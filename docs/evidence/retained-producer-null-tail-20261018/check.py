#!/usr/bin/env python3
"""Offline null-family source frontier and final-report size calculation."""
from collections import Counter
from dataclasses import dataclass
import hashlib
import importlib.util
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
PROJECT = HERE.parents[2]


@dataclass(frozen=True)
class Number:
    width: int


@dataclass(frozen=True)
class Filename:
    pass


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    sources = {}
    for row in identity['archives']:
        path = PROJECT / row['path']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        with tarfile.open(path) as archive:
            for item in row['files']:
                data = archive.extractfile(item['member']).read()
                assert len(data) == item['bytes']
                assert hashlib.sha256(data).hexdigest() == item['sha256']
                sources[item['name']] = data.decode()
    for item in identity['local_files']:
        data = (PROJECT / item['path']).read_bytes()
        assert len(data) == item['bytes']
        assert hashlib.sha256(data).hexdigest() == item['sha256']
        sources[item['path']] = data.decode()

    def has(name, fragment):
        assert ' '.join(fragment.split()) in ' '.join(sources[name].split()), name

    has('driver', 'if Num_Registered_VCs_In_Why3 > Old_Num then')
    has('driver', 'Set_Field (Full, "assumptions", Get_Assume_JSON);')
    has('driver', 'Ada.Text_IO.Put (FD, GNATCOLL.JSON.Write (Full, Compact => False));')
    has('definition', 'and then Analysis_Requested (E, With_Inlined => True)')
    has('analysis', 'if not FA.Is_Main and then not Is_Possibly_Nonreturning_Procedure')
    has('analysis', 'if FA.Kind = Kind_Subprogram and then not Has_Effects (FA) then Warn_On_Subprogram_With_No_Effect (FA); return;')
    has('analysis', 'if Get_Termination_Condition (FA.Spec_Entity) = (Static, True) then')
    has('subprograms', 'is ((Ekind (E) = E_Function and then not Is_Function_With_Side_Effects (E)) or else Ekind (E) = E_Package or else Has_Automatic_Instantiation_Annotation (E));')
    has('subprograms', 'return (Kind => Unspecified);')
    has('attributes', 'Is_Original_Program_Node => False,')
    has('errout_spec', 'Warnings_Errors : GNATCOLL.JSON.JSON_Array;')
    has('utility', 'A : V_Attributes := Null_Attributes;')
    has('assumption_types', '(File => Find (Symbol_Table, File), Line => Line, Column => Column);')
    has('assumption_types', "(Subp_Type_Rec'(Name => Find (Symbol_Table, Name), Sloc => Sloc));")
    has('assumption_types_spec', 'Null_Subp : constant Subp_Type := null;')
    has('timing', '(if Is_Null (Key) then "global" else To_Key (Key));')
    has('timing', 'Set_Field (Obj, Timings.Key (Q), Float (Timings.Element (Q)));')
    has('json', 'Flt_Value => Long_Float (Val)')
    has('json', 'Append (Ret, (1 .. 2 * Val => \' \'));')
    has('json', "S : constant String := Item.Data.Flt_Value'Img;")
    has('json_utility', 'Append (Ret, "\\u0000");')
    has('textio', "Terminate_Line (File.all'Access);")
    has('textio', 'if File.Col /= 1 then New_Line (File);')
    has('textio', "File.Col := File.Col + Item'Length;")
    has('textio_spec', 'Page_Length : Count := 0;')
    has('json_spec', 'type JSON_Value is new Ada.Finalization.Controlled with record')
    has('json', 'Read_States : Read_State_Array_Access := new Read_State_Array (1 .. 32);')
    has('gnatcoll_atomic', 'subtype Atomic_Counter is System.Atomic_Counters.Atomic_Unsigned;')
    has('atomic_spec', 'type Atomic_Unsigned is mod 2 ** 32 with Default_Value => 0, Atomic;')
    has('xstrings', 'New_Size : constant String_Size := Growth_Strategy (0, Size);')
    has('xstrings', 'String_Size\'Max (Current * 3 / 2, Min_Size);')
    has('unbounded', 'Growth_Factor : constant := 2;')
    has('unbounded', 'DR := Allocate (DL, DL / Growth_Factor);')
    has('unbounded', '((Static_Size + Required_Length + Reserved_Length - 1) / Min_Mul_Alloc + 2) * Min_Mul_Alloc - Static_Size;')
    has('unbounded_spec', 'type Shared_String (Max_Length : Natural) is limited record')
    has('target_types', 'return BIGGEST_ALIGNMENT / BITS_PER_UNIT;')
    has('target_types', 'return get_target_maximum_default_alignment ();')
    has('x86_target', '(TARGET_IAMCU ? 32 : (TARGET_AVX512F')
    has('x86_target', '? 512 : (TARGET_AVX ? 256 : 128)))')
    has('graphs_spec', 'type Vertex_Id is new Natural;')
    has('graphs', 'Stack.Append (V); Will_Visit (V) := True;')
    has('graphs', "(Parent => Current.Child, Child => W));")
    has('graphs', 'subtype V_To_V is Vertex_To_Vertex_T (0 .. G.Vertices.Last_Index);')
    has('graphs', 'Size (V) := Size (V) + Size (W);')
    has('graphs', 'Size (Child (S)) := Size (S);')
    has('graphs', 'Link (Parent (W), W);')
    has('cfg', 'Ctx.Unwind_Lengths.Append (Ctx.Unwind_Actions.Length);')
    has('cfg', 'Move_Connections (CM, Dst => Union_Id (N), Src => Union_Id (Stmts));')
    has('cfg', 'Add_Vertex (FA, Null_Attributes, FA.Helper_End_Vertex);')
    has('cfg', 'Add_Vertex (FA, Null_Attributes, FA.Exceptional_End_Vertex);')
    has('cfg', 'Add_Vertex (FA, Null_Attributes, FA.End_Vertex);')
    has('data_graph', 'FA.DDG := FA.CFG.Create;')
    has('ip_graph', 'FA.TDG := FA.CFG.Create;')
    has('program_graph', 'FA.PDG := FA.CFG.Create;')
    has('src/silver_reports.ads', 'Max_Report_Length : constant Positive := 262_144;')
    has('src/silver_library_reports.ads', 'Max_Report_Length : constant Positive := 16_777_216;')
    has('src/silver_platform.ads', 'Max_Path_Length : constant Positive := 4_096;')

    # Retain all native callers, not merely the four selected semantic calls.
    scan_path = HERE.parent / 'retained-producer-strings-20261018/check.py'
    spec = importlib.util.spec_from_file_location('source_scan', scan_path)
    scan = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(scan)
    source_archive = PROJECT / identity['archives'][0]['path']
    frontier = []
    with tarfile.open(source_archive) as archive:
        for member in archive:
            if not (member.isfile() and member.name.startswith('spark-source/src/')
                    and member.name.endswith(('.adb', '.ads'))):
                continue
            source = archive.extractfile(member).read().decode()
            for pos, name, actual in scan.scan_calls(source, ('Entity_To_Subp_Assumption',)):
                frontier.append({'file': member.name.removeprefix('spark-source/'),
                                 'line': source.count('\n', 0, pos)+1,
                                 'actual': ' '.join(actual.split())})
    assert len(frontier) == 9, frontier

    global_timings = ['globals (basic)', 'globals (advanced)', 'marking',
                      'properties (advanced)', 'flow analysis',
                      'init_why_sections', 'translation of standard']
    for name in global_timings:
        has('driver', f'(Timing, Null_Subp, "{name}");')
    has('driver', '(Timing, Entity_To_Subp_Assumption (E), "gnat2why.vc_generation");')
    claims = [{'assumptions': [], 'claim': {'predicate': name, 'arg': Number(1)}}
              for name in ['CLAIM_EFFECTS', 'CLAIM_AORTE']]
    report = {
        'spark': {' 1': 'all'}, 'skip_flow_proof': [], 'skip_proof': [],
        'progress': 'PROGRESS_PROOF', 'stop_reason': 'STOP_REASON_NONE',
        'warn_error': [], 'flow': [], 'pragma_assume': [], 'proof': [],
        'assumptions': claims,
        'timings': {'global': {name: Number(32) for name in global_timings},
                    ' 1': {'gnat2why.vc_generation': Number(32)}},
        'entities': {' 1': {'name': 'Main', 'sloc': [
            {'file': Filename(), 'line': Number(10), 'column': Number(10)}]}},
    }
    stats = Counter()

    def size(value, depth=0):
        """Return constant + filename_coefficient*P for the actual pretty rules."""
        stats['values'] += 1
        stats['max_depth'] = max(stats['max_depth'], depth)
        if isinstance(value, Number):
            stats['numbers'] += 1
            return value.width, 0
        if isinstance(value, Filename):
            stats['strings'] += 1
            return 2, 6
        if isinstance(value, str):
            stats['strings'] += 1
            assert all(32 <= ord(c) <= 126 for c in value)
            return len(json.dumps(value)), 0
        if isinstance(value, bool):
            stats['booleans'] += 1
            return len(str(value).lower()), 0
        assert isinstance(value, (dict, list))
        obj = isinstance(value, dict)
        stats['objects' if obj else 'arrays'] += 1
        stats['max_object_fields' if obj else 'max_array_elements'] = max(
            stats['max_object_fields' if obj else 'max_array_elements'], len(value))
        # Open + LF + close indentation + close; comma between each element.
        total, coefficient = 3+2*depth+max(0, len(value)-1), 0
        for key, child in (value.items() if obj else enumerate(value)):
            total += 2*(depth+1) + 1  # indentation and final LF
            if obj:
                stats['fields'] += 1
                total += len(json.dumps(key)) + 2  # quoted key + ': '
            a, b = size(child, depth+1)
            total += a
            coefficient += b
        return total, coefficient

    constant, coefficient = size(report)
    assert coefficient == 6
    assert len(report) == 12
    result = {
        'native_or_proof_executions': 0,
        'source_class': 'Required_Tokens with permitted ASCII case/trivia; current byte cap unchanged',
        'why3_launches': 0, 'solver_launches': 0,
        'flow_messages': 0, 'proof_messages': 0,
        'claims_upper_bound': 2, 'assumptions_per_claim': 0,
        'reported_entities': 1, 'entity_location_components': 1,
        'entity_to_subp_request_bound': 4,
        'assumption_pool_find_calls': 8,
        'assumption_pool_distinct_strings': 2,
        'assumption_hashcons_distinct_records': 1,
        'global_timings': global_timings, 'main_timings': ['gnat2why.vc_generation'],
        'schema': dict(stats),
        'pretty_string_bytes': {'constant': constant, 'filename_byte_coefficient': coefficient},
        'emitted_file_bytes': {'constant': constant+1, 'filename_byte_coefficient': coefficient},
        'emitted_file_bytes_at_P_222': constant+1+coefficient*222,
        'emitted_file_bytes_at_P_256': constant+1+coefficient*256,
        'entity_to_subp_complete_call_frontier': sorted(frontier, key=lambda r: (r['file'], r['line'])),
        'scope': 'Source specialization and report shape/byte envelope; not whole flow working-storage, JSON refcounts, downstream orchestration or complete tool feasibility.'
    }
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    composition_path = PROJECT / identity['composition']['path']
    assert hashlib.sha256(composition_path.read_bytes()).hexdigest() == identity['composition']['sha256']
    composition = json.loads(composition_path.read_text())
    main_nodes = next(c['bound']['A_Main'] for c in composition['cases'] if c['name'] == 'null')
    assert main_nodes == 39
    vertex_bound = 2*main_nodes + (6+1+3+1)
    pending = vertex_bound**2+1
    storage = {
        'native_or_proof_executions': 0,
        'json_producer_live_reference_bound': 2+2+4,
        'json_parser_live_reference_bound': 32+3+1+2+4,
        'json_counter_unsigned_bits': 32,
        'target_maximum_alignment_bytes': 64,
        'selected_layout_header_envelope_bytes': 64,
        'source_main_node_bound': main_nodes,
        'cfg_vertex_bound': vertex_bound,
        'graph_edge_bound': vertex_bound**2,
        'ordinary_dfs_pending_bound': vertex_bound,
        'dominator_dfs_pending_bound': pending,
        'dominator_dfs_vector_capacity_bound': 1 << (pending-1).bit_length(),
        'dominator_array_bound': vertex_bound+1,
        'dominator_size_bound': vertex_bound,
        'dominator_size_comparison_arithmetic_bound': 2*vertex_bound,
        'path_evaluations': [],
        'scope': 'Producer/parser JSON aliases, backing/reader dimensions and local flow graph; global visibility/ALI metadata and whole report executables remain separate.'
    }
    for p in [222, 256, 4096]:
        b = constant+6*p
        d = max(p,32)
        read_d = max(2*p,32)
        capacity = b+b//2+2*storage['target_maximum_alignment_bytes']
        row = {
            'filename_bytes': p, 'write_string': b, 'file': b+1,
            'producer_xstring_capacity': d+4096,
            'parser_xstring_capacity': 3*read_d//2+4096,
            'unbounded_string_capacity': capacity,
            'unbounded_allocation_with_header_64': capacity+64,
            'text_io_column': b+1,
            'fits_existing_null_report_recognizer': b+1 <= 262144,
            'fits_existing_raw_report_buffer': b+1 <= 16777216,
            'fits_64KiB_file_buffer': b+1 <= 65536,
        }
        assert 3*row['parser_xstring_capacity'] < 2**32
        assert capacity+64 < 2**31
        assert all(row[k] for k in row if k.startswith('fits_'))
        storage['path_evaluations'].append(row)
    (HERE / 'storage.json').write_text(json.dumps(storage, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ['assumption_pool_find_calls', 'schema', 'pretty_string_bytes', 'emitted_file_bytes', 'emitted_file_bytes_at_P_222']}))


if __name__ == '__main__':
    main()
