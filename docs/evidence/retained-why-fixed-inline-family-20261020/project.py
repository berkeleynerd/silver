"""New targeted type/declaration projection from accepted retained bytes.

This imports the R51 byte reader, not its CE calculation/checker. No native run.
"""
from pathlib import Path
import gzip, hashlib, importlib.util, json, sys, tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
OLD = HERE.parent / 'retained-why-preinline-prefix-20261020'
CASES = ['put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid']

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module

Raw = load('fixed_family_raw', OLD / 'model.py').Raw

def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())

def project(case):
    graph = json.loads(gzip.decompress((OLD / f'{case}-graph.json.gz').read_bytes()))
    archive = REPO / f'docs/evidence/retained-why-save-state-capture-20261020/capture-{case}.tar.gz'
    prefix = ('inline/' if case == 'input-is-valid' else 'registration/') + case.replace('-', '_') + '/capture/'
    with tarfile.open(archive) as arc:
        payload = arc.extractfile(prefix + 'session-blocks.jsonl').read()
        table_bytes=arc.extractfile(prefix+'hsdecl-table.json').read()
        graph_member=prefix+('inline-entry-graph.json' if case=='input-is-valid' else 'representative-graph.json')
        table_graph_bytes=arc.extractfile(graph_member).read()
    raw = Raw(payload)
    types, identifiers, signatures, data, declarations, type_symbols = {}, {}, {}, {}, {}, {}
    def ident(p):
        name, attrs = raw.ident(p)
        identifiers[str(p)] = dict(name=name, attrs=sorted(attrs), tag=raw.fields(p,4)[3]>>1)
        return p
    def ty(p):
        if str(p) in types: return types[str(p)]
        n, _ = raw.fields(p,2)
        if raw.blocks[n]['tag'] == 0:
            v, = raw.fields(n,1); ident(raw.fields(v,1)[0]); result = ['v',v]
        else:
            s, children = raw.fields(n,2,1)
            name, params, definition = raw.fields(s,3); ident(name)
            type_symbols[str(s)]=dict(identifier=name,definition_tag=None if definition==1 else raw.blocks[definition]['tag'])
            if definition!=1 and raw.blocks[definition]['tag']==1:
                bounds,=raw.fields(definition,1,1)
                lo,hi=raw.fields(bounds,2)
                type_symbols[str(s)]['range']=[raw.integer(lo),raw.integer(hi)]
            assert definition == 1 or raw.blocks[definition]['tag'] in (1,2), 'unnormalized alias'
            children = raw.seq(children)
            assert len(children) == len(raw.seq(params))
            result = ['a',s,[ty(c) for c in children]]
        types[str(p)] = result
        return result
    def symbol(p):
        if str(p) in signatures: return
        name,args,result,constr,proj = raw.fields(p,5); ident(name)
        signatures[str(p)] = dict(identifier=name, args=[ty(t) for t in raw.seq(args)],
            result=None if result==1 else ty(raw.fields(result,1)[0]), constructor=constr>>1, projection=proj>>1)
    for t in graph['terms']:
        if t['type'] is not None: ty(t['type'])
    for v in graph['variables'].values(): ty(v['type'])
    for p in graph['symbols']: symbol(int(p))
    for d in graph['declarations']:
        node,news,_ = raw.fields(d['declaration'],3)
        kind = raw.blocks[node]['tag']; assert kind==d['kind']
        value, = raw.fields(node,1,kind)
        keys = [ident(p) for p,_ in raw.mapping(news)]
        row = dict(kind=kind, news=keys)
        if kind==0:
            name,args,definition=raw.fields(value,3);ident(name)
            if definition!=1 and raw.blocks[definition]['tag']==0:ty(raw.fields(definition,1)[0])
        elif kind==1:
            for item in raw.seq(value):
                ts,constructors=raw.fields(item,2)
                name,params,definition=raw.fields(ts,3);ident(name)
                assert raw.seq(params)==() and definition==1
                cs=[]
                for item in raw.seq(constructors):
                    s,projections=raw.fields(item,2);symbol(s)
                    for p in raw.seq(projections):
                        if p!=1:symbol(raw.fields(p,1)[0])
                    args=signatures[str(s)]['args'];assert all(t[0]=='a' and not t[2] for t in args)
                    cs.append([t[1] for t in args])
                data[str(ts)]=cs
        elif kind==3:
            row['heads']=d['definition_symbols']
        elif kind==4:
            sign,entries=raw.fields(value,2);heads=[];clauses=[]
            for item in raw.seq(entries):
                s,cls=raw.fields(item,2);symbol(s);heads.append(s)
                for pair in raw.seq(cls):
                    pr,f=raw.fields(pair,2);ident(raw.fields(pr,1)[0]);clauses.append(pr)
            row.update(sign=sign>>1,heads=heads,clauses=clauses)
        declarations[str(d['declaration'])]=row
    # New complete necessary-key projection for Dlogic/Dind. R51 projected
    # Paxiom keys only. Reuse accepted table/graph bytes without replaying its
    # layout/capture validation. No output formula comparison is approximated.
    table=json.loads(table_bytes);blocks=json.loads(table_graph_bytes)['blocks']
    def fields(p,size=None):
        b=blocks[str(p)];assert b['tag']==0
        fs=b['fields'];assert size is None or len(fs)==size;return fs
    def seq(p):
        out=[]
        while p!=1:v,p=fields(p,2);out.append(v)
        return out
    def key(p):
        dn,_,_=fields(p,3);b=blocks[str(dn)];kind=b['tag']
        if kind not in (3,4):return None
        value,=b['fields']
        if kind==3:return (3,tuple(fields(x,2)[0] for x in seq(value)))
        sign,entries=fields(value,2)
        return (4,sign,tuple((fields(x,2)[0],tuple(fields(y,2)[0] for y in seq(fields(x,2)[1]))) for x in seq(entries)))
    wanted={key(d['declaration']):d['declaration'] for d in graph['declarations'] if d['kind'] in (3,4)}
    assert len(wanted)==sum(d['kind'] in (3,4) for d in graph['declarations'])
    matches={d:[] for d in wanted.values()}
    for p in table['retained_unique_declarations']:
        k=key(p)
        if k in wanted:matches[wanted[k]].append(p)
    assert all(ps==[d] for d,ps in matches.items()),'additional initial logic/ind representation requires analysis'
    def size(t):return 1+(sum(size(c) for c in t[2]) if t[0]=='a' else 0)
    def variables(t):return {t[1]} if t[0]=='v' else set().union(*(variables(c) for c in t[2]))
    def founded(ts,path=()):
        assert ts not in path
        if str(ts) not in data:return 1,0
        cs=data[str(ts)];n,c=1,len(cs)
        for args in cs:
            for child in args:
                a,b=founded(child,path+(ts,));n+=a;c+=b
        return n,c
    counts=[founded(int(ts)) for ts in data]
    return dict(case=case, input=dict(archive=str(archive.relative_to(REPO)),member=prefix+'session-blocks.jsonl',identity=identity(payload)),
        types=types,type_symbols=type_symbols,signatures=signatures,identifiers=identifiers,declarations=declarations,data=data,
        initial_logic_ind_projection=dict(table_identity=identity(table_bytes),graph_member=graph_member,graph_identity=identity(table_graph_bytes),
            all_initial_objects=len(table['retained_unique_declarations']),same_key_objects={str(d):ps for d,ps in matches.items()},raw_objects_only=True),
        maxima=dict(type_nodes=max(map(size,types.values())),arity=max(len(s['args']) for s in signatures.values()),
            signature_type_variables=max(len(set().union(*(variables(t) for t in s['args']+([] if s['result'] is None else [s['result']])))) for s in signatures.values())),
        ground_data=dict(declarations=len(data),constructor_arguments=sum(len(a) for cs in data.values() for a in cs),
            founded_type_entries=sum(x[0] for x in counts),founded_constructor_entries=sum(x[1] for x in counts)))

if __name__=='__main__':
    for case in CASES:
        result=project(case)
        (HERE/f'{case}-types.json').write_text(json.dumps(result,sort_keys=True,indent=2)+'\n')
        print(case,result['maxima'],flush=True)
