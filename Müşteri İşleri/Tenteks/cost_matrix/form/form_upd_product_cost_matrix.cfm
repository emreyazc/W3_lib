<cfif isDefined("attributes.cost_matrix_id") and len(attributes.cost_matrix_id)>
    <cfinclude template="../query/get_cost_matrix.cfm">
</cfif>

<cfform name="form_cost_matrix" method="post" enctype="multipart/form-data" <!---action="#request.self#?fuseaction=stock.emptypopup_add_product_cost_matrix"--->>
     <cfoutput query="get_cost_matrix">
         <cf_box title="Birim Maliyet Güncelle">
        <cf_box_elements>
            <div class="form-group" id="item-matrix-status">
                <label><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="matrix_status" id="matrix_status" value="1" checked></label>&nbsp;&nbsp;&nbsp;
            </div>
            <div class="form-group" id="item-main-product_id">
                <label class="col col-4 col-sm-12">Ana Ürün</label>
                <div class="col col-8 col-sm-12">
                    <input type="hidden" name="main_product_id" id="main_product_id" value="#main_product_id#">
                    <div class="input-group">
                        <!---
                         <input name="main_product_name" type="text" id="main_product_name"  onfocus="AutoComplete_Create('main_product_name','PRODUCT_NAME','PRODUCT_NAME','get_product_autocomplete','0','STOCK_ID','stock_id','form_cost_matrix','3','200');" value="" autocomplete="off">
                        --->
                        <input type="text" name="main_product_name" id="main_product_name" value="#main_product_name#">
                        <span class="input-group-addon btnPointer icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=form_cost_matrix.main_product_id&field_name=form_cost_matrix.main_product_name','list');"></span>
                    </div>
                </div>
            </div>
        </cf_box_elements>
        <cf_tab defaultOpen="sayfa_1" divId="sayfa_1,sayfa_2,sayfa_3,sayfa_4" divLang="Boy Kısmında Kullanılan Ürünler;En Kısmında Kullanılan Ürünler;Adet Bazlı Kullanılan Ürünler;Birim Fiyatlar">
            <div id="unique_sayfa_1" class="ui-info-text uniqueBox">
                <div class="form-group" id="item-al-2">
                    <label class="col col-4 col-sm-12">Alüminyum Dikme</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="alm_id_1" id="alm_id_1" value="#alm_id_1#">
                        <div class="input-group">
                            <input name="alm_name_1" type="text" id="alm_name_1" value="#alm_name_1#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.alm_id_1&field_name=form_cost_matrix.alm_name_1&field_total_price=form_cost_matrix.alm_cost_1');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-cost-1">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="alm_cost_1" type="text" id="alm_cost_1" value="#TLFormat(alm_cost_1)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-2">
                    <label class="col col-4 col-sm-12">Alüminyum Dikme Kapağı</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="alm_id_2" id="alm_id_2" value="#alm_id_2#">
                        <div class="input-group">
                            <input type="text" name="alm_name_2" id="alm_name_2" value="#alm_name_2#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.alm_id_2&field_name=form_cost_matrix.alm_name_2&field_total_price=form_cost_matrix.alm_cost_2');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-cost-2">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="alm_cost_2" type="text" id="alm_cost_2" value="#TLFormat(alm_cost_2)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pvc">
                    <label class="col col-4 col-sm-12">PVC Fermuar Çıtası</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="pvc_id" id="pvc_id" value="#pvc_id#">
                        <div class="input-group">
                            <input type="text" name="pvc_name" id="pvc_name" value="#pvc_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.pvc_id&field_name=form_cost_matrix.pvc_name&field_total_price=form_cost_matrix.pvc_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pvc-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="pvc_cost" type="text" id="pvc_cost" value="#TLFormat(pvc_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-zip">
                    <label class="col col-4 col-sm-12">Fermuar</label>
                    <div class="col col-8 col-sm-12">
                     <input type="hidden" name="zip_id" id="zip_id" value="#zip_id#">
                        <div class="input-group">
                            <input type="text" name="zip_name" id="zip_name" value="#zip_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.zip_id&field_name=form_cost_matrix.zip_name&field_total_price=form_cost_matrix.zip_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-zip-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="zip_cost" type="text" id="zip_cost" value="#TLFormat(zip_cost)#" >
                        </div>
                    </div>
                </div>
            </div>
             <div id="unique_sayfa_2" class="ui-info-text uniqueBox">
                <div class="form-group" id="item-al-case">
                    <label class="col col-4 col-sm-12">Alüminyum Kasa</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="al_case_id" id="al_case_id" value="#al_case_id#">
                        <div class="input-group">
                            <input type="text" name="al_case_name" id="al_case_name" value="#al_case_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.al_case_id&field_name=form_cost_matrix.al_case_name&field_total_price=form_cost_matrix.al_case_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-case-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                       <div class="input-group">
                            <input name="al_case_cost" type="text" id="al_case_cost" value="#TLFormat(al_case_cost)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-case-lid">
                    <label class="col col-4 col-sm-12">Alüminyum Kasa Kapağı</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="al_case_lid_id" id="al_case_lid_id" value="#al_case_lid_id#">
                        <div class="input-group">
                            <input type="text" name="al_case_lid_name" id="al_case_lid_name" value="#al_case_lid_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.al_case_lid_id&field_name=form_cost_matrix.al_case_lid_name&field_total_price=form_cost_matrix.al_case_lid_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-case-lid-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="al_case_lid_cost" type="text" id="al_case_lid_cost" value="#TLFormat(al_case_lid_cost)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-profile">
                    <label class="col col-4 col-sm-12">Alüminyum Etek Profili</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="al_profile_id" id="al_profile_id" value="#al_profile_id#">
                        <div class="input-group">
                            <input type="text" name="al_profile_name" id="al_profile_name" value="#al_profile_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.al_profile_id&field_name=form_cost_matrix.al_profile_name&field_total_price=form_cost_matrix.al_profile_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-profile-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="al_profile_cost" type="text" id="al_profile_cost" value="#TLFormat(al_profile_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-weight">
                    <label class="col col-4 col-sm-12">Alüminyum Ağırlık Demiri</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="al_weight_id" id="al_weight_id" value="#al_weight_id#">
                        <div class="input-group">
                            <input type="text" name="al_weight_name" id="al_weight_name" value="#al_weight_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.al_weight_id&field_name=form_cost_matrix.al_weight_name&field_total_price=form_cost_matrix.al_weight_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-al-weight-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="al_weight_cost" type="text" id="al_weight_cost" value="#TLFormat(al_weight_cost)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pipe">
                    <label class="col col-4 col-sm-12">Boru</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="pipe_id" id="pipe_id" value="#pipe_id#">
                        <div class="input-group">
                            <input type="text" name="pipe_name" id="pipe_name" value="#pipe_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.pipe_id&field_name=form_cost_matrix.pipe_name&field_total_price=form_cost_matrix.pipe_cost');"></span>
                         </div>
                    </div>
                </div>
                <div class="form-group" id="item-pipe-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="pipe_cost" type="text" id="pipe_cost" value="#TLFormat(pipe_cost)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-fabric">
                    <label class="col col-4 col-sm-12">Kumaş Fitili</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="fabric_id" id="fabric_id" value="#fabric_id#">
                        <div class="input-group">
                            <input type="text" name="fabric_name" id="fabric_name" value="#fabric_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.fabric_id&field_name=form_cost_matrix.fabric_name&field_total_price=form_cost_matrix.fabric_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-fabric-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="fabric_cost" type="text" id="fabric_cost" value="#TLFormat(fabric_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-eaves">
                    <label class="col col-4 col-sm-12">Etek Fitili</label>
                    <div class="col col-8 col-sm-12">
                       <input type="hidden" name="eaves_id" id="eaves_id" value="#eaves_id#">
                        <div class="input-group">
                            <input type="text" name="eaves_name" id="eaves_name" value="#eaves_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.eaves_id&field_name=form_cost_matrix.eaves_name&field_total_price=form_cost_matrix.eaves_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-fabric-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="eaves_cost" type="text" id="eaves_cost" value="#TLFormat(eaves_cost)#">
                        </div>
                    </div>
                </div>
            </div>
            <div id="unique_sayfa_3" class="ui-info-text uniqueBox">
                <div class="form-group" id="item-case-lid">
                    <label class="col col-4 col-sm-12">Sağ - Sol Kasa Kapağı</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="case_lid_id" id="case_lid_id" value="#case_lid_id#">
                         <div class="input-group">
                            <input type="text" name="case_lid_name" id="case_lid_name" value="#case_lid_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.case_lid_id&field_name=form_cost_matrix.case_lid_name&field_total_price=form_cost_matrix.case_lid_cost');"></span>
                         </div>
                    </div>
                </div>
                <div class="form-group" id="item-case-lid-quantity">
                    <label class="col col-4 col-sm-12">Adet (Sağ - Sol Kasa Kapağı)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="case_lid_quantity" id="case_lid_quantity" value="#case_lid_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-case-lid-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="case_lid_cost" type="text" id="case_lid_cost" value="#TLFormat(case_lid_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-bottom-lid">
                    <label class="col col-4 col-sm-12">Dikme Alt Kapağı</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="bottom_lid_id" id="bottom_lid_id" value="#bottom_lid_id#">
                        <div class="input-group">
                            <input type="text" name="bottom_lid_name" id="bottom_lid_name" value="#bottom_lid_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.bottom_lid_id&field_name=form_cost_matrix.bottom_lid_name&field_total_price=form_cost_matrix.bottom_lid_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-bottom-lid-quantity">
                    <label class="col col-4 col-sm-12">Adet (Dikme Alt Kapağı)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="bottom_lid_quantity" id="bottom_lid_quantity" value="#bottom_lid_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-bottom-lid-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <div class="input-group">
                                <input name="bottom_lid_cost" type="text" id="bottom_lid_cost" value="#TLFormat(bottom_lid_cost)#">
                            </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-slat-set">
                    <label class="col col-4 col-sm-12">Etek Çıtası Takımı</label>
                    <div class="col col-8 col-sm-12">
                    <input type="hidden" name="slat_set_id" id="slat_set_id" value="#slat_set_id#">
                        <div class="input-group">
                            <input type="text" name="slat_set_name" id="slat_set_name" value="#slat_set_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.slat_set_id&field_name=form_cost_matrix.slat_set_name&field_total_price=form_cost_matrix.slat_set_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-slat-set-quantity">
                    <label class="col col-4 col-sm-12">Adet (Etek Çıtası Takımı)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="slat_set_quantity" id="slat_set_quantity" value="#slat_set_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-slat-set-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input name="slat_set_cost" type="text" id="slat_set_cost" value="#TLFormat(slat_set_cost)#" >
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-holder">
                    <label class="col col-4 col-sm-12">Motor Tutucu</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="engine_holder_id" id="engine_holder_id" value="#engine_holder_id#">
                        <div class="input-group">
                            <input type="text" name="engine_holder_name" id="engine_holder_name" value="#engine_holder_name#">
                            <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.engine_holder_id&field_name=form_cost_matrix.engine_holder_name&field_total_price=form_cost_matrix.engine_holder_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-holder-quantity">
                    <label class="col col-4 col-sm-12">Adet (Motor Tutucu)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_holder_quantity" id="engine_holder_quantity" value="#engine_holder_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-holder-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_holder_cost" id="engine_holder_cost" value="#TLFormat(engine_holder_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pipe-kit">
                    <label class="col col-4 col-sm-12">Boru Başı Takımı</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="pipe_kit_id" id="pipe_kit_id" value="#pipe_kit_id#">
                        <div class="input-group">
                           <input type="text" name="pipe_kit_name" id="pipe_kit_name" value="#pipe_kit_name#">
                           <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.pipe_kit_id&field_name=form_cost_matrix.pipe_kit_name&field_total_price=form_cost_matrix.pipe_kit_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pipe-kit-quantity">
                    <label class="col col-4 col-sm-12">Adet (Boru Başı Takımı)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="pipe_kit_quantity" id="pipe_kit_quantity" value="#pipe_kit_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-pipe-kit-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="pipe_kit_cost" id="pipe_kit_cost" value="#TLFormat(pipe_kit_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-adapter">
                    <label class="col col-4 col-sm-12">Motor Adaptörü</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="engine_adapter_id" id="engine_adapter_id" value="#engine_adapter_id#">
                        <div class="input-group">
                             <input type="text" name="engine_adapter_name" id="engine_adapter_name" value="#engine_adapter_name#">
                             <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.engine_adapter_id&field_name=form_cost_matrix.engine_adapter_name&field_total_price=form_cost_matrix.engine_adapter_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-adapter-quantity">
                    <label class="col col-4 col-sm-12">Adet (Motor Adaptörü)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_adapter_quantity" id="engine_adapter_quantity" value="#engine_adapter_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-adapter-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_adapter_cost" id="engine_adapter_cost" value="#TLFormat(engine_adapter_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-slat-end">
                    <label class="col col-4 col-sm-12">PVC Çıta Ucu</label>
                    <div class="col col-8 col-sm-12">
                        <input type="hidden" name="slat_end_id" id="slat_end_id" value="#slat_end_id#">
                        <div class="input-group">
                           <input type="text" name="slat_end_name" id="slat_end_name" value="#slat_end_name#">
                           <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.slat_end_id&field_name=form_cost_matrix.slat_end_name&field_total_price=form_cost_matrix.slat_end_cost');"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-slat-end-quantity">
                    <label class="col col-4 col-sm-12">Adet (PVC Çıta Ucu)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="slat_end_quantity" id="slat_end_quantity" value="#slat_end_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-slat-end-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="slat_end_cost" id="slat_end_cost" value="#TLFormat(slat_end_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-zip-holder">
                    <label class="col col-4 col-sm-12">Perde Tutucu</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <input type="hidden" name="zip_holder_id" id="zip_holder_id" value="#zip_holder_id#">
                            <div class="input-group">
                                <input type="text" name="zip_holder_name" id="zip_holder_name" value="#zip_holder_name#">
                                <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.zip_holder_id&field_name=form_cost_matrix.zip_holder_name&field_total_price=form_cost_matrix.zip_holder_cost');"></span>
                           </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-zip-holder-quantity">
                    <label class="col col-4 col-sm-12">Adet (Perde Tutucu)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="zip_holder_quantity" id="zip_holder_quantity" value="#zip_holder_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-zip-holder-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="zip_holder_cost" id="zip_holder_cost" value="#TLFormat(zip_holder_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-roller-bearing">
                    <label class="col col-4 col-sm-12">Rulman ve Rulman Yatağı</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <input type="hidden" name="roller_id" id="roller_id" value="#roller_id#">
                            <div class="input-group">
                               <input type="text" name="roller_name" id="roller_name" value="#roller_name#">
                               <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.roller_id&field_name=form_cost_matrix.roller_name&field_total_price=form_cost_matrix.roller_cost');"></span>
                           </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-roller-bearing-quantity">
                    <label class="col col-4 col-sm-12">Adet (Rulman ve Rulman Yatağı)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="roller_quantity" id="roller_quantity" value="#roller_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-roller-bearing-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="roller_cost" id="roller_cost" value="#TLFormat(roller_cost)#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine">
                    <label class="col col-4 col-sm-12">Motor</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <input type="hidden" name="engine_id" id="engine_id" value="#engine_id#">
                            <div class="input-group">
                                <input type="text" name="engine_name" id="engine_name" value="#engine_name#">
                                <span class="input-group-addon btnPointer icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_cost_matrix.engine_id&field_name=form_cost_matrix.engine_name&field_total_price=form_cost_matrix.engine_cost');"></span>
                           </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-engine-quantity">
                    <label class="col col-4 col-sm-12">Adet (Motor)</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_quantity" id="engine_quantity" value="#engine_quantity#">
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-engine-cost">
                    <label class="col col-4 col-sm-12">FİYAT</label>
                    <div class="col col-8 col-sm-12">
                        <div class="input-group">
                            <input type="text" name="engine_cost" id="engine_cost" value="#TLFormat(engine_cost)#">
                        </div>
                    </div>
                </div>
            </div>
            <div id="unique_sayfa_4" class="ui-info-text uniqueBox">
                <div class="form-group" id="item-al-unit-cost">
                    <label class="col col-4 col-sm-12">Alüminyum Birim Fiyat</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <!---
                            <input type="hidden" name="camp_id" id="camp_id" value="">
                            --->
                            <div class="input-group">
                                <input type="text" name="al_unit_cost" id="al_unit_cost" value="#TLFormat(al_unit_cost)#">
                                <!---
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                --->
                            </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-lme-iron-unit-cost">
                    <label class="col col-4 col-sm-12">Demir Birim Fiyat</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <!---
                            <input type="hidden" name="camp_id" id="camp_id" value="">
                            --->
                            <div class="input-group">
                                <input type="text" name="lme_iron_unit_cost" id="lme_iron_unit_cost" value="#TLFormat(lme_iron_unit_cost)#">
                                <!---
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                --->
                            </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-paint-cost">
                    <label class="col col-4 col-sm-12">Boya</label>
                    <div class="col col-8 col-sm-12">
                        <cfoutput>
                            <!---
                            <input type="hidden" name="camp_id" id="camp_id" value="">
                            --->
                            <div class="input-group">
                                <input type="text" name="paint_cost" id="paint_cost" value="#TLFormat(paint_cost)#" >
                                <!---
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                                --->
                            </div>
                        </cfoutput>
                    </div>
                </div>
                <div class="form-group" id="item-labor-cost">
                    <label class="col col-4 col-sm-12">İşçilik</label>
                    <div class="col col-8 col-sm-12">
                        <!---
                        <input type="hidden" name="camp_id" id="camp_id" value="">
                        --->
                        <div class="input-group">
                        <input type="text" name="labor_cost" id="labor_cost" value="#TLFormat(labor_cost)#" >
                        <!---
                        <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_campaigns&field_id=form_basket.camp_id&field_name=form_basket.camp_name');"></span>
                        --->
                        </div>
                    </div>
                </div>
            </div>
        </cf_tab>
        <cf_workcube_buttons is_upd="1">
    </cf_box>
     </cfoutput>
