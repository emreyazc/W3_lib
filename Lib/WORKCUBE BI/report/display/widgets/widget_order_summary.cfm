<!--- widget_order_summary.cfm --->
<cfsetting showdebugoutput="false">

<!--- İlk veri yükleme (Son 7 gün toplam sipariş) --->
<cfquery name="qSummary" datasource="#DSN#">
    SELECT COUNT(*) AS ORDER_COUNT
    FROM workcube_test.workcube_test.ORDERS_TEST
    WHERE ORDERDATE >= DATEADD(day, -7, GETDATE())
</cfquery>

<cfscript>
    orderCount = (qSummary.recordCount ? val(qSummary.ORDER_COUNT[1]) : 0);
</cfscript>

<cfoutput>
  <cfwebsocket name="ws" subscribeTo="soketkanal" onMessage="messageHandler" />

  <style>
    body.light-mode { background: white; color: ##222; }
    body.dark-mode  { background: ##1a1a1a; color: ##eee; }
    html, body {
      margin: 0; padding: 0; height: 100%;
      font-family: sans-serif;
      display: flex; align-items: center; justify-content: center;
    }
    .summary-box {
      border-radius: 16px; padding: 24px; text-align: center;
      box-shadow: 0 6px 20px rgba(0,0,0,0.1);
      background: inherit; border: 1px solid ##ccc;
    }
    .summary-count { font-size: 48px; font-weight: bold; }
    .summary-label { font-size: 18px; margin-top: 10px; opacity: 0.7; }
  </style>

  <div class="summary-box">
    <div class="summary-count" id="orderCount">#orderCount#</div>
    <div class="summary-label">Son 7 Günlük Sipariş</div>
  </div>

  <script>
    // WebSocket'ten "orderSummary" tipi geldiğinde UI güncellenir
    function messageHandler(event) {
      let gelenMesaj = event?.data || event;
      let data = null;

      if (typeof gelenMesaj === "string" && (gelenMesaj.startsWith("{") || gelenMesaj.startsWith("["))) {
        try { data = JSON.parse(gelenMesaj); } catch (e) { return; }
      } else if (typeof gelenMesaj === "object") {
        data = gelenMesaj;
      } else {
        return;
      }

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

    // Tema entegrasyonu (parent -> iframe)
    window.addEventListener("message", function(event) {
      if (event.data?.type === "setTheme") {
        const theme = event.data.theme;
        document.body.classList.remove("light-mode", "dark-mode");
        document.body.classList.add(theme + "-mode");
      }
    });
  </script>
</cfoutput>
