<cfscript>
    matrix_range = REReplace("#attributes.matrix_range#",",",".","ALL");
    matrix_max_width = REReplace("#attributes.matrix_max_width#",",",".","ALL");
    matrix_max_height = REReplace("#attributes.matrix_max_height#",",",".","ALL");
    matrix_min_width = REReplace("#attributes.matrix_min_width#",",",".","ALL");
    matrix_min_height = REReplace("#attributes.matrix_min_height#",",",".","ALL");
    profit_rate = REReplace("#attributes.profit_rate#",",",".","ALL");
</cfscript>

<cfquery  name="ADD_COST_MATRIX_ALL_CRITERIA" datasource="#DSN1#">
    INSERT INTO
        COST_MATRIX_ALL_CRITERIA
        (  
            COST_MATRIX_ID,
            MATRIX_NAME,
            MATRIX_RANGE,
            MAX_MATRIX_WIDTH,
            MAX_MATRIX_HEIGHT,
            MIN_MATRIX_WIDTH,
            MIN_MATRIX_HEIGHT,
            PROFIT_RATE,
            RECORDT_DATE,
            RECORD_MEMBER
        )
        VALUES
            (
                <cfif isDefined("attributes.cost_matrix_id") and len(attributes.cost_matrix_id)>#attributes.cost_matrix_id#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_name") and len(attributes.matrix_name)>'#attributes.matrix_name#'<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_range") and len(attributes.matrix_range)>#matrix_range#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_max_width") and len(attributes.matrix_max_width)>#matrix_max_width#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_max_height") and len(attributes.matrix_max_height)>#matrix_max_height#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_min_width") and len(attributes.matrix_min_width)>#matrix_min_width#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.matrix_min_height") and len(attributes.matrix_min_height)>#matrix_min_height#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.profit_rate") and len(attributes.profit_rate)>#profit_rate#<cfelse>NULL</cfif>,
                #now()#,
                <cfif isDefined("session.ep.userid") and len(session.ep.userid)>#session.ep.userid#<cfelse>NULL</cfif>
            )
</cfquery>

<cfquery name="GET_MAX_MATRIX_ALL_CRITERIA" datasource="#DSN1#">
    SELECT TOP(1)
        COST_MATRIX_ALL_CRITERIA_ID
    FROM
        COST_MATRIX_ALL_CRITERIA
    ORDER BY
        COST_MATRIX_ALL_CRITERIA_ID DESC
</cfquery>

<script type="text/javascript">
        window.location.href="<cfoutput>#request.self#?fuseaction=sales.det_cost_matrix_all_criteria&event=det&cost_matrix_all_criteria_id=#GET_MAX_MATRIX_ALL_CRITERIA.COST_MATRIX_ALL_CRITERIA_ID#</cfoutput>";
</script>