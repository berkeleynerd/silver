from pathlib import Path
import json,sys
root=Path(sys.argv[1]);sys.path.insert(0,str(root))
from scripts.check_evidence import audit_reports
reports=root/'.silver/linux-x86_64/compiler/obj/explore/guard-frontend/gnatprove'
result=audit_reports(reports,{'silver'})
output=json.dumps(result,indent=2)+'\n'
(Path(__file__).parent/'result.json').write_text(output);print(output,end='')
