<cfinclude template="get_offer_cost_row.cfm">


<cfif isDefined("url.to_type") and url.to_type eq 1> <!--- TEklif MAliyet Kopylamak İçin --->
    <cfquery name="get_emp" datasource="#DSN3#">
        SELECT SALES_EMP FROM OFFER_COST WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>
    
    <cfquery name="get_dept_code" datasource="#DSN#">
        SELECT EP.POSITION_ID, D.SPECIAL_CODE2 
        FROM EMPLOYEE_POSITIONS AS EP
        LEFT JOIN DEPARTMENT AS D ON D.DEPARTMENT_ID=EP.DEPARTMENT_ID
        WHERE POSITION_ID = #session.ep.position_code#
    </cfquery>
    <cfquery name="get_offer_number" datasource="#DSN3#">
        SELECT
            OFFER_COST_NUMBER_ID,
            DEPT_SPECIAL_CODE AS OC_CODE,
            DEPT_OFFER_COST_NUMBER AS OC_NUMBER
        FROM OFFER_COST_NUMBER
        WHERE DEPT_SPECIAL_CODE = '#get_dept_code.SPECIAL_CODE2#'
    </cfquery>

    <cfquery name="upd_offer_cost_number" datasource="#DSN3#">
        UPDATE OFFER_COST_NUMBER
        SET DEPT_OFFER_COST_NUMBER = DEPT_OFFER_COST_NUMBER+1
        WHERE OFFER_COST_NUMBER_ID = #get_offer_number.OFFER_COST_NUMBER_ID#
    </cfquery>

	<cfquery name="ADD_COPY_OFFER_COST" datasource="#DSN3#">
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
                SALES_EMP
            )
        SELECT 
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
            SALES_EMP
        FROM 
            OFFER_COST
        WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>
    <cfquery name="GET_LAST_OFFER_COST" datasource="#DSN3#">
        SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
    </cfquery>

    <cfset last_offer_costid = GET_LAST_OFFER_COST.OFFER_COST_ID>

    <cfloop query="get_offer_cost_row">
        <cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
            SELECT
                UNIT_ID,
                UNIT
            FROM
                SETUP_UNIT
            WHERE
                UNIT = '#product_unit#'
        </cfquery>
        <cfquery name="INSERT_OFFER_COST_ROW_COPY" datasource="#DSN3#">
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
                #last_offer_costid#,
                <cfif len(product_id)>#product_id#<cfelse>NULL</cfif>,
                <cfif len(stock_id)>#stock_id#<cfelse>NULL</cfif>,
                <cfif len(product_name)>'#product_name#'<cfelse>NULL</cfif>,
                <cfif len(manufact_code)>'#manufact_code#'<cfelse>NULL</cfif>,
                <cfif len(product_code_2)>'#product_code_2#'<cfelse>NULL</cfif>,
                <cfif len(product_unit)>'#product_unit#'<cfelse>NULL</cfif>,
                #GET_SETUP_UNIT.UNIT_ID#,
                <cfif len(quantity)>#quantity#<cfelse>NULL</cfif>,
				<cfif len(money)>'#money#'<cfelse>NULL</cfif>,
				<cfif len(price_exwork)>#price_exwork#<cfelse>NULL</cfif>,
				<cfif len(discount)>#discount#<cfelse>NULL</cfif>,
				<cfif len(net_price_exwork)>#net_price_exwork#<cfelse>NULL</cfif>,
				<cfif len(unit_cost)>#unit_cost#<cfelse>NULL</cfif>,
				<cfif len(total_cost)>#total_cost#<cfelse>NULL</cfif>,
				<cfif len(unit_offer)>#unit_offer#<cfelse>NULL</cfif>,
				<cfif len(total_offer)>#total_offer#<cfelse>NULL</cfif>,
				<cfif len(export_factor)>#export_factor#<cfelse>NULL</cfif>,
				<cfif len(offer_factor)>#offer_factor#<cfelse>NULL</cfif>,
				<cfif len(profit_margin)>#profit_margin#<cfelse>NULL</cfif>,
				<cfif len(is_alternative)>#is_alternative#<cfelse>NULL</cfif>,
				<cfif len(is_imported)>#is_imported#<cfelse>NULL</cfif>,
				<cfif len(provision_time)>#provision_time#<cfelse>NULL</cfif>,
				<cfif len(row_group_name)>'#row_group_name#'<cfelse>NULL</cfif>,
				<cfif len(row_group_quantity)>#row_group_quantity#<cfelse>NULL</cfif>,
				<cfif len(row_group_money)>'#row_group_money#'<cfelse>NULL</cfif>,
                #NOW()#,
                #SESSION.EP.USERID#
            )
        </cfquery>
    </cfloop>

    <cfquery name="GET_OFFER_COST_GROUP_PRODUCT_MAIN" datasource="#DSN3#">
        SELECT
            *
        FROM
            OFFER_COST_GROUP_PRODUCT
        WHERE
            OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfoutput query="GET_OFFER_COST_GROUP_PRODUCT_MAIN">
        <cfquery name="ADD_OFFER_COST_GROUP_COPY" datasource="#DSN3#">
            INSERT INTO OFFER_COST_GROUP_PRODUCT
                (
                    OFFER_COST_ID,
                    OFFER_COST_GROUP,
                    PRODUCT_ID,
                    STOCK_ID,
                    GROUP_QUANTITY,
                    GROUP_MONEY
                )
            VALUES
                (  
                    #last_offer_costid#,
                    '#OFFER_COST_GROUP#',
                    <cfif len(PRODUCT_ID)>#PRODUCT_ID#<cfelse>NULL</cfif>,
                    <cfif len(STOCK_ID)>#STOCK_ID#<cfelse>NULL</cfif>,
                    <cfif len(GROUP_QUANTITY)>#GROUP_QUANTITY#<cfelse>NULL</cfif>,
                    <cfif len(GROUP_MONEY)>'#GROUP_MONEY#'<cfelse>NULL</cfif>
                )
        </cfquery>
    </cfoutput>


    <!---<cfquery name="get_dept_code" datasource="#DSN#">
        SELECT 
            EP.POSITION_ID,
            D.SPECIAL_CODE2
        FROM EMPLOYEE_POSITIONS AS EP
        LEFT JOIN DEPARTMENT AS D ON D.DEPARTMENT_ID=EP.DEPARTMENT_ID
        WHERE POSITION_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
    </cfquery>
    <cfquery name="get_last_cost_id" datasource="#DSN3#">
        SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
    </cfquery>
    <cfset new_cost_id=#get_last_cost_id.OFFER_COST_ID#+1>--->

    <cfquery name="UPD_COPY_OFFER_COST" datasource="#DSN3#">
        UPDATE
            OFFER_COST
        SET 
            OFFER_COST_HEAD = '#get_offer_number.OC_CODE#-#dateformat(now(),'yy')#-#numberFormat(get_offer_number.OC_NUMBER,'0000')#',
            MAIN_OFFER_COST_ID = #attributes.offer_cost_id#,
            OFFER_COST_VERSION = 0,
            OFFER_COST_STAGE = 313,
            RECORD_DATE = #now()#,
            RECORD_EMP = #SESSION.EP.USERID#,
            IS_TREE = 0
        WHERE
            OFFER_COST_ID = #get_last_offer_cost.offer_cost_id#
    </cfquery>
   
   
    
    <script>
        window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#get_last_offer_cost.offer_cost_id#</cfoutput>';
    </script>
