FUNCTION Z_SEND_OTF_EMAIL_PDF3.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(JOB_OUTPUT_INFO) TYPE  SSFCRESCL
*"     REFERENCE(SENDER) TYPE  SYUNAME OPTIONAL
*"     REFERENCE(SENDER_ADDR) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(RECIPIENT) TYPE  SYUNAME
*"     REFERENCE(RECIPIENT_ADDR) TYPE  AD_SMTPADR OPTIONAL
*"     REFERENCE(DOC_NAME) TYPE  CHAR50
*"     REFERENCE(EMAIL_SUBJECT) TYPE  CHAR50 OPTIONAL
*"     REFERENCE(I_SEND_IMMEDIATELY) TYPE  XFELD OPTIONAL
*"     REFERENCE(I_EXPRESS) TYPE  XFELD OPTIONAL
*"     REFERENCE(I_COPY) TYPE  XFELD OPTIONAL
*"  TABLES
*"      IT_RECIPIENTS TYPE  BCSY_SMTPA OPTIONAL
*"      EMAIL_BODY STRUCTURE  SOLISTI1 OPTIONAL
*"      IT_COPYTO TYPE  BCSY_SMTPA OPTIONAL
*"      IT_BCOPYTO TYPE  BCSY_SMTPA OPTIONAL
*"  EXCEPTIONS
*"      ERROR_SENDING_EMAIL
*"      ERROR_CONVERTING_OTF_DATA
*"----------------------------------------------------------------------

  DATA: l_send_request TYPE REF TO cl_bcs,         " Send request
        l_body          TYPE bcsy_text,                " Mail body
        l_document      TYPE REF TO cl_document_bcs,   " Mail
        l_sender        TYPE REF TO if_sender_bcs,     " Sender address
        l_recipient     TYPE REF TO if_recipient_bcs,  " Recipient
        l_email         TYPE ad_smtpadr,               " Email ID
        l_extension     TYPE soodk-objtp VALUE 'PDF',  " PDF format
        lt_pdf_content  TYPE solix_tab,
        l_pdf_size      TYPE so_obj_len,               " Size of PDF in Xstring
        l_pdf_xstring   TYPE xstring,                  " PDF in Xstring
        l_len_in        LIKE sood-objlen,              "Size of PDF in binary
        lt_tline        TYPE TABLE OF tline WITH HEADER LINE. "Bianry file of PDF

  DATA: bcs_exception      TYPE REF TO cx_bcs.
  FIELD-SYMBOLS <ls_recipients> TYPE ad_smtpadr.

* Attachment for otf records
* Convert OTF flow into PDF
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
      max_linewidth         = 132
    IMPORTING
      bin_filesize          = l_len_in
      bin_file              = l_pdf_xstring
    TABLES
      otf                   = job_output_info-otfdata
      lines                 = lt_tline
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.
  IF sy-subrc <> 0.
    RAISE error_converting_otf_data.
  ENDIF.

  l_pdf_size = xstrlen( l_pdf_xstring ).
  lt_pdf_content = cl_document_bcs=>xstring_to_solix( ip_xstring = l_pdf_xstring ).

  TRY.
* Create persistent send request
      l_send_request = cl_bcs=>create_persistent( ).

* Create document for mail body
      LOOP AT email_body.
        APPEND email_body-line TO l_body.
      ENDLOOP.

      l_document = cl_document_bcs=>create_document(
                   i_type    = 'RAW'
                   i_text    = l_body  " Mail body
                   i_subject = email_subject ).

* Add attchment
      CALL METHOD l_document->add_attachment
        EXPORTING
          i_attachment_type    = l_extension
          i_attachment_subject = doc_name
          i_attachment_size    = l_pdf_size
          i_att_content_hex    = lt_pdf_content.     " Attachment for success record

*   add document to send request
      l_send_request->set_document( l_document ).

* Sender address
      IF sender_addr IS NOT INITIAL.
        l_email = sender_addr.
        l_sender = cl_cam_address_bcs=>create_internet_address( l_email ).
      ELSEIF sender IS NOT INITIAL.
        l_sender = cl_sapuser_bcs=>create( sender ).
      ELSE.
        l_sender = cl_sapuser_bcs=>create( sy-uname ).
      ENDIF.

      CALL METHOD l_send_request->set_sender
        EXPORTING
          i_sender = l_sender.

