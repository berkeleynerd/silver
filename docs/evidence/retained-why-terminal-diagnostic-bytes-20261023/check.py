#!/usr/bin/env python3
"""Focused retained-source/ELF identity and terminal-bound arithmetic check.

No process under study, compiler, solver, disassembler or predecessor checker
is run. --write freezes this packet; default verifies its stable projections.
The semantic source argument is in the research note, not proved by this script.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
INT = 2**62 - 1
PINF = 1_000_000_010
ELF_REL = Path('.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3')
ELF_SHA = '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368'
INITIAL_FREEZE = '6be9a29ea4490616c4d60723a81e4b1a26e54a0c'
WRAPPER_DEPTH = 2
ARCHIVES = {
    'why': ('docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz',
            '2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749'),
    'ocaml': ('docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
              '04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7'),
}
SPANS = {
    'why': {
        'src/util/exn_printer.ml': [(12, 52)],
        'src/util/loc.ml': [(114, 126), (249, 281), (302, 360)],
        'src/util/sysutil.ml': [(42, 90)],
        'src/util/debug.ml': [(158, 173)],
        'src/core/task.ml': [(362, 377)],
        'src/driver/prove_client.ml': [(13, 57), (207, 261)],
        'src/driver/call_provers.ml': [(101, 129), (168, 174), (206, 247), (604, 618)],
        'src/session/session_itp.ml': [(807, 865), (1566, 1572), (1842, 1849), (2212, 2244)],
        'src/session/controller_itp.ml': [(518, 540), (591, 619)],
        'src/parser/typing.ml': [(1713, 1738)],
        'src/gnat/gnat_checks.ml': [(1060, 1077)],
        'src/gnat/gnat_main.ml': [(330, 360)],
        'src/gnat/gnat_util.ml': [(1, 23)],
    },
    'ocaml': {
        'stdlib/printexc.ml': [(22, 76), (151, 189), (324, 364)],
        'stdlib/fun.ml': [(21, 38)],
        'stdlib/buffer.ml': [(17, 39), (63, 129), (161, 180)],
        'stdlib/filename.ml': [(329, 360)],
        'stdlib/format.ml': [(937, 1008), (1248, 1257), (1387, 1396)],
        'otherlibs/unix/unix.ml': [(89, 172)],
        'otherlibs/unix/unixsupport.c': [(288, 320)],
        'otherlibs/unix/rename.c': [(23, 40)],
        'runtime/sys.c': [(63, 95), (299, 319)],
    },
}
IMPORTS = [
    'docs/research/retained-why-callback-demand.md',
    'docs/research/retained-why-diagnostic-expansion.md',
    'docs/research/retained-why-standard-formatter-core.md',
    'docs/research/retained-why-format-accumulator.md',
    'docs/research/retained-why-printer-output.md',
    'docs/research/retained-why-sexplib-converter-prefix.md',
    'docs/research/retained-why-session-exception-prefix.md',
    'docs/research/retained-adapter-launch-output.md',
    'docs/research/retained-parallel-logging-prefix.md',
    'docs/research/retained-combined-parallel-startup.md',
    'docs/research/retained-shared-server-prefix.md',
    'docs/research/retained-adapter-protocol-storage.md',
    'docs/evidence/retained-solver-request-bytes-20261020/projection.json',
]
RE_DIRS = [
    'docs/evidence/retained-solver-response-adapter-20261020/re-api-source/lib',
    'docs/evidence/retained-response-timing-config-20261020/re-prefix-source/lib',
]
R67_NOTE = 'docs/research/retained-why-format-accumulator.md'
R67_COMMIT = '4364b0bcccfabaad6a843b529879ba6c48eedb2e'


def digest(b):
    return hashlib.sha256(b).hexdigest()


def evaluate(path_bytes, frame_bytes):
    """Conditional interface; providers/premises must be supplied by the join."""
    assert isinstance(path_bytes, int) and path_bytes >= 0
    assert isinstance(frame_bytes, int) and frame_bytes >= 0
    s = max(467, path_bytes + 51, frame_bytes + 23, 256)
    k = 467 + 12 * s + 256
    t = 0
    for _ in range(WRAPPER_DEPTH + 1):
        t = 4 * t + 8 * k + 65536
    assert t == 21 * (8 * k + 65536)
    x = t + 1024
    e = 320 * (2**(WRAPPER_DEPTH + 1) - 1) + 16
    length = x + e
    insertion = 3 * e + 2
    tc = PINF + length + 1
    guards = {
        'core_sentinel': length + 79 <= PINF,
        'core_scan_arithmetic': (3 * e + 1) * tc + length + 79 <= INT,
        'core_counts': 4 * insertion + 2 <= INT,
        'buffer_double_and_string': 2 * max(512, x) <= 2**57 - 9,
    }
    return {
        'P': path_bytes, 'M': frame_bytes, 'S': s, 'K': k,
        'Y_single_dispatch': t, 'x_abort_each': x,
        'X_abort_payload_sum': 2 * x,
        'direct_terminal_stderr_bytes': 2 * t + 253,
        'principal_private_events_per_outer': e,
        'principal_private_bytes_all_four_outers': 4 * x,
        'principal_private_events_all_four_outers': 4 * e,
        'guards': guards,
        'conditional_numeric_interface_passes': all(guards.values()),
        'actual_joined_claim': False,
    }


def freeze(name, obj, write):
    text = json.dumps(obj, indent=2, sort_keys=True) + '\n'
    p = HERE / name
    if write:
        p.write_text(text)
    else:
        assert p.read_text() == text, f'stale {name}'


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--write', action='store_true')
    p.add_argument('--elf', type=Path)
    p.add_argument('--reuse-native-evidence', action='store_true',
                   help='reuse exact initial-freeze ASCII/ELF evidence; do not reread ELF')
    args = p.parse_args()
    start = time.monotonic()
    if args.reuse_native_evidence:
        retained_path = (HERE / 'result.json').relative_to(ROOT).as_posix()
        retained = json.loads(subprocess.check_output(
            ['git', 'show', f'{INITIAL_FREEZE}:{retained_path}'], cwd=ROOT))
        assert retained['elf_sha256'] == ELF_SHA
        assert retained['static_resident_ascii_cap'] == 467
        elf_bytes = retained['elf_bytes']
        ascii_offset = retained['largest_ascii_run_offset']
        ascii_sha = retained['largest_ascii_run_sha256']
        literal_witnesses = retained['literal_witnesses']
    else:
        elf = args.elf
        if elf is None:
            elf = next((r / ELF_REL for r in (ROOT, *ROOT.parents)
                        if (r / ELF_REL).exists()), None)
        assert elf is not None, 'supply --elf for the retained installed ELF'
        b = elf.read_bytes()
        assert digest(b) == ELF_SHA
        best = max(re.finditer(rb'[\x09\x0a\x0d\x20-\x7e]+', b),
                   key=lambda m: len(m[0]))
        assert len(best[0]) == 467
        elf_bytes, ascii_offset, ascii_sha = len(b), best.start(), digest(best[0])
        # Illustrative resident literals, not an exhaustive pointer-origin proof.
        needles = [b'Buffer.add: cannot grow buffer', b'int_of_string',
                   b'float_of_string', b'Invalid server answer: %s',
                   b'Str.replace: illegal backslash sequence',
                   b'Str.group_beginning', b'Out of memory', b'Stack overflow']
        literal_witnesses = []
        for needle in needles:
            pos = b.find(needle)
            assert pos >= 0, needle
            literal_witnesses.append({'bytes': len(needle),
                                     'text': needle.decode('ascii'),
                                     'elf_offset': pos})
    identities = {}
    witnesses = []
    for family, (name, sha) in ARCHIVES.items():
        ap = ROOT / name
        assert digest(ap.read_bytes()) == sha
        identities[name] = sha
        with tarfile.open(ap) as tf:
            members = tf.getmembers()
            for suffix, ranges in SPANS[family].items():
                matches = [m for m in members if m.isfile() and
                           (m.name == suffix or m.name.endswith('/' + suffix))]
                assert len(matches) == 1, (suffix, [m.name for m in matches])
                raw = tf.extractfile(matches[0]).read()
                lines = raw.decode().splitlines(keepends=True)
                for first, last in ranges:
                    assert 1 <= first <= last <= len(lines), (suffix, first, last, len(lines))
                    text = ''.join(lines[first-1:last])
                    witnesses.append({'archive': name, 'member': matches[0].name,
                                      'member_sha256': digest(raw),
                                      'start': first, 'end': last, 'text': text,
                                      'span_sha256': digest(text.encode())})
    for name in IMPORTS:
        if name == R67_NOTE:
            frozen = subprocess.check_output(
                ['git', 'show', f'{R67_COMMIT}:{name}'], cwd=ROOT)
            if (ROOT / name).exists():
                assert (ROOT / name).read_bytes() == frozen
            identities[name] = digest(frozen)
        else:
            identities[name] = digest((ROOT / name).read_bytes())
    re_errors = []
    for dirname in RE_DIRS:
        for rp in sorted((ROOT / dirname).glob('*.ml')):
            name = rp.relative_to(ROOT).as_posix()
            raw = rp.read_bytes()
            identities[name] = digest(raw)
            for number, line in enumerate(raw.decode().splitlines(), 1):
                if re.search(r'\b(exception|raise|failwith|invalid_arg|assert)\b', line):
                    re_errors.append({'file': name, 'line': number, 'text': line})
    proj = json.loads((ROOT / IMPORTS[-1]).read_text())
    paths = {}
    for domain, data in proj['domains'].items():
        paths[domain] = {
            'retained_TMPDIR_bytes': data['recorded_TMPDIR_bytes'],
            'request_path_upper': data['recorded_TMPDIR_bytes'] +
                max(v['task_path_bytes']['constant'] for v in data['provers'].values()),
            'requires_combined_shared_prefix_preservation': True,
        }
    example = evaluate(416, 444)
    assert example['conditional_numeric_interface_passes']
    assert example['X_abort_payload_sum'] == 4_880_432
    assert sum(len(s) for s in [
        'Fatal error: exception \n',
        'Fatal error in uncaught exception handler: exception \n',
        'Fatal error: out of memory in uncaught exception handler\n']) + 2 * 59 == 253
    result = {
        'scope': 'conditional post-registration scalar terminal family',
        'actual_joined_exports': None,
        'remaining_inputs': ['actual P provider', 'actual Pc=R+24 and M=Pc+48',
                             'named source/native/service/proxy premises'],
        'static_resident_ascii_cap': 467,
        'elf_sha256': ELF_SHA, 'elf_bytes': elf_bytes,
        'largest_ascii_run_offset': ascii_offset,
        'largest_ascii_run_sha256': ascii_sha,
        'literal_witnesses': literal_witnesses,
        'wrapper_depth_upper': WRAPPER_DEPTH, 'dispatch_packages_per_outer': 7,
        'why_passes_per_outer': 14, 'why_candidates_per_outer': 770,
        'printexc_calls_per_outer': 7, 'printexc_candidates_per_outer': 35,
        'refines_initial_d3_freeze': INITIAL_FREEZE,
        'outer_diagnostic_calls': 4, 'abort_json_attempts': 2,
        'normal_json_attempts': 1,
        'request_path_inputs': paths,
        'configuration_range_example_only': example,
        'source_spans': len(witnesses),
        'R67_note_frozen_commit': R67_COMMIT,
        'native_execution': False, 'new_disassembly': False,
        'predecessor_checker_replay': False,
        'complete_capacity_or_admission': False,
    }
    freeze('inputs.json', identities, args.write)
    freeze('source-witnesses.json', witnesses, args.write)
    freeze('re-error-census.json', re_errors, args.write)
    freeze('result.json', result, args.write)
    print(json.dumps({'ok': True, 'elapsed_seconds': time.monotonic() - start,
                      'spans': len(witnesses), 'identity_inputs': len(identities),
                      'conditional_example_X_sum': example['X_abort_payload_sum'],
                      'native_evidence_reused': args.reuse_native_evidence,
                      'actual_joined_exports': None}, sort_keys=True))


if __name__ == '__main__':
    main()
