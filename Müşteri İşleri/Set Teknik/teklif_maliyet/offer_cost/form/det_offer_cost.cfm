<cfquery name="GET_OFFER_COST" datasource="#DSN3#">
    SELECT
        O.OFFER_COST_ID,
        O.OFFER_COST_STATUS,
        O.OFFER_COST_STAGE,
        O.OFFER_COST_NUMBER,
        O.OFFER_COST_HEAD,
        O.COMPANY_ID,
        O.PARTNER_ID,
        O.PROJECT_ID,
        O.RECORD_DATE,
        O.RECORD_EMP,
        O.UPDATE_DATE,
        O.UPDATE_EMP,
        E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS RECORDER,
        O.OFFER_COST_DETAIL,
        O.PRODUCT_ID,
        O.STOCK_ID,
        O.SALES_EMP,
        EE.EMPLOYEE_NAME + ' ' + EE.EMPLOYEE_SURNAME AS SALES,
        O.INTERNAL_ID
    FROM
        OFFER_COST O
        LEFT JOIN #DSN#.EMPLOYEES E ON E.EMPLOYEE_ID=O.RECORD_EMP
        LEFT JOIN #DSN#.EMPLOYEES EE ON EE.EMPLOYEE_ID=O.SALES_EMP
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
</cfquery>
<!---Tabloya join eklendi -Kerem--->
<cfif len(GET_OFFER_COST.PROJECT_ID)>
    <cfquery name="GET_PROJECT" datasource="#DSN#">
        SELECT
            *
        FROM
            PRO_PROJECTS
        WHERE
            PROJECT_ID =  #GET_OFFER_COST.PROJECT_ID#
    </cfquery>
</cfif>

<cfquery name="GET_OFFER_COST_ROW" datasource="#DSN3#">
     SELECT
        OCR.PRODUCT_ID,
        OCR.PRODUCT_NAME,
        OCR.PRODUCT_UNIT,
        OCR.QUANTITY,
        MONEY,
        OCR.PRICE_EXWORK,
        OCR.DISCOUNT,
        OCR.NET_PRICE_EXWORK,
        OCR.UNIT_COST,
        OCR.TOTAL_COST,
        OCR.UNIT_OFFER,
        OCR.TOTAL_OFFER,
        OCR.EXPORT_FACTOR,
        OCR.OFFER_FACTOR,
        OCR.PROFIT_MARGIN,
        OCR.IS_ALTERNATIVE,
        OCR.PROVISION_TIME,
        OCR.ROW_GROUP_NAME AS ROW_GROUP_NAME,
        OCR.ROW_GROUP_QUANTITY AS ROW_GROUP_QUANTITY,
        OCR.RECORD_DATE,
        OCR.RECORD_EMP,
        OCR.UPDATE_DATE,
        OCR.UPDATE_EMP,
        PC.PRODUCT_CAT AS PRODUCT_CAT,
        PC.PRODUCT_CATID,
        PB.BRAND_NAME AS BRAND_NAME,
        PBM.MODEL_NAME AS MODEL_NAME
    FROM
        OFFER_COST_ROW OCR
        LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
        LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS PB ON PB.BRAND_ID = P.BRAND_ID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS_MODEL PBM ON PBM.MODEL_ID = P.SHORT_CODE_ID
    WHERE
        OCR.OFFER_COST_ID = #attributes.offer_cost_id#
    ORDER BY
        OCR.ROW_GROUP_NAME ASC
</cfquery>

<cfquery name="GET_OFFER_COST_GROUP" datasource="#DSN3#">
    SELECT 
        OFFER_COST_GROUP, GROUP_QUANTITY 
    FROM 
        OFFER_COST_GROUP_PRODUCT 
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
        AND
        OFFER_COST_GROUP <> 'Hizmet'
</cfquery>

<cfinclude template="../query/get_offer_cost_row_product.cfm">

<cfinclude template="../query/get_money.cfm">

<cfscript>
    usd_price = get_money_usd.rate2;
    eur_price = get_money_eur.rate2;
    gbp_price = get_money_gbp.rate2;
    parite = usd_price/eur_price;
</cfscript>

<cfscript>
    i = 0;
    total_eur_product = 0;
    total_eur_product_cost = 0;
    grand_total_eur_product_offer = 0;
    grand_total_eur_product_cost = 0;
    total_eur_product_grupsuz = 0;
    total_eur_product_cost_grupsuz = 0;
</cfscript>

<cfscript>
    toplam_eur = 0;
    total_offer_eur = 0;
    total_offer_tl = 0;
    toplam_eur_group = 0;
    total_offer_eur_group = 0;
    total_offer_tl_group = 0;
</cfscript>

<cfscript>
    to_eur_group_hizmet = 0;
    to_eur_hizmet = 0;
    total_eur_group_hizmet = 0;
    total_eur_hizmet = 0;
    total_eur_hizmet_cost = 0;
    sum_total_eur_group_hizmet = 0;
    sum_total_eur_hizmet = 0;

    sum_to_eur_group_hizmet = 0;
    sum_to_eur_hizmet = 0;
</cfscript>

<cfscript>
    toplam_eur_hizmet = 0;
    total_offer_eur_hizmet = 0;
    total_offer_tl_hizmet = 0;
    toplam_eur_group_hizmet = 0;
    total_offer_eur_group_hizmet = 0;
    total_offer_tl_group_hizmet = 0;
</cfscript>

<!--- maliyet için --->
<cfscript>
    to_eur_group_cost = 0;
    to_eur_cost = 0;
    total_eur_group_cost = 0;
    total_eur_cost = 0;
    sum_total_eur_group_cost = 0;
    sum_total_eur_cost = 0;
    total_offer_eur_cost = 0;
    sum_to_eur_group_cost = 0;
    sum_to_eur_cost = 0;
</cfscript>

<cfscript>
    toplam_eur_cost = 0;
    total_cost_eur = 0;
    total_cost_tl = 0;
    toplam_eur_group_cost = 0;
    total_cost_eur_group = 0;
    total_cost_tl_group = 0;
</cfscript>

<cfscript>
    toplam_eur_hizmet_cost = 0;
    total_cost_eur_hizmet = 0;
    total_cost_tl_hizmet = 0;
    to_tl_hizmet_cost =0;
    to_eur_hizmet_cost =0;
    toplam_eur_group_hizmet_cost = 0;
    total_cost_eur_group_hizmet = 0;
    total_cost_tl_group_hizmet = 0;
    services_and_product_total_product_offer = 0;
    services_and_product_total_product_cost = 0;
</cfscript>

<!--- opsiyon ürünler --->
<cfscript>
    toplam_eur_option = 0;
    total_eur_option = 0;
    total_eur_option_cost = 0;
