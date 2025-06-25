@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Interface Entity'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZTB_I_BOOKING_0631 
  as projection on ZTB_R_BOOKING_0631
{
    key TravelID,
    key BookingID,
    BookingDate,
    CustomerID,
    AirlineID,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    LocalLastChangedAt,
    
    /* Associations */
    _BookingStatus,
    _BookingSuppl : redirected to composition child ZTB_I_BOOKSUPP_631,
    _Carrier,
    _Connection,
    _Customer,
    _Travel : redirected to parent ZTB_I_TRAVEL_0631
}
