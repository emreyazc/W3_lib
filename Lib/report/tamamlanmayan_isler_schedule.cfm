<!---
	Desc : Tamamlanmayan işler için mail bilgilendirmesi yapar.
	Date : 04.03.2022
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->

<!---
	work_currency_id = 26 VE 81 (başlamadı ve başladı aşamaları)
--->

	<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
		SELECT COMP_ID,COMPANY_NAME,EMAIL,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME2 FROM OUR_COMPANY WHERE COMP_ID = 1
	</cfquery>
	
	<cfset session.ep.company_id = GET_COMP_ADDR.COMP_ID>
	<cfset session.ep.company = "#GET_COMP_ADDR.COMPANY_NAME#">
	<cfset session.ep.company_email = GET_COMP_ADDR.EMAIL>
	
	<cfif len(get_comp_addr.ASSET_FILE_NAME2)>
		<cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
	<cfelse>
		<cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
	</cfif>
	
	<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
	<cfset subject_mail='TAMAMLANMAYAN İŞLER LİSTESİ'>
	
	<cfquery name="GET_EMP" datasource="#DSN#">
		SELECT
			E.EMPLOYEE_ID,
			E.EMPLOYEE_NAME,
			E.EMPLOYEE_SURNAME,
			E.EMPLOYEE_EMAIL
		FROM
			EMPLOYEES E
		WHERE	
			E.EMPLOYEE_STATUS = 1
			AND E.EMPLOYEE_EMAIL IS NOT NULL
	</cfquery>
	
	<cfloop query="#GET_EMP#">
		<cfquery name="GET_WORKS" datasource="#DSN#">
			SELECT
				PW.WORK_ID,
				PW.WORK_NO,
				PW.WORK_HEAD,
				PR.PROJECT_ID,
				PR.PROJECT_HEAD,
				PW.PROJECT_EMP_ID,
				PW.TARGET_FINISH,
				PTR.STAGE
			FROM
				PRO_WORKS PW
				LEFT JOIN PROCESS_TYPE_ROWS PTR ON PTR.PROCESS_ROW_ID = PW.WORK_CURRENCY_ID
				LEFT JOIN PRO_PROJECTS PR ON PR.PROJECT_ID = PW.PROJECT_ID
			WHERE
				(PW.WORK_CURRENCY_ID = 26 OR PW.WORK_CURRENCY_ID = 81)
				AND PW.WORK_STATUS = 1
				AND PW.PROJECT_EMP_ID = #EMPLOYEE_ID#
			ORDER BY PW.TARGET_FINISH ASC
		</cfquery>
	
		<cfif len(GET_WORKS.WORK_ID)>
			
			<!---
			<cfset to_mail="yunusemreyazici@birikimpilleri.com">
			<cfset to_mail="#GET_EMP.EMPLOYEE_EMAIL#">
			--->
	
			<cfif len(GET_EMP.EMPLOYEE_EMAIL)>
				<cfset to_mail="#GET_EMP.EMPLOYEE_EMAIL#">
		
				<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">

					<cfmailparam name = "Importance" value = "High">
				
					<table cellpadding="0" cellspacing="0" align="center" width="1100">
						<tr align="center">
							<td align="center"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
						</tr>
						<tr>
							<td colspan="4">&nbsp;</td>
						</tr>
						<tr>
							<td align="center" style="font-size:15px; margin-left:20px"><p>Günaydın.</p> <p>Sayın, #GET_EMP.EMPLOYEE_NAME# #GET_EMP.EMPLOYEE_SURNAME# <strong>#dateformat(now(), dateformat_style)# itibarı ile</strong> üzerinizde <b>Tamamlanmamış</b> aşamasında işler bulunmaktadır.</p></td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<table style="border:1px solid black">
								<tr style="font-size:15px">
									<table cellpadding="0" cellspacing="0" align="left" width="1100">
										<thead>
											<tr align="left" style="font-size:15px; background-color:rgb(224, 224, 224)">
												<th style="width:5%; margin-left:5px; margin-right:5px">&nbsp;</th>
												<th style="width:5%; margin-left:5px; margin-right:5px">Sıra</th>
												<th style="width:10%; margin-left:5px; margin-right:5px">İş No.</th>
												<th style="width:40%; margin-left:5px; margin-right:5px">İş Adı</th>
												<th style="width:10%; margin-left:5px; margin-right:5px">Aşama</th>
												<th style="width:10%; margin-left:5px; margin-right:5px">Bitiş Tarihi</th>
												<th style="width:35%; margin-left:5px; margin-right:5px">Proje</th>
											</tr>
											<tr>
												<td colspan="7">
													<hr>
												</td>
											</tr>
											<tr>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
												<td>&nbsp;</td>
											</tr>
										</thead>
										<tbody>
											<cfloop query="GET_WORKS">
												<tr align="center">
													<td>&nbsp;</td>
													<td align="left">#currentRow#.</td>
													<td align="center"><a href="https://erp.birikimpilleri.com/index.cfm?fuseaction=project.works&event=det&id=#WORK_ID#">#WORK_NO#</a></td>
													<td align="left"><a href="https://erp.birikimpilleri.com/index.cfm?fuseaction=project.works&event=det&id=#WORK_ID#">#WORK_HEAD#</a></td>
													<td align="left">#STAGE#</td>
													<td align="left">#dateformat(TARGET_FINISH,dateformat_style)#</td>
													<td align="left"><a href="https://erp.birikimpilleri.com/index.cfm?fuseaction=project.projects&event=det&id=#PROJECT_ID#">#PROJECT_HEAD#</a></td>
												</tr>
											</cfloop>
										</tbody>
									</table>
								</tr>
								<tr>
									<td align="center" style="font-size:15px"><p><strong>İyi çalışmalar.</strong></p><td>
								</tr>
							</table>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
						<tr align="center">
							<td class="unbold" style="font-size:12px;">
							#get_comp_addr.company_name#<br>
							#get_comp_addr.address#<br>
							<cf_get_lang_main no="87.Tel">: #get_comp_addr.tel_code# #get_comp_addr.tel# <cf_get_lang_main no="76.Fax">: #get_comp_addr.tel_code# #get_comp_addr.fax#<br>
							<a href="mailto:#get_comp_addr.web#">#get_comp_addr.web#</a>
							</td>
						</tr>
					</table>
				</cfmail>	
			</cfif>
		</cfif>
	</cfloop>