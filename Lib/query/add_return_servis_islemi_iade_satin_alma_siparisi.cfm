<!--- 25.10.2021 Yunus Emre Yazici - Birikim Piileri Desc : Merkeze İade gelistirimleri yapildi. Is No : IS102582 --->

<cfif isDefined("attributes.center_return") and len(attributes.center_return) and attributes.center_return eq 1 or session.ep.isBranchAuthorization eq 0>

	<cfset wrk_id = dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*100)>

	<cfif isDefined("attributes.service_company_id") and len(attributes.service_company_id)>
		<cfquery name="GET_COMPANY" datasource="#DSN#">
			SELECT CITY, COUNTY, COMPANY_ADDRESS FROM COMPANY WHERE COMPANY_ID = #attributes.service_company_id#
		</cfquery>
		<cfset service_city = GET_COMPANY.CITY>
		<cfset service_county = GET_COMPANY.COUNTY>
		<cfset service_company_address = GET_COMPANY.COMPANY_ADDRESS>
	<cfelseif isDefined("attributes.service_consumer_id") and len(attributes.service_consumer_id)>
		<cfquery name="GET_CONSUMER" datasource="#DSN#">
			SELECT HOME_CITY_ID, HOME_COUNTY_ID, HOMEADDRESS FROM CONSUMER
		</cfquery>
		<cfset service_city = GET_CONSUMER.HOME_CITY_ID>
		<cfset service_county = GET_CONSUMER.HOME_COUNTY_ID>
		<cfset service_company_address = GET_CONSUMER.HOMEADDRESS>
	<cfelseif isDefined("attributes.service_partner_id") and len(attributes.service_partner_id)>
		<cfquery name="GET_PARTNER" datasource="#dsn#">
			SELECT CITY, COUNTY, COMPANY_PARTNER_ADDRESS FROM COMPANY_PARTNER WHERE PARTNER_ID = #attributes.service_partner_id#
		</cfquery>
		<cfset service_city = GET_PARTNER.CITY>
		<cfset service_county = GET_PARTNER.COUNTY>
		<cfset service_company_address = GET_PARTNER.COMPANY_PARTNER_ADDRESS>
	</cfif>

	<cfif not (isdefined("attributes.order_number") and len(attributes.order_number))>
			<cfquery name="get_order_code" datasource="#DSN3#">
				SELECT ORDER_NO, ORDER_NUMBER FROM GENERAL_PAPERS WHERE PAPER_TYPE = 1 AND ZONE_TYPE = 0
			</cfquery>
			<cfset paper_code = evaluate('get_order_code.ORDER_NO')>
			<cfset paper_number = evaluate('get_order_code.ORDER_NUMBER') +1>
			<cfset paper_full = '#paper_code#-#paper_number#'>
			<cfquery name="UPD_OFFER_CODE" datasource="#DSN3#">
				UPDATE 
					GENERAL_PAPERS 
				SET 
					ORDER_NUMBER = ORDER_NUMBER+1
				WHERE 
					PAPER_TYPE = 1 
					AND ZONE_TYPE = 0
			</cfquery>
		<cfelse>
			<cfset paper_full = attributes.order_number>
	</cfif>

	<cfif isDefined("attributes.invoice_id") and len(attributes.invoice_id)>
		<cfquery name="GET_INVOICE_NUMBER" datasource="#DSN2#">
			SELECT INVOICE_NUMBER FROM INVOICE WHERE INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.invoice_id#">
		</cfquery>
	</cfif>

	<cfquery name="INSERT_ORDER" datasource="#DSN3#">
		INSERT INTO
			ORDERS
			(
				WRK_ID,
				ORDER_HEAD,
				ORDER_NUMBER,
				ORDER_STATUS,
				ORDER_STAGE,
				ORDER_DETAIL,
				ORDER_DATE,
				ORDER_CURRENCY,
				<!---ORDER_ROW_CURRENCY,Bu alan ordersta yok kaldırdım. Evren Abda 07022022--->
				<!---RESERVE_TYPE,Bu alan ordersta yok kaldırdım. Evren Abda 07022022--->
				COMMETHOD_ID,
				ORDER_ZONE,
				PURCHASE_SALES,
				COMPANY_ID,
				PARTNER_ID,
				CONSUMER_ID,
				EMPLOYEE_ID,
				ORDER_EMPLOYEE_ID,
				PRIORITY_ID,
				IS_WORK,
				INCLUDED_KDV,
				INVISIBLE,
				SHIP_METHOD,
				RESERVED,
				STARTDATE,
				DELIVERDATE,
				/*
				SHIP_ADDRESS,
				*/
				CITY_ID,
				COUNTY_ID,
				IS_PAID,
				IS_ENDUSER_PRICE,
				IS_DISPATCH,
				RECORD_DATE,
				RECORD_EMP,
				RECORD_IP,
				DELIVER_DEPT_ID,
				LOCATION_ID
				/*
				DISCOUNTTOTAL,
				TAX,
				NETTOTAL,
				OTV_TOTAL,
				TAXTOTAL,
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				PAYMETHOD,
				PAYFORMUL,
				PUBLISHDATE,
				*/
			)
			VALUES
			(
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">,
				'SATIN ALMA SİPARİŞİ (İADE)',
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_full#">,
				1, /* aktif / pasif */ 
				173, /* order_stage (kayıt aşaması) */
				<cfif isDefined("attributes.invoice_id") and len(attributes.invoice_id)>
					'#GET_INVOICE_NUMBER.INVOICE_NUMBER#',
				<cfelse>
					NULL,
				</cfif>
				#now()#,
				NULL,
				<!--- -6,--->
				<!--- -1, --->
				NULL,
				0, /* order_zone */
				0,
				<cfif len(attributes.service_company_id)>#attributes.service_company_id#<cfelse>NULL</cfif>, /* COMPANY_ID */ 
				<cfif len(attributes.service_partner_id)>#attributes.service_partner_id#<cfelse>NULL</cfif>, /* partner_id */
				<cfif len(attributes.service_consumer_id)>#attributes.service_consumer_id#<cfelse>NULL</cfif>, /*consumer_id */
				<cfif len(attributes.service_employee_id)>#attributes.service_employee_id#<cfelse>NULL</cfif>, /* employee_id */ 
				#session.ep.userid#,
				0,
				0,
				0,
				0,
				NULL, /* ship_method */
				0,
				#now()#,
				#now()#, /* deliverdate */
				/*
				<cfif len(service_company_address)>#service_company_address#<cfelse>NULL</cfif>,
				*/
				<cfif len(service_city)>#service_city#<cfelse>NULL</cfif>,
				<cfif len(service_county)>#service_county#<cfelse>NULL</cfif>,
				0,
				0,
				0,
				#now()#,
				#session.ep.userid#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
				62, /*idari kontrol depo için departman id */
				1 /* merkez için lokasyon id */ 
			)
	</cfquery>

	<cfloop list="#attributes.invoice_row_list#" index="i">
		<cfif isdefined("attributes.is_check#i#")>
			<cfquery name="KONTROL_" datasource="#DSN3#">
				SELECT 
					SUM(AMOUNT) TOTAL_AMOUNT
				FROM 
					SERVICE_PROD_RETURN_ROWS SPRR,
					SERVICE_PROD_RETURN SPR 
				WHERE 
					SPRR.RETURN_ID = SPR.RETURN_ID AND 
					SPRR.INVOICE_ROW_ID = #evaluate('attributes.invoice_row_id#i#')# AND
					SPR.PERIOD_ID = #attributes.period_id# AND
					SPRR.STOCK_ID = #evaluate('attributes.stock_id#i#')#
				<!---BK--->
				<cfif is_return_control eq 1>
					AND SPRR.RETURN_ACT_TYPE = 1
				</cfif>				
			</cfquery>
			
			<!---
			<cfif len(attributes.service_company_id)>
				<cfquery name="Company" datasource="#DSN#">
					select NICKNAME from COMPANY WHERE COMPANY_ID=#attributes.service_company_id#
				</cfquery>
				<cfset comp_name=Company.NICKNAME>
			</cfif>
			<cfif len(attributes.service_consumer_id)>
				<cfquery name="Consumer" datasource="#DSN#">
					select CONSUMER_NAME,CONSUMER_SURNAME from CONSUMER WHERE CONSUMER_ID=#attributes.service_consumer_id#
				</cfquery>
				<cfset comp_name=Consumer.CONSUMER_NAME+""+Consumer.CONSUMER_SURNAME>
			</cfif>
			--->
			<cfif kontrol_.recordcount and len(kontrol_.total_amount)>
				<cfset my_sayi_ = kontrol_.total_amount + evaluate('amount#i#')>
				<cfif my_sayi_ gt evaluate('invoice_amount#i#')>
					<script type="text/javascript">
						alert("Toplam Satıştan Fazla İade Alamazsınız!");
						history.back();
					</script>
					<cfabort>
				</cfif>
			</cfif>
		</cfif>
		<cfif isdefined("attributes.is_check#i#")>
			<cfquery name="GET_INVOICE_ROW" datasource="#DSN2#">
				SELECT
					*
				FROM
					INVOICE_ROW 
				WHERE
					INVOICE_ROW_ID = #evaluate('attributes.invoice_row_id#i#')#
			</cfquery>
		</cfif>
		<cfquery name="GET_ORDER" datasource="#DSN3#">
			SELECT MAX(ORDER_ID) AS ORDER_ID FROM ORDERS WHERE WRK_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wrk_id#">
		</cfquery>

	<cfquery name="INSERT_ORDER_INFO_PLUS" datasource="#DSN3#">
		INSERT INTO
			ORDER_INFO_PLUS
			(
				ORDER_ID,
				PROPERTY1,
				RECORD_IP,
				RECORD_EMP,
				RECORD_DATE
			)
			VALUES
			(
				#GET_ORDER.ORDER_ID#,
				'İade Teslimat',
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				#session.ep.userid#,
				#now()#
			)
	</cfquery>

		<cfif isDefined("amount#i#")>
			<cfif evaluate('amount#i#') gt 0>
				<cfquery name="ADD_ORDER_ROW_" datasource="#DSN3#">
					INSERT INTO 
						ORDER_ROW
						(
							ORDER_ID,
							STOCK_ID,
							PRODUCT_ID,
							PRODUCT_NAME,
							QUANTITY,
							AMOUNT2,
							PRICE,
							TAX,
							UNIT,
							UNIT_ID,
							COST_ID,
							COST_PRICE,
							DELIVER_DATE,
							DELIVER_DEPT,
							DELIVER_LOCATION,
							DISCOUNT_1,
							DISCOUNT_2,
							DISCOUNT_3,
							DISCOUNT_4,
							DISCOUNT_5,
							DISCOUNT_6,
							DISCOUNT_7,
							DISCOUNT_8,
							DISCOUNT_9,
							DISCOUNT_10,
							SPECT_VAR_ID,
							SPECT_VAR_NAME,
							LOT_NO,
							PRICE_OTHER,
							OTHER_MONEY,
							OTHER_MONEY_VALUE,
							NETTOTAL,
							IS_PROMOTION,
							DISCOUNT_COST,
							EXTRA_COST,
							UNIQUE_RELATION_ID,
							PROM_RELATION_ID,
							PRODUCT_NAME2,
							EXTRA_PRICE, /* işçilik birim ücreti */
							EK_TUTAR_PRICE,
							EXTRA_PRICE_TOTAL,
							SHELF_NUMBER,
							PRODUCT_MANUFACT_CODE,
							BASKET_EXTRA_INFO_ID,
							SELECT_INFO_EXTRA,
							DETAIL_INFO_EXTRA,
							BASKET_EMPLOYEE_ID,
							LIST_PRICE,
							PRICE_CAT,
							CATALOG_ID,
							EXTRA_PRICE_OTHER_TOTAL,
							NUMBER_OF_INSTALLMENT,
							DUEDATE,
							KARMA_PRODUCT_ID,
							OTV_ORAN,
							OTVTOTAL,
							WRK_ROW_ID,
							WRK_ROW_RELATION_ID,
							RELATED_ACTION_ID,
							RELATED_ACTION_TABLE,
							WIDTH_VALUE,
							DEPTH_VALUE,
							HEIGHT_VALUE,
							ROW_PROJECT_ID,
							ROW_WORK_ID,
							DESCRIPTION,
							ORDER_ROW_CURRENCY,
							RESERVE_TYPE
						)
					VALUES
						(
							#GET_ORDER.ORDER_ID#,
							#GET_INVOICE_ROW.STOCK_ID#,
							#GET_INVOICE_ROW.PRODUCT_ID#,
							'#GET_INVOICE_ROW.NAME_PRODUCT#',
							#evaluate('amount#i#')#, /*#GET_INVOICE_ROW.AMOUNT#,*/
							#GET_INVOICE_ROW.AMOUNT#,
							#GET_INVOICE_ROW.PRICE#,
							#GET_INVOICE_ROW.TAX#,
							'#GET_INVOICE_ROW.UNIT#',
							#GET_INVOICE_ROW.UNIT_ID#,
							<cfif len(GET_INVOICE_ROW.COST_ID)>#GET_INVOICE_ROW.COST_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.COST_PRICE)>#GET_INVOICE_ROW.COST_PRICE#<cfelse>NULL</cfif>,
							#now()#,
							44, <!--- depo --->
							1,
							<cfif len(GET_INVOICE_ROW.DISCOUNT1)>#GET_INVOICE_ROW.DISCOUNT1#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT2)>#GET_INVOICE_ROW.DISCOUNT2#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT3)>#GET_INVOICE_ROW.DISCOUNT3#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT4)>#GET_INVOICE_ROW.DISCOUNT4#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT5)>#GET_INVOICE_ROW.DISCOUNT5#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT6)>#GET_INVOICE_ROW.DISCOUNT6#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT7)>#GET_INVOICE_ROW.DISCOUNT7#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT8)>#GET_INVOICE_ROW.DISCOUNT8#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT9)>#GET_INVOICE_ROW.DISCOUNT9#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT10)>#GET_INVOICE_ROW.DISCOUNT10#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.SPECT_VAR_ID)>#GET_INVOICE_ROW.SPECT_VAR_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.SPECT_VAR_NAME)>'#GET_INVOICE_ROW.SPECT_VAR_NAME#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.LOT_NO)>'#GET_INVOICE_ROW.LOT_NO#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.PRICE_OTHER)>#GET_INVOICE_ROW.PRICE_OTHER#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.OTHER_MONEY)>'#GET_INVOICE_ROW.OTHER_MONEY#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.OTHER_MONEY_VALUE)>#GET_INVOICE_ROW.OTHER_MONEY_VALUE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.NETTOTAL)>#GET_INVOICE_ROW.NETTOTAL#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.IS_PROMOTION)>#GET_INVOICE_ROW.IS_PROMOTION#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DISCOUNT_COST)>#GET_INVOICE_ROW.DISCOUNT_COST#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.EXTRA_COST)>#GET_INVOICE_ROW.EXTRA_COST#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.UNIQUE_RELATION_ID)>'#GET_INVOICE_ROW.UNIQUE_RELATION_ID#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.PROM_RELATION_ID)>'#GET_INVOICE_ROW.PROM_RELATION_ID#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.PRODUCT_NAME2)>'#GET_INVOICE_ROW.PRODUCT_NAME2#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.EXTRA_PRICE)>#GET_INVOICE_ROW.EXTRA_PRICE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.EK_TUTAR_PRICE)>#GET_INVOICE_ROW.EK_TUTAR_PRICE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.EXTRA_PRICE_TOTAL)>#GET_INVOICE_ROW.EXTRA_PRICE_TOTAL#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.SHELF_NUMBER)>#GET_INVOICE_ROW.SHELF_NUMBER#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.PRODUCT_MANUFACT_CODE)>'#GET_INVOICE_ROW.PRODUCT_MANUFACT_CODE#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.BASKET_EXTRA_INFO_ID)>#GET_INVOICE_ROW.BASKET_EXTRA_INFO_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.SELECT_INFO_EXTRA)>#GET_INVOICE_ROW.SELECT_INFO_EXTRA#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DETAIL_INFO_EXTRA)>'#GET_INVOICE_ROW.DETAIL_INFO_EXTRA#'<cfelse>NULL</cfif>,
							#session.ep.userid#,
							<cfif len(GET_INVOICE_ROW.LIST_PRICE)>#GET_INVOICE_ROW.LIST_PRICE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.PRICE_CAT)>#GET_INVOICE_ROW.PRICE_CAT#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.CATALOG_ID)>#GET_INVOICE_ROW.CATALOG_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.EXTRA_PRICE_OTHER_TOTAL)>#GET_INVOICE_ROW.EXTRA_PRICE_OTHER_TOTAL#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.NUMBER_OF_INSTALLMENT)>#GET_INVOICE_ROW.NUMBER_OF_INSTALLMENT#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DUE_DATE)>#GET_INVOICE_ROW.DUE_DATE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.KARMA_PRODUCT_ID)>#GET_INVOICE_ROW.KARMA_PRODUCT_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.OTV_ORAN)>#GET_INVOICE_ROW.OTV_ORAN#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.OTVTOTAL)>#GET_INVOICE_ROW.OTVTOTAL#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.WRK_ROW_ID)>'#GET_INVOICE_ROW.WRK_ROW_ID#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.WRK_ROW_RELATION_ID)>'#GET_INVOICE_ROW.WRK_ROW_RELATION_ID#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.RELATED_ACTION_ID)>'#GET_INVOICE_ROW.RELATED_ACTION_ID#'<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.RELATED_ACTION_TABLE)>#GET_INVOICE_ROW.RELATED_ACTION_TABLE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.WIDTH_VALUE)>#GET_INVOICE_ROW.WIDTH_VALUE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DEPTH_VALUE)>#GET_INVOICE_ROW.DEPTH_VALUE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.HEIGHT_VALUE)>#GET_INVOICE_ROW.HEIGHT_VALUE#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.ROW_PROJECT_ID)>#GET_INVOICE_ROW.ROW_PROJECT_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.ROW_WORK_ID)>#GET_INVOICE_ROW.ROW_WORK_ID#<cfelse>NULL</cfif>,
							<cfif len(GET_INVOICE_ROW.DESCRIPTION)>'#GET_INVOICE_ROW.DESCRIPTION#'<cfelse>NULL</cfif>,
							'-6',
							'-1'
						)
				</cfquery>
			</cfif>
		</cfif>
	</cfloop>

	<!--- 05.11.2021 - Yunus Emre Yazıcı - Desc : Eğer buradan oluşan satınalma siparişi için süreç çalıştırılmak istenirse aşağıdaki process kullanılmalıdır. --->
	<!--- 
	<cf_workcube_process
		is_upd='1'
		data_source='#dsn3#'
		old_process_line='0'
		process_stage='171'
		record_member='#session.ep.userid#'
		record_date='#now()#'
		action_table='ORDERS'
		action_column='ORDER_ID'
		action_id= '#GET_ORDER.ORDER_ID#'
		action_page='#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#GET_ORDER.ORDER_ID#' 
		warning_description='SATIN ALMA SİPARİŞİ (İADE):#GET_ORDER.ORDER_ID#'>
	--->
	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT 
			COMPANY_NAME,
			ADDRESS,
			TEL_CODE,
			TEL,FAX,
			WEB,
			ASSET_FILE_NAME2 
		FROM 
			OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfquery name="GET_ORDER_MAIL" datasource="#DSN3#">
		SELECT
			ORDER_ID,
			ORDER_HEAD,
			ORDER_DATE,
			ORDER_STAGE,
			RECORD_EMP,
			ORDER_NUMBER
		FROM
			ORDERS
		WHERE ORDER_ID = #GET_ORDER.ORDER_ID#
	</cfquery>

	<cfquery name="GET_DEP_ADMIN" datasource="#DSN#">
		SELECT ADMIN1_POSITION_CODE FROM DEPARTMENT WHERE DEPARTMENT_ID = 23
	</cfquery>

	<cfquery name="GET_EMP" datasource="#DSN#">
		SELECT EMPLOYEE_ID FROM EMPLOYEE_POSITIONS WHERE POSITION_ID = #GET_DEP_ADMIN.ADMIN1_POSITION_CODE#
	</cfquery>

	<cfquery name="GET_EMAIL" datasource="#DSN#">
		SELECT EMPLOYEE_EMAIL FROM EMPLOYEES WHERE EMPLOYEE_ID = #GET_EMP.EMPLOYEE_ID#
	</cfquery>

	<cfif len(get_comp_addr.ASSET_FILE_NAME2)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

	<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
	<cfset to_mail="#GET_EMAIL.EMPLOYEE_EMAIL#">
	<cfset subject_mail='#GET_ORDER_MAIL.ORDER_NUMBER# - Satınalma Siparişi'>

	<!---
	<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
		<html></html>
			<body>
				<cfoutput>
					<table cellpadding="0" cellspacing="0" align="center" width="800">
						<tr>
							<td align="center"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
							<!---
							<td align="center"><img border="0" src="#caller.user_domain#/#attributes.mail_logo#"/></td>
							--->
						</tr>
						<tr align="center">
							<td style="text-align:left">
								<p>Aşağıdaki sipariş numarasına tıklayarak, satınalma siparişi kaydına ulaşabilirsiniz.</p>
							</td>
						</tr>
						<tr align="center">
							<td style="text-align:left">
								<h4>Konu : #GET_ORDER_MAIL.ORDER_HEAD#</h4>
								<h4>Sipariş No : <a href="http://#employee_url#/#request.self#?fuseaction=purchase.list_order&event=upd&order_id=#GET_ORDER_MAIL.ORDER_ID#" class="tableyazi">#GET_ORDER_MAIL.ORDER_NUMBER#</a></h4>
								<h4>Tarih : #dateformat(GET_ORDER_MAIL.ORDER_DATE,"dd.mm.yyyy")#</h4>
							</td>
							<td style="text-align:right">
								
							</td>
						</tr>
						<tr>
							<td align="right"></td>
						</tr>
						<tr>
							<td align="left"></td>
						</tr>
						<cfif get_comp_addr.recordcount>
							<tr>
								<td><br/><br></td>
								<td><br/><br></td>
							</tr>
							<tr>
								<td class="unbold" style="font-size:12px;">
								#get_comp_addr.company_name#<br>
								#get_comp_addr.address#<br>
								<cf_get_lang_main no="87.Tel">: #get_comp_addr.tel_code# #get_comp_addr.tel# <cf_get_lang_main no="76.Fax">: #get_comp_addr.tel_code# #get_comp_addr.fax#<br>
								<a href="mailto:#get_comp_addr.web#">#get_comp_addr.web#</a>
								</td>
							</tr>
						</cfif>
					</table> 
				</cfoutput>
			</body>
		</html>
	</cfmail>
	--->

	<script type="text/javascript">
		alert("Merkeze İade İçin Satınalma Siparişi Oluşturuldu" );
		window.location.href ="<cfoutput>#request.self#?fuseaction=service.product_return</cfoutput>";
	</script>

