#!/usr/bin/env python3
"""Offline source-to-initial-GIMPLE interface for direct literal output.

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
        local_representation_checks=dict(
            literal_length_fits_String_Length_and_Integer=length<=I32,
            String_constructor_unsigned_size=length+21<=2**32-1,
            Character_array_bit_size_fits_signed64=8*length<=2**63-1,
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
            '5000 calls compose without a new source cap']


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
    result = dict(scope='direct literal output: source to initial GIMPLE and data operands',
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
