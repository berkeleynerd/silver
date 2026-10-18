"""Replay the precise-symbol, optional-exclusion bound on the frozen graph."""
from pathlib import Path
import hashlib,importlib.util,json,tarfile
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
PRIOR=HERE.parent/'retained-why-preparation-entry-20261018'
def load(name,path):
 spec=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
Refiner=load('retained_inline_refiner',HERE/'refine.py').Refiner
def identity(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def verified_graph():
 manifest=json.loads((HERE/'inputs.json').read_text())
 for path,expected in manifest['dependencies'].items():assert identity((REPO/path).read_bytes())==expected,path
 previous=load('retained_inline_entry',PRIOR/'compose.py')
 result,dimensions,batches=previous.compose()
 with tarfile.open(PRIOR/'capture.tar.gz') as t:
  raw=t.extractfile('capture/inline-entry-graph.json').read();graph=json.loads(raw)
 assert identity(raw)==manifest['graph_identity']==result['graph_identity']
 return graph,result,dimensions,batches

def compose():
 graph,prior,dimensions,batches=verified_graph();model=Refiner(graph);r=model.run()
 coordinates=[tuple(x['dimensions'][k] for k in ['n','b','p','a']) for b in dimensions['ordered_batches'] for x in b['roots']]
 assert coordinates==r['input_coordinates'],'opened root correspondence mismatch'
 assert len(r['root_results'])==prior['mapped_roots']==143
 assert not r['eligibility_ambiguities']
 assert not any(x['self_reference_possible'] for x in r['definition_eligibility'])
 rows=r['root_results'];hits=r['symbol_matched_optional_hits']
 totals={
  'replace_recursive_entries_upper':sum(x[0] for x in coordinates),
  'unfold_entries_upper':sum(x[3] for x in coordinates),
  'environment_hits_upper':len(hits),
  'relocate_recursive_entries_upper':sum(x['body_dimensions'][0] for x in hits),
  'type_map_term_entries_upper':sum(x['body_dimensions'][0] for x in hits),
  'post_type_substitution_recursive_entries_upper':sum(x['body_dimensions'][0] for x in hits),
  'fresh_variable_identifiers_inside_kernel_upper':sum(x[1] for x in coordinates)+sum(2*x['body_dimensions'][1]+sum(c>0 for c in x['formal_occurrences']) for x in hits)}
 stored=[]
 for row in rows:
  mass=sum(row['output_coordinates_upper'][:3]);arity=row['arity']
  stored.append(mass+(2+2*arity+int(arity>0) if row['kind']=='logic' else 0))
 compact={
  'scope':r['scope'],'graph_identity':prior['graph_identity'],
  'source_eligible_definition_candidates':r['eligible_definition_count'],
  'environment_entries_upper':r['environment_entries'],
  'metadata_exclusion_set_known':False,'covers_every_metadata_exclusion_set':True,
  'eligibility_uniform_across_optional_choices':True,
  'ordered_mapped_roots':len(rows),'input_task_nodes':prior['entry_task_nodes'],
  'output_root_coordinate_sums_upper':dict(zip(['n','b','p','a'],(sum(x['output_coordinates_upper'][i] for x in rows) for i in range(4)))),
  'output_root_coordinate_maxima_upper':dict(zip(['n','b','p','a'],(max(x['output_coordinates_upper'][i] for x in rows) for i in range(4)))),
  'maximum_output_root_mass_upper':max(sum(x['output_coordinates_upper'][:3]) for x in rows),
  'sum_output_root_mass_upper':sum(sum(x['output_coordinates_upper'][:3]) for x in rows),
  'goal_coordinate_upper':dict(zip(['n','b','p','a'],rows[-1]['output_coordinates_upper'])),
  'goal_mass_upper':sum(rows[-1]['output_coordinates_upper'][:3]),
  'maximum_saved_hit_body_mass_upper':max(sum(x['body_dimensions'][:3]) for x in hits),
  'maximum_formal_occurrence_coefficient':max(c for x in hits for c in x['formal_occurrences']),
  'kernel_events':totals,'output_task_nodes_upper':prior['entry_task_nodes'],
  'mapped_declaration_constructor_calls_upper':len(rows),
  'maximum_reconstructed_formula_mass_upper':max(stored),
  'sum_reconstructed_formula_mass_upper':sum(stored),
  'one_pair_conditional_semantic_inline_bound_established':True,
  'exact_native_inlining_observed':False,'all_hidden_substitution_work_bounded':False,
  'all_type_and_validator_work_bounded':False,'all_fresh_identifiers_bounded':False,
  'process_wide_counter_join_established':False,'cache_backing_capacity_established':False,
  'all_fixed_pair_dimensions_established':False,'whole_pipeline_capacity_established':False,
  'source_argument_machine_checked':False,'new_native_runs':0}
 return compact,r,model

if __name__=='__main__':print(json.dumps(compose()[0],indent=2))
