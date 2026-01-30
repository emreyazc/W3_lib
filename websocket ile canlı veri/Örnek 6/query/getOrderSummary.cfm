<cfcontent reset="yes" type="application/json; charset=utf-8">
<cfquery name="qSummary" datasource="#DSN#">
    SELECT COUNT(*) AS ORDER_COUNT
    FROM workcube_test.workcube_test.ORDERS_TEST
    WHERE ORDERDATE >= DATEADD(day, -7, GETDATE())
</cfquery>

<cfset result = { ORDER_COUNT = qSummary.ORDER_COUNT[1] }>

<cfoutput>#serializeJSON(result)#</cfoutput>