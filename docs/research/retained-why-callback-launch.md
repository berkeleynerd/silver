# Retained Why callback multiplicity and launch alternative

Research [#119](https://github.com/berkeleynerd/silver/issues/119), Linux x86_64,
2026-10-18. The default signal protocol supports **at most two SIGINT callbacks
that enter session saving**, under the explicit source/runtime premises below.
Repeated external SIGINT is therefore not, by itself, an established mechanism
for unbounded identifier registration. One pending runtime bit can survive the
clear-to-block interval, so a one-shot claim would be too strong.

This finite multiplicity does **not** finish the counter or allocation proof.
The retained capture does not identify the controller's complete session graph,
and the per-save/exit work has not been fully charged. The accounted endpoint
remains **60,496 + 1,145 = 61,641**. Complete continuing-call capacity, complete
callback closure, allocation/auxiliary capacities, history and family claims
remain unestablished. This packet does not revive the missing-task witness
withdrawn in [the corrected callback packet](retained-why-inline-callback-closure.md).

## Source-backed finite multiplicity

The [evidence packet](../evidence/retained-why-callback-launch-20261018/README.md)
reuses exact Why3 revision `9390baf120ef260547dfa14f08e11c890b203d9c`, OCaml
revision `8eb41f72ded84df884c3671734c947f612091f84`, installed executable SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`, and the
retained same-process counter/input evidence. Newly retained exact
`runtime/signals_nat.c` completes the relevant signal interface. Seven named
native bodies were extracted from the existing disassembly and all 1,520
instruction/continuation bytes checked against the pinned ELF. No new target,
debugger, disassembler, compiler or solver was executed.

The claim is an inspected source/interface argument, with these premises:

- The selected native Linux runtime uses the documented successful POSIX
  masking operations. SIGINT is a valid, blockable signal. The first ignore
  setter commits successfully on a path reaching session save; the handler's
  `Invalid_argument` catch is not used to bypass an invalid SIGINT number.
- One OCaml worker dispatches these callbacks. There is no concurrent eligible
  worker executing another SIGINT handler, no application producer that writes
  its pending bit, and no reinstallation of its handler during the bounded
  invocation. The retained process has one initial thread; the reused native
  API inventory identifies no external Thread.create/C-thread-register
  consumer. The native tick routine blocks OS signals and records SIGVTALRM,
  not SIGINT. These are the existing scoped interface findings, not a general
  theorem about arbitrary foreign code or forged aliases.
- No callback code unblocks SIGINT during this callback, before the runtime
  restores its saved mask. The live Why3 source route and inspected signal
  setter/thread interfaces supply no such unmasking or reinstallation.
  Successful `caml_sigmask_hook` preserves the specified mask operations.

There is no new premise that signals do not arrive and no queue snapshot is
needed. The initial OCaml pending bit may be either zero or one.

1. `signals_nat.c:100–112` has `handle_signal` call only
   `caml_record_signal(sig)` (besides errno handling). It does not directly
   invoke an OCaml handler. `signals.c:129–135` assigns
   `caml_pending_signals[signal_number] = 1`; repeated recordings coalesce into
   this bit, not a growing callback queue.
2. `signals.c:72–104` queries the thread mask, skips blocked signals, clears
   the selected pending bit, then calls `caml_execute_signal_exn(i, 0)`.
   Between the clear and the subsequent block, another OS delivery may set the
   bit back to one. This is the source of the conservative second invocation.
3. `signals.c:201–227` blocks the selected signal before calling the OCaml
   closure and restores the original mask after the callback, including an
   exception result. Nested pending-action processing during that callback
   sees SIGINT blocked and skips it. Raw signal delivery is not recursive
   OCaml callback dispatch in this selected native runtime.
4. `gnat_main.ml:298–309` first sets SIGINT to ignore, then SIGHUP/SIGTERM,
   then saves the session. `signals_nat.c:114–154` installs `SIG_IGN` using
   `sigaction`. POSIX specifies that setting a pending signal to SIG_IGN
   discards it even while blocked. Further ignored signals cannot call the
   old OS handler. This operation does not clear the OCaml pending bit.
5. `signals.c:447–490` allocates the previous Signal_handle result only after
   `caml_set_signal_action` has committed, then processes pending signals.
   This allocation and pending-action processing do not invalidate the count:
   SIGINT remains blocked throughout the OCaml callback, and its OS disposition
   is already ignored. A failure before save can reduce the number of saves.
6. If the first save exits the process, there is no continuation. Conservatively
   permit it to escape and the interrupted transform to continue. The stale
   OCaml bit can now dispatch one more callback, despite the ignored OS
   disposition, because pending processing reads its retained closure. That
   dispatch clears the bit. There is no permitted producer to refill it once
   SIG_IGN is committed. A second save cannot be followed by a third.

The invariant after the first successful ignore commit is: no new OS-produced
SIGINT runtime bit; at most one old bit remains. Before that commit no callback
has entered saving. Thus at most two callbacks reach saving. The argument is
about callbacks that reach the identifier-producing save path; it does not
bound arbitrary failed signal-service retries, total C error-path allocation,
or all other runtime callbacks. Such failures are outside the successful
service premises used here, and this packet makes no complete allocation claim.

`multiplicity.py` exhaustively checks a 29-state abstraction of this protocol,
including arbitrary signal-delivery stutters and a stale-bit path reaching two
saves. Its transitions are mapped to the source above. This is an independently
checkable finite model and source argument, **not** a machine-checked refinement
of native code and **not** an observed two-callback execution.

## Concrete conditional charging interface

A save charge must include **both** explanation and shape traversal.
`Termcode.goal_expl_task` (`termcode.ml:64–99`) calls `search_attrs`; the latter
uses the safe `Term.t_fold` for let/case/universal-quantifier nodes. That fold
(`term.ml:1284–1296`) opens binders and clones variables. SV6 shape traversal
independently opens binders through `Shape.t_shape`, as already established.
The 1,024-byte shape-buffer limit is not a bound on these registrations:
explanation traversal has no such limit, and a quantifier can clone its entire
variable list before the next shape-buffer push checks the limit.

For a source-validated, finite, fully opened term occurrence tree, define its
opening mass `O(t)` by summing one for each let/epsilon binder, the quantifier
variable-list length for each quantifier, and the number of distinct pattern
variables for every case branch, recursively over all children and triggers.
Count duplicated occurrences, not merely distinct heap blocks. Interpret delayed
`bv_subst` substitutions before charging descendants, using abstract fresh names;
a raw stored-node count is insufficient. `term.ml:739–781` propagates saved
substitutions without directly registering variables; the opening functions at
799–832 register the cloned variables. A certificate must establish this finite
expansion and source correspondence, not assume a general session term has the
specific envelope proved for the first inlining input.

For each proof-node **visit** made by `fold_all_session`, let `t_g` be its raw
task when the existing detachment guard succeeds. A conservative identified
binder contribution is:

```text
B_binders(S) = sum over successful APn visits g of
                [ O(goal_formula(t_g))
                  + sum over proposition declarations d in t_g of O(formula(d)) ]
```

Using all proposition declarations is conservative because `Task.local_decls`
selects a subset of the existing task declaration sequence (`task.ml:245–278`),
and shape truncation can only stop its traversal early. The complete opening
mass also bounds explanation's restricted traversal. Forest sharing must retain
visit multiplicity; it cannot silently deduplicate repeated node IDs.

This is a source-supported bound on the identified binder-opening contribution,
not a claim that every helper or installed exit hook has already been charged.
Let `R` bound all remaining handler/exit identifier registrations per invocation,
with its own source justification, and let a session certificate bound
`B_binders(S)` uniformly over allowed interruption points and the two attempts.
The arithmetic composition would then be:

```text
counter_end <= 61,641 + 2 * (B_binders(S) + R)
B_binders(S) + R <= 2,305,843,009,213,663,131
    implies counter_end <= 2^62 - 1
```

No value for `B_binders(S)` or `R` is supplied or certified here. Consequently
this conditional inequality is not added to the accepted endpoint.

The precise missing graph input is the session reached from the GNAT signal
closure's captured controller, including `controller_session`, `session_files`,
file/theory root lists, proof-node and transformation tables and their child
lists, and the `session_raw_tasks` mapping to task chains/formulas. Formula
records must include bound-variable lists, pattern variable sets, triggers,
saved substitutions and relevant well-formedness data. A separate visited-forest
certificate must check cycles and occurrence multiplicity, preserve the table
and task identities, and establish that the selected inline call and save
updates do not enlarge this charged projection. Source-prefix construction is
an alternative to observing the graph. The retained task/Hsdecl graph and private
counter do not provide that closure-to-session join. No new capture is requested
or performed by this packet. Remaining-helper/exit-hook charging is a separate
source obligation, rather than an excuse to search for speculative exceptions.

The next graph derivation has a concrete fixed seed, rather than an arbitrary
unknown input. The [fixed-context packet](retained-producer-fixed-context.md)
retains the exact 121,828-byte Input_Is_Valid JSON with SHA-256
`d146b75d28832260c49de3d8eb5f816c8481595127dc56dfaf3512cbdb6a4b2d`,
identical to this invocation, and a historical 1,521-byte session XML with one
file, one theory, five goal occurrences, one transformation and six proof
attempts. `fixed-session-seed.json` binds those archive members. Those historical
XML occurrences do not count the current in-memory transformed tasks or expose
their formulas. The fixed-context source projection explains controller
load/reload, reparse, typing and VC generation before scheduling. Reconstructing
that fixed prefix and the active transformation stage is therefore a concrete
next route to the needed session certificate. The literal-output family adds
no Main backend process or changed fixed module/clone graph; this does not
upgrade the current note to a family-wide capacity proof.

## Decidable launch alternative and its integration boundary

A concrete alternative is to set `POSIX_SPAWN_SETSIGMASK` with a mask containing
SIGINT when spawning **only gnatwhy3**, before its new program image executes.
Use an explicit mask, not the spawn attribute's unspecified default. Preserve
required existing mask bits; leave SIGTERM and required server/solver signals
unblocked. The launcher must check attribute/spawn results and reject a launch
that fails to establish the rule. Calling a mask API after spawning leaves a
race and does not implement this rule. Setting an inherited SIG_IGN disposition
alone does not implement it either: GNAT installs its own handler at startup.

The declarative rule is decidable from the spawn configuration; the zero-SIGINT-
callback conclusion also requires a source/ABI argument that no selected code
unblocks it. OCaml's pending dispatcher checks the current mask even for a
previously recorded bit. `Thread.sigmask`, `Unix.sigprocmask`, `Unix.sigsuspend`
and foreign mask writers are explicit interfaces whose reachability must be
closed; this packet retains their relevant source and does not claim that
whole-program mask preservation is already proved.

The retained argv includes `--socket` and no `--debug`/standalone switch. Its
separately launched `why3server --single-client -j 1` is already recorded in the
capture plan. `gnat_checks.ml:371–376` chooses `connect_external` for this
configuration. Therefore a Why-only spawn mask need not be inherited by the
server or solvers. Preserve that separation: launch the server independently
with its required signal mask, then pass its socket to Why. The server forks
solver children and gives each its own process group (`server-unix.c:313–353`).
Masking a parent that instead launches an internal server would affect that
server and its solver children and requires a different argument.

Cancellation changes materially. SIGINT would no longer trigger GNAT's graceful
session save. A proposed supervisor must treat cancellation as an aborted,
non-successful run, terminate Why through an unblocked termination mechanism,
and explicitly reap Why and arrange server/solver cleanup. A single kill of
the server's process group is insufficient because solvers have separate
process groups. The existing external server's client-disconnect path calls
`kill_processes`, and single-client mode then shuts down; shutdown also calls
`kill_all_processes`. `proc.c:23–30` kills solver groups with SIGKILL. These source
paths are useful integration evidence, not a newly validated cancellation
implementation. Required cleanup, failure fallback and reaping must be checked
against the actual supervisor before selecting this configuration.

Normal completion still executes the ordinary exit hooks; blocking SIGINT does
not disable them. Forced termination does not promise to execute OCaml exit
hooks or save the session. Any requirement to run those hooks on cancellation
must therefore be resolved explicitly. This is an integration design decision
within the authorized research, not an added owner-approval ceremony. No
existing cancellation policy is claimed to satisfy the proposed rule.

Finally, the old capture did not record the signal mask. A future masked launch
is not automatically the same execution: the counter/input/representative join
must be established for its source prefix or separately retained state. This
packet does not attach the existing observed 60,496 counter to an unexecuted
configuration. The default finite-multiplicity route avoids that new prefix join
and is the preferred next charging task.
