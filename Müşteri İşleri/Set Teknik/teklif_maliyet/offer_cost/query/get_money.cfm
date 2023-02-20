<cfquery name="GET_MONEY_USD" datasource="#DSN#">
    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'USD'
</cfquery>

<cfquery name="GET_MONEY_GBP" datasource="#DSN#">
    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'GBP'
</cfquery>

<cfquery name="GET_MONEY_EUR" datasource="#DSN#">
    SELECT RATE1, RATE2, MONEY_SYMBOL FROM SETUP_MONEY WHERE MONEY = 'EUR'
</cfquery>

<cfquery name="GET_MONEY" datasource="#DSN#">
    SELECT * FROM SETUP_MONEY WHERE PERIOD_ID = #session.ep.period_id#
</cfquery>