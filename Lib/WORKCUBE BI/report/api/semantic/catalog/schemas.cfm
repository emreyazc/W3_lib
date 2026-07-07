<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="url.dsn"    default="DSN">
<cfparam name="url.limit"  default="50">

<cftry>
    <cfquery name="qSchemas" datasource="#url.dsn#" cachedWithin="#CreateTimeSpan(0,0,1,0)#">
        SELECT 
            SCHEMA_NAME
        FROM 
            INFORMATION_SCHEMA.SCHEMATA
        WHERE 
            1=1
            AND LOWER(SCHEMA_NAME) NOT IN ('information_schema','pg_catalog','pg_toast','pg_temp_1','pg_toast_temp_1')
            AND LOWER(SCHEMA_NAME) NOT IN ('sys')
            AND SCHEMA_NAME LIKE '%#url.dsn#%'
        ORDER BY 
            SCHEMA_NAME
        OFFSET 0 ROWS
    </cfquery>
    <cfset items = []>
    <cfloop query="qSchemas">
        <cfset arrayAppend(items, qSchemas.SCHEMA_NAME)>
    </cfloop>
    <cfoutput>#serializeJSON({items=items})#</cfoutput>
<cfcatch>
    <cfheader statuscode="500" statustext="Server Error">
    <cfoutput>#serializeJSON({error=cfcatch.message, detail=cfcatch.detail})#</cfoutput>
</cfcatch>
</cftry>
