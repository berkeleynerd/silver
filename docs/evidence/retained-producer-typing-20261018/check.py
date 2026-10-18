#!/usr/bin/env python3
"""Verify retained source identities and branch anchors; no tool execution."""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
EXPECTED_ARCHIVE = '0a4a7edfa6ec0b78220bbb429ec0b503b8eb2fba864e875ce69b69936e24ce78'


def main():
    identity = json.loads((HERE/'identity.json').read_text())
    archive = HERE/'sources.tar.gz'
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == EXPECTED_ARCHIVE
    assert identity['source_archive_sha256'] == EXPECTED_ARCHIVE
    source = {}
    with tarfile.open(archive) as tar:
        for entry in identity['files']:
            data = tar.extractfile(entry['path']).read()
            assert len(data) == entry['bytes']
            assert hashlib.sha256(data).hexdigest() == entry['sha256']
            source[entry['path']] = data.decode()
    for filename, snippets in {
        'src/mlw/dexpr.ml': [
            '[Ity.restore_pv v], e',
            'when ity_equal xs.xs_ity ity_unit ->',
            'vl, e_match e (List.rev bl) Mxs.empty',
            'let ld, v  = mk_proxy_decl ~ghost:(ghost || gh) e in',
            'c_fun ~mask pvl p q xq (get_oldies old) e, dsp, dvl',
        ],
        'src/mlw/expr.ml': [
            'let e_and e1 e2 = e_if e1 e2 e_false',
            'let e_or e1 e2 = e_if e1 e_true e2',
            'let e_not e = e_if e e_false e_true',
            '| _ when ity_equal e.e_ity ity_unit -> t_void',
            'if ity_equal e.e_ity ity_unit || not (eff_pure e.e_effect) then None',
        ],
        'plugins/gnat_json/gnat_ast_to_ptree.ml': [
            'mk_fun [] None pat Ity.MaskVisible spec body)',
            'E.mk_match expr [] exn_handlers)',
        ],
    }.items():
        assert all(s in source[filename] for s in snippets)
    result = dict(source_archive_sha256=EXPECTED_ARCHIVE,
                  source_files=len(source), native_executions=0,
                  scope='Identity and branch anchors only; source reachability is reviewed, not mechanically inferred; quantitative whole-producer join remains open')
    (HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
