from pathlib import Path
import json,hashlib,tarfile,copy
HERE=Path('docs/evidence/retained-why-parallel-residual-transfer-20261020').resolve();CODE=HERE/'collector';ROOT=Path('/tmp/silver-r53-20261020-a2');ROOT.mkdir(exist_ok=False)
ORIG='/home/canto/src/github.com/berkeleynerd/silver/tmp/wse-20261020'
def ident(p):
 b=Path(p).read_bytes();return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
with tarfile.open(HERE.parents[2]/'docs/evidence/retained-why-save-state-capture-20261020/capture-common.tar.gz') as t:
 plan=json.load(t.extractfile('registration/plan.json'));resolution=json.load(t.extractfile('registration/driver-resolution.json'))
 (ROOT/'overlay').mkdir()
 for member in t.getnames():
  if member.startswith('registration/overlay/'):
   (ROOT/'overlay'/Path(member).name).write_bytes(t.extractfile(member).read())
# Keep only the hypothesis-distinguishing first domain. Later domains get a new plan.
case=copy.deepcopy(next(x for x in plan['inputs'] if x['name']=='first_or_default'))
def move(x):
 if isinstance(x,str):return x.replace(ORIG,str(ROOT))
 if isinstance(x,list):return [move(v) for v in x]
 if isinstance(x,dict):return {move(k):move(v) for k,v in x.items()}
 return x
case=move(case);case['argv'][1:1]=['-j','12'];case['server']['argv'][-1]='12'
cwd=Path(case['cwd']);cwd.mkdir();(cwd/'temp').mkdir()
with tarfile.open(HERE.parents[2]/'docs/evidence/retained-why-save-state-capture-20261020/capture-first-or-default.tar.gz') as t:
 (cwd/case['argv'][-1]).write_bytes(t.extractfile('registration/first_or_default/'+case['argv'][-1]).read())
(cwd/'why3.conf').write_bytes(Path(ORIG+'/first_or_default/why3.conf').read_bytes())
plan['inputs']=[case];plan['scope']='R53 missing metadata, First_Or_Default registration only, actual client/server J12, zero solvers, no full Hsdecl'
# Preserve every installed input and check original helper identities separately.
plan['inherited_file_identities']=plan['file_identities']
plan['file_identities']={p:m for p,m in plan['file_identities'].items() if not p.startswith(ORIG+'/')}
for p in [*(ROOT/'overlay').iterdir(),cwd/case['argv'][-1],cwd/'why3.conf']:
 plan['file_identities'][str(p)]=ident(p)
