<!---
	Date : 07.09.2021
	Desc : Satın Alma Talepleri raporudur.
	Company : Birikim Pilleri
	Developer : Yunus Emre Yazıcı
--->

<cfparam name="attributes.demand_type" default="">
<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.est_del" default="">
<cfparam name="attributes.demand_status" default="">

<cfquery name="GET_DATA" datasource="#DSN3#">
    SELECT
        INTERNAL_ID,
        TO_POSITION_CODE,
        TOTAL,
        INTERNALDEMAND.DISCOUNT,
        TOTAL_TAX,
        OTV_TOTAL,
        NET_TOTAL,
        INTERNALDEMAND.OTHER_MONEY AS OTHER_MONEY,
        INTERNALDEMAND_STATUS,
        PRIORITY,
        NOTES,
        FROM_POSITION_CODE,
        TARGET_DATE,
        INTERNALDEMAND.PROJECT_ID,
        WORK_ID,
        INTERNALDEMAND_STAGE,
        DEPARTMENT_IN,
        LOCATION_IN,
        DEPARTMENT_OUT,
        LOCATION_OUT,
        INTERNALDEMAND.REF_NO,
        SHIP_METHOD,
        INTERNAL_NUMBER,
        IS_ACTIVE,
        INTERNALDEMAND.SERVICE_ID,
        PROJECT_ID_OUT,
        INTERNALDEMAND.RECORD_EMP,
        INTERNALDEMAND.RECORD_DATE AS TALEP_DATE,
        INTERNALDEMAND.UPDATE_DATE,
        INTERNALDEMAND.UPDATE_EMP,
        DPL_ID,
        INTERNALDEMAND.DEMAND_TYPE AS TALEP_TIPI,
        OFFER_ID,
        FROM_COMPANY_ID,
        FROM_PARTNER_ID,
        FROM_CONSUMER_ID,
        PROCESS_CAT,
        SUBJECT,
        OPPORTUNITIES.OPP_STATUS,
        OPPORTUNITIES.OPP_CURRENCY_ID,
        OPPORTUNITIES.OPP_STAGE,
        OPPORTUNITIES.COMPANY_ID,
        OPPORTUNITIES.PARTNER_ID,
        OPPORTUNITIES.CONSUMER_ID,
        OPPORTUNITIES.OPP_HEAD,
        OPPORTUNITIES.OPP_DETAIL,
        OPPORTUNITIES.COMMETHOD_ID,
        OPPORTUNITIES.STOCK_ID,
        OPPORTUNITIES.PRODUCT_CAT_ID,
        OPPORTUNITIES.ACTIVITY_TIME,
        OPPORTUNITIES.INCOME,
        OPPORTUNITIES.MONEY,
        OPPORTUNITIES.PROBABILITY,
        OPPORTUNITIES.OPP_DATE,
        OPPORTUNITIES.ACTION_DATE,
        OPPORTUNITIES.INVOICE_DATE,
        OPPORTUNITIES.APPLICATION_LEVEL,
        OPPORTUNITIES.SALES_PARTNER_ID,
        OPPORTUNITIES.SALES_CONSUMER_ID,
        OPPORTUNITIES.CC_POSITIONS,
        OPPORTUNITIES.CC_PAR_IDS,
        OPPORTUNITIES.CC_CON_IDS,
        OPPORTUNITIES.CC_GRP_IDS,
        OPPORTUNITIES.CC_WRKGRP_IDS,
        OPPORTUNITIES.OPP_ZONE,
        OPPORTUNITIES.IS_VIEWED_PAR,
        OPPORTUNITIES.PROJECT_ID,
        OPPORTUNITIES.IS_PROCESSED,
        OPPORTUNITIES.OPP_NO,
        OPPORTUNITIES.CONSUMER_ID,
        OPPORTUNITIES.OPPORTUNITY_TYPE_ID,
        OPPORTUNITIES.REF_COMPANY_ID,
        OPPORTUNITIES.REF_PARTNER_ID,
        OPPORTUNITIES.REF_CONSUMER_ID,
        OPPORTUNITIES.REF_EMPLOYEE_ID,
        OPPORTUNITIES.COST,
        OPPORTUNITIES.MONEY2,
        OPPORTUNITIES.SALE_ADD_OPTION_ID,
        OPPORTUNITIES.SERVICE_ID,
        OPPORTUNITIES.SALES_EMP_ID,
        OPPORTUNITIES.SALES_TEAM_ID,
        OPPORTUNITIES.PREFERENCE_REASON_ID,
        OPPORTUNITIES.RIVAL_COMPANY_ID,
        OPPORTUNITIES.RIVAL_PARTNER_ID,
        OPPORTUNITIES.CUS_HELP_ID,
        OPPORTUNITIES.CAMPAIGN_ID,
        OPPORTUNITIES.ADD_RSS,
        OPPORTUNITIES.RECORD_EMP,
        OPPORTUNITIES.RECORD_PAR,
        OPPORTUNITIES.RECORD_DATE,
        OPPORTUNITIES.RECORD_IP,
        OPPORTUNITIES.UPDATE_EMP,
        OPPORTUNITIES.UPDATE_PAR,
        OPPORTUNITIES.UPDATE_DATE,
        OPPORTUNITIES.UPDATE_IP,
        OPPORTUNITIES.COUNTRY_ID,
        OPPORTUNITIES.SZ_ID,
        OPPORTUNITIES.EVENT_PLAN_ROW_ID,
        <!--- MÜŞTERİ İLE İGİLİ BİLGİLER --->
        COMPANY.FULLNAME AS FIRSAT_COMPANY,
        <!--- MÜŞTERİ İLE İGİLİ BİLGİLER --->
        <!--- ÜRÜN BİLGİLERİ --->
        PRODUCT.PRODUCT_NAME AS URUN_ADI,
        PRODUCT.COMPANY_ID AS URUN_TEDARIKCI,
        <!--- ÜRÜN BİLGİLERİ --->
        <!--- STOK BİLGİLERİ --->
        STOCKS.STOCK_CODE AS STOK_KODU,
        <!--- STOK BİLGİLERİ --->
        <!--- EK Bilgiler --->
        PRODUCT_INFO_PLUS.PROPERTY1 AS MENSEI,
        <!--- EK Bilgiler --->
        <!--- Basket Bilgi --->
        SETUP_BASKET_INFO_TYPES.BASKET_INFO_TYPE AS TAHMINI_TESLIM,
        <!--- Basket Bilgi --->
        <!--- ÜRÜN KATEGORİSİ --->
        PRODUCT_CAT.PRODUCT_CAT AS URUN_KATEGORI
        <!--- ÜRÜN KATEGORİSİ --->
    FROM
        INTERNALDEMAND
        LEFT JOIN OPPORTUNITIES ON OPPORTUNITIES.OPP_ID = INTERNALDEMAND.OPP_ID
        LEFT JOIN #DSN#.COMPANY ON #DSN#.COMPANY.COMPANY_ID = OPPORTUNITIES.COMPANY_ID
        LEFT JOIN INTERNALDEMAND_ROW ON INTERNALDEMAND_ROW.I_ID = INTERNALDEMAND.INTERNAL_ID
        LEFT JOIN PRODUCT ON PRODUCT.PRODUCT_ID = INTERNALDEMAND_ROW.PRODUCT_ID
        LEFT JOIN STOCKS ON STOCKS.STOCK_ID = INTERNALDEMAND_ROW.STOCK_ID
        LEFT JOIN PRODUCT_INFO_PLUS ON PRODUCT_INFO_PLUS.PRODUCT_ID = INTERNALDEMAND_ROW.PRODUCT_ID
        LEFT JOIN SETUP_BASKET_INFO_TYPES ON SETUP_BASKET_INFO_TYPES.BASKET_INFO_TYPE_ID = INTERNALDEMAND_ROW.BASKET_EXTRA_INFO_ID
        LEFT JOIN PRODUCT_CAT ON PRODUCT_CAT.PRODUCT_CATID = PRODUCT.PRODUCT_CATID
    WHERE
        INTERNAL_ID IS NOT NULL
            <!--- Talep tipi (iç talep yada satın alma) --->
            <cfif attributes.demand_type eq 1>
                AND DEMAND_TYPE = 1
            </cfif>
            <cfif attributes.demand_type eq 0>
                AND DEMAND_TYPE = 0
            </cfif>
            <!--- Basket tahmini teslim --->
            <cfif attributes.est_del eq 1>
                AND BASKET_EXTRA_INFO_ID = 1
            </cfif>
            <cfif attributes.est_del eq 2>
                AND BASKET_EXTRA_INFO_ID = 2
            </cfif>
            <cfif attributes.est_del eq 3>
                AND BASKET_EXTRA_INFO_ID = 3
            </cfif>
            <cfif attributes.est_del eq 4>
                AND BASKET_EXTRA_INFO_ID = 4
            </cfif>
            <cfif attributes.est_del eq 5>
                AND BASKET_EXTRA_INFO_ID = 5
            </cfif>
            <cfif attributes.est_del eq 6>
                AND BASKET_EXTRA_INFO_ID = 6
            </cfif>
            <!--- talep aktif / pasif durumu --->
            <cfif attributes.demand_status eq 0>
                AND IS_ACTIVE = 0
            </cfif>
            <cfif attributes.demand_status eq 1>
                AND IS_ACTIVE = 1
            </cfif>
