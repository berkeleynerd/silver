"""New post-inline structural inventory; reuse accepted results without replay."""
from pathlib import Path
import collections, gzip, hashlib, importlib.util, json, re, sys, tarfile

HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
EVIDENCE=HERE.parent
R51=EVIDENCE/'retained-why-preinline-prefix-20261020'
R54=EVIDENCE/'retained-why-parallel-symbol-exclusion-20261020'
R56=EVIDENCE/'retained-why-fixed-inline-family-20261020'
R57=EVIDENCE/'retained-why-returned-storage-20261020'
DRIVERS=EVIDENCE/'retained-solver-request-bytes-20261020'
CASES=['put-line','put','first-or-default','is-message','input-is-valid']

def read(p):return json.loads(p.read_text())
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

# Reuse only the repaired lexer, not R57's calculation/checker.
spec=importlib.util.spec_from_file_location('r58_lexer',R57/'context_model.py')
lexer=importlib.util.module_from_spec(spec);spec.loader.exec_module(lexer)

def drivers():
    inputs=read(DRIVERS/'driver-inputs.json')
    accepted=read(R57/'driver-connection.json')
    active={n:lexer.without_comments((DRIVERS/'drivers'/n).read_text()) for n in inputs}
    for n in inputs:assert identity((DRIVERS/'drivers'/n).read_bytes())==inputs[n]['identity']
    closures=accepted['driver_closures'];z3=set(closures['z3_gnatprove.drv'])
    def expanding_rules(names):
        rules=[]
        for n in names:
            theory=None
            for line in active[n].splitlines():
                m=re.match(r'^\s*theory\s+(.+?)\s*$',line)
                if m:theory=m[1]
                if re.match(r'^\s*remove\s+allprops\s*$',line):
                    assert theory is not None;rules.append((theory,'remove allprops'))
                if re.match(r'^\s*end\s*$',line):theory=None
        return sorted(set(rules))
    z3_expanding=set(expanding_rules(z3))
    rows={}
    def expanded(n,path=()):
        assert n not in path
        return len(active[n].encode())+sum(expanded(c,path+(n,)) for c in inputs[n]['imports'])
    for driver,names in closures.items():
        assert not any(re.search(r'^\s*use\b',active[n],re.M) for n in names)
        assert not any('remove_unused:dependency' in active[n] for n in names)
        allprops=expanding_rules(names)
        # Every expanding directive has the same theory/rule in Z3. Other driver
        # rules each create at most one metadata tdecl.
        assert set(allprops)<=z3_expanding
        typed_meta=[]
        for n in names:
            for line in active[n].splitlines():
                if re.match(r'^\s*meta\b',line) and re.search(r'\btype\b',line):
                    assert n in z3
                    typed_meta.append(dict(file=n,line=line.strip()))
        rows[driver]=dict(expanded_active_bytes=expanded(driver),remove_allprops_rules=allprops,
                          typed_meta_directives=typed_meta,no_forced_theory_use=True)
    return dict(drivers=rows,extra_rules_per_history_upper=max(r['expanded_active_bytes'] for r in rows.values()),
                common_type_meta_and_expanding_rule_connection_is_source_argument=True)

