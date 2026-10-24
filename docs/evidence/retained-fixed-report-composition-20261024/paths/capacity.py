"""Source-derived pathname hull for the #212/#194 report configuration.

Lengths are UTF-8 bytes. This constructs a configuration bound, not an
admission predicate. Effective environment and physical-directory attachment
must be established separately; no supplied P can certify those relations.
"""
from dataclasses import dataclass

SOURCES = ('main.adb', 'silver_io.ads', 'silver_io.adb',
           'silver_output_libc.ads', 'silver_arguments.ads',
           'silver_arguments.adb', 'silver_runtime.ads')
REPORTS = ('main~1.spark', 'silver_io.spark', 'silver_output_libc.spark',
           'silver_arguments.spark', 'silver_runtime.spark')
UNITS = ('main~1', 'silver_io', 'silver_output_libc',
         'silver_arguments', 'silver_runtime')


def size(text):
    if '\0' in text:
        raise ValueError('pathname operand contains NUL')
    return len(text.encode('utf-8'))


@dataclass(frozen=True)
class Configuration:
    # Actual pathname spellings, with separate service-returned cwd/real roots.
    workspace_root: str
    physical_workspace_root: str
    initial_and_saved_cwds: tuple[str, ...]
    runtime_roots: tuple[str, ...]
    runtime_names: tuple[str, ...]
    temporary_root: str
    normalized_temporary_root: str
    # All selected additional N/Full_File_Name/Full_Ref_Name and mapping names,
    # including normalized config files and Source_Reference spellings, if any.
    additional_source_and_config_paths: tuple[str, ...] = ()


def domain(config):
    """Construct all named report demands under the README's source relation.

    Two root spellings cover lexical construction and physical getcwd returns.
    Fresh six-character suffixes have equal width; 'XXXXXX' is a width witness,
    not a selected/reused directory. GPR PID and temporary counters retain their
    full source widths. No filesystem access or target process is performed.
    """
    roots = (config.workspace_root, config.physical_workspace_root)
    work = tuple(r.rstrip('/') + '/program-XXXXXX' for r in roots)
    # Include a trailing slash in the object-directory bound: GPR2 directory
    # Value/Dir_Name can retain it and #194 Compose adds its own conservative 1.
    obj = tuple(w + '/obj/gnatprove/' for w in work)
    initial = tuple(config.initial_and_saved_cwds)
    if not initial or not config.runtime_roots or not config.runtime_names:
        raise ValueError('complete cwd and runtime families are required')
    paths = {
        'project_argument': tuple(w + '/program.gpr' for w in work),
        'initial_and_saved_cwd': initial,
        'workspace_directory': work,
        'producer_and_reporter_object_cwd': obj,
        'object_directory': obj,
        'copied_source_and_sloc': tuple(w+'/'+n for w in work for n in SOURCES),
        'runtime_source_and_reference': tuple(r.rstrip('/')+'/'+n
            for r in config.runtime_roots for n in config.runtime_names),
        'config_file': tuple(o+'gnatprove.alfad' for o in obj),
        'ordinary_summary': tuple(o+'gnatprove.out' for o in obj),
        'sarif_file': tuple(o+'gnatprove.sarif' for o in obj),
        'spark_files': tuple(o+n for o in obj for n in REPORTS),
        'gnat2why_options': tuple(o+'00000000.tmp' for o in obj),
        'relative_trace': tuple(u+'__flow__'+'9'*10+'.trace' for u in UNITS),
        'absolute_trace': tuple(o+u+'__flow__'+'9'*10+'.trace'
                                for o in obj for u in UNITS),
        # GPR.Tempdir: chosen normalized temp root/GPR.<positive int32 PID>/
        # GNAT-TEMP-<six digits>.TMP. Failure produces no longer successful name.
        'gpr_configuration_and_naming': tuple(t.rstrip('/')+'/GPR.'+'9'*10
             +'/GNAT-TEMP-999999.TMP'
             for t in (config.temporary_root, config.normalized_temporary_root)),
        'additional_source_and_config': tuple(config.additional_source_and_config_paths),
    }
    demands = {k: max(map(size,v), default=0) for k,v in paths.items()}
    # Reproduce #194's conservative spelling join, including its extra slash
    # even if the object directory already carries one.
    od = demands['object_directory']
    consumer = dict(project_argument=demands['project_argument'],
        initial_and_saved_cwd=max(demands['initial_and_saved_cwd'],od),
        object_directory=od,
        config_file=od+1+len('gnatprove.alfad'),
        ordinary_summary=od+1+len('gnatprove.out'),
        sarif_file=od+1+len('gnatprove.sarif'),
        spark_files=od+1+max(map(len,REPORTS)),
        unit_source_paths=max(demands['copied_source_and_sloc'],
            demands['runtime_source_and_reference'],
            demands['additional_source_and_config']))
    p = max(*demands.values(), *consumer.values())
    return dict(path_demands=demands, consumer_demands=consumer,
        common_path_bytes=p, source_path_bytes=consumer['unit_source_paths'],
        project_path_bytes=consumer['project_argument'], object_dir_bytes=od,
        initial_cwd_bytes=consumer['initial_and_saved_cwd'],
        frozen_arguments_interval_fits=p<=395,
        actual_configuration_relation_established=False,
        admission_decision=False)


def why_domains(*, client_cwd_bytes, canonical_directory_bytes, provider):
    """Keep accepted Why-client path owners distinct from the report hull."""
    if min(client_cwd_bytes, canonical_directory_bytes) < 0:
        raise ValueError('negative byte length')
    return dict(PrecutP=max(180,client_cwd_bytes+10), P_file=180, P_stat=167,
        P_diag={name:max(row['request_path_upper_F'],canonical_directory_bytes+24)
                for name,row in provider.items()},
        canonical_path_bytes=canonical_directory_bytes+24,
        response_frame_bytes=canonical_directory_bytes+72)
