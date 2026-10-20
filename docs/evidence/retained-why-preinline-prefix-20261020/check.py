#!/usr/bin/env python3
"""New finite prefix transfer; reads retained data, never executes target code."""
import argparse,gzip,hashlib,json,struct,tarfile,time
from pathlib import Path
from collections import Counter
import model as m

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
CAP="docs/evidence/retained-why-save-state-capture-20261020/"
CASES=('put_line','put','first_or_default','is_message','input_is_valid')

def metrics(c):
    k=c[0];out=Counter(n=1,b=0,p=0,a=int(k=='app'),trigger_groups=0)
    kids=[]
    if k=='app':kids=c[3]
    elif k in ('if','not'):kids=c[2]
    elif k=='bin':kids=c[3]
    elif k in ('let','eps','quant'):
        b=c[3] if k in ('let','quant') else c[2]
        if k=='let':kids=[c[2]]
        else:kids=[]
        out['b']+=b[0];out['trigger_groups']+=len(b[1]);kids+=[b[2]]+[x for g in b[1] for x in g]
    elif k=='case':
        kids=[c[2]]
        for p,b in c[3]:
            out['p']+=p[3];out['b']+=b[0];kids.append(b[2])
    for x in kids:out.update(metrics(x))
    return out

def decl(raw,d):
    node,_,_=raw.fields(d,3);kind=raw.blocks[node]['tag'];value,=raw.fields(node,1,kind)
    out=dict(kind=kind,id=d,roots=[])
    if kind==2:out['symbol']=raw.symbol(value)
    elif kind==3:
        out['definitions']=[]
        for pair in raw.seq(value):
            ls,df=raw.fields(pair,2);ls1,formula,decr=raw.fields(df,3);assert ls==ls1
            out['definitions'].append((raw.symbol(ls),raw.term(formula)));out['roots'].append(raw.term(formula))
    elif kind==4:
        sign,entries=raw.fields(value,2)
        for entry in raw.seq(entries):
            ls,clauses=raw.fields(entry,2);raw.symbol(ls)
            for pair in raw.seq(clauses):
                pr,f=raw.fields(pair,2);out['roots'].append(raw.term(f))
    elif kind==5:
        pk,pr,f=raw.fields(value,3);out.update(pk=pk>>1,symbol=pr,roots=[raw.term(f)])
    return out

def mapped(raw,d):
    for i,t in enumerate(d['roots']):
        c=m.canonical(t,triggers=True,stats=True);arity=0
        if d['kind']==3:
            if c[0]=='quant':
                assert c[2]==0;arity=c[3][0];c=c[3][2]
            assert c[0] in ('app','bin');c=c[3][1]
            assert arity==raw.symbols[d['definitions'][i][0]]['arity']
        yield metrics(c),arity

def hidden(roots):
    terms=set();binds=set()
    def walk(t):
        if t in terms:return
        terms.add(t);k,a=t.kind,t.args
        if k in ('let','quant'):bs=[a[1]]
        elif k=='eps':bs=[a[0]]
        elif k=='case':bs=[b for p,b in a[1]]
        else:bs=[]
        binds.update(bs)
        for x in m.children(t,True):walk(x)
    for t in roots:walk(t)
    return dict(stored_terms=len(terms),binders=len(binds),nonempty_maps=sum(bool(b.saved) for b in binds),saved_entries=sum(len(b.saved) for b in binds),max_map=max((len(b.saved) for b in binds),default=0))


