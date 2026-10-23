# Six-owner residual for the selected parallel callbacks and shutdown

2026-10-23 UTC, #119 / #153. **Candidate source argument, pending independent
review.** At the accepted combined quiet/timeless/J12/logging registration cut,
`other_callbacks_and_shutdown` is the **zero six-owner vector**, after assigning
lookup/library construction, all named preparation, request printing and save
binder registrations to their existing owners. This is a process-scoped result,
not a per-episode allowance. The [packet](../evidence/retained-why-callback-demand-20261023/README.md)
exports a vector for each of the five processes.

The decisive control fact is specific to `parallel > 1`: the parallel callback
logs an `InternalFailure` status without its payload, then drops that status.
It does not call the serial GNAT exception-reporting callback. A preparation
exception can still abandon a prefix and leave already charged objects behind;
this result neither assumes preparation success nor removes those charges.

## Attachment and ownership

Use the [combined registration relation](retained-combined-parallel-startup.md)
and [shared-demand attachment](retained-why-shared-demand.md), with the same
fixed executable, Why3 `9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml
`8eb41f72ded84df884c3671734c947f612091f84`, typed/native-service correspondence,
guarded mutation and first-counter-violation premises. The target Input cut is
registration; its historical post-CE state is only the existing upper envelope.
No serial PID or later cut is silently relabeled as J12 registration.

The effect argument applies to every prefix before the first violated shared
counter invariant. It does not use a final counter endpoint to prove its own
zero contribution. Aggregate no-wrap must still be discharged by composition;
the source routing and the distinction between session records and logical
constructors do not provide that arithmetic result.

The selected route is fresh automatic Per_Check, three fixed provers, external
server, no editor/replay/manual/debug-save mode, CE off, one OCaml worker and
the accepted immutable registered forest. The controlled startup and subsequent
callback/source capability restrictions retain their original scope. This is
not a theorem about arbitrary plugins, arbitrary new native callbacks, or a
different command line. The live root goal and issue bookkeeping belong to the
lead; this isolated subthread has no local harness goal.

The [debug control](retained-why-debug-formatter-control.md) supplies disabled
stack-trace/output flags and their preservation. In particular, a disabled
`dprintf` does not invoke `%a` or `%t`; ordinary argument evaluation is still
audited. Gnat_config's `--logging` is distinct from `GNATWHY3LOG`: the selected
JSON status log is active, while the debug-formatter environment override is
absent. The [model-meta control](retained-why-model-meta-control.md) supplies
`get_model=None` for every selected request, including failed preparation
histories and arbitrary supported response contents.

There remains **one** global `e<=2`, two save-entering callbacks and at most
three saves. No component below obtains another exception allowance. Save
binders are already charged once by shared-demand's imported
`fresh_variable_calls_upper`. Lookup, preparation and printing charges include
their failed prefixes, whether or not their exception is subsequently dropped.

## Scheduling and ordinary responses

The frozen source witnesses identify these actual selected paths:

| Path | Six-owner effect after assigned components are removed |
| --- | --- |
| `Gnat_main.handle_obj/schedule_goal` → `Gnat_checks.schedule_goal` | Reads registered checks and IDs; schedules existing goals. The parallel wrapper updates a remaining-count ref and may interrupt other attempts. No logical symbol/type/declaration/task constructor. |
| `Controller.schedule_proof_attempt` | Grafts or replaces a **session proof-attempt** record and enqueues it; this is not `Task.Hstask`, `Theory.Hstdecl` or `Decl.Hsdecl`. `notification` is the supplied constant function. |
| `idle_handler` → `build_prover_call` | Calls `Driver.prove_task`. Its lookup/preparation/printing bodies belong to the three separate residuals. Filename selection, Buffer/channel setup, command formatting, request bookkeeping and sending do not call any of the six constructors. |
| `Call_provers.get_new_results` | Reads and splits scalar server records; parses answer/step/time strings and writes result records. `record_model`'s None branch never invokes `prp_model_parser`, even for model-looking text. Re/string/native service failures do not construct Why logical values. |
| `Controller.timeout_handler` and attempt callback | Updates result/status tables, compares/sorts returned records, invokes `Running`, `Done`, `Interrupted` or `InternalFailure` callbacks. Generic comparison may inspect data but does not register Why objects. Blocking scheduler excludes editor processing. |
| Parallel wrapper and `Logging.log` | Serializes goal ID, prover string, timestamp, status kind and, for Done only, scalar answer/time. No exception payload, term, type, declaration or deferred logical printer is stored in the formatter. |
| `Done` → `Gnat_main.interpret_result` → `register_result` | Reads answers/statuses and selects the next already registered goal. Session status propagation changes Boolean tables, not logical tasks. |

The potentially constructor-bearing branches must be excluded rather than
mistaken for the last row. Per_Check has the single strategy
`split_goal_wp_conj` (`gnat_checks.ml:284–302`). Accepted registered leaves
have no child transformations and this final parent, so `is_full_split_goal`
returns true. The [forest/attempt preservation](retained-why-save-attempt-growth.md)
already establishes that selected responses and saves do not change these
links. Its first-exception argument applies here: `is_full_split_goal` has no
catch returning false; failure aborts the decision or reaches register_result's
Exit arm. That arm cannot call `add_ce_goal` with CE off. Thus `further_split`,
session task grafting, new proof-node identifier registration and CE/RAC
construction are absent. No response retry or new transformation owner is
inferred from an InternalFailure. Ordinary selection may continue with existing
goals; their eventual preparation remains charged at its actual owner.

The separate named preparation components include callback work performed
*inside* the transform/lookup bodies, and the printer component includes work
through its propagation boundary. This residual does not move their in-body
warnings or validators into a new zero category.

## Why escaped logical diagnostics do not reach Pretty

`controller_itp.ml:518–540` pops a scheduled attempt, then protects both
`build_prover_call spa` and `update_observer ()`. With stack tracing disabled,
every exception from this protected expression invokes
`spa.spa_callback (InternalFailure e)`. The entire Driver lookup, preparation,
print and request-send sequence lies inside that expression. An exception
before the inner trap, such as Queue.Empty or a failure while popping, comes
from queue/scalar work, not a logical producer. `build_prover_call`'s inner
Sys_error handler can call the same callback earlier; it cannot bypass the
outer trap for a logical payload.

The captured callback is the wrapper constructed by
`schedule_proof_attempt` (`controller_itp.ml:591–619`), which updates session
status then calls the supplied GNAT parallel callback. It has no exception
printer and does not re-raise an InternalFailure payload. Its field/table
operations can fail, but such failure is a **new** exception from those
operations or from a separately charged signal save.

The supplied callback is concretely `gnat_checks.ml:1060–1077`, not an arbitrary
function and not the serial branch at line1083. It optionally logs, tests
`remaining`, then has exactly one forwarding branch: `Done pr`. Every other
status falls through `_ -> ()`. `Logging.pas_to_json` maps InternalFailure to
the constant string `"internalfailure"`; its results arm also uses `_ -> []`.
Consequently no source edge unwraps or formats e. The logical payload can be
arbitrarily large without affecting the six-owner result of this handler.

If session update or logging raises, the handler's body is outside its own
trap. A build Sys_error callback failure can enter the outer idle handler once;
a failure in that outer handler escapes to the GNAT outer catch. It carries
the **secondary** scalar/save failure, not the discarded preparation exception.
Likewise an interrupt/status callback has no logical payload rethrow. Faithful
exception/frame semantics do not resume a discarded producer frame or make its
exception reappear. A pending signal failure replaces the current exception;
it does not implicitly nest it in the new payload. `Fun.protect` wraps the
failed *finally* computation, whose timing/save error has the same scalar
family; it does not attach the discarded body exception.

This excludes `Gnat_main.interpret_result`'s `InternalFailure e` printer at
`:110–114` for this selected route. It also excludes terminal reporting of
`UnsupportedTerm`, `UnsupportedDecl`, TypeMismatch and parser/typing logical
payloads propagated from lookup, preparation or request printing. It does not
assert that those exceptions cannot occur. The earlier
[25,920 first-fold allowance](retained-why-save-exit-charge.md) has different
serial control and inputs and is neither multiplied nor imported here.

## Save, ending, terminal reports and hooks

All five accepted saved proposition forests have **no Tcase or patterns** and
only variable-valued saved substitutions, by the
[save structural transfer](retained-why-save-stack-composition.md). These
immutable raw session tasks are distinct from transient prepared tasks.
Explanation and SV6 shape opening uses `t_open_bound`/`t_open_quant` and unsafe
term substitution, with existing type pointers. `create_vsymbol` registers the
fresh variable's identifier; those registrations are exactly the imported save
binder component. There is no Hsty call or declaration/tdecl/task/Hcpt write.
The absent pattern branch matters: it excludes smart-pattern type diagnostics
without assuming physical equality for an arbitrary prepared type.

Other save work reads task metadata and existing names, builds local maps and
shape strings, and serializes scalar/session fields. `save_ident` restores an
existing path or prints `id_string`; it is not Pretty. No selected save helper
enters a parser, clone, general type substitution or a logical declaration
constructor. Runtime/I/O/format exceptions, BadID, GoalNotFound and internal
selection/shape sentinels cover these source leaves at the already accepted
native-service boundary. Local ShapeTooLong and explanation Exit are consumed
by their shown local traps. Escaping failures may terminate or be consumed by
an interrupted computation; partial binder work remains within the existing
global save charge. No successful-save assumption is introduced.

`ending` removes valid CE attempts (none on this CE-off route), performs its
already charged save, traverses status/statistics/extra-info and formats JSON.
Accepted attempts have `proof_script=None`; `manual_proof_info` consequently
returns None. `session_find_ce_pa` returns None because no CE goal exists, so
`maybe_giant_step_rac` is not called. Even an existing result record is not
treated as a latent executable callback. The answer printer handles only
constants and strings. The final profiling-prefix environment write is scalar.

The reachable terminal error family consists of ordinary primitive/string/
numeric/container/service failures, payload-free session/task sentinels,
Prove_client's string/constant errors, and Loc/Finally wrappers around that
family. Source failures of `update_theory_node` format constant text as
`Loc.Message`, optionally Located; status-warning callbacks similarly contain
no logical printer. BadID has no logical payload; the Task and Prove_client
registered printers have only constant/string branches for these inputs.
The external Re family is used only on strings with scalar/data callbacks;
its constructors are not Why logical constructors. This conclusion uses the
same explicit Re service behavior as combined startup, not a newly asserted
Re version or no-failure premise.

Reuse the [Why exception dispatch](retained-why-session-exception-prefix.md)
and [Sexplib registry](retained-why-sexplib-converter-prefix.md) at precisely
their inspected callback-family/preservation scope. All unrelated Why printers
reject these constructors. The relevant matched branches print scalar data;
Printexc's fallback does not recursively interpret opaque payload blocks as
Why values. Sexplib's fixed converters and Unix/Fun/Dynlink adapters introduce
no Why constructor; recursive wrappers retain the established scalar inner
family. A printer failure is suppressed before dispatch continues with the
original input; it does not turn a scalar input into a logical exception.
Thus additional fallback passes and failure during reporting still have zero
six-owner effect. Pretty's real `is_ts_tuple` writer is deliberately **not**
called, rather than assumed to hit a warm cache.

The accepted exit family is Debug Stats, standard Format flushing and terminal
channel flushes. The debug-control result preserves an empty registered-stat
callback list; timing entries are scalar. Its once gates and Format callback
ownership remain the existing results. No hook holds a pending logical printer.
Repeated flushes, nested saves or partial hook execution do not create another
six-owner write. Counts, bytes, tables, stack, native errors, progress and
physical service sufficiency retain their separate obligations.

## Export, checking and limits

For each process in the accepted 51/42/22/2/1 root family, the new callable
`residuals(escape=2)` returns

```
other_callbacks_and_shutdown = {
  Ident, Decl.Hsdecl, Ty.Hsty, Theory.Hstdecl, Task.Hstask, Task.Stdecl.Hcpt:
    {increments: 0, requests: 0}
}
```

Every vector is already process-scoped. `escape` accepts only integer0,1,2;
it documents the inherited single budget and cannot grant a second one.
The checker pins imported documents/results, verifies exact source member and
line correspondence, joins actual registered-root identities, exercises the
finite callback status/failure abstraction and checks API schema/arithmetic.
It does not prove the source simulation or replay a predecessor checker.

There is no missing input *inside this selected six-owner residual*, conditional
on the named accepted premises and source argument. Whole-process headroom
still needs all other component vectors and backing transfers; those inputs
are not supplied as zeros by this API. Different routing, new callback owners,
or changed logical forest/meta/flag inputs invalidate this attachment. General
grammar coverage, all resource owners and the complete #119 rule remain open.
Oracle, tools, pins and admission are unchanged; #88–94 remain unstarted.
Ordinary OS/allocator and physical-resource sufficiency stay at the trusted
boundary. No aggregate RAM gate is added.

Selected author setting: GPT-6 Astra / Extra High; runtime-setting and token/
cost telemetry unavailable. `round.json` records elapsed evidence and the
material rework: following the J12 callback closure eliminated an unjustified
generic diagnostic multiplier and avoided importing the serial-only bound.
No CLI memory or GitHub record was changed by this subthread.
