<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/gridstack@9.2.1/dist/gridstack.min.css">
<style>
  body.light-mode {
    background: #f5f5f5;
    color: #222;
  }

  body.dark-mode {
    background: #121212;
    color: #e0e0e0;
  }

  body.dark-mode .grid-stack-item-content {
    background-color: #1e1e1e;
    border: 1px solid #444;
  }

  body.dark-mode .widget-title {
    color: #e0e0e0;
  }

  body 
  { 
    margin: 0; 
    padding: 0; 
    background: #f5f5f5; 
    font-family: sans-serif; 
  }
  .grid-stack-item .grid-stack-item-content {
    padding-top: 10px;
    padding-bottom: 10px;
    box-sizing: border-box;
    /* Bonus: kart hissi için (opsiyonel) */
    background: #fff;
    border-radius: 15px;
    box-shadow: 0 2px 10px rgba(0,0,0,.06);
  }
  .widget-title {
    display: inline-block;
    font-weight: bold;
    font-size: 16px;
    margin-bottom: 6px;
    cursor: text;
  }
  .widget-title[contenteditable="true"]:focus {
    outline: 2px dashed #007bff;
    background: #eef7ff;
  }

  .settings-panel button:hover {
    background: #ddd;
  }

  #btn_addd_dashboard {
    margin: 16px;
    padding: 10px 20px;
    font-size: 15px;
    border: none;
    background-color: #007bff;
    color: white;
    border-radius: 6px;
    cursor: pointer;
  }
  .widget-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    padding: 8px 0;
    border-bottom: 1px solid #eee;
  }
  .widget-item:last-child {
    border-bottom: none;
  }
  .widget-item input[type="text"] {
    flex: 1;
    font-size: 14px;
    padding: 6px;
    border: 1px solid #ccc;
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
    background-color: #28a745;
    color: white;
    border-radius: 4px;
    cursor: pointer;
  }
  .widget-item button.remove {
    background-color: #dc3545;
  }
  .widget-item button:hover {
    opacity: 0.85;
  }
  .close-widget-btn {
    position: absolute;
    top: 6px;
    right: 8px;
    background: #f44336;
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
    background: #d32f2f;
  }

  /* Sağdan Açılır Menü (Glassmorphism) */
  .side-menu {
      position: fixed;
      top: 100px;
      right: -250px;
      width: 250px;
      height: 75%;
      background: rgba(61, 136, 206, 0.55); /* Workcube koyu renk + saydam */
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border-left: 1px solid rgba(255,255,255,0.1);
      box-shadow: -2px 0 12px rgba(0,0,0,0.3);
      transition: right 0.3s ease;
      z-index: 2000;
      overflow-y: auto;
      padding-top: 20px;
      border-radius: 6px;
  }

  .side-menu.open {
      right: 0;
  }

  .side-menu .menu-title {
      font-size: 14px;
      font-weight: bold;
      margin: 0 0 8px 20px;
      color: rgba(255,255,255,0.7);
  }

  .side-menu .menu-item {
      padding: 10px 20px;
      cursor: pointer;
      font-size: 14px;
      color: rgba(255,255,255,0.85);
      transition: background 0.2s ease, color 0.2s ease;
  }

  .side-menu .menu-item:hover {
      background-color: rgba(255,255,255,0.1);
      color: #fff;
  }

  .side-menu .menu-item.favorite { color: #b37feb; }
  .side-menu .menu-item.add-dashboard { color: #4cafef; }

  /* Menü Toggle Butonu (Glass) */
  .menu-toggle-btn {
      min-height: 45px;
      position: fixed;
      right: 0;
      width: 42px;
      background: rgba(61, 136, 206, 0.55); /* Workcube koyu renk + saydam */
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      color: #fff;
      border: 1px solid rgba(255,255,255,0.15);
      cursor: pointer;
      z-index: 2100;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 6px 0 0 6px;
      transition: right 0.3s ease, background 0.2s ease;
  }
  .menu-toggle-btn:hover {
      background: rgba(60, 60, 90, 0.8);
  }
  .dashboard-header {
    display: grid;
    grid-template-columns: 1fr auto 1fr; /* sol ve sağ eşit esnek, orta otomatik */
    align-items: center;
    width: 100%;
    min-height: 45px;
    background: rgba(61, 136, 206, 0.55); /* Side-menu ile aynı renk */
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    color: #fff;
    padding: 0 32px;
    box-sizing: border-box;
    border-bottom: 1px solid rgba(255,255,255,0.1);
    box-shadow: -2px 0 12px rgba(0,0,0,0.3);
    position: relative;
  }

  /* sol/orta/sağ grid kolonları */
  .dashboard-header .left   { grid-column: 1; display:flex; align-items:center; gap:8px; min-width: 0; }
  .dashboard-header .right  { grid-column: 3; display:flex; justify-content:flex-end; align-items:center; gap:8px; min-width: 0; }

  .dashboard-header h1 {
    font-size: 1.3rem;
    font-weight: 400;
    margin: 0;
    color: #fff;
    letter-spacing: 0.02em;
    line-height: 1.2;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    text-align: center;
  }

  .dashboard-header .center {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    min-width: 0;
  }

  .dashboard-header .center h1 {
    font-size: 2rem;
    font-weight: 600;
    color: #fff; /* arka plan koyu olduğu için başlık beyaz */
    letter-spacing: 1px;
    text-shadow: 0 2px 4px rgba(0,0,0,0.25);
  }

  .dashboard-header button {
    background: none;
    border: none;
    color: #fff;
    font-size: 1.15rem;
    padding: 8px 14px;
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.18s;
    outline: none;
  }

  .dashboard-header button:hover {
    background: rgba(255,255,255,0.13);
  }

  .dashboard-header .widget-btn {
    font-size: 1.35rem;
    font-weight: 500;
    padding: 7px 13px;
  }

  .dashboard-header .settings-btn {
    font-size: 1.35rem;
    padding: 7px 13px;
  }

  .dashboard-header .theme-btn {
    font-size: 1.35rem;
    padding: 7px 13px;
  }

  .dashboard-header .export-btn:hover {
    background: rgba(255,255,255,0.13);
  }
  .badge_dashbaord {
    display: inline-block;
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 6px;
    color: white;
    background-color: gray;
    user-select: none;
    line-height: 1;
    }

   .badge-system {
    background-color: #007bff; /* Mavi */
    border-radius: 3px;
    }
    .badge-custom {
    background-color: #28a745; /* Yeşil */
    border-radius: 3px;
    }
    .badge-nocode {
    background-color:rgb(178, 0, 0); /* kırmızı */
    border-radius: 4px;
    }
    .active-tab {
    background: #ddd !important;
    font-weight: bold;
    border-bottom: 2px solid #007bff;
  }
  /* Ufak bir buton stili (isteğe bağlı) */
  .wizard-btn {
    border: 1px solid #dcdfe6; background: #fff; border-radius: 8px;
    padding: 6px 10px; cursor: pointer; margin-left: 6px;
  }
  .wizard-btn:hover { background: #f7f8fa; }
   /* === Widget Builder Modal (namespace) === */
   #widgetBuilderRoot.wb-hidden { display:none }
  #widgetBuilderRoot.wb-backdrop {
    position:fixed; inset:0; background:rgba(0,0,0,.25);
    display:flex; align-items:center; justify-content:center; z-index:9999;
  }
  #widgetBuilderRoot .wb-modal {
    width:90%; max-height:90vh; overflow:auto; background:#fff;
    border-radius:14px; box-shadow:0 20px 60px rgba(0,0,0,.25);
  }
  #widgetBuilderRoot .wb-modal header {
    padding:12px 16px; border-bottom:1px solid #e5e7eb;
    display:flex; justify-content:space-between; align-items:center;
  }
  #widgetBuilderRoot .wb-title { font-weight:700 }
  #widgetBuilderRoot .wb-muted { color:#6b7280; font-size:12px }
  #widgetBuilderRoot .wb-content { padding:12px 16px }
  #widgetBuilderRoot .sw-btn {
    cursor:pointer; padding:8px 12px; border:1px solid #e5e7eb;
    background:#fff; border-radius:8px;
  }
  #widgetBuilderRoot .sw-btn.sw-primary { background:#1f6feb; border-color:#1f6feb; color:#fff }
  #widgetBuilderRoot .right { margin-left:auto }
  /* ——— Patch: Side Menu UX & A11y Cilaları ——— */
  /* 1) Badge alias (typo fix, mevcut adı bozmadan) */
  .badge-dashboard, .badge_dashbaord { display:inline-block; font-size:10px; padding:2px 6px; border-radius:6px; color:#fff; line-height:1; }
  .badge-system  { background:#007bff; border-radius:3px; }
  .badge-custom  { background:#28a745; border-radius:3px; }
  .badge-nocode  { background:rgb(178,0,0); border-radius:4px; }

  /* 2) Side-menu içerik boşlukları ve scrollbar iyileştirmesi */
  .side-menu { scrollbar-width: thin; scrollbar-color: rgba(255,255,255,0.35) transparent; }
  .side-menu::-webkit-scrollbar { width:8px; }
  .side-menu::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.35); border-radius:8px; }
  .side-menu::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.5); }

  /* 3) Menü öğeleri: satır yüksekliği, focus ve aktif görsellik */
  .side-menu .menu-item { 
    padding: 12px 20px;                 /* satır yüksekliği arttı */
    border-radius: 6px; 
    outline: none; 
  }
  .side-menu .menu-item:focus-visible {
    outline: 2px solid rgba(255,255,255,0.6);
    outline-offset: 2px;
  }
  .side-menu .menu-item.active {
    background: rgba(255,255,255,0.16);
    color: #fff;
    font-weight: 600;
  }

  /* Favori item görsel cilası (yıldız sabit hizada) */
  .side-menu .menu-item.favorite { 
    color: #b37feb; 
    display: flex; 
    align-items: center; 
    gap: 6px;
  }

  /* 4) Bölüm başlıkları sabit kalsın (uzun listelerde kayarken görünür) */
  .side-menu .menu-title {
    position: sticky; 
    top: 0; 
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    padding: 6px 20px;
    margin: 0;
    z-index: 1;
  }

  /* 5) “Dashboard Oluştur” satırı (li.menu-item.add-dashboard içindeki buton) */
  .side-menu .menu-item.add-dashboard {
    padding: 12px 20px 6px 20px;  /* üstte biraz daha nefes alan boşluk */
    cursor: default;              /* buton var, li tıklanmasın */
  }
  .side-menu .menu-item.add-dashboard > #btnDashboardEkle {
    width: 100%;
    background: #28a745;
    color: #fff;
    padding: 10px 12px;
    border: none;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: transform .08s ease, box-shadow .18s ease, background .18s ease;
    box-shadow: 0 4px 14px rgba(0,0,0,.12);
  }
  .side-menu .menu-item.add-dashboard > #btnDashboardEkle:hover {
    transform: translateY(-1px);
    box-shadow: 0 6px 18px rgba(0,0,0,.18);
    background: #2db64e;
  }
  .side-menu .menu-item.add-dashboard > #btnDashboardEkle:active {
    transform: translateY(0);
    box-shadow: 0 3px 10px rgba(0,0,0,.14);
  }

  /* 6) Dark mode uyumu (menü ve başlıklar) */
  body.dark-mode .side-menu {
    background: rgba(25, 58, 95, 0.55);
    border-left: 1px solid rgba(255,255,255,0.08);
    box-shadow: -2px 0 12px rgba(0,0,0,0.45);
  }
  body.dark-mode .side-menu .menu-title { color: rgba(255,255,255,0.8); }
  body.dark-mode .side-menu .menu-item { color: rgba(255,255,255,0.9); }
  body.dark-mode .side-menu .menu-item:hover { background: rgba(255,255,255,0.12); color:#fff; }
  body.dark-mode .side-menu .menu-item.add-dashboard > #btnDashboardEkle {
    background: #2aa64a;
  }

  /* 7) Menü toggle butonu: daha belirgin hover/focus (mevcut yapına uyumlu) */
  .menu-toggle-btn:focus-visible {
    outline: 2px solid rgba(255,255,255,0.75);
    outline-offset: 2px;
  }
</style>