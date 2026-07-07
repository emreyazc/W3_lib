<style>
    /* === Widget Builder Modal (scoped) === */
    #widgetBuilderRoot.wb-hidden { display:none }
    #widgetBuilderRoot.wb-backdrop {
        position:fixed; inset:0; background:rgba(0,0,0,.25);
        display:flex; align-items:center; justify-content:center; z-index:9999;
    }
    #widgetBuilderRoot .wb-modal {
        width:90%; max-height:90vh; overflow:auto; background:white;
        border-radius:14px; box-shadow:0 20px 60px rgba(0,0,0,.25);
    }
    #widgetBuilderRoot .wb-modal header {
        padding:12px 16px; border-bottom:1px solid rgb(229,231,235);
        display:flex; justify-content:space-between; align-items:center;
    }
    #widgetBuilderRoot .wb-title { font-weight:700 }
    #widgetBuilderRoot .wb-muted { color:rgb(107,114,128); font-size:12px }
    #widgetBuilderRoot .wb-content { padding:12px 16px }

    /* Common controls (scoped) */
    #widgetBuilderRoot .sw-card{border:1px solid rgb(233,236,239);border-radius:14px;background:white}
    #widgetBuilderRoot .sw-card>.hdr{padding:10px 12px;border-bottom:1px solid rgb(238,240,243);font-weight:600}
    #widgetBuilderRoot .sw-card>.body{padding:12px}
    #widgetBuilderRoot .sw-btn{cursor:pointer;padding:8px 12px;border:1px solid rgb(229,231,235);background:white;border-radius:8px}
    #widgetBuilderRoot .sw-btn.sw-primary{background:rgb(31,111,235);border-color:rgb(31,111,235);color:white}
    #widgetBuilderRoot .right{margin-left:auto}
    #widgetBuilderRoot .sw-table{width:100%;border-collapse:separate;border-spacing:0}
    #widgetBuilderRoot .sw-table th,#widgetBuilderRoot .sw-table td{padding:8px 10px;border-bottom:1px solid rgb(238,240,243);text-align:left;font-size:13px;white-space:nowrap;vertical-align:top}
    #widgetBuilderRoot .sw-table th{position:sticky;top:0;background:rgb(247,248,251);z-index:1}
    #widgetBuilderRoot .sw-chip{display:inline-block;padding:2px 8px;border:1px solid rgb(229,231,235);border-radius:999px;font-size:12px;background:white}
    #widgetBuilderRoot .toolbar{display:flex;gap:8px;align-items:center;margin-bottom:10px;flex-wrap:wrap}

    /* Pick Fields: stacked columns + scrolls */
    #widgetBuilderRoot #stepPickFields .pf-stack{display:flex; flex-direction:column; gap:14px; }
    #widgetBuilderRoot #pfCatalogHost,
    #widgetBuilderRoot #pfSelectedHost{max-height:360px; overflow:auto; border-top:1px solid rgb(238,240,243);}

    /* SQL + Results */
    #widgetBuilderRoot .sw-sqlbox summary{cursor:pointer; font-weight:600; margin-bottom:6px}
    #widgetBuilderRoot .wb-sql{background:rgb(11,16,32); color:rgb(230,237,243); padding:10px; border-radius:8px; overflow:auto; font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; font-size:12px}
    #widgetBuilderRoot .wb-reswrap{max-height:420px; overflow:auto; border:1px solid rgb(238,240,243); border-radius:10px}
    #wbChartHost { position: relative; }
    #wbChartHost > canvas { width: 100% !important; height: 100% !important; display:block; }
</style>

<script>
// --- Bootstrap: define a safe global stub early ---
window.EDIT = window.EDIT || { mode:'create', widgetId:null, loadedConfig:null };
window.__WB_QUEUE = window.__WB_QUEUE || [];
window.__WB_READY = false;
// Temporary stub: queue calls until real openWidgetBuilder is ready
window.openWidgetBuilder = async function(mode='create', widgetId=null){
  try{
    EDIT.mode = (mode === 'edit') ? 'edit' : 'create';
    EDIT.widgetId = (EDIT.mode==='edit') ? Number(widgetId) : null;
    const WR = document.getElementById('widgetBuilderRoot');
    if (WR){ WR.classList.remove('wb-hidden'); WR.style.display='flex'; }
    hide('stepSelectModel'); hide('stepModelLoaded'); hide('stepPickFields'); hide('stepPreview');
    if(window.wbUpdateStepHint) window.wbUpdateStepHint();
    if (EDIT.mode === 'create'){
      show('stepSelectModel'); if(window.wbUpdateStepHint) window.wbUpdateStepHint(); wbListModels && wbListModels();
    } else {
      await loadWidgetForEdit(EDIT.widgetId);
    }
  }catch(e){
    console.error('openWidgetBuilder error', e);
    alert('Wizard açılamadı: ' + (e.message||e));
  }
};
</script>

      
    <!-- MODAL -->
<div id="widgetBuilderRoot"
        class="wb-backdrop wb-hidden"
        style="display:none"
        role="dialog"
        aria-modal="true"
        aria-labelledby="wbTitle"
        data-list-url="/v16/add_options/report/api/semantic/models/list.cfm"
        data-get-url="/v16/add_options/report/api/semantic/models/get.cfm"
        data-run-url="/v16/add_options/report/api/semantic/models/run.cfm">
    
    <div class="wb-modal">
        <header>
        <div>
            <div id="wbTitle" class="wb-title">Widget Builder</div>
            <div class="wb-muted" id="wbStepHint">Adım 1/3</div>
        </div>
        <button class="sw-btn" onclick="closeWidgetBuilder()">Kapat ✕</button>
        </header>
    
        <div class="wb-content">
        <div class="sw-wrap" id="builderRoot">
            <!-- Step 1: Model Seç -->
            <div class="sw-card" id="stepSelectModel">
            <div class="hdr">Model Seç</div>
            <div class="body">
                <div class="toolbar">
                <input id="modelSearch" class="sw-btn" placeholder="Model ara..." style="flex:1" />
                <button id="btnRefresh" class="sw-btn">Yenile</button>
                </div>
                <div class="wb-muted" id="modelHint">Yayınlanmış modeller listelenir. Bir satıra çift tıklayarak ya da “Yükle” ile devam edebilirsiniz.</div>
                <div id="modelTableHost" style="margin-top:8px;max-height:420px;overflow:auto;border:1px solid rgb(238,240,243);border-radius:10px"></div>
            </div>
            </div>
    
            <!-- Step (Ara özet): Model Yüklendi -->
            <div class="sw-card" id="stepModelLoaded" style="display:none;margin-top:14px">
            <div class="hdr">Model Yüklendi</div>
            <div class="body" id="loadedSummary"></div>
            <div class="body" style="display:flex;gap:8px">
                <button class="sw-btn" id="btnBack" onclick="goBack()">← Geri</button>
                <span style="flex:1"></span>
                <button class="sw-btn sw-primary" id="btnNext" onclick="goNext()">Devam et</button>
            </div>
            </div>
    
            <!-- Step 2: Alan Seç / Filtre -->
            <div class="sw-card" id="stepPickFields" style="display:none; margin-top:14px">
            <div class="hdr">Alan Seç / Filtre</div>
            <div class="body">
                <!-- Toolbar -->
                <div class="toolbar">
                <select id="pfEntity" class="sw-btn" style="min-width:200px">
                    <option value="">Tüm varlıklar</option>
                </select>
                <select id="pfRole" class="sw-btn">
                    <option value="">Tüm roller</option>
                    <option value="dimension">Boyut</option>
                    <option value="measure">Ölçü</option>
                    <option value="date">Tarih</option>
                    <option value="id">Kimlik</option>
                </select>
                <input id="pfSearch" class="sw-btn" placeholder="Varlık/alan/etiket/tip içinde ara…" style="flex:1; min-width:200px" />
                </div>
    
                <!-- Alt alta iki kutu -->
                <div class="pf-stack">
                    <!-- Sol: Varlık Kataloğu -->
                    <div class="sw-card" style="border:none">
                        <div class="hdr">Varlık Kataloğu</div>
                        <div class="body" style="padding:0">
                            <div id="pfCatalogHost"></div>
                        </div>
                    </div>
                    <!-- Sağ: Seçilen Alanlar -->
                    <div class="sw-card" style="border:none">
                        <div class="hdr">Seçilen Alanlar</div>
                        <div class="body" style="padding:0">
                            <div id="pfSelectedHost"></div>
                        </div>
                    </div>
                </div>
                <!-- Filtreler -->
                <div class="sw-card" style="margin-top:14px">
                    <div class="hdr">Filtreler (WHERE)</div>
                    <div class="body" style="padding-top:8px">
                        <div id="pfFiltersHost"></div>
                        <div style="margin-top:8px">
                        <button class="sw-btn" onclick="pfAddFilter()">+ Filtre Ekle</button>
                        </div>
                    </div>
                </div>
                <div class="sw-card" style="margin-top:14px">
                    <div class="hdr">Toplama Sonrası Filtre (HAVING)</div>
                    <div class="body" id="pfHavingHost"></div>
                </div>  
            </div>
                <div class="body" style="display:flex; gap:8px">
                    <button class="sw-btn" onclick="goBackToSummary()">← Geri</button>
                    <span style="flex:1"></span>
                    <button class="sw-btn" onclick="pfClear()">Temizle</button>
                    <button class="sw-btn sw-primary" onclick="pfConfirm()">Devam et</button>
                </div>
            </div>
    
            <!-- Step 3: Önizleme & Görselleştirme -->
            <div class="sw-card" id="stepPreview" style="display:none; margin-top:14px">
                <div class="hdr">Önizleme &amp; Görselleştirme</div>
                <div class="body">
                    <!-- Üst toolbar -->
                    <div class="toolbar" style="align-items:flex-end">
                        <div style="display:flex;gap:8px;flex-wrap:wrap">
                            <label>Görünüm</label>
                            <select id="pvChartType" class="sw-btn">
                                <option value="bar">📊 Bar</option>
                                <option value="line">📈 Line</option>
                                <option value="pie">🥧 Pie</option>
                                <option value="doughnut">🍩 Doughnut</option>
                                <option value="polarArea">🎯 Polar Area</option>
                                <option value="radar">📡 Radar</option>
                                <option value="bubble">🫧 Bubble</option>
                                <option value="scatter">📍 Scatter</option>
                                <option value="area">📉 Area</option>
                            </select>
                        </div>
                        <div style="display:flex;gap:8px;flex-wrap:wrap">
                            <label>X Ekseni</label>
                            <select id="pvX" class="sw-btn" disabled></select>
                        </div>
                        <div style="display:flex;gap:8px;flex-wrap:wrap">
                            <label>Y Serileri</label>
                            <select id="pvY" class="sw-btn" multiple size="3" style="min-width:180px" disabled></select>
                        </div>
                        <!-- Sıralama kontrolleri dinamik eklenecek -->
                        <div style="display:flex;gap:8px;flex-wrap:wrap">
                            <label>Boyut</label>
                            <input id="pvW" class="sw-btn" type="number" min="100" value="500" style="width:90px" title="Genişlik (px)">
                            <input id="pvH" class="sw-btn" type="number" min="50" value="250" style="width:90px" title="Yükseklik (px)">
                            <label class="sw-btn" style="display:flex;gap:6px;align-items:center">
                            <input id="pvFit" type="checkbox">
                            Sığdır (genişlik %100)
                            </label>
                        </div>
                        <div id="vizOpts" class="toolbar" style="gap:8px;flex-wrap:wrap;margin-top:6px">
                            <label><input type="checkbox" id="voLegend" checked> Legend</label>
                            <label><input type="checkbox" id="voStacked"> Stacked</label>
                            <label><input type="checkbox" id="voFill"> Fill (Area)</label>
                            <input id="voTitle" class="sw-btn" placeholder="Grafik başlığı" style="min-width:220px">
                            <input id="voXLabel" class="sw-btn" placeholder="X etiketi" style="min-width:160px">
                            <input id="voYLabel" class="sw-btn" placeholder="Y etiketi" style="min-width:160px">
                        </div>
                        <div style="display:flex;gap:8px;flex-wrap:wrap;margin-left:auto">
                            <label>Limit</label>
                            <input id="pvLimit" class="sw-btn" type="number" min="1" value="50" style="width:90px">
                            <button id="pvRunBtn" class="sw-btn sw-primary">Çalıştır</button>
                            <button id="pvCsvBtn" class="sw-btn">CSV</button>
                        </div>
                        <label style="display:flex;gap:6px;align-items:center">
                            İşlem:
                            <select id="liveOps" class="sw-btn" multiple size="5" style="min-width:260px">
                              <option value=""                        data-placeholder="1">(Seçiniz)</option>
                              <option value="sales.list_offer"        data-label="Satış Teklifleri">Satış Teklifleri</option>
                              <option value="sales.list_order"        data-label="Satış Siparişleri">Satış Siparişleri</option>
                              <option value="purchase.list_order"     data-label="Satınalma Siparişleri">Satınalma Siparişleri</option>
                              <option value="invoice.form_add_bill"   data-label="Satış Faturası">Satış Faturası</option>
                              <option value="project.projects"        data-label="Proje Yönetimi">Proje Yönetimi</option>
                            </select>
                          </label>              
                    </div>
                
                    <!-- SQL -->
                    <details class="sw-sqlbox" open>
                        <summary>Oluşan SQL’i göster/gizle</summary>
                        <pre id="wbSql" class="wb-sql"></pre>
                    </details>
                
                    <!-- Sonuçlar -->
                    <div class="wb-reswrap" style="margin-top:8px">
                        <div id="wbResultHost"><div class="wb-muted" style="padding:10px">Henüz sorgu çalıştırılmadı.</div></div>
                    </div>
                
                    <!-- Grafik --><!-- YENİ -->
                    <div class="wb-chartbox" style="margin-top:10px">
                        <div id="wbChartHost" style="width:100%;height:360px">
                        <canvas id="wbChartCanvas"></canvas>
                        </div>
                    </div>
                </div>
                <div class="wb-reswrap" style="margin-top:8px">
                    <div id="wbMeta" class="toolbar" style="gap:8px;flex-wrap:wrap;margin-top:6px">
                        <input id="wmTitle" class="sw-btn" placeholder="Widget başlığı" style="min-width:240px">
                        <input id="wmDesc"  class="sw-btn" placeholder="Açıklama (ops.)" style="min-width:300px">
                        <input id="wmIcon"  class="sw-btn" placeholder="İkon (ör: bar-chart)" style="min-width:160px">
                    </div>
                </div>
                <div class="body" style="display:flex;gap:8px">
                    <button class="sw-btn" onclick="goBackToPick()">← Geri</button>
                    <span style="flex:1"></span>
                    <button class="sw-btn sw-primary" onclick="finalizeWidget()">Kaydet / Widget’e Dön</button>
                </div>
            </div>  
        </div>
        <!-- /builderRoot -->
        </div>
    </div>
