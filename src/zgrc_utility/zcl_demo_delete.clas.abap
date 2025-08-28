CLASS zcl_demo_delete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  interfaces IF_OO_ADT_CLASSRUN.


  PROTECTED SECTION.
  PRIVATE SECTION.
  daTA : lo_out TYPE ref to if_oo_adt_classrun_out.
  METHODS delete_data.
*    RAISING
*      cx_root.
ENDCLASS.



CLASS ZCL_DEMO_DELETE IMPLEMENTATION.


METHOD delete_data.
DATA : ls_loc_migr TYPE ztgrc_loc_migr.
DELETE FROM ztgrc_loc_migr.
delete FROM ztgrc_loc_migr_d.
delete FROM ztgrc_file_locn.
delete FROM ztgrc_file_loc_d.
DELETE FROM ztgrc_locationx.
ENDMETHOD.


meTHOD IF_OO_ADT_CLASSRUN~main.
*    me->out = out.
    delete_data( ).

endMETHOD.
ENDCLASS.
