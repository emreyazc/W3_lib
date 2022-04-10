<!---Yunus Emre Yazıcı - Birikim Pilleri - Yıllık İzin Prosedürü Şablonu --->

<!---
<cfset attributes.ID = attributes.action_id>
<cfset attributes.ID = action_id>
--->
<cfset attributes.contract_id = attributes.action_id>

<!---
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
    SELECT
        M12
    FROM
        EMPLOYEES_SALARY
    WHERE
        EMPLOYEE_ID = #GET_CONTRACT.EMPLOYEE_ID# 
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
--->
<cfdocument format="pdf" marginTop = "1" marginBottom = "1">
<cfdocumentitem type="header" evalatprint="true">
	<table class="table" border="1" style="width:100% ; height:40% ;">
		<tr>
			<td rowspan="3" colspan="3" style=" text-align:center; width:100%;"><cf_get_server_file output_file="../../images/birikim_logo.png" image_width="235" image_height="112" output_server="1" output_type="5"></td>
			<td colspan="4" style="text-align:center"><b>BİRİKİM PİLLERİ YILLIK İZİN PROSEDÜRÜ</b>
				<tr>
					<td style="text-align:center;">Doküman No</td>
					<td style="text-align:center;">Sayfa No</td>
					<td style="text-align:center;">Revizyon No</td>
					<td style="text-align:center;">Yürürlülük Tarihi</td>
				</tr>
				<tr>
					<td style="text-align:center;">F46</td>
					<td style="text-align:center;"><cfoutput>#cfdocument.currentpagenumber#</cfoutput></td>
					<td style="text-align:center;">00</td>
					<td style="text-align:center;">01/07/2021</td>
				</tr>
			</td>
		</tr>
	</table>
</cfdocumentitem>

 
<cfdocumentitem type="footer" evalatprint="true">
	<table class="table" style="width:210mm; height:20mm; text-align:center" border="0">
		<tr style="align:left">
			<td style="text-align:left; width:210mm">Hazırlayan</td>
			<td style="text-align:left; width:210mm">Onaylayan</td>
		</tr>
		<tr style="align:left">
			<td style="text-align:left; width:210mm">YÖNETİM TEMSİLCİSİ:&nbsp;</td>
			<td style="text-align:left; width:210mm">GENEL MÜDÜR :&nbsp;</td>
		</tr>
		<tr></tr>
	</table>
