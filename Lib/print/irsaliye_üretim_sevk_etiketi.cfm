<!---
	Date : 03.01.2022
	Desc : Üretimden depoya gidecek ürünler içindir.
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->
<cfset attributes.ship_id = attributes.action_id> 

<cfquery name="Ship" datasource="#dsn2#">
	SELECT
		SHIP.*,
		#dsn_alias#.DEPARTMENT.DEPARTMENT_HEAD,
		C.FULLNAME
	FROM
		SHIP
		LEFT JOIN #dsn3_alias#.PRODUCTION_ORDERS PO ON SHIP.PROD_ORDER_NUMBER = PO.P_ORDER_ID
		LEFT JOIN #dsn3_alias#.PRODUCTION_ORDERS_ROW POR ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
		LEFT JOIN #dsn3_alias#.ORDERS O ON POR.ORDER_ID = O.ORDER_ID
		LEFT JOIN #dsn_alias#.COMPANY C ON O.COMPANY_ID = C.COMPANY_ID,		
		#dsn_alias#.DEPARTMENT
	WHERE
		SHIP.SHIP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_id#"> AND
		#dsn_alias#.DEPARTMENT.DEPARTMENT_ID = SHIP.DELIVER_STORE_ID
</cfquery>
<cfif Ship.Ship_Type neq 81>
	<script type="text/javascript">
		alert("Belge tipi uygun değil!");
	</script>
	<cfexit method="exittemplate">
</cfif>
<cfquery name="Get_Ship_Row" datasource="#dsn2#">
	SELECT 
		PRODUCT_ID,
        NAME_PRODUCT,
        AMOUNT,
        UNIT,
        NETTOTAL,
        PRICE,
        DISCOUNT,
        TAX
	FROM 
		SHIP_ROW
	WHERE 
		SHIP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.ship_id#">
	ORDER BY
		SHIP_ROW_ID
</cfquery>
<cfquery name="Get_My_Company" datasource="#dsn#">
	SELECT COMPANY_NAME,ADDRESS	FROM OUR_COMPANY WHERE COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>
<cfquery name="Get_Name_Of_Dep_Giris" datasource="#dsn#">
	SELECT 
		D.DEPARTMENT_HEAD,
		B.BRANCH_NAME,
		B.BRANCH_ADDRESS,
		B.BRANCH_COUNTY,
		B.BRANCH_CITY 
	FROM 
		DEPARTMENT D,
		BRANCH B 
	WHERE 
		D.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Department_In#"> AND 
		D.BRANCH_ID = B.BRANCH_ID AND 
		D.IS_STORE <> 2
</cfquery>
<cfquery name="Get_Name_Of_Dep_Cikis" datasource="#dsn#">
	SELECT 
		D.DEPARTMENT_HEAD,
		B.BRANCH_NAME,
		B.BRANCH_ADDRESS,
		B.BRANCH_COUNTY,
		B.BRANCH_CITY 
	FROM 
		DEPARTMENT D,
		BRANCH B 
	WHERE 
		D.DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Deliver_Store_Id#"> AND 
		D.BRANCH_ID = B.BRANCH_ID AND 
		D.IS_STORE <> 2
</cfquery>
<cfquery name="CHECK" datasource="#DSN#">
	SELECT 
		ASSET_FILE_NAME2,
		ASSET_FILE_NAME2_SERVER_ID,
	    COMPANY_NAME
	FROM 
		OUR_COMPANY 
	WHERE 
		COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
</cfquery>

<link rel="stylesheet" href="/css/assets/template/catalyst/print.css" type="text/css">

<cfdocument  format="PDF" pagetype="A5">
	<table style="width:100mm; height:120mm" border="1px">
		<tbody>
			<tr>
				<td style="font-size:20px"><b>SİPARİŞ NO</b></td>
				<td style="font-size:20px"><b><cfoutput>#SHIP.REF_NO#</cfoutput></b></td>
			</tr>
			<tr>
				<td style="font-size:20px"><b>ÜRÜN</b></td>
				<td style="font-size:20px"><b><cfoutput query="GET_SHIP_ROW">#NAME_PRODUCT#</cfoutput></b></td>
			</tr>
			<tr>
				<td style="font-size:20px"><b>ÜRÜN MİKTARI</b></td>
				<td style="font-size:20px"><b><cfoutput query="GET_SHIP_ROW">#AMOUNT#</cfoutput></b></td>
			</tr>
			<tr>
				<td style="font-size:20px"><b>REFERANS</b></td>
				<td style="font-size:20px"><b><cfoutput>#Ship.FULLNAME#</cfoutput></b></td>
			</tr>
		</tbody>
	</table>
	<table style="width:100mm; height:15mm">
		<tbody>
			<tr>
				<td>
					<cfoutput><b>#Ship.Ship_Number#</b></cfoutput>
				</td>
			</tr>
		</tbody>
	</table>
</cfdocument>
<!---
<table style="width:100mm">
	<tr class="fixed">
		<td style="font-size:9px!important;"><b><cf_get_lang dictionary_id='61710.© Copyright'></b> <cfoutput>#check.COMPANY_NAME#</cfoutput> <cf_get_lang dictionary_id='61711.dışında kullanılamaz, paylaşılamaz.'></td>
	</tr>
</table>
--->

