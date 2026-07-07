<!--- dynamic_semantic_widget.cfm — Semantic (model) tabanlı widget renderer --->
<cfsetting showdebugoutput="false">
<cfcontent type="text/html; charset=utf-8">

<!-- ==== Parametre / Ortam ==== -->
<cfparam name="DSN" default="workcube_test">
<cfparam name="url.widgetid" type="numeric">

<cfset thisWidgetId = val(url.widgetid)>
<cfset scheme   = ( structKeyExists(cgi,"https") AND len(cgi.https) AND lcase(cgi.https) EQ "on" ) ? "https" : "http">
<cfset portPart = ( structKeyExists(cgi,"server_port") AND len(cgi.server_port) AND NOT listFind("80,443", cgi.server_port) ? ":" & cgi.server_port : "" )>
<cfset baseUrl  = scheme & "://" & cgi.server_name & portPart>
<cfset runApi   = baseUrl & "/v16/add_options/report/api/semantic/models/run.cfm">

<!-- ==== Widget Config ==== -->
<cfquery name="qDef" datasource="#DSN#">
  SELECT WIDGET_NAME, WIDGET_CONFIG
  FROM DASHBOARD_WIDGET_DEFS
  WHERE WIDGET_ID = <cfqueryparam value="#thisWidgetId#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif qDef.recordcount EQ 0 OR NOT len(qDef.WIDGET_CONFIG)>
  <h3 style="margin:0">Geçersiz veya eksik widget.</h3>
  <cfabort>
</cfif>

<cfset widgetTitle = qDef.WIDGET_NAME>
<cfset cfgRoot     = deserializeJSON(qDef.WIDGET_CONFIG)>
<!--- { kind:"semantic", cfg:{...}, viz:{...}, vizOptions:{...}, format:{...} } --->
<cfset cfg         = (structKeyExists(cfgRoot, "cfg") ? cfgRoot.cfg : structNew())>
<cfset viz         = (structKeyExists(cfgRoot, "viz") ? cfgRoot.viz : structNew())>
<cfset vizOptions  = (structKeyExists(cfgRoot, "vizOptions") ? cfgRoot.vizOptions : structNew())>

<cfif NOT structKeyExists(cfg, "modelRef") OR NOT structKeyExists(cfg.modelRef, "modelUid")>
  <h3 style="margin:0">Eksik konfigürasyon: modelRef.modelUid</h3>
  <cfabort>
</cfif>

<!-- ==== Bu widget hangi işlemleri (fuseaction) dinliyor? ==== -->
<cfquery name="qOps" datasource="#DSN#">
  SELECT FUSEACTION
  FROM DASHBOARD_WIDGET_OPERATION_MAP
  WHERE WIDGET_ID = <cfqueryparam value="#thisWidgetId#" cfsqltype="cf_sql_integer">
</cfquery>
<cfset opList = []>
<cfloop query="qOps"><cfset arrayAppend(opList, qOps.FUSEACTION)></cfloop>

<!-- ==== İlk veri (server-side) için run.cfm’e POST ==== -->
<cfhttp url="#runApi#" method="post" timeout="30" result="runHttp">
  <cfhttpparam type="header" name="Content-Type" value="application/json; charset=utf-8">
  <cfhttpparam type="body" value="#serializeJSON(cfg)#">
</cfhttp>

<cfset runRaw = runHttp.fileContent>
<cfif NOT isJSON(runRaw)>
  <h3 style="margin:0">Koşum hatası</h3>
  <div style="color:#b91c1c">run.cfm JSON dönmedi.</div>
  <cfabort>
</cfif>

<cfset runResp = deserializeJSON(runRaw)>
<cfif NOT structKeyExists(runResp,"success") OR NOT runResp.success>
  <h3 style="margin:0">Sorgu başarısız</h3>
  <div style="color:#b91c1c">#encodeForHtml( runResp.message ?: "Bilinmeyen hata" )#</div>
  <cfif structKeyExists(runResp,"sql") AND len(runResp.sql)>
    <details style="margin-top:6px"><summary>SQL</summary><pre style="white-space:pre-wrap">#encodeForHtml(runResp.sql)#</pre></details>
  </cfif>
  <cfabort>
</cfif>

<!-- ==== JSON embed ==== -->
<cfset rows     = ( structKeyExists(runResp,"rows") AND isArray(runResp.rows) ? runResp.rows : [] )>
<cfset rowsJson = serializeJSON(rows)>
<cfset vizJson  = serializeJSON(viz)>
<cfset vizOptJson = serializeJSON(vizOptions)>
<cfset cfgJson  = serializeJSON(cfg)>
<cfset liveOpsJson = serializeJSON(opList)>

