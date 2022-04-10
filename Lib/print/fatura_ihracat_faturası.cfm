<!--- İhracat Fatura Baski Birikim --->
<cf_get_lang_set module_name="invoice"><!--- sayfanin en altinda kapanisi var --->
<cfquery name="Get_Invoice" datasource="#dsn2#">
	SELECT 
        COMPANY_ID,
        CONSUMER_ID,
        DEPARTMENT_ID,
        SHIP_METHOD,
        INVOICE_DATE,
        INVOICE_NUMBER,
        INVOICE_CAT,
        NOTE,
        INVOICE_ID,
        SHIP_ADDRESS,
        NETTOTAL,
        GROSSTOTAL,
        TAXTOTAL,
        SA_DISCOUNT,
        TEVKIFAT_ORAN,
        OTHER_MONEY,
        TEVKIFAT,
        TEVKIFAT_ID,
        PROCESS_CAT,
        TAXTOTAL AS INVOICE_TAX,
        UUID
    FROM 
    	INVOICE 
    WHERE 
	<cfif not isDefined("attributes.ID")>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
        INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
</cfquery>
<cfif get_invoice.invoice_cat neq 531>
	<script type="text/javascript">
		alert("Bu alandan sadece İhracat Faturası Yazdırılmalıdır.");		
	</script>
		<cfabort>
</cfif>
<cfquery name="Get_Process_cat" datasource="#dsn3#">
		SELECT INVOICE_TYPE_CODE,PROFILE_ID FROM SETUP_PROCESS_CAT  WHERE PROCESS_CAT_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.process_cat#">
	</cfquery>
	
<cfquery name="Get_Invoice_Row" datasource="#dsn2#">
    SELECT 
        IR.*,
        S.PROPERTY,
        IR.NAME_PRODUCT AS PRODUCT_NAME,
        S.STOCK_CODE,
		NETTOTAL
    FROM 
        INVOICE_ROW IR, 
        #dsn3_alias#.STOCKS S
      
    WHERE 
        IR.STOCK_ID = S.STOCK_ID AND
        <cfif not isDefined("attributes.ID")>
        	IR.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#"> <!--- _sil neden integer i liste gibi kullaniyor? --->
        <cfelse>
        	IR.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
        </cfif>
    ORDER BY
        IR.INVOICE_ROW_ID 
</cfquery>
<cfoutput>
</cfoutput>
<cfif Len(Get_Invoice.TEVKIFAT_ID)>
    <cfquery name="Get_Setup_Tevkifat" datasource="#dsn3#">
        SELECT * FROM SETUP_TEVKIFAT WHERE TEVKIFAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.TEVKIFAT_ID#">
    </cfquery>
</cfif>
<cfquery name="Get_Sale_Order" datasource="#dsn2#">
	SELECT 
		O.ORDER_NUMBER,
      O.ORDER_EMPLOYEE_ID,
      E.EMPLOYEE_NAME,
      E.EMPLOYEE_SURNAME
	FROM 
		INVOICE I,
		INVOICE_SHIPS ISH,
		#dsn3_alias#.ORDERS_SHIP OS,
		#dsn3_alias#.ORDERS O,
      #dsn#.EMPLOYEES E
	WHERE
	<cfif not isDefined("attributes.id")>
		I.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
    <cfelse>
    	I.INVOICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.id#">
    </cfif>
	  	AND I.INVOICE_ID = ISH.INVOICE_ID
		AND ISH.SHIP_ID = OS.SHIP_ID
		AND O.ORDER_ID = OS.ORDER_ID
		AND OS.PERIOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
</cfquery>

<cfquery name="get_money" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM OFFER_MONEY WHERE MONEY_TYPE = '#Get_Invoice.other_money#' AND ACTION_ID = #attributes.action_id#
</cfquery>
<cfquery name="get_money_selected" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM OFFER_MONEY WHERE MONEY_TYPE = '#Get_Invoice.other_money#' AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>

