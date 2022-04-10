<!---
	Desc : Birikim Satınalma Siparişi (Yurtiçi) formudur.
	Date : 04.01.2022
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfif isdefined("attributes.action_id")>
    <cfset attributes.order_id = attributes.action_id>
<cfelse>
    <cfif isdefined("attributes.id")>
        <cfset attributes.order_id = attributes.id>
    <cfelse>
        <cfset attributes.order_id = listdeleteduplicates(attributes.iid)>
    </cfif>
</cfif>
<cfquery name="Our_Company" datasource="#dsn#">
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
	    OUR_COMPANY 
	WHERE 
	<cfif isDefined("SESSION.EP.COMPANY_ID")>
		COMP_ID = #SESSION.EP.COMPANY_ID#
	<cfelseif isDefined("SESSION.PP.COMPANY")>	
		COMP_ID = #SESSION.PP.COMPANY#
	</cfif>
</cfquery>
<cfquery name="CHECK" datasource="#DSN#">
	SELECT 
		ASSET_FILE_NAME2,
		ASSET_FILE_NAME2_SERVER_ID,
	    COMPANY_NAME
	FROM 
		OUR_COMPANY 
	WHERE 
		<cfif isdefined("attributes.our_company_id")>
			COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.our_company_id#">
		<cfelse>
			<cfif isDefined("session.ep.company_id") and len(session.ep.company_id)>
				COMP_ID = #session.ep.company_id#
			<cfelseif isDefined("session.pp.company_id") and len(session.pp.company_id)>	
				COMP_ID = #session.pp.company_id#
			<cfelseif isDefined("session.ww.our_company_id")>
				COMP_ID = #session.ww.our_company_id#
			<cfelseif isDefined("session.cp.our_company_id")>
				COMP_ID = #session.cp.our_company_id#
			</cfif> 
		</cfif> 
</cfquery>
<cfif isDefined('attributes.ORDER_ID')>
	<cfquery name="Get_Order" datasource="#DSN#">
		SELECT
			E.EMPLOYEE_NAME,
			E.EMPLOYEE_SURNAME,
			E.EMPLOYEE_EMAIL,			
			O.*
		FROM 
			#dsn3_alias#.ORDERS O , 
			EMPLOYEES E
		WHERE 
			O.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#"> AND
			E.EMPLOYEE_ID = O.RECORD_EMP
	</cfquery>
</cfif>
<cfquery name="Get_Order_Rows" datasource="#dsn3#">
	SELECT
		ORR.*,
		S.BARCOD,
		S.MANUFACT_CODE,
		S.STOCK_CODE,
		S.STOCK_CODE_2
	FROM
		ORDER_ROW ORR,
		STOCKS S
	WHERE
		ORR.ORDER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_id#"> AND
		ORR.STOCK_ID = S.STOCK_ID
	ORDER BY
		ORR.ORDER_ROW_ID
</cfquery>
<cfif len(Get_Order.Deliver_Dept_id)>
    <cfquery name="Get_Store" datasource="#dsn#">
    	SELECT DEPARTMENT_HEAD,BRANCH_ID FROM DEPARTMENT WHERE DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Deliver_Dept_id#">
    </cfquery>
	
	<cfquery name="GET_LOCATION" datasource="#DSN#">
		SELECT BRANCH_NAME, ADMIN1_POSITION_CODE, BRANCH_ADDRESS, BRANCH_TELCODE, BRANCH_TEL1, BRANCH_FAX FROM BRANCH WHERE BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_STORE.BRANCH_ID#">
	</cfquery>

	<cfquery name="GET_LOC_ADMIN" datasource="#DSN#">
		SELECT EMPLOYEE_NAME, EMPLOYEE_SURNAME FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_LOCATION.ADMIN1_POSITION_CODE#">
	</cfquery>
</cfif>
<cfif len(Get_Order.Paymethod)>
	<cfset attributes.paymethod_id = Get_Order.Paymethod>
    <cfquery name="Get_Paymethod" datasource="#dsn#">
    	SELECT * FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.Paymethod_id#">
    </cfquery>