<!-- ==== WebSocket Aboneliği ==== -->
<cfwebsocket name="hbw_sem" subscribeTo="soketkanal" onMessage="__hbOnMsgSem" onOpen="__hbOpenSem" onError="__hbErrSem" />

<!-- ==== HTML/JS ==== -->
<cfoutput>
<style>
  :root { --wb-h: 300px; }
  body { margin: 0; font: 13px/1.4 system-ui, -apple-system, Segoe UI, Roboto, Arial; }
  .wb-wrap { padding: 8px 10px; }
  .wb-muted { color:##6b7280; font-size:12px; }
  canvas { width: 100% !important; height: var(--wb-h) !important; }
  table { border-collapse: collapse; width: 100%; font-size: 12px; }
  th, td { padding: 6px 8px; border-bottom: 1px solid ##eef0f3; text-align: left; white-space: nowrap; }
  th { background: ##f7f8fb; position: sticky; top: 0; }
  .wb-badge {
    position:absolute; top:6px; right:8px; font-size:11px; color:##065f46; background:##d1fae5;
    border:1px solid ##34d399; border-radius:999px; padding:2px 8px; display:none;
  }
  .wb-host-wrap { position:relative; }
</style>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<div class="wb-wrap">
  <!-- İsteğe bağlı başlık
  <h2>#encodeForHtml(widgetTitle)#</h2>
  -->

  <!-- Server JSON'ları -->
  <script id="wb-rows"  type="application/json">#rowsJson#</script>
  <script id="wb-viz"   type="application/json">#vizJson#</script>
  <script id="wb-vizop" type="application/json">#vizOptJson#</script>
  <script id="wb-cfg"   type="application/json">#cfgJson#</script>
  <script id="wb-ops"   type="application/json">#liveOpsJson#</script>
  <script id="wb-run"   type="application/json">#serializeJSON(runApi)#</script>
  <script id="wb-id"    type="application/json">#serializeJSON(thisWidgetId)#</script>

  <!-- Grafik/Tablo host -->
  <div class="wb-host-wrap">
    <div class="wb-badge" id="wb-badge">✓ Yenilendi</div>
    <div id="wb-host"><canvas id="widgetChart"></canvas></div>
  </div>
</div>

<script>
(function(){
  /* ===== Helpers ===== */
  function isNum(v){ return v!==null && v!=='' && !isNaN(parseFloat(v)); }
  function debounce(fn,ms){ var t; return function(){ var a=arguments; clearTimeout(t); t=setTimeout(function(){ fn.apply(null,a); }, ms||300); }; }

  // CF Query JSON → rows[]
  function cfQueryJsonToRows(cfjson){
    var j = cfjson || {};
    var C = j.COLUMNS || j.columns || [];
    var D = j.DATA || j.data;
    if (!C || !D) return [];
    var rows = [];
    if (Array.isArray(D) && Array.isArray(D[0])) {
      for (var i=0;i<D.length;i++){
        var row={}; for (var c=0;c<C.length;c++){ row[C[c]] = D[i][c]; } rows.push(row);
      }
    } else if (typeof D === "object"){
      var len = (D[C[0]] || []).length;
      for (var r=0;r<len;r++){
        var row={}; for (var k=0;k<C.length;k++){ var key=C[k]; row[key] = (D[key] || [])[r]; } rows.push(row);
      }
    }
    return rows;
  }

  // Farklı şemaları normalize et
  function normalizeRunResp(d){
    if (!d || typeof d !== 'object') return { success:false, rows:[], message:'' };
    var success = !!(d.success === true || d.SUCCESS === true || String(d.success).toLowerCase() === 'true');
    var rows = d.rows || d.ROWS || d.data || d.DATA || [];
    if ((!Array.isArray(rows) || !rows.length) && (d.COLUMNS || d.columns) && (d.DATA || d.data)){
      rows = cfQueryJsonToRows(d);
    }
    if (!Array.isArray(rows)) rows = [];
    var message = d.message || d.MESSAGE || '';
    return { success: success, rows: rows, message: message };
  }

  /* ===== Bootstrap Data ===== */
  var rows  = []; try { rows = JSON.parse(document.getElementById('wb-rows').textContent || '[]'); } catch(e){}
  var viz   = {}; try { viz  = JSON.parse(document.getElementById('wb-viz').textContent  || '{}'); } catch(e){}
  var vopt  = {}; try { vopt = JSON.parse(document.getElementById('wb-vizop').textContent|| '{}'); } catch(e){}
  var cfg   = {}; try { cfg  = JSON.parse(document.getElementById('wb-cfg').textContent  || '{}'); } catch(e){}
  var LIVE_OPS = []; try { LIVE_OPS = JSON.parse(document.getElementById('wb-ops').textContent || '[]'); } catch(e){}
  var RUN_URL  = ''; try { RUN_URL  = JSON.parse(document.getElementById('wb-run').textContent || '""'); } catch(e){}
  var WIDGET_ID= null; try { WIDGET_ID= JSON.parse(document.getElementById('wb-id').textContent  || 'null'); } catch(e){}

  console.log('[semantic-widget] init → widgetId=', WIDGET_ID, 'liveOps=', LIVE_OPS);

  var typeIn = (viz.chartType || 'bar');
  var type   = (typeIn === 'area') ? 'line' : typeIn;

  /* ===== Auto X/Y Mapping ===== */
  var keys = rows.length ? Object.keys(rows[0]||{}) : [];
  function autoMap(){
    var x = viz.x, y = viz.y;
    if(!x || (keys.length && keys.indexOf(x) < 0)){
      var cat = (rows[0] && keys.find(function(k){ return !isNum(rows[0][k]); })) || null;
      x = cat || keys[0] || null;
    }
    if(!Array.isArray(y) || !y.length){
      y = (rows[0] ? keys.filter(function(k){ return k!==x && isNum(rows[0][k]); }) : []);
      if(!y.length && keys.length>1){ y = [ keys.find(function(k){return k!==x;}) ]; }
    }
    return {x:x, y:y};
  }
  var map = autoMap();

  /* ===== Chart/Table Render ===== */
  var chart = null;
  function renderTable(){
    var host = document.getElementById('wb-host');
    if(!rows.length){ host.innerHTML = '<div class="wb-muted">Veri yok</div>'; return; }
    var cols = Object.keys(rows[0] || {});
    var html = '<div style="max-height:var(--wb-h);overflow:auto"><table><thead><tr>';
    cols.forEach(function(c){ html += '<th>'+c+'</th>'; });
    html += '</tr></thead><tbody>';
    rows.forEach(function(r){
      html += '<tr>';
      cols.forEach(function(c){ html += '<td>'+ (r[c]===undefined?'':r[c]) +'</td>'; });
      html += '</tr>';
    });
    html += '</tbody></table></div>';
    host.innerHTML = html;
  }

  function buildDatasets(yKeys){
    return yKeys.map(function(k){
      if(type === 'scatter' || type === 'bubble'){
        var data = rows.map(function(r){
          var xv = parseFloat(r[map.x]), yv = parseFloat(r[k]);
          if(isNaN(xv) || isNaN(yv)) return null;
          return { x:xv, y:yv, r:(type==='bubble' ? Math.max(3, Math.min(12, Math.abs(yv))) : undefined) };
        }).filter(Boolean);
        return { label:k, data:data, showLine:false, parsing:false };
      }
      var dataArr = rows.map(function(r){ var v = parseFloat(r[k]); return isNaN(v)? null : v; });
      return { label:k, data:dataArr, fill:(typeIn==='area'), tension:(typeIn==='area')?0.25:0 };
    });
  }

  function draw(){
    var host = document.getElementById('wb-host');
    if(type === 'table'){ if(chart){ chart.destroy(); chart=null; } renderTable(); return; }

    var labels = rows.map(function(r){ return String(r[map.x]); });
    var datasets = buildDatasets(map.y);

    if(chart){
      chart.config.type = (typeIn === 'area') ? 'line' : typeIn;
      chart.data.labels = labels;
      chart.data.datasets = datasets;
      chart.update();
      return;
    }

    var ctx = document.getElementById('widgetChart').getContext('2d');
    chart = new Chart(ctx, {
      type: (typeIn === 'area') ? 'line' : typeIn,
      data: { labels: labels, datasets: datasets },
      options: {
        responsive: true, maintainAspectRatio: false,
        scales: (type==='pie'||type==='doughnut'||type==='polarArea') ? {} : {
          x: { ticks: { autoSkip: true, maxTicksLimit: 8 } },
          y: { beginAtZero: true }
        },
        plugins: { legend: { display: true }, tooltip: { enabled: true } },
        elements: { point: { radius: (type==='line'||typeIn==='area')?2:3 } }
      }
    });
  }

  // İlk çizim
  draw();

  // Yenilendi rozeti
  var showBadge = (function(){
    var t; return function(){
      var b = document.getElementById('wb-badge'); if(!b) return;
      b.style.display='inline-block';
      clearTimeout(t);
      t = setTimeout(function(){ b.style.display='none'; }, 1200);
    };
  })();

  // Güvenli yeniden çizim (destroy → create)
  function hardRedraw(){
    if (chart) { try{ chart.destroy(); }catch(_){ } chart = null; }
    draw();
  }

  // Re-fetch (run.cfm) — normalize + hardRedraw
  var doRefresh = debounce(function(){
    if(!RUN_URL){ console.warn('[semantic-widget] RUN_URL yok.'); return; }
    console.log('[semantic-widget] doRefresh() → run.cfm POST. widgetId=', WIDGET_ID);

    fetch(RUN_URL, {
      method: 'POST',
      headers: {
        'Accept': 'application/json; charset=utf-8',
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: JSON.stringify(cfg)
    })
    .then(function(r){ return r.text(); })
    .then(function(txt){
      var raw;
      try { raw = JSON.parse(txt); }
      catch(e){
        console.error('[semantic-widget] JSON parse fail', { body: (txt||'').slice(0,200) });
        return;
      }
      var n = normalizeRunResp(raw);
      if(!n.success){
        console.warn('[semantic-widget] refresh hata:', n.message);
        return;
      }
      rows = n.rows;
      keys = rows.length ? Object.keys(rows[0]||{}) : [];

      // Kaydedilmiş X/Y hâlâ geçerliyse koru, değilse otomatik eşle
      if(!viz.x || keys.indexOf(viz.x) < 0 || !Array.isArray(viz.y) || !viz.y.length){
        map = autoMap();
      } else {
        map = { x: viz.x, y: viz.y.slice(0) };
      }

      console.log('[semantic-widget] grafik yeniden çiziliyor. satır sayısı=', rows.length);
      hardRedraw();
      showBadge();
    })
    .catch(function(e){
      console.error('[semantic-widget] refresh exception', e);
    });
  }, 400);

  /* ===== WebSocket Eventleri ===== */
  window.__hbOpenSem = function(info){
    try{ console.log('[semantic-widget][WS] OPEN soketkanal', info); }catch(_){}
  };
  window.__hbErrSem = function(err){
    try{ console.warn('[semantic-widget][WS] ERROR', err); }catch(_){}
  };
  window.__hbOnMsgSem = function(message){
    var raw = message && message.data ? message.data : message;
    console.log('[semantic-widget][WS] RAW:', raw);

    // JSON dene
    var m = {};
    if (typeof raw === 'string'){
      try { m = JSON.parse(raw); } catch(e){
        // "invalidate:123" gibi düz string olabilir
        if (raw.indexOf('invalidate:') === 0){
          var wid = Number(raw.split(':')[1]||'0');
          if (wid === WIDGET_ID){ console.log('[semantic-widget][WS] invalidate(hit) → refresh'); doRefresh(); }
          return;
        }
        m = {};
      }
    } else if (typeof raw === 'object' && raw){ m = raw; }

    // Çeşitli alan adlarıyla gelebilir
    var kind  = m.kind || m.KIND || m.type || m.TYPE || '';
    var topic = m.topic || m.TOPIC || '';
    var wid   = Number( m.widgetId || m.WIDGETID || m.WIDGET_ID || 0 );
    var fa    = m.fuseaction || m.fa || (m.detail ? (m.detail.fuseaction || m.detail.fa) : '') || '';

    // 1) Widget-bazlı invalidation
    if ((kind === 'invalidate' || topic === 'widget.invalidate') && wid === WIDGET_ID){
      console.log('[semantic-widget][WS] invalidate(widgetId match) → refresh');
      doRefresh(); return;
    }

    // 2) İşlem-bazlı tetik (fuseaction eşleşmesi)
    if ((kind === 'operation' || topic === 'operation' || fa) && Array.isArray(LIVE_OPS) && LIVE_OPS.length){
      if (fa && LIVE_OPS.indexOf(String(fa)) >= 0){
        console.log('[semantic-widget][WS] operation match (', fa, ') → refresh');
        doRefresh(); return;
      }
    }
  };

  /* ===== İsteğe bağlı: postMessage / harici bus ===== */
  window.addEventListener('message', function(ev){
    var d = ev && ev.data ? ev.data : {};
    var t = d.type || '';
    var fa = d.fuseaction || d.fa || '';
    if (!t) return;
    if (t === 'workcube:operation' || t === 'operation'){
      if (Array.isArray(LIVE_OPS) && LIVE_OPS.indexOf(String(fa)) >= 0){
        console.log('[semantic-widget] postMessage tetik:', fa, 'widgetId=', WIDGET_ID);
        doRefresh();
      }
    }
  });
})();
</script>
</cfoutput>
