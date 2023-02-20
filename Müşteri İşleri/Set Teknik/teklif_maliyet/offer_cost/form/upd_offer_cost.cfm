<cftry>

<cfinclude template="../query/get_offer_cost.cfm">

<cfif len(GET_OFFER_COST.PROJECT_ID)>
    <cfquery name="GET_PROJECT" datasource="#DSN#">
        SELECT
            *
        FROM
            PRO_PROJECTS
        WHERE
            PROJECT_ID =  #GET_OFFER_COST.PROJECT_ID#
    </cfquery>
</cfif>

<cfquery name="GET_OFFER_COST_ROW" datasource="#DSN3#">
     SELECT
        OCR.PRODUCT_ID,
        OCR.STOCK_ID,
        OCR.PRODUCT_NAME,
        OCR.MANUFACT_CODE,
        OCR.PRODUCT_CODE_2,
        OCR.PRODUCT_UNIT,
        OCR.PRODUCT_UNIT_ID,
        OCR.QUANTITY,
        MONEY,
        OCR.PRICE_EXWORK,
        OCR.DISCOUNT,
        OCR.NET_PRICE_EXWORK,
        OCR.UNIT_COST,
        OCR.TOTAL_COST,
        OCR.UNIT_OFFER,
        OCR.TOTAL_OFFER,
        OCR.EXPORT_FACTOR,
        OCR.OFFER_FACTOR,
        OCR.PROFIT_MARGIN,
        OCR.IS_ALTERNATIVE,
        OCR.IS_IMPORTED,
        OCR.PROVISION_TIME,
        OCR.ROW_GROUP_NAME,
        OCR.ROW_GROUP_QUANTITY,
        OCR.ROW_GROUP_MONEY,
        OCR.RECORD_DATE,
        OCR.RECORD_EMP,
        OCR.UPDATE_DATE,
        OCR.UPDATE_EMP,
        PC.PRODUCT_CAT AS PRODUCT_CAT
    FROM
        OFFER_COST_ROW OCR
        LEFT JOIN #DSN1#.PRODUCT P ON P.PRODUCT_ID = OCR.PRODUCT_ID
        LEFT JOIN #DSN1#.PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
    WHERE
        OCR.OFFER_COST_ID = #attributes.offer_cost_id#
    ORDER BY OCR.ROW_GROUP_NAME
</cfquery>

<cfquery name="OFFER_COST_PRODUCT_CONTROL" datasource="#DSN3#"> <!--- eğer baskete ürün eklenmemişse ürün ağacı oluştur butonu görünmemesi için eklendi--->
    SELECT
        OFFER_COST_ROW_ID
    FROM
        OFFER_COST_ROW
    WHERE  
        OFFER_COST_ID = #attributes.offer_cost_id#
        AND
        ROW_GROUP_NAME <> 'Hizmet'
</cfquery>

<cfset offer_cost_product_count = offer_cost_product_control.recordCount>

<cfset cmp = createObject("component","V16.settings.cfc.setupCountry") />
<cfset GET_COUNTRY = cmp.getCountry()>
<cfquery name="GET_SALE_ZONES" datasource="#DSN#">
	SELECT SZ_ID,SZ_NAME FROM SALES_ZONES
</cfquery>

<cfquery name="GET_OTHER_MONEY" datasource="#DSN#">
    SELECT
        MONEY_ID,
        MONEY AS OTHER_MONEY
    FROM
        SETUP_MONEY
    WHERE
        PERIOD_ID = #session.ep.period_id#
</cfquery>

<cfquery name="GET_SETUP_UNIT" datasource="#DSN#">
    SELECT
        UNIT_ID,
        UNIT
    FROM
        SETUP_UNIT
</cfquery>

<cfset last_product_cat_2 = ''>

<cfquery name="GET_OFFER_COST_GROUP" datasource="#DSN#"> 
    SELECT
        *
    FROM
        OFFER_COST_GROUP
</cfquery>

<cfquery name="CONTROL_SERVICE_PRODUCT" datasource="#DSN3#">
    SELECT
        PRODUCT_ID
    FROM
        OFFER_COST_ROW
    WHERE
        OFFER_COST_ID = #attributes.offer_cost_id#
        AND
        ROW_GROUP_NAME = 'Hizmet'
</cfquery>

<cf_catalystHeader>

