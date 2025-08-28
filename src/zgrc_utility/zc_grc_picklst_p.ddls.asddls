@EndUserText.label: 'Picklist Maintaince Application'
@AccessControl.authorizationCheck: #CHECK
@ObjectModel.sapObjectNodeType.name: 'ZGRC_PICKLST'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZC_GRC_PICKLST_P
  provider contract transactional_query
  as projection on ZR_GRC_PICKLST_P
{
  key ListId,
  @Consumption.valueHelpDefinition: [{ entity: {
      name: 'ZR_GRC_PICKLISTNAME_VH',
      element: 'ListName'
  } }]
 ListName, 
  AppRelated,
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
  _Child : redirected to composition child ZC_GRC_PICKLST_C,
    _Createdby,
   _Lastchangedby
  
}
