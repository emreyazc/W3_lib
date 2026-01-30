<cfwebsocket name="ws" subscribeTo="soketkanal" onMessage="messageHandler" />
<cfoutput>
  <style>
    body.light-mode {
      background: white;
      color: ##222;
    }
    body.dark-mode {
      background: ##1a1a1a;
      color: ##eee;
    }
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      font-family: sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .summary-box {
      border-radius: 16px;
      padding: 24px;
      text-align: center;
      box-shadow: 0 6px 20px rgba(0,0,0,0.1);
      background: inherit;
      border: 1px solid ##ccc;
    }
    .summary-count {
      font-size: 48px;
      font-weight: bold;
    }
    .summary-label {
      font-size: 18px;
      margin-top: 10px;
      opacity: 0.7;
    }
  </style>

    <div class="summary-box">
        <div class="summary-count" id="orderCount">...</div>
        <div class="summary-label">Son 7 Günlük Sipariş</div>
    </div>

  <script>
    // Sayfa ilk açıldığında ilk veriyi yükle
    fetch("/V16/add_options/report/query/getOrderSummary.cfm")
        .then(res => res.json())
        .then(data => {
            console.log("Gelen veri:", data);
            document.getElementById("orderCount").textContent = data.ORDER_COUNT;
            reportHeightToParent();
        })
        .catch(err => {
            console.error("Veri çekme hatası:", err);
    });

    function updateOrderSummary(payload) {
        if (!payload?.DATA?.COLUMNS || !payload?.DATA?.DATA) return;

        const columns = payload.DATA.COLUMNS.map(c => c.toUpperCase());
        const dataRows = payload.DATA.DATA;
        const countIndex = columns.indexOf("COUNT");
        if (countIndex === -1) return;

        let total = 0;
        dataRows.forEach(row => {
            const val = row[countIndex];
            if (!isNaN(val)) total += parseInt(val);
        });

        document.getElementById("orderCount").textContent = total;
    }

    function messageHandler(event) {
        console.log("Gelen Ham Mesaj:", event.data);
        let gelenMesaj = event?.data;
        if (!gelenMesaj) return;

        let data = null;
        if (typeof gelenMesaj === "string" && (gelenMesaj.startsWith("{") || gelenMesaj.startsWith("["))) {
            try { data = JSON.parse(gelenMesaj); } catch (e) { return; }
        } else if (typeof gelenMesaj === "object") {
            data = gelenMesaj;
        }

        //console.log("WebSocket'ten gelen veri:", data);

        // ✅ Sadece orderSummary tipindeki mesajları dinle
        if (data?.TYPE === "orderSummary" && data?.DATA?.ORDER_COUNT !== undefined) {
            document.getElementById("orderCount").textContent = data.DATA.ORDER_COUNT;
            reportHeightToParent();
        }
    }

    function reportHeightToParent() {
      const height = document.body.scrollHeight;
      parent.postMessage({ type: "setHeight", height }, "*");
    }

    window.addEventListener("load", () => {
      reportHeightToParent();
    });

    window.addEventListener("message", function(event) {
      if (event.data?.type === "setTheme") {
        const theme = event.data.theme;
        document.body.classList.remove("light-mode", "dark-mode");
        document.body.classList.add(theme + "-mode");
      }
    });
  </script>
</cfoutput>