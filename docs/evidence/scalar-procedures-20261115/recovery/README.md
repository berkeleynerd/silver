# Reduced-host recovery — 2026-11-15

The owner resumed #370/#29 through complete validation, critical review and
reviewable publication. Authorization is recorded on main in `903dac970`.
The published starting point is `32895f4827`; the
[November 13 failure packet](../../scalar-procedures-20261109/final-failures-20261113/README.md)
retains the exact implementation, native assertion failure and Lean memory
failure. Those failed complete checks remain failed.

## Workspace and evidence recovery

The current host is Linux ARM64 with twelve available CPUs and approximately
15.8 GiB RAM. Original Linux x86_64 workspaces and binary proof objects are
absent here. The committed input/report/session packets are retained; their
presence is historical evidence, not a fresh ARM64 result. `host.json` records
this observation and the selected delegated models/efforts. Live lead settings
and whole-team token/cost measurements are not independently exposed.

Isolated worktrees initially restored under the mounted repository encountered
`Too many open files` in both GNAT translation and Lean/Lake imports. Linux's
per-process descriptor limit is 1,048,576; the Lean investigation isolated an
approximately 9,832-handle limit on the mounted filesystem, while the same
probe exceeded 12,000 handles on native storage. The failed launches are kept
in the respective investigation packets. They did not test the proof goals.

A dedicated Docker volume, `silver-recovery-370-20261115`, supplies native ext4
storage, bound at `/home/agent/silver-workspaces/recovery-volume`. Integration,
native diagnosis and certificate reconstruction use its separate worktrees.
The isolated function-source investigation uses native overlay storage at
`/home/agent/silver-worktrees/procedures-lean-370`. Each installation is separately
configured after relocation; no writable proof workspace is shared. These are
sandbox-local workspaces: retained deliverable evidence is committed and pushed
through the existing PR; local caches are not implied to exist on the host.

## Focused work and checkpoint order

- Astra Max native investigation: compare the unchanged array-declaration
  assertion with retained sessions, then check the whole helper and affected
  caller under the canonical compiler policy. Retained success under a different
  budget is not current-policy success.
- Astra Max function-source investigation: check the previously failing
  `DeclarationLoopFunctionLocals` closure in isolation, with one worker,
  automatic process threads and an 8 GiB threshold. Monitor process RSS and host
  headroom. This reduction is justified by this host's measured memory limit.
- Astra Ultra certificate investigation: determine a kernel-checked complete
  source reconstruction that fits this host. The earlier aggregate footprint
  exceeded current RAM. Preserve every source byte, checked lexer result,
  authoritative binding and final audited argument.

Native diagnosis initially reserves at most two workers alongside the isolated
Lean run; only small certificate lemma experiments may overlap. Reassess these
allocations before each larger run. Full contracts and declared domains,
canonical proof policy, all obligations and source correspondence remain intact.
No blind complete retry, timeout increase or successor implementation is selected.

`test-inventory.json` identifies 691 distinct tests at the starting point;
it records discovery, not execution or successful regression validation.
Complete native assurance, complete Lean/source/module/axiom/provenance checking,
all applicable regression cases, final critical review and Rosetta reconciliation
remain pending. Subsequent focused results and exact final inputs must be linked
here before a complete-checkpoint claim.

## Focused repairs and final-input checkpoint

The native repair at `03141a9fe` binds the existing model expression once in a
`Ghost => Static` constant, without changing the runtime initializer, exported
contract, full domain or 30-second canonical proof policy. The whole helper
passed 56 proof and two flow checks; the unchanged direct caller retains 11
proof and two flow checks with exact continuity evidence. The corresponding
Lean renderer passed run `20261115T173050-5f33a5830ee5`, freshly auditing 13,678
declarations. The [independent review](../certificate-memory/review-native-ghost-constant.md)
accepts the source, wrapper and exact reviewed-token delta.

