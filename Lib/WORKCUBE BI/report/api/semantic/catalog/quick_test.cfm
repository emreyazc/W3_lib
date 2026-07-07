<cfsetting enablecfoutputonly="true">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <!-- Body -->
  <cfset raw = ToString(getHttpRequestData().content)>
  <cfif NOT len(trim(raw))>
    <cfoutput>#serializeJSON({success:false, message:"Empty request body"})#</cfoutput><cfexit>
  </cfif>

  <cfset body      = deserializeJson(raw)>
  <cfset entities  = body.entities ?: []>
  <cfset relations = body.relations ?: []>
  <cfparam name="body.limit" default="10">

  <cfif NOT isArray(entities) OR arrayLen(entities) LT 1>
    <cfoutput>#serializeJSON({success:false, message:"At least one entity required"})#</cfoutput><cfexit>
  </cfif>

  <cfscript>
    // [schema].[table]
    function fq(schema, table){
      var s = trim(schema ?: "");
      var t = trim(table  ?: "");
      if (!len(t)) return "";
      return (len(s) ? "[" & s & "]." : "") & "[" & t & "]";
    }
    // [schema].[table].[col]
    function fqcol(schema, table, col){
      var c = trim(col ?: "");
      if (!len(c)) return "";
      return fq(schema, table) & ".[" & c & "]";
    }
    function upperOr(val, def){ return len(trim(val ?: "")) ? uCase(val) : def; }
    // Query -> array of structs
    function arrFromQuery(q){
        var a    = [];
        var cols = listToArray(q.columnList);
        var i    = 1;
        var c    = "";
        for (i=1; i<=q.recordCount; i++){
          var row = {};
          for (c in cols){
            row[c] = q[c][i];
          }
          arrayAppend(a, row);
        }
        return a;
      }
  </cfscript>

  <!-- Entity map -->
  <cfset entityMap = {} >
  <cfloop array="#entities#" index="e">
    <cfset entityMap[e.entityId] = { 
        schema = (e.schema ?: ""), 
        table = e.table,
        alias  = (len(trim(e.alias ?: "")) ? e.alias : e.table),
        fields = (isArray(e.fields) ? e.fields : [])
    }>
  </cfloop>

  <!-- ==== BASE ENTITY ==== -->
  <cfif arrayLen(relations)>
    <cfset baseId = relations[1].leftEntityId>
  <cfelse>
    <cfset baseId = entities[1].entityId>
  </cfif>
  <cfset baseEnt = entityMap[baseId]>
  <cfif NOT isStruct(baseEnt) OR NOT len(baseEnt.table)>
    <cfoutput>#serializeJSON({success:false, message:"Base entity/table not found"})#</cfoutput><cfexit>
  </cfif>

  <!-- ==== SELECT LİSTESİ: SADECE VISIBLE ==== -->
  <cfset selectCols = []>
  <cfset aliasList  = []>
  <cfloop array="#entities#" index="e">
    <cfset aliasPrefix = (len(trim(e.alias ?: "")) ? e.alias : e.table)>
    <cfset picked = []>
    <cfif isArray(e.fields)>
      <cfloop array="#e.fields#" index="f">
        <cfif NOT structKeyExists(f, "visible") OR f.visible>
          <cfset colAlias = aliasPrefix & "_" & f.name>
          <cfset arrayAppend(picked, fqcol(e.schema, e.table, f.name) & " AS [" & colAlias & "]")>
          <cfset arrayAppend(aliasList, colAlias)>
        </cfif>
      </cfloop>
    </cfif>
    <cfif arrayLen(picked)>
      <cfset arrayAppend(selectCols, picked, true)>
    </cfif>
  </cfloop>

    <cfset orderBy  = body.orderBy ?: {} >
    <cfset orderCol = trim(orderBy.column ?: "")>
    <cfset orderDir = uCase(trim(orderBy.dir ?: "ASC"))>
    <cfif len(orderCol) AND arrayFindNoCase(aliasList, orderCol)>
        <cfset orderSql = " ORDER BY [" & orderCol & "] " & (orderDir EQ "DESC" ? "DESC" : "ASC")>
    <cfelse>
        <cfset orderSql = "">
    </cfif>

    <!-- ==== LIMIT ==== -->
    <cfset topN = val(body.limit)>
    <cfif topN LTE 0><cfset topN = 10></cfif>

    <!-- ==== SQL BUILD ==== -->
    <cfif arrayLen(selectCols)>
        <cfset sql = "SELECT TOP " & topN & " " & arrayToList(selectCols, ", ") & " FROM " & fq(baseEnt.schema, baseEnt.table)>
    <cfelse>
        <!-- Hiç görünür kolon yoksa placeholder kolon dön -->
        <cfset sql = "SELECT TOP " & topN & " 1 AS [NO_VISIBLE_FIELDS] FROM " & fq(baseEnt.schema, baseEnt.table)>
    </cfif>

    <cfset sql &= orderSql>

  <!-- JOIN'ler -->
  <cfif arrayLen(relations)>
    <cfloop array="#relations#" index="rel">
      <cfset L = entityMap[ rel.leftEntityId ]>
      <cfset R = entityMap[ rel.rightEntityId ]>
      <cfif NOT isStruct(L) OR NOT isStruct(R)>
        <cfoutput>#serializeJSON({success:false, message:"Unknown entity id in relations"})#</cfoutput><cfexit>
      </cfif>

      <cfset joinType = upperOr(rel.joinType, "INNER")>
      <cfset onParts = []>

      <cfloop array="#(rel.joins ?: [])#" index="j">
        <cfset lc = ( structKeyExists(j,"left")       ? j.left
                    : structKeyExists(j,"leftField")  ? j.leftField
                    : structKeyExists(j,"leftColumn") ? j.leftColumn : "" )>
        <cfset rc = ( structKeyExists(j,"right")       ? j.right
                    : structKeyExists(j,"rightField")  ? j.rightField
                    : structKeyExists(j,"rightColumn") ? j.rightColumn : "" )>
        <cfif NOT len(trim(lc)) OR NOT len(trim(rc))>
          <cfoutput>#serializeJSON({success:false, message:"Join pair columns missing"})#</cfoutput><cfexit>
        </cfif>
        <cfset arrayAppend(onParts, fqcol(L.schema, L.table, lc) & " = " & fqcol(R.schema, R.table, rc))>
      </cfloop>

      <cfif arrayLen(onParts)>
        <cfset sql &= " " & joinType & " JOIN " & fq(R.schema, R.table) & " ON " & arrayToList(onParts, " AND ")>
      </cfif>
    </cfloop>
  </cfif>

    <cfset t0 = getTickCount()>

    <!-- ÇALIŞTIR -->
    <cfquery name="qTest" datasource="#dsn#">
        #preserveSingleQuotes(sql)#
    </cfquery>
    <cfset durationMs = getTickCount() - t0>
    <!-- result -->
    <cfscript>
        rows     = arrFromQuery(qTest);
        rowCount = qTest.recordCount;
        out      = { success:true, sql=sql, rowCount=rowCount, rows=rows, durationMs=durationMs };
    </cfscript>
    <cfoutput>#serializeJSON(out)#</cfoutput>
    <cfcatch>
        <cfheader statuscode="500" statustext="Server Error">
        <cfoutput>#serializeJSON({success:false,message=cfcatch.message,detail=cfcatch.detail})#</cfoutput>
    </cfcatch>
</cftry>
<cfsetting enablecfoutputonly="false">