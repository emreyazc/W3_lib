<!--- 
    Description: Proforma (İngilizce) Şablonu - Birikim Pilleri
    File: 05DF1759-FEEC-E150-C91072B3BACCA3A3.cfm
    Author: Birikim Pilleri - Yunus Emre Yazıcı
    Date: 13.12.2021
--->
<cfquery name="CHECK" datasource="#DSN#">
	SELECT 
        ASSET_FILE_NAME3,
        ASSET_FILE_NAME3_SERVER_ID,
        COMPANY_NAME,
        TEL_CODE,
        TEL,
        TEL2,
        TEL3,
        TEL4,
        FAX,
        ADDRESS,
        WEB,
        EMAIL,
        TAX_OFFICE,
        TAX_NO 
    FROM 
        OUR_COMPANY 
    WHERE 
        COMP_ID = #SESSION.EP.COMPANY_ID#
</cfquery>
  
<cfset attributes.purchase_sales = 1 >
<cfquery name="GET_OFFER" datasource="#dsn3#">
	SELECT * FROM OFFER WHERE OFFER_ID = #attributes.action_id#
</cfquery>
<cfoutput><div align="left">

<cfquery name="GET_BRANCH_INFO" datasource="#DSN#">
  SELECT
    E.EMPLOYEE_EMAIL,
    B.BRANCH_FULLNAME,
    B.BRANCH_COUNTRY,
    B.BRANCH_ADDRESS,
    B.BRANCH_TELCODE,
    B.BRANCH_TEL1,
    B.BRANCH_FAX
  FROM
    EMPLOYEE_POSITIONS EP
    LEFT JOIN DEPARTMENT D ON D.DEPARTMENT_ID = EP.DEPARTMENT_ID
    LEFT JOIN BRANCH B ON B.BRANCH_ID = D.BRANCH_ID
    LEFT JOIN EMPLOYEES E ON E.EMPLOYEE_ID = EP.EMPLOYEE_ID
  WHERE
    EP.EMPLOYEE_ID = #GET_OFFER.RECORD_MEMBER#
</cfquery>

<cfif len(get_offer.company_id)>
	<cfquery name="get_company" datasource="#dsn#">
		SELECT FULLNAME, COUNTY, CITY,COMPANY_ADDRESS, COMPANY_POSTCODE, MEMBER_CODE, COUNTRY, COMPANY_TELCODE, COMPANY_TEL1, COMPANY_FAX, COMPANY_EMAIL FROM COMPANY WHERE COMPANY_ID = #get_offer.company_id#
	</cfquery>
	<cfset firma_adi = get_company.fullname>
	<cfset adres =get_company.company_address>
	<cfset postacodu =get_company.company_postcode>
	<cfif len(get_company.county)>
		<cfquery name="get_county" datasource="#dsn#">
			SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #get_company.county#
		</cfquery>
		<cfset ilce = get_county.county_name>
	</cfif>
	<cfif len(get_company.city)>
		<cfquery name="get_city" datasource="#dsn#">
			SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #get_company.city#
		</cfquery>
		<cfset il = get_city.city_name>
	</cfif>
	<cfif len(get_company.country)>
		<cfquery name="get_country" datasource="#dsn#">
			SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #get_company.country#
		</cfquery>
		<cfset ulke = get_country.country_name>
	</cfif>

<cfelseif len(get_offer.consumer_id)>
	<cfquery name="get_consumer" datasource="#dsn#">
		SELECT CONSUMER_NAME + ' ' + CONSUMER_SURNAME MEMBER_NAME, HOME_COUNTY_ID COUNTY, HOME_CITY_ID CITY, HOME_COUNTRY_ID COUNTRY, TAX_CITY_ID, TAX_COUNTRY_ID, TAX_COUNTY_ID FROM CONSUMER WHERE CONSUMER_ID = #get_offer.consumer_id#
	</cfquery>
	<cfset firma_adi = get_consumer.member_name>
	
	<cfif len(get_consumer.county)>
		<cfquery name="get_county" datasource="#dsn#">
			SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = '#get_consumer.tax_county_id#'
		</cfquery>
		<cfset ilce = get_county.county_name>
	</cfif>
	<cfif len(get_consumer.city)>
		<cfquery name="get_city" datasource="#dsn#">
			SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = '#get_consumer.tax_city_id#'
		</cfquery>
		<cfset il = get_city.city_name>
	</cfif>
	<cfif len(get_consumer.country)>
		<cfquery name="get_country" datasource="#dsn#">
			SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = '#get_consumer.tax_country_id#'
		</cfquery>
		<cfset ulke = get_country.country_name>
	</cfif>
