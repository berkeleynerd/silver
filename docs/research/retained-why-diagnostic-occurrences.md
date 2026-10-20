# Selected suffix diagnostic occurrences

2026-10-20 UTC, #119 / #153, Linux x86_64. Author base
`01ad7f9053fc1d2d64e7a993ec8f2d8d2543e3a7`.

Under the existing selected source/native/runtime and metadata-preservation
relation, the whole selected suffix has the following outer call bounds.
These count attempted invocations, including failed prefixes. They do not
multiply the historical first-inline six-report bound by an assumed number
of successful tasks.

| Case | Scheduling owners A | Outer Exn_printer calls | Outer Printexc.to_string calls | Printer integer-error stderr calls |
| --- | ---: | ---: | ---: | ---: |
| Put_Line | 194 | 390 | 2 | 194 |
| Put | 161 | 324 | 2 | 161 |
| First_Or_Default | 98 | 198 | 2 | 98 |
| Is_Message | 11 | 24 | 2 | 11 |
| Input_Is_Valid | 5 | 12 | 2 | 5 |
| Sum of separate processes | 469 | 948 | 10 | 469 |

Each process additionally has at most one normal JSON call, two abort JSON
calls, one GNAT raw-backtrace string conversion, and four raw-backtrace print
calls. At most one of the covered string/print invocations is active at a time.
The [disabled-backtrace interface](retained-why-disabled-backtrace.md) therefore
gives per process:

```text
n <= 1, m <= e+2 <= 4, d <= 1
direct backtrace object requests <= 1112*n + 80*m <= 1432 bytes
direct backtrace channel requests <= m <= 4, bytes <= 59*m <= 236
returned backtrace string length <= 59
covered active native projection <= 5016*d <= 5016 bytes.
```

This is a component result. **Recursive exception-printer expansion, diagnostic
payload bytes, aggregate JSON sizes and actual standard-core B/E remain
unjoined.** The first-inline depth-two/eight-Pretty-attempt argument is not a
whole-suffix wrapper-depth theorem. The exact missing recursive interface is
described below. No complete reporting, save/exit, R, stack or physical-capacity
claim follows. The [packet](../evidence/retained-why-diagnostic-occurrences-20261020/README.md)
retains the new source witnesses, reused identities, per-site occurrence counts and
per-case arithmetic.

## Reused interval and owner counts

The five process identities, post-initialization cuts, one OCaml worker,
fixed Per_Check/non-replay/CE-off configuration, external prover server,
three selected driver/printer roots and classified pending clients are the
accepted inputs. Registration and configuration have finished before these
cuts. The four earlier cuts precede scheduling; Input_Is_Valid already has
its first preparation owner active. Its entire owner is overcounted, not added
again to the suffix allowance.

Reuse [interrupted preparation](retained-why-path-writer-capacity.md) and
[attempt/status preservation](retained-why-save-attempt-growth.md). Their
selected-pair argument bounds scheduling owners as well as owners that actually
reach prepare_task: A<=3G+e, for G=64/53/32/3/1 and one global e<=2. A failed
owner before preparation cannot requeue itself. Repetition requires a previous
nonvalid Done followed by a consumed exceptional false result of the tried
query. Each first pair is distinct and each repeated owner consumes that same
global escape allowance. Failed publication may lose future work; it supplies
no fresh retry credit. We therefore use A=194/161/98/11/5 even for diagnostic
failures before Driver.prove_task is entered.

Queue.pop removes a published scheduled object before build. Build and idle
do not retry it. No selected thread, signal, warning, exception-printer or
exit hook independently schedules a new owner. Keep the accepted whole-suffix
at-most-two save-entering callbacks, at-most-three saves and e<=2 unchanged.
Different component bounds may each conservatively use e=2; that does not
authorize two new escapes at every report or owner.

## Outer reporting topology

Here an **outer** report is an entry from the selected control flow into
Exn_printer.exn_printer or Printexc.to_string. Calls made by their registries
and wrapper printers are inner expansion, not additional outer reports.

| Outer site | Whole-suffix bound | Why failures do not retry it |
| --- | ---: | --- |
| GNAT interpret_result InternalFailure from build_prover_call's Sys_error handler | A | One build per popped owner; handler body is outside its try. |
| Same GNAT report from idle_handler's broad handler | A | One enclosing handler per owner; it may catch failure of the first report, but cannot catch itself. |
| Main's outer exception report | 1 | Main's handler is outside its protected initialization/scheduling/ending expression. |
| Installed GNAT uncaught handler's exception report | 1 | Printexc invokes that configured handler once, after one protected preliminary do_at_exit. |
| Printexc fallback conversion of original exception | 1 | Sequential fallback after custom-handler failure. |
| Printexc fallback conversion of secondary exception | 1 | Failure escapes to the final wrapper; no new reporting pass. |