</cfquery>

<cfquery name="GET_BASKET_INFO" datasource="#DSN3#">
    SELECT
        OPTION_NUMBER,
        BASKET_INFO_TYPE_ID,
        BASKET_INFO_TYPE
    FROM
        SETUP_BASKET_INFO_TYPES
    WHERE  
        OPTION_NUMBER = 1
</cfquery>

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.totalrecords" default=#GET_DATA.recordcount#>

<cfsavecontent variable="head"><cf_get_lang dictionary_id="33263.Satınalma Talepleri"></cfsavecontent>
<cf_report_list_search title="#head#">
    <cf_report_list_search_area>
        <cfform name="demand_detail_report" action="#request.self#?fuseaction=report.detail_report&event=det&report_id=37" method="post">
            <cf_box_elements>
                <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                        <label class="col col-12 col-xs-12">Talep Tipi</label>
                        <select name="demand_type" id="demand_type">
                            <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                            <option value="1"<cfif isdefined('attributes.demand_type')and attributes.demand_type eq 1>selected="selected"</cfif>>Satın Alma Talebi</option>
                            <option value="0"<cfif isdefined('attributes.demand_type')and attributes.demand_type eq 0>selected="selected"</cfif>>İç Talep</option>	
                        </select>
                    </div>
                    <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                        <label class="col col-12 col-xs-12">Talep Durumu</label>
                        <select name="demand_status" id="demand_status">
                            <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                            <option value="1"<cfif isdefined('attributes.demand_status')and attributes.demand_status eq 1>selected="selected"</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                            <option value="0"<cfif isdefined('attributes.demand_status')and attributes.demand_status eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>	
                        </select>
                    </div>
                </div>
                
                <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                   <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                        <label>Tahmini Teslim</label>
                        <select name="est_del" id="est_del">
                            <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                            <cfoutput query="GET_BASKET_INFO">
                                <option value="#GET_BASKET_INFO.BASKET_INFO_TYPE_ID #"<cfif isdefined('attributes.est_del')and attributes.est_del eq GET_BASKET_INFO.BASKET_INFO_TYPE_ID>selected="selected"</cfif>>#GET_BASKET_INFO.BASKET_INFO_TYPE#</option>
                            </cfoutput>
                        </select>
                    </div>
                    <!---
                    <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                        <label>Müşteri</label>
                        <input type="text">
                    </div>
                </div>
                
                <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                    <div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
                        <label>Ürün Kategorisi</label>
                        <input type="text">
                    </div>
                     --->
                </div>
               
                <div class="row ReportContentBorder">
                    <div class="ReportContentFooter">
                        <input name="form_submitted" id="form_submitted" value="1" type="hidden">
                        <label><cf_get_lang dictionary_id='57858.Excel Getir'><input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>></label>
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                        <cf_wrk_report_search_button search_function='control()' button_type='1'>
                    </div>
                </div>
            </cf_box_elements>
        </cfform>
    </cf_report_list_search_area>
