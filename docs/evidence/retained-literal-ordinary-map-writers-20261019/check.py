#!/usr/bin/env python3
"""Replay the ordinary-map reference census and its frozen source identities.

This is an offline consistency check, not a call-graph or reachability prover.
The source argument and selected-configuration premises live in the note.
"""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
SYMBOLS = (
    'linemap_add', 'linemap_line_start', 'linemap_position_for_column',
    'line_map_new_raw', 'linemap_module_loc', 'linemap_module_restore',
    'cpp_create_reader', 'gcc_json_context', 'physical_location_maker',
)
SELFTESTS = {
    'gcc/input.cc': (1106, 3369),
    'gcc/opt-problem.cc': (95, 334),
    'gcc/dumpfile.cc': (2144, 2796),
    'gcc/diagnostics/changes.cc': (902, 1854),
    'gcc/diagnostics/context.cc': (2001, 2333),
    'gcc/diagnostics/source-printing.cc': (4040, 7048),
    'gcc/diagnostics/paths-output.cc': (1460, 2794),
    'gcc/diagnostics/sarif-sink.cc': (4668, 5426),
}
MEMBERS = r'info_ordinary\.(?:maps|allocated|used)|LINEMAPS_(?:ALLOCATED|USED)\s*\('


def census(root):
    pattern = r'\b(?:' + '|'.join(SYMBOLS) + r')\b|' + MEMBERS
    result = subprocess.run(
        ['rg', '--no-ignore', '--hidden', '--line-number', '--with-filename',
         '--only-matching', pattern, 'gcc', 'libcpp'],
        cwd=root, check=True, capture_output=True, text=True)
    grouped = defaultdict(list)
    for row in result.stdout.splitlines():
        path, line, symbol = row.split(':', 2)
        grouped[path].append({'line': int(line), 'symbol': symbol})
    return {path: sorted(rows, key=lambda r: (r['line'], r['symbol']))
            for path, rows in sorted(grouped.items())}


def identity(path):
    raw = path.read_bytes()
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output', type=Path, default=HERE / 'check-results.json')
    args = parser.parse_args()
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    roots = {'gcc': args.gcc_root, 'repo': REPO}
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    for row in inputs['files']:
        check('identity ' + row['root'] + ':' + row['path'],
              identity(roots[row['root']] / row['path']) ==
              {key: row[key] for key in ('bytes', 'sha256')})
    observed = census(args.gcc_root)
    expected = json.loads((HERE / 'references.json').read_text())
    check('exact reference census, including comments and declarations', observed == expected)
    for path, (start, end) in SELFTESTS.items():
        # Source coordinates use LF; form-feed page separators are not lines.
        lines = (args.gcc_root / path).read_text().split('\n')
        check('CHECKING_P section ' + path,
              lines[start - 1] == '#if CHECKING_P' and
              lines[end - 1].startswith('#endif') and 'CHECKING_P' in lines[end - 1])
        check('all allocating API references inside test section ' + path,
              all(start < row['line'] < end for row in observed[path]
                  if row['symbol'] in SYMBOLS[:6]))
    ada_paths = {p for p, rows in observed.items() if p.startswith('gcc/ada/')
                 and any(row['symbol'] in SYMBOLS[:6] for row in rows)}
    check('Ada allocating API source is only trans.cc',
          ada_paths == {'gcc/ada/gcc-interface/trans.cc'})
    check('Ada allocating references are only preallocation lines',
          [r['line'] for r in observed['gcc/ada/gcc-interface/trans.cc']
           if r['symbol'] in SYMBOLS[:6]] == [358, 360, 361, 362])
    pre = REPO / 'docs/evidence/retained-literal-ordinary-maps-20261018'
    pre_inputs = json.loads((pre / 'inputs.json').read_text())
    inherited = [r for r in pre_inputs['files'] if r['root'] == 'gcc']
    inherited += [dict(r, path='gcc/ada/' + r['path']) for r in pre_inputs['files']
                  if r['root'] == 'ada' and r['path'].startswith('gcc-interface/')]
    for row in inherited:
        check('accepted preallocation source equality ' + row['path'],
              identity(args.gcc_root / row['path']) ==
              {key: row[key] for key in ('bytes', 'sha256')})
    graph_path = REPO / 'docs/evidence/retained-literal-invocation-join-20261018/result.json'
    graph = json.loads(graph_path.read_text())
    main_role = [p for p in graph['processes'] if p['role'] == 'Main_compile']
    check('unique retained Main compiler role', len(main_role) == 1)
    argv = main_role[0]['argv']
    check('retained selected Ada route', argv[1:4] == ['-c', '-x', 'ada'] and
          '/x86_64-pc-linux-gnu/' in main_role[0]['child_frontend']['executable'])
    check('no excluded selector in retained Main argv', not any(
          arg.startswith(('-flto', '-fself-test', '-fplugin', '-specs', '@')) for arg in argv))
    result = json.loads((pre / 'result.json').read_text())
    check('accepted three-request preallocation result unchanged',
          result['additional_GGC_events_upper'] == 3 and
          [row['rounded_GGC_bytes'] for row in result['allocation_rows']] ==
          [8192, 32768, 131072] and result['additional_finalizers_upper'] == 0)
    output = {
        'started_utc': started,
        'completed_utc': datetime.now(timezone.utc).isoformat(),
        'elapsed_seconds': time.perf_counter() - timer,
        'checks': len(checks), 'passed': checks,
        'reference_files': len(observed),
        'symbol_references': sum(len(rows) for rows in observed.values()),
        'source_argument_is_separate_from_consistency_checks': True,
        'native_tool_executions': 0, 'prior_successful_suites_rerun': False,
        'whole_native_capacity_established': False,
        'independent_review_included': False,
        'lead_live_model_effort': None, 'token_cost_measurements': None,
        'implementation_inputs': {name: identity(HERE / name)
            for name in ('check.py', 'inputs.json', 'references.json')},
    }
    args.output.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps({key: output[key] for key in
        ('checks', 'reference_files', 'symbol_references', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
