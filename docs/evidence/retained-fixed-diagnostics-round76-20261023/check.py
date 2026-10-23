"""Integrate reviewed diagnostic interfaces without replaying providers."""
from pathlib import Path
import hashlib,json,subprocess,time
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];EV=HERE.parent;start=time.perf_counter()
def read(p):return json.loads(p.read_text())
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
components=read(HERE/'inputs.json')['components'];frozen={}
for c in components.values():
    for p in c['paths']:
        b=(ROOT/p).read_bytes()
        assert b==subprocess.check_output(['git','show',c['freeze']+':'+p],cwd=ROOT),p
        frozen[p]=identity(b)
pre=read(EV/'review-precut-failure-capacity-20261023/result.json')
sexp=read(EV/'review-fixed-ptree-sexp-output-20261023/result.json')
mlw=read(EV/'retained-fixed-ptree-mlw-review-20261023/result.json')
assert pre['status']==sexp['status']==mlw['status']=='pass'
assert pre['reviewed_commit']==components['precut']['freeze']
assert sexp['reviewed_commit']==components['sexp']['freeze']
assert mlw['author_repaired']==components['mlw']['freeze']
assert not pre['whole_process_capacity_established'] and not pre['actual_path_joined']
assert not sexp['whole_process_capacity_established']
assert sexp['maximum_B']==7104139 and sexp['maximum_backing']==8388608
sr=read(EV/'retained-fixed-ptree-sexp-output-20261023/result.json')
assert max(c['complete_failure_byte_bound'] for c in sr['cases'])==sexp['maximum_B']
assert max(c['buffer_backing_bound'] for c in sr['cases'])==sexp['maximum_backing']
assert all(c['FileTags_filename_bound']==180 for c in sr['cases'])
assert (EV/'retained-fixed-ptree-sexp-output-20261023/result-before-filetag-repair.json').read_bytes()==subprocess.check_output(['git','show','22e910d7f7:docs/evidence/retained-fixed-ptree-sexp-output-20261023/result.json'],cwd=ROOT)
assert (EV/'retained-fixed-ptree-mlw-output-20261023/result-before-private-string-correction.json').read_bytes()==subprocess.check_output(['git','show','c8506b1d4064:docs/evidence/retained-fixed-ptree-mlw-output-20261023/result.json'],cwd=ROOT)
for name in ('precut','sexp'):
    receipt=pre if name=='precut' else sexp
    assert receipt['native_runs']==receipt['provider_checker_runs']==0
assert mlw['native_runs']==mlw['provider_replays']==0
pins=read(EV/'retained-literal-native-completion-20261019/inputs.json')
for r in pins['repository']:assert identity((ROOT/r['path']).read_bytes())=={k:r[k] for k in ('bytes','sha256')},r['path']
native=read(EV/'retained-fixed-ptree-mlw-output-20261023/native-witnesses.json')
assert identity(Path(native['executable']).read_bytes())==native['identity']
out=dict(status='pass',frozen_files=frozen,conditional_precut_scalar_marker_interface=True,
    fixed_diagnostic_sexp_and_mlw_interfaces=True,FileTags_repair_reviewed=True,private_string_repair_reviewed=True,
    complete_fixed_process_composition=False,controlled_driver_resolution_repair_complete=False,
    Main_full_profile_accepted=False,issue153_complete=False,issue178_complete=False,whole_capacity_rule_complete=False,
    native_source_pins_unchanged=len(pins['repository']),installed_Why_unchanged=True,
    component_checker_replays=0,integration_native_runs=0,global_exception_allowance_renewed=False,
    elapsed_seconds=time.perf_counter()-start)
(HERE/'integration-result.json').write_text(json.dumps(out,indent=2)+'\n')
print(json.dumps({k:v for k,v in out.items() if k!='frozen_files'},indent=2))