The [function-source repair](../lean-recovery/README.md) preserves the full-source
duplicate-detecting scan and public theorem while normalizing the expected
string through a proved character identity. Focused run
`20261115T173223-fb4134e2af34` passed at the ordinary 8 GiB threshold; its process
tree peaked at 5.710 GiB. Corrupt character/token and duplicate controls remain
retained. The [certificate repair](../certificate-memory/README.md) constructs
the existing reconstruction theorem through the checked auxiliary-lemma path.
Its actual-size join passed at 3 GiB. These results favor a proof representation
and string-normalization bottleneck; they do not establish an asymptotic bound
on the entire proof pipeline or complete assurance.

The old-source certificate run was deliberately interrupted after the required
native repair invalidated its source, with no memory failure. Five completed
line buckets, all inputs and compiled artifacts remain retained. Its final
aggregate and audit did not run. Resume on the combined source and reuse only
matching artifacts through normal Lake dependency checks.

All 40 generated candidates were independently regenerated on the final Ada
bytes and refreshed together; [the refresh inventory](generated-candidate-refresh.json)
identifies the seven changed files, including the formerly stale output
specification candidate. [The reviewed pin delta](reviewed-output-pin-delta.json)
contains exactly one static declaration and two references to it.
[Lean cache seed identities](lean-cache-seed.json) record matching ARM64 artifacts,
not proof success. Before the full Lean run, check the two largest inherited
function headers with one worker/default process threads and the same 8 GiB
threshold. Complete native validation may proceed on the fixed Ada/tool inputs.
All final complete checks and the 691-ID regression inventory remain outstanding.

### Inherited declaration-header capacity

The two largest inherited declaration headers failed the 8 GiB kernel limit
even when scheduled alone. The [targeted normalization](../lean-recovery/header-capacity/README.md)
at `1684b88fa` preserves both public statements and complete-source extractors;
run `20261115T175133-2b096066a6f7` passed 108 imported modules and a fresh
15,611-declaration audit. Largest-process RSS was 4.022 GiB and process-tree
RSS 5.025 GiB. [Independent review](../native-recovery/review-function-header-memory.md)
accepted the exact strings, characters, tokens, unchanged statements and
retained evidence. Existing kernel corruption controls apply to the unchanged
normalization mechanism; ordinary-body duplicate fixtures do not test the
separate header extractor.

The subsequent focused `FunctionSourceCandidate` build passed additional
dependencies and the shorter `FunctionTypeAt` headers, then deliberately stopped
after `DeclarationHeaderParameterStepSpec` reached the same 8 GiB limit. It is
interrupted, with no complete caller audit. Completed objects remain retained.
The next bounded batch covers that failed header and five remaining declaration
specification headers at least as long as the demonstrated 695-character case.
Their exact statements and whole-source scanners remain required; no broader
rewrite or language restriction is selected. The complete native audit and
final-source line-certificate batch continue independently. Dense aggregate
validation waits for a separate memory allocation.

### Recovered function-source and output certificate checkpoints

All selected long function-source expectations now use the reviewed checked
normalization mechanism. The [six-header batch](../lean-recovery/parameter-local-headers/README.md)
and [remaining ten-check batch](../lean-recovery/remaining-expectations/README.md)
passed focused audits and independent exact-data/source reviews; their records
distinguish observed failures from same-mechanism selections. The 433-character
selection cutoff was not asserted to be a proven memory bound. No public theorem,
whole-source selector, native domain or source byte was weakened.

The complete [function-source candidate](../lean-recovery/function-source-candidate/README.md)
then passed run `20261115T182909-e353e1507833`: 197 imported modules, a fresh
17,516-declaration audit and 5.60 GiB peak process-tree RSS. This refresh includes
the unchanged function-local loop against the final reviewed source; its earlier
old-source success alone was not treated as final-source evidence.

The final-source [output certificate](../certificate-memory/README.md) passed
run `20261115T183635-e890328a97c4`: 17 imported modules, a fresh
51,104-declaration audit, 178.755 monitored seconds and 6.500 GiB peak tree RSS.
It reused the successful eight-line batch (14 modules / 22,993 declarations).
Neither run triggered its memory guard. Exact input snapshots and full cache
artifact inventories are retained for verified transfer; complete-project Lean
and native audits and the final regression suite remain mandatory.

