@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZTB_C_BOOKING_0631 
 provider contract transactional_query
  as projection on ZTB_R_BOOKING_0631
{
    key TravelID,
    
    @Search.defaultSearchElement: true
    key BookingID,
    
    BookingDate,
    
     @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity : { name:    '/DMO/I_Customer_StdVH' ,
                                                      element: 'CustomerID' } ,
                                           useForValidation: true }]
    CustomerID,
    _Customer.LastName as CustomerName,
    
     @Search.defaultSearchElement: true
     @ObjectModel.text.element: [ 'CarrierName' ]
     @Consumption.valueHelpDefinition: [{ entity : { name:    '/DMO/I_Flight_StdVH' ,
                                                      element: 'AirlineID' } ,
                                          additionalBinding: [{ localElement: 'ConnectionId' ,
                                                                element: 'ConnectionID' ,
                                                                usage: #RESULT }],             ///min 1:30 video 7/06
                                           useForValidation: true }]
    AirlineID,
    _Carrier.Name as CarrierName,
    
    ConnectionId,
    
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LocalLastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSuppl,
    _Carrier,
    _Connection,
    _Customer,
    _Travel
}
