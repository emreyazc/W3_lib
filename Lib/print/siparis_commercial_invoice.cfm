<!---
	Date : 15.12.2021
	Desc : İhracat Birimi için Commercial Invoice şablonudur.
	Dev	 : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfquery name="GET_ORDER" datasource="#dsn3#">
	SELECT
		O.ORDER_ID,
		O.ORDER_DATE,
		O.ORDER_NUMBER,
		O.OTHER_MONEY,
		O.ORDER_DETAIL,
		O.SHIP_ADDRESS,
		O.REF_NO,
		SM.SHIP_METHOD AS SHIP_METHOD,
		E.EMPLOYEE_NAME,
		E.EMPLOYEE_SURNAME,
		C.FULLNAME AS FULLNAME,
		C.MEMBER_CODE AS MEMBER_CODE,
		C.COMPANY_ADDRESS,
		CP.COMPANY_PARTNER_NAME,
		CP.COMPANY_PARTNER_SURNAME,
		CP.COMPANY_PARTNER_TELCODE,
		CP.COMPANY_PARTNER_TEL,
		SC.COUNTRY_NAME,
		SCI.CITY_NAME
	FROM
		ORDERS O
		LEFT JOIN #DSN#.SHIP_METHOD SM ON O.SHIP_METHOD = SM.SHIP_METHOD_ID
		LEFT JOIN #DSN#.EMPLOYEES E ON O.ORDER_EMPLOYEE_ID = E.EMPLOYEE_ID
		LEFT JOIN #DSN#.COMPANY C ON O.COMPANY_ID = C.COMPANY_ID
		LEFT JOIN #DSN#.COMPANY_PARTNER CP ON O.PARTNER_ID = CP.PARTNER_ID
		LEFT JOIN #DSN#.SETUP_COUNTRY SC ON C.COUNTRY = SC.COUNTRY_ID
		LEFT JOIN #DSN#.SETUP_CITY SCI ON C.CITY = SCI.CITY_ID
	WHERE
		ORDER_ID = #attributes.action_id#
</cfquery>

<cfquery name="GET_ORDER_ROW" datasource="#dsn3#">
	SELECT
		ORR.PRODUCT_ID,
		ORR.PRODUCT_NAME,
		ORR.PRICE,
		ORR.UNIT,
		ORR.QUANTITY,
		ORR.NETTOTAL,
		ORR.OTHER_MONEY,
		S.STOCK_CODE_2 AS STOCK_CODE_2
	FROM
		ORDER_ROW ORR
		LEFT JOIN STOCKS S ON S.STOCK_ID = ORR.STOCK_ID
	WHERE
		ORDER_ID = #GET_ORDER.ORDER_ID#
</cfquery>

<cfquery name="CHECK" datasource="#DSN#">
	SELECT 
	   ASSET_FILE_NAME2,
	   ASSET_FILE_NAME2_SERVER_ID,
	   COMPANY_NAME,
	   ADDRESS,
	   TEL,
	   FAX,
	   EMAIL,
	   WEB,
	   TAX_OFFICE,
	   TAX_NO
	FROM 
	   OUR_COMPANY 
	WHERE 
	   <cfif isdefined("attributes.our_company_id")>
	   COMP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.our_company_id#">
	   <cfelse>
	   <cfif isDefined("session.ep.company_id") and len(session.ep.company_id)>
		  COMP_ID = #session.ep.company_id#
	   <cfelseif isDefined("session.pp.company_id") and len(session.pp.company_id)>  
		  COMP_ID = #session.pp.company_id#
	   <cfelseif isDefined("session.ww.our_company_id")>
		  COMP_ID = #session.ww.our_company_id#
	   <cfelseif isDefined("session.cp.our_company_id")>
		  COMP_ID = #session.cp.our_company_id#
	   </cfif> 
	   </cfif> 
 </cfquery>

<cfquery name="get_money" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM ORDER_MONEY WHERE MONEY_TYPE = '#GET_ORDER_ROW.OTHER_MONEY#' AND ACTION_ID = #attributes.action_id#
</cfquery>
<cfquery name="get_money_selected" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM ORDER_MONEY WHERE MONEY_TYPE = '#GET_ORDER_ROW.OTHER_MONEY#' AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>