</cfform>

<cf_box>

<cfoutput query="GET_COST_MATRIX">
    <cfscript>
        product_cost = (alm_cost_1+alm_cost_2+pvc_cost+zip_cost+al_case_cost+al_case_lid_cost+al_profile_cost+al_weight_cost+pipe_cost+fabric_cost+eaves_cost);
        product_quantity_cost_total = ((case_lid_cost*case_lid_quantity)+(bottom_lid_cost*bottom_lid_quantity)+(slat_set_cost*slat_set_quantity)+(engine_holder_cost*engine_holder_quantity)+(pipe_kit_cost*pipe_kit_quantity)+(engine_adapter_cost*engine_adapter_quantity)+(slat_end_cost*slat_end_quantity)+(zip_holder_cost*zip_holder_quantity)+(roller_cost*roller_quantity)+(engine_cost*engine_quantity));
        product_cost_total_labor = (product_cost+product_quantity_cost_total)*0.35;
        main_product_total_cost=(product_cost+product_quantity_cost_total+product_cost_total_labor)
    </cfscript>


    <cf_grid_list>
        <thead>
            <th>Adetsiz Ürünlerin Toplamı</th>
            <th>Adetli Ürünlerin Toplamı</th>
            <th>İşçilik Maliyeti</th>
            <th>Toplam Maliyet</th>
            <th>Matris Oluştur</th>
        </thead>
        <tbody>
            <td>#TLFormat(product_cost,3)#</td>
            <td>#TLFormat(product_quantity_cost_total,3)#</td>
            <td>#TLFormat(product_cost_total_labor,3)#</td>
            <td>#TLFormat(main_product_total_cost,3)#</td>
            <td width="20" class="header_icn_none"><a href="#request.self#?fuseaction=stock.form_add_product_cost_matrix_all_criteria&event=add&cost_matrix_id=#cost_matrix_id#"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></td>
        </tbody>
    </cf_grid_list>
</cfoutput>
<cf_box>