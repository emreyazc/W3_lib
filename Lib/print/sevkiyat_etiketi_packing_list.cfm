<!---
	Date : 17.12.2021
	Desc : Birikim İhracat Packing List Şablonudur
	Dev	 : Yunus Emre Yazıcı - Birikim Pilleri
--->

<!---
<cfquery name="GET_SHIP_RESULT" datasource="#DSN2#">
	SELECT
		SHIP_METHOD_TYPE,
		SHIP_FIS_NO,
		OUT_DATE,
		COST_VALUE,
		COST_VALUE_MONEY,
		COST_VALUE_2
		COST_VALUE2_MONEY,
		COMPANY_ID,
		PARTNER_ID,
		SENDING_ADDRESS
	FROM
		SHIP_RESULT
	WHERE
		SHIP_RESULT_ID = #attributes.action_id#
</cfquery>
--->
<cfquery name="CHECK" datasource="#DSN#">
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
        ADDRESS,
        WEB,
        EMAIL,
        TAX_OFFICE,
        TAX_NO 
    FROM 
        OUR_COMPANY 
    WHERE 
        COMP_ID = #SESSION.EP.COMPANY_ID#
</cfquery>

<cfquery name="GET_SHIP_RESULT" datasource="#DSN2#">
	SELECT
		SR.SHIP_METHOD_TYPE,
		SR.SHIP_FIS_NO,
		SR.OUT_DATE,
		SR.DELIVERY_DATE,
		SR.SHIP_STAGE,
		SR.COST_VALUE,
		SR.COST_VALUE_MONEY,
		SR.COST_VALUE2,
		SR.COST_VALUE2_MONEY,
		SR.COMPANY_ID,
		SR.PARTNER_ID,
		SR.SENDING_ADDRESS,
		SR.SENDING_COUNTY_ID,
		SR.SENDING_CITY_ID,
		SR.SENDING_COUNTRY_ID,
		S_ULKE.COUNTRY_NAME AS ULKE,
		S_SEHIR.CITY_NAME AS SEHIR,
		S_ILCE.COUNTY_NAME AS ILCE,
		CP.FULLNAME AS CONSUMER
	FROM
		SHIP_RESULT SR
		LEFT JOIN #DSN#.COMPANY CP ON CP.COMPANY_ID = SR.COMPANY_ID
		LEFT JOIN #DSN#.SETUP_COUNTRY S_ULKE ON S_ULKE.COUNTRY_ID = SR.SENDING_COUNTRY_ID
		LEFT JOIN #DSN#.SETUP_CITY S_SEHIR ON S_SEHIR.CITY_ID = SR.SENDING_CITY_ID
		LEFT JOIN #DSN#.SETUP_COUNTY S_ILCE ON S_ILCE.COUNTY_ID = SR.SENDING_COUNTY_ID
	WHERE
		SHIP_RESULT_ID = #attributes.action_id#
</cfquery>

<cfquery name="GET_INVOICE_NO" datasource="#DSN2#">
	SELECT
		SHIP_NUMBER
	FROM
		SHIP_RESULT_ROW SRR
	WHERE
		SHIP_RESULT_ID = #attributes.action_id#
</cfquery>

<cfquery name="GET_SHIP_RESULT_ROW" datasource="#DSN2#">
	SELECT
		SRR.SHIP_ID,
		SRR.DELIVER_TYPE,
		SRR.DELIVER_ADRESS,
		ORR.PRODUCT_ID AS PRODUCT_ID,
		ORR.PRODUCT_NAME,
		ORR.UNIT,
		ORR.AMOUNT2,
		ST.STOCK_CODE_2 AS STOCK_CODE_2,
		ORR.PRODUCT_NAME,
		ORR.PRODUCT_ID AS PRODUCT_ID
	FROM
		SHIP_RESULT_ROW SRR
		LEFT JOIN #DSN3#.ORDERS_SHIP OS ON OS.SHIP_ID = SRR.SHIP_ID
		LEFT JOIN #DSN3#.ORDER_ROW ORR ON ORR.ORDER_ID = OS.ORDER_ID
		LEFT JOIN #DSN3#.STOCKS ST ON ST.PRODUCT_ID = ORR.PRODUCT_ID
	WHERE
		SHIP_RESULT_ID = #attributes.action_id#
</cfquery>

