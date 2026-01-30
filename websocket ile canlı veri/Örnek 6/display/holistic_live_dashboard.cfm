<!-- holistic_live_dashboard.cfm (Widget Seçimli - Ayar Panelinden Yönetim, iframe tabanlı) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack.min.css">
<cfquery name="qDashboardLayout" datasource="#DSN#">
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
        D.FILE_PATH -- artık grafik yolu buradan geliyor
    FROM DASHBOARD_USER_LAYOUT L
    INNER JOIN DASHBOARD_WIDGET_DEFS D ON L.WIDGET_ID = D.WIDGET_ID
    WHERE
        L.EMPLOYEE_ID = <cfqueryparam value="#session.ep.userid#" cfsqltype="cf_sql_integer">
        AND L.DASHBOARD_KEY = 'HolisticLiveDashboard'
        AND L.IS_ACTIVE = 1
    ORDER BY L.SORT_ORDER
</cfquery>

<cfquery name="qWidgetDefs" datasource="#DSN#">
    SELECT 
      WIDGET_ID,
      WIDGET_NAME,
      FILE_PATH
    FROM 
        DASHBOARD_WIDGET_DEFS
    WHERE 
        IS_ACTIVE = 1
    ORDER 
        BY WIDGET_NAME
</cfquery>

<cfset arrDashboardLayout = []>
<cfloop query="qDashboardLayout">
  <cfset structItem = {
    ID = qDashboardLayout.ID,
    FILE_PATH = qDashboardLayout.FILE_PATH,
    CUSTOM_TITLE = qDashboardLayout.CUSTOM_TITLE,
    POSITION_X = qDashboardLayout.POSITION_X,
    POSITION_Y = qDashboardLayout.POSITION_Y,
    WIDTH = qDashboardLayout.WIDTH,
    HEIGHT = qDashboardLayout.HEIGHT,
    SORT_ORDER = qDashboardLayout.SORT_ORDER,
    IS_ACTIVE = qDashboardLayout.IS_ACTIVE,
    WIDGET_ID = qDashboardLayout.WIDGET_ID
  }>
  <cfset arrayAppend(arrDashboardLayout, structItem)>
</cfloop>

<cfset arrWidgetDefs = []>
<cfloop query="qWidgetDefs">
  <cfset arrayAppend(arrWidgetDefs, {
    ID: qWidgetDefs.WIDGET_ID,
    NAME: qWidgetDefs.WIDGET_NAME,
    PATH: qWidgetDefs.FILE_PATH
  })>
</cfloop>

<cfoutput>
    <script>
        const dashboardLayout = #serializeJSON(arrDashboardLayout)#;
        const availableWidgets = #serializeJSON(arrWidgetDefs)#;
        //console.log(availableWidgets);
    </script>
</cfoutput>

<cfoutput>
<style>
  body.light-mode {
    background: ##f5f5f5;
    color: ##222;
  }

  body.dark-mode {
    background: ##121212;
    color: ##e0e0e0;
  }

  body.dark-mode .grid-stack-item-content {
    background-color: ##1e1e1e;
    border: 1px solid ##444;
  }

  body.dark-mode .widget-title {
    color: ##e0e0e0;
  }

  body 
  { 
    margin: 0; 
    padding: 0; 
    background: ##f5f5f5; 
    font-family: sans-serif; 
  }
  .grid-stack-item-content {
    background-color: ##fff;
    border: 1px solid ##ccc;
    border-radius: 15px;
    padding: 10px;
    height: 100%;
    text-align: center;
    position: relative;
  }
  .widget-title {
    display: inline-block;
    font-weight: bold;
    font-size: 16px;
    margin-bottom: 6px;
    cursor: text;
  }
  .widget-title[contenteditable="true"]:focus {
    outline: 2px dashed ##007bff;
    background: ##eef7ff;
  }

  .settings-panel button:hover {
    background: ##ddd;
  }
  ##btnWidgetEkle {
    margin: 16px;
    padding: 10px 20px;
    font-size: 15px;
    border: none;
    background-color: ##007bff;
    color: white;
    border-radius: 6px;
    cursor: pointer;
  }
  ##btnWidgetEkle:hover {
    background-color: ##0056b3;
  }
  ##widgetModal {
    position: fixed;
    top: 80px;
    left: 50%;
    transform: translateX(-50%);
    background: ##fff;
    border: 1px solid ##ccc;
    border-radius: 8px;
    padding: 20px;
    width: 500px;
    display: none;
    box-shadow: 0 10px 30px rgba(0,0,0,0.15);
    z-index: 1000;
  }
  ##widgetModal strong {
    font-size: 16px;
    display: block;
    margin-bottom: 10px;
  }
  ##widgetModal .close-btn {
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 18px;
    background: none;
    border: none;
    color: ##888;
    cursor: pointer;
  }
  ##widgetModal .close-btn:hover {
    color: ##000;
  }
  .widget-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 8px 0;
    border-bottom: 1px solid ##eee;
  }
  .widget-item:last-child {
    border-bottom: none;
  }
  .widget-item input[type="text"] {
    flex: 1;
    font-size: 14px;
    padding: 6px;
    border: 1px solid ##ccc;
    border-radius: 4px;
  }
  .widget-item .button-group {
    display: flex;
    gap: 6px;
  }
  .widget-item button {
    padding: 6px 10px;
    font-size: 13px;
    border: none;
    background-color: ##28a745;
    color: white;
    border-radius: 4px;
    cursor: pointer;
  }
  .widget-item button.remove {
    background-color: ##dc3545;
  }
  .widget-item button:hover {
    opacity: 0.85;
  }
  .close-widget-btn {
    position: absolute;
    top: 6px;
    right: 8px;
    z-index: 10;
    background: ##f44336;
    color: white;
    border: none;
    border-radius: 50%;
    width: 24px;
    height: 24px;
    font-size: 16px;
    line-height: 20px;
    cursor: pointer;
  }
  .close-widget-btn:hover {
    background: ##d32f2f;
  }
