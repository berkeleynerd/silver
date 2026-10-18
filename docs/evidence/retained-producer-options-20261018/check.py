#!/usr/bin/env python3
"""Source-pinned option/configuration arithmetic; no native/proof execution."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def main():
    identity = json.loads((HERE / 'identity.json').read_text())
    sources = {}
    for row in identity['archives']:
        archive = ROOT / row['path']
        assert hashlib.sha256(archive.read_bytes()).hexdigest() == row['sha256']
        with tarfile.open(archive) as tar:
            for item in row['files']:
                data = tar.extractfile(item['member']).read()
                assert len(data) == item['bytes']
                assert hashlib.sha256(data).hexdigest() == item['sha256']
                sources[item['name']] = data.decode()
    for item in identity['local_files']:
        data = (ROOT / item['path']).read_bytes()
        assert len(data) == item['bytes']
        assert hashlib.sha256(data).hexdigest() == item['sha256']
        sources[item['path']] = data.decode()

    def has(name, text):
        assert ' '.join(text.split()) in ' '.join(sources[name].split()), name

    has('writer', 'GNAT.SHA1.Digest (Write_Cont) (1 .. 8) & ".tmp"')
    has('writer', 'Set_Field (Obj, Warning_Status_Name, To_JSON (FS.Warning_Status));')
    has('writer', 'Set_Field (Obj, Why3_Args_Name, To_JSON (Compute_Why3_Args (Obj_Dir, FS)));')
    has('configuration', 'File_Specific_Map.Insert ("default", Default);')
    has('configuration', 'File_Specific_Map.Delete ("Ada");')
    has('configuration', 'Key => String (Units (C).Main_Part.Source.Simple_Name), New_Item => Gen')
    has('configuration', 'Parallel := Natural (System.Multiprocessors.Number_Of_CPUs);')
    has('configuration', 'Use_Semaphores := not Debug and then not CL_Switches.Dbg_No_Sem;')
    has('configuration', 'FS.CE_Timeout := (if FS.CE_Steps > 0 then 0 elsif FS.Timeout = 0 then Constants.Max_CE_Timeout')
    has('configuration', 'if Proof_Input = "" then FS.Proof := Per_Check;')
    has('configuration', 'if Lazy_Input = "" then FS.Lazy := True;')
    has('configuration', '"why3server_" & PID_String (PID_String\'First + 1 .. PID_String\'Last) & ".sock"')
    has('configuration_spec', 'is (Ada.Directories.Base_Name (Socket_Name.all));')
    has('reader', 'for Var_Index in Positive range 1 .. Length (Ar) loop Why3_Args.Append (Get (Get (Ar, Var_Index)));')
    has('warnings_body', "for MW in Misc_Warning_Kind loop Set_Field (Obj, Misc_Warning_Kind'Image (MW), Warning_Enabled_Status'Image (W (MW)));")
    has('gnatprove', 'if Debug then Args.Append ("--logging"); end if; Id := Non_Blocking_Spawn ("why3server", Args);')
    has('gnatprove', 'Integer\'Max (1, Parallel / Num_Provers);')
    has('gnatprove', 'Set_Key_Value ("command", Build_Prover_Command (Prover, Args_Step => False));')
    has('named_semaphores', 'S := Create_Semaphore_C (To_C (Name), unsigned (Init));')
    has('semaphores_c', 'sem_open (name, O_CREAT | O_EXCL, 0600, init)')

    enum = re.search(r'type Misc_Warning_Kind is\s*\((.*?)\);', sources['warnings'], re.S)[1]
    warnings = re.findall(r'\b\w+\b', re.sub(r'--[^\n]*', '', enum))
    assert len(warnings) == 63
    warning_map = {key.upper(): 'WS_DISABLED' for key in warnings}
    # WS_DISABLED and false are independent conservative width envelopes.
    # They need not be the actual status/value selected for every field.
    arguments = ['spark_semaphore_wrapper', 'gnatwhy3', '--timeout', '0',
                 '--steps', '100000', '--ce-steps', '0', '--memlimit', '1000',
                 '--prover', 'cvc5,z3,altergo', '--proof', 'per_check', '-j',
                 '2147483647', '--counterexample', 'on', '--giant-step-rac',
                 'on', '--rac-prover', 'cvc5', '--warn-prover', 'cvc5',
                 '--ce-timeout', '10']
    assert len(arguments) == 26
    for arg in ['--timeout=0', '--steps=100000', '--memlimit=1000', '--level=2',
                '--prover=cvc5,z3,altergo', '-j0', '--no-loop-unrolling']:
        assert arg in sources['src/silver.adb']
    path = object()
    common = dict(global_gen_mode=False, output_mode='GPO_PRETTY_SIMPLE',
                  exclude_line='', gnattest_values='', debug_exec_rac=False,
                  debug=False, flow_advanced_debug=False, flow_generate_contracts=False)
    extra = dict(limit_units=False, limit_subp='', limit_region='', limit_name='',
                 limit_lines=[], report_mode='GPR_ALL', warning_mode='SW_TREAT_AS_ERROR',
                 flow_show_gg=False, proof_generate_axiom_guards=False,
                 ide_mode=False, cwe=False, parallel_why3=False, why3_dir=path)
    fs = dict(check_counterexamples=False, no_loop_unrolling=False,
              no_inlining=False, gp_mode='GPM_ALL', warning_status=warning_map)

    def size(value):
        if value is path:
            return 2, 6
        if isinstance(value, dict):
            children = [(len(json.dumps(k)) + 1 + a, b)
                        for k, v in value.items() for a, b in [size(v)]]
        elif isinstance(value, list):
            children = [size(v) for v in value]
        else:
            return len(json.dumps(value, separators=(',', ':'))), 0
        return (2 + max(0, len(value) - 1) + sum(a for a, b in children),
                sum(b for a, b in children))

    option_rows = []
    for phase in [1, 2]:
        row = fs | (dict(proof_warnings=False, why3_args=arguments) if phase == 2 else {})
        tree = common | (extra if phase == 2 else {}) | {'file_specific': {'default': row, 'main.adb': row}}
        constant, coefficient = size(tree)
        option_rows.append(dict(phase=phase, root_fields=len(tree),
                               file_specific_rows=2, row_fields=len(row),
                               compact_bytes=dict(constant=constant, path_byte_coefficient=coefficient),
                               file_bytes=dict(constant=constant+1, path_byte_coefficient=coefficient),
                               evaluations=[dict(path_bytes=p, file_bytes=constant+coefficient*p+1,
                                                 unbounded_allocation_bytes=64+(constant+coefficient*p)*3//2+128)
                                            for p in [222, 4096]]))
    assert [x['root_fields'] for x in option_rows] == [9, 22]

    config_bytes = (HERE / 'gnatprove.conf').read_bytes()
    config = json.loads(config_bytes)
    assert len(config['provers']) == 9 and len(config['editors']) == 1
    lines = ['[main]', 'magic =  ' + str(config['magic']), 'memlimit =  ' + str(config['memlimit'])]
    commands = []

    def command(prover, steps=False):
        result = ' '.join([prover['executable']] + prover['args_steps' if steps else 'args_time'] + prover['args'])
        commands.append(result)
        return result

    def string(key, value):
        lines.append(key + ' = "' + value + '"')

    for editor in config['editors']:
        lines.append('[editor ' + editor['title'] + ']')
        string('name', editor['name'])
        string('command', command(editor))
    for prover in config['provers']:
        lines.append('[prover]')
        string('command', command(prover))
        if 'args_steps' in prover:
            string('command_steps', command(prover, True))
        for key in ['driver', 'name', 'shortcut', 'version']:
            string(key, prover[key])
        if 'interactive' in prover:
            lines.append('interactive = ' + str(prover['interactive']).lower())
        if 'editor' in prover:
            string('editor', prover['editor'])
        if 'in_place' in prover:
            lines.append('in_place = ' + str(prover['in_place']).lower())
    output = '\n'.join(lines) + '\n'

    def inventory(value, depth=0):
        if isinstance(value, dict):
            children = [inventory(v, depth+1) for v in value.values()]
            own = dict(objects=1, arrays=0, strings=0, fields=len(value), array_elements=0,
                       max_fields=len(value), max_array=0, max_string=max(map(len, value), default=0), depth=depth)
        elif isinstance(value, list):
            children = [inventory(v, depth+1) for v in value]
            own = dict(objects=0, arrays=1, strings=0, fields=0, array_elements=len(value),
                       max_fields=0, max_array=len(value), max_string=0, depth=depth)
        else:
            children = []
            own = dict(objects=0, arrays=0, strings=int(isinstance(value, str)), fields=0,
                       array_elements=0, max_fields=0, max_array=0,
                       max_string=len(value) if isinstance(value, str) else 0, depth=depth)
        for child in children:
            for key in own:
                own[key] = max(own[key], child[key]) if key.startswith('max_') or key == 'depth' else own[key]+child[key]
        return own

    result = dict(native_or_proof_executions=0,
                  source_class='15-token null family with permitted ASCII case/trivia; selected project/options/configuration',
                  option_phases=option_rows, warning_fields_per_row=len(warnings),
                  longest_warning_name=max(map(len, warnings)), why3_argument_count=len(arguments),
                  why3_argument_byte_sum_bound=sum(map(len, arguments)),
                  why3_argument_array_capacity=32, why3_argument_max_bytes=max(map(len, arguments)),
                  writer_live_reference_bound=8, parser_with_wrappers_live_reference_bound=46,
                  consumer_live_reference_bound=16, option_schema_container_depth=4,
                  option_filename_bytes=12, gnatwhy3_launches=0, idle_why3server_launches=1,
                  gnatprove_config_input_bytes=len(config_bytes), gnatprove_config_inventory=inventory(config),
                  why3_conf_output_bytes=len(output), why3_conf_line_count=len(lines),
                  why3_conf_max_line_bytes=max(map(len, lines)),
                  why3_conf_max_command_bytes=max(map(len, commands)),
                  socket_basename_byte_bound=26, socket_full_path_bound='socket_directory_bytes + 27',
                  semaphore_name_byte_bound=21, server_argv_count=4,
                  semaphore_initial_value='max(1, floor(J/3))',
                  worker_configuration_condition='1 <= J <= floor(INT_MAX/2); selected -j0 reads Number_Of_CPUs',
                  external_interfaces='Working filesystem, libc/OS process/socket/semaphore services and sufficient resources use the existing trusted boundary.',
                  residuals=['Generic producer ALI writer/reader indices and tables',
                             'GPR2/GPRbuild project/configuration orchestration',
                             'Whole null-family native/producer composition and independent review'])
    assert all(e['file_bytes'] < 65536 for row in option_rows for e in row['evaluations'])
    (HERE / 'why3.conf.reconstructed').write_text(output)
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: result[key] for key in ['option_phases', 'gnatprove_config_input_bytes', 'why3_conf_output_bytes', 'why3_conf_max_line_bytes']}))


if __name__ == '__main__':
    main()
