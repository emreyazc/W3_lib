<!-- ============= Semantic Wizard (include) ============= -->
<style>
    /* Namespace: sadece wizard içinde */
    #semanticWizardRoot * { box-sizing: border-box; }

    /* İskelet */
    #semanticWizardRoot.sw-hidden{display:none}
    #semanticWizardRoot.sw-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.25);display:flex;align-items:center;justify-content:center;z-index:9999}
    #semanticWizardRoot .sw-modal{width:90%;max-height:90vh;overflow:auto;background:#fff;border-radius:14px;box-shadow:0 20px 60px rgba(0,0,0,.25)}
    #semanticWizardRoot .sw-modal header{padding:12px 16px;border-bottom:1px solid #e5e7eb;display:flex;justify-content:space-between;align-items:center}
    #semanticWizardRoot .sw-title{font-weight:700}
    #semanticWizardRoot .sw-muted{color:#6b7280;font-size:12px}
    #semanticWizardRoot .sw-btn{cursor:pointer;padding:8px 12px;border:1px solid #e5e7eb;background:#fff;border-radius:8px}
    #semanticWizardRoot .sw-btn.sw-primary{background:#1f6feb;border-color:#1f6feb;color:#fff}
    #semanticWizardRoot .sw-btn[disabled]{opacity:.5;cursor:not-allowed}
    #semanticWizardRoot .sw-content{padding:12px 16px}

    /* Stepper */
    #semanticWizardRoot .sw-stepper{display:flex;gap:10px;overflow:auto;padding:8px 16px;background:#f7f8fa;border-bottom:1px solid #e5e7eb}
    #semanticWizardRoot .sw-step{display:flex;align-items:center;gap:8px;white-space:nowrap}
    #semanticWizardRoot .sw-dot{width:22px;height:22px;border-radius:50%;border:2px solid #e5e7eb;display:grid;place-items:center;font-size:12px;color:#6b7280;background:#fff;flex:0 0 auto}
    #semanticWizardRoot .sw-step.sw-active .sw-dot{border-color:#1f6feb;color:#1f6feb}
    #semanticWizardRoot .sw-step.sw-done .sw-dot{background:#1f6feb;border-color:#1f6feb;color:#fff}

    /* Ortak minik parçalar */
    #semanticWizardRoot .sw-row{display:flex;align-items:center;justify-content:space-between;border:1px solid #e5e7eb;border-radius:10px;padding:10px}
    #semanticWizardRoot .sw-xs{font-size:12px;color:#6b7280}
    #semanticWizardRoot .sw-help{font-size:12px;color:#6b7280;margin-top:6px}
    #semanticWizardRoot .sw-chip{display:inline-block;padding:3px 8px;border:1px solid #e5e7eb;border-radius:999px;font-size:12px;background:#fff}
    #semanticWizardRoot .sw-card{border:1px solid #e9ecef;border-radius:14px;background:#fff}
    #semanticWizardRoot .sw-card > .hdr{padding:10px 12px;border-bottom:1px solid #eef0f3;font-weight:600}
    #semanticWizardRoot .sw-card > .body{padding:12px}

    /* Pager */
    #semanticWizardRoot .sw-pager{display:flex;justify-content:space-between;align-items:center;gap:8px;margin-top:14px;padding:12px 0;border-top:1px solid #e5e7eb;position:sticky;bottom:0;background:#fff}

    /* ============ STEP 1 (Flex) ============ */
    #swStep1 .s1-top{display:flex;flex-wrap:wrap;gap:14px}
    #swStep1 .s1-schema{flex:0 0 420px;max-width:420px}
    #swStep1 .s1-tables{flex:1 1 420px;min-width:360px}
    #swStep1 .s1-bottom{margin-top:14px}
    #swStep1 .s1-entities{flex:1 1 auto}

    /* ============ STEP 2 (Üst üste) ============ */
    #swStep2 .s2-wrap{display:flex;flex-direction:column;gap:14px}
    #swStep2 .s2-entityList{width:100%}
    #swStep2 .s2-fields{width:100%}
    #swFieldTable{width:100%;border-collapse:collapse;table-layout:fixed}
    #swFieldTable th,#swFieldTable td{border-bottom:1px solid #eef0f3;padding:8px 6px;text-align:left;font-size:13px;vertical-align:top}
    #swFieldTable .s2-aggWrap{display:flex;flex-wrap:wrap;gap:8px}

    /* ============ STEP 3 (Flex) ============ */
    /* STEP 3 — Dikey düzen: Üstten alta: İlişki Tanımı → İlişkiler → Test Sonucu */
    #swStep3 .s3-wrap{
    display: grid;
    grid-template-columns: 1fr;
    grid-template-areas:
        "config"
        "relations"
        "results";
    gap: 14px;
    align-items: start;
    }
    #swStep3 .s3-config   { grid-area: config; }
    #swStep3 .s3-relations{ grid-area: relations; }
    #swStep3 .s3-results  { grid-area: results; }

    /* Kart gövdeleri iç scroll alabilsin */
    #swStep3 .s3-config,
    #swStep3 .s3-relations,
    #swStep3 .s3-results { display:flex; flex-direction:column; }
    #swStep3 .s3-config  > .body,
    #swStep3 .s3-relations > .body,
    #swStep3 .s3-results > .body { flex:1 1 auto; min-height:0; }

    /* Yükseklikler: dış modal kaymasın, her blok kendi içinde scroll yapsın */
    #swStep3 .s3-config  > .body   { max-height: 30vh; overflow:auto; }
    #swStep3 .s3-relations > .body { max-height: 30vh; overflow:auto; }
    #swStep3 .s3-results > .body   { max-height: 28vh; overflow:auto; }

    /* Join çekmecesinde yatay kaymayı kapat ve satırları taşırma */
    #swStep3 .s3-drawer{ overflow-x:hidden; }
    #swStep3 .s3-joinRow{
    display:flex; align-items:center; gap:8px; flex-wrap:wrap;
    }
    #swStep3 .s3-joinRow select{ flex:1 1 200px; min-width:140px; max-width:100%; }
    #swStep3 .s3-joinRow > span,
    #swStep3 .s3-joinRow > button.sw-btn{ flex:0 0 auto; float:none; }

    /* (Vardıysa) SQL başlığını sticky tut – sonuçlar kayarken sabit kalsın */
    #semanticWizardRoot .sw-sqlbox summary{
    position:sticky; top:0; background:#fff; z-index:1; cursor:pointer; font-weight:600; margin-bottom:6px;
    }
    #semanticWizardRoot .sw-sqlbox summary{
        position: sticky;
        top: 0;
        background: #fff;
        z-index: 1;
        cursor: pointer;
        font-weight: 600;
        margin-bottom: 6px;
    }
    #swStep3 .s3-relations{flex:1 1 450px;min-width:420px}
    #swStep3 .s3-drawer{overflow-x: hidden;border:1px dashed #e0e3e7;border-radius:10px;padding:10px;background:#fcfdff;margin-top:10px}
    #swStep3 .s3-joinRow{display: flex;align-items: center;gap: 8px; flex-wrap: wrap;}
    #swStep3 .s3-joinRow select{
        flex: 1 1 200px;        /* büyüsün/küçülsün */
        min-width: 140px;       /* çok dar kalmasın */
        max-width: 100%;
    }
    #swStep3 .s3-joinRow > span,
    #swStep3 .s3-joinRow > button.sw-btn{flex: 0 0 auto;float: none;}

    /* ============ STEP 4 ============ */
    #swStep4 .s4-box .s4-list{display:flex;flex-direction:column;gap:10px}
    #swStep4 .s4-item{display:flex;justify-content:space-between;align-items:center;padding:14px;border:1px dashed #e5e7eb;border-radius:12px;background:linear-gradient(0deg,#fafafa,#fff)}
    #swStep4 .s4-pill{padding:4px 10px;border:1px solid #e5e7eb;border-radius:999px;font-size:12px;color:#6b7280;background:#fff}

    /* ============ STEP 5 ============ */
    #swStep5 .s5-form{display:flex;flex-wrap:wrap;align-items:center;gap:10px;max-width:640px}
    #swStep5 .s5-form label{flex:0 0 160px}
    #swStep5 .s5-form .fld{flex:1 1 300px;min-width:260px}

    /* ============ STEP 3 - Quick Test Sonuçları ============ */
    #swStep3 .s3-results{flex:1 1 100%}
    #semanticWizardRoot .sw-sql{background:#0b1020; color:#e6edf3; padding:10px; border-radius:8px; overflow:auto; font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; font-size:12px}

    #semanticWizardRoot .res-wrap{max-height:420px; overflow:auto; border:1px solid #eef0f3; border-radius:10px}
    #semanticWizardRoot .sw-table{width:100%; border-collapse:separate; border-spacing:0; table-layout:auto}
    #semanticWizardRoot .sw-table th,
    #semanticWizardRoot .sw-table td{padding:8px 10px; border-bottom:1px solid #eef0f3; font-size:12.5px; text-align:left; vertical-align:top; white-space:nowrap}
    #semanticWizardRoot .sw-table th{position:sticky; top:0; background:#f7f8fb; z-index:1}
    #semanticWizardRoot .sw-table tr:nth-child(even) td{background:#fcfcfe}
    #semanticWizardRoot .sw-table tr:hover td{background:#f6fafc}
    #semanticWizardRoot .sw-chip.mini{font-size:11px; padding:2px 6px}
    #semanticWizardRoot #swTblList{max-height: 340px; overflow: auto;}
    #semanticWizardRoot #swFieldTable thead th{position: sticky; top: 0; background: #f7f8fb; z-index: 1;}
    #semanticWizardRoot .sw-rel-highlight{ animation: swBlink 1.2s ease-in-out 1; }
    @keyframes swBlink{
        0%,100%{ background:inherit; }
        20%,60%{ background:#fffbe6; } /* yumuşak sarı vurgulama */
    }
</style>
  
  <div id="semanticWizardRoot"
       class="sw-backdrop sw-hidden"
       style="display:none"
       aria-modal="true"
       role="dialog"
       aria-labelledby="swTitle"
       data-dsn="<cfoutput>#encodeForHTMLAttribute(dsn ?: DSN ?: '')#</cfoutput>">
    <div class="sw-modal">
      <header>
        <div>
          <div id="swTitle" class="sw-title">Semantic Modeler</div>
          <div class="sw-muted">Tek modal / wizard — İleri/Geri ile adımlar</div>
        </div>
        <button class="sw-btn" onclick="closeSemanticWizard()">Kapat</button>
      </header>
  
      <div class="sw-stepper" id="swStepper"></div>
  
      <div class="sw-content">
        <!-- STEP 1 -->
        <div id="swStep1" hidden>
          <div class="s1-top">
            <div class="sw-card s1-schema">
                <div class="hdr">Şemalar</div>
                <div class="body">
                  <div style="display:flex; gap:8px; margin-bottom:8px">
                    <input id="swSchemaFilter" class="sw-btn" placeholder="Şema ara..." style="flex:1" />
                    <button class="sw-btn" onclick="swClearSchemaFilter()">Temizle</button>
                  </div>
                  <div id="swSchemaList" class="res-wrap" style="max-height:300px;">
                    <div class="sw-muted">Yükleniyor…</div>
                  </div>
                  <div class="sw-help" style="margin-top:8px">
                    Şemanın yanındaki <b>Yükle</b> ile varlıkları (view ve tablo) getir.
                  </div>
                </div>
              </div>                          
            <div class="sw-card s1-tables">
                <div class="hdr">Varlıklar</div>
                    <div class="body">
                        <div style="margin-bottom:8px">
                            <input id="swTblSearch" class="sw-btn" placeholder="Varlık ara..." oninput="swRenderTableList()" style="width:100%" />
                        </div>
                        <div id="swTblList" class="res-wrap" style="max-height:340px"></div>
                    </div>
                </div>
          </div>
          <div class="s1-bottom">
            <div class="sw-card s1-entities">
              <div class="hdr">Seçili Varlıklar</div>
              <div class="body" id="swEntitySummary">
                <div class="sw-muted">Henüz entity eklenmedi.</div>
              </div>
            </div>
          </div>
        </div>
  
        <!-- STEP 2 -->
        <div id="swStep2" hidden>
          <div class="s2-wrap">
            <div class="sw-card s2-entityList">
              <div class="hdr">Varlıklar</div>
              <div class="body" id="swEntityList"></div>
            </div>
            <div style="margin-bottom:8px">
                <input id="swFieldFilter" class="sw-btn" placeholder="Alan ara..." oninput="swApplyFieldFilter()" style="width:100%" />
            </div>
            <div class="sw-card s2-fields">
              <div class="hdr">Kolonlar & Semantic Tanımlar</div>
              <div class="body">
                <div id="swFieldTableWrap" class="res-wrap" style="max-height:360px">
                <table id="swFieldTable">
                    <colgroup>
                        <col style="width:150px"/>
                        <col style="width:150px"/>
                        <col style="width:150px"/>
                        <col style="width:120px"/>
                        <col style="width:130px"/>
                        <col style="width:100px"/>
                        <col style="width:120px"/>
                        <col style="width:80px"/>
                        <col style="width:200px"/>
                    </colgroup>
                    <thead>
                        <tr>
                        <th>Sütun Adı</th>
                        <th>Alias</th>
                        <th>Açıklama</th>
                        <th>Rol</th>
                        <th>Varsayılan Hesaplama</th>
                        <th>Hesaplama Seçenekleri</th>
                        <th>Biçim</th>
                        <th>Görünürlük</th>
                        <th>Kategori/Etiket</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                    </table>
                </div>
                <div class="sw-help" style="margin-top:8px">
                    Ölçüler için <b>Varsayılan Hesaplama</b>’yı seçin; kullanıcı gerekirse 
                    <b>Hesaplama Seçenekleri</b>’nden başka birini tercih edebilir.
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- STEP 3 -->
        <div id="swStep3" hidden>
            <div class="s3-wrap">
                <div id="swConnectivity" class="sw-help" style="margin:6px 0 10px"></div>
                <div class="sw-card s3-config">
                    <div class="hdr">İlişki Tanımı</div>
                    <div class="body">
                    <div style="display:flex;flex-direction:column;gap:6px;margin-bottom:10px">
                        <label>Sol Varlık</label>
                        <select id="swLeftEntity" class="sw-btn" onchange="swRenderJoinDrawer()"></select>
                        <label>Sağ Varlık</label>
                        <select id="swRightEntity" class="sw-btn" onchange="swRenderJoinDrawer()"></select>
                        <label>Join Type</label>
                        <select id="swJoinType" class="sw-btn">
                            <option>INNER</option>
                            <option>LEFT</option>
                            <option>RIGHT</option>
                            <option>FULL</option>
                        </select>
                        <label>Kardinalite</label>
                        <select id="swCardinality" class="sw-btn">
                        <option>1-1</option><option selected>1-N</option><option>N-N</option>
                        </select>
                    </div>
            
                    <div class="s3-drawer" id="swJoinDrawer">
                        <b>Join Eşleştir</b>
                        <div class="sw-help">Sol ve sağ kolonları seç, satır ekle.</div>
                        <div id="swJoinRows"></div>
                        <div style="margin-top:8px;display:flex;gap:8px;flex-wrap:wrap;align-items:center">
                            <button class="sw-btn" onclick="swSwapEntities()" title="Sol/Sağ tarafları değiştir">⇄ Tarafları Değiştir</button>
                            <button class="sw-btn" onclick="swAddJoinRow()">+ Koşul Ekle</button>
                            <button class="sw-btn" onclick="swSuggestJoins()">Önerileri Getir</button>
                            <button id="swApplyJoinBtn" class="sw-btn" onclick="swApplyJoin()">Uygula</button>
                            <button id="swQuickTestBtn" class="sw-btn" onclick="swQuickTest()">Test Et</button>
                            <input id="swTestLimit" class="sw-btn" type="number" min="1" value="10" title="Top N" style="width:100px"/>
                            <!---
                            <span class="sw-chip mini">Örnek sonuç</span>
                            --->
                        </div>
                    </div>
            
                    <div class="sw-help" style="margin-top:6px">Öneriler *_ID ve aynı isimli kolonlardan türetilir.</div>
                    <div class="sw-help">Rozetler: 🔑 PK &nbsp;&nbsp; 🔗 FK</div>
                    </div>
                </div>
        
                <div class="sw-card s3-relations">
                    <div class="hdr">İlişkiler</div>
                    <div class="body" id="swRelationsList">
                    <div class="sw-muted">Henüz ilişki eklenmedi.</div>
                    </div>
                </div>
        
                <!-- ✓ YENİ: Sonuç kartı (tam genişlik) -->
                <div class="sw-card s3-results">
                    <div class="hdr">Test Sonucu</div>
                    <div class="body">
                        <details class="sw-sqlbox" open>
                        <summary style="display:flex;align-items:center;justify-content:space-between;gap:8px">
                            <span>Oluşan SQL’i göster/gizle</span>
                            <button class="sw-btn" type="button" onclick="swCopySQL()">SQL’i Kopyala</button>
                        </summary>
                        <pre id="swQuickTestSQL" class="sw-sql"></pre>
                        </details>
                    <div class="res-wrap">
                        <div id="swQuickTestResult"><div class="sw-muted">Henüz test çalıştırılmadı.</div></div>
                    </div>
                    <div id="swQuickTestMeta" class="sw-help" style="margin-top:6px"></div>
                    </div>
                </div>
            </div>
        </div>  
  
        <!-- STEP 4 -->
        <div id="swStep4" hidden>
          <div class="sw-card s4-box">
            <div class="hdr">Doğrulama / Test (MVP sonrası)</div>
            <div class="body">
              <div class="s4-list">
                <div class="s4-item"><span>Cycle kontrolü</span><span class="s4-pill">Planlandı</span></div>
                <div class="s4-item"><span>Boş join oranı</span><span class="s4-pill">Planlandı</span></div>
                <div class="s4-item"><span>Alias çakışması</span><span class="s4-pill">Planlandı</span></div>
              </div>
              <div class="sw-help" style="margin-top:8px">Bu adım Q4 başında aktif edilecek.</div>
            </div>
          </div>
        </div>
  
        <!-- STEP 5 -->
        <div id="swStep5" hidden>
          <div class="sw-card s5-box">
            <div class="hdr">Kaydet & Yayınla</div>
            <div class="body">
                <div style="display:flex; gap:8px; margin-top:12px; flex-wrap:wrap">
                    <button id="swBtnSaveDraft"   class="sw-btn"        onclick="swSaveDraft()">Taslak Kaydet</button>
                    <button id="swBtnPublish"     class="sw-btn sw-primary" onclick="swPublishModel()">Yayınla</button>
                    <button id="swBtnShowJSON"    class="sw-btn"        onclick="swShowModelJSON()">JSON’u Göster</button>
                    <button id="swBtnDownloadJSON"class="sw-btn"        onclick="swDownloadModelJSON()">JSON İndir</button>
                </div>
                <details id="swModelJSONBox" class="sw-sqlbox" style="margin-top:10px">
                    <summary>Model JSON (v1)</summary>
                    <pre id="swModelJSON" class="sw-sql"></pre>
                </details>                  
                <!---
              <div class="s5-form">
                <label>Model Adı</label>
                <input id="swModelName" class="sw-btn fld" value="ERP Core Model" />
                <label>Aktif</label>
                <select id="swIsActive" class="sw-btn fld">
                  <option value="true" selected>Evet</option>
                  <option value="false">Hayır</option>
                </select>
              </div>
              <div class="sw-help" style="margin-top:8px">Kaydet dediğinde metadata ve ilişkiler DB’ye yazılır.</div>
            --->
            </div>
          </div>
        </div>
  
        <!-- PAGER -->
        <div class="sw-pager">
          <div class="sw-muted" id="swStepHint">Adım 1/5</div>
          <div style="display:flex;gap:8px">
            <button class="sw-btn" onclick="swPrevStep()">&larr; Geri</button>
            <button class="sw-btn" id="swSaveBtn" onclick="swSaveModel()" style="display:none">Kaydet</button>
            <button class="sw-btn sw-primary" id="swNextBtn" onclick="swNextStep()">İleri &rarr;</button>
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <script>
    /* ======================== DSN ======================== */
    function swResolveDSN(){
      const el = document.getElementById('semanticWizardRoot');
      const fromData = (el && el.dataset && el.dataset.dsn ? el.dataset.dsn.trim() : "");
      const fromCFa  = "<cfoutput>#encodeForJavaScript(dsn ?: '')#</cfoutput>";
      const fromCFb  = "<cfoutput>#encodeForJavaScript(DSN ?: '')#</cfoutput>";
      return [fromData, fromCFa, fromCFb].find(v => v && v !== "undefined" && v !== "##DSN##") || "";
    }
  
    /* ===================== State ====================== */
    const SW = {
      step: 1, maxStep: 5,
      dsn: swResolveDSN(),     // sadece datasource
      schema: "",              // Step1'de listeleme için geçici seçim
      tables: [], columns: {}, // cache key: schema.table
      tableRows: [],
      entities: [], selectedEntityId: null,
      relations: [], tempJoins: []
    };
    window.SW = SW;
  
    function swKey(schema, table){ return `${schema}.${table}`; }
    function swShowStep(n){ for(let i=1;i<=SW.maxStep;i++){ const el=document.getElementById('swStep'+i); if(el) el.hidden=(i!==n); } }
    function swSetStep(n){ SW.step=n; swRender(); }
  
    /* ===================== Catalog API ====================== */
    async function swFetchSchemas() {
      if (!SW.dsn){ console.warn("SW.dsn boş, schemas çağrısı yapılmadı."); return []; }
      const params = new URLSearchParams({ dsn: SW.dsn, limit: 100 });
      const r = await fetch(`/V16/add_options/report/api/semantic/catalog/schemas.cfm?${params.toString()}`);
      if (!r.ok) { console.error("schemas err", await r.text()); return []; }
      const data = await r.json();
      if (Array.isArray(data)) return data;
      if (Array.isArray(data.items)) return data.items;
      if (Array.isArray(data.ITEMS)) return data.ITEMS;
      return [];
    }
  
    async function swFetchTables(schema, q="") {
      if (!SW.dsn){ console.warn("SW.dsn boş, tables çağrısı yapılmadı."); return []; }
      const params = new URLSearchParams({ dsn: SW.dsn, schema, q, limit: 500 });
      const r = await fetch(`/v16/add_options/report/api/semantic/catalog/tables.cfm?${params.toString()}`);
      if (!r.ok) { console.error("tables err", await r.text()); return []; }
      const data = await r.json();
      const raw = Array.isArray(data.items) ? data.items
               : Array.isArray(data.ITEMS) ? data.ITEMS
               : Array.isArray(data)       ? data
               : [];
      return raw.map(it => ({
        name:   it.name   || it.NAME,
        schema: it.schema || it.SCHEMA,
        type:   (it.type  || it.TYPE || "").toLowerCase()
      }));
    }
  
    async function swFetchColumns(schema, table){
      if (!SW.dsn){ console.warn("SW.dsn boş, columns çağrısı yapılmadı."); return []; }
      const params = new URLSearchParams({ dsn: SW.dsn, schema, table });
      const r = await fetch(`/v16/add_options/report/api/semantic/catalog/columns.cfm?${params.toString()}`);
      if(!r.ok){ console.error("columns err", await r.text()); return []; }
      const data = await r.json();
      const raw = Array.isArray(data.columns) ? data.columns
               : Array.isArray(data.COLUMNS) ? data.COLUMNS
               : [];
      return raw.map(c => ({
        name:     c.name     || c.NAME,
        dataType: (c.dataType|| c.DATATYPE || "").toLowerCase(),
        is_pk:    !!(c.isPk  ?? c.ISPK    ?? false),
        is_fk:    !!(c.isFk  ?? c.ISFK    ?? false),
        nullable: !!(c.nullable ?? c.NULLABLE ?? true)
      }));
    }
  
    /* ===================== Render ====================== */
    function swRender(){
      const labels = ["E1 Şema/Varlık","E2 Varlık","E3 İlişki","E4 Doğrulama","E5 Kaydet"];
      document.getElementById('swStepper').innerHTML = labels.map((lbl,i)=>{
        const idx=i+1, cls = idx<SW.step?'sw-step sw-done':(idx===SW.step?'sw-step sw-active':'sw-step');
        return `<div class="${cls}"><div class="sw-dot">${idx<SW.step?'✓':idx}</div><div class="sw-label">${lbl}</div></div>`;
      }).join('');
      swShowStep(SW.step);
  
      document.getElementById('swStepHint').textContent = `Adım ${SW.step}/${SW.maxStep}`;
      const isLast = SW.step===SW.maxStep;
      document.getElementById('swNextBtn').style.display = isLast ? 'none':'inline-block';
      document.getElementById('swSaveBtn').style.display = isLast ? 'inline-block':'none';
  
      if(SW.step===1){
        swRenderSchemas();
        swRenderTableList();
        swRenderEntitySummary();
      }
      if(SW.step===2){ swRenderEntityList(); }
      if(SW.step===3){
        swInitJoinSelectors();
        swRenderRelationsList();
        swRenderConnectivityBadge();
      }
    }
  
    /* ==== STEP 1 ==== */
    async function swRenderSchemas(filter){
        const host = document.getElementById('swSchemaList');
        if (!host) return;

        // Inputtan ya da parametreden filtre değeri
        const q = typeof filter === 'string'
            ? filter.trim().toLowerCase()
            : (document.getElementById('swSchemaFilter')?.value || '').trim().toLowerCase();

        try {
            const items = await swFetchSchemas();                // ['dbo','public',...]
            const all   = Array.isArray(items) ? items : [];
            const list  = q ? all.filter(s => String(s).toLowerCase().includes(q)) : all;

            if (!list.length){
            host.innerHTML = '<div class="sw-muted">Şema bulunamadı.</div>';
            return;
            }

            // alfabetik sırala ve tabloyu bas
            const rows = [...list].sort((a,b)=> String(a).localeCompare(String(b))).map(s=>{
            const sQ = JSON.stringify(String(s)); // onclick için güvenli
            return `
                <tr>
                <td><b>${swEscape(String(s))}</b></td>
                <td style="text-align:right">
                    <button class="sw-btn" onclick='swLoadTables(${sQ})'>Yükle</button>
                </td>
                </tr>`;
            }).join('');

            host.innerHTML = `
            <table class="sw-table" style="width:100%">
                <thead>
                <tr>
                    <th>Şema Adı</th>
                    <th style="text-align:right">İşlem</th>
                </tr>
                </thead>
                <tbody>${rows}</tbody>
            </table>`;

            // Arama input’una debounce’lu bağla (bir kez)
            const inp = document.getElementById('swSchemaFilter');
            if (inp && !inp._bound) {
            inp._bound = true;
            let t; inp.addEventListener('input', () => {
                clearTimeout(t); t = setTimeout(()=> swRenderSchemas(inp.value), 200);
            });
            }

        } catch (err) {
            console.error(err);
            host.innerHTML = '<div class="alert alert-danger">Şemalar getirilemedi.</div>';
        }
        }

        // Aramayı temizle butonu
        window.swClearSchemaFilter = function(){
        const inp = document.getElementById('swSchemaFilter');
        if (inp) inp.value = '';
        swRenderSchemas('');
        };

        window.swApplyFieldFilter = function(){
            SW._fieldFilter = (document.getElementById('swFieldFilter')?.value || '').trim();
            if (SW.selectedEntityId) swEditEntity(SW.selectedEntityId);
        };

        // (Zaten eklemiş olabilirsin ama hatırlatayım)
        // swLoadTables artık parametre alabiliyor olsun:
        window.swLoadTables = async function(schema){
        const activeSchema = schema || SW.schema;
        if (!activeSchema) { alert("Önce bir şema seçin."); return; }
        SW.schema = activeSchema;

        const q = (document.getElementById('swTblSearch')?.value || "").trim();
        const rows = await swFetchTables(SW.schema, q);
        SW.tableRows = rows;
        SW.tables    = rows.map(r => r.name);
        swRenderTableList();
    };

    window.swLoadTables = async function(schema){
        // Eski kullanım uyumluluğu: parametre yoksa SW.schema'yı kullan
        const activeSchema = schema || SW.schema;
        if (!activeSchema) { alert("Önce bir şema seçin."); return; }

        SW.schema = activeSchema; // aktif şemayı güncelle
        const q = (document.getElementById('swTblSearch')?.value || "").trim();
        const rows = await swFetchTables(SW.schema, q);
        SW.tableRows = rows;
        SW.tables    = rows.map(r => r.name);
        swRenderTableList();
    };
  
    function swGetTableMeta(tbl){
      return (SW.tableRows||[]).find(r => r.name === tbl) || null;
    }
  
    window.swRenderTableList = function(){
        const q    = (document.getElementById('swTblSearch')?.value || '').toLowerCase();
        const data = (SW.tables || []).filter(t => t.toLowerCase().includes(q));
        const host = document.getElementById('swTblList');
        if (!host) return;

        if (!data.length){
            host.innerHTML = `<div class="sw-muted">Sonuç yok.</div>`;
            return;
        }

        // alfabetik sırala ve meta ekle
        const items = [...data]
            .sort((a,b) => a.localeCompare(b))
            .map(name => {
            const meta = swGetTableMeta(name) || { schema: '—', type: '' };
            return {
                name,
                schema: meta.schema || '—',
                type: (meta.type || '').toUpperCase() // view/table vs.
            };
            });

        const rows = items.map(it => {
            const nameQ   = JSON.stringify(it.name);   // onclick için güvenli quoting
            const schemaQ = JSON.stringify(it.schema); // onclick için güvenli quoting
            return `
            <tr>
                <td><b>${swEscape(it.name)}</b></td>
                <td><span class="sw-xs">${swEscape(it.schema)}</span></td>
                <td>${swEscape(it.type || '-')}</td>
                <td style="text-align:right">
                <div style="display:flex;gap:8px;justify-content:flex-end">
                    <button class="sw-btn" onclick='swViewColumns(${schemaQ}, ${nameQ})'>Kolonlar</button>
                    <button class="sw-btn sw-primary" onclick='swAddEntity(${schemaQ}, ${nameQ})'>+ Varlık</button>
                </div>
                </td>
            </tr>`;
        }).join('');

        host.innerHTML = `
            <table class="sw-table" style="width:100%">
            <thead>
                <tr>
                <th>Ad</th>
                <th>Şema</th>
                <th>Tip</th>
                <th style="text-align:right">İşlemler</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
            </table>`;
    };
  
    window.swViewColumns = async function(schema, tbl){
      const cols = await swFetchColumns(schema, tbl);
      if (!cols.length){ alert(`${tbl} için kolon bulunamadı.`); return; }
      const lines = cols.map(c=>{
        const flags = [ c.is_pk ? "PK" : "", c.is_fk ? "FK" : "", c.nullable ? "NULL" : "NOT NULL" ].filter(Boolean).join(", ");
        return `${c.name} : ${c.dataType} ${flags ? '('+flags+')' : ''}`;
      });
      alert(`${schema}.${tbl} kolonları:\n` + lines.join("\n"));
      SW.columns[swKey(schema,tbl)] = cols;
    };
  
    window.swAddEntity = async function(schema, tbl){
      if (SW.entities.some(e=>e.table===tbl && (e.schema||"")===schema)){
        alert('Bu varlık zaten eklendi.'); return;
      }
      const cacheKey = swKey(schema,tbl);
      if (!SW.columns[cacheKey]) {
        SW.columns[cacheKey] = await swFetchColumns(schema, tbl);
      }
      const cols = SW.columns[cacheKey] || [];
      const id=(SW.entities.at(-1)?.entityId||0)+1;
      const e={
        entityId:id, table:tbl, alias:tbl, label:tbl, category:"",
        dsn: SW.dsn,           // entity bazında datasource
        schema: schema,        // tablonun gerçek şeması
        keys: cols.filter(c=>c.is_pk).map(c=>c.name),
        fields: cols.map(c=>({
          name:c.name, alias:c.name, label:c.name, desc:"",
          dataType:c.dataType,
          role: c.is_pk ? 'id' : (/(date|time)/i.test(c.dataType)?'date':'dimension'),
          aggDefault: (/(int|decimal|numeric|money|float|real|double)/i.test(c.dataType) && !c.is_pk && !/(date|time)/i.test(c.dataType)) ? 'sum' : 'none',
          aggAllowed: (/(int|decimal|numeric|money|float|real|double)/i.test(c.dataType) && !c.is_pk) ? ['sum','avg','min','max','count'] : [],
          format: /(money|decimal|numeric)/i.test(c.dataType)?'money' : (/(date|time)/i.test(c.dataType)?'date':''),
          isKey: !!c.is_pk, isFk: !!c.is_fk, visible:true, filterable:true, category:""
        }))
      };
      SW.entities.push(e);
      swRenderEntitySummary();
    };

    // Join seçenekleri için field meta üret (PK/FK bilgisi dahil)
    function swGetEntityFieldsForJoinMeta(e){
        if(!e) return [];
        // Kolon cache'inden FK bilgisi (fallback)
        const key = swKey(e.schema, e.table);
        const cols = (SW.columns && SW.columns[key]) || [];
        const fkSet = new Set(cols.filter(c => c.is_fk || c.ISFK).map(c => c.name || c.NAME));

        const list = (e.fields || []).map(f => ({
            name: f.name,
            isPk: !!(f.isKey || f.role === 'id'),
            isFk: (typeof f.isFk !== 'undefined') ? !!f.isFk : fkSet.has(f.name)
        }));

        // PK'lar önce, sonra FK'lar, sonra alfabetik
        return list.sort((a,b)=>{
            const ra = a.isPk ? 0 : (a.isFk ? 1 : 2);
            const rb = b.isPk ? 0 : (b.isFk ? 1 : 2);
            if (ra !== rb) return ra - rb;
            return String(a.name).localeCompare(String(b.name));
        });
    }

    // PK/FK rozetli option listesi üret
    function swBuildJoinOptions(fieldMeta, placeholder){
    const ops = [`<option value="">${swEscape(placeholder || 'Kolon seç')}</option>`];
    fieldMeta.forEach(f => {
        const badge = (f.isPk ? ' 🔑' : '') + (f.isFk ? ' 🔗' : '');
        const label = swEscape(`${f.name}${badge}`);
        const val   = swEscape(f.name);
        ops.push(`<option value="${val}">${label}</option>`);
    });
    return ops.join('');
    }

  
    function swRenderEntitySummary(){
        const host = document.getElementById('swEntitySummary');
        const list = SW.entities || [];
        if (!host) return;

        if (!list.length){
            host.innerHTML = '<div class="sw-muted">Henüz varlık eklenmedi.</div>';
            return;
        }

        // alfabetik sıralı (alias/table)
        const items = [...list].sort((a,b)=>
            String(a.alias || a.table || '').localeCompare(String(b.alias || b.table || ''))
        );

        const rows = items.map(e=>{
            const alias  = swEscape(e.alias || e.table || `#${e.entityId}`);
            const schema = swEscape(e.schema || '—');
            const table  = swEscape(e.table  || '');
            const keys   = (e.keys && e.keys.length) ? e.keys.map(k=>swEscape(k)).join(', ') : '-';

            return `
            <tr>
                <td><b>${alias}</b></td>
                <td><span class="sw-xs">${schema}.${table}</span></td>
                <td>${keys}</td>
                <td style="text-align:right">
                <div style="display:flex;gap:8px;justify-content:flex-end">
                    <button class="sw-btn" onclick="swGotoEntity(${e.entityId})">Düzenle</button>
                    <button class="sw-btn" onclick="swDeleteEntity(${e.entityId})">Sil</button>
                </div>
                </td>
            </tr>`;
        }).join('');

        host.innerHTML = `
        <table class="sw-table" style="width:100%">
        <thead>
            <tr>
            <th>Ad</th>
            <th>Şema.Tablo</th>
            <th>Anahtarlar</th>
            <th style="text-align:right">İşlemler</th>
            </tr>
        </thead>
        <tbody>${rows}</tbody>
        </table>`;
    }
    window.swGotoEntity=function(id){ SW.selectedEntityId=id; swSetStep(2); };
    // Varlık silme (ilişkileri de temizler)
    // Varlık silme (ilişkileri de temizler ve UI'ı yeniler)
    // Varlık silme (ilişkileri de temizler ve UI'ı yeniler)
    window.swDeleteEntity = function(id){
        if(!confirm('Bu varlığı silmek istediğinize emin misiniz?')) return;

        // 1) Varlığı sil
        SW.entities = (SW.entities || []).filter(e => e.entityId !== id);

        // 2) Bu varlığa bağlı tüm ilişkileri temizle
        SW.relations = (SW.relations || []).filter(r => r.leftEntityId !== id && r.rightEntityId !== id);

        // 3) Seçili varlık bu ise güvenli bir seçime dön
        if (SW.selectedEntityId === id) {
            SW.selectedEntityId = SW.entities[0]?.entityId || null;
        }

        // 4) UI'yı toparla (varsa ilgili kısımları yeniden çiz)
        if (document.getElementById('swEntitySummary')) swRenderEntitySummary();
        if (document.getElementById('swEntityList'))    swRenderEntityList();
        if (document.getElementById('swRelationsList')) swRenderRelationsList();
        if (document.getElementById('swConnectivity'))  swRenderConnectivityBadge();

        // Step 3 açıkken sol/sağ seçimlerini de güncelle
        if (SW.step === 3 && typeof swInitJoinSelectors === 'function') {
            swInitJoinSelectors();
        }
    };
  
    /* ==== STEP 2 ==== */
    function swRenderEntityList(){
        const wrap = document.getElementById('swEntityList');
        if (!wrap) return;

        const list = SW.entities || [];
        if (!list.length){
            wrap.innerHTML = '<div class="sw-muted">Varlık yok.</div>';
            return;
        }

        // alfabetik sırala (alias/table)
        const items = [...list].sort((a,b)=>
            String(a.alias || a.table || '').localeCompare(String(b.alias || b.table || ''))
        );

        const rows = items.map(e=>{
            const alias  = swEscape(e.alias || e.table || `#${e.entityId}`);
            const schema = swEscape(e.schema || '—');
            const table  = swEscape(e.table  || '');
            const keys   = (e.keys && e.keys.length) ? e.keys.map(k=>swEscape(k)).join(', ') : '-';

            return `
            <tr>
                <td><b>${alias}</b></td>
                <td><span class="sw-xs">${schema}.${table}</span></td>
                <td>${keys}</td>
                <td style="text-align:right">
                <button class="sw-btn" onclick="swEditEntity(${e.entityId})">Düzenle</button>
                <!-- İstersen buraya Sil de ekleyebilirsin:
                <button class="sw-btn" onclick="swDeleteEntity(${e.entityId})">Sil</button>
                -->
                </td>
            </tr>`;
        }).join('');

        wrap.innerHTML = `
            <table class="sw-table" style="width:100%">
            <thead>
                <tr>
                <th>Ad</th>
                <th>Şema.Tablo</th>
                <th>Anahtarlar</th>
                <th style="text-align:right">İşlemler</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
            </table>`;

        // önceki davranışı koru: seçili yoksa ilk varlığı seç ve düzenleme görünümünü aç
        if (!SW.selectedEntityId && SW.entities[0]) SW.selectedEntityId = SW.entities[0].entityId;
        swEditEntity(SW.selectedEntityId);
    }
  
    window.swEditEntity = function(id){
        SW.selectedEntityId = id;
        const e = SW.entities.find(x => x.entityId === id); if(!e) return;

        const tbody = document.querySelector('#swFieldTable tbody');
        const q = String(SW._fieldFilter || '').toLowerCase();

        // Filtre: name/label/desc içinde arar
        const src = e.fields || [];
        const view = q
            ? src.filter(f =>
                [f.name, f.label, f.desc].some(v => String(v||'').toLowerCase().includes(q))
            )
            : src;

        if (!view.length){
            tbody.innerHTML = `<tr><td colspan="9"><div class="sw-muted">Eşleşen alan yok.</div></td></tr>`;
            return;
        }

        tbody.innerHTML = view.map(f => {
            const i = src.indexOf(f); // orijinal index
            return `
            <tr>
                <td><input readonly class="sw-btn" value="${f.name||''}"/></td>
                <td><input class="sw-btn" value="${f.label||''}" oninput="swUpdField(${id},${i},'label',this.value)" /></td>
                <td><textarea class="sw-btn" rows="1" oninput="swUpdField(${id},${i},'desc',this.value)">${f.desc||''}</textarea></td>
                <td>
                <select class="sw-btn" onchange="swUpdField(${id},${i},'role',this.value)">
                    ${['id','dimension','date','measure'].map(r=>`<option ${f.role===r?'selected':''}>${r}</option>`).join('')}
                </select>
                </td>
                <td>
                <select class="sw-btn" onchange="swUpdField(${id},${i},'aggDefault',this.value)">
                    ${['none','sum','avg','count','min','max'].map(a=>`<option ${f.aggDefault===a?'selected':''}>${a}</option>`).join('')}
                </select>
                </td>
                <td>
                <div class="s2-aggWrap">
                    ${['sum','avg','count','min','max'].map(a=>{
                    const checked=(f.aggAllowed||[]).includes(a)?'checked':'';
                    return `<label class="sw-xs"><input type="checkbox" ${checked} onchange="swToggleAllowed(${id},${i},'${a}',this.checked)"> ${a.toUpperCase()}</label>`;
                    }).join('')}
                </div>
                </td>
                <td>
                <select class="sw-btn" onchange="swUpdField(${id},${i},'format',this.value)">
                    ${['','money','date','percent','string','number'].map(v=>`<option value="${v}" ${f.format===v?'selected':''}>${v||'—'}</option>`).join('')}
                </select>
                </td>
                <td style="text-align:center"><input type="checkbox" ${f.visible?'checked':''} onchange="swUpdField(${id},${i},'visible',this.checked)"/></td>
                <td><input class="sw-btn" value="${f.category||''}" oninput="swUpdField(${id},${i},'category',this.value)" placeholder="Finansal, Stok..." /></td>
            </tr>
            `;
        }).join('');
    };
    window.swUpdField=function(id,idx,key,val){
      const e=SW.entities.find(x=>x.entityId===id); if(!e) return;
      e.fields[idx][key]=val;
      if(key==='role' && val!=='measure'){ e.fields[idx].aggDefault='none'; e.fields[idx].aggAllowed=[]; swEditEntity(id); }
    };
    window.swToggleAllowed=function(id,idx,agg,checked){
      const e=SW.entities.find(x=>x.entityId===id); if(!e) return;
      const list=new Set(e.fields[idx].aggAllowed||[]);
      if(checked) list.add(agg); else list.delete(agg);
      e.fields[idx].aggAllowed=Array.from(list);
    };
  
    /* ==== STEP 3 ==== */
    function swInitJoinSelectors(){
      const L = document.getElementById('swLeftEntity');
      const R = document.getElementById('swRightEntity');
      const opts = SW.entities.map(e=>`<option value="${e.entityId}">${e.alias}</option>`).join('');
      L.innerHTML = opts; R.innerHTML = opts;
  
      if(!L.value && SW.entities[0]) L.value = SW.entities[0].entityId;
      if(!R.value && SW.entities[1]) R.value = SW.entities[1].entityId;
      if(L.value === R.value && SW.entities[1]) R.value = SW.entities[1].entityId;
  
      const handleChange = function(){
        if(L.value === R.value){ alert("Sol ve sağ entity farklı olmalı."); this.selectedIndex = 0; return; }
        SW.tempJoins = [{left:'', right:''}];
        swRenderJoinRows();
      };
      L.onchange = handleChange;
      R.onchange = handleChange;
  
      if(!SW.tempJoins || !SW.tempJoins.length) SW.tempJoins=[{left:'', right:''}];
      swRenderJoinRows();
    }
  
    function swGetEntity(id){ return SW.entities.find(e=>e.entityId===+id); }
    function swGetEntityFieldsForJoin(e){
      if(!e) return [];
      const ks = (e.fields||[]).filter(f=>f.isKey || f.role==='id').map(f=>f.name);
      const rest = (e.fields||[]).filter(f=>!(f.isKey||f.role==='id')).map(f=>f.name);
      return [...new Set([...ks, ...rest])];
    }

    function swUpdateApplyState(){
        const btn = document.getElementById('swApplyJoinBtn');
        if (!btn) return;
        const ok = hasValidTempJoin();        // sende zaten var
        btn.disabled = !ok;
        btn.title = ok ? 'İlişkiyi uygula' : 'En az bir geçerli kolon eşleşmesi seçin';
    }
  
    function swRenderJoinRows(){
      const lId = +document.getElementById('swLeftEntity').value;
      const rId = +document.getElementById('swRightEntity').value;
      const le = swGetEntity(lId), re = swGetEntity(rId);
      const lMeta = swGetEntityFieldsForJoinMeta(le);
      const rMeta = swGetEntityFieldsForJoinMeta(re);
      const leftOpts  = swBuildJoinOptions(lMeta,  'Sol kolon');
      const rightOpts = swBuildJoinOptions(rMeta, 'Sağ kolon');
  
      const box = document.getElementById('swJoinRows');
        box.innerHTML = (SW.tempJoins||[]).map((j,i)=>`
          <div class="s3-joinRow">
            <select class="sw-btn sw-lcol" data-idx="${i}" data-side="left">${leftOpts}</select>
            <span>=</span>
            <select class="sw-btn sw-rcol" data-idx="${i}" data-side="right">${rightOpts}</select>
            <button class="sw-btn" title="Bu koşulda sol/sağı değiştir" onclick="swSwapJoinRow(${i})">⇄</button>
            <button class="sw-btn" title="Koşulu Sil" onclick="swRemoveJoinRow(${i})">×</button>
          </div>
        `).join('');
  
      box.querySelectorAll('.sw-lcol').forEach((sel,i)=>{ sel.value = SW.tempJoins[i].left || ""; });
      box.querySelectorAll('.sw-rcol').forEach((sel,i)=>{ sel.value = SW.tempJoins[i].right || ""; });
  
      box.querySelectorAll('select').forEach(sel=>{
        sel.addEventListener('change', function(){
        const i = +this.dataset.idx, side = this.dataset.side;
        SW.tempJoins[i][side] = this.value;
        swUpdateApplyState();
        });
        });
        swUpdateApplyState();
    }

    window.swSwapJoinRow = function(i){
        const row = (SW.tempJoins || [])[i];
        if (!row) return;
        const tmp = row.left; row.left = row.right; row.right = tmp;
        swRenderJoinRows();
        // UX: swap sonrası aynı satırın sol select’ine odaklan
        const box = document.getElementById('swJoinRows');
        const el  = box?.querySelector(`.s3-joinRow:nth-child(${i+1}) .sw-lcol`);
        if (el) setTimeout(()=> el.focus(), 0);
    };

    window.swSwapEntities = function(){
        const L = document.getElementById('swLeftEntity');
        const R = document.getElementById('swRightEntity');
        if (!L || !R) return;
        const lVal = L.value, rVal = R.value;
        if (!lVal || !rVal || lVal === rVal) return;

        // Select değerlerini tersle
        L.value = rVal; 
        R.value = lVal;

        // Geçici join eşleşmelerini de sol/sağ olarak tersle
        (SW.tempJoins || []).forEach(j => { const t = j.left; j.left = j.right; j.right = t; });

        // UI'ı yenile
        swRenderJoinRows();
    };


    window.swRemoveJoinRow = function(i){
        SW.tempJoins.splice(i,1);
        if (!SW.tempJoins.length) SW.tempJoins = [{left:'', right:''}];
        swRenderJoinRows();
        swUpdateApplyState();
    };

    const _oldSuggest = window.swSuggestJoins;
    window.swSuggestJoins = function(){ _oldSuggest(); swUpdateApplyState(); };
  
    function swFocusLastJoinRow(){
        const box = document.getElementById('swJoinRows');
        const el  = box?.querySelector('.s3-joinRow:last-child .sw-lcol');
        if (el) setTimeout(()=> el.focus(), 0);
    }
    window.swAddJoinRow = function(){
        (SW.tempJoins ||= []).push({left:'', right:''});
        swRenderJoinRows();
        swUpdateApplyState();
    };
    window.swSuggestJoins = function(){
      const lId = +document.getElementById('swLeftEntity').value;
      const rId = +document.getElementById('swRightEntity').value;
      const le = swGetEntity(lId), re = swGetEntity(rId);
      if(!le || !re){ alert("Önce sol/sağ entity seçin."); return; }
      const L = swGetEntityFieldsForJoin(le);
      const R = swGetEntityFieldsForJoin(re);
      const cand = [];
      L.forEach(ln=>{
        if(/_ID$/i.test(ln) && R.includes('ID')) cand.push({left:ln, right:'ID'});
        if(R.includes(ln)) cand.push({left:ln, right:ln});
      });
      SW.tempJoins = cand.length ? cand : [{left:'', right:''}];
      swRenderJoinRows();
    };
  
    function hasValidTempJoin(){
      const lId=+document.getElementById('swLeftEntity').value;
      const rId=+document.getElementById('swRightEntity').value;
      const validPairs=(SW.tempJoins||[]).filter(j=>j.left && j.right);
      return !!(lId && rId && lId!==rId && validPairs.length);
    }
    function swAutoApplyTempJoins(){
      if(!hasValidTempJoin()) return;
      const lId=+document.getElementById('swLeftEntity').value;
      const rId=+document.getElementById('swRightEntity').value;
      const joinType=document.getElementById('swJoinType').value;
      const cardinality=document.getElementById('swCardinality').value;
      const joins=(SW.tempJoins||[]).filter(j=>j.left && j.right);
      const exists = SW.relations.some(r => r.leftEntityId===lId && r.rightEntityId===rId && JSON.stringify(r.joins)===JSON.stringify(joins));
      if(!exists){
        SW.relations.push({leftEntityId:lId,rightEntityId:rId,joinType,cardinality,joins});
        swRenderRelationsList();
      }
    }

    async function swQuickTest() {
        const prev = document.getElementById('swNextBtn');
        const next = document.getElementById('swNextBtn');
        const back = document.getElementById('swPrevStep') || document.querySelector('.sw-pager .sw-btn:not(#swNextBtn):not(#swSaveBtn)');
        if (next) next.disabled = true;
        if (back) back.disabled = true;
        const btn  = document.getElementById('swQuickTestBtn');
        const host = document.getElementById('swQuickTestResult');
        const sqlBox = document.getElementById('swQuickTestSQL');

        // Butonu kilitle, metni değiştir; sonuç alanına yükleniyor mesajı koy
        swBtnBusy(btn, true, 'Test ediliyor…', 'Test Et');
        if (host) host.innerHTML = '<div class="sw-help">Çalıştırılıyor…</div>';
        if (sqlBox) sqlBox.textContent = '';
        let payload = null; // <-- scope: catch'de erişilse bile undefined olmaz
        const t0 = Date.now();
        try {
            // Guard: tüm entity'lerde schema+table var mı?
            const missing = (SW.entities||[]).filter(e => !e.schema || !e.table);
            if (missing.length){
            alert("Eksik şema/varlık: " + missing.map(e=>e.alias || e.table || e.entityId).join(", "));
            swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
            return;
            }

            // İlişkiler: Uygula'ya basılmadıysa UI'dan üret
            const rels = swGatherRelationsForTest();
            if (!rels.length){
            alert("En az bir JOIN çifti seçin veya 'Uygula'ya basın.");
            swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
            return;
            }

            // İstersen limit'i UI'dan al; burada sabit örnek
            const limit = Math.max(1, parseInt(document.getElementById('swTestLimit')?.value || '10', 10));

            payload = { dsn: SW.dsn, entities: SW.entities || [], relations: rels, limit };

            const res = await fetch(`/V16/add_options/report/api/semantic/catalog/quick_test.cfm`, {
            method: "POST",
            headers: { "Content-Type":"application/json" },
            body: JSON.stringify(payload)
            });

            // JSON güvenli parse
            const raw = await res.text();
            console.debug('[quick_test raw <=]', raw.slice(0, 400));
            let data;
            try { data = JSON.parse(raw); }
            catch (e) {
                throw new Error("Sunucudan JSON yerine farklı bir içerik geldi.");
            }

            const ok   = swPick(data, "success") === true;
            const msg  = swPick(data, "message") || swPick(data, "detail") || swPick(data, "info");
            const sql  = swPick(data, "sql");
            const rows = swPick(data, "rows") || [];

            const sqlBox = document.getElementById("swQuickTestSQL");
            if (sqlBox) sqlBox.textContent = sql || "";

            // Hata
            if (!ok) 
            {
                document.getElementById("swQuickTestResult").innerHTML =
                `<div class="alert alert-danger">Test başarısız: ${swEscape(msg || "Bilinmiyor")}</div>`;
                const meta = document.getElementById('swQuickTestMeta');
                if (meta) meta.textContent = '';
                swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
            return;
            }

            // Tablo
            const host = document.getElementById("swQuickTestResult");
            if (!rows.length) {
            host.innerHTML = `<div class="alert alert-warning">Sonuç yok${sql ? `<div class="mt-2"><code>${swEscape(sql)}</code></div>` : ""}</div>`;
            swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
            } else {
            const cols = Object.keys(rows[0] || {});
            let html = `<table class="sw-table"><thead><tr>`;
            cols.forEach(c => { html += `<th>${swEscape(c)}</th>`; });
            html += `</tr></thead><tbody>`;
            rows.forEach(r => {
                html += `<tr>`;
                cols.forEach(c => { html += `<td title="${swEscape(r[c])}">${swEscape(r[c])}</td>`; });
                html += `</tr>`;
            });
            html += `</tbody></table>`;
            host.innerHTML = html;
            swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
            if (next) next.disabled = false;
            if (back) back.disabled = false;
            }
            // Meta: satır sayısı ve süre
            const meta = document.getElementById('swQuickTestMeta');
            if (meta) meta.textContent = `Satır: ${rows.length} • Süre: ${Date.now()-t0} ms`;
        } catch (err) {
            console.error(err);
            document.getElementById("swQuickTestResult").innerHTML = `<div class="alert alert-danger">Hata: ${err.message}</div>`;
            const meta = document.getElementById('swQuickTestMeta');
            if (meta) meta.textContent = '';
            swBtnBusy(btn, false, 'Test ediliyor…', 'Test Et');
        }}
  
    /* Relations list + connectivity */
    function swRenderRelationsList(){
        const host = document.getElementById('swRelationsList');
        if (!host) return;

        const rels = SW.relations || [];
        if (!rels.length){
            host.innerHTML = '<div class="sw-muted">Henüz ilişki eklenmedi.</div>';
            return;
        }

        const rows = rels.map((r, i) => {
            const L = SW.entities.find(e => e.entityId === r.leftEntityId)?.alias || r.leftEntityId;
            const R = SW.entities.find(e => e.entityId === r.rightEntityId)?.alias || r.rightEntityId;
            const pairs = (r.joins || []).map(j => `${j.left} = ${j.right}`).join(' AND ') || '-';

            return `
            <tr>
                <td>#${i+1}</td>
                <td>${swEscape(String(L))}</td>
                <td>${swEscape(String(R))}</td>
                <td><span class="sw-chip">${swEscape(String(r.joinType || ''))}</span></td>
                <td><span class="sw-chip">${swEscape(String(r.cardinality || ''))}</span></td>
                <td><span class="sw-xs">${swEscape(pairs)}</span></td>
                <td style="text-align:right">
                <div style="display:flex;gap:8px;justify-content:flex-end">
                    <button class="sw-btn" onclick="swLoadRelation(${i})">Yükle</button>
                    <button class="sw-btn" onclick="SW.relations.splice(${i},1); swRenderRelationsList(); swRenderConnectivityBadge();">Sil</button>
                </div>
                </td>
            </tr>`;
        }).join('');

        host.innerHTML = `
            <table class="sw-table" style="width:100%">
            <thead>
                <tr>
                <th>#</th>
                <th>Sol Varlık</th>
                <th>Sağ Varlık</th>
                <th>Join Tipi</th>
                <th>Kardinalite</th>
                <th>Koşullar</th>
                <th style="text-align:right">İşlemler</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
            </table>`;
    }
    window.swLoadRelation = function(i){
        const r = (SW.relations || [])[i]; 
        if (!r) return;

        // Sol/sağ entity ve ayarlar
        const L = document.getElementById('swLeftEntity');
        const R = document.getElementById('swRightEntity');
        const JT = document.getElementById('swJoinType');
        const CR = document.getElementById('swCardinality');

        if (L) L.value = r.leftEntityId;
        if (R) R.value = r.rightEntityId;
        if (JT) JT.value = r.joinType || 'INNER';
        if (CR) CR.value = r.cardinality || '1-N';

        // Join koşullarını çekmeceye yükle
        SW.tempJoins = (r.joins || []).map(j => ({ left:j.left, right:j.right }));
        swRenderJoinRows();

        // Gerekirse Step 3'e geç
        if (SW.step !== 3) swSetStep(3);
    };
    function swBuildGraph(){
      const g = new Map();
      SW.entities.forEach(e=>g.set(e.entityId, []));
      SW.relations.forEach(r=>{
        g.get(r.leftEntityId).push(r.rightEntityId);
        g.get(r.rightEntityId).push(r.leftEntityId);
      });
      return g;
    }
    function swIsConnectedAll(){
      const ids = SW.entities.map(e=>e.entityId);
      if(ids.length<=1) return true;
      const g = swBuildGraph();
      const seen = new Set([ids[0]]);
      const st=[ids[0]];
      while(st.length){
        const u = st.pop();
        (g.get(u)||[]).forEach(v=>{ if(!seen.has(v)){ seen.add(v); st.push(v); } });
      }
      return ids.every(id=>seen.has(id));
    }
    function swRenderConnectivityBadge(){
      const el = document.getElementById('swConnectivity');
      if(!el) return;
      const ok = swIsConnectedAll();
      el.innerHTML = ok
        ? '🔗 Bağlantı durumu: <b>TAMAM</b> — tüm seçili tablolar tek bileşende.'
        : '⚠️ Bağlantı durumu: <b>EKSİK</b> — bazı tablolar kopuk, ilişki ekleyin.';
    }
  
    /* Pager */
    window.openSemanticWizard = function(){
      const el = document.getElementById('semanticWizardRoot');
      if(!el) return; el.classList.remove('sw-hidden'); el.style.display='flex'; swRender();
    };
    window.closeSemanticWizard = function(){
      const el = document.getElementById('semanticWizardRoot');
      if(!el) return; el.classList.add('sw-hidden'); el.style.display='none';
    };
    window.swNextStep=function(){ if(SW.step===3) swAutoApplyTempJoins(); if(!swValidateStep(SW.step)) return; if(SW.step<SW.maxStep) SW.step++; swRender(); };
    window.swPrevStep=function(){ if(SW.step>1) SW.step--; swRender(); };
  
    function swValidateStep(step){
      if(step===1 && !SW.entities.length){ alert("En az bir tabloyu Varlık olarak ekleyin."); return false; }
      if(step===2){
        for(const e of SW.entities){
          if(!e.keys || !e.keys.length){ alert(`'${e.alias}' için en az bir KEY seçin.`); return false; }
          for(const f of e.fields){
            if(!f.role){ alert(`${e.alias}.${f.name} için ROLE seçin.`); return false; }
            if(f.role==='measure' && (!f.aggDefault || f.aggDefault==='none')){
              alert(`${e.alias}.${f.name} measure için DEFAULT_AGG seçin.`); return false;
            }
          }
        }
      }
      if(step===3){
        if(!SW.relations.length){ alert("En az bir ilişki ekleyin."); return false; }
        if(!swIsConnectedAll()){ alert("Tüm seçili entity’ler tek bileşende değil. Eksik ilişkileri ekleyin."); return false; }
      }
      return true;
    }
  
    /* Save (mock) */
    window.swSaveModel=function(){
      const payload={
        modelName:document.getElementById('swModelName').value || 'ERP Core Model',
        entities:SW.entities,
        relations:SW.relations,
        active:document.getElementById('swIsActive').value==='true'
      };
      //console.log("Semantic Model Payload:", payload);
      alert("Mock: Model kaydedildi (payload console’da).");
    };
  
    // İlk render
    swRender();

    function swGatherRelationsForTest(){
        const rels0 = Array.isArray(SW.relations) ? [...SW.relations] : [];
        if (rels0.length) return rels0;

        const LSel = document.getElementById('swLeftEntity');
        const RSel = document.getElementById('swRightEntity');
        if (!LSel || !RSel) return [];

        const lId = +LSel.value, rId = +RSel.value;
        if (!lId || !rId || lId===rId) return [];

        const pairs = (SW.tempJoins||[])
            .filter(j=>j && j.left && j.right)
            .map(j=>({left:j.left, right:j.right}));

        if (!pairs.length) return [];

        return [{
            leftEntityId:lId,
            rightEntityId:rId,
            joinType: (document.getElementById('swJoinType')?.value || 'INNER'),
            cardinality: (document.getElementById('swCardinality')?.value || '1-N'),
            joins: pairs
        }];
    }

    function swCanonicalJoins(joins){
        return (joins||[])
        .map(j=>({ left: String(j.left||''), right: String(j.right||'') }))
        .sort((a,b)=> (a.left+a.right).localeCompare(b.left+b.right));
    }

    // === İlişkiyi uygula (Uygula butonu) ===
    window.swApplyJoin = function(){
        const LSel = document.getElementById('swLeftEntity');
        const RSel = document.getElementById('swRightEntity');
        const lId = +LSel.value;
        const rId = +RSel.value;

        if (!lId || !rId || lId === rId){
            alert("Sol ve sağ entity farklı olmalı."); 
            return;
        }

        const type = document.getElementById('swJoinType')?.value || 'INNER';
        const card = document.getElementById('swCardinality')?.value || '1-N';

        // UI'da seçilmiş eşleşmeler
        const pairs = (SW.tempJoins || [])
            .filter(j => j && j.left && j.right)
            .map(j => ({ left:j.left, right:j.right }));

        if (!pairs.length){
            alert("Geçerli en az bir kolon eşleşmesi seçin."); 
            return;
        }
        const newPairs = swCanonicalJoins(pairs);
        const isSame = (SW.relations||[]).some(r =>
            r.leftEntityId === lId &&
            r.rightEntityId === rId &&
            r.joinType === type &&
            JSON.stringify(swCanonicalJoins(r.joins)) === JSON.stringify(newPairs)
        );
        if (!isSame){
            SW.relations.push({ leftEntityId:lId, rightEntityId:rId, joinType:type, cardinality:card, joins:pairs });
        }
        // UI'ı güncelle
        swRenderRelationsList();
        swRenderConnectivityBadge();
        // (İstersen) alert("İlişki eklendi.");
        const newIdx = SW.relations.length - 1;
        swHighlightRelationRow(newIdx);
    };
    function swPick(o, ...keys){
        if (!o || typeof o !== 'object') return undefined;
        const oks = Object.keys(o);
        for (const k of keys){
            const hit = oks.find(kk => kk.toLowerCase() === k.toLowerCase());
            if (hit) return o[hit];
        }
        return undefined;
    }

    function swGetRows(data){
        // rows, ROWS, data, DATA… ne geldiyse diziye çevir
        let rows = swPick(data, 'rows', 'data');
        if (Array.isArray(rows)) return rows;
        return []; // başka şekil gelmiyor; backend'i A adımıyla sabitledik
    }
    function swEscape(s){
        return String(s ?? '')
        .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
        .replace(/"/g,'&quot;').replace(/'/g,'&#39;');
    }
    // Basit busy helper: butonu kilitle/aç ve metni değiştir
    function swBtnBusy(el, busy, busyText='İşleniyor…', idleText){
        if(!el) return;
        if(busy){
            el.dataset._oldTxt = el.textContent;
            el.disabled = true;
            el.setAttribute('aria-busy','true');
            el.textContent = busyText;
        }else{
            el.disabled = false;
            el.removeAttribute('aria-busy');
            el.textContent = idleText || el.dataset._oldTxt || el.textContent;
            delete el.dataset._oldTxt;
        }
    }
    function swHighlightRelationRow(idx){
        const tbody = document.querySelector('#swRelationsList tbody');
        if (!tbody) return;
        const tr = tbody.querySelector(`tr:nth-child(${idx+1})`);
        if (!tr) return;
        tr.scrollIntoView({block:'center', behavior:'smooth'});
        tr.classList.add('sw-rel-highlight');
        setTimeout(()=>tr.classList.remove('sw-rel-highlight'), 1600);
    }
    window.swCopySQL = function(){
        const el = document.getElementById('swQuickTestSQL');
        const txt = (el?.textContent || '').trim();
        if (!txt){ alert('Kopyalanacak SQL yok.'); return; }

        const write = navigator.clipboard?.writeText
            ? navigator.clipboard.writeText(txt)
            : new Promise((res,rej)=>{
                const ta=document.createElement('textarea');
                ta.value=txt; document.body.appendChild(ta); ta.select();
                try{ document.execCommand('copy'); res(); } catch(e){ rej(e); } finally{ ta.remove(); }
            });

        write.then(()=>{/* istersen toast: swToast('success','SQL kopyalandı.') */})
            .catch(()=> alert('Kopyalama başarısız.'));
    };
    function swUuid(){ try{ return crypto.randomUUID(); }catch(_){
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g,c=>{
            const r=Math.random()*16|0, v=c==='x'?r:(r&0x3|0x8); return v.toString(16);
        });
    }}
    function swEnsureStableIds(){
        // model id'yi SW.modelUid olarak tut (ilk kayıtta üret)
        if(!SW.modelUid) SW.modelUid = swUuid();

        // varlıklar
        (SW.entities||[]).forEach(e=>{
            if(!e.uid) e.uid = swUuid();
            (e.fields||[]).forEach(f=>{ if(!f.uid) f.uid = swUuid(); });
        });

        // ilişkiler
        (SW.relations||[]).forEach(r=>{ if(!r.uid) r.uid = swUuid(); });
    }
    function swValidateModelForSave(){
        if(!(SW.entities||[]).length) throw new Error("En az bir varlık ekleyin.");
        // Her varlıkta en az bir KEY
        for(const e of SW.entities){
            if(!e.keys || !e.keys.length) throw new Error(`'${e.alias||e.table}' için en az bir anahtar (KEY) seçin.`);
            for(const f of e.fields||[]){
            if(!f.role) throw new Error(`${e.alias||e.table}.${f.name} için Rol seçin.`);
            if(f.role==='measure'){
                if(!f.aggDefault || f.aggDefault==='none') throw new Error(`${e.alias||e.table}.${f.name} için Varsayılan Hesaplama seçin.`);
                if(Array.isArray(f.aggAllowed) && !f.aggAllowed.includes(f.aggDefault)){
                throw new Error(`${e.alias||e.table}.${f.name} için Varsayılan Hesaplama, Hesaplama Seçenekleri içinde olmalı.`);
                }
            }
            }
        }
        // İlişkiler ve bağlantı
        if(!(SW.relations||[]).length) throw new Error("En az bir ilişki tanımlayın.");
        if(!swIsConnectedAll()) throw new Error("Tüm varlıklar tek bir bileşende bağlı olmalı (eksik ilişki ekleyin).");
    }
    function swBuildModelJSON(){
        swEnsureStableIds();
        const modelName = (document.getElementById('swModelName')?.value || 'ERP Core Model').trim();
        const isActive  = (document.getElementById('swIsActive')?.value === 'true');

        // normalize entity map
        const entities = (SW.entities||[]).map(e=>({
            uid: e.uid,
            entityId: e.entityId, // UI iç kullanım için saklı (kalıcı değil)
            dsn: e.dsn || SW.dsn || "",
            schema: e.schema || "",
            table: e.table || "",
            alias: e.alias || e.table,
            label: e.label || e.alias || e.table,
            category: e.category || "",
            keys: [...(e.keys||[])],
            fields: (e.fields||[]).map(f=>({
            uid: f.uid,
            name: f.name,
            alias: f.alias || f.name,
            label: f.label || f.name,
            desc: f.desc || "",
            role: f.role || "dimension",
            dataType: f.dataType || "",
            aggDefault: f.aggDefault || "none",
            aggAllowed: Array.isArray(f.aggAllowed) ? f.aggAllowed : [],
            format: f.format || "",
            isKey: !!f.isKey,
            isFk: !!f.isFk,
            visible: f.visible !== false,
            filterable: f.filterable !== false,
            category: f.category || ""
            }))
        }));

        const relations = (SW.relations||[]).map(r=>({
            uid: r.uid,
            left_entity_uid: (SW.entities.find(e=>e.entityId===r.leftEntityId)||{}).uid,
            right_entity_uid:(SW.entities.find(e=>e.entityId===r.rightEntityId)||{}).uid,
            joinType: r.joinType || "INNER",
            cardinality: r.cardinality || "1-N",
            joins: (r.joins||[]).map(j=>({ left: j.left, right: j.right }))
        }));

        return {
            schemaVersion: "1.0",
            modelUid: SW.modelUid,
            name: modelName,
            active: !!isActive,
            dsn: SW.dsn || "",
            entities,
            relations,
            meta: {
            createdAt: SW.createdAt || null,
            updatedAt: new Date().toISOString()
            }
        };
    }
    function swShowModelJSON(){
        try{
            const json = swBuildModelJSON();
            const box  = document.getElementById('swModelJSON');
            if(box) box.textContent = JSON.stringify(json, null, 2);
            const det = document.getElementById('swModelJSONBox');
            if(det) det.open = true;
        }catch(err){
            alert("JSON oluşturulamadı: " + err.message);
        }
    }
    function swDownloadModelJSON(){
        try{
            const json = swBuildModelJSON();
            const blob = new Blob([JSON.stringify(json,null,2)], {type:'application/json'});
            const url  = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url; a.download = (json.name || 'model') + '.json';
            a.click(); URL.revokeObjectURL(url);
        }catch(err){
            alert("JSON indirilemedi: " + err.message);
        }
    }
    async function swSaveDraft(){
        try{
            swValidateModelForSave();
            const btns = lockStep5(true);
            const payload = { model: swBuildModelJSON() };

            // createdAt ilk kez atanır
            if(!SW.createdAt) { SW.createdAt = new Date().toISOString(); payload.model.meta.createdAt = SW.createdAt; }

            const res = await fetch('/V16/add_options/report/api/semantic/models/save.cfm', {
            method:'POST', headers:{'Content-Type':'application/json'},
            body: JSON.stringify(payload)
            });
            const raw = await res.text(); let data;
            try{ data = JSON.parse(raw); }catch{ throw new Error('Geçersiz JSON cevap'); }
            if(data.success !== true) throw new Error(data.message || 'Kaydetme başarısız');

            // server döndürdüyse modelUid güncelle
            if(data.modelUid) SW.modelUid = data.modelUid;
            alert('Taslak kaydedildi.');
        }catch(err){
            alert('Kaydetme hatası: ' + err.message);
        }finally{
            lockStep5(false);
        }
    }
    async function swPublishModel(){
    try{
        swValidateModelForSave();
        const btns = lockStep5(true);
        const payload = { model: swBuildModelJSON() };

        const res = await fetch('/V16/add_options/report/api/semantic/models/publish.cfm', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify(payload)
        });
        const raw = await res.text(); let data;
        try{ data = JSON.parse(raw); }catch{ throw new Error('Geçersiz JSON cevap'); }
        if(data.success !== true) throw new Error(data.message || 'Yayınlama başarısız');

        if(data.modelUid) SW.modelUid = data.modelUid;
        alert(`Yayınlandı (v${data.version ?? '—'})`);
        }catch(err){
            alert('Yayınlama hatası: ' + err.message);
        }finally{
            lockStep5(false);
        }
    }
    function lockStep5(busy){
        const ids = ['swBtnSaveDraft','swBtnPublish','swBtnShowJSON','swBtnDownloadJSON'];
        ids.forEach(id=>{ const el=document.getElementById(id); if(el) el.disabled = !!busy; });
    }
    function markDirty(){ window.__WB_DIRTY = true; }
      document.getElementById('builderRoot')?.addEventListener('input', markDirty, {capture:true});
      window.closeWidgetBuilder = function(){
        if(window.__WB_DIRTY && !confirm('Kaydedilmemiş değişiklikler var. Kapatılsın mı?')) return;
        WR.classList.add('wb-hidden'); WR.style.display='none';
        removePreviewSortControls();
        window.__WB_DIRTY = false;
    };
  </script>