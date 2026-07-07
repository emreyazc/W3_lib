<head>
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <!-- CodeMirror core -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/codemirror.min.js"></script>

  <!-- Tema (isteğe bağlı koyu: darcula) -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/theme/darcula.min.css">

  <!-- SQL modu + eklentiler -->
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/mode/sql/sql.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/edit/matchbrackets.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/comment/comment.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.16/addon/display/placeholder.min.js"></script>
  
</head>
<cfinclude  template="holistic_live_dashboard_style.cfm">
<cfparam name="url.dashboard_id" default="">
<cfif len(url.dashboard_id)>
    <cfset currentDashboardID = url.dashboard_id>
<cfelse>
    <cfset currentDashboardID = 0>
</cfif>

<cfquery name="GET_DASHBOARD_DEF" datasource="#DSN#">
    SELECT * FROM DASHBOARD_DEFS WHERE DASHBOARD_ID = #currentDashboardID#
</cfquery>

<cfquery name="GET_DASHBOARD" datasource="#DSN#">
    SELECT 
        L.ID,
        L.CUSTOM_TITLE,
        L.WIDGET_ID,
        L.POSITION_X,
        L.POSITION_Y,
        L.WIDTH,
        L.HEIGHT,
        L.SORT_ORDER,
        L.IS_ACTIVE,
        D.FILE_PATH, -- artık grafik yolu buradan geliyor,
        D.WIDGET_TYPE
    FROM 
        DASHBOARD_USER_LAYOUT L
        INNER JOIN DASHBOARD_WIDGET_DEFS D ON L.WIDGET_ID = D.WIDGET_ID
    WHERE
        L.EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
        AND L.IS_ACTIVE = 1
        AND L.DASHBOARD_ID = #currentDashboardID#
    ORDER BY L.SORT_ORDER
</cfquery>

<cfquery name="GET_DASHBOARD_LIST" datasource="#DSN#">
  SELECT 
      D.DASHBOARD_ID,
      D.DASHBOARD_NAME,
      U.IS_FAVORITE
  FROM 
      DASHBOARD_DEFS D
      INNER JOIN DASHBOARD_USER U ON D.DASHBOARD_ID = U.DASHBOARD_ID
  WHERE 
      U.EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
  ORDER BY
      U.IS_FAVORITE DESC, D.DASHBOARD_NAME
</cfquery>

<cfquery name="GET_WIDGET" datasource="#DSN#">
    SELECT 
        WIDGET_ID,
        WIDGET_NAME,
        FILE_PATH,
        WIDGET_TYPE
    FROM 
        DASHBOARD_WIDGET_DEFS
    WHERE 
        IS_ACTIVE = 1
    ORDER BY 
        WIDGET_NAME
</cfquery>

<cfquery name="get_modules" datasource="#DSN#">
  SELECT MODULE_ID, MODULE AS MODULE_NAME FROM MODULES ORDER BY MODULE_NAME ASC
</cfquery>

<cfset modulesJSON = serializeJSON(get_modules)>

<cfset arrDashboardLayout = []>
<cfloop query="GET_DASHBOARD">
  <cfset structItem = {
    ID = GET_DASHBOARD.ID,
    FILE_PATH = GET_DASHBOARD.FILE_PATH,
    CUSTOM_TITLE = GET_DASHBOARD.CUSTOM_TITLE,
    POSITION_X = GET_DASHBOARD.POSITION_X,
    POSITION_Y = GET_DASHBOARD.POSITION_Y,
    WIDTH = GET_DASHBOARD.WIDTH,
    HEIGHT = GET_DASHBOARD.HEIGHT,
    SORT_ORDER = GET_DASHBOARD.SORT_ORDER,
    IS_ACTIVE = GET_DASHBOARD.IS_ACTIVE,
    WIDGET_ID = GET_DASHBOARD.WIDGET_ID,
    WIDGET_TYPE = GET_DASHBOARD.WIDGET_TYPE
  }>
  <cfset arrayAppend(arrDashboardLayout, structItem)>
</cfloop>

<cfset arrWidgetDefs = []>
<cfloop query="GET_WIDGET">
  <cfset arrayAppend(arrWidgetDefs, {
    ID: GET_WIDGET.WIDGET_ID,
    NAME: GET_WIDGET.WIDGET_NAME,
    PATH: GET_WIDGET.FILE_PATH,
    WIDGET_TYPE: GET_WIDGET.WIDGET_TYPE
  })>
</cfloop>

<cfoutput>
  <script>
      const dashboardLayout = #serializeJSON(arrDashboardLayout)#;
      const availableWidgets = #serializeJSON(arrWidgetDefs)#;
      let selectedColumns = [];
      //console.log(availableWidgets);
  </script>
</cfoutput>

