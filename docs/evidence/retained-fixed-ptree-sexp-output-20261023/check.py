"""New fixed diagnostic Sexp input/representation audit; no target execution."""
from pathlib import Path
import hashlib,json,re,struct,tarfile,time
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
START=time.perf_counter()
checks=0
def check(p,message):
    global checks
    checks+=1
    assert p,message
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
for p,e in json.loads((HERE/'inputs.json').read_text()).items():
    check(identity((ROOT/p).read_bytes())==e,p)
for p,e in json.loads((HERE/'archive-manifest.json').read_text()).items():
    check(identity((HERE/p).read_bytes())=={k:e[k] for k in ('bytes','sha256')},p)
    with tarfile.open(HERE/p) as t:
        check({m.name for m in t.getmembers() if m.isfile()}==set(e['members']),p+' members')
        for n,x in e['members'].items():check(identity(t.extractfile(n).read())==x,n)
with tarfile.open(HERE/'capture.tar.gz') as t:
    def get(n):return json.load(t.extractfile(n))
    plan=get('plan.json');old=get('origin-plan.json');runs=get('result.json')
    for p,e in plan['file_identities'].items():check(identity(Path(p).read_bytes())==e,p)
    elf=Path(plan['cases'][0]['argv'][0]).read_bytes()
    phoff=struct.unpack_from('<Q',elf,32)[0];phsize,phnum=struct.unpack_from('<HH',elf,54)
    def native(addr,n):
        for i in range(phnum):
            typ,flags,off,va,pa,filesz,memsz,align=struct.unpack_from('<IIQQQQQQ',elf,phoff+i*phsize)
            if typ==1 and va<=addr and addr+n<=va+filesz:return elf[off+addr-va:off+addr-va+n]
        raise AssertionError('unmapped native span')
    native_bytes=0
    for name,body in json.loads((HERE/'native-bodies.json').read_text()).items():
        for line in body.splitlines():
            m=re.match(r'\s*([0-9a-f]+):\s*\t((?:[0-9a-f]{2}\s+)+)',line)
            if m:
                b=bytes.fromhex(m[2]);native_bytes+=len(b)
                check(native(int(m[1],16),len(b))==b,name)
    raw={r['case']:r for r in json.loads((ROOT/'docs/evidence/retained-fixed-ptree-capture-20261023/result.json').read_text())['cases']}
    results=[]
    for c,o,run in zip(plan['cases'],old['cases'],runs):
        name=c['name'];check(name==o['name']==run['case'],'case')
        check(c['argv']==o['argv'][:-1]+['--debug-why3','gnat_ast',o['argv'][-1]],'sole option change')
        check(identity(t.extractfile(name+'/'+c['argv'][-1]).read())==o['input']==c['input'],'unchanged fixed JSON')
        check(identity(t.extractfile(name+'/why3.conf').read())==old['working_configuration_copies'][o['cwd']+'/why3.conf'],'unchanged config')
        proc=get(name+'/capture/process.json');s=get(name+'/capture/summary.json');g=get(name+'/capture/graph.json')
        check(proc['argv']==c['argv'] and proc['environment']==c['environment'],'actual process')
        check('Gnat_ast_to_ptree__save_mlw_as_sexp_7559' in proc['stack'] and 'to_string_mach_1258' in proc['stack'],'exact diagnostic caller')
        check(bytes.fromhex(proc['entry_instruction_bytes'])==native(0x86cf10,120),'entry bytes')
        check(run['returncode']==0 and not run['timeout'] and s['completed'] and not s['guard_hits'],'capture success')
        check(s['inferior_calls']==s['inferior_memory_writes']==0 and s['stopped_before_sexp_bytes'],'capture cut')
        nodes={int(k):v for k,v in g['objects'].items()};memo={};visiting=set();seen=set()
        # (atoms, Lists, atom payload bytes, max atom, max list length, depth, spine length)
        todo=[('sexp',g['root'],False)]
        while todo:
            kind,v,done=todo.pop();key=(kind,v)
            if key in memo:continue
            if kind=='list' and v==1:memo[key]=(0,0,0,0,0,0,0);continue
            check(not v&1 and v in nodes,'well-typed data pointer');n=nodes[v];seen.add(v)
            check((n['header']&255,n['header']>>10)==(n['tag'],n['words']),'header')
            if kind=='string':
                b=bytes.fromhex(n['data_hex']);check(n['tag']==252 and len(b)==n['length']<8*n['words'],'string')
                memo[key]=(0,0,len(b),len(b),0,0,0);continue
            if kind=='sexp':
                check(n['tag'] in (0,1) and n['words']==1 and len(n['fields'])==1,'Atom/List representation')
                children=[('string' if n['tag']==0 else 'list',n['fields'][0])]
            else:
                check(n['tag']==0 and n['words']==2 and len(n['fields'])==2,'proper Sexp list')
                children=[('sexp',n['fields'][0]),('list',n['fields'][1])]
            if not done:
                check(key not in visiting,'acyclic Sexp');visiting.add(key);todo.append((kind,v,True))
                todo.extend((a,b,False) for a,b in children if (a,b) not in memo)
            else:
                visiting.remove(key);cs=[memo[k] for k in children]
                a=sum(x[0] for x in cs);l=sum(x[1] for x in cs);b=sum(x[2] for x in cs)
                ma=max(x[3] for x in cs);ml=max(x[4] for x in cs);depth=max(x[5] for x in cs)
                if kind=='sexp':
                    if n['tag']==0:a+=1
                    else:l+=1;ml=max(ml,cs[0][6])
                    depth+=1;spine=0
                else:spine=cs[1][6]+1
                memo[key]=(a,l,b,ma,ml,depth,spine)
        check(seen==set(nodes),'complete graph interpretation')
        a,l,payload,ma,ml,depth,_=memo[('sexp',g['root'])]
        r=raw[name];R=r['expanded_words']+r['expanded_blocks']+r['expanded_immediates']
        # Mode-independent allowance: at most one option occurrence per raw
        # field/value. Switching modes inserts at most a four-byte Atom.
        base=4*payload+3*a+2*l
        filetag_extra=4*180*r['position_candidate_occurrences']
        B=base+19*R+filetag_extra
        capacity=1024
        while capacity<B:capacity*=2
        guard={'atom_escape':4*max(ma,4)+2<=2**57-9,'buffer':capacity<=2**57-9,
               'buffer_addition':B+4*max(ma,4)+2<=2**62-1,'buffer_double':2*capacity<=2**62-1,
               'file_offset':B<=2**63-1,'list_length':ml+1<=2**62-1}
        check(all(guard.values()),'individual representation guards')
        results.append(dict(case=name,atoms=a,lists=l,atom_payload_bytes=payload,maximum_atom_bytes=ma,
            maximum_list_length=ml,depth=depth,raw_option_occurrence_allowance=R,
            captured_mode_byte_bound=base,all_option_modes_byte_bound=base+19*R,
            FileTags_filename_bound=180,FileTags_replacement_extra_bytes=filetag_extra,
            complete_failure_byte_bound=B,buffer_backing_bound=capacity,
            guards=guard,capture_seconds=run['elapsed_seconds']))
result=dict(status='pass',cases=results,checks=checks,native_instruction_bytes=native_bytes,
    scope='fixed diagnostic Sexp capture and individual serializer representation',
    managed_run='20261023T224957-d4e38ab6623a',new_boundary_captures=5,solvers=0,
    target_capture_seconds=sum(r['elapsed_seconds'] for r in runs),predecessor_replays=0,
    source_transfer_requires_review=True,elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
