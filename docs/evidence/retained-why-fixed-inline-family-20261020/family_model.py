"""Weighted first-inline model over R51 exports, with no predecessor replay.

The accepted weighted algebra is imported as a library. This adapter supplies the
new finite inputs, type structures, inductive clauses and root attribution.
Choice is an envelope over metadata and old-return alternatives, not an exact
native trace. Attribute equality is not inferred from strict equality.
"""
from collections import Counter
from functools import lru_cache
import gzip, json
from project import HERE, OLD, CASES, load

Refiner=load('fixed_family_weighted', HERE.parent/'retained-why-inline-refinement-20261018/refine.py').Refiner
def freeze(x):return tuple(map(freeze,x)) if isinstance(x,list) else x
def type_size(t):return 0 if t is None else 1+(sum(type_size(c) for c in t[2]) if t[0]=='a' else 0)

class Family(Refiner):
    def __init__(self,g,types):
        super().__init__({'blocks':{}})
        self.g=g;self.types=types;self.free_keys={};self.rows=[];self.eligibility=[]
    def fields(self,p,n=None):
        assert n==5 and str(p) in self.g['symbols'];return (p,None,None,None,None)
    def ident(self,p):
        s=self.g['symbols'][str(p)]
        return dict(name=s['name'],pointer=p,attributes=s['attrs'])
    def variable(self,raw):
        self.nextvar+=1;key=self.nextvar;v=self.g['variables'][str(raw)]
        self.variables[key]=(freeze(self.types[str(v['type'])]),dict(name=v['name'],attributes=v['attrs']))
        return key
    def ty(self,p):return None if p is None else freeze(self.types[str(p)])
    def newframe(self,b):
        return tuple((v,self.variable(v)) for v in b['variables']),tuple((int(v),t) for v,t in b['saved'].items())
    @lru_cache(None)
    def stored_symbols(self,p):
        t=self.g['terms'][p];k,a=t['kind'],t['args'];out=set();children=[];binds=[]
        if k=='app':out.add(a[0]);children+=a[1]
        elif k=='bin':children+=a[1:]
        elif k in ('if','not'):children+=a
        elif k=='let':children.append(a[0]);binds.append(a[1])
        elif k=='quant':binds.append(a[1])
        elif k=='eps':binds.append(a[0])
        elif k=='case':
            children.append(a[0])
            for pat,b in a[1]:
                assert pat[0]=='app' and not pat[1][1] and not pat[2] and pat[3]==1
                out.add(pat[1][0]);binds.append(b)
        for bi in binds:
            b=self.g['bindings'][bi];children.append(b['body']);children+=list(b['saved'].values())
            children += [x for group in b['triggers'] for x in group]
        for ch in children:out.update(self.stored_symbols(ch))
        return frozenset(out)
    def open(self,p,frames=()):
        t=self.g['terms'][p];k,a=t['kind'],t['args'];ty=self.ty(t['type']);attrs=frozenset(t['attrs'])
        if k=='var':
            raw=a[0]
            for i,(bound,saved) in enumerate(frames):
                if raw in dict(bound):return self.make('var',dict(bound)[raw],ty,attrs)
                if raw in dict(saved):return self.with_attrs(self.open(dict(saved)[raw],frames[i+1:]),attrs)
            if raw not in self.free_keys:
                key=-1-len(self.free_keys);self.free_keys[raw]=key;v=self.g['variables'][str(raw)]
                self.variables[key]=(self.ty(v['type']),dict(name=v['name'],attributes=v['attrs']))
            return self.make('var',self.free_keys[raw],ty,attrs)
        if k in ('true','false'):return self.make(k,None,ty,attrs)
        if k=='const':return self.make(k,freeze(a),ty,attrs)
        if k=='app':return self.make(k,a[0],ty,attrs,[self.open(x,frames) for x in a[1]])
        if k=='bin':return self.make('binop',a[0],ty,attrs,[self.open(x,frames) for x in a[1:]])
        if k in ('if','not'):return self.make(k,None,ty,attrs,[self.open(x,frames) for x in a])
        def opened(bi):
            b=self.g['bindings'][bi];fr=self.newframe(b);vs=tuple(v for _,v in fr[0]);new=(fr,)+frames
            return b,vs,new
        if k in ('let','eps'):
            b,vs,fr=opened(a[1] if k=='let' else a[0]);children=[self.open(b['body'],fr)]
            if k=='let':children.insert(0,self.open(a[0],frames))
            return self.make(k,None,ty,attrs,children,[vs])
        if k=='quant':
            b,vs,fr=opened(a[1]);children=[self.open(b['body'],fr)]
            children += [self.open(x,fr) for group in b['triggers'] for x in group]
            return self.make(k,(a[0],tuple(map(len,b['triggers']))),ty,attrs,children,[vs])
        assert k=='case'
        children=[self.open(a[0],frames)];bindings=[];patterns=[]
        for pat,bi in a[1]:
            assert pat[0]=='app' and not pat[1][1] and not pat[2] and pat[3]==1
            b,vs,fr=opened(bi);assert not vs
            children.append(self.open(b['body'],fr));bindings.append(vs);patterns.append((1,(pat[1][0],)))
        return self.make(k,None,ty,attrs,children,bindings,patterns)
    def alpha(self,t,scope=(),depth=0):
        n=self.nodes[t];k,key,ty,attrs,ch,bnds,pat=n
        assert k!='choice'
        if k=='var':key=dict(scope).get(key,('free',key))
        local={v:('bound',depth+i) for i,v in enumerate(v for group in bnds for v in group)}
        children=[]
        for child,bound in zip(ch,self.child_scopes(n)):
            children.append(self.alpha(child,scope+tuple((v,local[v]) for v in bound),depth+len(local)))
        return k,key,ty,tuple(map(len,bnds)),pat,tuple(children)
    def stored_profile(self,roots):
        """Stored occurrence envelope; sharing is counted on every edge."""
        entries=0;values=[];keys=set();free=set();attrs=set();free_max=0;nonunary=[]
        def walk(p):
            nonlocal entries,free_max
            t=self.g['terms'][p];attrs.update(t['attrs']);k,a=t['kind'],t['args'];bs=[]
            if k=='app':ch=list(a[1])
            elif k=='bin':ch=list(a[1:])
            elif k in ('if','not'):ch=list(a)
            elif k=='let':ch=[a[0]];bs=[a[1]]
            elif k=='quant':ch=[];bs=[a[1]]
            elif k=='eps':ch=[];bs=[a[0]]
            elif k=='case':ch=[a[0]];bs=[b for _,b in a[1]]
            else:ch=[]
            for bi in bs:
                b=self.g['bindings'][bi];ch.append(b['body']);ch += [x for group in b['triggers'] for x in group]
                entries+=len(b['saved'])
                for v,p in b['saved'].items():
                    out=self.open(p);dim=self.dimensions(out);fv=self.free(out)
                    assert dim[1:3]==(0,0), dict(saved_key=v,value_root=p,dimensions=dim)
                    free_count=sum(n for _,n in fv);free_max=max(free_max,free_count)
                    if free_count>1:nonunary.append(dict(key=int(v),root=p,nodes=dim[0],free_occurrences=free_count))
                    values.append(dim[0])
                    if dim[0]>1:keys.add(int(v))
                    inverse={key:raw for raw,key in self.free_keys.items()}
                    free.update(inverse[v] for v,_ in fv)
                    ch.append(p)
            return 1+sum(walk(x) for x in ch)
        nodes=sum(walk(p) for p in roots)
        assert not keys&free,'composable nonleaf seed value'
        return dict(saved_entries=entries,value_nodes=max(values+[1]),stored_nodes=nodes,
            nonleaf_keys=sorted(keys),value_free_variables=sorted(free),attributes=sorted(attrs),
            maximum_value_free_occurrences=free_max,nonunary_values=nonunary)
    def declaration(self,d,stage):
        if stage=='ce' and d['dropped']:return
        indexes=d['candidate_root_indexes' if stage=='ce' else 'raw_root_indexes']
        expected=d['candidate_mapped_roots' if stage=='ce' else 'raw_mapped_roots']
        batch=[]
        for i,p in enumerate(indexes):
            t=self.open(p);formals=();s=None
            if d['kind']==3:
                assert len(indexes)==len(d['definition_symbols'])==1
                s=d['definition_symbols'][i];node=self.nodes[t]
                if node[0]=='quant':
                    assert node[1][0]==0;formals=node[5][0];t=node[4][0];node=self.nodes[t]
                assert node[0] in ('app','binop') and len(node[4])==2
                head,t=node[4];hn=self.nodes[head]
                assert hn[0]=='app' and hn[1]==s
                assert tuple(self.nodes[x][1] for x in hn[4])==formals
            dim=self.dimensions(t)
            assert list(dim)==[expected[i]['coordinates'][k] for k in ('n','b','p','a')]
            assert len(formals)==expected[i]['formal_arity']
            batch.append((s,formals,t,self.stored_symbols(p)))
        for s,formals,t,stored in batch:
            index=len(self.rows);before=len(self.hit_rows);self.active_stored_symbols=set(stored)
            # The definition equation includes its own head. Stored body-only
            # provenance is relevant to recursion; remove the equation head.
            if s is not None:self.active_stored_symbols.discard(s)
            out=self.replace(t,index)
            row=dict(declaration=d['declaration'],kind=d['kind'],symbol=s,arity=len(formals),
                input=list(self.dimensions(t)),output=list(self.dimensions(out)),
                hits=self.hit_rows[before:])
            assert row['output'][1]<=row['input'][1] and row['output'][2]<=row['input'][2]
            self.rows.append(row)
            if s is not None:
                rec=s in self.symbols(out) or s in self.active_stored_symbols
                # Extra used-symbol/CE exclusions only suppress an environment
                # insertion. The no-extra-eligible theorem does not need them.
                assert not rec,('visible recursion',s)
                may,must=self.eligible(self.with_attrs(out,frozenset(self.ident(s)['attributes'])))
                assert may==must,('nonuniform eligibility',self.ident(s))
                self.eligibility.append(dict(symbol=s,name=self.ident(s)['name'],eligible=may,body=list(self.dimensions(out)),formals=len(formals)))
                if may:
                    assert set(dict(self.free(out)))<=set(formals)
                    self.environment[s]=(formals,out)
                    self.environment_stored_symbols[s]=frozenset(self.active_stored_symbols)

