# Source-tree structural guards review — 2026-11-06

No unresolved component finding remains after the selector-prefix repair.
The integrated guards are ready for the required complete Lean/source/module/
axiom checkpoint. Focused acceptance does not establish final integrated
assurance; native applicability and the final evidence record remain pending
at this review boundary.

## Scope and exact inputs

Owner-authorized [#314 scope](../source-tree-structural-guards.md), published at
`584e230e310c851b7b74791e9314a8e974dbcb21`, follows the retained
[Med-1 finding](interim-review-0d30841795-20261105.md#med-1-some-source-check-tree-languages-have-no-precedence-guard-since-before-baseline).
The review covers the five named tree languages, their inventories, controls
and source wiring; it does not reopen the broader external review.

| Component | Reviewed source |
| --- | --- |
| Image scanner and FilesSplice | `55d3ea64bc98e04f184937698808c2e2393e3db1` |
| Predicate guards, including prefix repair | `3e515817c3a0848ee14473ebd3446b333980a1a9` |
| Combined integration | `92ab046be220177eb850be943791df57d87043dc` |

Independent Git comparisons confirm exact component bytes in integration.
Only three new guard modules and three source-wiring files differ from the
authorization baseline. Existing trees, evaluations, renderers, source bindings,
semantic endpoint definitions, Ada implementation and admission rules are
unchanged. The current project inventory is 641 modules.

## Semantic and inventory assessment

Rules were checked against the actual renderers and Ada RM
[4.1](https://docs.adacore.com/live/wave/arm22/html/arm22/arm22-4-1.html),
[4.4](https://docs.adacore.com/live/wave/arm22/html/arm22/arm22-4-4.html),
[4.5.7](https://docs.adacore.com/live/wave/arm22/html/arm22/arm22-4-5-7.html) and
[4.5.8](https://docs.adacore.com/live/wave/arm22/html/arm22/arm22-4-5-8.html).
Bare `not` requires a primary; mixed unparenthesized logical chains are rejected.
Both associations of the same Boolean operator remain accepted. Conditional,
case, quantified and declaration forms retain the required enclosing context;
orphan declaration, `begin` and `elsif` roots cannot pass as complete expressions.

Scanner arithmetic distinguishes primary, term and additive expression
positions. Its bare arithmetic requires source precedence and left association,
while explicit parentheses permit the corresponding alternatives. FilesSplice
checks every numeric/index child as well as predicate grouping. Command checks
recurse through actions, tests, sequences, branches and matching case-alternative
categories. The explicit `skip` sentinel remains part of this representation;
these checks do not assert a complete Ada grammar or case-coverage theorem.

The positive inventories cover all three scalar bodies and their runtime RHS,
all six scalar-helper bodies, five adapter expressions and all three fields of
the adapter function. Independent extraction matched all **21** named scanner
structural/consume commands to `currentTrees`. The actual FilesSplice expression
is checked recursively. Predicate proofs populate three new `CheckedSource`
fields; the scanner exposes its inventory/root theorem beside the unchanged
token checks; FilesSplice's proof populates `FilesSource.ActualSource` and
`actual_source`.

Discriminating controls prove equal rendered tokens for the rejected scalar
`not` grouping, scanner multiply/add and arithmetic-association alternatives,
and FilesSplice conditional/quantifier-boundary alternatives. Other controls
exercise nested malformed operands, wrong command categories and positive
same-operator Boolean nesting. They check guard results, not merely token
inequality.

## Finding and disposition

The first predicate draft used `primary` for selected/indexed prefixes. That
also admitted parenthesized conditionals and aggregates, which are not Ada
names: for example, a conditional scalar result could pass before `.after`.
The repair adds exhaustive `prefix` classifiers and uses them at selectors,
indexing and repeated selector operands in helper replacement and adapter body
updates. Controls now reject grouped conditional/name/aggregate prefixes and
accept function-call results and valid selector chains. Current trees needed
no changes. This finding is resolved in the reviewed predicate commit.

## Evidence and limits

Inspected immutable focused runs finished successfully: predicate
`20261106T163857-813cf8538291` audited 348 modules/95,856 declarations; Image
`20261106T163545-5268a6d953e4` audited 47 modules/11,226 declarations. Both use
only `propext`, `Classical.choice` and `Quot.sound`. They remain partial checks;
the lead owns complete integrated validation and retention of earlier failures.

The assurance, response, roadmap and task-record edits retain the interpreted
source premises and accurately limit coverage. Opaque identifier/type-name
tokens and fixed Boolean token leaves, including `PredicateLoopNative` and
`ImageModelFinishNative`, remain outside these guards. No verified general
parser or stronger semantic endpoint is claimed.

Selected reviewer: **GPT-6 Astra / Extra High**; runtime confirmation and
token/cost measurements are unavailable. Observed interval:
**16:31:31–16:42:42 UTC**, including coordination and source retrieval. The round
resolved the prefix-category finding and cleared integrated component review.
This reviewer launched no Lean, native, build or test job and changed only this
report. No CLI recall was updated.
