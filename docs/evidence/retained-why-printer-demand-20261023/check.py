"""Focused new-cut source identity, transcription and arithmetic checks."""
import ast
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def main():
    started = time.perf_counter()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in inputs['providers'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    witness = json.loads((HERE / 'source-witnesses.json').read_text())
    archive = ROOT / witness['archive']
    assert identity(archive.read_bytes()) == witness['archive_identity']
    sources = {}
    with tarfile.open(archive) as tf:
        for path, row in witness['sources'].items():
            data = tf.extractfile(row['member']).read()
            assert identity(data) == {k: row[k] for k in ('bytes', 'sha256')}
            lines = data.decode().splitlines(keepends=True)
            for section in row['sections']:
                assert ''.join(lines[section['first']-1:section['last']]) == section['text']
            sources[path] = data.decode()
    assert 'let tys = lazy (get_type_arguments t)' in sources['core/printer.ml']
    assert "print_type fmt (Lazy.force tys).(i)" in sources['core/printer.ml']
    assert 'let get_syntax_map task =\n  let sm0 = Printer.get_syntax_map task in\n  Task.on_meta meta_lsinst (sm_add_ls sm0) sm0 task' in sources['transform/discriminate.ml']
    assert 'let rec has_quantification f =' in sources['printer/smtv2.ml']
    assert '| _ -> Term.t_any has_quantification f' in sources['printer/smtv2.ml']
    assert 'let t_any pr t = Util.any t_fold pr t' in sources['core/term.ml']
    assert 'List.iter (print_prop info fmt) info.incr_list_axioms' in sources['printer/smtv2.ml']
    assert 'List.iter (print_ldecl_axiom info fmt) info.incr_list_ldecls' in sources['printer/smtv2.ml']
    spec = importlib.util.spec_from_file_location('printer_demand', HERE / 'compose.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    result = module.calculate()
    assert result == json.loads((HERE / 'result.json').read_text())
    for case in result['cases']:
        e = case['episodes_upper']
        for owner, vector in case['process_vector'].items():
            assert all(v == e * case['per_episode_vector'][owner][k] for k, v in vector.items())
            if owner != 'Ident':
                assert vector == {'increments': 0, 'requests': 0}
        d = case['dimensions']
        fine = 2*d['P'] + d['A'] + 2*(d['A']+1)
        assert case['per_episode_vector']['Ident']['increments'] == d['H']*fine
        assert fine <= 8*(d['S']+1)*(d['P']+1)
    for p in HERE.glob('*.py'):
        ast.parse(p.read_text(), filename=str(p))
    links = 0
    for p in [ROOT / 'docs/research/retained-why-printer-demand.md', HERE / 'README.md']:
        for target in re.findall(r'\]\(([^)]+)\)', p.read_text()):
            if '://' not in target and not target.startswith('#'):
                assert (p.parent / target.split('#')[0]).exists(), target
                links += 1
    answer = {'status': 'pass', 'elapsed_seconds': time.perf_counter()-started,
              'source_members': len(sources), 'frozen_providers': len(inputs['providers']),
              'cases': len(result['cases']), 'local_links': links,
              'predecessor_checkers_replayed': 0, 'native_runs': 0,
              'independent_whole_packet_review': False,
              'source_argument_machine_checked': False, 'whole_capacity_rule': False}
    (HERE / 'check-result.json').write_text(json.dumps(answer, indent=2) + '\n')
    print(json.dumps(answer))


if __name__ == '__main__':
    main()
