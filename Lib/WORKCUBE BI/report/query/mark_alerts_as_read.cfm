<cfcontent type="application/json" />

<cfscript>
  userId = session.user_id ?: 1;

  query = "
    UPDATE DASHBOARD_ALERT_LOGS
    SET IS_READ = 1
    WHERE USER_ID = ? AND IS_READ = 0
  ";

  result = queryExecute(query, [userId], {datasource="workcube_test"});

  writeOutput(serializeJSON({
    status: "success",
    message: "Okundu olarak işaretlendi"
  }));
</cfscript>
