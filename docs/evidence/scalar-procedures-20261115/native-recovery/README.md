# Native array-declaration recovery — 2026-11-15

This is focused recovery work within authorized #370. Complete native and
Lean/source assurance remain required; this packet does not promote procedure
support or close the issue.

## Retained diagnosis

The Nov 13 complete native checkpoint failed only
`silver_output_profile.adb:2340:32:VC_ASSERT`, the logical state equality in
`Array_Declaration_At`. Its retained generated session has one unresolved main
goal, `def'vc.412`; CVC5, Z3 and Alt-Ergo each reached the canonical 30-second
limit with a 1,000 MiB process limit. The backup has the same unresolved goal
and the identical shape file. No memory failure is reported for that obligation.
The original inputs and generated sessions remain in the
[Nov 13 packet](../../scalar-procedures-20261109/final-failures-20261113/README.md).

The earlier complete helper success reused a Z3 proof of this assertion,
reported as 73,959 normalized steps and zero fresh elapsed time. The retained
session inventory includes exactly one step-budget attempt per main prover
among the array helper's otherwise canonical attempts. Thus the earlier
requested 30-second command is not evidence of a fresh 30-second solve of this
obligation. [Assertion history](assertion-history.json) and
[attempt limits](earlier-array-attempt-limits.json) preserve these observations.
The older broader gate remains failed on its other obligations.

The runtime initializer is exactly the model expression after substituting
`Boolean_Array_Values_Model` and `Array_Values_Model` for their runtime helpers;
their complete contracts already supply both raw and logical equality.
[The comparison](initializer-comparison.json) records the normalized hashes.
[The exact generated assertion node](failed-assertion-gnat-node.json) shows
logical `=` against the model call's epsilon/guard term. No semantic defect or
unique reason for the previous timeouts has been established.

## Host recovery and current experiment

The new host is Linux ARM64 with 12 available CPUs and about 15.8 GiB RAM;
the earlier evidence is Linux x86_64. The initial focused run
`20261115T165617-180373f5f92a` stopped in translation with `Too many open files`,
before solver verification. Both Linux open-file limits were 1,048,576 and the
system-wide open-file table was far below its limit. An independent Lean launch
hit the same mounted-filesystem failure. This is retained as an unsuccessful
host attempt, not an assertion result.

The lead provided a dedicated Docker volume at
`/home/agent/silver-workspaces/recovery-volume/native`. The native tools were
copied into the isolated worktree and bootstrap regenerated installation paths.
The mounted packet and tools remain intact. The unchanged focused experiment
checks every line of the complete `Array_Declaration_At` declaration/body and
its direct `Declaration_At` caller, including runtime, contract and flow checks.
It uses all mode, all reports, warnings/checks as errors, level 2, all three
canonical provers and the unchanged 30-second timeout. Two managed workers
reserve headroom for the concurrent isolated Lean check; native RSS and host
available memory are sampled every ten seconds.

## Fresh complete-helper result: failed

Native-volume run `20261115T170136-e1c83ecc05db` exited **1** at 17:14:57 UTC
after 801.067 launcher seconds / 800.829 managed seconds. The complete
`Array_Declaration_At` has 56/57 proved proof records and two successful flow
records. The sole failure is the same assertion and generated goal; all three
canonical attempts again timed out at 30 seconds. Its 10-second counterexample
attempt also timed out. The run therefore remains failed.

The complete direct caller `Declaration_At` independently passed all 11 proof
and two flow records. Both selected entities are in `all` mode. The report has
494 successful flow records overall, no skipped proof/flow and no pragma-assume
entries. All 2,606 prepared input hashes and 12 tool identities matched at the
terminal check. Sampled native process RSS peaked at 2,559,392 KiB, and the
smallest sampled host available memory was 5,669,424 KiB. These are process-RSS
and host-headroom observations, not a hard memory cap.

No source, contract, declared domain, proof obligation or compiler/application
policy changed for this baseline. A diagnostic checkpoint in the managed ledger
records the failed assertion, retained evidence and next hypothesis. The
follow-up experiment binds the same model call once as a `Ghost => Static`
constant before the assertion. Its separately retained result follows below.
The existing successful caller can be retained only while its complete source
and the helper's exported contract remain unchanged. Complete assurance and the
actual-source wrapper proof remain mandatory.

