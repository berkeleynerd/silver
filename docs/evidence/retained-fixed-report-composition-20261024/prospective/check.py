#!/usr/bin/env python3
"""One changed-input check: source/config identities, pure overlay and fixture.

No subprocess, compiler/prover, predecessor checker, native target or service.
This writes result.json and removes only the fresh fixture it created.
"""
from pathlib import Path
from xml.parsers import expat
import xml.etree.ElementTree as ET
import hashlib
import json
import os
import platform
import re
import secrets
import shutil
import tarfile
import time
import recipe as r

START = time.monotonic()
HERE, ROOT = r.HERE, r.ROOT


def sha(data):
    return hashlib.sha256(data).hexdigest()


def rejected(fn, *args):
    try:
        fn(*args)
    except ValueError:
        return
    raise AssertionError('negative predicate case was accepted')


manifest = json.loads((HERE/'source-manifest.json').read_text())
for name, digest in manifest['repository_files'].items():
    assert sha((ROOT/name).read_bytes()) == digest, name
prefix = manifest['accepted_research_prefix']
assert sha((ROOT/prefix['path']).read_bytes()[:prefix['bytes']]) == prefix['sha256']
archive = HERE/'sources.tar.gz'
assert sha(archive.read_bytes()) == manifest['sources_archive_sha256']
with tarfile.open(archive) as t:
    source = {n: t.extractfile(n).read() for n in t.getnames()}
assert set(source) == set(manifest['sources'])
for n, data in source.items():
    assert sha(data) == manifest['sources'][n]['sha256'], n
    assert len(data) == manifest['sources'][n]['bytes'], n


def has(name, text):
    assert text in source[name].decode(), (name, text)


has('gnatcoll/gnatcoll-utils.adb', 'Resolve_Links => True')
has('gnatcoll/gnatcoll-utils.adb', 'return Exec_Path (Exec_Path\'First .. Path_Last - 3);')
has('spark/gnatprove/configuration.ads', 'Prefix                    : constant String := Executable_Location;')
has('spark/gnatprove/configuration.ads', 'if Ada.Environment_Variables.Exists ("GNSA_ROOT")')
has('spark/gnatprove/gnatprove.adb', 'Args.Append ("--RTS=" & CL_Switches.RTS.all);')
has('spark/gnatprove/gnatprove.adb', 'Create (Ada.Directories.Simple_Name (Command_Name))')
has('spark/gnatprove/configuration.adb', 'Proj_Opt.Add_Switch (Options.RTS, CL_Switches.RTS.all);')
has('spark/gnatprove/gnatprove.adb', 'Phase2_Subdir / Data_Representation_Subdir')
has('spark/gnatprove/gnatprove.adb', 'Phase2_Subdir / Phase1_Subdir')
has('spark/common/vc_kinds.ads', 'Data_Representation_Subdir_Name : constant String := "data_representation";')
has('gcc/osint.adb', 'if RTS_Src_Path_Name /= null and then RTS_Lib_Path_Name /= null then')
has('gcc/osint.adb', 'Read_Default_Search_Dirs (Norm_Search_Dir, Search_File, null)')
has('gcc/switch-c.adb', 'Opt.No_Stdinc := True;')
has('gcc/switch-c.adb', 'Store_Compilation_Switch (Switch_Chars);')
has('gcc/lib.adb', 'Compilation_Switches.Increment_Last;')
has('gpr/gpr/src/gpr-conf.adb', 'if Is_Absolute_Path (Runtime_Dir) then')
has('gpr/gpr/src/gpr-env.adb', 'Get_Name_String (Source.Path.Display_Name);')
has('gpr/gpr/src/gpr-env.adb', 'Get_Name_String (Source.Display_File);')
has('gpr/src/gprbuild-compile.adb', 'Set_Env_For_Include_Dirs (Id, Source_Project);')
has('spark/why/gnat2why-driver.adb', 'Max_Why3_Filename_Length : constant := 64;')

