<cfprocessingdirective pageEncoding="UTF-8">
<cfcontent type="text/html; charset=UTF-8">
<cfquery name="GET_DASHBOARD_LIST" datasource="#DSN#">
    SELECT 
        D.DASHBOARD_ID,
        D.DASHBOARD_NAME,
        U.IS_FAVORITE
    FROM 
        DASHBOARD_DEFS D
        INNER JOIN DASHBOARD_USER U ON D.DASHBOARD_ID = U.DASHBOARD_ID
    WHERE 
        U.EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
    ORDER BY
        U.IS_FAVORITE DESC, D.DASHBOARD_NAME
  </cfquery>
  
<cfoutput>
    <ul id="dashboardList" style="list-style:none; padding:0; margin:0;">
        <cfloop query="GET_DASHBOARD_LIST">
            <li class="menu-item <cfif IS_FAVORITE eq 1>favorite</cfif>" data-id="#DASHBOARD_ID#">
            <cfif IS_FAVORITE eq 1>⭐</cfif> #DASHBOARD_NAME#
            </li>
        </cfloop>
    </ul>
</cfoutput>