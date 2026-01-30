<!--- 
    Date : 30.01.2026
    Desc : Gelen E-Faturaların, Fatura ya da Masraf fişi bağlantısı varsa koparır ve loglar.
    Dev  : Yunus Emre Yazıcı @Gramoni
--->


<cfparam name="attributes.report_id" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.form_submitted" default="0">
<cfparam name="attributes.unlink_submitted" default="0">

<cfquery name="ensure_unlink_log_table" datasource="#dsn2#">
    IF OBJECT_ID('EINVOICE_UNLINK_LOG', 'U') IS NULL
    BEGIN
        CREATE TABLE EINVOICE_UNLINK_LOG
        (
            LOG_ID              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            RECEIVING_DETAIL_ID INT NOT NULL,
            OLD_INVOICE_ID      INT NULL,
            OLD_EXPENSE_ID      INT NULL,
            OLD_STATUS          NVARCHAR(100) NULL,
            OLD_IS_PROCESS      INT NULL,
            UNLINKED_BY         INT NULL,
            UNLINKED_AT         DATETIME NOT NULL DEFAULT(GETDATE()),
            CLIENT_IP           NVARCHAR(64) NULL,
            NOTE                NVARCHAR(500) NULL
        );
        CREATE INDEX IX_EINVOICE_UNLINK_LOG_RDID ON EINVOICE_UNLINK_LOG(RECEIVING_DETAIL_ID);
        CREATE INDEX IX_EINVOICE_UNLINK_LOG_AT ON EINVOICE_UNLINK_LOG(UNLINKED_AT);
    END
</cfquery>

<cfset get_einv = QueryNew("RECEIVING_DETAIL_ID,INVOICE_ID,EXPENSE_ID,PARTY_NAME,STATUS,IS_PROCESS,STATUS_CODE,STATUS_DESCRIPTION")>

<cfif attributes.unlink_submitted>
    <cfparam name="attributes.total_rows" default="0">
    <cftransaction>
        <cfloop from="1" to="#val(attributes.total_rows)#" index="i">
            <cfset k = "rd_#i#">
            <cfif structKeyExists(attributes, k) AND len(attributes[k])>
                <cfset selected_rd_id = val(attributes[k])>
                
                <cfquery name="get_old" datasource="#dsn2#">
                    SELECT 
                        RECEIVING_DETAIL_ID, 
                        INVOICE_ID, 
                        EXPENSE_ID, 
                        STATUS, 
                        IS_PROCESS
                    FROM 
                        EINVOICE_RECEIVING_DETAIL
                    WHERE 
                        RECEIVING_DETAIL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#selected_rd_id#">
                </cfquery>

                <cfquery name="upd_unlink" datasource="#dsn2#">
                    UPDATE 
                        EINVOICE_RECEIVING_DETAIL
                    SET 
                        STATUS      = NULL,
                        IS_PROCESS  = NULL,
                        INVOICE_ID  = NULL,
                        EXPENSE_ID  = NULL
                    WHERE 
                        RECEIVING_DETAIL_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#selected_rd_id#">
                </cfquery>

                <cfif isDefined("upd_unlink") AND upd_unlink.recordCount GT 0>
                    <cfquery name="ins_unlink_log" datasource="#dsn2#">
                        INSERT INTO 
                            EINVOICE_UNLINK_LOG
                        (
                            RECEIVING_DETAIL_ID, 
                            OLD_INVOICE_ID, 
                            OLD_EXPENSE_ID, 
                            OLD_STATUS, 
                            OLD_IS_PROCESS, 
                            UNLINKED_BY, 
                            CLIENT_IP, 
                            NOTE
                        )
                        VALUES
                        (
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#selected_rd_id#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#(get_old.recordCount ? val(get_old.INVOICE_ID) : 0)#" null="#(get_old.recordCount AND len(get_old.INVOICE_ID) ? 0 : 1)#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#(get_old.recordCount ? val(get_old.EXPENSE_ID) : 0)#" null="#(get_old.recordCount AND len(get_old.EXPENSE_ID) ? 0 : 1)#">,
                            <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#(get_old.recordCount ? toString(get_old.STATUS) : '')#" null="#(get_old.recordCount AND len(toString(get_old.STATUS)) ? 0 : 1)#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#(get_old.recordCount ? val(get_old.IS_PROCESS) : 0)#" null="#(get_old.recordCount AND len(get_old.IS_PROCESS) ? 0 : 1)#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#(isDefined('session.ep.userid') ? session.ep.userid : 0)#">,
                            <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#CGI.REMOTE_ADDR#">,
                            <cfqueryparam cfsqltype="cf_sql_nvarchar" value="Rapor ekranından e-fatura bağlantısı koparıldı">
                        )
                    </cfquery>
                </cfif>
            </cfif>
        </cfloop>
    </cftransaction>

    <script type="text/javascript">
        alert("Seçilen kayıtların bağlantısı başarıyla koparıldı.");
    </script>
    <cfset attributes.form_submitted = 1>
</cfif>

