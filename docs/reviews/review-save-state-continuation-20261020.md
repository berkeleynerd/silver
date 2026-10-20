# Review: fresh save state and conditional continuation bounds

2026-10-20 UTC, Linux x86_64, owner-authorized research #119 / #153.
**Accept the conditional component results after repair of one medium finding,
M1 / [#154](https://github.com/berkeleynerd/silver/issues/154). No material
findings remain in this review's scope.** Complete save capacity, all-prefix
table contracts and #119/#153 completion are not established.

The aggregate review target is `057a18abff22617d4adb4d9ed38398ed5a61966d`.
The focused repair target is `af092f2618b893e36907e133a6ea602a95329f28`.
The isolated review worktree starts at the aggregate freeze; repair code and
results were read and executed directly from the repair's Git blobs, without
changing implementation files in this worktree.

| Input | Exact frozen commit |
| --- | --- |
| Executed missing-state collector | `f3baf9cdfa068496a4034c16f77e9fbcd756420a` |
| Collector, replay and recognized-custom-block comparison packet | `8df43caae203eba9439b8272d936c04aa521b92f` |
| Native no-resize prefix packet | `c41ec855a407e3424c5db1bb45cf019a4224c891` |
| Attempt/status/prover growth packet | `bc1c5adecabc81c8d6c9c063d6c3470f8e1ac127` |
| Fresh capture retention packet | `d0ae63f72a0b2918c5b1078bd2d3ab99b9b3b768` |
| Original numeric join | `680f75dd24877a18c61298571f5678bf693cd88b` |

Reviewed paths comprise the three research notes
[native prefixes](../research/retained-why-save-hashtbl-prefix.md),
[later growth](../research/retained-why-save-attempt-growth.md), and
[integrated state join](../research/retained-why-save-state-join.md), plus the
five evidence directories `retained-why-save-{missing-state,hashtbl-prefix,
attempt-growth,state-capture,state-join}-20261020/`. Inputs include their
retained source excerpts, instruction bodies, manifests, source/layout witnesses,
collector/comparison/replay implementations and saved results. The executable
identity is `7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`;
the native witness checks use this exact retained Linux image.

The Oracle, AGENTS.md and applicable development review rules were read.
The accepted [Round 27 review](review-save-entry-operational-20261020.md),
operational transfer, forest/B/J/L certificates and ordinary-ending/native
effect contracts are dependencies at their existing conditional scope. Their
successful old observer, binder, alpha and native/proof analyses were not
repeated. The parent's exact-freeze integration checks are reused for the
67-file correspondence and unchanged 94 native aggregate pins; those counts
are parent-reported checks, not a second reviewer execution.

## M1: fresh mutable state and raw inputs were not fully joined — fixed

At the aggregate freeze, `state-join/join.py` checked fresh attempt totals but
imported `prover_domain0_upper` from an older process without checking the new
structural prover-key domain. That domain directly controls the smaller P+2
allowance. It also compared only the derived `save-missing-state.json` identity
between the graph-comparison and replay records, leaving their overlapping
raw block/root identities unchecked. An immutable logical graph match cannot
establish either mutable-state equality or equality of other consumed bytes.

The [negative probe](review-save-state-continuation-20261020/negative-provenance-freeze.json)
replaced the saved replay block/root hashes with zero hashes through the parser
seam. `join()` returned exactly the retained result. No capture or implementation
file was changed. Independent [fresh-state checks](review-save-state-continuation-20261020/fresh-state-check.json)
found domains **1/1/1/1/2**, distinct per-goal tables and initial membership
coverage in the actual manifest-bound projections. All actual overlapping
identities agree. This was a validation omission, not a demonstrated incorrect
numeric result or damaged capture.

Repair `af092f2618b893e36907e133a6ea602a95329f28` validates structural
name/version/alternative bytes, distinct goal IDs/table pointers and per-goal
membership counts before importing the old bounds. It requires all overlapping
comparison/replay identities to agree and rehashes every named fresh input.
The repair tests reject an enlarged prover domain, redistributed membership
counts, aliased goal tables, mismatched raw identities and changed capture
bytes. The original negative probe now rejects. Removing the added fresh-state
certificate from the repaired result reproduces every original result exactly.
The [repair check](review-save-state-continuation-20261020/repair-check.json)
records this disposition. #154 is the existing finding record; no additional
finding issue is needed.

## Conditional argument assessment

The native no-resize argument uses separate scalar size and binding visits,
including duplicate bindings. Its induction excludes the first possible resize
using `size0 + additions <= 2*capacity`, or the explicit clear-before-add
variant. The retained `add` and absent-`replace` instructions put publication,
size increment and threshold testing after the allocation poll with no
intervening dispatch. `caml_modify` can request collection, but does not dispatch
the save on these paths. The immediate `Empty` value excludes the urgent-GC
branch of `Array.fill`, supporting the atomic-clear claim under the retained
native/runtime premises. This is narrower than treating arbitrary source
stores as atomic.

The stale-head problem in absent `replace` is addressed by the nonreturning
nested-save protocol and absence of an internal receiving catch. A higher catch
can continue with committed nested writes, but cannot resume that interrupted
mutation. Traversal clients may catch exceptions; unchanged old `next` links,
finite entry chains and globally charged additions still bound a reached
traversal. Client cost, key/payload behavior, resources and the exclusion of a
suspended pre-cut link mutator remain required premises. The result does not
assert a general interrupted-resize theorem.

The growth argument correctly distinguishes the retained finite selected pair
key domain K from the normal 459 scheduler-entry envelope. Caught signal-save
`Not_found` can make a tried pair appear untried, so the latter is not an
interrupted scheduler bound. The selected constructors and persistent-key
invariants support K+e binding growth and P+e shared prover-ID growth under
the table and continued signal contracts. One global e<=2 budget applies from
the cut through ending; it is not renewed per save or per goal. Missing-key
handlers consume the relevant exception rather than replaying one exception
through multiple fallback handlers. Stale misses during the prover-ID `Exit`
search are included. Constructor prefixes abandoned after incrementing the
attempt counter remain a separate, explicitly unknown obligation.

The collector preserves complete byte strings, duplicate table entries, scalar
sizes, capacities, finite map structure and Buffer backing. Failed sections
remain unknown. The replay pins the executed collector/observer sources and
compares decoded files byte-for-byte. Graph correspondence preserves ordered
logical declarations, sharing, tags, sizes and immediate/data bytes under a
bijection. The custom-block exception recognizes only the pinned Zarith
operations table and independently derived load biases; every byte after that
operations pointer remains exact, including unused payload bytes. Unknown
custom operations are rejected. This transfers the accepted conditional
immutable B/J/L projection, not mutable backing or every future execution.

The capture packet preserves the separate registration and first-inline phases,
original misleading runner/plan wording, startup guard observations and exact
managed-run identities. Its streaming verification/extraction code checks exact
regular-file membership, identities and safe names before extraction into a new
root. Existing archive verification and extraction successes were reused;
packaging is not treated as a native source-refinement proof.

The numeric result remains **203 of 206 sufficient no-resize guards passing**.
The three failing theory-cache guards are **48/48/43 > 32**. Counting empty
theories is required by `update_file_node`'s sibling traversal. These failed
sufficient guards establish neither an actual overflow nor a tool defect.
The five later attempt upper bounds remain **208/173/108/12/9**, and shared
prover-ID additions **6/6/6/6/7**. The measured Buffer is 1,088 bytes at position
zero; the nonempty dictionary is retained. Numeric success does not set the
native continuation, key/payload, traversal-client or complete-save flags.

## Verification, scope and reporting

| Reviewer check | Result | Elapsed |
| --- | --- | ---: |
| Original provenance negative probe | Confirmed M1; actual overlaps separately agree | 0.116285450 s |
| Manifest-bound fresh-state check | Five prover domains, table distinctness and initial membership coverage agree | 0.075826981 s |
| [Native prefix checker](review-save-state-continuation-20261020/native-prefix-check.json) | 25 source excerpts, 20 native bodies, 4,316 instruction bytes and guard boundaries pass | 0.351329771 s |
| Exact repair delta | Three focused tests, original negative probe rejection, new result and unchanged old arithmetic pass | 0.239985098 s |

These were bounded offline checks on Linux x86_64. No target, capture,
disassembler, solver, proof, Lean or old observer/binder/alpha execution was
started. No source fetch, GitHub write or CLI-memory update was performed by
this reviewer. The review-owned files are this report and its evidence folder.

Reviewer selected setting: **GPT-6 Astra / Extra High**, explicitly confirmed
by the parent as its spawn selection. Runtime model/effort confirmation and
token/monetary measurements are unavailable. The first timed checkpoint was
09:25:37 UTC; the repair-check checkpoint at 09:32:00 was 383 seconds later,
including reading, reasoning and coordination, not just checker execution.
The intended result was a bounded critical review; the result is conditional
acceptance with M1 repaired and unchanged numerical bounds. This single round
does not support a causal comparison of model quality or cost efficiency.

The remaining obligations are unchanged: theory-cache resize/interruption,
whole-continuation native/signal and key/client contracts, abandoned-constructor
counter headroom, successful lookup coverage, restored-path preservation,
serializer/scalar/Format lengths and storage, native allocation/hash/string and
file/error/exit composition, followed by the wider #119 obligations. They are
open research work, not new findings requiring completion in this review.
Oracle, current admission and tool pins are unchanged; production #88–#94
remains unstarted and draft PR #121 remains unmerged. The subthread harness
returned no local goal; the parent confirmed its active #119 goal. This report
does not change that goal's status or treat the subjective 80–85% estimate as
validation.