</cfif>
<!--- Uye bilgileri --->
<cfset Member_Code = "">
<cfset Member_Name = "">
<cfset Member_Mail = "">
<cfset Member_TaxOffice = "">
<cfset Member_TaxNo = "">
<cfset Member_TelCode = "">
<cfset Member_Tel = "">
<cfset Member_Fax = "">
<cfset Member_Address = "">
<cfset Member_Semt = "">
<cfset Member_County = "">
<cfset Member_City = "">
<cfset Member_Country = "">
<cfif isdefined("Get_Order.Company_Id") and Len(Get_Order.Company_Id)>
	<cfquery name="Get_Member_Info" datasource="#dsn#">
		SELECT
            COMPANY_ID MEMBER_ID,
            MEMBER_CODE MEMBER_CODE,
            FULLNAME MEMBER_NAME,
            COMPANY_EMAIL MEMBER_EMAIL,
            TAXOFFICE MEMBER_TAXOFFICE,
            TAXNO MEMBER_TAXNO,
            COMPANY_TELCODE MEMBER_TELCODE,
            COMPANY_TEL1 MEMBER_TEL,
            COMPANY_FAX MEMBER_FAX,
            COMPANY_ADDRESS MEMBER_ADDRESS,
            SEMT MEMBER_SEMT,
            COUNTY MEMBER_COUNTY,
            CITY MEMBER_CITY,
            COUNTRY MEMBER_COUNTRY
        FROM
            COMPANY
        WHERE
            COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Company_Id#">
	</cfquery>
<cfelseif isdefined("Get_Order.Consumer_Id") and Len(Get_Order.Consumer_Id)>
	<cfquery name="Get_Member_Info" datasource="#dsn#">
        SELECT
        	CONSUMER_ID MEMBER_ID,
            MEMBER_CODE MEMBER_CODE,
            CONSUMER_NAME + ' ' + CONSUMER_SURNAME MEMBER_NAME,
            CONSUMER_EMAIL MEMBER_EMAIL,
            TAX_OFFICE MEMBER_TAXOFFICE,
            TAX_NO MEMBER_TAXNO,
            CONSUMER_WORKTELCODE MEMBER_TELCODE,
            CONSUMER_WORKTEL MEMBER_TEL,
            CONSUMER_FAXCODE + '' + CONSUMER_FAX MEMBER_FAX,
            WORKADDRESS MEMBER_ADDRESS,
            WORKSEMT MEMBER_SEMT,
            WORK_COUNTY_ID MEMBER_COUNTY,
            WORK_CITY_ID MEMBER_CITY,
            WORK_COUNTRY_ID MEMBER_COUNTRY
        FROM
        	CONSUMER
        WHERE
        	CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Consumer_Id#">
	</cfquery>
</cfif>
<cfif isdefined("Get_Member_Info") and Get_Member_Info.RecordCount>
	<cfset Member_Code = Get_Member_Info.Member_Code>
    <cfset Member_Name = Get_Member_Info.Member_Name>
    <cfset Member_Mail = Get_Member_Info.Member_Email>
    <cfset Member_TaxOffice = Get_Member_Info.Member_TaxOffice>
    <cfset Member_TaxNo = Get_Member_Info.Member_TaxNo>
    <cfset Member_TelCode = Get_Member_Info.Member_TelCode>
    <cfset Member_Tel = Get_Member_Info.Member_Tel>
    <cfset Member_Fax = Get_Member_Info.Member_Fax>
    <cfset Member_Address = Get_Member_Info.Member_Address>
    <cfset Member_Semt = Get_Member_Info.Member_Semt>
    
	<cfif Len(Get_Member_Info.Member_County)>
		<cfquery name="Get_County_Name" datasource="#dsn#">
			SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_County#">
		</cfquery>
		<cfset Member_County = Get_County_Name.County_Name>
	</cfif>
	<cfif Len(Get_Member_Info.Member_City)>
		<cfquery name="Get_City_Name" datasource="#dsn#">
			SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_City#">
		</cfquery>
		<cfset Member_City = Get_City_Name.City_Name>
	</cfif>
	<cfif Len(Get_Member_Info.Member_Country)>
		<cfquery name="Get_Country_Name" datasource="#dsn#">
			SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_Country#">
		</cfquery>
		<cfset Member_Country = Get_Country_Name.Country_Name>
	</cfif>
</cfif>
<cfif Len(Get_Order.Partner_id)>
    <cfquery name="Get_Partner" datasource="#dsn#">
        SELECT COMPANY_PARTNER_NAME + ' ' + COMPANY_PARTNER_SURNAME PARTNER_NAME FROM COMPANY_PARTNER WHERE PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Partner_id#">
    </cfquery>
	<cfset Partner_Name = Get_Partner.Partner_Name>
<cfelse>
	<cfset Partner_Name = ''>
