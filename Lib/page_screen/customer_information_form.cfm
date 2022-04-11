<style>
	.form-group input[type=tel], .form-group input[type=mail]{
	width: 100%!important;
	min-height: 23px;
	font-family: 'Roboto';
	padding: 1px 25px 1px 5px;
	font-size: 12px;
	outline:none;
	-webkit-box-sizing:border-box;
	        box-sizing:border-box;
	line-height: 1.42857143;
	color: #555;
	background-color: #fff;
	background-image: none;
	-webkit-box-shadow:0;
	        box-shadow:0;
	border-radius: 0;
	border: 1px solid #ccc;
	-webkit-transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
	-o-transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
	transition: border-color ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
	transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s;
	transition: border-color ease-in-out .15s, box-shadow ease-in-out .15s, -webkit-box-shadow ease-in-out .15s;
}

</style>

<cfscript>
	//parametreler
	projectCatId = 6; //proje kategorisi
	company_id = 1; //basvuru firma Id
	partner_id = 540; //basvuru partner Id
	process_stage = 10; //Başvuru aşama Id
	appcat_id = 1; //Başvuru kategori Id
	priority_id = 1; 
	ComMethod_Id = 1;
	processStageAsset = 14; //Dijital varlık Aşama Id
	attributes.module = 'call';
	attributes.module_id = 27;
	attributes.action_section = 'G_SERVICE_ID';
	attributes.asset_cat_id = -5;
	attributes.action_type = 0;
	attributes.property_id = 11; //belge tipi
</cfscript>

<cfquery name="getProject" datasource="#dsn#">
	SELECT
    	PROJECT_ID,
        PROJECT_HEAD
    FROM
    	PRO_PROJECTS
    WHERE
    	PROCESS_CAT = #projectCatId# AND 
		#CreateODBCDate(now())# BETWEEN TARGET_START AND TARGET_FINISH	
