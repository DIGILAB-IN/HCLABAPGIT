*&---------------------------------------------------------------------*
*& Report ZHANA_SIMPLIFY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZHANA_SIMPLIFY.
TYPE-POOLS : TRUXS.

TYPES :
  BEGIN OF GTY_ZHANA_SIMPLE,
    recordid TYPE int4,
    MODULEAPPLICATION TYPE STRING,
    INDUSTRY          TYPE STRING,
    OLDTCODE          TYPE STRING,
    STATUS            TYPE STRING,
    REPLACEMENTTCODE  TYPE STRING,
    OSSNOTE           TYPE STRING,
    COMMENTS          TYPE STRING,
  END OF GTY_ZHANA_SIMPLE.

DATA :
  G_RAW_DATA      TYPE TRUXS_T_TEXT_DATA,
  GS_ZHANA_SIMPLE TYPE  ZHANA_SIMPLE,
  GT_ZHANA_SIMPLE TYPE TABLE OF ZHANA_SIMPLE.


SELECTION-SCREEN BEGIN OF BLOCK BLOCK-1 WITH FRAME TITLE TEXT-001.

PARAMETERS : PA_FILE LIKE RLGRAP-FILENAME DEFAULT 'C:\excel.xls'.
" or CFFILE-FILENAME

SELECTION-SCREEN END OF BLOCK BLOCK-1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR PA_FILE.

  PERFORM U_SELECTFILE USING PA_FILE.

START-OF-SELECTION.

  PERFORM U_UPLOADEXCELDATA.
  PERFORM U_DISPLAYINTERNALTABLEDATA.

END-OF-SELECTION.
*&---------------------------------------------------------------------*
*& Form U_SELECTFILE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PA_FILE
*&---------------------------------------------------------------------*
FORM U_SELECTFILE  USING    P_PA_FILE TYPE LOCALFILE.
  DATA :
    LV_SUBRC  LIKE SY-SUBRC,
    LT_IT_TAB TYPE FILETABLE.
  " Display File Open Dialog control/screen

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE     = 'Select Source Excel File'
      DEFAULT_FILENAME = '*.xls'
      MULTISELECTION   = ' '
    CHANGING
      FILE_TABLE       = LT_IT_TAB
      RC               = LV_SUBRC.

  " Write path on input area
  LOOP AT LT_IT_TAB INTO P_PA_FILE.
  ENDLOOP.

ENDFORM. " end of u_selectfile
*&---------------------------------------------------------------------*
*& Form U_UPLOADEXCELDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM U_UPLOADEXCELDATA .
  CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
    EXPORTING
      I_LINE_HEADER        = 'X'
      I_TAB_RAW_DATA       = G_RAW_DATA
      I_FILENAME           = PA_FILE
    TABLES
      I_TAB_CONVERTED_DATA = GT_ZHANA_SIMPLE[]
    EXCEPTIONS
      CONVERSION_FAILED    = 1
      OTHERS               = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM. "end of upload
*&---------------------------------------------------------------------*
*& Form U_DISPLAYINTERNALTABLEDATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM U_DISPLAYINTERNALTABLEDATA .
  WRITE : /
    'MODULEAPPLICATION' RIGHT-JUSTIFIED,
    13 'INDUSTRY',
    26 'OLDTCODE',
    36 'STATUS' RIGHT-JUSTIFIED,
    56 'REPLACEMENTTCODE' RIGHT-JUSTIFIED,
    66 'OSSNOTE' RIGHT-JUSTIFIED,
    72 'COMMENTS'.

  LOOP AT GT_ZHANA_SIMPLE INTO GS_ZHANA_SIMPLE.

    MODIFY ZHANA_SIMPLE FROM TABLE GT_ZHANA_SIMPLE.
*    WRITE : /
*     GS_ZHANA_SIMPLE-MODULEAPPLICATION RIGHT-JUSTIFIED,
*     GS_ZHANA_SIMPLE-INDUSTRY,
*     GS_ZHANA_SIMPLE-OLDTCODE,
*     GS_ZHANA_SIMPLE-STATUS RIGHT-JUSTIFIED,
*     GS_ZHANA_SIMPLE-REPLACEMENTTCODE RIGHT-JUSTIFIED,
*     GS_ZHANA_SIMPLE-OSSNOTE RIGHT-JUSTIFIED,
*     GS_ZHANA_SIMPLE-COMMENTS .

  ENDLOOP.
ENDFORM.
