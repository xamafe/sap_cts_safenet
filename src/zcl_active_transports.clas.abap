CLASS zcl_active_transports DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES program_selection TYPE RANGE OF programm.
    TYPES: BEGIN OF transport_object,
             pgmid    TYPE pgmid,
             object   TYPE trobjtype,
             obj_name TYPE trobj_name,
           END OF Transport_object,
           transport_objects TYPE STANDARD TABLE OF transport_object WITH DEFAULT KEY.
    METHODS set_program_selection
      IMPORTING programs   TYPE program_selection
                w_includes TYPE abap_bool.
    METHODS get_running_transports
      RETURNING
        VALUE(r_result) TYPE trkorrs.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS r3tr TYPE pgmid VALUE 'R3TR' ##NO_TEXT.
    CONSTANTS prog TYPE trobjtype VALUE 'PROG' ##NO_TEXT.
    CONSTANTS limu TYPE pgmid VALUE 'LIMU' ##NO_TEXT.
    CONSTANTS reps TYPE trobjtype VALUE 'REPS' ##NO_TEXT.
    DATA searched_objects TYPE transport_objects.
    METHODS add_includes_to_programs
      CHANGING
        program_entries TYPE transport_objects.
ENDCLASS.



CLASS ZCL_ACTIVE_TRANSPORTS IMPLEMENTATION.


  METHOD add_includes_to_programs.
    DATA includes TYPE STANDARD TABLE OF programm.
    data report_id TYPE sy-repid.
    LOOP AT program_entries REFERENCE INTO DATA(program_entry) WHERE pgmid = r3tr AND object = prog.
      FREE includes.
      report_id = program_entry->obj_name.
*     This FM finds all includes, even classes and SAP standard objects. If you want to, you can reduce this...
      CALL FUNCTION 'GET_INCLUDES'
        EXPORTING
          progname = report_id
        TABLES
          incltab  = includes.
      CHECK includes IS NOT INITIAL.
      APPEND LINES OF VALUE transport_objects( FOR include IN includes
                                               (
                                                 pgmid = limu
                                                 object = reps
                                                 obj_name = include
                                               )
                                            )
          TO program_entries.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_running_transports.

    DATA requests TYPE tmsiqreqs.

    SORT searched_objects.
    DELETE ADJACENT DUPLICATES FROM searched_objects COMPARING ALL FIELDS.

*   !!!BEWARE!!! TRBAT contains imports and exports. !!!BEWARE!!!
*   The scope here is to protect productive systems, which do not export.
*   You can take a look at FMs TMS_UIQ_IQD_READ_QUEUE and TMS_UIQ_IMPORT_QUEUE_DISPLAY,
*   but in using them you might miss imports from the OS terminal.
*   Or you prolong the runtime by also processing E070 and other tables.
*   --> Your choice :-)
    SELECT FROM trbat AS batch INNER JOIN e071 AS trans
            ON batch~trkorr = trans~trkorr
        FIELDS batch~trkorr
         FOR ALL ENTRIES IN @searched_objects
         WHERE trans~pgmid = @searched_objects-pgmid
           AND trans~object = @searched_objects-object
           AND trans~obj_name = @searched_objects-obj_name
        INTO TABLE @r_result.

    CALL FUNCTION 'TMS_UIQ_IQD_READ_QUEUE'
      EXPORTING
        iv_system         = sy-sysid
      IMPORTING
        et_requests       = requests
      EXCEPTIONS
        read_queue_failed = 1
        OTHERS            = 2.
    IF sy-subrc <> 0.

    ENDIF.

    r_result = value #( base r_result
                         FOR request in requests WHERE ( umodes = 'IO' )
                         ( request-trkorr )
                      ).

  ENDMETHOD.


  METHOD set_program_selection.
    DATA new_program_entries TYPE transport_objects.
    CHECK programs IS NOT INITIAL.

*   Lets check for existing programs
    SELECT FROM reposrc
        FIELDS
            @r3tr AS pgmid,
            @prog AS object,
            progname AS obj_name
        WHERE
              progname IN @programs
          and subc = '1'
        APPENDING TABLE @new_program_entries.

*   All programs can be also send as LIMU REPS, so lets add this
    new_program_entries = VALUE #( BASE new_program_entries
                                     FOR new_entry IN new_program_entries WHERE ( pgmid = r3tr AND object = prog )
                                        (
                                            pgmid = limu
                                            object = reps
                                            obj_name = new_entry-obj_name
                                        )
                                 ).

    IF w_includes = abap_true.
      add_includes_to_programs( CHANGING program_entries = new_program_entries ).
    ENDIF.

    APPEND LINES OF new_program_entries TO searched_objects.

  ENDMETHOD.
ENDCLASS.
