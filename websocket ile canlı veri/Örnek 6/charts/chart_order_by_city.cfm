<cfoutput>
    <!-- chart_order_by_city.cfm -->
    <div id="chartContainer_city_#createUUID()#" style="width:100%; height:300px;"></div>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
    fetch("/path/to/api/or/your/mock/data")
      .then(response => response.json())
      .then(data => {
        const ctx = document.getElementById("chartContainer_city_#createUUID()#").getContext("2d");
        new Chart(ctx, {
          type: 'bar',
          data: {
            labels: data.map(d => d.CITY),
            datasets: [{
              label: 'Sipariş Sayısı',
              data: data.map(d => d.ID),
              backgroundColor: 'rgba(54, 162, 235, 0.6)',
              borderColor: 'rgba(54, 162, 235, 1)',
              borderWidth: 1
            }]
          },
          options: {
            responsive: true,
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
      });
    </script>
    </cfoutput>
    