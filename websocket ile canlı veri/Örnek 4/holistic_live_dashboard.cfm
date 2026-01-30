<!-- holistic_live_dashboard.cfm (Widget Seçimli - Ayar Panelinden Yönetim, iframe tabanlı) -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack.min.css">
<cfoutput>
<style>
  body { margin: 0; padding: 0; background: ##f5f5f5; font-family: sans-serif; }
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
  .widget-settings {
    position: absolute;
    top: 5px;
    right: 10px;
    font-size: 14px;
    cursor: pointer;
    background: none;
    border: none;
    color: ##007bff;
  }
  .widget-settings:hover {
    color: ##0056b3;
  }
  .settings-panel {
    display: none;
    position: absolute;
    top: 30px;
    right: 10px;
    background: ##fff;
    border: 1px solid ##ccc;
    border-radius: 8px;
    padding: 10px;
    z-index: 999;
    width: 160px;
    box-shadow: 0 6px 15px rgba(0,0,0,0.1);
    text-align: left;
  }
  .settings-panel button {
    display: block;
    width: 100%;
    margin-top: 5px;
    padding: 6px;
    font-size: 13px;
    background: ##eee;
    border: none;
    border-radius: 4px;
    cursor: pointer;
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
</style>

<!-- Widget Yöneticisi Butonu -->
<button id="btnWidgetEkle">🔧 Widget Yöneticisi</button>

<!-- Widget Seçim Paneli -->
<div id="widgetModal">
  <button class="close-btn" onclick="closeWidgetModal()">✕</button>
  <strong>Bir Widget Seç:</strong>
  <div id="widgetList">
    <div class="widget-item">
      <input type="text" value="WebSocket Test Grafiği">
      <div class="button-group">
        <button onclick="addWidgetFromInput(this)">Ekle</button>
        <button class="remove" onclick="removeWidgetFromInput(this)">Sil</button>
      </div>
    </div>
  </div>
  <br>
  <button onclick="addNewWidgetRow()">➕ Yeni Widget Satırı</button>
</div>

<!-- Grid Alanı -->
<div class="grid-stack" style="min-height: 100vh;"></div>

<script src="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack-all.min.js"></script>
<script>
  const grid = GridStack.init({ float: true, cellHeight: 100, margin: 10 });
  let kutuSayaci = 1;
  const modal = document.getElementById("widgetModal");
  const btn = document.getElementById("btnWidgetEkle");
  const widgetList = document.getElementById("widgetList");

  btn.addEventListener("click", () => {
    modal.style.display = modal.style.display === "block" ? "none" : "block";
  });

  function closeWidgetModal() {
    modal.style.display = "none";
  }

  function toggleSettings(panel) {
    panel.style.display = panel.style.display === "block" ? "none" : "block";
  }

  function addWidget(title) {
    const iframeSrc = "/V16/add_options/report/display/orders_graph.cfm";
    const widgetEl = document.createElement("div");
    widgetEl.className = "grid-stack-item";
    widgetEl.innerHTML = `
      <div class="grid-stack-item-content">
        <button class="widget-settings" onclick="toggleSettings(this.nextElementSibling)">⚙️</button>
        <div class="settings-panel">
          <button onclick="alert('Özellik geliştirilecek: Genişlik Değiştir')">Çap Değiştir</button>
          <button onclick="alert('Özellik geliştirilecek: Veri Kaynağını Güncelle')">Veri Kaynağı</button>
          <button onclick="this.closest('.grid-stack-item').remove()">❌ Kapat</button>
        </div>
        <span class="widget-title" contenteditable="true">${title}</span><br>
        <iframe src="${iframeSrc}" width="100%" height="260" frameborder="0" style="margin-top: 8px; border-radius: 8px;"></iframe>
        <small>##${kutuSayaci}</small>
      </div>`;
    grid.addWidget(widgetEl, {w: 3, h: 2});
    kutuSayaci++;
  }

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

  function addWidgetFromInput(btn) {
    const title = btn.closest(".widget-item").querySelector("input").value;
    addWidget(title);
  }

  function removeWidgetFromInput(btn) {
    const title = btn.closest(".widget-item").querySelector("input").value;
    const allWidgets = document.querySelectorAll(".grid-stack-item");
    allWidgets.forEach(widget => {
      const widgetTitle = widget.querySelector(".widget-title");
      if (widgetTitle && widgetTitle.textContent.trim() === title.trim()) {
        grid.removeWidget(widget);
      }
    });
  }

  function addNewWidgetRow() {
    const div = document.createElement("div");
    div.className = "widget-item";
    div.innerHTML = `
      <input type="text" value="Yeni Widget">
      <div class="button-group">
        <button onclick="addWidgetFromInput(this)">Ekle</button>
        <button class="remove" onclick="removeWidgetFromInput(this)">Sil</button>
      </div>`;
    widgetList.appendChild(div);
  }
</script>
</cfoutput>
