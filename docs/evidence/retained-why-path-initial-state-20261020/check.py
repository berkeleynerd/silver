#!/usr/bin/env python3
"""Check retained source/metadata inputs for the local suspended-frame argument.

This does not run an observer, reconstruct a stack, or prove source semantics.
--write seals only this packet's derived files; the default checks exact bytes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = 'docs/evidence/'
CAP = E + 'retained-why-save-state-capture-20261020/'
WHY = E + 'retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = E + 'retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
OP = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
INVENTORY = E + 'retained-why-path-input-inventory-20261020/capture-inventory.json'
NATIVE = E + 'retained-why-native-effect-completeness-20261019/'
CASES = [('put_line', 17310), ('put', 17514), ('first_or_default', 17631),
         ('is_message', 17704), ('input_is_valid', 17869)]
SPECS = {
    'why3/src/util/weakhtbl.ml': [(63, 91)],
    'why3/src/core/ident.ml': [(158, 177)],
    'why3/src/core/theory.ml': [(472, 500)],
    'why3/src/gnat/gnat_main.ml': [(265, 280), (298, 360)],
    'why3/src/gnat/gnat_checks.ml': [(501, 510), (750, 768)],
    'why3/src/gnat/gnat_scheduler.ml': [(1, None)],
    'why3/src/session/controller_itp.ml': [(412, 440), (517, 536),
                                           (578, 591), (641, 652)],
    'why3/src/driver/driver.ml': [(372, 390), (490, 494)],
    'why3/src/session/session_itp.ml': [(2099, 2107), (2212, 2245)],
    'why3/src/util/debug.ml': [(158, 205)],
    'why3/src/driver/prove_client.ml': [(108, 155)],
}
OSPECS = {
    'stdlib/ephemeron.ml': [(159, 221), (241, 265), (315, 335), (492, 560)],
    'stdlib/stdlib.ml': [(550, 572)],
    'stdlib/format.ml': [(1400, 1404)],
    'otherlibs/systhreads/thread.ml': [(81, 104)],
    'otherlibs/systhreads/st_stubs.c': [(723, 740)],
    'runtime/weak.c': [(112, 139), (326, 342)],
    'runtime/signals.c': [(199, 227), (260, 305)],
    'runtime/fail_nat.c': [(58, 88)],
}
REUSED = [INVENTORY, NATIVE + 'inputs.json', NATIVE + 'configuration.json',
    NATIVE + 'crt-weak-bindings.json', NATIVE + 'interface-summary.json',
    E + 'retained-why-restored-path-continuation-20261020/private-writer-census.json',
    E + 'retained-why-path-input-inventory-20261020/cut-evidence.json',
    'docs/research/retained-tool-source-identity.md',
    'docs/research/retained-why-inline-callback-closure.md',
    'docs/research/retained-why-save-preservation.md',
    'docs/research/retained-why-native-effect-completeness.md',
    'docs/research/retained-why-session-formatter-prefix-repair.md',
    'docs/reviews/review-save-capacity-round31-20261020.md']


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def encoded(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def build():
    files, members, witnesses = {}, {}, []

    def file(path):
        data = (ROOT / path).read_bytes()
        files[path] = identity(data)
        return data

    def member(t, archive, name):
        data = t.extractfile(name).read()
        members[archive + ':' + name] = identity(data)
        return data

    reused = {p: file(p) for p in REUSED}
    for archive, specs in [(WHY, SPECS), (OCAML, {OP+k:v for k,v in OSPECS.items()})]:
        file(archive)
        with tarfile.open(ROOT / archive) as t:
            for name, ranges in specs.items():
                data = member(t, archive, name)
                lines = data.decode().splitlines(keepends=True)
                for first, last in ranges:
                    last = last or len(lines)
                    excerpt = ''.join(lines[first-1:last])
                    witnesses.append({'archive': archive, 'member': name,
                        'member_identity': identity(data), 'first': first, 'last': last,
                        'excerpt_identity': identity(excerpt.encode()), 'text': excerpt})

    archive = CAP + 'capture-common.tar.gz'
    file(archive)
    with tarfile.open(ROOT / archive) as t:
        plans = {phase: json.loads(member(t, archive, phase+'/plan.json'))
                 for phase in ['registration', 'inline']}
    native = json.loads(reused[NATIVE+'crt-weak-bindings.json'])
    expected_images = {r['path']: {k:r[k] for k in ['bytes','sha256']}
                       for r in native['images']}
    inventory = json.loads(reused[INVENTORY])
    attachments, selections = [], []
    for i, (case, pid) in enumerate(CASES):
        phase = 'inline' if case == 'input_is_valid' else 'registration'
        archive = CAP + 'capture-' + case.replace('_','-') + '.tar.gz'
        file(archive)
        prefix = phase + '/' + case + '/capture/'
        symbol_member = 'session-observer' if phase == 'inline' else 'session-symbols'
        with tarfile.open(ROOT / archive) as t:
            obs = {name: json.loads(member(t, archive, prefix+name+'.json'))
                   for name in ['process','summary','exit-hook-roots',symbol_member]}
        proc, summary, hooks, symbols = (obs[k] for k in
            ['process','summary','exit-hook-roots',symbol_member])
        plan = plans[phase]
        entry = next(r for r in plan['inputs'] if r['name'] == case)
        assert proc['pid'] == pid and proc['initial_threads'] == 1
        assert proc['argv'] == entry['argv'] and proc['environment'] == entry['environment']
        assert proc['environment']['OCAMLRUNPARAM'] == 's=256M,h=16M,M=1000'
        assert plan['source_revision'] == '9390baf120ef260547dfa14f08e11c890b203d9c'
        assert plan['runtime_candidate_revision'] == '8eb41f72ded84df884c3671734c947f612091f84'
        assert summary['mapped_files'] == expected_images
        assert summary['completed'] and not summary['failures']
        assert not summary['new_threads'] and not summary['guard_hits']
        assert all(r['hits'] == 0 for r in summary['forbidden_calls'].values())
        bias = symbols['load_bias']
        if phase == 'registration':
            for r in symbols['checks'].values():
                assert r['address'] == bias + r['elf_value']
        chain = hooks['exit_chain']
        assert hooks['complete'] and not hooks['failures'] and not hooks['unknown_closures']
        assert len(chain) == 3
        assert [r['code']-bias for r in chain] == [0x941560,0x941560,0x9406e0]
        assert [r['callback']['code']-bias for r in chain[:2]] == [0x55a680,0x98b6a0]
        assert [r['gate'] for r in chain[:2]] == [3,3]
        assert hooks['statistic_values']['roots'] == []
        assert hooks['statistic_values']['blocks'] == 0
        for j in range(2):
            assert chain[j]['raw_fields'][4] == chain[j+1]['address']
            assert chain[j]['raw_fields'][2] == chain[j]['callback']['address']
        if phase == 'registration':
            stop = next(r for r in summary['snapshots'] if r['label']=='end_of_registration')
            pc = int(stop['pc'],16) - bias
            assert pc == plan['endpoint']['address'] == 0x530a10
            endpoint = 'camlGnat_checks__iter_2373'
            directives = []
        else:
            # The inline plan's inherited endpoint is intentionally not used.
            stop = summary['snapshots'][-1]
            assert stop['label'] == 'inline_trivial_entry'
            pc = int(stop['pc'],16) - bias
            assert pc == plan['entry_observers']['apply']['address'] == 0x5d7aa0
            assert summary['inline_entry']
            endpoint = plan['entry_observers']['apply']['symbol']
            directives = summary['driver_preparation'][-1]['visited_directives']
            assert directives == ['counterexamples_dependent_intros','inline_trivial']
        attachments.append({'case':case,'pid':pid,'phase':phase,'argv':proc['argv'],
            'environment':proc['environment'],'mapped_image_count':len(expected_images),
            'same_images_as_native_initialization_argument':True,
            'initial_threads':1,'new_threads':[], 'cut_symbol':endpoint,
            'cut_snapshot_label':stop['label'], 'cut_observed_pc':stop['pc'],
            'load_bias':bias,'cut_elf_relative_pc':hex(pc),'directives':directives,
            'endpoint_backtrace':None,'protected_guard_hits':[],
            'startup_guard_count':len(summary['startup_guard_hits']),
            'exit_chain_code_offsets':[hex(r['code']-bias) for r in chain],
            'exit_callback_code_offsets':[hex(r['callback']['code']-bias) for r in chain[:2]],
            'exit_gate_raw_values':[3,3],'registered_statistics_roots':[],
            'metadata_observation_not_new_stack_capture':True})
        row = inventory['cases'][i]
        assert row['case'] == case and row['cached_hash_max_multiplicity'] == 1
        assert row['captured_current_serialized_candidate_set_complete_under_cached_hash_premise']
        candidates = [c for s in row['serialized_identifier_selections'] for c in s['candidates']]
        assert len(candidates) == 2
        paths = [c['payload']['qualified_path'] for c in candidates]
        assert sorted(p['joined_dot_bytes'] for p in paths) == [0,6]
        assert sorted(p['component_count'] for p in paths) == [0,1]
        assert row['old_bucket_array_roots'] is None
        selections.append({'case':case,'pid':pid,
            'serialized_identifier_count':row['serialized_identifier_count'],
            'current_cells':row['current_entry_count'],
            'absent_serialized_tags':row['serialized_tags_without_current_cached_hash_match'],
            'present_serialized_tags':2,'nonempty_initial_path_bytes_upper':6,
            'nonempty_initial_path_components_upper':1,
            'initial_identifier_weighted_bytes_upper':row['serialized_identifier_current_candidate_weighted_bytes_upper'],
            'resumable_old_array_exclusion':'local source/control theorem under named behavior relation',
            'old_array_values_observed':None,
            'all_current_payloads_decoded':row['all_current_payloads_decoded'],
            'whole_interval_path_bytes_upper':None})
    assert [r['initial_identifier_weighted_bytes_upper'] for r in selections] == [607,503,334,74,86]
    result = {'schema':1,'base_commit':'2866d4642c43444abd18e0b6e9600edaa216b99b',
        'kind':'source control theorem with checked retained-input attachment',
        'semantic_argument':'docs/research/retained-why-path-initial-state.md',
        'scope':'five named cuts; initial selectable paths for captured serialized tags',
        'suspended_pre_cut_theory_table_mutation_excluded_under_named_relation':True,
        'initial_selectable_payload_set_complete_under_named_relation':True,
        'initial_nonempty_qualified_path_bytes_upper':6,
        'cases':selections,'endpoint_stack_observed':False,
        'no_signals_assumed':False,'identifier_tag_freshness_assumed':False,
        'whole_pre_cut_no_new_why_root_proved':False,
        'whole_post_cut_native_effect_completeness_proved':False,
        'whole_interval_R':None,'whole_interval_U':None,'complete_save_capacity':False,
        'native_runs':0,'observer_replays':0,'new_captures':0,'source_fetches':0,
        'solver_requests':0,'semantic_theorem_proved_by_python':False}
    return {'inputs.json':{'files':files,'members':members},
            'source-witnesses.json':witnesses,'prefix-attachment.json':attachments,
            'result.json':result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write',action='store_true')
    args = parser.parse_args()
    start = time.perf_counter()
    outputs = build()
    for name,value in outputs.items():
        data=encoded(value)
        if args.write:
            (HERE/name).write_bytes(data)
        else:
            assert (HERE/name).read_bytes()==data,name
    print(json.dumps({'passed':True,'source_witnesses':len(outputs['source-witnesses.json']),
        'fresh_process_attachments':len(outputs['prefix-attachment.json']),
        'elapsed_seconds':time.perf_counter()-start,'native_runs':0,'observer_replays':0,
        'endpoint_stack_observed':False,'semantic_theorem_proved_by_python':False},indent=2))


if __name__=='__main__':
    main()
