from pathlib import Path
from datetime import datetime,timezone
from collections import Counter
import json,sys,xml.etree.ElementTree as ET
root=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(root))
from tests.test_samples import SupportedSampleTests,audit_reports
report=root/'.silver/linux-x86_64/program-7GdkTj/obj/gnatprove'
SupportedSampleTests().assert_application_proof_policy(report/'gnatprove.sarif',output=True)
statistics=audit_reports(report,{'main','silver_io','silver_output_libc','silver_arguments','silver_runtime'}, {'silver_output_libc','silver_runtime'}, application_kind='argument',indexed_main=True)
summary={}
for f in report.rglob('why3session.xml'):
 tree=ET.parse(f).getroot();provers={p.get('id'):p.get('name') for p in tree.findall('prover')}
 for proof in tree.iter('proof'):
  result=proof.find('result')
  if result is None:continue
  name=provers[proof.get('prover')];entry=summary.setdefault(name,{'results':{}})
  status=result.get('status');entry['results'][status]=entry['results'].get(status,0)+1
started=datetime.fromisoformat('2026-11-21T19:16:55.580000+00:00')
finished=datetime.fromtimestamp((report/'gnatprove.sarif').stat().st_mtime,timezone.utc)
record={'original_test_run':'20261121T191653-cdd01ba978f7','test_outcome':'failed at 1800-second deadline; unchanged','observation_run':'20261121T194920-1da1c3dafb35','original_prover_exit_status':'unavailable after original parent exited','prover_started':started.isoformat(),'report_written':finished.isoformat(),'elapsed_until_report_seconds':(finished-started).total_seconds(),'independent_report_audit':statistics,'recorded_solver_results':summary,'scope':'retained report/policy audit only; no compiler build, execution or fresh end-to-end test claim'}
(root/'tmp/maximal-serial-assessment/result.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record,indent=2))
