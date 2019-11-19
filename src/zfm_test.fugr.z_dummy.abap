FUNCTION Z_DUMMY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(ET_DUMP_DET) TYPE  RSDUMPTAB
*"----------------------------------------------------------------------
CALL FUNCTION 'RS_ST22_GET_DUMPS'
 EXPORTING
   P_DAY              = SY-DATUM
 IMPORTING
   P_INFOTAB          = et_dump_det
 EXCEPTIONS
   NO_AUTHORITY       = 1
   OTHERS             = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

ENDFUNCTION.
