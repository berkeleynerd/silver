#!/usr/bin/env python3
"""Join selected literal frontend tables and physical source backing offline.

This exports named component predicates, not complete frontend/tool capacity.
The companion source argument supplies coverage; checks exercise the arithmetic.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import re
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
PRIOR = E / 'unbounded-programs/retained-native-expansion-20261017'
I32, I64 = 2**31-1, 2**63-1
NUMERIC_KEYS = dict(Uints='Uint_entries', Udigits='Uint_digits', Ureals='Ureal_entries')


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def code_only(raw):
    return re.sub(rb'--[^\r\n]*|"(?:[^"]|"")*"|\'[^\'\r\n]\'', b' ', raw)


def source_object(raw):
    """Separate source buffer and line-array objects, including initial backing."""
    lines = re.split(rb'\r\n|[\r\n]', raw)
    column_maximum = 1
    for line in lines:
        column = 1
        for byte in line:
            column = 8*((column-1+8)//8)+1 if byte == 9 else column+1
        column_maximum = max(column_maximum, column)
    capacity = 500
    while capacity < len(lines):
        capacity *= 2
    checks = dict(source_length_and_EOF=len(raw)+1 <= I32,
        individual_source_buffer=len(raw)+17 <= I64,
        line_capacity_bit_product=32*capacity <= I32,
        line_successor=len(lines)+1 <= I32,
        expanded_column=column_maximum <= 32766,
        no_Source_Reference=not re.search(rb'\bpragma\s+Source_Reference\b', code_only(raw), re.I),
        no_VT_or_FF=11 not in raw and 12 not in raw)
    return dict(**identity(raw), physical_line_entries_bound=len(lines),
        max_expanded_final_column=column_maximum,
        aligned_source_extent=4096*((len(raw)+4096)//4096),
        source_buffer_individual_bytes_upper=len(raw)+17,
        line_table_capacity_bound=capacity, line_table_individual_bytes=4*capacity,
        logical_line_table_objects=0, checks=checks,
        all_selected_checks_pass=all(checks.values()))


def pattern_string_storage(configuration, ada_root):
    """Lifetime String objects; resetting SFN_Patterns does not free pointees."""
    texts = {name:(Path(ada_root)/name).read_text() for name in
             ('fname-uf.adb','frontend.adb','par-prag.adb','table.adb')}
    initialize = texts['fname-uf.adb'].split('procedure Initialize is',1)[1].split('end Initialize;',1)[0]
    defaults = re.findall(r'new String\'\("([^"]*)"\)', initialize)
    calls = sum(texts[name].count('Fname.UF.Initialize;') for name in ('fname-uf.adb','frontend.adb'))
    table_init = texts['table.adb'].split('procedure Init is',1)[1].split('end Init;',1)[0]
    require(defaults == ['*.ads','-','*.adb','-'] and calls == 2 and
            'SFN_Patterns.Init;' in initialize and 'Clear;' in table_init and
            not re.search(r'\b(?:Free|Unchecked_Deallocation)\b', table_init),
            'two source initialization passes, four String objects each, no pointee reclamation')
    for anchor in ('Pat := Get_String_Argument (Arg1);', 'Dot := new String\'(".");',
                   'Dot := Get_String_Argument (Arg);', "return new String'(Name_Buffer (1 .. Name_Len));"):
        require(anchor in texts['par-prag.adb'], 'pattern String source witness: '+anchor)
    patterns = re.findall(rb'pragma\s+Source_File_Name_Project\s*\(\s*(?:Spec|Body)_File_Name\s*=>\s*"([^"]*)"\s*,\s*Casing\s*=>\s*lowercase\s*,\s*Dot_Replacement\s*=>\s*"([^"]*)"\s*\);', configuration)
    require(patterns == [(b'*.ads',b'-'),(b'*.adb',b'-')], 'two exact selected pattern pragmas')
    default_objects, configured_objects = calls*len(defaults), 3*len(patterns)
    maximum_length = max([len(s) for s in defaults]+[len(s) for row in patterns for s in row]+[1])
    return dict(pattern_String_allocations_upper=default_objects+configured_objects,
        pattern_String_individual_bytes_upper=maximum_length+16,
        pattern_String_allocation_rows=dict(default_initialization_calls=calls,
            String_objects_per_initialization=len(defaults), default_lifetime_objects=default_objects,
            configuration_pattern_pragmas=len(patterns), String_objects_per_pattern_pragma=3,
            configuration_delta_objects=configured_objects, reset_reclaims_String_pointees=False))


class Context:
    def __init__(self, ada_root, gcc_root):
        roots = dict(repository=REPO, ada=Path(ada_root))
        self.inputs = read(HERE/'inputs.json')
        self.ada = roots['ada']
        for row in self.inputs['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes()) ==
                    {k:row[k] for k in ('bytes','sha256')}, 'changed input: '+row['path'])
        self.numeric = runpy.run_path(str(E/'retained-literal-ada-numeric-20261018/compose.py'))
        self.numeric_context = self.numeric['Context'](ada_root, gcc_root)
        self.front = self.numeric_context.front
        self.model = self.numeric_context.model
        self.invocation = runpy.run_path(str(E/'retained-literal-invocation-join-20261018/compose.py'))
        self.invocation_context = self.invocation['Context']()
        self.indexed = read(PRIOR/'native-indexed-invocation.json')['indexed_configuration_delta']
        self.indexed_physical = read(PRIOR/'native-indexed-source-buffers.json')
        self.null = runpy.run_path(str(PRIOR/'compose-null-capacity.py'))
        self.runtime = None

    def runtime_inventory(self, directory):
        """Check the complete installed runtime identity once, price each object."""
        if self.runtime is not None:
            require(str(directory) == self.runtime['directory'], 'one selected runtime directory')
            return self.runtime
        rows, manifest = [], []
        for path in sorted(Path(directory).rglob('*')):
            if not path.is_file():
                continue
            raw = path.read_bytes()
            name = path.relative_to(directory).as_posix()
            manifest.append(dict(path=name, **identity(raw), git_blob_sha1=hashlib.sha1(
                b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()))
            rows.append(dict(path=name, **source_object(raw)))
        digest = hashlib.sha256(json.dumps(manifest, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
        expected = self.indexed_physical['native_runtime_inventory']
        require(len(rows) == expected['file_count'] == 1575 and
                digest == expected['manifest_sha256'] and
                sum(r['aligned_source_extent'] for r in rows) == expected['aligned_source_sum'] == 20496384,
                'complete installed runtime identity and aligned union')
        self.runtime = dict(directory=str(directory), file_count=len(rows), manifest_sha256=digest,
            aligned_source_extent=sum(r['aligned_source_extent'] for r in rows),
            source_buffer_individual_bytes_upper=max(r['source_buffer_individual_bytes_upper'] for r in rows),
            line_table_individual_bytes_upper=max(r['line_table_individual_bytes'] for r in rows),
            physical_line_entries_bound_maximum=max(r['physical_line_entries_bound'] for r in rows),
            max_expanded_final_column=max(r['max_expanded_final_column'] for r in rows),
            all_per_source_checks_pass=all(r['all_selected_checks_pass'] for r in rows),
            logical_line_table_objects=0,
            shape_projection_sha256=hashlib.sha256(json.dumps(rows, sort_keys=True,
                separators=(',', ':')).encode()).hexdigest())
        return self.runtime


def bind_descriptor(raw, descriptor_path, context):
    descriptor_path = Path(descriptor_path).resolve()
    selected = read(descriptor_path)
    require(set(selected) == {'scope','core_descriptor','runtime','host_page_bytes'} and
            selected['scope'] == 'selected literal invocation and numeric design route', 'selected descriptor schema')
    core_path = (descriptor_path.parent/selected['core_descriptor']).resolve()
    core = read(core_path)
    require(core['scope'] == 'selected indexed direct literal output research' and
            core['complete_path_bound'] == 512 and selected['host_page_bytes'] == 4096,
            'selected frontend path/page scope')
    invocation = context.invocation['build'](raw, context.invocation_context,
        selected['runtime'], path_bytes=513, host_page_bytes=4096)
    require(invocation['source_identity'] == identity(raw), 'same actual source bytes')
    require(invocation['processes'][0]['child_frontend']['argv_positions_upper'] == 25,
            'selected current gnat1 argument bound')
    files = {row['role']:row for row in invocation['materialization']}
    for phase in ('native','datarep','phase1','phase2'):
        require(core['launch'][phase+'_Main'] == invocation['graph']['Main'], 'same common Main path')
    shared = {}
    for role, name in core['shared_inputs'].items():
        path = (core_path.parent/name).resolve()
        shared[role] = path.read_bytes()
        expected = (invocation['shared_System']['identity'] if role == 'System' else
                    files['naming' if role == 'configuration' else role]['identity'])
        require(identity(shared[role]) == expected, 'same actual shared bytes: '+role)
    require(shared['configuration'] == files['naming']['text'].encode() and
            len(shared['configuration']) == 327, 'exact current configuration')
    require(core['launch']['native_options'] == ['-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types'],
            'selected no-xref frontend switches')
    return core, invocation, files, shared


def physical_sources(raw, files, shared, invocation, context):
    runtime = context.runtime_inventory(Path(invocation['shared_System']['path']).parent)
    extras = dict(Main=source_object(raw), configuration=source_object(shared['configuration']),
        additional_indexed_System=source_object(shared['System']))
    # The native selected no-inline Main route reads imported specifications;
    # the fixed Silver body is materialized but is not a source-load job here.
    for name in ('silver_io.ads','silver_output_libc.ads'):
        extras[name] = source_object(shared[name])
    require(extras['additional_indexed_System']['aligned_source_extent'] == 8192 and
            identity(shared['System']) == {k:context.indexed_physical['additional_System_input'][k]
                for k in ('bytes','sha256')}, 'indexed startup System correction')
    templates = [('libgnat/a-unccon.ads', 7), ('libgnat/s-imagei.ads', 1), ('libgnat/s-imagei.adb', 1)]
    require(context.model['fixed_native_inputs']['fixed_generic_instances'] == 8,
            'accepted fixed spec-instance frontier')
    virtual = []
    for name, count in templates:
        template = source_object((context.ada/name).read_bytes())
        virtual.append(dict(template=name, copies_upper=count,
            aligned_extent_each=template['aligned_source_extent'],
            shared_physical_text_and_line_arrays=True, new_text_or_line_array_objects=0,
            Dope_Rec_metadata_objects_upper=count, Dope_Rec_metadata_storage_priced_here=False))
    physical_count = runtime['file_count']+len(extras)
    virtual_count = sum(row['copies_upper'] for row in virtual)
    permanent = physical_count+virtual_count
    extent = (runtime['aligned_source_extent']+sum(r['aligned_source_extent'] for r in extras.values())+
              sum(r['copies_upper']*r['aligned_extent_each'] for r in virtual))
    require((physical_count,virtual_count,permanent) == (1580,9,1589), 'indexed physical/virtual count')
    table = context.model['native_table_backing_row']
    patterns = context.model['fixed_native_inputs']['fixed_lifetime_table_growth']['fname__uf__sfn_patterns__last_valXn']
    patterns += context.model['native_gpr_naming_configuration']()['SFN_Patterns_entries']
    require(patterns == 6 and context.indexed['SFN_Table_entries'] == 1, 'current source naming table deltas')
    tables = dict(Source_File=table(permanent+1,1,10,200,464,I32),
        Instances=table(1+virtual_count,0,10,200,4,I32),
        SFN_Patterns=table(patterns,1,10,100,64,I32),
        SFN_Table=table(1,0,10,200,12,I32))
    checks = dict(runtime_individual_objects=runtime['all_per_source_checks_pass'],
        extra_individual_objects=all(r['all_selected_checks_pass'] for r in extras.values()),
        source_cursor_and_final_block_increment=extent-1 <= I32-4096,
        source_tables=all(r['all_selected_checks_pass'] for r in tables.values()),
        backend_File_Info_Array=12*permanent+16 <= I64,
        source_file_index_static_array=(2+I32//4096)*4 <= I64)
    return dict(runtime=runtime, extra_physical_objects=extras, virtual_sources=virtual,
        physical_files_upper=physical_count, virtual_files_upper=virtual_count,
        permanent_source_entries_upper=permanent, failed_load_transient_slots_upper=1,
        Source_File_backing_demand=permanent+1, backend_File_Info_entries_upper=permanent,
        insertion_capable_filename_lookups_upper=permanent+1,
        direct_filename_identifier_calls_upper=2*(permanent+1),
        aligned_source_extent=extent, Source_Last_bound=extent-1,
        tables=tables, backend_File_Info_Array_individual_bytes_upper=12*permanent+16,
        Source_File_Index_static_entries=2+I32//4096,
        indexed_SFN_hash_wrapper_bytes=16, indexed_SFN_hash_bucket_array_bytes=808,
        **pattern_string_storage(shared['configuration'], context.ada),
        virtual_source_Dope_Rec_metadata_objects_upper=virtual_count,
        virtual_source_Dope_Rec_metadata_storage_priced_here=False,
        checks=checks, all_selected_checks_pass=all(checks.values()),
        GCC_line_maps_combined_locations_shared_identifiers_and_later_heaps_included=False)


def compose(raw, context, descriptor_path=E/'retained-literal-pipeline-20261018/selected-route.json'):
    core, invocation, files, shared = bind_descriptor(raw, descriptor_path, context)
    front = context.front['compose'](raw, context.model)
    numeric = context.numeric['compose'](raw, context.numeric_context)
    require(front['selected_source'] == invocation['source_counts'] and
            numeric['source']['sha256'] == invocation['source_identity']['sha256'], 'same frontend/numeric/invocation source')
    configuration = context.model['native_configuration_storage'](
        mapping_bytes=files['source_mapping']['text'].encode(), mapping_filename=files['source_mapping']['path'],
        configuration_filename=files['naming']['path'], source_path_files=[], object_path_files=[], pathname_length=512)
    logical = context.model['native_frontend_logical_join'](counts=front['Main_counts'],
        scanner_pools=front['scanner_pools'], max_identifier_length=front['lexemes']['maximum_word_characters'],
        input_identifier_length=1, loop_depth=0, pathname_length=512,
        configuration_storage=configuration, indexed_configuration_delta=context.indexed)
    require(logical['Main_constructor'] == front['Main_constructor'], 'same Main constructor projection')
    base_numeric = {name:logical['tables'][key] for name,key in NUMERIC_KEYS.items()}
    for name in NUMERIC_KEYS:
        pre_callback = sum(numeric['demand_rows'][row][name] for row in
            ('fixed_all_roots_lifetime_allowance','selected_scanner','Main_constructor'))
        require(base_numeric[name] == pre_callback, 'numeric projection before callbacks: '+name)
    # Replace the three projections with the accepted lifetime bound. Do not
    # add its full fixed/Main subtotal to an already charged frontend subtotal.
    joined = copy.deepcopy(logical)
    for name,key in NUMERIC_KEYS.items():
        joined['tables'][key] = numeric['demands'][name]
    require(read(PRIOR/'native-no-xref-proposal.json')['Xrefs_lifetime_appends'] == 0,
            'selected native no-xref route')
    joined['tables']['Xrefs_entries'] = 0
    physical = physical_sources(raw, files, shared, invocation, context)
    names = context.model['native_source_and_frontend_name_backing'](joined, raw)
    nodes = joined['tables']['node_identities']
    gigi_checks = dict(max_gnat_nodes_Argument=0 < nodes <= I32,
        each_association_array_raw_request=8*nodes <= I64,
        selected_frontend_encoded_name=names['selected_frontend_name_buffer_bound'] <= 4096,
        complete_path_spelling_and_NUL=513 <= I32)
    gigi = dict(joined_frontend_node_identities_upper=nodes, association_array_requests=2,
        each_association_array_raw_bytes_upper=8*nodes,
        selected_frontend_encoded_name_bytes_upper=names['selected_frontend_name_buffer_bound'],
        Main_qualified_name_characters_upper=joined['common']['max_qualified_name'],
        fixed_nonpath_name_before_selected_encoding=names['fixed_nonpath_name_before_selected_encoding'],
        all_interned_name_characters_upper=max(joined['fixed']['fixed_Name_buffer_bound'],
            joined['common']['max_qualified_name'], joined['common']['max_unqualified_name'],31),
        complete_path_spelling_characters_upper=512, filename_bytes_including_NUL_upper=513,
        checks=gigi_checks, all_selected_checks_pass=all(gigi_checks.values()),
        GGC_rounding_location_maps_filename_identifier_growth_and_later_name_constructors_included=False)
    components = dict(configuration=configuration,
        core_tables=context.model['native_core_table_backing'](joined),
        parser_auxiliary=context.model['native_parser_auxiliary_backing'](joined),
        invocation=context.model['native_invocation_backing'](joined),
        numeric=numeric, physical_sources=physical, gigi_array_and_name_input=gigi)
    checks = {name:value['all_selected_checks_pass'] for name,value in components.items()}
    return dict(scope='selected literal Main frontend logical/physical/backing component join',
        source=invocation['source_identity'], source_counts=front['selected_source'],
        descriptor_identity=identity(Path(descriptor_path).read_bytes()),
        selected_launch=dict(Main=invocation['graph']['Main'], native=invocation['graph']['native'],
            path_spelling_characters=512, path_bytes_including_NUL=513,
            gnat1_argv_positions_upper=25, fixed_Silver_compile_jobs=0),
        configuration_input_identities={name:identity(raw) for name,raw in shared.items()},
        mapping=dict(path=files['source_mapping']['path'], **identity(files['source_mapping']['text'].encode()),
            records=configuration['mapping_records']),
        frontend_logical_join_before_numeric_callbacks=logical,
        joined_logical_tables=joined['tables'], numeric_base_projection=base_numeric,
        numeric_lifetime_projection=numeric['demands'],
        numeric_added_callback_projection={name:numeric['demands'][name]-base_numeric[name] for name in NUMERIC_KEYS},
        numeric_accounting='Three named table projections replaced by accepted lifetime demands; Rep_Table stays in numeric component only.',
        components=components, component_checks=checks,
        all_selected_component_checks_pass=all(checks.values()),
        exported_source_entry_bounds={key:physical[key] for key in
            ('physical_files_upper','virtual_files_upper','permanent_source_entries_upper',
             'failed_load_transient_slots_upper','Source_File_backing_demand','backend_File_Info_entries_upper',
             'insertion_capable_filename_lookups_upper','direct_filename_identifier_calls_upper')},
        remaining=['Complete combined source locations, ordinary line maps and shared filename identifiers.',
            'Per-virtual-source Dope_Rec metadata allocations (up to nine) outside shared text/line arrays.',
            'Later frontend/warning/ALI/command/name consumers and recursive/local objects outside these named transfers.',
            'All other gigi/GCC/native phases, materializing parent, and independent proof producer.',
            'Aggregate source/path equality attachment and production correspondence/adoption.'],
        complete_native_frontend=False, complete_gigi=False, complete_native_capacity=False,
        whole_toolchain_capacity_established=False, complete_parent_storage=False,
        independent_proof_producer_closed=False, aggregate_attachment_complete=False,
        production_admission_changed=False, aggregate_RAM_or_address_space_gate=False,
        native_tool_executions=0)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--gcc-root', type=Path, required=True)
    parser.add_argument('--descriptor', type=Path, default=E/'retained-literal-pipeline-20261018/selected-route.json')
    parser.add_argument('--source', type=Path, default=REPO/'samples/hello_world.adb')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    context = Context(args.ada_root, args.gcc_root)
    result = compose(args.source.read_bytes(), context, args.descriptor)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(dict(source=result['source'], component_checks=result['component_checks'],
        source_entries=result['exported_source_entry_bounds'], complete_native_capacity=False)))