</cfif>
<cfif len(get_offer.paymethod)>
  <cfset attributes.paymethod_id = get_offer.paymethod>
  <cfquery name="GET_PAYMETHOD" datasource="#dsn#">
    SELECT * FROM SETUP_PAYMETHOD WHERE PAYMETHOD_ID = #attributes.PAYMETHOD_ID#
  </cfquery>
</cfif>
<cfif len(get_offer.SHIP_METHOD)>
  <cfset attributes.ship_method=get_offer.SHIP_METHOD>
  <cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
    SELECT SHIP_METHOD FROM SHIP_METHOD WHERE SHIP_METHOD_ID=#attributes.ship_method#
  </cfquery>

<cfquery name="GET_OFFER_ROWS" datasource="#dsn3#">
	SELECT 
    OFFER_ROW.*,
    STOCKS.STOCK_CODE AS STOK_KODU,
    STOCKS.STOCK_CODE_2 AS OZEL_KOD,
    STOCKS.PRODUCT_ID AS PRODUCT_ID,
    SL.ITEM AS ENG_UNIT
  FROM
    OFFER_ROW 
    LEFT JOIN STOCKS ON STOCKS.PRODUCT_ID = OFFER_ROW.PRODUCT_ID
    LEFT JOIN #DSN1#.PRODUCT_UNIT PU ON PU.PRODUCT_UNIT_ID = OFFER_ROW.UNIT_ID
		LEFT JOIN #DSN#.SETUP_LANGUAGE_INFO SL ON SL.UNIQUE_COLUMN_ID = PU.MAIN_UNIT_ID
  WHERE	
    OFFER_ID = #attributes.action_id# AND
    SL.LANGUAGE = 'eng' AND 
		SL.COLUMN_NAME = 'UNIT'
</cfquery>

<cfquery name="get_money" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM OFFER_MONEY WHERE MONEY_TYPE = '#get_offer.other_money#' AND ACTION_ID = #attributes.action_id#
</cfquery>
<cfquery name="get_money_selected" datasource="#dsn3#">
	SELECT RATE1,RATE2,MONEY_TYPE FROM OFFER_MONEY WHERE MONEY_TYPE = '#get_offer.other_money#' AND ACTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
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
<cfset sayfa_sayisi = ceiling(GET_OFFER_ROWS.recordcount/satir_end)>
<cfif sayfa_sayisi eq 0>
	<cfset sayfa_sayisi = 1>
