<!---Yunus Emre Yazıcı - Birikim Pilleri - Belirsiz Süreli Yönetici İş Sözleşmesi Print Şablonu --->

<!---
<cfset attributes.ID = attributes.action_id>
<cfset attributes.ID = action_id>
--->
<cfset attributes.contract_id = attributes.action_id>

<cfquery name="GET_CONTRACT" datasource="#DSN#">
	SELECT
        *
	FROM
		EMPLOYEES_CONTRACT
	WHERE
		<!---CONTRACT_ID = #attributes.ID#--->
        CONTRACT_ID = #attributes.contract_id#
</cfquery>

<cfquery name="GET_EMPLOYEE" datasource="#DSN#">
    SELECT
        EMPLOYEE_ID,
        EMPLOYEE_NAME,
        EMPLOYEE_SURNAME,
        GROUP_STARTDATE
    FROM
        EMPLOYEES
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID#
</cfquery>

<cfquery name="GET_EMPLOYEE_IN_OUT" datasource="#DSN#">
    SELECT
        *
    FROM
        EMPLOYEES_IN_OUT
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID#    
</cfquery>

<cfquery name="GET_EMPLOYEE_SALARY" datasource="#DSN#">
    SELECT TOP (1)
        M12
    FROM
        EMPLOYEES_SALARY
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID#
    ORDER BY SALARY_HISTORY_ID DESC
</cfquery>

<cfquery name="GET_MONEYS" datasource="#DSN#">
	SELECT
		MONEY_ID,
		MONEY
	FROM
		SETUP_MONEY
	WHERE
		PERIOD_ID = #SESSION.EP.PERIOD_ID#
</cfquery>

<cfquery name="GET_EMPLOYEE_POSITIONS" datasource="#DSN#">
    SELECT 
        POSITION_NAME 
    FROM 
        EMPLOYEE_POSITIONS
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID# 
</cfquery>

<cfquery name="GET_EMPLOYEE_ADDRESS" datasource="#DSN#">
    SELECT
        HOMEADDRESS
    FROM
        EMPLOYEES_DETAIL
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID#    
</cfquery>

<cfquery name="GET_BRANCH" datasource="#dsn#">
	SELECT 
		EMPLOYEE_POSITIONS.POSITION_NAME,
		EMPLOYEE_POSITIONS.TITLE_ID,
		DEPARTMENT.DEPARTMENT_HEAD,
		BRANCH.BRANCH_NAME,
		OUR_COMPANY.COMPANY_NAME
	FROM
		EMPLOYEE_POSITIONS,
		DEPARTMENT,
		BRANCH,
		OUR_COMPANY
	WHERE
		EMPLOYEE_POSITIONS.EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID# AND
		EMPLOYEE_POSITIONS.DEPARTMENT_ID = DEPARTMENT.DEPARTMENT_ID AND
		BRANCH.BRANCH_ID = DEPARTMENT.BRANCH_ID AND 
		BRANCH.COMPANY_ID = OUR_COMPANY.COMP_ID 
</cfquery>

<cfdocument format="pdf" marginTop = "1" marginBottom = "1">
<cfdocumentitem type="header" evalatprint="true">
	<table class="table" border="1" style="width:100% ; height:40%">
		<tr>
			<td rowspan="3" colspan="3" style="text-align:center; width:100%;"><cf_get_server_file output_file="../../images/birikim_logo.png" image_width="235" image_height="112" output_server="1" output_type="5"></td>
			<td colspan="4" style="text-align:center"><b>Belirsiz Tam Süreli Yönetici İş Sözleşmesi</b>
				<tr>
					<td style="text-align:center;">Doküman No</td>
					<td style="text-align:center;">Sayfa No</td>
					<td style="text-align:center;">Revizyon No</td>
					<td style="text-align:center;">Yürürlülük Tarihi</td>
				</tr>
				<tr>
					<td style="text-align:center;"><cfoutput>#GET_CONTRACT.CONTRACT_NO#</cfoutput></td>
					<td style="text-align:center;"><cfoutput>#cfdocument.currentpagenumber#</cfoutput></td>
					<td style="text-align:center;">003</td>
					<td style="text-align:center;">01/07/2021</td>
				</tr>
			</td>
		</tr>
	</table>
</cfdocumentitem>

