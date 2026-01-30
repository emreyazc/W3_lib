<cfcontent type="application/json; charset=utf-8">
<cfprocessingdirective pageencoding="utf-8">

<cftry>

  <!--- 1. JSON içeriğini al --->
  <cfset rawData = getHttpRequestData().content>

  <!--- 2. Boş veri kontrolü --->
  <cfif NOT len(trim(rawData))>
    <cfset response = { success = false, error = "Boş JSON verisi geldi." }>
    <cfoutput>#serializeJSON(response, false)#</cfoutput>
    <cfabort>
  </cfif>

  <!--- 3. JSON parse --->
  <cfset jsonBody = deserializeJSON(rawData)>
  <cfset layout = jsonBody.layout>

  <!--- 4. Eski kayıtları sil --->

  <cfquery datasource="#DSN#">
    DELETE FROM DASHBOARD_USER_LAYOUT WHERE EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer"> AND DASHBOARD_KEY = 'HolisticLiveDashboard'
  </cfquery>

  <!--- 5. Yeni kayıtları kaydet --->
  <cfloop array="#layout#" index="item">
    <cfset fuseaction = structKeyExists(item, "GRAPH_FUSEACTION") ? item.GRAPH_FUSEACTION : "report.orders_graph">
    <cfquery datasource="#DSN#">
      INSERT INTO DASHBOARD_USER_LAYOUT (
        EMPLOYEE_ID,
        DASHBOARD_KEY,
        GRAPH_FUSEACTION,
        CUSTOM_TITLE,
        WIDGET_ID,
        POSITION_X,
        POSITION_Y,
        WIDTH,
        HEIGHT,
        SORT_ORDER,
        IS_ACTIVE,
        RECORD_DATE,
        RECORD_EMP
      ) VALUES (
        <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
        'HolisticLiveDashboard',
        <cfqueryparam value="#fuseaction#" cfsqltype="cf_sql_nvarchar">,
        <cfqueryparam value="#item.CUSTOM_TITLE#" cfsqltype="cf_sql_nvarchar">,
        <cfqueryparam value="#val(item.WIDGET_ID)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(item.POSITION_X)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(item.POSITION_Y)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(item.WIDTH)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(item.HEIGHT)#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#val(item.SORT_ORDER)#" cfsqltype="cf_sql_integer">,
        1,
        #now()#,
        <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
      )
    </cfquery>
  </cfloop>

  <!--- 6. Başarılı dönüş --->
  <cfset response = { success = true }>
  <cfoutput>#serializeJSON(response, false)#</cfoutput>

<cfcatch type="any">
  <cfset response = {
    success = false,
    error = cfcatch.message,
    detail = cfcatch.detail,
    where = cfcatch.where
  }>
  <cfoutput>#serializeJSON(response, false)#</cfoutput>
</cfcatch>
</cftry>
