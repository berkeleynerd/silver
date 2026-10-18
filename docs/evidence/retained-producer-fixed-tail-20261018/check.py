#!/usr/bin/env python3
"""Replay fixed initial-split/registration evidence offline; no native execution.

Source dispatch/operation coverage and fixed-execution transfer remain inspected
arguments. Physical managed storage does not bound unfolded formula occurrences.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
LIMIT = 2**62 - 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def archive(path):
    with tarfile.open(path) as stream:
        members = stream.getmembers()
        assert all(m.isfile() for m in members)
        assert len(members) == len({m.name for m in members})
        return {m.name: stream.extractfile(m).read() for m in members}


def uncomment(text):
    """Keep strings/newlines while removing the retained driver's nested comments."""
    out = []; i = 0; depth = 0; quoted = False
    while i < len(text):
        c = text[i]
        if depth:
            if text.startswith('(*', i): depth += 1; out += '  '; i += 2
            elif text.startswith('*)', i): depth -= 1; out += '  '; i += 2
            else: out.append('\n' if c == '\n' else ' '); i += 1
        elif quoted:
            out.append(c); i += 1
            if c == '\\':
                assert i < len(text); out.append(text[i]); i += 1
            elif c == '"': quoted = False
        elif text.startswith('(*)', i):
            # Driver_lexer.token treats this multiplication operator specially.
            out += '(*)'; i += 3
        elif text.startswith('(*', i): depth = 1; out += '  '; i += 2
        else:
            out.append(c); i += 1
            if c == '"': quoted = True
    assert depth == 0 and not quoted
    return ''.join(out)


def driver_dispatch(texts, top, resolution):
    directives = []
    def visit(path, stack):
        assert path not in stack
        text = uncomment(texts[path].decode())
        for number, line in enumerate(text.splitlines(), 1):
            match = re.fullmatch(r'\s*(import|transformation|printer)\s+"([^"\\]*)"\s*', line)
            if not match:
                assert not re.match(r'\s*(import|transformation|printer)\b', line), (path, number, line)
                continue
            kind, name = match.groups()
            if kind == 'import':
                matches = [r['candidates'][0] for r in resolution[path]['imports'] if r['name'] == name]
                assert len(matches) == 1
                visit(matches[0], stack + [path])
            else: directives.append(dict(kind=kind, name=name, path=path, line=number))
    visit(top, [])
    printers = [r['name'] for r in directives if r['kind'] == 'printer']
    assert len(printers) == 1
    return dict(printer=printers[0], transformations=[r for r in directives if r['kind'] == 'transformation'])


