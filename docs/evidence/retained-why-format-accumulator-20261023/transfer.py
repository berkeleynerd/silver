"""Source-attached local representation interface; no aggregate resource gate."""
MAX_INT=2**62-1
MAX_STRING=2**57-9
MAX_WOSIZE=2**54-1


def string_layout(n):
    assert type(n) is int and n>=0
    words=(n+8)//8
    offset=words*8-1
    return dict(length_bytes_upper=n,payload_words_upper=words,
                total_object_bytes_upper=8*(words+1),
                last_padding_byte_index_upper=offset,
                guards=dict(length=n<=MAX_STRING,rounding_addition=n+8<=MAX_INT,
                            header_words=words<=MAX_WOSIZE,
                            object_bytes=8*(words+1)<=MAX_INT,
                            padding=0<=offset-n<=7))


def derive(census,providers):
    R=census['conservative_format_tree_and_accumulator_nodes']
    cases=[]
    for case in providers['output']['cases']:
        drivers={}
        for driver,old in case['drivers'].items():
            name=old['printed_name_bytes_upper'];comment=old['raw_comment_name_bytes_upper']
            strings=dict(main_buffer_backing=old['request_buffer']['allocated_capacity_upper'],
                         name_helper_result=name,name_helper_backing=512,
                         raw_comment_escape=4*comment,quoted_comment=4*comment+2,
                         main_single_text_payload=347,native_integer_conversion=21,
                         scalar_padded_result=64,char_result=1,
                         annotation_raw=7,annotation_description=5,annotation_backing=16,
                         annotation_error_message=census['annotation_error_bytes_upper'],
                         annotation_error_backing=256)
            layouts={k:string_layout(v) for k,v in strings.items()}
            drivers[driver]=dict(
                source_format_nodes_and_local_accumulator_nodes_upper=R,
                local_accumulator_descent_frames_upper=R+1,
                fixed_nonstring_payload_words_upper=128,
                fixed_nonstring_object_bytes_upper=1032,
                ordinary_accumulator_payload_words_upper=2,
                fixed_format_constructor_payload_words_upper=4,
                formatter_record_payload_words=28,
                partial_application_closure_payload_words_upper=5,
                dynamic_closure_group_members_upper=3,
                dynamic_closure_captured_slots_upper=16,
                dynamic_source_closure_group_payload_words_upper=28,
                string_objects=layouts,
                scalar_padding_width_range=[0,64],
                scalar_precision_selected=False,
                native_integer_conversion_bytes_upper=21,
                integer_conversion_C_format_buffer_bytes=32,
                integer_conversion_C_output_buffer_bytes=128,
                annotation_parser_length_upper=5,
                annotation_integer_argument_length_upper=1,
                annotation_integer_value_range=[0,2],
                annotation_error_attempts_per_request_upper=1,
                annotation_error_owner='fresh Buffer256, no main/stderr output',
                structural_progress_measure='proper format subtree / accumulator tail, with accepted finite callback tree substituted',
                assumes_each_formatting_call_emits_core_event=False,
                all_local_representation_guards=all(all(x['guards'].values()) for x in layouts.values()),
                structural_progress_under_typed_source_premises=True,
                physical_stack_and_allocator_sufficiency_remain_external=True)
        cases.append(dict(case=case['case'],drivers=drivers))
    return dict(base=census['base'],scope='selected formatting accumulator, local layout and finite progress',
                cases=cases,all_local_representation_guards=all(
                    r['all_local_representation_guards'] for c in cases for r in c['drivers'].values()),
                accumulator_representation_interface_closed_under_retained_premises=True,
                selected_source_native_behavior_premise_required=True,
                source_argument_machine_checked=False,
                physical_stack_sufficiency_proved=False,
                allocator_GC_kernel_service_proved=False,
                total_memory_reservation_claimed=False,
                shared_stderr_whole_interval_closed=False,
                whole_printer_capacity=False,whole_process_capacity=False,
                global_escape_budget=2,save_entering_callbacks=2,saves_upper=3,budget_renewed=False,
                aggregate_RAM_or_stack_gate=False)
