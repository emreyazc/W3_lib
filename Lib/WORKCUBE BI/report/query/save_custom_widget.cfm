<cfcontent type="application/json">
<cftry>
    <cfset rawData = getHttpRequestData().content>
    <cfset parsedData = deserializeJSON(rawData)>

    <cfset widgetId = parsedData.widget_id>
    <cfset title = parsedData.title>
    <cfset widget_url = parsedData.src>

    <cfquery name="insertWidget" datasource="#DSN#">
        INSERT INTO DASHBOARD_WIDGET_DEFS (
            WIDGET_NAME,
            FILE_PATH,
            DESCRIPTION,
            RECORD_EMP,
            RECORD_DATE,
            IS_ACTIVE
        ) VALUES (
            <cfqueryparam value="#title#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#widget_url#" cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value='Kullanıcı tanımlı widget' cfsqltype="cf_sql_nvarchar">,
            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
            #now()#,
            1
        )
    </cfquery>
    <cfoutput>#serializeJSON({ "success": true, "message": "Widget kaydedildi!" })#</cfoutput>
    <cfcatch type="any">
        <cfsavecontent variable="ssss">
            <cfdump var="#cfcatch#">
          </cfsavecontent>
        <cffile action="write" output="#ssss#" file="c:\\custom_widget_kaydet.html">
        <cfoutput>#serializeJSON({ "success": false, "message": "#cfcatch.message#" })#</cfoutput>
    </cfcatch>
</cftry>