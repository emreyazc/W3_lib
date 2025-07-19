<!---
    sendTest.cfm
--->
<!--- 1. ORDERS_TEST tablosu yoksa oluştur --->
<cfquery datasource="#DSN#">
    IF NOT EXISTS (
        SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'ORDERS_TEST'
    )
    CREATE TABLE ORDERS_TEST (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        CITY VARCHAR(50),
        ORDERDATE DATE
    )
</cfquery>

<!--- 2. Test için yeni sipariş ekle --->
<cfquery datasource="#dsn#">
    INSERT INTO ORDERS_TEST (CITY, ORDERDATE)
    VALUES ('Malatya', <cfqueryparam value="#dateformat(now(),'yyyy-mm-dd')#" cfsqltype="cf_sql_date">)
</cfquery>

<!--- 3. Şehirlere göre sipariş sayısını çek --->
<cfquery name="getOrderCityCount" datasource="#dsn#">
    SELECT CITY, COUNT(*) AS COUNT
    FROM ORDERS_TEST
    GROUP BY CITY
</cfquery>

<!--- 4. Sonucu canlı olarak kanala gönder --->
<cfdump var="#getOrderCityCount#">
<cfset wsPublish("soketkanal", serializeJSON(getOrderCityCount))>


Sipariş ve grafik güncellendi!
