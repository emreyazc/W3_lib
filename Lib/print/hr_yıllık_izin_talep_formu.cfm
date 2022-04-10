<!--- 
    Description: İzin Talep Formu -  Yıllık Ücretli İzin Talep Formu
    File: 6BD527D8-C6FC-7140-D4E2241DFCC7346F.cfm
    Author: Birikim Pilleri - Yunus Emre Yazıcı
    Date: 16.08.2021
--->

<style>
	.txtbold, .headbold {font-weight:bold;}
</style>
<cf_get_lang_set module_name="ehesap"><!--- sayfanin en altinda kapanisi var --->
<cfsetting showdebugoutput="no">
<cfquery name="GET_GENERAL_OFFTIMES" datasource="#dsn#">
	SELECT START_DATE,FINISH_DATE FROM SETUP_GENERAL_OFFTIMES
</cfquery>
<cfset offday_list_ = ''>
<cfoutput query="GET_GENERAL_OFFTIMES">
	<cfscript>
		offday_gun = datediff('d',GET_GENERAL_OFFTIMES.start_date,GET_GENERAL_OFFTIMES.finish_date)+1;
		offday_startdate = date_add("h", session.ep.time_zone, GET_GENERAL_OFFTIMES.start_date); 
		offday_finishdate = date_add("h", session.ep.time_zone, GET_GENERAL_OFFTIMES.finish_date);
		
		for (mck=0; mck lt offday_gun; mck=mck+1)
			{
			temp_izin_gunu = date_add("d",mck,offday_startdate);
			daycode = '#dateformat(temp_izin_gunu,dateformat_style)#';
			if(not listfindnocase(offday_list_,'#daycode#'))
				offday_list_ = listappend(offday_list_,'#daycode#');
			}
	</cfscript>
</cfoutput>
<cfquery name="GET_OFFTIME" datasource="#DSN#">
	SELECT 
		OFFTIME.*, 
		SETUP_OFFTIME.OFFTIMECAT,
		(SELECT POSITION_NAME FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = OFFTIME.VALIDATOR_POSITION_CODE_1) AS AMIR1_POSITION_NAME,
		(SELECT POSITION_NAME FROM EMPLOYEE_POSITIONS WHERE POSITION_CODE = OFFTIME.VALIDATOR_POSITION_CODE_2) AS AMIR2_POSITION_NAME,
		CASE 
            WHEN ISNULL(OFFTIME.SUB_OFFTIMECAT_ID,0) <> 0 THEN (SELECT top 1 OFFTIMECAT FROM SETUP_OFFTIME A WHERE A.OFFTIMECAT_ID = OFFTIME.SUB_OFFTIMECAT_ID)
            WHEN ISNULL(OFFTIME.SUB_OFFTIMECAT_ID,0) = 0 THEN (SELECT top 1  OFFTIMECAT FROM OFFTIME B WHERE B.OFFTIMECAT_ID = OFFTIME.OFFTIMECAT_ID)
        END AS NEW_CAT_NAME
	FROM 
		OFFTIME,
		SETUP_OFFTIME
	WHERE
		OFFTIME.OFFTIMECAT_ID = SETUP_OFFTIME.OFFTIMECAT_ID AND
		OFFTIME_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.iid#">
</cfquery>
<cfif not get_offtime.recordcount>
	<br/><br/><br/><b><cf_get_lang_main no ='1074.Kayıt Bulunamadı'>!</b>
	<cfexit method="exittemplate">
