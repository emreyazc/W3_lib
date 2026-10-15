<!---
	Date : 20.07.2026
	Desc : TEK TABLO CIZEN INTERAKTIF CUSTOM TAG - arama, yatay scroll, sayfa kaydirilirken
	       sabit kalan baslik, istege bagli canli toplam satiri ve sayfalama.

	KULLANIM
	--------
	type="1" (varsayilan): tag satirlari query'den kendi cizer, caller hicbir <tr> yazmaz.
		<cf_ada_table query="#get_totals#" columns="COMPANY_NAME,EVENT_DATE,TOTAL_PERSON"
			labels="FİRMA,TARİH,TOPLAM KİŞİ" aggregate_column="TOTAL_PERSON" show_totals="1">

	type="2": basligi ve satirlari caller hazirlar, attribute olarak gecer (head/labels + rows).
	Araya ara toplam/ayrac satiri sokulabilir. Baslik head="..." (bir <thead> ici HTML) ya da
	labels ile, satirlar rows="..." ile verilir; HTML once <cfsavecontent> ile toplanir.
		<cfsavecontent variable="my_head"><tr><th data-at-col="TOPLAM KİŞİ">Toplam Kişi</th></tr></cfsavecontent>
		<cfsavecontent variable="my_rows"><cfoutput query="q"><tr><td data-at-col="TOPLAM KİŞİ">#TOPLAM#</td></tr></cfoutput></cfsavecontent>
		<cf_ada_table type="2" head="#my_head#" rows="#my_rows#" show_totals="1" total_columns="TOPLAM KİŞİ" aggregate_column="TOPLAM KİŞİ">
	Baslik head ile (cok satirli/colspan'li olabilir) ya da labels'tan uretilir (head varsa
	labels yok sayilir).
	CANLI TOPLAM (show_totals): toplanacak her <td> - ve head modunda ayrica her <th> -
	data-at-col="<anahtar>" tasir; deger textContent'ten ya da data-at-val'dan okunur.
	total_columns/aggregate_column bu anahtarlarla verilir (labels modunda anahtar = baslik
	metni). data-at-col olmayan hucreler/satirlar toplamlara hic karismaz. Toplam satirinin
	hucre sayisi ve sutun sirasi gercek <thead>'den okunur.

	ATTRIBUTE'LAR
	-------------
	query/columns/labels : type=1 zorunlu (columns ile labels ayni uzunlukta olmali).
	                       Bos query hata degildir, empty_message basilir.
	group_column         : (type=1) verilirse bu kolon ayri bir sutun olarak CIZILMEZ; degeri
	                       her degistiginde tablonun tamamini kaplayan bir grup basligi satiri
	                       basilir. Query'nin bu kolona gore sirali gelmesi beklenir. Caller'in
	                       proje/kategori basina ayri tablo cizmesine ya da grup satirlarini
	                       elle uretmesine (type=2) gerek kalmaz.
	type                 : 1 (varsayilan) | 2. type=2'de query/columns yok sayilir; baslik icin
	                       head YA DA labels zorunludur.
	head, rows           : (type=2) caller'in hazir baslik/satir HTML'i, default "".
	                       head type=1 ile verilirse hata firlatilir.
	show_totals          : 0/1, default 0. Sayfa toplami + genel toplam satirlari.
	total_columns        : toplanacak kolon/anahtar listesi. type=1'de bos birakilirsa
	                       tespit edilen TUM sayisal kolonlar toplanir. Ekrandaki "Topla"
	                       kutucuklariyla kullanici bunu canli degistirebilir.
	aggregate_column     : "ana toplam" kolonu - kutucugu yoktur, kapatilan diger toplam
	                       kolonlarinin toplami bundan otomatik dusulur.
	page_size            : default 20.        title : tablonun ustundeki baslik, default "".
	name                 : JS instance anahtari (bos ise otomatik; lazy="1" iken zorunlu).
	empty_message        : default "Kayıt Bulunamadı !".
	is_excel             : 0/1. 1 ise JS'siz, tum satirlari iceren duz bir <table> basar -
	                       projedeki mevcut is_excel konvansiyonu (host sayfa cfheader/
	                       cfcontent ile ciktiyi .xls gibi yutturur, bkz. proje.cfm).
	allow_show_all       : default 1. 0 ise "Tumunu Goster" butonu basılmaz.

	LAZY / SUNUCU TARAFLI SAYFALAMA (lazy="1", hem type=1 hem type=2)
	-----------------------------------------------------------------
	Varsayilanda (lazy="0") tum veri ilk yuklemede gelir, sayfalama client-side'dir.
	lazy="1" iken caller sadece 1. sayfayi basar, diger sayfalari tag AJAX ile ister
	(self-post + marker; bu projede .cfc endpoint yok).
		lazy       : 1 iken 'name' ve 'total_rows' ZORUNLU (name ajax isteginde ayni
		             instance'i bulmak, total_rows sayfa butonlarini cizmek icin).
		ajax_url   : bos ise mevcut URL kullanilir.
		ajax_params: bos birakilirsa tag form scope'undaki tum alanlari (at_* haric)
		             kendisi urlencode edip tasir - caller filtrelerini elle dizmez.

	AJAX ISTEGINI TAG KENDI KARSILAR: caller sayfasinda dispatch blogu YOKTUR. Tag
	at_instance/at_page/at_page_size ile self-post eder, sayfa bastan calisir ve hedef
	instance kendi cevabini basip request'i sonlandirir (diger instance'lar hic cizilmez).
	Caller'in tek sorumlulugu, sunucu tarafli sayfalama icin at_page/at_page_size'i kendi
	sorgusuna uygulamak ve o filtreye ait toplam satir sayisini total_rows ile vermektir
	(at_page="all" gelirse tum satirlar donmelidir).
	Cevap @@AT_JSON@@...@@AT_JSON_SON@@ arasinda:
		type=1: {"rows":[{cells:{...},totals:{...}},...], "total_rows":N}
		type=2: {"rows_html":"<tr>...</tr>", "total_rows":N}
	Lazy modda arama yine client-side'dir (sadece yuklu satirlarda) ve toplam satiri tek
	"Toplam" olur (Sayfa/Genel ayrimi yok). "Tumunu Goster" tum veriyi bir kez ister.

	NOT: kolon tipi (tarih/sayi/metin) caller'dan istenmez - query metadata'sindan, o da
	belirsizse ilk dolu hucreden tespit edilir; hem tarih formatlamada hem total_columns
	dogrulamasinda kullanilir.
--->

<!--- ZORUNLU --->
<cfparam name="attributes.query" default="">
<cfparam name="attributes.columns" default="">
<cfparam name="attributes.labels" default="">

<!--- ISTEGE BAGLI --->
<cfparam name="attributes.type" default="1">
<cfparam name="attributes.rows" default="">
<cfparam name="attributes.head" default="">
<cfparam name="attributes.group_column" default="">
<cfparam name="attributes.total_columns" default="">
<cfparam name="attributes.aggregate_column" default="">
<cfparam name="attributes.show_totals" default="0">
<cfparam name="attributes.page_size" default="20">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.name" default="">
<cfparam name="attributes.is_excel" default="0">
<cfparam name="attributes.empty_message" default="Kayıt Bulunamadı !">
<cfparam name="attributes.lazy" default="0">
<cfparam name="attributes.ajax_url" default="">
<cfparam name="attributes.ajax_params" default="">
<cfparam name="attributes.total_rows" default="">
<cfparam name="attributes.allow_show_all" default="1">

<!--- Host sayfadan miras gelebilir (ör. cf_date), ama ayri bir tag oldugumuz icin guvenilmez - yoksa uygulamanin tarih girdi formatina duser. --->
<cfparam name="dateformat_style" default="dd/mm/yyyy">

<!--- Kapali kullanimda (<cf_ada_table ...></cf_ada_table>) govde/end mode'da tekrar cizilmesin. --->
<cfif thisTag.executionMode neq "start"><cfexit method="exittag"></cfif>

<!--- Tag tum veriyi hic gormedigi icin sayfa butonlarini total_rows ile cizer. --->
<cfif attributes.lazy and not len(attributes.total_rows)>
	<cfthrow message="cf_ada_table: lazy=""1"" iken 'total_rows' zorunludur (toplam eslesen satir sayisi).">
</cfif>

<!--- Ajax isteginde hedef instance ismiyle bulunur; otomatik id (at1, at2...) sayfadaki tag sirasina bagli oldugu icin guvenilmez. --->
<cfif attributes.lazy and not len(attributes.name)>
	<cfthrow message="cf_ada_table: lazy=""1"" iken 'name' zorunludur (ajax isteğinde aynı instance'ı bulabilmek için).">
</cfif>

<!--- Sessizce yok sayilirsa caller basliginin neden gelmedigini arar. --->
<cfif len(attributes.head) and attributes.type neq "2">
	<cfthrow message="cf_ada_table: 'head' attribute'u yalnızca type=""2"" ile kullanılabilir (type 1 başlığı columns/labels'tan üretir).">
</cfif>

<cfif len(attributes.group_column) and attributes.type neq "1">
	<cfthrow message="cf_ada_table: 'group_column' yalnızca type=""1"" ile kullanılabilir (type 2'de grup satırlarını zaten caller yazar).">
</cfif>

<!--- Ayni sayfada birden fazla kullanimda element id'leri cakismasin diye instance kimligi --->
<cfif not structKeyExists(request, "ada_table_count")>
	<cfset request.ada_table_count = 0>
</cfif>
<cfset request.ada_table_count = request.ada_table_count + 1>
<cfset instance_id = "at" & request.ada_table_count>
<cfif len(attributes.name)>
	<cfset registry_key = attributes.name>
<cfelse>
	<cfset registry_key = instance_id>
</cfif>

<!--- LAZY AJAX: tag kendi self-post'unu kendi karsilar (caller'da dispatch blogu yok). Sayfa bastan calisti, at_instance hangi instance'i istiyorsa yalnizca o cevap verir; digerleri hic cizilmez. --->
<cfset ada_ajax_target = "">
<cfif isDefined("form.at_instance") and len(trim(form.at_instance))>
	<cfset ada_ajax_target = trim(form.at_instance)>
