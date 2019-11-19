*&---------------------------------------------------------------------*
*& Report Z_HANA_SIMPLIFICATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_HANA_SIMPLIFICATION.


TYPE-POOLS: truxs.

PARAMETERS: p_file TYPE  rlgrap-filename.
PARAMETERS: p_head TYPE char01 DEFAULT 'X'.

TYPES: BEGIN OF GTY_ZHANA_SIMPLE,
  recordid TYPE int4,
    MODULEAPPLICATION TYPE STRING,
    INDUSTRY          TYPE STRING,
    OLDTCODE          TYPE STRING,
    STATUS            TYPE STRING,
    REPLACEMENTTCODE  TYPE STRING,
    OSSNOTE           TYPE STRING,
    COMMENTS          TYPE STRING,
  END OF GTY_ZHANA_SIMPLE..
DATA:
      G_RAW_DATA      TYPE TRUXS_T_TEXT_DATA,
      GS_ZHANA_SIMPLE TYPE  ZHANA_SIMPLE,
      GT_ZHANA_SIMPLE TYPE TABLE OF ZHANA_SIMPLE.

* At selection screen
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      field_name = 'P_FILE'
    IMPORTING
      file_name  = p_file.

START-OF-SELECTION.
*  Convert Excel Data to SAP internal Table Data
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
*     I_FIELD_SEPERATOR        =
      i_line_header            =  p_head
      i_tab_raw_data           =  G_RAW_DATA       " WORK TABLE
      i_filename               =  p_file
    TABLES
      i_tab_converted_data     = GT_ZHANA_SIMPLE[]  "ACTUAL DATA
   EXCEPTIONS
      conversion_failed        = 1
      OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

***********************************************************************
* END-OF-SELECTION.
END-OF-SELECTION.

  LOOP AT GT_ZHANA_SIMPLE INTO GS_ZHANA_SIMPLE.

    MODIFY ZHANA_SIMPLE FROM TABLE GT_ZHANA_SIMPLE.
*    WRITE:/ wa_datatab-sapid.


*    NOW compare SAPIDs from ZEMP ======> GRACREQPROVLOG (955 USERS)/USR02 (289) /


  ENDLOOP.
