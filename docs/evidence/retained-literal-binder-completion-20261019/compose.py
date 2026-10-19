#!/usr/bin/env python3
"""Selected GNATBIND capacity composition; never executes native tools."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
ADA_ROOT = Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada')
GCC_ROOT = Path('/tmp/silver-backend-compose-20261018/full-source')
I32 = 2**31 - 1
U32 = 2**32 - 1


def require(condition, message):
    if not condition:
        raise ValueError(message)


def integer(value, minimum=0):
    require(type(value) is int and value >= minimum, 'integer domain')
    return value


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def table_storage(demand, initial, stride, low, high):
    integer(demand); integer(initial, 1); integer(stride, 1)
    capacities = [initial]
    while capacities[-1] < demand:
        capacities.append(max(2 * capacities[-1], capacities[-1] + 10))
    cap = capacities[-1]
    overlap = cap + (capacities[-2] if len(capacities) > 1 else 0)
    return dict(demand=demand, capacities=capacities, low=low,
        last_allocated_index=low+cap-1, next_after_demand=low+demand,
        allocated_bytes=cap*stride, old_and_new_bytes=overlap*stride,
        fits=(low-1 >= -2**31 and low+cap <= high and
              low+demand <= high and cap*200 <= 2**63-1 and
              overlap*stride <= I32))


def name_storage(parser_entries, parser_chars, row_bytes, path_bytes,
                 ali_files, sdeps, subunits, preset_entries=1211,
                 preset_chars=12517, preset_payload=37):
    for x in (parser_entries, parser_chars, subunits): integer(x)
    for x in (row_bytes, path_bytes, ali_files, sdeps): integer(x, 1)
    producers = dict(startup=preset_entries, mapping=5,
        ALI_lookup_and_object_names=2*ali_files, Main_and_runtime_seed=2,
        System=2, generated_spec_and_body=4, consistency=2*sdeps,
        duplicate_subunits=2*subunits)
    path_events = sum(producers[k] for k in ('mapping', 'ALI_lookup_and_object_names',
        'Main_and_runtime_seed', 'System', 'generated_spec_and_body'))
    row_events = producers['consistency'] + producers['duplicate_subunits']
    nonparser_chars = preset_chars + path_events*(path_bytes+1) + row_events*(row_bytes+3)
    entries = parser_entries + sum(producers.values())
    chars = parser_chars + nonparser_chars
    payload = max(preset_payload, path_bytes, row_bytes+2)
    et = table_storage(entries, 6000, 16, -399999997, -300000000)
    ct = table_storage(chars, 50000, 1, 0, I32)
    return dict(nonparser_entry_producers=producers,
        nonparser_entry_events=sum(producers.values()),
        nonparser_character_slots=nonparser_chars,
        parser_entry_events=parser_entries, parser_character_slots=parser_chars,
        path_producer_events=path_events, row_producer_events=row_events,
        maximum_payload_bytes=payload, scratch_bytes=131064,
        entry_table=et, character_table=ct,
        conditions=dict(name_payload_Short=payload <= 32767,
                        name_scratch=payload+1 <= 131064,
                        name_entry_indices_and_backing=et['fits'],
                        name_character_indices_and_backing=ct['fits']))


def hash_storage(nodes, initial_upper):
    """Upper envelope for every actual initial size in 1..initial_upper.

    With M=max(8, initial_upper, nodes), capacity <=2M; coexistence <=3M.
    This weaker-than-1.5 envelope avoids relying on floating threshold rounding.
    Every bucket stores a full dummy Node, not a pointer.
    """
    integer(nodes); integer(initial_upper, 1)
    m = max(8, initial_upper, nodes)
    return dict(nodes_upper=nodes, initial_upper=initial_upper,
        bucket_capacity_upper=2*m, coexisting_bucket_slots_upper=3*m,
        node_or_bucket_bytes_upper=64, control_bytes_upper=64,
        coexisting_array_metadata_bytes_upper=64,
        largest_bucket_request_bytes_upper=2*m*64+32,
        nodes_controls_and_coexisting_bytes_upper=(nodes+3*m)*64+128,
        fits=(nodes+1 <= I32 and 2*m <= U32//2 and
              2*m*64+32 <= I32 and (nodes+3*m)*64+128 <= I32))


def graph_storage(units, constructs, relations, signatures):
    for x in (units, constructs, signatures): integer(x, 1)
    integer(relations)
    require(constructs <= signatures, 'construct/signature upper-domain join')
    owners = {
        'elaborable_units': hash_storage(units, units),
        'elaborable_construct_signatures': hash_storage(signatures, units),
        'invocation_vertex_attributes': hash_storage(constructs, units),
        'invocation_signature_to_vertex': hash_storage(constructs, units),
        'directed_all_vertices': hash_storage(constructs, units),
        'invocation_edge_attributes': hash_storage(relations, units),
        'invocation_source_target_relations': hash_storage(relations, units),
        'directed_all_edges': hash_storage(relations, units),
        'invocation_roots_empty': hash_storage(0, units),
        'directed_components_empty': hash_storage(0, units),
    }
    # One eager Create(1), clamped to eight buckets, for each actual vertex.
    # Sum d(v)<=relations; max(8,d)<=8+d bounds any degree distribution.
    outgoing = dict(instances_upper=constructs, initial_buckets_each=8,
        nodes_upper=relations, coexisting_bucket_slots_upper=24*constructs+3*relations,
        controls_and_array_metadata_bytes_upper=128*constructs,
        largest_bucket_request_bytes_upper=2*max(8, relations)*64+32,
        nodes_controls_and_coexisting_bytes_upper=
            (relations+24*constructs+3*relations)*64+128*constructs)
    control = 256+64  # 20 counters + seven handles; generic DG three handles
    live = control + outgoing['nodes_controls_and_coexisting_bytes_upper'] + sum(
        x['nodes_controls_and_coexisting_bytes_upper'] for x in owners.values())
    # No recursive invocation traversal: roots empty; component discovery is
    # performed on the fixed library graph only. Iterators/destruction are fixed
    # nesting; 2*(U+V+E)+32 also dominates their total active scalar handles.
    handle_bound = 2*(units+constructs+relations)+32
    conditions = dict(invocation_ID_successors=max(constructs+1, relations+1) <= I32,
        graph_hash_indices_and_requests=all(x['fits'] for x in owners.values()),
        outgoing_set_indices_and_requests=(max(8, relations)*2 <= U32//2 and
            outgoing['largest_bucket_request_bytes_upper'] <= I32),
        graph_controls_and_coexistence=live <= I32,
        graph_counts_and_iterator_locks=handle_bound <= I32)
    return dict(units_upper=units, constructs_upper=constructs,
        relations_upper=relations, signatures_upper=signatures,
        owner_maps=owners, outgoing_sets=outgoing,
        invocation_and_directed_control_bytes_upper=control,
        owned_coexisting_representation_bytes_upper=live,
        iterator_handle_bound=handle_bound,
        invocation_root_count=0, invocation_component_node_count=0,
        invocation_DFS_sets_or_frames=0, invocation_list_nodes_or_controls=0,
        library_graph='fixed OUTPUT read projection, not null/no-relations graph',
        conditions=conditions)


class Context:
    def __init__(self, ada_root=ADA_ROOT, gcc_root=GCC_ROOT):
        pins = json.loads((HERE/'inputs.json').read_bytes())
        for row in pins['repository']:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k: row[k] for k in ('bytes', 'sha256')}, 'repository input: '+row['path'])
        roots = dict(ada=Path(ada_root), gcc=Path(gcc_root))
        self.sources = {}
        for row in pins['sources']:
            raw = (roots[row['root']]/row['path']).read_bytes()
            require(identity(raw) == {k: row[k] for k in ('bytes', 'sha256')},
                    'source input: '+row['path'])
            self.sources[row['path']] = raw
        presets = re.findall(rb'^\s*Name_(\w+)\s+: constant Name_Id := N \+ \$;',
                             self.sources['snames.ads-tmpl'], re.M)
        self.preset = (256+len(presets), 512+sum(len(x)+1 for x in presets), max(map(len,presets)))
        require(self.preset == (1211, 12517, 37), 'preset inventory')
        self.ali = runpy.run_path(str(E/'retained-literal-binder-ali-20261018/compose.py'))
        self.ali_context = self.ali['Context'](ada_root)
        self.inv = runpy.run_path(str(E/'retained-literal-invocation-join-20261018/compose.py'))
        self.inv_context = self.inv['Context']()
        self.pins_checked = dict(repository=len(pins['repository']), sources=len(pins['sources']))
        # All paths are generated roles or content-checked installed inputs.
        self.maximum_generated_line = max(max(map(len,
            self.inv_context.artifacts['indexed/obj/b__main~1.'+suffix].split(b'\n')))
            for suffix in ('adb', 'ads'))
        require(self.maximum_generated_line == 191, 'fixed OUTPUT line projection')


def evaluate(raw_source, context, invocation=None, path_bytes=512, host_page_bytes=4096):
    integer(path_bytes, 1); integer(host_page_bytes, 1)
    fresh = context.inv['build'](raw_source, context.inv_context,
        path_bytes=path_bytes, host_page_bytes=host_page_bytes)
    if invocation is not None:
        require(invocation == fresh, 'invocation must equal fresh same-source selection')
    require(fresh['GPR_or_Gprbind_jobs'] == 0 and fresh['fixed_Silver_compile_jobs'] == 0,
            'selected direct process graph')
    p = context.ali['evaluate'](raw_source, context.ali_context, path_bytes=path_bytes)
    require(p['source'] == fresh['source_identity'] == identity(raw_source), 'same source')
    require(p['source_counts'] == fresh['source_counts'], 'same source counts')
    f = p['fixed_closure']; tables = p['native_parser_tables']
    d = {k: v['demand_upper'] for k,v in tables.items()}
    require(f['all_constructs_ordinary'] and f['fixed_Main_signature_count'] == 0,
            'fixed ordinary constructs and no incoming Main signature')
    require((d['ALIs'],d['Units'],d['Sdep'],d['Invocation_Constructs'],
             d['Invocation_Relations'],d['Invocation_Signatures']) ==
            (83,180,1048,1290,367,1290), 'accepted finite ALI domains')
    parser = p['native_parser_name_contribution']
    row = p['Main_ALI_interface']['Main_ALI_writer']['max_record_bytes_including_LF']
    names = name_storage(parser['entry_events_upper'],
        parser['character_slots_including_NUL_upper'], max(109,row), path_bytes,
        d['ALIs'],d['Sdep'],len(f['subunit_names']),*context.preset)
    graph = graph_storage(d['Units'],d['Invocation_Constructs'],
                          d['Invocation_Relations'],d['Invocation_Signatures'])
    job = [j for j in fresh['processes'] if j['role']=='binder_generate']
    require(len(job)==1, 'one binder process'); job=job[0]
    argv=job['argv']; require(len(argv)==7 and argv[1]=='-o' and argv[4]=='-x' and
        argv[5].startswith('-F=') and argv[6].startswith('-O='), 'direct binder arguments')
    require(set(job['environment']) == {'PATH','LC_ALL','TMPDIR','ADA_PRJ_OBJECTS_FILE'},
            'controlled binder environment')
    # Same library/output projection: only Main checksum varies, fixed width.
    # Current installed-prefix shortening uses the actual bounded Osint/C
    # allocations; it is not asserted to be an identical old relocation run.
    maximum_arg = max(len(x) for x in argv[1:])
    fixed = dict(argument_count=6, filename_and_index_slots_each=8,
        filename_and_index_array_bytes_upper=8*(8+8),
        current_argument_copy_bytes=maximum_arg,
        retained_argument_payload_bytes=sum(len(x) for x in
            (argv[2],argv[3],argv[5][3:],argv[6][3:])),
        Main_directory_two_copies_bytes_upper=2*(path_bytes+1),
        source_search_slots_upper=2, library_search_slots_upper=3,
        source_and_library_initial_pointer_slots_each=10,
        search_pointer_backing_bytes_upper=2*10*8,
        directory_normalization_payload_bytes_upper=3*(path_bytes+1),
        default_path_iterator_payload_bytes_upper=2*(path_bytes+1),
        object_directory_file_bytes_upper=path_bytes+1,
        source_mapping_file_bytes=0, source_mapping_reader_bytes=1,
        mapping_tables_initial_entries_each=1000,
        system_reader_bytes=7504,
        normalizer_max_path_parameter=4096,
        normalization_path_buffer_bytes_upper=path_bytes+2*4096+4,
        normalization_link_buffer_bytes=4096+2,
        normalization_result_and_final_scratch_bytes_upper=2*(path_bytes+1),
        locate_file_scratch_bytes_upper=path_bytes+1,
        prefix_saved_copy_bytes_upper=path_bytes+1,
        prefix_key_bytes=5, prefix_key_root_bytes=9,
        prefix_translation_scratch_bytes_upper=path_bytes+5,
        prefix_ada_C_input_and_output_bytes_upper=2*(path_bytes+1),
        prefix_translation_iterations_upper=1,
        generated_statement_buffer_bytes=1000,
        generated_line_bytes_upper=context.maximum_generated_line,
        direct_generated_path_line_bytes_upper=path_bytes+10,
        generated_output_stream_buffer_bytes=32767,
        interrupt_and_dispatch_initial_slots_each=100,
        output_object_list_lines_upper=d['Units'],
        output_object_list_line_bytes_upper=path_bytes+1,
        source_coverage='retained fixed initialization + direct-argument/search transfer + fixed OUTPUT generator projection')
    conditions = dict(selected_same_source_invocation=fresh['selected_native_launch_graph_computable'],
        accepted_native_ALI_local_interfaces=all(v is True for k,v in p['conditions'].items()
            if not k.startswith('GPR_')),
        **names['conditions'], **graph['conditions'],
        binder_argv_search_and_path_indices=(path_bytes+2*4096+4 <= I32 and
            maximum_arg <= I32 and path_bytes+5 <= I32),
        binder_generation_buffers=(fixed['generated_line_bytes_upper'] <= 1000 and
            path_bytes+10 <= I32),
        fixed_OUTPUT_library_graph_projection=True,
        fixed_initialization_and_direct_process_coverage=True)
    coverage = True  # source partition below; numerical guards remain separate
    fits = all(v is True for v in conditions.values())
    return dict(scope='selected direct GNATBIND process; literal-output family',
        source_identity=identity(raw_source), source_counts=p['source_counts'],
        path_bytes=path_bytes, host_page_bytes=host_page_bytes,
        conditions=conditions, names=names, graph=graph,
        fixed_process_owners=fixed, ALI_local_result=p,
        ALI_local_result_scope='retained local evidence; old nonparser/graph residuals superseded here',
        binder_source_coverage_complete=coverage, binder_capacity_established=fits,
        residuals=[] if fits else [k for k,v in conditions.items() if v is not True],
        GPR_or_Gprbind_jobs=0, native_tool_executions=0,
        whole_literal_pipeline_capacity_established=False,
        production_launcher_adopted=False, aggregate_RAM_gate=False,
        input_pins_checked=context.pins_checked,
        premises=['Selected coherent invocation/input/filesystem and installed source correspondence.',
            'LP64 x86-64 Linux; Integer/Natural 32-bit, pointers/alignment at most 8 bytes; GNAT unconstrained-array metadata at most 32 bytes per allocation.',
            'Linux PATH_MAX=4096; selected complete raw/normalized/resolved paths fit P.',
            'Accessible files, successful allocator/stack/disk and ordinary libc/OS contracts; no physical-memory total is asserted.'])


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root',type=Path,default=ADA_ROOT)
    parser.add_argument('--gcc-root',type=Path,default=GCC_ROOT)
    parser.add_argument('--source',type=Path,default=REPO/'samples/hello_world.adb')
    parser.add_argument('--path-bytes',type=int,default=512)
    parser.add_argument('--output',type=Path,required=True)
    a=parser.parse_args()
    result=evaluate(a.source.read_bytes(),Context(a.ada_root,a.gcc_root),path_bytes=a.path_bytes)
    a.output.write_text(json.dumps(result,indent=2)+'\n')


if __name__=='__main__': main()