<cfform name="form_offer_cost" method="post" enctype="multipart/form-data" action="#request.self#?fuseaction=sales.emptypopup_upd_offer_cost">
    <input type="hidden" name="consumer_id" id="consumer_id"  value="<cfoutput>#GET_OFFER_COST.PARTNER_ID#</cfoutput>">
    <input type="hidden" name="company_id" id="company_id" value="<cfoutput>#GET_OFFER_COST.COMPANY_ID#</cfoutput>">
    <input type="hidden" name="offer_cost_id" id="offer_cost_id"  value="<cfoutput>#offer_cost_id#</cfoutput>">
    <input type="hidden" name="is_submit_form" id="is_submit_form" value="">
    <input type="hidden" name="row_count" id="row_count" value="">
    <input type="hidden" name="row_count_2" id="row_count_2" value="">
    <cfoutput>
        <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
            <cf_box title="Müşteri Bilgileri">
                <cf_box_elements>
                    <div class="col col-4 col-md-4 col-sm-12" type="column" index="0" sort="true">
                        <div class="form-group" id="item-sales_emp">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40903.Satış Yapan'></label>
                            <div class="col col-8 col-sm-12">
                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="#get_offer_cost.sales_emp#">
                                <cfif len(get_offer_cost.sales_emp)>
                                    <div class="input-group">
                                        <input name="sales_emp" type="text" id="sales_emp" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','110');" value="#get_emp_info(get_offer_cost.sales_emp,0,0)#" autocomplete="off">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_offer_cost.sales_emp_id&field_name=form_offer_cost.sales_emp&select_list=1');"></span>
                                    </div>
                                <cfelse>
                                    <div class="input-group">
                                        <input name="sales_emp" type="text" id="sales_emp" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','110');" value="" autocomplete="off">
                                        <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_offer_cost.sales_emp_id&field_name=form_offer_cost.sales_emp&select_list=1');"></span>
                                    </div>
                                </cfif>
                            </div>
                        </div>
                        <div class="form-group" id="item-offer_cost_status">
                            <label><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="offer_cost_status" id="offer_cost_status" value="1" <cfif GET_OFFER_COST.OFFER_COST_STATUS eq 1> checked</cfif>></label>&nbsp;&nbsp;&nbsp;
                        </div>
                        <div class="form-group" id="item-process_stage">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                            <div class="col col-8 col-sm-12">
                                <cf_workcube_process is_upd='0' select_value='#get_offer_cost.offer_cost_stage#' process_cat_width='130' is_detail='1'>
                            </div>
                        </div>
                        <div class="form-group" id="item-offer_cost_detail">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57629.açıklama'></label>
                            <div class="col col-8 col-sm-12">
                                <textarea style="height:100px;" name="offer_cost_detail" id="offer_cost_detail" >#get_offer_cost.OFFER_COST_DETAIL#</textarea>
                            </div>
                        </div>
                        <div class="form-group" id="item-offer_cost_head">
                            <label class="col col-4 col-sm-12">Teklif Maliyet Numarası</label>
                            <div class="col col-8 col-sm-12">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58059.Başlık Girmelisiniz'></cfsavecontent>
                                <cfinput type="text" id="offer_cost_head" name="offer_cost_head" value="#get_offer_cost.offer_cost_head#" required="no" message="#message#" maxlength="200">
                            </div>
                        </div>
                        <cf_duxi name="about_company" id="about_company" type="text" data="" value="#get_par_info(GET_OFFER_COST.COMPANY_ID,1,1,0)#" hint="şirket" label="57574" threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=form_offer_cost.company_id&is_period_kontrol=0&field_comp_name=form_offer_cost.about_company&field_partner=form_offer_cost.partner_id&field_consumer=form_offer_cost.consumer_id&field_name=form_offer_cost.about_par_name&par_con=1&select_list=2,3">
                        <div class="form-group" id="form_ul_about_par_name">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <input type="hidden" name="partner_id" id="partner_id" value="<cfoutput>#GET_OFFER_COST.PARTNER_ID#</cfoutput>">
                                <input type="text" name="about_par_name" id="about_par_name" data="" value="<cfif len(GET_OFFER_COST.PARTNER_ID)>#get_par_info(GET_OFFER_COST.PARTNER_ID,0,-1,0)#<cfelse></cfif>">
                            </div>
                        </div>
                        <cfif len(GET_OFFER_COST.PROJECT_ID)>
                            <cf_duxi name="related_project_id" type="hidden" value="#GET_PROJECT.PROJECT_ID#">
                            <cf_duxi name="related_project_head" type="text" data="GET_PROJECT.PROJECT_HEAD" placeholder="58459" label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=form_offer_cost.related_project_head&project_id=form_offer_cost.related_project_id">
                        <cfelse>
                            <cf_duxi name="related_project_id" type="hidden" value="">
                            <cf_duxi name="related_project_head" type="text" data="" placeholder="58459" label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=form_offer_cost.related_project_head&project_id=form_offer_cost.related_project_id">
                        </cfif>
                        <div class="form-group require" id="item-offer_cost_date">
                            <label class="col col-4 col-sm-12">Tarih</label>
                            <div class="col col-8 col-sm-12">
                                <div class="input-group">
                                    <cfinput type="text" name="offer_cost_date" id="offer_cost_date"  value="#dateformat(get_offer_cost.offer_cost_date,dateformat_style)#" validate="#validate_style#" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="offer_cost_date"></span>
                                </div>
                            </div>                
                        </div>
                        <cfif len(get_offer_cost.product_id)>
                            <cfquery name="GET_SYSTEM_NAME" datasource="#DSN1#">
                                SELECT
                                    PRODUCT_NAME
                                FROM
                                    PRODUCT
                                WHERE
                                    PRODUCT_ID = #get_offer_cost.product_id#
                            </cfquery>
                            <div class="form-group" id="item-offer_cost_system_name">
                                <input type="hidden" name="system_id" id="system_id" value="<cfoutput>#get_offer_cost.product_id#</cfoutput>">
                                <label class="col col-4 col-sm-12">Sistem / Ürün Adı</label>
                                <div class="col col-8 col-sm-12">
                                    <cfsavecontent variable="message">Sistem / Mamul Adı Boş Bırakılamaz !</cfsavecontent>
                                    <cfinput type="text" id="system_name" name="system_name" value="#get_system_name.product_name#" required="yes" message="#message#" maxlength="200">
                                </div>
                            </div>
                        </cfif>
                    </div>
                </cf_box_elements>
                <cf_box_footer>
                    <div class="col col-12"><cf_record_info query_name='GET_OFFER_COST' is_partner='1' is_consumer='1' record_emp="RECORD_EMP" update_emp="UPDATE_EMP">
                    </div>
                     <div class="col col-1">
                        <input type="submit" name="is_update" id="is_update" value="Güncelle" onclick="update_func()">
                        <input style="background-color:red" type="submit" name="is_delete" id="is_delete" value="Sil" onclick="delete_func()">
                    </div>
                </cf_box_footer>
            </cf_box>
            <cfif control_service_product.recordcount eq 0>
                <cf_box title="Hizmet Ürünleri">
                    <cf_box_elements>
                        <div class="col col-4 col-md-4 col-sm-12">
                            <div class="form-group require" id="item-offer_cost_service_product">
                                <label class="col col-4 col-sm-12">Hizmet Ürünlerini Dahil Et</label>
                                <div class="col col-8 col-sm-12">
                                    <div class="input-group">
                                        <input type="checkbox" id="include_service_product" name="include_service_product" value="1" onclick="show_service_product()">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </cf_box_elements>
                </cf_box>
            </cfif>
            <cf_box title="Ürünler">
                <cf_box_elements>
                    <div style="width:100%; display:block" id="product">
                        <cf_grid_list id="products" sort="0" name="products" class="basket_list">
                            <thead>
                                <tr>
                                    <th width="15">
                                        <a title="Satır <cf_get_lang dictionary_id='57582.Ekle'>" onClick="add_row_p('','1','');"><i class="fa fa-plus"></i></a>
                                        <a title="Boş Satır<cf_get_lang dictionary_id='57582.Ekle'>" onClick="add_row('','1','');"><i class="fa fa-pencil"></i></a>
                                    </th>
                                    <th>Grup</th>
                                    <th>Grup Miktarı</th>
                                    <th>Grup Döviz</th>
                                    <th>Ürün Tipi</th>
                                    <th>İthal Ediliyor</th>
                                    <th>Üretici Kodu</th>
                                    <th>Özel Kod</th>
                                    <th>Ürün</th>
                                    <th>Birim</th>
                                    <th>Miktar</th>
                                    <th>Döviz Cinsi</th>
                                    <th>Liste Exwork</th>
                                    <th>İskonto (%)</th>
                                    <th>Net Alış</th>
                                    <th>İthalat Katsayısı</th>
                                    <th>Birim Maliyet</th>
                                    <th>Toplam Maliyet</th>
                                    <th>Teklif Katsayısı</th>
                                    <th>Birim Teklif</th>
                                    <th>Toplam Teklif</th>
                                    <th>Teslim Süresi (Gün)</th>
                                    <th>Kar Marjı</th>
                                </tr>
                            </thead>
                            <tbody name="table_1" id="table_1"></tbody>
                        </cf_grid_list>
                    </div>
                    <div style="width:100%; display:none" id="service_product">
                        <cf_grid_list id="services" sort="0" name="services" class="basket_list">
                            <thead>
                                <tr>
                                    <!---
                                    <th width="15"><a title="<cf_get_lang dictionary_id='57582.Ekle'>" onClick="add_row('','1','');"><i class="fa fa-plus"></i></a></th>
                                    --->
                                    <th>&nbsp;</th>
                                    <th width="5">Grup</th>
                                    <th width="5">Grup Miktarı</th>
                                    <th width="5">Grup Döviz</th>
                                    <th width="5">Ürün Tipi</th>
                                    <th width="5">İthal Ediliyor</th>
                                    <th width="5">Üretici Kodu</th>
                                    <th width="5">Özel Kod</th>
                                    <th width="5">Ürün</th>
                                    <th width="5">Birim</th>
                                    <th width="5">Miktar</th>
                                    <th width="5">Döviz Cinsi</th>
                                    <th width="5">Liste Exwork</th>
                                    <th width="5">İskonto (%)</th>
                                    <th width="5">Net Alış</th>
                                    <th width="5">İthalat Katsayısı</th>
                                    <th width="5">Birim Maliyet</th>
                                    <th width="5">Toplam Maliyet</th>
                                    <th width="5">Teklif Katsayısı</th>
                                    <th width="5">Birim Teklif</th>
                                    <th width="5">Toplam Teklif</th>
                                    <th width="5">Teslim Süresi (Gün)</th>
                                    <th width="5">Kar Marjı</th>
                                </tr>
                            </thead>
                            <tbody name="table_2" id="table_2"></tbody>
                        </cf_grid_list>
                    </div>
                </cf_box_elements>
            </cf_box>
        </div>
    </cfoutput>