</cfif>
<cfoutput query="get_offtime">
	<cfquery name="get_offtime_cat" datasource="#dsn#" maxrows="1">
		SELECT SATURDAY_ON,DAY_CONTROL FROM SETUP_OFFTIME_LIMIT WHERE STARTDATE <= '#startdate#'  AND FINISHDATE >= '#startdate#'
	</cfquery>
	
	<cfif get_offtime_cat.recordcount and len(get_offtime_cat.SATURDAY_ON)>
		<cfset saturday_on = get_offtime_cat.SATURDAY_ON>
	<cfelse>
		<cfset saturday_on = 1>
	</cfif>
	<cfif get_offtime_cat.recordcount and len(get_offtime_cat.DAY_CONTROL)>
		<cfset day_control_ = get_offtime_cat.DAY_CONTROL>
	<cfelse>
		<cfset day_control_ = 0>
	</cfif>
	<cfscript>
		temporary_sunday_total_ = 0;
		temporary_offday_total_ = 0;
		temporary_halfday_total = 0;
		total_izin_ = datediff('d',startdate,finishdate)+1;
		izin_startdate_ = date_add("h", session.ep.time_zone, startdate); 
		izin_finishdate_ = date_add("h", session.ep.time_zone, finishdate);
		diff= DateDiff("h",startdate,finishdate)
		
		for (mck_=0; mck_ lt total_izin_; mck_=mck_+1)
		{
			temp_izin_gunu_ = date_add("d",mck_,izin_startdate_);
			daycode_ = '#dateformat(temp_izin_gunu_,dateformat_style)#';
			if (dayofweek(temp_izin_gunu_) eq 1)
				temporary_sunday_total_ = temporary_sunday_total_ + 1;
			else if (dayofweek(temp_izin_gunu_) eq 7 and saturday_on eq 0)
				temporary_sunday_total_ = temporary_sunday_total_ + 1;
			else if(listlen(offday_list_) and listfindnocase(offday_list_,'#daycode_#'))
				temporary_offday_total_ = temporary_offday_total_ + 1;
			else if(daycode_ is '#dateformat(dateadd("h",2,finishdate),dateformat_style)#' and day_control_ gt 0 and timeformat(dateadd("h",2,finishdate),'HH') lt day_control_)
				temporary_halfday_total = temporary_halfday_total + 1;
		}
			izin_gun = total_izin_ - temporary_sunday_total_ - temporary_offday_total_ - (0.5 * temporary_halfday_total);
	</cfscript>
	<cfset real_days = izin_gun>