<cfelseif session.ep.isBranchAuthorization eq 1>
	<cfquery name="GET_STAGE" datasource="#DSN#" maxrows="1">
		SELECT
			PTR.STAGE,
			PTR.PROCESS_ROW_ID 
		FROM
			PROCESS_TYPE_ROWS PTR,
			PROCESS_TYPE_OUR_COMPANY PTO,
			PROCESS_TYPE PT
		WHERE
			PT.IS_ACTIVE = 1 AND
			PT.PROCESS_ID = PTR.PROCESS_ID AND
			PT.PROCESS_ID = PTO.PROCESS_ID AND
			PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
			PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%service.add_return%">
		ORDER BY
			PTR.PROCESS_ROW_ID ASC
	</cfquery>
	<cfif not get_stage.recordcount>
		<script type="text/javascript">
			alert("Servis Durumu Bulunamadı! Müşteri Hizmetlerine Başvurunuz!");
			history.back();
		</script>
		<cfabort>
	</cfif>
	<cfloop list="#attributes.invoice_row_list#" index="i">
		<cfif isdefined("attributes.is_check#i#")>
			<cfquery name="KONTROL_" datasource="#DSN3#">
				SELECT 
					SUM(AMOUNT) TOTAL_AMOUNT
				FROM 
					SERVICE_PROD_RETURN_ROWS SPRR,
					SERVICE_PROD_RETURN SPR 
				WHERE 
					SPRR.RETURN_ID = SPR.RETURN_ID AND 
					SPRR.INVOICE_ROW_ID = #evaluate('attributes.invoice_row_id#i#')# AND
					SPR.PERIOD_ID = #attributes.period_id# AND
					SPRR.STOCK_ID = #evaluate('attributes.stock_id#i#')#
				<!---BK--->
				<cfif is_return_control eq 1>
					AND SPRR.RETURN_ACT_TYPE = 1
				</cfif>				
			</cfquery>
			<cfif kontrol_.recordcount and len(kontrol_.total_amount)>
				<cfset my_sayi_ = kontrol_.total_amount + evaluate('amount#i#')>
				<cfif my_sayi_ gt evaluate('invoice_amount#i#')>
					<script type="text/javascript">
						alert("Toplam Satıştan Fazla İade Alamazsınız!");
						history.back();
					</script>
					<cfabort>
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
		<cfif len(attributes.service_company_id)>
				<cfquery name="Company_Service" datasource="#DSN#">
					 SELECT 
					  NICKNAME 
					 FROM 
					  COMPANY 
					 WHERE COMPANY_ID=#attributes.service_company_id#
				</cfquery>
				<cfset comp_name=Company_Service.NICKNAME>
			</cfif>
			<cfif len(attributes.service_consumer_id)>
				<cfquery name="Consumer_Service" datasource="#DSN#">
					 SELECT 
					 CONSUMER_NAME +' '+ CONSUMER_SURNAME AS NAME
					 FROM 
					 CONSUMER 
					 WHERE CONSUMER_ID=#attributes.service_consumer_id#
				</cfquery>
			 <cfset comp_name=Consumer_Service.NAME>
			</cfif>
	<cflock name="#CreateUUID()#" timeout="20">
		<cftransaction>
		<cfquery name="ADD_RETURN" datasource="#DSN3#" result="MAX_ID">
			INSERT INTO
				SERVICE_PROD_RETURN
			(
				INVOICE_ID,
				PAPER_NO,
				PERIOD_ID,
				SERVICE_COMPANY_ID,
				SERVICE_PARTNER_ID,
				SERVICE_CONSUMER_ID,
				SERVICE_EMPLOYEE_ID,
				RECORD_DATE,
				RECORD_IP,
				RECORD_EMP
			)
			VALUES
			(
				#attributes.invoice_id#,
				'#attributes.paper_no#',
				#attributes.period_id#,
				<cfif len(attributes.service_company_id)>#attributes.service_company_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.service_partner_id)>#attributes.service_partner_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.service_consumer_id)>#attributes.service_consumer_id#<cfelse>NULL</cfif>,
				<cfif len(attributes.service_employee_id)>#attributes.service_employee_id#<cfelse>NULL</cfif>,
				#now()#,
				'#cgi.remote_addr#',
				#session.ep.userid#
			)
		</cfquery>
		<cfset GET_MAX.MAX_ID = MAX_ID.IDENTITYCOL>
		<cfloop list="#attributes.invoice_row_list#" index="i">
			<cfif isdefined("attributes.is_check#i#")>
				<cfset detail= URLEncodedFormat(evaluate("attributes.detail#i#"))>
				<cfquery name="ADD_RETURN_ROWS" datasource="#DSN3#">
					INSERT INTO
						SERVICE_PROD_RETURN_ROWS
					(
						RETURN_ID,
						STOCK_ID,
						RETURN_TYPE,
						RETURN_ACT_TYPE,
						<!--- BK kaldirildi. 20130702 RETURN_TYPE_OTHER, --->
						DETAIL,
						ACCESSORIES,
						PACKAGE,
						AMOUNT,
						INVOICE_ROW_ID,
						RETURN_STAGE
					)
					VALUES
					(
						#get_max.max_id#,
						#evaluate('stock_id#i#')#,
						#evaluate('returncat#i#')#,
						<cfif isdefined("attributes.return_act_type#i#") and len(evaluate('attributes.return_act_type#i#'))>#evaluate('attributes.return_act_type#i#')#<cfelse>NULL</cfif>,
						<!--- BK kaldirildi. 20130702 <cfif evaluate('returncat#i#') eq -1 and len(evaluate('returncat_text#i#'))>'#evaluate('returncat_text#i#')#'<cfelse>NULL</cfif>, --->
						'#detail#',
						<cfif isdefined("attributes.accessories#i#")>#evaluate('attributes.accessories#i#')#<cfelse>NULL</cfif>,
						#evaluate('package#i#')#,
						#evaluate('amount#i#')#,
						#i#,
						#get_stage.process_row_id#
					)
				</cfquery>
				<cfquery name="GET_MAX_ROW" datasource="#DSN3#">
					SELECT MAX(RETURN_ROW_ID) AS MAX_ID FROM SERVICE_PROD_RETURN_ROWS
				</cfquery>
				<!--- degisim ise ve xml de takip eklensin secili ise uyeye bir takip kaydi yapiyor --->
				<!--- fazla urun ise stogun bloke stok miktari 1 arttirilir--->
				<cfif isdefined("attributes.return_act_type#i#") and len(evaluate('attributes.return_act_type#i#')) and evaluate('attributes.return_act_type#i#') eq 3>
					<cfquery name="UPD_STOCK_STRATEGY" datasource="#DSN3#">
						UPDATE
							STOCK_STRATEGY
						SET
							BLOCK_STOCK_VALUE = ISNULL(BLOCK_STOCK_VALUE,0) + #evaluate('amount#i#')#,
							RETURN_BLOCK_VALUE = #evaluate('amount#i#')#
						WHERE
							STOCK_ID = #evaluate('stock_id#i#')# AND
							STRATEGY_TYPE = 0
					</cfquery>
				</cfif>
			</cfif>
		</cfloop>
		</cftransaction>
	</cflock>
	<cf_workcube_process 
		is_upd='1' 
		old_process_line='0'
		process_stage='#get_stage.process_row_id#' 
		record_member='#session.ep.userid#' 
		record_date='#now()#' 
		action_id='#get_max.max_id#'
		action_page='#request.self#?fuseaction=service.popup_upd_product_return&return_id=#get_max.max_id#' 
		warning_description='İade : #get_max.max_id#'>
	<script type="text/javascript">
		window.location.href ="<cfoutput>#request.self#?fuseaction=service.product_return&FORM_SUBMITTED=1&KEYWORD=#attributes.paper_no#&PRODUCT_PROCESS_TYPE=&RETURN_TYPE=&LISTING_TYPE=2&CONSUMER_ID=<cfif len(attributes.service_consumer_id)>#attributes.service_consumer_id#<cfelse>&nbsp</cfif>&COMPANY_ID=<cfif len(attributes.service_company_id)>#attributes.service_company_id#<cfelse>&nbsp</cfif>&MEMBER_TYPE=partner&MEMBER_NAME=#comp_name#&IS_IRSALIYE=&RETURN_STAGE=</cfoutput>";
	</script>
</cfif>