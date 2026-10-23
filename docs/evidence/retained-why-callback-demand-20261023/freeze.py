"""Author-only freezing of exact retained inputs; no target/tool execution."""
import hashlib
import json
import tarfile
from pathlib import Path
from compose import calculate, CASES
from control import check_control

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
ARCHIVE = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
FUN_ARCHIVE = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def write(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def freeze():
    specs = [
        ('parallel_callback', 'why3/src/gnat/gnat_checks.ml', 1038, 1084,
         'Only Done is forwarded; parallel>1 selects this closure.'),
        ('scalar_log', 'why3/src/gnat/gnat_checks.ml', 26, 112,
         'InternalFailure payload discarded; only scalar fields serialized.'),
        ('idle_catch', 'why3/src/session/controller_itp.ml', 518, 540,
         'Entire build is protected; disabled stack_trace catches every exception.'),
        ('build', 'why3/src/session/controller_itp.ml', 410, 441,
         'Driver.prove_task runs inside idle trap; inner Sys_error uses same callback.'),
        ('scheduled_callback', 'why3/src/session/controller_itp.ml', 591, 652,
         'Status writes precede parallel callback; no payload printer or rethrow.'),
        ('response_callback', 'why3/src/session/controller_itp.ml', 443, 516,
         'Response/status/record operations; blocking excludes editor processing.'),
        ('interrupt_existing', 'why3/src/session/controller_itp.ml', 542, 589,
         'Interrupts existing attempts; no logical task construction.'),
        ('main_callbacks', 'why3/src/gnat/gnat_main.ml', 79, 165,
         'InternalFailure branch exists in inner callback but is not forwarded by parallel wrapper.'),
        ('run_goal', 'why3/src/gnat/gnat_checks.ml', 985, 1036,
         'Selected noninteractive path uses constant notifier and schedules existing goal.'),
        ('strategy', 'why3/src/gnat/gnat_checks.ml', 282, 359,
         'Per_Check single strategy and full-split predicate with no false-return catch.'),
        ('register_result', 'why3/src/gnat/gnat_checks.ml', 598, 665,
         'Full-split guard and CE-off catch exclude constructor-bearing successors.'),
        ('session_attempts', 'why3/src/session/session_itp.ml', 610, 677,
         'Proof-attempt records and integer IDs are distinct from the six logical owners.'),
        ('session_status', 'why3/src/session/session_itp.ml', 737, 879,
         'Result/status-table updates, constant notifier and scalar warning.'),
        ('driver_scope', 'why3/src/driver/driver.ml', 372, 509,
         'Lookup/preparation/printing are separate charged owners; remaining wrappers are scalar.'),
        ('response_analysis', 'why3/src/driver/call_provers.ml', 204, 405,
         'None model option avoids model callback; all selected parser operands are data.'),
        ('response_dispatch', 'why3/src/driver/call_provers.ml', 455, 601,
         'Saved requests/results and ordinary dispatch introduce no logical constructors.'),
        ('socket_services', 'why3/src/driver/prove_client.ml', 12, 107,
         'Socket state and scalar errors; connection formatting does not expose logical payload.'),
        ('socket_requests', 'why3/src/driver/prove_client.ml', 162, 261,
         'Request strings, response fields and scalar exception printers.'),
        ('ending_reports', 'why3/src/gnat/gnat_main.ml', 214, 309,
         'CE branch excluded; save separately charged; output/profiling fields scalar.'),
        ('outer_report', 'why3/src/gnat/gnat_main.ml', 331, 360,
         'Outer catch does not reinstall producer or callback.'),
        ('uncaught_gnat', 'why3/src/gnat/gnat_util.ml', 1, 22,
         'Installed scalar-family exception reporting and JSON abort.'),
        ('manual_info', 'why3/src/gnat/gnat_manual.ml', 131, 145,
         'Accepted None script excludes editor-command path.'),
        ('ce_ending_selection', 'why3/src/gnat/gnat_checks.ml', 1144, 1238,
         'No counterexample goal; ordinary status/goal selection is read-only.'),
        ('save_serialization', 'why3/src/session/session_itp.ml', 2003, 2244,
         'Existing paths, session fields, shape strings and scalar serialization.'),
        ('save_explanation', 'why3/src/session/termcode.ml', 20, 99,
         'Selected explanation traversal opens binders but creates no other six-owner object.'),
        ('save_shape', 'why3/src/session/termcode.ml', 338, 627,
         'SV6 shape builders; actual no-pattern input selects bound/quant opening only.'),
        ('variable_constructor', 'why3/src/core/term.ml', 28, 43,
         'Fresh-variable Ident registration; existing type reused.'),
        ('unsafe_opening', 'why3/src/core/term.ml', 739, 835,
         'Variable-only substitution preserves type pointers; save binders separately charged.'),
        ('task_diagnostics', 'why3/src/core/task.ml', 362, 375,
         'Task sentinel branches print constant/string data.'),
        ('restore_read', 'why3/src/core/theory.ml', 490, 492,
         'Restore functions only read existing private table; no theory reconstruction.'),
        ('stats', 'why3/src/util/debug.ml', 156, 218,
         'Timing map scalar; accepted empty registered_stats prevents user printers.'),
        ('why_dispatch', 'why3/src/util/exn_printer.ml', 12, 51,
         'Rejection preserves original input; no secondary logical recursion.'),
        ('loc_dispatch', 'why3/src/util/loc.ml', 335, 353,
         'Message strings and recursive Located wrapper.'),
        ('printexc_fallback', 'ocaml/stdlib/printexc.ml', 24, 76,
         'Opaque blocks are not recursively interpreted as Why logical payloads.'),
        ('uncaught_runtime', 'ocaml/stdlib/printexc.ml', 320, 361,
         'At-exit, installed handler and original/secondary fallback are finite terminal sites.'),
        ('pretty_real_writer', 'why3/src/core/pretty.ml', 254, 284,
         'Excluded diagnostic route really can call is_ts_tuple; not assumed read-only.'),
        ('tuple_real_writer', 'why3/src/core/ty.ml', 278, 294,
         'A cold tuple probe registers n+1 identifiers; excluded by reachability here.'),
    ]
    witnesses = []
    with tarfile.open(REPO / ARCHIVE) as tar:
        for key, member, first, last, claim in specs:
            raw = tar.extractfile(member).read()
            lines = raw.splitlines(keepends=True)
            assert 1 <= first <= last <= len(lines), key
            excerpt = b''.join(lines[first-1:last])
            witnesses.append({'id': key, 'archive': ARCHIVE, 'member': member,
                              'first_line': first, 'last_line': last,
                              'member_identity': identity(raw),
                              'excerpt_identity': identity(excerpt),
                              'text': excerpt.decode(), 'claim': claim})
    with tarfile.open(REPO / FUN_ARCHIVE) as tar:
        member = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/stdlib/fun.ml'
        raw = tar.extractfile(member).read()
        excerpt = b''.join(raw.splitlines(keepends=True)[20:38])
        witnesses.append({'id': 'finally_secondary', 'archive': FUN_ARCHIVE,
                          'member': member, 'first_line': 21, 'last_line': 38,
                          'member_identity': identity(raw),
                          'excerpt_identity': identity(excerpt), 'text': excerpt.decode(),
                          'claim': 'Finally_raised carries failing cleanup exception, not discarded body exception.'})
    write('source-witnesses.json', witnesses)
    providers = [ARCHIVE, FUN_ARCHIVE,
        'docs/research/retained-combined-parallel-startup.md',
        'docs/research/retained-tool-source-identity.md',
        'docs/research/retained-why-shared-demand.md',
        'docs/evidence/retained-why-shared-demand-20261020/compose.py',
        'docs/evidence/retained-why-shared-demand-20261020/attachment.json',
        'docs/research/retained-why-parallel-state-attachment.md',
        'docs/research/retained-why-save-attempt-growth.md',
        'docs/research/retained-why-save-stack-composition.md',
        'docs/evidence/retained-why-save-stack-composition-20261020/result.json',
        'docs/research/retained-why-save-shape-builder-allocation.md',
        'docs/research/retained-why-save-printer-control.md',
        'docs/research/retained-why-debug-formatter-control.md',
        'docs/evidence/retained-why-debug-formatter-control-20261020/result.json',
        'docs/reviews/review-debug-formatter-control-20261020.md',
        'docs/research/retained-why-model-meta-control.md',
        'docs/evidence/retained-why-model-meta-control-20261020/result.json',
        'docs/reviews/review-model-meta-attachment-20261020.md',
        'docs/research/retained-why-session-exception-prefix.md',
        'docs/evidence/retained-why-session-exception-prefix-20261019/registration-inventory.json',
        'docs/research/retained-why-sexplib-converter-prefix.md',
        'docs/evidence/retained-why-sexplib-converter-prefix-20261019/result.json',
        'docs/reviews/review-why-exception-and-sexplib-prefix-040fba6e24.md',
        'docs/research/retained-why-save-exit-charge.md']
    providers += ['docs/evidence/retained-why-fixed-inline-family-20261020/' + c + '-family.json' for c in CASES]
    write('inputs.json', {'files': {p: identity((REPO / p).read_bytes()) for p in providers},
                          'author_base': 'bc5db2f580',
                          'source_native_relation_reused': True,
                          'new_native_correspondence_claim': False})
    write('result.json', calculate())
    write('control-result.json', check_control())


if __name__ == '__main__':
    freeze()
