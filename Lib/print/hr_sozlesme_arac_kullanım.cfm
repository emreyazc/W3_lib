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
			<td colspan="4" style="text-align:center"><b>ARAÇ KULLANIM TALİMATLARI</b>
				<tr>
					<td style="text-align:center;">Doküman No</td>
					<td style="text-align:center;">Sayfa No</td>
					<td style="text-align:center;">Revizyon No</td>
					<td style="text-align:center;">Yürürlülük Tarihi</td>
				</tr>
				<tr>
					<td style="text-align:center;">F47</td>
					<td style="text-align:center;"><cfoutput>#cfdocument.currentpagenumber#</cfoutput></td>
					<td style="text-align:center;">00</td>
					<td style="text-align:center;">01/07/2021</td>
				</tr>
			</td>
		</tr>
	</table>
</cfdocumentitem>

 
<cfdocumentitem type="footer" evalatprint="true">
	<table class="table" style="width:210mm; height:20mm; text-align:center; border: 1px solid black; border-collapse: collapse" >
		<tr style="align:left">
			<td style="text-align:left; width:210mm; background-color:lightgray;">Hazırlayan</td>
			<td style="text-align:left; width:210mm; background-color:lightgray;">Onaylayan</td>
            <td style="text-align:left; width:210mm; background-color:lightgray;">Personel</td>
		</tr>
		<tr style="align:left">
			<td style="text-align:left; width:210mm">&nbsp;</td>
			<td style="text-align:left; width:210mm">&nbsp;</td>
            <td style="text-align:left; width:210mm">&nbsp;</td>
		</tr>
		<tr></tr>
	</table>