</cfoutput>
	<cfquery name="get_employee_info" datasource="#dsn#" maxrows="1">
		SELECT
			B.BRANCH_NAME,
			D.DEPARTMENT_HEAD,
			EP.POSITION_NAME,
			OC.NICK_NAME,
			E.KIDEM_DATE
		FROM
			EMPLOYEES E,
			BRANCH B,
			DEPARTMENT D,
			EMPLOYEE_POSITIONS EP,
			OUR_COMPANY OC
		WHERE
			E.EMPLOYEE_ID = EP.EMPLOYEE_ID AND
			E.EMPLOYEE_ID = #get_offtime.employee_id# AND
			EP.DEPARTMENT_ID = D.DEPARTMENT_ID AND
			D.BRANCH_ID = B.BRANCH_ID AND
			B.COMPANY_ID = OC.COMP_ID AND
			<!---D.DEPARTMENT_STATUS = 1 AND--->
			EP.IS_MASTER = 1
	</cfquery>

				<cfset record_=date_add('h',session.ep.time_zone,get_offtime.record_date)>
				<cfset start_=date_add('h',session.ep.time_zone,get_offtime.startdate)>
				<cfset end_=date_add('h',session.ep.time_zone,get_offtime.finishdate)>
				
				<cfif len(get_offtime.WORK_STARTDATE)>
					<cfset work_start_= date_add('h',session.ep.time_zone,get_offtime.WORK_STARTDATE)>
				<cfelse>				
				<cfset work_start_= date_add('d',1,get_offtime.finishdate)>
				<cfset work_start_= date_add('h',session.ep.time_zone,work_start_)>
				</cfif>

	<cfdocument format="pdf">
		<!---asd--->
		<table class="table" border="1" style="width:220mm	; height:8%; border-collapse: collapse;">
			<tr border="1">
				<td style="text-align:center; width:32%;"><cf_get_server_file output_file="../../images/birikim_logo.png" image_width="200" image_height="100" output_server="1" output_type="5"></td>
				<td style="text-align:center; width:36%;"><b>YILLIK ÜCRETLİ İZİN TALEP VE ONAY FORMU</b></td>
				<td style="text-align:center; width:32%;" ><cfoutput>#dateformat(get_offtime.record_date,dateformat_style)#</cfoutput></td>
			</tr>
		</table>
		<br/>
		<br/>

		<cfquery name="GET_POSITION" datasource="#dsn#">
			SELECT
				EMPLOYEE_POSITIONS.DEPARTMENT_ID,
				DEPARTMENT.DEPARTMENT_HEAD,
				EMPLOYEE_POSITIONS.POSITION_ID,
				EMPLOYEE_POSITIONS.POSITION_CODE,
				EMPLOYEE_POSITIONS.POSITION_NAME,
				EMPLOYEE_POSITIONS.EMPLOYEE_ID,
				EMPLOYEE_POSITIONS.EMPLOYEE_NAME,
				EMPLOYEE_POSITIONS.EMPLOYEE_SURNAME,
				EMPLOYEES.EMPLOYEE_NO,
				EMPLOYEES.EMPLOYEE_EMAIL,
				BRANCH.BRANCH_NAME,
				BRANCH.BRANCH_ID,
				BRANCH.COMPANY_ID
			FROM
				EMPLOYEE_POSITIONS,
				EMPLOYEES,
				DEPARTMENT,
				BRANCH
			WHERE
				EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
				EMPLOYEE_POSITIONS.POSITION_STATUS = 1 AND
				DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID
			<cfif isDefined("attributes.EMPLOYEE_ID") and len(attributes.EMPLOYEE_ID)>
				AND EMPLOYEES.EMPLOYEE_ID = EMPLOYEE_POSITIONS.EMPLOYEE_ID
				AND EMPLOYEES.EMPLOYEE_ID = #attributes.EMPLOYEE_ID#
			</cfif>
			<cfif isDefined("attributes.POSITION_CODE") and len(attributes.POSITION_CODE)>
				AND EMPLOYEE_POSITIONS.POSITION_CODE = #attributes.POSITION_CODE#
			</cfif>
		</cfquery>
		
		<cfquery name="GET_KIDEM" datasource="#DSN#">
			SELECT
				HesaplanmisKidemBaslangic
			FROM
				GET_EMPLOYEE_IN_OUT
			WHERE
				EMPLOYEE_ID=#get_offtime.employee_id#
		</cfquery>

		<!--- Şuanki tarihe göre yıllık izin hakediş tarihini hesaplıyoruz --->
		
		<cfscript>
			kıdem_date=GET_EMPLOYEE_INFO.KIDEM_DATE;
			now_date=now();
			diffA=dateDiff("YYYY", kıdem_date, now_date)
			year=diffA;
			diff_year=year;
			posdateresult=DateAdd("YYYY",diff_year,kıdem_date);
			diff_day=-1;
			hesaplanan_hekedis_date=DateAdd("d",diff_day,posdateresult);
		</cfscript>
		

				<style type="text/css">
					.tg  {border-collapse:collapse;border-spacing:0;}
					.tg td{border-color:black;border-style:solid;border-width:1px;font-size:16px;
					  overflow:hidden;word-break:normal;}
					.tg th{border-color:black;border-style:solid;border-width:1px;font-size:16px;
					  font-weight:normal;overflow:hidden;word-break:normal;}
					.tg .tg-c3ow{border-color:inherit;text-align:center;vertical-align:top}
					.tg .tg-7btt{border-color:inherit;font-weight:bold;text-align:center;vertical-align:top}
					.tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}
					.tg .tg-fymr{border-color:inherit;font-weight:bold;text-align:left;vertical-align:top}
					@media screen and (max-width: 100%) {.tg {width: auto !important;}.tg col {width: auto !important;}.tg-wrap {overflow-x: auto;-webkit-overflow-scrolling: touch;}}</style>
					<div class="tg-wrap"><table class="tg" style="undefined;table-layout: fixed; width: 100%">
					<colgroup>
					<col style="width: 22%">
					<col style="width: 35%">
					<col style="width: 2%">
					<col style="width: 2%">
					<col style="width: 40%">
					</colgroup>
					<thead>
					  <tr>
						<th class="tg-7btt" colspan="2">** Bu Bölüm İnsan Kaynakları Tarafından Doldurulacaktır</th>
						<th class="tg-0pky" rowspan="11"></th>
						<th class="tg-7btt" colspan="2">** Bu Bölüm Personel Tarafından Doldurulacaktır</th>
					  </tr>
					  <tr>
						<td class="tg-0pky">Personelin Adı</td>
						<td class="tg-0pky"><cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif></td>
						<td class="tg-c3ow" colspan="2" rowspan="10"><p style="text-align:right"><cfoutput>#dateformat(GET_OFFTIME.RECORD_DATE,dateformat_style)#</cfoutput></p><p style="text-align:center">İNSAN KAYNAKLARI MÜDÜRLÜĞÜNE</p><p style="text-align:left">Yıllık Ücretli İzin kullanma dönemim olan <cfoutput>#dateformat(izin_startdate_,dateformat_style)#</cfoutput>&nbsp; - &nbsp;<cfoutput>#dateformat(izin_finishdate_,dateformat_style)#</cfoutput> tarihleri arasında kullanmam gereken izin hakkımı &nbsp;"Talep Formu"nda beyan ettiğim günlerde kullanmak istiyorum. <br>Gereğini Arz Ederim.</p><p style="text-align:left">Saygılarımla.</p><p style="text-align:left">Personelin Adı : <cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif><br> İzin Talep Tarihi : <cfoutput>#dateformat(GET_OFFTIME.RECORD_DATE,dateformat_style)#</cfoutput></p><br><p style="text-align:left">İmza : <br><br><br></p></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">Görevi</td>
						<td class="tg-0pky"><cfoutput>#get_employee_info.POSITION_NAME#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İşe Giriş Tarihi</td>
						<td class="tg-0pky"><cfoutput>#dateformat(GET_KIDEM.HesaplanmisKidemBaslangic,dateformat_style)#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-fymr">Yıllık İzni Hak Ettiği Tarih</td>
						<td class="tg-0pky"><cfoutput>#dateformat(hesaplanan_hekedis_date,dateformat_style)#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İzin Başlangıç Tarihi</td>
						<td class="tg-0pky"><cfoutput>#dateformat(izin_startdate_,dateformat_style)#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İzin Bitiş Tarihi</td>
						<td class="tg-0pky"><cfoutput>#dateformat(izin_finishdate_,dateformat_style)#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İzin Gün Sayısı</td>
						<td class="tg-0pky"><cfoutput>#total_izin_#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-7btt" colspan="2">** Bu Bölüm Personel Tarafından Doldurulacaktır</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İrtibat Telefon No</td>
						<td class="tg-0pky"><cfoutput>#GET_OFFTIME.TEL_CODE# #GET_OFFTIME.TEL_NO#</cfoutput></td>
					  </tr>
					  <tr>
						<td class="tg-0pky">İzinde Bulunacağı Adres</td>
						<td class="tg-0pky"><cfoutput>#GET_OFFTIME.ADDRESS#</cfoutput></td>
					  </tr>
					</thead>
					</table></div>
					
		<cfif len(get_offtime.validator_position_code)>
			<cfset attributes.employee_id = "">
			<cfset attributes.position_code = get_offtime.validator_position_code>
			<cfquery name="GET_POSITION" datasource="#dsn#">
				SELECT
					EMPLOYEE_POSITIONS.DEPARTMENT_ID,
					DEPARTMENT.DEPARTMENT_HEAD,
					EMPLOYEE_POSITIONS.POSITION_ID,
					EMPLOYEE_POSITIONS.POSITION_CODE,
					EMPLOYEE_POSITIONS.POSITION_NAME,
					EMPLOYEE_POSITIONS.EMPLOYEE_ID,
					EMPLOYEE_POSITIONS.EMPLOYEE_NAME,
					EMPLOYEE_POSITIONS.EMPLOYEE_SURNAME,
					EMPLOYEES.EMPLOYEE_NO,
					EMPLOYEES.EMPLOYEE_EMAIL,
					BRANCH.BRANCH_NAME,
					BRANCH.BRANCH_ID,
					BRANCH.COMPANY_ID
				FROM
					EMPLOYEE_POSITIONS,
					EMPLOYEES,
					DEPARTMENT,
					BRANCH
				WHERE
					EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
					EMPLOYEE_POSITIONS.POSITION_STATUS = 1 AND
					DEPARTMENT.BRANCH_ID = BRANCH.BRANCH_ID
				<cfif isDefined("attributes.EMPLOYEE_ID") and len(attributes.EMPLOYEE_ID)>
					AND EMPLOYEES.EMPLOYEE_ID = EMPLOYEE_POSITIONS.EMPLOYEE_ID
					AND EMPLOYEES.EMPLOYEE_ID = #attributes.EMPLOYEE_ID#
				</cfif>
				<cfif isDefined("attributes.POSITION_CODE") and len(attributes.POSITION_CODE)>
					AND EMPLOYEE_POSITIONS.POSITION_CODE = #attributes.POSITION_CODE#
				</cfif>
			</cfquery>
			<cfset pos_temp = "#get_position.employee_name# #get_position.employee_surname#">
		<cfelse>
			<cfset pos_temp = "">
		</cfif>
		<table class="table" border="1" style="width:100%; height:6%; font-size:16;">
			<td style="width:20%"><p>DÜŞÜNCE VE ONAY</p></td>
			<td style="width:80%"><p>Kimliği yukarıda yer alan personelimizin, (bulunduğumuz yıl) Yılına ait yıllık ücretli izin hakkını <cfoutput>#dateformat(izin_startdate_,dateformat_style)#</cfoutput> tarihinde ayrılmak ve <cfoutput>#dateformat(izin_finishdate_,dateformat_style)#</cfoutput> tarihinde göreve başlamak kaydıyla kullanması uygundur.</p></td>
		</table>
		<br/>
		
		<table class="table" border="1" style="width:100%; height:10%; font-size:16;">
			<tr class="table" border="1" style="width:100%">
				<td style="text-align:center; width:33%; height:10%">
					<a>TALEP</a><br/>
					<a><cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif></b><br/><b><cfoutput>#get_employee_info.POSITION_NAME#</cfoutput></a><br/>
					<br/><br/><a>&nbsp;İmza</a>
				</td>
				<td style="text-align:center; width:33%">
					<a>ONAY</a><br/>
					<a><cfoutput>#get_emp_info(get_offtime.validator_position_code_1,1,0)#</cfoutput></b><br/><b><cfoutput>#get_offtime.AMIR1_POSITION_NAME#</cfoutput></a><br/>
					<br/><br/><a>&nbsp;İmza</a>
				</td>
				<td style="text-align:center; width:33%">
					<a>ONAY</a><br/>
					<a>Betül Altunsoy</a><br/><b>İnsan Kaynakları Müdürü</b><br/>
					<br/><br/><a>&nbsp;İmza</a>
				</td>
			</tr>
		</br>
		</table>
		<br/>
		<table class="table" border="1" style="width:100%; height:15%; font-size:16;">
			<tr>
				&nbsp;<td colspan="2"><p>2021 Yılına ait yıllık ücretli izin hakkımı <cfoutput>#dateformat(izin_startdate_,dateformat_style)#</cfoutput> Tarihi ile <cfoutput>#dateformat(izin_finishdate_,dateformat_style)#</cfoutput> Tarihleri arasında kullandım</p><p align="right">Personel</p><p align="right"><cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif></p></td>
			</tr>
			<tr style="text-align:center; height:10%">
				<td><a align="center">İmza</a></td>
				<td><a align="center">İş Başı Tarihi: <cfoutput>#dateformat(work_start_,dateformat_style)#</cfoutput></a></td>
			</tr>
		</table>
		
		<p><b>ÖNEMLİ NOT: </b>6331 Sayılı İş Sağlığı ve Güvenliği Yasası gereğince yıllık izin döneminde iş yerinde bulunmamanız nedeniyle başka işte çalışmanız ve Kaza geçirmeniz halinde SGK tarafından kaza ile ilgili sorumluluklar sizden tahsil edilmektedir. İzinde olacağınız süre sizin dinlenmeniz için verilmektedir. İyi tatiller dileklerimizle.</p>
		
	
	<cfdocumentitem type="footer" evalatprint="true">
		<table class="table" border="1" style="width:100%; font-size:16;">
			<tr>
				<td style="width:25%; text-align:center;">
					İK
				</td>
				<td style="width:50%; text-align:center;">
					<a>Sayfa : <cfoutput>#cfdocument.currentpagenumber#</cfoutput></a>
				</td>
				<td style="width:25%; text-align:center;">
					Form : İK
				</td>
			</tr>
		</table>
	</cfdocumentitem>
	</cfdocument>

<cfif isdefined('attributes.is_print')>
	<script type="text/javascript">
	function waitfor(){
	window.close();
	}	
	setTimeout("waitfor()",3000);
	window.print();
	</script>
</cfif>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#"><!--- sayfanin en ustunde acilisi var --->
"
