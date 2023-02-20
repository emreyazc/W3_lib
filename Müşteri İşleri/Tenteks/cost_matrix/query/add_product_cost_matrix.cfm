<cfscript>
    alm_cost_1 = REReplace("#attributes.alm_cost_1#",",",".","ALL");
    alm_cost_2 = REReplace("#attributes.alm_cost_2#",",",".","ALL");
    pvc_cost = REReplace("#attributes.pvc_cost#",",",".","ALL");
    zip_cost = REReplace("#attributes.zip_cost#",",",".","ALL");
    al_case_cost = REReplace("#attributes.al_case_cost#",",",".","ALL");
    al_case_lid_cost = REReplace("#attributes.al_case_lid_cost#",",",".","ALL");
    al_profile_cost = REReplace("#attributes.al_profile_cost#",",",".","ALL");
    al_weight_cost = REReplace("#attributes.al_weight_cost#",",",".","ALL");
    pipe_cost = REReplace("#attributes.pipe_cost#",",",".","ALL");
    fabric_cost = REReplace("#attributes.fabric_cost#",",",".","ALL");
    eaves_cost = REReplace("#attributes.eaves_cost#",",",".","ALL");
    case_lid_cost = REReplace("#attributes.case_lid_cost#",",",".","ALL");
    bottom_lid_cost = REReplace("#attributes.bottom_lid_cost#",",",".","ALL");
    slat_set_cost = REReplace("#attributes.slat_set_cost#",",",".","ALL");
    engine_holder_cost = REReplace("#attributes.engine_holder_cost#",",",".","ALL");
    pipe_kit_cost = REReplace("#attributes.pipe_kit_cost#",",",".","ALL");
    engine_adapter_cost = REReplace("#attributes.engine_adapter_cost#",",",".","ALL");
    slat_end_cost = REReplace("#attributes.slat_end_cost#",",",".","ALL");
    zip_holder_cost = REReplace("#attributes.zip_holder_cost#",",",".","ALL");
    roller_cost = REReplace("#attributes.roller_cost#",",",".","ALL");
    engine_cost = REReplace("#attributes.engine_cost#",",",".","ALL");
    al_unit_cost = REReplace("#attributes.al_unit_cost#",",",".","ALL");
    lme_iron_unit_cost = REReplace("#attributes.lme_iron_unit_cost#",",",".","ALL");
    paint_cost = REReplace("#attributes.paint_cost#",",",".","ALL");
    fabric_unit_cost = REReplace("#attributes.fabric_unit_cost#",",",".","ALL");
    labor_cost = REReplace("#attributes.labor_cost#",",",".","ALL");
</cfscript>

