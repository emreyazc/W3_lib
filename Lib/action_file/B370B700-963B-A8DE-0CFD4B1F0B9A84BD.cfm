<!---
    Date : 16.03.2022
    Desc : GELEN HAVALE olduğunda ilgili pazarlamacıya Mail, müşteriye SMS ile bilgilendirme yapar.
    Dev  : Yunus Emre Yazıcı - Birikim Pilleri
--->

<cfif isDefined("attributes.action_id") and len(attributes.action_id)>
    <cfquery name="GET_INFO" datasource="#caller.DSN2#">
        SELECT
            BA.ACTION_TYPE,
            BA.OTHER_CASH_ACT_VALUE,
            BA.OTHER_MONEY,
            C.FULLNAME,
            CP.COMPANY_PARTNER_NAME+' '+CP.COMPANY_PARTNER_SURNAME AS PARTNER_NAME,
            CP.MOBILTEL,
            CP.IS_SEND_FINANCE_MAIL,
            EP.EMPLOYEE_NAME+' '+EP.EMPLOYEE_SURNAME AS TEMSILCI,
            EP.EMPLOYEE_EMAIL AS TEMSILCI_MAIL
        FROM	
            BANK_ACTIONS BA
            LEFT JOIN #caller.DSN#.COMPANY C ON C.COMPANY_ID = BA.ACTION_FROM_COMPANY_ID
            LEFT JOIN #caller.DSN#.COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
            LEFT JOIN #caller.DSN#.WORKGROUP_EMP_PAR WEP ON WEP.COMPANY_ID = BA.ACTION_FROM_COMPANY_ID
            LEFT JOIN #caller.DSN#.EMPLOYEE_POSITIONS EP ON EP.POSITION_ID = WEP.POSITION_CODE
        WHERE
            BA.ACTION_ID = #attributes.action_id#
    </cfquery>

    <cfquery name="GET_COMP_ADDR" datasource="#caller.DSN2#">
        SELECT COMPANY_NAME,ADDRESS,TEL_CODE,TEL,FAX,WEB,ASSET_FILE_NAME2 FROM #caller.DSN#.OUR_COMPANY WHERE COMP_ID = #session.ep.company_id#
    </cfquery>

    <cfif len(get_comp_addr.ASSET_FILE_NAME2)>
        <cfset attributes.mail_logo = "documents/settings/"&get_comp_addr.asset_file_name2>
    <cfelse>
        <cfset attributes.mail_logo = "documents/templates/info_mail/logobig.gif">
    </cfif>
    
    <cfset from_mail='#session.ep.company#<#session.ep.company_email#>'>
    <!---
    <cfset to_mail="yunusemreyazici@birikimpilleri.com">
    <cfset to_mail="#GET_INFO.TEMSILCI_MAIL#">
    --->
    <cfset to_mail="#GET_INFO.TEMSILCI_MAIL#">
    <cfset subject_mail='BİRİKİM PİLLERİ - GELEN HAVALE'>

    <cfif len(to_mail)>
        <cfmail from="#from_mail#" to="#to_mail#" subject="#subject_mail#" type="html" charset="utf-8">
            <html>
                <table cellpadding="0" cellspacing="0" align="center" width="800">
                   <tr>
                      <td align="center"><img border="0" src="https://erp.birikimpilleri.com:443/#attributes.mail_logo#"/></td>
                      <!---
                      <td align="center"><img border="0" src="#caller.user_domain#/#attributes.mail_logo#"/></td>
                      --->
                   </tr>
                   <tr align="center">
                      <td style="text-align:left">
                         <p>Tebrikler,</p>
                         <P>#GET_INFO.TEMSILCI#</P>
                      </td>
                   </tr>
                   <tr>
                      <p>
                         Temsilcisi olduğunuz <strong>#GET_INFO.FULLNAME#</strong> hesabından <strong>#caller.TLFormat(GET_INFO.OTHER_CASH_ACT_VALUE,2)# #GET_INFO.OTHER_MONEY#</strong> tutarında <b>HAVALE</b> yapılmıştır.
                      </p>
                   </tr>
                   <tr>
                      <p>
                         Teşekkür ederiz.
                      </p>
                   </tr>
                   <tr align="right">
                      <p>
                         <strong>Muhasebe Departmanı</strong>
                      </p>
                   </tr>
                   <tr>
                      <td align="right"></td>
                  </tr>
                  <cfif get_comp_addr.recordcount>
                      <tr>
                          <td><br/><br></td>
                          <td><br/><br></td>
                      </tr>
                      <tr>
                          <td class="unbold" style="font-size:12px;">
                          #get_comp_addr.company_name#<br>
                          #get_comp_addr.address#<br>
                          <cf_get_lang_main no="87.Tel">: #get_comp_addr.tel_code# #get_comp_addr.tel# <cf_get_lang_main no="76.Fax">: #get_comp_addr.tel_code# #get_comp_addr.fax#<br>
                          <a href="mailto:#get_comp_addr.web#">#get_comp_addr.web#</a>
                          </td>
                      </tr>
                  </cfif>
              </table>
                </table>
             </html>
        </cfmail>
    </cfif>

    <!--- kurumsal hesap kontak kişisine SMS atmak için eklenmiştir. --->
    <cfif GET_INFO.IS_SEND_FINANCE_MAIL eq 0>
        <cfif len(GET_INFO.MOBILTEL)>
            <cfset attributes.tel_no = "#GET_INFO.MOBILTEL#"> <!--- cari yetkilisi tel_no --->
            <cfset attributes.message_body = "Değerli Müşterimiz #GET_INFO.FULLNAME# hesabınızdan #caller.TLFormat(GET_INFO.OTHER_CASH_ACT_VALUE,2)# #GET_INFO.OTHER_MONEY# tutarında HAVALE tarafımıza ulaşmıştır." >
            <cfinclude template="send_sms_action.cfm">
        </cfif>
    </cfif>

</cfif>