plan['required_overlay_paths']=move(plan['required_overlay_paths']);plan['selected_driver_closure']=move(plan['selected_driver_closure'])
plan['arithmetic_sites']={}
plan['collector_root']=str(CODE);plan['intentional_argv_delta_from_retained_serial']=['client -j 12','server -j 12','isolated writable paths'];plan['full_Hsdecl_capture']=False
resolution=move(resolution)
(ROOT/'driver-resolution.json').write_text(json.dumps(resolution,indent=2)+'\n')
# Remove arithmetic trace observers and former full-table capture; retain all
# read-only guard, phase, file-open and scheduling/printing/request observers.
s=(CODE/'inherited-probe.py').read_text().replace("ROOT=Path('"+ORIG+"')","ROOT=Path(CAPTURE_ROOT)\nCODE=Path(COLLECTOR_ROOT)")
a=s.index('# Three complete arithmetic-site observers');b=s.index('# Observe the real open64 result');s=s[:a]+s[b:]
s=s.replace(" for label,handle in ARITHMETIC_FILES.items():\n  handle.flush();handle.close()\n  SUMMARY['arithmetic'][label]['trace']=identity(OUT/(label+'.operands'))\n",'')
s=s.replace("   SUMMARY['arithmetic_at_previous_endpoint']={k:v['hits'] for k,v in SUMMARY['arithmetic'].items()}\n",'')
s=s[:s.index('def raw_graph(roots):')]
s+='''# R53 endpoint projection: missing metadata and raw logical correspondence only.
import importlib.util
_spec=importlib.util.spec_from_file_location('r53_session',CODE/'inherited-session_observer.py')
_session_module=importlib.util.module_from_spec(_spec);_spec.loader.exec_module(_session_module)
_meta_spec=importlib.util.spec_from_file_location('r53_metadata',CODE/'metadata.py')
_meta_module=importlib.util.module_from_spec(_meta_spec);_meta_spec.loader.exec_module(_meta_module)
def capture_fixed_session():
    global data
    original_read=data
    log=(OUT/'metadata-memory-reads.jsonl').open('w')
    def logged_read(addr,n=8):
        b=original_read(addr,n)
        log.write(json.dumps(dict(address=addr,bytes=n,hex=b.hex()),separators=(',',':'))+'\\n')
        return b
    data=logged_read
    checks={}
    for name,spec in PLAN['session_observer']['symbols'].items():
        ptr=address(name);checks[name]={'address':ptr,'elf_value':spec['elf_value']}
        if 'code_hex' in spec:
            got=data(ptr,len(bytes.fromhex(spec['code_hex']))).hex()
            assert got==spec['code_hex'],('session root code mismatch',name)
            checks[name]['code_hex']=got
    bias=address('camlWhy3__Ident')-PLAN['session_observer']['ident_elf_value']
    assert all(row['address']==bias+row['elf_value'] for row in checks.values())
    (OUT/'session-symbols.json').write_text(json.dumps({'load_bias':bias,'checks':checks},indent=2)+'\\n')
    session=_session_module.SessionCapture(data,address,OUT,PLAN['session_observer']['limits'])
    try:
        roots=session.capture_roots();assert roots['complete'],roots
        result=session.capture_session();assert result['complete'],result
        meta=_meta_module.Projection(session).collect();assert meta['complete']
        selected=[r for r in meta['drivers'] if r.get('selected')]
        expected=['inline_trivial','eliminate_builtin','remove_unused','detect_polymorphism','eliminate_inductive','eliminate_algebraic_if_poly','eliminate_literal','eliminate_gnatprove_guard_epsilon','eliminate_epsilon','introduce_premises','simplify_formula','discriminate_if_poly','encoding_smt_if_poly']
        assert len(selected)==1 and selected[0]['transformations']==expected
        SUMMARY['metadata']={'complete':True,'identity':identity(OUT/'metadata.json'),'full_Hsdecl_captured':False}
        save()
    finally:
        session.close();log.close();data=original_read
'''
(CODE/'probe.py').write_text(s)
r=(CODE/'inherited-run.py').read_text()
r=r.replace("ROOT=Path(__file__).parent;PLAN=json.loads((ROOT/'plan.json').read_text())", "import sys\nROOT=Path(sys.argv[1]).resolve();PLAN=json.loads((ROOT/'plan.json').read_text());CODE=Path(PLAN['collector_root'])")
r=r.replace("root='"+ORIG+"'", "root='CAPTURE_ROOT_VALUE'\nCOLLECTOR_ROOT='COLLECTOR_ROOT_VALUE'\nCAPTURE_ROOT=root")
r=r.replace("exec(open(root+'/probe.py').read())", "exec(open(COLLECTOR_ROOT+'/probe.py').read())")
r=r.replace("'''.replace('CASE_INDEX=INDEX','CASE_INDEX='+str(i))", "'''.replace('CASE_INDEX=INDEX','CASE_INDEX='+str(i)).replace('CAPTURE_ROOT_VALUE',str(ROOT)).replace('COLLECTOR_ROOT_VALUE',str(CODE))")
r=r.replace('All five registration segments completed; no solver scheduling or driver preparation; inputs unchanged.', 'R53 selected registration metadata capture completed; client/server J12, no solver scheduling/preparation, inputs unchanged.')
(CODE/'run.py').write_text(r)
for p in CODE.iterdir():
 if p.is_file():plan['file_identities'][str(p)]=ident(p)
(ROOT/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
(HERE/'attempt-2-plan.json').write_bytes((ROOT/'plan.json').read_bytes())
(HERE/'attempt-2-driver-resolution.json').write_bytes((ROOT/'driver-resolution.json').read_bytes())
print(ROOT, 'plan inputs', len(plan['file_identities']))
