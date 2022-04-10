<!--- servis destek formu --->
<cfquery name="OUR_COMPANY" datasource="#DSN#">
	SELECT
		ASSET_FILE_NAME2,
		ASSET_FILE_NAME2_SERVER_ID,
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

<cfquery name="GET_WORK_POS" datasource="#DSN#">
	SELECT
		COMPANY_ID,
		OUR_COMPANY_ID,
		POSITION_CODE,
		IS_MASTER
	FROM
		WORKGROUP_EMP_PAR
	WHERE
		COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#get_service.service_company_id#"> AND
		COMPANY_ID IS NOT NULL AND
		IS_MASTER = 1
</cfquery>

<br/><br/><br/>
<table border="0" cellpadding="1" cellspacing="1" style="width:175mm;" align="center">
    <tr height="16">
		<cfoutput query="our_company">
            <td align="left" width="60%">
            <cfif len(our_company.asset_file_name2)>
                <cf_get_server_file output_file="settings/#asset_file_name2#" output_server="#asset_file_name2_server_id#" output_type="5">
            </cfif>&nbsp;
            </td>
            <td style="text-align:left;" width="40%">
                <font class="formbold">#company_name#</font><br/>
                #address#<br/>
                <cf_get_lang_main no='87.Telefon'>: #tel_code# #tel#<br/>
                <cf_get_lang_main no='76.Fax'>: #tel_code# #fax#<br/>
                #web#&nbsp;&nbsp;#email#
            </td>
        </cfoutput>
    </tr>  
</table>
<br/><br/>
<cfoutput query="get_service">
    <table cellpadding="3" cellspacing="0" border="1" style="width:175mm;" align="center">
		<tr>
            <td width="35%" bgcolor="000000">
				<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
					SERVİS FORMU
			   	</font>
				<!---
					<cfif servicecat_id eq 1>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						 İADE FORMU
					</font>
						</cfif> 
					<cfif servicecat_id eq 2>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						KOŞULSUZ İADE FORMU
					</font>
					</cfif> 
					<cfif servicecat_id eq 3>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						DEĞİŞİM FORMU
					</font>
					</cfif>
					<cfif servicecat_id eq 4>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						ARIZA BİLDİRİM FORMU
					</font>
					</cfif>
					<cfif servicecat_id eq 5>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						ŞİKAYET FORMU
					</font>
					</cfif> 
					<cfif servicecat_id eq 6>
					<font color="FFFFFF" size="+1" face="Arial, Helvetica, sans-serif">
						YENİDEN KARGO GÖNDERİM FORMU
					</font>
					</cfif>   
				--->
            </td>
            <td width="32%">
                <font class="formbold">Form No:</font>&nbsp;&nbsp;#service_no#
            </td>
            <td style="text-align:right;" width="32%">
                <font class="formbold"><cf_get_lang_main no='330.Tarih'>:</font>&nbsp;&nbsp;#dateformat(APPLY_date,dateformat_style)#
            </td>
        </tr>
    </table>
