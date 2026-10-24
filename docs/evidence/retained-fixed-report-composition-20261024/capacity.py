"""#212 fixed-source specialization; mathematical bounds, no native execution.

Only the two specification processes are closed here. Path spelling is still
an explicit configuration operand. This does not claim whole #212 or #119.
Accepted provider functions are imported unchanged; their checkers never run.
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


p = provider('fixed_report_producer',
             'retained-producer-report-capacity-20261024/capacity.py')
c = provider('fixed_report_consumer',
             'retained-required-report-consumers-20261024/capacity.py')

# Body rows are a source callable census, not a report/metadata domain theorem.
CALLABLES = {
    'Silver_IO': ('Silver_IO', 'Put_Line', 'Put'),
    'Silver_Arguments': ('Silver_Arguments', 'Is_Message', 'Input_Is_Valid',
                         'First_Or_Default', 'Reject'),
    'Silver_Output_Libc': ('Silver_Output_Libc', 'Put_Byte', 'Flush',
                            'Set_Exit_Status'),
    'Silver_Runtime': ('Silver_Runtime', 'Argument_Count', 'Argument',
                       'Set_Exit_Status'),
}
GRAPH_UPPER = dict(Silver_IO=3, Silver_Arguments=5,
                   Silver_Output_Libc=1, Silver_Runtime=1)
SPECS = {
    'Silver_Output_Libc': dict(frontend=18575, why=8714, state=0),
    'Silver_Runtime': dict(frontend=1510, why=7376, state=1),
}


def spec_incoming(unit, *, path_bytes):
    """Post-simplification emission domain, not the allocated vertex count.

The source argument establishes six skeleton vertices plus two per abstract
state. Cleared null vertices have empty variable/call sets, no program/loop/
parameter flags and no original-program flag in these two straight-line
packages. They cannot fund an emitter or occur on a trace path. Imported
subprogram declarations and their contracts are not package statements.
"""
    p.natural(path_bytes)
    row = SPECS[unit]
    e = row['state']
    f = 1 + 2*e                   # synthetic null; Exit_State singleton
    v = 6 + 2*e
    # Accepted incoming graph equation with zero expression/declaration/call
    # roots. Zero outside calls follows the separate contract/reference proof.
    flow = 7*v*f + 12*f + 4*v + e + 6
    warning = row['why']          # keep Image warning funding across imports
    traces = v + 2*v*f
    # Reuse only the accepted text/name equation. Its generic count result is
    # deliberately discarded, rather than changing the accepted provider.
    text = p.incoming_state(frontend_nodes=0, entities=0, list_headers=0,
                            why_allocations=0, name_bytes=19, magic_bytes=760,
                            path_bytes=path_bytes, instantiation_edges=0)
    return dict(frontend_nodes=row['frontend'], frontend_entities=row['frontend'],
                graph_count=1, callable_count=4, report_entities=4,
                expression_roots=0, abstract_states=e, flow_ids=f,
                eligible_vertices=v, constructor_vertices=row['frontend']+12,
                statement_list_visits=1, join_calls=3,
                outside_flow_records=0, flow_records=flow,
                warning_records=warning, proof_records=0,
                message_bytes=text['message_bytes'], flow_name_bytes=text['flow_name_bytes'],
                warning_message_bytes=192, native_print_calls=3*flow+2*warning,
                third_pool_calls=8+flow, message_ids=flow,
                trace_attempts=traces, trace_counter=traces,
                trace_lines_per_file=v, trace_line_bytes=path_bytes+12,
                guards=dict(flow_set=flow <= p.HASH, flow_array=flow <= 2**30-1,
                            warning_array=warning <= 2**30-1,
                            trace_counter=traces <= p.I, trace_lines=v+1 <= p.I,
                            trace_column=path_bytes+12 <= p.I,
                            source_span_lists=f <= p.HASH,
                            constructed_vertex_index=row['frontend']+12 <= p.I))


def spec_report(unit, *, path_bytes):
    """Actual fixed-source count/string domains, parametric in source paths.

