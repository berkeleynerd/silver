#!/usr/bin/env python3
"""Recheck #139's affected inputs using the retained verified runtime census."""
import argparse
import ast
import copy
import hashlib
import json
from pathlib import Path
import re
import runpy
import subprocess
import time
from types import SimpleNamespace

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PRIOR = REPO/'docs/evidence/unbounded-programs/retained-native-expansion-20261017'
BEFORE = 'd7034d952050df0e015958158131b6ccc2e70f64'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root',type=Path,required=True)
    args=parser.parse_args()
    started=time.monotonic()
    leaf=runpy.run_path(str(HERE/'compose.py'))
    checks=[]

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def frozen(name):
        return subprocess.run(['git','show',BEFORE+':'+str((HERE/name).relative_to(REPO))],
            cwd=REPO,check=True,capture_output=True).stdout

    old_raw=frozen('result.json'); old=json.loads(old_raw)
    old_checks_raw=frozen('check-results.json'); old_checks=json.loads(old_checks_raw)
    check('43-check evidence retained byte-for-byte at frozen original commit',
        old_checks['checks']==43 and (HERE/'check-results.json').read_bytes()==old_checks_raw)
    manifest=leaf['read'](HERE/'inputs.json')
    roots=dict(repository=REPO,ada=args.ada_root)
    for row in manifest['files']:
        check('input identity '+row['root']+':'+row['path'],
            leaf['identity']((roots[row['root']]/row['path']).read_bytes())==
            {k:row[k] for k in ('bytes','sha256')})
    configuration=(PRIOR/'null-capacity-fixture.adc').read_bytes()
    patterns=leaf['pattern_string_storage'](configuration,args.ada_root)
    check('lifetime fourteen, default eight, configuration six',
        patterns['pattern_String_allocations_upper']==14 and
        patterns['pattern_String_allocation_rows']['default_lifetime_objects']==8 and
        patterns['pattern_String_allocation_rows']['configuration_delta_objects']==6)
    check('two initialization calls allocate four Strings each',
        patterns['pattern_String_allocation_rows']['default_initialization_calls']==2 and
        patterns['pattern_String_allocation_rows']['String_objects_per_initialization']==4 and
        patterns['pattern_String_allocation_rows']['reset_reclaims_String_pointees'] is False)
    check('every pattern String object is bounded by21bytes',patterns['pattern_String_individual_bytes_upper']==21)
    sinput=(args.ada_root/'sinput-l.adb').read_text()
    check('exact per-virtual-source Dope allocation and shared text witnesses',
        "new Dope_Rec'(Snew.Source_First, Snew.Source_Last);" in sinput and
        "Snew.Source_Text := Sold.Source_Text;" in sinput and
        "Set_Dope (Snew.Source_Text'Address, Dope);" in sinput)
    # Extract two unchanged pure arithmetic/configuration definitions. This
    # does not run derive.py, its loader/examples or any source-corpus scan.
    names=('native_table_backing_row','native_gpr_naming_configuration')
    nodes=[node for node in ast.parse((PRIOR/'derive.py').read_bytes()).body
           if isinstance(node,ast.FunctionDef) and node.name in names]
    check('exactly two retained pure definitions extracted',len(nodes)==2)
    model=dict(repository=REPO,hashlib=hashlib,re=re)
    exec(compile(ast.Module(body=nodes,type_ignores=[]),str(PRIOR/'derive.py'),'exec'),model)
    model['fixed_native_inputs']=leaf['read'](PRIOR/'native-fixed-inputs.json')
    physical_before=old['components']['physical_sources']

    def retained_runtime(directory):
        check('retained verified runtime directory is unchanged',
            str(directory)==physical_before['runtime']['directory'])
        return copy.deepcopy(physical_before['runtime'])

    context=SimpleNamespace(ada=args.ada_root,model=model,
        indexed=leaf['read'](PRIOR/'native-indexed-invocation.json')['indexed_configuration_delta'],
        indexed_physical=leaf['read'](PRIOR/'native-indexed-source-buffers.json'),
        runtime_inventory=retained_runtime)
    shared={name:(REPO/'src'/name).read_bytes() for name in
        ('silver_io.ads','silver_io.adb','silver_output_libc.ads')}
    shared['configuration']=configuration
    system=Path(physical_before['runtime']['directory'])/'system.ads'
    shared['System']=system.read_bytes()
    physical=leaf['physical_sources']((REPO/'samples/hello_world.adb').read_bytes(),None,shared,
        dict(shared_System=dict(path=str(system))),context)
    check('composed physical export includes full lifetime pattern projection',
        all(physical[key]==value for key,value in patterns.items()))
    check('nine virtual metadata objects explicitly remain unpriced',
        physical['virtual_source_Dope_Rec_metadata_objects_upper']==9 and
        physical['virtual_source_Dope_Rec_metadata_storage_priced_here'] is False and
        sum(row['Dope_Rec_metadata_objects_upper'] for row in physical['virtual_sources'])==9 and
        all(row['Dope_Rec_metadata_storage_priced_here'] is False for row in physical['virtual_sources']))
    comparison=copy.deepcopy(physical)
    comparison['pattern_String_allocations_upper']=6
    for key in ('pattern_String_allocation_rows','virtual_source_Dope_Rec_metadata_objects_upper',
                'virtual_source_Dope_Rec_metadata_storage_priced_here'):
        del comparison[key]
    for row in comparison['virtual_sources']:
        del row['Dope_Rec_metadata_objects_upper']; del row['Dope_Rec_metadata_storage_priced_here']
    check('all other physical projections equal the retained successful input',comparison==physical_before)
    result=copy.deepcopy(old)
    result['components']['physical_sources']=physical
    remainder='Per-virtual-source Dope_Rec metadata allocations (up to nine) outside shared text/line arrays.'
    result['remaining'].insert(1,remainder)
    check('scope flags remain false',all(result[key] is False for key in
        ('complete_native_frontend','complete_gigi','complete_native_capacity','whole_toolchain_capacity_established',
         'complete_parent_storage','independent_proof_producer_closed','aggregate_attachment_complete',
         'production_admission_changed','aggregate_RAM_or_address_space_gate')))
    report=dict(review_target=BEFORE,issue=139,checks=len(checks),passed=checks,
        focused_elapsed_seconds=time.monotonic()-started,
        retained_original_result_identity=leaf['identity'](old_raw),
        retained_43_check_evidence_identity=leaf['identity'](old_checks_raw),
        source_witness_files=['fname-uf.adb','frontend.adb','par-prag.adb','table.adb','sinput-l.adb','sinput.ads'],
        direct_input_identities_checked=len(manifest['files']),runtime_census_reused_from=BEFORE,
        full_source_corpus_rerun=False,predecessor_model_loader_or_suites_rerun=False,
        native_tool_executions=0,complete_native_capacity=False)
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    (HERE/'correction-check-results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({key:value for key,value in report.items() if key!='passed'}))


if __name__=='__main__':
    main()
