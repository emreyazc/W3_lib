<!---
    Date : 14.04.2022
    Desc : İş İlanları için oluşturulan WEX i getirir.
--->

<cfsavecontent variable="send_body">
    //{"test":"test"}
</cfsavecontent>

<cfhttp url="http://hr.mbaokullari.com/wex.cfm/notice_work/control_notice_work" result="result" charset="utf-8" method="get">
	
</cfhttp>

<cfoutput> #result.filecontent# </cfoutput>

<cfset cfData = DeserializeJSON(result.filecontent)>
<cfdump var="#cfData#">

<!---
<cfoutput>
    #dateformat(now(),dateformat_style)#
</cfoutput>
--->