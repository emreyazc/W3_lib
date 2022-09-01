<cfscript>
    function tree_ (a)
    {
        SQLStr ='
                SELECT
                    PT.*
                FROM
                    PRODUCT_TREE PT
                WHERE
                    STOCK_ID = #a#
            ';
        get_product_tree_row = cfquery(SQLString : SQLStr, Datasource : dsn3);
        test_str = '#get_product_tree_row.stock_id#';
        line_number = '#get_product_tree_row.line_number#';
        writeOutput('<tr><td>#line_number#.</td><td>#test_str#</td><tr>');
    }
</cfscript>
<cfquery name="GET_PRODUCT_TREE" datasource="#DSN3#">
    SELECT
        *
    FROM
        PRODUCT_TREE
    WHERE
        STOCK_ID = #attributes.stock_id#
</cfquery>

<cf_flat_list>
    <thead>
        <tr>
            <th>Satır</th>
            <th>1. Seviye Yarı Mamüller</th>
        </tr>
    </thead>
    <tbody>
        <cfoutput query="GET_PRODUCT_TREE">
            #tree_(GET_PRODUCT_TREE.RELATED_ID)#
        </cfoutput>
    </tbody>
</cf_flat_list>