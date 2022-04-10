<!--- 
    Description: Mail Order Form Şablonu - Birikim Pilleri
    File: BD94CBBC-BBFA-7439-56BBD4BE47CBC54D.cfm
    Author: Birikim Pilleri - Yunus Emre Yazıcı
    Date: 27.05.2021
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
    STOCKS.PRODUCT_ID AS PRODUCT_ID
  FROM
    OFFER_ROW 
    LEFT JOIN STOCKS ON STOCKS.PRODUCT_ID = OFFER_ROW.PRODUCT_ID
  WHERE	
    OFFER_ID = #attributes.action_id#
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
                  <tr><td>Şube</td><td><b>: #GET_BRANCH_INFO.BRANCH_FULLNAME#</b></td></tr>
                  <tr><td>Adres</td><td><b>: #GET_BRANCH_INFO.BRANCH_ADDRESS#</b></td></tr>
                  <tr><td>Vergi D. / No</td><td><b>: #CHECK.TAX_OFFICE# / #CHECK.TAX_NO#</b></td></tr>
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
          <tr><td>Tarih</td><td><b><cfoutput>: #dateformat(dateadd('h',session.ep.time_zone,get_offer.offer_date),'dd/mm/yyyy')#</cfoutput></b></td></tr>
          <tr><td>Teklif No</td><td><b><cfoutput>: #get_offer.offer_number# </cfoutput></b></td></tr>
          <tr><td>Geçerlilik Tarihi</td><td><b><cfoutput>: #dateformat(get_offer.finishdate,"dd/mm/yyyy")#</cfoutput></b></td></tr>
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
      <td colspan="4" align="center"><b style="font-size:20px">MAIL ORDER</b></td>
    </tr>
  </table>
