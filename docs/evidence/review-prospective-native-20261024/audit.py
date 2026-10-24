#!/usr/bin/env python3
"""Independent changed-obligation audit of prospective native author 4aab5b0e9c.

Read frozen archives/results and the new pure arithmetic interface only. Do not
execute author/predecessor checkers, tools, fixtures, services or runtime scans.
"""
from pathlib import Path
from xml.parsers import expat
import ast
import hashlib
import importlib.util
import json
import platform
import re
import tarfile
import time
import xml.etree.ElementTree as ET

START = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/prospective-native'
AUTHOR = '4aab5b0e9cc931965c68bf2450473d3b63f7841a'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads((ROOT / path).read_text())


def members(path):
    with tarfile.open(path) as archive:
        return {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}


manifest = json.loads((PACKET / 'source-manifest.json').read_text())
result = json.loads((PACKET / 'result.json').read_text())
handoff = json.loads((PACKET / 'handoff.json').read_text())
targets = sorted(p for p in PACKET.rglob('*') if p.is_file()) + [ROOT / 'docs/research/retained-fixed-report-composition.md']
assert len(targets) == 33
target_hashes = {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in targets}
for path, digest in manifest['providers'].items():
    assert sha((ROOT / path).read_bytes()) == digest, path
research = (ROOT / 'docs/research/retained-fixed-report-composition.md').read_bytes()
prefix = manifest['accepted_research_prefix']
assert sha(research[:prefix['bytes']]) == prefix['sha256']
assert sha((PACKET / 'sources.tar.gz').read_bytes()) == manifest['source_archive_sha256']
source = members(PACKET / 'sources.tar.gz')
assert set(source) == set(manifest['sources']) and len(source) == 52
archives = {}
gcc = {r['path']: r['sha256'] for r in read('docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json')['files']}
for name, data in source.items():
    row = manifest['sources'][name]
    assert (len(data), sha(data)) == (row['bytes'], row['sha256'])
    origin = row['origin']
    if 'archive' in origin:
        path = origin['archive']
        if path not in archives:
            archives[path] = members(ROOT / path)
        assert data == archives[path][origin['member']], name
    else:
        assert sha(data) == gcc[origin['path']], name
text = {n: b.decode() for n, b in source.items()}
gpr_path = 'docs/evidence/retained-producer-gpr-descriptor-20261018/gprbuild-v26.0.0.tar.gz'
gpr = archives[gpr_path]
supplements = {}
for suffix in ('/gpr-err-scanner.adb', '/gpr-opt.ads'):
    name = next(n for n in gpr if n.endswith(suffix))
    supplements[name] = dict(bytes=len(gpr[name]), sha256=sha(gpr[name]))
scanner = gpr[next(n for n in gpr if n.endswith('/gpr-err-scanner.adb'))].decode()
assert 'return Name_Find;' in scanner and 'Token_Name := End_String;' in scanner
assert 'Name_Enter' not in scanner
opt = gpr[next(n for n in gpr if n.endswith('/gpr-opt.ads'))].decode()
assert re.search(r'Use_Include_Path_File\s*:\s*Boolean\s*:=\s*False', opt)
set_paths = [(n, i, line.strip()) for n, b in gpr.items() if n.endswith(('.ads', '.adb'))
             for i, line in enumerate(b.decode().splitlines(), 1) if 'Set_Ada_Paths' in line]
retained_inventory = json.loads((PACKET / 'gpr-set-ada-paths-inventory.json').read_text())
assert set_paths == [(r['path'], r['line'], r['text']) for r in retained_inventory]

# Independently enumerate every selected package fragment and changed macro site.
db = members(ROOT / 'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz')


def xml(name):
    builder = ET.TreeBuilder()
    parser = expat.ParserCreate()
    parser.StartElementHandler, parser.EndElementHandler = builder.start, builder.end
    parser.CharacterDataHandler = builder.data
    def entity(parent, context, system):
        child = parent.ExternalEntityParserCreate(context)
        child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        child.ExternalEntityRefHandler = lambda c, b, s, p: entity(child, c, s)
        child.Parse(db['db/' + system], True)
        return 1
    parser.ExternalEntityRefHandler = lambda c, b, s, p: entity(parser, c, s)
    parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
    parser.Parse(db[name], True)
    return builder.close()


def applies(item, runtime, target):
    for group in item:
        if group.tag == 'config':
            continue
        answers = []
        for option in group:
            yes = True
            for key, pattern in option.attrib.items():
                if key == 'except':
                    yes &= not bool(pattern and re.search(pattern, target))
                else:
                    value = dict(name='GNAT' if group.tag == 'compilers' else target,
                                 language='Ada', version='16.1', runtime=runtime)[key]
                    yes &= pattern.lower() == value.lower() if key == 'language' else bool(re.search(pattern, value))
            answers.append(yes)
        yes = any(answers)
        if group.get('negate', '').lower() == 'true':
            yes = not yes
        if not yes:
            return False
    return True


