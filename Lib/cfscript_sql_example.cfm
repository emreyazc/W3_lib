<cfscript>
	if(session.ep.userid eq 1)
	{	
		function test (a){
			SQLStr ="
					SELECT
						*
					FROM
						ORDER_ROW
					WHERE
						ORDER_ID = #a#
				";
			get_order_row = cfquery(SQLString : SQLStr, Datasource : dsn3);
			if(a neq 0){
				test_str = "<p>a = #get_order_row.PRODUCT_NAME#</p>";
				writeOutput(test_str);
			}
			else{
				break;
			}
		}
	};
</cfscript>

<cfquery name="GET_ORDER" datasource="#DSN3#">
	SELECT
		*
	FROM
		ORDERS
</cfquery>

<cfoutput query="GET_ORDER">
	#test(GET_ORDER.ORDER_ID)#
</cfoutput>