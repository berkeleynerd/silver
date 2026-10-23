"""Focused checks of this packet only; no predecessor checker/capture replay."""
import copy
import json
import platform
import time
from project import HERE, EVIDENCE, CASES, identity, read, attachment, input_projection, source_witnesses
from compose import compose, zero, OWNERS, RESIDUALS, INT_MAX, ARRAY_MAX, apply_transfers, native_runtime_limits

started = time.monotonic()
checks = []


def check(label, condition):
    assert condition, label
    checks.append(label)


def rejected(label, fn):
    try:
        fn()
    except (ValueError, AssertionError):
        checks.append(label)
    else:
        raise AssertionError(label + ' was accepted')


manifest = read(HERE / 'inputs.json')
for name, expected in manifest['files'].items():
    check('input identity ' + name, identity((HERE.parents[2] / name).read_bytes()) == expected)
check('same-process Input projection', input_projection() == read(HERE / 'input-state.json'))
check('process owner cut attachment', attachment() == read(HERE / 'attachment.json'))
check('exact source witnesses', source_witnesses() == read(HERE / 'source-witnesses.json'))
r = compose()
check('frozen result', r == read(HERE / 'result.json'))
check('native array limit decoded from retained installed instruction',
      native_runtime_limits()['max_array_length'] == ARRAY_MAX)
check('same captured ELF supplies native limits', native_runtime_limits()['elf_identity'] ==
      read(HERE/'input-state.json')['installed_elf_identity'])
wrong=read(EVIDENCE/'retained-why-session-save-outcomes-20261019/runtime-limits.json')
wrong['max_wosize']=(1<<53)-1
rejected('different profiling-branch limit cannot be imported',lambda: native_runtime_limits(wrong))
check('206 table component reused', r['saved_component_reused']['applications'] == 206)
check('203 + 3 partition', r['saved_component_reused']['no_resize'] == 203 and
      r['saved_component_reused']['selected_theory_replacements'] == 3)
check('attempt endpoints retained', list(r['saved_component_reused']['next_proofAttemptID_upper'].values())
      == [209,174,109,13,10])
check('one process budget', r['budgets'] == dict(per_process_escape=2,save_entering_callbacks_upper=2,
      saves_upper=3,allowance_renewed_at_stage_boundary=False))
check('separate actual roots', [x['demand']['registered_roots'] for x in r['cases']] == [51,42,22,2,1])
check('no raw-leaf episode substitution', [x['demand']['preparation_episodes_upper'] for x in r['cases']]
      == [155,128,68,8,5])
expected_ident = [17199798,13259024,4864603,232156,314625]
check('joined known Ident increments', [x['known_demand']['Ident']['increments'] for x in r['cases']]
      == expected_ident)
check('known native operands fit', all(x['known_and_supplied_operands_fit'] for x in r['cases']))
check('lookup omission remains visible', all('lookup_library_constructors' in x['missing_residual_contracts']
      and not x['through_R58_complete_including_lookup'] for x in r['cases']))
check('no full-headroom promotion', not r['whole_pipeline_capacity'] and not r['actual_whole_process_headroom']
      and all(not x['actual_whole_process_headroom'] for x in r['cases']))
check('Input upper envelope not registration equality', r['cases'][-1]['attachment']['attachment_kind']
      == 'upper_envelope_from_later_cut' and r['cases'][-1]['attachment']['historical_pid'] == 97103)
check('Input full CE and update, no unmeasured subtraction',
      r['cases'][-1]['demand']['components']['CE_and_monomorphise']['Ident']['increments'] == 1903 and
      r['cases'][-1]['demand']['components']['driver_update']['Ident']['increments'] == 75 and
      not r['cases'][-1]['attachment']['unmeasured_delta_subtracted'])
# Independent correspondence to frozen stage totals, without rerunning stages.
frozen_inline = read(EVIDENCE / 'retained-why-fixed-inline-family-20261020/result.json')
frozen_post = read(EVIDENCE / 'retained-why-postinline-preparation-20261020/result.json')
check('R56 Ident retained exactly', sum(x['demand']['components']['first_inline']['Ident']['increments']
      for x in r['cases']) == frozen_inline['all_five_processes']['Ident'])
