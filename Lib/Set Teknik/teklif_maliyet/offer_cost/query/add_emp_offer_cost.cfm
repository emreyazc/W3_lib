<cfsavecontent variable="ssss">
    <cfdump var="#attributes#">
</cfsavecontent>
<cffile action="write" output="#ssss#" file="#download_folder#att.html">

<cfif len(attributes.offer_cost_date)>
    <cf_date tarih="attributes.offer_cost_date">
</cfif>

<cftry>
    <cfquery name="INSERT_OFFER_COST" datasource="#DSN3#">
        INSERT INTO OFFER_COST
            (
                OFFER_COST_STATUS,
                OFFER_COST_STAGE,
                OFFER_COST_HEAD,
                OFFER_COST_DATE,
                COMPANY_ID,
                PARTNER_ID,
                PROJECT_ID,
                RECORD_DATE,
                RECORD_EMP,
                OFFER_COST_DETAIL,
                OFFER_COST_VERSION,
                IS_TREE,
                SALES_EMP
            )
        VALUES
            (  
                <cfif isDefined("attributes.offer_cost_status")>1<cfelse>0</cfif>,
                #attributes.process_stage#,
                <cfif isDefined("attributes.offer_cost_head") and len(offer_cost_head)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.offer_cost_head#"><cfelse></cfif>,
                <cfif len(attributes.offer_cost_date)>#attributes.offer_cost_date#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.company_id") and len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.partner_id") and len(attributes.partner_id)>#attributes.partner_id#<cfelse>NULL</cfif>,
                <cfif isDefined("attributes.related_project_id") and len(attributes.related_project_id)>#attributes.related_project_id#<cfelse>NULL</cfif>,
                #NOW()#,
                #SESSION.EP.USERID#,
                <cfif isDefined("attributes.offer_cost_detail") and len(attributes.offer_cost_detail)>'#attributes.offer_cost_detail#'<cfelse>NULL</cfif>,
                0,
                0,
                <cfif isDefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#attributes.sales_emp_id#<cfelse>NULL</cfif>
            )
    </cfquery>

    <cfquery name="GET_MAX_OFFER_COST" datasource="#DSN3#">
        SELECT TOP(1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
    </cfquery>

    <cfloop index="i" from="1" to="#attributes.row_count#">
        <cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>
            <cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
                    SELECT
                        UNIT_ID,
                        UNIT
                    FROM
                        SETUP_UNIT
                    WHERE
                        UNIT = '#evaluate("attributes.product_unit#i#")#'
            </cfquery>
            <cfif isDefined("attributes.include_service_product") and attributes.include_service_product eq 1>
                <cfif evaluate('attributes.row_group_name#i#') neq 'Hizmet'>
                    <cfquery name="INSERT_OFFER_COST_ROW" datasource="#DSN3#">
                        INSERT INTO OFFER_COST_ROW
                        (
                            OFFER_COST_ID,
                            PRODUCT_ID,
                            STOCK_ID,
                            PRODUCT_NAME,
                            MANUFACT_CODE,
                            PRODUCT_CODE_2,
                            PRODUCT_UNIT,
                            PRODUCT_UNIT_ID,
                            QUANTITY,
                            MONEY,
                            PRICE_EXWORK,
                            DISCOUNT,
                            NET_PRICE_EXWORK,
                            UNIT_COST,
                            TOTAL_COST,
                            UNIT_OFFER,
                            TOTAL_OFFER,
                            EXPORT_FACTOR,
                            OFFER_FACTOR,
                            PROFIT_MARGIN,
                            IS_ALTERNATIVE,
                            IS_IMPORTED,
                            PROVISION_TIME,
                            ROW_GROUP_NAME,
                            ROW_GROUP_QUANTITY,
                            ROW_GROUP_MONEY,
                            RECORD_DATE,
                            RECORD_EMP
                        )
                        VALUES
                        (
                            #GET_MAX_OFFER_COST.OFFER_COST_ID#,
                            <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>'#evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.manufact_code2#i#') and len(evaluate("attributes.manufact_code2#i#"))>'#evaluate('attributes.manufact_code2#i#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_code_2#i#') and len(evaluate("attributes.product_code_2#i#"))>'#evaluate('attributes.product_code_2#i#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_unit#i#') and len(evaluate("attributes.product_unit#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit#i#')#"><cfelse>NULL</cfif>,
                            #GET_SETUP_UNIT.UNIT_ID#,
                            <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.quantity#i#')#"><cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.money#i#') and len(evaluate("attributes.money#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.money#i#')#"><cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_cost#i#') and len(evaluate("attributes.product_cost#i#"))>#evaluate('attributes.product_cost#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.discount#i#') and len(evaluate("attributes.discount#i#"))>#evaluate('attributes.discount#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.nettotal_cost#i#') and len(evaluate("attributes.nettotal_cost#i#"))>#evaluate('attributes.nettotal_cost#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.unit_cost#i#') and len(evaluate("attributes.unit_cost#i#"))>#evaluate('attributes.unit_cost#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.total_cost#i#') and len(evaluate("attributes.total_cost#i#"))>#evaluate('attributes.total_cost#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.unit_offer#i#') and len(evaluate("attributes.unit_offer#i#"))>#evaluate('attributes.unit_offer#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.total_offer#i#') and len(evaluate("attributes.total_offer#i#"))>#evaluate('attributes.total_offer#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.export_factor#i#') and len(evaluate("attributes.export_factor#i#"))>#evaluate('attributes.export_factor#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.offer_factor#i#') and len(evaluate("attributes.offer_factor#i#"))>#evaluate('attributes.offer_factor#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.profit_margin#i#') and len(evaluate("attributes.profit_margin#i#"))>#evaluate('attributes.profit_margin#i#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.is_alternative#i#') and len(evaluate("attributes.is_alternative#i#"))>#evaluate('attributes.is_alternative#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.is_imported#i#') and len(evaluate("attributes.is_imported#i#"))>#evaluate('attributes.is_imported#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.provision_time#i#') and len(evaluate("attributes.provision_time#i#"))>#evaluate('attributes.provision_time#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.row_group_name#i#') and len(evaluate("attributes.row_group_name#i#"))>'#evaluate('attributes.row_group_name#i#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.row_group_quantity#i#') and len(evaluate("attributes.row_group_quantity#i#"))>'#evaluate('attributes.row_group_quantity#i#')#'<cfelse>1</cfif>,
                            <cfif isDefined('attributes.row_group_money#i#') and len(evaluate("attributes.row_group_money#i#"))>'#evaluate('attributes.row_group_money#i#')#'<cfelse>NULL</cfif>,
                            #NOW()#,
                            #SESSION.EP.USERID#
                        )
                    </cfquery>
                </cfif>
            <cfelse>
                 <cfquery name="INSERT_OFFER_COST_ROW" datasource="#DSN3#">
                    INSERT INTO OFFER_COST_ROW
                    (
                        OFFER_COST_ID,
                        PRODUCT_ID,
                        STOCK_ID,
                        PRODUCT_NAME,
                        MANUFACT_CODE,
                        PRODUCT_CODE_2,
                        PRODUCT_UNIT,
                        PRODUCT_UNIT_ID,
                        QUANTITY,
                        MONEY,
                        PRICE_EXWORK,
                        DISCOUNT,
                        NET_PRICE_EXWORK,
                        UNIT_COST,
                        TOTAL_COST,
                        UNIT_OFFER,
                        TOTAL_OFFER,
                        EXPORT_FACTOR,
                        OFFER_FACTOR,
                        PROFIT_MARGIN,
                        IS_ALTERNATIVE,
                        IS_IMPORTED,
                        PROVISION_TIME,
                        ROW_GROUP_NAME,
                        ROW_GROUP_QUANTITY,
                        ROW_GROUP_MONEY,
                        RECORD_DATE,
                        RECORD_EMP
                    )
                    VALUES
                    (
                        #GET_MAX_OFFER_COST.OFFER_COST_ID#,
                        <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>'#evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.manufact_code2#i#') and len(evaluate("attributes.manufact_code2#i#"))>'#evaluate('attributes.manufact_code2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_code_2#i#') and len(evaluate("attributes.product_code_2#i#"))>'#evaluate('attributes.product_code_2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_unit#i#') and len(evaluate("attributes.product_unit#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit#i#')#"><cfelse>NULL</cfif>,
                        #GET_SETUP_UNIT.UNIT_ID#,
                        <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.quantity#i#')#"><cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.money#i#') and len(evaluate("attributes.money#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.money#i#')#"><cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_cost#i#') and len(evaluate("attributes.product_cost#i#"))>#evaluate('attributes.product_cost#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.discount#i#') and len(evaluate("attributes.discount#i#"))>#evaluate('attributes.discount#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.nettotal_cost#i#') and len(evaluate("attributes.nettotal_cost#i#"))>#evaluate('attributes.nettotal_cost#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.unit_cost#i#') and len(evaluate("attributes.unit_cost#i#"))>#evaluate('attributes.unit_cost#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.total_cost#i#') and len(evaluate("attributes.total_cost#i#"))>#evaluate('attributes.total_cost#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.unit_offer#i#') and len(evaluate("attributes.unit_offer#i#"))>#evaluate('attributes.unit_offer#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.total_offer#i#') and len(evaluate("attributes.total_offer#i#"))>#evaluate('attributes.total_offer#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.export_factor#i#') and len(evaluate("attributes.export_factor#i#"))>#evaluate('attributes.export_factor#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.offer_factor#i#') and len(evaluate("attributes.offer_factor#i#"))>#evaluate('attributes.offer_factor#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.profit_margin#i#') and len(evaluate("attributes.profit_margin#i#"))>#evaluate('attributes.profit_margin#i#')#<cfelse>0</cfif>,
                        <cfif isDefined('attributes.is_alternative#i#') and len(evaluate("attributes.is_alternative#i#"))>#evaluate('attributes.is_alternative#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.is_imported#i#') and len(evaluate("attributes.is_imported#i#"))>#evaluate('attributes.is_imported#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.provision_time#i#') and len(evaluate("attributes.provision_time#i#"))>#evaluate('attributes.provision_time#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.row_group_name#i#') and len(evaluate("attributes.row_group_name#i#"))>'#evaluate('attributes.row_group_name#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.row_group_quantity#i#') and len(evaluate("attributes.row_group_quantity#i#"))>'#evaluate('attributes.row_group_quantity#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.row_group_money_hizmet#i#') and len(evaluate("attributes.row_group_money_hizmet#i#"))>'#evaluate('attributes.row_group_money_hizmet#i#')#'<cfelse>NULL</cfif>,
                        #NOW()#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
            </cfif>
        </cfif>
    </cfloop>
    <cfquery name="upd_offer_cost_number" datasource="#DSN3#">
        UPDATE OFFER_COST_NUMBER
        SET DEPT_OFFER_COST_NUMBER = DEPT_OFFER_COST_NUMBER+1
        WHERE OFFER_COST_NUMBER_ID = #attributes.offer_cost_number_id#
    </cfquery>
    
    <cfquery name="GET_OFFER_COS_ROW_GROUP" datasource="#DSN3#">
        SELECT DISTINCT 
            ROW_GROUP_NAME,
            ROW_GROUP_QUANTITY,
            ROW_GROUP_MONEY
        FROM
            OFFER_COST_ROW
        WHERE
            OFFER_COST_ID = #GET_MAX_OFFER_COST.OFFER_COST_ID#
            AND
            ROW_GROUP_NAME IS NOT NULL
    </cfquery>

    <cfloop query="#GET_OFFER_COS_ROW_GROUP#">
        <cfquery name="ADD_OFFER_COST_GROUP" datasource="#DSN3#">
            INSERT INTO OFFER_COST_GROUP_PRODUCT
                (
                    OFFER_COST_ID,
                    OFFER_COST_GROUP,
                    GROUP_QUANTITY,
                    GROUP_MONEY
                )
            VALUES
                (  
                    #GET_MAX_OFFER_COST.OFFER_COST_ID#,
                    <cfif len(GET_OFFER_COS_ROW_GROUP.ROW_GROUP_NAME)>'#GET_OFFER_COS_ROW_GROUP.ROW_GROUP_NAME#'<cfelse>NULL</cfif>,
                    #GET_OFFER_COS_ROW_GROUP.ROW_GROUP_QUANTITY#,
                    '#GET_OFFER_COS_ROW_GROUP.ROW_GROUP_MONEY#'
                )
        </cfquery>
    </cfloop>

    <cfset attributes.offer_cost_id = GET_MAX_OFFER_COST.OFFER_COST_ID>

    <script type="text/javascript">
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
    </script>
    <cfcatch  type="any">
        <cfsavecontent variable="ssss">
            <cfdump var="#cfcatch#">
        </cfsavecontent>
        <cffile action="write" output="#ssss#" file="#download_folder#hataaaa.html">
</cfcatch>
</cftry>
