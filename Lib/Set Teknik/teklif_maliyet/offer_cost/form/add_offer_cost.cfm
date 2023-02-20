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

<!---Başlık kısmı için eklendi -Kerem Ümit--->
<cfquery name="get_dept_code" datasource="#DSN#">
    SELECT 
        EP.POSITION_ID,
        D.SPECIAL_CODE2
    FROM EMPLOYEE_POSITIONS AS EP
    LEFT JOIN DEPARTMENT AS D ON D.DEPARTMENT_ID=EP.DEPARTMENT_ID
    WHERE POSITION_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.position_code#">
</cfquery>
<cfquery name="get_last_cost_id" datasource="#DSN3#">
    SELECT TOP (1) OFFER_COST_ID FROM OFFER_COST ORDER BY OFFER_COST_ID DESC
</cfquery>
<cfset new_cost_id=#get_last_cost_id.OFFER_COST_ID#+1>

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
<cfquery name="get_offer_number" datasource="#DSN3#">
    SELECT
        OFFER_COST_NUMBER_ID,
        DEPT_SPECIAL_CODE AS OC_CODE,
        DEPT_OFFER_COST_NUMBER AS OC_NUMBER
    FROM OFFER_COST_NUMBER
    WHERE DEPT_SPECIAL_CODE = '#get_dept_code.SPECIAL_CODE2#'
</cfquery>
<cf_catalystHeader>

