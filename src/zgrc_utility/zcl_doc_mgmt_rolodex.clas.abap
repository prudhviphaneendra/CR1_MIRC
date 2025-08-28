CLASS zcl_doc_mgmt_rolodex DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    interfaces if_sadl_exit_calc_element_read.
    CLASS-METHODS : execute_data.

    DATA : gv_tenant_id TYPE zgrc_doc_mgmt_tenant_id.
    DATA : gv_folder_id TYPE zgrc_doc_mgmt_folder_id.
    DATA : gv_root_folder_id TYPE zgrc_doc_mgmt_folder_id.
    DATA : gv_main_uuid TYPE sysuuid_x16.
    DATA : gv_comm_scenario TYPE if_com_management=>ty_cscn_id.
    DATA : gv_service_id TYPE if_com_management=>ty_cscn_outb_srv_id.
    DATA : gv_app_name TYPE zgrc_app_name.

    TYPES:
      BEGIN OF http_status,
        code   TYPE i,
        reason TYPE string,
      END OF http_status .
    METHODS : constructor IMPORTING iv_app_name  TYPE zgrc_app_name OPTIONAL
                                    iv_doc_type  TYPE zgrc_doc_type OPTIONAL
                                    iv_main_uuid TYPE sysuuid_x16 OPTIONAL,

      is_attach_feature_available IMPORTING iv_app_name         TYPE zgrc_app_name
                                  RETURNING VALUE(RV_available) TYPE abap_boolean,
      get_communication_details IMPORTING iv_app_name     TYPE zgrc_app_name
                                EXPORTING eo_http_client  TYPE REF TO if_web_http_client
                                          eo_http_request TYPE REF TO if_web_http_request,

      set_http_header IMPORTING io_http_client  TYPE REF TO if_web_http_client
                                io_http_request TYPE REF TO if_web_http_request
                                IV_action_name  TYPE string,

      set_uri_path    IMPORTING io_http_client  TYPE REF TO if_web_http_client
                                io_http_request TYPE REF TO if_web_http_request
                                iv_action_name  TYPE string,

      set_part_data   IMPORTING iv_file_name    TYPE string OPTIONAL
                                iv_file_data    TYPE xstring OPTIONAL
                                io_http_client  TYPE REF TO if_web_http_client
                                io_http_request TYPE REF TO if_web_http_request
                                iv_action_name  TYPE string,

      get_folder_id RETURNING VALUE(rv_folder_id) TYPE zgrc_doc_mgmt_folder_id,
      upload_file IMPORTING iv_file_name   TYPE string
                            iv_file_data   TYPE xstring
                            iv_app_name    TYPE zgrc_app_name
                  EXPORTING es_status      TYPE http_status
                            ev_status_text TYPE string
                  RAISING
                            cx_web_http_client_error,
      download_file IMPORTING iv_folder_id TYPE zgrc_doc_mgmt_folder_id,
*                              iv_file_id   t
      execute_query_post IMPORTING io_http_client   TYPE REF TO if_web_http_client
                                   io_http_request  TYPE REF TO if_web_http_request
                         CHANGING  co_http_response TYPE REF TO if_web_http_response,

      receive_results CHANGING gv_flag TYPE abap_boolean,

      delete_file.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA : lo_out TYPE REF TO if_oo_adt_classrun_out.
    METHODS : create_folder IMPORTING iv_tenant_id        TYPE zgrc_doc_mgmt_tenant_id
                                      folder_name         TYPE string
                            RETURNING VALUE(rv_folder_id) TYPE zgrc_doc_mgmt_folder_id.

ENDCLASS.



CLASS zcl_doc_mgmt_rolodex IMPLEMENTATION.

  METHOD constructor.
*    if iv_doc_type IS INITIAL.
    DATA(lv_doc_type) = iv_doc_type.
    lv_doc_type = 'GENERIC'.
*    ENDIF.
*    if iv_app_name IS INITIAL.
    DATA(lv_app_name) = iv_doc_type.
    lv_app_name = 'GENERIC'.
*    ENDIF.
    IF iv_app_name IS NOT INITIAL.
      gv_app_name = iv_app_name.
    ENDIF.
    SELECT * FROM ztgrc_fixed_val
    WHERE app_name IN ( @iv_app_name , @lv_app_name ) AND
          doc_type IN ( @lv_doc_type , @iv_doc_type )
    INTO TABLE @DATA(lt_fixed_value).
*    ENDIF.

    gv_main_uuid = iv_main_uuid.

    IF lt_fixed_value IS NOT INITIAL.
      gv_tenant_id = VALUE #( lt_fixed_value[  id = 'TENANT_ID' ]-value OPTIONAL ).