Thus Exn outer<=2A+2, Printexc outer<=2, combined outer<=2A+4. The
six historical sites remain recognizable, but their two owner-local sites
are counted over all scheduling owners. It would be unsound to keep a global
six merely because those source locations are unchanged.

The timeout InternalFailure arm is not a further selected producer:
Call_provers.fetch_new_results constructs only ProverFinished or ProverStarted,
and get_new_results drops ProverStarted when blocking. The external route has
no selected result-buffer writer producing InternalFailure. Finished owners
are removed before Done dispatch; stale duplicates cannot repeat that callback.
Editor/replay/interactive callback families are excluded by the existing
configuration relation, not by the spelling of their functions. This remains
true if a build published a call before an exception reached its handler.

Prove_client's conversion while connecting is before the cuts; the accepted
external connection is not disconnected/reconnected in this suffix.
Pmodule.acc_ind_decl, wf_def and wf_module's error reports are eager module
initializers, not callbacks executed by later use of their values. The
registered wrapper printers are handled separately below. Lexlib.resolve_file
would print a caught exception into a warning, but its selected lexer clients
require a `[#` position directive. The four exact later library files have
zero such byte substrings, including inside comments or strings. Reparse cannot
create a new directive. The accepted named-library closure excludes other
source files and dynamic parser roots. This closes that extra outer-report
candidate without requiring a bound on library reparse counts.

The [channel-exit argument](retained-why-channel-exit-bound.md) already excludes
Reduction_engine.normalize, Compute/Gappa/Reflection and CE/RAC entry routes.
The [standard control argument](retained-why-standard-formatter-control.md)
excludes plugin/configuration, compiler diagnostic, interactive cleaning and
archive writers, and fixes the warning hook to private warning-list storage.
The existing source/client inventories are reused rather than regenerated.

## JSON and direct stderr roots

Ordinary ending occurs at most once. Its print_messages calls
print_json_single_line once. Main's outer handler and the configured uncaught
handler each call abort_with_message at most once; its print_json precedes exit.
A partial normal JSON can therefore coexist with later abort prefixes. There
are at most **three JSON invocations**, split one normal/two abort, not one
successful final report. Registration aborts precede the cuts; the other
further-split abort is excluded by the accepted fully split Per_Check forest.
Failed hooks neither restart ending nor reset these source-root counts.

Printer.int_of_string catches every exception from conversion. Its stderr
format call must be counted even for intended decimal syntax and irrespective
of the missing numeric-service join. If the call returns it asserts; if it
fails, that exception escapes. Each automatic owner enters its selected Smtv2
task printer at most once. The selected syntax-conversion clients are within
that print: the driver-loading check_syntax clients are before the cuts.
The print_type/print_decl catches wrap Unsupported and reraise; the model-map,
attribute and record bookkeeping catches do not enclose syntax printing.
syntax_range_literal's Exit catch has no supplied callback on this selected
Smtv2 route and raises Failure. Thus even a failure of the stderr report cannot
resume that print and produce another integer-error report. There are at most
**A** such stderr attempts, without any bound on successful syntax conversions.
Exception pretty printers do not invoke the Smtv2 syntax renderer.

