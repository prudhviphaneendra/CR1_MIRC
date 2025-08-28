    @AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View Entity for Picklist'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_GRC_PICKLIST
//with parameters
//P_listID  :  zgrc_picklist_numbering 
//p_value_id  :  zgrc_picklist_numbering 
 as select from ztgrc_picklst_c
{

@UI.hidden: true
key list_id as ListId, 
@UI.hidden: true   
    key value_id as ValueId,      
    list_value as ListValue,
    concat_with_space( value_id, list_value, 1 ) as Value 
   
} ;
//where list_id = $parameters.P_listID;
//and value_id = $parameters.p_value_id;
