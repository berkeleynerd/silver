"""Managed missing-metadata continuation using the explicit plan scope as reason."""
import json,subprocess,sys,shlex
from pathlib import Path
CODE=Path(__file__).resolve().parent;REPO=Path('/home/canto/src/github.com/berkeleynerd/silver');ROOT=Path(sys.argv[1]).resolve();plan=json.loads((ROOT/'plan.json').read_text())
cmd=['python3',str(REPO/'scripts/dev.py'),'tool','--task','#119','--jobs','1','--reason',plan['scope'],'--workspace',str(ROOT)]
for p in sorted(set(plan['file_identities'])|{str(CODE/'managed-next.py'),str(ROOT/'plan.json'),str(ROOT/'driver-resolution.json')}):cmd+=['--input',p]
cmd+=['--','python3',str(CODE/'run.py'),str(ROOT)]
if '--print' in sys.argv:print(shlex.join(cmd))
else:raise SystemExit(subprocess.call(cmd,cwd=REPO))
