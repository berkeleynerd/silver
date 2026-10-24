"""#194 mathematical source-to-consumer transfer, not an admission test.

Only import accepted provider functions; never execute predecessor checkers.
Source provenance, selected behavior, valid numeric metadata, UTF-8 and physical
resources remain separate premises. A failed sufficient guard is not overflow.
"""
from dataclasses import asdict
import importlib.util
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent

def provider(name, relative):
    spec = importlib.util.spec_from_file_location(name, HERE.parent / relative)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod

p = provider('required_consumer_producer', 'retained-producer-report-capacity-20261024/capacity.py')
r = provider('required_consumer_parser', 'retained-response-parser-capacity-20261023/capacity.py')
I, U, SIZE, HASH = p.I, p.U, p.SIZE, p.HASH
# Recomputed from complete pinned declarations by this packet's checker.
SARIF_SIZES = dict(result=13536, location=13088, logicalLocation=1152,
                   suppression=13952, reportingDescriptor=4368,
                   invocation=12640, run=44256)
REQUIRED_OUTPUT = ('main~1.spark', 'silver_io.spark', 'silver_output_libc.spark',
                   'silver_arguments.spark', 'silver_runtime.spark')


def configuration(*, project_path_bytes, object_dir_bytes, output_mode=True,
                  brief=True):
    p.natural(project_path_bytes, object_dir_bytes)
    # Native argv includes the installation wrapper's forwarded compiler pair.
    args = ['gnatprove', '-P', None, '-U', '--mode=all', '--report=all',
            '--warnings=continue' if output_mode else '--warnings=error',
            '--checks-as-errors=on', '--level=2', '--prover=cvc5,z3,altergo',
            '--steps=100000', '--timeout=0', '--memlimit=1000', '-j0',
            '--no-loop-unrolling']
    if brief:
        args.append('--output=brief')
    args += ['-cargs', '-Wno-free-nonheap-object']
    cmd = sum(len(x) if x is not None else project_path_bytes for x in args) + len(args)-1
    av = p.container([(1, 0, 0, p.literal(x) if x is not None
                       else p.string(project_path_bytes)) for x in args], object_kind=False)
    shape = p.object_fields([
        ('obj_dirs', p.array(1, p.string(object_dir_bytes))), ('cmdline', av),
        ('proof_switches', p.object_fields([])), ('mode', p.literal('GPM_ALL')),
        ('has_errors', p.atom(5)), ('colors', p.atom(5))])
    return dict(argv=args, argv_count=len(args), joined_command_bytes=cmd,
                shape=shape, config_file_bytes=shape.compact+1,
                assumptions=False, output_header=False, quiet=False,
                parent_summary_lines=1, parent_summary_line_bytes=object_dir_bytes+40)


def parser_input(shape, *, compact=False):
    b = (shape.compact if compact else shape.pretty)+1
    d = max(shape.string_max, shape.key_max)
    return dict(B=b, token=min(b, max(6*d+2, 317)),
                key=min(b, 6*shape.key_max+2), decoded=d,
                depth=shape.depth, array=shape.array_max, object=shape.object_max,
                containers=shape.objects+shape.arrays, values=shape.values,
                fields=shape.fields)


def parsed_report(shape, *, path_bytes, max_path, page_size, compact=False):
    inp = parser_input(shape, compact=compact)
    result = r.guard(inp, path_bytes, max_path, page_size)
    # Parser graph is a tree of occurrences. The post-return consumers do not
    # retain JSON nodes in the database or SARIF; census adds at most64 handles.
    refs = max(result['operands']['json_counter'], 64)
    result['guards']['consumer_json_aliases'] = refs < U
    result['guards']['consumer_xstring_aliases'] = 64 < U
    result['all_guards'] = all(result['guards'].values())
    return dict(input=inp, **result)


