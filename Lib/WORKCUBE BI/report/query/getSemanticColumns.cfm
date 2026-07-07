<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cfparam name="url.table_ids" default="">
<cfset idList = ListQualify(trim(url.table_ids), "'")>

<cfquery name="getSemanticColumns" datasource="#dsn#">
  SELECT 
    SEMANTIC_COLUMN_ID,
    SEMANTIC_TABLE_ID,
    COLUMN_NAME,
    DATA_TYPE,
    IS_VISIBLE,
    ROLE_HINT,
    LABEL
  FROM 
    DASHBOARD_SEMANTIC_COLUMNS
  WHERE 
    IS_VISIBLE = 1
    <cfif len(idList)>
      AND SEMANTIC_TABLE_ID IN (#preserveSingleQuotes(idList)#)
    </cfif>
  ORDER BY 
    SEMANTIC_TABLE_ID, COLUMN_NAME
</cfquery>

<cfset resultArray = []>
<cfloop query="getSemanticColumns">
  <cfset arrayAppend(resultArray, [
    SEMANTIC_COLUMN_ID,
    SEMANTIC_TABLE_ID,
    COLUMN_NAME,
    DATA_TYPE,
    ROLE_HINT,
    LABEL
  ])>
</cfloop>

<cfoutput>#serializeJSON(resultArray)#</cfoutput>
