<!--- Standart Satis Siparis Formu --->

<!---<cfif not isdefined("attributes.action_id")><!--- Toplu Printte gelmesin diye eklendi --->
	<cf_get_lang dictionary_id="865.Seçmiş Olduğunuz Şablon Bu İşlem İçin Uygun Değil">!
	<cfexit method="exittemplate">
</cfif>--->
<cfsetting showdebugoutput="no">
<cfif not isdefined("attributes.action_id")>
	<cfset attributes.order_id = listdeleteduplicates(attributes.iid)>
<cfelse>
	<cfset attributes.order_id = attributes.action_id>
</cfif>
<cfif not isDefined("attributes.data_source")><cfset attributes.data_source = dsn></cfif><!--- Baska sayfalardan include edildiginde sorun olmamasi adina eklendi fbs20130412 --->
<cfquery name="Our_Company" datasource="#attributes.data_source#">
	SELECT 
		ASSET_FILE_NAME3,
		ASSET_FILE_NAME3_SERVER_ID,
		COMPANY_NAME,
		TEL_CODE,
		TEL,TEL2,
		TEL3,
		TEL4,
		FAX,
		TAX_OFFICE,
		TAX_NO,
		ADDRESS,
		WEB,
		EMAIL
	FROM 
	   #dsn_alias#.OUR_COMPANY 
	WHERE 
	<cfif isDefined("SESSION.EP.Company_Id")>
		COMP_ID = #SESSION.EP.Company_Id#
	<cfelseif isDefined("SESSION.PP.COMPANY")>	
		COMP_ID = #SESSION.PP.COMPANY#
	</cfif>
</cfquery>

	<cfquery name="Get_Order" datasource="#attributes.data_source#">
		SELECT 
			I.INVOICE_ID,
			SC.CITY_ID,
			SCO.COUNTY_ID,
        	I.COMPANY_ID,
			I.CONSUMER_ID,
			I.DEPARTMENT_ID,
			I.SHIP_METHOD,
			I.INVOICE_DATE,
			I.INVOICE_NUMBER,
			I.INVOICE_CAT,
			I.NOTE,
			I.INVOICE_ID,
			I.SHIP_ADDRESS,
			O.SALES_PARTNER_ID,
			I.NETTOTAL,
			I.GROSSTOTAL,
			I.TAXTOTAL,
			I.SA_DISCOUNT,
			TEVKIFAT_ORAN,
			I.OTHER_MONEY,
			TEVKIFAT,
			TEVKIFAT_ID,
			SCO.COUNTY_NAME,
            SC.CITY_NAME,			
            CP.COMPANY_PARTNER_NAME,
            CP.COMPANY_PARTNER_SURNAME,
            SHIP_METHOD.SHIP_METHOD AS SHIP_METHOD_,
			OI.ORDER_ID,
			O.ORDER_NUMBER,
			O.ORDER_DETAIL
       	FROM 
			#dsn2_alias#.INVOICE I
			LEFT JOIN #DSN3#.ORDERS_INVOICE OI ON OI.INVOICE_ID = I.INVOICE_ID
			LEFT JOIN #dsn3_alias#.ORDERS O  ON O.ORDER_ID=OI.ORDER_ID
            LEFT JOIN COMPANY C ON C.COMPANY_ID = I.COMPANY_ID
			LEFT JOIN COMPANY_PARTNER CP ON CP.COMPANY_ID = C.COMPANY_ID AND CP.PARTNER_ID = I.PARTNER_ID
            LEFT JOIN SHIP_METHOD ON SHIP_METHOD_ID =  I.SHIP_METHOD
		LEFT JOIN SETUP_CITY SC ON C.CITY=SC.CITY_ID
		LEFT JOIN SETUP_COUNTY SCO ON C.COUNTY=SCO.COUNTY_ID
		WHERE 
	<cfif not isDefined("attributes.ID")>
        I.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
        I.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
	</cfquery>

<cfoutput>#GET_ORDER.ORDER_NUMBER#</cfoutput>

