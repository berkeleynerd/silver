#!/usr/bin/env python3
"""Narrow source applicability, multiline census and correction-input audit."""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import re
import runpy
import subprocess
import time

REPO = Path(__file__).resolve().parents[2]
PACKET = REPO / 'docs/evidence/retained-literal-location-lifetime-20261018'
TARGET = '11057399b9e8806aa50a80122a978ae3c94f1958'
BASE = '1d5bcbe4469b8df7b5a260e2656a1dc0ef9b161a'


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(path.read_bytes())


def git(*args):
    return subprocess.check_output(['git', '-C', str(REPO), *args])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path, default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path, default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    args = parser.parse_args()
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    targets = []
    for name in git('diff', '--name-only', BASE, TARGET).decode().splitlines():
        raw = (REPO / name).read_bytes()
        check('frozen target ' + name, raw == git('show', TARGET + ':' + name))
        targets.append(dict(path=name, **identity(raw)))
    check('eleven target files', len(targets) == 11)
    roots = dict(gcc=args.gcc_root, ada=args.ada_root, repository=REPO)
    manifest = read(PACKET / 'inputs.json')
    for row in manifest['files']:
        check('identity ' + row['root'] + ':' + row['path'],
              identity((roots[row['root']] / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')})
    check('121 source and 33 repository records',
          sum(row['root'] != 'repository' for row in manifest['files']) == 121 and len(manifest['files']) == 154)
    retained = read(PACKET / 'check-results.json')
    check('retained 140-check success applies to callable and argument',
          retained['passed'] and retained['checks'] == len(retained['cases']) == 140 and
          retained['callable_identity'] == identity((PACKET / 'derive.py').read_bytes()) and
          retained['source_argument_identity'] == identity((REPO / 'docs/research/retained-literal-location-lifetime.md').read_bytes()))

    inventory = read(PACKET / 'writer-inventory.json')
    regex = re.compile(r'\b(get_or_create_combined_loc|make_location|set_source_range|'
                       r'location_with_discriminator(?:_components)?|set_block|tree_set_block|'
                       r'TREE_SET_BLOCK|gimple_set_block|rebuild_location_adhoc_htab)\s*\(')
    corpus = hashlib.sha256()
    extra, total, files = [], 0, []
    for directory in ('gcc', 'libcpp'):
        files.extend(p for p in (args.gcc_root / directory).rglob('*') if p.is_file() and p.suffix in ('.c', '.cc', '.h'))
    for path in sorted(files):
        name = path.relative_to(args.gcc_root).as_posix()
        raw = path.read_bytes()
        corpus.update((name + '\0' + str(len(raw)) + '\0' + identity(raw)['sha256'] + '\n').encode())
        text = raw.decode()
        known = {(row['line'], row['callee']) for row in inventory['location_writers'].get(name, [])}
        for match in regex.finditer(text):
            total += 1
            line = text.count('\n', 0, match.start()) + 1
            if (line, match[1]) not in known:
                extra.append(dict(path=name, line=line, callee=match[1]))
    check('same complete retained source corpus', len(files) == inventory['corpus_files'] == 3574 and
          corpus.hexdigest() == inventory['corpus_sha256'] == manifest['corpus_identity']['corpus_sha256'])
    check('one additional multiline constructor call', extra == [dict(path='gcc/tree-inline.cc', line=5051,
          callee='location_with_discriminator')])
    inline = (args.gcc_root / 'gcc/tree-inline.cc').read_text()
    start = inline.index('expand_call_inline (basic_block bb, gimple *stmt, copy_body_data *id,')
    call = inline.index('loc = location_with_discriminator\n', start)
    check('additional call is within actual inline expansion',
          inline.index('/* We will be inlining this callee.  */', start) < call and
          inline.index('cg_edge->callee->get_untransformed_body ();', start) < call)

    module = runpy.run_path(str(PACKET / 'derive.py'))
    shared = read(REPO / 'docs/evidence/retained-literal-original-shared-storage-20261018/result.json')
    source, counts = shared['source'], shared['source_counts']
    correction = module['corrected_shared_identifier_projection']
    check('pure correction equals separate retained Hello diagnostic',
          correction(shared, source, counts) == read(PACKET / 'shared-identifier-correction.json'))
    fields = [('identifier_hash', key) for key in shared['identifier_hash'] if key != 'checks']
    fields += [('identifier_hash', 'checks', key) for key in shared['identifier_hash']['checks']]
    fields += [('counter_endpoints', key) for key in ('incoming_temporary_name_serial_upper', 'next_temporary_name_serial_upper')]
    fields += [('counter_endpoints', 'checks', 'temporary_name_serial_unsigned')]
    for path in fields:
        changed = copy.deepcopy(shared)
        leaf = changed
        for key in path[:-1]:
            leaf = leaf[key]
        old = leaf[path[-1]]
        leaf[path[-1]] = not old if isinstance(old, bool) else old + 1
        try:
            correction(changed, source, counts)
        except ValueError:
            check('reject altered dependent predecessor field ' + '.'.join(path), True)
        else:
            raise AssertionError('accepted altered predecessor field ' + '.'.join(path))
    check('shared predecessor remains unchanged', shared == read(REPO / 'docs/evidence/retained-literal-original-shared-storage-20261018/result.json'))
    result = read(PACKET / 'result.json')
    check('separate location delta and open whole-process scope',
          result['additional_location_and_later_warning_GGC_events_upper'] == 13 and
          result['filename_ingress']['direct_GGC_requests_upper'] == 3180 and
          not result['filename_ingress']['included_in_new_location_warning_delta'] and
          result['total_GGC_events'] is result['whole_original_gigi_allocation_events'] is None and
          all(result[key] is False for key in ('complete_global_counter_lifetime_closed',
              'complete_collector_lifetime_closed', 'complete_gimplifier_lifetime_closed',
              'whole_literal_pipeline_capacity_established', 'production_admission_changed', 'aggregate_RAM_gate')))
    output = dict(target=TARGET, base=BASE, target_files=targets,
                  started_utc=started, completed_utc=datetime.now(timezone.utc).isoformat(),
                  elapsed_seconds=time.perf_counter()-timer, platform=platform.platform(),
                  source_roots={key:str(value) for key,value in roots.items()},
                  checks=len(checks), passed=checks, complete_corpus_files=len(files),
                  whole_text_location_matches=total, additional_multiline_matches=extra,
                  multiline_disposition='Nonblocking inventory limitation: the extra call is in actual inline expansion, excluded by the accepted selected O0/unavailable-callee argument.',
                  retained_focused_checks=140, retained_focused_elapsed_seconds=retained['elapsed_seconds'],
                  full_candidate_suite_rerun=False, candidate_Context_executed=False,
                  aggregate_evaluators_executed=0, native_tool_executions=0, prover_runs=0,
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_confirmed_model_effort=None, token_cost_measurements=None)
    destination = Path(__file__).with_suffix('.json')
    destination.write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps(dict(checks=len(checks), elapsed_seconds=output['elapsed_seconds'],
                         additional_multiline_matches=extra)))


if __name__ == '__main__':
    main()
