*&---------------------------------------------------------------------*
*& Report ztrigger_action_by_cts
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztrigger_action_by_cts.

INCLUDE ztrigger_action_by_cts_cls.
INCLUDE ztrigger_action_by_cts_top.
INCLUDE ztrigger_action_by_cts_sel.

START-OF-SELECTION.
  DATA(trigger) = trigger_action=>create( programs = sel_reps[]
                                          search_for_includes = w_incls ).
  IF trigger->relevant_transports_running( ) = abap_false.
    WRITE: 'Nothing to do, Goodbye'.
    EXIT.
  ENDIF.
  trigger->call_action( do_crash = dump
                        do_event_call = sys_evnt
                        event_to_call = event ).
