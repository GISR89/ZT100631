CLASS zcl_ext_update_ent_0631 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_ext_update_ent_0631 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    MODIFY ENTITIES OF ztb_r_travel_0631
           ENTITY Travel
           UPDATE FIELDS ( AgencyID Description )
           WITH VALUE #( ( TravelID    = '00000001'
                           AgencyID    = '000002'
                           Description = 'new update' ) )
           FAILED DATA(failed)
           REPORTED DATA(reported).

    READ ENTITIES OF ztb_r_travel_0631
           ENTITY Travel
           FIELDS ( AgencyID Description )
           WITH VALUE #( ( TravelID    = '00000001' ) )
           RESULT DATA(lt_travel_data)
           FAILED failed
           REPORTED reported.

    COMMIT ENTITIES.

    IF failed IS INITIAL.
      out->write( 'Commit Successfull' ).
    ELSE.
      out->write( 'Commit Failed' ).
    ENDIF.


  ENDMETHOD.

ENDCLASS.
