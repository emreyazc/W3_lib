<cfset body = deserializeJSON(toString(getHttpRequestData().content))>

<cfquery datasource="#DSN#">
    DELETE FROM DASHBOARD_USER_LAYOUT WHERE WIDGET_ID = <cfqueryparam value="#body.widget_id#" cfsqltype="cf_sql_integer">
  </cfquery>
<cfquery datasource="#DSN#">
  DELETE FROM DASHBOARD_WIDGET_DEFS WHERE WIDGET_ID = <cfqueryparam value="#body.widget_id#" cfsqltype="cf_sql_integer"> AND WIDGET_TYPE = 2
</cfquery>

<cfoutput>#serializeJSON({ "success": true, "message": "Widget silindi." })#</cfoutput>