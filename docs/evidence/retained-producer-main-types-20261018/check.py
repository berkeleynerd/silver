#!/usr/bin/env python3
"""Retained-file and concrete theory-module checks; no native execution."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent


def module(source, name):
    match = re.search(r'^module ' + re.escape(name) + r'\s*$', source, re.M)
    assert match is not None
    following = re.search(r'^module ', source[match.end():], re.M)
    end = len(source) if following is None else match.end() + following.start()
    return source[match.start():end]


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    archive = HERE / 'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity['source_archive_sha256']
    sources = {}
    with tarfile.open(archive) as source:
        for f in identity['files']:
            data = source.extractfile(f['path']).read()
            assert len(data) == f['bytes']
            assert hashlib.sha256(data).hexdigest() == f['sha256']
            sources[f['path']] = data.decode()
    standard = sources['installed/share/spark/theories/_gnatprove_standard.mlw']
    ada = sources['installed/share/spark/theories/ada__model.mlw']
    boolean = sources['installed/libexec/spark/share/why3/theories/bool.mlw']
    profiles = {}
    for filename, source, names in [
        ('_gnatprove_standard.mlw', standard, ['Main', 'Array__1']),
        ('ada__model.mlw', ada, ['Index_Type', 'Unconstr_Array', 'Constr_Array']),
        ('bool.mlw', boolean, ['Bool']),
    ]:
        for name in names:
            body = module(source, name)
            profiles[filename + ':' + name] = {
                'bytes': len(body.encode()),
                'sha256': hashlib.sha256(body.encode()).hexdigest(),
                'match_keywords': len(re.findall(r'\bmatch\b', body)),
                'invariant_keywords': len(re.findall(r'\binvariant\b', body)),
                'type_declaration_lines': re.findall(r'^\s*type [^\n]*', body, re.M),
            }
    assert all(p['invariant_keywords'] == 0 for p in profiles.values())
    assert profiles['bool.mlw:Bool']['match_keywords'] == 5
    assert all(p['match_keywords'] == 0 for k, p in profiles.items() if k != 'bool.mlw:Bool')
    # Exact shape checks support navigation/reproduction, not the flag proof.
    assert 'type __t = map' in module(ada, 'Constr_Array')
    assert '{ elts [@syntax:getter:elts] [@model_trace:] : map; rt : I1.t }' in module(ada, 'Unconstr_Array')
    assert 'type t = {rec__first : base;\n            rec__last  : base}' in module(ada, 'Index_Type')
    assert 'type map__ref = { mutable map__content [@model_trace:] : map }' in module(standard, 'Array__1')
    result = dict(source_files=len(identity['files']), module_profiles=profiles,
                  native_executions=0,
                  scope='Source identities and selected literal/module facts only; type flags and reachability are source-reviewed arguments; no whole-process size closure')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(source_files=result['source_files'], modules=len(profiles),
                          native_executions=0, status='passed')))


if __name__ == '__main__':
    main()
