"""Replay the retained one-pair entry measurement, without native tools."""
from pathlib import Path
import hashlib,importlib.util,json,tarfile
HERE=Path(__file__).resolve().parent
_decoder_spec=importlib.util.spec_from_file_location("retained_entry_decoder",HERE/"decode.py")
_decoder=importlib.util.module_from_spec(_decoder_spec);_decoder_spec.loader.exec_module(_decoder)
decode=_decoder.decode
REPO=HERE.parents[2]
def identity(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def read_archive(name,expected):
 p=HERE/(name+'.tar.gz');assert identity(p.read_bytes())==expected['identity']
 with tarfile.open(p) as t:
  members=t.getmembers();assert all(m.isfile() for m in members)
  assert len({m.name for m in members})==len(members)
  data={m.name:t.extractfile(m).read() for m in members}
 assert {n:identity(b) for n,b in data.items()}==expected['members']
 return data

def compose():
 manifest=json.loads((HERE/'inputs.json').read_text())
 for n,v in manifest['dependencies'].items():assert identity((REPO/n).read_bytes())==v
 capture=read_archive('capture',manifest['capture'])
 sources=read_archive('sources',manifest['sources'])
 drivers=read_archive('drivers',manifest['drivers'])
 prior=json.loads((REPO/'docs/evidence/retained-why-preparation-bound-20261018/inputs.json').read_text())
 overlap=set(prior['members'])&set(sources)
 for n in overlap:assert identity(sources[n])==prior['members'][n]
 assert {'src/core/term.ml','src/core/decl.ml','src/core/ty.ml','src/driver/driver.ml'}<=overlap
 s=json.loads(capture['capture/summary.json']);plan=json.loads(capture['plan.json'])
 case=plan['inputs'][0];assert len(plan['inputs'])==1 and case['name']=='input_is_valid'
 assert identity(capture['input/'+case['argv'][-1]])==case['input']
 process=json.loads(capture['capture/process.json'])
 assert process['argv']==case['argv'] and process['environment']==case['environment']
 assert s['completed'] and not s['failures'] and not s['guard_hits'] and not s['new_threads']
 assert not any(v['hits'] for v in s['forbidden_calls'].values())
 assert len(s['driver_preparation'])==1
 prep=s['driver_preparation'][0]
 assert prep['visited_directives']==['counterexamples_dependent_intros','inline_trivial']
 matching=[i for row in s['dispatch']['graft'] for i,x in enumerate(row['tasks']) if x==prep['input_shape']]
 assert matching==[2]
 envelope=json.loads((REPO/'docs/evidence/retained-producer-driver-envelope-20261018/result.json').read_text())
 assert next(r for r in envelope['cases'] if r['name']==case['name'])['input_sha256']==case['input']['sha256']
 assert prep['directives']==[x['name'] for x in envelope['selected_driver_dispatch']['cvc5']['transformations']]
 graph=json.loads(capture['capture/inline-entry-graph.json'])
 assert identity(capture['capture/inline-entry-graph.json'])==s['inline_entry']['graph']
 assert graph['task_address']==s['inline_entry']['task']
 assert graph['ordered_tdecls']==s['inline_entry']['ordered_tdecls']
 assert [r['tdecl'] for r in graph['ordered_tdecls']]==list(reversed(s['inline_entry']['shape']['declaration_addresses']))
 resolution=json.loads(capture['driver-resolution.json'])
 assert set(resolution)==set(drivers)
 for name,row in resolution.items():assert identity(drivers[name])==row['identity']
 d=decode(graph)
 logical=iter(d['ordered_batches']);batches=[]
 for td in graph['ordered_tdecls']:
  if td['node_tag']==0:
   b=next(logical);kind=['type','data','param','logic','ind','prop'][b['tag']]
   terms=[]
   for root in b['roots']:
    x=root['dimensions'];q={'nodes':x['n'],'binders':x['b'],'mass':x['m'],'applications':x['a']}
    if kind=='logic':q['arity']=root['arity']
    terms.append(q)
  else:kind={1:'use',2:'clone',3:'meta'}[td['node_tag']];terms=[]
  batches.append({'kind':kind,'terms':terms})
 assert next(logical,None) is None
 # Feed the reviewed callable only up to the FIRST demonstrably excessive
 # conservative bound. Never evaluate its astronomical remaining recurrence.
 module_path=REPO/'docs/evidence/retained-why-preparation-bound-20261018/compose.py'
 spec=importlib.util.spec_from_file_location('conditional_inline',module_path)
 mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)
 env={'nodes':0,'binders':0,'mass':1,'freevars':0};excess=None;prefix=[]
 for index,batch in enumerate(batches):
  rows=[mod.inline_kernel(t,env) for t in batch['terms']]
  high=next((v for v in rows if v['output_opened_mass_upper']>(1<<62)-1),None)
  if high:
   excess={'task_node_index':index,'logical_declaration_index':sum(b['kind'] not in {'meta','use','clone'} for b in batches[:index]),
    'environment_before':env,'input_batch':batch,'kernel_result':high,'ocaml_int_max':(1<<62)-1,
    'meaning':'conservative upper bound exceeds machine range; no observed overflow or actual growth claim'}
   break
  prefix.append(batch)
  if batch['kind']=='logic' and len(rows)==1:
   mass=rows[0]['output_opened_mass_upper'];arity=batch['terms'][0]['arity']
   env={'nodes':max(env['nodes'],mass),'binders':max(env['binders'],mass-1),'mass':max(env['mass'],mass),'freevars':max(env['freevars'],min(arity,mass))}
 assert excess
 assert mod.inline_context(prefix)['input_task_nodes']==len(prefix)
 roots=[r for b in d['ordered_batches'] for r in b['roots']]
 stored=d['stored'];bi=stored['bind_infos']
 result={'scope':'Input_Is_Valid, first actual cvc5 inline_trivial entry only',
 'input_sha256':case['input']['sha256'],'original_graft_child_index':matching[0],
 'input_task_nodes':prep['input_shape']['chain_length'],'entry_task_nodes':len(batches),
 'declaration_kinds':{k:sum(b['kind']==k for b in batches) for k in sorted({b['kind'] for b in batches})},
 'mapped_roots':len(roots),'root_dimension_sums':{k:sum(r['dimensions'][k] for r in roots) for k in ['n','b','p','a','m']},
 'root_coordinate_maxima':{k:max(r['dimensions'][k] for r in roots) for k in ['n','b','p','a','m']},
 'maximum_logic_arity':max(r.get('arity',0) for r in roots),
 'goal_dimensions':[r['dimensions'] for b in d['ordered_batches'] if b.get('prop_kind')==2 for r in b['roots']],
 'unique_stored_terms':stored['unique_terms_including_unused_substitution_values'],
 'bind_infos':len(bi),'validated_binder_payloads':d['validated_binder_payloads'],
 'stored_substitution_entries':sum(b['substitution_entries'] for b in bi),
 'nonempty_stored_substitution_maps':sum(b['substitution_entries']>0 for b in bi),
 'maximum_stored_substitution_map':max(b['substitution_entries'] for b in bi),
 'all_graph_blocks':stored['all_graph_blocks'],'all_graph_payload_bytes':stored['all_graph_payload_bytes'],
 'graph_identity':s['inline_entry']['graph'],'first_conservative_excess':excess,
 'one_pair_opened_dimensions_observed':True,'all_fixed_pair_dimensions_established':False,
 'all_preparation_capacity_established':False,'whole_pipeline_capacity_established':False,
 'source_argument_machine_checked':False,'new_native_runs_for_replay':0}
 return result,d,batches

if __name__=='__main__':
 result,dimensions,batches=compose()
 print(json.dumps(result,indent=2))
