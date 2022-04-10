<!--- servis destek formu --->
<cfquery name="OUR_COMPANY" datasource="#DSN#">
	SELECT 
		ASSET_FILE_NAME3,
		ASSET_FILE_NAME3_SERVER_ID,
		COMPANY_NAME,
		TEL_CODE,
		TEL,TEL2,
		TEL3,
		TEL4,
		FAX,
		TAX_OFFICE,
		TAX_NO,
		ADDRESS,
		WEB,
		EMAIL
	FROM 
	    OUR_COMPANY 
	WHERE 
	   <cfif isDefined("SESSION.EP.COMPANY_ID")>
		COMP_ID = #SESSION.EP.COMPANY_ID#
	<cfelseif isDefined("SESSION.PP.COMPANY")>	
		COMP_ID = #SESSION.PP.COMPANY#
	</cfif>
</cfquery>
<cfquery name="get_service" datasource="#dsn3#">
	SELECT * FROM SERVICE WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>
<cfquery name="GET_SERVICE_TASK" datasource="#dsn#">
	SELECT 
		PW.PROJECT_EMP_ID,
		PW.OUTSRC_PARTNER_ID
	FROM
		PRO_WORKS PW,
		#dsn3_alias#.SERVICE S
	WHERE
		PW.SERVICE_ID = S.SERVICE_ID AND
		PW.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		S.SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
	GROUP BY
		PW.PROJECT_EMP_ID,
		PW.OUTSRC_PARTNER_ID
</cfquery>
<cfif len(get_service.service_company_id)>
	<cfquery name="get_adres" datasource="#dsn#">
		SELECT
			 COMPANY_ADDRESS AS ADRES,
			 SEMT AS SEMT,
			 COMPANY_TELCODE AS TELCODE,
			 COMPANY_TEL1 AS TEL,
			 TAXOFFICE AS TAX,
			 TAXNO AS TAXNO,
			 COUNTY AS COUNTY,
			 CITY AS CITY,
			 COUNTRY AS COUNTRY
		FROM  
			 COMPANY
		WHERE 
			 COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.service_company_id#">
	</cfquery>
<cfelseif len(get_service.service_consumer_id)>
	<cfquery name="get_adres" datasource="#dsn#">
		SELECT
			 WORKADDRESS AS ADRES,
			 WORKSEMT AS SEMT,
			 CONSUMER_WORKTELCODE AS TELCODE,
			 CONSUMER_WORKTEL AS TEL,
			 TAX_OFFICE AS TAX,
			 TAX_NO AS TAXNO,
			 WORK_COUNTY_ID AS COUNTY,
			 WORK_CITY_ID AS CITY,
			 WORK_COUNTRY_ID AS COUNTRY
		FROM  
			 CONSUMER
		WHERE 
			 CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.service_consumer_id#">
	</cfquery>
	<cfquery name="GET_CONSUMER" datasource="#DSN#">
		SELECT
			*
		FROM
			CONSUMER
		WHERE
			CONSUMER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.service_consumer_id#">
	</cfquery>
	

</cfif>
<cfif len(get_adres.county)>
    <cfquery name="GET_COUNTY" datasource="#dsn#">
        SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_adres.county#">
    </cfquery>
</cfif>
<cfif len(get_adres.city)>
    <cfquery name="GET_CITY" datasource="#dsn#">
        SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_adres.city#">
    </cfquery> 
</cfif>
<cfif len(get_service.subscription_id)>
	<cfquery name="GET_SUBSCRIPTION" datasource="#DSN3#">
		SELECT
			SC.*
		FROM
			SUBSCRIPTION_CONTRACT SC
		WHERE
			SUBSCRIPTION_ID IS NOT NULL AND 
			SC.SUBSCRIPTION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.subscription_id#">
	</cfquery>
</cfif>
<cfquery name="GET_SERVICE_PLUS" datasource="#DSN3#">
	SELECT
		*
	FROM
		SERVICE_PLUS
	WHERE
		SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>
<cfif len(get_service.project_id)>
    <cfquery name="get_project" datasource="#dsn#">
        SELECT 
            PROJECT_HEAD,PROJECT_ID 
        FROM 
            PRO_PROJECTS
        WHERE
            PROJECT_ID IS NOT NULL AND
            PROJECT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.project_id#">
    </cfquery>
</cfif>

<cfquery name="GET_SERVICE_OPERATION" datasource="#DSN3#">
	SELECT
		*
	FROM
		SERVICE_OPERATION
	WHERE
		SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>

