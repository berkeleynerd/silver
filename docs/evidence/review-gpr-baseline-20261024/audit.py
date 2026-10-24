#!/usr/bin/env python3
"""Independent offline review of the frozen GPR baseline; no author imports."""
import ast
import hashlib
import json
import platform
import re
import subprocess
import tarfile
import time
from pathlib import Path
from xml.parsers import expat

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/gpr-baseline'
AUTHOR = '17569ceaa8daf41892852cc4ab8b423b28d9091e'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def inventory(data):
    """Tokenize fixed inputs, then count each declaration RHS independently.

    This is not GPR execution or a general syntax acceptance test. Comments and
    doubled-quote string escapes are consumed before punctuation is considered.
    The fixed source grammar and parser control flow are also reviewed manually.
    """
    pattern = re.compile(r'(?P<skip>\s+|--[^\n]*)|(?P<string>"(?:""|[^"])*")|'
                         r'(?P<word>[A-Za-z][A-Za-z_0-9]*)|(?P<num>[0-9]+)|'
                         r'(?P<symbol>:=|=>|[();,&\'])')
    tokens = []
    at = 0
    text = data.decode('ascii')
    while at < len(text):
        match = pattern.match(text, at)
        assert match is not None, (at, text[at:at + 30])
        kind, value = match.lastgroup, match.group()
        if kind != 'skip':
            value = value[1:-1].replace('""', '"') if kind == 'string' else value.lower()
            tokens.append((kind, value))
        at = match.end()
    words = [value if kind != 'string' else None for kind, value in tokens]
    starts = [i + 1 for i, value in enumerate(words) if value in ('use', ':=')]
    refs = terms = 0
    refs_per_rhs = []
    for start in starts:
        end = words.index(';', start)
        i, local = start, 0
        while i < end:
            kind, value = tokens[i]
            if value in (')', ',', '&') and kind == 'symbol':
                i += 1
            elif kind == 'string':
                terms += 1
                i += 1
                if i < end and words[i] == 'at':
                    assert tokens[i + 1][0] == 'num'
                    i += 2
            elif kind == 'symbol' and value == '(':
                terms += 1
                i += 1
            else:
                assert kind == 'word', tokens[i]
                terms += 1
                refs += 1
                local += 1
                i += 1
                if i < end and words[i] == "'":
                    assert tokens[i + 1][0] == 'word'
                    i += 2
                    if i < end and words[i] == '(':
                        assert tokens[i + 1][0] == 'string' and words[i + 2] == ')'
                        i += 3
        refs_per_rhs.append(local)
    assert max(refs_per_rhs, default=0) <= 1
    cases = [i for i, w in enumerate(words) if w == 'case' and words[i - 1] != 'end']
    assert all(words[i + 1:i + 3] == ['gcc_prefix', 'is'] for i in cases)
    assert all(w not in ('with', 'extends', 'aggregate', 'external', 'split') for w in words)
    strings = [v for k, v in tokens if k == 'string']
    return dict(tokens=len(tokens), declarations=len(starts), terms=terms,
                references=refs, string_tokens=len(strings),
                packages=words.count('package'), empty_case_constructs=len(cases),
                literal_payload=sum(map(len, strings)), max_literal=max(map(len, strings)),
                case_selector_references=len(cases))


