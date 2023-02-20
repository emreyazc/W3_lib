<cfinclude template="get_offer_cost.cfm">
<cfinclude template="get_offer_cost_row.cfm">
<!---
<cfinclude template="get_offer_cost_row_only_product.cfm">
--->
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
	ticari_mal_total_eur_group_offer = 0;
</cfscript>

<cfquery name="GET_OFFER_COST_SYSTEM" datasource="#DSN1#">
	SELECT PRODUCT_NAME FROM PRODUCT WHERE PRODUCT_ID = #get_offer_cost.product_id#
</cfquery>

<cfset system_name = get_offer_cost_system.product_name>

<cfif isDefined("url.to_type") and url.to_type eq 1> <!--- MAMULE TEKLİF OLUŞTURMAK İÇİN --->

		<cfquery name="GET_MAMUL" datasource="#DSN1#">
			SELECT
				P.PRODUCT_NAME,
				PS.PRICE,
				PS.PRICE_KDV,
				PS.IS_KDV,
				PS.MONEY,
				PS.UNIT_ID,
				PU.MAIN_UNIT,
				PU.MAIN_UNIT_ID
			FROM
				PRODUCT P
				LEFT JOIN PRICE_STANDART PS ON PS.PRODUCT_ID = P.PRODUCT_ID
				LEFT JOIN PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = PS.UNIT_ID
			WHERE
				P.PRODUCT_ID = #get_offer_cost.product_id#
				AND PS.PURCHASESALES =1
		</cfquery>

		<cfscript>
			mamul_doviz_price = #get_mamul.price#;
			mamul_tl_price = #get_mamul.price#*eur_price;
			mamul_tax_price = mamul_doviz_price*1.18;
			mamul_tax = mamul_tax_price-mamul_tl_price;
		</cfscript>

		<cfquery name="get_gen_paper" datasource="#dsn3#">
			SELECT 
        	    * 
            FROM 
    	        GENERAL_PAPERS 
            WHERE 
	            ZONE_TYPE = 0 AND PAPER_TYPE = 1
		</cfquery>
		<cfset paper_code = evaluate('get_gen_paper.OFFER_NO')>
		<cfset paper_number = evaluate('get_gen_paper.OFFER_NUMBER') +1>
		<cfset paper_full = '#paper_code#-#paper_number#'>

        <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
			UPDATE
				GENERAL_PAPERS
			SET
				OFFER_NUMBER = OFFER_NUMBER+1
			WHERE
				PAPER_TYPE = 1 AND
				ZONE_TYPE = 0
		</cfquery>

        <cfquery name="ADD_OFFER" datasource="#DSN3#" result="GET_MAX_OFFER">
			INSERT INTO
				OFFER
			(
				OFFER_NUMBER,
				OFFER_STATUS,
				OFFER_CURRENCY,
				PURCHASE_SALES,
				OFFER_ZONE,
				OFFER_HEAD,
				OFFER_DETAIL,
				COMPANY_ID,
				PARTNER_ID,
				STARTDATE,
				FINISHDATE,
				DELIVERDATE,
				NETTOTAL,
				PRICE,
				TAX,
				OTV_TOTAL,
				SA_DISCOUNT,
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				PAYMETHOD,
				IS_PROCESSED,
				IS_PARTNER_ZONE,
				IS_PUBLIC_ZONE,
				INCLUDED_KDV,
				OFFER_STAGE,
				SHIP_METHOD,
				SHIP_ADDRESS,
				PROJECT_ID,
				OFFER_DATE,
				OFFER_FINISHDATE,
				REF_NO,
				CITY_ID,
				COUNTY_ID,
				COUNTRY_ID,
				SALES_EMP_ID,
				SHIP_ADDRESS_ID,
				RECORD_MEMBER,
				RECORD_DATE,
				RECORD_IP,
				PROBABILITY,
				OFFER_COST_ID,
				OUR_REF_NO
			)
			VALUES 
			(
				'#get_offer_cost.offer_cost_head#',
				1, <!--- status --->
				-1, <!--- currency --->
				1,
				0, <!--- offer_zone --->
				'#get_offer_cost.offer_cost_head#', <!--- offer_head --->
				'SİSTEM TEKLİF TM-#get_offer_cost.offer_cost_id#', <!--- offer_detail --->
				#get_offer_cost.company_id#,
				#get_offer_cost.partner_id#,
				#now()# <!---STARTDATE--->,
				#now()# <!---FINISHDATE--->,
				#now()# <!---DELIVERDATE--->,
				#mamul_tl_price#<!---NETTOTAL --->,
				#mamul_tl_price#<!---PRICE --->,
				18<!---TAX --->,
				0<!---OTV_TOTAL --->,
				0,
				'EUR', <!---OTHER_MONEY --->
				#mamul_doviz_price#, <!--- OTHER_MONEY_VALUE --->
				25, <!--- paymethod --->
				0,
				0,
				0,
				0,
				385, <!---OFFER_STAGE --->
				9, <!--- SHIP_METHOD --->
				NULL, <!--- SHIP_ADDRESS --->
				<cfif len(get_offer_cost.project_id)>#get_offer_cost.project_id#<cfelse>NULL</cfif>,
				#now()#,
				#now()#,
				NULL,
				NULL<!---CITY_ID --->,
				NULL<!---COUNTY_ID --->,
				NULL<!---COUNTRY_ID --->,
				<cfif isDefined('get_offer_cost.sales_emp') and len(#get_offer_cost.sales_emp#)>#get_offer_cost.sales_emp#<cfelse>NULL</cfif>,
				NULL<!---SHIP_ADDRESS_ID--->,
				#session.ep.userid#,
				#now()#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
				100,
				#attributes.offer_cost_id#,
				'#get_offer_cost.offer_cost_head#'
			)
		</cfquery>
		<cfset GET_MAX_OFFER.max_id = GET_MAX_OFFER.IDENTITYCOL>

		<cfquery name="ADD_OFFER_MONEY" datasource="#DSN3#">
			INSERT INTO 
				OFFER_MONEY
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
					#get_max_offer.max_id#,
					1,
					1,
					0
				),
				(
					'USD',
					#get_max_offer.max_id#,
					#usd_price#,
					1,
					0
				),
				(
					'GBP',
					#get_max_offer.max_id#,
					#gbp_price#,
					1,
					0
				),
				(
					'EUR',
					#get_max_offer.max_id#,
					#eur_price#,
					1,
					1
				)
		</cfquery>

		<cfset wrk_row_id = 'holo'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>

		<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
			INSERT INTO
				OFFER_ROW
			(
				OFFER_ID,
				PRODUCT_ID,
				STOCK_ID,
				QUANTITY,
				UNIT,
				UNIT_ID,
				PRICE,
				PRICE_OTHER,
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
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				NET_MALIYET,
				MARJ,
				PROM_COST,
				DISCOUNT_COST,
				IS_PROMOTION,
				EXTRA_PRICE_OTHER_TOTAL,
				EXTRA_PRICE,
				EXTRA_PRICE_TOTAL,
				OTV_ORAN,
				OTVTOTAL,
				EXTRA_COST,
				LIST_PRICE,
				NUMBER_OF_INSTALLMENT,
				AMOUNT2,
				EK_TUTAR_PRICE,
				WRK_ROW_ID,
				BSMV_RATE,
				BSMV_AMOUNT,
				BSMV_CURRENCY,
				OIV_RATE,
				OIV_AMOUNT,
				TEVKIFAT_RATE,
				TEVKIFAT_AMOUNT
			)
			VALUES
			(
				#get_max_offer.max_id#,
				#get_offer_cost.product_id#,
				#get_offer_cost.stock_id#,
				1,
				'#get_mamul.main_unit#',
				#get_mamul.main_unit_id#,
				#mamul_tl_price#,
				#mamul_doviz_price#,
				18,
				'#get_mamul.product_name#',
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				'EUR',
				#mamul_doviz_price#,
				0, <!--- NET_MALIYET --->
				0, <!--- MARJ --->
				0,
				0,
				0,
				0, <!--- EXTRA_PRICE_OTHER_TOTAL --->
				0, <!--- EXTRA_PRICE --->
				0, <!--- EXTRA_PRICE_TOTAL --->
				0, <!--- OTV_ORAN --->
				0, <!--- OTVTOTAL --->
				0, <!--- EXTRA_COST --->
				#mamul_doviz_price# <!--- LIST_PRICE --->,
				0,
				1, <!--- AMOUNT2 --->
				0, <!--- EK_TUTAR_PRICE --->
				'#wrk_row_id#', <!--- WRK_ROW_İD --->
				0,
				0,
				0,
				0,
				0,
				0,
				0
			)
		</cfquery>

		<cfquery name="UPD_OFFER_COST_OFFER" datasource="#DSN3#">
			UPDATE OFFER_COST
			SET OFFER_ID = #get_max_offer.max_id#, IS_OFFER = 1
			WHERE OFFER_COST_ID = #attributes.offer_cost_id#
		</cfquery>

	<script type="text/javascript">
    	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_max_offer.max_id#</cfoutput>";
    </script>
	<!---<cfinclude template="../../actions/sales/offer_total_check.cfm"> iptal--->