</cfdocumentitem>
 <cfoutput>
	<cfdocumentsection>
	<h4>1. AMAÇ</h4>
	<p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu prosedürün amacı, Birikim Pilleri Batarya San. Tic. LTD. ŞTİ.’nde görev alan ve kendisine araç tahis edilen tüm personelin Araç Zimmet Sözleşmesi (Araç Kullanım Talimatı) imzaladıktan sonra araçları teslim alarak kullanmak ve kullanma talimatında yer alan tüm kurallara uymak zorundadır. Talimatlara uymayan, İş Sağlığı ve Güvenliği tedbirlerine dikkat etmeden araçları kullanan personel kaza yapması halinde sorumluluk taşımaktadır. Trafik kurallarında yer alan yasaklar dışında şirket tarafından belirlenen kurallara aykırı araç kullanan personel şirket sözleşmelerine aykırı araç kullanma dışında yasal Prosedürlere tabi olacaktır.
	</p>
	<h4>2. KAPSAM</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Prosedür ve talimatlarda kalite kaydı olarak tanımlanmış tüm dokümantasyonu kapsar.
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
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.1. Genel Kurallar</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Araçların temiz ve bakımlı tutulması zorunludur. (Motor, kaporta araç içi vb.)
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Araçların periyodik bakımlarının yaptırılmasında sorumluluk kullanıcıya aittir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. İş seyahatlerine çıkılmadan önce mutlaka aracın yağ, su vb. diğer kontrollerinin yapılması, şayet bir sorun var ise gerekli tamirat işlemi tamamlandıktan sonra yola çıkılması gerekmektedir. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. Araç kullanıcısı, bakım yaptırdıktan sonra ilgili bakım formunu doldurup yapılan bakımı kayıt altına almak zorundadır. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. Kullanıcı sürücü belgesini, araç ruhsatı ve bulundurulması yasal açıdan zorunlu diğer belge (Psikoteknik) ve ekipman ile araç dosyasını araç kullanımı sırasında daima yanında bulundurmakla yükümlüdür. Bu maddenin ihlali ile ilgili tüm cezai sorumluluklar kullanıcıya aittir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6. Araçların seyir halinde farları sürekli açık tutulmalıdır. Göreve çıkmadan önce, muhakkak far, fren, park ve sinyal lambalarını kontrol edilmelidir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7. Şirket aracını kullanması gereken herkes mutlaka "Araç Kullanım Talimatı" nı okumak ve imzalamak zorundadır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8. Araçlar, yönetimin belirlemiş olduğu şartlar ve amaçlar dışında kullanılamaz, şirket personeli haricinde 3.’cü kişilere verilemez.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9. Araçların içerisinde, yapılan işin mahiyetinin dışında veya şirket çalışanı dışında 3.kişiler bulunmamalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10. Şirket aracı ile ilgili seyahat ederken emniyet kemeri takılması zorunlu olup kemer takmadan araç kullanma halinde sorumluluk aracı kullanan personele aittir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;11. Alkol, uyuşturucu maddeler veya tedavi amaçlı uyku yapıcı ilaçlar alındıktan sonra araç kullanılamaz; .kullanımı halinde iş akdi derhal feshedilir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;12. Araç kullanıcısı her ayın ilk günü, orijinal ehliyetini (fotokopi değil) bağlı bulunduğu yöneticisine göstermek zorundadır. Sürücü belgesine el konulduğu takdirde bunu hemen bağlı bulunduğu amirine bildirmekle ve aracı idari işler birimine, bölgelerde bölge yöneticisine teslim etmekle yükümlüdür. Aksi takdirde oluşacak hukuki ve maddi tazminleri peşinen personele aittir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;13. OGS, HGS bulunan araçlarda cihazın arızalanması, kayıp olması veya kredi azalması durumunda idari işler birimine haber verilmeli ve arızalı cihaz ile otomatik geçiş yapılmamalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;14. Sürücü hatalarından kaynaklanan ve sigorta şirketi tarafından kabul edilmeyen parça, vb. malzeme bedeli ve bakım bedelleri kullanıcı tarafından tazmin edilir. (Lastik yarılması, jant hasarları, jant kapağı, sigara yanığı vb.) kullanıcı, aracı kendi özel işlerinde kullandığında araçla yaptığı tüm harcamaları şirketine ödemekle mükelleftir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;15. Kullanıcı kendisine zimmet edilmiş aracın, herhangi bir sebepten dolayı veya izinli olduğu sürelerde başkaları tarafından kullanıldığının araştırmasını yapmak ve varsa bu durumu tutanak ile yöneticisine bildirmek ve bu tutanağı idari işler birimine ulaştırmakla yükümlüdür. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>16. Kendisine zimmet edilmiş aracın şirket personeli olan diğer kişi tarafından kullanılabilmesi için, görev formunu, kullanma talebi olan kişinin amiri tarafından yazılı olarak onaylanmış olması gerekir. Araç görev formunu dolduran bir kişi o form iptal edilmeden başkasına araç veremez, kullandıramaz.</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;17. Araç tamir bakım faturalarının kendilerine teslim edilmesi durumunda faturalar yöneticisine teslim etmek ve merkez idari işler birimine ulaştırılmasının sağlanmasından sorumludur. Aksi takdirde faturaların kayıp olması ve/veya geç kalınmasından dolayı oluşacak muhasebe kayıtlarından kaynaklanan sorunların cezai sonuçları da kullanıcıya aittir. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;18. Aracın, bakım onarım amacıyla servise verilmesi halinde, ilgili servisten alınacak olan, servis giriş formunun aslını araç dosyasına koymak zorundadır. İlgili formun fotokopisi de idari işler birimine gönderilecektir. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;19. Belgesiz ve habersiz yapılan bir araba masrafı için kesinlikle ödeme yapılmaz.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;20. Kullanıcı, araç, arıza vb. durumlarda ilgili üst amirine bilgi vermeli, varsa talep vb. istekler idari işler biriminden yöneticisi vasıtası ile iletilmelidir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;21. Araç kullanıcısı, aracın periyodik bakım ve onarımlarında aracın lastik diş derinliğini kontrol ettirmekle yükümlüdür. 3 mm' nin altına düşen diş derinliklerini araç servis giriş formu tespit ederek, idari işler birimine bildirmek zorundadır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.2. İş Harici Kullanımlar</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Çalışanların; İş harici şirket araç kullanımı isteği çok benimsenmeyen bir durumdur. Özellikle sağlık, ivedi bir iş ve zorunlu durumlarda araba verilebilir. Bu durumda araç görev formu doldurulur, yapılan km hesaplanır ve söz konusu araç kullanıcısından yakıt bedeli istenir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.3. Trafik Cezaları</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Her türlü trafik cezası kullanıcıya ait olup, cezalar araç kullanıcısı tarafından ödenir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Kullanıcı kendisine zimmet edilen aracın www.gelirler.gov.tr/İnternet vergi dairesi ve Trafik denetleme Web sayfasından aracına ait trafik cezasının olup olmadığını her ay kontrol etmek ve gereğini yerine getirmek zorundadır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Kullanıcı İnternet üzerinden aracının durumunu gözlemlemek için gerekli olan bilgileri idari işler biriminden temin edilebilir. Ancak internet üzerinden alınan bilgilerin olası eksik veya hatalı olması durumunda Vergi Daireleri bilgileri kanunen esas alınır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. Kullanıcı trafik cezasına ait ödeme makbuzunun aslını trafik ceza tutanağının fotokopisi ile birlikte idari işler birimine yasal ödeme süresi içerisinde ödeyerek ulaştırmakla yükümlüdür.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. Trafik cezalarının ödemesinin internet ve banka şubelerinden yapılmaması, Vergi Dairelerinden yatırılması esastır. Zorunlu durumlarda ilgili bankalar aracılığı ile ödeme yapılabilir. Cezaların geç ödenmesi nedeni ile oluşacak yasal faizler de kullanıcı tarafından ödenir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6. Vergi dairelerinde ödenmiş trafik cezaları bazen ödenmemiş borç olarak gözükebilmekte ve yasal faizleri de işletilmektedir. Bu durumda borcun silinebilmesi için ceza ödeme makbuzunun aslının vergi dairesine ibrazı şarttır. Fotokopi ödeme makbuzu geçerli değildir. Aksi takdirde kullanıcı, borcun mükerrer ödemesini yapmak zorundadır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7. Trafik cezaları kullanıcıya bizzat ibraz edildiği gibi kullanıcıya ulaşılamadığı durumlarda posta kanalı ile de gelebilmektedir. Araç kullanıcısının haberi olmadan düzenlenen trafik cezalarında, idari işler birimi ceza tutanağının kendilerine ulaştığı andan sonra kullanıcıyı bilgilendirip, gerekli işlemleri yapar/yaptırır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8. İdari işler birimi, kendilerine ulaştırılmamış ceza ödeme makbuzlarından dolayı araç kullanıcılarını aramak veya haberdar etmek zorundan değildir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9. İdari işler birimi, trafik cezası bulunan aracın dosyasında ödeme makbuzu aslının olmaması durumunda trafik cezasını faizi ile birlikte vergi dairesine öder ve kullanıcıdan tazmini için muhasebe servisini bilgilendirir. Muhasebe servisi gerekli tazmini yapar.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10. Ödenen trafik cezalarına ait, ceza makbuzları ile ödeme makbuzlarının fotokopileri, araç dosyasının en arkasına eklenir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.4. Trafik Kazaları ve Yaptırımlar</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Trafik kazalarında mutlaka alkol muayenesi yaptırılmalı, kaza tutanakları olay yerinde tutturulmalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Evrakların aslı ve sigorta hasar dosya kayıt numarası öğrenilerek idari işler birimine, yetkililerine ve ilgili yöneticisine ulaştırılmalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Kaza, ilgili tüm yöneticilere bildirilmelidir. Kazayı yapanlar arası tutanak veya anlaşma, resmi bir işlem yapılmalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.5. Kaza Raporu</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. Kaza raporu okunarak teslim alınmalıdır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Kaza durumunda ilgili ilk yönetici (bölgelerde bölge yöneticisi) olay ile ilgili görüş ve düşüncelerini belirterek, tutanağın fotokopisi ile birlikte idari işler birimine ulaştırmak zorundadır. 
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Kazanın gerçekleştiği tarihte güzergâhı ve uğranılan noktalar belirtilmelidir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. Uygunsuz araç kullanmaktan doğan herhangi bir kaza durumunda; tutanakta belirtilen kusur dağılım oranının %50'den fazla olması halinde sürücü, kazadan kaynaklanan giderleri ve varsa 3. kişilere ödenecek tazminatları karşılamakla yükümlüdür.
            
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. %50 oranını aşan kazadan sonra araç bir daha verilmemek üzere geri alınır.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6. Kaza harici oluşan hasarlarda idari işler biriminden bilgi alınarak Prosedürler yerine getirilmelidir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>5.6. Araç Kaza Dosyasındaki Belgeler</b>
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Kaza sonrası ayrıntılı kaza raporu doldurularak idari işler birimine iletilmelidir.
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. İş Akdine Sebep Olan İhlaller
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. Alkol ve uyuşturucu, uyku yapıcı ilaçların etkisinde araç kullanmak,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3. Şirket itibarını sarsacak şekilde araç kullanmak,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4. Kazaların sürekliliği ve kusur oranı,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. Trafik cezalarının sürekliliği,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6. Ehliyetsiz ve ruhsatsız araç kullanmak,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7. Gerçek olmayan beyanlar,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;8. Emniyet Kemeri takılmaması,
        </p>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;9. Şirket yönetimi, yukarıda belirtilen maddelerin herhangi birinin ihlalini iş akdi fesih nedeni olarak geçerli kılabilir.    
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

