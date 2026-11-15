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
