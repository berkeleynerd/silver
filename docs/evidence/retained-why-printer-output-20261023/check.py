"""Focused author packet integrity/arithmetic check; no predecessor imports."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
import time
from compose import evaluate

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def main():
    start = time.perf_counter()
    inputs = json.loads((HERE/'inputs.json').read_text())
    blobs = {}
    for name, expected in inputs.items():
        data = subprocess.check_output(['git','show',name],cwd=ROOT)
        assert identity(data) == expected, name
        blobs[name] = data
    census = json.loads((HERE/'census.json').read_text())
    witnesses = json.loads((HERE/'source-witnesses.json').read_text())
    archives = {}
    seen = set()
    for row in witnesses:
        key = census['base']+':'+row['archive']
        data = blobs[key]
        assert identity(data) == row['archive_identity']
        if key not in archives:
            with tarfile.open(fileobj=io.BytesIO(data),mode='r:gz') as arc:
                wanted = {r['member'] for r in witnesses if r['archive']==row['archive']}
                archives[key] = {name:arc.extractfile(name).read() for name in wanted}
        member = archives[key][row['member']]
        assert identity(member) == row['member_identity']
        lines = member.decode().splitlines(keepends=True)
        first, last = row['first_line'], row['last_line']
        assert type(first) is int and type(last) is int
        assert 1 <= first <= last <= len(lines), (key,first,last,len(lines))
        span = (key,row['member'],first,last)
        assert span not in seen
        seen.add(span)
        excerpt = ''.join(lines[first-1:last])
        assert excerpt == row['excerpt']
        assert identity(excerpt.encode()) == row['excerpt_identity']
    raw = json.loads(blobs[census['raw_names_provider']+
        ':docs/evidence/retained-why-raw-name-length-20261023/result.json'])
    names = {r['case']:r for r in raw['cases']}
    hs = json.loads(blobs[census['hsattr_provider']+
        ':docs/evidence/retained-why-hsattr-demand-20261023/result.json'])
    hyp = {r['case']:r['hyp_name_value_bytes_upper'] for r in hs['cases']}
    assert len(census['cases']) == len(names) == len(hyp) == 5
    for row in census['cases']:
        n = names[row['case']]
        assert row['raw_name_bytes'] == n['raw_name_L_at_printer_entry']
        assert row['raw_comment_name_bytes'] == max(n['raw_name_L_at_printer_entry'],n['raw_proposition_name_L_pr'])
        assert hyp[row['case']] == n['L_pr_hyp_name_input'] == 13
        assert row['all_original_trigger_groups_nonempty']
    result = json.loads((HERE/'result.json').read_text())
    assert result == evaluate(census)
    assert result['all_scoped_numeric_guards_pass']
    assert not result['whole_printer_capacity'] and not result['whole_process_capacity']
    assert not result['aggregate_RAM_gate'] and not result['budget_renewed']
    counterexample = json.loads((HERE/'drain-counterexample.json').read_text())
    assert counterexample['Pinf'] == 1000000010
    assert len(counterexample['steps']) == 6
    assert any('force_newline' in s for s in counterexample['steps'])
    report = dict(status='pass',frozen_inputs=len(inputs),source_spans=len(witnesses),
                  cases=5,driver_case_compositions=15,
                  elapsed_seconds=time.perf_counter()-start,
                  source_semantics_machine_checked=False,
                  predecessor_programs_run=0,native_runs=0,
                  independent_review=False)
    (HERE/'check-result.json').write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps(report))


if __name__ == '__main__': main()
