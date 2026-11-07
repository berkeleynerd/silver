"""Apply root's bounded publication scope; keep every full archive byte locally."""
from pathlib import Path
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
import shutil

native=Path(__file__).resolve().parents[2]
scratch=Path(__file__).resolve().parent
feature=native.parent/'boolean-arrays'
packet=feature/'docs/evidence/boolean-arrays-20261106/native-primary-failure/terminal-native'
stage=scratch/'terminal-native-retained'
run=Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261106T232644-673fc5a9c06b')
ledger=run/'original-native-tasks-and-sessions'
reports=native/'.silver/linux-x86_64/compiler/obj/review-final/gnatprove'
spec=importlib.util.spec_from_file_location('retention_helpers',scratch/'retain-repaired-final-native.py')
helpers=importlib.util.module_from_spec(spec);spec.loader.exec_module(helpers)
sha,write,archive=helpers.sha,helpers.write,helpers.add_archive
assert not ledger.exists()
for row in json.loads((packet/'artifact-inventory.json').read_text()):
    assert sha(packet/row['path'])==row['sha256'],row['path']
record=json.loads((packet/'record.json').read_text())
assert len(record['actual_unresolved_report_records'])==2
assert {r['entity'] for r in record['unresolved_helper_sessions']}=={'silver_output_profile__read_primary_into','silver_output_profile__read_relation_into'}
ledger.mkdir()
for name in ('all-native-tasks-and-sessions.tar.gz','all-native-tasks-and-sessions.inventory.json','record.json','retention-helper.py','artifact-inventory.json'):
    original=stage/name
    shutil.copy2(original,ledger/name)
    assert sha(ledger/name)==sha(original),name
local={'recorded_utc':datetime.now(timezone.utc).isoformat(),'run_id':run.name,'original_source_sha256':record['native_source_sha256'],'original_outcome':'failure','archive':{'path':str(ledger/'all-native-tasks-and-sessions.tar.gz'),'bytes':(ledger/'all-native-tasks-and-sessions.tar.gz').stat().st_size,'sha256':sha(ledger/'all-native-tasks-and-sessions.tar.gz')},'member_inventory':{'path':str(ledger/'all-native-tasks-and-sessions.inventory.json'),'bytes':(ledger/'all-native-tasks-and-sessions.inventory.json').stat().st_size,'sha256':sha(ledger/'all-native-tasks-and-sessions.inventory.json')},'archive_summary':record['archives']['all-native-tasks-and-sessions'],'verification':'Original terminal collector checked every archive member hash and inventory. This ledger copy was verified by exact whole-file SHA-256 against the preserved native scratch original. No tasks were regenerated.','publication_scope':'The complete generated task/session/shape/configuration archive remains local in the existing managed run ledger, including successful helpers. The checked-in terminal packet retains complete native reports, exact input/tool/source identities, logs/events/census, and only the two unresolved helpers generated tasks/sessions/shapes plus their shared configuration. No publication chunking or new storage format.'}
write(ledger/'local-retention.json',local)
write(packet/'local-full-task-retention.json',local)
# Preserve both the original full scratch packet and the independently verified ledger copy.
# Only redundant copies in the not-yet-committed publication packet are removed.
for name in ('all-native-tasks-and-sessions.tar.gz','all-native-tasks-and-sessions.inventory.json'):
    assert sha(packet/name)==sha(ledger/name)
    (packet/name).unlink()
config_members=[(p,str(p.relative_to(reports))) for p in sorted(reports.rglob('*.conf')) if p.is_file()]
assert [name for _,name in config_members]==['why3.conf']
config_inventory=archive(packet/'failed-helper-shared-configuration.tar.gz',config_members)
write(packet/'failed-helper-shared-configuration.inventory.json',config_inventory)
record['archives']['all-native-tasks-and-sessions'].update({'retention':'local-only in original managed run ledger','locator':'local-full-task-retention.json','archive_sha256':local['archive']['sha256'],'archive_bytes':local['archive']['bytes']})
record['archives']['failed-helper-shared-configuration']={'members':len(config_inventory),'source_bytes':sum(x['bytes'] for x in config_inventory),'scope':'Shared exact Why3 configuration governing both failed helper tasks.'}
record['publication_scope']=local['publication_scope']
record['local_full_task_retention']=local
record['failed_helper_solver_scope']='The ordinary original run did not save standalone SMT/PSMT solver input files in either failed helper directory. Exact generated .gnat-json tasks, current Why3 sessions/shapes, shared Why3 configuration and the complete original reports/attempt diagnostics are retained. Earlier original/helper diagnosis packets remain separate immutable evidence.'
write(packet/'record.json',record)
(packet/'README.md').write_text('# Original audit terminal evidence\n\nThis is the failed original-source complete audit, not repaired-source success evidence. [record.json](record.json) retains its exact two unresolved records, both Primary source locations (check 3570:28; emitted diagnostic 3572:20), Relation assertion 3945:18, and complete census: 76 units, 16,163 proof records (16,161 informational and two medium), and 1,513 informational flow records.\n\nThe checked-in archives retain all 76 native reports, exact original source/input/tool identities, managed events/logs, and only the two failed helpers\' generated tasks, current sessions/shapes and shared Why3 configuration. No standalone original SMT/PSMT files were generated in those helper directories. Earlier failed and repaired-helper packets remain separate dated evidence.\n\nThe complete available generated task/session/shape/configuration archive, including successful helpers, is preserved locally under the original managed run in `.git/silver-runs`; its exact path, verified byte size, SHA-256 and member-inventory identity are in [local-full-task-retention.json](local-full-task-retention.json). The full verified scratch packet is also preserved. Successful-helper generated tasks are not checked in, and no chunking format was introduced.\n')
shutil.copy2(Path(__file__),packet/'publication-scope-helper.py')
write(packet/'artifact-inventory.json',[{'path':p.name,'bytes':p.stat().st_size,'sha256':sha(p)} for p in sorted(packet.iterdir()) if p.is_file() and p.name!='artifact-inventory.json'])
for row in json.loads((packet/'artifact-inventory.json').read_text()):
    assert sha(packet/row['path'])==row['sha256'],row['path']
assert max(p.stat().st_size for p in packet.iterdir() if p.is_file())<100*1024*1024
print(json.dumps({'packet':str(packet),'published_files':len(list(packet.iterdir())),'published_bytes':sum(p.stat().st_size for p in packet.iterdir() if p.is_file()),'full_local_archive':local['archive'],'member_inventory':local['member_inventory'],'full_task_members':local['archive_summary'],'outcome':record['finished']['outcome'],'counts':record['counts']},indent=2))
