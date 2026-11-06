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
under `reports/0/lean-focused.log`. These local records have not been copied
into this checked-in packet by this documentation task.

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

Complete native run `20261106T201636-d09ed16a345c` is active on the original
installation with four workers and the canonical retained cache. Its 143
tracked proof inputs (131 source files, nine Python scripts and three project
or configuration files) match integration `831f9b348a`. It is separate from
the proof-only helper repair and has no final audit result yet.

Documentation preparation selected GPT-6.1 Sol / High; runtime confirmation and
token/cost measurements are unavailable. This subthread read the root, source,
semantic and String checkpoint files, the native handoff, the transfer inventory,
and existing managed events/evidence/logs. It ran no native, Lean or test command
and changed no proof/cache inputs. The conditional delivery-edit handoff is
preserved locally at `tmp/boolean-arrays/tmp/DELIVERY-FINALIZATION-20261106.md`.