</cfif>
  <table width="700">
    <tr>
      <td align="left"><cf_get_server_file output_file="../../images/birikim_logo3.jpg" image_width="235" output_server="1" output_type="5"></td>
      <td align="right"><cf_get_server_file output_file="../../images/teklif_pil.png" image_width="180" image_height="80" output_server="1" output_type="5"></td>
    </tr>
  </table>
  <table width="700">
    <tr>
      <td align="left">
        <table align="left">
          <tr>
            <td align="left">
              <cfoutput>
                <b style="font-size:13px">#CHECK.company_name#</b>
                <table>
                  <!---<tr><td>Şube</td><td><b>: #GET_BRANCH_INFO.BRANCH_FULLNAME#</b></td></tr>--->
                  <tr><td>Address</td><td><b>: #GET_BRANCH_INFO.BRANCH_ADDRESS#</b></td></tr>
                  <tr><td>Tax Ad. / No</td><td><b>: #CHECK.TAX_OFFICE# / #CHECK.TAX_NO#</b></td></tr>
                  <tr><td>Tel</td><td><b>: #GET_BRANCH_INFO.BRANCH_TELCODE# #GET_BRANCH_INFO.BRANCH_TEL1#</b></td></tr>
                  <tr><td>Fax</td><td><b>: #GET_BRANCH_INFO.BRANCH_TELCODE# #GET_BRANCH_INFO.BRANCH_FAX#</b></td></tr>
                </table>
              </cfoutput>
            </td>
          </tr>
        </table>
      </td>
      <td align="right">
        <table align="right">
          <tr><td>Date</td><td><b><cfoutput>: #dateformat(dateadd('h',session.ep.time_zone,get_offer.offer_date),'dd/mm/yyyy')#</cfoutput></b></td></tr>
          <tr><td>Quotation</td><td><b><cfoutput>: #get_offer.offer_number# </cfoutput></b></td></tr>
          <tr><td>Validity</td><td><b><cfoutput>: #dateformat(get_offer.finishdate,"dd/mm/yyyy")#</cfoutput></b></td></tr>
        </table>
        <b><cf_workcube_barcode show="1" type="qrcode" height="100" value="#get_offer.offer_number#"></b>
      </td>
    </tr>
    <!----
    <td align="left">
      <cf_get_server_file output_file="../../images/tel_no_1.png" image_width="150" image_height="40" output_server="1" output_type="5">
    </td>
    --->
  </table>
  <table width="700">
    <tr align="center">
      <td colspan="4" align="center"><b style="font-size:20px">PROFORMA</b></td>
    </tr>
  </table>

  <table frame="box" width="700" height="85">
    <td align="left">
      <table>
        <tr><td><b>Company / Authorize </b></td><td><b>: <cfif len(get_offer.PARTNER_ID)><cfset contact_type = "p">#get_par_info(get_offer.PARTNER_ID,0,1,0)# - #get_par_info(get_offer.PARTNER_ID,0,-1,0)#</cfif></b></td></tr>
        <tr><td><b>Tel </b></td><td><b>: <cfif isDefined("get_company.company_tel1") and len(get_company.company_tel1)><cfoutput>#get_company.COMPANY_TELCODE# #get_company.company_tel1#</cfoutput><cfelse></cfif></b></td></tr>
        <tr><td><b>Fax </b></td><td><b>: <cfif isDefined("get_company.company_fax") and len(get_company.company_fax)><cfoutput>#get_company.company_fax#</cfoutput><cfelse></cfif></b></td></tr>
        <tr><td><b>E-mail </b></td><td><b>: <cfif isDefined("get_company.company_email") and len(get_company.company_email)><cfoutput>#get_company.company_email#</cfoutput><cfelse></cfif></b></td></tr>
      </table>
    </td>
    <td align="right">
      <table>
        <!---<tr><td><b>Teslim Tarihi </b></td><td><b>: #dateformat(get_offer.deliverdate,"dd/mm/yyyy")#</b></td></tr>--->
        <tr><td><b>Shipment Method</b></td><td><b>: <cfif isDefined("GET_SHIP_METHOD.SHIP_METHOD") AND len("GET_SHIP_METHOD.SHIP_METHOD")><cfoutput>#GET_SHIP_METHOD.SHIP_METHOD#</cfoutput><cfelse></cfif></b></td></tr>
        <!---<tr><td><b>Kargo Ücreti</b></td><td>: </td></tr>--->
        <tr><td><b>Payment Method</b></td><td><b>: <cfif len(get_offer.paymethod)><cfoutput>#get_paymethod.paymethod#</cfoutput><cfelse></cfif></b></td></tr>
      </table>
    </td>
</cfif> 
</cfoutput>

