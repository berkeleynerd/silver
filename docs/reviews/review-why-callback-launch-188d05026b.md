# Review of retained Why callback multiplicity and launch alternative

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed commit `188d05026b2648d32a6de877c817232e201bb81f`, based on corrected
callback packet `f5475afb3513443a5a05bdfd1e6e7a8ab3a27269`.
**Accepted as a conditional source/interface result.** No material correction
was found. The two-save bound depends on the explicit successful POSIX,
single-dispatcher/producer, no-reinstallation and no-unmask premises. It does
not establish the missing session charge, complete callback capacity or a
validated masked-launch configuration.

## Signal multiplicity

The central invariant is valid under the stated premises. At the first
successful SIGINT-ignore commit, no callback has yet entered saving: every
save path passes that commit first. There is at most one active SIGINT callback
that can reach saving and at most one stale OCaml pending bit. With no further
eligible producer and no handler reinstallation, at most one later callback
can consume that bit. The active callback and that later callback each enter
saving at most once. This proves an upper bound of two save-entering callbacks,
including paths where a save throws and the interrupted transform continues.

The two pending states are correctly distinguished. The native OS handler in
`signals_nat.c:100–112` only records delivery; `signals.c:129–135` sets a bit.
Repeated recordings therefore coalesce at the OCaml level. The dispatcher
clears that bit before `caml_execute_signal_exn` blocks SIGINT, leaving a real
clear-to-block interval in which delivery can restore one bit. After blocking,
the current worker cannot run another raw SIGINT handler. A kernel-pending
SIGINT is a different state: successful `sigaction(SIG_IGN)` discards it,
as the archived POSIX text specifies, without clearing the OCaml bit. The
upper bound does not require a bound on how many external signals arrive.

The setter commits the disposition before allocating the old `Signal_handle`
result or processing pending signals. That allocation cannot enable another
SIGINT callback on this worker while SIGINT remains blocked. Pending dispatch
invoked inside the callback queries the mask and skips SIGINT; raw native
signal delivery is not immediate OCaml callback dispatch. Restoring the saved
mask after normal return or an exception can expose the stale bit, but cannot
recreate a producer once SIGINT is ignored. The GNAT handler does not reinstall
its SIGINT closure. The inspected tick thread blocks OS signals and records
SIGVTALRM, not SIGINT.

The producer premise matters as much as one OCaml worker. An additional
eligible native thread or an independent writer of the SIGINT bit is excluded
by the stated claim; startup's one-thread observation alone would not prove
that exclusion for all later states. Likewise, successful masking and the
first ignore commit are premises, not consequences of the model. The note
does not extend the bound to arbitrary failed service retries, their total
allocations, or all other callbacks. These limitations must travel with any
reuse of the result. The review adds no assumption to the Oracle or trusted
boundary and does not classify unproved cases as successful completed runs.

The 29-state model is consistent with this argument. `installed` controls
whether external events can produce a runtime bit or an OS-pending state;
`gap` represents the clear-to-block interval; `masked` precedes the ignore
commit; `ignored`/`saved` retain blocking; escape restores eligibility while
leaving the disposition ignored. The model permits arbitrary delivery
stutters, save failure and continuation, and a two-save abstract path. It
intentionally omits termination paths, which cannot increase the count.
Its Boolean OS-pending representation is sufficient for this upper bound
because the ignore commit discards the pending OS state before unblocking.
The model is not presented as native refinement or an observed execution.

## Conditional registration charge

The packet correctly includes explanation traversal as well as shape traversal.
`Termcode.goal_expl_task` uses `search_attrs`; its selected `Term.t_fold` cases
open let/case/universal-quantifier binders. SV6 `Shape.t_shape` independently
opens binders. The explanation restriction can reduce work relative to a full
opened occurrence traversal, but does not justify omitting its charge.

The definition of `O(t)` counts each opening's cloned variables, including
quantifier list lengths and case-pattern variable sets. Delayed substitutions
must be interpreted before descending, and shared subterms must retain their
occurrence multiplicity. This matches the distinction between substitution
propagation and the actual fresh-symbol calls. The 1,024-byte shape limit
cannot replace that charge: quantifier cloning precedes a later buffer check,
and explanation traversal has no corresponding limit.

`Task.local_decls` filters the existing task declaration sequence, so charging
all proposition declarations is conservative for the identified shape work.
The first `O(goal_formula)` separately covers explanation work. Counting every
successful proof-node visit avoids silently deduplicating a shared session
forest. The term expansion and forest must be finite and source-valid, and
their bound must hold across both saves and all allowed interruption points.
The packet expressly leaves those certificates and preservation arguments open.