A fresh read-only regression discovery confirms 691 distinct test IDs across
57 modules, unchanged from the starting inventory, and 85 manifest samples.
Two methods are explicitly Linux-x86-only and inapplicable to this ARM64 run.
This inventory is not a suite execution. Managed tests lease the entire host
artifact root; nested application proofs retain canonical `-j0`, independently
of the managed worker reservation. Run the final compiler build and full suite
after the conflicting proof leases and dense memory allocations release.

### Complete-project entry and memory diagnosis

The remaining focused helper gate exposed the same literal-normalization cost
in the Boolean declaration specification header. A five-field diagnostic
isolated its 674-character suffix. The two-file repair at `7064c1863` retains
the complete original theorem, all five fields, source selector and exact
header data. The [complete helper candidate](../lean-recovery/complete-checkpoint/README.md)
then passed run `20261115T185653-905487da1ee4`, freshly auditing 104 modules and
14,576 declarations. The [independent review](../native-recovery/review-boolean-header-memory.md)
accepted the repair and verified its retained input and artifact inventories.

The complete cached Lean check started as
`20261115T190543-9bda6434802c` on the production bytes now published in
`8ccbc8421`. Its preflight import graph reaches all 1,003 project modules.
The run uses one worker, automatic twelve process threads and an 8 GiB
per-process threshold, with separate 10 GiB process-tree and 1.5 GiB available-
host-memory guards. The complete native audit
`20261115T174959-94ae5c6fdf63` continues separately with two workers and unchanged
canonical proof settings. At this entry checkpoint both runs remain active;
neither has a completed whole-project success. The prospective
[literal inventory](../native-recovery/source-expectation-inventory.md) identifies
possible diagnostic targets, not observed failures or required speculative
repairs.

The observed memory failures concern the representation and kernel reduction
of long source expectations and reconstruction witnesses. The enlarged
implementation exposes that cost, including in inherited function and Boolean
checks. The same public claims and source selectors pass after checked
normalization, and the complete output reconstruction passes after compact
witness construction. This is evidence for a proof-representation bottleneck;
it does not demonstrate exponential program-state growth or establish an
asymptotic complexity bound. Procedure semantics still require their full
composition proof, and the application's 4,096-byte source limit is unchanged.

The native computation survived the loss of its original monitoring wrapper.
Resource sampling has a retained gap from 18:39:22 to 18:43:06 UTC, after which
an identity-checked attachment monitor restored the existing headroom guard.
No original wrapper exit status is available. Its eventual outcome must use
the managed phase records, complete native manifest, logs and final input/tool
checks, with this monitoring limitation retained explicitly.

The [interim independent delivery review](../../../reviews/review-scalar-procedures-delivery-20261115.md)
checks the frozen `8ccbc8421` integration, reviewed repair continuity, retained
focused audits and the isolated Rosetta proposal. It identifies no new material
static defect. Final acceptance remains withheld until the complete native and
Lean audits, build, applicable full regression coverage and coordinated delivery
records are available for its closing addendum.

### First complete-run outcome and next focused check

Complete Lean run `20261115T190543-9bda6434802c` stopped at 19:39:40 UTC after
two explicit kernel-memory failures in `ComposeDeclarationSourceCandidate`:
`declaration_fact_11` checks the 650-character parser-state record expectation;
`declaration_fact_22` checks the 922-character state-validity expression.
The source-only diagnostic guard sent SIGINT; its summary records monitored
child return code `-2` after 2,037.495 seconds. No complete audit ran. Peak sampled tree RSS was
8.960 GiB and minimum host availability was 3.760 GiB, so this was the Lean
per-process limit rather than exhaustion of host headroom.

