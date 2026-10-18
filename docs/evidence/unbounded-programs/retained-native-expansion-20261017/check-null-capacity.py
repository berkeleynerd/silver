#!/usr/bin/env python3
"""Focused offline boundary checks for actual-byte null capacity composition."""
import argparse
import ast
import importlib.util
import json
from pathlib import Path
import tempfile

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('null_capacity', HERE/'compose-null-capacity.py')
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ada-root',type=Path,required=True)
    a = p.parse_args()
    model = mod.load_model(a.ada_root)
    # Both reusable active helpers must implement the corrected physical-line
    # semantics. Extract only the collector function, without running its CLI.
    collector_tree = ast.parse((HERE/'reconcile-fixed.py').read_text())
    shape_function = next(n for n in collector_tree.body
                          if isinstance(n,ast.FunctionDef) and n.name == 'source_shape')
    collector = {'re':mod.re}
    exec(compile(ast.Module(body=[shape_function],type_ignores=[]),'<collector-shape>','exec'),collector)
    for raw in [b'x\vy\fz',b'x\ty\f\tz',b'x\r\ny\rz\n',b'']:
        correct = mod.physical_source_shape(raw)
        assert model['source_shape'](raw) == correct
        fixed = collector['source_shape'](raw)
        assert all(fixed[k] == v for k,v in correct.items())
    fixture = HERE/'null-capacity-fixture.json'
    baseline = mod.compose(fixture,model)
    assert baseline == json.loads((HERE/'native-null-capacity-composition.json').read_bytes())
    assert baseline['all_selected_compiler_component_predicates_pass']
    original = (mod.REPO/'samples/null.adb').read_bytes()
    passed = ['retained actual-byte composition','shared and fixed collector physical-line helpers agree']
    # Rejected shapes include a second otherwise legal null statement, a pragma
    # change and a keyword split by a real comment; none may borrow this proof.
    for raw in [original.replace(b'null;',b'null; null;'),
                original.replace(b'(On)',b'(Off)'),
                original.replace(b'procedure',b'proce-- comment\ndure'),
                original+b'\x00', original+b'\x80']:
        try:
            mod.null_source_counts(raw)
        except ValueError:
            pass
        else:
            raise AssertionError('unsupported source shape accepted')
    passed.append('unsupported token streams and bytes rejected')
    for terminator in [b'\r',b'\n',b'\v',b'\f',b'\r\n']:
        raw = b'-- begin null; end Main;'+terminator+original.upper()+b'-- EOF comment'
        assert mod.null_source_counts(raw) == mod.null_source_counts(original)
    passed.append('all five supported line endings and EOF comments')
    descriptor = json.loads(fixture.read_bytes())
    descriptor['files'] = {k:str((HERE/v).resolve()) for k,v in descriptor['files'].items()}
    with tempfile.TemporaryDirectory(prefix='silver-null-capacity-check-') as tmp:
        tmp = Path(tmp); source = tmp/'source.adb'; dpath = tmp/'input.json'
        descriptor['files']['Main'] = str(source)
        dpath.write_text(json.dumps(descriptor))
        # An input above the current 4096-byte language limit is only an
        # arithmetic test: it must not grow the constant syntax/graph counts.
        source.write_bytes((b'--'+b'x'*100+b'\n')*100+original)
        large = mod.compose(dpath,model)
        assert large['inputs']['Main']['bytes'] > 4096
        assert large['source_counts'] == baseline['source_counts']
        assert large['logical_table_demands'] == baseline['logical_table_demands']
        assert large['all_selected_compiler_component_predicates_pass']
        assert not large['production_admission_changed']
        passed.append('larger comment-only source preserves graph counts')
        # GNAT's selected expanded final column is <=32766, including the
        # one-past-final-column value. These straddle the actual rule exactly.
        source.write_bytes(b'--'+b'x'*32763+b'\n'+original)
        edge = mod.compose(dpath,model)
        assert edge['all_selected_compiler_component_predicates_pass']
        source.write_bytes(b'--'+b'x'*32764+b'\n'+original)
        over = mod.compose(dpath,model)
        assert not over['component_checks']['physical_sources']
        assert over['component_checks']['core_tables']
        passed.append('expanded-column boundary rejects without changing graph counts')
        # FF/VT terminate comments but do not reset GNAT's physical line start.
        # Each fragment fits the column bound; their shared physical line does
        # not. CR, LF and CRLF really do reset it and remain accepted here.
        for terminator in [b'\v',b'\f',b'\r',b'\n',b'\r\n']:
            source.write_bytes(b'--'+b'x'*20000+terminator+b'--'+b'x'*20000+b'\n'+original)
            combined = mod.compose(dpath,model)
            assert combined['source_counts'] == baseline['source_counts']
            assert combined['component_checks']['physical_sources'] == (terminator not in [b'\v',b'\f'])
        passed.append('FF/VT end comments without resetting physical columns')
        # Actual configuration bytes, not a manually asserted declaration
        # count, select the indexed read projection.
        source.write_bytes(original)
        config = tmp/'config.adc'
        config.write_bytes((HERE/'null-capacity-fixture.adc').read_bytes()+b'pragma Suppress (All_Checks);\n')
        descriptor['files']['configuration'] = str(config)
        dpath.write_text(json.dumps(descriptor))
        try:
            mod.compose(dpath,model)
        except ValueError as error:
            assert 'configuration' in str(error)
        else:
            raise AssertionError('changed configuration accepted')
        passed.append('configuration semantic override rejected')
    assert not mod.current_command(model,2**31)['all_selected_checks_pass']
    passed.append('signed option/coverage arithmetic overflow rejected')
    print(json.dumps({'passed':passed,'native_executions':0},indent=2))


if __name__ == '__main__':
    main()
