<!---
	Date : 01.04.2022
	Desc : Ürün Kabul Formu (İdari)
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
	<cfquery name="GET_ORDER" datasource="#DSN3#">
		SELECT
			*
		FROM
			ORDERS O
			LEFT JOIN ORDER_ROW ORR ON ORR.ORDER_ID = O.ORDER_ID
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = ORR.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_ID = P.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_IMAGES PI ON PI.PRODUCT_ID = ORR.PRODUCT_ID
			LEFT JOIN #DSN#.SETUP_COUNTRY SC ON SC.COUNTRY_ID = P.ORIGIN_ID
			LEFT JOIN STOCKS S ON S.PRODUCT_ID = ORR.PRODUCT_ID
			LEFT JOIN #DSN#.COMPANY C ON C.COMPANY_ID = O.COMPANY_ID
		WHERE
			O.ORDER_ID = #attributes.action_id#
			AND PU.IS_MAIN = 1
	</cfquery>

	<cfquery name="CHECK" datasource="#DSN#">
		SELECT 
			ASSET_FILE_NAME2,
			ASSET_FILE_NAME2_SERVER_ID,
			COMPANY_NAME,
			ADDRESS,
			TEL_CODE,
			TEL,
			FAX
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

	<cfdocument format="pdf" orientation = "landscape" pagetype="A4" marginbottom="2" margintop="2" marginleft="0.5" marginright="0.5">
		<cfdocumentitem type = "header" evalatprint = "true">
			<table style="width:100%; font-size:13px">
				<tr style="width:100%" align="center">
					<td align="left">
						<cfif len(CHECK.ASSET_FILE_NAME2)>
							<cfset attributes.type = 1>
							<cf_get_server_file output_file="/settings/#CHECK.ASSET_FILE_NAME2#" image_height="100" output_server="#CHECK.ASSET_FILE_NAME2_SERVER_ID#" output_type="5">
						</cfif>
					</td>
					<td align="center"><h3>ÜRÜN KABUL FORMU (İDARİ)</h3></td>
					<td align="right"><cf_get_server_file output_file="../../images/teklif_pil.png" image_height="100" output_server="1" output_type="5"></td>
				</tr>
			</table>
			<table style="width:100%; font-size:13px">
				<tr style="width:100%">
					<td colspan="2"><cfoutput>#CHECK.COMPANY_NAME#</cfoutput></td>
					<td>Firma Adı</td><td> : <cfoutput>#GET_ORDER.FULLNAME#</cfoutput></td>
					<td>Tarih</td><td >: <cfoutput>#dateformat(GET_ORDER.ORDER_DATE,dateformat_style)#</cfoutput></td>
				</tr>
				<tr style="width:100%">
					<td colspan="2" ><cfoutput>#CHECK.ADDRESS#</cfoutput></td>
					<td >İrsaliye No</td><td>: </td>
					<td >Sipariş No</td><td>: <cfoutput>#GET_ORDER.ORDER_NUMBER#</cfoutput></td>
				</tr>
				<tr style="width:100%">
					<td colspan="2">TEL: <cfoutput>0#CHECK.TEL_CODE# #CHECK.TEL#</cfoutput></td>
					<td >İrsaliye Tarihi</td><td>: </td>
					<td >Temsilci Grubu</td><td>: Satınalma</td>
				</tr>
				<tr>
					<td colspan="4"></td>
					<td>Müşteri Temsilcisi</td><td>: </td>
				</tr>
			</table>
		</cfdocumentitem>

		<cfdocumentitem type = "footer" evalatprint = "true">

			<table border="1px" cellspacing="0" cellpadding="2" style="font-size:13px; width:100%; height:20%"> 
				<tbody>
					<tr style="height:15%">
						<td style="width:20%" align="center" rowspan="2">GÖRSEL KONTROL SONUCU</td>
						<td style="width:10%" align="center">KABUL</td>
						<td style="width:25%" align="center" rowspan="2">KONTROLÜ YAPAN</td>
						<td style="width:25%" align="center">DEPO SORUMLUSU</td>
						<td style="width:20%" align="center">İmza</td>
					</tr>
					<tr style="height:5%">
						<td align="center">RED</td>
						<td align="center"><cfoutput>#session.ep.name# #session.ep.surname#</cfoutput></td>
						<td align="center">&nbsp;</td>
					</tr>
				</tbody>
			</table>
			<!---
			<table border="1px" cellspacing="0" cellpadding="3" style="font-size:13px; width:100%; height:20mm"> 
				<tr>
					<td align="center" rowspan="2" style="width:25%">GÖRSEL KONTROL SONUCU</td>
					<td align="center">KABUL</td>
					<td align="center" style="width:25%">KONTROLÜ YAPAN</td>
					<td align="center" style="width:25%">DEPO SORUMLUSU</td>
					<td align="center" style="width:25%">İmza</td>
				</tr>
				<tr>
					<td align="center">&nbsp;</td>
					<td align="center">RED</td>
					<td align="center"><cfoutput>#session.ep.name# #session.ep.surname#</cfoutput></td>
					<td align="center">Depo Sorumlusu</td>
					<td align="center">&nbsp;</td>
				</tr>
			</table>
			--->
		</cfdocumentitem>

		<cfdocumentsection>
			<table border="1px" cellspacing="0" cellpadding="3" style="font-size:13px; width:100%"> 
				<thead>
					<tr>
						<th style="width:10%" rowspan="2" align="center">Ürün Resmi</th>
						<th style="width:40%" rowspan="2" align="center">Ürün Cinsi</th>
						<th style="width:10%" rowspan="2" align="center">Miktar</th>
						<th style="width:10%" align="center" colspan="2">Ürünlerde Hasar Var mı ?</th>
						<th style="width:10%" align="center" colspan="2">Akma Var mı ?</th>
						<th style="width:10%" align="center" colspan="2">Paslanma Var mı ?</th>
						<th style="width:10%" align="center" colspan="2">Üretim veya Son Kullanma Tarihi Uygun mu ?</th>
					</tr>
					<tr>
						<th style="width:5%" align="center">E</th>
						<th style="width:5%" align="center">H</th>
						<th style="width:5%" align="center">E</th>
						<th style="width:5%" align="center">H</th>
						<th style="width:5%" align="center">E</th>
						<th style="width:5%" align="center">H</th>
						<th style="width:5%" align="center">E</th>
						<th style="width:5%" align="center">H</th>
					</tr>

				</thead>
				<!---
				<tbody>
					<cfoutput query="GET_ORDER">
						<tr>
							<td align="center"><cf_get_server_file output_file="../../documents/product/#PATH#" image_height="80" output_server="1" output_type="5"></td>
							<td>
								<table style="width:100%; height:100%; font-size:13px" border="1px">
									<tr>
										<td style="width:50%" align="left">#STOCK_CODE_2#</td>
										<td style="width:50%" align="left">Üretim Tarihi :</td>
									</tr>
									<tr>
										<td style="width:100%" align="left" colspan="2">#PRODUCT_NAME#</td>
									</tr>
									<tr>
										<td style="width:50%" align="left">Menşei: </td>
										<td style="width:50%" align="left">Ağırlık: -</td>
									</tr>
								</table>
							</td>
							<td>
								<table style="width:100%; height:100%; font-size:13px" border="1px">
									<tr align="right">
										<td>#QUANTITY#</td>
									</tr>
									<tr align="center"><td>Teknik Test Adeti</td></tr>
									<tr><td>&nbsp;</td></tr>
								</table>
							</td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
						</tr>
						<!---
						<cfif currentRow mod 5>
							<cfdocumentitem type="pagebreak" />
						</cfif>
						--->
					</cfoutput>
				</tbody>
				--->
			</table>
			<cfoutput query="GET_ORDER">
				<table border="1px" cellspacing="0" cellpadding="1" style="font-size:12px; width:100%">
					<tbody>
						<tr>
							<td style="width:10%" align="center"><cf_get_server_file output_file="../../documents/product/#PATH#" image_height="75" output_server="1" output_type="5"></td>
							<td style="width:40%">
								<table border="1px" cellspacing="0" cellpadding="1" style="width:100%; height:100%; border-collapse: collapse">
									<tr>
										<td style="width:50%" align="left"><h2>#STOCK_CODE_2#</h2></td>
										<td style="width:50%" align="left">Üretim Tarihi: </td>
									</tr>
									<tr>
										<td style="width:100%" colspan="2" align="left"><b>#PRODUCT_NAME#</b></td>
									</tr>
									<tr>
										<td style="width:50%" align="left">Menşei : #COUNTRY_NAME#</td>
										<td style="width:50%" align="left">Ağırlık (GR) : #WEIGHT#</td>
									</tr>
								</table>
							</td>
							<td style="width:10%">
								<table border="1px" cellspacing="0" cellpadding="1" style="width:100%; height:100%; border-collapse: collapse">
									<tr align="right">
										<td>#QUANTITY#</td>
									</tr>
									<tr align="center"><td>Teknik Test Adeti</td></tr>
									<tr><td>&nbsp;</td></tr>
								</table>
							</td>
							<td style="width:5%"></td><td style="width:5%"></td>
							<td style="width:5%"></td><td style="width:5%"></td>
							<td style="width:5%"></td><td style="width:5%"></td>
							<td style="width:5%"></td><td style="width:5%"></td>
						</tr>
					</tbody>
				</table>
				<cfif currentRow%3 eq 0>
					<cfdocumentitem type="pagebreak" />
				</cfif>
			</cfoutput>
			<style>
			<!---
				#detay_1#
					{
						width: 100%;
						height: 100%;
						border: 1;
						font-size: 12px;
						border-collapse: collapse;
					}
				#detay_2#
					{
						width: 100%;
						height: 100%;
						border: 1;
						font-size: 12px;
						border-collapse: collapse;
					}
			--->
				table {
					border-collapse: collapse;
					border: 1px;
					<!--- 
					padding: 10px;
					--->
					font-size:13px;
				}
			</style>
		</cfdocumentsection>
	</cfdocument>

</cfif>