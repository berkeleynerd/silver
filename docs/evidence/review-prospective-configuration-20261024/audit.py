#!/usr/bin/env python3
"""Independent offline changed-obligation audit of author 9432b9d694.

No author/predecessor checker, native target, installation rescan or fixture.
The exported recipe is imported as the interface under review. A counterexample
is retained, rather than changing the author or treating it as a native run.
"""
from pathlib import Path
from xml.parsers import expat
import hashlib
import importlib.util
import json
import platform
import re
import sys
import tarfile
import time
import xml.etree.ElementTree as ET

START = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-fixed-report-composition-20261024/prospective'
AUTHOR = '9432b9d69498cce7e2474d7a96c4adc37f97b7ae'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_text())


manifest = read_json(PACKET / 'source-manifest.json')
author_result = read_json(PACKET / 'result.json')
handoff = read_json(PACKET / 'handoff.json')
target_files = sorted(PACKET.iterdir()) + [ROOT / 'docs/research/retained-fixed-report-composition.md']
assert len(target_files) == 12 and all(p.is_file() for p in target_files)
target_hashes = {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in target_files}
for name, digest in manifest['repository_files'].items():
    assert sha((ROOT / name).read_bytes()) == digest, name
prefix = manifest['accepted_research_prefix']
assert sha((ROOT / prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
assert sha((PACKET / 'sources.tar.gz').read_bytes()) == manifest['sources_archive_sha256']
with tarfile.open(PACKET / 'sources.tar.gz') as archive:
    sources = {n: archive.extractfile(n).read() for n in archive.getnames()}
assert set(sources) == set(manifest['sources'])
for name, data in sources.items():
    assert sha(data) == manifest['sources'][name]['sha256']
    assert len(data) == manifest['sources'][name]['bytes']

origin = manifest['sources']['gpr/gpr/src/gpr-conf.adb']['origin']
archive_path = ROOT / origin['archive']
assert sha(archive_path.read_bytes()) == origin['archive_sha256']
knowledge_member = origin['member'].replace('gpr-conf.adb', 'gpr-knowledge.adb')
with tarfile.open(archive_path) as archive:
    knowledge = archive.extractfile(knowledge_member).read()
selector = read_json(PACKET / 'runtime-selection.json')
assert sha(knowledge) == selector['complete_source_sha256']
assert len(knowledge) == selector['complete_source_bytes']

# Source anchors attach manual control-flow review, not a replacement proof.
anchors = {
    'gnatcoll/gnatcoll-utils.adb': ['Resolve_Links => True', "Path_Last - 3"],
    'spark/gnatprove/configuration.ads': ['Prefix                    : constant String := Executable_Location;', 'Ada.Environment_Variables.Exists ("GNSA_ROOT")'],
    'spark/gnatprove/configuration.adb': ['Proj_Opt.Add_Switch (Options.RTS, CL_Switches.RTS.all);'],
    'spark/gnatprove/gnatprove.adb': ['Args.Append ("--RTS=" & CL_Switches.RTS.all);', 'Create (Ada.Directories.Simple_Name (Command_Name))', 'Gpr_Val & Path_Separator & Libgnat & Path_Separator & Sharegpr'],
    'gpr/gpr/src/gpr-conf.adb': ['RTS_Dir := new String\'(Normalize_Pathname (Runtime_Dir));', 'Set_Runtime_For (Name_Ada, RTS_Dir.all);', '& Runtime_Name_For (Name) &'],
    'gpr/gpr/src/gpr-env.adb': ['Get_Name_String (Source.Display_File);', 'Get_Name_String (Source.Path.Display_Name);', 'Name_Buffer (Name_Len) := ASCII.LF;'],
    'gpr/gpr/src/gpr-tempdir.adb': ['Normalize_Pathname (Dir.all)', 'Directory & Directory_Separator & File_Name.all'],
    'gcc/switch-c.adb': ['Opt.No_Stdinc := True;', 'Opt.RTS_Switch := True;', 'Store_Compilation_Switch (Switch_Chars);'],
    'gcc/osint.adb': ['Read_Default_Search_Dirs (Norm_Search_Dir, Search_File, null)', 'Result := new String\'(Directory);', 'Dir_Name.all & Name & ASCII.NUL;', "Name_Find (Full_Name (Full_Name'First .. Full_Name'Last - 1))"],
    'gcc/lib.adb': ['Compilation_Switches.Increment_Last;', "new String'(Switch);"],
}
for name, texts in anchors.items():
    for text in texts:
        assert text in sources[name].decode(), (name, text)
assert 'Compiler.Runtime := Get_String_No_Adalib (Rts);' in knowledge.decode()
assert 'Compiler.Runtime_Dir := Compiler.Runtime;' in knowledge.decode()
assert 'Ncomp.Runtime_Dir := El.Runtime_Dir;' in knowledge.decode()
assert 'Ncomp.Runtime := El.Runtime;' in knowledge.decode()

spec = importlib.util.spec_from_file_location('reviewed_prospective_recipe', PACKET / 'recipe.py')
recipe = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = recipe
spec.loader.exec_module(recipe)
work = '/tmp/program-Ab09zZ'
obj = work + '/obj/gnatprove'
assert recipe.environment(work) == {
    'PATH': recipe.PREFIX + '/bin:/usr/bin:/bin', 'LC_ALL': 'C', 'TMPDIR': work + '/tmp'}
assert recipe.parent_environment(work) == dict(recipe.environment(work),
    PATH=(recipe.BUNDLED_BIN + ':') * 2 + recipe.PREFIX + '/bin:/usr/bin:/bin',
    GPR_PROJECT_PATH=':' + recipe.PREFIX + '/lib/gnat:' + recipe.PREFIX + '/share/gpr',
    GPR_TOOL='gnatprove')

# Derive source closure from the actual project literal, independently of SOURCES.
silver = (ROOT / 'src/silver.adb').read_text()
line = next(l for l in silver.splitlines() if 'for Source_Files use' in l and 'silver_io' in l)
names = re.findall(r'""([a-z_]+\.(?:ads|adb))""', line)
assert len(names) == 7 and tuple(names) == recipe.SOURCE_NAMES
expected_map = [(n[:-4] + ('%s' if n.endswith('.ads') else '%b'), n, work + '/' + n) for n in names]
assert list(recipe.mapping_triples(work)) == expected_map
assert 'for Body (""Main"") use ""main.adb"" at 1;' in silver
assert 'for Source_Dirs use (""."");' in silver
mapping = ''.join('\n'.join(row) + '\n' for row in reversed(expected_map)).encode()
recipe.check_mapping(mapping, work)
for bad in (mapping[:-1], mapping + mapping[:mapping.index(b'\n') + 1], mapping.replace(b'main.adb', b'other.adb')):
    try:
        recipe.check_mapping(bad, work)
    except ValueError:
        pass
    else:
        raise AssertionError('bad mapping accepted')

# Re-evaluate the changed runtime selector against all frozen XML configurations.
with tarfile.open(ROOT / 'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz') as archive:
    configs = {n: archive.extractfile(n).read() for n in archive.getnames()}


def tree(name):
    builder = ET.TreeBuilder()
    parser = expat.ParserCreate()
    parser.StartElementHandler = builder.start
    parser.EndElementHandler = builder.end
    parser.CharacterDataHandler = builder.data
    def entity(context, base, system, public):
        child = parser.ExternalEntityParserCreate(context)
        child.Parse(configs['db/' + system], True)
        return 1
    parser.ExternalEntityRefHandler = entity
    parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
    parser.Parse(configs[name], True)
    return builder.close()


def selected(element, runtime, target):
    values = dict(name='GNAT', version='16.1', runtime=runtime, language='Ada')
    for group in element:
        if group.tag == 'config':
            continue
        assert group.tag in ('compilers', 'targets', 'hosts')
        outcomes = []
        for option in group:
            matches = True
            for key, pattern in option.attrib.items():
                if key == 'except':
                    matches &= not bool(re.search(pattern, target)) if pattern else True
                else:
                    value = values[key] if group.tag == 'compilers' else target
                    matches &= (pattern.lower() == value.lower() if key == 'language' else bool(re.search(pattern, value)))
            outcomes.append(matches)
        matches = any(outcomes)
        if group.get('negate') == 'true':
            matches = not matches
        if not matches:
            return False
    return True


xml_names = sorted(n for n in configs if n.startswith('db/') and n.endswith('.xml'))
assert len(xml_names) == 63
runtime_changes = []
for name in xml_names:
    for i, item in enumerate(tree(name).findall('configuration')):
        old = selected(item, 'default', 'x86_64-linux')
        new = selected(item, recipe.RTS, 'x86_64-linux')
        assert new == selected(item, recipe.RTS, 'x86_64-pc-linux-gnu')
        if old != new:
            runtime_changes.append(dict(file=name, index=i, before=old, after=new,
                                        fragment=item.findtext('config')))
assert len(runtime_changes) == 1
change = runtime_changes[0]
assert (change['file'], change['index'], change['before'], change['after']) == ('db/gnat.xml', 13, False, True)
assert change['fragment'].count('--RTS=${RUNTIME_DIR(ada)}') == 2
assert re.findall(r'package\s+(\w+)\s+is', change['fragment']) == ['Compiler', 'Binder']

widths = []
for workers in [3] + [10 ** n for n in range(1, 10)] + [2147483647]:
    argv = ['gnatprove', '-P', work + '/program.gpr', '-U', '--mode=all',
            '--report=all', '--warnings=continue', '--checks-as-errors=on',
            '--prover=cvc5,z3,altergo', '--steps=0', '--timeout=0', '--memlimit=0',
            '--counterexamples=off', '-j' + str(workers), '--no-loop-unrolling',
            '--output=brief', '--RTS=' + recipe.RTS, '-cargs', '-Wno-free-nonheap-object']
    cfg = recipe.configuration(work, workers)
    assert cfg['argv'] == argv and cfg['execve_argv'] == [recipe.EXECUTABLE] + argv[1:]
    serialized = dict(obj_dirs=[obj + '/'], cmdline=argv, proof_switches={},
                      mode='GPM_ALL', has_errors=False, colors=False)
    size = len(json.dumps(serialized, separators=(',', ':')).encode()) + 1
    joined = len(' '.join(argv).encode())
    assert size == cfg['config_file_bytes'] == 608 + len(str(workers))
    assert joined == cfg['joined_command_bytes'] == 434 + len(str(workers))
    assert recipe.base.c.configuration_bounds(cfg, path_bytes=188, max_path=4096, page_size=4096)['all_guards']
    widths.append(dict(workers=workers, entries=len(argv), command_bytes=joined, config_bytes=size))

derived = dict(workspace=len(work), temporary_root=len(work + '/tmp'), project=len(work + '/program.gpr'),
               object_with_slash=len(obj + '/'), phase_cwd=len(obj + '/data_representation'),
               temporary_file=len(work + '/tmp/GPR.2147483647/GNAT-TEMP-999999.TMP'),
               fixed_source=max(len(work + '/' + n) for n in names),
               why_json=len(obj + '/' + 'x' * 64), runtime=len(recipe.RTS),
               runtime_object=len(recipe.RUNTIME_OBJECT), runtime_source_file=len(recipe.RUNTIME_SOURCE + '/standard.ads.h'))
assert derived == dict(workspace=19, temporary_root=23, project=31, object_with_slash=34,
                       phase_cwd=53, temporary_file=59, fixed_source=42, why_json=98,
                       runtime=162, runtime_object=169, runtime_source_file=188)
assert max(derived.values()) == recipe.hull(work)['common_path_bytes'] == 188
old = read_json(PACKET.parent / 'paths/result.json')
assert author_result['fixed_report_joins_reused'] == old['fixed_report_joins']
assert author_result['runtime_corpus_evidence_reused'] == old['runtime_corpus']
assert old['runtime_corpus']['manifest_sha256'] == manifest['runtime_corpus']['accepted_manifest_sha256']
assert author_result['actual_complete_common_path_bytes'] is None
assert handoff['actual_complete_common_path_bytes'] is None and not handoff['production_implemented']
assert not author_result['effective_native_child_inputs_observed']
assert not author_result['rts_delta']['complete_native_storage_recomposition']
assert len('--RTS=' + recipe.RTS) == author_result['rts_delta']['switch_utf8_bytes'] == 168
assert author_result['rts_delta']['null_ALI_extra_bytes'] == 171
assert (author_result['global_e_upper'], author_result['save_entering_callbacks_upper'], author_result['saves_upper']) == (2, 2, 3)

# Confirmed exact-checker mismatch: canonicalization by rstrip is broader than
# the prose's optional single slash, while the native consumer preserves it.
malformed = recipe.RUNTIME_SOURCE + '/' * 256
assert recipe.pathfile_entries((malformed + '\n').encode(), work, 'source') == [malformed]
raw_full_name = malformed + 'system.ads'
assert len(raw_full_name.encode()) == 439 and len(raw_full_name) > 395
counterexample = dict(id='F1', location='prospective/recipe.py:132',
    input_kind='source pathfile', input_utf8=malformed + '\n', trailing_slashes=256,
    checker_accepts=True, raw_directory_bytes=len(malformed),
    native_source_derived_full_name_utf8=raw_full_name, full_name_bytes=len(raw_full_name),
    advertised_common_P=188, frozen_arguments_sufficient_endpoint=395,
    violates_prose_optional_single_slash=True, production_counterexample=False,
    selected_GPR_route_shown_to_emit_this=False,
    source_loci=['gcc/osint.adb:403-428', 'gcc/osint.adb:654-656',
                 'gcc/osint.adb:2123-2148', 'gcc/osint.adb:1887-1918'],
    required_correction='Compare raw entries with each allowed spelling or spelling plus one slash; preserve source-generated sequence and cardinality duties.')

result = dict(status='completed_with_one_interface_finding', reviewed_commit=AUTHOR,
    target_sha256=target_hashes, repository_input_count=len(manifest['repository_files']),
    source_archive_count=len(sources), supplemental_complete_source_sha256=sha(knowledge),
    source_anchors=anchors, xml_files=len(xml_names), runtime_changes=runtime_changes,
    configuration_widths=widths, independent_path_demands=derived,
    old_report_joins_and_runtime_corpus_reused=True, counterexample=counterexample,
    actual_complete_common_path_bytes=None, production_configuration_executed=False,
    source_identity_premise_unchanged=True, native_storage_composition_deferred=True,
    physical_resources_assumed=True, global_e_upper=2, save_entering_callbacks_upper=2,
    saves_upper=3, author_or_predecessor_checker_runs=0, native_target_compiler_prover_lean_runs=0,
    fixture_runs=0, live_installation_rescans=0, service_queries=0,
    platform=dict(system=platform.system(), machine=platform.machine(), release=platform.release()),
    selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_model_confirmed=False,
    token_usage=None, cost=None, elapsed_seconds=time.monotonic() - START)
(HERE / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({k: result[k] for k in ('status', 'reviewed_commit', 'repository_input_count',
                                       'source_archive_count', 'xml_files', 'elapsed_seconds')}, indent=2))
