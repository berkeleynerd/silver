#!/usr/bin/env python3
"""Freeze selected retained inputs. This records identities, not proof results."""
from pathlib import Path
import hashlib
import json
import tarfile

ROOT = Path(__file__).resolve().parents[3]
PACKET = Path(__file__).resolve().parent
BASE = 'a07c225eb4987708db46d9439fce1fcdd152b166'


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


notes = '''retained-tool-capacity retained-tool-source-identity
retained-producer-prefix-composition retained-producer-fixed-tail
retained-producer-fixed-context retained-combined-parallel-startup
retained-why-parallel-state-attachment retained-why-shared-demand
retained-why-library-constructors retained-why-printer-entry
retained-why-returned-storage retained-why-postinline-preparation
retained-why-canonical-json-input retained-why-report-path-inputs
retained-why-reporting-path-join retained-why-reporting-composition
retained-why-logging-capacity retained-why-save-path-input-join
retained-why-save-service-contract retained-why-save-owned-stack-join
retained-why-standard-channel-attachment retained-server-request-storage
retained-server-owned-storage retained-server-libc-storage
retained-backend-output-route retained-controller-owner-join
retained-current-protocol-join retained-adapter-protocol-storage
retained-why-save-table-contract-join retained-why-attempt-counter-continuation
retained-solver-request-bytes retained-solver-launch-profile'''.split()
providers = {'oracle.md','docs/trusted-boundary.md'}
providers.update('docs/research/'+name+'.md' for name in notes)
receipts = sorted(str(path.relative_to(ROOT)) for path in (ROOT/'docs/evidence').glob('*/integration-result.json')
                  if any('round'+str(r)+'-' in str(path) for r in range(63,75)))
providers.update(receipts)
for spec in '''retained-name-attribute-round65-20261023/composition-result.json
retained-six-owner-round63-20261023/candidate-composition-result.json
retained-controller-owner-join-20261023/result.json
retained-why-canonical-json-input-20261023/result.json
retained-why-report-path-inputs-20261023/projection.json
retained-reporting-path-join-20261023/result.json
retained-why-logging-capacity-20261023/bounds.json
retained-solver-request-bytes-20261020/projection.json
retained-why-save-round32-20261020/result.json
retained-why-save-round38-20261020/save-stack-join.json
retained-why-save-table-contract-join-20261020/result.json
retained-why-library-constructors-20261023/family-shapes.json
retained-why-printer-entry-20261020/result.json
retained-server-owned-storage-20261020/projection.json
retained-server-libc-storage-20261020/projection.json
retained-current-protocol-join-20261023/result.json
retained-backend-output-route-20261023/projection.json
retained-backend-output-route-20261023/result.json
retained-why-session-helper-source-20261019/sources.tar.gz
retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz
retained-producer-fixed-context-20261018/sources.tar.gz'''.split():
    providers.add('docs/evidence/'+spec)
manifest = dict(base_commit=BASE,
                providers={p:ident((ROOT/p).read_bytes()) for p in sorted(providers)},
                acceptance_receipts=receipts,
                preparation_private_memos=dict(author_freeze='bb61e70086339202fd167cd4990f86106e63ebe6',
                                               independent_review_accepted=False, files={}))
if (PACKET/'inputs.json').exists():
    previous=json.loads((PACKET/'inputs.json').read_text())
    manifest['preparation_private_memos']=previous['preparation_private_memos']
(PACKET/'inputs.json').write_text(json.dumps(manifest,indent=2)+'\n')

# These anchors locate manually reviewed source cases. Presence is not a semantic proof.
selections = {
 'why3/src/transform/eliminate_epsilon.ml': [
  (25,67,['with Exit -> Nothing']),
  (96,109,['Hls.create 3','Ty.Hty.create 3','id_canonical (Ty.ty_var']),
  (123,177,['| Nothing ->','| Partial (ls, rargs) ->','| Id ty ->'])],
 'why3/src/core/decl.ml': [
  (39,67,['let make_ls_defn ls vl t','let open_ls_defn','| Tbinop (_, _, f) -> vl,f']),
  (111,140,['Hid.create 5','Hid.add cgr callee','Array.of_list dl']),
  (142,195,['| Por (p1,p2) ->','term (create_vs_graph vl) () e']),
  (197,240,['let htb = Hid.create 5','Hid.add htb s c','when id_equal id s']),
  (242,281,['if res = [] then raise exn','List.filter test mx'])],
 'why3/src/mlw/pdecl.ml': [
  (567,614,['| RLlemma ->','| Some f when cty.cty_pre = [] ->','| Cfun e ->']),
  (615,638,['| LDrec rdl ->','try [create_logic_decl dl] with Decl.NoTerminationProof _ ->'])],
 'why3/src/mlw/expr.ml': [
  (102,150,['let make_post t','| RKfunc ->','(RLls ls)']),
  (213,221,['let rs_of_ls ls','make_post (t_app ls t_args ls.ls_value)']),
  (560,632,['let rec raw_of_expr prop e','t_let_close_simp','let term_of_expr ~prop e']),
  (891,919,['let mk_proxy ghost e hd','let e_app s el','List.fold_right2 add_proxy']),
  (1193,1236,['let rec e_rs_subst sm e','and c_rs_subst sm','c_app (Mrs.find_def s s sm)'])],
 'why3/src/mlw/ity.ml': [
  (1590,1595,['cty_post = post @ c.cty_post'])],
 'why3/src/mlw/pmodule.ml': [
  (729,780,['let clone_ls cl ls','create_lsymbol ~proj ~constr', '| Dlogic ldl ->','create_logic_decl (List.map get_logic ldl)'])],
 'why3/src/core/term.ml': [
  (1284,1294,['t_open_bound']) ,
  (1668,1673,['| Tvar _ | Tconst _ -> true','| _ -> false']),
  (1703,1714,['if n = 1 || small e then','t_let_close v e t'])],
}
archive='docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
members={}
with tarfile.open(ROOT/archive) as tar:
 for member,spans in selections.items():
    data=tar.extractfile(member).read();lines=data.decode().splitlines(keepends=True)
    members[member]=dict(ident(data),ranges=[dict(first=lo,last=hi,anchors=anchors,
                    sha256=hashlib.sha256(''.join(lines[lo-1:hi]).encode()).hexdigest())
                    for lo,hi,anchors in spans])
(PACKET/'source-ranges.json').write_text(json.dumps(dict(archives={archive:members}),indent=2)+'\n')
print('Prepared input identities and source spans; no composition audit executed.')