* Recipient address
*---Checks if we have multiple recipient mail-ids or not
      IF it_recipients[] IS INITIAL.
        IF recipient_addr IS NOT INITIAL.
          l_email = recipient_addr.

        ELSEIF recipient IS NOT INITIAL.
          CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
            EXPORTING
              i_uname           = recipient
            IMPORTING
              e_email_address   = l_email
            EXCEPTIONS
              not_qualified     = 1
              user_not_found    = 2
              address_not_found = 3
              OTHERS            = 4.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ELSE.
          CALL FUNCTION 'EFG_GEN_GET_USER_EMAIL'
            EXPORTING
              i_uname           = sy-uname
            IMPORTING
              e_email_address   = l_email
            EXCEPTIONS
              not_qualified     = 1
              user_not_found    = 2
              address_not_found = 3
              OTHERS            = 4.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.
        ENDIF.
        l_recipient = cl_cam_address_bcs=>create_internet_address( l_email ).

*
*** do not have the delivered copy
        l_send_request->set_status_attributes( i_requested_status = 'N'  ).

* Add recipient address to send request
        CALL METHOD l_send_request->add_recipient
          EXPORTING
            i_recipient  = l_recipient
            i_express    = i_express
            i_copy       = i_copy
            i_blind_copy = ' '
            i_no_forward = ' '.
      ELSE.
*---Generating the list of multiple recipients to whom the mail will be sent
        LOOP AT it_recipients ASSIGNING <ls_recipients>.
          l_recipient = cl_cam_address_bcs=>create_internet_address( <ls_recipients> ).
*-----Setting the Attribute for never sending status mail
          l_send_request->set_status_attributes( i_requested_status = 'N').
*-----Adds the recipient instance
          CALL METHOD l_send_request->add_recipient
            EXPORTING
              i_recipient  = l_recipient
              i_express    = i_express
              i_copy       = i_copy
              i_blind_copy = ' '
              i_no_forward = ' '.
        ENDLOOP.
*---Checking if we hvae a single user or not to send the mail to
        IF recipient_addr IS NOT INITIAL.         " Recipient Address is provided
          l_recipient = cl_cam_address_bcs=>create_internet_address( recipient_addr ).
*-----Setting the Attribute for never sending status mail
          l_send_request->set_status_attributes( i_requested_status = 'N'  ).
*-----Adds the recipient instance
          CALL METHOD l_send_request->add_recipient
            EXPORTING
              i_recipient  = l_recipient
              i_express    = i_express
              i_copy       = space
              i_blind_copy = ' '
              i_no_forward = ' '.
        ENDIF.
      ENDIF.

*---Checks if we have Copy to mail-ids or not
      IF it_copyto[] IS NOT INITIAL.
*---Generating the list of multiple Copy To to whom the mail will be sent
        LOOP AT it_copyto ASSIGNING FIELD-SYMBOL(<ls_copyto>).
          DATA(l_copyto) = cl_cam_address_bcs=>create_internet_address( <ls_copyto> ).
*-----Setting the Attribute for never sending status mail
          l_send_request->set_status_attributes( i_requested_status = 'N').
*-----Adds the Copy To instance
          CALL METHOD l_send_request->add_recipient
            EXPORTING
              i_recipient  = l_copyto
              i_express    = i_express
              i_copy       = abap_true
              i_blind_copy = ' '
              i_no_forward = ' '.
        ENDLOOP.
      ENDIF.

*---Checks if we have Blind Copy to mail-ids or not
      IF it_bcopyto[] IS NOT INITIAL.
*---Generating the list of multiple Copy To to whom the mail will be sent
        LOOP AT it_bcopyto ASSIGNING FIELD-SYMBOL(<ls_bcopyto>).
          DATA(l_bcopyto) = cl_cam_address_bcs=>create_internet_address( <ls_bcopyto> ).
*-----Setting the Attribute for never sending status mail
          l_send_request->set_status_attributes( i_requested_status = 'N').
*-----Adds the Copy To instance
          CALL METHOD l_send_request->add_recipient
            EXPORTING
              i_recipient  = l_bcopyto
              i_express    = i_express
              i_copy       = ' '
              i_blind_copy = abap_true
              i_no_forward = ' '.
        ENDLOOP.
      ENDIF.

      IF i_send_immediately = 'X'.
        l_send_request->set_send_immediately( 'X' ).
      ENDIF.

* Send mail
      CALL METHOD l_send_request->send( ).

    CATCH cx_bcs INTO bcs_exception.
      RAISE error_sending_email.
      EXIT.
  ENDTRY.


ENDFUNCTION.
