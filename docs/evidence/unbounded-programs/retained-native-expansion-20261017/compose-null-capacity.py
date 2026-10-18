#!/usr/bin/env python3
"""Compose selected null-compiler capacity predicates from actual input bytes.

This offline research checker does not launch a tool or change admission. It
accepts only the established null token class and exact indexed configuration.
The supplied complete-path bound remains a parent-invocation premise: checking
the listed paths cannot establish that an upstream producer listed every path.
"""
import argparse
import contextlib
import hashlib
import io
import json
from pathlib import Path
import re
import runpy
import sys
import tempfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
I32, I64 = 2**31-1, 2**63-1
sha = lambda b: hashlib.sha256(b).hexdigest()
NULL_TOKENS = 'procedure main is pragma spark_mode ( on ) ; begin null ; end main ;'.split()
TOKEN = re.compile(rb'[ \t\r\n\v\f]+|--[^\r\n\v\f]*|[A-Za-z][A-Za-z_0-9]*|[();]')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def null_source_counts(raw):
    """Complete byte scan, with Ada CR/LF/VT/FF comment termination."""
    require(bool(raw), 'empty source')
    require(all(32 <= b <= 126 or b in (9,10,11,12,13) for b in raw),
            'source contains a byte outside the selected ASCII class')
    at, tokens, words = 0, [], []
    while at < len(raw):
        m = TOKEN.match(raw, at)
        require(m is not None, f'unsupported source byte at offset {at}')
        token = m[0]; at = m.end()
        if token.isspace() or token.startswith(b'--'):
            continue
        tokens.append(token.decode().lower())
        if re.fullmatch(rb'[A-Za-z][A-Za-z_0-9]*', token):
            words.append(token)
    require(tokens == NULL_TOKENS, 'source is outside the selected null token class')
    # The established parser transfer is identical for every spelling of this
    # token sequence. Scanner nodes use the two-visit allowance; the null and
    # fixed procedure/pragma scaffold contribute eight more ordinary nodes.
    ordinary = 2*len(words)+8
    return dict(tokens=tokens, word_tokens=len(words), word_characters=sum(map(len,words)),
                max_identifier_length=max(map(len,words)), scanner_nodes=2*len(words),
                parser_nodes=ordinary, parser_entities=1,
                parser_slots=9*ordinary+61, parser_lists=4)


def load_model(ada_root):
    """Reuse existing source-checked formulas, preserving their old defaults."""
    old = sys.argv
    with tempfile.TemporaryDirectory(prefix='silver-null-formulas-') as tmp:
        sys.argv = [str(HERE/'derive.py'), str(ada_root), str(Path(tmp)/'prior.json')]
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                return runpy.run_path(str(HERE/'derive.py'))
        finally:
            sys.argv = old


def records():
    identity = json.loads((HERE/'null-capacity-inputs.json').read_bytes())
    values = {}
    for row in identity['files']:
        raw = (HERE/row['path']).read_bytes()
        require(len(raw) == row['bytes'] and sha(raw) == row['sha256'],
                'changed formula/component input: '+row['path'])
        if row['path'].endswith('.json'):
            values[row['path']] = json.loads(raw)
    return identity, values


