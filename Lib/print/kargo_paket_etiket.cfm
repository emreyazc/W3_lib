<!---
	Desc : Birikim Pilleri Kargo Şablonu
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
		TEL,TEL2,
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
			O.ORDER_NUMBER,
			O.SHIP_ADDRESS,
			O.CITY_ID,
			O.COUNTY_ID,
			I.RECORD_EMP AS RECORD_EMP
       	FROM 
			#dsn2_alias#.INVOICE I
			LEFT JOIN #dsn3_alias#.ORDERS O  ON I.ORDER_ID=O.ORDER_ID
            LEFT JOIN COMPANY C ON C.COMPANY_ID = I.COMPANY_ID
			LEFT JOIN COMPANY_PARTNER CP ON CP.COMPANY_ID = C.COMPANY_ID AND CP.PARTNER_ID = I.PARTNER_ID
            LEFT JOIN SHIP_METHOD ON SHIP_METHOD_ID =  I.SHIP_METHOD
			LEFT JOIN SETUP_CITY SC ON C.CITY=SC.CITY_ID
			LEFT JOIN SETUP_COUNTY SCO ON C.COUNTY=SCO.COUNTY_ID
			LEFT JOIN SETUP_COUNTY SCORDER ON SCORDER.COUNTY_ID = O.COUNTY_ID
			LEFT JOIN SETUP_CITY SCITYORDER ON SCITYORDER.CITY_ID = O.CITY_ID
		WHERE 
	<cfif not isDefined("attributes.ID")>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
	</cfquery>

	<cfif len(Get_Order.RECORD_EMP)>
		<cfquery name="GET_BRANCH_INFO" datasource="#DSN#">
			SELECT
			B.BRANCH_FULLNAME,
			B.BRANCH_COUNTRY,
			B.BRANCH_ADDRESS,
			B.BRANCH_TELCODE,
			B.BRANCH_TEL1,
			B.BRANCH_FAX,
			B.BRANCH_COUNTY,
			B.BRANCH_CITY
			FROM
			EMPLOYEE_POSITIONS EP
			LEFT JOIN DEPARTMENT D ON D.DEPARTMENT_ID = EP.DEPARTMENT_ID
			LEFT JOIN BRANCH B ON B.BRANCH_ID = D.BRANCH_ID
			WHERE
			EP.EMPLOYEE_ID = #Get_Order.RECORD_EMP#
	</cfquery>
	</cfif>

	<cfquery name="GET_INVOICE_SHIP" datasource="#dsn2_alias#">
		SELECT
			SRR.SHIP_RESULT_ROW_ID,
			SRP.PACKAGE_PIECE AS PAKET_ADET,
			SRP.PACKAGE_TYPE,
			SPT.PACKAGE_TYPE AS PAKET_TİPİ	
		FROM
			INVOICE_SHIPS I_SHIPS
			LEFT JOIN SHIP_RESULT_ROW SRR ON SRR.SHIP_ID = I_SHIPS.SHIP_ID
			LEFT JOIN SHIP_RESULT_PACKAGE SRP ON SRP.SHIP_ID = SRR.SHIP_RESULT_ROW_ID
			LEFT JOIN #DSN#.SETUP_PACKAGE_TYPE SPT ON SPT.PACKAGE_TYPE_ID = SRP.PACKAGE_TYPE
		WHERE
		<cfif not isDefined("attributes.ID")>
			I_SHIPS.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
		<cfelse>
			I_SHIPS.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
		</cfif>
	</cfquery>

	<!---
	<cfdump var="#GET_INVOICE_SHIP#">
	--->

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
        TEVKIFAT_ID,
		PAY_METHOD
    FROM 
    	INVOICE 
    WHERE 
	<cfif not isDefined("attributes.ID")>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
</cfquery>

<cfif len(Get_Invoice.PAY_METHOD)>
	<cfquery name="GET_PAYMETHOD" datasource="#DSN#">
		SELECT
			PAYMETHOD
		FROM
			SETUP_PAYMETHOD	
		WHERE
			PAYMETHOD_ID = #Get_Invoice.PAY_METHOD#
	</cfquery>
</cfif>

<cfif len(GET_ORDER.CITY_ID)>
	<cfquery name="GET_ORDER_CITY" datasource="#DSN#">
		SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #GET_ORDER.CITY_ID#
	</cfquery>
</cfif>
<cfif len(GET_ORDER.COUNTY_ID)>
	<cfquery name="GET_ORDER_COUNTY" datasource="#DSN#">
		SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #GET_ORDER.COUNTY_ID#
	</cfquery>
</cfif>

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

<cfif GET_INVOICE_SHIP.PAKET_ADET eq 1 OR GET_INVOICE_SHIP.PAKET_ADET eq ''>
	<cfset index_to = 1>
