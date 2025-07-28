CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES:
      ty_travel_create               TYPE TABLE FOR CREATE ztb_r_travel_0631\\Travel,
      ty_travel_update               TYPE TABLE FOR UPDATE ztb_r_travel_0631\\Travel,
      ty_travel_delete               TYPE TABLE FOR DELETE ztb_r_travel_0631\\Travel,
      ty_travel_failed               TYPE TABLE FOR FAILED EARLY ztb_r_travel_0631\\Travel,
      ty_travel_reported             TYPE TABLE FOR REPORTED EARLY ztb_r_travel_0631\\Travel,

      ty_travel_action_accept_import TYPE TABLE FOR ACTION IMPORT ztb_r_travel_0631\\Travel~acceptTravel,
      ty_travel_action_accept_result TYPE TABLE FOR ACTION RESULT ztb_r_travel_0631\\Travel~acceptTravel.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O', "Open
        accepted TYPE c LENGTH 1 VALUE 'A', "Accepted
        reject   TYPE c LENGTH 1 VALUE 'X', "Rejected
      END OF travel_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
      ENTITY Travel
      FIELDS ( OverallStatus )
      WITH VALUE #( FOR row_key IN  keys ( %key = row_key-%key ) )
      RESULT DATA(lt_entity_travel).

    result = VALUE #( FOR ls_travel IN lt_entity_travel ( %key   = ls_travel-%key
                                                          "%field-TravelID      = COND #( WHEN ls_travel-OverallStatus = travel_status-accepted
                                                          %field-OverallStatus      = COND #( WHEN ls_travel-OverallStatus = travel_status-accepted
                                                                                         THEN if_abap_behv=>fc-f-read_only
                                                                                         ELSE if_abap_behv=>fc-f-unrestricted )
                                                          %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = travel_status-accepted
                                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                                         ELSE if_abap_behv=>fc-o-enabled )
                                                          %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = travel_status-reject
                                                                                         THEN if_abap_behv=>fc-o-disabled
                                                                                         ELSE if_abap_behv=>fc-o-enabled ) ) ).


  ENDMETHOD.

  METHOD get_instance_authorizations.

  ENDMETHOD.

  METHOD get_global_authorizations.

    "CB9980007185

    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name(  ).


    IF requested_authorizations-%create EQ if_abap_behv=>mk-on OR
         requested_authorizations-%action-createTravelByTemplate EQ if_abap_behv=>mk-on.

      IF lv_technical_name EQ 'CB9980007185'.
        result-%create                        = if_abap_behv=>auth-allowed.
        result-%action-createTravelByTemplate = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create                        = if_abap_behv=>auth-unauthorized.
        result-%action-createTravelByTemplate = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>not_authorized
                                                            severity    = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDIF.

    IF requested_authorizations-%update EQ if_abap_behv=>mk-on.

      IF lv_technical_name EQ 'CB9980007185'.
        result-%update      = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update      = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>not_authorized
                                                            severity    = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDIF.

    IF requested_authorizations-%action-acceptTravel     EQ if_abap_behv=>mk-on OR
       requested_authorizations-%action-rejectTravel EQ if_abap_behv=>mk-on.


      IF lv_technical_name EQ 'CB9980007185'.
        result-%action-acceptTravel = if_abap_behv=>auth-allowed.
        result-%action-rejectTravel = if_abap_behv=>auth-allowed.
      ELSE.
        result-%action-acceptTravel = if_abap_behv=>auth-unauthorized.
        result-%action-rejectTravel = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>not_authorized
                                                            severity    = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDIF.

    IF requested_authorizations-%delete EQ if_abap_behv=>mk-on.

      IF lv_technical_name EQ 'CB9980007185'.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.

        APPEND VALUE #( %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>not_authorized
                                                            severity    = if_abap_behv_message=>severity-error )
                        %global = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD createTravelByTemplate.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelID AgencyID CustomerID BookingFee TotalPrice CurrencyCode )
    WITH VALUE #( FOR row_key IN  keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    FAILED failed
    REPORTED reported.

    DATA lt_create_travel TYPE TABLE FOR CREATE ztb_r_travel_0631\\Travel.

    SELECT MAX( travel_id ) FROM ztb_travel_0631 INTO @DATA(lv_travel_id).

    DATA(lv_date) = cl_abap_context_info=>get_system_date( ).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
                                                     ( %cid = lv_travel_id + idx
                                                       TravelID      = lv_travel_id + idx
                                                       AgencyID      = create_row-AgencyID
                                                       CustomerID    = create_row-CustomerID
                                                       BeginDate     = lv_date
                                                       EndDate       = lv_date + 30
                                                       BookingFee    = create_row-BookingFee
                                                       TotalPrice    = create_row-TotalPrice
                                                       CurrencyCode  = create_row-CurrencyCode
                                                       Description   = 'Add comments'
                                                       OverallStatus = travel_status-open ) ).

    MODIFY ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
     ENTITY Travel
     CREATE FIELDS ( TravelID
                     AgencyID
                     CustomerID
                     BeginDate
                     EndDate
                     BookingFee
                     TotalPrice
                     CurrencyCode
                     Description
                     OverallStatus )
     WITH lt_create_travel
     MAPPED mapped
     FAILED failed
     REPORTED reported.

    result = VALUE #( FOR result_row IN lt_create_travel INDEX INTO idx
                                      ( %cid_ref = keys[ idx ]-%cid_ref
                                        %key     = keys[ idx ]-%key
                                        %param   = CORRESPONDING #( result_row ) ) ).

  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
             ENTITY Travel
             UPDATE
             FIELDS ( OverallStatus )
             WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                             OverallStatus = travel_status-accepted ) ).

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
         ENTITY Travel
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
           ENTITY Travel
           UPDATE
           FIELDS ( OverallStatus )
           WITH VALUE #( FOR key IN keys ( %tky          = key-%tky
                                           OverallStatus = travel_status-reject ) ).

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
         ENTITY Travel
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  ENDMETHOD.

  METHOD validateCustomer.

    DATA customers TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY client customer_id.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( CustomerID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING customer_id = CustomerID EXCEPT * ).
    DELETE customers WHERE customer_id IS INITIAL.

    IF customers IS NOT INITIAL.

      SELECT FROM /dmo/customer AS db
             INNER JOIN @customers AS it ON db~customer_id = it~customer_id
             FIELDS db~customer_id
             INTO TABLE @DATA(valid_customers).

    ENDIF.

    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #( %tky        = travel-%tky
                      %state_area = 'VALIDATE_CUSTOMER' ) TO reported-travel.

      IF travel-CustomerID IS INITIAL.

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid   = /dmo/cm_flight_messages=>enter_customer_id
                                                            severity = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF NOT line_exists( valid_customers[ customer_id = travel-CustomerID ] ).

        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = travel-%tky
                        %state_area = 'VALIDATE_CUSTOMER'
                        %msg = NEW /dmo/cm_flight_messages( textid      = /dmo/cm_flight_messages=>customer_unkown
                                                            customer_id = travel-CustomerID
                                                            severity    = if_abap_behv_message=>severity-error )
                        %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
              ENTITY Travel
              FIELDS (  BeginDate EndDate TravelID )
              WITH CORRESPONDING #( keys )
              RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(  %tky               = travel-%tky
                       %state_area        = 'VALIDATE_DATES' ) TO reported-travel.

      IF travel-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_begin_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

      IF travel-EndDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg                = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_end_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

      IF travel-EndDate < travel-BeginDate AND travel-BeginDate IS NOT INITIAL
                                           AND travel-EndDate IS NOT INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW /dmo/cm_flight_messages(
                                                                textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                                begin_date = travel-BeginDate
                                                                end_date   = travel-EndDate
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

      IF travel-BeginDate < cl_abap_context_info=>get_system_date( ) AND travel-BeginDate IS NOT INITIAL.
        APPEND VALUE #( %tky               = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                begin_date = travel-BeginDate
                                                                textid     = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
            ENTITY Travel
            FIELDS ( OverallStatus )
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).
      CASE travel-OverallStatus.

        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.

          APPEND VALUE #( %key = travel-%key ) TO failed-travel.

          APPEND VALUE #( %key        = travel-%key
                          %state_area = 'VALIDATE_STATUS'
                          %msg        = NEW /dmo/cm_flight_messages(
                                                          status   = travel-OverallStatus
                                                          textid   = /dmo/cm_flight_messages=>status_invalid
                                                          severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZTB_R_TRAVEL_0631 DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: create TYPE string VALUE 'C',
               update TYPE string VALUE 'U',
               delete TYPE string VALUE 'D'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.


ENDCLASS.

CLASS lsc_ZTB_R_TRAVEL_0631 IMPLEMENTATION.

  METHOD save_modified.


**********************************************************************
    DATA: lt_travel_log   TYPE STANDARD TABLE OF ztb_log_0631,
          lt_travel_log_u TYPE STANDARD TABLE OF ztb_log_0631.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    IF NOT create-travel IS INITIAL.

      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).

        GET TIME STAMP FIELD <ls_travel_log>-created_at.
        <ls_travel_log>-changing_operation = lsc_ZTB_R_TRAVEL_0631=>create.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS TravelID = <ls_travel_log>-travelid
            INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name = 'BookingFee'.
            <ls_travel_log>-changed_value      = ls_travel-BookingFee.
            <ls_travel_log>-user_mod           = lv_user.
            TRY.
                <ls_travel_log>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH  cx_uuid_error.
            ENDTRY.
            APPEND <ls_travel_log> TO lt_travel_log_u.
          ENDIF.

        ENDIF.

      ENDLOOP.
    ENDIF.

    IF NOT update-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( update-travel ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travelid = ls_update_travel-TravelID ] TO FIELD-SYMBOL(<ls_travel_log_up>).

        GET TIME STAMP FIELD <ls_travel_log_up>-created_at.
        <ls_travel_log_up>-changing_operation = lsc_ZTB_R_TRAVEL_0631=>update.

        IF ls_update_travel-%control-CustomerID EQ  cl_abap_behv=>flag_changed OR
           ls_update_travel-%control-AgencyID EQ  cl_abap_behv=>flag_changed OR
           ls_update_travel-%control-OverallStatus EQ  cl_abap_behv=>flag_changed OR
           ls_update_travel-%control-BookingFee EQ  cl_abap_behv=>flag_changed OR

          <ls_travel_log_up>-changed_field_name = 'CustomerID'.
          <ls_travel_log_up>-changed_value      = ls_update_travel-CustomerID.
          <ls_travel_log_up>-user_mod           = lv_user.
          TRY.
              <ls_travel_log_up>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH  cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_up> TO lt_travel_log_u.
        ENDIF.

      ENDLOOP.
    ENDIF.

    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).
        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation = lsc_ZTB_R_TRAVEL_0631=>delete.
        <ls_travel_log_del>-user_mod          = lv_user.
        TRY.
            <ls_travel_log_del>-change_id          = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH  cx_uuid_error.
        ENDTRY.
        APPEND <ls_travel_log_del> TO lt_travel_log_u.

      ENDLOOP.
    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT ztb_log_0631 FROM TABLE @lt_travel_log_u.
    ENDIF.

