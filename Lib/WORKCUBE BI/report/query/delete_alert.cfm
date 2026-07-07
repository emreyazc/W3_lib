<cftry>
    <cfcontent type="application/json; charset=utf-8">

    <cfset raw = toString(getHTTPRequestData().content ?: "")>
    <cfif NOT len(raw)>
        <cfoutput>#serializeJSON({error="Boş gövde"})#</cfoutput>
        <cfabort>
    </cfif>

    <cfset body = deserializeJSON(raw)>
    <cfset alertId = val(body.alertId ?: 0)>

    <cfif NOT alertId>
        <cfoutput>#serializeJSON({error="Eksik parametre"})#</cfoutput>
        <cfabort>
    </cfif>

    <cfset userId = val(session.user_id ?: 0)>

    <cfquery datasource="#DSN#">
        DELETE FROM DASHBOARD_ALERT_RULES WHERE ALERT_ID = <cfqueryparam value="#alertId#" cfsqltype="cf_sql_integer"> AND EMPLOYEE_ID = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfoutput>#serializeJSON({status="ok"})#</cfoutput>

<cfcatch type="any">
    <cfsavecontent variable="ssss">
        <cfdump var="#cfcatch#">
    </cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\\delete_alert.html">
    <cfheader statuscode="500" statustext="Server Error">
    <cfoutput>#serializeJSON({error=true, message=cfcatch.message})#</cfoutput>
</cfcatch>
</cftry>
