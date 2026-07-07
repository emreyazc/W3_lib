<cfsetting showdebugoutput="false">
<cfheader name="Content-Type" value="application/json; charset=utf-8">
<cfset userId = 0>
<cfif structKeyExists(session, "ep") AND structKeyExists(session.ep, "userid") AND len(session.ep.userid)>
  <cfset userId = val(session.ep.userid)>
</cfif>
<cfset rawBody = toString( getHttpRequestData().content )>
<cfif NOT len(trim(rawBody))>
  <cfset resp = { "success": false, "code": "EMPTY_BODY", "message": "Boş gövde." }>
  <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
</cfif>
<cftry>
  <cfset payload = deserializeJSON(rawBody, true)>
  <cfcatch type="any">
    <cfset resp = { "success": false, "code": "BAD_JSON", "message": "JSON parse edilemedi: " & cfcatch.message }>
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfcatch>
</cftry>
<cfif isStruct(payload) AND structKeyExists(payload, "model")>
  <cfset model = payload.model>
<cfelse>
  <cfset model = payload>
</cfif>
<cfset requiredKeys = ["schemaVersion","name","entities","relations"]>
<cfloop array="#requiredKeys#" index="k">
  <cfif NOT structKeyExists(model, k)>
    <cfset resp = { "success": false, "code": "VALIDATION", "message": "Eksik alan: " & k }>
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>
</cfloop>
<cfif NOT structKeyExists(model, "modelUid") OR NOT len(model.modelUid)>
  <cfset model.modelUid = createUUID()>
</cfif>
<cfset nowTs = createODBCDateTime( now() )>
<cfset snapshot = {
  "schemaVersion" = model.schemaVersion,
  "dsn"           = (model.dsn ?: ""),
  "entities"      = model.entities,
  "relations"     = model.relations
}>
<cfset checksum = hash( serializeJSON(snapshot), "SHA-256" )>

<cftransaction>
  <cftry>
    <cfquery name="qGet" datasource="#DSN#">
      SELECT MODEL_UID, CURRENT_VERSION
      FROM workcube_test.DASHBOARD_SEMANTIC_MODEL
      WHERE MODEL_UID = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qGet.recordCount EQ 0>
      <cfquery datasource="#DSN#">
        INSERT INTO workcube_test.DASHBOARD_SEMANTIC_MODEL
          (MODEL_UID, NAME, DSN, STATUS, CURRENT_VERSION, IS_ACTIVE,
           RECORD_EMP, RECORD_DATE, UPDATE_EMP, UPDATE_DATE)
        VALUES
          (
            <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#model.name#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#(model.dsn ?: '')#" cfsqltype="cf_sql_nvarchar">,
            'draft',
            0,
            <cfqueryparam value="#(model.active ? 1 : 0)#" cfsqltype="cf_sql_bit">,
            <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">
          )
      </cfquery>
    <cfelse>
      <cfquery datasource="#DSN#">
        UPDATE workcube_test.DASHBOARD_SEMANTIC_MODEL
           SET NAME        = <cfqueryparam value="#model.name#" cfsqltype="cf_sql_nvarchar">,
               DSN         = <cfqueryparam value="#(model.dsn ?: '')#" cfsqltype="cf_sql_nvarchar">,
               IS_ACTIVE   = <cfqueryparam value="#(model.active ? 1 : 0)#" cfsqltype="cf_sql_bit">,
               UPDATE_EMP  = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
               UPDATE_DATE = <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">,
               STATUS      = 'draft'
         WHERE MODEL_UID   = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
      </cfquery>
    </cfif>
    <cfquery name="qMax" datasource="#DSN#">
      SELECT ISNULL(MAX(VERSION_NO),0) AS MAXV
      FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
      WHERE MODEL_UID = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfset nextVersion = (qMax.MAXV[1] ?: 0) + 1>
    <cfquery name="qSame" datasource="#DSN#">
      SELECT TOP 1 VERSION_NO
      FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
      WHERE MODEL_UID = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
        AND STATE = 'draft'
        AND CHECKSUM = <cfqueryparam value="#checksum#" cfsqltype="cf_sql_varchar">
      ORDER BY VERSION_NO DESC
    </cfquery>
    <cfif qSame.recordCount EQ 0>
      <cfset jsonBlob = serializeJSON(model)>
      <cfquery datasource="#DSN#">
        INSERT INTO workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
          (VERSION_UID, MODEL_UID, VERSION_NO, STATE, JSON_BLOB, CHECKSUM,
           RECORD_EMP, RECORD_DATE, PUBLISHED_DATE)
        VALUES
          (
            <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#nextVersion#" cfsqltype="cf_sql_integer">,
            'draft',
            <cfqueryparam value="#jsonBlob#" cfsqltype="cf_sql_nvarchar" maxlength="4000000">,
            <cfqueryparam value="#checksum#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">,
            NULL
          )
      </cfquery>
      <cfquery datasource="#DSN#">
        UPDATE workcube_test.DASHBOARD_SEMANTIC_MODEL
           SET CURRENT_VERSION = <cfqueryparam value="#nextVersion#" cfsqltype="cf_sql_integer">,
               UPDATE_DATE     = <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">
         WHERE MODEL_UID       = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
      </cfquery>

      <cfset savedVersion = nextVersion>
    <cfelse>
      <cfset savedVersion = qSame.VERSION_NO[1]>
    </cfif>
    <cfset resp = { "success": true, "modelUid": model.modelUid, "version": savedVersion, "status": "draft" }>
    <cfoutput>#serializeJSON(resp)#</cfoutput>

    <cfcatch type="any">
      <cftransaction action="rollback">
        <cfsavecontent variable="ssss">
            <cfdump var="#cfcatch#">
        </cfsavecontent>
        <cffile action="write" output="#ssss#" file="c:\\save_semantic.html">
      <cfset resp = { "success": false, "code": "SAVE_FAILED", "message": "Kaydetme hatası: " & cfcatch.message }>
      <cfoutput>#serializeJSON(resp)#</cfoutput>
    </cfcatch>
  </cftry>
</cftransaction>
