class ZCL_Z_DUMMY_ODATA_DPC_EXT definition
  public
  inheriting from ZCL_Z_DUMMY_ODATA_DPC
  create public .

public section.
protected section.

  methods DUMPSET_GET_ENTITYSET
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_Z_DUMMY_ODATA_DPC_EXT IMPLEMENTATION.


  method DUMPSET_GET_ENTITYSET.
**TRY.
*CALL METHOD SUPER->DUMPSET_GET_ENTITYSET
*  EXPORTING
*    IV_ENTITY_NAME           =
*    IV_ENTITY_SET_NAME       =
*    IV_SOURCE_NAME           =
*    IT_FILTER_SELECT_OPTIONS =
*    IS_PAGING                =
*    IT_KEY_TAB               =
*    IT_NAVIGATION_PATH       =
*    IT_ORDER                 =
*    IV_FILTER_STRING         =
*    IV_SEARCH_STRING         =
**    IO_TECH_REQUEST_CONTEXT  =
**  IMPORTING
**    ET_ENTITYSET             =
**    ES_RESPONSE_CONTEXT      =
*    .
** CATCH /IWBEP/CX_MGW_BUSI_EXCEPTION .
** CATCH /IWBEP/CX_MGW_TECH_EXCEPTION .
**ENDTRY.
     DATA: lt_dumpinfo TYPE rsdumptab,
          ls_dumpinfo LIKE LINE OF lt_dumpinfo,
          ls_entity   LIKE LINE OF et_entityset.
     CALL FUNCTION 'Z_DUMMY'            "DESTINATION 'SM1CLNT001'  "getting dumps from sm1
     IMPORTING
        et_dump_det = lt_dumpinfo.

*     CALL FUNCTION 'Z_DUMMY' DESTINATION 'SM1CLNT001'
*     IMPORTING
*        et_dump_det = lt_dumpinfo.

*Fill ET_ENTITYSET
    LOOP AT lt_dumpinfo INTO ls_dumpinfo .
      ls_entity-sydate    = ls_dumpinfo-sydate.
      ls_entity-sytime    = ls_dumpinfo-sytime.
      ls_entity-syhost    = ls_dumpinfo-syhost.
      ls_entity-syuser    = ls_dumpinfo-syuser.
      ls_entity-dumpid    = ls_dumpinfo-dumpid.
      ls_entity-programname  = ls_dumpinfo-programname.
      ls_entity-includename  = ls_dumpinfo-includename.
      ls_entity-linenumber   = ls_dumpinfo-linenumber.

      APPEND ls_entity TO et_entityset.
    ENDLOOP.


  endmethod.
ENDCLASS.
