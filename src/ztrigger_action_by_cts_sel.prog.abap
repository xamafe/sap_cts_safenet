*&---------------------------------------------------------------------*
*& Include ztrigger_action_by_cts_sel
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK in WITH FRAME.
  SELECT-OPTIONS sel_reps FOR <reposrc>-programm.
  PARAMETERS w_incls AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK in.

SELECTION-SCREEN BEGIN OF BLOCK out WITH FRAME.

  PARAMETERS:
    dump     AS CHECKBOX DEFAULT 'X',
    sys_evnt AS CHECKBOX,
    event    TYPE btceventid.

SELECTION-SCREEN END OF BLOCK out.