</cfform>
<script>
    function delete_func(){
        if(confirm("Silmek İstediğinizden Emin misiniz ?"))
            {
                document.getElementById("is_submit_form").value=1;
                return true;
            }
        else
            {
                document.getElementById("is_submit_form").value=0;
                return false;
                window.location.reload();
            }
    }
    function update_func(){
        if(confirm("Güncellemek İstediğinizden Emin misiniz ?"))
            {
                document.getElementById("is_submit_form").value=2;
                return true;
            }
        else
            {
                document.getElementById("is_submit_form").value=0;
                return false;
                window.location.reload();
            }
    }
</script>

<script>
    function discount_control(sayac)
    {
        var export_factor_ = document.getElementById("export_factor"+sayac).value;
            if(export_factor_<= 0)
            {
                alert('İthalat Katsayısı; boş, sıfır yada negatif değer olamaz!');
                document.getElementById("export_factor"+sayac).value = 1;
            }
        var offer_factor_ = document.getElementById("offer_factor"+sayac).value;
            <!---if(offer_factor_ <=0)
            {
                alert('Teklif Katsayısı; boş, sıfır yada negatif değer olamaz!');
                document.getElementById("offer_factor"+sayac).value = 1;
            }--->
        var discount_ = document.getElementById("discount"+sayac).value;
        if(discount_ > 100)
        {
            alert('İskonto Oranı 100 den Fazla Olamaz !');
            document.getElementById("discount"+sayac).value = 0;
            discount_ = 0;
        };
        if(discount_ < 0)
        {
            alert('İskonto Oranı 0 dan Az Olamaz !');
            document.getElementById("discount"+sayac).value = 0;
            discount_ = 0;
        };
        if(0 < discount_ <100)
        {
            var quantity_ = document.getElementById("quantity"+sayac).value;
            if(quantity_!= ""){
                document.getElementById("product_cost"+sayac).value = document.getElementById("product_cost"+sayac).value.replace(',', '.');
                var cost_ = document.getElementById("product_cost"+sayac).value;
                if(cost_ <= 0)
                {
                    alert('Liste Fiyatı Sıfırdan Küçük Olamaz!');
                    document.getElementById("product_cost"+sayac).value = 0;
                    cost_ = 0;
                }
                document.getElementById("export_factor"+sayac).value = document.getElementById("export_factor"+sayac).value.replace(',', '.');
                document.getElementById("offer_factor"+sayac).value = document.getElementById("offer_factor"+sayac).value.replace(',', '.');
                var export_factor_ = document.getElementById("export_factor"+sayac).value;
                var offer_factor_ = document.getElementById("offer_factor"+sayac).value;
                discount_val = cost_*(discount_/100);
                nettotal_cost_ = cost_-discount_val;
                document.getElementById("nettotal_cost"+sayac).value=nettotal_cost_;
                unit_cost_ = nettotal_cost_*export_factor_.replace(',', '.');
                unit_cost_ = unit_cost_.toFixed(2);
                document.getElementById("unit_cost"+sayac).value=unit_cost_;
                var quantity_ = document.getElementById("quantity"+sayac).value;
                total_cost_ = unit_cost_*quantity_;
                document.getElementById("total_cost"+sayac).value=total_cost_;
                if(offer_factor_ == 0){
                    unit_offer_ = 0 ;
                }else{
                    unit_offer_ = unit_cost_ / (offer_factor_.replace(',', '.'));
                }
                unit_offer_ = unit_offer_.toFixed(2);
                document.getElementById("unit_offer"+sayac).value=unit_offer_;
                if(unit_offer_==0){
                    total_offer_=0;
                }else{
                    total_offer_ = unit_offer_*quantity_;

                }

                if(discount_ == 100){
                    profit_margin_ = 0;}
                else{
                    if(total_offer_==0){
                        profit_margin_=0;
                    }else{
                    profit_margin_ = (total_offer_-total_cost_)/total_offer_;
                    }
                }
                if(cost_ == 0){
                    profit_margin_ = 0;}
                else{
                    if(total_offer_==0){
                        profit_margin_=0;
                    }else{
                        profit_margin_ = (total_offer_-total_cost_)/total_offer_;
                    }
                }
               /* if(discount_ == 100)
                    profit_margin_ = 0;
                else
                    profit_margin_ = (total_offer_-total_cost_)/total_offer_;
                    */

                document.getElementById("total_offer"+sayac).value=total_offer_;
                document.getElementById("profit_margin"+sayac).value=Number(profit_margin_.toFixed(2));
            };
        }
    };
    
    function quantity_control(sayac)
    {
        document.getElementById("quantity"+sayac).value = document.getElementById("quantity"+sayac).value.replace(',', '.');

        var quantity_ = document.getElementById("quantity"+sayac).value;
        if(quantity_ <= 0)
        {
            alert('Miktar Sıfır ve ya Daha Küçük Olamaz !');
            document.getElementById("quantity"+sayac).value=1;
        };
        if(quantity_ >= 1)
        {
            var quantity_r = document.getElementById("quantity"+sayac).value;
            unit_cost_r = document.getElementById("unit_cost"+sayac).value;
            total_cost_r = unit_cost_r*quantity_r;
            document.getElementById("total_cost"+sayac).value=total_cost_r;
            unit_offer_r = document.getElementById("unit_offer"+sayac).value;
            total_offer_r = unit_offer_r*quantity_r;
            document.getElementById("total_offer"+sayac).value=total_offer_r;
        }
    }

    function change_group_quantity(sayac)
    {
        var group_quantity_ = document.getElementById("row_group_quantity"+sayac).value;
        var group_name_ = document.getElementById("row_group_name"+sayac).value;

        var name_length = group_name_.length;
        if(name_length > 0)
        {
            for (let i = 1; i <= counter_; i++) 
                {
                console.log(i);
                    if (group_name_== document.getElementById("row_group_name"+i).value) 
                    {
                        console.log(i);
                        document.getElementById("row_group_quantity"+i).value = group_quantity_;
                    }
                };
            console.log(group_quantity_);
            console.log(group_name_);
            console.log(counter_);
        }
    }

    function change_group_money ( sayac )
    {
        var group_money_ = document.getElementById("row_group_money"+sayac).value;
        var group_name_ = document.getElementById("row_group_name"+sayac).value;

        var name_length = group_name_.length;
        if(name_length > 0)
        {
            for (let i = 1; i <= counter_; i++) 
                {
                console.log(i);
                    if (group_name_== document.getElementById("row_group_name"+i).value) 
                    {
                        console.log(i);
                        document.getElementById("row_group_money"+i).value = group_money_;
                    }
                };
            console.log(group_money_);
            console.log(group_name_);
            console.log(counter_);
        }
    }

    function change_group_money_hizmet ( sayac2 )
    {
        var group_money_hizmet_ = document.getElementById("row_group_money_hizmet"+sayac2).value;
        var group_name_hizmet_ = document.getElementById("row_group_name_hizmet"+sayac2).value;

        var name_length = group_money_hizmet_.length;
        if(name_length > 0)
        {
            for (let i = 1; i <= counter_2_; i++) 
                {
                console.log(i);
                    if (group_name_hizmet_== document.getElementById("row_group_name_hizmet"+i).value) 
                    {
                        console.log(i);
                        document.getElementById("row_group_money_hizmet"+i).value = group_money_hizmet_;
                    }
                };
            console.log(group_money_hizmet_);
            console.log(group_name_hizmet_);
            console.log(counter_2_);
        }
    }
    