*    'ff26efb5-3362-4701-9680-22044dd23bf7'.

      gv_comm_scenario = VALUE #( lt_fixed_value[  id = 'COMM_SCENARIO' ]-value OPTIONAL ).
      gv_service_id = VALUE #( lt_fixed_value[  id = 'SERVICE_ID' ]-value OPTIONAL ).

      gv_root_folder_id = VALUE #( lt_fixed_value[ id = 'ROOT_FOLDER_ID' ]-value OPTIONAL ).
    ENDIF.

    CLEAR : gv_main_uuid.
    SELECT SINGLE folder_id FROM ztgrc_doc_rep
    WHERE uuid = @gv_main_uuid
    INTO @gv_folder_id.

*    gv_folder_id = '6891ce01b60e545d6396ea02'.
  ENDMETHOD.
  METHOD get_communication_details.

    DATA : lo_http_response TYPE REF TO if_web_http_response.
    DATA: lv_comm_scenario  TYPE if_com_management=>ty_cscn_id,
          lv_service_id     TYPE if_com_management=>ty_cscn_outb_srv_id,
          lv_comm_system_id TYPE if_com_management=>ty_cs_id.


    DATA : lo_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

*    lv_comm_scenario = 'ZGRC_DOC_MGMT_ROLODEX_CS'.
*    lv_service_id = 'ZGRC_DOC_MGMT_ROLODEX_REST'.

    lo_cscn = VALUE #(  ( sign = 'I' option = 'EQ' low = gv_comm_scenario  ) ).

    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance(  ).

    lo_factory->query_ca(
      EXPORTING
        is_query              = VALUE #( cscn_id_range = lo_cscn )
      IMPORTING
        et_com_arrangement    = DATA(lt_com_arrangement)
*    et_com_arrangement_v2 =
    ).

    READ TABLE lt_com_arrangement INTO DATA(ls_com_arrangement) INDEX 1.


    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                          comm_scenario  = gv_comm_scenario
                          service_id     = gv_service_id
                          comm_system_id = ls_com_arrangement->get_comm_system_id(  )
                        ).
      CATCH cx_http_dest_provider_error INTO DATA(lo_exception).
        "handle exception
    ENDTRY.

    TRY.
        eo_http_client = cl_web_http_client_manager=>create_by_http_destination( i_destination = lo_dest ).
        eo_http_request = eo_http_client->get_http_request( ).


      CATCH cx_web_http_client_error.
        "handle exception
    ENDTRY.


  ENDMETHOD.

  METHOD set_http_header.
    DATA : lv_value TYPE string.

    IF iv_action_name = 'CREATE_FOLDER'.
      LV_value = 'application/json'.
    ELSEIF iv_action_name = 'UPLOAD_FILE'.
      lv_value = 'multipart/form-data'.
    ENDIF.

    io_http_request->set_header_field(
      EXPORTING
        i_name  = 'Accept'
        i_value = 'application/json'  ).

    io_http_request->set_header_field(
  EXPORTING
    i_name  = 'x-tenant-id'
    i_value = CONV string( gv_tenant_id )    ).

    io_http_request->set_header_field(
  EXPORTING
    i_name  = 'Content-Type'
    i_value = lv_value   ).

  ENDMETHOD.

  METHOD set_uri_path.
    DATA : lv_uri TYPE string.

    IF  iv_action_name = 'CREATE_FOLDER'.
      lv_uri = '/folders/' && gv_root_folder_id.
    ELSEIF iv_action_name = 'UPLOAD_FILE'.
      lv_uri = '/folders/' && gv_folder_id && '/files'.
    ENDIF.

    io_http_request->set_uri_path(
      EXPORTING
        i_uri_path = lv_uri ).
  ENDMETHOD.

  METHOD set_part_data.


    IF iv_action_name EQ 'UPLOAD_FILE'.
      DATA(lo_part) = io_http_request->add_multipart( ).
      DATA(lv_value) = 'form-data;name="files";filename="' && iv_file_name && '"'.
      lo_part->set_content_type( content_type = 'application/xlsx' ).
      lo_part->set_header_field(
    EXPORTING
      i_name  = if_web_http_header=>content_disposition
      i_value = lv_value ).

      lo_part->set_binary(
        EXPORTING
          i_data   = iv_file_data ).

    ELSEIF iv_Action_name = 'CREATE_FOLDER'.
      FREE lo_part.
      lo_part = io_http_request->add_multipart( ).
      lv_value = gv_app_name.
      lo_part->set_header_field(
    EXPORTING
      i_name  = 'name'
      i_value = lv_value ).
*    lo_part->set_content_type( content_type = 'application/json' ).
    ENDIF.


  ENDMETHOD.

  METHOD is_attach_Feature_available.
    IF iv_app_name EQ 'LOCATION' OR iv_app_name EQ 'PROPERTY'.
      rv_available = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_folder_id.
    rv_folder_id = gv_folder_id.
  ENDMETHOD.

  METHOD upload_file.
    DATA: lo_http_response TYPE REF TO if_web_http_response.
    DATA : lv_folder_name TYPE string.
    IF is_attach_feature_available( iv_app_name ) EQ abap_true.


      IF gv_folder_id IS INITIAL.