**********************************************************************
    DATA:lt_supplements TYPE STANDARD TABLE OF ztb_booksupp_631,
         lv_op_type     TYPE zde_flag_0631,
         lv_update      TYPE zde_flag_0631.

    IF NOT create-supplements IS INITIAL.

       LOOP AT create-supplements INTO DATA(ls_supplements).
        APPEND INITIAL LINE TO lt_supplements ASSIGNING FIELD-SYMBOL(<fs_supplements>).
        <fs_supplements>-travel_id  = ls_supplements-TravelID.
        <fs_supplements>-booking_id = ls_supplements-BookingID.
        <fs_supplements>-supplement_id = ls_supplements-SupplementID.
        <fs_supplements>-price = ls_supplements-Price.
        <fs_supplements>-currency_code = ls_supplements-CurrencyCode.
        <fs_supplements>-local_last_changed_at = ls_supplements-LocalLastChangedAt.
      ENDLOOP.

      lv_op_type = lsc_ztb_r_travel_0631=>create.
    ENDIF.

    IF NOT update-supplements IS INITIAL.

      LOOP AT update-supplements INTO ls_supplements.
        APPEND INITIAL LINE TO lt_supplements ASSIGNING <fs_supplements>.
        <fs_supplements>-travel_id  = ls_supplements-TravelID.
        <fs_supplements>-booking_id = ls_supplements-BookingID.
        <fs_supplements>-supplement_id = ls_supplements-SupplementID.
        <fs_supplements>-price = ls_supplements-Price.
        <fs_supplements>-currency_code = ls_supplements-CurrencyCode.
        <fs_supplements>-local_last_changed_at = ls_supplements-LocalLastChangedAt.
      ENDLOOP.

      " lt_supplements = CORRESPONDING #( create-supplements ).
      lv_op_type = lsc_ztb_r_travel_0631=>update.
    ENDIF.

    IF NOT delete-supplements IS INITIAL.

         LOOP AT delete-supplements INTO data(ls_supplements_del).
        APPEND INITIAL LINE TO lt_supplements ASSIGNING FIELD-SYMBOL(<fs_supplements2>).
        <fs_supplements2>-travel_id  = ls_supplements_del-TravelID.
        <fs_supplements2>-booking_id = ls_supplements_del-BookingID.
        <fs_supplements2>-supplement_id = ls_supplements_del-BookingSupplementID.

      ENDLOOP.

      "lt_supplements = CORRESPONDING #( create-supplements ).
      lv_op_type = lsc_ztb_r_travel_0631=>delete.
    ENDIF.

    IF NOT lt_supplements IS INITIAL.

      CALL FUNCTION 'Z_SUPPL_0631'
        EXPORTING
          it_supplements = lt_supplements
          iv_op_type     = lv_op_type
        IMPORTING
          ev_updated     = lv_update.

*  if lv_update eq abap_true.
*    reported-supplements[ 1 ]-%msg "para mensajes
*  endif.

    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.


ENDCLASS.
