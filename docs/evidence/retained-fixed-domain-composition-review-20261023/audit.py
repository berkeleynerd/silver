#!/usr/bin/env python3
"""Independent arithmetic and frozen-input review; imports no provider code."""
import hashlib
import json
import subprocess
import tarfile
import time
from pathlib import Path

START = time.perf_counter()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / 'docs/evidence/retained-fixed-domain-composition-20261023'
checks = 0


def check(condition, label):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(label)


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


inputs = read(HERE / 'inputs.json')
for path, expected in inputs['author_files'].items():
    frozen = subprocess.check_output(['git', 'show', inputs['author_commit'] + ':' + path], cwd=ROOT)
    check(identity(frozen) == expected, 'author Git identity ' + path)
    check((ROOT / path).read_bytes() == frozen, 'integrated author identity ' + path)
for path, expected in inputs['review_context'].items():
    check(identity((ROOT / path).read_bytes()) == expected, 'review context ' + path)
manifest = read(AUTHOR / 'inputs.json')
for path, expected in manifest['providers'].items():
    check(identity((ROOT / path).read_bytes()) == expected, 'provider identity ' + path)
for path, expected in manifest['preparation_private_memos']['files'].items():
    check(identity((ROOT / path).read_bytes()) == expected, 'reviewed memo identity ' + path)

members_count = spans_count = 0
for archive, members in read(AUTHOR / 'source-ranges.json')['archives'].items():
    with tarfile.open(ROOT / archive) as tar:
        for name, expected in members.items():
            members_count += 1
            data = tar.extractfile(name).read()
            check(identity(data) == {k: expected[k] for k in ('bytes', 'sha256')}, 'complete source ' + name)
            lines = data.decode().splitlines(keepends=True)
            for span in expected['ranges']:
                spans_count += 1
                data = ''.join(lines[span['first'] - 1:span['last']]).encode()
                check(hashlib.sha256(data).hexdigest() == span['sha256'], 'source span ' + name)
                check(all(a.encode() in data for a in span['anchors']), 'source anchors ' + name)

result = read(AUTHOR / 'result.json')
check(result['status'] == 'pass', 'author result')
for key in ('unconditional_whole_process_capacity', 'arbitrary_pre_cut_failure_prefixes_covered',
            'arbitrary_Main_covered', 'GNATCOLL_and_final_spark_consumers_covered',
            'production_launcher_adapter_refinement_established', 'exceptional_allowance_renewed',
            'aggregate_RAM_or_stack_gate'):
    check(result[key] is False, 'scope ' + key)
check((result['global_exception_allowance'], result['global_save_callbacks'], result['global_saves'])
      == (2, 2, 3), 'single global allowance')
check(result['successful_controlled_startup_scope'] is True, 'successful prefix restriction')
check(result['guarded_fixed_Why_conjunction_established'] is True, 'claimed scoped conjunction')

names = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
roots = [51, 42, 22, 2, 1]
owners = [192, 159, 96, 9, 3]
initial = [14, 12, 10, 1, 3]
tau = [43, 82, 49, 89, 49]
loc = [352, 346, 382, 368, 376]
digits = [3, 3, 2, 1, 1]
paths = [t + max(5, 2*l) + 28 for t, l in zip(tau, loc)]
wire = [p + 231 + 2*d for p, d in zip(paths, digits)]
reports = {r['case'].replace('-', '_'): r for r in read(ROOT / 'docs/evidence/retained-reporting-path-join-20261023/result.json')['cases']}
stacks = {r['case'].replace('-', '_'): r for r in read(ROOT / 'docs/evidence/retained-why-save-round38-20261020/save-stack-join.json')['cases']}

for i, row in enumerate(result['cases']):
    check(row['case'] == names[i], 'domain order')
    n = 3 * roots[i]
    q = n + 2
    a = initial[i] + q
    check([row[k] for k in ('registered_roots', 'current_runs', 'preparation_Q', 'retained_protocol_N', 'reported_attempts', 'weighted_occurrences_O')]
          == [roots[i], n, q, owners[i], a, 76*max(a, q)], 'physical/count transport')
    check((row['F'], row['request_constant']) == (paths[i], wire[i]), 'path/request substitution')
    check(row['log_offered_bytes'] == 1281*q*(q+4), 'logging lifetime')
    stack = stacks[names[i]]
    p = sum(stack[k] for k in ('S', 'T', 'G', 'F'))
    check(row['save_caller_per_save_bytes'] == p, 'save owner sum')
    check(row['three_save_two_callback_caller_projection'] == 3*p + 13944, 'save bridge and shell')
    for r in row['reporting_provider_endpoints'] + [row['common_result_directory_endpoint']]:
        s = max(467, paths[i]+51, r['R']+95)
        y = 21*(8*(723+12*s)+65536)
        x = 2*y + 2048
        b = reports[names[i]]['b1'] + 6*x
        e = reports[names[i]]['e1'] + 2*x
        l = b+e
        check((r['S'], r['Y'], r['X'], r['B'], r['E']) == (s, y, x, b, e), 'reporting transport')
        check(r['Std'] == b+70*(e+2)+2*y+371 <= 2**63-1, 'standard offered bytes')
        check(l+79 <= 1000000010, 'Format sentinel')
        check((3*e+1)*(1000000011+l)+l+79 <= 2**62-1, 'Format scan')
        check(12*e+10 <= 2**62-1, 'Format queue count')
    check(row['epsilon'] == dict(Hls_bindings=0, Hty_bindings=1, buckets_each=16), 'epsilon source projection')
    check(row['validator'] == dict(cgr_physical_cells_upper=2, htb_cells=0, buckets_each=16,
                                  vector_width_upper=4, variant_position_list_upper=8), 'validator source projection')

constant = sum(n*w for n,w in zip(owners,wire)) + 250578
symbolic_constant = sum(n*(w-t) for n,w,t in zip(owners,wire,tau)) + 250578
check(constant == result['server_retained_tau_constant'] == 726339, 'direct server constant')
check(symbolic_constant == result['server_symbolic_tau_constant'] == 699393, 'symbolic TMPDIR constant')
check(sum(owners) == 459 and sum(3*g for g in roots) == 354, 'distinct owner envelopes')

# Closed form for the accepted recurrence b[k+1]=2*b[k]+2048,
# b[0]=1024. This independently checks every new evaluated request operand.
for row in result['receive_operand_evaluations']:
    a = row['adapter_bytes']
    for w, m, b in zip(wire, row['request_lengths'], row['receive_capacities']):
        need = a+w+1023
        exponent = max(0, ((need+2048+3071)//3072-1).bit_length())
        closed = 3072*(1 << exponent)-2048
        check(m == a+w and need <= 2**31-1, 'receive request input')
        check(b == closed >= need, 'receive closed form')
        check(exponent == 0 or 3072*(1 << (exponent-1))-2048 < need, 'minimal sufficient backing')
        check(2*(b+1024) <= 2**64-1, 'attempted receive growth')

audit = dict(status='pass', author_commit=inputs['author_commit'], checks=checks,
             author_files=len(inputs['author_files']), providers=len(manifest['providers']),
             complete_source_members=members_count, source_spans=spans_count,
             verdict='accepted selected successful-startup continuation; whole #153/#119 remain open',
             new_material_findings=[], predecessor_checker_replays=0, native_runs=0,
             elapsed_seconds=round(time.perf_counter()-START, 6),
             audit_code=identity(Path(__file__).read_bytes()), inputs=identity((HERE/'inputs.json').read_bytes()))
(HERE / 'audit-result.json').write_text(json.dumps(audit, indent=2)+'\n')
print(json.dumps(audit, indent=2))
