
    <cfquery name="det_cost_matrix" datasource="#DSN1#">
        SELECT
            *
        FROM    
            COST_MATRIX
        <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
            WHERE
                MAIN_PRODUCT_NAME LIKE '%#attributes.keyword#%'
        </cfif>
    </cfquery>