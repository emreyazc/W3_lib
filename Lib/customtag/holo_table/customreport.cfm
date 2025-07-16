<!---
  Custom Tag: cf_customreport.cfm
  Amaç    : SQL sorgusundan gelen verileri tablo halinde görüntülemek,
            istenilen kolonları göstermek ve gerekli formatlamaları uygulamak.

  Parametreler:
  ------------------------------------------------------------------------------
  query               [required]  : ColdFusion query nesnesi
  columns             [required]  : Gösterilecek kolon isimleri (virgülle ayrılmış)
  titles              [required]  : Kolon başlıkları (columns ile aynı sırada)
  formats             [optional]  : Her kolona ait format tipi (string, money, date, percent, etc.)
  dateformat_style    [optional]  : 'date' format türü için kullanılacak biçim (varsayılan: dd.mm.yyyy)
  money_precision     [optional]  : 'money' format türü için virgülden sonra gösterilecek basamak (varsayılan: 2)
  export              [optional]  : true/false – tabloyu Excel'e export edecek butonu gösterir
  tableId             [optional]  : Tabloya özel bir HTML id vermek için (otomatik oluşturulur)
  searching           [optional]  : Genel arama kutusunu devreye sokar / devre dışı bırakır.
  pageLength          [optional]  : Sayfada gösterilecek kayıt sayısını belirler. Default olarak 25 dir.

  Desteklenen Format Türleri:
  ------------------------------------------------------------------------------
  string              : Varsayılan düz metin
  date                : Tarih gösterimi (dateFormat kullanır)
  money               : TLFormat(val, money_precision) ile para biçimi
  number              : Noktalı sayı (9.999,00)
  percent             : Yüzde formatı (%)
  yesno               : 1 → Evet, 0 → Hayır
  link                : URL'yi tıklanabilir hale getirir
  mail                : Mailto link
  badge               : CSS ile etiket görünümü
  icon                : 1 → ✅, 0 → ❌

  Örnek Kullanım:
  ------------------------------------------------------------------------------
  <cf_customreport 
    query="#qEmployees#"
    columns="EMPLOYEE_NAME,EMPLOYEE_SURNAME,RECORD_DATE,SALARY"
    titles="Adı,Soyadı,Kayıt Tarihi,Maaş"
    formats="string,string,date,money"
    money_precision="3"
    dateformat_style="dd.MM.yyyy"
    export="true">
--->

<cfparam name="attributes.query" default="">
<cfparam name="attributes.titles" default="">
<cfparam name="attributes.columns" default="">
<cfparam name="attributes.formats" default="">
<cfparam name="attributes.export" default="false">
<cfparam name="attributes.searching" default="false">
<cfparam name="attributes.pageLength" default="25">
<cfparam name="attributes.dateformat_style" default="dd.mm.yyyy">
<cfparam name="attributes.money_precision" default="2">
<cfparam name="attributes.tableId" default="cfreport_#createUUID()#">

<cfset local.q = attributes.query>
<cfset local.titleArray = ListToArray(attributes.titles)>
<cfset local.columnArray = ListToArray(attributes.columns)>
<cfset local.formatArray = ListToArray(attributes.formats)>
<cfset local.rowCount = local.q.recordCount>

<cf_box>
  <table id="<cfoutput>#attributes.tableId#</cfoutput>" class="table table-striped table-bordered" border="1" cellspacing="0" cellpadding="5">
    <thead>
      <cfoutput>
        <tr>
          <cfloop array="#local.titleArray#" index="header">
            <th>#header#</th>
          </cfloop>
        </tr>
        <tr>
          <cfloop from="1" to="#arrayLen(local.columnArray)#" index="k">
            <th><input type="text" placeholder="Ara..." style="width: 100%; box-sizing: border-box;"></th>
          </cfloop>
        </tr>
      </cfoutput>
    </thead>
    <tbody>
      <cfif local.rowCount EQ 0>
        <tr>
          <td colspan="<cfoutput>#arrayLen(local.columnArray)#</cfoutput>" style="text-align:center; font-style:italic; color:#888;">Kayıt bulunamadı !</td>
        </tr>
      <cfelse>
        <cfoutput>
          <cfloop from="1" to="#local.rowCount#" index="i">
            <tr>
              <cfloop index="j" from="1" to="#arrayLen(local.columnArray)#">
                <cfset col = local.columnArray[j]>
                <cfset val = local.q[col][i]>
                <cfset fmt = arrayLen(local.formatArray) GTE j ? local.formatArray[j] : "string">
  
                <td>
                  <cfif fmt EQ "date">
                    #dateFormat(val, attributes.dateformat_style)#
                  <cfelseif fmt EQ "money">
                    #caller.TLFormat(val, attributes.money_precision)#
                  <cfelseif fmt EQ "number">
                    #numberFormat(val, "9.999,00")#
                  <cfelseif fmt EQ "percent">
                    #numberFormat(val * 100, "9.99")# %
                  <cfelseif fmt EQ "yesno">
                    <cfif val EQ 1>
                      Evet
                    <cfelse>
                      Hayır
                    </cfif>
                  <cfelseif fmt EQ "link">
                    <a href="#val#" target="_blank">Link</a>
                  <cfelseif fmt EQ "mail">
                    <a href="mailto:#val#">#val#</a>
                  <cfelseif fmt EQ "badge">
                    <span class="badge">#val#</span>
                  <cfelseif fmt EQ "icon">
                    <cfif val EQ 1>✅<cfelse>❌</cfif>
                  <cfelse>
                    #HTMLEditFormat(val)#
                  </cfif>
                </td>
              </cfloop>
            </tr>
          </cfloop>
        </cfoutput>
      </cfif>
    </tbody>
  </table>