</cfdocumentitem>
 <cfoutput>
	<cfdocumentsection>
	<h4>1. AMAÇ</h4>
	<p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu İzin Prosedürü’ nün amacı BİRİKİM PİLLERİ’ nde Şirketi‘nde personelin Yıllık Ücretli İzin, Sosyal İzin, Mazeret İzni, Ücretsiz İzin, Hastalık, Ölüm, Evlilik, Doğum, İdari İzinler vb. nedenlerle kullanılacak izinlerinin kullanımına yönelik yöntem ve esasları belirlemektir.
	</p>
	<h4>2. KAPSAM</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;İstanbul / Tuzla Organize Sanayi Bölgesinde bulunan Şirketimiz BİRİKİM PİLLERİ’ nde çalışanlar için Yıllık İzin ve Mazeret İzinleri ile ilgili Prosedürler yazılarak ve uygulamaya alınmıştır. Kullanılacak izinler yasada belirtilen Prosedüre uygun kullanılmalı ve tüm belgeler hazırlandıktan sonra İnsan Kaynakları Müdürlüğüne teslim edilmelidir. Belgeler İnsan Kaynakları tarafından onaylanması halinde geçerlidir.
        </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4857 Sayılı İş Kanunu hükümleri, 6331 Sayılı İş sağlığı ve Güvenliği, SGK uygulamaları bakımından İzin ile ilgili işlemler İzin Prosedürüne uygun olarak yapılmalıdır. Şirketimiz ve çalışanlarımızın zarar görmemeleri için önemli bulunmaktadır.
         </p>
        <p class="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>Şirketimizde sağlıklı ve huzurlu bir çalışma ortamı yaratmak, Prosedürlere uygun davranmak, hata yapmamak ve çıkabilecek sorunlara zamanında çözüm bulmak için bu kurallara tüm çalışanlarımızın uyması gerektiği; riskli durumlar, iş güvenliği ve işçi sağlığı yönünden uygulama yaparak izin kullanmanız oldukça önemlidir. Size sunulan bu İzin Prosedürü işyerinizde huzurlu bir çalışma ortamında uygulamaların anlatılması için hazırlanmıştır. Yöneticileriniz ve İnsan Kaynakları Birimi Yönetici ve çalışanları izin kullanımda sizlere yardımcı olacaktır. 
        </p>
        <p clas="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>
            Bu Prosedür; BİRİKİM PİLLERİ Bünyesinde alınan tüm izinleri kapsar.
        </p>
        <p clas="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>
            BİRİKİM PİLLERİ ekonomik koşullar gereği veya diğer sebepler ile yürürlükteki Prosedürleri revize edebilir, tamamen yürürlükten kaldırabilir, yerine farklı Prosedürler ikame edebilir. 
        </p>
        <p clas="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>
            BİRİKİM PİLLERİ’ nde de yürürlüğe giren tüm yönetmelik ve Prosedür vb. yayınlarda belirtilen uygulamalar, çalışanlar adına kazanılmış hak olarak değerlendirilemez.
        </p>
        <p clas="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;>
            BİRİKİM PİLLERİ yönetiminin yasal uygulamalar nedeniyle bu hakları değiştirme, sınırlandırma ve iptal etme hakkı saklıdır. 
        </p>
        <p class="paragraph"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;></p>
	<h4>3. SORUMLULUK VE YETKİLER</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu Prosedür’ de belirtilen usul ve esasların uygulanmasından İnsan Kaynakları Müdürlüğü ve tüm birimler sorumludur.
        </p>
    <h4>4. REFERANS DÖKÜMANLAR</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Yok. 
        </p>
    <h4>5.TANIMLAR</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.1 Yıllık Ücretli İzin</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Yıllık ücretli izine hak kazanabilmek için BİRİKİM PİLLERİ’ nde işe giriş tarihi itibariyle deneme süresi de dâhil olmak üzere en az bir tam yıl çalışmış olmak gerekmektedir.( Uzun Süreli Ücretsiz kullanılan izinler çalışma süresinden sayılmaz, Bu süre kadar ilave çalışma yapıldıktan sonra izne hak kazanılır)
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b) Yıllık izin Kullanma zamanı İşverenin Yönetim hakkı kapsamında İşverence belirlenir. İşçi tarafında başka zamanlarda kullanılmak istenirse durum uygun olması halinde işverence kullandırılabilir. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;c) Personelin çalışma süresine göre kullanabileceği yıllık ücretli izin süreleri aşağıdaki gibidir. 
        </p>
        <table style="width:80%; text-align:left; margin-left:20mm">
            <tr>
                <td>
                    a) 1 - 5 yıl çalışanlar (5. Yıl dahil)
                </td>
                <td>
                    14 gün
                </td>
            <tr>
                <td>
                    b) 6 -14 yıl çalışanlar (6. ve 14. Yıl dahil) 
                </td>
                <td>
                    20 gün                
                </td>
            </tr>
            <tr>
                <td>
                    c) 15 yıldan fazla çalışanlar (15. Yıl dahil) 
                </td>
                <td>
                    26 gün
                </td>
            </tr>
            <tr>
                <td>
                    d) 18 yaşından küçük çalışanlar en az
                </td>
                <td>
                    20 gün
                </td>
            </tr>
            <tr>
                <td>
                    e) 50 ve daha yukarı yaştakiler en az 
                </td>
                <td>
                    20 gün
                </td>
            </tr>
        </tr>
        </table>

        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;d) Kısmi süreli olarak çalışanlar Yukarıda yer verilen esaslara göre 14 gün içinde işe geldikleri gün sayısı kadar izin kullanmış olarak kabul edilir. (Yıllık izin Yönetmeliği 13. Maddesi)</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;e) ÖRNEK: Hafta içinde 3 gün işe gelen kısmı süreli çalışan 14 günde 6 gün işe gelmeden yıllık izin kullanır. Bu izin sürende hafta tatili ve Ulusal bayrama rastlayan günler yıllık izinden sayılmaz.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;f) Yıllık ücretli izin süresinin hesabında Cumartesi günleri iş günü olarak kabul edilir. Yıllık izin süresinden sayılır.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;g) Yıllık ücretli izin günlerinin hesabında izin süresine rastlayan Hafta Tatili, Ulusal Bayram ve Genel Tatil günleri izin süresinden sayılmaz. </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;h) Yıllık ücretli izinlerin, izne hak kazanma tarihinden itibaren 6331 sayılı ISG Konunu şartları nedeniyle bir yıl içerisinde en fazla 3’e bölünerek kullanılması zorunludur. İlk yıllık izin 10 günden az kullandırılamaz</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;i) Yıllık izinlerin yasada belirlenen şekilde kullanılması zorunludur. 1 er günlük izinler çok zorunlu olmadığı takdirde yasa hükmü gereğince kullanılamaz. (İdari para cezası ödenir) </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;j) Yıllık izinde bulunulan sürede başka bir işte çalışılması halinde iş kazası nedeniyle giderler SGK Tarafından işçiden talep edilmektedir. Bu nedenle personelimizin zor durumda kalmaması için dikkat etmesi kendi sağlığı açısından önemlidir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;k) İşin gerekleri sonucu, yıllık iznini hak kazandığı yıl içinde kullanamayan personele, işten ayrılması halinde, hak kazanarak kullanamadığı yıllık izinlere ilişkin ücret ödenir. Ancak bu durum sadece işten ayrılma döneminde hak edilen izinleri kapsar. Geçmiş dönemdeki izinlerin her yıl kullanılması yasal zorunluluktur.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;l) Kullanılacak yıllık ücretli izne ilişkin “Yıllık Ücretli İzin Talep ve Onay Formu” düzenlenir, ilgili bölüm yöneticisine imzalatılır ve İnsan Kaynakları Birimine teslim edilir. Ancak Dijital ortamda İK süreçleri ve Yasal Uygulamalar başladıktan sonra KEP Adresleri üzerinden İK Birimine talep ve onay verilecektir. </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m) Yıllık iznin kullanılması bağlı bulunulan Yöneticinin ve İnsan Kaynakları Yöneticisi’ nin onayına tabidir. İşin gerekleri nedeni ile uygun bulunmayan yıllık izin talepleri ertelenebilir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;n) Yıllık ücretli izinler, bir bölümü 10 günden az olmamak şartı ile en çok 3’e bölünebilir. </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;o) Yıllık ücretli izin kullanımı için “Yıllık Ücretli İzin Talep ve Onay Formu” personel tarafından izne çıkmadan en az 15 gün önce Dijital İK ortamında ise İK Yöneticisi tarafından onaylanması zorunludur.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;p) İnsan Kaynakları Birimi ilgili Yıllık İzin bilgilerini ait olduğu döneme ait bordro bilgilerine dahil eder. Bu nedenle izne çıkmadan 15 gün önce onay formu teslim edilerek onay alınması gerekmektedir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;q) İzinden dönen personelin izin bilgileri Yıllık Ücretli İzin Kartı’ na kaydedilmesi için İzin Kullandığı Hakkındaki Dijital bildirimi veya belge İK birimine gönderilmesi gerekir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;r) Yıllık izin süreleri ve kullanım şekli ile ilgili yasalarda yapılacak değişiklikler aynen uygulanacaktır</p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.2 Sosyal İzinler</b>
        </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;a) Aşağıda belirtilen hallerin belgelendirmesi şartı ile personele, belirtilen sürelerde sosyal izinler verilir. </p>
        <table style="border: 1px solid black; border-collapse: collapse; width:80%; text-align:left; margin-left:20mm">
            <tr>
                <td>1. Evlilik </td> <td>3</td><td>Gün</td>
            </tr>
            <tr>
                <td>2. Eş, çocuk, anne, baba ve kardeş ölümü</td> <td>5</td><td>Gün</td>
            </tr>
            <tr>
                <td>3. Eşin doğum yapması</td> <td>5</td> <td>Gün</td>
            </tr>
            <tr>
                <td>4. Çocuğunun evlenmesi</td> <td>5</td> <td>Gün</td>
            </tr>
            <tr>
                <td>5. Ev değiştirilmesi</td> <td>2</td> <td>Gün</td>
            </tr>
            <tr>
                <td>6. Çalışanın evlat edinmesi</td> <td>3</td> <td>Gün</td>
            </tr>
            <tr>
                <td>7. Kayınpeder-kayınvalide ölümü</td> <td>2</td> <td>Gün</td>
            </tr>
            <tr>
                <td>8. Çocuğunun evlenmesi</td> <td>2</td> <td>Gün</td>
            </tr>
            <tr>
                <td>9. % 70 Engelli Çocuğunun Tedavisi</td> <td>10</td> <td>Gün</td>
            </tr>
        </table>

        <p class="paragraph">Ayrıca en az yüzde yetmiş oranında engelli veya devam eden hastalığı olan çocuğunun tedavisinde, hastalık raporuna dayalı olarak ve çalışan ebeveynden sadece biri tarafından kullanılması kaydıyla, bir yıl içinde toptan veya bölümler hâlinde on güne kadar ücretli izin verilir.
        </p>
        <p class="paragraph">
            b) Yukarıda belirtilen hallerde kullanılacak izinlere ilişkin İzin Belgesi Dijital ortamda veya elle bildirilir. Mazeret izinlerinde ise ekine izin gerekçesine ait belgeler ilave edilir ve ilgili bölüm yöneticisi tarafından onaylandıktan sonra İnsan Kaynakları Birimine Dijital ortamda veya elle gönderilir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.3 Mazeret İzinleri</b>
        </p>
        <p class="paragraph">
            a) Birikim Pilleri tarafından çalışanlarına belirli süreli ücretli olarak mazeret izni hakkı tanınmıştır. Mazeret izinleri süresi bir tam yıl çalışma süresi içinde 22,5 saattir.
        </p>
        <p class="paragraph">
            b) Mazeret iznine hak kazanabilmek için Birikim Pillerinde en az 6 aylık çalışma süresini doldurmak gereklidir.
        </p>
        <p class="paragraph">
            c) 30 saatlik Mazeret izni bir çalışma yılı esasına dayalı olup, kullanılmayan sürelerin bir sonraki yıla devretmesi mümkün değildir
        </p>
        <p class="paragraph">
            d) Yıl içinde hak kazanılıp kullanılmayan mazeret izinlerine ilişkin herhangi bir ücret ödenmez ve talepte edilemez.
        </p>
        <p class="paragraph">
            e) Mazeret izni en kısa 1 saat olabilir. 1 saatin altındaki talep ya da kullanımlarda 1 saat olarak işlem yapılır.
        </p>
        <p class="paragraph">
            f) Tam günlük mazeret izinlerinde, makul ve kabul edilebilir bir gerekçe olması koşulu ile en fazla 1-2 gün olarak ardışık kullanılabilir.(Birim Yöneticisi ve İnsan Kaynakları Yöneticisinin onayları gerekmektedir) 
        </p>
        <p class="paragraph">
            g)Mazeret izni talep eden personel “Mazeret İzin Formu’ doldurarak imzalar, Bölüm Yöneticisi ve İnsan Kaynakları Yöneticisi’ ne gönderilerek Dijital ortamda KEP onayı alındıktan sonra izin kullanılır. Dijital İK onayı olmada izin kullanılması halinde bu izin geçerli kabul edilemez.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.4 Doğum İzni</b>
        </p>
        <p class="paragraph">
            a) Personelin Hamile olması halinde 8 Hafta doğum öncesi,8 Hafta doğum sonrası olmak üzere 16 Hafta doğum izni yasa gereğince bulunmaktadır. Personelin çalışabilecek durumda olması halinde 3 Haftaya kadar doktor tarafından çalışmasına izin verilir. Artan 5 hafta doğum sonrasına kalan doğum iznine ilave edilir.
        </p>
        <p class="paragraph">
            b) Doğum öncesi ücretsiz izin kullanılmaması gerekir. SGK böyle durumlarda Geçici iş görmezlik ödeneği ödemez.
        </p>
        <p class="paragraph">
            c) Bu sürede Alınan raporlar 3 gün içinde İK birimine Dijital ortamda veya elden gönderilir.
        </p>
        <p class="paragraph">
            d) Normal doğum sonrası 8 haftalık ek süre bulunmaktadır. Personelin talep etmesi halinde 6 ay ücretsiz izin talebi işveren tarafından onaylanır. Personelin ücretli izni bulunması halinde 6 aylık ücretsiz izinden sonra kullanılmalıdır. Aksi durumda ücretsiz izinler SGK tarafından kabul edilmemektedir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.5 Süt İzni</b>
        </p>
        <p class="paragraph">
            a) Kadın çalışanların doğum yaptıktan sonra doğumun gerçekleştiği tarihten başlayarak 1 yıl süreyle, bebeğin gelişimi süresince süt izni kullandırılır.
        </p>
        <p class="paragraph">
            b) Süt izni prensip olarak yasada öngörüldüğü şekli ile günde 1,5 saat olarak kullandırılır.
        </p>
        <p class="paragraph">
            c) Herhangi bir ücret kesintisi yapılmaz. Ücretli izindir.
        </p>
        <p class="paragraph">
            d) Kadın çalışanın yazılı talebi halinde, iş süreçlerinin aksamaması koşulu, İlgili bölüm yöneticisi ve İnsan Kaynakları Yöneticisinin onaylaması halinde 1,5 saatlik süt izinleri birleştirilerek, haftada 1 gün izin kullandırılabilir. Toplu süt izni kullandırılması yasalara aykırıdır.
        </p>
        <p class="paragraph">
            e) Süt izni kullanımı için ile ilgili personelin çocuğu bir yaşını tamamlayıncaya kadar emzirme izni için personelden talep yazısı alınarak işlem yapılır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.6 Ücretsiz İzin</b>
        </p>
        <p class="paragraph">
            a) 1 haftaya kadar Ücretsiz izin taleplerinde onay yetkisi bölüm yöneticisi ve İnsan Kaynakları Yöneticisine aittir. Ancak ücretsiz izin belgesinin İnsan Kaynakları Yöneticisi tarafından onaylanması ve izin öncesi personel dosyasına konması zorunludur.
        </p>
        <p class="paragraph">
            b) 1 haftayı aşan Ücretsiz izin taleplerinde onay makamı İnsan Kaynakları Yöneticisidir.
        </p>
        <p class="paragraph">
            c) Tüm ücretsiz izin talepleri mail ortamında veya elden verilerek yapılır.
        </p>
        <p class="paragraph">
            d) Tüm izinlere ilişkin bilgiler İnsan Kaynakları Birimi tarafından Dijital ortamda veya personel özlük dosyasında muhafaza edilir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.7 İstirahat Raporu ve İşbaşı</b>
        </p>
        <p class="paragraph">
            a) Hastalık nedeniyle aile hekimi, iş yeri hekimi, kamu hastanesi veya Sosyal Güvenlik Kurumu ile anlaşmalı bir özel sağlık kuruluşlarınca istirahat’ i uygun görülen çalışanın aldığı raporun bir kopyasının kişisel bilgi dosyalarında saklanması için 2 gün içinde mail ortamında veya elden İK birimine gönderilmesi gerekir. 
        </p>
        <p class="paragraph">
            b) Rapor alan personelin durumu, 2 gün içerisinde bölüm yöneticisi tarafından İnsan Kaynakları Birimine bildirilir.
        </p>
        <p class="paragraph">
            c) Özel doktorlardan alınan raporların geçerli olması için işyeri hekiminin onaylaması veya kamu hastanesi veya Sosyal Güvenlik Kurumu ile anlaşmalı bir özel sağlık kuruluşunun ilgili kliniğinde benzer bir tanı ve istirahat öngören rapor alınmalıdır.
        </p>
        <p class="paragraph">
            d) Maktu aylık ücret alan personelin hastalık sebebi ile raporlu olarak geçirilen istirahat süresinin ilk 2 günün işveren tarafından ödenir. 3’ üncü gün dahil olmak kaydı ile kalan günlerin ücreti SGK’ Tarafından Geçici İş Göremezlik ödeneğinden alınacaktır.
        </p>
        
    <h4>6. UYGULAMA</h4>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6.1. KAYITLARIN SAKLANMASI VE ARŞİVLENMESİ</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>6.1.1.</b> YT. kalite sistemi kapsamında yer alan prosedür, talimat ve diğer dokümanların uygulanması neticesinde ortaya çıkan kalite kayıtlarının hangi birimlerde, ne kadar süre saklanacağını, saklama süreleri dolan kalite kayıtlarının genel arşivde ne kadar süre saklanacağını sorumlularıyla beraber tanımlayan Kayıt Master Listesi (F04)’ni hazırlar.<p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>6.1.2.</b>  Hazırlanan liste bütün birimlere dağıtılır. Her birim kalite kayıtları listesinde tanımlanan ilgili kayıtları, öngörülen süreler kadar saklarlar. Basılı olarak saklanması gereken kayıtlar ilgili birimlerde, ulaşılabilir şekilde saklanır. Dijital olarak saklanan kayıtlar şirket serveri üzerinde saklanır. <p>
        <br><br>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6.2. ARŞİVLENEN KAYITLARA ULAŞIM</h4>
        <p class="paragraph">Basılı olarak saklanan kayıtlara ulaşım, ilgili departmanın yetkilisi tarafından sağlanır. Dijital kayıtlara ulaşım ise kullanılan ERP programı üzerinden yetkilendirme sınırı dahilinde sağlanır. </p>
    <h4>7. KAYITLAR</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>7.1. </b>Kayıt Master Listesi (F04)</p>
    <h4>8. REVİZYONLAR</h4>


<table style="width:100%; height:20%; border: 1px solid black; border-collapse: collapse;">
    <tr style="border: 1px solid black; border-collapse: collapse; height:20mm; ">
      <th style="width:20%; border: 1px solid black; border-collapse: collapse;">Rev. No</th>
      <th style="width:60%; border: 1px solid black; border-collapse: collapse;">Açıklama</th> 
      <th style="width:20%; border: 1px solid black; border-collapse: collapse;">Rev. Tarihi</th>
    </tr>
    <tr style="border: 1px solid black; border-collapse: collapse; height:20mm; ">
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;&nbsp;</td>
    </tr>
    <tr style="border: 1px solid black; border-collapse: collapse; height:20mm;">
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
    </tr>
  </table>

</cfdocumentsection> 
 </cfoutput>

</cfdocument>

