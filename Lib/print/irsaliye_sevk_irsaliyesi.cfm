<!--- stok depolararası sevk irsaliyesi print şablonu --->
<cfset attributes.ship_id = attributes.action_id> 

<cfquery name="Ship" datasource="#dsn2#">
	SELECT
		SHIP.*,
		#dsn_alias#.DEPARTMENT.DEPARTMENT_HEAD,
		C.FULLNAME,
		SM.SHIP_METHOD AS SHIP_METHOD_
	FROM
		SHIP
		LEFT JOIN #dsn3_alias#.PRODUCTION_ORDERS PO ON SHIP.PROD_ORDER_NUMBER = PO.P_ORDER_ID
		LEFT JOIN #dsn3_alias#.PRODUCTION_ORDERS_ROW POR ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
		LEFT JOIN #dsn3_alias#.ORDERS O ON POR.ORDER_ID = O.ORDER_ID
		LEFT JOIN #DSN#.SHIP_METHOD SM ON SM.SHIP_METHOD_ID =  SHIP.SHIP_METHOD
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
<cfdocument  format="PDF" pagetype="A5">
	<div class="css4">
		<div>
			<table border="2" style="height:135mm; width:100mm; font-size:11px">
				<cfoutput>
					<tbody>
						<tr rowspan="2" style="font-size:16px">
							<td style="width:25%" align="center"><b>SEVK TARİHİ</b></td>
							<td style="width:25%" align="center"><b>#dateformat(SHIP.ship_date,dateformat_style)#</b></td>
							<td style="width:25%" align="center"><b>İRSALİYE NO</b></td>
							<td style="width:25%;" align="center"><b>#Ship.Ship_Number#</b><!---<cf_barcode type="EAN13" barcode="#INVOICE_NUMBER#" extra_height="0"><cfif len(errors)><cfoutput>#errors#</cfoutput></cfif>---></td>
						</tr>
						<tr>
							<th colspan="4" align="center" style="font-size:20px"><b>ÇIKIŞ DEPO</b></th>
						</tr>
						<tr>
							<td colspan="4"><b style="font-size:20px">#Get_Name_Of_Dep_Cikis.Branch_Name#</b>-
								<cfif len(Ship.Deliver_Store_Id) and len(Ship.Location)>
									<cfquery name="Get_Out_Location" datasource="#dsn#">
										SELECT COMMENT FROM STOCKS_LOCATION WHERE LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Location#"> AND DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Deliver_Store_Id#">
									</cfquery>
									<b style="font-size:20px">#Get_Out_Location.Comment#</b>
								</cfif>
							</td>
						</tr>	
						<tr>
							<th colspan="4" align="center" style="font-size:20px"><b>GİRİŞ DEPO</b></th>
						</tr>
						<tr>
							<td colspan="4">
								<cfif len(Ship.Department_In) and len(Ship.Location_In)>
                                <cfquery name="Get_In_Location" datasource="#dsn#">
                                    SELECT COMMENT FROM STOCKS_LOCATION WHERE LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Location_In#"> AND DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Ship.Department_In#">
                                </cfquery>
                                <b style="font-size:20px">#Get_In_Location.Comment#</b>
                                </cfif>
							</td>
						</tr>
						<tr>
							<td colspan="4" style="font-size:20px"><b>ADRES : #Get_Name_Of_Dep_Giris.Branch_Address# #Get_Name_Of_Dep_Giris.Branch_County# #Get_Name_Of_Dep_Giris.Branch_City#</b></td>
						</tr>
						<!---
						<tr>
							<td colspan="4"><b>Teslim Alan : </b><cfif len(ship.deliver_emp)></cfif>#ship.deliver_emp#</td>
						</tr>
						--->
					</tbody>
				</cfoutput>
			</table>
		</div>
	</div>
</cfdocument>