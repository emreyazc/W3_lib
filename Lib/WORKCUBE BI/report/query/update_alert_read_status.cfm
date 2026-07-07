<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">
<cfprocessingdirective pageEncoding="utf-8">

<cftry>
    <!-- gelen JSON'u al -->
    <cfset raw = toString(getHttpRequestData().content)>
    <cfif NOT len(trim(raw))>
        <cfoutput>#serializeJSON({status="error", message="Boş gövde"})#</cfoutput>
        <cfabort>
    </cfif>

    <cfset data   = deserializeJSON(raw)>
    <cfset logId  = val(data.logId)>
    <cfset isRead = val(data.isRead)>

    <cfif logId LTE 0>
        <cfoutput>#serializeJSON({status="error", message="Geçersiz log ID"})#</cfoutput>
        <cfabort>
    </cfif>

    <!-- güncelleme -->
    <cfquery datasource="#DSN#">
        UPDATE 
          DASHBOARD_NOTIFICATION
        SET 
          IS_READ = <cfqueryparam value="#isRead#" cfsqltype="cf_sql_bit">
        WHERE 
          LOG_ID = <cfqueryparam value="#logId#" cfsqltype="cf_sql_integer">
    </cfquery>

    <cfoutput>#serializeJSON({status="success", message="Güncellendi"})#</cfoutput>
  <cfcatch type="any">
      <cfoutput>#serializeJSON({status="error", message="Hata oluştu", detail=cfcatch.message})#</cfoutput>
  </cfcatch>
</cftry>