</cfscript>

<!--- bakım ürünleri --->
<cfscript>
    toplam_eur_bakim = 0;
    total_eur_bakim = 0;
    total_eur_bakim_cost = 0;
</cfscript>

<cfscript>
    karlilik = 0;
    toplam_eur = 0;
    toplam_eur_cost = 0;
    toplam_eur_cost = 0;
</cfscript>

<cfscript>
    karlilik =0;
    total_eur_product =0;
    total_eur_product_cost =0;
</cfscript>

<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY = cmp.getCountry()>
<cfquery name="GET_SALE_ZONES" datasource="#DSN#">
	SELECT SZ_ID,SZ_NAME FROM SALES_ZONES
</cfquery>
<cf_catalystHeader>
<cfoutput>
    <cf_box responsive_table="1" title="Genel Bilgiler">
        <cf_box_elements>
            <div class="col col-4 col-md-4 col-sm-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-offer_cost_head">
                    <div class="col col-8 col-sm-6">
                        <label>Teklif Maliyet Numarası : </label>
                        <label>#get_offer_cost.offer_cost_head#</label>
                    </div>
                </div>
                <div class="form-group" id="item-member_name">
                    <div class="col col-8 col-sm-6">
                        <label>Şirket / Yetkili:</label>
                        <label>#get_par_info(GET_OFFER_COST.PARTNER_ID,0,0,0)#</label>
                    </div>
                </div>
                <div class="form-group" id="item-project_head"><!---label id düzeltildi -Kerem--->
                    <div class="col col-8 col-sm-6">
                        <label>Proje: </label>
                        <cfif len(GET_OFFER_COST.PROJECT_ID)>
                            <label>#GET_PROJECT.PROJECT_HEAD#</label>
                        <cfelse>
                            <label>Projesiz</label>
                        </cfif>
                    </div>
                </div>
                <!---Tarih ve kayıt eden alanları eklendi -Kerem--->
                <div class="form-group" id="item-record_date">
                    <div class="col col-8 col-sm-6">
                        <label>Tarih:</label>
                        <label>#dateformat(get_offer_cost.RECORD_DATE,'dd/mm/yyyy')#</label>
                    </div>
                </div>
                <div class="form-group" id="item-record_emp">
                    <div class="col col-8 col-sm-6">
                        <label>Kayıt Eden:</label>
                        <label>#get_offer_cost.RECORDER#</label>
                    </div>
                </div>
                <div class="form-group" id="item-sales_emp">
                    <div class="col col-8 col-sm-6">
                        <label>Satış Yapan:</label>
                        <label>#get_offer_cost.SALES#</label>
                    </div>
                </div>
                <div class="form-group" id="item-offer_cost_detail">
                    <div class="col col-8 col-sm-6">
                        <label>Açıklama:</label>
                        <label>#get_offer_cost.OFFER_COST_DETAIL#</label>
                    </div>
                </div>
            </div>
            <div class="col col-4 col-md-4 col-sm-12" type="column" index="2" sort="true">
                <div class="ui-row">
                    <div id="sepetim_total">
                        <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                            <div class="totalBox">
                                <div class="totalBoxHead font-grey-mint">
                                    <span class="headText">Kur</span>
                                    <div class="collapse">
                                        <span class="icon-minus"></span>
                                    </div>
                                </div>
                                <div class="totalBoxBody"> 
                                    <table>
                                        <cfoutput>
                                            <cfloop query="get_money">
                                                <tr>
                                                    <td colspan="2">
                                                        <input type="hidden" name="hidden_rd_money_#currentrow#" value="#money#" id="hidden_rd_money_#currentrow#">
                                                        <input type="hidden" name="txt_rate1_#currentrow#" value="#rate1#" id="txt_rate1_#currentrow#">
                                                        <cfif MONEY neq 'TL'>
                                                            <label>#MONEY#</label><label></label>
                                                        </cfif>
                                                    </td>
                                                    <td colspan="2">
                                                        <cfif MONEY neq 'TL'>
                                                            </label><label>#RATE2#</label>
                                                        </cfif>
                                                    </td>
                                                </tr>
                                            </cfloop>
                                        </cfoutput>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </cf_box_elements>
    </cf_box>
</cfoutput>

<cfscript>
    total_eur_product_grupsuz = 0;
    total_eur_product_cost_grupsuz = 0;
</cfscript>

