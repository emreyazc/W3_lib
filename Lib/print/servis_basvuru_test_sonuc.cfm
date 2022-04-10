<!---
	Desc : Test Biriminin yaptığı testlerin sonuçları için tasarlamıştır.
	Date : 10.11.2021
	Dev	 : Yunus Emre Yazıcı - Birikim Pilleri
---->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
	<cfquery name="GET_SERVICES_TEST" datasource="#DSN3#">
		SELECT 
			SERVICE_NO,
			APPLY_DATE,
			TEST_STANDART,
			CHARGING_METHOD,
			CHARGING_CURRENT,
			MAX_VOLTAGE,
			OFF_CURRENT,
			REST_AFTER_CHARGING,
			DISCHARGING_METHOD_ID,
			DISCHARGE_TIME,
			DISCHARGE_CURRENT,
			ENCODING_VOLTAGE,
			TEMPERATURE,
			TEST_STEPS,
			SERIAL_NUMBER,
			NOMINAL_CAPACITY,
			TEST_RESULT,
			RESULT,
			RATE,
			COMMENT,
			P_BRAND,
			P_TYPE_OF_CELL,
			P_CHEMISTRY,
			P_CELL_CONFIGURATION,
			P_NOMINAL_CAPACITY,
			P_NOMINAL_VOLTAGE,
			INTERNAL_RESISTANCE,
			DIMENSIONS_WIDHT,
			DIMENSIONS_HEIGHT,
			DIMENSIONS_LENGTH,
			DIMENSIONS_CALIBER,
			SERVICE.SERVICE_PRODUCT_ID AS SERVICE_PRODUCT_ID
		FROM 
			SERVICE
			LEFT JOIN SERVICE_TEST_CONTROL ON SERVICE.SERVICE_ID = SERVICE_TEST_CONTROL.SERVICE_ID
		WHERE
			SERVICE.SERVICE_ID = #attributes.action_id#
	</cfquery>

	<!---	
		eğer bizdeki bir ürün test edilecekse, o zaman ürün kartından ürünle ilgili bilgiler çekilecek
		test edilen ürün kendi ürünümüz değilse bilgileri Test Sonucu ekranından alacak.
	--->
	
	<cfif len(GET_SERVICES_TEST.SERVICE_PRODUCT_ID)>
		<cfquery name="GET_PRODUCT_INFO" datasource="#DSN1#">
			SELECT
				PRODUCT.PRODUCT_NAME,
				PRODUCT_IMAGES.PATH AS IMAGE_PATH
			FROM
				PRODUCT
				LEFT JOIN PRODUCT_IMAGES ON PRODUCT.PRODUCT_ID = PRODUCT_IMAGES.PRODUCT_ID
			WHERE
				PRODUCT.PRODUCT_ID = #GET_SERVICES_TEST.SERVICE_PRODUCT_ID#
		</cfquery>
	</cfif>
	
	<cfquery name="GET_GRAPH_ASSET" datasource="#DSN#">
		SELECT
			ASSET_FILE_NAME
		FROM
			ASSET
		WHERE
			PROPERTY_ID = 21 AND
			ACTION_ID = #attributes.action_id#
	</cfquery>

	<cfquery name="GET_COMMENT_ASSET" datasource="#DSN#">
		SELECT
			ASSET_FILE_NAME
		FROM
			ASSET
		WHERE
			PROPERTY_ID = 22 AND
			ACTION_ID = #attributes.action_id#
	</cfquery>
	
	<cfquery name="GET_TEST_PRODUCT_ASSET" datasource="#DSN#">
		SELECT
			ASSET_FILE_NAME
		FROM
			ASSET
		WHERE
			PROPERTY_ID = 23 AND
			ACTION_ID = #attributes.action_id#
	</cfquery>
	
	<cfif len(GET_SERVICES_TEST.DISCHARGING_METHOD_ID)>
		<cfquery name="GET_DISCHARGING_NAME" datasource="#DSN3#">
			SELECT DISCHARDING_ID, DISCHARDING_NAME FROM DISCHARDING_METHOD WHERE DISCHARDING_ID = #GET_SERVICES_TEST.DISCHARGING_METHOD_ID#
		</cfquery>
	</cfif>

	<cfdocument format="PDF" marginTop = "1" marginBottom = "1"> 
		<cfdocumentitem type="header" evalatprint="true">
			<table class="table" border="1" style="width:100% ; height:40%">
				<tr>
					<td rowspan="3" colspan="3" style=" text-align:center; width:100%;"><cf_get_server_file output_file="../../images/birikim_logo.png" image_height="70" output_server="1" output_type="5"></td>
					<td colspan="4" style="text-align:center"><b><cfoutput>#GET_SERVICES_TEST.SERVICE_NO#</cfoutput> Başvuru Test Sonuçları</b>
						<tr>
							<td style="text-align:center;">Başvuru No</td>
							<td style="text-align:center;">Sayfa No</td>
							<td style="text-align:center;">Başvuru Tarhi</td>
						</tr>
						<tr>
							<td style="text-align:center;"><cfoutput>#GET_SERVICES_TEST.SERVICE_NO#</cfoutput></td>
							<td style="text-align:center;"><cfoutput>#cfdocument.currentpagenumber#</cfoutput></td>
							<td style="text-align:center;"><cfoutput>#dateformat(GET_SERVICES_TEST.APPLY_DATE,dateformat_style)#</cfoutput></td>
						</tr>
					</td>
				</tr>
			</table>
		</cfdocumentitem>
		<cfdocumentitem type="footer" evalatprint="true">
			<cfif cfdocument.currentPageNumber eq cfdocument.totalPageCount>
				<table style="width:100%">
					<tr align="right">
						<td><b align="right">Testi Gerçekleştiren</b><br><b align="right">Serdar Anık</b><br><b>Test Sorumlusu</b></td>
					</tr>
				</table>
			</cfif>
		</cfdocumentitem>
		<cfdocumentsection>
			<cfoutput query="GET_SERVICES_TEST">
					<h4 align="center">Test Raporu</h4>
					<table style="width: 100%;" border="1">
						<tbody>
							<tr>
								<th colspan="3" style="height:20mm; background-color:lightgray">Ürün Bilgileri</th>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Markası</b><br><a style="color:orange; font-size:15">Brand</a></td>
								<td style="width: 15%">#P_BRAND#</td>
								<td align="center">Ürün Görseli</td>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Hücre Modeli</b><br><a style="color:orange; font-size:15">Type of Cell</a></td>
								<td>#P_TYPE_OF_CELL#</td>
								
								<cfif len(GET_SERVICES_TEST.SERVICE_PRODUCT_ID)>
									<cfloop query="GET_PRODUCT_INFO">
										<td align="center" rowspan="5"><cf_get_server_file output_file="product/#IMAGE_PATH#" image_width="300" output_server="1" output_type="5"></td>
									</cfloop>
								<cfelse>
									<cfloop query="GET_TEST_PRODUCT_ASSET">
										<tr>
											<td><cf_get_server_file output_file="service/#ASSET_FILE_NAME#" image_height="150" output_server="1" output_type="5"></td>
										</tr>
									</cfloop>
								</cfif>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Kimyası</b><br><a style="color:orange; font-size:15">Chemistry</a></td>
								<td>#P_CHEMISTRY#</td>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Hücre Yapılandırması</b><br><a style="color:orange; font-size:15">Cell Configuration</a></td>
								<td>#P_CELL_CONFIGURATION#</td>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Nominal Kapasite</b><br><a style="color:orange; font-size:15">Nominal Capacity</a></td>
								<td>#P_NOMINAL_CAPACITY#</td>
							</tr>
							<tr>
								<td style="height: 75px; width: 20%"><b>Nominal Voltajı</b><br><a style="color:orange; font-size:15">Nominal Voltage</a></td>
								<td>#P_NOMINAL_VOLTAGE#</td>
							</tr>
						</tbody>
					</table>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
					<table style="width: 100%;" border="1">
						<thead>
							<th colspan="3" style="height:20mm; background-color:lightgray">TEST KOŞULLARI / <a style="color:orange; font-size:15">TEST CONDITIONS</a></th>
						</thead>
						<tbody>
							<tr><td style="height: 35px; width: 20%">Test Standardı <br><a style="color:orange; font-size:15">Test Standard</a></td><td style="width: 80%">#TEST_STANDART#</td></tr>
							<tr><td style="height: 35px">Şarj Metodu<br><a style="color:orange; font-size:15">Charging Method</a></td><td>#CHARGING_METHOD#</td></tr>
							<tr><td style="height: 35px">Şarj Akımı<br><a style="color:orange; font-size:15">Charging Current</a></td><td>#CHARGING_CURRENT#</td></tr>
							<tr><td style="height: 35px">Maksimum Voltajı<br><a style="color:orange; font-size:15">Maximum Voltage</a></td><td>#MAX_VOLTAGE#</tr>
							<tr><td style="height: 35px">Şarj Kapatma Akımı<br><a style="color:orange; font-size:15">Cut Off Current</a></td><td>#OFF_CURRENT#</td></tr>
						</tbody>
					</table>
					<br>
					<table style="width: 100%;" border="1">
						<tbody>
							<tr><td style="height: 35px; width: 20%">Şarjdan Sonra Dinlenme<br><a style="color:orange; font-size:15">Rest After Charging</a></td><td style="width: 80%">#REST_AFTER_CHARGING#</td></tr>
						</tbody>
					</table>
					<br>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
					<table style="width: 100%;" border="1">
						<tbody>
							<tr rowspan="2">
								<td rowspan="2" style=" width: 20%">Deşarj Metodu<br><a style="color:orange; font-size:15">Discharging Method</a></td>
								<td align="center">Sabit Akım<br><a style="color:orange; font-size:15">Constant Current</a></td>
								<td align="center">Sabit Güç<br><a style="color:orange; font-size:15">Constant Power</a></td>
								<td align="center">Sabit Direnç<br><a style="color:orange; font-size:15">Constant Resistance</a></td>
							</tr>
							<tr>
								<td align="center"><cfif GET_DISCHARGING_NAME.DISCHARDING_ID eq 1 ><b>(X)</b><cfelse>( )</cfif></td>
								<td align="center"><cfif GET_DISCHARGING_NAME.DISCHARDING_ID eq 2 ><b>(X)</b><cfelse>( )</cfif></td>
								<td align="center"><cfif GET_DISCHARGING_NAME.DISCHARDING_ID eq 3 ><b>(X)</b><cfelse>( )</cfif></td>
							</tr>
							<tr>
								<td rowspan="2">Deşarj Değerleri<br><a style="color:orange; font-size:15">Discharge</a></td>
								<td colspan="2" align="center">Akım <br><a style="color:orange; font-size:15">Current</a></td>
								<td align="center">Süre<br><a style="color:orange; font-size:15">Time/Minute Current</a></td>
							</tr>
							<tr>
								<td colspan="2">#DISCHARGE_CURRENT#</td>
								<td align="center">#DISCHARGE_TIME#</td>
							</tr>
							<tr>
								<td>Deşarj Bitiş Voltajı<br><a style="color:orange; font-size:15">Discharging Ending Voltage</a></td>
								<td colspan="3">#ENCODING_VOLTAGE#</td>
							</tr>
							<tr>
								<td>Ortam Sıcaklığı<br><a style="color:orange; font-size:15">Temperature</a></td>
								<td colspan="3">#TEMPERATURE#</td>
							</tr>
							<tr>
								<td style="height: 100px">Test Basamakları<br><a style="color:orange; font-size:15">Test Steps</a></td>
								<td colspan="3">#TEST_STEPS#</td>
							</tr>
						</tbody>
					</table>
					<table style="width: 100%;" border="1">
						<tr>
							<td rowspan="2">Boyutlar<br><a style="color:orange; font-size:15">Dimensions</a></td>
							<td align="center">En<br><a style="color:orange; font-size:15">Width</a></td>
							<td align="center">Boy<br><a style="color:orange; font-size:15">Length</a></td>
							<td align="center">Yükseklik<br><a style="color:orange; font-size:15">Height</a></td>
							<td align="center">Çap<br><a style="color:orange; font-size:15">Height</a></td>
						</tr>
						<tr>
							<td>#DIMENSIONS_WIDHT#</td>
							<td>#DIMENSIONS_LENGTH#</td>
							<td>#DIMENSIONS_HEIGHT#</td>
							<td>#DIMENSIONS_CALIBER#</td>
						</tr>
					</table>
					<h4>Sonuç Tablosu</h4>
					<table style="width: 100%;" border="1">
						<tr><td>Seri Numarası : </td><td>#SERIAL_NUMBER#</td></tr>
						<tr><td>Nominal Kapasite :</td><td>#NOMINAL_CAPACITY#</td></tr>
						<tr><td>Test Sonucu : </td><td>#TEST_RESULT#</td></tr>
						<tr><td>Sonuç : </td><td>#RESULT#</td></tr>
						<tr><td>Oran :</td><td>#RATE#</td></tr>
					</table>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
					<table style="width: 100%;" border="1" cellpadding="20">
						<tbody>
							<tr>
								<td align="center" colspan="2" style="height: 35px;"><h4>SONUÇ<a style="color:orange; font-size:15"> / RESULT</a></h4></td>
							</tr>
							<tr>
								<td align="left" style="width:20%; height: 35px;">Deşarj Süresi<br><a style="color:orange; font-size:15">Discharge Time</a></td>
								<td align="center">#DISCHARGE_TIME#<a style="color:orange; font-size:15">(minute)</a></td>
							</tr>
							<cfloop query="GET_GRAPH_ASSET">
							<tr>
								<td align="left" style="height:600px">Grafik</td>
								<td><cf_get_server_file output_file="service/#ASSET_FILE_NAME#" image_height="600px" output_server="1" output_type="5"></td>
							</tr>
							</cfloop>
						</tbody>
					</table>
					<cfdocumentitem type="pagebreak">
					</cfdocumentitem>
					<table style="width: 100%;" border="1" cellpadding="20">
						<tbody>
							<tr>
								<td align="center" style="height:20px"><h4>Yorum</h4></td>
							</tr>
							<cfloop query="GET_COMMENT_ASSET">
								<tr>
									<td><cf_get_server_file output_file="service/#ASSET_FILE_NAME#" image_height="150" output_server="1" output_type="5"></td>
								</tr>
							</cfloop>
							<tr><td>#COMMENT#</td></tr>
						</tbody>
					</table>
					<br>
					<cfif len(GET_SERVICES_TEST.INTERNAL_RESISTANCE)>
						<div align="center">
							<h4>İç Direnç ve Voltaj Tablosu</h4>
							#INTERNAL_RESISTANCE#
						</div>
					</cfif>
			</cfoutput>
		</cfdocumentsection>
	</cfdocument>
</cfif>