def selected_unit(**source):
    """Input is the exact accepted selected_report source interface per unit.

    R/G/A are current global occurrence bounds for that producer invocation;
    no new error/callback/save budget is introduced by composing units.
    """
    report = p.selected_report(**source)
    return dict(source=source, **report,
                entities=source['entities'], h=source['instantiation_edges']+1,
                flow=report['incoming']['flow_records'],
                warning=report['incoming']['warning_records'],
                proof=source['records'], goals=source['goals'])


def vector(n, element_bytes):
    """Generated SARIF array allocation and native 3*Length intermediate."""
    p.natural(n, element_bytes)
    cap, growth, multiply = (2 if n else 0), 0, 0
    while cap < n:
        multiply = max(multiply, 3*cap)
        cap = 3*cap//2
        growth += 1
    request = 32+element_bytes*cap if n else 0
    return dict(length=n, capacity=cap, growth_copies=growth,
                multiply=multiply, allocation=request,
                guards=dict(length=n <= I, growth=multiply <= I,
                            allocation=request <= SIZE))


def sarif_shape(rows, decoded):
    """Populated typed writer shape; optional populated fields overcharged."""
    text = p.string(decoded)
    region = p.object_fields([('startLine', p.atom(11)), ('startColumn', p.atom(11))])
    physical = p.object_fields([('artifactLocation', p.object_fields([('uri',text)])),
                                ('region', region)])
    location = p.object_fields([('physicalLocation',physical), ('id',p.atom(11)),
       ('logicalLocations',p.array(1,p.object_fields([('name',text)])))])
    message = p.object_fields([('text',text), ('arguments',p.array(1,text))])
    result = p.object_fields([('ruleId',text), ('kind',text), ('level',text),
       ('message',message), ('locations',p.array(1,location)),
       ('relatedLocations',p.array(1,location)),
       ('suppressions',p.array(1,p.object_fields([('kind',text),('justification',text)])))])
    description = p.object_fields([('text',text)])
    rule = p.object_fields([('id',text), ('shortDescription',description),
                            ('fullDescription',description)])
    driver = p.object_fields([('name',text),('version',text),('organization',text),
                              ('rules',p.array(167,rule))])
    invocation = p.object_fields([('commandLine',text),('endTimeUtc',text),
                                  ('exitCode',p.atom(11)),('executionSuccessful',p.atom(5))])
    run = p.object_fields([('tool',p.object_fields([('driver',driver)])),
        ('invocations',p.array(1,invocation)),('results',p.array(rows,result))])
    return p.object_fields([('version',p.literal('2.1.0')),('runs',p.array(1,run))])