<cfloop from="1" to="#sayfa_sayisi#" index="j">
<table frame="box" cellpadding="0" cellspacing="0" border="0" style="height:110mm;">
    <tr valign="top">
    	<td>
        <table width="700" cellpadding="3" cellspacing="0" border="1px" bordercolor="#EFEFEF">
       
        <tr class="formbold">
            <td bgcolor="EFEFEF">ERP Code </td>
            <td bgcolor="EFEFEF">Description </td>
            <td width="90" align="right" bgcolor="#EFEFEF">Quantity</td>
            <td width="90" align="right" bgcolor="#EFEFEF">Unit</td>
            <td width="90" align="right" bgcolor="#EFEFEF">Unit Price</td>
            <td width="115" align="right" bgcolor="#EFEFEF">Total Amount</td>
            <!--- <td width="30">KDV</td>
                <td width="100">KDV'li Toplam</td> --->
        </tr>
		<cfoutput query="GET_OFFER_ROWS" startrow="#satir_start#" maxrows="#satir_end#">
      <cfset satir_indirim =price_other*(discount_1/100) + (price_other - (price_other*(discount_1/100)))* discount_2/100 +discount_cost>
      <cfif PRODUCT_ID neq 35835 and PRODUCT_ID neq 35836 >
        <cfscript>
          if (not len(QUANTITY)) QUANTITY = 1;
          if (not len(PRICE)) 
              price = 0;
          tax_percent = TAX;
          if (not len(discount_1)) indirim1 = 0; else indirim1 = discount_1;
          if (not len(discount_2)) indirim2 = 0; else indirim2 = discount_2;
          if (not len(discount_3)) indirim3 = 0; else indirim3 = discount_3;
          if (not len(discount_4)) indirim4 = 0; else indirim4 = discount_4;
          if (not len(discount_5)) indirim5 = 0; else indirim5 = discount_5;
          indirim6 = 0;
          indirim7 = 0;
          indirim8 = 0;
          indirim9 = 0;
          indirim10 = 0;
          indirim_carpan = (100-indirim1) * (100-indirim2) * (100-indirim3) * (100-indirim4) * (100-indirim5);
      
          other_money_value = price_other;	
          other_money_price = OTHER_MONEY_VALUE;
          net_maliyet = NET_MALIYET;
          marj = MARJ;
          if(len(price_other))
              other_money_rowtotal = price_other;
          else
              other_money_rowtotal = price;
          row_total = QUANTITY * price;
          row_nettotal = round((row_total/10000000000) * indirim_carpan);
          row_taxtotal = round(row_nettotal * (tax_percent/100));
          row_lasttotal = row_nettotal + row_taxtotal;
          sepet_total = sepet_total + row_total; //subtotal_
          sepet_toplam_indirim = sepet_toplam_indirim + (round(row_total) - round(row_nettotal)); //discount_
          sepet_total_tax = sepet_total_tax + row_taxtotal; //totaltax_
          sepet_net_total = sepet_net_total + row_lasttotal; //nettotal_
          genel_toplam = genel_toplam + row_total; //row_nettotal  genel_toplam 
      </cfscript>
      </cfif>
      <cfif GET_OFFER_ROWS.PRODUCT_ID neq 35835 and GET_OFFER_ROWS.PRODUCT_ID neq 35836>
        <tr>
          <td>#OZEL_KOD#</td>
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
            </br><!---<b><p style="color:red">#DETAIL_INFO_EXTRA#</p></b>--->
          </td> <!--- Ürün adı ve satır altı açıklama --->
          <td align="right">#QUANTITY#</td>
          <td align="right">#ENG_UNIT#</td>
          <td align="right">#TLFORMAT((price/get_money.rate2),3)# #GET_MONEY.MONEY_TYPE#</td> 
          <td align="right">#TLFORMAT(((price*quantity)/get_money.rate2),3)# #GET_MONEY.MONEY_TYPE#</td>
        </tr>
        <tr>
          <td>
            <!--- Ürüne ait tek görsel varsa şablonda gelir, birden fazla varsa Kapak Görseli işaretlenmiş olan gelir, birden fazla görsel var ve Kapak Görseli seçilmemişse görsel gelmez. --->
            <cfquery name="GET_PRODUCT_IMAGES" datasource="#DSN1#">
              SELECT
                PATH
              FROM
                PRODUCT_IMAGES
              WHERE
                PRODUCT_ID = #GET_OFFER_ROWS.PRODUCT_ID#
            </cfquery>
            <cfif GET_PRODUCT_IMAGES.recordCount gt 1>
              <cfquery name="GET_PRODUCT_IMAGES_MANY" datasource="#DSN1#">
                SELECT
                  PATH,
                  IS_COVER
                FROM
                  PRODUCT_IMAGES
                WHERE
                  PRODUCT_ID = #GET_OFFER_ROWS.PRODUCT_ID#
              </cfquery>
              <cfloop query="GET_PRODUCT_IMAGES_MANY">
                <cfif IS_COVER eq 1>
                  <cf_get_server_file output_file="../../documents/product/#GET_PRODUCT_IMAGES_MANY.PATH#" image_height="80" output_server="1" output_type="5">
                </cfif>
              </cfloop>
            <cfelseif GET_PRODUCT_IMAGES.recordCount eq 1>
              <cf_get_server_file output_file="../../documents/product/#GET_PRODUCT_IMAGES.PATH#" image_height="80" output_server="1" output_type="5">
              <cfelseif GET_PRODUCT_IMAGES.recordCount eq 0>
            </cfif>
          </td>
          <td style="height:80; width:80" colspan="5"><b><p style="color:red">#DETAIL_INFO_EXTRA#</p></b></td>
        </tr>
      </cfif>
        </cfoutput>
        <cfset freight_cost = 0>
        <cfset insurance_cost = 0>
        </table><br />
        <cfif sayfa_sayisi eq j>
        <table width="225" align="right" cellpadding="3" cellspacing="0" border="1px" bordercolor="#EFEFEF">
            <tr>
                <td width="125"><b>Sub Total&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                <td align="right"><cfoutput>#TLFormat((genel_toplam/get_money.rate2),3)# #GET_MONEY.MONEY_TYPE#</cfoutput></td>
            </tr>
            <cfloop query="GET_OFFER_ROWS">
              <cfif PRODUCT_ID eq 35835>
                <tr>
                  <td width="125"><b>Freight Cost&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                  <td align="right"><cfoutput>#TLFormat((PRICE/get_money.rate2),3)# #GET_MONEY.MONEY_TYPE#</cfoutput></td>
              </tr>
              <cfset freight_cost = PRICE>
              </cfif>
            </cfloop>
            <cfloop query="GET_OFFER_ROWS">
              <cfif PRODUCT_ID eq 35836>
                <tr>
                  <td width="125"><b>İnsurance Cost&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                  <td align="right"><cfoutput>#TLFormat((PRICE/get_money.rate2),3)# #GET_MONEY.MONEY_TYPE#</cfoutput></td>
                </tr>
                <cfset insurance_cost = PRICE>
              </cfif>
            </cfloop>            
            <!---
            <tr>
                <td width="125"><b>İskonto <cfif #indirim1# eq 0 > - <cfelse>(<cfoutput>%#indirim1#</cfoutput>)</cfif>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                <td align="right"><cfif #indirim1# eq 0 > Uygulanmıyor <cfelse><cfoutput query="GET_OFFER_ROWS">#TLFormat((sepet_toplam_indirim)/get_money.rate2)# #GET_MONEY.MONEY_TYPE#</cfoutput></cfif></td>
            </tr>
            --->
            <!---
            <tr>
                <td width="125"><b>Ara Toplam &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                <td align="right"><cfoutput>#TLFormat(genel_toplam/get_money.rate2)# #get_offer.other_money#</cfoutput></td>
            </tr>
            --->
            <!---
            <tr>
                <td><b>KDV (%18)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></td>
                <td align="right"><cfoutput>#TLFormat(((genel_toplam/get_money.rate2)/100)*18)# #get_offer.other_money#</cfoutput></td>
            </tr>
            --->
            <cfscript>
              genel_toplam = genel_toplam+freight_cost+insurance_cost
            </cfscript>
            <tr>
                <td><b> Total Amount &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </b></td>
                <td align="right"><cfoutput>#TLFormat(((genel_toplam)/get_money.rate2),3)# #get_offer.other_money#</cfoutput></td>
                <!--- ihracat olduğu için kdv kaldırıldı --->
                <!--- 
                <td align="right"><cfoutput>#TLFormat((genel_toplam/get_money.rate2)*1.18)# #get_offer.other_money#</cfoutput></td>
                --->
            </tr>
        </table>
        </cfif>
        </td>
	</tr>
    <tr>
    </tr>
