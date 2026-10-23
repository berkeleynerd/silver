#!/usr/bin/env python3
"""Author-only pin preparation; check.py validates the frozen pins."""
from pathlib import Path
import hashlib
import json
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
LIBS = 'docs/evidence/retained-producer-import-context-20261018/sources.tar.gz'

def ident(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}

def dump(n, d):
    (HERE/n).write_text(json.dumps(d, indent=2, sort_keys=True)+'\n')

providers = [WHY, OCAML, LIBS, 'docs/trusted-boundary.md']
notes = ['retained-combined-parallel-startup', 'retained-parallel-logging-prefix',
         'retained-why-initial-registration-bound', 'retained-why-parallel-state-attachment',
         'retained-why-path-library-origins', 'retained-why-library-constructors',
         'retained-why-printer-demand', 'retained-why-callback-demand',
         'retained-why-model-meta-control', 'retained-why-native-effect-completeness',
         'retained-why-save-hashtbl-prefix', 'retained-why-printer-name-tables',
         'retained-why-report-path-inputs', 'retained-why-library-probe-paths']
providers += ['docs/research/'+n+'.md' for n in notes]
packets = {
    'retained-combined-parallel-startup-20261020': ['projection.json', 'inputs.json'],
    'retained-parallel-logging-prefix-20261020': ['input-role-projection.json'],
    'retained-why-report-path-inputs-20261023': ['projection.json', 'library-projection.json', 'inputs.json'],
    'retained-why-diagnostic-warnings-20261023': ['library-projection.json'],
    'retained-why-save-hashtbl-prefix-20261020': ['inputs.json', 'native-bodies.json', 'native-witnesses.json', 'check-result.json']}
providers += ['docs/evidence/'+p+'/'+f for p, fs in packets.items() for f in fs]
inputs = {p: ident((ROOT/p).read_bytes()) for p in providers}
specs = {
    'why3/src/util/loc.ml': [(13,30), (42,115), (254,298), (343,360)],
    'why3/src/util/loc.mli': [(25,100)],
    'why3/src/util/wstdlib.ml': [(13,32)],
    'why3/src/util/exthtbl.ml': [(38,50)],
    'why3/src/util/lexlib.mll': [(18,31), (131,145)],
    'why3/src/parser/lexer.mll': [(59,73), (257,279)],
    'why3/src/parser/parser_common.mly': [(18,39)],
    'why3/src/parser/parser.mly': [(66,98)],
    'why3/src/parser/typing.ml': [(258,261), (1756,1770)],
    'why3/src/core/ident.ml': [(380,423)],
    'why3/plugins/gnat_json/gnat_ast_to_ptree.ml': [(57,66), (229,257)],
    'why3/plugins/gnat_json/ptree_constructors.ml': [(10,20)],
    'why3/src/parser/mlw_printer.ml': [(20,28), (73,83)],
    'why3/src/transform/args_wrapper.ml': [(434,445)],
    'why3/src/parser/sexp_parser.ml': [(12,24)],
    'why3/src/session/session_itp.ml': [(1838,1850)]}
rows = []
for ar, items in [(WHY, specs), (OCAML, {'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/hashtbl.ml': [(20,40), (64,76), (115,152), (340,405), (477,488)]})]:
    with tarfile.open(ROOT/ar) as t:
        for name, spans in items.items():
            data = t.extractfile(name).read()
            lines = data.decode().splitlines(keepends=True)
            rs = []
            for lo, hi in spans:
                assert 1 <= lo <= hi <= len(lines), (name, lo, hi, len(lines))
                rs.append({'start': lo, 'end': hi, 'identity': ident(''.join(lines[lo-1:hi]).encode())})
            rows.append({'archive': ar, 'member': name, 'identity': ident(data), 'ranges': rs})
pattern = re.compile(r'\b(?:FileTags|get_file_tag|tag_counter|user_position|position_of_sexp)\b|\bLoc\.extract\b|\b(?:open|include)\s+(?:Why3\.)?Loc\b|\bmodule\s+\w+\s*=\s*(?:Why3\.)?Loc\b')
census = []
count = 0
with tarfile.open(ROOT/WHY) as t:
    for inf in t.getmembers():
        if inf.isfile() and inf.name.startswith(('why3/src/', 'why3/plugins/')) and Path(inf.name).suffix in {'.ml', '.mli', '.mll', '.mly'}:
            count += 1
            data = t.extractfile(inf).read()
            hits = [{'line': i, 'text': line} for i, line in enumerate(data.decode().splitlines(), 1) if pattern.search(line)]
            if hits:
                census.append({'member': inf.name, 'identity': ident(data), 'hits': hits})
dump('inputs.json', inputs)
dump('source-ranges.json', rows)
dump('census-baseline.json', {'source_files_scanned': count, 'files': census})
print({'provider_files': len(inputs), 'source_members': len(rows),
       'source_ranges': sum(len(r['ranges']) for r in rows),
       'census_files': count, 'matching_files': len(census)})
