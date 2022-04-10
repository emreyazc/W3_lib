<!---
	Date : 08.03.2022
	Desc : COC Belgesi 
	Dev : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>

	<cfquery name="GET_INVOICE" datasource="#DSN2#">
		SELECT
			I.*,
			C.FULLNAME,
			SC.CITY_NAME,
			SCO.COUNTY_NAME,
			E.EMPLOYEE_NAME,
			E.EMPLOYEE_SURNAME
		FROM
			INVOICE I
			LEFT JOIN #DSN#.COMPANY C ON C.COMPANY_ID = I.COMPANY_ID
			LEFT JOIN #DSN#.SETUP_CITY SC ON SC.CITY_ID = C.CITY
			LEFT JOIN #DSN#.SETUP_COUNTY SCO ON SCO.COUNTY_ID = C.COUNTY
			LEFT JOIN #DSN#.EMPLOYEES E ON E.EMPLOYEE_ID = I.SALE_EMP
		WHERE
			INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
	</cfquery>
	
	<cfquery name="GET_INVOICE_ROW" datasource="#DSN2#">
		SELECT
			IR.*,
			P.*
		FROM
			INVOICE_ROW IR
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = IR.PRODUCT_ID
		WHERE
			INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
	</cfquery>

	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME2 FROM OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfif len(get_comp_addr.ASSET_FILE_NAME2)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

	 <cfdocument  format="PDF" pageType="A4" marginBottom="4">
		<table style="width:220mm" border="1">
			<tbody>
				<tr>
					<td style="width:50%" rowspan="2">
						<table style="width:100%">
							<tr>
								<td>
									<img border="0" src="https://erp.birikimpilleri.com:443/<cfoutput>#attributes.mail_logo#</cfoutput>"/>
								</td>
								<td style="font-size:13px">
									<cfoutput><b>#GET_COMP_ADDR.COMPANY_NAME#</b><br>#GET_COMP_ADDR.ADDRESS#<br>Tel : #GET_COMP_ADDR.TEL_CODE# #GET_COMP_ADDR.TEL#</cfoutput>
								</td>
							</tr>
						</table>
					</td>
					<td style="width:50%">
						<table style="width:100%">
							<tr>
								<td style="width:70%">Evrak Numarası</td>
								<td style="width:30%" rowspan="2"><cfoutput>#GET_INVOICE.INVOICE_ID#</cfoutput></td>
							</tr>
							
							<tr>
								<td>Document No</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td style="width:50%">
						<table style="width:100%">
							<tr>
								<td style="width:70%">Sayfa Numarası</td>
								<td style="width:30%" rowspan="2">1</td>
							</tr>
							
							<tr>
								<td>Page No</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td style="width:50%">
						<table style="width:100%">
							<tr>
								<td></td>
								<td rowspan="3" style="width:50%"><cfoutput>#GET_INVOICE.FULLNAME#</cfoutput></td>
							</tr>
							<tr>
								<td rowspan="3" style="width:20%"><b>Müşteri</b> <br><i>Client</i></td>
								<td></td>
							</tr>
							<tr>
								<td rowspan="3" style="width:30%"><cfoutput>#GET_INVOICE.SHIP_ADDRESS#</cfoutput></td>
								<td></td>
							</tr>
							<tr>
								<td colspan="2">
									<cfoutput>#GET_INVOICE.COUNTY_NAME# / #GET_INVOICE.CITY_NAME#</cfoutput>
								</td>
							</tr>
						</table>
					</td>
					<td rowspan="2">
						<table style="width:100%">
							<tr>
								<td></td>
							</tr>
							<tr align="center">
								<td>UYGUNLUK BEYANI <br> <b><i>DECLARATION OF CONFORMITY</i></b></td>
							</tr>
							<tr>
								<td></td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<table style="width:100%">
							<tr>
								<td style="width:50%">Emir No</td>
								<td style="width:50%" rowspan="2"><cfoutput>#GET_INVOICE.INVOICE_NUMBER#</cfoutput></td>
							</tr>
							<tr>
								<td>Commande No</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td>
						<table style="width:100%">
							<tr>
								<td style="width:50%">Sipariş No</td>
								<td rowspan="2" style="width:50%"><cfoutput>#GET_INVOICE.REF_NO#</cfoutput></td>
							</tr>
							<tr>
								<td>Contrat No</td>
							</tr>
						</table>
					</td>
					<td rowspan="2">
						<table style="width:100%">
							<tr>
								<td style="width:50%">Teslimat Tarihi</td>
								<td><cfoutput>#dateformat(GET_INVOICE.INVOICE_DATE,dateformat_style)#</cfoutput></td>
							</tr>
						</table>
					</td>
				</tr>
			</tbody>
		</table>
	
		<table style="width:220mm" border="1">
			<tr>
				<td style="width:5%" align="center">No</td>
				<td style="width:20%" align="center"><b>Referans</b><br> Referance </td>
				<td style="width:55%" align="center"><b>Ürün Detayları</b><br>Product Details</td>
				<td style="width:20%" align="center"><b>Ürün Kodu</b><br> Product Code</td>
				<td style="width:5%" align="center"><b>Adet</b><br>Quantity</td>
			</tr>
			<tr>
				<td colspan="5">
					<hr> 
				</td>
			</tr>
			<cfoutput query="GET_INVOICE_ROW">
				<tr>
					<td align="center">#currentRow#.</td>
					<td align="center">#PRODUCT_CODE_2#</td>
					<td align="center">#NAME_PRODUCT#</td>
					<td align="center">#PRODUCT_CODE#</td>
					<td align="center">#AMOUNT# #UNIT#</td>
				</tr>
			</cfoutput>
		</table>
		
		<cfdocumentitem  type="footer" evalprint="false">
			<table style="width:220mm" border="1">
				<tr>
					<td>
						<b><i>Satışı gerçekleştirilen ürünlerin belirtilen ihtiyaçlara uygunluğu, tamamlanan testler ve gözlem neticesinde bütün standart ve regülasyonlar nezdinde sağlanmıştır.</i></b>
						<br>
						<i>We herebydeclare, barring exceptions, reservations, or exemptions listed in this statement of conformity, that the listed supplies comply with the contrat requirement and that, after completion of testing and verification, they completely satisfy all specifed requirement, and applicable standards and regulations.</i>
					</td>
				</tr>
				<tr>
					<td>
						<b><i>Teslim alınan ürünler ile ilgili</i></b>
						<br>
						<i>Information particular to the supplies</i>
						<br>
						<b><i>Teslim alınan ürünlerin faturası</i></b>
						<br>
						<i>Specify the reference of concessions</i>
					</td>
				</tr>
			</table>
			<table style="width:220mm" style="border:1px solid black">
				<tr align="center">
					<td colspan="3">Satışı Gerçekleştiren / / Supplier quality manager/ Supplier Quality Manager</td>
				</tr>
				<tr>
					<td><b>İsim - Soyisim</b><br><i>Name - Surname</i></td> 
					<td><cfoutput>#GET_INVOICE.EMPLOYEE_NAME# #GET_INVOICE.EMPLOYEE_SURNAME#</cfoutput></td>
					<td><b>İmza</b><br><i>Signature</i></td>
				</tr>
				<tr>
					<td><b>Tarih</b><br><i>Date</i></td> 
					<td><cfoutput>#dateformat(GET_INVOICE.INVOICE_DATE,dateformat_style)#</cfoutput></td>
					<td>
						<cfquery name="GET_EMPLOYEE_ASSET" datasource="#DSN#">
							SELECT TOP 1
							  ASSET_FILE
							FROM
							  EMPLOYEE_EMPLOYMENT_ROWS
							WHERE
							  EMPLOYEE_ID = #GET_INVOICE.SALE_EMP#
							  AND ASSET_CAT_ID = 30
						</cfquery>
						<cfif len(GET_EMPLOYEE_ASSET.ASSET_FILE)>
							<!---
							<cf_get_server_file output_file="hr/#GET_EMPLOYEE_ASSET.ASSET_FILE#" output_server="#3#" output_type="5" image_width="100">
							--->
							<cfif len(GET_EMPLOYEE_ASSET.ASSET_FILE)>
							  <cfset myImage=ImageRead("../../documents/hr/#GET_EMPLOYEE_ASSET.ASSET_FILE#")>
							  <cfset ImageResize(myImage,"20%","","blackman",1)>
							  <cfimage source="#myImage#" action="writeToBrowser">
							</cfif>
							<!---
							<cfscript>
							  TextCharacteristics = { size="20", style="bold", strikethrough="false", underline="false"};
							  imgObj = imageNew("",152,152,"rgb","red");
							  text = "#get_emp_info(get_action_detail.revenue_collector_id,0,0)#";
							  imgObj.drawText("CFDocs",20,50,TextCharacteristics);
							  cfimage (action="writeToBrowser", source=imgObj);
							</cfscript>
							--->
							<cfelse>
							&nbsp;
						</cfif>
					</td>
				</tr>
			</table>

			<table style="width:220mm" style="border:1px solid black">
			
				<cfquery name="SESSION_EMP" datasource="#DSN#">
					SELECT
						EMPLOYEE_ID,
						EMPLOYEE_NAME,
						EMPLOYEE_SURNAME
					FROM
						EMPLOYEES
					WHERE
						EMPLOYEE_ID = #session.ep.userid#
				</cfquery>
	
				<tr align="center">
					<td colspan="3">Kontrol yapan / Inspection Body Only</td>
				</tr>
				<tr>
					<td><b>İsim - Soyisim</b><br><i>Name - Surname</i></td> 
					<td><cfoutput>#SESSION_EMP.EMPLOYEE_NAME# #SESSION_EMP.EMPLOYEE_SURNAME#</cfoutput></td>
					<td><b>İmza</b><br><i>Signature</i></td>
				</tr>
				<tr>
					<td><b>Tarih</b><br><i>Date</i></td> 
					<td><cfoutput>#dateformat(GET_INVOICE.INVOICE_DATE,dateformat_style)#</cfoutput></td>
					<td>
						<cfquery name="GET_EMPLOYEE_ASSET_SESSION" datasource="#DSN#">
							SELECT TOP 1
							  ASSET_FILE
							FROM
							  EMPLOYEE_EMPLOYMENT_ROWS
							WHERE
							  EMPLOYEE_ID = #SESSION_EMP.EMPLOYEE_ID#
							  AND ASSET_CAT_ID = 30
						</cfquery>
	
						<cfif len(GET_EMPLOYEE_ASSET_SESSION.ASSET_FILE)>
							<!---
							<cf_get_server_file output_file="hr/#GET_EMPLOYEE_ASSET.ASSET_FILE#" output_server="#3#" output_type="5" image_width="100">
							--->
							<cfif len(GET_EMPLOYEE_ASSET_SESSION.ASSET_FILE)>
							  <cfset myImage=ImageRead("../../documents/hr/#GET_EMPLOYEE_ASSET_SESSION.ASSET_FILE#")>
							  <cfset ImageResize(myImage,"20%","","blackman",1)>
							  <cfimage source="#myImage#" action="writeToBrowser">
							</cfif>
							<!---
							<cfscript>
							  TextCharacteristics = { size="20", style="bold", strikethrough="false", underline="false"};
							  imgObj = imageNew("",152,152,"rgb","red");
							  text = "#get_emp_info(get_action_detail.revenue_collector_id,0,0)#";
							  imgObj.drawText("CFDocs",20,50,TextCharacteristics);
							  cfimage (action="writeToBrowser", source=imgObj);
							</cfscript>
							--->
							<cfelse>
							&nbsp;
						</cfif>
					</td>
				</tr>
			</table>
		</cfdocumentitem>
	 </cfdocument>
</cfif>