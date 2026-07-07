<cfcontent type="application/json; charset=utf-8">
<cfparam name="data.dashboard_id" default="0">
<cfparam name="data.dashboard_name" default="">
<cfparam name="data.m_id" default="0">
<cfparam name="data.is_favorite" default="0">
<cfparam name="data.is_public" default="0">
<cfsetting showdebugoutput="no">
<cftry>
  <cfset rawBody = toString(getHttpRequestData().content)>
  <cfset data = deserializeJSON(rawBody)>
  <cfsavecontent variable="ssss">
    <cfdump var="#data#">
  </cfsavecontent>
  <cffile action="write" output="#ssss#" file="c:\\update_dashboard_dump.html">
  <cfquery datasource="#DSN#">
    UPDATE 
      DASHBOARD_DEFS
    SET 
        DASHBOARD_NAME = <cfqueryparam value="#data.dashboard_name#" cfsqltype="cf_sql_varchar">,
        MODULE_ID = <cfqueryparam value="#data.m_id#" cfsqltype="cf_sql_integer">,
        IS_PUBLIC = <cfqueryparam value="#data.is_public#" cfsqltype="cf_sql_bit">,
        UPDATE_DATE = #now()#,
        UPDATE_EMP = #session.ep.userid#
    WHERE 
        DASHBOARD_ID = <cfqueryparam value="#data.dashboard_id#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfquery datasource="#DSN#">
    UPDATE 
        DASHBOARD_USER
    SET 
        IS_FAVORITE = <cfqueryparam value="#data.is_favorite#" cfsqltype="cf_sql_bit">
    WHERE 
        DASHBOARD_ID = <cfqueryparam value="#data.dashboard_id#" cfsqltype="cf_sql_integer">
        AND
        EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfoutput>{"success":true}</cfoutput>
  <cfcatch>
    <cfsavecontent variable="ssss">
        <cfdump var="#cfcatch#">
    </cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\\update_dashboard_hata.html">
    <cfoutput>{"success":false,"error":"#cfcatch.message#"}</cfoutput>
  </cfcatch>
</cftry>