def collector(units, *, command_bytes, version_bytes, path_bytes, max_path,
              page_size, duration_ceiling):
    """Whole spark_report process: config stays live, two sequential passes.

    duration_ceiling is a source/configuration time premise, not an observed
    report value. Require 0<=native Max_Time<=duration_ceiling. Its safe guard
    uses I-128 to avoid the Float(I) rounding endpoint. Runtime metadata types
    and nonnegative finite times/steps remain upstream obligations.
    """
    p.natural(command_bytes, version_bytes, path_bytes, max_path, page_size,
              duration_ceiling)
    if not units:
        raise ValueError('required report set must be nonempty')
    count = len(units)
    entities = sum(x['entities'] for x in units)
    slocs = sum(x['entities']*x['h'] for x in units)
    find = count+2*(entities+slocs)
    rows = sum(x['flow']+x['proof']+x['warning'] for x in units)
    checks = sum(x['flow']+x['proof'] for x in units)
    # Each proved record traverses at most G distinct goal nodes in the
    # accepted fresh forest; each leaf adds one real/Trivial/Checker count.
    # Plus one covers the native PC_Trivial branch without assuming it absent.
    stats = sum(x['proof']*(x['goals']+1) for x in units)
    h = max(x['h'] for x in units)
    name = max(x['source']['full_name_bytes'] for x in units)
    decoded = max(max(x['full'].string_max, x['full'].key_max) for x in units)
    d = max(258, command_bytes, version_bytes, path_bytes, decoded, 20)
    symbol = p.third_pool_domains(entities=entities, filenames=slocs+count,
              location_depth=h, find_calls=find, name_bytes=name, path_bytes=path_bytes)
    parsed = [parsed_report(x['full'], path_bytes=path_bytes,
                            max_path=max_path, page_size=page_size) for x in units]
    vec = {k: vector(n, SARIF_SIZES[k]) for k,n in
           [('result',rows), ('location',1 if rows else 0),
            ('logicalLocation',1 if rows else 0), ('suppression',1 if rows else 0),
            ('reportingDescriptor',167), ('invocation',1), ('run',1)]}
    # Each result has separate primary and related-location vectors of <=1;
    # each primary location has <=1 logical location. Same allocation bound.
    growth = vec['result']['growth_copies']+vec['reportingDescriptor']['growth_copies']
    aliases = 256+16*growth
    # At most one message argument in the accepted Add_Json_Msg source schema.
    # Aligned_Length(1,0), header<=64, element<=128, alignment<=64 => bulk<=64.
    argument_vector = 64+64*128
    # Natural image includes its leading blank: eleven, not ten, bytes.
    prover_cell = 11+2+5*(7+4+1)+4*2+1
    table_width = 6*(prover_cell+3)
    # Covers all branches, including suppression explanation with four strings.
    subp_line = name+h*(path_bytes+11)+18*max(0,h-1)+256
    line = max(table_width, subp_line, 4*decoded+path_bytes+128,
               path_bytes+160, command_bytes+64, 256)
    # Source census: fixed sections<=128 lines, each unit<=4, each subp<=4,
    # each suppressed/pragma record<=2. Add10 retained hardchecks separately.
    lines = 128+4*count+4*entities+2*checks+10
    # Dynamic text can include LF. Its byte envelope also bounds descriptor
    # line increments, without assuming source names/paths contain no LF.
    output_bytes = lines*(line+1)
    native_backing = line+line//2+192
    failure_bytes = count*5*(max(path_bytes+64,214)+1)
    sarif = sarif_shape(rows,d)
    guards = dict(
        wildcard_match_counter=count <= I,
        db_hash_domain=max(count,entities) <= HASH,
        list_counts=max(checks,entities,h)+1 <= I,
        summary_checks=checks <= I,
        summary_stats=stats <= I,
        percent_multiplication=100*max(checks,stats) <= I,
        post_percent_merge=10*100 <= I,
        table_cell=prover_cell <= 1000,
        textio_column=line+1 <= I,
        textio_line=output_bytes+1 <= I,
        stderr_line=failure_bytes+1 <= I,
        sarif_file_offset=sarif.compact <= 2**63-1,
        text_backing=native_backing <= I,
        float_to_integer=duration_ceiling <= I-128,
        vss_character_count=d <= 2**30-1,
        vss_alignment=d+129 <= I,
        vss_allocation=d+129 <= SIZE,
        vss_refcount=aliases < U,
        native_record_request=64+4096*I <= SIZE,
        path_compose=path_bytes+64 <= I)
    return dict(report_count=count, parse_passes=2, report_parsers=parsed,
                entities=entities, location_occurrences=slocs, symbol_pool=symbol,
                find_calls=find, diagnostic_rows=rows, check_rows=checks,
                statistic_count=stats, prover_names=5,
                db_max_unit_subps=entities, difficult_transient=11,
                difficult_retained=10, summary_rows=12, summary_columns=6,
                prover_cell_bytes=prover_cell, text_line_bytes=line,
                text_explicit_lines=lines, text_output_bytes=output_bytes, failure_output_bytes=failure_bytes,
                sarif_file_bytes=sarif.compact, sarif_depth=sarif.depth,
                text_unbounded_backing=native_backing,
                sarif_vectors=vec, sarif_string_bytes=d,
                sarif_string_allocation=d+129, vss_aliases=aliases,
                argument_vector_allocation=argument_vector,
                sarif_output_character_allocation=64, guards=guards,
                all_guards=(all(guards.values())
                            and all(symbol['guards'].values())
                            and all(x['all_guards'] for x in parsed)
                            and all(all(x['guards'].values()) for x in vec.values())))


