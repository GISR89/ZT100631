@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplements - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define view entity ZTB_C_BOOKSUPP_631
  as projection on ZTB_R_BOOKSUPP_631
{
  key TravelID,
  key BookingID,

      @Search.defaultSearchElement: true
  key BookingSupplementID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'SupplementDescription' ]
      @Consumption.valueHelpDefinition: [{ entity : { name:    '/DMO/I_Supplement_StdVH' ,
                                                    element: 'SupplementID' } ,
                                         additionalBinding: [{ localElement: 'Price' ,
                                                               element: 'Price' ,
                                                               usage: #RESULT },

                                                               { localElement: 'CurrencyCode' ,
                                                               element: 'CurrencyCode' ,
                                                               usage: #RESULT } ],
                                          useForValidation: true }]

      SupplementID,
      _SupplementText.Description as SupplementDescription : localized,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      @Consumption.valueHelpDefinition: [{ entity : { name:    'I_CurrencyStdVH' ,
                                                      element: 'Currency' } ,
                                           useForValidation: true }]
      CurrencyCode,

      LocalLastChangedAt,

      /* Associations */
      _Booking : redirected to parent ZTB_C_BOOKING_0631,
      _Supplement,
      _SupplementText,
      _Travel  : redirected to ZTB_C_TRAVEL_0631
}
