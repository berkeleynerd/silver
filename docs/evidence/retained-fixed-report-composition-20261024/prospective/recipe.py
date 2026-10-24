"""Prospective #88/#89 refinement contract; no launcher or admission decision.

Import only frozen mathematical providers, never their checkers. Paths are
UTF-8 bytes. A concrete fixture inhabits this contract, not a native execution.
"""
from pathlib import Path
import importlib.util
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def provider(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


base = provider('prospective_fixed',
    'docs/evidence/retained-fixed-report-composition-20261024/capacity.py')
paths = provider('prospective_paths',
    'docs/evidence/retained-fixed-report-composition-20261024/paths/capacity.py')
VENDOR = '/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef'
PREFIX = '/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/image-tools'
BUNDLED_BIN = PREFIX + '/libexec/spark/bin'
EXECUTABLE = PREFIX + '/bin/gnatprove'
ADAPTER = '/home/canto/src/github.com/berkeleynerd/silver/.silver/linux-x86_64/compiler/bin/silver_image_adapter'
RTS = VENDOR + '/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0'
RUNTIME_SOURCE = RTS + '/adainclude'
RUNTIME_OBJECT = RTS + '/adalib'
SOURCE_NAMES = paths.SOURCES
PHASES = ('', '/phase1', '/data_representation')


def workspace(value):
    if re.fullmatch(r'/tmp/program-[A-Za-z0-9]{6}', value) is None:
        raise ValueError('fresh physical /tmp/program-<six ASCII alnum> required')
    return value


def environment(work):
    workspace(work)
    # Construct from empty, without consulting or merging the caller's environ.
    return dict(PATH=PREFIX + '/bin:/usr/bin:/bin', LC_ALL='C', TMPDIR=work+'/tmp')


def parent_environment(work):
    env = environment(work)
    env['PATH'] = BUNDLED_BIN + ':' + BUNDLED_BIN + ':' + env['PATH']
    env['GPR_PROJECT_PATH'] = ':' + PREFIX+'/lib/gnat:'+PREFIX+'/share/gpr'
    env['GPR_TOOL'] = 'gnatprove'
    return env


def configuration(work, workers):
    """19 serialized argv entries; argv[0] is Simple_Name(Command_Name)."""
    workspace(work)
    old = base.prospective_configuration(project_path_bytes=paths.size(work+'/program.gpr'),
        object_dir_bytes=paths.size(work+'/obj/gnatprove/'), workers=workers)
    args = list(old['argv'])
    args[2] = work+'/program.gpr'
    args.insert(args.index('-cargs'), '--RTS='+RTS)
    p = base.p
    argv = p.container([(1, 0, 0, p.literal(a)) for a in args], object_kind=False)
    # Retain the conservative possibly trailing-slash object directory spelling.
    shape = p.object_fields([
        ('obj_dirs', p.array(1, p.literal(work+'/obj/gnatprove/'))),
        ('cmdline', argv), ('proof_switches', p.object_fields([])),
        ('mode', p.literal('GPM_ALL')), ('has_errors', p.atom(5)),
        ('colors', p.atom(5))])
    return dict(old, argv=args, argv_count=len(args), shape=shape,
        joined_command_bytes=sum(paths.size(a) for a in args)+len(args)-1,
        config_file_bytes=shape.compact+1,
        execve_executable=EXECUTABLE,
        execve_argv=[EXECUTABLE]+args[1:], initial_environment=environment(work),
        cwd=work, concrete_path_join_complete=False)


def hull(work):
    workspace(work)
    obj = work+'/obj/gnatprove'
    # Source-derived phase cwd families and bounded .gnat-json filename are
    # additional to the frozen path packet. Physical equality is a separate
    # required filesystem relation, demonstrated for the fixture only.
    cwds = (work, work+'/tmp', work+'/obj') + tuple(obj+s for s in PHASES)
    extra = (obj+'/'+'x'*64, RTS, RUNTIME_OBJECT)
    cfg = paths.Configuration('/tmp', '/tmp', cwds, (RUNTIME_SOURCE,),
        ('standard.ads.h',), work+'/tmp', work+'/tmp', extra)
    result = paths.domain(cfg)
    result['prospective_contract_common_path_bytes'] = result['common_path_bytes']
    result['actual_complete_common_path_bytes'] = None
    return result


def mapping_triples(work):
    workspace(work)
    return tuple((name[:-4]+('%s' if name.endswith('.ads') else '%b'),
                  name, work+'/'+name) for name in SOURCE_NAMES)


def mapping_bytes(work):
    return ''.join('\n'.join(row)+'\n' for row in mapping_triples(work)).encode()


def check_mapping(data, work):
    """GPR hash iteration order is immaterial; triples and multiplicity are exact."""
    if not data.endswith(b'\n'):
        raise ValueError('mapping must end in LF')
    lines = data.decode('utf-8').split('\n')[:-1]
    rows = [tuple(lines[i:i+3]) for i in range(0, len(lines), 3)]
    if sorted(rows) != sorted(mapping_triples(work)):
        raise ValueError('mapping differs from the seven current project sources')


def pathfile_entries(data, work, kind):
    """Check every effective directory, with no unexamined inherited input.

    This checks pathname provenance, not file length/cardinality capacity.
    GPR supplies ordering/multiplicity; their storage owner must retain both.
    Match raw bytes: native directory normalization preserves trailing slashes.
    """
    workspace(work)
    obj = work+'/obj/gnatprove'
    allowed = ({work, RUNTIME_SOURCE} if kind == 'source' else
               {work+'/obj', RUNTIME_OBJECT} | {obj+s for s in PHASES})
    if kind not in ('source', 'object') or not data.endswith(b'\n'):
        raise ValueError('LF-terminated source/object pathfile required')
    values = data.decode('utf-8').split('\n')[:-1]
    allowed_spellings = allowed | {p+'/' for p in allowed}
    if not values or any(v not in allowed_spellings for v in values):
        raise ValueError('effective pathfile escapes the selected directory family')
    return values


def temporary_name(value, work):
    workspace(work)
    if re.fullmatch(re.escape(work)+r'/tmp/GPR\.[1-9][0-9]{0,9}/GNAT-TEMP-[0-9]{6}\.TMP', value) is None:
        raise ValueError('temporary filename outside source-derived family')
    if paths.size(value) > paths.size(work+'/tmp')+36:
        raise ValueError('temporary path wider than source bound')
    # Caller must independently establish realpath(value) == value, freshness,
    # ordinary controlled descendants, and stability through the consuming read.
    return value
