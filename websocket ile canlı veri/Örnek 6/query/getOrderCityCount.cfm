<cfcontent reset="yes" type="application/json; charset=utf-8">
<cfquery name="getOrderCityCount" datasource="#dsn#">
    SELECT CITY, COUNT(*) AS COUNT
    FROM ORDERS_TEST
    GROUP BY CITY
</cfquery>
<cfoutput>
    #serializeJSON(getOrderCityCount)#
</cfoutput>