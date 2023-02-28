<!---
    Date : 28.02.2023 
    Desc : Mal alım faturası kesildiğinde son satınalma fiyatını ürün kartına standart alış fiyatına EUR olarak yazar.
    Dev : Yunus Emre Yazıcı - Holo Dijital
--->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
    <cfquery name="GET_INVOICE_PRODUCT" datasource="#caller.DSN2#">
        SELECT
            IRR.PRODUCT_ID,
            IRR.TAX,
            IRR.PRICE AS BIRIM_FIYAT_TL,
            I.INVOICE_DATE
        FROM
            INVOICE I
            LEFT JOIN INVOICE_ROW IRR ON IRR.INVOICE_ID = I.INVOICE_ID
            LEFT JOIN INVOICE_MONEY IM ON IM.ACTION_ID = I.INVOICE_ID
        WHERE
            I.INVOICE_ID = #attributes.action_id#
            AND
            IM.IS_SELECTED = 1
    </cfquery>

    <cfquery name="GET_INVOICE_EUR" datasource="#caller.DSN2#">
        SELECT
            RATE2
        FROM
            INVOICE_MONEY
        WHERE
            ACTION_ID = #attributes.action_id#
            AND
            MONEY_TYPE = 'EUR'
    </cfquery>

    <cfoutput query="get_invoice_product">
        <cfscript>
            eur_price = get_invoice_eur.rate2;
            alis_fiyati_tl = birim_fiyat_tl;
            alis_fiyati_eur = birim_fiyat_tl/eur_price;
            kdv_tutar_alis = alis_fiyati_tl*tax/100;
        </cfscript>

        <cfquery name="GET_UNIT" datasource="#caller.DSN2#">
            SELECT
                PRODUCT_UNIT_ID
            FROM
                #caller.DSN1#.PRODUCT_UNIT
            WHERE
                PRODUCT_ID = #product_id#
                AND
                PRODUCT_UNIT_STATUS = 1
        </cfquery>

        <cfquery name="UPD_ALIS" datasource="#caller.DSN2#">
            UPDATE 
                #caller.DSN1#.PRICE_STANDART
            SET 
                PRICESTANDART_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="0">,
                RECORD_EMP = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.USERID#">
            WHERE 
                PRODUCT_ID = #product_id#
                AND
                PURCHASESALES = 0
        </cfquery>

        <cfset bugun_00 = DateFormat(get_invoice_product.invoice_date,caller.dateformat_style)>
        <cf_date tarih='bugun_00'>

        <cfquery name="INSERT_PRICE_ALIS" datasource="#caller.DSN2#">
            INSERT INTO 
                #caller.DSN1#.PRICE_STANDART
                    (
                        PRICESTANDART_STATUS,
                        PRODUCT_ID,
                        PURCHASESALES,
                        PRICE,
                        PRICE_KDV,
                        IS_KDV,
                        ROUNDING,
                        MONEY,
                        UNIT_ID,
                        START_DATE,
                        RECORD_DATE,
                        RECORD_IP,
                        RECORD_EMP
                    )
                VALUES
                    (
                        <cfqueryparam cfsqltype="cf_sql_smallint" value="1">,
                        #product_id#,
                        0, <!--- alış --->
                        #alis_fiyati_eur#,
                        #kdv_tutar_alis#,
                        0,
                        0,
                        'EUR',
                        #get_unit.product_unit_id#,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#bugun_00#">,
                        <cfqueryparam cfsqltype="cf_sql_timestamp" value="#get_invoice_product.invoice_date#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTEADDR#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.EP.USERID#">  
                    )
        </cfquery>
    </cfoutput>
</cfif>