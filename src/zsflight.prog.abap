*&---------------------------------------------------------------------*
*& Report Z_HANA_SIMPLIFICATION2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSFLIGHT.
CLASS lcl_report DEFINITION.
*
  PUBLIC SECTION.
*
    DATA: t_data   TYPE STANDARD TABLE OF sflight,  " Output dat
          r_carrid TYPE RANGE OF sflight-carrid.    " Select Option
*
    METHODS:
      get_data,
*
      generate_output.
*
ENDCLASS.                    "lcl_report DEFINITION
*
DATA: lo_report TYPE REF TO lcl_report.
*
DATA: w_carrid TYPE sflight-carrid.
*
** Selection Screen
SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE aaa.
SELECT-OPTIONS: s_carrid FOR w_carrid.
SELECTION-SCREEN: END   OF BLOCK blk1.
*
** Initialization
INITIALIZATION.
  aaa = 'Selection Criteria'.
* object for the report
  CREATE OBJECT lo_report.
* generate output
  lo_report->generate_output( ).
*
** Start of Selection
START-OF-SELECTION.
* Get data
  lo_report->r_carrid = s_carrid[].
  lo_report->get_data( ).
*
*----------------------------------------------------------------------*
* Local Class Implementation
*----------------------------------------------------------------------*
CLASS lcl_report IMPLEMENTATION.
*
  METHOD get_data.
*
*   data selection
    SELECT * FROM sflight
           INTO  TABLE me->t_data
           WHERE carrid IN s_carrid.
    IF sy-dbcnt IS INITIAL.
      MESSAGE s398(00) WITH 'No data selected'.
    ENDIF.
*
*   export to memory
    EXPORT data = me->t_data TO MEMORY ID sy-cprog.
*
  ENDMETHOD.                    "get_data
*
  METHOD generate_output.
*
*   local data
    DATA: lo_dock TYPE REF TO cl_gui_docking_container,
          lo_cont TYPE REF TO cl_gui_container,
          lo_alv  TYPE REF TO cl_salv_table.
*
*   import output table from the memory and free afterwards
    IMPORT data = me->t_data FROM MEMORY ID sy-cprog.
    FREE MEMORY ID sy-cprog.
*
*   Only if there is some data
    CHECK me->t_data IS NOT INITIAL.
*
*   Create a docking control at bottom
    CHECK lo_dock IS INITIAL.
    CREATE OBJECT lo_dock
      EXPORTING
        repid = sy-cprog
        dynnr = sy-dynnr
        ratio = 80
        side  = cl_gui_docking_container=>dock_at_bottom
        name  = 'DOCK_CONT'.
    IF sy-subrc <> 0.
      MESSAGE 'Error in the Docking control' TYPE 'S'.
    ENDIF.
*
*   Create a SALV for output
    CHECK lo_alv IS INITIAL.
    TRY.
*       Narrow Casting: To initialize custom container from
*       docking container
        lo_cont ?= lo_dock.
*
*       SALV Table Display on the Docking container
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display   = if_salv_c_bool_sap=>false
            r_container    = lo_cont
            container_name = 'DOCK_CONT'
          IMPORTING
            r_salv_table   = lo_alv
          CHANGING
            t_table        = me->t_data.
      CATCH cx_salv_msg .
    ENDTRY.
*
*   Pf status
    DATA: lo_functions TYPE REF TO cl_salv_functions_list.
    lo_functions = lo_alv->get_functions( ).
    lo_functions->set_default( abap_true ).
*
*   output display
    lo_alv->display( ).
*
  ENDMETHOD.                    "generate_output
*
ENDCLASS.                    "lcl_report IMPLEMENTATION
