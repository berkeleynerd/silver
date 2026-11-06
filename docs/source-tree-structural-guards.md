# Source-tree structural guards

**Implemented and validated on Linux, 2026-11-06; awaiting owner review and
merge.** The delivery below supersedes the initial planning status.

## Authorization and scope — 2026-11-06

After the completed Lean optimizations and instruction to proceed with the next
regularly scheduled unit, the owner explicitly selected **“#314 structural guards
(recommended from our earlier order)”**. This follows the earlier ordering,
**“Let's implement our lean optimizations before we address 314.”** The
[dated memory](session-memory.md#2026-11-06--lean-deliveries-complete-structural-guards-selected-next)
records this authorization. [Milestone 18](https://github.com/berkeleynerd/silver/milestone/18)
contains the existing [#314](https://github.com/berkeleynerd/silver/issues/314)
follow-up as one cohesive proof-only work package. Keep it Backlog until that
record reaches main; implementation then follows the ordinary Ready/claim flow.

The [retained Med-1 report](reviews/interim-review-0d30841795-20261105.md#med-1-some-source-check-tree-languages-have-no-precedence-guard-since-before-baseline)
found a structural-check limitation, with no wrong current tree demonstrated.
The delivered qualification of assurance claims remains valid. Its prior trial
module is unavailable and did not cover FilesSplice, scanner wiring or a complete
build/audit; it is historical evidence, not the implementation for this task.

Add explicit, fail-closed category, precedence and association guards for exactly
these existing source-tree languages:

| Tree language | Required integration |
| --- | --- |
| `ScalarBodyNative` | Guard the full current scalar-body tree inventory and add the applicable field/proof to `Predicate.SourceChecks.CheckedSource`. |
| `Native.ScalarHelpers` | Guard the full current scalar-helper inventory and add its field/proof to `CheckedSource`. |
| `Adapter` | Guard the full current adapter inventory and add its field/proof to `CheckedSource`. |
| Image `ScannerNative` | Guard the current structural/consume command trees, including nested expressions, and add a standalone checked theorem beside the scanner source checks. |
| `FilesSplice.Predicate` | Guard the actual splice expression and wire its proof into `FilesSource.ActualSource` and `actual_source`. |

Use explicit constructor/category rules, rather than a permissive fallback that
accepts an unexamined expression. Check nested operands and command branches.
Preserve legitimate same-operator `and then` and `or else` nesting on either
side; this task must not require changing the existing trees to one chosen
Boolean association. Distinguish those cases from precedence-changing or
nonassociative arithmetic alternatives. Preserve explicit parentheses and the
source grammar's operand-category restrictions.

Current trees, evaluations, renderers, rendered tokens, authoritative source
bindings, semantic endpoints and admission rules remain unchanged. Keep exact
source/token/reconstruction checks and existing semantic/source premises. A new
guard strengthens the structural evidence supporting the interpreted-source
premise; it does not establish a verified general Ada parser or remove any
interpretation premise from an endpoint theorem.

## Completion criteria

1. Provide kernel-checked positive inventories covering every current tree in
   the five named languages, with the required checked-source/scanner/Files
   wiring. Keep the existing semantic bridge and correspondence endpoints.
2. Provide discriminating kernel-checked negative controls for wrong categories,
   precedence and association, including the scalar `not` collision and scanner
   multiplication/addition alternatives identified by Med-1, and suitable
   FilesSplice controls. Where the hazard is a token collision, demonstrate that
   the wrong tree renders the same token sequence while the guard rejects it.
   Positive controls must accept legitimate same-operator Boolean nesting on
   both sides. Controls must test the guard's actual rules, not only unrelated
   source-token inequality.
3. Obtain independent semantic/source review of the rules, full inventory,
   negative controls and actual wiring. Challenge missing constructors,
   permissive fallback cases, nested children and precedence/association
   boundaries; retain findings and their dispositions.
4. Pass one complete final Lean/source/module/axiom audit on stable integrated
   inputs, with every module and required proof accounted for and no unfinished
   proofs or project-specific axioms. Focused guard checks alone do not complete
   source correspondence or discharge the universal assurance requirement.
5. Establish native proof/build input applicability against the retained complete
   successful evidence. Refresh affected native evidence only when captured
   inputs changed or another concrete concern invalidates applicability. Run
   proportionate focused tests for module registration, source checking or other
   tooling actually changed; retain failed outcomes as failed. Follow the
   existing [proof-iteration workflow](proof-iteration.md), managed reservations,
   automatic CPU settings and host-memory policy.
6. Update the assurance record and #314 disposition accurately, retain exact
   implementation/review/evidence identities, and publish the completed PR for
   owner review. A later owner instruction is required to merge implementation.

## Limits and exclusions

Opaque fixed token leaves remain outside these tree guards. In particular, the
fixed Boolean token tests with handwritten evaluations in `PredicateLoopNative`
and `ImageModelFinishNative` retain their documented source/semantic review
limits. Keep those limits explicit; do not claim that this package guards every
operator hidden inside token leaves or every source-tree language.

No generic precedence/parser framework, broader proof/cache framework, Ada
implementation change, source-tree rewrite, Oracle amendment or language feature
is selected. This task does not start Boolean arrays #297, functions #298,
sample expansion #300 or deferred capacity work. Samples and mutation controls
exercise the checks; they do not replace the complete final assurance audit.

## Planning round

Routine planning selected GPT-6.1 Sol / High; runtime model/effort metadata and
token/cost measurements are unavailable. This round records the completed
performance delivery, the explicit owner selection and one bounded existing
issue under milestone 18. It changes documentation only and runs no proof,
build, native test or benchmark. Guard implementation remained unstarted until
the authorization record reached main. No CLI recall entry was updated.

## Implementation checkpoint — 2026-11-06

Authorization PR #331 reached main as `584e230e310c851b7b74791e9314a8e974dbcb21`.
The integration branch is `fix/source-tree-structural-guards-20261106`, in
`tmp/source-tree-structural-guards`. Two bounded implementation workers selected
GPT-6.1 Sol / Extra High: predicate guards in `tmp/predicate-structural-guards`
and Image guards in `tmp/image-source-tree-guards`. Independent critical review
selected GPT-6 Astra / Extra High. These are selected settings; runtime
confirmation and token/cost measurements are unavailable.

The three idle proof workspaces were seeded from
`tmp/lean-chunk-reuse/.silver/linux-x86_64/proof`, after successful complete run
`20261106T150342-2526cc1a0ef4` on governed source `524dbfbd40`. The copy retained
all Lake metadata and ordinary/private/server object sidecars. The original
seed's earlier provenance and final 638-module audit are retained in the
[completed performance evidence](evidence/lean-incremental-throughput-20261106/integrated-complete/README.md).
Each workspace uses a symlink to that donor's pinned Lean installation, and
has its own writable proof cache. The normal managed runner still synchronizes
current sources, resolves dependencies and performs a fresh audit.

Concurrent focused checks reserve six of the host's twelve workers each;
per-process threads remain automatic. The final integrated run uses automatic
worker/thread settings. The existing 24 GiB per-process allowance is retained;
actual aggregate memory and host headroom govern concurrent scheduling.
At this initial checkpoint, implementation, focused checks, review and complete
final assurance remained pending; the following delivery closes those checks.

## Implementation and validation — 2026-11-06

Governed source `92ab046be220177eb850be943791df57d87043dc` combines Image
commit `55d3ea64bc` (integrated as `8b5d89384e`) and predicate commit
`3e515817c3` (integrated as `92ab046be2`). Exactly three new guard modules and
three existing source-record files change on the proof side. Existing trees,
evaluation, rendering, authoritative source bindings, semantic endpoints, Ada
implementation and admitted language remain byte-identical to the authorized
baseline.

The predicate inventories check three scalar bodies and their runtime RHS,
six scalar-helper bodies, five adapter expressions and the adapter function's
three fields. The scanner inventory covers all 21 named command trees and both
complete procedure roots. The FilesSplice guard checks the actual expression,
including numeric and byte-index descendants. The required three
`CheckedSource` fields, standalone scanner theorem and `FilesSource.ActualSource`
field carry these proofs. Kernel controls reject the reported token collisions,
arithmetic misassociation, mixed Boolean chains, malformed nested children and
invalid expression/prefix categories, while preserving valid same-operator
Boolean nesting on either side.

The [independent review](reviews/review-source-tree-structural-guards-20261106.md)
found one defect in the draft: using `primary` at selector/index prefixes also
accepted parenthesized conditionals and aggregates where Ada requires a name.
Explicit prefix classifiers and positive/negative controls repair it without
changing current trees. No component finding remains. Initial focused attempts
also needed ordinary proof-only repairs for opaque numeral rendering and Lean
constructor/binder name collisions; both failed runs remain labelled failed.

| Validation | Result |
| --- | --- |
| Complete Lean `20261106T164208-1614accb2e5e` | Passed: 641 modules, 128,705 declarations; only `propext`, `Classical.choice`, `Quot.sound`. Cached build 155.542 s, fresh audit 9.978 s, managed duration 175.393 s. 86 modules rebuilt; no clean build or independent replay. |
| Final source identity | All 748 captured shared inputs match the governed Git commit and final bytes; both Lean tool hashes match. Regenerated certificates passed parity and the complete source checks. |
| Source/certificate tests `20261106T164008-c4b3837f4da3` | All 16 methods passed, without skips, in 76.685 s. Includes real kernel acceptance/rejection fixtures. |
| Native applicability | Retained full run `20261106T145116-6582d1e5fcb5` (17,496 checks) and up-to-date build `20261106T145251-335323a924fa` remain applicable: all 2,586 native inputs, 143 tracked inputs/path set and 12 tools match. No native rerun. |

The [evidence packet](evidence/source-tree-structural-guards-20261106/README.md)
retains terminal run records, logs, focused outcomes, failed attempts and input
comparisons. Final Lean selected 12 workers and 12 threads per process
automatically, with the retained 24 GiB per-process allowance. This proof-only
change leaves compiler, test tooling, fixtures and samples unchanged; the
proportionate source tests and full Lean checkpoint add no claim to rerun the
whole application suite, macOS or hosted CI.

Implementation and independent source review completed between approximately
16:27 and 16:43 UTC; the complete audit finished at 16:45:04 UTC. Selected worker
and reviewer settings are recorded above and in the review. Lead runtime
model/effort and all token/cost measurements are unavailable. The review repair
closed the only consequential draft gap; there was no resource-exhaustion retry
or semantic/source rewrite. These timings describe this round, not a general
performance guarantee.

The package is ready for owner review. #314 and milestone 18 remain open until
the implementation reaches main under a later merge instruction. No later
language feature is started, and no CLI recall entry was updated.
