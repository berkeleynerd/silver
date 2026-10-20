#!/usr/bin/env python3
"""Focused retention/census check; no predecessor or native tool execution."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import tarfile
import time

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def read(p): return json.loads(p.read_text())
def identity(b): return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def require(value,message):
    if not value: raise AssertionError(message)

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--write-result',action='store_true')
    args=parser.parse_args()
    started=time.monotonic()
    inputs=read(HERE/'inputs.json')
    for row in inputs['inputs']:
        require(identity((ROOT/row['path']).read_bytes())=={k:row[k] for k in ('bytes','sha256')},row['path'])
    spec=importlib.util.spec_from_file_location('binder_inventory',HERE/'build_inventory.py')
    builder=importlib.util.module_from_spec(spec);spec.loader.exec_module(builder)
    sources=builder.source_bytes()
    source_rows=read(HERE/'source-inputs.json')
    require(len(source_rows)==len(sources),'complete source capsule census')
    for row in source_rows:
        b=sources[row['local']]
        require(identity(b)=={k:row[k] for k in ('bytes','sha256')},row['local'])
        if 'archive' in row:
            with tarfile.open(ROOT/row['archive']) as archive:
                require(archive.extractfile(row['member']).read()==b,'retained source equality '+row['local'])
        else:
            pins=read(ROOT/row['pin'])['native_source_identity']['selected_sha256']
            require(pins[row['local']]==row['sha256'],'accepted extra source pin')
    completion=read(ROOT/'docs/evidence/retained-literal-binder-completion-20261019/inputs.json')
    bindgen=[r for r in completion['sources'] if r['path']=='bindgen.adb']
    require(len(bindgen)==1 and identity(sources['bindgen.adb'])=={k:bindgen[0][k] for k in ('bytes','sha256')},'unchanged full binder source pin')
    generated=builder.make()
    for name,value in generated.items():
        require(value==read(HERE/name),'retained regeneration '+name)
    # A citation must retain the relevant field, not only neighboring source.
    # These targeted assertions cover the independently reviewed range defects.
    inventory={row['id']:row for row in generated['consumer-inventory.json']}
    citation_checks=0
    def cited_contains(row_id,role,*tokens):
        nonlocal citation_checks
        reference=inventory[row_id][role].split(';')[0]
        member,ranges=reference.split(':')
        lines=sources[member].decode().splitlines(keepends=True)
        pieces=[]
        for span in ranges.split(','):
            first,_,last=span.partition('-')
            first,last=int(first),int(last or first)
            require(1<=first<=last<=len(lines),'citation range '+reference)
            pieces.append(''.join(lines[first-1:last]))
        text=''.join(pieces)
        for token in tokens:
            require(token in text,f'cited field {row_id}/{role}: {token}')
            citation_checks+=1
    cited_contains('U-name-kind','writer','Write_Info_Str (" SU")')
    cited_contains('U-finalization','writer','Write_Info_Str (" PF")','Write_Info_Str (" GE")')
    cited_contains('U-finalization','reader','Is_Generic := True','Has_Finalizer := True',"Unit_Kind := 's'")
    cited_contains('U-casing','writer','Write_Info_Str (" IL")','Write_Info_Str (" IU")','Write_Info_Str (" KM")','Write_Info_Str (" KU")')
    cited_contains('U-casing','reader','Icasing := All_Lower_Case','Icasing := All_Upper_Case','Kcasing := Mixed_Case','Kcasing := All_Upper_Case')
    cited_contains('U-scalars','writer','Write_Info_Str (" IS")')
    cited_contains('U-scalars','reader','Init_Scalars := True','Initialize_Scalars_Used := True')
    cited_contains('U-scalars','consumer','if Initialize_Scalars_Used then')
    cited_contains('U-other','writer','Write_Info_Str (" O")','Write_Info_Str (" RA")','Write_Info_Str (" RC")','Write_Info_Str (" RT")')
    cited_contains('U-other','reader','Optimize_Alignment := C','RCI := True','Remote_Types := True','Has_RACW := True')
    cited_contains('fixed-auxiliary','writer','Collect_Withs (Unode)','Write_With_Lines;')
    closure=generated['fixed-ali-projection.json']
    require(len(closure)==82,'fixed closure ALI cardinality')
    projections=[(n,l) for n,row in closure.items() for l in row['projection']]
    p_lines=[l for _,l in projections if l.startswith('P')]
    require(len(p_lines)==82 and set(p_lines)=={'P ZX','P SS ZX'},'fixed P projection')
    require(any(n=='closure/a-chahan.ali' and l=='P SS ZX' for n,l in projections),'non-exempt secondary-stack witness')
    require(not any(l.startswith('T ') for _,l in projections),'no fixed task stack contribution')
    require(not any(' IS' in l for _,l in projections if l.startswith('U ')),'no fixed scalar initialization')
    partition=generated['restriction-partition.json']
    require(len(partition)==100 and len({r['restriction'] for r in partition})==100,'complete restriction enum excluding sentinel')
    absorbed=[r for r in partition if r['fixed_witnesses']]
    require(len(absorbed)==30,'fixed boolean violation support')
    require(not any('=' in l for _,l in projections if l.startswith(('RR ','RV '))),'no fixed parameter restriction value/count')
    occurrences=generated['bindgen-occurrences.json']
    require(occurrences['Icasing']==[1674] and occurrences['Kcasing']==[],'exact casing consumer census')
    require(occurrences['Version']==[3071],'exact checksum consumer census')
    # These checks preserve the critical semantic premises in the literal
    # source. They do not prove Ada semantics or run the public recognizer.
    recognizer=(ROOT/'docs/evidence/unbounded-programs/retained-native-expansion-20261017/derive-literal-output.py').read_text()
    require('"(?:[ !#-~]|"")*"' in recognizer,'doubled-quote literal token')
    require('32<=b<=126 or b in (9,10,11,12,13)' in recognizer,'ASCII source alphabet')
    require("elsif C = '['" in sources['scng.adb'].decode() and
        'and then Identifier_Char (Source (Scan_Ptr + 2))' in sources['scng.adb'].decode(),'bracket scanner predicate')
    result=dict(scope='retained-family binder serialization transfer inventory',
        repository_inputs=len(inputs['inputs']),source_members=len(sources),
        literal_excerpts=len(generated['source-excerpts.json']),consumer_groups=len(generated['consumer-inventory.json']),
        field_specific_citation_checks=citation_checks,
        tracked_bindgen_identifiers=len(occurrences),fixed_ali_files=len(closure),
        restriction_members_excluding_sentinel=len(partition),fixed_boolean_violations=len(absorbed),
        native_executions=0,predecessor_checker_replays=0,
        actual_evaluated_binder_measured=False,semantic_source_theorem_machine_proved=False,
        new_binder_capacity_derivation=False,independent_review='pending')
    if args.write_result:(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    else:require(read(HERE/'result.json')==result,'result equality')
    print(json.dumps(dict(result=result,check_seconds=time.monotonic()-started)))

if __name__=='__main__':main()