# Parse the complete installed database with the one changed runtime operand.
# This is the new XML selection calculation, not a replay of the old descriptor.
config_archive = ROOT/'docs/evidence/retained-producer-gpr-descriptor-20261018/installed-configs.tar.gz'
with tarfile.open(config_archive) as t:
    config = {n: t.extractfile(n).read() for n in t.getnames()}
installed_configs = []
config_path_max = 0
for n, data in config.items():
    p = (Path(r.PREFIX)/'libexec/spark/share/gprconfig'/n[3:] if n.startswith('db/')
         else Path(r.PREFIX)/'share/spark/config'/n)
    assert p.read_bytes() == data, p
    installed_configs.append(dict(path=str(p), sha256=sha(data)))
    config_path_max = max(config_path_max, r.paths.size(str(p)), r.paths.size(os.path.realpath(p)))
assert config_path_max == 177
assert (Path(r.PREFIX)/'share/spark/config/gnatprove.conf').read_bytes() == source['installed/gnatprove.conf']


def parse_xml(name):
    builder = ET.TreeBuilder()
    parser = expat.ParserCreate()
    parser.StartElementHandler = builder.start
    parser.EndElementHandler = builder.end
    parser.CharacterDataHandler = builder.data
    def external(parent, context, system):
        assert '/' not in system and '\\' not in system
        child = parent.ExternalEntityParserCreate(context)
        child.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
        child.Parse(config['db/'+system], True)
        return 1
    parser.ExternalEntityRefHandler = lambda context, base, system, public: external(parser, context, system)
    parser.SetParamEntityParsing(expat.XML_PARAM_ENTITY_PARSING_ALWAYS)
    parser.Parse(config[name], True)
    return builder.close()


def applies(configuration, target):
    for group in configuration:
        if group.tag == 'config':
            continue
        assert group.tag in ('compilers', 'targets', 'hosts')
        def matches(child):
            for key, pattern in child.attrib.items():
                if key == 'except':
                    if pattern and re.search(pattern, target):
                        return False
                else:
                    value = dict(name='GNAT' if group.tag == 'compilers' else target,
                                 version='16.1', runtime=r.RTS, language='Ada')[key]
                    if key == 'language':
                        if pattern.lower() != value.lower():
                            return False
                    elif not re.search(pattern, value):
                        return False
            return True
        yes = any(matches(child) for child in group)
        if group.get('negate', '').lower() == 'true':
            yes = not yes
        if not yes:
            return False
    return True


selected, fragments = [], {}
xml_files = sorted(n for n in config if n.startswith('db/') and n.endswith('.xml'))
assert len(xml_files) == 63
for name in xml_files:
    for index, item in enumerate(parse_xml(name).findall('configuration')):
        fragment = item.findtext('config') or ''
        compiler = re.search(r'package\s+Compiler\s+is(.*?)end\s+Compiler;', fragment, re.I|re.S)
        if compiler is None or not re.search(r'\("ada"\)', compiler[1], re.I):
            continue
        yes = applies(item, 'x86_64-linux')
        assert yes == applies(item, 'x86_64-pc-linux-gnu')
        if yes:
            selected.append([name, index])
            fragments[(name, index)] = fragment
old_selected = json.loads((ROOT/'docs/evidence/retained-producer-gpr-descriptor-20261018/result.json').read_text())['selected_Ada_Compiler_configurations']
assert all(row in selected for row in old_selected)
extra = [row for row in selected if row not in old_selected]
assert len(extra) == 1
assert 'Compiler\'Leading_Required_Switches ("Ada") & ("--RTS=${RUNTIME_DIR(ada)}")' in fragments[tuple(extra[0])]

# Narrow live metadata/content observation: physical roots, selected discovery,
# exact existing configuration and absence of the two runtime pathfiles.
assert platform.system() == 'Linux' and platform.machine() == 'x86_64'
physical = []
for value in ('/tmp', r.PREFIX, r.EXECUTABLE, r.VENDOR, r.RTS, r.RUNTIME_SOURCE, r.RUNTIME_OBJECT):
    assert os.path.realpath(value) == value and os.path.exists(value), value
    physical.append(dict(path=value, realpath=os.path.realpath(value), utf8_bytes=r.paths.size(value)))