</cfif>

<cfscript>
	total_tl_group_offer = 0;
	total_eur_group_offer = 0;
</cfscript>

<cfif isDefined("url.to_type") and url.to_type eq 2> <!--- YARI MAMUL TEKLİFİ OLUŞTURMAK İÇİN --->
	<cfquery name="GET_OFFER_COST_SEMI_PRODUCT" datasource="#DSN3#">
		SELECT
			OGP.PRODUCT_ID AS PRODUCT_ID,
			OGP.STOCK_ID AS STOCK_ID,
			OGP.GROUP_QUANTITY AS GROUP_QUANTITY,
			OGP.GROUP_MONEY AS GROUP_MONEY,
			P.PRODUCT_NAME AS PRODUCT_NAME,
			PS.PRICE AS PRICE,
			PS.PRICE_KDV,
			PS.IS_KDV,
			PS.MONEY AS MONEY,
			PS.UNIT_ID AS UNIT_ID,
			PU.MAIN_UNIT AS MAIN_UNIT,
			PU.MAIN_UNIT_ID AS MAIN_UNIT_ID
		FROM
			OFFER_COST_GROUP_PRODUCT OGP
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OGP.PRODUCT_ID
			LEFT JOIN #DSN1#.PRICE_STANDART PS ON PS.PRODUCT_ID = P.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = PS.UNIT_ID
		WHERE
			OGP.OFFER_COST_ID = #attributes.offer_cost_id#
			AND
			PS.PURCHASESALES =1
			AND
			OGP.OFFER_COST_GROUP IS NOT NULL
	</cfquery>

	<cfoutput query="GET_OFFER_COST_SEMI_PRODUCT">
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = (price*usd_price)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = (price*gbp)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price_q = (price);
				yari_mamul_tl_price = (price*eur_price);
			}
				//total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				total_tl_group_offer = total_tl_group_offer+yari_mamul_tl_price;
		</cfscript>
	</cfoutput>

	<cfscript>
		total_eur_group_offer = total_tl_group_offer/eur_price;
	</cfscript>
	
	<cfquery name="get_gen_paper" datasource="#dsn3#">
		SELECT
    	    * 
        FROM 
            GENERAL_PAPERS
        WHERE 
	        ZONE_TYPE = 0 AND PAPER_TYPE = 1
	</cfquery>
	<cfset paper_code = evaluate('get_gen_paper.OFFER_NO')>
	<cfset paper_number = evaluate('get_gen_paper.OFFER_NUMBER') +1>
	<cfset paper_full = '#paper_code#-#paper_number#'>

    <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
		UPDATE
			GENERAL_PAPERS
		SET
			OFFER_NUMBER = OFFER_NUMBER+1
		WHERE
			PAPER_TYPE = 1 AND
			ZONE_TYPE = 0
	</cfquery>

	<cfquery name="ADD_OFFER" datasource="#DSN3#" result="GET_MAX_OFFER">
		INSERT INTO
			OFFER
		(
			OFFER_NUMBER,
			OFFER_STATUS,
			OFFER_CURRENCY,
			PURCHASE_SALES,
			OFFER_ZONE,
			OFFER_HEAD,
			OFFER_DETAIL,
			COMPANY_ID,
			PARTNER_ID,
			STARTDATE,
			FINISHDATE,
			DELIVERDATE,
			NETTOTAL,
			PRICE,
			TAX,
			OTV_TOTAL,
			SA_DISCOUNT,
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
			PAYMETHOD,
			IS_PROCESSED,
			IS_PARTNER_ZONE,
			IS_PUBLIC_ZONE,
			INCLUDED_KDV,
			OFFER_STAGE,
			SHIP_METHOD,
			SHIP_ADDRESS,
			PROJECT_ID,
			OFFER_DATE,
			OFFER_FINISHDATE,
			REF_NO,
			CITY_ID,
			COUNTY_ID,
			COUNTRY_ID,
			SALES_EMP_ID,
			SHIP_ADDRESS_ID,
			RECORD_MEMBER,
			RECORD_DATE,
			RECORD_IP,
			PROBABILITY,
			OFFER_COST_ID,
			OUR_REF_NO
		)
		VALUES 
		(
			'#get_offer_cost.offer_cost_head#',
			1, <!--- status --->
			-1, <!--- currency --->
			1,
			0, <!--- offer_zone --->
			'#get_offer_cost.offer_cost_head#', <!--- offer_head --->
			'Teklif TM-#get_offer_cost.offer_cost_id#', <!--- offer_detail --->
			#get_offer_cost.company_id#,
			#get_offer_cost.partner_id#,
			#now()# <!---STARTDATE--->,
			#now()# <!---FINISHDATE--->,
			#now()# <!---DELIVERDATE--->,
			#total_tl_group_offer#<!---NETTOTAL --->,
			#total_tl_group_offer#<!---PRICE --->,
			18<!---TAX --->,
			0<!---OTV_TOTAL --->,
			0,
			'EUR', <!---OTHER_MONEY --->
			#total_eur_group_offer#, <!--- OTHER_MONEY_VALUE --->
			25, <!--- paymethod --->
			0,
			0,
			0,
			0,
			385, <!---OFFER_STAGE --->
			9, <!--- SHIP_METHOD --->
			NULL, <!--- SHIP_ADDRESS --->
			<cfif len(get_offer_cost.project_id)>#get_offer_cost.project_id#<cfelse>NULL</cfif>,
			#now()#,
			#now()#,
			NULL,
			NULL<!---CITY_ID --->,
			NULL<!---COUNTY_ID --->,
			NULL<!---COUNTRY_ID --->,
			<cfif isDefined('get_offer_cost.sales_emp') and len(#get_offer_cost.sales_emp#)>#get_offer_cost.sales_emp#<cfelse>NULL</cfif>,
			NULL<!---SHIP_ADDRESS_ID--->,
			#session.ep.userid#,
			#now()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			100,
			#attributes.offer_cost_id#,
			'#get_offer_cost.offer_cost_head#'
		)
	</cfquery>
	<cfset GET_MAX_OFFER.max_id = GET_MAX_OFFER.IDENTITYCOL>

	<cfquery name="ADD_OFFER_MONEY" datasource="#DSN3#">
		INSERT INTO 
			OFFER_MONEY
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
				#get_max_offer.max_id#,
				1,
				1,
				0
			),
			(
				'USD',
				#get_max_offer.max_id#,
				#usd_price#,
				1,
				0
			),
			(
				'GBP',
				#get_max_offer.max_id#,
				#gbp_price#,
				1,
				0
			),
			(
				'EUR',
				#get_max_offer.max_id#,
				#eur_price#,
				1,
				1
			)
	</cfquery>

	<cfloop query="#GET_OFFER_COST_SEMI_PRODUCT#">
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price = yari_mamul_tl_price;
				yari_mamul_doviz_price_q = yari_mamul_tl_price;
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = (price*usd_price)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/usd_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price*usd_price);
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = (price*gbp_price)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/gbp_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price*gbp_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price_q = (price);
				yari_mamul_tl_price = price*eur_price;
			}
				//total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				//total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>

		<!---
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = yari_mamul_tl_price;
			}
			else if(MONEY eq "USD"){
				yari_mamul_doviz_price = yari_mamul_tl_price/usd_price;
			}
			else if(MONEY eq "GBP"){
				yari_mamul_doviz_price = yari_mamul_tl_price/gbp_price;
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = yari_mamul_tl_price/eur_price;
			}
		</cfscript>
		--->

		<cfset wrk_row_id = 'holo'&'#currentRow#'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>

		<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
			INSERT INTO
				OFFER_ROW
			(
				OFFER_ID,
				PRODUCT_ID,
				STOCK_ID,
				QUANTITY,
				UNIT,
				UNIT_ID,
				PRICE,
				PRICE_OTHER,
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
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				NET_MALIYET,
				MARJ,
				PROM_COST,
				DISCOUNT_COST,
				IS_PROMOTION,
				EXTRA_PRICE_OTHER_TOTAL,
				EXTRA_PRICE,
				EXTRA_PRICE_TOTAL,
				OTV_ORAN,
				OTVTOTAL,
				EXTRA_COST,
				LIST_PRICE,
				NUMBER_OF_INSTALLMENT,
				AMOUNT2,
				EK_TUTAR_PRICE,
				WRK_ROW_ID,
				BSMV_RATE,
				BSMV_AMOUNT,
				BSMV_CURRENCY,
				OIV_RATE,
				OIV_AMOUNT,
				TEVKIFAT_RATE,
				TEVKIFAT_AMOUNT
			)
			VALUES
			(
				#get_max_offer.max_id#,
				#get_offer_cost_semi_product.product_id#,
				#get_offer_cost_semi_product.stock_id#,
				#GROUP_QUANTITY#,
				'#main_unit#',
				#get_offer_cost_semi_product.main_unit_id#,
				#yari_mamul_tl_price#,
				#yari_mamul_doviz_price#,
				18,
				'#product_name#',
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				'#group_money#',
				#yari_mamul_doviz_price#,
				0, <!--- NET_MALIYET --->
				0, <!--- MARJ --->
				0,
				0,
				0,
				0, <!--- EXTRA_PRICE_OTHER_TOTAL --->
				0, <!--- EXTRA_PRICE --->
				0, <!--- EXTRA_PRICE_TOTAL --->
				0, <!--- OTV_ORAN --->
				0, <!--- OTVTOTAL --->
				0, <!--- EXTRA_COST --->
				#yari_mamul_doviz_price# <!--- LIST_PRICE --->,
				0,
				1, <!--- AMOUNT2 --->
				0, <!--- EK_TUTAR_PRICE --->
				'#wrk_row_id#', <!--- WRK_ROW_İD --->
				0,
				0,
				0,
				0,
				0,
				0,
				0
			)
		</cfquery>
	</cfloop>
	<cfquery name="UPD_OFFER_COST_OFFER" datasource="#DSN3#">
		UPDATE OFFER_COST
		SET SEMI_PRODUCT_OFFER_ID = #get_max_offer.max_id#, IS_OFFER = 1
		WHERE OFFER_COST_ID = #attributes.offer_cost_id#
		</cfquery>
	<script type="text/javascript">
    	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_max_offer.max_id#</cfoutput>";
    </script>
	<!---<cfinclude template="../../actions/sales/offer_total_check.cfm">--->
