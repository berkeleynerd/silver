"""One managed metadata acquisition, no proof or solver execution."""
import json,subprocess,sys,shlex
from pathlib import Path
CODE=Path(__file__).resolve().parent
REPO=Path('/home/canto/src/github.com/berkeleynerd/silver')
ROOT=Path(sys.argv[1]).resolve()
plan=json.loads((ROOT/'plan.json').read_text())
cmd=['python3',str(REPO/'scripts/dev.py'),'tool','--task','#119','--jobs','1',
 '--reason','R53 missing metadata: all 5918792 retained read-log rows omit Meta/argument roots. First_Or_Default contains all four residual families. Acquire actual raw and selected Z3 metadata at registration with client/server J12; zero solver/preparation; logical closure only for symbol correspondence; no full Hsdecl or arithmetic replay.',
 '--workspace',str(ROOT)]
paths=set(plan['file_identities'])|{str(CODE/'managed.py'),str(ROOT/'plan.json'),str(ROOT/'driver-resolution.json')}
for p in sorted(paths):cmd+=['--input',p]
cmd+=['--','python3',str(CODE/'run.py'),str(ROOT)]
if '--print' in sys.argv:print(shlex.join(cmd))
else:raise SystemExit(subprocess.call(cmd,cwd=REPO))
