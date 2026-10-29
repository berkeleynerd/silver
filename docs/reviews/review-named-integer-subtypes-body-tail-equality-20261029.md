# Named Integer subtypes: Body_Tail equality repair — 2026-10-29

**Source/applicability verdict: no actionable source defect found; focused
native discharge confirmed. An evidence-retention defect was found and
corrected. The final complete checkpoints remain pending.** This bounded review
addresses #286 and draft PR #289; it does not
authorize merging or repeat the earlier feature/capacity review.

Selected reviewer: GPT-6 Astra / Extra High. Runtime model/effort confirmation
and token/cost measurements are unavailable. Substantive source and applicability
review ran 20:45:24–20:48:22 UTC (178 seconds), followed by report preparation.
Final source/pin and focused-evidence confirmation ran 20:55:05–20:58:59 UTC
(234 seconds, including retention-correction wait). The reviewer used the isolated
`tmp/subtypes-body-tail-review` worktree, based on
`b4c599520bfd785ec24364c1d0be1bc71addbf2a`, and edited only this report. No
proof, build, regression test or GitHub action was run by the reviewer. The
live harness returned no active goal.

## Exact inputs and scope

The implementation baseline is
`97312a790fb11a83a9607ad48ddab491711f2c3d`. The reviewed candidate was the
source-only working-tree change in `tmp/range-subtypes-native`, initially at
`8c3eeec12f2d25950f3e6883062cb54a33d291f1`. It was subsequently committed,
with the reviewed bytes unchanged, as
`d1c90fbbb68c6e85295a9c4402f3124a1b0a29d6`:

- File: `src/silver_output_profile.adb`.
- Baseline SHA-256:
  `241637c5043dc66776a4a9715e7703abb9602c6323fa0d12a5375959790e4f07`.
- Candidate SHA-256:
  `84779089d15b9e7990fd806de3a8965edfb5bdeacac2c02544cb0c9d28ba6a8a`.
- Delta: eight added lines, comprising six lines of Static ghost declaration,
  assertions and calls, plus two comment lines, in the final `Body_Tail` block.

Final integration target:
`6020416906b5fc3d2bd10d012e70937c80f0617c`. It integrates the same source as
`5e836b27d6` and refreshes only the two source-binding artifacts below. Compared
with the implementation baseline, these are the only changed files under
`src`, `proof`, `tests`, `scripts`, `samples` and `catalogue`.

| Final artifact | SHA-256 |
| --- | --- |
| `ReviewedOutputShape.lean` | `dbfbec6d594896b227dffb8cdec21c4b129b0ba7deb326b29c51aaa32bb3a1ad` |
| `OutputBodyCertificate.lean` | `3f9d06ae63a75479c101e8b3baf4f08a98c2615f97cf24818c88b701a6586ab0` |

Reviewed the exact diff, `Body_Tail` and `Body_Tail_Model`, `Valid_Body`,
`Valid_Flow`, the `Body_Scan`/`Scalar_Flow` representation, existing equality
lemmas, the relevant pinned SPARK rules, and the Lean source requirements and
dependency paths. The existing [integration review](review-named-integer-subtypes-final-integration-97312a790f.md)
supplies the established 555-identity regression reconciliation. Its feature
findings and original log reconciliation were not repeated.

## Equality and erasure

`Original_Tail` evaluates the original-input model only in a `Ghost => Static`
constant. Its precondition is exactly the unchanged enclosing precondition:
valid text, context and original scan. The model's valid-body postcondition
fixes its flow count to the context count, which the original valid scan also
has, satisfying the constrained `Body_Scan (Scan.Count)` declaration. The
model call has the same first variant component as the caller and rank 3
against the caller's rank 4. No new domain restriction is introduced.

At loop exit, the existing invariant equates the original-input model with
the current-result model; for zero iterations, `Result` is initialized to
`Scan`. This justifies the new `Original_Tail = Tail` assertion. On the final
nonzero-position path, loop exit supplies the stop predicate and the unchanged
model definition gives `Tail = Result`, already asserted before the new calls.
Projection of these two whole-record equalities gives respectively
`Original_Tail.Facts = Tail.Facts` and `Tail.Facts = Result.Facts`: precisely
the `Left = Right` preconditions of both `Lemma_Flow_Equality` calls.