<cfset Member_Code = "">
<cfset Member_Name = "">
<cfset Member_Mail = "">
<cfset Member_TaxOffice = "">
<cfset Member_TaxNo = "">
<cfset Member_TelCode = "">
<cfset Member_Tel = "">
<cfset Member_Fax = "">
<cfset Member_Address = "">
<cfset Member_Semt = "">
<cfset Member_County = "">
<cfset Member_City = "">
<cfset Member_Country = "">
<cfset Member_Tc_No = "">
<cfset bakiye = "">
<cfif isdefined("Get_Invoice.Company_Id") and Len(Get_Invoice.Company_Id)>
    <cfquery name="Get_Member_Info" datasource="#dsn#">
        SELECT
            C.COMPANY_ID MEMBER_ID,
			   C.HOMEPAGE Member_HOMEPAGE,
            C.MEMBER_CODE MEMBER_CODE,
            C.FULLNAME MEMBER_NAME,
            C.COMPANY_EMAIL MEMBER_EMAIL,
            C.TAXOFFICE MEMBER_TAXOFFICE,
            C.TAXNO MEMBER_TAXNO,
            C.COMPANY_TELCODE MEMBER_TELCODE,
            C.COMPANY_TEL1 MEMBER_TEL,
            C.COMPANY_FAX MEMBER_FAX,
            C.COMPANY_ADDRESS MEMBER_ADDRESS,
            C.SEMT MEMBER_SEMT,
            C.COUNTY MEMBER_COUNTY,
            C.CITY MEMBER_CITY,
            C.COUNTRY MEMBER_COUNTRY,
       		C.IS_PERSON,
            CP.TC_IDENTITY,
			C.USE_EFATURA
        FROM
            COMPANY C LEFT JOIN COMPANY_PARTNER CP ON C.COMPANY_ID = CP.COMPANY_ID  
        WHERE
            C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Company_Id#">          
    </cfquery>
    <cfquery name="Get_Remainder" datasource="#dsn2#">
		SELECT 
        	*
        FROM 
        	COMPANY_REMAINDER 
        WHERE 
        	COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Company_Id#">
	</cfquery>
<cfelseif isdefined("Get_Invoice.Consumer_Id") and Len(Get_Invoice.Consumer_Id)>
	<cfquery name="Get_Member_Info" datasource="#dsn#">
    	SELECT
        	   CONSUMER_ID MEMBER_ID,
            MEMBER_CODE MEMBER_CODE,
            CONSUMER_NAME + ' ' + CONSUMER_SURNAME MEMBER_NAME,
            CONSUMER_EMAIL MEMBER_EMAIL,
            TAX_OFFICE MEMBER_TAXOFFICE,
            TAX_NO MEMBER_TAXNO,
            CONSUMER_WORKTELCODE MEMBER_TELCODE,
            CONSUMER_WORKTEL MEMBER_TEL,
            CONSUMER_FAXCODE + '' + CONSUMER_FAX MEMBER_FAX,
            WORKADDRESS MEMBER_ADDRESS,
            WORKSEMT MEMBER_SEMT,
            WORK_COUNTY_ID MEMBER_COUNTY,
            WORK_CITY_ID MEMBER_CITY,
            WORK_COUNTRY_ID MEMBER_COUNTRY,
            TC_IDENTY_NO TC_IDENTY_NO,
			   USE_EFATURA
        FROM
         	CONSUMER
        WHERE
        	   CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Consumer_Id#">
    </cfquery>
   <cfquery name="Get_Remainder" datasource="#dsn2#">
		SELECT 
        	*
      FROM 
        	CONSUMER_REMAINDER 
      WHERE 
        	CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Consumer_Id#">
	</cfquery>
</cfif>
<cfif isdefined("Get_Member_Info") and Get_Member_Info.RecordCount>
	<cfset Member_Code = Get_Member_Info.Member_Code>
    <cfset Member_Name = Get_Member_Info.Member_Name>
    <cfset Member_Mail = Get_Member_Info.Member_Email>
    <cfset Member_TaxOffice = Get_Member_Info.Member_TaxOffice>
    <cfset Member_TaxNo = Get_Member_Info.Member_TaxNo>
    <cfset Member_HOMEPAGE ="">
    <cfset Member_TelCode = Get_Member_Info.Member_TelCode>
    <cfset Member_Tel = Get_Member_Info.Member_Tel>
    <cfset Member_Fax = Get_Member_Info.Member_Fax>
    <cfset Member_Address = Get_Member_Info.Member_Address>
    <cfset Member_Semt = Get_Member_Info.Member_Semt>
    <cfif isdefined("Get_Member_Info.TC_IDENTY_NO") and len(Get_Member_Info.TC_IDENTY_NO)><cfset Member_Tc_No =  Get_Member_Info.TC_IDENTY_NO ><cfelseif isdefined("Get_Member_Info.TC_IDENTITY") and len(Get_Member_Info.TC_IDENTITY)><cfset Member_Tc_No =  Get_Member_Info.TC_IDENTITY ></cfif>
    <cfset bakiye = get_remainder.bakiye>
	<cfif Len(Get_Member_Info.Member_County)>
		<cfquery name="Get_County_Name" datasource="#dsn#">
			SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_County#">
		</cfquery>
		<cfset Member_County = Get_County_Name.County_Name>
	</cfif>
	<cfif Len(Get_Member_Info.Member_City)>
		<cfquery name="Get_City_Name" datasource="#dsn#">
			SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_City#">
		</cfquery>
		<cfset Member_City = Get_City_Name.City_Name>
	</cfif>
	<cfif Len(Get_Member_Info.Member_Country)>
		<cfquery name="Get_Country_Name" datasource="#dsn#">
			SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Member_Info.Member_Country#">
		</cfquery>
		<cfset Member_Country = Get_Country_Name.Country_Name>
	</cfif>
