<!---
    Desc : Barkod ve Ürün Adı ile arama yapılarak Ürün hakkında bilgilere ulaşılır. Standart ve toptan satış fiyatı, ürün görseli, ürün belgeleri ve tüm depolardaki stok miktarını ve ürünün ana birimini getirir.
    Dev  : Yunus Emre Yazıcı
    Date : 03.01.2021
--->

<cfparam name="attributes.stock_barcode" default="">
<cfparam name="attributes.stocks_price" default="">
<cfparam name="attributes.stock_name" default="">

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
            P.PRODUCT_ID AS URUN_ID,
            PI.PATH
        FROM
            STOCKS S 
            LEFT JOIN PRODUCT P ON P.PRODUCT_ID = S.PRODUCT_ID
            LEFT JOIN #DSN3#.PRICE PR ON PR.PRODUCT_ID = S.PRODUCT_ID
            LEFT JOIN PRODUCT_IMAGES PI ON PI.PRODUCT_ID = PR.PRODUCT_ID
        WHERE
            <cfif isDefined("attributes.barcode_no") and len(attributes.barcode_no)>
                S.BARCOD LIKE '%#attributes.barcode_no#%'AND
            </cfif>
            <cfif isDefined("attributes.stock_name") and len(attributes.stock_name) gt 0 and len(attributes.stock_id) gt 0>
                S.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.stock_id#"> AND
            </cfif>
            PR.FINISHDATE IS NULL
            AND S.BARCOD IS NOT NULL
            AND PI.IS_COVER = 1
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

        <!---
        <cfquery name="GET_SEVK" datasource="#DSN2#">
            SELECT DISTINCT 
                SR.STOCK_IN,
                D.DEPARTMENT_HEAD,
                SL.COMMENT
            FROM 
                STOCKS_ROW SR
                LEFT JOIN #DSN#.DEPARTMENT D ON D.DEPARTMENT_ID = SR.STORE
                LEFT JOIN #DSN#.STOCKS_LOCATION SL ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID
            WHERE
                SR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_STOCK_PRICE.PRODUCT_ID#"> 
                AND SR.STOCK_IN <> 0
            ORDER BY
                DEPARTMENT_HEAD ASC
        </cfquery>
        --->

        <cfquery name="GET_TOTAL_STOCK" datasource="#DSN2#">
            SELECT 
                TS.PRODUCT_STOCK,
                TS.PRODUCT_ID,
                TS.STOCK_ID,
                TS.STOCK_CODE,
                TS.STOCK_STATUS,
                TS.BARCOD,
                TS.STORE,
                TS.STORE_LOCATION,
                D.DEPARTMENT_DETAIL,
                D.DEPARTMENT_HEAD,
                PU.MAIN_UNIT
            FROM 
                GET_STOCK_LOCATION_TOTAL TS
                LEFT JOIN #DSN#.DEPARTMENT D ON D.DEPARTMENT_ID = TS.STORE
                LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_ID = TS.PRODUCT_ID
            WHERE 
                TS.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_STOCK_PRICE.PRODUCT_ID#">
                AND TS.PRODUCT_STOCK > 0 /* sıfır stok olan depoları göstermemek için */
                AND PU.IS_MAIN = 1
        </cfquery>

        <cfquery name="GET_SUM_TOTAL_STOCK" datasource="#DSN2#">
            SELECT 
                SUM(PRODUCT_STOCK) AS TOPLAM_STOK
            FROM 
                GET_STOCK_LOCATION_TOTAL TS
                LEFT JOIN #DSN#.DEPARTMENT D ON D.DEPARTMENT_ID = TS.STORE
            WHERE 
                PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_STOCK_PRICE.PRODUCT_ID#">
                AND TS.PRODUCT_STOCK <> 0
        </cfquery>

        <!---
            SELECT DISTINCT 
                SR.STOCK_IN,
                D.DEPARTMENT_HEAD,
                SL.LOCATION_ID,
                SL.COMMENT,
                SR.SHELF_NUMBER
            FROM 
                catalyst_birikim.catalyst_birikim_2022_1.STOCKS_ROW SR
                LEFT JOIN catalyst_birikim.catalyst_birikim.DEPARTMENT D ON D.DEPARTMENT_ID = SR.STORE
                LEFT JOIN catalyst_birikim.catalyst_birikim.STOCKS_LOCATION SL ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID
            WHERE
                SR.PRODUCT_ID = 29282
                AND SR.STOCK_IN <> 0
                AND SL.LOCATION_ID = 1
        --->
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
    <cf_box title="Barkod ya da Ürün Adı Giriniz">
        <cfform name="product_inquiry" id="product_inquiry" method="POST" action="" >
            <cf_box_search>
                <div class="col col-12 col-xs-12">
                    <div class="row formContent">
                        <div class="row" type="row">
                            <div class="col col-4 col-md-4 col-sm-6 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <div class="col col-12 col-md-12">
                                        <div class="form-group">
                                            <!---
                                            <label class="col col-12 col-xs-12">Barkod</label>
                                            --->
                                            <div class="col col-12">
                                                <div class="input-group">
                                                    <input type="hidden" name="form_submit" id="form_submit" value="1" />
                                                    <input placeholder="Barkod" type="text" name="barcode_no" id="barcode_no" value="" style="width:100px;" <!---laceholder="Barkod"--->>
                                                </div>	
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-3 col-sm-6 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <div class="col col-12 col-xs-12">
                                        <div class="form-group">
                                            <!---
                                            <label class="col col-12 col-xs-12"><cf_get_lang_main no='245.Ürün'> Adı</label>
                                            --->
                                            <div class="col col-12">
                                                <div class="input-group">
                                                    <input type="hidden" name="stock_id" id="stock_id" <cfif len(attributes.stock_name)>value="<cfoutput>#attributes.stock_id#</cfoutput>"</cfif>>
                                                    <input placeholder="<cf_get_lang_main no='245.Ürün'> Adı" type="text" name="stock_name" id="stock_name" style="width:150px;" value="<cfoutput>#attributes.stock_name#</cfoutput>"  onFocus="AutoComplete_Create('stock_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID','stock_id','','3','225');" autocomplete="off">
                                                    <span class="input-group-addon btnPointer icon-ellipsis" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=product_inquiry.stock_id&field_name=product_inquiry.stock_name','list');"></span>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col col-4 col-md-3 col-sm-6 col-xs-12">
                                <div class="col col-12 col-xs-12">
                                    <div class="col col-12 col-xs-12">
                                        <div class="form-group">
                                            <!---
                                            <label class="col col-12 col-xs-12">Ara</label>
                                            --->
                                            <div class="col col-12">
                                                <div class="input-group">
                                                    <cf_wrk_search_button button_type="4">
                                                </div>	
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>               
                        </div>
                    </div>
                </div>
            <cf_box_search>
        </cfform>
    </cf_box>
    <div class="loader"></div>
    <cfsavecontent variable="head">Fiyat Gör</cfsavecontent>
    <cf_box title="#head#" uidrop="1" hide_table_column="1">
        <div class="form-group searchList">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th style ="width:5%">Barkod</th>
                        <th style ="width:20%;">Ürün Adı</th>
                        <th style ="width:15%">Ürün Görseli</th>
                        <th style="width:10%">Belgeler</th>
                        <th style="width:10%;">Toptan Satış Fiyatı</th>
                        <cfif session.ep.isBranchAuthorization eq 1 or session.ep.admin eq 1>
                            <th style="width:10%;">Standart Satış Fiyatı</th>
                        </cfif>
                        <th style="width:20%;">Şube / Depo - Stok Miktarı</th>
                    </tr>
                </thead>
                <tbody>
                    <cfif isdefined("attributes.form_submit")>
                        <cfif GET_STOCK_PRICE.recordcount neq 0>
                            <cfif isDefined("attributes.barcode_no") and len(attributes.barcode_no) or isDefined("attributes.stock_name") and len(attributes.stock_name)>
                                <tr>
                                    <th style ="width:10%"><cfoutput>#GET_STOCK_PRICE.BARKOD#</cfoutput></th>
                                    <th style ="width:20%"><cfoutput><a href="#request.self#?fuseaction=stock.list_stock&event=det&pid=#GET_STOCK_PRICE.PRODUCT_ID#">#GET_STOCK_PRICE.URUN_ADI#</a></cfoutput></th>
                                    <th style ="width:15%">
                                        <cfif len(GET_STOCK_PRICE.PATH)>
                                            <cf_get_server_file output_file="../../documents/product/#GET_STOCK_PRICE.PATH#" image_height="350" output_server="1" output_type="5">
                                            <!---
                                            <cf_get_server_file output_file="../../documents/product/#GET_STOCK_PRICE.PATH#" image_height="350" image_width="350" output_server="1" output_type="5">
                                            --->
                                            <cfelse>
                                        </cfif>
                                    </th>
                                    <th style="width:20%">
                                        <cfquery name="GET_ASSET" datasource="#DSN#">
                                            SELECT 
                                                ASSET_NO,
                                                ASSET_FILE_NAME, 
                                                ASSET_NAME 
                                            FROM 
                                                ASSET A 
                                            WHERE 
                                                ACTION_ID =#GET_STOCK_PRICE.URUN_ID# AND MODULE_ID = 5
                                        </cfquery>
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                    <th align="left">Belge No</th>
                                                    <th align="left">Belge Adı</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif len(GET_ASSET.ASSET_FILE_NAME)>
                                                    <cfoutput query="GET_ASSET">
                                                        <tr align="left">
                                                            <td>#ASSET_NO#</td>
                                                            <td><a href="#file_web_path#/product/#asset_file_name#" target="_blank" class="tableyazi">#asset_name#</a></td>
                                                        </tr>
                                                    </cfoutput>
                                                <cfelse>
                                                    <tr>
                                                        <td colspan="2"><a style="color:red">Ürün Belgesi Bulunamadı!</a></td>
                                                    </tr>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </th>
                                    <th style ="width:10%">
                                        <cf_grid_list>
                                            <thead>
                                                <th>KDV Hariç</th>
                                                <th>KDV Dahil</th>
                                            </thead>
                                            <tbody>
                                                <cfif len(GET_STOCK_PRICE.TOPTAN_LISTE) and GET_STOCK_PRICE.TOPTAN_LISTE neq 0>
                                                    <cfoutput>
                                                        <td>#TLFormat(GET_STOCK_PRICE.TOPTAN_LISTE)# #GET_STOCK_PRICE.DOVIZ#</td>
                                                        <td>#TLFormat(GET_STOCK_PRICE.TOPTAN_LISTE_KDV)# #GET_STOCK_PRICE.DOVIZ#</td>
                                                    </cfoutput>
                                                <cfelse>
                                                    <td colspan="2"><a style="color:red">Toptan Satış Fiyatı Bulunamadı !</a></td>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </th>
                                    <cfif session.ep.isBranchAuthorization eq 1 or session.ep.admin eq 1>
                                        <th style ="width:10%">
                                            <cf_grid_list>
                                                <thead>
                                                    <th>KDV Hariç</th>
                                                    <th>KDV Dahil</th>
                                                </thead>
                                                <tbody>
                                                    <cfif len(GET_PRICE_SS.PRICE) and GET_PRICE_SS.PRICE neq 0>
                                                        <cfoutput>
                                                            <td>#TLFormat(GET_PRICE_SS.PRICE)# #GET_PRICE_SS.MONEY#</td>
                                                            <td>#TLFormat(GET_PRICE_SS.PRICE_KDV)# #GET_PRICE_SS.MONEY#</td>
                                                        </cfoutput>
                                                    <cfelse>
                                                        <td colspan="2"><a style="color:red">Standart Satış Fiyatı Bulunamadı !</a></td>
                                                    </cfif>
                                                </tbody>
                                            </cf_grid_list>
                                        </th>
                                    </cfif>
                                    <cfif GET_TOTAL_STOCK.recordcount neq 0>
                                        <th align="left" style="width:15%">
                                            <cf_grid_list>
                                                <thead>
                                                    <th width="10">No.</th>
                                                    <th>Depo</th>
                                                    <th>Miktar (S.Stok)</th>
                                                    <th>Birim</th>
                                                </thead>
                                                <cfoutput query="GET_TOTAL_STOCK">
                                                    <tbody>
                                                        <th>#currentRow#.</th>
                                                        <td>#DEPARTMENT_HEAD#</td>
                                                        <td>#PRODUCT_STOCK#</td>
                                                        <!---
                                                        <td>#GET_PRICE_SS.ADD_UNIT#</td>
                                                        --->
                                                        <td>#MAIN_UNIT#</td>
                                                    </tbody>
                                                </cfoutput>
                                                <tr style="background-color:lightblue" align="center">
                                                    <td colspan="2" align="center"><a style="color:red; font-size:18px">TOPLAM</a></td>
                                                    <td><a style="color:red; font-size:18px"><cfoutput>#GET_SUM_TOTAL_STOCK.TOPLAM_STOK#</cfoutput></a></td>
                                                    <td align="left"><a style="color:red; font-size:18px"><cfoutput>#GET_TOTAL_STOCK.MAIN_UNIT#</cfoutput></a></td>
                                                </tr>
                                            </cf_grid_list>
                                        </th>
                                    <cfelse>
                                        <th colspan="2" style="width:15%"><a style="color:red">Ürün Stoklarda Bulunamadı !</a></th>
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