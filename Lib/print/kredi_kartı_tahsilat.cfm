<!--- Kredi Kartı Tahsilatı --->
<link rel="stylesheet" href="/css/assets/template/catalyst/print.css" type="text/css">
<cfquery name="GET_PAYMENT" datasource="#DSN3#">
	SELECT 
    	ACTION_FROM_COMPANY_ID,
        CONSUMER_ID,
        ACTION_TYPE_ID,
        CARD_NO,
        SALES_CREDIT,
        ACTION_DETAIL,
        STORE_REPORT_DATE,
        CREDITCARD_PAYMENT_ID ,
		OTHER_CASH_ACT_VALUE,
		OTHER_MONEY
    FROM 
    	CREDIT_CARD_BANK_PAYMENTS 
    WHERE 
    	CREDITCARD_PAYMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>
<cfif len(get_payment.action_from_company_id)>
	<cfquery name="GET_MEMBER_INFO" datasource="#DSN3#">
		SELECT
			MEMBER_CODE,
			FULLNAME,
			COMPANY_ADDRESS ADDRESS,
			COUNTY,
			CITY,
			COUNTRY,
			SEMT,
			TAXOFFICE TAX_OFFICE,
			TAXNO TAX_NO
		FROM
			#dsn_alias#.COMPANY
		WHERE 
			COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_payment.action_from_company_id#">
	</cfquery>
<cfelse>
	<cfquery name="GET_MEMBER_INFO" datasource="#DSN3#">
		SELECT 
			MEMBER_CODE,
			CONSUMER_NAME,
			CONSUMER_SURNAME,
			HOMEADDRESS ADDRESS,
			HOME_CITY_ID CITY,
			HOME_COUNTY_ID COUNTY,
			HOME_COUNTRY_ID COUNTRY,
			HOMESEMT SEMT,
			TAX_OFFICE,
			TAX_NO
		FROM 
			#dsn_alias#.CONSUMER
		WHERE 
			CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_payment.consumer_id#">
	</cfquery>
</cfif>
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
<cfoutput>
<table style="width:210mm" align="center">
	<tr>
		<cf_get_server_file output_file="/settings/#check.asset_file_name2#" output_server="#check.asset_file_name2_server_id#" output_type="5">
	</tr>
</table>
<table style="width:210mm">
	<tr>
		<td>
			<table width="100%">
				<tr class="row_border">
					<td class="print-head">
						<table style="width:100%;">
							<tr>
								<cfif get_payment.action_type_id eq 241>
									<td class="print_title"><cf_get_lang dictionary_id='30101.kredi kartı tahsilatları'></td>
								<cfelseif get_payment.action_type_id eq 245>
									<td class="print_title"><cf_get_lang dictionary_id='29552.kredi kartı tahsilat iptal'></td>
								</cfif>
								<td style="text-align:right;">
									<cfif len(check.asset_file_name2)>
									<cfset attributes.type = 1>
									<!---
									<cf_get_server_file output_file="/settings/#check.asset_file_name2#" output_server="#check.asset_file_name2_server_id#" output_type="5">
									--->
									</cfif>
								</td>
							</tr> 
						</table>
					</td>
				</tr>
				<tr class="row_border" class="row_border">
					<td>
						<table>
							<tr>
							<td style="width:140px"><b><cf_get_lang dictionary_id='58772.Transaction No.'></b></td>
								<td style="width:140px"> #GET_PAYMENT.creditcard_payment_id#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='34241.Code'></b></td>
								<td style="width:140px"> #GET_MEMBER_INFO.MEMBER_CODE#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='57519.cari hesap'></b></td>
								<td>#GET_MEMBER_INFO.FULLNAME#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='58762.Tax Office'></b></td>
								<td>#GET_MEMBER_INFO.TAX_OFFICE#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='57752.TIN'></b></td>
								<td>#GET_MEMBER_INFO.TAX_NO#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='57629.Açıklama'></b></td> 
									<td>#GET_PAYMENT.action_detail#</td>
							</tr>
							<tr>
								<td style="width:140px"><b><cf_get_lang dictionary_id='58723.Addres'></b></td>
								<td>
									<cfif len(GET_MEMBER_INFO.COUNTY)>
										<cfquery name="GET_COUNTY_HOME" datasource="#DSN3#">
											SELECT COUNTY_NAME FROM #dsn_alias#.SETUP_COUNTY WHERE COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_MEMBER_INFO.COUNTY#">
										</cfquery>
									</cfif>
									<cfif len(GET_MEMBER_INFO.CITY)>
										<cfquery name="GET_CITY_HOME" datasource="#DSN3#">
											SELECT CITY_NAME FROM #dsn_alias#.SETUP_CITY WHERE CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_MEMBER_INFO.CITY#">
										</cfquery>				  
									</cfif>	
									#GET_MEMBER_INFO.ADDRESS#
									<cfif len(GET_MEMBER_INFO.COUNTY)>#GET_COUNTY_HOME.COUNTY_NAME#</cfif>&nbsp;&nbsp;<cfif len(GET_MEMBER_INFO.CITY)>#GET_CITY_HOME.CITY_NAME#</cfif> 
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<table>
					<tr>
						<td style="height:35px;"><b><cf_get_lang dictionary_id='57771. DETAY"'></b></td>
					</tr> 
				</table>
				<table class="print_border" style="width:100mm">
					<tr>
						<th><cf_get_lang dictionary_id='57742.tarih.'></th>
						<th><cf_get_lang dictionary_id='57673.tutar'></th>
						<th><cf_get_lang dictionary_id='58056.dövizli tutar'></th>
					</tr>
					<tr>
						<td>#dateformat(GET_PAYMENT.STORE_REPORT_DATE,'dd.mm.yyyy')##timeformat(date_add('h',session.ep.time_zone,now()),timeformat_style)#</td>
						<td style="text-align:right;"><cfif len(GET_PAYMENT.CREDITCARD_PAYMENT_ID)>#TLFormat(GET_PAYMENT.SALES_CREDIT)#&nbsp; #session.ep.money#</cfif></td>
						<td style="text-align:right;">#TLFormat(GET_PAYMENT.OTHER_CASH_ACT_VALUE)#&nbsp;#GET_PAYMENT.OTHER_MONEY#</td>
					</tr>
				</table>
				<table>
					</br>
						<tr class="fixed">
						<td style="font-size:9px!important;"><b><cf_get_lang dictionary_id='61710.© Copyright'></b> <cfoutput>#check.COMPANY_NAME#</cfoutput> <cf_get_lang dictionary_id='61711.dışında kullanılamaz, paylaşılamaz.'></td>
						</tr>
					</br>
				</table>
			</table>
		</td>
	</tr>
</table>
</cfoutput>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
