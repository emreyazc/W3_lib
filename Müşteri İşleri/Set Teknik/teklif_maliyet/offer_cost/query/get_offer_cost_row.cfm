<cfquery name="GET_OFFER_COST_ROW" datasource="#DSN3#">
    SELECT
        *
    FROM
        OFFER_COST_ROW
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
</cfquery>