for value in (r.RTS+'/ada_source_path', r.RTS+'/ada_object_path'):
    assert not os.path.lexists(value), value
    physical.append(dict(path=value, absent_including_dangling_symlink=True))
executables = []
expected = {'gnatprove': '544e6da2eedc24ce87d9200d44f61e8e789726466e81e68bf8935489d7f5323e',
            'gnat2why': '343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1',
            'spark_report': '2c9d18384bd6fdd4ec5f52a1985aa5f62e8acd224db7f290bbd7bc851ebd9e14'}
discovery_path = r.parent_environment('/tmp/program-XXXXXX')['PATH']
for name in ('gnatprove', 'gprbuild', 'gprconfig', 'gcc', 'gnat2why', 'spark_report', 'gnatls', 'gnatwhy3'):
    value = r.EXECUTABLE if name == 'gnatprove' else r.BUNDLED_BIN+'/'+name
    found = shutil.which(name, path=discovery_path)
    real = (r.EXECUTABLE if name == 'gnatprove' else r.ADAPTER if name == 'gnatwhy3'
            else r.VENDOR+'/libexec/spark/bin/'+name)
    assert found == value and os.path.realpath(value) == real, (name, found)
    assert Path(value).is_symlink() == (name != 'gnatprove')
    data = Path(value).read_bytes()
    assert data[:4] == b'\x7fELF'
    if name in expected:
        assert sha(data) == expected[name]
    executables.append(dict(name=name, path=value, realpath=real, bytes=len(data), sha256=sha(data)))
assert Path(r.EXECUTABLE).read_bytes() == Path(r.VENDOR+'/bin/gnatprove').read_bytes()
adapter_config = Path(r.PREFIX).parent/'generated/silver_image_config.ads'
adapter_config_bytes = adapter_config.read_bytes()
assert ('Native_Gnatwhy3 : constant String := "'+r.VENDOR+'/libexec/spark/bin/gnatwhy3";').encode() in adapter_config_bytes
assert sha(Path(r.VENDOR+'/libexec/spark/bin/gnatwhy3').read_bytes()).encode() in adapter_config_bytes
# The changed empty-derived environment must also preserve On_Path's selected
# provers and server. This is discovery metadata, not a solver/service run.
prover_discovery = []
for name in ('cvc5', 'z3', 'alt-ergo', 'why3server'):
    value = r.BUNDLED_BIN+'/'+name
    real = r.VENDOR+'/libexec/spark/bin/'+name
    assert shutil.which(name, path=discovery_path) == value
    assert Path(value).is_symlink() and os.path.realpath(value) == real
    with open(value, 'rb') as stream:
        assert stream.read(4) == b'\x7fELF'
    prover_discovery.append(dict(name=name, path=value, realpath=real,
                                content_identity_rechecked=False))
parent = json.loads((ROOT/'docs/evidence/retained-producer-parent-20261018/sources.json').read_text())
for n in ('producer/bin/gcc', 'producer/libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1'):
    item = parent['installed'][n]
    assert sha(Path(item['resolved_path']).read_bytes()) == item['sha256']

# A disposable filesystem fixture, not GPR-produced inputs or a target run.
while True:
    work = '/tmp/program-'+secrets.token_hex(3)
    try:
        os.mkdir(work, 0o700)
        break
    except FileExistsError:
        continue