<cfif attributes.form_submitted AND len(trim(attributes.keyword))>
    <cfquery name="get_einv" datasource="#dsn2#">
        SELECT 
            EINVOICE_ID, 
            INVOICE_ID, 
            EXPENSE_ID, 
            RECEIVING_DETAIL_ID, 
            PARTY_NAME, 
            STATUS, 
            IS_PROCESS, 
            STATUS_CODE, 
            STATUS_DESCRIPTION
        FROM 
            EINVOICE_RECEIVING_DETAIL
        WHERE 
            EINVOICE_ID = <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#trim(attributes.keyword)#">
        ORDER BY 
            RECEIVING_DETAIL_ID DESC
    </cfquery>
</cfif>

<div class="col col-12">
    <cfform name="main_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#&event=det&report_id=#url.report_id#">
        <input type="hidden" name="form_submitted" value="1">
        <input type="hidden" name="unlink_submitted" id="unlink_submitted" value="0">
        <input type="hidden" name="has_selection" id="has_selection" value="0">
        <input type="hidden" name="total_rows" value="<cfoutput>#get_einv.recordCount#</cfoutput>">
        <cf_box>
            <cf_box_search>
                <div class="form-group">
                    <input type="text" name="keyword" id="keyword" value="<cfoutput>#attributes.keyword#</cfoutput>" placeholder="Fatura No (ETTN) Giriniz...">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button button_type="4">
                </div>
            </cf_box_search>
        </cf_box>
        <cf_box title="Gelen E-Fatura Kayıtları" uidrop="1" hide_table_column="1">
            <cf_grid_list>
                <thead>
                    <tr>
                        <th>Fatura No</th>
                        <th>Şirket</th>
                        <th>Statü</th>
                        <th>Bağlantı Durumu</th>
                        <th>Bağlı Fatura ID</th>
                        <th>Bağlı Masraf ID</th>
                        <th>Seç</th>
                    </tr>
                </thead>
                <tbody>
                    <cfif get_einv.recordCount>
                        <cfoutput query="get_einv">
                            <cfset hasInvoice = len(INVOICE_ID) GT 0>
                            <cfset hasExpense = len(EXPENSE_ID) GT 0>
                            <cfset hasRelation = (hasInvoice OR hasExpense)>
                            <tr>
                                <td>#EINVOICE_ID#</td>
                                <td>#PARTY_NAME#</td>
                                <td>#STATUS_DESCRIPTION#</td>
                                <td style="text-align:center;">
                                    <cfif hasRelation>
                                        <span style="color:green; font-weight:bold;">
                                            <i class="fa fa-link"></i> BAĞLI
                                        </span>
                                    <cfelse>
                                        <span style="color:##999;">
                                            <i class="fa fa-unlink"></i> Yok
                                        </span>
                                    </cfif>
                                </td>
                                <td style="text-align:center;">
                                    <cfif hasInvoice>
                                        <strong>#INVOICE_ID#</strong>
                                    <cfelse>
                                        -
                                    </cfif>
                                </td>

                                <td style="text-align:center;">
                                    <cfif hasExpense>
                                        <strong>#EXPENSE_ID#</strong>
                                    <cfelse>
                                        -
                                    </cfif>
                                </td>

                                <td style="text-align:center;">
                                    <input type="checkbox" name="rd_#currentRow#" id="rd_#currentRow#" value="#RECEIVING_DETAIL_ID#" onclick="onRdClick(this);" <cfif NOT hasRelation>disabled</cfif>>
                                </td>
                            </tr>
                        </cfoutput>
                    <cfelse>
                        <tr>
                            <td colspan="7" style="text-align:center;">
                                <cfif len(attributes.keyword)>
                                    Kayıt bulunamadı.
                                <cfelse>
                                    Lütfen filtreleyiniz.
                                </cfif>
                            </td>
                        </tr>
                    </cfif>
                </tbody>
            </cf_grid_list>
            
            <cfif get_einv.recordCount>
                <div style="margin-top:10px; text-align:right;">
                    <button type="button" class="btn btn-danger" onclick="submitUnlinkAction();">Bağlantıyı Kopar</button>
                </div>
            </cfif>
        </cf_box>
    </cfform>
</div>

<script type="text/javascript">
    function onRdClick(element) {
        var inputs = document.getElementsByTagName("input");
        var hasSelection = 0;
        for(var i = 0; i < inputs.length; i++) {
            if(inputs[i].type == "checkbox" && inputs[i].name.indexOf("rd_") === 0) {
                if(inputs[i].checked) { hasSelection = 1; break; }
            }
        }
        document.getElementById("has_selection").value = hasSelection;
    }

    function submitUnlinkAction() {
        var hasSel = document.getElementById("has_selection").value;
        
        if(hasSel != "1") {
            alert("En az 1 kayıt seçiniz!");
            return false;
        }

        if(confirm("DİKKAT! Seçili kayıtların fatura/masraf bağlantıları KOPARILACAK.\nBu işlem geri alınamaz. Devam etmek istiyor musunuz?")) {
            document.getElementById("unlink_submitted").value = "1";
            document.main_form.submit();
        }
    }
</script>