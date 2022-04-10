<!--- 
    Description: İzin Talep Formu -  Personel Mazeret İzin Belgesi
    File: 6BD527D8-C6FC-7140-D4E2241DFCC7346F.cfm
    Author: Birikim Pilleri - Yunus Emre Yazıcı
    Date: 13.08.2021
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
			OC.NICK_NAME
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
		<table class="table" border="1" style="width:100% ; height:8%; border-collapse: collapse;">
			<tr border="1">
				<td style="text-align:center; width:15%;"><cf_get_server_file output_file="../../images/birikim_logo.png" image_width="200" image_height="100" output_server="1" output_type="5"></td>
				<td style="text-align:center; width:15%;"><b>PERSONEL MAZERET İZİN BELGESİ</b></td>
				<td style="text-align:center; width:15%;" ><cfoutput>#dateformat(get_offtime.record_date,dateformat_style)#</cfoutput></td>
			</tr>
		</table>
		<br/>
		<table class="table" border="1" style="width:100% ; height:5%; font-size:13;">
			<tr>
				<td style="text-align:center; background-color: rgb(235, 235, 235); width:50%" colspan="2">
					<b >Talepte Bulunan Personelin Bilgileri</b>
				</td>	
			</tr>
			<tr>
				<td style="text-align:center; width:50%;">
					<b>Adı Soyadı</b>
				</td>
				<td style="text-align:center; width:50%">
					<a>
						<cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif>
					</a>
				</td>
			</tr>
		</br>
		</table>
		<br/>
		<table class="table" border="1" style="width:100%; font-size:13;">
			<tr>
				<td style="text-align:center; background-color: rgb(235, 235, 235); width:100%" colspan="3">
					<b>Mazeret İzin Bilgileri</b>
				</td>
			</tr>
			<tr>
				<tr>
					<td style="text-align:left; width:33%;">
						&nbsp;<b>Mazaeret Bildirim Tarihi: </b>
					</td>
					<td style="text-align:left; width:33%;">
						<a><cfoutput>#dateformat(get_offtime.record_date,dateformat_style)# #timeformat(get_offtime.record_date,timeformat_style)#</cfoutput></a>
					</td>
					<td style="text-align:left; width:33%; height:10%"> <b>Mazeret Talebi Nedenleri</b></td>
				</tr>
				<tr>
					<td>&nbsp;<b>Mazeret İzin Süresi</b></td>
					<cfif diff  GTE 9>
						<td><cfoutput>#real_days# gün</cfoutput></td>
					<cfelse>
						<td><cfoutput>#diff# saat</cfoutput></td>
					</cfif>
					<td style="align-content:top" rowspan="6"><p><cfoutput>#get_offtime.detail#</cfoutput></p></td>
				</tr>
				<tr>
					<td>&nbsp;<b>Mazeret İznine Ayrılma Tarihi</b></td>
					<td><cfoutput>#dateformat(start_,dateformat_style)# #timeformat(start_,timeformat_style)#</cfoutput></td>
				</tr>
				<tr>
					<td>&nbsp;<b>Mazeret İzninden Dönüş Tarihi</b></td>
					<td><a><cfoutput>#dateformat(izin_finishdate_,dateformat_style)# #timeformat(izin_finishdate_,timeformat_style)#</cfoutput></a></td>
				</tr>
				<tr>
					<td><b>İşe Başlama Tarihi</b></td>
					<td><a><cfoutput>#dateformat(work_start_,dateformat_style)# #timeformat(work_start_,timeformat_style)#</cfoutput></a></td>
				</tr>
				<tr>
					<td><b>Çıkış Tarihi ve Saati</b></td>
					<td><a><cfoutput>#dateformat(start_,dateformat_style)# #timeformat(start_,timeformat_style)#</cfoutput></a></td>
				</tr>
				<tr>
					<td>&nbsp;<b>Mazeret İzni Süresince Yerine Görevlendirilen Personelin Adı</b></td>
					<td>-</td>
				</tr>
			</tr>
		</br>
		</table>
		<br/>
		<a style="font-size:13;"><b>Not 1 : </b>Personel Mazeret izni verilmesi ve süresinin belirlenmesi işverenin yetkisindedir.</a>
		<br/><br/>
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
		<table class="table" border="1" style="width:100%; height:5%; font-size:13;">
			<tr  style="background-color: rgb(235, 235, 235);">
				<td style="text-align:center; width:33%;">
					<b><cfif len(get_offtime.employee_id)><cfoutput>#get_emp_info(get_offtime.employee_id,0,0)#</cfoutput></cfif></b><br/><b><cfoutput>#get_employee_info.POSITION_NAME#</cfoutput></b>
				</td>
				<td style="text-align:center; width:33%;">
					<b><cfoutput>#get_emp_info(get_offtime.validator_position_code_1,1,0)#</cfoutput></b><br/><b><cfoutput>#get_offtime.AMIR1_POSITION_NAME#</cfoutput></b>
				</td>
				<td style="text-align:center; width:33%;">
					<b>Betül Altunsoy</b><br/><b>İnsan Kaynakları Müdürü</b>
				</td>	
			</tr>
		</table>
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
		<table class="table" border="1" style="width:100%; height:10%; font-size:13;">
			<tr class="table" border="1" style="width:100%">
				<td style="text-align:left; width:33%; height:10%">
					<a>&nbsp;İmza</a>
				</td>
				<td style="text-align:left; width:33%">
					<a>&nbsp;İmza</a>
				</td>
				<td style="text-align:left; width:33%">
					<a>&nbsp;İmza</a>
				</td>
			</tr>
		</br>
		</table>
		<br/>
		<a style="font-size:12;"><b>Not 2 : </b>Aşağıda yazılı mazeret izinler ücretli olarak kullandırılacaktr, bu izinlerin dışında izin verilmesi işverenin yetkisi dahilinde bulunmaktadır.</a>
		<br/><br/>
		<table class="table" border="1" style="height:15%; width:100%; font-size:13;">
			<tr></tr>
			<td style="width: 35%">
				&nbsp;<a>- Evlilik</a><br/>
				&nbsp;<a>- Eşinin, çocuğunun, anne, baba ve kardeşlerinin ölümü</a><br/>
				&nbsp;<a>- Evlat edinme</a><br/>
				&nbsp;<a>- Eşinin doğum yapması</a><br/>
				&nbsp;<a>- %70 Engelli Çocuğu olanlara</a><br/>
			</td>
			<td style="width: 15%">
				&nbsp;<a>3 Gün</a><br/>
				&nbsp;<a>5 Gün</a><br/><br/>
				&nbsp;<a>3 Gün</a><br/>
				&nbsp;<a>5 Gün</a><br/>
				&nbsp;<a>10 Gün / Yıl</a><br/>
			</td>
			<td style="width: 35%">
				&nbsp;<a>- Diğer izinler (Banka ve Resmi Kurum işleri)</a><br/>
				&nbsp;<a>- Kayınpeder- Kayınvalide </a><br/>
				&nbsp;<a>- Çocuğunun evlenmesi (Evrak ibrazı şarttır)</a><br/>
				&nbsp;<a>- Taşınma izni</a><br/>
			</td>
			<td style="width: 15%">
				&nbsp;<a>3 Güne kadar</a><br/><br/>
				&nbsp;<a>2 Gün</a><br/>
				&nbsp;<a>2 Gün</a><br/><br/>
				&nbsp;<a>3 Gün</a><br/>
			</td>
		</table>
		<br/>
	<a style="font-size:13;"><b>ÖNEMLİ NOT: </b>Mazeret izni alındığı taktirde yasa gereğinde dışarıda bulunduğunuz süreler işyerinde sayılmadığınız için İş Kazası olarak değerlendirilmemektdir. Bu nedenle dışarıda bulunduğunuz sürede riskli durumla karşılaşmamanız için kendinize ve sağlığınıza dikkat etmenizde fayda bulunmaktadır. İzin belgesini İnsan Kaynaklarına vermeden binadan ayrılmayınız.</a>
	
	<cfdocumentitem type="footer" evalatprint="true">
		<table class="table" border="1" style="width:100%; font-size:13;">
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
