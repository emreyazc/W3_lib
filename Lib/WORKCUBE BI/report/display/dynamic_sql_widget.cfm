<!--- dynamic_sql_widget.cfm — SQL tabanlı widget renderer (temiz) --->
<cfsetting showdebugoutput="false">

<!--- ========== API: run (JSON) ========== --->
<cfif structKeyExists(url,"api") AND lcase(url.api) EQ "run">
  <cfcontent type="application/json; charset=utf-8">
  <cftry>
    <cfparam name="url.widgetid" type="numeric">
    <cfset _DSN = structKeyExists(request,"DSN") ? request.DSN : DSN>
    <cfquery name="cfg" datasource="#_DSN#">
      SELECT 
        SQL_QUERY
      FROM 
        DASHBOARD_WIDGET_SQL_CONFIG
      WHERE 
        WIDGET_ID = <cfqueryparam value="#url.widgetid#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif cfg.recordcount EQ 0>
      <cfoutput>{"error":true,"message":"Widget bulunamadı"}</cfoutput><cfabort>
    </cfif>
    <cfset _sql = trim(cfg.SQL_QUERY)>
    <cfset _sql = rereplace(_sql, ";\s*$", "", "all")>
    <cfif NOT refindnocase("^\s*select\b", _sql)>
      <cfoutput>{"error":true,"message":"Sadece SELECT sorgularına izin verilir."}</cfoutput><cfabort>
    </cfif>

    <cfset q = queryExecute(_sql, {}, {datasource=_DSN})>
    <cfset qjson = serializeJSON(q, true)>
    <cfoutput>#qjson#</cfoutput>

    <cfcatch type="any">
      <cfoutput>{"error":true,"message":"#encodeForJavaScript(cfcatch.message)#"}</cfoutput>
    </cfcatch>
  </cftry>
  <cfabort>
</cfif>

<!--- ========== HTML RENDER ========== --->
<cfcontent type="text/html; charset=utf-8">
<cfparam name="url.widgetid" type="numeric">

<!--- DSN --->
<cfset _DSN = structKeyExists(request,"DSN") ? request.DSN : DSN>

<!--- Config --->
<cfquery name="getConfig" datasource="#_DSN#">
  SELECT 
    WSC.SQL_QUERY, 
    WSC.CHART_TYPE, 
    WSC.COLUMN_ROLES_JSON,
    W.WIDGET_NAME
  FROM 
    DASHBOARD_WIDGET_SQL_CONFIG WSC
    INNER JOIN DASHBOARD_WIDGET_DEFS W ON W.WIDGET_ID = WSC.WIDGET_ID
  WHERE 
    WSC.WIDGET_ID = <cfqueryparam value="#url.widgetid#" cfsqltype="cf_sql_integer">
</cfquery>
<cfif getConfig.recordcount EQ 0>
  <h3>Geçersiz Widget ID</h3>
  <cfabort>
</cfif>

<!--- Değerler --->
<cfset sqlQuery     = trim(getConfig.SQL_QUERY)>
<cfset chartType    = lcase(trim(getConfig.CHART_TYPE))>
<cfif NOT len(chartType)><cfset chartType = "bar"></cfif>
<cfset widgetTitle  = getConfig.WIDGET_NAME>
<cfset columnRoles  = (isJSON(getConfig.COLUMN_ROLES_JSON) ? deserializeJSON(getConfig.COLUMN_ROLES_JSON) : {})>

<!--- İlk veri (SSR) --->
<cfquery name="qryData" datasource="#_DSN#">
  #preserveSingleQuotes(sqlQuery)#
</cfquery>
<cfset dataJSON        = serializeJSON(qryData, true)>
<cfset jsChartTypeSafe = encodeForJavaScript(chartType)>
<cfset jsWidgetTitle   = encodeForJavaScript(widgetTitle)>
<cfset htmlWidgetTitle = encodeForHTML(widgetTitle)>
<cfset rolesJSON       = serializeJSON(columnRoles)>

