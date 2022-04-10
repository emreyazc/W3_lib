<!---
    Desc : Stok Kodundan fiyat ve depo bazında stok sorgulatır.
    Dev  : Yunus Emre Yazıcı
    Date : 03.01.2021
--->

<cfparam name="attributes.stock_barcode" default="">
<cfparam name="attributes.stocks_price" default="">

<cfif isdefined("attributes.form_submit")>
    <cfquery name="GET_STOCK_PRICE" datasource="#DSN1#">
        SELECT
            S.PRODUCT_ID,
            S.STOCK_CODE,
            S.BARCOD AS BARKOD,
            P.PRODUCT_NAME AS URUN_ADI,
            PR.PRICE AS TOPTAN_LISTE,
            PR.PRICE_KDV AS TOPTAN_LISTE_KDV,
            PR.MONEY AS DOVIZ,
            P.PRODUCT_ID
        FROM
            STOCKS S 
            LEFT JOIN PRODUCT P ON P.PRODUCT_ID = S.PRODUCT_ID
            LEFT JOIN #DSN3#.PRICE PR ON PR.STOCK_ID = S.STOCK_ID
        <cfif isDefined("attributes.barcode_no") and len(attributes.barcode_no)>
        WHERE
            S.BARCOD LIKE '%#attributes.barcode_no#%'
            <cfif isDefined("attributes.produt_name_label") and len(attributes.produt_name_label)>
                OR P.PRODUCT_NAME LIKE '%#attributes.produt_name_label#%'
            </cfif>
            AND PR.FINISHDATE IS NULL
            AND S.BARCOD IS NOT NULL
        </cfif>
    </cfquery>

    <!---
    <cfquery name="GET_DEPARTMENT" datasource="#DSN#">
        SELECT
            D.DEPARTMENT_ID,
            D.DEPARTMENT_HEAD,
            SL.COMMENT,
            SL.LOCATION_ID,
            D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS LOCATION_NAME
        FROM
            BRANCH B,
            DEPARTMENT D,
            STOCKS_LOCATION SL
        WHERE
            B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
            B.BRANCH_ID = D.BRANCH_ID AND
            SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
            D.DEPARTMENT_STATUS = 1 AND
            B.BRANCH_ID IN(SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">)
        ORDER BY
            LOCATION_NAME
    </cfquery>
    --->

    <cfif len(GET_STOCK_PRICE.PRODUCT_ID)>
        <cfquery name="GET_PRICE_SS" datasource="#DSN3#">
            SELECT	
                PRICE,
                PRICE_KDV,
            <cfif session.ep.period_year lt 2009>
                CASE WHEN MONEY ='TL' THEN '<cfoutput>#session.ep.money#</cfoutput>' ELSE MONEY END AS MONEY,
            <cfelse>
                MONEY,
            </cfif> 
                ADD_UNIT,
                PRODUCT_UNIT_ID
            FROM 
                PRICE_STANDART,
                PRODUCT_UNIT
            WHERE
                PRICE_STANDART.PRODUCT_ID = #GET_STOCK_PRICE.PRODUCT_ID# AND
                PRICE_STANDART.PURCHASESALES = 1 AND 
                PRICE_STANDART.PRICESTANDART_STATUS = 1 AND 
                PRODUCT_UNIT.PRODUCT_ID = PRICE_STANDART.PRODUCT_ID AND 
                PRICE_STANDART.UNIT_ID = PRODUCT_UNIT.PRODUCT_UNIT_ID
                AND PRICE_STANDART.PRODUCT_ID = #GET_STOCK_PRICE.PRODUCT_ID#
            ORDER BY
                PRODUCT_UNIT.PRODUCT_UNIT_ID
        </cfquery>

        <cfquery name="GET_SEVK" datasource="#DSN2#">
            SELECT DISTINCT 
                SR.STOCK_IN,
                D.DEPARTMENT_HEAD
            FROM 
                STOCKS_ROW SR
                LEFT JOIN #DSN#.DEPARTMENT D ON D.DEPARTMENT_ID = SR.STORE
                LEFT JOIN #DSN#.STOCKS_LOCATION SL ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID
            WHERE
                SR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_STOCK_PRICE.PRODUCT_ID#"> AND
                SR.STOCK_IN <> 0
        </cfquery>
    </cfif>
</cfif>

<!---
<cfif isDefined("attributes.barcode_no") and len(attributes.barcode_no)>
    <cfdump var="#GET_STOCK_PRICE#">
    <cfdump  var="#GET_PRICE_SS#">
    <cfdump var="#GET_DEPARTMENT#">
    <cfdump var="#GET_SEVK#">
</cfif>
--->

<title>
    Fiyat Gör
</title>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="product_inquiry" id="product_inquiry" method="POST" action="" >
            <cf_box_search title="Fiyat Sorgulama " closable="0" id="product_inquiry_price">
                <cfinput type="hidden" name="form_submit" id="form_submit" value="1" />
                <div class="form-group">						
                    <cfinput type="text" name="barcode_no" id="barcode_no" value="" style="width:100px;"  placeholder="Barkod">
                </div>
                <cfif session.ep.userid eq 111>
                    <div class="form-group">						
                        <cfinput type="text" name="produt_name_label" id="produt_name_label" value="" placeholder="Ürün Adı">
                    </div>
                </cfif>
                <div class="form-group"><cf_wrk_search_button button_type="4"></div>
            </cf_box_search>
        </cfform>
    </cf_box>
    <div class="loader"></div>
    <cfsavecontent variable="head">Fiyat Gör</cfsavecontent>
    <cf_box title="#head#" uidrop="1" hide_table_column="1">
        <div class="form-group searchList">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th style ="width:20%">Barkod</th>
                        <th style ="width:20%;">Ürün Adı</th>
                        <th style="width:20%;">Toptan Satış Fiyatı</th>
                        <th style="width:20%;">Standart Satış Fiyatı</th>
                        <th style="width:20%;">Şube / Depo - Stok Miktarı</th>
                    </tr>
                </thead>
                <tbody>
                    <cfif isdefined("attributes.form_submit")>
                        <cfif GET_STOCK_PRICE.recordcount neq 0>
                            <cfif isDefined("attributes.barcode_no") and len(attributes.barcode_no)>
                                <tr>
                                    <th style ="width:10%"><cfoutput>#GET_STOCK_PRICE.BARKOD#</cfoutput></th>
                                    <th style ="width:20%"><cfoutput><a href="#request.self#?fuseaction=stock.list_stock&event=det&pid=#GET_STOCK_PRICE.PRODUCT_ID#">#GET_STOCK_PRICE.URUN_ADI#</a></cfoutput></th>
                                    <th style ="width:20%"><cfif len(GET_STOCK_PRICE.TOPTAN_LISTE) and GET_STOCK_PRICE.TOPTAN_LISTE neq 0><cfoutput>KDV Hariç : #TLFormat(GET_STOCK_PRICE.TOPTAN_LISTE)# #GET_STOCK_PRICE.DOVIZ# <br> KDV Dahil : #TLFormat(GET_STOCK_PRICE.TOPTAN_LISTE_KDV)# #GET_STOCK_PRICE.DOVIZ#</cfoutput><cfelse><a style="color:red">Toptan Satış Fiyatı Bulunamadı !</a></cfif></th>
                                    <th style ="width:20%"><cfif len(GET_PRICE_SS.PRICE) and GET_PRICE_SS.PRICE neq 0><cfoutput>KDV Hariç : #TLFormat(GET_PRICE_SS.PRICE)# #GET_PRICE_SS.MONEY#  <br> KDV Dahil : #TLFormat(GET_PRICE_SS.PRICE_KDV)# #GET_PRICE_SS.MONEY#</cfoutput><cfelse><a style="color:red">Standart Satış Fiyatı Bulunamadı !</a></cfif></th>
                                    <cfif GET_SEVK.recordcount neq 0>
                                        <th style="width:15%"><cfoutput query="GET_SEVK"><p>#DEPARTMENT_HEAD# Depo - #STOCK_IN# #GET_PRICE_SS.ADD_UNIT#</p></cfoutput></th>
                                    <cfelse>
                                        <th colspan="2" style="width:15%"><a style="color:red">Ürün Stokta Bulunamadı !</a></th>
                                    </cfif>
                                </tr>
                                <cfelse>
                                    <tr><td colspan="5"><a style="color:red">Ürün Bulunamadı !</a></td></tr>
                            </cfif>
                            <cfelse>
                            <tr><td colspan="5"><a style="color:red">Ürün Bulunamadı !</a></td></tr>
                        </cfif>
                    </cfif>
                </tbody>
            </cf_grid_list>
        </div>
    </cf_box>
</div>