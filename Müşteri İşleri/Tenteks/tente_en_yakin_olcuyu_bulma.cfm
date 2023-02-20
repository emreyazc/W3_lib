<!---
<cfquery name="get_product_width_tente" datasource="#DSN1#" maxrows="-1"><!--- maxrows="#arguments.maxrows#" --->
    SELECT
        PP.PROPERTY_ID,
        PPD.PROPERTY_DETAIL AS PRODUCT_,
        PPD.PROPERTY_DETAIL_ID AS PROPERTY_DETAIL_ID,
        PPD.IS_ACTIVE AS PRODUCT_ID
    FROM
        PRODUCT_PROPERTY_DETAIL PPD
        LEFT JOIN PRODUCT_PROPERTY PP ON PP.PROPERTY_ID = PPD.PRPT_ID
    WHERE
        PPD.PRPT_ID = 46
        <!---
        AND
        (PPD.PROPERTY_DETAIL BETWEEN #arguments.product_width_tente#-60 AND #arguments.product_width_tente#+60)
        --->
    ORDER BY
        PPD.PROPERTY_DETAIL ASC
</cfquery>

<cfquery name="get_product_height_tente" datasource="#DSN1#" maxrows="-1"><!--- maxrows="#arguments.maxrows#" --->
    SELECT
        PP.PROPERTY_ID,
        PPD.PROPERTY_DETAIL AS PRODUCT_,
        PPD.PROPERTY_DETAIL_ID AS PROPERTY_DETAIL_ID,
        PPD.IS_ACTIVE AS PRODUCT_ID
    FROM
        PRODUCT_PROPERTY_DETAIL PPD
        LEFT JOIN PRODUCT_PROPERTY PP ON PP.PROPERTY_ID = PPD.PRPT_ID
    WHERE
        PPD.PRPT_ID = 47 <!--- AÇILIM ID --->
        <!---
        AND
        (PPD.PROPERTY_DETAIL BETWEEN #arguments.product_height_tente#-50 AND #arguments.product_height_tente#+50)
        --->
    ORDER BY
        PPD.PROPERTY_DETAIL ASC
</cfquery>

<cfset array_tente_height = ArrayNew(1)>
<cfloop query="#get_product_height_tente#">
    <cfset array_tente_height[currentRow] = [PRODUCT_]>
</cfloop>

<cfset array_tente_width = ArrayNew(1)>
<cfloop query="#get_product_width_tente#">
    <cfset array_tente_width[currentRow] = [PRODUCT_]>
</cfloop>

<!---
<cfset myVariable_height = array_tente_height[1]>
<cfset myVariable_width = array_tente_height[1]>
--->

<cfset i=0>

<cfloop query="#get_product_height_tente#">
    <cfset kontrol_tente_height = array_tente_height[currentRow].toList()>
</cfloop>

<cfloop query="#get_product_width_tente#">
    <cfset kontrol_tente_width = array_tente_width[currentRow].toList()>
</cfloop>

<cfscript>
    searchValue = 256;
    closestValue = 99999;  // bu değer arama değerine çok uzak olacak şekilde başlatılır.

    for (i = 1; i <= ArrayLen(array_tente_width); i++) {
    deger_ = array_tente_width[i].toList();
    diff = Abs(deger_ - searchValue);
    if (diff < closestValue) {
        closestValue = diff;
        closestIndex = i;
    }
    }
    writeOutput("En yakın genişlik: " & array_tente_width[closestIndex].toList());
</cfscript>

<cfscript>
    searchValue = 52;
    closestValue = 99999;  // bu değer arama değerine çok uzak olacak şekilde başlatılır.

    for (i = 1; i <= ArrayLen(array_tente_height); i++) {
    deger_ = array_tente_height[i].toList();
    diff = Abs(deger_ - searchValue);
    if (diff < closestValue) {
        closestValue = diff;
        closestIndex = i;
    }
    }
    writeOutput("En yakın yükseklik: " & array_tente_height[closestIndex].toList());
</cfscript>

<!---
<cfdump var="#get_product_height_tente#">
--->

<script>
    const cars = [15];
    for (let i = 0; i < cars.length; i++) {
        cars[i]= i;
    }
    for (let i = 0; i < cars.length; i++) {
        console.log(cars[i]);
    }
</script>
--->

<!---
<cfquery name="get_cephe" datasource="#dsn1#">
    select
        PROPERTY_ID
    from
        product_property
    where
        property = '1. Cephe Skyteks Soft'
</cfquery>

<cfquery name="get_acilim" datasource="#dsn1#">
    select
        PROPERTY_ID
    from
        product_property
    where
        property = '2. Açılım Skyteks Soft'
</cfquery>

<cfquery name="GET_STOCK" datasource="#DSN1#">
    SELECT
		SP.STOCK_ID
	FROM
		PRODUCT P
		LEFT JOIN STOCKS S ON S.PRODUCT_ID = P.PRODUCT_ID
		LEFT JOIN STOCK_PRP SP ON SP.STOCK_ID = S.STOCK_ID
	WHERE
		S.STOCK_STATUS = 1
		AND
		P.PRODUCT_ID IN(6634)
</cfquery>

<cfloop query="#get_stock#">
    <cfif len(stock_id)>
        <cfquery name="get_stock_ozellik_cephe" datasource="#dsn1#">
            SELECT
                PPD.PROPERTY_DETAIL AS CEPHE
            FROM
                STOCKS_PROPERTY SP
                LEFT JOIN PRODUCT_PROPERTY_DETAIL PPD ON PPD.PROPERTY_DETAIL_ID = SP.PROPERTY_DETAIL_ID
            WHERE 
                SP.STOCK_ID = #stock_id#
                AND
                SP.PROPERTY_ID = #get_cephe.property_id#
        </cfquery>
        
        <cfquery name="get_stock_ozellik_acilim" datasource="#dsn1#">
            SELECT
                PPD.PROPERTY_DETAIL AS ACILIM
            FROM
                STOCKS_PROPERTY SP
                LEFT JOIN PRODUCT_PROPERTY_DETAIL PPD ON PPD.PROPERTY_DETAIL_ID = SP.PROPERTY_DETAIL_ID
            WHERE 
                SP.STOCK_ID = #stock_id#
                AND
                SP.PROPERTY_ID = #get_acilim.property_id#
        </cfquery>
    
        <cfset kelime = '#get_stock_ozellik_acilim.acilim##get_stock_ozellik_cephe.cephe#'>
        <cfoutput>
            stock id : #stock_id# - #kelime#
        </cfoutput>

        <cfif len(kelime)>
            <cfquery name="upd_prp" datasource="#DSN1#">
                UPDATE 
                    STOCK_PRP
                SET
                    PRP = '#kelime#'
                WHERE
                    STOCK_ID = #stock_id#
            </cfquery>
        </cfif>
    </cfif>
</cfloop>

<!---
<cfabort>
<cfloop query="#get_stock#">
    <cfquery name="get_cephe" datasource="#DSN1#">
        SELECT
            *
        FROM
            STOCKS_PROPERTY SP
            LEFT JOIN 
        WHERE 
            STOCK_ID = #stock_id#
    </cfquery>
</cfloop>
--->

--->