The original session outcome and failed logs are retained by the Lean owner.
All 287 existing module objects remain preserved, including the completed
source certificates and catalogue candidate; object presence is not a fresh
whole-project audit. The next bounded repair normalizes only those two exact
expectations in a separate helper and their original private proofs. Every
public statement and complete-source extractor remains required. The complete
declaration candidate must pass a focused audit and independent review before
another complete run. Other prospective literals remain unchanged. The native
audit continues independently on its original frozen inputs.

### Declaration recovery and complete continuation

The two-fact repair is integrated at `dbdec4b22`, preserving all 47 original
candidate statements. The [focused success packet](../lean-recovery/complete-checkpoint/declaration-normalization/README.md)
retains run `20261115T194603-51d997e177d8`: 101 modules and a fresh audit of
14,411 declarations, with the three approved foundations only. It passed under
the same 8 GiB per-process threshold, without a guard interruption. All 1,111
captured inputs, imported workspace files, artifacts and tools were reverified;
all 287 previous objects remain byte-identical. Independent critical review
accepted the exact source/token data, unchanged claims and original terminal
evidence before the complete continuation.

Complete cached run `20261115T195423-d7650f191422` began on these frozen
production bytes with 289 retained objects and all 1,004 project modules
reachable in the preflight import graph. It uses a new retained run directory,
leaving the failed complete packet untouched. The one-worker/default-twelve-
thread/8-GiB allocation and existing guards remain appropriate alongside the
productive two-worker native audit on this host. No clean build, independent
kernel replay or repeated successful focused gate was added. Whole-project
success, final build/regressions and final delivery acceptance remain pending.

### Procedure metadata-header failure and focused follow-up

Complete continuation `20261115T195423-d7650f191422` stopped at 20:10:09 UTC
on the 646-character `metadata_append_header` expectation in
`ProcedureDeclarationHighSourceParts/Body.lean`. The existing source-only
diagnostic guard interrupted the run after the explicit kernel-memory error,
with monitored child return `-2` and original outer session exit 254. Elapsed
time was 946.159 seconds; no complete audit ran. Peak process/tree RSS was
8,394,704 / 9,184,752 KiB, with minimum available host memory 3,573,632 KiB.
Completed declaration, procedure-frame, body and source artifacts remain
preserved. The subsequent outer source module was interrupted, not passed.

The next bounded repair changes only that header proof and a new exact-token
helper. The separate `ordinary_0` body theorem, original header statement,
full-source procedure selector and metadata definition remain unchanged.
The complete `ProcedureDeclarationHighSourceCandidate`, including all its
source fragments, must pass focused validation and independent review before
another complete continuation. Native validation remains productive on its
unchanged source. This is a retained failed/interrupted complete attempt,
not completed source assurance.

### Procedure header recovery and next complete continuation

The exact header repair is integrated at `33a7c351f`. The
[focused packet](../lean-recovery/complete-checkpoint/procedure-metadata-normalization/README.md)
retains successful run `20261115T201355-b250e246f4ef`: all source fragments and
the full high-level procedure candidate, followed by a fresh audit of 115
modules / 16,374 declarations. It completed in 25.031 monitored seconds with
1,858,416 KiB peak process RSS and no guard or interruption. Independent critical
review accepted the unchanged body theorem, header statement, metadata
definition, exact 646 characters / 138 tokens and original focused evidence.

All 621 previous objects remain byte-identical. The next complete cached run,
`20261115T201746-8829535d867a`, starts with 625 objects and a preflight import
graph reaching all 1,005 modules. Production bytes are frozen at the reviewed
repair, and the previous complete attempts remain separately retained. The
same measured resource allocation and guards apply alongside the native audit.
Complete assurance, final build/regression coverage and delivery acceptance
remain pending.

### Flow-source constructor failure and field diagnosis

Complete run `20261115T201746-8829535d867a` stopped at 20:29:51 UTC after
kernel-memory errors in the counted-bound, flow and reader constructor proofs
of `PredicateFlowSourceCandidate`. The original session returned 254 and the
monitor recorded child return `-2` from the diagnostic SIGINT. No complete
audit ran. All 656 completed objects were preserved; the next native-helper
candidate was interrupted. Peak process/tree RSS was 8,401,840 / 9,443,488 KiB,
with minimum available host memory 6,535,664 KiB.