</cf_report_list_search>
<cfif isdefined("attributes.form_submitted")>
    <cfif attributes.is_excel eq 1>
        <cfset filename="export_analyse#dateformat(now(),'ddmmyyyy')#_#timeformat(now(),'HHMMl')#_#session.ep.name#_#session.ep.surname#">
        <cfheader name="Expires" value="#Now()#">
        <cfcontent type="application/vnd.msexcel;charset=utf-16">
        <cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
        <meta http-equiv="Content-Type" content="text/plain; charset=utf-16">
    </cfif>
    
    <cf_report_list>
        <thead>
            <tr>
                <th width="30"><cf_get_lang dictionary_id="58577.Sıra"></th>
                <th>Fırsat No. </th>
                <th>İlişkili Fırsat</th>
                <th>Talep No.</th>
                <th>Talep Durumu</th>
                <th>Talep Tarihi</th>
                <th>Satın Alma Talebi Başlığı</th>
                <th>Talep Tutarı</th>
                <th>Stok Kodu</th>
                <th>Ürün Adı</th>
                <th>Ürün Kategorisi</th>
                <th>Tedarikçi</th>
                <th>Tahmini Teslim</th>
                <th>Menşei</th>
                <th>Fırsat Müşterisi</th>
            </tr>
        </thead>
        <tbody>
            <cfoutput query="GET_DATA">
                <tr>
                    <td>#currentrow#</th>
                    <td>#OPP_NO#</td>
                    <td>#OPP_HEAD#</td>
                    <td><a href="#request.self#?fuseaction=purchase.list_purchasedemand&event=upd&id=#INTERNAL_ID#" class="tableyazi">#INTERNAL_NUMBER#</a></td>
                    <td><cfif GET_DATA.IS_ACTIVE eq 1><a style="color:green">Aktif</a> <cfelse><a style="color:red">Pasif</a></else></cfif></td>
                    <td>#dateformat(TALEP_DATE,dateformat_style)#</td>     
                    <td>#SUBJECT#</td>
                    <td>#TLFormat(NET_TOTAL)# #OTHER_MONEY#</td>
                    <td>#STOK_KODU#</td>
                    <td>#URUN_ADI#</td>
                    <td>#URUN_KATEGORI#</td>
                    <td>
                        <cfif isDefined("GET_DATA.URUN_TEDARIKCI") and len(GET_DATA.URUN_TEDARIKCI)>
                            <cfquery name="GET_TEDARIKCI" datasource="#DSN#">
                                SELECT
                                    FULLNAME AS URUN_TEDARIKCI_ADI
                                FROM
                                    COMPANY
                                WHERE
                                    COMPANY_ID = #GET_DATA.URUN_TEDARIKCI# 
                            </cfquery>
                            <cfloop query="GET_TEDARIKCI">
                                #URUN_TEDARIKCI_ADI#
                            </cfloop>
                        <cfelse>
                        </cfif>
                    </td>
                    <td>#TAHMINI_TESLIM#</td>
                    <td>#MENSEI#</td>
                    <td>#FIRSAT_COMPANY#</td>
                </tr>
            </cfoutput>
        </tbody>
    </cf_report_list>
</cfif>
<script>
    function control()
	{
		if(document.order_detail_report.is_excel.checked==false)
			{
				document.order_detail_report.action="<cfoutput>#request.self#</cfoutput>?fuseaction=report.import_order_analyse"
				return true;
			}
			else{
				document.order_detail_report.action="<cfoutput>#request.self#?fuseaction=report.emptypopup_import_order_analyse</cfoutput>"}
	}
</script>