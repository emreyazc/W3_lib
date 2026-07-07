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
<cfset hasModel = isStruct(payload) AND structKeyExists(payload, "model")>
<cfset hasUid   = isStruct(payload) AND structKeyExists(payload, "modelUid")>
<cfif NOT hasModel AND NOT hasUid>
  <cfset resp = { "success": false, "code": "VALIDATION", "message": "model veya modelUid gönderilmelidir." }>
  <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
</cfif>
<cfset nowTs = createODBCDateTime( now() )>
<cfif hasModel>
  <cfset model = payload.model>
  <cfif NOT structKeyExists(model, "modelUid")>
    <cfset resp = { "success": false, "code": "VALIDATION", "message": "Model JSON içinde modelUid yok." }>
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>
  <cfset checksum = hash( serializeJSON(model), "SHA-256" )>
<cfelse>
  <cfset modelUid = payload.modelUid>
</cfif>
<cftransaction>
  <cftry>
    <cfquery name="qM" datasource="#DSN#">
      SELECT MODEL_UID, CURRENT_VERSION
      FROM workcube_test.DASHBOARD_SEMANTIC_MODEL
      WHERE MODEL_UID = <cfqueryparam value="#(hasModel ? model.modelUid : modelUid)#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfif qM.recordCount EQ 0>
      <cfset resp = { "success": false, "code": "NOT_FOUND", "message": "Model bulunamadı." }>
      <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
    </cfif>
    <cfif NOT hasModel>
      <cfif structKeyExists(payload, "fromVersion")>
        <cfquery name="qDraft" datasource="#DSN#">
          SELECT TOP 1 JSON_BLOB
          FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
          WHERE MODEL_UID = <cfqueryparam value="#modelUid#" cfsqltype="cf_sql_varchar">
            AND VERSION_NO = <cfqueryparam value="#payload.fromVersion#" cfsqltype="cf_sql_integer">
            AND STATE IN ('draft','published')
          ORDER BY VERSION_NO DESC
        </cfquery>
      <cfelse>
        <cfquery name="qDraft" datasource="#DSN#">
          SELECT TOP 1 JSON_BLOB
          FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
          WHERE MODEL_UID = <cfqueryparam value="#modelUid#" cfsqltype="cf_sql_varchar">
            AND STATE = 'draft'
          ORDER BY VERSION_NO DESC
        </cfquery>
      </cfif>
      <cfif qDraft.recordCount EQ 0>
        <cfset resp = { "success": false, "code": "NO_DRAFT", "message": "Yayınlanacak taslak versiyon bulunamadı." }>
        <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
      </cfif>
      <cfset model    = deserializeJSON( qDraft.JSON_BLOB[1], true )>
      <cfset checksum = hash( serializeJSON(model), "SHA-256" )>
    </cfif>
    <cfquery name="qMax" datasource="#DSN#">
      SELECT ISNULL(MAX(VERSION_NO),0) AS MAXV
      FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
      WHERE MODEL_UID = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfset nextVersion = (qMax.MAXV[1] ?: 0) + 1>
    <cfquery datasource="#DSN#">
      INSERT INTO workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
        (VERSION_UID, MODEL_UID, VERSION_NO, STATE, JSON_BLOB, CHECKSUM,
         RECORD_EMP, RECORD_DATE, PUBLISHED_DATE)
      VALUES
        (
          <cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#nextVersion#" cfsqltype="cf_sql_integer">,
          'published',
          <cfqueryparam value="#serializeJSON(model)#" cfsqltype="cf_sql_nvarchar" maxlength="4000000">,
          <cfqueryparam value="#checksum#" cfsqltype="cf_sql_varchar">,
          <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
          <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">,
          <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">
        )
    </cfquery>
    <cfquery datasource="#DSN#">
      UPDATE workcube_test.DASHBOARD_SEMANTIC_MODEL
         SET STATUS       = 'published',
             CURRENT_VERSION = <cfqueryparam value="#nextVersion#" cfsqltype="cf_sql_integer">,
             UPDATE_EMP   = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
             UPDATE_DATE  = <cfqueryparam value="#nowTs#" cfsqltype="cf_sql_timestamp">
       WHERE MODEL_UID    = <cfqueryparam value="#model.modelUid#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfset resp = { "success": true, "modelUid": model.modelUid, "version": nextVersion, "status": "published" }>
    <cfoutput>#serializeJSON(resp)#</cfoutput>
    <cfcatch type="any">
      <cftransaction action="rollback">
        <cfsavecontent variable="ssss">
            <cfdump var="#cfcatch#">
        </cfsavecontent>
        <cffile action="write" output="#ssss#" file="c:\\publish_semantic.html">
        <cfset resp = { "success": false, "code": "SAVE_FAILED", "message": "Yayınlama hatası: " & cfcatch.message }>
      <cfoutput>#serializeJSON(resp)#</cfoutput>
    </cfcatch>
</cftry>
</cftransaction>