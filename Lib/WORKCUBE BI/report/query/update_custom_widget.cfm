<cftry>
  <cfset rawData = getHttpRequestData().content>
  <cfset parsedData = deserializeJSON(rawData)>

  <cfset widgetId = parsedData.widget_id>
  <cfset title = parsedData.title>
  <cfset widget_url = parsedData.src>

  <cfquery datasource="#DSN#">
    UPDATE   
      DASHBOARD_WIDGET_DEFS
    SET 
      WIDGET_NAME = <cfqueryparam value="#title#" cfsqltype="cf_sql_nvarchar">,
      FILE_PATH = <cfqueryparam value="#widget_url#" cfsqltype="cf_sql_nvarchar">,
      DESCRIPTION = <cfqueryparam value='Kullanıcı tanımlı widget' cfsqltype="cf_sql_nvarchar">,
      UPDATE_DATE = <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
      UPDATE_EMP = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
      IS_ACTIVE = 1
    WHERE 
      WIDGET_ID = <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">
  </cfquery>
  <cfoutput>#serializeJSON({ "success": true, "message": "Widget güncellendi." })#</cfoutput>
  <cfcatch type="any">
    <cfsavecontent variable="ssss">
        <cfdump var="#cfcatch#">
      </cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\\custom_widget_guncelle.html">
    <cfoutput>#serializeJSON({ "success": false, "message": "#cfcatch.message#" })#</cfoutput>
  </cfcatch>
</cftry>