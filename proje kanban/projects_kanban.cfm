<cf_xml_page_edit fuseact="project.project_kanban">
<cfquery name="get_user_group" datasource="#dsn#">
    SELECT
		UG.USER_GROUP_ID,
    	USER_GROUP_NAME,
		UGE.EMPLOYEE_ID,
		E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS EMP_NAME
	FROM 
		USER_GROUP UG,
		USER_GROUP_EMPLOYEE UGE,
		EMPLOYEES E
	WHERE
		UG.USER_GROUP_ID = UGE.USER_GROUP_ID
		AND
		E.EMPLOYEE_ID = UGE.EMPLOYEE_ID
		AND
        UG.USER_GROUP_ID IN(<cfqueryparam cfsqltype="cf_sql_integer" value="#xml_user_group#" list="yes">) --- yetki grup id'lerine göre kontrol ediyor.
        AND
        UGE.EMPLOYEE_ID = #session.ep.userid#
</cfquery>

<cfparam name="attributes.priority_cat" default="">
<cfparam name="attributes.activity_id" default="">
<cfparam name="attributes.currency" default="">
<cfparam name="attributes.pro_employee" default="">
<cfparam name="attributes.pro_employee_id" default="">
<cfparam name="attributes.workgroup_id" default="">
<cfparam name="attributes.target_start" default="">
<cfparam name="attributes.target_finish" default="">
<cfparam name="attributes.work_cat" default="">
<cfparam name="attributes.is_milestone" default="0">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.sort_type" default="0">
<cfparam name="attributes.time_interval" default="">
<cfparam name="attributes.startrow" default="1">
<cfparam name="attributes.day_type" default="0">
<cfparam name="attributes.roles_id" default="">
<cfparam name="attributes.is_empty" default="">
<cfparam name="attributes.project_cat" default="">
<cfif isdefined("attributes.target_start") and isdate(attributes.target_start)>
    <cf_date tarih = "attributes.target_start">
</cfif>
<cfif isdefined("attributes.target_finish") and isdate(attributes.target_finish)>
    <cf_date tarih = "attributes.target_finish">
</cfif>
<cfif isdefined("attributes.id") and len(attributes.id)>
  <cfset attributes.project_id = attributes.id>
  <cfset attributes.project_head = get_project_name(attributes.project_id)>
  <cfset attributes.is_submitted = 1>
</cfif>

