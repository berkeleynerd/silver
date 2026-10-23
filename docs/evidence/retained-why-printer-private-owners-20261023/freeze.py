"""Freeze retained providers/source, without executing their checkers or models."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
OP = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/'

def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}

def main():
    providers = [
        'docs/research/retained-tool-source-identity.md',
        'docs/research/retained-why-printer-entry.md',
        'docs/reviews/review-printer-entry-20261023.md',
        'docs/evidence/retained-why-printer-entry-20261020/result.json',
        'docs/research/retained-why-printer-demand.md',
        'docs/reviews/review-printer-demand-20261023.md',
        'docs/reviews/review-printer-syntax-20261023.md',
        'docs/evidence/retained-why-printer-demand-20261023/result.json',
        'docs/research/retained-why-printer-name-tables.md',
        'docs/reviews/review-printer-name-tables-20261023.md',
        'docs/evidence/retained-why-printer-name-tables-20261023/result.json',
        'docs/research/retained-why-raw-name-length.md',
        'docs/evidence/retained-why-raw-name-length-20261023/result.json',
        'docs/research/retained-why-hsattr-demand.md',
        'docs/evidence/retained-why-hsattr-demand-20261023/result.json',
        'docs/reviews/review-name-attribute-bounds-20261023.md',
        'docs/research/retained-why-printer-output.md',
        'docs/evidence/retained-why-printer-output-20261023/result.json',
        'docs/evidence/retained-why-printer-output-20261023/census.json',
        'docs/reviews/review-printer-output-20261023.md',
        'docs/research/retained-why-save-hashtbl-prefix.md',
        'docs/evidence/retained-why-save-hashtbl-prefix-20261020/native-witnesses.json',
        'docs/research/retained-why-model-meta-control.md',
        'docs/research/retained-why-debug-formatter-control.md',
        'docs/research/retained-why-native-effect-completeness.md',
        'docs/research/retained-why-ordinary-ending-control.md',
    ]
    ranges = {
        WHY: {
            'why3/src/printer/smtv2.ml': [(200,318),(344,356),(359,545),(547,640),(654,739),(770,931),(959,1075)],
            'why3/src/printer/cntexmp_printer.ml': [(16,138)],
            'why3/src/core/printer.ml': [(76,123),(148,218),(224,228),(288,382),(411,429),(499,561)],
            'why3/src/transform/discriminate.ml': [(489,499)],
            'why3/src/core/task.ml': [(225,237),(283,289),(337,347)],
            'why3/src/core/term.ml': [(20,89),(404,418),(594,624),(648,675),(739,831),(1177,1209),(1284,1299)],
            'why3/src/core/decl.ml': [(60,67),(442,446),(518,524),(610,617)],
            'why3/src/core/ty.ml': [(153,172)],
            'why3/src/core/ident.ml': [(14,39),(156,219),(370,414)],
            'why3/src/util/wstdlib.ml': [(11,30),(60,99)],
            'why3/src/util/extmap.ml': [(97,211),(215,352),(391,436),(495,533)],
            'why3/src/util/extset.ml': [(56,101)],
            'why3/src/util/util.ml': [(34,59)],
            'why3/src/util/exthtbl.ml': [(38,65)],
            'why3/src/util/strings.ml': [(60,81)],
            'why3/src/util/number.ml': [(167,194)],
            'why3/src/driver/driver.ml': [(391,404),(456,474)],
        },
        OCAML: {
            OP+'set.ml': [(72,143),(195,265)],
            OP+'array.ml': [(151,163)],
            OP+'list.ml': [(21,25)],
            OP+'hashtbl.ml': [(21,76),(115,152),(344,409),(431,454),(477,488)],
        },
    }
    manifest = {
        'base_commit': '75ac621aeb9f28ea5abbf512e95a99f2e714acbd',
        'accepted_R65_integration': '5a3869c76a6ae13db8781172c688df19475be25f',
        'accepted_name_attribute_review': '2533c4962814cc85cda0e76462819d5e16525b30',
        'accepted_R66_author': 'b5aad6d57b2f215ac047edb931314812c6687905',
        'accepted_R66_review': '32fdc06f27eeb71ac29d4c861d74f3a3af2bd6b1',
        'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
        'ocaml_revision': '8eb41f72ded84df884c3671734c947f612091f84',
        'files': {p: identity((ROOT/p).read_bytes()) for p in providers},
        'archives': {p: identity((ROOT/p).read_bytes()) for p in ranges},
    }
    witnesses = []
    for archive, members in ranges.items():
        with tarfile.open(ROOT/archive) as tf:
            for member, spans in members.items():
                b = tf.extractfile(member).read()
                lines = b.decode().splitlines(keepends=True)
                assert all(1 <= a <= z <= len(lines) for a,z in spans)
                witnesses.append({'archive': archive, 'member': member, 'identity': identity(b),
                    'sections': [{'first':a, 'last':z, 'text':''.join(lines[a-1:z])} for a,z in spans]})
    (HERE/'inputs.json').write_text(json.dumps(manifest, indent=2)+'\n')
    (HERE/'source-witnesses.json').write_text(json.dumps(witnesses, indent=2)+'\n')

if __name__ == '__main__':
    main()
