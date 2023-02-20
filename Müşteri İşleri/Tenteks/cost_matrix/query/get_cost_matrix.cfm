
    <cfquery name="GET_COST_MATRIX" datasource="#DSN1#">
        SELECT
            *
        FROM    
            COST_MATRIX
        WHERE
            COST_MATRIX_ID = #attributes.cost_matrix_id#
    </cfquery>