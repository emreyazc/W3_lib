<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="url.dsn"    default="DSN">
<cfparam name="url.schema" default="">
<cfparam name="url.q"      default="">
<cfparam name="url.limit"  default="200">

<cfif !len(trim(url.schema))>
  <cfheader statuscode="400" statustext="Bad Request">
  <cfoutput>#serializeJSON({error="Missing schema"})#</cfoutput><cfabort>
</cfif>

<cftry>
  <cfquery name="q" datasource="#url.dsn#" cachedWithin="#CreateTimeSpan(0,0,1,0)#">
    SELECT table_schema, table_name, table_type
    FROM information_schema.tables
    WHERE table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.schema#">
      AND LOWER(table_type) IN ('base table','view')
      <cfif len(trim(url.q))>
        AND table_name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#url.q#%">
      </cfif>
    ORDER BY table_name
  </cfquery>

  <cfset items = []>
  <cfloop query="q">
    <cfset row = structNew()>
    <cfset row.name   = q.table_name>
    <cfset row.schema = q.table_schema>
    <cfset row.type   = lcase(q.table_type)>
    <cfset arrayAppend(items, row)>
  </cfloop>

  <cfif arrayLen(items) GT val(url.limit)>
    <cfset items = items[1 : val(url.limit)]>
  </cfif>

  <cfoutput>#serializeJSON({items=items})#</cfoutput>

<cfcatch>
  <cfheader statuscode="500" statustext="Server Error">
  <cfoutput>#serializeJSON({error=cfcatch.message, detail=cfcatch.detail})#</cfoutput>
</cfcatch>
</cftry>
