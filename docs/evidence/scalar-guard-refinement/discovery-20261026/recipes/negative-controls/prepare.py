"""Extract six independent original unsafe fragments; never invoke native tools."""
from pathlib import Path
import hashlib
import json

BASE=Path(__file__).resolve().parent
ORIGINAL=BASE.parent/'probes/unsafe/src/main.adb'
PROJECT=BASE.parent/'probes/unsafe/probe.gpr'
original=ORIGINAL.read_text()
lines=original.splitlines(keepends=True)
specs=[
    ('stale_replacement',7,13,[lines[2]],11,18,'VC_RANGE_CHECK','range check might fail',
     'After X < 9, X := 9 replaces the old fact; the next X+1 is outside 0 .. 9.'),
    ('branch_join',14,18,[lines[2]],17,15,'VC_RANGE_CHECK','range check might fail',
     'Seed=9 takes the explicit else assigning 9, then the joined X+1 is outside 0 .. 9.'),
    ('omitted_else',19,23,[lines[2]],22,15,'VC_RANGE_CHECK','range check might fail',
     'Seed=9 takes the omitted else, preserving 9 before X+1.'),
    ('loop_reentry',24,29,[lines[2]],27,42,'VC_RANGE_CHECK','range check might fail',
     'Seed=8 passes the preloop X < 9 guard; the second iteration attempts X=10.'),
    ('minimum_negation',30,33,[lines[3],lines[4]],32,36,'VC_OVERFLOW_CHECK','overflow check might fail',
     'Seed=Integer minimum reaches negative Wide; -Wide exceeds Integer maximum.'),
    ('shadowed_mutable',34,38,[lines[2],lines[3]],37,12,'VC_RANGE_CHECK','range check might fail',
     'Seed=10 remains in hidden mutable Wide; the same-spelled inner index does not change it.'),
]
cases=[]
for name,start,end,declarations,oldline,col,rule,message,rationale in specs:
    fragment=''.join(lines[start-1:end])
    header='procedure Main is\n   pragma SPARK_Mode (On);\n'+''.join(declarations)+'begin\n'
    source=header+fragment+'end Main;\n'
    path=BASE/'projects'/name
    (path/'src').mkdir(parents=True,exist_ok=True)
    (path/'src/main.adb').write_text(source)
    (path/'probe.gpr').write_bytes(PROJECT.read_bytes())
    new_line=len(header.splitlines())+(oldline-start+1)
    cases.append(dict(name=name,status='prepared only; not executed',native_expectation='EXPECTED FAIL',
                      rationale=rationale,source_bytes=len(source.encode()),source_sha256=hashlib.sha256(source.encode()).hexdigest(),
                      original_fragment_lines=[start,end],original_failing_line=oldline,
                      original_fragment_sha256=hashlib.sha256(fragment.encode()).hexdigest(),
                      expected_check=dict(file='main.adb',line=new_line,col=col,rule=rule,message_contains=message,
                                          expected_unproved_safety_sites=1),
                      expected_source_line=source.splitlines()[new_line-1]))
manifest=dict(issue=237,status='six independent negative controls prepared; no new native execution',
              original_combined_source=str(ORIGINAL),original_combined_sha256=hashlib.sha256(original.encode()).hexdigest(),
              original_evidence='../results/20261026T002359Z/unsafe',
              evidence_limit='Combined evidence failed original lines 11 and 17; later four sites were proved after preceding unsafe checks. It does not establish six exercised failing sites.',
              cases=cases)
(BASE/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps([{c['name']:c['expected_check']} for c in cases],indent=2))
