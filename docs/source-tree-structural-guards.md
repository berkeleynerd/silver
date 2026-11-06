# Source-tree structural guards

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
build, native test or benchmark. Guard implementation remains unstarted until
the authorization record is on main. No CLI recall entry was updated.
