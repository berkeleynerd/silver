#!/usr/bin/env python3
"""Check imported identities and new affine interfaces; execute no old checker."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile
import time

from transfer import abort, joined_json, normal, schema, single_line

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = ROOT / 'docs/evidence'
SOURCE = EV / 'retained-why-session-helper-source-20261019/sources.tar.gz'
RANGES = [
    ('src/util/json_base.ml', 13, 112),
    ('src/gnat/gnat_report.ml', 59, 85),
    ('src/gnat/gnat_report.ml', 130, 234),
    ('src/gnat/gnat_checks.ml', 818, 862),
    ('src/gnat/gnat_checks.ml', 940, 979),
    ('src/gnat/gnat_main.ml', 213, 281),
    ('src/gnat/gnat_manual.ml', 131, 145),
    ('src/gnat/gnat_util.ml', 1, 22),
]


def load(path):
    return json.loads(Path(path).read_text())


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def late_input(row):
    path = ROOT / row['path']
    raw = path.read_bytes() if path.exists() else subprocess.check_output(
        ['git', 'show', row['freeze'] + ':' + row['path']], cwd=ROOT)
    assert ident(raw) == row['identity'], row['path']
    return raw


def affine(fn, names, keys):
    zero = [0] * len(names)
    base = fn(*zero)
    result = {k: {'constant': base[k]} for k in keys}
    for i, name in enumerate(names):
        unit = zero.copy()
        unit[i] = 1
        value = fn(*unit)
        for k in keys:
            result[k][name] = value[k] - base[k]
    # An independent mixed-value evaluation checks the displayed expansion.
    point = list(range(1, len(names)+1))
    value = fn(*point)
    for k in keys:
        assert value[k] == result[k]['constant'] + sum(
            result[k][n]*v for n, v in zip(names, point))
    return result


def build(inputs):
    for path, expected in inputs['files'].items():
        assert ident((ROOT/path).read_bytes()) == expected, path
    late = {row['path']: late_input(row) for row in inputs['late_providers']}
    occurrences = json.loads(next(raw for path, raw in late.items() if path.endswith('/result.json')))
    assert b'Accepted under the named selected' in next(
        raw for path, raw in late.items() if '/reviews/' in path)

    source_witnesses = []
    with tarfile.open(SOURCE) as archive:
        source = {p: archive.extractfile('why3/'+p).read() for p, _, _ in RANGES}
        for path, first, last in RANGES:
            raw = source[path]
            lines = raw.decode().splitlines(keepends=True)
            assert 1 <= first <= last <= len(lines), path
            source_witnesses.append(dict(member='why3/'+path, identity=ident(raw),
                first_line=first, last_line=last, text=''.join(lines[first-1:last])))
    # Exact correspondence to the already accepted schema sources, no census.
    old_identity = load(EV/'retained-producer-response-20261018/identity.json')
    matched = 0
    for row in old_identity['files']:
        path = row['path'].removeprefix('why3/')
        if path in source:
            assert ident(source[path]) == {k: row[k] for k in ('bytes', 'sha256')}
            matched += 1
    assert matched == 5  # report, checks, main, util, json_base
    reused = next(r for r in load(EV/'retained-why-standard-formatter-core-20261020/source-witnesses.json')
                  if r['first_line'] == 1249 and r['member'].endswith('/stdlib/format.ml'))
    assert 'else Buffer.sub buf 1 (len - 2)' in reused['text']
    source_witnesses.append(dict(reused_provider='retained-why-standard-formatter-core-20261020/source-witnesses.json',
        member=reused['member'],identity=reused['member_identity'],first_line=1249,last_line=1256,
        text=''.join(reused['text'].splitlines(keepends=True)[:8])))
    json_source = source['src/util/json_base.ml'].decode()
    single = json_source.split('let rec print_json_single_line fmt v =')[1].split('(* Get json fields.')[0]
    assert 'List.sort' not in single and '@[' not in single and '@ ' not in single
    assert 'print_json_single_line Format.std_formatter' in source['src/gnat/gnat_report.ml'].decode()
    assert '"results", List []' in source['src/gnat/gnat_util.ml'].decode()
    assert sum(map(len, ['error', 'internal', 'results'])) == 20

    raw = affine(lambda *x: single_line(schema(*x)),
                 ['R', 'G', 'A', 'S', 'K', 'W', 'L_A', 'L_T', 'L_W'],
                 ['B', 'E', 'Q_strings'])
    assert raw['B'] == dict(constant=212,R=987,G=189,A=489,S=549,K=321,W=3,L_A=6,L_T=6,L_W=6)
    assert raw['E'] == dict(constant=81,R=358,G=73,A=66,S=79,K=5,W=3,L_A=2,L_T=2,L_W=2)
    assert raw['Q_strings'] == dict(constant=7456,R=36736,G=7568,A=5992,S=7712,K=72,W=72,L_A=256,L_T=256,L_W=256)
    compact = affine(normal, ['R','G','A','N','O','W_o','L_o','D','H'], ['B','E','Q_strings'])
    assert compact['B'] == dict(constant=14864,R=3732,G=189,A=873,N=3075,O=3111,W_o=3,L_o=6,D=3,H=6)
    assert compact['E'] == dict(constant=2313,R=753,G=73,A=194,N=1027,O=1039,W_o=3,L_o=2,D=3,H=2)
    assert compact['Q_strings'] == dict(constant=278384,R=75296,G=7568,A=22376,N=131144,O=132680,W_o=72,L_o=256,D=72,H=256)

    fixed = {}
    for stem in ['retained-producer-fixed-paths-20261018','retained-producer-fixed-check-spines-20261018']:
        for row in load(EV/stem/'result.json')['fixed_inputs']:
            fixed[row['native_input_sha256']] = row['response_record_bound']
    attached = {r['case']:r for r in load(EV/'retained-why-model-meta-control-20261020/attachment.json')['cases']}
    prefixes = {r['case']:r for r in load(EV/'retained-why-path-initial-state-20261020/prefix-attachment.json')}
    backtrace_inputs = {r['case']:r for r in load(EV/'retained-why-disabled-backtrace-20261020/input-attachment.json')}
    manifest = load(EV/'retained-why-save-state-capture-20261020/capture-manifest.json')
    captured_inputs = {r['member'].split('/')[1]:r for group in manifest['groups']
                       for r in group['local_plan_inputs_rehashed'] if r['member'].endswith('.gnat-json')}
    growth = {r['case']:r for r in load(EV/'retained-why-save-attempt-growth-20261020/applications.json')}
    fresh = {r['case']:r for r in load(EV/'retained-why-save-state-join-20261020/result.json')['cases']}
    timing = {r['case']:r for r in load(EV/'retained-why-exit-timing-growth-20261020/result.json')['cases']}
    writers = load(EV/'retained-why-path-writer-capacity-20261020/result.json')['cases']
    roots = {r['case']:r for r in occurrences['cases']}
    cases = []
    for row in writers:
        name, pid = row['case'], row['pid']
        at, gr, fr, ti, rt = attached[name], growth[name], fresh[name], timing[name], roots[name]
        assert pid == at['pid'] == fr['new_pid'] == ti['pid'] == rt['pid']
        pf, bt = prefixes[name], backtrace_inputs[name]
        for field in ('pid','argv','environment','cut_symbol','cut_elf_relative_pc'):
            assert pf[field] == bt[field], (name,field)
        assert pf['pid'] == pid and pf['cut_symbol'] == at['cut_symbol']
        sha = at['input_identity']['sha256']
        assert {k:captured_inputs[name][k] for k in ('bytes','sha256')} == at['input_identity']
        assert sha == gr['input_sha256']
        assert fr['logical_graph_correspondence_established']
        assert gr['inputs']['all_scripts_none']
        r, g = fixed[sha], row['registered_goals_upper']
        a = gr['conditional_transfer']['conditional_A_xml_upper']
        n = row['under_named_existing_premises']['dispatch_bounds']['preparation_episodes_intersecting_suffix_upper']
        assert n == 3*g+2 == ti['preparation_episodes_intersecting_suffix_upper']
        assert ti['reachable_timing_cells_upper'] == 26
        assert ti['total_distinct_key_bytes_upper'] == 1051
        assert rt['under_named_existing_relation']['normal_json_invocations_upper'] == 1
        assert rt['under_named_existing_relation']['abort_json_invocations_upper'] == 2
        assert rt['under_named_existing_relation']['scheduling_owners_upper'] == n
        coefficients = affine(lambda o,wo,lo,x: joined_json(r,g,a,n,o,wo,lo,x),
                              ['O','W_o','L_o','X'], ['B','E','Q_strings'])
        cases.append(dict(case=name,pid=pid,input_sha256=sha,
            conditional_inputs=dict(R=r,G=g,A=a,N=n,K=26,L_T=1051,D=1,H=26619),
            all_JSON_attempts_coefficients=coefficients,
            actual_B=None,actual_E=None,whole_standard_core_guards_established=False))
    assert [r['conditional_inputs']['R'] for r in cases] == [22,18,9,1,1]
    assert [r['conditional_inputs']['A'] for r in cases] == [208,173,108,12,9]
    hook = load(EV/'retained-why-debug-hook-capacity-20261020/result.json')
    assert hook['offered_Buffer_bytes_upper'] == 26619
    assert load(EV/'retained-why-model-meta-control-20261020/result.json')['get_model_for_selected_saved_calls'] == 'None'
    assert load(EV/'retained-why-standard-round42-20261020/integration-result.json')['standard_entry_to_interrupted_core_join']['core_initial_state_premise_discharged_under_named_relation']
    products = {
        'source-witnesses.json': source_witnesses,
        'transfer.json': dict(raw_schema_coefficients=raw, compact_normal_coefficients=compact,
            abort_at_zero_payload=abort(0),abort_payload_coefficients={'B':6,'E':2,'Q_strings':256},
            single_line_format_interface='H_f=2C+F+M+Nf+Nb; Z_f=2C+3F+M+Nf+Nb; M<=V-1',
            non_string_format_scalar_subtotal='128H_f+192Z_f+16(2C+F+M)+32Ni+464Nf',
            final_JSON_graph_block_subset='40V+24F+16Nf, excluding string storage; not cumulative construction',
            JSON_strings_subtotal='256L+72(F+Ns)',cases=cases),
        'result.json': dict(scope='Conditional standard JSON prospective inputs and partial noncore interfaces',
            cases=5,source_excerpts=len(source_witnesses),accepted_schema_source_identity_matches=matched,
            single_line_and_boxed_routes_separate=True,interrupted_attempt_multiplicity_preserved=True,
            input_byte_identity_join=True,normal_JSON_calls_upper=1,abort_JSON_calls_upper=2,
            actual_whole_JSON_B=None,actual_whole_JSON_E=None,actual_noncore_total=None,
            actual_whole_standard_B=None,actual_whole_standard_E=None,
            scalar_service_success=False,finite_JSON_numbers_established=False,
            complete_native_caller_stack=False,complete_R=False,complete_U=False,
            physical_sufficiency=False,whole_pipeline_capacity=False,
            issue_119_or_153_complete=False,production_started=False,
            new_target_runs=0,new_captures=0,disassemblers=0,source_fetches=0,
            solver_runs=0,proof_runs=0,predecessor_checker_replays=0)
    }
    return products


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.perf_counter()
    products = build(load(HERE/'inputs.json'))
    for name, value in products.items():
        path = HERE/name
        encoded = json.dumps(value,indent=2,sort_keys=True)+'\n'
        if args.write:
            path.write_text(encoded)
        else:
            assert path.read_text() == encoded, name
    print(json.dumps(dict(status='pass',mode='write' if args.write else 'comparison',
        cases=5,source_excerpts=len(products['source-witnesses.json']),affine_interfaces=3,
        elapsed_seconds=time.perf_counter()-start),indent=2))


if __name__ == '__main__':
    main()