<cfdocumentitem type="footer" evalatprint="true">
	<table class="table" style="width:210mm; height:20mm; text-align:center" border="0">
		<tr style="align:left">
			<td style="text-align:left; width:210mm">Personel</td>
			<td style="text-align:left; width:210mm">İş Veren / Vekili</td>
		</tr>
		<tr style="align:left">
			<td style="text-align:left; width:210mm"><cfoutput>#GET_EMPLOYEE.EMPLOYEE_NAME# #GET_EMPLOYEE.EMPLOYEE_SURNAME#</cfoutput></td>
			<td style="text-align:left; width:210mm">Kadem Usta</td>
		</tr>
		<tr></tr>
	</table>
</cfdocumentitem>
 <cfoutput>
	<cfdocumentsection>
        <p>
            <h4>1.Taraflar</h4>
               <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;İşverenin Adı ve Adresi : BİRİKİM PİLLERİ BATARYA SANAYİ VE TİCARET LİMİTED ŞİRKETİ Adres: Tepeören Mah. İstanbul Tuzla Organize Sanayi Bölgesi (İTOSB) 4. Cadde No: 8 Tuzla /İstanbul adresinde bulunan şirket merkezi, bundan sonra  BİRİKİM PİLLERİ  Merkez Ofisi işyeri olarak anılacaktır.
               </p>
               <p class="paragraph">Personelin Adı Soyadı ve Adresi : <i style="color:red"><b>#GET_EMPLOYEE.EMPLOYEE_NAME# #GET_EMPLOYEE.EMPLOYEE_SURNAME# -</b></i> <i style="color:red"><b>#GET_EMPLOYEE_ADDRESS.HOMEADDRESS#</b></i>
               </p>

            <h4>2. Yapılacak İşin Yeri Ve Konusu</h4>
               <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Personel, gerek bu sözleşmenin hükümleri gerekse 4857 sayılı İş Kanunu 6331 Sayılı İş sağlığı ve Güvenliği Kanunu,6698 Sayılıl Kimlik Verileri Koruma Kanunu ile ilgili diğer mevzuat,şirket yönetmelikleri ve kuralları çerçevesinde BİRİKİM PİLLERİ işyerinde  “Belirsiz Süreli İş Sözleşmesi.”  İle   BİRİKİM PİLLERİ’  İşyerinde <i style="color:red"><b>#GET_EMPLOYEE_POSITIONS.POSITION_NAME#</b></i> Görevi ile çalışmayı kabul ve taahhüt eder. 
              </p>
              <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Personel, gerekli görüldüğünde, işverenin diğer işyerlerinde de  çalışmayı kabul eder. İşyerinin bu hüküm çerçevesinde değiştirilmesi iş şartlarında esaslı değişiklik veya iş şartlarının uygulanmaması olarak öne sürülemez.
              </p>
              <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Bu durum iş sözleşmesinde esaslı bir değişiklik  veya iş şartlarının uygulanmaması olarak kabul edilemez. Personel görev değişikliği sonrasındakı ücret ve yasal haklarının aynen uygulanmasını kabul eder.
              </p>
              <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Personel T.C sınırları içerisinde olmak kaydıyla İŞVEREN tarafından görev verilecek yerlerde sözleşme hükümlerine göre çalışmaya seyahat engel hali bulunmadığını kabul eder. Ayrıca bu görevlendirme nedeniyle ek ücret ve iyileştirme talep etmeden çalışacağını peşinen kabul ve beyan eder.
              </p>
              <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) Personel, bu Sözleşme’de belirtilen görevi herhangi bir ek deyim, eğitim ve belgeye ihtiyaç olmaksızın yapabileceğini, bu görev için gerekli vasıflara sahip olduğunu, kendisi tarafından düzenlenerek onaylanan ve bu sözleşmenin ayrılmaz bir parçası olan İş Başvuru formundaki tüm bilgilerin gerçeğe uygun olduğunu, aksinin tespiti halinde, bu durumun işverene haklı sebeple İş Sözleşmesi’ni derhal feshetme yetkisi verdiğini kabul, beyan ve taahhüt eder. 
              </p>
           
            <h4>3. İşin Türü Ve Kapsamı</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Personel  , <i style="color:red"><b>#GET_EMPLOYEE_POSITIONS.POSITION_NAME#</b></i> Personeli olarak  Belirsiz Tam Süreli Hizmet Sözleşmesi ile yöneticileri  tarafından verilecek görev kapsamında BİRİKİM PİLLERİ işyerinde  işin gereklerine göre  belirtilen her türlü işi yapmayı kabul eder. Personel   İşin yapılması sırasında gelişmelere uygun olarak görev tanımında yapılacak tüm işleri yerine getirmek zorundadır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) BİRİKİM PİLLERİ’ nin <i style="color:red"><b>#GET_BRANCH.BRANCH_NAME#</b></i> işyerinde  Personelin yaptığı iş ve bağlı bulunduğu ofis açısından genel merkez ya da şube/bayi olarak, yönetim ve organizasyon gereği geçici veya devamlı olarak değiştirilebilir. Personel kendisine bu konuda verilecek talimata uymayı peşinen kabul eder.
               </p>
           
               <h4>4. Ücret.</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) İşveren, gördüğü işe karşılık olarak Personel’e, Aylık Maktu ücret  ödemeyi kabul eder.  Ayda Tam süreli, çalışma karşılığı <i style="color:red"><b>#TLFORMAT(GET_EMPLOYEE_SALARY.M12)# #GET_MONEYS.MONEY#</b></i>(brüt)/Net ücret üzerinden hesaplanacak net ücret  ödenecektir. Çalışılan süreye ilişkin ücret, bir sonraki ayın 12’inci gününe kadar Personel’in banka hesabına  yatırılarak ödenir. Personel bu hizmetleri karşılığında her ay verilen ücret dışında herhangi bir ücret talep edemez.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Yönetici’ye verilen aylık  ücret içerisinde  ücret ve yan unsurlar dahil olarak belirlenmiştir. Ücret dışında Personel   fazla çalışma ücreti talep edemez. Ulusal Bayram ve genel Tatil Günü çalışılması halinde her gün için 1 günlük ücret ödenir 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Ücret,  her ayın ilk haftasında önceki aya ait çalışma karşılığı aylık net ücret banka hesabına yatırılır. Ücretin Personel ’a  ödenmesinden sonra ödenen tutara 7 gün içinde yazılı olarak itiraz etmeyen Personel   bordro’nun doğruluğunu ve alacağının bu miktarda olduğunu kabul eder.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) İşveren, İş Kanunu gereğince ücret bordrosunu Dijital  ortamda veya manuel olarak  Personel ’a vermek zorunda bulunduğu için Personel; ücretinin ödenmesinden itibaren bordrosunu onaylamak zorundadır. Dijtal ortam çalışması sonrasından bordro dijital ortamda gönderilir. Personel   verilen sürede itirazda bulunmaması halinde ilgili aya ait başkaca  alacağı bulunduğunu ileri süremez.
               </p>
               <p class"paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e) Yöneticilerin ücretleri, işlerin organizasyonu ve görevlerinin yerine getirilmesi için yöneticilik  görevi ve ünvanı esas alınarak belirlenmiştir. Asıl olan işlerini gün içerisinde tamamlamaları gerekmesi nedeniyle görevin gerektirdiği fazla çalışma,ofis bünyesinde veya görevin ifası gereği yapılan seyahat dönemlerindeki fazla çalışmalar ücrete dahil olarak değerlendirilmektedir.   Yasal düzenlemeler ve yargı kararlarının bu yönde olması nedeniyle yönetici tarafından ücret kapsamı içerisinde kalan fazla çalışma ücreti talep edilemez.
               </p>
           
               <h4>5. Süre</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu sözleşme Belirsiz Tam Süreli bir iş sözleşmesidir ve Personel  <i style="color:red"><b>#dateformat(GET_EMPLOYEE_IN_OUT.START_DATE,dateformat_style)#</b></i> tarihinde işe başlamıştır.
               </p>
               
               <h4>6. Deneme Süresi </h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Taraflar; İşveren ve Personel Tam Süreli İş Sözleşmesi kapsamında fiilen işe başlama tarihi olan <i style="color:red"><b>#dateformat(GET_EMPLOYEE_IN_OUT.START_DATE,dateformat_style)#</b></i> itibaren 2 aylık süreyi deneme süresi olarak kararlaştırmışlardır. Sözleşme yasa kapsamında 2 aylık deneme süresi içinde işveren veya Personel tarafından herhangi bir gerekçe ileri sürmeden, bildirimsiz ve tazminatsız olarak feshedilebilir. Bu süre içerisinde feshedilen sözleşmeler için ihbar tazminatı ödenmemesi yasa  maddelerinde belirlenmiştir.
               </p>
               
               <h4>7. Çalışma Düzeni</h4>
               <p>Çalışma süresi; haftada 45 saat olmak üzere çalışma yapılacaktır. Personel  tespit edilen günlük ve haftalık çalışmalarına ve düzenlemelere uymak zorundadır.</p> 
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a)  Günlük çalışmanın başlangıcı ve sonu ile ara dinlenmesinin zamanı işverence yasada yer verilen    yemek ve çay molaları işverence kullandırılır. Bu süreler çalışma süresinden sayılmaz.     
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Personel, işveren tarafından belirlenen çalışma saatlerine uymaması,çalışmaya  geç gelmesi ya da gelmemesi halinde çalışılmayan günler için ücret ödenmez ücretsiz izinli olarak kabul edilir.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) İşverenin ve vekillerinin gerek işin yapılmasına gerekse çalışma yapılan işyerinin düzeni ve güvenliğine yönelik olarak verilecek talimatlara Personel  uymakla yükümlüdür. Bunlara aykırı davranış sözleşmenin feshine yol açar.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Personel, işveren tarafından belirlenen çalışma saatlerine uymaması,çalışmaya  geç gelmesi ya da geçerli bir rapor ibraz etmeden çalışmaya gelmemesi halinde çalışılmayan günler için ücret ödenmez ücretsiz izinli olarak kabul edilir..
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) Personel, Tehlikeli durumlarda tedbir alınması için yöneticisine bildirimde bulunduğu gibi görevlendirmeyi yapan yönetici’ yi bilgilendirdikten sonra verilecek talimatlara göre çalışacaktır.
               </p>
                   
               <h4>8. Personel’in Sorumluluğu</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Personel, işyerinde her türlü koruyucu önlemleri almakla yükümlüdür. Arızalı veya bozuk araç gereç ve malzemeleri kullanamaz, bu gibi durumları işverene bildirerek tedbir almasını sağlandıktan sonra çalışma yapabilir. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Personel, görevin ifasında şirket talimatlarına ve yönetmeliklerine , genel politikalarına ve İşveren tarafından berlirlenen çalışma kurallarına uyacağını kabul ve taahhüt eder.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c. Personel,  kendi kusuru ve ihmali nedeniyle sebep olduğu zararların ücretinden doğrudan kesilerek giderilmesini kabul eder. İşverenin yasal hakları saklıdır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d. Personel,  eğitimlerde kullanılan eğitim meteryallerini işverenin onayı olmadan işyerinin ve eğitim yerinin dışına çıkaramaz, başkalarına veremez, çoğaltamaz, başkalarının eline geçmesini engelleyecek her türlü tedbiri almak zorundadır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e. Personel, kendisine emaneten verilmiş olan makine, malzeme ve benzeri demirbaş eşyayı işverenin talebi üzerine derhal veya iş sözleşmesinin sona ermesinde ayrıca bir isteme gerek olmaksızın iade eder.
               </p>
               
               <h4>9. Personel ’in Yükümlülüğü</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Personel, Yönetmeliği ve görev tanımlarını,oryantasyon kitabını, disiplin yönetmeliğini  okuduğunu; buralardaki ilke ve kurallara uyacağını belirtir.  Personelin  başka bir işyerinde işverenin izni olmadan çalışamaz. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Personel, şirkette veya şirket araçları ile seyahatte,servislerle taşınması sırasasında,işçi sağlığı ve iş güvenliği önlemlerine uymakla yükümlüdür. İş güvenliği önlemlerine uymayan Personel uyarıları dinlemediği takdirde  işveren’in haklı nedenle fesih hakkı bulunduğunu kabul eder.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c. Personel   şirkete verdiği bilgi veya belgelerde, ikamet ve diğer değişiklikleri 7 gün  içerisinde işverene bildirmek zorundadır. Aksine davranış işyeri kurallarına aykırı davranış sayılır,
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d. Personel; İş Sağlığı ve Güvenliği için eğitimi ile ilgili işbaşı oryantasyon eğitimi almak ve eğitiminde  belirtilen kurallara uymakla yükümlüdür. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e. Eğitimde ve yönetmeliklerde belirtilen iş sağlığı ve güvenliği kurallarına uymak, yöneticileri tarafından verilen İş sağlığı ve güvenliği kurallarına ile ilgili talimatlara göre hareket etmek zorundadır. Aksi davranışlar işyeri kurallarına aykırı davranış oluşturur.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;f. Personel kullanılan makine teçhizatının tehlike arz etmesi halinde yöneticilerine haber vermek, tamiri sağlandıktan sonra kullanmak zorundadır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;g. Personel’ ının  görevini  ve yükümlülüklerini yerine getirmemesi,hatalı davranması,işe özen borcununu yerine getirmemesi,halinde iş sözleşmesinin haklı nedenle feshi dışında işverenin bu konuda uğrayacağı her türlü müspet-menfi,doğrudan ve dolaylı zararından sorumlu olduğunu kabul eder. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;h. Ücreti işveren tarafından karşılanarak yöneticinin  gelişimi için özel  eğitime gönderilen yönetici  eğitim veya seminer tarihinden itibaren işin önem derecesine göre belirlenecek süre kadar çalışmak zorundadır. Bu süre ve şartlar personele eğitime gönderilmesi aşamasında protokol ile belirlenecektir. Personel belirlenen bu süre kadar çalışmadığı takdirde eğitim bedelini veya kararlaştırılacak miktarı ödemekle mükelleftir.Bu madde sadece özel eğitime gönderilenler için geçerlidir.
               </p>
                   
               <h4>10.Yıllık İzin Kullanımı</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Personel ’ın, Yıllık ücretli izin, mazeret izni gibi izin haklarının kullandıırlması ve zamanının belirlenmesi   işveren yönetim hakkı gereğince işverenin yetkisinde bulunmaktadır. Personel   işveren tarafından belirlenen tarihlerde yıllık izinlerini kullanır. İzin kullanımı için Personel tarafından ıslak imzalı ya da yazılı olarak tutulan yıllık izin formlarının ve işverenin onayı şarttır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Yıllık izinler bir bölümü 10 günden aşağı olmamak üzere işveren tarafından kullandırılır.  
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Yıllık izin kullanımı 4857 Sayılı İş kanunu 53 maddesi ve Yıllık izin Yönetmeliğinde belirlenen şekilde kullandırılır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) Yıllık izin kullanım günlerinde, başka işyerinde çalışma halinde iş kazası geçirilmesi veya meslek hastalığına yakalanma durumunda  iş kazası ile ilgili sorunlarda işyerimiz sorumlu olmadığı gibi SGK tarafından tüm masraflar çalışandan talep edilmektedir.  Bu nedenle Yıllık izine çıkarken veya Mazeret izni kullanırken belgelerinizi insan kaynakları birimine teslim etmeden  İşyerinden ayrılmayınız.
               </p>
           </br></br>
               <h4>11.İşverenin Yükümlülüğü</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. İşveren Personel’e işçilik haklarını ödemek, ahlak ve iyiniyet kurallarına uymak, iş sağlığı ve iş güvenliği tedbirlerini almakla yükümlüdür.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. İşveren 4857 sayılı İş kanunu ve yönetmeliklerde öngörülen yıllık izinler ve  ücretli olarak belirlenen aşağıdaki izinleri ücretli olarak kullandırılır.
               </p>
               <p class="paragraph">
                   <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1) Evlilikte 3 gün, 
                   <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2) 1 Derece Yakınların ölümünde 3 gün,
                   <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3) Çoçuğu olan baba için 5 gün,
                   <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4) Evlat edinme 3 gün,
                   <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5) % 70 engelli çocuğu olanlar için 1 yılda 10 gün,
                   <br><p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ücretsiz izin hakkı işverene ait olup bu sürelerle ilgili ücret ödenmez.</p> 
               </p>
               <h4>12. Kıdem Tazminatından Sorumluluk</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;İşveren Personel’ in kıdem ve yıllık ücretli izne hak kazanabilmek bakımından <i style="color:red"><b>#dateformat(GET_EMPLOYEE_IN_OUT.START_DATE,dateformat_style)#</b></i> tarihinin esas alınacağını kabul eder.
               </p>
               <h4>13. Ticari Sırların Korunması Ve Gizlilik</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. Personel, İşveren, İşverenin idareci, sahipleri ve müşterileri ile bunların her birinin işleri, hesapları, mali durumları, meslek sırları, faaliyetleri, anlaşmaları, işlemleri veya menfaatlerine ilişkin herhangi bir bilgiyi kesinlikle gizli tutacağını ve bunları gerek kendi lehine, gerekse başkası lehine doğrudan veya başka bir şahıs aracılığıyla ifşa etmemeyi, kullanmayacağını, yaymayacağını, yayınlamayacağını veya başka bir şekilde ifşa etmeyeceğini kabul ve beyan eder. Çalışan istihdam süresi boyunca yaptığı çalışmalar ve/veya istihdamı dolayısıyla elde ettiği bilgi ve belgeleri çalışmanın sona ermesinden sonra da dahil olmak üzere hiçbir surette üçüncü şahıslara iletmeyecek ve söz konusu bilgi ve belgelerin üçüncü şahısların eline geçmemesi için gerekeni yapacağını kabul ve taahhüt eder.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Personel, gerek işyerinde çalışırken, gerek işyerinden ayrıldıktan sonra işverene zarar veren davranışlarda bulunmamak, kanun yada resmi düzenlemeler çerçevesinde yapılacak açıklamalar hariç olmak üzere, iş ve/veya işyeri ile ilgili olarak öğrendiği her türlü bilgiyi saklamakla ve üçüncü kişilere doğrudan ya da dolaylı olarak açıklamamakla ve bildirmemekle yükümlüdür.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c. 3Personel işyeri bünyesinde kendi bölümünde ya da diğer bölümlerde çalışan kişi ya da kişilere aktaracağı bilgi, o kişi ya da kişilerin sahip olması gereken bilginin üzerinde ve fazlasında bilgi sahibi olmayacaktır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d. Personel, gerek kendi ücret miktarını, gerekse işi nedeniyle öğrendiği diğer işçilerin ücret miktarını da saklamakla ve başkalarına doğrudan ya da dolaylı olarak açıklamamakla ve bildirmemekle yükümlüdür
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e. 5Personel’ın, işbu madde kapsamındaki yükümlülüklerini ihlal etmesi halinde işverenin tazminat davası açma hakkı saklı tutar
               </p>  
               <h4>14. Rekabet Yasağı</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Personel, bu sözleşme süresince, işin sırlarına vakıf olması nedeniyle İşveren ile doğrudan rekabet teşkil edecek faaliyetlerden uzak duracak, İşveren ile aynı alanda faaliyet gösteren rakip bir müessesede ve İşverenin müşteri portföyündeki bir şirkette her ne sıfatla olursa olsun görev almayacaktır. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Personel, gerek bu sözleşme süresince, gerekse sözleşmenin hangi sebeple olursa olsun sona ermesinden sonra,  Şirket’in ticari itibarını, ürünlerini ve hizmetlerini zedeleyecek bir hareket ve açıklamalarda bulunmayacaktır. 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Personel, işbu Sözleşme fesih edildikten sonra, fesih sebebine bağlı kalmaksızın, Şirket’le akdi ilişkisi bulunan hiçbir çalışanına, şirket ile akdi ilişkisini sona erdirmesi hususunda ikna etmeye çalışmayacak, teklif veya tavsiyede bulunmayacaktır.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) Personel, işbu madde kapsamındaki yükümlülüklerini ihlal etmesi halinde işverenin tazminat davası hakkı saklı tutar.
               </p>
               <h4>15. İş Sözleşmesinin Haklı Nedenle Feshi</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Personel’in  işverenin talimatlarına uymaması, sır saklama yükümlülüğüne aykırı davranması,
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) İşveren veya çalışanlardan herhangi biri hakkında asılsız isnadlarda bulunması, şeref ve namusuna dokunacak sözler sarfetmesi,
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) İşverenin güvenini kötüye kullanması, doğruluk ve bağlılığa aykırı davranışlarda bulunması, 
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) İzin almaksızın ve haklı nedene dayanmaksızın arka arkaya 2 gün veya bir ayda aralıklı 3 iş günü işe gelmemesi,  
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e) Görevleri kendisine hatırlatıldığı halde yapmaması,buna benzer davranışlar göstermesi,
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;f) Ayrıca 4857 Sayılı iş Kanunun 25 maddesindeki diğer fiillerin varlığı  halinde tazminatsız olarak işveren tarafından iş sözleşmesi  feshedilebilir. 
               </p>
       
               <h4>16. Ücret Kesintisi</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;İşveren;  Personel ’ın  iş sözleşmesi şartlarını veya işyeri yönetmeliklerini ihlal ederek veya işveren talimatlarına aykırı davranarak işverene, işyerine veya işveren vekiline zarar vermesi halinde Personel  in ücretinden 4857 sayılı İş Yasasının 38 maddesindeki esaslara dayanarak ücret kesintisi yapabilecektir.
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;İşveren; Personel ’ın işten ayrılması sırasında yapılacak ücret ve benzeri ödemelerden şirkete olan borçlarını kesmek veya mahsup etmek hakkına sahiptir.
               </p>
               <h4>17. Kişisel verilerin Koruması</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a. 6698 Sayılı Kimlik Verilerinin Korunması Kanununun 28. Maddesi 2’ inci fıkrasında yer verilen İstisna kapsamında  olan ve paylaşılması gereken kimlik verilerinin belirtilen kurumlara verilmesi zorunludur. Bu nedenle işveren tarafından verilecek bilgilerin yasaya aykırı olmadığı ve bu konuda işverene karşı herhangi bir yükümlülük getirmediğini personel kabul eder.  
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b. Personel, kişisel verilerinin, işbu maddede belirtilen İşveren ve grup Şirketlerin ilgili departmanları tarafından, özlük haklarının düzenlenmesi, kayıt altına alınması ve genel anlamda değerlendirilebilmesi maksadıyla İşveren tarafından işlenmesine ve arşivlenmesini onayladığını ve bu konuda iş verene yetki tanıdığını kabul ve beyan eder.       
               </p>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c. Kimlik Verileri Koruma Kanunu gereğince işveren tarafından yapılacak bilgilendirme formu  Personel tarafından imzalandıktan sonra bir örneği kendisine verilmiştir.
               </p>
       
               <h4>18. Genel Yollama</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu sözleşmede düzenlenmeyen konularda İnsan Kaynakları Yönetmeliği, Disiplin Yönetmeliği, Oryantasyon kitabı  ile  4857 sayılı İş Kanunu,6098 sayılı Borçlar kanunu 6331 sayılı iş sağlığı ve Güvenliği Kanunu,6698 Sayılı Kimlik Verileri Koruma Kanunu ve yönetmelikler ile ilgili hükümleri uygulanır.
               </p>
       
               <h4>19. Tebligat Adresi</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Personel , sözleşmede yazılı adresinin yasal tebligat adresi olduğunu, İnsan Kaynakları Birimine herhangi bir adres değişikliği bildirmediği taktirde, sözleşmedeki adrese yapılacak tebligatların hukuken geçerli ve bağlayıcı olduğunu kabul eder. Şirket dijital dönüşümü sonrasında elektonik ortamda ve şahsi olarak verilecek mail adresine yapılacak bildirimlerin yasal olarak geçerli olduğunu kabul eder. Dijital ortamda gönderilecek maillerin yasal olarak geçerli olduğunu ve işveren tarafından istenilen bilgi ve belgeleri  zamanında cevaplandırmayı kabul eder. 
               </p>
       
               <h4>20. Uyuşmazlıkların Çözümü</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Taraflar bu sözleşmeden doğacak uyuşmazlıkların çözümünde İstanbul Anadolu Yakası Mahkemeleri ve İcra Daireleri  yetkili olduğunu taraflar kabul eder.. 
               </p>
       
               <h4>21. Sözleşme Maddeleri</h4>
               <p class="paragraph">
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Yirmi maddeden oluşan bu sözleşme <i style="color:red"><b>#dateformat(GET_EMPLOYEE_IN_OUT.START_DATE,dateformat_style)#</b></i> tarihinde iki nüsha olarak düzenlenerek imzalanmış  ve bir örneği Personel ’a  verilmiştir. 
               </p>
               </p>
</cfdocumentsection> 
 </cfoutput>

</cfdocument>

<style>

.content {
    width: 210mm;
    font-size: 13px;
}
.paragraph {
    text-indent: 20px;
}
</style>