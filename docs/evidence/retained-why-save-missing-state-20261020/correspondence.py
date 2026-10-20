#!/usr/bin/env python3
"""Join a fresh forest/task projection to an accepted count by raw isomorphism.
No observer replay, term opening, binder calculation or alpha computation.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import time
import custom_ops

HERE=Path(__file__).resolve().parent
E=HERE.parent
DOMAIN=E/'retained-why-fixed-session-domain-20261020'
STATE=E/'retained-why-session-save-state-20261019'


def identity(p):
    h=hashlib.sha256();n=0
    with p.open('rb') as f:
        for raw in iter(lambda:f.read(1<<20),b''):h.update(raw);n+=len(raw)
    return {'bytes':n,'sha256':h.hexdigest()}


def get(p):return json.loads(p.read_text())


def load_blocks(path):
    blocks={};payload=0
    with path.open() as f:
        for line in f:
            r=json.loads(line);p=r['address'];raw=bytes.fromhex(r['payload_hex'])
            assert p not in blocks and len(raw)==8*r['words']
            assert int.from_bytes(bytes.fromhex(r['header_hex']),'little')==r['header']
            assert (r['tag'],r['words'])==(r['header']&255,r['header']>>10)
            assert len(blocks)<1000000
            payload+=len(raw)+8;assert payload<=128*1024*1024
            blocks[p]=(r['tag'],r['words'],raw)
    return blocks


def fields(blocks,p,n=None,tag=0):
    t,k,raw=blocks[p];assert t==tag and (n is None or n==k),(p,t,k,tag,n)
    return struct.unpack('<'+'Q'*k,raw)


def declarations(blocks,chain):
    out=[];following=chain[0]['option'] if chain else 1
    kinds=[]
    for r in chain:
        assert r['option']==following
        head,=fields(blocks,following,1);assert head==r['head']
        hd=fields(blocks,head,6);assert hd[0]==r['tdecl'];following=hd[1]
        node,_=fields(blocks,r['tdecl'],2);kind=blocks[node][0]
        assert kind in (0,1,2,3);kinds.append(kind)
        if kind==0:
            declaration,=fields(blocks,node,1);out.append(declaration)
    assert following==1
    return kinds,out


def compare_graphs(old,new,root_pairs,recognized_custom=None,custom_matches=None):
    """Bijection of ordered ordinary graphs; all scalar/data bytes exact. Recognized custom operations pointers have an explicit relocation witness.

    No heap-pointer equality across processes is assumed. Runtime blocks are
    rejected. Only an explicitly recognized custom operations word may relocate; all other opaque payload bytes remain exact.
    """
    forward={};reverse={};todo=list(reversed(root_pairs))
    while todo:
        a,b=todo.pop()
        if a&1 or b&1:
            assert a==b,('immediate mismatch',a,b);continue
        if a in forward:
            assert forward[a]==b,('sharing mismatch',a,b);continue
        assert b not in reverse,('sharing collapsed',a,b)
        forward[a]=b;reverse[b]=a
        at,an,ar=old[a];bt,bn,br=new[b]
        assert (at,an)==(bt,bn),('block layout mismatch',a,b,at,bt,an,bn)
        assert at<246 or at>=251,('runtime block in logical graph',a,at)
        if at==255:
            custom_ops.compare(ar,br,recognized_custom)
            if custom_matches is not None:custom_matches.append({'old':a,'new':b,'words':an,'symbol':recognized_custom['symbol']})
        elif at>=251:
            assert ar==br,('opaque payload mismatch',a,b,at)
        else:
            af=struct.unpack('<'+'Q'*an,ar);bf=struct.unpack('<'+'Q'*bn,br)
            todo.extend(reversed(list(zip(af,bf))))
    return forward


def forest_events(path):
    maps={};events=[]
    def ref(kind,value):
        domain=maps.setdefault(kind,{})
        if value not in domain:domain[value]=len(domain)
        return domain[value]
    with path.open() as f:
        for line in f:
            kind,value=json.loads(line)
            if kind=='leave':
                k,v=value;events.append([kind,k,ref(k,v)])
            elif kind=='visit':
                # Task pointers join separately through each chain below.
                events.append([kind,ref('goal',value['goal']),bool(value['root'])])
            else:
                assert kind in ('file','theory','goal','transformation')
                events.append([kind,ref(kind,value)])
    return events


def accepted_inputs(case):
    summary=get(DOMAIN/'summary.json');accepted,=[c for c in summary['cases'] if c['case']==case]
    if case=='input_is_valid':
        manifest=get(STATE/'capture-identities.json')['members']
        analysis=STATE/'result.json';cert_path=STATE/'binder-certificate.json';cert=get(cert_path)
    else:
        item,=[a for a in get(DOMAIN/'capture-manifest.json')['archives'] if a['path']=='capture-'+case.replace('_','-')+'.tar.gz']
        manifest={m['path']:{'bytes':m['bytes'],'sha256':m['sha256']} for m in item['members']}
        analysis=cert_path=DOMAIN/(case.replace('_','-')+'-analysis.json');cert=get(cert_path)['full_certificate']
    assert identity(analysis)==accepted['analysis_identity']
    return accepted,manifest,cert_path,cert


def normalize(value,root):
    if isinstance(value,str):return value.replace(str(root),'<capture-root>')
    if isinstance(value,list):return [normalize(v,root) for v in value]
    if isinstance(value,dict):return {normalize(k,root):normalize(v,root) for k,v in value.items()}
    return value


def compare(old,new,case):
    start=time.perf_counter();accepted,manifest,cert_path,cert=accepted_inputs(case)
    consumed={}
    names=['process.json','session-root.json','session-blocks.jsonl','session-task-chains.json',
           'session-forest.json','session-forest-events.jsonl']
    for name in names:
        actual=identity(old/name);assert actual==manifest[case+'/capture/'+name],('accepted old input changed',name)
        consumed[name]=actual
    symbol_file='session-observer.json' if case=='input_is_valid' else 'session-symbols.json'
    assert identity(old/symbol_file)==manifest[case+'/capture/'+symbol_file]
    consumed[symbol_file]=identity(old/symbol_file)
    op,np=get(old/'process.json'),get(new/'process.json')
    assert op['pid']==accepted['pid'] and op['pid']!=np['pid']
    oldroot,newroot=old.parent.parent,new.parent.parent
    oldplan,newplan=get(oldroot/'plan.json'),get(newroot/'plan.json')
    oldcase,=[c for c in oldplan['inputs'] if c.get('name',case)==case]
    newcase,=[c for c in newplan['inputs'] if c.get('name',case)==case]
    assert op['argv']==oldcase['argv'] and op['environment']==oldcase['environment']
    assert np['argv']==newcase['argv'] and np['environment']==newcase['environment']
    assert normalize(op['argv'],oldroot)==normalize(np['argv'],newroot)
    assert normalize(op['environment'],oldroot)==normalize(np['environment'],newroot)
    assert identity(old.parent/oldcase['argv'][-1])==identity(new.parent/newcase['argv'][-1])==oldcase['input']
    config=lambda c:Path(c['argv'][c['argv'].index('--why3-conf')+1])
    assert identity(config(oldcase))==identity(config(newcase))
    ns,nr=get(new/'summary.json'),get(new/'result.json')
    assert ns['completed'] and not ns['failures'] and not ns['guard_hits']
    assert nr['completed'] and nr['returncode']==0 and not nr['timed_out']
    assert get(new/'save-missing-state.json')['complete']
    assert forest_events(old/'session-forest-events.jsonl')==forest_events(new/'session-forest-events.jsonl')
    ob,nb=load_blocks(old/'session-blocks.jsonl'),load_blocks(new/'session-blocks.jsonl')
    oc,nc=get(old/'session-task-chains.json'),get(new/'session-task-chains.json')
    ov,nv=get(old/'session-forest.json')['visits'],get(new/'session-forest.json')['visits']
    assert len(ov)==len(nv)==len(cert['visits'])
    root_pairs=[];tasks={};back={};visits=[]
    for index,(a,b) in enumerate(zip(ov,nv)):
        assert (a['detached'],a['root'])==(b['detached'],b['root'])
        if a['detached']:
            visits.append({'index':index,'detached':True,'accepted_charge':0});continue
        ap,bp=str(a['task']),str(b['task'])
        assert tasks.setdefault(ap,bp)==bp and back.setdefault(bp,ap)==ap, 'task sharing mismatch'
        ak,ad=declarations(ob,oc[ap]);bk,bd=declarations(nb,nc[bp])
        assert ak==bk and ad==cert['tasks'][ap]['logical_declarations']
        root_pairs.extend(zip(ad,bd))
        visits.append({'index':index,'old_task':int(ap),'new_task':int(bp),
                       'accepted_charge':cert['visits'][index]['charge']})
    recognized=custom_ops.context(old,new,oldplan,newplan);custom_matches=[]
    join=compare_graphs(ob,nb,root_pairs,recognized,custom_matches)
    assert sum(v['accepted_charge'] for v in visits)==cert['B_binders']==accepted['B_binders']
    formulas=[]
    for p,counts in cert['formulas'].items():
        # Extra nonforest tasks are outside this forest transfer. Their counts
        # are retained by the old certificate but cannot be relabeled blindly.
        if int(p) in join:formulas.append({'old':int(p),'new':join[int(p)],'accepted_counts':counts})
    return {'case':case,'old_pid':op['pid'],'new_pid':np['pid'],
        'old_phase':accepted['endpoint'] if 'endpoint' in accepted else ('first-inline entry' if case=='input_is_valid' else 'pre-scheduling registration'),
        'new_phase':get(new/'save-missing-state.json')['phase'],
        'scope':'Same stopped logical forest/task declaration graphs modulo a checked pointer bijection; only accepted conditional occurrence charges transfer. Mutable backing is fresh-process evidence.',
        'old_inputs':consumed,'new_inputs':{n:identity(new/n) for n in names+['save-missing-state.json','summary.json','result.json']},
        'accepted_certificate':{'path':str(cert_path.relative_to(E.parent.parent)), 'identity':identity(cert_path)},
        'recognized_custom_operations':recognized,'custom_block_pairs':custom_matches,
        'logical_graph_pointer_pairs':len(join),'task_pointer_pairs':tasks,'formula_pointer_pairs':formulas,
        'visits':visits,'B_binders':cert['B_binders'],'G':len(visits),'matched':True,
        'binder_recomputations':0,'alpha_replays':0,'observer_replays':0,'native_runs':0,
        'phase_equality_beyond_named_endpoints':False,'mutable_state_transferred_between_processes':False,
        'elapsed_seconds':time.perf_counter()-start}


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--old',type=Path,required=True);p.add_argument('--new',type=Path,required=True)
    p.add_argument('--case',choices=['put_line','put','first_or_default','is_message','input_is_valid'],required=True)
    p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    result=compare(a.old,a.new,a.case);a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['case','matched','B_binders','logical_graph_pointer_pairs','elapsed_seconds']}))
