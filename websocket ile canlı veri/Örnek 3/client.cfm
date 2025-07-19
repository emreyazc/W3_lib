<!---
    client.cfm
--->

<cfoutput>
    <html>
    <head>
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
            fetch("/V16/report/query/getOrderCityCount.cfm")
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
                document.getElementById("msgDiv").innerText = "Veri başarıyla yüklendi.";
            })
            .catch(err => {
                document.getElementById("msgDiv").innerText = "Veri alınamadı: " + err;
            });

            // WebSocket ile canlı güncellemede:
            function messageHandler(event) {
                let gelenMesaj = event && event.data ? event.data : undefined;
                let data = null;
                if (!gelenMesaj) return;
                if (typeof gelenMesaj === "string" && (gelenMesaj.startsWith("{") || gelenMesaj.startsWith("["))) {
                    try { data = JSON.parse(gelenMesaj); } catch (e) { return; }
                } else if (typeof gelenMesaj === "object") {
                    data = gelenMesaj;
                } else {
                    return;
                }
                if (data.DATA && data.COLUMNS) {
                    var cityIndex = data.COLUMNS.indexOf("CITY");
                    var countIndex = data.COLUMNS.indexOf("COUNT");
                    var cityList = [], orderList = [];
                    data.DATA.forEach(function(row) {
                        cityList.push(row[cityIndex]);
                        orderList.push(parseInt(row[countIndex]));
                    });
                    initOrUpdateChart(cityList, orderList); // sadece veriyi güncelle!
                    document.getElementById("msgDiv").innerText = "Canlı güncelleme: " + new Date().toLocaleTimeString();
                }
            }
        </script>        
    </head>
    <body>
        <cfwebsocket name="ws" subscribeTo="soketkanal" onMessage="messageHandler" />
        <h3>Bugünkü Siparişler (Şehir Bazında)</h3>
        <canvas id="myChart" width="600" height="250"></canvas>
        <div id="msgDiv" style="margin-top:20px; color:##666;">Henüz veri gelmedi.</div>
    </body>
    </html>
    </cfoutput>
    