<!--- orders_by_city_widget.cfm --->
<cfsetting showdebugoutput="false">

<!--- İlk veri yükleme --->
<cfquery name="qOrders" datasource="#DSN#">
    SELECT CITY, COUNT(*) AS CNT
    FROM ORDERS_TEST
    GROUP BY CITY
</cfquery>

<cfscript>
    cityList  = [];
    countList = [];
    for (row in qOrders) {
        arrayAppend(cityList, row.CITY);
        arrayAppend(countList, val(row.CNT));
    }
    cityJson  = serializeJSON(cityList);
    countJson = serializeJSON(countList);
</cfscript>

<cfoutput>
    <cfwebsocket name="ws" subscribeTo="soketkanal" onMessage="messageHandler" />

    <style>
        body.light-mode { background: white; color: ##222; }
        body.dark-mode  { background: ##1a1a1a; color: ##eee; }
        html, body { margin: 0; padding: 0; width: 100%; height: 100%; overflow: hidden; }
        ##myChart { display: block; width: 100% !important; height: 100% !important; }
    </style>

    <canvas id="myChart"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var chart = null;

        function initOrUpdateChart(cityList, orderList) {
            if (!chart) {
                var ctx = document.getElementById('myChart').getContext('2d');
                chart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: cityList,
                        datasets: [{
                            label: 'Sipariş Sayısı',
                            data: orderList,
                            backgroundColor: '##007bff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            y: { beginAtZero: true, precision: 0 }
                        }
                    }
                });
            } else {
                chart.data.labels = cityList;
                chart.data.datasets[0].data = orderList;
                chart.update();
            }
        }

        // İlk yükleme (CF verisi)
        (function(){
            var cityList  = #preserveSingleQuotes(cityJson)#;
            var orderList = #preserveSingleQuotes(countJson)#;
            initOrUpdateChart(cityList, orderList);
            reportHeightToParent();
        })();

        // WebSocket güncelleme
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

            if (data.TYPE === "orderByCity" && data.DATA?.COLUMNS && data.DATA?.DATA) {
                var cityIndex  = data.DATA.COLUMNS.indexOf("CITY");
                var countIndex = data.DATA.COLUMNS.indexOf("COUNT");
                var cityList = [], orderList = [];

                data.DATA.DATA.forEach(function(row) {
                    cityList.push(row[cityIndex]);
                    orderList.push(parseInt(row[countIndex], 10) || 0);
                });

                initOrUpdateChart(cityList, orderList);
                reportHeightToParent();
            }
        }

        function reportHeightToParent() {
            const height = document.body.scrollHeight;
            parent.postMessage({ type: "setHeight", height }, "*");
        }

        window.addEventListener("load", () => {
            reportHeightToParent();
            window.dispatchEvent(new Event('resize'));
        });

        window.addEventListener("resize", () => {
            if (chart) chart.resize();
            reportHeightToParent();
        });

        window.addEventListener("message", function(event) {
            if (event.data && event.data.type === "setTheme") {
                const theme = event.data.theme;
                document.body.classList.remove("light-mode", "dark-mode");
                document.body.classList.add(theme + "-mode");
            }
        });
    </script>
</cfoutput>
