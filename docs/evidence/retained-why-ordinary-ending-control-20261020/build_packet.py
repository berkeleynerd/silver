#!/usr/bin/env python3
"""Retain exact already-available source excerpts; no target execution/fetch."""
from pathlib import Path
import hashlib
import json
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
PREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'

PLAN = [
    ('scheduler', 'why', 'src/gnat/gnat_scheduler.ml', 1, 28),
    ('ending_handler', 'why', 'src/gnat/gnat_main.ml', 265, 360),
    ('schedule_results', 'why', 'src/gnat/gnat_main.ml', 75, 152),
    ('per_check_strategy', 'why', 'src/gnat/gnat_checks.ml', 283, 323),
    ('selected_result_paths', 'why', 'src/gnat/gnat_checks.ml', 598, 663),
    ('save_delegate', 'why', 'src/gnat/gnat_checks.ml', 749, 765),
    ('ending_cleanup', 'why', 'src/gnat/gnat_checks.ml', 1129, 1157),
    ('session_shape', 'why', 'src/session/session_itp.ml', 145, 206),
    ('session_access', 'why', 'src/session/session_itp.ml', 298, 386),
    ('session_fold', 'why', 'src/session/session_itp.ml', 413, 459),
    ('session_mutators', 'why', 'src/session/session_itp.ml', 643, 746),
    ('session_remove', 'why', 'src/session/session_itp.ml', 903, 969),
    ('session_provers', 'why', 'src/session/session_itp.ml', 1933, 2017),
    ('session_serialize', 'why', 'src/session/session_itp.ml', 2023, 2210),
    ('session_save', 'why', 'src/session/session_itp.ml', 2212, 2244),
    ('driver_prepare', 'why', 'src/driver/driver.ml', 330, 408),
    ('driver_prove', 'why', 'src/driver/driver.ml', 449, 497),
    ('controller_prove', 'why', 'src/session/controller_itp.ml', 409, 438),
    ('explanation', 'why', 'src/session/termcode.ml', 25, 98),
    ('shape_constants', 'why', 'src/session/termcode.ml', 185, 240),
    ('shape_walk', 'why', 'src/session/termcode.ml', 338, 506),
    ('shape_dictionary', 'why', 'src/session/termcode.ml', 545, 628),
    ('term_patterns', 'why', 'src/core/term.ml', 115, 178),
    ('term_open', 'why', 'src/core/term.ml', 737, 831),
    ('term_fold', 'why', 'src/core/term.ml', 1282, 1296),
    ('task_selection', 'why', 'src/core/task.ml', 253, 276),
    ('name_decode', 'why', 'src/core/ident.ml', 110, 152),
    ('name_printer', 'why', 'src/core/ident.ml', 225, 289),
    ('table_defaults', 'why', 'src/util/exthtbl.ml', 36, 59),
    ('weak_memo', 'why', 'src/util/weakhtbl.ml', 86, 112),
    ('timing', 'why', 'src/util/debug.ml', 156, 188),
    ('backup', 'why', 'src/util/sysutil.ml', 11, 16),
    ('gnat_abort', 'why', 'src/gnat/gnat_util.ml', 1, 22),
    ('buffer', 'ocaml', 'stdlib/buffer.ml', 1, 170),
    ('format_buffer', 'ocaml', 'stdlib/format.ml', 937, 1007),
    ('protect', 'ocaml', 'stdlib/fun.ml', 27, 38),
    ('exit', 'ocaml', 'stdlib/stdlib.ml', 550, 570),
    ('uncaught', 'ocaml', 'stdlib/printexc.ml', 327, 367),
    ('hashtbl_cleanup', 'ocaml', 'stdlib/hashtbl.ml', 143, 232),
    ('ephemeron_replace', 'ocaml', 'stdlib/ephemeron.ml', 320, 339),
    ('pending_signals', 'ocaml', 'runtime/signals.c', 72, 135),
    ('signal_dispatch', 'ocaml', 'runtime/signals.c', 201, 227),
    ('pending_actions', 'ocaml', 'runtime/signals.c', 260, 305),
    ('signal_setter', 'ocaml', 'runtime/signals.c', 447, 490),
    ('signal_native', 'ocaml', 'runtime/signals_nat.c', 100, 154),
    ('native_raise', 'ocaml', 'runtime/fail_nat.c', 63, 87),
    ('raise_result', 'ocaml', 'runtime/fail_nat.c', 188, 191),
]

