<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cftry>
  <cfset DSN = request.DSN ?: DSN>
  <cfparam name="url.widgetid" type="numeric">

  <cfset wverKey = "wver:#url.widgetid#">
  <cfset wver = 0>
  <cftry>
    <cfset wver = cacheGet(wverKey)>
    <cfif isNull(wver)><cfset wver = 0></cfif>
    <cfcatch>
      <cfif structKeyExists(application,"hb_wver") AND structKeyExists(application.hb_wver,wverKey)>
        <cfset wver = val(application.hb_wver[wverKey])>
      </cfif>
    </cfcatch>
  </cftry>

  <cfquery name="cfg" datasource="#DSN#">
    SELECT C.SQL_QUERY
    FROM DASHBOARD_WIDGET_SQL_CONFIG C
    WHERE C.WIDGET_ID = <cfqueryparam value="#url.widgetid#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfif cfg.recordcount EQ 0>
    <cfset writeOutput( serializeJSON({success:false, message:"Widget SQL bulunamadı"}) )><cfabort>
  </cfif>
  <cfset sqlQuery = trim(cfg.SQL_QUERY)>

  <cfif NOT refindnocase("^\s*select\b", sqlQuery)>
    <cfset writeOutput( serializeJSON({success:false, message:"Yalnızca SELECT sorguları çalıştırılabilir"}) )><cfabort>
  </cfif>

  <cfset etag = hash( url.widgetid & ":" & wver & ":" & hash(sqlQuery) )>
  <cfheader name="ETag" value="#etag#">
  <cfset req = getHttpRequestData()>
  <cfset inm = (structKeyExists(req.headers,"If-None-Match") ? req.headers["If-None-Match"] : "")>
  <cfif len(inm) AND inm EQ etag>
    <cfheader statuscode="304" statustext="Not Modified"><cfabort>
  </cfif>

  <cfset t1 = getTickCount()>
  <cfquery name="q" datasource="#DSN#" timeout="30">
    #preserveSingleQuotes(sqlQuery)#
  </cfquery>
  <cfset elapsed = getTickCount() - t1>

  <cfset cols = []>
  <cfloop list="#q.columnList#" index="c">
    <cfset arrayAppend(cols, {name=c})>
  </cfloop>

  <cfset rows = []>
  <cfloop query="q">
    <cfset r = {} >
    <cfloop list="#q.columnList#" index="c">
      <cfset r[c] = q[c][currentRow]>
    </cfloop>
    <cfset arrayAppend(rows, r)>
  </cfloop>

  <cfset writeOutput( serializeJSON({
    success:true,
    widgetId:url.widgetid,
    wver:wver,
    etag:etag,
    elapsedMs:elapsed,
    columns:cols,
    rows:rows
  }))>

  <cfcatch type="any">
    <cfset writeOutput( serializeJSON({success:false, message:cfcatch.message}) )>
  </cfcatch>
</cftry>