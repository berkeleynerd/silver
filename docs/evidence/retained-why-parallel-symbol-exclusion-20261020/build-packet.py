"""Build portable source/input identities and compact R54 claim summary."""
import hashlib,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
SOURCE=ROOT/'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
ranges={
 'core/pattern.ml':[(20,141)],
 'core/term.ml':[(262,402),(648,663),(739,864),(1164,1173),(1247,1281),(1674,1715),(1745,1815)],
 'core/decl.ml':[(344,371),(621,673)],
 'core/task.ml':[(45,62),(148,200)],
 'core/theory.ml':[(651,660),(999,1016)],
 'core/ty.ml':[(150,168),(202,219)],
 'core/trans.ml':[(209,218)],
 'driver/driver.ml':[(330,369)],
 'transform/inlining.ml':[(18,20),(27,85),(92,102),(125,149)],
 'transform/eliminate_definition.ml':[(26,59)],
 'transform/remove_unused.ml':[(46,62),(92,101),(145,175),(183,284)],
 'transform/detect_polymorphism.ml':[(45,119)],
 'transform/eliminate_inductive.ml':[(15,61)],
 'transform/eliminate_algebraic.ml':[(56,67),(593,648),(666,670)],
 'transform/eliminate_literal.ml':[(22,48),(53,93),(169,179),(181,222)],
 'transform/eliminate_gnatprove_guard_epsilon.ml':[(29,121)],
 'transform/eliminate_epsilon.ml':[(76,114),(132,221)],
 'transform/introduction.ml':[(24,54),(107,125),(173,220),(249,280)],
 'transform/simplify_formula.ml':[(15,44)],
 'transform/discriminate.ml':[(467,471)],
 'transform/encoding.ml':[(129,133)],
}
def identity(p):
 b=p.read_bytes();return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
witnesses={}
with tarfile.open(SOURCE) as t:
 for path,spans in ranges.items():
  member='why3/src/'+path;b=t.extractfile(member).read();lines=b.decode().splitlines()
  witnesses[member]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),excerpts=[dict(first=a,last=z,text='\n'.join(lines[a-1:z])) for a,z in spans])
(HERE/'source-witnesses.json').write_text(json.dumps(witnesses,indent=2)+'\n')
inputs={str(SOURCE.relative_to(ROOT)):identity(SOURCE)}
for case in ['put-line','put','first-or-default','is-message','input-is-valid']:
 for prefix,ending in [('retained-why-preinline-prefix-20261020','graph.json.gz'),('retained-why-parallel-first-fill-20261020','certificate.json'),('retained-why-parallel-residual-transfer-20261020','capture.tar.gz')]:
  p=ROOT/'docs/evidence'/prefix/(case+'-'+ending);inputs[str(p.relative_to(ROOT))]=identity(p)
 mapname='first-domain-address-map.json.gz' if case=='first-or-default' else case+'-correspondence.map.json.gz'
 p=ROOT/'docs/evidence/retained-why-parallel-residual-transfer-20261020'/mapname;inputs[str(p.relative_to(ROOT))]=identity(p)
for p in [ROOT/'docs/evidence/retained-why-preinline-prefix-20261020/model.py',ROOT/'docs/evidence/retained-why-preinline-prefix-20261020/check.py',ROOT/'docs/research/retained-why-preinline-prefix.md',ROOT/'docs/research/retained-why-parallel-first-fill.md',ROOT/'docs/research/retained-why-parallel-residual-transfer.md',ROOT/'docs/evidence/retained-why-preinline-prefix-20261020/result.json',ROOT/'docs/evidence/retained-why-parallel-first-fill-20261020/result.json']:
 inputs[str(p.relative_to(ROOT))]=identity(p)
(HERE/'inputs.json').write_text(json.dumps(dict(acquisition_freeze='43bbaf6805d7dc10269f9efe1b2394663bf0feee',source_revision='9390baf120ef260547dfa14f08e11c890b203d9c',inputs=inputs),indent=2)+'\n')
summary=[]
for case in ['put-line','put','first-or-default','is-message','input-is-valid']:
 md=json.loads((HERE/f'{case}-metadata.json').read_text());ex=json.loads((HERE/f'{case}-exclusions.json').read_text())
 assert md['transformations']==['inline_trivial','eliminate_builtin','remove_unused','detect_polymorphism','eliminate_inductive','eliminate_algebraic_if_poly','eliminate_literal','eliminate_gnatprove_guard_epsilon','eliminate_epsilon','introduce_premises','simplify_formula','discriminate_if_poly','encoding_smt_if_poly']
 assert ex['no_introduced_prsymbol'] and ex['cluster_excluded_from_keep'] and ex['inductive_clause_keys_disjoint_from_residuals']
 summary.append(dict(case=case,inline_no_count=md['updated_counts']['inline:no'],raw_tasks=md['raw_tasks'],raw_polymorphic_signatures=len(md['raw_signature_polymorphism']),unignored_polymorphic_signatures=len(ex['unignored_polymorphic_cluster']),builtin_removed_cluster_incoming_axioms=sum(x['removed_builtin'] for x in ex['cluster_incoming_declarations']),residual_keys=len(ex['witnesses']),marker_occurrences=[x['visible_candidate_occurrences'] for x in ex['witnesses']],introduced_prsymbol_metadata=False,derived_monomorphic_only=True))
result=dict(round=54,cases=summary,residual_keys=sum(x['residual_keys'] for x in summary),ordered_z3_stages=13,updated_metadata_derived_for_five_captured_domains=True,source_argument_residual_z3_strict_collision_exclusion=True,source_argument_fixed_raw_residual_ce_family_closed=True,source_theorem_machine_checked=False,arbitrary_intended_parallel_shared_state_attached=False,global_allowance=dict(save_callbacks=2,saves=3,escaping_exceptions_upper=2,scope='one unchanged process-wide budget'),native_runs=0,solver_launches=0,old_capture_replays=0)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