<!---
<cfquery name="GET_SHIP_RESULT_ROW" datasource="#DSN2#">
	SELECT
		SRR.SHIP_ID,
		SRR.DELIVER_TYPE,
		SRR.DELIVER_ADRESS,
		S_ROW.PRODUCT_ID AS PRODUCT_ID,
		S_ROW.AMOUNT,
		S_ROW.UNIT,
		S_ROW.NAME_PRODUCT,
		ST.STOCK_CODE_2,
		PPD.PROPERTY_DETAIL,
		SRP.SHIP_RESULT_PACKAGE_ID AS PACKAGE_NO,
		SRP.PACKAGE_DIMENTION AS PAKET_BOYUTU,
		SRP.PACKAGE_WEIGHT AS PAKET_AGIRLIGI,
		SL.ITEM AS ENG_UNIT
	FROM
		SHIP_RESULT_ROW SRR
		LEFT JOIN SHIP_ROW S_ROW ON S_ROW.SHIP_ID = SRR.SHIP_ID
		LEFT JOIN #DSN3#.STOCKS ST ON ST.STOCK_ID = S_ROW.STOCK_ID
		LEFT JOIN #DSN1#.PRODUCT_DT_PROPERTIES PDP ON PDP.PRODUCT_ID = S_ROW.PRODUCT_ID
		LEFT JOIN #DSN1#.PRODUCT_PROPERTY_DETAIL PPD ON  PPD.PROPERTY_DETAIL_ID = PDP.VARIATION_ID
		LEFT JOIN SHIP_RESULT_PACKAGE SRP ON SRP.SHIP_ID = SRR.SHIP_RESULT_ID
		LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = S_ROW.UNIT_ID
		LEFT JOIN #DSN#.SETUP_LANGUAGE_INFO SL ON SL.UNIQUE_COLUMN_ID = PU.MAIN_UNIT_ID
	WHERE
		SHIP_RESULT_ID = #attributes.action_id# AND 
		SL.LANGUAGE = 'eng' AND 
		SL.COLUMN_NAME = 'UNIT'
</cfquery>
--->

<cfdocument format="PDF" orientation = "landscape" saveasname="ReportName" pagetype="A4" margintop="0.5" marginbottom="0.5" marginright="1" marginleft="1">
	<tr>
		<td align="left"><cf_get_server_file output_file="../../images/birikim.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/power_xtra.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/panasonic.png" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/saft.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/xtar.jpg" image_height="65" output_server="1" output_type="5"></td>
	</tr>

	<h3 align="center">PACKING LIST</h3>
	<table style="width:100%; font-size:13px;" cellpadding="2" cellspacing="2" border="1px solid-black">
		<tbody>
			<tr>
				<td colspan="4"><cfoutput><b>#CHECK.COMPANY_NAME#</b> <br> #CHECK.ADDRESS#</cfoutput></td>
				<td colspan="6">Date : <cfoutput>#dateformat(GET_SHIP_RESULT.OUT_DATE,"dd/mm/yyyy")# </cfoutput><br>Invoıce Number : <br><cfoutput query="GET_INVOICE_NO">#currentRow#. #SHIP_NUMBER#<br></cfoutput></td>
			</tr>
			<tr>
				<td colspan="4">The consignee/goods owner :</td>
				<td colspan="6">Sendor :</td>
			</tr>
			<tr>
				<td colspan="4"><cfoutput query="GET_SHIP_RESULT"><b>#CONSUMER#</b><br><b>#SENDING_ADDRESS#</b><br><b>#ILCE# / #SEHIR#</b><br><b>#ULKE#</b></cfoutput></td>
				<td colspan="6"><cfoutput query="CHECK"><a>#COMPANY_NAME#</a><br><a>Address: #ADDRESS#</a><br><a>Tax Office : #TAX_OFFICE#</a><br><a>Tax No : #TAX_NO#</a></cfoutput></td>
			</tr>
			<tr>
				<td align="center">Item No</td>
				<td align="center">GTIP No</td>
				<td align="center">Stock Code No</td>
				<td align="center">Stock Description</td>
				<td align="center">Quantity</td>
				<td align="center">Unit</td>
				<td align="center">Weight Details in gr</td>
				<td align="center">Total Net Weight (gr)</td>
				<td align="center">Total Gross Weight (gr)</td>
				<td align="center">Pallet No</td>
			</tr>
			<cfoutput query="GET_SHIP_RESULT_ROW">
				<tr>
					<td align="center">#currentRow#</td>
					<td></td>
					<td>#STOCK_CODE_2#</td>
					<td>#PRODUCT_NAME#</td>
					<td align="center">#AMOUNT2#</td>
					<td align="center">#UNIT#</td>
						<cfquery name="GET_PROPERTY" datasource="#DSN1#">
							SELECT
								PDP.VARIATION_ID,
								PDP.DETAIL,
								PDP.IS_EXIT,
								PDP.TOTAL_MIN,
								PDP.TOTAL_MAX,
								PDP.AMOUNT,
								PDP.RECORD_DATE,
								PDP.RECORD_EMP,
								PDP.UPDATE_EMP,
								PDP.UPDATE_DATE,
								PDP.IS_OPTIONAL,
								PDP.IS_INTERNET,
								PDP.LINE_VALUE,
								PDP.PROPERTY_ID,
								PP.PROPERTY,
								PPD.PRPT_ID,
								PPD.PROPERTY_DETAIL_ID, 
								PPD.PROPERTY_DETAIL
							FROM
								PRODUCT_DT_PROPERTIES PDP
								LEFT JOIN PRODUCT_PROPERTY PP ON PDP.PROPERTY_ID = PP.PROPERTY_ID
								LEFT JOIN PRODUCT_PROPERTY_DETAIL PPD ON PDP.VARIATION_ID =PPD.PROPERTY_DETAIL_ID
							WHERE
								PDP.PROPERTY_ID = 318 <!--- ağırlık özelliği için id --->
								AND PDP.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#PRODUCT_ID#"> 
							ORDER BY LINE_VALUE    
						</cfquery>
						<cfscript>
							str = GET_PROPERTY.PROPERTY_DETAIL;
							weight = REReplace("#str#","gr| gr |GR| GR |GR ","","ALL");
							amount = AMOUNT2;
						</cfscript>
					<td align="center">
						<cfloop query="GET_PROPERTY">
							#weight#
						</cfloop>
					</td>
					<td align="center">-</td>
					<td></td>
					<td align="center">-</td>
				</tr>
			</cfoutput>
			<tr>
				<td colspan="4"></td>
				<td colspan="3" align="center"><b>TOTAL<b></td>
				<td><b>Total Net Weight</b></td>
				<td><b>Total Gross Weigh</b></td>
				<td></td>
			</tr>
		</tbody>
	</table>