</table>

<table width="700" cellpadding="3" height="100" cellspacing="0" border="0" bordercolor="#EFEFEF">
<cfif sayfa_sayisi eq j>
     <tr>
        <td> <hr /></td>
     </tr>
     <tr>
      <td colspan="2"><font size="-2"><b>Details: <cfoutput>#GET_OFFER.OFFER_DETAIL#</cfoutput>
       </td>
     </tr>
     <!---
     <tr>
       <td colspan="2"><font size="-2"><b>      Teklif Şartları:</b><br />
           1. Fiyatlara aksi belirtilmedikçe K.D.V. dahil değildir.<br />
           2. Fiyatlar aksi belirtilmedikçe USD (Amerikan Doları) cinsinden ve peşin ödeme esasına göre verilmiştir.<br />
           3. Teklif edilen ürünler imalat hatalarına karşı, Sanayi Bakanlığı garanti koşulları geçerlidir.<br />
           4. Teklifimiz sadece kuruluşunuz için geçerli olup üçüncü şahıs ve kuruluşlar için geçerli değildir. (Referans gösterilemez)<br />
           5. Teklifimizdeki tüm cihazlar her türlü imalat hatalarına karşı teslim tarihini takiben 2 (iki) yıl garanti kapsamındadır. Garanti süresi<br />
           içerisinde arızalanan cihaz, tamir için alıcı tarafından kuruluşumuz servislerine getirilir.<br />
           6. Ürünler, paketi ve ambalajı zarar görmediği ve kullanılmadığı takdirde, 15 gün yasal süre içerisinde iade alınmaktadır. 15 gün yasal<br /> 
           süreyi geçtiği takdirde iade alınmamaktadır.<br />
           7. Teklifimiz, tarafınızca kaşe ve imzalanıp tarafımıza faxlanmadıkça, kuruluşumuzu yükümlülük altına almaz.<br />
           8. Teslimat, stoktaki malzemeler için Ankara Bilgi Teknolojileri Ltd. ofisidir, Ankara dışı teslimatlarda kargo bedeli tarafınıza aittir. Stokta<br /> 
           olmayan malzemelerin teslimi kesin sipariş ve ödeme alındıktan sonra en az 4 ila 6 hafta arasındadır.<br />
        9. Fiyatlarımıza montaj, bakım ve onarım hizmetleri dahil değildir. <br />
       10. Firmamızdan yerinde montaj desteği alınması halinde tüm yol ve konaklama masrafları (teklif bedelimizin %10'u + K.D.V. olarak hesaplanır) alıcı firmaya fatura edilecektir. <br /> 
       11. Sipariş Onay Formu imzalanana kadar şirketimiz yükümlülük altına girmez. </font> 
       </td>
    </tr>
    --->
</cfif>
</table> 
</br>

<table width="700" cellpadding="2" cellspacing="1" border="0" bordercolor="#EFEFEF">
  <tr align="center">
    <td width="310" height="5" valign="top" align="left"><hr/><br/>
       <b>Terms & Conditions</b><br>
       <p>* Please include the quotation number on your swift message.</p>
    </td>
  </tr>
</table>

<table width="700" cellpadding="2" cellspacing="1" border="0" bordercolor="#EFEFEF">
<cfif sayfa_sayisi eq j>
  <tr align="center">
   <td width="310" height="5" valign="top" align="center"><hr/><p><b>Sales Person</b><br/>
      <cfoutput>
        <cfif len(get_offer.sales_emp_id)>
                #get_emp_info(get_offer.sales_emp_id,0,0)#
        </cfif>
    </cfoutput> <BR>
    <cfoutput>#GET_BRANCH_INFO.EMPLOYEE_EMAIL#</cfoutput>
	</td>
  <!---
	<td width="310" height="5" valign="top" align="center"><hr/><p><b>Teklifi Onaylayan </b></p>
    </td> 
  ---> 
  </tr>
  <tr>
    <tr>
      <td width="700" height="10" valign="top" align="center">
          <cfquery name="GET_EMPLOYEE_ASSET" datasource="#DSN#">
            SELECT TOP 1
              ASSET_FILE
            FROM
              EMPLOYEE_EMPLOYMENT_ROWS
            WHERE
              EMPLOYEE_ID = #get_offer.sales_emp_id#
              AND ASSET_CAT_ID = 30
          </cfquery>
          <cfif len(GET_EMPLOYEE_ASSET.ASSET_FILE)>
            <!---
            <cf_get_server_file output_file="hr/#GET_EMPLOYEE_ASSET.ASSET_FILE#" output_server="#3#" output_type="5" image_width="100">
            --->
            <cfif len(GET_EMPLOYEE_ASSET.ASSET_FILE)>
              <cfset myImage=ImageRead("../../documents/hr/#GET_EMPLOYEE_ASSET.ASSET_FILE#")>
              <cfset ImageResize(myImage,"13%","","blackman",1)>
              <cfimage source="#myImage#" action="writeToBrowser">
            </cfif>
            <!---
            <cfscript>
              TextCharacteristics = { size="20", style="bold", strikethrough="false", underline="false"};
              imgObj = imageNew("",152,152,"rgb","red");
              text = "#get_emp_info(get_action_detail.revenue_collector_id,0,0)#";
              imgObj.drawText("CFDocs",20,50,TextCharacteristics);
              cfimage (action="writeToBrowser", source=imgObj);
            </cfscript>
            --->
            <cfelse>
            &nbsp;
          </cfif>
      </td>
      <td height="1" valign="top" align="center">
        &nbsp;
      </td>
    </tr>
  </tr>
</cfif>
</table>

<!---
<table width="700" cellpadding="2" cellspacing="1" border="0" bordercolor="#EFEFEF">  
<cfif sayfa_sayisi eq j>
  <tr>    
    <td width="310" height="10" valign="top" align="center">
	</br>İmza - Kaşe
	  </td>    
  	<td width="310" height="10" valign="top" align="center">
	</br>İmza - Kaşe    
    </td>	  
  </tr>
</cfif>
</table>
--->
	<cfset satir_start = satir_start + satir_end>
</cfloop>