def current_command(model, pathname_bound):
    """Current indexed argc plus the two selected native-only switches."""
    p = pathname_bound; argc = decoded = 24; canonical = 2*decoded
    arg = max(24,p+8); word = 4*(arg+67)
    objects = dict(original_C_argv=(argc+1)*8, decoded_options=96*decoded,
        pruned_decoded_options=96*decoded, reconstructed_C_argv=(2*decoded+1)*8,
        Ada_argument_pointer_array=(canonical-1)*16+16,
        copied_Ada_argument=arg+16, copied_C_argument=arg+1,
        option_obstack=max(4096,word+116), auxiliary_basename=p+1,
        coverage_filename=2*p+7, working_directory_buffer=max(4097,2*(p+1)),
        Ada_SARIF_filename=p+11+16, indexed_output_name=8+16)
    switches = model['native_table_backing_row'](canonical,1,30,100,16,I32)
    checks = dict(canonical_argv_counter=canonical+1<=I32,
        selected_argument_arithmetic=word+116<=I32,
        coverage_filename_signed_arithmetic=2*p+7<=I32,
        individual_pointer_differences=all(v<=I64 for v in objects.values()),
        Compilation_Switches_table=switches['all_selected_checks_pass'])
    # Charge every canonical argument as a stored switch, including a full
    # pathname-sized spelling and A-record punctuation. This deliberately
    # overcounts flags omitted by Back_End's switch filter, avoiding inheritance
    # of the older six/seven-record ALI constants.
    return dict(selected_native_only_switches=['-gnatx','-Wno-free-nonheap-object'],
        gnat1_argc_bound=argc, decoded_option_count_bound=decoded,
        canonical_save_argc_bound=canonical, largest_argument_characters=arg,
        single_object_bytes=objects, Compilation_Switches_table=switches,
        ALI_A_record_max_characters=arg+4,
        ALI_A_total_bytes_including_LF=canonical*(arg+5), checks=checks,
        all_selected_checks_pass=all(checks.values()))


