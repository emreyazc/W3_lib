<!---
    Teklif Maliyet Sürecinin TEKLİF SÜRECİ içindir.
--->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
    <cfquery name="GET_OFFER_COST" datasource="#caller.DSN3#">
        SELECT
            PROJECT_ID
        FROM
            OFFER_COST
        WHERE
            OFFER_COST_ID = #attributes.action_id#
    </cfquery>
</cfif>

<!--- SATIRLARDAN YENİ ÜRÜN KARTLARI OLUŞTURMAK İÇİN --->
<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
    <cfquery name="GET_OFFER_COST_ROW" datasource="#caller.DSN3#">
        SELECT
            *
        FROM
            OFFER_COST_ROW
        WHERE
            OFFER_COST_ID = #attributes.action_id#
    </cfquery>
    
    <cfoutput query="GET_OFFER_COST_ROW">
        <cfif PRODUCT_ID eq ''>
            <cfquery name="GET_OTHER_PERIOD" datasource="#caller.DSN#">
                SELECT PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.COMPANY_ID#">
            </cfquery>
            <cfquery name="GET_CODES" datasource="#caller.DSN3#">
		        SELECT * FROM SETUP_PRODUCT_PERIOD_CAT WHERE PRO_CODE_CATID = 1
	        </cfquery>
            <!---
            <cfset bugun_00 = DateFormat(now(),dateformat_style)>
            --->
                <cfquery name="ADD_PRODUCT" datasource="#caller.DSN1#">
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
                            OFFER_COST_ROW_ID,
                            PROJECT_ID
                        )
                        VALUES
                        (
                            1,
                            'STD-#OFFER_COST_ROW_ID#-#attributes.action_id#',
                            593,
                            '#PRODUCT_NAME#',
                            18,
                            18,
                            1,
                            1,
                            0, /* IS_PRODUCTION */
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
                            <cfif len(MANUFACT_CODE)>'#MANUFACT_CODE#'<cfelse>NULL</cfif>, /* MANUFACT_CODE */
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
                            <cfif len(PRODUCT_CODE_2)>'#PRODUCT_CODE_2#'<cfelse>NULL</cfif>, /* PRODUCT_CODE_2 (ÖZEL KOD) */
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
                            #IS_IMPORTED#,
                            #attributes.action_id#,
                            #OFFER_COST_ROW_ID#,
                            <cfif len(GET_OFFER_COST.PROJECT_ID)>#GET_OFFER_COST.PROJECT_ID#<cfelse>NULL</cfif>
                        )
                    SELECT @@IDENTITY AS MAX_PRODUCT_ID
                </cfquery>
                <cfquery name="GET_PID" datasource="#caller.DSN1#">
                    SELECT MAX(PRODUCT_ID) AS PRODUCT_ID, MAX(PRODUCT_NAME) AS PRODUCT_NAME FROM PRODUCT
                </cfquery>
                <cfset pid = GET_PID.PRODUCT_ID>
                <cfquery name="ADD_GENERAL_PARAMETERS" datasource="#caller.DSN1#">
                    INSERT INTO PRODUCT_GENERAL_PARAMETERS
                    (
                        PRODUCT_ID,
                        COMPANY_ID, 
                        PRODUCT_STATUS,
                        IS_IMPORTED
                    )
                    VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#pid#">,
                        <cfif FORM.COMPANY_ID is ""><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.COMPANY_ID#"></cfif>,
                        #session.ep.company_id#,
                        #evaluate(IS_IMPORTED)#
                    )
                </cfquery>
                <cfif GET_CODES.recordcount and GET_OTHER_PERIOD.recordcount>
                    <cfloop list="#ValueList(GET_OTHER_PERIOD.PERIOD_ID)#" index="i">
                        <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN3#">
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
                <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN1#">
                    INSERT INTO
                        PRODUCT_UNIT 
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
                <cfquery name="GET_MAX_UNIT" datasource="#caller.DSN1#">
                    SELECT MAX(PRODUCT_UNIT_ID) AS MAX_UNIT FROM PRODUCT_UNIT
                </cfquery>
                <cfscript>
                    purchase_kdvsiz = PRICE_EXWORK;
                    purchase_kdvli = (purchase_kdvsiz*1.18);
                    purchase_is_tax_included = 0;
                </cfscript>
                <!--- purchasesales is 0 / alış fiyatı --->
                <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN1#">
                    INSERT INTO
                        PRICE_STANDART
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
                        #purchase_kdvsiz#,
                        #purchase_kdvli#,
                        #purchase_is_tax_included#,
                        0,
                        'TL',
                        #now()#,
                        #NOW()#,
                        1,
                        #GET_MAX_UNIT.MAX_UNIT#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
            <!--- purchasesales is 1 / satış fiyatı --->
            <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN1#">
                INSERT INTO 
                    PRICE_STANDART
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
                    0,
                    0,
                    'TL',
                    #now()#,
                    #NOW()#,
                    1,
                    #GET_MAX_UNIT.MAX_UNIT#,
                    #SESSION.EP.USERID#
                )
            </cfquery>
            <cfquery name="ADD_STOCKS" datasource="#caller.DSN1#">
                INSERT INTO
                    STOCKS
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
                    'STD - #OFFER_COST_ROW_ID# - #attributes.action_id#',
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
            <cfquery name="GET_MAX_STCK" datasource="#caller.DSN1#">
                SELECT 
                    MAX(STOCK_ID) AS MAX_STCK, 
                    MAX(PRODUCT_UNIT_ID) AS MAX_UNIT_ID 
                FROM STOCKS
            </cfquery>
            <cfquery name="ADD_STOCK_BARCODE" datasource="#caller.DSN1#">
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
            <cfquery name="ADD_PRODUCT_OUR_COMPANY_ID" datasource="#caller.DSN1#">
                INSERT INTO 
                    PRODUCT_OUR_COMPANY
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
            <cfquery name="add_product_branch_id" datasource="#caller.DSN1#">
                INSERT INTO
                    PRODUCT_BRANCH
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
            <cfquery name="get_my_periods" datasource="#caller.DSN#">
                SELECT * FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #SESSION.EP.COMPANY_ID#
            </cfquery>
            <cfloop query="get_my_periods">
                <!---
                <cfif database_type is "MSSQL">
                    <cfset temp_dsn = "#DSN#_#PERIOD_YEAR#_#SESSION.EP.COMPANY_ID#">
                <cfelseif database_type is "DB2">
                    <cfset temp_dsn = "#dsn#_#SESSION.EP.COMPANY_ID#_#right(period_year,2)#">
                </cfif>
                --->
                <cfquery name="INSRT_STK_ROW" datasource="#caller.DSN2#">
                    INSERT INTO STOCKS_ROW
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
            <cfquery name="ADD_STK_STRATEGY" datasource="#caller.DSN3#">
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

            <cfquery name="GET_PID_2" datasource="#caller.DSN1#">
                    SELECT MAX(PRODUCT_ID) AS PRODUCT_ID, MAX(PRODUCT_NAME) AS PRODUCT_NAME FROM PRODUCT
            </cfquery>

            <cfquery name="UPD_OFFER_COST_ROW" datasource="#caller.DSN3#">
                UPDATE OFFER_COST_ROW
                SET
                    IS_ALTERNATIVE = 0,
                    PRODUCT_ID = #GET_PID_2.PRODUCT_ID#,
                    STOCK_ID = #GET_MAX_STCK.MAX_STCK#
                WHERE OFFER_COST_ROW_ID = #OFFER_COST_ROW_ID#
            </cfquery>
        </cfif>
    </cfoutput>
