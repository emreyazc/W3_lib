<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="url.type" default="unread">

<cfset userId = session.ep.userid>

<cfif url.type EQ "read">
    <cfset condition = "IS_READ = 1">
<cfelse>
    <cfset condition = "IS_READ = 0">
</cfif>

<cfquery name="qNoti" datasource="workcube_test">
    SELECT TOP 10 
        LOG_ID,
        ALERT_MESSAGE AS MESSAGE,
        SEVERITY,
        IS_READ,
        FORMAT(LOG_DATE, 'yyyy-MM-dd HH:mm') AS DATE
    FROM DASHBOARD_NOTIFICATION
    WHERE USER_ID = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
      AND #preserveSingleQuotes(condition)#
    ORDER BY LOG_DATE DESC
</cfquery>

<cfset rows = []>
<cfloop query="qNoti">
    <cfset row = {
        "LOG_ID"   = qNoti.LOG_ID,
        "MESSAGE"  = qNoti.MESSAGE,
        "SEVERITY" = qNoti.SEVERITY,
        "IS_READ"  = qNoti.IS_READ,
        "DATE"     = qNoti.DATE
    }>
    <cfset arrayAppend(rows, row)>
</cfloop>

<cfoutput>#serializeJSON(rows)#</cfoutput>
