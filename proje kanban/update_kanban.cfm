<!-- emptypopup_upd_kanban_process -->
<cfif isDefined("url.project_id") AND isDefined("url.processrowid")>
    <cfquery name="qUpdate" datasource="#DSN#">
        UPDATE PRO_PROJECTS
        SET PRO_CURRENCY_ID = <cfqueryparam value="#url.processrowid#" cfsqltype="cf_sql_integer">
        WHERE PROJECT_ID = <cfqueryparam value="#url.project_id#" cfsqltype="cf_sql_integer">
    </cfquery>
</cfif>