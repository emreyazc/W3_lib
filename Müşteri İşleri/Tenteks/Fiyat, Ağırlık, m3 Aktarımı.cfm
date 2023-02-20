<cfquery name="GET_OFFER_ROW" datasource="#DSN3#">
	SELECT
		PRODUCT_ID,
		PRODUCT_NAME,
		NEW_PRODUCT_PROPERTY_DETAILS
	FROM
		OFFER_ROW
	WHERE
		OFFER_ID = 75
		AND
		NEW_PRODUCT_PROPERTY_DETAILS IS NOT NULL
</cfquery>

<cfloop query="#GET_OFFER_ROW#">
	<cfdump var="#PRODUCT_NAME#">
	<cfquery name="GET_PROPERTY_DETAILS" datasource="#DSN1#">
		SELECT
			PROPERTY_DETAIL_ID,
			PROPERTY_DETAIL
		FROM
			PRODUCT_PROPERTY_DETAIL 
		WHERE
			PROPERTY_DETAIL_ID IN (<cfqueryparam value="#GET_OFFER_ROW.NEW_PRODUCT_PROPERTY_DETAILS#" cfsqltype="CF_SQL_INTEGER"list="yes"/>)
	</cfquery>
	<cfdump var="#get_property_details#">
</cfloop>


<!---
<cfspreadsheet action="read" src="fiyat_listesi_import.xlsx" query="qData" columns="1,2,3,4,5,6,7"/>


<cfoutput query="qData" startrow="2">
	<cfset fiyat = reReplace(col_3,",",".","ALL")>
	<cfset metre_kup = reReplace(col_5,",",".","ALL")>
	<cfset agirlik = reReplace(col_6,",",".","ALL")>
	<cfscript>
		product_id = col_1;
		stock_id = col_2;
		doviz = 'EUR';
		redzone = col_7;
	</cfscript>

	<!---
	#product_id#
	#stock_id#
	#fiyat#
	#doviz#
	#metre_kup#
	#agirlik#
	#redzone#
	<br>
	--->
<!---
<cfquery name="INSERT" datasource="#DSN1#">
	INSERT INTO 
		CURRENT_MATERIAL_PRICE 
			(PRODUCT_ID, STOCK_ID, CURRENT_PRICE, MONEY, IS_REDZONE, CUBIC_METER, WEIGHT, NUMBER_OF_RAIL, IS_IMPORT, IS_ACTIVE)
		VALUES 
			(#product_id#, #stock_id#, #fiyat#, '#doviz#', #redzone#, #metre_kup#, #agirlik#, 0, 1, 1)
	</cfquery>
--->
</cfoutput>
--->
