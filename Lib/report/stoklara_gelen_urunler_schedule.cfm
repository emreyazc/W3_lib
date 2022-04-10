<!---
    Date : 08.03.2022
    Desc : Stoklara eklenen ürünlerin listesini her sabah ilgili departmanlara mail gönderir.
    Dev : Yunus Emre Yazıcı - Birikim Pilleri
--->


	<cfquery name="GET_EMP_EMAIL" datasource="#DSN#">
		SELECT
			EMPLOYEE_EMAIL
		FROM
			EMPLOYEES
		WHERE
			EMPLOYEE_STATUS = 1
			AND EMPLOYEE_EMAIL IS NOT NULL
	</cfquery>

	<!---
	<cfquery name="GET_DAILY_STOCKS_IN" datasource="#DSN2#">
		SELECT
			P.PRODUCT_NAME,
			P.BARCOD AS BARKOD,
			/*
			SR.STOCK_ID,
			*/
			SUM(SR.STOCK_IN) AS ADET,
			S.STOCK_CODE AS STOK_KODU,
			S.STOCK_CODE_2 AS OZEL_KOD,
			PU.MAIN_UNIT AS BIRIM,
			PC.PRODUCT_CAT,
			PC.HIERARCHY,
			PI.PATH
		FROM
			STOCKS_ROW SR
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = SR.PRODUCT_ID
			LEFT JOIN #DSN3#.STOCKS S ON S.STOCK_ID = SR.STOCK_ID
			LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_ID = SR.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT PR ON PR.PRODUCT_ID = SR.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = PR.PRODUCT_CATID
			LEFT JOIN #DSN1#.PRODUCT_IMAGES PI ON PI.PRODUCT_ID = PR.PRODUCT_ID
		WHERE
			SR.PROCESS_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-1,now()))#">
			AND SR.STORE_LOCATION = 1
		 	AND SR.STORE = 62
			AND SR.STOCK_OUT = 0
			AND PU.IS_MAIN = 1
			AND PI.IS_COVER = 1
			AND P.IS_SALES = 1
		GROUP BY
			/*
			SR.STOCK_ID,
			*/
			P.PRODUCT_NAME,
			P.BARCOD,
			S.STOCK_CODE,
			S.STOCK_CODE_2,
			PU.MAIN_UNIT,
			PC.PRODUCT_CAT,
			PC.HIERARCHY,
			PI.PATH
		ORDER BY
			P.PRODUCT_NAME ASC
	</cfquery>
	--->

	<cfquery name="GET_DAILY_STOCKS_IN" datasource="#DSN2#">
		SELECT
			S.SHIP_NUMBER,
			SR.NAME_PRODUCT,
			SR.AMOUNT,
			SR.UNIT,
			ST.STOCK_CODE AS STOK_KODU,
			ST.STOCK_CODE_2 AS OZEL_KOD,
			PI.PATH,
			PC.PRODUCT_CAT,
			PC.HIERARCHY,
			P.BARCOD AS BARKOD
		FROM
			SHIP S
			LEFT JOIN SHIP_ROW SR ON SR.SHIP_ID = S.SHIP_ID
			LEFT JOIN #DSN3#.STOCKS ST ON ST.STOCK_ID = SR.STOCK_ID
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = SR.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
			LEFT JOIN #DSN1#.PRODUCT_IMAGES PI ON PI.PRODUCT_ID = P.PRODUCT_ID
		WHERE
			S.SHIP_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-2,now()))#">
			AND S.SHIP_TYPE = 76
			AND PI.IS_COVER = 1
	</cfquery>

	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME1 FROM OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfif len(get_comp_addr.ASSET_FILE_NAME1)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name1>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

<cfdump var="#GET_DAILY_STOCKS_IN#">

