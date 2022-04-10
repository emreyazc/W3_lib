<!---
	Desc      : Tahsilat Ekle ekranından Kayıt oluşturulunca. ilgili Cariye bilgilendirme Maili, SMS i gönderir ve gönderilen Mail ve SMS i Etkileşim olarak kaydeder.
	File      : DE294BE5-B175-E2E5-CCB67DE429C53D36.cfm
	Date  	  : 21.01.2021
	Developer : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cftry>
	<cfif len(attributes.action_id)>
		<cftransaction>
			<cfquery name="CASH_ACTIONS" datasource="#caller.DSN2#">
				SELECT
					CA.ACTION_TYPE_ID,
					CA.ACTION_TYPE,
					CA.ACTION_DATE,
					CA.PAPER_NO,
					CA.CASH_ACTION_VALUE,
					CA.OTHER_MONEY,
					CA.CASH_ACTION_FROM_COMPANY_ID AS CASH_COMPANY,
					C.COMPANY_ID,
					C.FULLNAME,
					C.COMPANY_TELCODE,
					C.COMPANY_TEL1,
					C.COMPANY_ADDRESS,
					C.COMPANY_EMAIL,
					EP.EMPLOYEE_EMAIL AS TEMSILCI_MAIL
				FROM
					CASH_ACTIONS CA
					LEFT JOIN #caller.DSN#.COMPANY C ON C.COMPANY_ID = CA.CASH_ACTION_FROM_COMPANY_ID
					LEFT JOIN #caller.DSN#.WORKGROUP_EMP_PAR WEP ON WEP.COMPANY_ID = C.COMPANY_ID
					LEFT JOIN #caller.DSN#.EMPLOYEE_POSITIONS EP ON EP.POSITION_ID = WEP.POSITION_CODE
				WHERE
					CA.ACTION_ID = #attributes.action_id#
					AND WEP.IS_MASTER = 1
			</cfquery>
		</cftransaction>

		<cfquery name="GET_COMPANY_MANAGER" datasource="#caller.DSN2#">
			SELECT
				C.MANAGER_PARTNER_ID,
				CP.COMPANY_PARTNER_TELCODE,
				CP.COMPANY_PARTNER_TEL
			FROM
				#caller.DSN#.COMPANY C
				LEFT JOIN #caller.DSN#.COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
			WHERE
				C.COMPANY_ID = #CASH_ACTIONS.CASH_COMPANY#
		</cfquery>

		<cfquery name="GET_COMP_ADDR" datasource="#caller.DSN2#">
			SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME2 FROM #caller.DSN#.OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
		</cfquery>

		<cfif len(get_comp_addr.ASSET_FILE_NAME2)>
			<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
		<cfelse>
			<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
		</cfif>

		<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
		<!---
		<cfset to_mail="yunusemreyazici@birikimpilleri.com">
		--->
		<cfset to_mail="#CASH_ACTIONS.TEMSILCI_MAIL#">		
		<cfset subject_mail='BİRİKİM PİLLERİ TAHSİLAT'>
	
		<cfif len(to_mail)>
			<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
				<html>
					<table cellpadding="0" cellspacing="0" align="center" width="800">
						<tr>
							<td align="left"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
						</tr>
						<tr align="center">
							<td style="text-align:left">
								<p>Tebrikler,</p>
								<p>#CASH_ACTIONS.TEMSILCI_MAIL#</p>
							</td>
						</tr>
						<tr>
							<p>
								<strong>#CASH_ACTIONS.FULLNAME#</strong> hesabından <strong>#caller.TLFormat(CASH_ACTIONS.CASH_ACTION_VALUE,2)# #CASH_ACTIONS.OTHER_MONEY#</strong> tutarında #CASH_ACTIONS.ACTION_TYPE# yapılmıştır.
							</p>
						</tr>
						<tr>
							<p>
								Teşekkür ederiz.
							</p>
						</tr>
						<tr align="center">
							<p>
								<strong>Muhasebe Departmanı</strong>
							</p>
						</tr>
						<tr>
							<td align="right"></td>
						</tr>
						<cfif get_comp_addr.recordcount>
							<tr>
								<td><br/><br></td>
								<td><br/><br></td>
							</tr>
							<tr>
								<td class="unbold" style="font-size:12px;">
								#get_comp_addr.company_name#<br>
								#get_comp_addr.address#<br>
								<cf_get_lang_main no="87.Tel">: #get_comp_addr.tel_code# #get_comp_addr.tel# <cf_get_lang_main no="76.Fax">: #get_comp_addr.tel_code# #get_comp_addr.fax#<br>
								<a href="mailto:#get_comp_addr.web#">#get_comp_addr.web#</a>
								</td>
							</tr>
						</cfif>
					</table>
				</html>
			</cfmail>
		</cfif>
	
		
			<!--- kurumsal hesap kontak kişisine SMS atmak için eklenmiştir. --->

			<cfif len(GET_COMPANY_MANAGER.COMPANY_PARTNER_TEL)>
				<cfset attributes.tel_no = "#GET_COMPANY_MANAGER.COMPANY_PARTNER_TEL#"> <!--- cari yetkilisi tel_no --->
				<cfset attributes.message_body = "Değerli Müşterimiz #CASH_ACTIONS.FULLNAME#, hesabınızdan #caller.TLFormat(CASH_ACTIONS.CASH_ACTION_VALUE,2)# #CASH_ACTIONS.OTHER_MONEY# tutarında #CASH_ACTIONS.ACTION_TYPE# işlemi yapılmıştır." >
				<cfinclude template="send_sms_action.cfm">
			</cfif>

			<cfset attributes.company_id = CASH_ACTIONS.CASH_COMPANY>
			<cfif len(GET_COMPANY_MANAGER.MANAGER_PARTNER_ID)>
				<cfset attributes.partner_id = GET_COMPANY_MANAGER.MANAGER_PARTNER_ID>
			</cfif>
			<cfset attributes.applicant_name = '#CASH_ACTIONS.FULLNAME#'>
			<cfset attributes.applicant_mail = '#CASH_ACTIONS.COMPANY_EMAIL#'>
			<cfset attributes.customer_telno = '#GET_COMPANY_MANAGER.COMPANY_PARTNER_TEL#'>
			<cfset attributes.customer_telcode = '#GET_COMPANY_MANAGER.COMPANY_PARTNER_TELCODE#'>
			<cfset attributes.detail = 'TAHSİLAT - #CASH_ACTIONS.PAPER_NO#'>
			<cfset attributes.subject = 'Değerli Müşterimiz #CASH_ACTIONS.FULLNAME#, hesabınızdan #caller.TLFormat(CASH_ACTIONS.CASH_ACTION_VALUE,2)# #CASH_ACTIONS.OTHER_MONEY# tutarında #CASH_ACTIONS.ACTION_TYPE# işlemi yapılmıştır.'>
			<cfset attributes.member_type = 'partner'>
			<cfset attributes.app_cat = 2>
			<cfset attributes.interaction_cat = 7>
		
			<cfinclude template="../../V16/callcenter/query/add_helpdesk_birikim.cfm">
		
	</cfif>
	<cfcatch type="any">
		<cfsavecontent variable="ssss">
			<cfdump var="#cfcatch#">
		</cfsavecontent>
		<!---
		<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
		<cfset to_mail="yunusemreyazici@birikimpilleri.com">
		<cfset subject_mail='hata'>
		
		<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
			<cfdump  var="#ssss#">
		</cfmail>
		--->
		<cffile action="write" output="#ssss#" file="#caller.download_folder#hataaaa.html">
	</cfcatch>
</cftry>