fixture = dict(workspace=work, target_executed=False)
try:
    w = Path(work)
    obj = w/'obj/gnatprove'
    for path in [w/'tmp', obj, obj/'phase1', obj/'data_representation']:
        path.mkdir(parents=True, exist_ok=True)
    env = r.environment(work)
    assert set(env) == {'PATH', 'LC_ALL', 'TMPDIR'}
    assert env['TMPDIR'] == work+'/tmp'
    # The authoritative source is copied byte-for-byte. Null is solely the
    # inhabitant of this directory fixture, never universal report evidence.
    for name in r.SOURCE_NAMES:
        origin = ROOT/('samples/null.adb' if name == 'main.adb' else 'src/'+name)
        (w/name).write_bytes(origin.read_bytes())
        assert (w/name).read_bytes() == origin.read_bytes()
    silver = (ROOT/'src/silver.adb').read_text().splitlines()
    # Decode the exact existing Output_Mode project literal; omit its else arm.
    project = []
    in_project = False
    for line in silver:
        if '"project Program is"' in line:
            in_project = True
        if in_project and '& LF' in line and 'else "' not in line:
            match = re.search(r'"((?:[^"]|"")*)"\s*& LF', line)
            assert match, line
            project.append(match[1].replace('""', '"'))
        if in_project and '"end Program;"' in line:
            break
    project_bytes = ('\n'.join(project)+'\n').encode()
    assert len(project) == 14 and 'with ' not in project_bytes.decode().lower()
    (w/'program.gpr').write_bytes(project_bytes)
    naming = (ROOT/'docs/evidence/retained-producer-gpr-descriptor-20261018/naming.reconstructed.adc').read_bytes()
    assert len(naming) == 327 and b'Source_Reference' not in naming
    pid_dir = w/'tmp/GPR.2147483647'
    pid_dir.mkdir()
    payloads = [r.mapping_bytes(work), naming, (work+'\n').encode(),
                (str(obj/'phase1')+'\n'+r.RUNTIME_OBJECT+'\n').encode()]
    tempfiles = []
    for index, data in enumerate(payloads, 1):
        path = pid_dir/f'GNAT-TEMP-{index:06}.TMP'
        path.write_bytes(data)
        r.temporary_name(str(path), work)
        assert os.path.realpath(path) == str(path)
        tempfiles.append(dict(path=str(path), realpath=str(path), utf8_bytes=r.paths.size(str(path)),
                              bytes=len(data), sha256=sha(data)))
    r.check_mapping(payloads[0], work)
    r.pathfile_entries(payloads[2], work, 'source')
    r.pathfile_entries(payloads[3], work, 'object')
    rejected(r.check_mapping, payloads[0].replace(b'main.adb', b'evil.adb'), work)
    rejected(r.pathfile_entries, b'/foreign/source\n', work, 'source')
    rejected(r.pathfile_entries, b'/foreign/object\n', work, 'object')
    rejected(r.workspace, '/tmp/program-abcdef/../escape')
    rejected(r.workspace, '/tmp/program-\u00e9abcde')
    # A child symlink violates the physical predicate even under a short T.
    (w/'tmp/GPR.1').symlink_to(obj, target_is_directory=True)
    assert os.path.realpath(w/'tmp/GPR.1') != str(w/'tmp/GPR.1')
    (w/'tmp/GPR.1').unlink()
    cwds = [work, str(w/'tmp'), str(w/'obj')] + [str(obj)+s for s in r.PHASES]
    saved = os.open('.', os.O_RDONLY)
    try:
        for cwd in cwds:
            os.chdir(cwd)
            assert os.getcwd() == cwd and os.path.realpath(cwd) == cwd
    finally:
        os.fchdir(saved)
        os.close(saved)
    fixture.update(initial_environment=env, parent_environment_before_service_operands=r.parent_environment(work),
        physical_cwds=cwds, generated_input_origin='hand-prepared prospective fixture, not GPR output',
        project_bytes=len(project_bytes), project_sha256=sha(project_bytes),
        naming_bytes=len(naming), mapping_triples=[list(row) for row in r.mapping_triples(work)],
        temporary_files=tempfiles, source_files=list(r.SOURCE_NAMES),
        source_pathfile_utf8=payloads[2].decode(), object_pathfile_utf8=payloads[3].decode(),
        foreign_mapping_path_and_symlink_cases_rejected=True)
finally:
    shutil.rmtree(work)
fixture['removed_after_check'] = not os.path.lexists(work)
assert fixture['removed_after_check']

