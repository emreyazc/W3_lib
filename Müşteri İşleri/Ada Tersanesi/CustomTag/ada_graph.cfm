<!---
	Date : 16.07.2026
	Desc : TEK GRAFIK CIZEN BASIT CUSTOM TAG (ECharts 5).
	       type parametresi ile pasta (pie), sutun (bar), cizgi (line) veya alan (area) grafik cizer.
	       Temel kullanimda sadece labels + values verilir, gerisi opsiyoneldir.

	Kullanim (temel - sadece zorunlu attribute'lar; listeler varsayilan olarak "|" ile ayrilir):
		<cf_ada_graph labels="Elektrikçi|Kaynakçı|İşçi" values="12|5|30">

	Kullanim (isteğe bağlı attribute'larla):
		<cf_ada_graph type="pie" title="Meslek Dağılımı" labels="Elektrikçi|Kaynakçı|İşçi" values="12|5|30">
		<cf_ada_graph type="bar" title="Aylık Üretim" labels="Ocak|Şubat|Mart" values="120|90|150" unit="Adet">
		<cf_ada_graph type="line" title="Günlük Giriş" labels="01/07|02/07|03/07" values="45|52|38" unit="Kişi">
		<cf_ada_graph type="area" title="Kümülatif Giriş" labels="01/07|02/07|03/07" values="45|97|135" unit="Kişi">

	Kullanim (alternatif - labels/values yerine dogrudan sorgu ile, liste/ayrac derdi yok):
		<cf_ada_graph query="#get_meslek_dagilimi#" label_column="MESLEK_ADI" value_column="KISI_SAYISI" type="pie" title="Meslek Dağılımı">

	=====================================================================================
	ZORUNLU ATTRIBUTE'LAR (her kullanimda verilmelidir):
	=====================================================================================
		labels       : Etiket listesi (örn. "Elektrikçi|Kaynakçı|İşçi"). Grafikteki dilim/sütun/nokta
		               isimleri bu listeden gelir.
		values       : Değer listesi (örn. "12|5|30"). Eleman sayısı labels ile AYNI olmalıdır,
		               yoksa tag hata fırlatır.

		Istisna: 'query' + 'label_column' + 'value_column' üçlüsü verilirse veri sorgudan okunur,
		         labels/values gerekmez (alternatif kullanım - aşağıda).

	=====================================================================================
	ISTEGE BAGLI ATTRIBUTE'LAR (verilmezse default degeri kullanilir, vermek sart degil):
	=====================================================================================
		type         : Grafik tipi: pie | bar | line | area. Default "pie".
		title        : Grafik başlığı. Default "" - verilmezse grafik başlıksız çizilir
		               (her raporda title kullanmak zorunda değilsiniz).
		subtitle     : Başlık altındaki küçük yazı (örn. tarih aralığı). Default "".
		height       : Grafik yüksekliği (px). Default 400.
		number_format: raw (varsayılan) | money. money; etiket, tooltip ve değer eksenini
		               Türkçe para biçiminde, iki ondalıkla gösterir. Veri ham sayı kalır.
		unit         : Değer birimi (örn. "Kişi" -> etikette "12 Kişi" yazar). Default "Kişi".
		               Farklı birim gerekirse (ör. "Adet") elle verilebilir.
		delimiter    : labels/values liste ayracı. Default "|" (etiketlerde/verilerde virgül
		               geçebileceği için virgül yerine bu güvenli varsayılan kullanılır).
		               Gerekirse "," gibi başka bir ayraca çevrilebilir. (query kullanımında gerekmez)
		label_width  : bar/line/area'da x ekseni etiketlerinin azami genişliği (px). Bu genişliği
		               aşan etiket "..." ile kısaltılır. Default 70. **0 verilirse kırpma tamamen
		               kapanır** ve etiket tam uzunluğunda çizilir - uzun firma/proje unvanları
		               için önerilen kullanım budur (grafiğe alttan yer açmak gerekebilir).
		               Pasta grafikte kullanılmaz.
		label_rotate : bar/line/area'da x ekseni etiketlerinin eğim açısı (derece). Verilmezse
		               3'ten fazla etiket varsa 30, değilse 0 uygulanır. Etiket genişletildiğinde
		               açıyı da artırmak (ör. 45) çakışmayı önler. Pasta grafikte kullanılmaz.
		name         : JS API kayıt anahtarı (window.adaGraphs['<name>']). Boş bırakılırsa otomatik üretilir.
		query        : Veri sorgusu. Verilirse labels/values yerine bu kullanılır.
		label_column : query verildiğinde etiketlerin okunacağı kolon adı (query ile birlikte zorunlu).
		value_column : query verildiğinde değerlerin okunacağı kolon adı (query ile birlikte zorunlu).
		color_universe : Olası TÜM etiketlerin sabit sıralı tam listesi (ör. sistemdeki
		                 tüm meslek adları, hep aynı sırada). Verilirse renk ataması hash yerine bu
		                 listedeki sıraya göre yapılır - aynı etiket her raporda/grafikte HER ZAMAN
		                 aynı rengi alır ve liste 30 sabit rengi aşsa bile (ek renkler otomatik
		                 üretilir) iki farklı etiket asla aynı rengi paylaşmaz (raporlar arası
		                 dahil). Verilmezse tag,
		                 SETUP_PARTNER_POSITION/COMPANY_PARTNER'daki TÜM meslek
		                 adlarını kendi içinde bir kez sorgulayıp (request scope'ta cache'leyerek)
		                 bu evreni otomatik kurar - meslek bazlı grafikler için caller'ın hiçbir
		                 şey vermesine gerek yoktur. Farklı bir etiket evreni (ör. aylar) gerekirse
		                 elle verilebilir.

	JS API (grafiği sayfadan güncellemek isteyenler için, örn. filtre butonları):
		var g = window.adaGraphs['benim_grafigim'];
		g.update(['A','B'], [3,5], 'yeni alt başlık')  -> grafiği yeni veriyle günceller
		g.resize()                                     -> kapsayıcı boyutu değiştiyse yeniden boyutlandırır
		g.getChart()                                   -> ECharts chart nesnesini döner (ileri kullanım)
--->
<cfif thisTag.executionMode neq "start"><cfexit method="exittag"></cfif>

<!--- ZORUNLU (query kullanilmiyorsa mutlaka verilmelidir) --->
<cfparam name="attributes.labels" default="">
<cfparam name="attributes.values" default="">

<!--- ISTEGE BAGLI (verilmezse default degeri kullanilir) --->
<cfparam name="attributes.type" default="pie">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.subtitle" default="">
<cfparam name="attributes.height" default="400">
<cfparam name="attributes.unit" default="Kişi">
<!--- raw: mevcut gösterim; money: 1.234.567,89. Sayısal veri değişmez. --->
<cfparam name="attributes.number_format" default="raw">
<cfif not listFindNoCase("raw,money",attributes.number_format)>
    <cfthrow message="cf_ada_graph: number_format raw veya money olmalıdır.">
</cfif>
<cfparam name="attributes.delimiter" default="|">
<cfparam name="attributes.label_width" default="70">
<cfparam name="attributes.label_rotate" default="">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.query" default="">
<cfparam name="attributes.label_column" default="">
<cfparam name="attributes.value_column" default="">
<cfparam name="attributes.color_universe" default="">

<cfif not listFindNoCase("pie,bar,line,area", attributes.type)>
	<cfthrow message="cf_ada_graph: 'type' attribute'u pie, bar, line veya area olmalıdır (gelen: #attributes.type#).">
</cfif>

<cfif isQuery(attributes.query)>
	<!--- Sorgu ile kullanim: etiket/deger dizileri sorgudan kurulur, liste/ayrac derdi yoktur --->
	<cfif not len(attributes.label_column) or not len(attributes.value_column)>
		<cfthrow message="cf_ada_graph: 'query' verildiğinde 'label_column' ve 'value_column' da verilmelidir.">
	</cfif>
	<cfif not listFindNoCase(attributes.query.columnList, attributes.label_column)>
		<cfthrow message="cf_ada_graph: sorguda '#attributes.label_column#' kolonu yok (kolonlar: #attributes.query.columnList#).">
	</cfif>
	<cfif not listFindNoCase(attributes.query.columnList, attributes.value_column)>
		<cfthrow message="cf_ada_graph: sorguda '#attributes.value_column#' kolonu yok (kolonlar: #attributes.query.columnList#).">
	</cfif>
	<cfif not attributes.query.recordCount>
		<div style="padding:15px;color:#666;">Kayıt Bulunamadı !</div>
		<cfexit method="exittag">
	</cfif>
	<cfset label_arr = arrayNew(1)>
	<cfset value_arr = arrayNew(1)>
	<cfloop from="1" to="#attributes.query.recordCount#" index="ag_row">
		<cfset arrayAppend(label_arr, attributes.query[attributes.label_column][ag_row])>
		<cfset arrayAppend(value_arr, attributes.query[attributes.value_column][ag_row])>
	</cfloop>
<cfelse>
	<!--- Liste ile kullanim (temel kullanim): labels ve values ZORUNLUDUR ve birlikte verilmelidir.
		Ikisinden yalnizca biri verilmisse bu bir caller hatasidir ve hata firlatilir; ikisi de
		bosse veri gelmemis demektir (gecerli calisma zamani durumu), grafik yerine mesaj basilir. --->
	<cfif (len(attributes.labels) gt 0) xor (len(attributes.values) gt 0)>
		<cfthrow message="cf_ada_graph: 'labels' ve 'values' zorunludur ve birlikte verilmelidir (yalnızca biri verilmiş).">
	</cfif>
	<cfif not len(attributes.labels)>
		<div style="padding:15px;color:#666;">Kayıt Bulunamadı !</div>
		<cfexit method="exittag">
	</cfif>

	<cfset label_arr = listToArray(attributes.labels, attributes.delimiter)>
	<cfset value_arr = listToArray(attributes.values, attributes.delimiter)>

	<cfif arrayLen(label_arr) neq arrayLen(value_arr)>
		<cfthrow message="cf_ada_graph: 'labels' (#arrayLen(label_arr)# eleman) ile 'values' (#arrayLen(value_arr)# eleman) aynı uzunlukta olmalıdır - ikisi zorunludur ve eleman sayıları eşit olmalıdır.">
	</cfif>
</cfif>

<!--- color_universe: ihtimal dahilindeki TUM etiketlerin sabit sirali listesi. Verilirse renk,
	hash yerine bu listedeki siraya (rank) gore atanir - liste 30 sabit rengi assa bile (JS
	tarafinda agColorForIndex ek renk uretir) cakisma matematiksel olarak imkansiz olur (hash'in
	aksine, sira zaten benzersizdir). Verilmezse, tag TUM meslekleri (SETUP_PARTNER_POSITION/COMPANY_PARTNER,
	tarih/filtreden bagimsiz, alfabetik) kendi icinde bir kez sorgulayip request scope'ta
	cachele-yerek evreni otomatik kurar - ayni sayfada birden fazla grafik olsa bile sorgu
	sadece 1 kez calisir. --->
<cfset universe_arr = arrayNew(1)>
<cfif len(attributes.color_universe)>
	<cfset universe_arr = listToArray(attributes.color_universe, attributes.delimiter)>
<cfelse>
	<cfif not structKeyExists(request, "ada_graph_position_universe")>
		<cfset request.ada_graph_position_universe = "">
		<!--- Bu tag meslek disi baglamlarda da kullanilabildigi icin (ör. aylik grafik), tablo
			bulunamazsa/erisilemezse sessizce hash moduna dusulur - chart kirilmasin. --->
		<cftry>
			<cfquery name="ada_graph_position_universe_qry" datasource="#dsn#">
				SELECT DISTINCT
					SPP.PARTNER_POSITION AS POSITION_NAME
				FROM
					COMPANY_PARTNER CP
					INNER JOIN SETUP_PARTNER_POSITION SPP ON CP.MISSION = SPP.PARTNER_POSITION_ID
				WHERE
					CP.COMPANY_PARTNER_STATUS = 1
					AND CP.MISSION IS NOT NULL
					AND CP.PDKS_NUMBER IS NOT NULL
					AND LTRIM(RTRIM(CP.PDKS_NUMBER)) <> ''
				ORDER BY
					SPP.PARTNER_POSITION
			</cfquery>
			<cfset request.ada_graph_position_universe = valueList(ada_graph_position_universe_qry.POSITION_NAME, "|")>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	<cfif len(request.ada_graph_position_universe)>
		<cfset universe_arr = listToArray(request.ada_graph_position_universe, "|")>
	</cfif>
</cfif>

<!--- Ayni sayfada birden fazla kullanimda element id'leri cakismasin diye instance kimligi --->
<cfif not structKeyExists(request, "ada_graph_count")>
	<cfset request.ada_graph_count = 0>
</cfif>
<cfset request.ada_graph_count = request.ada_graph_count + 1>
<cfset instance_id = "ag" & request.ada_graph_count>

<!--- JS API kayit anahtari: isim verilmediyse instance kimligi kullanilir --->
<cfif len(attributes.name)>
	<cfset registry_key = attributes.name>
<cfelse>
	<cfset registry_key = instance_id>
</cfif>

<!--- ECharts istek basina yalnizca bir kez yuklenir (request scope tag ile cagiran arasinda ortaktir) --->
<cfif not structKeyExists(request, "ada_graph_assets")>
	<cfset request.ada_graph_assets = true>
	<script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js" defer></script>
</cfif>

<cfoutput>
	<div id="adaGraph_#instance_id#" style="width:100%;height:#val(attributes.height)#px;"></div>
</cfoutput>

<script type="text/javascript">
	// IIFE: state global scope'a sizmasin, ayni sayfadaki diger instance'larla cakismasin.
	(function() {
		var agId = 'adaGraph_<cfoutput>#instance_id#</cfoutput>';
		var agKey = '<cfoutput>#jsStringFormat(registry_key)#</cfoutput>';
		var agType = '<cfoutput>#lcase(attributes.type)#</cfoutput>';
		var agTitle = '<cfoutput>#jsStringFormat(attributes.title)#</cfoutput>';
		var agSubtitle = '<cfoutput>#jsStringFormat(attributes.subtitle)#</cfoutput>';
		var agUnit = '<cfoutput>#jsStringFormat(attributes.unit)#</cfoutput>';
        var agNumberFormat = '<cfoutput>#lcase(attributes.number_format)#</cfoutput>';
        var agMoneyFormatter = new Intl.NumberFormat('tr-TR', {minimumFractionDigits:2,maximumFractionDigits:2});
		// Bos label_rotate = otomatik aci (asagida etiket sayisina gore belirlenir)
		var agLabelWidth = <cfoutput>#val(attributes.label_width)#</cfoutput>;
		var agLabelRotate = '<cfoutput>#jsStringFormat(attributes.label_rotate)#</cfoutput>';
		var agLabels = <cfoutput>#serializeJSON(label_arr)#</cfoutput>;
		var agValues = <cfoutput>#serializeJSON(value_arr)#</cfoutput>;
		var agUniverse = <cfoutput>#serializeJSON(universe_arr)#</cfoutput>;
		var agChart = null;

		// Sayfa genelinde (tüm cf_ada_graph çağrıları arasında) paylaşılan kayıt: aynı etiket
		// (ör. TAŞÇI) hangi grafikte önce çizilirse çizilsin HEP aynı rengi alır - rengin,
		// o etiketin agUniverse'te bulunup bulunmamasına ya da aynı pasta içindeki diğer
		// etiketlerle çakışıp kaymasına bağlı olarak grafikten grafiğe FARKLILAŞMASI artık
		// mümkün değil (önceden her grafik kendi 'used' setiyle bağımsız hesaplıyordu, bu
		// yüzden aynı meslek bir pastada yeşile bir diğerinde mora kayabiliyordu).
		window.adaGraphColorRegistry = window.adaGraphColorRegistry || { colorByLabel: {}, usedIdx: {} };

		function agNumberText(v) {
            if (agNumberFormat !== 'money') return String(v);
            if (v === null || typeof v === 'undefined' || v === '') return '';
            var number = Number(v);
            return Number.isFinite(number) ? agMoneyFormatter.format(number) : String(v);
        }
        function agValueText(v) {
            var text = agNumberText(v);
            return agUnit && text !== '' ? text + ' ' + agUnit : text;
        }

		// Sabit palet: aynı etiket (ör. meslek adı) her raporda/grafikte hep aynı rengi alsın diye
		// sıraya değil, etiket metninin hash'ine göre renk seçilir.
		// Her renk ayrı bir renk ailesinden (tek mavi, tek yeşil, vb.) - iki rengin
		// birbirine çok benzemesini (ör. iki farklı mavi tonu) önlemek için.
		var agPalette = [
			'#2a78d6', '#008300', '#e87ba4', '#eda100', '#1baf7a', '#eb6834', '#4a3aa7', '#e34948',
			'#009688', '#958900', '#994caa', '#03a9f4', '#c2185b', '#8bc34a', '#00bcd4',
			'#9d3434', '#006c95', '#b37fd2', '#8c387b', '#25984d', '#c75372', '#0094b9', '#dd7570',
			'#944400', '#6b46a0', '#00b1a4', '#7aa950', '#9765c6', '#4055ac', '#b05baa'
		];
		function agHashIndex(label) {
			var str = String(label);
			var hash = 5381;
			for (var i = 0; i < str.length; i++) {
				hash = (((hash << 5) + hash) + str.charCodeAt(i)) | 0;
			}
			return Math.abs(hash) % agPalette.length;
		}

		// Sabit paletin (30 renk) ötesindeki index'ler için: golden-angle ile HSL uzayında
		// ek, birbirinden ayrışan renkler üretilir. Böylece evrende (ör. meslek listesi)
		// 30'dan fazla farklı etiket olsa bile index modulo'lanmaz - her index gerçekten
		// benzersiz bir renge karşılık gelir, çakışma matematiksel olarak imkansız kalır
		// (önceden rank % agPalette.length yapıldığı için 30 sıra arayla duran iki etiket
		// - ör. ELEKTRİKÇİ ve TAŞÇI - aynı rengi paylaşıyordu).
		function agColorForIndex(idx) {
			if (idx < agPalette.length) return agPalette[idx];
			var golden = 0.6180339887;
			var extra = idx - agPalette.length;
			var hue = ((extra * golden * 360) % 360 + 360) % 360;
			var sat = 55 + (extra % 3) * 12;
			var light = 40 + (extra % 4) * 8;
			return 'hsl(' + hue.toFixed(1) + ',' + sat + '%,' + light + '%)';
		}

		// agUniverse verilmişse (ör. sistemdeki tüm meslekler, sabit sırayla) etiketin rengi o
		// listedeki SIRASINA göre belirlenir - sıra zaten benzersiz olduğu için (hash'in aksine
		// bilgi kaybetmez) ve agColorForIndex sabit 30 rengi aştığında yeni renk ürettiği için,
		// evren 30'u geçse bile çakışma matematiksel olarak imkansız olur: raporlar arası VE
		// aynı grafik içinde. agUniverse yoksa (bu tag'i genel amaçla, tam etiket evrenini
		// bilmeden kullanan diğer raporlar için) hash'e düşülür.
		function agPreferredIndex(label) {
			if (agUniverse.length) {
				var rank = agUniverse.indexOf(label);
				if (rank !== -1) return rank;
			}
			return agHashIndex(label);
		}

		// Etiketin tercih ettiği renk yukarıdan gelir; iki farklı etiket aynı renge denk
		// gelirse (agUniverse yokken hash çakışması ihtimali) ilk sahibi tercih rengini alır,
		// sonrakiler bir sonraki boş slota kayar - bu artık sadece o an render edilen tek
		// grafiğe değil, window.adaGraphColorRegistry üzerinden SAYFADAKİ TÜM grafiklere göre
		// yapılır, yani aynı etiket hangi grafikte önce görünürse görünsün rengi sabitlenir ve
		// sayfadaki hiçbir iki farklı etiket asla aynı rengi paylaşmaz.
		function agAssignColors(labels) {
			var reg = window.adaGraphColorRegistry;
			var colors = [];
			for (var i = 0; i < labels.length; i++) {
				var label = labels[i];
				if (reg.colorByLabel.hasOwnProperty(label)) {
					colors.push(reg.colorByLabel[label]);
					continue;
				}
				var idx = agPreferredIndex(label);
				while (reg.usedIdx.hasOwnProperty(idx)) {
					idx = idx + 1;
				}
				reg.usedIdx[idx] = true;
				var color = agColorForIndex(idx);
				reg.colorByLabel[label] = color;
				colors.push(color);
			}
			return colors;
		}

		function agBuildOption(labels, values, subtitle) {
			var option = {
                textStyle: { fontFamily: 'Arial, sans-serif', fontSize: 12, color: '#475569' },
				title: {
					text: agTitle,
					subtext: subtitle || '',
					left: 'center',
					top: 5,
					textStyle: { fontSize: 14, color: '#444' },
					subtextStyle: { fontSize: 12, color: '#666', fontWeight: 'bold' }
				}
			};

			if (agType === 'pie') {
				var pieColors = agAssignColors(labels);
				var data = [];
				for (var i = 0; i < labels.length; i++) {
					data.push({ name: labels[i], value: Number(values[i]), itemStyle: { color: pieColors[i] } });
				}
				option.tooltip = {
					trigger: 'item',
					formatter: function(p) {
						return p.name + ': <strong>' + agValueText(p.value) + '</strong> (' + p.percent + '%)';
					}
				};
				option.legend = {
					type: 'scroll',
					top: 48,
					left: 'center',
					itemGap: 14,
					textStyle: { fontSize: 12 }
				};
				option.series = [{
					type: 'pie',
					radius: ['30%', '54%'],
					center: ['50%', '58%'],
					avoidLabelOverlap: true,
					minAngle: 3,
					padAngle: 2,
					itemStyle: { borderRadius: 10 },
					label: {
						show: true,
						formatter: function(p) { return p.name + '\n' + agValueText(p.value); },
						fontSize: 13,
						lineHeight: 16
					},
					emphasis: { label: { fontSize: 15, fontWeight: 'bold' } },
					labelLine: { show: true, length: 10, length2: 8 },
					data: data
				}];
			} else {
				var nums = [];
				for (var j = 0; j < values.length; j++) {
					nums.push(Number(values[j]));
				}
				option.tooltip = {
					trigger: 'axis',
					formatter: function(params) {
						var p = params[0];
						return p.name + ': <strong>' + agValueText(p.value) + '</strong>';
					}
				};
				option.grid = { left: 30, right: 20, top: 70, bottom: 20, containLabel: true };
				var agAxisLabel = {
					rotate: agLabelRotate === '' ? (labels.length > 3 ? 30 : 0) : Number(agLabelRotate),
					interval: 0,
					fontSize: 12
				};
				// label_width 0 ise genislik/kirpma hic tanimlanmaz; ECharts etiketi tam uzunlugunda
				// cizer (uzun firma/proje unvanlari icin). 0'dan buyukse etiket o genislige kirpilir -
				// tag'in onceki davranisi.
				if (agLabelWidth > 0) {
					agAxisLabel.width = agLabelWidth;
					agAxisLabel.overflow = 'truncate';
				}

				option.xAxis = {
					type: 'category',
					data: labels,
					axisLabel: agAxisLabel
				};
				option.yAxis = { type: 'value' };
                if (agNumberFormat === 'money') {
                    option.yAxis.axisLabel = { formatter: agNumberText };
                }

				if (agType === 'bar') {
					var barColors = agAssignColors(labels);
					var barData = nums.map(function(v, idx) {
						return { value: v, itemStyle: { color: barColors[idx] } };
					});
					option.series = [{
						type: 'bar',
						data: barData,
						barMaxWidth: 60,
						itemStyle: { borderRadius: [4, 4, 0, 0] },
						label: {
							show: true,
							position: 'top',
							fontSize: 12,
							formatter: function(p) { return agValueText(p.value); }
						}
					}];
				} else {
					var lineSeries = {
						type: 'line',
						data: nums,
						smooth: false,
						symbolSize: 8,
						itemStyle: { borderColor: '#fff', borderWidth: 2 },
						label: {
							show: true,
							position: 'top',
							fontSize: 12,
							formatter: function(p) { return agValueText(p.value); }
						}
					};
					if (agType === 'area') {
						lineSeries.areaStyle = { opacity: 0.1 };
					}
					option.series = [lineSeries];
				}
			}

			return option;
		}

		function agRender() {
			if (!agChart) return;
			agChart.setOption(agBuildOption(agLabels, agValues, agSubtitle), true);
		}

		// Dışarıya açılan API: sayfa, grafiği yeni veriyle güncelleyebilir (örn. filtre butonları).
		window.adaGraphs = window.adaGraphs || {};
		window.adaGraphs[agKey] = {
			update: function(labels, values, subtitle) {
				agLabels = labels || [];
				agValues = values || [];
				if (typeof subtitle !== 'undefined') agSubtitle = subtitle || '';
				agRender();
			},
			resize: function() {
				if (agChart) { try { agChart.resize(); } catch (e) {} }
			},
			// Rapor özel yerleşimleri de aynı sayı biçimini kullanabilir.
            formatNumber: agNumberText,
            formatValue: agValueText,
            getChart: function() {
				return agChart;
			}
		};

		// echarts defer ile yüklendiği için grafik çizimi kütüphane hazır olana kadar bekletilir.
		// Sayfa AJAX ile yüklendiğinde DOMContentLoaded çoktan geçmiş olabileceğinden
		// readyState kontrolü + kısa aralıklı bekleme kullanılır.
		function agStart() {
			var waited = 0;
			var timer = setInterval(function() {
				if (window.echarts) {
					clearInterval(timer);
					var el = document.getElementById(agId);
					if (!el) return;
					agChart = echarts.init(el, null, {
                        renderer: 'canvas',
                        // Daha yüksek piksel yoğunluğu: ekran ve PNG/PDF aktarımı korunur.
                        devicePixelRatio: Math.max(2, window.devicePixelRatio || 1)
                    });
					agRender();
					if (window.ResizeObserver) {
						new ResizeObserver(function() {
							try { agChart.resize(); } catch (e) {}
						}).observe(el);
					} else {
						window.addEventListener('resize', function() {
							try { agChart.resize(); } catch (e) {}
						});
					}
				} else {
					waited += 50;
					if (waited >= 10000) {
						clearInterval(timer);
						var failEl = document.getElementById(agId);
						if (failEl) failEl.innerHTML = '<div style="padding:15px;color:#c00;">Grafik kütüphanesi yüklenemedi !</div>';
					}
				}
			}, 50);
		}

		if (document.readyState === 'loading') {
			document.addEventListener('DOMContentLoaded', agStart);
		} else {
			agStart();
		}
	})();
</script>
