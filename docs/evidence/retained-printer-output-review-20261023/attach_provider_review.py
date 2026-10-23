"""Attach separate accepted input review; never replay its audit."""
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REVIEW = '2533c4962814cc85cda0e76462819d5e16525b30'
AUTHOR = 'b5aad6d57b2f215ac047edb931314812c6687905'
EXPECTED = {'62f686fe7331c2faf74c3c9f66df93f2626f1fa0',
            '39afb9db41c4052a7b68c2663f2bcc72d72a27ac',
            'badd4304991e055d957d0965d004e3d207ecc8fa'}
start = time.monotonic()
paths = ['docs/reviews/review-name-attribute-bounds-20261023.md']
paths += ['docs/evidence/retained-name-attribute-bounds-review-20261023/'+p
          for p in ('targets.json','audit-result.json','round.json')]
blobs = {p: subprocess.check_output(['git','show',REVIEW+':'+p],cwd=ROOT) for p in paths}
targets = json.loads(blobs[paths[1]])
assert {r['commit'] for r in targets['targets']} == EXPECTED
report = blobs[paths[0]].decode()
assert '**Accepted under the retained\npremises at these exact freezes:**' in report
old_result = json.loads(blobs[paths[2]])
assert old_result['targets'] == targets
author = json.loads(subprocess.check_output(['git','show',AUTHOR+
    ':docs/evidence/retained-why-printer-output-20261023/result.json'],cwd=ROOT))
assert set(author['providers'].values()) <= EXPECTED
out = dict(status='attached',review=REVIEW,author=AUTHOR,targets=targets,
           provider_reviewer_acceptance_reused=True,provider_review_replays=0,
           providers=author['providers'],elapsed_seconds=time.monotonic()-start,
           exact_files={p:dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest()) for p,b in blobs.items()})
(HERE/'provider-review-attachment.json').write_text(json.dumps(out,indent=2,sort_keys=True)+'\n')
print(json.dumps({k:v for k,v in out.items() if k not in ('targets','exact_files')},indent=2))
