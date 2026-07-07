<cfcontent type="application/json; charset=UTF-8">
<cfsetting showdebugoutput="no">
<cftry>
  <!--- POST ile gelen JSON'u oku --->
  <cfset rawBody = toString(getHttpRequestData().content)>
  <cfset data = deserializeJSON(rawBody)>
  <cfparam name="data.dashboard_id" default="0">
    <cfquery datasource="#DSN#">
        DELETE FROM DASHBOARD_USER WHERE DASHBOARD_ID = <cfqueryparam value="#data.dashboard_id#" cfsqltype="cf_sql_integer">   
    </cfquery> 
    <cfquery datasource="#DSN#">
        DELETE FROM DASHBOARD_USER_LAYOUT WHERE DASHBOARD_ID = <cfqueryparam value="#data.dashboard_id#" cfsqltype="cf_sql_integer">   
    </cfquery> 
    <cfquery datasource="#DSN#">
        DELETE FROM DASHBOARD_DEFS WHERE DASHBOARD_ID = <cfqueryparam value="#data.dashboard_id#" cfsqltype="cf_sql_integer">   
    </cfquery> 
  <cfoutput>{"success":true}</cfoutput>
  <cfcatch>
    <cfsavecontent variable="ssss">
        <cfdump var="#cfcatch#">
    </cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\\delete_dashboard_hata.html">
    <cfoutput>{"success":false,"error":"#cfcatch.message#"}</cfoutput>
  </cfcatch>
</cftry>