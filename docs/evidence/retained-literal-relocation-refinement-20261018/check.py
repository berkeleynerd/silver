#!/usr/bin/env python3
"""Focused offline source-example, interface and interval checks."""
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
API = runpy.run_path(str(HERE/'derive.py'))


def program(calls, size=1):
    return (b'with Silver_IO;\nprocedure Main is\n pragma SPARK_Mode (On);\nbegin\n'
            + b'\n'.join([b'Silver_IO.Put ("'+b'a'*size+b'");']*calls)
            + b'\nend Main;\n')


def main():
    start = time.monotonic()
    start_utc = datetime.now(timezone.utc).isoformat()
    ctx = API['Context']()
    evaluate = lambda raw, **kw: API['evaluate'](raw, ctx, **kw)
    cases = {}
    for name, raw in [('one_call', program(1)), ('literal_8192', program(1,8192)),
                      ('calls_5000', program(5000))]:
        r = evaluate(raw)
        assert r['selected_literal_assembler_and_linker_representation_fits']
        cases[name] = r
    assert cases['calls_5000']['predecessor_failed_checks'] == ['fixed_signed_relocation_reach']
    assert cases['calls_5000']['operand_domains']['common_signed32'] < cases['calls_5000']['predecessor_common_signed32']
    # The previous rule is not overwritten or silently relabeled.
    old = ctx.api['evaluate'](program(5000), ctx.base)
    assert old['link']['failed_sufficient_checks'] == ['fixed_signed_relocation_reach']
    assert cases['calls_5000']['unchanged_other_checks'] == {
        k:v for k,v in old['link']['checks'].items() if k != 'fixed_signed_relocation_reach'}
    assert old['link']['layout']['trial_endpoint'] == 2*cases['calls_5000']['retained_endpoint']
    assert not cases['calls_5000']['whole_literal_pipeline_capacity_established']
    # Find only the adjacent sufficient-rule boundary, without native execution.
    lo, hi = 5000, 100000
    assert not evaluate(program(hi))['selected_literal_assembler_and_linker_representation_fits']
    while lo+1 < hi:
        mid = (lo+hi)//2
        r = evaluate(program(mid))
        if r['selected_literal_assembler_and_linker_representation_fits']:
            lo = mid
        else:
            hi = mid
    boundary = {str(c): evaluate(program(c)) for c in (lo,hi)}
    assert not boundary[str(lo)]['failed_sufficient_checks']
    assert 'fixed_signed_relocation_reach' in boundary[str(hi)]['failed_sufficient_checks']
    # Extrema check the interval reasoning, including negative differences and
    # the K=0/K=1 transition where the synthetic-PLT allowance can dominate.
    interval_cases = 0
    for v in (0,1,2,15,16,100,2**31-1,2**31,2**63):
        for k in (0,1,2,2019040):
            d = API['operand_domains'](v,k)
            assert d['common_signed32'] == v+max(k+15,16)
            for a in (0,v//2,v):
                for b in (0,v//2,v):
                    for addend in (-k,0,k):
                        assert abs(a-b+addend) <= d['rows']['ordinary_PC_relative']
                        interval_cases += 1
                for b in (0,(v+15)//2,v+15):
                    for addend in (-k,0,k):
                        assert abs(a-b+addend) <= d['rows']['TLS_thread_endpoint_with_addend']
                        interval_cases += 1
    cutoff = API['I32']-max(API['K']+15,16)
    assert API['operand_domains'](cutoff)['fits_signed32']
    assert not API['operand_domains'](cutoff+1)['fits_signed32']
    # Source binding and independent failed consumers survive the refinement.
    bad = [b'Silver_IO.Put ("a");', program(1).replace(b'pragma SPARK_Mode (On);',b'')]
    rejected = 0
    for raw in bad:
        try:
            evaluate(raw)
        except (ValueError, AssertionError):
            rejected += 1
    assert rejected == len(bad)
    page = evaluate(program(1),host_page_bytes=2**62)
    assert not page['selected_literal_assembler_and_linker_representation_fits']
    assert 'host_page_arithmetic' in page['failed_sufficient_checks']
    mutation_rejections = 0
    for key in ('bound','check'):
        changed = copy.deepcopy(old)
        if key == 'bound':
            changed['link']['relocation_bounds']['common_signed32'] -= 1
        else:
            changed['link']['checks']['fixed_signed_relocation_reach'] = True
        try:
            API['refine'](changed)
        except ValueError:
            mutation_rejections += 1
    assert mutation_rejections == 2
    result = dict(scope='Consumer-specific signed reach for the selected literal linker',
                  pins_verified=ctx.pins_verified, examples=cases,
                  adjacent_unit_literal_call_boundary=boundary,
                  checks=dict(interval_extrema=interval_cases,source_rejections=rejected,
                              predecessor_mutation_rejections=mutation_rejections,
                              signed_cutoff=cutoff,unrelated_page_failure_preserved=True,
                              earlier_failure_record_preserved=True,all_passed=True),
                  timing=dict(start_utc=start_utc,end_utc=datetime.now(timezone.utc).isoformat(),
                              elapsed_seconds=time.monotonic()-start),
                  native_tool_executions=0,whole_literal_pipeline_capacity_established=False)
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(checks=result['checks'],boundary_calls=[lo,hi],
                         calls_5000_common=cases['calls_5000']['operand_domains']['common_signed32'],
                         elapsed_seconds=result['timing']['elapsed_seconds'])))


if __name__ == '__main__':
    main()
