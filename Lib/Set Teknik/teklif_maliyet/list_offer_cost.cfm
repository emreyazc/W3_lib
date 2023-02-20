<cf_get_lang_set module_name="sales">
<cfparam name="attributes.keyword" default="">

<cfparam name="attributes.page" default=1>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfparam name="attributes.is_submit" default="">
<cfparam name="attributes.status" default="1">

<cfif isDefined("attributes.is_submit") and len(attributes.is_submit)>
    <cfquery name="GET_LIST_OFFER_COST" datasource="#DSN3#">
        SELECT
            OC.*,
            PTR.STAGE
        FROM
            OFFER_COST OC
            LEFT JOIN #DSN#.PROCESS_TYPE_ROWS PTR ON PTR.PROCESS_ROW_ID = OC.OFFER_COST_STAGE
        WHERE
            OFFER_COST_ID IS NOT NULL
            <cfif isdefined("attributes.status") and len(attributes.status)>
                AND OC.OFFER_COST_STATUS = <cfqueryparam cfsqltype="cf_sql_smallint" value="#attributes.status#">
            </cfif>
            <cfif isDefined("attributes.keyword") and len(attributes.keyword)>
                 AND OC.OFFER_COST_HEAD LIKE '%#attributes.keyword#%'
            </cfif>
            <cfif isDefined("attributes.record_emp") and len(attributes.record_emp)>
                AND OC.RECORD_EMP = #attributes.record_emp#
            </cfif>
            <cfif isDefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>
                AND OC.SALES_EMP = #attributes.sales_emp_id#
            </cfif>
        ORDER BY
            OFFER_COST_HEAD DESC
    </cfquery>
    <cfparam name="attributes.totalrecords" default="#GET_LIST_OFFER_COST.recordcount#">
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform action="#request.self#?fuseaction=#fusebox.circuit#.list_offer_cost" method="post" name="filter_offer_cost">
            <cfinput type="hidden" name="is_submit" id="is_submit" value="1">
            <cf_box_search>
				<div class="form-group">
					<cfsavecontent variable="placemessage"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" id="keyword" placeholder="#placemessage#" style="width:100px;" value="#attributes.keyword#" maxlength="50">
				</div>
                <div class="form-group">
                    <select name="status" id="status">
                        <option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                        <option value="1" <cfif isdefined("attributes.status") and (attributes.status eq 1)>selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
                        <option value="0" <cfif isdefined("attributes.status") and (attributes.status eq 0)>selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
                    </select>
                </div>
				<div class="form-group small">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" onKeyUp="isNumber(this)" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">                    
				</div>
				<div class="form-group">
					<cfsavecontent variable="message_date"><cf_get_lang dictionary_id='57782.Tarih Değerini Kontrol Ediniz'>!</cfsavecontent>
					<cf_wrk_search_button button_type="4">                    
				</div>
			</cf_box_search>
            <cf_box_search_detail>
                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-record_emp_name">
                        <label class="col col-12">Teklif Maliyet Kaydeden</label>
                        <div class="col col-12">
                            <div class="input-group">
                                <input type="hidden" name="record_emp" id="record_emp" value="">
                                <input name="record_emp_name" type="text" id="record_emp_name" onFocus="AutoComplete_Create('record_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','record_emp','','3','120');" value="" autocomplete="off">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=filter_offer_cost.record_emp&field_name=filter_offer_cost.record_emp_name&select_list=1');"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-sales_emp">
						<label class="col col-12"><cf_get_lang dictionary_id='40903.Satış Yapan'></label>
						<div class="col col-12">
							<div class="input-group">
								<input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isDefined("attributes.sales_emp") and len(attributes.sales_emp) and isdefined("attributes.sales_emp_id") and  len(attributes.sales_emp_id)><cfoutput>#attributes.sales_emp_id#</cfoutput></cfif>">
								<input name="sales_emp" type="text" id="sales_emp" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','120');" value="<cfif isDefined("attributes.sales_emp") and len(attributes.sales_emp) and len(attributes.sales_emp_id)><cfoutput>#attributes.sales_emp#</cfoutput></cfif>" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_emp_id=filter_offer_cost.sales_emp_id&field_name=filter_offer_cost.sales_emp&select_list=1');"></span>
							</div>
						</div>
					</div>
                </div>
            </cf_box_search_detail>
        </cfform>
    </cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="46105.Teklif Maliyet"></cfsavecontent>
    <cf_box title="#message#" uidrop="1" hide_table_column="1">
        <cf_flat_list>
            <thead>
				<tr>
					<th width="60"><cf_get_lang dictionary_id ='58577.Sıra'></th>
					<th width="60">Başlık</th>
                    <!---
					<th width="120">Teklif Maliyet No</th>
                    --->
                    <th>Teklif Maliyet Tarihi</th>
					<th><cf_get_lang dictionary_id='57574.Sirket'> - <cf_get_lang dictionary_id='57578.Yetkili'></th>
					<th>Satış Yapan</th>
					<th>Kaydeden</th>
                    <th>Kayıt Tarihi</th>
                    <th><cf_get_lang dictionary_id='58859.Surec'></th>
					<th width="20" class="header_icn_none text-center"><a href="<cfoutput>#request.self#?fuseaction=sales.list_offer_cost&event=add</cfoutput>"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.ekle'>" alt="<cf_get_lang dictionary_id='57582.ekle'>"></i></a></th>
                </tr>
			</thead>
            <cfif isDefined("attributes.is_submit") and len(attributes.is_submit)>
                <tbody>
                    <cfoutput query="GET_LIST_OFFER_COST" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#"> 
                        <tr>
                            <td>#currentRow#.</td>
                            <!---
                            <td><a href="#request.self#?fuseaction=sales.list_offer_cost&event=det&offer_cost_id=#OFFER_COST_ID#">TM-#OFFER_COST_ID#</a></td>
                            --->
                            <td><a href="#request.self#?fuseaction=sales.list_offer_cost&event=det&offer_cost_id=#OFFER_COST_ID#">#OFFER_COST_HEAD#</a></td>
                            <td>#DateFormat(OFFER_COST_DATE,dateformat_style)#</td>
                            <td>#get_par_info(COMPANY_ID,1,1,0)# - #get_par_info(PARTNER_ID,0,2,0)#</td>
                            <td>#get_emp_info(SALES_EMP,0,0)#</td>
                            <td>#get_emp_info(RECORD_EMP,0,0)#</td>
                            <td>#DateFormat(RECORD_DATE,dateformat_style)#</td>
                            <td>#STAGE#</td>
                            <td><a href="#request.self#?fuseaction=sales.list_offer_cost&event=upd&offer_cost_id=#OFFER_COST_ID#">&nbsp;<i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a></td>
                        </tr>
                    </cfoutput>
                </tbody>
            </cfif>
        </cf_flat_list>
        <cfset url_str = "sales.list_offer_cost_">
        <cfif isDefined("attributes.is_submit") and len(attributes.is_submit)>
            <cfif isdefined("attributes.is_submit")>
                <cfset url_str = "#url_str#&is_submit=#attributes.is_submit#">
            </cfif>
            <cfset adres="#request.self#?fuseaction=sales.list_offer_cost&is_submit=1">
            <cf_paging
            page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#url_str#">
        </cfif>
    </cf_box>
</div>