CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITIES OF ztb_r_travel_0631 IN LOCAL MODE
     ENTITY Booking
     FIELDS ( BookingStatus )
     WITH VALUE #( FOR <row_key> IN keys ( %key = <row_key>-%key ) )
     RESULT DATA(booking).

    LOOP AT booking INTO DATA(ls_booking).
      CASE ls_booking-BookingStatus.
        WHEN 'N'.  " New
        WHEN 'X'.  " Cancelled
        WHEN 'B'.  " Booked
        WHEN OTHERS.

          APPEND VALUE #( %key = ls_booking-%key ) TO failed-booking.
          APPEND VALUE #( %key = ls_booking-%key
                          %state_area = 'VALIDATE_STATUS'
                                  %msg        = NEW /dmo/cm_flight_messages(
                                                                  status   = ls_booking-BookingStatus
                                                                  textid   = /dmo/cm_flight_messages=>status_invalid
                                                                  severity = if_abap_behv_message=>severity-error )
                                  %element-BookingStatus = if_abap_behv=>mk-on ) TO reported-booking.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.


ENDCLASS.