</cfif> 
</cfoutput>
<br>
  <br>
  <table width="700">
    <tr>
      <td width="100" class="txtbold">Firma Kodu: </td>
      <td colspan="2">
          <p>
            <cfoutput>
              #get_company.member_code#
            </cfoutput><hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Firma Adı: </td>
      <td colspan="2">
          <p>
            <cfoutput>
              #get_company.fullname#
            </cfoutput><hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Tel: </td>
      <td colspan="2">
        <p>
          <cfif isDefined("get_company.company_tel1") and len(get_company.company_tel1)>
          <cfoutput>#get_company.company_tel1#</cfoutput>
          <cfelse> Telefon Numarası Kayıtlı Değil
        </cfif><hr>
        </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Fax: </td>
      <td colspan="2">
          <p>
            <cfif isDefined("get_company.company_fax") and len(get_company.company_fax)>
              <cfoutput>#get_company.company_fax#</cfoutput>
              <cfelse> Fax Numarası Kayıtlı Değil
            </cfif><hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Email: </td>
      <td colspan="2">
          <p>
            <cfif isDefined("get_company.company_email") and len(get_company.company_email)>
                <cfoutput>#get_company.company_email#</cfoutput>
              <cfelse> Email Kayıtlı Değil
            </cfif><hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Adres: </td>
      <td colspan="2">
          <p>
            <cfif isDefined("get_company.company_address") and len(get_company.company_address)>
                <cfoutput>#get_company.company_address#</cfoutput>
              <cfelse> Adres Kayıtlı Değil
            </cfif><hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">İl - İlçe: </td>
      <td colspan="1">
          <p>
            <cfif isDefined("get_city.city_name") and len(get_city.city_name)>
              <cfoutput>#get_city.city_name#</cfoutput>
            <cfelse> İl Kayıtlı Değil
            </cfif><hr>
          </p>
      </td>
      <td colspan="1">
          <p>
            <cfif isDefined("get_county.county_name") and len(get_company.company_address)>
              <cfoutput>#get_county.county_name#</cfoutput>
            <cfelse>İlçe Kayıtlı Değil
          </cfif><hr>
          </p>
      </td>
    </tr>
    
    <tr>
      <td width="100" class="txtbold">Kart Bilgileri: </td>
      <td width="310" height="10" align="left"><p><label align="center" for="visa"><b>Visa&nbsp;&nbsp;&nbsp;</b></label><input class="checkbox" id="vehicle1" name="vehicle1" value="" readonly="yes"><br/>
     </td>
     <td width="310" height="10" align="left"><p><label align="center" for="mastercard"><b>Mastercard&nbsp;&nbsp;&nbsp;</b></label><input class="checkbox" id="vehicle1" name="vehicle1" value="" readonly="yes"></p>
       </td>  
     </tr>
    </tr>
    
    <!---
   <tr>
    <td width="100" class="txtbold">Kart Bilgileri: </td>
      <td width="310" height="10" align="left"><label>Visa</label><h2>☐</h2>  
    </td>
    <td width="310" height="10" align="left"><label>Visa</label><h2>☐</h2> 
    </td>
   </tr>
  --->
     <!---
    <tr>
      <td width="100" class="txtbold">Kart Bilgileri: </td>
      <td colspan="2">
          <p>Visa<hr></p>
      </td>
      <td colspan="2">
          <p>Master<hr></p>
      </td>
    </tr>
     --->
    <tr>
      <td width="100" class="txtbold">Banka: </td>
      <td colspan="2">
          <p>
            - <hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Kart Sahibinin Adı Soyadı: </td>
      <td colspan="2">
          <p>
            - <hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Kredi Kart No: </td>
      <td colspan="2">
          <p>
            - <hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Son Kullanma Tarihi: </td>
      <td colspan="2"> 
          <p>
            - <hr> ( Kartın arka yüzündeki 3 haneli sayı )
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Güvenlik No: </td>
      <td colspan="2">
          <p>
            - <hr>
          </p>
          BİRİKİM PİLLERİ BATARYA SANAYİ VE TİC. LTD. ŞTİ. tarafından yukarıda belirtilen kredi kartımdan aşağıda belirtilen tutarın çekilmesini onaylıyorum.
        </br></br>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Peşin: </td>
      <td width="310" height="10" align="left"><p><input class="checkbox" id="vehicle1" name="vehicle1" value="" readonly="yes"><br/><br/>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Miktar (Rakamla): </td>
      <td colspan="2">
        <cfset toplam_ = 0>
          <cfset iskonto_ = 0>
          <cfset genel_toplam_ = 0>
          <cfset disc_cost = 0>
          <cfset tax_total = 0>
          <cfoutput query="get_offer_rows" startrow="#satir_start#" maxrows="#satir_end#">
            <cfif len(offer_id)>
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
              <cfset toplam_ = PRICE>
              <!--- <cfset genel_toplam_ = PRICE_OTHER*QUANTITY> --->
              <cfset genel_toplam_ = genel_toplam_ + row_total>
              <cfif Len(discounttotal)><cfset iskonto_ = discounttotal><cfelse><cfset iskonto_ = 0></cfif>
            </cfif>
          </cfoutput>
           <!---
          <tr>
            <td colspan="3">
              <table>
                <tr>
                  <td><strong>TOPLAM (KDV hariç) </strong></td>
                </tr>
                <tr>
                  <td nowrap="nowrap"><strong>KDV(%18)</strong></td>
                </tr>
                <tr>
                  <td><strong>TOPLAM (KDV dahil)</strong></td>
                </tr>
              </table>
            </td>
            <td colspan="2">
              <table>
                <tr>
                  <td align="right">&nbsp;<cfoutput>#TLFormat(genel_toplam_)#</cfoutput></td>
                </tr>
                <tr>
                  <td align="right">&nbsp;<cfoutput>#TLFormat((genel_toplam_/100)*18)#</cfoutput></td>
                </tr>
                <tr>
                  <td align="right">&nbsp;<cfoutput>#TLFormat(get_offer.PRICE)#</cfoutput></td>
                </tr>
              </table>
            </td>
          </tr>
          --->
          <p>
            <cfoutput>#TLFormat((((genel_toplam/get_money.rate2)*1.18)),3)# #get_offer.other_money#</cfoutput>&nbsp;<hr>
          </p>
      </td>
    </tr>
    <tr>
      <td width="100" class="txtbold">Miktar (Yazı ile): </td>
      <td colspan="2">
        <cfset para_yazi = (((genel_toplam/get_money.rate2)*1.18))>
            <cfif get_offer.other_money eq 'TL'>
              <cf_n2txt number="para_yazi" para_birimi="TL" alt_para_birimi="Kr">
              <cfelseif get_offer.other_money eq 'EUR' >
                <cf_n2txt number="para_yazi" para_birimi="EUR" alt_para_birimi="Cent">
              <cfelseif get_offer.other_money eq 'USD' >
                <cf_n2txt number="para_yazi" para_birimi="USD" alt_para_birimi="Cent">
            </cfif>
          <p>
            <cfoutput>#para_yazi#</cfoutput> <hr>
          </p>
    </tr>
        <tr>
          <td width="100" class="txtbold">Çekim Tarihi: </td>
          <td colspan="2">
              <p>
                - <hr>
              </p>
      </td>
    </tr>
    <tr>
  </table>
  
<table width="700" cellpadding="2" cellspacing="1" border="0" bordercolor="#EFEFEF">
  <tr>
   <td width="310" height="5" valign="top" align="center"><p><b>Kart Sahibi imza</b><br/>
      -
	</td>
  <td width="310" height="5" valign="top" align="center"><p><b>Firma imza</b><br/>
    -
</td>
  </tr>
</table>
<table width="700" border="0" bordercolor="#EFEFEF">
  <tr>
  <br/><br/><td width="310" height="5" valign="top" align="center"><p><b>Yukarıdaki formu eksiksiz doldurup, <cfoutput>0#CHECK.TEL_CODE# #CHECK.FAX#</cfoutput> nolu faks numarasına gönderiniz. Yaşanacak problemler ile ilgili satış temsilciniz veya <cfoutput>0#CHECK.TEL_CODE# #CHECK.TEL#</cfoutput> / 1201 numaradan muhasebe departmanı ile görüşünüz
   </b><br/>
	</td>
  </tr>
</table>

<style>
.txtbold {font-weight: bold;}
h1 {text-align: center; font-size: larger; font-weight: bold;}
h2 {text-align: left; font-size: 30px;}
<!---p {text-align: center;}--->
div {text-align: center;}
.checkbox {width: 35px; height: 25px;}
.bigchecklabel {font-size: larger;}
</style>