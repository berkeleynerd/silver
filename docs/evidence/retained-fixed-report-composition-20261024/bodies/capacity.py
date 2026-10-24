"""#212 actual Silver_IO source overlay; no native execution or admission rule.

The source proof and remaining joins are in README.md. The accepted provider
functions are imported unchanged; no predecessor checker is executed.
"""
from dataclasses import asdict
import importlib.util
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent


def provider(name, relative):
    spec = importlib.util.spec_from_file_location(name, HERE.parents[1] / relative)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


p = provider('io_report_producer', 'retained-producer-report-capacity-20261024/capacity.py')
c = provider('io_report_consumer', 'retained-required-report-consumers-20261024/capacity.py')

FRONTEND = 19837
WHY_ALLOCATIONS = 16547
SOURCE = {
    'Put_Line': dict(ordinary_assignments=10, side_effect_assignments=3,
                     procedure_calls=4, conditions=4, returns=4, joins=16),
    'Put': dict(ordinary_assignments=8, side_effect_assignments=2,
                procedure_calls=3, conditions=3, returns=3, joins=15),
}
REPORT_NAMES = ('Silver_IO', 'Silver_IO.Put_Line', 'Silver_IO.Put',
                'Silver_Output_Libc.Put_Byte', 'Silver_Output_Libc.Flush',
                'Silver_Output_Libc.Set_Exit_Status')


def graph_rows():
    result = {}
    for name, source in SOURCE.items():
        f = 17
        calls = source['side_effect_assignments'] + source['procedure_calls']
        terms = dict(scaffolding=10, initial_final=2*f,
            assignments=5*source['ordinary_assignments'], calls=15*calls,
            conditions=3*source['conditions'], range_loop=6, invariants=2,
            returns=source['returns'], object_declarations=5*(1+4),
            type_declarations=4*4, postconditions=2, block_overhead=4,
            joins=source['joins'])
        v = sum(terms.values())
        # Preserve initialization/sanity failure paths; do not assume success.
        flow = (4*f+3)*v + (11+8)*f + 13*calls + 4
        array_warning = (source['ordinary_assignments']
                         + source['side_effect_assignments']
                         + source['procedure_calls'] + 4)
        result[name] = dict(flow_ids=f, eligible_vertices=v,
            constructor_vertices=FRONTEND+v, vertex_terms=terms,
            call_nodes=calls, constraint_roots=8, flow_records=flow,
            extra_warning_records=array_warning+13*calls,
            trace_attempts=v+2*v*f)
    f = 7
    terms = dict(scaffolding=10, initial_final=2*f,
                 object_declarations=5*5, type_declarations=4*4,
                 block_overhead=4, joins=6)
    v = sum(terms.values())
    result['Silver_IO'] = dict(flow_ids=f, eligible_vertices=v,
        constructor_vertices=FRONTEND+v, vertex_terms=terms,
        call_nodes=0, constraint_roots=4,
        flow_records=4*v*f+2*v+(8+4)*f+4,
        extra_warning_records=0, trace_attempts=v+2*v*f)
    return result


def mixed_string(ascii_bytes, path_bytes):
    """Printable/fixed ASCII plus unrestricted path bytes; no ASCII-path premise.

    Printable ASCII, quotes/backslashes and the fixed newline recipes cost
    at most two encoded bytes per character; paths retain the generic six.
    The outer quotes are included. UTF-8 validity remains the accepted premise.
    """
    p.natural(ascii_bytes, path_bytes)
    encoded = 2 + 2*ascii_bytes + 6*path_bytes
    return p.Shape(pretty=encoded, compact=encoded, strings=1,
                   string_max=ascii_bytes+path_bytes)


def flow_row(path_bytes):
    # 1189 literal bytes + 12 SPARK RM wrapper + 11 CWE; three names <=762;
    # five source-location strings <=P+64; SARIF surplus <=14*3+8=50.
    text = mixed_string(1189+12+11+3*762+5*64+50, 5*path_bytes)
    return p.object_fields([
        ('file', p.string(path_bytes)), ('line', p.atom(10)), ('col', p.atom(10)),
        ('message', p.object_fields([('text', text)])),
        ('suppressed', p.literal('')), ('rule', p.string(64)),
        ('severity', p.literal('warning')), ('entity', p.atom(10)),
        ('check_tree', p.object_fields([])),
        ('unproved_status', p.object_fields([('status', p.literal('unknown'))])),
        ('tracefile', p.string(33)), ('msg_id', p.atom(10)),
        ('how_proved', p.literal('flow'))])