spec = importlib.util.spec_from_file_location('reviewed_native_capacity', PACKET / 'capacity.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
R = C.R
selected = {'default': [], R: []}
fragments = {}
xmls = sorted(n for n in db if n.startswith('db/') and n.endswith('.xml'))
assert len(xmls) == 63
for name in xmls:
    tree = xml(name)
    assert not any(v.get('name') == 'RUNTIME_DIR' for v in tree.iter('variable'))
    for i, item in enumerate(tree.findall('configuration')):
        fragments[(name, i)] = item.findtext('config') or ''
        for runtime in selected:
            outcome = applies(item, runtime, 'x86_64-linux')
            assert outcome == applies(item, runtime, 'x86_64-pc-linux-gnu')
            if outcome:
                selected[runtime].append((name, i))
assert len(selected['default']) == 19 and len(selected[R]) == 20
assert set(selected[R]) - set(selected['default']) == {('db/gnat.xml', 13)}
assert not set(selected['default']) - set(selected[R])
macro_sites = {str(key): fragments[key].count('${RUNTIME_DIR(ada)}')
               for key in selected[R] if '${RUNTIME_DIR(ada)}' in fragments[key]}
assert sum(macro_sites.values()) == 4
assert ('db/linker.xml', 82) in selected['default']
assert '-Wl,-rpath-link,${RUNTIME_DIR(ada)}/adalib' in fragments[('db/linker.xml', 82)]
assert 'return Name_As_Directory (Get_Name_String (Comp.Runtime_Dir));' in text['gpr/gpr-knowledge.adb']
assert 'return Dir & Directory_Separator;' in text['gpr/gpr-knowledge.adb']
assert "Compiler.Runtime_Dir := Compiler.Runtime;" in text['gpr/gpr-knowledge.adb']
assert 'Last := Last - 1;' in text['gcc/ada/libgnat/s-os_lib.adb']
assert (len(R), len('--RTS=' + R), len('--RTS=' + R + '/')) == (162, 168, 169)
assert len('-Wl,-rpath-link,' + R + '//adalib') == 186
assert len(R + '/adainclude/standard.ads.h') == 188

# Source-derived allocation trace per added clause, including discarded branches.
node_trace = [('declarative_item', 'gpr-dect.adb:1230-1239'),
              ('attribute', 'gpr-dect.adb:544-548'), ('outer_expression', 'gpr-strt.adb:657-658'),
              ('reference_term', 'gpr-strt.adb:1441'), ('attribute_reference', 'gpr-strt.adb:186-188'),
              ('list_term', 'gpr-strt.adb:1441'), ('literal_list', 'gpr-strt.adb:1471-1474'),
              ('inner_expression', 'gpr-strt.adb:1493-1499,657-658'),
              ('literal_term', 'gpr-strt.adb:1441'), ('literal', 'gpr-strt.adb:1547-1549')]
reference = text['gpr/gpr-strt.adb'].split('procedure Parse_Variable_Reference', 1)[1]
assert reference.index('            return;') < reference.index('(Of_Kind => N_Variable_Reference')
assert len(node_trace) * 2 == result['GPR']['ordinary_AST_nodes_per_configuration_parse'] == 20
record = text['gpr/gpr.ads'].split('type Project_Node_Record is record', 1)[1].split('end record;', 1)[0]
assert len([l for l in record.splitlines() if ':' in l.split('--')[0]]) == 22
assert 4 + 1 + 1 + 1 == result['GPR']['String_Elements_per_configuration_evaluation'] == 7
assert 'Shared.Array_Elements.Table (Elem).Value := New_Value;' in text['gpr/gpr-proc.adb']
assert 'User_Array := Conf_Array;' in text['gpr/gpr-conf.adb']
assert 'return New_Id;' in text['gpr/gpr-names.adb']
assert 'New_Capacity := 2 * New_Capacity;' in text['gcc/ada/libgnat/a-coinve.adb']

# Rebuild exact inserted chunks from the XML rather than copying their widths.
extra = fragments[('db/gnat.xml', 13)].replace('${RUNTIME_DIR(ada)}', R + '/')
chunks = re.findall(r'package\s+\w+\s+is\s*(.*?)\s*end\s+\w+;', extra, re.S)
assert len(chunks) == 2
chunk_bytes = sum(7 + len(c.encode()) for c in chunks)
assert chunk_bytes == result['GPR']['added_chunk_bytes']
observations = members(ROOT / 'docs/evidence/retained-producer-orchestration-20261018/observations.tar.gz')
text_bounds = {}
for name, data in observations.items():
    key = Path(name).name
    if name.startswith('complete_configs/retained-temporaries/') and key in result['GPR']['configurations']:
        s = data.decode()
        runtime = re.search(r'for Runtime_Dir\s+\("Ada"\) use "([^"]+)"', s).group(1)
        assert len(runtime) == 129 and s.count(runtime) == 2
        assert '("-c", "-x", "ada", "-gnatA")' in s and '("gnatbind_prefix=")' in s
        bound = len(data) + len(R) + 2 * (len(R) + 1 - len(runtime)) + chunk_bytes
        assert bound == result['GPR']['configurations'][key]['upper_bytes']
        assert ((bound + 1 + 4095) // 4096) * 4096 == 8192
        text_bounds[key] = bound
assert sorted(text_bounds.values()) == [7505, 7715, 7779]

names = ('main.adb', 'silver_io.ads', 'silver_io.adb', 'silver_output_libc.ads',
         'silver_arguments.ads', 'silver_arguments.adb', 'silver_runtime.ads')
work = '/tmp/program-ABC123'
mapping = ''.join('\n'.join([n[:-4] + ('%s' if n.endswith('.ads') else '%b'), n, work + '/' + n]) + '\n' for n in names).encode()
assert len(mapping) == 489 and C.mapping_objects()['reader_bytes'] == len(mapping) + 17 == 506
assert 1 + 3 * len(names) == 22
assert len(work + '/obj/gnatprove/\n') == 35
descriptor = read('docs/evidence/retained-producer-gpr-descriptor-20261018/result.json')
for phase in ('phase1', 'phase2'):
    old = descriptor[phase]
    switches = old.get('A_rows', old.get('A_rows_if_output_were_enabled')) + ['-Wno-free-nonheap-object', '--RTS=' + R + '/']
    row = result['light_phases'][phase]
    assert (len(switches), sum(map(len, switches)), max(map(len, switches))) == (row['switch_count'], row['switch_payload'], row['switch_max'])
    assert len(old['argv_excluding_executable']) + 2 == 18
assert len('A ' + '--RTS=' + R + '/' + '\n') == 172
assert result['indexed_null_ALI']['file_bytes'] == 29622804 + 172 == 29622976
assert result['indexed_null_ALI']['reader_bytes'] == 29622977
assert result['indexed_null_ALI']['Main_A'] + result['indexed_null_ALI']['System_A'] == 21
assert C.table(11, 1, 30, 100, 16)['bytes'] == 976
assert C.gpr_unit_transfer_conditions()['endpoint_arithmetic']['passed']
# Check multiplicity is transported, rather than silently fixed at one.
multi = C.gpr_context(100, 200, 300, 20, 32, parses=3, evaluations=4, language_conversions=5)
assert [multi['tables'][n]['demand'] for n in ('Project_Nodes', 'String_Elements', 'Name_Lists')] == [160, 228, 335]
assert multi['Name_Vector']['length'] == 23 and multi['Name_Vector']['longest_new_element_bytes'] == 234
assert not C.gpr_context(99999999, 0, 0, 0, 0)['passed']
assert not result['GPR']['context_transfer']['observed_or_established_actual_context_counts']
assert not result['GPR']['complete_parent_capacity_established']
assert not result['whole_toolchain_capacity_established'] and not result['production_implemented']
assert result['actual_complete_common_path_bytes'] is None
assert '#212_under_#119' in handoff['residuals']
assert (result['e_upper'], result['save_entering_callbacks_upper'], result['saves_upper']) == (2, 2, 3)

receipt = dict(status='pass_no_new_material_finding', reviewed_commit=AUTHOR,
    target_sha256=target_hashes, provider_count=len(manifest['providers']), complete_sources=len(source),
    supplementary_sources=supplements, base_xml_files=len(xmls), selected_fragments=selected,
    runtime_macro_sites=macro_sites, GPR_clause_allocation_trace=node_trace,
    GPR_text_bounds=text_bounds, GPR_chunk_bytes=chunk_bytes,
    top_level_RTS_bytes=168, compiler_RTS_bytes=169, linker_literal_bytes=186,
    indexed_null_ALI_bytes=29622976, map_bytes=len(mapping), map_reader_bytes=506,
    conditional_GPR_context_baseline_still_open=True, report_P_conditional=188,
    actual_complete_common_path_bytes=None, source_identity_and_physical_premises_unchanged=True,
    native_target_compiler_prover_lean_runs=0, author_or_predecessor_checker_runs=0,
    fixture_runs=0, service_queries=0, runtime_corpus_rescans=0,
    selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_model_confirmed=False,
    token_usage=None, cost=None, platform=platform.system() + ' ' + platform.machine(),
    elapsed_seconds=time.monotonic() - START)
(HERE / 'result.json').write_text(json.dumps(receipt, indent=2, sort_keys=True) + '\n')
print(json.dumps({k: receipt[k] for k in ('status', 'reviewed_commit', 'provider_count', 'complete_sources', 'elapsed_seconds')}, indent=2))