The existing lemma proves `Same_Flow`, whose visible `Logical_Equal` body
checks discriminants, path fields, interval-array bounds and element bounds.
All three flows have the same fixed `Count`, including the `1 .. 0` null-array
case, so Ada array sliding creates no missing bound premise. The nested
`Lemma_Condition_Equality` supplies the established bridge rather than assuming
its conclusion. Read-only inspection of the retained failed-full
`silver_output_profile.spark` also found proved logical-equality annotations
and both existing lemma postconditions. These local results do not turn that
failed full run into a successful complete checkpoint.

The new final assertion exposes transitivity without replacing or weakening
the original Static postcondition. The invalid-result branch, executable
assignments/returns, admission rules, domains, contracts, variants, endpoint
statements and proof settings are unchanged. No assume, exemption, suppression
or new imported/project axiom is added.

Static erasure is explicit in the pinned SPARK 16.1 LRM:

- [exceptions.rst](../../references/spark/16.1/docs/lrm/source/exceptions.rst),
  lines 152–161, makes Static policy always `Ignore`; lines 230–231 say Static
  assertions are never checked. Named assertion policies cannot override this.
- [subprograms.rst](../../references/spark/16.1/docs/lrm/source/subprograms.rst),
  lines 2210–2211, classifies calls to ghost procedures as ghost statements;
  lines 2222–2228 give them the procedure's assertion policy and ignore aspects
  of an ignored ghost entity; lines 2239–2248
  give ignored ghost declarations, statements and completions no runtime effect.
- `Original_Tail` and `Body_Tail_Model` explicitly have `Ghost => Static`.
  `Lemma_Flow_Equality` has that aspect at source line 2255; both added
  assertions explicitly use `Static`.

Consequently `silver.gpr`'s `-gnata` does not cause these additions to execute.
In particular there is no runtime model recursion, extra `Body_Scan` storage
or copy, argument evaluation for the ghost calls, or added assertion failure
path. This uses the existing trusted GNAT/SPARK Static-erasure interpretation;
it is not a claim of byte-identical executable artifacts.

## Source correspondence and invalidation

`PredicateSourceRequirements` checks the exact `Body_Tail` specification,
including its Static model-equality contract, and its implementation header.
The imperative loop is connected to that contract by native proof. The same
requirements check the rendered `Body_Tail_Model` expression; that expression
and all header pins are unchanged. The repair preserves this division of
responsibility rather than replacing the imperative implementation with a
separate unchecked model.

Read-only extraction at the final integration target confirmed that
`ReviewedOutputShape.outputImplementation` equals the source's 38,765 tokens
(previously 38,698), with every other byte of that pin module unchanged.
`OutputBodyCertificate` exactly equals the unchanged generator's in-memory
rendering of the reviewed source; no proof or regression test was run for this
comparison. Full-source pin changes invalidate
`ComposeSourceCandidate` through its direct `ReviewedOutputShape` import and
`PredicateSourceCandidate` through `PredicateSourceRequirements` →
`PredicateSourceShape` → `ReviewedOutputShape`. Its
`PredicateScalarBodyCandidate` dependency also imports `PredicateSourceShape`
and is invalidated. The embedded source also
invalidates its handwritten binding/certificate and transitive consumers under
the actual Lake dependencies. These obligations remain required even though
the model rendering and public contracts did not change. Pin or certificate
regeneration alone does not establish source correspondence.

## Smallest justified regression refresh

For this source delta plus only the mechanical pin/certificate refresh above,
refresh these 46 identities on final inputs:

