<!---
    Date : 08.03.2022
    Desc : Stoklara eklenen ürünlerin listesini gün sonunda ilgili personele mail gönderir.
    Dev : Yunus Emre Yazıcı - Birikim Pilleri
--->

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

	<!---
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
			<!---
			S.SHIP_DATE = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-2,now()))#">
			--->
			S.SHIP_DATE = '2022-03-14 00:00:00.000'
			AND S.SHIP_TYPE = 76
			AND PI.IS_COVER = 1
	</cfquery>

	<cfdump var="#GET_DAILY_STOCKS_IN#">
	--->

	<!---
	<cfquery name="GET_STOCKS_DAILY" datasource="#DSN2#">
		SELECT
			SR_SEVK.PRODUCT_ID,
			SR_SEVK.NAME_PRODUCT,
			SUM(SR_SEVK.AMOUNT) AS MIKTAR,
			SR_SEVK.UNIT,
			S_SEVK.DEPARTMENT_IN,
			S_SEVK.LOCATION_IN,
			S_SEVK.SHIP_DATE,
			ST.STOCK_CODE AS STOK_KODU,
			ST.STOCK_CODE_2 AS OZEL_KOD,
			ST.PRODUCT_NAME AS STOK_ADI,
			P.BARCOD AS BARKOD,
			P.PRODUCT_ID,
			PC.PRODUCT_CAT,
			PC.HIERARCHY
			/*
			SR_SEVK.*
			*/
		FROM
			SHIP S
			LEFT JOIN SHIP_ROW SR ON SR.SHIP_ID = S.SHIP_ID
			LEFT JOIN SHIP_ROW SR_SEVK ON SR_SEVK.WRK_ROW_RELATION_ID = SR.WRK_ROW_ID
			LEFT JOIN SHIP S_SEVK ON S_SEVK.SHIP_ID = SR_SEVK.SHIP_ID
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = SR_SEVK.PRODUCT_ID
			LEFT JOIN #DSN3#.STOCKS ST ON ST.STOCK_ID = SR_SEVK.STOCK_ID
			LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
		WHERE
		(
				(S.SHIP_TYPE = 76 OR S.SHIP_TYPE = 811)
				AND S_SEVK.LOCATION_IN = 1 /* Merkez lokasyon*/ 
				AND S_SEVK.LOCATION = 1 /* Merkez lokasyon*/ 
				AND S_SEVK.DEPARTMENT_IN = 62 /* İdari kontrol depo */
				AND SR_SEVK.TO_SHELF_NUMBER = 1240 /* KABUL RAFI */
				<!---
				AND S_SEVK.SHIP_DATE = '2022-03-16 00:00:00.000'
				AND S_SEVK.SHIP_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-1,now()))#">
				AND S_SEVK.SHIP_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(now())#">
				--->
				AND S_SEVK.SHIP_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-1,now()))#">
			)
				AND
			(
				P.PRODUCT_STATUS = 1
				AND P.IS_SALES = 1
			)
		GROUP BY
			SR_SEVK.PRODUCT_ID,
			SR_SEVK.NAME_PRODUCT,
			SR_SEVK.UNIT,
			S_SEVK.DEPARTMENT_IN,
			S_SEVK.LOCATION_IN,
			S_SEVK.SHIP_DATE,
			ST.STOCK_CODE,
			ST.STOCK_CODE_2,
			ST.PRODUCT_NAME,
			P.BARCOD,
			P.PRODUCT_ID,
			PC.PRODUCT_CAT,
			PC.HIERARCHY
		ORDER BY
			SR_SEVK.PRODUCT_ID ASC
	</cfquery>
	

	<cfoutput><p>#GET_STOCKS_DAILY.recordCount#</p></cfoutput>

	<p>Personele Giden Rapor</p>
	<p><cfoutput>Tarih : #dateformat(GET_STOCKS_DAILY.SHIP_DATE,dateformat_style)#</cfoutput></p>

	<cfdump var="#GET_STOCKS_DAILY#">

	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME1 FROM OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfif len(get_comp_addr.ASSET_FILE_NAME1)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name1>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

