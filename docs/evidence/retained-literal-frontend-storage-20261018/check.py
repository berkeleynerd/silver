#!/usr/bin/env python3
"""Focused frontend storage joins and arithmetic boundaries; no native runs."""
import argparse
import json
from pathlib import Path
import tempfile
import time
from compose import Context, E, HERE, I32, REPO, compose, source_object


def source(c=1, n=0, length=1):
    calls = [b'Silver_IO.'+(b'Put' if i%2 else b'Put_Line')+b' ("'+b'x'*length+b'");'
             for i in range(c)]
    return (b'with Silver_IO;\nprocedure Main is\npragma SPARK_Mode (On);\nbegin\n'+
            b'\n'.join(calls+[b'null;']*n)+b'\nend Main;\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ada-root',type=Path,required=True)
    parser.add_argument('--gcc-root',type=Path,required=True)
    args=parser.parse_args()
    start=time.monotonic()
    context=Context(args.ada_root,args.gcc_root)
    checks=[]

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    def reject(name, fn):
        try:
            fn()
        except ValueError:
            check(name,True)
        else:
            raise AssertionError(name)

    hello=compose((REPO/'samples/hello_world.adb').read_bytes(),context)
    physical=hello['components']['physical_sources']
    check('all selected hello component checks',hello['all_selected_component_checks_pass'])
    check('indexed runtime extent includes second System',physical['runtime']['aligned_source_extent']==20496384
          and physical['extra_physical_objects']['additional_indexed_System']['aligned_source_extent']==8192)
    check('permanent versus failed-load transient versus filename ingress',
        hello['exported_source_entry_bounds']==dict(physical_files_upper=1580,virtual_files_upper=9,
            permanent_source_entries_upper=1589,failed_load_transient_slots_upper=1,
            Source_File_backing_demand=1590,backend_File_Info_entries_upper=1589,
            insertion_capable_filename_lookups_upper=1590,direct_filename_identifier_calls_upper=3180))
    check('actual source/naming/map and nine virtual extents',physical['aligned_source_extent']==20561920
          and hello['mapping']['records']==4 and hello['configuration_input_identities']['configuration']['bytes']==327
          and sum(r['copies_upper']*r['aligned_extent_each'] for r in physical['virtual_sources'])==40960)
    check('current naming patterns and indexed table',physical['tables']['SFN_Patterns']['demand']==6
          and physical['tables']['SFN_Table']['demand']==1)
    check('source backing pays only failed slot; backend array permanent',
        physical['tables']['Source_File']['demand']==1590
        and physical['backend_File_Info_Array_individual_bytes_upper']==19084)
    gigi=hello['components']['gigi_array_and_name_input']
    check('joined node count determines both association array objects',
        gigi['joined_frontend_node_identities_upper']==41294 and gigi['association_array_requests']==2
        and gigi['each_association_array_raw_bytes_upper']==330352
        and gigi['selected_frontend_encoded_name_bytes_upper']==737)
    check('numeric projections replace exactly once',hello['numeric_base_projection']==dict(Uints=24331,Udigits=75019,Ureals=60)
          and hello['numeric_lifetime_projection']==dict(Uints=28429,Udigits=107797,Ureals=67,Rep_Table=504)
          and hello['joined_logical_tables']['Uint_entries']==28429)
    for c,n,length in [(1,1,0),(2,3,13),(7,0,8192),(31,9,2)]:
        result=compose(source(c,n,length),context)
        check(f'component conjunction C{c} N{n} D{length}',result['all_selected_component_checks_pass'])
        check(f'Main vector C{c} N{n}',result['joined_logical_tables']['node_identities']==41234+41+19*c+4*n)
        check(f'source identity C{c} N{n}',result['source']['sha256']==result['source_counts']['source_sha256'])
    raw=source(2,1,3)
    baseline=compose(raw,context)
    for label, variant in [('case',raw.upper()),('CRLF',raw.replace(b'\n',b'\r\n')),
                           ('comment',b'-- pragma Source_Reference (99);\r'+raw)]:
        result=compose(variant,context)
        check(label+' logical projection invariant',result['joined_logical_tables']==baseline['joined_logical_tables'])
        check(label+' physical source bytes attached',result['components']['physical_sources']['extra_physical_objects']['Main']['bytes']==len(variant))
    for c in (5000,32765,32766):
        result=compose(source(c,1,0),context)
        scope=context.model['uint_digits'](c+2)
        check(f'source scope-digit growth C{c}',result['numeric_lifetime_projection']['Udigits']==107726+c*(70+scope))
        check(f'large literal shell remains local conjunction C{c}',result['all_selected_component_checks_pass']
              and not result['complete_native_frontend'] and not result['complete_native_capacity'])
    check('physical aligned EOF boundary',source_object(b'x'*4095)['aligned_source_extent']==4096
          and source_object(b'x'*4096)['aligned_source_extent']==8192)
    check('line backing exact initial and first doubling',source_object(b'\n'*499)['line_table_capacity_bound']==500
          and source_object(b'\n'*500)['line_table_capacity_bound']==1000)
    check('tab expansion and column boundary',source_object(b'\t')['max_expanded_final_column']==9
          and source_object(b'x'*32765)['all_selected_checks_pass']
          and not source_object(b'x'*32766)['all_selected_checks_pass'])
    check('Source_Reference code cannot claim zero logical-line objects',
          not source_object(b'pragma Source_Reference (9, "foo");')['checks']['no_Source_Reference'])
    # Mathematical guard checks exercise individual objects and source-derived
    # nominal domains without allocating their claimed source/table sizes.
    table=context.model['native_table_backing_row']
    check('Source_File nominal/backing failure remains a predicate',
          not table(I32,1,10,200,464,I32)['all_selected_checks_pass'])
    for name,raw in [('empty',b''),('trailing source',source()+b'junk'),('VT',source()+b'\v'),
                     ('declaration',source().replace(b'begin',b'X : Integer := 1; begin'))]:
        reject(name,lambda raw=raw:compose(raw,context))
    with tempfile.TemporaryDirectory(prefix='silver-frontend-descriptor-') as tmp:
        descriptor=json.loads((E/'retained-literal-pipeline-20261018/selected-route.json').read_bytes())
        descriptor['core_descriptor']=str(E/'retained-literal-pipeline-20261018/selected-core-fixture.json')
        descriptor['runtime']['cwd']+='x'
        path=Path(tmp)/'bad.json';path.write_text(json.dumps(descriptor))
        reject('different selected cwd class',lambda:compose(source(),context,path))
    check('global/native/proof/parent/adoption flags all false',all(hello[key] is False for key in
        ('complete_native_frontend','complete_gigi','complete_native_capacity',
         'whole_toolchain_capacity_established','complete_parent_storage','independent_proof_producer_closed',
         'aggregate_attachment_complete','production_admission_changed','aggregate_RAM_or_address_space_gate')))
    result=dict(checks=len(checks),passed=checks,elapsed_seconds=time.monotonic()-start,
        host='linux-x86_64',direct_input_records_verified=len(context.inputs['files']),
        runtime_files_verified=context.runtime['file_count'],native_tool_executions=0,
        predecessor_suites_rerun=False,complete_native_frontend=False,complete_native_capacity=False)
    (HERE/'result.json').write_text(json.dumps(hello,indent=2)+'\n')
    (HERE/'check-results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k!='passed'}))


if __name__=='__main__':
    main()
