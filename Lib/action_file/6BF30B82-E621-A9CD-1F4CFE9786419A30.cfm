<cfinclude template="../../V16/add_options/bank/query/add_debit_claim_note_1.cfm">

<!---
    Desc : Kredi Kartı Tahsilatı sonrası bilgilendirme mail ve SMS gönderilmesi için eklendi.
    Dev : Yunus Emre Yazıcı
    Date : 23.02.2022
--->

<cfif isDefined("attributes.action_id") and len (attributes.action_id)>

    <cfquery name="GET_CARD_PAYMENT" datasource="#caller.DSN3#">
       SELECT
          CC.OTHER_CASH_ACT_VALUE,
          CC.OTHER_MONEY,
          CC.ACTION_CURRENCY_ID,
          CC.ACTION_FROM_COMPANY_ID,
          CC.PARTNER_ID,
          CC.ACTION_TYPE,
          CC.RECORD_DATE,
          CC.PAPER_NO,
          CC.UPDATE_EMP,
          C.FULLNAME,
          C.COMPANY_ADDRESS,
          C.COMPANY_EMAIL,
          EP.EMPLOYEE_EMAIL AS TEMSILCI_MAIL,
          C.POS_CODE
       FROM
          CREDIT_CARD_BANK_PAYMENTS CC
          LEFT JOIN #caller.DSN#.COMPANY C ON C.COMPANY_ID = CC.ACTION_FROM_COMPANY_ID
          LEFT JOIN #caller.DSN#.WORKGROUP_EMP_PAR WEP ON WEP.COMPANY_ID = C.COMPANY_ID
          LEFT JOIN #caller.DSN#.EMPLOYEE_POSITIONS EP ON EP.POSITION_ID = WEP.POSITION_CODE
       WHERE
          CREDITCARD_PAYMENT_ID = #attributes.action_id#
          AND WEP.IS_MASTER = 1
    </cfquery>
 
    <cfquery name="GET_COMPANY_MANAGER" datasource="#caller.DSN3#">
       SELECT
          C.MANAGER_PARTNER_ID,
          CP.COMPANY_PARTNER_TELCODE,
          CP.COMPANY_PARTNER_TEL,
          CP.MOBIL_CODE,
          CP.MOBILTEL
       FROM
          #caller.DSN#.COMPANY C
          LEFT JOIN #caller.DSN#.COMPANY_PARTNER CP ON CP.PARTNER_ID = C.MANAGER_PARTNER_ID
       WHERE
          C.COMPANY_ID = #GET_CARD_PAYMENT.ACTION_FROM_COMPANY_ID#
    </cfquery>
 
    <cfquery name="GET_COMP_ADDR" datasource="#caller.DSN3#">
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
    --->
    <cfset to_mail="#GET_CARD_PAYMENT.TEMSILCI_MAIL#">
    <cfset subject_mail='BİRİKİM PİLLERİ KREDİ KARTI TAHSİLAT'>
    
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
                     <P>#GET_CARD_PAYMENT.TEMSILCI_MAIL#</P>
                  </td>
               </tr>
               <tr>
                  <p>
                     <strong>#GET_CARD_PAYMENT.FULLNAME#</strong> hesabından <strong>#caller.TLFormat(GET_CARD_PAYMENT.OTHER_CASH_ACT_VALUE,2)# #GET_CARD_PAYMENT.OTHER_MONEY#</strong> tutarında #GET_CARD_PAYMENT.ACTION_TYPE# yapılmıştır.
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
 
    <!---
    <cfset attributes.tel_no = "05453458594">
    <cfset attributes.tel_no = "#GET_COMPANY_MANAGER.MOBILTEL#">
    --->
    <cfif len(GET_COMPANY_MANAGER.MOBILTEL)>
        <cfset attributes.tel_no = "#GET_COMPANY_MANAGER.MOBILTEL#">
        <cfset attributes.message_body = "#GET_CARD_PAYMENT.FULLNAME# Hesabına Mahsuben Yalnız #caller.TLFormat(GET_CARD_PAYMENT.OTHER_CASH_ACT_VALUE,2)# #GET_CARD_PAYMENT.OTHER_MONEY# tahsil edilmiştir." >
        <cfinclude template="send_sms_action.cfm">
    </cfif>

    <!--- kurumsal hesap kontak kişisine SMS atmak için eklenmiştir. --->

        <cfset attributes.company_id = GET_CARD_PAYMENT.ACTION_FROM_COMPANY_ID>
        <cfif len(GET_COMPANY_MANAGER.MANAGER_PARTNER_ID)>
            <cfset attributes.partner_id = GET_COMPANY_MANAGER.MANAGER_PARTNER_ID>
        </cfif>
        <cfset attributes.applicant_name = '#GET_CARD_PAYMENT.FULLNAME#'>
        <cfset attributes.applicant_mail = '#GET_CARD_PAYMENT.COMPANY_EMAIL#'>
        <cfset attributes.customer_telno = '#GET_COMPANY_MANAGER.MOBILTEL#'>
        <cfset attributes.customer_telcode = '#GET_COMPANY_MANAGER.MOBIL_CODE#'>
        <cfset attributes.detail = 'TAHSİLAT - #GET_CARD_PAYMENT.PAPER_NO#'>
        <cfset attributes.subject = '#GET_CARD_PAYMENT.FULLNAME# Hesabına Mahsuben Yalnız #caller.TLFormat(GET_CARD_PAYMENT.OTHER_CASH_ACT_VALUE,2)# #GET_CARD_PAYMENT.OTHER_MONEY# tahsil edilmiştir.'>
        <cfset attributes.member_type = 'partner'>
        <cfset attributes.app_cat = 4> <!--- iletişim yöntemi (SMS için) --->
        <cfset attributes.interaction_cat = 7>
    
        <cfinclude template="../../V16/callcenter/query/add_helpdesk_birikim.cfm">
 </cfif>