Diagnostic run `20261115T203335-d0861ad752c6` restated all 17 exact contract
fields individually against the same complete source. It exited naturally with
failure code 1, without interruption, after two kernel-memory errors:
`CountedBoundNative.spec` and `FlowSourceBridge.joined`. The reader fields
produced no diagnostics in this failed probe; they are not claimed as audited
successes. The probe and original failed run remain diagnostic evidence.

The bounded repair now targets only the long literal fragments in those two
confirmed fields, preserving every surrounding header, semantic rendering and
concatenation. The five unchanged reader propositions will receive individual
private proofs, then assemble the original reader contract. That tests proof
aggregation as the explanation for the reader-constructor failure; the complete
candidate must still validate it. The temporary probe will be retained outside
production and retired before the full candidate gate. Native source and
validation remain unchanged, and complete assurance remains pending.

### Flow-source recovery and complete continuation

The two-file repair is integrated at `451b5761a`. Its
[focused success packet](../lean-recovery/complete-checkpoint/predicate-flow-normalization/README.md)
retains run `20261115T204311-34308bc25803`: the whole flow-source candidate,
both normalization helpers, all five private reader fields and their unchanged
caller passed a fresh 132-module / 21,861-declaration audit. The monitored run
completed in 255.286 seconds without a guard or interruption under the same
8 GiB per-process threshold. Independent review accepted the exact source data,
all semantic renderings, field factoring and original terminal evidence. The
failed probe remains failed; the combined repair does not establish that proof
aggregation was the sole cause of the earlier reader error.

All 656 prior objects remain byte-identical. Complete cached continuation
`20261115T205032-5834a8189332` starts with 658 objects on the reviewed production
bytes; the preflight import graph reaches all 1,006 project modules. It retains
the same resource allocation and guards alongside the unchanged native audit.
Complete native and Lean assurance, build/regression coverage and final delivery
acceptance remain pending.

### Native-shape header failures and focused follow-up

Complete continuation `20261115T205032-5834a8189332` stopped at 21:01:37 UTC
after six explicit kernel-memory errors in `PredicateNativeShapeCandidate`.
Each failing private theorem checks one complete specification header:
`primary_model`, `relation_model`, `condition_tail`, `condition_model`,
`boolean_factor_model` and `boolean_relation_model`. Their exact expected
strings contain 701, 705, 948, 709, 729 and 737 characters respectively.
The diagnostics identify individual equalities, so another field-isolation
probe is unnecessary. The preceding `PredicateNativeHelpersCandidate` built
successfully; the subsequent body-source candidate was interrupted.

The author collected original session 72203: outer exit 254, monitored child
return `-2` after the diagnostic SIGINT, and 665.628 seconds elapsed. No complete
audit ran. Peak process/tree RSS was 8,435,184 / 9,477,264 KiB and minimum host
availability was 6,390,096 KiB. This was the configured Lean memory threshold;
neither the host-headroom nor tree-memory guard fired. Completed objects and
the exact failure packet are retained by the Lean owner.

The bounded repair changes only those six private proof bodies/imports and an
isolated exact-token helper. It retains every original theorem statement,
whole-source selector, native source definition, precondition, postcondition
and variant. The complete native-shape candidate must pass focused validation
and independent critical review before the next cached complete continuation.
The productive native audit continues on its unchanged inputs. No whole-project
or final regression success is claimed.

### Native-shape recovery and next complete continuation

The six-header repair is integrated at `438213ec2`, with its
[focused success packet](../lean-recovery/complete-checkpoint/native-shape-normalization/README.md)
in `fbf81c587`. Run `20261115T210927-f5ecbbed5260` passed the complete
`PredicateNativeShapeCandidate`, all six helper contracts and all 63 original
private source statements. Its fresh audit covers 127 modules / 21,408
declarations with only the three approved foundations. The author collected
original session 18170 with exit zero; no guard or interruption occurred.
Monitored elapsed was 285.288 seconds, peak process/tree RSS was
4,252,992 / 5,296,592 KiB, and minimum host availability was 11,302,496 KiB.