</script>

<script type="text/javascript">
    var counter_ = 0;
    function table_row_count(){
        var table_1 = document.getElementById("table_1");
        var totalRowCount = table.rows.length;
        console.log(totalRowCount);
        row_count_ = document.getElementById("row_count").value;
        row_count_ = row_count_-1;
        console.log(row_count_);
    }
</script>

<cfoutput query="GET_OFFER_COST_ROW">
    <script type="text/javascript">
            counter_ = ((counter_*1)+1);
            console.log(+counter_+'= counter')
            document.getElementById("row_count").value = counter_;
            console.log(counter_);
            var newRow;
            var newCell;
            
            newRow = document.getElementById("table_1").insertRow(document.getElementById("table_1").rows.length);
            newRow.setAttribute("name","frm_row"+counter_);
            newRow.setAttribute("NAME","frm_row"+counter_);

            console.log('frm_row'+counter_);
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="table_1.deleteRow(this.parentNode.parentNode.rowIndex-1);table_1.deleteRow(this.parentNode.parentNode.parentNode.rowIndex-1);table_row_count();"><i class="fa fa-minus"></i></a>';

            newCell = newRow.insertCell(newRow.cells.length);
            //<select name="money" id="money"><option value="">Seçiniz</option><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#"<cfif OTHER_MONEY eq GET_OFFER_COST_ROW.MONEY>selected</cfif>>#OTHER_MONEY#</option></cfloop></select>
            newCell.innerHTML = '<select name="row_group_name" id="row_group_name"><option value="">Seçiniz</option><cfloop query="#GET_OFFER_COST_GROUP#"><option value="#OFFER_COST_GROUP_NAME#"<cfif OFFER_COST_GROUP_NAME eq GET_OFFER_COST_ROW.ROW_GROUP_NAME>selected</cfif>>#OFFER_COST_GROUP_NAME#</option></cfloop></select>';
            document.getElementById("row_group_name").name = "row_group_name"+counter_;
            document.getElementById("row_group_name").id = "row_group_name"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="number" name="row_group_quantity" id="row_group_quantity" value="#ROW_GROUP_QUANTITY#" onchange="change_group_quantity('+counter_+')">';
            document.getElementById("row_group_quantity").name = "row_group_quantity"+counter_;
            document.getElementById("row_group_quantity").id = "row_group_quantity"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<select name="row_group_money" id="row_group_money" onchange="change_group_money('+counter_+')"><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#"<cfif OTHER_MONEY eq GET_OFFER_COST_ROW.ROW_GROUP_MONEY>selected</cfif>>#OTHER_MONEY#</option></cfloop></select>';
            document.getElementById("row_group_money").name = "row_group_money"+counter_;
            document.getElementById("row_group_money").id = "row_group_money"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
		    newCell.innerHTML = '<select name="is_alternative" id="is_alternative"><option value="0"<cfif IS_ALTERNATIVE eq 0>selected</cfif>>Normal</option><option value="1" <cfif IS_ALTERNATIVE eq 1>selected</cfif>>Yeni Ürün</option><option value="2" <cfif IS_ALTERNATIVE eq 2>selected</cfif>>Opsiyon Ürün</option><option value="3" <cfif IS_ALTERNATIVE eq 3>selected</cfif>>Bakım</option></select>';
            document.getElementById("is_alternative").name = "is_alternative"+counter_;
            document.getElementById("is_alternative").id = "is_alternative"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
		    newCell.innerHTML = '<select name="is_imported" id="is_imported" onchange="change_export_factor('+counter_+')"><option value="1"<cfif IS_IMPORTED eq 1>selected</cfif>>Evet</option><option value="0"<cfif IS_IMPORTED eq 0>selected</cfif>>Hayır</option></select>';
            document.getElementById("is_imported").name = "is_imported"+counter_;
            document.getElementById("is_imported").id = "is_imported"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="manufact_code2" id="manufact_code2" value="#MANUFACT_CODE#">';
            document.getElementById("manufact_code2").name = "manufact_code2"+counter_;
            document.getElementById("manufact_code2").id = "manufact_code2"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="product_code_2" id="product_code_2" value="#PRODUCT_CODE_2#">';
            document.getElementById("product_code_2").name = "product_code_2"+counter_;
            document.getElementById("product_code_2").id = "product_code_2"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="hidden" name="product_id" id="product_id" value="#PRODUCT_ID#"><input type="text" name="product_name" id="product_name" value="#PRODUCT_NAME#"><input type="hidden" name="stock_id" id="stock_id" value="#STOCK_ID#">';
            document.getElementById("product_id").name = "product_id"+counter_;
            document.getElementById("product_id").id = "product_id"+counter_;
            document.getElementById("stock_id").name = "stock_id"+counter_;
            document.getElementById("stock_id").id = "stock_id"+counter_;
            document.getElementById("product_name").name = "product_name"+counter_;
            document.getElementById("product_name").id = "product_name"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="hidden" name="product_unit_id" id="product_unit_id" value="#PRODUCT_UNIT_ID#"><select name="product_unit" id="product_unit"><option value="">Seçiniz</option><cfloop query="#GET_SETUP_UNIT#"><option value="#UNIT#"<cfif UNIT eq GET_OFFER_COST_ROW.PRODUCT_UNIT>selected</cfif>>#UNIT#</option></cfloop></select>';
            document.getElementById("product_unit_id").name = "product_unit_id"+counter_;
            document.getElementById("product_unit_id").id = "product_unit_id"+counter_;
            document.getElementById("product_unit").name = "product_unit"+counter_;
            document.getElementById("product_unit").id = "product_unit"+counter_;
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" id="quantity" name="quantity" min="1" value="#QUANTITY#"onchange="quantity_control('+counter_+')">';
            document.getElementById("quantity").name = "quantity"+counter_;
            document.getElementById("quantity").id = "quantity"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<select name="money" id="money"><option value="">Seçiniz</option><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#"<cfif OTHER_MONEY eq GET_OFFER_COST_ROW.MONEY>selected</cfif>>#OTHER_MONEY#</option></cfloop></select>';
            document.getElementById("money").name = "money"+counter_;
            document.getElementById("money").id = "money"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="product_cost" id="product_cost" value="#PRICE_EXWORK#" onchange="discount_control('+counter_+')">';
            document.getElementById("product_cost").name = "product_cost"+counter_;
            document.getElementById("product_cost").id = "product_cost"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="number" id="discount" name="discount" value="#DISCOUNT#" onchange="discount_control('+counter_+')">';
            document.getElementById("discount").name = "discount"+counter_;
            document.getElementById("discount").id = "discount"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="number" id="nettotal_cost" name="nettotal_cost" value="#NET_PRICE_EXWORK#" readonly>';
            document.getElementById("nettotal_cost").name = "nettotal_cost"+counter_;
            document.getElementById("nettotal_cost").id = "nettotal_cost"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="export_factor" id="export_factor" value="#EXPORT_FACTOR#" onchange="discount_control('+counter_+')">';
            document.getElementById("export_factor").name = "export_factor"+counter_;
            document.getElementById("export_factor").id = "export_factor"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="unit_cost" id="unit_cost" value="#UNIT_COST#" readonly>';
            document.getElementById("unit_cost").name = "unit_cost"+counter_;
            document.getElementById("unit_cost").id = "unit_cost"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="total_cost" id="total_cost" value="#TOTAL_COST#" readonly>';
            document.getElementById("total_cost").name = "total_cost"+counter_;
            document.getElementById("total_cost").id = "total_cost"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="offer_factor" id="offer_factor" value="#OFFER_FACTOR#" onchange="discount_control('+counter_+')">';
            document.getElementById("offer_factor").name = "offer_factor"+counter_;
            document.getElementById("offer_factor").id = "offer_factor"+counter_;
            
            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="unit_offer" id="unit_offer" value="#UNIT_OFFER#" readonly>';
            document.getElementById("unit_offer").name = "unit_offer"+counter_;
            document.getElementById("unit_offer").id = "unit_offer"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="total_offer" id="total_offer" value="#TOTAL_OFFER#" readonly>';
            document.getElementById("total_offer").name = "total_offer"+counter_;
            document.getElementById("total_offer").id = "total_offer"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="provision_time" id="provision_time" value="#PROVISION_TIME#">';
            document.getElementById("provision_time").name = "provision_time"+counter_;
            document.getElementById("provision_time").id = "provision_time"+counter_;

            newCell = newRow.insertCell(newRow.cells.length);
            newCell.innerHTML = '<input type="text" name="profit_margin" id="profit_margin" value="#PROFIT_MARGIN#" onchange="discount_control('+counter_+')">';
            document.getElementById("profit_margin").name = "profit_margin"+counter_;
            document.getElementById("profit_margin").id = "profit_margin"+counter_;

            //window.open("<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id"+counter_+"&field_name=form_offer_cost.product_name"+counter_+"&field_total_price=form_offer_cost.product_cost"+counter_+"&field_unit=form_offer_cost.product_unit"+counter_+"&field_unit_id=form_offer_cost.product_unit_id"+counter_+"&field_amount=form_offer_cost.quantity"+counter_+"&field_money=form_offer_cost.money"+counter_+"");
            //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_+'&field_name=form_offer_cost.product_name'+counter_+'&field_total_price=form_offer_cost.product_cost'+counter_+'&field_unit=form_offer_cost.product_unit'+counter_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_+'&field_amount=form_offer_cost.quantity'+counter_+'&field_money=form_offer_cost.money'+counter_+'');
    </script>
