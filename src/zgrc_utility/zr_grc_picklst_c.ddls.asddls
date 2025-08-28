@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for ZTGRC_PICKLST_C'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GRC_PICKLST_C as select from ztgrc_picklst_c
association to parent ZR_GRC_PICKLST_P as _Parent on
$projection.ListId = _Parent.ListId
association[0..1] to I_User as _Createdby
    on $projection.Createdby = _Createdby.UserID
    association[0..1] to I_User as _Lastchangedby
    on $projection.Lastchangedby = _Lastchangedby.UserID
{
    key list_id as ListId,
    
    key value_id as ValueId,
    list_value as ListValue,
    list_desc as ListDesc,
    active as Active,
    lang as Language,
    @Semantics.user.createdBy: true
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
    @Semantics.user.localInstanceLastChangedBy: true
    lastchangedby as Lastchangedby,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangedat as Lastchangedat,
    _Parent,
    _Createdby,
    _Lastchangedby
}
