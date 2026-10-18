#!/usr/bin/env python3
"""Check the retained source/read-projection packet; no compiler/prover run."""
import hashlib
import json
from pathlib import Path
import tarfile


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


root = Path(__file__).resolve().parent
manifest = json.loads((root / 'sources.json').read_bytes())
assert identity((root / 'sources.tar.gz').read_bytes()) == manifest['archive']
with tarfile.open(root / 'sources.tar.gz') as tar:
    sources = {m.name: tar.extractfile(m).read() for m in tar if m.isfile()}
assert set(sources) == set(manifest['sources'])
for name, raw in sources.items():
    row = manifest['sources'][name]
    assert identity(raw) == dict(bytes=row['bytes'], sha256=row['sha256']), name
installed = manifest['installed']
system = 'lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude/system.ads'
assert installed['producer/' + system]['sha256'] == installed['native/' + system]['sha256']
compiler = 'libexec/gcc/x86_64-pc-linux-gnu/16.1.0/gnat1'
assert installed['producer/' + compiler]['sha256'] != installed['native/' + compiler]['sha256']
assert installed['producer/' + compiler]['sha256'] == '5e93a62546d5538c3744c04c1b5989dc248f4a90ff47f6ea2f2d0bf3e2e2e1f6'
# These assertions retain the reviewed branch anchors; the source reasoning is
# in the companion record, not inferred from substring matches alone.
assert b'else Libexec_Spark);' in sources['spark/src/gnatprove/configuration.ads']
assert b'Translation_Phase /= GS_Data_Representation' in sources['spark/src/gnatprove/gnatprove.adb']
listing = sources['gpr2/src/private/gpr2-build-view_tables-update_sources_list.adb']
assert b'and then not Units.Is_Indexed_List' in listing
assert b'if not Src_Ref.Has_Naming_Exception then' in listing
assert b'and then not S_Ref.Has_Index' in sources['gpr2/src/private/gpr2-build-view_tables.adb']
assert b'Self.Tree_Db.Ref.Refresh (Option, Messages);' in sources['gpr2/src/private/gpr2-tree_internal.adb']
flag = '-Wno-free-nonheap-object'
assert len(flag) == 24
assert b"'f' | 'g' | 'm' | 'O' | 'W' | 'w'" in sources['spark/src/why/gnat2why-driver.adb']
assert b'Lib.Store_Compilation_Switch (Switch_Chars);' in sources['gcc/ada/adabkend.adb']
switch_delta = dict(phase1_argc=17, phase2_argc=17, datarep_argc=19,
                    phase1_A=10, phase1_A_sum=77, phase1_A_max=24,
                    phase2_stored_A=9, phase2_A_sum=70, phase2_A_max=24,
                    null_ALI_file_bound=29622777 + len(flag) + 3,
                    null_ALI_record_bound=789, null_ALI_lines=77551)
# Same six-field JSON schema as the prior null-global packet, with two exact
# fixed arguments added. Each array string contributes length+3 bytes; the
# joined command contributes the two payloads and two separating spaces.
extra_args = ['-cargs', flag]
configuration_constant = 313 + sum(len(s) + 3 for s in extra_args)
command_constant = 181 + sum(len(s) + 1 for s in extra_args)
assert configuration_constant == 349 and command_constant == 213
switch_delta['parent_configuration'] = dict(cmdline_entries=17, cmdline_capacity=32,
    file_byte_bound_constant=configuration_constant, path_coefficient=12,
    joined_command_constant=command_constant, joined_command_path_coefficient=1,
    file_bytes_at_P4096=configuration_constant+12*4096,
    small_file_reader_at_P4096=configuration_constant+12*4096<65536)
result = dict(source_files=len(sources), system_bytes_equal=True,
              distinct_compiler_binaries=True, indexed_Main_source_parses_in_GPR2_discovery=0,
              proposed_warning_switch_delta=switch_delta,
              source_reasoning_required=True, whole_producer_capacity_established=False,
              compiler_or_prover_executed=False)
print(json.dumps(result, sort_keys=True))