</cfoutput>

<script type="text/javascript">
    var counter_ = document.getElementById("row_count").value;
	function add_row(barcode,amount,name)
	{
        counter_ = ((counter_*1)+1);
        document.getElementById("row_count").value = counter_;
        console.log(counter_);
		var newRow;
		var newCell;
		
		newRow = document.getElementById("table_1").insertRow(document.getElementById("table_1").rows.length);
		newRow.setAttribute("name","frm_row"+counter_);
		newRow.setAttribute("NAME","frm_row"+counter_);

        console.log('frm_row'+counter_);
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="table_1.deleteRow(this.parentNode.parentNode.rowIndex-1)"><i class="fa fa-minus"></i></a>';

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<select name="row_group_name" id="row_group_name"><option value="">Seçiniz</option><cfoutput query="GET_OFFER_COST_GROUP"><option value="#OFFER_COST_GROUP_NAME#">#OFFER_COST_GROUP_NAME#</option></cfoutput></select>';
        document.getElementById("row_group_name").name = "row_group_name"+counter_;
        document.getElementById("row_group_name").id = "row_group_name"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="number" name="row_group_quantity" id="row_group_quantity" value="1" onchange="change_group_quantity('+counter_+')">';
        document.getElementById("row_group_quantity").name = "row_group_quantity"+counter_;
        document.getElementById("row_group_quantity").id = "row_group_quantity"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="row_group_money" id="row_group_money"><cfoutput query="GET_OTHER_MONEY"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfoutput></select>';
        document.getElementById("row_group_money").name = "row_group_money"+counter_;
        document.getElementById("row_group_money").id = "row_group_money"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="is_alternative" id="is_alternative"><option value="0">Normal</option><option value="1">Yeni Ürün</option><option value="2">Opsiyon Ürün</option><option value="3">Bakım</option></select>';
        document.getElementById("is_alternative").name = "is_alternative"+counter_;
        document.getElementById("is_alternative").id = "is_alternative"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="is_imported" id="is_imported" onchange="change_export_factor('+counter_+')"><option value="">Seçiniz</option><option value="1">Evet</option><option value="0">Hayır</option></select>';
        document.getElementById("is_imported").name = "is_imported"+counter_;
        document.getElementById("is_imported").id = "is_imported"+counter_;
        
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="text" name="manufact_code2" id="manufact_code2" value="">';
        document.getElementById("manufact_code2").name = "manufact_code2"+counter_;
        document.getElementById("manufact_code2").id = "manufact_code2"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="text" name="product_code_2" id="product_code_2" value="">';
        document.getElementById("product_code_2").name = "product_code_2"+counter_;
        document.getElementById("product_code_2").id = "product_code_2"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="product_id" id="product_id" value=""><input type="text" name="product_name" id="product_name" value=""><input type="hidden" name="stock_id" id="stock_id" value="">';
        document.getElementById("product_id").name = "product_id"+counter_;
        document.getElementById("product_id").id = "product_id"+counter_;
        document.getElementById("stock_id").name = "stock_id"+counter_;
        document.getElementById("stock_id").id = "stock_id"+counter_;
        document.getElementById("product_name").name = "product_name"+counter_;
        document.getElementById("product_name").id = "product_name"+counter_;

		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="hidden" name="product_unit_id" id="product_unit_id" value=""><select name="product_unit" id="product_unit"><option value="">Seçiniz</option><cfoutput query="GET_SETUP_UNIT"><option value="#UNIT#">#UNIT#</option></cfoutput></select>';
        document.getElementById("product_unit_id").name = "product_unit_id"+counter_;
        document.getElementById("product_unit_id").id = "product_unit_id"+counter_;
        document.getElementById("product_unit").name = "product_unit"+counter_;
        document.getElementById("product_unit").id = "product_unit"+counter_;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity" name="quantity" min="1" value="1" onchange="quantity_control('+counter_+')">';
        document.getElementById("quantity").name = "quantity"+counter_;
        document.getElementById("quantity").id = "quantity"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="money" id="money"><option value="">Seçiniz</option><cfoutput query="GET_OTHER_MONEY"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfoutput></select>';
        document.getElementById("money").name = "money"+counter_;
        document.getElementById("money").id = "money"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="product_cost" id="product_cost" value="" onchange="discount_control('+counter_+')">';
        document.getElementById("product_cost").name = "product_cost"+counter_;
        document.getElementById("product_cost").id = "product_cost"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="number" id="discount" name="discount" value="0" onchange="discount_control('+counter_+')">';
        document.getElementById("discount").name = "discount"+counter_;
        document.getElementById("discount").id = "discount"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="nettotal_cost" id="nettotal_cost" value="" readonly>';
        document.getElementById("nettotal_cost").name = "nettotal_cost"+counter_;
        document.getElementById("nettotal_cost").id = "nettotal_cost"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="export_factor" id="export_factor" value="1" onchange="discount_control('+counter_+')">';
        document.getElementById("export_factor").name = "export_factor"+counter_;
        document.getElementById("export_factor").id = "export_factor"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="unit_cost" id="unit_cost" value="" readonly>';
        document.getElementById("unit_cost").name = "unit_cost"+counter_;
        document.getElementById("unit_cost").id = "unit_cost"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="total_cost" id="total_cost" value="" readonly>';
        document.getElementById("total_cost").name = "total_cost"+counter_;
        document.getElementById("total_cost").id = "total_cost"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="offer_factor" id="offer_factor" value="1" onchange="discount_control('+counter_+')">';
        document.getElementById("offer_factor").name = "offer_factor"+counter_;
        document.getElementById("offer_factor").id = "offer_factor"+counter_;
        
        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="unit_offer" id="unit_offer" value="" readonly>';
        document.getElementById("unit_offer").name = "unit_offer"+counter_;
        document.getElementById("unit_offer").id = "unit_offer"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="total_offer" id="total_offer" value="" readonly>';
        document.getElementById("total_offer").name = "total_offer"+counter_;
        document.getElementById("total_offer").id = "total_offer"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="provision_time" id="provision_time" value="">';
        document.getElementById("provision_time").name = "provision_time"+counter_;
        document.getElementById("provision_time").id = "provision_time"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" name="profit_margin" id="profit_margin" value="" onchange="discount_control('+counter_+')">';
        document.getElementById("profit_margin").name = "profit_margin"+counter_;
        document.getElementById("profit_margin").id = "profit_margin"+counter_;

        //window.open("<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id"+counter_+"&field_name=form_offer_cost.product_name"+counter_+"&field_total_price=form_offer_cost.product_cost"+counter_+"&field_unit=form_offer_cost.product_unit"+counter_+"&field_unit_id=form_offer_cost.product_unit_id"+counter_+"&field_amount=form_offer_cost.quantity"+counter_+"&field_money=form_offer_cost.money"+counter_+"");
        //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_+'&field_stock_id=form_offer_cost.stock_id'+counter_+'&field_name=form_offer_cost.product_name'+counter_+'&field_total_price=form_offer_cost.product_cost'+counter_+'&field_unit=form_offer_cost.product_unit'+counter_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_+'&field_amount=form_offer_cost.quantity'+counter_+'&field_money=form_offer_cost.money'+counter_+'');
        //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_+'&field_stock_id=form_offer_cost.stock_id'+counter_+'&field_name=form_offer_cost.product_name'+counter_+'&field_total_price=form_offer_cost.product_cost'+counter_+'&field_unit=form_offer_cost.product_unit'+counter_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_+'&field_amount=form_offer_cost.quantity'+counter_+'&field_money=form_offer_cost.money'+counter_+'&field_manufact_code=form_offer_cost.manufact_code2'+counter_+'&field_product_code_2=form_offer_cost.product_code_2'+counter_+'&field_total_price2=form_offer_cost.nettotal_cost'+counter_+'');
    }
    
    function add_row_p()
    {
        openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_unit_set</cfoutput>');
    }