</cfif>

<cfif isDefined("url.to_type") and url.to_type eq 2> <!--- TEklif MAliyet Revize İçin --->
    <cfquery name="get_emp" datasource="#DSN3#">
        SELECT SALES_EMP FROM OFFER_COST WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>
    <cfquery name="get_dept_code" datasource="#DSN#">
        SELECT EP.POSITION_ID, D.SPECIAL_CODE2 
        FROM EMPLOYEE_POSITIONS AS EP
        LEFT JOIN DEPARTMENT AS D ON D.DEPARTMENT_ID=EP.DEPARTMENT_ID
        WHERE POSITION_ID=#session.ep.position_code#
    </cfquery>
    <cfquery name="get_offer_number" datasource="#DSN3#">
        SELECT
            OFFER_COST_NUMBER_ID,
            DEPT_SPECIAL_CODE AS OC_CODE,
            DEPT_OFFER_COST_NUMBER AS OC_NUMBER
        FROM OFFER_COST_NUMBER
        WHERE DEPT_SPECIAL_CODE = '#get_dept_code.SPECIAL_CODE2#'
    </cfquery>
	<cfquery name="ADD_REVIZE_OFFER_COST" datasource="#DSN3#">
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
                SALES_EMP
            )
        SELECT 
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
            SALES_EMP
        FROM 
            OFFER_COST
        WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfquery name="GET_LAST_OFFER_COST" datasource="#DSN3#">
        SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
    </cfquery>

    <cfset last_offer_costid = GET_LAST_OFFER_COST.OFFER_COST_ID>

	<cfloop query="get_offer_cost_row">
        <cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
            SELECT
                UNIT_ID,
                UNIT
            FROM
                SETUP_UNIT
            WHERE
                UNIT = '#product_unit#'
        </cfquery>
        <cfquery name="INSERT_OFFER_COST_ROW_COPY" datasource="#DSN3#">
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
                #last_offer_costid#,
                <cfif len(product_id)>#product_id#<cfelse>NULL</cfif>,
                <cfif len(stock_id)>#stock_id#<cfelse>NULL</cfif>,
                <cfif len(product_name)>'#product_name#'<cfelse>NULL</cfif>,
                <cfif len(manufact_code)>'#manufact_code#'<cfelse>NULL</cfif>,
                <cfif len(product_code_2)>'#product_code_2#'<cfelse>NULL</cfif>,
                <cfif len(product_unit)>'#product_unit#'<cfelse>NULL</cfif>,
                #GET_SETUP_UNIT.UNIT_ID#,
                <cfif len(quantity)>#quantity#<cfelse>NULL</cfif>,
				<cfif len(money)>'#money#'<cfelse>NULL</cfif>,
				<cfif len(price_exwork)>#price_exwork#<cfelse>NULL</cfif>,
				<cfif len(discount)>#discount#<cfelse>NULL</cfif>,
				<cfif len(net_price_exwork)>#net_price_exwork#<cfelse>NULL</cfif>,
				<cfif len(unit_cost)>#unit_cost#<cfelse>NULL</cfif>,
				<cfif len(total_cost)>#total_cost#<cfelse>NULL</cfif>,
				<cfif len(unit_offer)>#unit_offer#<cfelse>NULL</cfif>,
				<cfif len(total_offer)>#total_offer#<cfelse>NULL</cfif>,
				<cfif len(export_factor)>#export_factor#<cfelse>NULL</cfif>,
				<cfif len(offer_factor)>#offer_factor#<cfelse>NULL</cfif>,
				<cfif len(profit_margin)>#profit_margin#<cfelse>NULL</cfif>,
				<cfif len(is_alternative)>#is_alternative#<cfelse>NULL</cfif>,
				<cfif len(is_imported)>#is_imported#<cfelse>NULL</cfif>,
				<cfif len(provision_time)>#provision_time#<cfelse>NULL</cfif>,
				<cfif len(row_group_name)>'#row_group_name#'<cfelse>NULL</cfif>,
				<cfif len(row_group_quantity)>#row_group_quantity#<cfelse>NULL</cfif>,
				<cfif len(row_group_money)>'#row_group_money#'<cfelse>NULL</cfif>,
                #NOW()#,
                #SESSION.EP.USERID#
            )
        </cfquery>
    </cfloop>

	<cfquery name="GET_OFFER_COST_GROUP_PRODUCT_MAIN" datasource="#DSN3#">
        SELECT
            *
        FROM
            OFFER_COST_GROUP_PRODUCT
        WHERE
            OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfoutput query="GET_OFFER_COST_GROUP_PRODUCT_MAIN">
        <cfquery name="ADD_OFFER_COST_GROUP_COPY" datasource="#DSN3#">
            INSERT INTO OFFER_COST_GROUP_PRODUCT
                (
                    OFFER_COST_ID,
                    OFFER_COST_GROUP,
                    PRODUCT_ID,
                    STOCK_ID,
                    GROUP_QUANTITY,
                    GROUP_MONEY
                )
            VALUES
                (  
                    #last_offer_costid#,
                    '#OFFER_COST_GROUP#',
                    <cfif len(PRODUCT_ID)>#PRODUCT_ID#<cfelse>NULL</cfif>,
                    <cfif len(STOCK_ID)>#STOCK_ID#<cfelse>NULL</cfif>,
                    <cfif len(GROUP_QUANTITY)>#GROUP_QUANTITY#<cfelse>NULL</cfif>,
                    <cfif len(GROUP_MONEY)>'#GROUP_MONEY#'<cfelse>NULL</cfif>
                )
        </cfquery>
    </cfoutput>

    <cfquery name="GET_MAIN_OFFER_COST_VERSION" datasource="#DSN3#">
        SELECT OFFER_COST_HEAD, OFFER_COST_VERSION FROM OFFER_COST WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfset new_offer_cost_version = get_main_offer_cost_version.offer_cost_version+1>

    <cfquery name="UPD_REVIZE_OFFER_COST" datasource="#DSN3#">
        UPDATE 
            OFFER_COST
        SET 
            OFFER_COST_HEAD = '#GET_MAIN_OFFER_COST_VERSION.OFFER_COST_HEAD#-#new_offer_cost_version#',
            MAIN_OFFER_COST_ID = #attributes.offer_cost_id#,
            OFFER_COST_VERSION = 0,
            OFFER_COST_STAGE = 313,
            RECORD_DATE = #now()#,
            RECORD_EMP = #SESSION.EP.USERID#,
            IS_TREE = 0
        WHERE
            OFFER_COST_ID = #get_last_offer_cost.offer_cost_id#
    </cfquery>

    <cfquery name="UPD_MASTER_OFFER_COST" datasource="#DSN3#">
        UPDATE 
            OFFER_COST
        SET 
            OFFER_COST_VERSION = #new_offer_cost_version#
        WHERE
            OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>
    <cfquery name="upd_offer_cost_number" datasource="#DSN3#">
        UPDATE OFFER_COST_NUMBER
        SET DEPT_OFFER_COST_NUMBER = DEPT_OFFER_COST_NUMBER+1
        WHERE OFFER_COST_NUMBER_ID = #get_offer_number.offer_cost_number_id#
    </cfquery>

    <script>
        window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#get_last_offer_cost.offer_cost_id#</cfoutput>';
    </script>
</cfif>