</cfif>
<cfif Len(Get_Order.Ship_Method)>
    <cfquery name="Get_Ship_Method" datasource="#dsn#">
        SELECT
            SHIP_METHOD_ID,
            SHIP_METHOD
        FROM
            SHIP_METHOD
        WHERE 
            SHIP_METHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Order.Ship_Method#">
    </cfquery>
</cfif>

<cfif len(get_order.other_money)>
	<cfquery name="GET_MONEY" datasource="#DSN3#">
		SELECT 
			MONEY_TYPE,
			RATE1,
			RATE2
		FROM
			ORDER_MONEY
		WHERE
			ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_ORDER.ORDER_ID#">
			AND MONEY_TYPE = '#GET_ORDER.OTHER_MONEY#'
	</cfquery>
</cfif>

<cfquery name="Get_Upper_Position" datasource="#dsn#">
	SELECT * FROM EMPLOYEE_POSITIONS WHERE EMPLOYEE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">
</cfquery>
<cfif len (Get_Upper_Position.Upper_Position_Code)>
    <cfquery name="Get_Chief1_Name" datasource="#dsn#">
        SELECT EMPLOYEE_NAME,EMPLOYEE_SURNAME FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Upper_Position.Upper_Position_Code#">
    </cfquery>
</cfif>
<cfset Row_Start = 1>
<cfset Row_End = 28>
<cfset yazilan_satir=1>
<cfif Get_Order_Rows.RecordCount>
	<cfset Page_Count = Ceiling((Get_Order_Rows.RecordCount)/Row_End)>
<cfelse>
	<cfset Page_Count = 1>
</cfif>
<cfscript>
	sepet_total = 0;
	sepet_toplam_indirim = 0;
	sepet_total_tax = 0;
	sepet_net_total = 0;
</cfscript>

<link rel="stylesheet" href="/css/assets/template/catalyst/print.css" type="text/css">