def summarize(rows):
    hits=[h for r in rows for h in r['hits']];logic=[r for r in rows if r['kind']==3];ind=[r for r in rows if r['kind']==4]
    ins=[sum(r['input'][i] for r in rows) for i in range(4)]
    outs=[sum(r['output'][i] for r in rows) for i in range(4)]
    hit_nodes=sum(h['body_dimensions'][0] for h in hits)
    hit_free=sum(sum(c>0 for c in h['formal_occurrences']) for h in hits)
    fresh_kernel=ins[1]+sum(2*h['body_dimensions'][1] for h in hits)+hit_free
    arity=sum(r['arity'] for r in logic)
    # Use OUTPUT binder ceilings for constructor/validation openings: this
    # avoids relying on an unproved binder-nonincreasing specialization.
    lb=sum(r['output'][1] for r in logic);ib=sum(r['output'][1] for r in ind)
    fresh=fresh_kernel+6*arity+lb+outs[1]+2*ib
    mass=[sum(r['output'][:3])+(2+2*r['arity']+int(r['arity']>0) if r['kind']==3 else 0) for r in rows]
    return dict(mapped_roots=len(rows),logic_definitions=len(logic),inductive_clauses=len(ind),formal_arity_sum=arity,
        input_coordinates=ins,output_coordinates_upper=outs,
        maximum_root_mass_upper=max(sum(r['output'][:3]) for r in rows),
        maximum_reconstructed_formula_mass_upper=max(mass),sum_reconstructed_formula_mass_upper=sum(mass),
        maximum_body_bound_plus_formal_slots_upper=max(r['input'][1] for r in rows)+max([r['arity'] for r in logic]+[0]),
        maximum_hit_body_mass_upper=max([sum(h['body_dimensions'][:3]) for h in hits]+[0]),
        maximum_formal_coefficient=max([c for h in hits for c in h['formal_occurrences']]+[0]),
        kernel=dict(replace_entries=ins[0],unfold_entries=ins[3],hits=len(hits),relocate_entries=hit_nodes,
            type_map_term_entries=hit_nodes,post_type_substitution_entries=hit_nodes,fresh_Ident=fresh_kernel),
        Ident=dict(kernel=fresh_kernel,definition_formals=6*arity,termination_body=lb,task_check_match=outs[1],
            inductive_clause_and_positivity=2*ib,total=fresh),
        semantic_operations=dict(termination_entries=sum(r['output'][0] for r in logic),
            check_match_entries=outs[0],inductive_clause_and_positivity_entries=2*sum(r['output'][0] for r in ind)),
        hit_free_variables=hit_free)