Independent critical review verified the exact literals, character/token lists,
complete-source headers, unchanged statements/selectors/contracts and all
1,114 input / 1,009 workspace / 3,962 artifact / two executable hashes.
The original evidence's private-statement count of 58 was a multiline-parser
inventory error; the corrected count is 63, independently verified. It did not
change production claims or proof results. All 659 prior objects and 3,950
variant/hash files remain unchanged; 661 objects are now present.

Complete cached continuation `20261115T211741-9bb82c28fe83` started on the
frozen reviewed production, with all 1,007 project modules reachable from
`Silver.Audit` in the preflight graph.
The same one-worker/default-twelve-thread/8-GiB allocation and separate guards
remain appropriate beside the productive two-worker native audit. All four
failed complete attempts remain distinct from focused successes. Complete
assurance, final compiler/regression coverage and final delivery acceptance
remain pending.

### Complete native checkpoint passed

The [complete native packet](../native-recovery/full-native/README.md), integrated
at `5fa307903`, retains successful run `20261115T174959-94ae5c6fdf63` on the
unchanged native inputs. At 21:19:31 UTC its native-tool phase exited zero and
the managed audit completed successfully. Fresh coverage and provenance checks
accepted all 19,444 required checks: 1,715 flow and 17,729 proof checks across
78 units / 1,232 entities. All 2,606 captured inputs, 80 report hashes and twelve
tool identities match. The complete array-declaration helper and direct caller
are included in this full result.

This is canonical 30-second full validation using the existing result cache,
with forced analysis and two workers; it is not a cold-run measurement. Managed
elapsed time was 12,572.65 seconds. The original wrapper exit is unavailable,
the managed overall returncode is null, and the earlier 224-second sampling gap
remains explicit. Native phase exit zero, managed success, final reports and
the verified complete manifest establish the reported outcome; no missing exit
observation is invented. All 119 archived files and direct terminal records
have verified hashes.

The monitor released the finished native run after retaining its evidence and
now owns the final two-worker compiler build in integration. Complete Lean run
`20261115T211741-9bb82c28fe83` continues in its separate workspace; the full suite
waits for the dense Lean allocation to release. Final native-evidence review,
complete Lean/source assurance, regression coverage and coordinated delivery
acceptance remain pending.

### Final compiler build and next body-source diagnosis

Final build `20261115T212353-b892f44c0742` passed on the accepted native inputs.
The [build packet](../native-recovery/final-validation/build/README.md), integrated
at `00818d453`, retains observed wrapper/native-phase exits zero, managed success,
the compiled/linked compiler and retained up-to-date Image adapter. All native
inputs, tools and full-audit report hashes still match. This is an incremental
build; it is not regression execution.

Complete Lean continuation `20261115T211741-9bb82c28fe83` stopped at 21:26:21 UTC
on four individual equalities in `PredicateBodySourceCandidate`: the tail-model
specification, body-tail specification, read-body specification and valid-context
expression. The author collected original session 15946 with outer exit 254;
the monitored child returned `-2` after the diagnostic SIGINT. Elapsed time was
520.532 seconds, with peak process/tree RSS 8,390,032 / 9,454,224 KiB and minimum
host availability 7,668,128 KiB. No whole-project audit ran, and the subsequent
structural-guard module was interrupted.

The four exact long literals contain 712, 633, 632 and 762 characters. The two
composite specifications retain their typed semantic renderings and complete
88-character variant suffixes. The bounded repair targets only those four
private proofs and an exact-token helper; all statements, definitions, domains,
selectors, renderings, concatenations and termination requirements remain intact.
All 661 prior objects remain preserved. Complete focused candidate success and
independent critical review precede another cached complete continuation.
Native/build success remains applicable; the full suite still waits for the
dense Lean work to finish. Final delivery acceptance remains pending.

