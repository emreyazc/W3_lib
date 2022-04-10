<!--- 
    Description: Zimmet İade Şablonu  - Birikim Pilleri
    File: 5B7FC6F2-969F-A6C2-2FB67D7E1A603272.cfm.
    Author: Birikim Pilleri - Yunus Emre Yazıcı
    Date: 14.06.2021
--->
<!doctype html>
<html lang="en">
  <head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-BmbxuPwQa2lc/FVzBcNJ7UAyJxM6wuqIj61tLrc4wSX0szH/Ev+nYRRuWlolflfl" crossorigin="anonymous">

  </head>
  <body>

<cfif isdefined("attributes.action_type") and len(attributes.action_type)>
	<cfset attributes.id = attributes.action_type>
</cfif>
<cfif isdefined("attributes.action_id") and len(attributes.action_id)>
	<cfset attributes.action_type = attributes.action_id> 
	<cfset attributes.id = attributes.action_type>
</cfif>

<cfquery name="GET_ASSETP" datasource="#DSN#">
	SELECT 
		*
	FROM
		ASSET_P
	WHERE
		ASSET_P.ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
</cfquery>

<!--- <cfdump var = "#GET_ASSETP#"> --->

<cfquery name="CHECK" datasource="#DSN#">
	SELECT 
		ASSET_FILE_NAME2, 
		COMPANY_NAME, 
		TEL_CODE,
		TEL,
		TEL2,
		TEL3,
		TEL4,
		FAX,
		ADDRESS,
		WEB,
		EMAIL
	FROM 
	 	OUR_COMPANY 
	WHERE 
		COMP_ID = #session.ep.company_id#
</cfquery>
<div class="container center" style="width:750px">
<br/><br/><br/><br/><br/>
<table align="right">
        <td><b><cf_get_lang_main no='330.Tarih'>: 
		<cfscript>
		writeOutput(dateformat(now(), "DD / MM / YYYY") & "")
		</cfscript>
		</td>
</table>

<br/>

<table class="table table-borderless">
	<thead>
		<th scope="row"></th>
			<cfoutput>
			
			<td scope="col"><img src="#file_web_path#settings/#CHECK.asset_file_name2#" border="0"></td>
			<td scope="col" align="right"> <span class="headbold"><b>#CHECK.company_name#</b></span></br>
				<cfset adres="#CHECK.address#">
				<pre>
					#Wrap(adres, 60)#
				</pre>
				<br/>
				<b><cf_get_lang_main no='87.Tel'>:</b>(#CHECK.tel_code#)
				<cfif Len(CHECK.tel)>#CHECK.tel#,</cfif>
				<cfif Len(CHECK.tel2)>#CHECK.tel2#,</cfif>
				<cfif Len(CHECK.tel3)>#CHECK.tel3#,</cfif>
				<cfif Len(CHECK.tel4)>#CHECK.tel4# </cfif>
				<b><cf_get_lang_main no='76.Fax'>:</b>(#CHECK.tel_code#) #CHECK.fax#<br/>
				#CHECK.web# - info@birikimpilleri.com
			</td>
			</cfoutput>
	   
		</thead>
	</table>
<br/><br/><br/><br/>
<table align="center">
    <tr>
        <td><b><font size="+1" face="Arial, Helvetica, sans-serif">Zimmet İade Formu</font></b></td>
    </tr>
</table>
		
<br/><br/>
<cfoutput>

    <table class="table table-borderless" style="text-align:left">
            <tr>
                <td>
                    <b>#GET_ASSETP.ASSETP#</b> isimli varlık iade alınıp, muhafaza edilmesi için 
                    <b>#get_emp_info(session.ep.USERID,0,0)#</b>&nbsp;'a teslim edilmiş ve zimmetlenmiştir.<br/><br/><br/>
                </td>
				</table>
				<table class="table table-bordered d-flex">
					<tr>
						<td>Demirbaş Numarası</td>
						<td>#GET_ASSETP.inventory_number#<br />
						</td>
					</tr>
					<tr>
						<td>Seri Numarası</td>
						<td>#GET_ASSETP.serial_no#</td>
					</tr>
					<tr>
						<td>Özel Kod</td>
						<td>#GET_ASSETP.primary_code#</td>
					</tr>
					<tr>
						<td>Açıklama</td>
						<td>#GET_ASSETP.ASSETP_DETAIL#</td>
					</tr>
				  </table>
			<br/>
			<table class="table table-borderless">
            </tr>
			<br/>
        <tr>
            <td scope="col" align="left"><b>Zimmet Alan</b></td>
            <td scope="col" align="right"><b>Zimmet Veren</b></td>
        </tr>
        <tr>
            <td scope="row" align="left">#get_emp_info(session.ep.USERID,0,0)#</td>
            <td scope="row" align="right">#get_emp_info(get_assetp.employee_id,0,0)#</td>
        </tr>
    </table>
	</div>
</cfoutput>
</body>
</html>

<style>
	pre {
	margin-bottom: -25px;	
	font-family: Sans-serif;
	font-size: 8pt; 
	} 
</style>