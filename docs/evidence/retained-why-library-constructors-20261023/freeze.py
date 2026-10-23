"""Freeze exact source excerpts and input identities for this bounded packet."""
import hashlib
import json
import re
import tarfile
from compose import HERE, ROOT

ARCHIVE = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
SPANS = {
    'why3/src/core/ident.ml': [(185, 225)],
    'why3/src/core/ty.ml': [(16, 33), (50, 88), (90, 104), (116, 135), (159, 172), (183, 217), (234, 254), (278, 292)],
    'why3/src/core/term.ml': [(17, 39), (43, 85), (735, 873), (874, 894), (1037, 1057), (1085, 1173), (1282, 1295), (1483, 1508), (1669, 1714)],
    'why3/src/core/dterm.ml': [(606, 723)],
    'why3/src/core/theory.ml': [(268, 272), (549, 580), (593, 611), (954, 963), (976, 995), (1028, 1054)],
    'why3/src/mlw/ity.ml': [(19, 86), (182, 185), (543, 592), (743, 757), (768, 798), (900, 939), (1196, 1236), (1293, 1315), (1334, 1434), (1436, 1575)],
    'why3/src/mlw/expr.ml': [(19, 35), (46, 58), (98, 171), (173, 221), (524, 525), (552, 735), (781, 850), (941, 946), (957, 963), (1191, 1310)],
    'why3/src/mlw/pdecl.ml': [(379, 386), (452, 506), (531, 638), (683, 687)],
    'why3/src/mlw/pmodule.ml': [(50, 117), (221, 243), (278, 290), (353, 378), (481, 486), (527, 569),
        (604, 615), (739, 833), (902, 956), (1031, 1082), (1349, 1377), (1450, 1485), (1491, 1505), (1590, 1634)],
    'why3/src/parser/typing.ml': [(277, 285), (698, 826), (932, 963), (1230, 1234), (1495, 1580), (1675, 1705), (1895, 1905)],
    'why3/src/mlw/dexpr.ml': [(957, 960), (1176, 1192), (1309, 1327), (1406, 1530), (1550, 1571), (1610, 1640), (1732, 1790)],
    'why3/src/parser/lexer.mll': [(108, 115)],
    'why3/src/util/lexlib.mll': [(82, 96)],
    'why3/src/core/pattern.ml': [(16, 163)],
    'why3/src/util/exthtbl.ml': [(40, 50)],
    'why3/src/util/weakhtbl.ml': [(66, 87)],
}
INPUTS = [
    'docs/research/retained-why-library-publication-bound.md',
    'docs/research/retained-why-path-library-origins.md',
    'docs/research/retained-why-initial-registration-bound.md',
    'docs/research/retained-why-path-initial-state.md',
    'docs/evidence/retained-why-library-publication-bound-20261020/bound.json',
    'docs/evidence/retained-why-library-publication-bound-20261020/source-witness.json',
    'docs/evidence/retained-why-shared-demand-20261020/attachment.json',
]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def sources():
    out = []
    with tarfile.open(ROOT / ARCHIVE) as archive:
        for member, spans in SPANS.items():
            raw = archive.extractfile(member).read()
            lines = raw.splitlines(keepends=True)
            for first, last in spans:
                assert 1 <= first <= last <= len(lines), (member, first, last, len(lines))
                excerpt = b''.join(lines[first-1:last])
                out.append(dict(archive=ARCHIVE, member=member, first_line=first,
                    last_line=last, member_identity=identity(raw),
                    excerpt_identity=identity(excerpt), excerpt=excerpt.decode()))
    # Core decl/Hashcons implementations are in the accepted core archive.
    other = 'docs/evidence/retained-why-inline-operations-20261018/sources.tar.gz'
    with tarfile.open(ROOT / other) as archive:
        for member, spans in {
            'why3/src/core/decl.ml': [(30, 105), (120, 275), (388, 419), (462, 507), (524, 550)],
            'why3/src/util/hashcons.ml': [(31, 50)],
        }.items():
            raw = archive.extractfile(member).read()
            lines = raw.splitlines(keepends=True)
            for first, last in spans:
                assert 1 <= first <= last <= len(lines), (member, first, last, len(lines))
                excerpt = b''.join(lines[first-1:last])
                out.append(dict(archive=other, member=member, first_line=first,
                    last_line=last, member_identity=identity(raw),
                    excerpt_identity=identity(excerpt), excerpt=excerpt.decode()))
    other = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
    member = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/ephemeron.ml'
    with tarfile.open(ROOT / other) as archive:
        raw = archive.extractfile(member).read()
        lines = raw.splitlines(keepends=True)
        for first, last in [(195, 221), (242, 268), (315, 334), (527, 551)]:
            assert 1 <= first <= last <= len(lines), (member, first, last, len(lines))
            excerpt = b''.join(lines[first-1:last])
            out.append(dict(archive=other, member=member, first_line=first,
                last_line=last, member_identity=identity(raw),
                excerpt_identity=identity(excerpt), excerpt=excerpt.decode()))
    return out


def restore_census():
    members, references, private_exports = [], [], []
    names = r'\b(restore_its|restore_rs|restore_pv|rs_of_ls|mk_rs|mk_its|cty_apply)\b'
    with tarfile.open(ROOT / ARCHIVE) as archive:
        for entry in archive.getmembers():
            if not entry.isfile() or not entry.name.endswith(('.ml', '.mli', '.mll', '.mly')):
                continue
            raw = archive.extractfile(entry).read()
            members.append(dict(member=entry.name, **identity(raw)))
            for line, text in enumerate(raw.decode().splitlines(), 1):
                if re.search(names, text):
                    references.append(dict(member=entry.name, line=line, text=text))
                if entry.name.endswith('.mli') and re.search(r'\bval\s+(rs_of_ls|mk_rs|mk_its)\b', text):
                    private_exports.append(dict(member=entry.name, line=line, text=text))
        fields = {}
        for member in ['why3/src/mlw/ity.ml', 'why3/src/mlw/expr.ml']:
            lines = archive.extractfile(member).read().decode().splitlines()
            fields[member] = [dict(line=i+1, text=line) for i, line in enumerate(lines)
                if re.match(r'^\s*mutable\s+\w+\s*:', line)]
    return dict(source_members=members, references=references,
        private_helper_exports=private_exports, mutable_record_fields=fields,
        census_is_not_reachability_proof=True,
        physical_restore_association_requires_prefix_before_first_ident_wrap=True,
        unconditional_no_foreign_body_claim=False)


def inputs():
    paths = INPUTS + [str(p.relative_to(ROOT)) for p in sorted(
        (ROOT / 'docs/evidence/retained-why-fixed-inline-family-20261020').glob('*-family.json'))]
    return dict(base='0e17e4a87440fc6d5b4d87fb5fe384ce6ae3f1ae',
        why3_revision='9390baf120ef260547dfa14f08e11c890b203d9c',
        files={p: identity((ROOT / p).read_bytes()) for p in paths})


if __name__ == '__main__':
    for name, obj in [('source-witnesses.json', sources()), ('inputs.json', inputs()),
                      ('restore-census.json', restore_census())]:
        (HERE / name).write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')
