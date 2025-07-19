<!---
    client.cfm
--->

<cfoutput>
    <html>
    <head>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            var chart = null;
            function messageHandler(event) {
                let gelenMesaj = event && event.data ? event.data : undefined;
                let data = null;
                if (!gelenMesaj) {
                    document.getElementById("msgDiv").innerText = "Boş veri geldi!";
                    return;
                }
                if (typeof gelenMesaj === "string" && (gelenMesaj.startsWith("{") || gelenMesaj.startsWith("["))) {
                    try {
                        data = JSON.parse(gelenMesaj);
                    } catch (e) {
                        document.getElementById("msgDiv").innerText = "JSON hatası: " + e + "\nGelen veri: " + gelenMesaj;
                        return;
                    }
                } else if (typeof gelenMesaj === "object") {
                    data = gelenMesaj;
                } else {
                    document.getElementById("msgDiv").innerText = gelenMesaj;
                    return;
                }
    
                // --- ŞEHİR VE SİPARİŞ SAYISI VERİLERİNİ ÇIKAR ---
                var cityList = [];
                var orderList = [];
                if (data.DATA && data.COLUMNS) {
                    var cityIndex = data.COLUMNS.indexOf("CITY");
                    var countIndex = data.COLUMNS.indexOf("COUNT");
                    data.DATA.forEach(function(row) {
                        cityList.push(row[cityIndex]);
                        orderList.push(parseInt(row[countIndex]));
                    });
                } else {
                    document.getElementById("msgDiv").innerText = "Beklenen formatta veri yok!";
                    return;
                }
    
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
                            plugins: { legend: { display: false } }
                        }
                    });
                } else {
                    chart.data.labels = cityList;
                    chart.data.datasets[0].data = orderList;
                    chart.update();
                }
                document.getElementById("msgDiv").innerText = "Güncellendi: " + new Date().toLocaleTimeString();
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
    