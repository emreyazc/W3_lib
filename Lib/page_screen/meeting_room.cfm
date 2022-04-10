<!---  
	EVENT_ROOM = 1 : Galata
				 2 : Karakoy
				 3 : Beyoglu
--->

<cfquery name="GET_EVENT" datasource="#DSN#">
	SELECT
		EVENT_HEAD,
		EVENT_DETAIL,
		EVENT_ROOM,
		EVENT_TO_POS,
		STARTDATE,
		FINISHDATE
	FROM
		EVENT
	WHERE EVENT_ROOM=2 
	<!---
		AND convert(varchar, STARTDATE, 3) = convert(varchar, getdate(), 3)
	---> <!--- bugün gerçekleşen toplantı ---> <!--- ve --->
<!--- şuanda saat eğer startdate ile finishdate arasında ise gösteriyor. --->
</cfquery>

<!---
<cfset start_remaining_h = Timeformat(now(),'HH')-Timeformat(GET_EVENT.STARTDATE,'HH') > <!--- Başlamasına kalan. ---->
<cfset start_remaining_m = Timeformat(GET_EVENT.STARTDATE,'MM')-Timeformat(now(),'MM') >

<cfset finish_remaining_h = Timeformat(GET_EVENT.FINISHDATE,'HH')-Timeformat(now(),'HH') > <!--- Bitmesine kalan. ---->
<cfset finish_remaining_m= Timeformat(GET_EVENT.FINISHDATE,'MM')-Timeformat(now(),'MM') >
--->

<cfquery name="GET_GUEST_EMP" datasource="#DSN#">
	SELECT
		EMPLOYEE_NAME,
		EMPLOYEE_SURNAME
	FROM
		EMPLOYEES
	WHERE 
		EMPLOYEE_ID IN (<cfqueryparam value="#GET_EVENT.EVENT_TO_POS#" cfsqltype="CF_SQL_INTEGER"list="yes"/>)
</cfquery>
<cfoutput query="GET_EVENT">
	<cf_box>
		<cf_box_elements>
			<div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
				<h5 style="color: darkblue; font-size:25px">GALATA TOPLANTI ODASI</h5>		
			</div>
			<div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
				<h5 style="color: darkblue; font-size:25px">SAAT : #Timeformat(now(),'HH:MM')#</h5>
				<br>
				<h5 style="color: darkblue; font-size:25px">TARİH	 : #dateformat(now(),'DD.MM.YYYY')#</h5>			
			</div>
		</cf_box_elements>
		<cf_box_elements>
			<div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
				<h5 style="color: darkblue; font-size:25px">Toplantı Adi : #EVENT_HEAD#</h5>
			</div>
			<div class="form-group col col-6 col-md-6 col-sm-6 col-xs-12">
				<h5 style="color: darkblue; font-size:25px">Toplantı Açıklaması :  #EVENT_DETAIL#</h5>
			</div>
		</cf_box_elements>
	</cf_box>
</cfoutput>

<cf_box>
	<div class="form-group col col-12 col-md-12 col-sm-12 col-xs-12">
		<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
			<h5 style="color: darkblue; font-size:25px">KATILIMCILAR</h5>	
		</div>
	   </div>
	<div class="form-group col col-12 col-md-12 col-sm-12 col-xs-12">
		<cfoutput query="GET_GUEST_EMP">
			<div class="col col-6 col-md-6 col-sm-6 col-xs-12">
				<h5 style="color: darkblue; font-size:25px">#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</h5>
			</div>
		</cfoutput>
	</div>
</cf_box>


<!---
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
		<h2 style="color:red">
			<cfif #GET_EVENT.EVENT_ROOM# eq 1 >
					Galata Toplantı Odası
			</cfif>
			<cfif #GET_EVENT.EVENT_ROOM# eq 2 >
					Karaköy Toplantı Odası
			</cfif>
			<cfif #GET_EVENT.EVENT_ROOM# eq 3 >
					Beyoğlu Seminer Salonu
			</cfif>
		</h2>
  </head>
  <body>
    <h1></h1>
    <!-- Optional JavaScript; choose one of the two! -->
    <!-- Option 1: Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    <!-- Option 2: Separate Popper and Bootstrap JS -->
    <!--
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.9.2/dist/umd/popper.min.js" integrity="sha384-IQsoLXl5PILFhosVNubq5LC7Qb9DXgDA9i+tQ8Zj3iwWAwPtgFTxbJ8NT4GN1R8p" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>
    -->
	<!---
	<cfoutput query="GET_EVENT">
		<h5 style="color: darkblue">Şuan Saat : #Timeformat(now(),'HH:MM')# - Tarih : #dateformat(now(),'DD.MM.YYYY')#</h5>
		<h4 style="color:blue">Toplantının Başlamasına, #start_remaining_h# saat #start_remaining_m# dakika kaldı.</h4>
		
			<h4 style="color:green">Toplantının Bitmesine, #finish_remaining_h# saat #finish_remaining_m# dakika kaldı.</h4>
		
		<p>Toplantı Adi : #EVENT_HEAD#</p>
		<p>Toplantı Açıklaması : #EVENT_DETAIL#</p>
		
		<p>Toplantı Tarihi (Başlangıç - Bitiş) : #dateformat(STARTDATE,'DD.MM.YYYY')# - #dateformat(FINISHDATE,'DD.MM.YYYY')#</p>
		<p>Toplantı Saati (Başlangıç - Bitiş) : #Timeformat(STARTDATE,'HH:MM')# - #Timeformat(FINISHDATE,'HH:MM')#</p>
		
	</cfoutput>
	--->

	<cfoutput query="GET_EVENT">
		<p>Toplantı Tarihi (Başlangıç - Bitiş) : #dateformat(STARTDATE,'DD.MM.YYYY')# - #dateformat(FINISHDATE,'DD.MM.YYYY')#</p>
		<p>Toplantı Saati (Başlangıç - Bitiş) : #Timeformat(STARTDATE,'HH:MM')# - #Timeformat(FINISHDATE,'HH:MM')#</p>
		<p>Toplantı Adi : #EVENT_HEAD#</p>
		<p>Toplantı Açıklaması : #EVENT_DETAIL#</p>
	</cfoutput>
	<b>Katılımcılar:</b></br><cfoutput query="GET_GUEST_EMP"><p>#EMPLOYEE_NAME# #EMPLOYEE_SURNAME#</p></cfoutput>

	<!---
	<cfif Timeformat(GET_EVENT.STARTDATE,'HH') lt Timeformat(now(),'HH')>
		<cfoutput>Başlangıç saati, anlık saatten küçüktür.</cfoutput>
	</cfif>
	--->

  </body>
</html>
--->