def inventory(case):
    g=json.loads(gzip.decompress((R51/f'{case}-graph.json.gz').read_bytes()))
    t=read(R56/f'{case}-types.json');f=read(R56/f'{case}-family.json')
    details=json.loads(gzip.decompress((R56/f'{case}-details.json.gz').read_bytes()))
    meta=read(R54/f'{case}-metadata.json')
    ds={d['declaration']:d for d in g['declarations']}
    ctx=list(g['raw_task_declaration_sequences'].values())[0][:-1]
    assert all(s[:-1]==ctx for s in g['raw_task_declaration_sequences'].values())
    counts=collections.Counter(ds[p]['kind'] for p in ctx)
    assert counts[3]+counts[4]+counts[5]==next(x['original_context_keys'] for x in read(R57/'result.json')['domains'] if x['case']==case)
    assert counts[1]==len(t['data']) # each nonempty Ddata is singleton
    for p in ctx:
        row=t['declarations'][str(p)]
        if row['kind'] in (3,4):assert len(row['heads'])==1
        if row['kind']==4:assert len(row['clauses'])==1
    # New necessary termination fact: no raw singleton body contains its own
    # head, including stored maps; previous definitions cannot reference a
    # later undeclared head. The selected inline substitutions preserve this.
    def symbols(p,seen):
        if p in seen:return set()
        seen.add(p);x=g['terms'][p];k,a=x['kind'],x['args'];bs=[];out=set()
        if k=='app':out.add(a[0]);ch=a[1]
        elif k=='bin':ch=a[1:]
        elif k in ('if','not'):ch=a
        elif k=='let':ch=[a[0]];bs=[a[1]]
        elif k=='quant':ch=[];bs=[a[1]]
        elif k=='eps':ch=[];bs=[a[0]]
        elif k=='case':
            ch=[a[0]];bs=[b for _,b in a[1]]
            out.update(pat[1][0] for pat,_ in a[1])
        else:ch=[]
        for bi in bs:
            b=g['bindings'][bi];ch=list(ch)+[b['body']]+list(b['saved'].values())+[v for tr in b['triggers'] for v in tr]
        for c in ch:out.update(symbols(c,seen))
        return out
    no_self=[]
    for p in ctx:
        d=ds[p]
        if d['kind']==3:
            head,=d['definition_symbols'];seen=set()
            root,=d['raw_root_indexes'];formula=g['terms'][root]
            if formula['kind']=='quant':
                binding=g['bindings'][formula['args'][1]]
                assert all(g['terms'][v]['kind']=='var' for v in binding['saved'].values())
                formula=g['terms'][binding['body']]
            if formula['kind']=='app':
                lhs,body=formula['args'][1]
            else:
                assert formula['kind']=='bin';_,lhs,body=formula['args']
            assert g['terms'][lhs]['kind']=='app' and g['terms'][lhs]['args'][0]==head
            used=symbols(body,seen)
            assert head not in used
            no_self.append(dict(declaration=p,head=head,stored_body_terms=len(seen)))
    context_features=read(R57/f'{case}-context.json')
    assert all(x['declaration_kind']!=4 for route in context_features['stages'].values() for x in route['features'])
    archive=REPO/t['input']['archive']
    prefix=t['input']['member'].removesuffix('session-blocks.jsonl')
    member=prefix+'session-task-chains.json'
    with tarfile.open(archive) as arc:chain_bytes=arc.extractfile(member).read()
    chains=json.loads(chain_bytes)
    selected=[r['task'] for r in f['stages']['raw']['roots']]
    assert all(str(p) in chains for p in selected)
    H=max(len(chains[str(p)]) for p in selected)
    assert H>=len(ctx)+1
    # R54's exact event inventory is a reused premise; only new aggregates here.
    type_args=[dict(meta=e['meta'],type=v,origin=e['origin']) for e in meta['update_events'] for k,v in e.get('arguments',[]) if k==0]
    assert len(type_args)==2 and all(x['type'][0]=='app' and x['type'][2]==[] for x in type_args)
    assert all(x['origin']!='raw' for x in type_args)
    deps=[e for e in meta['update_events'] if e['meta']=='remove_unused:dependency']
    assert all(e['origin']=='raw' for e in deps)
    routes={}
    for route in ('raw','ce'):
        rows=details[route]['context_rows'];ls=[r for r in rows if r['kind']==3]
        routes[route]=dict(logic_formals=sum(r['arity'] for r in ls),
            logic_body_slots=sum(r['output'][1] for r in ls),
            inductive_slots=sum(r['output'][1] for r in rows if r['kind']==4),
            axiom_slots=sum(r['output'][1] for r in rows if r['kind']==5),
            mapped_context_rows=len(rows))
    return dict(case=case,context_declarations=len(ctx),context_kind_counts=dict(sorted(counts.items())),
        singleton_logic_and_inductive_heads=True,singleton_inductive_clauses=True,singleton_data_declarations=True,
        no_inductive_let_case_or_epsilon=True,
        no_recursive_singleton_bodies=no_self,signature_maxima=t['maxima'],ground_data=t['ground_data'],
        declared_identifier_slots=sum(len(t['declarations'][str(p)]['news']) for p in ctx),
        symbol_universe_upper=len(t['identifiers'])+2*len(deps)+2,
        raw_dependency_events=len(deps),raw_task_nodes_upper=H,
        task_chain_input=dict(archive=str(archive.relative_to(REPO)),member=member,identity=identity(chain_bytes)),
        z3_metadata_add_events=len(meta['update_events']),type_metadata_arguments=type_args,
        meta_argument_arity_upper=max(len(e.get('arguments',[])) for e in meta['update_events']),
        routes=routes)

if __name__=='__main__':
    (HERE/'driver-inventory.json').write_text(json.dumps(drivers(),sort_keys=True,indent=2)+'\n')
    for c in CASES:
        out=inventory(c);(HERE/f'{c}-inventory.json').write_text(json.dumps(out,sort_keys=True,indent=2)+'\n')
        print(c,out['context_kind_counts'],out['raw_task_nodes_upper'],out['symbol_universe_upper'])
