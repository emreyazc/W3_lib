<cfcontent type="application/json">
<cftry>
    <cfif NOT structKeyExists(form, "dashboard_name")>
        <cfoutput>{"SUCCESS":false,"MESSAGE":"Eksik veri"}</cfoutput>
        <cfabort>
    </cfif>

    <cfquery name="qInsert" datasource="#DSN#">
        INSERT INTO 
            DASHBOARD_DEFS 
            (
                DASHBOARD_NAME, 
                MODULE_ID, 
                IS_PUBLIC, 
                RECORD_EMP, 
                RECORD_DATE
            )
        VALUES (
            <cfqueryparam value="#form.dashboard_name#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#form.module_id#" cfsqltype="cf_sql_integer" null="#NOT len(form.module_id)#">,
            <cfif isDefined("form.is_public") and len(form.is_public)><cfqueryparam value="#form.is_public#" cfsqltype="cf_sql_bit"><cfelse>0</cfif>,
            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
            #now()#
        )
    </cfquery>

    <cfquery name="qGetID" datasource="#DSN#">
        SELECT TOP 1 DASHBOARD_ID FROM DASHBOARD_DEFS ORDER BY DASHBOARD_ID DESC
    </cfquery>
    <cfset newDashboardId = qGetID.DASHBOARD_ID>

    <cfquery datasource="#DSN#">
        INSERT INTO 
            DASHBOARD_USER
            (
                DASHBOARD_ID,
                EMPLOYEE_ID,
                IS_OWNER,
                IS_FAVORITE,
                CAN_EDIT
            )
        VALUES (
            <cfqueryparam value="#newDashboardId#" cfsqltype="cf_sql_integer">,
            <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">,
            1,
            <cfqueryparam value="#structKeyExists(form,'is_favorite')#" cfsqltype="cf_sql_bit">,
            1
        )
    </cfquery>
    <cfoutput>{"SUCCESS":true,"NEW_ID":#newDashboardId#}</cfoutput>
<cfcatch>
    <cfsavecontent variable="ssss">
        <cfdump var="#cfcatch#">
    </cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\\add_dashboard_hata.html">
    <cfoutput>{"SUCCESS":false,"MESSAGE":"#cfcatch.message#"}</cfoutput>
</cfcatch>
</cftry>
