<cfoutput>
    <cfwebsocket name="ws" subscribeTo="soketkanal" onMessage="messageHandler" />
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
            width: 100%;
            height: 100%;
            overflow: hidden;
        }
        ##myChart {
            display: block;
            width: 100% !important;
            height: 100% !important;
        }
    </style>
    <canvas id="myChart"></canvas>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        var chart = null;
        function initOrUpdateChart(cityList, orderList) {
            if (!chart) {
                // Sadece ilk kez açılışta oluştur
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
                        plugins: { legend: { display: false } }
                    }
                });
            } else {
                // Sonraki her canlı güncellemede sadece veriyi güncelle!
                chart.data.labels = cityList;
                chart.data.datasets[0].data = orderList;
                chart.update();
            }
        }

        // İlk yüklemede:
        fetch("/V16/add_options/report/query/getOrderCityCount.cfm")
        .then(response => response.json())
        .then(data => {
            var cityList = [], orderList = [];
            if (data.DATA && data.COLUMNS) {
                var cityIndex = data.COLUMNS.indexOf("CITY");
                var countIndex = data.COLUMNS.indexOf("COUNT");
                data.DATA.forEach(function(row) {
                    cityList.push(row[cityIndex]);
                    orderList.push(parseInt(row[countIndex]));
                });
            }
            initOrUpdateChart(cityList, orderList);
            reportHeightToParent();
        })
        .catch(err => {
            console.error("Veri alınamadı:", err);
        });

        // WebSocket ile canlı güncellemede:
        function messageHandler(event) {
            // Gelen ham event'i göster
            //console.log("Ham Event:", event);
            console.log("Gelen Ham Mesaj:", event.data);

            let gelenMesaj = event?.data || event;
            let data = null;

            // JSON parse et
            if (typeof gelenMesaj === "string" && (gelenMesaj.startsWith("{") || gelenMesaj.startsWith("["))) {
                try { data = JSON.parse(gelenMesaj); } catch (e) { console.error("JSON parse hatası", e); return; }
            } else if (typeof gelenMesaj === "object") {
                data = gelenMesaj;
            } else {
                return;
            }

            console.log("Event.data parsed:", data);

            // Sadece "orderByCity" tipi gelirse işleme al
            if (data.TYPE === "orderByCity" && data.DATA?.COLUMNS && data.DATA?.DATA) {
                var cityIndex = data.DATA.COLUMNS.indexOf("CITY");
                var countIndex = data.DATA.COLUMNS.indexOf("COUNT");
                var cityList = [], orderList = [];

                data.DATA.DATA.forEach(function(row) {
                    cityList.push(row[cityIndex]);
                    orderList.push(parseInt(row[countIndex]));
                });

                // Grafiği güncelle
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