</cfif>

<cfif isDefined("url.to_type") and url.to_type eq 3> <!--- ÜRÜN BAZINDA TEKLİF OLUŞTURMAK İÇİN --->

	<cfquery name="get_offer_cost_row_only_product" datasource="#DSN3#">
		SELECT
			OCR.PRODUCT_ID,
			OCR.STOCK_ID,
			OCR.UNIT_OFFER,
			OCR.PRODUCT_NAME,

			OCR.QUANTITY,
			OCR.MONEY,
			PU.MAIN_UNIT_ID,
			PU.MAIN_UNIT
		FROM
			OFFER_COST_ROW OCR
			LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_ID = OCR.PRODUCT_ID
		WHERE
			OCR.OFFER_COST_ID = #attributes.offer_cost_id#
			AND
			OCR.IS_ALTERNATIVE <> 2
			AND
			PU.IS_MAIN = 1
	</cfquery>

	<cfoutput query="get_offer_cost_row_only_product">
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = unit_offer;
				yari_mamul_doviz_price = (unit_offer/eur_price)*QUANTITY;
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = unit_offer*usd_price;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = unit_offer*gbp_price;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = (unit_offer);
				yari_mamul_tl_price = unit_offer*eur_price;
			}
				total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>
	</cfoutput>

	<cfquery name="get_gen_paper" datasource="#dsn3#">
		SELECT 
    	    *
        FROM 
            GENERAL_PAPERS 
        WHERE 
	        ZONE_TYPE = 0 AND PAPER_TYPE = 1
	</cfquery>

	<cfset paper_code = evaluate('get_gen_paper.OFFER_NO')>
	<cfset paper_number = evaluate('get_gen_paper.OFFER_NUMBER') +1>
	<cfset paper_full = '#paper_code#-#paper_number#'>

    <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
		UPDATE
			GENERAL_PAPERS
		SET
			OFFER_NUMBER = OFFER_NUMBER+1
		WHERE
			PAPER_TYPE = 1 AND
			ZONE_TYPE = 0
	</cfquery>
	
	<cfquery name="ADD_OFFER" datasource="#DSN3#" result="GET_MAX_OFFER">
		INSERT INTO
			OFFER
		(
			OFFER_NUMBER,
			OFFER_STATUS,
			OFFER_CURRENCY,
			PURCHASE_SALES,
			OFFER_ZONE,
			OFFER_HEAD,
			OFFER_DETAIL,
			COMPANY_ID,
			PARTNER_ID,
			STARTDATE,
			FINISHDATE,
			DELIVERDATE,
			NETTOTAL,
			PRICE,
			TAX,
			OTV_TOTAL,
			SA_DISCOUNT,
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
			PAYMETHOD,
			IS_PROCESSED,
			IS_PARTNER_ZONE,
			IS_PUBLIC_ZONE,
			INCLUDED_KDV,
			OFFER_STAGE,
			SHIP_METHOD,
			SHIP_ADDRESS,
			PROJECT_ID,
			OFFER_DATE,
			OFFER_FINISHDATE,
			REF_NO,
			CITY_ID,
			COUNTY_ID,
			COUNTRY_ID,
			SALES_EMP_ID,
			SHIP_ADDRESS_ID,
			RECORD_MEMBER,
			RECORD_DATE,
			RECORD_IP,
			PROBABILITY,
			OFFER_COST_ID,
			OUR_REF_NO
		)
		VALUES 
		(
			'#get_offer_cost.offer_cost_head#',
			1, <!--- status --->
			-1, <!--- currency --->
			1,
			0, <!--- offer_zone --->
			'#get_offer_cost.offer_cost_head#', <!--- offer_head --->
			'KÜMÜLATİF TEKLİF TM-#get_offer_cost.offer_cost_id#', <!--- offer_detail --->
			#get_offer_cost.company_id#,
			#get_offer_cost.partner_id#,
			#now()# <!---STARTDATE--->,
			#now()# <!---FINISHDATE--->,
			#now()# <!---DELIVERDATE--->,
			#total_tl_group_offer#<!---NETTOTAL --->,
			#total_tl_group_offer#<!---PRICE --->,
			18<!---TAX --->,
			0<!---OTV_TOTAL --->,
			0,
			'EUR', <!---OTHER_MONEY --->
			#total_eur_group_offer#, <!--- OTHER_MONEY_VALUE --->
			25, <!--- paymethod --->
			0,
			0,
			0,
			0,
			385, <!---OFFER_STAGE --->
			9, <!--- SHIP_METHOD --->
			NULL, <!--- SHIP_ADDRESS --->
			<cfif len(get_offer_cost.project_id)>#get_offer_cost.project_id#<cfelse>NULL</cfif>,
			#now()#,
			#now()#,
			NULL,
			NULL<!---CITY_ID --->,
			NULL<!---COUNTY_ID --->,
			NULL<!---COUNTRY_ID --->,
			<cfif isDefined('get_offer_cost.sales_emp') and len(#get_offer_cost.sales_emp#)>#get_offer_cost.sales_emp#<cfelse>NULL</cfif>,
			NULL<!---SHIP_ADDRESS_ID--->,
			#session.ep.userid#,
			#now()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			100,
			#attributes.offer_cost_id#,
			'#get_offer_cost.offer_cost_head#'
		)
	</cfquery>
	<cfset GET_MAX_OFFER.max_id = GET_MAX_OFFER.IDENTITYCOL>

	<cfquery name="ADD_OFFER_MONEY" datasource="#DSN3#">
		INSERT INTO 
			OFFER_MONEY
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
				#get_max_offer.max_id#,
				1,
				1,
				0
			),
			(
				'USD',
				#get_max_offer.max_id#,
				#usd_price#,
				1,
				0
			),
			(
				'GBP',
				#get_max_offer.max_id#,
				#gbp_price#,
				1,
				0
			),
			(
				'EUR',
				#get_max_offer.max_id#,
				#eur_price#,
				1,
				1
			)
	</cfquery>

	<cfloop query="#get_offer_cost_row_only_product#">
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = unit_offer;
				yari_mamul_doviz_price = (unit_offer/eur_price);
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = unit_offer*usd_price;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = unit_offer*gbp_price;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = (unit_offer);
				yari_mamul_tl_price = unit_offer*eur_price;
			}
				total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>

		<cfset wrk_row_id = 'holo'&'#currentRow#'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>

		<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
			INSERT INTO
				OFFER_ROW
			(
				OFFER_ID,
				PRODUCT_ID,
				STOCK_ID,
				QUANTITY,
				UNIT,
				UNIT_ID,
				PRICE,
				PRICE_OTHER,
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
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				NET_MALIYET,
				MARJ,
				PROM_COST,
				DISCOUNT_COST,
				IS_PROMOTION,
				EXTRA_PRICE_OTHER_TOTAL,
				EXTRA_PRICE,
				EXTRA_PRICE_TOTAL,
				OTV_ORAN,
				OTVTOTAL,
				EXTRA_COST,
				LIST_PRICE,
				NUMBER_OF_INSTALLMENT,
				AMOUNT2,
				EK_TUTAR_PRICE,
				WRK_ROW_ID,
				BSMV_RATE,
				BSMV_AMOUNT,
				BSMV_CURRENCY,
				OIV_RATE,
				OIV_AMOUNT,
				TEVKIFAT_RATE,
				TEVKIFAT_AMOUNT
			)
			VALUES
			(
				#get_max_offer.max_id#,
				#get_offer_cost_row_only_product.product_id#,
				#get_offer_cost_row_only_product.stock_id#,
				#quantity#,
				'#main_unit#',
				#get_offer_cost_row_only_product.main_unit_id#,
				#yari_mamul_tl_price#,
				#yari_mamul_doviz_price#, <!--- PRICE_OTHER --->
				18,
				'#product_name#',
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				'EUR',
				#yari_mamul_doviz_price#, <!--- OTHER_MONEY_VALUE ---->
				0, <!--- NET_MALIYET --->
				0, <!--- MARJ --->
				0,
				0,
				0,
				0, <!--- EXTRA_PRICE_OTHER_TOTAL --->
				0, <!--- EXTRA_PRICE --->
				0, <!--- EXTRA_PRICE_TOTAL --->
				0, <!--- OTV_ORAN --->
				0, <!--- OTVTOTAL --->
				0, <!--- EXTRA_COST --->
				#yari_mamul_doviz_price# <!--- LIST_PRICE --->,
				0,
				1, <!--- AMOUNT2 --->
				0, <!--- EK_TUTAR_PRICE --->
				'#wrk_row_id#', <!--- WRK_ROW_İD --->
				0,
				0,
				0,
				0,
				0,
				0,
				0
			)
		</cfquery>
	</cfloop>
	<cfquery name="UPD_OFFER_COST_OFFER" datasource="#DSN3#">
		UPDATE OFFER_COST
		SET CUMULATIVE_OFFER_ID = #get_max_offer.max_id#, IS_OFFER = 1
		WHERE OFFER_COST_ID = #attributes.offer_cost_id#
		</cfquery>
	<script type="text/javascript">
    	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_max_offer.max_id#</cfoutput>";
    </script>
	<!---<cfinclude template="../../actions/sales/offer_total_check.cfm">--->
