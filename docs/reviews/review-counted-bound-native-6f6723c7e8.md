# B3 / #311 independent native gate review — 2026-11-05

**Result: PASS for the bounded native design.** No concrete metadata, lookup,
admission or frame-lifetime defect was identified. This review does not claim
the pending Lean/source correspondence, full-route tests or final integrated
resource/proof checkpoint has passed.

## Exact inputs and review record

- Reviewer: independent subthread `/root/assess_inherited_blockers`.
- Selected model/effort: GPT-6 Astra, Extra High. Runtime model/effort were not
  independently exposed. Token/cost measurements were unavailable.
- Clock interval: 2026-11-05 09:42:42–09:46:54 UTC, 252 seconds to the recorded
  clock checkpoint before writing this report.
- Owner authorization and repair scope were supplied by the lead; this is a
  read-only implementation review, with only this report written.
- Exact target: `6f6723c7e8b2085db268174a9bd8469fb907fa72`, specifically
  `src/silver_output_profile.adb:2539–2577` (`Read_Counted_Bound`) and
  `:4624–4626` (its two counted-loop call sites).
- The source was read using `git show`; the working native file still matched
  that commit, SHA-256
  `88cfb89fb4d4970df7a8a88740655e556d47758330108be9e35556d4f40e7c1b`.
  Commit whitespace validation passed. Concurrent uncommitted proof work was
  excluded from the reviewed target.
- Supporting inputs: existing scalar/array lookup and parsing code, array
  metadata validity, declaration uniqueness, body-context construction, the
  focused native proof log, and the separate B3 test draft identified below.
  Earlier B1/B2/B5 reviews are unchanged.

## Admission and name resolution

Both counted-loop endpoints use the gate, after optional `reverse` and before
index-bound construction. The `for ... of` branch still resolves the original
array metadata directly. No initializer, ordinary scalar expression or other
array-read call site was changed.

The gate retains only metadata entries whose original `Mutable` field is true.
Its scalar overlay, scope mask, source position and elaboration mode are the
same as the existing reader. An attempted direct constant-array read therefore
has no array target in the gate. Grouping and arithmetic recursively pass this
filtered metadata, so wrapping the read does not evade the restriction. Array
reads inside array subscripts remain excluded by the existing scalar parser.

Deleting array entries cannot expose an earlier same-named array in an actual
admitted declaration context: `New_Name_Allowed` at `:1298–1308` rejects
duplicates across all binding kinds. This reachable-context uniqueness is a
necessary part of the reasoning; `Valid_Metadata` alone does not express it.
Scoped loop indexes intentionally hide outer arrays because scalar lookup
takes precedence in `silver_scalar_expressions.adb:224–232`, identically in
both parses. A hidden scalar used as `A(1)` still leaves invalid trailing
indexing syntax; removing the outer array cannot convert it into a legal
constant-array read. The new loop binder's existing mask is preserved in both
parses. Scalar snapshots stay in the unchanged scalar overlay.

On gate success the wrapper returns **the original full-metadata reader's
result**, not the gate's result. It consequently preserves bounds, staticness,
operand count and consumed position for every successful return. Even if the
gate ever accepted a parse rejected by the original reader, the wrapper would
still return rejection. The partial-parse interface does not bypass the
counted header's unchanged range-delimiter and `loop` checks.

## Metadata and stack reasoning

The filtered metadata is an order-preserving subsequence. Each survivor is
copied as a complete `Binding`, preserving source-name positions, index bounds,
element offset/length, mutability and component bounds. Only its metadata slot
number changes. No element storage is repacked, and unused metadata slots are
ignored because lookup is bounded by `Count`.

The loop invariant `Arrays.Count < Index` makes the next append fit the original
capacity. Original offset ordering plus the invariant on the last selected
entry preserves `Valid_Metadata` across skipped constants. Keeping offsets
unchanged is correct; body reads use component bounds, and original scalar
elaboration defaults are the same in both reader calls. There is no mutation
of `Context.Array_Names` or the caller's facts.

`Overlay` and filtered `Arrays` belong to the explicitly non-inlined wrapper.
Scalar parsing cannot recursively enter `Loop_Body`, and the wrapper returns
before the caller descends into the loop body. The extra scratch allocation
therefore contributes to the currently active bound-read peak rather than to
every retained recursive loop frame. The subsequent original-reader call can
overlap the wrapper's scratch lifetime, so a small additional peak is real;
this review does not quantify ABI frame sizes or replace the final stack run.

## Evidence and remaining integration

I inspected managed run `20261105T092808-028faf0bb408`: its focused
`Read_Counted_Bound` proof reports **24 checks proved**, including termination,
metadata invariant initialization/preservation, append bounds and call
preconditions. This is focused native evidence, not the complete compiler
native audit or proof that the new membership rule is source-linked in Lean.

I also inspected the separate draft
`tmp/counted-bound-repair/tests/test_counted_bound_review.py`, SHA-256
`08cdecb325be133fca334a3aab4f3924d7b1bd48d3fd40474e854e00aa575004`.
Its four methods cover 21 direct/wrapped lower/upper/reverse rejection cases,
snapshot and foreach full-route controls, interleaved constant/mutable metadata
with original constant reads afterward, and deep nesting under an 8 MiB stack.
Those test outcomes were still pending when this review was prepared; no pass
is inferred from their source. Cheap scalar-shadow/own-binder-mask regressions
were suggested to the worker as additional coverage, not as found bugs.

The next proof/source integration must model the actual gate-plus-original-read
composition, including the filter's meaning, rather than assuming the old
reader equation still describes `Loop_Body`. That work and final review are
already assigned to the lead/workers. Language/catalogue wording must retain
the narrow scope stated here: direct constant-array components are excluded
only in counted-loop bound expressions; snapshots, mutable-array reads and
constant-array foreach remain available. No new permission step or extra
validation infrastructure is requested by this review.
