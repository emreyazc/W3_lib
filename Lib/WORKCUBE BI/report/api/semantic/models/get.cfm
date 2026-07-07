<!--- /SEMANTIC/MODELS/GET.CFM --->
<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json; charset=utf-8">

<cfset modelUid = trim(url.modelUid ?: form.modelUid ?: "")>
<cfset version  = lcase(trim(url.version  ?: form.version  ?: "published"))>

<cfif NOT len(modelUid)>
  <cfoutput>#serializeJSON({success:false, code:"VALIDATION", message:"modelUid gerekli."})#</cfoutput><cfabort>
</cfif>

<cfif reFind("^[0-9]+$", version)>
  <cfset whereVer = "AND VERSION_NO = ?">
  <cfset verParam = {value: val(version), cfsqltype:"cf_sql_integer"}>
<cfelseif version EQ "latest">
  <cfset whereVer = "">
  <cfset verParam = "">
<cfelse>
  <cfset whereVer = "AND STATE='published'">
  <cfset verParam = "">
</cfif>

<!--- Güvenli defaults --->
<cfparam name="version"  default="latest">
<cfparam name="modelUid" default="">

<!--- Basit tip belirleme --->
<cfset versionArg = trim(version & "")>
<cfset isNumericVersion = REFind("^[0-9]+$", versionArg) GT 0>

<cfquery name="q" datasource="#DSN#">
  SELECT TOP 1
    JSON_BLOB,
    VERSION_NO,
    STATE
  FROM 
    DASHBOARD_SEMANTIC_MODEL_VERSION
  WHERE 
    MODEL_UID = <cfqueryparam value="#modelUid#" cfsqltype="cf_sql_varchar" maxlength="36">
  <!--- Version filtresi --->
  <cfif isNumericVersion>
    AND VERSION_NO = <cfqueryparam value="#val(versionArg)#" cfsqltype="cf_sql_integer">
  <cfelseif LCase(versionArg) EQ "published">
    AND STATE = <cfqueryparam value="published" cfsqltype="cf_sql_varchar">
  <cfelseif LCase(versionArg) EQ "draft">
    AND STATE = <cfqueryparam value="draft" cfsqltype="cf_sql_varchar">
  <cfelse>
    <!--- latest: ekstra filtre yok --->
  </cfif>
  ORDER BY VERSION_NO DESC
</cfquery>


<cfif q.recordCount EQ 0>
  <cfoutput>#serializeJSON({success:false, code:"NOT_FOUND", message:"Model/versiyon bulunamadı."})#</cfoutput><cfabort>
</cfif>

<cfset data = deserializeJSON(q.JSON_BLOB[1], true)>
<cfoutput>#serializeJSON({success:true, version:q.VERSION_NO[1], state:q.STATE[1], model:data})#</cfoutput>
