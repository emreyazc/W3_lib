<!--- Aylik kredi odeme raporu. Vade araligi [baslangic, sonraki ay). --->
<cfsetting showdebugoutput="no">
<cfparam name="attributes.executive_summary" default="0">
<cfset attributes.executive_summary = (isSimpleValue(attributes.executive_summary) and attributes.executive_summary eq "1") ? 1 : 0>
<cfparam name="attributes.report_month" default="">
<cfparam name="attributes.report_year" default="">
<cfparam name="attributes.report_start_date" default="">
<cfparam name="attributes.report_end_date" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.credit_type_id" default="">
<cfparam name="attributes.money_type" default="">
<cfparam name="attributes.credit_active_status" default="1">
<cfif not listFind("all,1,0",attributes.credit_active_status)>
    <cfset attributes.credit_active_status = "1">
</cfif>
<!--- Ilk acilista kapali krediler gizlenir; isaretsiz checkbox POST'ta gonderilmez. --->
<cfif not structKeyExists(attributes,"hide_completed")>
    <cfif structKeyExists(attributes,"credit_filters_submitted")>
        <cfset attributes.hide_completed = 0>
    <cfelse>
        <cfset attributes.hide_completed = 1>
    </cfif>
</cfif>
<cfset attributes.hide_completed = (isSimpleValue(attributes.hide_completed) and attributes.hide_completed eq "1") ? 1 : 0>


<cfif len(attributes.company_id) and not isValid("integer", attributes.company_id)>
    <cfset attributes.company_id = "">
</cfif>
<cfif len(attributes.credit_type_id) and not isValid("integer", attributes.credit_type_id)>
    <cfset attributes.credit_type_id = "">
</cfif>

<!--- Ay ve tarih araligi birbirini dislar. Tarih girdileri HTML date formatinda yyyy-mm-dd gelir. --->
<cfset credit_month_names = "Ocak,Şubat,Mart,Nisan,Mayıs,Haziran,Temmuz,Ağustos,Eylül,Ekim,Kasım,Aralık">
<cfset credit_filter_error = "">
<cfset credit_period_label = "">
<cfset attributes.report_start_date = trim(attributes.report_start_date)>
<cfset attributes.report_end_date = trim(attributes.report_end_date)>
<cfset credit_range_selected = len(attributes.report_start_date) or len(attributes.report_end_date)>
<cfif not structKeyExists(attributes,"credit_filters_submitted") and not credit_range_selected>
    <cfif not len(attributes.report_month)><cfset attributes.report_month = month(now())></cfif>
    <cfif not len(attributes.report_year)><cfset attributes.report_year = year(now())></cfif>
</cfif>
<cfif credit_range_selected>
    <cfif len(attributes.report_month)>
        <cfset credit_filter_error = "Ay ve tarih aralığı birlikte seçilemez. Tek bir dönem seçiniz.">
    <cfelseif not len(attributes.report_start_date) or not len(attributes.report_end_date)>
        <cfset credit_filter_error = "Başlangıç ve bitiş tarihlerini birlikte seçiniz.">
    <cfelseif not reFind("^[0-9]{4}-[0-9]{2}-[0-9]{2}$",attributes.report_start_date) or not reFind("^[0-9]{4}-[0-9]{2}-[0-9]{2}$",attributes.report_end_date)>
        <cfset credit_filter_error = "Geçerli bir başlangıç ve bitiş tarihi seçiniz.">
    <cfelse>
        <cftry>
            <cfset credit_filter_start = createDate(val(left(attributes.report_start_date,4)),val(mid(attributes.report_start_date,6,2)),val(right(attributes.report_start_date,2)))>
            <cfset credit_filter_end = createDate(val(left(attributes.report_end_date,4)),val(mid(attributes.report_end_date,6,2)),val(right(attributes.report_end_date,2)))>
            <cfif dateFormat(credit_filter_start,"yyyy-mm-dd") neq attributes.report_start_date or dateFormat(credit_filter_end,"yyyy-mm-dd") neq attributes.report_end_date
                or year(credit_filter_start) lt 1900 or year(credit_filter_end) gt 2100>
                <cfset credit_filter_error = "1900 ile 2100 arasında geçerli tarihler seçiniz.">
            <cfelseif dateCompare(credit_filter_start,credit_filter_end) gt 0>
                <cfset credit_filter_error = "Başlangıç tarihi bitiş tarihinden sonra olamaz.">
            <cfelse>
                <cfset credit_filter_end_exclusive = dateAdd("d",1,credit_filter_end)>
                <cfset credit_period_label = dateFormat(credit_filter_start,"dd/mm/yyyy") & " - " & dateFormat(credit_filter_end,"dd/mm/yyyy")>
                <cfset attributes.report_year = "">
            </cfif>
            <cfcatch type="any"><cfset credit_filter_error = "Geçerli bir başlangıç ve bitiş tarihi seçiniz."></cfcatch>
        </cftry>
    </cfif>
<cfelse>
    <cfif not isValid("integer",attributes.report_month) or not isValid("integer",attributes.report_year)>
        <cfset credit_filter_error = "Bir ay ve yıl veya başlangıç-bitiş tarihleri seçiniz.">
    <cfelseif attributes.report_month lt 1 or attributes.report_month gt 12 or attributes.report_year lt 1900 or attributes.report_year gt 2100>
        <cfset credit_filter_error = "Geçerli bir ay ve 1900 ile 2100 arasında bir yıl seçiniz.">
    <cfelse>
        <cfset credit_filter_start = createDate(attributes.report_year,attributes.report_month,1)>
        <cfset credit_filter_end_exclusive = dateAdd("m",1,credit_filter_start)>
        <cfset credit_period_label = listGetAt(credit_month_names,attributes.report_month) & " " & attributes.report_year>
    </cfif>
</cfif>

<cfquery name="get_credit_institutions" datasource="#dsn3#">
    SELECT C.COMPANY_ID,
           C.FULLNAME AS KURUM
    FROM #dsn#.COMPANY C
    WHERE EXISTS (
        SELECT 1 FROM CREDIT_CONTRACT CC
        WHERE CC.COMPANY_ID = C.COMPANY_ID
    )
    ORDER BY KURUM, C.COMPANY_ID
</cfquery>
<cfquery name="get_credit_types" datasource="#dsn#">
    SELECT CREDIT_TYPE_ID, CREDIT_TYPE
    FROM SETUP_CREDIT_TYPE
    ORDER BY CREDIT_TYPE, CREDIT_TYPE_ID
</cfquery>
<cfquery name="get_credit_currencies" datasource="#dsn3#">
    SELECT DISTINCT MONEY_TYPE
    FROM CREDIT_CONTRACT
    WHERE MONEY_TYPE IS NOT NULL AND LTRIM(RTRIM(MONEY_TYPE)) <> ''
    ORDER BY MONEY_TYPE
</cfquery>