<style>
  h2 { font-size:16px; margin:0 0 10px 0; color:##111; }
  .wrap { font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Arial; }
  canvas { width:100% !important; max-height:320px; }
  .tbl { width:100%; border-collapse:collapse; font-size:13px; }
  .tbl th,.tbl td { border:1px solid ##eee; padding:6px 8px; }
  .empty { color:##6b7280; font-size:13px; padding:8px 0; }
  .kpi-card { display:flex; align-items:center; justify-content:space-between;
              padding:16px; border:1px solid ##e5e7eb; border-radius:14px; background:#fff; }
  .kpi-title { font-size:13px; color:##6b7280; }
  .kpi-value { font-size:30px; font-weight:700; line-height:1.1; }
</style>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

<cfoutput>
  <div class="wrap">
    <h2>#htmlWidgetTitle#</h2>
    <div id="kpiContainer" style="display:none;"></div>
    <div id="apexContainer" style="display:none;"></div>
    <div id="tableContainer" style="display:none;"></div>
    <canvas id="widgetChart"></canvas>
  </div>

  <!--- SSR JSON --->
  <script id="data-json" type="application/json">#dataJSON#</script>

  <script>
  /* ===== Helpers ===== */
  function cfQueryJsonToRows(cfjson){
    const j = cfjson || {};
    const C = j.COLUMNS || j.columns || [];
    const D = j.DATA || j.data;
    if (!C || !D) return [];
    const rows = [];
    if (Array.isArray(D) && Array.isArray(D[0])) {
      for (let i=0;i<D.length;i++){ const row={}; for (let c=0;c<C.length;c++){ row[C[c]] = D[i][c]; } rows.push(row); }
    } else if (typeof D === "object"){
      const len = (D[C[0]] || []).length;
      for (let i=0;i<len;i++){ const row={}; for (let c=0;c<C.length;c++){ const key=C[c]; row[key] = (D[key] || [])[i]; } rows.push(row); }
    }
    return rows;
  }
  function safeKeys(obj){ const map={}; Object.keys(obj||{}).forEach(k=>{ map[k]=k; map[k.toLowerCase()]=k; map[k.toUpperCase()]=k; map[k.trim()]=k; }); return map; }
  function getVal(row, colName){
    if (row==null) return undefined;
    if (Object.prototype.hasOwnProperty.call(row, colName)) return row[colName];
    const m = safeKeys(row), k = m[colName] || m[(colName||"").toLowerCase()] || m[(colName||"").toUpperCase()] || m[(colName||"").trim()];
    if (k) return row[k];
    const ks = Object.keys(row); if (ks.length===1) return row[ks[0]];
    return undefined;
  }
  function toNumberLocaleAware(v){
    if (v===null || v===undefined) return NaN;
    if (typeof v==="number") return v;
    let s = String(v).trim();
    if (/^\d{1,3}(\.\d{3})*(,\d+)?$/.test(s)) s = s.replace(/\./g,"").replace(",","." );
    else if (/^\d+,\d+$/.test(s)) s = s.replace(",","." );
    const n = parseFloat(s); return isFinite(n)?n:NaN;
  }
  function inferTypes(rows){
    if (!rows || !rows.length) return {};
    const keys = Object.keys(rows[0]);
    const types = {};
    keys.forEach(k=>{
      let seen=0, num=0;
      for (let i=0;i<Math.min(rows.length,50);i++){
        const v = getVal(rows[i], k);
        if (v==null || v==="") continue;
        seen++; if (!isNaN(toNumberLocaleAware(v))) num++;
      }
      types[k] = (seen>0 && num/seen>0.6) ? "number" : "text";
    });
    return types;
  }
  function normalizeRoles(rawRoles, rows){
    if (rawRoles && (rawRoles.dims || rawRoles.measures)){
      const dim = rawRoles.dims && rawRoles.dims[0] ? rawRoles.dims[0].field : null;
      const meas = (rawRoles.measures||[]).map(m=>m.field);
      return { dimension: dim, measures: meas };
    }
    if (Array.isArray(rawRoles)){
      const dim = (rawRoles.find(x=>String(x.role).toLowerCase()==="dimension")||{}).name || null;
      const meas = rawRoles.filter(x=>String(x.role).toLowerCase()==="metric").map(x=>x.name);
      return { dimension: dim, measures: meas };
    }
    const types = inferTypes(rows); const keys = Object.keys(types);
    const dim = keys.find(k=>types[k]!=="number") || keys[0] || null;
    const measures = keys.filter(k=>types[k]==="number");
    return { dimension: dim, measures: measures.length?measures:[keys[1]].filter(Boolean) };
  }

  /* ===== Simple renderers ===== */
  function renderTable(rows){
    const host = document.getElementById("tableContainer");
    if (!rows || !rows.length){ host.innerHTML = '<div class="empty">Veri yok.</div>'; host.style.display='block'; return; }
    const cols = Object.keys(rows[0]);
    let thead = "<tr>"+cols.map(c=>`<th>${c}</th>`).join("")+"</tr>";
    let tbody = rows.map(r=>"<tr>"+cols.map(c=>`<td>${(getVal(r,c)??"")}</td>`).join("")+"</tr>").join("");
    host.innerHTML = `<table class="tbl"><thead>${thead}</thead><tbody>${tbody}</tbody></table>`;
    host.style.display = 'block';
  }
  function renderKPI_HTML(title, value){
    const el = document.getElementById("kpiContainer");
    el.innerHTML = `
      <div class="kpi-card">
        <div><div class="kpi-title">${title||""}</div><div class="kpi-value">${value}</div></div>
        <div class="kpi-right"></div>
      </div>`;
    el.style.display='block';
  }
  function renderKPI_Spark(title, rows, dimKey, metricKey){
    const el = document.getElementById("apexContainer");
    const labels = dimKey ? rows.map(r=>getVal(r,dimKey)) : rows.map((_,i)=>i+1);
    const values = metricKey ? rows.map(r=>toNumberLocaleAware(getVal(r,metricKey))||0) : [];
    const total  = values.reduce((a,b)=>a+b,0);
    el.innerHTML = `
      <div style="display:flex;align-items:center;justify-content:space-between;padding:16px;border:1px solid ##e5e7eb;border-radius:14px;background:##fff;">
        <div><div class="kpi-title">${title||""}</div><div class="kpi-value">${total}</div></div>
        <div id="sparkTarget" style="width:160px;height:60px;"></div>
      </div>`;
    const spark = new ApexCharts(document.querySelector('##sparkTarget'), {
      chart:{type:'line',height:60,sparkline:{enabled:true}},
      series:[{data:values}],
      stroke:{width:2,curve:'smooth'},
      tooltip:{enabled:true,x:{show:false}},
      xaxis:{type:'category',categories:labels}
    }); spark.render();
  }
  function renderGauge(title, value, target){
    const el = document.getElementById("apexContainer");
    el.innerHTML = `<div id="gaugeTarget"></div>`;
    const maxVal = Math.max(target || value || 100, 1);
    const pct = Math.max(0, Math.min(100, (value / maxVal) * 100));
    const chart = new ApexCharts(document.querySelector('##gaugeTarget'),{
      chart:{type:'radialBar',height:260},
      series:[pct],
      plotOptions:{ radialBar:{ startAngle:-90,endAngle:90,hollow:{size:'60%'},
        dataLabels:{ name:{show:true,offsetY:20,color:'##6b7280',fontSize:'13px'},
                    value:{show:true,formatter:()=>value,fontSize:'22px',offsetY:-10}} } },
      labels:[title||'']
    }); chart.render();
  }
  function renderProgress(title, value, target){
    const el = document.getElementById("apexContainer");
    el.innerHTML = `<div id="progressTarget"></div>`;
    const maxVal = Math.max(target || value || 100, 1);
    const pct = (value / maxVal) * 100;
    const chart = new ApexCharts(document.querySelector('##progressTarget'),{
      chart:{type:'bar',height:90,sparkline:{enabled:true}},
      plotOptions:{bar:{horizontal:true,barHeight:'40%',borderRadius:6}},
      series:[{data:[pct]}], xaxis:{max:100},
      dataLabels:{enabled:true,formatter:()=>`${value} / ${maxVal}`},
      tooltip:{enabled:false}, title:{text:title||'',style:{fontSize:'13px',color:'##6b7280'}}
    }); chart.render();
    el.style.display='block';
  }

  /* ===== Chart lifecycle ===== */
  let __HB_CHART = null;
  function destroyChart(){ if (__HB_CHART){ try{ __HB_CHART.destroy(); }catch(e){} __HB_CHART=null; } }
  function renderChartJS(ctx, type, rows, dimKey, measureKeys){
    const labels = rows.map(r=>String(getVal(r, dimKey)));
    const datasets = measureKeys.map(mk=>({
      label: mk,
      data: rows.map(r=>toNumberLocaleAware(getVal(r, mk))||0),
      borderWidth:2,
      fill:(type==='area')
    }));
    const chartType = (type==='area'?'line':type) || 'bar';

    destroyChart();
    if (chartType==="pie"){
      const mk = measureKeys[0];
      __HB_CHART = new Chart(ctx, {
        type:'pie',
        data:{ labels, datasets:[{ label: mk, data: datasets[0].data }] },
        options:{ responsive:true }
      });
      return;
    }
    __HB_CHART = new Chart(ctx, {
      type: chartType,
      data:{ labels, datasets },
      options:{ responsive:true, plugins:{ legend:{ display: datasets.length>1 } } }
    });
  }

  /* ===== Globals from CF ===== */
  const __WIDGET_ID  = Number(#url.widgetid#);
  const __ROLES_RAW  = #rolesJSON#;
  const __CHART_TYPE = "#jsChartTypeSafe#";
  const __TITLE      = "#jsWidgetTitle#";

  /* ===== Single point render ===== */
  function renderAll(rows){
    const elChart = document.getElementById("widgetChart");
    const elTbl   = document.getElementById("tableContainer");
    const elKPI   = document.getElementById("kpiContainer");
    const elApex  = document.getElementById("apexContainer");
    if (elTbl)  { elTbl.innerHTML=""; elTbl.style.display='none'; }
    if (elKPI)  { elKPI.innerHTML=""; elKPI.style.display='none'; }
    if (elApex) { elApex.innerHTML=""; elApex.style.display='none'; }
    destroyChart();
    if (elChart) elChart.style.display='block';

    if (!rows || !rows.length){
      if (elChart) elChart.style.display="none";
      if (elTbl){ elTbl.innerHTML = '<div class="empty">Veri bulunamadı.</div>'; elTbl.style.display='block'; }
      return;
    }

    const keys = Object.keys(rows[0]||{});
    const onlyOneCol = (keys.length===1);
    const norm = normalizeRoles(__ROLES_RAW, rows);
    const dimKey = norm.dimension || (onlyOneCol ? keys[0] : keys.find(k=>k!==keys[0]) || keys[0]);
    let measureKeys = (norm.measures||[]).length ? norm.measures : keys.filter(k=>k!==dimKey);

    let targetKey = null;
    if (Array.isArray(__ROLES_RAW)) {
      const t = __ROLES_RAW.find(x=>String(x.role).toLowerCase()==="target");
      if (t) targetKey = t.name;
    }

    const sumOf = (mk)=> rows.reduce((a,r)=> a + (toNumberLocaleAware(getVal(r,mk))||0), 0);
    const firstNumeric = (measureKeys[0] || keys.find(k=>!isNaN(toNumberLocaleAware(getVal(rows[0],k)))));

    const type = (__CHART_TYPE||'bar').toLowerCase();

    if (type==="table"){
      if (elChart) elChart.style.display="none";
      renderTable(rows); return;
    }
    if (type==="kpi" || onlyOneCol){
      const mk = onlyOneCol ? keys[0] : (firstNumeric || keys[0]);
      const total = sumOf(mk);
      if (elChart) elChart.style.display="none";
      renderKPI_HTML(__TITLE, total); return;
    }
    if (type==="kpi_spark"){
      const mk = (measureKeys[0] || firstNumeric || keys[0]);
      if (elChart) elChart.style.display="none";
      renderKPI_Spark(__TITLE, rows, dimKey, mk); return;
    }
    if (type==="gauge"){
      const mk = (measureKeys[0] || firstNumeric || keys[0]);
      const target = targetKey ? (toNumberLocaleAware(getVal(rows[0], targetKey))||null) : null;
      if (elChart) elChart.style.display="none";
      renderGauge(__TITLE, sumOf(mk), target); return;
    }
    if (type==="progress"){
      const mk = (measureKeys[0] || firstNumeric || keys[0]);
      const target = targetKey ? (toNumberLocaleAware(getVal(rows[0], targetKey))||null) : null;
      if (elChart) elChart.style.display="none";
      renderProgress(__TITLE, sumOf(mk), target); return;
    }
    if (!dimKey || measureKeys.length===0){
      if (elChart) elChart.style.display="none";
      renderTable(rows); return;
    }
    if (type==="pie" && measureKeys.length>1) measureKeys = [measureKeys[0]];
    const ctx = document.getElementById("widgetChart").getContext('2d');
    renderChartJS(ctx, type, rows, dimKey, measureKeys);
  }

  /* ===== Re-fetch ===== */
  async function fetchAndRender(fromInvalidate){
    try{
      const u = new URL(window.location.href);
      u.searchParams.set('api','run');
      const res = await fetch(u.toString(), { cache:'no-store', headers:{'Accept':'application/json'} });
      const txt = await res.text();
      let raw;
      try { raw = JSON.parse(txt); }
      catch(e){
        console.error('run api JSON parse fail', {status:res.status, ctype:res.headers.get('content-type'), body:txt.slice(0,200)});
        return;
      }
      const rows = cfQueryJsonToRows(raw);
      renderAll(rows);
    }catch(err){
      console.error('run api hata:', err && (err.message||err));
    }
  }

  /* ===== İlk çizim (SSR) ===== */
  (function(){
    try {
      const raw = JSON.parse(document.getElementById("data-json").textContent);
      const rows = cfQueryJsonToRows(raw);
      renderAll(rows);
    } catch(e) {
      console.warn("SSR parse hata", e);
    }
  })();

  /* ===== WS: invalidate → re-fetch ===== */
  </script>
  <cfwebsocket name="hbw_sql" subscribeTo="soketkanal" onMessage="__hbOnMsgSql" onOpen="__hbOpenSql" onError="__hbErrSql" />
  <script>
  (function(){
    const WID = __WIDGET_ID;
    window.__hbOpenSql = function(){ console.log('[HB][WS] OPEN soketkanal (widget:', WID, ')'); };
    window.__hbErrSql  = function(e){ console.error('[HB][WS] ERROR', e); };

    function firstProp(obj, keys){
      for (var i=0;i<keys.length;i++){ var k=keys[i]; if (obj && Object.prototype.hasOwnProperty.call(obj,k)) return obj[k]; }
      return undefined;
    }
    function toObj(raw){
      if (typeof raw === 'string'){ try{ return JSON.parse(raw); }catch(e){ return {}; } }
      return raw || {};
    }

    window.__hbOnMsgSql = function(ev){
      var raw = ev && ev.data ? ev.data : ev;
      console.log('[HB][WS] RAW:', raw);
      var m = toObj(raw);
      var kind  = firstProp(m, ['kind','KIND','type','TYPE']);
      var topic = firstProp(m, ['topic','TOPIC']);
      var wid   = Number(firstProp(m, ['widgetId','WIDGETID','WIDGET_ID','widgetID']));
      console.log('[HB][WS] PARSED:', {kind:kind, topic:topic, widgetId:wid});

      if ((kind === 'invalidate' || topic === 'widget.invalidate') && wid === WID) {
        console.log('[HB][WS] HIT → re-fetch');
        fetchAndRender(true);
      }
    };
  })();
  </script>
</cfoutput>