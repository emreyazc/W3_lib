<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/devextreme/21.1.4/css/dx.common.css" />
<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/devextreme/21.1.4/css/dx.light.css" />
<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"/>
			
<script src="https://cdn3.devexpress.com/jslib/20.2.6/js/dx.all.js"></script>
<script src="https://cdn3.devexpress.com/jslib/21.1.4/js/localization/dx.messages.tr.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/exceljs/3.3.1/exceljs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.8/FileSaver.min.js"></script>

<cfset Randomize(round(rand()*1000000))/>
<cfparam name="attributes.col" default="gridContainer_#round(rand()*10000000)#">
<cfset attributes.id = "#attributes.col#_grid">
<cfparam name="attributes.height" default="">
<cfparam name="attributes.width" default="">
<cfparam name="attributes.title" default="">
<cfparam name="attributes.sub_title" default="">
<cfparam name="attributes.add_link" default="">
<cfparam name="attributes.header_filter" default="1">
<cfparam name="attributes.header_export" default="1">
<cfparam name="attributes.table_manage" default="0">
<cfparam name="attributes.grid_page_size" default="15">
<cfparam name="attributes.selection" default="1">
<cfparam name="attributes.filter_panel" default="1">
<cfparam name="attributes.searchPanel" default="0">
<cfparam name="attributes.toolbar" default="1">
<cfparam name="attributes.dragging" default="0">
<cfparam name="attributes.table_code" default="XX">
<cfparam name="attributes.table_u_id" default="XX">
<cfparam name="attributes.group_cols" default="">
<cfparam name="attributes.save_layout" default="1">
<cfparam name="attributes.is_tree" default="0">
<cfparam name="attributes.selectedRowKeys" default="">
<cfparam name="attributes.expandedRowKeys" default="">

<cfparam name="attributes.col_summary" default="">
<cfparam name="attributes.col_summary_type" default="">

<cfif isdefined("attributes.query_name")>
	<cfset get_query = evaluate("caller.#attributes.query_name#")>
	<cfset get_query_result = evaluate("caller.#attributes.query_name#_result")>

	<cfif isdefined("attributes.col_list")>
		<cfset col_list = attributes.col_list>
	<cfelse>
		<cfset col_list = get_query_result.COLUMNLIST>
	</cfif>
<cfelseif isdefined("attributes.yoi_json")>
	<script src="/json/<cfoutput>#attributes.yoi_json#</cfoutput>.js"></script>
	<cfset col_list = attributes.col_list>
</cfif>

<cfset CRLF = Chr(13) & Chr(10)>
<cfset cift_t = '"'>
<cfset tek_t = "'">

<!--begin: Datatable-->
<script>
DevExpress.localization.locale("tr");

<cfif isdefined("attributes.query_name")>
var grid_data_<cfoutput>#attributes.col#</cfoutput> = [
	<cfoutput query="get_query">
		{    
			<cfloop from="1" to="#listlen(col_list)#" index="sira">
				<cfset data_name_ = listgetat(col_list,sira)>
				
				<cfset data_ = evaluate("#data_name_#")>
				<cfset data_ = replace(data_,CRLF,'<br/>','all')>
				<cfset data_ = replace(data_,cift_t,tek_t,'all')>
				"#data_name_#":"#data_#"<cfif sira neq listlen(col_list)>,</cfif>
			</cfloop>
		}
		<cfif currentrow neq get_query.recordcount>,</cfif>
	</cfoutput>
	];
<cfelseif isdefined("attributes.yoi_json")>
	<cfoutput>var grid_data_#attributes.col# = #attributes.yoi_json#;</cfoutput>
</cfif>
</script>

<cfif isdefined("attributes.query_name")>
	<cfset col_list = "YOIORDER,#col_list#">
	<cfif isdefined("attributes.col_name_list")>
		<cfset col_name_list = "SIRA,#attributes.col_name_list#">
	</cfif>
	<cfif isdefined("attributes.col_type_list")>
		<cfset col_type_list = "number,#attributes.col_type_list#">
	</cfif>
