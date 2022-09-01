<!---
	Date : 14.04.2022
	Desc : IK ilanları içindir.
---->

<cfcomponent>
	<cfset dsn = application.systemParam.systemParam().dsn>
	<cffunction name="control_notice_work" access="public" returntype="any">
	
		<cfargument name="version" type="any" default="">
		<cfset result = structnew()>
			<cftry>
				<cfquery name="get_notice_work" datasource="#dsn#">
					SELECT 
						*
					FROM
						NOTICES
					WHERE
						STATUS = 1
						AND 
						STARTDATE <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(now())#">
						AND <cfqueryparam cfsqltype="cf_sql_timestamp" value="#createodbcdate(now())#"> <= FINISHDATE
            	</cfquery>

			<cfset result.error=0>		
			<cfset result.notice_list = ArrayNew(1)>
			
			<cfoutput query="get_notice_work">
				<cfset result.notice_list[currentRow] = structnew()>
				
				<cfset result.notice_list[currentRow].baslik = notice_head>
				<cfset result.notice_list[currentRow].detay = detail>
				<cfset result.notice_list[currentRow].start_date = startdate>
				<cfset result.notice_list[currentRow].finish_date = finishdate>
				<cfset result.notice_list[currentRow].ilan_no = notice_no>
				<cfset result.notice_list[currentRow].ilan_id = notice_id>
				<cfset result.notice_list[currentRow].ilan_cat_id = notice_cat_id>
			</cfoutput>

			<cfcatch type="any">
            <cfset result.error=1>
			</cfcatch>
			</cftry>
			<cfset donus = serializeJSON(result)>
			<cfset donus = replace(donus,'//','','one')>
			<cfreturn donus>
	</cffunction>
</cfcomponent>