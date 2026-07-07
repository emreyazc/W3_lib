<!--- /v16/add_options/report/api/widgets/get_semantic_widget.cfm --->
<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <!--- CONFIG --->
  <cfset ADMIN_DSN = "workcube_test">

  <!--- Varsayılan response --->
  <cfset resp = { "success": false }>

  <!--- 1) Girdi okuma: JSON body > form/url --->
  <cfset httpData = getHttpRequestData()>
  <cfset rawBody  = ( structKeyExists(httpData,"content") AND isSimpleValue(httpData.content) ? httpData.content : "" )>

  <cfset p = structNew()>
  <cfif len(trim(rawBody)) GT 0 AND isJSON(rawBody)>
    <cfset p = deserializeJSON(rawBody)>
  </cfif>

  <!--- URL/FORM fallback --->
  <cfparam name="p.widgetId" default="#( structKeyExists(url,'widgetId') ? val(url.widgetId) : ( structKeyExists(form,'widgetId') ? val(form.widgetId) : 0 ) )#">

  <cfif NOT val(p.widgetId)>
    <cfset resp = { "success": false, "message": "widgetId eksik veya geçersiz." }>
    <cfoutput>#serializeJSON(resp)#</cfoutput>
    <cfabort>
  </cfif>

  <!--- 2) Widget'ı çek --->
  <cfquery name="q" datasource="#ADMIN_DSN#">
    SELECT 
      WIDGET_ID,
      WIDGET_NAME,
      DESCRIPTION,
      FILE_PATH,
      ICON,
      IS_ACTIVE,
      WIDGET_TYPE,
      WIDGET_CONFIG,
      RECORD_DATE,
      UPDATE_DATE,
      RECORD_EMP,
      UPDATE_EMP
    FROM DASHBOARD_WIDGET_DEFS
    WHERE WIDGET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(p.widgetId)#">
  </cfquery>

  <cfif q.recordCount EQ 0>
    <cfset resp = { "success": false, "message": "Widget bulunamadı." }>
    <cfoutput>#serializeJSON(resp)#</cfoutput>
    <cfabort>
  </cfif>

  <!--- 3) Config'i ayrıştır --->
  <cfset configRaw = trim(q.WIDGET_CONFIG)>
  <cfset cfg = {}>

  <cfif len(configRaw) AND isJSON(configRaw)>
    <cfset cfg = deserializeJSON(configRaw)>
  </cfif>

  <!--- 4) Beklenen şemayı güvene al (kind/cfg/viz/vizOptions/format) --->
  <cfset kind = ( structKeyExists(cfg, "kind") ? lcase(toString(cfg.kind)) : "" )>
  <!--- Semantic dışı ise yine de döndürürüz ama uyarı koyarız --->
  <cfset isSemantic = ( kind EQ "semantic" )>

  <cfset cfgStruct = ( structKeyExists(cfg,"cfg") AND isStruct(cfg.cfg) ? cfg.cfg : {} )>
  <cfset vizStruct = ( structKeyExists(cfg,"viz") AND isStruct(cfg.viz) ? cfg.viz : {} )>
  <cfset vizOpts   = ( structKeyExists(cfg,"vizOptions") AND isStruct(cfg.vizOptions) ? cfg.vizOptions : {} )>
  <cfset fmtStruct = ( structKeyExists(cfg,"format") AND isStruct(cfg.format) ? cfg.format : {} )>

  <!--- Backward-compat: bazı eski kayıtlarda vizOptions/format cfg içine gömülü olabilir --->
  <cfif NOT structCount(vizOpts) AND structKeyExists(cfgStruct, "_vizOptions") AND isStruct(cfgStruct._vizOptions)>
    <cfset vizOpts = cfgStruct._vizOptions>
  </cfif>
  <cfif NOT structCount(fmtStruct) AND structKeyExists(cfgStruct, "_format") AND isStruct(cfgStruct._format)>
    <cfset fmtStruct = cfgStruct._format>
  </cfif>

  <!--- 5) Model referansı var mı? (edit yüklemede lazım) --->
  <cfset modelRef = {} >
  <cfif structKeyExists(cfgStruct,"modelRef") AND isStruct(cfgStruct.modelRef)>
    <cfset modelRef = cfgStruct.modelRef>
  </cfif>

  <!--- 6) Response objesini hazırla --->
  <cfset meta = {
      "name"     : toString(q.WIDGET_NAME),
      "desc"     : toString(q.DESCRIPTION),
      "icon"     : toString(q.ICON),
      "isActive" : val(q.IS_ACTIVE),
      "filePath" : toString(q.FILE_PATH),
      "widgetType": val(q.WIDGET_TYPE),
      "recordDate": q.RECORD_DATE,
      "updateDate": q.UPDATE_DATE
  }>

  <cfset resp = {
    "success": true,
    "widgetId": val(q.WIDGET_ID),
    "meta": meta,
    "config": {
      "kind"      : ( isSemantic ? "semantic" : ( len(kind) ? kind : "unknown" ) ),
      "cfg"       : cfgStruct,
      "viz"       : vizStruct,
      "vizOptions": vizOpts,
      "format"    : fmtStruct
    }
  }>

  <!--- Semantic değilse küçük bir uyarı ekle (edit akışında önlem) --->
  <cfif NOT isSemantic>
    <cfset resp.warning = "Bu widget 'semantic' türünde görünmüyor. Yine de mevcut WIDGET_CONFIG döndürüldü.">
  </cfif>

  <!--- 7) Çıkış --->
  <cfoutput>#serializeJSON(resp)#</cfoutput>

  <cfcatch type="any">
    <cfset err = { "success": false, "message": cfcatch.message }>
    <cfif structKeyExists(cfcatch,"detail") AND len(cfcatch.detail)>
      <cfset err.detail = cfcatch.detail>
    </cfif>
    <cfoutput>#serializeJSON(err)#</cfoutput>
  </cfcatch>
</cftry>