hull = r.hull(work)
assert hull['common_path_bytes'] == 188
assert hull['project_path_bytes'] == 31 and hull['object_dir_bytes'] == 34
assert hull['path_demands']['gpr_configuration_and_naming'] == 59
old_paths = json.loads((HERE.parent/'paths/result.json').read_text())
assert old_paths['conditional_installed_configuration']['common_path_bytes'] == 188
assert old_paths['runtime_corpus']['manifest_sha256'] == manifest['runtime_corpus']['accepted_manifest_sha256']
# Reuse the accepted successful report joins at unchanged P; no report replay.
reports = old_paths['fixed_report_joins']
assert len(reports) == 4 and all(row['writer_sufficient'] and row['reader_sufficient'] for row in reports)
configs = []
for workers in (3, r.base.p.I):
    cfg = r.configuration(work, workers)
    bounds = r.base.c.configuration_bounds(cfg, path_bytes=188, max_path=4096, page_size=4096)
    assert cfg['argv_count'] == 19 and bounds['all_guards']
    obj = dict(obj_dirs=[work+'/obj/gnatprove/'], cmdline=cfg['argv'],
               proof_switches={}, mode='GPM_ALL', has_errors=False, colors=False)
    actual = json.dumps(obj, separators=(',', ':'), ensure_ascii=True).encode()+b'\n'
    assert len(actual) <= cfg['config_file_bytes']
    configs.append(dict(worker_width=len(str(workers)), argv=cfg['argv'],
        argv_count=cfg['argv_count'], joined_command_bytes=cfg['joined_command_bytes'],
        config_file_bytes_upper=cfg['config_file_bytes'], fixture_json_bytes=len(actual),
        configuration_reader_guards=bounds['all_guards']))
rts_bytes = r.paths.size('--RTS='+r.RTS)
assert rts_bytes == 168
result = dict(status='pass', scope='prospective environment/path/configuration contract and filesystem inhabitant',
    platform=dict(system=platform.system(), machine=platform.machine()),
    source_config_files=len(source), repository_inputs=len(manifest['repository_files']),
    physical_installation_observation=physical, discovered_executables=executables,
    selected_prover_server_discovery=prover_discovery,
    installed_configuration_files_compared=len(installed_configs)+1,
    installed_configuration_max_physical_path_bytes=config_path_max,
    selected_image_adapter=dict(path=r.ADAPTER, generated_config_path=str(adapter_config),
        generated_config_sha256=sha(adapter_config_bytes), current_routing_preserved=True,
        future_private_protocol_refinement_established=False),
    installed_configuration_manifest_sha256=sha(json.dumps(installed_configs,sort_keys=True).encode()),
    compiler_database=dict(xml_files=63, selected_Ada_Compiler_configurations=selected,
                          additional_configuration=extra, runtime=r.RTS),
    fixture=fixture, prospective_hull=hull, configuration_widths=configs,
    fixed_report_joins_reused=reports, runtime_corpus_evidence_reused=old_paths['runtime_corpus'],
    rts_delta=dict(switch_utf8_bytes=rts_bytes, compiler_argv_entries=1,
        stored_switch_entries_upper=1, stored_switch_payload_bytes_upper=rts_bytes,
        null_phase1_A_rows=11, null_phase1_A_payload=77+rts_bytes,
        null_phase2_A_rows_if_enabled=10, null_phase2_A_payload_if_enabled=70+rts_bytes,
        null_ALI_extra_bytes=rts_bytes+3, null_ALI_bytes_upper=29622804+rts_bytes+3,
        null_ALI_lines_upper=77552, Atree_creation_by_switch_storage=0,
        complete_native_storage_recomposition=False),
    prospective_launcher_implemented=False, effective_native_child_inputs_observed=False,
    actual_complete_common_path_bytes=None, complete_private_why_recipe=False,
    complete_fixed_report_capacity=False, complete_five_report_collector=False,
    global_e_upper=2, save_entering_callbacks_upper=2, saves_upper=3,
    physical_resources_assumed=True, admission_changed=False,
    compiler_prover_native_runs=0, predecessor_checker_replays=0, service_queries=0,
    elapsed_seconds=time.monotonic()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(status=result['status'], elapsed_seconds=result['elapsed_seconds'],
    prospective_P=188, argv_count=19, compiler_database_extra=extra,
    configuration_widths=[{k:v for k,v in row.items() if k!='argv'} for row in configs],
    actual_complete_common_path_bytes=None),indent=2))