The arithmetic is correct:
`61,641 + 2 * (B_binders(S) + R) <= 2^62 - 1` when
`B_binders(S) + R <= 2,305,843,009,213,663,131`.
This uses the two-save premises and a separately justified `R` for all
remaining handler/exit registrations. It is not a completed charge of those
helpers or of other runtime callbacks and allocations. Neither `B_binders(S)`
nor `R` is supplied, so the accepted endpoint remains **61,641**.

The missing input is identified accurately: the signal closure's controller
must join to the current session roots, node/transformation tables, visit
structure, raw tasks and fully interpretable formulas. The retained first-inline
task/Hsdecl graph does not provide that join. The exact equal fixed JSON and
historical XML seed are useful for source-prefix reconstruction, but five
historical XML goals do not count the current transformed in-memory forest.
The note makes no such substitution and does not revive the refuted stable
missing-task exception witness.

## Launch alternative

The explicit `POSIX_SPAWN_SETSIGMASK` rule describes a concrete prospective
launch configuration. The archived specification supports establishing the
requested child mask before its new image executes. The packet correctly
rejects post-spawn masking and inherited ignore disposition alone as substitutes.
It also requires persistent masking across the identified unmask interfaces;
the decidable spawn attribute does not itself prove that persistence.

The recorded socket argument and separate `why3server --single-client -j 1`
select the external-server source route. Masking only Why need not change the
separately launched server's or solvers' masks. The server creates separate
solver process groups, and its disconnect/shutdown paths invoke group cleanup.
Consequently one kill of the server's group is not a sufficient general
cleanup design. The retained source supplies integration evidence, not a
tested supervisor or proof of reaping and failure fallback.

SIGINT masking changes graceful-save behavior; cancellation must be represented
as aborted rather than successful. Normal exit hooks remain enabled, while
forced termination need not run them. The note does not claim that these changes
have been accepted or implemented. It also correctly refuses to attach the
observed 60,496 starting counter to an unexecuted masked prefix. All launch,
cancellation, current-session, full-charge and complete-capacity flags remain
false. The existing external boundary is not silently strengthened.

## Inputs, evidence and review record

The review covers the [research note](../research/retained-why-callback-launch.md)
and all ten files in its [packet](../evidence/retained-why-callback-launch-20261018/README.md)
at the exact target commit. `inputs.json` and `round.json` retain individual
identities and the reused corrected-callback, private-counter and fixed-context
inputs. Source pins are Why3 `9390baf120ef260547dfa14f08e11c890b203d9c` and
OCaml `8eb41f72ded84df884c3671734c947f612091f84`. The new source archive has
SHA-256 `0d26b107d5d4526f198c626f94abbf9a8a3c0a9982ce346751a2929233187902`;
its index identifies exact source URLs/members and official POSIX documents.

The source review inspected the signal recorder, dispatcher, block/restore,
setter and native OS-handler functions, GNAT handler, thread-mask/tick
interfaces, explanation/fold/substitution/shape functions, task declaration
filter, server-selection and cleanup routes. It also inspected the model,
checker, native bodies and invocation/seed/result records. Existing Oracle,
trusted-boundary and review requirements were read; this is research within
the authorized scope, without a language or runtime change.

The author's **0.515001545-second** successful check was reused, including its
seven-body **1,520-byte** comparison with the pinned installed ELF and the
29-state exploration. No successful extraction or check was rerun. One narrow
[symbol-scope observation](../evidence/review-why-callback-launch-188d05026b/native-symbol-scope.json)
resolved the remaining naming/coverage question: all seven retained headers
match their ELF symbol addresses, each byte sequence is contiguous and covers
the full symbol extent, and the retained total includes 57 bytes after symbol
ends. The tool-reported **0.163842-second** command also included preliminary
status and filesystem reads; isolated symbol-check time is unavailable. No
target, debugger, objdump, compiler, solver, proof, build or broad suite ran.
Linux x86_64 was confirmed; the sparse review worktree is on the repository
filesystem. Candidate source files were not edited.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, token usage and monetary cost were unavailable. A reported model
capacity interruption was resumed with the same selected settings; no lower
tier was substituted and completed work was retained. Review began at
**2026-10-18 23:32:04 UTC** and reached report completion at
**23:36:24 UTC**, **260 seconds** at one-second resolution, including the
interruption/resumption and excluding final commit preparation.
Only this report and narrow review evidence are owned by the branch. GitHub,
CLI memory and harness were not written. Integration and the next session-charge
work remain with the parent; this acceptance does not complete the owner's
full retained-tool capacity goal.