<br/><br/>
<table border="0" cellpadding="1" cellspacing="1" style="width:175mm;" align="center">
    <tr height="23">
        <td width="80">
            <font class="txtbold"><cf_get_lang_main no='45.Müşteri'></font>
        </td>
        <td align="left" width="250">
        <cfif len(service_consumer_id)>
            <font class="txtbold">:</font>&nbsp;#get_cons_info(service_consumer_id,0,0)#
        </cfif>
        <cfif len(service_company_id)>
            <font class="txtbold">:</font>&nbsp;#get_par_info(service_company_id,1,1,0)#
        </cfif>
        </td>
        <td width="125"><font class="txtbold">Başvuru Tarihi</font></td>
        <td align="left" width="250"><font class="txtbold">:</font>&nbsp;#dateformat(apply_date,dateformat_style)#</td>
    </tr>
    <tr height="23">
        <td><font class="txtbold"><cf_get_lang_main no='166.Yetkili'></font></td>
        <td><font class="txtbold">:</font> #get_service.applicator_name#</td>
        <td><font class="txtbold"><cf_get_lang_main no='79.Saat'></font></td>
        <td>
        <cfif len(apply_date)>
            <cfset applydate = date_add("H",session.ep.TIME_ZONE,apply_date)>
        </cfif>
            <font class="txtbold">:</font>&nbsp;<cfif len(apply_date)>#timeformat(applydate,'HH:MM:SS')#</cfif>
        </td>
    </tr>
    <tr height="23">
        <td><font class="txtbold"><cf_get_lang_main no='1311.Adres'></font></td>
		<td>
			<font class="txtbold">:</font>&nbsp;#get_adres.adres#<br/>
			<cfif len(get_adres.county)>
            	#get_county.county_name#
            </cfif>
            <cfif len(get_adres.city)>
            	#get_city.city_name#
            </cfif>
        </td>
		<td><font class="txtbold"><cf_get_lang_main no='305.Garanti'></font></td>
        <td nowrap="nowrap">
        <table>
            <tr>
                <td><font class="txtbold">:</font><input type="checkbox" style="size:5px;"> <cf_get_lang_main no='83.Evet'></td>
                <td><input type="checkbox" style="size:5px;"> <cf_get_lang_main no='84.Hayır'></td>
            </tr>
        </table>
		</td>
        <!---
		<td><font class="txtbold"><cf_get_lang_main no='1371.Workcube'><cf_get_lang_main no='225.Seri No'></font></td>
        <td><font class="txtbold">:</font>
			<cfif len(get_service.subscription_id)>
            	&nbsp;#get_subscription.subscription_no#
            <cfelse>
            	&nbsp;
            </cfif>
        </td>
		--->
	</tr>
    <tr height="23">
        <td><font class="txtbold"><cf_get_lang_main no='87.Telefon'></font></td>
        <td><font class="txtbold">:</font>&nbsp;#get_adres.telcode# - #get_adres.tel#</td>
		<td>Temsilci</td>
        <td>: <a style="color:black"><cfoutput>#get_emp_info(GET_WORK_POS.POSITION_CODE,1,0)#</cfoutput></a></td>
    </tr>
    <!---
	<tr height="23">        
		
		<td><font class="txtbold"><cf_get_lang no="948.Bakım Anlaşması"></font></td>
        <td nowrap="nowrap">
        <table>
            <tr>
                <td><font class="txtbold">:</font><input type="checkbox" style="size:5px;"> <cf_get_lang_main no='1152.Var'></td>
                <td><input type="checkbox" style="size:5px;"> <cf_get_lang_main no='1134.Yok'></td>
            </tr>
        </table>
        </td>
	
    </tr>
	--->
    <tr height="23">
        <td><font class="txtbold"><cf_get_lang_main no='340.Vergi No'></font></td>
		<td><font class="txtbold">:</font>&nbsp;#get_adres.taxno#</td>
		<td><font class="txtbold"><cf_get_lang_main no='1350.Vergi Dairesi'></font></td>
        <td><font class="txtbold">:</font>&nbsp;#get_adres.tax#</td>
        <!---
		<td><font class="txtbold"><cf_get_lang_main no='4.Proje'></font></td>
        <td nowrap="nowrap">
        <table>
            <tr>
                <td><font class="txtbold">: </font>
				<cfif len(get_service.project_id)>
                    #get_project.project_head#
				<cfelse>
                    &nbsp;
				</cfif>
                </td>
                <td></td>
            </tr>
        </table>
		</td>
		--->
	</tr>	
</table>
<cfif isdefined ("service_product_id") and len (service_product_id)>
	<cfquery name="get_prod" datasource="#dsn1#">
		SELECT
			MANUFACT_CODE,
			PRODUCT_CODE_2
		FROM
			PRODUCT
		WHERE
			PRODUCT_ID = #get_service.service_product_id#
	</cfquery>
</cfif>
<hr style="width:175mm;">
<table border="0" cellpadding="1" cellspacing="1" style="width:175mm;" align="center">
    <tr style="height:28mm;" valign="top">
        <td>
			<b>Fatura No:</b> #bring_name#<br/><br/>
            <b><cf_get_lang_main no='68.Konu'> </b>:&nbsp;#service_head#<br/>
            <b>Açıklama :</b><cfset new_detail = replace(service_detail,'#chr(13)#','<br/>','all')>
            #new_detail#<br/><br/>
			<cfif isdefined ("service_product_id") and len (service_product_id)>
				<b>Ürün Kodu:</b> #get_prod.manufact_code# <cfif isdefined ("get_prod.product_code_2") and len (get_prod.product_code_2)>/ #get_prod.product_code_2#</cfif><br/>
				<b>Ürün Adı:</b> #product_name#
			</cfif>
        </td>
    </tr>
