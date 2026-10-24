#!/usr/bin/env python3
"""Focused F1 purity/source repair check; does not rerun the original checker."""
import hashlib
import importlib.util
import json
import platform
import subprocess
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
PARENT = HERE.parent
ROOT = PARENT.parents[3]
sys.dont_write_bytecode = True


def read(path):
    return json.loads(path.read_bytes())


def sha(b):
    return hashlib.sha256(b).hexdigest()


def stats():
    return dict(activations=0,constant_requests=0,unchanged_selectors=0,
                minmax_calls=0,extremum_absorptions=0)


def main():
    start = time.perf_counter()
    receipt = read(HERE/'inputs.json')
    for row in read(PARENT/'packet-manifest-f1.json')['files']:
        b = (ROOT/row['path']).read_bytes()
        assert len(b) == row['bytes'] and sha(b) == row['sha256'], row['path']
    for row in receipt['unchanged_receipts']:
        b = (ROOT/row['path']).read_bytes()
        old = subprocess.check_output(['git','show',receipt['author']+':'+row['path']],cwd=ROOT)
        assert b == old and len(b) == row['bytes'] and sha(b) == row['sha256']
    # Check original artifact identities at their original freeze; no checker
    # replay and no claim that its superseded lemma was semantically accepted.
    original_files = read(PARENT/'packet-manifest.json')['files']
    for row in original_files:
        b = subprocess.check_output(['git','show',receipt['author']+':'+row['path']],cwd=ROOT)
        assert len(b) == row['bytes'] and sha(b) == row['sha256']
    for row in receipt['anchors']:
        b = (HERE/row['retained_file']).read_bytes()
        old = subprocess.check_output(['git','show',row['commit']+':'+row['path']],cwd=ROOT)
        assert b == old and len(b) == row['bytes'] and sha(b) == row['sha256']
    manifests = read(PARENT/'source-manifest.json')
    needed = {'gcc/genmatch.cc','gcc/fold-const.cc','gcc/tree.cc'}
    sources = {}
    for archive in manifests['archives']:
        rows = [r for r in manifests['files'] if r['archive'] == archive['path']
                and r['path'] in needed]
        if not rows:
            continue
        ap = PARENT/archive['path']
        assert sha(ap.read_bytes()) == archive['sha256']
        with tarfile.open(ap,'r:gz') as tf:
            for row in rows:
                b = tf.extractfile(row['path']).read()
                assert len(b) == row['bytes'] and sha(b) == row['sha256']
                sources[row['path']] = b
    assert set(sources) == needed
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    for row in witnesses:
        lo,hi=row['first_lf_line'],row['last_lf_line']
        b=b'\n'.join(sources[row['source']].split(b'\n')[lo-1:hi])+b'\n'
        assert sha(b) == row['sha256']
    finding=read(HERE/'finding-F1.original.json')
    for row in finding['source_spans']:
        b=sources[row['path']]
        assert sha(b) == row['source_sha256']
        span=b'\n'.join(b.split(b'\n')[row['first_lf_line']-1:row['last_lf_line']])+b'\n'
        assert sha(span) == row['sha256']
    assert finding['attached_partition_affected'] is False
    gen=sources['gcc/genmatch.cc'].decode()
    assert 'if (TREE_SIDE_EFFECTS (captures[%d]))' in gen
    assert '_r = build2_loc (loc, COMPOUND_EXPR, type, ' in gen
    assert 'fold_ignored_result (captures[%d]), _r);' in gen
    # Import definitions only. Neither parent check() nor its matcher parser
    # is invoked, so no successful original case corpus is replayed.
    spec=importlib.util.spec_from_file_location('selector_purity_model',PARENT/'check.py')
    model=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(model)
    Node,Condition=model.Node,model.Condition
    bounds={False:Node('literal',-2**31),True:Node('literal',2**31-1)}
    pure=Condition('Q',side_effects=False)
    effect=Condition('P_effectful',side_effects=True)
    pure_inner=Node('cond',Condition('P_pure',side_effects=False),Node('literal',1),Node('literal',7))
    effect_inner=Node('cond',effect,Node('literal',1),Node('literal',7))
    pure_tree=Node('cond',pure,Node('var','D'),pure_inner)
    effect_tree=Node('cond',pure,Node('var','D'),effect_inner)
    checked_pure=0
    rejected=0
    for direction in (False,True):
        s=stats()
        assert model.maximum(pure_tree,direction,s,bounds) is bounds[direction]
        assert s['activations']==5 and s['extremum_absorptions']==1
        assert s['constant_requests']<=3
        checked_pure+=1
        for node in (effect_tree,Node('cond',effect,Node('var','D'),Node('literal',1)),
                     Node('cond',object(),Node('var','D'),Node('literal',1)),
                     Node('cond',None,Node('var','D'),Node('literal',1))):
            try:
                model.maximum(node,direction,stats(),bounds)
            except ValueError:
                rejected+=1
            else:
                raise AssertionError('unsupported or unspecified condition admitted')
        # Source-trace model of genmatch's unused-capture omission branch.
        # The effectful case is deliberately outside maximum()'s domain.
        E=('literal',bounds[direction].args[0])
        for side_effects in (False,True):
            result=('COMPOUND','P_effectful',E) if side_effects else E
            binary_requests=int(side_effects)
            assert (result==E)==(not side_effects)
            assert binary_requests==int(result[0]=='COMPOUND')
    for make in (lambda:Condition('omitted'),lambda:Condition('unknown',side_effects=None),
                 lambda:Condition('int_not_bool',side_effects=0)):
        try:
            make()
        except (ValueError,TypeError):
            rejected+=1
        else:
            raise AssertionError('condition purity was implicitly assumed')
    minmax=read(PARENT/'matcher-audit.json')['extremum']['root_patterns']
    for line in (4950,4961):
        row,=[r for r in minmax if r['line']==line]
        assert 'genmatch.cc:2961-2991' in row['disposition']
        assert '4668-4685' in row['disposition']
        assert 'TREE_SIDE_EFFECTS-false' in row['disposition']
    result=dict(status='pass',repair='F1/#214',author_input=receipt['author'],
                review_input=receipt['review'],platform=platform.system(),
                machine=platform.machine(),elapsed_seconds=time.perf_counter()-start,
                completed_utc=datetime.now(timezone.utc).isoformat(),
                retained_complete_sources=len(sources),new_lf_witnesses=len(witnesses),
                original_finding_spans=len(finding['source_spans']),
                original_freeze_file_identities=len(original_files),
                unchanged_receipts=len(receipt['unchanged_receipts']),
                exact_review_anchors=len(receipt['anchors']),pure_queries=checked_pure,
                effectful_or_unspecified_inputs_rejected=rejected,
                generic_omission_trace_cases=4,coefficients_changed=False,
                native_compiler_prover_lean_predecessor_or_original_full_checks=0,
                source_argument_machine_proved=False,complete_native_capacity_result=False)
    (HERE/'current-f1.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__=='__main__':
    main()