<cf_box title="Ürünler">
    <cf_grid_list sort="0">
        <thead>
            <tr>
                <th>Grup Adı</th>
                <th>Ürün Kategorisi</th>
                <th>Grup Miktarı</th>
                <th>Ürün Tipi</th>
                <th>Ürün</th>
                <th>Marka</th>
                <th>Model</th>
                <th>Birim</th>
                <th>Miktar</th>
                <th>Döviz Cinsi</th>
                <th>Liste Exwork</th>
                <th>İskonto (%)</th>
                <th>Net Alış</th>
                <th>İthalat Katsayısı</th>
                <th>Birim Maliyet</th>
                <th>Toplam Maliyet</th>
                <th>Toplam Maliyet (EUR)</th>
                <th>Teklif Katsayısı</th>
                <th>Birim Teklif</th>
                <th>Toplam Teklif</th>
                <th>Teslim Süresi</th>
                <th>Kar Marjı</th>
                <th>Toplam Teklif (EUR)</th>
            </tr>
        </thead>
        
        <tbody>
            <cfoutput>
                <cfloop query="#get_offer_cost_group#">
                    <cfscript>
                        i=i+1;
                    </cfscript>
                    <cfset grup_adi = '#get_offer_cost_group.offer_cost_group#'>
                    <cfset grup_adedi = #get_offer_cost_group.group_quantity#>
                    <cfloop query="get_offer_cost_row_product">
                        <cfif grup_adi eq row_group_name>
                            <cfscript>
                                if(MONEY eq "TL"){
                                    to_eur_product = TOTAL_OFFER/eur_price;
                                    to_eur_product_cost = TOTAL_COST/eur_price;
                                }
                                else if(MONEY eq "USD"){
                                    to_tl_product = TOTAL_OFFER*usd_price;
                                    to_eur_product = to_tl_product/eur_price;
                                    to_tl_product_cost = TOTAL_COST*usd_price;
                                    to_eur_product_cost = to_tl_product_cost/eur_price;
                                }
                                else if(MONEY eq "EUR"){
                                    to_eur_product = TOTAL_OFFER;
                                    to_eur_product_cost = TOTAL_COST;
                                }
                                else if(MONEY eq "GBP"){
                                    to_tl_product = TOTAL_OFFER*gbp_price;
                                    to_eur_product = to_tl_product/eur_price;
                                    to_tl_product_cost = TOTAL_COST*gbp_price;
                                    to_eur_product_cost = to_tl_product_cost/eur_price;
                                }
                                
                                
                            </cfscript>
                            <tr>
                                <td>#ROW_GROUP_NAME#</td>
                                <td>#PRODUCT_CAT#</td>
                                <td>#ROW_GROUP_QUANTITY#</td>
                                <cfif is_alternative eq 0>
                                    <td>Normal</td>
                                <cfelseif is_alternative eq 1>
                                    <td>Yeni Ürün</td>
                                <cfelseif is_alternative eq 2>
                                    <td>Opsiyon Ürün</td>
                                <cfelseif is_alternative eq 3>
                                    <td>Bakım</td>
                                <cfelse>
                                    <td>-</td>
                                </cfif>
                                <td>#PRODUCT_NAME#</td>
                                <td>#BRAND_NAME#</td>
                                <td>#MODEL_NAME#</td>
                                <td>#PRODUCT_UNIT#</td>
                                <td>#QUANTITY#</td>
                                <td>#MONEY#</td>
                                <td>#TLFormat(PRICE_EXWORK,3)#</td>
                                <td>#DISCOUNT#</td>
                                <td>#TLFormat(NET_PRICE_EXWORK,3)# #MONEY#</td>
                                <td>#EXPORT_FACTOR#</td>
                                <td>#TLFormat(UNIT_COST,3)# #MONEY#</td>
                                <td>#TLFormat(TOTAL_COST,3)# #MONEY#</td>
                                <td>#TLFormat(to_eur_product_cost,3)# EUR</td>
                                <td>#OFFER_FACTOR#</td>
                                <td>#TLFormat(UNIT_OFFER,3)# #MONEY#</td>
                                <td>#TLFormat(TOTAL_OFFER,3)# #MONEY#</td>
                                <td>#PROVISION_TIME#</td>
                                <td>#TLFormat(PROFIT_MARGIN)#</td>
                                <td>#TLFormat(to_eur_product)# EUR</td>
                            </tr>
                            <cfscript>
                                total_eur_product = total_eur_product+to_eur_product;
                                total_eur_product_cost = total_eur_product_cost+to_eur_product_cost;
                            </cfscript>
                            <cfscript>
                                total_eur_product_grup_toplami = total_eur_product+to_eur_product;
                                total_eur_product_cost_grup_toplami = total_eur_product_cost+to_eur_product_cost;
                            </cfscript>
                        </cfif>
                    </cfloop>
                        <cfscript>
                            //net_total_eur_product = total_eur_product*grup_adedi;
                            //net_total_eur_product_cost = total_eur_product_cost*grup_adedi;
                            net_total_eur_product = total_eur_product;
                            net_total_eur_product_cost = total_eur_product_cost;
                        </cfscript>
                        <tr>
                            <td colspan="23" style="color:red">
                                <b><i>#grup_adi# Grubu Teklif Toplamı: #TLFormat(total_eur_product,3)# EUR</i></b></br>
                                <b><i>#grup_adi# Grubu Maliyet Toplamı: #TLFormat(total_eur_product_cost,3)# EUR</i></b>
                            </td>
                             <cfscript>
                                total_eur_product = 0;
                                total_eur_product_cost = 0;
                            </cfscript>
                        </tr>
                        <tr>
                            <td colspan="23">
                                <cfscript>
                                    karlilik = (total_eur_product_grup_toplami-total_eur_product_cost_grup_toplami)*100/total_eur_product_cost_grup_toplami;
                                </cfscript>
                            </br>
                                <b style="color:black"><i>#grup_adi# Grubu Karlılık: %#TLFormat(karlilik,3)#</i></b>
                            </td>
                        </tr>
                        <cfscript>
                            grand_total_eur_product_offer = grand_total_eur_product_offer+net_total_eur_product;
                            grand_total_eur_product_cost = grand_total_eur_product_cost+net_total_eur_product_cost;
                        </cfscript>
                        <!---
                        <b>teklif : #grand_total_eur_product_offer#</b></br>
                        <b>maliyet : #grand_total_eur_product_cost#</b></br>
                        --->
                        <!---
                        <div id="sepetim_total">
                            <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                                <div class="totalBox">
                                    <div class="totalBoxHead font-grey-mint">
                                        <span class="headText">#grup_adi#</span>
                                        <div class="collapse">
                                            <span class="icon-minus"></span>
                                        </div>
                                    </div>
                                    <div class="totalBoxBody"> 
                                        <table>
                                            <cfoutput>
                                                <cfloop query="get_money">
                                                    <tr>
                                                        <td>Grubu Teklif Toplamı: #TLFormat(total_eur_product,3)# EUR</td>
                                                    </tr>
                                                    <tr>
                                                        <td>Grubu Maliyet Toplamı Toplamı: #TLFormat(total_eur_product,3)# EUR</td>
                                                    </tr>
                                                    <tr>
                                                        <td>Karlılık: %#TLFormat(karlilik,3)#</td>
                                                    </tr>
                                                </cfloop>
                                            </cfoutput>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        --->
                </cfloop>
                <cfif get_offer_cost_row_product_non_group.recordcount gt 0> <!--- grubu olmayan satırlar için --->
                    <cfloop query="#get_offer_cost_row_product_non_group#">
                        <cfscript>
                            if(MONEY eq "TL"){
                                to_eur_product_grupsuz = TOTAL_OFFER/eur_price;
                                to_eur_product_cost_grupsuz = TOTAL_COST/eur_price;
                            }
                            else if(MONEY eq "USD"){
                                to_tl_product_grupsuz = TOTAL_OFFER*usd_price;
                                to_eur_product_grupsuz = to_tl_product_grupsuz/eur_price;
                                to_tl_product_cost_grupsuz = TOTAL_COST*usd_price;
                                to_eur_product_cost_grupsuz = to_tl_product_cost_grupsuz/eur_price;
                            }
                            else if(MONEY eq "EUR"){
                                to_eur_product_grupsuz = TOTAL_OFFER;
                                to_eur_product_cost_grupsuz = TOTAL_COST;
                            }
                            else if(MONEY eq "GBP"){
                                to_tl_product_grupsuz = TOTAL_OFFER*gbp_price;
                                to_eur_product_grupsuz = to_tl_product_grupsuz/eur_price;
                                to_tl_product_cost_grupsuz = TOTAL_COST*gbp_price;
                                to_eur_product_cost_grupsuz = to_tl_product_cost_grupsuz/eur_price;
                            }
                        </cfscript>
                            <tr>
                                <td><cfif len(ROW_GROUP_NAME)>#ROW_GROUP_NAME#<cfelse>Grup Yok</cfif></td>
                                <td>#PRODUCT_CAT#</td>
                                <td>#ROW_GROUP_QUANTITY#</td>
                                <cfif is_alternative eq 0>
                                    <td>Normal</td>
                                <cfelseif is_alternative eq 1>
                                    <td>Yeni Ürün</td>
                                <cfelseif is_alternative eq 2>
                                    <td>Opsiyon Ürün</td>
                                <cfelseif is_alternative eq 3>
                                    <td>Bakım</td>
                                <cfelse>
                                    <td>-</td>
                                </cfif>
                                <td>#PRODUCT_NAME#</td>
                                <td>#BRAND_NAME#</td>
                                <td>#MODEL_NAME#</td>
                                <td>#PRODUCT_UNIT#</td>
                                <td>#QUANTITY#</td>
                                <td>#MONEY#</td>
                                <td>#TLFormat(PRICE_EXWORK,3)#</td>
                                <td>#DISCOUNT#</td>
                                <td>#TLFormat(NET_PRICE_EXWORK,3)# #MONEY#</td>
                                <td>#EXPORT_FACTOR#</td>
                                <td>#TLFormat(UNIT_COST,3)# #MONEY#</td>
                                <td>#TLFormat(TOTAL_COST,3)# #MONEY#</td>
                                <td>#TLFormat(to_eur_product_cost_grupsuz,3)# EUR</td>
                                <td>#OFFER_FACTOR#</td>
                                <td>#TLFormat(UNIT_OFFER,3)# #MONEY#</td>
                                <td>#TLFormat(TOTAL_OFFER,3)# #MONEY#</td>
                                <td>#PROVISION_TIME#</td>
                                <td>#TLFormat(PROFIT_MARGIN)#</td>
                                <td>#TLFormat(to_eur_product_grupsuz)# EUR</td>
                            </tr>
                            <cfscript>
                                total_eur_product_grupsuz = total_eur_product_grupsuz+to_eur_product_grupsuz;
                                total_eur_product_cost_grupsuz = total_eur_product_cost_grupsuz+to_eur_product_cost_grupsuz;
                            </cfscript>
                    </cfloop>
                    <tr>
                        <td colspan="23" style="color:red">
                            <b><i>Gruplanmamış Ürünler Teklif Toplamı: #TLFormat(total_eur_product_grupsuz,3)# EUR</i></b></br>
                            <b><i>Gruplanmamış Ürünler Maliyet Toplamı: #TLFormat(total_eur_product_cost_grupsuz,3)# EUR</i></b>
                        </td>
                    </tr>
                    <cfscript>
                        if(total_eur_product_grupsuz==total_eur_product_cost_grupsuz)
                        {
                            karlilik_grupsuz=0;
                        }
                        else{
                            karlilik_grupsuz = (total_eur_product_grupsuz-total_eur_product_cost_grupsuz)*100/total_eur_product_cost_grupsuz;
                        }
                    </cfscript>
                    <tr>
                        <td colspan="23">
                            <b style="color:black"><i>Gruplanmamış Ürünler Karlılık : % #TLFormat(karlilik_grupsuz,3)# EUR</i></b>
                        </td>
                    </tr>
                </cfif>
            </cfoutput>
        </tbody>
    </cf_grid_list>