</cfif>
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
  
<cfif len(Get_Invoice.Department_Id)>
	<cfquery name="Get_Store" datasource="#dsn#">
		SELECT DEPARTMENT_HEAD FROM DEPARTMENT WHERE DEPARTMENT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Department_Id#">
	</cfquery>
</cfif>
<cfquery name="Get_Account" datasource="#dsn3#">
		SELECT B.BANK_NAME, A.IS_INTERNET,A.ACCOUNT_OWNER_CUSTOMER_NO,ACCOUNT_CURRENCY_ID FROM ACCOUNTS A , BANK_BRANCH B WHERE A.ACCOUNT_BRANCH_ID=B.BANK_BRANCH_ID
	</cfquery>

<cfif len(Get_Invoice.Ship_Method)>
	<cfquery name="Get_Method" datasource="#dsn#">
		SELECT SHIP_METHOD FROM SHIP_METHOD WHERE SHIP_METHOD_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#Get_Invoice.Ship_Method#">
	</cfquery>
</cfif>
<cfset sepet.kdv_array = ArrayNew(2)>
<cfset invoice_bill_upd = arraynew(2)>
<cfset kdv_total = 0>
<cfset satir_toplam_indirim = 0>
<cfoutput query="Get_Invoice_Row">
	<cfset invoice_bill_upd[currentrow][1] = product_id >
	<cfset invoice_bill_upd[currentrow][2] = product_name>
	<cfset invoice_bill_upd[currentrow][3] = stock_code>
    <cfset invoice_bill_upd[currentrow][4] = amount>
	<cfset invoice_bill_upd[currentrow][5] = unit>
	<cfset invoice_bill_upd[currentrow][35] = unit_id>	
	<cfset invoice_bill_upd[currentrow][6] = price>	
	<cfset invoice_bill_upd[currentrow][8] = discounttotal>
	<cfset invoice_bill_upd[currentrow][10] = stock_id>
	<cfset invoice_bill_upd[currentrow][14] = pay_method>
	<cfset invoice_bill_upd[currentrow][15] = amount*price>
	<cfset invoice_bill_upd[currentrow][16] = nettotal>	
	<cfset invoice_bill_upd[currentrow][18] = grosstotal>
	<cfset invoice_bill_upd[currentrow][17] = taxtotal>
	<cfset invoice_bill_upd[currentrow][19] = 0 >
	<cfset invoice_bill_upd[currentrow][20] = 0 > 
	<cfset invoice_bill_upd[currentrow][27] = 0 >
	<cfset invoice_bill_upd[currentrow][26] = spect_var_id>
	<cfset invoice_bill_upd[currentrow][39] = spect_var_name>
	<cfset invoice_bill_upd[currentrow][40] = LOT_NO>
	<cfset invoice_bill_upd[currentrow][41] = PRICE_OTHER>
	<cfset invoice_bill_upd[currentrow][28] = 0>
	<cfif len(TAX)>
		<cfset invoice_bill_upd[currentrow][7] = TAX>
		<!--- <cfset invoice_bill_upd[currentrow][17] = satir_tax_tutar> --->
		<cfelse>
			<cfif nettotal neq 0>
				<cfset invoice_bill_upd[currentrow][7] = (taxtotal/nettotal)*100 >
			<cfelse>	
				<cfset invoice_bill_upd[currentrow][7] = 0>
			</cfif>
	</cfif>		
	<cfscript>
	kdv_flag = 0;
	for (k=1;k lte arraylen(sepet.kdv_array);k=k+1)
	{
		if (sepet.kdv_array[k][1] eq invoice_bill_upd[currentrow][7])
		{
			kdv_flag = 1;
			sepet.kdv_array[k][2] = sepet.kdv_array[k][2] + invoice_bill_upd[currentrow][17];				
		}
	}
	if (not kdv_flag)
	{
		sepet.kdv_array[arraylen(sepet.kdv_array)+1][1] = invoice_bill_upd[currentrow][7];
		sepet.kdv_array[arraylen(sepet.kdv_array)][2] = invoice_bill_upd[currentrow][17];
	}	
	</cfscript>
	<cfset kdv_total = kdv_total + invoice_bill_upd[currentrow][17]>   
