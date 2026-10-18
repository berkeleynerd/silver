# Independent review of the fixed selected-driver dispatch envelope

2026-10-18, [#119](https://github.com/berkeleynerd/silver/issues/119).
Reviewed commit: `2cd4b09820db5819644d43050e10cb9bf4447e10`, comprising
[the source argument](../../research/retained-producer-driver-envelope.md)
and this packet's seven pre-existing files. Selected reviewer: GPT-6 Astra,
Extra High; independent runtime confirmation of model/effort, token usage and
cost is unavailable. Inspection/replay interval: 19:06:44–19:09:02 UTC,
138 seconds, excluding report authoring and commit. Actual host: Linux 7.0.14
x86_64; `scripts/dev.py paths` reports `linux-x86_64`. The live harness goal
was absent; this bounded review followed the parent's explicit assignment.

**Accepted within the stated conditional scope; no unresolved material
finding.** The result bounds dispatch over the five fixed processes by
153 registered proof-node IDs, 459 selected task/prover pairs and 6,120 outer
configured transform applications. Each pair permits at most one
`prepare_task` and one `print_task_prepared` entry. These are upper bounds,
not observed successful executions, physical task reconstruction counts or a
capacity certificate. No premise that a solver succeeds or completes is
needed. The ordinary source/runtime/protocol contracts and the existing
relevant-source correspondence premise remain explicit assumptions.

The accepted initial-registration argument and
[independent review](../retained-producer-fixed-tail-20261018/review.md) were
reused, including the exact five inputs, raw counts, Input_Is_Valid filter
classification and private-driver import lists. This review did not reopen
their complete prefix or perform native execution. No Oracle, toolchain,
production configuration or admission change is accepted by this report.

The following source checks establish the claimed scope:

- **Fixed domain and configuration.** Archived `gnat_main.ml:48–73,332–355`
  and `gnat_checks.ml:201–226,490–505` register only children of the initial
  split, possibly omitting children. Raw counts therefore remain upper bounds;
  the accepted Input_Is_Valid classification alone sharpens four to one.
  `gnat_checks.ml:284–354,598–663` makes every fresh Per_Check child fully
  split, preventing the `further_split`/`add_clone` branch when selected
  provers are exhausted. Counterexamples off excludes `add_ce_goal`.
  `gnat_config.ml:24–55,307–330,531–550,650–673` supplies the retained
  serial, automatic, no-replay configuration and first-selected warning
  prover. The warning branch in `gnat_checks.ml:662–663,1049–1084` does not
  retry other drivers or introduce a fourth driver.
- **Pair-once invariant, including failure.** `next` removes a goal from its
  scheduling set before entry (`gnat_checks.ml:272–280`). With fresh selected
  prover state, `controller_itp.ml:619–652` has no previous result from which
  to adapt limits, and `session_itp.ml:662–675` creates a nonobsolete attempt
  with the requested limits. `controller_itp.ml:594–617` stores each Done
  result before invoking `interpret_result`; `has_been_tried_by` then sees
  the same `Gnat_config.limit` values (`gnat_checks.ml:469–485,1023–1032`).
  Nonvalid results may re-add the goal, but `find_best_untried_prover`
  (`:714–724`) excludes completed identical-limit attempts. Freshness excludes
  obsolete-valid preference, and the built-in Trivial prover has a distinct
  key. Already-proved goals need no selected-driver call.
- **Exceptions and notifications.** Preparation failures leave no completed
  result, so that fact alone would not prevent retry. The actual missing
  transition is decisive: `gnat_main.ml:95–116` handles InternalFailure with
  a warning and no `handle_vc_result` or requeue. The controller pops the
  queued attempt before preparation (`controller_itp.ml:517–536`). Uncaught
  exceptions stop their path; Interrupted and other non-Done notifications
  do not requeue through the normal interpreter. Terminal calls are removed
  before callback dispatch, and later missing-call lookups are ignored
  (`:448–490`). The fixed script scheduler and serial prover branch exclude
  editor/replay and multi-prover rescheduling. Infinite NoUpdates polling
  adds no pair entries, but its work and wall time are not bounded here.
- **Preparation and printing counts.** `controller_itp.ml:412–440` retrieves
  the task and calls `Driver.prove_task` once per popped attempt.
  `driver.ml:372–389,456–474,490–494` then has one preparation entry, a
  single fold over configured directives, and at most one prepared printer
  entry; exceptions can only prevent later entries on this path. The accepted
  lists contain 15, 13 and 12 directives, hence 40 per candidate registered
  task and 6,120 over the five processes. `smtv2.ml:1077–1082` confirms the
  three named printer registrations. This count excludes recursive helper
  dispatch, declaration callbacks, term visits and work internal to printers.
- **Original task versus reconstruction.** `session_itp.ml:310–311,679–690`
  binds each proof-node ID to its original task, and `task.ml:65–74` gives
  immutable task-head fields. Selected proof-attempt state does not replace
  those goal tasks. Nevertheless `driver.ml:330–389` adds driver context
  and applies transformations, so multiple driver calls can reconstruct
  physical tasks and allocate repeatedly. The packet correctly does not
  transfer the earlier registration no-collection interval, allocation bound
  or semantic-count maximum 47 to this later lifetime.
- **Limited numeric calculation.** The retained float declarations occur at
  `ieee_float.mlw:903,945,987`. `eliminate_literal.ml:135–153` constructs
  `(2^s - 1) * 2^(2^(e-1) - s)`; `src/util/constant.ml:39–40` in the pinned
  accepted source archive links that constructor to
  `Number.real_value`, whose normalization is at `number.ml:91–108`.
  The checker preserves factors of five and exactly establishes numerator
  bit lengths 128/1024/16384 and decimal digits 39/309/4933, with denominator
  one. `number.ml:302–322`, `smtv2.ml:320–334` and
  `printer.ml:345–407` support the separately stated fraction/radix output
  concerns. The calculation covers only those three direct declarations;
  it neither inventories all literal origins nor bounds all backend output.

The callable identity repair is independently confirmed in the frozen code.
`compose()` invokes `verified_inputs()` before reading the accepted result's
driver dispatch. The latter checks dependency byte lengths and SHA-256 values,
the source archive identity, regular and uniquely named archive members, exact
member identities, byte equality of all 15 selected Why3 sources with the
accepted source archive, and the imported float file's accepted archive join.
Both the CLI and checker use that same callable. The full result comparison
also retains every false capacity flag. This is the documented ordinary
Python invocation with assertions enabled and the reviewed manifest; no
arithmetic script is being treated as a machine-checked control-flow proof.

Replay performed exactly once from the private worktree:

```sh
python3 docs/evidence/retained-producer-driver-envelope-20261018/check.py
```

It exited zero with empty stderr in 3.215907666 seconds measured around the
checker subprocess. It transitively replayed the accepted registration checker
once and passed the isolated CLI test that alters cvc5 printer evidence:
the modified dependency was rejected before any composition output. The
complete recomputed result equaled `result.json`, including raw count 156,
registered upper bound 153, pair upper bound 459, transform upper bound 6120,
and false backend-printer and whole-pipeline capacity flags.

The reviewed packet identities were:

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| `inputs.json` | 7,094 | `7cf91642571924ea1cc81c02a983605f4fe3e3be538440f9a42bcc9d6712beac` |
| `sources.tar.gz` | 104,488 | `cde4b3e2e77cc0c714f706c87507c02116d78a35b70789a92aca31dbe5a3bd89` |
| `result.json` | 17,988 | `1cfbadc5ce52073540798ffc5439304315c18adea2a9e29bfd1bf3279487b436` |

Material finding disposition: the pre-freeze callable identity gap is fixed
and verified above. The `Introduction.Hsdecl` counter concern is independently
confirmed and remains explicitly open, as required by this increment's scope:
`introduction.ml:33–52` returns the same declaration from `tag`, while
`hashcons.ml:41–45` increments whenever the merge result is physically the
same object. Same-object hits therefore defeat a distinct-object or
cache-miss-only counter bound. No such bound is claimed here.

Prepared-task domain capacity, cumulative allocation and cache/name/counter
lifetimes, complete semantic-count coverage, every reachable numeric origin,
unfolded printing work, formatter/buffer/filename limits, and subsequent
server/solver/result/timing/session/response joins remain open. The packet's
capacity and production-adoption flags remain false. These retained
obligations are not unresolved defects in the finite dispatch claim and do not
constitute completed work on #119. No native capture, solver run, broad
build/proof/test, GitHub write or CLI-memory update was performed. The only
repository edit made by this review is this report.