<cfquery name="Get_Order_Row" datasource="#attributes.data_source#">
	SELECT
		ORR.*,
		S.PROPERTY,
		S.STOCK_CODE,
		S.BARCOD,
		S.MANUFACT_CODE,
		S.IS_INVENTORY,
		S.IS_PRODUCTION
	FROM
		#dsn3_alias#.ORDER_ROW ORR,
		#dsn3_alias#.STOCKS S
	WHERE
		ORR.ORDER_ID IN ( #attributes.Order_id# )
        AND
		ORR.STOCK_ID = S.STOCK_ID
	ORDER BY
		ORR.ORDER_ROW_ID
</cfquery>

<cfif isdefined("Get_Order.Company_Id") and Len(Get_Order.Company_Id)>
	<cfquery name="Get_Member_Info" datasource="#attributes.data_source#">
		SELECT
			SC.CITY_ID,
			SCO.COUNTY_ID,
            C.COMPANY_ID MEMBER_ID,
            C.MEMBER_CODE MEMBER_CODE,
            C.FULLNAME MEMBER_NAME,
            C.COMPANY_EMAIL MEMBER_EMAIL,
            C.TAXOFFICE MEMBER_TAXOFFICE,
            C.TAXNO MEMBER_TAXNO,
            C.COMPANY_TELCODE MEMBER_TELCODE,
            C.COMPANY_TEL1 MEMBER_TEL,
            C.COMPANY_FAX MEMBER_FAX,
            C.COMPANY_ADDRESS MEMBER_ADDRESS,
            C.SEMT MEMBER_SEMT,
            SCO.COUNTY_NAME MEMBER_COUNTY,
            SC.CITY_NAME MEMBER_CITY,
            C.COUNTRY MEMBER_COUNTRY
        FROM
            #dsn_alias#.COMPANY C
		LEFT JOIN
			SETUP_CITY SC ON
			C.CITY=SC.CITY_ID
		LEFT JOIN
			SETUP_COUNTY SCO ON
			C.COUNTY=SCO.COUNTY_ID
        WHERE
            COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Company_Id#">
	</cfquery>
<cfelseif isdefined("Get_Order.Consumer_Id") and Len(Get_Order.Consumer_Id)>
	<cfquery name="Get_Member_Info" datasource="#attributes.data_source#">
        SELECT
			SC.CITY_ID,
			SCO.COUNTY_ID,
        	C.CONSUMER_ID MEMBER_ID,
            C.MEMBER_CODE MEMBER_CODE,
            C.CONSUMER_NAME + ' ' + CONSUMER_SURNAME MEMBER_NAME,
            C.CONSUMER_EMAIL MEMBER_EMAIL,
            C.TAX_OFFICE MEMBER_TAXOFFICE,
            C.TAX_NO MEMBER_TAXNO,
			C.TAX_ADRESS,
			C.TAX_CITY_ID,
			C.TAX_COUNTY_ID,
            C.CONSUMER_WORKTELCODE MEMBER_TELCODE,
            C.CONSUMER_WORKTEL MEMBER_TEL,
            C.CONSUMER_FAXCODE + '' + CONSUMER_FAX MEMBER_FAX,
            C.WORKADDRESS MEMBER_ADDRESS,
            C.WORKSEMT MEMBER_SEMT,
            SCO.COUNTY_NAME MEMBER_COUNTY,
            SC.CITY_NAME MEMBER_CITY,
			C.WORK_COUNTRY_ID MEMBER_COUNTRY
        FROM
        	#dsn_alias#.CONSUMER C
		LEFT JOIN
			SETUP_CITY SC ON
			C.TAX_CITY_ID=SC.CITY_ID
		LEFT JOIN
			SETUP_COUNTY SCO ON
			C.TAX_COUNTY_ID=SCO.COUNTY_ID
        WHERE
        	CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Consumer_Id#">
	</cfquery>
</cfif>

<cfquery name="get_order_info_plus" datasource="#DSN3#">
	SELECT 
		*
	FROM 
	  ORDER_INFO_PLUS 
	WHERE
		ORDER_ID IN ( #attributes.Order_id# )
</cfquery>

<cfquery name="Get_Invoice" datasource="#dsn2#">
	SELECT 
    	COMPANY_ID,
        CONSUMER_ID,
        DEPARTMENT_ID,
        SHIP_METHOD,
        INVOICE_DATE,
        INVOICE_NUMBER,
        INVOICE_CAT,
        NOTE,
        INVOICE_ID,
        SHIP_ADDRESS,
        NETTOTAL,
        GROSSTOTAL,
        TAXTOTAL,
        SA_DISCOUNT,
        TEVKIFAT_ORAN,
        OTHER_MONEY,
        TEVKIFAT,
        TEVKIFAT_ID
    FROM 
    	INVOICE 
    WHERE 
	<cfif not isDefined("attributes.ID")>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
</cfquery>

<cfset sepet_total = 0>
<cfset sepet_toplam_indirim = 0>
<cfset sepet_total_tax = 0>
<cfset sepet_net_total = 0>
<cfset Row_Start = 1>
<cfset Row_End = 23>
<!---<cfif Get_Order_Row.RecordCount><cfset Page_Count = Ceiling(Get_Order_Row.RecordCount/Row_End)><cfelse><cfset Page_Count = 1></cfif>--->
<cfset Page_Count = 1>
<style type="text/css">
    .css1 {font-size:14px;font-family:arial,verdana;color:000000;}
    .css2 {font-size:18px;font-family:arial,verdana;color:000000; background-color:white;font-weight:bold; }
    .css3 {font-size:12px;font-family:arial,verdana;color:000000;}
	.css4 {margin-left:5mm; margin-top:10mm;}
			#sol
			{
				float:left;
				width:50%;
			}
			
			#sag
			{
				float:left;
				width:50%;
			}
            #alt
			{   
                float:left;
                width:100%;
			}
</style> 
<cfoutput query="get_order">
	<div class="css4">
		<cfloop from="1" to="#Page_Count#" index="i">	
			<table style="width:100mm;height:20mm;" class="css1" align="left" cellspacing="0">
				<tr class="css2">
					<cfif Get_Order.SALES_PARTNER_ID eq 40>
						<td >
							<img align="left" src="/documents/images/n11.png"  width="180" height="50" />
							<cfif get_order.ship_method eq 1 or get_order.ship_method eq 4>
								<img align="right" src="/documents/images/yurtici.png"  width="180" height="50" />
							<cfelseif get_order.ship_method eq 2 or get_order.ship_method eq 3>
								<img align="right" src="/documents/images/aras.jpg"  width="180" height="50" />
							<cfelseif get_order.ship_method eq 5>
								<img align="right" src="/documents/images/kolay.jpg"  width="180" height="50" />
							<cfelseif get_order.ship_method eq 24>
								<img align="right" src="/documents/images/mng.png"  width="180" height="50" />
							<cfelse>
								<td style="width:60%"> </td>
							</cfif>
						</td>
						<!---
						<cfelseif Get_Order.SALES_PARTNER_ID eq 41>
							<td ><img align="left" src="/documents/images/hepsiburada.png"  width="180" height="50" />
								<cfif get_order.ship_method eq 1 or get_order.ship_method eq 4>
									<img align="right" src="/documents/images/yurtici.png"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 2 or get_order.ship_method eq 3>
									<img align="right" src="/documents/images/aras.jpg"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 5>
									<img align="right" src="/documents/images/kolay.jpg"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 24>
									<img align="right" src="/documents/images/mng.png"  width="180" height="50" />
								<cfelse>
									<td style="width:60%"> </td>
								</cfif>
							</td>
						<cfelseif Get_Order.SALES_PARTNER_ID eq 2009>
							<td ><img align="left" src="/documents/images/trendyol.png"  width="180" height="50" />
								<cfif get_order.ship_method eq 1 or get_order.ship_method eq 4>
									<img align="right" src="/documents/images/yurtici.png"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 2 or get_order.ship_method eq 3>
									<img align="right" src="/documents/images/aras.jpg"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 5>
									<img align="right" src="/documents/images/kolay.jpg"  width="180" height="50" />
								<cfelseif get_order.ship_method eq 24>
									<img align="right" src="/documents/images/mng.png"  width="180" height="50" />
								<cfelse>
									<td style="width:60%"> </td>
								</cfif>
							</td>
						--->
					<cfelse>
						<td><img align="left" src="#user_domain##file_web_path#settings/#our_company.asset_file_name3#" border="0" width="180" height="60">
							<cfif get_order.ship_method eq 1 or get_order.ship_method eq 4>
								<img align="right" src="/documents/images/yurtici.png"  width="180" height="60" />
							<cfelseif get_order.ship_method eq 2 or get_order.ship_method eq 3>
								<img align="right" src="/documents/images/aras.jpg"  width="180" height="60" />
							<cfelseif get_order.ship_method eq 5>
								<img align="right" src="/documents/images/kolay.jpg"  width="180" height="60" />
							<cfelseif get_order.ship_method eq 24>
								<img align="right" src="/documents/images/mng.png"  width="180" height="60" />
							<cfelse>
								<td style="width:60%"> </td>
							</cfif>
						</td>
					</cfif>
				</tr>
			</table>
			<table style="width:100%;" class="css2" align="left" cellspacing="0">
				<tr class="css2" align="left">
					<cfif GET_ORDER.ORDER_NUMBER neq '' and GET_ORDER.ORDER_NUMBER neq ''>
						<td style="width:40%">
							<strong><cf_workcube_barcode value="#GET_ORDER.ORDER_NUMBER#-#GET_ORDER.ORDER_NUMBER#" type="code128" show="1" height="100" width="400"></strong>
						</td>
						<td>
							&nbsp;
						</td>
					<cfelse>
						<!---
					<td style="width:40%"><strong></strong></td>
						--->
					</cfif>
				</tr>
				<tr class="css2" align="center">
					<cfif GET_ORDER.ORDER_NUMBER neq '' and GET_ORDER.ORDER_NUMBER neq ''>
						<td><strong>#GET_ORDER.ORDER_NUMBER#</strong></td>
					<cfelse>
						<td><strong></strong></td>
					</cfif>
				</tr>
			</table>
			
			<div id="sol" style="align:left; width:50mm;">
				<table  style="width:100%;height:70px;" border="0"  class="css1" cellspacing="0" cellpadding="0" align="center" >
					<tr>
						<td style="width:100%" class="txtbold"><strong>Teslimat Bilgileri</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td style="width:100%" class="txtbold">Teslim Alacak Kişi</td>
					</tr>
					<tr>
						<td ><strong>#Get_Member_Info.MEMBER_NAME#</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td class="txtbold">Semt/İlçe/İl</td>
					</tr>
					<tr>
						<td class="txtbold"><strong>#COUNTY_NAME#/#CİTY_NAME#</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td class="txtbold">Teslimat Adresi</td>
					</tr>
					<tr>
						<td class="txtbold"><strong>#Ship_Address#</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td class="txtbold">Sipariş Açıklaması</td>
					</tr>
					<tr>
						<td class="txtbold"><strong>#GET_ORDER.ORDER_DETAIL#</strong></td>
					</tr>
				</table>
			</div>
			
			<div id="sag">
				<table  style="width:100%;height:70px;" border="0"  class="css1" cellspacing="0" cellpadding="0" align="left" >
					<tr>
						<td style="width:100%" class="txtbold"><strong>Fatura Bilgileri</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td style="width:100%" class="txtbold">Müşteri Adı</td>
					</tr>
					<tr>
						<td ><strong>#Get_Member_Info.MEMBER_NAME#</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td class="txtbold">Semt/İlçe/İl</td>
					</tr>
					<tr>
						<td class="txtbold"><strong>#Get_Member_Info.MEMBER_SEMT#/#Get_Member_Info.MEMBER_COUNTY#/#Get_Member_Info.MEMBER_CITY#</strong></td>
					</tr>
					<tr style="height:10mm;">
						<td class="txtbold">Fatura Adresi</td>
					</tr>
					<tr>
						<cfif isdefined("employee_browser_types") and len(employee_browser_types)>
							<td class="txtbold"><strong>#get_member_info.tax_adress#</strong></td>
						<cfelse>
							<td class="txtbold"><strong>Fatura adresi bulunamadı.</strong></td>
						</cfif>
					</tr>
					<cfif get_order.ship_method eq 1>
						<tr style="height:10mm;">
							<td class="txtbold"><strong><p style="color:red; font-size:15px">Tahsil Edilecek Ürün Bedeli : <u>#wrk_round(get_net_total.NETTOTAL)# #Get_Order.OTHER_MONEY#</u></p></strong></td>
						</tr>
						<tr style="height:5mm;">
							<td class="txtbold"><strong><p style="color:red; font-size:15px">Tahsilat Tipi : Nakit</p></strong></td>
						</tr>
						<!---
						<tr>
							<td class="txtbold"><strong><p style="color:red;">#get_pay_method.PAYMETHOD# #Get_Order.OTHER_MONEY#</p></strong></td>
						</tr>
						--->
					</cfif>
				</table>
			</div>
			
			<div id="alt" style="align:center">
				<table  style="width:100mm;" border="0"  class="css1" cellspacing="0" cellpadding="0" align="left" >
					<tr><td colspan="2" style="height:3mm;">&nbsp;</td></tr>
						<tr class="css2" style="width:100%" >
							<td style="width:100%"><strong>SATICI BİLGİLERİ</strong></td>
						</tr>
					<tr>
						<td class="txtbold"><strong>Satıcı Adı</strong></td>
					</tr>
					<tr>
						<td class="txtbold"><strong><cfoutput>#OUR_COMPANY.COMPANY_NAME#</cfoutput></strong></td>
					</tr>
				</table>
				<table  style="width:100mm;" border="0"  class="css1" cellspacing="0" cellpadding="0" align="left" >
					
				</table>
			</div>
					<cfset Row_Start = Row_End + Row_Start>
				</cfloop>
	</div>
</cfoutput>	