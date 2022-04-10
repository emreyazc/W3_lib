<!---
	Desc : Birikim Pilleri Kargo Etiket - Toptan Satış İrsaliye
--->

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
		TEL,
		TEL2,
		TEL3,
		TEL4,
		FAX,
		TAX_OFFICE,
		TAX_NO,
		ADDRESS,
		WEB,
		EMAIL,
		CITY.CITY_NAME,
		COUNTY.COUNTY_NAME
	FROM 
	   #dsn_alias#.OUR_COMPANY OC
	   LEFT JOIN #DSN#.SETUP_CITY CITY ON CITY.CITY_ID = OC.CITY_ID
	   LEFT JOIN #DSN#.SETUP_COUNTY COUNTY ON COUNTY.COUNTY_ID = OC.COUNTY_ID
	WHERE 
	<cfif isDefined("SESSION.EP.Company_Id")>
		COMP_ID = #SESSION.EP.Company_Id#
	<cfelseif isDefined("SESSION.PP.COMPANY")>	
		COMP_ID = #SESSION.PP.COMPANY#
	</cfif>
</cfquery>

<cfquery name="GET_SHIP" datasource="#DSN2#">
	SELECT
		S.SHIP_NUMBER,
		S.DELIVER_DATE,
		S.COMPANY_ID,
		S.CONSUMER_ID,
		S.PARTNER_ID,
		SM.SHIP_METHOD AS SHIP_METHOD_,
		SP.PAYMETHOD AS PAYMETHOD_,
		O.SHIP_ADDRESS AS ORDER_ADDRESS,
		S.CITY_ID,
		S.COUNTY_ID,
		S.SHIP_TYPE
	FROM
		SHIP S
		LEFT JOIN #DSN3#.ORDERS_SHIP OS ON OS.SHIP_ID = S.SHIP_ID
		LEFT JOIN #DSN3#.ORDERS O ON O.ORDER_ID = OS.ORDER_ID
		LEFT JOIN #DSN#.SHIP_METHOD SM ON SM.SHIP_METHOD_ID =  S.SHIP_METHOD
		LEFT JOIN #DSN#.SETUP_PAYMETHOD SP ON SP.PAYMETHOD_ID = S.PAYMETHOD_ID
	WHERE
		S.SHIP_ID = #attributes.action_id#
</cfquery>

<cfif GET_SHIP.SHIP_TYPE neq 71>
	<script type="text/javascript">
		alert("Bu alandan sadece Toptan Satış İrsaliye Etiketi Yazdırabilirsiniz.");		
	</script>
		<cfabort>
</cfif>

<cfif isdefined("GET_SHIP.COMPANY_ID") and Len(GET_SHIP.COMPANY_ID)>
	<cfquery name="GET_MEMBER_INFO" datasource="#attributes.data_source#">
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
			LEFT JOIN SETUP_CITY SC ON C.CITY=SC.CITY_ID
			LEFT JOIN SETUP_COUNTY SCO ON C.COUNTY=SCO.COUNTY_ID
        WHERE
            COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_SHIP.COMPANY_ID#">
	</cfquery>
	<cfelseif isdefined("GET_SHIP.CONSUMER_ID") and Len(GET_SHIP.CONSUMER_ID)>
		<cfquery name="GET_MEMBER_INFO" datasource="#attributes.data_source#">
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
				LEFT JOIN SETUP_CITY SC ON C.TAX_CITY_ID=SC.CITY_ID
				LEFT JOIN SETUP_COUNTY SCO ON C.TAX_COUNTY_ID=SCO.COUNTY_ID
			WHERE
				CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_SHIP.CONSUMER_ID#">
		</cfquery>
</cfif>

<cfif isdefined("GET_SHIP.PARTNER_ID") and Len(GET_SHIP.PARTNER_ID)>
	<cfquery name="GET_PARTNER_INFO" datasource="#DSN#">
		SELECT
			COMPANY_PARTNER_NAME AS PARTNER_NAME,
			COMPANY_PARTNER_SURNAME AS PARTNER_SURNAME,
			COMPANY_PARTNER_TELCODE AS PARTNER_TELCODE,
			COMPANY_PARTNER_TEL AS PARTNER_TEL
		FROM
			COMPANY_PARTNER
		WHERE
			PARTNER_ID = #GET_SHIP.PARTNER_ID#
	</cfquery>
</cfif>

