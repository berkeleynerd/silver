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

## Bounded capacity and annotation follow-up — 2026-10-29

**The source-derived 32 MiB envelope remains supported; two validation/evidence
record corrections were identified. No semantic defect was found in the ghost
equality repair.** The expression review above was not repeated.

Selected reviewer remained GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements remain unavailable. Substantive follow-up ran from
15:25:41 to 15:30:00 UTC (259 seconds), followed by report preparation.
Correction checks completed at 15:31:47 UTC (366 seconds from follow-up start,
including report preparation and coordination).
No native, Lean or regression run was performed.

Capacity inputs were `docs/named-integer-subtypes-report-capacity.md` and its
constant-array, fixed-array and bounded-mutable predecessor accounts, at
`4224e6caf21bade207002051abaeea0230dbb44b`, together with the retained subtype
producer packet and the existing capacity regression. The five producer/frontend
inputs listed in the subtype account were accessible at its referenced retained
paths; all five SHA-256 hashes matched. The supporting `why-gen-expr.adb` also
matched the predecessor account's hash. All six files in the subtype producer
packet matched their recorded compressed/original hashes and sizes.

Inspection of the actual producer confirmed the static scalar-range gate,
the absence of the inline component-constraint route for a named component
mark, and the type-VC/coverage/timing gates. Initializer, component and assignment
conversions remain at existing source roots; narrowing their target ranges
does not add another source traversal or conversion site. Static subtype
declarations add neither initialized objects nor new metadata entities through
those routes. The shorter seven-byte scalar declaration changes the independent
declaration allowance, while the joint root/component, element-reference,
loop/write advisory and flow/name allowances remain applicable. Independent
arithmetic gives 5,689 charged checks and 31,822,336 bytes, leaving 1,732,096
bytes below 33,554,432. The retained probe contains exactly two
`VC_RANGE_CHECK` records, one Main entity, and empty flow/warning sections,
consistent with its narrow corroboration claim. No required new Main diagnostic
class or omitted feature-local source charge was found.

**Medium — stale executable capacity formula.** At the capacity review input,
`tests/test_capacity.py:114` still used `SOURCE_BYTES // 13` and its assertion
expected 31,269,376 bytes. It therefore tested the predecessor envelope and
undercharged the new declaration allowance by 552,960 bytes. No actual buffer
overflow was demonstrated: the corrected bound still fits. The lead repaired
the existing formula, comment and assertion in
`ad2bb41d47fbfb4773472a64eafdd4d33ef0d8a4`; this follow-up inspected that diff.
Disposition: source correction verified; final regression outcome pending.

The separate annotation input was
`90cceaa4674b6b6decba4c8550bd560cfb622a66`. Its parent output-profile source
is byte-identical to the prior critical input. The delta adds a static ghost
`Same_Parser_Subtype_Visibility` wrapper that compares the fixed array bounds
and every operation's Boolean value, then uses it in `Same_Parser_State`.
The use-type clause exposes enum equality. This preserves complete record
equality and changes no admission expression or domain. All five snapshots in
`native-logical-equality/after.json` matched their recorded original hashes and
sizes; the repaired source matched its recorded SHA-256. The two retained Why3
sessions mark all goals proved, and the report contains two successful
`VC_INLINE_CHECK` records plus 287 successful flow records. This supports the
specific annotation repair, not complete compiler verification.

**Minor — incorrect focused-warning total.** That annotation commit's
`after.json` says `warnings: 0`, and its README says “no warnings”. The
hash-matched `focused-success.spark.gz` instead contains 50 warning records:
5 `array-initialization`, 26 `contracts-recursive`, and 19 `numeric-variant`.
These are compiler-unit diagnostics, distinct from the warning-free Main
producer probe above. They do not negate the two successful annotation checks,
but the retained summary must report their actual count and distinguish any
applicable warning policy from absence of warnings. Disposition: reported to
the integration lead and corrected in
`96cb5f3601e38902bad623fd30c7f24677006289`. This follow-up inspected the corrected
README and JSON, including their explicit requirement to apply the existing
warning/advisory policy in the complete native audit. The original report is
unchanged; the correction agrees with its warning inventory.

No requested retained input was unavailable. Installed-binary attestation was
not attempted; the inherited pinned-producer/tool boundary still applies.
The complete repaired-source native audit, source binding and shape checks,
Lean/provenance checks and final regressions remain separate obligations.