</style>

<!-- Widget Seçim Paneli -->
<div id="widgetModal" style="display:none; position:fixed; top:80px; left:50%; transform:translateX(-50%); background:##fff; border:1px solid ##ccc; border-radius:8px; padding:20px; width:400px; box-shadow:0 10px 30px rgba(0,0,0,0.15); z-index:1000;">
    <button onclick="closeWidgetModal()" style="position:absolute; top:10px; right:10px; background:none; border:none; font-size:16px; cursor:pointer;">✕</button>
    <strong>Bir Widget Seç:</strong>
    <div id="widgetList"></div>
</div>

<!-- Widget Yöneticisi Butonu -->
<button id="btnWidgetEkle">🔧 Widget Yöneticisi</button>
<!---
<button onclick="saveDashboardLayout()" style="position: relative; z-index: 9999; padding: 8px 14px; background: ##28a745; color: white; border: none; border-radius: 6px;">💾 Kaydet</button>
--->
<button onclick="toggleTheme()" style="margin:16px; padding:10px 20px; font-size:15px; position: relative; z-index: 9999; margin-left: 10px; background: ##555; color: white; border: none; border-radius: 6px;">
🌓 Tema Değiştir
</button>
  

<!-- Grid Alanı -->
<div class="grid-stack" style="min-height: 100vh;"></div>
<div id="toast" style="display:none; position: fixed; top: 60px; right: 20px; background: ##323232; color: ##fff; padding: 12px 20px; border-radius: 6px; box-shadow: 0 2px 6px rgba(0,0,0,0.2); z-index: 9999; font-size: 14px;"></div>

<script src="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack-all.min.js"></script>
<script>
    const grid = GridStack.init({ float: true, cellHeight: 100, margin: 10 });

    // Sayfa açıldığında dashboard kayıtlarını yükle
    dashboardLayout.forEach(item => {
        const widgetEl = document.createElement("div");
        widgetEl.className = "grid-stack-item";
        widgetEl.innerHTML = `
        <div class="grid-stack-item-content">
          <button class="close-widget-btn" onclick="removeWidget(this)">×</button>
          <span class="widget-title" contenteditable="true">${item.CUSTOM_TITLE || "Başlıksız"}</span><br>
          <input type="hidden" class="widget-id-hidden" value="${item.WIDGET_ID}">
          <iframe src="${item.FILE_PATH}?widgetid=${item.WIDGET_ID}" width="100%" height="260" frameborder="0" style="margin-top: 8px; border-radius: 8px;" onload="resizeIframe(this)"></iframe>
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
  const btn = document.getElementById("btnWidgetEkle");
  const widgetList = document.getElementById("widgetList");

  btn.addEventListener("click", () => {
    modal.style.display = modal.style.display === "block" ? "none" : "block";
  });

  function closeWidgetModal() {
    document.getElementById("widgetModal").style.display = "none";
  }

  function renderWidgetSelector() {
    const listContainer = document.getElementById("widgetList");
    listContainer.innerHTML = "";
    availableWidgets.forEach(w => {
      const div = document.createElement("div");
      div.className = "widget-item";
      div.style = "display: flex; justify-content: space-between; align-items: center; padding: 6px 0; border-bottom: 1px solid ##eee;";
      div.innerHTML = `
        <span style="flex:1;">${w.NAME}</span>
        <button onclick="addWidgetFromDB('${w.NAME}', '${w.PATH}', ${w.ID})">Ekle</button>`;
      listContainer.appendChild(div);
    });
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

    grid.addWidget(widgetEl, { w: 3, h: 2 });
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

  function createWidgetElement(widget) {
    const widgetId = widget.ID;
    const title = widget.NAME;
    const filePath = widget.PATH;

    const el = document.createElement('div');
    el.classList.add('grid-stack-item');
    el.setAttribute('gs-x', '0');
    el.setAttribute('gs-y', '0');
    el.setAttribute('gs-width', '4');
    el.setAttribute('gs-height', '2');
    el.setAttribute('data-widgetid', widgetId);

    el.innerHTML = `
        <div class="grid-stack-item-content">
            <iframe src="${filePath}" frameborder="0" style="width:100%; height:100%;"></iframe>
        </div>
    `;
    return el;
  }

  // Kullanıcı bir widget seçtiğinde çağrılacak:
  function addWidgetToDashboard(widget) {
      const widgetElement = createWidgetElement(widget);
      grid.addWidget(widgetElement);
      saveDashboardLayout();  // otomatik kaydet
  }

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
      //console.log("Kaydedilecek layout", layoutData);
      fetch("/V16/add_options/report/query/save_dashboard_layout.cfm", {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: JSON.stringify({ layout: layoutData })
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
</script>
</cfoutput>
