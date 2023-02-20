<!--- yarı mamülleri çekiyoruz --->
<cfquery name="GET_OFFER_COST_GROUP_PRODUCT" datasource="#DSN3#">
    SELECT
        OFFER_COST_ID,
        OFFER_COST_GROUP AS GRUP,
        PRODUCT_ID AS PRODUCT_ID,
        STOCK_ID AS STOCK_ID
    FROM
        OFFER_COST_GROUP_PRODUCT
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
</cfquery>
        
    <cfoutput query="GET_OFFER_COST_GROUP_PRODUCT">
        <cfquery name="GET_OFFER_ROW" datasource="#DSN3#">
            SELECT
                ROW_GROUP_NAME, 
                PRODUCT_NAME,
                PRODUCT_ID,
                STOCK_ID,
                QUANTITY
            FROM
                OFFER_COST_ROW
            WHERE
                OFFER_COST_ID = #attributes.offer_cost_id#
                AND
                ROW_GROUP_NAME = '#GRUP#'
        </cfquery>

        <cfset wrk_id = "#dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmss')#_#session.ep.userid#_#Evaluate('STOCK_ID')#_#round(rand()*100)#_2">
                
        <cfquery name="GET_PRODUCT_NAME" datasource="#DSN1#">
            SELECT
                PRODUCT_NAME
            FROM
                PRODUCT 
            WHERE
                PRODUCT_ID = #PRODUCT_ID#
        </cfquery>
            
        <!--- YARI MAMUL İÇİN MAIN SPECT --->
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
                    'YM - #GET_OFFER_COST_GROUP_PRODUCT.GRUP#',
                    1, <!--- SPECT_TYPE --->
                    #GET_OFFER_COST_GROUP_PRODUCT.PRODUCT_ID#,
                    #GET_OFFER_COST_GROUP_PRODUCT.STOCK_ID#,
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
            
        <cfloop query="GET_OFFER_ROW">
            <cfset quantity_ = GET_OFFER_ROW.QUANTITY>

            <cfquery name="GET_UNIT_ID" datasource="#DSN1#">
                SELECT
                    PRODUCT_UNIT_ID
                FROM
                    PRODUCT_UNIT
                WHERE
                    PRODUCT_ID = #PRODUCT_ID#
            </cfquery>
            <cfquery name="get_info_plus" datasource="#DSN3#">
                SELECT
                    PROPERTY1
                FROM 
                    PRODUCT_INFO_PLUS
                WHERE 
                    PRO_INFO_ID = 2 AND PRODUCT_ID = #PRODUCT_ID#
            </cfquery>
            <!--- YARI MAMULE ÜRÜN AĞACI OLUŞTURUYORUZ --->

            <cfquery name="GET_OFFER_COST_SEMI_PRODUCT" datasource="#DSN3#">
                SELECT
                    PRODUCT_ID,
                    STOCK_ID,
                    GROUP_QUANTITY,
                    OFFER_COST_GROUP
                FROM
                    OFFER_COST_GROUP_PRODUCT
                WHERE
                    OFFER_COST_ID = #attributes.offer_cost_id#
                    AND
                    OFFER_COST_GROUP = '#ROW_GROUP_NAME#'
            </cfquery>

            <cfset semi_product_quantity_ = get_offer_cost_semi_product.group_quantity>

            <cfscript>
                hammadde_adet = quantity_/semi_product_quantity_;
            </cfscript>

            <!---
            <cfdump var = "#GET_OFFER_COST_SEMI_PRODUCT#">

            #ROW_GROUP_NAME# </br>
            #semi_product_quantity_# <br>
            hesap = #quantity_# / #semi_product_quantity_#;
            --->

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
                        RECORD_DATE
                    )
                    VALUES
                    (
                        #GET_OFFER_COST_GROUP_PRODUCT.STOCK_ID#, <!--- ürün ağacının bağlanacağı ürünün stock_id si --->
                        #STOCK_ID#,<!--- teklif maliyetteki satırlardaki ürünlerin stock id leri --->
                        #PRODUCT_ID#,<!--- teklif maliyetteki satırlardaki ürünlerin product id leri --->
                        1,
                        #hammadde_adet#,
                        #GET_UNIT_ID.PRODUCT_UNIT_ID#, <!--- teklif maliyetteki satırlardaki ürünlerin unit id (PRODUCT_UNIT tablasundaki PRODUCT_UNIT_ID) leri --->
                        0,
                        1,
                        0,
                        253, <!--- process_stage --->
                        0,                    
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                    )
            </cfquery>

            <cfquery name="GET_SPECT_MAIN_ID" datasource="#DSN3#">
                SELECT MAX(SPECT_MAIN_ID) AS SPECT_MAIN_ID_ FROM SPECT_MAIN
            </cfquery>
        </cfloop>
        <cfquery name="GET_PRODUCT_TREE" datasource="#DSN3#">
            SELECT
                *           
            FROM
                PRODUCT_TREE
            WHERE
                STOCK_ID = #GET_OFFER_COST_GROUP_PRODUCT.STOCK_ID#
        </cfquery>
        <cfloop query="#GET_PRODUCT_TREE#">
            <cfquery name="GET_TREE_PRODUCT" datasource="#DSN1#">
                SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = #GET_PRODUCT_TREE.PRODUCT_ID#
            </cfquery>
             <!--- YARI MAMUL İÇİN SPECT SATIRLARI (HAMMADDELER) --->
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
    </cfoutput>

    <!--- MAMUL ÜRÜN AĞACI İÇİN --->

    <cfquery name="GET_SYSTEM_PRODUCT" datasource="#DSN3#">
        SELECT
            PRODUCT_ID,
            STOCK_ID
        FROM
            OFFER_COST
        WHERE
            OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfset system_product_id = get_system_product.product_id>
    <cfset system_stock_id = get_system_product.stock_id>
        
    <cfquery name="GET_OFFER_COST_SEMI_PRODUCT" datasource="#DSN3#">
        SELECT
            PRODUCT_ID,
            STOCK_ID,
            GROUP_QUANTITY
        FROM
            OFFER_COST_GROUP_PRODUCT
        WHERE
            OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>

    <cfset wrk_id_system = "#dateformat(now(),'YYYYMMDD')##timeformat(now(),'HHmmss')#_#session.ep.userid#_#Evaluate('system_stock_id')#_#round(rand()*100)#_2">

    <cfoutput query="GET_OFFER_COST_SEMI_PRODUCT">

        <cfset semi_product_id = product_id>
        <cfset semi_stock_id = stock_id>
        <cfset semi_product_quantity_ = group_quantity>

        <cfquery name="GET_UNIT_ID" datasource="#DSN1#">
            SELECT
                PRODUCT_UNIT_ID
            FROM
                PRODUCT_UNIT
            WHERE
                PRODUCT_ID = #semi_product_id#
        </cfquery>

        <cfquery name="GET_SEMI_PRODUCT_SM" datasource="#DSN3#">
            SELECT
                SPECT_MAIN_ID
            FROM
                SPECT_MAIN
            WHERE
                STOCK_ID = #semi_stock_id#
        </cfquery>
            
        <cfset semi_product_spect_main_id = GET_SEMI_PRODUCT_SM.SPECT_MAIN_ID>

             <!--- MAMUL İÇİN PRODUCT_TREE SATIRLARI (HAMMADDELER) --->
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
                    TREE_TYPE,
                    SPECT_MAIN_ID
                )
                VALUES
                (
                    #system_stock_id#, <!--- ürün ağacının bağlanacağı ürünün stock_id si --->
                    #semi_stock_id#,<!--- teklif maliyetteki satırlardaki ürünlerin stock id leri --->
                    #semi_product_id#,<!--- teklif maliyetteki satırlardaki ürünlerin product id leri --->
                    1,
                    #semi_product_quantity_#,
                    #GET_UNIT_ID.PRODUCT_UNIT_ID#, <!--- teklif maliyetteki satırlardaki ürünlerin unit id (PRODUCT_UNIT tablasundaki PRODUCT_UNIT_ID) leri --->
                    0,
                    1,
                    0,
                    253, <!--- process_stage --->
                    0,                    
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.userid#">,
                    <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">,
                    <cfif get_info_plus.recordCount><cfif get_info_plus.PROPERTY1 eq 'Garantili'>2<cfelseif get_info_plus.PROPERTY1 eq 'Garantisiz'>1</cfif><cfelse>NULL</cfif>,
                    #semi_product_spect_main_id#
                )
        </cfquery>
    </cfoutput>

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
                '#wrk_id_system#',
                'SİSTEM - #attributes.offer_cost_id#',
                1, <!--- SPECT_TYPE --->
                #system_product_id#,
                #system_stock_id#,
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

    <cfquery name="GET_SPECT_MAIN_ID" datasource="#DSN3#">
        SELECT MAX(SPECT_MAIN_ID) AS SPECT_MAIN_ID_ FROM SPECT_MAIN
    </cfquery>

    <cfquery name="GET_PRODUCT_TREE" datasource="#DSN3#">
        SELECT
            *           
        FROM
            PRODUCT_TREE
        WHERE
            STOCK_ID = #system_stock_id#
    </cfquery>
    <cfloop query="#GET_PRODUCT_TREE#">
        <cfquery name="GET_TREE_PRODUCT" datasource="#DSN1#">
            SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = #GET_PRODUCT_TREE.PRODUCT_ID#
        </cfquery>
         <!--- MAMUL İÇİN SPECT SATIRLARI (HAMMADDELER) --->
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

    <cfquery name="UPD_OFFER_COST_TREE" datasource="#DSN3#">
        UPDATE OFFER_COST
        SET
            IS_TREE = 1
        WHERE OFFER_COST_ID = #attributes.offer_cost_id#
    </cfquery>
    
    <script>
        alert('Ürün Ağacı Oluşturuldu !');
        window.location.href = '<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#attributes.offer_cost_id#</cfoutput>';
    </script>