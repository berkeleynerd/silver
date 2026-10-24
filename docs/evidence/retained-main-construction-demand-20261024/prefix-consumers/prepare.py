"""Freeze new consumer operands from retained providers; execute no predecessor."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = 'd3f8e84cc8'
PACKET = 'docs/evidence/retained-main-construction-demand-20261024'
RESEARCH = 'docs/research/retained-main-construction-demand.md'
WHY = 'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
YOJSON = PACKET + '/prefix-consumers/yojson-3.0.0.tar.gz'
NUMERIC = 'docs/evidence/retained-producer-numerics-20261018/inputs-fields-and-runs.tar.gz'
ZARITH = 'docs/evidence/retained-why-interval-native-effects-20261019/'
PROVIDERS = [WHY, OCAML, NUMERIC,
    'docs/evidence/retained-producer-numerics-20261018/manifest.json',
    'docs/evidence/retained-producer-numerics-20261018/summary.json',
    'docs/research/retained-producer-numerics.md',
    'docs/research/retained-producer-fixed-numerics.md',
    'docs/research/retained-producer-fixed.md',
    'docs/research/retained-producer-composition.md',
    'docs/evidence/retained-producer-composition-20261018/result.json',
    'docs/research/retained-producer-storage.md',
    'docs/evidence/retained-producer-storage-20261018/serialization.json',
    'docs/evidence/retained-why-native-effect-completeness-20261019/source-family.json',
    'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json',
    'docs/research/retained-why-fixed-session-atoms.md',
    'docs/evidence/retained-why-formatter-prefix-repair-20261019/inputs.json',
    'docs/reviews/review-main-prefix-auxiliary-20261024.md',
    'docs/evidence/review-main-prefix-auxiliary-20261024/result.json',
] + [ZARITH + n for n in ('caml_z.c', 'z.ml', 'big_int_Z.ml', 'zarith-retrieval.json')]
SPECS = {
 WHY: {
  'plugins/gnat_json/gnat_ast_to_ptree.ml': [(40, 52), (330, 335), (369, 395), (422, 455), (648, 676), (1194, 1202), (1337, 1359), (1382, 1410)],
  'plugins/gnat_json/gnat_ast.ml': [(1306, 1355)],
  'src/util/number.ml': [(76, 165)], 'src/util/bigInt.ml': [(11, 70)],
  'src/util/constant.ml': [(27, 43)],
 },
 OCAML: {
  'stdlib/lexing.ml': [(16, 79), (83, 170), (183, 200)],
  'stdlib/buffer.ml': [(19, 37), (78, 100), (136, 143), (172, 197)],
  'stdlib/format.ml': [(27, 45), (106, 121), (218, 250), (256, 287), (325, 342), (430, 465), (473, 534), (592, 635), (937, 978), (1005, 1035), (1189, 1195), (1265, 1402)],
  'stdlib/printf.ml': [(17, 43)],
  'stdlib/camlinternalFormat.ml': [(1378, 1422), (1448, 1457), (1515, 1547), (1560, 1566), (1665, 1698), (1938, 1953)],
  'stdlib/queue.ml': [(18, 95)], 'stdlib/stack.ml': [(16, 59)],
  'runtime/lexing.c': [(23, 124), (130, 233)],
  'runtime/custom.c': [(30, 100)], 'runtime/ints.c': [(137, 189)],
 },
 YOJSON: {
  'lib/safe.cppo.ml': [(1, 29)], 'lib/dune': [(1, 2), (57, 75)],
  'lib/read.mll': [(1, 150), (170, 261), (276, 312), (338, 360), (480, 494), (535, 545), (578, 590), (859, 899)],
  'lib/common.ml': [(1, 31)], 'lib/codec.ml': [(1, 47)], 'lib/lexer_utils.mll': [(1, 18)],
 },
}
LOOSE = {
 ZARITH+'caml_z.c': [(80, 175), (316, 343), (363, 425), (587, 697), (1365, 1392), (1422, 1498), (1588, 1669), (1674, 1698), (1825, 1853)],
 ZARITH+'big_int_Z.ml': [(21, 56), (84, 107)],
 ZARITH+'z.ml': [(28, 102), (117, 130), (310, 328)],
}


def sha(data): return hashlib.sha256(data).hexdigest()
def pin(path, data=None):
 data = (ROOT/path).read_bytes() if data is None else data
 return {'path': path, 'bytes': len(data), 'sha256': sha(data)}
def write(name, data): (HERE/name).write_text(json.dumps(data, indent=2)+'\n')
def witness(path, data, spans, archive=None):
 lines=data.splitlines(True); pieces=[]
 for first,last in spans:
  assert 1<=first<=last<=len(lines), (path, first,last,len(lines))
  b=b''.join(lines[first-1:last]);pieces.append({'first':first,'last':last,'sha256':sha(b),'text':b.decode()})
 return {'archive':archive, **pin(path,data),'spans':pieces}


def numeric_projection():
 rows=[]; tuples=set()
 with tarfile.open(ROOT/NUMERIC) as t:
  for member in sorted(t.getnames()):
   if '/numeric-' not in member or not member.endswith('.json'): continue
   data=t.extractfile(member).read(); s=json.loads(data)
   codes={f['code'] for f in s['numeric_fields'] if f['type']=='urealp__ureal'}
   assert codes==set(map(int,s['ureals']))
   values=[]
   for code in sorted(codes):
    x=s['ureals'][str(code)]
    v=(int(s['uints'][str(x['num'])]['value']),int(s['uints'][str(x['den'])]['value']),x['rbase'],x['negative'])
    tuples.add(v); values.append({'ureal_code':code, 'tuple':v})
   rows.append({**pin(member,data),'phase':s['phase'],'ureal_fields':sum(f['type']=='urealp__ureal' for f in s['numeric_fields']),'values':values})
 return {'archive':NUMERIC,'accepted_decoded_fields_reused_without_predecessor_replay':True,'snapshots':rows,'distinct_tuples':[list(x) for x in sorted(tuples)]}


if __name__=='__main__':
 rows=[]
 for archive,spec in SPECS.items():
  with tarfile.open(ROOT/archive) as t:
   names=t.getnames()
   for name,spans in spec.items():
    exact=name if name in names else next(n for n in names if n.endswith('/'+name))
    rows.append(witness(exact,t.extractfile(exact).read(),spans,archive))
 for path,spans in LOOSE.items(): rows.append(witness(path,(ROOT/path).read_bytes(),spans))
 write('source-witnesses.json',rows)
 write('numeric-origins.json',numeric_projection())
 oldnames=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--',PACKET],cwd=ROOT,text=True).splitlines()
 old=[pin(p,subprocess.check_output(['git','show',f'{BASE}:{p}'],cwd=ROOT)) for p in oldnames]
 prior=subprocess.check_output(['git','show',f'{BASE}:{RESEARCH}'],cwd=ROOT)
 write('inputs.json',{'base_commit':BASE,'auxiliary_author':'ae53fcef513b322bdc67f91aee998d1a8c356a22','auxiliary_review':'bee34a8db1a84991cbf7491343223c5d71735afd','providers':[pin(p) for p in PROVIDERS],'immutable_prior_packets':old,'research_prefix':pin(RESEARCH,prior)})
 installed=json.loads((ROOT/'docs/evidence/retained-why-formatter-prefix-repair-20261019/inputs.json').read_text())['installed_files']['gnatwhy3']
 p=Path(installed['path']); b=p.read_bytes(); assert sha(b)==installed['identity']['sha256']
 needle=b'/home/runner/work/why3/why3/_opam/.opam-switch/build/yojson.3.0.0/_build/default'
 offsets=[]; start=0
 while (pos:=b.find(needle,start))!=-1: offsets.append(pos);start=pos+1
 assert offsets
 write('binary-version-path.json',{'accepted_binary':installed,'needle':needle.decode(),'offsets':offsets,'interpretation':'Corroborates selected Yojson3.0.0 family only. Exact historical source/native correspondence remains the inherited external behavior relation; no independent provenance theorem or binary-attestation gate.'})
 print('Frozen sources, new numeric projection, prior packet identities and version-path corroboration.')
