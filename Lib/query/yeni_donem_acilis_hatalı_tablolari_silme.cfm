<!---
<cfquery name="del_" datasource="#dsn#">
    DELETE FROM SETUP_PERIOD WHERE PERIOD_ID = #get_max_id.max_id#
</cfquery>
<cfquery name="del_2" datasource="#dsn#">
    DELETE FROM SETUP_MONEY WHERE PERIOD_ID = #get_max_id.max_id#
</cfquery>

<cfset db_user_ = 'workcube'>
<cfset db_pass_ = 'M%iFa2!4Tf1c4?Lu'>
<cfset cf_admin_password = '?h3L9?A1xF52xM8*'>

<cfset new_dsn_ = '#dsn#_2023_2'>

<cfquery name="getActiveLogin" datasource="_#dsn#">
    SELECT spid FROM sys.sysprocesses where loginame = '#new_dsn_#'
</cfquery>	
<cfif getActiveLogin.recordcount>
    <cfquery name="killActiveLogin" datasource="_#dsn#">
       kill #getActiveLogin.spid#
    </cfquery>
</cfif>
<!---
<cfquery name="delUser" datasource="_#dsn#">
    DROP USER #new_dsn_#
</cfquery>
<cfquery name="delLogin" datasource="_#dsn#">
    DROP LOGIN #new_dsn_#
</cfquery>


<cfquery name="getSchemaTables" datasource="_#dsn#">
    SELECT  'DROP TABLE #new_dsn_#.' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13) AS DEL_TABLE
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '#new_dsn_#'
        AND TABLE_TYPE = 'BASE TABLE'
</cfquery>

<cfif getSchemaTables.recordcount>
    <cfquery name="delSchemaTables" datasource="_#dsn#">
        <cfloop query="getSchemaTables">
            #DEL_TABLE#
        </cfloop>
    </cfquery>
</cfif>

<cfquery name="getSchemaViews" datasource="_#dsn#">
    SELECT  'DROP VIEW #new_dsn_#.' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13) AS DEL_TABLE
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '#new_dsn_#'
        AND TABLE_TYPE = 'VIEW'
</cfquery>

<cfif getSchemaViews.recordcount>
    <cfquery name="delSchemaViews" datasource="_#dsn#">
        <cfloop query="getSchemaViews">
            #DEL_TABLE#
        </cfloop>
    </cfquery>
</cfif>

<cfquery name="getSchemaProcedures" datasource="_#dsn#">
    SELECT  'DROP PROCEDURE #new_dsn_#.' + QUOTENAME(ROUTINE_NAME) + ';' + CHAR(13) AS DEL_TABLE
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '#new_dsn_#'
        AND ROUTINE_TYPE = 'PROCEDURE'
</cfquery>

<cfif getSchemaProcedures.recordcount>
    <cfquery name="delSchemaProcedures" datasource="_#dsn#">
        <cfloop query="getSchemaProcedures">
            #DEL_TABLE#
        </cfloop>
    </cfquery>
</cfif>

<cfquery name="getSchemaFunctions" datasource="_#dsn#">
    SELECT  'DROP FUNCTION #new_dsn_#.' + QUOTENAME(ROUTINE_NAME) + ';' + CHAR(13) AS DEL_TABLE
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_SCHEMA = '#new_dsn_#'
        AND ROUTINE_TYPE = 'FUNCTION'
</cfquery>

<cfif getSchemaFunctions.recordcount>
    <cfquery name="delSchemaFunctions" datasource="_#dsn#">
        <cfloop query="getSchemaFunctions">
            #DEL_TABLE#
        </cfloop>
    </cfquery>
</cfif>
<cfquery name="delSchema" datasource="_#dsn#">
    DROP SCHEMA #new_dsn_#
</cfquery>
--->
--->