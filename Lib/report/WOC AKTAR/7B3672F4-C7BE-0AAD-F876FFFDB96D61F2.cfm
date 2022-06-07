woc aktarim

<cfspreadsheet action="read" src="C:\inetpub\wwwroot\Devcatalyst_Test\documents\report\woc.xls" query="qData">

<!---
<cfdump var="#qData#">
--->

<cfdump var="#qData#">

<cfoutput query="qData" startrow="1">

    <cfquery name="INSERT_WOC" datasource="#DSN#">
        INSERT INTO SETUP_PRINT_FILES_CATS 
        (
            PRINT_MODULE_ID,
            PRINT_NAME,
            PRINT_NAME_ENG,
            PRINT_TYPE,
            PRINT_MODULE_NAME,
            PRINT_DICTIONARY_ID
        )
        VALUES('#col_1#', '#col_2#', '#col_3#', '#col_4#', '#col_5#', '#col_6#');
    </cfquery>

</cfoutput>