<cfif isDefined("GET_SERVICE.SERVICE_COMPANY_ID") and len(GET_SERVICE.SERVICE_COMPANY_ID)>
	<cfquery name="GET_COMPANY" datasource="#DSN#">
		SELECT 
			* 
		FROM 
			COMPANY
		WHERE
			COMPANY_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_SERVICE.SERVICE_COMPANY_ID#">
	</cfquery>

	<cfquery name="GET_COMPANY_PARTNER" datasource="#DSN#">
		SELECT
			*
		FROM
			COMPANY_PARTNER
		WHERE
			PARTNER_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_COMPANY.MANAGER_PARTNER_ID#">
	</cfquery>

<cfelse>
</cfif>

<cfquery name="GET_TOTAL_PRICE" datasource="#DSN3#">
	SELECT SUM(TOTAL_PRICE) AS FIS_TOPLAM FROM SERVICE_OPERATION WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>

<cfquery name="GET_TOTAL_PRICE_MONEY" datasource="#DSN3#">
	SELECT CURRENCY FROM SERVICE_OPERATION WHERE SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.action_id#">
</cfquery>

<cfparam name = "sehir_id" default="">
<cfparam name = "sehir_adi" default ="">

<cfparam name= "ilce_adi" default="">
<cfparam name= "ilce_id" default="">

<cfif isDefined("GET_SERVICE.SERVICE_COMPANY_ID") and len(GET_SERVICE.SERVICE_COMPANY_ID) and isDefined("GET_COMPANY.CITY") and len(GET_COMPANY.CITY)>
	<cfset sehir_id = GET_COMPANY.CITY> 
	<cfset ilce_id = GET_COMPANY.COUNTY>
</cfif>

<cfif isDefined("GET_SERVICE.SERVICE_CONSUMER_ID") and len(GET_SERVICE.SERVICE_CONSUMER_ID) and isDefined("GET_CONSUMER.HOME_CITY_ID") and len(GET_CONSUMER.HOME_CITY_ID)>
	<cfset sehir_id = GET_CONSUMER.HOME_CITY_ID>
	<cfset ilce_id = GET_CONSUMER.HOME_COUNTY_ID>
</cfif>

<cfif isDefined("sehir_id") and len(sehir_id)>
	<cfquery name="GET_CITY" datasource="#DSN#">
		SELECT
			*
		FROM
			SETUP_CITY
		WHERE
			CITY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#sehir_id#">
	</cfquery>
</cfif>

<cfif isDefined("ilce_id") and len(ilce_id)>
	<cfquery name="GET_COUNTY" datasource="#DSN#">
		SELECT
			*
		FROM
			SETUP_COUNTY
		WHERE
			COUNTY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#ilce_id#">
	</cfquery>
</cfif>

<cfif isDefined("GET_COUNTY.CITY_NAME") and len(GET_COUNTY.CITY_NAME)>
	<cfset sehir_adi = GET_CITY.CITY_NAME>
</cfif>
<cfif isDefined("GET_COUNTY.COUNTY_NAME") and len(GET_COUNTY.COUNTY_NAME)>
	<cfset ilce_adi = GET_COUNTY.COUNTY_NAME>
</cfif>



<cfquery name="GET_BRANCH" datasource="#DSN#">
	SELECT
		*
	FROM
		BRANCH
	WHERE
		BRANCH_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#GET_SERVICE.SERVICE_BRANCH_ID#">
</cfquery>