</cfdocument>

<!---
	<cfdocument format="PDF" orientation = "landscape" saveasname="ReportName" pagetype="A4" margintop="0.5" marginbottom="0.5" marginright="1" marginleft="1">
	<tr>
		<td align="left"><cf_get_server_file output_file="../../images/birikim.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/power_xtra.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/panasonic.png" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/saft.jpg" image_height="65" output_server="1" output_type="5"></td>
		<td align="left"><cf_get_server_file output_file="../../images/xtar.jpg" image_height="65" output_server="1" output_type="5"></td>
	</tr>

	<h3 align="center">PACKING LIST</h3>
	<table style="width:100%; font-size:13px;" cellpadding="2" cellspacing="2" border="1px solid-black">
		<tbody>
			<tr>
				<td colspan="4"><cfoutput><b>#CHECK.COMPANY_NAME#</b> <br> #CHECK.ADDRESS#</cfoutput></td>
				<td colspan="6">Date : <cfoutput>#dateformat(GET_SHIP_RESULT.OUT_DATE,"dd/mm/yyyy")# </cfoutput><br>Invoıce Number : <br><cfoutput query="GET_INVOICE_NO">#currentRow#. #SHIP_NUMBER#<br></cfoutput></td>
			</tr>
			<tr>
				<td colspan="4">The consignee/goods owner :</td>
				<td colspan="6">Sendor :</td>
			</tr>
			<tr>
				<td colspan="4"><cfoutput query="GET_SHIP_RESULT"><b>#CONSUMER#</b><br><b>#SENDING_ADDRESS#</b><br><b>#ILCE# / #SEHIR#</b><br><b>#ULKE#</b></cfoutput></td>
				<td colspan="6"><cfoutput query="CHECK"><a>#COMPANY_NAME#</a><br><a>Address: #ADDRESS#</a><br><a>Tax Office : #TAX_OFFICE#</a><br><a>Tax No : #TAX_NO#</a></cfoutput></td>
			</tr>
			<tr>
				<td align="center">Item No</td>
				<td align="center">GTIP No</td>
				<td align="center">Stock Code No</td>
				<td align="center">Stock Description</td>
				<td align="center">Quantitiy</td>
				<td align="center">Unit</td>
				<td align="center">Weight Details in gr</td>
				<td align="center">Total Net Weight (gr)</td>
				<td align="center">Total Gross Weight (gr)</td>
				<td align="center">Pallet No</td>
			</tr>
			<cfoutput query="GET_SHIP_RESULT_ROW">
				<tr>
					<td>#currentRow	#</td>
					<td></td>
					<td>#STOCK_CODE_2#</td>
					<td>
						<cfquery name="GET_ENG_PRODUCT_NAME" datasource="#DSN#">
						  SELECT
							ITEM
						  FROM
							SETUP_LANGUAGE_INFO
						  WHERE
							COLUMN_NAME = 'PRODUCT_NAME' AND
							TABLE_NAME = 'PRODUCT' AND
							LANGUAGE = 'ENG' AND
							UNIQUE_COLUMN_ID = #PRODUCT_ID#
						</cfquery>
						<cfoutput>#GET_ENG_PRODUCT_NAME.ITEM#</cfoutput>
					  </br><!---<b><p style="color:red">#DETAIL_INFO_EXTRA#</p></b>--->
					</td> <!--- Ürün adı ve satır altı açıklama --->
					<td>#AMOUNT2#</td>
					<td>#UNIT#</td>
					<td></td>
					<td></td>
					<td></td>
					<td align="center">#PACKAGE_NO#</td>
				</tr>
			</cfoutput>
			<tr>
				<td colspan="4"></td>
				<td colspan="3" align="center"><b>TOTAL<b></td>
				<td><b>Total Net Weight</b></td>
				<td><b>Total Gross Weigh</b></td>
				<td></td>
			</tr>
		</tbody>
	</table>


</cfdocument>
--->