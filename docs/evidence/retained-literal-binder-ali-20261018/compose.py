#!/usr/bin/env python3
"""Offline literal Main/fixed-output ALI consumer composition, not a binder run."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import runpy
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
ALI = REPO/'docs/evidence/retained-literal-ali-20261018'
BINDER = REPO/'docs/evidence/retained-binder-capacity-20261018'
OUTPUT = REPO/'docs/evidence/retained-linker-output-delta-20261018'
I32 = 2**31-1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(condition, message):
    if not condition:
        raise ValueError(message)


def archive_members(path, expected):
    with tarfile.open(path) as archive:
        result = {m.name: archive.extractfile(m).read()
                  for m in archive if m.isfile()}
    require(set(result) == set(expected), 'archive member set: '+str(path))
    for name, raw in result.items():
        require(identity(raw) == {k: expected[name][k] for k in ('bytes', 'sha256')},
                'archive member: '+name)
    return result


def census(alis):
    """Read complete fixed files; count parser rows only before the first X."""
    records, graph = Counter(), Counter()
    dependencies = defaultdict(set)
    constructs, signatures, hash_texts, args, subunits = [], set(), [], [], []
    max_row = note_sources = 0
    for name, raw in sorted(alis.items()):
        require(b'\r' not in raw, 'selected fixed ALI newline spelling')
        for line in raw.split(b'\n'):
            if line.startswith(b'X '):
                break
            if not line:
                continue
            records[line[:1].decode()] += 1
            max_row = max(max_row, len(line))
            require(not line.startswith(b'R '), 'No_Dependence absent')
            if line.startswith(b'A '):
                args.append(line[2:])
            if line.startswith(b'D '):
                fields = line.split()
                dependencies[fields[1]].add(tuple(fields[2:4]))
                if len(fields) > 4 and not fields[4][:1].isdigit() and not fields[4].endswith((b'%b', b'%s')):
                    require(re.fullmatch(rb'[a-z_]+(?:\.[a-z_]+)*', fields[4]), 'ASCII subunit')
                    subunits.append(fields[4].decode())
            if line.startswith(b'N '):
                note_sources += bool(re.match(rb'N .[0-9]+:[0-9]+:', line))
            if line.startswith(b'G '):
                kind = line[2:3].decode()
                graph[kind] += 1
                sigs = re.findall(rb'\[([^\]]*)\]', line)
                if kind == 'c':
                    require(line.startswith(b'G c Z ') and len(sigs) == 1, 'ordinary construct')
                    constructs.extend(sigs)
                elif kind == 'r':
                    require(line.startswith(b'G r c none ') and len(sigs) == 2, 'fixed relation shape')
                else:
                    require(line == b'G a e', 'fixed graph attribute')
                for sig in sigs:
                    n, scope, ln, col, loc = sig.split()
                    require(0 <= int(ln) <= I32 and 0 <= int(col) <= I32, 'fixed Nat coordinates')
                    require((n, scope) != (b'main', b'standard'), 'no fixed Main signature')
                    signatures.add(sig)
                    hash_texts.append(scope+b'__'+n+b'__'+ln+b'_'+col+
                                      (b'__'+loc if loc != b'none' else b''))
    require(len(alis) == 82, 'fixed ALI count')
    require(dict(records) == dict(V=82, A=823, P=82, R=523, U=139,
                                  W=421, Z=118, D=1007, G=1359, N=7, L=1), 'fixed row census')
    require(dict(graph) == dict(a=82, c=1271, r=6), 'fixed graph census')
    require(len(constructs) == len(set(constructs)) == len(signatures) == 1271,
            'relations reuse construct signatures')
    require(all(len(v) == 1 for v in dependencies.values()), 'coherent fixed D versions/timestamps')
    require(len(dependencies) == 163 and note_sources == 0, 'dependency/note census')
    events = (2*records['U']+3*(records['W']+records['Z'])+3*records['D']+
              3*graph['c']+7*graph['r']+records['L']+records['N'])
    return dict(ALI_files=len(alis), complete_file_bytes=sum(map(len, alis.values())),
        max_complete_file_bytes=max(map(len, alis.values())), records=dict(sorted(records.items())),
        invocation_records=dict(sorted(graph.items())), distinct_signatures=len(signatures),
        all_constructs_ordinary=True, fixed_Main_signature_count=0,
        maximum_signature_hash_bytes=max(map(len, hash_texts)),
        max_consumed_row_bytes_before_LF=max_row, distinct_dependency_names=len(dependencies),
        dependency_mismatch_count=0, subunit_names=subunits, notes_with_explicit_source=note_sources,
        argument_payload_bytes=sum(map(len, args)), maximum_argument_payload_bytes=max(map(len, args)),
        parser_name_entry_events=events, parser_name_character_slots=events*(max_row+1))


def table(demand, initial, increment):
    capacities = [initial]
    while capacities[-1] < demand:
        previous = capacities[-1]
        capacities.append(max(previous*(100+increment)//100, previous+10))
    return dict(demand_upper=demand, capacities=capacities,
                ID_and_Int_arithmetic_fit=max(demand+1, capacities[-1]+1) <= 99_999_999)


def declaration(raw, name, initial, increment, gpr=False):
    package = b'GNAT.Table' if gpr else b'Table.Table'
    pattern = rb'package '+name.encode()+rb' is new '+re.escape(package)+rb'\s*\((.*?)\);'
    matches = re.findall(pattern, raw, re.S)
    require(len(matches) == 1, 'table declaration: '+name)
    for key, value in (('Table_Initial', initial), ('Table_Increment', increment)):
        require(re.search(key.encode()+rb'\s*=>\s*'+str(value).encode()+rb'(?:\s*,|\s*$)', matches[0]),
                'table sizing: '+name+'/'+key)


class Context:
    def __init__(self, ada_root):
        pins = json.loads((HERE/'inputs.json').read_bytes())
        for row in pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k: row[k] for k in ('bytes', 'sha256')}, 'changed input: '+row['path'])
        self.pins = len(pins)
        self.ali_api = runpy.run_path(str(ALI/'compose.py'))
        self.ali_context = self.ali_api['Context'](ada_root)
        descriptor = json.loads((self.ali_api['NATIVE']/'native-ali-inputs.json').read_bytes())
        self.nonpath_name_bound = descriptor['fixed_nonpath_name_bound']
        binder = json.loads((BINDER/'manifest.json').read_bytes())
        capsule = binder['archives']['sources.tar.gz']
        require(identity((BINDER/'sources.tar.gz').read_bytes()) == capsule['archive'], 'binder archive')
        sources = archive_members(BINDER/'sources.tar.gz', capsule['members'])
        output = json.loads((OUTPUT/'manifest.json').read_bytes())['artifacts']
        require(identity((OUTPUT/'artifacts.tar.gz').read_bytes()) ==
                {k: output[k] for k in ('bytes', 'sha256')}, 'output archive')
        artifacts = archive_members(OUTPUT/'artifacts.tar.gz', {r['path']: r for r in output['members']})
        alis = {p.removeprefix('closure/'): raw for p, raw in artifacts.items()
                if p.startswith('closure/') and p != 'closure/main.ali'}
        self.fixed = census(alis)
        self.table_specs = dict(ALIs=(500, 200), Units=(100, 200), Withs=(5000, 200),
            Args=(1000, 100), Sdep=(5000, 200), Source=(1000, 200),
            Invocation_Constructs=(2500, 200), Invocation_Signatures=(2500, 200),
            Invocation_Relations=(2500, 200), Linker_Options=(200, 400),
            Notes=(200, 400), No_Deps=(200, 400))
        for name, (initial, growth) in self.table_specs.items():
            file = ('ali-util.ads' if name == 'Source' else
                    'ali.adb' if name.startswith('Invocation_') else 'ali.ads')
            declaration(sources['gcc/ada/'+file], name, initial, growth)
        for name, initial in dict(ALIs=500, Units=100, Args=1000, Withs=5000, Sdep=5000).items():
            declaration(sources['gpr/gpr/src/gpr-ali.ads'], name, initial,
                        100 if name == 'Args' else 200, gpr=True)
        anchors = {
            'gcc/ada/ali.adb': [b'Buffer : Bounded_String (2052);', b'Sig_Map.Create (500);',
                b'Extra := Get_Name;', b'Invoker := Scan_Invocation_Signature;',
                b'Target := Scan_Invocation_Signature;'],
            'gcc/ada/table.adb': [b'New_Length : Long_Long_Integer;'],
            'gpr/src/gprbind.adb': [b'Read_Lines    => "A"'],
            'gpr/gpr/src/gpr-ali.adb': [b"Ignore := ('U' => False, others => True);"],
            'gpr/gpr/src/gpr-names.ads': [b'Name_Buffer : String (1 .. 1_000_000);'],
            'gpr/gpr/src/gpr-names.adb': [b'Hash_Num : constant Int := 2**16;'],
        }
        for name, patterns in anchors.items():
            for pattern in patterns:
                require(pattern in sources[name], 'source anchor: '+name)
        unit = re.search(rb'type Unit_Record is record\n(.*?)   end record;', sources['gcc/ada/ali.ads'], re.S)[1]
        fields = re.findall(rb'^      ([A-Za-z_]+) : ([A-Za-z_]+);', unit, re.M)
        require(len(fields) == 40 and sum(t == b'Version_String' for _, t in fields) == 1, 'Unit_Record layout')
        self.source_members = len(sources)


def evaluate(raw, context, path_bytes=512):
    main = context.ali_api['evaluate'](raw, context.ali_context, path_bytes)
    f, rec = context.fixed, context.fixed['records']
    writer, inv = main['Main_ALI_writer'], main['Main_invocation_interface']
    u = writer['Units_table']['demand']
    a = main['ALI_A_records']
    constructs, relations, signatures = (inv['ALI_Invocation_'+k] for k in ('Constructs', 'Relations', 'Signatures'))
    demands = dict(ALIs=f['ALI_files']+1, Units=rec['U']+u,
        Withs=rec['W']+rec['Z']+u*u, Args=rec['A']+a, Sdep=rec['D']+u,
        Source=f['distinct_dependency_names']+u,
        Invocation_Constructs=f['invocation_records']['c']+constructs,
        Invocation_Relations=f['invocation_records']['r']+relations,
        Invocation_Signatures=f['distinct_signatures']+signatures,
        Linker_Options=rec['L']+1, Notes=rec['N']+1, No_Deps=0)
    tables = {name: table(demand, *context.table_specs[name]) for name, demand in demands.items()}
    main_events = 2*u+3*u*u+3*u+3*constructs+7*relations
    main_row = writer['max_record_bytes_including_LF']-1
    names = dict(fixed_entry_events=f['parser_name_entry_events'], Main_entry_events=main_events,
        entry_events_upper=f['parser_name_entry_events']+main_events,
        character_slots_including_NUL_upper=f['parser_name_character_slots']+main_events*(main_row+1),
        payload_bytes_upper=max(f['max_consumed_row_bytes_before_LF'], main_row),
        scratch_bytes=4*32766, stored_payload_Short_limit=32767,
        Name_Entries_initial_slots=6000, Name_Entries_growth_percent=100, Name_Entry_bytes=16,
        Name_Chars_initial_slots=50000, Name_Chars_growth_percent=100,
        complete_pool_backing_established=False,
        incoming_contract='Add all nonparser entry events/character slots before applying Table growth; charge index/sentinel and old/new backing. Every incoming payload must fit Short and scratch.')
    sig_count = demands['Invocation_Signatures']
    # 751 pairs trigger the sole expansion; the second threshold is 1500.
    require(750 < sig_count <= 1500, 'selected Sig_Map expansion interval')
    sig = dict(distinct_nodes_upper=sig_count, bucket_capacities=[500, 1000],
        coexisting_bucket_slots_upper=1500, node_bytes_upper=64,
        nodes_and_coexisting_buckets_bytes_upper=(sig_count+1500)*64,
        hash_text_bytes_upper=max(f['maximum_signature_hash_bytes'], inv['max_serialized_signature_characters']),
        hash_scratch_bytes=2052, hash_To_String_temporary_bytes_upper=max(f['maximum_signature_hash_bytes'], inv['max_serialized_signature_characters']))
    reader = main['Main_ALI_reader_bytes_including_EOF_upper']
    buffers = dict(Main_file_bytes_upper=writer['serialized_file_byte_bound'],
        Main_reader_bytes_including_EOF_upper=reader,
        fixed_maximum_reader_bytes_including_EOF=f['max_complete_file_bytes']+1,
        native_peak_raw_ALI_buffer_bytes_upper=max(reader, f['max_complete_file_bytes']+1),
        native_cumulative_raw_ALI_allocated_bytes_upper=writer['serialized_file_byte_bound']+f['complete_file_bytes']+demands['ALIs'],
        native_dependency_recursion_depth_upper=demands['ALIs'],
        cumulative_bytes_are_not_peak_live_or_RAM_gate=True)
    main_arg_max = max(map(len, main['stored_native_switches']))
    gpr = dict(raw_buffer_bytes_including_EOF_upper=reader,
        table_demands_upper=dict(ALIs=1, Units=u, Args=a, Withs=0, Sdep=0),
        table_backing_slot_bounds=dict(ALIs=500, Units=100, Args=1000, Withs=0, Sdep=0),
        argument_string_payload_bytes=main['ALI_A_payload_characters'],
        maximum_argument_string_payload_bytes=main_arg_max,
        argument_filter_local_copy_bytes_upper=main_arg_max, version_scratch_bytes=32,
        name_entry_events_upper=2+2*u,
        name_value_bytes_upper=path_bytes+len('GNAT 16')+u*(context.nonpath_name_bound+path_bytes),
        maximum_name_payload_bytes_upper=max(path_bytes, context.nonpath_name_bound, len('GNAT 16')),
        name_values_have_extra_NUL=False, static_hash_slots=65536, static_name_scratch_bytes=1000000,
        complete_name_vector_backing_established=False,
        incoming_contract='Add these events and value bytes to incoming GPR.Names; charge discriminated entry metadata, indefinite-vector capacities, growth overlap and indices. Main ALI path, including C NUL, must fit scratch.',
        recursive_fixed_ALI_reads=0)
    conditions = dict(accepted_Main_ALI_interface=main['selected_Main_ALI_interface_fits'],
        native_parser_table_indices=all(t['ID_and_Int_arithmetic_fit'] for t in tables.values()),
        native_Units_growth_bytes=tables['Units']['capacities'] == [100, 300] and 300*320 <= I32,
        native_signature_map_and_hash=sig['hash_text_bytes_upper'] <= sig['hash_scratch_bytes'] and
            sig['nodes_and_coexisting_buckets_bytes_upper'] <= I32,
        native_parser_name_payload=names['payload_bytes_upper'] <= min(names['stored_payload_Short_limit'], names['scratch_bytes']),
        native_and_GPR_reader_indices=max(reader, f['max_complete_file_bytes']+1) <= I32,
        GPR_initial_table_capacities=all(v <= gpr['table_backing_slot_bounds'][k] for k, v in gpr['table_demands_upper'].items()),
        GPR_local_name_scratch=max(gpr['maximum_name_payload_bytes_upper']+1, main_arg_max) <= gpr['static_name_scratch_bytes'])
    return dict(source=main['source'], source_counts=main['source_counts'], path_spelling_bytes_upper=path_bytes,
        fixed_closure=f, Main_ALI_interface=main, native_parser_tables=tables,
        native_Unit_Record_bytes_upper=320, native_Units_old_and_new_backing_bytes_upper=400*320,
        native_signature_map=sig, native_raw_buffers=buffers, native_parser_name_contribution=names,
        native_argument_strings=dict(count=demands['Args'], payload_bytes=f['argument_payload_bytes']+main['ALI_A_payload_characters'],
            maximum_payload_bytes=max(f['maximum_argument_payload_bytes'], main_arg_max)),
        Gprbind_Main_reader=gpr, conditions=conditions,
        selected_ALI_consumer_local_interfaces_fit=all(conditions.values()),
        fixed_inputs_checked=context.pins, consumer_source_members_checked=context.source_members,
        native_tool_executions=0, aggregate_RAM_gate=False,
        whole_binder_or_parent_capacity_established=False, whole_literal_pipeline_capacity_established=False,
        remaining=['Native nonparser name producers and complete shared name-table backing.',
            'GPR incoming names, entry metadata/vector backing and all driver argument/search/response lifetimes.',
            'Invocation/library graph containers and transient backing under variable signature IDs and Main edges.',
            'Complete output launch/options/search materialization and the remaining producer pipeline.'],
        premises=['Relevant installed behavior matches the retained reviewed consumer/serializer sources on x86-64 Linux.',
            'Selected indexed no-Xref/split-wide configuration and retained fixed output closure; Table_Factor=1.',
            'Path spellings satisfy P; coherent regular files and D versions/timestamps, -x, case-sensitive filesystem, no aliased ALI requests.',
            'All incoming shared name-pool/driver contracts and physical resources are established separately.'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--source', type=Path, default=REPO/'samples/hello_world.adb')
    parser.add_argument('--path-bytes', type=int, default=512)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = evaluate(args.source.read_bytes(), Context(args.ada_root), args.path_bytes)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('selected_ALI_consumer_local_interfaces_fit',
        'whole_binder_or_parent_capacity_established', 'native_tool_executions')}))
