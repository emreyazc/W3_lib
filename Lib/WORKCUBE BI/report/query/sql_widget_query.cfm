<!--- sql_widget_wizard.cfm  — Tek dosya: UI + AJAX (preview/load/save) --->
<cfsetting showdebugoutput="false">

<!--- ====== SERVER TARAFI: AJAX UÇLARI ====== --->
<cfif structKeyExists(url, "api")>
  <cfcontent type="application/json; charset=utf-8">

  <cftry>
    <cfset DSN = request.DSN ?: DSN>
    <cfset api = lcase(url.api)>

    <!--- LOAD: var olan widget'ı oku --->
    <cfif api EQ "load">
      <cfparam name="url.widgetid" type="numeric">
      <cfquery name="q" datasource="#DSN#">
        SELECT 
          W.WIDGET_ID, W.WIDGET_NAME, W.DESCRIPTION,
          C.SQL_QUERY, C.CHART_TYPE, C.COLUMN_ROLES_JSON
        FROM DASHBOARD_WIDGET_DEFS W
        INNER JOIN DASHBOARD_WIDGET_SQL_CONFIG C ON C.WIDGET_ID = W.WIDGET_ID
        WHERE W.WIDGET_ID = <cfqueryparam value="#url.widgetid#" cfsqltype="cf_sql_integer">
      </cfquery>
      <cfif q.recordcount EQ 0>
        <cfset writeOutput(serializeJSON({success:false, message:"Widget bulunamadı."}))>
        <cfabort>
      </cfif>

      <!--- Seçili fuseaction'lar --->
      <cfquery name="qOps" datasource="#DSN#">
        SELECT 
          FUSEACTION
        FROM 
          DASHBOARD_WIDGET_OPERATION_MAP
        WHERE 
          WIDGET_ID = <cfqueryparam value="#url.widgetid#" cfsqltype="cf_sql_integer">
        ORDER BY 
          FUSEACTION
      </cfquery>
      <cfset ops = []>
      <cfloop query="qOps">
        <cfset arrayAppend(ops, qOps.FUSEACTION)>
      </cfloop>

      <cfset resp = {
        success: true,
        data: {
          widgetId: q.WIDGET_ID,
          widgetName: q.WIDGET_NAME,
          description: q.DESCRIPTION,
          sqlQuery: q.SQL_QUERY,
          chartType: q.CHART_TYPE,
          columns: (isJSON(q.COLUMN_ROLES_JSON) ? deserializeJSON(q.COLUMN_ROLES_JSON) : {}),
          opFuseactions: ops
        }
      }>
      <cfset writeOutput(serializeJSON(resp))>
      <cfabort>
    </cfif>

    <!--- PREVIEW: SQL'i TOP 100 ile çalıştır, kolon/örnek veri döndür --->
    <cfif api EQ "preview">
      <cfparam name="form.sqlQuery" default="">
      <cfparam name="form.topN" default="100">
      <cfset clean = rereplace(form.sqlQuery, ";\s*$", "", "all")>
      <cfif NOT refindnocase("^\s*select\b", clean)>
        <cfset writeOutput(serializeJSON({success:false, message:"Sadece SELECT sorguları önizlenebilir."}))>
        <cfabort>
      </cfif>
      <cfset previewSQL = clean>
      <cfif NOT refindnocase("\btop\s+\d+\b", previewSQL)>
        <cfset previewSQL = rereplace(previewSQL, "^\s*select\s+", "SELECT TOP " & val(form.topN) & " ", "one")>
      </cfif>

      <cfset ts1 = getTickCount()>
      <cfquery name="p" datasource="#DSN#" timeout="15">
        #preserveSingleQuotes(previewSQL)#
      </cfquery>
      <cfset elapsed = getTickCount()-ts1>

      <cfset cols = []>
      <cfloop list="#p.columnList#" index="c">
        <cfset arrayAppend(cols, {name=c})>
      </cfloop>

      <cfset rows = []>
      <cfloop query="p">
        <cfset row = {} >
        <cfloop list="#p.columnList#" index="c">
          <cfset row[c] = p[c][currentRow]>
        </cfloop>
        <cfset arrayAppend(rows, row)>
      </cfloop>

      <cfset writeOutput(serializeJSON({
        success: true,
        columns: cols,
        rows: rows,
        elapsedMs: elapsed,
        rowCount: arrayLen(rows)
      }))>
      <cfabort>
    </cfif>

    <!--- SAVE: yeni ya da update --->
    <cfif api EQ "save">
      <!--- Beklenen body: widgetId?, widgetName, description, sqlQuery, chartType, columns, opFuseactions[] --->
      <cfset raw = toString(getHttpRequestData().content)>
      <cfset data = deserializeJSON(raw)>

      <cfset widgetId   = (structKeyExists(data,"widgetId") AND len(data.widgetId)) ? val(data.widgetId) : 0>
      <cfset widgetName = trim(data.widgetName)>
      <cfset description = trim(data.description ?: "")>
      <cfset sqlQuery    = trim(data.sqlQuery)>
      <cfset chartType   = trim(data.chartType ?: "table")>
      <cfset columnRolesJSON = serializeJSON(data.columns ?: {})>

      <!--- Çoklu fuseaction listesi (sade) --->
      <cfset opFuseactions = (structKeyExists(data,"opFuseactions") AND isArray(data.opFuseactions)) ? data.opFuseactions : []>
      <!--- trim + boşları at + uniq --->
      <cfset _uniq = structNew()>
      <cfset _ops = []>
      <cfloop array="#opFuseactions#" index="__fa">
        <cfset __v = trim(__fa)>
        <cfif len(__v) AND NOT structKeyExists(_uniq, __v)>
          <cfset _uniq[__v] = 1>
          <cfset arrayAppend(_ops, __v)>
        </cfif>
      </cfloop>
      <cfset opFuseactions = _ops>

      <!--- Basit güvenlik: sadece SELECT --->
      <cfif NOT refindnocase("^\s*select\b", sqlQuery)>
        <cfset writeOutput(serializeJSON({success:false, message:"Sadece SELECT sorguları kaydedilebilir."}))>
        <cfabort>
      </cfif>

      <!--- INSERT / UPDATE --->
      <cfif widgetId EQ 0>
        <!--- INSERT --->
        <cfquery name="insertWidget" datasource="#DSN#">
          INSERT INTO DASHBOARD_WIDGET_DEFS (
            WIDGET_NAME, DESCRIPTION, GRAPH_FUSEACTION, FILE_PATH, ICON, 
            IS_ACTIVE, RECORD_DATE, RECORD_EMP, WIDGET_TYPE
          )
          VALUES (
            <cfqueryparam value="#widgetName#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">,
            NULL,
            <cfqueryparam value="V16/add_options/report/display/dynamic_sql_widget.cfm" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="bar-chart" cfsqltype="cf_sql_varchar">,
            1, GETDATE(),
            <cfqueryparam value="1" cfsqltype="cf_sql_integer">,
            3
          );
          SELECT SCOPE_IDENTITY() AS NEW_ID;
        </cfquery>
        <cfset newId = insertWidget.NEW_ID>

        <cfquery datasource="#DSN#">
          INSERT INTO DASHBOARD_WIDGET_SQL_CONFIG (
            WIDGET_ID, SQL_QUERY, CHART_TYPE, COLUMN_ROLES_JSON, RECORD_DATE, RECORD_EMP
          )
          VALUES (
            <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#sqlQuery#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#chartType#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#columnRolesJSON#" cfsqltype="cf_sql_longvarchar">,
            GETDATE(),
            <cfqueryparam value="1" cfsqltype="cf_sql_integer">
          )
        </cfquery>

        <cfset filePath = "V16/add_options/report/display/dynamic_sql_widget.cfm?widgetid=#newId#">
        <cfquery datasource="#DSN#">
          UPDATE DASHBOARD_WIDGET_DEFS
          SET FILE_PATH = <cfqueryparam value="#filePath#" cfsqltype="cf_sql_varchar">
          WHERE WIDGET_ID = <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <!--- EŞLEME: sade (WIDGET_ID, FUSEACTION) --->
        <cfif arrayLen(opFuseactions)>
          <!--- yeni widget'ta silmeye gerek yok ama tek örüntü için bırakıldı --->
          <cfquery datasource="#DSN#">
            DELETE FROM workcube_test.workcube_test.DASHBOARD_WIDGET_OPERATION_MAP
            WHERE WIDGET_ID = <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">
          </cfquery>
          <cfloop array="#opFuseactions#" index="fa">
            <cfquery datasource="#DSN#">
              INSERT INTO workcube_test.workcube_test.DASHBOARD_WIDGET_OPERATION_MAP (WIDGET_ID, FUSEACTION)
              VALUES (
                <cfqueryparam value="#newId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#fa#" cfsqltype="cf_sql_nvarchar">
              )
            </cfquery>
          </cfloop>
        </cfif>

        <cfset writeOutput(serializeJSON({success:true, widgetID:newId}))>
        <cfabort>

      <cfelse>
        <!--- UPDATE --->
        <cfquery datasource="#DSN#">
          UPDATE DASHBOARD_WIDGET_DEFS
          SET WIDGET_NAME = <cfqueryparam value="#widgetName#" cfsqltype="cf_sql_varchar">,
              DESCRIPTION = <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar">
          WHERE WIDGET_ID = <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">
        </cfquery>

        <cfquery name="up" datasource="#DSN#">
          MERGE DASHBOARD_WIDGET_SQL_CONFIG AS T
          USING (SELECT <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer"> AS WIDGET_ID) AS S
          ON (T.WIDGET_ID = S.WIDGET_ID)
          WHEN MATCHED THEN UPDATE SET
            SQL_QUERY = <cfqueryparam value="#sqlQuery#" cfsqltype="cf_sql_longvarchar">,
            CHART_TYPE = <cfqueryparam value="#chartType#" cfsqltype="cf_sql_varchar">,
            COLUMN_ROLES_JSON = <cfqueryparam value="#columnRolesJSON#" cfsqltype="cf_sql_longvarchar">,
            RECORD_DATE = GETDATE(), RECORD_EMP = <cfqueryparam value="1" cfsqltype="cf_sql_integer">
          WHEN NOT MATCHED THEN INSERT (WIDGET_ID, SQL_QUERY, CHART_TYPE, COLUMN_ROLES_JSON, RECORD_DATE, RECORD_EMP)
          VALUES (
            <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#sqlQuery#" cfsqltype="cf_sql_longvarchar">,
            <cfqueryparam value="#chartType#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#columnRolesJSON#" cfsqltype="cf_sql_longvarchar">,
            GETDATE(),
            <cfqueryparam value="1" cfsqltype="cf_sql_integer">
          );
        </cfquery>

        <!--- EŞLEMEYİ YENİLE: sil + ekle (yalnız iki kolon) --->
        <cfquery datasource="#DSN#">
          DELETE FROM workcube_test.workcube_test.DASHBOARD_WIDGET_OPERATION_MAP
          WHERE WIDGET_ID = <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cfif arrayLen(opFuseactions)>
          <cfloop array="#opFuseactions#" index="fa">
            <cfquery datasource="#DSN#">
              INSERT INTO DASHBOARD_WIDGET_OPERATION_MAP (WIDGET_ID, FUSEACTION)
              VALUES (
                <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#fa#" cfsqltype="cf_sql_nvarchar">
              )
            </cfquery>
          </cfloop>
        </cfif>

        <cfset writeOutput(serializeJSON({success:true, widgetID:widgetId}))>
        <cfabort>
      </cfif>
    </cfif>

    <!--- Bilinmeyen api --->
    <cfset writeOutput(serializeJSON({success:false, message:"Geçersiz API."}))>
    <cfcatch type="any">
      <cfset writeOutput(serializeJSON({success:false, message:cfcatch.message}))>
    </cfcatch>
  </cftry>
  <cfabort>
</cfif>