<cfif GET_STOCKS_DAILY.recordCount GT 0>

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
					<!---
					<td align="center"><b>Depo Hareket Raporu</b></td>
					--->
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
	
			<cfoutput query="GET_STOCKS_DAILY">
				<table border="1" cellspacing="0" cellpadding="3" style="width:100%">
					<cfif currentRow EQ 1>
						<thead>
							<tr style="background-color:gray">
								<th align="center" style="font-size:13px; width:5%">Sıra</th>
								<th style="font-size:13px; width:20%">Barkod</th>
								<!---
								<th style="font-size:13px; width:10%">Depo</th>
								<th style="font-size:13px; width:10%">Entegrasyon</th>
								--->
								<th style="font-size:13px; width:40%">Stok Adı</th>
								<th style="font-size:13px; width:10%">Miktarı</th>
								<th style="font-size:13px; width:10%">Birim</th>
								<th style="font-size:13px; width:15%">Resim</th>
							</tr>
						</thead>
					</cfif>
					<tbody>
						<tr>
							<td align="center" style="width:5%"><h2>#currentrow#</h2></td>
							<td align="center" style="font-size:13px; width:20%">#BARKOD# <br> 
								<cf_workcube_barcode show="1" type="qrcode" width="75" height="75" value="#BARKOD#">
							</td>
							<!---
							<td align="center" style="font-size:13px; width:5%">Depo</td>
							<td align="center" style="font-size:13px; width:5%">İrsaliye</td>
							--->
							<td align="center" style="font-size:13px; width:40%">
								<table style="height:100%; width:100%">
									<!---
									<tr>#NAME_PRODUCT#<br></tr>
									--->
									<!---
									<tr><a style="color:red; font-size:13px; align:center" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#">#STOK_ADI#</a></tr>
									--->
									<tr><a style="color:red; font-size:16px; align:center; text-decoration: none" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#"><b>#NAME_PRODUCT#</b></a></tr>
								</table>
							</td>
							<td align="center" style="font-size:13px; width:10%">#MIKTAR#</td>
							<td align="center" style="font-size:13px; width:10%">#UNIT#</td>
							<td align="center" style="width:15%; width:15%">
								<cfquery name="GET_P_IMG" datasource="#DSN1#">
									SELECT PATH FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #PRODUCT_ID# AND IS_COVER = 1
								</cfquery>
								<cfif len(GET_P_IMG.PATH)>
									<cf_get_server_file output_file="../../documents/product/#GET_P_IMG.PATH#" image_height="100" image_width="100" output_server="1" output_type="5">
									<cfelse>
								</cfif>
							</td>
						</tr>
						<!---
						<tr>
							<td colspan="6">
								<a style="color:red; font-size:13px; align:center" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#">#STOK_KODU# - W3 STOK SAYFASI</a>
							</td>
						</tr>
						--->
					</tbody>
				</table>
				<cfif currentRow%4 eq 0>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
				</cfif>
			</cfoutput>
		</cfdocumentsection>

	</cfdocument>

	<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
	<cfset to_mail="yunusemreyazici@birikimpilleri.com">
	<!---
	<cfset to_mail="gelenurun@birikimpilleri.com">
	--->

	<cfmail from="#from_mail#" to="#to_mail#" subject="DEPO HAREKET RAPORU- #dateformat(now(),'dd/mm/yyyy')#" type="html" charset="utf-8">
		<html>
			<body>
				<p>Ekte bulunan PDF deki ürünler stoklara gelmiştir.</p><br>
				<p>İyi çalışmalar.</p>
				<cfmailparam file="depo_hareket_raporu#dateformat(now(),'dd/mm/yyyy')#.pdf" content="#pdfoutput_depo_hareket#">
			</body>
		</html>
	</cfmail>

<cfelse>
	<script>
		alert("gelen ürün yok");
	</script>
</cfif>

