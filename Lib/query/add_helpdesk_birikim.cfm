<cftry>
	<cfquery name="ADD_HELP" datasource="#caller.dsn2#">
		INSERT INTO
			#caller.DSN#.CUSTOMER_HELP
		(
			PARTNER_ID,
			COMPANY_ID,					
			CONSUMER_ID,
			RECORD_EMP,
			RECORD_DATE,
			RECORD_IP,
			SUBJECT,
			DETAIL,
			APP_CAT,
			PROCESS_STAGE,
			INTERACTION_DATE,
			INTERACTION_CAT,
			APPLICANT_NAME,
			APPLICANT_MAIL,
			IS_REPLY,
			IS_REPLY_MAIL,
			CUSTOMER_TELCODE,
			CUSTOMER_TELNO
		)
		VALUES
		(
			<cfif attributes.member_type is 'partner'>
			<cfif isDefined("attributes.partner_id") and len(attributes.partner_id)>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.partner_id#">,
			<cfelse>
				NULL,
			</cfif>
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">,
			NULL,
			<cfelse>
			NULL,
			NULL,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.consumer_id#">,		
			</cfif>
			82, /*System Admin id */
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.subject#">,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.detail#">,
			<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.app_cat#">,
			11,
			<cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
			<cfif isDefined("attributes.interaction_cat") and len(attributes.interaction_cat)>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.interaction_cat#">,
			<cfelse>
			NULL,
			</cfif>
			'#attributes.applicant_name#',
			'#attributes.applicant_mail#',
			1,
			1,
			'#attributes.customer_telcode#',
			'#attributes.customer_telno#'
		 )
	</cfquery>
<cfcatch  type="any">
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
