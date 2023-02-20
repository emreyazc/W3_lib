<!---
Oluşturulacak veritabanı collation a dikkat edilsin ve bu uyarıyı comment içine alarak sayfanızı refresh edin.. 20030429
COLLATE Turkish_CI_AS 
COLLATE SQL_Latin1_General_CP1_CI_AS
COLLATE Latin1_General_CI_AS
<cfabort>
 --->
<cfif attributes.is_special_period_date eq 1 and len(attributes.start_date) and len(attributes.finish_date)>
	<cfset attributes.start_date = attributes.start_date>
	<cfset attributes.finish_date = attributes.finish_date>
<cfelse>
	<cfset attributes.start_date="01/01/#period_year#">
	<cfset attributes.finish_date="31/12/#period_year#">
</cfif>
<cf_date tarih='attributes.start_date'>
<cf_date tarih='attributes.finish_date'>
<cfif attributes.is_special_period_date eq 1>
	<cfquery name="get_old_db" datasource="#DSN#">
		SELECT
			PERIOD_YEAR,
			OUR_COMPANY_ID
		FROM
			SETUP_PERIOD
		WHERE
			OUR_COMPANY_ID = #COMPANY_ID# AND
			(
				((#attributes.start_date# BETWEEN START_DATE AND FINISH_DATE) OR
				(#attributes.finish_date# BETWEEN START_DATE AND FINISH_DATE)) OR
				(
                    (START_DATE BETWEEN #attributes.start_date# AND #attributes.finish_date#) OR
                    (FINISH_DATE BETWEEN #attributes.start_date# AND #attributes.finish_date#)
				)
			) OR PERIOD_YEAR = #PERIOD_YEAR#
	</cfquery>
	<cfif get_old_db.recordcount>
		<script type="text/javascript">
			alert("<cf_get_lang no ='2514.Bu Firma ve Döneme ait Kayıt bulunmaktadır'>. Lütfen Tarih Aralığını Kontrol Ediniz!");
			history.back();
		</script>
		<cfabort>
	</cfif>
<cfelse>
	<cfquery name="get_old_db" datasource="#DSN#">
		SELECT
			PERIOD_YEAR,
			OUR_COMPANY_ID
		FROM
			SETUP_PERIOD
		WHERE
			PERIOD_YEAR = #PERIOD_YEAR# AND
			OUR_COMPANY_ID = #COMPANY_ID#
	</cfquery>


	<cfif get_old_db.recordcount>
		<script type="text/javascript">
			alert("<cf_get_lang no ='2514.Bu Firma ve Döneme ait Kayıt bulunmaktadır'>!");
			history.back();
		</script>
		<cfabort>
	</cfif>
</cfif>
 <!--- //donem db varmi --->
 
<cfif not len(attributes.period_date)>
	<cfset attributes.period_date="01/01/#period_year#">
</cfif>
<cfif not len(attributes.budget_period_date)>
	<cfset attributes.budget_period_date="01/01/#period_year#">
</cfif>
<cf_date tarih='attributes.period_date'>
<cf_date tarih='attributes.budget_period_date'>
<cfquery name="get_period" datasource="#dsn#">
	SELECT PERIOD_ID FROM SETUP_PERIOD
</cfquery>
<cfif get_period.recordcount and ( isdefined("attributes.is_old_account_plan") and attributes.is_old_account_plan eq 1 )>
	<cfset old_account_plan = 1>
<cfelse>
	<cfset old_account_plan = 0>
</cfif>

<cflock name="#CREATEUUID()#" timeout="20">
	<cftransaction>
		<cfquery name="get_period_id" datasource="#dsn#">
			SELECT MAX(PERIOD_ID) AS MAX_ID FROM SETUP_PERIOD
		</cfquery>
		<cfif isnumeric(get_period_id.max_id)>
			<cfset max_id = get_period_id.max_id + 1>
		<cfelse>
			<cfset max_id = 1>
		</cfif>

		<cfquery name="INS_PERIOD" datasource="#DSN#">
			INSERT INTO 
				SETUP_PERIOD
            (
                PERIOD_ID,
                PERIOD,
                PERIOD_YEAR,
                IS_INTEGRATED,
                OUR_COMPANY_ID,
                PERIOD_DATE,
                BUDGET_PERIOD_DATE,
                OTHER_MONEY,
                STANDART_PROCESS_MONEY,
                INVENTORY_CALC_TYPE,
                RECORD_DATE,
                RECORD_IP,
                RECORD_EMP,
                START_DATE,
                FINISH_DATE
            ) 
			VALUES 
            (
                #MAX_ID#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#period_name#">,
                #PERIOD_YEAR#,
            <cfif isdefined("is_integrated")>
                #IS_INTEGRATED#
            <cfelse>
                0
            </cfif>,
                #COMPANY_ID#,
                #attributes.period_date#,
                #attributes.budget_period_date#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.other_money#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.standart_process_money#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.inventory_calc_type#">,
                #NOW()#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
                #SESSION.EP.USERID#,
                #attributes.start_date#,
                #attributes.finish_date#
            )
		</cfquery>

		<cfquery name="GET_MAX_ID" datasource="#dsn#">
			SELECT MAX(PERIOD_ID) AS MAX_ID FROM SETUP_PERIOD
		</cfquery>

        <cfquery name = "get_last_money" datasource="#dsn#">
        	SELECT TOP 1 MONEY,CURRENCY_CODE FROM SETUP_MONEY WHERE COMPANY_ID = #COMPANY_ID# AND RATE1 = RATE2 ORDER BY MONEY_ID DESC
        </cfquery>
        <cfif get_last_money.recordcount eq 1>
        	<cfset new_period_money = get_last_money.money>
        	<cfset new_period_currency_code = get_last_money.currency_code>
        <cfelse>
        	<cfset new_period_money = attributes.standart_process_money>
            <cfif attributes.standart_process_money eq 'TL'>
            	<cfset new_period_currency_code = 'TRY'>
        	<cfelse>
            	<cfset new_period_currency_code = attributes.standart_process_money>
            </cfif>
        </cfif>
		<cfquery name="ADD_SETUP_MONEY" datasource="#DSN#">
			INSERT INTO 
				SETUP_MONEY
            (
                
                MONEY,
                RATE1,
                RATE2,
                RATE3,
                EFFECTIVE_SALE,
                EFFECTIVE_PUR,
                RATEPP2,
                RATEPP3,
                RATEWW2,
                RATEWW3,
                MONEY_STATUS,
                COMPANY_ID,
                CURRENCY_CODE,
                PERIOD_ID,
                RECORD_DATE,
                RECORD_EMP,
                RECORD_IP
            )
			VALUES
            (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_period_money#">,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                1,
                #COMPANY_ID#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#new_period_currency_code#">,
                #get_max_id.max_id#,
                #now()#,
                #session.ep.userid#,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.remote_addr#">
            )
		</cfquery>
	</cftransaction>
</cflock>

<cfif fusebox.use_period>
	<cftry>
		<cfif isdefined("attributes.db_username")>
			<cfset db_user_ = attributes.db_username>
			<cfset db_pass_ = attributes.db_password>
            <cfset cf_admin_password = attributes.cf_admin_password>
		<cfelse>
			<cfset db_user_ = database_username>
			<cfset db_pass_ = database_password>
		</cfif>
		<!--- Musterilerde workcube dosyalari ile documents ayni dizinde olmadigi zaman, paramdaki upload folder kullanildiginda, add_period_db taginde admin_tools xmllerini bulamiyor, bu yuzden workcube e ulasmasini bu sekilde sagladik FBS 20140528 --->
		<cfset upload_folder = '#index_folder#admin_tools#dir_seperator#'>
		<cfif database_type IS "MSSQL">
			<cf_add_period_db username="#db_user_#" is_old_account="#old_account_plan#" password="#db_pass_#" period_id="#get_max_id.max_id#" dsn="#dsn#" host="#database_host#" upload_folder="#upload_folder#">
		<cfelseif database_type IS "DB2">
			<cf_add_period_db_db2 username="#db_user_#" is_old_account="#old_account_plan#" password="#db_pass_#" period_id="#get_max_id.max_id#" dsn="#dsn#" host="#database_host#" upload_folder="#upload_folder#">
		</cfif>
		<cfcatch type="any">
		<cfsavecontent variable="hata_">
			<cfdump var="#cfcatch#">
		</cfsavecontent>
		<cffile action="write" file="c:/test_period_hata.html" output="#hata_#">
        	<cfset new_dsn_ = '#dsn#_#period_year#_#attributes.COMPANY_ID#'>
        
			<cfquery name="del_" datasource="#dsn#">
				DELETE FROM SETUP_PERIOD WHERE PERIOD_ID = #get_max_id.max_id#
			</cfquery>
			<cfquery name="del_2" datasource="#dsn#">
				DELETE FROM SETUP_MONEY WHERE PERIOD_ID = #get_max_id.max_id#
			</cfquery>
            
            <cfquery name="getActiveLogin" datasource="_#dsn#">
            	SELECT spid FROM sys.sysprocesses where loginame = '#new_dsn_#'
            </cfquery>	
            <cfif getActiveLogin.recordcount>
            	<cfquery name="killActiveLogin" datasource="_#dsn#">
                   kill #getActiveLogin.spid#
                </cfquery>
            </cfif>
            
            <cfquery name="delUser" datasource="_#dsn#">
            	DROP USER #new_dsn_#
            </cfquery>
            <cfquery name="delLogin" datasource="_#dsn#">
				DROP LOGIN #new_dsn_#
            </cfquery>
            
            <cfquery name="getSchemaTables" datasource="_#dsn#">
                SELECT  'DROP TABLE #new_dsn_#.' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13) AS DEL_TABLE
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = '#new_dsn_#'
                    AND TABLE_TYPE = 'BASE TABLE'
            </cfquery>
            
            <cfif getSchemaTables.recordcount>
                <cfquery name="delSchemaTables" datasource="_#dsn#">
                    <cfloop query="getSchemaTables">
                        #DEL_TABLE#
                    </cfloop>
                </cfquery>
            </cfif>
            
            <cfquery name="getSchemaViews" datasource="_#dsn#">
                SELECT  'DROP VIEW #new_dsn_#.' + QUOTENAME(TABLE_NAME) + ';' + CHAR(13) AS DEL_TABLE
                FROM INFORMATION_SCHEMA.TABLES
                WHERE TABLE_SCHEMA = '#new_dsn_#'
                    AND TABLE_TYPE = 'VIEW'
            </cfquery>
            
            <cfif getSchemaViews.recordcount>
                <cfquery name="delSchemaViews" datasource="_#dsn#">
                    <cfloop query="getSchemaViews">
                        #DEL_TABLE#
                    </cfloop>
                </cfquery>
            </cfif>
            
            <cfquery name="getSchemaProcedures" datasource="_#dsn#">
                SELECT  'DROP PROCEDURE #new_dsn_#.' + QUOTENAME(ROUTINE_NAME) + ';' + CHAR(13) AS DEL_TABLE
                FROM INFORMATION_SCHEMA.ROUTINES
                WHERE ROUTINE_SCHEMA = '#new_dsn_#'
                    AND ROUTINE_TYPE = 'PROCEDURE'
            </cfquery>
            
            <cfif getSchemaProcedures.recordcount>
                <cfquery name="delSchemaProcedures" datasource="_#dsn#">
                    <cfloop query="getSchemaProcedures">
                        #DEL_TABLE#
                    </cfloop>
                </cfquery>
            </cfif>

            <cfquery name="getSchemaFunctions" datasource="_#dsn#">
                SELECT  'DROP FUNCTION #new_dsn_#.' + QUOTENAME(ROUTINE_NAME) + ';' + CHAR(13) AS DEL_TABLE
                FROM INFORMATION_SCHEMA.ROUTINES
                WHERE ROUTINE_SCHEMA = '#new_dsn_#'
                    AND ROUTINE_TYPE = 'FUNCTION'
            </cfquery>
            
            <cfif getSchemaFunctions.recordcount>
                <cfquery name="delSchemaFunctions" datasource="_#dsn#">
                    <cfloop query="getSchemaFunctions">
                        #DEL_TABLE#
                    </cfloop>
                </cfquery>
            </cfif>
            <cfquery name="delSchema" datasource="_#dsn#">
            	DROP SCHEMA #new_dsn_#
            </cfquery>
            <cfsavecontent variable="icerik">
				<cfdump var="#cfcatch#">
			</cfsavecontent>
			<cffile action="write" file="c:\period_open_error.html" output="#icerik#">
			<script type="text/javascript">
				alert("Dönem Veritabanı Oluşturulamadı! Kullanıcı Adı - Şifre ve Veritabanı Yolu Bilgilerini Kontrol Ediniz!");
				history.back();
			</script>
			<cfabort>
		</cfcatch> 
	</cftry>
</cfif>
<cflocation url="#request.self#?fuseaction=settings.form_add_period" addtoken="no">