# These are inspected source/effect rows, not generated semantic conclusions.
ROWS = [
 ('scheduler_exit', ['scheduler','ending_handler'], 'Exit', 'ending is the catch body, outside its protected loop; no ordinary-save reentry'),
 ('handler_setters', ['ending_handler','signal_setter'], 'Invalid_argument', 'setter-only catch; save and exit are after the protected expression'),
 ('session_bad_id', ['session_access'], 'Not_found -> BadID', 'lookup failure translates and propagates; no raw-task insertion'),
 ('detachment', ['session_access'], 'Not_found', 'failed get_task yields detached=true and can skip an APn'),
 ('session_defaults', ['session_shape','table_defaults'], 'Not_found', 'return empty/dummy/scalar default; no task or binder creation'),
 ('explanation', ['explanation'], 'Not_found, Exit', 'drop matching attribute or stop explanation traversal; no binder restart'),
 ('declaration_selection', ['task_selection'], 'Not_found', 'may recompute selection suffix; ordered subset remains; no binder traversal in selector'),
 ('name_decoder', ['name_decode'], 'Not_found, Exit', 'alternate string classification; no logical traversal or shared Shape alias'),
 ('local_shape_names', ['shape_walk','name_printer'], 'Not_found', 'local cache fallback; interrupted operation unwound; outer fresh printer remains private'),
 ('shape_truncation', ['shape_dictionary'], 'ShapeTooLong', 'abandon proposition; copy buffer, clear, advance; no retry'),
 ('shape_dictionary_miss', ['shape_dictionary'], 'Not_found', 'one insertion continuation; no rollback or inverse-map consistency claim'),
 ('prover_statistics', ['session_provers'], 'Not_found', 'new local statistics table or zero default; no binder work'),
 ('prover_id', ['session_provers'], 'Not_found, Exit', 'scalar search/default or insertion; nested effects persist; no uniqueness claim after interference'),
 ('saved_identifier', ['session_serialize'], 'Not_found', 'fallback to existing id_string; no logical-term printing'),
 ('container_cleanup', ['hashtbl_cleanup','ephemeron_replace'], 'exception/reraise, Not_found', 'restore traversal bookkeeping and reraise, or replace miss with add; no binder callback replay'),
 ('pattern_translation', ['term_patterns','term_open'], 'Invalid_argument -> BadArity', 'pattern check may translate failure; no repeat of already completed pat_rename variable cloning'),
 ('timing_lookup', ['timing'], 'Not_found', 'scalar timing default; no save retry'),
 ('timing_finally', ['protect','timing'], 'exception / Finally_raised', 'finally once, original or replacement exception; work is never retried'),
 ('outer_gnat', ['ending_handler','gnat_abort'], 'stack_trace / Out_of_memory / other', 'reraise or report/abort; handler body cannot catch itself or call ending'),
 ('uncaught_exit', ['uncaught','exit','gnat_abort'], 'printer/hook/handler suppression', 'reports or terminal path; no ordinary save call; cleared exit gates are not restored'),
]

DEPS = [
 'docs/research/retained-producer-driver-envelope.md',
 'docs/evidence/retained-producer-driver-envelope-20261018/result.json',
 'docs/evidence/retained-producer-driver-envelope-20261018/review.md',
 'docs/research/retained-why-callback-launch.md',
 'docs/reviews/review-why-callback-launch-188d05026b.md',
 'docs/research/retained-why-native-effect-completeness.md',
 'docs/reviews/review-why-native-composition-7b84ac0176.md',
 'docs/evidence/retained-why-native-effect-completeness-20261019/interface-summary.json',
 'docs/research/retained-why-save-exit-charge.md',
 'docs/reviews/review-why-save-exit-charge-6dd2732dd0.md',
 'docs/research/retained-why-session-save-state.md',
 'docs/research/retained-tool-source-identity.md',
]

def digest(data):
    return hashlib.sha256(data).hexdigest()

def write(name, value):
    (HERE/name).write_text(json.dumps(value, indent=2) + '\n')

def main():
    inputs = {}
    for p in [WHY, OCAML] + DEPS:
        b = (ROOT/p).read_bytes()
        inputs[p] = {'bytes':len(b), 'sha256':digest(b)}
    # The source archives are unchanged accepted inputs, not a fresh fetch.
    assert inputs[WHY]['sha256'] == '2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749'
    assert inputs[OCAML]['sha256'] == '04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7'
    excerpts = []
    with tarfile.open(ROOT/WHY) as why, tarfile.open(ROOT/OCAML) as ocaml:
        for key, kind, member, first, last in PLAN:
            archive = WHY if kind == 'why' else OCAML
            member = 'why3/'+member if kind == 'why' else PREFIX+member
            b = (why if kind == 'why' else ocaml).extractfile(member).read()
            lines = b.decode().splitlines(keepends=True)
            assert 1 <= first <= last <= len(lines), (key, len(lines))
            excerpt = ''.join(lines[first-1:last])
            excerpts.append(dict(id=key, archive=archive, member=member,
                member_bytes=len(b), member_sha256=digest(b), first=first, last=last,
                excerpt_sha256=digest(excerpt.encode()), text=excerpt))
    write('inputs.json', dict(base_commit='1f510363e40a7c18558743bef0c28f41d06f83db',
        why3_revision='9390baf120ef260547dfa14f08e11c890b203d9c',
        ocaml_revision='8eb41f72ded84df884c3671734c947f612091f84', inputs=inputs))
    write('source-excerpts.json', excerpts)
    write('control-ledger.json', [dict(id=k, source_refs=refs, receives=receives,
        effect=effect) for k, refs, receives, effect in ROWS])
    print(json.dumps(dict(inputs=len(inputs), excerpts=len(excerpts), ledger_rows=len(ROWS))))

if __name__ == '__main__':
    main()
