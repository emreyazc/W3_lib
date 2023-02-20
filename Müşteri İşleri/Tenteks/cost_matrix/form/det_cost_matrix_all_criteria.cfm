<cfif isDefined("attributes.cost_matrix_all_criteria_id") and len(attributes.cost_matrix_all_criteria_id)>
    <cfinclude template="../query/det_cost_matrix_all_criteria.cfm">
</cfif>

<!---
<cfdump var="#det_cost_matrix_all_criteria#">
--->

<cfquery name="GET_COST_MATRIX" datasource="#DSN1#">
    SELECT
        *
    FROM   
        COST_MATRIX
    WHERE
        COST_MATRIX_ID = #det_cost_matrix_all_criteria.cost_matrix_id#
</cfquery>

<cfscript>
    min_en = det_cost_matrix_all_criteria.min_matrix_width;
    min_boy = det_cost_matrix_all_criteria.min_matrix_height;
    max_en = det_cost_matrix_all_criteria.max_matrix_width;
    max_boy = det_cost_matrix_all_criteria.max_matrix_height;
    range = det_cost_matrix_all_criteria.matrix_range;
    kar_orani = det_cost_matrix_all_criteria.profit_rate;
</cfscript>

<cf_box>
    <cfoutput query="GET_COST_MATRIX">
        <cfscript>
            product_cost = (alm_cost_1+alm_cost_2+pvc_cost+zip_cost+al_case_cost+al_case_lid_cost+al_profile_cost+al_weight_cost+pipe_cost+fabric_cost+eaves_cost);
            width_product_cost = (al_case_cost+al_case_lid_cost+al_profile_cost+al_weight_cost+pipe_cost+fabric_cost+eaves_cost);
            height_product_cost = (alm_cost_1+alm_cost_2+pvc_cost+zip_cost);
            fabric_unit_cost = fabric_unit_cost;
            product_quantity_cost_total = ((case_lid_cost*case_lid_quantity)+(bottom_lid_cost*bottom_lid_quantity)+(slat_set_cost*slat_set_quantity)+(engine_holder_cost*engine_holder_quantity)+(pipe_kit_cost*pipe_kit_quantity)+(engine_adapter_cost*engine_adapter_quantity)+(slat_end_cost*slat_end_quantity)+(zip_holder_cost*zip_holder_quantity)+(roller_cost*roller_quantity)+(engine_cost*engine_quantity));
            product_cost_total_labor = (product_cost+product_quantity_cost_total)*0.35;
            main_product_total_cost=(product_cost+product_quantity_cost_total+product_cost_total_labor);
            main_product_total_cost = main_product_total_cost+fabric_unit_cost;
        </cfscript>


        <cf_grid_list>
            <thead>
                <th>Enine Kullanılan Ürünler</th>
                <th>Boyuna Kullanılan Ürünler</th>
                <th>Adetsiz Ürünlerin Toplamı</th>
                <th>Adetli Ürünlerin Toplamı</th>
                <th>Kumaş Birim Maliyet</th>
                <th>İşçilik Maliyeti</th>
                <th>Toplam Maliyet</th>
                <th>Matris Oluştur</th>
            </thead>
            <tbody>
                <td>#TLFormat(width_product_cost,3)#</td>
                <td>#TLFormat(height_product_cost,3)#</td>
                <td>#TLFormat(product_cost,3)#</td>
                <td>#TLFormat(product_quantity_cost_total,3)#</td>
                <td>#TLFormat(fabric_unit_cost,3)#</td>
                <td>#TLFormat(product_cost_total_labor,3)#</td>
                <td>#TLFormat(main_product_total_cost,3)#</td>
                <td width="20" class="header_icn_none"><a href="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.form_add_product_cost_matrix_all_criteria&event=add&cost_matrix_id=#cost_matrix_id#"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></td>
            </tbody>
        </cf_grid_list>
    </cfoutput>

<cf_tab defaultOpen="sayfa_1" divId="sayfa_1,sayfa_2" divLang="Maaliyet Matrisi;Satış Fiyatı Matrisi">
    <div id="unique_sayfa_1" class="ui-info-text uniqueBox">
        <cf_grid_list>
                <thead>
                    <tr>
                    <th><!---Satır:boy<br>Sütun:en---></th>
                        <cfloop index="j" from="#min_en#" to="#max_en#" step="#range#">
                            <th align="left">
                                <cfoutput>En : #j# cm</cfoutput>
                            </th>
                        </cfloop>
                    </tr>
                </thead>
            <cfloop index="i" from="#min_boy#" to="#max_boy#" step="#range#">
                <tbody>
                    <tr>
                    <th align="left"><cfoutput>&nbsp;Boy : #i# cm</cfoutput></th>
                        <cfloop index="j" from="#min_en#" to="#max_en#" step="#range#">
                            <td>
                                <cfscript>
                                    net_total=width_product_cost*j/100+height_product_cost*i/100+product_quantity_cost_total;
                                    //fabric_unit_cost = (fabric_unit_cost*i*j)/10000;
                                    product_cost_total_labor=(net_total*0.35);
                                    net_total=(net_total+product_cost_total_labor)*1;
                                </cfscript>
                                <cfoutput>#TLFormat(net_total,3)#</cfoutput>
                            </td>
                        </cfloop>
                    <tr>
                </tbody>
            </cfloop>
        </cf_grid_list>
    </div>
    <div id="unique_sayfa_2" class="ui-info-text uniqueBox">
        <cf_grid_list>
                <thead>
                    <tr>
                    <th align="center"><cfoutput>Kar Oranı: #kar_orani#</cfoutput><!---Satır:boy<br>Sütun:en---></th>
                        <cfloop index="j" from="#min_en#" to="#max_en#" step="#range#">
                            <th align="left">
                                <cfoutput>En : #j# cm</cfoutput>
                            </th>
                        </cfloop>
                    </tr>
                </thead>
            <cfloop index="i" from="#min_boy#" to="#max_boy#" step="#range#">
                <tbody>
                    <tr>
                    <th align="left"><cfoutput>&nbsp;Boy : #i# cm</cfoutput></th>
                        <cfloop index="j" from="#min_en#" to="#max_en#" step="#range#">
                            <td>
                                <cfscript>
                                    net_total=width_product_cost*j/100+height_product_cost*i/100+product_quantity_cost_total;
                                    //fabric_unit_cost = fabric_unit_cost*i*j/10000;
                                    product_cost_total_labor=(net_total*0.35);
                                    net_total=(net_total+product_cost_total_labor)*kar_orani;
                                </cfscript>
                                <cfoutput>#TLFormat(net_total,3)#</cfoutput>
                            </td>
                        </cfloop>
                    <tr>
                </tbody>
            </cfloop>
        </cf_grid_list>
    </div>
</cf_tab>
    <cf_workcube_buttons>
</cf_box>
