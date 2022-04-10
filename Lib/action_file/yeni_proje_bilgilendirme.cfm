<cfif len(attributes.action_id)>
	<cfquery name="GET_COMP_ADDR" datasource="#attributes.data_source#">
		SELECT 
			COMPANY_NAME,
			ADDRESS,
			TEL_CODE,
			TEL,FAX,
			WEB,
			ASSET_FILE_NAME2 
		FROM 
			#caller.dsn#.OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
	</cfquery>

	<cfquery name="GET_PROJECT" datasource="#caller.DSN#">
		SELECT
			PRO.PROJECT_ID AS PROJE_ID,
			PRO.TARGET_START AS BASLANGIC_TARIHI,
			PRO.TARGET_FINISH AS BITIS_TARIHI,
			PRO.PROJECT_NUMBER AS PROJE_NO,
			PRO.PROJECT_HEAD AS PROJE_BASLIK,
			PRO.PROJECT_DETAIL AS PROJE_DETAY,
			EMP_PAR.EMPLOYEE_ID,
			E.EMPLOYEE_NAME AS EMP_NAME,
			E.EMPLOYEE_SURNAME EMP_SURNAME,
			E.EMPLOYEE_EMAIL AS EMP_MAIL,
			EMP_PAR.ROLE_HEAD AS PROJE_ROL
		FROM
			PRO_PROJECTS PRO
			LEFT JOIN WORKGROUP_EMP_PAR EMP_PAR ON EMP_PAR.PROJECT_ID = PRO.PROJECT_ID
			LEFT JOIN EMPLOYEES E ON E.EMPLOYEE_ID = EMP_PAR.EMPLOYEE_ID
		WHERE
			PRO.PROJECT_ID = #attributes.action_id#
	</cfquery>
	
	
	<cfif len(get_comp_addr.ASSET_FILE_NAME2)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>

	<cfoutput query="GET_PROJECT">
		<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
		<cfset to_mail='#EMP_MAIL#'>
		<cfset subject_mail='#PROJE_NO# - YENİ PROJEDE GÖREVLENDİRİLDİNİZ '>
		<cfif len(to_mail)>
			<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
				<html></html>
					<body>
						<cfoutput>
							<table cellpadding="0" cellspacing="0" align="center" width="800">
								<tr>
									<td align="left"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
								</tr>
								<tr align="center">
									<td style="text-align:left">
										<p>Sayın #EMP_NAME# #EMP_SURNAME#, bir projede görevlendirildiniz.</p>
									</td>
								</tr>
								<tr align="center">
									<td style="text-align:left">
										<h4>Proje : <a href="http://#caller.employee_url#/#request.self#?fuseaction=project.projects&event=det&id=#PROJE_ID#" class="tableyazi">#PROJE_NO# - #PROJE_BASLIK#</a></h4>
										<h4>Başlangıç Tarihi : #dateformat(BASLANGIC_TARIHI,"dd.mm.yyyy")#</h4>
										<h4>Görev : #PROJE_ROL#</h4>
										<h4>Proje Başlangıç Tarihi : #dateformat(BASLANGIC_TARIHI,"dd.mm.yyyy")#</h4>
										<h4>Proje Bitiş Tarihi : #dateformat(BITIS_TARIHI,"dd.mm.yyyy")#</h4>
									</td>
									<td style="text-align:right">
									</td>
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
						</cfoutput>
					</body>
				</html>
			</cfmail>
		</cfif>
	</cfoutput>
</cfif>