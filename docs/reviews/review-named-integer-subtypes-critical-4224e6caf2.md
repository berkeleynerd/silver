# Named Integer subtypes: critical correspondence review — 2026-10-29

**Bounded verdict: no actionable defect found.** This is an independent source
review for #286, not a completed assurance or delivery claim.

Reviewed commit: `4224e6caf21bade207002051abaeea0230dbb44b`, compared with
`00bed9c425a4212a49f9d3558fb0a7205bc4a805`. The isolated review worktree was
`tmp/subtype-critical-review`, branch `review/subtype-critical-4224e6caf2`.
Only this report was edited. No GitHub changes or implementation changes were
made. The live harness reported no active goal.

Selected reviewer: GPT-6 Astra / Extra High; runtime model/effort confirmation
and token/cost measurements are unavailable. Substantive review ran from
15:09:10 to 15:14:41 UTC (331 seconds), followed by report preparation.
`python3 scripts/dev.py paths` identified the host as `linux-x86_64`.
No native build, GNATprove, Lean, regression or sample run was performed.

## Inputs and boundaries

Read `AGENTS.md`, the Oracle, relevant language and capability sections, and
the review-bookkeeping requirements. Primary implementation inputs were
`src/silver_output_profile.adb`, its specification, and the changed
`silver_scalar_expressions.ads` and `silver_array_bindings` files.

Primary proof inputs were `ComposeExpressions`, `ComposeContracts`,
`ComposeSourceCandidate`, `ComposeArrayExpressions`,
`ArrayBindingsNativeExpressions`, `ArrayBindingsNativeEquations`,
`ArrayBindingsSourceChecks`, `PredicateNativeExpressions`,
`PredicateNativePrecedence`, `PredicateArrayBodyNative`, and
`PredicateArrayBodySource`. Targeted supporting reads covered subtype metadata,
declaration/type lookup, evaluation and domain adapters, array allocation/read
invariants, subtype hiding propagation, endpoint obligation traces, and the new
tests. These were the files at the reviewed commit, not the lead's continuing
proof repairs.

The question was whether this increment repeats the earlier association-check
or omitted-native-domain defects, or introduces a concrete native/model meaning
mismatch in the new fields, subtype lookup/hiding, or bounded components.
This was not a new universal review of all preexisting expression constructors.

## Reviewed correspondence

- The new subtype constructors agree across rendering, evaluation and the
  concrete trees: subtype indexes remain one-based; appended metadata and
  parser-state updates preserve the other fields; the five operation spellings
  and binder values match; and the omitted constraint argument is restricted
  to the `Scalar_Constraint_At` spine with its actual Full default. The concrete
  new comparison, conditional, quantified and aggregate forms retain their
  grouping and scope. The array helper's explicit precedence categories cover
  the added arithmetic, comparison and guarded/quantified constructors. No
  association collision was found in the changed source trees.
- The native and interpreted helper domains both carry subtype-environment
  validity and bounded interval endpoints. `ArrayAddDomain` retains the new
  last-segment allocation condition; the caller derives it from the existing
  environment's allocated-prefix bound. `ValidMetadata` carries ordered,
  disjoint allocation, while `validMetadataBody`, `validBinding_meaning` and
  `checked_preconditions` cover the changed native validity predicates.
  Initialized-value containment remains the separate `InitialsFit` /
  `SourceReady` property; it is not silently assumed of arbitrary native tables.
- Initializers and indexed stores compare both ends of the value interval with
  the declared component interval. Non-elaborating reads and foreach binders
  use that component interval; elaboration still uses exact initialized values.
  The native record field order, empty binding, append tree and source checks
  include `Component_Bounds` consistently. The scalar/array identity separation
  follows the enlarged scalar limit.
- Type lookup checks object hiding before resolving predefined Integer or an
  earlier subtype. Declaration uniqueness includes the subtype table, direct
  parents remain visible predefined Integer, and subtype names cannot be
  Integer. String is already a forbidden declaration spelling. Operation-hiding
  flags reach condition and statement calls; qualified-call handling remains
  in the existing operation resolver. Loop binders remain scalar identities.
- Staticness and intermediate Integer checks remain in both endpoint reads.
  Optional object ranges must be contained in the resolved base interval.
  `SubtypeDeclarationChecksAt` retains both raw endpoint arithmetic obligation
  lists, and initializer traces include the subtype declaration case. This
  review found no weakened endpoint assumption or removed obligation route.

## Remaining verification

The lead reported ongoing interpreted `ComposeHelperEquations` proof
normalization and an unresolved native VC concerning raw `Hidden_Calls` equality
in `Same_Parser_State`. Neither is treated as successful here. A possible later
logical-equality annotation change is outside this exact review input.

Complete native Bronze/Silver discharge, Lean checking and axiom/module audits,
authoritative-source correspondence/certificates, provenance, final build and
full regression validation remain integration obligations on identified final
inputs. Existing focused results and samples were not rerun or promoted to
universal assurance by this review. This report authorizes no merge.
