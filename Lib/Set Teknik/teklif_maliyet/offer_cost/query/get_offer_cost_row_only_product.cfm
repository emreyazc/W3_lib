<cfquery name="GET_OFFER_COST_ROW_ONLY_PRODUCT" datasource="#DSN3#">
    SELECT
        *
    FROM
        OFFER_COST_ROW
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
        AND
        ROW_GROUP_NAME <> 'Hizmet'
        AND
        IS_ALTERNATIVE <> 2
</cfquery>