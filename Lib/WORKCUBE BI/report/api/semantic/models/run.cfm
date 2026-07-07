<cfsetting showdebugoutput="false">
<cfcontent type="application/json; charset=utf-8">

<cftry>
  <cfset resp = structNew()>
  <cfset resp.success = false>
  <cfset ADMIN_DSN = "workcube_test">

  <cfset httpData = getHttpRequestData()>
  <cfset rawBody  = "">
  <cfif structKeyExists(httpData,"content") AND isSimpleValue(httpData.content)>
    <cfset rawBody = httpData.content>
  </cfif>

  <cfset payload = structNew()>
  <cfif len(trim(rawBody)) GT 0 AND isJSON(rawBody)>
    <cfset payload = deserializeJSON(rawBody)>
  <cfelse>
    <cfset payload.modelRef = structNew()>
    <cfif structKeyExists(form,"modelUid")><cfset payload.modelRef.modelUid = form.modelUid></cfif>
    <cfif structKeyExists(form,"version")><cfset payload.modelRef.version  = form.version></cfif>
    <cfif structKeyExists(form,"limit")  ><cfset payload.limit             = val(form.limit)></cfif>
  </cfif>

  <cfif NOT structKeyExists(payload,"modelRef") OR NOT structKeyExists(payload.modelRef,"modelUid") OR NOT len(trim(payload.modelRef.modelUid))>
    <cfset resp.message = "modelRef.modelUid zorunlu.">
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>
  <cfparam name="payload.modelRef.version" default="published">
  <cfparam name="payload.limit" default="50">

  <cfset modelUid = trim(payload.modelRef.modelUid)>
  <cfset ver      = lcase(trim(payload.modelRef.version))>

  <cfquery name="qVer" datasource="#ADMIN_DSN#">
    SELECT TOP 1 JSON_BLOB, VERSION_NO, STATE
    FROM workcube_test.DASHBOARD_SEMANTIC_MODEL_VERSION
    WHERE MODEL_UID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#modelUid#">
    <cfif isNumeric(ver)>
      AND VERSION_NO = <cfqueryparam cfsqltype="cf_sql_integer" value="#ver#">
    <cfelseif ver EQ "published">
      AND STATE = 'published'
    </cfif>
    ORDER BY VERSION_NO DESC
  </cfquery>
  <cfif qVer.recordCount EQ 0>
    <cfset resp.message = "Model bulunamadı ya da versiyon geçersiz.">
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>

  <cfset model = deserializeJSON(qVer.JSON_BLOB)>

  <cfset selArr = []>
  <cfif structKeyExists(payload,"select") AND isArray(payload.select)><cfset selArr = payload.select></cfif>
  <cfif arrayLen(selArr) EQ 0>
    <cfset resp.message = "select boş. En az bir alan seçin.">
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>

  <cfset filters = []>
  <cfif structKeyExists(payload,"filters") AND isArray(payload.filters)><cfset filters = payload.filters></cfif>

  <cfset hasOrder = false>
  <cfset orderCol = "">
  <cfset orderDir = "ASC">
  <cfif structKeyExists(payload,"orderBy") AND isStruct(payload.orderBy)>
    <cfif structKeyExists(payload.orderBy,"column") AND len(trim(payload.orderBy.column))>
      <cfset hasOrder = true>
      <cfset orderCol = trim(payload.orderBy.column)>
    </cfif>
    <cfif structKeyExists(payload.orderBy,"dir") AND ucase(payload.orderBy.dir) EQ "DESC">
      <cfset orderDir = "DESC">
    </cfif>
  </cfif>

  <cfset havingArr = []>
  <cfif structKeyExists(payload, "having") AND isArray(payload.having)>
    <cfset havingArr = payload.having>
  </cfif>

  <cfset anyAgg = false>
  <cfloop array="#selArr#" index="SAG">
    <cfif structKeyExists(SAG,"agg") AND lcase(SAG.agg) NEQ "none"><cfset anyAgg = true></cfif>
  </cfloop>
  <cfif arrayLen(havingArr) GT 0 AND NOT anyAgg>
    <cfset resp.message = "HAVING kullanmak için en az bir agregasyon seçin.">
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>

  <cfset entMap = structNew()>
  <cfloop array="#model.entities#" index="E">
    <cfset aliasName = ( structKeyExists(E,"alias") AND len(E.alias) ? E.alias : E.table )>
    <cfset entMap[ aliasName ] = E>
    <cfif ucase(aliasName) NEQ ucase(E.table)>
      <cfset entMap[ E.table ] = E>
    </cfif>
  </cfloop>

  <cfset needNames = "">
  <cfloop array="#selArr#" index="S">
    <cfif structKeyExists(S,"entity") AND len(S.entity)>
      <cfset thisEnt = trim(S.entity)>
      <cfif listFindNoCase(needNames,thisEnt) EQ 0>
        <cfset needNames = listAppend(needNames,thisEnt)>
      </cfif>
    </cfif>
  </cfloop>
  <cfif NOT len(needNames)>
    <cfset resp.message = "Seçimlerde entity adı yok.">
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>
  <cfif isArray(filters)>
    <cfloop array="#filters#" index="F">
      <cfif structKeyExists(F,"key") AND find(".", F.key)>
        <cfset fEnt = listFirst(F.key, ".")>
        <cfif listFindNoCase(needNames, fEnt) EQ 0>
          <cfset needNames = listAppend(needNames, fEnt)>
        </cfif>
      </cfif>
    </cfloop>
  </cfif>

  <cfset baseName   = listFirst(needNames)>
  <cfif NOT structKeyExists(entMap,baseName)>
    <cfset resp.message = "Baz varlık modeli içinde bulunamadı: " & baseName>
    <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
  </cfif>
  <cfset baseEnt    = entMap[baseName]>
  <cfset baseSchema = (structKeyExists(baseEnt,"schema") AND len(baseEnt.schema) ? baseEnt.schema : "workcube_test")>
  <cfset baseAlias  = (structKeyExists(baseEnt,"alias")  AND len(baseEnt.alias)  ? baseEnt.alias  : baseEnt.table)>
  <cfset fromSQL    = "[" & baseSchema & "].[" & baseEnt.table & "] AS [" & baseAlias & "]">

  <cfset included = baseName>
  <cfset pending  = "">
  <cfloop list="#needNames#" index="nm"><cfif nm NEQ baseName><cfset pending = listAppend(pending,nm)></cfif></cfloop>

  <cfset joinSQL = "">
  <cfloop condition="len(pending) GT 0">
    <cfset progress = false>
    <cfloop array="#model.relations#" index="R">
      <cfset leUid = (structKeyExists(R,"left_entity_uid")  ? R.left_entity_uid  : "")>
      <cfset reUid = (structKeyExists(R,"right_entity_uid") ? R.right_entity_uid : "")>

      <cfset leftEnt = ""><cfset rightEnt = "">
      <cfloop array="#model.entities#" index="E2">
        <cfif structKeyExists(E2,"uid") AND E2.uid EQ leUid AND isSimpleValue(leftEnt)>
          <cfset leftEnt  = (structKeyExists(E2,"alias") AND len(E2.alias) ? E2.alias : E2.table)>
        </cfif>
        <cfif structKeyExists(E2,"uid") AND E2.uid EQ reUid AND isSimpleValue(rightEnt)>
          <cfset rightEnt = (structKeyExists(E2,"alias") AND len(E2.alias) ? E2.alias : E2.table)>
        </cfif>
      </cfloop>
      <cfif NOT len(leftEnt) OR NOT len(rightEnt)><cfcontinue></cfif>

      <cfset leftInIncluded  = (listFindNoCase(included,leftEnt)  GT 0)>
      <cfset rightInIncluded = (listFindNoCase(included,rightEnt) GT 0)>
      <cfset leftInPending   = (listFindNoCase(pending,leftEnt)   GT 0)>
      <cfset rightInPending  = (listFindNoCase(pending,rightEnt)  GT 0)>

      <cfif (leftInIncluded AND rightInPending) OR (rightInIncluded AND leftInPending)>
        <cfset srcName = (leftInIncluded ? leftEnt : rightEnt)>
        <cfset dstName = (leftInIncluded ? rightEnt : leftEnt)>
        <cfset srcE = entMap[srcName]>
        <cfset dstE = entMap[dstName]>

        <cfset srcSchema = (structKeyExists(srcE,"schema") AND len(srcE.schema) ? srcE.schema : "workcube_test")>
        <cfset dstSchema = (structKeyExists(dstE,"schema") AND len(dstE.schema) ? dstE.schema : "workcube_test")>
        <cfset srcAlias  = (structKeyExists(srcE,"alias")  AND len(srcE.alias)  ? srcE.alias  : srcE.table)>
        <cfset dstAlias  = (structKeyExists(dstE,"alias")  AND len(dstE.alias)  ? dstE.alias  : dstE.table)>
        <cfset jt        = (structKeyExists(R,"joinType") AND ucase(R.joinType) EQ "INNER" ? "INNER" : "LEFT")>

        <cfset onParts = "">
        <cfif structKeyExists(R,"joins") AND isArray(R.joins)>
          <cfloop array="#R.joins#" index="J">
            <cfif structKeyExists(J,"left") AND structKeyExists(J,"right")>
              <cfset cond = "[" & srcAlias & "].[" & J.left & "] = [" & dstAlias & "].[" & J.right & "]">
              <cfif len(onParts)><cfset onParts = onParts & " AND "></cfif>
              <cfset onParts = onParts & cond>
            </cfif>
          </cfloop>
        </cfif>
        <cfif NOT len(onParts)><cfcontinue></cfif>

        <cfset joinSQL = joinSQL & " " & jt & " JOIN [" & dstSchema & "].[" & dstE.table & "] AS [" & dstAlias & "] ON " & onParts>
        <cfif listFindNoCase(pending,dstName) GT 0>
          <cfset pending  = listDeleteAt(pending, listFindNoCase(pending,dstName))>
          <cfset included = listAppend(included,dstName)>
          <cfset progress = true>
        </cfif>
      </cfif>
    </cfloop>
    <cfif NOT progress>
      <cfset resp.message = "Seçilen varlıklar arasında ilişki bulunamadı (pending: " & pending & ").">
      <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
    </cfif>
  </cfloop>

  <cfset selectParts      = "">
  <cfset selectPreview    = "">
  <cfset aliasList        = "">
  <cfset groupByParts     = "">
  <cfset groupByPreview   = "">
  <cfset hasAggSelections = false>

  <cfloop array="#selArr#" index="S2">
    <cfset eName = trim(S2.entity)>
    <cfset fName = trim(S2.field)>
    <cfset agg   = (structKeyExists(S2,"agg") ? lcase(trim(S2.agg)) : "none")>

    <cfif NOT structKeyExists(entMap,eName)>
      <cfset resp.message = "Entity bulunamadı: " & eName>
      <cfoutput>#serializeJSON(resp)#</cfoutput><cfabort>
    </cfif>

    <cfset E2     = entMap[eName]>
    <cfset aName  = (structKeyExists(E2,"alias") AND len(E2.alias) ? E2.alias : E2.table)>
    <cfset outAli = (structKeyExists(S2,"alias") AND len(trim(S2.alias)) ? trim(S2.alias) : aName & "_" & fName)>

    <cfset expr     = "[" & aName & "].[" & fName & "]">
    <cfset exprPrev = expr>

    <cfif agg NEQ "none" AND len(agg)>
      <cfset hasAggSelections = true>
      <cfif agg EQ "count_distinct">
        <cfset expr     = "COUNT(DISTINCT " & expr & ")">
        <cfset exprPrev = expr>
      <cfelseif listFindNoCase("sum,avg,min,max,count", agg)>
        <cfset expr     = ucase(agg) & "(" & expr & ")">
        <cfset exprPrev = expr>
      </cfif>
    <cfelse>
      <cfif listFindNoCase(groupByParts, "[" & aName & "].[" & fName & "]") EQ 0>
        <cfset groupByParts   = groupByParts   & (len(groupByParts)?" , ":"") & "[" & aName & "].[" & fName & "]">
        <cfset groupByPreview = groupByPreview & (len(groupByPreview)?" , ":"") & "[" & aName & "].[" & fName & "]">
      </cfif>
    </cfif>

    <cfset selectParts   = selectParts   & (len(selectParts)?" , ":"") & expr      & " AS [" & outAli & "]">
    <cfset selectPreview = selectPreview & (len(selectPreview)?" , ":"") & exprPrev & " AS [" & outAli & "]">
    <cfif listFindNoCase(aliasList,outAli) EQ 0><cfset aliasList = listAppend(aliasList,outAli)></cfif>
  </cfloop>

  <cfset limitN = val(payload.limit)>
  <cfif limitN LTE 0><cfset limitN = 50></cfif>

  <cfset wherePreview = "">
  <cfset hasWhere     = (isArray(filters) AND arrayLen(filters) GT 0)>

  <cfquery name="qData" datasource="#( structKeyExists(model,'dsn') AND len(model.dsn) ? model.dsn : 'workcube_test' )#">
    SELECT TOP #limitN# #preservesinglequotes(selectParts)#
    FROM #preservesinglequotes(fromSQL)##preservesinglequotes(joinSQL)#
    <cfif hasWhere>
      WHERE
      <cfset firstDone = false>
      <cfloop array="#filters#" index="F">
        <cfset conj = (structKeyExists(F,"conj") AND len(trim(F.conj)) ? ucase(trim(F.conj)) : "AND")>
        <cfset fKey = (structKeyExists(F,"key") ? trim(F.key) : "")>
        <cfset fOp  = (structKeyExists(F,"op")  ? ucase(trim(F.op)) : "=")>
        <cfset fVal = (structKeyExists(F,"value") AND isSimpleValue(F.value) ? trim(F.value) : "")>

        <cfset fEnt = listFirst(fKey,".")>
        <cfset fCol = listLast(fKey,".")>

        <cfset aName2 = ""><cfset E3 = "">
        <cfif structKeyExists(entMap,fEnt)>
          <cfset E3     = entMap[fEnt]>
          <cfset aName2 = (structKeyExists(E3,"alias") AND len(E3.alias) ? E3.alias : E3.table)>
        </cfif>

        <cfset cfType = "cf_sql_varchar">
        <cfset dt = "">
        <cfif isStruct(E3) AND structKeyExists(E3,"fields") AND isArray(E3.fields)>
          <cfloop array="#E3.fields#" index="FD">
            <cfif structKeyExists(FD,"name") AND ucase(FD.name) EQ ucase(fCol)>
              <cfif structKeyExists(FD,"dataType")><cfset dt = lcase(trim(FD.dataType))></cfif>
              <cfif reFind("int|bigint|smallint|tinyint", dt)>
                <cfset cfType = "cf_sql_integer">
              <cfelseif reFind("decimal|numeric|money|float|real|double", dt)>
                <cfset cfType = "cf_sql_numeric">
              <cfelseif reFind("date|time", dt)>
                <cfset cfType = "cf_sql_timestamp">
              <cfelseif reFind("bit|bool", dt)>
                <cfset cfType = "cf_sql_bit">
              <cfelse>
                <cfset cfType = "cf_sql_varchar">
              </cfif>
            </cfif>
          </cfloop>
        </cfif>

        <cfset pvValQuoted = fVal>
        <cfif cfType NEQ "cf_sql_integer" AND cfType NEQ "cf_sql_numeric" AND cfType NEQ "cf_sql_bit">
          <cfif left(pvValQuoted,1) NEQ "'" ><cfset pvValQuoted = "'" & pvValQuoted></cfif>
          <cfif right(pvValQuoted,1) NEQ "'" ><cfset pvValQuoted = pvValQuoted & "'"></cfif>
        </cfif>

        <cfif firstDone> #conj# </cfif>
        <cfset firstDone = true>

        <cfif fOp EQ "IN">
          [#aName2#].[#fCol#] IN (
            <cfqueryparam value="#fVal#" cfsqltype="#cfType#" list="true">
          )
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") & "[" & aName2 & "].[" & fCol & "] IN (" & fVal & ")">
        <cfelseif fOp EQ "BETWEEN">
          <cfset v1 = listFirst(fVal)><cfset v2 = listLast(fVal)>
          [#aName2#].[#fCol#] BETWEEN
            <cfqueryparam value="#v1#" cfsqltype="#cfType#"> AND
            <cfqueryparam value="#v2#" cfsqltype="#cfType#">
          <cfset pv1 = v1><cfset pv2 = v2>
          <cfif cfType EQ "cf_sql_varchar"><cfset pv1 = "'" & pv1 & "'"><cfset pv2 = "'" & pv2 & "'"></cfif>
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") &
            "[" & aName2 & "].[" & fCol & "] BETWEEN " & pv1 & " AND " & pv2>
        <cfelseif fOp EQ "LIKE">
          <cfset likeVal = fVal>
          <cfif find("%", likeVal) EQ 0><cfset likeVal = "%" & likeVal & "%"></cfif>
          [#aName2#].[#fCol#] LIKE <cfqueryparam value="#likeVal#" cfsqltype="cf_sql_varchar">
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") &
            "[" & aName2 & "].[" & fCol & "] LIKE '" & likeVal & "'" >
        <cfelseif fOp EQ "!=">
          [#aName2#].[#fCol#] <> <cfqueryparam value="#fVal#" cfsqltype="#cfType#">
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") &
            "[" & aName2 & "].[" & fCol & "] <> " & pvValQuoted>
        <cfelseif fOp EQ "=" OR fOp EQ ">" OR fOp EQ ">=" OR fOp EQ "<" OR fOp EQ "<=">
          [#aName2#].[#fCol#] #fOp# <cfqueryparam value="#fVal#" cfsqltype="#cfType#">
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") &
            "[" & aName2 & "].[" & fCol & "] " & fOp & " " & pvValQuoted>
        <cfelse>
          [#aName2#].[#fCol#] = <cfqueryparam value="#fVal#" cfsqltype="#cfType#">
          <cfset wherePreview = wherePreview & (len(wherePreview)?" " & conj & " ":"") &
            "[" & aName2 & "].[" & fCol & "] = " & pvValQuoted>
        </cfif>
      </cfloop>
    </cfif>

    <cfif hasAggSelections AND len(groupByParts)>
      GROUP BY #preservesinglequotes(groupByParts)#
    </cfif>

    <cfif arrayLen(havingArr) GT 0>
      <cfset hvFirst = false>
      <cfset havingPreview = "">
      HAVING
      <cfloop array="#havingArr#" index="H">
        <cfset hConj = (structKeyExists(H,"conj") AND len(trim(H.conj)) ? ucase(trim(H.conj)) : "AND")>

        <cfset hEnt = (structKeyExists(H,"entity") ? trim(H.entity) : "")>
        <cfset hCol = (structKeyExists(H,"field")  ? trim(H.field ) : "")>
        <cfset hAgg = lcase( structKeyExists(H,"agg") ? trim(H.agg) : "none" )>
        <cfset hOp  = ucase( structKeyExists(H,"op")  ? trim(H.op)  : "=" )>
        <cfset hVal = ( structKeyExists(H,"value") ? H.value : "" )>

        <cfset aNameH = ""><cfset dtH = "varchar">
        <cfif structKeyExists(entMap,hEnt)>
          <cfset E4 = entMap[hEnt]>
          <cfset aNameH = (structKeyExists(E4,"alias") AND len(E4.alias) ? E4.alias : E4.table)>
          <cfif structKeyExists(E4,"fields") AND isArray(E4.fields)>
            <cfloop array="#E4.fields#" index="FDH">
              <cfif structKeyExists(FDH,"name") AND ucase(FDH.name) EQ ucase(hCol)>
                <cfif structKeyExists(FDH,"dataType")><cfset dtH = lcase(trim(FDH.dataType))></cfif>
              </cfif>
            </cfloop>
          </cfif>
        </cfif>

        <cfset cfTypeH = "cf_sql_varchar">
        <cfif reFind("int|bigint|smallint|tinyint", dtH)>
          <cfset cfTypeH = "cf_sql_integer">
        <cfelseif reFind("decimal|numeric|money|float|real|double", dtH)>
          <cfset cfTypeH = "cf_sql_numeric">
        <cfelseif reFind("date|time", dtH)>
          <cfset cfTypeH = "cf_sql_timestamp">
        <cfelseif reFind("bit|bool", dtH)>
          <cfset cfTypeH = "cf_sql_bit">
        </cfif>

        <cfset hvExpr = "">
        <cfif hAgg EQ "count_distinct">
          <cfset hvExpr = "COUNT(DISTINCT [" & aNameH & "].[" & hCol & "])">
          <cfset cfTypeH = "cf_sql_integer">
        <cfelseif hAgg EQ "count">
          <cfset hvExpr = "COUNT([" & aNameH & "].[" & hCol & "])">
          <cfset cfTypeH = "cf_sql_integer">
        <cfelseif hAgg EQ "sum">
          <cfset hvExpr = "SUM([" & aNameH & "].[" & hCol & "])">
        <cfelseif hAgg EQ "avg">
          <cfset hvExpr = "AVG([" & aNameH & "].[" & hCol & "])">
        <cfelseif hAgg EQ "min">
          <cfset hvExpr = "MIN([" & aNameH & "].[" & hCol & "])">
        <cfelseif hAgg EQ "max">
          <cfset hvExpr = "MAX([" & aNameH & "].[" & hCol & "])">
        <cfelse>
          <cfset hvExpr = "[" & aNameH & "].[" & hCol & "]">
        </cfif>
        <cfset hvValQuoted = hVal>
        <cfif cfTypeH NEQ "cf_sql_integer" AND cfTypeH NEQ "cf_sql_numeric" AND cfTypeH NEQ "cf_sql_bit">
          <cfif isSimpleValue(hvValQuoted)>
            <cfif left(hvValQuoted,1) NEQ "'" ><cfset hvValQuoted = "'" & hvValQuoted></cfif>
            <cfif right(hvValQuoted,1) NEQ "'" ><cfset hvValQuoted = hvValQuoted & "'"></cfif>
          </cfif>
        </cfif>

        <cfif hvFirst> #hConj# </cfif>
        <cfset hvFirst = true>
        <cfif hOp EQ "IN">
          #preservesinglequotes(hvExpr)# IN (
            <cfqueryparam value="#hVal#" cfsqltype="#cfTypeH#" list="true">
          )
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") & hvExpr & " IN (" & hVal & ")">
        <cfelseif hOp EQ "BETWEEN">
          <cfset hv1 = listFirst(hVal)><cfset hv2 = listLast(hVal)>
          #preservesinglequotes(hvExpr)# BETWEEN
            <cfqueryparam value="#hv1#" cfsqltype="#cfTypeH#"> AND
            <cfqueryparam value="#hv2#" cfsqltype="#cfTypeH#">
          <cfset pv1 = hv1><cfset pv2 = hv2>
          <cfif cfTypeH EQ "cf_sql_varchar"><cfset pv1 = "'" & pv1 & "'"><cfset pv2 = "'" & pv2 & "'"></cfif>
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") &
            hvExpr & " BETWEEN " & pv1 & " AND " & pv2>
        <cfelseif hOp EQ "LIKE">
          <cfset likeValH = hVal>
          <cfif find("%", likeValH) EQ 0><cfset likeValH = "%" & likeValH & "%"></cfif>
          #preservesinglequotes(hvExpr)# LIKE <cfqueryparam value="#likeValH#" cfsqltype="cf_sql_varchar">
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") &
            hvExpr & " LIKE '" & likeValH & "'" >
        <cfelseif hOp EQ "!=">
          #preservesinglequotes(hvExpr)# <> <cfqueryparam value="#hVal#" cfsqltype="#cfTypeH#">
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") &
            hvExpr & " <> " & hvValQuoted>
        <cfelseif hOp EQ "=" OR hOp EQ ">" OR hOp EQ ">=" OR hOp EQ "<" OR hOp EQ "<=">
          #preservesinglequotes(hvExpr)# #hOp# <cfqueryparam value="#hVal#" cfsqltype="#cfTypeH#">
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") &
            hvExpr & " " & hOp & " " & hvValQuoted>
        <cfelse>
          #preservesinglequotes(hvExpr)# = <cfqueryparam value="#hVal#" cfsqltype="#cfTypeH#">
          <cfset havingPreview = havingPreview & (len(havingPreview)?" " & hConj & " ":"") &
            hvExpr & " = " & hvValQuoted>
        </cfif>
      </cfloop>
    </cfif>

    <cfif hasOrder AND listFindNoCase(aliasList, orderCol) GT 0>
      ORDER BY [#orderCol#] #orderDir#
    </cfif>
  </cfquery>

  <cfset sqlPreview = "SELECT TOP " & limitN & " " & selectPreview & " FROM " & fromSQL & joinSQL>
  <cfif len(wherePreview)>
    <cfset sqlPreview = sqlPreview & " WHERE " & wherePreview>
  </cfif>
  <cfif hasAggSelections AND len(groupByPreview)>
    <cfset sqlPreview = sqlPreview & " GROUP BY " & groupByPreview>
  </cfif>
  <cfif arrayLen(havingArr) GT 0 AND len(havingPreview)>
    <cfset sqlPreview = sqlPreview & " HAVING " & havingPreview>
  </cfif>
  <cfif hasOrder AND listFindNoCase(aliasList, orderCol) GT 0>
    <cfset sqlPreview = sqlPreview & " ORDER BY [" & orderCol & "] " & orderDir>
  </cfif>

  <cfset rows = []>
  <cfif qData.recordCount GT 0>
    <cfset cols = qData.columnList>
    <cfloop query="qData">
      <cfset r = structNew()>
      <cfloop list="#cols#" index="c"><cfset r[c] = qData[c][qData.currentRow]></cfloop>
      <cfset arrayAppend(rows, r)>
    </cfloop>
  </cfif>

  <cfset resp.success = true>
  <cfset resp.sql     = sqlPreview>
  <cfset resp.rows    = rows>
  <cfoutput>#serializeJSON(resp)#</cfoutput>

  <cfcatch type="any">
    <cfsavecontent variable="ssss"><cfdump var="#cfcatch#"></cfsavecontent>
    <cffile action="write" output="#ssss#" file="c:\run.html">
    <cfset err = { "success": false, "message": cfcatch.message }>
    <cfif structKeyExists(cfcatch,"detail") AND len(cfcatch.detail)><cfset err.detail = cfcatch.detail></cfif>
    <cfoutput>#serializeJSON(err)#</cfoutput>
  </cfcatch>
</cftry>
