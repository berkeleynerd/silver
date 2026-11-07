# Boolean-array evidence inventory — 2026-11-06

**Preparation snapshot; the complete integrated delivery checkpoint is pending.**
This inventory supports [#297](https://github.com/berkeleynerd/silver/issues/297)
and the [capability record](../../boolean-arrays.md). It records existing local
cache provenance and focused results; it does not claim final native assurance,
complete source correspondence, sample execution or feature delivery.

Paths below are relative to the shared repository root unless stated otherwise.
The integration checkout is `tmp/boolean-arrays`; the native installation stays
at `tmp/empty-loop-repair`. All inspected results are native Linux x86_64.
The local managed registry is
`.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/`; each run has
`runs/<run-id>/events.jsonl`. Successful Lean runs retain their own
`lean-focused-evidence.json` and `lean-focused.log`; failed runs retain logs
under `reports/0/lean-focused.log`. The helper-memory failure/success records
linked below are copied into this packet; other local records remain at their
original managed paths.

## Ordinary cache reuse and transfers

Each feature tree uses its own `.silver/linux-x86_64/proof/.lake` workspace.
The root, semantic, source and String trees' Lean tool links currently resolve
to `tmp/source-tree-structural-guards/.tools/linux-x86_64/lean`. Successful
focused evidence identifies Lean 4.34.1. This observed common tool location is
separate from the history of copied proof objects.

| Route | What the retained record establishes | Record and limits |
| --- | --- | --- |
| Earlier #314 workspace → feature caches | The semantic handoff says the lead seeded complete Lake/private/server sidecars from an idle #314 workspace. | `tmp/boolean-arrays-semantics/tmp/SEMANTICS-HANDOFF.md`, Resource/runs. The original seed command, exact source/destination inventories and transfer time were not located in this investigation. The current common Lean tool link alone does not establish these particulars. |
| Integration → semantic tree, 18:44 checkpoint | Both caches were idle; the resolved Lean binary and seven source modules matched. Complete 16-artifact sets were copied for each module. | Same semantic handoff, Update 18:44. Modules: `ComposeExpressions`, `ComposeArrayExpressions`, `ComposeContracts`, `ComposeModelCalls`, `ComposeBooleanArrayElaboration`, `ComposeArrayStore`, `ComposeBooleanInitializerNative`. No separate transfer manifest was located; the handoff is the available provenance. |
| Semantic → String trace tree | The String handoff records a root-confirmed idle source and 485 exact-source modules / 7,760 complete artifacts, from source terminal run `20261106T190506-21a2155d83a1`. | `tmp/boolean-arrays-string-traces/tmp/cache-import-semantics.json` records the absolute source workspace, terminal run, each module/source SHA-256 and each artifact path/SHA-256. The destination is the String tree's own proof workspace. Its handoff records ordinary managed rebuilds when copied traces retained former absolute source paths, and no trace rewriting. |
| Source → integration tree, 20:02 UTC | Two exact-source modules, `ScalarExpressionBodyCertificate` and `ScalarExpressionSourceChecks`, were copied with all 32 artifact files from idle workspaces. | `tmp/boolean-arrays/tmp/cache-import-source.json` records UTC, absolute source/destination, source terminal run `20261106T194029-667da8c0974e`, module/source hashes and artifact paths/hashes/sizes. The lead reports backups preserved. Lake dependency validation and the fresh complete audit remain pending. |

The 485-module inventory describes the transferred cache, not 485 modules freshly
audited by the source terminal run: that run's focused import scope was 144
modules. Copied `.olean`, private/server sidecars, traces and IR preserve ordinary
local work. They are not authenticated artifacts or an independent kernel replay.
The existing runner checks cached kernel-bypass policy, synchronizes captured
sources, lets Lake validate dependencies/rebuild stale objects, and performs a
fresh axiom audit of the selected import scope. Local cache and trace integrity
remain the existing [trusted-boundary premise](../../trusted-boundary.md).
A successful copy or matching inventory does not replace those checks.

No complete inventory of all later root/source cache transfers was located.
Existing handoffs establish the routes above; undocumented transfers must not be
inferred from a fast build or from matching tool links. Final evidence should
identify any additional actual transfer and its existing record if one is used.

## Successful focused Lean checks

These entries were checked against each run's terminal event, focused evidence
and audit log. All are incremental (`clean_build: false`), with fresh selected
scope axiom audits and no separate kernel replay. Their foundations are
`propext`, `Classical.choice` and `Quot.sound`. Module/declaration counts describe
overlapping import scopes and must not be summed. Build/audit columns are phase
seconds, not whole managed elapsed time. Exact targets, tools and input digest
are retained in each run's focused evidence.

| Run ID | Selected scope | Modules / declarations | Build / audit s |
| --- | --- | --- | --- |
| `20261106T174230-0d6e0c1ee35c` | Boolean array foundation | 16 / 1,758 | 13.596 / 8.279 |
| `20261106T174643-4d3ab3f8f38d` | Array bindings | 21 / 2,349 | 10.373 / 6.870 |
| `20261106T175345-aa343ea73fac` | Boolean assignments, declarations and freezing | 55 / 6,484 | 7.319 / 7.422 |
| `20261106T175411-602afbfa491f` | Compose admission and array expressions | 72 / 11,436 | 83.565 / 10.236 |
| `20261106T180337-79d0f3ff7c29` | Typed array-binding reads | 22 / 2,407 | 21.520 / 17.698 |
| `20261106T181009-b9ac450aa269` | Scalar expression admission | 33 / 3,698 | 18.967 / 7.230 |
| `20261106T182220-6d9e0a5f8f8f` | Aggregate snapshots and typed bindings | 40 / 5,516 | 10.325 / 7.220 |
| `20261106T182828-812595b7b7ce` | Condition soundness, uniqueness and validity | 84 / 9,722 | 14.631 / 7.643 |
| `20261106T185405-587bfd498383` | Native condition helpers | 112 / 16,158 | 13.744 / 8.214 |
| `20261106T185635-e94a490c92fe` | Raw Boolean aggregate trace | 131 / 17,386 | 25.509 / 21.359 |
| `20261106T190506-21a2155d83a1` | Mixed Boolean declaration region trace | 144 / 17,704 | 12.982 / 14.370 |
| `20261106T192051-18f2ef0343cd` | Body meaning and flow validity | 140 / 14,750 | 35.285 / 8.614 |
| `20261106T192233-4a921a21291a` | Compose evaluation, Boolean aggregate source and checks | 149 / 23,089 | 43.088 / 8.786 |
| `20261106T193157-2fea6bcc3959` | Boolean header and Sequence model | 254 / 29,129 | 536.943 / 10.230 |
| `20261106T194029-667da8c0974e` | Native/body libraries, loop, scalar source bridge and grammar | 314 / 46,619 | 42.974 / 10.055 |
| `20261106T194718-c5f570887ac0` | Actual String assurance | 203 / 21,418 | 53.174 / 7.724 |
| `20261106T195837-5846f84d4aa8` | Boolean-array body source shape | 127 / 18,432 | 18.493 / 7.524 |

The source and semantic handoffs distinguish these audit scopes from Lake build
job counts. For example, the native-helper run had 113 build jobs but 112 audited
modules; the native-library run had 320 jobs but 314 audited modules.

## Failed runs with reusable completed dependency builds

A failed target does not invalidate every successfully built dependency; it also
does not turn the containing run into a successful checkpoint. The following
retained logs identify useful work. Reuse remains subject to ordinary source,
tool and dependency validation in subsequent managed runs.

| Run ID and overall outcome | Completed dependency work visible in its retained log |
| --- | --- |
| `20261106T184418-114b21f667cc`, failed array-model proof | String equations 168 s, String declaration equation 270 s, scalar denotations 296 s. These module timings overlap; they are not additive wall time. |
| `20261106T185555-78de4c495efe`, failed Basic readings/array recursion | Scalar body certificate 747 s and scalar source checks 100 s completed. The source handoff explicitly retains their objects for later runs. |
| `20261106T185637-6e4ca1ad1d36`, failed array equations | 63 dependency module builds completed, including array model and Boolean initializer libraries. |
| `20261106T190942-1022caa80b98`, failed array-equation rewriting | 32 dependency builds completed, including Boolean initializer libraries. |
| `20261106T191719-6625601a3aea`, failed evaluation migration | Compose equations completed in 207 s; later evaluation repair passed in `192233`. |
| `20261106T192317-17af08ff29ef`, failed Basic equations | 99 dependency builds completed, including 145 s scalar source checks and 249 s Compose equations. |
| `20261106T192831-24da53dccda7`, failed Header/Flow prerequisites | 193 dependency builds completed in the String tree; its handoff records reuse by the final Actual String assurance run. |

The String follow-ups `20261106T194252-f36360b4c684` and
`20261106T194354-238f0d24728f` also failed, respectively on an unnecessary
`simpa` and missing distinct Boolean-array-write coverage. The source/String
owners repaired that coverage before the successful `194718` audit.
`20261106T174931-ce072d60f7a0` reached build and axiom-audit success but failed
final input stability; it is not a successful checkpoint. The interrupted
`20261106T191028-595c8eddd6ba` captured conflicting prerequisite drafts; its
partial builds likewise carry no successful audit claim.

## Native work retained at the original installation

The handoff at `tmp/boolean-arrays-native/tmp/RESUME-boolean-arrays-native.md`
identifies the editing tree and original-path validation installation separately. The latter
preserves `compiler/obj/review-final/gnatprove` and
`.silver/linux-x86_64/proof-cache/gnatprove`; exploratory repairs use
`compiler/obj/explore/boolean-array-repairs` and the separate
`tmp/boolean-array-producer/repair-cache`, all relative to that installation's
host artifacts or worktree as appropriate.

The original build `20261106T173931-2f5300a7d291` passed. Exploratory
`20261106T174020-4a67423374dd` failed because its cache directory was absent;
`20261106T174113-7f175d61085a` was interrupted after legacy helpers dominated.
Retained incremental run `20261106T174859-3c4e45f871bc` was interrupted on lead
coordination after about 6,014 s, with old snapshot `4091a00a39`. It retained
successful helper sessions but also two diagnosed failures: masked name bounds
and the declaration's Ada record-equality postcondition. Neither this run nor
its stale aggregate reports constitute final native audit evidence.

On repaired validation snapshot `a224e481b2`, the handoff and successful managed
terminal events identify these bounded checks:

| Run ID | Scoped native result reported by the native handoff |
| --- | --- |
| `20261106T193001-49b33d4345e5` | Boolean-array name guard: 21 checks |
| `20261106T193211-8660851a1154` | Static parser equality bridge: 2 checks |
| `20261106T193707-8db6f1a92157` | Exact declaration postcondition: 4 checks; explicit `VC_POSTCONDITION` at line 2100 |
| `20261106T193934-65a47892c441` | Executable Boolean initializer: 11 checks |

The earlier successful `20261106T193504-5749d3bf8b59` proved three model-call
preconditions, not the intended postcondition; line-only trial
`20261106T193310-5815fc79b0fe` was interrupted. The check counts above are native
handoff observations, not a new complete report audit by this documentation
subthread. The native aggregate run `20261106T194221-0a4c2a4941b8` had no terminal
event in the inspected snapshot; its final disposition belongs in the delivery
record. Run-local `native.log`, `exploratory-evidence` and retained prior reports
preserve the scoped commands and outcomes.

## Remaining integrated checkpoint

The lead still must record complete final native Bronze/Silver obligation and
report/provenance audits, the exact-source build, sample/regression results,
complete Lean/source/module/axiom checks and independent integration review.
Focused results above retain their own earlier input scopes. Cheap source-header
preflight at `tmp/boolean-arrays-source/tmp/source-header-preflight.json`
records a root-plus-source-overlay inventory of 654 reachable modules, zero
missing/orphan modules and exact 53,290-token
source-pin parity for output hash `d82f6880924196f6fccc2077ed86b71c6a31683d72b8e2a935d494b7d62296f4`;
it explicitly is not a kernel or universal source proof. Source pin agreement
and the cache inventory cannot substitute for complete correspondence.

Managed source-policy preflight `20261106T200200-7ef07483368b` finished failed
on stale generated output/scalar-body/array-spec certificates. Its separate
native kernel-control method passed. Commit `4c76637b6c` refreshed the three
certificates and eight output line modules. Rerun
`20261106T200420-7eed53372413` passed all 15 source-policy methods, including
certificate parity, in 7.675 s. This is not complete source correspondence.

The integrated helper run `20261106T200514-093a13a9b4dc` then failed two kernel
decisions at the shared `all_goals` command in `candidate_boolean_array_helpers`
at the 24,576 MiB per-process memory threshold. The build took 2,661.426 s;
`ReviewedOutputShape` built successfully in 191 s, and the failed helper module
reported 2,463 s. The [failed log](helper-memory/failed-focused.log),
[events](helper-memory/events.jsonl) and [diagnostic](helper-memory/diagnostic.json)
are retained. The two failing field identities were not printed by that shared
command. The next check isolates named Boolean-array fields and bridges the
long expected-token headers through kernel-checked literal equalities, keeping
the public statements and authoritative source route unchanged. The source
candidate remains pending until that repair and the full checkpoint pass.

## Helper-memory repair and scoped review

Named-field isolation commit `f060bdd5628361bf9d2247c63a41781699a4bd32`
retained the public helper statement and delegated its complete requirements to
`BooleanArraySource.candidate_checked`. Run `20261106T205410-9ce5cebd89e1`
then failed after a 1,548.251 s build: named `model_spec_tokens` and
`executable_spec_tokens` old-header lexer bridges exhausted the 24,576 MiB
per-process kernel threshold; `body_source` also failed with reduction stuck at
`Nat.repr` before the required representation import. The
[named-field failed log](helper-memory/failed-named-field-check.log) is retained.
This was a failed diagnostic, not successful assurance.

Final repair `8102cd38980ef112bbeed69d8e082d9626f96bc9` replaces only the
`BooleanArraySource.modelSpec` and `executableSpec` data right-hand sides with
exact 247/289-token literals, removes the expensive old-string lexer bridges,
and restores `import all Init.Data.Repr` in the candidate leaf. It follows the
existing direct-literal precedent `24452b335af757f6a0b5986288a42d3b47a92078`.
Native source, semantic definitions, all six `Checked` fields, actual-source
checks and authoritative source transport remain unchanged.

| Run ID | Actual result and retained records |
| --- | --- |
| `20261106T212312-4dc45d97ebe4` | Successful focused target `Silver.ComposeBooleanArraySourceCandidate`: 237.105 s build, new leaf 225 s; 11.202 s fresh axiom audit, 79 modules / 12,470 declarations, only `propext`, `Classical.choice`, `Quot.sound`. [Manifest](helper-memory/literal-repair-lean-focused-evidence.json), [log](helper-memory/literal-repair-lean-focused.log). |
| `20261106T213048-2ad7d6083cbb` | Combined helper plus eight `OutputBodyLines` modules passed: 94 modules / 30,296 declarations, 2,856.052 s build / 8.753 s fresh audit, approved three foundations. [Manifest](helper-memory/combined-lean-focused-evidence.json), [log](helper-memory/combined-lean-focused.log), [762-input applicability](helper-memory/combined-input-applicability.json). This still excludes final authoritative-source reconstruction and the complete project audit. |

The successful leaf run was incremental (`clean_build: false`), Linux x86_64,
Lean 4.34.1, eight workers/eight threads per process, 12 available CPUs and
24,576 MiB per process. It has no independent kernel replay or peak-memory
measurement. The retained manifest reports 269.963 s managed elapsed time;
phase timings are not whole-team elapsed time. Its import scope does not include
the combined helper or final authoritative-source endpoints.

The [independent repair review](../../reviews/review-boolean-array-header-memory-20261106.md)
found no scoped finding. Its target is exactly `8102cd3898`, including named
isolation `f060bdd562`, with original requirements compared against
`d3aafa4bafd6d94179eb74d883102f953b09afd7`. The reviewer inspected the immutable
successful ledger and confirmed all 762 captured input hashes match the target
workspace; this capture count is distinct from the 79-module audit scope.
[Input inventory](helper-memory/helper-memory-inputs.json) retains exact inspected
source/evidence hashes. Independent restricted-ASCII header extraction confirms
that both literals equal the original expected strings and complete native
specification headers, and that all six `Checked` fields remain byte-identical:
[comparison](helper-memory/helper-memory-header-equality.json),
[extraction script](helper-memory/check_header_literals.py). This extraction
supplements the kernel checks and is not itself a source proof. The review
reuses the byte-identical success files above.

| Round | Selected settings and intended result | Result, review disposition and available measurements |
| --- | --- | --- |
| Named isolation and literal repair | Bounded implementation: GPT-6.1 Sol / Extra High; identify the failing fields while preserving all requirements | Failed named bridge run retained; exact literal repair passed the focused leaf. Lean phase timings are above; model token/cost measurements and independent runtime setting confirmation are unavailable. |
| Independent critical review | GPT-6 Astra / Extra High, selected launch/handoff confirmed; challenge requirement preservation, exact tokens and evidence applicability | No scoped finding. First measured UTC 21:30:49 to closing 21:33:09 gives a 140 s lower bound; initial diff retrieval preceded that interval. Runtime settings and token/cost measurements unavailable. No proof/build/test/application run launched by the reviewer. |
| Evidence checkpoint documentation | GPT-6.1 Sol / High, selected launch; preserve failed and successful evidence plus the scoped review | Retained the packet and review, corrected local links and recorded active combined/native work without a completion claim. Only cheap documentation checks; no source/proof/cache edits. Runtime confirmation and token/cost measurements unavailable. |

## Active native validation and remaining delivery

Complete native run `20261106T201636-d09ed16a345c` used the original
installation with four workers and the canonical retained cache. Its 143
tracked proof inputs (131 source files, nine Python scripts and three project
or configuration files) matched integration `831f9b348a` and remain unchanged
by the integrated proof-only header repair. It was deliberately interrupted at
21:50:04 UTC after 5,605.352 s, once the unresolved `VC_ASSERT` at
`silver_output_profile.adb:2178:32` was identified. Completed sessions, reports,
cache entries and the exact diagnostic were retained; no full audit success is
claimed. The earlier focused postcondition at line 2100 passed separately and
did not prove this preceding assertion.

The native diagnostic concerns `Same_Parser_State` between the executable
array-declaration result and its model. Fieldwise candidate `d05d2bb379` failed
run `20261106T215058-ebdafecd6a1b` on equality of their positions. Direct inline
candidate `af55339df7` was rejected before proof in
`20261106T220352-f4b0e62d076e`: the pinned tool does not allow that annotation
with the existing conjunctive postcondition. Separate ghost expansion candidate
`13026ad590` retained all existing bodies/contracts, but its isolated bridge
failed in `20261106T221315-d935921d7570`. None of these candidates is integrated.
The original-source 120-second solver-budget experiment subsequently failed;
the higher-memory trial was interrupted after a cached Z3 out-of-memory result
made that comparison inconclusive. The bounded repair and its focused evidence
are recorded below. No failed assertion is assumed as completed assurance, and
no contract or language rule is weakened.

The combined Lean checkpoint above used four Lake workers and eight threads per
process at 24,576 MiB per process, sharing the 32 GiB host with the native work.
All eight output line modules and the combined helper built successfully; the
helper reported 669 s. The complete reconstruction, remaining source candidates
and whole-project audit remain outstanding. That combined run's governed inputs
are `8102cd3898`; the later shared type-word repair changes its source inputs as
recorded below.

Documentation preparation selected GPT-6.1 Sol / High; runtime confirmation and
token/cost measurements are unavailable. This subthread read the root, source,
semantic and String checkpoint files, the native handoff, the transfer inventory,
and existing managed events/evidence/logs. It ran no native, Lean or test command
and changed no proof/cache inputs. The conditional delivery-edit handoff is
preserved locally at `tmp/boolean-arrays/tmp/DELIVERY-FINALIZATION-20261106.md`.

## Shared Boolean type-word repair

Independent inspection of the exact native obligation identified distinct
solver arrays for the model's and executable's identical `"boolean"` literals.
Native repair `b47bee6f2b`, integrated as `a1cc4a53df`, introduces one shared
constant and replaces those two uses. All existing contracts, the original
logical equality assertion and its equality bridge remain. The corresponding
Lean constructor and checked constant declaration are integrated as
`27fcd2e77b`; pin/certificate refresh `1b7140d90b` completes the source update.
The [independent review](../../reviews/review-boolean-array-type-word-20261106.md)
found no required correction and independently reproduced the pin and generated
certificates. This is reviewed preparation, not complete source assurance.

| Check | Result and scope |
| --- | --- |
| Native `20261106T224718-9374c3fb5301` | The original assertion at line 2179 passed under the ordinary 30-second/1000-MiB settings; three focused checks, 45.328 s. [Result](shared-type-word/focused-assertion-result.json). Broader native/model checks and complete audit remain required. |
| Lean `20261106T225112-b305e0e70621` | `ComposeArrayEquations` and `ComposeEvaluation` passed: 151 modules / 21,354 declarations, 334.635 s build and 8.359 s fresh audit, exactly the approved foundations. [Manifest](shared-type-word/lean-focused-evidence.json), [log](shared-type-word/lean-focused.log). This source-independent run captured the earlier Ada bytes; it does not establish correspondence to the new constant. |
| Cache transfer | From the idle successful focused workspace into the idle integration workspace: 23 rebuilt module families, 360 artifact files, 81 copied and 279 already identical. All 151 audited module sources matched integration; complete private/server/hash/trace families were retained without rewriting traces. [Inventory](shared-type-word/cache-import-fixed-word.json). Lake dependency checking and the complete fresh audit remain mandatory. |
| Source policy `20261106T225857-e507df7ab57e` | All 16 tests passed in 93.985 s, including exact certificate regeneration and native kernel rejection controls. [Result](shared-type-word/source-policy-tests.json), [log](shared-type-word/source-policy-tests.log). This is not the complete project audit. |
| Complete declaration `20261106T224836-6338c8d07171` | All 47 checks passed together: 45 proof and two flow records, 1,032.688 s. This includes the original assertion, equality-bridge precondition and both postcondition modes. [Result](shared-type-word/whole-declaration-result.json). |
| Complete model `20261106T230639-d72d8edd5e80` | All 42 checks passed: 40 proof and two flow records, 910.136 s. [Result](shared-type-word/complete-model-result.json). Both scoped runs use the normal 30-second/1000-MiB proof settings; their scopes overlap and their counts are not a full-compiler total. |

The [mechanical refresh](shared-type-word/refresh.json) changes only line buckets
0, 1 and 6, their reconstruction and the complete output pin (53,290 to 53,297
tokens). The native body hash is
`1686b0b61da8c684ce185995621fb08bc5a6932893d2cc859a82ced9922ce4e8`.
The [failed 120-second trial](shared-type-word/original-assertion-timeout120-memory1000.json)
and [interrupted higher-memory trial](shared-type-word/original-assertion-timeout120-memory4096-interruption.json)
retain their actual outcomes. Implementation selected GPT-6.1 Sol / Extra High;
critical review selected GPT-6 Astra / Extra High. Runtime confirmation and
token/cost measurements are unavailable.

The installed native validation tree then switched, at its original path, to
integration `943a97c8cf`; all 144 selected source/script/project/catalogue inputs
matched the feature tree and Git target, with no extra source or script files:
[comparison](shared-type-word/native-final-inputs.json). An ordinary cache
transfer under managed leases copied 3,744 previously absent exact-key entries
from the idle repair cache into the idle canonical cache; no existing entry was
overwritten, and no response, trace or path was rewritten. The unchanged
GNATprove cache matching decides whether each entry applies. The
[transfer inventory](shared-type-word/native-cache-transfer.json.gz) records its
paths and contents; managed run `20261106T232457-ecc6160ab56c` passed.

Complete native run `20261106T232644-673fc5a9c06b` and complete Lean run
`20261106T230229-b9a860723df5` are active at this checkpoint. A separate installed
workspace rebuilt the same source in `20261106T230245-a19eaca75889` and is running
the full 612-test inventory in `20261106T230401-5dde322e2782`. These active runs
are not successful assurance evidence yet. Final regression applicability,
Rosetta rendering, independent delivery confirmation and publication remain
pending.


## Complete-checkpoint resource recovery — 2026-11-07

Complete Lean run `20261106T230229-b9a860723df5` failed its
`OutputBodyCertificate` build with exit 137 after 2,556 seconds, including
recorded suspension. Kernel evidence identifies a global out-of-memory kill at
00:08:27 UTC; this is not a reported proof/type error. The reconstruction and
several source candidates overlapped on the 32 GiB host. Pausing stopped growth
but retained their heaps, and a transient garbage-collection low did not justify
resuming concurrent dense checks. The original failed run and completed module
objects are preserved. The [resource evidence directory](final-lean/) retains
the kernel observation, input comparison and process/suspension samples.

The run finished failed after a 9,229.662 s build, preserving 175 successful
module builds. `PredicateNativeShapeCandidate` was deliberately terminated to
recover RAM; this is distinct from the reconstruction's OOM kill. A third failure
exposed omitted Boolean-array assignment cases in `PredicateFlags`. Repair
`ba23d2167c` also updates its direct consumer `PredicateSelectors`, as the
[independent flag review](../../reviews/review-boolean-array-flags-20261107.md)
required. Both focused builds and fresh audits passed. The complete cached
retry serializes module builds with automatic 12-thread processes and the
unchanged 24,576 MiB threshold. Native verification continues on unchanged
inputs. No complete checkpoint is claimed by these focused checks.

## Final regression coverage and flag-repair applicability

The [regression packet](final-regressions/README.md) preserves full run
`20261106T230401-5dde322e2782` as failed: 612 executions, representing 603
distinct methods plus nine imported duplicates, with 602 passes, eight skips,
one catalogue assertion failure and one sample compilation deadline error.
Only two expectation literals changed in `689aef86bf`; the actual catalogue
already used the specified Integer-array terminology. The targeted catalogue
rerun passed. The unchanged complete manifest method subsequently passed all
61 sources and 117 execution cases at the same 120-second fixture deadline.
Seven native Lean controls passed in the 55-test fixture rerun; the eighth has
applicable retained certificate-control success. The dynamic-expression method's
two successful cases are retained without a repeat.

The [independent applicability review](../../reviews/review-boolean-arrays-regression-applicability-20261107.md)
accounts for all 603 distinct methods: 593 original passes, the catalogue and
manifest repairs, seven fresh controls and one retained certificate control.
The subsequent flag review covers the two proof-file changes separately: 800
of the original 802 selected certificate-fixture inputs now match, while the
two changed modules are outside its actual dependency closure. Native/sample
inputs and all relevant proof-reader projections remain unchanged. This is
reviewed result reuse, not a passing full-suite run. Final Rosetta metadata
changes still require the three-method renderer rerun and applicability follow-up.

## Equation-field and primary-branch repairs — 2026-11-07

The [serial retry](final-lean-retry/README.md) successfully rebuilt the complete
source reconstruction (2,817 s) and seven dependent modules. It then exposed
positional proof bullets in `ComposeSourceBridge` being assigned in the updated
structure's declaration order. The reviewed repair attaches the unchanged
proof bodies to their named fields. [Focused run `032925`](equation-fields/README.md)
passes 318 modules / 92,000 declarations with the approved foundations; it
precedes the native source change below and is not final complete assurance.

The ongoing original native audit `20261106T232644-673fc5a9c06b` has a completed
`Read_Primary_Into` session with one unresolved final model-equality postcondition.
The [failure and focused repair packet](native-primary-failure/README.md) retains
the exact task and normal-limit timeouts. A one-line Static assertion in the new
Boolean-array branch passes its assertion/model-call precondition in `031832`
and the original postcondition in `032305`. The
[independent review](../../reviews/review-boolean-array-primary-cut-20261107.md)
confirms unchanged runtime behavior, model, domains and complete postcondition.
The old canonical audit continues collecting remaining diagnostics on its
original inputs; it is not a final successful audit of the repaired source.

Because the native source will change, the coordinator explicitly interrupted
the older Lean retry after its known field-order failure and snapshot retention.
The pause, resume and interruption are recorded separately; all completed
objects remain and no stopped process or workspace lease was left behind.
The [integration packet](primary-cut-integration/README.md) records the actual
source/pin/reconstruction refresh and successful rerun of both affected
source-policy methods. All eight line modules remain byte-identical. Native
whole-helper/final audit and final build remain required, followed by the
complete Lean/source checkpoint and final Rosetta validation.

After the separately required final Rosetta rerun, reviewed regression coverage
will be 588 retained original methods + one catalogue repair + one manifest
repair + seven native fixtures + one retained certificate control + two refreshed
source-policy methods + three final Rosetta methods = 603 distinct methods.
Final runtime-input/build and metadata applicability still require confirmation.
No prior failed/interrupted run is relabelled successful.

## Complete Primary helper and Relation diagnosis — 2026-11-07

The [complete Primary helper packet](native-primary-failure/complete-helper/record.json)
records successful run `20261107T032921-a797df49b155`: all 87 checks
(two flow and 85 proof) passed in 1,271.345 seconds at the normal proof limits.
This removes the line filter used in the earlier two focused checks. It covers
the integrated Primary assertion on native body `c1ce845a59`, not the complete
compiler or the later Relation candidate.

The original full audit continues on unchanged old source `1686b0b61d`.
Its completed `Read_Relation_Into` session has one unresolved false-flow
equality assertion, mapped from the retained task and session shapes to
`3945:18` (`GP_Check1952`, `def'vc.368`). The
[dated Relation packet](native-primary-failure/relation-completed-helper/README.md)
retains that diagnostic without waiting for the buffered driver output. The
current source has the same Relation body, with a one-line offset from the
Primary repair. Review found no executable or model mismatch and proposed one
local Static equality assertion after the nonzero-target false-flow assignment.
The isolated candidate must prove its new assertion and call precondition,
then the retained original assertion and complete affected helper. These are
pending checks; no candidate or full-audit success is inferred from the diagnosis.

The two new evidence subdirectories are dated additions. The original
`native-primary-failure` checkpoint and its inventoried files remain unchanged.
Final native verification/build and complete Lean/source assurance remain
outstanding; no Lean process is paused or running at this checkpoint.

The proposed Relation cut subsequently passed both focused checks at normal
configured limits: `20261107T040114-c0bc2424d7bc` covers the new assertion and
its call precondition, and `20261107T040331-451c30667872` covers the original
merged assertion and its call precondition. The
[independent review](../../reviews/review-boolean-array-relation-cut-20261107.md)
confirms the exact candidate and both retained results. The
[integration packet](relation-cut-integration/README.md) records the source,
full-pin, reconstruction and single-bucket refresh, plus successful run
`20261107T040620-63bb90cecba1` of the two affected source-policy methods.
Complete Relation helper run `20261107T040619-48e6ccbe10c9` is active; the
original full audit continues collecting diagnostics on its unchanged source.
Final complete native/build/Lean assurance remains outstanding.

Complete Relation helper run `20261107T040619-48e6ccbe10c9` subsequently passed
all 152 checks (150 proof and two flow) in 2,625.834 seconds at the same normal
configured limits. The [complete-helper packet](native-primary-failure/relation-complete-helper/record.json)
retains exact candidate `7d39745bd9`, all helper reports/tasks/session, inputs,
tools and managed outcome. This includes the original postcondition and both
local/merged assertions. The original full audit is still running on its frozen
source. Both known failures now have complete helper repair evidence; final
complete native verification/build and Lean/source assurance remain required.