</cf_box>

<cfscript>
    product_offer_total = 0;
    product_offer_total = grand_total_eur_product_offer+total_eur_product_grupsuz;
    product_cost_total = grand_total_eur_product_cost+total_eur_product_cost_grupsuz;
</cfscript>

<cfscript>
    product_offer_total_eur = product_offer_total;
    product_offer_total_tl = product_offer_total_eur*eur_price;
    product_offer_total_usd = product_offer_total_tl/usd_price;
    product_offer_total_gbp = product_offer_total_tl/gbp_price;
</cfscript>

<cfscript>
    product_cost_total_eur = product_cost_total;
    product_cost_total_tl = product_cost_total_eur*eur_price;
    product_cost_total_usd = product_cost_total_tl/usd_price;
    product_cost_total_gbp = product_cost_total_tl/gbp_price;
</cfscript>

<cfscript>
    if(product_offer_total_eur==product_cost_total_eur)
    {
        total_karlilik_urunler=0;
    }
    else{
        total_karlilik_urunler = (product_offer_total_eur-product_cost_total_eur)*100/product_cost_total_eur;
    }
    
</cfscript>

<div basket_footer style="width:100%;" align="left">
    <div class="ui-row">
        <div id="sepetim_total" class="padding-0">
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Ürünler Teklif Toplamı</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td><label>USD</label></td>
                                    <td>#TLFormat(product_offer_total_usd,3)# USD</td>
                                </tr>
                                <tr>
                                    <td><label>EUR</label></td>
                                    <td>#TLFormat(product_offer_total_eur,3)# EUR</td>
                                </tr>
                                <tr>
                                    <td><label>GBP</label></td>
                                    <td>#TLFormat(product_offer_total_gbp,3)# GBP</td>
                                </tr>
                                <tr>
                                    <td><label>TL</label></td>
                                    <td>#TLFormat(product_offer_total_tl,3)# TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Ürünler Maliyet Toplamı</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td><label>USD</label></td>
                                    <td>#TLFormat(product_cost_total_usd,3)# USD</td>
                                </tr>
                                <tr>
                                    <td><label>EUR</label></td>
                                    <td>#TLFormat(product_cost_total_eur,3)# EUR</td>
                                </tr>
                                <tr>
                                    <td><label>GBP</label></td>
                                    <td>#TLFormat(product_cost_total_gbp,3)# GBP</td>
                                </tr>
                                <tr>
                                    <td><label>TL</label></td>
                                    <td>#TLFormat(product_cost_total_tl,3)# TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Ürünler Toplam Karlılık</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody">
                        <table>
                            <cfoutput>
                                <tr>
                                    <td><label>Ürünler Karlılık</label></td>
                                    <td>%#TLFormat(total_karlilik_urunler,3)#</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!--- Opsiyon Ürünler --->
