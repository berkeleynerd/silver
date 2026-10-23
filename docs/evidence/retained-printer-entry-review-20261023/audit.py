"""Independent R61 finite review audit; no transformation/checker replay."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import time

ROOT=Path(sys.argv[1]);FREEZE=sys.argv[2]
HERE=Path(__file__).resolve().parent
PACKET=ROOT/'docs/evidence/retained-why-printer-entry-20261020'
def read(p):return json.loads(p.read_text())
def identity(b):return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}

def opened_shape(graph,index,frames=()):
    node=graph['terms'][index];kind,args=node['kind'],node['args']
    if kind=='var':
        v=args[0]
        for i,(bound,saved) in enumerate(frames):
            if v in bound:return ('var',(),0)
            if str(v) in saved:return opened_shape(graph,saved[str(v)],frames[i+1:])
        return ('var',(),0)
    if kind in ('const','true','false'):return (kind,(),0)
    if kind=='app':return (kind,tuple(opened_shape(graph,p,frames) for p in args[1]),0)
    if kind=='bin':return (kind,tuple(opened_shape(graph,p,frames) for p in args[1:]),0)
    if kind in ('if','not'):return (kind,tuple(opened_shape(graph,p,frames) for p in args),0)
    assert kind in ('let','eps','quant'),kind
    b=graph['bindings'][args[1] if kind in ('let','quant') else args[0]]
    nested=((set(b['variables']),b['saved']),)+frames
    children=[opened_shape(graph,b['body'],nested)]
    if kind=='let':children.insert(0,opened_shape(graph,args[0],frames))
    if kind=='quant':children += [opened_shape(graph,p,nested) for tr in b['triggers'] for p in tr]
    return (kind,tuple(children),len(b['variables']))

def slots(node):return node[2]+sum(map(slots,node[1]))

def main():
    start=time.perf_counter();checks=0
    paths=['docs/research/retained-why-printer-entry.md']
    paths+=subprocess.check_output(['git','ls-tree','-r','--name-only',FREEZE,'docs/evidence/retained-why-printer-entry-20261020'],cwd=ROOT,text=True).splitlines()
    frozen={}
    for p in paths:
        b=subprocess.check_output(['git','show',f'{FREEZE}:{p}'],cwd=ROOT)
        assert b==(ROOT/p).read_bytes(),p
        frozen[p]=identity(b);checks+=1
    for p,i in read(PACKET/'packet-inputs.json').items():
        assert identity((ROOT/p).read_bytes())==i,p;checks+=1
    inputs=read(PACKET/'inputs.json')
    for p,i in inputs['retained_inputs'].items():
        assert identity((ROOT/p).read_bytes())==i,p;checks+=1
    for p,i in inputs['external_frozen_inputs'].items():
        assert identity(subprocess.check_output(['git','show',p],cwd=ROOT))==i,p;checks+=1
    w=read(PACKET/'source-witnesses.json')
    assert identity((ROOT/w['archive']).read_bytes())==w['archive_identity']
    with tarfile.open(ROOT/w['archive']) as t:
        for name,row in w['sources'].items():
            b=t.extractfile(row['member']).read();assert identity(b)=={k:row[k] for k in ('bytes','sha256')}
            ls=b.decode().splitlines(keepends=True);checks+=1
            for s in row['sections']:
                assert ''.join(ls[s['first']-1:s['last']])==s['text'];checks+=1
    # Independently decode only the four named exceptional let paths. This
    # uses raw retained syntax/substitution frames, not the producer model.
    special=[]
    for case,goal in [('put-line',62),('put',52)]:
        graph=read_gzip(ROOT/f'docs/evidence/retained-why-preinline-prefix-20261020/{case}-graph.json.gz')
        inventory=read(PACKET/f'{case}-inventory.json')
        for route in ('raw','ce'):
            row=next(r for r in inventory['routes'][route] if r['goal']==goal)
            tree=opened_shape(graph,row['formula']);found=[]
            def walk(node,path=(),ancestors=()):
                if node[0]=='let' and slots(node[1][0]):
                    assert slots(node[1][1])==0
                    assert not any(k=='let' and index==0 for k,index in ancestors)
                    found.append(list(path))
                for index,child in enumerate(node[1]):walk(child,path+(index,),ancestors+((node[0],index),))
            walk(tree)
            assert found==[r['path'] for r in row['binding_bearing_let_values']]
            assert len(found)==1
            special.append({'case':case,'route':route,'goal':goal,'path':found[0],
                            'let_value_ancestors':0,'target_bound_slots':0});checks+=3
    # A source-shaped, unmemoized t_gen_map fixture. The quantified
    # predicate has seven free variables, 32 unused bound slots and 100
    # dead saved keys whose stored values are variables. Dead saved values
    # are walked even though none contributes a free prepass key.
    fixture={'kind':'quant','bound':list(range(32)),
             'saved':{i:{'kind':'var'} for i in range(100)},
             'body':{'kind':'app','typed':False,
                     'children':[{'kind':'var'} for _ in range(7)]}}
    dimensions={'N':0,'B':0,'J':0,'F':7};calls=[]
    def request_type(role):calls.append(role)
    def visit(node):
        dimensions['N']+=1
        if node['kind']=='var':request_type('typed term');return
        if node['kind']=='app':
            if node['typed']:request_type('typed term')
            for child in node['children']:visit(child)
            return
        assert node['kind']=='quant'
        for key,value in node['saved'].items():
            dimensions['J']+=1;request_type('saved key');visit(value)
        for slot in node['bound']:
            dimensions['B']+=1;request_type('bound slot')
        visit(node['body'])
    for key in range(dimensions['F']):request_type('free prepass key')
    visit(fixture)
    n,b,j,f=(dimensions[k] for k in ('N','B','J','F'))
    actual=len(calls)
    assert (n,b,j,f)==(109,32,100,7)
    assert actual<=n+b+j+f
    assert actual>n+j+f and actual>n+b+f and actual>n+b+j
    checks+=5
    result=read(PACKET/'result.json')
    demands={}
    for row in result['cases']:
        d=row['dimensions'];one=row['one_episode'];total=row['process_demands'];e=row['episodes_upper']
        assert e==3*row['registered_roots']+2
        assert d['K']==d['K0']+64*e*d['P']**2
        assert d['V']==6*d['Q'] and d['S']==24*d['M']+32
        assert d['unique_goal_pre_introduction_R']==2*d['M']*(1+6*d['unique_goal_pre_introduction_K'])
        assert all(total[k]==e*v for k,v in one.items())
        assert total['new_type_tags']==total['type_hashcons_requests'];checks+=6
        components=row['direct_Ident_components']
        intro=3*d['unique_goal_pre_introduction_R']
        ordinary=1024*d['D']*(d['S']+1)*(d['P']+1)
        assert components['introduction_type_map_variable_clones']=={'one_episode':intro,'process_demand':e*intro}
        assert components['opening_and_generated_symbols']=={'one_episode':ordinary,'process_demand':e*ordinary}
        assert one['direct_Ident_registrations']==ordinary+intro
        preceding=read(ROOT/f"docs/evidence/retained-why-postinline-preparation-20261020/{row['case']}-inventory.json")
        t=preceding['signature_maxima']['type_nodes'];a=preceding['signature_maxima']['arity']
        forest=sum(preceding['ground_data'][k] for k in ('founded_type_entries','founded_constructor_entries'))
        assert one['type_hashcons_requests']==4*t*t*d['unique_goal_pre_introduction_R']+64*d['task_nodes']*(forest+(a+1)*t)
        checks+=4
        demands[row['case']]={
            'Ident':total['direct_Ident_registrations'],
            'Decl.Hsdecl':total['logical_decl_constructor_requests'],
            'Ty.Hsty':total['type_hashcons_requests'],
            'Theory.Hstdecl':total['tdecl_constructor_requests'],
            'Task.Hstask':total['task_add_requests'],
            'Task.Stdecl.Hcpt':64*total['task_add_requests']}
    assert result['combined_demands']['type_hashcons_requests']==sum(d['Ty.Hsty'] for d in demands.values())
    assert not result['initial_counter_plus_whole_suffix_headroom_claimed']
    assert not result['new_stage_escape_allowance'] and not result['aggregate_RAM_gate'];checks+=3
    out={'status':'pass','freeze':FREEZE,'reviewer_script_identity':identity(Path(__file__).read_bytes()),'exact_inputs':frozen,'checks':checks,
         'exceptional_let_paths':special,'type_map_dimension_fixture':{'N':n,'B':b,'J':j,'F':f,'fnT_calls':actual},
         'six_owner_mapping_without_second_episode_multiplier':demands,
         'elapsed_seconds':time.perf_counter()-start,'native_runs':0,'predecessor_checker_replays':0,
         'author_checker_replayed':False,'transforms_executed':False,
         'limits':'Finite identity/path/arithmetic audit; universal source/lineage argument independently reviewed in the report.'}
    (HERE/'audit-result.json').write_text(json.dumps(out,indent=2)+'\n')
    print(json.dumps({k:v for k,v in out.items() if k not in ('exact_inputs','six_owner_mapping_without_second_episode_multiplier')},indent=2))

def read_gzip(p):return json.loads(gzip.decompress(p.read_bytes()))
if __name__=='__main__':main()
