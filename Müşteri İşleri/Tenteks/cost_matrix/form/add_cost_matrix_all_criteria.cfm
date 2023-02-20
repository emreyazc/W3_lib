<cfif isDefined("attributes.cost_matrix_id") and len(attributes.cost_matrix_id)>
        <cfinclude template="../query/get_cost_matrix.cfm">
</cfif>

<cfform name="form_cost_matrix_all_criteria" method="post" enctype="multipart/form-data" action="#request.self#?fuseaction=stock.emptypopup_add_cost_matrix_all_criteria">
    <cf_box title="Maliyet Matrisi Oluştur">
        <cfif isDefined("attributes.cost_matrix_id") and len(attributes.cost_matrix_id)>
            <cfoutput query="GET_COST_MATRIX">
                <cfscript>
                    product_cost = (alm_cost_1+alm_cost_2+pvc_cost+zip_cost+al_case_cost+al_case_lid_cost+al_profile_cost+al_weight_cost+pipe_cost+fabric_cost+eaves_cost);
                    product_quantity_cost_total = ((case_lid_cost*case_lid_quantity)+(bottom_lid_cost*bottom_lid_quantity)+(slat_set_cost*slat_set_quantity)+(engine_holder_cost*engine_holder_quantity)+(pipe_kit_cost*pipe_kit_quantity)+(engine_adapter_cost*engine_adapter_quantity)+(slat_end_cost*slat_end_quantity)+(zip_holder_cost*zip_holder_quantity)+(roller_cost*roller_quantity)+(engine_cost*engine_quantity));
                    product_cost_total_labor = (product_cost+product_quantity_cost_total)*0.35;
                    main_product_total_cost=(product_cost+product_quantity_cost_total+product_cost_total_labor)
                </cfscript>
                <cf_grid_list>
                    <thead>
                        <th>Ana Ürün</th>
                        <th>Adetsiz Ürünlerin Toplamı</th>
                        <th>Adetli Ürünlerin Toplamı</th>
                        <th>Kumaş Birim Maliyeti</th>
                        <th>İşçilik Maliyeti</th>
                        <th>Toplam Maliyet</th>
                    </thead>
                    <tbody>
                        <td>#MAIN_PRODUCT_NAME#</td>
                        <td>#TLFormat(product_cost,3)#</td>
                        <td>#TLFormat(product_quantity_cost_total,3)#</td>
                        <td>#TLFormat(fabric_unit_cost,3)#</td>
                        <td>#TLFormat(product_cost_total_labor,3)#</td>
                        <td>#TLFormat(main_product_total_cost,3)#</td>
                    </tbody>
                </cf_grid_list>
            </cfoutput>
        </cfif>
    <cf_box>
    <cf_box>
            <div class="col col-4 col-md-4 col-sm-12" type="column" index="1" sort="true">
                <input type="hidden" name="cost_matrix_id" id="cost_matrix_id" value="<cfoutput>#attributes.cost_matrix_id#</cfoutput>">
                <div class="form-group" id="item-main-product_id">
                    <label class="col col-4 col-sm-12">Ana Ürün</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="main_product_id" id="main_product_id" value="#main_product_id#">
                        <div class="input-group">
                            <input type="text" name="main_product_name" id="main_product_name" readonly="yes" value="<cfoutput>#get_cost_matrix.main_product_name#</cfoutput>">
                            <!---
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=form_cost_matrix.main_product_id&field_name=form_cost_matrix.main_product_name','list');"></span>
                            --->
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-matrix-name">
                    <label class="col col-4 col-sm-12">Matris Adı</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_name" id="matrix_name" value="">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-record-member">
                    <label class="col col-4 col-sm-12">Kaydeden</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="record_member_id" id="record_member_id" value="#session.ep.userid#">
                        <div class="input-group">
                            <input type="text" name="record_member_name" id="record_member_name" readonly="yes" value="<cfoutput>#get_emp_info(session.ep.userid,0,0)#</cfoutput>">
                        </div>
                    </div>
                </div>
            </div>
            <div class="col col-4 col-md-4 col-sm-12" type="column" index="2" sort="true">
                <div class="form-group" id="item-main-matrix-range">
                    <label class="col col-4 col-sm-12">Matris Aralığı</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_range" id="matrix_range" value="">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-matrix-max-width">
                    <label class="col col-4 col-sm-12">Maksimum En</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_max_width" id="matrix_max_width" value="">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-matrix-max-height">
                    <label class="col col-4 col-sm-12">Maksimum Boy</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_max_height" id="matrix_max_height" value="">
                        </div>
                    </div>
                </div>
            </div>
            <div class="col col-4 col-md-4 col-sm-12" type="column" index="3" sort="true">
                <div class="form-group" id="item-main-matrix-min-width">
                    <label class="col col-4 col-sm-12">Minimum En</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_min_width" id="matrix_min_width" value="">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-matrix-min-height">
                    <label class="col col-4 col-sm-12">Minimum Boy</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="matrix_min_height" id="matrix_min_height" value="">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-main-matrix-profit-rate">
                    <label class="col col-4 col-sm-12">Kar Oranı (%)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="profit_rate" id="profit_rate" value="">
                        </div>
                    </div>
                </div>
            </div>
    </cf_box>
    <cf_workcube_buttons>
</cfform>