def calculate(case):
    g=json.loads(gzip.decompress((OLD/f'{case}-graph.json.gz').read_bytes()))
    certificate=json.loads((OLD/f'{case}-certificate.json').read_text())
    projection=json.loads((HERE/f'{case}-types.json').read_text())
    mapping=json.loads((HERE.parent/'retained-fixed-goal-attribution-20261020/fixed-root-map.json').read_text())[case.replace('-','_')]
    labels=json.loads((HERE.parent/'retained-fixed-goal-attribution-20261020/raw-goal-labels.json').read_text())[case.replace('-','_')]
    goals={x['goal']:x for x in certificate['all_raw_goals']};bydecl={d['declaration']:d for d in g['declarations']}
    labelmap={x['goal']:x for x in labels}
    assert len(goals)==len(labels)==len(g['raw_task_declaration_sequences'])
    context=certificate['common_context_declarations']
    assert all(ds[:-1]==context for ds in g['raw_task_declaration_sequences'].values())
    for x in mapping:assert goals[x['goal']]['raw_formula']==labelmap[x['goal']]['formula'] and x['trivial']==labelmap[x['goal']]['trivial']
    assert len({x['goal'] for x in mapping})==len(mapping)
    assert all('inline:trivial' not in t['attrs'] for category in ('terms','variables','symbols') for t in (g[category].values() if isinstance(g[category],dict) else g[category]))
    stages={};details={}
    for stage in ('raw','ce'):
        m=Family(g,projection['types']);seed_checks=0
        if stage=='ce':
            for d in g['declarations']:
                if not d['seed_root_indexes']:continue
                assert len(d['candidate_root_indexes'])==1
                expected=m.alpha(m.open(d['candidate_root_indexes'][0]))
                for p in d['seed_root_indexes']:
                    assert m.alpha(m.open(p))==expected,('seed semantic mismatch',case,d['declaration'])
                    seed_checks+=1
        for d in context:m.declaration(bydecl[d],stage)
        contextrows=list(m.rows);roots=[]
        assert all(x['body'][1:3]==[0,0] for x in m.eligibility if x['eligible'])
        seedroots=[]
        for d in context:
            row=bydecl[d]
            seedroots += (row['seed_root_indexes'] if stage=='ce' else row['raw_root_indexes'])
        context_profile=m.stored_profile(seedroots)
        for root in mapping:
            goal=goals[root['goal']];ds=g['raw_task_declaration_sequences'][str(goal['task'])]
            gd=bydecl[ds[-1]];assert g['terms'][gd['raw_root_indexes'][0]]['raw']==goal['raw_formula']
            before=len(m.rows);m.declaration(gd,stage);row=m.rows[before:];assert len(row)==1
            stat=summarize(contextrows+row)
            assert stat['maximum_formal_coefficient']<=1
            gp=m.stored_profile(gd['candidate_root_indexes' if stage=='ce' else 'raw_root_indexes'])
            E=context_profile['saved_entries']+gp['saved_entries'];V=max(context_profile['value_nodes'],gp['value_nodes'])
            assert not (set(context_profile['nonleaf_keys'])|set(gp['nonleaf_keys'])) & (set(context_profile['value_free_variables'])|set(gp['value_free_variables']))
            P=stat['maximum_body_bound_plus_formal_slots_upper'];K=E+2*P;M=stat['maximum_reconstructed_formula_mass_upper'];R=M*(1+K*V)
            # This is an attached candidate envelope. Extending it to returned
            # declarations is a separate hypothesis, deliberately not asserted.
            stat['candidate_storage']=dict(seed_saved_entries_upper=E,seed_value_nodes_upper=V,
                seed_value_free_occurrences_upper=max(context_profile['maximum_value_free_occurrences'],gp['maximum_value_free_occurrences']),
                nonunary_seed_values=context_profile['nonunary_values']+gp['nonunary_values'],
                delayed_map_entries_upper=K,opening_map_entries_upper=K+P,stored_formula_occurrences_upper=R)
            T=projection['maxima']['type_nodes']
            stat['kernel']['type_instantiation_requests']=(stat['kernel']['type_map_term_entries']+stat['hit_free_variables'])*T
            stat['kernel']['type_matching_entries']=(stat['kernel']['unfold_entries']+stat['kernel']['type_map_term_entries'])*(projection['maxima']['arity']+1)*T*T
            stat['kernel']['integer_range_comparisons']=2*stat['kernel']['type_map_term_entries']
            # Every call before Hsdecl return uses an input or a constructed
            # candidate. Six openings overcharge the known constructor sites.
            n=stat['input_coordinates'][0];ln=stat['semantic_operations']['termination_entries'];indn=stat['semantic_operations']['inductive_clause_and_positivity_entries']
            starts=2*n+ln+6*stat['logic_definitions']+stat['output_coordinates_upper'][2]+indn
            stat['candidate_operations']=dict(hidden_substitution_starts_upper=starts,
                hidden_substitution_term_entries_upper=starts*R,
                free_variable_scan_entries_upper=starts*R*M*V+(n+stat['logic_definitions']+stat['mapped_roots']+stat['logic_definitions']*projection['maxima']['arity'])*R+stat['kernel']['type_map_term_entries'],
                hash_semantic_node_entries_upper=stat['mapped_roots']*M)
            roots.append(dict(**root,task=goal['task'],raw_formula=goal['raw_formula'],goal_output=row[0]['output'],**stat))
        modeled_type_max=max([type_size(n[2]) for n in m.nodes]+[type_size(t) for t,_ in m.variables.values()])
        assert modeled_type_max<=projection['maxima']['type_nodes']
        constant_cases=set()
        for _,body in m.environment.values():
            def constants(t):
                node=m.nodes[t]
                if node[0]=='const':
                    ty=node[2];assert ty[0]=='a' and not ty[2]
                    ts=projection['type_symbols'][str(ty[1])]
                    if ts['definition_tag'] is None:
                        assert projection['identifiers'][str(ts['identifier'])]['tag']==1
                        constant_cases.add(('builtin_int',node[1][1]))
                    else:
                        assert ts['definition_tag']==1
                        lo,hi=ts['range'];value=node[1][1];assert lo<=value<=hi
                        constant_cases.add(('range_int',value,lo,hi))
                for child in node[4]:constants(child)
            constants(body)
        stages[stage]=dict(eligible_definitions=sum(x['eligible'] for x in m.eligibility),seed_opened_shape_checks=seed_checks,
            maximum_modeled_type_nodes=modeled_type_max,environment_constant_cases=sorted(constant_cases),
            range_comparison_operand_bits=max([abs(n).bit_length() for row in constant_cases if row[0]=='range_int' for n in row[1:]]+[0]),
            context=summarize(contextrows),roots=roots)
        details[stage]=dict(eligibility=m.eligibility,context_rows=contextrows,goal_rows=m.rows[len(contextrows):])
    metadata=json.loads((HERE.parent/'retained-why-parallel-symbol-exclusion-20261020'/f'{case}-metadata.json').read_text())
    excluded=metadata['selected_symbols']['inline:no']
    assert all(str(x['old_pointer']) in g['symbols'] for x in excluded)
    return dict(case=case,raw_goals=len(goals),registered_roots=len(mapping),nontrivial_registered_roots=sum(not r['trivial'] for r in mapping),
        fixed_driver_routes=dict(cvc5='ce',altergo='ce + monomorphise_goal identity',z3='raw'),
        actual_z3_inline_no=[dict(symbol=x['old_pointer'],name=x['name']) for x in excluded],
        covers_every_inline_no_and_additional_exclusion=True,stages=stages),details

if __name__=='__main__':
    for case in CASES:
        result,details=calculate(case)
        (HERE/f'{case}-family.json').write_text(json.dumps(result,sort_keys=True,indent=2)+'\n')
        (HERE/f'{case}-details.json.gz').write_bytes(gzip.compress((json.dumps(details,sort_keys=True)+'\n').encode(),mtime=0))
        print(case,[(s,len(v['roots']),v['eligible_definitions'],max(x['Ident']['total'] for x in v['roots'])) for s,v in result['stages'].items()],flush=True)
