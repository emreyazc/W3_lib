<cfcontent type="application/json; charset=utf-8">
<cftry>
    <!--- URL parametresi al --->
    <cfparam name="url.widgetId" default="0">
    <cfset widgetId = val(url.widgetId)>
    <!--- Parametre kontrolü --->
    <cfif widgetId EQ 0>
        <cfoutput>#serializeJSON({ "error"=true, "message"="widgetId gerekli" })#</cfoutput>
        <cfabort>
    </cfif>
    <!--- Sorgu --->
    <cfquery name="qMetrics" datasource="#dsn#">
        SELECT 
            METADATA_ID, 
            WIDGET_ID, 
            METRIC_TYPE, 
            DISPLAY_NAME, 
            VALUE_FIELD, 
            VALUE_UNIT
        FROM 
            DASHBOARD_WIDGET_SEMANTIC_METADATA
        WHERE 
            IS_ACTIVE = 1 
            AND WIDGET_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#widgetId#">
        ORDER BY 
            DISPLAY_NAME
    </cfquery>
    <!--- JSON dönüş --->
    <cfset result = []>
    <cfif qMetrics.recordCount GT 0>
        <cfloop query="qMetrics">
            <cfset arrayAppend(result, {
                "METADATA_ID" = qMetrics.METADATA_ID,
                "WIDGET_ID"   = qMetrics.WIDGET_ID,
                "METRIC_TYPE" = qMetrics.METRIC_TYPE,
                "DISPLAY_NAME"= qMetrics.DISPLAY_NAME,
                "VALUE_FIELD" = qMetrics.VALUE_FIELD,
                "VALUE_UNIT"  = qMetrics.VALUE_UNIT
            })>
        </cfloop>
    </cfif>
    <cfoutput>#serializeJSON(result)#</cfoutput>
    <cfcatch type="any">
        <!--- Hata durumunda bile boş array dön --->
        <cfoutput>#serializeJSON([])#</cfoutput>
        <!--- Log atmak istersen:
        <cflog file="get_metrics" type="error" text="Hata: #cfcatch.message# | #cfcatch.detail#">
        --->
    </cfcatch>
</cftry>