<cf_box title="Opsiyon Ürünler">
    <cf_grid_list>
        <thead>
            <tr>
                <th>Grup Adı</th>
                <th>Ürün Kategorisi</th>
                <th>Ürün Tipi</th>
                <th>Ürün</th>
                <th>Marka</th>
                <th>Model</th>
                <th>Birim</th>
                <th>Miktar</th>
                <th>Döviz Cinsi</th>
                <th>Liste Exwork</th>
                <th>İskonto (%)</th>
                <th>Net Alış</th>
                <th>İthalat Katsayısı</th>
                <th>Birim Maliyet</th>
                <th>Toplam Maliyet</th>
                <th>Teklif Katsayısı</th>
                <th>Birim Teklif</th>
                <th>Toplam Teklif</th>
                <th>Teslim Süresi</th>
                <th>Kar Marjı</th>
                <th>Toplam Teklif (EUR)</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="get_offer_cost_row">
                <cfif is_alternative eq 2>
                    <cfscript>
                        if(MONEY eq "TL"){
                            to_eur_option = TOTAL_OFFER/eur_price;
                            to_eur_option_cost = TOTAL_COST/eur_price;
                            to_tl_option_cost = to_eur_option*eur_price;
                        }
                        else if(MONEY eq "USD"){
                            to_tl_option = TOTAL_OFFER*usd_price;
                            to_eur_option = to_tl_option/eur_price;
                            to_tl_option_cost = TOTAL_COST*usd_price;
                            to_eur_option_cost = to_tl_option_cost/eur_price;
                        }
                        else if(MONEY eq "EUR"){
                            to_eur_option = TOTAL_OFFER;
                            to_eur_option_cost = TOTAL_COST;
                        }
                        else if(MONEY eq "GBP"){
                            to_tl_option = TOTAL_OFFER*gbp_price;
                            to_eur_option = to_tl_option/eur_price;
                            to_tl_option_cost = TOTAL_COST*gbp_price;
                            to_eur_option_cost = to_tl_option_cost/eur_price;
                        }
                            total_eur_option = total_eur_option+to_eur_option;
                            total_eur_option_cost = total_eur_option_cost+to_eur_option_cost;
                    </cfscript>
                    <tr>
                        <td>#ROW_GROUP_NAME#</td>
                        <td>#PRODUCT_CAT#</td>
                        <cfif is_alternative eq 0>
                                <td>Normal</td>
                            <cfelseif is_alternative eq 1>
                                <td>Yeni Ürün</td>
                            <cfelseif is_alternative eq 2>
                                <td>Opsiyon Ürün</td>
                            <cfelse>
                                <td>-</td>
                        </cfif>
                        <td>#PRODUCT_NAME#</td>
                        <td>#BRAND_NAME#</td>
                        <td>#MODEL_NAME#</td>
                        <td>#PRODUCT_UNIT#</td>
                        <td>#QUANTITY#</td>
                        <td>#MONEY#</td>
                        <td>#TLFormat(PRICE_EXWORK,3)#</td>
                        <td>#DISCOUNT#</td>
                        <td>#TLFormat(NET_PRICE_EXWORK,3)# #MONEY#</td>
                        <td>#EXPORT_FACTOR#</td>
                        <td>#TLFormat(UNIT_COST,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_COST,3)# #MONEY#</td>
                        <td>#OFFER_FACTOR#</td>
                        <td>#TLFormat(UNIT_OFFER,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_OFFER,3)# #MONEY#</td>
                        <td>#PROVISION_TIME#</td>
                        <td>#TLFormat(PROFIT_MARGIN)#</td>
                        <td>#TLFormat(to_eur_option)# EUR</td>
                    </tr>
                </cfif>
            </cfoutput>
            <tr>
                <td colspan="19" style="color:red">
                    <b><i>Opsiyon Ürünler Teklif Toplamı : <cfoutput>#TLFormat(total_eur_option,3)#</cfoutput> EUR</b></i>
                    </br>
                    <b><i>Opsiyon Ürünler Maliyet Toplamı : <cfoutput>#TLFormat(total_eur_option_cost,3)#</cfoutput> EUR</i></b>
                </td>
            </tr>
        </tbody>
    </cf_grid_list>

    <!--- opsiyon ürünler TEKLİF --->
    <cfscript>
        grand_total_option_offer = 0;
        grand_total_option_offer_eur = total_eur_option;
        grand_total_option_offer_to_tl = grand_total_option_offer_eur*eur_price;
        grand_total_option_offer_to_usd = grand_total_option_offer_eur/usd_price;
        grand_total_option_offer_to_gbp = grand_total_option_offer_eur/gbp_price;
    </cfscript>
    <!--- opsiyon ürünler MALİYET --->
    <cfscript>
        grand_total_option_cost = 0;
        grand_total_option_cost_eur = total_eur_option_cost;
        grand_total_option_cost_to_tl = grand_total_option_cost_eur*eur_price;
        grand_total_option_cost_to_usd = grand_total_option_cost_eur/usd_price;
        grand_total_option_cost_to_gbp = grand_total_option_cost_eur/gbp_price;
    </cfscript>
    
    <div basket_footer style="width:100%;" align="left">
        <div id="sepetim_total">
            <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Opsiyon Ürünler Toplam Teklif</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_offer_to_usd,3)#</td>
                                    <td colspan="2">USD</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_offer_eur,3)#</td>
                                    <td colspan="2">EUR</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_offer_to_gbp,3)#</td>
                                    <td colspan="2">GBP</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_offer_to_tl,3)#</td>
                                    <td colspan="2">TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Opsiyon Ürünler Toplam Maliyet</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_cost_to_usd,3)#</td>
                                    <td colspan="2">USD</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_cost_eur,3)#</td>
                                    <td colspan="2">EUR</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_cost_to_gbp,3)#</td>
                                    <td colspan="2">GBP</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_option_cost_to_tl,3)#</td>
                                    <td colspan="2">TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cf_box>
<!--- Opsiyon ürünler --->