def registration_join(raw, original, manifest):
    """Replay the one-input classification; it is not a second five-case bound."""
    get = lambda name: json.loads(raw[name])
    plan = get('plan.json'); prior = json.loads(original['plan.json'])
    root = manifest['registration_capture_root']; old_root = manifest['capture_root']
    assert len(plan['inputs']) == 1
    case = plan['inputs'][0]; name = case['name']; assert name == 'input_is_valid'
    old_case = next(c for c in prior['inputs'] if c['name'] == name)
    relocate = lambda obj: json.loads(json.dumps(obj).replace(old_root, root))
    assert case == relocate(old_case)
    for key in ('source_revision', 'guards', 'protected_start', 'endpoint',
                'state_fields', 'arithmetic_sites', 'observer', 'forbidden_calls',
                'dispatch_observers', 'server_identity'):
        assert plan[key] == prior[key], key
    assert get('driver-resolution.json') == relocate(json.loads(original['driver-resolution.json']))
    for path, row in plan['file_identities'].items():
        if path.startswith(root+'/'):
            assert identity(raw[path[len(root)+1:]]) == row
        else:
            assert row == prior['file_identities'][path]
    for f in ['why3.conf', case['argv'][-1]]:
        assert raw[name+'/'+f] == original[name+'/'+f]
    for f in ('why3.conf', 'cvc5_gnatprove.drv', 'silver_cvc5_no_steps.gen',
              'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv'):
        assert raw['overlay/'+f] == original['overlay/'+f]
    summary = get(name+'/capture/summary.json')
    old_summary = json.loads(original[name+'/capture/summary.json'])
    assert summary['completed'] and summary['protected']
    assert not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
    assert summary['previous_endpoint_visits'] == 1
    assert summary['mapped_files'] == old_summary['mapped_files']
    for family in ('guards', 'forbidden_calls'):
        assert set(summary[family]) == set(old_summary[family])
        for symbol, row in summary[family].items():
            assert row['first32'] == old_summary[family][symbol]['first32']
            if family == 'forbidden_calls': assert row['hits'] == 0
    for label, row in summary['arithmetic'].items():
        assert raw[name+'/capture/'+label+'.operands'] == original[name+'/capture/'+label+'.operands']
        assert not row['violations'] and row['hits'] == old_summary['arithmetic'][label]['hits']
    proc = get(name+'/capture/process.json')
    assert proc['argv'] == case['argv'] and proc['environment'] == case['environment']
    assert proc['initial_threads'] == 1
    assert summary['dispatch']['connection'][0]['socket_name'] == case['server']['socket']
    assert len(summary['dispatch']['connection']) == len(summary['dispatch']['transform']) == len(summary['dispatch']['graft']) == 1
    assert len(summary['dispatch']['graft'][0]['tasks']) == 4
    for event in summary['dispatch']['transform']+summary['dispatch']['graft']:
        assert event['name'] == 'split_goal_wp_conj' and event['argument_count'] == 0
    for label, spec in plan['registration_observers'].items():
        assert summary['registration_observers'][label]['first32'] == spec['first32']
    rows = summary['registration']; assert [r['goal_id'] for r in rows] == [1,2,3,4]
    common = ['vc:annotation', 'expl:precondition', 'hyp_name:Requires']
    check = dict(id=0, kind_ordinal=24, shape='if__return__call_is_message__call_argument', already_proved=False)
    for row, call in zip(rows, [54,55,56,57]):
        labels = common + ([] if row['goal_id'] != 3 else [
            'GP_Shape:'+check['shape'],
            'GP_Check:0:VC_PRECONDITION:silver_arguments.adb:14:43']) + ['rac:call_id:'+str(call)]
        assert row['labels_read'] == labels
        if row['goal_id'] == 3:
            assert not row['is_trivial'] and row['selected_check'] == check
            assert row['decision'] == 'add_to_check' and row['toplevel']
        else:
            assert row['is_trivial'] and row['selected_check'] is None
            assert row['decision'] == 'set_not_interesting'
    endpoint = summary['registration_endpoint']
    assert endpoint == dict(checks=[dict(check=check,to_be_scheduled=[3],to_be_proved=[3],toplevel=[3])],
                            goalmap=[dict(goal_id=3,check=check)],total_nb_goals=1,nb_checks=1,not_interesting=[1,2,4])
    run = get('result.json')['cases'][0]
    assert run['completed'] and run['returncode'] == 0 and not run['timed_out'] and not run['failures']
    server = get(name+'/capture/server.json')
    assert server['actual_argv'] == case['server']['argv'] and server['actual_environment'] == case['server']['environment']
    assert server['binary'] == plan['server_identity'] and server['returncode'] == 1 and not server['forced_cleanup']
    assert raw[name+'/capture/server.log'] == b''
    events = [json.loads(line) for line in raw['managed/events.jsonl'].splitlines()]
    assert events[-1]['outcome'] == 'success' and events[-1]['run_id'] == manifest['registration_managed_run']
    return dict(raw_tasks=4,registered_toplevel_goals=1,not_interesting_goals=3,
                registered_goal_ids=[3],reported_G_bound=1,source_filter_join_established=True,
                classifications=rows,endpoint=endpoint,managed_run=manifest['registration_managed_run'],
                managed_seconds=events[-1]['duration_seconds'],debugger_seconds=run['duration_seconds'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE/'identity.json').read_bytes())
    for path, expected in manifest['dependencies'].items():
        assert identity((REPO/path).read_bytes()) == expected, path
    archived = {}
    for name, expected in manifest['archives'].items():
        assert identity((HERE/name).read_bytes()) == expected['identity']
        data = archive(HERE/name)
        assert {n:identity(b) for n,b in data.items()} == expected['members']
        archived[name] = data
    raw, sources = archived['observations.tar.gz'], archived['sources.tar.gz']
    registration = registration_join(archived['registration.tar.gz'], raw, manifest)
    prior_sources = archive(EVIDENCE/'retained-producer-prefix-composition-20261018/sources.tar.gz')
    for path in manifest['why3_sources_joined_to_prior']:
        assert sources[path] == prior_sources[path], path
    previous = EVIDENCE/'retained-producer-prefix-per-check-20261018'
    subprocess.run([sys.executable,str(previous/'check.py')],check=True,cwd=REPO,stdout=subprocess.DEVNULL)
    old = archive(previous/'observations.tar.gz')
    old_plan = json.loads(old['plan.json'])
    old_result = json.loads((previous/'result.json').read_bytes())
    old_cases = {r['name']:r for r in old_result['cases']}
    get = lambda name:json.loads(raw[name])
    plan = get('plan.json'); root = manifest['capture_root']
    old_root = json.loads((previous/'identity.json').read_bytes())['capture_root']
    assert plan['source_revision'] == old_plan['source_revision'] == manifest['why3_revision']
    for key in ('runtime_candidate_revision','guards','protected_start','state_fields','arithmetic_sites','observer'):
        assert plan[key] == old_plan[key], key
    assert plan['previous_endpoint'] == old_plan['endpoint']
    assert plan['endpoint']['symbol'] == 'camlGnat_checks__iter_2373'
    assert plan['endpoint']['address'] == 0x530a10
    assert plan['endpoint']['first32'] == '4883ec0848890424bf01000000488d05fcb65c00488b98a0000000488d05a6af'
    assert len(plan['forbidden_calls']) == 10
    changed = {'run.py','probe.py','driver-resolution.json'}
    for path, expected in old_plan['file_identities'].items():
        if path.startswith(old_root+'/') and path[len(old_root)+1:] in changed: continue
        assert plan['file_identities'][path.replace(old_root,root)] == expected, path
    for name,data in raw.items():
        if root+'/'+name in plan['file_identities']:
            assert identity(data) == plan['file_identities'][root+'/'+name]
    spec = importlib.util.spec_from_file_location('gc',EVIDENCE/'retained-producer-prefix-gc-20261018/check.py')
    gc = importlib.util.module_from_spec(spec); spec.loader.exec_module(gc)
    assert plan['guards'] == list(gc.GUARDS)
    sites = json.loads((EVIDENCE/'retained-producer-prefix-counts-20261018/identity.json').read_bytes())['sites']
    dimensions = json.loads((EVIDENCE/'retained-producer-prefix-gc-20261018/dimensions-inputs.json').read_bytes())
    dim_raw = archive(EVIDENCE/'retained-producer-prefix-gc-20261018/dimensions-sources.tar.gz')
    texts = {p:dim_raw[row['member']] for p,row in dimensions['installed_text'].items()}
    texts.update({root+'/'+p:b for p,b in raw.items() if p.startswith('overlay/')})
    resolution = get('driver-resolution.json')
    assert resolution == json.loads(json.dumps(json.loads(old['driver-resolution.json'])).replace(old_root,root))
    assert len(resolution) == 14
    for path,row in resolution.items(): assert identity(texts[path]) == row['identity']
    dispatch = {name:driver_dispatch(texts,root+'/overlay/'+filename,resolution)
                for name,filename in [('cvc5','cvc5_gnatprove.drv'),('z3','z3_gnatprove.drv'),('altergo','alt_ergo_gnatprove_smt2.drv')]}
    static_words = (sum(row['load_memory_bytes'] for row in dimensions['images'].values())+7)//8
    assert static_words == old_result['loaded_image_word_overcount']
    rows = []
    runs = get('result.json')['cases']
    assert len(runs) == len(plan['inputs']) == 5
    for case, prior, run in zip(plan['inputs'],old_plan['inputs'],runs):
        name = case['name']; assert run['name'] == prior['name'] == name
        expected = json.loads(json.dumps(prior).replace(old_root,root))
        expected['argv'][-1:-1] = ['--socket',case['cwd']+'/server.sock']
        assert {k:case[k] for k in expected} == expected
        server = case['server']
        assert server == dict(argv=[str(Path(case['argv'][0]).with_name('why3server')),'--socket','server.sock','--single-client','-j','1'],cwd=case['cwd'],environment={'PATH':'/usr/bin:/bin','LC_ALL':'C'},socket=case['cwd']+'/server.sock')
        assert len(Path(server['socket']).name.encode()) == 11 < 108
        assert case['environment'] == get(name+'/capture/process.json')['environment']
        assert case['argv'] == get(name+'/capture/process.json')['argv']
        assert get(name+'/capture/process.json')['initial_threads'] == 1
        assert identity(raw[name+'/'+case['argv'][-1]]) == case['input'] == prior['input']
        assert raw[name+'/why3.conf'] == old[name+'/why3.conf']
        assert run['completed'] and run['returncode']==0 and not run['timed_out']
        assert not run['failures'] and not run['guard_hits']
        summary = get(name+'/capture/summary.json')
        assert summary['completed'] and summary['protected']
        assert not summary['failures'] and not summary['guard_hits'] and not summary['new_threads']
        assert summary['previous_endpoint_visits'] == 1
        assert set(summary['guards']) == set(plan['guards'])
        old_summary = json.loads(old[name+'/capture/summary.json'])
        for guard,row in summary['guards'].items(): assert row['first32']==old_summary['guards'][guard]['first32']
        assert [r['guard'] for r in summary['startup_guard_hits']] == [r['guard'] for r in old_summary['startup_guard_hits']]
        assert len(summary['snapshots']) == 4
        start,middle,end = summary['snapshots'][1:]
        assert summary['baseline'] == start
        assert [r['label'] for r in (start,middle,end)] == ['before_first_why3_module','before_server_and_split','end_of_registration']
        for snap in (start,middle,end):
            s = snap['state']
            assert snap['native_r14'] == snap['state_address']
            assert s['young_limit'] == s['young_trigger'] == s['young_alloc_start']
            assert s['young_alloc_end']-s['young_alloc_start'] == 8*2**28
            assert s['minor_heap_wsz'] == snap['caml_init_minor_heap_wsz'] == 2**28
            assert snap['caml_init_heap_wsz'] == s['stat_heap_wsz'] == 2**24
            assert snap['caml_custom_major_ratio'] == 1000
            assert snap['minor_allocated_words'] == (s['young_alloc_end']-snap['effective_young_ptr'])//8
            assert 0<=snap['minor_allocated_words']<2**28 and 0<=snap['caml_allocated_words']<2**28
            assert snap['caml_gc_phase'] == 0
            assert all(s[k]==0 for k in ('in_minor_collection','requested_major_slice','requested_minor_gc'))
            assert 0<=s['extra_heap_resources_minor']<1 and 0<=snap['caml_extra_heap_resources']<1
            assert snap['caml_dependent_size']==snap['caml_dependent_allocated']==0
            for table in snap['tables'].values():
                assert table['used_entries']==(table['ptr']-table['base'])//table['entry_size']
                assert table['ptr']<table['threshold']==table['limit']
                assert (table['threshold']-table['base'])//table['entry_size']==2**25
            assert all(s[k]==start['state'][k] for k in gc.STATS)
        def words(snap): return snap['minor_allocated_words']+snap['caml_allocated_words']
        assert words(start)<=words(middle)<=words(end)
        startup = start['state']['stat_minor_words']+start['state']['stat_major_words']+words(start)
        assert startup == int(startup)
        assert summary['mapped_files']==old_summary['mapped_files']
        opened = set()
        assert summary['file_open_site']['first32']==plan['observer']['first32']
        for event in summary['file_opens']:
            if event['fd']>=0 and event['flags']&3==0:
                assert event['identity']==plan['file_identities'][event['resolved_path']]
                opened.add(event['resolved_path'])
        assert set(plan['required_overlay_paths'])<=opened
        assert set(plan['selected_driver_closure'].values())<=opened
        arithmetic = {}
        for label,observed in summary['arithmetic'].items():
            site = sites[label]
            assert observed['first32']==site['first32'] and observed['operation']==site['operation']
            assert not observed['violations']
            data=raw[name+'/capture/'+label+'.operands']; assert identity(data)==observed['trace']
            assert len(data)%16==0
            pairs=list(struct.iter_unpack('<qq',data)); values=[]
            for a,b in pairs:
                value=a*b if site['operation']=='multiply' else a+b
                assert 0<=a<=LIMIT and 0<=b<=LIMIT and 0<=value<=LIMIT
                values.append(value)
            computed=dict(hits=len(pairs),minimum_left=min(a for a,b in pairs),minimum_right=min(b for a,b in pairs),maximum_left=max(a for a,b in pairs),maximum_right=max(b for a,b in pairs),maximum_result=max(values))
            assert computed=={k:observed[k] for k in computed}
            before=summary['arithmetic_at_previous_endpoint'][label]
            assert before==old_cases[name]['arithmetic'][label]['hits']
            assert data[:16*before]==old[name+'/capture/'+label+'.operands']
            computed['post_init_hits']=len(pairs)-before
            arithmetic[label]=computed
        observed=summary['dispatch']
        assert len(observed['connection'])==1 and observed['connection'][0]['socket_name']==server['socket']
        assert len(observed['transform'])==len(observed['graft'])==1
        for event in observed['transform']+observed['graft']:
            assert event['name']=='split_goal_wp_conj' and event['argument_count']==0
        task_rows=observed['graft'][0]['tasks']
        assert task_rows
        for t in task_rows+[observed['transform'][0]['input_task']]:
            assert t['chain_length']==len(t['declaration_addresses'])
        assert set(summary['forbidden_calls'])==set(plan['forbidden_calls'])
        for symbol,event in summary['forbidden_calls'].items():
            assert event['hits']==0 and event['first32']==plan['forbidden_calls'][symbol]['first32']
        server_run=get(name+'/capture/server.json')
        assert server_run['actual_argv']==server['argv'] and server_run['actual_environment']==server['environment']
        assert server_run['binary']==plan['server_identity']==plan['file_identities'][server['argv'][0]]
        assert not server_run['forced_cleanup'] and server_run['returncode']==1
        assert raw[name+'/capture/server.log']==b''
        rows.append(dict(name=name,input_sha256=case['input']['sha256'],prefix_words=words(middle)-words(start),post_init_words=words(end)-words(middle),total_words=words(end)-words(start),gc7_prefix_word_delta=words(middle)-words(start)-old_cases[name]['allocation_words'],startup_word_overcount=int(startup),raw_split_tasks=len(task_rows),maximum_task_chain_length=max(t['chain_length'] for t in task_rows),input_task_chain_length=observed['transform'][0]['input_task']['chain_length'],arithmetic=arithmetic,server_teardown_exit=server_run['returncode'],debugger_seconds=run['duration_seconds']))
    w=max(r['total_words'] for r in rows)
    b=w+max(r['startup_word_overcount'] for r in rows)+static_words
    count=max(a['maximum_result'] for r in rows for a in r['arithmetic'].values())
    checks=dict(identity_counter=(w+1,LIMIT),synthetic_line=(w+1,2**47-1),physical_words=(b,LIMIT),dependency_rank_and_midpoint=(2*b+2,LIMIT),projection_height=(b+65536,LIMIT),byte_length_arithmetic=(16*b+2,LIMIT),semantic_count=(count,LIMIT),split_triviality_accumulator=(3,LIMIT),unfold_depth=(1,LIMIT))
    assert all(0<=upper<limit for upper,limit in checks.values())
    events=[json.loads(line) for line in raw['managed/events.jsonl'].splitlines()]
    assert events[-1]['event']=='finished' and events[-1]['outcome']=='success'
    assert events[-1]['run_id']==manifest['managed_run']
    result=dict(scope=manifest['scope'],platform='linux-x86_64',managed_run=manifest['managed_run'],cases=rows,maximum_protected_lifetime_words=w,combined_managed_static_word_budget=b,loaded_image_word_overcount=static_words,numeric_conditions={k:dict(upper=v[0],limit=v[1]) for k,v in checks.items()},semantic_operations=sum(a['hits'] for r in rows for a in r['arithmetic'].values()),post_init_semantic_operations=sum(a['post_init_hits'] for r in rows for a in r['arithmetic'].values()),maximum_semantic_result=count,driver_dispatch=dispatch,initial_split_registration_capacity_established=True,source_argument_machine_checked=False,relevant_source_behavior_required=True,external_runtime_contracts_required=True,whole_tail_capacity_established=False,whole_pipeline_capacity_established=False,backend_task_printing_calls_in_segment=0,solver_executions=0,solver_output_bytes_bounded=False,raw_task_counts_used_as_reported_G=False,production_configuration_adopted=False,managed_seconds=events[-1]['duration_seconds'],debugger_seconds=sum(r['debugger_seconds'] for r in rows))
    result['input_is_valid_registration'] = registration
    if args.output: args.output.write_text(json.dumps(result,indent=2)+'\n')
    else: assert result==json.loads((HERE/'result.json').read_bytes())
    print(json.dumps({k:result[k] for k in ('maximum_protected_lifetime_words','combined_managed_static_word_budget','semantic_operations','initial_split_registration_capacity_established','whole_tail_capacity_established')},indent=2))


if __name__=='__main__': main()
