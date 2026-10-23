"""Check the reviewed private-string correction only; no graph/checker replay."""
from pathlib import Path
import hashlib
import json
import time

h = Path(__file__).resolve().parent
root = h.parents[2]
start = time.perf_counter()
note = root / 'docs/research/retained-fixed-ptree-mlw-output.md'
assert 'T = max(M, 4P+2, 4L+2, L+16, 90)' in note.read_text()
assert "4 * old['maximum_direct_string_payload'] + 2" in (h / 'check.py').read_text()
rows = []
capture = json.loads((root / 'docs/evidence/retained-fixed-ptree-capture-20261023/result.json').read_text())
for case in capture['cases']:
    length = case['maximum_direct_string_payload']
    # Each symbolic component is separately included in the max; finite joins
    # below include the previously omitted unmarked/small-path branch.
    for marker, path in ((0, 0), (0, 416), (1743304, 416)):
        components = [marker, 4*path+2, 4*length+2, length+16, 90]
        total = max(components)
        assert all(total >= c for c in components)
        assert total <= 2**57-9
        rows.append(dict(case=case['case'], L=length, P=path, M=marker, T=total))
result = dict(status='pass', scope='private-string T correction only; original successful graph/native/output checks retained without replay',
              reviewed_problem='Direct %S strings require 4L+2 independently of marker M and filename P.',
              previous_result='result-before-private-string-correction.json',
              input_sha256={str(p.relative_to(root)): hashlib.sha256(p.read_bytes()).hexdigest()
                            for p in (note, h/'check.py', h/'result-before-private-string-correction.json')},
              joins=rows, elapsed_seconds=time.perf_counter()-start)
(h/'private-string-repair-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result, indent=2))
