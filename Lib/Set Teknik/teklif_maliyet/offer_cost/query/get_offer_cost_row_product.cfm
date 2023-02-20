<!---
    Desc : Teklif Maliyet detay sayfası için oluşturulmuştur. Hizmet, Opsiyon ve Alternatif ürünler hariç tüm ürünleri listeler (gruplu grupsuz).
--->

<cfquery name="GET_OFFER_COST_ROW_PRODUCT" datasource="#DSN3#">
     SELECT
        OCR.PRODUCT_ID,
        OCR.PRODUCT_NAME,
        OCR.PRODUCT_UNIT,
        OCR.QUANTITY,
        MONEY,
        OCR.PRICE_EXWORK,
        OCR.DISCOUNT,
        OCR.NET_PRICE_EXWORK,
        OCR.UNIT_COST,
        OCR.TOTAL_COST,
        OCR.UNIT_OFFER,
        OCR.TOTAL_OFFER,
        OCR.EXPORT_FACTOR,
        OCR.OFFER_FACTOR,
        OCR.PROFIT_MARGIN,
        OCR.IS_ALTERNATIVE,
        OCR.PROVISION_TIME,
        OCR.ROW_GROUP_NAME AS ROW_GROUP_NAME,
        OCR.ROW_GROUP_QUANTITY AS ROW_GROUP_QUANTITY,
        OCR.RECORD_DATE,
        OCR.RECORD_EMP,
        OCR.UPDATE_DATE,
        OCR.UPDATE_EMP,
        PC.PRODUCT_CAT AS PRODUCT_CAT,
        PC.PRODUCT_CATID,
        PB.BRAND_NAME AS BRAND_NAME,
        PBM.MODEL_NAME AS MODEL_NAME
    FROM
        OFFER_COST_ROW OCR
        LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
        LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS PB ON PB.BRAND_ID = P.BRAND_ID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS_MODEL PBM ON PBM.MODEL_ID = P.SHORT_CODE_ID
    WHERE
        OCR.OFFER_COST_ID = <cfif isDefined('attributes.offer_cost_id') and len(attributes.offer_cost_id)>#attributes.offer_cost_id#<cfelseif isDefined('offer_cost_id_output') and len(offer_cost_id_output)>#offer_cost_id_output#</cfif>
        AND
        OCR.ROW_GROUP_NAME <> 'Hizmet' /* hizmetleri dahil etme */
        AND
        OCR.IS_ALTERNATIVE <> 2 /* opsiyon ürünleri dahil etme */
        AND
        OCR.IS_ALTERNATIVE <> 3 /* alternatif ürünleri dahil etme */
    ORDER BY
        OCR.ROW_GROUP_NAME ASC
</cfquery>

<cfquery name="GET_OFFER_COST_ROW_PRODUCT_NON_GROUP" datasource="#DSN3#">
     SELECT
        OCR.PRODUCT_ID,
        OCR.PRODUCT_NAME,
        OCR.PRODUCT_UNIT,
        OCR.QUANTITY,
        MONEY,
        OCR.PRICE_EXWORK,
        OCR.DISCOUNT,
        OCR.NET_PRICE_EXWORK,
        OCR.UNIT_COST,
        OCR.TOTAL_COST,
        OCR.UNIT_OFFER,
        OCR.TOTAL_OFFER,
        OCR.EXPORT_FACTOR,
        OCR.OFFER_FACTOR,
        OCR.PROFIT_MARGIN,
        OCR.IS_ALTERNATIVE,
        OCR.PROVISION_TIME,
        OCR.ROW_GROUP_NAME AS ROW_GROUP_NAME,
        OCR.ROW_GROUP_QUANTITY AS ROW_GROUP_QUANTITY,
        OCR.RECORD_DATE,
        OCR.RECORD_EMP,
        OCR.UPDATE_DATE,
        OCR.UPDATE_EMP,
        PC.PRODUCT_CAT AS PRODUCT_CAT,
        PC.PRODUCT_CATID,
        PB.BRAND_NAME AS BRAND_NAME,
        PBM.MODEL_NAME AS MODEL_NAME
    FROM
        OFFER_COST_ROW OCR
        LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
        LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS PB ON PB.BRAND_ID = P.BRAND_ID
        LEFT JOIN #DSN1#.PRODUCT_BRANDS_MODEL PBM ON PBM.MODEL_ID = P.SHORT_CODE_ID
    WHERE
        OCR.OFFER_COST_ID = <cfif isDefined('attributes.offer_cost_id') and len(attributes.offer_cost_id)>#attributes.offer_cost_id#<cfelseif isDefined('offer_cost_id_output') and len(offer_cost_id_output)>#offer_cost_id_output#</cfif>
        AND
        OCR.ROW_GROUP_NAME IS NULL <!--- grupsuz ürünler --->
        AND
        OCR.IS_ALTERNATIVE <> 2
        AND
        OCR.IS_ALTERNATIVE <> 3
    ORDER BY
        OCR.ROW_GROUP_NAME ASC
</cfquery>