<!---
    dashboard
--->
<cfoutput>
    <html>
    <head>
    <script>
    function messageHandler(event, token) {
        console.log('event:', event);
        console.log('token:', token);

        // Bunu ekrana yaz:
        if(token) {
            document.getElementById("msgDiv").innerText = token;
        } else if(event && event.data) {
            document.getElementById("msgDiv").innerText = event.data;
        } else {
            document.getElementById("msgDiv").innerText = "Boş mesaj veya parametre yok!";
        }
    }
    </script>
    </head>
    <body>
    <cfwebsocket 
        name="ws"
        subscribeTo="soketkanal"
        onMessage="messageHandler"
    />
    <div id="msgDiv">Henüz mesaj yok.</div>
    </body>
    </html>
</cfoutput>