</cf_box>

<!-- DataTables & Export Kütüphaneleri -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.7/css/jquery.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.4.2/css/buttons.dataTables.min.css">
<link rel="stylesheet" href="https://cdn.datatables.net/colreorder/1.6.2/css/colReorder.dataTables.min.css">

<script src="https://cdn.datatables.net/1.13.7/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.print.min.js"></script>
<script src="https://cdn.datatables.net/colreorder/1.6.2/js/dataTables.colReorder.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js"></script>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    var table = $('#<cfoutput>#attributes.tableId#</cfoutput>').DataTable({
      dom: 'Blfrtip',
      paging: true,
      searching: true,
      ordering: true,
      responsive: true,
      orderCellsTop: true,
      colReorder: true,
      pageLength: <cfoutput>#attributes.pageLength#</cfoutput>,
      lengthMenu: [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "Tümü"] ],
      buttons: [
        'copyHtml5',
        'excelHtml5',
        'csvHtml5',
        'pdfHtml5',
        'print',
        'colvis', // kolon görünürlüğü
      ],
      language: {
        //url: "//cdn.datatables.net/plug-ins/1.13.7/i18n/tr.json",
        emptyTable: 'Kayıt Bulunamadı !',
        lengthMenu: 'Sayfada _MENU_ Kayıt Göster',
        //info: 'Toplam _PAGES_ Sayfadan _PAGE_. Sayfadasınız ',
        search: 'Ara',
        infoFiltered: '(_MAX_ kayıt içerisinden bulunan)',
        info: '_TOTAL_ kayıttan _START_ - _END_ arasındaki kayıtlar gösteriliyor',
        buttons: {
        "collection": "Koleksiyon <span class=\"ui-button-icon-primary ui-icon ui-icon-triangle-1-s\"><\/span>",
        "colvis": "Sütun görünürlüğü",
        "colvisRestore": "Görünürlüğü eski haline getir",
        "copy": "KOPYALA",
        "copyKeys": "Tablodaki veriyi kopyalamak için CTRL veya u2318 + C tuşlarına basınız. İptal etmek için bu mesaja tıklayın veya escape tuşuna basın.",
        "copySuccess": {
            "_": "%ds satır panoya kopyalandı",
            "1": "1 satır panoya kopyalandı"
        },
        "copyTitle": "Panoya kopyala",
        "createState": "Şuanki Görünümü Kaydet",
        "csv": "CSV",
        "excel": "EXCEL",
        "pageLength": {
            "_": "%d satır göster",
            "-1": "Bütün satırları göster"
        },
        "pdf": "PDF",
        "print": "YAZDIR",
        "removeAllStates": "Tüm Görünümleri Sil",
        "removeState": "Aktif Görünümü Sil",
        "renameState": "Aktif Görünümün Adını Değiştir",
        "savedStates": "Kaydedilmiş Görünümler",
        "stateRestore": "Görünüm -&gt; %d",
        "updateState": "Aktif Görünümün Güncelle"
    },
        paginate: {
          "first":      "İlk",
          "last":       "Son",
          "next":       "İleri",
          "previous":   "Geri"
      },
      },
      search: {
        smart: false,
        caseInsensitive: true
      }
    });

    // Kolon başlıklarına göre filtre inputlarını aktif et
    $('#<cfoutput>#attributes.tableId#</cfoutput> thead tr:eq(1) th input').each(function (i) {
      $(this).on('keyup change', function () {
        if (table.column(i).search() !== this.value) {
          table.column(i).search(this.value).draw();
        }
      });
    });
  });
</script>

<!-- Basit stil (badge örneği için) -->
<style>
  .badge {
    background-color: #eee;
    border-radius: 4px;
    padding: 2px 6px;
    font-size: 12px;
    display: inline-block;
    color: #333;
  }
</style>