<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <cfparam name="DSN" default="workcube_test">

  <cfparam name="url.widgetId" type="numeric">
  <cfparam name="url.metricName" default="">
  <cfparam name="url.dashboardId" default="">
  <cfparam name="url.widgetType" default="">

  <cfquery name="q" datasource="#DSN#">
    SELECT
      A.ALERT_ID,
      A.EMPLOYEE_ID,
      A.WIDGET_ID,
      A.ALERT_TYPE,
      A.METRIC_NAME,
      A.CONDITION_OPERATOR,
      A.CONDITION_VALUE,
      A.CHANNEL_EMAIL, A.CHANNEL_SLACK, A.CHANNEL_DISCORD, A.CHANNEL_SMS, A.CHANNEL_WHATSAPP,
      A.DESCRIPTION,                   
      A.COOLDOWN_MINUTES,              
      A.LAST_SENT_AT,                  
      A.IS_ACTIVE,
      A.RECORD_DATE,
      A.DASHBOARD_ID,
      W.WIDGET_TYPE
    FROM DASHBOARD_ALERT_RULES A
    LEFT JOIN DASHBOARD_WIDGET_DEFS W ON W.WIDGET_ID = A.WIDGET_ID
    WHERE A.WIDGET_ID = <cfqueryparam value="#url.widgetId#" cfsqltype="cf_sql_integer">
      <cfif len(url.metricName)>
        AND A.METRIC_NAME = <cfqueryparam value="#url.metricName#" cfsqltype="cf_sql_varchar">
      </cfif>
      <cfif len(url.dashboardId)>
        AND A.DASHBOARD_ID = <cfqueryparam value="#url.dashboardId#" cfsqltype="cf_sql_integer">
      </cfif>
      <cfif len(url.widgetType)>
        AND W.WIDGET_TYPE = <cfqueryparam value="#url.widgetType#" cfsqltype="cf_sql_integer">
      </cfif>
    ORDER BY A.RECORD_DATE DESC
  </cfquery>

  <cfset data = []>
  <cfloop query="q">
    <cfset channels = []>
    <cfif q.CHANNEL_EMAIL EQ 1><cfset arrayAppend(channels,"email")></cfif>
    <cfif q.CHANNEL_SLACK EQ 1><cfset arrayAppend(channels,"slack")></cfif>
    <cfif q.CHANNEL_DISCORD EQ 1><cfset arrayAppend(channels,"discord")></cfif>
    <cfif q.CHANNEL_SMS EQ 1><cfset arrayAppend(channels,"sms")></cfif>
    <cfif q.CHANNEL_WHATSAPP EQ 1><cfset arrayAppend(channels,"whatsapp")></cfif>

    <cfset row = {
      "RULEID":        q.ALERT_ID,
      "WIDGETID":      q.WIDGET_ID,
      "WIDGETTYPE":    (NOT isNull(q.WIDGET_TYPE) ? q.WIDGET_TYPE : 0),
      "ALERTTYPE":     q.ALERT_TYPE,
      "TARGETFIELD":   q.METRIC_NAME,
      "OPERATOR":      q.CONDITION_OPERATOR,
      "VALUE":         q.CONDITION_VALUE,
      "CHANNELS":      channels,
      "ISACTIVE":      q.IS_ACTIVE,
      "DASHBOARDID":   q.DASHBOARD_ID,
      "RECORDDATE":    dateTimeFormat(q.RECORD_DATE, "yyyy-mm-dd HH:nn:ss"),

      "DESCRIPTION":       q.DESCRIPTION,
      "COOLDOWN_MINUTES":  q.COOLDOWN_MINUTES,
      "LAST_SENT_AT":      ( isNull(q.LAST_SENT_AT) ? "" : dateTimeFormat(q.LAST_SENT_AT, "yyyy-mm-dd HH:nn:ss") ),

      "ruleId":        q.ALERT_ID,
      "widgetId":      q.WIDGET_ID,
      "widgetType":    (NOT isNull(q.WIDGET_TYPE) ? q.WIDGET_TYPE : 0),
      "alertType":     q.ALERT_TYPE,
      "targetField":   q.METRIC_NAME,
      "operator":      q.CONDITION_OPERATOR,
      "value":         q.CONDITION_VALUE,
      "isActive":      q.IS_ACTIVE,
      "dashboardId":   q.DASHBOARD_ID,
      "recordDate":    dateTimeFormat(q.RECORD_DATE, "yyyy-mm-dd HH:nn:ss"),
      "description":       q.DESCRIPTION,
      "cooldownMinutes":   q.COOLDOWN_MINUTES,
      "lastSentAt":        ( isNull(q.LAST_SENT_AT) ? "" : dateTimeFormat(q.LAST_SENT_AT, "yyyy-mm-dd HH:nn:ss") )
    }>

    <cfset arrayAppend(data, row)>
  </cfloop>

  <cfoutput>#serializeJSON(data)#</cfoutput>

  <cfcatch type="any">
    <cfoutput>#serializeJSON({ ok:false, error=cfcatch.message })#</cfoutput>
  </cfcatch>
</cftry>