check('R58 Ident retained exactly', sum(x['demand']['components']['R58']['Ident']['increments']
      for x in r['cases']) == frozen_post['combined_totals']['direct_Ident_registrations'])
check('R58 type requests not type visits', sum(x['demand']['components']['R58']['Ty.Hsty']['requests']
      for x in r['cases']) == frozen_post['combined_totals']['type_application_requests'])
# e is shared: changing it once propagates to every component, never to new allowances.
r0, r1 = compose(escape=0), compose(escape=1)
for a,b,c in zip(r0['cases'],r1['cases'],r['cases']):
    for owner in OWNERS:
        for field in ('increments','requests'):
            check('common e affine '+a['case']+'/'+owner+'/'+field,
                  c['known_demand'][owner][field]-b['known_demand'][owner][field] ==
                  b['known_demand'][owner][field]-a['known_demand'][owner][field])
rejected('cannot renew e', lambda: compose(escape=3))
rejected('bool escape', lambda: compose(escape=True))
rejected('unknown process', lambda: compose({'elsewhere': {}}))
rejected('unknown stage', lambda: compose({'put-line': {'later': zero()}}))
rejected('omitted owner is not zero', lambda: compose({'put-line': {'later_preparation': {'Ident': dict(increments=0,requests=0)}}}))
for bad in (True,-1,1.0):
    v=zero();v['Ident']['increments']=bad
    rejected('invalid demand '+repr(bad), lambda v=v: compose({'put-line': {'later_preparation': v}}))
full = {case: {name: zero() for name in RESIDUALS} for case in CASES}
conditional = compose(full)
check('explicit zero is only caller hypothesis', all(x['six_owner_capacity_conditional_on_supplied_contracts']
      for x in conditional['cases']) and not conditional['actual_whole_process_headroom'])
changed=copy.deepcopy(full);changed['input-is-valid']['later_preparation']['Ident']['increments']=17
more=compose(changed)
check('suffix increment propagated', more['cases'][-1]['conditional_transfers']['Ident']['counter']['final_upper'] ==
      conditional['cases'][-1]['conditional_transfers']['Ident']['counter']['final_upper']+17)
changed['input-is-valid']['later_preparation']['Ident']['increments']=INT_MAX
check('native counter overflow rejected as headroom', not compose(changed)['cases'][-1]['known_and_supplied_operands_fit'])
changed=copy.deepcopy(full);changed['put-line']['later_preparation']['Task.Stdecl.Hcpt']['requests']=ARRAY_MAX
check('native growth operand failure remains false', not compose(changed)['cases'][0]['known_and_supplied_operands_fit'])
# Initial transferred dimensions are upper bounds, so test monotonicity directly.
s=read(HERE/'attachment.json')[-1]['owners'];larger=copy.deepcopy(s)
larger['Decl.Hsdecl']['allocated_key_slots'] += 100
larger['Decl.Hsdecl']['maximum_bucket_length'] += 10
larger['Task.Stdecl.Hcpt']['bucket_nodes'] += 100
old,new=apply_transfers(s,zero()),apply_transfers(larger,zero())
check('initial allocated slots propagated',new['Decl.Hsdecl']['backing']['live_entries_upper'] ==
      old['Decl.Hsdecl']['backing']['live_entries_upper']+100)
check('stored ephemeron size propagated',new['Task.Stdecl.Hcpt']['backing']['stored_entries_upper'] ==
      old['Task.Stdecl.Hcpt']['backing']['stored_entries_upper']+100)
# Arithmetic illustration of the reviewed general no-shrink lemma, including caps.
for n in range(0,200):
    g=3*n//2+3
    assert ((g-3)*2+2)//3 == n
    for cap in (n+1,g):
        m=min(g,cap)
        assert ((m-3)*2+2)//3 <= n < n+1
check('no-loss bucket growth illustration including caps', True)
summary=dict(status='pass',counted_checks=len(checks),elapsed_seconds=round(time.monotonic()-started,6),
             platform=platform.system()+' '+platform.machine(),
             native_runs=0,predecessor_checker_replays=0,capture_replays=0,
             source_argument_machine_checked=False,whole_process_headroom=False,
             checks=checks)
(HERE/'check-result.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k!='checks'},indent=2))