<cfform name="form_offer_cost" method="post" enctype="multipart/form-data" action="#request.self#?fuseaction=sales.emptypopup_add_offer_cost">
    <input type="hidden" name="offer_cost_id" id="offer_cost_id"  value="">
    <input type="hidden" name="is_submit_form" id="is_submit_form" value="">
    <input type="hidden" name="row_count" id="row_count" value="">
    <cfoutput>
        <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
            <cf_box title="Müşteri Bilgileri">
                <cf_box_elements>
                    <div class="col col-4 col-md-4 col-sm-12" type="column" index="0" sort="true">
                        <!--- Satış Yapan       -Kerem Ümit Üçler 14.11.2022--->
                    <div class="form-group" id="item-sales_emp">
                        <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='40903.Satış Yapan'></label>
                        <div class="col col-8 col-sm-12">
                            <div class="input-group">
                                <input type="hidden" name="offer_cost_number_id" id="offer_cost_number_id" value="<cfif isDefined('get_offer_number.OFFER_COST_NUMBER_ID') and len(get_offer_number.OFFER_COST_NUMBER_ID)>#get_offer_number.OFFER_COST_NUMBER_ID#</cfif>">
                                <input type="hidden" name="sales_emp_id" id="sales_emp_id" value="<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#attributes.sales_emp_id#</cfif>">
                                <input type="text" name="sales_emp" id="sales_emp" value="<cfif isdefined("attributes.sales_emp_id") and len(attributes.sales_emp_id)>#get_emp_info(attributes.sales_emp_id,0,0)#</cfif>" onFocus="AutoComplete_Create('sales_emp','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','3','EMPLOYEE_ID','sales_emp_id','','3','125');" autocomplete="off">
                                <span class="input-group-addon btnPointer icon-ellipsis" onClick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_positions&field_emp_id=form_offer_cost.sales_emp_id&field_name=form_offer_cost.sales_emp&select_list=1');"></span>
                            </div>
                        </div>
                    </div>
                        <div class="form-group" id="item-offer_cost_status">
                            <label><cf_get_lang dictionary_id='57493.Aktif'><input type="checkbox" name="offer_cost_status" id="offer_cost_status" value="1" checked></label>&nbsp;&nbsp;&nbsp;
                        </div>
                        <div class="form-group" id="item-process_stage">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id="58859.Süreç"></label>
                            <div class="col col-8 col-sm-12">
                                <cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
                            </div>
                        </div>
                        <div class="form-group" id="item-offer_cost_head">
                            <label class="col col-4 col-sm-12">Teklif Maliyet Numarası-Test</label>
                            <div class="col col-8 col-sm-12">
                                <cfinput type="text" id="offer_cost_head" name="offer_cost_head" value="#get_offer_number.OC_CODE#-#dateformat(now(),'yy')#-#numberFormat(get_offer_number.OC_NUMBER,'0000')#" maxlength="200" required="yes" message="#getLang('','Başlık Girmelisiniz',58059)# !">
                            </div><!----////---#get_dept_code.SPECIAL_CODE2#-#dateformat(now(),'yy')#-#new_cost_id#--->
                        </div>
                        <div class="form-group" id="item-offer_cost_detail">
                            <label class="col col-4 col-sm-12"><cf_get_lang dictionary_id='57629.açıklama'></label>
                            <div class="col col-8 col-sm-12">
                                <textarea style="height:100px;" name="offer_cost_detail" id="offer_cost_detail" value=""></textarea>
                            </div>
                        </div>
                        <div class="form-group" id="item-member_name">
                            <input type="hidden" name="consumer_id" id="consumer_id"  value="<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                            <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#get_partner.company_id#</cfoutput></cfif>">
                        </div>
                        <cf_duxi name="about_company" id="about_company" type="text" data="" hint="şirket" label="57574" threepoint="#request.self#?fuseaction=objects.popup_list_pars&field_comp_id=form_offer_cost.company_id&is_period_kontrol=0&field_comp_name=form_offer_cost.about_company&field_partner=form_offer_cost.partner_id&field_consumer=form_offer_cost.consumer_id&field_name=form_offer_cost.about_par_name&par_con=1&select_list=2,3">
                        <div class="form-group" id="form_ul_about_par_name">
                            <label class="col col-4 col-md-4 col-sm-4 col-xs-12"><cf_get_lang dictionary_id='57578.Yetkili'></label>
                            <div class="col col-8 col-md-8 col-sm-8 col-xs-12">
                                <input type="hidden" name="partner_id" id="partner_id" value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#attributes.partner_id#</cfoutput></cfif>">
                                <input type="text" name="about_par_name" id="about_par_name"   value="<cfif isdefined("attributes.partner_id") and len(attributes.partner_id)><cfoutput>#get_partner.company_partner_name# #get_partner.company_partner_surname#</cfoutput><cfelseif isdefined("attributes.consumer_id")><cfoutput>#get_consumer.consumer_name# #get_consumer.consumer_surname#</cfoutput></cfif>">
                            </div>
                        </div>
                        <cf_duxi name="related_project_id" type="hidden" value="">
                        <cf_duxi name="related_project_head" type="text" data="" placeholder="58459" label="34997" threepoint= "#request.self#?fuseaction=objects.popup_list_projects&project_head=form_offer_cost.related_project_head&project_id=form_offer_cost.related_project_id">
                    </div>
                    <div class="col col-4 col-md-4 col-sm-12" type="column" index="1" sort="true">
                        <div class="form-group require" id="item-offer_cost_date">
                            <label class="col col-4 col-sm-12">Tarih</label>
                            <div class="col col-8 col-sm-12">
                                <div class="input-group">
                                    <cfinput type="text" name="offer_cost_date" id="offer_cost_date"  value="#dateformat(now(),dateformat_style)#" validate="#validate_style#" maxlength="10">
                                    <span class="input-group-addon"><cf_wrk_date_image date_field="offer_cost_date"></span>
                                </div>
				            </div>                
			            </div>
                    </div>
                </cf_box_elements>
                <cf_box_footer>
                        <cf_workcube_buttons is_upd='0' add_function="number_control()" >
                            <!---<input type="button" value="test butonudur lütfen tıklamayınız" onClick="number_control()">--->
                </cf_box_footer>
            </cf_box>
            <cf_box title="Hizmet Ürünleri">
                <cf_box_elements>
                    <div class="col col-4 col-md-4 col-sm-12">
                        <div class="form-group require" id="item-offer_cost_service_product">
                            <label class="col col-4 col-sm-12">Hizmet Ürünlerini Dahil Etme</label>
                            <div class="col col-8 col-sm-12">
                                <div class="input-group">
                                    <input type="checkbox" id="include_service_product" name="include_service_product" value="1" onclick="show_service_product()">
                                </div>
                            </div>
                        </div>
                    </div>
                </cf_box_elements>
            </cf_box>
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
                            <tbody name="table_2" id="table_2"></tbody>
                        </cf_grid_list>
                    </div>
                    <div style="width:100%; display:block" id="service_product">
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
                            <tbody name="table_1" id="table_1"></tbody>
                        </cf_grid_list>
                    </div>
                </cf_box_elements>
            </cf_box>
        </div>
    </cfoutput>
</cfform>

