<!--- FBS 20080805 toplu odeme kosullari eklendi --->
<cf_get_lang_set module_name="cash"><!--- sayfanin en altinda kapanisi var --->
<cfif isdefined("attributes.keyword") and attributes.keyword is 'multi_payment'>
	<cfset table_name = "CASH_ACTIONS">
	<cfset column_name = "MULTI_ACTION_ID">
<cfelse>
	<cfset table_name = "CASH_ACTIONS">
	<cfset column_name = "ACTION_ID">
</cfif>
<cfquery name="get_action_detail" datasource="#dsn2#">
	SELECT
		*
	FROM
		#table_name#
	WHERE
		#column_name# = #attributes.action_id#
	ORDER BY
		ACTION_ID
</cfquery>
<cfquery name="get_cashes" datasource="#dsn2#">
	SELECT * FROM CASH WHERE CASH_ID = #get_action_detail.cash_action_from_cash_id#
</cfquery>
<cfquery name="get_action_rate" datasource="#dsn#">
	SELECT * FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id# AND MONEY = '#get_cashes.cash_currency_id#'
</cfquery>
<cfquery name="check" datasource="#dsn#">
	SELECT
		COMPANY_NAME,
		TEL_CODE,
		TEL,
		TEL2,
		TEL3,
		TEL4,
		FAX,
		ADDRESS,
		WEB,
		EMAIL,
		ASSET_FILE_NAME3,
		ASSET_FILE_NAME3_SERVER_ID,
		TAX_OFFICE,
		TAX_NO
	FROM
		OUR_COMPANY
	WHERE
		<cfif isDefined("session.ep.company_id")>
			COMP_ID = #session.ep.company_id#
		<cfelseif isDefined("session.pp.company")>	
			COMP_ID = #session.pp.company_id#
		</cfif> 
</cfquery>

<cfset genel_toplam = 0>
<div align="left">
	<br/><br/><br/>
	<table width="650" border="0" cellspacing="0" cellpadding="0">
		<cfif len(check.asset_file_name3)>
			<tr>
				<td style="text-align:right;"><cf_get_server_file output_file="settings/#check.asset_file_name3#" output_server="#check.asset_file_name3_server_id#" output_type="5"></td>
			</tr>
		</cfif>
		<tr> 
			<td valign="top">
				<cfoutput query="check">
					<font class="headbold">#company_name#</font><br/>
					<b><cf_get_lang_main no='87.Telefon'> : </b> (#tel_code#) - #tel#  #tel2#  #tel3# #tel4# <br/>
					<b><cf_get_lang_main no='76.Fax'> : </b> #fax# <br/>
					#address#<br/>
					<b><cf_get_lang_main no='1350.Vergi Dairesi'> - <cf_get_lang_main no='75.No'>:</b> #TAX_OFFICE# - #TAX_NO#<br/>
					#web# - #email#
				</cfoutput>
			</td>
		</tr>
	</table>
	<cfloop query="get_action_detail">
	<cfoutput>
	<table width="650" border="0">
		<tr>
			<td colspan="5"><hr></td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
			<td style="text-align:right;"><cf_get_lang_main no='215.Kayıt Tarihi'> : <strong>#dateformat(get_action_detail.record_date,dateformat_style)#</strong></td>
		</tr>
		<tr>
			<td colspan="4"><cf_get_lang no='107.Tediye Makbuzu No'> :<strong>#get_action_detail.paper_no#</strong></td>
			<td style="text-align:right;"><cf_get_lang_main no='330.Tarih'> : <strong>#dateformat(get_action_detail.ACTION_DATE,dateformat_style)#</strong></td>
		</tr>
		<tr>
			<td height="50" colspan="5">
				<cfif len(get_action_detail.CASH_ACTION_TO_COMPANY_ID)>
					<strong>#get_par_info(get_action_detail.CASH_ACTION_TO_COMPANY_ID,1,1,0)#</strong>
				</cfif>
				<cfif len(get_action_detail.CASH_ACTION_TO_CONSUMER_ID)>
					<strong>#get_cons_info(get_action_detail.CASH_ACTION_TO_CONSUMER_ID,0,0)#</strong>
				</cfif>
				<cfif len(get_action_detail.CASH_ACTION_TO_EMPLOYEE_ID)>
					<strong>#get_emp_info(get_action_detail.CASH_ACTION_TO_EMPLOYEE_ID,0,0)#</strong>
				</cfif>
				<cf_get_lang no='108.Hesabına Mahsuben Yalnız'>
				<cfset mynumber = get_action_detail.CASH_ACTION_VALUE >
				<cfset mybirim = '#get_cashes.CASH_CURRENCY_ID#'>
				<cf_n2txt number="myNumber" para_birimi="#mybirim#">
				<strong>#mynumber#</strong>
				<cf_get_lang no='109.Ödenmiştir'>
			</td>
		</tr>
	</table>
	<table width="650">
		<tr>
			<td style="text-align:right;">
			<table width="100%" border="0">
				<tr>
					<td colspan="2"><strong><cf_get_lang_main no='217.Açıklama'> </strong>: #get_action_detail.action_detail#</td>
				</tr>
				<tr>
					<td style="text-align:right;" width="300"><strong><cf_get_lang_main no='1233.Nakit'></strong> : #TLFormat(get_action_detail.CASH_ACTION_VALUE)#&nbsp;#get_action_rate.MONEY#</td>
					<td style="text-align:right;"><strong><cf_get_lang no='112.Ödemeyi Yapan'></strong> : <cfif len(get_action_detail.PAYER_ID)>#get_emp_info(get_action_detail.PAYER_ID,0,0)#</cfif></td>
				</tr>
				<cfset genel_toplam = genel_toplam + get_action_detail.CASH_ACTION_VALUE>
				<cfif not isdefined("attributes.keyword")>
				<tr>
					<td style="text-align:right;"><strong><cf_get_lang_main no='80.Toplam'></strong> : #TLFormat(get_action_detail.CASH_ACTION_VALUE)#&nbsp;#get_action_rate.MONEY#</td>
					<td style="text-align:right;">&nbsp;</td>
				</tr>
				</cfif>
			</table>
			</td>
		</tr>
	</cfoutput>
	</cfloop>
		<cfif isdefined("attributes.keyword") and attributes.keyword is 'multi_payment'>
		<tr>
			<td><hr></td>
		</tr>
		<tr>
			<td style="text-align:right;"><strong><cf_get_lang_main no='80.TOPLAM'> : <cfoutput>#TLFormat(genel_toplam)# #get_action_rate.money#</cfoutput></strong></td>
		</tr>
		</cfif>
	</table>
</div>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
