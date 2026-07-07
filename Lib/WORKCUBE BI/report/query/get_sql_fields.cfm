<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <cfparam name="DSN" default="workcube_test">
  <cfparam name="url.widgetId" type="numeric">

  <cfquery name="cfg" datasource="#DSN#">
    SELECT 
      WSC.SQL_QUERY,
      WSC.COLUMN_ROLES_JSON,
      W.WIDGET_NAME
    FROM DASHBOARD_WIDGET_SQL_CONFIG WSC
    INNER JOIN DASHBOARD_WIDGET_DEFS W ON W.WIDGET_ID = WSC.WIDGET_ID
    WHERE WSC.WIDGET_ID = <cfqueryparam value="#url.widgetId#" cfsqltype="cf_sql_integer">
  </cfquery>

  <cfif cfg.recordcount EQ 0>
    <cfoutput>#serializeJSON([])#</cfoutput>
    <cfexit method="exittemplate">
  </cfif>

  <cfset userSql = trim(cfg.SQL_QUERY)>
  <cfset fields  = []>

  <cfscript>
    function uiTypeFromSql(systemTypeName) {
      if (!isSimpleValue(systemTypeName)) return "text";
      var t = lcase(toString(systemTypeName));
      if (refind("int|decimal|numeric|float|real|money|smallmoney|bigint|tinyint|smallint|number", t)) return "number";
      if (refind("date|datetime|datetime2|smalldatetime|time", t)) return "date";
      if (refind("bit", t)) return "boolean";
      return "text";
    }
    function labelize(colName) {
      if (!isSimpleValue(colName)) return "";
      var s = toString(colName);
      var titled = (len(s) > 1) ? ucase(left(s,1)) & mid(s, 2, len(s)-1) : ucase(s);
      return replace(titled, "_", " ", "all");
    }
  </cfscript>

  <cfif len(trim(cfg.COLUMN_ROLES_JSON))>
    <cfset roles = {} />
    <cftry>
      <cfset roles = deserializeJSON(cfg.COLUMN_ROLES_JSON)>
    <cfcatch>
      <cfset roles = {} />
    </cfcatch>
    </cftry>

    <cfif structKeyExists(roles,"fields") AND isArray(roles.fields)>
      <cfloop array="#roles.fields#" index="f">
        <cfset colName = "">
        <cfset colType = "text">
        <cfset friendlyLabel = "">
        <cfset isMeasure = ( structKeyExists(f,"role") AND isSimpleValue(f.role) AND findNoCase("measure", f.role) GT 0 )>

        <cfif structKeyExists(f,"name") AND isSimpleValue(f.name)>
          <cfset colName = f.name>
        <cfelseif structKeyExists(f,"id")>
          <cfif isSimpleValue(f.id)>
            <cfset colName = f.id>
          <cfelseif isStruct(f.id)>
            <cfif structKeyExists(f.id,"field") AND isSimpleValue(f.id.field)><cfset colName = f.id.field></cfif>
            <cfif structKeyExists(f.id,"label") AND isSimpleValue(f.id.label)><cfset friendlyLabel = f.id.label></cfif>
          </cfif>
        </cfif>

        <cfif structKeyExists(f,"type") AND isSimpleValue(f.type)><cfset colType = f.type></cfif>
        <cfif NOT len(friendlyLabel) AND structKeyExists(f,"label") AND isSimpleValue(f.label)><cfset friendlyLabel = f.label></cfif>

        <cfif len(colName)>
          <cfset arrayAppend(fields, {
            "id": colName,
            "label": len(friendlyLabel) ? friendlyLabel : labelize(colName),
            "type": uiTypeFromSql(colType),
            "isMeasure": isMeasure,
            "source": "sql"
          })>
        </cfif>
      </cfloop>

    <cfelseif structKeyExists(roles,"measures") OR structKeyExists(roles,"dimensions")>
      <cfif structKeyExists(roles,"measures") AND isArray(roles.measures)>
        <cfloop array="#roles.measures#" index="m">
          <cfset mField = ""><cfset mLabel = "">
          <cfif isSimpleValue(m)>
            <cfset mField = m>
          <cfelseif isStruct(m)>
            <cfif structKeyExists(m,"field") AND isSimpleValue(m.field)><cfset mField = m.field></cfif>
            <cfif structKeyExists(m,"label") AND isSimpleValue(m.label)><cfset mLabel = m.label></cfif>
          </cfif>
          <cfif len(mField)>
            <cfset arrayAppend(fields, {
              "id": mField, "label": len(mLabel)?mLabel:labelize(mField),
              "type": "number", "isMeasure": true, "source":"sql"
            })>
          </cfif>
        </cfloop>
      </cfif>

      <cfif structKeyExists(roles,"dimensions") AND isArray(roles.dimensions)>
        <cfloop array="#roles.dimensions#" index="d">
          <cfset dField = ""><cfset dLabel = "">
          <cfif isSimpleValue(d)>
            <cfset dField = d>
          <cfelseif isStruct(d)>
            <cfif structKeyExists(d,"field") AND isSimpleValue(d.field)><cfset dField = d.field></cfif>
            <cfif structKeyExists(d,"label") AND isSimpleValue(d.label)><cfset dLabel = d.label></cfif>
          </cfif>
          <cfif len(dField)>
            <cfset arrayAppend(fields, {
              "id": dField, "label": len(dLabel)?dLabel:labelize(dField),
              "type": "text", "isMeasure": false, "source":"sql"
            })>
          </cfif>
        </cfloop>
      </cfif>
    </cfif>
  </cfif>

  <cfif arrayLen(fields) EQ 0 AND len(userSql)>
    <cfquery name="desc" datasource="#DSN#">
      DECLARE @q NVARCHAR(MAX) = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#userSql#">;
      EXEC sys.sp_describe_first_result_set @tsql = @q, @params = NULL, @include_browse_information = 1;
    </cfquery>

    <cfif desc.recordCount GT 0>
      <cfloop query="desc">
        <cfset colName = trim(desc.name)>
        <cfif len(colName)>
          <cfset sysType = trim(desc.system_type_name)>
          <cfset arrayAppend(fields, {
            "id": colName,
            "label": labelize(colName),
            "type": uiTypeFromSql(sysType),
            "isMeasure": ( uiTypeFromSql(sysType) EQ "number" ),
            "source": "sql"
          })>
        </cfif>
      </cfloop>
    </cfif>
  </cfif>

  <cfoutput>#serializeJSON(fields)#</cfoutput>

  <cfcatch type="any">
    <cfoutput>#serializeJSON({ ok:false, error=cfcatch.message })#</cfoutput>
  </cfcatch>
</cftry>