</script>

<script>
    function change_export_factor(sayac)
    {
        var is_imported_js = document.getElementById("is_imported"+sayac).value;
        if(is_imported_js == 1)
        {
            document.getElementById("export_factor"+sayac).value = 1.1;
            discount_control(sayac);
        }
        if(is_imported_js == 0)
        {
            document.getElementById("export_factor"+sayac).value = 1;
            discount_control(sayac);
        }
    }
</script>

<!---
<cfinclude template="../../../objects/display/display_member_risk.cfm"><!--- Risk --->
--->

<cfif control_service_product.recordcount eq 0>
    <cfquery name="GET_PRODUCT" datasource="#DSN1#">
        SELECT
            P.PRODUCT_ID,
            P.MANUFACT_CODE,
            P.PRODUCT_CODE_2,
            S.STOCK_ID,
            P.PRODUCT_NAME,
            PU.PRODUCT_UNIT_ID,
            PR.PRICE,
            PR.MONEY,
            PU.MAIN_UNIT_ID,
            PU.MAIN_UNIT,
            PC.PRODUCT_CAT AS PRODUCT_CAT,
            PGP.IS_IMPORTED
        FROM
            PRODUCT P
            LEFT JOIN STOCKS S ON S.PRODUCT_ID = P.PRODUCT_ID
            LEFT JOIN #DSN3#.PRICE_STANDART PR ON PR.PRODUCT_ID = P.PRODUCT_ID
            LEFT JOIN PRODUCT_UNIT PU ON PU.PRODUCT_ID = P.PRODUCT_ID
            LEFT JOIN #DSN#.SETUP_UNIT SU ON SU.UNIT_ID = PU.MAIN_UNIT_ID
            LEFT JOIN PRODUCT_CAT PC ON PC.PRODUCT_CATID = P.PRODUCT_CATID
            LEFT JOIN PRODUCT_GENERAL_PARAMETERS PGP ON PGP.PRODUCT_ID = P.PRODUCT_ID
        WHERE
            PC.PRODUCT_CATID = 588
            AND
            PR.PURCHASESALES = 0
            AND
            PR.PRICESTANDART_STATUS = 1
    </cfquery>