<style>
#creditFilters { --credit-ink:#172b4d; --credit-muted:#6b7a90; --credit-line:#e4eaf2; --credit-accent:#2463eb; color:var(--credit-ink); font-family:inherit; padding:8px 0 18px; }
#creditFilters .credit-heading { display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:20px; }
#creditFilters .credit-eyebrow { color:var(--credit-accent); font-size:11px; letter-spacing:1.2px; font-weight:700; margin-bottom:6px; }
#creditFilters h2 { margin:0; font-size:25px; font-weight:700; color:var(--credit-ink); }
#creditFilters .credit-subtitle { margin:7px 0 0; font-size:13px; color:var(--credit-muted); }
#creditFilters .credit-header-badge { padding:8px 13px; border:1px solid #cdebdc; border-radius:20px; background:#effaf4; color:#21734c; font-size:12px; white-space:nowrap; }
#creditFilters .credit-filter-card { padding:20px; background:#fff; border:1px solid var(--credit-line); border-radius:12px; box-shadow:0 3px 14px rgba(25,45,78,.035); }
#creditFilters .credit-section-label { font-size:14px; font-weight:700; margin-bottom:17px; }
#creditFilters #form_credit_monthly_report { width:100%; margin:0; padding:0; float:none; }
#creditFilters .credit-filter-grid::before, #creditFilters .credit-filter-grid::after, #creditFilters .credit-filter-actions::before, #creditFilters .credit-filter-actions::after { content:none !important; display:none !important; }
#creditFilters .credit-filter-grid { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:16px 20px; }
#creditFilters .credit-filter-field { min-width:0; width:auto !important; float:none !important; margin:0 !important; padding:0 !important; }
#creditFilters .credit-filter-field > label { display:block; width:auto !important; float:none !important; padding:0 !important; line-height:18px; font-size:12px; font-weight:600; color:#53647c; margin:0 0 7px; }
#creditFilters .credit-filter-field input[type=text], #creditFilters .credit-filter-field input[type=date], #creditFilters .credit-filter-field select { width:100% !important; max-width:100%; height:36px !important; min-height:36px; margin:0 !important; float:none !important; box-sizing:border-box; border:1px solid #d8e0ec; border-radius:6px; padding:7px 10px; color:var(--credit-ink); background-color:#fff; font-size:12px; }
#creditFilters .credit-filter-field select { padding-right:30px; background-repeat:no-repeat !important; background-position:right 10px center !important; }
#creditFilters .credit-filter-field input:focus, #creditFilters .credit-filter-field select:focus { border-color:#83a7f6; outline:none; box-shadow:0 0 0 3px rgba(36,99,235,.09); }
#creditFilters .credit-filter-actions { width:100%; box-sizing:border-box; float:none; display:flex; flex-wrap:wrap; justify-content:space-between; align-items:center; gap:14px; border-top:1px solid var(--credit-line); padding-top:16px; margin-top:20px; }
#creditFilters .credit-checkbox { display:flex; align-items:center; gap:8px; width:auto !important; float:none !important; padding:0 !important; margin:0; color:#53647c; font-size:12px; cursor:pointer; }
#creditFilters .credit-checkbox input { width:16px !important; height:16px !important; margin:0 !important; flex:0 0 16px; accent-color:var(--credit-accent); }
#creditFilters .credit-buttons { display:flex; flex-wrap:wrap; gap:10px; width:auto !important; float:none !important; margin-left:auto; }
#creditFilters .credit-button { border:0; border-radius:7px; padding:10px 18px; min-height:36px; font-size:13px; font-weight:600; cursor:pointer; background:var(--credit-accent); color:#fff; line-height:18px; }
#creditFilters .credit-button:hover { background:#194fc5; }
#creditFilters .credit-button:focus-visible { outline:2px solid #2463eb; outline-offset:3px; }
#creditFilters .credit-button-pdf { background:#f4f6fa; color:#43536d; border:1px solid #d8e0ec; }
#creditFilters .credit-button-pdf:hover { background:#e9edf5; }
#creditFilters .credit-button i { margin-right:6px; }
@media(max-width:1100px) { #creditFilters .credit-filter-grid { grid-template-columns:repeat(3,minmax(0,1fr)); } }
@media(max-width:760px) { #creditFilters .credit-filter-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } #creditFilters .credit-heading { align-items:flex-start; } #creditFilters h2 { font-size:21px; } }
@media(max-width:480px) { #creditFilters .credit-filter-grid { grid-template-columns:1fr; } #creditFilters .credit-filter-card { padding:15px; } #creditFilters .credit-header-badge { display:none; } #creditFilters .credit-buttons { width:100% !important; margin:0; } #creditFilters .credit-buttons button { flex:1; } }
</style>
<div id="creditFilters">
    <div class="credit-filter-card">
        <div class="credit-section-label">Rapor filtreleri</div>
        <cfform name="form_credit_monthly_report" id="form_credit_monthly_report" method="post" action="">
            <input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <input type="hidden" name="credit_filters_submitted" value="1">
            <div class="credit-filter-grid">
                <div class="credit-filter-field">
                    <label for="report_month">Ay</label>
                    <select name="report_month" id="report_month" title="Ay" aria-label="Ay" onchange="creditSelectMonth();">
                    <option value=""<cfif not len(attributes.report_month)> selected="selected"</cfif>>Ay seçiniz</option>
                    <cfloop from="1" to="12" index="credit_month_index">
                        <cfoutput><option value="#credit_month_index#"<cfif len(attributes.report_month) and attributes.report_month eq credit_month_index> selected</cfif>>#listGetAt(credit_month_names, credit_month_index)#</option></cfoutput>
                    </cfloop>
                </select>
                </div>
                <div class="credit-filter-field">
                    <label for="report_year">Yıl</label>
                    <cfoutput><input type="text" name="report_year" id="report_year" value="#encodeForHTMLAttribute(attributes.report_year)#" maxlength="4" placeholder="Yıl" title="Yıl" inputmode="numeric" onchange="creditSelectYear();"></cfoutput>
                </div>
                <div class="credit-filter-field">
                    <label for="report_start_date">Başlangıç Tarihi</label>
                    <cfoutput><input type="date" name="report_start_date" id="report_start_date" value="#encodeForHTMLAttribute(attributes.report_start_date)#" min="1900-01-01" max="2100-12-31" oninput="creditSelectRange();" onchange="creditSelectRange();"></cfoutput>
                </div>
                <div class="credit-filter-field">
                    <label for="report_end_date">Bitiş Tarihi</label>
                    <cfoutput><input type="date" name="report_end_date" id="report_end_date" value="#encodeForHTMLAttribute(attributes.report_end_date)#" min="1900-01-01" max="2100-12-31" oninput="creditSelectRange();" onchange="creditSelectRange();"></cfoutput>
                </div>
                <div class="credit-filter-field">
                    <label for="company_id">Kredi Kurumu</label>
                    <select name="company_id" id="company_id">
                            <option value="">Tümü</option>
                            <cfoutput query="get_credit_institutions">
                                <option value="#COMPANY_ID#"<cfif attributes.company_id eq COMPANY_ID> selected</cfif>>#encodeForHTML(KURUM)#</option>
                            </cfoutput>
                        </select>
                </div>
                <div class="credit-filter-field">
                    <label for="credit_type_id">Kredi Türü</label>
                    <select name="credit_type_id" id="credit_type_id">
                            <option value="">Tümü</option>
                            <cfoutput query="get_credit_types">
                                <option value="#CREDIT_TYPE_ID#"<cfif attributes.credit_type_id eq CREDIT_TYPE_ID> selected</cfif>>#encodeForHTML(CREDIT_TYPE)#</option>
                            </cfoutput>
                        </select>
                </div>
                <div class="credit-filter-field">
                    <label for="money_type">Döviz</label>
                    <select name="money_type" id="money_type">
                            <option value="">Tümü</option>
                            <cfoutput query="get_credit_currencies">
                                <option value="#encodeForHTMLAttribute(MONEY_TYPE)#"<cfif attributes.money_type eq MONEY_TYPE> selected</cfif>>#encodeForHTML(MONEY_TYPE)#</option>
                            </cfoutput>
                        </select>
                </div>
                <div class="credit-filter-field">
                    <label for="credit_active_status">Kredi Durumu</label>
                    <select name="credit_active_status" id="credit_active_status">
                        <option value="1"<cfif attributes.credit_active_status eq "1"> selected="selected"</cfif>>Aktif</option>
                        <option value="0"<cfif attributes.credit_active_status eq "0"> selected="selected"</cfif>>Pasif</option>
                        <option value="all"<cfif attributes.credit_active_status eq "all"> selected="selected"</cfif>>Tümü</option>
                    </select>
                </div>
            </div>
            <div class="credit-filter-actions">
                <label for="hide_completed" class="credit-checkbox">
                    <input type="checkbox" name="hide_completed" id="hide_completed" value="1"<cfif attributes.hide_completed eq 1> checked="checked"</cfif>>
                    Ödemesi bitmiş kredileri getirme
                </label>
                <label for="executive_summary" class="credit-checkbox"><input type="checkbox" name="executive_summary" id="executive_summary" value="1"<cfif attributes.executive_summary eq 1> checked="checked"</cfif>> Yöneticiye Özet</label>
                <div class="credit-buttons">
                    <button type="submit" class="credit-button" onclick="return creditMonthlyFilterControl();">Raporu Getir</button>
                    <button type="button" class="credit-button credit-button-pdf" onclick="creditMonthlyPdf();"><i class="fa fa-file-pdf-o" aria-hidden="true"></i>PDF Çıkart</button>
                </div>
            </div>
        </cfform>
    </div>
</div>
<cfif len(credit_filter_error)>
    <cfoutput><div class="alert alert-danger" role="alert">#encodeForHTML(credit_filter_error)#</div></cfoutput>
    <cfexit method="exittemplate">
</cfif>

<!--- Sadece mevcut sirketin yil bazli gerceklesen hareket tablolari.
      Compare/yedek semalari bilerek dahil edilmez. --->
<cfquery name="credit_payment_schemas" datasource="#dsn3#">
    SELECT TABLE_SCHEMA
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CREDIT_CONTRACT_PAYMENT_INCOME'
      AND TABLE_TYPE = 'BASE TABLE'
      AND TABLE_SCHEMA LIKE <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#dsn#[_][12][0-9][0-9][0-9][_]#val(session.ep.company_id)#">
    ORDER BY TABLE_SCHEMA
</cfquery>
<cfif not credit_payment_schemas.recordCount>
    <cfthrow message="Kredi ödeme tabloları bulunamadı. Dönem şeması erişimini kontrol ediniz.">
</cfif>
<cfset credit_payment_cutoff = dateAdd('d', 1, createDate(year(now()), month(now()), day(now())))>
<cfquery name="get_credit_overview" datasource="#dsn3#">
    WITH PAYMENT_SOURCE AS (

        <cfloop query="credit_payment_schemas">
            <cfif credit_payment_schemas.currentRow gt 1>UNION ALL</cfif>
            SELECT P.CREDIT_CONTRACT_ROW_ID, P.CREDIT_CONTRACT_ID,
                   ISNULL(P.CAPITAL_PRICE,0) AS PAID_CAPITAL,
                   ISNULL(P.INTEREST_PRICE,0) AS PAID_INTEREST,
                   ISNULL(P.TAX_PRICE,0) AS PAID_TAX,
                   ISNULL(P.DELAY_PRICE,0) AS PAID_DELAY,
                   ISNULL(P.TOTAL_PRICE,0) AS PAID_TOTAL
            FROM [#replace(credit_payment_schemas.TABLE_SCHEMA,']',']]' ,'all')#].CREDIT_CONTRACT_PAYMENT_INCOME P
            WHERE P.PROCESS_TYPE IN (120,291)
              AND P.PROCESS_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_payment_cutoff#">
              AND EXISTS (
                  SELECT 1 FROM CREDIT_CONTRACT_ROW R
                  INNER JOIN CREDIT_CONTRACT C0 ON C0.CREDIT_CONTRACT_ID = R.CREDIT_CONTRACT_ID
                  WHERE R.CREDIT_CONTRACT_ROW_ID = P.CREDIT_CONTRACT_ROW_ID
                    AND R.CREDIT_CONTRACT_ID = P.CREDIT_CONTRACT_ID
                    AND R.CREDIT_CONTRACT_TYPE = 1 AND R.IS_PAID = 0
                    <cfif len(attributes.company_id)>
                        AND C0.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                    </cfif>
                    <cfif len(attributes.credit_type_id)>
                        AND C0.CREDIT_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.credit_type_id#">
                    </cfif>
                    <cfif len(attributes.money_type)>
                        AND C0.MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.money_type#">
                    </cfif>
              )
        </cfloop>
    ), PAYMENTS AS (
        SELECT CREDIT_CONTRACT_ROW_ID, CREDIT_CONTRACT_ID,
               SUM(PAID_CAPITAL) AS PAID_CAPITAL, SUM(PAID_INTEREST) AS PAID_INTEREST,
               SUM(PAID_TAX) AS PAID_TAX, SUM(PAID_TOTAL) AS PAID_TOTAL, COUNT(*) AS PAYMENT_COUNT
        FROM PAYMENT_SOURCE GROUP BY CREDIT_CONTRACT_ROW_ID, CREDIT_CONTRACT_ID
    ), PLAN_ROWS AS (
        SELECT R.CREDIT_CONTRACT_ID,
               ISNULL(R.CAPITAL_PRICE,0) AS CAPITAL, ISNULL(R.TOTAL_PRICE,0) AS PLANNED,
               ISNULL(P.PAID_TOTAL,0) AS PAID_TOTAL,
               ISNULL(P.PAYMENT_COUNT,0) AS PAYMENT_COUNT,
               CAST(ISNULL(R.CAPITAL_PRICE,0)-ISNULL(P.PAID_CAPITAL,0) AS decimal(24,2)) AS CAPITAL_REMAINING,
               CAST(ISNULL(R.INTEREST_PRICE,0)-ISNULL(P.PAID_INTEREST,0) AS decimal(24,2)) AS INTEREST_REMAINING,
               CAST(ISNULL(R.TAX_PRICE,0)-ISNULL(P.PAID_TAX,0) AS decimal(24,2)) AS TAX_REMAINING,
               CAST(ISNULL(R.CAPITAL_PRICE,0)+ISNULL(R.INTEREST_PRICE,0)+ISNULL(R.TAX_PRICE,0)
                 -ISNULL(P.PAID_CAPITAL,0)-ISNULL(P.PAID_INTEREST,0)-ISNULL(P.PAID_TAX,0) AS decimal(24,2)) AS REMAINING
        FROM CREDIT_CONTRACT_ROW R
        LEFT JOIN PAYMENTS P ON P.CREDIT_CONTRACT_ROW_ID=R.CREDIT_CONTRACT_ROW_ID
                            AND P.CREDIT_CONTRACT_ID=R.CREDIT_CONTRACT_ID
        WHERE R.CREDIT_CONTRACT_TYPE=1 AND R.IS_PAID=0
    ), PLAN_TOTALS AS (
        SELECT CREDIT_CONTRACT_ID, COUNT(*) AS TAKSIT_SAYISI,
               SUM(CASE WHEN PAYMENT_COUNT>0 AND ROUND(REMAINING,2)<=0 THEN 1 ELSE 0 END) AS ODENEN_ADET,
               SUM(CASE WHEN PAYMENT_COUNT>0 AND ROUND(REMAINING,2)>0 THEN 1 ELSE 0 END) AS KISMI_ADET,
               SUM(CASE WHEN PAYMENT_COUNT=0 OR ROUND(REMAINING,2)>0 THEN 1 ELSE 0 END) AS KALAN_ADET,
               SUM(PLANNED) AS PLAN_TOPLAMI, SUM(PAID_TOTAL) AS ODENEN_TOPLAM,
               SUM(CASE WHEN CAPITAL_REMAINING>0 THEN CAPITAL_REMAINING ELSE 0 END) AS KALAN_ANAPARA,
               SUM(CASE WHEN INTEREST_REMAINING>0 THEN INTEREST_REMAINING ELSE 0 END) AS KALAN_FAIZ,
               SUM(CASE WHEN TAX_REMAINING>0 THEN TAX_REMAINING ELSE 0 END) AS KALAN_MASRAF,
               SUM(CASE WHEN REMAINING>0 THEN REMAINING ELSE 0 END) AS KALAN_ODEME
        FROM PLAN_ROWS GROUP BY CREDIT_CONTRACT_ID
    ), LEGACY_REPAYMENTS AS (
        -- Plansiz eski krediler: gerceklesen geri odeme satirlari bir kez toplanir.
        SELECT CREDIT_CONTRACT_ID, COUNT(*) AS PAYMENT_COUNT,
               SUM(ISNULL(CAPITAL_PRICE,0)) AS PAID_CAPITAL
        FROM CREDIT_CONTRACT_ROW
        WHERE CREDIT_CONTRACT_TYPE=1 AND IS_PAID=1 AND PROCESS_TYPE=291
          AND PROCESS_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_payment_cutoff#">
        GROUP BY CREDIT_CONTRACT_ID
    )
    SELECT C.CREDIT_CONTRACT_ID, C.CREDIT_NO, ISNULL(C.DETAIL,'') AS KREDI_ACIKLAMASI, C.CREDIT_DATE AS KULLANIM_TARIHI,
           CO.FULLNAME AS KURUM,
           ISNULL(T.CREDIT_TYPE,'Tür belirtilmemiş') AS KREDI_TURU,
           C.MONEY_TYPE AS DOVIZ, CAST(ISNULL(C.TOTAL_REVENUE,0) AS decimal(24,2)) AS KREDI_TUTARI,
           ISNULL(A.TAKSIT_SAYISI,0) AS TAKSIT_SAYISI,
           A.ODENEN_ADET AS ODENEN_ADET,
           A.KISMI_ADET AS KISMI_ADET,
           A.KALAN_ADET AS KALAN_ADET,
           CAST(A.PLAN_TOPLAMI AS decimal(24,2)) AS PLAN_TOPLAMI,
           CAST(A.ODENEN_TOPLAM AS decimal(24,2)) AS ODENEN_TOPLAM,
           CAST(A.KALAN_ANAPARA AS decimal(24,2)) AS KALAN_ANAPARA,
           CAST(A.KALAN_FAIZ AS decimal(24,2)) AS KALAN_FAIZ,
           CAST(A.KALAN_MASRAF AS decimal(24,2)) AS KALAN_MASRAF,
           CAST(A.KALAN_ANAPARA+A.KALAN_FAIZ AS decimal(24,2)) AS KALAN_ANAPARA_FAIZ,
           CAST(A.KALAN_ODEME AS decimal(24,2)) AS KALAN_ODEME,
           CASE WHEN C.MONEY_TYPE='TL' THEN 1.0 ELSE FX.RATE END AS GUNCEL_KUR,

           GFX.KALAN_TL AS KALAN_TL,
           CASE WHEN A.CREDIT_CONTRACT_ID IS NULL
                     AND C.TOTAL_REVENUE>0 AND L.PAYMENT_COUNT>0
                     AND ROUND(C.TOTAL_REVENUE-L.PAID_CAPITAL,2)<=0
                THEN 'Anapara ödenmiş; ödeme planı yok, kapanış doğrulanamadı'
                WHEN A.CREDIT_CONTRACT_ID IS NULL THEN 'Ödeme planı yok; kalan borç hesaplanamadı'
                ELSE '' END AS KONTROL,
           CASE WHEN A.CREDIT_CONTRACT_ID IS NULL THEN 1 ELSE 0 END AS PLAN_EKSIK
    FROM CREDIT_CONTRACT C
    LEFT JOIN PLAN_TOTALS A ON A.CREDIT_CONTRACT_ID=C.CREDIT_CONTRACT_ID
    LEFT JOIN LEGACY_REPAYMENTS L ON L.CREDIT_CONTRACT_ID=C.CREDIT_CONTRACT_ID
    LEFT JOIN #dsn#.COMPANY CO ON CO.COMPANY_ID=C.COMPANY_ID
    LEFT JOIN #dsn#.SETUP_CREDIT_TYPE T ON T.CREDIT_TYPE_ID=C.CREDIT_TYPE
    OUTER APPLY (
        SELECT TOP (1) M.RATE2 / NULLIF(M.RATE1,0) AS RATE
        FROM #dsn#.SETUP_MONEY M
        WHERE M.PERIOD_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
          AND M.MONEY=C.MONEY_TYPE AND M.MONEY_STATUS=1
          AND M.RATE1>0 AND M.RATE2>0
        ORDER BY COALESCE(M.UPDATE_DATE,M.RECORD_DATE) DESC, M.MONEY_ID DESC
    ) FX
    -- TL toplami, aylik/yillik dagilimla ayni sekilde taksit bazinda kurusa yuvarlanir.
    OUTER APPLY (
        SELECT SUM(FX_ROWS.TAKSIT_KALAN_TL) AS KALAN_TL
        FROM (
            SELECT CAST(
                (CASE WHEN PR.REMAINING>0 THEN PR.REMAINING ELSE 0 END)
                *(CASE WHEN C.MONEY_TYPE='TL' THEN 1.0 ELSE FX.RATE END)
                AS decimal(24,2)) AS TAKSIT_KALAN_TL
            FROM PLAN_ROWS PR
            WHERE PR.CREDIT_CONTRACT_ID=C.CREDIT_CONTRACT_ID
        ) FX_ROWS
    ) GFX
    WHERE 1=1
    <cfif attributes.credit_active_status neq "all">
        AND C.IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.credit_active_status#">
    </cfif>
    <cfif attributes.hide_completed eq 1>
        AND (A.CREDIT_CONTRACT_ID IS NULL OR A.KALAN_ADET > 0)
    </cfif>
    <cfif len(attributes.company_id)>
        AND C.COMPANY_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
    </cfif>
    <cfif len(attributes.credit_type_id)>
        AND C.CREDIT_TYPE=<cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.credit_type_id#">
    </cfif>
    <cfif len(attributes.money_type)>
        AND C.MONEY_TYPE=<cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.money_type#">
    </cfif>
    ORDER BY DOVIZ, KURUM, C.CREDIT_NO, C.CREDIT_CONTRACT_ID
</cfquery>

<cfquery name="get_credit_schedule_rows" datasource="#dsn3#">
    WITH PAYMENT_SOURCE AS (
        <cfloop query="credit_payment_schemas">
            <cfif credit_payment_schemas.currentRow gt 1>UNION ALL</cfif>
            SELECT P.CREDIT_CONTRACT_ROW_ID, P.CREDIT_CONTRACT_ID,
                   ISNULL(P.CAPITAL_PRICE,0) AS PAID_CAPITAL,
                   ISNULL(P.INTEREST_PRICE,0) AS PAID_INTEREST,
                   ISNULL(P.TAX_PRICE,0) AS PAID_TAX,
                   ISNULL(P.DELAY_PRICE,0) AS PAID_DELAY,
                   ISNULL(P.TOTAL_PRICE,0) AS PAID_TOTAL
            FROM [#replace(credit_payment_schemas.TABLE_SCHEMA,']',']]' ,'all')#].CREDIT_CONTRACT_PAYMENT_INCOME P
            WHERE P.PROCESS_TYPE IN (120,291)
              AND P.PROCESS_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_payment_cutoff#">
              AND EXISTS (
                  SELECT 1 FROM CREDIT_CONTRACT_ROW R
                  INNER JOIN CREDIT_CONTRACT C0 ON C0.CREDIT_CONTRACT_ID = R.CREDIT_CONTRACT_ID
                  WHERE R.CREDIT_CONTRACT_ROW_ID = P.CREDIT_CONTRACT_ROW_ID
                    AND R.CREDIT_CONTRACT_ID = P.CREDIT_CONTRACT_ID
                    AND R.CREDIT_CONTRACT_TYPE = 1 AND R.IS_PAID = 0


                    <cfif len(attributes.company_id)>
                        AND C0.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
                    </cfif>
                    <cfif len(attributes.credit_type_id)>
                        AND C0.CREDIT_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.credit_type_id#">
                    </cfif>
                    <cfif len(attributes.money_type)>
                        AND C0.MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.money_type#">
                    </cfif>
              )
        </cfloop>
    ), PAYMENTS AS (
        SELECT CREDIT_CONTRACT_ROW_ID, CREDIT_CONTRACT_ID,
               SUM(PAID_CAPITAL) AS PAID_CAPITAL, SUM(PAID_INTEREST) AS PAID_INTEREST,
               SUM(PAID_TAX) AS PAID_TAX, SUM(PAID_DELAY) AS PAID_DELAY,
               SUM(PAID_TOTAL) AS PAID_TOTAL, COUNT(*) AS PAYMENT_COUNT
        FROM PAYMENT_SOURCE
        GROUP BY CREDIT_CONTRACT_ROW_ID, CREDIT_CONTRACT_ID
    ), BASE AS (
        SELECT R.CREDIT_CONTRACT_ROW_ID, C.CREDIT_CONTRACT_ID,
               C.CREDIT_DATE AS KULLANIM_TARIHI, R.PROCESS_DATE AS VADE, DAY(R.PROCESS_DATE) AS VADE_GUN,
               CONVERT(varchar(10),R.PROCESS_DATE,104) AS VADE_LABEL,
               CONVERT(varchar(10),R.PROCESS_DATE,120) AS VADE_SIRA,
               YEAR(R.PROCESS_DATE) AS VADE_YIL,
               CONVERT(varchar(7),R.PROCESS_DATE,120) AS VADE_AY,
               CO.FULLNAME AS KURUM,
               C.CREDIT_NO, ISNULL(C.DETAIL,'') AS KREDI_ACIKLAMASI, ISNULL(T.CREDIT_TYPE,'Tür belirtilmemiş') AS KREDI_TURU,
               C.MONEY_TYPE AS DOVIZ, ISNULL(R.DETAIL,'') AS ACIKLAMA,
               CASE WHEN C.MONEY_TYPE='TL' THEN 1.0 ELSE FX.RATE END AS GUNCEL_KUR,

               CAST(ISNULL(R.CAPITAL_PRICE,0) AS decimal(24,2)) AS ANAPARA,
               CAST(ISNULL(R.INTEREST_PRICE,0) AS decimal(24,2)) AS FAIZ,
               CAST(ISNULL(R.TAX_PRICE,0) AS decimal(24,2)) AS MASRAF,
               CAST(ISNULL(R.TOTAL_PRICE,0) AS decimal(24,2)) AS PLANLANAN,
               CAST(ISNULL(P.PAID_TOTAL,0) AS decimal(24,2)) AS ODENEN,
               CAST(ISNULL(P.PAID_DELAY,0) AS decimal(24,2)) AS GECIKME,
               ISNULL(P.PAYMENT_COUNT,0) AS PAYMENT_COUNT,
               ISNULL(R.IS_PAID_ROW,0) AS PLAN_PAYMENT_MARK,
               CAST(ISNULL(R.CAPITAL_PRICE,0)+ISNULL(R.INTEREST_PRICE,0)+ISNULL(R.TAX_PRICE,0)
                    -ISNULL(P.PAID_CAPITAL,0)-ISNULL(P.PAID_INTEREST,0)-ISNULL(P.PAID_TAX,0)
                    AS decimal(24,2)) AS RAW_REMAINING
        FROM CREDIT_CONTRACT_ROW R
        INNER JOIN CREDIT_CONTRACT C ON C.CREDIT_CONTRACT_ID = R.CREDIT_CONTRACT_ID
        LEFT JOIN #dsn#.COMPANY CO ON CO.COMPANY_ID = C.COMPANY_ID
        LEFT JOIN #dsn#.SETUP_CREDIT_TYPE T ON T.CREDIT_TYPE_ID = C.CREDIT_TYPE
        LEFT JOIN PAYMENTS P ON P.CREDIT_CONTRACT_ROW_ID = R.CREDIT_CONTRACT_ROW_ID
                            AND P.CREDIT_CONTRACT_ID = R.CREDIT_CONTRACT_ID
        OUTER APPLY (
        SELECT TOP (1) M.RATE2 / NULLIF(M.RATE1,0) AS RATE
        FROM #dsn#.SETUP_MONEY M
        WHERE M.PERIOD_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.period_id#">
          AND M.MONEY=C.MONEY_TYPE AND M.MONEY_STATUS=1
          AND M.RATE1>0 AND M.RATE2>0
        ORDER BY COALESCE(M.UPDATE_DATE,M.RECORD_DATE) DESC, M.MONEY_ID DESC
        ) FX
        WHERE R.CREDIT_CONTRACT_TYPE = 1 AND R.IS_PAID = 0
    <cfif attributes.credit_active_status neq "all">
        AND C.IS_ACTIVE = <cfqueryparam cfsqltype="cf_sql_bit" value="#attributes.credit_active_status#">
    </cfif>
          <cfif attributes.hide_completed eq 1>
              <!--- Ay filtresinden bagimsiz, kredinin tum taksitleri kontrol edilir. --->
              AND EXISTS (
                  SELECT 1
                  FROM CREDIT_CONTRACT_ROW RO
                  LEFT JOIN PAYMENTS PO ON PO.CREDIT_CONTRACT_ROW_ID=RO.CREDIT_CONTRACT_ROW_ID
                                       AND PO.CREDIT_CONTRACT_ID=RO.CREDIT_CONTRACT_ID
                  WHERE RO.CREDIT_CONTRACT_ID=C.CREDIT_CONTRACT_ID
                    AND RO.CREDIT_CONTRACT_TYPE=1 AND RO.IS_PAID=0
                    AND (
                        ISNULL(PO.PAYMENT_COUNT,0)=0
                        OR ROUND(
                            ISNULL(RO.CAPITAL_PRICE,0)+ISNULL(RO.INTEREST_PRICE,0)+ISNULL(RO.TAX_PRICE,0)
                            -ISNULL(PO.PAID_CAPITAL,0)-ISNULL(PO.PAID_INTEREST,0)-ISNULL(PO.PAID_TAX,0)
                        ,2)>0
                    )
              )
          </cfif>


          <cfif len(attributes.company_id)>
              AND C.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.company_id#">
          </cfif>
          <cfif len(attributes.credit_type_id)>
              AND C.CREDIT_TYPE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.credit_type_id#">
          </cfif>
          <cfif len(attributes.money_type)>
              AND C.MONEY_TYPE = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes.money_type#">
          </cfif>
    )
    SELECT *, CASE WHEN GUNCEL_KUR IS NULL THEN 1 ELSE 0 END AS FX_EKSIK, CAST(PLANLANAN*GUNCEL_KUR AS decimal(24,2)) AS PLANLANAN_TL,
           CAST(ODENEN*GUNCEL_KUR AS decimal(24,2)) AS ODENEN_TL,
           CAST((CASE WHEN RAW_REMAINING>0 THEN RAW_REMAINING ELSE 0 END)*GUNCEL_KUR AS decimal(24,2)) AS KALAN_TL,
           CAST(CASE WHEN RAW_REMAINING > 0 THEN RAW_REMAINING ELSE 0 END AS decimal(24,2)) AS KALAN,
           CASE WHEN PAYMENT_COUNT = 0 AND PLAN_PAYMENT_MARK = 1 THEN 'Ödeme kaydı kontrol edilmeli'
                WHEN PAYMENT_COUNT = 0 THEN 'Ödenmedi'
                WHEN RAW_REMAINING > 0 THEN 'Kısmi ödeme / tutar farkı'
                ELSE 'Ödendi' END AS DURUM,
           CAST(CASE WHEN RAW_REMAINING < 0 THEN -RAW_REMAINING ELSE 0 END AS decimal(24,2)) AS FAZLA_ODEME
    FROM BASE
    ORDER BY DOVIZ, VADE, KURUM, CREDIT_NO, CREDIT_CONTRACT_ROW_ID
</cfquery>
<!--- Tum vadeler tek seferde okunur; mevcut aylik bolum yine secilen aya sinirlanir. --->
<cfquery name="get_monthly_credit_rows" dbtype="query">
    SELECT * FROM get_credit_schedule_rows
    WHERE VADE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_filter_start#">
      AND VADE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_filter_end_exclusive#">
    ORDER BY DOVIZ, VADE, KURUM, CREDIT_NO, CREDIT_CONTRACT_ROW_ID
</cfquery>
<cfquery name="credit_distribution_currencies" dbtype="query">
    SELECT DISTINCT DOVIZ FROM get_credit_schedule_rows WHERE KALAN>0 ORDER BY DOVIZ
</cfquery>
<cfquery name="credit_distribution_month_tl" dbtype="query">
    SELECT VADE_AY AS DONEM, SUM(KALAN_TL) AS TUTAR_TL, SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_credit_schedule_rows WHERE KALAN>0
    GROUP BY VADE_AY ORDER BY VADE_AY
</cfquery>
<cfset credit_month_display_labels = arrayNew(1)>
<cfloop query="credit_distribution_month_tl">
    <cfset credit_month_key = credit_distribution_month_tl.DONEM>
    <cfset arrayAppend(credit_month_display_labels, listGetAt(credit_month_names,val(right(credit_month_key,2))) & " " & left(credit_month_key,4))>
</cfloop>
<cfset queryAddColumn(credit_distribution_month_tl,"DONEM_ETIKET","varchar",credit_month_display_labels)>

<cfquery name="credit_distribution_year_tl" dbtype="query">
    SELECT VADE_YIL AS DONEM, SUM(KALAN_TL) AS TUTAR_TL, SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_credit_schedule_rows WHERE KALAN>0
    GROUP BY VADE_YIL ORDER BY VADE_YIL
</cfquery>
<cfset credit_distribution_missing = 0>
<cfloop query="credit_distribution_month_tl">
    <cfset credit_distribution_missing += credit_distribution_month_tl.KUR_EKSIK>
</cfloop>

<cfquery name="credit_currency_summary" dbtype="query">
    SELECT DOVIZ, COUNT(*) AS TAKSIT_ADEDI,
           SUM(PLANLANAN) AS PLANLANAN, SUM(ODENEN) AS ODENEN,
           SUM(KALAN) AS KALAN, SUM(GECIKME) AS GECIKME,
           SUM(FAZLA_ODEME) AS FAZLA_ODEME, SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_monthly_credit_rows
    GROUP BY DOVIZ ORDER BY DOVIZ
</cfquery>

<cfquery name="credit_overview_currencies" dbtype="query">
    SELECT DOVIZ, COUNT(*) AS KREDI_ADEDI, SUM(TAKSIT_SAYISI) AS TAKSIT_SAYISI,
           SUM(ODENEN_ADET) AS ODENEN_ADET, SUM(KISMI_ADET) AS KISMI_ADET,
           SUM(KALAN_ADET) AS KALAN_ADET, SUM(KALAN_ANAPARA) AS KALAN_ANAPARA,
           SUM(KALAN_ODEME) AS KALAN_ODEME, SUM(PLAN_EKSIK) AS PLAN_EKSIK
    FROM get_credit_overview GROUP BY DOVIZ ORDER BY DOVIZ
</cfquery>
<cfset credit_tl = {generalRemaining=0, generalMissing=0, generalPlanMissing=0, monthlyPlanned=0, monthlyPaid=0, monthlyRemaining=0, monthlyMissing=0}>
<cfloop query="get_credit_overview">
    <cfif get_credit_overview.PLAN_EKSIK eq 1><cfset credit_tl.generalPlanMissing++></cfif>
    <cfif isNumeric(get_credit_overview.KALAN_TL)>
        <cfset credit_tl.generalRemaining += get_credit_overview.KALAN_TL>
    <cfelseif get_credit_overview.KALAN_ODEME gt 0>
        <cfset credit_tl.generalMissing++>
    </cfif>
</cfloop>
<cfloop query="get_monthly_credit_rows">
    <cfif isNumeric(get_monthly_credit_rows.GUNCEL_KUR)>
        <cfset credit_tl.monthlyPlanned += get_monthly_credit_rows.PLANLANAN_TL>
        <cfset credit_tl.monthlyPaid += get_monthly_credit_rows.ODENEN_TL>
        <cfset credit_tl.monthlyRemaining += get_monthly_credit_rows.KALAN_TL>
    <cfelse>
        <cfset credit_tl.monthlyMissing++>
    </cfif>
</cfloop>
<cfif attributes.executive_summary eq 1>
<!--- Yonetici ozeti ayni sorgulardan beslenir; ek veritabani sorgusu yapilmaz. --->
<cfquery name="credit_exec_fx" dbtype="query">
    SELECT DOVIZ, SUM(PLANLANAN) AS PLANLANAN, SUM(ODENEN) AS ODENEN, SUM(KALAN) AS KALAN,
           SUM(PLANLANAN_TL) AS PLANLANAN_TL, SUM(ODENEN_TL) AS ODENEN_TL, SUM(KALAN_TL) AS KALAN_TL,
           SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_monthly_credit_rows GROUP BY DOVIZ ORDER BY DOVIZ
</cfquery>
<cfquery name="credit_exec_bank" dbtype="query">
    SELECT KURUM, SUM(PLANLANAN_TL) AS PLANLANAN_TL, SUM(ODENEN_TL) AS ODENEN_TL,
           SUM(KALAN_TL) AS KALAN_TL, SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_monthly_credit_rows GROUP BY KURUM ORDER BY KALAN_TL DESC, KURUM
</cfquery>
<cfquery name="credit_exec_past" dbtype="query">
    SELECT DOVIZ, SUM(KALAN) AS KALAN, SUM(KALAN_TL) AS KALAN_TL, SUM(FX_EKSIK) AS KUR_EKSIK
    FROM get_credit_schedule_rows
    WHERE VADE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#credit_filter_start#"> AND KALAN > 0
    GROUP BY DOVIZ ORDER BY DOVIZ
</cfquery>
<cfquery name="credit_exec_year_currency" dbtype="query">
    SELECT VADE_YIL, DOVIZ, SUM(KALAN) AS KALAN
    FROM get_credit_schedule_rows WHERE KALAN > 0 GROUP BY VADE_YIL, DOVIZ ORDER BY VADE_YIL, DOVIZ
</cfquery>
<cfquery name="credit_exec_loans" dbtype="query">
    SELECT * FROM get_credit_overview ORDER BY KREDI_TURU, KURUM, DOVIZ, CREDIT_NO, CREDIT_CONTRACT_ID
</cfquery>
<cfscript>
// Dönem ölçüleri kredi ID'siyle birleştirilir. Taksit ve ödeme satırları tekrar toplanmaz.
creditExecPeriod={}; creditExecYears={}; creditExecPast=0; creditExecPastMissing=0;
creditExecOverallCapital=0; creditExecOverallAF=0;
creditExecGroups=[]; creditExecGroupIndex={};
for(ce=1;ce<=get_monthly_credit_rows.recordCount;ce++) {
    cek=toString(get_monthly_credit_rows.CREDIT_CONTRACT_ID[ce]);
    if(!structKeyExists(creditExecPeriod,cek)) creditExecPeriod[cek]={planned=0,paid=0,remaining=0};
    creditExecPeriod[cek].planned+=val(get_monthly_credit_rows.PLANLANAN[ce]);
    creditExecPeriod[cek].paid+=val(get_monthly_credit_rows.ODENEN[ce]);
    creditExecPeriod[cek].remaining+=val(get_monthly_credit_rows.KALAN[ce]);
}
for(ce=1;ce<=credit_exec_past.recordCount;ce++) {
    creditExecPast+=val(credit_exec_past.KALAN_TL[ce]);
    creditExecPastMissing+=val(credit_exec_past.KUR_EKSIK[ce]);
}
for(ce=1;ce<=credit_exec_year_currency.recordCount;ce++) {
    cek=toString(credit_exec_year_currency.VADE_YIL[ce]);
    if(!structKeyExists(creditExecYears,cek)) creditExecYears[cek]={};
    creditExecYears[cek][credit_exec_year_currency.DOVIZ[ce]]=val(credit_exec_year_currency.KALAN[ce]);
}
for(ce=1;ce<=credit_exec_loans.recordCount;ce++) {
    // Gruplama yalnızca kayıtlı kredi türüdür; açıklamadan kredi türü türetilmez.
    cet=credit_exec_loans.KREDI_TURU[ce];
    if(!structKeyExists(creditExecGroupIndex,cet)) {
        arrayAppend(creditExecGroups,{title=cet,rows=[],currencies={},currencyOrder=[],banks=[],bankIndex={},capitalTL=0,afTL=0,remainingTL=0,missing=0});
        creditExecGroupIndex[cet]=arrayLen(creditExecGroups);
    }
    ceg=creditExecGroupIndex[cet];
    arrayAppend(creditExecGroups[ceg].rows,ce);
    ced=credit_exec_loans.DOVIZ[ce];
    if(!structKeyExists(creditExecGroups[ceg].currencies,ced)) {
        creditExecGroups[ceg].currencies[ced]={planned=0,capital=0,af=0,remaining=0,missing=0};
        arrayAppend(creditExecGroups[ceg].currencyOrder,ced);
    }
    cek=toString(credit_exec_loans.CREDIT_CONTRACT_ID[ce]);
    cep={planned=0,paid=0,remaining=0};
    if(structKeyExists(creditExecPeriod,cek)) cep=creditExecPeriod[cek];
    creditExecGroups[ceg].currencies[ced].planned+=cep.planned;
    // Banka ara toplamları döviz bazındadır; farklı dövizler birbirine eklenmez.
    ceb=toString(credit_exec_loans.KURUM[ce]) & chr(31) & ced;
    if(!structKeyExists(creditExecGroups[ceg].bankIndex,ceb)) {
        arrayAppend(creditExecGroups[ceg].banks,{institution=credit_exec_loans.KURUM[ce],currency=ced,planned=0,capital=0,af=0,remaining=0,missing=0});
        creditExecGroups[ceg].bankIndex[ceb]=arrayLen(creditExecGroups[ceg].banks);
    }
    cebi=creditExecGroups[ceg].bankIndex[ceb];
    creditExecGroups[ceg].banks[cebi].planned+=cep.planned;
    if(credit_exec_loans.PLAN_EKSIK[ce]==0) {
        creditExecGroups[ceg].currencies[ced].capital+=val(credit_exec_loans.KALAN_ANAPARA[ce]);
        creditExecGroups[ceg].currencies[ced].af+=val(credit_exec_loans.KALAN_ANAPARA_FAIZ[ce]);
        creditExecGroups[ceg].currencies[ced].remaining+=val(credit_exec_loans.KALAN_ODEME[ce]);
        creditExecGroups[ceg].banks[cebi].capital+=val(credit_exec_loans.KALAN_ANAPARA[ce]);
        creditExecGroups[ceg].banks[cebi].af+=val(credit_exec_loans.KALAN_ANAPARA_FAIZ[ce]);
        creditExecGroups[ceg].banks[cebi].remaining+=val(credit_exec_loans.KALAN_ODEME[ce]);
    } else {
        creditExecGroups[ceg].currencies[ced].missing++;
        creditExecGroups[ceg].banks[cebi].missing++;
    }
    if(credit_exec_loans.PLAN_EKSIK[ce]==0 && isNumeric(credit_exec_loans.GUNCEL_KUR[ce])) {
        creditExecGroups[ceg].capitalTL+=round(val(credit_exec_loans.KALAN_ANAPARA[ce])*credit_exec_loans.GUNCEL_KUR[ce]*100)/100;
        creditExecGroups[ceg].afTL+=round(val(credit_exec_loans.KALAN_ANAPARA_FAIZ[ce])*credit_exec_loans.GUNCEL_KUR[ce]*100)/100;
        creditExecGroups[ceg].remainingTL+=val(credit_exec_loans.KALAN_TL[ce]);
        creditExecOverallCapital+=round(val(credit_exec_loans.KALAN_ANAPARA[ce])*credit_exec_loans.GUNCEL_KUR[ce]*100)/100;
        creditExecOverallAF+=round(val(credit_exec_loans.KALAN_ANAPARA_FAIZ[ce])*credit_exec_loans.GUNCEL_KUR[ce]*100)/100;
    } else creditExecGroups[ceg].missing++;
}
creditExecGraphLabels=[];
for(ce=1;ce<=credit_exec_fx.recordCount;ce++) {
    arrayAppend(creditExecGraphLabels,credit_exec_fx.DOVIZ[ce] & chr(10) & TLFormat(val(credit_exec_fx.PLANLANAN[ce]),2));
}
queryAddColumn(credit_exec_fx,"GRAFIK_ETIKET","varchar",creditExecGraphLabels);
</cfscript>
<style id="creditExecutiveStyle">
#creditExecutive{--ink:#172943;--muted:#64748b;--line:#e2e8f0;--blue:#2463eb;color:var(--ink);font-family:Arial,sans-serif;width:100%;max-width:none;margin:0;padding:0}
#creditExecutive *{box-sizing:border-box}#creditExecutive .ce-header{display:flex;justify-content:space-between;gap:18px;align-items:flex-end;margin:26px 0 18px}
#creditExecutive h1{font-size:27px;margin:0 0 8px;font-weight:700}#creditExecutive h2{font-size:18px;margin:0 0 8px}#creditExecutive h3{font-size:15px;margin:20px 0 12px}
#creditExecutive .ce-eyebrow{color:var(--blue);font-size:11px;font-weight:700;letter-spacing:1.6px;margin-bottom:8px}#creditExecutive .ce-muted{color:var(--muted);font-size:12px;line-height:1.6}
#creditExecutive .ce-kpis{display:grid!important;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px;width:100%;float:none;clear:both;margin:0;padding:0;align-items:stretch}
/* Workcube clearfix pseudo-elements must not occupy grid cells. */
#creditExecutive .ce-kpis::before,#creditExecutive .ce-kpis::after,#creditExecutive .ce-grid::before,#creditExecutive .ce-grid::after{content:none!important;display:none!important}
#creditExecutive .ce-kpis>.ce-kpi{float:none!important;clear:none!important;width:auto!important;min-width:0;margin:0!important;display:flex;flex-direction:column;justify-content:center}
#creditExecutive .ce-kpi{padding:22px;background:#fff;border:1px solid var(--line);border-radius:14px;min-height:140px}
#creditExecutive .ce-kpi.ce-primary{background:#172f56;color:white;border-color:#172f56}#creditExecutive .ce-kpi-label{font-size:13px;margin-bottom:12px}#creditExecutive .ce-number{font-size:29px;line-height:1.2;font-weight:700;letter-spacing:-.6px;font-variant-numeric:tabular-nums}
#creditExecutive .ce-unit{font-size:13px;font-weight:400;margin-left:5px}#creditExecutive .ce-kpi small{display:block;margin-top:10px;font-size:11px;line-height:1.5;opacity:.85}
#creditExecutive .ce-panel{padding:22px;border:1px solid var(--line);border-radius:14px;background:#fff;margin-top:18px;min-width:0}
#creditExecutive .ce-grid{display:grid!important;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;width:100%;float:none;clear:both;margin-top:18px;padding:0;align-items:start}
#creditExecutive .ce-grid>.ce-panel{float:none!important;clear:none!important;width:auto!important;min-width:0;margin:0!important;align-self:stretch}
#creditExecutive .ce-ada-table,#creditExecutive .ce-scroll{min-width:0;max-width:100%}
#creditExecutive .ce-header::before,#creditExecutive .ce-header::after,#creditExecutive .ce-balance::before,#creditExecutive .ce-balance::after{content:none!important;display:none!important}
#creditExecutive .ce-scroll{overflow-x:auto}
#creditExecutive .ce-num{text-align:right;white-space:nowrap;font-variant-numeric:tabular-nums}#creditExecutive .ce-total td{font-weight:700;background:#eef4fd;border-top:1px solid #cbd9ef}#creditExecutive .ce-subtotal td{background:#f8fafc;font-weight:600}
#creditExecutive .ce-alert{padding:14px 18px;border-left:4px solid #d08b24;background:#fff7e8;border-radius:7px;margin-top:16px;font-size:12px;line-height:1.7}#creditExecutive .ce-note{font-size:11px;color:var(--muted);line-height:1.6;margin-top:12px}
#creditExecutive .ce-balance{display:flex;gap:30px;justify-content:space-between;flex-wrap:wrap;margin:16px 0}#creditExecutive .ce-balance strong{display:block;font-size:23px;margin-top:7px}#creditExecutive .ce-description{min-width:210px;max-width:330px;line-height:1.5}#creditExecutive .ce-bank-title td{background:#e8eef7;font-weight:700}#creditExecutive .ce-graph{width:100%;min-height:330px}
@media(max-width:1100px){#creditExecutive .ce-grid{grid-template-columns:minmax(0,1fr)}#creditExecutive .ce-number{font-size:clamp(18px,2.4vw,25px)}#creditExecutive .ce-kpis{gap:12px}}
@media(max-width:650px){#creditExecutive .ce-kpis{grid-template-columns:1fr}#creditExecutive .ce-header{display:block}#creditExecutive .ce-panel{padding:15px}#creditExecutive h1{font-size:22px}}
@media print{#creditExecutive{max-width:none;margin:0}#creditExecutive .ce-kpis{grid-template-columns:1.3fr 1fr 1fr}#creditExecutive .ce-grid{grid-template-columns:1fr 1fr}#creditExecutive .ce-panel{border-radius:0;padding:12px;break-inside:auto}#creditExecutive .ce-graph{min-height:0;break-inside:avoid}#creditExecutive .ce-graph img{width:100%}#creditExecutive .ce-kpi{padding:14px;break-inside:avoid}#creditExecutive .ce-number{font-size:22px}#creditExecutive .ce-scroll{overflow:visible}#creditExecutive table{font-size:9px}#creditExecutive .ce-loan-table{font-size:8px}#creditExecutive th,#creditExecutive td{padding:6px 4px}#creditExecutive .ce-description{min-width:130px}#creditExecutive thead{display:table-header-group}#creditExecutive tr{break-inside:avoid}#creditExecutive h2,#creditExecutive h3{break-after:avoid}#creditExecutive .ce-long-section{break-before:page}.ce-print-button{display:none}}
/* Ekran düzeninden bağımsız, tek sütunlu baskı akışı. */
@media print {
    #creditExecutive .ce-grid{display:block!important;width:100%;margin:12px 0 0}
    #creditExecutive .ce-grid>.ce-panel{display:block!important;width:100%!important;margin:0 0 14px!important;min-height:0;break-inside:auto}
    #creditExecutive .ce-grid>.ce-panel+ .ce-panel{break-before:page}
    #creditExecutive .ce-kpi{min-height:0;padding:12px}
    #creditExecutive .ce-kpi small{margin-top:5px}
    #creditExecutive .ce-kpi-label{margin-bottom:7px}
    #creditExecutive .ce-panel{padding:10px;box-decoration-break:clone}
    #creditExecutive .ce-graph{width:100%;min-height:0;break-inside:avoid;text-align:center}
    #creditExecutive .ce-graph img{display:block;width:100%;height:auto;max-height:90mm;object-fit:contain;margin:0 auto}
    #creditExecutive table{width:100%!important;border-collapse:collapse;table-layout:auto;font-size:9px}
    #creditExecutive th,#creditExecutive td{padding:5px 6px;border-bottom:1px solid #dce3ed}
    #creditExecutive th{background:#f1f5fa;text-align:left}
    #creditExecutive td.ce-num,#creditExecutive th.ce-num{text-align:right;white-space:nowrap}
    #creditExecutive td:not(.ce-num),#creditExecutive th:not(.ce-num){white-space:normal;overflow-wrap:anywhere}
    #creditExecutive .ce-description{min-width:100px;max-width:270px}
    #creditExecutive .ce-note{font-size:9px;margin-top:7px}
    #creditExecutive .ce-muted{font-size:10px}
    #creditExecutive h2{font-size:15px}
    #creditExecutive h3{font-size:12px}
}
</style>
<cf_box title="Yöneticiye Özet">
<div id="creditExecutive">
    <cfoutput>
        <div style="font-size:13px; margin-bottom:15px;">
            <strong>Ödeme Dönemi:</strong>
            #encodeForHTML(credit_period_label)#
        </div>
    </cfoutput>
    <cfoutput>
        <div class="ce-kpis">
            <div class="ce-kpi ce-primary"><div class="ce-kpi-label">Dönemin toplam ödeme yükü</div><div class="ce-number">#TLFormat(credit_tl.monthlyPlanned,2)#<span class="ce-unit">TL</span><cfif credit_tl.monthlyMissing gt 0> *</cfif></div><small>Seçilen döneme düşen planlanmış taksitler</small></div>
            <div class="ce-kpi"><div class="ce-kpi-label">Bu taksitlerden ödenen</div><div class="ce-number">#TLFormat(credit_tl.monthlyPaid,2)#<span class="ce-unit">TL</span><cfif credit_tl.monthlyMissing gt 0> *</cfif></div><small>Bugüne kadar kaydedilmiş ödemeler</small></div>
            <div class="ce-kpi"><div class="ce-kpi-label">Ödenecek kalan</div><div class="ce-number">#TLFormat(credit_tl.monthlyRemaining,2)#<span class="ce-unit">TL</span><cfif credit_tl.monthlyMissing gt 0> *</cfif></div><small>Seçilen dönemin taksitlerine ait kalan borç</small></div>
        </div>
        <p class="ce-note">Tüm birleşik tutarlar güncel kurla TL karşılığıdır. Ödenen tutarlar da güncel kurla değerlenir; banka çıkış tutarı değildir. Ödemeler gecikme bedeli ve fazla ödeme içerebildiği için toplam yük ile ödenen + kalan arasında fark olabilir.</p>
        <cfif credit_tl.monthlyMissing gt 0 or credit_tl.generalMissing gt 0 or credit_tl.generalPlanMissing gt 0><div class="ce-alert"><strong>Eksik veri:</strong> #credit_tl.generalPlanMissing# kredinin ödeme planı, #credit_tl.generalMissing# kredinin güncel kuru eksik. Dönemde #credit_tl.monthlyMissing# taksidin TL karşılığı hesaplanamıyor. * işaretli toplamlar yalnızca hesaplanabilen kayıtları içerir. Plansız kredilerde, rotatif dahil, borç sıfır kabul edilmez.</div></cfif>
        <cfif credit_exec_past.recordCount><div class="ce-alert"><strong>Önceki vadelerden kalan:</strong> #TLFormat(creditExecPast,2)# TL<cfif creditExecPastMissing gt 0> * (kuru eksik taksitler hariç)</cfif>. Seçilen dönemden önce vadesi gelmiş, bugün itibarıyla hâlâ açık taksitlerdir; üstteki dönem toplamına dahil değildir.<br><cfloop query="credit_exec_past">#encodeForHTML(DOVIZ)#: #TLFormat(KALAN,2)# &nbsp; </cfloop></div></cfif>
        <cfif not get_monthly_credit_rows.recordCount><div class="ce-alert">Seçilen filtrelerde bu döneme ait kayıtlı taksit bulunmuyor. Tüm vadelerdeki borç özeti aşağıdadır.</div></cfif>
    </cfoutput>
    <div class="ce-grid">
        <section class="ce-panel"><h2>Döviz bazında dönem ödemesi</h2><p class="ce-muted">Grafik, toplam ödeme yükünün güncel TL karşılığını gösterir. Asıl döviz ihtiyacı tablodadır.</p>
            <cfif credit_tl.monthlyMissing eq 0 and credit_exec_fx.recordCount><div class="ce-graph" data-exec-graph="credit_exec_fx"><cf_ada_graph number_format="money" query="#credit_exec_fx#" label_column="GRAFIK_ETIKET" value_column="PLANLANAN_TL" type="bar" title="Dövizlerin TL Karşılığı" unit="TL" height="330" name="credit_exec_fx" color_universe="#valueList(credit_exec_fx.GRAFIK_ETIKET,'|')#"></div><cfelseif credit_tl.monthlyMissing gt 0><p class="ce-alert">Kur eksikliği nedeniyle grafik gösterilemiyor; döviz tutarları aşağıdadır.</p></cfif>
            <div class="ce-scroll"><cfsavecontent variable="credit_ada_converted_1_head"><tr><th>Döviz</th><th class="ce-num">Dönem ödemesi</th><th class="ce-num">Ödenen</th><th class="ce-num">Kalan</th></tr></cfsavecontent>
                <cfsavecontent variable="credit_ada_converted_1_rows"><cfoutput query="credit_exec_fx"><tr><td>#encodeForHTML(DOVIZ)#</td><td class="ce-num">#TLFormat(PLANLANAN,2)#</td><td class="ce-num">#TLFormat(ODENEN,2)#</td><td class="ce-num">#TLFormat(KALAN,2)#</td></tr></cfoutput></cfsavecontent>
                <div class="ce-ada-table" data-exec-table="<cfoutput>credit_ada_converted_1</cfoutput>">
                <cf_ada_table type="2" head="#credit_ada_converted_1_head#" rows="#credit_ada_converted_1_rows#" show_totals="0" page_size="100" name="credit_ada_converted_1" empty_message="Kayıt bulunamadı.">
            </div>
            <template data-exec-table-source="<cfoutput>credit_ada_converted_1</cfoutput>"><cf_ada_table type="2" head="#credit_ada_converted_1_head#" rows="#credit_ada_converted_1_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_1_pdf"></template></div>
        </section>
        <section class="ce-panel"><h2>Kurum bazında dönem ödemesi</h2><p class="ce-muted">Kalan ödeme yüküne göre büyükten küçüğe · güncel TL karşılığı</p>
            <cfif credit_tl.monthlyMissing eq 0 and credit_exec_bank.recordCount><div class="ce-graph" data-exec-graph="credit_exec_bank"><cf_ada_graph number_format="money" query="#credit_exec_bank#" label_column="KURUM" value_column="KALAN_TL" type="bar" title="Kurumlara Ödenecek Kalan" unit="TL" height="#max(330,credit_exec_bank.recordCount*44+95)#" name="credit_exec_bank" color_universe="#valueList(get_credit_institutions.KURUM,'|')#"></div><cfelseif credit_tl.monthlyMissing gt 0><p class="ce-alert">Kur eksikliği nedeniyle kurum grafiği gösterilemiyor.</p></cfif>
            <div class="ce-scroll"><cfsavecontent variable="credit_ada_converted_2_head"><tr><th>Kurum</th><th class="ce-num">Dönem · TL</th><th class="ce-num">Ödenen · TL</th><th class="ce-num">Kalan · TL</th></tr></cfsavecontent>
                <cfsavecontent variable="credit_ada_converted_2_rows"><cfoutput query="credit_exec_bank"><tr><td>#encodeForHTML(KURUM)#</td><td class="ce-num">#TLFormat(val(PLANLANAN_TL),2)# TL<cfif KUR_EKSIK gt 0> *</cfif></td><td class="ce-num">#TLFormat(val(ODENEN_TL),2)# TL<cfif KUR_EKSIK gt 0> *</cfif></td><td class="ce-num">#TLFormat(val(KALAN_TL),2)# TL<cfif KUR_EKSIK gt 0> *</cfif></td></tr></cfoutput><cfoutput><tr class="ce-total"><td>GENEL TOPLAM</td><td class="ce-num">#TLFormat(credit_tl.monthlyPlanned,2)# TL<cfif credit_tl.monthlyMissing gt 0> *</cfif></td><td class="ce-num">#TLFormat(credit_tl.monthlyPaid,2)# TL<cfif credit_tl.monthlyMissing gt 0> *</cfif></td><td class="ce-num">#TLFormat(credit_tl.monthlyRemaining,2)# TL<cfif credit_tl.monthlyMissing gt 0> *</cfif></td></tr></cfoutput></cfsavecontent>
                <div class="ce-ada-table" data-exec-table="<cfoutput>credit_ada_converted_2</cfoutput>">
                <cf_ada_table type="2" head="#credit_ada_converted_2_head#" rows="#credit_ada_converted_2_rows#" show_totals="0" page_size="100" name="credit_ada_converted_2" empty_message="Kayıt bulunamadı.">
            </div>
            <template data-exec-table-source="<cfoutput>credit_ada_converted_2</cfoutput>"><cf_ada_table type="2" head="#credit_ada_converted_2_head#" rows="#credit_ada_converted_2_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_2_pdf"></template></div>
        </section>
</div>
<section class="ce-panel"><h2>Borcun genel görünümü — tüm vadeler</h2><div class="ce-muted">Ay / tarih aralığından bağımsızdır. Diğer filtreler geçerlidir. Bakiyeler bugüne kadar kaydedilmiş ödemelere göredir.</div>
    <cfoutput><div class="ce-balance"><div class="ce-muted">Kalan anapara<strong>#TLFormat(creditExecOverallCapital,2)# TL<cfif credit_tl.generalMissing+credit_tl.generalPlanMissing gt 0> *</cfif></strong></div><div class="ce-muted">Kalan anapara + faiz<strong>#TLFormat(creditExecOverallAF,2)# TL<cfif credit_tl.generalMissing+credit_tl.generalPlanMissing gt 0> *</cfif></strong></div><div class="ce-muted">Kalan toplam ödeme (vergi dahil)<strong>#TLFormat(credit_tl.generalRemaining,2)# TL<cfif credit_tl.generalMissing+credit_tl.generalPlanMissing gt 0> *</cfif></strong></div></div></cfoutput>
    <h3>Yıllara göre kalan ödeme</h3>
    <cfif credit_distribution_missing eq 0 and credit_distribution_year_tl.recordCount><div class="ce-graph" data-exec-graph="credit_exec_year"><cf_ada_graph number_format="money" query="#credit_distribution_year_tl#" label_column="DONEM" value_column="TUTAR_TL" type="bar" title="Yıllara Göre Kalan Ödeme" unit="TL" height="330" name="credit_exec_year" color_universe="#valueList(credit_distribution_year_tl.DONEM,'|')#"></div></cfif>
    <div class="ce-scroll"><cfsavecontent variable="credit_ada_converted_3_head"><tr><th>Vade yılı</th><cfoutput query="credit_distribution_currencies"><th class="ce-num">#encodeForHTML(DOVIZ)#</th></cfoutput><th class="ce-num">Güncel kurla toplam TL</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_3_rows">
    <cfloop query="credit_distribution_year_tl"><cfset cey=toString(credit_distribution_year_tl.DONEM)><cfoutput><tr><td>#encodeForHTML(cey)#</td></cfoutput><cfloop query="credit_distribution_currencies"><cfset cev=0><cfif structKeyExists(creditExecYears,cey) and structKeyExists(creditExecYears[cey],credit_distribution_currencies.DOVIZ)><cfset cev=creditExecYears[cey][credit_distribution_currencies.DOVIZ]></cfif><cfoutput><td class="ce-num">#TLFormat(cev,2)#</td></cfoutput></cfloop><cfoutput><td class="ce-num">#TLFormat(val(credit_distribution_year_tl.TUTAR_TL),2)# TL<cfif credit_distribution_year_tl.KUR_EKSIK gt 0> *</cfif></td></tr></cfoutput></cfloop>
    <cfoutput><tr class="ce-total"><td>TOPLAM</td></cfoutput><cfloop query="credit_distribution_currencies"><cfset ceysum=0><cfloop collection="#creditExecYears#" item="ceyk"><cfif structKeyExists(creditExecYears[ceyk],credit_distribution_currencies.DOVIZ)><cfset ceysum+=creditExecYears[ceyk][credit_distribution_currencies.DOVIZ]></cfif></cfloop><cfoutput><td class="ce-num">#TLFormat(ceysum,2)#</td></cfoutput></cfloop><cfoutput><td class="ce-num">#TLFormat(credit_tl.generalRemaining,2)# TL<cfif credit_tl.generalMissing+credit_tl.generalPlanMissing gt 0> *</cfif></td></tr></cfoutput>
    </cfsavecontent>
<div class="ce-ada-table" data-exec-table="<cfoutput>credit_ada_converted_3</cfoutput>">
<cf_ada_table type="2" head="#credit_ada_converted_3_head#" rows="#credit_ada_converted_3_rows#" show_totals="0" page_size="100" name="credit_ada_converted_3" empty_message="Kayıt bulunamadı.">
</div>
<template data-exec-table-source="<cfoutput>credit_ada_converted_3</cfoutput>"><cf_ada_table type="2" head="#credit_ada_converted_3_head#" rows="#credit_ada_converted_3_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_3_pdf"></template></div><p class="ce-note">Dağılım, kayıtlı taksit planlarının kalan tutarlarını içerir. Önceki yıllardan kalan açık vadeler kendi yılında gösterilir. Ödeme planı olmayan krediler yıllara dağıtılamaz.</p>
</section>
<section class="ce-panel ce-long-section"><h2>Kredi türü ve kurum bazında borç özeti</h2><p class="ce-muted">Kredi başına tek satır. Türler Workcube kayıtlarından alınır. Dönem ödemesi seçilen aralığa; taksit sayıları ve kalan borç tüm vadelere aittir.</p>
<cfloop from="1" to="#arrayLen(creditExecGroups)#" index="cegi"><cfset cegroup=creditExecGroups[cegi]>
    <cfoutput><h3>#encodeForHTML(cegroup.title)#</h3></cfoutput><div class="ce-scroll"><cfsavecontent variable="credit_ada_converted_4_head"><tr><th>Kredi no</th><th>Açıklama</th><th>Döviz</th><th class="ce-num">Dönem ödemesi</th><th class="ce-num">Toplam / Ödenen / Kalan taksit</th><th class="ce-num">Kalan anapara</th><th class="ce-num">Kalan anapara + faiz</th><th class="ce-num">Kalan toplam ödeme</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_4_rows">
    <cfset ceLastBank=""><cfset ceLastCurrency=""><cfset ceFirst=true>
    <cfloop array="#cegroup.rows#" index="cerow"><cfset ceInstitution=credit_exec_loans.KURUM[cerow]><cfset ceCurrency=credit_exec_loans.DOVIZ[cerow]>
        <cfif not ceFirst and (ceLastBank neq ceInstitution or ceLastCurrency neq ceCurrency)><cfset cesub=cegroup.banks[cegroup.bankIndex[toString(ceLastBank)&chr(31)&ceLastCurrency]]><cfoutput><tr class="ce-subtotal"><td colspan="2">#encodeForHTML(ceLastBank)# · Ara toplam</td><td>#encodeForHTML(ceLastCurrency)#</td><td class="ce-num">#TLFormat(cesub.planned,2)#</td><td></td><td class="ce-num">#TLFormat(cesub.capital,2)#<cfif cesub.missing> *</cfif></td><td class="ce-num">#TLFormat(cesub.af,2)#<cfif cesub.missing> *</cfif></td><td class="ce-num">#TLFormat(cesub.remaining,2)#<cfif cesub.missing> *</cfif></td></tr></cfoutput></cfif>
        <cfif ceFirst or ceLastBank neq ceInstitution><cfoutput><tr class="ce-bank-title"><td colspan="8">#encodeForHTML(ceInstitution)#</td></tr></cfoutput></cfif>
        <cfset ceLastBank=ceInstitution><cfset ceLastCurrency=ceCurrency><cfset ceFirst=false><cfset cek=toString(credit_exec_loans.CREDIT_CONTRACT_ID[cerow])><cfset cep={planned=0,paid=0,remaining=0}><cfif structKeyExists(creditExecPeriod,cek)><cfset cep=creditExecPeriod[cek]></cfif>
        <cfoutput><tr><td>#encodeForHTML(credit_exec_loans.CREDIT_NO[cerow])#</td><td class="ce-description">#encodeForHTML(credit_exec_loans.KREDI_ACIKLAMASI[cerow])#<cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 1><br><small>Ödeme planı yok; bakiye doğrulanmalı.</small></cfif></td><td>#encodeForHTML(ceCurrency)#</td><td class="ce-num"><cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 0>#TLFormat(cep.planned,2)#<cfelse>—</cfif></td><td class="ce-num"><cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 0>#credit_exec_loans.TAKSIT_SAYISI[cerow]# / #credit_exec_loans.ODENEN_ADET[cerow]# / #credit_exec_loans.KALAN_ADET[cerow]#<cfelse>—</cfif></td><td class="ce-num"><cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 0>#TLFormat(credit_exec_loans.KALAN_ANAPARA[cerow],2)#<cfelse>—</cfif></td><td class="ce-num"><cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 0>#TLFormat(credit_exec_loans.KALAN_ANAPARA_FAIZ[cerow],2)#<cfelse>—</cfif></td><td class="ce-num"><cfif credit_exec_loans.PLAN_EKSIK[cerow] eq 0>#TLFormat(credit_exec_loans.KALAN_ODEME[cerow],2)#<cfelse>—</cfif></td></tr></cfoutput>
    </cfloop>
    <cfif not ceFirst><cfset cesub=cegroup.banks[cegroup.bankIndex[toString(ceLastBank)&chr(31)&ceLastCurrency]]><cfoutput><tr class="ce-subtotal"><td colspan="2">#encodeForHTML(ceLastBank)# · Ara toplam</td><td>#encodeForHTML(ceLastCurrency)#</td><td class="ce-num">#TLFormat(cesub.planned,2)#</td><td></td><td class="ce-num">#TLFormat(cesub.capital,2)#<cfif cesub.missing> *</cfif></td><td class="ce-num">#TLFormat(cesub.af,2)#<cfif cesub.missing> *</cfif></td><td class="ce-num">#TLFormat(cesub.remaining,2)#<cfif cesub.missing> *</cfif></td></tr></cfoutput></cfif>
    <cfloop array="#cegroup.currencyOrder#" index="ced"><cfset cetotal=cegroup.currencies[ced]><cfoutput><tr class="ce-total"><td colspan="2">Tür toplamı</td><td>#encodeForHTML(ced)#</td><td class="ce-num">#TLFormat(cetotal.planned,2)#<cfif cetotal.missing> *</cfif></td><td></td><td class="ce-num">#TLFormat(cetotal.capital,2)#<cfif cetotal.missing> *</cfif></td><td class="ce-num">#TLFormat(cetotal.af,2)#<cfif cetotal.missing> *</cfif></td><td class="ce-num">#TLFormat(cetotal.remaining,2)#<cfif cetotal.missing> *</cfif></td></tr></cfoutput></cfloop>
    <cfoutput><tr class="ce-total"><td colspan="2">Tür toplamı · TL karşılığı</td><td>TL</td><td></td><td></td><td class="ce-num">#TLFormat(cegroup.capitalTL,2)# TL<cfif cegroup.missing> *</cfif></td><td class="ce-num">#TLFormat(cegroup.afTL,2)# TL<cfif cegroup.missing> *</cfif></td><td class="ce-num">#TLFormat(cegroup.remainingTL,2)# TL<cfif cegroup.missing> *</cfif></td></tr></cfoutput>
    </cfsavecontent>
<div class="ce-ada-table" data-exec-table="<cfoutput>credit_ada_converted_4_#cegi#</cfoutput>">
<cf_ada_table type="2" head="#credit_ada_converted_4_head#" rows="#credit_ada_converted_4_rows#" show_totals="0" page_size="100" name="credit_ada_converted_4_#cegi#" empty_message="Kayıt bulunamadı.">
</div>
<template data-exec-table-source="<cfoutput>credit_ada_converted_4_#cegi#</cfoutput>"><cf_ada_table type="2" head="#credit_ada_converted_4_head#" rows="#credit_ada_converted_4_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_4_#cegi#_pdf"></template></div>
</cfloop>
<p class="ce-note">Tüm taksit sayıları kayıtlı planlara göredir. Kısmi ödenen taksitler kalan sayısına dahildir. “—” eksik bilgiyi, * eksik kayıtlar hariç hesaplanabilen toplamı gösterir. Geçmiş dönem seçimi o dönemin kapanış bakiyesini oluşturmaz; ödeme durumu bugüne göredir.</p>
</section>
</div>

</cf_box>
<cfelse>
<cf_box title="Güncel Kurla TL Özeti">
    <cfoutput>
        <div class="credit-tl-summary" style="padding:12px;">
            <p><strong>Seçilen Dönem:</strong> #encodeForHTML(credit_period_label)#</p>
            <p><strong>Kredi Durumu:</strong> <cfif attributes.credit_active_status eq "1">Aktif<cfelseif attributes.credit_active_status eq "0">Pasif<cfelse>Tümü</cfif></p>
            <p><strong>Hesaplanabilen kalan ödeme (tüm vadeler):</strong>
            #TLFormat(credit_tl.generalRemaining,2)# TL<cfif credit_tl.generalPlanMissing gt 0 or credit_tl.generalMissing gt 0> *
                <br><small>* Hesaplanabilen kayıtların toplamıdır.
                <cfif credit_tl.generalPlanMissing gt 0>#credit_tl.generalPlanMissing# plansız kredi hariçtir.</cfif>
                <cfif credit_tl.generalMissing gt 0>#credit_tl.generalMissing# kredinin güncel kuru eksiktir.</cfif></small></cfif></p>
            <p><strong>#encodeForHTML(credit_period_label)#:</strong>
                Planlanan: #TLFormat(credit_tl.monthlyPlanned,2)# TL ·
                Ödenen: #TLFormat(credit_tl.monthlyPaid,2)# TL ·
                Kalan: #TLFormat(credit_tl.monthlyRemaining,2)# TL
            <cfif credit_tl.monthlyMissing gt 0> *<br><small>* Güncel kuru eksik #credit_tl.monthlyMissing# taksit hariç, hesaplanabilen TL tutarlarıdır.</small></cfif></p>
            <p>Tüm TL karşılıkları güncel RATE2 / RATE1 ile değerlenmiştir. Ödenen TL tutarı da bu kurla gösterilir; ödeme günündeki banka çıkış tutarı değildir.</p>
        </div>
    </cfoutput>
</cf_box>
<cf_box title="Genel Görünüm — Tüm Vadeler">
    <div style="padding:8px 10px;">
        Ay/tarih aralığı filtresinden bağımsızdır; kurum, kredi türü ve döviz filtreleri uygulanır.
        Taksit sayıları Workcube'de kayıtlı ödeme planına göredir. Kısmi ödenen taksitler kalan adede dahildir.
        Kullanım tarihi kredi kartındaki tarihtir.
        <cfif attributes.hide_completed eq 1>Ödemesi bitmiş krediler gizlenir. Ödeme planı olmayanlarda kapanış doğrulanamadığı için kayıt görünür kalır; anapara geri ödemesi tek başına kapanış sayılmaz.</cfif>
        TL karşılıkları SETUP_MONEY güncel RATE2 / RATE1 kuruyla hesaplanır. Kuru olmayan tutarların TL karşılığında “Kur eksik” yazılır; eksik toplam gösterilmez.
    </div>
    <cfloop query="credit_overview_currencies">
        <cfset overview_currency = credit_overview_currencies.DOVIZ>
        <cfset overview_index = credit_overview_currencies.currentRow>
        <cfquery name="credit_overview_currency" dbtype="query">
            SELECT * FROM get_credit_overview
            WHERE DOVIZ=<cfqueryparam cfsqltype="cf_sql_varchar" value="#overview_currency#">
            ORDER BY KURUM, CREDIT_NO
        </cfquery>
                <cfset credit_overview_incomplete = "">
        <cfloop query="credit_overview_currency">
            <cfif credit_overview_currency.PLAN_EKSIK eq 1>
                <cfset credit_overview_incomplete = "ODENEN_ADET,KISMI_ADET,KALAN_ADET,KALAN_ANAPARA,KALAN_FAIZ,KALAN_MASRAF,KALAN_ANAPARA_FAIZ,KALAN_ODEME,KALAN_TL">
            <cfelseif not isNumeric(credit_overview_currency.KALAN_TL)>
                <cfif not listFind(credit_overview_incomplete,"KALAN_TL")><cfset credit_overview_incomplete = listAppend(credit_overview_incomplete,"KALAN_TL")></cfif>
            </cfif>
        </cfloop>
<!--- TLFormat sadece gorunume uygulanir; ada_table toplamlari ham data-at-val ile hesaplar. --->
<cfsavecontent variable="credit_overview_head">
    <tr>
        <th data-at-col="KURUM">Kurum</th>
        <th data-at-col="CREDIT_NO">Kredi No</th>
        <th data-at-col="KREDI_ACIKLAMASI">Kredi Açıklaması</th>
        <th data-at-col="KREDI_TURU">Kredi Türü</th>
        <th data-at-col="KULLANIM_TARIHI">Kullanım Tarihi</th>
        <th data-at-col="KREDI_TUTARI" data-credit-money="2">Kredi Tutarı</th>
        <th data-at-col="TAKSIT_SAYISI">Kayıtlı Taksit</th>
        <th data-at-col="ODENEN_ADET">Ödenen Adet</th>
        <th data-at-col="KISMI_ADET">Kısmi Ödenen Adet</th>
        <th data-at-col="KALAN_ADET">Kalan Adet</th>
        <th data-at-col="KALAN_ANAPARA" data-credit-money="2">Kalan Anapara</th>
        <th data-at-col="KALAN_FAIZ" data-credit-money="2">Kalan Faiz</th>
        <th data-at-col="KALAN_MASRAF" data-credit-money="2">Kalan Vergi/Masraf</th>
        <th data-at-col="KALAN_ANAPARA_FAIZ" data-credit-money="2">Kalan Anapara ve Faiz</th>
        <th data-at-col="KALAN_ODEME" data-credit-money="2">Kalan Toplam Ödeme</th>
        <th data-at-col="GUNCEL_KUR" data-credit-money="4">Güncel Kur</th>
        <th data-at-col="KALAN_TL" data-credit-money="2" data-credit-unit="TL">Kalan Ödeme TL</th>
        <th data-at-col="KONTROL">Kontrol</th>
    </tr>
</cfsavecontent>
<cfsavecontent variable="credit_overview_rows">
    <cfoutput query="credit_overview_currency">
        <tr>
            <td data-at-col="KURUM">#encodeForHTML(KURUM)#</td>
            <td data-at-col="CREDIT_NO">#encodeForHTML(CREDIT_NO)#</td>
            <td data-at-col="KREDI_ACIKLAMASI">#encodeForHTML(KREDI_ACIKLAMASI)#</td>
            <td data-at-col="KREDI_TURU">#encodeForHTML(KREDI_TURU)#</td>
            <td data-at-col="KULLANIM_TARIHI"><cfif isDate(KULLANIM_TARIHI)>#dateFormat(KULLANIM_TARIHI,"dd/mm/yyyy")#</cfif></td>
            <td data-at-col="KREDI_TUTARI" data-at-val="#encodeForHTMLAttribute(KREDI_TUTARI)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KREDI_TUTARI)>#TLFormat(KREDI_TUTARI,2)#</cfif></td>
            <td data-at-col="TAKSIT_SAYISI" data-at-val="#TAKSIT_SAYISI#" style="text-align:right;">#TAKSIT_SAYISI#</td>
            <td data-at-col="ODENEN_ADET" data-at-val="#ODENEN_ADET#" style="text-align:right;"><cfif PLAN_EKSIK eq 0>#ODENEN_ADET#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KISMI_ADET" data-at-val="#KISMI_ADET#" style="text-align:right;"><cfif PLAN_EKSIK eq 0>#KISMI_ADET#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_ADET" data-at-val="#KALAN_ADET#" style="text-align:right;"><cfif PLAN_EKSIK eq 0>#KALAN_ADET#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_ANAPARA" data-at-val="#encodeForHTMLAttribute(KALAN_ANAPARA)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_ANAPARA)>#TLFormat(KALAN_ANAPARA,2)#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_FAIZ" data-at-val="#encodeForHTMLAttribute(KALAN_FAIZ)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_FAIZ)>#TLFormat(KALAN_FAIZ,2)#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_MASRAF" data-at-val="#encodeForHTMLAttribute(KALAN_MASRAF)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_MASRAF)>#TLFormat(KALAN_MASRAF,2)#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_ANAPARA_FAIZ" data-at-val="#encodeForHTMLAttribute(KALAN_ANAPARA_FAIZ)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_ANAPARA_FAIZ)>#TLFormat(KALAN_ANAPARA_FAIZ,2)#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="KALAN_ODEME" data-at-val="#encodeForHTMLAttribute(KALAN_ODEME)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_ODEME)>#TLFormat(KALAN_ODEME,2)#<cfelse><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span></cfif></td>
            <td data-at-col="GUNCEL_KUR" data-at-val="#encodeForHTMLAttribute(GUNCEL_KUR)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(GUNCEL_KUR)>#TLFormat(GUNCEL_KUR,4)#</cfif></td>
            <td data-at-col="KALAN_TL" data-at-val="#encodeForHTMLAttribute(KALAN_TL)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_TL)>#TLFormat(KALAN_TL,2)# TL<cfelseif PLAN_EKSIK eq 1><span title="Ödeme planı bulunmadığı için bu bilgi hesaplanamıyor">—</span><cfelse>Kur eksik</cfif></td>
            <td data-at-col="KONTROL">#encodeForHTML(KONTROL)#</td>
        </tr>
    </cfoutput>
</cfsavecontent>
<div class="credit-money-table" data-credit-incomplete-columns="<cfoutput>#credit_overview_incomplete#</cfoutput>">
    <cf_ada_table type="2" head="#credit_overview_head#" rows="#credit_overview_rows#"
        title="#overview_currency# — Krediler"
        show_totals="1"
        total_columns="KREDI_TUTARI,TAKSIT_SAYISI,ODENEN_ADET,KISMI_ADET,KALAN_ADET,KALAN_ANAPARA,KALAN_FAIZ,KALAN_MASRAF,KALAN_ANAPARA_FAIZ,KALAN_ODEME,KALAN_TL"
        page_size="20"
        name="credit_overview_#overview_index#">
</div>
        <cfoutput>
            <p style="padding:8px 10px;">
                <strong>#encodeForHTML(overview_currency)#:</strong>
                #credit_overview_currencies.KREDI_ADEDI# kredi;
                #val(credit_overview_currencies.TAKSIT_SAYISI)# kayıtlı taksit;
                #val(credit_overview_currencies.ODENEN_ADET)# ödenen;
                #val(credit_overview_currencies.KALAN_ADET)# kalan
                (kalanların #val(credit_overview_currencies.KISMI_ADET)# adedi kısmi ödenmiş).
                Kayıtlı planlara göre kalan anapara: #TLFormat(val(credit_overview_currencies.KALAN_ANAPARA),2)#.
                Kalan ödeme: #TLFormat(val(credit_overview_currencies.KALAN_ODEME),2)#.
                <cfif len(credit_overview_incomplete)><br><small>* İşaretli toplamlar yalnızca hesaplanabilen değerleri kapsar; eksik plan/kur bilgileri dahil değildir.</small></cfif>
                <cfif credit_overview_currencies.PLAN_EKSIK gt 0><br><small>#credit_overview_currencies.PLAN_EKSIK# kredinin ödeme planı yok. “—” görünen alanlar bilinmiyor; sıfır borç anlamına gelmez.</small></cfif>
            </p>
        </cfoutput>
        <section class="credit-pdf-general" style="display:none;">
            <cfoutput><h2>Genel Görünüm — #encodeForHTML(overview_currency)# — Tüm Vadeler</h2>
                <p>Kayıtlı ödeme planları. Kısmi ödenen taksitler kalan adede dahildir. TL karşılığı güncel RATE2 / RATE1 kuruyla hesaplanır. “—” bilgisi olmayan alanı; * ise eksik veriler hariç hesaplanabilen değerlerin toplamını gösterir.</p></cfoutput>
            <cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["KREDI_TUTARI"] = 0>
<cfset credit_pdf_sums["TAKSIT_SAYISI"] = 0>
<cfset credit_pdf_sums["ODENEN_ADET"] = 0>
<cfset credit_pdf_sums["KISMI_ADET"] = 0>
<cfset credit_pdf_sums["KALAN_ADET"] = 0>
<cfset credit_pdf_sums["KALAN_ANAPARA"] = 0>
<cfset credit_pdf_sums["KALAN_FAIZ"] = 0>
<cfset credit_pdf_sums["KALAN_MASRAF"] = 0>
<cfset credit_pdf_sums["KALAN_ANAPARA_FAIZ"] = 0>
<cfset credit_pdf_sums["KALAN_ODEME"] = 0>
<cfset credit_pdf_sums["KALAN_TL"] = 0>
<cfloop query="credit_overview_currency">
<cfif isNumeric(credit_overview_currency.KREDI_TUTARI)><cfset credit_pdf_sums["KREDI_TUTARI"] += credit_overview_currency.KREDI_TUTARI></cfif>
<cfif isNumeric(credit_overview_currency.TAKSIT_SAYISI)><cfset credit_pdf_sums["TAKSIT_SAYISI"] += credit_overview_currency.TAKSIT_SAYISI></cfif>
<cfif isNumeric(credit_overview_currency.ODENEN_ADET)><cfset credit_pdf_sums["ODENEN_ADET"] += credit_overview_currency.ODENEN_ADET></cfif>
<cfif isNumeric(credit_overview_currency.KISMI_ADET)><cfset credit_pdf_sums["KISMI_ADET"] += credit_overview_currency.KISMI_ADET></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_ADET)><cfset credit_pdf_sums["KALAN_ADET"] += credit_overview_currency.KALAN_ADET></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_ANAPARA)><cfset credit_pdf_sums["KALAN_ANAPARA"] += credit_overview_currency.KALAN_ANAPARA></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_FAIZ)><cfset credit_pdf_sums["KALAN_FAIZ"] += credit_overview_currency.KALAN_FAIZ></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_MASRAF)><cfset credit_pdf_sums["KALAN_MASRAF"] += credit_overview_currency.KALAN_MASRAF></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_ANAPARA_FAIZ)><cfset credit_pdf_sums["KALAN_ANAPARA_FAIZ"] += credit_overview_currency.KALAN_ANAPARA_FAIZ></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_ODEME)><cfset credit_pdf_sums["KALAN_ODEME"] += credit_overview_currency.KALAN_ODEME></cfif>
<cfif isNumeric(credit_overview_currency.KALAN_TL)><cfset credit_pdf_sums["KALAN_TL"] += credit_overview_currency.KALAN_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td class="number">#TLFormat(credit_pdf_sums["KREDI_TUTARI"],2)#<cfif listFind(credit_overview_incomplete,"KREDI_TUTARI")> *</cfif></td>
<td class="number">#numberFormat(credit_pdf_sums["TAKSIT_SAYISI"],"0")#<cfif listFind(credit_overview_incomplete,"TAKSIT_SAYISI")> *</cfif></td>
<td class="number">#numberFormat(credit_pdf_sums["ODENEN_ADET"],"0")#<cfif listFind(credit_overview_incomplete,"ODENEN_ADET")> *</cfif></td>
<td class="number">#numberFormat(credit_pdf_sums["KISMI_ADET"],"0")#<cfif listFind(credit_overview_incomplete,"KISMI_ADET")> *</cfif></td>
<td class="number">#numberFormat(credit_pdf_sums["KALAN_ADET"],"0")#<cfif listFind(credit_overview_incomplete,"KALAN_ADET")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_ANAPARA"],2)#<cfif listFind(credit_overview_incomplete,"KALAN_ANAPARA")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_FAIZ"],2)#<cfif listFind(credit_overview_incomplete,"KALAN_FAIZ")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_MASRAF"],2)#<cfif listFind(credit_overview_incomplete,"KALAN_MASRAF")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_ANAPARA_FAIZ"],2)#<cfif listFind(credit_overview_incomplete,"KALAN_ANAPARA_FAIZ")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_ODEME"],2)#<cfif listFind(credit_overview_incomplete,"KALAN_ODEME")> *</cfif></td>
<td></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_TL"],2)# TL<cfif listFind(credit_overview_incomplete,"KALAN_TL")> *</cfif></td>
<td></td>
</tr></cfoutput></cfsavecontent>
<cfoutput><cfsavecontent variable="credit_ada_converted_5_head">#credit_overview_head#</cfsavecontent>
<cfsavecontent variable="credit_ada_converted_5_rows">#credit_overview_rows##credit_pdf_foot#</cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_5_head#" rows="#credit_ada_converted_5_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_5_#overview_index#_pdf"></cfoutput>
        </section>
    </cfloop>
</cf_box>


<cf_box title="Kalan Kredi Ödemeleri — Aylık ve Yıllık Dağılım">
    <p style="padding:8px 10px;">Seçilen ay/tarih aralığından bağımsız olarak tüm vadelerde kalan ödemeler gösterilir; geçmiş vadeli ödenmemiş tutarlar da kendi vade ayında yer alır.
        Kurum, kredi türü, döviz ve aktif/pasif filtreleri uygulanır. TL karşılıklarında güncel RATE2 / RATE1 kullanılır.
        Ödeme planı bulunmayan krediler bu dağılıma dahil edilemez. Aylık dönemler ay adı ve yıl biçiminde gösterilir.</p>
    <cfif not credit_distribution_currencies.recordCount>
        <p style="padding:10px;">Filtrelere uygun, ödeme planı kayıtlı kalan borç bulunamadı.</p>
    <cfelse>

        <cfif credit_distribution_missing eq 0>
            <cf_ada_graph number_format="money" query="#credit_distribution_month_tl#" label_column="DONEM_ETIKET" value_column="TUTAR_TL" type="bar"
                title="Kalan Ödemelerin Aylık Dağılımı — Güncel Kurla TL" unit="TL" height="400" label_rotate="45" name="credit_dist_month_tl">
            <cf_ada_graph number_format="money" query="#credit_distribution_year_tl#" label_column="DONEM" value_column="TUTAR_TL" type="bar"
                title="Kalan Ödemelerin Yıllık Dağılımı — Güncel Kurla TL" unit="TL" height="320" name="credit_dist_year_tl">
        <cfelse>
            <p>Güncel kuru eksik taksitler bulunduğundan birleşik TL grafikleri ve TL genel toplamları gösterilmiyor. İlgili dönemlerde “Kur eksik” yazılır.</p>
        </cfif>
        <cfset credit_dist_tl_totals = credit_distribution_missing eq 0 ? "TUTAR_TL" : "DONEM">
<cfsavecontent variable="credit_dist_head"><cfoutput><tr>
<th data-at-col="DONEM">Dönem</th>
<th data-at-col="TUTAR_TL" data-credit-money="2" data-credit-unit="TL">Kalan Ödeme TL</th>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_dist_rows">
<cfoutput query="credit_distribution_month_tl"><tr>
<td data-at-col="DONEM">#encodeForHTML(DONEM_ETIKET)#</td>
<td data-at-col="TUTAR_TL" data-at-val="#encodeForHTMLAttribute(TUTAR_TL)#" style="text-align:right;"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td>
</tr></cfoutput></cfsavecontent>
<div class="credit-money-table"><cf_ada_table type="2" head="#credit_dist_head#" rows="#credit_dist_rows#" title="Aylık Dağılım — Tüm Dövizlerin TL Karşılığı" show_totals="#credit_distribution_missing eq 0 ? 1 : 0#" total_columns="#credit_dist_tl_totals#" page_size="24" name="credit_dist_month_tl_table"></div>
<cfsavecontent variable="credit_dist_head"><cfoutput><tr>
<th data-at-col="DONEM">Dönem</th>
<th data-at-col="TUTAR_TL" data-credit-money="2" data-credit-unit="TL">Kalan Ödeme TL</th>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_dist_rows">
<cfoutput query="credit_distribution_year_tl"><tr>
<td data-at-col="DONEM">#encodeForHTML(DONEM)#</td>
<td data-at-col="TUTAR_TL" data-at-val="#encodeForHTMLAttribute(TUTAR_TL)#" style="text-align:right;"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td>
</tr></cfoutput></cfsavecontent>
<div class="credit-money-table"><cf_ada_table type="2" head="#credit_dist_head#" rows="#credit_dist_rows#" title="Yıllık Dağılım — Tüm Dövizlerin TL Karşılığı" show_totals="#credit_distribution_missing eq 0 ? 1 : 0#" total_columns="#credit_dist_tl_totals#" page_size="24" name="credit_dist_year_tl_table"></div>

        <cfloop query="credit_distribution_currencies">
            <cfset credit_dist_currency = credit_distribution_currencies.DOVIZ>
            <cfset credit_dist_index = credit_distribution_currencies.currentRow>
            <cfquery name="credit_dist_month" dbtype="query">
                SELECT VADE_AY AS DONEM, SUM(KALAN) AS TUTAR, SUM(KALAN_TL) AS TUTAR_TL, SUM(FX_EKSIK) AS KUR_EKSIK
                FROM get_credit_schedule_rows WHERE KALAN>0 AND DOVIZ=<cfqueryparam cfsqltype="cf_sql_varchar" value="#credit_dist_currency#">
                GROUP BY VADE_AY ORDER BY VADE_AY
            </cfquery>
<cfset credit_month_display_labels = arrayNew(1)>
<cfloop query="credit_dist_month">
    <cfset credit_month_key = credit_dist_month.DONEM>
    <cfset arrayAppend(credit_month_display_labels, listGetAt(credit_month_names,val(right(credit_month_key,2))) & " " & left(credit_month_key,4))>
</cfloop>
<cfset queryAddColumn(credit_dist_month,"DONEM_ETIKET","varchar",credit_month_display_labels)>

            <cfquery name="credit_dist_year" dbtype="query">
                SELECT VADE_YIL AS DONEM, SUM(KALAN) AS TUTAR, SUM(KALAN_TL) AS TUTAR_TL, SUM(FX_EKSIK) AS KUR_EKSIK
                FROM get_credit_schedule_rows WHERE KALAN>0 AND DOVIZ=<cfqueryparam cfsqltype="cf_sql_varchar" value="#credit_dist_currency#">
                GROUP BY VADE_YIL ORDER BY VADE_YIL
            </cfquery>
            <cfset credit_dist_currency_missing = 0>
            <cfloop query="credit_dist_month"><cfset credit_dist_currency_missing += credit_dist_month.KUR_EKSIK></cfloop>
            <cfset credit_dist_currency_totals = credit_dist_currency_missing eq 0 ? "TUTAR,TUTAR_TL" : "TUTAR">
            <cf_ada_graph number_format="money" query="#credit_dist_month#" label_column="DONEM_ETIKET" value_column="TUTAR" type="bar"
                title="#credit_dist_currency# — Kalan Ödemelerin Aylık Dağılımı" unit="#credit_dist_currency#" height="380" label_rotate="45" name="credit_dist_month_#credit_dist_index#">
            <cf_ada_graph number_format="money" query="#credit_dist_year#" label_column="DONEM" value_column="TUTAR" type="bar"
                title="#credit_dist_currency# — Kalan Ödemelerin Yıllık Dağılımı" unit="#credit_dist_currency#" height="300" name="credit_dist_year_#credit_dist_index#">
<cfsavecontent variable="credit_dist_head"><cfoutput><tr>
<th data-at-col="DONEM">Dönem</th>
<th data-at-col="TUTAR" data-credit-money="2">Kalan Ödeme (#credit_dist_currency#)</th>
<th data-at-col="TUTAR_TL" data-credit-money="2" data-credit-unit="TL">Güncel Kurla TL</th>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_dist_rows">
<cfoutput query="credit_dist_month"><tr>
<td data-at-col="DONEM">#encodeForHTML(DONEM_ETIKET)#</td>
<td data-at-col="TUTAR" data-at-val="#TUTAR#" style="text-align:right;">#TLFormat(TUTAR,2)#</td>
<td data-at-col="TUTAR_TL" data-at-val="#encodeForHTMLAttribute(TUTAR_TL)#" style="text-align:right;"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td>
</tr></cfoutput></cfsavecontent>
<div class="credit-money-table"><cf_ada_table type="2" head="#credit_dist_head#" rows="#credit_dist_rows#" title="#credit_dist_currency# — Aylık Dağılım" show_totals="1" total_columns="#credit_dist_currency_totals#" page_size="24" name="credit_dist_month_table_#credit_dist_index#"></div>
<section class="credit-pdf-distribution" data-graph="<cfoutput>credit_dist_month_#credit_dist_index#</cfoutput>" style="display:none;">
        <cfoutput><h2>#encodeForHTML(credit_dist_currency)# — Aylık Kalan Ödeme Dağılımı</h2></cfoutput>
        <div class="credit-distribution-image"></div><cfset credit_pdf_dist_missing = 0><cfloop query="credit_dist_month"><cfset credit_pdf_dist_missing += credit_dist_month.KUR_EKSIK></cfloop>
<cfset credit_pdf_dist_incomplete = credit_pdf_dist_missing gt 0 ? "TUTAR_TL" : "">
<cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["TUTAR"] = 0>
<cfset credit_pdf_sums["TUTAR_TL"] = 0>
<cfloop query="credit_dist_month">
<cfif isNumeric(credit_dist_month.TUTAR)><cfset credit_pdf_sums["TUTAR"] += credit_dist_month.TUTAR></cfif>
<cfif isNumeric(credit_dist_month.TUTAR_TL)><cfset credit_pdf_sums["TUTAR_TL"] += credit_dist_month.TUTAR_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR"],2)#</cfif></td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR_TL")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR_TL"],2)# TL</cfif></td>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_6_head"><tr><th>Dönem</th><th>Kalan Ödeme</th><th>Güncel Kurla TL</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_6_rows">
        <cfoutput query="credit_dist_month"><tr><td>#encodeForHTML(DONEM_ETIKET)#</td><td class="number">#TLFormat(TUTAR,2)#</td><td class="number"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td></tr></cfoutput>
        <cfoutput>#credit_pdf_foot#</cfoutput></cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_6_head#" rows="#credit_ada_converted_6_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_6_#credit_dist_index#_pdf"></section>
<cfsavecontent variable="credit_dist_head"><cfoutput><tr>
<th data-at-col="DONEM">Dönem</th>
<th data-at-col="TUTAR" data-credit-money="2">Kalan Ödeme (#credit_dist_currency#)</th>
<th data-at-col="TUTAR_TL" data-credit-money="2" data-credit-unit="TL">Güncel Kurla TL</th>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_dist_rows">
<cfoutput query="credit_dist_year"><tr>
<td data-at-col="DONEM">#encodeForHTML(DONEM)#</td>
<td data-at-col="TUTAR" data-at-val="#TUTAR#" style="text-align:right;">#TLFormat(TUTAR,2)#</td>
<td data-at-col="TUTAR_TL" data-at-val="#encodeForHTMLAttribute(TUTAR_TL)#" style="text-align:right;"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td>
</tr></cfoutput></cfsavecontent>
<div class="credit-money-table"><cf_ada_table type="2" head="#credit_dist_head#" rows="#credit_dist_rows#" title="#credit_dist_currency# — Yıllık Dağılım" show_totals="1" total_columns="#credit_dist_currency_totals#" page_size="24" name="credit_dist_year_table_#credit_dist_index#"></div>
<section class="credit-pdf-distribution" data-graph="<cfoutput>credit_dist_year_#credit_dist_index#</cfoutput>" style="display:none;">
        <cfoutput><h2>#encodeForHTML(credit_dist_currency)# — Yıllık Kalan Ödeme Dağılımı</h2></cfoutput>
        <div class="credit-distribution-image"></div><cfset credit_pdf_dist_missing = 0><cfloop query="credit_dist_year"><cfset credit_pdf_dist_missing += credit_dist_year.KUR_EKSIK></cfloop>
<cfset credit_pdf_dist_incomplete = credit_pdf_dist_missing gt 0 ? "TUTAR_TL" : "">
<cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["TUTAR"] = 0>
<cfset credit_pdf_sums["TUTAR_TL"] = 0>
<cfloop query="credit_dist_year">
<cfif isNumeric(credit_dist_year.TUTAR)><cfset credit_pdf_sums["TUTAR"] += credit_dist_year.TUTAR></cfif>
<cfif isNumeric(credit_dist_year.TUTAR_TL)><cfset credit_pdf_sums["TUTAR_TL"] += credit_dist_year.TUTAR_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR"],2)#</cfif></td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR_TL")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR_TL"],2)# TL</cfif></td>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_7_head"><tr><th>Dönem</th><th>Kalan Ödeme</th><th>Güncel Kurla TL</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_7_rows">
        <cfoutput query="credit_dist_year"><tr><td>#DONEM#</td><td class="number">#TLFormat(TUTAR,2)#</td><td class="number"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td></tr></cfoutput>
        <cfoutput>#credit_pdf_foot#</cfoutput></cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_7_head#" rows="#credit_ada_converted_7_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_7_#credit_dist_index#_pdf"></section>
</cfloop>
<section class="credit-pdf-distribution" data-graph="<cfif credit_distribution_missing eq 0>credit_dist_month_tl</cfif>" style="display:none;">
        <h2>Aylık Kalan Ödeme Dağılımı — Güncel Kurla TL</h2><div class="credit-distribution-image"></div>
        <cfset credit_pdf_dist_missing = 0><cfloop query="credit_distribution_month_tl"><cfset credit_pdf_dist_missing += credit_distribution_month_tl.KUR_EKSIK></cfloop>
<cfset credit_pdf_dist_incomplete = credit_pdf_dist_missing gt 0 ? "TUTAR_TL" : "">
<cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["TUTAR_TL"] = 0>
<cfloop query="credit_distribution_month_tl">
<cfif isNumeric(credit_distribution_month_tl.TUTAR_TL)><cfset credit_pdf_sums["TUTAR_TL"] += credit_distribution_month_tl.TUTAR_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR_TL")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR_TL"],2)# TL</cfif></td>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_8_head"><tr><th>Dönem</th><th>Kalan Ödeme TL</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_8_rows">
        <cfoutput query="credit_distribution_month_tl"><tr><td>#encodeForHTML(DONEM_ETIKET)#</td><td class="number"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td></tr></cfoutput>
        <cfoutput>#credit_pdf_foot#</cfoutput></cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_8_head#" rows="#credit_ada_converted_8_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_8_pdf"></section>
<section class="credit-pdf-distribution" data-graph="<cfif credit_distribution_missing eq 0>credit_dist_year_tl</cfif>" style="display:none;">
        <h2>Yıllık Kalan Ödeme Dağılımı — Güncel Kurla TL</h2><div class="credit-distribution-image"></div>
        <cfset credit_pdf_dist_missing = 0><cfloop query="credit_distribution_year_tl"><cfset credit_pdf_dist_missing += credit_distribution_year_tl.KUR_EKSIK></cfloop>
<cfset credit_pdf_dist_incomplete = credit_pdf_dist_missing gt 0 ? "TUTAR_TL" : "">
<cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["TUTAR_TL"] = 0>
<cfloop query="credit_distribution_year_tl">
<cfif isNumeric(credit_distribution_year_tl.TUTAR_TL)><cfset credit_pdf_sums["TUTAR_TL"] += credit_distribution_year_tl.TUTAR_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td class="number"><cfif listFind(credit_pdf_dist_incomplete,"TUTAR_TL")>Hesaplanamadı<cfelse>#TLFormat(credit_pdf_sums["TUTAR_TL"],2)# TL</cfif></td>
</tr></cfoutput></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_9_head"><tr><th>Dönem</th><th>Kalan Ödeme TL</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_9_rows">
        <cfoutput query="credit_distribution_year_tl"><tr><td>#DONEM#</td><td class="number"><cfif KUR_EKSIK eq 0>#TLFormat(TUTAR_TL,2)# TL<cfelse>Kur eksik</cfif></td></tr></cfoutput>
        <cfoutput>#credit_pdf_foot#</cfoutput></cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_9_head#" rows="#credit_ada_converted_9_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_9_pdf"></section>
</cfif>
</cf_box>

<cfif not get_monthly_credit_rows.recordCount>
    <cf_box title="Seçilen Dönem Ödeme Planı"><div style="padding:15px;">Seçilen dönem ve filtrelere uygun taksit bulunamadı.</div></cf_box>
<cfelse>
    <cfoutput><div style="padding:8px 10px;">
        <strong>#encodeForHTML(credit_period_label)#</strong>
        — Vadesi seçilen döneme gelen taksitler. Ödemeler #dateFormat(now(),'dd/mm/yyyy')# itibarıyladır.
    </div></cfoutput>
    <cfloop query="credit_currency_summary">
        <cfset credit_currency_code = credit_currency_summary.DOVIZ>
        <cfset credit_currency_index = credit_currency_summary.currentRow>
        <cfquery name="credit_currency_details" dbtype="query">
            SELECT * FROM get_monthly_credit_rows
            WHERE DOVIZ = <cfqueryparam cfsqltype="cf_sql_varchar" value="#credit_currency_code#">
            ORDER BY VADE, KURUM, CREDIT_NO, CREDIT_CONTRACT_ROW_ID
        </cfquery>
        <cfquery name="credit_daily_graph" dbtype="query">
            SELECT VADE_SIRA, VADE_LABEL, SUM(PLANLANAN) AS TUTAR
            FROM credit_currency_details GROUP BY VADE_SIRA, VADE_LABEL ORDER BY VADE_SIRA
        </cfquery>
        <cfquery name="credit_bank_graph" dbtype="query">
            SELECT KURUM, SUM(PLANLANAN) AS TUTAR
            FROM credit_currency_details GROUP BY KURUM ORDER BY TUTAR DESC
        </cfquery>
        <cf_box title="#credit_currency_code# — Seçilen Dönem Ödeme Özeti">
            <cfoutput>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12">
                    <div style="padding:16px;border:1px solid ##e4e8ed;border-radius:4px;margin-bottom:12px;">
                        <div>Planlanan Ödeme (#encodeForHTML(credit_currency_code)#)</div>
                        <strong style="font-size:22px;">#TLFormat(credit_currency_summary.PLANLANAN,2)#</strong>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12">
                    <div style="padding:16px;border:1px solid ##e4e8ed;border-radius:4px;margin-bottom:12px;">
                        <div>Ödenen Tutar (#encodeForHTML(credit_currency_code)#)</div>
                        <strong style="font-size:22px;color:##27824a;">#TLFormat(credit_currency_summary.ODENEN,2)#</strong>
                    </div>
                </div>
                <div class="col col-4 col-md-4 col-sm-6 col-xs-12">
                    <div style="padding:16px;border:1px solid ##e4e8ed;border-radius:4px;margin-bottom:12px;">
                        <div>Kalan Ödeme (#encodeForHTML(credit_currency_code)#)</div>
                        <strong style="font-size:22px;color:##c25336;">#TLFormat(credit_currency_summary.KALAN,2)#</strong>
                    </div>
                </div>
                <div style="clear:both;padding:0 10px 10px;">
                    #credit_currency_summary.TAKSIT_ADEDI# taksit.
                    Ödenen tutara dahil gecikme bedeli: #TLFormat(credit_currency_summary.GECIKME,2)# #encodeForHTML(credit_currency_code)#.
                    <cfif credit_currency_summary.FAZLA_ODEME gt 0>
                        Plan bileşenlerini aşan ödeme farkı: #TLFormat(credit_currency_summary.FAZLA_ODEME,2)# #encodeForHTML(credit_currency_code)#.
                    </cfif>
                </div>
            </cfoutput>
        </cf_box>
        <div class="col col-7 col-md-7 col-sm-12 col-xs-12">
            <cf_box>
                <cf_ada_graph number_format="money" query="#credit_daily_graph#" label_column="VADE_LABEL" value_column="TUTAR"
                    type="bar" title="Günlere Göre Planlanan Ödeme" subtitle="#credit_currency_code#"
                    unit="#credit_currency_code#" height="360" label_width="0" label_rotate="30"
                    color_universe="#valueList(credit_daily_graph.VADE_LABEL,'|')#" name="credit_daily_#credit_currency_index#">
            </cf_box>
        </div>
        <div class="col col-5 col-md-5 col-sm-12 col-xs-12">
            <cf_box>
                <cf_ada_graph number_format="money" query="#credit_bank_graph#" label_column="KURUM" value_column="TUTAR"
                    type="pie" title="Kurumlara Göre Planlanan Ödeme" subtitle="#credit_currency_code#"
                    unit="#credit_currency_code#" height="360"
                    color_universe="#valueList(get_credit_institutions.KURUM,'|')#" name="credit_bank_#credit_currency_index#">
            </cf_box>
        </div>
        <div style="clear:both;"></div>
        <cf_box title="#credit_currency_code# — Taksit Detayları">
            <!--- TLFormat sadece gorunume uygulanir; ada_table toplamlari ham data-at-val ile hesaplar. --->
<cfsavecontent variable="credit_detail_head">
    <tr>
        <th data-at-col="KULLANIM_TARIHI">Kullanım Tarihi</th>
        <th data-at-col="VADE">Vade</th>
        <th data-at-col="KURUM">Kurum</th>
        <th data-at-col="CREDIT_NO">Kredi No</th>
        <th data-at-col="KREDI_ACIKLAMASI">Kredi Açıklaması</th>
        <th data-at-col="KREDI_TURU">Kredi Türü</th>
        <th data-at-col="ACIKLAMA">Taksit Açıklaması</th>
        <th data-at-col="ANAPARA" data-credit-money="2">Anapara</th>
        <th data-at-col="FAIZ" data-credit-money="2">Faiz</th>
        <th data-at-col="MASRAF" data-credit-money="2">Vergi/Masraf</th>
        <th data-at-col="PLANLANAN" data-credit-money="2">Planlanan</th>
        <th data-at-col="ODENEN" data-credit-money="2">Ödenen</th>
        <th data-at-col="GECIKME" data-credit-money="2">Gecikme Bedeli</th>
        <th data-at-col="KALAN" data-credit-money="2">Kalan</th>
        <th data-at-col="FAZLA_ODEME" data-credit-money="2">Ödeme Farkı</th>
        <th data-at-col="GUNCEL_KUR" data-credit-money="4">Güncel Kur</th>
        <th data-at-col="PLANLANAN_TL" data-credit-money="2" data-credit-unit="TL">Planlanan TL</th>
        <th data-at-col="ODENEN_TL" data-credit-money="2" data-credit-unit="TL">Ödenen TL</th>
        <th data-at-col="KALAN_TL" data-credit-money="2" data-credit-unit="TL">Kalan TL</th>
        <th data-at-col="DURUM">Durum</th>
        <th data-at-col="DOVIZ">Döviz</th>
    </tr>
</cfsavecontent>
<cfsavecontent variable="credit_detail_rows">
    <cfoutput query="credit_currency_details">
        <tr>
            <td data-at-col="KULLANIM_TARIHI"><cfif isDate(KULLANIM_TARIHI)>#dateFormat(KULLANIM_TARIHI,"dd/mm/yyyy")#</cfif></td>
            <td data-at-col="VADE"><cfif isDate(VADE)>#dateFormat(VADE,"dd/mm/yyyy")#</cfif></td>
            <td data-at-col="KURUM">#encodeForHTML(KURUM)#</td>
            <td data-at-col="CREDIT_NO">#encodeForHTML(CREDIT_NO)#</td>
            <td data-at-col="KREDI_ACIKLAMASI">#encodeForHTML(KREDI_ACIKLAMASI)#</td>
            <td data-at-col="KREDI_TURU">#encodeForHTML(KREDI_TURU)#</td>
            <td data-at-col="ACIKLAMA">#encodeForHTML(ACIKLAMA)#</td>
            <td data-at-col="ANAPARA" data-at-val="#encodeForHTMLAttribute(ANAPARA)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(ANAPARA)>#TLFormat(ANAPARA,2)#</cfif></td>
            <td data-at-col="FAIZ" data-at-val="#encodeForHTMLAttribute(FAIZ)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(FAIZ)>#TLFormat(FAIZ,2)#</cfif></td>
            <td data-at-col="MASRAF" data-at-val="#encodeForHTMLAttribute(MASRAF)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(MASRAF)>#TLFormat(MASRAF,2)#</cfif></td>
            <td data-at-col="PLANLANAN" data-at-val="#encodeForHTMLAttribute(PLANLANAN)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(PLANLANAN)>#TLFormat(PLANLANAN,2)#</cfif></td>
            <td data-at-col="ODENEN" data-at-val="#encodeForHTMLAttribute(ODENEN)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(ODENEN)>#TLFormat(ODENEN,2)#</cfif></td>
            <td data-at-col="GECIKME" data-at-val="#encodeForHTMLAttribute(GECIKME)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(GECIKME)>#TLFormat(GECIKME,2)#</cfif></td>
            <td data-at-col="KALAN" data-at-val="#encodeForHTMLAttribute(KALAN)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN)>#TLFormat(KALAN,2)#</cfif></td>
            <td data-at-col="FAZLA_ODEME" data-at-val="#encodeForHTMLAttribute(FAZLA_ODEME)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(FAZLA_ODEME)>#TLFormat(FAZLA_ODEME,2)#</cfif></td>
            <td data-at-col="GUNCEL_KUR" data-at-val="#encodeForHTMLAttribute(GUNCEL_KUR)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(GUNCEL_KUR)>#TLFormat(GUNCEL_KUR,4)#</cfif></td>
            <td data-at-col="PLANLANAN_TL" data-at-val="#encodeForHTMLAttribute(PLANLANAN_TL)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(PLANLANAN_TL)>#TLFormat(PLANLANAN_TL,2)# TL<cfelse>Kur eksik</cfif></td>
            <td data-at-col="ODENEN_TL" data-at-val="#encodeForHTMLAttribute(ODENEN_TL)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(ODENEN_TL)>#TLFormat(ODENEN_TL,2)# TL<cfelse>Kur eksik</cfif></td>
            <td data-at-col="KALAN_TL" data-at-val="#encodeForHTMLAttribute(KALAN_TL)#" style="text-align:right;white-space:nowrap;"><cfif isNumeric(KALAN_TL)>#TLFormat(KALAN_TL,2)# TL<cfelse>Kur eksik</cfif></td>
            <td data-at-col="DURUM">#encodeForHTML(DURUM)#</td>
            <td data-at-col="DOVIZ">#encodeForHTML(DOVIZ)#</td>
        </tr>
    </cfoutput>
</cfsavecontent>
<div class="credit-money-table" data-credit-incomplete-columns="<cfif credit_currency_summary.KUR_EKSIK gt 0>PLANLANAN_TL,ODENEN_TL,KALAN_TL</cfif>">
    <cf_ada_table type="2" head="#credit_detail_head#" rows="#credit_detail_rows#"
        show_totals="1"
        total_columns="ANAPARA,FAIZ,MASRAF,PLANLANAN,ODENEN,GECIKME,KALAN,FAZLA_ODEME,PLANLANAN_TL,ODENEN_TL,KALAN_TL"
        page_size="20"
        name="credit_detail_#credit_currency_index#">
</div><cfif credit_currency_summary.KUR_EKSIK gt 0><p style="padding:8px 10px;">* İşaretli TL toplamları güncel kuru eksik kayıtlar hariç hesaplanabilen değerleri kapsar.</p></cfif>
        </cf_box>
        <!--- PDF: sayfalama ve tablo ici aramadan bagimsiz, filtrelenmis tum taksitler. --->
        <cfoutput>
        <section class="credit-pdf-source" data-index="#credit_currency_index#" style="display:none;">
            <h2>#encodeForHTML(credit_currency_code)# — Seçilen Dönem Ödeme Özeti</h2>
            <p>#encodeForHTML(credit_period_label)#.
                Ödemeler #dateFormat(now(),'dd/mm/yyyy')# itibarıyladır.</p>
            <cfsavecontent variable="credit_ada_converted_10_head"><tr><th>Planlanan</th><th>Ödenen</th><th>Kalan</th><th>Gecikme Bedeli</th><th>Ödeme Farkı</th></tr></cfsavecontent>
<cfsavecontent variable="credit_ada_converted_10_rows">
                <tr><td>#TLFormat(credit_currency_summary.PLANLANAN,2)#</td><td>#TLFormat(credit_currency_summary.ODENEN,2)#</td><td>#TLFormat(credit_currency_summary.KALAN,2)#</td><td>#TLFormat(credit_currency_summary.GECIKME,2)#</td><td>#TLFormat(credit_currency_summary.FAZLA_ODEME,2)#</td></tr>
            </cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_10_head#" rows="#credit_ada_converted_10_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_10_#credit_currency_index#_pdf">
            <div class="credit-pdf-graphs"></div>
            <h3>Taksit Detayları (#encodeForHTML(credit_currency_code)#)</h3>
            <p>* İşaretli toplamlar güncel kuru eksik kayıtlar hariç hesaplanabilen değerleri kapsar.</p>
            </cfoutput>
<cfset credit_detail_incomplete = credit_currency_summary.KUR_EKSIK gt 0 ? "PLANLANAN_TL,ODENEN_TL,KALAN_TL" : "">
<cfset credit_pdf_sums = {}>
<cfset credit_pdf_sums["ANAPARA"] = 0>
<cfset credit_pdf_sums["FAIZ"] = 0>
<cfset credit_pdf_sums["MASRAF"] = 0>
<cfset credit_pdf_sums["PLANLANAN"] = 0>
<cfset credit_pdf_sums["ODENEN"] = 0>
<cfset credit_pdf_sums["GECIKME"] = 0>
<cfset credit_pdf_sums["KALAN"] = 0>
<cfset credit_pdf_sums["FAZLA_ODEME"] = 0>
<cfset credit_pdf_sums["PLANLANAN_TL"] = 0>
<cfset credit_pdf_sums["ODENEN_TL"] = 0>
<cfset credit_pdf_sums["KALAN_TL"] = 0>
<cfloop query="credit_currency_details">
<cfif isNumeric(credit_currency_details.ANAPARA)><cfset credit_pdf_sums["ANAPARA"] += credit_currency_details.ANAPARA></cfif>
<cfif isNumeric(credit_currency_details.FAIZ)><cfset credit_pdf_sums["FAIZ"] += credit_currency_details.FAIZ></cfif>
<cfif isNumeric(credit_currency_details.MASRAF)><cfset credit_pdf_sums["MASRAF"] += credit_currency_details.MASRAF></cfif>
<cfif isNumeric(credit_currency_details.PLANLANAN)><cfset credit_pdf_sums["PLANLANAN"] += credit_currency_details.PLANLANAN></cfif>
<cfif isNumeric(credit_currency_details.ODENEN)><cfset credit_pdf_sums["ODENEN"] += credit_currency_details.ODENEN></cfif>
<cfif isNumeric(credit_currency_details.GECIKME)><cfset credit_pdf_sums["GECIKME"] += credit_currency_details.GECIKME></cfif>
<cfif isNumeric(credit_currency_details.KALAN)><cfset credit_pdf_sums["KALAN"] += credit_currency_details.KALAN></cfif>
<cfif isNumeric(credit_currency_details.FAZLA_ODEME)><cfset credit_pdf_sums["FAZLA_ODEME"] += credit_currency_details.FAZLA_ODEME></cfif>
<cfif isNumeric(credit_currency_details.PLANLANAN_TL)><cfset credit_pdf_sums["PLANLANAN_TL"] += credit_currency_details.PLANLANAN_TL></cfif>
<cfif isNumeric(credit_currency_details.ODENEN_TL)><cfset credit_pdf_sums["ODENEN_TL"] += credit_currency_details.ODENEN_TL></cfif>
<cfif isNumeric(credit_currency_details.KALAN_TL)><cfset credit_pdf_sums["KALAN_TL"] += credit_currency_details.KALAN_TL></cfif>
</cfloop>
<cfsavecontent variable="credit_pdf_foot"><cfoutput><tr>
<td>Genel Toplam</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td class="number">#TLFormat(credit_pdf_sums["ANAPARA"],2)#<cfif listFind(credit_detail_incomplete,"ANAPARA")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["FAIZ"],2)#<cfif listFind(credit_detail_incomplete,"FAIZ")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["MASRAF"],2)#<cfif listFind(credit_detail_incomplete,"MASRAF")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["PLANLANAN"],2)#<cfif listFind(credit_detail_incomplete,"PLANLANAN")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["ODENEN"],2)#<cfif listFind(credit_detail_incomplete,"ODENEN")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["GECIKME"],2)#<cfif listFind(credit_detail_incomplete,"GECIKME")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN"],2)#<cfif listFind(credit_detail_incomplete,"KALAN")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["FAZLA_ODEME"],2)#<cfif listFind(credit_detail_incomplete,"FAZLA_ODEME")> *</cfif></td>
<td></td>
<td class="number">#TLFormat(credit_pdf_sums["PLANLANAN_TL"],2)# TL<cfif listFind(credit_detail_incomplete,"PLANLANAN_TL")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["ODENEN_TL"],2)# TL<cfif listFind(credit_detail_incomplete,"ODENEN_TL")> *</cfif></td>
<td class="number">#TLFormat(credit_pdf_sums["KALAN_TL"],2)# TL<cfif listFind(credit_detail_incomplete,"KALAN_TL")> *</cfif></td>
<td></td>
<td></td>
</tr></cfoutput></cfsavecontent>
<cfoutput><cfsavecontent variable="credit_ada_converted_11_head">#credit_detail_head#</cfsavecontent>
<cfsavecontent variable="credit_ada_converted_11_rows">#credit_detail_rows##credit_pdf_foot#</cfsavecontent>
<cf_ada_table type="2" head="#credit_ada_converted_11_head#" rows="#credit_ada_converted_11_rows#" show_totals="0" is_excel="1" name="credit_ada_converted_11_#credit_currency_index#_pdf"></cfoutput>
        </section>
    </cfloop>
</cfif>

</cfif><!--- Yonetici / standart gorunum sonu --->
<script type="text/javascript">
    // ada_table arama/sayfalama sonrasinda toplam satirlarini yeniden uretir.
    // Sunucudaki TLFormat ile ayni Turkce para gorunumu yalnizca bu raporun
    // dinamik toplamlarina uygulanir; kaynak sayilar ve taksit adetleri degismez.
    (function () {
        function initCreditMoneyTotals() {
            var wrappers = document.querySelectorAll('.credit-money-table');
            var moneyFormat = new Intl.NumberFormat('tr-TR', {
                minimumFractionDigits: 2, maximumFractionDigits: 2
            });
            Array.prototype.forEach.call(wrappers, function (wrapper) {
                var table = wrapper.querySelector('table');
                if (!table || !table.tHead || !table.tFoot) return;
                var foot = table.tFoot;
                var incompleteColumns = (wrapper.getAttribute('data-credit-incomplete-columns') || '').split(',');
                var observer;
                function formatTotals() {
                    if (observer) observer.disconnect();
                    var headers = table.tHead.rows[0].cells;
                    Array.prototype.forEach.call(foot.rows, function (row) {
                        Array.prototype.forEach.call(headers, function (head, index) {
                            var cell = row.cells[index];
                            if (!cell) return;
                            var incomplete = incompleteColumns.indexOf(head.getAttribute('data-at-col')) !== -1;
                            if (!head.hasAttribute('data-credit-money') && !incomplete) return;
                            var raw = cell.getAttribute('data-credit-total');
                            if (raw === null) raw = cell.textContent.trim();
                            if (!raw) return;
                            var value = Number(raw);
                            if (!Number.isFinite(value)) return;
                            cell.setAttribute('data-credit-total', raw);
                            cell.textContent = (head.hasAttribute('data-credit-money') ? moneyFormat.format(value) : String(value)) + (head.getAttribute('data-credit-unit') ? ' ' + head.getAttribute('data-credit-unit') : '') + (incomplete ? ' *' : '');
                            if (incomplete) cell.title = 'Yalnızca hesaplanabilen değerler toplanmıştır; eksik bilgiler dahil değildir.';
                            cell.style.textAlign = 'right';
                            cell.style.whiteSpace = 'nowrap';
                        });
                    });
                    if (observer) observer.observe(foot, { childList: true, subtree: true });
                }
                observer = new MutationObserver(formatTotals);
                formatTotals();
            });
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initCreditMoneyTotals);
        } else {
            initCreditMoneyTotals();
        }
    }());

    function creditMonthlyPdf() {
        if (document.getElementById("creditExecutive")) { creditExecutivePdf(); return; }
        var sources = document.querySelectorAll('.credit-pdf-source');
        var general = document.querySelectorAll('.credit-pdf-general');
        if (!sources.length && !general.length) {
            alert('PDF için raporda en az bir taksit bulunmalıdır.');
            return;
        }
        var summary = document.querySelector('.credit-tl-summary');
        var body = summary ? summary.outerHTML : '';
        var completionFilter = document.getElementById('hide_completed');
        if (completionFilter && completionFilter.defaultChecked) {
            body += '<p>Ödemesi bitmiş krediler hariçtir. Ödeme planı olmayan kredilerin kapanışı doğrulanamamıştır; bu kayıtlar kontrol için gösterilir.</p>';
        }
        for (var gi = 0; gi < general.length; gi++) {
            var gc = general[gi].cloneNode(true);
            gc.removeAttribute('style');
            gc.className = 'currency-section';
            body += gc.outerHTML;
        }
        for (var i = 0; i < sources.length; i++) {
            var idx = sources[i].getAttribute('data-index');
            var copy = sources[i].cloneNode(true);
            copy.removeAttribute('style');
            copy.className = 'currency-section';
            var graphArea = copy.querySelector('.credit-pdf-graphs');
            var names = ['credit_daily_' + idx, 'credit_bank_' + idx];
            for (var j = 0; j < names.length; j++) {
                var api = window.adaGraphs && window.adaGraphs[names[j]];
                var chart = api && api.getChart();
                if (!chart) {
                    alert('Grafikler henüz hazır değil. Birkaç saniye sonra tekrar deneyiniz.');
                    return;
                }
                try {
                    var img = document.createElement('img');
                    img.src = chart.getDataURL({type:'png', pixelRatio:2, backgroundColor:'#fff'});
                    img.alt = j === 0 ? 'Günlere göre planlanan ödeme' : 'Kurumlara göre planlanan ödeme';
                    graphArea.appendChild(img);
                } catch (e) {
                    alert('Grafik PDF çıktısına aktarılamadı. Sayfayı yenileyip tekrar deneyiniz.');
                    return;
                }
            }
            body += copy.outerHTML;
        }
        var distributions = document.querySelectorAll('.credit-pdf-distribution');
        for (var di = 0; di < distributions.length; di++) {
            var distribution = distributions[di].cloneNode(true);
            distribution.removeAttribute('style');
            distribution.className = 'currency-section';
            var graphName = distribution.getAttribute('data-graph');
            if (graphName) {
                var distApi = window.adaGraphs && window.adaGraphs[graphName];
                var distChart = distApi && distApi.getChart();
                if (!distChart) {
                    alert('Dağılım grafikleri henüz hazır değil. Birkaç saniye sonra tekrar deneyiniz.');
                    return;
                }
                try {
                    var distImage = document.createElement('img');
                    distImage.src = distChart.getDataURL({type:'png', pixelRatio:2, backgroundColor:'#fff'});
                    distImage.style.width = '100%';
                    distribution.querySelector('.credit-distribution-image').appendChild(distImage);
                } catch (e) {
                    alert('Dağılım grafiği PDF çıktısına aktarılamadı.');
                    return;
                }
            }
            body += distribution.outerHTML;
        }
        var w = window.open('', '_blank');
        if (!w) {
            alert('PDF penceresi engellendi. Bu site için açılır pencerelere izin veriniz.');
            return;
        }
        var css = '@page{size:A4 landscape;margin:10mm}body{font:10px Arial,sans-serif;color:#222}' +
            'h1{font-size:19px}h2{font-size:15px}h3{font-size:12px}' +
            'table{width:100%;border-collapse:collapse;font-size:8px;table-layout:auto}' +
            'th,td{border:1px solid #ccd2da;padding:5px 3px;overflow-wrap:anywhere;vertical-align:top}' +
            'th{background:#eef2f6;text-align:left}td.number{text-align:right;white-space:nowrap}' +
            'thead{display:table-header-group}tr{break-inside:avoid}' +
            '.summary{font-size:12px;margin-bottom:12px}.summary td{text-align:right}' +
            '.credit-pdf-graphs{display:flex;align-items:center;break-inside:avoid;margin:12px 0}' +
            '.credit-pdf-graphs img{width:50%;height:auto;object-fit:contain}' +
            '.currency-section{break-before:page}.currency-section:first-of-type{break-before:auto}' +
            '.print-button{margin-bottom:12px;padding:8px 14px;cursor:pointer}' +
            '@media print{.print-button{display:none}}';
        w.document.open();
        w.document.write('<!doctype html><html lang="tr"><head><meta charset="utf-8"><title>Kredi Ödeme Raporu</title><style>' + css + '</style></head><body><button class="print-button" onclick="window.print()">Yazdır / PDF Kaydet</button><h1>Kredi Ödeme Raporu</h1>' + body + '</body></html>');
        w.document.close();
        var images = w.document.images;
        var ready = [];
        for (var k = 0; k < images.length; k++) {
            ready.push(new Promise(function(resolve) {
                var img = images[k];
                if (img.complete) resolve();
                else { img.onload = resolve; img.onerror = resolve; }
            }));
        }
        Promise.all(ready).then(function() {
            setTimeout(function() { if (!w.closed) { w.focus(); w.print(); } }, 250);
        });
    }

    function creditSelectMonth() {
        var month = document.getElementById('report_month');
        if (!month.value) return;
        document.getElementById('report_start_date').value = '';
        document.getElementById('report_end_date').value = '';
        var year = document.getElementById('report_year');
        if (!year.value) year.value = String(new Date().getFullYear());
    }
    function creditSelectYear() {
        if (document.getElementById('report_month').value) creditSelectMonth();
    }
    function creditSelectRange() {
        if (!document.getElementById('report_start_date').value && !document.getElementById('report_end_date').value) return;
        document.getElementById('report_month').value = '';
        document.getElementById('report_year').value = '';
    }
    function creditParseFilterDate(value) {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
        var parts = value.split('-').map(Number);
        if (parts[0] < 1900 || parts[0] > 2100) return null;
        var date = new Date(Date.UTC(parts[0], parts[1]-1, parts[2]));
        return date.getUTCFullYear() === parts[0] && date.getUTCMonth() === parts[1]-1 && date.getUTCDate() === parts[2] ? date : null;
    }
    function creditMonthlyFilterControl() {
        var start = document.getElementById('report_start_date');
        var end = document.getElementById('report_end_date');
        var month = document.getElementById('report_month');
        var year = document.getElementById('report_year');
        if (start.value || end.value) {
            creditSelectRange();
            var startDate = creditParseFilterDate(start.value);
            var endDate = creditParseFilterDate(end.value);
            if (!startDate || !endDate) {
                alert('Geçerli başlangıç ve bitiş tarihlerini birlikte seçiniz.');
                (!startDate ? start : end).focus();
                return false;
            }
            if (startDate.getTime() > endDate.getTime()) {
                alert('Başlangıç tarihi bitiş tarihinden sonra olamaz.');
                end.focus();
                return false;
            }
            return true;
        }
        if (!/^(?:[1-9]|1[0-2])$/.test(month.value)) {
            alert('Bir ay veya başlangıç-bitiş tarihleri seçiniz.');
            month.focus();
            return false;
        }
        if (!/^\d{4}$/.test(year.value) || Number(year.value) < 1900 || Number(year.value) > 2100) {
            alert('1900 ile 2100 arasında bir yıl giriniz.');
            year.focus();
            return false;
        }
        return true;
    }
    (function () {
        function bindCreditPeriodForm() {
            var form = document.getElementById('form_credit_monthly_report');
            if (form) form.addEventListener('submit', function (event) {
                if (!creditMonthlyFilterControl()) {
                    event.preventDefault();
                    event.stopImmediatePropagation();
                }
            }, true);
        }
        if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bindCreditPeriodForm);
        else bindCreditPeriodForm();
    }());
</script>
<script>
(function () {
    function initExecutiveCharts(attempt) {
        if (!document.getElementById('creditExecutive')) return;
        var entry = window.adaGraphs && window.adaGraphs.credit_exec_bank;
        var chart = entry && entry.getChart();
        if (!chart) { if (attempt < 100) setTimeout(function () { initExecutiveCharts(attempt + 1); }, 100); return; }
        var old = chart.getOption();
        var source = old.series && old.series[0];
        if (!source || !old.xAxis || !old.xAxis[0]) return;
        var labels = old.xAxis[0].data || [];
        chart.setOption({
            textStyle: {fontFamily:'Arial, sans-serif',fontSize:12,color:'#475569'},
            title: {text:'Kurumlara Ödenecek Kalan',textStyle:{fontSize:15}},
            grid: {left:12,right:30,top:55,bottom:25,containLabel:true},
            tooltip: {trigger:'axis',axisPointer:{type:'shadow'},formatter:function (items) {
                var p=items[0]; var v=(typeof p.value==='object')?p.value.value:p.value;
                // ECharts tooltip receives HTML; escape institution names before insertion.
                var label=String(p.name).replace(/[&<>"']/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c];});
                return label+'<br>'+entry.formatValue(v);
            }},
            xAxis:{type:'value',axisLabel:{fontSize:12,color:'#475569',formatter:function(v){return entry.formatNumber(v);}}},
            yAxis:{type:'category',data:labels,inverse:true,axisLabel:{width:200,overflow:'break',fontSize:12,lineHeight:16,color:'#475569'}},
            series:[{type:'bar',data:source.data,barMaxWidth:22,itemStyle:{borderRadius:[0,4,4,0]}}]
        },true);
        chart.resize();
    }
    if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',function(){initExecutiveCharts(0);});
    else initExecutiveCharts(0);
}());
function creditExecutivePdf() {
    var original=document.getElementById('creditExecutive');
    if(!original) return;
    var copy=original.cloneNode(true);
    copy.querySelectorAll('script').forEach(function(s){s.remove();});
    // PDF includes every server-filtered row, independently of ada_table pagination/search.
    copy.querySelectorAll('[data-exec-table]').forEach(function(target) {
        var key=target.getAttribute('data-exec-table');
        var source=Array.from(copy.querySelectorAll('template[data-exec-table-source]')).find(function(t){
            return t.getAttribute('data-exec-table-source')===key;
        });
        if(source) target.replaceChildren(source.content.cloneNode(true));
    });
    copy.querySelectorAll('template[data-exec-table-source]').forEach(function(t){t.remove();});

    var originals=original.querySelectorAll('[data-exec-graph]');
    var targets=copy.querySelectorAll('[data-exec-graph]');
    for(var i=0;i<originals.length;i++) {
        var name=originals[i].getAttribute('data-exec-graph');
        var api=window.adaGraphs && window.adaGraphs[name];
        var chart=api && api.getChart();
        if(!chart){alert('Grafikler henüz hazır değil. Biraz sonra tekrar deneyiniz.');return;}
        try {
            var img=document.createElement('img');
            img.src=chart.getDataURL({type:'png',pixelRatio:2,backgroundColor:'#fff'});
            targets[i].replaceChildren(img);
        } catch(e){alert('Grafik PDF çıktısına aktarılamadı.');return;}
    }
    var w=window.open('','_blank');
    if(!w){alert('PDF için bu siteye açılır pencere izni veriniz.');return;}
    var css=document.getElementById('creditExecutiveStyle').textContent;
    w.document.open();
    w.document.write('<!doctype html><html lang="tr"><head><meta charset="utf-8"><title>Kredi Yönetici Özeti</title><style>'+css+'@page{size:A4 landscape;margin:10mm}body{margin:0;background:white}*{-webkit-print-color-adjust:exact;print-color-adjust:exact}.ce-print-button{padding:10px 16px;margin:10px}</style></head><body><button class="ce-print-button" onclick="window.print()">Yazdır / PDF Kaydet</button>'+copy.outerHTML+'</body></html>');
    w.document.close();
    Promise.all(Array.from(w.document.images).map(function(img){return new Promise(function(resolve){if(img.complete) resolve();else {img.onload=resolve;img.onerror=resolve;}});})).then(function(){setTimeout(function(){if(!w.closed){w.focus();w.print();}},250);});
}
</script>