</cfif>
<!---
<cfquery name="get_layouts" datasource="#caller.dsn#">
	SELECT 
		* 
	FROM 
		LIST_LAYOUTS 
	WHERE 
		PAGE_ID_COL = '#attributes.id#' AND 
		(
			IS_GLOBAL = 1
			OR
			(PERSON_ID = #session.ep.userid# AND USE_LAYOUT_ID IS NULL)
		)
</cfquery>


<cfquery name="get_view" dataSource="#caller.dsn#">
	SELECT
		VLR.*,
		VL.PAGE_SIZE
	FROM
		LIST_LAYOUTS_ROWS VLR,
		LIST_LAYOUTS VL
	WHERE
		VL.LAYOUT_ID = VLR.LAYOUT_ID AND
		VL.PERSON_ID = #session.ep.userid# AND
		VL.PAGE_ID_COL = '#attributes.id#' AND
		VL.USE_LAYOUT_ID IS NULL AND
		VL.IS_SELECTED = 1
</cfquery>
<cfif not get_view.recordcount>
	<cfquery name="get_view" dataSource="#caller.dsn#">
		SELECT
			VLR.*,
			VL.PAGE_SIZE
		FROM
			LIST_LAYOUTS_ROWS VLR,
			LIST_LAYOUTS VL_OTHER,
			LIST_LAYOUTS VL
		WHERE
			VL_OTHER.LAYOUT_ID = VLR.LAYOUT_ID AND
			VL.PERSON_ID = #session.ep.userid# AND
			VL.PAGE_ID_COL = '#attributes.id#' AND
			VL.USE_LAYOUT_ID IS NOT NULL AND
			VL.USE_LAYOUT_ID = VL_OTHER.LAYOUT_ID AND
			VL.IS_SELECTED = 1
	</cfquery>
</cfif>
--->
<!---
<cfoutput query="get_view">
	<cfscript>
		'col_width_#col_name#' = COL_WIDTH;
		'col_visible_#col_name#' = COL_VISIBLE;
		'col_number_#col_name#' = COL_NUMBER;
		'col_pinned_#col_name#' = COL_PINNED;
		'col_pinned_position_#col_name#' = COL_PINNED_POSITION;
		'col_sort_order_#col_name#' = COL_SORT_ORDER;
	</cfscript>
	<cfset attributes.grid_page_size = PAGE_SIZE>
</cfoutput>
--->

<cfoutput>
	<style>
	<cfif len(attributes.height)>
	###attributes.id#
	{
		height:#attributes.height#px;
	}
	</cfif>
	
	.dx-datagrid .dx-header-filter 
	{  
		display: none!important;  
	}  
	.dx-datagrid .dx-header-filter {  
		display: inline-block!important;  
	}  
	</style>
	<div id="#attributes.id#"></div>
	<script>
	
	<cfif attributes.table_manage eq 1>
	view_temp_select = '<select name="list_layout_id" id="list_layout_id" onchange="set_layout_id();"><option value="">Seçiniz</option><option value="0">Sıfırla</option><cfloop query="get_layouts"><option value="<cfif IS_GLOBAL eq 1>#LAYOUT_ID#<cfelse>#-1*LAYOUT_ID#</cfif>">#LAYOUT_NAME#</option></cfloop></select>';
	<cfelse>
	view_temp_select = '';
	</cfif>
	first_load = 1;
	
	<cfif attributes.dragging eq 1>
		<cfif len(attributes.table_code)>
			table_code = '#Encrypt(attributes.table_code,"#ct_key#","CFMX_COMPAT","Hex")#';
		</cfif>
		<cfif len(attributes.table_u_id)>
			table_u_id = '#Encrypt(attributes.table_u_id,"#ct_key#","CFMX_COMPAT","Hex")#';
		</cfif>
		<cfif len(attributes.table_priority_col)>
			table_priority_col = '#Encrypt(attributes.table_priority_col,"#ct_key#","CFMX_COMPAT","Hex")#';
		</cfif>
	</cfif>
	
	function documentHeight()
	{
    return Math.max(
        document.documentElement.clientHeight,
        document.body.scrollHeight,
        document.documentElement.scrollHeight,
        document.body.offsetHeight,
        document.documentElement.offsetHeight
    );
	}
	
	function documentWidth()
	{
    return Math.max(
        document.documentElement.clientWidth,
        document.body.scrollWidth,
        document.documentElement.scrollWidth,
        document.body.offsetWidth,
        document.documentElement.offsetWidth
    );
	}
	
	<cfif not len(attributes.height)>
		height_ = documentHeight() - 130;
		document.getElementById('#attributes.id#').style.height = height_ + 'px';
	<cfelse>
		document.getElementById('#attributes.id#').style.height = '#attributes.height#px';
	</cfif>
	document.getElementById('#attributes.id#').style.height = '100%';
	
	<cfif not len(attributes.width)>
		width_ = documentWidth() - 100;
		document.getElementById('#attributes.id#').style.width = width_ + 'px';
	<cfelse>
		document.getElementById('#attributes.id#').style.width = '#attributes.width#px';
	</cfif>
	document.getElementById('#attributes.id#').style.width = '100%';
	$(function(){
		grid_#attributes.id# = $("###attributes.id#").<cfif attributes.is_tree eq 0>dxDataGrid<cfelse>dxTreeList</cfif>({
			dataSource: grid_data_#attributes.col#,
			allowColumnReordering:<cfif attributes.table_manage eq 1>true<cfelse>false</cfif>,
			allowColumnResizing:<cfif attributes.table_manage eq 1>true<cfelse>false</cfif>,
			columnAutoWidth:true,
			showBorders:true,
			showColumnLines: true,
			showRowLines: true,
			sorting:{mode:"multiple"},
			<cfif attributes.is_tree eq 1>
			keyExpr: "#attributes.keyExpr#",
			parentIdExpr:"#attributes.parentIdExpr#",
			selection: 
			{
				mode: "multiple",
				recursive: false
			},
			</cfif>
			<cfif attributes.filter_panel eq 1>
			filterRow: 
			{
            visible: true,
            applyFilter: "auto"
			},
			</cfif>
			<cfif attributes.header_filter eq 1>
			headerFilter: 
			{
				visible:true
			},
			</cfif>
			
			<cfif attributes.header_export eq 1>
			export: 
			{
			  enabled:<cfif attributes.header_export eq 1>true<cfelse>false</cfif>,
			  allowExportSelectedData: false
			},
			</cfif>
			<cfif attributes.dragging eq 1>
			rowDragging:
			{
				allowReordering: true,
				onReorder: function(e) 
				{
					var visibleRows = e.component.getVisibleRows(),
						toIndex = grid_data_#attributes.col#.indexOf(visibleRows[e.toIndex].data),
						fromIndex = grid_data_#attributes.col#.indexOf(e.itemData);

					grid_data_#attributes.col#.splice(fromIndex,1);
					grid_data_#attributes.col#.splice(toIndex,0,e.itemData);

					e.component.refresh();
					
					visibleRows = grid_data_#attributes.col#;
					rows_ = grid_data_#attributes.col#.length;
										
					for (i = 0; i < rows_; i++) 
					{
						id_deger_ = visibleRows[i].YOIUPDATE;
						sira_deger_ = i + 1;

						address_ = 'index.cfm?page=set_page_row_defines';
						address_ += '&type=order';
						address_ += '&row=' + sira_deger_;
						address_ += '&id_value=' + id_deger_;
						address_ += '&table=' + table_code;
						address_ += '&table_u_id=' + table_u_id;
						address_ += '&table_priority_col=' + table_priority_col;
						APL(address_,'action_div_#attributes.id#');
					}
				}
			},
			</cfif>
			onExporting: function(e) 
			{
			  var workbook = new ExcelJS.Workbook();
			  var worksheet = workbook.addWorksheet('#attributes.id#');
			  
			  DevExpress.excelExporter.exportDataGrid({
				component: e.component,
				worksheet: worksheet,
				autoFilterEnabled: true
			  }).then(function() {
				workbook.xlsx.writeBuffer().then(function(buffer) {
				  saveAs(new Blob([buffer], { type: 'application/octet-stream' }), '#attributes.id#.xlsx');
				});
			  });
			  e.cancel = true;
			},
			<cfif attributes.searchPanel eq 1>
			searchPanel: 
			{
            visible:true,
            width: 240,
            placeholder: "Search..."
			},
			</cfif>
			paging:
			{
            pageSize:#attributes.grid_page_size#
			},
			pager: 
			{
            showPageSizeSelector: true,
            allowedPageSizes: [<cfif attributes.grid_page_size lt 20>#attributes.grid_page_size#,#attributes.grid_page_size*2#,#attributes.grid_page_size*4#,#attributes.grid_page_size*8#,#attributes.grid_page_size*16#<cfelse>20,50,100,200</cfif>],
            showInfo: true
			},
			columnChooser: {
				enabled:<cfif attributes.table_manage eq 1>true<cfelse>false</cfif>
			},
			columnFixing: { 
				enabled: true
			},
			columns:
			[
				<cfloop from="1" to="#listlen(col_list)#" index="sira">
					<cfset name_ = listgetat(col_list,sira)>
					{
						<cfif len(attributes.group_cols) and listfind(attributes.group_cols,name_)>
							<cfset g_order = listfind(attributes.group_cols,name_) - 1>
							groupIndex:#g_order#,
						</cfif>
						<cfif name_ is 'YOIUPDATE' or name_ is 'YOIDELETE'>
						visible:true,
						<cfelseif isdefined("col_visible_#name_#") and evaluate("col_visible_#name_#") eq 1>
						visible: true,
						<!---
						<cfelseif get_view.recordcount>
						visible: false,
						--->
						<cfelse>
						visible: true,
						</cfif>
						<cfif isdefined("col_width_#name_#") and evaluate("col_width_#name_#") gt 0>
						width:#evaluate("col_width_#name_#")#,
						</cfif>
						<cfif isdefined("col_number_#name_#")>
						visibleIndex:#evaluate("col_number_#name_#")#,
						<cfelse>
						visibleIndex:#listlen(col_list)+1#,
						</cfif>
						<cfif name_ is 'YOIUPDATE' or name_ is 'YOIDELETE'>
						fixed:1,
						fixedPosition:"right",
						<cfelseif isdefined("col_pinned_#name_#") and isdefined("col_pinned_position_#name_#") and evaluate("col_pinned_#name_#") eq 1>
						fixed:1,
						fixedPosition:"#evaluate("col_pinned_position_#name_#")#",
						</cfif>
						<cfif isdefined("col_sort_order_#name_#") and len(evaluate("col_sort_order_#name_#"))>
						sortOrder:"#evaluate("col_sort_order_#name_#")#",
						</cfif>					
						<cfif UCASE(attributes.col) is name_>
							cellTemplate: function(container,options)
							{
								deger_ = 'index.cfm?page=#caller.attributes.page#&action=detail&#attributes.col#=' + options.value;
								return $("<a>", {"href":deger_}).text(options.value);
							},
						</cfif>
						<cfif name_ is 'YOIORDER'>
							caption: 'Sıra No',  
							cellTemplate: function(cellElement,cellInfo)
							{  
								cellElement.text(cellInfo.row.rowIndex + 1)
							},
						</cfif>	
						<cfif name_ is 'YOIUPDATE'>
							caption: '',  
							cellTemplate: function(container,options)
							{  
								<cfif isdefined("attributes.update_popup_link")>
									id_ = options.data.YOIUPDATE;
									deger_ = '#attributes.update_popup_link#';
									deger_ = deger_.replace("YOIUPDATE",id_);
									
									$("<div>")  
									.append($("<img>", {"src":"/assets/media/svg/icons/Design/edit.svg","href":"##","onclick":deger_,"data-toggle":"modal","data-target":"##myModal"}))  
									.appendTo(container); 
								<cfelseif isdefined("attributes.update_link")>
									id_ = options.data.YOIUPDATE;
									deger_ = '#attributes.update_link#';
									deger_ = deger_.replace("YOIUPDATE",id_);
									$("<div>")
									.append($("<img>", {"src":"/assets/media/svg/icons/Design/edit.svg","href":"##","onclick":"window.location.href='" + deger_ + "'"}))  
									.appendTo(container);
								</cfif>
							},
						</cfif>
						<cfif name_ is 'YOIDELETE'>
							caption: '',  
							cellTemplate: function(container,options)
							{  
								<cfif isdefined("attributes.delete_popup_link")>
									id_ = options.data.YOIDELETE;
									deger_ = '#attributes.delete_popup_link#';
									deger_ = deger_.replace("YOIDELETE",id_);
									
									$("<div>")  
									.append($("<img>", {"src":"/assets/media/svg/icons/Home/trash.svg","href":"##","onclick":deger_,"data-toggle":"modal","data-target":"##myModal"}))  
									.appendTo(container);
								<cfelseif isdefined("attributes.delete_link")>
									id_ = options.data.YOIDELETE;
									deger_ = '#attributes.delete_link#';
									deger_ = deger_.replace("YOIDELETE",id_);
									.append($("<img>", {"src":"/assets/media/svg/icons/Home/trash.svg","href":deger_}))  
									.appendTo(container);
								</cfif>
							},
						</cfif>
						<cfif name_ is 'YOISELECT'>
							caption: '',  
							cellTemplate: function(container,options)
							{  
								<cfif isdefined("attributes.select_popup_link")>
									id_ = options.data.YOISELECT;
									deger_ = '#attributes.select_popup_link#';
									deger_ = deger_.replace("YOISELECT",id_);
									
									$("<div>")  
									.append($("<img>", {"src":"/assets/media/svg/icons/Navigation/Route.svg","href":"##","onclick":deger_,"data-toggle":"modal","data-target":"##myModal"}))  
									.appendTo(container);
								</cfif>
							},
						</cfif>
						<cfif isdefined("col_name_list") and len(col_name_list)>
							<cfset caption_ = listgetat(col_name_list,sira)>
							caption: "#caption_#",
						</cfif>
						<cfif isdefined("col_type_list") and len(col_type_list)>
							<cfset type_ = listgetat(col_type_list,sira)>
							dataType:"#type_#",
							<cfif type_ is 'number'>
							format:"##,####0.####",
							</cfif>
						<cfelse>
							<cfif name_ contains '_DATE'>
							dataType:"date",
							format:'dd/MM/yyyy',
							<cfelseif name_ contains '_ID'>
							dataType:"number",
							<cfelse>
							dataType:"string",
							</cfif>
						</cfif>
						dataField:"#name_#",
						encodeHtml:false,
						headerFilter: {
						allowSearch: true
										}						
					}
					<cfif sira neq listlen(col_list)>,</cfif>					
				</cfloop>
			],
			<cfif len(attributes.col_summary)>
				summary:
				{
					totalItems:[
					<cfloop from="1" to="#listlen(attributes.col_summary)#" index="s_sira">
					<cfset name_ = listgetat(attributes.col_summary,s_sira)>
					<cfset type_ = listgetat(attributes.col_summary_type,s_sira)>
						{
							column:"#name_#",
							<cfif type_ is 'sum_currency'>
							summaryType:"sum",
							valueFormat:{style:"currency",currency:"TRY"}
							<cfelse>
							summaryType:"#type_#",
							valueFormat:"##,######.####"
							</cfif>
						}
						<cfif s_sira neq listlen(attributes.col_summary)>,</cfif>
					</cfloop>
					]
				},
			</cfif>
			onContentReady:function(e) 
			{
				/*
				$("##grid_detailed_search").parent().parent().addClass("dx-toolbar-item-auto-hide");
				$("##grid_view_save").parent().parent().addClass("dx-toolbar-item-auto-hide");
				*/
				if(first_load != 1)
				{
					//save_view_layout();
					first_load = 0;
				}
				else
				{
					first_load = 0;
					$('.dx-toolbar-before').addClass("");
					$('.dx-toolbar-after').addClass("");
				}
			}
			<cfif attributes.toolbar eq 1>
			,onToolbarPreparing: function(e) 
			{
					var dataGrid = e.component;

					e.toolbarOptions.items.unshift(
					{
						location: "after",
						template: function()
						{
							/*
							return $("<div/>")
								.addClass("card-title")
								.append(
								   $(view_temp_select)
								);
							*/
						}
					}
					/*
					<cfif attributes.header_filter eq 1>
					,
					{
						location: "after",
						widget: "dxButton",
						options: {
							icon: "filter",
							hint:"Detaylı Arama",
							text:"Detaylı Arama",
							elementAttr: 
							{
								"id":"grid_detailed_search"
							},
							onClick: function() 
							{
								get_search_row();
							}
						}
					}
					</cfif>
					*/
					);
			}
			</cfif>
			<cfif len(attributes.selectedRowKeys)>
			,selectedRowKeys:[#attributes.selectedRowKeys#]
			</cfif>
			<cfif len(attributes.expandedRowKeys)>
			,expandedRowKeys:[#attributes.expandedRowKeys#]
			</cfif>
		}).<cfif attributes.is_tree eq 0>dxDataGrid<cfelse>dxTreeList</cfif>("instance");
	});
	
	function save_view_layout()
	{
		<cfif attributes.save_layout eq 1>
		col_info_list = '';
		<cfloop from="1" to="#listlen(col_list)#" index="sira">
		<cfset name_ = listgetat(col_list,sira)>
			aaa = grid_#attributes.id#.columnOption('#name_#');
			//console.log(aaa);
			if(aaa.visible == true)
				gor = 1;
			else
				gor = 0;
				
			if(aaa.width != undefined)
				width_ = aaa.width;
			else
				width_ = 0;
				
			if(aaa.fixed != undefined && aaa.fixed == true)
				pinned_ = 1;
			else
				pinned_ = 0;
				
			if(aaa.fixedPosition != undefined)
				pinned_position_ = aaa.fixedPosition;
			else
				pinned_position_ = "left";
				
			if(aaa.sortOrder != undefined)
				sort_order_ = aaa.sortOrder;
			else
				sort_order_ = "none";
			
			satir_data = aaa.name + '*' + gor + '*' + aaa.visibleIndex + '*' + width_ + '*' + pinned_ + '*' + pinned_position_ + '*' + sort_order_;
			
			if(col_info_list == '')
				col_info_list = satir_data;
			else
				col_info_list = col_info_list + ',' + satir_data;
		</cfloop>
		address_ = 'index.cfm?page=set_page_col_defines';
		address_ += '&id=#attributes.id#';
		address_ += '&page_size=' + grid_#attributes.id#.option().paging.pageSize;
		address_ += '&col_info=' + col_info_list;
		address_ += '&is_layout_change=0';
		APL(address_,'action_div_#attributes.id#');
		</cfif>
	};
	
	function set_layout_id()
	{
		deger_ = document.getElementById('list_layout_id').value;
		
		if(deger_ != '')
		{
			address_ = 'index.cfm?page=set_page_col_defines';
			address_ += '&list_layout_id=' + document.getElementById('list_layout_id').value;
			address_ += '&is_layout_change=1';
			address_ += '&id=#attributes.id#';
			APL(address_,'action_div_#attributes.id#');
		}
	}
	
	search_visible = 0;
	function get_search_row()
	{
		if(search_visible == 0)
		{
			search_visible = 1;
			grid_#attributes.id#.option("filterRow.visible",true);
		}
		else
		{
			search_visible = 0;
			grid_#attributes.id#.option("filterRow.visible",false);
		}
	}
	</script>
</cfoutput>
<div id="action_div_<cfoutput>#attributes.id#</cfoutput>"></div>