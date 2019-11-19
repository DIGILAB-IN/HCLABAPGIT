FUNCTION Z_JOBLOG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EV_JOBLIST_SEL_JOB) TYPE  TBTCJOB
*"  TABLES
*"      ZJOBLIST STRUCTURE  TBTCJOB
*"----------------------------------------------------------------------
CALL FUNCTION 'BP_JOBLIST_PROCESSOR_SM37B'
*  EXPORTING
*    JOBLIST_OPCODE                   =
*   JOBLIST_REFR_PARAM               = ' '
*   EXIT_AT_REFRESH                  = ' '
 IMPORTING
   JOBLIST_SEL_JOB                  = EV_JOBLIST_SEL_JOB
*  TABLES
*    JOBLIST                          = ZJOBLIST
* EXCEPTIONS
*   INVALID_OPCODE                   = 1
*   JOBLIST_IS_EMPTY                 = 2
*   JOBLIST_PROCESSOR_CANCELED       = 3
*   REFRESH_LIST_REQUIRED            = 4
*   OTHERS                           = 5
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.





ENDFUNCTION.