### Body-source recovery and accepted native/build evidence

The four-field repair is integrated at `a6c8c8afc`, with the
[focused success packet](../lean-recovery/complete-checkpoint/body-source-normalization/README.md)
in `afac5d059`. Run `20261115T212952-885cb9e630e5` passed the complete
`PredicateBodySourceCandidate`, all four helper contracts and all 108 original
private statements. Its fresh audit covers 290 modules / 38,257 declarations
with only the three approved foundations. The author collected original session
78053 exit zero; no guard or interruption occurred. Monitored elapsed was
385.482 seconds, peak process/tree RSS was 5,800,992 / 6,859,408 KiB, and minimum
host availability was 10,238,272 KiB.

Independent critical acceptance `c3b84a76d` verifies the exact literals, typed
semantic renderings, variant suffixes, unchanged statements and selectors, all
1,115 input / 1,010 workspace / 3,974 artifact / two tool hashes, and the durable
terminal packet. All 661 prior objects and 3,962 variant/hash files remain
unchanged; 663 objects are now present. The complete preflight graph reaches all
1,008 project modules. Complete cached continuation
`20261115T214116-f50ce45f47c2` started on the frozen reviewed production,
with one worker because a single candidate has measured roughly 9 GiB tree RSS
on this 15.8-GiB host. Default twelve process threads, the 8-GiB threshold and
the separate existing guards remain in force. The native run has finished;
competing native work is no longer the reason for this reduction.

Independent review `a9723e157` accepts the complete native audit and final build.
It verifies complete coverage, every required obligation, source policy,
contract-dependency boundaries, diagnostic classifications, provenance and
build identities. [The dependency-count erratum](../native-recovery/full-native/helper-dependency-erratum.json)
corrects a historical manual inventory: the two helpers each have two ordinary
dependency-claim records, containing 126 and 52 dependency entries. Their
dependencies are accepted by the boundary audit; all 78 reports have empty
`pragma_assume` lists. The original archive is unchanged. The unavailable
original native wrapper exit and monitoring gap remain explicit. No production
change or proof rerun was needed for this evidence correction.

Complete Lean/source assurance, full regression coverage, coordinated Rosetta
promotion and final feature acceptance remain pending.

### Procedure-name loop source failure

Complete continuation `20261115T214116-f50ce45f47c2` stopped at 21:43:16 UTC
after one isolated kernel-memory error at `ProcedureNameSourceParts/Loop.lean:20`.
The public `loop` theorem compares the complete `actual_name_free` body selected
from the reviewed whole source with `SourceChecks.loopBody`, one exact expected
string. The author collected original session 3798: outer exit 254, monitored
child return `-2` after the diagnostic SIGINT, 120.211 seconds elapsed. No
whole-project audit ran; the next actual-parameter module was interrupted.
Preceding predicate and procedure-name parts completed, and their objects remain
preserved.

The next bounded repair normalizes only that literal through the checked
character/lexer route, retaining the original public theorem, complete source
selector, loop definition, native code, invariants, variant, returns and closing
tokens. The whole `ProcedureNameSourceCandidate`, including all headers, record,
step, model and loop fields, must pass focused validation and independent
critical review before another complete continuation. Native/build acceptance
remains valid; full regressions and final delivery acceptance remain pending.

### Procedure-name loop recovery accepted

Repair `1dde32cce` preserves the exact 677-character / 134-token loop through
the checked character/lexer normalization. Its
[complete focused packet](../lean-recovery/complete-checkpoint/procedure-name-loop-normalization/README.md),
integrated at `7dcb0cf03`, records run `20261115T214559-235d06a3549a`: the entire
`ProcedureNameSourceCandidate` passed a fresh audit of 116 modules / 14,774
declarations with only the three approved foundations. The author collected
original session 80078 exit zero, with no guard or interruption. The loop proof
built in 3.5 seconds; managed build/audit took 5.643 / 0.817 seconds and monitored
elapsed was 15.018 seconds. Peak process/tree RSS was 951,440 / 1,385,184 KiB.