def silver_reader(unit, *, kind, path_bytes):
    if kind not in ('main', 'runtime', 'null'):
        raise ValueError('reader kind')
    p.natural(path_bytes)
    raw, projected = unit['full'], unit['projected']
    b = raw.pretty+1 if kind == 'null' else unit['silver_projected_file_bytes']
    buffer = 16_777_216 if kind == 'main' else 262_144
    # Null raw file loads into16MiB storage, but its recognizer only admits256KiB.
    guards = dict(current_buffer=b <= buffer,
                  current_path=1 <= path_bytes <= 4096,
                  c_path_terminator=path_bytes+1 <= I,
                  cursor_spare=b+2 <= I,
                  raw_projection_depth=kind == 'null' or raw.depth <= 64,
                  audit_depth=kind == 'null' or projected.depth <= 64,
                  padded_reference=b+1 <= I)
    return dict(kind=kind, raw_bytes=raw.pretty+1, retained_bytes=b,
                current_guard_bytes=buffer,
                native_read_buffer_bytes=262_144 if kind == 'runtime' else 16_777_216,
                c_path_bytes=path_bytes+1, raw_native_byte_counter=False,
                ghost_histories_erased=True, guards=guards,
                current_sufficient=all(guards.values()),
                scalable_required=dict(retained_capacity=b,
                  raw_nesting=raw.depth, audit_nesting=projected.depth,
                  cursor_max=b+2, largest_audit_copy=b+1,
                  whole_file_copies=2 if kind == 'null' else 0))


def configuration_bounds(config, *, path_bytes, max_path, page_size):
    shape = config['shape']
    parsed = parsed_report(shape, path_bytes=path_bytes, max_path=max_path,
                           page_size=page_size, compact=True)
    # The accepted pretty-writer bound also safely overcharges compact writing.
    written = p.representation(shape, filename_bytes=path_bytes)
    c = config['joined_command_bytes']
    backing = c+c//2+192
    guards = dict(joined_string=c+1 <= I, joined_backing=backing <= I,
                  command_json_aliases=64 < U, config_path=path_bytes+64 <= I)
    return dict(parser=parsed, writer=written, joined_backing=backing,
                guards=guards, all_guards=all(guards.values())
                and parsed['all_guards'] and written['sufficient'])


def compose(source_by_report, *, output_mode, brief, project_path_bytes,
            object_dir_bytes, path_bytes, max_path, page_size, version_bytes,
            duration_ceiling):
    """Complete required-set join; no observed report is accepted as a bound.

    A caller may separately specialize accepted source functions for fixed
    libraries, but must preserve their exported dimensions and provenance.
    """
    required = REQUIRED_OUTPUT if output_mode else ('main~1.spark',)
    if set(source_by_report) != set(required):
        raise ValueError('source bindings must cover exactly the required set')
    units = [selected_unit(**source_by_report[n]) for n in required]
    config = configuration(project_path_bytes=project_path_bytes,
               object_dir_bytes=object_dir_bytes, output_mode=output_mode,brief=brief)
    cb = configuration_bounds(config, path_bytes=path_bytes,
                              max_path=max_path,page_size=page_size)
    collect = collector(units,command_bytes=config['joined_command_bytes'],
               version_bytes=version_bytes,path_bytes=path_bytes,max_path=max_path,
               page_size=page_size,duration_ceiling=duration_ceiling)
    readers = {n:silver_reader(x,kind=('main' if output_mode else 'null')
                              if n=='main~1.spark' else 'runtime',path_bytes=path_bytes)
               for n,x in zip(required,units)}
    return dict(required=list(required),config={**config,'shape':asdict(config['shape'])},
                configuration=cb,collector=collect,silver=readers,
                consumer_native_guards=cb['all_guards'] and collect['all_guards'],
                current_silver_guards=all(x['current_sufficient'] for x in readers.values()),
                source_inputs_bound=False,physical_resources_assumed=True,
                admission_decision=False)
