<!---
	Date : 26.07.1995
	Desc : İki endpoint için yazılmış bir API dir. Farklı endpointler eklenebilir.
		   authenticate : endpointten veri alabilmek için kullanıcı bilgisi ile auth olabilmesini sağlayan fonksiyon.
		   logApiCall : auth olabilen ya da olamayan kullanıcının bilgisi tutar. Kim ? Ne zaman ? Hangi veriyi aldı bilgisi tutulur.
	Dev  : Yunus Emre Yazıcı
--->

<cffunction name="logApiCall" access="public" returntype="void">
    <cfargument name="apikey" type="string" required="true">
    <cfargument name="apisecret" type="string" required="true">
    <cfargument name="token" type="string" required="false" default="">
    <cfargument name="endpoint" type="string" required="true">
    <cfargument name="isSuccess" type="boolean" required="true">
    <cfargument name="expireDate" type="date" required="false" default="">

    <cfset var dsn = application.systemParam.systemParam().dsn>

    <cfquery datasource="#dsn#">
        INSERT INTO API_LOGS (
            APIKEY, APISECRET, TOKEN, ENDPOINT_NAME, REQUEST_TIME, IS_SUCCESS, EXPIRE_DATE
        ) VALUES (
            <cfqueryparam value="#arguments.apikey#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.apisecret#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.token#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#arguments.endpoint#" cfsqltype="cf_sql_varchar">,
            <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
            <cfqueryparam value="#arguments.isSuccess#" cfsqltype="cf_sql_bit">,
            <cfqueryparam value="#arguments.expireDate#" cfsqltype="cf_sql_timestamp">
        )
    </cfquery>
</cffunction>

<cffunction name="authenticate" access="public" returntype="struct">
    <cfargument name="apikey" type="string" required="true">
    <cfargument name="apisecret" type="string" required="true">

    <cfset var dsn = application.systemParam.systemParam().dsn>
    <cfset var result = structNew()>
    <cfset var qCheckUser = "">
    <cfset var qToken = "">
    <cfset var token = "">
    <cfset var expireDate = now()>

    <cfif NOT len(trim(arguments.apikey)) OR NOT len(trim(arguments.apisecret))>
        <cfset result.status = "fail">
        <cfset result.message = "API key ve secret gönderilmelidir.">
        <cfset logApiCall(arguments.apikey, arguments.apisecret, "", CGI.SCRIPT_NAME, false, "")>
        <cfreturn result>
    </cfif>

    <cfquery name="qCheckUser" datasource="#dsn#">
        SELECT * FROM API_USERS
        WHERE APIKEY = <cfqueryparam value="#arguments.apikey#" cfsqltype="cf_sql_varchar">
          AND APISECRET = <cfqueryparam value="#arguments.apisecret#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif qCheckUser.recordCount EQ 0>
        <cfset result.status = "fail">
        <cfset result.message = "API key veya secret hatalı.">
        <cfset logApiCall(arguments.apikey, arguments.apisecret, "", CGI.SCRIPT_NAME, false, "")>
        <cfreturn result>
    </cfif>

    <cfquery name="qToken" datasource="#dsn#">
        SELECT * FROM API_TOKENS 
        WHERE APIKEY = <cfqueryparam value="#arguments.apikey#" cfsqltype="cf_sql_varchar">
          AND EXPIRE_DATE >= <cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">
        ORDER BY EXPIRE_DATE DESC
    </cfquery>

    <cfif qToken.recordCount GT 0>
        <cfset token = qToken.TOKEN>
        <cfset expireDate = qToken.EXPIRE_DATE>
    <cfelse>
        <cfset token = hash(arguments.apikey & now(), "SHA-256")>
        <cfset expireDate = dateAdd("h", 1, now())>

        <cfquery datasource="#dsn#">
            INSERT INTO API_TOKENS (APIKEY, TOKEN, EXPIRE_DATE)
            VALUES (
                <cfqueryparam value="#arguments.apikey#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#expireDate#" cfsqltype="cf_sql_timestamp">
            )
        </cfquery>
    </cfif>

    <cfset result.status = "success">
    <cfset result.message = "Kimlik doğrulandı.">
    <cfset result.token = token>
    <cfset result.expireDate = expireDate>

    <cfset logApiCall(arguments.apikey, arguments.apisecret, token, CGI.SCRIPT_NAME, true, expireDate)>

    <cfreturn result>
</cffunction>

<cffunction name="getAvailableEndpoints" access="remote" returntype="any">
    <cfargument name="apikey" type="string" required="true">
    <cfargument name="apisecret" type="string" required="true">

    <cfset var dsn = application.systemParam.systemParam().dsn>
    <cfset var auth = authenticate(arguments.apikey, arguments.apisecret)>
    <cfset var result = structNew()>
    <cfset var endpointList = []>

    <cfif auth.status NEQ "success">
        <cfset result.STATUS = "fail">
        <cfset result.MESSAGE = auth.message>
        <cfset result.DATA = []>
        <cfreturn serializeJSON(result)>
    </cfif>

    <cfset arrayAppend(endpointList, {
        name = "getPositionCatList",
        description = "Pozisyon kategorilerini listeler",
        method = "GET",
        url = "/positioncat/getPositionCatList"
    })>

    <cfset arrayAppend(endpointList, {
        name = "getPositionNameList",
        description = "Pozisyon adlarını listeler",
        method = "GET",
        url = "/positioncat/getPositionNameList"
    })>

    <cfset arrayAppend(endpointList, {
        name = "getAvailableEndpoints",
        description = "Mevcut endpoint listesini verir",
        method = "GET",
        url = "/positioncat/getAvailableEndpoints"
    })>

    <cfset result.STATUS = "success">
    <cfset result.MESSAGE = "Kullanılabilir endpoint listesi getirildi.">
    <cfset result.TOKEN = auth.token>
    <cfset result.EXPIRES_AT = auth.expireDate>
    <cfset result.DATA = endpointList>

    <cfset logApiCall(arguments.apikey, arguments.apisecret, auth.token, "getAvailableEndpoints", true, auth.expireDate)>

    <cfreturn serializeJSON(result)>
