@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZTB_I_BOOKSUPP_631 
  as projection on ZTB_R_BOOKSUPP_631
{
    key TravelID,
    key BookingID,
    key BookingSupplementID,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    
    /* Associations */
    _Booking : redirected to parent ZTB_I_BOOKING_0631,
    _Supplement,
    _SupplementText,
    _Travel : redirected to ZTB_I_TRAVEL_0631
}