<cfquery  name="ADD_COST_MATR" datasource="#DSN1#">
    INSERT INTO
        COST_MATRIX 
        (
            MATRIX_STATUS,
            MAIN_PRODUCT_ID,
            MAIN_PRODUCT_NAME,
            ALM_ID_1,
            ALM_NAME_1,
            ALM_COST_1,
            ALM_ID_2,
            ALM_NAME_2,
            ALM_COST_2,
            PVC_ID,
            PVC_NAME,
            PVC_COST,
            ZIP_ID,
            ZIP_NAME,
            ZIP_COST,
            AL_CASE_ID,
            AL_CASE_NAME,
            AL_CASE_COST,
            AL_CASE_LID_ID,
            AL_CASE_LID_NAME,
            AL_CASE_LID_COST,
            AL_PROFILE_ID,
            AL_PROFILE_NAME,
            AL_PROFILE_COST,
            AL_WEIGHT_ID,
            AL_WEIGHT_NAME,
            AL_WEIGHT_COST,
            PIPE_ID,
            PIPE_NAME,
            PIPE_COST,
            FABRIC_ID,
            FABRIC_NAME,
            FABRIC_COST,
            EAVES_ID,
            EAVES_NAME,
            EAVES_COST,
            CASE_LID_ID,
            CASE_LID_NAME,
            CASE_LID_COST,
            BOTTOM_LID_ID,
            BOTTOM_LID_NAME,
            BOTTOM_LID_COST,
            SLAT_SET_ID,
            SLAT_SET_NAME,
            SLAT_SET_COST,
            ENGINE_HOLDER_ID,
            ENGINE_HOLDER_NAME,
            ENGINE_HOLDER_COST,
            PIPE_KIT_ID,
            PIPE_KIT_NAME,
            PIPE_KIT_COST,
            ENGINE_ADAPTER_ID,
            ENGINE_ADAPTER_NAME,
            ENGINE_ADAPTER_COST,
            SLAT_END_ID,
            SLAT_END_NAME,
            SLAT_END_COST,
            ZIP_HOLDER_ID,
            ZIP_HOLDER_NAME,
            ZIP_HOLDER_COST,
            ROLLER_ID,
            ROLLER_NAME,
            ROLLER_COST,
            ENGINE_ID,
            ENGINE_NAME,
            ENGINE_COST,
            AL_UNIT_COST,
            LME_IRON_UNIT_COST,
            FABRIC_UNIT_COST,
            PAINT_COST,
            LABOR_COST,
            CASE_LID_QUANTITY,
            BOTTOM_LID_QUANTITY,
            SLAT_SET_QUANTITY,
            ENGINE_HOLDER_QUANTITY,
            PIPE_KIT_QUANTITY,
            ENGINE_ADAPTER_QUANTITY,
            SLAT_END_QUANTITY,
            ZIP_HOLDER_QUANTITY,
            ROLLER_QUANTITY,
            ENGINE_QUANTITY,
            RECORD_MEMBER,
            RECORD_DATE
        )
            VALUES
        (   
            <cfif isDefined("attributes.matrix_status")>1<cfelse>0</cfif>,
            <cfif isDefined("attributes.main_product_id") and len(attributes.main_product_id)>#attributes.main_product_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.main_product_name") and len(attributes.main_product_name)>'#attributes.main_product_name#'<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.alm_id_1") and len(attributes.alm_id_1)>#attributes.alm_id_1#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.alm_name_1") and len(attributes.alm_name_1)>'#attributes.alm_name_1#'<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.alm_cost_1") and len(attributes.alm_cost_1)>#alm_cost_1#</cfif>,
            <cfif isDefined("attributes.alm_id_2") and len(attributes.alm_id_2) and len(attributes.alm_id_2)>#attributes.alm_id_2#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.alm_name_2") and len(attributes.alm_name_2) and len(attributes.alm_name_2)>'#attributes.alm_name_2#'<cfelse>NULL</cfif>,
            <cfif len(attributes.alm_cost_2)>#alm_cost_2#</cfif>,
			<cfif isDefined("attributes.pvc_id") and len(attributes.pvc_id)>#attributes.pvc_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.pvc_name") and len(attributes.pvc_name)>'#attributes.pvc_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.pvc_cost)>#pvc_cost#</cfif>,
			<cfif isDefined("attributes.zip_id") and len(attributes.zip_id)>#attributes.zip_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.zip_name") and len(attributes.zip_name)>'#attributes.zip_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.zip_cost)>#zip_cost#</cfif>,
            <cfif isDefined("attributes.al_case_id") and len(attributes.al_case_id)>#attributes.al_case_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.al_case_name") and len(attributes.al_case_name)>'#attributes.al_case_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.al_case_cost)>#al_case_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.al_case_lid_id") and len(attributes.al_case_lid_id)>#attributes.al_case_lid_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.al_case_lid_name") and len(attributes.al_case_lid_name)>'#attributes.al_case_lid_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.al_case_lid_cost)>#al_case_lid_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.al_profile_id") and len(attributes.al_profile_id)>#attributes.al_profile_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.al_profile_name") and len(attributes.al_profile_name)>'#attributes.al_profile_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.al_profile_cost)>#al_profile_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.al_weight_id") and len(attributes.al_weight_id)>#attributes.al_weight_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.al_weight_name") and len(attributes.al_weight_name)>'#attributes.al_weight_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.al_weight_cost)>#al_weight_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.pipe_id") and len(attributes.pipe_id)>#attributes.pipe_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.pipe_name") and len(attributes.pipe_name)>'#attributes.pipe_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.pipe_cost)>#pipe_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.fabric_id") and len(attributes.fabric_id)>#attributes.fabric_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.fabric_name") and len(attributes.fabric_name)>'#attributes.fabric_name#'<cfelse>NULL</cfif>,
            <cfif len(attributes.fabric_cost)>#fabric_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.eaves_id") and len(attributes.eaves_id)>#attributes.eaves_id#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.eaves_name") and len(attributes.eaves_name)>'#attributes.eaves_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.eaves_cost)>#eaves_cost#<cfelse>NULL</cfif>,
            <cfif isDefined("attributes.case_lid_id") and len(attributes.case_lid_id) and len(attributes.case_lid_id)>#attributes.case_lid_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.case_lid_name") and len(attributes.case_lid_name) and len(attributes.case_lid_name)>'#attributes.case_lid_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.case_lid_cost)>#case_lid_cost#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.bottom_lid_id") and len(attributes.bottom_lid_id)>#attributes.bottom_lid_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.bottom_lid_name") and len(attributes.bottom_lid_name)>'#attributes.bottom_lid_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.bottom_lid_cost)>#bottom_lid_cost#</cfif>,
			<cfif isDefined("attributes.slat_set_id") and len(attributes.slat_set_id)>#attributes.slat_set_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.slat_set_name") and len(attributes.slat_set_name)>'#attributes.slat_set_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.slat_set_cost)>#slat_set_cost#</cfif>,
			<cfif isDefined("attributes.engine_holder_id") and len(attributes.engine_holder_id)>#attributes.engine_holder_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.engine_holder_name") and len(attributes.engine_holder_name)>'#attributes.engine_holder_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.engine_holder_cost)>#engine_holder_cost#</cfif>,
			<cfif isDefined("attributes.pipe_kit_id") and len(attributes.pipe_kit_id)>#attributes.pipe_kit_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.pipe_kit_name") and len(attributes.pipe_kit_name)>'#attributes.pipe_kit_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.pipe_kit_cost)>#pipe_kit_cost#</cfif>,
			<cfif isDefined("attributes.engine_adapter_id") and len(attributes.engine_adapter_id)>#attributes.engine_adapter_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.engine_adapter_name") and len(attributes.engine_adapter_name)>'#attributes.engine_adapter_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.engine_adapter_cost)>#engine_adapter_cost#</cfif>,
			<cfif isDefined("attributes.slat_end_id") and len(attributes.slat_end_id)>#attributes.slat_end_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.slat_end_name") and len(attributes.slat_end_name)>'#attributes.slat_end_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.slat_end_cost)>#slat_end_cost#</cfif>,
			<cfif isDefined("attributes.zip_holder_id") and len(attributes.zip_holder_id)>#attributes.zip_holder_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.zip_holder_name") and len(attributes.zip_holder_name)>'#attributes.zip_holder_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.zip_holder_cost)>#zip_holder_cost#</cfif>,
			<cfif isDefined("attributes.roller_id") and len(attributes.roller_id)>#attributes.roller_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.roller_name") and len(attributes.roller_name)>'#attributes.roller_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.roller_cost)>#roller_cost#</cfif>,
			<cfif isDefined("attributes.engine_id") and len(attributes.engine_id)>#attributes.engine_id#<cfelse>NULL</cfif>,
			<cfif isDefined("attributes.engine_name") and len(attributes.engine_name)>'#attributes.engine_name#'<cfelse>NULL</cfif>,
			<cfif len(attributes.engine_cost)>#engine_cost#</cfif>,
            <cfif len(attributes.al_unit_cost)>#al_unit_cost#</cfif>,
			<cfif len(attributes.lme_iron_unit_cost)>#lme_iron_unit_cost#</cfif>,
            <cfif len(attributes.fabric_unit_cost)> #fabric_unit_cost#</cfif>,
            <cfif len(attributes.paint_cost)>#paint_cost#</cfif>,
            <cfif len(attributes.labor_cost)>#labor_cost#</cfif>,
			<cfif isdefined("attributes.case_lid_quantity") and len(attributes.case_lid_quantity)>#attributes.case_lid_quantity#<cfelse>NULL</cfif>,
			<cfif isdefined("attributes.bottom_lid_quantity") and len(attributes.bottom_lid_quantity)>#attributes.bottom_lid_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.slat_set_quantity") and len(attributes.slat_set_quantity)>#attributes.slat_set_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.engine_holder_quantity") and len(attributes.engine_holder_quantity)>#attributes.engine_holder_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.pipe_kit_quantity") and len(attributes.pipe_kit_quantity)>#attributes.pipe_kit_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.engine_adapter_quantity") and len(attributes.engine_adapter_quantity)>#attributes.engine_adapter_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.slat_end_quantity") and len(attributes.slat_end_quantity)>#attributes.slat_end_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.zip_holder_quantity") and len(attributes.zip_holder_quantity)>#attributes.zip_holder_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.roller_quantity") and len(attributes.roller_quantity)>#attributes.roller_quantity#<cfelse>NULL</cfif>,
            <cfif isdefined("attributes.engine_quantity") and len(attributes.engine_quantity)>#attributes.engine_quantity#<cfelse>NULL</cfif>,
            #session.ep.userid#,
            #now()#
        )
</cfquery>

<cfquery name="GET_COST_MATRIX_ALL" datasource="#DSN1#">
    SELECT TOP(1)
        COST_MATRIX_ID
    FROM
        COST_MATRIX
    ORDER BY
        COST_MATRIX_ID DESC
</cfquery>

<script type="text/javascript">
        window.location.href="<cfoutput>#request.self#?fuseaction=stock.form_upd_product_cost_matrix&event=det&cost_matrix_id=#GET_COST_MATRIX_ALL.COST_MATRIX_ID#</cfoutput>";
</script>