Independent critical review `a63b879cf` accepts the unchanged public theorem,
complete selector, literal/character/token identities, imperative loop, both invariants,
variant, returns and named terminator. All other source parts, models, complete
caller and authoritative transport remain intact. The reviewer checked all
1,116 input / 1,011 workspace / 4,082 artifact / two tool hashes, actual imported
module set and immutable terminal packet. All 678 prior objects and 4,064
variant/hash files remain unchanged; 681 objects are now present. The complete
preflight graph reaches all 1,009 modules.

Complete cached continuation `20261115T215223-28e04bff3fce` started on the
frozen reviewed production with the existing measured-memory allocation and guards. All six
prior interrupted complete attempts remain separately retained. Complete
Lean/source assurance, full regression coverage, Rosetta promotion and final
feature acceptance remain pending.

### Complete Lean/source checkpoint passed; final regressions active

The [complete Lean packet](../lean-recovery/complete-checkpoint/final-complete-cached/README.md),
integrated at `92e5ef282`, records successful run
`20261115T215223-28e04bff3fce` on frozen production `1dde32cce` (author
`32c6fbca5`). The actual fresh audit covers all 1,009 current project modules
and 162,269 declarations, using only the three approved foundations. Source
candidates, semantic bridges and the top-level facade are included. All captured
input, workspace, artifact and tool hashes match; all 681 prior objects remain
unchanged. The author collected original session 79079 exit zero, without any
guard or interruption, after 695.766 monitored seconds. This is complete cached
validation with a fresh whole-project audit, not a clean build or kernel replay.

The dense Lean allocation and managed lease are released. The independently
accepted native audit and final compiler build remain valid on unchanged native
inputs. Independent review of the complete Lean packet is in progress; final
feature acceptance remains separate from successful proof execution.

The full regression/sample suite started at 22:09:16 UTC as
`20261115T220916-99f1eaeea331`, from integration launch HEAD `4de5d4e51`. Its
source/proof production matches the validated snapshot. Preflight discovery
confirmed 691 distinct IDs and 85 manifest samples, with two expected
Linux-x86-only cases inapplicable on ARM64. Those are inventory expectations;
actual pass/failure/skip results remain pending. The runner captured 1,316
regression inputs, all 2,606 native inputs and both matching compiler binaries.
It uses automatic managed workers and unchanged canonical application `-j0`,
with the 1.5-GiB host-headroom guard and no proof-tree cap. The original launcher
remains owned through terminal collection. Only documentation/evidence may
change in integration while these test inputs are frozen.

Full regression success, Rosetta/support reconciliation and final independent
delivery acceptance remain outstanding. PR #371 remains draft.

### Complete Lean accepted; regression fixture diagnosis

Independent acceptance `3620b9d9b` verifies the complete Lean packet, actual
module/declaration scope, all captured hashes, regenerated candidates, source
bindings and continuity with the accepted native inputs. Both complete proof
checkpoints and the final compiler build now have independent acceptance.

The still-running full suite has reported one actual failure in
`LeanModuleTests.test_output_body_chunks_reuse_objects_across_content_and_occurrence_edits`.
The original run continues with its frozen inputs; the terminal traceback and
complete inventory are pending. Read-only inspection found that this test's
isolated fixture omits `CertificateJoinWitness`, which the current aggregate
generator imports. The earlier generator change updated the companion source
fixture but missed this module-reuse fixture. This is a concrete dependency
omission and a likely explanation, not yet a verified resolution of the
observed failure.

A bounded patch is being prepared in the separate author worktree: add only
that copied helper dependency and correct the cold-build count comment. All
reuse/invalidation assertions, eleven edit variants, audit checks, memory
settings and watchdogs remain unchanged. No production, generator or active
suite input changes are authorized. The full traceback and a focused complete
repair run after suite release must establish the actual result; independent
review must account for every final test identity before delivery acceptance.
