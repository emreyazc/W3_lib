<!---
    File: einvoice_digitalplanet.cfm
    Folder: V16\e_government\display
    Author:
    Date:
    Description:
        Digital Planet E-fatura gönderme
    History:
        12.10.2019 Gramoni-Mahmut Çifçi - E-Government standart modüle taşındı
    To Do:

--->

<cfinclude template="create_ubltr.cfm" />
<!--- XML dosya olusturuluyor --->
<cffile action="write" file="#directory_name##dir_seperator##invoice_number#.xml" output="#trim(invoice_data)#" charset="utf-8" mode="777"/>

<cfif get_our_company.is_template_code eq 1>
	<cfif not len(invoice_prefix)>
		Lütfen seri alanına geçerli bir ön ek giriniz.
		<cfabort>
	</cfif>
</cfif>

<!--- Fatura önizleme sayfasından geliyor ise çalışmayı durduruyoruz --->
<cfif attributes.fuseaction Neq 'invoice.popup_preview_invoice'>
	<cfset save_folder		= "#upload_folder#e_government#dir_seperator#xml" />

	<!--- Ticket almak icin gerekli XML formati hazirlaniyor --->
	<cfxml variable="ticket_data"><cfoutput>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
	<soapenv:Header/>
	<soapenv:Body>
		<tem:GetFormsAuthenticationTicket>
			<tem:CorporateCode>#get_our_company.EINVOICE_COMPANY_CODE#</tem:CorporateCode>
			<tem:LoginName>#get_our_company.EINVOICE_USER_NAME#</tem:LoginName>
			<tem:Password><![CDATA[#get_our_company.EINVOICE_PASSWORD#]]></tem:Password>
		</tem:GetFormsAuthenticationTicket>
	</soapenv:Body>
	</soapenv:Envelope></cfoutput>
	</cfxml>

	<cfif get_our_company.einvoice_test_system eq 1>
		<cfset web_service_url = 'https://IntegrationServiceWithoutMtomtest.eveelektronik.com.tr/IntegrationService.asmx'>
	<cfelse>
		<cfset web_service_url = 'https://integrationservicewithoutmtom.digitalplanet.com.tr/IntegrationService.asmx'>
	</cfif>
	<!--- Fatura kaydetmek icin gerekli tek seferlik ticket alınıyor ---> 
	<cffile
		action="write"
		file="C:\01_ticket_request.xml"
		output="#trim(ticket_data)#"
		charset="utf-8"
		mode="777">
	<cfhttp url="#web_service_url#" method="post" result="httpResponse">
		<cfhttpparam type="header" name="content-type" value="text/xml">
		<cfhttpparam type="header" name="SOAPAction" value="http://tempuri.org/GetFormsAuthenticationTicket">
		<cfhttpparam type="header" name="content-length" value="#len(ticket_data)#">
		<cfhttpparam type="header" name="charset" value="utf-8">
		<cfhttpparam type="xml" name="message" value="#trim(ticket_data)#">
	</cfhttp>
	<cffile
    action="write"
    file="C:\02_ticket_response.xml"
    output="#httpResponse.fileContent#"
    charset="utf-8"
    mode="777">
	<cftry>
		<cfset Ticket = xmlParse(httpResponse.filecontent)>
		<cfset Ticket = Ticket.Envelope.Body.GetFormsAuthenticationTicketResponse.GetFormsAuthenticationTicketResult.XmlText>
		<cfcatch type="Any">
			<div class="tour_box_content">
				<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
					<div style="background-color: #f28b82;" class="tour_box tour_box-type2">
						<div class="tour_box_title">
							<h1>Hata Bildirimi !</h1>
						</div>
						<div class="tour_box_text" >
							Ticket Alma Sırasında Bir Hata Meydana Geldi !<br /><cfabort>
						</div>
					</div>
				</div>
			</div>
		</cfcatch>
	</cftry>
	<!--- Imzasiz Fatura Base64 e cevriliyor ---> 
	<cffile action="READBINARY" file="#directory_name##dir_seperator##invoice_number#.xml" variable="e_fatura" mode="777">
	<cfset base64_efatura = trim(ToBase64(e_fatura))>
	<!--- SendInvoiceData fonksiyonu icin gerekli xml olusturuluyor --->
	<cfxml variable="invoice_data"><cfoutput>
	<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
	<soapenv:Header/>
	<soapenv:Body>
		<cfif get_our_company.is_template_code eq 1><tem:SendInvoiceDataWithTemplateCode><cfelse><tem:SendInvoiceData></cfif>
			<tem:Ticket>#Ticket#</tem:Ticket>
			<tem:FileType>UBL</tem:FileType>
			<tem:InvoiceRawData>#base64_efatura#</tem:InvoiceRawData>
			<tem:CorporateCode>#get_our_company.einvoice_company_code#</tem:CorporateCode>
			<tem:MapCode></tem:MapCode>
			<tem:ReceiverPostboxName>#get_alias.alias#</tem:ReceiverPostboxName>
			<cfif get_our_company.is_template_code eq 1><tem:TemplateCode>#invoice_prefix#</tem:TemplateCode>
		</tem:SendInvoiceDataWithTemplateCode><cfelse></tem:SendInvoiceData></cfif>
		</soapenv:Body>
	</soapenv:Envelope></cfoutput>
	</cfxml>

	<cffile
    action="write"
    file="C:\03_invoice_request.xml"
    output="#trim(invoice_data)#"
    charset="utf-8"
    mode="777">
	<!--- Fatura kaydı gercekletiriliyor --->
	<cfhttp url="#web_service_url#" method="post" result="httpResponse">
		<cfhttpparam type="header" name="content-type" value="text/xml">
		<cfif get_our_company.is_template_code eq 1><cfhttpparam type="header" name="SOAPAction" value="http://tempuri.org/SendInvoiceDataWithTemplateCode"><cfelse><cfhttpparam type="header" name="SOAPAction" value="http://tempuri.org/SendInvoiceData"></cfif>
		<cfhttpparam type="header" name="content-length" value="#len(invoice_data)#">
		<cfhttpparam type="header" name="charset" value="utf-8">
		<cfhttpparam type="xml" name="message" value="#trim(invoice_data)#">
	</cfhttp>
	<cffile
    action="write"
    file="C:\04_invoice_response.xml"
    output="#httpResponse.fileContent#"
    charset="utf-8"
    mode="777">

	<cfset STATUS_DESCRIPTION = "">
	<cfif get_our_company.is_template_code eq 1>
		<cfset xml_filecontent = XMLParse(httpResponse.filecontent).Envelope.Body.SendInvoiceDataWithTemplateCodeResponse.SendInvoiceDataWithTemplateCodeResult>
	<cfelse>
		<cfset xml_filecontent = XMLParse(httpResponse.filecontent).Envelope.Body.SendInvoiceDataResponse.SendInvoiceDataResult>
	</cfif>

	<cftry>
		<cfset InvoiceStateResult = xml_filecontent.Invoices.InvoiceStateResult>
		<cfset SERVICE_RESULT = InvoiceStateResult.ServiceResult.xmlText>
		<cfset UUID = InvoiceStateResult.UUID.xmlText>
		<cfset E_INVOICE_ID = InvoiceStateResult.InvoiceId.xmlText>
		<cfset STATUS_DESCRIPTION = InvoiceStateResult.StatusDescription.xmlText>
		<cfset STATUS_CODE = InvoiceStateResult.StatusCode.xmlText>
		
		<cfif listfind('1,17,18,19,20,21,22,23,24,25,37,41,46',STATUS_CODE)><!--- 1 GONDERIME HAZIR ,17 XML ONAYLANDI, 18 IMZA BASARISIZ, 19 İMZA BASARILI, 20 KURAL ONAYI BASARISIZ, 21 KURAL ONAYI BASARILI, 22 ARSIVLEME HATALI, 23 ARSIVLEME BASARILI, 24:SISTEME KAYDEDILDI, 37 IMZA BEKLIYOR, 41: GONDERIM ONAYI BEKLENIYOR --->
			<cfset STATUS_CODE = 1>
		</cfif>

		<cfset ERROR_CODE = InvoiceStateResult.ErrorCode.xmlText>    
		<cfif isdefined("xml_filecontent.ServiceResultDescription.xmlText")>
			<cfset SERVICE_RESULT_DESCRIPTION = xml_filecontent.ServiceResultDescription.xmlText>
		<cfelse>
			<cfset SERVICE_RESULT_DESCRIPTION = "">
		</cfif>

		<cfscript> 
			get_our_company_tmp.dsn2 = dsn2;
			get_our_company2 = get_our_company_tmp.add_einvoice_sending_detail
			(
				service_result: service_result,
				uuid: uuid,
				einvoice_id:invoice_number,
				status_description: status_description,
				service_result_description: service_result_description,
				status_code: status_code,
				error_code:error_code,
				action_id: attributes.action_id,
				action_type: attributes.action_type,
				invoice_type_code: temp_InvoiceTypeCode
			);
		</cfscript>
		<cfif STATUS_CODE eq 1>
			<cfscript> 
				get_our_company2 = get_our_company_tmp.add_einvoice_relation
				(
					uuid: uuid,
					integration_id:e_invoice_id,
					einvoice_id:invoice_number,
					profile_id: get_invoice.profile_id,
					action_id: attributes.action_id,
					action_type: attributes.action_type,
					path: temp_path,
					sender_type: get_our_company.einvoice_type,
					documentUrl: 'https://ebelge.digitalplanet.com.tr/ViewDocument.aspx?ID=#get_comp_info.tax_no#&UUID=#uuid#&doctype=outinvoice'
				);
			</cfscript>
			<cfset new_invoice_number = E_INVOICE_ID>
		</cfif>
		<cfcatch type="Any">
			<cfif isdefined('xml_filecontent.SendInvoiceDataResult')>
				<cfset error_code = xml_filecontent.ServiceResultDescription.XmlText>
			<cfelseif isdefined('xml_filecontent.ServiceResultDescription')>
				<cfset error_code = xml_filecontent.ServiceResultDescription.XmlText>
			</cfif>
			
			<div class="tour_box_content">
				<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
					<div style="background-color: #f28b82;" class="tour_box tour_box-type2">
						<div class="tour_box_title">
							<h1>Hata Bildirimi !</h1>
						</div>
						<div class="tour_box_text" >
							<p>Fatura Gönderimi Sırasında Bir Hata Meydana Geldi !<br /></p>
							<p><cfif isdefined("error_code")>Hata Kodu :<cfoutput> #error_code#</cfoutput></cfif></p>
						</div>
					</div>
				</div>
			</div>
			<cfif not isdefined("attributes.is_multi")>
				<cfabort>
			</cfif>
		</cfcatch>
	</cftry>
</cfif>