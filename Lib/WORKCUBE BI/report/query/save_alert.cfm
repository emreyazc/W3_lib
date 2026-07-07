<cftry>

  <cfcontent type="application/json; charset=utf-8">

  <cfparam name="DSN" default="workcube_test">


  <cfset raw = toString(getHTTPRequestData().content ?: "")>
  <cfif NOT len(raw)>
    <cfoutput>#serializeJSON({ok:false, error="Boş gövde"})#</cfoutput><cfabort>
  </cfif>
  <cfset body = deserializeJSON(raw)>


  <cfset alertId     = val(body.alertId ?: 0)>
  <cfset dashboardId = val(body.dashboardId ?: 0)>
  <cfset widgetId    = val(body.widgetId ?: 0)>
  <cfset alertType   = trim(body.alertType ?: "alarm")>
  <cfset metric      = trim(body.metric ?: "")>
  <cfset operator    = trim(body.operator ?: ">")>
  <cfset valueStr    = trim(body.value ?: "")>          
  <cfset channels    = body.channels ?: []>

  <cfset description = ( structKeyExists(body,"description") ? trim(toString(body.description)) : "" )>

  <cfset cooldownIsNull = ( NOT structKeyExists(body,"cooldownMinutes") ) OR ( NOT len(trim( toString(body.cooldownMinutes) )) )>
  <cfset cooldownMinutes = cooldownIsNull ? 0 : val(body.cooldownMinutes)>


  <cfif NOT dashboardId OR NOT widgetId OR NOT len(metric) OR NOT len(operator) OR NOT len(valueStr)>
    <cfoutput>#serializeJSON({ok:false, error="Eksik parametre"})#</cfoutput><cfabort>
  </cfif>

  <cfset userId = val(session.ep.userid ?: 0)>

  <cfset chEmail    = (arrayFindNoCase(channels, "email")    GT 0) ? 1 : 0>
  <cfset chSlack    = (arrayFindNoCase(channels, "slack")    GT 0) ? 1 : 0>
  <cfset chDiscord  = (arrayFindNoCase(channels, "discord")  GT 0) ? 1 : 0>
  <cfset chSms      = (arrayFindNoCase(channels, "sms")      GT 0) ? 1 : 0>
  <cfset chWhatsapp = (arrayFindNoCase(channels, "whatsapp") GT 0) ? 1 : 0>

  <cfset mode = "insert">
  <cfset targetAlertId = 0>

  <cfif alertId GT 0>
    <cfset mode = "update">
    <cfset targetAlertId = alertId>
  <cfelse>
    <cfquery name="qCheck" datasource="#DSN#">
      SELECT ALERT_ID
      FROM DASHBOARD_ALERT_RULES
      WHERE EMPLOYEE_ID = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
        AND DASHBOARD_ID = <cfqueryparam value="#dashboardId#" cfsqltype="cf_sql_integer">
        AND WIDGET_ID = <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">
        AND METRIC_NAME = <cfqueryparam value="#metric#" cfsqltype="cf_sql_varchar">
    </cfquery>
    <cfif qCheck.recordCount>
      <cfset mode = "update">
      <cfset targetAlertId = qCheck.ALERT_ID[1]>
    </cfif>
  </cfif>

  <cfif mode EQ "update">
    <cfquery datasource="#DSN#">
      UPDATE DASHBOARD_ALERT_RULES
      SET
        ALERT_TYPE          = <cfqueryparam value="#alertType#" cfsqltype="cf_sql_varchar">,
        CONDITION_OPERATOR  = <cfqueryparam value="#operator#" cfsqltype="cf_sql_varchar">,
        CONDITION_VALUE     = <cfqueryparam value="#valueStr#" cfsqltype="cf_sql_varchar">,
        CHANNEL_EMAIL       = <cfqueryparam value="#chEmail#" cfsqltype="cf_sql_bit">,
        CHANNEL_SLACK       = <cfqueryparam value="#chSlack#" cfsqltype="cf_sql_bit">,
        CHANNEL_DISCORD     = <cfqueryparam value="#chDiscord#" cfsqltype="cf_sql_bit">,
        CHANNEL_SMS         = <cfqueryparam value="#chSms#" cfsqltype="cf_sql_bit">,
        CHANNEL_WHATSAPP    = <cfqueryparam value="#chWhatsapp#" cfsqltype="cf_sql_bit">,
        DESCRIPTION         = <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar" null="#NOT len(description)#">,
        COOLDOWN_MINUTES = <cfqueryparam value="#cooldownMinutes#" cfsqltype="cf_sql_integer" null="#cooldownIsNull#">,
        IS_ACTIVE           = 1,
        RECORD_DATE         = GETDATE()
      WHERE ALERT_ID = <cfqueryparam value="#targetAlertId#" cfsqltype="cf_sql_integer">
        AND EMPLOYEE_ID  = <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">
        AND DASHBOARD_ID = <cfqueryparam value="#dashboardId#" cfsqltype="cf_sql_integer">
        AND WIDGET_ID = <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfoutput>#serializeJSON({ok:true, mode="update", alertId=targetAlertId})#</cfoutput>

  <cfelse>
    <cfquery name="qIns" datasource="#DSN#">
      INSERT INTO DASHBOARD_ALERT_RULES
      (
        EMPLOYEE_ID,
        DASHBOARD_ID,
        WIDGET_ID,
        ALERT_TYPE,
        METRIC_NAME,
        CONDITION_OPERATOR,
        CONDITION_VALUE,
        CHANNEL_EMAIL,
        CHANNEL_SLACK,
        CHANNEL_DISCORD,
        CHANNEL_SMS,
        CHANNEL_WHATSAPP,
        DESCRIPTION,
        COOLDOWN_MINUTES,
        IS_ACTIVE,
        RECORD_DATE
      )
      OUTPUT INSERTED.ALERT_ID
      VALUES
      (
        <cfqueryparam value="#userId#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#dashboardId#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#widgetId#" cfsqltype="cf_sql_integer">,
        <cfqueryparam value="#alertType#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#metric#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#operator#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#valueStr#" cfsqltype="cf_sql_varchar">,
        <cfqueryparam value="#chEmail#" cfsqltype="cf_sql_bit">,
        <cfqueryparam value="#chSlack#" cfsqltype="cf_sql_bit">,
        <cfqueryparam value="#chDiscord#" cfsqltype="cf_sql_bit">,
        <cfqueryparam value="#chSms#" cfsqltype="cf_sql_bit">,
        <cfqueryparam value="#chWhatsapp#" cfsqltype="cf_sql_bit">,
        <cfqueryparam value="#description#" cfsqltype="cf_sql_varchar" null="#NOT len(description)#">,
        <cfqueryparam value="#cooldownMinutes#" cfsqltype="cf_sql_integer" null="#cooldownIsNull#">,
        1,
        GETDATE()
      )
    </cfquery>

    <cfset newId = qIns.recordCount ? qIns.ALERT_ID[1] : 0>
    <cfoutput>#serializeJSON({ok:true, mode="insert", alertId=newId})#</cfoutput>
  </cfif>

  <cfcatch type="any">
    <cfheader statuscode="500" statustext="Server Error">
    <cfoutput>#serializeJSON({ok:false, error=cfcatch.message})#</cfoutput>
  </cfcatch>
</cftry>
