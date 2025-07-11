CLASS lhc_Supplements DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplimPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplements~calculateTotalSupplimPrice.

ENDCLASS.

CLASS lhc_Supplements IMPLEMENTATION.

  METHOD calculateTotalSupplimPrice.
  ENDMETHOD.

ENDCLASS.
