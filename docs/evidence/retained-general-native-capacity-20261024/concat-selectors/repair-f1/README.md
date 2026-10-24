# F1 / #214: require pure selectors for constructor-free absorption

2026-10-24 UTC. Narrow repair of the reusable maximum-query lemma in author
`bba92a0c0685cffdf8c9e179f6b36aafea81c4be`, following provisional independent
review `8ce1291b7a7cf9739666562f81cac09b73d8ad5f`. The exact original
[review](review.original.md) and [F1 counterexample](finding-F1.original.json)
are retained byte-for-byte. F1/P2 is confirmed at the reusable-lemma boundary;
it is not an identified production or current-Main defect.

The active parent README and MIN/MAX source dispositions now require every
completed condition and selector in the lemma to have TREE_SIDE_EFFECTS false,
with pure nonvolatile scalar leaves. The parent call rank is interpreted on
this corrected domain. The claim still permits unchanged literal-only
selectors, and preserves the original full-base-type extremum requirement.
Effect-bearing or unspecified conditions are outside this lemma; they need a
separate constructor transfer. This is no change to Silver admission.

The missing source join was GENERIC unused-capture handling. MIN/MAX's @0 is
a top-level capture, so genmatch.cc:2961–2991 does not mark it as a conditionally
captured selector arm. The early-out logic at4359–4400 is not a substitute for
a purity premise. The result generator at4668–4685 emits a conditional
fold_ignored_result plus COMPOUND_EXPR constructor when an unused captured
operand has TREE_SIDE_EFFECTS set. In the preserved counterexample the inner
selector's arms are pure literals; fold_ignored_result reaches its effectful
condition P (fold-const.cc:16323–16374), producing COMPOUND(P,E). A later
maximum-query fallback does not refund this request.

For the actual attached provider family, EQ/NE operands are literal zero and
fresh nonvolatile captured Integer declarations. Declaration references do
not evaluate their initializers. Lower-bound arms are literal/declaration
leaves; inverse comparisons, scalar arithmetic and selectors propagate their
operand effect flags. The applicable build1, PROCESS_ARG, build2 and build3
source is pinned in the new nine-span witness file. No operator in this
selected grammar adds a side effect, under the existing no-trapv/sanitizer
and scalar-IF/no-actions premises. Thus discarded selectors have
TREE_SIDE_EFFECTS false and the generated COMPOUND branch does not run.
Readonly alone is insufficient and is not used to establish this fact.

The callable parent `maximum` model now requires an explicit `Condition`
with a Boolean `side_effects` field and rejects true or omitted/unspecified
purity. Literal/var tags denote the already stated pure scalar leaf domain.
The finite pure-selector fixtures explicitly supply false. They are model
premises, not an inference of source purity from a tag. The new focused check
covers the repaired pure case in both maximum directions, the exact effectful
counterexample's rejection, an effectful outer condition, old opaque-condition
inputs, omitted purity, and a non-Boolean purity value. It also checks the
GENERIC omission truth table as a source-trace model, not GCC execution.

The original `current.json` and `packet-manifest.json` remain unchanged.
Their successful 2.216572-second check belongs to the exact original author
freeze, including its now-superseded generic claim. The new repair checker
verifies those original manifest inputs from that Git freeze and preserves
the original results, then checks only the changed purity obligation and
additional source correspondence. The repaired parent full-check entry point
uses `packet-manifest-f1.json` and would write a distinct `current-pure.json`;
it was not replayed. The focused repair result is `current-f1.json`.

No scalar or query coefficient changes: scalar event remains
520J+128s+368r+288m+344 raw caller bytes, and one receiving query pair remains
80s+568 for the attached pure partition. All size/layout, annotation,
occurrence attachment, nested-provider, slice, forced-capture, pointer,
backing/workspace and downstream obligations remain open. The global
once-per-Why-process e<=2/two-callback/three-save allowances are unchanged.
No Oracle, tool pin, production code, admission, issue, goal or memory write
was made in this subthread.

Selected author: GPT-6 Astra / Extra High, unchanged. Runtime confirmation,
tokens and cost are unavailable. First repair clock: 06:52:14 UTC; focused
completion/time and Linux platform are recorded in `current-f1.json`.
Intended result: resolve F1 without widening implementation scope or replaying
accepted checks. Achieved argument: explicit purity domain, attached source
purity and the omitted GENERIC generator join. Narrow independent acceptance
is pending. No native compiler, prover, Lean, generated matcher, predecessor
checker or original full selector check ran.
