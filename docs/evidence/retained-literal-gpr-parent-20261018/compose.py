#!/usr/bin/env python3
"""Offline local GPRbuild literal-output DW reader interface, not a build."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
CONSUMER = REPO/'docs/evidence/retained-literal-binder-ali-20261018'
BINDER = REPO/'docs/evidence/retained-binder-capacity-20261018'
OUTPUT = REPO/'docs/evidence/retained-linker-output-delta-20261018'
SPLIT = REPO/'docs/evidence/retained-split-options-20261018'
I32, I64, ID_LAST = 2**31-1, 2**63-1, 99_999_999


def require(ok, message):
    if not ok:
        raise ValueError(message)


def fixed_scan(raw, policy='DW'):
    """Census the selected parser projection; this is not an ALI validator.

    W enables W/Y/Z together in the actual reader. G is unknown; X ends the
    consumed projection. Complete bytes, including Xref text, remain charged.
    """
    require(policy in ('DW', 'W'), 'selected parent read policy')
    require(b'\r' not in raw, 'selected fixed LF serialization')
    rows = []
    for line in raw.split(b'\n'):
        if line.startswith(b'X '):
            break
        if line:
            rows.append(line)
    counts = Counter(line[:1].decode() for line in rows)
    selected = [line for line in rows if line[:1] in (b'V', b'U', b'W', b'Y', b'Z')
                or policy == 'DW' and line.startswith(b'D ')]
    u, w = counts['U'], counts['W']+counts['Y']+counts['Z']
    d = counts['D'] if policy == 'DW' else 0
    # Version: one lookup. U: two. W/Y/Z and D: at most three each.
    events = 1+2*u+3*w+3*d
    names = [line.split()[1].decode() for line in rows if line[:1] in (b'W', b'Y', b'Z')]
    a_rows = [line for line in raw.splitlines(keepends=True) if line.startswith(b'A ')]
    return dict(complete_bytes=len(raw), non_A_complete_bytes=len(raw)-sum(map(len, a_rows)),
        recorded_A_payloads=[line[2:].decode() for line in raw.splitlines() if line.startswith(b'A ')],
        table_demands_upper=dict(ALIs=1, Units=u, Withs=w, Sdep=d, Args=0),
        consumed_name_row_bytes_upper=max(map(len, selected)),
        parser_name_entry_events_upper=events,
        parser_name_value_bytes_upper=events*max(map(len, selected)),
        withed_units=names, records_before_X=dict(sorted(counts.items())),
        invocation_signature_records_consumed=0, Xref_records_consumed=0)


def table(demand, initial, increment, component_bytes):
    """GNAT.Dynamic_Tables first-growth policy, including its strict spare."""
    capacities, capacity, used = [], 0, 0
    while used < demand:
        used += 1
        if used > capacity:
            new = initial if not capacity else capacity*(100+increment)//100
            if new <= capacity:
                new = capacity+10
            if new <= used:
                new = used+10
            capacity = new
            capacities.append(capacity)
    return dict(demand_upper=demand, capacities=capacities,
        component_bytes_upper=component_bytes, allocated_bytes_upper=capacity*component_bytes,
        indices_and_next_slot_fit=max(demand+1, capacity+1) <= ID_LAST,
        allocation_bits_and_pointer_difference_fit=8*capacity*component_bytes <= I32
            and capacity*component_bytes+16 <= I64)


class Context:
    def __init__(self, ada_root):
        self.consumer_api = runpy.run_path(str(CONSUMER/'compose.py'))
        identity, members = self.consumer_api['identity'], self.consumer_api['archive_members']
        self.pins = json.loads((HERE/'inputs.json').read_bytes())
        for row in self.pins:
            require(identity((REPO/row['path']).read_bytes()) ==
                    {k: row[k] for k in ('bytes', 'sha256')}, 'changed input: '+row['path'])
        self.consumer = self.consumer_api['Context'](ada_root)
        manifest = json.loads((BINDER/'manifest.json').read_bytes())['archives']['sources.tar.gz']
        require(identity((BINDER/'sources.tar.gz').read_bytes()) == manifest['archive'], 'binder sources')
        self.sources = members(BINDER/'sources.tar.gz', manifest['members'])
        own = json.loads((HERE/'sources.json').read_bytes())
        require(identity((HERE/'sources.tar.gz').read_bytes()) == own['archive'], 'additional sources')
        additional = members(HERE/'sources.tar.gz', {r['path']: r for r in own['files']})
        for path, raw in additional.items():
            if path.startswith('gcc/ada/'):
                require(identity((Path(ada_root)/path.removeprefix('gcc/ada/')).read_bytes()) == identity(raw),
                        'additional GCC source correspondence: '+path)
        self.sources.update(additional)
        split = json.loads((SPLIT/'sources.json').read_bytes())
        require(identity((SPLIT/'sources.tar.gz').read_bytes()) ==
                {k: split['archive'][k] for k in ('bytes', 'sha256')}, 'split sources')
        split_sources = members(SPLIT/'sources.tar.gz', {r['path']: r for r in split['files']})
        self.sources.update(split_sources)
        artifacts = json.loads((OUTPUT/'manifest.json').read_bytes())['artifacts']
        require(identity((OUTPUT/'artifacts.tar.gz').read_bytes()) ==
                {k: artifacts[k] for k in ('bytes', 'sha256')}, 'fixed output artifacts')
        self.artifacts = members(OUTPUT/'artifacts.tar.gz', {r['path']: r for r in artifacts['members']})
        self.fixed_raw = {name: self.artifacts['closure/'+name]
                          for name in ('silver_io.ali', 'silver_output_libc.ali')}
        self.fixed = {name: fixed_scan(raw) for name, raw in self.fixed_raw.items()}
        baseline = ['-gnatA', '-gnat2022', '-gnata', '-gnato', '-mtune=generic', '-march=x86-64']
        require(all(row['recorded_A_payloads'] == baseline for row in self.fixed.values()),
                'fixed unindexed baseline stored switches')
        # Derivation: retained six stored switches + the three native additions.
        # -gnateI1 belongs only to indexed Main; no arbitrary options/duplicates.
        self.fixed_switches = baseline+['-Wno-free-nonheap-object', '-gnatx', '-fsplit-wide-types']
        self.fixed_A_bytes = sum(len(s)+3 for s in self.fixed_switches)
        require(len(self.fixed_switches) == 9 and self.fixed_A_bytes == 129,
                'selected fixed child A envelope')
        self.table_specs = dict(ALIs=(500, 200, 8192), Units=(100, 200, 320),
                                Withs=(5000, 200, 80), Sdep=(5000, 200, 128), Args=(1000, 100, 16))
        for name, (initial, growth, _) in self.table_specs.items():
            self.consumer_api['declaration'](self.sources['gpr/gpr/src/gpr-ali.ads'], name,
                                             initial, growth, gpr=True)
        self.check_source_shape()

    def check_source_shape(self):
        anchors = {
            'gpr/src/gprbuild-main.adb': [b'Queue.Initialize (Opt.One_Compilation_Per_Obj_Dir);',
                b'Compute_Compilation_Phases', b'Add_Mains_To_Queue;'],
            'gpr/gpr/src/gpr_build_util.adb': [b'if not Repeat and then Source.Id.In_The_Queue then',
                b'Q.Table (Q_First).Processed := True;', b'Source.Id.In_The_Queue := True;',
                b'Data.Closure_Needed   :=', b'Has_Mains', b'if not Proj.Externally_Built then',
                b'not Builder_Data (Tree).Closure_Needed', b'Source_Files_Htable.Get',
                b'Src_Id.Dep_Name = Afile', b'Closure => True'],
            'gpr/src/gprbuild-compile.adb': [b'Read_Lines    => "W"', b'Read_Lines => "DW"',
                b'Record_ALI_For (Src_Data, The_ALI);', b'ALI.Initialize_ALI;', b'Free (Text);',
                b'Queue.Next;', b'Config.Dependency_Kind = Makefile', b'if The_ALI = ALI.No_ALI_Id then',
                b'if Id.Index /= 0'],
            'gpr/gpr/src/gpr-ali.adb': [b"Ignore := ('U' => False, others => True);",
                b"if Ignore ('W') then", b"if Ignore ('D') then", b"if Ignore ('A') then",
                b'ALIs.Init;', b'Units.Init;', b'Withs.Init;', b'Sdep.Init;',
                b'Sdep.Table (Sdep.Last).Rfile := File_Name_Type (Name_Enter);'],
            'gpr/gpr/src/gpr-names.adb': [b'Hash_Num : constant Int := 2**16;',
                b'package Name_Vectors is new Ada.Containers.Indefinite_Vectors', b'Name_Entries.Append'],
            'gpr/gpr/src/gpr-names.ads': [b'Name_Buffer : String (1 .. 1_000_000);'],
            'gcc/ada/libgnat/g-dyntab.adb': [b'New_Allocated_Length := New_Length + 10;',
                b'Long_Long_Integer (Old_Allocated_Length)', b'Free (Temp);'],
            'gcc/ada/switch-c.adb': [b'Xref_Active := False;', b'if Store_Switch then',
                b'Scan_Pos (Switch_Chars, Max, Ptr, Multiple_Unit_Index, C);'],
            'gcc/ada/back_end.adb': [b'Store_Compilation_Switch (Switch_Chars);',
                b'Is_Internal_GCC_Switch (Switch_Chars)'],
            'gcc/ada/lib-writ.adb': [b"Write_Info_Initiate ('A');", b'if Opt.Xref_Active then'],
        }
        for name, snippets in anchors.items():
            for snippet in snippets:
                require(snippet in self.sources[name], 'source anchor: '+name)
        known = re.search(rb'Known_ALI_Lines\s*:.*?:=\s*\((.*?)\);',
                          self.sources['gpr/gpr/src/gpr-ali.adb'], re.S)[1]
        require(not re.search(rb"'G'\s*=>\s*True", known) and b'others => False' in known,
                'G lines are unknown to the GPR reader')
        for name in ('gpr/src/gprbuild-main.adb', 'gpr/src/gprbuild-compile.adb',
                     'gpr/gpr/src/gpr_build_util.adb'):
            code = re.sub(rb'--[^\n]*', b'', self.sources[name])
            require(not re.search(rb'Repeat\s*=>\s*True', code), 'no selected explicit repeat insertion')
        ali = self.sources['gpr/gpr/src/gpr-ali.ads']
        for name, count in dict(ALIs=25, Unit=33, With=10, Sdep=8).items():
            body = re.search(rb'type '+name.encode()+rb'_Record is record(.*?)end record;', ali, re.S)[1]
            require(len(re.findall(rb'^\s+[A-Za-z_]+\s*:', body, re.M)) == count,
                    'fixed record field count: '+name)
        rident = re.sub(rb'--[^\n]*', b'', self.sources['gcc/ada/libgnat/s-rident.ads'])
        restrictions = re.search(rb'type Restriction_Id is\s*\((.*?)\);', rident, re.S)[1].split(b',')
        require(len(restrictions) == 101, 'fixed restriction enum')
        # Overcharge all five restriction arrays by the entire 101-member enum,
        # and every array scalar by eight bytes. Remaining 24 fields also get 8.
        require(24*8+5*101*8 <= 8192, 'ALIs_Record component bound')
        self.extra_source_count = 3
        self.split_source_count = 29


def evaluate(raw, context, path_bytes=512):
    prior = context.consumer_api['evaluate'](raw, context.consumer, path_bytes)
    main = prior['Main_ALI_interface']
    writer = main['Main_ALI_writer']
    u = writer['Units_table']['demand']
    main_demands = dict(ALIs=1, Units=u, Withs=u*u, Sdep=u, Args=0)
    main_events = 1+2*u+3*u*u+3*u
    main_row = writer['max_record_bytes_including_LF']-1
    fixed = context.fixed
    fixed_demands = {k: sum(r['table_demands_upper'][k] for r in fixed.values()) for k in main_demands}
    cumulative = {k: main_demands[k]+fixed_demands[k] for k in main_demands}
    per_scan = {k: max(main_demands[k], *(r['table_demands_upper'][k] for r in fixed.values()))
                for k in main_demands}
    tables = {name: table(demand, *context.table_specs[name]) for name, demand in per_scan.items()}
    no_reset = {name: table(demand, *context.table_specs[name]) for name, demand in cumulative.items()}
    fixed_readers = {name: row['non_A_complete_bytes']+context.fixed_A_bytes+1
                     for name, row in fixed.items()}
    reader = main['Main_ALI_reader_bytes_including_EOF_upper']
    names = dict(Main_entry_events_upper=main_events,
        fixed_entry_events_upper=sum(r['parser_name_entry_events_upper'] for r in fixed.values()),
        entry_events_upper=main_events+sum(r['parser_name_entry_events_upper'] for r in fixed.values()),
        value_bytes_upper=main_events*main_row+sum(r['parser_name_value_bytes_upper'] for r in fixed.values()),
        maximum_payload_bytes_upper=max(main_row, *(r['consumed_name_row_bytes_upper'] for r in fixed.values())),
        extra_NUL_per_stored_value=0, static_hash_slots=65536, static_name_scratch_bytes=1000000,
        reset_between_scans=False, complete_name_vector_backing_established=False,
        ALI_path_interning_charged=False,
        incoming_contract='F/Dep_Path names already interned; add E_parser and C_parser to all incoming/nonparser events and value bytes. Bound Name_Id and Count_Type, discriminated entry metadata/padding, indefinite-vector capacity/overlap and every incoming payload separately. Table resets do not release Names.')
    conditions = dict(accepted_Main_writer_and_source=main['selected_Main_ALI_interface_fits'],
        parent_parser_table_indices=all(t['indices_and_next_slot_fit'] for t in no_reset.values()),
        parent_parser_individual_table_allocations=all(t['allocation_bits_and_pointer_difference_fit'] for t in tables.values()),
        parent_raw_reader_indices_and_EOF=max(reader, *fixed_readers.values()) <= I32,
        parent_cursors_and_line_counter=max(reader, *fixed_readers.values())+1 <= I32,
        parent_shared_name_scratch=max(names['maximum_payload_bytes_upper'], path_bytes+1, 32) <= 1000000)
    return dict(scope='GPRbuild.Compile Phase_2_ALI DW reader under the explicit fresh-output job/child interface',
        source=main['source'], source_counts=main['source_counts'], path_spelling_bytes_upper=path_bytes,
        Main_ALI_interface=main, fixed_parent_job_ALIs=fixed,
        fixed_native_stored_switch_envelope=dict(switches=context.fixed_switches, rows_upper=9,
            payload_bytes_upper=sum(map(len, context.fixed_switches)), complete_A_bytes_upper=context.fixed_A_bytes,
            indexed_Main_switch_excluded='-gnateI1', duplicates_or_extra_stored_switches_permitted=False),
        schedule=dict(Phase_2_ALI_DW_calls_upper=3, Record_ALI_For_additional_W_reads_upper=0,
            selected_jobs=['Main', 'Silver_IO body', 'Silver_Output_Libc spec'],
            runtime_ALI_recursion_in_parent=0, native_parent_ALI_buffers_simultaneously_live_upper=1,
            successful_scans_reset_ALI_tables=True, shared_GPR_Names_persists=True,
            fresh_job_frontier_requires_descriptor_premises=True, whole_parent_call_graph_closed=False),
        parser_tables_per_scan=tables, table_append_counts_cumulative_upper=cumulative,
        parser_tables_without_inter_scan_reset=no_reset,
        raw_buffers=dict(Main_including_EOF_upper=reader, fixed_including_EOF_upper=fixed_readers,
            peak_local_reader_bytes_upper=max(reader, *fixed_readers.values()),
            cumulative_local_reader_bytes_upper=reader+sum(fixed_readers.values()),
            cumulative_is_not_peak_live_or_RAM_gate=True),
        parser_name_contribution=names, argument_strings_allocated=0,
        invocation_signature_tables_or_hash_text_allocated=0, version_local_scratch_bytes=32,
        conditions=conditions, selected_parent_DW_reader_local_interface_fits=all(conditions.values()),
        fixed_inputs_checked=len(context.pins), binder_source_members_checked=151,
        additional_source_members_checked=context.extra_source_count, split_source_members_checked=context.split_source_count,
        native_tool_executions=0, aggregate_RAM_gate=False,
        output_launch_descriptor_materialized=False, fixed_child_regeneration_correspondence_established=False,
        complete_GPR_Names_backing_established=False, output_parent_source_buffers_established=False,
        whole_native_parent_capacity_established=False, whole_literal_pipeline_capacity_established=False,
        premises=[
            'Relevant installed behavior matches pinned GCC/GPR source on Linux x86-64; case-sensitive filenames, native mode rather than GnatProve mode, ordinary LP64 scalar/layout and physical-resource premises remain separate.',
            'One ordinary non-library project/tree/Main, no imports/extensions/aggregates/Roots, no runtime sources in the project inventory; fixed Silver sources are unindexed, Main alone indexed.',
            'Fresh writable native object/ALI/exchange directories, default object checks; one local non-jobserver compile pass, no unique-compile/compile-all/distributed/requeue/keep-going/check-switches/no-split modes or external injection.',
            'Coherent accepted literal Main and fixed Silver source/specification bytes; the accepted Main W closure reaches only the two fixed Silver jobs in this project inventory.',
            'Each fixed child ALI preserves retained version/U/W/Y/Z/D names and row-width envelopes, fixed metadata field widths, and complete non-A byte envelope except optional Xref deletion; the nine allowed unindexed stored native switches occur at most once. Selected native/producer option separation and this regeneration correspondence must be realized by the later descriptor.',
            'Successful child/parsing interfaces and ordinary process wait completion; every Dep_Path spelling and C NUL satisfies P; Names includes all incoming and nonparser producers.'],
        remaining=[
            'Materialize the complete selected output launch/search/options descriptor and fixed-child ALI regeneration correspondence; this callable checks the interface, not those producers.',
            'Close persistent shared GPR.Names vector backing with incoming/nonparser contributions.',
            'Price additional fixed Silver source buffers, source/name/project/configuration/phase routes, queue and driver lifetimes; the null three-buffer witness does not transfer.',
            'Compose all native/producer/link/binder components; research #119 remains incomplete.'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--source', type=Path, default=REPO/'samples/hello_world.adb')
    parser.add_argument('--path-bytes', type=int, default=512)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = evaluate(args.source.read_bytes(), Context(args.ada_root), args.path_bytes)
    args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('selected_parent_DW_reader_local_interface_fits',
        'whole_native_parent_capacity_established', 'native_tool_executions')}))