<div class="fis_baski">
	<tr style="text-align:center"><b>BİRİKİM PİLLERİ LTD. ŞTİ.</b></tr></br>
	<tr style="text-align:center;"><b style="font-size:15px"><cfoutput>#OUR_COMPANY.WEB#</cfoutput></b></tr></br>
	<table class="head_table">
		<tr><tr><td><p style="text-align:left">Telefon: <cfoutput>#GET_BRANCH.BRANCH_TELCODE# #GET_BRANCH.BRANCH_TEL1#</cfoutput></p></td><td><p style="text-align:right">Tarih: <cfoutput>#dateformat(now(),"dd.mm.yyyy")#</cfoutput></p></td></tr></tr>
		<tr><tr><td><p style="text-align:left">Fax: <cfoutput>0#GET_BRANCH.BRANCH_FAX#</cfoutput></p></td><td><p style="text-align:right">Saat: <cfoutput>#dateformat(now(),"HH:MM")#</cfoutput></p></td></tr></tr>
	</table>
	<table class="head_table">
		<tr><p style="text-align:center"><cf_workcube_barcode show="1" type="qrcode" height="100" shape="RECTANGLE" value="#GET_SERVICE.SERVICE_NO#"></p></tr>
		<tr><b style="text-align:center; color:darkblue">SERVİS GİRİŞ TUTANAĞI</b></tr></br>
		<td>
			<tr><b style="text-align:center"><cfoutput>#GET_SERVICE.SERVICE_NO#</cfoutput></b></tr></br>
		</td>
		<hr />
	</table>
	<table>
		<tr><b style="text-align:center; font-size:14px">Müşteri Bilgileri</b></tr></br>
		<cfif isDefined("GET_SERVICE.SERVICE_CONSUMER_ID") and len(GET_SERVICE.SERVICE_CONSUMER_ID)>
			<cfoutput>
				<table class="head_table">
					<tr><tr><td><p style="text-align:left">#GET_SERVICE.SERVICE_COUNTY#</p></td><td><p style="text-align:right">#GET_SERVICE.BRING_MOBILE_NO#</p></td></tr></tr>
				</table>
			</cfoutput>
		<cfelse>
		</cfif>
		<cfif isDefined("GET_SERVICE.SERVICE_COMPANY_ID") and len(GET_SERVICE.SERVICE_COMPANY_ID)>
			<cfoutput>
				<tr><p style="font-size:15px"></p></tr>
				<table class="head_table">
					<tr><tr><td><p style="text-align:left">#GET_COMPANY.FULLNAME#</p></td><td><p style="text-align:right">#GET_COMPANY.COMPANY_TELCODE# #GET_COMPANY.COMPANY_TEL1#</p></td></tr></tr>
					<tr><tr><td><p style="text-align:left">#GET_COMPANY_PARTNER.COMPANY_PARTNER_NAME# #GET_COMPANY_PARTNER.COMPANY_PARTNER_SURNAME#</p></td><td><p style="text-align:right">#GET_COMPANY_PARTNER.COMPANY_PARTNER_TELCODE# #GET_COMPANY_PARTNER.COMPANY_PARTNER_TEL#</p></td></tr></tr>
					<tr><tr><td><p style="text-align:left">#sehir_adi#</p></td><td><p style="text-align:right">#ilce_adi#</p></td></tr></tr>
				</table>
			</cfoutput>
		<cfelse>
		</cfif>
	</table>
	<hr />
	<b style="text-align:center">Ürün Bilgileri</b></br>
	<cfoutput query="GET_SERVICE_OPERATION">
		<table>
			<tr>
				<td style="text-align:left">
					#PRODUCT_NAME#
				</td>
			</tr>
			<tr>
				<td>
					#AMOUNT# Adet x #TLFormat(GET_SERVICE_OPERATION.PRICE)# #GET_TOTAL_PRICE_MONEY.CURRENCY#
				</td>
			</tr></cfoutput>
			<tr></tr>
		</table>
		<p style="text-align:right; font-weight:bold;">Genel Toplam:<cfoutput query="GET_TOTAL_PRICE">#FIS_TOPLAM#</cfoutput> <cfoutput query="GET_TOTAL_PRICE">#GET_TOTAL_PRICE_MONEY.CURRENCY#</cfoutput> </p>
		<cfif isDefined("GET_SERVICE.SERVICE_DETAIL") and len(GET_SERVICE.SERVICE_DETAIL)>
			<div style="text-align:left">
				<hr />
				<tr><b>Açıklama: <cfoutput>#GET_SERVICE.SERVICE_DETAIL#</cfoutput></b></tr></br>	
			</div>
		</cfif>
		<hr />
		<div class="sub_detail">
			<table class="sub_detail_table">
				<tr><p>&nbsp;&nbsp;- 3 ay içerisinde teslim alınmayan bataryalardan şirketimiz sorumlu değildir.</p></tr>
				<tr><p>&nbsp;&nbsp;- Li-ion ve Li-polymer batarya gruplarında koruma devresi (PCM) bozuk çıkabilir. Bozuk ise yapılan piller geri alınmaz.</p></tr>
				<tr><p>&nbsp;&nbsp;- Koruma devreleri (PCM) bozuk olup olmadığını test etmemiz mümkün değildir.</p></tr>
				<tr><p>&nbsp;&nbsp;- Plastik kutu içerisindeki batarya gruplarını çıkarma için batarya kesilerek açılır ve oluşacak küçük hasarları müşteri peşinen kabul etmiş sayılır.</p></tr>
				<tr><p>&nbsp;&nbsp;- İçerisi yenilenen bataryalar 6 ay persormans garantilidir.</p></tr>
				<tr><p>&nbsp;&nbsp;- İçerisi yenilenmiş bataryalar çalışmaması halinde birikim pillerine 1 ay içerisinde bildirilmelidir.</p></tr>
			</table>
		</div>
</div>


<style>
	.fis_baski {
		<!---background-color: rgb(246, 246, 246);--->
		border: 1;
		<!---border: 2px solid black;--->
		width: 8cm;
		text-align:center;
	}
	.head_table {
		width:8cm;
		align:center;
	}
	.sub_detail {
		<!---background-color: rgb(246, 246, 246);--->
		border: 1px solid black;
		width: 8cm;
		text-align:left;
		font-size: 12px;
	}
	.sub_detail_table {
		border: 1;
	}
</style>