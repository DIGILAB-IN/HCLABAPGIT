*&---------------------------------------------------------------------*
*& Report Z_HANA_SIMPLIFICATION2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_HANA_SIMPLIFICATION2.
*       CLASS lcl_report DEFINITION
*----------------------------------------------------------------------*
CLASS LCL_REPORT DEFINITION.

  PUBLIC SECTION.

*   Final output table
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
     TYPES: BEGIN OF T_AGR_TCODES,
            AGR_NAME TYPE AGR_NAME,
            END OF T_AGR_TCODES.


    DATA: IT_DATATAB TYPE STANDARD TABLE Of t_datatab,
*          IT_DATATAB TYPE STANDARD TABLE OF T_DATATAB INITIAL SIZE 0,
          IT_AGRTAB1 TYPE STANDARD TABLE OF T_AGR_TCODES.

*   ALV reference
    DATA: O_ALV TYPE REF TO CL_SALV_TABLE.

    METHODS:
*     data selection
      GET_DATA,
*     Generating output
      GENERATE_OUTPUT.

ENDCLASS.                    "lcl_report DEFINITION
*
START-OF-SELECTION.
  DATA: LO_REPORT TYPE REF TO LCL_REPORT.

  CREATE OBJECT LO_REPORT.

  LO_REPORT->GET_DATA( ).
  LO_REPORT->GENERATE_OUTPUT( ).
*
*----------------------------------------------------------------------*
*       CLASS lcl_report IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS LCL_REPORT IMPLEMENTATION.

  METHOD GET_DATA.
*   data selection

    SELECT tcode
      into table @DATA(IT_AGRTAB1)
       FROM AGR_TCODES .



*  SELECT recordid MODULEAPPLICATION INDUSTRY OLDTCODE STATUS REPLACEMENTTCODE OSSNOTE COMMENTS
*        from ZHANA_SIMPLE
*        INTO  TABLE IT_DATATAB
*        where ( STATUS = 'Obsolete' OR STATUS = 'Replaced') ."AND OLDTCODE <> IT_AGRTAB1~TCODE.

    SELECT a~recordid a~MODULEAPPLICATION a~INDUSTRY a~OLDTCODE a~STATUS a~REPLACEMENTTCODE a~OSSNOTE a~COMMENTS
        from ZHANA_SIMPLE AS a INNER JOIN AGR_TCODES AS b
        ON b~tcode = a~OLDTCODE
           INTO  TABLE IT_DATATAB.
           "UP TO 9999 ROWS.
  ENDMETHOD.                    "get_data

*.......................................................................
  METHOD GENERATE_OUTPUT.
* New ALV instance
*   We are calling the static Factory method which will give back
*   the ALV object reference.
* exception class
    DATA: LX_MSG TYPE REF TO CX_SALV_MSG.
    DATA column TYPE REF TO cl_salv_column.
         column = O_alv->get_columns( )->get_column( 'recordid' ).
         column->set_short_text( 'RecordID' ).
    TRY.
        CL_SALV_TABLE=>FACTORY(
          IMPORTING
            R_SALV_TABLE = O_ALV
          CHANGING
            T_TABLE      = IT_DATATAB ).
      CATCH CX_SALV_MSG INTO LX_MSG.
    ENDTRY.
    O_ALV->DISPLAY( ).


  ENDMETHOD.                    "generate_output

ENDCLASS.                    "lcl_report IMPLEMENTATION