The accepted actual meta argument in
[library origins](retained-why-path-library-origins.md#selected-writer-closure)
supplies get_model=None; therefore the model-parser malformed-expression stderr
writer contributes zero. This is stronger than CE-off alone and is reused
without a new meta proof.

Printexc's custom-handler fallback has at most two Printf stderr header calls,
one for each exception string, followed by at most one explicit stderr flush.
Its outer Out_of_memory handler has at most one prerr_endline call, even if
earlier output already happened. A failure of that handler is suppressed by
the final wrapper. These direct Printf/Stdlib writes are separate from Format's
standard-core event accounting. The raw-print calls are counted next; their
59-byte fallback is not counted again as a header.

## Backtrace clients and simultaneous activity

Reuse the complete diagnostic-client inventory in the accepted disabled-
backtrace packet. GNAT's configured uncaught handler contributes one raw string
conversion. Its secondary fallback has two sequential raw prints; the default
OCaml uncaught handler is replaced, not additionally invoked. The C fatal path
calls the registered OCaml wrapper once and then terminates. Its alternative
default C path is not a second report root. The wrapper catches escaping
exceptions, including failures while printing its own Out_of_memory message.

Session_itp.update_goal_node needs its own charge. Its exception pattern protects
only get_proof_parent, not recursive parent update bodies. get_proof_parent
reads the immutable parent after get_proofNode; that getter catches table
Not_found and raises BadID. Under the inherited source/runtime relation it
has no ordinary Not_found result. A pending signal-origin Not_found outside
the inner trap can conservatively select the outer handler. Such a caught
escape is consumed once from the global e<=2; the handler warns, prints a
backtrace and asserts, with no local self-retry. Higher catches do not recreate
that consumed signal exception. Therefore this site contributes at most e
raw prints, including prints that themselves fail. No claim is made that the
abstract exception placement is a reproduced native execution or an actual
safepoint at every source boundary.

add_registered_transformation's raw print is in old-session merge, excluded
after the fresh non-replay cuts. The occurrences at 1679 and 1784 are comments.
The accepted normalization exclusion covers reduction_engine's get_backtrace.
IDE/browser/bddinfer and Thread.create reporting roots are outside this
standalone one-worker relation. Pinterp's get_callstack is not one of these
diagnostic inputs. This gives n<=1 and m<=e+2<=4 across the whole suffix.

These covered conversions/prints do not call another covered conversion/print.
The selected pending clients save/exit or yield; save and the exit hooks do
not enter these raw diagnostic callers. A mutating save either terminates or
raises; a raw conversion may catch its Failure and continue its own fallback,
but no second raw diagnostic was entered by that save. A failure escaping a
raw call unwinds it before a higher report or uncaught fallback starts. The
uncaught wrapper prevents recursive fatal reporting. Consequently d<=1 for
the accepted covered string/print native projection, despite nested save/exit
frames. Standalone raw getters used in Fun.protect and other existing owners
are not newly counted conversions; their frames retain their original owners.
The 5016-byte component does not include suspended callers or save/service
frames and is not a whole-process stack bound.

## Exact remaining recursive and payload join

The exception registries preserve the original argument after a printer throws
and advance to the next registration. They do not recursively report the new
failure. However a successful prefix of a wrapper printer may recursively
print its inner exception, then throw; fallback can traverse that same inner
exception again. The accepted first-inline argument addressed this with a
depth-specific recurrence. Its depth-two premise concerned that interval's
TypeMismatch payloads and does not establish the whole-suffix error family.

In particular, the accepted source registration suffixes include
Loc.Located, Trans.TransFailure and Pretty's BadInstance(BadI_rs_type(_,exn));
OCaml Fun.Finally_raised delegates through Printexc. The clone constructor at
pmodule.ml:1389–1391 catches cty_match failures into BadI_rs_type. Library and
cleanup failures must be classified before choosing a maximum wrapper depth
or multiplying per-registry resource costs. Unselected Dynlink/strategy/argument
parser wrappers cannot simply be added as though they were reached either.

The remaining computable interface needs, for every outer site, an actual
upper bound on reachable wrapper depth and a per-layer bound on recursive
delegations across the Why registry, its Printexc adapter, OCaml printers and
fallback. If Q_j bounds such child calls at level j and C_leaf bounds leaf
registry work, the cumulative recurrence is
`C_j <= C_local,j + Q_j*C_(j-1)`, including each attempted prefix. Its inputs
must come from the selected constructor/dispatch graph, including secondary
cleanup and signal failures; neither the finite site count nor immutable
strings supply them. This packet leaves those inputs and the resulting inner
invocation totals null. It does not assert a universal eight-attempt factor.

Normal JSON result/warning trees, exception text, scalar conversions, annotation
helpers and all standard-core text/event budgets still need their own payload
and occurrence joins. No byte limit is inferred from 2A+4 reports. The
backtrace subtotal alone is composable now under its named inherited premises;
do not add it twice through surrounding strings. Oracle 7–9, 13, 21 and 25
remain unchanged; #119/#153 remain incomplete, production #88–#94 unstarted,
and PR #121 draft/unmerged. Selected author setting is GPT-6 Astra / Extra High;
runtime confirmation and token/cost telemetry are unavailable. The packet's
round record states observed time and the single new comparison check.
