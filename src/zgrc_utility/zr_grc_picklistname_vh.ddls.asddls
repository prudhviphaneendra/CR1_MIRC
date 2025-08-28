@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity of Value Help of Picklist Name'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@Search.searchable: true
define view entity ZR_GRC_PICKLISTNAME_VH as select from ztgrc_picklst_p
{
   @UI.hidden: true
    key list_id as ListId,
    @EndUserText.label: 'List Name'
    @Search.defaultSearchElement: true
    @Search.fuzzinessThreshold: 0.7
    list_name as ListName,
    @EndUserText.label: 'App Related'
    app_related as AppRelated
    
}
