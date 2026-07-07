<cfcontent type="application/json; charset=UTF-8">
<cfsetting showdebugoutput="no">

<cfparam name="url.dashboard_id" default="0">

<cfset dashboard_id = val(url.dashboard_id)>

<cfquery name="getDashboard" datasource="#DSN#">
  SELECT
    D.DASHBOARD_ID,
    D.DASHBOARD_NAME,
    D.MODULE_ID,
    D.IS_PUBLIC,
    U.IS_FAVORITE
  FROM
    DASHBOARD_DEFS D
    INNER JOIN DASHBOARD_USER U ON D.DASHBOARD_ID = U.DASHBOARD_ID
  WHERE
    D.DASHBOARD_ID = <cfqueryparam value="#dashboard_id#" cfsqltype="cf_sql_integer">
    AND
    U.EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif getDashboard.recordcount>
  <cfset dashboard = {
    "id": getDashboard.DASHBOARD_ID,
    "name": getDashboard.DASHBOARD_NAME,
    "module_id": getDashboard.MODULE_ID,
    "is_favorite": getDashboard.IS_FAVORITE,
    "is_public": getDashboard.IS_PUBLIC
  }>
  <cfoutput>#serializeJSON(dashboard)#</cfoutput>
<cfelse>
  <cfoutput>{"error":"Dashboard bulunamadı"}</cfoutput>
</cfif>