<cfscript>
	satir_start = 1;
	satir_end = 23;	
	sepet_total = 0;
	sepet_toplam_indirim = 0;
	sepet_total_tax = 0;
	sepet_net_total = 0;
	genel_toplam = 0;
</cfscript>

<cfdocument format="pdf" marginTop = "1" marginBottom = "1">
	<cfdocumentitem type="footer" evalatprint="true">
		<table style="width:100%; height:40%; font-size:13px">
		   <tr align="right">
			  <td align="right"> <b align="left">Page <cfoutput>#cfdocument.currentpagenumber#</cfoutput></b></td>
		   </tr>
		</table>
	 </cfdocumentitem>
	 <cfdocumentitem type="header" evalprint="true">
		<!---
		<table>
		   <tr style="width:100%">
			  <td align="left"><cfoutput><a style="font-size:13px; width:50%"><b>#CHECK.COMPANY_NAME#</b></a></cfoutput></td>
			  <td align="center" style="width:20%">&nbsp;</td>   
			  <td align="right" style="width:20%"><img src="/images/birikim_logo.png" align="right" height="80px;"></td>
		   </tr>
		</table>
		--->
		<table style="width:100%" align="center">
			<tbody>
				<tr style="width:100%">
					<td align="left" style="width:35%"><cfoutput><a style="font-size:15px; width:50%"><b>#CHECK.COMPANY_NAME#</b></a></cfoutput></td>
					<td align="center" style="width:30%">&nbsp;</td>
					<td align="right" style="width:35%"><img src="/images/birikim_logo.png" align="right" height="110px;"></td>
				</tr>
			</tbody>
		</table>
	</cfdocumentitem>

	<cfdocumentsection>
		<table style="align:center; width:100%; font-size:12px">
		  <tbody>
			 <tr>
				<td style="width:40%"><cfoutput>#GET_ORDER.FULLNAME#</cfoutput></td>
				<td rowspan="7" style="background-color:white; width:20%"></td>
				<td>Date </td>
				<td>: <cfoutput>#dateformat(GET_ORDER.ORDER_DATE,dateformat_style)#</cfoutput></td>
			 </tr>
			 <tr>
				<td><cfoutput>#GET_ORDER.COMPANY_PARTNER_NAME# #GET_ORDER.COMPANY_PARTNER_SURNAME#</cfoutput></td>
				<td>Customer No</td>
				<td>: <cfoutput>#GET_ORDER.MEMBER_CODE#</cfoutput></td>
			 </tr>
			 <tr>
				<td><cfoutput>#GET_ORDER.COMPANY_PARTNER_TELCODE# #GET_ORDER.COMPANY_PARTNER_TEL#</cfoutput></td>
				<td>Order No</td>
				<td>: <cfoutput>#GET_ORDER.ORDER_NUMBER#</cfoutput></td>
			 </tr>
			 <tr>
				<td><cfoutput>#GET_ORDER.COMPANY_ADDRESS#</cfoutput><br><cfoutput>#GET_ORDER.CITY_NAME# / #GET_ORDER.COUNTRY_NAME#</cfoutput></td>
				<td>Your Reference</td>
				<td>: <cfoutput>#GET_ORDER.REF_NO#</cfoutput></td>
			 </tr>
			 <tr>
				<td><cfoutput>#GET_ORDER.COUNTRY_NAME#</cfoutput></td>
				<td>Sales Person</td>
				<td>: <cfoutput>#GET_ORDER.EMPLOYEE_NAME# #GET_ORDER.EMPLOYEE_SURNAME#</cfoutput></td>
			 </tr>
			 <tr>
				<td></td>
				<td>Delivery</td>
				<td>: <cfoutput>#GET_ORDER.SHIP_METHOD#</cfoutput></td>
			 </tr>
			 <tr>
				<td></td>
				<td>Note-1</td>
				<td>: <cfoutput>#GET_ORDER.ORDER_DETAIL#</cfoutput></td>
			 </tr>
		  </tbody>
		</table>

		<cfquery name="GET_ORDER_INVOICE" datasource="#DSN3#">
			SELECT
				I.INVOICE_NUMBER
			FROM
				ORDERS_INVOICE OI
				LEFT JOIN #DSN2#.INVOICE I ON I.INVOICE_ID = OI.INVOICE_ID
			WHERE OI.ORDER_ID = #GET_ORDER.ORDER_ID#
		</cfquery>

		<table style="align:center; width:100%; font-size:12px">
		   <tbody>
			<cfif len(GET_ORDER_INVOICE.INVOICE_NUMBER)>
				<tr>
					<td><h2>Invoice : <cfoutput>#GET_ORDER_INVOICE.INVOICE_NUMBER#</cfoutput></h2></td>
					<td rowspan="3"></td>
					<td></td>
				 </tr>
			</cfif>
			  <tr>&nbsp;</tr>
			  <tr>
				 <td>Ship To : <cfoutput>#GET_ORDER.SHIP_ADDRESS#</cfoutput></td>
				 <td></td>
			  </tr>
		   </tbody>
		</table>
		<br>

		<table style="width:100%; font-size:13px">
		   <tbody>
				 <tr>
					<td>Art. No.</td>
					<td>Description</td>
					<td>Quantity</td>
					<td>Price</td>
					<td>Total Price</td>
				  </tr>
				  <tr>
					 <td colspan="5"><hr class="solid"></td>
				  </tr>
				  <cfoutput query="GET_ORDER_ROW">
					<cfif PRODUCT_ID neq 35835 and PRODUCT_ID neq 35836 >
						<tr>
							<td>#STOCK_CODE_2#</td>
							<td>
							 <cfquery name="GET_ENG_PRODUCT_NAME" datasource="#DSN#">
							  SELECT
								ITEM
							  FROM
								SETUP_LANGUAGE_INFO
							  WHERE
								COLUMN_NAME = 'PRODUCT_NAME' AND
								TABLE_NAME = 'PRODUCT' AND
								LANGUAGE = 'ENG' AND
								UNIQUE_COLUMN_ID = #PRODUCT_ID#
							</cfquery>
							<cfloop query="GET_ENG_PRODUCT_NAME">#ITEM#</cfloop>
							</td>
							<td>#QUANTITY#</td>
							<td>#TLFORMAT(price/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</td>
							<td>#TLFORMAT((price*quantity)/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</td>
						</tr>
					</cfif>
				  </cfoutput>
		   </tbody>
		</table>

		<cfoutput query="GET_ORDER_ROW">
			<cfif PRODUCT_ID neq 35835 and PRODUCT_ID neq 35836>
				<cfscript>
					row_total = QUANTITY * price;
					sepet_net_total = row_total;
					genel_toplam = genel_toplam + row_total; //row_nettotal  genel_toplam 
				</cfscript>
			</cfif>
		</cfoutput>

		<cfset freight_cost = 0>
        <cfset insurance_cost = 0>

		<div align="right">
		   <table style="margin-top:20px">
			  <tbody>
				 <tr>
					<td><b>SUB TOTAL VALUE</b></td>
					<td>: <b><cfoutput>#TLFormat(genel_toplam/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</cfoutput></b></td>
				 </tr>
				 <cfloop query="GET_ORDER_ROW">
					<cfif PRODUCT_ID eq 35835>
					  <tr>
						<td width="125"><b>FREIGHT COST&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
						<td align="right">: <b><cfoutput>#TLFormat(PRICE/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</cfoutput></b></td>
					</tr>
					<cfset freight_cost = PRICE>
					</cfif>
				  </cfloop>
				  <cfloop query="GET_ORDER_ROW">
					<cfif PRODUCT_ID eq 35836>
					  <tr>
						<td width="125"><b>INSURANCE COST&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
						<td align="right">: <b><cfoutput>#TLFormat(PRICE/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</cfoutput></b></td>
					  </tr>
					  <cfset insurance_cost = PRICE>
					</cfif>
				  </cfloop>
				  <cfscript>
					genel_toplam = genel_toplam+freight_cost+insurance_cost
				  </cfscript>
				 <tr>
					<td><b>TOTAL VALUE</b></td>
					<td>: <b><cfoutput>#TLFormat(((genel_toplam)/get_money.rate2))# #GET_ORDER.OTHER_MONEY#</cfoutput></b></td>
				 </tr>
			  </tbody>
		   </table>
		</div>
  </cfdocumentsection>
</cfdocument>