def ident(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
def read(path):return json.loads(path.read_bytes())
def json_bytes(value):return (json.dumps(value,sort_keys=True,indent=2)+'\n').encode()

def convert_graph(graph):
    out={}
    for p,r in graph['blocks'].items():
        data=bytes.fromhex(r['payload_hex']) if 'payload_hex' in r else struct.pack('<'+'Q'*len(r['fields']),*r['fields'])
        assert r['words']==len(data)//8 and r['tag']==r['header']&255 and r['words']==r['header']>>10
        out[int(p)]={**r,'address':int(p),'header_hex':int(r['header']).to_bytes(8,'little').hex(),'payload_hex':data.hex()}
    return out

def validate_table(table,graph):
    n=table['outer_length'];assert n==5003 and len(table['buckets'])==n
    assert len(table['outer_array']['fields'])==len(table['hash_outer_array']['fields'])==n
    roots=[];allocated=0
    for i,b in enumerate(table['buckets']):
        assert b['index']==i and b['address']==table['outer_array']['fields'][i]
        assert b['hash_array']['address']==table['hash_outer_array']['fields'][i]
        hashes=b['hash_array']['fields']
        if b['header']==0:
            assert not hashes
            continue
        payload=b['payload'];assert b['header']&255==251
        assert b['header']>>10==len(payload) and len(payload)==len(hashes)+2
        assert payload[1]==table['ephe_none_value']
        allocated+=len(hashes)
        for p,h in zip(payload[2:],hashes):
            assert h&1
            if p!=table['ephe_none_value']:
                assert ((h>>1)&((1<<62)-1))%n==i
                roots.append(p)
    assert allocated==table['allocated_key_slots']
    assert len(roots)==table['nonempty_key_slots']
    assert len(set(roots))==len(table['retained_unique_declarations'])
    graph_roots=graph.get('hsdecl_declaration_roots',graph['roots'])
    assert set(roots)==set(table['retained_unique_declarations'])==set(graph_roots)
    blocks=graph['blocks']
    for p in roots:assert str(p) in blocks
    # Check complete graph closure, without reinterpreting unrelated payloads.
    for p,r in blocks.items():
        if 'fields' in r:
            for v in r['fields']:
                if not v&1:assert str(v) in blocks,(p,v)
    return dict(nonempty_slots=len(roots),distinct_objects=len(set(roots)),allocated_slots=allocated,
                graph_blocks=len(blocks),complete_slot_and_graph_closure=True)

def metadata_graph(raw,roots):
    seen=set();binds=set()
    def walk(t):
        if t in seen:return
        seen.add(t)
        if t.kind in ('let','quant'):bs=[t.args[1]]
        elif t.kind=='eps':bs=[t.args[0]]
        elif t.kind=='case':bs=[b for p,b in t.args[1]]
        else:bs=[]
        binds.update(bs)
        for c in m.children(t,True):walk(c)
    for t in roots:walk(t)
    saved=[t for b in binds for t in b.saved.values()]
    dims=[metrics(m.canonical(t,triggers=True)) for t in saved]
    base=hidden(roots)
    base.update(saved_image_kinds=dict(Counter(t.kind for t in saved)),
                max_saved_image_nodes=max((d['n'] for d in dims),default=0),
                max_saved_image_binders=max((d['b'] for d in dims),default=0),
                max_free_map_keys=max((len(b.free) for b in binds),default=0),
                max_attributes=max((len(t.attrs) for t in seen),default=0))
    return base,seen,binds

def tvs(raw,t,variables,seen=None):
    if seen is None:seen=set()
    if t in seen:return set()
    seen.add(t);out=set() if t.ty is None else set(raw.typevars(t.ty))
    if t.kind=='quant':
        for v in t.args[1].variables:out.update(raw.typevars(variables[v][0]))
    for c in m.children(t,True):out.update(tvs(raw,c,variables,seen))
    return out

def free_in_tree(c):
    k=c[0]
    if k=='var':return Counter({c[2][1]:1}) if c[2][0]=='free' else Counter()
    if k=='app':kids=c[3]
    elif k in ('if','not'):kids=c[2]
    elif k=='bin':kids=c[3]
    elif k in ('let','eps','quant'):
        b=c[3] if k in ('let','quant') else c[2]
        kids=([c[2]] if k=='let' else [])+[b[2]]+[x for g in b[1] for x in g]
    elif k=='case':kids=[c[2]]+[b[2] for p,b in c[3]]
    else:kids=[]
    return sum((free_in_tree(x) for x in kids),Counter())

def verify_binding_free_counts(binds):
    for b in binds:
        frames=(({v:i for i,v in enumerate(b.variables)},b.saved),)
        roots=[b.body]+[t for g in b.triggers for t in g]
        actual=sum((free_in_tree(m.canonical(t,frames,len(b.variables),True)) for t in roots),Counter())
        assert actual==b.free,('binding free-variable mismatch',b.raw,actual,b.free)

def export_graph(raw,ce,roots):
    terms={};binds={};trows=[];brows=[]
    def bind(b):
        if b in binds:return binds[b]
        index=len(brows);binds[b]=index;brows.append(None)
        brows[index]=dict(raw=b.raw,variables=b.variables,free_variables=dict(b.free),
            saved={str(v):term(t) for v,t in b.saved.items()},body=term(b.body),
            triggers=[[term(t) for t in g] for g in b.triggers])
        return index
    def term(t):
        if t in terms:return terms[t]
        index=len(trows);terms[t]=index;trows.append(None);k,a=t.kind,t.args
        if k=='app':args=[a[0],[term(t) for t in a[1]]]
        elif k in ('if','not'):args=[term(t) for t in a]
        elif k=='bin':args=[a[0],term(a[1]),term(a[2])]
        elif k=='let':args=[term(a[0]),bind(a[1])]
        elif k=='quant':args=[a[0],bind(a[1])]
        elif k=='eps':args=[bind(a[0])]
        elif k=='case':args=[term(a[0]),[[p,bind(b)] for p,b in a[1]]]
        else:args=a
        trows[index]=dict(raw=t.raw,kind=k,args=args,type=t.ty,attrs=sorted(t.attrs),location=t.loc)
        return index
    indexes=[term(t) for t in roots]
    symbols={str(p):{**s,'attrs':sorted(s['attrs'])} for p,s in raw.symbols.items()}
    variables={str(p):dict(type=t,name=n,attrs=sorted(a)) for p,(t,n,a) in ce.variables.items()}
    return dict(terms=trows,bindings=brows,symbols=symbols,variables=variables),indexes

def calculate_case(case,members):
    slug=case.replace('_','-');archive=CAP+'capture-'+slug+'.tar.gz'
    prefix=('inline/' if case=='input_is_valid' else 'registration/')+case+'/capture/'
    get=lambda name:members[(archive,prefix+name)]
    process=json.loads(get('process.json'));summary=json.loads(get('summary.json'))
    assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
    group='inline' if case=='input_is_valid' else 'registration'
    assert summary['snapshots'][-1]['label']==('inline_trivial_entry' if group=='inline' else 'end_of_registration')
    if group=='inline':
        assert len(summary['driver_preparation'])==1
        assert summary['driver_preparation'][0]['visited_directives']==['counterexamples_dependent_intros','inline_trivial']
    raw=m.Raw(get('session-blocks.jsonl'));chains=json.loads(get('session-task-chains.json'));forest=json.loads(get('session-forest.json'))
    contexts={tuple(row['tdecl'] for row in chain[1:]) for chain in chains.values()}
    assert len(contexts)==1
    table=json.loads(get('hsdecl-table.json'))
    graph=json.loads(get('inline-entry-graph.json' if group=='inline' else 'representative-graph.json'))
    table_check=validate_table(table,graph)
    block_graph=convert_graph(graph)
    for p,r in block_graph.items():
        if p in raw.blocks:
            old=raw.blocks[p]
            assert (old['tag'],old['words'],old['payload_hex'])==(r['tag'],r['words'],r['payload_hex']),p
        else:raw.blocks[p]=r
    decls={};tasks={}
    for task,chain in chains.items():
        ds=[];following=int(task)
        for row in chain:
            assert row['option']==following
            head,=raw.fields(following,1);assert head==row['head']
            td,following,*_=raw.fields(head,6);assert td==row['tdecl']
        assert following==1
        for row in reversed(chain):
            node,_=raw.fields(row['tdecl'],2)
            if raw.blocks[node]['tag']==0:
                d,=raw.fields(node,1)
                if d not in decls:decls[d]=decl(raw,d)
                ds.append(d)
        tasks[task]=ds
    common=next(iter(tasks.values()))[:-1]
    assert all(ds[:-1]==common for ds in tasks.values())
    # Exact physical equality symbol, attached through the source BuiltIn prefix.
    assert [decls[d]['kind'] for d in common[:4]]==[0,0,0,2]
    eq=decls[common[3]]['symbol'];signature=raw.symbols[eq]
    assert signature['name']=='infix =' and signature['arity']==2
    assert signature['value_type'] is None and signature['arg_types'][0]==signature['arg_types'][1]
    assert not signature['constr'] and not signature['projection'] and not signature['attrs']
    assert len(raw.typevars(signature['arg_types'][0]))==1
    assert [p for p,s in raw.symbols.items() if s['name']=='infix =']==[eq]
    # All actual patterns are nullary constructors: Pattern.check_compile's
    # fresh argument list and both branch-renaming lists are empty.
    assert all(p[0]=='app' and not p[1][1] and not p[2] and p[3]==1 for p in raw.patterns.values())
    ce=m.CE(raw,eq);results={};charges={};events={};branch_events={}
    for d,info in decls.items():
        kind=info['kind'];drop=False
        if kind==2:drop='id:unused' in raw.symbols[info['symbol']]['attrs']
        elif kind==3 and len(info['definitions'])==1:drop='id:unused' in raw.symbols[info['definitions'][0][0]]['attrs']
        before=ce.events.copy();branch=ce.branch_events.copy()
        if drop:results[d]=None
        elif kind==5:
            assert info['pk'] in (1,2)
            assert not tvs(raw,info['roots'][0],ce.variables)
            result=ce.remove(info['pk']==2,info['roots'][0])
            assert not tvs(raw,result,ce.variables) and not free_in_tree(m.canonical(result,triggers=True))
            results[d]={**info,'roots':[result]}
        else:results[d]=info
        events[d]=dict(ce.events-before);branch_events[d]=dict(ce.branch_events-branch)
        charges[d]=sum(events[d].get(k,0) for k in ('binder_open','unused_copy'))
    assert not ce.branch_events['iff_expanded'] and not ce.branch_events['if_expanded']
    assert not ce.branch_events['unused_equality']
    # Complete same-Paxiom-key projection. Equality may reject more rows;
    # keeping any coordinate-compatible old row is safe for hidden state.
    key_to_decl={decls[d]['symbol']:d for d in common if decls[d]['kind']==5}
    assert len(key_to_decl)==sum(decls[d]['kind']==5 for d in common)
    matches={d:[] for d in key_to_decl.values()}
    for oldd in table['retained_unique_declarations']:
        dn,_,_=raw.fields(oldd,3)
        if raw.blocks[dn]['tag']!=5:continue
        pp,=raw.fields(dn,1,5);kind,pr,f=raw.fields(pp,3)
        if kind!=3 or pr not in key_to_decl:continue
        d=key_to_decl[pr];oldterm=raw.term(f)
        before=metrics(m.canonical(oldterm,triggers=True));after=metrics(m.canonical(results[d]['roots'][0],triggers=True))
        matches[d].append(dict(declaration=oldd,formula=f,coordinates=dict(before),
            compatible=before==after,raw_declaration=oldd==d))
    if group=='registration':
        assert all(len(rows)==1 and rows[0]['declaration']==d for d,rows in matches.items())
    # Input's current successful CE context is observed after first fill.
    observed_rows=None;observed_check=None
    if group=='inline':
        observed_rows=[decl(raw,d) for d in graph['input_declaration_roots']]
        selected_task=next(v['task'] for v in forest['visits'] if v['goal']==3)
        candidate=[results[d] for d in tasks[str(selected_task)] if results[d] is not None]
        assert len(candidate)==len(observed_rows)
        for a,b in zip(candidate,observed_rows):
            assert a['kind']==b['kind'] and a.get('symbol')==b.get('symbol')
            assert len(a['roots'])==len(b['roots'])
            for t,u in zip(a['roots'],b['roots']):
                assert m.canonical(t,triggers=True)==m.canonical(u,triggers=True)
        obsroots=[t for d in observed_rows for t in d['roots']]
        candroots=[t for d in candidate for t in d['roots']]
        assert hidden(obsroots)==hidden(candroots)
        observed_check=dict(alpha_with_triggers=True,all_mapped_roots=143,
            candidate_and_observed_stored_counts=hidden(obsroots),complete_graph_isomorphism_claimed=False)
    # A seed family for each shared-context declaration. Goals never query
    # Hsdecl; non-propositions pass through unchanged.
    families={}
    observed_by_key={d.get('symbol'):d for d in (observed_rows or []) if d['kind']==5 and d['pk']==1}
    for d in common:
        info=results[d]
        if info is None:families[d]=[];continue
        roots=list(info['roots'])
        if info['kind']==5:
            if group=='registration':
                roots.extend(raw.term(r['formula']) for r in matches[d] if r['compatible'])
            else:roots.extend(observed_by_key[info['symbol']]['roots'])
        families[d]=list(dict.fromkeys(roots))
    r50=read(ROOT/'docs/evidence/retained-why-goal-revalidation-20261020/goal-certificate.json')[case]
    old_goal={g['goal']:g for g in r50['goals']}
    selected=[];all_goals=[]
    for v in forest['visits']:
        assert not v['detached']
        ds=tasks[str(v['task'])];goal=decls[ds[-1]];assert goal['kind']==5 and goal['pk']==2
        rawdim=metrics(m.canonical(goal['roots'][0],triggers=True))
        assert rawdim['n']==old_goal[v['goal']]['term_occurrences'] and rawdim['b']==old_goal[v['goal']]['registration_charge']
        all_goals.append(dict(goal=v['goal'],task=v['task'],raw_formula=goal['roots'][0].raw,
                              raw_coordinates=dict(rawdim),ce_coordinates=dict(metrics(m.canonical(results[ds[-1]]['roots'][0],triggers=True)))))
        if v['root'] or (case=='input_is_valid' and v['goal']!=3):continue
        stages={}
        for stage,infos in [('raw',[decls[d] for d in ds]),('ce',[results[d] for d in ds if results[d] is not None])]:
            counts=Counter();maxima=Counter();validation=0;root_rows=[]
            for info in infos:
                for i,(dim,arity) in enumerate(mapped(raw,info)):
                    counts.update(dim)
                    for k,n in dim.items():maxima[k]=max(maxima[k],n)
                    validation+=dim['b']+arity
                    root_rows.append(dict(declaration=info['id'],root_index=i,role='logic_body' if info['kind']==3 else 'formula',
                                          coordinates=dict(dim),formal_arity=arity))
            roots=[t for info in infos for t in info['roots']]
            stored,_,_=metadata_graph(raw,roots)
            stages[stage]=dict(logical_declarations=len(infos),mapped_roots=len(root_rows),
                coordinate_sums=dict(counts),coordinate_maxima=dict(maxima),stored=stored,
                validation_Ident_upper=validation)
        ce_goal=results[ds[-1]]['roots'][0];goalb=metrics(m.canonical(ce_goal,triggers=True))['b']
        seedroots=[t for d in common for t in families[d]]+[ce_goal]
        seed_profile,_,_=metadata_graph(raw,seedroots)
        mapping=sum(charges[d] for d in ds);validation=stages['ce']['validation_Ident_upper']
        selected.append(dict(goal=v['goal'],task=v['task'],stages=stages,
            ce_mapping_Ident_upper=mapping,ce_validation_Ident_upper=validation,
            ce_direct_Ident_upper=mapping+validation,altergo_mono_goal_validation_Ident_upper=goalb,
            altergo_prefix_Ident_upper=mapping+validation+goalb,
            mono_fresh_type_symbols=0,ce_seed_union_stored_upper=seed_profile))
    # All decoded input/candidate binding maps are checked against independent
    # opened free-variable occurrence counts; hidden values are never dropped.
    roots=[t for i in decls.values() for t in i['roots']]+[t for i in results.values() if i for t in i['roots']]+[t for roots in families.values() for t in roots]
    _,all_terms,binds=metadata_graph(raw,roots);verify_binding_free_counts(binds)
    ce.variables={**raw.variables,**ce.variables}
    exported,indexes=export_graph(raw,ce,roots)
    raw_count=sum(len(i['roots']) for i in decls.values())
    candidate_count=sum(len(i['roots']) for i in results.values() if i)
    raw_pos=0;candidate_pos=raw_count;seed_pos=raw_count+candidate_count;decl_rows=[]
    for d,info in decls.items():
        # references use the shared export map below, preserving every lsymbol.
        nr=len(info['roots']);nc=len(results[d]['roots']) if results[d] is not None else 0
        nf=len(families.get(d,[]))
        decl_rows.append(dict(declaration=d,kind=info['kind'],symbol=info.get('symbol'),
            definition_symbols=[s for s,t in info.get('definitions',[])],
            raw_mapped_roots=[dict(coordinates=dict(dim),formal_arity=arity) for dim,arity in mapped(raw,info)],
            candidate_mapped_roots=[] if results[d] is None else [dict(coordinates=dict(dim),formal_arity=arity) for dim,arity in mapped(raw,results[d])],
            raw_root_indexes=indexes[raw_pos:raw_pos+nr],
            candidate_root_indexes=indexes[candidate_pos:candidate_pos+nc],
            seed_root_indexes=indexes[seed_pos:seed_pos+nf],
            dropped=results[d] is None,mapping_events=events[d],branch_events=branch_events[d]))
        raw_pos+=nr;candidate_pos+=nc;seed_pos+=nf
    # Explicit formula-root index lists correspond to the ordered declarations.
    exported.update(raw_root_indexes=indexes[:raw_count],candidate_root_indexes=indexes[raw_count:raw_count+candidate_count],
                    seed_root_indexes=indexes[raw_count+candidate_count:],declarations=decl_rows,
                    raw_task_declaration_sequences=tasks)
    sumc=sum(r['ce_direct_Ident_upper'] for r in selected)
    sumb=sum(r['altergo_mono_goal_validation_Ident_upper'] for r in selected)
    maxprefix=max(r['altergo_prefix_Ident_upper'] for r in selected)
    full=2*sumc+sumb+2*maxprefix
    subtraction=selected[0]['ce_direct_Ident_upper'] if group=='inline' else 0
    case_result=dict(case=case,pid=process['pid'],selected_goals=len(selected),
        retained_serial_seed_closure_under_named_premises=True,
        intended_parallel_seed_closure=False,
        common_task_prefix_nodes=len(next(iter(contexts))),common_logical_declarations=len(common),
        common_context_ce_mapping_Ident_upper=sum(charges[d] for d in common),
        table=table_check,context_Paxiom_keys=len(matches),
        same_key_old_objects=sum(map(len,matches.values())),
        compatible_old_objects=sum(r['compatible'] for rs in matches.values() for r in rs),
        raw_goal_type_variables=0,ce_goal_type_variables=0,mono_new_type_symbols=0,
        selected_raw_max_coordinate_sums={k:max(r['stages']['raw']['coordinate_sums'][k] for r in selected) for k in ('n','b','p','a')},
        selected_ce_max_coordinate_sums={k:max(r['stages']['ce']['coordinate_sums'][k] for r in selected) for k in ('n','b','p','a')},
        selected_ce_direct_Ident_max=max(r['ce_direct_Ident_upper'] for r in selected),
        selected_ce_direct_Ident_sum=sumc,selected_ce_goal_binder_sum=sumb,
        selected_altergo_prefix_Ident_max=maxprefix,
        under_named_episode_and_seed_premises=dict(full_prefix_Ident_upper=full,post_cut_prefix_Ident_upper=full-subtraction,
            already_completed_cvc5_prefix_allowance=subtraction,global_escape_budget=2),
        observed_input_check=observed_check,verified_binding_free_maps=len(binds),
        opened_expansion_branches=dict(ce.branch_events))
    certificate=dict(case=case,pid=process['pid'],equality_symbol=eq,common_context_declarations=common,
                     seed_union_scope='Retained serial continuation under named first-fill/cache/freshness premises; no intended-parallel transfer',
                     all_raw_goals=all_goals,selected=selected,same_key_projection=matches)
    m.Raw.term.cache_clear();m.Raw.seq.cache_clear();m.Raw.attrs.cache_clear();m.Raw.typevars.cache_clear();m.freevars.cache_clear()
    return case_result,certificate,exported

def calculate():
    inputs=read(HERE/'inputs.json')
    for p,want in inputs['files'].items():assert ident((ROOT/p).read_bytes())==want,p
    members={}
    manifest=read(ROOT/(CAP+'capture-manifest.json'))
    retained={(CAP+a['path'],x['path']):{k:x[k] for k in ('bytes','sha256')} for a in manifest['archives'] for x in a['members']}
    for archive in sorted({s['archive'] for s in inputs['members']}):
        with tarfile.open(ROOT/archive) as f:
            for s in inputs['members']:
                if s['archive']!=archive:continue
                record=f.getmember(s['member']);assert record.isfile()
                data=f.extractfile(record).read();assert ident(data)==s['identity']
                if archive.startswith(CAP):assert retained[(archive,s['member'])]==s['identity']
                members[(archive,s['member'])]=data
    for w in read(HERE/'source-witnesses.json'):
        lines=members[(w['archive'],w['member'])].decode().splitlines(keepends=True)
        assert ''.join(lines[w['first_line']-1:w['last_line']])==w['text']
    dispatcher=read(ROOT/'docs/evidence/retained-producer-driver-envelope-20261018/result.json')['selected_driver_dispatch']
    expected={'cvc5':['counterexamples_dependent_intros','inline_trivial'],
              'z3':['inline_trivial'],
              'altergo':['counterexamples_dependent_intros','monomorphise_goal','inline_trivial']}
    filenames={'cvc5':'cvc5_gnatprove.drv','z3':'z3_gnatprove.drv','altergo':'alt_ergo_gnatprove_smt2.drv'}
    for name,order in expected.items():
        assert [r['name'] for r in dispatcher[name]['transformations'][:len(order)]]==order
        for group in ('registration','inline'):
            lines=members[(CAP+'capture-common.tar.gz',group+'/overlay/'+filenames[name])].decode().splitlines()
            for r in dispatcher[name]['transformations'][:len(order)]:
                assert lines[r['line']-1].strip()=='transformation "'+r['name']+'"'
    products={};rows=[]
    for case in CASES:
        result,certificate,graph=calculate_case(case,members);rows.append(result)
        slug=case.replace('_','-')
        products[slug+'-certificate.json']=json_bytes(certificate)
        products[slug+'-graph.json.gz']=gzip.compress(json_bytes(graph),mtime=0)
    episode=read(ROOT/'docs/evidence/retained-why-path-writer-capacity-20261020/result.json')
    for a,b in zip(rows,episode['cases']):
        assert a['case']==b['case'] and a['pid']==b['pid']
        assert a['selected_goals']==b['registered_goals_upper']
        assert b['under_named_existing_premises']['dispatch_bounds']['preparation_episodes_intersecting_suffix_upper']==3*a['selected_goals']+2
    result=dict(scope='Fixed selected raw-task prefixes into inline_trivial; retained serial episode and seed attachment',drivers=expected,cases=rows,
        direct_opened_charge_scope='Fixed raw declarations and valid strict-equal representative/cache relation',
        episode_composition_scope='Retained serial R34 continuation only',
        retained_serial_seed_closure_under_named_premises=True,
        intended_parallel_seed_closure=False,intended_parallel_episode_composition_claimed=False,
        under_named_source_cache_episode_and_seed_premises=dict(
            full_five_process_prefix_Ident_upper=sum(r['under_named_episode_and_seed_premises']['full_prefix_Ident_upper'] for r in rows),
            post_five_cut_prefix_Ident_upper=sum(r['under_named_episode_and_seed_premises']['post_cut_prefix_Ident_upper'] for r in rows)),
        includes_R50_update_charge=False,includes_transform_lookup_initialization=False,
        includes_pending_callback_charge=False,source_theorem_machine_checked=False,
        complete_inline_capacity=False,complete_Ident_no_wrap=False,native_runs=0,predecessor_replays=0)
    products['result.json']=json_bytes(result)
    return products

def main():
    p=argparse.ArgumentParser();p.add_argument('--write',action='store_true');args=p.parse_args()
    start=time.monotonic()
    for name,data in calculate().items():
        if args.write:(HERE/name).write_bytes(data)
        else:assert (HERE/name).read_bytes()==data,name
    print(json.dumps(dict(status='pass',cases=5,elapsed_seconds=time.monotonic()-start,
                         native_runs=0,predecessor_replays=0),indent=2))
if __name__=='__main__':main()
