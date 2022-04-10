<!---Yunus Emre Yazıcı - Birikim Pilleri - Kıyafet Yönetmeliği Print Şablonu --->

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
			<td colspan="4" style="text-align:center"><b>BİRİKİM PİLLERİ TEMSİL VE GÖRÜNÜM KURALLARI YÖNETMELİĞİ</b>
				<tr>
					<td style="text-align:center;">Doküman No</td>
					<td style="text-align:center;">Sayfa No</td>
					<td style="text-align:center;">Revizyon No</td>
					<td style="text-align:center;">Yürürlülük Tarihi</td>
				</tr>
				<tr>
					<td style="text-align:center;">F45</td>
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
	<p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Birikim Pilleri çalışanlarının, iç ve dış müşterilere ve üçüncü şahıslara karşı tutumlarında, dürüstlük, onur anlayışıyla uyum içinde davranmaları ve Birikim Pilleri’ ni temsil etmeleri nedeniyle görünümlerine dikkat etmeleri esastır.Bu davranışlar yanında görev için firmaya geliş ve müşteriler veya kurumlarda Birikim Pilleri’ nin temsil edilmesi nedeniyle çevreye karşı duyarlı olmak, işyerine yakışır şekilde giyinmek ve bakımlı olmak zorunluluktur. Personelin özel yaşantılarında da Birikim Pilleri onuruna uygun şekilde davranmaları ön koşuldur.
	</p>
	<h4>2. KAPSAM</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Personel iç ve dış görevlerde şirketi temsil etmesi nedeniyle yaptığı işin önemine ve şirket kurallarına uygun davranışlar sergilemesi gerekmektedir. Müşteri firma personeli ve yöneticileri ile müşteri işyerinde ve şirketimizde yapılan görüşmelerde, 
       </p>
       <p class="paragraph">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Uyumlu davranışlar sergilemek
       </p>
       <p class="paragraph">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Kurum kültürüne uygun konuşmalar yapmak.
       </p>
       <p class="paragraph">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Tartışma ortamına girmemek.
       </p>
       <p class="paragraph">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sorunlu durumlarda yöneticilerinden fikir almak.
       </p>
       <p class="paragraph">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Davranışlarını göstermesi esas olmalıdır .
       </p>
	<h4>3. SORUMLULUK VE YETKİLER</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bu prosedürün uygulamasından tüm Birikim Pilleri Batarya San. Tic. Ltd. Şti. birim yetkilileri ve YT. sorumludur
        </p>    
    <h4>4. REFERANS DÖKÜMANLAR</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Yok. 
        </p>
    <h4>5.TANIMLAR</h4>
        <p class="paragraph">
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Şirketimizde genel kabul gören iş kıyafeti yönetmeliği kapsamında çalışanın firmadaki görevine göre hazırlanmış olan ‘’giyim kodları’’ aşağıdaki gibidir
        </p>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.1 Bussines / Kurumsal Resmi</h4>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Erkekler</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Takım elbise (tercihen gri/lacivert/siyah renklerde).</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Uygun renklerde pantolon blazer ceket.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Gömlek, kravat ve koyu renk çorap/ayakkabı şeklindedir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Klasik ayakkabı.</p><br>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bayanlar</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Etek/pantolon–ceket döpiyes veya uygun hırkalar/bluz ve döpiyes altına giyilecek ayakkabı ve çizme/bot şeklindedir. </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Koyu ve pastel renkler tercih edilmelidir.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sandalet/terlik tarzı ayakkabılar, abartılı aksesuar ve makyaj, iş görünümüne uymayan transparan/dekolte kıyafetler, mine etekler (diz üstü), kısa kollu bluzlar (ip askılı), göğüs dekolteli kıyafetler, bel ve göbek açık kıyafetler iş kıyafeti tanımına uymadığından özen gösterilmesi gerekmektedir. </p>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.2 Bussines Casual / Kurumsal Rahat </h4>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Erkekler</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Kumaş, keten ya da kanvas pantolon.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Uygun renklerde gömlek.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Loafer ya da Oxford ayakkabı.</p>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bayanlar</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Kumaş, keten ya da kanvas pantolon .</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Koyu ve pastel renkler tercih edilmelidir. </p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Ayakkabı loafer, Oxford ve ya babet tarzı.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Sandalet/terlik tarzı ayakkabılar, abartılı aksesuar ve makyaj, iş görünümüne uymayan transparan /dekolte kıyafetler, mine etekler( diz üstü), kısa kollu bluzlar (ip askılı), göğüs dekolteli kıyafetler, bel ve göbek açık kıyafetler iş kıyafeti tanımına uymadığından özen gösterilmesi gerekmektedir.</p>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5.3 Businnes Uniform / İş Üniforması</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Birikim Pilleri logolo T-shirt ve yelekler.</p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- Kumaş, keten ve yırtık olmayan Jean pantolonlar.</p>
        <p class="paragraph">Birikim Pilleri’, özel sektör ve Kamu Sektöründe hizmet vermekte ve çoğunlukla müşterileri veya diğer Birikim Pilleri’ firma temsilcileri ile iç ve dış görevlerde toplantı yapmakta veya destek hizmetleri için firmalarda bulunmaktadır.</p>
        <p class="paragraph">Birikim Pilleri’ çalışanlarının temsil görevleri ve firmalardaki işleri nedeniyle örnek davranışlar sergilemesi gerekmektedir. Şirketin dinamik yapısı nedeniyle personelimizin her zaman müşteri ziyareti ve toplantılar için görevlendirme ihtiyacı nedeniyle tüm çalışanların bu kurallara uyması gerekmektedir. İşyeri kuralları gereğince çalışanların iş güvenliği ve sağlığı kurallarına uymaları zorunluluktur. Çalışırken iş yapmanızı engelleyecek ve kazalara neden olacak kıyafetler giyilmemesi gereklidir. Unutulmaması gereken sizlerin iş sağlığı ve güvenliği bizim için ve kendi güvenliğiniz için önemlidir. </p>
        <p class="paragprah">Belirlenen temsil ve görünüm kurallarına uyulmaması Disiplin Kuralları Yönetmeliği, İş Güvenliği ve Sağlığı Kanunu ile İş Kanununda belirtilen Prosedürlere göre işlem yapılmasını gerektirmektedir.</p>
        <p class="paragraph">Yönetmelikte belirtilen şekilde davranmayan, yapılan ikazlara uymayarak hatalı davranışlar sergilenmesi durumunda sağlık ve güvenlik konularında alınacak tedbirlere tüm çalışanlarımızın gereken uymaları kendi sağlıkları ve güvenlikleri bakımından önemlidir. Bu nedenle personelimizin temsil ve görünüm kuralları içinde uyumlu çalışması temsil ve görünüm kurallarına özen göstermesi esastır. </p>
    <h4>6. UYGULAMA</h4>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6.1. KAYITLARIN SAKLANMASI VE ARŞİVLENMESİ</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>6.1.1.</b> YT. kalite sistemi kapsamında yer alan prosedür, talimat ve diğer dokümanların uygulanması neticesinde ortaya çıkan kalite kayıtlarının hangi birimlerde, ne kadar süre saklanacağını, saklama süreleri dolan kalite kayıtlarının genel arşivde ne kadar süre saklanacağını sorumlularıyla beraber tanımlayan Kayıt Master Listesi (F04)’ni hazırlar.<p>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>6.1.2.</b>  Hazırlanan liste bütün birimlere dağıtılır. Her birim kalite kayıtları listesinde tanımlanan ilgili kayıtları, öngörülen süreler kadar saklarlar. Basılı olarak saklanması gereken kayıtlar ilgili birimlerde, ulaşılabilir şekilde saklanır. Dijital olarak saklanan kayıtlar şirket serveri üzerinde saklanır. <p>
        <h4 class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6.2. ARŞİVLENEN KAYITLARA ULAŞIM</h4>
        <p class="paragraph">Basılı olarak saklanan kayıtlara ulaşım, ilgili departmanın yetkilisi tarafından sağlanır. Dijital kayıtlara ulaşım ise kullanılan ERP programı üzerinden yetkilendirme sınırı dahilinde sağlanır. </p>
    <h4>7. KAYITLAR</h4>
        <p class="paragraph">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>7.1. </b>Kayıt Master Listesi (F04)</p>
    <h4>8. REVİZYONLAR</h4>

<!-- CSS Code: Place this code in the document's head (between the 'head' tags) -->

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
    <tr style="border: 1px solid black; border-collapse: collapse; height:20mm;">
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
      <td style="border: 1px solid black; border-collapse: collapse;">&nbsp;</td>
    </tr>
  </table>

</cfdocumentsection> 
 </cfoutput>

</cfdocument>