| Selection | Identities | Affected dependency |
| --- | ---: | --- |
| `tests.test_lean_source` | 12 | Current source byte policy, regenerated certificate parity, and actual proof-source/import scans. |
| `tests.test_platforms` | 16 | Shared fixture copies embedded Ada sources and the complete current Lean source tree. |
| `tests.test_output_integrity` | 17 | Shared `setUpClass` copies all current `src` and rebuilds the real compiler with fixture-specific installation paths. |
| `tests.test_silver.SilverIntegrationTests.test_tool_failures_and_source_changes_do_not_report_success` | 1 | Links current `src` and rebuilds the real compiler with fixture-specific paths. |

The first 28 replace the earlier affected-test reruns again; the additional 18
come from the original retained set. Static AST/source inspection matched all
46 identities to the unchanged checked-in 555-identity inventory. The resulting
plan is **509 applicable retained results plus 46 refreshed results**, with an
explicit replacement for each identity. No fresh success is claimed here.

The retained runtime admission, compiler behavior, application and sample
results remain applicable because every new source action is erased as above,
the executable operation sequence and all observable decisions are unchanged,
and test/application/library/toolchain/settings inputs remain unchanged. The
runtime tests do not consume the changed Lean pins. The rebuilt shared fixtures
above receive fresh coverage because they consume the changed source directly.
Other native probe fixtures build unchanged report/image/runtime dependency
closures; their use of the root source directory does not import
`Silver_Output_Profile`. Other Lean/tooling tests use unchanged audit modules,
bindings, Lake/toolchain inputs or synthetic source fixtures. No additional
affected family was found for this exact delta.

Retain the original full-suite outcome and both earlier 28-identity reruns as
history; do not relabel old results as fresh. Reconcile all 555 identities,
including any new failure or incomplete rerun. Additional implementation,
tooling, settings or fixture changes require assessment of their actual delta.
The [development reuse rule](../../development.md#proof-loop-and-validation)
composes regression results only: a fresh final compiler build and successful
complete native proof/audit and Lean/source/module/axiom checkpoints remain
mandatory. This repair creates no need for cold proofs, clean Lean rebuilds,
independent replay or another full regression run if the stated applicability
and complete identity coverage hold.

## Evidence boundary

The retained complete native run `20261029T165015-c6b111fb4f2a` failed the Static
`Body_Tail` result/model equality at `3414:20`; the other 15,384 proof entries
and 1,432 flow entries do not substitute for that missing obligation or its
unreached complete audit. The old complete Lean run
`20261029T161817-0a8089cd7dc3` was deliberately interrupted at 20:40:43 UTC and
cannot establish final-source correspondence.

At the initial source-review boundary, focused run
`20261029T203414-0517c9b1e3dd` was still active. Its retained raw events now
confirm native-tool exit 0 and successful termination at 20:53:55 UTC, after
1,179.240 seconds. It used one worker, the existing level-2 prover portfolio
and 30-second timeout, with `--limit-region=silver_output_profile.adb:3406:3477`
plus unit flow. All 62 proof and 287 flow entries are informational/proved,
including the complete `Body_Tail` postcondition; all 330 Why3 session goals,
including the aggregate, are marked proved. The 50 retained warnings comprise
5 array-initialization, 26 recursive-contract and 19 numeric-variant advisories.
There is no unresolved proof/flow entry.

Review found that the initial focused report archive at `5e6eea53e0` was empty
and its report-hash map was `{}`. That was a retention-script mistake, not a
failed native run. Corrective evidence commit
`f5369ea5698b049941876ee8d02a8bac251d9435` retains exactly `gnatprove.out`,
`gnatprove.sarif` and `silver_output_profile.spark`. Independently verified
all 12 [packet](../evidence/named-integer-subtypes-20261029/native-full-reuse/body-tail-repair/README.md)
artifact hashes, all three archive-member hashes, raw terminal events,
the 330-goal XML and actual report entries. The retained source hash is the
reviewed candidate hash, and all 143 captured tracked native inputs were
independently compared with source commit `d1c90fbbb6`, with no differences.
The evidence correction changed no source or run and required no proof rerun.

This confirms the focused repair only. It does not establish a complete native
coverage/provenance audit, final Lean/source/module/axiom assurance, final
compiler build or the planned 46 refreshed regression outcomes.