<cfoutput>
  <!-- Sağdan Açılır Menü -->
  <div id="rightMenu" class="side-menu">
      <div class="menu-section">
        <li class="menu-item add-dashboard">
          <button id="btnDashboardEkle" style="width:100%; background:##28a745; color:white; padding:10px; border:none; border-radius:6px; font-weight:600; cursor:pointer;">
            🔧 Dashboard Oluştur
          </button>
        </li>
        <div class="menu-title">📊 Dashboard’lar</div>
        <ul id="dashboardList" style="list-style:none; padding:0; margin:0;">
          <cfloop query="GET_DASHBOARD_LIST">
            <li class="menu-item <cfif IS_FAVORITE eq 1>favorite</cfif>" data-id="#DASHBOARD_ID#">
              <cfif IS_FAVORITE eq 1>⭐</cfif> #DASHBOARD_NAME#
            </li>
          </cfloop>
        </ul>
      </div>
      <!---
      <div class="menu-section">
          <div class="menu-title">⚙️ Ayarlar</div>
          <ul style="list-style:none; padding:0; margin:0;">
              <li class="menu-item">Dashboard Yönetimi</li>
              <li class="menu-item">Widget Yönetimi</li>
              <li class="menu-item">Kullanıcı & Yetkiler</li>
          </ul>
      </div>
      --->
      <div class="menu-section">
          <div class="menu-title">📚 Yardım</div>
          <!---
          <ul style="list-style:none; padding:0; margin:0;">
              <li class="menu-item">Kullanıcı Rehberi</li>
              <li class="menu-item">Sürüm Notları</li>
          </ul>
          --->
      </div>
  </div>

  <!--- Menü Toggle Butonu --->
  <button id="menuToggleBtn" class="menu-toggle-btn">☰</button>

  <!--- Widget Seçim Paneli --->
  <div id="widgetModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <button onclick="closeWidgetModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>

    <strong>Bir Widget Seç:</strong>
    <div id="widgetList"></div>

    <!-- Alt Butonlar -->
    <div id="kendi" style="display: flex; flex-direction: column; gap: 10px; padding: 10px 0; border-top: 1px solid ##eee; margin-top: 10px;">

      <button onclick="openWidgetBuilder()" style="padding:10px 20px; background:##6f42c1; color:white; border:none; border-radius:6px; cursor:pointer;">📊 No-Code Widget Oluştur</button>
      
      <!-- Harici URL ile Widget -->
      <button onclick="openCustomWidgetModal()" style="padding:10px 20px; background:##28a745; color:white; border:none; border-radius:6px; cursor:pointer;">🔗 Harici Kaynak Widget'ı Ekle</button>

      <!-- SQL ile Widget -->
      <button onclick="openSQLWidgetModal()" style="padding:10px 20px; background:##007bff; color:white; border:none; border-radius:6px; cursor:pointer;">🧠 SQL ile Widget Oluştur
      </button>

    </div>
  </div>

  <!-- Modal 2: Kolon Rolleri Tanımla -->
  <div id="columnRoleModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:450px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <!-- Kolon Seçici Modal -->
    <div id="columnSelectorModal" style="display:none; position:fixed; top:100px; left:50%; transform:translateX(-50%); background:white; border:1px solid ##ccc; padding:20px; border-radius:8px; width:400px; box-shadow:0 8px 20px rgba(0,0,0,0.2); z-index:1000;">
      <select id="columnDropdown" multiple style="width:100%; padding:8px; margin-top:10px; height:100px;"></select>
      <div style="text-align:right; margin-top:20px;">
          <button onclick="addColumnToTable()" style="padding:6px 12px;">Ekle</button>
          <button onclick="closeColumnSelector()" style="padding:6px 12px;">İptal</button>
        </div>
      </div>
    <!-- Kapat Butonu -->
    <button onclick="closeColumnRoleModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>
    <h3 align="center">📊 Widget Oluştur – Adım 2 / 4</h3>
    <h4>Sütun Seç</h4>
    <!-- Sütun Ekle Butonu -->
    <button onclick="openColumnSelector()" style="padding: 6px 12px; background: ##007bff; color: white; border: none; border-radius: 4px;">
      ➕ Sütun Ekle
    </button>
    <p style="font-size:14px; text-align:center; color:##555;">Kolonları seçin ve grafikteki rollerini belirleyin.</p>
    <div id="columnsContainer" style="margin-top: 16px;">
      <!-- Başlık -->
      <div style="display: flex; font-weight: bold; background: ##f1f1f1; padding: 8px; border-radius: 4px;">
        <div style="flex: 1;">Kolon</div>
        <div style="width: 80px;">İşlem</div>
      </div>
    
      <!-- Eklenen kolonlar burada listelenecek -->
      <div id="columnsTableBody"></div>
    </div>

    <!-- Alt Butonlar -->
    <div style="display:flex; justify-content:space-between;">
      <button onclick="backToSemanticWidgetModal()" 
          style="padding:8px 16px; background:##6c757d; color:white; border:none; border-radius:6px;">
        ⬅️ Geri
      </button>
      <button onclick="goToTestChartModal()" 
          style="padding:8px 16px; background:##6f42c1; color:white; border:none; border-radius:6px;">
        ➡️ Devam Et
      </button>
    </div>
  </div>

  <!-- Modal 3: Test Et -->
  <div id="testChartModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:600px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <!-- Kapat Butonu -->
    <button onclick="closeTestChartModal()" 
        style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>

    <h3 align="center">📊 Widget Oluştur – Adım 3 / 4</h3>
    <p style="font-size:14px; text-align:center; color:##555;">Veri örneğini ve grafiğin önizlemesini test edin.</p>

    <!-- Dummy Veri Tablosu -->
    <div style="overflow-x:auto; margin-bottom:20px;">
      <table>
        <thead>
          <tr></tr> <!-- Bu satır eksikse `headRow` null döner -->
        </thead>
        <tbody></tbody>
      </table>
    </div>

    <!-- Grafik Alanı -->
    <div id="chartPreview" style="height:300px; margin-bottom:20px;">
      <canvas id="testChartCanvas" width="600" height="300"></canvas>
    </div>

    <!-- Alt Butonlar -->
    <div style="display:flex; justify-content:space-between;">
      <button onclick="backToColumnRoleModal()" 
          style="padding:8px 16px; background:##6c757d; color:white; border:none; border-radius:6px;">
        ⬅️ Geri
      </button>
      <!---
      <button onclick="goToCreateWidgetModal()" 
          style="padding:8px 16px; background:##6f42c1; color:white; border:none; border-radius:6px;">
        ➡️ Devam Et
      </button>
      --->
      <button onclick="finalizeWidgetCreation()" 
          style="padding:8px 16px; background:##28a745; color:white; border:none; border-radius:6px;">
        ✅ Oluştur
      </button>
    </div>
  </div>

  
  <!--- Harici Kaynak Widget'ı Ekle --->
  <div id="addCustomWidgetModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <!-- Kapat Butonu -->
    <button onclick="closeCustomWidgetModal()" 
        style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕
    </button>

    <h3 align="center">🖼 Harici Kaynak Widget'ı Ekle</h3>
    
    <form id="customWidgetForm" style="margin-top:15px;">
      <!--- Widget Başlığı --->
      <label>Widget Başlığı:</label><br>
      <input type="text" id="customWidgetTitle" required style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>
      <!--- Embed / iFrame URL --->
      <label>Embed / iFrame URL:</label><br>
      <input type="url" id="customWidgetURL" placeholder="https://..." required style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>
      <small style="font-size:12px; color:##666;">Örn: Google Drive, PowerBI, Data Studio, Tableau...</small><br><br>
      <!--- Ekle Butonu ---->
      <button type="button" onclick="saveCustomWidget()" style="padding:10px 20px; background:##007bff; color:white; border:none; border-radius:6px; cursor:pointer; width:100%;">✅ Ekle </button>
    </form>
  </div>

  <!--- Custom Widget Düzenleme Modal --->
  <div id="editCustomWidgetModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    
    <!--- Kapat Butonu --->
    <button onclick="closeEditWidgetModal()" 
        style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕
    </button>

    <h3 align="center">⚙️ Widget'ı Düzenle</h3>

    <input type="hidden" id="editWidgetId">

    <!--- Widget Başlığı --->
    <label>Widget Başlığı:</label><br>
    <input type="text" id="editWidgetTitle" required style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>

    <!--- Embed / iFrame URL --->
    <label>Embed / iFrame URL:</label><br>
    <input type="url" id="editWidgetURL" required placeholder="https://..." style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>

    <!--- İşlem Butonları --->
    <div style="display:flex; gap:10px; margin-top:10px;">
      <button onclick="saveEditedWidget()" style="flex:1; padding:10px; background:##28a745; color:white; border:none; border-radius:6px; cursor:pointer;">💾 Kaydet</button>
      <button onclick="deleteWidget()" style="flex:1; padding:10px; background:##dc3545; color:white; border:none; border-radius:6px; cursor:pointer;">🗑 Sil</button>
    </div>
  </div>


  <!-- Arkaplan Kapatıcı (opsiyonel) -->
  <div id="customWidgetOverlay" onclick="closeCustomWidgetModal()" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.3); z-index:999;"></div>

  <!-- Dashboard Oluştur Modal -->
  <div id="addDashboardModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <button onclick="closeaddDashboardModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>
    <h3 align="center">🆕 Dashboard Oluştur</h3>

    <form id="dashboardAddForm">
      <label>Dashboard Adı:</label><br>
      <input type="text" name="dashboard_name" required style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>
      <label>Modül:</label><br>
      <select name="module_id" id="module_id" style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;">
        <option value="">Seçiniz</option>
        <cfloop query="#get_modules#">
          <option value="#module_id#">#module_name#</option>
        </cfloop>
      </select><br>
      <label><input type="checkbox" name="is_favorite" value="1"> Favori Yap</label><br>
      <label><input type="checkbox" name="is_public" value="1"> Herkese Açık Olsun</label><br>
      <button type="submit" style="padding:10px 20px; background:##007bff; color:white; border:none; border-radius:6px; cursor:pointer;">
        ✅ Oluştur
      </button>
    </form>
  </div>

  <!-- Dashboard Ayarlar Modal -->
  <div id="editDashboardModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <button onclick="closeEditDashboardModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>
    <h3 align="center">⚙️ Dashboard Ayarları</h3>

    <form id="dashboardEditForm">
      <input type="hidden" name="edit_dashboard_id" id="edit_dashboard_id">
      <label>Dashboard Adı:</label><br>
      <input type="text" name="edit_dashboard_name" id="edit_dashboard_name" required style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;"><br>
      <label>Modül:</label><br>
      <select name="edit_module_id" id="edit_module_id" style="width:100%; padding:8px; margin-bottom:12px; border-radius:6px; border:1px solid ##ddd;">
        <option value="0">Seçinize</option>
        <cfloop query="#get_modules#">
          <option value="#module_id#">#module_name#</option>
        </cfloop>
      </select><br>

      <label><input type="checkbox" name="is_favorite" id="edit_is_favorite" value="1"> Favori Yap</label><br>
      <label><input type="checkbox" name="is_public" id="edit_is_public" value="1"> Herkese Açık</label><br><br>

      <div style="display:flex; justify-content:space-between;">
        <button type="submit" style="padding:10px 20px; background:##28a745; color:white; border:none; border-radius:6px; cursor:pointer;">
          💾 Kaydet
        </button>
        <button type="button" onclick="deleteDashboard()" style="padding:10px 18px; background:##dc3545; color:white; border:none; border-radius:6px; cursor:pointer;">
          🗑️ Sil
        </button>
      </div>
    </form>
  </div>

  <div class="dashboard-header">
    <div class="left">
      <div id="notificationBell" style="position:relative; margin-right:10px;">
        <button onclick="toggleNotificationPanel()" title="Bildirimler" style="background:none; border:none; cursor:pointer;">🔔</button>
        <span id="notificationCount" style="position:absolute; right:-6px; background:red; color:white; font-size:12px; padding:2px 5px; border-radius:50%; display:none;">0</span>
      </div>
  
      <button class="theme-btn" title="Tema Değiştir" onclick="toggleTheme()">🌓</button>
      <button id="btnWidgetEkle" class="widget-btn" title="Widget Ekle">🔧</button>

      <!-- Yeni Wizard Butonu -->
      <button id="btnSemanticWizard" class="wizard-btn" title="Semantik Model Editörü" onclick="openSemanticWizard()">📐</button>
    </div>
  
    <div class="center">
      <h1><span style="margin-right:8px;">📊</span><cfoutput>#GET_DASHBOARD_DEF.DASHBOARD_NAME#</cfoutput></h1>
    </div>
  
    <div class="right">
      <button class="settings-btn" title="Dashboard Ayarları">⚙️</button>
      <button class="export-btn" onclick="exportDashboardAsPDF()" title="PDF olarak indir">📄</button>
    </div>
  </div>

  <!-- 🔔 Bildirim Paneli -->
  <div id="notificationPanel" style="display:none; position:absolute; top:100px; left:20px; width:320px; max-height:400px; overflow-y:auto; background:##fff; border:1px solid ##ccc; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,0.2); z-index:3000; padding:10px;">
    <!-- Sekmeler -->
    <div style="display:flex; margin-bottom:10px; border-bottom:1px solid ##ddd;">
      <button onclick="switchAlertTab('unread')" id="tab-unread" class="active-tab" style="flex:1; padding:6px; background:##eee; border:none; cursor:pointer;">
        🆕 Yeni
      </button>
      <button onclick="switchAlertTab('read')" id="tab-read" style="flex:1; padding:6px; background:##fff; border:none; cursor:pointer;">
        📁 Okundu
      </button>
    </div>
    <!-- Liste Alanı -->
    <ul id="notificationList" style="list-style:none; padding-left:0; margin:0;">
      <li>🔄 Yükleniyor...</li>
    </ul>
  </div>


  <!-- Alarm & Uyarı Modalı -->
  <div id="widgetAlertModal" style="display:none; position:fixed; top:60px; left:50%; transform:translateX(-50%);background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:420px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:2000;">
    <input type="hidden" id="alertIdHidden">
    <button onclick="closeWidgetAlertModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:18px; cursor:pointer;">✕</button>
    <h3 style="text-align:center;">🔔 Alarm & Uyarı Ayarı</h3>
    <hr>

    <!-- Alarm Türü -->
    <label>Alarm Türü:</label><br>
    <label><input type="radio" name="alertType" value="alarm" checked> Alarm</label>
    <label><input type="radio" name="alertType" value="uyari" style="margin-left:10px;"> Uyarı</label><br><br>

    <!-- Metrik -->
    <label>Metrik:</label><br>
    <select id="metricSelect" style="width:100%; padding:6px; margin-top:4px;">
    <!-- Dinamik olarak doldurulacak -->
    </select><br><br>

    <!-- Koşul -->
    <label>Koşul:</label><br>
    <div style="display:flex; gap:4px; margin-top:4px;">
      <select id="operatorSelect" style="flex:1; padding:6px;">
        <option value=">">&gt;</option>
        <option value="<">&lt;</option>
        <option value="=">=</option>
        <option value="!=">!=</option>
      </select>
      <input type="number" id="valueInput" placeholder="Değer" style="flex:1; padding:6px;">
    </div>
    <br><br>

    <!-- Açıklama -->
    <label>Açıklama:</label><br>
    <textarea id="aciklamaInput" placeholder="Kural için not veya açıklama yazınız" style="width:100%; padding:6px; min-height:60px; resize:vertical;"></textarea>
    <br><br>

    <!-- Bekleme Süresi -->
    <label>Tekrar Tetikleme Bekleme Süresi (dakika):</label><br>
    <input type="number" id="beklemeSuresiInput" placeholder="Örn: 10" style="width:100%; padding:6px;">
    <br><br>

    <!-- Son Gönderim Zamanı -->
    <label>Son Gönderim Zamanı:</label><br>
    <input type="text" id="sonGonderimInput" style="width:100%; padding:6px;" readonly>
    <br><br>

    <!-- Bildirim Kanalları -->
    <label>Bildirim Kanalları:</label><br>
    <label><input type="checkbox" name="channel" value="email"> Email</label><br>
    <label><input type="checkbox" name="channel" value="slack"> Slack</label><br>
    <label><input type="checkbox" name="channel" value="discord"> Discord</label><br>
    <label><input type="checkbox" name="channel" value="sms"> SMS</label><br>
    <label><input type="checkbox" name="channel" value="whatsapp"> WhatsApp</label><br><br>

    <div style="display:flex; gap:10px;">
      <button onclick="submitAlertSettings()" style="flex:1; padding:10px; background:##007bff; color:##fff; border:none; border-radius:4px; cursor:pointer;"> 💾 Kaydet </button>
      <button onclick="deleteAlert()" style="flex:1; padding:10px; background:##dc3545; color:##fff; border:none; border-radius:4px; cursor:pointer;"> 🗑 Sil </button>
    </div>
  </div>


  <!---
  <!-- Widget Yöneticisi Butonu -->
  <button id="btnWidgetEkle">🔧 Widget Yöneticisi</button>
  <!---
  <button onclick="saveDashboardLayout()" style="position: relative; z-index: 9999; padding: 8px 14px; background: ##28a745; color: white; border: none; border-radius: 6px;">💾 Kaydet</button>
  --->
  <button onclick="toggleTheme()" style="margin:16px; padding:10px 20px; font-size:15px; position: relative; z-index: 9999; margin-left: 10px; background: ##555; color: white; border: none; border-radius: 6px;">
  🌓 Tema Değiştir
  </button>
  --->

  <!-- Grid Alanı -->
  <div class="grid-stack" style="min-height: 100vh;"></div>
  <div id="toast" style="display:none; position: fixed; top: 100px; right: 20px; background: ##323232; color: ##fff; padding: 12px 20px; border-radius: 6px; box-shadow: 0 2px 6px rgba(0,0,0,0.2); z-index: 9999; font-size: 14px;"></div>

  <script src="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack-all.min.js"></script>
  <script>
    const headRow = document.querySelector("##testTable thead tr");
    const tableBody = document.querySelector("##testTable tbody");
      const grid = GridStack.init({ 
        float: true, 
        cellHeight: 50, 
        margin: 10,
        staticGrid: window.innerWidth <= 768 // mobilde düzenleme kapalı
      });

      // Sayfa açıldığında dashboard kayıtlarını yükle
      dashboardLayout.forEach(item => {
          const widgetEl = document.createElement("div");
          widgetEl.className = "grid-stack-item";
          widgetEl.innerHTML = `
          <div class="grid-stack-item-content">
            <button class="widget-alert-btn" onclick="openWidgetAlertModal(${item.WIDGET_ID},${item.WIDGET_TYPE})" title="Alarm & Uyarı Ayarları" style="background:none; border:none; cursor:pointer; font-size:16px;">🔔</button>
            <button class="close-widget-btn" onclick="removeWidget(this)">×</button>
            <span class="widget-title" contenteditable="true">${item.CUSTOM_TITLE || "Başlıksız"}</span><br>
            <input type="hidden" class="widget-id-hidden" value="${item.WIDGET_ID}">
            <iframe src="${item.FILE_PATH}" width="100%" height="260" frameborder="0" style="margin-top: 8px; border-radius: 8px;" onload="resizeIframe(this)"></iframe>
          </div>`;

          grid.addWidget(widgetEl, {
          x: item.POSITION_X,
          y: item.POSITION_Y,
          w: item.WIDTH,
          h: item.HEIGHT,
          autoPosition: true // otomatik olarak boş yere yerleştir
          });
      });

    function removeWidget(button) {
        const item = button.closest(".grid-stack-item");
        grid.removeWidget(item);
        grid.compact(); // <--- Bu satır önemli
        autoSaveDashboard();
    }

    function resizeIframe(iframe) {
        try {
        const doc = iframe.contentDocument || iframe.contentWindow.document;
        if (doc && doc.body) {
            iframe.style.height = doc.body.scrollHeight + "px";
        }
        } catch (e) {
        console.warn("iframe erişimi kısıtlı olabilir:", e);
        }
    }

    const modal = document.getElementById("widgetModal");
    const add_dashboard_modal = document.getElementById("addDashboardModal");
    const btn = document.getElementById("btnWidgetEkle");
    const btn_addd_dashboard = document.getElementById("btnDashboardEkle");
    const widgetList = document.getElementById("widgetList");

    btn.addEventListener("click", () => {
      modal.style.display = modal.style.display === "block" ? "none" : "block";
    });

    btn_addd_dashboard.addEventListener("click", () => {
      add_dashboard_modal.style.display = add_dashboard_modal.style.display === "block" ? "none" : "block";
    });


    function closeWidgetModal() {
      document.getElementById("widgetModal").style.display = "none";
    }

    function closeaddDashboardModal() {
      document.getElementById("addDashboardModal").style.display = "none";
    }

  // Basit kaçış (onclick içinde güvenli aktarım)
    const esc = (s='') => String(s)
      .replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;')
      .replace(/"/g,'&quot;').replace(/'/g,'&##39;').replace(/`/g,'&##96;');

    function renderWidgetSelector() {
      const listContainer = document.getElementById("widgetList");
      listContainer.innerHTML = "";

      // tablo iskeleti
      const table = document.createElement("table");
      table.style = "width:100%; border-collapse:collapse;";

      // başlık satırı
      const thead = document.createElement("thead");
      thead.innerHTML = `
        <tr style="border-bottom:2px solid ##ccc;">
          <th style="text-align:left; padding:12px 0;">Widget Adı</th>
          <th style="text-align:left; padding:12px 0;">Widget Türü</th>
          <th style="text-align:left; padding:12px 0;">Modül</th>
          <th style="text-align:right; padding:12px 0;">*</th>
        </tr>
      `;
      table.appendChild(thead);

      const tbody = document.createElement("tbody");

      availableWidgets.forEach(w => {
        const tr = document.createElement("tr");
        tr.style = "border-bottom:1px solid ##eee;";

        // 🎯 Tür rozetleri
        let badgeHTML = "";
        if (w.WIDGET_TYPE === 1) {
          badgeHTML = `<span class="badge_dashbaord badge-system">🧩 Sistem</span>`;
        } else if (w.WIDGET_TYPE === 2) {
          badgeHTML = `<span class="badge_dashbaord badge-custom">🌐 Outsource</span>`;
        } else if (w.WIDGET_TYPE === 3) {
          badgeHTML = `<span class="badge_dashbaord badge-sql">🧠 SQL</span>`;
        } else if (w.WIDGET_TYPE === 4) {
          badgeHTML = `<span class="badge_dashbaord badge-nocode">✨ No Code</span>`;
        }

        // ✏️ Düzenleme butonu
        let badgePen = "";
        if (w.WIDGET_TYPE === 2) {
          badgePen = `<button onclick="openEditWidgetModal(${w.ID}, '${esc(w.NAME)}', '${esc(w.PATH)}')" title="Düzenle" style="border:none; background:none; cursor:pointer;">✏️</button>`;
        } else if (w.WIDGET_TYPE === 3) {
          badgePen = `<button onclick="openSQLWidgetModal('edit', ${w.ID})" title="Düzenle" style="border:none; background:none; cursor:pointer;">✏️</button>`;
        } else if (w.WIDGET_TYPE === 4) {
          badgePen = `<button onclick="window.openWidgetBuilder('edit', ${w.ID})" title="Düzenle" style="border:none; background:none; cursor:pointer;">✏️</button>`;
        }

        // ortak hücre stili
        const cellStyle = "padding:12px 0; vertical-align:middle;";

        // sütunlar
        const tdName = document.createElement("td");
        tdName.style = cellStyle;
        tdName.textContent = w.NAME || "";

        const tdBadge = document.createElement("td");
        tdBadge.style = cellStyle;
        tdBadge.innerHTML = badgeHTML;

        const tdEdit = document.createElement("td");
        tdEdit.style = cellStyle;
        tdEdit.innerHTML = badgePen || `<span style="opacity:.6;"></span>`;

        const tdAdd = document.createElement("td");
        tdAdd.style = "padding:12px 0; vertical-align:middle; text-align:right;";
        tdAdd.innerHTML = `<button style="background:##28a745; color:white; border:none; border-radius:6px; cursor:pointer;" onclick="addWidgetFromDB('${esc(w.NAME)}', '${esc(w.PATH)}', ${w.ID})">Ekle</button>`;

        tr.appendChild(tdName);
        tr.appendChild(tdBadge);
        tr.appendChild(tdEdit);
        tr.appendChild(tdAdd);
        tbody.appendChild(tr);
      });

      table.appendChild(tbody);
      listContainer.appendChild(table);
    }

    function openEditWidgetModal(id, title, filePath) {
      document.getElementById('editWidgetId').value = id;
      document.getElementById('editWidgetTitle').value = title;

      // URL parametresini çek
      const urlParam = new URLSearchParams(filePath.split('?')[1]).get('url');
      document.getElementById('editWidgetURL').value = decodeURIComponent(urlParam);
      document.getElementById('editCustomWidgetModal').style.display = 'block';
    }

    function closeEditWidgetModal() {
      document.getElementById('editCustomWidgetModal').style.display = 'none';
    }

    function addWidgetFromDB(title, path, widgetId) {
      const widgetEl = document.createElement("div");
      widgetEl.className = "grid-stack-item";
      widgetEl.dataset.widgetid = widgetId;
      widgetEl.innerHTML = `
          <div class="grid-stack-item-content">
            <button class="close-widget-btn" onclick="removeWidget(this)">×</button>
            <span class="widget-title" contenteditable="true">${title}</span><br>
            <input type="hidden" class="widget-id-hidden" value="${widgetId}">
            <iframe src="${path}" width="100%" height="260" frameborder="0" style="margin-top: 8px; border-radius: 8px;" onload="resizeIframe(this)"></iframe>
          </div>`;

      grid.addWidget(widgetEl, { w: 4, h: 7 });
      autoSaveDashboard();
    }

      document.addEventListener('blur', function (e) {
          if (e.target.classList.contains('widget-title')) {
              autoSaveDashboard();
          }
      }, true);

      document.getElementById("btnWidgetEkle").addEventListener("click", () => {
          renderWidgetSelector();
          document.getElementById("widgetModal").style.display = "block";
      });

    function getCurrentLayout() {
      const layout = [];
      document.querySelectorAll(".grid-stack .grid-stack-item").forEach((el, index) => {
          const node = el.gridstackNode;
          const title = el.querySelector(".widget-title")?.textContent?.trim() || "Başlıksız";
          
          const hiddenInput = el.querySelector("input.widget-id-hidden");
          const widgetid = hiddenInput ? parseInt(hiddenInput.value) : 99;

          layout.push({
              WIDGET_ID: widgetid,
              CUSTOM_TITLE: title,
              POSITION_X: node.x,
              POSITION_Y: node.y,
              WIDTH: node.w,
              HEIGHT: node.h,
              SORT_ORDER: index
          });
      });
      return layout;
      }   

    function showToast(message, bgColor = "##323232") {
      const toast = document.getElementById("toast");
      toast.textContent = message;
      toast.style.background = bgColor;
      toast.style.display = "block";

      setTimeout(() => {
        toast.style.display = "none";
      }, 2000);
    }
      
    function saveDashboardLayout() {
        const layoutData = getCurrentLayout();
        const dashboardId = new URLSearchParams(window.location.search).get('dashboard_id') || 0;
        //console.log("Kaydedilecek layout", layoutData);
        fetch("/V16/add_options/report/query/save_dashboard_layout.cfm", {
          method: "POST",
          headers: { "Content-Type": "application/json; charset=utf-8" },
          body: JSON.stringify({ 
          layout: layoutData,
          dashboard_id: dashboardId
        })
        })
        .then(async res => {
        const text = await res.text(); // ham haliyle al
        try {
            const json = JSON.parse(text); // JSON olup olmadığını dene
            if (json.SUCCESS) {
              showToast("✔️ Kaydedildi", "##28a745");
            } else {
            //alert("Kaydetme başarısız:\n" + (json.error || "Hata açıklaması yok."));
            showToast("❌ Kaydetme başarısız", "##dc3545");
            console.error("CF cevap:", json);
            }
        } catch (err) {
            console.error("Geçersiz JSON yanıtı:", text); // 👈 Bu bize lazım
            showToast("❌ Kaydetme sırasında beklenmeyen hata", "##ffc107");
        }
        });
    }

    function debounce(func, delay) {
        let timeout;
        return function() {
            clearTimeout(timeout);
            timeout = setTimeout(func, delay);
        };
    }
    const autoSaveDashboard = debounce(saveDashboardLayout, 1000);

    grid.on('change', function() {
      autoSaveDashboard();
    });

    window.addEventListener("message", function (event) {
      if (event.data && event.data.type === "setHeight" && event.source) {
          const iframes = document.querySelectorAll("iframe");
          iframes.forEach(frame => {
          if (frame.contentWindow === event.source) {
              frame.style.height = event.data.height + "px";
          }
          });
      }
      });

      function applyTheme(theme) {
        document.body.classList.remove("light-mode", "dark-mode");
        document.body.classList.add(theme + "-mode");
        sendThemeToIframes(theme); // iframe’lere gönder
      }

      function toggleTheme() {
        const current = localStorage.getItem("dashboardTheme") || "light";
        const next = current === "light" ? "dark" : "light";
        localStorage.setItem("dashboardTheme", next);
        applyTheme(next);
      }

      (function initTheme() {
        const savedTheme = localStorage.getItem("dashboardTheme") || "light";
        applyTheme(savedTheme);
      })();

      function sendThemeToIframes(theme) {
        document.querySelectorAll("iframe").forEach(iframe => {
          iframe.contentWindow.postMessage({ type: "setTheme", theme: theme }, "*");
        });
      }

      const menu = document.getElementById('rightMenu');
      const menuToggleBtn = document.getElementById('menuToggleBtn');

      menuToggleBtn.addEventListener('click', () => {
          menu.classList.toggle('open');
          /*
          // Menü açıldıysa butonu sağa kaydır
          if(menu.classList.contains('open')) {
              menuToggleBtn.style.right = '250px';
          } else {
              menuToggleBtn.style.right = '0';
          }
          */
      });

      // Dashboard Ekle Modal form submit
      document.getElementById('dashboardAddForm').addEventListener('submit', function(e){
      e.preventDefault();
      const formData = new FormData(this);
      fetch("/V16/add_options/report/query/add_dashboard.cfm", {
          method: 'POST',
          body: formData
      })
      .then(res => res.json())
      .then(data => {
          if(data.SUCCESS){
              closeaddDashboardModal();
              showToast("✔️ Dashboard oluşturuldu", "##28a745");
              refreshDashboardMenu();
              // Menüye yeni dashboard'u ekleyelim
              const list = document.getElementById('dashboardList');
              const li = document.createElement('li');
              li.className = 'menu-item';
              li.dataset.id = data.NEW_ID;
              li.innerText = formData.get('dashboard_name');
              list.insertBefore(li, list.querySelector('.add-dashboard'));
              // Yeni dashboard'a geçiş
              //window.location = `<cfoutput>#request.self#</cfoutput>?fuseaction=report.holistic_live_dashboard&dashboard_id=${data.NEW_ID}`;
          } else {
              showToast("❌ Dashboard oluşturulamadı", "##dc3545");
          }
      })
      .catch(err => {
          console.error(err);
          showToast("❌ Sunucu hatası", "##dc3545");
      });
      });
      bindDashboardMenuClicks();
      function bindDashboardMenuClicks() {
        document.querySelectorAll('##dashboardList .menu-item[data-id]').forEach(item => {
            item.addEventListener('click', function () {
                const id = this.getAttribute('data-id');
                window.location = `#request.self#?fuseaction=report.holistic_live_dashboard&dashboard_id=${id}`;
            });
        });
      }
  </script>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script>
    window.SQL_EDIT_SNAPSHOT = null;
    function exportDashboardAsPDF() {
      const dashboard = document.querySelector('.grid-stack'); // veya asıl dashboard id/classı
      html2canvas(dashboard).then(canvas => {
        const imgData = canvas.toDataURL('image/png');
        const pdf = new window.jspdf.jsPDF({
          orientation: 'landscape',
          unit: 'px',
          format: [canvas.width, canvas.height]
        });
        pdf.addImage(imgData, 'PNG', 0, 0, canvas.width, canvas.height);
        pdf.save('dashboard.pdf');
      });
    }
    const dashboardId = new URLSearchParams(window.location.search).get('dashboard_id') || 0;
    document.querySelector('.settings-btn').addEventListener('click', function() {
      openEditDashboardModal(dashboardId);
    });

    function openEditDashboardModal(dashboardId) {
      fetch("/V16/add_options/report/query/get_dashboard.cfm?dashboard_id=" + dashboardId)
        .then(response => {
          if (!response.ok) throw new Error("Dashboard bilgisi getirilemedi.");
          return response.json();
        })
        .then(data => {
          if (data.error) {
            //alert("Dashboard bulunamadı!");
            showToast("✔️ Dashboard Bulunamadı", "##28a745");
            return;
          }

          // Inputlara dashboard verilerini yaz
          document.getElementById('edit_dashboard_id').value = data.id || '';
          document.getElementById('edit_dashboard_name').value = data.name || '';
          document.getElementById('edit_module_id').value = data.module_id || '';
          document.getElementById('edit_is_favorite').checked = !!data.is_favorite;
          document.getElementById('edit_is_public').checked = !!data.is_public;

          // Modalı aç
          document.getElementById('editDashboardModal').style.display = 'block';
        })
        .catch(err => {
          alert("Dashboard bilgisi alınamadı: " + err.message);
        });
    }

    // Modalı kapatmak için (örnek)
    function closeEditDashboardModal() {
      document.getElementById('editDashboardModal').style.display = 'none';
    }

    document.getElementById('dashboardEditForm').onsubmit = function(e) {
      e.preventDefault(); // Sayfa yenilenmesin

      // Form inputlarını al
      const dashboard_id = document.getElementById('edit_dashboard_id').value;
      const dashboard_name = document.getElementById('edit_dashboard_name').value;
      const m_id = document.getElementById('edit_module_id').value;
      const is_favorite = document.getElementById('edit_is_favorite').checked ? 1 : 0;
      const is_public = document.getElementById('edit_is_public').checked ? 1 : 0;

      // JSON objesi hazırlama (veya urlencoded data, backend’e göre)
      const formData = {
        dashboard_id,
        dashboard_name,
        m_id,
        is_favorite,
        is_public
      };
      //console.log(formData.dashboard_id);
      fetch("/V16/add_options/report/query/update_dashboard.cfm", {
        method: 'POST',
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(formData)
      })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            showToast("✔️ Dashboard başarıyla güncellendi!", "##28a745");
            closeEditDashboardModal();
            refreshDashboardMenu();
            // Ekrandaki bilgileri yenilemek için burada bir fonksiyon çağırabilirsin
          } else {
            alert("Dashboard güncellenemedi: " + (data.error || "Bilinmeyen hata"));
          }
        })
        .catch(err => {
          alert("Güncelleme sırasında hata: " + err.message);
        });
      };

    function deleteDashboard() {
      if (!confirm("Dashboard'u silmek istediğinize emin misiniz?")) return;
      const dashboard_id = document.getElementById('edit_dashboard_id').value;
      fetch('/V16/add_options/report/query/delete_dashboard.cfm', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ dashboard_id })
      })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            showToast("✔️ Dashboard başarıyla silindi!", "##DC3545");
            refreshDashboardMenu();
            closeEditDashboardModal();
            //window.location = `#request.self#?fuseaction=report.holistic_live_dashboard`;
            // Ekranı güncelle, listeden silinen dashboard'u çıkar
            // refreshDashboards(); // örnek bir fonksiyon
          } else {
            alert("Silme işlemi başarısız: " + (data.error || "Bilinmeyen hata"));
          }
        })
        .catch(err => {
          alert("Silme sırasında hata: " + err.message);
        });
    }
    // Modal Aç
    function openCustomWidgetModal() {
        document.getElementById('addCustomWidgetModal').style.display = 'block';
        document.getElementById('customWidgetOverlay').style.display = 'block';
    }

    // Modal Kapat
    function closeCustomWidgetModal() {
        document.getElementById('addCustomWidgetModal').style.display = 'none';
        document.getElementById('customWidgetOverlay').style.display = 'none';
    }

    // Widget Kaydet
    function saveCustomWidget(){
      const title = document.getElementById('customWidgetTitle').value.trim();
      const url = document.getElementById('customWidgetURL').value.trim();

      if (!title || !url) {
          showToast("❌ Lütfen başlık ve URL giriniz!", "##DC3545");
          return;
      }

      const newWidget = {
          widget_id: "custom_" + Date.now(),
          type: "iframe",
          title: title,
          src: url,
          pos: { x: 0, y: 0 }
      };

      //console.log("Yeni Widget:", newWidget);

      // 🟩 BACKEND’E GÖNDER
      
      fetch("/V16/add_options/report/query/save_custom_widget.cfm", {
          method: "POST",
          headers: { "Content-Type": "application/json; charset=UTF-8" },
          body: JSON.stringify(newWidget)
      })
      .then(response => response.json())
      .then(data => {
          if (data.success) {
              showToast("✔️ Widget Başarıyla Kaydedildi", "##28a745");
          } else {
              alert("Hata: " + data.message);
          }
      })
      .catch(error => {
          alert("İletişim hatası: " + error.message);
      });

      // Form temizle + modal kapat
      document.getElementById('customWidgetForm').reset();
      closeCustomWidgetModal();
    }
    function saveEditedWidget() {
      const id = document.getElementById('editWidgetId').value;
      const title = document.getElementById('editWidgetTitle').value.trim();
      const url = document.getElementById('editWidgetURL').value.trim();

      if (!title || !url) {
        //alert("Başlık ve URL zorunlu!");
        showToast("❌ Başlık ve URL Zorunlu !", "##DC3545");
        return;
      }

      const data = {
        widget_id: id,
        title: title,
        src: url
      };

      fetch("/V16/add_options/report/query/update_custom_widget.cfm", {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(data)
      })
      .then(r => r.json())
      .then(res => {
        showToast("✔️ Widget Güncellendi!", "##28A745");
        if (res.success) location.reload();
      });
    }
    function deleteWidget() {
      const id = document.getElementById('editWidgetId').value;
      if (!confirm("Bu widget'ı silmek istediğine emin misin?")) return;

      fetch("/V16/add_options/report/query/delete_custom_widget.cfm", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ widget_id: id })
      })
      .then(r => r.json())
      .then(res => {
        showToast("✔️ Widget Silindi!", "##DC3545");
        if (res.success) location.reload();
      });
    }
    function refreshDashboardMenu() {
      fetch('/V16/add_options/report/query/dashboard_menu_list.cfm')
        .then(response => response.text())
        .then(html => {
            document.getElementById('dashboardList').innerHTML = html;
            bindDashboardMenuClicks();
        })
        .catch(error => {
            console.error('Menü güncellenemedi:', error);
        });
    }

    document.getElementById("metricSelect").addEventListener("change", () => {
      const widgetId = document.getElementById("widgetAlertModal").dataset.widgetId;
      const metric = document.getElementById("metricSelect").value;
      if (metric) {
        loadExistingAlertSettings(widgetId, metric);
      }
    });

    let currentWidgetId = null;
    // SQL=3, NoCode=4
    async function openWidgetAlertModal(widgetId, widgetType) {
      const modal = document.getElementById("widgetAlertModal");
      const metricSelect = document.getElementById("metricSelect");

      // 1) modal state
      modal.dataset.widgetId = widgetId;
      modal.dataset.widgetType = widgetType;   // 👈 önemli
      modal.dataset.dashboardId = (typeof dashboardId !== "undefined" ? dashboardId : "");

      // 2) UI reset (temiz açılış)
      document.getElementById("alertIdHidden").value = "";
      document.querySelector('input[name="alertType"][value="alarm"]').checked = true;
      document.getElementById("operatorSelect").value = ">";
      document.getElementById("valueInput").value = "";
      // kanallar reset
      document.querySelectorAll('##widgetAlertModal input[name="channel"]').forEach(cb => cb.checked = false);

      // 3) metrikleri doldur (tipine göre)
      try {
        const fields = await populateMetricSelect(widgetId, widgetType); // 👈 az önce ayırdığımız fonksiyon
        // 4) varsa ilk metrik için mevcut ayarı yükle
        if (Array.isArray(fields) && fields.length > 0) {
          // metricSelect zaten dolduruldu; seçili değeri al
          const selectedMetric = metricSelect.value;
          await loadExistingAlertSettings(widgetId, selectedMetric, widgetType); // 👈 widgetType'ı da iletelim
        } else {
          // hiç metrik yoksa alanları kilitle
          document.getElementById("operatorSelect").disabled = true;
          document.getElementById("valueInput").disabled = true;
        }
      } catch (e) {
        console.error("populateMetricSelect error:", e);
      }

      // 5) metrik değişince mevcut ayarı yeniden yükle
      metricSelect.onchange = async () => {
        const metric = metricSelect.value;
        await loadExistingAlertSettings(widgetId, metric, widgetType);
      };

      // 6) göster
      modal.style.display = "block";
    }

    function populateMetricSelectSql(widgetId) {
      return new Promise((resolve, reject) => {
        // Burada backend'den kolon listesi çekilecek
        // Örn: /v16/add_options/report/query/get_sql_fields.cfm?widgetId=123&type=sql
        fetch(`/v16/add_options/report/query/get_sql_fields.cfm?widgetId=${widgetId}&type=sql`)
          .then(res => res.json())
          .then(fields => {
            const select = document.getElementById("metricSelect");
            select.innerHTML = "";
            fields.forEach(f => {
              const opt = document.createElement("option");
              opt.value = f.id;
              opt.textContent = f.label;
              select.appendChild(opt);
            });
            resolve(fields);
          })
          .catch(reject);
      });
    }

    function populateMetricSelect(widgetId, widgetType) {
      return new Promise((resolve, reject) => {
        if (widgetType == 3) {
          // SQL widget
          populateMetricSelectSql(widgetId).then(resolve).catch(reject);
        } else if (widgetType == 4) {
          // NoCode widget
          populateMetricSelectNoCode(widgetId).then(resolve).catch(reject);
        } else {
          resolve([]); // diğer tiplerde boş liste
        }
      });
    }

    document.getElementById("metricSelect").addEventListener("change", () => {
      const widgetId = document.getElementById("widgetAlertModal").dataset.widgetId;
      const metric = document.getElementById("metricSelect").value;
      loadExistingAlertSettings(widgetId, metric);
    });

    function closeWidgetAlertModal() {
      document.getElementById("widgetAlertModal").style.display = "none";
    }

    function submitAlertSettings() {
      const modal = document.getElementById("widgetAlertModal");
      const widgetId   = modal.dataset.widgetId;
      const widgetType = modal.dataset.widgetType || 3; // 3=SQL, 4=NoCode (ileride)
      const dashId     = modal.dataset.dashboardId || (typeof dashboardId !== "undefined" ? dashboardId : "");

      const alertId    = document.getElementById("alertIdHidden").value || null;
      const alertType  = document.querySelector('input[name="alertType"]:checked').value;
      const metric     = document.getElementById("metricSelect").value;
      const operator   = document.getElementById("operatorSelect").value;
      const valueRaw   = document.getElementById("valueInput").value;

      // yeni alanlar
      const description     = document.getElementById("aciklamaInput")?.value || "";
      const cooldownMinutes = document.getElementById("beklemeSuresiInput")?.value || "";

      // kanallar
      const channels = Array.from(document.querySelectorAll('##widgetAlertModal input[name="channel"]:checked')).map(el => el.value);

      // --- basit validasyonlar ---
      if (!metric) { alert("Lütfen bir metrik seçin."); return; }
      if (!operator) { alert("Lütfen bir operatör seçin."); return; }
      if (valueRaw === "" || valueRaw === null) { alert("Lütfen bir değer girin."); return; }
      const valueNum = Number(valueRaw);
      if (Number.isNaN(valueNum)) { alert("Değer sayısal olmalı."); return; }

      // cooldown integer olmalı (boşsa null gönderelim)
      let cd = null;
      if (cooldownMinutes !== "") {
        const cdNum = parseInt(cooldownMinutes, 10);
        if (Number.isNaN(cdNum) || cdNum < 0) { alert("Bekleme süresi (dakika) 0 veya pozitif tam sayı olmalı."); return; }
        cd = cdNum;
      }

      // payload — backend'in JSON beklediğini varsayıyoruz
      const alertData = {
        alertId,                 // null → insert, dolu → update
        widgetId,
        widgetType,              // şimdilik 3
        dashboardId: dashId,
        alertType,               // 'alarm' | 'uyari'
        metric,                  // METRIC_NAME
        operator,                // CONDITION_OPERATOR
        value: valueNum,         // CONDITION_VALUE (number)
        channels,                // ["email","slack",...]
        description,             // DESCRIPTION
        cooldownMinutes: cd      // COOLDOWN_MINUTES (null | int)
        // lastSentAt gönderME — sadece backend günceller/gösterir
      };
      console.log(alertData);
      fetch('/V16/add_options/report/query/save_alert.cfm', {
        method: 'POST',
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify(alertData)
      })
      .then(r => r.json())
      .then(res => {
        if (res && res.ok === false) {
          alert("Kaydetme sırasında hata: " + (res.error || "Bilinmeyen hata"));
          return;
        }
        alert("Alarm/Uyarı başarıyla kaydedildi.");
        closeWidgetAlertModal();
      })
      .catch(err => {
        console.error("Hata:", err);
        alert("Bir hata oluştu.");
      });
  }

  function loadNotifications(type = "unread") {
    fetch(`/V16/add_options/report/query/get_notifications.cfm?type=${type}`)
      .then(res => res.json())
      .then(data => {
        const list = document.getElementById("notificationList");
        list.innerHTML = "";

        if (!data || data.length === 0) {
          list.innerHTML = `<li>📭 ${type === "unread" ? "Yeni bildirim yok." : "Okunmuş bildirim yok."}</li>`;
          return;
        }

        data.forEach(item => {
        const li = document.createElement("li");
        li.style.padding = "6px 0";
        li.style.borderBottom = "1px solid ##eee";

        // Zarf butonuna göre ikon ve tooltip
        const isUnread = type === "unread";
        const icon = isUnread ? "✉️" : "📪";
        const tooltip = isUnread ? "Okundu olarak işaretle" : "Yeniden okunmadı yap";

        li.innerHTML = `<div style="display:flex; justify-content:space-between; align-items:flex-start;">
            <div>
              🛎️ <b>${item.MESSAGE}</b><br><small>${item.DATE}</small>
            </div>
            <button title="${tooltip}" onclick="toggleReadStatus(${item.LOG_ID}, ${isUnread})" 
              style="background:none; border:none; cursor:pointer; font-size:16px;">${icon}</button>
          </div>
        `;

        list.appendChild(li);
      });
            });
        }
    function updateNotificationBadge() {
      fetch("/V16/add_options/report/query/get_notifications.cfm")
        .then(res => res.json())
        .then(data => {
          const count = data.filter(x => x.IS_READ === 0).length;
          const badge = document.getElementById("notificationCount");
          if (count > 0) {
            badge.innerText = count;
            badge.style.display = "inline-block";
          } else {
            badge.style.display = "none";
          }
        })
        .catch(console.error);
    }
    document.addEventListener("DOMContentLoaded", function () {
      updateNotificationBadge(); // 🟡 Sayfa açılır açılmaz çağrılır
    });

    function toggleNotificationPanel() {
      const panel = document.getElementById("notificationPanel");
      if (panel.style.display === "none" || panel.style.display === "") {
        loadNotifications(); // 👈 Listeyi yükle
        panel.style.display = "block";

        // ✅ Okundu olarak işaretle
        fetch("/V16/add_options/report/query/mark_alerts_as_read.cfm", { method: "POST" })
          .then(() => {
            // Badge'i sıfırla
            const badge = document.getElementById("notificationCount");
            badge.style.display = "none";
          });
      } else {
        panel.style.display = "none";
      }
    }
  
    function switchAlertTab(type) {
      // Sekme stilini ayarla
      document.getElementById("tab-unread").classList.remove("active-tab");
      document.getElementById("tab-read").classList.remove("active-tab");
      document.getElementById("tab-" + type).classList.add("active-tab");

      // Listeyi yeniden yükle
      loadNotifications(type);
    }

    function toggleReadStatus(logId, isUnread) {
      const newStatus = isUnread ? 1 : 0;
      fetch("/V16/add_options/report/query/update_alert_read_status.cfm", {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify({ logId: logId, isRead: newStatus })
      })
      .then(res => res.json())
      .then(res => {
        //console.log(res); // debug
        const currentTab = document.querySelector(".active-tab").id.replace("tab-", "");
        loadNotifications(currentTab); // Sekmeye göre yeniden yükle
        updateNotificationBadge();     // Sayacı da güncelle
      });
    }

    // Seçili metrik için kayıtlı kuralları getirir ve mevcut modal alanlarını doldurur.
    // Ekstra HTML eklemez, sadece formu set eder.
    async function loadExistingAlertSettings(widgetId, metric, widgetType = 3) {
    const modal = document.getElementById("widgetAlertModal");
    const dashId = modal?.dataset?.dashboardId || "";

    // --- yardımcılar ---
    const resetForm = () => {
      document.getElementById("alertIdHidden").value = "";
      // varsayılanlar
      const alarmRadio = modal.querySelector('input[name="alertType"][value="alarm"]');
      if (alarmRadio) alarmRadio.checked = true;
      const opSel = document.getElementById("operatorSelect");
      if (opSel) opSel.value = ">";
      const valInp = document.getElementById("valueInput");
      if (valInp) valInp.value = "";
      modal.querySelectorAll('input[name="channel"]').forEach(cb => (cb.checked = false));

      // yeni alanları sıfırla
      const desc = document.getElementById("aciklamaInput");
      if (desc) desc.value = "";
      const cd = document.getElementById("beklemeSuresiInput");
      if (cd) cd.value = "";
      const lastSent = document.getElementById("sonGonderimInput");
      if (lastSent) lastSent.value = "";
    };

    const fillForm = (rule) => {
      console.log(rule);
      document.getElementById("alertIdHidden").value = rule?.RULEID || rule?.ruleId || "";

      // alarm/uyarı
      const at = rule?.ALERTTYPE || rule?.alertType || "alarm";
      const radio = modal.querySelector(`input[name="alertType"][value="${at}"]`);
      if (radio) radio.checked = true;

      // operatör & değer
      const opSel = document.getElementById("operatorSelect");
      if (opSel) opSel.value = rule?.OPERATOR || rule?.operator || ">";
      const valInp = document.getElementById("valueInput");
      if (valInp) valInp.value = (rule?.VALUE ?? rule?.value ?? "");

      // kanallar (hem array hem kolon-bool şemalarını destekle)
      let selected = [];
      if (Array.isArray(rule?.CHANNELS || rule?.channels)) {
        selected = rule.CHANNELS || rule.channels;
      } else {
        const map = {
          email: rule?.CHANNEL_EMAIL ?? rule?.channel_email,
          slack: rule?.CHANNEL_SLACK ?? rule?.channel_slack,
          discord: rule?.CHANNEL_DISCORD ?? rule?.channel_discord,
          sms: rule?.CHANNEL_SMS ?? rule?.channel_sms,
          whatsapp: rule?.CHANNEL_WHATSAPP ?? rule?.channel_whatsapp,
        };
        selected = Object.keys(map).filter(k => String(map[k]) === "1");
      }
      modal.querySelectorAll('input[name="channel"]').forEach(cb => {
        cb.checked = selected.includes(cb.value);
      });

      // açıklama
      const desc = document.getElementById("aciklamaInput");
      if (desc) desc.value = rule?.DESCRIPTION || rule?.description || "";

      // bekleme süresi
      const cd = document.getElementById("beklemeSuresiInput");
      if (cd) cd.value = rule?.COOLDOWN_MINUTES ?? rule?.cooldownMinutes ?? "";

      // son gönderim zamanı (readonly)
      const lastSent = document.getElementById("sonGonderimInput");
      if (lastSent) {
        lastSent.value = rule?.LAST_SENT_AT || rule?.lastSentAt || "";
      }
    };

    // --- veriyi çek ---
    const qs =
      `widgetId=${encodeURIComponent(widgetId)}` +
      `&metricName=${encodeURIComponent(metric || "")}` +
      (dashId ? `&dashboardId=${encodeURIComponent(dashId)}` : "") +
      (widgetType ? `&widgetType=${encodeURIComponent(widgetType)}` : "");

    let rules = [];
    try {
      const res = await fetch(`/v16/add_options/report/query/get_alert.cfm?${qs}`);
      rules = await res.json(); // beklenen: [{...}, ...] veya []
    } catch (err) {
      console.error("get_alert.cfm fetch error:", err);
      rules = [];
    }

    // --- formu güncelle ---
    if (Array.isArray(rules) && rules.length > 0) {
      fillForm(rules[0]); // ilk kuralı basıyoruz
    } else {
      resetForm();
    }
  }



    function closeWidgetAlertModal() {
      document.getElementById("widgetAlertModal").style.display = "none";
      // Temizlik istersen burada yapılır
    }

    function deleteAlert() {
      const modal = document.getElementById("widgetAlertModal");
      const dashboardId = modal.dataset.dashboardId;
      const widgetId    = modal.dataset.widgetId;
      const metric      = document.getElementById("metricSelect").value;

      // 3 farklı kaynaktan sırayla oku
      let alertId =
        modal?.dataset?.alertId ||
        document.getElementById("alertIdHidden")?.value ||
        window.currentAlertId;

      // temizle
      if (alertId === "null" || alertId === "undefined") alertId = "";

      if (!confirm("Bu alarm/uyarı tamamen silinecek. Emin misiniz?")) return;

      // ALERT_ID varsa onu gönder; yoksa dashboardId+widgetId+metric ile ilerle (hibrit destek)
      const payload = 
        { 
          alertId: Number(alertId), 
          dashboardId: Number(dashboardId), 
          widgetId: Number(widgetId), 
          metric 
        };
        //console.log(payload);
      fetch('/V16/add_options/report/query/delete_alert.cfm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
      .then(r => r.json())
      .then(res => {
        if (res.error) throw new Error(res.message || "Silinemedi");
        showToast("✔️ Alarm/Uyarı silindi!", "##DC3545");
        // modal state’i temizle
        modal.dataset.alertId = "";
        window.currentAlertId = null;
        const hid = document.getElementById("alertIdHidden");
        if (hid) hid.value = "";
        closeWidgetAlertModal();
        // (opsiyonel) widget rozeti/ikonu güncelle
        // loadWidgetAlerts(Number(widgetId));
      })
      .catch(err => {
        console.error("deleteAlert error:", err);
        showToast("❌ Silme sırasında hata oluştu.", "##dc3545");
      });
    }
    var cmSqlEditor = null;

    function initSQLCodeEditor() {
      if (cmSqlEditor) return cmSqlEditor; // tekrar kurma

      var textarea = document.getElementById("sqlQuery");
      cmSqlEditor = CodeMirror.fromTextArea(textarea, {
        mode: "text/x-mssql",          // MS SQL Server vurgusu
        lineNumbers: true,
        matchBrackets: true,
        indentUnit: 2,
        tabSize: 2,
        indentWithTabs: false,
        lineWrapping: true,
        autofocus: false,
        theme: (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? "darcula" : "default",
        placeholder: "SELECT CITY, SUM(TOTAL) AS TOTAL_SALES FROM ORDERS GROUP BY CITY",
        extraKeys: {
          "Ctrl-Enter": function(cm){ handleSQLWidgetSave(); },
          "Cmd-Enter":  function(cm){ handleSQLWidgetSave(); },
          "Tab": function(cm){
            if (cm.somethingSelected()) cm.indentSelection("add");
            else cm.replaceSelection("  ", "end");
          }
        }
      });

      // İlk boyut
      cmSqlEditor.setSize("100%", "220px");

      // Modal açılınca yeniden hesapla (önemli)
      setTimeout(function(){
        cmSqlEditor.refresh();
      }, 0);

      return cmSqlEditor;
    }



    function closeColumnRoleModal() {
      document.getElementById("columnRoleModal").style.display = "none";
    }
    /*
    selectedColumns.push({
      id: "3",
      name: "OTHER_MONEY_VALUE",
      label: "Sipariş Tutarı",
      dataType: "numeric",
      roleHint: "measure"
    });
    */

  let selectedChartType = "bar"; // varsayılan olarak çubuk grafik

  function goToTestChartModal() {
    selectedChartType = document.getElementById("chartTypeSelect").value;
    //console.log("📌 Seçilen grafik tipi:", selectedChartType);
    // 1. Seçilen kolonları al
    const rows = document.querySelectorAll(".column-row");
    const selectedColumns = Array.from(rows).map(row => {
      const colId = row.dataset.columnId;
      const label = row.querySelector("td").innerText;
      return { id: colId, label };
    });

    //console.log("🧪 Seçilen Kolonlar:", selectedColumns);

    // 2. Modal'daki tabloya başlıkları yerleştir
    const headRow = document.querySelector("##testChartModal table thead tr");
    const body = document.querySelector("##testChartModal table tbody");
    if (!headRow || !body) {
      console.error("❌ Tablo alanı bulunamadı!");
      return;
    }

    headRow.innerHTML = "";
    body.innerHTML = "";

    selectedColumns.forEach(col => {
      const th = document.createElement("th");
      th.textContent = col.label;
      headRow.appendChild(th);
    });

    // 3. Rastgele veri ile satırları oluştur
    for (let i = 0; i < 5; i++) {
        const tr = document.createElement("tr");
        selectedColumns.forEach(col => {
          const td = document.createElement("td");
          td.textContent = `${col.label} ${i + 1}`;
          tr.appendChild(td);
        });
        body.appendChild(tr);
      }

      // 4. Grafik önizlemesi oluştur
      const chartPreview = document.getElementById("chartPreview");
      chartPreview.innerHTML = '<canvas id="testChartCanvas" height="250"></canvas>';

      const ctx = document.getElementById("testChartCanvas").getContext("2d");

      // Önceki grafik varsa yok et
      if (window.testChartInstance) {
        window.testChartInstance.destroy();
      }

      // 5. Yeni grafik çiz
      const labels = Array.from({ length: 5 }, (_, i) => `Veri ${i + 1}`);
      const datasets = selectedColumns.map((col, index) => {
        return {
          label: col.label,
          data: Array.from({ length: 5 }, () => Math.floor(Math.random() * 1000)),
          backgroundColor: `rgba(${50 + index * 50}, 100, 200, 0.6)`
        };
    });

    window.testChartInstance = new Chart(ctx, {
      type: selectedChartType,
      data: {
        labels: labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Demo Grafik Önizleme'
          }
        }
      }
    });

    // 6. Modal'ı göster
    document.getElementById("testChartModal").style.display = "block";
  }
    function getDummyValue(col) {
      switch (col.dataType) {
        case "numeric": return Math.floor(Math.random() * 1000);
        case "date": return `2023-01-${String(Math.floor(Math.random() * 28 + 1)).padStart(2, '0')}`;
        case "text": return "Örnek";
        default: return "-";
      }
    }
    function backToColumnRoleModal() {
      document.getElementById("testChartModal").style.display = "none";
      document.getElementById("columnRoleModal").style.display = "block";
    }

    function closeTestChartModal() {
      document.getElementById("testChartModal").style.display = "none";
    }

    function finalizeWidgetCreation() {
      alert("🎉 Widget başarıyla oluşturuldu!"); 
      // İleride: API çağrısı, modal kapatma, dashboard’a ekleme vs.
      closeTestChartModal();
    }

    function updateDisabledColumns() {
      const allSelects = document.querySelectorAll(".column-role-row select:first-child");

      allSelects.forEach(select => {
        const currentValue = select.value;

        for (const option of select.options) {
          if (option.value === "" || option.value === currentValue) {
            option.disabled = false;
          } else {
            option.disabled = usedColumns.has(option.value);
          }
        }
      });
    }

    function openColumnSelector() {
      selectedColumns = []; // Önceki seçimleri temizle
      const selectedTableIds = [...document.querySelectorAll("##tableSelect option:checked")]
        .map(opt => opt.value);

      if (selectedTableIds.length === 0) {
        alert("Lütfen önce en az bir tablo seçin.");
        return;
      }

      const idList = selectedTableIds.join(",");

      fetch(`/V16/add_options/report/query/getSemanticColumns.cfm?table_ids=${idList}`)
        .then(res => res.json())
        .then(data => {
          const dropdown = document.getElementById("columnDropdown");
          dropdown.innerHTML = "";

          data.forEach(col => {
            const option = document.createElement("option");
            option.value = col[0];
            option.textContent = `${col[5] || col[2]} (${col[2]})`;
            dropdown.appendChild(option);
          });

          document.getElementById("columnSelectorModal").style.display = "block";
        });
    }

    function closeColumnSelector() {
      document.getElementById("columnSelectorModal").style.display = "none";
    }
    function addColumnToTable() {
      const dropdown = document.getElementById("columnDropdown");
      const selectedOptions = [...dropdown.selectedOptions];

      selectedOptions.forEach(option => {
        const selectedId = option.value;
        const selectedText = option.text;

        // Aynı kolon zaten ekli mi?
        if (selectedColumns.some(c => c.id === selectedId)) return;

        // Dizimize ekle
        selectedColumns.push({
          id: selectedId,
          label: selectedText
        });

        // DOM’a satır ekle
        const newRow = document.createElement("tr");
        newRow.classList.add("column-row");
        newRow.dataset.columnId = selectedId;
        newRow.innerHTML = `
          <td>${selectedText}</td>
          <td>
            <button onclick="removeColumnFromTable('${selectedId}', this)">🗑</button>
          </td>
        `;
        document.getElementById("columnsTableBody").appendChild(newRow);
      });

      closeColumnSelector();
    }

    function removeColumnFromTable(columnId, btn) {
      selectedColumns = selectedColumns.filter(col => col.id !== columnId);
      btn.closest("tr").remove();
    }
  </script>
</cfoutput>

<cfinclude  template="semantic_wizard.cfm">
<cfinclude  template="no_code_widget_builder.cfm">
<cfinclude  template="sql_widget_wizard.cfm">