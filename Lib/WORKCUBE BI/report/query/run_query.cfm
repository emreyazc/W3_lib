<cfsetting showdebugoutput="false">
<cfcontent reset="true" type="application/json; charset=utf-8">

<cfscript>
function getSqlFromInput(inp){
  var keys = ["sqlQuery","sql","query","q","text","stmt","statement"];
  for (var k in keys){
    if (structKeyExists(inp, k) AND len(toString(inp[k]))){
      return toString(inp[k]);
    }
  }
  if (structKeyExists(url, "sql")) return toString(url.sql);
  if (structKeyExists(form, "sql")) return toString(form.sql);
  return "";
}

function stripInvisible(s){
  if (!isSimpleValue(s)) s = toString(s);
  s = replaceNoCase(s, chr(65279), "", "all");
  s = replaceNoCase(s, chr(8203),  "", "all");
  s = replaceNoCase(s, chr(8206),  "", "all");
  s = replaceNoCase(s, chr(8207),  "", "all");
  return s;
}
function stripSqlComments(s){
  s = reReplaceNoCase(s, "/\\*.*?\\*/", "", "all"); 
  s = reReplaceNoCase(s, "--[^\\r\\n]*", "", "all");
  return s;
}
function stripTrailingSemicolons(s){
  return reReplaceNoCase(s, ";+\\s*$", "", "all");
}
function ltrimUnicode(s){
  return reReplaceNoCase(s, "^[\\s\\u00A0\\u1680\\u2000-\\u200B\\u202F\\u205F\\u3000]+", "", "one");
}
function normalizeSql(s){
  s = stripInvisible(s);
  s = stripSqlComments(s);
  s = stripTrailingSemicolons(s);
  s = ltrimUnicode(s);
  return trim(s);
}
function firstWord(s){
  s = ltrimUnicode(s);
  var m = reFind("(?i)^([a-z]+)", s, 1, true);
  if (structKeyExists(m,"len") AND arrayLen(m.len)>=2 AND m.len[2]>0){
    return lCase( mid(s, m.pos[2], m.len[2]) );
  }
  return "";
}
function hasForbiddenTokens(s){
  if (reFind(";", s)) return true;
  var forbidden = "drop|update|delete|insert|merge|truncate|alter|create|exec|execute|declare|backup|restore|grant|revoke|shutdown|kill|attach|detach|use\\s+|dbcc|openrowset|openquery|bulk\\s+insert|bcp|xp_[a-z0-9_]+|sp_[a-z0-9_]+";
  return reFindNoCase(forbidden, s) GT 0;
}
</cfscript>

<cftry>
  <cfset rawBody = toString(getHttpRequestData().content)>
  <cfset input   = structNew()>
  <cfif len(trim(rawBody))>
    <cftry><cfset input = deserializeJSON(rawBody)><cfcatch></cfcatch></cftry>
  </cfif>
  <cfset userSQL   = getSqlFromInput(input)>
  <cfset normalized = normalizeSql(userSQL)>
  <cfif NOT len(normalized)>
    <cfoutput>#serializeJSON({"error":"SQL metni boş görünüyor. Lütfen gövdeye 'sqlQuery' (veya 'sql') alanında sorgu gönderin."})#</cfoutput>
    <cfabort>
  </cfif>
  <!---
  <cfset fw = firstWord(normalized)>
  <cfif NOT listFindNoCase("select,with", fw)>
    <cfoutput>#serializeJSON({"error":"Sadece SELECT (veya WITH ile başlayan) sorgulara izin verilir."})#</cfoutput>
    <cfabort>
  </cfif>
  --->
  <cfif hasForbiddenTokens(normalized)>
    <cfoutput>#serializeJSON({"error":"Sorgu tehlikeli komutlar içeriyor veya çoklu komut içeriyor (;) — izin verilmez."})#</cfoutput>
    <cfabort>
  </cfif>
  <cfset reqLimit     = (structKeyExists(input,"limit") AND isNumeric(input.limit)) ? int(input.limit) : 200>
  <cfset resultLimit  = min( max(reqLimit, 1), 1000 )>
  <cfquery name="qSetLimit" datasource="#DSN#" timeout="5">SET ROWCOUNT #resultLimit#</cfquery>

  <cfquery name="qData" datasource="#DSN#" timeout="20">
    #preserveSingleQuotes(userSQL)#
  </cfquery>

  <cfquery name="qResetLimit" datasource="#DSN#" timeout="5">SET ROWCOUNT 0</cfquery>


  <cfset columnInfo = []>
  <cfset theCols = qData.columnList>
  <cfif qData.recordCount EQ 0>
    <cfloop list="#theCols#" index="col">
      <cfset arrayAppend(columnInfo, {"name": col, "type": "unknown"})>
    </cfloop>
  <cfelse>
    <cfloop list="#theCols#" index="col">
      <cfset sampleVal = qData[col][1]>
      <cfset colType = "string">
      <cfif isNumeric(sampleVal)><cfset colType = "numeric">
      <cfelseif isDate(sampleVal)><cfset colType = "date"></cfif>
      <cfset arrayAppend(columnInfo, {"name": col, "type": colType})>
    </cfloop>
  </cfif>

  <cfset rowData = []>
  <cfloop query="qData">
    <cfset row = structNew()>
    <cfloop list="#theCols#" index="col">
      <cfset row[col] = qData[col][currentRow]>
    </cfloop>
    <cfset arrayAppend(rowData, row)>
  </cfloop>

  <cfoutput>#serializeJSON({
    "limitApplied": resultLimit,
    "rowCount": qData.recordCount,
    "columns": columnInfo,
    "data": rowData
  })#</cfoutput>

  <cfcatch>
    <cftry><cfquery name="qResetOnError" datasource="#DSN#" timeout="5">SET ROWCOUNT 0</cfquery><cfcatch></cfcatch></cftry>

    <cfset err = {
      "error"  = replace(cfcatch.message, '"', "'", "all"),
      "detail" = (structKeyExists(cfcatch,"detail") ? left(replace(cfcatch.detail, '"', "'", "all"), 500) : ""),
      "type"   = (structKeyExists(cfcatch,"type") ? cfcatch.type : "")
    }>
    <cfoutput>#serializeJSON(err)#</cfoutput>
  </cfcatch>
</cftry>