# Ordinary ending: preserved task domain and interrupted-save control

2026-10-20 UTC, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119)
and [#153](https://github.com/berkeleynerd/silver/issues/153), base `1f510363e4`.
This source argument closes the ordinary save's **control and logical-input
transfer**, conditional on the caller's validated session and representation
inputs. It does not establish complete save, report or process capacity.
Independent review is required before integration acceptance.

The ordinary save is entered at most once. A nested SIGINT handler cannot
return normally to an interrupted Buffer operation: it either exits or raises,
unwinding that operation. A receiving catch higher in the save can nevertheless
continue with changed shape tables and output state. No transactional rollback,
unchanged serialization, or successful save follows from the control result.

The [packet](../evidence/retained-why-ordinary-ending-control-20261020/README.md)
retains exact source excerpts, the receiving-catch ledger, a conditional
count/byte transfer and focused offline checks. No native target ran. Why3
`9390baf120ef260547dfa14f08e11c890b203d9c` and OCaml 4.14.2
`8eb41f72ded84df884c3671734c947f612091f84` retain the existing
[relevant-source behavior relation](retained-tool-source-identity.md#relevant-behavior-within-the-existing-trust-boundary).
The accepted [native-owner argument](retained-why-native-effect-completeness.md)
is reused for its named effect interfaces, not promoted to a later whole-process
numeric bound. The caller must establish its continued configuration and actual
representation domains at this later entry. No source identity or trust premise
is strengthened here.

## Entry and logical state

Let F be a source-validated, finite session forest at a post-registration cut.
Its projection includes file/theory/root lists, proof-node and transformation
links, raw-task bindings and complete task/formula representations, with actual
visit multiplicity, delayed substitutions, triggers and pattern variables.
This is not merely the registered/check-leaf domain: root and uninteresting
tasks remain in the forest. A caller must bind the projection to the actual
controller/session and check its well-formedness and finite opening certificate.

Use the accepted fresh Per_Check, CE-off, automatic, non-replay scheduling
[envelope](retained-producer-driver-envelope.md). Ordinary selected prover
attempts alter proof-attempt records and proved/status fields; they do not graft
new task nodes. `Driver.prove_task` retrieves the stored task and prepares a
persistent transformed value without replacing `session_raw_tasks`.
The accepted exclusion of further splitting, CE grafting and interactive/replay
routes is required; this is not a theorem for arbitrary controller clients.

The source separation is explicit (`session_itp.ml:645–735`):
`graft_proof_attempt` writes attempts, while `mk_proof_node` writes the raw-task
map and `graft_transf` changes the task forest. The latter routes belong to the
completed registration prefix and excluded successor paths. Extending the
selected preparation functions' native/counter coverage remains separate;
this logical projection theorem does not establish their successful completion.

At ordinary ending, `remove_all_valid_ce_attempt` invokes `remove_subtree`
only on an `APa` (`gnat_checks.ml:1147–1157`). The APa removal arm changes the
attempt table and its parent's attempt map, not proof-node/transformation links
or raw-task bindings (`session_itp.ml:903–969`). Thus even a partial cleanup
preserves F. In CE-off mode it normally removes nothing. Do not infer that
every proof-attempt/status table is unchanged or that partially updated attempt
records always serialize successfully.

Direct `save_session` (`session_itp.ml:2212–2244`) resets/recomputes shape data,
backs up files and serializes. Its read-only traversal of F calls
`goal_expl_task` and `compute_and_add_shape`; neither installs opened terms in
the session. Binder opening creates fresh transient variables and substituted
terms, preserving the represented formulas under the caller's established
opening/freshness invariants. The save's other writes affect shape/checksum
consumers, prover-number assignments, channels/files and `session_dir_for_save`.
They do not change F. The native owner/frame contracts and absence of other
application workers remain necessary to extend this source fact across polls.

Consequently all saves reached during this selected continuation use the same
logical F, even after a failed or partial save. `fold_all_session` visits the
same APn occurrence domain; changing the number of APa visits adds no binder
walk (`session_itp.ml:415–459`). An asynchronous `Not_found` consumed by
`goal_is_detached` may skip a goal, not introduce one. No fixed numerical bound
is taken from the old PID 97103 forest: its 966/1,074/315 constants are not inputs
to this packet.

## One ordinary save and the precise signal bound

`Gnat_scheduler.main_loop` has `with Exit -> ending ()` (`gnat_scheduler.ml:18–26`).
The handler body is outside its protected expression. `ending` performs cleanup,
then exactly one `record_timing (fun () -> C.save_session c)` before reporting
(`gnat_main.ml:270–279`). A throw in cleanup can prevent the save; a throw in
the save/timing cleanup cannot restart `ending`. `Fun.protect` runs its finally
and returns or reraises; it does not retry work. The outer GNAT catch reports
and calls `abort_with_message`, whose last action is `exit 1`. If that handler
throws, it escapes to uncaught processing. Neither route calls the scheduler
or ordinary ending again. Thus there is at most one ordinary save entry.

The bounded interval starts at this ordinary-ending entry and ends when its
save returns to the next reporting stage, or escapes through the specified
error/uncaught/exit route. Later successful `report_messages` work is a separate
successor. For this interval the signal premises are:

- SIGINT selects the installed `save_session_and_exit c` closure, or is already
  ignored after an earlier invocation. The controller/session identity is F's.
- The accepted single-worker POSIX mask/ignore services succeed; no source or
  native client unmasks SIGINT inside its handler or reinstalls its old OS
  disposition/OCaml handler after the ignore commit. The classified pending
  and native owners retain their accepted effects.
- The ordinary save, timing-finally and named error/exit roots introduce no
  signal registration, loader, reflection or worker-creation edge. The only
  reached setter is the handler's three ignore calls. This follows from the
  source roots in the packet together with the accepted formatter/exception
  and native-owner effect interfaces, not from importing an old numeric flag.

Under those premises the earlier [signal protocol](retained-why-callback-launch.md)
has the following independent application to this interval. Any number of
external SIGINT deliveries before the first ignore commit coalesce in one
runtime pending bit (`signals_nat.c:100–112`, `signals.c:72–104,129–135`).
The dispatcher clears that bit, blocks SIGINT, and invokes the handler
(`signals.c:201–227`). Nested pending processing skips the blocked signal.
The handler commits SIG_IGN **before** entering save; POSIX discards pending
OS deliveries and subsequent ignored deliveries cannot refill the runtime bit.
One stale bit can have been recorded between the original clear and block.
On exception, restoring the mask can permit that one further dispatch, which
clears the bit. It cannot produce a third save without a prohibited refill or
reinstallation. The setter commits before allocating its old-handler result
(`signals.c:447–490`); a pre-save failure does not increase save entries.

Thus **at most two save-entering SIGINT callbacks** occur in this interval,
and **at most one is simultaneously nested inside the ordinary save**. They
need not be successful, and a higher catch may permit the second after the
first raises. This does not assume only one external signal, nor bound arbitrary
failed service attempts, all callbacks, or signal saves before this interval.
If any listed premise is unavailable, the exported upper bound is unknown;
the checker does not silently use two. A larger process composition must join
the continuing configuration and any remaining signal budget explicitly.

## No return to an interrupted Buffer operation

`save_session_and_exit` has only a local `Invalid_argument` catch around its
three signal setters, followed by `C.save_session c; exit signum`
(`gnat_main.ml:298–309`). That catch does not protect save or exit.
`Stdlib.exit` executes exit hooks and `sys_exit` (`stdlib.ml:550–570`);
successful `sys_exit` is terminal. A hook or save exception instead propagates.
There is no branch returning unit from this handler to the interrupted client.

The runtime returns an exception result from the callback and raises it at the
interrupted operation (`signals.c:260–305`, `fail_nat.c:63–87,188–191`).
Buffer's resizing/append bodies contain no receiving OCaml catch
(`buffer.ml:77–170`). The selected Format output path has no catch that turns
that failure into a return from Buffer. Therefore a handler that mutates Shape
cannot resume the interrupted `resize`/append with its saved `old_pos`, `old_len`
or `new_position`. This discharges that specific reentrant-resumption concern.
It does not assert that an ordinary save cannot continue at a higher catch.

Each nested save is itself protected from another SIGINT save by the mask.
Under the native frame and usual Buffer arithmetic/representation premises,
its failed prefixes preserve Buffer's own position/backing invariants: failed
growth occurs before publication, and the final stores do not invoke an
application callback. Another higher-level append then reads current fields.
No assumed fresh zero position is used after a caught nested-save failure.

## Receiving catches and their effects

The full source-bound [ledger](../evidence/retained-why-ordinary-ending-control-20261020/control-ledger.json)
groups the reached catches by protected expression and continuation.

| Receiving family | Continuation and retained effect |
| --- | --- |
| Session lookup/defaults and detachment | A failed lookup returns an empty/default value, skips an APn, or becomes `BadID`. It does not insert or replace a raw task. |
| Explanation `Not_found` / `Exit` | Drops an attribute match or stops explanation search. It does not retry a binder-bearing traversal. |
| `Task.local_decls` `Not_found` | Can recompute a selection suffix, but returns an ordered subset of the input declarations. Selection performs no binder opening. Shape traversal starts after selection returns. |
| Shape name and identifier-printer misses; decoding sentinels | Select a local name/cache fallback. Nested saving cannot alias this outer fresh printer/alpha map. These paths do not restart a term or binder opening. |
| `ShapeTooLong` | Abandons the current proposition; copies current buffer contents, clears and advances. No formula retry. |
| `Gshape.add_shape` miss | Can resume insertion after nested clearing/writes. The maps and `n` need not agree as before interruption; it still performs at most one insertion attempt for that caller. |
| Prover-statistics misses and prover-ID search `Not_found` / `Exit` | Supply defaults or leave the scalar search and insert an ID. Partial/nested mutation is not rolled back. No logical term traversal occurs here. |
| `save_ident` / saved-shape/checksum defaults | Use existing identifier text or an empty/dummy saved value. They do not print a new logical term or create a task. |
| Container iteration cleanup | Restores traversal bookkeeping and reraises; no user callback replay. Source-owned scalar map equality/comparison does not register Why identifiers. |
| Timing `Fun.protect` | Executes its finally once, then returns/reraises; finally failure becomes `Finally_raised`. No ordinary-save retry. |
| GNAT outer / uncaught / exit | Forward to reporting or termination, never ordinary ending. Exit gates clear before hooks; terminal `flush_all` is not itself once-only. |

The opening bodies (`term.ml:739–831,1284–1296`) contain no retry catch around
fresh-variable construction. Pattern rebuilding can translate an arity error,
but does not repeat `pat_rename`'s variable cloning. The declaration-selection
suffix catch above contains no opening. Remaining lookups, name decoders and
scalar/formatter leaves contain no binder-bearing retry. Accordingly a partial
or resumed save still opens no more binders than the full conservative walk of
F. Logical/pattern errors and their diagnostic payloads retain their actual
routes; this packet supplies no generic zero diagnostic charge or reuse of the
old type-specific D allowance for an unjoined forest.

Raw F is preserved even when a returned shape has been affected by a nested
save. The two Gshape maps and `n`, per-goal saved shapes, prover-number choices,
open channels, partially written files, `session_dir_for_save` and exit gates
can change. In particular, a partial nested reset/insertion can invalidate a
preexisting relationship between a saved shape list and the global dictionary.
No inverse-map consistency, faithful saved-artifact theorem or success of a
later reader is asserted. If such an invariant is used by the eventual capacity
or assurance argument, it needs an explicit restoration/dependency argument.

## Conditional quantitative interface

For the actual F, the caller supplies nonnegative mathematical upper bounds:

- B: explanation opening mass plus all proposition opening mass, with complete
  delayed-substitution/trigger/pattern expansion and repeated APn occurrences.
- J: all possible nonempty proposition/explanation `add_shape` calls per save.
- G: APn occurrences per save.
- L: the complete **untruncated** number of bytes that shape-output operations
  can append per save, including the full constant-formatting output and a
  bound for all allowed name/alpha/suffix fallback outcomes. L is not the raw
  graph size, the final 1,024-byte truncation limit or one observed output size.

With the source and signal premises established and k<=2 remaining callbacks,
at most `1+k` save traversals contribute. The exports are `(1+k)*B` binder
registrations, `(1+k)*J` insertion calls, and `(1+k)*G` APn visits. A shape
buffer position after its first save-owned clear is at most `(1+k)*L`:
clear reduces position, successful append increases it by its charged bytes,
and the no-resumption result excludes a stale interrupted append's later store.
This deliberately avoids reusing the serial-save 1,024-plus-one-atom argument
after nested mutation. Source-event and byte bounds do not establish all
allocation, lookup, formatter-queue or scalar-prover-counter capacities.

The executable transfer leaves unspecified B/J/G/L as null and never returns
whole-save, whole-counter or whole-pipeline success. It reports mathematical
products separately from their required tagged-integer/String guards. A
successful bound for binder registrations also needs the caller's starting
counter and every other owner, including diagnostic work. No numeric current
forest has been instantiated and no production membership changed.

The next joins are the five exact forests and their opened/atom certificates,
the later configuration/representation interface, all required save/serialization
representations and any assurance-essential saved-artifact invariant. Later
driver preparation, printing, solver/result/report capacities and the full
current grammar remain separate #119 obligations.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation and
token/cost evidence are unavailable. The packet's round record reports the
measured interval and focused check time. No CLI memory update is claimed.