<cfelseif isDefined("url.at_instance") and len(trim(url.at_instance))>
	<cfset ada_ajax_target = trim(url.at_instance)>
</cfif>
<cfset is_ajax_response = (len(ada_ajax_target) and compare(ada_ajax_target, registry_key) eq 0)>
<cfif len(ada_ajax_target) and not is_ajax_response>
	<cfexit method="exittag">
</cfif>

<!--- Caller filtrelerini elle dizmesin: ajax_params verilmediyse form scope oldugu gibi tasinir (tag icerigini yorumlamaz, sayfa kendi attributes'ina yine ayni degerlerle ulasir). --->
<cfif attributes.lazy and not len(attributes.ajax_params)>
	<cfset ada_auto_params = "">
	<cfloop collection="#form#" item="ada_form_key">
		<cfif not listFindNoCase("at_instance,at_page,at_page_size,fieldnames", ada_form_key) and isSimpleValue(form[ada_form_key])>
			<cfset ada_auto_params = listAppend(ada_auto_params, lcase(ada_form_key) & "=" & urlEncodedFormat(form[ada_form_key]), "&")>
		</cfif>
	</cfloop>
	<cfset attributes.ajax_params = ada_auto_params>
</cfif>

<!--- TYPE 2: baslik (head ya da labels) ve satir HTML'i (rows) attribute olarak gecer; tag kabugu verir - arama, yatay scroll, sticky header, sayfalama, istege bagli canli toplam. --->
<cfif attributes.type eq "2">
	<cfif not len(attributes.labels) and not len(trim(attributes.head))>
		<cfthrow message="cf_ada_table (type=2): 'labels' ya da 'head' zorunludur (thead başlıkları).">
	</cfif>

	<!--- head varsa labels yok sayilir; dis <thead> yazilmissa ic ice kalmasin diye temizlenir. --->
	<cfset use_head_html = len(trim(attributes.head)) gt 0>
	<cfset head_html = trim(attributes.head)>
	<cfif use_head_html>
		<cfset head_html = trim(reReplaceNoCase(head_html, "^<thead[^>]*>", "", "one"))>
		<cfset head_html = trim(reReplaceNoCase(head_html, "</thead>$", "", "one"))>
	</cfif>

	<cfset label_arr = arrayNew(1)>
	<cfif not use_head_html>
		<cfloop list="#attributes.labels#" index="lbl_item">
			<cfset arrayAppend(label_arr, trim(lbl_item))>
		</cfloop>
	</cfif>

	<!--- Toplam anahtari: labels modunda baslik metni, head modunda <th>'deki data-at-col degeri (baslik metni ic etiketlerle karisik olabildigi icin metne bakilamaz). --->
	<cfset total_key_arr = label_arr>
	<cfif use_head_html>
		<cfset total_key_arr = arrayNew(1)>
		<cfset head_key_matches = reMatchNoCase("data-at-col[[:space:]]*=[[:space:]]*[""'][^""']*[""']", head_html)>
		<cfloop array="#head_key_matches#" index="head_key_match">
			<cfset head_key_val = trim(reReplaceNoCase(head_key_match, "^data-at-col[[:space:]]*=[[:space:]]*[""']|[""']$", "", "all"))>
			<!--- Caller anahtari htmlEditFormat'li basmis olabilir; tarayici cozerek okudugu icin JS dogru esler, buradaki ham metin de ayni sekilde cozulur. --->
			<cfset head_key_val = replace(head_key_val, "&quot;", """", "all")>
			<cfset head_key_val = replace(head_key_val, "&##39;", "'", "all")>
			<cfset head_key_val = replace(head_key_val, "&##x27;", "'", "all")>
			<cfset head_key_val = replace(head_key_val, "&lt;", "<", "all")>
			<cfset head_key_val = replace(head_key_val, "&gt;", ">", "all")>
			<cfset head_key_val = replace(head_key_val, "&amp;", "&", "all")>
			<cfset arrayAppend(total_key_arr, head_key_val)>
		</cfloop>
	</cfif>

	<cfset total_column_arr = arrayNew(1)>
	<cfif attributes.show_totals and len(attributes.total_columns)>
		<cfloop list="#attributes.total_columns#" index="tc_item">
			<cfset tc_name = trim(tc_item)>
			<cfif not arrayFind(total_key_arr, tc_name)>
				<cfif use_head_html>
					<cfthrow message="cf_ada_table (type=2): 'total_columns' içindeki '#tc_name#' için 'head' içinde data-at-col='#tc_name#' taşıyan bir th yok (head içinde bulunanlar: #arrayToList(total_key_arr)#).">
				<cfelse>
					<cfthrow message="cf_ada_table (type=2): 'total_columns' içindeki '#tc_name#' 'labels' listesinde yok (#attributes.labels#).">
				</cfif>
			</cfif>
			<cfset arrayAppend(total_column_arr, tc_name)>
		</cfloop>
	</cfif>
	<cfif attributes.show_totals and len(attributes.aggregate_column) and not arrayFind(total_column_arr, trim(attributes.aggregate_column))>
		<cfthrow message="cf_ada_table (type=2): 'aggregate_column' değeri '#attributes.aggregate_column#' 'total_columns' içinde yok.">
	</cfif>
	<cfset type2_show_totals = (attributes.show_totals and arrayLen(total_column_arr))>

	<!--- Ajax cevabi: caller'in hazirladigi satir HTML'i oldugu gibi doner (JS tbody'yi bununla degistirir). Cevap sayfa ciktisina degil dogrudan response govdesine yazilir - tag baska bir tag'in (cf_box gibi) icinde cagrilmis olabilir. --->
	<cfif is_ajax_response>
		<cfset ajax_payload = structNew()>
		<cfset ajax_payload["rows_html"] = attributes.rows>
		<cfset ajax_payload["total_rows"] = val(attributes.total_rows)>
		<cfset ajax_json = "@@AT_JSON@@" & serializeJSON(ajax_payload) & "@@AT_JSON_SON@@">
		<cfcontent type="application/json; charset=utf-8" variable="#toBinary(toBase64(ajax_json, 'utf-8'))#" reset="true">
		<cfabort>
	</cfif>

	<cfif attributes.is_excel>
		<!--- Excel: sade, JS'siz duz tablo - head/rows oldugu gibi basilir (head yoksa labels'tan) --->
		<cfoutput>
		<table style="border-collapse:collapse;">
			<thead>
				<cfif use_head_html>
					#head_html#
				<cfelse>
					<tr>
						<cfloop array="#label_arr#" index="lbl">
							<th style="border:1px solid ##999;padding:4px 8px;background:##eee;text-align:left;">#htmlEditFormat(lbl)#</th>
						</cfloop>
					</tr>
				</cfif>
			</thead>
			<tbody>#attributes.rows#</tbody>
		</table>
		</cfoutput>
		<cfexit method="exittag">
	</cfif>

	<cfoutput>
	<style>
		##adaTableWrap_#registry_key# { font-family:inherit; }
		##adaTableWrap_#registry_key# .ada-table-toolbar { display:flex; flex-wrap:wrap; align-items:center; gap:10px; margin-bottom:10px; }
		##adaTableWrap_#registry_key# .ada-table-search {
			padding:6px 10px; border:1px solid ##c9d0d8; border-radius:5px; min-width:230px; font-size:13px;
		}
		##adaTableWrap_#registry_key# .ada-table-scroll {
			overflow-x:auto; width:100%; border:1px solid ##d8dde3; border-radius:6px;
		}
		##adaTableWrap_#registry_key# table {
			width:100%; border-collapse:collapse; white-space:nowrap; font-size:13px;
		}
		##adaTableWrap_#registry_key# thead th {
			background:##eef1f5; color:##33424e; text-align:left;
			padding:9px 10px; font-weight:600; font-size:11px; text-transform:uppercase; letter-spacing:.04em;
			border-bottom:2px solid ##c9d0d8; border-right:1px solid ##dde2e7; box-sizing:border-box;
		}
		##adaTableWrap_#registry_key# thead th:last-child { border-right:none; }
		##adaTableWrap_#registry_key# .ada-table-sticky-head {
			position:fixed; top:0; overflow:hidden; z-index:2147483000; display:none;
			box-shadow:0 2px 6px rgba(0,0,0,.12); border-bottom:2px solid ##c9d0d8;
		}
		##adaTableWrap_#registry_key# .ada-table-sticky-head table {
			border-collapse:collapse; white-space:nowrap; font-size:13px; width:auto;
		}
		##adaTableWrap_#registry_key# .ada-table-sticky-head th {
			background:##eef1f5; color:##33424e; text-align:left;
			padding:9px 10px; font-weight:600; font-size:11px; text-transform:uppercase; letter-spacing:.04em;
			border-right:1px solid ##dde2e7; box-sizing:border-box;
		}
		##adaTableWrap_#registry_key# .ada-table-sticky-head th:last-child { border-right:none; }
		##adaTableWrap_#registry_key# .ada-table-total-toggle {
			display:block; margin-top:4px; font-weight:400; font-size:10px; text-transform:none;
			letter-spacing:normal; color:##6b7680; cursor:pointer;
		}
		##adaTableWrap_#registry_key# .ada-table-total-toggle input { margin-right:3px; vertical-align:middle; cursor:pointer; }
		##adaTableWrap_#registry_key# .ada-table-total-fixed { cursor:default; font-style:italic; color:##8a94a0; }
		##adaTableWrap_#registry_key# tbody td {
			padding:8px 10px; border-bottom:1px solid ##edf0f3; border-right:1px solid ##f2f4f6; color:##2b333a;
		}
		##adaTableWrap_#registry_key# tbody td:last-child { border-right:none; }
		##adaTableWrap_#registry_key# tbody tr:nth-child(even) { background:##f8fafb; }
		##adaTableWrap_#registry_key# tbody tr:hover { background:##eaf2fb; }
		##adaTableWrap_#registry_key# tfoot td {
			padding:8px 10px; font-weight:700; color:##33424e;
			background:##fff6db; border-top:2px solid ##e3c266; border-right:1px solid ##f0e0ac;
		}
		##adaTableWrap_#registry_key# tfoot td:last-child { border-right:none; }
		##adaTableWrap_#registry_key# tfoot tr:last-child td { background:##eef6ee; border-top:1px solid ##cfe4cf; }
		##adaTableWrap_#registry_key# .ada-table-paging {
			display:flex; align-items:center; gap:8px; margin-top:10px; flex-wrap:wrap; font-size:12px; color:##55606a;
		}
		##adaTableWrap_#registry_key# .ada-table-paging button {
			padding:4px 10px; border:1px solid ##c9d0d8; border-radius:4px; background:##fff; cursor:pointer; font-size:12px;
		}
		##adaTableWrap_#registry_key# .ada-table-paging button:hover:not(:disabled) { background:##eef1f5; }
		##adaTableWrap_#registry_key# .ada-table-paging button:disabled { opacity:.4; cursor:default; }
		##adaTableWrap_#registry_key# .ada-table-paging button.ada-table-page-current {
			background:##33424e; color:##fff; border-color:##33424e;
		}
	</style>
	<div class="ada-table-wrap" id="adaTableWrap_#registry_key#">
		<div class="ada-table-toolbar">
			<cfif len(attributes.title)>
				<strong style="margin-right:auto;">#htmlEditFormat(attributes.title)#</strong>
			</cfif>
			<input type="text" class="ada-table-search" id="adaTableSearch_#registry_key#" placeholder="Ara...">
		</div>

		<div class="ada-table-scroll">
			<table id="adaTable_#registry_key#">
				<!--- head modunda caller HTML'i oldugu gibi basilir ("Topla" kutucuklarini JS ekler); labels modunda tag uretir. data-at-col iki modda da var: toplam satiri hangi sutuna yazilacagini gercek thead'den okuyor. --->
				<thead>
					<cfif use_head_html>
						#head_html#
					<cfelse>
						<tr>
							<cfloop array="#label_arr#" index="lbl">
								<th data-at-col="#htmlEditFormat(lbl)#">
									#htmlEditFormat(lbl)#
									<cfif type2_show_totals and arrayFind(total_column_arr, lbl) and compareNoCase(lbl, attributes.aggregate_column) neq 0>
										<label class="ada-table-total-toggle">
											<input type="checkbox" data-col="#htmlEditFormat(lbl)#" checked> Topla
										</label>
									<cfelseif type2_show_totals and len(attributes.aggregate_column) and compareNoCase(lbl, attributes.aggregate_column) eq 0>
										<span class="ada-table-total-toggle ada-table-total-fixed">Toplam (sabit)</span>
									</cfif>
								</th>
							</cfloop>
						</tr>
					</cfif>
				</thead>
				<tbody id="adaTableBody_#registry_key#">#attributes.rows#</tbody>
				<cfif type2_show_totals>
					<tfoot id="adaTableFoot_#registry_key#"></tfoot>
				</cfif>
			</table>
		</div>

		<!--- Sticky kopya: cok satirli baslik da olabildigi icin thead'in tamami klonlanir. --->
		<div class="ada-table-sticky-head" id="adaTableStickyHead_#registry_key#">
			<table>
				<thead id="adaTableStickyThead_#registry_key#"></thead>
			</table>
		</div>

		<div class="ada-table-paging" id="adaTablePaging_#registry_key#"></div>
	</div>

	<script type="text/javascript">
		// Type 1'den farki: satirlar zaten DOM'da (caller "rows" ile hazir HTML gecti), toplamlar da data-at-col isaretli hucrelerden okunur.
		(function() {
			var atInstance = '#registry_key#';
			var atPageSize = #val(attributes.page_size)# || 20;
			var atShowTotals = #type2_show_totals ? "true" : "false"#;
			var atTotalColumns = #serializeJSON(total_column_arr)#;
			var atAggregateColumn = #serializeJSON(len(attributes.aggregate_column) ? trim(attributes.aggregate_column) : "")#;
			var atActiveTotalColumns = atTotalColumns.slice();

			// Lazy/ajax sayfalama (opsiyonel - bkz. dosya basi "LAZY / SUNUCU TARAFLI SAYFALAMA" bolumu). lazy verilmediyse atLazyMode false kalir, asagidaki TUM dallanmalar bugunku (tamamen client-side) davranisa duser.
			var atLazyMode = #attributes.lazy ? "true" : "false"#;
			var atAjaxUrl = #serializeJSON(len(attributes.ajax_url) ? attributes.ajax_url : "")#;
			var atAjaxParams = #serializeJSON(attributes.ajax_params)#;
			var atTotalRows = #val(attributes.total_rows)#;
			var atAllowShowAll = #attributes.allow_show_all ? "true" : "false"#;
			var atRequestSeq = 0;
			var atAllLoaded = !atLazyMode;

			var atBody = document.getElementById('adaTableBody_' + atInstance);
			if (!atBody) return;

			var atTable = document.getElementById('adaTable_' + atInstance);
			// Sutun sayisi ve anahtar->sutun eslesmesi gercek thead'den okunur (caller'in yazdigi baslikla hizali kalsin diye). Kolon satiri = en cok sutunlu baslik satiri.
			var atHead = { count: 0, index: {} };

			function atReadHeadInfo() {
				var info = { count: 0, index: {} };
				if (!atTable || !atTable.tHead) return info;
				var rows = atTable.tHead.rows;
				var bestRow = null;
				for (var r = 0; r < rows.length; r++) {
					var span = 0;
					for (var c = 0; c < rows[r].cells.length; c++) span += rows[r].cells[c].colSpan || 1;
					if (span > info.count) { info.count = span; bestRow = rows[r]; }
				}
				if (!bestRow) return info;
				var pos = 0;
				for (var c2 = 0; c2 < bestRow.cells.length; c2++) {
					var key = bestRow.cells[c2].getAttribute('data-at-col');
					if (key) info.index[key] = pos;
					pos += bestRow.cells[c2].colSpan || 1;
				}
				return info;
			}

			// "Topla" kutucuklari: labels modunda sunucu basar, head modunda (caller HTML'i) data-at-col tasiyan basliklara burada eklenir. Zaten varsa dokunulmaz.
			function atEnsureTotalToggles() {
				if (!atShowTotals || !atTable || !atTable.tHead) return;
				for (var i = 0; i < atTotalColumns.length; i++) {
					var col = atTotalColumns[i];
					var th = atTable.tHead.querySelector('[data-at-col="' + col + '"]');
					if (!th || th.querySelector('.ada-table-total-toggle')) continue;
					if (atAggregateColumn && col === atAggregateColumn) {
						var fixed = document.createElement('span');
						fixed.className = 'ada-table-total-toggle ada-table-total-fixed';
						fixed.textContent = 'Toplam (sabit)';
						th.appendChild(fixed);
					} else {
						var lab = document.createElement('label');
						lab.className = 'ada-table-total-toggle';
						var cb = document.createElement('input');
						cb.type = 'checkbox';
						cb.setAttribute('data-col', col);
						cb.checked = true;
						lab.appendChild(cb);
						lab.appendChild(document.createTextNode(' Topla'));
						th.appendChild(lab);
					}
				}
			}

			var atAllRows = [];
			var atFiltered = [];
			var atPage = 1;
			var atShowAll = false;

			// tbody'nin dogrudan <tr> cocuklari (:scope destegine guvenmemek icin elle suzulur) - hem ilk kurulumda hem her ajax sayfa yuklemesinden sonra kullanilir.
			function atRescanRows() {
				atAllRows = [];
				var kids = atBody.children;
				for (var k = 0; k < kids.length; k++) {
					if (kids[k].tagName === 'TR') atAllRows.push(kids[k]);
				}
				atFiltered = atAllRows.slice();
			}
			atRescanRows();

			// 11.07.cfm'deki pieParseResponse ile ayni desen, farkli marker (AT_JSON) - iki ozellik ayni sayfada calissa bile marker'lar cakismasin diye.
			function atParseAjaxResponse(txt) {
				var start = txt.indexOf('@@AT_JSON@@');
				var end = txt.indexOf('@@AT_JSON_SON@@');
				if (start > -1 && end > start) {
					try { return JSON.parse(txt.substring(start + 11, end)); } catch (e) {}
				}
				try { return JSON.parse(txt); } catch (e) {}
				return null;
			}

			// Bir sayfayi (ya da at_page="all" ile hepsini) sunucudan ister; cevapta gelen "rows_html" ile tbody degistirilir. Arama kutusunda aktif bir terim varsa yeni sayfaya da (client-side) yeniden uygulanir.
			function atFetchPage(page, showAll) {
				var url = atAjaxUrl || (window.location.pathname + window.location.search);
				var params = 'at_instance=' + encodeURIComponent(atInstance)
					+ '&at_page=' + (showAll ? 'all' : page)
					+ '&at_page_size=' + atPageSize
					+ (atAjaxParams ? '&' + atAjaxParams : '');
				var seq = ++atRequestSeq;
				fetch(url, {
					method: 'POST',
					headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
					credentials: 'same-origin',
					body: params
				})
				.then(function(response) { return response.text(); })
				.then(function(txt) {
					if (seq !== atRequestSeq) return;
					var data = atParseAjaxResponse(txt);
					if (!data || data.error) {
						console.error('cf_ada_table ajax hata:', data && data.error);
						return;
					}
					atBody.innerHTML = data.rows_html;
					atRescanRows();
					atTotalRows = data.total_rows;
					if (showAll) {
						atAllLoaded = true;
						atShowAll = true;
					} else {
						atPage = page;
					}
					if (searchInput && searchInput.value) {
						atApplySearch(searchInput.value);
					} else {
						atRender();
					}
				})
				.catch(function(err) {
					if (seq !== atRequestSeq) return;
					console.error('cf_ada_table ajax hata:', err);
				});
			}

			// Satirin bir anahtar icin degeri: [data-at-col] hucresinden (once data-at-val, yoksa textContent). Eslesme yoksa katki 0 - ara toplam satirlari kendiliginden toplama karismaz.
			function atRowValue(row, col) {
				var cells = row.querySelectorAll('[data-at-col]');
				for (var i = 0; i < cells.length; i++) {
					if (cells[i].getAttribute('data-at-col') === col) {
						var raw = cells[i].hasAttribute('data-at-val') ? cells[i].getAttribute('data-at-val') : cells[i].textContent;
						var num = parseFloat(String(raw).replace(',', '.'));
						return isNaN(num) ? 0 : num;
					}
				}
				return 0;
			}

			function atSumColumn(rows, col) {
				var sum = 0;
				for (var i = 0; i < rows.length; i++) sum += atRowValue(rows[i], col);
				return sum;
			}

			// aggregate_column verilmisse, o kolonun toplami sabit degil: ham toplamindan, DIGER total_columns kolonlarindan "Topla" kutucugu KAPALI olanlarin toplami cikarilir (type 1'deki ile ayni mantik).
			function atComputeAggregateSum(rows) {
				var sum = atSumColumn(rows, atAggregateColumn);
				for (var i = 0; i < atTotalColumns.length; i++) {
					var col = atTotalColumns[i];
					if (col === atAggregateColumn) continue;
					if (atActiveTotalColumns.indexOf(col) === -1) {
						sum -= atSumColumn(rows, col);
					}
				}
				return sum;
			}

			// Toplam satiri: thead'deki sutun sayisi kadar bos <td>, ilk hucre satir adi, her deger anahtarin thead'deki sirasina. Sutunu bulunamayan toplam konsola yazilir.
			function atBuildTotalRow(label, sums) {
				var tr = document.createElement('tr');
				for (var c = 0; c < atHead.count; c++) tr.appendChild(document.createElement('td'));
				if (!tr.cells.length) return tr;
				tr.cells[0].textContent = label;
				for (var key in sums) {
					if (!sums.hasOwnProperty(key)) continue;
					var pos = atHead.index[key];
					if (typeof pos !== 'number') {
						console.warn('cf_ada_table: "' + key + '" başlığı thead içinde data-at-col ile işaretlenmemiş, toplamı gösterilemiyor.');
						continue;
					}
					if (pos > 0 && tr.cells[pos]) tr.cells[pos].textContent = sums[key];
				}
				return tr;
			}

			function atRenderTotals(pageRows, totalPages) {
				if (!atShowTotals) return;
				var tfoot = document.getElementById('adaTableFoot_' + atInstance);
				if (!tfoot) return;
				tfoot.textContent = '';

				var grandSums = {};
				if (atAggregateColumn) grandSums[atAggregateColumn] = atComputeAggregateSum(atFiltered);
				for (var i = 0; i < atActiveTotalColumns.length; i++) {
					var col = atActiveTotalColumns[i];
					if (col === atAggregateColumn) continue;
					grandSums[col] = atSumColumn(atFiltered, col);
				}

				// Lazy modda "Sayfa Toplamı"/"Genel Toplam" ayrimi yok - tek "Toplam" satiri, sadece o an yuklu olan veriye gore (sayfadaysa sayfanin, "Tumunu Goster" sonrasi hepsinin) - bkz. dosya basi "LAZY / SUNUCU TARAFLI SAYFALAMA".
				if (atLazyMode) {
					tfoot.appendChild(atBuildTotalRow('Toplam', grandSums));
					return;
				}

				// Tek sayfa varsa "Sayfa Toplamı" = "Genel Toplam" olacagindan tekrar gostermeye gerek yok.
				if (totalPages > 1) {
					var pageSums = {};
					if (atAggregateColumn) pageSums[atAggregateColumn] = atComputeAggregateSum(pageRows);
					for (var j = 0; j < atActiveTotalColumns.length; j++) {
						var pcol = atActiveTotalColumns[j];
						if (pcol === atAggregateColumn) continue;
						pageSums[pcol] = atSumColumn(pageRows, pcol);
					}
					tfoot.appendChild(atBuildTotalRow('Sayfa Toplamı', pageSums));
				}

				tfoot.appendChild(atBuildTotalRow('Genel Toplam', grandSums));
			}

			// Kullanici bir kolonun "Topla" kutucugunu ac/kapat yapinca aktif kume guncellenir ve tum render pipeline'i tazelenir (sadece toplam satirlarini degil).
			function atToggleTotalColumn(col, isOn) {
				var idx = atActiveTotalColumns.indexOf(col);
				if (isOn && idx === -1) atActiveTotalColumns.push(col);
				if (!isOn && idx !== -1) atActiveTotalColumns.splice(idx, 1);
				atRender();
			}

			function atNormalize(s) {
				return String(s === null || typeof s === 'undefined' ? '' : s).toLocaleLowerCase('tr');
			}

			function atApplySearch(text) {
				var term = atNormalize(text);
				atFiltered = [];
				for (var i = 0; i < atAllRows.length; i++) {
					if (!term || atNormalize(atAllRows[i].textContent).indexOf(term) !== -1) {
						atFiltered.push(atAllRows[i]);
					}
				}
				atPage = 1;
				atRender();
			}

			function atMakePageBtn(label, page, disabled) {
				var btn = document.createElement('button');
				btn.type = 'button';
				btn.textContent = label;
				btn.disabled = !!disabled;
				btn.addEventListener('click', function() {
					if (atLazyMode && !atAllLoaded) {
						atFetchPage(page, false);
					} else {
						atPage = page;
						atRender();
					}
				});
				return btn;
			}

			function atMakeToggleShowAllBtn() {
				var btn = document.createElement('button');
				btn.type = 'button';
				btn.textContent = atShowAll ? 'Sayfalara Böl' : 'Tümünü Göster';
				btn.addEventListener('click', function() {
					if (atLazyMode && !atAllLoaded) {
						atFetchPage(1, true);
						return;
					}
					atShowAll = !atShowAll;
					atPage = 1;
					atRender();
				});
				return btn;
			}

			function atRenderPaging(totalRows, totalPages) {
				var el = document.getElementById('adaTablePaging_' + atInstance);
				if (!el) return;
				el.textContent = '';
				if (totalRows === 0) return;
				var naturalTotalPages = Math.max(1, Math.ceil(totalRows / atPageSize));
				if (naturalTotalPages <= 1) return;

				var info = document.createElement('span');
				if (atShowAll) {
					info.textContent = totalRows + ' kayıt (tümü) gösteriliyor';
				} else {
					var startIdx = ((atPage - 1) * atPageSize) + 1;
					var endIdx = Math.min(atPage * atPageSize, totalRows);
					info.textContent = totalRows + ' kayıttan ' + startIdx + '-' + endIdx + ' arası gösteriliyor';
				}
				el.appendChild(info);

				if (!atShowAll) {
					el.appendChild(atMakePageBtn('« Önceki', atPage - 1, atPage <= 1));
					for (var p = 1; p <= totalPages; p++) {
						var b = atMakePageBtn(String(p), p, false);
						if (p === atPage) b.className = 'ada-table-page-current';
						el.appendChild(b);
					}
					el.appendChild(atMakePageBtn('Sonraki »', atPage + 1, atPage >= totalPages));
				}

				if (atAllowShowAll) el.appendChild(atMakeToggleShowAllBtn());
			}

			function atRender() {
				var pageRows;
				var totalRows, totalPages;

				if (atLazyMode && !atAllLoaded) {
					// atAllRows/atFiltered zaten sadece o an sunucudan gelen sayfa - hepsi gorunur, yerel dilimlemeye gerek yok; sayfa sayisi sunucunun bildirdigi total_rows'a gore hesaplanir (client hicbir zaman tum veriyi gormedi).
					totalRows = atTotalRows;
					totalPages = Math.max(1, Math.ceil(totalRows / atPageSize));
					for (var i = 0; i < atAllRows.length; i++) atAllRows[i].style.display = '';
					pageRows = atFiltered;
				} else {
					totalRows = atFiltered.length;
					totalPages = atShowAll ? 1 : Math.max(1, Math.ceil(totalRows / atPageSize));
					if (atPage > totalPages) atPage = totalPages;
					if (atPage < 1) atPage = 1;

					var start = atShowAll ? 0 : (atPage - 1) * atPageSize;
					var end = atShowAll ? totalRows : start + atPageSize;

					// Once tum satirlar gizlenir, sonra sadece gecerli sayfadaki (suzulmus) satirlar gosterilir.
					for (var i2 = 0; i2 < atAllRows.length; i2++) atAllRows[i2].style.display = 'none';
					for (var j = start; j < end && j < totalRows; j++) atFiltered[j].style.display = '';

					pageRows = atFiltered.slice(start, end);
				}

				atRenderPaging(totalRows, totalPages);
				atRenderTotals(pageRows, totalPages);
				atUpdateSticky();
			}

			var atScrollBox = document.querySelector('##adaTableWrap_' + atInstance + ' .ada-table-scroll');
			var atRealThead = atTable ? atTable.tHead : null;
			var atStickyHead = document.getElementById('adaTableStickyHead_' + atInstance);
			var atStickyThead = document.getElementById('adaTableStickyThead_' + atInstance);
			var atStickyTable = atStickyHead ? atStickyHead.querySelector('table') : null;

			// Fixed kopya header: thead'in TUM satirlari klonlanir, genislikler pikselle kopyalanir. Kutucuk klonlari da baglanir (stuck durumdayken de calissin diye) ve degisiklik gercek header'daki kutucuga geri yazilir.
			function atSyncStickyHead() {
				if (!atStickyThead || !atRealThead) return;
				atStickyThead.innerHTML = '';
				var srcRows = atRealThead.rows;
				for (var r = 0; r < srcRows.length; r++) {
					var cloneRow = srcRows[r].cloneNode(true);
					for (var c = 0; c < srcRows[r].cells.length; c++) {
						if (cloneRow.cells[c]) cloneRow.cells[c].style.width = srcRows[r].cells[c].getBoundingClientRect().width + 'px';
					}
					atStickyThead.appendChild(cloneRow);

					var cloneCheckboxes = cloneRow.querySelectorAll('input[data-col]');
					for (var k = 0; k < cloneCheckboxes.length; k++) {
						(function(checkboxEl) {
							checkboxEl.addEventListener('change', function() {
								var col = checkboxEl.getAttribute('data-col');
								var realCheckbox = atRealThead.querySelector('input[data-col="' + col + '"]');
								if (realCheckbox) realCheckbox.checked = checkboxEl.checked;
								atToggleTotalColumn(col, checkboxEl.checked);
							});
						})(cloneCheckboxes[k]);
					}
				}
				if (atStickyTable) atStickyTable.style.width = atRealThead.getBoundingClientRect().width + 'px';
			}

			function atGetFixedNavOffset() {
				var navEl = document.querySelector('.navbar-fixed-top');
				return navEl ? navEl.getBoundingClientRect().height : 0;
			}

			function atUpdateSticky() {
				if (!atScrollBox || !atStickyHead || !atRealThead) return;
				var topOffset = atGetFixedNavOffset();
				var rect = atScrollBox.getBoundingClientRect();
				var headHeight = atRealThead.getBoundingClientRect().height || 0;
				var shouldStick = rect.top < topOffset && rect.bottom > (topOffset + headHeight);
				if (shouldStick) {
					atSyncStickyHead();
					atStickyHead.style.display = 'block';
					atStickyHead.style.top = topOffset + 'px';
					atStickyHead.style.left = rect.left + 'px';
					atStickyHead.style.width = atScrollBox.clientWidth + 'px';
					if (atStickyTable) atStickyTable.style.transform = 'translateX(-' + atScrollBox.scrollLeft + 'px)';
				} else {
					atStickyHead.style.display = 'none';
				}
			}

			document.addEventListener('scroll', atUpdateSticky, true);
			window.addEventListener('resize', atUpdateSticky);
			if (atScrollBox) {
				atScrollBox.addEventListener('scroll', function() {
					if (atStickyHead && atStickyHead.style.display === 'block' && atStickyTable) {
						atStickyTable.style.transform = 'translateX(-' + atScrollBox.scrollLeft + 'px)';
					}
				});
			}

			var searchInput = document.getElementById('adaTableSearch_' + atInstance);
			if (searchInput) {
				searchInput.addEventListener('input', function() { atApplySearch(searchInput.value); });
			}

			// Once kutucuklar eklenir, sonra baglanir - asagidaki dongu hem tag'in bastigi hem JS'in ekledigi kutucuklari yakalasin diye.
			atEnsureTotalToggles();
			atHead = atReadHeadInfo();

			var wrapEl = document.getElementById('adaTableWrap_' + atInstance);
			if (wrapEl) {
				var toggles = wrapEl.querySelectorAll('.ada-table-total-toggle input[data-col]');
				for (var tgIdx = 0; tgIdx < toggles.length; tgIdx++) {
					(function(toggleEl) {
						toggleEl.addEventListener('change', function() {
							atToggleTotalColumn(toggleEl.getAttribute('data-col'), toggleEl.checked);
						});
					})(toggles[tgIdx]);
				}
			}

			atRender();
		})();
	</script>
	</cfoutput>
	<cfexit method="exittag">
</cfif>

<!--- ===== TYPE 1 (varsayilan): satirlari tag query'den cizer ===== --->
<cfif not len(attributes.columns) or not len(attributes.labels)>
	<cfthrow message="cf_ada_table: 'columns' ve 'labels' zorunludur ve birlikte verilmelidir.">
</cfif>

<!--- Liste elemanlarindaki bosluklar temizlenir - "A, B, C" gibi yazimlar da calissin diye --->
<cfset column_arr = arrayNew(1)>
<cfloop list="#attributes.columns#" index="col_item">
	<cfset arrayAppend(column_arr, trim(col_item))>
</cfloop>
<cfset label_arr = arrayNew(1)>
<cfloop list="#attributes.labels#" index="lbl_item">
	<cfset arrayAppend(label_arr, trim(lbl_item))>
</cfloop>

<cfif arrayLen(column_arr) neq arrayLen(label_arr)>
	<cfthrow message="cf_ada_table: 'columns' (#arrayLen(column_arr)# eleman) ile 'labels' (#arrayLen(label_arr)# eleman) aynı uzunlukta olmalıdır.">
</cfif>

<cfif not isQuery(attributes.query)>
	<cfthrow message="cf_ada_table: 'query' attribute'u geçerli bir CF query nesnesi olmalıdır.">
</cfif>

<cfloop array="#column_arr#" index="col_name">
	<cfif not listFindNoCase(attributes.query.columnList, col_name)>
		<cfthrow message="cf_ada_table: sorguda '#col_name#' kolonu yok (kolonlar: #attributes.query.columnList#).">
	</cfif>
</cfloop>

<!--- Grup kolonu ayri bir sutun olarak cizilmez: basligi da, hucreleri de yoktur - sadece deger degistiginde tum satiri kaplayan bir grup basligi olur. Bu yuzden asagida "gorunen kolonlar" (display_column_arr) ile "satirda tasinan kolonlar" (column_arr) ayrisir. --->
<cfset group_column_name = trim(attributes.group_column)>
<cfif len(group_column_name)>
	<cfif not listFindNoCase(attributes.columns, group_column_name)>
		<cfthrow message="cf_ada_table: 'group_column' değeri '#group_column_name#' 'columns' listesinde yok.">
	</cfif>
	<cfif arrayLen(column_arr) lte 1>
		<cfthrow message="cf_ada_table: 'group_column' dışında gösterilecek en az bir kolon olmalıdır.">
	</cfif>
</cfif>

<cfset display_column_arr = arrayNew(1)>
<cfset display_label_arr = arrayNew(1)>
<cfloop from="1" to="#arrayLen(column_arr)#" index="disp_idx">
	<cfif not len(group_column_name) or compareNoCase(column_arr[disp_idx], group_column_name) neq 0>
		<cfset arrayAppend(display_column_arr, column_arr[disp_idx])>
		<cfset arrayAppend(display_label_arr, label_arr[disp_idx])>
	</cfif>
</cfloop>

<!--- Kolon tipi tespiti (date/number/text): once query metadata'si, belirsizse ilk dolu hucre. Sayi once kontrol edilir - isDate() bazi sayisal string'leri tarih sanabiliyor. --->
<cfset column_types = structNew()>
<cfset meta_arr = arrayNew(1)>
<cftry>
	<cfset meta_arr = getMetaData(attributes.query)>
	<cfcatch type="any"></cfcatch>
</cftry>

<cfloop array="#column_arr#" index="col_name">
	<cfset detected_type = "text">
	<cfset meta_found = false>

	<cfloop array="#meta_arr#" index="meta_col">
		<cfif isStruct(meta_col) and structKeyExists(meta_col, "name") and compareNoCase(meta_col.name, col_name) eq 0>
			<cfset meta_found = true>
			<cfset type_name = "">
			<cfif structKeyExists(meta_col, "typeName")>
				<cfset type_name = lcase(meta_col.typeName)>
			</cfif>
			<cfif reFindNoCase("int|decimal|numeric|float|double|bit|real|money", type_name)>
				<cfset detected_type = "number">
			<cfelseif findNoCase("date", type_name) or findNoCase("time", type_name)>
				<cfset detected_type = "date">
			</cfif>
		</cfif>
	</cfloop>

	<cfif not meta_found and attributes.query.recordCount>
		<cfloop from="1" to="#attributes.query.recordCount#" index="type_row_idx">
			<cfset cell_val = attributes.query[col_name][type_row_idx]>
			<cfif len(trim(cell_val))>
				<cfif isNumeric(cell_val)>
					<cfset detected_type = "number">
				<cfelseif isDate(cell_val)>
					<cfset detected_type = "date">
				</cfif>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>

	<cfset column_types[col_name] = detected_type>
</cfloop>

<!--- total_columns: columns'ta ve sayisal olmali. Bos birakilirsa (show_totals=1 iken) tespit edilen tum sayisal kolonlar toplanir. --->
<cfset total_column_arr = arrayNew(1)>
<cfif len(attributes.total_columns)>
	<cfloop list="#attributes.total_columns#" index="tc_item">
		<cfset tc_name = trim(tc_item)>
		<cfif not listFindNoCase(attributes.columns, tc_name)>
			<cfthrow message="cf_ada_table: 'total_columns' içindeki '#tc_name#' kolonu 'columns' listesinde yok.">
		</cfif>
		<cfif len(group_column_name) and compareNoCase(tc_name, group_column_name) eq 0>
			<cfthrow message="cf_ada_table: 'total_columns' içindeki '#tc_name#' aynı zamanda 'group_column' - grup kolonu tabloda çizilmediği için toplanamaz.">
		</cfif>
		<cfif column_types[tc_name] neq "number">
			<cfthrow message="cf_ada_table: 'total_columns' içindeki '#tc_name#' kolonu sayısal değil (tespit edilen tip: #column_types[tc_name]#), toplanamaz.">
		</cfif>
		<cfset arrayAppend(total_column_arr, tc_name)>
	</cfloop>
<cfelseif attributes.show_totals>
	<cfloop array="#display_column_arr#" index="auto_tc_col">
		<cfif column_types[auto_tc_col] eq "number">
			<cfset arrayAppend(total_column_arr, auto_tc_col)>
		</cfif>
	</cfloop>
</cfif>

<!--- Asagida ham attribute degil bu liste kullanilir - nihai toplam kolon kumesi burada. --->
<cfset total_columns_list = arrayToList(total_column_arr)>

<!--- aggregate_column dogrulamasi: verilmisse columns'ta olmali ve sayisal olmali --->
<cfif len(attributes.aggregate_column)>
	<cfif not listFindNoCase(attributes.columns, attributes.aggregate_column)>
		<cfthrow message="cf_ada_table: 'aggregate_column' değeri '#attributes.aggregate_column#' 'columns' listesinde yok.">
	</cfif>
	<cfif column_types[attributes.aggregate_column] neq "number">
		<cfthrow message="cf_ada_table: 'aggregate_column' değeri '#attributes.aggregate_column#' sayısal değil, ana toplam olamaz.">
	</cfif>
</cfif>

<!--- Satirlar JSON'a cevrilir: "cells" (gorunen metin) + "totals" (ham sayisal deger). JS bunlari textContent ile yazar (innerHTML degil) - DB metni XSS'e donusmesin diye. Ajax cevabinda da ayni yapi doner, bu yuzden bos query kontrolunden once uretilir. --->
<cfset table_rows = arrayNew(1)>
<cfloop from="1" to="#attributes.query.recordCount#" index="row_idx">
	<cfset cells_obj = structNew()>
	<cfset totals_obj = structNew()>
	<cfloop array="#column_arr#" index="col_name">
		<cfset raw_val = attributes.query[col_name][row_idx]>
		<cfif column_types[col_name] eq "date" and len(trim(raw_val)) and isDate(raw_val)>
			<cfset cells_obj[col_name] = dateFormat(raw_val, dateformat_style)>
		<cfelse>
			<cfset cells_obj[col_name] = raw_val>
		</cfif>
		<cfif listFindNoCase(total_columns_list, col_name)>
			<cfset totals_obj[col_name] = val(raw_val)>
		</cfif>
	</cfloop>
	<cfset row_obj = structNew()>
	<cfset row_obj["cells"] = cells_obj>
	<cfset row_obj["totals"] = totals_obj>
	<cfset arrayAppend(table_rows, row_obj)>
</cfloop>

<!--- Ajax cevabi: istenen sayfanin satirlari + o filtreye ait toplam satir sayisi. Cevap sayfa ciktisina degil dogrudan response govdesine yazilir - tag baska bir tag'in (cf_box gibi) icinde cagrilmis olabilir. --->
<cfif is_ajax_response>
	<cfset ajax_payload = structNew()>
	<cfset ajax_payload["rows"] = table_rows>
	<cfset ajax_payload["total_rows"] = val(attributes.total_rows)>
	<cfset ajax_json = "@@AT_JSON@@" & serializeJSON(ajax_payload) & "@@AT_JSON_SON@@">
	<cfcontent type="application/json; charset=utf-8" variable="#toBinary(toBase64(ajax_json, 'utf-8'))#" reset="true">
	<cfabort>
</cfif>

<!--- Veri yoksa ne interaktif goruntu ne de excel icin gosterilecek bir sey yok --->
<cfif not attributes.query.recordCount>
	<cfoutput><div style="padding:15px;color:##666;">#attributes.empty_message#</div></cfoutput>
	<cfexit method="exittag">
</cfif>

<cfif attributes.is_excel>
	<!--- Excel: host sayfa ciktiyi .xls gibi yutturuyor, burada sadece sade/JS'siz duz tablo basilir (arama/sayfalama/sticky yok, tum satirlar). --->
	<cfset excel_last_group = "">
	<cfoutput>
	<table style="border-collapse:collapse;">
		<thead>
			<tr>
				<cfloop array="#display_label_arr#" index="lbl">
					<th style="border:1px solid ##999;padding:4px 8px;background:##eee;text-align:left;">#htmlEditFormat(lbl)#</th>
				</cfloop>
			</tr>
		</thead>
		<tbody>
			<cfloop from="1" to="#attributes.query.recordCount#" index="row_idx">
				<cfif len(group_column_name)>
					<cfset excel_group_val = attributes.query[group_column_name][row_idx]>
					<cfif row_idx eq 1 or compare(excel_group_val, excel_last_group) neq 0>
						<tr>
							<td colspan="#arrayLen(display_column_arr)#" style="border:1px solid ##ccc;padding:4px 8px;background:##eef1f5;"><strong>#htmlEditFormat(excel_group_val)#</strong></td>
						</tr>
						<cfset excel_last_group = excel_group_val>
					</cfif>
				</cfif>
				<tr>
					<cfloop array="#display_column_arr#" index="col_name">
						<cfset raw_val = attributes.query[col_name][row_idx]>
						<cfif column_types[col_name] eq "date" and len(trim(raw_val)) and isDate(raw_val)>
							<cfset display_val = dateFormat(raw_val, dateformat_style)>
						<cfelse>
							<cfset display_val = raw_val>
						</cfif>
						<td style="border:1px solid ##ccc;padding:4px 8px;">#htmlEditFormat(display_val)#</td>
					</cfloop>
				</tr>
			</cfloop>
			<cfif attributes.show_totals and arrayLen(total_column_arr)>
				<tr>
					<cfloop array="#display_column_arr#" index="col_name">
						<cfif col_name eq display_column_arr[1]>
							<td style="border:1px solid ##ccc;padding:4px 8px;"><strong>TOPLAM</strong></td>
						<cfelseif listFindNoCase(total_columns_list, col_name)>
							<cfset col_sum = 0>
							<cfloop from="1" to="#attributes.query.recordCount#" index="sum_row_idx">
								<cfset col_sum = col_sum + val(attributes.query[col_name][sum_row_idx])>
							</cfloop>
							<td style="border:1px solid ##ccc;padding:4px 8px;"><strong>#col_sum#</strong></td>
						<cfelse>
							<td style="border:1px solid ##ccc;padding:4px 8px;"></td>
						</cfif>
					</cfloop>
				</tr>
			</cfif>
		</tbody>
	</table>
	</cfoutput>
	<cfexit method="exittag">
</cfif>

<cfif attributes.show_totals>
	<cfset js_show_totals = "true">
<cfelse>
	<cfset js_show_totals = "false">
</cfif>

<cfoutput>
<style>
	##adaTableWrap_#registry_key# { font-family:inherit; }
	##adaTableWrap_#registry_key# .ada-table-toolbar { display:flex; flex-wrap:wrap; align-items:center; gap:10px; margin-bottom:10px; }
	##adaTableWrap_#registry_key# .ada-table-search {
		padding:6px 10px; border:1px solid ##c9d0d8; border-radius:5px; min-width:230px; font-size:13px;
	}
	##adaTableWrap_#registry_key# .ada-table-scroll {
		overflow-x:auto; width:100%; border:1px solid ##d8dde3; border-radius:6px;
	}
	##adaTableWrap_#registry_key# table {
		width:100%; border-collapse:collapse; white-space:nowrap; font-size:13px;
	}
	##adaTableWrap_#registry_key# thead th {
		background:##eef1f5; color:##33424e; text-align:left;
		padding:9px 10px; font-weight:600; font-size:11px; text-transform:uppercase; letter-spacing:.04em;
		border-bottom:2px solid ##c9d0d8; border-right:1px solid ##dde2e7; box-sizing:border-box;
	}
	##adaTableWrap_#registry_key# thead th:last-child { border-right:none; }
	<!--- Gercek thead ekrandan cikinca JS'in gosterdigi position:fixed kopya (CSS sticky, ata elementlerdeki overflow yuzunden guvenilmez). z-index cok yuksek: host navbar'larin altinda kalmasin diye. Gercek "top" degerini JS hesaplar. --->
	##adaTableWrap_#registry_key# .ada-table-sticky-head {
		position:fixed; top:0; overflow:hidden; z-index:2147483000; display:none;
		box-shadow:0 2px 6px rgba(0,0,0,.12); border-bottom:2px solid ##c9d0d8;
	}
	##adaTableWrap_#registry_key# .ada-table-sticky-head table {
		border-collapse:collapse; white-space:nowrap; font-size:13px; width:auto;
	}
	##adaTableWrap_#registry_key# .ada-table-sticky-head th {
		background:##eef1f5; color:##33424e; text-align:left;
		padding:9px 10px; font-weight:600; font-size:11px; text-transform:uppercase; letter-spacing:.04em;
		border-right:1px solid ##dde2e7; box-sizing:border-box;
	}
	##adaTableWrap_#registry_key# .ada-table-sticky-head th:last-child { border-right:none; }
	##adaTableWrap_#registry_key# .ada-table-total-toggle {
		display:block; margin-top:4px; font-weight:400; font-size:10px; text-transform:none;
		letter-spacing:normal; color:##6b7680; cursor:pointer;
	}
	##adaTableWrap_#registry_key# .ada-table-total-toggle input { margin-right:3px; vertical-align:middle; cursor:pointer; }
	##adaTableWrap_#registry_key# .ada-table-total-fixed { cursor:default; font-style:italic; color:##8a94a0; }
	##adaTableWrap_#registry_key# tbody td {
		padding:8px 10px; border-bottom:1px solid ##edf0f3; border-right:1px solid ##f2f4f6; color:##2b333a;
	}
	##adaTableWrap_#registry_key# tbody td:last-child { border-right:none; }
	##adaTableWrap_#registry_key# tbody tr:nth-child(even) { background:##f8fafb; }
	##adaTableWrap_#registry_key# tbody tr:hover { background:##eaf2fb; }
	<!--- group_column verildiginde satirlar arasina giren tam genislikte grup basligi (nth-child/hover kurallarini ezmesi icin daha spesifik). --->
	##adaTableWrap_#registry_key# tbody tr.ada-table-group-row td,
	##adaTableWrap_#registry_key# tbody tr.ada-table-group-row:hover td {
		background:##eef1f5; color:##33424e; font-weight:700; border-top:1px solid ##c9d0d8;
	}
	##adaTableWrap_#registry_key# tfoot td {
		padding:8px 10px; font-weight:700; color:##33424e;
		background:##fff6db; border-top:2px solid ##e3c266; border-right:1px solid ##f0e0ac;
	}
	##adaTableWrap_#registry_key# tfoot td:last-child { border-right:none; }
	##adaTableWrap_#registry_key# tfoot tr:last-child td { background:##eef6ee; border-top:1px solid ##cfe4cf; }
	##adaTableWrap_#registry_key# .ada-table-paging {
		display:flex; align-items:center; gap:8px; margin-top:10px; flex-wrap:wrap; font-size:12px; color:##55606a;
	}
	##adaTableWrap_#registry_key# .ada-table-paging button {
		padding:4px 10px; border:1px solid ##c9d0d8; border-radius:4px; background:##fff; cursor:pointer; font-size:12px;
	}
	##adaTableWrap_#registry_key# .ada-table-paging button:hover:not(:disabled) { background:##eef1f5; }
	##adaTableWrap_#registry_key# .ada-table-paging button:disabled { opacity:.4; cursor:default; }
	##adaTableWrap_#registry_key# .ada-table-paging button.ada-table-page-current {
		background:##33424e; color:##fff; border-color:##33424e;
	}
</style>
<div class="ada-table-wrap" id="adaTableWrap_#registry_key#">
	<div class="ada-table-toolbar">
		<cfif len(attributes.title)>
			<strong style="margin-right:auto;">#htmlEditFormat(attributes.title)#</strong>
		</cfif>
		<input type="text" class="ada-table-search" id="adaTableSearch_#registry_key#" placeholder="Ara...">
	</div>

	<div class="ada-table-scroll">
		<table id="adaTable_#registry_key#">
			<thead>
				<tr>
					<cfloop from="1" to="#arrayLen(display_column_arr)#" index="th_idx">
						<cfset th_col = display_column_arr[th_idx]>
						<cfset th_lbl = display_label_arr[th_idx]>
						<th>
							#htmlEditFormat(th_lbl)#
							<cfif attributes.show_totals and column_types[th_col] eq "number" and compareNoCase(th_col, attributes.aggregate_column) neq 0>
								<label class="ada-table-total-toggle">
									<input type="checkbox" data-col="#th_col#" <cfif listFindNoCase(total_columns_list, th_col)>checked</cfif>> Topla
								</label>
							<cfelseif attributes.show_totals and th_col eq attributes.aggregate_column>
								<span class="ada-table-total-toggle ada-table-total-fixed">Toplam (sabit)</span>
							</cfif>
						</th>
					</cfloop>
				</tr>
			</thead>
			<tbody id="adaTableBody_#registry_key#"></tbody>
			<cfif attributes.show_totals>
				<tfoot id="adaTableFoot_#registry_key#"></tfoot>
			</cfif>
		</table>
	</div>

	<!--- Sticky kopya: scroll kutusunun DISINDA, position:fixed - gercek header ekrandan cikinca JS bunu gosterir. --->
	<div class="ada-table-sticky-head" id="adaTableStickyHead_#registry_key#">
		<table>
			<thead>
				<tr id="adaTableStickyRow_#registry_key#"></tr>
			</thead>
		</table>
	</div>

	<div class="ada-table-paging" id="adaTablePaging_#registry_key#"></div>
</div>

<script type="text/javascript">
	// IIFE: state global scope'a sizmasin, ayni sayfadaki diger instance'larla cakismasin.
	(function() {
		var atInstance = '#registry_key#';
		var atRows = #serializeJSON(table_rows)#;
		// atColumns = ekranda cizilen sutunlar (grup kolonu haric); atSearchColumns satirin tasidigi tum kolonlar - grup basligindaki metin de aranabilsin diye.
		var atColumns = #serializeJSON(display_column_arr)#;
		var atSearchColumns = #serializeJSON(column_arr)#;
		var atGroupColumn = #serializeJSON(group_column_name)#;
		var atLabels = #serializeJSON(display_label_arr)#;
		var atTotalColumns = #serializeJSON(total_column_arr)#;
		var atAggregateColumn = '#jsStringFormat(attributes.aggregate_column)#';
		var atShowTotals = #js_show_totals#;
		var atPageSize = #val(attributes.page_size)# || 20;

		// Lazy/ajax sayfalama (opsiyonel - bkz. dosya basi "LAZY / SUNUCU TARAFLI SAYFALAMA" bolumu). lazy verilmediyse atLazyMode false kalir, asagidaki TUM dallanmalar bugunku (tamamen client-side) davranisa duser.
		var atLazyMode = #attributes.lazy ? "true" : "false"#;
		var atAjaxUrl = #serializeJSON(len(attributes.ajax_url) ? attributes.ajax_url : "")#;
		var atAjaxParams = #serializeJSON(attributes.ajax_params)#;
		var atTotalRows = #val(attributes.total_rows)#;
		var atAllowShowAll = #attributes.allow_show_all ? "true" : "false"#;
		var atRequestSeq = 0;
		var atAllLoaded = !atLazyMode;

		var atFiltered = atRows;
		var atPage = 1;
		var atShowAll = false;
		// O an aktif toplam kolonlari: baslangic kumesi total_columns'tan gelir, kullanici kutucuklarla degistirebilir (sunucuya geri yazilmaz).
		var atActiveTotalColumns = atTotalColumns.slice();

		function atNormalize(s) {
			return String(s === null || typeof s === 'undefined' ? '' : s).toLocaleLowerCase('tr');
		}

		function atMatchesSearch(row, term) {
			if (!term) return true;
			for (var i = 0; i < atSearchColumns.length; i++) {
				if (atNormalize(row.cells[atSearchColumns[i]]).indexOf(term) !== -1) return true;
			}
			return false;
		}

		function atApplySearch(text) {
			var term = atNormalize(text);
			atFiltered = [];
			for (var i = 0; i < atRows.length; i++) {
				if (atMatchesSearch(atRows[i], term)) atFiltered.push(atRows[i]);
			}
			atPage = 1;
			atRender();
		}

		// 11.07.cfm'deki pieParseResponse ile ayni desen, farkli marker (AT_JSON) - iki ozellik ayni sayfada calissa bile marker'lar cakismasin diye.
		function atParseAjaxResponse(txt) {
			var start = txt.indexOf('@@AT_JSON@@');
			var end = txt.indexOf('@@AT_JSON_SON@@');
			if (start > -1 && end > start) {
				try { return JSON.parse(txt.substring(start + 11, end)); } catch (e) {}
			}
			try { return JSON.parse(txt); } catch (e) {}
			return null;
		}

		// Bir sayfayi (ya da at_page="all" ile hepsini) sunucudan ister; cevapta gelen "rows" dizisi (ayni {cells,totals} sekli) atRows'un yerini alir. Arama kutusunda aktif bir terim varsa yeni sayfaya da (client-side) yeniden uygulanir.
		function atFetchPage(page, showAll) {
			var url = atAjaxUrl || (window.location.pathname + window.location.search);
			var params = 'at_instance=' + encodeURIComponent(atInstance)
				+ '&at_page=' + (showAll ? 'all' : page)
				+ '&at_page_size=' + atPageSize
				+ (atAjaxParams ? '&' + atAjaxParams : '');
			var seq = ++atRequestSeq;
			fetch(url, {
				method: 'POST',
				headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
				credentials: 'same-origin',
				body: params
			})
			.then(function(response) { return response.text(); })
			.then(function(txt) {
				if (seq !== atRequestSeq) return;
				var data = atParseAjaxResponse(txt);
				if (!data || data.error) {
					console.error('cf_ada_table ajax hata:', data && data.error);
					return;
				}
				atRows = data.rows;
				atTotalRows = data.total_rows;
				if (showAll) {
					atAllLoaded = true;
					atShowAll = true;
				} else {
					atPage = page;
				}
				if (searchInput && searchInput.value) {
					atApplySearch(searchInput.value);
				} else {
					atFiltered = atRows;
					atRender();
				}
			})
			.catch(function(err) {
				if (seq !== atRequestSeq) return;
				console.error('cf_ada_table ajax hata:', err);
			});
		}

		function atSumColumn(rows, col) {
			var sum = 0;
			for (var i = 0; i < rows.length; i++) {
				sum += Number(rows[i].totals[col] || 0);
			}
			return sum;
		}

		function atBuildCell(text) {
			var td = document.createElement('td');
			td.textContent = (text === null || typeof text === 'undefined') ? '' : text;
			return td;
		}

		// Grup basligi satiri: group_column degeri degistiginde (ve her sayfanin basinda, sayfa grubun ortasindan basliyor olabilir) tum sutunlari kaplayan tek hucre.
		function atBuildGroupRow(text) {
			var tr = document.createElement('tr');
			tr.className = 'ada-table-group-row';
			var td = document.createElement('td');
			td.colSpan = atColumns.length;
			var strong = document.createElement('strong');
			strong.textContent = (text === null || typeof text === 'undefined') ? '' : text;
			td.appendChild(strong);
			tr.appendChild(td);
			return tr;
		}

		function atRenderRows(pageRows) {
			var tbody = document.getElementById('adaTableBody_' + atInstance);
			if (!tbody) return;
			tbody.textContent = '';
			var lastGroup = null;
			for (var i = 0; i < pageRows.length; i++) {
				if (atGroupColumn) {
					var groupVal = pageRows[i].cells[atGroupColumn];
					if (i === 0 || groupVal !== lastGroup) {
						tbody.appendChild(atBuildGroupRow(groupVal));
						lastGroup = groupVal;
					}
				}
				var tr = document.createElement('tr');
				for (var c = 0; c < atColumns.length; c++) {
					tr.appendChild(atBuildCell(pageRows[i].cells[atColumns[c]]));
				}
				tbody.appendChild(tr);
			}
		}

		function atMakePageBtn(label, page, disabled) {
			var btn = document.createElement('button');
			btn.type = 'button';
			btn.textContent = label;
			btn.disabled = !!disabled;
			btn.addEventListener('click', function() {
				if (atLazyMode && !atAllLoaded) {
					atFetchPage(page, false);
				} else {
					atPage = page;
					atRender();
				}
			});
			return btn;
		}

		function atMakeToggleShowAllBtn() {
			var btn = document.createElement('button');
			btn.type = 'button';
			btn.textContent = atShowAll ? 'Sayfalara Böl' : 'Tümünü Göster';
			btn.addEventListener('click', function() {
				if (atLazyMode && !atAllLoaded) {
					atFetchPage(1, true);
					return;
				}
				atShowAll = !atShowAll;
				atPage = 1;
				atRender();
			});
			return btn;
		}

		function atRenderPaging(totalRows, totalPages) {
			var el = document.getElementById('adaTablePaging_' + atInstance);
			if (!el) return;
			el.textContent = '';

			if (totalRows === 0) return;

			// "Tumunu Goster" aktifken bile gecis butonu gorunsun diye normalde kac sayfa gerekirdi hesabi.
			var naturalTotalPages = Math.max(1, Math.ceil(totalRows / atPageSize));
			if (naturalTotalPages <= 1) return;

			var info = document.createElement('span');
			if (atShowAll) {
				info.textContent = totalRows + ' kayıt (tümü) gösteriliyor';
			} else {
				var startIdx = ((atPage - 1) * atPageSize) + 1;
				var endIdx = Math.min(atPage * atPageSize, totalRows);
				info.textContent = totalRows + ' kayıttan ' + startIdx + '-' + endIdx + ' arası gösteriliyor';
			}
			el.appendChild(info);

			if (!atShowAll) {
				el.appendChild(atMakePageBtn('« Önceki', atPage - 1, atPage <= 1));
				for (var p = 1; p <= totalPages; p++) {
					var b = atMakePageBtn(String(p), p, false);
					if (p === atPage) b.className = 'ada-table-page-current';
					el.appendChild(b);
				}
				el.appendChild(atMakePageBtn('Sonraki »', atPage + 1, atPage >= totalPages));
			}

			if (atAllowShowAll) el.appendChild(atMakeToggleShowAllBtn());
		}

		function atBuildTotalRow(label, sums) {
			var tr = document.createElement('tr');
			for (var c = 0; c < atColumns.length; c++) {
				var td = document.createElement('td');
				var col = atColumns[c];
				if (c === 0) {
					td.textContent = label;
				} else if (col === atAggregateColumn || atActiveTotalColumns.indexOf(col) !== -1) {
					td.textContent = sums[col];
				}
				tr.appendChild(td);
			}
			return tr;
		}

		// aggregate_column'un toplami sabit degil: kutucugu KAPALI olan diger toplam kolonlarinin toplami ham toplamdan dusulur.
		function atComputeAggregateSum(rows) {
			var sum = atSumColumn(rows, atAggregateColumn);
			for (var i = 0; i < atTotalColumns.length; i++) {
				var col = atTotalColumns[i];
				if (col === atAggregateColumn) continue;
				if (atActiveTotalColumns.indexOf(col) === -1) {
					sum -= atSumColumn(rows, col);
				}
			}
			return sum;
		}

		function atRenderTotals(pageRows, totalPages) {
			if (!atShowTotals) return;
			var tfoot = document.getElementById('adaTableFoot_' + atInstance);
			if (!tfoot) return;
			tfoot.textContent = '';

			var grandSums = {};
			if (atAggregateColumn) {
				grandSums[atAggregateColumn] = atComputeAggregateSum(atFiltered);
			}
			for (var i = 0; i < atActiveTotalColumns.length; i++) {
				var col = atActiveTotalColumns[i];
				if (col === atAggregateColumn) continue;
				grandSums[col] = atSumColumn(atFiltered, col);
			}

			// Lazy modda "Sayfa Toplamı"/"Genel Toplam" ayrimi yok - tek "Toplam" satiri, sadece o an yuklu olan veriye gore (sayfadaysa sayfanin, "Tumunu Goster" sonrasi hepsinin) - bkz. dosya basi "LAZY / SUNUCU TARAFLI SAYFALAMA".
			if (atLazyMode) {
				tfoot.appendChild(atBuildTotalRow('Toplam', grandSums));
				return;
			}

			// Tek sayfa varsa "Sayfa Toplamı" = "Genel Toplam" olacagindan tekrar gostermeye gerek yok.
			if (totalPages > 1) {
				var pageSums = {};
				if (atAggregateColumn) {
					pageSums[atAggregateColumn] = atComputeAggregateSum(pageRows);
				}
				for (var j = 0; j < atActiveTotalColumns.length; j++) {
					var pcol = atActiveTotalColumns[j];
					if (pcol === atAggregateColumn) continue;
					pageSums[pcol] = atSumColumn(pageRows, pcol);
				}
				tfoot.appendChild(atBuildTotalRow('Sayfa Toplamı', pageSums));
			}

			tfoot.appendChild(atBuildTotalRow('Genel Toplam', grandSums));
		}

		// Kullanici bir kolonun "Topla" kutucugunu ac/kapat yapinca aktif kume guncellenir ve tum tabloyu yeniden cizmeye gerek kalmadan sadece toplam satirlari yenilenir.
		function atToggleTotalColumn(col, isOn) {
			var idx = atActiveTotalColumns.indexOf(col);
			if (isOn && idx === -1) atActiveTotalColumns.push(col);
			if (!isOn && idx !== -1) atActiveTotalColumns.splice(idx, 1);
			atRender();
		}

		function atRender() {
			var totalRows, totalPages, pageRows;

			if (atLazyMode && !atAllLoaded) {
				// atRows/atFiltered zaten sadece o an sunucudan gelen sayfa - hepsi gosterilir; sayfa sayisi sunucunun bildirdigi total_rows'a gore hesaplanir (client hicbir zaman tum veriyi gormedi).
				totalRows = atTotalRows;
				totalPages = Math.max(1, Math.ceil(totalRows / atPageSize));
				pageRows = atFiltered;
			} else {
				totalRows = atFiltered.length;
				var effectivePageSize = atShowAll ? Math.max(totalRows, 1) : atPageSize;
				totalPages = atShowAll ? 1 : Math.max(1, Math.ceil(totalRows / atPageSize));
				if (atPage > totalPages) atPage = totalPages;
				if (atPage < 1) atPage = 1;

				var start = (atPage - 1) * effectivePageSize;
				pageRows = atFiltered.slice(start, start + effectivePageSize);
			}
			atRenderRows(pageRows);
			atRenderPaging(totalRows, totalPages);
			atRenderTotals(pageRows, totalPages);
			atUpdateSticky();
		}

		var atScrollBox = document.querySelector('##adaTableWrap_' + atInstance + ' .ada-table-scroll');
		var atRealTheadRow = document.querySelector('##adaTable_' + atInstance + ' thead tr');
		var atStickyHead = document.getElementById('adaTableStickyHead_' + atInstance);
		var atStickyRow = document.getElementById('adaTableStickyRow_' + atInstance);
		var atStickyTable = atStickyHead ? atStickyHead.querySelector('table') : null;

		// Fixed kopya header: her <th>'in tam kopyasi (kutucuklar dahil). Kopya ayri bir <table> oldugu icin genislikler pikselle kopyalanir; icerik degisebildiginden her "stuck" kontrolunde yeniden kurulur.
		function atSyncStickyHead() {
			if (!atStickyRow || !atRealTheadRow) return;
			var ths = atRealTheadRow.querySelectorAll('th');
			atStickyRow.innerHTML = '';
			for (var i = 0; i < ths.length; i++) {
				var cloneTh = ths[i].cloneNode(true);
				cloneTh.style.width = ths[i].getBoundingClientRect().width + 'px';
				atStickyRow.appendChild(cloneTh);

				// Kopya kutucuk ayri bir DOM elementi - degisiklik gercek kutucuga da yazilir.
				var cloneCheckbox = cloneTh.querySelector('input[data-col]');
				if (cloneCheckbox) {
					(function(checkboxEl) {
						checkboxEl.addEventListener('change', function() {
							var col = checkboxEl.getAttribute('data-col');
							var realCheckbox = atRealTheadRow.querySelector('input[data-col="' + col + '"]');
							if (realCheckbox) realCheckbox.checked = checkboxEl.checked;
							atToggleTotalColumn(col, checkboxEl.checked);
						});
					})(cloneCheckbox);
				}
			}
			if (atStickyTable) atStickyTable.style.width = atRealTheadRow.getBoundingClientRect().width + 'px';
		}

		// Host sayfada sabit navbar varsa kopya header onun altinda kalmasin diye asagi itilir; .navbar-fixed-top yoksa offset 0 kalir.
		function atGetFixedNavOffset() {
			var navEl = document.querySelector('.navbar-fixed-top');
			return navEl ? navEl.getBoundingClientRect().height : 0;
		}

		// CSS position:sticky yerine JS: sticky, ata elementlerden birindeki overflow yuzunden calismayi kesebiliyor ve host sayfanin CSS'ine guvenilemez. getBoundingClientRect hangi atanin scroll ettigini bilmeyi gerektirmez; scroll dinleyicisi de capture ile document'e baglanir (scroll event'i bubble etmez).
		function atUpdateSticky() {
			if (!atScrollBox || !atStickyHead || !atRealTheadRow) return;
			var topOffset = atGetFixedNavOffset();
			var rect = atScrollBox.getBoundingClientRect();
			var headHeight = atRealTheadRow.getBoundingClientRect().height || 0;
			var shouldStick = rect.top < topOffset && rect.bottom > (topOffset + headHeight);
			if (shouldStick) {
				atSyncStickyHead();
				atStickyHead.style.display = 'block';
				atStickyHead.style.top = topOffset + 'px';
				atStickyHead.style.left = rect.left + 'px';
				atStickyHead.style.width = atScrollBox.clientWidth + 'px';
				if (atStickyTable) atStickyTable.style.transform = 'translateX(-' + atScrollBox.scrollLeft + 'px)';
			} else {
				atStickyHead.style.display = 'none';
			}
		}

		document.addEventListener('scroll', atUpdateSticky, true);
		window.addEventListener('resize', atUpdateSticky);
		if (atScrollBox) {
			atScrollBox.addEventListener('scroll', function() {
				if (atStickyHead && atStickyHead.style.display === 'block' && atStickyTable) {
					atStickyTable.style.transform = 'translateX(-' + atScrollBox.scrollLeft + 'px)';
				}
			});
		}

		var searchInput = document.getElementById('adaTableSearch_' + atInstance);
		if (searchInput) {
			searchInput.addEventListener('input', function() {
				atApplySearch(searchInput.value);
			});
		}

		var wrapEl = document.getElementById('adaTableWrap_' + atInstance);
		if (wrapEl) {
			var toggles = wrapEl.querySelectorAll('.ada-table-total-toggle input[data-col]');
			for (var tgIdx = 0; tgIdx < toggles.length; tgIdx++) {
				(function(toggleEl) {
					toggleEl.addEventListener('change', function() {
						atToggleTotalColumn(toggleEl.getAttribute('data-col'), toggleEl.checked);
					});
				})(toggles[tgIdx]);
			}
		}

		atRender();
	})();
</script>
</cfoutput>
