# Original package effects review — 2026-11-28

No new material finding in the nine frozen modules reviewed below. Their
statements and proofs support the bounded effect-inference, native-mask,
initializer and return claims. This accepts those increments for continued
integration; it does not establish complete #416 assurance or PR #424 readiness.

The lead assigned this independent, read-only review within the owner-authorized
#416 work and #426/#427 repair delivery. The unchanged Oracle requires original
source correspondence, every admitted input and composition, complete obligation
discharge, and no assumed project-specific safety or checking certificate.
The package rules require conservative transitive effects, full declared routine
domains, and coverage of dead arms, empty loops and unused definitions. The lead
retains implementation, publication and delivery ownership. This review changed
only this report and local review scratch; it launched no compiler or Lean run.

Reviewer selection: GPT-6 Astra, Max, for critical proof review. Runtime model
and effort were not independently exposed. Elapsed review time across the
handoff and token/cost measurements are unavailable. Actual host: Linux x86-64.
No native workers were reserved; CPUs 4–5 remained released to the lead.

The reviewed effect chain is `9d59088c1c`, `150d11848e`, `a89ee4d838`,
`86a2a367a8`, `0cbf01f1fc`, `623ec790e1`, `a328a03b13`, and
`87b6254bf6f28d6634725faedd382735e101d4ab`. The initializer chain is
`ee320c0909`, `941f481cfa`, and
`9207833fefe6cda0e611ff6a9e16d03d08582da8`. The complete contents of the
nine files below were inspected, totaling 3,317 lines. Each frozen copy was
compared with its commit blob and independently hashed. All nine also match
integrated checkpoint `737e2843909d00b95071b2c90a89a6da9f84e957` exactly.
Later changes are outside this review.

| File under `proof/Silver/` | Frozen source | SHA-256 |
| --- | --- | --- |
| `ApplicationPackageSourceEffects.lean` | `87b6254bf6` | `7c16d9263d798245b396a2b606ee0cada353518cf1a6c32a694979799f5d1ade` |
| `PackageEffectSummaries.lean` | `87b6254bf6` | `e59055ffa03ff3b7444a6dcd363a75c953ea0d938e79fbb53e4ba35b827d36b2` |
| `ApplicationPackageProcedureEffects.lean` | `87b6254bf6` | `52e6b7237169dcdeb4a5cedf5d12cd7ef8bf9b8182e086e4d7f2490758fa9148` |
| `ApplicationPackageBasicEffects.lean` | `87b6254bf6` | `b5ad3987b78ff6d8816fc53833ed5309e744c40ba2036b7c751921a5c8d51097` |
| `ApplicationPackageRoutineEffects.lean` | `87b6254bf6` | `3726e6874a6c454e836c9a22f8ff963168e77ece945a4e58a529623f745f3fe2` |
| `ApplicationPackageRoutineResults.lean` | `87b6254bf6` | `03d8bbe10f4055a1bd61283525ef6eebd4584afd1a7bc573cc668192860233f2` |
| `ApplicationPackageRoutineFooterEffects.lean` | `9207833fef` | `12169837e3f1028229f5bbf097d29f4152edd063a8866293add4549bc24f56a8` |
| `ApplicationPackageLocalInitializerEffects.lean` | `9207833fef` | `06051ead0deca4926f203e9afca6de2a1e39dbbe10601974bcdbbe2d0f551ac7` |
| `ApplicationPackageRoutineInitializerEffects.lean` | `9207833fef` | `267d6bf068ea292ba6542926878a71b171dcddcd751077784947aeca7cc77da1` |

Immediate definitions and consumers were also inspected at their matching
`737e284390` revisions: `PackageDefinitions`, `PackagePhasedRoutineSafety`,
`PackageSummaryLibrarySafety`, `ApplicationPackageRoutineSourceChecking`,
`ApplicationPackageRoutineSourceSummary`, `ApplicationPackageRoutineSourceLibrary`,
and the function-return interface in `ApplicationPackageReturnReading`.
This is targeted dependency inspection, not a new exhaustive review of their
transitive proof imports or the native compiler.

The substantive checks were:

- **Conservative summaries and identities.** `Included` compares membership,
  so duplicates, native bit order and extra lexical reads do not require a
  semantic effect-list equality. `execute_local_summary` proves preservation of
  additional captured cells from the inferred write footprint.
  `append_local_summary` keeps the native summary at the original callable
  ordinal. Inference visits both conditional arms and loop bodies;
  `inference_append` retains the full source sequence. `routine_inference`
  consumes the separately derived phased-check result, rather than placing it
  inside the source relation.
- **Original argument rows and native accumulation.** `StoredReads` and
  `RowReads` come from the executed actual fold, including arbitrary physical
  indices and empty argument lists. `original_executed` proves equality of
  source spans, targets and association control through `SameSyntax`;
  it does not assume equality of the omitted effect fields. Original semantic
  arguments are transported to the executed rows before their reads are
  included. Named reorderings retain the actual formal slots.
