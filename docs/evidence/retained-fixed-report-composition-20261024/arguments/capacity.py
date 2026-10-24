"""#212 actual Arguments report composition; conditional paths, no admission gate.

Imports the independently accepted IO overlay and accepted #193/#194 helpers
unchanged. Source classification and generated-slot derivation are in README.
"""
from dataclasses import replace
import importlib.util
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('arguments_io_report',
                                             HERE.parent/'bodies/capacity.py')
io = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = io
spec.loader.exec_module(io)
p, c = io.p, io.c

FRONTEND = 19921
WHY_ALLOCATIONS = 13070
REPORT_NAMES = (
    'Silver_Arguments', 'Silver_Arguments.Is_Message',
    'Silver_Arguments.Input_Is_Valid', 'Silver_Arguments.First_Or_Default',
    'Silver_Arguments.Reject', 'Silver_Runtime.Argument_Count',
    'Silver_Runtime.Argument', 'Silver_Output_Libc.Set_Exit_Status')
# typed call occurrences upper-bound both aliasing checks and any one vertex's
# call set. Pure calls are within expression vertices, not side-effect calls.
SOURCE = {
    'Is_Message': dict(roots=5, captures=2, string_temporaries=0, types=4,
        objects=0, conditions=0, simple_returns=1, extended_returns=0,
        statement_calls=0, blocks=1, joins=8, contracts=2, call_frontier=0),
    'Input_Is_Valid': dict(roots=6, captures=2, string_temporaries=1, types=4,
        objects=0, conditions=2, simple_returns=3, extended_returns=0,
        statement_calls=0, blocks=1, joins=11, contracts=2, call_frontier=8),
    'First_Or_Default': dict(roots=15, captures=8, string_temporaries=1, types=12,
        objects=3, conditions=5, simple_returns=2, extended_returns=2,
        statement_calls=0, blocks=2, joins=27, contracts=2, call_frontier=16),
    'Reject': dict(roots=1, captures=0, string_temporaries=0, types=0,
        objects=0, conditions=0, simple_returns=0, extended_returns=0,
        statement_calls=1, blocks=1, joins=6, contracts=0, call_frontier=1),
}


def graph_rows():
    result = {}
    for name, s in SOURCE.items():
        f = 2*s['roots']+1
        terms = dict(scaffolding=10, initial_final=2*f,
            conditions=3*s['conditions'], simple_returns=3*s['simple_returns'],
            extended_returns=4*s['extended_returns'],
            object_declarations=5*(s['objects']+s['captures']+s['string_temporaries']),
            type_declarations=4*s['types'], contracts=s['contracts'],
            calls=15*s['statement_calls'], blocks=4*s['blocks'], joins=s['joins'])
        v = sum(terms.values())
        q = 2*s['types']
        call = s['call_frontier']
        # Keep function side-effect/volatility, all initialization/sanity paths,
        # generic termination scans and their success messages. The sole
        # removed VF family is explicit Proof_In reads: these Global contracts
        # have none, or the callable has no user Global and fails that filter.
        flow = q*f + 5*v*f + 12*f + v*(4+call) + 13*call + 6
        result[name] = dict(flow_ids=f, eligible_vertices=v,
            constructor_vertices=FRONTEND+v, vertex_terms=terms,
            constraint_roots=q, call_frontier=call, flow_records=flow,
            extra_warning_records=13*call, trace_attempts=v+2*v*f)
    # No package objects or executing calls. Keep conservative empty body,
    # initial/final and join allowances; all other construction is null.
    terms = dict(scaffolding=10, initial_final=2, blocks=4, joins=6)
    v = sum(terms.values())
    result['Silver_Arguments'] = dict(flow_ids=1, eligible_vertices=v,
        constructor_vertices=FRONTEND+v, vertex_terms=terms,
        constraint_roots=0, call_frontier=0, flow_records=6*v+12,
        extra_warning_records=0, trace_attempts=3*v)
    return result


def flow_row(path_bytes):
    # Same reached schema and max literal/marker census as accepted IO. The
    # relative trace basename is seven bytes longer (40 rather than 33).
    old = io.flow_row(path_bytes)
    assert old.string_max >= 40
    return replace(old, pretty=old.pretty+6*7, compact=old.compact+6*7)