def physical_source_shape(raw):
    """Native physical lines: FF/VT end comments but do not reset columns.

    Sinput.Skip_Line_Terminators marks FF/VT Physical=False (sinput.adb:887-890).
    Scng preserves Current_Line_Start in that branch (scng.adb:2528-2532), and
    Check_End_Of_Line includes those bytes in the next expanded-column scan.
    This corrects the older generic fixture helper's FF/VT line splitting.
    """
    lines = re.split(rb'\r\n|[\r\n]',raw)
    maximum = 1
    for line in lines:
        column = 1
        for byte in line:
            column = 8*((column-1+8)//8)+1 if byte == 9 else column+1
        maximum = max(maximum,column)
    return dict(physical_line_entries_bound=len(lines), max_expanded_final_column=maximum,
        maximum_line_bytes=max(map(len,lines)), aligned_source_extent=4096*((len(raw)+4096)//4096))


def physical_sources(model, inputs):
    rows = []
    for role, raw in inputs.items():
        shape = physical_source_shape(raw)
        lines = shape['physical_line_entries_bound']; capacity = 500
        while capacity < lines:
            capacity *= 2
        checks = dict(source_length_and_EOF=len(raw)+1<=I32,
            individual_source_buffer=len(raw)+17<=I64,
            line_table_bit_product=32*capacity<=I32,
            expanded_columns=shape['max_expanded_final_column']<=32766,
            gigi_last_logical_line=1<=lines<=2**24)
        rows.append(dict(role=role, bytes=len(raw), sha256=sha(raw), **shape,
                         line_table_capacity=capacity, line_table_bytes=4*capacity,
                         checks=checks))
    extent = sum(r['aligned_source_extent'] for r in rows)
    # Three physical files, no virtual sources. One spare record pays a failed
    # physical load before its immediate Last decrement; the initial instance
    # entry and two fixed naming patterns retain their own tables.
    table = model['native_table_backing_row']
    tables = dict(Source_File=table(4,1,10,200,464,I32),
                  Instances=table(1,0,10,200,4,I32),
                  SFN_Patterns=table(2,1,10,100,64,I32),
                  SFN_Table=table(1,0,10,200,12,I32))
    checks = dict(physical_sources=all(all(r['checks'].values()) for r in rows),
        source_cursor_and_block_increment=extent-1<=I32-4096,
        source_tables=all(r['all_selected_checks_pass'] for r in tables.values()),
        File_Info_Array_individual_object=3*12<=I64)
    return dict(sources=rows, physical_files=3, virtual_sources=0,
        aligned_source_extent=extent, tables=tables, File_Info_Array_bytes=36,
        indexed_SFN_hash_wrapper_bytes=16, indexed_SFN_hash_bucket_bytes=808,
        checks=checks, all_selected_checks_pass=all(checks.values()))


def compose(descriptor_path, model, producer_datarep=False):
    identity, prior = records()
    raw_descriptor = descriptor_path.read_bytes()
    descriptor = json.loads(raw_descriptor)
    require(set(descriptor) == {'scope','files','launch_paths','complete_path_bound'},
            'descriptor fields do not match the scoped schema')
    expected_scope = ('selected indexed producer data representation null compiler'
                      if producer_datarep else 'selected indexed native null compiler')
    require(descriptor['scope'] == expected_scope, 'wrong descriptor scope')
    files = descriptor['files']; launch = descriptor['launch_paths']
    require(set(files) == {'Main','configuration','mapping','System','gnat1'}, 'unexpected file roles')
    required = {'Main','configuration','mapping','System','gnat1','cwd','assembly',
                'native_include','native_objects','raw_default_prefix','source_path_probe','object_path_probe'}
    if producer_datarep:
        required.add('representation_json')
    require(set(launch) == required, 'launch path roles do not match the scoped schema')
    require(all(isinstance(s,str) and s.startswith('/') and
                all(32<=ord(c)<=126 for c in s) for s in launch.values()),
            'every launch path must be an absolute ASCII pathname')
    p = descriptor['complete_path_bound']
    require(type(p) is int and p>=0, 'path bound must be a nonnegative integer')
    require(max(len(s) for s in launch.values())<=p, 'listed raw path exceeds supplied bound')
    require(max(len(str(Path(s).resolve())) for s in launch.values())<=p,
            'listed normalized/resolved path exceeds supplied bound')
    require(Path(launch['Main']).name == 'main.adb', 'Main launch basename must be main.adb')
    require(Path(launch['System']).name == 'system.ads', 'System launch basename must be system.ads')
    if producer_datarep:
        require(Path(launch['representation_json']) == Path(launch['cwd'])/'main.adb.json',
                'wrong selected representation JSON pathname')
        require(Path(launch['assembly']) == Path(launch['cwd'])/'main~1.o',
                'wrong selected data-representation assembly pathname')
    require(Path(launch['source_path_probe']).name == 'ada_source_path' and
            Path(launch['object_path_probe']).name == 'ada_object_path', 'wrong default search probes')
    loaded = {role:(descriptor_path.parent/name).read_bytes() for role,name in files.items()}
    expected_compiler = ('5e93a62546d5538c3744c04c1b5989dc248f4a90ff47f6ea2f2d0bf3e2e2e1f6'
                        if producer_datarep else prior['native-gcc-prefix-witness.json']['gnat1_sha256'])
    require(sha(loaded['gnat1']) == expected_compiler,
            'gnat1 differs from the supported executable')
    system = prior['native-indexed-source-buffers.json']['additional_System_input']
    require(len(loaded['System']) == system['bytes'] and sha(loaded['System']) == system['sha256'],
            'System differs from the pinned native input')
    base = REPO/'docs/evidence/unbounded-programs/retained-source-closure-20261017/driver-snapshots/293256/GNAT-TEMP-000002.TMP'
    expected_configuration = base.read_bytes()+(HERE/'indexed-naming-pragma-derived.adc').read_bytes()
    require(loaded['configuration'] == expected_configuration, 'configuration is not the exact reviewed indexed form')
    require(loaded['mapping'] == f"main%b\nmain.adb\n{launch['Main']}\n".encode(),
            'mapping is not the single exact Main unit/basename/launch-path triple')
    lexical = null_source_counts(loaded['Main'])
    counts = dict(model['main_example_counts'])
    for key in ('parser_nodes','parser_slots','parser_lists','parser_entities','word_tokens'):
        counts[key] = lexical[key]
    pools = dict(Name_entries=lexical['word_tokens'],
        Name_characters=lexical['word_characters']+lexical['word_tokens'],
        Uint_entries=0, Uint_digits=0, String_descriptors=0, String_characters=0)
    configuration = model['native_configuration_storage'](
        mapping_bytes=loaded['mapping'], mapping_filename=launch['mapping'],
        configuration_filename=launch['configuration'], source_path_files=[],
        object_path_files=[], pathname_length=p)
    delta = prior['native-indexed-invocation.json']['indexed_configuration_delta']
    logical = model['native_frontend_logical_join'](counts=counts, scanner_pools=pools,
        max_identifier_length=lexical['max_identifier_length'], input_identifier_length=1,
        loop_depth=0, pathname_length=p, configuration_storage=configuration,
        indexed_configuration_delta=delta)
    if producer_datarep:
        # Create_Repinfo_File and Create_Auxiliary_File each call Name_Find.
        # Even charge the existing Main basename as fresh; the output-name
        # role is covered by P. Namet is unlocked before this late output.
        logical['tables']['Name_entries'] += 2
        logical['tables']['Name_characters'] += 2*(p+1)
    # The selected native-only -gnatx disables recording/output, not semantic
    # reference marking. Keep the common semantic transfer and initialized
    # table/hash backing while setting only the actual appended entry count.
    require(prior['native-no-xref-proposal.json']['Xrefs_lifetime_appends'] == 0,
            'changed selected no-xref transfer')
    logical['tables']['Xrefs_entries'] = 0
    # Join the actual extra fixed floating callback allowances before pricing
    # the mutable Ada tables. The retained all-roots frontend constant may
    # already contain some; adding them again is intentional overcount.
    floating = prior['native-null-callback-collector.json']['Ada_callbacks']['fixed_float_transfer']
    for key, extra in [('Uint_entries','Uint_appends'),('Uint_digits','Udigit_word_appends'),
                       ('Ureal_entries','Ureal_appends')]:
        logical['tables'][key] += floating[extra]
    diagnostic = model['native_diagnostic_metadata'](0,0)
    command = current_command(model,p)
    if producer_datarep:
        # Same conservative argv/backing bound, with the separately derived
        # 19-argument GCC / 23-entry gnat1 descriptor. The alternate fixed
        # prefix is checked by the producer wrapper, not inferred from a
        # version string or the native executable's witness.
        command.pop('selected_native_only_switches')
        command['selected_datarep_switches'] = [
            '-S','-gnatR2js','-gnatws','-gnatx','-gnatis','-Wno-free-nonheap-object']
    components = dict(
        configuration=configuration,
        core_tables=model['native_core_table_backing'](logical),
        parser_auxiliary=model['native_parser_auxiliary_backing'](logical),
        physical_sources=physical_sources(model,{k:loaded[k] for k in ('Main','configuration','System')}),
        diagnostic_backing=model['native_diagnostic_backing'](diagnostic),
        diagnostic_rendering=model['native_diagnostic_rendering'](diagnostic,p),
        invocation=model['native_invocation_backing'](logical),
        command=command,
        ALI=model['native_ali_backing'](logical,lexical['max_identifier_length'],command,False),
        local_numeric=model['native_local_numeric_and_concat_backing'](logical,[]))
    # This existing helper also returns a conservative all-roots physical
    # inventory. Only its independent selected frontend-name bound is reused;
    # actual null physical sources were computed from the three bytestrings.
    names = model['native_source_and_frontend_name_backing'](logical,loaded['Main'])
    n = logical['tables']['node_identities']
    loc = prior['native-null-source-locations.json']
    metadata_checks = dict(
        frontend_encoded_name=names['selected_frontend_name_buffer_bound']<=4096,
        filename_identifier_length=p<=loc['identifier_length_existing_requirement'],
        max_gnat_nodes_argument=0<n<=I32,
        association_array_individual_request=8*n<=I64,
        shared_identifier_occupancy=loc['shared_identifier_insertions_at_most']<65536*3//4,
        ad_hoc_location_occupancy=loc['ad_hoc_location_requests_at_most']<127*3//4)
    components['gigi_metadata'] = dict(node_count=n, each_association_array_raw_bytes=8*n,
        selected_frontend_encoded_name_bytes=names['selected_frontend_name_buffer_bound'],
        filename_spellings_at_most=4, filename_bytes_including_NUL=p+1,
        shared_identifier_table_bytes=524288, ordinary_line_map_vector_raw_bytes=8192,
        ad_hoc_backing_raw_bytes=5120, checks=metadata_checks,
        all_selected_checks_pass=all(metadata_checks.values()))
    callback = prior['native-null-callback-collector.json']
    components['remaining_fixed_callbacks'] = dict(
        Rep_Table=callback['Ada_callbacks']['table_backing_checks']['Rep_Table'],
        UI_Ints_wrapper_bytes=16, UI_Ints_static_bucket_bytes=8184,
        all_selected_checks_pass=callback['Ada_callbacks']['table_backing_checks']['Rep_Table']['all_selected_checks_pass'])
    collector = prior['native-collector-closure.json']
    lifecycle = prior['native-static-lifecycle.json']
    require(lifecycle['known_GGC_subtotal_unchanged'] == 40098, 'changed lifecycle event bound')
    require(loc['updated_selected_known_GGC_subtotal'] == 40098, 'changed metadata event bound')
    checks = {name:value['all_selected_checks_pass'] for name,value in components.items()}
    result = dict(scope='selected native-null compiler component composition',
        descriptor_sha256=sha(raw_descriptor), source_counter_kind='complete restricted null-token scan',
        inputs={role:dict(bytes=len(raw),sha256=sha(raw),launch_path=launch.get(role))
                for role,raw in loaded.items()}, supplied_complete_path_bound=p,
        formula_and_component_inputs_verified=len(identity['files']), source_counts=lexical,
        logical_table_demands=logical['tables'], fixed_indexed_delta=delta,
        components=components, component_checks=checks,
        all_selected_compiler_component_predicates_pass=all(checks.values()),
        GCC_GGC_events_upper_under_selected_read_projection=40098,
        collector_backing=collector['collector_backing_substitution'],
        fixed_ordinary_startup_basis=lifecycle['fixed_ordinary_prefix_capacity_basis'],
        static_exit_new_GGC_events=0, static_exit_new_ordinary_requests=0,
        external_prerequisites=[
            'Parent constructs the selected indexed argc/options/environment and binds the launch files to these bytes',
            'Supplied P covers every raw/normalized/resolved generated/default-search path, including unlisted parent-created paths',
            'Selected effective source/object search has no ada_source_path/ada_object_path file or unlisted alias/override',
            'Existing supported-host allocator, library and OS interface assumptions',
            'GPR/GCC parent process, assembler, binder/linker and independent GNATprove producer composition',
            'Production source-counter/recognizer/proof correspondence before any admission change'],
        whole_toolchain_capacity_established=False, production_admission_changed=False,
        aggregate_RAM_or_address_space_admission_gate=False,
        compiler_prover_debugger_executions=0)
    if producer_datarep:
        result['scope'] = 'selected producer data-representation null compiler component composition'
        result['representation_output'] = dict(file_bytes=4, array_entries=0,
            maximum_payload_line=1, additional_Name_find_requests=2,
            additional_Name_entries=2, additional_Name_characters=2*(p+1),
            independent_source_reasoning_required=True)
        result['external_prerequisites'][4] = (
            'GPR/GCC parent process and remaining GNATprove frontend/report/server composition; '
            '-S selects no assembler, binder or linker in this process')
        result['alternate_fixed_prefix_checked_by_wrapper'] = True
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--descriptor',type=Path,required=True)
    p.add_argument('--ada-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    result = compose(a.descriptor,load_model(a.ada_root))
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'source_bytes':result['inputs']['Main']['bytes'],
        'component_checks':result['component_checks'],
        'whole_toolchain_capacity_established':False}))


if __name__ == '__main__':
    main()
