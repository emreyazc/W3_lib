<cfsetting showdebugoutput="no">
<cf_get_lang_set module_name="product">
<cfparam name="attributes.cat" default="">
<cfparam name="attributes.brand_id" default="">
<cfparam name="attributes.brand_name" default="">
<cfparam name="attributes.keyword" default="">

<cfif isDefined("attributes.is_form_submitted") and len(is_form_submitted)>
	<cfinclude template="../query/det_cost_matrix.cfm">
</cfif>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box>
        <cfform name="search_product" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
            <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
			<cf_box_search>
				<div class="form-group">
					<cfsavecontent variable="message"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
					<cfinput type="text" name="keyword" id="keyword" style="width:100px;" value="#attributes.keyword#" maxlength="50" placeholder="#message#">
				</div>
				<div class="form-group">
					<select name="product_status" id="product_status" style="width:50px;">
						<option value="1"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 1)> selected</cfif>><cf_get_lang dictionary_id='57493.Aktif'></option>
						<option value="0"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 0)> selected</cfif>><cf_get_lang dictionary_id='57494.Pasif'></option>
						<option value="2"<cfif isDefined("attributes.product_status") and (attributes.product_status eq 2)> selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
					</select>
				</div>
				<div class="form-group small">
					<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes"  maxlength="3" onKeyUp="isNumber(this)" style="width:25px;">
				</div>
				<div class="form-group">
					<cf_wrk_search_button button_type="4">
					<cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'>
				</div>
                <!---
				<div class="form-group">
					<a class="ui-btn ui-btn-gray2" href="javascript://" title="<cf_get_lang dictionary_id='37699.Barkod ara'>" onClick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_barcod_search');"><i class="fa fa-barcode"></i></a>
				</div>
                --->
			</cf_box_search>
        </cfform>
    </cf_box>

    <cfsavecontent variable="message"><cf_get_lang dictionary_id='988.Maliyet Matrisi'></cfsavecontent>
	<cf_box title="#message#" uidrop="1" hide_table_column="1">
        <cf_grid_list>
            <thead>
                <tr>
                    <th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
					<th><cf_get_lang dictionary_id='57742.Tarih'></th>
					<th><cf_get_lang dictionary_id='57657.Ürün'></th>
					<th><cf_get_lang dictionary_id='57489.Para Br'></th>
					<th width="20" class="header_icn_none"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.form_add_product_cost_matrix"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                </tr>
            </thead>
				<tbody>
					<cfif isDefined("attributes.is_form_submitted") and len(is_form_submitted)>
						<cfoutput query="det_cost_matrix">
							<tr>
								<td><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.form_upd_product_cost_matrix&event=det&cost_matrix_id=#cost_matrix_id#">#currentrow#.</td>
								<td>#DateFormat(RECORD_DATE,dateformat_style)#</td>
								<td>#MAIN_PRODUCT_NAME#</td>
								<td></td>
								<td></td>
							<tr>
						</cfoutput>
					</cfif>
				</tbody>
        </cf_grid_list>
    </cf_box>
</div>