<script>
    function number_control(){
        var oc_number=document.getElementById("offer_cost_head").value;/*teklif maliyet numarası alınıyor*/
        var sql_oc_number= "SELECT OFFER_COST_HEAD FROM OFFER_COST WHERE OFFER_COST_HEAD  ='"+oc_number+"'";/*teklif maliyet numarası sorgulanıyor*/
        new_sql_oc_number = wrk_query(sql_oc_number,'dsn3');
        var str_length=oc_number.length;/*string parcalama ve birlestirme isleminde kullaniliyor*/
        /*verilen sayiyi 0 ile maskelemek icin kucuk bir function*/
        function padWithLeadingZeros(num, totalLength) {
        
            return String(num).padStart(totalLength, '0');
        }

        if(new_sql_oc_number.recordcount >0){/*teklif maliyet no mevcutsa*/
            var lastFour = oc_number.substr(oc_number.length - 4);/*maliyet nosunun son 4 basamagi aliniyor*/
            var new_first_str=oc_number.slice(0, (str_length-4));/*maliyet nosunun son 4 basamagi haric aliniyor*/
            var new_last_four=parseInt(lastFour)+1;/*maliyet nosunun son 4 basamagi integera convert edilip 1 artiriliyor*/
            
            if(new_last_four.toString().length<4){/*elde edilen int deger 4 digit degilse*/
                var new_last_four_=new_last_four;
                for(i=new_last_four.toString().length;i<=4;i++){/*4 digit olana kadar 0 ile maskeliyoruz*/
                    new_last_four_=padWithLeadingZeros(new_last_four_, 4);
                    console.log(new_last_four_);
                }
            }
            var new_oc_number=new_first_str+new_last_four_;/*stringi birlestirip value'yu degistiriyoruz*/
            document.getElementById("offer_cost_head").value=new_oc_number;

            alert("Teklif maliyet numarası kullanılmaktadır. Numara otomatik bir arttırılacaktır. Tekrar kaydediniz!")
            
            return false;

        }
    }
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
                document.getElementById("product_cost"+sayac).value = document.getElementById("product_cost"+sayac).value.replace(',','.');
                var cost_ = document.getElementById("product_cost"+sayac).value;
                if(cost_ <= 0)
                {
                    alert('Liste Fiyatı Sıfırdan Küçük Olamaz!');
                    document.getElementById("product_cost"+sayac).value = 0;
                    cost_ = 0;
                }
                document.getElementById("export_factor"+sayac).value = document.getElementById("export_factor"+sayac).value.replace(',','.');
                document.getElementById("offer_factor"+sayac).value = document.getElementById("offer_factor"+sayac).value.replace(',','.');
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
                    unit_offer_ = 0;
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
                    profit_margin_ = 0;
                }
                else{
                    if(total_offer_==0){
                        profit_margin_ = 0;
                    }else{
                        profit_margin_ = (total_offer_-total_cost_)/total_offer_;
                    }
                }
                if(cost_ == 0){
                    profit_margin_ = 0;

                }
                else{
                    if(total_offer_==0){
                        profit_margin_=0;
                    }
                    else{
                        profit_margin_ = (total_offer_-total_cost_)/total_offer_;
                    }
                }
                document.getElementById("total_offer"+sayac).value=total_offer_;
                document.getElementById("profit_margin"+sayac).value=Number(profit_margin_.toFixed(2));
            };
        }
    };
    function quantity_control(sayac)
    {
        document.getElementById("quantity"+sayac).value = document.getElementById("quantity"+sayac).value.replace(',','.');

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
    };
    <!---function money_control(){
    var i=1;
    var selected_groups=[];
    var group_name_= new Array();
    var group_opt= new Array();
    var table = document.getElementById("table_1");
    var table_ = document.getElementById("table_2");
    var totalRowCount = table.rows.length;
    totalRowCount = totalRowCount+ table_.rows.length;
    for( i=1 ; i<=totalRowCount ; i++ ){
        group_opt[i] = document.getElementById("row_group_name"+i);
        group_name_[i]=group_opt[i].value;
        group_name_text=group_opt[i].options[group_opt[i].selectedIndex].text;
        selected_groups.push(group_name_text);
        console.log(group_opt[i])
        console.log(group_name_[i])
    } 
    let filteredGroups = [...new Set(selected_groups)];
    console.table(filteredGroups);

    for(i=1;i<=totalRowCount;i++){

    }       
    //console.table(selected_groups);
    /*const selected_money_=document.getElementById('money'+i).value;*/
    }--->
    
    function change_group_quantity ( sayac )
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
</script>

<script type="text/javascript">
    var counter_ = 0;
    function table_row_count(){
        var table = document.getElementById("table_1");
        var totalRowCount = table.rows.length;
        //console.log(totalRowCount);
        row_count_ = document.getElementById("row_count").value;
        row_count_ = row_count_-1;
        //console.log(row_count_);
    }
