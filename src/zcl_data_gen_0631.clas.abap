CLASS zcl_data_gen_0631 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_data_gen_0631 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DELETE FROM ztb_travel_0631.

    INSERT ztb_travel_0631 FROM (
      SELECT FROM /dmo/travel
        FIELDS
          travel_id,
          agency_id,
          customer_id,
          begin_date,
          end_date,
          booking_fee,
          total_price,
          currency_code,
          description,
          CASE status WHEN 'B' THEN 'A'
                      WHEN 'P' THEN 'O'
                      WHEN 'N' THEN 'O'
                      ELSE 'X' END AS overall_status,
          createdby AS created_by,
          createdat AS created_at,
          lastchangedby AS last_changed_by,
          lastchangedat AS last_changed_at  ).

    DELETE FROM ztb_booking_0631.

    INSERT ztb_booking_0631 FROM (
        SELECT
          FROM /dmo/booking
          JOIN ztb_travel_0631 ON /dmo/booking~travel_id = ztb_travel_0631~travel_id
          JOIN /dmo/travel ON /dmo/travel~travel_id = /dmo/booking~travel_id
          FIELDS
                  ztb_travel_0631~travel_id,
                  /dmo/booking~booking_id,
                  /dmo/booking~booking_date,
                  /dmo/booking~customer_id,
                  /dmo/booking~carrier_id,
                  /dmo/booking~connection_id,
                  /dmo/booking~flight_date,
                  /dmo/booking~flight_price,
                  /dmo/booking~currency_code,
                  CASE /dmo/travel~status WHEN 'P' THEN 'N'
                                                   ELSE /dmo/travel~status END AS booking_status,
                  ztb_travel_0631~last_changed_at AS last_changed_at ).


    DELETE FROM ztb_booksupp_631.

    INSERT ztb_booksupp_631 FROM (
       SELECT FROM /dmo/book_suppl AS supp
              JOIN ztb_travel_0631  AS trvl ON trvl~travel_id = supp~travel_id
              JOIN ztb_booking_0631 AS book ON book~travel_id = trvl~travel_id
                                           AND book~booking_id = supp~booking_id
              FIELDS
             trvl~travel_id,
             book~booking_id,
              supp~booking_supplement_id,
              supp~supplement_id,
              supp~price,
              supp~currency_code,
              trvl~last_changed_at    AS local_last_changed_at ).

  ENDMETHOD.

ENDCLASS.