<cfdocument  format="PDF" pagetype="A5">
	<div class="css4">
		<div>
			<table border="2" style="height:135mm; width:100mm; font-size:11px">
				<cfoutput query="GET_SHIP">
					<tbody>
						<tr rowspan="2">
							<td style="width:25%" align="center"><b>TARİH/SAAT</b></td>
							<td style="width:25%" align="center"><b>#dateFormat(DELIVER_DATE,dateformat_style)#</b></td>
							<td style="width:25%" align="center"><b>İRSALİYE</b></td>
							<td style="width:25%;" align="center"><b>#SHIP_NUMBER#</b><!---<cf_barcode type="EAN13" barcode="#INVOICE_NUMBER#" extra_height="0"><cfif len(errors)><cfoutput>#errors#</cfoutput></cfif>---></td>
						</tr>
						<tr>
							<td align="center"><b>KARGO</b></td>
							<td align="center"><b>#SHIP_METHOD_#</b></td>
							<td align="center">#PAYMETHOD_#</td>
							<td align="center">1</td>
						</tr>
						<tr>
							<th colspan="4" align="left" style="width:25%"><b>ALICI</b></th>
						</tr>
						<tr>
							<td colspan="4"><cfoutput>#Get_Member_Info.MEMBER_NAME#</cfoutput></td>
						</tr>
						<tr>
							<td colspan="4"><b>ADRES : </b>#ORDER_ADDRESS#</td>
						</tr>
						<tr>
							<td colspan="2" style="width:50%">
								<cfif len(GET_SHIP.CITY_ID)>
									<cfquery name="GET_SHIP_CITY" datasource="#DSN#">
										SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #GET_SHIP.CITY_ID#
									</cfquery>
									<b>İL : </b>#GET_SHIP_CITY.CITY_NAME#
								</cfif>
							</td>
							<td colspan="2" style="width:50%">
								<cfif len(GET_SHIP.COUNTY_ID)>
									<cfquery name="GET_SHIP_COUNTY" datasource="#DSN#">
										SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #GET_SHIP.COUNTY_ID#
									</cfquery>
									<b>İLÇE : </b>#GET_SHIP_COUNTY.COUNTY_NAME#
								</cfif>
							</td>
						</tr>
						<tr>
							<td colspan="2"><b>İLGİLİ : </b>#GET_PARTNER_INFO.PARTNER_NAME# #GET_PARTNER_INFO.PARTNER_SURNAME#</td>
							<td colspan="2"><b>TEL : </b>#GET_PARTNER_INFO.PARTNER_TELCODE# #GET_PARTNER_INFO.PARTNER_TEL#</td>
						</tr>
						<tr>
							<th colspan="4" align="left"><b>GÖNDEREN</b></th>
						</tr>
						<tr>
							<td colspan="4">#OUR_COMPANY.COMPANY_NAME#</td>
						</tr>
						<tr>
							<td colspan="4"><b>ADRES : </b>#OUR_COMPANY.ADDRESS#</td>
						</tr>
						<tr>
							<td colspan="2"><b>İL : </b>#OUR_COMPANY.CITY_NAME#</td>
							<td colspan="2"><b>İLÇE : </b>#OUR_COMPANY.COUNTY_NAME#</td>
						</tr>
						<tr>
							<td colspan="4"><b>TEL : </b>0#OUR_COMPANY.TEL_CODE# #OUR_COMPANY.TEL#</td>
							<!---
							<td colspan="2"></td>
							--->
						</tr>
						<tr>
							<th colspan="4" align="left"><b>MÜŞTERİ</b></th>
						</tr>
						<tr>
							<td colspan="4">#Get_Member_Info.MEMBER_NAME#</td>
						</tr>
						<tr>
							<td colspan="4"><b>ADRES : </b>#Get_Member_Info.MEMBER_ADDRESS#</td>
						</tr>
						<tr>
							<td colspan="2"><b>İL : </b>#Get_Member_Info.MEMBER_CITY#</td>
							<td colspan="2"><b>İLÇE : </b>#Get_Member_Info.MEMBER_COUNTY#</td>
						</tr>
						<tr>
							<td colspan="4"><b>TEL : </b>#Get_Member_Info.MEMBER_TELCODE# #Get_Member_Info.MEMBER_TEL#</td>
							<!---
							<td colspan="2"></td>
							--->
						</tr>
					</tbody>
				</cfoutput>
			</table>
		</div>
	</div>
</cfdocument>