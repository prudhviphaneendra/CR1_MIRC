CLASS lhc_child DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS duplicate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Child~duplicate.
    METHODS setdefaults FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Child~setdefaults.

ENDCLASS.

CLASS lhc_child IMPLEMENTATION.

  METHOD duplicate.

    READ ENTITIES OF zr_grc_picklst_p IN LOCAL MODE
         ENTITY Child
         FIELDS ( ListValue )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_listvalue).

     LOOP AT lt_listvalue ASSIGNING FIELD-SYMBOL(<ls_listvalue>).
      IF <ls_listvalue>-ListValue IS INITIAL.
      APPEND VALUE #( %tky = <ls_listvalue>-%tky ) TO failed-child.
        APPEND VALUE #(
         %tky = <ls_listvalue>-%tky
          %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = | Please input List Value | ) ) to reported-child.
       ENDIF.
    ENDLOOP.

      SELECT list_value
           FROM ZTGRC_PICKLST_C
           FOR ALL ENTRIES IN @lt_listvalue
           WHERE list_value = @lt_listvalue-ListValue
           AND list_id = @lt_listvalue-ListId
           INTO TABLE @DATA(lt_picklist_c).
       IF sy-subrc = 0.
       LOOP AT lt_listvalue ASSIGNING <ls_listvalue>.
        APPEND VALUE #( %tky = <ls_listvalue>-%tky ) TO failed-child.
            APPEND VALUE #(
          %tky = <ls_listvalue>-%tky
          %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = | Provided List Value - { <ls_listvalue>-ListValue } is Already Exist | ) ) to reported-child.

    ENDLOOP.
      ENDIF.



  ENDMETHOD.

  METHOD setdefaults.

  READ ENTITIES OF zr_grc_picklst_p IN LOCAL MODE
         ENTITY Child
         FIELDS ( Active Language )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_defaults).

    DATA: lt_upd TYPE TABLE FOR UPDATE zr_grc_picklst_c.

     LOOP AT lt_defaults ASSIGNING FIELD-SYMBOL(<ls_defaults>).
      APPEND VALUE #(
        %tky = <ls_defaults>-%tky
        Active = COND #( WHEN <ls_defaults>-Active IS INITIAL THEN 'X' )
        Language =  COND #( WHEN <ls_defaults>-Language IS INITIAL THEN sy-langu ) ) TO lt_upd.
     ENDLOOP.

     MODIFY ENTITIES OF zr_grc_picklst_p IN LOCAL MODE
     ENTITY Child
     UPDATE FIELDS ( Active Language )
     WITH lt_upd.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_grc_picklst_p DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS adjust_numbers REDEFINITION.

ENDCLASS.

CLASS lsc_zr_grc_picklst_p IMPLEMENTATION.

  METHOD adjust_numbers.

      DATA:    lv_listid  TYPE zgrc_picklist_numbering,
          lv_valueid TYPE zgrc_picklist_numbering.

    IF mapped-parent IS NOT INITIAL.
*  DATA : value_id_max TYPE zgrc_numbering.
      SELECT MAX( list_id )
          FROM ztgrc_picklst_p
          INTO @DATA(lv_lists).
      IF sy-subrc = 0 AND lv_lists IS NOT INITIAL.
        DATA(list_id_max) = lv_lists.
      ELSE.
        list_id_max = '100000'.
      ENDIF.

      LOOP AT mapped-parent ASSIGNING FIELD-SYMBOL(<ls_parent>) .

        list_id_max += 1.
        <ls_parent>-ListId = list_id_max.
      ENDLOOP.

    ENDIF.

    IF mapped-child IS NOT INITIAL.
*  DATA : value_id_max TYPE zgrc_numbering.
      SELECT MAX( value_id )
          FROM ztgrc_picklst_c
          INTO @DATA(lv_picklists).
      IF sy-subrc = 0 AND lv_picklists IS NOT INITIAL.
        DATA(value_id_max) = lv_picklists.
      ELSE.
        value_id_max = '500000'.
      ENDIF.

      LOOP AT mapped-child ASSIGNING FIELD-SYMBOL(<ls_child>) STEP -1.
        <ls_child>-ListId = <ls_child>-%tmp-ListId.
        value_id_max += 1.
        <ls_child>-ValueId = value_id_max.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS LHC_ZR_GRC_PICKLST_P DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Parent
        RESULT result,
      duplicate FOR VALIDATE ON SAVE
            IMPORTING keys FOR Parent~duplicate.
ENDCLASS.

CLASS LHC_ZR_GRC_PICKLST_P IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

  METHOD duplicate.
     READ ENTITIES OF ZR_GRC_PICKLST_P IN LOCAL MODE
      ENTITY Parent
      FIELDS ( ListName )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_listname).

    LOOP AT lt_listname ASSIGNING FIELD-SYMBOL(<ls_listname>).
      IF <ls_listname>-ListName IS INITIAL.
        APPEND VALUE #(
          %tky = <ls_listname>-%tky
          %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = | Please input List Name | ) ) to reported-parent.
       ENDIF.
    ENDLOOP.

       SELECT list_name
           FROM ZTGRC_PICKLST_P
           FOR ALL ENTRIES IN @lt_listname
           WHERE list_name = @lt_listname-ListName
           INTO TABLE @DATA(lt_picklist_p).
       IF sy-subrc = 0.
       LOOP AT lt_listname ASSIGNING <ls_listname>.
        APPEND VALUE #( %tky = <ls_listname>-%tky ) TO failed-parent.
            APPEND VALUE #(
          %tky = <ls_listname>-%tky
          %msg = new_message_with_text(
                         severity = if_abap_behv_message=>severity-error
                         text = | Provided List Name - { <ls_listname>-ListName } is Already Exist | ) ) to reported-parent.

    ENDLOOP.
      ENDIF.

  ENDMETHOD.

ENDCLASS.
