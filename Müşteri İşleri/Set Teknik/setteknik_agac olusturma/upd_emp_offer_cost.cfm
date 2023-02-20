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

    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 0>
    <script>
        window.history.back();
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
                OFFER_COST_DETAIL = <cfif isDefined("attributes.offer_cost_detail") and len(attributes.offer_cost_detail)>'#attributes.offer_cost_detail#'<cfelse>NULL</cfif>
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
                        <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
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
                        #NOW()#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
            </cfif>
        </cfloop>
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
    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 3> <!--- İç Talep Oluşturmak İçin --->
            <cfquery name="get_gen_paper" datasource="#dsn3#">
				SELECT PURCHASEDEMAND_NO, PURCHASEDEMAND_NUMBER FROM GENERAL_PAPERS WHERE PAPER_TYPE IS NULL
			</cfquery>
            <cfset paper_code = evaluate('get_gen_paper.PURCHASEDEMAND_NO')>
			<cfset paper_number = evaluate('get_gen_paper.PURCHASEDEMAND_NUMBER') +1>
			<cfset paper_full = '#paper_code#-#paper_number#'>
            <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
				UPDATE GENERAL_PAPERS SET PURCHASEDEMAND_NUMBER = PURCHASEDEMAND_NUMBER+1 WHERE PAPER_TYPE IS NULL
			</cfquery>
            <cfquery name="ADD_INTERNALDEMAND" datasource="#dsn3#" result="MAX_ID">
                INSERT INTO
                    INTERNALDEMAND
                    (
                        INTERNAL_NUMBER,
                        TO_POSITION_CODE,
                        SUBJECT,
                        FROM_POSITION_CODE,
                        TOTAL,
                        DISCOUNT,
                        TOTAL_TAX,
                        OTV_TOTAL,
                        NET_TOTAL,
                        PRIORITY,
                        INTERNALDEMAND_STATUS,
                        IS_ACTIVE,
                        PROJECT_ID,
                        INTERNALDEMAND_STAGE,
                        DEPARTMENT_IN,
                        LOCATION_IN,
                        DEPARTMENT_OUT,
                        LOCATION_OUT,
                        REF_NO,
                        SHIP_METHOD,
                        OTHER_MONEY,
                        OTHER_MONEY_VALUE,
                        DEMAND_TYPE,
                        RECORD_EMP,
                        RECORD_DATE,
                        DEPARTMENT_ID,
                        OFFER_COST_ID
                )
                    VALUES
                (
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#paper_full#">,
                        38,
                        'Satın Alma Talebi - TM - #attributes.offer_cost_id#',
                        #session.ep.position_code#,
                        10,
                        <cfif isdefined("attributes.BASKET_DISCOUNT_TOTAL") and len(attributes.BASKET_DISCOUNT_TOTAL)>#attributes.BASKET_DISCOUNT_TOTAL#<cfelse>0</cfif>,
                        0,0,0,
                        3, /* öncelik */ 
                        0, /* internaldemand_status */
                        1, /* aktif */
                        -1, /* PROJESİZ */ 
                        272, /* process_stage satınalma talebi aşaması id */
                        29, /* department_in id */
                        123456, /* location_in id */
                        29, /* department_out */
                        123456,
                        <cfif isdefined("attributes.offer_cost_id") and len(attributes.offer_cost_id)><cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.offer_cost_id#"><cfelse>NULL</cfif>,
                        11, /* ship_method */
                        'TL', /* basket_money */
                        10, /* basket_money_value */
                        1, /* demand_type */
                        #SESSION.EP.USERID#,
                        #now()#,
                        1,
                        #attributes.offer_cost_id#
                )
	    </cfquery>
        <cfloop index="i" from="0" to="#attributes.row_count#">
            <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>
                <cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
                    SELECT
                        UNIT_ID,
                        UNIT
                    FROM
                        SETUP_UNIT
                    WHERE
                        UNIT = '#evaluate("attributes.product_unit#i#")#'
                </cfquery>

                <cfquery name="ADD_INTERNALDEMAND_ROW" datasource="#DSN3#">
					INSERT INTO
						INTERNALDEMAND_ROW
						(
							I_ID,
							PRODUCT_ID,
							STOCK_ID,
							QUANTITY,
							UNIT,
							UNIT_ID,
							PRICE,
							PRICE_OTHER,
							OTHER_MONEY,
							OTHER_MONEY_VALUE,
							TAX,
							DUEDATE,
							PRODUCT_NAME,
							DISCOUNT_1,
							DISCOUNT_2,
							DISCOUNT_3,
							DISCOUNT_4,
							DISCOUNT_5,
							DISCOUNT_6,
							DISCOUNT_7,
							DISCOUNT_8,
							DISCOUNT_9,
							DISCOUNT_10,
							TAXTOTAL,
							NETTOTAL,
							OTV_ORAN,
							OTVTOTAL,
							COST_PRICE,
							EXTRA_COST,
							MARJ,
							PROM_COMISSION,
							PROM_COST,
							DISCOUNT_COST,
							PROM_ID,
							IS_PROMOTION,
							PROM_STOCK_ID,
							IS_COMMISSION,
							UNIQUE_RELATION_ID,
							PROM_RELATION_ID,
							AMOUNT2,
							UNIT2,
							EXTRA_PRICE,
							EK_TUTAR_PRICE,
							EXTRA_PRICE_TOTAL,
							EXTRA_PRICE_OTHER_TOTAL,
							SHELF_NUMBER,
							BASKET_EXTRA_INFO_ID,
							SELECT_INFO_EXTRA,
							DETAIL_INFO_EXTRA,
							PRICE_CAT,
							CATALOG_ID,
							LIST_PRICE,
							NUMBER_OF_INSTALLMENT,
							BASKET_EMPLOYEE_ID,
							KARMA_PRODUCT_ID,
							RESERVE_DATE,
							PRODUCT_NAME2,
							PRODUCT_MANUFACT_CODE,
							WRK_ROW_ID,
							WRK_ROW_RELATION_ID,
							PRO_MATERIAL_ID,
							WIDTH_VALUE,
							DEPTH_VALUE,
							HEIGHT_VALUE,
							ROW_PROJECT_ID,
	                        ROW_WORK_ID,
							PBS_ID,
							DELIVER_DEPT,
							DELIVER_LOCATION
							<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
							,SPECT_VAR_ID
							,SPECT_VAR_NAME
							</cfif>,
	                        LOT_NO
							<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,EXPENSE_CENTER_ID</cfif>
							<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,EXPENSE_ITEM_ID</cfif>
							<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,ACTIVITY_TYPE_ID</cfif>
							<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,ACC_CODE</cfif>
							<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,OIV_RATE </cfif>
							<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,OIV_AMOUNT</cfif>
						)
					VALUES
						(
							#MAX_ID.IDENTITYCOL#,
							#evaluate("attributes.product_id#i#")#,
							<cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
							<cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
                            <cfif isDefined('attributes.product_unit#i#') and len(evaluate("attributes.product_unit#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit#i#')#"><cfelse>NULL</cfif>,
                            #GET_SETUP_UNIT.UNIT_ID#,
							<cfif isdefined('attributes.product_cost#i#') and len(trim(evaluate('attributes.product_cost#i#')))>#evaluate("attributes.product_cost#i#")#,<cfelse>0,</cfif>
							<cfif isdefined('attributes.product_cost#i#') and len(evaluate("attributes.product_cost#i#")) and isNumeric(evaluate("attributes.product_cost#i#"))>#evaluate('attributes.product_cost#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.money#i#') and len(evaluate("attributes.money#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.money#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.product_cost#i#') and len(evaluate("attributes.product_cost#i#")) and isNumeric(evaluate("attributes.product_cost#i#"))>#evaluate('attributes.product_cost#i#')#<cfelse>NULL</cfif>,
							0,
							0, 
							<cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>'#evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.indirim1#i#')>#evaluate('attributes.indirim1#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim2#i#')>#evaluate('attributes.indirim2#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim3#i#')>#evaluate('attributes.indirim3#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim4#i#')>#evaluate('attributes.indirim4#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim5#i#')>#evaluate('attributes.indirim5#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim6#i#')>#evaluate('attributes.indirim6#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim7#i#')>#evaluate('attributes.indirim7#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim8#i#')>#evaluate('attributes.indirim8#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim9#i#')>#evaluate('attributes.indirim9#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.indirim10#i#')>#evaluate('attributes.indirim10#i#')#<cfelse>0</cfif>,
							0,
							<cfif isDefined('attributes.total_cost#i#') and len(evaluate("attributes.total_cost#i#"))>#evaluate('attributes.total_cost#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.otv_oran#i#') and len(evaluate('attributes.otv_oran#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.otv_oran#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_otvtotal#i#') and len(evaluate('attributes.row_otvtotal#i#'))>#evaluate('attributes.row_otvtotal#i#')#<cfelse>NULL</cfif>,
							<cfif isDefined('attributes.total_offer#i#') and len(evaluate("attributes.total_offer#i#"))>#evaluate('attributes.total_offer#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.extra_cost#i#') and len(evaluate('attributes.extra_cost#i#'))>#evaluate('attributes.extra_cost#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.marj#i#') and len(evaluate('attributes.marj#i#'))>#evaluate('attributes.marj#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.promosyon_yuzde#i#') and len(evaluate('attributes.promosyon_yuzde#i#'))>#evaluate('attributes.promosyon_yuzde#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.promosyon_maliyet#i#') and len(evaluate('attributes.promosyon_maliyet#i#'))>#evaluate('attributes.promosyon_maliyet#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.iskonto_tutar#i#') and len(evaluate('attributes.iskonto_tutar#i#'))>#evaluate('attributes.iskonto_tutar#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_promotion_id#i#') and len(evaluate('attributes.row_promotion_id#i#'))>#evaluate('attributes.row_promotion_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.is_promotion#i#') and len(evaluate('attributes.is_promotion#i#'))>#evaluate('attributes.is_promotion#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.prom_stock_id#i#') and len(evaluate('attributes.prom_stock_id#i#'))>#evaluate('attributes.prom_stock_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.is_commission#i#') and len(evaluate('attributes.is_commission#i#'))>#evaluate('attributes.is_commission#i#')#<cfelse>0</cfif>,
							<cfif isdefined('attributes.row_unique_relation_id#i#') and len(evaluate('attributes.row_unique_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.prom_relation_id#i#') and len(evaluate('attributes.prom_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.amount_other#i#') and len(evaluate('attributes.amount_other#i#'))>#evaluate('attributes.amount_other#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.unit_other#i#') and len(evaluate('attributes.unit_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.ek_tutar#i#') and len(evaluate('attributes.ek_tutar#i#'))>#evaluate('attributes.ek_tutar#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.ek_tutar_price#i#') and len(evaluate('attributes.ek_tutar_price#i#'))>#evaluate('attributes.ek_tutar_price#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.ek_tutar_total#i#') and len(evaluate('attributes.ek_tutar_total#i#'))>#evaluate('attributes.ek_tutar_total#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.ek_tutar_other_total#i#') and len(evaluate('attributes.ek_tutar_other_total#i#'))>#evaluate('attributes.ek_tutar_other_total#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.shelf_number#i#') and len(evaluate('attributes.shelf_number#i#'))>#evaluate('attributes.shelf_number#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.basket_extra_info#i#') and len(evaluate('attributes.basket_extra_info#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.select_info_extra#i#') and len(evaluate('attributes.select_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.detail_info_extra#i#') and len(evaluate('attributes.detail_info_extra#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.detail_info_extra#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.price_cat#i#') and len(evaluate('attributes.price_cat#i#'))>#evaluate('attributes.price_cat#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_catalog_id#i#') and len(evaluate('attributes.row_catalog_id#i#'))>#evaluate('attributes.row_catalog_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.list_price#i#') and len(evaluate('attributes.list_price#i#'))>#evaluate('attributes.list_price#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.number_of_installment#i#') and len(evaluate('attributes.number_of_installment#i#'))>#evaluate('attributes.number_of_installment#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.basket_employee_id#i#') and len(evaluate('attributes.basket_employee_id#i#')) and isdefined('attributes.basket_employee#i#') and len(evaluate('attributes.basket_employee#i#'))>#evaluate('attributes.basket_employee_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.karma_product_id#i#') and len(evaluate('attributes.karma_product_id#i#'))>#evaluate('attributes.karma_product_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined("attributes.reserve_date#i#") and isdate(evaluate('attributes.reserve_date#i#'))>#evaluate('attributes.reserve_date#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.product_name_other#i#') and len(evaluate('attributes.product_name_other#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_name_other#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.manufact_code#i#') and len(evaluate('attributes.manufact_code#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.manufact_code#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.wrk_row_id#i#') and len(evaluate('attributes.wrk_row_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined('attributes.wrk_row_relation_id#i#') and len(evaluate('attributes.wrk_row_relation_id#i#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#i#')#"><cfelse>NULL</cfif>,
							<cfif isdefined("attributes.row_ship_id#i#") and len(evaluate('attributes.row_ship_id#i#')) and evaluate('attributes.row_ship_id#i#') neq 0>#ListFirst(evaluate('attributes.row_ship_id#i#'),';')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_width#i#') and len(evaluate('attributes.row_width#i#'))>#evaluate('attributes.row_width#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_depth#i#') and len(evaluate('attributes.row_depth#i#'))>#evaluate('attributes.row_depth#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_height#i#') and len(evaluate('attributes.row_height#i#'))>#evaluate('attributes.row_height#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.row_project_id#i#') and len(evaluate('attributes.row_project_id#i#')) and isdefined('attributes.row_project_name#i#') and len(evaluate('attributes.row_project_name#i#'))>#evaluate('attributes.row_project_id#i#')#<cfelse>NULL</cfif>,
	                        <cfif isdefined('attributes.row_work_id#i#') and len(evaluate('attributes.row_work_id#i#')) and isdefined('attributes.row_work_name#i#') and len(evaluate('attributes.row_work_name#i#'))>#evaluate('attributes.row_work_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined('attributes.pbs_code#i#') and len(evaluate('attributes.pbs_code#i#')) and isdefined('attributes.pbs_id#i#') and len(evaluate('attributes.pbs_id#i#'))>#evaluate('attributes.pbs_id#i#')#<cfelse>NULL</cfif>,
							<cfif isdefined("attributes.deliver_dept#i#") and len(trim(evaluate("attributes.deliver_dept#i#"))) and len(listfirst(evaluate("attributes.deliver_dept#i#"),"-"))>
								#listfirst(evaluate("attributes.deliver_dept#i#"),"-")#,
							<cfelseif isdefined('attributes.department_in_id') and len(attributes.department_in_id)>
								#attributes.department_in_id#,
							<cfelse>
								NULL,
							</cfif>
							<cfif isdefined("attributes.deliver_dept#i#") and listlen(trim(evaluate("attributes.deliver_dept#i#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#i#"),"-"))>
								#listlast(evaluate("attributes.deliver_dept#i#"),"-")#
							<cfelseif isdefined('attributes.location_in_id') and len(attributes.location_in_id)>
								#attributes.location_in_id#
							<cfelse>
								NULL
							</cfif>
							<cfif isdefined('attributes.spect_id#i#') and len(evaluate('attributes.spect_id#i#'))>
								,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_id#i#')#">
								,<cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.spect_name#i#')#">
							</cfif>,
	                        <cfif isdefined('attributes.lot_no#i#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#i#')#"><cfelse>NULL</cfif>
							<cfif isdefined('attributes.row_exp_center_id#i#') and len(evaluate("attributes.row_exp_center_id#i#")) and isdefined('attributes.row_exp_center_name#i#') and len(evaluate("attributes.row_exp_center_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#i#')#"></cfif>
							<cfif isdefined('attributes.row_exp_item_id#i#') and len(evaluate("attributes.row_exp_item_id#i#")) and isdefined('attributes.row_exp_item_name#i#') and len(evaluate("attributes.row_exp_item_name#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#i#')#"></cfif>
							<cfif isdefined('attributes.row_activity_id#i#') and len(evaluate("attributes.row_activity_id#i#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#i#')#"></cfif>
							<cfif isdefined('attributes.row_acc_code#i#') and len(evaluate("attributes.row_acc_code#i#"))>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#i#')#"></cfif>
							<cfif isdefined('attributes.row_oiv_rate#i#') and len(evaluate("attributes.row_oiv_rate#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_rate#i#')#"></cfif>
							<cfif isdefined('attributes.row_oiv_amount#i#') and len(evaluate("attributes.row_oiv_amount#i#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_amount#i#')#"></cfif>
						)
				</cfquery>
            </cfif>
        </cfloop>
        <script>
            alert('Satınalma Talebi Oluşturuldu! Satınalma Talebi Nn : <cfoutput>#paper_full#</cfoutput>');
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
        </script>

    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 4> <!--- Ürün Ağacı Oluşturmak İçin --->

            <cfquery name="OFFER_COST_PRODUCT_CONTROL" datasource="#DSN3#">
                SELECT
                    PRODUCT_ID
                FROM
                    OFFER_COST
                WHERE
                    OFFER_COST_ID = #attributes.offer_cost_id#
            </cfquery>

        <cfif len(offer_cost_product_control.product_id)>
            <script>
                alert('Bu Teklif Maliyete Ait Ürün Ağacı Daha Önce Oluşturulmuştur!');
                window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
            </script>
            <cfabort>
        <cfelse>
            <cfquery name="GET_OFFER_COST_ROW" datasource="#DSN3#">
                SELECT
                    *
                FROM
                    OFFER_COST_ROW
                WHERE
                    OFFER_COST_ID = #attributes.offer_cost_id#
            </cfquery>

            <cfquery name="GET_MONEY_USD" datasource="#DSN#">
                SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'USD'
            </cfquery>

                <cfquery name="GET_MONEY_GBP" datasource="#DSN#">
                    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'GBP'
                </cfquery>

                <cfquery name="GET_MONEY_EUR" datasource="#DSN#">
                    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'EUR'
                </cfquery>

                <cfquery name="GET_MONEY" datasource="#DSN#">
                    SELECT * FROM SETUP_MONEY
                </cfquery>

                <cfscript>
                    usd_price = get_money_usd.rate2;
                    eur_price = get_money_eur.rate2;
                    gbp_price = get_money_gbp.rate2;
                </cfscript>

                <cfscript>
                    to_eur_group = 0;
                    to_eur = 0;
                    total_eur_group = 0;
                    total_eur = 0;
                    sum_total_eur_group = 0;
                    sum_total_eur = 0;

                    sum_to_eur_group = 0;
                    sum_to_eur = 0;
                </cfscript>

                <cfscript>
                    toplam_eur = 0;
                    total_offer_eur = 0;
                    total_offer_tl = 0;
                    toplam_eur_group = 0;
                    total_offer_eur_group = 0;
                    total_offer_tl_group = 0;
                </cfscript>

                <cfoutput query="GET_OFFER_COST_ROW">
                    <cfscript>
                        if(MONEY eq "TL"){
                                to_eur_group = TOTAL_OFFER/eur_price;
                            }
                            else if(MONEY eq "USD"){
                                to_tl_group = TOTAL_OFFER*usd_price;
                                to_eur_group = to_tl_group/eur_price;
                            }
                            else if(MONEY eq "EUR"){
                                to_eur_group = TOTAL_OFFER;
                            }
                                total_eur_group = total_eur_group+to_eur_group;
                    </cfscript>
                </cfoutput>

                <cfscript>
                    total_eur_group_kdv =  (total_eur_group*1.18);
                </cfscript>

                <cfquery name="GET_OTHER_PERIOD" datasource="#DSN3#">
                    SELECT PERIOD_ID FROM #dsn_alias#.SETUP_PERIOD WHERE OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.COMPANY_ID#">
                </cfquery>
                <cfquery name="GET_CODES" datasource="#DSN3#">
                    SELECT * FROM SETUP_PRODUCT_PERIOD_CAT WHERE PRO_CODE_CATID = 1
                </cfquery>
                <cfset bugun_00 = DateFormat(now(),dateformat_style)>
                <cf_date tarih='bugun_00'>
                <cfquery name="ADD_PRODUCT" datasource="#DSN1#">
                INSERT INTO
                    PRODUCT
                    (
                        PRODUCT_STATUS,                    
                        PRODUCT_CODE,
                        PRODUCT_CATID,
                        PRODUCT_NAME,
                        TAX,
                        TAX_PURCHASE,
                        IS_QUALITY,
                        IS_INVENTORY,
                        IS_PRODUCTION,
                        IS_COST,
                        IS_SALES,
                        IS_PURCHASE,
                        IS_PROTOTYPE,
                        IS_TERAZI,
                        IS_SERIAL_NO,
                        IS_ZERO_STOCK,
                        IS_KARMA,
                        IS_LIMITED_STOCK,
                        IS_LOT_NO,
                        BARCOD,
                        PRODUCT_DETAIL,
                        PRODUCT_DETAIL2,
                        COMPANY_ID,
                        BRAND_ID,
                        RECORD_DATE,
                        RECORD_MEMBER,
                        MEMBER_TYPE,
                        MANUFACT_CODE,
                        SHELF_LIFE,
                        SEGMENT_ID,
                        PRODUCT_MANAGER,
                        IS_INTERNET,
                        IS_EXTRANET,
                        PROD_COMPETITIVE,
                        PRODUCT_STAGE,
                        MIN_MARGIN,
                        MAX_MARGIN,
                        OTV,
                        PRODUCT_CODE_2,
                        SHORT_CODE,
                        SHORT_CODE_ID,
                        WORK_STOCK_ID,
                        WORK_STOCK_AMOUNT,
                        PACKAGE_CONTROL_TYPE,
                        IS_COMMISSION,
                        IS_GIFT_CARD,
                        GIFT_VALID_DAY,
                        CUSTOMS_RECIPE_CODE,
                        OIV,
                        BSMV,
                        IS_IMPORTED,
                        OFFER_COST_ID,
                        PROJECT_ID
                    )
                    VALUES
                    (
                        1,
                        'STD - #attributes.offer_cost_id#',
                        498,
                        'Ürün TM - #attributes.offer_cost_id#',
                        18,
                        18,
                        1,
                        1,
                        1,
                        1,
                        1,
                        0,
                        1,
                        0,
                        0,
                        0,
                        0,
                        0,
                        0,
                        NULL,
                        NULL,
                        NULL,
                        NULL,
                        57,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#NOW()#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.USERID#">,
                        'e-1',
                        NULL, /* MANUFACT_CODE */ 
                        NULL,
                        NULL, /* SEGMENT_ID */
                        NULL,
                        0,
                        0,
                        5,
                        29,        
                        0, /* MIN_MARGIN */
                        0, /* MAX_MARGIN */
                        NULL,
                        <cfif isDefined("attributes.offer_cost_head") and len(attributes.offer_cost_head)>'#attributes.offer_cost_head#'<cfelse>NULL</cfif>,
                        'Mod',
                        280,
                        NULL,
                        NULL,
                        NULL, /*PACKAGE_CONTROL_TYPE*/
                        0,
                        0,
                        0,				
                        NULL,
                        NULL, /* OIV */
                        NULL, /* BSMV*/
                        1,
                        #attributes.offer_cost_id#,
                        <cfif isDefined("attributes.related_project_id") and len(attributes.related_project_id)>#attributes.related_project_id#<cfelse>NULL</cfif>
                    )
                    SELECT @@IDENTITY AS MAX_PRODUCT_ID
                </cfquery>
                <cfquery name="GET_PID" datasource="#DSN3#">
                    SELECT MAX(PRODUCT_ID) AS PRODUCT_ID FROM #dsn1_alias#.PRODUCT
                </cfquery>
                <cfset pid = GET_PID.PRODUCT_ID>

                <cfif GET_CODES.recordcount and GET_OTHER_PERIOD.recordcount>
                    <cfloop list="#ValueList(GET_OTHER_PERIOD.PERIOD_ID)#" index="i">
                        <cfquery name="ADD_MAIN_UNIT" datasource="#DSN3#">
                            INSERT INTO
                                PRODUCT_PERIOD
                                (
                                    PRODUCT_ID,  
                                    PERIOD_ID,
                                    ACCOUNT_CODE,
                                    ACCOUNT_CODE_PUR,
                                    ACCOUNT_DISCOUNT,
                                    ACCOUNT_PRICE,
                                    ACCOUNT_PUR_IADE,
                                    ACCOUNT_IADE,
                                    ACCOUNT_DISCOUNT_PUR,
                                    ACCOUNT_YURTDISI,					
                                    ACCOUNT_YURTDISI_PUR,
                                    EXPENSE_CENTER_ID,
                                    EXPENSE_ITEM_ID,
                                    INCOME_ITEM_ID,
                                    EXPENSE_TEMPLATE_ID,
                                    ACTIVITY_TYPE_ID,
                                    COST_EXPENSE_CENTER_ID,
                                    INCOME_ACTIVITY_TYPE_ID,
                                    INCOME_TEMPLATE_ID,
                                    ACCOUNT_LOSS,
                                    ACCOUNT_EXPENDITURE,
                                    OVER_COUNT,
                                    UNDER_COUNT,
                                    PRODUCTION_COST,
                                    HALF_PRODUCTION_COST,
                                    SALE_PRODUCT_COST,
                                    MATERIAL_CODE,
                                    KONSINYE_PUR_CODE,
                                    KONSINYE_SALE_CODE,
                                    KONSINYE_SALE_NAZ_CODE,
                                    DIMM_CODE,
                                    DIMM_YANS_CODE,
                                    PROMOTION_CODE,
                                    PRODUCT_PERIOD_CAT_ID,
                                    ACCOUNT_PRICE_PUR,
                                    MATERIAL_CODE_SALE,
                                    PRODUCTION_COST_SALE,
                                    SALE_MANUFACTURED_COST,
                                    PROVIDED_PROGRESS_CODE,
                                    SCRAP_CODE_SALE,
                                    SCRAP_CODE,
                                    PROD_GENERAL_CODE,
                                    PROD_LABOR_COST_CODE,
                                    RECEIVED_PROGRESS_CODE,
                                    INVENTORY_CAT_ID,
                                    INVENTORY_CODE,
                                    AMORTIZATION_METHOD_ID,
                                    AMORTIZATION_TYPE_ID,
                                    AMORTIZATION_EXP_CENTER_ID,
                                    AMORTIZATION_EXP_ITEM_ID,
                                    AMORTIZATION_CODE
                                )
                                VALUES 
                                (
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_PID.PRODUCT_ID#">,
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">,
                                    <cfif len(GET_CODES.ACCOUNT_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_CODE_PUR)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_CODE_PUR#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_DISCOUNT)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_DISCOUNT#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_PRICE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_PRICE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_PUR_IADE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_PUR_IADE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_IADE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_IADE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_DISCOUNT_PUR)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_DISCOUNT_PUR#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_YURTDISI)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_YURTDISI#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_YURTDISI_PUR)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_YURTDISI_PUR#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INC_CENTER_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.INC_CENTER_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.EXP_ITEM_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.EXP_ITEM_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INC_ITEM_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.INC_ITEM_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.EXP_TEMPLATE_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.EXP_TEMPLATE_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.EXP_ACTIVITY_TYPE_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.EXP_ACTIVITY_TYPE_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.EXP_CENTER_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.EXP_CENTER_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INC_ACTIVITY_TYPE_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.INC_ACTIVITY_TYPE_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INC_TEMPLATE_ID)><cfqueryparam cfsqltype="cf_sql_integer" value="#GET_CODES.INC_TEMPLATE_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_LOSS)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_LOSS#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.ACCOUNT_EXPENDITURE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_EXPENDITURE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.OVER_COUNT)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.OVER_COUNT#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.UNDER_COUNT)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.UNDER_COUNT#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PRODUCTION_COST)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PRODUCTION_COST#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.HALF_PRODUCTION_COST)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.HALF_PRODUCTION_COST#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.SALE_PRODUCT_COST)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.SALE_PRODUCT_COST#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.MATERIAL_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.MATERIAL_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.KONSINYE_PUR_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.KONSINYE_PUR_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.KONSINYE_SALE_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.KONSINYE_SALE_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.KONSINYE_SALE_NAZ_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.KONSINYE_SALE_NAZ_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.DIMM_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.DIMM_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.DIMM_YANS_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.DIMM_YANS_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PROMOTION_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PROMOTION_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    1 /* PRODUCT_PERIOD_CAT_ID */,
                                    <cfif len(GET_CODES.ACCOUNT_PRICE_PUR)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.ACCOUNT_PRICE_PUR#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.MATERIAL_CODE_SALE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.MATERIAL_CODE_SALE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PRODUCTION_COST_SALE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PRODUCTION_COST_SALE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.SALE_MANUFACTURED_COST)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.SALE_MANUFACTURED_COST#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PROVIDED_PROGRESS_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PROVIDED_PROGRESS_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.SCRAP_CODE_SALE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.SCRAP_CODE_SALE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.SCRAP_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.SCRAP_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PROD_GENERAL_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PROD_GENERAL_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.PROD_LABOR_COST_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.PROD_LABOR_COST_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.RECEIVED_PROGRESS_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.RECEIVED_PROGRESS_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INVENTORY_CAT_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.INVENTORY_CAT_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.INVENTORY_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.INVENTORY_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.AMORTIZATION_METHOD_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.AMORTIZATION_METHOD_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.AMORTIZATION_TYPE_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.AMORTIZATION_TYPE_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.AMORTIZATION_EXP_CENTER_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.AMORTIZATION_EXP_CENTER_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.AMORTIZATION_EXP_ITEM_ID)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.AMORTIZATION_EXP_ITEM_ID#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>,
                                    <cfif len(GET_CODES.AMORTIZATION_CODE)><cfqueryparam cfsqltype="cf_sql_varchar" value="#GET_CODES.AMORTIZATION_CODE#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="" null="yes"></cfif>
                                )
                        </cfquery>
                    </cfloop>
                </cfif>
                <cfquery name="ADD_MAIN_UNIT" datasource="#DSN3#">
                    INSERT INTO
                        #dsn1_alias#.PRODUCT_UNIT 
                    (
                        PRODUCT_ID, 
                        PRODUCT_UNIT_STATUS, 
                        MAIN_UNIT_ID, 
                        MAIN_UNIT, 
                        UNIT_ID, 
                        ADD_UNIT,
                        DIMENTION,
                        WEIGHT,
                        VOLUME,
                        IS_MAIN,
                        IS_SHIP_UNIT,
                        RECORD_EMP,
                        RECORD_DATE
                    )
                    VALUES 
                    (
                        #GET_PID.PRODUCT_ID#,
                        1,
                        1,
                        'Adet',
                        1,
                        'Adet',
                        NULL,
                        NULL,
                        NULL,
                        1,
                        1,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                    )				
                </cfquery>
                <cfquery name="GET_MAX_UNIT" datasource="#DSN3#">
                    SELECT MAX(PRODUCT_UNIT_ID) AS MAX_UNIT FROM #dsn1_alias#.PRODUCT_UNIT
                </cfquery>
                <!---
                <cfquery name="GROUP_SUM" datasource="#DSN3#">
                    SELECT
                        PC.PRODUCT_CATID AS CAT_ID,
                        SUM(PRICE_EXWORK) AS GROUP_PRICE_EXWORK
                    FROM
                        OFFER_COST_ROW OCR
                        LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
                        LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
                    WHERE
                        OCR.OFFER_COST_ID = #attributes.offer_cost_id#
                    GROUP BY
                        PC.PRODUCT_CATID
                </cfquery>
                <cfscript>
                    purchase_kdvsiz = GROUP_SUM.GROUP_PRICE_EXWORK;
                    purchase_kdvli = (purchase_kdvsiz*1.18);
                    purchase_is_tax_included = 0;
                </cfscript>
                --->
                <!--- purchasesales is 0 / alış fiyatı --->
                <!---
                <script>
                    alert('<cfoutput>#total_eur_group#</cfoutput>');
                </script>
                --->
            <cfquery name="ADD_STD_PRICE" datasource="#DSN3#">
                INSERT INTO
                    #dsn1_alias#.PRICE_STANDART
                (
                    PRODUCT_ID, 
                    PURCHASESALES, 
                    PRICE, 
                    PRICE_KDV,
                    IS_KDV,
                    ROUNDING,
                    MONEY,
                    START_DATE,
                    RECORD_DATE,
                    PRICESTANDART_STATUS,
                    UNIT_ID,
                    RECORD_EMP
                )
                VALUES
                (
                    #GET_PID.PRODUCT_ID#,
                    0,
                    #total_eur_group#,
                    #total_eur_group_kdv#,
                    0,
                    0,
                    'EUR',
                    #bugun_00#,
                    #NOW()#,
                    1,
                    #GET_MAX_UNIT.MAX_UNIT#,
                    #SESSION.EP.USERID#
                )
            </cfquery>
            <!--- purchasesales is 1 / satış fiyatı --->
            <cfquery name="ADD_STD_PRICE" datasource="#DSN3#">
                INSERT INTO 
                    #dsn1_alias#.PRICE_STANDART
                (
                    PRODUCT_ID, 
                    PURCHASESALES, 
                    PRICE, 
                    PRICE_KDV,
                    IS_KDV,
                    ROUNDING,
                    MONEY,
                    START_DATE,
                    RECORD_DATE,
                    PRICESTANDART_STATUS,
                    UNIT_ID,
                    RECORD_EMP
                )
                VALUES
                (
                    #GET_PID.PRODUCT_ID#,
                    1,
                    0,
                    0,
                    0, <!---IS_KDV--->
                    0,
                    'EUR',
                    #bugun_00#,
                    #NOW()#,
                    1,
                    #GET_MAX_UNIT.MAX_UNIT#,
                    #SESSION.EP.USERID#
                )
            </cfquery>
            <cfquery name="ADD_STOCKS" datasource="#DSN3#">
                INSERT INTO
                    #dsn1_alias#.STOCKS
                (
                    STOCK_CODE,
                    STOCK_CODE_2,
                    BARCOD,
                    PRODUCT_ID,
                    PROPERTY,	
                    PRODUCT_UNIT_ID,
                    STOCK_STATUS,
                    MANUFACT_CODE,
                    RECORD_EMP, 
                    RECORD_IP,
                    RECORD_DATE
                )
                VALUES
                (
                    'STD - #attributes.offer_cost_id#',
                    '', <!--- STOCK_CODE_2 --->
                    '', <!--- BARCODE --->
                    #GET_PID.PRODUCT_ID#,
                    '', <!--- property degeri null oldugunda raporlar, urun agacı gibi bir cok ekranda property le beraber cekilen urun isminde sorun oluyordu ---><!--- '-',  boş olarak eklenmesi terch edildi--->
                    #GET_MAX_UNIT.MAX_UNIT#,
                    1,
                    '',
                    #session.ep.userid#,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_addr#">,
                    #now()#
                )
            </cfquery>
            <cfquery name="GET_MAX_STCK" datasource="#DSN1#">
                SELECT 
                        MAX(STOCK_ID) AS MAX_STCK, 
                        MAX(PRODUCT_UNIT_ID) AS MAX_UNIT_ID 
                FROM STOCKS
            </cfquery>
            <cfquery name="ADD_STOCK_BARCODE" datasource="#DSN1#">
                INSERT INTO
                    STOCKS_BARCODES
                (
                    STOCK_ID,
                    BARCODE,
                    UNIT_ID
                )
                VALUES 
                (
                    #GET_MAX_STCK.MAX_STCK#,
                    '',
                    #GET_MAX_STCK.MAX_UNIT_ID#
                )
            </cfquery>
            <cfquery name="ADD_PRODUCT_OUR_COMPANY_ID" datasource="#DSN3#">
                INSERT INTO 
                    #dsn1_alias#.PRODUCT_OUR_COMPANY
                    (
                        PRODUCT_ID,
                        OUR_COMPANY_ID
                    )
                    VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pid.product_id#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">
                    )
            </cfquery>
            <cfquery name="add_product_branch_id" datasource="#DSN3#">
                INSERT INTO
                    #dsn1_alias#.PRODUCT_BRANCH
                (
                    PRODUCT_ID,
                    BRANCH_ID,
                    RECORD_EMP, 
                    RECORD_IP,
                    RECORD_DATE
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#get_pid.product_id#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#listgetat(session.ep.user_location,2,'-')#">,
                    #session.ep.userid#,
                    <cfqueryparam cfsqltype="cf_sql_varchar" value="#remote_addr#">,
                    #now()#				
                )
            </cfquery>
            <cfquery name="get_my_periods" datasource="#DSN3#">
                SELECT * FROM #dsn_alias#.SETUP_PERIOD WHERE OUR_COMPANY_ID = #SESSION.EP.COMPANY_ID#
            </cfquery>
            <cfloop query="get_my_periods">
                <cfif database_type is "MSSQL">
                    <cfset temp_dsn = "#DSN#_#PERIOD_YEAR#_#SESSION.EP.COMPANY_ID#">
                <cfelseif database_type is "DB2">
                    <cfset temp_dsn = "#dsn#_#SESSION.EP.COMPANY_ID#_#right(period_year,2)#">
                </cfif>
                <cfquery name="INSRT_STK_ROW" datasource="#DSN3#">
                    INSERT INTO #temp_dsn#.STOCKS_ROW 
                        (
                            STOCK_ID,
                            PRODUCT_ID
                        )
                    VALUES 
                        (
                            #GET_MAX_STCK.MAX_STCK#,
                            #GET_PID.PRODUCT_ID#
                        )
                </cfquery>
            </cfloop>
            <cfquery name="ADD_STK_STRATEGY" datasource="#DSN3#">
                INSERT INTO
                    STOCK_STRATEGY 
                (
                    PRODUCT_ID,
                    STOCK_ID,
                    MINIMUM_ORDER_UNIT_ID,
                    STRATEGY_TYPE,
                    IS_LIVE_ORDER
                    
                )
                VALUES
                (
                    #GET_PID.PRODUCT_ID#,
                    #GET_MAX_STCK.MAX_STCK#,
                    #GET_MAX_UNIT.MAX_UNIT#,
                    1,
                    0
                )
            </cfquery>

            <cfquery name="UPD_OFFER_COST_PRODUCT" datasource="#DSN3#">
                UPDATE 
                    OFFER_COST
                SET 
                    PRODUCT_ID = #GET_PID.PRODUCT_ID#,
                    STOCK_ID = #GET_MAX_STCK.MAX_STCK#
                WHERE 
                    OFFER_COST_ID = #attributes.offer_cost_id#;
            </cfquery>

            <cfloop index="i" from="1" to="#attributes.row_count#">
                <cfif evaluate('attributes.row_group_name#i#') neq 'Hizmet'>
                    <cfquery name="GET_UNIT_ID" datasource="#DSN1#">
                        SELECT
                            PRODUCT_UNIT_ID
                        FROM
                            PRODUCT_UNIT
                        WHERE
                            PRODUCT_ID = #evaluate('attributes.product_id#i#')#
                    </cfquery>
                    <cfquery name="get_info_plus" datasource="#DSN3#">
                        SELECT
                            PROPERTY1
                        FROM PRODUCT_INFO_PLUS
                        WHERE PRO_INFO_ID = 2 AND PRODUCT_ID = #evaluate('attributes.product_id#i#')#
                    </cfquery>
                    <!--- add_sub query'sine tree type eklendi ürün kartındaki bilgiden çekerek bileşen tipini basıyor -Kerem Ümit Üçler 271022--->
                    <cfquery name="add_sub" datasource="#DSN3#">
                        INSERT INTO
                            PRODUCT_TREE
                            (
                                STOCK_ID,
                                RELATED_ID,
                                PRODUCT_ID,
                                IS_TREE,
                                AMOUNT,
                                UNIT_ID,
                                IS_CONFIGURE,
                                IS_SEVK,
                                IS_PHANTOM,
                                PROCESS_STAGE,
                                IS_FREE_AMOUNT,
                                RECORD_EMP,
                                RECORD_DATE,
                                TREE_TYPE
                            )
                            VALUES
                            (
                                    #GET_MAX_STCK.MAX_STCK#, <!--- ürün ağacının bağlanacağı ürünün stock_id si --->
                                    <cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,<!--- teklif maliyetteki satırlardaki ürünlerin stock id leri --->
                                    <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,<!--- teklif maliyetteki satırlardaki ürünlerin product id leri --->
                                    1,
                                    <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
                                    #GET_UNIT_ID.PRODUCT_UNIT_ID#, <!--- teklif maliyetteki satırlardaki ürünlerin unit id (PRODUCT_UNIT tablasundaki PRODUCT_UNIT_ID) leri --->
                                    0,
                                    1,
                                    0,
                                    253, <!--- process_stage --->
                                    0,                    
                                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                                    <cfif get_info_plus.recordCount><cfif get_info_plus.PROPERTY1 eq 'Garantili'>2<cfelseif get_info_plus.PROPERTY1 eq 'Garantisiz'>1</cfif><cfelse>NULL</cfif>
                            )
                    </cfquery>
                </cfif>
            </cfloop>

            <cfset wrk_id = "#dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmss')#_#session.ep.userid#_#Evaluate('GET_MAX_STCK.MAX_STCK')#_#round(rand()*100)#_2">
            
            <cfquery name="ADD_SPECT_MAIN" datasource="#DSN3#">
                INSERT INTO 
                    SPECT_MAIN
                    (
                        WRK_ID,
                        SPECT_MAIN_NAME,
                        SPECT_TYPE,
                        PRODUCT_ID,
                        STOCK_ID,
                        IS_TREE,
                        SPECT_STATUS,
                        FUSEACTION,
                        IS_LIMITED_STOCK,
                        RECORD_EMP,
                        RECORD_IP,
                        RECORD_DATE,
                        IS_MIX_PRODUCT
                    )
                    VALUES
                    (
                        '#wrk_id#',
                        'Ürün TM - #attributes.offer_cost_id#',
                        1, <!--- SPECT_TYPE --->
                        #GET_PID.PRODUCT_ID#,
                        #GET_MAX_STCK.MAX_STCK#,
                        1,
                        1,
                        'objects.emptypopup_add_spect_main_versiyon',
                        0,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
                        #NOW()#,
                        0
                    )
            </cfquery>
            <cfset urun_adi='Ürün Adı: Ürün TM - #attributes.offer_cost_id#'>
            <cfquery name="GET_SPECT_MAIN_ID" datasource="#DSN3#">
                SELECT MAX(SPECT_MAIN_ID) AS SPECT_MAIN_ID_ FROM SPECT_MAIN
            </cfquery>

            <cfquery name="GET_PRODUCT_TREE" datasource="#DSN3#">
                SELECT
                    *           
                FROM
                    PRODUCT_TREE
                WHERE
                    STOCK_ID = #GET_MAX_STCK.MAX_STCK#
            </cfquery>

            <cfloop query="#GET_PRODUCT_TREE#">
                
                <cfquery name="GET_TREE_PRODUCT" datasource="#DSN1#">
                    SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = #GET_PRODUCT_TREE.PRODUCT_ID#
                </cfquery>
                
                <cfquery name="ADD_SPECT_MAIN_ROW" datasource="#DSN3#">
                    INSERT INTO
                        SPECT_MAIN_ROW
                        (
                            SPECT_MAIN_ID,
                            PRODUCT_ID,
                            STOCK_ID,
                            AMOUNT,
                            PRODUCT_NAME,
                            IS_PROPERTY,
                            IS_CONFIGURE,
                            IS_SEVK,
                            LINE_NUMBER,
                            RELATED_TREE_ID,
                            QUESTION_ID,
                            IS_FREE_AMOUNT,
                            FIRE_AMOUNT,
                            FIRE_RATE
                        )
                        VALUES
                        (
                            #GET_SPECT_MAIN_ID.SPECT_MAIN_ID_#,
                            #GET_PRODUCT_TREE.PRODUCT_ID#,
                            #GET_PRODUCT_TREE.RELATED_ID#,
                            #GET_PRODUCT_TREE.AMOUNT#,
                            '#GET_TREE_PRODUCT.PRODUCT_NAME#',
                            0,
                            0,
                            1,
                            0,
                            #GET_PRODUCT_TREE.PRODUCT_TREE_ID#,
                            0,
                            0,
                            0,
                            0
                        )
                </cfquery>
            </cfloop>

            <script>
                alert('Ürün Ağacı Oluşturuldu ! <cfoutput>#urun_adi#</cfoutput>');
                window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
            </script>
        </cfif>
    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 5> <!--- Teklif Maliyet Revize İçin --->
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
                    OFFER_COST_VERSION
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
                OFFER_COST_VERSION
            FROM 
                OFFER_COST
            WHERE OFFER_COST_ID = #attributes.offer_cost_id#
        </cfquery>

        <cfquery name="GET_LAST_OFFER_COST" datasource="#DSN3#">
            SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
        </cfquery>

        <cfset last_offer_costid = GET_LAST_OFFER_COST.OFFER_COST_ID>

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

                <cfquery name="INSERT_OFFER_COST_ROW_REVIZE" datasource="#DSN3#">
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
                        RECORD_DATE,
                        RECORD_EMP
                    )
                    VALUES
                    (
                        #last_offer_costid#,
                        <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>'#evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.manufact_code2#i#') and len(evaluate("attributes.manufact_code2#i#"))>'#evaluate('attributes.manufact_code2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_code_2#i#') and len(evaluate("attributes.product_code_2#i#"))>'#evaluate('attributes.product_code_2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_unit#i#') and len(evaluate("attributes.product_unit#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit#i#')#"><cfelse>NULL</cfif>,
                        #GET_SETUP_UNIT.UNIT_ID#,
                        <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
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
                        #NOW()#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
            </cfif>
        </cfloop>

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
                OFFER_COST_VERSION = 0
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

        <script>
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#get_last_offer_cost.offer_cost_id#</cfoutput>';
        </script>
    <cfelseif isDefined("attributes.is_submit_form") and attributes.is_submit_form eq 6> <!--- Teklif Maliyet Kopyalama İçin --->
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
                    OFFER_COST_VERSION
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
                OFFER_COST_VERSION
            FROM 
                OFFER_COST
            WHERE OFFER_COST_ID = #attributes.offer_cost_id#
        </cfquery>

        <cfquery name="GET_LAST_OFFER_COST" datasource="#DSN3#">
            SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
        </cfquery>

        <cfset last_offer_costid = GET_LAST_OFFER_COST.OFFER_COST_ID>

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
                        RECORD_DATE,
                        RECORD_EMP
                    )
                    VALUES
                    (
                        #last_offer_costid#,
                        <cfif isDefined('attributes.product_id#i#') and len(evaluate("attributes.product_id#i#"))>#evaluate('attributes.product_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.stock_id#i#') and len(evaluate("attributes.stock_id#i#"))>#evaluate('attributes.stock_id#i#')#<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_name#i#') and len(evaluate("attributes.product_name#i#"))>'#evaluate('attributes.product_name#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.manufact_code2#i#') and len(evaluate("attributes.manufact_code2#i#"))>'#evaluate('attributes.manufact_code2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_code_2#i#') and len(evaluate("attributes.product_code_2#i#"))>'#evaluate('attributes.product_code_2#i#')#'<cfelse>NULL</cfif>,
                        <cfif isDefined('attributes.product_unit#i#') and len(evaluate("attributes.product_unit#i#"))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.product_unit#i#')#"><cfelse>NULL</cfif>,
                        #GET_SETUP_UNIT.UNIT_ID#,
                        <cfif isDefined('attributes.quantity#i#') and len(evaluate("attributes.quantity#i#"))>#evaluate('attributes.quantity#i#')#<cfelse>NULL</cfif>,
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
                        #NOW()#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
            </cfif>
        </cfloop>

        <cfquery name="get_dept_code" datasource="#DSN#">
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
        <cfset new_cost_id=#get_last_cost_id.OFFER_COST_ID#+1>

        <cfquery name="UPD_COPY_OFFER_COST" datasource="#DSN3#">
            UPDATE 
                OFFER_COST
            SET 
                OFFER_COST_HEAD = '#get_dept_code.SPECIAL_CODE2#-#dateformat(now(),'yy')#-#new_cost_id#',
                MAIN_OFFER_COST_ID = #attributes.offer_cost_id#,
                OFFER_COST_VERSION = 0,
                OFFER_COST_STAGE = 313
            WHERE
                OFFER_COST_ID = #get_last_offer_cost.offer_cost_id#
        </cfquery>

        <script>
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#get_last_offer_cost.offer_cost_id#</cfoutput>';
        </script>
</cfif>