"""Freeze source excerpts and existing providers for the new printer cut."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2) + '\n')


SECTIONS = {
    'driver/driver.ml': [(391, 408)],
    'core/printer.ml': [(70, 130), (280, 345), (411, 435), (518, 563)],
    'printer/smtv2.ml': [(23, 224), (228, 321), (344, 719), (736, 1100)],
    'printer/cntexmp_printer.ml': [(13, 142)],
    'transform/discriminate.ml': [(475, 505)],
    'core/ident.ml': [(160, 220), (230, 302)],
    'core/term.ml': [(30, 90), (125, 188), (570, 603), (637, 698), (739, 833), (1178, 1209), (1284, 1299)],
    'core/ty.ml': [(120, 172), (236, 254)],
    'core/decl.ml': [(38, 82)],
    'core/task.ml': [(110, 160), (232, 260)],
    'util/debug.ml': [(13, 80)],
}


def main():
    archive = EV / 'retained-why-session-helper-source-20261019/sources.tar.gz'
    sources = {}
    with tarfile.open(archive) as tf:
        for path, sections in SECTIONS.items():
            member = 'why3/src/' + path
            data = tf.extractfile(member).read()
            lines = data.decode().splitlines(keepends=True)
            sources[path] = dict(member=member, **identity(data), sections=[
                {'first': lo, 'last': min(hi, len(lines)), 'text': ''.join(lines[lo-1:hi])}
                for lo, hi in sections])
    dump('source-witnesses.json', {'archive': str(archive.relative_to(ROOT)),
                                 'archive_identity': identity(archive.read_bytes()),
                                 'why3_revision': '9390baf120ef260547dfa14f08e11c890b203d9c',
                                 'sources': sources})
    names = [
        'docs/research/retained-why-printer-entry.md',
        'docs/reviews/review-printer-entry-20261023.md',
        'docs/evidence/retained-why-printer-entry-20261020/result.json',
        'docs/research/retained-why-debug-formatter-control.md',
        'docs/evidence/retained-why-debug-formatter-control-20261020/result.json',
        'docs/research/retained-why-model-meta-control.md',
        'docs/evidence/retained-why-model-meta-control-20261020/result.json',
        'docs/research/retained-cvc5-task-acceptance.md',
        'docs/evidence/retained-cvc5-task-acceptance-20261020/result.json',
        'docs/reviews/review-printer-syntax-20261023.md',
    ]
    for case in ('put-line', 'put', 'first-or-default', 'is-message', 'input-is-valid'):
        names += ['docs/evidence/retained-why-postinline-preparation-20261020/' + case + '-inventory.json',
                  'docs/evidence/retained-why-printer-entry-20261020/' + case + '-inventory.json']
    names += [str(p.relative_to(ROOT)) for p in sorted((EV / 'retained-printer-syntax-review-20261023').glob('*')) if p.is_file()]
    dump('inputs.json', {'providers': {name: identity((ROOT / name).read_bytes()) for name in names},
                         'live_lead_model': None, 'live_lead_effort': None,
                         'policy_lead_baseline': 'GPT-6 Astra / Extra High',
                         'runtime_setting_confirmation': None,
                         'source_argument_machine_checked': False})


if __name__ == '__main__':
    main()
