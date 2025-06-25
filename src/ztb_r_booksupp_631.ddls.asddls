@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Root Entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZTB_R_BOOKSUPP_631
  as select from ztb_booksupp_631

  association        to parent ZTB_R_BOOKING_0631 as _Booking        on  $projection.BookingID = _Booking.BookingID
                                                                     and $projection.TravelID  = _Booking.TravelID

  association [1..1] to ZTB_R_TRAVEL_0631         as _Travel         on  $projection.TravelID = _Travel.TravelID
  association [1..1] to /DMO/I_Supplement         as _Supplement     on  $projection.SupplementID = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText     as _SupplementText on  $projection.SupplementID = _SupplementText.SupplementID

{
  key travel_id             as TravelID,
  key booking_id            as BookingID,
  key booking_supplement_id as BookingSupplementID,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      //Local Etag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _Booking,
      _Travel,
      _Supplement,
      _SupplementText
}
