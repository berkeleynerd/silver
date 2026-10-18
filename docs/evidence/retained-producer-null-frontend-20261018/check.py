#!/usr/bin/env python3
"""Replay retained observations and check actual-source/descriptor boundaries."""
import argparse
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root', type=Path, required=True)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    api = runpy.run_path(str(HERE/'compose.py'))
    native = runpy.run_path(str(api['NATIVE']/'compose-null-capacity.py'))
    model = native['load_model'](args.ada_root)
    evidence = api['retained']()
    descriptor = json.loads((HERE/'fixture.json').read_bytes())
    source = evidence['raw']['main.adb']
    call = lambda s,d=descriptor: api['compose'](s,d,model,evidence)
    result = call(source)
    assert result == json.loads((HERE/'result.json').read_bytes())
    assert result['physical_sources']['aligned_source_extent'] == 24576
    assert result['phases']['phase1']['logical_table_demands']['namet__name_entries__last_val'] == 1738
    assert result['phases']['phase2']['logical_table_demands']['namet__name_entries__last_val'] == 1802
    positive = {
        'retained':source,
        'case_and_comment':b'-- test\r\n'+source.upper(),
        'long_trivia':b'--'+b' x'*100+b'\n'+source+b'\n'*10000,
        'CR_and_tabs':source.replace(b'\n',b'\r').replace(b' ',b'\t'),
        'one_megabyte_trivia':(b'--'+b'x'*997+b'\n')*1000+source,
    }
    rows = []
    for label, value in positive.items():
        r = call(value)
        assert r['all_selected_frontend_predicates_pass'], label
        rows.append(dict(name=label,bytes=len(value),kind='passes arithmetic',
            aligned_source_extent=r['physical_sources']['aligned_source_extent']))
    too_wide = call(b'--'+b'x'*32765+b'\n'+source)
    assert not too_wide['all_selected_frontend_predicates_pass']
    assert not too_wide['physical_sources']['sources'][1]['checks']['expanded_column']
    rows.append(dict(name='overwide_comment',kind='column predicate false'))
    rejects = {
        'changed_construct':source.replace(b'null;',b'return;'),
        'wrong_Main':source.replace(b'Main',b'Maine'),
        'extra_pragma':source+b'pragma SPARK_Mode (On);',
        'non_ASCII':b'--\xff\n'+source,
        'VT_not_current_alphabet':b'\v'+source,
    }
    for label,value in rejects.items():
        try: call(value)
        except ValueError: pass
        else: raise AssertionError(label+' was not rejected')
        rows.append(dict(name=label,kind='outside source class'))
    for field,value in [('capture_plan_sha256','0'*64),('phase_options_sha256',{}),
                        ('paths',[]),('complete_path_bound',0)]:
        bad = dict(descriptor);bad[field] = value
        try: call(source,bad)
        except ValueError: pass
        else: raise AssertionError(field+' was not rejected')
        rows.append(dict(name='changed_'+field,kind='descriptor rejected'))
    report = dict(offline_cases=rows, retained_result_matches=True,
        table_positions_reconciled=242, coherent_range_returns=68,
        managed_run=evidence['manifest']['run'], native_tool_executions=0,
        whole_toolchain_capacity_established=False)
    if args.output:
        args.output.write_text(json.dumps(report,indent=2)+'\n')
    else:
        assert report == json.loads((HERE/'checks.json').read_bytes())
    print(json.dumps(dict(offline_cases=len(rows),retained_result_matches=True,native_tool_executions=0)))


if __name__ == '__main__':
    main()
