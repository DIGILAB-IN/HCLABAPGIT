*&---------------------------------------------------------------------*
*& Report Z_HANA_SIMPLIFICATION1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_HANA_SIMPLIFICATION1.

TYPE-POOLS: TRUXS.

PARAMETERS: P_FILE TYPE  RLGRAP-FILENAME.
PARAMETERS: P_HEAD TYPE CHAR01 DEFAULT 'X'.

TYPES: BEGIN OF T_DATATAB,
         recordid TYPE zhana_simple-recordid,
         MODULEAPPLICATION TYPE ZHANA_SIMPLE-MODULEAPPLICATION,
         INDUSTRY          TYPE ZHANA_SIMPLE-INDUSTRY,
         OLDTCODE          TYPE ZHANA_SIMPLE-OLDTCODE,
         STATUS            TYPE ZHANA_SIMPLE-STATUS,
         REPLACEMENTTCODE  TYPE ZHANA_SIMPLE-REPLACEMENTTCODE,
         OSSNOTE           TYPE ZHANA_SIMPLE-OSSNOTE,
         COMMENTS          TYPE ZHANA_SIMPLE-COMMENTS,
       END OF T_DATATAB.
DATA: IT_DATATAB TYPE STANDARD TABLE OF ZHANA_SIMPLE,
      WA_DATATAB TYPE ZHANA_SIMPLE.

DATA: IT_RAW TYPE TRUXS_T_TEXT_DATA.

* At selection screen
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      FIELD_NAME = 'P_FILE'
    IMPORTING
      FILE_NAME  = P_FILE.


***********************************************************************
*START-OF-SELECTION.
START-OF-SELECTION.

  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_LINE_HEADER        = P_HEAD
      I_TAB_RAW_DATA       = IT_RAW       " WORK TABLE
      I_FILENAME           = P_FILE
    TABLES
      I_TAB_CONVERTED_DATA = IT_DATATAB[]    "ACTUAL DATA
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.

  IF SY-SUBRC <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 s.y-msgv4.
  ENDIF.


***********************************************************************
* END-OF-SELECTION.
END-OF-SELECTION.
  LOOP AT IT_DATATAB INTO WA_DATATAB.

    MODIFY ZHANA_SIMPLE FROM TABLE IT_DATATAB.
*    WRITE:/ wa_datatab-recordid,
*            wa_datatab-MODULEAPPLICATION,
*            wa_datatab-INDUSTRY,
*            wa_datatab-OLDTCODE,
*            wa_datatab-STATUS,
*            wa_datatab-REPLACEMENTTCODE,
*            wa_datatab-OSSNOTE,
*            wa_datatab-COMMENTS.
  ENDLOOP.

*  https://answers.sap.com/questions/4470016/program-to-upload-a-excel-file-into-z-table.html       ===link


******* Selection Screen
*PARAMETERS: p_file  TYPE rlgrap-filename OBLIGATORY. "To enter file name.
*
*TYPES: BEGIN OF ty_hana,
*    MODULEAPPLICATION TYPE ZHANA_SIMPLE-MODULEAPPLICATION,
*    INDUSTRY          TYPE ZHANA_SIMPLE-industry,
*    OLDTCODE          TYPE ZHANA_SIMPLE-oldtcode,
*    STATUS            TYPE zhana_simple-status,
*    REPLACEMENTTCODE  TYPE zhana_simple-replacementtcode,
*    OSSNOTE           TYPE zhana_simple-ossnote,
*    COMMENTS          TYPE zhana_simple-comments,
*END OF ty_hana.
*
*DATA: lt_type  TYPE truxs_t_text_data,
*lt_excel TYPE TABLE OF ty_hana,
*ls_excel TYPE ty_hana.
*
*DATA: lt_excel_temp TYPE STANDARD TABLE OF zhana_simple,
*ls_excel_temp LIKE LINE OF lt_excel_temp.
*TYPES: ZCL_EXCEL_UPLOAD TYPE zcl_hp_excel_upload.
*
*DATA: lr_excel TYPE REF TO zcl_excel_upload.
*
******* F4 help for fetching excel file
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
*
*zcl_hp_excel_upload = >filename_f4_help(
*IMPORTING
*ev_filename  = p_file
*).
*
*START-OF-SELECTION.
*
*CREATE OBJECT lr_excel.
******* Populating internal table using excel sheet data
*lr_excel->upload_excel(
*EXPORTING
*it_type   = lt_type
*iv_file   = p_file
*IMPORTING
*et_upload = lt_excel
*).
*
*END-OF-SELECTION.
*
*DELETE lt_excel INDEX 1. " delete header of excel sheet
*MOVE-CORRESPONDING lt_excel TO lt_excel_temp.
*
******* Update database table
*IF lt_excel_temp IS NOT INITIAL.
*MODIFY zhana_simple FROM TABLE lt_excel_temp.
*
*IF sy-subrc EQ 0.
***Create a message in SE91, that the db table is updated successfully.
*MESSAGE i000(zhp_messages).
*ENDIF.
*ENDIF.
*
**https://inkyourcode.com/upload-excel-local-system-sap-table-using-abap/               ===link
