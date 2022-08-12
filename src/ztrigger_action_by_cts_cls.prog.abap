*&---------------------------------------------------------------------*
*& Include ztrigger_action_by_cts_cls
*&---------------------------------------------------------------------*

CLASS trigger_action DEFINITION CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES ty_program_selection TYPE RANGE OF programm.
    "! creates a new instance and sets selection parameters
    "! @parameter programs |
    "! @parameter search_for_includes |
    "! @parameter result |
    CLASS-METHODS create
      IMPORTING
        programs            TYPE table
        search_for_includes TYPE abap_bool
      RETURNING
        VALUE(result)       TYPE REF TO trigger_action.
    METHODS constructor
      IMPORTING
        programs            TYPE table
        search_for_includes TYPE abap_bool.
    METHODS call_action
      IMPORTING
        do_crash      TYPE abap_bool
        do_event_call TYPE abap_bool
        event_to_call TYPE btceventid.
    "! Checks if transports are running, that contain one of the given programs
    "! @parameter result |
    METHODS relevant_transports_running
      RETURNING VALUE(result) TYPE abap_bool.
    METHODS: get_program_selection RETURNING VALUE(r_result) TYPE ty_program_selection,
      set_program_selection IMPORTING program_selection TYPE ty_program_selection,
      get_program_search_w_includes RETURNING VALUE(r_result) TYPE abap_bool,
      set_search_for_program_include IMPORTING search_for_program_includes TYPE abap_bool.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA program_selection TYPE RANGE OF programm.
    DATA search_for_program_includes TYPE abap_bool.
ENDCLASS.

CLASS trigger_action IMPLEMENTATION.

  METHOD constructor.
    set_program_selection( programs ).
    set_search_for_program_include( search_for_includes ).
  ENDMETHOD.


  METHOD create.
    result = NEW #( programs = programs
                    search_for_includes = search_for_includes ).
  ENDMETHOD.


  METHOD call_action.

    IF do_event_call = abap_true.
      cl_batch_event=>raise(
        EXPORTING
          i_eventid                      = event_to_call
        EXCEPTIONS
          excpt_raise_failed             = 1
          excpt_server_accepts_no_events = 2
          excpt_raise_forbidden          = 3
          excpt_unknown_event            = 4
          excpt_no_authority             = 5
          OTHERS                         = 6
      ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.

*   for obvious reasons this has to be the last call... :-D
    IF do_crash = abap_true.
      MESSAGE x398(00) WITH 'one of the reports were found in transports'.
    ENDIF.

  ENDMETHOD.

  METHOD get_program_selection.
    r_result = me->program_selection.
  ENDMETHOD.

  METHOD set_program_selection.
    me->program_selection = program_selection.
  ENDMETHOD.

  METHOD get_program_search_w_includes.
    r_result = me->search_for_program_includes.
  ENDMETHOD.

  METHOD set_search_for_program_include.
    me->search_for_program_includes = search_for_program_includes.
  ENDMETHOD.

  METHOD relevant_transports_running.
    result = abap_false.
    DATA(active_transports) = NEW zcl_active_transports( ).
    active_transports->set_program_selection( programs = get_program_selection( )
                                              w_includes = get_program_search_w_includes( )
                                            ).

    IF lines( active_transports->get_running_transports( ) ) > 0.
      result = abap_true.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