- **Direct and transitive call effects.** Procedure binding distinguishes
  input, output and input-output modes: pure output targets add copy-back writes
  without a copy-in read, while input-output targets contribute both. Function
  assignment adds its actual writable target to the earlier callee's effects.
  Bounds needed to set a native mask bit are explicit or derived from the
  executed fixed-capacity union. Source declaration and lookup facts preserve
  local shadowing; guessed state identities are not used.
- **Initializer scopes.** Each local RHS keeps its original preappend layout.
  `object_visible` uses successful native hiding and storage to transport every
  still-visible global to the post-Object mask scan, including cross-kind
  hiding. The histories retain all local and output-prefix reads in order.
  Output RHSs retain the original common preappend scope. Public constant seeds
  have no runtime global read; their original elaboration/value correspondence
  remains the separate initializer proof obligation. `initializer_effects`
  derives complete initializer coverage in the body-entry mask without a
  per-row effect-coverage premise.
- **Return and copy-back.** The function result is selected from its original
  terminal expression and checked in the actual final flow. Procedure results
  retain canonical formal rows through hiding, local declarations and output
  installation. Their local cells are identified by original formal spans,
  independent of current global values; exactly writable formals are collected
  in formal order. `results_included`, `return_preserves` and `footer_effects`
  connect result reads and retained body effects to the exact recorded footer
  masks. No full-text metadata-validity premise is imposed on a shorter source
  prefix to obtain these facts.

Retained validation was inspected rather than repeated. The managed start and
finish records, target lists, resource settings, audit output and captured source
maps were read for the following successes. The six effect-module hashes in the
first row and the three initializer-module hashes in the second row match the
reviewed bytes; `RoutineResults` also matches both. The initializer packet's
recorded event, evidence and log artifact digests were recomputed successfully.

| Retained run | Actual scope and result | Allocation |
| --- | --- | --- |
| `20261128T013911-0bd2ac3fa899` | `ApplicationPackageBasicEffects` and `ApplicationPackageRoutineEffects`; 84,516 declarations audited; 1,726 captured inputs; success | CPUs 6–7, two automatic workers/threads, 8,192 MiB per Lean process |
| `20261128T010928-3ffa7a1933c2` | `ApplicationPackageRoutineInitializerEffects`; 84,588 declarations audited; 1,706 captured inputs; success | CPUs 0–1, two automatic workers/threads, 8,192 MiB per Lean process |

Both use Linux x86-64 and Lean 4.34.1 and audit only the documented foundations
`propext`, `Classical.choice` and `Quot.sound`. They are incremental focused runs,
not clean builds or independent kernel replays. Their complete captured source
sets differ. In particular, the final effect run does not contain the three
initializer modules, and the initializer run predates later effect revisions.
These successes therefore establish their respective recorded scopes, not a
single validation of the entire integrated tree. The retained
[effect packet](../evidence/bounded-library-packages-416-20261122/package-result-effect-aggregation/README.md)
and [initializer packet](../evidence/bounded-library-packages-416-20261122/package-routine-initializer-effects/README.md)
preserve those distinctions and the preceding failed drafts.

The following remain completion requirements for the lead and active proof
streams, rather than new findings against these correctly bounded increments:

- Derive inclusion of effects newly introduced by the complete original body,
  including inherited assignments, every guard and counted-loop endpoint, all
  branches and loop bodies. `NativeMasks.tail_incoming` proves that incoming
  effects survive; it does not establish coverage of newly introduced effects.
- Compose initializer, body and result inclusion through the actual footer and
  derive `EntryEffectsAt` for every original completion. Feed that result and
  the independently derived phased checks into `checked_source_library` at
  the exact completed prefixes. Effect inclusion, successful checking and
  safety must remain conclusions, not fields assumed in final source meaning.
- Carry the native function no-write fact into original execution
  correspondence. `completionReturn_function`/`function_results` expose an
  empty returned write mask. Complete inferred-write inclusion then permits
  proving that the original function execution leaves globals unchanged.
  `SharedEnvironment.append` returns only a function value; its definition and
  the generic locality theorem alone do not prove that source-specific purity
  fact.
- Complete the authoritative-source/import binding, original package and Main
  runtime initialization, full-domain application/tool endpoint, and applicable
  complete native/Lean/source and regression validation. The explicit
  state-read/target helper equations in these modules still need their actual
  source-bound callers. This review supplies no native audit, new namespace
  reproduction, final application proof, Rosetta promotion or merge approval.

No repair is requested for the frozen nine-file scope. Complete the outstanding
joins and review their actual integrated result before claiming delivery. Issue
and board updates remain with the lead; no GitHub state or CLI memory was changed
by this review.