</cffunction>

<cffunction name="getPositionCatList" access="remote" returntype="any">
    <cfargument name="apikey" type="string" required="true">
    <cfargument name="apisecret" type="string" required="true">

    <cfset var dsn = application.systemParam.systemParam().dsn>
    <cfset var auth = authenticate(arguments.apikey, arguments.apisecret)>
    <cfset var result = structNew()>
    <cfset var qData = "">
    <cfset var dataList = []>

    <cfif auth.status NEQ "success">
        <cfset result.STATUS = "fail">
        <cfset result.MESSAGE = auth.message>
        <cfset result.DATA = []>
        <cfreturn serializeJSON(result)>
    </cfif>

    <cfquery name="qData" datasource="#dsn#">
        SELECT 
            POSITION_CAT_ID AS id,
            POSITION_CAT AS name,
            RECORD_DATE,
            UPDATE_DATE
        FROM 
            SETUP_POSITION_CAT
    </cfquery>

    <cfloop query="qData">
        <cfset arrayAppend(dataList, {
            id = qData.id,
            name = qData.name,
            record_date = qData.RECORD_DATE,
            update_date = qData.UPDATE_DATE
        })>
    </cfloop>

    <cfset result.STATUS = "success">
    <cfset result.MESSAGE = "Veri başarıyla alındı.">
    <cfset result.TOKEN = auth.token>
    <cfset result.EXPIRES_AT = auth.expireDate>
    <cfset result.DATA = dataList>

    <cfset logApiCall(arguments.apikey, arguments.apisecret, auth.token, "getPositionCatList", true, auth.expireDate)>

    <cfreturn serializeJSON(result)>
</cffunction>

<cffunction name="getPositionNameList" access="remote" returntype="any">
    <cfargument name="apikey" type="string" required="true">
    <cfargument name="apisecret" type="string" required="true">

    <cfset var dsn = application.systemParam.systemParam().dsn>
    <cfset var auth = authenticate(arguments.apikey, arguments.apisecret)>
    <cfset var result = structNew()>
    <cfset var qData = "">
    <cfset var dataList = []>

    <cfif auth.status NEQ "success">
        <cfset result.STATUS = "fail">
        <cfset result.MESSAGE = auth.message>
        <cfset result.DATA = []>
        <cfreturn serializeJSON(result)>
    </cfif>

    <cfquery name="qData" datasource="#dsn#">
        SELECT 
            POS_NAME_ID AS id,
            POSITION_NAME AS name
        FROM 
            EMPLOYEE_POSITION_NAMES
    </cfquery>

    <cfloop query="qData">
        <cfset arrayAppend(dataList, {
            id = qData.id,
            name = qData.name
        })>
    </cfloop>

    <cfset result.STATUS = "success">
    <cfset result.MESSAGE = "Veri başarıyla alındı.">
    <cfset result.TOKEN = auth.token>
    <cfset result.EXPIRES_AT = auth.expireDate>
    <cfset result.DATA = dataList>

    <cfset logApiCall(arguments.apikey, arguments.apisecret, auth.token, "getPositionNameList", true, auth.expireDate)>

    <cfreturn serializeJSON(result)>
</cffunction>

<!---
	Amaç: Yetkilendirme için kullanılan apikey ve apisecret bilgilerini saklamak.
--->
<!---
	CREATE TABLE API_USERS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    COMPANY_NAME VARCHAR(255),
    APIKEY VARCHAR(255),
    APISECRET VARCHAR(255),
    CREATE_DATE DATETIME DEFAULT GETDATE()
	);
--->

<!---
	Amaç: Doğrulama sonrası verilen token bilgisini ve süresini saklamak.
--->
<!---
	CREATE TABLE API_TOKENS (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    APIKEY VARCHAR(255),
    TOKEN VARCHAR(512),
    EXPIRE_DATE DATETIME,
    CREATE_DATE DATETIME DEFAULT GETDATE()
	);
--->

<!---
	Amaç: Her istek için log tutmak. Hangi kullanıcı, ne zaman, hangi endpointi çağırdı, başarılı mıydı gibi bilgileri içerir.
--->
<!---
	/*
	CREATE TABLE [workcube_test].[workcube_test].API_LOGS (
		LOG_ID INT IDENTITY(1,1) PRIMARY KEY,
		APIKEY VARCHAR(255),
		APISECRET VARCHAR(255),
		TOKEN VARCHAR(500),
		ENDPOINT_NAME VARCHAR(255),
		REQUEST_TIME DATETIME,
		IS_SUCCESS BIT,
		EXPIRE_DATE DATETIME
	);
	*/
--->

<!---
 Örnek Kullanım Link : http://erptest.setteknik.com.tr/wex.cfm/positioncat/getPositionNameList?apikey=0e4c11746f3c4e4a91b1622b9e20f3e0&apisecret=dW4wPD1x8mvFALDU2uNtxc7GbZkHD1lCKJ23o4E2s8
--->