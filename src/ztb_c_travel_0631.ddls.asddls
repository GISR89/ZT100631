@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true
@Search.searchable: true

define root view entity ZTB_C_TRAVEL_0631
  provider contract transactional_query
  as projection on ZTB_R_TRAVEL_0631
{
      @Search.defaultSearchElement: true
  key TravelID,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Consumption.valueHelpDefinition: [{ entity : { name:    '/DMO/I_Agency_StdVH' ,
                                                      element: 'AgencyID' } ,
                                           useForValidation: true }]
      AgencyID,
      _Agency.Name as AgencyName,

      @Search.defaultSearchElement: true
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [{ entity : { name:    '/DMO/I_Customer_StdVH' ,
                                                      element: 'CustomerID' } ,
                                           useForValidation: true }]
      CustomerID,
      _Customer.LastName as CustomerName,
      
      BeginDate,
      EndDate,
      
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [{ entity : { name:    'I_CurrencyStdVH' ,
                                                      element: 'Currency' } ,
                                           useForValidation: true }]
      CurrencyCode,
      
      Description,
      
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      _OverallStatus._Text.Text as OverallStatusText : localized,

      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,

      /* Associations */
      _Agency,
      _Booking,
      _Currency,
      _Customer,
      _OverallStatus
}