</cfif>

<!--- GRUPLARA (YARI MAMULLERE) YENİ ÜRÜN KARTI OLUŞTURMAK İÇİN --->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
        <cfquery name="OFFER_COST_PRODUCT_CONTROL" datasource="#caller.DSN3#">
            SELECT
                PRODUCT_ID
            FROM
                OFFER_COST
            WHERE
                OFFER_COST_ID = #attributes.action_id#
        </cfquery>
    <cfif len(offer_cost_product_control.product_id) eq 0>

        <cfquery name="GET_OFFER_COST_ROW_GROUP" datasource="#caller.DSN3#">
            SELECT DISTINCT ROW_GROUP_NAME AS GRUP, ROW_GROUP_MONEY FROM OFFER_COST_ROW WHERE OFFER_COST_ID = #attributes.action_id# AND ROW_GROUP_NAME IS NOT NULL
        </cfquery>
        
        <cfif get_offer_cost_row_group.recordCount gt 0>
            <cfloop query="#GET_OFFER_COST_ROW_GROUP#">
                <cfquery name="GET_OTHER_PERIOD" datasource="#caller.DSN#">
                    SELECT PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.COMPANY_ID#">
                </cfquery>
                <cfquery name="GET_CODES" datasource="#caller.DSN3#">
                    SELECT * FROM SETUP_PRODUCT_PERIOD_CAT WHERE PRO_CODE_CATID = 1
                </cfquery>

                <cfscript>
                    grup_adi = '#GET_OFFER_COST_ROW_GROUP.GRUP#';
                    urun_adi = 'YM-#grup_adi#-#attributes.action_id#';
                </cfscript>

                <cfquery name="ADD_PRODUCT" datasource="#caller.DSN1#">
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
                                <!---
                                MANUFACT_CODE,
                                --->
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
                                <!---
                                PRODUCT_CODE_2,
                                --->
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
                                <!---
                                OFFER_COST_ROW_ID,
                                --->
                                PROJECT_ID
                                
                            )
                            VALUES
                            (
                                1,
                                '#urun_adi#',
                                593,
                                '#urun_adi#',
                                18,
                                18,
                                1,
                                1,
                                1, /* IS_PRODUCTION */
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
                                <!---
                                <cfif len(MANUFACT_CODE)>'#MANUFACT_CODE#'<cfelse>NULL</cfif>, /* MANUFACT_CODE */
                                --->
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
                                <!---
                                <cfif len(PRODUCT_CODE_2)>'#PRODUCT_CODE_2#'<cfelse>NULL</cfif>, /* PRODUCT_CODE_2 (ÖZEL KOD) */
                                --->
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
                                0, <!--- IS_IMPORTED (ithal ediliyor) --->
                                #attributes.action_id#,
                                <!---
                                #OFFER_COST_ROW_ID#,
                                --->
                                <cfif len(GET_OFFER_COST.PROJECT_ID)>#GET_OFFER_COST.PROJECT_ID#<cfelse>NULL</cfif>
                            )
                        SELECT @@IDENTITY AS MAX_PRODUCT_ID
                </cfquery>
                <cfquery name="GET_PID" datasource="#caller.DSN1#">
                    SELECT MAX(PRODUCT_ID) AS PRODUCT_ID, MAX(PRODUCT_NAME) AS PRODUCT_NAME FROM PRODUCT
                </cfquery>
                <cfset pid = GET_PID.PRODUCT_ID>
                <cfquery name="ADD_GENERAL_PARAMETERS" datasource="#caller.DSN1#">
                    INSERT INTO PRODUCT_GENERAL_PARAMETERS
                    (
                        PRODUCT_ID,
                        COMPANY_ID, 
                        PRODUCT_STATUS,
                        IS_IMPORTED
                    )
                    VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#pid#">,
                        <cfif FORM.COMPANY_ID is ""><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.COMPANY_ID#"></cfif>,
                        #session.ep.company_id#,
                        0
                    )
                </cfquery>
                <cfif GET_CODES.recordcount and GET_OTHER_PERIOD.recordcount>
                        <cfloop list="#ValueList(GET_OTHER_PERIOD.PERIOD_ID)#" index="i">
                            <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN3#">
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
                <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN1#">
                    INSERT INTO
                        PRODUCT_UNIT 
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
                        48,
                        'Set',
                        48,
                        'Set',
                        NULL,
                        NULL,
                        NULL,
                        1,
                        1,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                    )
                </cfquery>
                <cfquery name="GET_MAX_UNIT" datasource="#caller.DSN1#">
                    SELECT MAX(PRODUCT_UNIT_ID) AS MAX_UNIT FROM PRODUCT_UNIT
                </cfquery>
                <cfquery name="GET_OFFER_COST_ROW" datasource="#caller.DSN3#">
                    SELECT
                        *
                    FROM
                        OFFER_COST_ROW
                    WHERE
                        OFFER_COST_ID = #attributes.action_id#
                        AND
                        ROW_GROUP_NAME = '#GET_OFFER_COST_ROW_GROUP.GRUP#'
                </cfquery>
                <cfquery name="GET_MONEY_USD" datasource="#caller.DSN#">
                    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'USD'
                </cfquery>
                <cfquery name="GET_MONEY_GBP" datasource="#caller.DSN#">
                    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'GBP'
                </cfquery>
                <cfquery name="GET_MONEY_EUR" datasource="#caller.DSN#">
                    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'EUR'
                </cfquery>
                <cfquery name="GET_MONEY" datasource="#caller.DSN#">
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
                        }else if(MONEY eq "GBP"){
                            to_tl_group = TOTAL_OFFER*gbp_price;
                            to_eur_group = to_tl_group/eur_price;
                        }
                        total_eur_group = total_eur_group+to_eur_group;
                    </cfscript>
                </cfoutput>
                <cfscript>
                    total_eur_group_kdv =  (total_eur_group*1.18);
                </cfscript>
                <!--- grup dövizi ile hesaplama sağlandı. Y.Emre Yazici - 14.01.2023--->
                <cfscript>
                    if(ROW_GROUP_MONEY eq "TL"){
                        to_doviz_group = total_eur_group*eur_price;
                    }
                    else if(ROW_GROUP_MONEY eq "USD"){
                        to_doviz_group_tl = total_eur_group*eur_price;
                        to_doviz_group = to_doviz_group_tl/usd_price;
                    }
                    else if(ROW_GROUP_MONEY eq "EUR"){
                        to_doviz_group = total_eur_group;
                    }else if(ROW_GROUP_MONEY eq "GBP"){
                        to_doviz_group_tl = total_eur_group*eur_price;
                        to_doviz_group = to_doviz_group_tl/gbp_price;
                    }
                </cfscript>
                <cfscript>
                    to_doviz_group_kdv = (to_doviz_group*1.18);
                </cfscript>
                <!--- grup dövizi ile hesaplama sağlandı. Y.Emre Yazici - 14.01.2023--->
                <cfset bugun_00 = DateFormat(now(),caller.dateformat_style)>
                <cf_date tarih='bugun_00'>
                <!--- purchasesales is 0 / alış fiyatı --->
                <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                    INSERT INTO
                        #caller.dsn1_alias#.PRICE_STANDART
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
                        0,
                        0,
                        0,
                        0,
                        '#ROW_GROUP_MONEY#',
                        #bugun_00#,
                        #NOW()#,
                        1,
                        #GET_MAX_UNIT.MAX_UNIT#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
                <!--- purchasesales is 1 / satış fiyatı --->
                <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                    INSERT INTO 
                        #caller.dsn1_alias#.PRICE_STANDART
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
                        #to_doviz_group#,
                        #to_doviz_group_kdv#,
                        0, <!---IS_KDV--->
                        0,
                        '#ROW_GROUP_MONEY#',
                        #bugun_00#,
                        #NOW()#,
                        1,
                        #GET_MAX_UNIT.MAX_UNIT#,
                        #SESSION.EP.USERID#
                    )
                </cfquery>
                <!---
                <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                    INSERT INTO
                        #caller.dsn1_alias#.PRICE_STANDART
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
                        0,
                        0,
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
                <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                    INSERT INTO 
                        #caller.dsn1_alias#.PRICE_STANDART
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
                --->
                <cfscript>
                    grup_adi = '#GET_OFFER_COST_ROW_GROUP.GRUP#';
                    stok_adi = 'S-YM-#grup_adi#-#attributes.action_id#';
                </cfscript>
                <cfquery name="ADD_STOCKS" datasource="#caller.DSN3#">
                    INSERT INTO
                        #caller.dsn1_alias#.STOCKS
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
                        '#stok_adi#',
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
                <cfquery name="GET_MAX_STCK" datasource="#caller.DSN1#">
                    SELECT 
                            MAX(STOCK_ID) AS MAX_STCK, 
                            MAX(PRODUCT_UNIT_ID) AS MAX_UNIT_ID 
                    FROM STOCKS
                </cfquery>
                <cfquery name="ADD_STOCK_BARCODE" datasource="#caller.DSN1#">
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
                <cfquery name="ADD_PRODUCT_OUR_COMPANY_ID" datasource="#caller.DSN3#">
                    INSERT INTO 
                        #caller.dsn1_alias#.PRODUCT_OUR_COMPANY
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
                <cfquery name="add_product_branch_id" datasource="#caller.DSN3#">
                    INSERT INTO
                        #caller.dsn1_alias#.PRODUCT_BRANCH
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
                <cfquery name="get_my_periods" datasource="#caller.DSN3#">
                    SELECT * FROM #caller.dsn_alias#.SETUP_PERIOD WHERE OUR_COMPANY_ID = #SESSION.EP.COMPANY_ID#
                </cfquery>
                <cfloop query="get_my_periods">
                    <cfset temp_dsn = "#caller.DSN#_#PERIOD_YEAR#_#SESSION.EP.COMPANY_ID#">
                    <cfquery name="INSRT_STK_ROW" datasource="#caller.DSN3#">
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
                <cfquery name="ADD_STK_STRATEGY" datasource="#caller.DSN3#">
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

                <cfquery name="UPD_OFFER_COST_GROUP_PRODUCT" datasource="#caller.DSN3#">
                    UPDATE 
                        OFFER_COST_GROUP_PRODUCT
                    SET
                        PRODUCT_ID = #GET_PID.PRODUCT_ID#, 
                        STOCK_ID = #GET_MAX_STCK.MAX_STCK#
                    WHERE 
                        OFFER_COST_ID = #attributes.action_id#
                        AND
                        OFFER_COST_GROUP = '#grup_adi#'
                </cfquery>
            </cfloop>
            <!---
            <cfloop query="#GET_OFFER_COST_ROW_GROUP#">
                <cfquery name="GET_OFFER_COST_ROW_W_GROUP" datasource="#caller.DSN3#">
                    SELECT
                        PRODUCT_NAME,
                        ROW_GROUP_NAME
                    FROM
                        OFFER_COST_ROW
                    WHERE
                        OFFER_COST_ID = #attributes.action_id#
                        AND
                        ROW_GROUP_NAME = '#GRUP#'
                </cfquery>
                <cfdump var="#GET_OFFER_COST_ROW_W_GROUP#">
            </cfloop>
            --->
        </cfif>
    </cfif>
