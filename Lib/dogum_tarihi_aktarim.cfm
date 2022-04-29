<cfspreadsheet  action="read" src="C:\inetpub\wwwroot\W3Holistic\documents\aktar_mba.xlsx"  query="qData">

<!---
<cfdump var="#qData#">
--->

<cfoutput query="qData" startrow="2">
    <cfquery name="get_employee_id" datasource="#dsn#">
        SELECT
            EI.EMPLOYEE_ID,
            EO.IN_OUT_ID,
            E.*
        FROM
            EMPLOYEES E,
            EMPLOYEES_IDENTY EI,
            EMPLOYEES_IN_OUT EO
        WHERE
            EO.EMPLOYEE_ID = EI.EMPLOYEE_ID  AND
            E.EMPLOYEE_ID = EI.EMPLOYEE_ID
            AND 
            (
            EI.TC_IDENTY_NO = '#col_4#'
            OR 
            (E.EMPLOYEE_NAME = '#col_2#' AND E.EMPLOYEE_SURNAME = '#col_3#')
            )
        ORDER BY
            EO.IN_OUT_ID DESC
    </cfquery>

    <!---
    <cfloop query="#get_employee_id#">#EMPLOYEE_ID#</cfloop> #col_5# <!---#get_employee_id.recordcount#--->
    --->
    
    <cfscript>
    dogum_tarihi_ = col_5;
    if(len(dogum_tarihi_))
			{
				dogumyil = listgetat(col_5,3,'/');
				dogumgun = listgetat(col_5,2,'/');
				dogumay = listgetat(col_5,1,'/');
			}
    </cfscript>

    <cfif dogumyil lt 00 or dogumyil eq 00>
        <cfset dogumyil_ = dogumyil+2000>
        <cfelse>
        <cfset dogumyil_ = dogumyil+1900>
    </cfif>

    <cfloop query="#get_employee_id#">#EMPLOYEE_ID#</cfloop> #col_5# (#dogumay#, #dogumgun#, #dogumyil_#) <!---#get_employee_id.recordcount#--->

    <cfquery name="upd_" datasource="#dsn#">
        UPDATE 
            EMPLOYEES_IDENTY
        SET
            BIRTH_DATE = <cfif len(dogum_tarihi_)>#createodbcdatetime(createdate(dogumyil_,dogumay,dogumgun))#<cfelse>NULL</cfif>
        WHERE 
            EMPLOYEE_ID = #get_employee_id.employee_id#
    </cfquery>

    <br>
</cfoutput>
<cfabort>