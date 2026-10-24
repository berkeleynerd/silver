#!/usr/bin/env python3
"""Freeze only retained source/provider bytes for the new cut restriction."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


WHY = 'docs/evidence/retained-producer-prefix-composition-20261018/sources.tar.gz'
OCAML = 'docs/evidence/retained-producer-prefix-gc-20261018/sources.tar.gz'
NATIVE = 'docs/evidence/retained-producer-prefix-gc-20261018/observations.tar.gz'
members = {
    WHY: {
        'src/gnat/gnat_config.ml': [(267,267),(346,401),(552,563),(675,693),(714,768)],
        'src/gnat/gnat_main.ml': [(316,360)],
        'src/gnat/gnat_util.ml': [(101,123)],
        'src/gnat/gnat_checks.ml': [(380,412)],
        'src/session/controller_itp.ml': [(114,137),(271,285)],
        'src/session/session_itp.ml': [(584,637),(1843,1864)],
        'src/core/env.ml': [(41,46),(154,176),(191,228)],
        'src/driver/driver.ml': [(254,280)],
        'src/core/ident.ml': [(29,39),(187,192)],
        'src/core/ty.ml': [(90,122)],
        'src/mlw/ity.ml': [(125,160)],
        'src/core/decl.ml': [(340,419)],
        'src/core/theory.ml': [(214,274)],
        'src/core/task.ml': [(19,29),(88,106)],
        'src/util/hashcons.ml': [(31,55)],
        'src/util/hcpt.ml': [(138,158)],
        'src/util/weakhtbl.ml': [(60,85)],
        'src/transform/introduction.ml': [(33,52),(149,180)],
        'plugins/gnat_json/gnat_ast_to_ptree.ml': [(1382,1410)],
    },
    OCAML: {
        'ocaml/stdlib/weak.ml': [(98,128),(178,264)],
        'ocaml/stdlib/ephemeron.ml': [(127,158),(195,221)],
        'ocaml/stdlib/hashtbl.ml': [(20,80)],
    },
    NATIVE: {
        'success/constructors-static.txt': [(2,24),(110,228)],
        'success/constructors-static-more.txt': [(6,45)],
        'success/attribute-static.txt': [(88,103)],
        'success/installed-constructors.txt': [(39,120)],
        'success/installed-static-inspection.txt': [(1,266)],
    },
}
providers = [
    'docs/research/retained-producer-prefix-gc.md',
    'docs/research/retained-producer-prefix-composition.md',
    'docs/research/retained-combined-parallel-startup.md',
    'docs/research/retained-fixed-failure-composition.md',
    'docs/research/retained-why-initial-registration-bound.md',
    'docs/research/retained-why-path-initial-state.md',
    'docs/research/retained-why-hsattr-demand.md',
    'docs/research/retained-why-shared-demand.md',
    'docs/research/retained-preparation-private-memos.md',
    'docs/evidence/retained-producer-prefix-gc-20261018/result.json',
    'docs/evidence/retained-producer-prefix-gc-20261018/dimensions-result.json',
    'docs/evidence/retained-producer-prefix-gc-20261018/identity.json',
    'docs/evidence/retained-producer-prefix-composition-20261018/review.md',
    'docs/evidence/retained-combined-parallel-startup-20261020/projection.json',
    'docs/evidence/retained-combined-parallel-startup-20261020/inputs.json',
    'docs/evidence/retained-combined-parallel-startup-20261020/check-result.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/configuration-repair.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/paths.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/initial-driver-closure.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/result.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/inputs.json',
    'docs/evidence/retained-fixed-failure-composition-20261023/providers.json',
    'docs/evidence/retained-why-session-save-outcomes-20261019/runtime-limits.json',
    'docs/reviews/review-request-inline-capacity-20261020.md',
    'docs/reviews/review-fixed-failure-composition-20261023.md',
]


def main():
    result = {'base_commit': 'b334e2eb57',
              'why_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
              'ocaml_revision': '8eb41f72ded84df884c3671734c947f612091f84',
              'archives': [], 'providers': []}
    for path, selected in members.items():
        row = {'path': path, **identity((ROOT/path).read_bytes()), 'members': []}
        with tarfile.open(ROOT/path) as archive:
            for name, ranges in selected.items():
                data = archive.extractfile(name).read()
                lines = data.decode().splitlines()
                spans = []
                for first, last in ranges:
                    assert 1 <= first <= last <= len(lines), (name, first, last)
                    text = '\n'.join(lines[first-1:last])+'\n'
                    spans.append({'first': first, 'last': last, **identity(text.encode())})
                row['members'].append({'path': name, **identity(data), 'spans': spans})
        result['archives'].append(row)
    config = ROOT/'docs/evidence/retained-fixed-failure-composition-20261023/configuration'
    paths = providers + [str(p.relative_to(ROOT)) for p in sorted(config.rglob('*')) if p.is_file()]
    for path in paths:
        result['providers'].append({'path': path, **identity((ROOT/path).read_bytes())})
    (HERE/'identity.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({'archives':len(result['archives']),
                      'members':sum(len(x['members']) for x in result['archives']),
                      'spans':sum(len(m['spans']) for x in result['archives'] for m in x['members']),
                      'providers':len(result['providers'])}))


if __name__ == '__main__':
    main()
