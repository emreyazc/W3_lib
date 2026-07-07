<!--- ====== CLIENT TARAFI: MODAL + WIZARD UI (Chart.js preview, stacked layout) ====== --->
<cfsetting showdebugoutput="false">
<cfoutput>
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<!-- CodeMirror 5 -->
<link  rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css">
<link  rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/theme/eclipse.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/sql/sql.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/matchbrackets.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/closebrackets.min.js"></script>


<style>
  .sw-modal{position:fixed;inset:0;background:rgba(0,0,0,.5);display:none;z-index:9999}
  .sw-dialog{width:min(1000px,92vw);max-height:92vh;overflow:auto;margin:4vh auto;background:##fff;border-radius:14px;box-shadow:0 10px 30px rgba(0,0,0,.2)}
  .sw-header{position:relative;display:block;padding:16px 20px;border-bottom:1px solid ##eee}
  .sw-title{font-weight:700}
  .sw-close{position:absolute;right:12px;top:6px}
  .sw-body{padding:16px 20px}
  .sw-footer{display:flex;gap:8px;padding:12px 20px;border-top:1px solid ##eee;justify-content:flex-end}
  .sw-steps{display:flex;gap:8px;padding:10px 20px;border-bottom:1px solid ##eee}
  .sw-step{padding:6px 10px;border-radius:8px;background:##f5f5f5;font-size:12px}
  .sw-step.active{background:##111;color:##fff}

  /* Stacked form */
  .sw-stack{display:flex;flex-direction:column;gap:12px}
  .sw-field{display:flex;flex-direction:column}
  .sw-label{display:block;margin-bottom:6px;font-size:12px;color:##666;line-height:1}
  .sw-input,.sw-textarea,.sw-select{width:100%;padding:10px;border:1px solid ##ddd;border-radius:10px;box-sizing:border-box}
  .sw-textarea{min-height:160px;font-family:ui-monospace,Consolas,monospace}
  .sw-select[multiple]{min-height:120px}
  .sw-hint{font-size:12px;color:##666}
  .sw-badge{font-size:12px;background:##f2f2f2;border-radius:8px;padding:4px 8px;margin-left:8px}
  .sw-row{display:flex;align-items:center;gap:8px}
  .sw-divider{height:1px;background:##eee;margin:12px 0}

  .sw-btn{padding:10px 14px;border-radius:10px;border:1px solid ##ddd;background:##fafafa;cursor:pointer}
  .sw-btn.primary{background:##111;color:##fff;border-color:##111}
  .sw-btn.ghost{position:absolute; background:transparent}

  .sw-table{width:100%;border-collapse:collapse;font-size:13px}
  .sw-table th,.sw-table td{border:1px solid ##eee;padding:6px 8px}
  .sw-kpi{display:flex;gap:12px;align-items:baseline}
  .sw-kpi .val{font-size:32px;font-weight:700}
  /* Pager (Geri/İlerle aynı bölgede) */
  .sw-pager{display:flex;justify-content:space-between;align-items:center;gap:8px;margin-top:16px}
  /* sticky alt barlar (pager & footer) */
  .sw-pager { position: sticky; bottom: 0; background: ##fff; padding: 12px 20px; margin: 0 -20px; border-top: 1px solid ##eee; z-index: 2; }
  .sw-footer { position: sticky; bottom: 0; background: ##fff; }
  /* zebra tablo & hover */
  .sw-table tbody tr:nth-child(odd){ background: ##fafafa; }
  .sw-table tbody tr:hover { background: ##f0f7ff; }
  /* buton loading durumu */
  .sw-btn{ position: relative; }
  .sw-btn.loading{ pointer-events:none; opacity:.75; }
  @keyframes swspin{ to{ transform: rotate(360deg); } }
  .sw-btn.loading::after{
    content:""; position:absolute; left:50%; top:50%; width:14px; height:14px; margin:-7px 0 0 -7px;
    border:2px solid ##9ca3af; border-top-color: transparent; border-radius:50%; animation: swspin .8s linear infinite;
  }
  /* CodeMirror kutusu görünümü */
  .CodeMirror{
    height: 260px;
    border: 1px solid ##ddd;
    border-radius: 10px;
    font-family: ui-monospace,Consolas,monospace;
    font-size: 13px;
  }
  /* === Dark Mode Overrides (body.dark-mode iken) === */
  .dark-mode .sw-dialog{ background: ##0b0f14; color: ##e5e7eb; border-color: ##1f2937; }
  .dark-mode .sw-header{ border-bottom-color: ##1f2937; }
  .dark-mode .sw-footer, .dark-mode .sw-pager{ background: ##0b0f14; border-top-color: ##1f2937; }
  .dark-mode .sw-step{ background: ##111827; color: ##d1d5db; }
  .dark-mode .sw-step.active{ background: ##2563eb; color: ##fff; }

  .dark-mode .sw-input, 
  .dark-mode .sw-textarea, 
  .dark-mode .sw-select{ 
    background: ##0f1621; 
    color: ##e5e7eb; 
    border-color: ##334155; 
  }
  .dark-mode .sw-input::placeholder,
  .dark-mode .sw-textarea::placeholder{ color: ##9ca3af; }

  .dark-mode .sw-badge{ background: ##111827; color: ##d1d5db; }
  .dark-mode .sw-hint{ color: ##9ca3af; }

  .dark-mode .sw-table th, 
  .dark-mode .sw-table td{ border-color: ##1f2937; }
  .dark-mode .sw-table tbody tr:nth-child(odd){ background: ##0f1621; }
  .dark-mode .sw-table tbody tr:hover{ background: ##132030; }

  .dark-mode .sw-btn{ background: ##111827; border-color: ##334155; color: ##e5e7eb; }
  .dark-mode .sw-btn.primary{ background: ##2563eb; border-color: ##2563eb; color: ##fff; }

  /* CodeMirror kutusu koyu zeminle uyumlu (tema: darcula) */
  .dark-mode .CodeMirror{
    background: ##1e1f22; 
    color: ##f5f5f5; 
    border-color: ##334155;
  }
</style>

<div id="sqlWidgetModal" class="sw-modal" data-api="/V16/add_options/report/query/sql_widget_query.cfm">
  <div class="sw-dialog">
    <div class="sw-header">
      <span class="sw-title">SQL Widget Sihirbazı</span>
      <span id="swTitleBadge" class="sw-badge">Yeni</span>
      <button class="sw-btn ghost sw-close" onclick="document.getElementById('sqlWidgetModal').style.display='none'">Kapat</button>
    </div>

    <div class="sw-steps">
      <div class="sw-step active" data-step="1">1) Bilgi & SQL</div>
      <div class="sw-step" data-step="2">2) Önizleme & Görselleştirme</div>
    </div>

    <!-- STEP 1 -->
    <div class="sw-body" id="step1">
      <div class="sw-stack">
        <div class="sw-field">
          <label class="sw-label" for="wName">Widget Adı</label>
          <input id="wName" class="sw-input" placeholder="Örn: İllere Göre Sipariş">
        </div>
        <div class="sw-field">
          <label class="sw-label" for="opSelect">İşlem</label>
          <select class="sw-select" id="opSelect" name="OP_FUSEACTION[]" multiple size="5">
            <option value="sales.list_offer" data-label="Satış Teklifleri">Satış Teklifleri</option>
            <option value="sales.list_order" data-label="Satış Siparişleri">Satış Siparişleri</option>
            <option value="purchase.list_order" data-label="Satınalma Siparişleri">Satınalma Siparişleri</option>
            <option value="invoice.form_add_bill" data-label="Satış Faturası">Satış Faturası</option>
            <option value="project.projects" data-label="Proje Yönetimi">Proje Yönetimi</option>
          </select>
        </div>
        <div class="sw-field">
          <label class="sw-label" for="wDesc">Açıklama</label>
          <input id="wDesc" class="sw-input" placeholder="Kısa açıklama (opsiyonel)">
        </div>
        <div class="sw-field">
          <label class="sw-label" for="wSQL">SQL Sorgusu</label>
          <div class="sw-row" style="justify-content:flex-end; gap:8px; margin-bottom:6px">
            <button class="sw-btn" onclick="beautifySQL()">Biçimlendir</button>
            <button class="sw-btn" onclick="minifySQL()">Sadeleştir</button>
          </div>          
          <textarea id="wSQL" class="sw-textarea" placeholder="SELECT CITY, COUNT(*) AS ORDER_COUNT FROM ... GROUP BY CITY"></textarea>
          <div class="sw-row" style="justify-content:space-between;margin-top:6px">
            <div class="sw-hint">İpucu: Önizleme sadece <strong>SELECT</strong> sorgusu çalıştırır. Önizleme TOP 100 uygular.</div>
          </div>
        </div>
      </div>

      <div class="sw-pager">
        <button class="sw-btn primary" onclick="goStep(2,true)">İlerle →</button>
      </div>
    </div>

    <!-- STEP 2 -->
    <div class="sw-body" id="step2" style="display:none">
      <!-- üst araç çubuğu: Test Et -->
      <div class="sw-row" style="justify-content:flex-end;margin-bottom:8px">
        <button id="btnPreview" class="sw-btn" onclick="doPreview()">Test Et (Önizleme)</button>
        <span id="previewBadge" class="sw-badge" aria-live="polite">Beklemede</span>
      </div>

      <div class="sw-stack">
        <div class="sw-field">
          <label class="sw-label">Önizleme — Tablo</label>
          <div class="sw-row" style="justify-content:flex-end; gap:8px; margin:6px 0">
            <button class="sw-btn" onclick="copyCSV()">Kopyala (CSV)</button>
            <button class="sw-btn" onclick="exportCSV()">CSV indir</button>
          </div>          
          <div id="tableHost" style="border:1px solid ##eee;border-radius:10px;padding:8px;overflow:auto;max-height:240px">
            <div class="sw-hint">“Test Et” ile önizleme alın.</div>
          </div>
        </div>

        <div class="sw-divider"></div>

        <div class="sw-field">
          <label class="sw-label" for="chartType">Görselleştirme Tipi</label>
          <select id="chartType" class="sw-select" onchange="onChartTypeChanged()">
            <option value="auto">Otomatik (öner)</option>
            <option value="kpi">KPI (tek değer)</option>
            <option value="table">Tablo</option>
            <option value="bar">Bar</option>
            <option value="line">Line</option>
            <option value="pie">Pie</option>
          </select>
        </div>

        <div id="rolePanel" class="sw-stack" style="display:none">
          <div class="sw-field">
            <label class="sw-label" for="dimField">Dimension (X)</label>
            <select id="dimField" class="sw-select"></select>
          </div>
          <div class="sw-field">
            <label class="sw-label" for="measSelect">Measure (Y - çoklu)</label>
            <select id="measSelect" class="sw-select" multiple size="6"></select>
          </div>
          <div class="sw-field">
            <label class="sw-label" for="sortField">Sıralama</label>
            <select id="sortField" class="sw-select"></select>
          </div>
        </div>

        <div class="sw-field">
          <label class="sw-label">Önizleme — Grafik</label>
          <div class="sw-row" style="justify-content:flex-end; gap:8px; margin:6px 0">
            <button class="sw-btn" onclick="downloadPNG()">PNG indir</button>
          </div>          
          <div id="chartHost" style="border:1px solid ##eee;border-radius:10px;padding:8px;min-height:260px">
            <canvas id="chartCanvas" style="width:100%;height:260px"></canvas>
          </div>
        </div>
      </div>

      <div class="sw-pager">
        <button class="sw-btn" onclick="goStep(1)">← Geri</button>
        <button class="sw-btn" onclick="doPreview()">Yenile</button>
      </div>
    </div>

    <div class="sw-footer">
      <button class="sw-btn" onclick="document.getElementById('sqlWidgetModal').style.display='none'">Vazgeç</button>
      <button id="btnSave" class="sw-btn primary" onclick="doSave()">Kaydet</button>
    </div>
  </div>
</div>

  <script>
    // Global tema durumu
    let SW_THEME = null;

    // Dashboard'daki temayı oku
    function getDashboardTheme(){
      const ls = localStorage.getItem('dashboardTheme');
      if (ls === 'dark' || ls === 'light') return ls;
      // body class'tan çıkarım
      if (document.body.classList.contains('dark-mode')) return 'dark';
      return 'light';
    }
    // Chart.js görünümünü tema ile uyumla
    function applyChartTheme(theme){
      const dark = (theme === 'dark');
      const textColor = dark ? 'rgb(229,231,235)' : 'rgb(17,24,39)';
      const gridColor = dark ? 'rgb(55,65,81)'   : 'rgb(229,231,235)';
      // Global defaults
      if (window.Chart && Chart.defaults){
        Chart.defaults.color = textColor;
        Chart.defaults.borderColor = gridColor;
      }
    }
    // CodeMirror temasını ayarla
    function applyEditorTheme(theme){
      // CM, ensureEditor ile atanıyor
      if (typeof ensureEditor === 'function') ensureEditor();
      if (window.CM){
        CM.setOption('theme', theme === 'dark' ? 'darcula' : 'eclipse');
      }
    }
    // Wizard'ı temaya göre güncelle (CSS + Chart + CM)
    function syncThemeToWizard(theme){
      if (!theme) theme = getDashboardTheme();
      SW_THEME = theme;
      const modal = document.getElementById('sqlWidgetModal');
      if (modal) modal.setAttribute('data-theme', theme);

      applyEditorTheme(theme);
      applyChartTheme(theme);

      // Grafiği yeni temayla tazele (varsa)
      if (typeof renderChartPreview === 'function'){
        // reflow'a saygı: canvas hazırsa çiz
        reflowThen(()=>{ return renderChartPreview() && visibleWidth(document.getElementById('chartHost'))>50; });
      }
    }
    let CM = null; // CodeMirror instance
    function ensureEditor(){
      if (CM) return CM;
      const ta = document.getElementById('wSQL');
      if (!ta || typeof CodeMirror === 'undefined') return null;
      CM = CodeMirror.fromTextArea(ta, {
        mode: 'text/x-mssql',    // T-SQL
        theme: 'eclipse',
        lineNumbers: true,
        lineWrapping: true,
        matchBrackets: true,
        autoCloseBrackets: true,
        indentUnit: 2,
        tabSize: 2
      });
      CM.setOption('theme', getDashboardTheme()==='dark' ? 'darcula' : 'eclipse');
      // Kısayollar (editör odağındayken)
      CM.addKeyMap({
        'Ctrl-Enter': ()=> doPreview(),
        'Cmd-Enter' : ()=> doPreview(),
        'Ctrl-S'    : cm => { cm.execCommand('save'); doSave(); },
        'Cmd-S'     : ()=> doSave()
      });
      // Boyut garanti (CSS de set ediyor ama burada da sabitleyelim)
      CM.setSize(null, 260);
      return CM;
    }
    function getSQL(){
      const ta = document.getElementById('wSQL');
      return (CM ? CM.getValue() : (ta?.value || ''));
    }
    function setSQL(val){
      const ta = document.getElementById('wSQL');
      if (CM) CM.setValue(val || '');
      else if (ta) ta.value = val || '';
    }

    function hslToRgba(h, s, l, a=1){
      // h:[0..360], s/l:[0..100], a:[0..1]
      s/=100; l/=100;
      const c=(1-Math.abs(2*l-1))*s;
      const x=c*(1-Math.abs((h/60)%2-1));
      const m=l-c/2;
      let r=0,g=0,b=0;
      if (0<=h && h<60)   { r=c; g=x; b=0; }
      else if (60<=h && h<120){ r=x; g=c; b=0; }
      else if (120<=h && h<180){ r=0; g=c; b=x; }
      else if (180<=h && h<240){ r=0; g=x; b=c; }
      else if (240<=h && h<300){ r=x; g=0; b=c; }
      else { r=c; g=0; b=x; }
      r=Math.round((r+m)*255); g=Math.round((g+m)*255); b=Math.round((b+m)*255);
      return `rgba(${r},${g},${b},${a})`;
    }

    // Tema duyarlı renk paleti
    function getPalette(theme, count, forPie=false){
      // Doygun ve ayrık tonlar
      const hues = [210, 10, 145, 40, 280, 100, 340, 190, 25, 160, 300, 55];
      const dark  = theme === 'dark';
      const res = [];
      for (let i=0;i<count;i++){
        const h = hues[i % hues.length] + (i>=hues.length ? (i*17)%360 : 0);
        // Lightness/saturation tema bazlı
        const s = dark ? 70 : 65;
        const lBorder = dark ? 60 : 45;
        const lFill   = dark ? 55 : 50;
        // Pasta diliminde daha opak dolduralım
        const aFill   = forPie ? 0.85 : 0.35;
        res.push({
          border: hslToRgba(h, s, lBorder, 1),
          fill  : hslToRgba(h, s, lFill,   aFill)
        });
      }
      return res;
    }

    /* ===== Globals ===== */
    let SW_CHART = null;
    let SW_STATE = {
      widgetId: 0, name:"", desc:"", sql:"",
      columns: [], rows: [],
      chartType: "auto",
      roles: { dims:[], measures:[], sort:[] }
    };
    function isOk(r){ return !!(r && (r.success===true || r.SUCCESS===true)); }

    /* ===== Helpers ===== */
    function getApiBase(){
      const el = document.getElementById("sqlWidgetModal");
      return el?.dataset?.api || "#encodeForJavaScript(CGI.SCRIPT_NAME)#";
    }
    function visibleWidth(el){ if(!el) return 0; let w=el.getBoundingClientRect().width; if(!w){const p=el.closest('.sw-dialog')||el.parentElement; if(p) w=p.getBoundingClientRect().width;} return w; }
    function reflowThen(cb, tries=10){ requestAnimationFrame(()=>{ const ok=cb(); if(!ok && tries>0) setTimeout(()=>reflowThen(cb,tries-1), 40); }); }
    function safeKeys(obj){ const map={}; Object.keys(obj||{}).forEach(k=>{ map[k]=k; map[k.toLowerCase()]=k; map[k.toUpperCase()]=k; map[k.trim()]=k; }); return map; }
    function getVal(row, colName){
      if (row==null) return undefined;
      if (Array.isArray(row)) return row[0];
      if (Object.prototype.hasOwnProperty.call(row,colName)) return row[colName];
      const m=safeKeys(row); const k=m[colName]||m[(colName||"").toLowerCase()]||m[(colName||"").toUpperCase()]||m[(colName||"").trim()];
      if (k) return row[k];
      const ks=Object.keys(row); if (ks.length===1) return row[ks[0]];
      return undefined;
    }
    function lowerKeysDeep(x){
      if (Array.isArray(x)) return x.map(lowerKeysDeep);
      if (x && typeof x === "object"){ const o={}; for (const k in x) o[k.toLowerCase()] = lowerKeysDeep(x[k]); return o; }
      return x;
    }
    function normalizePreviewResponse(raw){
      const r = lowerKeysDeep(raw||{});
      const columns = Array.isArray(r.columns) ? r.columns.map(c=>{
        if (c.name) return {name:c.name};
        if (c.NAME) return {name:c.NAME};
        const k = Object.keys(c)[0]; return {name:c[k]||k};
      }) : [];
      const rows = Array.isArray(r.rows) ? r.rows : [];
      const rowCount = Number(r.rowcount ?? rows.length ?? 0) || rows.length || 0;
      const elapsedMs = Number(r.elapsedms ?? r.elapsed ?? r.ms ?? r.time ?? 0) || 0;
      return { success: !!(r.success), columns, rows, rowCount, elapsedMs };
    }
    function toNumberLocaleAware(v){
      if (v===null || v===undefined) return NaN;
      if (typeof v==="number") return v;
      let s = String(v).trim();
      if (/^\d{1,3}(\.\d{3})*(,\d+)?$/.test(s)) s = s.replace(/\./g,"").replace(",","." );
      else if (/^\d+,\d+$/.test(s)) s = s.replace(",","." );
      const n = parseFloat(s); return isFinite(n)?n:NaN;
    }
    function inferColumnTypes(){
      const rows = SW_STATE.rows || [];
      const cols = SW_STATE.columns || [];
      const types = {};
      cols.forEach(c=>{
        let seen=0, num=0;
        for(let i=0;i<Math.min(rows.length,50);i++){
          const v = rows[i][c.name];
          if(v===null || v===undefined || v==="") continue;
          seen++; if(!isNaN(toNumberLocaleAware(v))) num++;
        }
        types[c.name] = (seen>0 && num/seen > 0.6) ? "number" : "text";
      });
      return types;
    }

    /* ===== API ===== */
    async function apiPreview(sql){
      const fd = new FormData(); fd.append("sqlQuery", sql); fd.append("topN","100");
      const res = await fetch(getApiBase()+"?api=preview", { method:"POST", body: fd });
      return res.json();
    }
    async function apiLoad(widgetId){
      const res = await fetch(getApiBase()+"?api=load&widgetid="+widgetId);
      return res.json();
    }
    async function apiSave(payload){
      const res = await fetch(getApiBase()+"?api=save", {
        method:"POST", headers:{ "Content-Type":"application/json; charset=utf-8" }, body: JSON.stringify(payload)
      });
      return res.json();
    }

    // İlk yüklemede uygula
    document.addEventListener('DOMContentLoaded', ()=> {
      syncThemeToWizard(getDashboardTheme());
    });

    // applyTheme patch (varsa) – dashboard çağırdığında biz de senkron olalım
    if (typeof window.applyTheme === 'function'){
      const __origApplyTheme = window.applyTheme;
      window.applyTheme = function(theme){
        try { __origApplyTheme(theme); } finally { syncThemeToWizard(theme); }
      };
    }

    // localStorage üstünden gelen değişiklikleri dinle (başka tab veya üst kod)
    window.addEventListener('storage', (e)=>{
      if (e.key === 'dashboardTheme'){
        syncThemeToWizard(e.newValue === 'dark' ? 'dark' : 'light');
      }
    });

    // (opsiyonel) Eğer bir üst context'ten postMessage ile "setTheme" gelirse
    window.addEventListener('message', (ev)=>{
      if (ev && ev.data && ev.data.type === 'setTheme'){
        syncThemeToWizard(ev.data.theme);
      }
    });

    /* ===== Modal open (export global) ===== */
    function openSQLWidgetModal(arg1={}, arg2){
      // Eski imza: ('edit', id)   // Yeni imza: ({widgetId, api, mode, startStep})
      let mode, widgetId, api, startStep = 1;
      if (typeof arg1 === "object"){
        mode      = arg1.mode || (arg1.widgetId ? "edit" : "create");
        widgetId  = arg1.widgetId;
        api       = arg1.api;
        startStep = arg1.startStep || 1;
      } else {
        mode     = arg1;
        widgetId = arg2;
      }

      const modal = document.getElementById("sqlWidgetModal");
      if (api) modal.dataset.api = api;
      modal.style.display = "block";
      ensureEditor(); // <-- EKLENDİ
      syncThemeToWizard(getDashboardTheme());  // <-- EKLE
      resetWizard();    // Step 1 açık başlasın
      goStep(1);

      if (mode === "edit" && widgetId){
        SW_STATE.widgetId = widgetId;
        document.getElementById("swTitleBadge").textContent = "Düzenle";
        apiLoad(widgetId).then(r=>{
          if (!isOk(r)){ alert(r?.message || "Yüklenemedi"); return; }

          const raw = r.DATA || r.data || {};
          const d = lowerKeysDeep(raw);

          const name = d.widgetname || d.widget_name || d.name || "";
          const desc = d.description || d.desc || "";
          const sql  = d.sqlquery || d.sql_query || d.sql || "";
          const ct   = (d.charttype || (d.columns && d.columns.chart && d.columns.chart.type) || "auto").toLowerCase();

          // savedOps: hem orijinal camelCase'i hem lowercase'i dene
          const savedOps =
            (raw && Array.isArray(raw.opFuseactions)) ? raw.opFuseactions :
            (Array.isArray(d.opfuseactions) ? d.opfuseactions : []);

          const opSel = document.getElementById("opSelect");
          if (opSel) {
            Array.from(opSel.options).forEach(function (o) {
              o.selected = savedOps.indexOf(o.value) !== -1;
            });
          }

          document.getElementById("wName").value     = name;
          document.getElementById("wDesc").value     = desc;
          setSQL(sql);
          document.getElementById("chartType").value = ct;

          const loadedCols = raw.COLUMNS || raw.columns || d.columns;
          SW_STATE.roles = normalizeLoadedRoles(loadedCols);
          SW_STATE.name = name; SW_STATE.desc = desc; SW_STATE.sql = sql;

          if (startStep === 2){
            reflowThen(()=>{ goStep(2,true); return true; }, 1);
          }
        });
      } else {
        document.getElementById("swTitleBadge").textContent = "Yeni";
      }
    }
    window.openSQLWidgetModal = openSQLWidgetModal;

    /* ===== Wizard nav ===== */
    function goStep(step, from1To2=false){
      document.querySelectorAll(".sw-step").forEach(el=>{
        el.classList.toggle("active", el.getAttribute("data-step")==String(step));
      });
      document.getElementById("step1").style.display = (step==1?"block":"none");
      document.getElementById("step2").style.display = (step==2?"block":"none");

      if (step==2 && from1To2){
        SW_STATE.name = document.getElementById("wName").value.trim();
        SW_STATE.desc = document.getElementById("wDesc").value.trim();
        SW_STATE.sql  = getSQL().trim();
        if (!SW_STATE.name || !SW_STATE.sql){ alert("Widget adı ve SQL zorunludur."); goStep(1); return; }
        reflowThen(()=>{ doPreview(); return true; }, 1);
      }
    }

    /* ===== Roles/UI ===== */
    function disableXYCharts(disable){
      const sel = document.getElementById("chartType");
      ["bar","line","pie"].forEach(v=>{
        const opt = sel?.querySelector(`option[value="${v}"]`);
        if (opt) opt.disabled = !!disable;
      });
    }
    function setChartType(val){
      const sel = document.getElementById("chartType");
      if (!sel) return;
      const opt = sel.querySelector(`option[value="${val}"]`);
      sel.value = (opt && !opt.disabled) ? val : "table";
      onChartTypeChanged();
    }
    function onChartTypeChanged(){
      const ct = document.getElementById("chartType").value;
      document.getElementById("rolePanel").style.display =
        (ct==="bar"||ct==="line"||ct==="pie") ? "block" : "none";
      setupRolePanel(true); // seçimleri koru
      reflowThen(()=>{ renderChartPreview(); return visibleWidth(document.getElementById("chartHost"))>50; });
    }

    function setupRolePanel(restore=false){
      const types  = inferColumnTypes();
      const dimSel = document.getElementById("dimField");
      const measSel= document.getElementById("measSelect");
      const sortSel= document.getElementById("sortField");
      if(!dimSel || !measSel || !sortSel) return;

      dimSel.innerHTML=""; measSel.innerHTML=""; sortSel.innerHTML="";

      const cols = (SW_STATE.columns||[]).map(c=>c.name);
      cols.forEach(c=>{
        let o=document.createElement("option"); o.value=c; o.textContent=c; dimSel.appendChild(o);
        let s=document.createElement("option"); s.value=c; s.textContent=c; sortSel.appendChild(s);
      });

      let numCols = (SW_STATE.columns||[]).filter(c=>types[c.name]==="number").map(c=>c.name);
      if (numCols.length===0) numCols = cols.slice();

      const prior = restore ? (SW_STATE.roles || {}) : {};
      const priorDim = prior.dims && prior.dims[0] ? prior.dims[0].field : null;
      const priorMeasures = new Set((prior.measures||[]).map(m=>m.field));
      const priorSort = prior.sort && prior.sort[0] ? prior.sort[0].field : null;

      // Dimension
      const firstText = (SW_STATE.columns||[]).find(c=>types[c.name]!=="number");
      dimSel.value = (priorDim && cols.includes(priorDim))
        ? priorDim
        : (firstText ? firstText.name : (cols[0]||""));

      // Measures (multi select)
      numCols.forEach(c=>{
        const opt = document.createElement("option");
        opt.value = c; opt.textContent = c;
        if (priorMeasures.size ? priorMeasures.has(c) : false) opt.selected = true;
        measSel.appendChild(opt);
      });
      // Hiç seçim yoksa ilkini seç
      if (!measSel.selectedOptions.length && measSel.options.length){
        measSel.options[0].selected = true;
      }

      // Sort
      if (priorSort && cols.includes(priorSort)) sortSel.value = priorSort;

      // Events → State
      dimSel.onchange = () => {
        SW_STATE.roles.dims = [{field:dimSel.value,label:dimSel.value}];
        renderChartPreview();
      };
      measSel.onchange = () => {
        const selected = Array.from(measSel.selectedOptions).map(o=>o.value);
        SW_STATE.roles.measures = selected.map(x=>({field:x,agg:"SUM",label:x}));
        renderChartPreview();
      };
      sortSel.onchange = () => {
        SW_STATE.roles.sort = [{field:sortSel.value,dir:"DESC"}];
      };
    }

    function collectRoles(){
      const ct = document.getElementById("chartType").value;
      if (ct==="kpi" || ct==="table") return SW_STATE.roles || {dims:[],measures:[],sort:[]};

      const dim = document.getElementById("dimField")?.value;
      const measSel = document.getElementById("measSelect");
      const selectedMeasures = measSel ? Array.from(measSel.selectedOptions).map(o=>o.value) : [];
      const sortF = document.getElementById("sortField")?.value;

      const fallback = SW_STATE.roles || {dims:[],measures:[],sort:[]};
      const dims = dim ? [{field:dim,label:dim}] : (fallback.dims||[]);
      const measures = selectedMeasures.length ? selectedMeasures.map(m=>({field:m,agg:"SUM",label:m})) : (fallback.measures||[]);
      const sort = sortF ? [{field:sortF,dir:"DESC"}] : (fallback.sort||[]);
      return { dims, measures, sort };
    }
    function computePreviewRoles(chartType){
      let roles = collectRoles();
      const cols = (SW_STATE.columns||[]).map(c=>c.name);
      const types = inferColumnTypes();

      if (!roles.dims?.length){
        const firstText = cols.find(c=>types[c]!=="number");
        roles.dims = firstText ? [{field:firstText,label:firstText}] : (cols[0]?[{field:cols[0],label:cols[0]}]:[]);
      }
      if (!roles.measures?.length){
        let nums = cols.filter(c=>types[c]==="number");
        if (nums.length===0) nums = cols.filter(c=>c !== roles.dims[0]?.field);
        if (nums.length>0) roles.measures = [{field:nums[0], agg:"SUM", label:nums[0]}];
      }
      if (chartType==="pie" && roles.measures.length>1) roles.measures = [roles.measures[0]];
      return roles;
    }

    /* ===== Table ===== */
    function renderTable(){
      const host = document.getElementById("tableHost");
      let cols = SW_STATE.columns;
      if (!cols || cols.length===0){
        const firstRow = SW_STATE.rows?.[0] || {};
        cols = Object.keys(firstRow).map(k=>({name:k}));
      }
      if(!cols || cols.length===0){ host.innerHTML='<div class="sw-hint">Kolon yok.</div>'; return; }

      const rows = SW_STATE.rows || [];
      let thead = "<tr>" + cols.map(c=>`<th>${c.name}</th>`).join("") + "</tr>";
      let tbody = rows.slice(0,200).map(r=>{
        return "<tr>"+cols.map(c=>{
          const v = getVal(r, c.name);
          return `<td>${escapeHtml(v==null ? "" : v)}</td>`;
        }).join("")+"</tr>";
      }).join("");
      host.innerHTML = `<table class="sw-table"><thead>${thead}</thead><tbody>${tbody}</tbody></table>`;
    }
    function escapeHtml(s){ if(s==null) return ""; return String(s).replace(/[&<>"]/g, m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[m])); }

    /* ===== Preview (Chart.js) ===== */
    function drawChartJS(chartType, labels, datasets){
      if (!document.getElementById('chartCanvas')){
        document.getElementById('chartHost').innerHTML = '<canvas id="chartCanvas" style="width:100%;height:260px"></canvas>';
      }
      const ctx = document.getElementById('chartCanvas').getContext('2d');
      if (SW_CHART) { SW_CHART.destroy(); SW_CHART=null; }

      let type = chartType;
      let ds = datasets.map(d=>({...d}));
      const dark = (SW_THEME === 'dark');

      // Tip/alan ayarı
      if (chartType === 'area'){ type = 'line'; ds.forEach(d=>d.fill=true); }
      ds.forEach(d=>{ if(!d.borderWidth) d.borderWidth=2; });

      // Paleti hazırla
      if (type === 'pie'){
        // Pasta: tek dataset, çok renk
        const palette = getPalette(SW_THEME, labels.length, true);
        const bg = palette.map(p=>p.fill);
        const br = palette.map(p=>p.border);
        if (!ds[0]) ds[0] = { data: [] };
        if (!ds[0].backgroundColor) ds[0].backgroundColor = bg;
        if (!ds[0].borderColor)     ds[0].borderColor     = br;
      } else {
        // Bar/Line/Area: her dataset’e bir renk
        const palette = getPalette(SW_THEME, ds.length, false);
        ds = ds.map((d,i)=>{
          if (!d.backgroundColor) d.backgroundColor = (type==='line' ? palette[i].border : palette[i].fill);
          if (!d.borderColor)     d.borderColor     = palette[i].border;
          if (type==='line' && d.fill===true){
            // area fill
            d.backgroundColor = palette[i].fill;
          }
          return d;
        });
      }

      // Tema metin/grid/tooltip renkleri
      const textColor = dark ? 'rgb(229,231,235)' : 'rgb(17,24,39)';
      const gridColor = dark ? 'rgb(55,65,81)'   : 'rgb(229,231,235)';
      const tooltipBg = dark ? 'rgba(17,24,39,0.92)' : 'rgba(255,255,255,0.92)';
      const tooltipFg = dark ? 'rgb(229,231,235)' : 'rgb(17,24,39)';
      const nf = new Intl.NumberFormat('tr-TR');

      SW_CHART = new Chart(ctx, {
        type: type || 'bar',
        data: { labels, datasets: ds },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: { labels: { color: textColor }, display: ds.length > 1 || type==='pie' },
            tooltip: {
              backgroundColor: tooltipBg,
              titleColor: tooltipFg,
              bodyColor: tooltipFg,
              callbacks: {
                label: (ctx)=>{
                  const lab = ctx.dataset.label ? ctx.dataset.label + ': ' : '';
                  const val = (ctx.parsed && (typeof ctx.parsed.y!=='undefined')) ? ctx.parsed.y : ctx.parsed;
                  return lab + (isFinite(val) ? nf.format(val) : val);
                }
              }
            }
          },
          elements: { line: { tension: (chartType==='area'?0.25:0) } },
          scales: (type==='pie') ? {} : {
            x: { ticks: { color: textColor }, grid: { color: gridColor } },
            y: { ticks: { color: textColor, callback: (v)=> nf.format(v) }, grid: { color: gridColor } }
          }
        }
      });
    }

    function renderChartPreview(){
      const host = document.getElementById("chartHost");
      const ctSel = document.getElementById("chartType");
      const chosen = ctSel ? ctSel.value : "auto";
      const rows = SW_STATE.rows || [];
      const cols = SW_STATE.columns || [];

      if (!rows.length){
        host.innerHTML = `<div class="sw-hint">Veri yok.</div>`; 
        if (SW_CHART) { SW_CHART.destroy(); SW_CHART=null; }
        return true;
    }

    const effType = (chosen==="auto") ? (cols.length===1 ? "kpi" : "bar") : chosen;

    if (effType==="table"){
      if (SW_CHART) { SW_CHART.destroy(); SW_CHART=null; }
      host.innerHTML = `<div class="sw-hint">Tablo görünümü yukarıda.</div>`;
      return true;
    }
    if (cols.length===1 || effType==="kpi"){
      if (SW_CHART) { SW_CHART.destroy(); SW_CHART=null; }
      const c0 = cols[0].name;
      const v  = rows[0]?.[c0];
      host.innerHTML = `<div class="sw-kpi"><div class="val">${(v??"")}</div><div class="sw-hint">${c0}</div></div>`;
      return true;
    }

    const roles = computePreviewRoles(effType);
    if (!roles.dims?.length || !roles.measures?.length){
      if (SW_CHART) { SW_CHART.destroy(); SW_CHART=null; }
      host.innerHTML = `<div class="sw-hint">Grafik için en az 1 Dimension ve 1 Measure seç.</div>`;
      return true;
    }

    if (visibleWidth(host) < 60) return false;

    const xField = roles.dims[0].field;
    const yKeys  = roles.measures.map(m=>m.field);

    const labels = rows.map(r=> String(getVal(r,xField) ?? "") );
    let datasets = [];

    if (effType === 'pie'){
        const mk = yKeys[0];
        const data = rows.map(r=> toNumberLocaleAware(getVal(r,mk)) || 0 );
        datasets = [{ label: mk, data }];
      } else {
        datasets = yKeys.map(mk => ({
          label: mk,
          data: rows.map(r=> toNumberLocaleAware(getVal(r,mk)) || 0 )
        }));
      }
      drawChartJS(effType, labels, datasets);
      return true;
    }

    async function doPreview(){
      const badge = document.getElementById("previewBadge");
      const btn   = document.getElementById("btnPreview");

      setLoading(btn, true, "Çalışıyor…");
      try {
        badge.textContent = "Çalıştırılıyor...";

        // seçimleri koru
        SW_STATE.roles = collectRoles();
        const prevType = document.getElementById("chartType").value;

        const sql  = getSQL().trim();
        if(!sql){
          badge.textContent = "Hata";
          alert("SQL boş olamaz.");
          return;
        }

        const raw = await apiPreview(sql);
        const r = (typeof normalizePreviewResponse==="function") ? normalizePreviewResponse(raw) : raw;

        const ok = (r && r.success === true) || (r && r.success === undefined && raw && (raw.SUCCESS === true || raw.success === true));
        if(!ok){
          badge.textContent = "Hata";
          document.getElementById("tableHost").innerHTML = `<div class="sw-hint">Önizleme başarısız.</div>`;
          document.getElementById("chartHost").innerHTML = `<div class="sw-hint">Grafik oluşturulamadı.</div>`;
          return;
        }

        SW_STATE.columns = (r.columns||[]).map(c=>({name: c.name || c.NAME || c}));
        SW_STATE.rows    = r.rows || [];

        badge.textContent = `${r.rowCount ?? SW_STATE.rows.length} satır • ${(r.elapsedMs ?? r.elapsedms ?? 0)} ms • TOP 100`;

        renderTable();

        if (SW_STATE.columns.length >= 2){
          disableXYCharts(false);
          const xy = (prevType==='bar'||prevType==='line'||prevType==='pie');
          if (xy) {
            document.getElementById("chartType").value = prevType;
            document.getElementById("rolePanel").style.display = "block";
            setupRolePanel(true);
          } else {
            setChartType("bar");
            setupRolePanel(true);
          }
        } else {
          disableXYCharts(true);
          setChartType("kpi");
        }

        reflowThen(()=>{ 
          return renderChartPreview() && visibleWidth(document.getElementById("chartHost"))>50; 
        });

      } catch(err){
        console.error("doPreview error:", err);
        badge.textContent = "Hata";
        document.getElementById("tableHost").innerHTML = `<div class="sw-hint">Önizleme sırasında bir hata oluştu.</div>`;
        document.getElementById("chartHost").innerHTML = `<div class="sw-hint">Grafik oluşturulamadı.</div>`;
      } finally {
        setLoading(btn, false);
      }
    }

    async function doSave(){
      const btn = document.getElementById("btnSave");
      setLoading(btn, true, "Kaydediliyor…");
      try {
        const name = document.getElementById("wName").value.trim();
        const desc = document.getElementById("wDesc").value.trim();
        const sql  = getSQL().trim();  // <-- aynı şekilde
        if(!name || !sql){
          alert("Widget adı ve SQL zorunludur.");
          return;
        }

        let chartType = document.getElementById("chartType").value;
        if(chartType==="auto"){ chartType = (SW_STATE.columns.length<=1) ? "kpi" : "bar"; }

        let columns = {};
        if(chartType==="bar"||chartType==="line"||chartType==="pie"){
          columns = collectRoles();
          if(columns.dims.length<1 || columns.measures.length<1){
            alert("Seçilen grafik tipi için en az 1 dimension ve 1 measure gerekli.");
            return;
          }
          columns.chart = { type: chartType, x: columns.dims[0].field, y: columns.measures.map(m=>m.field) };
        }

        const opSel = document.getElementById("opSelect");
        const opFuseactions = Array.from(opSel.selectedOptions).map(o => o.value);

        const payload = {
          widgetId: SW_STATE.widgetId || 0,
          widgetName: name,
          description: desc || "SQL tabanlı özel widget",
          sqlQuery: sql,
          chartType: chartType,
          columns: columns,
          opFuseactions : opFuseactions
        };

        const r = await apiSave(payload);
        if(!isOk(r)){
          alert(r && r.message ? r.message : "Kaydedilemedi");
          return;
        }

        const wid = r.widgetID || r.widgetId || r.WIDGETID || r.WIDGETId || payload.widgetId;
        alert("Kaydedildi. Widget ID: " + wid);
        document.getElementById("sqlWidgetModal").style.display="none";

      } catch(err){
        console.error("doSave error:", err);
        alert("Kaydetme sırasında bir hata oluştu.");
      } finally {
        setLoading(btn, false);
      }
    }

    function rowsToCSV(){
      const cols = (SW_STATE.columns||[]).map(c=>c.name);
      const escape = (s)=> `"${String(s??"").replace(/"/g,'""')}"`;
      const header = cols.map(escape).join(',');
      const lines = (SW_STATE.rows||[]).map(r=> cols.map(c=>escape(getVal(r,c))).join(','));
      return [header, ...lines].join('\n');
    }
    function download(blob, filename){
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a'); a.href=url; a.download=filename; document.body.appendChild(a); a.click();
      setTimeout(()=>{ URL.revokeObjectURL(url); a.remove(); }, 200);
    }
    function exportCSV(){
      const csv = rowsToCSV();
      download(new Blob([csv],{type:"text/csv;charset=utf-8"}), "preview.csv");
    }
    async function copyCSV(){
      const csv = rowsToCSV();
      await navigator.clipboard.writeText(csv);
      const badge = document.getElementById('previewBadge'); if(badge) badge.textContent = "CSV kopyalandı";
    }
    function downloadPNG(){
      if (!SW_CHART){ alert("Önce grafik oluştur."); return; }
      const url = SW_CHART.toBase64Image();
      const a = document.createElement('a'); a.href = url; a.download = "widget.png"; a.click();
    }

    function beautifySQL(){
      const s = getSQL();
      setSQL(formatSQL(s));
      if (CM) CM.focus();
    }
    function minifySQL(){
      const s = getSQL();
      setSQL(s.replace(/\s+/g,' ').trim());
      if (CM) CM.focus();
    }
    // Naif ama iş gören formatter
    function formatSQL(sql){
      if(!sql) return sql;
      let s = sql;

      // büyük harf anahtar sözcükler
      const KW = ['SELECT','FROM','WHERE','GROUP BY','HAVING','ORDER BY','UNION ALL','UNION','LEFT JOIN','RIGHT JOIN','INNER JOIN','FULL JOIN','JOIN','ON','AND','OR'];
      KW.forEach(k=>{
        const re = new RegExp('\\b'+k.replace(' ','\\s+')+'\\b','gi');
        s = s.replace(re, k);
      });

      // satır başları
      s = s
        .replace(/\s+/g,' ') // normalize
        .replace(/\b(SELECT)\b/g, '\n$1')
        .replace(/\b(FROM|WHERE|GROUP BY|HAVING|ORDER BY|UNION ALL|UNION)\b/g, '\n$1')
        .replace(/\b(LEFT JOIN|RIGHT JOIN|INNER JOIN|FULL JOIN|JOIN)\b/g, '\n  $1')
        .replace(/\b(ON)\b/g, '\n    $1');

      // SELECT listesini satırlara böl (FROM'a kadar)
      s = s.replace(/SELECT\s+(.+?)\s+FROM/si, (m, cols)=> {
        const parts = cols.split(',').map(x=>x.trim()).filter(Boolean);
        return 'SELECT\n  ' + parts.join(',\n  ') + '\nFROM';
      });

      return s.trim().replace(/^\n+/,'');
    }

    /* ===== Reset ===== */
    function resetWizard(){
      SW_STATE = { widgetId:0, name:"",desc:"",sql:"", columns:[],rows:[], chartType:"auto", roles:{dims:[],measures:[],sort:[]} };
      document.getElementById("wName").value="";
      document.getElementById("wDesc").value="";
      setSQL("");
      document.getElementById("chartType").value="auto";
      document.getElementById("tableHost").innerHTML='<div class="sw-hint">“Test Et” ile önizleme alın.</div>';
      document.getElementById("chartHost").innerHTML='<div class="sw-hint">Grafik tipi ve roller uygun ise burada önizleme görünür.</div>';
      document.getElementById("previewBadge").textContent="Beklemede";
      const opSel = document.getElementById("opSelect");
      if (opSel) Array.from(opSel.options).forEach(o => o.selected = false);
    }

    /* ===== Roles normalize (for load) ===== */
    function normalizeLoadedRoles(loaded){
      if (!loaded) return { dims:[], measures:[], sort:[] };
      if (typeof loaded === "string"){
        try { loaded = JSON.parse(loaded); } catch(e){ return { dims:[], measures:[], sort:[] }; }
      }
      if (loaded.dims || loaded.measures){
        return {
          dims: Array.isArray(loaded.dims) ? loaded.dims : [],
          measures: Array.isArray(loaded.measures) ? loaded.measures : [],
          sort: Array.isArray(loaded.sort) ? loaded.sort : []
        };
      }
      if (Array.isArray(loaded)){
        const dim = loaded.find(x=> String(x.role).toLowerCase()==="dimension");
        const meas= loaded.filter(x=> String(x.role).toLowerCase()==="metric");
        const srt = loaded.find(x=> String(x.role).toLowerCase()==="sort");
        return {
          dims: dim ? [{field:dim.name, label:dim.name}] : [],
          measures: meas.map(m=>({field:m.name, agg:(m.agg||"SUM"), label:m.name})),
          sort: srt ? [{field:srt.name, dir:(srt.dir||"DESC")}] : []
        };
      }
      if (loaded.chart && (loaded.chart.x || loaded.chart.y)){
        const xs = loaded.chart.x ? [{field:loaded.chart.x, label:loaded.chart.x}] : [];
        const ysRaw = Array.isArray(loaded.chart.y) ? loaded.chart.y : (loaded.chart.y?[loaded.chart.y]:[]);
        const ys = ysRaw.map(y=>({field:y, agg:"SUM", label:y}));
        return { dims: xs, measures: ys, sort: loaded.sort || [] };
      }
      return { dims:[], measures:[], sort:[] };
    }
    document.addEventListener('keydown', (e)=>{
      const modal = document.getElementById('sqlWidgetModal');
      if (!modal || modal.style.display !== 'block') return;

      // ESC: kapat
      if (e.key === 'Escape'){ modal.style.display='none'; return; }

      // Ctrl/Cmd + Enter: Test
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter'){
        const btn = document.getElementById('btnPreview');
        if (btn && !btn.classList.contains('loading')) doPreview();
      }

      // Ctrl/Cmd + S: Kaydet
      if ((e.ctrlKey || e.metaKey) && (e.key.toLowerCase() === 's')){
        e.preventDefault();
        const btn = document.getElementById('btnSave');
        if (btn && !btn.classList.contains('loading')) doSave();
      }
    });
    function setLoading(btn, on, tempText){
      if(!btn) return;
      if(on){
        btn.dataset.text = btn.dataset.text || btn.textContent;
        if (tempText) btn.textContent = tempText;
        btn.classList.add('loading'); btn.disabled = true;
      } else {
        btn.classList.remove('loading'); btn.disabled = false;
        if (btn.dataset.text) btn.textContent = btn.dataset.text;
      }
    }
  </script>
</cfoutput>