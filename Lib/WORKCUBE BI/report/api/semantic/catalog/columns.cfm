<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="url.dsn"    default="DSN">
<cfparam name="url.schema" default="">
<cfparam name="url.table"  default="">

<cfif !len(trim(url.schema)) OR !len(trim(url.table))>
  <cfheader statuscode="400" statustext="Bad Request">
  <cfoutput>#serializeJSON({error="Missing schema or table"})#</cfoutput><cfabort>
</cfif>

<cftry>
  <cfquery name="qCols" datasource="#url.dsn#" cachedWithin="#CreateTimeSpan(0,0,0,30)#">
    SELECT
      c.table_schema,
      c.table_name,
      c.column_name,
      c.data_type,
      c.is_nullable
    FROM information_schema.columns c
    WHERE c.table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.schema#">
      AND c.table_name   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.table#">
    ORDER BY c.ordinal_position
  </cfquery>

  <cfquery name="qPK" datasource="#url.dsn#" cachedWithin="#CreateTimeSpan(0,0,0,30)#">
    SELECT kcu.column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
      ON tc.constraint_name = kcu.constraint_name
     AND tc.table_schema    = kcu.table_schema
     AND tc.table_name      = kcu.table_name
    WHERE tc.table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.schema#">
      AND tc.table_name   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.table#">
      AND tc.constraint_type = 'PRIMARY KEY'
  </cfquery>

  <cfquery name="qFK" datasource="#url.dsn#" cachedWithin="#CreateTimeSpan(0,0,0,30)#">
    SELECT kcu.column_name
    FROM information_schema.table_constraints tc
    JOIN information_schema.key_column_usage kcu
      ON tc.constraint_name = kcu.constraint_name
     AND tc.table_schema    = kcu.table_schema
     AND tc.table_name      = kcu.table_name
    WHERE tc.table_schema = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.schema#">
      AND tc.table_name   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.table#">
      AND tc.constraint_type = 'FOREIGN KEY'
  </cfquery>

  <cfset pkSet = structNew()>
  <cfloop query="qPK"><cfset pkSet[ lcase(qPK.column_name) ] = true></cfloop>

  <cfset fkSet = structNew()>
  <cfloop query="qFK"><cfset fkSet[ lcase(qFK.column_name) ] = true></cfloop>

  <cfset cols = []>
  <cfloop query="qCols">
    <cfset row = structNew()>
    <cfset row.name      = qCols.column_name>
    <cfset row.dataType  = lcase(qCols.data_type)>
    <cfset row.nullable  = (lcase(qCols.is_nullable) EQ "yes")>
    <cfset row.isPk      = structKeyExists(pkSet, lcase(qCols.column_name))>
    <cfset row.isFk      = structKeyExists(fkSet, lcase(qCols.column_name))>
    <!--- referans tablo/kolon bilgisi istersen burada ekstra joinlerle eklenebilir --->
    <cfset arrayAppend(cols, row)>
  </cfloop>

  <cfoutput>#serializeJSON({schema=url.schema, table=url.table, columns=cols})#</cfoutput>

<cfcatch>
  <cfheader statuscode="500" statustext="Server Error">
  <cfoutput>#serializeJSON({error=cfcatch.message, detail=cfcatch.detail})#</cfoutput>
</cfcatch>
</cftry>
