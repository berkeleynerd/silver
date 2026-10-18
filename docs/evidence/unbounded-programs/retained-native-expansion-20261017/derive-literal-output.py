#!/usr/bin/env python3
"""Offline direct literal output interface through conditional pass_expand output.

The source argument in retained-native-expansion.md supplies reachability and
helper behavior. This checker verifies inputs, scans a restricted source class
completely and composes that argument's counts. It does not execute GNAT or
claim whole-backend capacity, final emitted bytes, or language membership.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
TOKEN = re.compile(rb'[ \t\r\n\v\f]+|--[^\r\n\v\f]*|"(?:[ !#-~]|"")*"|[A-Za-z][A-Za-z_0-9]*|[().;]')
PREFIX = 'with silver_io ; procedure main is pragma spark_mode ( on ) ; begin'.split()
SUFFIX = 'end main ;'.split()
I32 = 2**31-1
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def require(value, message):
    if not value:
        raise ValueError(message)


def source_counts(raw):
    require(bool(raw), 'empty input')
    require(all(32<=b<=126 or b in (9,10,11,12,13) for b in raw), 'unsupported source byte')
    tokens = []; at = 0
    while at < len(raw):
        match = TOKEN.match(raw, at)
        require(match is not None, f'unsupported token at byte {at}')
        token = match[0]; at = match.end()
        if token.isspace() or token.startswith(b'--'):
            continue
        tokens.append(token if token.startswith(b'"') else token.decode().lower())
    require(tokens[:len(PREFIX)] == PREFIX and tokens[-len(SUFFIX):] == SUFFIX,
            'source is outside the selected literal-output shell')
    body = tokens[len(PREFIX):-len(SUFFIX)]
    require(bool(body), 'empty statement sequence')
    at = 0; lengths = []; calls = []; nulls = 0
    while at < len(body):
        if body[at:at+2] == ['null',';']:
            nulls += 1; at += 2
            continue
        require(at+7<=len(body) and body[at:at+2] == ['silver_io','.']
                and body[at+2] in ('put','put_line') and body[at+3] == '('
                and isinstance(body[at+4],bytes) and body[at+5:at+7] == [')',';'],
                'only qualified direct-literal Put/Put_Line and null statements are selected')
        literal = body[at+4][1:-1].replace(b'""',b'"')
        lengths.append(len(literal)); calls.append(body[at+2]); at += 7
    require(bool(calls), 'selected output family requires at least one output call')
    return dict(source_bytes=len(raw), source_sha256=sha(raw),
                output_calls=len(calls), Put=calls.count('put'), Put_Line=calls.count('put_line'),
                null_statements=nulls, decoded_literal_lengths=lengths,
                decoded_literal_bytes=sum(lengths), maximum_literal_length=max(lengths))


def composition(counts):
    c = counts['output_calls']; n = counts['null_statements']
    w = counts['decoded_literal_bytes']; length = counts['maximum_literal_length']
    uses = 3*c+1
    chain = 7*c+3*n+12
    operand_occurrences = 64*c+n+16
    return dict(
        native_Main=dict(procedure_bodies=1, implicit_bare_returns=1,
            String_literal_subtypes=c, call_markers=c, transient_blocks=0,
            secondary_stack_marks_or_releases=0, finalizer_bodies=0,
            generated_native_temporary_objects=0),
        gigi_payload_and_descriptors=dict(String_lowering_events=c,
            String_node_requested_bytes=w+21*c, each_literal_scratch_bytes=length,
            bounds_CONSTRUCTOR_requests=c, fat_pointer_CONSTRUCTOR_requests=c,
            descriptor_constructor_element_positions=4*c,
            each_bounds_record_bytes=8, each_fat_descriptor_bytes=16,
            literal_payload_bytes=w, bounds_payload_bytes=8*c,
            final_emitted_pool_bytes_claimed=False),
        initial_GIMPLE=dict(direct_calls=c, pointer_field_stores_upper=2*c,
            null_gotos_upper=n, null_labels_upper=n, bare_returns_upper=1,
            flat_executable_statements_upper=3*c+2*n+1,
            raw_statement_operand_positions_upper=8*c+2*n+1,
            descriptor_temporary_VAR_DECLs_upper=c, each_descriptor_bytes=16,
            source_BIND_cleanup_regions=0, local_EH_regions=0,
            variable_size_temporaries=0, implicit_bulk_memory_calls=0,
            static_bounds_pool_requests_upper=c,
            initial_scalar_SSA_names_from_actuals=0),
        CF_EH_CFG=dict(
            flat_CF_statements_upper=3*c+2*n+3,
            CF_new_gotos=1, CF_new_labels=1, CF_new_LABEL_DECLs=1,
            local_declarations_upper=c, finally_tree_label_entries_upper=n+1,
            local_EH_regions=0, EH_temporary_assignments=0,
            call_control_flow_splits=0, abnormal_edges=0,
            ordinary_blocks_upper=n+2, edges_upper=n+3,
            block_index_slots_upper=n+4, label_UID_requests_upper=n+1,
            live_CFG_statements_upper=3*c+n+2,
            initial_CFG_cleanup_fresh_statements=0,
            first_fixup_fresh_statements=0, real_loops=0),
        initial_SSA=dict(
            memory_declarations=1, renamed_variables=1,
            memory_definitions_upper=3*c, memory_uses_upper=uses,
            real_definitions=0, real_uses=0, PHIs=0,
            default_memory_names=1, default_definition_detached_NOPs=1,
            nondefault_memory_names_upper=3*c,
            fresh_SSA_names_upper=3*c+1, SSA_name_vector_length_upper=3*c+2,
            new_executable_statements=0,
            local_declaration_hash_initial_request_upper=c,
            reaching_definition_stack_pushes_upper=n+4+6*c,
            operand_slab_requested_bytes_upper=(1024+(4096 if uses>25 else 0)
                +16384*((max(0,uses-127)+408)//409))),
        conditional_O0_out_of_SSA=dict(
            requires_selected_options_and_whole_unit_Main_preservation=True,
            ordinary_blocks_upper=n+2, edges_upper=n+3,
            block_index_slots_upper=n+4,
            live_GIMPLE_statements_upper=3*c+n+2,
            SSA_name_vector_length_upper=3*c+2,
            descriptor_local_declarations_upper=c,
            descriptor_alignment_bytes_upper=16,
            prefilter_partition_extent_upper=3*c+2,
            ordinary_block_pointer_vector_length_upper=n+2,
            real_partitions=0, SSA_lowering_fresh_statements=0,
            SSA_lowering_fresh_real_pseudos=0, RTL_PHI_copies=0,
            expression_and_call_RTL_pseudo_bound_established=True,
            whole_unit_IPA_allocation_and_counter_join_established=False),
        conditional_native_pass_expand=dict(
            requires_selected_options_and_whole_unit_Main_preservation=True,
            boundary='after pass_expand execute; before virtual register instantiation',
            descriptor_TI_pseudos_upper=c, extraction_DI_pseudos_upper=2*c,
            fresh_dynamic_pseudos_upper=3*c, first_unused_pseudo_number_upper=98+3*c,
            descriptor_subreg_byte_offsets=[0,8], descriptor_subreg_mode='DI',
            DI_move_instructions_upper=6*c, direct_void_calls=c,
            ordinary_blocks_upper=n+4, edges_upper=n+5,
            block_index_slots_upper=n+6,
            CODE_LABEL_lifetime_requests_upper=n+2,
            NOTE_lifetime_requests_upper=n+6,
            ordinary_INSN_lifetime_requests_upper=6*c+n+4,
            CALL_INSN_lifetime_requests_upper=c,
            instruction_chain_lifetime_requests_upper=chain,
            first_unused_instruction_UID_upper=chain+1,
            live_nonchain_RTL_occurrences_upper=operand_occurrences,
            live_RTL_occurrences_including_chain_upper=chain+operand_occurrences,
            maximum_one_instruction_operand_note_usage_occurrences=16,
            maximum_operand_tree_depth=4,
            initial_local_stack_payload_bytes=0, outgoing_argument_stack_bytes=0,
            descriptor_nominal_payload_bytes=16*c,
            jump_instructions=0, local_EH_edges=0, dynamic_stack_operations=0,
            descriptor_cross_call_liveness_excluded=False,
            allocation_or_frame_bound_established=False,
            all_RTX_rtvec_lifetime_requests_bound_established=False),
        local_representation_checks=dict(
            literal_length_fits_String_Length_and_Integer=length<=I32,
            String_constructor_unsigned_size=length+21<=2**32-1,
            Character_array_bit_size_fits_signed64=8*length<=2**63-1,
            CFG_SSA_dominator_signed_intermediates=4*(n+4)<=I32,
            initial_SSA_name_versions_fit_unsigned32=3*c+2<=2**32-1,
            out_of_SSA_partition_extent_fits_signed_int=3*c+2<=I32,
            pass_expand_pseudo_number_fits_signed_int=98+3*c<=I32,
            pass_expand_instruction_UID_fits_signed_int=chain+1<=I32,
            pass_expand_block_index_fits_signed_int=n+6<=I32,
            descriptor_objects_have_fixed_size=True),
        semantic_library_admissibility='separate parameter; current 4096-byte rule is not promoted into this backend bound',
        later_GIMPLE_IPA_RTL_allocation_and_counter_composition_established=False,
        final_assembly_and_ELF_object_envelope_established=False,
        whole_native_backend_capacity_established=False,
        production_admission_changed=False)


def focused_checks():
    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '
    tail = b' end Main;'
    raw = shell+b'Silver_IO.Put ("a""b"); null; Silver_IO.Put_Line ("");'+tail
    c = source_counts(raw)
    assert (c['output_calls'],c['null_statements'],c['decoded_literal_lengths']) == (2,1,[3,0])
    assert composition(c)['initial_GIMPLE']['flat_executable_statements_upper'] == 9
    assert composition(c)['CF_EH_CFG']['flat_CF_statements_upper'] == 11
    assert composition(c)['CF_EH_CFG']['ordinary_blocks_upper'] == 3
    assert composition(c)['initial_SSA']['fresh_SSA_names_upper'] == 7
    rtl = composition(c)['conditional_native_pass_expand']
    assert (rtl['fresh_dynamic_pseudos_upper'],
            rtl['instruction_chain_lifetime_requests_upper'],
            rtl['live_nonchain_RTL_occurrences_upper']) == (6,29,145)
    assert rtl['ordinary_blocks_upper'] == 5 and rtl['edges_upper'] == 6
    limit = (I32-13)//7
    at_limit = dict(c, output_calls=limit, null_statements=0)
    above = dict(at_limit, output_calls=limit+1)
    assert composition(at_limit)['local_representation_checks']['pass_expand_instruction_UID_fits_signed_int']
    assert not composition(above)['local_representation_checks']['pass_expand_instruction_UID_fits_signed_int']
    for uses, expected in [(25,1024),(28,5120),(127,5120),(130,21504)]:
        artificial = dict(c,output_calls=(uses-1)//3)
        assert composition(artificial)['initial_SSA']['operand_slab_requested_bytes_upper'] == expected
    for statement in [b'Silver_IO.Put ("a" & "b");',b'Silver_IO.Put (X);',
                      b'for I in 1..2 loop null; end loop;', b'null;']:
        try:
            source_counts(shell+statement+tail)
        except ValueError:
            pass
        else:
            raise AssertionError('unsupported shape accepted')
    for end in [b'\r',b'\n',b'\v',b'\f',b'\r\n']:
        with_comment = b'-- ignored tokens "not a literal"'+end+raw+b'-- EOF comment'
        d = source_counts(with_comment)
        assert d['decoded_literal_lengths'] == [3,0]
    many = source_counts(shell+b'Silver_IO.Put ("x");'*5000+tail)
    assert many['source_bytes']>4096 and many['output_calls'] == 5000
    assert composition(many)['initial_GIMPLE']['flat_executable_statements_upper'] == 15001
    return ['complete restricted source scan', 'decoded quotes and empty literal',
            'unsupported constructs rejected', 'comment terminators and EOF',
            '5000 calls compose without a new source cap',
            'CF CFG SSA source count composition', 'SSA operand slab transitions',
            'pass_expand shape and signed instruction UID boundary']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--gcc-root',type=Path,required=True)
    p.add_argument('--ada-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    roots = {'gcc':a.gcc_root,'ada':a.ada_root,'silver':HERE.parents[3]}
    identity = json.loads((HERE/'literal-output-source-inputs.json').read_bytes())
    for row in identity['files']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        require(len(raw)==row['bytes'] and sha(raw)==row['sha256'], 'changed source: '+row['path'])
    counts = source_counts(a.source.read_bytes())
    result = dict(scope='direct literal output: source through conditional pass_expand output and data operands',
        source_files_verified=len(identity['files']), source_counts=counts,
        components=composition(counts), focused_checks=focused_checks(),
        native_tool_executions=0,
        arithmetic_requires_companion_manual_source_argument=True)
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(calls=counts['output_calls'], literal_bytes=counts['decoded_literal_bytes'],
        initial_GIMPLE_bound=result['components']['initial_GIMPLE']['flat_executable_statements_upper'],
        whole_native_backend_capacity_established=False)))


if __name__ == '__main__':
    main()