<!--- Hizmet Grubu --->
<cf_box title="Hizmet Grubu">
    <cf_grid_list>
        <thead>
            <tr>
                <th>Grup Adı</th>
                <th>Ürün Kategorisi</th>
                <th>Ürün Tipi</th>
                <th>Ürün</th>
                <th>Marka</th>
                <th>Model</th>
                <th>Birim</th>
                <th>Miktar</th>
                <th>Döviz Cinsi</th>
                <th>Liste Exwork</th>
                <th>İskonto (%)</th>
                <th>Net Alış</th>
                <th>İthalat Katsayısı</th>
                <th>Birim Maliyet</th>
                <th>Toplam Maliyet</th>
                <th>Teklif Katsayısı</th>
                <th>Birim Teklif</th>
                <th>Toplam Teklif</th>
                <th>Teslim Süresi</th>
                <th>Kar Marjı</th>
                <th>Toplam Teklif (EUR)</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="get_offer_cost_row">
                <cfif ROW_GROUP_NAME eq 'Hizmet'>
                    <cfscript>
                        if(MONEY eq "TL"){
                            to_eur_hizmet = TOTAL_OFFER/eur_price;
                            to_eur_hizmet_cost = TOTAL_COST/eur_price;
                        }
                        else if(MONEY eq "USD"){
                            to_tl_hizmet = TOTAL_OFFER*usd_price;
                            to_eur_hizmet = to_tl_hizmet/eur_price;
                            to_tl_hizmet_cost = TOTAL_COST*usd_price;
                            to_eur_hizmet_cost = to_tl_hizmet_cost/eur_price;
                        }
                        else if(MONEY eq "EUR"){
                            to_eur_hizmet = TOTAL_OFFER;
                            to_eur_hizmet_cost = TOTAL_COST;
                        }
                        else if(MONEY eq "GBP"){
                            to_tl_hizmet = TOTAL_OFFER*gbp_price;
                            to_eur_hizmet = to_tl_hizmet/eur_price;
                            to_tl_hizmet_cost = TOTAL_COST*gbp_price;
                            to_eur_hizmet_cost = to_tl_hizmet_cost/eur_price;
                        }
                            total_eur_hizmet = total_eur_hizmet+to_eur_hizmet;
                            total_eur_hizmet_cost = total_eur_hizmet_cost+to_eur_hizmet_cost;
                    </cfscript>
                    <tr>
                        <td>#ROW_GROUP_NAME#</td>
                        <td>#PRODUCT_CAT#</td>
                        <cfif is_alternative eq 0>
                                <td>Normal</td>
                            <cfelseif is_alternative eq 1>
                                <td>Yeni Ürün</td>
                            <cfelseif is_alternative eq 2>
                                <td>Opsiyon Ürün</td>
                            <cfelse>
                                <td>-</td>
                        </cfif>
                        <td>#PRODUCT_NAME#</td>
                        <td>#BRAND_NAME#</td>
                        <td>#MODEL_NAME#</td>
                        <td>#PRODUCT_UNIT#</td>
                        <td>#QUANTITY#</td>
                        <td>#MONEY#</td>
                        <td>#TLFormat(PRICE_EXWORK,3)#</td>
                        <td>#DISCOUNT#</td>
                        <td>#TLFormat(NET_PRICE_EXWORK,3)# #MONEY#</td>
                        <td>#EXPORT_FACTOR#</td>
                        <td>#TLFormat(UNIT_COST,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_COST,3)# #MONEY#</td>
                        <td>#OFFER_FACTOR#</td>
                        <td>#TLFormat(UNIT_OFFER,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_OFFER,3)# #MONEY#</td>
                        <td>#PROVISION_TIME#</td>
                        <td>#TLFormat(PROFIT_MARGIN)#</td>
                        <td>#TLFormat(to_eur_hizmet,3)# EUR</td>
                    </tr>
                </cfif>
            </cfoutput>
            <tr>
                <td colspan="19" style="color:red">
                    <b><i>Hizmet Ürünleri Teklif Toplamı : <cfoutput>#TLFormat(total_eur_hizmet,3)#</cfoutput> EUR</b></i>
                    </br>
                    <b><i>Hizmet Ürünleri Maliyet Toplamı : <cfoutput>#TLFormat(total_eur_hizmet_cost,3)#</cfoutput> EUR</i></b>
                    
                    <cfscript>
                        hizmet_fark = total_eur_hizmet_cost-total_eur_hizmet;
                        if(hizmet_fark gt 0)
                        {
                            karlilik_hizmet = (total_eur_hizmet-total_eur_hizmet_cost)*100/total_eur_hizmet_cost;
                        }
                        else
                        {
                            karlilik_hizmet = 0;
                        }
                    </cfscript>
                </td>
            </tr>
        </tbody>
    </cf_grid_list>

    <!--- hizmet ürünler TEKLİF --->
    <cfscript>
        grand_total_hizmet_offer = 0;
        grand_total_hizmet_offer_eur = total_eur_hizmet;
        grand_total_hizmet_offer_to_tl = grand_total_hizmet_offer_eur*eur_price;
        grand_total_hizmet_offer_to_usd = grand_total_hizmet_offer_to_tl/usd_price;
        grand_total_hizmet_offer_to_gbp = grand_total_hizmet_offer_to_tl/gbp_price;
    </cfscript>
    <!--- hizmet ürünler MALİYET --->
    <cfscript>
        grand_total_hizmet_cost = 0;
        grand_total_hizmet_cost_eur = total_eur_hizmet_cost;
        grand_total_hizmet_cost_to_tl = total_eur_hizmet_cost*eur_price;
        grand_total_hizmet_cost_to_usd = grand_total_hizmet_cost_to_tl/usd_price;
        grand_total_hizmet_cost_to_gbp = grand_total_hizmet_cost_to_tl/gbp_price;
    </cfscript>

    <div basket_footer style="width:100%;" align="left">
            <div id="sepetim_total">
                <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                    <div class="totalBox">
                        <div class="totalBoxHead font-grey-mint">
                            <span class="headText">Hizmet Ürünleri Toplam Teklif</span>
                            <div class="collapse">
                                <span class="icon-minus"></span>
                            </div>
                        </div>
                        <div class="totalBoxBody"> 
                            <table>
                                <cfoutput>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_cost_to_usd,3)#</td>
                                        <td colspan="2">USD</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_cost_eur,3)#</td>
                                        <td colspan="2">EUR</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_cost_to_gbp,3)#</td>
                                        <td colspan="2">GBP</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_cost_to_tl,3)#</td>
                                        <td colspan="2">TL</td>
                                    </tr>
                                </cfoutput>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                    <div class="totalBox">
                        <div class="totalBoxHead font-grey-mint">
                            <span class="headText">Hizmet Ürünleri Toplam Maliyet</span>
                            <div class="collapse">
                                <span class="icon-minus"></span>
                            </div>
                        </div>
                        <div class="totalBoxBody"> 
                            <table>
                                <cfoutput>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_offer_to_usd,3)#</td>
                                        <td colspan="2">USD</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_offer_eur,3)#</td>
                                        <td colspan="2">EUR</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_offer_to_gbp,3)#</td>
                                        <td colspan="2">GBP</td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">#TLFormat(grand_total_hizmet_offer_to_tl,3)#</td>
                                        <td colspan="2">TL</td>
                                    </tr>
                                </cfoutput>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                    <div class="totalBox">
                        <div class="totalBoxHead font-grey-mint">
                            <span class="headText">Hizmetler Toplam Karlılık</span>
                            <div class="collapse">
                                <span class="icon-minus"></span>
                            </div>
                        </div>
                        <div class="totalBoxBody">
                            <cfif grand_total_hizmet_cost_eur gt 0>
                                <cfscript>
                                    services_and_product_total_product_offer =grand_total_hizmet_offer_eur+product_offer_total_eur;
                                    services_and_product_total_product_cost = grand_total_hizmet_cost_eur+product_cost_total_eur;
                                    services_and_product_total_karlilik = (services_and_product_total_product_offer-services_and_product_total_product_cost)*100/services_and_product_total_product_cost;
                                </cfscript>
                            <!--- 
                                <cfscript>
                                    services_and_product_total_product_offer =grand_total_hizmet_offer_eur+grand_total_hizmet_offer_eur;
                                    services_and_product_total_product_cost = grand_total_hizmet_cost_eur+grand_total_hizmet_cost_eur;
                                    services_and_product_total_karlilik = (services_and_product_total_product_offer-services_and_product_total_product_cost)*100/services_and_product_total_product_cost;
                                </cfscript>
                            --->
                                <table>
                                    <cfoutput>
                                        <tr>
                                            <td><label>Hizmetler Karlılık</label></td>
                                            <td>%#TLFormat(karlilik_hizmet,3)#</td>
                                        </tr>
                                        <tr>
                                        <cfif hizmet_fark neq 0>
                                            <tr>
                                                <td><label>Ürünler ve Hizmetler Karlılık</label></td>
                                                <td>%#TLFormat(services_and_product_total_karlilik,3)#</td>
                                            </tr>
                                        </cfif>
                                    </cfoutput>
                                </table>
                            </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <cfscript>
            product_offer_total_eur = product_offer_total;
            product_offer_total_tl = product_offer_total_eur*eur_price;
            product_offer_total_usd = product_offer_total_tl/usd_price;
            product_offer_total_gbp = product_offer_total_tl/gbp_price;
        </cfscript>

        <cfscript>
            grand_total_hizmet_offer_eur = total_eur_hizmet;
            grand_total_hizmet_offer_to_tl = grand_total_hizmet_offer_eur*eur_price;
            grand_total_hizmet_offer_to_usd = grand_total_hizmet_offer_to_tl/usd_price;
            grand_total_hizmet_offer_to_gbp = grand_total_hizmet_offer_to_tl/gbp_price;
        </cfscript>

        <cfscript>
            grand_total_hizmet_cost_eur = total_eur_hizmet_cost;
            grand_total_hizmet_cost_to_tl = total_eur_hizmet_cost*eur_price;
            grand_total_hizmet_cost_to_usd = grand_total_hizmet_cost_to_tl/usd_price;
            grand_total_hizmet_cost_to_gbp = grand_total_hizmet_cost_to_tl/gbp_price;
        </cfscript>
        <cfscript>
            grand_total_offer_eur = product_offer_total_eur+grand_total_hizmet_offer_eur;
            grand_total_offer_to_tl = grand_total_offer_eur*eur_price;
            grand_total_offer_to_usd = grand_total_offer_to_tl/usd_price;
            grand_total_offer_to_gbp = grand_total_offer_to_tl/gbp_price;
        </cfscript>

        <cfscript>
            product_cost_total_eur = product_cost_total;
            product_cost_total_tl = product_cost_total_eur*eur_price;
            product_cost_total_usd = product_cost_total_tl/usd_price;
            product_cost_total_gbp = product_cost_total_tl/gbp_price;
        </cfscript>

        <cfscript>
            grand_total_hizmet_cost_eur = total_eur_hizmet_cost;
            grand_total_hizmet_cost_to_tl = total_eur_hizmet_cost*eur_price;
            grand_total_hizmet_cost_to_usd = grand_total_hizmet_cost_to_tl/usd_price;
            grand_total_hizmet_cost_to_gbp = grand_total_hizmet_cost_to_tl/gbp_price;
        </cfscript>

        <cfscript>
            grand_total_cost_eur = product_cost_total+total_eur_hizmet_cost;
            grand_total_cost_to_tl = grand_total_cost_eur*eur_price;
            grand_total_cost_to_usd = grand_total_cost_to_tl/usd_price;
            grand_total_cost_to_gbp = grand_total_cost_to_tl/gbp_price;
        </cfscript>

        <div basket_footer style="width:100%;" align="left">
            <div class="ui-row">
                <div id="sepetim_total" class="padding-0">
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <div class="totalBox">
                            <div class="totalBoxHead font-grey-mint">
                                <span class="headText">Genel Toplam Teklif</span>
                                <div class="collapse">
                                    <span class="icon-minus"></span>
                                </div>
                            </div>
                            <cfoutput>
                                <div class="totalBoxBody">
                                    <table>
                                    <tr>
                                    <td><label>USD</label></td>
                                    <td>#TLFormat(grand_total_offer_to_usd,3)# USD</td>
                                    </tr>
                                    <tr>
                                        <td><label>EUR</label></td>
                                        <td>#TLFormat(grand_total_offer_eur,3)# EUR</td>
                                    </tr>
                                    <tr>
                                        <td><label>GBP</label></td>
                                        <td>#TLFormat(grand_total_offer_to_gbp,3)# GBP</td>
                                    </tr>
                                    <tr>
                                        <td><label>TL</label></td>
                                        <td>#TLFormat(grand_total_offer_to_tl,3)# TL</td>
                                    </tr>
                                    </table>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-12">
                        <div class="totalBox">
                            <div class="totalBoxHead font-grey-mint">
                                <span class="headText">Genel Toplam Maliyet</span>
                                <div class="collapse">
                                    <span class="icon-minus"></span>
                                </div>
                            </div>
                            <cfoutput>
                                <div class="totalBoxBody">
                                    <table>
                                    <tr>
                                    <td><label>USD</label></td>
                                    <td>#TLFormat(grand_total_cost_to_usd,3)# USD</td>
                                    </tr>
                                    <tr>
                                        <td><label>EUR</label></td>
                                        <td>#TLFormat(grand_total_cost_eur,3)# EUR</td>
                                    </tr>
                                    <tr>
                                        <td><label>GBP</label></td>
                                        <td>#TLFormat(grand_total_cost_to_gbp,3)# GBP</td>
                                    </tr>
                                    <tr>
                                        <td><label>TL</label></td>
                                        <td>#TLFormat(grand_total_cost_to_tl,3)# TL</td>
                                    </tr>
                                    </table>
                                </div>
                            </cfoutput>
                        </div>
                    </div>
                </div>
            </div>
        </div>
