# Silver handoff

Updated on 2026-10-12 on Linux x86-64. Read [AGENTS.md](AGENTS.md),
[oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the newest
[session memory](docs/session-memory.md) before substantial work. Inspect Git
status and the live harness goal; historical goal states are not current instructions.

## Current work

**Close the existing features under composition** is the first roadmap priority.
The owner requested revisiting the narrow completed increments before accumulating
more isolated capabilities. The [roadmap](roadmap.md#current-development-sequence)
defines the ordered work and closure criteria; the
[current assessment](docs/language-generalization.md) records restrictions and
their reasons. Begin with the explicit fragment, restriction/capacity inventory
and shared binding/expression foundations, then compose statements, branches and
existing library effects. No new syntax is supported by this planning update.

Repeated output was authorized on 2026-10-11, but its proposed four-call cap was
rejected as unjustified. Its scope is now part of sequencing and effect
composition. The sole preliminary code edit in
`proof/Silver/ComposeAdmission.lean` remains uncommitted, incomplete and unvalidated;
it still contains the rejected constant and must be reconciled during
implementation. Preserve it and unrelated scratch; do not attribute the previous
checkpoint to this intermediate working tree.

The latest supported implementation is **Copy String Values**, commit
`e9d18f1996`, based on `96b98e1`. It adds up to two literal-backed constants before
the mutable result,
result initialization and equal-length assignments from either constant, and
constant references in bounded output expressions. The existing six output
shells and one terminal output per successful path remain. See the
[capability record](docs/copy-values.md) for scope, review and exact validation
inputs. The complete physical Linux checkpoint passed: native compiler audit,
build and full tests, complete Lean source correspondence and fresh axiom/coverage
audit. Optional independent replay was not requested. The implementation/review
target is the commit introducing `samples/copied_result.adb`, based on `96b98e1`.

This desktop chat recovered the completed CLI **Compose String Results**
context; it did not import that chat or reopen its goal. No active harness goal
was created for this increment. The previous capability is complete in
`96b98e1`, with [its original evidence](docs/string-results.md). The live harness
was rechecked on 2026-10-12 and has no active goal. Commit and publication
authorization persists; hosted Actions remains disabled. This documentation
update does not create a harness goal or change the Oracle.

The supplied [review of `d375aec`](docs/lean-iteration.md#external-review-of-d375aec)
has been assessed and its confirmed small repairs completed: reject direct
kernel-check bypasses in Lean inputs and retained build traces, test default-mode
failure paths and the real axiom audit, and strengthen assignment-membership
header correspondence. Complete cached Linux Lean validation and the affected
test suites passed without rebuilding source certificates. Replay remains optional.
The [three full final reviews](docs/lean-iteration.md#external-review-of-d375aec)
arrived in `26737d9`; their findings have been assessed and dispositioned.
Broader test promotion and comment-only proof-input edits remain deferred.
The retained native proof's
full manifest belongs to its original snapshot because the Lean runner changed;
its Ada and native configuration inputs remain unchanged. The repair/review target
is `767a33c`, based on `26737d9` and reviewing `d375aec`. That repair and the
earlier optimization goal are complete, as is the Copy String Values task above.

The [focused Lean runner](docs/lean-iteration.md) and selected workflow
simplification are complete. `check_lean.py --target MODULE` synchronizes current
inputs, builds the selected modules/imports and performs a fresh scoped axiom
audit. Default invocation remains a complete cached source-correspondence build
and coverage/axiom audit. Separate replay (`--replay`, alias `--full`) and detailed
provenance (`--provenance`) are explicit optional investigations. `--clean` no
longer implies replay. Focused evidence is separate and cannot establish complete
assurance. Native runner regressions, scratch replay/axiom probes and the complete
cached Linux check passed, preserving all twelve certificate objects. The completed optimization goal covered these changes; its implementation/review target is the
commit introducing `proof/Silver/AxiomAudit.lean`, based on `fe539a5`.

The bounded [Lean compartmentalization](docs/lean-compartmentalization.md) is
complete and adopted. Each embedded Ada file has its own Lean dependency, and
stable lexical/name helpers occupy a separate SPARK package. Complete Linux
native proof/tests, Lean build/axiom audit, fresh kernel replay and independent
evidence review passed. Existing evidence and caches are preserved. The
implementation/review target is the commit introducing
`src/silver_output_lexical.ads`, based on `1ed039e`. No language expansion occurred.

The owner authorized the runner follow-up after questioning routine replay and
bookkeeping. The workflow change retains actual-source proofs, correct
dependencies, fresh axiom/coverage auditing and input stability. No language
capability or further certificate framework was begun.

[Input-dependent branching](docs/input-branching.md) is complete: one String
equality on validated argv input selects two terminal literal-output branches;
invalid input reaches the existing rejection branch. All eight productions
passed the stable-input Linux checkpoint: native compiler audit, full test
suite, full Lean build, fresh axiom audit and independent fresh kernel replay.
Independent source review and final evidence corroboration found no material
findings. The Oracle, runtime operations and driver/report policies are unchanged.

The preceding branching implementation/review target is the commit introducing
[samples/input_branching.adb](samples/input_branching.adb), identifiable with:

```sh
git log --diff-filter=A -1 --format='%H %s' -- samples/input_branching.adb
```

It is based on `4422316`. The preceding assignment implementation and review
target `44fd8ea` retain their [completed evidence](docs/string-assignment.md).
The earlier branching and compartmentalization tasks did not request a replacement
harness goal. The runner follow-up later did, and that goal is complete. Recheck
the live state at resumption rather than treating historical goals as new instructions.
The [runner follow-up](docs/lean-concurrency.md#runner-follow-up) and
[native I/O optimization](docs/native-io-performance.md) also remain complete.

After observing the serial certificate cost, the owner requested end-of-day
checking or serious compartmentalization. The [workflow](development.md#proof-loop-and-validation)
now batches expensive source-correspondence checks at a stable end-of-session/day
checkpoint, with focused native/model checks during iteration. Preserve the
completed objects and caches. The bounded source/dependency assessment requested
before the next language increment is now complete, as recorded in the
[architecture follow-up](docs/architecture-review.md#proof-structure-and-the-expensive-rebuild)
and compartmentalization record. Changed-body checking and whole-project replay
remain expensive. The certificate representation is unchanged.

The former ordered increments are complete through Copy String Values. Their
narrow scopes retain their assurance. The
[current consolidation sequence](roadmap.md#current-development-sequence) now
takes priority; do not equate those completed milestones with full compositional
closure or resume adding isolated whole-program templates by default.

## Local tools and evidence

The desktop runs on the physical Linux x86-64 host with 22 available CPUs and
approximately 91 GiB RAM. The stopped CLI microVM had 12 CPUs and 31 GiB RAM;
its retained evidence keeps that attribution. Both environments use the same
host-keyed artifact namespace, so keep one writer per cache. Native pinned tools
and runtime readiness passed the read-only handover check. The completed Lean
checkpoint used 12 Lake workers, 12 threads per process and the 12,288 MiB
per-process threshold. Use `python3 scripts/dev.py paths` for the actual
installation and artifact paths. GNATprove uses all cores by default; Lean uses
all available Lake workers and per-process threads, with independent overrides.
The [concurrency record](docs/lean-concurrency.md) distinguishes measured speedups
from remaining serial work and explains the per-process memory threshold.

During iteration, choose the smallest relevant check and use existing caches;
these commands are alternatives, not a sequence after every edit:

```sh
python3 scripts/dev.py build
python3 scripts/dev.py prove
python3 scripts/dev.py test -- -p test_branching.py
```

Choose tests for the affected behavior and batch edits before expensive
source-certificate rebuilds. Use `python3 scripts/check_lean.py --target
Silver.ComposeMain --memory-mb 12288` for focused model feedback. Without a
target, a changed embedded Ada source still triggers its certificate rebuild.
Once a capability's inputs are stable, normally at the end of the session or
day, run the full test suite, `dev.py prove --full`, and `check_lean.py` without
a target. This retains complete compiler and source-correspondence validation
with cache reuse. Add `--replay` only for an explicit independent kernel audit;
it is no longer part of every checkpoint. Repeat only validation affected by subsequent
changes, failures or unresolved concerns. Documentation-only follow-ups need
lightweight checks. See the [validation cadence](development.md#proof-loop-and-validation).
Monitor aggregate host memory when running heavy
commands together. Preserve `.tools/<host>/`, `.silver/<host>/`, scratch files
and all foreign-host evidence. Source/runtime installation moves require
bootstrap and rebuild under the [platform coexistence rules](docs/platform-coexistence.md).

The review repairs' evidence is under
`.silver/linux-x86_64/review-d375aec-2026-10-11/`. The runner follow-up's evidence is under
`.silver/linux-x86_64/lean-iteration-2026-10-11/`. The completed partition's evidence is under
`.silver/linux-x86_64/compartmentalization-2026-10-11/`. The latest completed
capability's evidence is under `.silver/linux-x86_64/copy-values/`; the preceding
composed-result evidence is under `.silver/linux-x86_64/compose-results/`.
The earlier branching evidence is under
`.silver/linux-x86_64/branching-validation/`, and the preceding assignment evidence
is under `.silver/linux-x86_64/assignment-validation/`. Earlier review follow-up records
are under `.silver/linux-x86_64/review-44fd8ea/follow-up/`. Native I/O measurements,
validation and preserved before/after reports are under
`.silver/linux-x86_64/native-io-static-2026-10-10/`. Prior canonical
reports/manifests are preserved separately from new runner checks. Earlier
host recovery and Linux ARM64 records retain their original input and platform
scope in the [host-readiness record](docs/host-readiness.md) and linked artifacts.
Linux is primary. macOS proof work is a non-goal for the current follow-up; retain
existing artifacts without seeking or rerunning macOS validation. GNAT Pro is untested.

<a id="recover-and-preserve-the-old-vm-evidence"></a>

## Git, recovery and session state

The owner authorized committing and publishing completed work to
[the repository](https://github.com/berkeleynerd/silver). GitHub Actions remains
**disabled repository-wide** by explicit instruction; validation runs locally.
Do not enable hosted CI as a follow-up. Verify remote `main` at handoff and record
the closing commit in the final response and local evidence.

The non-dot `silver/` and `tools/` transfer directories were removed from both
the tree and reachable Git history at the owner's request. Live `.silver/` and
`.tools/` were preserved. See the
[history rewrite record](docs/host-readiness.md#transfer-history-removal) for
commit mappings and recovery limits. Back up the ignored live directories
separately; a clone cannot recover them. Do not merge the old archive-bearing
history into the rewritten branch. Existing scratch, foreign-host artifacts and
safety stash `a48321d` remain preserved. Historical references are not instructions
to recover the removed archives.

For a clone that still has the old history, preserve the entire old checkout,
including `.git`, unpublished work, ignored `.silver/` and `.tools/`, and scratch
files. Use a fresh clone of the rewritten remote in a separate directory, then
port unpublished source changes separately. Do not merge or push the old branch
history into it. Restore live tools and evidence through staging, preserving
newer state, and follow the installation-move rules above before using them.

CLI memory is unavailable: no memory tool is exposed and the conventional recall
directories are absent. No CLI recall entry was updated. Checked-in
[session memory](docs/session-memory.md) is the durable handoff. The separate
Codex remote-control request remains unresolved because of API authentication;
this language task does not change authentication or restart its daemon.

## Remaining limits

The intermittent warm-state GNATprove `DOC_END` JSON-reader failure remains
unresolved. Retain a recurrence's logs and inputs; successful validation does not
establish repair, and no automatic retry is configured. Faithful complete GNAT
obligation generation, static elimination of the admitted assignment's satisfied
length check, pinned solver completion for guarded concatenation, and the
frontend/runtime/environment assumptions remain explicit in
[assurance](docs/assurance.md) and the [trusted boundary](docs/trusted-boundary.md).
No new external operation or trusted shortcut is introduced by this increment.
