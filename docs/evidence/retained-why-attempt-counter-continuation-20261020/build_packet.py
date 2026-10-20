#!/usr/bin/env python3
"""Freeze exact retained sources and input identities; never fetch or execute them."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = HERE.parent
ARCHIVE = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
RANGES = [
    ('session-layout', 'src/session/session_itp.ml', 123, 145),
    ('counter', 'src/session/session_itp.ml', 281, 295),
    ('constructor-handlers', 'src/session/session_itp.ml', 643, 675),
    ('controller-graft-callback', 'src/session/controller_itp.ml', 592, 652),
    ('build-receiving-catch', 'src/session/controller_itp.ml', 413, 440),
    ('done-dispatch', 'src/session/controller_itp.ml', 448, 490),
    ('idle-receiving-catch', 'src/session/controller_itp.ml', 517, 536),
    ('idle-installer', 'src/session/controller_itp.ml', 578, 590),
    ('gnat-result-and-schedule', 'src/gnat/gnat_main.ml', 75, 161),
    ('ordinary-and-signal-exits', 'src/gnat/gnat_main.ml', 269, 309),
    ('initial-main-catch', 'src/gnat/gnat_main.ml', 331, 363),
    ('scheduler', 'src/gnat/gnat_scheduler.ml', 1, 29),
    ('initial-iteration', 'src/gnat/gnat_checks.ml', 506, 510),
    ('register-result-catch', 'src/gnat/gnat_checks.ml', 598, 662),
    ('actual-scheduling', 'src/gnat/gnat_checks.ml', 983, 1084),
    ('observer', 'src/gnat/gnat_checks.ml', 1327, 1332),
    ('timing', 'src/util/debug.ml', 155, 175),
    ('abort', 'src/gnat/gnat_util.ml', 1, 24),
]


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def dump(name, data):
    (HERE / name).write_text(json.dumps(data, indent=2) + '\n')


def main():
    excerpts = []
    with tarfile.open(ROOT / ARCHIVE) as t:
        for name, path, first, last in RANGES:
            member = 'why3/' + path
            raw = t.extractfile(member).read()
            lines = raw.decode().splitlines(keepends=True)
            last = min(last, len(lines))
            text = ''.join(lines[first - 1:last])
            excerpts.append({'id': name, 'archive': ARCHIVE, 'member': member,
                             'member_bytes': len(raw), 'member_sha256': ident(raw)['sha256'],
                             'first': first, 'last': last,
                             'excerpt_sha256': ident(text.encode())['sha256'], 'text': text})
        member = 'why3/src/session/session_itp.ml'
        lines = t.extractfile(member).read().decode().splitlines()
        census = [{'line': i, 'text': line} for i, line in enumerate(lines, 1)
                  if re.search(r'\b(next_proofAttemptID|gen_proofAttemptID|add_proof_attempt|graft_proof_attempt)\b', line)]
    prior = json.loads((E / 'retained-why-ordinary-ending-control-20261020/source-excerpts.json').read_text())
    excerpts.append(next(x for x in prior if x['id'] == 'protect'))
    dump('source-excerpts.json', excerpts)
    dump('source-census.json', {'member': member, 'references': census})
    paths = [ARCHIVE, excerpts[-1]['archive'],
             'docs/evidence/retained-why-session-helper-source-20261019/source-identities.json',
             'docs/evidence/retained-why-save-state-capture-20261020/capture-manifest.json',
             'docs/evidence/retained-why-save-state-join-20261020/result.json',
             'docs/evidence/retained-why-save-attempt-growth-20261020/applications.json',
             'docs/research/retained-producer-driver-envelope.md',
             'docs/research/retained-why-save-attempt-growth.md',
             'docs/research/retained-why-save-hashtbl-prefix.md',
             'docs/research/retained-why-ordinary-ending-control.md',
             'docs/reviews/review-save-state-continuation-20261020.md']
    for case in ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid'):
        for kind in ('correspondence', 'replay'):
            paths.append('docs/evidence/retained-why-save-state-join-20261020/' + case + '-' + kind + '.json')
    dump('inputs.json', {p: ident((ROOT / p).read_bytes()) for p in paths})


if __name__ == '__main__':
    main()
