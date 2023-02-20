<cfif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 1> <!--- Silmek İçin --->
    <cfquery name="DEL_OFFER_COST" datasource="#DSN3#">
        DELETE FROM OFFER_COST WHERE OFFER_COST_ID = #attributes.offer_cost_id#;
    </cfquery>

    <cfquery name="DEL_OFFER_COST_ROW" datasource="#DSN3#">
        DELETE FROM OFFER_COST_ROW WHERE OFFER_COST_ID = #attributes.offer_cost_id#;
    </cfquery>

    <script type="text/javascript">
        window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&is_submit=1</cfoutput>';
    </script>

    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 2> <!--- Güncellemek İçin --->
        <cfif len(attributes.offer_cost_date)><cf_date tarih="attributes.offer_cost_date"></cfif>
        <cfquery name="UPD_OFFER_COST" datasource="#DSN3#">
            UPDATE OFFER_COST
            SET
                OFFER_COST_STATUS = <cfif isDefined("attributes.offer_cost_status")>1<cfelse>0</cfif>,
                OFFER_COST_STAGE = #attributes.process_stage#,
                OFFER_COST_HEAD = <cfif isDefined("attributes.offer_cost_head") and len(offer_cost_head)><cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.offer_cost_head#"><cfelse></cfif>,
                OFFER_COST_DATE = <cfif len(attributes.offer_cost_date)>#attributes.offer_cost_date#<cfelse>NULL</cfif>,
                COMPANY_ID = <cfif isDefined("attributes.company_id") and len(attributes.company_id)>#attributes.company_id#<cfelse>NULL</cfif>,
                PARTNER_ID = <cfif isDefined("attributes.partner_id") and len(attributes.partner_id)>#attributes.partner_id#<cfelse>NULL</cfif>,
                PROJECT_ID = <cfif isDefined("attributes.related_project_id") and len(attributes.related_project_id)>#attributes.related_project_id#<cfelse>NULL</cfif>,
                UPDATE_DATE = #NOW()#,
                UPDATE_EMP = #SESSION.EP.USERID#,
                OFFER_COST_DETAIL = <cfif isDefined("attributes.offer_cost_detail") and len(attributes.offer_cost_detail)>'#attributes.offer_cost_detail#'<cfelse>NULL</cfif>,
                SALES_EMP = <cfif isDefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#attributes.sales_emp_id#<cfelse>NULL</cfif>
            WHERE OFFER_COST_ID = #attributes.offer_cost_id#
        </cfquery>

        
        <cfquery name="DEL_OFFER_COST_ROW" datasource="#DSN3#">
            DELETE FROM OFFER_COST_ROW WHERE OFFER_COST_ID = #attributes.offer_cost_id#;
        </cfquery>

        <cfloop index="i" from="0" to="#attributes.row_count#">
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
                        #attributes.offer_cost_id#,
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
        </cfloop>
        

        <cfif isDefined("attributes.include_service_product") and attributes.include_service_product eq 1>
            <cfloop index="j" from="1" to="#attributes.row_count_2#">                
                <cfif isDefined('attributes.product_name_hizmet#j#') and len(evaluate("attributes.product_name_hizmet#j#"))>
                    <cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
                        SELECT
                            UNIT_ID,
                            UNIT
                        FROM
                            SETUP_UNIT
                        WHERE
                            UNIT = '#evaluate("attributes.product_unit_hizmet#j#")#'
                    </cfquery>
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
                            #attributes.offer_cost_id#,
                            <cfif isDefined('attributes.product_id_hizmet#j#') and len(evaluate("attributes.product_id_hizmet#j#"))>#evaluate('attributes.product_id_hizmet#j#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.stock_id_hizmet#j#') and len(evaluate("attributes.stock_id_hizmet#j#"))>#evaluate('attributes.stock_id_hizmet#j#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_name_hizmet#j#') and len(evaluate("attributes.product_name_hizmet#j#"))>'#evaluate('attributes.product_name_hizmet#j#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.manufact_code2_hizmet#j#') and len(evaluate("attributes.manufact_code2_hizmet#j#"))>'#evaluate('attributes.manufact_code2_hizmet#j#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_code_2_hizmet#j#') and len(evaluate("attributes.product_code_2_hizmet#j#"))>'#evaluate('attributes.product_code_2_hizmet#j#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_unit_hizmet#j#') and len(evaluate("attributes.product_unit_hizmet#j#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit_hizmet#j#')#"><cfelse>NULL</cfif>,
                            #GET_SETUP_UNIT.UNIT_ID#,
                            <cfif isDefined('attributes.quantity_hizmet#j#') and len(evaluate("attributes.quantity_hizmet#j#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.quantity_hizmet#j#')#"><cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.money_hizmet#j#') and len(evaluate("attributes.money_hizmet#j#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.money_hizmet#j#')#"><cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_cost_hizmet#j#') and len(evaluate("attributes.product_cost_hizmet#j#"))>#evaluate('attributes.product_cost_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.discount_hizmet#j#') and len(evaluate("attributes.discount_hizmet#j#"))>#evaluate('attributes.discount_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.nettotal_cost_hizmet#j#') and len(evaluate("attributes.nettotal_cost_hizmet#j#"))>#evaluate('attributes.nettotal_cost_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.unit_cost_hizmet#j#') and len(evaluate("attributes.unit_cost_hizmet#j#"))>#evaluate('attributes.unit_cost_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.total_cost_hizmet#j#') and len(evaluate("attributes.total_cost_hizmet#j#"))>#evaluate('attributes.total_cost_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.unit_offer_hizmet#j#') and len(evaluate("attributes.unit_offer_hizmet#j#"))>#evaluate('attributes.unit_offer_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.total_offer_hizmet#j#') and len(evaluate("attributes.total_offer_hizmet#j#"))>#evaluate('attributes.total_offer_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.export_factor_hizmet#j#') and len(evaluate("attributes.export_factor_hizmet#j#"))>#evaluate('attributes.export_factor_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.offer_factor_hizmet#j#') and len(evaluate("attributes.offer_factor_hizmet#j#"))>#evaluate('attributes.offer_factor_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.profit_margin_hizmet#j#') and len(evaluate("attributes.profit_margin_hizmet#j#"))>#evaluate('attributes.profit_margin_hizmet#j#')#<cfelse>0</cfif>,
                            <cfif isDefined('attributes.is_alternative_hizmet#j#') and len(evaluate("attributes.is_alternative_hizmet#j#"))>#evaluate('attributes.is_alternative_hizmet#j#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.is_imported_hizmet#j#') and len(evaluate("attributes.is_imported_hizmet#j#"))>#evaluate('attributes.is_imported_hizmet#j#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.provision_time_hizmet#j#') and len(evaluate("attributes.provision_time_hizmet#j#"))>#evaluate('attributes.provision_time_hizmet#j#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.row_group_name_hizmet#j#') and len(evaluate("attributes.row_group_name_hizmet#j#"))>'#evaluate('attributes.row_group_name_hizmet#j#')#'<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.row_group_quantity_hizmet#j#') and len(evaluate("attributes.row_group_quantity_hizmet#j#"))>'#evaluate('attributes.row_group_quantity_hizmet#j#')#'<cfelse>1</cfif>,
                            <cfif isDefined('attributes.row_group_money_hizmet#i#') and len(evaluate("attributes.row_group_money_hizmet#i#"))>'#evaluate('attributes.row_group_money_hizmet#i#')#'<cfelse>NULL</cfif>,
                            #NOW()#,
                            #SESSION.EP.USERID#
                        )
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>

        <cfif isDefined("attributes.system_id") and len(attributes.system_id)>
            <cfquery name="UPD_PRODUCT_NAME" datasource="#DSN1#">
                UPDATE PRODUCT
                SET
                    PRODUCT_NAME = '#attributes.system_name#'
                WHERE 
                    PRODUCT_ID = #attributes.system_id#
            </cfquery>
        </cfif>

        <cfif attributes.process_stage eq 313> <!--- sadece kayıt aşamasında gruplar güncellenebilsin --->
            <cfquery name="DEL_OFFER_COST_ROW_GROUP" datasource="#DSN3#">
                DELETE FROM OFFER_COST_GROUP_PRODUCT WHERE OFFER_COST_ID = #attributes.offer_cost_id#;
            </cfquery>

            <cfquery name="GET_OFFER_COS_ROW_GROUP" datasource="#DSN3#">
                SELECT DISTINCT
                    ROW_GROUP_NAME,
                    ROW_GROUP_QUANTITY,
                    ROW_GROUP_MONEY
                FROM
                    OFFER_COST_ROW
                WHERE
                    OFFER_COST_ID = #attributes.offer_cost_id#
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
                            #attributes.offer_cost_id#,
                            <cfif len(GET_OFFER_COS_ROW_GROUP.ROW_GROUP_NAME)>'#GET_OFFER_COS_ROW_GROUP.ROW_GROUP_NAME#'<cfelse>NULL</cfif>,
                            <cfif len(GET_OFFER_COS_ROW_GROUP.ROW_GROUP_QUANTITY)>#GET_OFFER_COS_ROW_GROUP.ROW_GROUP_QUANTITY#<cfelse>1</cfif>,
                            '#GET_OFFER_COS_ROW_GROUP.ROW_GROUP_MONEY#'
                        )
                </cfquery>
            </cfloop>
        </cfif>
        
        <cfset page_type = 'list_offer_cost&event=upd'>
		<cfset page_name = 'Teklif Maliyet'>
        <cf_workcube_process 
            is_upd='1' 
		    data_source='#dsn3#'
            old_process_line='#attributes.old_process_line#'
            process_stage='#attributes.process_stage#' 
            record_member='#session.ep.userid#' 
            record_date='#now()#' 
            action_table='OFFER_COST'
            action_column='OFFER_COST_ID'
            action_id='#attributes.offer_cost_id#'
            action_page='#request.self#?fuseaction=#listgetat(attributes.fuseaction,1,'.')#.#page_type#&id=#attributes.offer_cost_id#' 
            warning_description='#page_name#: #attributes.offer_cost_id#'
            paper_no='#attributes.offer_cost_id#'>
        <script>
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
        </script>
<cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 0>
    <script>
        window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
    </script>
</cfif>