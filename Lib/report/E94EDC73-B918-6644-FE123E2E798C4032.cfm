<!---
	Date : 11.04.2022
	Desc : Proje Görevlilerine Proje Bitene Kadar Günlük Mail Gönderir
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfscript>
	if(isdefined("session.ep.userid"))
	{
		writeOutput("Bu rapor manuel çalıştırılamaz.");
		abort;
	}
</cfscript>

<cfquery name="GET_PROJECT" datasource="#DSN#">
	SELECT
		E.EMPLOYEE_NAME+' '+EMPLOYEE_SURNAME AS GOREVLI,
		E.EMPLOYEE_EMAIL AS GOREVLI_MAIL,
		PP.PROJECT_ID,
		PP.PROJECT_NUMBER AS PROJE_NO,
		PP.PROJECT_HEAD AS PROJE_ADI,
		PP.TARGET_START AS PROJE_BASLANGIC,
		PP.TARGET_FINISH AS PROJE_BITIS,
		PC.MAIN_PROCESS_CAT AS PROJE_KATEGORI
	FROM 
		EMPLOYEES E
		LEFT JOIN WORKGROUP_EMP_PAR WEP ON WEP.EMPLOYEE_ID = E.EMPLOYEE_ID
		LEFT JOIN PRO_PROJECTS PP ON PP.PROJECT_ID = WEP.PROJECT_ID
		LEFT JOIN SETUP_MAIN_PROCESS_CAT PC ON PC.MAIN_PROCESS_CAT_ID = PP.PROCESS_CAT
	WHERE
		PROJECT_STATUS = 1			<!--- sadece aktif projelerin gelmesi için. --->
		AND PP.PRO_CURRENCY_ID = 85		<!--- Aşaması BAŞLADI olan projelerin gelmesi için. --->
		AND E.EMPLOYEE_ID = 111
</cfquery>

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
<cfset subject_mail='GÖREVLİSİ OLDUĞUNUZ PROJELER - #dateformat(now(), dateformat_style)#'>

<cfif len(GET_PROJECT.GOREVLI_MAIL)>
	<cfset to_mail="#GET_PROJECT.GOREVLI_MAIL#">
	<cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
		<cfmailparam name ="Importance" value ="High">

		<table cellpadding="0" cellspacing="0" align="left" width="1100">
			<!---
			<tr align="left">
				<td align="left"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
			</tr>
			--->
			<tr>
				<td align="left" style="font-size:15px; margin-left:20px">
					<p>Günaydın.</p> 
					<p>Sayın, #GET_PROJECT.GOREVLI# <strong>#dateformat(now(), dateformat_style)# itibarı ile</strong> görevlisi olduğunuz <b>Projelerin</b> listesi aşağıdadır.</p>
				</td>
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
								<tr align="left" style=" height:40px; font-size:15px; background-color:rgb(224, 224, 224)">
									<th style="width:2%; margin-left:5px; margin-right:5px">&nbsp;</th>
									<th style="width:5%; margin-left:5px; margin-right:5px">Sıra</th>
									<th style="width:10%; margin-left:5px; margin-right:5px">Proje No.</th>
									<th style="width:30%; margin-left:5px; margin-right:5px">Proje Adı</th>
									<th style="width:10%; margin-left:5px; margin-right:5px">Kategori</th>
									<th style="width:10%; margin-left:5px; margin-right:5px">Başlangıç Tarihi</th>
									<th style="width:10%; margin-left:5px; margin-right:5px">Bitiş Tarihi</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="GET_PROJECT">
									<tr align="left" style="height:30px;">
										<td>&nbsp;</td>
										<td>#currentRow#.</td>
										<td><a href="https://erp.birikimpilleri.com/index.cfm?fuseaction=project.projects&event=det&id=#PROJECT_ID#">#PROJE_NO#</a></td>
										<td><a href="https://erp.birikimpilleri.com/index.cfm?fuseaction=project.projects&event=det&id=#PROJECT_ID#">#PROJE_ADI#</a></td>
										<td>#PROJE_KATEGORI#</td>
										<td>#dateformat(PROJE_BASLANGIC,dateformat_style)#</td>
										<td>#dateformat(PROJE_BITIS,dateformat_style)#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</tr>
				</table>
			</tr>
			<tr>
				<td colspan="3" align="left" style="font-size:15px">&nbsp;<td>
			</tr>
			<tr>
				<td colspan="3" align="left" style="font-size:15px"><p><strong>İyi çalışmalar.</strong></p><td>
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
			<tr align="left">
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



<cfdump var="#GET_PROJECT#">