</cfif>

<!--- BELGEYE (SİSTEME) MAMUL YENİ ÜRÜN KARTI OLUŞTURMAK İÇİN --->
<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
        <cfquery name="OFFER_COST_PRODUCT_CONTROL" datasource="#caller.DSN3#">
            SELECT
                PRODUCT_ID
            FROM
                OFFER_COST
            WHERE
                OFFER_COST_ID = #attributes.action_id#
        </cfquery>

        <cfif len(offer_cost_product_control.product_id) eq 0>

            <cfquery name="GET_OFFER_COST_ROW" datasource="#caller.DSN3#">
                SELECT
                    *
                FROM
                    OFFER_COST_ROW
                WHERE
                    OFFER_COST_ID = #attributes.action_id#
                    AND
                    IS_ALTERNATIVE <> 2
                    AND
                    ROW_GROUP_NAME <> 'Hizmet' <!--- opsiyon ve hizmet ürünleri dahil değil --->
            </cfquery>
            <cfquery name="GET_OFFER_COST_ROW_WITH_HIZMET" datasource="#caller.DSN3#">
                SELECT
                    *
                FROM
                    OFFER_COST_ROW
                WHERE
                    OFFER_COST_ID = #attributes.action_id#
                    AND
                    IS_ALTERNATIVE <> 2
                    AND
                    IS_ALTERNATIVE <> 3
                    AND
                    ROW_GROUP_NAME IS NOT NULL
            </cfquery>

            <cfquery name="GET_MONEY_USD" datasource="#caller.DSN#">
                SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'USD'
            </cfquery>
            <cfquery name="GET_MONEY_GBP" datasource="#caller.DSN#">
                SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'GBP'
            </cfquery>
            <cfquery name="GET_MONEY_EUR" datasource="#caller.DSN#">
                SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'EUR'
            </cfquery>
            <cfquery name="GET_MONEY" datasource="#caller.DSN#">
                SELECT * FROM SETUP_MONEY
            </cfquery>
            <cfscript>
                usd_price = get_money_usd.rate2;
                eur_price = get_money_eur.rate2;
                gbp_price = get_money_gbp.rate2;
            </cfscript>
            <cfscript>
                to_eur_group = 0;
                total_eur_group_offer = 0;
                total_eur_group_cost = 0;
                total_eur_group_kdv = 0;
                total_eur_group_offer_kdv = 0;
                total_eur_group_kdv_cost = 0;
            </cfscript>

            <cfquery name="GET_OTHER_PERIOD" datasource="#caller.DSN3#">
                SELECT PERIOD_ID FROM #caller.dsn_alias#.SETUP_PERIOD WHERE OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.COMPANY_ID#">
            </cfquery>
            <cfquery name="GET_CODES" datasource="#caller.DSN3#">
                SELECT * FROM SETUP_PRODUCT_PERIOD_CAT WHERE PRO_CODE_CATID = 1
            </cfquery>
            <cfset bugun_00 = DateFormat(now(),caller.dateformat_style)>
            <cf_date tarih='bugun_00'>
            <cfquery name="ADD_PRODUCT" datasource="#caller.DSN1#">
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
                        'STD - #attributes.action_id#',
                        593,
                        'Ürün TM - #attributes.action_id#',
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
                        0,
                        #attributes.action_id#,
                        <cfif len(GET_OFFER_COST.PROJECT_ID)>#GET_OFFER_COST.PROJECT_ID#<cfelse>NULL</cfif>
                    )
                SELECT @@IDENTITY AS MAX_PRODUCT_ID
            </cfquery>
            <cfquery name="GET_PID" datasource="#caller.DSN3#">
                SELECT MAX(PRODUCT_ID) AS PRODUCT_ID FROM #caller.dsn1_alias#.PRODUCT
            </cfquery>
            <cfset pid = GET_PID.PRODUCT_ID>

            <cfquery name="ADD_GENERAL_PARAMETERS" datasource="#caller.DSN1#">
                INSERT INTO PRODUCT_GENERAL_PARAMETERS
                (
                    PRODUCT_ID,
                    COMPANY_ID, 
                    PRODUCT_STATUS,
                    IS_IMPORTED
                )
                VALUES
                (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#pid#">,
                    <cfif FORM.COMPANY_ID is ""><cfqueryparam cfsqltype="cf_sql_integer" value="" null="yes"><cfelse><cfqueryparam cfsqltype="cf_sql_integer" value="#FORM.COMPANY_ID#"></cfif>,
                    #session.ep.company_id#,
                    0
                )
            </cfquery>

            <cfif GET_CODES.recordcount and GET_OTHER_PERIOD.recordcount>
                <cfloop list="#ValueList(GET_OTHER_PERIOD.PERIOD_ID)#" index="i">
                    <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN3#">
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
            <cfquery name="ADD_MAIN_UNIT" datasource="#caller.DSN3#">
                INSERT INTO
                    #caller.dsn1_alias#.PRODUCT_UNIT 
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
                    48,
                    'Set',
                    48,
                    'Set',
                    NULL,
                    NULL,
                    NULL,
                    1,
                    1,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                )				
            </cfquery>
            <cfquery name="GET_MAX_UNIT" datasource="#caller.DSN3#">
                SELECT MAX(PRODUCT_UNIT_ID) AS MAX_UNIT FROM #caller.dsn1_alias#.PRODUCT_UNIT
            </cfquery>

            <cfquery name="GET_OFFER_COST_GROUP_PRODUCT" datasource="#caller.DSN3#">
                SELECT
                    OCGP.PRODUCT_ID,
                    OFFER_COST_GROUP,
                    PS.PRICE,
                    PS.MONEY
                FROM
                    OFFER_COST_GROUP_PRODUCT OCGP
                    LEFT JOIN #caller.DSN1#.PRICE_STANDART PS ON PS.PRODUCT_ID = OCGP.PRODUCT_ID
                WHERE
                    OFFER_COST_ID = #attributes.action_id#
                    AND
                    PS.PURCHASESALES = 1
            </cfquery>

            <cfif get_offer_cost_group_product.recordCount gt 0>
                <cfloop query="#GET_OFFER_COST_GROUP_PRODUCT#">
                    <cfscript>
                        if(MONEY eq "TL"){
                            to_eur_group = price/eur_price;
                        }
                        else if(MONEY eq "USD"){
                            to_tl_group = price/usd_price;
                            to_eur_group = to_tl_group/eur_price;
                        }
                        else if(MONEY eq "EUR"){
                            to_eur_group = price;
                        }
                        else if(MONEY eq "GBP"){
                            to_tl_group = price/gbp_price;
                            to_eur_group = to_tl_group/eur_price;
                        }
                            total_eur_group_offer = total_eur_group_offer+to_eur_group;
                            total_tl_group_offer = total_eur_group_offer*eur_price;
                    </cfscript>
                    <cfoutput>
                        #currentrow# - #to_eur_group#
                        </br>
                    </cfoutput> 
                </cfloop>
                <cfscript>
                    total_eur_group_offer = caller.wrk_round(total_eur_group_offer);
                    total_eur_group_offer_kdv =  caller.wrk_round(total_eur_group_offer*1.18);
                </cfscript>
            </cfif>

            <!---
            <cfdump var="#GET_OFFER_COST_GROUP_PRODUCT#">

            <cfoutput>
                ticari mal = #total_eur_group_offer#
                </br>
            </cfoutput>
            --->

            <cfquery name="GET_OFFER_COST_ROW_NON_GROUP" datasource = "#caller.DSN3#">
	        	SELECT
	        		OCR.PRODUCT_ID AS PRODUCT_ID,
	        		OCR.STOCK_ID AS STOCK_ID,
	        		OCR.QUANTITY AS QUANTITY,
	        		OCR.UNIT_OFFER AS UNIT_OFFER,
                    OCR.MONEY AS MONEY,
	        		P.PRODUCT_NAME AS PRODUCT_NAME
	        	FROM
	        		OFFER_COST_ROW OCR
	        		LEFT JOIN PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
	        	WHERE
	        		OCR.OFFER_COST_ID = #attributes.action_id#
	        		AND
	        		OCR.IS_ALTERNATIVE <> 2
	        		AND
	        		OCR.IS_ALTERNATIVE <> 3
	        		AND
	        		OCR.ROW_GROUP_NAME IS NULL
	        </cfquery>

            <cfscript>
                ticari_mal_total_eur_group_offer = 0;
            </cfscript>

            <cfif get_offer_cost_row_non_group.recordCount gt 0>
                <cfloop query="#get_offer_cost_row_non_group#">
                    <cfscript>
                        if(MONEY eq "TL"){
                            ticari_mal_tl_price = unit_offer;
                            ticari_mal_doviz_price = (unit_offer/eur_price);
                            ticari_mal_doviz_price_q = (unit_offer/eur_price)*QUANTITY;
                        }
                        else if(MONEY eq "USD"){
                            ticari_mal_tl_price = unit_offer*usd_price;
                            ticari_mal_doviz_price_q = (ticari_mal_tl_price/eur_price)*QUANTITY;
                            ticari_mal_doviz_price = (ticari_mal_tl_price/eur_price);
                        }
                        else if(MONEY eq "EUR"){
                            ticari_mal_doviz_price_q = (unit_offer*QUANTITY);
                            ticari_mal_doviz_price = unit_offer;
                            ticari_mal_tl_price = unit_offer*eur_price;
                        }
                        else if(MONEY eq "GBP"){
                            ticari_mal_tl_price = unit_offer*gbp_price;
                            ticari_mal_doviz_price_q = (ticari_mal_tl_price/eur_price)*QUANTITY;
                            ticari_mal_doviz_price = (ticari_mal_tl_price/eur_price);
                        }
                            ticari_mal_total_eur_group_offer = ticari_mal_total_eur_group_offer+ticari_mal_doviz_price_q;
                            ticari_mal_total_tl_group_offer = ticari_mal_total_eur_group_offer*eur_price;
                    </cfscript>
                </cfloop>
                <cfscript>
                    total_eur_group_offer = total_eur_group_offer+ticari_mal_total_eur_group_offer;
                    total_eur_group_offer_kdv = total_eur_group_offer*1.18;
                </cfscript>
            </cfif>

            <!---
            <cfdump var="#get_offer_cost_row_non_group#">

            <cfoutput>
                ticari mal = #ticari_mal_total_eur_group_offer#
                </br>
            </cfoutput>
            --->

            <!--- purchasesales is 0 / alış fiyatı --->
            <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                INSERT INTO
                    #caller.dsn1_alias#.PRICE_STANDART
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
                    0,
                    0,
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
            <cfquery name="ADD_STD_PRICE" datasource="#caller.DSN3#">
                INSERT INTO 
                    #caller.dsn1_alias#.PRICE_STANDART
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
                    #total_eur_group_offer#,
                    #total_eur_group_offer_kdv#,
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
            <cfquery name="ADD_STOCKS" datasource="#caller.DSN3#">
                INSERT INTO
                    #caller.dsn1_alias#.STOCKS
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
                    'STD - #attributes.action_id#',
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
            <cfquery name="GET_MAX_STCK" datasource="#caller.DSN1#">
                SELECT 
                        MAX(STOCK_ID) AS MAX_STCK, 
                        MAX(PRODUCT_UNIT_ID) AS MAX_UNIT_ID 
                FROM STOCKS
            </cfquery>
            <cfquery name="ADD_STOCK_BARCODE" datasource="#caller.DSN1#">
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
            <cfquery name="ADD_PRODUCT_OUR_COMPANY_ID" datasource="#caller.DSN3#">
                INSERT INTO 
                    #caller.dsn1_alias#.PRODUCT_OUR_COMPANY
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
            <cfquery name="add_product_branch_id" datasource="#caller.DSN3#">
                INSERT INTO
                    #caller.dsn1_alias#.PRODUCT_BRANCH
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
            <cfquery name="get_my_periods" datasource="#caller.DSN3#">
                SELECT * FROM #caller.dsn_alias#.SETUP_PERIOD WHERE OUR_COMPANY_ID = #SESSION.EP.COMPANY_ID#
            </cfquery>
            <cfloop query="get_my_periods">
                <cfset temp_dsn = "#caller.DSN#_#PERIOD_YEAR#_#SESSION.EP.COMPANY_ID#">
                <cfquery name="INSRT_STK_ROW" datasource="#caller.DSN3#">
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
            <cfquery name="ADD_STK_STRATEGY" datasource="#caller.DSN3#">
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
            <cfquery name="UPD_OFFER_COST_PRODUCT" datasource="#caller.DSN3#">
                UPDATE 
                    OFFER_COST
                SET 
                    PRODUCT_ID = #GET_PID.PRODUCT_ID#,
                    STOCK_ID = #GET_MAX_STCK.MAX_STCK#
                WHERE 
                    OFFER_COST_ID = #attributes.action_id#;
            </cfquery>
        </cfif>
</cfif>