def backing(demand, initial, component, low=1):
    p = max(demand, initial)
    capacity = max(initial, demand + demand // 1000, 2 * p, p + 10)
    size = (capacity + 1) * component
    assert low + capacity < 2**31 and size < 2**63
    return dict(demand=demand, capacity=capacity, bytes=size)


def main():
    started = time.monotonic()
    changed = git('diff-tree', '--no-commit-id', '--name-only', '-r', AUTHOR).decode().splitlines()
    assert len(changed) == 19
    inputs = {}
    for path in changed:
        data = (ROOT / path).read_bytes()
        assert data == git('show', f'{AUTHOR}:{path}'), path
        inputs[path] = digest(data)
    manifest = json.loads((PACKET / 'source-manifest.json').read_text())
    for path, pin in manifest['providers'].items():
        assert digest((ROOT / path).read_bytes()) == pin, path
    assert len(manifest['providers']) == 11
    research = manifest['accepted_research_prefix']
    assert digest((ROOT / 'docs/research/retained-fixed-report-composition.md').read_bytes()
                  [:research['bytes']]) == research['sha256']
    assert digest((PACKET / 'source-sites.json').read_bytes()) == manifest['source_inventory_sha256']
    archive = ROOT / 'docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz'
    with tarfile.open(archive) as tf:
        sources = {m.name: tf.extractfile(m).read() for m in tf if m.isfile()
                   and m.name.endswith(('.adb', '.ads'))}
    for path, pin in manifest['source_members'].items():
        assert len(sources[path]) == pin['bytes'] and digest(sources[path]) == pin['sha256']
    assert len(manifest['source_members']) == 26
    source = {path.rsplit('/', 1)[-1]: data.decode() for path, data in sources.items()}
    sites = json.loads((PACKET / 'source-sites.json').read_text())
    for group in sites.values():
        for row in group:
            assert sources[row['source']].decode().splitlines()[row['line'] - 1].strip() == row['text']
    constructors = {name: len(re.findall(r'\bDefault_Project_Node\s*\(', source[name]))
                    for name in ('gpr-part.adb', 'gpr-dect.adb', 'gpr-strt.adb')}
    assert constructors == {'gpr-part.adb': 11, 'gpr-dect.adb': 10, 'gpr-strt.adb': 13}
    # Pin the call edge which the RHS-only author count omitted.
    assert 'Parse_Variable_Reference' in source['gpr-dect.adb'].splitlines()[888]
    assert source['gpr-strt.adb'].splitlines()[845].strip() == 'Names.Init;'
    assert 'Add_To_Names' in source['gpr-strt.adb'].splitlines()[855]
    reset_body = '\n'.join(source['gpr-proc.adb'].splitlines()[2760:2766])
    assert 'Free_List' in reset_body and 'Reset (' not in reset_body
    # Every Name_List allocator in the complete archive belongs to these bodies.
    writers = {name for name, text in source.items()
               if re.search(r'Name_List_Table\.(?:Append|Increment_Last)', text)}
    assert writers == {'gpr-nmsc.adb', 'gpr-util.adb'}
    name_conversions = len(re.findall(r'\bInto_List\s*=>', source['gpr-nmsc.adb']))
    assert name_conversions == 31
    aux_params = {'Withs': ('gpr-part.adb', 80), 'Project_Stack': ('gpr-part.adb', 64),
                  'Extended_Projects': ('gpr-part.adb', 32), 'Next_End_Nodes': ('gpr-tree.adb', 16)}
    for name, (file, width) in aux_params.items():
        instance = re.search(r'package ' + name + r' is new GNAT.Table\s*\((.*?)\);',
                             source[file], re.S).group(1)
        for key, value in [('Table_Low_Bound', 1), ('Table_Initial', 10), ('Table_Increment', 100)]:
            assert re.search(key + r'\s*=>\s*' + str(value) + r'\b', instance)
    attr = source['gpr-attr.adb']
    attr = attr[attr.index('--  Start of processing for Initialize'):attr.index('Initialized := True;')]
    assert len(re.findall(r'\bAdd_Attribute\s*\(', attr)) == 216
    assert len(re.findall(r'\bAdd_Package\s*\(', attr)) == 19
    assert len(re.findall(r'Add_Name\s*\("', source['gpr-snames.adb'])) == 300
    result = json.loads((PACKET / 'result.json').read_text())
    boundary = json.loads((PACKET / 'boundary-result.json').read_text())
    handoff = json.loads((PACKET / 'handoff.json').read_text())
    assert boundary['capacity_sha256'] == digest((PACKET / 'capacity.py').read_bytes())
    assert boundary['retained_baseline_result_sha256'] == digest((PACKET / 'result.json').read_bytes())
    syntax = ast.parse((PACKET / 'capacity.py').read_text())
    attach = next(n for n in syntax.body if isinstance(n, ast.FunctionDef) and n.name == 'attach_names')
    assert len(attach.args.args) == 4 and not attach.args.defaults
    returns = [n for n in ast.walk(attach) if isinstance(n, ast.keyword)
               and n.arg == 'additional_provider_attached']
    assert len(returns) == 1 and returns[0].value.value is False
    # Independently count changed structural XML input, with archive-local entities.
    with tarfile.open(ROOT / 'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz') as tf:
        db = {m.name: tf.extractfile(m).read() for m in tf if m.isfile()}
    xml_totals = {'inputs': 0, 'elements': 0, 'targetsets': 0}
    for row in result['XML_input_inventory']:
        data = db[row['path']]
        assert digest(data) == row['sha256'] and len(data) == row['bytes']
        counts = {'elements': 0, 'targetsets': 0}
        parser = expat.ParserCreate()
        def start(name, attrs):
            counts['elements'] += 1
            counts['targetsets'] += name == 'targetset'
        parser.StartElementHandler = start
        def entity(parent, context, system):
            assert '/' not in system and '\\' not in system
            child = parent.ExternalEntityParserCreate(context)
            child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
            child.ExternalEntityRefHandler = lambda c, b, s, p: entity(child, c, s)
            child.Parse(db['db/' + system], True)
            return 1
        parser.ExternalEntityRefHandler = lambda c, b, s, p: entity(parser, c, s)
        parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        parser.Parse(data, True)
        assert counts['elements'] == row['elements'] and counts['targetsets'] == row['target_sets']
        xml_totals['inputs'] += 1
        for key in counts:
            xml_totals[key] += counts[key]
    assert xml_totals == {'inputs': 65, 'elements': 9492, 'targetsets': 104}
    program = (PACKET / 'inputs/program.gpr').read_bytes()
    silver = (ROOT / 'src/silver.adb').read_text()
    selected = silver[silver.index('"project Program is"'):silver.index('"end Program;"') + len('"end Program;" & LF')]
    generated = []
    for line in selected.splitlines():
        if 'else "' not in line:
            match = re.search(r'"((?:""|[^"])*)"\s*& LF', line)
            if match:
                generated.append(match[1].replace('""', '"'))
    assert program == ('\n'.join(generated) + '\n').encode() and len(program) == 541
    user = inventory(program)
    phases = {}
    findings = []
    R = '/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0/'
    with tarfile.open(ROOT / 'docs/evidence/retained-producer-orchestration-20261018/observations.tar.gz') as tf:
        for phase, n in [('datarep', 2), ('phase1', 12), ('translation', 22)]:
            data = (PACKET / f'inputs/{phase}-before-extra-clauses.gpr').read_bytes()
            historical = tf.extractfile(f'complete_configs/retained-temporaries/{n}-GNAT-TEMP-000001.TMP').read()
            old = re.search(rb'for Runtime_Dir\s+\("Ada"\) use "([^"]+)"', historical).group(1)
            assert historical.count(old) == 2 and historical.replace(old, R.encode()) == data
            config = inventory(data)
            row = result['phases'][phase]
            for name, counts in [('project', user), ('configuration', config)]:
                for key, value in counts.items():
                    if key != 'case_selector_references':
                        assert row[name][key] == value, (phase, name, key)
            total = {key: user[key] + config[key] for key in user}
            L = total['string_tokens'] + total['references'] + 1
            D, Q, T, P = (total[key] for key in ('declarations', 'terms', 'tokens', 'packages'))
            demands = dict(Project_Nodes=34 * (T + 2), String_Elements=3 + (Q + D) * L,
                           Name_Lists=D * L + 2, Variable_Elements=216 * (P + 2) + D,
                           Arrays=2 * D, Array_Elements=2 * D, Packages=P + config['packages'],
                           Number_Lists=1, Reference_Prefix=1, Case_Choices=total['empty_case_constructs'],
                           Case_Stack=1)
            assert {k: v['demand'] for k, v in row['gross_shared_table_bounds'].items()} == demands
            for key, exported in row['gross_shared_table_bounds'].items():
                calculated = backing(demands[key], exported['initial'], exported['component_bytes'], exported['low'])
                assert all(exported[k] == v for k, v in calculated.items()) and all(exported['guards'].values())
            rts = {}
            for key, delta in [('Project_Nodes', 20), ('String_Elements', 7), ('Name_Lists', 7)]:
                exported = row['accepted_RTS_shared_table_attachment'][key]
                calculated = backing(demands[key] + delta, exported['initial'], exported['component_bytes'])
                assert all(exported[k] == v for k, v in calculated.items())
                assert handoff['phase_exports'][phase]['RTS_attached_shared_tables'][key] == exported
                rts[key] = calculated
            extra_demands = dict(Withs=0, Project_Stack=2, Extended_Projects=0,
                                 Next_End_Nodes=2 + P + total['empty_case_constructs'])
            for key, demand in extra_demands.items():
                expected = backing(demand, 10, aux_params[key][1])
                exported = boundary['auxiliary_parser_tables'][phase]['tables'][key]
                assert all(exported[k] == v for k, v in expected.items())
            known_names = 302 + 104 + 2 * T + 2 * D + Q
            assert row['known_GPR_Name_requests']['total'] == known_names
            actual_resets = total['references'] + total['case_selector_references']
            asserted_resets = row['reference_prefix_reset_events_upper']
            assert (asserted_resets, actual_resets) == (6, 7)
            findings.append(dict(phase=phase, field='reference_prefix_reset_events_upper',
                                 exported_upper=asserted_resets, source_selected_resets=actual_resets,
                                 omitted_case_selector_references=1, peak_backing_affected=False))
            assert not row['complete_GPR_process_capacity_closed']
            assert not row['complete_GPR_names_baseline_closed']
            phases[phase] = dict(user=user, configuration=config, list_bound=L,
                                 baseline_demands=demands, RTS_attachment=rts,
                                 auxiliary_demands=extra_demands, partial_names=known_names)
    for key in ('complete_GNATprove_GPR2_capacity_closed', 'complete_GPR_Name_baseline_closed',
                'complete_GPRconfig_capacity_closed', 'complete_producer_configuration_capacity_closed'):
        assert result[key] is False
    assert (handoff['e_upper'], handoff['save_entering_callbacks_upper'], handoff['saves_upper']) == (2, 2, 3)
    assert not handoff['aggregate_RAM_or_stack_gate'] and handoff['physical_premises_unchanged']
    receipt = dict(reviewed_commit=AUTHOR, platform=platform.system() + ' ' + platform.machine(),
                   status='completed_one_low_finding_reproduced', input_sha256=inputs,
                   provider_files=len(manifest['providers']), source_members=len(manifest['source_members']),
                   constructor_sites=constructors, Name_List_conversion_sites=name_conversions,
                   XML_structural_inventory=xml_totals, phases=phases,
                   findings=[dict(id='F1', severity='low', affected_exports=findings)],
                   author_and_predecessor_checker_runs=0, author_code_imports=0,
                   native_compiler_prover_Lean_capture_service_runs=0, runtime_corpus_rescans=0,
                   elapsed_seconds=round(time.monotonic() - started, 6))
    (HERE / 'result.json').write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
    print(json.dumps({key: receipt[key] for key in ('reviewed_commit', 'status', 'provider_files',
                                                  'source_members', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
