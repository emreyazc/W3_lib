<!--- /SEMANTIC/MODELS/LIST.CFM --->
<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json; charset=utf-8">

<cfset q = trim(url.q ?: "")>
<cfset limit = val(url.limit ?: 50)>
<cfif limit LTE 0 OR limit GT 200><cfset limit = 50></cfif>

<cfquery name="qList" datasource="#DSN#">
  SELECT TOP (#limit#)
         M.MODEL_UID, M.NAME, M.DSN, M.STATUS, M.CURRENT_VERSION,
         M.RECORD_EMP, M.RECORD_DATE, M.UPDATE_EMP, M.UPDATE_DATE
  FROM DASHBOARD_SEMANTIC_MODEL M
  WHERE 1=1
    AND M.STATUS='published'
    <cfif len(q)>
      AND (M.NAME LIKE <cfqueryparam value="%#q#%" cfsqltype="cf_sql_nvarchar">
        OR  M.DSN  LIKE <cfqueryparam value="%#q#%" cfsqltype="cf_sql_nvarchar"> )
    </cfif>
  ORDER BY M.UPDATE_DATE DESC
</cfquery>

<cfset items = []>
<cfloop query="qList">
  <cfset arrayAppend(items, {
    modelUid = qList.MODEL_UID,
    name     = qList.NAME,
    dsn      = qList.DSN,
    status   = qList.STATUS,
    currentVersion = qList.CURRENT_VERSION,
    recordEmp = qList.RECORD_EMP,
    recordDate= dateTimeFormat(qList.RECORD_DATE, "yyyy-mm-dd HH:nn:ss"),
    updateEmp = qList.UPDATE_EMP,
    updateDate= dateTimeFormat(qList.UPDATE_DATE, "yyyy-mm-dd HH:nn:ss")
  })>
</cfloop>

<cfoutput>#serializeJSON({success:true, items:items})#</cfoutput>