def warning_row(path_bytes):
    # Reached Image/array warning templates have no surviving placeholder.
    # Warning_Msg_N leaves E/secondary location/response fields at defaults.
    return p.object_fields([
        ('file', p.string(path_bytes)), ('line', p.atom(10)), ('col', p.atom(10)),
        ('message', p.object_fields([('text', p.string(192))])),
        ('suppressed', p.literal('')), ('rule', p.string(64)),
        ('severity', p.literal('warning')), ('check_tree', p.object_fields([])),
        ('unproved_status', p.object_fields([('status', p.literal('unknown'))])),
        ('how_proved', p.literal('trivial'))])


def io_report(*, path_bytes):
    p.natural(path_bytes)
    graphs = graph_rows()
    outside = 2 + 8*18
    flow_count = sum(x['flow_records'] for x in graphs.values()) + outside
    warning_count = WHY_ALLOCATIONS + sum(x['extra_warning_records'] for x in graphs.values())
    traces = sum(x['trace_attempts'] for x in graphs.values())
    flow = p.array(flow_count, flow_row(path_bytes))
    warnings = p.array(warning_count, warning_row(path_bytes))
    # W=max(510,64,550,0+2,6,64)=550. Source-span allocation is a separate join.
    cp = 24*550+2381
    proof_text = 2*cp+277
    proofs = p.canonical_proof(records=40, goals=117, attempts=309, answer_bytes=736,
        row_parameters=dict(path_bytes=path_bytes, text_bytes=proof_text,
                            rule_bytes=64, stats_count=5, stats_key_bytes=7,
                            aux_bytes=path_bytes+24))
    claims = p.claim_domain(6, 6)
    timing_fields = 7+2*6+26*2
    meta = p.metadata(entities=6, location_depth=1,
        name_bytes=max(map(len, REPORT_NAMES)), path_bytes=path_bytes,
        spark_entities=6, skip_flow=0, skip_proof=0, pragma_assume=0,
        claims=claims['claims'], claim_edges=claims['edges'], edges_per_claim=30,
        timing_entities=7, timing_names=timing_fields, timing_fields=timing_fields,
        timing_key_bytes=59, progress_bytes=64, stop_bytes=64)
    full = p.report(meta, warnings=warnings, flow=flow, proof=proofs['full'])
    projected = p.report(meta, warnings=warnings, flow=flow, proof=proofs['projected'])
    lifetime = p.assumption_lifetime(spark=12, skip_flow=0, skip_proof=0,
        vc_timings=12, response_timings=52, entity_messages=flow_count+40,
        pragma_assume=0, claims=30, claim_edges=42, location_depth=1)
    incoming = dict(frontend_nodes=FRONTEND, frontend_entities=FRONTEND,
        graph_count=3, graphs=graphs, outside_flow_records=outside,
        flow_records=flow_count, warning_records=warning_count,
        message_bytes=3818+5*path_bytes, sarif_message_bytes=3868+5*path_bytes,
        warning_message_bytes=192, raw_name_bytes=64, flow_name_bytes=760,
        native_print_calls=3*flow_count+2*warning_count,
        message_ids=flow_count, trace_attempts=traces, trace_counter=traces,
        trace_lines_per_file=max(x['eligible_vertices'] for x in graphs.values()),
        trace_line_bytes=path_bytes+12,
        guards=dict(flow_set=flow_count <= p.HASH,
                    flow_array=flow_count <= 2**30-1,
                    warning_array=warning_count <= 2**30-1,
                    trace_counter=traces <= p.I,
                    trace_lines=max(x['eligible_vertices'] for x in graphs.values())+1 <= p.I,
                    trace_column=path_bytes+12 <= p.I,
                    graph_variables=17 <= p.HASH,
                    constructed_vertex_index=max(x['constructor_vertices'] for x in graphs.values()) <= p.I))
    return dict(unit='Silver_IO', incoming=incoming, entities=6, h=1,
        source=dict(full_name_bytes=max(map(len, REPORT_NAMES)), path_bytes=path_bytes),
        flow=flow_count, warning=warning_count, proof=40, goals=117,
        records=40, attempts=309, responses=2, printed_cp_bytes=cp,
        proof_message_bytes=proof_text, full=full, projected=projected,
        silver_projected_file_bytes=projected.pretty+1, claim_domain=claims,
        third_pool=lifetime, writer=p.representation(full,filename_bytes=path_bytes),
        flow_brief=p.brief_output(message_bytes=3818+5*path_bytes+16,
                                  path_bytes=path_bytes,output_calls=3*flow_count),
        source_counts_bound=True, path_configuration_bound=False,
        native_warning_location_join_complete=False, source_span_join_complete=False,
        whole_process_capacity_bound=False)