*      it means folder id is not available & we need to create the folder first
        gv_folder_id = '6891ce01b60e545d6396ea02'.
*        CLEAR : lv_folder_name.
*        lv_folder_name = iv_app_name.
*        create_folder(
*          EXPORTING
*            iv_tenant_id = gv_tenant_id
*            folder_name  = lv_folder_name
*          RECEIVING
*            rv_folder_id = gv_folder_id
*        ).

      ENDIF.


*      it means folder id is available and no need to create new folder
      get_communication_details(
        EXPORTING
          iv_app_name     = iv_app_name
        IMPORTING
          eo_http_client  = DATA(lo_http_client)
          eo_http_request = DATA(lo_http_request) ).

      set_http_header(
        io_http_client  = lo_http_client
        io_http_request = lo_http_request
        iv_action_name = 'UPLOAD_FILE' ).

      set_uri_path(
        io_http_client  = lo_http_client
        io_http_request = lo_http_request
        iv_action_name = 'UPLOAD_FILE'
        ).


      set_part_data(
        iv_file_name    = iv_file_name
        iv_file_data    = iv_file_data
        io_http_client  = lo_http_client
        io_http_request = lo_http_request
        iv_action_name = 'UPLOAD_FILE' ).

      me->execute_query_post(
        EXPORTING
          io_http_client   = lo_http_client
          io_http_request  = lo_http_request
        CHANGING
          co_http_response = lo_http_response
      ).

      lo_http_response->get_status(
        RECEIVING
          r_value = DATA(ls_status)
      ).

      lo_http_response->get_text(
        RECEIVING
          r_value = DATA(lv_json_string)
      ).

      es_status = ls_status.
      ev_status_text = lv_json_string.

    ENDIF.


  ENDMETHOD.

  METHOD delete_file.
  ENDMETHOD.


  METHOD execute_data.


    DATA : lt_ztgrc_fixed_val TYPE TABLE OF ztgrc_fixed_val.

    lt_ztgrc_fixed_val = VALUE #( ( app_name = 'GENERIC' doc_type = 'GENERIC' id = 'TENANT_ID' value = 'ff26efb5-3362-4701-9680-22044dd23bf7' )
                                  ( app_name = 'GENERIC' doc_type = 'GENERIC' id = 'COMM_SCENARIO' value = 'ZGRC_DOC_MGMT_ROLODEX_CS' )
                                  ( app_name = 'GENERIC' doc_type = 'GENERIC' id = 'SERVICE_ID' value = 'ZGRC_DOC_MGMT_ROLODEX_REST' )
                                  ( app_name = 'GENERIC' doc_type = 'GENERIC' id = 'ROOT_FOLDER_ID' value = '6891ce01b60e545d6396ea02' ) ).

    MODIFY ztgrc_fixed_val FROM TABLE @lt_ztgrc_fixed_val.

  ENDMETHOD.

  METHOD execute_query_post.
    TRY.
        io_http_client->execute(
          EXPORTING
            i_method      =  if_web_http_client=>post
          RECEIVING
            r_response    = co_http_response
        ).
      CATCH cx_web_http_client_error.
        "handle exception
    ENDTRY.

  ENDMETHOD.

  METHOD receive_results.

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
*    me->out = out.
    execute_data(  ).
  ENDMETHOD.


  METHOD create_folder.
    DATA: lo_http_response TYPE REF TO if_web_http_response.

*      it means folder id is available and no need to create new folder
    get_communication_details(
      EXPORTING
        iv_app_name     = gv_app_name
      IMPORTING
        eo_http_client  = DATA(lo_http_client)
        eo_http_request = DATA(lo_http_request) ).

    set_http_header(
      io_http_client  = lo_http_client
      io_http_request = lo_http_request
      iv_action_name = 'CREATE_FOLDER' ).

    set_uri_path(
      io_http_client  = lo_http_client
      io_http_request = lo_http_request
      iv_action_name = 'CREATE_FOLDER' ).


    set_part_data(
      io_http_client  = lo_http_client
      io_http_request = lo_http_request
      iv_action_name = 'CREATE_FOLDER' ).

    me->execute_query_post(
      EXPORTING
        io_http_client   = lo_http_client
        io_http_request  = lo_http_request
      CHANGING
        co_http_response = lo_http_response
    ).

    lo_http_response->get_status(
      RECEIVING
        r_value = DATA(ls_status)
    ).

    lo_http_response->get_text(
      RECEIVING
        r_value = DATA(lv_json_string)
    ).


  ENDMETHOD.

  METHOD download_file.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.

  DATA : lt_data TYPE STANDARD TABLE OF zc_grc_doc_repo WITH DEFAULT KEY.

  lt_data = CORRESPONDING #( it_original_data ).

  ct_calculated_data = CORRESPONDING #( lt_data ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

ENDCLASS.