<cfquery name="get_stage" datasource="#DSN#">
    SELECT 
        PTR.STAGE,
        PTR.PROCESS_ROW_ID
    FROM
        erp_visiott.erp_visiott.PROCESS_TYPE_ROWS PTR,
        erp_visiott.erp_visiott.PROCESS_TYPE_OUR_COMPANY PTO,
        erp_visiott.erp_visiott.PROCESS_TYPE PT
    WHERE
        PT.IS_ACTIVE = 1 AND
        PT.PROCESS_ID = PTR.PROCESS_ID AND
        PT.PROCESS_ID = PTO.PROCESS_ID AND
        PTO.OUR_COMPANY_ID = 1 AND
        PT.FACTION LIKE '%project.projects%'
        <cfif len(attributes.currency)>
            AND PTR.PROCESS_ROW_ID IN (#attributes.currency#)
        </cfif>
    ORDER BY
        PTR.PROCESS_ID DESC,
        PTR.LINE_NUMBER
</cfquery>
<cfquery name="get_project_categories" datasource="#DSN#">
    SELECT 
		MAIN_PROCESS_CAT_ID, 
		MAIN_PROCESS_CAT
    FROM 
		SETUP_MAIN_PROCESS_CAT
    ORDER BY 
		MAIN_PROCESS_CAT
</cfquery>

<!-- SortableJS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/Sortable/1.15.0/Sortable.min.js"></script>

<style>
    :root {
        /* 1rem = 16px varsayılan */
        font-size: 16px;
    }

    /* Kanban Container (tüm sütunları saran) */
    .kanban-container {
        display: flex;
        gap: 2%;
        width: 100%;
        <!---
        margin: 2% auto;  /* Üst/alt %2, soldan sağdan ortalama */
        --->
        box-sizing: border-box;
        /* Sütun yükseklikleri bağımsız olsun */
        align-items: flex-start; 
        /* Çok sütun varsa yatay kaydırma için:*/
        flex-wrap: nowrap;
        overflow-x: auto; 
    }

    /* Kanban Sütunları */
    .kanban-column {
        flex: 0 0 15%;
        background: #f3f3f3;
        border-radius: 0.5rem;
        display: flex;
        flex-direction: column;
        box-sizing: border-box;
        box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
    }

    /* Sütun Başlığı */
    .kanban-header {
        background: #2c3e50;
        color: #fff;
        padding: 2%;
        border-radius: 1rem 1rem 0 0;
        font-size: 1rem;
        text-align: center;
    }

    /* Kartların bulunduğu alan */
    .kanban-items {
        padding: 2%;
        display: flex;
        flex-direction: column;
        gap: 2%;
        box-sizing: border-box;
    }

    /* Kart Tasarımı */
    .kanban-card {
        background: #fff;
        border: 0.1rem solid #ddd;
        border-radius: 0.5rem;
        padding: 2%;
        display: flex;
        flex-direction: column;
        gap: 5%;
        cursor: grab;
        transition: transform 0.2s, box-shadow 0.2s;
        position: relative;
    }
    .kanban-card:hover {
        transform: scale(1.02);
        box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.1);
    }
    .card-title {
    font-weight: bold;
    margin: 0;
    text-align: center !important;
    }

    .card-details {
        display: flex;
        flex-wrap: wrap;
        gap: 4%;
        font-size: 0.8rem;
        <!---
        background-color: rgb(0, 153, 255);
        --->
    }

    .card-details .detail {
        display: flex;
        align-items: center;
        gap: 0.5rem;
        <!---
        background: #f9f9f9;
        --->
        padding: 3% 0%;
        border-radius: 0.3rem;
    }
    .card-details .detail i {
        font-size: 0.8rem;
        color: #777;
        padding: 3% 0%;
    }

    .assignee-avatar {
        width: 12%;
        height: auto;
        border-radius: 50%;
        object-fit: cover;
        border: 0.05rem solid #ccc;
        min-width: 1.2rem; /* Aşırı daralmayı engeller */
    }

    /* Durum etiketi */
    .status-badge {
        font-size: 0.7rem;
        color: #fff;
        text-transform: uppercase;
    }
    .status-progress { background: #e67e22; }
    .status-review   { background: #2980b9; }
    .status-done     { background: #27ae60; }

    /* Farklı başlıklar için renkler */
    .header1  { background: #ff6961; }
    .header2  { background: #feca57; }
    .header3  { background: #1dd1a1; }
    .header4  { background: #54a0ff; }
    .header5  { background: #8e44ad; }
    .header6  { background: #d35400; }
    .header7  { background: #2ecc71; }
    .header8  { background: #c0392b; }
    .header9  { background: #16a085; }
    .header10 { background: #2980b9; }
    .header11 { background: #e67e22; }
    .header12 { background: #f1c40f; }
    .header13 { background: #27ae60; }
    .header14 { background: #9b59b6; }
    .header15 { background: #3498db; }
    .header16 { background: #ff4757; }
    .header17 { background: #2ed573; }
    .header18 { background: #cd84f1; }
    .header19 { background: #7158e2; }
    .header20 { background: #343a40; }
</style>

<cf_box scroll="0">
    <cfform name="works" method="post" action="#request.self#?fuseaction=#listfirst(attributes.fuseaction,'.')#.project_kanban">
      <cf_box_search>
        <input type="hidden" name="is_submitted" id="is_submitted" value="1" />
        <div class="form-group" id="form_ul_pro_employee_id">
          <div class="input-group">
              <input type="hidden" name="pro_employee_id"  id="pro_employee_id" value="<cfif isdefined('attributes.pro_employee_id') and len(attributes.pro_employee)><cfoutput>#attributes.pro_employee_id#</cfoutput></cfif>">
              <input type="text" name="pro_employee" id="pro_employee"  placeholder="<cf_get_lang dictionary_id='57569.Görevli'>"  value="<cfif isdefined('attributes.pro_employee') and len(attributes.pro_employee)><cfoutput>#attributes.pro_employee#</cfoutput></cfif>" onfocus="AutoComplete_Create('pro_employee','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','pro_employee_id','','3','135');" autocomplete="off">	
              <span class="input-group-addon icon-ellipsis btnPointer" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=works.pro_employee_id&field_name=works.pro_employee&select_list=1');"></span>
          </div>
        </div>
        <div class="form-group" id="item-search_date">        
          <div class="input-group">
            <cfsavecontent variable="txt1"><cf_get_lang dictionary_id="57782.Tarih Değerini Kontrol Ediniz">!</cfsavecontent>
            <cfinput type="text" name="target_start" id="target_start" value="#dateformat(attributes.target_start, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#txt1#">
            <span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="target_start"></span>
          </div>
        </div>
        <div class="form-group" id="item-search_date"> 
          <div class="input-group">
            <cfinput type="text" name="target_finish" id="target_finish" value="#dateformat(attributes.target_finish, dateformat_style)#" validate="#validate_style#" maxlength="10" message="#txt1#">
            <span class="input-group-addon btnPointer"><cf_wrk_date_image date_field="target_finish"></span>
          </div>
        </div>
        <!---
        <div class="form-group">               
            <select name="time_interval" id="time_interval">
                <option value="-2" <cfif isdefined("attributes.time_interval") and len(attributes.time_interval) and attributes.time_interval eq '-2'>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                <option value="-1" <cfif isdefined("attributes.time_interval") and len(attributes.time_interval) and attributes.time_interval eq '-1'>selected</cfif>><cf_get_lang dictionary_id='57942.Bugün'></option>
                <option value="0" <cfif isdefined("attributes.time_interval") and len(attributes.time_interval) and attributes.time_interval eq '0'>selected</cfif>><cf_get_lang dictionary_id='58734.Bu Hafta'></option>
                <option value="1" <cfif isdefined("attributes.time_interval") and len(attributes.time_interval)and attributes.time_interval eq '1'>selected</cfif>><cf_get_lang dictionary_id='58724.Bu Ay'></option>
            </select>
        </div>
        --->
        <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
            <div class="form-group">
                <cfsavecontent variable="secmessage"><cf_get_lang dictionary_id='57482.Asama'></cfsavecontent>
                <cf_multiselect_check
                    query_name="get_stage"  
                    name="currency"
                    option_text="#secmessage#" 
                    option_value="process_row_id"
                    option_name="stage"
                    value="#iif(isdefined("attributes.currency"),"attributes.currency",DE(""))#"
                    >
            </div>
        </div>
		<div class="form-group"><!---fy--->
			<label for="project_cat">Proje Kategorisi</label>
			<select name="project_cat" id="project_cat">
				<option value="">Tümü</option>
				<cfoutput query="get_project_categories">
					<option value="#MAIN_PROCESS_CAT_ID#" <cfif attributes.project_cat eq MAIN_PROCESS_CAT_ID>selected="selected"</cfif>>#MAIN_PROCESS_CAT#</option>
				</cfoutput>
			</select>
		</div>
        <div class="form-group">       
            <select name="is_empty" id="is_empty">
              <option value="1" <cfif attributes.is_empty eq 1>selected="selected"</cfif>>Projesi Olan Aşamalar</option>
              <!---
              <option value="-1" <cfif attributes.is_empty eq -1>selected="selected"</cfif>>Projesi Olmayan Aşamalar</option>
              --->
              <option value="0" <cfif attributes.is_empty eq 0>selected="selected"</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
            </select>
          </div>
        <div class="form-group">
          <cf_wrk_search_button is_excel="0" button_type="4">
        </div>
      </cf_box_search>
    </cfform>
</cf_box>

<cf_box title="Proje Kanban">
    <div class="kanban-container">
        <cfoutput query="get_stage">
            <cfquery name="get_project" datasource="#DSN#">
				SELECT 
					PTR.STAGE AS ASAMA_ADI, 
					PTR.PROCESS_ROW_ID,
					PP.PROJECT_NUMBER AS PROJE_NO,
					PP.PROJECT_ID,
					PP.TARGET_START,
					PP.TARGET_FINISH,
					PP.PROJECT_EMP_ID,
					#DSN#.Get_Dynamic_Language(SMC.MAIN_PROCESS_CAT_ID,'tr','SETUP_MAIN_PROCESS_CAT','MAIN_PROCESS_CAT',NULL,NULL,SMC.MAIN_PROCESS_CAT) AS PROJECT_CAT,
					(SELECT   
						CASE 
							WHEN E.PHOTO IS NOT NULL AND LEN(E.PHOTO) > 0 THEN '/documents/hr/'+E.PHOTO 
							WHEN E.PHOTO IS NULL AND ED.SEX = 0 THEN '/images/female.jpg'
						ELSE '/images/male.jpg' END AS AA
						FROM 
							EMPLOYEES E,
							EMPLOYEES_DETAIL ED
						WHERE  
							E.EMPLOYEE_ID = PP.PROJECT_EMP_ID
							AND ED.EMPLOYEE_ID = E.EMPLOYEE_ID
					) AS PHOTO
				FROM
					PRO_PROJECTS PP,
					PROCESS_TYPE_ROWS PTR,
					PROCESS_TYPE_OUR_COMPANY PTO,
					PROCESS_TYPE PT,
					SETUP_MAIN_PROCESS_CAT SMC
				WHERE
					PP.PRO_CURRENCY_ID = PTR.PROCESS_ROW_ID AND
					PT.IS_ACTIVE = 1 AND
					PT.PROCESS_ID = PTR.PROCESS_ID AND
					PT.PROCESS_ID = PTO.PROCESS_ID AND
					PTO.OUR_COMPANY_ID = #session.ep.company_id# AND
					PP.PROJECT_STATUS = 1 AND
					PP.PROCESS_CAT = SMC.MAIN_PROCESS_CAT_ID AND
					PP.PRO_CURRENCY_ID = #process_row_id#
					<cfif len(attributes.project_cat)>
						AND SMC.MAIN_PROCESS_CAT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.project_cat#">
					</cfif>
                    <cfif len(attributes.pro_employee) and len(attributes.pro_employee_id)>
                        AND PP.PROJECT_EMP_ID = #attributes.pro_employee_id#
                    </cfif>
                    <cfif len(attributes.target_start)>
                        AND PP.TARGET_START >=  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.target_start#">
                    </cfif>
                    <cfif len(attributes.target_finish) and attributes.day_type eq 0>
                        AND PP.TARGET_FINISH <=  <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.target_finish#">
                    </cfif>
				ORDER BY
					PTR.PROCESS_ID DESC,
					PTR.LINE_NUMBER
			</cfquery>
            <cfif get_project.recordCount or attributes.is_empty eq 0> <!--- ilgili aşamada proje yoksa --->
                <div class="kanban-column">
                    <div class="kanban-header header#get_stage.currentRow#">#stage# (#get_project.recordCount#)</div>
                    <cfloop query="#get_project#">
                        <div class="kanban-items" data-processrowid="#get_stage.process_row_id#" id="stage_#get_stage.process_row_id#">
                            <div class="kanban-card" data-projectid="#get_project.project_id#" data-status="Progress" data-id="1">
                                <div class="card-details">
                                    <h4 class="card-title">
										<a href="https://erp.visiott.com/index.cfm?fuseaction=project.projects&event=det&id=#get_project.project_id#" target="_blank">
											#get_project.proje_no#
										</a>
									</h4>
                                </div>
                                <div class="card-details">
                                    <div class="detail">
                                        <i class="fa fa-calendar"></i> 
                                        <span>#dateformat(get_project.target_start,dateformat_style)#</span>
                                    </div>
                                </div>
                                <div class="card-details">
                                    <div class="detail">
                                        <i class="fa fa-calendar"></i> 
                                        <span>#dateformat(get_project.target_finish,dateformat_style)#</span>
                                    </div>
                                </div>
                                <div class="card-details">
                                    <div class="detail">
                                        <span class="status-badge status-progress">#get_project.project_cat#</span>
                                    </div>
                                </div>
                                <div class="card-details">
                                    <div class="detail">
                                        <img src="#get_project.photo#" alt="#get_emp_info(project_emp_id,0,0)#" class="assignee-avatar" />
                                        <span>#get_emp_info(project_emp_id,0,0)#</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cfloop>
                </div>
            </cfif>
        </cfoutput>
    </div>
</cf_box>

<cfif get_user_group.recordCount> <!--- Kullanıcı sadece istenilen yetki grubunda ise kaydırma yapıp aşama güncelleyebilsin diye eklendi. --->
    <script>
        const columns = document.querySelectorAll('.kanban-items');
        columns.forEach(column => {
            new Sortable(column, {
            group: "shared",
            animation: 150,
            onEnd: function(evt) {
                // Taşınan kart (Proje)
                let itemEl = evt.item;
                // Yeni sütun (Aşama)
                let newColumnEl = evt.to;
                // projectID (Kart data-projectid)
                let projectID = itemEl.dataset.projectid;
                // Yeni processRowID (Sütun data-processrowid)
                let newProcessRowID = newColumnEl.dataset.processrowid;
                let newUrl = "<cfoutput>#request.self#</cfoutput>?fuseaction=project.emptypopup_upd_kanban_process" + "&project_id=" + projectID+ "&processrowid=" + newProcessRowID;
                //console.log(newUrl);
                // 'work_list_sort' veya istediğin container ID'yi belirt
                AjaxPageLoad(newUrl, "work_list_sort", 1);
            }
            });
        });
    </script>
</cfif>