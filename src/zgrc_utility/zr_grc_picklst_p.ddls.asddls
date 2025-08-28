@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Picklist Maintainance Application'
@ObjectModel.sapObjectNodeType.name: 'ZGRC_PICKLST'
define root view entity ZR_GRC_PICKLST_P
  as select from ztgrc_picklst_p
    composition[0..*] of ZR_GRC_PICKLST_C as _Child
    association[0..1] to I_User as _Createdby
    on $projection.Createdby = _Createdby.UserID
    association[0..1] to I_User as _Lastchangedby
    on $projection.Lastchangedby = _Lastchangedby.UserID
{
  key list_id as ListId,
  list_name as ListName,
  app_related as AppRelated,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.localInstanceLastChangedBy: true
  lastchangedby as Lastchangedby,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  lastchangedat as Lastchangedat,
   _Child,
     _Createdby,
  _Lastchangedby
  
}
