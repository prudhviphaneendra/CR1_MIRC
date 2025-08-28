@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Picklist Maintaince Application'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_GRC_PICKLST_C as projection on ZR_GRC_PICKLST_C
{
           key ListId,
    key ValueId,
    @EndUserText.label: 'List Name'
    ListValue,
    ListDesc,
    Active,
//    @Consumption.defaultValue: 'EN'
    Language,
    @ObjectModel.text.element: [ 'CreatedUser' ]
  @UI.textArrangement: #TEXT_ONLY
    Createdby,
      _Createdby.UserDescription as CreatedUser,
    Createdat,
      @ObjectModel.text.element: [ 'ChangedUser' ]
  @UI.textArrangement: #TEXT_ONLY
    Lastchangedby,
      _Lastchangedby.UserDescription as ChangedUser,
    Lastchangedat,
    /* Associations */
    _Parent : redirected to parent ZC_GRC_PICKLST_P,
        _Createdby,
   _Lastchangedby
}
