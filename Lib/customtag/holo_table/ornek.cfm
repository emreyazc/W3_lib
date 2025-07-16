<cfquery name="qEmployees" datasource="#DSN#">
    SELECT EMPLOYEE_ID, EMPLOYEE_NAME, EMPLOYEE_SURNAME, RECORD_DATE, 1000 AS SALARY FROM EMPLOYEES
</cfquery>

<cf_customreport 
    query="#qEmployees#" 
    columns="EMPLOYEE_NAME,EMPLOYEE_SURNAME,RECORD_DATE,SALARY"
    titles="Adı,Soyadı,Kayıt Tarihi,Maaş"
    formats="string,string,date,money"
    dateformat_style="dd.MM.yyyy"
    money_precision="3"
    export="true">