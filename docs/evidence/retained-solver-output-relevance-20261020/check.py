#!/usr/bin/env python3
"""Offline source identity, excerpt and affine-interface check; no tool runs."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
CVC = 'docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz'
DRV = 'docs/evidence/retained-producer-response-20261018/sources.tar.gz'
OVR = 'docs/evidence/retained-producer-prefix-per-check-20261018/observations.tar.gz'
CP = 'cvc5-86cecd83b685f59e884094693b9a4c5c90a62e03/src/'
DP = 'installed/libexec/spark/share/why3/drivers/'

SPEC = {
    WHY: {
        'why3/src/server/server-unix.c': [(389, 398), (434, 499), (505, 544), (575, 581)],
        'why3/src/util/sysutil.ml': [(29, 38)],
        'why3/src/driver/call_provers.ml': [(150, 173), (233, 247), (259, 338), (342, 402), (478, 499), (543, 560)],
        'why3/src/session/controller_itp.ml': [(448, 491), (592, 617)],
        'why3/src/gnat/gnat_checks.ml': [(805, 826), (961, 971), (1055, 1079)],
        'why3/src/gnat/gnat_main.ml': [(95, 114), (270, 290), (355, 360)],
        'why3/src/gnat/gnat_report.ml': [(34, 46), (185, 234)],
    },
    CVC: {
        CP + 'main/command_executor.cpp': [(81, 115)],
        CP + 'options/base_options.toml': [(4, 13), (83, 117)],
        CP + 'options/managed_streams.cpp': [(75, 85), (101, 119)],
    },
    DRV: {DP + 'smt-libv2.gen': [(19, 24)]},
    OVR: {
        'overlay/cvc5_gnatprove.drv': [(1, 12)],
        'overlay/silver_cvc5_no_steps.gen': [(1, 45)],
    },
}


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def run(write):
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in inputs['files'].items():
        assert ident((ROOT / name).read_bytes()) == expected, name
    witnesses = []
    sources = {}
    for archive, members in SPEC.items():
        with tarfile.open(ROOT / archive) as tar:
            for member, ranges in members.items():
                data = tar.extractfile(member).read()
                source = data.decode()
                sources[member] = source
                lines = source.splitlines()
                witnesses.append({
                    'archive': archive, 'member': member, **ident(data),
                    'excerpts': [{'first': lo, 'last': min(hi, len(lines)),
                                  'text': '\n'.join(lines[lo - 1:hi]) + '\n'}
                                 for lo, hi in ranges],
                })
    call = sources['why3/src/driver/call_provers.ml']
    assert 'let out = read_and_delete_file outfile in' in call
    assert 'let result_list = Re.Str.full_split re out in' in call
    assert 'List.map handle_answer (read_answers ~blocking)' in call
    assert 'pr_output = out;' in call
    assert 'Option.value ~default:(-1) (grep_steps out res_parser.prp_stepregexps)' in call
    assert 'Option.value ~default:(time) (grep_time out res_parser.prp_timeregexps)' in call
    assert 'Unknown (s1 ^ " + " ^ s2)' in call
    for member in ['overlay/cvc5_gnatprove.drv', 'overlay/silver_cvc5_no_steps.gen']:
        assert not re.search(r'^steps\s', sources[member], re.M), member
        assert not re.search(r'^time\s', sources[member], re.M), member
    assert 'import "silver_cvc5_no_steps.gen"' in sources['overlay/cvc5_gnatprove.drv']
    assert 'time "why3cpulimit time : %s s"' in sources[DP + 'smt-libv2.gen']
    assert 'unknown "^(error' in sources['overlay/silver_cvc5_no_steps.gen']
    assert sources[CP + 'main/command_executor.cpp'].count('if (d_solver->getOptionInfo("stats").boolValue())') == 2
    # Both expressions are affine; constant and all unit coefficients suffice.
    keys = ['R', 'G', 'A', 'Nx', 'Ox', 'Wo', 'Lo', 'D', 'H']
    checks = []
    for active in [None] + keys:
        x = {k: int(k == active) for k in keys}
        R, G, A, Nx, Ox, Wo, Lo, D, H = (x[k] for k in keys)
        S, K, LT = 5 * R, 26, 1051
        LA = 64 * A + 4 * Ox
        W = Ox + Nx + Wo + D
        LW = 514 * Ox + 512 * Nx + Lo + H
        b = 212 + 987*R + 549*S + 189*G + 489*A + 321*K + 3*W + 6*(LA+LT+LW)
        e = 81 + 358*R + 79*S + 73*G + 66*A + 5*K + 3*W + 2*(LA+LT+LW)
        assert b == 14864 + 3732*R + 189*G + 873*A + 3075*Nx + 3111*Ox + 3*Wo + 6*Lo + 3*D + 6*H
        assert e == 2313 + 753*R + 73*G + 194*A + 1027*Nx + 1039*Ox + 3*Wo + 2*Lo + 3*D + 2*H
        checks.append({'basis': active or 'constant', 'bytes': b, 'events': e})
    assert 47 + len(' + ') + len('Unknown ()') == 60
    assert len('Failure (interrupted)') < 64
    result = {
        'author_base': inputs['author_base'],
        'note': ident((ROOT / 'docs/research/retained-solver-output-relevance.md').read_bytes()),
        'input_files_checked': len(inputs['files']), 'source_files_checked': len(witnesses),
        'affine_basis_checks': checks,
        'clean_exact_pair': {'raw_bytes_upper': 84, 'formatted_answer_bytes_upper': 64,
                             'consecutive_answer_warnings': 0,
                             'ordinary_nonsignaled_termination': True,
                             'exit_zero_required': False,
                             'requires_selected_task_to_response_relation': True},
        'queued_cancellation': {'raw_file_bytes': 0, 'formatted_answer_bytes_upper': 64},
        'complete_q': None, 'actual_clean_attempt_count': None, 'complete_O': None,
        'observation_only_reclassification': False,
        'global_suffix_budget': {'save_entering_callbacks': 2, 'save_attempts': 3, 'e_upper': 2},
        'native_solver_proof_capture_runs': 0,
        'limitations': ['Source identity and displayed affine algebra only; no OCaml/C++ execution or reachability proof.',
                       'No producer semantic-acceptance, complete output, capacity-rule or automatic-discharge theorem.'],
    }
    for name, value in [('source-witnesses.json', witnesses), ('result.json', result)]:
        expected = canonical(value)
        if write:
            (HERE / name).write_text(expected)
        else:
            assert (HERE / name).read_text() == expected, name
    print(f"checked {len(inputs['files'])} inputs, {len(witnesses)} source files, {len(checks)} affine bases; whole q/O remain null")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)
