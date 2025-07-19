<!-----------------------------------------------------------------------

*************************************************************************
		Copyright Workcube Community Cooperation www.workcube.com
*************************************************************************
Application	: 	W O R K C U B E  H O L I S T I C
Motto		:	Holistic business!
Version		:	21
Description	:   Workcube is an e-business platform for digitalisation.
*************************************************************************
------------------------------------------------------------------------->
<cfcomponent displayname="Application" output="true" hint="Uygulamayı yönetir.">
	<cfscript>
		this.name = hash(getCurrentTemplatePath()) & 'WORKCUBE';
		this.sessionManagement = True;
		this.sessionTimeout = CreateTimeSpan(0,2,0,0);
		this.clientManagement = True;
		this.setClientCookies = True;
		this.customtagpaths = '';
      	this.customtagpaths = ListAppend(this.customtagpaths,getDirectoryFromPath(getCurrentTemplatePath()) & "CustomTags");
		this.customtagpaths = ListAppend(this.customtagpaths,getDirectoryFromPath(getCurrentTemplatePath()) & "Utility/CustomTag");
        this.customtagpaths = ListAppend(this.customtagpaths,getDirectoryFromPath(getCurrentTemplatePath()) & "AddOns/CustomTags");
        this.wschannels = [ 
            { name="chat", cfclistener="message_listener" }, 
            { name="workflow" }, 
            { name="webphone" },
            { name="soketkanal" } // ← KENDİ KANALINI EKLE
        ];

        this.mappings = StructNew();
        this.mappings["/workcube"] = replace(getDirectoryFromPath( getCurrentTemplatePath() ),"\","/","all");
        this.javaSettings = {loadPaths=['./JArchives']};
    </cfscript>
    
    <cfif fileExists(GetDirectoryFromPath(GetCurrentTemplatePath()) & "mailsetting.cfm")>
        <cfinclude template="mailsetting.cfm">
    </cfif>

    <!--- Sayfa request özellikleri --->
	<cfsetting requesttimeout="99999" showdebugoutput="false" enablecfoutputonly="false" />

	<!------------------------ on Application Start -------------------------
        Functions:params, objects, langs, functions, workcube_app
	------------------------------------------------------------------------>
	<cffunction name="OnApplicationStart" access="public" returntype="boolean" output="false" hint="Uygulama başladığı anda çalıştırılacak kodlar. Tek defa çalıştırır.">

        <cfscript>
            
            application.plevneresolved = structNew();
            application.serviceManager = new WMO.Services.ApplicationServiceManager();
            application.serviceManager.initialize( ApplicationVariableScope: variables );
            application.serviceManager.ConfigurationService.RegisterComponentConfiguration( "WMO.params" );
            application.serviceManager.Register( "WMO.Services.V16CompatibilityService" );
            application.serviceManager.Register( "AddOns.Plevne.core.injector" );

        </cfscript>

        <cfset application.systemObjects = createObject("component", "WMO.objects")>
		<cfset structAppend(variables,application.systemObjects.workcubeObjects('#dsn#'))/>
		<cfset structAppend(variables,application.systemObjects.parametricObjects('#dsn#'))/>
		<cfset structAppend(variables,application.systemObjects.parametricObjectsSystem('#dsn#'))/>
		<cfset application.langSet = createObject("component", "WMO.langs")>
        <cfset structAppend(variables,application.langSet.langSet('#dsn#'))/>
		<cfset application.functions = createObject("component", "WMO.functions")>
        <cfset structAppend(variables,application.functions)/>
		<cfset application.sqlFunctions = createObject("component", "WMO.sqlFunctions")>
        <cfset structAppend(variables,application.sqlFunctions)/>
		<cfset application.faFunctions = createObject("component", "cfc.faFunctions")>
        <cfset structAppend(variables,application.faFunctions)/>
		<cfset application.hrFunctions = createObject("component", "cfc.hrFunctions")>
        <cfset structAppend(variables,application.hrFunctions)/>
		<cfset application.sdFunctions = createObject("component", "cfc.sdFunctions")>
        <cfset structAppend(variables,application.sdFunctions)/>
		<cfset application.mmFunctions = createObject("component", "cfc.mmFunctions")>
        <cfset structAppend(variables,application.mmFunctions)/>
		<cfset application.GeneralFunctions = createObject("component", "WMO.GeneralFunctions")>
        <cfset structAppend(variables,application.GeneralFunctions)/>
		<cfset application.workcube_app = createObject("component", "WMO.workcube_app")>
        <cfset structAppend(variables,application.workcube_app)/>
        <cfset application.upgradeSystem = createObject("component","cfc.upgrade")>
        <cfset structAppend(variables,application.upgradeSystem)/>

        <cfscript>
            local.systemParam   = application.systemParam.systemParam();
            if(isDefined("local.systemParam.bugLog")){
                if(Len(local.systemParam.bugLog.bugLogListener)){
                    application.bugLog = createObject("component", "WMO.BugLogService");
                    structAppend(variables,application.bugLog);
                    application.bugLog.init(
                        bugLogListener  = local.systemParam.bugLog.bugLogListener,
                        appName         = CGI.SERVER_NAME & "-" & application.host.hostName
                    );
                }
            }

            //Proxy ayarları Gramoni-Mahmut 25.12.2019 16:21
            if(isDefined("local.systemParam.proxy")){
                if(Len(local.systemParam.proxy.proxyHost) And Len(local.systemParam.proxy.proxyPort)){
                    javaSystem	= createObject("java", "java.lang.System");
                    jProps		= javaSystem.getProperties();

                    jProps.setProperty("java.net.useSystemProxies", "true");
                    jProps.setProperty('http.proxyHost', '#local.systemParam.proxy.proxyHost#');
                    jProps.setProperty('http.proxyPort', '#local.systemParam.proxy.proxyPort#');
                    jProps.setProperty('https.proxyHost', '#local.systemParam.proxy.proxyHost#');
                    jProps.setProperty('https.proxyPort', '#local.systemParam.proxy.proxyPort#');
                    if(isdefined("local.systemParam.proxy.nonproxylist") and len(local.systemParam.proxy.nonproxylist)){
                        jProps.setProperty('http.nonProxyHosts', '#local.systemParam.proxy.nonproxylist#');
                        jProps.setProperty('https.nonProxyHosts', '#local.systemParam.proxy.nonproxylist#');
                    }
                }
            }
        </cfscript>

		<cfreturn true />
	</cffunction>


	<!---
	*************************************************************************
		OnSessionStart
	*************************************************************************
		Description : ColdFusion'a ilk istek geldiği anda çalışır. CFID,CFTOKEN, SESSIONID gibi değerler burada otomatik oluşur. Kullanıcı giriş ekranından giriş yaptığı zaman oluşan session ile alakası yoktur.
	--->
	<cffunction name="OnSessionStart" access="public" returntype="void" output="false" hint="Kullanıcı oturumu başladığında çalıştırılacak kodlar.">
		<cfreturn/>
	</cffunction>

    <!---
	<cffunction name="OnRequestStart" access="public" returntype="boolean" output="false" hint="Fires at first part of page processing.">
		<cfargument name="TargetPage" type="string" required="true" />

		<cfreturn true />
	</cffunction>
	--->

    <!---
		*************************************************************************
			onRequest
		*************************************************************************
			Description : En yoğun kullanılan kısımdır. Sayfa isteğinde bulunulduğunda bu kısım çalışır. OnRequestStart fonksiyonu ajax isteklerinde sorun yaratabildiği için geneli buraya toplanmıştır. Ana amacı genel kontroller yaptıktan sonra index.cfm'e yönlenmektir.
			Başlarında yer alan structAppend işleminin amacı application tarafında tutulan parametrik değerlerin, fonksiyonların sistem içersinde kullanılış şeklini değiştirmemektir. Yazılmadığı takdirde örneğin DSN atamalarının application.dsn şekline dönüştürülmesi gerekirdi.
			Index öncesi gelen kontroller sırasıyla şu şekildedir.
			Session kontrolü (wmo\w3cfsession.cfm) : Kullanıcı sistemden düşmüştür. Başka bir browser'da oturum açmıştır. Bunlar kontrol ediliyor.
			cf_xml_pers_settings_reader : Kullanıcı XML'i okunur. Açık kapalı gelmesini istediği alanlar burada tutulur.
			secure : Saldırı girişimleri burada yakalanır.
			control_time_cost : Haftalık zaman harcaması kontrolü
			sessionParams : Session'a özgü parametreler yüklenir. Örneğin dsn_2
			getDeniedPages : Yasaklı-Kısıtlı sayfa kontrolleri
	--->
	<cffunction name="onRequest" returnType="void">
		<cfargument name="targetPage" type="string" required="true" /><!--- Burası index.cfm gelir. Ulaşılmak istenen dosya index.cfm içerisindeki wrkTemplate'tir. --->

        <cfif IsDefined("application.upgradeSystem")>
            <cfif ((application.upgradeSystem.status) and isdefined('session.ep.userid') and session.ep.admin neq 1) or ((application.upgradeSystem.status) and not isdefined('session.ep.userid'))>
                <cfinclude template="maintenance.cfm">
                <cfabort>
            </cfif>
        <cfelse>
            <cfset OnApplicationStart()>
        </cfif>
        
        <cfif isdefined("url.fuseaction") and len(url.fuseaction) and isdefined("url.restart") and url.restart eq 1>
            <cfscript>
                OnApplicationStart();
            </cfscript>
        </cfif>

        <cfinclude template="/AddOns/Plevne/interceptors/gopcha_application.cfm">
        <cfinclude template="/AddOns/Plevne/interceptors/fuseactionshield.cfm">

        <cfinclude template="/WMO/middlewares/systemparam2request.cfm">
        <cfinclude template = "/WMO/middlewares/wexauth.cfm">
        <cfif IsDefined("url.runwro") and url.runwro eq 1><cfinclude template = "/WMO/middlewares/wro.cfm"></cfif>
        <cfif isDefined("application.plevne_service")>
        <cfset application.plevne_service.inject()>
        </cfif>
        <cfif isdefined("url.fuseaction") and len(url.fuseaction)>
            <cfquery name="GET_FUSEACTION" datasource="#dsn#">
                SELECT
                    WINDOW,
                    FILE_PATH,
                    DICTIONARY_ID,
                    CASE WHEN ADDOPTIONS_CONTROLLER_FILE_PATH IS NOT NULL THEN ADDOPTIONS_CONTROLLER_FILE_PATH ELSE CONTROLLER_FILE_PATH END AS CONTROLLER_FILE_PATH,
                    MODULE_NO,
                    FRIENDLY_URL,
                    IS_LEGACY,
                    ISNULL(LICENCE,1) AS LICENCE,
                    HEAD,
                    DISPLAY_BEFORE_PATH,
                    DISPLAY_AFTER_PATH,
                    ACTION_BEFORE_PATH,
                    ACTION_AFTER_PATH,
                    DATA_CFC,
                    TYPE,
                    SECURITY,
                    XML_PATH
                FROM
                    WRK_OBJECTS
                WHERE
                    FULL_FUSEACTION = '#url.fuseaction#'
            </cfquery>
            <cfif GET_FUSEACTION.recordcount>
                <cfscript>
                    application.objects['#URL.fuseaction#']['window'] = GET_FUSEACTION.WINDOW;
                    application.objects['#URL.fuseaction#']['filePath'] = GET_FUSEACTION.FILE_PATH;
                    application.objects['#URL.fuseaction#']['DICTIONARY_ID'] = GET_FUSEACTION.DICTIONARY_ID;
                    application.objects['#URL.fuseaction#']['CONTROLLER_FILE_PATH'] = GET_FUSEACTION.CONTROLLER_FILE_PATH;
                    application.objects['#URL.fuseaction#']['MODULE_NO'] = GET_FUSEACTION.MODULE_NO;
                    application.objects['#URL.fuseaction#']['FRIENDLY_URL'] = GET_FUSEACTION.FRIENDLY_URL;
                    application.objects['#URL.fuseaction#']['LEGACY'] = GET_FUSEACTION.IS_LEGACY;
                    application.objects['#URL.fuseaction#']['LICENCE'] = GET_FUSEACTION.LICENCE;
                    application.objects['#URL.fuseaction#']['DISPLAY_BEFORE_PATH'] = GET_FUSEACTION.DISPLAY_BEFORE_PATH;
                    application.objects['#URL.fuseaction#']['DISPLAY_AFTER_PATH'] = GET_FUSEACTION.DISPLAY_AFTER_PATH;
                    application.objects['#URL.fuseaction#']['ACTION_BEFORE_PATH'] = GET_FUSEACTION.ACTION_BEFORE_PATH;
                    application.objects['#URL.fuseaction#']['ACTION_AFTER_PATH'] = GET_FUSEACTION.ACTION_AFTER_PATH;
                    application.objects['#URL.fuseaction#']['DATA_CFC'] = GET_FUSEACTION.DATA_CFC;
                    application.objects['#URL.fuseaction#']['TYPE'] = GET_FUSEACTION.TYPE;
                    application.objects['#URL.fuseaction#']['SECURITY'] = GET_FUSEACTION.SECURITY;
                    application.objects['#URL.fuseaction#']['XML_PATH'] = GET_FUSEACTION.XML_PATH;
                </cfscript>
            </cfif>
        </cfif>
        <cfset structAppend(variables,application.functions)/>
        <cfif IsDefined("application.sqlFunctions")><cfset structAppend(variables,application.sqlFunctions)/></cfif>
        <cfset structAppend(variables,application.faFunctions)/>
        <cfset structAppend(variables,application.hrFunctions)/>
        <cfset structAppend(variables,application.sdFunctions)/>
        <cfset structAppend(variables,application.mmFunctions)/>
        <cfset structAppend(variables,application.GeneralFunctions)/>
        <cfset structAppend(variables,application.workcube_app)/>

		<cfif isDefined("SESSION.EP.MONEY")>
			<cfset str_money_bskt = SESSION.EP.MONEY>
            <cfset str_money_bskt2 = SESSION.EP.MONEY2><!--- sistem 2. dvizi --->
            <cfset str_money_bskt_main = SESSION.EP.MONEY><!--- str_money_bskt aşağıda değiştirildigi için burda str_money_bskt_main diye bi değişkene set ediliyor,kaldırmayınz --->
            <cfif isdefined("session.ep.our_company_info.rate_round_num")>
                <cfset rate_round_num_info = session.ep.our_company_info.rate_round_num>
            <cfelse>
                <cfset rate_round_num_info = 2>
            </cfif>
            <cfset int_bsk_comp_id = SESSION.EP.COMPANY_ID>
            <cfset int_bsk_period_id = SESSION.EP.PERIOD_ID>
        <cfelseif isDefined("SESSION.PP.MONEY")>
            <cfset str_money_bskt = SESSION.PP.MONEY>
            <cfset str_money_bskt2 = SESSION.PP.MONEY2>
            <cfset str_money_bskt_main = SESSION.PP.MONEY>
            <cfif isdefined("session.pp.our_company_info.rate_round_num")>
                <cfset rate_round_num_info = session.pp.our_company_info.rate_round_num>
            <cfelse>
                <cfset rate_round_num_info = 2>
            </cfif>
            <cfset int_bsk_comp_id = SESSION.PP.OUR_COMPANY_ID>
            <cfset int_bsk_period_id = SESSION.PP.PERIOD_ID>
        <cfelseif isDefined("SESSION.WW.MONEY")>
            <cfset str_money_bskt = SESSION.WW.MONEY>
            <cfset str_money_bskt2 = SESSION.WW.MONEY2>
            <cfset str_money_bskt_main = SESSION.WW.MONEY>
            <cfif isdefined("session.pp.our_company_info.rate_round_num")>
                <cfset rate_round_num_info = session.pp.our_company_info.rate_round_num>
            <cfelse>
                <cfset rate_round_num_info = 2>
            </cfif>
            <cfset int_bsk_comp_id = SESSION.WW.OUR_COMPANY_ID>
            <cfset int_bsk_period_id = SESSION.WW.PERIOD_ID>
        </cfif>
        <cfif not isdefined("session_base") and isdefined("session.ep")>
            <cfset session_base = session.ep>
        </cfif>
        <cfif isdefined("session.ep.dateformat_style") and len(session.ep.dateformat_style)>
            <cfset dateformat_style = session.ep.dateformat_style>
            <cfif dateformat_style is 'dd/mm/yyyy'>
                <cfset validate_style = 'eurodate'>
            <cfelse>
                <cfset validate_style = 'date'>
            </cfif>
            <cfset timeformat_style = session.ep.timeformat_style>
        <cfelse>
            <cfset dateformat_style = 'dd/mm/yyyy'>
            <cfset validate_style = 'eurodate'>
            <cfset timeformat_style = 'HH:MM'>
        </cfif>

        <cfif isdefined("session.ep.moneyformat_style") and len(session.ep.moneyformat_style)>
            <cfset moneyformat_style = session.ep.moneyformat_style>
        <cfelse>
            <cfset moneyformat_style = 0> 
        </cfif>
        
        <cfscript>
            attributes=structNew();
            StructAppend(attributes, url, "no");
            StructAppend(attributes, form, "no");
        </cfscript>
        
        <cfset request.self='index.cfm'>
        <cfset directAccessFiles='#request.self#,wrk_grid_edit.cfc,stock_report.cfc,wrk_visit.cfm,get_wrk_component_as_xml.cfm,dao.cfc,fck_image.cfm,fck_link.cfm,upload.cfm,config.cfm,connector.cfm,menu_icerik.cfm,special_functions.cfm,notfound.cfm,notfound_file.cfm,chat.cfc,cfopenchat_ajax.cfc,cfopenchat.cfc,ajax.cfc,class.cfc,admin.cfm,fbx_workcube_maintenance.cfm,index2.cfm,echo.cfc,load_page.cfm,cost_action_2.cfm,get_workdata.cfm,iedit.cfc,web_services,captchaService.cfc,captchaServiceConfigBean.cfc,olapcube_grid.cfc,artservice.cfc'>
        <cfset page_code = ''>
        <cfloop collection='#attributes#' item='k'><!--- Kullanicinin bulundugu sayfa parametreleri aliniyor --->
            <!--- icerik elemani objects.popup_documenter in alttaki ekranin div icindeki html source tasiyan hidden elemanidir --->
            <cfif (k neq 'FUSEACTION') and (k neq 'ICERIK') and (k neq 'IS_BASKET_HIDDEN')>
                <cfset page_code = page_code & "&" & k & "=" & attributes[k]>
            </cfif>
        </cfloop>
        <cfinclude template="WMO/w3CfSession.cfm">
        <cfscript>
            if(isdefined("attributes.fuseaction") and len(attributes.fuseaction))
            {
                request.pagelangList=arrayNew(1);
                fusebox.circuit = listFirst(attributes.fuseaction,'.');
                fusebox.general_cached_time = CreateTimeSpan(0,0,'#iif(isDefined('form.fieldnames'),0,15)#',0);
                fusebox.simdi = now();
                fusebox.fuseaction = listLast(attributes.fuseaction,'.');
                attributes.circuit = listFirst(attributes.fuseaction,'.');

                if(not findnocase('emptypopup',attributes.fuseaction))
                {
                    if (isdefined('session.ep.userid')) upd_workcube_app_action(0);
                }
            }
        </cfscript>
        <cfif isdefined("attributes.fuseaction") and len(attributes.fuseaction)>
            <cftry>
                <cf_xml_pers_settings_reader>
                <cfcatch>
                </cfcatch>
            </cftry>
        </cfif>
        <cfset application.secure = createObject("component", "WMO.secure")>
        <cfif isDefined("application.systemParam.is_wrk_visit_report") and application.systemParam.is_wrk_visit_report eq 1>
            <cfinclude template="WMO/visit.cfm">
        </cfif>
        
        <cfif isdefined("attributes.fuseaction")>
            <cfif isdefined("session.ep.must_password_change") AND session.ep.must_password_change EQ 1
            AND isDefined("session.ep.must_password_change_ignore_actions") AND NOT ArrayContains(session.ep.must_password_change_ignore_actions, attributes.fuseaction)
            And use_active_directory Neq 1>
                <script type="text/javascript">
                    window.location.href = "<cfoutput>#request.self#</cfoutput>?fuseaction=myhome.list_myaccount_password";
                </script>
            </cfif>
            <cfif application.secure.secure("#attributes.fuseaction#","#workcube_mode_ip#","#dsn#")>
                <!--- Haftalık zaman harcaması kontrolü --->
                <cfset application.control_time_cost = createObject("component", "cfc.control_time_cost")>

                <cfif isdefined("session.ep.userid")>
                    <cfset application.sessionParams = createObject("component", "WMO.sessionParams")>
                    <cfset structAppend(variables,application.sessionParams.sessionParam("#database_type#","#dsn#","#dsn1#","#session.ep.period_year#","#session.ep.company_id#"))>
                </cfif>

                <cfset application.denied_pages = ''>
                <cfset application.pageDenied = 0>
                <cfset pageDenied = 0>

                <cfset application.controlSession = createObject("component", "WMO.controlSession")>
                <cfif isdefined("session.ep.userid")>
                    <cfif not application.controlSession.controlSession('#dsn#','#session.ep.userid#')>
                        <cfloop collection=#session# item="key_field">
                            <cfscript>
                            if((key_field neq 'error_text') and (key_field neq 'sessionid'))
                                StructDelete(session, key_field);
                            </cfscript>
                        </cfloop>
                    </cfif>
                </cfif>

                <cfif isdefined("session.ep.userid")>
                    <cfset application.getDeniedPages = createObject("component", "WMO.getDeniedPages")>
                    <cfset deniedData = application.getDeniedPages.pageAuthority('#dsn#','#session.ep.userid#','#attributes.fuseaction#','#session.ep.position_code#', attributes.wrkflow?:0, "?" & cgi.QUERY_STRING, attributes.event?:'', cgi.http_referer, attributes.wsr_code?:'')>
                    <cfset structAppend(variables, deniedData)/>
                    <cfif StructKeyExists(application.deniedPages,attributes.fuseaction)>
                        <cfif deniedData['#attributes.fuseaction#']['IS_VIEW'] eq 1>
                            <cfset application.pageDenied = 1>
                            <cfset pageDenied = 1>
                        <cfelse>
                            <cfset application.pageDenied = 0>
                            <cfset pageDenied = 0>
                        </cfif>
                    </cfif>
                    <cfif not listFindNoCase('objects,objects2,home,myhome',listFirst(attributes.fuseaction,'.'),',')>
                        <cfset controlObjects = application.systemObjects.workObjects('#dsn#','#session.ep.userid#','#attributes.fuseaction#')>
                        
                        <cfif (not controlObjects.recordcount) and 
                        (
                            ( 
                                not StructKeyExists(deniedData, attributes.fuseaction)
                            ) 
                            or 
                            (
                                StructKeyExists(deniedData, attributes.fuseaction) 
                                and deniedData['#attributes.fuseaction#']['IS_VIEW'] eq 1
                            )
                        )>
                            <cfset application.pageDenied = 1>
                            <cfset pageDenied = 1>
                        </cfif>
                    </cfif>
                    <cfif application.getDeniedPages.recordAuthority('#dsn#','#session.ep.userid#','#replace(CGI.QUERY_STRING,"fuseaction=","")#','#session.ep.company_id#','#session.ep.period_id#')>
                        <cfset application.pageDenied = 2>
                        <cfset pageDenied = 2>
                    </cfif>
                </cfif>
                <cfinclude template="fbx_workcube_funcs.cfm">
                <cfif isdefined("application.denied_pages")>
                    <cfset denied_pages = application.denied_pages>
                </cfif>
                <cfinclude template="#ARGUMENTS.targetPage#" />
            </cfif>
        <cfelse>
            <cfset application.pageDenied = 0>
            <cfset pageDenied = 0>
            <cfinclude template="#ARGUMENTS.targetPage#" />
        </cfif>

		<cfreturn />
	</cffunction>


    <!---
		*************************************************************************
			OnRequestEnd
		*************************************************************************
			Description : İstek bittiği anda çalışır. Ajax sayfalarda sorunlar yaratabiliyor. Log kayıtları için kullanılabilir. Fakat bu durumda da dataları buraya taşımak için network meşgul edilecektir. Bu yüzden log kayıtlarını isteğin sonunda tutuyoruz.
	--->
	<cffunction name="OnRequestEnd" access="public" returntype="void" output="true" hint="Request sonrası çalışır.">
        <cfif isDefined("application.plevne_service")>
        <cfset application.plevne_service.end_trace()>
        </cfif>
		<cfreturn />
	</cffunction>

    <!---
		*************************************************************************
			OnSessionEnd
		*************************************************************************
			Description : ColdFusion session'ı son bulduğunda kullanılabilir. Catalyst'te herhangi bir şekilde ihtiyaç duyulmuyor. Sistemden çıkışlarda kullanıcın sistem session'ı silinir. Buradaki session CF tarafında tutulan session'dır. Kullanıcı sistemde belirtilen süre boyunca işlem yapmadığında otomatik olarak sonlandırılır.
	--->
    <cffunction name="OnSessionEnd" access="public" returntype="void" output="false" hint="Session kapanırken çalışır.">
		<cfargument name="SessionScope" type="struct" required="true" />
		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#"	/>
		<cfreturn />
	</cffunction>

    <!---
		*************************************************************************
			OnApplicationEnd
		*************************************************************************
			Description : Application durduğunda çalışır. Kullanılmıyor. Burada da log atılabilir. Fakat manuel application sonlandırmada çalışmaz
	--->
	<cffunction name="OnApplicationEnd" access="public" returntype="void" output="false" hint="Uygulama sonlandığında çalışır.">
 		<cfargument name="ApplicationScope" type="struct" required="false" default="#StructNew()#" 	/>
		<cfreturn />
	</cffunction>

    <!---
		*************************************************************************
			OnError
		*************************************************************************
			Description : Hata durumlarında devreye girer. error.cfc ile bütünleşiktir. Error.cfc içinde tanımlı olan hatalarda dile bağlı olarak hata ekranları oluşturur. Development mod için detay içerir. Hatalarla Geliştirilecek.
    --->
    
    <cffunction name="OnError" access="public" returntype="void" output="true" hint="Hataları raporlar.">
		<cfargument name="Exception" type="any" required="true" />
        <cfargument name="EventName" type="string" required="false" default=""/>

        <cfdump var="#arguments.Exception#" abort>

        <cfscript>
            createObject( "component", "WMO.error_manager" ).init(
                exp: arguments.Exception, 
                attr: isdefined("attributes") ? attributes : {} 
            ).setError();
        </cfscript>
        
        <cfreturn/>
          
    </cffunction>

</cfcomponent>