</table>
</cfoutput>
<table cellpadding="3" cellspacing="0" border="1" style="width:175mm;height:72mm;" align="center">
    <tr valign="top">
        <td width="75%" height="50%">
            <font class="txtbold">Uygulanan İşlemler :</font><br/>
             <cfoutput query="get_service_plus">
                #plus_content#
             </cfoutput>
        </td>
		<!---
        <td width="25%" height="50%">
		<table>
			<tr>
				<td><font class="txtbold">İşlem Tipleri:</font></td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Kurulum</td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Upgrade</td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Kullanım Desteği</td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;">Eğitim</td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Diğer</td>
			</tr>
		</table>
        </td>
		--->
      </tr>
<!---   
   <tr valign="top">
		<td width="75%" height="45%">
			<br/><font class="txtbold"><cf_get_lang_main no='157.Görevli'> :</font> 
			<cfoutput query="get_service_task">
				<cfif len(get_service_task.project_emp_id) and get_service_task.project_emp_id neq 0>
                   #get_emp_info(get_service_task.project_emp_id,0,0)#, 
                <cfelseif len(get_service_task.outsrc_partner_id) and get_service_task.outsrc_partner_id neq 0>
                   #get_par_info(get_service_task.outsrc_partner_id,0,-1,0)#, 
                </cfif>
            </cfoutput><br/><br/>
			<cfoutput>
                <font class="txtbold">Servis Tarihi </font> <br/><br/>
                <cfset startdate=date_add("H",session.ep.TIME_ZONE,get_service.start_date)>
                <cfif len(get_service.finish_date)>
                    <cfset finishdate=date_add("H",session.ep.TIME_ZONE,get_service.finish_date)>
                </cfif>
                <font class="txtbold"><cf_get_lang_main no='1055.Başlama'> :</font> Saat : &nbsp;#timeformat(startdate,'HH:MM:SS')#&nbsp;&nbsp;#dateformat(get_service.start_date,dateformat_style)#
                <font class="txtbold"><cf_get_lang_main no='90.Bitiş'> :</font> Saat : &nbsp;<cfif len(get_service.finish_date)>#timeformat(finishdate,'HH:MM:SS')#</cfif>&nbsp;&nbsp;#dateformat(get_service.finish_date,dateformat_style)#
                <br/><br/>
                <cfif len(startdate) and len(get_service.finish_date)>
                    <cfset d3=DATEDIFF('h',startdate,finishdate)>
                    <cfset minute_=DATEDIFF('N',startdate,finishdate) mod 60>
                </cfif>
                <cf_get_lang no="962.Toplam Çalışma Saat"> : <cfif len(startdate) and len(get_service.finish_date)>#d3# <cf_get_lang_main no='79.Saat'> #minute_# <cf_get_lang_main no='715.dakika'></cfif>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Adam Gün :
                </td>
            </cfoutput>
        <td width="25%" height="45%">
		<table>
			<tr>
			    <td><font class="txtbold">Hizmet Yeri</font></td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Müşteri</td>
			</tr>
			<tr>
				<td><input type="checkbox" style="size:5px;"> Pilburada</td>
			</tr>
			
		</table>
		</td>
	</tr>
	--->
</table>
<br/><br/>
<!---
<table border="0" cellpadding="1" cellspacing="1" style="width:175mm;" align="center">
	<tr valign="top" height="30">
		<td width="60%">
			<font class="txtbold"><cf_get_lang_main no='45.Müşteri'><cf_get_lang_main no='88.Onay'> :</font>
		</td>
		<td width="40%">
			<font class="txtbold"><cf_get_lang_main no='55.Not'> :</font>
		</td>
	</tr>
	<tr valign="top" height="30">
		<td>
			<font class="txtbold"><cf_get_lang_main no='45.Müşteri'><cf_get_lang_main no='166.Yetkili'> :</font>
		</td>
		<td>&nbsp;</td>
	</tr>
	<tr valign="top" height="30">
		<td>
			<font class="txtbold"><cf_get_lang_main no='330.Tarih'> :</font>
		</td>
		<td>&nbsp;</td>
	</tr>
</table>
--->
