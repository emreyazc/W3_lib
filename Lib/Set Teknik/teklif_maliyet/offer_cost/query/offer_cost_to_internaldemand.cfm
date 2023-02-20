        <cftry>
            
            <cfinclude template="get_money.cfm">
            <cfscript>
                usd_price = get_money_usd.rate2;
                eur_price = get_money_eur.rate2;
                gbp_price = get_money_gbp.rate2;
                parite = usd_price/eur_price;
            </cfscript>

            <cfscript>
                to_eur_group = 0;
                total_eur_group_offer = 0;
                total_eur_group_cost = 0;
            </cfscript>            
            <cfquery name="get_offer_cost_row_only_product" datasource="#DSN3#">
                SELECT
                    OCR.PRODUCT_ID,
                    OCR.STOCK_ID,
                    OCR.PRICE_EXWORK,
                    OCR.UNIT_OFFER,
                    OCR.DISCOUNT,
                    OCR.MONEY,
                    OCR.PRODUCT_NAME,
                    OCR.ROW_GROUP_NAME,
                    OCR.QUANTITY,
                    OCR.PRODUCT_UNIT AS MAIN_UNIT,
                    OCR.PRODUCT_UNIT_ID AS MAIN_UNIT_ID,
                    OCR.MANUFACT_CODE
                FROM
                    OFFER_COST_ROW OCR
                WHERE
                    OCR.OFFER_COST_ID = #attributes.offer_cost_id#
                    AND
                    OCR.IS_ALTERNATIVE <> 2
                    AND
                    OCR.IS_ALTERNATIVE <> 3
                    AND
                    (ROW_GROUP_NAME <> 'Hizmet' OR ROW_GROUP_NAME IS NULL)
            </cfquery>

            <cfoutput query="get_offer_cost_row_only_product">
                <cfscript>
                    if(MONEY eq "TL"){
                        yari_mamul_tl_price = price_exwork;
                        yari_mamul_doviz_price = (price_exwork/eur_price)*QUANTITY;
                    }
                    else if(MONEY eq "USD"){
                        yari_mamul_tl_price = price_exwork*usd_price;
                        yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
                    }
                    else if(MONEY eq "GBP"){
                        yari_mamul_tl_price = price_exwork*gbp_price;
                        yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
                    }
                    else if(MONEY eq "EUR"){
                        yari_mamul_doviz_price = (price_exwork*QUANTITY);
                        yari_mamul_tl_price = yari_mamul_doviz_price*eur_price;
                    }
                        total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
                        total_tl_group_offer = total_eur_group_offer*eur_price;
                        total_tax = total_tl_group_offer*1.18; 
                </cfscript>
            </cfoutput> 
            
            <cfquery name="get_gen_paper" datasource="#dsn3#">
				SELECT PURCHASEDEMAND_NO, PURCHASEDEMAND_NUMBER FROM GENERAL_PAPERS WHERE PAPER_TYPE IS NULL
			</cfquery>
            <cfset paper_code = evaluate('get_gen_paper.PURCHASEDEMAND_NO')>
			<cfset paper_number = evaluate('get_gen_paper.PURCHASEDEMAND_NUMBER') +1>
			<cfset paper_full = '#paper_code#-#paper_number#'>
            <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
				UPDATE GENERAL_PAPERS SET PURCHASEDEMAND_NUMBER = PURCHASEDEMAND_NUMBER+1 WHERE PAPER_TYPE IS NULL
			</cfquery>
            <cfquery name="get_offer_cost_det" datasource="#DSN3#">
                SELECT OFFER_COST_HEAD,SALES_EMP FROM OFFER_COST WHERE OFFER_COST_ID = #attributes.offer_cost_id#
            </cfquery>
            <cfquery name="get_offer_cost_company" datasource="#DSN3#">
                SELECT C.FULLNAME FROM OFFER_COST AS OC LEFT JOIN #DSN#.COMPANY AS C ON C.COMPANY_ID=OC.COMPANY_ID WHERE OC.OFFER_COST_ID = #attributes.offer_cost_id#
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
                        108,
                        '#get_offer_cost_det.OFFER_COST_HEAD#-SATINALMA TALEBİ',
                        <cfif isDefined(get_offer_cost_det.SALES_EMP) and len(#get_offer_cost_det.SALES_EMP#)>#get_offer_cost_det.SALES_EMP#<cfelse>NULL</cfif>,
                        #total_tl_group_offer#,
                        <cfif isdefined("attributes.BASKET_DISCOUNT_TOTAL") and len(attributes.BASKET_DISCOUNT_TOTAL)>#attributes.BASKET_DISCOUNT_TOTAL#<cfelse>0</cfif>,
                        #total_tax#,
                        0,
                        0,
                        3, /* öncelik */ 
                        0, /* internaldemand_status */
                        1, /* aktif */
                        -1, /* PROJESİZ */ 
                        412, /* process_stage satınalma talebi aşaması id */
                        29, /* department_in id */
                        123456, /* location_in id */
                        29, /* department_out */
                        123456,
                        '#get_offer_cost_det.OFFER_COST_HEAD#',
                        11, /* ship_method */
                        'TL', /* basket_money */
                        #total_eur_group_offer#, /* basket_money_value */
                        1, /* demand_type */
                        #SESSION.EP.USERID#,
                        #now()#,
                        1,
                        #attributes.offer_cost_id#
                    )
	        </cfquery>
            <cfquery name="get_max_id" datasource="#DSN3#">
                SELECT MAX(INTERNAL_ID) AS MAX_ID FROM INTERNALDEMAND
            </cfquery>

        <cfloop query="get_offer_cost_row_only_product">
            <cfscript>
                if(MONEY eq "TL"){
                    yari_mamul_tl_price = unit_offer;
                    kdv_tax = (yari_mamul_tl_price*1.18);
                    yari_mamul_doviz_price = (unit_offer/eur_price)*QUANTITY;
                    yari_mamul_tl_list_price = price_exwork;
                    if(yari_mamul_tl_price neq 0)
                    {
                        yari_mamul_tl_price_kdv = (yari_mamul_tl_price*18/100);
                    }else yari_mamul_tl_price_kdv = 0;
                }
                else if(MONEY eq "USD"){
                    yari_mamul_tl_price = unit_offer*usd_price;
                    yari_mamul_tl_list_price = price_exwork*usd_price;
                    kdv_tax = (yari_mamul_tl_price*1.18);
                    yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
                    if(yari_mamul_tl_price neq 0)
                    {
                        yari_mamul_tl_price_kdv = (yari_mamul_tl_price*18/100);
                    }else yari_mamul_tl_price_kdv = 0;
                    
                }
                else if(MONEY eq "GBP"){
                    yari_mamul_tl_price = unit_offer*gbp_price;
                    yari_mamul_tl_list_price = price_exwork*gbp_price;
                    kdv_tax = (yari_mamul_tl_price*1.18);
                    yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
                    if(yari_mamul_tl_price neq 0)
                    {
                        yari_mamul_tl_price_kdv = (yari_mamul_tl_price*18/100);
                    }else yari_mamul_tl_price_kdv = 0;
                    
                }
                else if(MONEY eq "EUR"){
                    yari_mamul_doviz_price = (unit_offer*QUANTITY);
                    yari_mamul_tl_price = yari_mamul_doviz_price*eur_price;
                    yari_mamul_tl_list_price = price_exwork*eur_price;
                    kdv_tax = (yari_mamul_tl_price*1.18);
                    if(yari_mamul_tl_price neq 0)
                    {
                        yari_mamul_tl_price_kdv = (yari_mamul_tl_price*18/100);
                    }else yari_mamul_tl_price_kdv = 0;
                }
                    total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
                    total_tl_group_offer = total_eur_group_offer*eur_price;
            </cfscript>

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
                        DELIVER_LOCATION,
                        LOT_NO
                    )
                VALUES
                    (
                        #MAX_ID.IDENTITYCOL#,
                        #product_id#,
                        #stock_id#,
                        #quantity#,
                        '#main_unit#',
				        #main_unit_id#,
                        #yari_mamul_tl_price#,
                        #price_exwork#,
                        '#money#',
                        #yari_mamul_doviz_price*quantity#,
                        #18#,
                        '#product_name#',
                        <cfif len(discount)>#discount#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim2#currentRow#')>#evaluate('attributes.indirim2#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim3#currentRow#')>#evaluate('attributes.indirim3#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim4#currentRow#')>#evaluate('attributes.indirim4#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim5#currentRow#')>#evaluate('attributes.indirim5#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim6#currentRow#')>#evaluate('attributes.indirim6#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim7#currentRow#')>#evaluate('attributes.indirim7#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim8#currentRow#')>#evaluate('attributes.indirim8#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim9#currentRow#')>#evaluate('attributes.indirim9#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.indirim10#currentRow#')>#evaluate('attributes.indirim10#currentRow#')#<cfelse>0</cfif>,
                        #yari_mamul_tl_price_kdv#,
                        #yari_mamul_tl_price*quantity#,
                        0,
                        0,
                        0,
                        <cfif isdefined('attributes.extra_cost#currentRow#') and len(evaluate('attributes.extra_cost#currentRow#'))>#evaluate('attributes.extra_cost#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.marj#currentRow#') and len(evaluate('attributes.marj#currentRow#'))>#evaluate('attributes.marj#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.promosyon_yuzde#currentRow#') and len(evaluate('attributes.promosyon_yuzde#currentRow#'))>#evaluate('attributes.promosyon_yuzde#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.promosyon_maliyet#currentRow#') and len(evaluate('attributes.promosyon_maliyet#currentRow#'))>#evaluate('attributes.promosyon_maliyet#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.iskonto_tutar#currentRow#') and len(evaluate('attributes.iskonto_tutar#currentRow#'))>#evaluate('attributes.iskonto_tutar#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_promotion_id#currentRow#') and len(evaluate('attributes.row_promotion_id#currentRow#'))>#evaluate('attributes.row_promotion_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.is_promotion#currentRow#') and len(evaluate('attributes.is_promotion#currentRow#'))>#evaluate('attributes.is_promotion#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.prom_stock_id#currentRow#') and len(evaluate('attributes.prom_stock_id#currentRow#'))>#evaluate('attributes.prom_stock_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.is_commission#currentRow#') and len(evaluate('attributes.is_commission#currentRow#'))>#evaluate('attributes.is_commission#currentRow#')#<cfelse>0</cfif>,
                        <cfif isdefined('attributes.row_unique_relation_id#currentRow#') and len(evaluate('attributes.row_unique_relation_id#currentRow#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.row_unique_relation_id#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.prom_relation_id#currentRow#') and len(evaluate('attributes.prom_relation_id#currentRow#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.prom_relation_id#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.amount_other#currentRow#') and len(evaluate('attributes.amount_other#currentRow#'))>#evaluate('attributes.amount_other#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.unit_other#currentRow#') and len(evaluate('attributes.unit_other#currentRow#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.unit_other#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.ek_tutar#currentRow#') and len(evaluate('attributes.ek_tutar#currentRow#'))>#evaluate('attributes.ek_tutar#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.ek_tutar_price#currentRow#') and len(evaluate('attributes.ek_tutar_price#currentRow#'))>#evaluate('attributes.ek_tutar_price#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.ek_tutar_total#currentRow#') and len(evaluate('attributes.ek_tutar_total#currentRow#'))>#evaluate('attributes.ek_tutar_total#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.ek_tutar_other_total#currentRow#') and len(evaluate('attributes.ek_tutar_other_total#currentRow#'))>#evaluate('attributes.ek_tutar_other_total#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.shelf_number#currentRow#') and len(evaluate('attributes.shelf_number#currentRow#'))>#evaluate('attributes.shelf_number#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.basket_extra_info#currentRow#') and len(evaluate('attributes.basket_extra_info#currentRow#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.basket_extra_info#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.select_info_extra#currentRow#') and len(evaluate('attributes.select_info_extra#currentRow#'))><cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.select_info_extra#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('get_offer_cost_company.FULLNAME') and len(#get_offer_cost_company.FULLNAME#)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_offer_cost_company.FULLNAME#"><cfelse>NULL</cfif>,                        <cfif isdefined('attributes.price_cat#currentRow#') and len(evaluate('attributes.price_cat#currentRow#'))>#evaluate('attributes.price_cat#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_catalog_id#currentRow#') and len(evaluate('attributes.row_catalog_id#currentRow#'))>#evaluate('attributes.row_catalog_id#currentRow#')#<cfelse>NULL</cfif>,
                        #yari_mamul_tl_list_price#,
                        <cfif isdefined('attributes.number_of_installment#currentRow#') and len(evaluate('attributes.number_of_installment#currentRow#'))>#evaluate('attributes.number_of_installment#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.basket_employee_id#currentRow#') and len(evaluate('attributes.basket_employee_id#currentRow#')) and isdefined('attributes.basket_employee#currentRow#') and len(evaluate('attributes.basket_employee#currentRow#'))>#evaluate('attributes.basket_employee_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.karma_product_id#currentRow#') and len(evaluate('attributes.karma_product_id#currentRow#'))>#evaluate('attributes.karma_product_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.reserve_date#currentRow#") and isdate(evaluate('attributes.reserve_date#currentRow#'))>#evaluate('attributes.reserve_date#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('get_offer_cost_det.OFFER_COST_HEAD') and len(#get_offer_cost_det.OFFER_COST_HEAD#)><cfqueryparam cfsqltype="cf_sql_varchar" value="#get_offer_cost_det.OFFER_COST_HEAD#"><cfelse>NULL</cfif>,
                        <cfif len(MANUFACT_CODE)>'#manufact_code#'<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.wrk_row_id#currentRow#') and len(evaluate('attributes.wrk_row_id#currentRow#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_id#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.wrk_row_relation_id#currentRow#') and len(evaluate('attributes.wrk_row_relation_id#currentRow#'))><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.wrk_row_relation_id#currentRow#')#"><cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.row_ship_id#currentRow#") and len(evaluate('attributes.row_ship_id#currentRow#')) and evaluate('attributes.row_ship_id#currentRow#') neq 0>#ListFirst(evaluate('attributes.row_ship_id#currentRow#'),';')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_width#currentRow#') and len(evaluate('attributes.row_width#currentRow#'))>#evaluate('attributes.row_width#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_depth#currentRow#') and len(evaluate('attributes.row_depth#currentRow#'))>#evaluate('attributes.row_depth#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_height#currentRow#') and len(evaluate('attributes.row_height#currentRow#'))>#evaluate('attributes.row_height#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_project_id#currentRow#') and len(evaluate('attributes.row_project_id#currentRow#')) and isdefined('attributes.row_project_name#currentRow#') and len(evaluate('attributes.row_project_name#currentRow#'))>#evaluate('attributes.row_project_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.row_work_id#currentRow#') and len(evaluate('attributes.row_work_id#currentRow#')) and isdefined('attributes.row_work_name#currentRow#') and len(evaluate('attributes.row_work_name#currentRow#'))>#evaluate('attributes.row_work_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined('attributes.pbs_code#currentRow#') and len(evaluate('attributes.pbs_code#currentRow#')) and isdefined('attributes.pbs_id#currentRow#') and len(evaluate('attributes.pbs_id#currentRow#'))>#evaluate('attributes.pbs_id#currentRow#')#<cfelse>NULL</cfif>,
                        <cfif isdefined("attributes.deliver_dept#currentRow#") and len(trim(evaluate("attributes.deliver_dept#currentRow#"))) and len(listfirst(evaluate("attributes.deliver_dept#currentRow#"),"-"))>
                            #listfirst(evaluate("attributes.deliver_dept#currentRow#"),"-")#,
                        <cfelseif isdefined('attributes.department_in_id') and len(attributes.department_in_id)>
                            #attributes.department_in_id#,
                        <cfelse>
                            NULL,
                        </cfif>
                        <cfif isdefined("attributes.deliver_dept#currentRow#") and listlen(trim(evaluate("attributes.deliver_dept#currentRow#")),"-") eq 2 and len(listlast(evaluate("attributes.deliver_dept#currentRow#"),"-"))>
                            #listlast(evaluate("attributes.deliver_dept#currentRow#"),"-")#
                        <cfelseif isdefined('attributes.location_in_id') and len(attributes.location_in_id)>
                            #attributes.location_in_id#
                        <cfelse>
                            NULL
                        </cfif>,
                        <cfif isdefined('attributes.lot_no#currentRow#')><cfqueryparam cfsqltype="cf_sql_varchar" value="#evaluate('attributes.lot_no#currentRow#')#"><cfelse>NULL</cfif>
                        <cfif isdefined('attributes.row_exp_center_id#currentRow#') and len(evaluate("attributes.row_exp_center_id#currentRow#")) and isdefined('attributes.row_exp_center_name#currentRow#') and len(evaluate("attributes.row_exp_center_name#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_center_id#currentRow#')#"></cfif>
                        <cfif isdefined('attributes.row_exp_item_id#currentRow#') and len(evaluate("attributes.row_exp_item_id#currentRow#")) and isdefined('attributes.row_exp_item_name#currentRow#') and len(evaluate("attributes.row_exp_item_name#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_exp_item_id#currentRow#')#"></cfif>
                        <cfif isdefined('attributes.row_activity_id#currentRow#') and len(evaluate("attributes.row_activity_id#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_integer" value="#evaluate('attributes.row_activity_id#currentRow#')#"></cfif>
                        <cfif isdefined('attributes.row_acc_code#currentRow#') and len(evaluate("attributes.row_acc_code#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#evaluate('attributes.row_acc_code#currentRow#')#"></cfif>
                        <cfif isdefined('attributes.row_oiv_rate#currentRow#') and len(evaluate("attributes.row_oiv_rate#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_rate#currentRow#')#"></cfif>
                        <cfif isdefined('attributes.row_oiv_amount#currentRow#') and len(evaluate("attributes.row_oiv_amount#currentRow#"))>,<cfqueryparam cfsqltype="cf_sql_float" value="#evaluate('attributes.row_oiv_amount#currentRow#')#"></cfif>
                    )
            </cfquery>
        </cfloop>

        <cfquery name="ADD_INTERNALDEMAND_MONEY" datasource="#DSN3#">
		INSERT INTO 
			INTERNALDEMAND_MONEY
		(
			MONEY_TYPE,
			ACTION_ID,
			RATE2,
			RATE1,
			IS_SELECTED
		)
		VALUES
			(
				'TL',
				#MAX_ID.IDENTITYCOL#,
				1,
				1,
				0
			),
			(
				'USD',
				#MAX_ID.IDENTITYCOL#,
				#usd_price#,
				1,
				0
			),
            (
				'GBP',
				#MAX_ID.IDENTITYCOL#,
				#gbp_price#,
				1,
				0
			),
			(
				'EUR',
				#MAX_ID.IDENTITYCOL#,
				#eur_price#,
				1,
				1
			)
	</cfquery>

        <cfquery name="UPD_OFFER_COST_DEMAND" datasource="#DSN3#">
            UPDATE 
                OFFER_COST
            SET
                INTERNAL_ID = #MAX_ID.IDENTITYCOL#
            WHERE 
                OFFER_COST_ID = #attributes.offer_cost_id#
        </cfquery>
        <cfif isDefined(get_offer_cost_det.SALES_EMP) and len(#get_offer_cost_det.SALES_EMP#)>
            <cfset kullanici=#get_offer_cost_det.SALES_EMP#>
        <cfelse>
            <cfset kullanici=#session.ep.userid#>
        </cfif>
        <cf_workcube_process
            data_source="workcube_test_1"
            action_page="#request.self#?fuseaction=purchase.list_purchasedemand&&event=upd&id=#get_max_id.MAX_ID#"
            action_id="#get_max_id.MAX_ID#"
            action_column="INTERNAL_ID"
            action_table="INTERNALDEMAND"
            is_upd="1"
            is_detail="1"
            process_stage="272"
            process_id="29"
            old_process_line="272"
            record_member="#kullanici#"
            record_date="#now()#"
            warning_description="#get_offer_cost_det.OFFER_COST_HEAD# : Satınalma Talebi">

        <script>
            alert('Satınalma Talebi Oluşturuldu! Satınalma Talebi Nn : <cfoutput>#paper_full#</cfoutput>');
            window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
        </script>
            <cfcatch  type="any">
                <cfsavecontent variable="ssss">
                    <cfdump var="#cfcatch#">
                </cfsavecontent>
            <cffile action="write" output="#ssss#" file="#application.systemparam.systemparam().download_folder#teklifmaliyethata1.html">
            </cfcatch>
        </cftry>