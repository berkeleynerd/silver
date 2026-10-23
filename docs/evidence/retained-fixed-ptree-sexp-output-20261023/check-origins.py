"""Supplemental source-origin, fixed filename and native-closure attachment."""
from pathlib import Path
import hashlib,json,struct,tarfile,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];start=time.perf_counter();count=0
cache={}
def member(p,n):
    key=(p,n)
    if key not in cache:
        with tarfile.open(p) as t:cache[key]=t.extractfile(n).read()
    return cache[key]
with tarfile.open(HERE/'sources.tar.gz') as t:
    for row in json.loads((HERE/'source-origins.json').read_text()):
        b=t.extractfile(row['member']).read();assert hashlib.sha256(b).hexdigest()==row['sha256'];count+=1
        assert row['providers']
        for r in row['providers']:
            assert member(ROOT/r['archive'],r['member'])==b;count+=1
filenames=[]
with tarfile.open(HERE/'capture.tar.gz') as t:
    plan=json.load(t.extractfile('plan.json'))
    for c in plan['cases']:
        stack=[json.load(t.extractfile(c['name']+'/'+c['argv'][-1]))];maximum=0
        while stack:
            x=stack.pop()
            if isinstance(x,str):maximum=max(maximum,len(x.encode()))
            elif isinstance(x,list):stack.extend(x)
            elif isinstance(x,dict):stack.extend(x.values())
        filenames.append(dict(case=c['name'],maximum_json_string_bytes=maximum));assert maximum<=189;count+=1
    elf=Path(plan['cases'][0]['argv'][0]).read_bytes()
    po=struct.unpack_from('<Q',elf,32)[0];ps,pn=struct.unpack_from('<HH',elf,54)
    for n,r in json.loads((HERE/'native-data.json').read_text()).items():
        a=r['address'];b=bytes.fromhex(r['hex'])
        for i in range(pn):
            typ,flags,off,va,pa,sz,ms,al=struct.unpack_from('<IIQQQQQQ',elf,po+i*ps)
            if typ==1 and va<=a<a+len(b)<=va+sz:
                assert elf[off+a-va:off+a-va+len(b)]==b;assert list(struct.unpack('<QQQ',b))==r['words'];count+=2;break
        else:raise AssertionError(n)
r=dict(status='pass',checks=count,json_strings=filenames,maximum_json_string_bound=189,
       scope='supplemental source-origin/filename/native-closure attachment; no graph-check replay',
       elapsed_seconds=time.perf_counter()-start)
(HERE/'origin-result.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
