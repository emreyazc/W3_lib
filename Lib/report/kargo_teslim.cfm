<style type="text/css">
    .css1 {font-size:16px;font-family:arial,verdana;color:000000;}
    .css2 {font-size:20px;font-family:arial,verdana;color:000000; background-color:white;font-weight:bold;}
    .css3 {font-size:14px;font-family:arial,verdana;color:000000;}
</style>

<cfif isdefined("attributes.invoice_date") and isdate(attributes.invoice_date)>
	<cf_date tarih=attributes.invoice_date>
<cfelse>
	<cfset attributes.invoice_date = createodbcdatetime('#year(now())#-#month(now())#-#day(now())#')>
</cfif>
<cfif isdefined("attributes.invoice_datee") and isdate(attributes.invoice_datee)>
	<cf_date tarih=attributes.invoice_datee>
<cfelse>
	<cfset attributes.invoice_datee = createodbcdatetime('#year(now())#-#month(now())#-#day(now())#')>
</cfif>

<cfparam name="attributes.is_excel" default="">
<cfparam name="attributes.ship_methods" default="">
<!---
<cfparam name="attributes.invoice_dept" default="">
--->	
<cfquery name="get_ship" datasource="#DSN#">
  SELECT SHIP_METHOD_ID, SHIP_METHOD FROM SHIP_METHOD ORDER BY SHIP_METHOD ASC
</cfquery>

