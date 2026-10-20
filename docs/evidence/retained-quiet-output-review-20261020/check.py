#!/usr/bin/env python3
"""Focused source/finite-language review checks; no solver or OCaml execution."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CVC = 'docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
SPEC = {
    CVC: {
        'src/options/options_handler.cpp': [(161, 222)],
        'src/main/command_executor.cpp': [(81, 115)],
        'src/smt/proof_final_callback.cpp': [(73, 114), (179, 207)],
        'src/api/cpp/cvc5_types.cpp': [(54, 78)],
    },
    WHY: {
        'src/gnat/gnat_config.ml': [(283, 289), (307, 330), (346, 409)],
        'src/driver/call_provers.ml': [(168, 173), (233, 247), (259, 338), (342, 402), (478, 499)],
        'src/server/server-unix.c': [(389, 398), (434, 499), (505, 544)],
        'src/gnat/gnat_checks.ml': [(961, 971)],
    },
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def canonical(obj):
    return json.dumps(obj, indent=2, sort_keys=True) + '\n'


def run(write):
    inputs = json.loads((HERE / 'inputs.json').read_text())
    count = 0
    for group in inputs['freezes']:
        for path, expected in group['files'].items():
            raw = (ROOT / path).read_bytes()
            assert identity(raw) == expected, path
            original = subprocess.check_output(['git', 'show', group['commit'] + ':' + path], cwd=ROOT)
            assert raw == original, path
            count += 1
    for path, expected in inputs['inherited_files'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    sources = {}
    excerpts = []
    for archive, files in SPEC.items():
        with tarfile.open(ROOT / archive) as tar:
            for suffix, ranges in files.items():
                member = next(n for n in tar.getnames() if n.endswith('/' + suffix))
                raw = tar.extractfile(member).read()
                source = raw.decode()
                sources[suffix] = source
                lines = source.splitlines()
                excerpts.append({'archive': archive, 'member': member, **identity(raw),
                                 'excerpts': [{'first': lo, 'last': hi,
                                               'text': '\n'.join(lines[lo-1:hi])+'\n'}
                                              for lo, hi in ranges]})

    proof = sources['src/smt/proof_final_callback.cpp']
    assert 'options().base.statisticsInternal || options().proof.checkProofsComplete' in proof
    assert proof.index('pnm->ensureChecked(pn.get());') < proof.index('if (d_checkProofHoles)')
    assert 'if (!isHandled && options().proof.checkProofsComplete)' in proof
    executor = sources['src/main/command_executor.cpp']
    assert executor.count('if (d_solver->getOptionInfo("stats").boolValue())') == 2
    config = sources['src/gnat/gnat_config.ml']
    assert config.index('read_config (Some Gnat_util.gnatprove_why3conf_file)') < config.index('check_config_for_builtin_provers conf;')
    assert '~load_plugins:(not builtin_provers_only)' in config
    call = sources['src/driver/call_provers.ml']
    for anchor in ['let result_list = Re.Str.full_split re out in',
                   'List.map handle_answer (read_answers ~blocking)',
                   'pr_output = out;',
                   '| (_, Unknown "(not unknown!)")',
                   'Unknown (s1 ^ " + " ^ s2)']:
        # The first alternative shares a line with another pattern in this source.
        assert anchor in call, anchor

    # Finite response arithmetic, independently extracted from the enum printer.
    # This is a calculation on the reviewed language, not a simulation of Re.Str.
    enum = sources['src/api/cpp/cvc5_types.cpp']
    start = enum.index('std::ostream& operator<<(std::ostream& out, UnknownExplanation e)')
    body = enum[start:enum.index('\n}', start)]
    reasons = re.findall(r'out << "([A-Z_]+)";', body)
    assert len(reasons) == len(set(reasons)) == 10
    error = '(error "Can\'t get-info :reason-unknown when the last result wasn\'t unknown!")\n'
    rows = [
        {'kind': 'sat', 'file_bytes': len('sat\n' + error), 'answer_bytes': len('Unknown (sat)')},
        {'kind': 'unsat', 'file_bytes': len('unsat\n' + error), 'answer_bytes': len('Valid')},
    ]
    for reason in reasons:
        r = reason.lower()
        ans = 'Timeout' if r == 'timeout' else 'StepLimitExceeded' if r == 'resourceout' else 'Unknown (unknown + ' + r + ')'
        rows.append({'kind': 'unknown/' + r, 'file_bytes': len('unknown\n(:reason-unknown ' + r + ')\n'),
                     'answer_bytes': len(ans)})
    assert max(r['file_bytes'] for r in rows) == 84
    assert max(r['answer_bytes'] for r in rows) <= 64
    assert len('Failure (interrupted)') <= 64
    result = {'frozen_files_byte_matched': count, 'inherited_inputs_checked': len(inputs['inherited_files']),
              'source_members_checked': len(excerpts), 'finite_response_rows': rows,
              'complete_q': None, 'complete_O': None, 'whole_capacity_goal_complete': False,
              'native_solver_proof_capture_runs': 0,
              'scope': 'Identity, source witnesses and finite-language byte arithmetic; source interpretation reviewed manually. No OCaml/C++ execution or task-to-response proof.'}
    for name, value in [('source-review.json', excerpts), ('result.json', result)]:
        data = canonical(value)
        if write:
            (HERE / name).write_text(data)
        else:
            assert (HERE / name).read_text() == data, name
    print(f'checked {count} frozen files, {len(excerpts)} source members, {len(rows)} finite response cases; complete q/O remain null')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)
