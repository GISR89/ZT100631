CLASS lhc_Supplements DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplimPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplements~calculateTotalSupplimPrice.

ENDCLASS.

CLASS lhc_Supplements IMPLEMENTATION.

  METHOD calculateTotalSupplimPrice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_0631=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
                                                                        GROUP BY booking_key-TravelID WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
