#!/usr/bin/env python3
"""Finite retained-input projection; not an OCaml semantic verifier."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
R53 = ROOT / 'docs/evidence/retained-why-parallel-residual-transfer-20261020'
R54 = ROOT / 'docs/evidence/retained-fixed-goal-attribution-20261020'
R55 = ROOT / 'docs/evidence/retained-parallel-logging-prefix-20261020'
QUIET = ROOT / 'docs/evidence/retained-cvc5-quiet-route-20261020/candidate-base-why3.conf'
COUNTS = dict(zip(('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid'), (192, 159, 96, 9, 3)))
PROVERS = ('cvc5', 'z3', 'altergo')
DRIVERS = dict(zip(PROVERS, ('cvc5_gnatprove.drv', 'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv')))

def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}

def read_json(p):
    return json.loads(p.read_bytes())

def uncomment(s):
    # Driver comments nest; preserve quoted strings and the (*) operator token.
    out, depth, i, quoted = [], 0, 0, False
    while i < len(s):
        if quoted and s[i] == "\\":
            out.extend(s[i:i+2]); i += 2; continue
        if not depth and s[i] == '"':
            quoted = not quoted
        if not depth and not quoted and s[i:i+3] == '(*)':
            out.extend('(*)'); i += 3; continue
        if not quoted and s[i:i+2] == '(*':
            depth += 1; i += 2; continue
        if not quoted and s[i:i+2] == '*)':
            assert depth > 0
            depth -= 1; i += 2; continue
        if not depth:
            out.append(s[i])
        i += 1
    assert depth == 0 and not quoted
    return ''.join(out)

def configs(b):
    sections = []
    for raw in b.decode('ascii').splitlines():
        s = raw.strip()
        if s.startswith('['):
            sections.append({'section': s})
        elif s:
            k, v = s.split('=', 1)
            v = v.strip()
            sections[-1][k.strip()] = json.loads(v) if v.startswith('"') else v
    selected = {s['shortcut']: s for s in sections if s.get('shortcut') in PROVERS}
    assert set(selected) == set(PROVERS)
    for s in selected.values():
        assert s.get('interactive', 'false') == 'false'
        assert 'extra_options' not in s and 'extra-options' not in s
    return selected

def walk(x):
    if isinstance(x, list):
        yield x
        for a in x:
            yield from walk(a)
    elif isinstance(x, dict):
        for a in x.values():
            yield from walk(a)

def sanitize(s):
    # Restricted alphabet of the source/header operands in this packet.
    assert all(c.isascii() and (c.isalnum() or c in "_' ") for c in s)
    return ''.join('qt' if c == "'" else '_' if c == ' ' else c for c in s) if s else 'zilch'

def driver_projection():
    manifest = read_json(HERE / 'driver-inputs.json')
    recorded = read_json(R53 / 'remaining-driver-resolution.json')
    text = {}
    for name, info in manifest.items():
        b = (HERE / 'drivers' / name).read_bytes()
        assert identity(b) == info['identity'] == recorded[info['recorded_path']]['identity']
        text[name] = uncomment(b.decode('ascii'))
        imports = re.findall(r'^\s*import\s+"([^"]+)"', text[name], re.M)
        assert imports == info['imports'] == [x['name'] for x in recorded[info['recorded_path']]['imports']]
        for imp, resolution in zip(imports, recorded[info['recorded_path']]['imports']):
            assert resolution['candidates'] == [manifest[imp]['recorded_path']]
    out = {}
    for prover, root in DRIVERS.items():
        seen = []
        def visit(name):
            assert name not in seen
            seen.append(name)
            for imp in manifest[name]['imports']:
                if imp not in seen:
                    visit(imp)
        visit(root)
        names = [v for name in seen for v in re.findall(r'^\s*filename\s+"([^"]+)"', text[name], re.M)]
        assert names == ['%f-%t-%g.' + ('psmt2' if prover == 'altergo' else 'smt2')]
        # All transformation directives occur in the root in these fixed drivers.
        assert all(not re.findall(r'^\s*transformation\s+', text[n], re.M) for n in seen[1:])
        out[prover] = {'files': seen, 'filename_template': names[0], 'transformations': re.findall(r'^\s*transformation\s+"([^"]+)"', text[root], re.M)}
    assert set(manifest) == {x for row in out.values() for x in row['files']}
    return out

def serialize(argv, ident, time='0.'):
    assert time in ('0.', '1.')
    assert all(not any(c in s for c in ';\n\r\0') for s in argv)
    return ';'.join(['run', str(ident), time, '0'] + argv) + '\n'

def wrap(argv, domain, ident, prover, adapter='a'):
    return [adapter, '--control', '.slv-a0', '--domain', str(domain), '--request', str(ident), '--prover', str(prover), '--'] + argv

def project():
    accepted_counts = read_json(ROOT / 'docs/evidence/retained-adapter-protocol-storage-20261020/result.json')
    assert {r['case']: r['run_entries'] for r in accepted_counts['cases']} == COUNTS
    assert all(r['positive_ID_digits'] == len(str(COUNTS[r['case']])) for r in accepted_counts['cases'])
    drivers = driver_projection()
    labels = read_json(R54 / 'raw-goal-labels.json')
    cuts = read_json(R55 / 'cut-projection.json')
    quiet = configs(QUIET.read_bytes())
    domains = {}
    for domain, (case, n) in enumerate(COUNTS.items()):
        with tarfile.open(R53 / (case.replace('_', '-') + '-capture.tar.gz')) as t:
            get = lambda name: t.extractfile(case + '/' + name).read()
            process = json.loads(get('capture/process.json'))
            metadata = json.loads(get('capture/metadata.json'))
            cfg_bytes = get('why3.conf')
            cfg = configs(cfg_bytes)
            assert identity(cfg_bytes) == {'bytes': 1946, 'sha256': 'f83746bab113aeaa0d1b3ccfd13a2ce0cd965f2673ac89b84973fd4b121dd1fb'}
            assert t.extractfile('overlay/why3.conf').read() == b'[main]\nmagic = 14\n'
            names = [m.name for m in t.getmembers() if m.name.endswith('.gnat-json')]
            assert len(names) == 1
            source = json.load(t.extractfile(names[0]))
        assert process['argv'] == cuts[case]['captured_argv']
        assert '--debug' not in process['argv'] and '--debug-save-vcs' not in process['argv']
        for opt, value in [('--steps', '0'), ('--timeout', '0'), ('--counterexample', 'off'), ('--proof', 'per_check'), ('--prover', 'cvc5,z3,altergo')]:
            assert process['argv'][process['argv'].index(opt)+1] == value
        funcs = [x for x in walk(source) if x and x[0] == 'W_FUNCTION_DECL' and x[3][3][3] == 'def']
        assert len(funcs) == 1
        f = funcs[0]
        assert len(f) == 12 and f[4] and f[2] == 4 and f[3][3][4:] == ['', None, False]
        filename, line = f[11]
        assert filename in ('silver_io.ads', 'silver_arguments.ads', 'silver_arguments.adb')
        loc = [101, 2 * (line << 16) + 1, 2 * (line << 16) + 1]
        assert labels[case] and all(x['name'] == "def'vc" and x['location_words'] == loc for x in labels[case])
        assert len({x['ident'] for x in labels[case]}) == 1
        temp = process['environment']['TMPDIR']
        assert temp and not temp.endswith('/') and temp.isascii()
        assert not any(c in temp for c in ';\n\r\0')
        stem = filename.rsplit('/', 1)[-1].rsplit('.', 1)[0]
        d = len(str(n))
        row = {'N': n, 'id_digits': d, 'raw_goals': len(labels[case]), 'json_member': names[0], 'function_node_id': f[1], 'source_location': f[11], 'goal_name': "def'vc", 'native_location_words': loc, 'location_filename_origin': 'source argument; FileTags lookup bytes not captured', 'recorded_TMPDIR': temp, 'recorded_TMPDIR_bytes': len(temp), 'provers': {}}
        for pnum, prover in enumerate(PROVERS):
            native = [r for r in metadata['drivers'] if r['prover'][0].lower() == prover]
            assert len(native) == 1 and native[0]['transformations'] == drivers[prover]['transformations']
            assert cfg[prover]['driver'] + '.drv' == DRIVERS[prover]
            name = drivers[prover]['filename_template'].replace('%f', sanitize(stem)).replace('%t', 'T').replace('%g', sanitize("def'vc"))
            file_example = temp + '/why_000000_' + name
            fadd = 12 + len(name)
            assert len(file_example) == len(temp) + fadd
            pr = {'driver_filename': name, 'driver_filename_bytes': len(name), 'task_path_bytes': {'tau': 1, 'constant': fadd}, 'profiles': {}}
            for profile, commands in [('original', cfg), ('quiet', quiet)]:
                command = commands[prover]['command']
                assert command.isascii() and not any(c in command for c in "\t\n\r'\"\\")
                tokens = command.split(' ')
                assert tokens[-1] == '%f' and all(tokens) and command.count('%') == 1
                if prover != 'cvc5':
                    assert command == cfg[prover]['command']
                argv = tokens[:-1] + [file_example]
                wrapped = wrap(argv, domain, n, pnum)
                plain_line = serialize(argv, n)
                line_wire = serialize(wrapped, n)
                argc = len(wrapped)
                assert len(line_wire) - len(plain_line) == 1 + 55 + d
                assert len(plain_line) == 10 + d + len(argv) + sum(map(len, argv))
                constant = len(line_wire) - 1 - len(temp) - 2*d
                # Check every admitted ID and both selected time strings,
                # plus a second adapter operand length; no solver execution.
                for ident in range(1, n+1):
                    for time in ('0.', '1.'):
                        for a in (1, 17):
                            w = wrap(argv, domain, ident, pnum, 'a'*a)
                            wire = serialize(w, ident, time)
                            assert len(wire) == a + len(temp) + constant + 2*len(str(ident))
                            assert len(wire) <= a + len(temp) + constant + 2*d
                            assert wire.count(';') == argc + 3
                pr['profiles'][profile] = {'command': command, 'original_argc': len(argv), 'wrapped_argc': argc, 'parser_m_excluding_executable': argc-1, 'total_fields': argc+4, 'semicolons': argc+3, 'original_wire_F_plus_d_constant': 10+len(argv)+sum(map(len,tokens[:-1])), 'wrapped_wire_bytes': {'A': 1, 'tau': 1, 'constant': constant, 'twice_id_digits': 2*d}, 'recorded_TMPDIR_A_1_wire_bytes': len(line_wire)}
            row['provers'][prover] = pr
        row['profiles'] = {}
        for profile in ('original', 'quiet'):
            prs = [r['profiles'][profile] for r in row['provers'].values()]
            c = max(p['wrapped_wire_bytes']['constant'] for p in prs) + 2*d
            row['profiles'][profile] = {'L_d': {'A':1,'tau':1,'constant':c}, 'm_d': max(p['parser_m_excluding_executable'] for p in prs), 'interrupt_wire_bytes': 11+d, 'M_d_equals_L_d_for_nonempty_operands': True}
        domains[case] = row
    return {'scope': 'conditional fixed-domain source/configuration projection; combined quiet+timeless+J12+logging startup join is separate', 'operands': {'A':'actual adapter executable argv byte length', 'tau':'actual nonempty TMPDIR without trailing slash byte length', 'C':'actual backend getcwd result byte length', 'R':'canonical result-directory byte length'}, 'drivers': drivers, 'domains': domains, 'aggregate': {'N': sum(COUNTS.values()), 'sum_N_times_digits': sum(n*len(str(n)) for n in COUNTS.values()), 'parser_m_domain_upper': 14}, 'output_paths': {'P_b': {'C':1,'constant':11}, 'P_c': {'R':1,'constant':24}, 'backend_getcwd_captured': False}, 'guards': ['valid source/runtime correspondence and successful non-unwinding relevant table mutations', 'selected fresh noninteractive route, no script override, no independent caller or replay', 'A,tau,R,C derived from selected exact configuration/canonical-directory relation; no semicolon, LF, CR or NUL in serialized operands', 'M_d+1023 <= INT_MAX; backend P_b+d+31 <= INT_MAX; canonical serializer guard remains separate']}

if __name__ == '__main__':
    print(json.dumps(project(), indent=2, sort_keys=True))