</script>

    <cfoutput query="GET_PRODUCT">
        <script type="text/javascript">
                counter_ = ((counter_*1)+1);
                //console.log(+counter_+'= counter')
                document.getElementById("row_count").value = counter_;
                //console.log(counter_);
                var newRow;
                var newCell;
                
                newRow = document.getElementById("table_1").insertRow(document.getElementById("table_1").rows.length);
                newRow.setAttribute("name","frm_row"+counter_);
                newRow.setAttribute("NAME","frm_row"+counter_);

                //console.log('frm_row'+counter_);
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="table_1.deleteRow(this.parentNode.parentNode.rowIndex-1);table_1.deleteRow(this.parentNode.parentNode.parentNode.rowIndex-1);table_row_count();"><i class="fa fa-minus"></i></a>';
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<select name="row_group_name" id="row_group_name"><option value="Hizmet">Hizmet</option><!---<cfloop query="#GET_OFFER_COST_GROUP#"><option value="#OFFER_COST_GROUP_NAME#">#OFFER_COST_GROUP_NAME#</option></cfloop>---></select>';
                document.getElementById("row_group_name").name = "row_group_name"+counter_;
                document.getElementById("row_group_name").id = "row_group_name"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="number" name="row_group_quantity" id="row_group_quantity" value="1" onchange="change_group_quantity('+counter_+')">';
                document.getElementById("row_group_quantity").name = "row_group_quantity"+counter_;
                document.getElementById("row_group_quantity").id = "row_group_quantity"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
		        newCell.innerHTML = '<select name="row_group_money" id="row_group_money" onchange="change_group_money('+counter_+')"><cfloop query="GET_OTHER_MONEY"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfloop></select>';
                document.getElementById("row_group_money").name = "row_group_money"+counter_;
                document.getElementById("row_group_money").id = "row_group_money"+counter_;
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<select name="is_alternative" id="is_alternative"><option value="0">Normal</option><option value="1">Yeni Ürün</option><option value="2">Opsiyon Ürün</option><option value="3">Bakım</option></select>';
                document.getElementById("is_alternative").name = "is_alternative"+counter_;
                document.getElementById("is_alternative").id = "is_alternative"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<select name="is_imported" id="is_imported"><option value="1"<cfif IS_IMPORTED eq 1>selected</cfif>>Evet</option><option value="0"<cfif IS_IMPORTED eq 0 or IS_IMPORTED eq ''>selected</cfif>>Hayır</option></select>';
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
                newCell.innerHTML = '<input type="hidden" name="product_unit_id" id="product_unit_id" value="#PRODUCT_UNIT_ID#"><select name="product_unit" id="product_unit"><option value="">Seçiniz</option><cfloop query="#GET_SETUP_UNIT#"><option value="#UNIT#"<cfif UNIT eq GET_PRODUCT.MAIN_UNIT>selected</cfif>>#UNIT#</option></cfloop></select>';
                document.getElementById("product_unit_id").name = "product_unit_id"+counter_;
                document.getElementById("product_unit_id").id = "product_unit_id"+counter_;
                document.getElementById("product_unit").name = "product_unit"+counter_;
                document.getElementById("product_unit").id = "product_unit"+counter_;
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" id="quantity" name="quantity" min="1" value="1" onchange="quantity_control('+counter_+')">';
                document.getElementById("quantity").name = "quantity"+counter_;
                document.getElementById("quantity").id = "quantity"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<select name="money" id="money"><option value="">Seçiniz</option><cfloop query="#GET_OTHER_MONEY#"><option value="#OTHER_MONEY#"<cfif OTHER_MONEY eq GET_PRODUCT.MONEY>selected</cfif>>#OTHER_MONEY#</option></cfloop></select>';
                document.getElementById("money").name = "money"+counter_;
                document.getElementById("money").id = "money"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="product_cost" id="product_cost" value="#PRICE#" onchange="discount_control('+counter_+')">';
                document.getElementById("product_cost").name = "product_cost"+counter_;
                document.getElementById("product_cost").id = "product_cost"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" id="discount" name="discount" value="0" onchange="discount_control('+counter_+')">';
                document.getElementById("discount").name = "discount"+counter_;
                document.getElementById("discount").id = "discount"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="number" id="nettotal_cost" name="nettotal_cost" value="#PRICE#" readonly>';
                document.getElementById("nettotal_cost").name = "nettotal_cost"+counter_;
                document.getElementById("nettotal_cost").id = "nettotal_cost"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="export_factor" id="export_factor" value="1" onchange="discount_control('+counter_+')">';
                document.getElementById("export_factor").name = "export_factor"+counter_;
                document.getElementById("export_factor").id = "export_factor"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="unit_cost" id="unit_cost" value="#PRICE#" readonly>';
                document.getElementById("unit_cost").name = "unit_cost"+counter_;
                document.getElementById("unit_cost").id = "unit_cost"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="total_cost" id="total_cost" value="#PRICE#" readonly>';
                document.getElementById("total_cost").name = "total_cost"+counter_;
                document.getElementById("total_cost").id = "total_cost"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="offer_factor" id="offer_factor" value="1" onchange="discount_control('+counter_+')">';
                document.getElementById("offer_factor").name = "offer_factor"+counter_;
                document.getElementById("offer_factor").id = "offer_factor"+counter_;
                
                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="unit_offer" id="unit_offer" value="#PRICE#" readonly>';
                document.getElementById("unit_offer").name = "unit_offer"+counter_;
                document.getElementById("unit_offer").id = "unit_offer"+counter_;

                newCell = newRow.insertCell(newRow.cells.length);
                newCell.innerHTML = '<input type="text" name="total_offer" id="total_offer" value="#PRICE#" readonly>';
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
                //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_+'&field_name=form_offer_cost.product_name'+counter_+'&field_total_price=form_offer_cost.product_cost'+counter_+'&field_unit=form_offer_cost.product_unit'+counter_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_+'&field_amount=form_offer_cost.quantity'+counter_+'&field_money=form_offer_cost.money'+counter_+'');
        </script>
    </cfoutput>