--->

	<cfquery name="GET_DAILY_STOCK" datasource="#DSN2#">
		SELECT
			SF.FIS_DATE,
			SFR.STOCK_ID,
			SFR.UNIT,
			SFR.UNIT_ID,
			S.PRODUCT_NAME AS NAME_PRODUCT,
			S.PRODUCT_ID,
			P.BARCOD AS BARKOD,
			PC.PRODUCT_CAT,
			PC.HIERARCHY,
			SUM(SFR.AMOUNT) AS MIKTAR
		FROM
			STOCK_FIS_ROW SFR
			LEFT JOIN STOCK_FIS SF ON SF.FIS_ID = SFR.FIS_ID
			LEFT JOIN #DSN3#.STOCKS S ON S.STOCK_ID = SFR.STOCK_ID
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = S.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
		WHERE
			SF.FIS_TYPE = 113
			<!---
			AND SF.FIS_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(DATEADD('d',-1,now()))#">
			AND SF.FIS_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(now())#">
			--->
			AND SF.FIS_DATE =  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(now())#">
			AND SF.LOCATION_OUT = 1 		/* ÇIKIŞ LOKASYON (MERKEZ) */ 
			AND SF.LOCATION_IN = 1 			/* GİRİŞ LOKASYON (MERKEZ) */ 
			AND DEPARTMENT_OUT = 62 		/* ÇIKIŞ DEPO (İDARİ KONTROL DEPO) */
			AND DEPARTMENT_IN = 44 			/* GİRİŞ DEPO (SATIŞ KONTROL DEPO) */
			AND SFR.SHELF_NUMBER = 1240 	/* çıkış rafı : mal kabul */
			AND SFR.TO_SHELF_NUMBER = 1244 	/* giriş rafı : SPT - 99 (satış rafı) */
			AND P.IS_SALES = 1
			AND P.PRODUCT_STATUS = 1
		GROUP BY
			SF.FIS_DATE,
			SFR.STOCK_ID,
			SFR.UNIT,
			SFR.UNIT_ID,
			S.PRODUCT_NAME,
			S.PRODUCT_ID,
			P.BARCOD,
			PC.PRODUCT_CAT,
			PC.HIERARCHY
	</cfquery>



	<cfoutput><h3>Tarih : #dateformat(GET_DAILY_STOCK.FIS_DATE,dateformat_style)#</h3></cfoutput>
	<cfoutput><h3>Stoklara alınan ürün sayısı : #GET_DAILY_STOCK.recordCount#</h3></cfoutput>



	<!---
	<cfdump var="#GET_DAILY_STOCK#">
	--->
	<cfform name="search" method="post">
		<input type="hidden" name="form_submitted" id="form_submitted" value="1">
		<cf_big_list_search_area>
			<div class="row">
				<div class="col col-12 form-inline">
					<div class="form-group" id="item-date">
						<div class="input-group x-14">
							<cf_workcube_buttons extraInfo="PDF İNDİR">
						</div>
					</div>
				</div>
			</div>
		</cf_big_list_search_area>
	</cfform>

	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME1 FROM OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfif len(get_comp_addr.ASSET_FILE_NAME1)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name1>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

	<cfif isdefined("attributes.form_submitted")>

		<cfif GET_DAILY_STOCK.recordCount GT 0>

			<script>
				alert("Satış Depo SPT99 rafına alınan <cfoutput>#GET_DAILY_STOCK.recordCount# stok için belge oluşturulacaktır. </cfoutput>");
			</script>
	
			<cfheader name="Content-Disposition" value="attachment; filename=stoklara_alınan_urunler_#dateformat(GET_DAILY_STOCK.FIS_DATE,dateformat_style)#.pdf">
			<cfcontent type="application/pdf">
	
			<!---
			<cfdocument format="pdf" marginTop = "2" marginBottom = "2" name="pdfoutput_depo_hareket">
			--->
			<cfdocument format="pdf" marginTop = "2" marginBottom = "2">
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
							<!---
							<td align="center"><b>Depo Hareket Raporu</b></td>
							--->
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
					<h3 align="center"><cfoutput>#dateformat(GET_DAILY_STOCK.FIS_DATE,dateformat_style)# - DEPO HAREKET RAPORU</cfoutput></h3>
	
					<cfoutput query="GET_DAILY_STOCK">
						<table border="1" cellspacing="0" cellpadding="3" style="width:100%">
							<cfif currentRow EQ 1>
								<thead>
									<tr style="background-color:gray">
										<th align="center" style="font-size:13px; width:5%">Sıra</th>
										<th style="font-size:13px; width:20%">Barkod</th>
										<!---
										<th style="font-size:13px; width:10%">Depo</th>
										<th style="font-size:13px; width:10%">Entegrasyon</th>
										--->
										<th style="font-size:13px; width:40%">Stok Adı</th>
										<th style="font-size:13px; width:10%">Miktarı</th>
										<th style="font-size:13px; width:10%">Birim</th>
										<th style="font-size:13px; width:15%">Resim</th>
									</tr>
								</thead>
							</cfif>
							<tbody>
								<tr>
									<td align="center" style="width:5%"><h2>#currentrow#</h2></td>
									<td align="center" style="font-size:13px; width:20%">#BARKOD# <br> 
										<cf_workcube_barcode show="1" type="qrcode" width="75" height="75" value="#BARKOD#">
									</td>
									<!---
									<td align="center" style="font-size:13px; width:5%">Depo</td>
									<td align="center" style="font-size:13px; width:5%">İrsaliye</td>
									--->
									<td align="center" style="font-size:13px; width:40%">
										<table style="height:100%; width:100%">
											<!---
											<tr>#NAME_PRODUCT#<br></tr>
											--->
											<!---
											<tr><a style="color:red; font-size:13px; align:center" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#">#STOK_ADI#</a></tr>
											--->
											<tr><a style="color:red; font-size:16px; align:center; text-decoration: none" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#"><b>#NAME_PRODUCT#</b></a></tr>
										</table>
									</td>
									<td align="center" style="font-size:13px; width:10%">#MIKTAR#</td>
									<td align="center" style="font-size:13px; width:10%">#UNIT#</td>
									<td align="center" style="width:15%; width:15%">
										<cfquery name="GET_P_IMG" datasource="#DSN1#">
											SELECT PATH FROM PRODUCT_IMAGES WHERE PRODUCT_ID = #PRODUCT_ID# AND IS_COVER = 1
										</cfquery>
										<cfif len(GET_P_IMG.PATH)>
											<cf_get_server_file output_file="../../documents/product/#GET_P_IMG.PATH#" image_height="100" image_width="100" output_server="1" output_type="5">
											<cfelse>
										</cfif>
									</td>
								</tr>
								<!---
								<tr>
									<td colspan="6">
										<a style="color:red; font-size:13px; align:center" href="#user_domain#?fuseaction=stock.list_stock&event=det&pid=#PRODUCT_ID#">#STOK_KODU# - W3 STOK SAYFASI</a>
									</td>
								</tr>
								--->
							</tbody>
						</table>
					</cfoutput>
				</cfdocumentsection>
			</cfdocument>
	
			<script>
				alert("Belge bilgisiyarınıza indirilmiştir.");
			</script>
	
			<!---
			<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
			<cfset to_mail="yunusemreyazici@birikimpilleri.com">
			<cfset to_mail="gelenurun@birikimpilleri.com">
			<cfset to_mail="yunusemreyazici@birikimpilleri.com">
			--->
		
			<!---
			<cfmail from="#from_mail#" to="#to_mail#" subject="DEPO HAREKET RAPORU- #dateformat(now(),'dd/mm/yyyy')#" type="html" charset="utf-8">
				<html>
					<body>
						<h2 style="color:red"></h2>
						<p>#dateformat(GET_DAILY_STOCK.FIS_DATE,dateformat_style)# tarihinde ekte bulunan PDF deki ürünler stoklara gelmiştir.</p>
						<p>İyi çalışmalar.</p>
						<!---
						<cfmailparam file="depo_hareket_raporu#dateformat(now(),'dd/mm/yyyy')#.pdf" content="#pdfoutput_depo_hareket#">
						--->
					</body>
				</html>
			</cfmail>
			--->
	
		<cfelse>
			<script>
				alert("Bugün Satış Depo SPT99 a ürün gelmemiştir.");
			</script>
	
		</cfif>

	</cfif>