</cfoutput>
<cfparam name="attributes.mode" default=23>
<cfscript>
	sayfa_toplam = 0;
	devreden_toplam = 0;	
</cfscript>
<cfset satir_indirim_toplam = 0>
<cfset toplam_indirim = 0>
<cfset Nettotal=0>
<cfset Taxtotal=0>
<link rel="stylesheet" href="/css/assets/template/catalyst/print1.css" type="text/css">

<cfdocument format="pdf">
   <cfdocumentitem type="footer" evalatprint="true">
      <table style="width:100%; font-size:13px">
         <tr align="right">
            <td align="right"> <b align="left">Page <cfoutput>#cfdocument.currentpagenumber#</cfoutput></b></td>
         </tr>
      </table>
   </cfdocumentitem>
   <cfdocumentitem type="header" evalprint="true">
      <table>
         <tr style="width:100%">
            <td align="left"><cfoutput><a style="font-size:15px; width:30%">#CHECK.COMPANY_NAME#</a></cfoutput></td>
            <td align="center" style="width:20%">&nbsp;</td>   
            <td align="right" style="width:20%"><img src="/images/birikim_logo.png" align="right" height="100px;"></td>
         </tr>
      </table>
   </cfdocumentitem>
   <cfdocumentsection>
         <table style="align:center; width:100%; font-size:12px">
           <tbody>
              <tr>
                 <td style="width:40%"><cfoutput>#Member_Name#</cfoutput></td>
                 <td rowspan="7" style="background-color:white; width:20%"></td>
                 <td>Date </td>
                 <td>: <cfoutput>#dateformat(Get_Invoice.Invoice_Date,'dd.mm.yyyy')#</cfoutput></td>
              </tr>
              <tr>
                 <td>şirket yetkilisi gelecek</td>
                 <td>Customer No</td>
                 <td>: <cfoutput>#Member_Code#</cfoutput></td>
              </tr>
              <tr>
                 <td><cfoutput>#Member_TelCode# #Member_Tel#</cfoutput></td>
                 <td>Order No</td>
                 <td>: <cfoutput>#Get_Sale_Order.ORDER_NUMBER#</cfoutput></td>
              </tr>
              <tr>
                 <td><cfoutput>#Member_City# / #Member_County#</cfoutput></td>
                 <td>Your Reference</td>
                 <td>: ?</td>
              </tr>
              <tr>
                 <td><cfoutput>#Member_City#</cfoutput></td>
                 <td>Sales Person</td>
                 <td>: <cfoutput>#Get_Sale_Order.EMPLOYEE_NAME# #Get_Sale_Order.EMPLOYEE_SURNAME# </cfoutput></td>
              </tr>
              <tr>
                 <td></td>
                 <td>Delivery</td>
                 <td>: <cfoutput>#Get_Method.SHIP_METHOD#</cfoutput></td>
              </tr>
              <tr>
                 <td></td>
                 <td>Note-1</td>
                 <td>: <cfoutput>#GET_INVOICE.NOTE#</cfoutput></td>
              </tr>
           </tbody>
         </table>

         <table style="align:center; width:100%; font-size:12px">
            <tbody>
               <tr>
                  <td><h3>Invoice <cfoutput>#Get_Invoice.INVOICE_NUMBER#</cfoutput></h3></td>
                  <td rowspan="3"></td>
                  <td></td>
               </tr>
               <tr>
                  <td>Ship To :</td>
                  <td></td>
               </tr>
            </tbody>
         </table>

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
                <cfoutput query="Get_Invoice_Row">    
                   <tr>
                      <td rowspan="4">#STOCK_CODE#</td>
                      <td>#NAME_PRODUCT#</td>
                      <td rowspan="4">#AMOUNT#</td>
                      <td rowspan="4">price</td>
                      <td rowspan="4">total price</td>
                   </tr>
                   <tr>
                      <td>EAN</td>
                   </tr>
                   <tr>
                      <td>Produced in: ? </td>
                   </tr>
                   <tr>
                      <td>GTIP Code:</td>
                   </tr>
                   <tr>
                     &nbsp;
                  </tr>
               </cfoutput>
            </tbody>
         </table>
         
         <div align="right">
            <table style="margin-top:20px">
               <tbody>
                  <tr>
                     <td>SUB TOTAL VALUE</td>
                     <td>: ?</td>
                  </tr>
                  <tr>
                     <td>FREIGHT</td>
                     <td>: ?</td>
                  </tr>
                  <tr>
                     <td>TOTAL VALUE</td>
                     <td>: ?</td>
                  </tr>
               </tbody>
            </table>
         </div>
   </cfdocumentsection>
</cfdocument>


<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->