<script>
    function show_service_product() {
    var x = document.getElementById("service_product");
    var y = document.getElementById("product");
    if (x.style.display === "none") {
        x.style.display = "block";
    } else {
        x.style.display = "none";
    }
    }
</script>

<script type="text/javascript">
    var counter_ = document.getElementById("row_count").value;
	function add_row(barcode,amount,name)
	{
        counter_ = ((counter_*1)+1);
        document.getElementById("row_count").value = counter_;
        //console.log(counter_);
		var newRow;
		var newCell;
		
		newRow = document.getElementById("table_2").insertRow(document.getElementById("table_2").rows.length);
		newRow.setAttribute("name","frm_row"+counter_);
		newRow.setAttribute("NAME","frm_row"+counter_);

        //console.log('frm_row'+counter_);
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="table_2.deleteRow(this.parentNode.parentNode.rowIndex-1)"><i class="fa fa-minus"></i></a>';
		
        //newCell.innerHTML = '<select name="money" id="money"><option value="">Seçiniz</option><cfoutput query="GET_OTHER_MONEY"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfoutput></select>';
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<select name="row_group_name" id="row_group_name"><option value="">Seçiniz</option><cfoutput query="GET_OFFER_COST_GROUP"><option value="#OFFER_COST_GROUP_NAME#">#OFFER_COST_GROUP_NAME#</option></cfoutput></select>';
        document.getElementById("row_group_name").name = "row_group_name"+counter_;
        document.getElementById("row_group_name").id = "row_group_name"+counter_;
        
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="number" name="row_group_quantity" id="row_group_quantity" value="1" onchange="change_group_quantity('+counter_+')">';
        document.getElementById("row_group_quantity").name = "row_group_quantity"+counter_;
        document.getElementById("row_group_quantity").id = "row_group_quantity"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<select name="row_group_money" id="row_group_money" onchange="change_group_money('+counter_+')"><cfoutput query="GET_OTHER_MONEY"><option value="#OTHER_MONEY#">#OTHER_MONEY#</option></cfoutput></select>';
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
		newCell.innerHTML = '<input type="text" id="discount" name="discount" value="0" onchange="discount_control('+counter_+')">';
        document.getElementById("discount").name = "discount"+counter_;
        document.getElementById("discount").id = "discount"+counter_;

        newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="nettotal_cost" name="nettotal_cost" readonly>';
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
        //openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_standart_unit</cfoutput>&field_id=form_offer_cost.product_id'+counter_+'&field_stock_id=form_offer_cost.stock_id'+counter_+'&field_name=form_offer_cost.product_name'+counter_+'&field_total_price=form_offer_cost.product_cost'+counter_+'&field_unit=form_offer_cost.product_unit'+counter_+'&field_unit_id=form_offer_cost.product_unit_id'+counter_+'&field_amount=form_offer_cost.quantity'+counter_+'&field_money=form_offer_cost.money'+counter_+'&field_manufact_code=form_offer.manufact_code2'+counter_+'');
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