<cfquery name="GET_SHIP_RESULT" datasource="#DSN2#">
	SELECT
		I.INVOICE_ID,
		I.INVOICE_NUMBER,
		SM.SHIP_METHOD,
		C.FULLNAME,
		I.COMPANY_ID,
		I.CONSUMER_ID,
		I.SHIP_ADDRESS,
		SR.SENDING_ADDRESS,
		SRP.PACKAGE_PIECE AS PAKET_ADET,
		SRP.PACKAGE_TYPE AS PAKET_TIP_ID,
		SPT.PACKAGE_TYPE AS PAKET_TIP,
		I.INVOICE_DATE,
		CS.CONSUMER_NAME,
		CS.CONSUMER_SURNAME,
		I.SERIAL_NO
	FROM
		INVOICE I
		LEFT JOIN #DSN#.COMPANY C ON C.COMPANY_ID = I.COMPANY_ID
		LEFT JOIN #DSN#.CONSUMER CS ON CS.CONSUMER_ID = I.CONSUMER_ID
		LEFT JOIN INVOICE_SHIPS ISHIP ON ISHIP.INVOICE_ID = I.INVOICE_ID
		LEFT JOIN SHIP_RESULT_ROW SRR ON SRR.SHIP_ID = ISHIP.SHIP_ID
		LEFT JOIN SHIP_RESULT_PACKAGE SRP ON SRP.SHIP_ID = SRR.SHIP_RESULT_ID
		LEFT JOIN SHIP_RESULT SR ON SR.SHIP_RESULT_ID = SRR.SHIP_RESULT_ID
		LEFT JOIN #DSN#.SETUP_PACKAGE_TYPE SPT ON SPT.PACKAGE_TYPE_ID = SRP.PACKAGE_TYPE
		LEFT JOIN #DSN#.SHIP_METHOD SM ON SM.SHIP_METHOD_ID = I.SHIP_METHOD
	WHERE
		I.PURCHASE_SALES = 1 AND
		I.INVOICE_DATE between #attributes.invoice_date# AND #attributes.invoice_datee#
		<cfif isdefined("attributes.ship_methods") and len(attributes.ship_methods)>
			AND SM.SHIP_METHOD_ID IN (#attributes.ship_methods#)
		</cfif>
		<cfif session.ep.company_id eq 1>
			AND I.DEPARTMENT_ID = 44
		<cfelseif session.ep.company_id eq 1>
			AND I.DEPARTMENT_ID = 47
		</cfif>
		<!---
		<cfif isDefined("attributes.invoice_dept") and len(attributes.invoice_dept)>
			AND I.DEPARTMENT_ID IN (#attributes.invoice_dept#)
		</cfif>
		--->
		ORDER BY
		I.INVOICE_DATE ASC
</cfquery>

<cfquery name="GET_COMP_ADDR" datasource="#DSN#">
	SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME2 FROM OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
</cfquery>

<!---
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		B.BRANCH_FULLNAME AS BRANCH_NAME
	FROM
		DEPARTMENT D
		LEFT JOIN BRANCH B ON B.BRANCH_ID = D.BRANCH_ID 
	WHERE
		B.COMPANY_ID = #session.ep.company_id#
		AND DEPARTMENT_STATUS = 1
		AND IS_STORE = 1
		AND (D.DEPARTMENT_ID = 44 OR D.DEPARTMENT_ID = 47)
</cfquery>
--->

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default='#GET_SHIP_RESULT.recordcount#'>
<cfif (isdefined('attributes.is_excel') and  attributes.is_excel eq 1)>
	<cfset attributes.startrow=1>
	<cfset attributes.maxrows=GET_SHIP_RESULT.recordcount>
<cfelse>
	<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
</cfif>
<cfoutput>
<cfform name="search" method="post" action="#request.self#?fuseaction=report.detail_report&report_id=#attributes.report_id#">
<input type="hidden" name="form_submitted" id="form_submitted" value="1">
	<cf_big_list_search_area>
		<div class="row">
			<div class="col col-12 form-inline">
			
				<div class="form-group" id="item-date">
					<div class="input-group x-14">
						<cfinput type="text" name="invoice_date" value="#dateformat(attributes.invoice_date,dateformat_style)#" >
						 <span class="input-group-addon"><cf_wrk_date_image date_field="invoice_date"></span>
					</div>
				</div>
				
				<div class="form-group" id="item-datee">
					<div class="input-group x-14">
						<cfinput type="text" name="invoice_datee" value="#dateformat(attributes.invoice_datee,dateformat_style)#" >
						 <span class="input-group-addon"><cf_wrk_date_image date_field="invoice_datee"></span>
					</div>
				</div>
				
				<div class="form-group" id="item-ship_methods">
                    <label class="col col-12">Sevk Yöntemi</label>
                    <div class="col col-12">
						<select name="ship_methods" id="ship_methods" style="width:120px;height:100px;" multiple>
							<cfloop query="get_ship">
							  <option value="#get_ship.SHIP_METHOD_ID#" <cfif isdefined("attributes.ship_methods") and listfindnocase(attributes.ship_methods,get_ship.SHIP_METHOD_ID)> selected</cfif>>#get_ship.SHIP_METHOD#</option>
							</cfloop>
						</select>
                    </div>
                </div>
				
				<div class="col col-12 form-inline">		
					<label><cf_get_lang dictionary_id='57858.Excel Getir'><input type="checkbox" name="is_excel" id="is_excel" value="1" <cfif attributes.is_excel eq 1>checked</cfif>></label>	
					<div class="form-group">
						<cf_wrk_search_button search_function='kontrol()' button_type="3">
					</div>
					<div class="form-group">
					    <a href="javascript://"onclick="printSa();" title="<cf_get_lang_main no='1943.Yazıcıya Gönder'>" >&nbsp;<i class="fa fa-print fa-2x font-blue"></i>&nbsp;</a>
					</div>
				</div>

				<!---
				<div class="form-group" id="item-department">
					<label class="col col-12">Depo</label>
					<div class="col col-12">
						<select name="invoice_dept" id="invoice_dept" style="width:120px;height:200px;" multiple>
							<cfloop query="GET_DEPARTMENT">
							  <option value="#GET_DEPARTMENT.DEPARTMENT_ID#" <cfif isdefined("attributes.invoice_dept") and listfindnocase(attributes.invoice_dept,GET_DEPARTMENT.DEPARTMENT_ID)> selected</cfif>>#GET_DEPARTMENT.BRANCH_NAME# - #GET_DEPARTMENT.DEPARTMENT_HEAD#</option>
							</cfloop>
						</select>
					</div>
				</div>
				--->
			</div>	 	
		</div>	
	</cf_big_list_search_area>				
</cfform> 


<cfif isdefined("attributes.form_submitted")>
		 <cfif isdefined('attributes.is_excel') and attributes.is_excel eq 1>
			<cfset filename = "#createuuid()#">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/msexcel;charset=utf-16">
			<cfheader name="Content-Disposition" value="attachment; filename=#filename#.xls">
			<meta http-equiv="Content-Type" content="text/html; charset=utf-16">	
			<cfset attributes.startrow=1>
				<cfset attributes.maxrows=GET_SHIP_RESULT.recordcount>
		</cfif>
<cf_big_list>
<cfif isdefined('attributes.is_excel') and attributes.is_excel neq 1>
<td align="center">
	<img src="#listfirst(fusebox.server_machine_list,';')#/documents/settings/#get_comp_addr.asset_file_name2#" width="250"/>
</td>	
</cfif>
<table cellpadding="3" cellspacing="0" class="css2" align="center" border="1" width="100%">
	<thead>
		<tr>
			<th>No.</th>
			<th>Tarih</th>
			<th>Müşteri</th>
			<th>Fatura No.</th>
			<th>Gönderim Adresi</th>
			<th>Sevk Yöntemi</th>
			<cfif session.ep.company_id eq 1>
				<th>Paket Sayısı</th>
				<th>Paket Tipi</th>
			</cfif>
		</tr>
	</thead>

	<tbody>
		<cfloop query="GET_SHIP_RESULT">
			<tr>
				<td>#currentRow#.</td>
				<td align="center">#dateformat(invoice_date,dateformat_style)#</td>
				<td >
					<cfif len(GET_SHIP_RESULT.company_id)>
						#fullname#
					<cfelseif len(GET_SHIP_RESULT.consumer_id)>
						#consumer_name# #consumer_surname#  
					 <cfelse>
					</cfif>
				</td>
				<td align="center">#GET_SHIP_RESULT.SERIAL_NO#</td>
				<td >#GET_SHIP_RESULT.SHIP_ADDRESS#</td>
				<td>#GET_SHIP_RESULT.SHIP_METHOD#</td>
				<cfif session.ep.company_id eq 1>
					<td align="center">#PAKET_ADET#</td>
					<td align="center">#PAKET_TIP#</td>
				</cfif>
			</tr>
		</cfloop>
	</tbody>
	
</table></br>

 <table  border="0" cellpadding="0" cellspacing="3"  align="center" width="99%">
	<tr>
		<td align="left"><strong>Teslim Eden<strong></td>
		<td align="right"><strong>Teslim Alan<strong></td>
	</tr>
	<tr>
		<td colspan="3" align="left"><cfoutput><strong>#SESSION.EP.name# #SESSION.EP.surname#</strong></cfoutput></td>
		<td align="right"><strong><strong></td>
	</tr>	
  </table>
  </cf_big_list>
</cfif>

</cfoutput>
<script language="JavaScript">	
	function kontrol()
	{	
	if(document.search.is_excel.checked==false)
			{
				document.search.action="<cfoutput>#request.self#?fuseaction=report.detail_report&report_id=#attributes.report_id#</cfoutput>";
			}
            else
            {
				document.search.action="<cfoutput>#request.self#?fuseaction=report.emptypopup_detail_report&report_id=#attributes.report_id#</cfoutput>";
			
            }
			
		
	}
	</script>