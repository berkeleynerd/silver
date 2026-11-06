# B3 independent core proof review — 2026-11-05

**Result: PASS within the assigned core proof scope.** No concrete defect was
identified in the native filter model, arbitrary-callee interpretation, exact
gate result, or loop admission/soundness transfer. The semantic connection is
carried by the existing loop-link interface. The assigned actual-source and
endpoint checkpoint remains necessary and is not claimed complete here.

## Identity and exact inputs

- Reviewer: independent subthread `/root/assess_inherited_blockers`.
- Selected model/effort: GPT-6 Astra, Extra High. Runtime settings were not
  independently exposed; no runtime confirmation is claimed.
- Review interval: 2026-11-05 10:28:26–10:31:54 UTC, 208 seconds to the recorded
  clock checkpoint at report finalization. Token and cost measurements were
  unavailable. Retained tool times below are distinct from reviewer elapsed time.
- Authorization: the lead assigned a bounded read-only architecture review
  within the owner-authorized repair round. Only this report was written. No
  builds, proofs, infrastructure changes, GitHub actions or agents were started.
- Exact review target: the frozen working snapshot in
  `/home/canto/src/github.com/berkeleynerd/silver/tmp/counted-bound-repair`,
  subsequently committed unchanged as
  `f03ca06c3e0c47edcb777cdd697dbd21b49e56d6`, based on
  `71911ad04995842720a1e60dae50a3ac94e76544`.
- The author confirmed the snapshot was frozen. The reviewer independently
  matched the supplied SHA-256 values before reading downstream connections.
  The commit diff whitespace check passed; no Lean source edits remained at the
  final Git-status check.

The seven primary proof inputs, all under `proof/Silver/`, were:

| File | SHA-256 |
| --- | --- |
| `PredicateBodyAdmission.lean` | `bf9ca9f90fd89538230a6a7d9a603afe7872079c8814508b9880c90c94c04423` |
| `PredicateCountedBoundModel.lean` | `b39beff7cc88e02b3792d1bbe3582bf36b0ea69972970e6c58c856c9c7a468fc` |
| `PredicateCountedBoundSource.lean` | `f67b56d30831566c369f00c661dd921a4c49675c7451df3a760ad5838928930b` |
| `PredicateLoopHelpers.lean` | `9a854aec8f04896d5cb6dc91a5e9c22a39b6933a0e53b80ec1a04023b0ee8f17` |
| `PredicateLoopImports.lean` | `cb62b9433824e54efdf749fadf27b08716296dd0d24746d60080f2e24fc47d6e` |
| `PredicateLoopNative.lean` | `f01bd1d6d79815678ac48417cf11b3f100bd271b005bf140f22a4510cdbc6788` |
| `PredicateLoopProperties.lean` | `805989ff0981da093af1f071d367d775aedbb19558b297ef8a9ddf77eea8b09e` |

Supporting inputs included the committed `tests/test_counted_bound_review.py`
(`08cdecb325be133fca334a3aab4f3924d7b1bd48d3fd40474e854e00aa575004`), existing
array/flow/scalar definitions, loop properties, implementation equations,
source requirements/candidate/checks/bridge, and retained evidence. The native
`src/silver_output_profile.adb` snapshot has SHA-256
`88cfb89fb4d4970df7a8a88740655e556d47758330108be9e35556d4f40e7c1b`;
the reviewer verified this also equals the file at the previously reviewed
native B3 commit `6f6723c7e8`. Its still-unstaged copy in this worktree is not
part of the new proof commit.

## Exact filter and helper meaning

The model filters only the active metadata list by `Binding.mutable`. Native
scratch storage is represented by a count and indexed items. `append_active`
proves that incrementing the count and then copying the complete binding adds
exactly one active entry. `filterFrom_active` lifts this through the ordered
fold, including the empty input and empty initial scratch cases. Whole bindings
are preserved, including offsets, bounds, component bounds and relative order;
there is no rebasing to the filtered list's positions.

The native `for Index in 1 .. Context.Array_Names.Count` traversal corresponds
to that active-list fold. Its rendered condition and increment/copy operations
match the native source. `countedArrays_valid` obtains capacity, per-binding
validity and ordered disjoint offsets by filtering the original valid metadata.
Finite native arithmetic and indexed accesses still require native verification;
they are not silently justified by the unbounded mathematical scratch type.

`Command.eval` interprets the whole helper: build the flow overlay, filter from
empty metadata, call the scalar reader on the filtered metadata, reject a zero
gate cursor, otherwise call the original scalar wrapper with the original
context. The rendering includes the same filtering operations, gate call and
return branch, plus the exact declarations and native invariants. Initializing
the model's gate field to `invalid` has no observable effect because the gate
command assigns it before the finish command reads it.

Both native calls omit `Initials`, so their default is the all-zero
`Empty_Values` table. The Lean empty initials list has exactly this zero-extended
meaning through `ArrayBindings.initialValue`. The proof explicitly establishes
`ValidInitials []`; it does not add an `InitialsFit` or initialized-prefix premise
to arbitrary native calls.

