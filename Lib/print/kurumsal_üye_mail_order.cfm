<!---
	Date : 01.01.2022
	Desc : Muhasebe Mail Order Şablonudur.
	Dev  : Yunus Emre Yazıcı - Birikim Pilleri
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

<cfquery name="GET_COMPANY" datasource="#DSN#">
	SELECT
		C.MEMBER_CODE,
		C.FULLNAME,
		C.COMPANY_TELCODE,
		C.COMPANY_TEL1,
		C.COMPANY_FAX,
		C.COMPANY_EMAIL,
		C.COMPANY_ADDRESS,
		C.POS_CODE,
		CP.COMPANY_PARTNER_NAME,
		CP.COMPANY_PARTNER_SURNAME,
		S_CITY.CITY_NAME,
		S_COUNTY.COUNTY_NAME,
		EP.EMPLOYEE_NAME,
		EP.EMPLOYEE_SURNAME
	FROM
		COMPANY C
		LEFT JOIN COMPANY_PARTNER CP ON CP.COMPANY_ID = C.COMPANY_ID
		LEFT JOIN SETUP_CITY S_CITY ON S_CITY.CITY_ID = C.CITY
		LEFT JOIN SETUP_COUNTY S_COUNTY ON S_COUNTY.COUNTY_ID = C.COUNTY
		LEFT JOIN EMPLOYEE_POSITIONS EP ON EP.POSITION_ID = C.POS_CODE
	WHERE
		CP.PARTNER_ID = #attributes.action_id#
</cfquery>

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
                <b style="font-size:13px"><cfoutput>#CHECK.company_name#</cfoutput></b>
                <table>
					<tr><td><cfoutput>#CHECK.ADDRESS#</cfoutput></td></tr>
					<tr><td><cfoutput>#CHECK.TAX_OFFICE# VD.</cfoutput><cfoutput>#CHECK.TAX_NO#</cfoutput></td></tr>
					<tr><td><cfoutput>TEL:0#CHECK.TEL_CODE# #CHECK.TEL#</cfoutput> <cfoutput>TEL:0#CHECK.TEL_CODE# #CHECK.FAX#</cfoutput></td></tr>
                </table>
            </td>
          </tr>
        </table>
      </td>
      <td align="right">
        <table align="right">
          <tr><td>Tarih</td><td><b><cfoutput>: #dateformat(dateadd('h',session.ep.time_zone,now()),'dd/mm/yyyy')#</cfoutput></b></td></tr>
          <tr><td>M. Temsilciniz</td><td><b>: <cfoutput query="GET_COMPANY">#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</cfoutput></b></td></tr>
        </table>
      </td>
    </tr>
  </table>
  <table width="700">
    <tr align="center">
      <td colspan="4" align="center"><b style="font-size:20px">MAIL ORDER</b></td>
    </tr>
  </table>
  <cfoutput query="GET_COMPANY">
	<table width="700">
		<tr>
		<td width="100" class="txtbold">Firma Kodu: </td>
		<td colspan="2">
			<p>
				#MEMBER_CODE#<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">Firma Adı: </td>
		<td colspan="2">
			<p>
				#FULLNAME#;<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">Tel: </td>
		<td colspan="2">
			<p>
				0#COMPANY_TELCODE# #COMPANY_TEL1#<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">Fax: </td>
		<td colspan="2">
			<p>
				0#COMPANY_TELCODE# #COMPANY_FAX#<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">Email: </td>
		<td colspan="2">
			<p>
				#COMPANY_EMAIL#<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">Adres: </td>
		<td colspan="2">
			<p>
				#COMPANY_ADDRESS#<hr>
			</p>
		</td>
		</tr>
		<tr>
		<td width="100" class="txtbold">İl - İlçe: </td>
		<td colspan="1">
			<p>
				#CITY_NAME#<hr>
			</p>
		</td>
		<td colspan="1">
			<p>
				#COUNTY_NAME#<hr>
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
			<td width="100" class="txtbold">Son Kullanım Tarihi : </td>
			<td colspan="2">
				<p>
				 &nbsp;<hr>
				</p>
			</td>
		</tr>
		<tr>
			<td width="100" class="txtbold">Güvenlik No: </td>
			<td colspan="2">
				<p>
					( Kartın arka yüzündeki 3 haneli sayı ) <hr>
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
		</tr>
		<tr>
			<td width="100" class="txtbold">Miktar (Yazı ile): </td>
				<td colspan="2">
					<p>
					&nbsp;<hr>
					</p>
				</td>
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
  </cfoutput>
  
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