@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for Picklist - Coastal Distance'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GRC_COSTDIST_PL as select from ZR_GRC_PICKLST_P
{
    key _Child.ValueId as Id,
   _Child.ListValue as CoastDist
}
where ListId = '100003';