</cfquery>
<cfif getProject.recordcount gt 1>
	<cfquery name="getProject" datasource="#dsn#">
    	SELECT 
        	TOP 1
            PP.PROJECT_ID,
       		PP.PROJECT_HEAD
        FROM 
            WORKGROUP_EMP_PAR WEP
            RIGHT JOIN PRO_PROJECTS PP ON PP.PROJECT_ID = WEP.PROJECT_ID
        WHERE 
            WEP.PROJECT_ID IN (#valuelist(getProject.project_id)#) 
            AND WEP.EMPLOYEE_ID = #session.ep.userid#
            AND PP.PROJECT_STATUS = 1
    </cfquery>
</cfif>

<cfif isdefined('attributes.event') and attributes.event is 'list'>
	<cfquery name="getService" datasource="#dsn#">
        SELECT
            G.SERVICE_ID,
            G.SERVICE_NO,
            G.RECORD_DATE,
            E.EMPLOYEE_NAME +' '+ E.EMPLOYEE_SURNAME AS RECORD_MEMBER
        FROM 
            G_SERVICE G
            LEFT JOIN EMPLOYEES AS E ON G.RECORD_MEMBER = E.EMPLOYEE_ID
        WHERE 
            G.RECORD_MEMBER = #session.ep.userid#
            <cfif getProject.recordcount>
	            AND G.PROJECT_ID = #getProject.PROJECT_ID#
            </cfif>
        ORDER BY
        	G.SERVICE_ID DESC
    </cfquery>	
    
    <div id="pageHeader" class="col col-12 text-left pageHeader font-green-haze" style="padding: 10px 6px 0px 11px !important;">
        <span class="pageCaption font-green-sharp bold">Müşteri Bilgi Formu : Son Kaydedilenler</span>
        <div id="pageTab" class="pull-right text-right">
            <nav class="detailHeadButton" id="tabMenu">
                <ul>
                    <li class="dropdown"><a href="index.cfm?fuseaction=call.customer_information&event=add" title="Ekle"><i class="icon-add"></i></a></li>
                </ul>
           </nav>
        </div>
    </div>
    
    <cf_wrk_html_table width="100%" class="basket_list" cellpadding="2" cellspacing="1" border="0">
        <cf_wrk_html_thead>	
            <cf_wrk_html_tr>
                <cf_wrk_html_th>ID</cf_wrk_html_th>
                <cf_wrk_html_th nowrap>No</cf_wrk_html_th>
                <cf_wrk_html_th nowrap>Kayıt Tarihi</cf_wrk_html_th>
                <cf_wrk_html_th nowrap>Kaydeden</cf_wrk_html_th>
           </cf_wrk_html_tr>
        </cf_wrk_html_thead>
    
        <cf_wrk_html_tbody>
            <cfoutput query="getService">
                <cf_wrk_html_tr>
                    <cf_wrk_html_td><a href="#request.self#?fuseaction=call.customer_information&service_id=#service_id#" class="tableyazi">#service_id#</a></cf_wrk_html_td>
                    <cf_wrk_html_td><a href="#request.self#?fuseaction=call.customer_information&service_id=#service_id#" class="tableyazi">#service_no#</a></cf_wrk_html_td>
                    <cf_wrk_html_td>#dateformat(record_date,'dd/mm/yyyy')#</cf_wrk_html_td>
                    <cf_wrk_html_td>#record_member#</cf_wrk_html_td>
                </cf_wrk_html_tr>
            </cfoutput>
        </cf_wrk_html_tbody>
    </cf_wrk_html_table>
<cfelse>
	<cfif isDefined("attributes.is_form_submitted")>
        <cfif len(attributes.country_id)>
            <cfquery name="myCountry" datasource="#DSN#">
                SELECT COUNTRY_NAME FROM SETUP_COUNTRY WHERE COUNTRY_ID = #attributes.country_id#
            </cfquery>
        </cfif>
        <cfif len(attributes.city_id)>
            <cfquery name="myCity" datasource="#dsn#">
                SELECT CITY_NAME FROM SETUP_CITY WHERE CITY_ID = #attributes.city_id#
            </cfquery>
        </cfif>
        <cfif len(attributes.county_id)>
            <cfquery name="myCounty" datasource="#dsn#">
                SELECT COUNTY_NAME FROM SETUP_COUNTY WHERE COUNTY_ID = #attributes.county_id#
            </cfquery>
        </cfif>
        
        <cfsavecontent variable="my_service_detail">
			<cfoutput>
            MÜŞTERİ BİLGİ FORMU:
                <cfif isdefined('attributes.name_surname') and len(attributes.name_surname)><p><b>Ad Soyad : </b>#attributes.name_surname#</p></cfif>
                <cfif isdefined('attributes.company_name') and len(attributes.company_name)><p><b>Firma Adı : </b>#attributes.company_name#</p></cfif>
                <cfif len(attributes.country_id)><p><b>Ülke : </b>#myCountry.country_name#</p></cfif>
                <cfif len(attributes.city_id)><p><b>İl : </b>#myCity.city_name#</p></cfif>
                <cfif len(attributes.county_id)><p><b>İlçe : </b>#myCounty.COUNTY_NAME#</p></cfif>
                <cfif len(attributes.tel_no)><p><b>Telefon : </b>#attributes.tel_no#</p></cfif>
                <cfif len(attributes.email)><p><b>E-Posta : </b>#attributes.email#</p></cfif>
                <cfif len(attributes.sector)><p><b>Bulunduğu Sektör : </b>#attributes.sector#</p></cfif>
                <!---
                <cfif len(attributes.project_id) and len(attributes.project_head)><b>Proje :</b> #attributes.project_head#<br /></cfif>
                --->
                <p><b>İlgilendiği Kategoriler : </b><cfif isdefined('attributes.pil') and attributes.pil eq 1>Pil </cfif><cfif isdefined('attributes.aku') and attributes.aku eq 1>Akü </cfif><cfif isdefined('attributes.sarj') and attributes.sarj eq 1>Şarj </cfif>
                <cfif isdefined('attributes.fener') and attributes.fener eq 1>Fener Aydınlatma </cfif><cfif isdefined('attributes.pil_grup') and attributes.pil_grup eq 1>Pil Grup </cfif></p>
                <cfif len(attributes.fill_emp_id)>
                        <cfquery name="GET_FILL_EMP_UPD" datasource="#dsn#">
                            SELECT
                                EMPLOYEE_NAME,
                                EMPLOYEE_SURNAME
                            FROM
                                EMPLOYEES
                            WHERE
                                EMPLOYEE_ID = #attributes.fill_emp_id#
                        </cfquery>
                   <p><b>Kaydı Alan Temsilci : </b>#GET_FILL_EMP_UPD.EMPLOYEE_NAME# #GET_FILL_EMP_UPD.EMPLOYEE_SURNAME#</p>
                </cfif>
				<cfif len(attributes.service_detail)>
	                <p><b>Açıklama : </b>#attributes.service_detail#</p>
                </cfif>
            </cfoutput>
        </cfsavecontent>

		<cftransaction>
        	<cfif isdefined('attributes.service_id') and len(attributes.service_id)>
                <cfquery name="UPD_SERVICE" datasource="#DSN#">
                    UPDATE
                        G_SERVICE
                    SET
                        FIRMA = <cfif len(attributes.company_name)>'#attributes.company_name#'<cfelse>NULL</cfif>,
                        TEL_NO = <cfif len(attributes.tel_no)>'#attributes.tel_no#'<cfelse>NULL</cfif>,
                        SEKTOR = <cfif len(attributes.sector)>'#attributes.sector#'<cfelse>NULL</cfif>,
						REF_NO = <cfif len(attributes.sector)>'#left(attributes.sector,50)#'<cfelse>NULL</cfif>,
                        PIL = <cfif isdefined('attributes.pil')>1<cfelse>0</cfif>,
                        AKU = <cfif isdefined('attributes.aku')>1<cfelse>0</cfif>,
                        SARJ = <cfif isdefined('attributes.sarj')>1<cfelse>0</cfif>,
                        FENER = <cfif isdefined('attributes.fener')>1<cfelse>0</cfif>,
                        PIL_GRUP = <cfif isdefined('attributes.pil_grup')>1<cfelse>0</cfif>,
                        COUNTRY_ID = <cfif len(attributes.country_id)>#attributes.country_id#<cfelse>NULL</cfif>,
                        CITY_ID = <cfif len(attributes.city_id)>#attributes.city_id#<cfelse>NULL</cfif>,
                        COUNTY_ID = <cfif len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
                        SERVICE_DETAIL = '#my_service_detail#',
                        APPLICATOR_NAME = <cfif len(attributes.name_surname)>'#attributes.name_surname#'<cfelse>NULL</cfif>,
                        APPLICATOR_EMAIL = <cfif len(attributes.email)>'#attributes.email#'<cfelse>NULL</cfif>,
                        PROJECT_ID = <cfif isdefined("attributes.project_id") and len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
                        UPDATE_DATE = #now()#,
                        UPDATE_MEMBER = #session.ep.userid#,
                        FORM_FILL_EMPLOYEE = <cfif len(attributes.fill_emp_id) and len(attributes.fill_emp_name)>#attributes.fill_emp_id#<cfelse>NULL</cfif>
                    WHERE
                        SERVICE_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.service_id#">
                </cfquery>
            <cfelse>
                <cf_papers paper_type="g_service_app">
                <cfset system_paper_no=paper_code & '-' & paper_number>
                <cfset system_paper_no_add=paper_number>
                <cfset attributes.service_no = system_paper_no>
                <cfquery name="UPD_GEN_PAP" datasource="#DSN#">
                    UPDATE
                        GENERAL_PAPERS_MAIN
                    SET
                        G_SERVICE_APP_NUMBER = #system_paper_no_add#
                    WHERE
                        G_SERVICE_APP_NUMBER IS NOT NULL
                </cfquery>
            
                <cfquery name="ADD_SERVICE" datasource="#DSN#" result="my_result">
                    INSERT INTO
                        G_SERVICE
                        (
                            SERVICE_ACTIVE,
                            ISREAD,
                            SERVICECAT_ID,
                            SERVICE_STATUS_ID,
                            PRIORITY_ID,
                            COMMETHOD_ID,
                            SERVICE_HEAD,
                            SERVICE_DETAIL,
                            APPLY_DATE,
                            START_DATE,
                            SERVICE_COMPANY_ID,
                            SERVICE_PARTNER_ID,
                            NOTIFY_EMPLOYEE_ID,
                            APPLICATOR_NAME,
                            APPLICATOR_EMAIL,
                            SERVICE_NO,
                            PROJECT_ID,
                            RECORD_DATE,
                            RECORD_MEMBER,
                            OUR_COMPANY_ID,
							REF_NO,
                            FIRMA,
                            TEL_NO,
                            SEKTOR,
                            PIL,
                            AKU,
                            SARJ,
                            FENER,
                            PIL_GRUP,
                            COUNTRY_ID,
                            CITY_ID,
                            COUNTY_ID,
                            FORM_FILL_EMPLOYEE
                        )
                        VALUES
                        (
                            1,
                            0,
                            #appcat_id#,
                            #process_stage#,
                            #priority_id#,
                            #commethod_id#,
                            '#system_paper_no#',
                            '#my_service_detail#',
                            #now()#,
							#date_add("h",1,now())#,
                            #company_id#,
                            #partner_id#,
                            #session.ep.userid#,
                            <cfif len(attributes.name_surname)>'#attributes.name_surname#'<cfelse>NULL</cfif>,
                            <cfif len(attributes.email)>'#attributes.email#'<cfelse>NULL</cfif>,
                            '#system_paper_no#',
                            <cfif isdefined("attributes.project_id") and len(attributes.project_id) and len(attributes.project_head)>#attributes.project_id#<cfelse>NULL</cfif>,
                            #now()#,
                            #session.ep.userid#,
                            <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#">,
							<cfif len(attributes.sector)>'#left(attributes.sector,50)#'<cfelse>NULL</cfif>,
                            <cfif len(attributes.company_name)>'#attributes.company_name#'<cfelse>NULL</cfif>,
                            <cfif len(attributes.tel_no)>'#attributes.tel_no#'<cfelse>NULL</cfif>,
                            <cfif len(attributes.sector)>'#attributes.sector#'<cfelse>NULL</cfif>,
                            <cfif isdefined('attributes.pil')>1<cfelse>0</cfif>,
                            <cfif isdefined('attributes.aku')>1<cfelse>0</cfif>,
                            <cfif isdefined('attributes.sarj')>1<cfelse>0</cfif>,
                            <cfif isdefined('attributes.fener')>1<cfelse>0</cfif>,
                            <cfif isdefined('attributes.pil_grup')>1<cfelse>0</cfif>,
                            <cfif len(attributes.country_id)>#attributes.country_id#<cfelse>NULL</cfif>,
                            <cfif len(attributes.city_id)>#attributes.city_id#<cfelse>NULL</cfif>,
                            <cfif len(attributes.county_id)>#attributes.county_id#<cfelse>NULL</cfif>,
                            <cfif len(attributes.fill_emp_id) and len(attributes.fill_emp_name)>#attributes.fill_emp_id#<cfelse>NULL</cfif>
                        )
                </cfquery>
                <cfset attributes.service_id = my_result.identityCol>
                <cfquery name="ADD_SERVICE_STATUS_ROW" datasource="#DSN#">
                    INSERT INTO 
                        G_SERVICE_APP_ROWS
                        (
                            SERVICE_ID,
                            SERVICECAT_ID,
                            SERVICE_SUB_CAT_ID,
                            SERVICE_SUB_STATUS_ID
                        )
                    VALUES
                        (
                            #attributes.service_id#,
                            #appcat_id#,
                            NULL,
                            NULL
                        )
                </cfquery>
        	</cfif>
			<!--- asset ekleniyor --->
            <cf_papers paper_type="ASSET">
            <cfset system_paper_no_asset=paper_code & '-' & paper_number>
			<cfset system_paper_no_add_asset=paper_number>
            <cfif len(system_paper_no_add_asset)>
                <cfquery name="UPD_GEN_PAP" datasource="#DSN#">
                    UPDATE 
                        GENERAL_PAPERS_MAIN
                    SET
                        ASSET_NUMBER = #system_paper_no_add_asset#
                    WHERE
                        ASSET_NUMBER IS NOT NULL
                </cfquery>
            </cfif>
            <cfscript>
                attributes.action_id = attributes.service_id;
                
                form.asset_name = attributes.service_no;
                form.ASSET_DESCRIPTION = '';
                form.ASSET_DETAIL = '';
    			attributes.asset_no = system_paper_no_asset;
	
                uploadFolder = application.systemParam.systemParam().upload_folder;
                fileSystem = CreateObject("component","V16.asset.cfc.file_system");
                asset_component = CreateObject("component","V16.asset.cfc.asset");
                uploadStatus = false;
            </cfscript>
            
            <cfif isdefined("attributes.foldername") and len(attributes.foldername) and isdefined('attributes.asset') and len(attributes.asset)>
                <!--- Upload File --->
                <cffunction name="uploadFile">
                    <cfargument name="assetInfo" type="struct" />
                    <cfset fileSystem.rename(assetInfo.filePath,assetInfo.uploadFolder & assetInfo.fileFullName) />
                    <cfif fileSystem.fileType(assetInfo.fileExtension)["fileType"] eq "image">
                        <cfset asset_component.createThumbnailFromImage(assetInfo : assetInfo) /><!--- Fotoğraf thumbnail ---->
                    </cfif>
                    <!--- insert AssetInfo --->
                    <cfset saveAssetMetaData(assetInfo) />
                </cffunction>
            
                <cffunction name="getFileSize" returntype="numeric">
                    <cfargument name="fileName" type="string" required="yes" />
                    <cfset var fileInstance = createObject("java","java.io.File").init(toString(arguments.fileName)) />
                    <cfif fileInstance.isFile()>
                        <cfreturn fileInstance.length() />
                    <cfelse>
                        <cfreturn -1 />
                    </cfif>
                </cffunction>
                
                <cffunction name="AssetInfoNew" returntype="struct" description="Returns new AssetInfo object that contains default values">
                    <cfset assetInfo=structNew() />
                    <cfset assetInfo.assetId="" />
                    <cfset assetInfo.assetName=form.ASSET_NAME />
                    <cfset assetInfo.assetDescription=form.ASSET_DESCRIPTION />
                    <cfset assetInfo.assetKeywords=form.ASSET_DETAIL />
                    <cfset assetInfo.assetCategoryId=attributes.asset_cat_id />
                    <cfset assetInfo.companyId=SESSION.EP.COMPANY_ID />
                    <cfset assetInfo.fileName="" />
                    <cfset assetInfo.fileSize="" />
                    <cfset assetInfo.fileExtension="" />
                    <cfset assetInfo.fileFullName = "" />
                    <cfset assetInfo.filePath=""/>
                    <cfset assetInfo.fileServerId=fusebox.server_machine />
                    <cfset assetInfo.uploadFolder=getUploadFolder() />
                    <cfset assetInfo.moduleName=attributes.module />
                    <cfset assetInfo.moduleId=attributes.module_id />
                    <cfset assetInfo.actionSection=attributes.action_section />
                    <cfset assetInfo.actionId=attributes.action_id />
                    <cfset assetInfo.isInternet=false />
                    <cfset assetInfo.recordDate=NOW() />
                    <cfset assetInfo.recordEmployee=SESSION.EP.USERID />
                    <cfset assetInfo.recordIp=CGI.REMOTE_ADDR />
                    <cfset assetInfo.updateEmployee=SESSION.EP.USERID />
                    <cfset assetInfo.updateIp=CGI.REMOTE_ADDR />
                    <cfset assetInfo.propertyId=attributes.property_id />
                    <cfset assetInfo.isLive=false />
                    <cfset assetInfo.featured=false />
                    <cfset assetInfo.is_special=false />
                    <cfreturn assetInfo />
                </cffunction>
            
                <cffunction name="getUploadFolder" returntype="string" description="Upload folder is determined by selected category">
                    <cfquery name="GET_UPLOAD_FOLDER" datasource="#DSN#">
                        SELECT
                            ASSETCAT_ID,
                            ASSETCAT_PATH
                        FROM
                            ASSET_CAT
                        WHERE
                            ASSETCAT_ID = #assetInfo.assetCategoryId#
                    </cfquery>
                    
                    <cfif assetInfo.assetCategoryId lt 0>
                        <cfif not DirectoryExists("#uploadFolder##get_upload_folder.assetcat_path##dir_seperator#")>
                            <cfdirectory action="create" directory="#uploadFolder##get_upload_folder.assetcat_path##dir_seperator#">
                        </cfif>
                        <cfset upload_folder = "#uploadFolder##get_upload_folder.assetcat_path##dir_seperator#">
                    <cfelse>
                        <cfset upload_folder = "#uploadFolder#asset#dir_seperator##get_upload_folder.assetcat_path##dir_seperator#">
                    </cfif>
            
                    <cfreturn upload_folder />
                </cffunction>
            
                <cffunction name="saveAssetMetaData" description="All database operations to save AssetInfo object">
                    <cfargument name="assetInfo" type="struct">
                    <cfquery name="ADD_ASSET" datasource="#DSN#" result="insertAsset">
                        INSERT INTO 
                            ASSET
                        (
                            PERIOD_ID,
                            ASSET_NO,
                            MODULE_NAME,
                            MODULE_ID,
                            ACTION_SECTION,
                            PROJECT_ID,
                            ACTION_ID,
                            COMPANY_ID,
                            ASSETCAT_ID,
                            ASSET_FILE_NAME,
                            ASSET_FILE_REAL_NAME,
                            ASSET_FILE_SIZE,
                            ASSET_FILE_SERVER_ID,
                            ASSET_NAME,
                            ASSET_DETAIL,
                            IS_INTERNET,
                            RECORD_DATE,
                            RECORD_EMP,
                            RECORD_IP,
                            PROPERTY_ID,
                            ASSET_DESCRIPTION,
                            IS_LIVE,
                            FEATURED,
                            IS_SPECIAL,
                            SERVER_NAME,
                            IS_IMAGE
                            ,ASSET_STAGE
                            ,IS_ACTIVE
                        )
                        VALUES
                        (
                            #session.ep.period_id#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.asset_no#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.moduleName#">,
                            #assetInfo.moduleId#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.actionSection#">,
                            <cfif isdefined("attributes.project_id") and len(attributes.project_id)>#attributes.project_id#<cfelse>NULL</cfif>,
                            #attributes.action_id#,
                            #assetInfo.companyId#,
                            #assetInfo.assetCategoryId#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.fileFullName#">,
                            <cfif isdefined("assetInfo.asset_file_real_name")><cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.asset_file_real_name#"><cfelse><cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.fileFullName#"></cfif>,
                            <cfif isdefined("assetInfo.fileSize") and len(assetInfo.fileSize)>#ROUND(assetInfo.fileSize/1024)#<cfelse>0</cfif>,
                            #assetInfo.fileServerId#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.assetName#">,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.assetKeywords#">,
                            <cfif assetInfo.isInternet>1<cfelse>0</cfif>,
                            #assetInfo.recordDate#,
                            #assetInfo.recordEmployee#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.recordIp#">,
                            #assetInfo.propertyId#,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#assetInfo.assetDescription#">,
                            <cfif assetInfo.isLive>1<cfelse>0</cfif>,
                            <cfif assetInfo.featured>1<cfelse>0</cfif>,
                            <cfif assetInfo.is_special>1<cfelse>0</cfif>,
                            <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(server_name)#">,
                            <cfif isdefined("attributes.is_image") and attributes.is_image eq 1>1<cfelse>0</cfif>
                            ,#processStageAsset#
                            ,1
                        )
                    </cfquery>
                    <cfset assetInfo.assetid = insertAsset.IDENTITYCOL>
                </cffunction>
            
                <cfscript>
                    fileRealName = "";
                   
                    session.imTempPath = "#upload_folder##createuuid()##dir_seperator#";
                    folder = "asset_preview/" & attributes.foldername;//dosyaların bulunduğu klasör
                    				
                    if(directoryexists(uploadFolder & folder)){
                        fileList = fileSystem.fileListinFolder(folderPath:folder);	
					     
                        function addAssetInfo(file) {
                            assetInfo = AssetInfoNew();
                            createId = createUUID();
                            assetInfo.fileSize = file.Size;
                            assetInfo.fileExtension = ucase(ListLast(file.name,"."));
                            assetInfo.fileName = createId;
                            assetInfo.fileFullName = assetInfo.fileName & "." & assetInfo.fileExtension;
                            if(uploadStatus) assetInfo.uploadFolder	= session.imPath;
                            if(len(fileRealName)) assetInfo.asset_file_real_name = fileRealName;
                            else assetInfo.asset_file_real_name = file.name;
                            assetInfo.filePath = Replace(file.Directory,uploadFolder,"") & "/" & file.name;
                        }
            
                        if(fileList.recordCount gt 0){
                            counter = 0;
                            for (row in fileList) {
								
                                addAssetInfo(row);
                                uploadFile(assetInfo);
                                
                                session.imPath = assetInfo.uploadFolder;
            
                                counter++;
                                
                                try{
                                    if(fileList.recordCount eq counter) fileSystem.deleteFolder(folder);//dosyaların bulunduğu klasörü siler.
                                }catch (any cfcatch) {
                                }
                                
                            }
            
                        }else{
                            WriteOutput('<script>alert("#getLang('assetcare',473)#!");</script>');
                        }
                    }else{
                        if(uploadStatus  == false)
                        {
                            WriteOutput('<script>alert("#getLang('assetcare',473)#! CODE:NOFOLDER");</script>');
                        }
                    }
                </cfscript>
            </cfif>


			<!--- mail gonderiliyor --->
			<cfif attributes.country_id eq 1> 
            <cfif len(attributes.email) and len(attributes.name_surname)>
				<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
                <cfif attributes.country_id eq 1> 
                <cfset message_head = "Ziyaretiniz için teşekkür ederiz. ID: #attributes.service_no#">
                </cfif>
                
                <cfmail from="#from_mail#" to="#attributes.email#" subject="#message_head#" type="html" charset="utf-8">
                    <html>
                        <head>
                        <title></title>
                        </head>
                        <body> 
                        <table border="0" style="width:800px;">                        
                            <tr style="height:60px;">
                                <td ><cfinclude template="/v16/objects/display/view_company_logo.cfm"></td>
                            </tr> 
                            <tr style="height:35px;">
                                <td style="vertical-align:top">
								<cfoutput>
                                    Sayın <b>#attributes.name_surname#</b>;<br/><br/>
                                    
                                    Birikim Pilleri olarak #attributes.project_head# standımıza göstermiş olduğunuz ilgiye teşekkür ederiz.<br />
                                    Sizleri standımızda ağırlamaktan kıvanç duyduk.<br /><br />

                                    <a href="https://bit.ly/3CUhs09">Yenilenen Kataloğumuzu İncelemek İçin Tıklayınız.</a><br><br>
                                    <a href="https://bit.ly/3CUhs09"><img src="https://erp.birikimpilleri.com:443/images/katalog.png" href="https://bit.ly/3CUhs09"></a><br><br>
                                    
                                    İş ortaklığımızın ilerlemesi için en kısa sürede müşteri temsilciniz telefon veya eposta yoluyla tarafınıza ulaşacaktır.<br /><nt>
                                    İletişim için bize iletmiş olduğunuz bilgileriniz aşağıdaki gibidir;<br /><br />
                                    
                                    
                                    <cfif len(attributes.tel_no)><b>Telefon numarası : #attributes.tel_no#</b><br /></cfif>
                                    
                                    <b>Eposta : #attributes.email#</b><br /><br />
                                    
                                    Eğer bilgilerinizde yanlışlık olduğunu düşünüyorsanız;<br />
                                    
                                    
                                    Bu maili yanıtlayarak veya "0216 629 90 60 (PBX)" numaralı telefondan bize ulaşabilirsiniz.<br /><br /><br />
                                    
                                    Saygılarımızla.
                                </cfoutput>
                                </td>	
                            </tr>
                            <tr>
                                <td>
                                    <cfinclude template="/v16/objects/display/view_company_info.cfm">
                                </td>
                            </tr> 
                    </table>
                    </body>
                    </html>
                </cfmail>
            </cfif>
			 <cfelse> 
            <cfif len(attributes.email) and len(attributes.name_surname)>
				<cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
                <cfset message_head = "Thank you for your visit. ID: #attributes.service_no#">
                
                <cfmail from="#from_mail#" to="#attributes.email#" subject="#message_head#" type="html" charset="utf-8">
                    <html>
                        <head>
                        <title></title>
                        </head>
                        <body> 
                        <table border="0" style="width:800px;">                        
                            <tr style="height:60px;">
                                <td ><cfinclude template="/v16/objects/display/view_company_logo.cfm"></td>
                            </tr> 
                            <tr style="height:35px;">
                                <td style="vertical-align:top">
                                    <cfoutput>
                                        Dear <b>#attributes.name_surname#</b>;<br/><br/>
										
										On behalf of Birikim Batteries Ltd., we would like to thank you for your interest in our company during the #attributes.project_head# exhibition.<br /><br />

                                        <a href="https://bit.ly/3CUhs09">Click to Review Our Renewed Catalogue.</a><br><br>
                                        <a href="https://bit.ly/3CUhs09"><img src="https://erp.birikimpilleri.com:443/images/katalog.png" href="https://bit.ly/3CUhs09"></a><br><br>

										For the purpose of improving our cooperation , we would like to inform you that our team will contact you as soon as possible via phone or email.<br /><br />

										Below are the contact details you kindly provided during the exhibition.<br />
                       
                                        <cfif len(attributes.tel_no)><b>Phone : #attributes.tel_no#</b><br /></cfif>
                                        
                                        <b>Email : #attributes.email#</b><br /><br />
                                        
                                        Please let us know if there are any mistakes in your contact details through replying to this email or feel free to reach us by phone,<br />
										"+90 216 629 90 60 PBX"<br /><br />
										
										Thank you for your visit again.<br />
										Best Regards,
                                    </cfoutput>
                                </td>	
                            </tr>
                            <tr>
                                <td>
                                    <cfinclude template="/v16/objects/display/view_company_info_eng.cfm">
                                </td>
                            </tr> 
                    </table>
                    </body>
                    </html>
                </cfmail>
            </cfif>
			
			 </cfif>
			 
			
        </cftransaction>
        <cfif attributes.is_form_submitted eq 1>
			<script type="text/javascript">
                window.location.href="<cfoutput>#request.self#?fuseaction=call.customer_information</cfoutput>";
            </script>
        <cfelse>
			<script type="text/javascript">
                window.location.href="<cfoutput>#request.self#?fuseaction=call.customer_information&service_id=#attributes.service_id#</cfoutput>";
            </script>        
        </cfif>
	<cfelse>
    	<cfquery name="getCountry" datasource="#DSN#">
            SELECT
                COUNTRY_ID,
                COUNTRY_NAME,
                IS_DEFAULT
            FROM
                SETUP_COUNTRY
            ORDER BY
                IS_DEFAULT DESC,
                COUNTRY_NAME
        </cfquery>
    
		<cfif isdefined('attributes.service_id') and len(attributes.service_id)>
        	<cfquery name="getService" datasource="#dsn#">
            	SELECT 
                	G.* ,
                    PP.PROJECT_HEAD
                FROM 
                	G_SERVICE G
                    LEFT JOIN PRO_PROJECTS AS PP ON G.PROJECT_ID = PP.PROJECT_ID
                WHERE 
                	G.SERVICE_ID = #attributes.service_id#
            </cfquery>
            <!---
            <cfif isDefined('#getService.FORM_FILL_EMP#') and len(getService.FORM_FILL_EMP)>
                
            </cfif>
            --->

        
            <cfscript>
				serviceId = attributes.service_id;
				service_no = getService.service_no;
                attributes.name_surname = getService.APPLICATOR_NAME;
                attributes.company_name = getService.FIRMA;
                attributes.tel_no = getService.TEL_NO;
                attributes.email = getService.APPLICATOR_EMAIL;
                attributes.sector = getService.SEKTOR;
				attributes.project_id = getService.PROJECT_ID;
				attributes.project_head = getService.PROJECT_HEAD;
				attributes.service_detail = getService.service_detail;
				attributes.pil = getService.PIL;
				attributes.aku = getService.AKU;
				attributes.sarj = getService.SARJ;
				attributes.fener = getService.FENER;
				attributes.pil_grup = getService.PIL_GRUP;
                attributes.country_id = getService.COUNTRY_ID;
                attributes.city_id = getService.CITY_ID;
                attributes.county_id = getService.COUNTY_ID;
                attributes.fill_emp_id = getService.FORM_FILL_EMPLOYEE;
            </cfscript>
        <cfelse>
            <cfscript>
				serviceId = '';
				service_no = '';
                attributes.name_surname = '';
                attributes.company_name = '';
				attributes.tel_no = '';
                attributes.email = '';
                attributes.sector = '';
				if(getProject.recordcount){
					attributes.project_id = getProject.PROJECT_ID;
					attributes.project_head = getProject.PROJECT_HEAD;
				} else
				{
					attributes.project_id = '';
					attributes.project_head = '';
				}
				attributes.service_detail = '';
				attributes.pil = 0;
				attributes.aku = 0;
				attributes.sarj = 0;
				attributes.fener = 0;
				attributes.pil_grup = 0;
                attributes.country_id = getCountry.COUNTRY_ID;
                attributes.city_id = '';
                attributes.county_id = '';
                attributes.fill_emp_id = '';
            </cfscript>
        </cfif>
        
        <cfif len(attributes.country_id)>
            <cfquery name="Get_City" datasource="#dsn#">
                SELECT CITY_ID,CITY_NAME FROM SETUP_CITY WHERE COUNTRY_ID = #attributes.country_id#
            </cfquery>
        </cfif>
        <cfif len(attributes.city_id)>
            <cfquery name="GetCounty" datasource="#dsn#">
                SELECT COUNTY_ID,COUNTY_NAME FROM SETUP_COUNTY WHERE CITY = #attributes.city_id#
            </cfquery>
        </cfif>
        
        <link rel="stylesheet" href="/css/assets/template/fileupload/dropzone.css" type="text/css">
        <link rel="stylesheet" href="/css/assets/template/fileupload/fileupload-min.css" type="text/css">
        
        <div id="pageHeader" class="col col-12 text-left pageHeader font-green-haze" style="padding: 10px 6px 0px 11px !important;">
            <span class="pageCaption font-green-sharp bold">Müşteri Bilgi Formu</span>
            <div id="pageTab" class="pull-right text-right">
                <nav class="detailHeadButton" id="tabMenu">
                    <ul>
                        <li class="dropdown"><a href="index.cfm?fuseaction=call.customer_information&event=list" title="Liste"><i class="icon-list-ul"></i></a></li>
                        <li class="dropdown"><a href="index.cfm?fuseaction=call.customer_information&event=add" title="Ekle"><i class="icon-add"></i></a></li>
                        <li class="dropdown"><a onclick="buttonClickFunction()" href="javascript:;" title="Kaydet"><i class="icon-check"></i></a></li><li class="dropdown" id="transformation"></li>
                    </ul>
               </nav>
            </div>
        </div>
        <cfform name="customer_information_form" method="post" enctype="multipart/form-data" action="">
            <input name="service_id" id="service_id" type="hidden" value="<cfoutput>#serviceId#</cfoutput>">
            <input name="service_no" id="service_no" type="hidden" value="<cfoutput>#service_no#</cfoutput>">
            <input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <div class="row">
                <div class="row formContent">
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                        <div class="form-group" id="item-notify_app_name">
                            <label class="col col-4 col-md-4 col-xs-12">Ad Soyad</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <input type="text" name="name_surname" id="name_surname" value="<cfoutput>#attributes.name_surname#</cfoutput>">
                            </div>
                        </div>
                        <div class="form-group" id="item-company">
                            <label class="col col-4 col-md-4 col-xs-12">Firma Adı</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <input type="text" name="company_name" id="company_name" maxlength="100" value="<cfoutput>#attributes.company_name#</cfoutput>">
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang_main no='807.Ülke'></label> 
                                <div class="col col-8 col-md-8 col-xs-12">
                                <select name="country_id" id="country_id" onchange="change_city();">
                                    <option value=""><cf_get_lang_main dictionary_id='57734.Seçiniz'></option>
                                    <cfoutput query="getCountry">
                                        <option value="#country_id#" <cfif attributes.country_id eq country_id>selected</cfif>>#country_name#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang_main dictionary_id='57971.Şehir'></label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <select name="city_id" id="city_id" onchange="change_county();">
                                    <option value=""><cf_get_lang_main dictionary_id='57734.Seçiniz'></option>
                                    <cfif isdefined("Get_City")>
                                        <cfoutput query="Get_City">
                                            <option value="#city_id#" <cfif attributes.city_id eq city_id>selected</cfif>>#city_name#</option>
                                        </cfoutput>
                                    </cfif>
                                </select> 
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-4 col-xs-12"><cf_get_lang_main no='1226.İlçe'></label>
                            <div class="col col-8 col-xs-12">
                                <select name="county_id" id="county_id">
                                    <option value=""><cf_get_lang_main dictionary_id='57734.Seçiniz'></option>
                                    <cfif len(attributes.county_id) and isdefined("GetCounty")>
                                        <cfoutput query="GetCounty">
                                            <option value="#county_id#"<cfif attributes.county_id eq county_id>selected</cfif>>#county_name#</option>
                                        </cfoutput>
                                    </cfif>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-tel_id">
                            <label class="col col-4 col-md-4 col-xs-12">Telefon Numarası</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <input type="tel" name="tel_no" id="tel_no" autocomplete="nope" value="<cfoutput>#attributes.tel_no#</cfoutput>" value="<cfoutput>#attributes.tel_no#</cfoutput>" validate="integer" message="Telefon No Hatalı!" onKeyUp="isNumber(this);" style="width:280px;">
                            </div>
                        </div>
                        <div class="form-group" id="item-town_id">
                            <label class="col col-4 col-md-4 col-xs-12">E-Posta</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <input type="mail" name="email" autocomplete="nope" id="email" value="<cfoutput>#attributes.email#</cfoutput>" style="width:280px;">
                            </div>
                        </div>
        
                        <div class="form-group" id="item-Industry">
                            <label class="col col-4 col-md-4 col-xs-12">Bulunduğu Sektör</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <select type="text" name="sector" id="sector">
                                <cfoutput><option value="#attributes.sector#" hidden selected>#attributes.sector#</option></cfoutput>
                                <option value=""<cfif attributes.sector eq "">selected</cfif>>Seçiniz</option>
                                <option value="Savunma Sanayi">Savunma Sanayi</option>
                                <option value="Aydınlatma">Aydınlatma</option>
                                <option value="Enerji">Enerji</option>
                                <option value="Elektrik">Elektrik</option>
                                <option value="Elektronik">Elektronik</option>
                                <option value="Kamu">Kamu</option>
                                <option value="Güvenlik Alarm">Güvenlik Alarm</option>
                                <option value="Asansör/Güç Kaynağı/Jeneratör">Asansör/Güç Kaynağı/Jeneratör</option>
                                <option value="Eğitim">Eğitim</option>
                                <option value="Finans">Finans</option>
                                <option value="İnşaat">İnşaat</option>
                                <option value="İş ve Yönetim">İş ve Yönetim</option>
                                <option value="Kimya, Petrol, Lastik ve Plastik">Kimya, Petrol, Lastik ve Plastik</option>
                                <option value="Medya, İletişim ve Yayıncılık">Medya, İletişim ve Yayıncılık</option>
                                <option value="Sağlık ve Sosyal Hizmetler">Sağlık ve Sosyal Hizmetler</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group" id="item-project">
                            <label class="col col-4 col-md-4 col-xs-12"><cf_get_lang_main no='4.Proje'></label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <div class="input-group">
                                  <cfoutput>
								<input type="hidden" name="project_id" id="project_id" value="#attributes.project_id#">
								<input name="project_head" type="text" id="project_head" onfocus="AutoComplete_Create('project_head','PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','list_works','3','200');" value="#attributes.project_head#" autocomplete="off">
								<span class="input-group-addon btnPointer icon-ellipsis" title="<cf_get_lang dictionary_id='57416.Proje'>" onclick="openBoxDraggable('#request.self#?fuseaction=objects.popup_list_projects&project_id=customer_information_form.project_id&project_head=customer_information_form.project_head');"></span>
							    </cfoutput>
                                </div>
                            </div>
                        </div>
                        <div class="form-group" id="item-fill-emp">
                            <label class="col col-4 col-md-4 col-xs-12">Kaydı Alan Temsilci</label>
                            <div class="col col-8 col-md-8 col-xs-12">
                                <div class="input-group">
                                    <cfif isDefined('attributes.service_id') and len(attributes.service_id)>
                                        <cfif len(getService.FORM_FILL_EMPLOYEE)>
                                            <cfquery name="GET_FILL_EMP" datasource="#dsn#">
                                                SELECT
                                                    EMPLOYEE_NAME,
                                                    EMPLOYEE_SURNAME
                                                FROM
                                                    EMPLOYEES
                                                WHERE
                                                    EMPLOYEE_ID = #getService.FORM_FILL_EMPLOYEE#
                                            </cfquery>
                                        </cfif>
                                    </cfif>
                                <cfoutput>
                                    <input type="hidden" name="fill_emp_id" id="fill_emp_id" value="#attributes.fill_emp_id#">
                                    <input type="text" name="fill_emp_name" id="fill_emp_name" value="<cfif isDefined('attributes.service_id') and len(attributes.service_id)><cfif len(getService.FORM_FILL_EMPLOYEE)><cfoutput>#GET_FILL_EMP.EMPLOYEE_NAME# #GET_FILL_EMP.EMPLOYEE_SURNAME#</cfoutput><cfelse></cfif><cfelse></cfif>" onFocus="AutoComplete_Create('fill_emp_name','MEMBER_NAME','MEMBER_NAME','get_member_autocomplete','\'3\',0,0','EMPLOYEE_ID','fill_emp_id','','3','200','get_company()');" autocomplete="off">
                                    <span class="input-group-addon icon-ellipsis btnPointer" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_positions&field_id=customer_information_form.fill_emp_id&field_name=customer_information_form.fill_emp_name&field_emp_id=customer_information_form.fill_emp_id','list');"></span>
                                </cfoutput>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-3 col-md-4 col-sm-6 col-xs-12">
                        <div class="form-group">
                            <div id="fileUpload" class="fileUpload">
                                <cfoutput>
                                    <div class="fileupload-body col col-12 col-md-10 col-sm-10 col-xs-12 offset-1" style="min-height: 270px !important;">
                                        <cfset foldername = createUUID()>
                                        <input type="hidden" name="foldername" value="#foldername#">
                                        <input type="hidden" name="asset" id="asset" value="">
										<input type="hidden" name="asset_control" id="asset_control" value="">
                                        <input type="hidden" name="message_Del" id="message_Del" value="<cfoutput>#getLang('main',51)#</cfoutput>">
                                        <input type="hidden" name="message_Cancel" id="message_Cancel" value="<cfoutput>#getLang('crm',21)#</cfoutput>">
                                        <div class="dropzone dz-clickable dropzonescroll" id="file-dropzone" style="height:175px;">
                                            <div class="dz-default dz-message" style="margin: 4em 1em !important;">
                                                <span>#getLang('assetcare',309)#</span>
                                            </div>
                                        </div>				
                                    </div>  
                                </cfoutput>      
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="catalyst-seperator"><label><br />İlgilendiği Kategoriler</label></div>
                        <div class="col col-12">
                            <div class="col col-2 col-md-3 col-sm-6 col-xs-12">
                                <div class="form-group" id="item-battery">
                                    <label class="container">Pil
                                        <input type="checkbox" name="pil" id="pil" value="1" <cfif attributes.pil eq 1>checked</cfif>>
                                        <span class="checkmark"></span>
                                    </label>
                                </div>
                            </div>
                            <div class="col col-2 col-md-3 col-sm-6 col-xs-12">
                                <div class="form-group" id="item-accumulator">
                                    <label class="container">Akü
                                        <input type="checkbox" name="aku" id="aku" value="1" <cfif attributes.aku eq 1>checked</cfif>>
                                        <span class="checkmark"></span>
                                    </label>
                                </div>
                            </div>
                            <div class="col col-2 col-md-3 col-sm-6 col-xs-12">
                                <div class="form-group" id="item-charger">
                                    <label  class="container">Şarj Cihazı
                                        <input type="checkbox" name="sarj" id="sarj" value="1" <cfif attributes.sarj eq 1>checked</cfif>>
                                        <span class="checkmark"></span>
                                    </label>
                                </div>
                            </div>
                            <div class="col col-3 col-md-3 col-sm-6 col-xs-12 ">
                                <div class="form-group" id="item-lighting">
                                    <label class="container">Fener Aydınlatma
                                        <input type="checkbox" name="fener" id="fener" value="1" <cfif attributes.fener eq 1>checked</cfif>>
                                        <span class="checkmark"></span>
                                    </label>
                                </div>
                            </div>
                            <div class="col col-3 col-md-3 col-sm-6 col-xs-12 ">
                                <div class="form-group" id="item-battery_group">
                                    <label class="container">Batarya Paketi
                                        <input type="checkbox" name="pil_grup" id="pil_grup" value="1" <cfif attributes.pil_grup eq 1>checked</cfif>>
                                        <span class="checkmark"></span>
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="form-group" id="item-service_detail">
                            <label class="col col-12 col-xs-12"><cf_get_lang_main no='217.Açıklama'></label>
                            <div class="col col-12">
                                <cfmodule
                                    template="/fckeditor/fckeditor.cfm"
                                    toolbarset="Basic"
                                    basepath="/fckeditor/"
                                    instancename="service_detail"
                                    valign="top"
                                    value="#attributes.service_detail#"
                                    height="130">
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="form-group">
                           <cfif isdefined('attributes.service_id') and len(attributes.service_id)>
                           	   <cf_workcube_buttons is_upd="1" is_delete="0" add_function='crtl_func(1)' insert_info="Güncelle ve Yeni Form">
                               <cf_workcube_buttons is_upd="1" is_delete="0" add_function='crtl_func(2)'>
                           <cfelse>
                               <cf_workcube_buttons is_upd="0" add_function='crtl_func(1)' insert_info="Kaydet ve Yeni Form">
                               <cf_workcube_buttons is_upd="0" add_function='crtl_func(2)'>
                           </cfif>
                        </div>
                    </div>
                </div>
            </div>
        </cfform>
        <script type="text/javascript" src="/JS/fileupload/dropzone.js"></script>
        <script type="text/javascript" src="/JS/fileupload/fileupload-min.js"></script>
		
		
					<script type="text/javascript">
            function crtl_func(type) 
            {
				document.getElementById('is_form_submitted').value = type;
				
                if(document.getElementById("asset").value == "")
                {
					if(document.getElementById("name_surname").value =="")
                    {
                        alert("Lütfen Ad Soyad Giriniz !");
                        return false;
                    }
				
					
					
					var countryregex = document.getElementById('country_id').value;
					var phoneNumber = document.getElementById('tel_no').value;
					var phoneRGEX = /^(05)([0-9]{2})\s?([0-9]{3})\s?([0-9]{2})\s?([0-9]{2})$/;
					var phoneResult = phoneRGEX.test(phoneNumber);
					var ulke = document.getElementById('country_id').innerHTML;
					if(phoneResult === false && countryregex == 1)
					{						
                        alert("Lütfen Telefon Numarasını Beklenen Formatta Giriniz      05XXXXXXXXX (11 Hane)");
                        return false;
                    }
								
					
					if(document.getElementById("sector").value =="")
                    {
                        alert("Lütfen Sektör Seçiniz !");
                        return false;
                    }
					
				

                }
				
				
				
				var email = $("input[name=email]").val();
				if(email != '')
				{
					var atpos=email.indexOf("@");
					var dotpos=email.lastIndexOf(".");
				
					if ( atpos<1 || dotpos<atpos+2 || dotpos+2>=email.length )
					{
						alert("Lütfen Geçerli Bir Email Adresi Giriniz");
                        return false;
					}
				}

                return true;
            }
            
            function change_city()
            {
                var country_ = document.getElementById('country_id').value;
                if(country_.length != 0)
                    LoadCity(country_,'city_id','county_id',0);
                else
                {
                    document.getElementById('city_id').value = '';
                    document.getElementById('county_id').value = '';
                    LoadCity(country_,'city_id','county_id',0);
                }
            }
            function change_county()
            {
                var city_ = document.getElementById('city_id').value;
                if(city_.length != 0)		
                    LoadCounty(city_,'county_id');
                else
                    document.getElementById('county_id').value = '';
            }
			
			var EmailDomainSuggester = {
  
  domains: ["hotmail.com", "gmail.com", "yahoo.com", "mynet.com"],
  
  bindTo: $('#email'),
  
  init: function() {
    this.addElements();
    this.bindEvents();
  },
  
  addElements: function() {
    // Create empty datalist
    this.datalist = $("<datalist />", {
      id: 'email-options'
    }).insertAfter(this.bindTo);
    // Corelate to input
    this.bindTo.attr("list", "email-options");
  },
  
  bindEvents: function() {
    this.bindTo.on("keyup", this.testValue);
  },
    
  testValue: function(event) {
    var el = $(this),
        value = el.val();
                    
    // email has @
    // remove != -1 to open earlier
    if (value.indexOf("@") != -1) {
      value = value.split("@")[0];
      EmailDomainSuggester.addDatalist(value); 
    } else {
      // empty list
      EmailDomainSuggester.datalist.empty();
    }
     
  },
  
  addDatalist: function(value) {
    var i, newOptionsString = "";
    for (i = 0; i < this.domains.length; i++) {
      newOptionsString += 
        "<option value='" + 
          value + 
          "@" +
          this.domains[i] +
        "'>";
    }
    
    // add new ones
    this.datalist.html(newOptionsString);
  }
  
}

EmailDomainSuggester.init();
        </script>


<script>
    $(document).ready(function(){
			
			$('#email').keyup(function(){
					var charMap = {Ç:'C',Ö:'O',Ş:'S',İ:'I',I:'i',Ü:'U',Ğ:'G',ç:'c',ö:'o',ş:'s',ı:'i',ü:'u',ğ:'g'};

			        var str = $('#email').val();
			        str_array = str.split('');

			        for(var i=0, len = str_array.length; i < len; i++) {
			            str_array[i] = charMap[ str_array[i] ] || str_array[i];
			        }

			        str = str_array.join('');

			        var clearStr = str.replace(" ","").replace("-","").replace(/[^a-z0-9-.çöşüğı@]/gi,"");

			        
			        $('#email').val(clearStr);
			        var print = clearStr;
			
			});
		});
</script>

    </cfif>
</cfif>