</cf_box>
<!--- Hizmet Grubu --->

<!--- Bakım Ürünleri --->
<cf_box title="Bakım Ürünleri">
    <cf_grid_list>
        <thead>
            <tr>
                <th>Grup Adı</th>
                <th>Ürün Kategorisi</th>
                <th>Ürün Tipi</th>
                <th>Ürün</th>
                <th>Marka</th>
                <th>Model</th>
                <th>Birim</th>
                <th>Miktar</th>
                <th>Döviz Cinsi</th>
                <th>Liste Exwork</th>
                <th>İskonto (%)</th>
                <th>Net Alış</th>
                <th>İthalat Katsayısı</th>
                <th>Birim Maliyet</th>
                <th>Toplam Maliyet</th>
                <th>Teklif Katsayısı</th>
                <th>Birim Teklif</th>
                <th>Toplam Teklif</th>
                <th>Teslim Süresi</th>
                <th>Kar Marjı</th>
                <th>Toplam Teklif (EUR)</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="get_offer_cost_row">
                <cfif is_alternative eq 3>
                    <cfscript>
                        if(MONEY eq "TL"){
                            to_eur_bakim_tl = TOTAL_OFFER;
                            to_eur_bakim = to_eur_bakim_tl/eur_price;
                            to_eur_bakim_cost_tl = TOTAL_COST;
                            to_eur_bakim_cost = to_eur_bakim_cost_tl/eur_price;
                        }
                        else if(MONEY eq "USD"){
                            to_tl_bakim_cost = TOTAL_COST*usd_price;
                            to_tl_bakim = TOTAL_OFFER*usd_price;
                            to_eur_bakim = to_tl_bakim/eur_price;
                            to_tl_bakim = TOTAL_COST*usd_price;
                            to_eur_bakim = to_tl_bakim_cost/eur_price;
                            to_eur_bakim_cost = to_tl_bakim_cost/eur_price;
                        }
                        else if(MONEY eq "EUR"){
                            to_eur_bakim = TOTAL_OFFER;
                            to_eur_bakim_cost = TOTAL_COST;
                        }
                        else if(MONEY eq "GBP"){
                            to_tl_bakim_cost = TOTAL_COST*gbp_price;
                            to_tl_bakim = TOTAL_OFFER*gbp_price;
                            to_eur_bakim = to_tl_bakim/eur_price;
                            to_tl_bakim = TOTAL_COST*gbp_price;
                            to_eur_bakim = to_tl_bakim_cost/eur_price;
                            to_eur_bakim_cost = to_tl_bakim_cost/eur_price;
                        }
                            total_eur_bakim = total_eur_bakim+to_eur_bakim;
                            total_eur_bakim_cost = total_eur_bakim_cost+to_eur_bakim_cost;
                    </cfscript>
                    <tr>
                        <td>#ROW_GROUP_NAME#</td>
                        <td>#PRODUCT_CAT#</td>
                        <cfif is_alternative eq 0>
                                <td>Normal</td>
                            <cfelseif is_alternative eq 1>
                                <td>Yeni Ürün</td>
                            <cfelseif is_alternative eq 2>
                                <td>Opsiyon Ürün</td>
                            <cfelseif is_alternative eq 3>
                                <td>Bakım</td>
                            <cfelse>
                                <td>-</td>
                        </cfif>
                        <td>#PRODUCT_NAME#</td>
                        <td>#BRAND_NAME#</td>
                        <td>#MODEL_NAME#</td>
                        <td>#PRODUCT_UNIT#</td>
                        <td>#QUANTITY#</td>
                        <td>#MONEY#</td>
                        <td>#TLFormat(PRICE_EXWORK,3)#</td>
                        <td>#DISCOUNT#</td>
                        <td>#TLFormat(NET_PRICE_EXWORK,3)# #MONEY#</td>
                        <td>#EXPORT_FACTOR#</td>
                        <td>#TLFormat(UNIT_COST,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_COST,3)# #MONEY#</td>
                        <td>#OFFER_FACTOR#</td>
                        <td>#TLFormat(UNIT_OFFER,3)# #MONEY#</td>
                        <td>#TLFormat(TOTAL_OFFER,3)# #MONEY#</td>
                        <td>#PROVISION_TIME#</td>
                        <td>#TLFormat(PROFIT_MARGIN)#</td>
                        <td>#TLFormat(to_eur_bakim)# EUR</td>
                    </tr>
                </cfif>
            </cfoutput>
            <tr>
                <td colspan="19" style="color:red">
                    <b><i>Bakım Ürünleri Teklif Toplamı : <cfoutput>#TLFormat(total_eur_bakim,3)#</cfoutput> EUR</b></i>
                    </br>
                    <b><i>Bakım Ürünleri Maliyet Toplamı : <cfoutput>#TLFormat(total_eur_bakim_cost,3)#</cfoutput> EUR</i></b>
                </td>
            </tr>
        </tbody>
    </cf_grid_list>

    <!--- bakım ürünleri TEKLİF --->
    <cfscript>
        grand_total_bakim_offer = 0;
        grand_total_bakim_offer_eur = total_eur_bakim;
        grand_total_bakim_offer_to_tl = grand_total_bakim_offer_eur*eur_price;
        grand_total_bakim_offer_to_usd = grand_total_bakim_offer_to_tl/usd_price;
        grand_total_bakim_offer_to_gbp = grand_total_bakim_offer_to_tl/gbp_price;
    </cfscript>
    <!--- bakım ürünleri MALİYET --->
    <cfscript>
        grand_total_bakim_cost = 0;
        grand_total_bakim_cost_eur = total_eur_bakim_cost;
        grand_total_bakim_cost_to_tl = grand_total_bakim_cost_eur*eur_price;
        grand_total_bakim_cost_to_usd = grand_total_bakim_cost_eur/usd_price;
        grand_total_bakim_cost_to_gbp = grand_total_bakim_cost_eur/gbp_price;
    </cfscript>

    <div basket_footer style="width:100%;" align="left">
        <div id="sepetim_total">
            <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Bakım Ürünleri Toplam Teklif</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_offer_to_usd,3)#</td>
                                    <td colspan="2">USD</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_offer_eur,3)#</td>
                                    <td colspan="2">EUR</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_offer_to_gbp,3)#</td>
                                    <td colspan="2">GBP</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_offer_to_tl,3)#</td>
                                    <td colspan="2">TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col col-3 col-md-3 col-sm-3 col-xs-6">
                <div class="totalBox">
                    <div class="totalBoxHead font-grey-mint">
                        <span class="headText">Bakım Ürünleri Toplam Maliyet</span>
                        <div class="collapse">
                            <span class="icon-minus"></span>
                        </div>
                    </div>
                    <div class="totalBoxBody"> 
                        <table>
                            <cfoutput>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_cost_to_usd,3)#</td>
                                    <td colspan="2">USD</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_cost_eur,3)#</td>
                                    <td colspan="2">EUR</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_cost_to_gbp,3)#</td>
                                    <td colspan="2">GBP</td>
                                </tr>
                                <tr>
                                    <td colspan="2">#TLFormat(grand_total_bakim_cost_to_tl,3)#</td>
                                    <td colspan="2">TL</td>
                                </tr>
                            </cfoutput>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</cf_box>
<!--- Bakım Ürünleri --->