No CP expression image, response duration, backend response or attempt occurs
in these processes. Warning arguments are omitted by the reached wrapper:
the templates contain no surviving name placeholder (accepted #193 proof).
"""
    inc = spec_incoming(unit, path_bytes=path_bytes)
    names = [unit] + [unit+'.'+name for name in CALLABLES[unit][1:]]
    full_name_bytes = max(map(len, names))
    flow = p.array(inc['flow_records'], p.add_json_message(
        path_bytes=path_bytes, text_bytes=inc['message_bytes'], rule_bytes=64,
        check_tree=p.object_fields([]), aux_bytes=path_bytes+24))
    warning = p.array(inc['warning_records'], p.add_json_message(
        path_bytes=path_bytes, text_bytes=192, rule_bytes=64,
        check_tree=p.object_fields([])))
    # Four report identities; no generated calls in package elaboration and
    # no imported callable body: therefore no assumption edge registration.
    claims = p.claim_domain(4, 0)
    meta = p.metadata(entities=4, location_depth=1, name_bytes=full_name_bytes,
        path_bytes=path_bytes, spark_entities=4, skip_flow=0, skip_proof=0,
        pragma_assume=0, claims=claims['claims'], edges_per_claim=20,
        claim_edges=claims['edges'], timing_entities=5, timing_names=15,
        timing_fields=15, timing_key_bytes=59, progress_bytes=64, stop_bytes=64)
    full = p.report(meta, warnings=warning, flow=flow, proof=p.array(0,p.atom(0)))
    lifetime = p.assumption_lifetime(spark=8, skip_flow=0, skip_proof=0,
        vc_timings=8, response_timings=0, entity_messages=inc['flow_records'],
        pragma_assume=0, claims=20, claim_edges=0, location_depth=1)
    brief = p.brief_output(message_bytes=inc['message_bytes']+16,
        path_bytes=path_bytes, output_calls=3*inc['flow_records'])
    writer = p.representation(full, filename_bytes=path_bytes)
    return dict(unit=unit, incoming=inc, entities=4, h=1,
        source=dict(full_name_bytes=full_name_bytes, path_bytes=path_bytes),
        flow=inc['flow_records'], warning=inc['warning_records'], proof=0, goals=0,
        records=0, attempts=0, responses=0, full=full, projected=full,
        silver_projected_file_bytes=full.pretty+1, claim_domain=claims,
        third_pool=lifetime, flow_brief=brief, writer=writer,
        source_counts_bound=True, path_configuration_bound=False,
        native_warning_location_join_complete=False,
        whole_process_capacity_bound=False)


def prospective_configuration(*, project_path_bytes, object_dir_bytes, workers):
    """Exact #88 argv/config shape overlay, not a launcher implementation.

The worker integer must be chosen from host headroom separately. The private
Why recipe does not rewrite GNATprove arguments. Output stays brief/report-all.
"""
    p.natural(project_path_bytes, object_dir_bytes, workers)
    if not 3 <= workers <= p.I:
        raise ValueError('explicit represented worker count >= 3 required')
    args = ['gnatprove', '-P', None, '-U', '--mode=all', '--report=all',
            '--warnings=continue', '--checks-as-errors=on',
            '--prover=cvc5,z3,altergo', '--steps=0', '--timeout=0',
            '--memlimit=0', '--counterexamples=off', '-j'+str(workers),
            '--no-loop-unrolling', '--output=brief',
            '-cargs', '-Wno-free-nonheap-object']
    command = sum(project_path_bytes if x is None else len(x) for x in args)
    command += len(args)-1
    argv = p.container([(1,0,0,p.string(project_path_bytes) if x is None
                         else p.literal(x)) for x in args], object_kind=False)
    shape = p.object_fields([
        ('obj_dirs',p.array(1,p.string(object_dir_bytes))), ('cmdline',argv),
        ('proof_switches',p.object_fields([])), ('mode',p.literal('GPM_ALL')),
        ('has_errors',p.atom(5)), ('colors',p.atom(5))])
    return dict(argv=args, argv_count=len(args), joined_command_bytes=command,
        shape=shape, config_file_bytes=shape.compact+1, workers=workers,
        assumptions=False, output_header=False, quiet=False,
        parent_summary_lines=1, parent_summary_line_characters=object_dir_bytes+40,
        parent_summary_output_characters=object_dir_bytes+41,
        parent_summary_output_bytes=2*(object_dir_bytes+40)+1,
        parent_counter_join_required=True, launcher_implemented=False,
        concrete_path_join_complete=False)