## Ghost model binding: complete helper passed

`20261115T171701-f22f9fbad388` exited **0** at 17:21:57 UTC after 296.434
launcher seconds. It selected the complete `Array_Declaration_At` with
`--limit-subp=silver_output_profile.adb:2251`, retaining the same canonical
all/all, level 2, three-prover, 30-second policy and two-worker reservation.
All **56 proof and two flow records** passed; mode is `all`, progress is
`PROGRESS_PROOF`, stop reason is `STOP_REASON_NONE`, and skip/assume lists are
empty. All 2,606 prepared input and 12 tool hashes matched at completion.

The new constant evaluates exactly `Array_Declaration_Model (Text, State,
Arguments)` at assertion level `Static`. The unchanged assertion and equality
lemma use that constant. The runtime initializer, exported raw-model contract
and full precondition are unchanged. Both the model and wrapper have the same
precondition, including permitted zero-position states. The new model-call
precondition is proved. SPARK's predefined `Static` level is always ignored in
runtime execution, independently of compiler switches or assertion policy.

All 53 proof identities preceding the ghost tail remain unchanged. Two identical
ghost-model calls and their two precondition checks become one constant
initialization with one precondition check. The logical equality assertion and
lemma precondition remain and pass; no obligation was suppressed. The generated
assertion now compares `Result` directly with `Model_State`, without the previous
epsilon term. Z3 proved it in 0.418491 seconds / 3,838 normalized steps; CVC5
proved it in 4.40634 seconds / 26,338 steps. Alt-Ergo's timeout remains a failed
solver attempt on an otherwise discharged required obligation.

The run reused the canonical-only baseline session. Its retained XML still
contains obsolete or unused earlier attempts, including the old counterexample
timeout; the current main goal is proved and every current report check passed.
This is incremental focused success, not a new cold measurement or complete
assurance checkpoint. Sampled native process RSS peaked at 1,975,904 KiB, with
at least 13,257,056 KiB host available memory in the retained samples.

The baseline's complete `Declaration_At` success remains applicable: its entire
declaration/body, the callee's exported contract, and the runtime initializer
are byte-identical, with matching fragment hashes. No other native input changed.
Combining these scopes gives **67 proved proof records and four flow records
across two complete entities**; the baseline run itself remains failed.

`ComposeArrayDeclarationSource.lean` now renders the exact ghost constant and
its uses. Its universal runtime-erasure equation is unchanged; the comments
identify the checked Static aspects and unchanged full-domain call precondition.
The existing whole-source annotation-policy check passed. Independent review
and focused Lean checking are still pending at this evidence snapshot.
The smallest targets are `Silver.ComposeArrayDeclarationSource` for the wrapper,
`Silver.ComposeHelperSourceCandidate` for exact helper/header reading after the
reviewed source binding is refreshed, and `Silver.ComposeSourceChecks` for
transport to authoritative source after the output certificate is updated.
No source pin or certificate was changed in this native repair. The lead owns
their reviewed integration and the mandatory complete native/Lean checkpoint.

## Retention

| Archive | Scope |
| --- | --- |
| `setup-and-mounted-failure.tar.gz` | Relocation/bootstrap logs; original mounted failure command, actual exit, reports, managed events and all 2,606 matching prepared inputs |
| `fresh-baseline-failure.tar.gz` | Native-volume command, exit, resource samples, reports, both selected generated helpers/sessions, managed diagnostic, terminal verification and all 2,606 matching prepared inputs |
| `model-constant-success.tar.gz` | Exact source delta, complete helper reports/generated session, caller-continuity and obligation mappings, terminal input/tool checks, source-review facts, commands/resources and all 2,606 matching prepared native inputs |

The archives contain source/configuration inputs and tool identities, not copied
tool binaries or a proof cache. `retained-files.json` records archive hashes,
sizes and member counts; all packed file bytes were compared with their retained
source files. The mounted originals remain in the original native worktree.
The native-volume originals remain under `tmp/native-recovery-20261115/` in
the dedicated native worktree. Historical evidence keeps its original platform,
settings and outcome; no completed provenance or complete-assurance manifest is
claimed for either failed run.