<cfelse>
	<cfset index_to = GET_INVOICE_SHIP.PAKET_ADET>
</cfif>

<cfloop index="j" from="1" to="#index_to#">
	<cfoutput query="get_order">
		<div class="css4">
			<cfloop from="1" to="#Page_Count#" index="i">
				<div>
					<table border="1" style="height:135mm; width:100mm">
						<tbody>
							<tr rowspan="2">
								<td style="width:25%" align="center"><b>TARİH/SAAT</b></td>
								<td style="width:25%" align="center"><b>#dateFormat(INVOICE_DATE,dateformat_style)#</b></td>
								<td style="width:25%" align="center"><b>FATURA</b></td>
								<td style="width:25%" align="center"><b>#INVOICE_NUMBER#</b><!---<cf_barcode type="EAN13" barcode="#INVOICE_NUMBER#" extra_height="0"><cfif len(errors)><cfoutput>#errors#</cfoutput></cfif>---></td>
							</tr>
							<tr>
								<td align="center" style="font-size:13px"><b>KARGO</b></td>
								<td align="center" style="font-size:13px"><b>#Get_Order.SHIP_METHOD_#</b></td>
								<td align="center" style="font-size:13px"><cfif len(Get_Invoice.PAY_METHOD)><b><!---#GET_PAYMETHOD.PAYMETHOD#--->&nbsp;</b><cfelse>&nbsp;</cfif></td>
								<td align="center">
									<cfif GET_INVOICE_SHIP.PAKET_ADET neq 1 OR GET_INVOICE_SHIP.PAKET_ADET neq ''>
										<b>#j# / #GET_INVOICE_SHIP.PAKET_ADET# <br> #GET_INVOICE_SHIP.PAKET_TİPİ#</b>
									<cfelse>
									</cfif>
								</td>
							</tr>
							<!---
							<tr>
								<td colspan="4"></td>
							</tr>
							--->
							<tr>
								<th colspan="4" align="left" style="width:25%"><b>ALICI</b></th>
							</tr>
							<tr>
								<td colspan="4">#Get_Member_Info.MEMBER_NAME#</td>
							</tr>
							<tr>
								<td colspan="4"><b>ADRES : </b>#GET_ORDER.SHIP_ADDRESS#</td>
							</tr>
							<tr>
								<td colspan="2" style="width:50%"><b>İL : </b><cfif isDefined("GET_ORDER_CITY.CITY_NAME") and len(GET_ORDER_CITY.CITY_NAME)>#GET_ORDER_CITY.CITY_NAME#</cfif></td>
								<td colspan="2" style="width:50%"><b>İLÇE : </b><cfif isDefined("GET_ORDER_COUNTY.COUNTY_NAME") and len(GET_ORDER_COUNTY.COUNTY_NAME)>#GET_ORDER_COUNTY.COUNTY_NAME#</cfif></td>
							</tr>
							<tr>
								<td colspan="2"><b>İLGİLİ : </b>#Get_Member_Info.MEMBER_NAME#</td>
								<td colspan="2"><b>TEL : </b>#Get_Member_Info.MEMBER_TELCODE# #GET_MEMBER_INFO.MEMBER_TEL#</td>
							</tr>
							<tr>
								<th colspan="4" align="left"><b>GÖNDEREN</b></th>
							</tr>
							<tr>
								<td colspan="4">#OUR_COMPANY.COMPANY_NAME#</td>
							</tr>
							<tr>
								<td colspan="4"><b>ADRES : </b>#GET_BRANCH_INFO.BRANCH_ADDRESS#</td>
							</tr>
							<tr>
								<td colspan="2"><b>İL : </b>#GET_BRANCH_INFO.BRANCH_CITY#</td>
								<td colspan="2"><b>İLÇE : </b>#GET_BRANCH_INFO.BRANCH_COUNTY#</td>
							</tr>
							<tr>
								<td colspan="4"><b>TEL : </b>#GET_BRANCH_INFO.BRANCH_TELCODE# #GET_BRANCH_INFO.BRANCH_TEL1# </td>
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
								<td colspan="2"><b>İL : </b>#CİTY_NAME#</td>
								<td colspan="2"><b>İLÇE : </b>#COUNTY_NAME#</td>
							</tr>
							<tr>
								<td colspan="4"><b>TEL : </b>#Get_Member_Info.MEMBER_TELCODE# #GET_MEMBER_INFO.MEMBER_TEL#</td>
								<!---
								<td colspan="2"></td>
								--->
							</tr>
						</tbody>
					</table>
				</div>
				<cfset Row_Start = Row_End + Row_Start>
			</cfloop>
		</div>
	</cfoutput>
	<cfif j eq index_to >
	<cfelse>
		<cfdocumentitem type="pagebreak"/>
	</cfif>
</cfloop>