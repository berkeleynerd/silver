#!/usr/bin/env python3
"""New-only source attachment/history/caller checks. No native execution."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from callers import History, Node, Spec, expanded, fold
from inventory import collect

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
CHECKS=Counter()


def check(ok,label):
    if not ok:raise AssertionError(label)
    CHECKS[label]+=1


def identities():
    manifest=json.loads((HERE/'identity.json').read_text())
    sha=lambda data:hashlib.sha256(data).hexdigest()
    for row in manifest['providers']:
        check(sha((ROOT/row['path']).read_bytes())==row['sha256'],'provider identity')
    for row in manifest['archives']:
        path=ROOT/row['path']
        check(sha(path.read_bytes())==row['sha256'],'archive identity')
        with tarfile.open(path) as t:
            for entry in row['files']:
                data=t.extractfile(entry['path']).read()
                check(sha(data)==entry['sha256'],'complete source identity')
                lines=data.decode().splitlines()
                for span in entry.get('spans',[]):
                    source='\n'.join(lines[span['first']-1:span['last']])+'\n'
                    check(sha(source.encode())==span['sha256'],'source span identity')
                    for anchor in span['anchors']:
                        check(anchor in source,'native branch anchor')


def history_diagrams():
    # Origination labels are finite source scopes. New targets all postdate
    # the whole original graph, not merely the current formula's free set.
    h=History(1000)
    for site in range(50):
        base=h.start_declaration()
        args,oldies=(1,2),( (1,3),(2,4),(1,3) )
        am,om=h.spec(base,args,oldies,({1},{1,2}),({1,3},{2,4},{3,4}))
        check(len(am)==2 and len(om)==4,'formal oldie coverage without external map')
        check(len(set(om.values()))==len(om),'whole inherited lexical map injective')
        # sm_save_olds reverses current->old pairs after cloning. Repeated
        # source use of old(x) points at one old identity.
        source=dict(oldies)
        new_oldies={om[old]:am[current] for current,old in source.items()}
        reverse={current:old for old,current in new_oldies.items()}
        check(len(reverse)==len(source),'source oldie reversal is injective')
        check(all(reverse[am[current]]==om[old] for current,old in source.items()),'sm_save_olds finds exact fresh oldie')
        scope=h.extend(om,(5,)) # initializer completed before local LDvar
        h.check(scope,{1,3,5})
        branch=h.extend(scope,(6,7))
        h.check(branch,{1,5,6,7})
        check(set(scope)=={1,2,3,4,5} and set(branch)=={1,2,3,4,5,6,7},'persistent branch scope does not escape')
        routine=h.extend(scope,(8,)) # RLpv created by local create_rsymbol
        h.check(routine,{1,5,8})
        check(set(om)=={1,2,3,4} and all(v>1000 for v in routine.values()),'local routine and binder targets postdate entire origin')
        # The top declaration is RKnone/RKfunc/RKpred/RKlemma, so its return
        # map is base rather than the inner body map.
        h.pv_table=base
        check(not h.start_declaration(),'declaration history preserves empty inherited pv table')
    return {'declarations':50,'fresh_targets':h.current_ident-h.origin_last_ident,
            'clone_term_roots':h.calls['clone_term']}


def caller_diagrams():
    # Native constructors are folded independently of term sizes.
    c=Spec(2,3,(1,2))
    any_=Node('Cany',spec=c)
    call=Node('Capp')
    expr=Node('let',(Node('LDvar',(Node('exec',(call,)),)),
                     Node('if',(Node('pure'),Node('assert'),Node('exec',(call,))))))
    fun=Node('Cfun',(expr,),c)
    unit=Node('scope',(Node('PDlet',(Node('LDsym',(fun,)),)),
                        Node('PDlet',(Node('LDsym',(any_,)),)),
                        Node('Dlogic',roots=3),Node('Dind',roots=4),
                        Node('Dprop'),Node('Dprop',selected=False),
                        Node('refined_val',spec=Spec(0,1)),Node('use'),
                        Node('clone_metadata'),Node('meta'),Node('type')))
    count=fold(unit)
    check(count==Counter(clone_term=27,clone_cty=3,direct_c_app=3),'complete ordered direct-caller recurrence')
    # Comparison-only Dlogic/Dind visits count even when returning the old
    # declaration context. A failed comparison consumes a nonnegative prefix.
    roots=[1]*7
    for n in range(8):
        check(sum(roots[:n])<=fold(Node('scope',(Node('Dlogic',roots=3),Node('Dind',roots=4))))['clone_term'],
              'discarded comparison and failed-prefix bound')
    local={'A':Counter(clone_term=2),'B':Counter(clone_term=3),'C':Counter(clone_term=5)}
    graph={'A':('B','C'),'B':('C',),'C':()}
    check(expanded('A',local,graph)==Counter(clone_term=15),'unchanged-weight clone DAG keeps occurrence multiplicity')
    # Two callers clone the same immutable origin; metadata is not a third
    # execution, and a use edge contributes no extra origin expansion.
    check(expanded('A',local,graph)['clone_term']*2==30,'independent source clone requests accumulate')
    check(fold(Node('clone_metadata'))['clone_term']==fold(Node('use'))['clone_term']==0,'metadata and use have no root replay')
    # A clone consumes a definition for comparison and emits no definition.
    # Cloning its output later must use the emitted records, not its input
    # weight or the work performed when constructing that output.
    comparison_input=Node('scope',(Node('Dlogic',roots=3),Node('Dprop')))
    comparison_output=Node('scope',(Node('Dprop'),Node('clone_metadata')))
    check(fold(comparison_input)['clone_term']==4 and
          fold(comparison_output)['clone_term']==1,
          'later clone counts transformed stored records rather than origin work')
    # Explicit general rows stay identified; inventory makes them unreachable.
    check(fold(Node('rec_member',spec=Spec(2,1),variants=3))['clone_term']==5,'unreached recursion row is not silently erased')
    return dict(count)


def main():
    started=time.monotonic()
    identities()
    inventory=collect()
    check(len(inventory['fixed_clone_origins'])==64,'fixed origin source set')
    check(len(inventory['all_origins'])==69,'ordinary Main plus fixed origin set')
    check(inventory['no_origin_program_globals'],'source frontier excludes top program globals')
    check(inventory['no_foreign_state_reference'],'source frontier excludes foreign program-state reads')
    check(inventory['type_witness_by_tokens_in_origins']==0,'source frontier excludes type-witness syntax')
    for module,row in inventory['origin_inventory'].items():
        check(not row['objects'],'per-origin no nullary program val')
        for c in row['plain_let_candidates']:
            check(c['ends_at_in_before_new_binding_or_declaration'],'per-candidate lexical let evidence')
    (HERE/'inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
    history=history_diagrams()
    callers=caller_diagrams()
    result={'status':'pass','assertions':sum(CHECKS.values()),'families':dict(CHECKS),
            'fixed_origins':64,'total_origins':69,'dependency_modules':len(inventory['dependency_closure']),
            'plain_let_candidates':inventory['origin_plain_let_candidates'],
            'history_diagrams':history,'caller_diagram':callers,
            'elapsed_seconds':time.monotonic()-started,'host':platform.platform(),
            'native_runs':0,'predecessor_checker_main_runs':0,
            'actual_frontier_clone_map_attachment':True,
            'complete_source_to_initial_vc_storage':False,'complete_native_bytes':False}
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__':main()
