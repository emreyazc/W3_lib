<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <cfset resp = { "success": false }>

  <cfset httpData = getHttpRequestData()>
  <cfset rawBody  = ( structKeyExists(httpData,"content") AND isSimpleValue(httpData.content) ? httpData.content : "" )>

  <cfset p = structNew()>
  <cfif len(trim(rawBody)) GT 0 AND isJSON(rawBody)>
    <cfset p = deserializeJSON(rawBody)>
  <cfelse>
    <cfset p.meta    = structKeyExists(form,"meta")    ? deserializeJSON(form.meta)    : {} >
    <cfset p.cfg     = structKeyExists(form,"cfg")     ? deserializeJSON(form.cfg)     : {} >
    <cfset p.viz     = structKeyExists(form,"viz")     ? deserializeJSON(form.viz)     : {} >
    <cfset p.widgetId= structKeyExists(form,"widgetId")? val(form.widgetId)            : 0  >
    <cfparam name="p.vizOptions" default=''>
    <cfparam name="p.format"     default=''>
    <cfparam name="p.live"       default=''>
    <cfset opFuseactions = []>
    <cfif isStruct(p.live)>
        <cfif structKeyExists(p.live, "ops") AND isArray(p.live.ops)>
            <cfset opFuseactions = p.live.ops>
        <cfelseif structKeyExists(p.live, "opCode") AND len(trim(p.live.opCode))>
            <cfset opFuseactions = [ trim(p.live.opCode) ]>
        </cfif>
    </cfif>
    <cfset cfgJson = serializeJSON( {
      "kind":"semantic",
      "cfg": (p.cfg ?: {}),
      "viz": (p.viz ?: {}),
      "vizOptions": (p.vizOptions ?: {}),  
      "format": (p.format ?: {}),
      "live": (p.live ?: {})
    } )>
  </cfif>

  <cfparam name="p.widgetId" default="0">
  <cfparam name="p.meta.name" default="">
  <cfparam name="p.meta.desc" default="">
  <cfparam name="p.meta.icon" default="bar-chart">
  <cfparam name="p.meta.isActive" default="1">

  <cfset cfgJson = serializeJSON( { "kind":"semantic", "cfg": (p.cfg ?: {}), "viz": (p.viz ?: {}) } )>

  <cfif val(p.widgetId) EQ 0>
    <cftransaction>
      <cfquery name="qIns" datasource="#DSN#">
        INSERT INTO DASHBOARD_WIDGET_DEFS
          (
            WIDGET_NAME, 
            DESCRIPTION, 
            FILE_PATH, 
            ICON, 
            IS_ACTIVE,
            RECORD_DATE, 
            RECORD_EMP, 
            WIDGET_TYPE, 
            WIDGET_CONFIG
          )
        VALUES
          (
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.name#">,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.desc#">,
            NULL,
            <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.icon#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#val(p.meta.isActive)#">,
            <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
            <cfqueryparam cfsqltype="cf_sql_integer" value="#val(session.ep.userid)#">,
            4,
            <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cfgJson#">
          );

        SELECT CAST(SCOPE_IDENTITY() AS INT) AS NEW_ID;
      </cfquery>

      <cfset newId = qIns.NEW_ID>
      <cfset newPath = "V16/add_options/report/display/dynamic_semantic_widget.cfm?widgetid=" & newId>

      <cfquery name="qUpdPath" datasource="#DSN#">
        UPDATE 
          DASHBOARD_WIDGET_DEFS
        SET 
          FILE_PATH = <cfqueryparam cfsqltype="cf_sql_varchar" value="#newPath#">
        WHERE 
          WIDGET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#newId#">
      </cfquery>

      <!--- EŞLEME: sade (WIDGET_ID, FUSEACTION)  | INSERT sonrası --->
      <cfif arrayLen(opFuseactions)>
        <!-- güvenlik: önce varsa sil, sonra ekle -->
        <cfquery datasource="#DSN#">
          DELETE FROM DASHBOARD_WIDGET_OPERATION_MAP
          WHERE WIDGET_ID = <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfloop array="#opFuseactions#" index="fa">
          <cfif len(trim(fa))>
            <cfquery datasource="#DSN#">
              INSERT INTO DASHBOARD_WIDGET_OPERATION_MAP (WIDGET_ID, FUSEACTION)
              VALUES (
                <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(fa)#" cfsqltype="cf_sql_nvarchar">
              )
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>

    </cftransaction>

    <cfset resp.success  = true>
    <cfset resp.widgetId = newId>
    <cfset resp.filePath = newPath>
    <cfset resp.message  = "Widget eklendi.">

  <cfelse>
    <cftransaction>
      <cfquery name="qUpd" datasource="#DSN#">
        UPDATE 
          DASHBOARD_WIDGET_DEFS
        SET
          WIDGET_NAME   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.name#">,
          DESCRIPTION   = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.desc#">,
          ICON          = <cfqueryparam cfsqltype="cf_sql_varchar" value="#p.meta.icon#">,
          IS_ACTIVE     = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(p.meta.isActive)#">,
          UPDATE_DATE   = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
          UPDATE_EMP    = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(session.ep.userid)#">,
          WIDGET_TYPE   = 4,
          WIDGET_CONFIG = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#cfgJson#">
        WHERE 
          WIDGET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(p.widgetId)#">
      </cfquery>
      <!--- EŞLEME: UPDATE sonrası --->
      <!--- Seçenek boşsa eşlemeyi temizleyelim; seçiliyse tekrar yazalım --->
      <cfset opFuseactions = []>
      <cfif isStruct(p.live)>
          <cfif structKeyExists(p.live, "ops") AND isArray(p.live.ops)>
              <cfset opFuseactions = p.live.ops>
          <cfelseif structKeyExists(p.live, "opCode") AND len(trim(p.live.opCode))>
              <cfset opFuseactions = [ trim(p.live.opCode) ]>
          </cfif>
      </cfif>
      <cfquery datasource="#DSN#">
        DELETE FROM DASHBOARD_WIDGET_OPERATION_MAP
        WHERE WIDGET_ID = <cfqueryparam value="#val(p.widgetId)#" cfsqltype="cf_sql_integer">
      </cfquery>

      <cfif arrayLen(opFuseactions)>
        <cfloop array="#opFuseactions#" index="fa">
          <cfif len(trim(fa))>
            <cfquery datasource="#DSN#">
              INSERT INTO DASHBOARD_WIDGET_OPERATION_MAP (WIDGET_ID, FUSEACTION)
              VALUES (
                <cfqueryparam value="#val(p.widgetId)#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(fa)#" cfsqltype="cf_sql_nvarchar">
              )
            </cfquery>
          </cfif>
        </cfloop>
      </cfif>
    </cftransaction>

    <cfset resp.success  = true>
    <cfset resp.widgetId = val(p.widgetId)>
    <cfset resp.message  = "Widget güncellendi.">
  </cfif>

  <cfoutput>#serializeJSON(resp)#</cfoutput>

  <cfcatch type="any">
    <cfset err = { "success": false, "message": cfcatch.message }>
    <cfif structKeyExists(cfcatch,"detail") AND len(cfcatch.detail)><cfset err.detail = cfcatch.detail></cfif>
    <cfoutput>#serializeJSON(err)#</cfoutput>
  </cfcatch>
</cftry>