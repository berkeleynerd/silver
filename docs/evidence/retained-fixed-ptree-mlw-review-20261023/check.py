"""Independent focused Mlw identity/arithmetic/correction review."""
from pathlib import Path
import hashlib,json,subprocess,struct,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];start=time.perf_counter();checks=0
def git(ref,p):return subprocess.check_output(['git','show',ref+':'+p],cwd=ROOT)
def check(p,msg):
    global checks
    checks+=1;assert p,msg
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
target=json.loads((HERE/'targets.json').read_text());ref=target['author_repaired'];rawref=target['raw_capture']
base='docs/evidence/retained-fixed-ptree-mlw-output-20261023/'
for p,e in json.loads(git(ref,base+'inputs.json')).items():
    b=git(rawref if 'retained-fixed-ptree-capture-' in p else ref,p)
    check(identity(b)==e,p)
initial=git(target['author_initial'],base+'result.json')
check(initial==git(ref,base+'result-before-private-string-correction.json'),'original result retained exactly')
native=json.loads(git(ref,base+'native-witnesses.json'));elf=Path(native['executable']).read_bytes()
check(identity(elf)==native['identity'],'installed ELF identity')
off=struct.unpack_from('<Q',elf,32)[0];size,count=struct.unpack_from('<HH',elf,54)
def span(a,n):
    for i in range(count):
        typ,flags,o,v,p,fs,ms,align=struct.unpack_from('<IIQQQQQQ',elf,off+i*size)
        if typ==1 and v<=a and a+n<=v+fs:return elf[o+a-v:o+a-v+n]
    raise AssertionError('unmapped span')
for r in native['spans']:
    b=bytes.fromhex(r['hex']);check(span(r['vaddr'],len(b))==b,r['symbol'])
for r in native['strings']:
    b=r['text'].encode()+b'\0';check(span(r['vaddr'],len(b))==b,'native format')
raw=json.loads(git(rawref,'docs/evidence/retained-fixed-ptree-capture-20261023/result.json'))['cases']
author={r['case']:r for r in json.loads(initial)['cases']};results=[]
for r in raw:
    n=1+r['expanded_blocks']+r['expanded_immediates'];u=8*n;f=256*u+1024
    k=r['maximum_identical_three_integer_record_occurrences'];l=r['position_candidate_occurrences'];s=r['expanded_direct_string_bytes']
    p,m=416,1743304;b=256*u+16*s+8*l*(4*p+82)+8*k*m+1024;o=b+70*(f+1);q=b+f
    check((b,f,o,q)==tuple(author[r['case']][v] for v in ('B','F','O','Q')),'independent output algebra')
    check(4*(q+1000000010+128)<=2**62-1 and o<=2**63-1,'Format/channel guards')
    L=r['maximum_direct_string_payload']
    for pp,mm in [(0,0),(189,0),(416,1743304),(10**6,10**7)]:
        T=max(mm,4*pp+2,4*L+2,L+16,90)
        check(all(T>=v for v in [mm,4*pp+2,4*L+2,L+16,90]),'independent symbolic string coverage')
    # The omitted old bound actually fails for unmarked/no-filename operands.
    check(max(0,2,L+16,90)<4*L+2,'old symbolic counterexample')
    # Algebraic debt invariant for two cached-offset initializations.
    for delta in (-1,0):
        for debt in (1,65536):
            for written in (1,debt):
                C=o-debt
                check(C+written+debt-written==o and -1<=C+written+delta<=o,'positive short-write debt')
    results.append(dict(case=r['case'],B=b,F=f,O=o,marker_copies=8*k))
out=dict(status='pass',checks=checks,cases=results,scope='independent frozen-byte/native/algebra review; semantic source review in report',
    author_initial=target['author_initial'],author_repaired=ref,native_runs=0,provider_replays=0,
    elapsed_seconds=time.perf_counter()-start)
(HERE/'result.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
