<cfsetting showdebugoutput="no">
<cfparam name="attributes.asset_id" default="">
<cfparam name="attributes.row_count" default="0">
<cfparam name="attributes.save_accessories" default="0">

<!--- AKSESUARLARI KAYDET --->
<cfif attributes.save_accessories EQ 1 AND len(attributes.asset_id) AND isNumeric(attributes.asset_id)>
    <cftransaction>
        <!--- Önce bu varlığın mevcut aksesuarlarını temizle --->
        <cfquery name="DELETE_ACCESSORIES" datasource="#DSN#">
            DELETE FROM ASSET_P_ACCESSORIES WHERE ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.asset_id#">
        </cfquery>

        <!--- Formda kalan satırları yeniden ekle --->
        <cfif isNumeric(attributes.row_count) AND attributes.row_count GT 0>
            <cfloop from="1" to="#attributes.row_count#" index="i">
                <cfif structKeyExists(attributes, "product_id#i#")
                    AND len(attributes["product_id#i#"])
                    AND isNumeric(attributes["product_id#i#"])
                    AND structKeyExists(attributes, "product_name#i#")
                    AND len(attributes["product_name#i#"])>

                    <cfquery name="ADD_ACCESSORY" datasource="#DSN#">
                        INSERT INTO ASSET_P_ACCESSORIES
                        (
                            ASSETP_ID,
                            PRODUCT_ID,
                            PRODUCT_NAME
                        )
                        VALUES
                        (
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.asset_id#">,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes["product_id#i#"]#">,
                            <cfqueryparam cfsqltype="cf_sql_nvarchar" value="#attributes["product_name#i#"]#">
                        )
                    </cfquery>
                </cfif>
            </cfloop>
        </cfif>
    </cftransaction>
</cfif>

<!--- Mevcut aksesuarlar --->
<cfquery name="GET_ACCESSORIES" datasource="#DSN#">
    SELECT
        APA.ASSETP_ID,
        APA.PRODUCT_ID,
        APA.PRODUCT_NAME
    FROM
        ASSET_P_ACCESSORIES APA
    WHERE
        APA.ASSETP_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.asset_id#">
    ORDER BY
        APA.ASSET_P_ACCESSORY_ID
</cfquery>

<div id="asset_accessories_content">
    <cfform name="form_assetp_accessories" id="form_assetp_accessories" method="post" action="#request.self#?fuseaction=assetcare.assetp_accessories">
        <cfoutput>
            <input type="hidden" name="asset_id" id="asset_id" value="#attributes.asset_id#">
            <input type="hidden" name="row_count" id="row_count" value="#GET_ACCESSORIES.recordcount#">
            <input type="hidden" name="save_accessories" id="save_accessories" value="1">
        </cfoutput>
        <div style="width:100%; display:block" id="accessories">
            <cf_grid_list id="products" sort="0" name="products" class="basket_list">
                <thead>
                    <tr>
                        <th width="15">
                            <a
                                title="Satır <cf_get_lang dictionary_id='57582.Ekle'>"
                                onclick="add_row_p();">
                                <i class="fa fa-plus"></i>
                            </a>
                        </th>
                        <th>Ürün Adı</th>
                    </tr>
                </thead>
                <tbody id="table_1" name="table_1">
                    <cfoutput query="GET_ACCESSORIES">
                        <tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                            <td>
                                <a title="<cf_get_lang dictionary_id='57463.Sil'>" style="cursor:pointer" class="eklebutton" onclick="delete_row(this);">
                                    <i class="fa fa-minus"></i>
                                </a>
                            </td>
                            <td>
                                <input type="hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#PRODUCT_ID#">
                                <input type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#PRODUCT_NAME#" readonly>
                            </td>
                        </tr>
                    </cfoutput>
                </tbody>
            </cf_grid_list>
        </div>
        <cf_box_footer>
            <input type="button" value="Güncelle" class="btn btn-success" onclick="saveAccessories();">
        </cf_box_footer>
    </cfform>
</div>

<style>
    #products input[type="text"] {
        width: 100%;
        box-sizing: border-box;
    }
</style>

<script type="text/javascript">
    var counter_ = <cfoutput>#GET_ACCESSORIES.recordcount#</cfoutput>;

    function delete_row(obj)
    {
        var row = obj.parentNode.parentNode;
        row.parentNode.removeChild(row);
    }

    function add_row_p()
    {
        counter_ = ((counter_ * 1) + 1);

        document.getElementById("row_count").value = counter_;

        var newRow;
        var newCell;

        newRow = document.getElementById("table_1").insertRow(document.getElementById("table_1").rows.length);

        newRow.setAttribute("name", "frm_row" + counter_);
        newRow.setAttribute("id", "frm_row" + counter_);
        // SİL
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML ='<a title="Sil" ' +'style="cursor:pointer" ' +'class="eklebutton" ' +'onclick="delete_row(this);">' +'<i class="fa fa-minus"></i>' +'</a>';

        // ÜRÜN
        newCell = newRow.insertCell(newRow.cells.length);
        newCell.innerHTML = '<input type="hidden" ' +'name="product_id' + counter_ + '" ' +'id="product_id' + counter_ + '" value="">' +'<input type="text" ' +'name="product_name' + counter_ + '" ' +'id="product_name' + counter_ + '" ' +'value="" readonly>';
        
        // ÜRÜN SEÇİM POPUP
        openBoxDraggable('<cfoutput>#request.self#?fuseaction=objects.popup_product_price_unit</cfoutput>' +'&field_id=form_assetp_accessories.product_id' + counter_ +'&field_name=form_assetp_accessories.product_name' + counter_);
    }

    function saveAccessories()
    {
        $.ajax({
            type: "POST",
            url: "<cfoutput>#request.self#?fuseaction=assetcare.assetp_accessories</cfoutput>",
            data: $("#form_assetp_accessories").serialize(),
            success: function()
            {
                refresh_box('asset_accessories','<cfoutput>#request.self#?fuseaction=assetcare.assetp_accessories&asset_id=#attributes.asset_id#</cfoutput>','0');
            },
            error: function()
            {
                alert("Aksesuarlar kaydedilirken bir hata oluştu.");
            }
        });
        return false;
    }
</script>