</div>
      
<script>
    const SCHEMA_VERSION = '1.0';
    (function(){
    // ===== Root & API =====
    const WR = document.getElementById('widgetBuilderRoot');
    if(!WR){ console.warn('widgetBuilderRoot bulunamadı'); return; }
    const BR = document.getElementById('builderRoot');
    
    const API = {
        list: WR.dataset.listUrl || '/v16/add_options/report/api/semantic/models/list.cfm',
        get : WR.dataset.getUrl  || '/v16/add_options/report/api/semantic/models/get.cfm',
        run : WR.dataset.runUrl  || '/v16/add_options/report/api/semantic/models/run.cfm'
    };
    
    // ===== Global State =====
    window.BLD = window.BLD || {
        selected : null,     // { modelUid, version, state }
        modelJson: null
    };
    window.PF = window.PF || {
        model   : null,
        selected: [],        // [{entity, field, role, agg, dtype, alias}]
        filters : []         // [{key, op, value, conj}]
    };
    let LAST_ROWS = Array.isArray(window.LAST_ROWS) ? window.LAST_ROWS : [];
    window.LAST_ROWS = LAST_ROWS;
    
    // ===== Utils =====
    const $ = (id)=> document.getElementById(id);
    const escapeHtml = (s)=> String(s ?? '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
        .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    const debounce = (fn,ms=250)=>{let t;return(...a)=>{clearTimeout(t);t=setTimeout(()=>fn(...a),ms);};};
    const lowerKeys = (o)=>Object.fromEntries(Object.entries(o||{}).map(([k,v])=>[String(k||'').toLowerCase(),v]));

    function getSelectValues(id){
        const el = document.getElementById(id);
        if (!el) return [];
        const opts = el.selectedOptions
            ? Array.from(el.selectedOptions)
            : Array.from(el.options || []).filter(o => o.selected);
        return opts.map(o => o.value).filter(Boolean);
    }

    function wbUpdateStepHint(){
        const hint = $('wbStepHint'); if(!hint) return;
        const s1 = getComputedStyle($('stepSelectModel')).display!=='none';
        const s2 = getComputedStyle($('stepModelLoaded')).display!=='none' || getComputedStyle($('stepPickFields')).display!=='none';
        const s3 = getComputedStyle($('stepPreview')).display!=='none';
        const n  = s1 ? 1 : (s2 ? 2 : 3);
        hint.textContent = `Adım ${n}/3`;
    }
    function show(el){
        if (typeof el === 'string') el = document.getElementById(el);
        if (!el) { console.warn('show(): element not found'); return; }
        el.style.display = 'block';
    }

    function hide(el){
        if (typeof el === 'string') el = document.getElementById(el);
        if (!el) { console.warn('hide(): element not found'); return; }
        el.style.display = 'none';
    }

    window.EDIT = window.EDIT || { mode:'create', widgetId:null, loadedConfig:null };
    // ===== Modal Open/Close (HTML onclick çağırıyor) =====
    window.openWidgetBuilder = async function(mode='create', widgetId=null){
        EDIT.mode = (mode === 'edit') ? 'edit' : 'create';
        EDIT.widgetId = (EDIT.mode==='edit') ? Number(widgetId) : null;

        WR.classList.remove('wb-hidden');
        WR.style.display='flex';

        // hepsini kapat, sonra hedef adımı göstereceğiz
        wbHide('stepSelectModel');
        wbHide('stepModelLoaded');
        wbHide('stepPickFields');
        wbHide('stepPreview');
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();

        if (EDIT.mode === 'create'){
            // create: klasik akış
            wbShow('stepSelectModel');
            if(window.wbUpdateStepHint) window.wbUpdateStepHint();
            wbListModels?.();
        } else {
            // edit: widget'ı çek + modeli yükle + Step-2'yi kur
            await loadWidgetForEdit(EDIT.widgetId);
        }
    };

    window.closeWidgetBuilder = function(){
        const WR = document.getElementById('widgetBuilderRoot');
        if(WR){ WR.classList.add('wb-hidden'); WR.style.display='none'; }
        removePreviewSortControls();     // modal kapanırken de temizle
    };

    // ===== Step 1: Model Listele / Yükle =====
    async function listModels(){
        const host = $('modelTableHost');
        if(host) host.innerHTML = `<div class="wb-muted" style="padding:10px">Yükleniyor...</div>`;
        try{
        const r = await fetch(API.list, {method:'GET', headers:{'Accept':'application/json; charset=utf-8'}});
        const raw = await r.json().catch(()=> ({}));
        const ok  = !!(raw.SUCCESS===true || raw.success===true);
        const items = raw.ITEMS || raw.items || [];
        if(!ok || !Array.isArray(items) || !items.length){
            host.innerHTML = `<div class="wb-muted" style="padding:10px">Sonuç yok.</div>`;
            return;
        }
        let rows = items.map(it=>{
            const x = lowerKeys(it);
            return {
            modelUid:   x.modeluid || x.model_uid || '',
            name:       x.name || '',
            dsn:        x.dsn || '',
            status:     (x.status||'').toLowerCase(),
            version:    x.currentversion || x.current_version || null,
            recordDate: x.recorddate || x.created_at || '',
            updateDate: x.updatedate || x.updated_at || ''
            };
        }).filter(r=>r.status==='published');
    
        renderModelTable(rows);
        }catch(e){
        host.innerHTML = `<div class="wb-muted" style="padding:10px;color:#b91c1c">Hata: ${escapeHtml(e.message||e)}</div>`;
        }
    }
    
    function renderModelTable(rows){
        const host = $('modelTableHost');
        const q = ($('modelSearch')?.value||'').toLowerCase();
        const list = q ? rows.filter(r=>(r.name||'').toLowerCase().includes(q)) : rows;
        if(!list.length){ host.innerHTML = `<div class="wb-muted" style="padding:10px">Sonuç yok.</div>`; return; }
    
        let html = `<table class="sw-table"><thead><tr>
        <th>Model</th><th>Veri Kaynağı</th><th>Durum</th><th>Versiyon</th><th>Kayıt</th><th>Güncelleme</th><th></th>
        </tr></thead><tbody>`;
        list.forEach(r=>{
        html += `<tr data-uid="${escapeHtml(r.modelUid)}" data-ver="${escapeHtml(r.version||'published')}" style="cursor:pointer">
            <td>${escapeHtml(r.name)}</td>
            <td>${escapeHtml(r.dsn)}</td>
            <td>${escapeHtml(r.status)}</td>
            <td>${escapeHtml(r.version)}</td>
            <td>${escapeHtml(r.recordDate)}</td>
            <td>${escapeHtml(r.updateDate)}</td>
            <td><button class="sw-btn" data-load="${escapeHtml(r.modelUid)}" data-version="${escapeHtml(r.version||'published')}">Yükle</button></td>
        </tr>`;
        });
        html += `</tbody></table>`;
        host.innerHTML = html;
    
        host.querySelectorAll('tbody tr').forEach(tr=>{
        tr.addEventListener('dblclick', ()=>{
            loadModel(tr.getAttribute('data-uid'), tr.getAttribute('data-ver'));
        });
        });
        host.querySelectorAll('button[data-load]').forEach(btn=>{
        btn.addEventListener('click', ()=>{
            loadModel(btn.getAttribute('data-load'), btn.getAttribute('data-version'));
        });
        });
    }
    
    async function loadModel(modelUid, version){
        try{
        if(!modelUid){ alert('modelUid boş geldi (UI tarafında bağlama sorunu).'); return; }
        const ver = version || 'published';
    
        // 1) JSON denemesi
        const payload = { modelUid, MODELUID: modelUid, version: ver, VERSION: ver };
        let r = await fetch(API.get, {
            method:'POST',
            headers:{'Content-Type':'application/json;charset=utf-8','Accept':'application/json;charset=utf-8'},
            body: JSON.stringify(payload)
        });
        let raw = await r.json().catch(()=> ({}));
    
        // 2) Validation ise form-encoded fallback
        const ok = (raw && (raw.SUCCESS===true || raw.success===true));
        const needFallback = !ok && raw && (raw.CODE==='VALIDATION' || raw.code==='VALIDATION' || /modelUid/i.test(String(raw.MESSAGE||'')));
        if(needFallback){
            const fd = new URLSearchParams();
            fd.set('modelUid', modelUid);
            fd.set('version', ver);
            r = await fetch(API.get, { method:'POST', headers:{'Accept':'application/json;charset=utf-8'}, body: fd });
            raw = await r.json().catch(()=> ({}));
        }
    
        // 3) Son kontrol
        const success = raw && (raw.SUCCESS===true || raw.success===true);
        const MODEL   = raw.MODEL || raw.model || null;
        if(!success || !MODEL){
            console.debug('get.cfm response =>', raw);
            alert('Model yüklenemedi: ' + (raw.MESSAGE||raw.message||''));
            return;
        }
    
        // 4) State ayarla ve özet adımına geç
        BLD.selected  = { modelUid, version:(raw.VERSION||raw.version||ver), state:(raw.STATE||raw.state||'published') };
        BLD.modelJson = MODEL;
    
        hide($('stepSelectModel')); show($('stepModelLoaded')); hide($('stepPickFields')); hide($('stepPreview'));
        fillLoadedSummary(MODEL, BLD.selected);
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
        }catch(e){
        alert('Hata: ' + (e.message||e));
        }
    }
    
    function fillLoadedSummary(model, sel){
        const host = $('loadedSummary');
        const ents = (model.entities||[]).length;
        const rels = (model.relations||[]).length;
        const ver  = String(sel?.version ?? '');
        const state= (sel?.state || '').toLowerCase();
        const stateChip = state ? `<span class="sw-chip">${escapeHtml(state)}</span>` : '';
    
        host.innerHTML = `
        <div style="overflow:auto;border:1px solid rgb(238,240,243);border-radius:10px">
            <table class="sw-table">
            <thead>
                <tr><th>Model</th><th>Versiyon</th><th>Veri Kaynağı</th><th>Varlık</th><th>İlişki</th></tr>
            </thead>
            <tbody>
                <tr>
                <td>${escapeHtml(model.name||'')}</td>
                <td>${escapeHtml(ver)} ${stateChip}</td>
                <td>${escapeHtml(model.dsn||'')}</td>
                <td>${ents}</td>
                <td>${rels}</td>
                </tr>
            </tbody>
            </table>
        </div>`;
    }
    
    // Geri / İleri (özet)
    window.goBack = function(){
        show($('stepSelectModel')); hide($('stepModelLoaded')); hide($('stepPickFields')); hide($('stepPreview'));
        removePreviewSortControls();     // daha da geri giderken de temizle
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
    };
    // orijinal goNext sonunda Step-2'yi açıyordu; şimdi Step-3'e geçiyor
    window.goNext = function(){
    if(!BLD.modelJson){ alert('Önce model yükleyin.'); return; }

    // mevcut
    initPickFields(BLD.modelJson);
    wbHide('stepModelLoaded');
    wbHide('stepSelectModel');
    wbHide('stepPickFields');
    wbShow('stepPreview');
    wbEnsurePreviewSortControls();
    wbRefreshSortOptions();
    if(window.wbUpdateStepHint) window.wbUpdateStepHint();

    // ✳️ Edit moduysa kaydedilmiş Step-3 ayarlarını uygula
    if(EDIT.mode === 'edit' && EDIT.loadedConfig){
        window.applySavedPreview || applySavedPreview(EDIT.loadedConfig); // AŞAĞIDA
    }
    };
    
    // ===== Step 2: Alan Seç / Filtre =====
    function initPickFields(model){
        window.PF = { model, selected: [], filters: [], having: []};
        renderPickToolbar(model);
        renderCatalog();
        renderSelected();
        renderFilterBox();
        renderHavingBox(); 
        renderHavingList();
    }

    function applySavedPreview(raw){
        const C   = raw?.config || {};
        const cfg = (C.cfg && typeof C.cfg==='object') ? C.cfg : C;
        const viz = C.viz || {};

        // chart tipi
        if (viz.chartType) $('pvChartType').value = viz.chartType;

        // orderBy & limit
        wbEnsurePreviewSortControls();
        wbRefreshSortOptions();
        if (cfg.orderBy?.column){
            $('pvOrderBy').value = cfg.orderBy.column;
            $('pvOrderDir').value = (cfg.orderBy.dir || 'ASC').toUpperCase()==='DESC' ? 'DESC' : 'ASC';
        }
        if (cfg.limit != null) $('pvLimit').value = cfg.limit;

        // X/Y mapping — satırlar yokken PF.selected'tan doldurup,
        // sonra kaydedilmiş viz'i override edelim
        wbUpdateMappingOptions([]); 
        wbPrefillMappingFromSelection();
        if (viz.x && $('pvX')){
            $('pvX').innerHTML = `<option value="${viz.x}">${viz.x}</option>`;
            $('pvX').disabled = false; $('pvX').value = viz.x;
        }
        if (Array.isArray(viz.y) && viz.y.length && $('pvY')){
            $('pvY').innerHTML = viz.y.map(v=>`<option value="${v}" selected>${v}</option>`).join('');
            $('pvY').disabled = false;
        }

        // viz options
        const vo = C.vizOptions || cfg._vizOptions || {};
        $('voLegend').checked = !!(vo.legend ?? true);
        $('voStacked').checked = !!vo.stacked;
        $('voFill').checked    = !!vo.fill;
        $('voTitle').value     = vo.title  || '';
        $('voXLabel').value    = vo.xLabel || '';
        $('voYLabel').value    = vo.yLabel || '';
    }

    // HAVING kutusu
    function renderHavingBox(){
        const host = $('pfHavingHost');
        // Sadece seçilmiş alanlardan seçenek üret (agg != 'none' olanlar + grup kolonları)
        const opts = (PF.selected||[]).map((s, i) => {
            const tag = (String(s.agg||'none')==='none') ? 'Grup' : ('Toplama: '+aggLabel(s.agg));
            return { i, entity:s.entity, field:s.field, agg:(s.agg||'none'), label:`${s.alias||s.field} — ${tag}` };
        });

        const keyHtml = opts.map(o => 
            `<option value="${o.i}">${escapeHtml(o.label)}</option>`
        ).join('');

        host.innerHTML = `
            <div class="toolbar" style="gap:8px;flex-wrap:wrap">
            <select id="hvKey" class="sw-btn" style="min-width:260px">${keyHtml}</select>
            <select id="hvOp" class="sw-btn">
                <option>=</option><option>!=</option>
                <option>&gt;</option><option>&gt;=</option>
                <option>&lt;</option><option>&lt;=</option>
                <option>IN</option><option>BETWEEN</option>
                <option>LIKE</option>
            </select>
            <input id="hvVal" class="sw-btn" placeholder="Değer (IN: a,b,c  /  BETWEEN: a,b)" style="min-width:260px">
            <select id="hvConj" class="sw-btn"><option>AND</option><option>OR</option></select>
            <button class="sw-btn" onclick="pfAddHaving()">+ Ekle</button>
            </div>
            <div id="pfHavingList" style="margin-top:8px"></div>
        `;
        refreshHavingOptions();
        renderHavingList(); // varsa zaten çağırıyorsanız tekrar gerekmez
    }

    function refreshHavingOptions(){
        const sel = $('hvKey');
        if(!sel) return;

        // PF.selected içinden sadece agg != 'none' olanları al
        const onlyAgg = (PF.selected || [])
            .map((s,i)=> ({...s, _idx:i}))        // PF.selected indeksini koru
            .filter(s => s.agg && s.agg !== 'none');

        if (!onlyAgg.length){
            sel.innerHTML = '';
            sel.disabled = true;
            return;
        }

        sel.disabled = false;
        sel.innerHTML = onlyAgg.map(s=>{
            const lbl = `${s.alias || s.field} — ${aggLabel(s.agg)}`;
            return `<option value="${s._idx}">${escapeHtml(lbl)}</option>`;
        }).join('');
    }

    window.pfAddHaving = function(){
        const keyIdx = parseInt($('hvKey').value,10);
        const op  = $('hvOp').value;
        const val = $('hvVal').value || '';
        const conj= $('hvConj').value || 'AND';

        const sel = PF.selected || [];
        if (isNaN(keyIdx) || !sel[keyIdx]) { alert('Geçerli bir alan seçin.'); return; }
        const k = sel[keyIdx];

        // HAVING maddesi: entity/field/agg + op/value/conj
        (PF.having ||= []).push({
            entity: k.entity, field: k.field, agg: (k.agg||'none'),
            op, value: val, conj
        });
        $('hvVal').value = '';
        renderHavingList();
    };

    function renderHavingList(){
        const host = $('pfHavingList');
        const arr = PF.having || [];
        if(!arr.length){ host.innerHTML = `<div class="wb-muted">HAVING yok.</div>`; return; }
        let html = `<table class="sw-table"><thead><tr>
            <th></th><th>Alan</th><th>Hesaplama</th><th>Operatör</th><th>Değer</th><th>Birleştir</th>
        </tr></thead><tbody>`;
        arr.forEach((h,i)=>{
            const lblAgg = aggLabel(h.agg||'none');
            html += `<tr>
            <td><button class="sw-btn" data-del="${i}">×</button></td>
            <td>${escapeHtml(h.entity)}.${escapeHtml(h.field)}</td>
            <td>${escapeHtml(lblAgg)}</td>
            <td>${escapeHtml(h.op)}</td>
            <td>${escapeHtml(h.value)}</td>
            <td>${escapeHtml(h.conj||'AND')}</td>
            </tr>`;
        });
        html += `</tbody></table>`;
        host.innerHTML = html;
        host.querySelectorAll('button[data-del]').forEach(b=>{
            b.addEventListener('click', ()=>{
            const i = parseInt(b.getAttribute('data-del'),10);
            if(!isNaN(i)){ PF.having.splice(i,1); renderHavingList(); }
            });
        });
    }

    function renderPickToolbar(model){
        const entSel = $('pfEntity');
        const roleSel = $('pfRole');
        const qInput  = $('pfSearch');
    
        // varlık seçenekleri
        entSel.innerHTML = `<option value="">Tüm varlıklar</option>` + (model.entities||[])
        .map(e => {
            const a = e.alias || e.table;
            return `<option value="${escapeHtml(a)}">${escapeHtml(a)}</option>`;
        }).join('');
    
        entSel.value = ''; roleSel.value = ''; qInput.value = '';
    
        // olaylar
        entSel.addEventListener('change', renderCatalog);
        roleSel.addEventListener('change', renderCatalog);
        qInput.addEventListener('input', debounce(()=>renderCatalog(), 200));
    
        renderCatalog();
    }
    
    function renderCatalog(){
        const host = $('pfCatalogHost');
        const ents = (BLD.modelJson?.entities || []);
    
        const entFilter = ($('pfEntity')?.value || '').trim();
        const roleFilter= ($('pfRole')?.value || '').trim();
        const q         = ($('pfSearch')?.value || '').trim().toLowerCase();
        const tokens    = q ? q.split(/\s+/) : [];
    
        let rows = [];
        ents.forEach(ent=>{
        const entityName = ent.alias || ent.table;
        if (entFilter && entityName !== entFilter) return;
    
        (ent.fields||[]).forEach(f=>{
            if (roleFilter && (f.role||'') !== roleFilter) return;
    
            const hay = [
            entityName, f.name||'', f.label||'', f.alias||'',
            f.desc||'', f.dataType||'', f.category||'',
            f.aggDefault||''
            ].join(' ').toLowerCase();
    
            const ok = !tokens.length || tokens.every(t => hay.includes(t));
            if(!ok) return;
    
            rows.push({ entityName, f });
        });
        });
    
        if(!rows.length){
        host.innerHTML = `<div class="wb-muted" style="padding:10px">Sonuç yok.</div>`;
        return;
        }
    
        // tablo
        let html = `<table class="sw-table"><thead><tr>
        <th>Varlık</th><th>Alan</th><th>Rol</th><th>Öntanımlı</th><th></th>
        </tr></thead><tbody>`;
        rows.forEach(r=>{
        html += `<tr>
            <td>${escapeHtml(r.entityName)}</td>
            <td>${escapeHtml(r.f.name)}</td>
            <td>${escapeHtml(r.f.role||'')}</td>
            <td>${escapeHtml(r.f.aggDefault||'')}</td>
            <td><button class="sw-btn" data-add="${escapeHtml(r.entityName)}::${escapeHtml(r.f.name)}">+ Ekle</button></td>
        </tr>`;
        });
        html += `</tbody></table>`;
        host.innerHTML = html;
    
        // ekle
        host.querySelectorAll('button[data-add]').forEach(btn=>{
        btn.addEventListener('click', ()=>{
            const [entityName, fieldName] = btn.getAttribute('data-add').split('::');
            const ent = (BLD.modelJson.entities||[]).find(e => (e.alias||e.table) === entityName);
            const f   = (ent?.fields||[]).find(ff => ff.name === fieldName);
            if(!ent || !f) return;
    
            (PF.selected ||= []).push({
            entity: entityName,
            field:  f.name,
            role:   f.role,
            agg:    f.aggDefault || 'none',
            dtype:  f.dataType,
            alias:  f.label || f.alias || f.name
            });
            if (typeof refreshHavingOptions === 'function') 
            refreshHavingOptions();
            renderSelected();
            refreshSortOptions();
        });
        });
    }

    // Modelden alan metası bulucu (varsa)
    function findFieldMeta(entityName, fieldName){
        const m = (window.BLD?.modelJson) || {};
        const ent = (m.entities||[]).find(e => (e.alias||e.table) === entityName);
        return (ent?.fields||[]).find(f => f.name === fieldName) || null;
    }
    // Seçenek üretici — count_distinct’i de ekliyoruz
    function aggOptionsFor(meta={}){
        const role = String(meta.role||'').toLowerCase();
        const dt   = String(meta.dataType||'');
        const numeric = isNumericType(dt);

        // Model “aggAllowed” veriyorsa onu baz al; yoksa mantıklı default set
        let base = (meta.aggAllowed && meta.aggAllowed.length)
            ? meta.aggAllowed.map(x=>String(x).toLowerCase())
            : (numeric || role==='measure'
                ? ['none','sum','avg','min','max','count','count_distinct']
                : ['none','count','count_distinct']);

        // Tarihlerde toplama yapmayalım
        if (isDateType(dt)) {
            base = ['none','count','count_distinct'];
        }

        // Tekrarsız, sıralı hale getir
        const order = ['none','sum','avg','min','max','count','count_distinct'];
        const set = Array.from(new Set(base));
        return order.filter(x => set.includes(x));
    }

    function isNumericType(dt=''){
        dt = String(dt).toLowerCase();
        return /int|bigint|smallint|tinyint|decimal|numeric|money|float|real|double/.test(dt);
    }
    function isDateType(dt=''){
        dt = String(dt).toLowerCase();
        return /date|time/.test(dt);
    }

    function aggLabel(a){
        const map = {
            none:'—', 
            sum:'Toplam', 
            avg:'Ortalama', 
            min:'Min', max:'Max',
            count:'Adet', 
            'count_distinct':'Farklı Adet'
        };
        return map[a] || a.toUpperCase();
    }

    // Varsayılan hesaplama
    function pickDefaultAgg(meta={}){
        const role = String(meta.role||'').toLowerCase();
        const dt   = String(meta.dataType||'');
        if (role==='measure' || isNumericType(dt)) return 'sum';
        // ölçü değilse varsayılan none kalsın; kullanıcı gerekirse count seçer
        return 'none';
    }
    
    window.renderSelected = function(){
        const host = $('pfSelectedHost');
        const arr = PF.selected || [];
        if(!arr.length){
            host.innerHTML = `<div class="wb-muted" style="padding:10px">Henüz alan seçilmedi.</div>`;
            return;
        }

        let html = `<table class="sw-table"><thead><tr>
            <th style="width:72px">Sıra</th>
            <th>Varlık</th>
            <th>Alan</th>
            <th>Görünen Ad</th>
            <th>Rol</th>
            <th>Hesaplama</th>
            <th style="width:80px">Kaldır</th>
            </tr></thead><tbody>`;

        arr.forEach((s,i)=>{
            if(!('alias' in s) || !s.alias) s.alias = s.field;

            // İzinli hesaplamaları meta’dan çıkar
            const meta = findFieldMeta(s.entity, s.field) || {};
            const opts = aggOptionsFor(meta);

            // Geçerli değilse varsayılan seç
            if(!s.agg || !opts.includes(s.agg)){
            s.agg = pickDefaultAgg(meta);
            }

            const selHtml = opts.map(a =>
            `<option value="${a}" ${a===s.agg?'selected':''}>${aggLabel(a)}</option>`
            ).join('');

            html += `<tr>
            <td>
                <div style="display:flex;gap:6px">
                <button class="sw-btn" ${i===0?'disabled':''} onclick="moveSel(${i},-1)">↑</button>
                <button class="sw-btn" ${i===arr.length-1?'disabled':''} onclick="moveSel(${i},+1)">↓</button>
                </div>
            </td>
            <td>${escapeHtml(s.entity)}</td>
            <td>${escapeHtml(s.field)}</td>
            <td><input class="sw-btn sel-alias" data-idx="${i}" value="${escapeHtml(s.alias||s.field)}" style="min-width:160px"></td>
            <td>${escapeHtml(s.role||'')}</td>
            <td><select class="sw-btn sel-agg" data-idx="${i}">${selHtml}</select></td>
            <td><button class="sw-btn" onclick="removeSelected(${i})">×</button></td>
            </tr>`;
        });

        html += `</tbody></table>`;
        host.innerHTML = html;

        // alias değişimi
        host.querySelectorAll('.sel-alias').forEach(inp=>{
            inp.addEventListener('input', ()=>{
            const i = +inp.dataset.idx;
            PF.selected[i].alias = inp.value.trim();
            if (typeof refreshHavingOptions === 'function') 
            refreshHavingOptions();
            });
        });
        // agg değişimi
        host.querySelectorAll('.sel-agg').forEach(sel=>{
            sel.addEventListener('change', ()=>{
            const i = +sel.dataset.idx;
            PF.selected[i].agg = sel.value;
            if (typeof refreshHavingOptions === 'function') refreshHavingOptions();
            });
        });
        refreshHavingOptions();
    };

    
    // Sıralama / Kaldırma
    window.moveSel = function(i, delta){
        i = parseInt(i, 10);
        delta = parseInt(delta, 10) || 0;
        const arr = (window.PF.selected ||= []);
        const j = i + delta;
        if (i < 0 || i >= arr.length || j < 0 || j >= arr.length) return;
    
        const tmp = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
    
        renderSelected();
        refreshSortOptions();
        if (typeof refreshHavingOptions === 'function') refreshHavingOptions();
    };
    window.removeSelected = function(i){
        i = parseInt(i, 10);
        const arr = (window.PF.selected ||= []);
        if (i < 0 || i >= arr.length) return;
        arr.splice(i, 1);
        renderSelected();
        refreshSortOptions();
        if (typeof refreshHavingOptions === 'function') refreshHavingOptions();
    };
    
    function renderFilterBox(){
        const host = $('pfFiltersHost');
        const keyOptions = [];
        const m = PF?.model;
        if(m && Array.isArray(m.entities)){
            m.entities.forEach(e=>{
            const a = e.alias || e.table;
            (e.fields||[]).forEach(f=> keyOptions.push(`${a}.${f.name}`));
            });
        }
        host.innerHTML = `
            <div class="toolbar" style="gap:8px;flex-wrap:wrap">
            <select id="pfKey" class="sw-btn" style="min-width:220px">
                ${keyOptions.length ? keyOptions.map(k=>`<option>${escapeHtml(k)}</option>`).join('') : '<option value="">(alan yok)</option>'}
            </select>
            <select id="pfOp" class="sw-btn">
                <option>=</option><option>!=</option><option>&gt;</option><option>&gt;=</option>
                <option>&lt;</option><option>&lt;=</option><option>LIKE</option><option>IN</option><option>BETWEEN</option>
            </select>
            <input id="pfVal" class="sw-btn" placeholder="Değer (IN: a,b,c  /  BETWEEN: a,b)" style="min-width:260px">
            <select id="pfConj" class="sw-btn"><option>AND</option><option>OR</option></select>
            </div>
            <div id="pfList" style="margin-top:8px"></div>
        `;
        renderFilterList();
    }

    window.pfAddFilter = function(){
        const key = $('pfKey')?.value, op = $('pfOp')?.value, val = $('pfVal')?.value, conj = $('pfConj')?.value;
        if(!key || !op){ alert('Filtre anahtarı ve operatör gerekli.'); return; }
        (window.PF.filters ||= []).push({ key, op, value: (val||''), conj: (conj||'AND') });
        $('pfVal').value = '';
        renderFilterList();
    };
    function renderFilterList(){
        const host = $('pfList'); if(!host) return;
        if(!PF.filters.length){ host.innerHTML = `<div class="wb-muted">Filtre yok.</div>`; return; }
        let html = `<table class="sw-table"><thead><tr><th></th><th>Alan</th><th>Operatör</th><th>Değer</th><th>Birleştir</th></tr></thead><tbody>`;
        PF.filters.forEach((f,i)=>{
        html += `<tr>
            <td><button class="sw-btn" data-del="${i}">×</button></td>
            <td>${escapeHtml(f.key)}</td>
            <td>${escapeHtml(f.op)}</td>
            <td>${escapeHtml(f.value)}</td>
            <td>${escapeHtml(f.conj||'AND')}</td>
        </tr>`;
        });
        html += `</tbody></table>`;
        host.innerHTML = html;
        host.querySelectorAll('button[data-del]').forEach(b=>{
        b.addEventListener('click', ()=>{
            const idx = parseInt(b.getAttribute('data-del'),10);
            if(!isNaN(idx)){ PF.filters.splice(idx,1); renderFilterList(); }
        });
        });
    }
    
    window.goBackToSummary = function(){
        show($('stepModelLoaded')); hide($('stepPickFields')); hide($('stepPreview'));
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
    };
    window.pfClear = function(){
        window.PF.selected = [];
        window.PF.filters  = [];
        window.PF.having = [];
        renderSelected(); 
        renderFilterList();
        renderHavingList(); 
        renderCatalog();
    };
    
    // ===== Step 3: Önizleme / Çalıştırma / Grafik =====
    function ensurePreviewSortControls(){
        const bar = document.querySelector('#stepPreview .toolbar');
        if(!bar) return;

        // her girişte temizle -> tek kopya kalsın
        removePreviewSortControls();

        const wrap = document.createElement('div');
        wrap.setAttribute('data-sort-controls','1');
        wrap.style.display = 'flex';
        wrap.style.gap = '8px';
        wrap.style.flexWrap = 'wrap';

        const lbl = document.createElement('label');
        lbl.textContent = 'Sırala';

        const ob = document.createElement('select');
        ob.id = 'pvOrderBy';
        ob.className = 'sw-btn';
        ob.style.minWidth = '160px';

        const dir = document.createElement('select');
        dir.id = 'pvOrderDir';
        dir.className = 'sw-btn';
        dir.innerHTML = `<option value="ASC">Artan</option><option value="DESC">Azalan</option>`;

        wrap.appendChild(lbl);
        wrap.appendChild(ob);
        wrap.appendChild(dir);

        // “Limit/Çalıştır/CSV” grubundan önce ekle
        bar.insertBefore(wrap, bar.lastElementChild);
    }
    
    window.pfConfirm = function(){
        wbUpdateMappingOptions(LAST_ROWS)
        const anyAgg = (PF.selected||[]).some(s => (s.agg||'none')!=='none');
        if (!anyAgg && (PF.having||[]).length){
            alert('HAVING kullanmak için en az bir alanda hesaplama (SUM/COUNT vb.) seçmelisiniz.');
            return;
        }
        show($('stepPreview')); hide($('stepPickFields'));
        ensurePreviewSortControls();     // her girişte sıfırdan kur
        refreshSortOptions();            // ve taze kolon listesini yükle
        prefillMappingFromSelection();       // <-- eklendi
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
    };
    
    window.refreshSortOptions = function(rows){
        const ob = $('pvOrderBy');
        if(!ob) return;

        let cols = [];
        if (Array.isArray(rows) && rows.length){
            cols = Object.keys(rows[0] || {});
        } else {
            cols = (PF.selected || []).map(s => (s.alias && s.alias.trim()) ? s.alias.trim() : s.field);
        }

        // tekilleştir (sırayı koru)
        const seen = new Set();
        cols = cols.filter(c => {
            const k = String(c);
            if (seen.has(k)) return false;
            seen.add(k);
            return true;
        });

        const cur = ob.value;
        ob.innerHTML = `<option value="">—</option>` + cols.map(c => `<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join('');
        if (cols.includes(cur)) ob.value = cur; else ob.value = '';
    };

    function removePreviewSortControls(){
        const bar = document.querySelector('#stepPreview .toolbar');
        if(!bar) return;
        bar.querySelectorAll('[data-sort-controls]').forEach(n => n.remove());
    }
    
    function lowerResp(raw){
        const d = lowerKeys(raw||{});
        const succ = (d.success===true || String(d.success).toLowerCase()==='true' || raw.SUCCESS===true);
        let rows = d.rows || d.data || raw.ROWS || raw.DATA || [];
        if(!Array.isArray(rows)) rows = [];
        const sql = d.sql || raw.SQL || '';
        const msg = d.message || raw.MESSAGE || '';
        return { success:succ, rows, sql, message:msg };
    }
    
    function buildRunPayload(){
        const sel   = (window.BLD?.selected)  || {};
        const model = (window.BLD?.modelJson) || {};
    
        const ob = document.getElementById('pvOrderBy')?.value || '';
        const od = (document.getElementById('pvOrderDir')?.value || 'ASC').toUpperCase() === 'DESC' ? 'DESC' : 'ASC';
    
        const payload = 
        {
        modelRef: {
            modelUid: sel.modelUid || model.modelUid || '',
            version : sel.version  || 'latest'
        },
        dsn: model.dsn || sel.dsn || '',
        select: (window.PF?.selected || []).map(s => ({
            entity: s.entity, field: s.field, role: s.role,
            agg: s.agg, alias: (s.alias && s.alias.trim()) ? s.alias : s.field
        })),
        filters: Array.isArray(window.PF?.filters) ? window.PF.filters.slice(0) : [],
        having : window.PF?.having  || [],
        limit: parseInt(document.getElementById('pvLimit')?.value || '50', 10)
        };
    
        if (ob) payload.orderBy = { column: ob, dir: od };
        return payload;
    }
    
    async function runQuery(){
        const payload = buildRunPayload();
        const btn     = document.getElementById('pvRunBtn');
        const host    = document.getElementById('wbResultHost');
        const sqlBox  = document.getElementById('wbSql');

        const normalize = (raw)=>{
            try{ if (typeof lowerResp === 'function') return lowerResp(raw); }catch(_){}
            const d = (raw && typeof raw === 'object') ? raw : {};
            const success = !!(d.success === true || d.SUCCESS === true || String(d.success).toLowerCase() === 'true');
            let rows = d.rows || d.data || d.ROWS || d.DATA || [];
            if (!Array.isArray(rows)) rows = [];
            const sql = d.sql || d.SQL || '';
            const message = d.message || d.MESSAGE || '';
            return { success, rows, sql, message };
        };

        try {
            if (btn)  btn.disabled = true;
            if (host) host.innerHTML = '<div class="wb-muted" style="padding:10px">Çalıştırılıyor...</div>';
            if (sqlBox) sqlBox.textContent = '';

            const r   = await fetch(API.run, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify(payload)
            });
            const raw  = await r.json().catch(function(){ return {}; });
            const data = normalize(raw);

            if (sqlBox) sqlBox.textContent = (data.sql || '');

            if (!data.success){
            if (host) {
                var msg1 = 'Hata: ' + escapeHtml(data.message ? String(data.message) : 'Bilinmiyor');
                host.innerHTML = '<div class="wb-muted" style="padding:10px;color:#b91c1c">' + msg1 + '</div>';
            }
            window.LAST_ROWS = [];
            try { LAST_ROWS = window.LAST_ROWS; } catch (_){}
            if (typeof wbUpdateMappingOptions === 'function') wbUpdateMappingOptions([]);
            else if (typeof updateMappingOptions === 'function') updateMappingOptions([]);
            if (typeof drawChartJS === 'function') drawChartJS();
            return;
            }

            // Başarılı: satırları set et
            window.LAST_ROWS = Array.isArray(data.rows) ? data.rows : [];
            try { LAST_ROWS = window.LAST_ROWS; } catch (_){}

            // Sonuç tablosu
            if (typeof renderResultTable === 'function') {
            renderResultTable(window.LAST_ROWS);
            } else if (host){
            var rows = window.LAST_ROWS;
            if (!rows.length){
                host.innerHTML = '<div class="wb-muted" style="padding:10px">Sonuç yok.</div>';
            } else {
                var cols = Object.keys(rows[0]);
                var html = '<table class="sw-table"><thead><tr>' + cols.map(function(c){return '<th>'+escapeHtml(c)+'</th>';}).join('') + '</tr></thead><tbody>';
                rows.forEach(function(r){
                html += '<tr>' + cols.map(function(c){ return '<td title="'+escapeHtml(r[c])+'">'+escapeHtml(r[c])+'</td>'; }).join('') + '</tr>';
                });
                html += '</tbody></table>';
                host.innerHTML = html;
            }
            }

            // X/Y mapping + grafik
            if (typeof wbUpdateMappingOptions === 'function') wbUpdateMappingOptions(window.LAST_ROWS);
            else if (typeof updateMappingOptions === 'function') updateMappingOptions(window.LAST_ROWS);
            if (typeof drawChartJS === 'function') drawChartJS();

        } catch (e) {
            if (host) {
            var msg2 = 'Hata: ' + escapeHtml((e && e.message) ? String(e.message) : String(e));
            host.innerHTML = '<div class="wb-muted" style="padding:10px;color:#b91c1c">' + msg2 + '</div>';
            }
        } finally {
            if (btn) btn.disabled = false;
        }
    }

        window.__wbChart = window.__wbChart || null; // chart instance'ı globalde tut

        function drawChartJS(){
        const type   = (typeof getChartType === 'function') ? getChartType() : (document.getElementById('pvChartType')?.value || 'bar');
        const canvas = document.getElementById('wbChartCanvas');
        if (!canvas) return;

        // Tablo görünümünde grafik yok
        if (type === 'table'){
            if (window.__wbChart) { window.__wbChart.destroy(); window.__wbChart = null; }
            return;
        }

        const rows = Array.isArray(window.LAST_ROWS) ? window.LAST_ROWS : [];
        if (!rows.length){
            if (window.__wbChart) { window.__wbChart.destroy(); window.__wbChart = null; }
            return;
        }

        const xEl   = document.getElementById('pvX');
        const xKey  = (xEl && typeof xEl.value === 'string') ? xEl.value : '';

        // Emniyetli çoklu seçim okuma (selectedOptions yoksa options fallback)
        const yEl = document.getElementById('pvY');
        let yKeys = [];
        if (yEl){
            if (yEl.selectedOptions && typeof yEl.selectedOptions.length === 'number'){
            // Bazı tarayıcılarda spread çalışmaz; Array.from kullan
            yKeys = Array.from(yEl.selectedOptions).map(o => o.value).filter(Boolean);
            } else if (yEl.options) {
            yKeys = Array.from(yEl.options).filter(o => o.selected).map(o => o.value).filter(Boolean);
            }
        }

        if (!xKey || !Array.isArray(yKeys) || !yKeys.length){
            if (window.__wbChart) { window.__wbChart.destroy(); window.__wbChart = null; }
            return;
        }

        // Boyut ayarı ve çizim
        if (typeof applyChartBoxSize === 'function') applyChartBoxSize();

        if (typeof ensureChartJS === 'function'){
            ensureChartJS(() => {
            const cfg = (typeof buildChartConfig === 'function')
                ? buildChartConfig(type, rows, xKey, yKeys, (typeof getVizOptions==='function' ? getVizOptions() : {}))
                : { type: 'bar', data: { labels: [], datasets: [] }, options: {} };

            if (window.__wbChart) window.__wbChart.destroy();
            const ctx = canvas.getContext('2d');
            window.__wbChart = new Chart(ctx, cfg);
            });
        }
    }


    const typeEl = document.getElementById('pvChartType');
        typeEl?.addEventListener('change', () => {
        wbUpdateMappingOptions(window.LAST_ROWS || []); // tip değişince X/Y adaylarını yeniden kur
        drawChartJS();                   // yeni seçime göre grafiği çiz
    });
    //document.getElementById('pvChartType')?.addEventListener('change', drawChartJS);
    document.getElementById('pvX')?.addEventListener('change', drawChartJS);
    document.getElementById('pvY')?.addEventListener('change', drawChartJS);

    function inferFormat(rows, selected){
        const fmt = {};
        (selected||[]).forEach(s=>{
            const key = s.alias?.trim() || s.field;
            const dt  = (s.dtype||'').toLowerCase();
            if (/int|decimal|numeric|money|float|real|double/.test(dt)) {
            fmt[key] = { type:'number', decimals: 0 };
            } else if (/date|time/.test(dt)) {
            fmt[key] = { type:'date',   pattern: 'YYYY-MM-DD' };
            } else {
            fmt[key] = { type:'string' };
            }
        });
        // rows yoksa bile seçilenlerden türetir; istersen rows ile duyarlılığı artırabilirsin.
        return fmt;
    }

    
    function renderResultTable(rows){
        const host = $('wbResultHost');
        if(!rows.length){ host.innerHTML = `<div class="wb-muted" style="padding:10px">Sonuç yok.</div>`; return; }
        const cols = Object.keys(rows[0]);
        let html = `<table class="sw-table"><thead><tr>`;
        cols.forEach(c=> html += `<th>${escapeHtml(c)}</th>`);
        html += `</tr></thead><tbody>`;
        rows.forEach(r=>{
        html += `<tr>`;
        cols.forEach(c=> html += `<td title="${escapeHtml(r[c])}">${escapeHtml(r[c])}</td>`);
        html += `</tr>`;
        });
        html += `</tbody></table>`;
        host.innerHTML = html;
    }
    
    function isNumericColumn(rows, key){
        for(let i=0;i<Math.min(20, rows.length);i++){
        const v = rows[i][key];
        if(v===null || v===undefined || v==='') continue;
        if(typeof v==='number') return true;
        if(!isNaN(parseFloat(v)) && isFinite(v)) return true;
        return false;
        }
        return false;
    }

    function assertSelect(id){
        const el = document.getElementById(id);
        if(!(el instanceof HTMLSelectElement)){
            console.warn(id, 'beklenen HTMLSelectElement değil:', el);
            return null;
        }
        return el;
    }

    // mevcut isNumericColumn(rows, key) fonksiyonunu aynen kullanıyoruz
    function updateMappingOptions(rows){
        const xSel = document.getElementById('pvX');
        const ySel = document.getElementById('pvY');
        if (!xSel || !ySel) return;

        // Önceki seçimleri hatırla
        const prevX = xSel.value;
        const prevYs = (ySel.selectedOptions
            ? Array.from(ySel.selectedOptions)
            : Array.from(ySel.options || []).filter(o => o.selected)
        ).map(o => o.value);

        // Temizle
        xSel.innerHTML = '';
        ySel.innerHTML = '';

        const type = (document.getElementById('pvChartType')?.value || 'bar');
        const hasRows = Array.isArray(rows) && rows.length > 0 && type !== 'table';

        // Satır yoksa veya tablo görünümündeyse kapat
        if (!hasRows){
            xSel.disabled = true;
            ySel.disabled = true;
            return;
        }

        xSel.disabled = false;
        ySel.disabled = false;

        const cols = Object.keys(rows[0] || {});
        let xCands = [], yCands = [];

        if (type === 'scatter' || type === 'bubble'){
            // her iki eksen de numerik
            xCands = cols.filter(c => isNumericColumn(rows, c));
            yCands = cols.filter(c => isNumericColumn(rows, c));
        } else if (type === 'pie' || type === 'doughnut' || type === 'polarArea'){
            // label = kategorik X, değer = numerik Y
            xCands = cols.filter(c => !isNumericColumn(rows, c));
            yCands = cols.filter(c =>  isNumericColumn(rows, c));
        } else {
            // bar/line/radar/area: X kategorik, Y numerik
            xCands = cols.filter(c => !isNumericColumn(rows, c));
            yCands = cols.filter(c =>  isNumericColumn(rows, c));
        }

        if (!xCands.length) xCands = cols.slice();
        if (!yCands.length) yCands = cols.slice();

        // Seçenekleri doldur
        xSel.innerHTML = xCands.map(c => `<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join('');
        ySel.innerHTML = yCands.map(c => `<option value="${escapeHtml(c)}">${escapeHtml(c)}</option>`).join('');

        // Önceki seçimleri geri yüklemeye çalış
        if (prevX && xCands.includes(prevX)) {
            xSel.value = prevX;
        } else if (xSel.options.length) {
            xSel.selectedIndex = 0;
        }

        if (prevYs && prevYs.length){
            Array.from(ySel.options).forEach(o => { o.selected = prevYs.includes(o.value); });
        }
        // hiçbiri seçilmediyse en az bir tanesini seç
        if (!Array.from(ySel.options).some(o => o.selected) && ySel.options.length){
            ySel.options[0].selected = true;
        }
    }

    function rowsToCSV(rows){
        if(!rows.length) return '';
        const cols = Object.keys(rows[0]);
        const esc = (v)=> `"${String(v??'').replace(/"/g,'""')}"`;
        const head = cols.map(esc).join(',');
        const body = rows.map(r=> cols.map(c=>esc(r[c])).join(',')).join('\n');
        return head+'\n'+body;
    }
    function downloadCSV(filename, text){
        const blob = new Blob([text], {type:'text/csv;charset=utf-8;'});
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a'); a.href=url; a.download=filename; a.click();
        setTimeout(()=> URL.revokeObjectURL(url), 500);
    }
    
    // Preview step geri/ileri & finalize
    window.goBackToPick = function(){
        show($('stepPickFields')); hide($('stepPreview'));
        // X/Y temizle
        const xSel=$('pvX'), ySel=$('pvY');
        if(xSel){ xSel.innerHTML=''; xSel.disabled=true; }
        if(ySel){ ySel.innerHTML=''; ySel.disabled=true; }
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
    };

    function inferVizXY(sel){
        const dims  = sel.filter(s => (s.agg||'none')==='none');        // boyutlar
        const aggs  = sel.filter(s => (s.agg||'none')!=='none');         // metrikler
        const x = dims.length ? (dims[0].alias || dims[0].field) : null;
        const y = aggs.length ? aggs.map(m => m.alias || m.field) : [];
        return { x, y };
    }

    window.finalizeWidget = function(){
        const cfgPayload = buildRunPayload();                 // modelRef, select, filters, having, limit, orderBy
        const chartType  = $('pvChartType')?.value || 'bar';
        const xKey       = $('pvX')?.value || null;
        const yKeys      = $('pvY') ? [...$('pvY').selectedOptions].map(o=>o.value) : [];

        const viz = { chartType: chartType, x: xKey, y: yKeys };

        // Backend’in beklediği meta alan adları:
        const meta = {
            name: $('wmTitle')?.value || '',
            desc: $('wmDesc')?.value  || '',
            icon: $('wmIcon')?.value  || 'bar-chart',
            isActive: 1
        };

        // İsteğe bağlı: vizOptions & format’ı da saklamak istiyorsan bkz. Bölüm 3
        const payload = {
            meta,                 // <- p.meta.*
            cfg: cfgPayload,      // <- p.cfg
            viz: viz,              // <- p.viz
            live: getLiveOptionsFromUI()
        };

        // Edit mi Create mi?
        if(EDIT.mode === 'edit' && EDIT.widgetId){
            payload.widgetId = EDIT.widgetId; // <- p.widgetId (UPDATE)
        }

        fetch('/v16/add_options/report/api/widgets/save_semantic_widget.cfm', {
            method: 'POST',
            headers: {'Content-Type':'application/json;charset=utf-8','Accept':'application/json;charset=utf-8'},
            body: JSON.stringify(payload)
        })
        .then(r=>r.json())
        .then(res=>{
            if(!res.success) return alert('Kaydetme hatası: ' + (res.message||''));
            alert((payload.widgetId?'Güncellendi: ':'Kaydedildi: ') + 'WidgetID '+ (res.widgetId||payload.widgetId));
            closeWidgetBuilder();
            // (ops.) WS invalidate backend’de tetikleniyorsa ekstra bir şey yapma
        })
        .catch(e=> alert('Ağ hatası: ' + e.message));
    };

    // ===== Wire static buttons/inputs =====
    $('btnRefresh')?.addEventListener('click', listModels);
    $('modelSearch')?.addEventListener('input', debounce(listModels, 200));
    $('pvRunBtn')?.addEventListener('click', runQuery);
    $('pvCsvBtn')?.addEventListener('click', ()=> {
        if(!LAST_ROWS.length) return alert('Önce sorgu çalıştırın.');
        downloadCSV('results.csv', rowsToCSV(LAST_ROWS));
    });
    
    // Dışarıdan gerekirse:
    window.wbListModels = listModels;
    window.wbRunQuery   = runQuery;

    // ==== dışarıdan erişim için export ====
    window.wbLoadModel                    = loadModel;
    window.wbInitPickFields               = initPickFields;
    window.wbRenderSelected               = renderSelected;
    window.wbRenderFilterBox              = renderFilterBox;
    window.wbRenderFilterList             = renderFilterList;
    window.wbRenderHavingList             = (typeof renderHavingList==='function'? renderHavingList : ()=>{});
    window.wbEnsurePreviewSortControls    = ensurePreviewSortControls;
    window.wbRefreshSortOptions           = refreshSortOptions;
    window.wbUpdateMappingOptions         = updateMappingOptions;
    window.wbPrefillMappingFromSelection  = prefillMappingFromSelection;
    window.wbShow = show;
    window.wbHide = hide;
    window.wbUpdateStepHint               = wbUpdateStepHint;

    
    })(); // IIFE sonu
    // Mark ready & drain queued calls
    (function(){
    try{
        window.__WB_READY = true;
        if (window.__WB_QUEUE && window.openWidgetBuilder){
        while(window.__WB_QUEUE.length){
            const [m, id] = window.__WB_QUEUE.shift();
            try{ window.openWidgetBuilder(m, id); }catch(_){}
        }
        }
    }catch(_){}
    })();
    
    
// ==== dışarıdan erişim için export (safety) ====
try{
  window.wbLoadModel  = window.wbLoadModel  || loadModel;
  window.wbInitPickFields = window.wbInitPickFields || initPickFields;
  window.wbRenderSelected = window.wbRenderSelected || renderSelected;
  window.wbRenderFilterBox = window.wbRenderFilterBox || renderFilterBox;
  window.wbRenderFilterList = window.wbRenderFilterList || renderFilterList;
  window.wbRenderHavingList = window.wbRenderHavingList || (typeof renderHavingList==='function'? renderHavingList : ()=>{});
  window.wbEnsurePreviewSortControls = window.wbEnsurePreviewSortControls || ensurePreviewSortControls;
  window.wbRefreshSortOptions = window.wbRefreshSortOptions || refreshSortOptions;
  window.wbUpdateMappingOptions = window.wbUpdateMappingOptions || updateMappingOptions;
  window.wbPrefillMappingFromSelection = window.wbPrefillMappingFromSelection || prefillMappingFromSelection;
  window.wbShow = window.wbShow || show;
  window.wbHide = window.wbHide || hide;
  window.wbUpdateStepHint = window.wbUpdateStepHint || wbUpdateStepHint;
}catch(e){ console.warn('export glue failed', e); }
// Basit helper'lar (global)
    window.$ = window.$ || (id => document.getElementById(id));
    window.debounce = window.debounce || function (fn, wait=200){
    let t; return (...args)=>{ clearTimeout(t); t=setTimeout(()=>fn.apply(null,args), wait); };
    };
    // ==== Chart.js entegrasyonu ====
    // Tek instance için tutucu:
    let __wbChart = null;

    // Chart.js yoksa CDN'den yükle
    function ensureChartJS(cb){
        if (window.Chart) return cb();
        const s = document.createElement('script');
        s.src = "https://cdn.jsdelivr.net/npm/chart.js";
        s.onload = cb;
        s.onerror = () => alert("Chart.js yüklenemedi (CDN erişimi).");
        document.head.appendChild(s);
    }

    function getChartType(){
        return (document.getElementById('pvChartType')?.value);
    }

    // Basit sayı dönüştürücü
    function toNum(v){
        const n = Number(v);
        return Number.isFinite(n) ? n : 0;
    }

    function buildChartConfig(type, rows, xKey, yKeys, vizOptions = {}){
        rows  = Array.isArray(rows)  ? rows  : [];
        yKeys = Array.isArray(yKeys) ? yKeys : [];

        const labels = rows.map(r => String((r && r[xKey]) ?? ''));

        const datasets = yKeys.map(k => ({
            label: k,
            data : rows.map(r => {
            const v = r ? r[k] : 0;
            const n = Number(v);
            return Number.isFinite(n) ? n : 0;
            }),
            fill : (type === 'area') ? true : !!vizOptions.fill
        }));

        return {
            type: (type === 'area' ? 'line' : type),
            data: { labels, datasets },
            options: {
            responsive: true,
            plugins: {
                legend: { display: vizOptions.legend !== false },
                title : { display: !!vizOptions.title, text: vizOptions.title }
            },
            scales: {
                x: { stacked: !!vizOptions.stacked, title:{ display: !!vizOptions.xLabel, text: vizOptions.xLabel }},
                y: { stacked: !!vizOptions.stacked, title:{ display: !!vizOptions.yLabel, text: vizOptions.yLabel }}
            }
            }
        };
    }


    function prefillMappingFromSelection(){
        const xSel = document.getElementById('pvX');
        const ySel = document.getElementById('pvY');
        if (!xSel || !ySel) return;

        const arr  = (PF && Array.isArray(PF.selected)) ? PF.selected : [];
        const dims = arr.filter(s => (s.agg || 'none') === 'none');
        const aggs = arr.filter(s => (s.agg || 'none') !== 'none');

        const x = ((dims[0] && (dims[0].alias || dims[0].field)) || '').toString().trim();
        const ys = (aggs.length ? aggs : arr.slice(1))
            .map(s => ((s.alias || s.field || '') + '').trim())
            .filter(Boolean);

        // X
        if (x) {
            xSel.innerHTML = `<option value="${escapeHtml(x)}">${escapeHtml(x)}</option>`;
            xSel.disabled = false;
            xSel.value = x;
        } else {
            xSel.innerHTML = '';
            xSel.disabled = true;
        }

        // Y(ler)
        if (ys.length) {
            ySel.innerHTML = ys.map(c => `<option value="${escapeHtml(c)}" selected>${escapeHtml(c)}</option>`).join('');
            ySel.disabled = false;
        } else {
            ySel.innerHTML = '';
            ySel.disabled = true;
        }
    }


    function applyChartBoxSize(){
        const host = document.getElementById('wbChartHost');
        if(!host) return;

        const fit = document.getElementById('pvFit')?.checked;
        const w   = parseInt(document.getElementById('pvW')?.value || '800', 10);
        const h   = parseInt(document.getElementById('pvH')?.value || '360', 10);

        if (fit) {
            host.style.width  = '100%';
            host.style.height = (isFinite(h) ? h : 360) + 'px';
        } else {
            host.style.width  = (isFinite(w) ? w : 800) + 'px';
            host.style.height = (isFinite(h) ? h : 360) + 'px';
        }

        // Chart.js yeniden ölçümlendirme
        if (window.__wbChart) {
            // maintainAspectRatio zaten false ise anında uyum sağlar
            __wbChart.resize();
        }
        }

        // İlk yükleme ve kontrol değişimlerinde bağla
        document.getElementById('pvW')?.addEventListener('input', applyChartBoxSize);
        document.getElementById('pvH')?.addEventListener('input', applyChartBoxSize);
        document.getElementById('pvFit')?.addEventListener('change', applyChartBoxSize);

        // Pencere yeniden boyutlanınca, Sığdır açık ise reflow yap
        window.addEventListener('resize', ()=>{
        if (document.getElementById('pvFit')?.checked) applyChartBoxSize();
    });
    function getVizOptions(){
        return {
            legend : !!document.getElementById('voLegend')?.checked,
            stacked: !!document.getElementById('voStacked')?.checked,
            fill   : !!document.getElementById('voFill')?.checked,
            title  : document.getElementById('voTitle')?.value || '',
            xLabel : document.getElementById('voXLabel')?.value || '',
            yLabel : document.getElementById('voYLabel')?.value || ''
        };
    }
    function getMetaFromUI(){
        return {
            title: document.getElementById('wmTitle')?.value || '',
            description: document.getElementById('wmDesc')?.value || '',
            icon: document.getElementById('wmIcon')?.value || ''
        };
    }
    async function loadWidgetForEdit(widgetId){
        try{
            const r = await fetch(`/v16/add_options/report/query/get_semantic_widget.cfm?widgetId=${widgetId}`, {
            headers:{ "Content-Type": "application/json; charset=utf-8" }
            });
            const raw = await r.json();
            if(!raw.success) throw new Error(raw.message || 'Widget okunamadı');

            EDIT.loadedConfig = raw;

            // === META → form alanlarını doldur ===
            const m = raw.meta || {};
            const setVal = (id, val) => { const el = document.getElementById(id); if (el) el.value = (val ?? '').toString(); };
            const setChk = (id, on)  => { const el = document.getElementById(id); if (el && 'checked' in el) el.checked = !!on; };

            setVal('wmTitle', m.name);
            setVal('wmDesc',  m.desc);
            setVal('wmIcon',  m.icon);
            setChk('wmActive', (typeof m.isActive === 'number' ? m.isActive !== 0 : !!m.isActive));

            // 1) İlgili modeli yükle
            const ref = raw.config?.cfg?.modelRef || {};
            await wbLoadModel(ref.modelUid, String(ref.version || 'published'));

            // 2) Step-2 state'ini hazırla
            wbInitPickFields(BLD.modelJson);  // PF.model set

            // 3) Kaydedilmiş seçim/filtreleri Step-2 UI'ına işle
            applyConfigToStep2(raw);          // senin fonksiyonun

            if (raw.config?.live){setLiveOptionsToUI(raw.config.live);}

            // 4) Step görünürlüğü
            wbHide('stepSelectModel');
            wbHide('stepModelLoaded');
            wbShow('stepPickFields');
            wbHide('stepPreview');
            if (window.wbUpdateStepHint) window.wbUpdateStepHint();

        }catch(e){
            alert('Edit yükleme hatası: ' + (e.message||e));
        }
    }

    function applyConfigToStep2(raw){
        if(!BLD?.modelJson){ console.warn('modelJson yok'); return; }
        if(!PF?.model){ console.warn('PF.model yok'); return; }

        const C   = raw?.config || {};
        const cfg = (C.cfg && typeof C.cfg==='object') ? C.cfg : C;

        const SELECT  = cfg.select  || [];
        const FILTERS = cfg.filters || [];
        const HAVING  = cfg.having  || [];

        // --- Seçilen alanlar
        PF.selected = SELECT.map(s => ({
            entity: s.entity || '',
            field : s.field  || '',
            role  : s.role   || '',
            agg   : (s.agg || 'none').toLowerCase(),
            dtype : null,
            alias : s.alias || s.label || s.field || ''
        }));
        wbRenderSelected();

        // --- Filtreler
        PF.filters = FILTERS.map(f=>({
            key  : f.key || '',
            op   : f.op || '=',
            value: (f.value ?? ''),
            conj : f.conj || 'AND'
        }));
        wbRenderFilterBox();
        wbRenderFilterList();

        // --- HAVING
        PF.having = HAVING.map(h=>({
            entity: h.entity || '',
            field : h.field  || '',
            agg   : (h.agg || 'none').toLowerCase(),
            op    : h.op  || '=',
            value : (h.value ?? ''),
            conj  : h.conj || 'AND'
        }));
        wbRenderHavingList?.();

        // --- Sıralama/limit bilgisi Step-3’e kaldı (Devam et deyince uygularız)
    }

    function applyConfigToUI(raw){
        if(!BLD?.modelJson){
            console.warn('applyConfigToUI: modelJson yok; wbLoadModel sonra wbInitPickFields çağrılmalı.');
            return;
        }
        if(!PF?.model){
            console.warn('applyConfigToUI: PF.model yok; wbInitPickFields() eksik.');
            return;
        }
        const meta = raw.meta || {};
        const cfg  = raw.config?.cfg || {};
        const viz  = raw.config?.viz || {};
        const vizOptions = raw.config?.vizOptions || {};
        const format = raw.config?.format || {};

        // PF.selected/filters/having
        PF.selected = (cfg.select||[]).map(s => ({
            entity:s.entity, field:s.field, role:s.role,
            agg:(s.agg||'none'), dtype:null, alias:(s.alias||s.field)
        }));
        wbRenderSelected(); 
        wbRenderFilterBox();
        PF.filters = (cfg.filters||[]).slice(0); wbRenderFilterList();
        PF.having  = (cfg.having||[]).slice(0);  wbRenderHavingList?.();

        // limit & order
        if(cfg.limit) $('pvLimit').value = cfg.limit;
        wbEnsurePreviewSortControls(); wbRefreshSortOptions();
        if(cfg.orderBy?.column){ $('pvOrderBy').value = cfg.orderBy.column; $('pvOrderDir').value = (cfg.orderBy.dir||'ASC').toUpperCase()==='DESC'?'DESC':'ASC'; }

        // viz tipi + mapping
        if(viz.chartType) $('pvChartType').value = viz.chartType;
        if(viz.x && $('pvX')){ $('pvX').innerHTML = `<option value="${viz.x}">${viz.x}</option>`; $('pvX').disabled=false; $('pvX').value=viz.x; }
        if(Array.isArray(viz.y) && viz.y.length && $('pvY')){
            $('pvY').innerHTML = viz.y.map(v=>`<option value="${v}" selected>${v}</option>`).join(''); $('pvY').disabled=false;
        }

        // vizOptions
        $('voLegend').checked = !!vizOptions.legend;
        $('voStacked').checked = !!vizOptions.stacked;
        $('voFill').checked    = !!vizOptions.fill;
        $('voTitle').value     = vizOptions.title  || '';
        $('voXLabel').value    = vizOptions.xLabel || '';
        $('voYLabel').value    = vizOptions.yLabel || '';

        // meta (dikkat: backend name/desc bekliyor)
        $('wmTitle').value = meta.name || '';
        $('wmDesc').value  = meta.desc || '';
        $('wmIcon').value  = meta.icon || 'bar-chart';

        console.debug(
            'DOM check:',
            !!document.getElementById('stepSelectModel'),
            !!document.getElementById('stepModelLoaded'),
            !!document.getElementById('stepPickFields'),
            !!document.getElementById('stepPreview')
        );

        // applyConfigToUI sonunda:
        wbHide('stepSelectModel');
        wbShow('stepModelLoaded');   // burada başlasın
        wbHide('stepPickFields');
        wbHide('stepPreview');
        if(window.wbUpdateStepHint) window.wbUpdateStepHint();
        // butonlardan “Devam et” basınca zaten stepPickFields → stepPreview akışı çalışacak
        $('pvRunBtn').click();
    }
    function getLiveOptionsFromUI(){
        const el = document.getElementById('liveOps');
        let ops = [];
        if (el){
            if (el.selectedOptions && typeof el.selectedOptions.length === 'number'){
            ops = Array.from(el.selectedOptions).map(o => o.value).filter(Boolean);
            } else if (el.options){
            ops = Array.from(el.options).filter(o => o.selected).map(o => o.value).filter(Boolean);
            }
        }
        return { ops }; // { ops: ["sales.list_order", ...] }
    }

    function setLiveOptionsToUI(live){
        const el = document.getElementById('liveOps');
        if (!el) return;

        // Hem {ops:[...]} hem de {opCode:"..."} formatlarını destekle
        const ops = Array.isArray(live?.ops)
            ? live.ops
            : (live?.opCode ? [live.opCode] : []);

        const set = new Set(ops.filter(Boolean));
        Array.from(el.options || []).forEach(o => { o.selected = set.has(o.value); });
    }

</script>