`eval_meaning` is quantified over arbitrary `FlowReaders.Calls` with the inherited
pointwise meanings and an original wrapper satisfying `ScalarRefinement`. It
proves every callee domain needed here: legal text/position/context/flow, valid
overlay names, valid mask, valid filtered metadata, and empty initials. It then
uses those meanings to derive equality with `readCountedBound`. The helper's
`Refinement` requires equality with this complete body evaluation on the legal
domain. This is stronger than the native postcondition that successful results
equal the original reader: that postcondition alone would allow arbitrary extra
rejection, while the new body equation fixes the gate's actual decision.

`Checked` separately requires the uniquely extracted ordinary function body,
implementation header, declaration contract and `No_Inline` pragma. Inspection
found the rendered tokens faithful to the reviewed native helper. These checks
must be instantiated against the final authoritative source; a pin change or
postcondition proof alone would not establish the required connection.

## Loop transfer and semantic propagation

`readCountedBound` returns the original full-metadata parse when its gate accepts.
`readCountedBound_original` proves that exact equality whenever the returned
cursor is nonzero. Thus endpoint expressions, bounds and symbolic array
identities are preserved. Neither the gate's filtered parse result nor a
reconstructed interval is substituted for the original result.

Both counted-bound calls in `loopHeader`, the native loop model, and the loop
renderer change together. `loopHeader_readings` obtains nonzero endpoint cursors
from successful header parsing, rewrites through `readCountedBound_original`,
and applies the existing scalar-reader soundness theorem using the original
array metadata. Cursor bounds are supplied by `readCountedBound_bound`.
Existing loop-bound boundedness, inner-flow validity and downstream soundness
therefore use the same endpoint readings as before, with the added admission
gate. The array-foreach branch remains separate.

The complete nonsyntactic propagation was inspected:

1. `LoopNative.Links.readScalar` now requires the original scalar refinement
   and the new complete `CountedBoundNative.Refinement` for `imports.readScalar`.
2. `ImportsMeaning.of_inherited` invokes `wrapper_meaning` with the legal loop
   scalar domain, obtaining `readCountedBound` meaning. Domain-preserving
   totalization retains every legal native call.
3. `model_links` supplies the matching witness using `eval_meaning`; it does not
   merely assert that a restricted checker exists.
4. Existing `Implementation.Definitions.loopLinks` feeds `body_helpers` and
   `model_body_helpers`. `Implementation.model_definitions` uses those links
   for the body/loop equations and sizing witness.
5. `Predicate.SourceBridge.InterpretedSource.definitions` already carries that
   strengthened structure to interpreted membership and executable
   correspondence. No new top-level `Calls` field is required for this helper.

The downstream implementation/source-bridge chain was reviewed statically.
Compilation of its final integrated endpoints is still required; the focused
audit below does not cover `PredicateEquations` or `PredicateSourceBridge`.

## Evidence and pending checkpoint

Retained records were read under
`/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/`.

| Run | Inspected result |
| --- | --- |
| `20261105T101659-603264e8ee68` | Linux x86-64, Lean 4.34.1; focused build of `PredicateCountedBoundSource` and `PredicateLoopHelpers` succeeded, 254 jobs, 702.861 s build phase. Fresh audit passed for 38,917 declarations with only `propext`, `Classical.choice`, `Quot.sound`, 8.638 s audit phase; recorded total 725.339 s. All seven reviewed proof modules appear in its module list. |
| `20261105T092808-028faf0bb408` | Focused native helper proof reports all 24 checks proved, including filter invariants, indexed accesses, and scalar/original-wrapper call preconditions. This is not a complete native proof/audit checkpoint. |
| `20261105T094428-7555bb86cd0f` | Four committed test methods passed in 29.069 s: 21 constant-array bound exclusions, full-route scalar snapshots/constant foreach and interleaved mutable-array offsets/reverse loops, plus native admission of a 4096-byte source with at least 140 nested loops under an 8 MiB stack. The stack method itself tests admission, not compilation/execution of that nested source. |

The Lean evidence is incremental (`clean_build: false`) with no separate kernel
recheck. A fresh foundation-only audit is recorded; a clean complete rerun is
not claimed. The review introduced no axioms or source changes.

The lead's assigned integration must still:

- Add/import `CountedBoundNative.Checked` in `PredicateSourceRequirements.Checked`
  and construct the corresponding candidate evidence for body, header, contract
  and `No_Inline`.
- Refresh the independently extracted `PredicateLoopCandidate.candidateBody`,
  whose two counted-bound calls still name `read_scalar_in_flow` in this worker
  tree, and preserve its proof against the updated renderer.
- Refresh the shared actual-source shape/pin/certificate and complete the source
  correspondence and integrated endpoint builds, including the existing model
  definition/witness chain above alongside the other repair changes.
- Complete required native proof/audit and final guarantee/resource evidence,
  with the intentional language restriction documented explicitly.

These are known assigned obligations, not unexpected findings. No additional
semantic field or witness requirement was found beyond the strengthened loop
links already implemented and the planned checkpoint. The scoped PASS does not
complete B3 or its parent repair issue.
