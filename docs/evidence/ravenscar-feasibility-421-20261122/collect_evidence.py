from pathlib import Path
import hashlib,json,shutil
root=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/ravenscar-feasibility-421')
registry=Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs')
ret=root/'retained'; ret.mkdir(exist_ok=True)
cases=['baseline','baseline-v2','package-state','package-composition','entry','entry-two-callers','clock-naive','clock-guarded']
runs=[]
for d in sorted(registry.iterdir()):
    f=d/'events.jsonl'
    if not f.is_file(): continue
    events=[json.loads(line) for line in f.read_text().splitlines()]
    start=next((e for e in events if e.get('event')=='started'),{})
    if not start.get('task','').startswith('421-'): continue
    prepared=next((e for e in events if e.get('event')=='prepared'),{})
    finish=next((e for e in events if e.get('event')=='finished'),{})
    phases=[e for e in events if e.get('phase')=='native-tool']
    duration=(phases[-1]['monotonic_ns']-phases[0]['monotonic_ns'])/1e9 if len(phases)==2 else None
    dest=ret/'runs'/d.name; dest.mkdir(parents=True,exist_ok=True)
    for name in ['events.jsonl','native.log']:
        if (d/name).is_file():shutil.copyfile(d/name,dest/name)
    task=start['task']
    disposition=('flow failure despite managed success' if task=='421-entry-two-callers-proof' else finish.get('outcome'))
    runs.append({'run_id':d.name,'task':task,'managed_outcome':finish.get('outcome'),'reviewed_disposition':disposition,
                 'managed_duration_seconds':finish.get('duration_seconds'),'native_tool_phase_seconds':duration,
                 'workers':start.get('workers'),'cpu_affinity':start.get('cpu_affinity'),
                 'fingerprint':prepared.get('fingerprint'),'started_utc':start.get('utc'),'finished_utc':finish.get('utc'),
                 'command':next((e['command'] for e in events if e.get('event')=='command'),[]),
                 'inputs':prepared.get('inputs',{})})
(ret/'run-summary.json').write_text(json.dumps(runs,indent=2)+'\n')
summary={}
artifacts={}
for name in cases:
    case=root/name; target=ret/'cases'/name
    (target/'src').mkdir(parents=True,exist_ok=True)
    for f in [*case.glob('*.gpr'),*case.glob('*.adc'),*case.glob('src/*.ad?')]:
        shutil.copyfile(f,target/f.relative_to(case))
    rows=[]
    for p in case.glob('out/obj/explore/*/gnatprove'):
        dst=target/'proof'/p.parent.name;dst.mkdir(parents=True,exist_ok=True)
        for f in p.iterdir():
            if f.is_file() and (f.suffix in ('.spark','.ali','.sarif') or f.name in ('gnatprove.out','data_representation_generation.log')):
                shutil.copyfile(f,dst/f.name)
        phase=p/'phase1'
        if phase.exists():
            (dst/'phase1').mkdir(exist_ok=True)
            for f in phase.glob('*.ali'):shutil.copyfile(f,dst/'phase1'/f.name)
        for f in p.glob('*.spark'):
            d=json.loads(f.read_text())
            rows.append({'report':str(f.relative_to(case)),'owned_entities':{k:d['entities'][k] for k in d['spark']},
                         'all_entities':d['entities'],'spark':d['spark'],
                         'skip_flow_proof':d['skip_flow_proof'],'skip_proof':d['skip_proof'],
                         'pragma_assume':d['pragma_assume'],'warn_error':d['warn_error'],'stop_reason':d['stop_reason'],
                         'records':[dict(kind=kind,**{k:r.get(k) for k in ('rule','severity','how_proved','entity','file','line','col','message')})
                                    for kind in ('flow','proof','warn_error') for r in d[kind]]})
    native=case/'out/obj/native'
    if native.exists():
        dst=target/'native';dst.mkdir(exist_ok=True)
        for f in native.iterdir():
            if f.is_file() and (f.suffix in ('.ali','.bexch') or f.name in ('b__main.adb','b__main.ads')):shutil.copyfile(f,dst/f.name)
    obs=case/'out/observation/runtime.json'
    if obs.exists():shutil.copyfile(obs,target/'runtime.json')
    exe=case/'out/bin/native/main'
    if exe.exists():artifacts[name]={'path':str(exe),'sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'size':exe.stat().st_size}
    summary[name]=rows
(ret/'report-records.json').write_text(json.dumps(summary,indent=2)+'\n')
(ret/'native-artifacts.json').write_text(json.dumps(artifacts,indent=2)+'\n')
for name in ('observe.py','host-runtime-inventory.json','NOTES.md','collect_evidence.py'):shutil.copyfile(root/name,ret/name)
# Verify source/configuration identity between proof and native compilation.
identities=[]
for case in ('baseline-v2','entry'):
    prefix='421-'+case
    selected={r['task']:r for r in runs if r['task'] in (prefix+'-proof',prefix+'-build')}
    a=selected[prefix+'-proof']['inputs']['inputs_sha256'];b=selected[prefix+'-build']['inputs']['inputs_sha256']
    paths=[p for p in a if p.startswith(str(root/case)+'/')]
    identities.append({'case':case,'proof_build_declared_inputs_equal':all(a[p]==b.get(p) for p in paths),
                       'declared_inputs':{p:a[p] for p in paths}})
assert all(r['proof_build_declared_inputs_equal'] for r in identities)
(ret/'source-identity-checks.json').write_text(json.dumps(identities,indent=2)+'\n')
print(json.dumps({'run_count':len(runs),'sum_managed_seconds':sum(r['managed_duration_seconds'] for r in runs),
                  'sum_completed_native_tool_phases_seconds':sum(r['native_tool_phase_seconds'] or 0 for r in runs),
                  'case_record_counts':{case:sum(len(d['records']) for d in rows) for case,rows in summary.items()},
                  'identity_checks':identities},indent=2))
