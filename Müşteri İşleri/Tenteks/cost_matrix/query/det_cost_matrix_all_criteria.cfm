
    <cfquery name="det_cost_matrix_all_criteria" datasource="#DSN1#">
        SELECT
            *
        FROM    
            COST_MATRIX_ALL_CRITERIA
        WHERE
            COST_MATRIX_ALL_CRITERIA_ID = #attributes.cost_matrix_all_criteria_id#
    </cfquery>