<script type="text/javascript">
    var counter_2_ = 0;
    function table_row_count_2(){
        var table_2 = document.getElementById("table_2");
        var totalRowCount_2 = table.rows.length;
        //console.log(totalRowCount);
        row_count_2_ = document.getElementById("row_count_2").value;
        row_count_2_ = row_count_2_-1;
        //console.log(row_count_);
    }
</script>

<cfoutput query="GET_PRODUCT">
    <script type="text/javascript">
            counter_2_ = ((counter_2_*1)+1);
            //console.log(+counter_2_+'= counter')
            document.getElementById("row_count_2").value = counter_2_;
            //console.log(counter_2_);
            var newRow_2;
            var newCell_2;
            
            newRow_2 = document.getElementById("table_2").insertRow(document.getElementById("table_2").rows.length);
            newRow_2.setAttribute("name","frm_row"+counter_2_);
            newRow_2.setAttribute("NAME","frm_row"+counter_2_);

            //console.log('frm_row'+counter_2_);
            
            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="table_2.deleteRow(this.parentNode.parentNode.rowIndex-1);table_1.deleteRow(this.parentNode.parentNode.parentNode.rowIndex-1);table_row_count();"><i class="fa fa-minus"></i></a>';

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<select name="row_group_name_hizmet" id="row_group_name_hizmet"><option value="Hizmet">Hizmet</option><!---<cfloop query="#GET_OFFER_COST_GROUP#"><option value="#OFFER_COST_GROUP_NAME#">#OFFER_COST_GROUP_NAME#</option></cfloop>---></select>';
            document.getElementById("row_group_name_hizmet").name = "row_group_name_hizmet"+counter_2_;
            document.getElementById("row_group_name_hizmet").id = "row_group_name_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="row_group_quantity_hizmet" id="row_group_quantity_hizmet" value="1">';
            document.getElementById("row_group_quantity_hizmet").name = "row_group_quantity_hizmet"+counter_2_;
            document.getElementById("row_group_quantity_hizmet").id = "row_group_quantity_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<select name="row_group_money_hizmet" id="row_group_money_hizmet" onchange="change_group_money_hizmet('+counter_2_+')"><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfloop></select>';
            document.getElementById("row_group_money_hizmet").name = "row_group_money_hizmet"+counter_2_;
            document.getElementById("row_group_money_hizmet").id = "row_group_money_hizmet"+counter_2_;
            
            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<select name="is_alternative_hizmet" id="is_alternative_hizmet"><option value="0">Normal</option><option value="1">Yeni Ürün</option><option value="2">Opsiyon Ürün</option><option value="3">Bakım</option></select>';
            document.getElementById("is_alternative_hizmet").name = "is_alternative_hizmet"+counter_2_;
            document.getElementById("is_alternative_hizmet").id = "is_alternative_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<select name="is_imported_hizmet" id="is_imported_hizmet"><option value="1"<cfif IS_IMPORTED eq 1>selected</cfif>>Evet</option><option value="0"<cfif IS_IMPORTED eq 0 or IS_IMPORTED eq ''>selected</cfif>>Hayır</option></select>';
            document.getElementById("is_imported_hizmet").name = "is_imported_hizmet"+counter_2_;
            document.getElementById("is_imported_hizmet").id = "is_imported_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="manufact_code2_hizmet" id="manufact_code2_hizmet" value="#MANUFACT_CODE#">';
            document.getElementById("manufact_code2_hizmet").name = "manufact_code2_hizmet"+counter_2_;
            document.getElementById("manufact_code2_hizmet").id = "manufact_code2_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="product_code_2_hizmet" id="product_code_2_hizmet" value="#PRODUCT_CODE_2#">';
            document.getElementById("product_code_2_hizmet").name = "product_code_2_hizmet"+counter_2_;
            document.getElementById("product_code_2_hizmet").id = "product_code_2_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="hidden" name="product_id_hizmet" id="product_id_hizmet" value="#PRODUCT_ID#"><input type="text" name="product_name_hizmet" id="product_name_hizmet" value="#PRODUCT_NAME#"><input type="hidden" name="stock_id_hizmet" id="stock_id_hizmet" value="#STOCK_ID#">';
            document.getElementById("product_id_hizmet").name = "product_id_hizmet"+counter_2_;
            document.getElementById("product_id_hizmet").id = "product_id_hizmet"+counter_2_;
            document.getElementById("stock_id_hizmet").name = "stock_id_hizmet"+counter_2_;
            document.getElementById("stock_id_hizmet").id = "stock_id_hizmet"+counter_2_;
            document.getElementById("product_name_hizmet").name = "product_name_hizmet"+counter_2_;
            document.getElementById("product_name_hizmet").id = "product_name_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="hidden" name="product_unit_id_hizmet" id="product_unit_id_hizmet" value="#PRODUCT_UNIT_ID#"><select name="product_unit_hizmet" id="product_unit_hizmet"><option value="">Seçiniz</option><cfloop query="#GET_SETUP_UNIT#"><option value="#UNIT#"<cfif UNIT eq GET_PRODUCT.MAIN_UNIT>selected</cfif>>#UNIT#</option></cfloop></select>';
            document.getElementById("product_unit_id_hizmet").name = "product_unit_id_hizmet"+counter_2_;
            document.getElementById("product_unit_id_hizmet").id = "product_unit_id_hizmet"+counter_2_;
            document.getElementById("product_unit_hizmet").name = "product_unit_hizmet"+counter_2_;
            document.getElementById("product_unit_hizmet").id = "product_unit_hizmet"+counter_2_;
            
            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="number" id="quantity_hizmet" name="quantity_hizmet" min="1" value="1" onchange="quantity_control('+counter_2_+')">';
            document.getElementById("quantity_hizmet").name = "quantity_hizmet"+counter_2_;
            document.getElementById("quantity_hizmet").id = "quantity_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<select name="money_hizmet" id="money_hizmet"><option value="">Seçiniz</option><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#"<cfif OTHER_MONEY eq GET_PRODUCT.MONEY>selected</cfif>>#OTHER_MONEY#</option></cfloop></select>';
            document.getElementById("money_hizmet").name = "money_hizmet"+counter_2_;
            document.getElementById("money_hizmet").id = "money_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="product_cost_hizmet" id="product_cost_hizmet" value="#PRICE#" onchange="discount_control('+counter_2_+')">';
            document.getElementById("product_cost_hizmet").name = "product_cost_hizmet"+counter_2_;
            document.getElementById("product_cost_hizmet").id = "product_cost_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="number" id="discount_hizmet" name="discount_hizmet" value="0" onchange="discount_control('+counter_2_+')">';
            document.getElementById("discount_hizmet").name = "discount_hizmet"+counter_2_;
            document.getElementById("discount_hizmet").id = "discount_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="number" id="nettotal_cost_hizmet" name="nettotal_cost_hizmet" value="#PRICE#" readonly>';
            document.getElementById("nettotal_cost_hizmet").name = "nettotal_cost_hizmet"+counter_2_;
            document.getElementById("nettotal_cost_hizmet").id = "nettotal_cost_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="export_factor_hizmet" id="export_factor_hizmet" value="1" onchange="discount_control('+counter_2_+')">';
            document.getElementById("export_factor_hizmet").name = "export_factor_hizmet"+counter_2_;
            document.getElementById("export_factor_hizmet").id = "export_factor_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="unit_cost_hizmet" id="unit_cost_hizmet" value="#PRICE#" readonly>';
            document.getElementById("unit_cost_hizmet").name = "unit_cost_hizmet"+counter_2_;
            document.getElementById("unit_cost_hizmet").id = "unit_cost_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="total_cost_hizmet" id="total_cost_hizmet" value="#PRICE#" readonly>';
            document.getElementById("total_cost_hizmet").name = "total_cost_hizmet"+counter_2_;
            document.getElementById("total_cost_hizmet").id = "total_cost_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="offer_factor_hizmet" id="offer_factor_hizmet" value="1" onchange="discount_control('+counter_2_+')">';
            document.getElementById("offer_factor_hizmet").name = "offer_factor_hizmet"+counter_2_;
            document.getElementById("offer_factor_hizmet").id = "offer_factor_hizmet"+counter_2_;
            
            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="unit_offer_hizmet" id="unit_offer_hizmet" value="#PRICE#" readonly>';
            document.getElementById("unit_offer_hizmet").name = "unit_offer_hizmet"+counter_2_;
            document.getElementById("unit_offer_hizmet").id = "unit_offer_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="total_offer_hizmet" id="total_offer_hizmet" value="#PRICE#" readonly>';
            document.getElementById("total_offer_hizmet").name = "total_offer_hizmet"+counter_2_;
            document.getElementById("total_offer_hizmet").id = "total_offer_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="provision_time_hizmet" id="provision_time_hizmet" value="">';
            document.getElementById("provision_time_hizmet").name = "provision_time_hizmet"+counter_2_;
            document.getElementById("provision_time_hizmet").id = "provision_time_hizmet"+counter_2_;

            newCell_2 = newRow_2.insertCell(newRow_2.cells.length);
            newCell_2.innerHTML = '<input type="text" name="profit_margin_hizmet" id="profit_margin_hizmet" value="" onchange="discount_control('+counter_2_+')">';
            document.getElementById("profit_margin_hizmet").name = "profit_margin_hizmet"+counter_2_;
            document.getElementById("profit_margin_hizmet").id = "profit_margin_hizmet"+counter_2_;

            //window.open("<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id"+counter_2_+"&field_name=form_offer_cost.product_name"+counter_2_+"&field_total_price=form_offer_cost.product_cost"+counter_2_+"&field_unit=form_offer_cost.product_unit"+counter_2_+"&field_unit_id=form_offer_cost.product_unit_id"+counter_2_+"&field_amount=form_offer_cost.quantity"+counter_2_+"&field_money=form_offer_cost.money"+counter_2_+"");
            //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_2_+'&field_name=form_offer_cost.product_name'+counter_2_+'&field_total_price=form_offer_cost.product_cost'+counter_2_+'&field_unit=form_offer_cost.product_unit'+counter_2_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_2_+'&field_amount=form_offer_cost.quantity'+counter_2_+'&field_money=form_offer_cost.money'+counter_2_+'');
    </script>
</cfoutput>

    <script>
        function show_service_product() {
        var x = document.getElementById("service_product");
        if (x.style.display === "block") {
            x.style.display = "none";
        } else {
            x.style.display = "block";
        }
        }
    </script>
</cfif>


	<cfcatch  type="any">
		<cfsavecontent variable="ssss">
			<cfdump var="#cfcatch#">
		</cfsavecontent>
	<cffile action="write" output="#ssss#" file="#application.systemparam.systemparam().download_folder#hataaaaa.html">
	</cfcatch>
</cftry>