def arguments_report(*, path_bytes):
    p.natural(path_bytes)
    graphs = graph_rows()
    # Four required-contract attempts; 20 root visits * 32 whole proof roots.
    outside = 4+20*32
    flow_count = sum(x['flow_records'] for x in graphs.values())+outside
    warning_count = WHY_ALLOCATIONS+sum(x['extra_warning_records'] for x in graphs.values())
    traces = sum(x['trace_attempts'] for x in graphs.values())
    flow = p.array(flow_count,flow_row(path_bytes))
    warnings = p.array(warning_count,io.warning_row(path_bytes))
    proofs = p.canonical_proof(records=11,goals=39,attempts=95,answer_bytes=736,
        row_parameters=dict(path_bytes=path_bytes,text_bytes=31439,rule_bytes=64,
                            stats_count=5,stats_key_bytes=7,aux_bytes=path_bytes+24))
    # All pairs over the eight source-report identities deliberately overcharge
    # the acyclic selected call graph; this is not eight frontend entities.
    claims = p.claim_domain(8,8*8)
    timing_fields = 7+2*8+26*3
    meta = p.metadata(entities=8,location_depth=1,
        name_bytes=max(map(len,REPORT_NAMES)),path_bytes=path_bytes,
        spark_entities=8,skip_flow=0,skip_proof=0,pragma_assume=0,
        claims=claims['claims'],claim_edges=claims['edges'],edges_per_claim=40,
        timing_entities=9,timing_names=timing_fields,timing_fields=timing_fields,
        timing_key_bytes=59,progress_bytes=64,stop_bytes=64)
    full = p.report(meta,warnings=warnings,flow=flow,proof=proofs['full'])
    projected = p.report(meta,warnings=warnings,flow=flow,proof=proofs['projected'])
    lifetime = p.assumption_lifetime(spark=16,skip_flow=0,skip_proof=0,
        vc_timings=16,response_timings=78,entity_messages=flow_count+11,
        pragma_assume=0,claims=40,claim_edges=448,location_depth=1)
    incoming = dict(frontend_nodes=FRONTEND,frontend_entities=FRONTEND,
        graph_count=5,graphs=graphs,outside_flow_records=outside,
        flow_records=flow_count,warning_records=warning_count,
        message_bytes=3818+5*path_bytes,sarif_message_bytes=3868+5*path_bytes,
        warning_message_bytes=192,raw_name_bytes=128,flow_name_bytes=760,
        native_print_calls=3*flow_count+2*warning_count,message_ids=flow_count,
        trace_attempts=traces,trace_counter=traces,trace_filename_bytes=40,
        trace_lines_per_file=max(x['eligible_vertices'] for x in graphs.values()),
        trace_line_bytes=path_bytes+12,
        guards=dict(flow_set=flow_count <= p.HASH,
            flow_array=flow_count <= 2**30-1,warning_array=warning_count <= 2**30-1,
            trace_counter=traces <= p.I,
            trace_lines=max(x['eligible_vertices'] for x in graphs.values())+1 <= p.I,
            trace_column=path_bytes+12 <= p.I,graph_variables=31 <= p.HASH,
            constructed_vertex_index=max(x['constructor_vertices'] for x in graphs.values()) <= p.I))
    return dict(unit='Silver_Arguments',incoming=incoming,entities=8,h=1,
        source=dict(full_name_bytes=max(map(len,REPORT_NAMES)),path_bytes=path_bytes),
        flow=flow_count,warning=warning_count,proof=11,goals=39,records=11,
        attempts=95,responses=3,printed_cp_bytes=15581,proof_message_bytes=31439,
        full=full,projected=projected,silver_projected_file_bytes=projected.pretty+1,
        claim_domain=claims,third_pool=lifetime,
        writer=p.representation(full,filename_bytes=path_bytes),
        flow_brief=p.brief_output(message_bytes=3818+5*path_bytes+16,
                                  path_bytes=path_bytes,output_calls=3*flow_count),
        source_counts_bound=True,path_configuration_bound=False,
        native_warning_location_join_complete=False,source_span_join_complete=False,
        whole_process_capacity_bound=False)