</cfif>

<cfif isDefined("url.to_type") and url.to_type eq 4> <!--- YARI MAMUL VE TİCARİ MAL TEKLİFİ OLUŞTURMAK İÇİN --->
	<cfquery name="GET_OFFER_COST_SEMI_PRODUCT" datasource="#DSN3#">
		SELECT
			OGP.PRODUCT_ID AS PRODUCT_ID,
			OGP.STOCK_ID AS STOCK_ID,
			OGP.GROUP_QUANTITY AS GROUP_QUANTITY,
			OGP.GROUP_MONEY AS GROUP_MONEY,
			P.PRODUCT_NAME AS PRODUCT_NAME,
			PS.PRICE AS PRICE,
			PS.PRICE_KDV,
			PS.IS_KDV,
			PS.MONEY AS MONEY,
			PS.UNIT_ID AS UNIT_ID,
			PU.MAIN_UNIT AS MAIN_UNIT,
			PU.MAIN_UNIT_ID AS MAIN_UNIT_ID
		FROM
			OFFER_COST_GROUP_PRODUCT OGP
			LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OGP.PRODUCT_ID
			LEFT JOIN #DSN1#.PRICE_STANDART PS ON PS.PRODUCT_ID = P.PRODUCT_ID
			LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = PS.UNIT_ID
		WHERE
			OGP.OFFER_COST_ID = #attributes.offer_cost_id#
			AND
			PS.PURCHASESALES =1
			AND
			OGP.OFFER_COST_GROUP IS NOT NULL
	</cfquery>

	<cfoutput query="GET_OFFER_COST_SEMI_PRODUCT">
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = price;
				yari_mamul_doviz_price = (price/eur_price);
				yari_mamul_doviz_price_q = (price/eur_price)*GROUP_QUANTITY;
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = price*usd_price;
				yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price)*GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = price*gbp_price;
				yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price)*GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price_q = (price*GROUP_QUANTITY);
				yari_mamul_doviz_price = price;
				yari_mamul_tl_price = price*eur_price;
			}
				total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price_q;
				total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>
	</cfoutput>

	<!---buraya kadar olan kısım yarı mamülller --->

	<cfquery name="GET_OFFER_COST_ROW_NON_GROUP" datasource = "#DSN3#">
		SELECT
			OCR.PRODUCT_ID AS PRODUCT_ID,
			OCR.STOCK_ID AS STOCK_ID,
			OCR.QUANTITY AS QUANTITY,
			OCR.UNIT_OFFER AS UNIT_OFFER,
			OCR.MONEY AS MONEY,
			P.PRODUCT_NAME AS PRODUCT_NAME,
			PS.PRICE AS PRICE,
			PS.PRICE_KDV,
			PS.IS_KDV,
			PS.UNIT_ID AS UNIT_ID,
			PU.MAIN_UNIT AS MAIN_UNIT,
			PU.MAIN_UNIT_ID AS MAIN_UNIT_ID
		FROM
			OFFER_COST_ROW OCR
			LEFT JOIN PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
			LEFT JOIN PRICE_STANDART PS ON PS.PRODUCT_ID = P.PRODUCT_ID
			LEFT JOIN PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = PS.UNIT_ID
		WHERE
			OCR.OFFER_COST_ID = #attributes.offer_cost_id#
			AND
			OCR.IS_ALTERNATIVE <> 2 <!--- opsiyon ürünleri dahil değil --->
			AND
			OCR.IS_ALTERNATIVE <> 3 <!--- bakım ürünleri dahil değil --->
			AND
			PS.PURCHASESALES =1
			AND
			OCR.ROW_GROUP_NAME IS NULL
	</cfquery>

	<cfif get_offer_cost_row_non_group.recordCount gt 0>
		<cfoutput query="GET_OFFER_COST_ROW_NON_GROUP">
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
				else if(MONEY eq "GBP"){
					ticari_mal_tl_price = unit_offer*gbp_price;
					ticari_mal_doviz_price_q = (ticari_mal_tl_price/eur_price)*QUANTITY;
					ticari_mal_doviz_price = (ticari_mal_tl_price/eur_price);
				}
				else if(MONEY eq "EUR"){
					ticari_mal_doviz_price_q = (unit_offer*QUANTITY);
					ticari_mal_doviz_price = unit_offer;
					ticari_mal_tl_price = unit_offer*eur_price;
				}
					ticari_mal_total_eur_group_offer = ticari_mal_total_eur_group_offer+ticari_mal_doviz_price_q;
					ticari_mal_total_tl_group_offer = ticari_mal_total_eur_group_offer*eur_price;
			</cfscript>
		</cfoutput>
		<cfset total_tl_group_offer = total_tl_group_offer+ticari_mal_total_tl_group_offer> <!--- price --->
		<cfset yari_mamul_tl_price = yari_mamul_tl_price+ticari_mal_tl_price> <!--- nettotal --->
		<cfset yari_mamul_doviz_price = yari_mamul_doviz_price+ticari_mal_doviz_price> <!--- other_money_value --->
	</cfif>
	
	<cfquery name="get_gen_paper" datasource="#dsn3#">
		SELECT 
    	    * 
        FROM 
            GENERAL_PAPERS 
        WHERE 
	        ZONE_TYPE = 0 AND PAPER_TYPE = 1
	</cfquery>
	<cfset paper_code = evaluate('get_gen_paper.OFFER_NO')>
	<cfset paper_number = evaluate('get_gen_paper.OFFER_NUMBER') +1>
	<cfset paper_full = '#paper_code#-#paper_number#'>

    <cfquery name="SET_MAX_PAPER" datasource="#DSN3#">
		UPDATE
			GENERAL_PAPERS
		SET
			OFFER_NUMBER = OFFER_NUMBER+1
		WHERE
			PAPER_TYPE = 1 AND
			ZONE_TYPE = 0
	</cfquery>

	<cfquery name="ADD_OFFER" datasource="#DSN3#" result="GET_MAX_OFFER">
		INSERT INTO
			OFFER
		(
			OFFER_NUMBER,
			OFFER_STATUS,
			OFFER_CURRENCY,
			PURCHASE_SALES,
			OFFER_ZONE,
			OFFER_HEAD,
			OFFER_DETAIL,
			COMPANY_ID,
			PARTNER_ID,
			STARTDATE,
			FINISHDATE,
			DELIVERDATE,
			NETTOTAL,
			PRICE,
			TAX,
			OTV_TOTAL,
			SA_DISCOUNT,
			OTHER_MONEY,
			OTHER_MONEY_VALUE,
			PAYMETHOD,
			IS_PROCESSED,
			IS_PARTNER_ZONE,
			IS_PUBLIC_ZONE,
			INCLUDED_KDV,
			OFFER_STAGE,
			SHIP_METHOD,
			SHIP_ADDRESS,
			PROJECT_ID,
			OFFER_DATE,
			OFFER_FINISHDATE,
			REF_NO,
			CITY_ID,
			COUNTY_ID,
			COUNTRY_ID,
			SALES_EMP_ID,
			SHIP_ADDRESS_ID,
			RECORD_MEMBER,
			RECORD_DATE,
			RECORD_IP,
			PROBABILITY,
			OFFER_COST_ID,
			OUR_REF_NO
		)
		VALUES
		(
			'#get_offer_cost.offer_cost_head#',
			1, <!--- status --->
			-1, <!--- currency --->
			1,
			0, <!--- offer_zone --->
			'#get_offer_cost.offer_cost_head#', <!--- offer_head --->
			'YARI MAMUL VE TİCARI MAL TM-#get_offer_cost.offer_cost_id#', <!--- offer_detail --->
			#get_offer_cost.company_id#,
			#get_offer_cost.partner_id#,
			#now()# <!---STARTDATE--->,
			#now()# <!---FINISHDATE--->,
			#now()# <!---DELIVERDATE--->,
			#total_tl_group_offer#<!---NETTOTAL --->,
			#yari_mamul_tl_price#<!---PRICE --->,
			18<!---TAX --->,
			0<!---OTV_TOTAL --->,
			0,
			'EUR', <!---OTHER_MONEY --->
			#yari_mamul_doviz_price#, <!--- OTHER_MONEY_VALUE --->
			25, <!--- paymethod --->
			0,
			0,
			0,
			0,
			385, <!---OFFER_STAGE --->
			9, <!--- SHIP_METHOD --->
			NULL, <!--- SHIP_ADDRESS --->
			<cfif len(get_offer_cost.project_id)>#get_offer_cost.project_id#<cfelse>NULL</cfif>,
			#now()#,
			#now()#,
			NULL,
			NULL<!---CITY_ID --->,
			NULL<!---COUNTY_ID --->,
			NULL<!---COUNTRY_ID --->,
			<cfif isDefined('get_offer_cost.sales_emp') and len(#get_offer_cost.sales_emp#)>#get_offer_cost.sales_emp#<cfelse>NULL</cfif>,
			NULL<!---SHIP_ADDRESS_ID--->,
			#session.ep.userid#,
			#now()#,
			<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">,
			100,
			#attributes.offer_cost_id#,
			'#get_offer_cost.offer_cost_head#'
		)
	</cfquery>
	<cfset GET_MAX_OFFER.max_id = GET_MAX_OFFER.IDENTITYCOL>

	<cfquery name="ADD_OFFER_MONEY" datasource="#DSN3#">
		INSERT INTO 
			OFFER_MONEY
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
				#get_max_offer.max_id#,
				1,
				1,
				0
			),
			(
				'USD',
				#get_max_offer.max_id#,
				#usd_price#,
				1,
				0
			),
			(
				'GBP',
				#get_max_offer.max_id#,
				#gbp_price#,
				1,
				0
			),
			(
				'EUR',
				#get_max_offer.max_id#,
				#eur_price#,
				1,
				1
			)
	</cfquery>
	<!--- YARI MAMULLERİ SATIRLARA ATIYORUZ --->
	<cfloop query="#GET_OFFER_COST_SEMI_PRODUCT#">
		<!---
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = price;
				yari_mamul_doviz_price = (price/eur_price)*GROUP_QUANTITY;
				yari_mamul_doviz_price_q = (price/eur_price);
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = price*gbp_price;
				yari_mamul_doviz_price = (to_tl_group/eur_price)*GROUP_QUANTITY;
				yari_mamul_doviz_price_q = (to_tl_group/eur_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = price;
				yari_mamul_doviz_price_q = (price*GROUP_QUANTITY);
				yari_mamul_tl_price = price*eur_price;
			}
				total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>
		--->
		<cfscript>
			if(MONEY eq "TL"){
				yari_mamul_tl_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price = yari_mamul_tl_price;
				yari_mamul_doviz_price_q = yari_mamul_tl_price;
			}
			else if(MONEY eq "USD"){
				yari_mamul_tl_price = (price*usd_price)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/usd_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price*usd_price);
			}
			else if(MONEY eq "GBP"){
				yari_mamul_tl_price = (price*gbp_price)/GROUP_QUANTITY;
				yari_mamul_doviz_price = (yari_mamul_tl_price/gbp_price);
				yari_mamul_doviz_price_q = (yari_mamul_tl_price*gbp_price);
			}
			else if(MONEY eq "EUR"){
				yari_mamul_doviz_price = price/GROUP_QUANTITY;
				yari_mamul_doviz_price_q = (price);
				yari_mamul_tl_price = price*eur_price;
			}
				//total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
				//total_tl_group_offer = total_eur_group_offer*eur_price;
		</cfscript>

		<cfset wrk_row_id = 'holo'&'#currentRow#'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>

		<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
			INSERT INTO
				OFFER_ROW
			(
				OFFER_ID,
				PRODUCT_ID,
				STOCK_ID,
				QUANTITY,
				UNIT,
				UNIT_ID,
				PRICE,
				PRICE_OTHER,
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
				OTHER_MONEY,
				OTHER_MONEY_VALUE,
				NET_MALIYET,
				MARJ,
				PROM_COST,
				DISCOUNT_COST,
				IS_PROMOTION,
				EXTRA_PRICE_OTHER_TOTAL,
				EXTRA_PRICE,
				EXTRA_PRICE_TOTAL,
				OTV_ORAN,
				OTVTOTAL,
				EXTRA_COST,
				LIST_PRICE,
				NUMBER_OF_INSTALLMENT,
				AMOUNT2,
				EK_TUTAR_PRICE,
				WRK_ROW_ID,
				BSMV_RATE,
				BSMV_AMOUNT,
				BSMV_CURRENCY,
				OIV_RATE,
				OIV_AMOUNT,
				TEVKIFAT_RATE,
				TEVKIFAT_AMOUNT
			)
			VALUES
			(
				#get_max_offer.max_id#,
				#get_offer_cost_semi_product.product_id#,
				#get_offer_cost_semi_product.stock_id#,
				#GROUP_QUANTITY#,
				'#main_unit#',
				#get_offer_cost_semi_product.main_unit_id#,
				#yari_mamul_tl_price#,
				#yari_mamul_doviz_price#,
				18,
				'#product_name#',
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				0,
				'#group_money#',
				#yari_mamul_doviz_price#,
				0, <!--- NET_MALIYET --->
				0, <!--- MARJ --->
				0,
				0,
				0,
				0, <!--- EXTRA_PRICE_OTHER_TOTAL --->
				0, <!--- EXTRA_PRICE --->
				0, <!--- EXTRA_PRICE_TOTAL --->
				0, <!--- OTV_ORAN --->
				0, <!--- OTVTOTAL --->
				0, <!--- EXTRA_COST --->
				#yari_mamul_doviz_price# <!--- LIST_PRICE --->,
				0,
				1, <!--- AMOUNT2 --->
				0, <!--- EK_TUTAR_PRICE --->
				'#wrk_row_id#', <!--- WRK_ROW_İD --->
				0,
				0,
				0,
				0,
				0,
				0,
				0
			)
		</cfquery>
	</cfloop>

	<!--- TİCARI MALLARI SATIRLARA ATIYORUZ --->
	<cfif get_offer_cost_row_non_group.recordCount gt 0>
		<cfloop query="#GET_OFFER_COST_ROW_NON_GROUP#">
			<cfscript>
				if(MONEY eq "TL"){
					yari_mamul_tl_price = unit_offer;
					yari_mamul_doviz_price = (unit_offer/eur_price)*QUANTITY;
					yari_mamul_doviz_price_q = (unit_offer/eur_price);
				}
				else if(MONEY eq "USD"){
					yari_mamul_tl_price = unit_offer*usd_price;
					yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
					yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price);
				}
				else if(MONEY eq "GBP"){
					yari_mamul_tl_price = unit_offer*gbp_price;
					yari_mamul_doviz_price = (yari_mamul_tl_price/eur_price)*QUANTITY;
					yari_mamul_doviz_price_q = (yari_mamul_tl_price/eur_price);
				}
				if(MONEY eq "EUR"){
					yari_mamul_doviz_price = unit_offer;
					yari_mamul_doviz_price_q = (unit_offer*QUANTITY);
					yari_mamul_tl_price = unit_offer*eur_price;
				}
					total_eur_group_offer = total_eur_group_offer+yari_mamul_doviz_price;
					total_tl_group_offer = total_eur_group_offer*eur_price;
			</cfscript>

			<cfset wrk_row_id = 'holo'&'#currentRow#'&dateformat(now(),'YYYYMMDD')&timeformat(now(),'HHmmss')&'_#session.ep.userid#_'&round(rand()*1000)>

			<cfquery name="ADD_OFFER_ROW" datasource="#DSN3#">
				INSERT INTO
					OFFER_ROW
				(
					OFFER_ID,
					PRODUCT_ID,
					STOCK_ID,
					QUANTITY,
					UNIT,
					UNIT_ID,
					PRICE,
					PRICE_OTHER,
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
					OTHER_MONEY,
					OTHER_MONEY_VALUE,
					NET_MALIYET,
					MARJ,
					PROM_COST,
					DISCOUNT_COST,
					IS_PROMOTION,
					EXTRA_PRICE_OTHER_TOTAL,
					EXTRA_PRICE,
					EXTRA_PRICE_TOTAL,
					OTV_ORAN,
					OTVTOTAL,
					EXTRA_COST,
					LIST_PRICE,
					NUMBER_OF_INSTALLMENT,
					AMOUNT2,
					EK_TUTAR_PRICE,
					WRK_ROW_ID,
					BSMV_RATE,
					BSMV_AMOUNT,
					BSMV_CURRENCY,
					OIV_RATE,
					OIV_AMOUNT,
					TEVKIFAT_RATE,
					TEVKIFAT_AMOUNT
				)
				VALUES
				(
					#get_max_offer.max_id#,
					#get_offer_cost_row_non_group.product_id#,
					#get_offer_cost_row_non_group.stock_id#,
					#QUANTITY#,
					'#main_unit#',
					#get_offer_cost_row_non_group.main_unit_id#,
					#yari_mamul_tl_price#,
					#yari_mamul_doviz_price#,
					18,
					'#product_name#',
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					0,
					'EUR',
					#yari_mamul_doviz_price#,
					0, <!--- NET_MALIYET --->
					0, <!--- MARJ --->
					0,
					0,
					0,
					0, <!--- EXTRA_PRICE_OTHER_TOTAL --->
					0, <!--- EXTRA_PRICE --->
					0, <!--- EXTRA_PRICE_TOTAL --->
					0, <!--- OTV_ORAN --->
					0, <!--- OTVTOTAL --->
					0, <!--- EXTRA_COST --->
					#yari_mamul_doviz_price# <!--- LIST_PRICE --->,
					0,
					1, <!--- AMOUNT2 --->
					0, <!--- EK_TUTAR_PRICE --->
					'#wrk_row_id#', <!--- WRK_ROW_İD --->
					0,
					0,
					0,
					0,
					0,
					0,
					0
				)
			</cfquery>
		</cfloop>
	</cfif>
	<cfquery name="UPD_OFFER_COST_OFFER" datasource="#DSN3#">
		UPDATE OFFER_COST
		SET SEMI_AND_NON_GROUP_OFFER_ID = #get_max_offer.max_id#, IS_OFFER = 1
		WHERE OFFER_COST_ID = #attributes.offer_cost_id#
		</cfquery>
	<script type="text/javascript">
    	window.location.href="<cfoutput>#request.self#?fuseaction=sales.list_offer&event=upd&offer_id=#get_max_offer.max_id#</cfoutput>";
    </script>
	<!---<cfinclude template="../../actions/sales/offer_total_check.cfm">--->
</cfif>