<cfdocument format="PDF">
		<table style="width:220mm">
			<tr>
				<td align="left">
					<cfif len(check.asset_file_name2)>
                        <cfset attributes.type = 1>
                        <cf_get_server_file output_file="/settings/#check.asset_file_name2#" output_server="#check.asset_file_name2_server_id#" output_type="5">
                    </cfif>
				</td>
				<td align="right">
					<cf_workcube_barcode show="1" type="qrcode" height="100" value="#get_order.order_number#">
				</td>
			</tr>
		</table>
		<table align="center" style="width:220mm">
			<tbody>
				<tr>
					<td align="left"><cfoutput>#check.COMPANY_NAME#</cfoutput></td>
					<td rowspan="5"></td>
					<td align="right">Tarih :</td>
					<td align="right"><cfoutput>#dateformat(Get_Order.Order_Date,dateformat_style)#</cfoutput></td>
				</tr>
				<tr>
					<td align="left"><cfoutput>#OUR_COMPANY.ADDRESS#</cfoutput></td>
					<td align="right">Sipariş No :</td>
					<td align="right"><cfoutput>#GET_ORDER.ORDER_NUMBER#</cfoutput></td>
				</tr>
				<tr>
					<td align="left"><cfoutput>#Our_Company.TAX_OFFICE#</cfoutput> VD. <cfoutput>#OUR_COMPANY.TAX_NO#</cfoutput></td>
					<td align="right">Bilgi Kodu :</td>
					<td align="right"><cfoutput>#GET_ORDER.ORDER_ID#</cfoutput></td>
				</tr>
				<tr>
					<td>TEL: 0<cfoutput>#OUR_COMPANY.TEL_CODE#</cfoutput> <cfoutput>#OUR_COMPANY.TEL#</cfoutput></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td>FAX: 0<cfoutput>#OUR_COMPANY.TEL_CODE#</cfoutput> <cfoutput>#OUR_COMPANY.FAX#</cfoutput></td>
					<td></td>
					<td></td>
				</tr>
			</tbody>
		</table>
		<h2 align="center">SİPARİŞ FORMU</h2>
		<table style="width:220mm; border: 1px solid black">
			<tbody>
				<tr>
					<td style="width:15%">Firma Adı</td>
					<td style="width:50%">: <cfoutput>#Member_Name#</cfoutput></td>
					<td style="width:35%" rowspan="5">
						<table>
							<tbody>
							<tr>Toplam <cfoutput>#GET_ORDER_ROWS.recordcount#</cfoutput> kalem ürün vardır.<br></tr>
							<tr>E-Fatura TİCARİ senaryo ile kabul edilir.<br></tr>
							<tr>Bu formu ürünler ile birlikte gönderiniz.<br></tr>
							<cfif GET_MONEY.MONEY_TYPE neq 'TL'>
								<b>DÖVİZ KURU</b>
								<cfoutput query="GET_MONEY"><tr><br>1 #MONEY_TYPE# = #RATE2# TL </tr></cfoutput>
							</cfif>
							</tbody>
						</table>
					</td>
				</tr>
				<tr>
					<td>Konu</td>
					<td>: <cfoutput>#GET_ORDER.ORDER_HEAD#</cfoutput></td>
				</tr>
				<tr>
					<td>Tel</td>
					<td>: <cfif len(Member_Tel)><cfoutput><cfif len(Member_TelCode)>(#Member_TelCode#)</cfif> #Member_Tel#</cfoutput></cfif></td>
				</tr>
				<tr>
					<td>Fax</td>
					<td>: <cfif len(Member_Fax)><cfoutput><cfif len(Member_TelCode)>(#Member_Fax#)</cfif> #Member_Fax#</cfoutput></cfif></td>
				</tr>
				<tr>
					<td>Email</td>
					<td>: <cfoutput>#Member_Mail#</cfoutput></td>
				</tr>
			</tbody>
		</table>
		<table style="width:220mm; border:1px solid black">
			<thead>
				<tr>
					<td align="center"><b>Ürün Cinsi</b></td>
					<td><b>Miktar</b></td>
					<td><b>Birim</b></td>
					<td><b>Birim Fiyat</b></td>
					<td><b>Toplam Fiyat</b></td>
				</tr>
				<tr style="width:100%">
					<td colspan="5" style="width:100%"><hr></td>
				</tr>
			</thead>
			<tbody>
				<cfoutput query="Get_Order_Rows">
					<!---
					<cfif not IsDefined('ilk_urun_id')><cfset ilk_urun_id=Get_Order_Rows.PRODUCT_ID></cfif>
					--->
					<cfscript>
						if (not len(QUANTITY)) QUANTITY = 1;
						if (not len(PRICE)) 
							price = 0;
						tax_percent = TAX;
						if (not len(discount_1)) indirim1 = 0; else indirim1 = discount_1;
						if (not len(discount_2)) indirim2 = 0; else indirim2 = discount_2;
						if (not len(discount_3)) indirim3 = 0; else indirim3 = discount_3;
						if (not len(discount_4)) indirim4 = 0; else indirim4 = discount_4;
						if (not len(discount_5)) indirim5 = 0; else indirim5 = discount_5;
						indirim6 = 0;
						indirim7 = 0;
						indirim8 = 0;
						indirim9 = 0;
						indirim10 = 0;
						indirim_carpan = (100-indirim1) * (100-indirim2) * (100-indirim3) * (100-indirim4) * (100-indirim5);
						other_money_value = price_other;	
						other_money_price = OTHER_MONEY_VALUE;
						net_maliyet = COST_PRICE;
						marj = MARJ;
						if(len(price_other))
						other_money_rowtotal = price_other;
						else
							other_money_rowtotal = price;
						row_total = QUANTITY * price;
						row_nettotal = wrk_round((row_total/10000000000) * indirim_carpan);
						row_taxtotal = wrk_round(row_nettotal * (tax_percent/100));
						row_lasttotal = row_nettotal + row_taxtotal;
						sepet_total = sepet_total + row_total; //subtotal_
						sepet_toplam_indirim = sepet_toplam_indirim + wrk_round(row_total) - wrk_round(row_nettotal); //discount_
						sepet_total_tax = sepet_total_tax + row_taxtotal; //totaltax_
						sepet_net_total = sepet_net_total + row_lasttotal; //nettotal_
					</cfscript>
					<tr style="height:15mm">
						<td style="text-align:left">
							<table style="border: 1px black">
								<tbody>
									<tr>
										<td rowspan="3">#currentRow#.</td>
										<!--- Ürüne ait tek görsel varsa şablonda gelir, birden fazla varsa Kapak Görseli işaretlenmiş olan gelir, birden fazla görsel var ve Kapak Görseli seçilmemişse görsel gelmez. --->
										<td rowspan="3">
											<cfquery name="GET_PRODUCT_IMAGES" datasource="#DSN1#">
												SELECT
													PATH
												FROM
													PRODUCT_IMAGES
												WHERE
													PRODUCT_ID = #Get_Order_Rows.PRODUCT_ID#
											</cfquery>
											<cfif GET_PRODUCT_IMAGES.recordCount gt 1>
												<cfquery name="GET_PRODUCT_IMAGES_MANY" datasource="#DSN1#">
													SELECT
													  PATH,
													  IS_COVER
													FROM
													  PRODUCT_IMAGES
													WHERE
													  PRODUCT_ID = #Get_Order_Rows.PRODUCT_ID#
												  </cfquery>
												  <cfloop query="GET_PRODUCT_IMAGES_MANY">
													<cfif IS_COVER eq 1>
													  <cf_get_server_file output_file="../../documents/product/#GET_PRODUCT_IMAGES_MANY.PATH#" image_height="80" output_server="1" output_type="5">
													</cfif>
												  </cfloop>
												<cfelseif GET_PRODUCT_IMAGES.recordCount eq 1>
												<cf_get_server_file output_file="../../documents/product/#GET_PRODUCT_IMAGES.PATH#" image_height="80" output_server="1" output_type="5">
												<cfelseif GET_PRODUCT_IMAGES.recordCount eq 0>
											</cfif>
										</td>
										<td>
											<cfquery name="PRODUCT_INFO" datasource="#DSN3#">
												SELECT
													BARCOD,
													MANUFACT_CODE
												FROM
													PRODUCT
												WHERE
													PRODUCT_ID = #Get_Order_Rows.PRODUCT_ID#
											</cfquery>
											<p>#STOCK_CODE_2#</p>
											<p>#left(Product_Name,42)#</p>
											<cfloop query="PRODUCT_INFO">
												<p>#BARCOD# - #MANUFACT_CODE#</p>
											</cfloop>
										</td>
									</tr>
									<tr>
										<td></td>
									</tr>
									<tr>
										<td></td>
									</tr>
								</tbody>
							</table>
						</td>
						<td style="text-align:center" >#Quantity#</td>
						<td style="text-align:center">#Unit#</td>
						<td style="text-align:center"><a><cfif Quantity neq 0>#TLFormat((price/get_money.rate2),3)# #OTHER_MONEY#<cfelse>#TLFormat(row_nettotal)# #OTHER_MONEY#</cfif></a></td>
						<td style="text-align:center"><a>#TLFormat(((price*quantity)/get_money.rate2),3)# #OTHER_MONEY#</a></td>
					</tr>
					<tr style="width:100%">
						<td colspan="5" style="width:100%"><hr></td>
					</tr>
				</cfoutput>
			</tbody>
		</table>
		<br>
		<table style="width:220mm; height:50mm; border: 1px solid black">
			<tbody>
				<tr>
					<tr>
						<td style="width:50" colspan="4"><b><i>Sevk Bilgileri</i></b></td>
					</tr>
					<tr>
						<td>Depo İsmi</td>
						<td style="width:50">: <cfoutput>#GET_STORE.DEPARTMENT_HEAD#</cfoutput>-<cfoutput>#GET_LOCATION.BRANCH_NAME#</cfoutput></td>
						<td style="width:50">Sevkiyat Tipi</td>
						<td style="width:50">: <cfoutput><cfif len(Get_Order.ship_method)>#Get_Ship_Method.Ship_Method#</cfif></cfoutput></td>
					</tr>
					<tr>
						<td>Yetkili Kişi</td>
						<td>: <cfoutput>#GET_LOC_ADMIN.EMPLOYEE_NAME# #GET_LOC_ADMIN.EMPLOYEE_SURNAME#</cfoutput></td>
						<td>Sevkiyat Tarihi</td>
						<td>: </td>
					</tr>
					<tr>
						<td>Telefon</td>
						<td>: <cfoutput>#GET_LOCATION.BRANCH_TELCODE# #GET_LOCATION.BRANCH_TEL1#</cfoutput></td>
						<td>Teslim Tarihi</td>
						<td>: <cfoutput><cfif len(Get_Order.Deliverdate)>#dateformat(Get_Order.Deliverdate,dateformat_style)#</cfif></cfoutput></td>
					</tr>
					<tr>
						<td>Fax</td>
						<td>: <cfoutput>#GET_LOCATION.BRANCH_FAX#</cfoutput></td>
						<td></td>
						<td>&nbsp;</td>
					</tr>
					<tr>
						<td><a style="color:red">Sevk Adresi</a></td>
						<td colspan="3"><a style="color:red">: <cfoutput>#GET_LOCATION.BRANCH_ADDRESS#</cfoutput></a></td>
					</tr>
				</tr>
				<tr>
					<td>Detaylar</td>
					<td colspan="3">: <cfif len(Get_Order.Order_Detail)><cfoutput>#Get_Order.Order_Detail#</cfoutput></cfif></td>
				</tr>
			</tbody>
		</table>
		<div align="right" style="position:fixed:; float:right; width:50%">
			<cfoutput>
				<br>
				<table style="border: 1px solid black">
					<tr align="center">
						<td align="center"><b>TOPLAM</b></td>
					</tr>
					<tr>
						<td>Alt Toplam</td>
						<td>: #TLFormat((sepet_total/get_money.rate2),3)# <cfoutput>#GET_MONEY.MONEY_TYPE#</cfoutput><cfoutput></cfoutput></td>
					</tr>
					<tr>
						<td>KDV</td>
						<td>: #TLFormat((sepet_total_tax/get_money.rate2),3)# #GET_ORDER.OTHER_MONEY#</td>
					</tr>
					<tr>
						<td>Genel Toplam</td>
						<td>: #TLFormat((sepet_net_total/get_money.rate2),3)# #GET_ORDER.OTHER_MONEY#</td>
					</tr>
				</table>
			</cfoutput>
		</div>
		<br>
		<div align="left" style="position:fixed:; float:left; width:50%">
			<table style="border: 1px solid black">
				<tr><td><b style="font-size:13px">Tarih</b></td><td>: <cfoutput><b style="font-size:13px">#dateformat(Get_Order.Order_Date,dateformat_style)#</b></cfoutput></td></tr>
				<tr><td><b style="font-size:13px">TCMB Günlük Kur</b></td><td>: <b style="font-size:13px"><cfoutput>#GET_MONEY.RATE1# #GET_MONEY.MONEY_TYPE# = #TLFormat(GET_MONEY.RATE2)# TRY</cfoutput></b></td></tr>
				<tr><td><b style="font-size:13px">Toplam</b></td><td>: <b style="font-size:13px"><cfoutput>#TLFormat(((sepet_net_total)),3)# TL</cfoutput></b></td></tr>
			</table>
		</div>
		<!---
		<cfdocumentitem type = "footer">
			<table style="width:210mm; height:50mm; border: 1px solid black">
				<tbody>
					<tr>
						<tr>
							<td style="width:50" colspan="4"><b><i>Sevk Bilgileri</i></b></td>
						</tr>
						<tr>
							<td>Depo İsmi</td>
							<td style="width:50"><cfoutput>#GET_STORE.DEPARTMENT_HEAD#</cfoutput>-<cfoutput>#GET_LOCATION.BRANCH_NAME#</cfoutput></td>
							<td style="width:50">Sevkiyat Tipi</td>
							<td style="width:50"><cfoutput><cfif len(Get_Order.ship_method)>#Get_Ship_Method.Ship_Method#</cfif></cfoutput></td>
						</tr>
						<tr>
							<td>Yetkili Kişi</td>
							<td><cfoutput>#GET_LOC_ADMIN.EMPLOYEE_NAME# #GET_LOC_ADMIN.EMPLOYEE_SURNAME#</cfoutput></td>
							<td>Sevkiyat Tarihi</td>
							<td></td>
						</tr>
						<tr>
							<td>Telefon</td>
							<td><cfoutput>#GET_LOCATION.BRANCH_TELCODE# #GET_LOCATION.BRANCH_TEL1#</cfoutput></td>
							<td>Teslim Tarihi</td>
							<td><cfoutput><cfif len(Get_Order.Deliverdate)>#dateformat(Get_Order.Deliverdate,dateformat_style)#</cfif></cfoutput></td>
						</tr>
						<tr>
							<td>Fax</td>
							<td><cfoutput>#GET_LOCATION.BRANCH_TELCODE# #GET_LOCATION.BRANCH_FAX#</cfoutput></td>
							<td></td>
							<td>....</td>
						</tr>
						<tr>
							<td>Depo Adresi</td>
							<td colspan="3"><cfoutput>#GET_LOCATION.BRANCH_ADDRESS#</cfoutput></td>
						</tr>
					</tr>
					<tr>
						<td>Detaylar</td>
						<td colspan="3"><cfif len(Get_Order.Order_Detail)><cfoutput>#Get_Order.Order_Detail#</cfoutput></cfif></td>
					</tr>
				</tbody>
			</table>
		</cfdocumentitem>
		--->
</cfdocument>