<cfif GET_DAILY_STOCKS_IN.recordCount neq 0>
	<cfdocument format="pdf" marginTop = "2" marginBottom = "2" name="pdfoutput">
		<cfdocumentitem type="header" evalatprint="true">
			<table border="0" id="main_table" class="table" style="width:100%; height:30%">
				<tr>
					<td align="left" rowspan="2">
						&nbsp;
						<br>
						<cfoutput><img style="height:70" border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></cfoutput>
						<br>
						&nbsp;
					</td>
					<td align="center"><b>Gelen Ürün Listesi</b></td>
				</tr>
				<tr>
					<td align="right"><cfoutput><b>#dateformat(now(),"dd / mm / yyyy")#</b></cfoutput></td>
				</tr>
			</table>
		</cfdocumentitem>
		<cfdocumentitem type= "footer">
			<table class="table" style="width:100%; border:1px solid black">
				<tr align="center">
					<td><b><cfoutput>#dateformat(now(),dateformat_style)#</cfoutput></b></td>
					<td><b>www.birikimpilleri.com</b></td>
					<td><b>Sayfa No : <cfoutput>#cfdocument.currentpagenumber#</cfoutput></b></td>
				</tr>
			</table>
		</cfdocumentitem>
		<cfdocumentsection>
	
			<h3 align="center"><cfoutput>#dateformat(now(),dateformat_style)# - GELEN ÜRÜN LİSTESİ</cfoutput></h3>
	
			<cfoutput query="GET_DAILY_STOCKS_IN">
				<!---
				<table class="table" border="1" cellspacing="0" cellpadding="3" style="width:100%">
					<tbody>
						<tr style="width:100%; font-size:14px">
							<td align="center" style="width:15%"><b style="font-size:40px">#currentRow#</b></td>
							<td style="width:55%">
								<table class="table" border="0" style="width:100%">
									<tr>
										<td>
											<b style="font-size:30px">#OZEL_KOD#</b>
										</td>
									</tr>
									<tr>
										<td>
											<b style="font-size:14px">#NAME_PRODUCT#</b>
										</td>
									</tr>
									<tr>
										<td>
											<a style="font-size:14px">#PRODUCT_CAT#</a>
										</td>
									</tr>
								</table>
							</td>
							<td style="width:30%" align="center" rowspan="4">
								<cf_get_server_file output_file="../../documents/product/#PATH#" image_width="200" output_server="1" output_type="5">
							</td>
						</tr>
						<tr align="center">
							<td><b>Stok Kodu</b></td>
							<td><b>Barkodu</b></td>
						</tr>
						<tr align="center">
							<td>
								&nbsp;
								<br>
								<cf_workcube_barcode show="1" type="code39" width="200" height="25" value="#OZEL_KOD#"><br>
								<a style="font-size:14px">#OZEL_KOD#</a>
								<br>
								&nbsp;
							</td>
							<td>
								&nbsp;
								<br>
								<cf_workcube_barcode show="1" type="code39" width="200" height="25" value="#BARKOD#"><br>
								<a style="font-size:14px">#BARKOD#</a>
								<br>
								&nbsp;
							</td>
							<!---
							<td><cf_barcode type="code39" barcode="#BARKOD#" extra_height="0"></td>
							<td><cf_barcode type="code39" barcode="#BARKOD#" extra_height="0"></td>
							--->
						</tr>
						<!---
						<tr>
							<td colspan="2"><a style="color:red">Detaylar İçin Link : </a></td>
						</tr>
						--->
					</tbody>
				</table>
				--->
	
				<table border="1" cellspacing="0" cellpadding="3" style="width:100%; height:30%">
					<tbody>
						<tr>
							<td width="10%" align="center">
							  <h1>#currentRow#</h1>
							</td>
							<td>
							<table>
								<tr>
									<td>
										<h2>#OZEL_KOD#</h2>
									</td>
								</tr>
								<tr>
									<td><b style="font-size:14px">#NAME_PRODUCT#</b></td>
								</tr>
								<tr>
									<td><a style="font-size:14px">#PRODUCT_CAT# - #HIERARCHY#</a></td>
								</tr>
						  </table>
							</td>
							<td rowspan="3">
								<cf_get_server_file output_file="../../documents/product/#PATH#" image_width="300" output_server="1" output_type="5">
							</td>
						</tr>
						<tr>
							<td colspan="2" border="0">
								<table cellspacing="0" cellpadding="3" style="width:100%">
									<tr align="center" height="20%">
										<td width="50%">
											<b style="font-size:14px">Stok Kodu</b>
										</td>
										<td width="50%">
											<b style="font-size:14px">Barkodu</b>
										</td>
									</tr>
									<tr align="center" width="50%" height="80%">
										<td>
											<cf_workcube_barcode show="1" type="code39" width="200" height="25" value="#OZEL_KOD#"><br>
											<a style="font-size:14px">#OZEL_KOD#</a>
										</td>
										<td>
											<cf_workcube_barcode show="1" type="code39" width="200" height="25" value="#BARKOD#"><br>
											<a style="font-size:14px">#BARKOD#</a>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr height="5%" align="left">
							<td colspan="2"><a style="font-size:13px; color:red">Detaylar İçin Link : </a></td>
						</tr>
					</tbody>
				</table>
	
				<!---
				<cfif currentRow%2 eq 0>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
				</cfif>
				--->
			</cfoutput>
	
		</cfdocumentsection>
	</cfdocument>
	
	
	<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
	<cfset to_mail="yunusemreyazici@birikimpilleri.com">
	
	<cfmail from="#from_mail#" to="#to_mail#" subject="Gelen Ürün Listesi" type="html" charset="utf-8">
		<html>
			<body>
				<p>Ekte bulunan PDF deki ürünler stoklara gelmiştir.</p><br>
				<p>İyi çalışmalar.</p>
				<cfmailparam file="gelen_urunler#dateformat(now(),'dd/mm/yyyy')#.pdf" content="#pdfoutput#">
			</body>
		</html>
	</cfmail>


	<cfdocument format="pdf" marginTop = "2" marginBottom = "2" name="pdfoutput_depo_hareket">

		<cfdocumentitem type="header" evalatprint="true">
			<table border="0" id="main_table" class="table" style="width:100%; height:30%">
				<tr>
					<td align="left" rowspan="2">
						&nbsp;
						<br>
						<cfoutput><img style="height:70" border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></cfoutput>
						<br>
						&nbsp;
					</td>
					<td align="center"><b>Depo Hareket Raporu</b></td>
				</tr>
				<tr>
					<td align="right"><cfoutput><b>#dateformat(now(),"dd / mm / yyyy")#</b></cfoutput></td>
				</tr>
			</table>
		</cfdocumentitem>

		<cfdocumentitem type= "footer">
			<table class="table" style="width:100%; border:1px solid black; background-color:gray">
				<tr align="center">
					<td><b><cfoutput>#dateformat(now(),dateformat_style)#</cfoutput></b></td>
					<td><b>www.birikimpilleri.com</b></td>
					<td><b>Sayfa No : <cfoutput>#cfdocument.currentpagenumber#</cfoutput></b></td>
				</tr>
			</table>
		</cfdocumentitem>

		<cfdocumentsection>
	
			<h3 align="center"><cfoutput>#dateformat(now(),dateformat_style)# - DEPO HAREKET RAPORU</cfoutput></h3>
	
			<table border="1" cellspacing="0" cellpadding="3" style="width:100%">
				<thead>
					<tr style="background-color:gray">
						<th style="font-size:13px">Sıra</th>
						<th style="font-size:13px">Stok Kodu</th>
						<th style="font-size:13px">Depo</th>
						<th style="font-size:13px">Entegrasyon</th>
						<th style="font-size:13px">Stok Adı</th>
						<th style="font-size:13px">Miktarı</th>
						<th style="font-size:13px">Birim</th>
						<th style="font-size:13px">Resim</th>
					</tr>
				</thead>

				<tbody>
					<cfoutput query="GET_DAILY_STOCKS_IN">
						<tr>
							<td><h2>#currentrow#</h2></td>
							<td align="center" style="font-size:13px">#OZEL_KOD# <br> <cf_workcube_barcode show="1" type="code39" width="200" height="25" value="#OZEL_KOD#"> </td>
							<td align="center" style="font-size:13px">Depo</td>
							<td align="center" style="font-size:13px">İrsaliye</td>
							<td align="center" style="font-size:13px">#NAME_PRODUCT#</td>
							<td align="center" style="font-size:13px">#AMOUNT#</td>
							<td align="center" style="font-size:13px">#UNIT#</td>
							<td align="center"><cf_get_server_file output_file="../../documents/product/#PATH#" image_height="100" output_server="1" output_type="5"></td>
						</tr>
					</cfoutput>
				</tbody>
			</table>
	
		</cfdocumentsection>

	</cfdocument>

	<cfmail from="#from_mail#" to="#to_mail#" subject="DEPO HAREKET RAPORU" type="html" charset="utf-8">
		<html>
			<body>
				<p>Ekte bulunan PDF deki ürünler stoklara gelmiştir.</p><br>
				<p>İyi çalışmalar.</p>
				<cfmailparam file="gelen_urunler#dateformat(now(),'dd/mm/yyyy')#.pdf" content="#pdfoutput_depo_hareket#">
			</body>
		</html>
	</cfmail>

</cfif>

