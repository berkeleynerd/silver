# Concat scalar-selector review checkpoint

2026-10-24 UTC. Independent critical review for #201 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort,
tokens and monetary cost are unavailable.

Exact author: `bba92a0c0685cffdf8c9e179f6b36aafea81c4be`.
**Provisional verdict: repair required for the reusable maximum-query lemma
(F1, P2).** The attached pure seed-provider scalar partition and its stated
local coefficients have no identified material accounting defect. The
general lemma explicitly permits arbitrary conditions and needs a purity
premise before this packet can be accepted as written. No author repair or
admission change was made by this reviewer.

The [receipt](../evidence/review-concat-selectors-20261024/README.md) binds the
twelve changed author files, twenty-one prerequisite anchors, retained source
and the accepted prefix review by exact bytes/SHA-256. All sixty earlier
general-native packet files are unchanged from prefix author
`fd44328b98f1a977d0cfdbb01aa161940124edcb`. Its accepted review
`000656e773c6eae24a673afeb5af05f200dc6723` remains immutable.

## F1 — arbitrary conditions invalidate constructor-free extremum absorption

Priority **P2**, restricted to the reusable lemma's scope. The claim at
concat-selectors/README.md:181–205 allows arbitrary completed conditions,
says no unary/binary/ternary nodes are constructed, and concludes that every
subtree containing a declaration returns the requested extremum E. The
MIN/MAX dispositions at source lines 4950/4961 repeat the constructor-free
claim. `max_value` itself does not visit conditions, but the recursive folder
must preserve effects when discarding an unchanged selector operand.

Use this synthetic native helper input, without claiming current-Main
reachability:

```text
T = base signed Integer32; E = INT_MAX
D = nonvolatile VAR_DECL of T, with the full T extrema
P = an already constructed side-effecting Boolean CALL_EXPR
Q = a pure completed Boolean condition
C = COND_T(P, literal_T(1), literal_T(7))
X = COND_T(Q, D, C)
```

The leaves satisfy the stated lemma. Its explicit allowance for arbitrary
conditions admits P. Both arms of C are unchanged by `max_value`, so
`max_value(C,true)` returns C itself (`utils.cc:4160–4178`). The declaration
D returns E. The outer query therefore requests `MAX(E,C)`, which commutes
to `MAX(C,E)` and reaches the extremum rule at `match.pd:4961`.

That source rule's unused capture @0 is C. It is an ordinary top-level
capture of MAX, not an arm captured conditionally inside the matched pattern;
the capture analysis does not force it to be free of side effects
(`genmatch.cc:2961–2991`). The GENERIC result generator explicitly emits:

```text
if (TREE_SIDE_EFFECTS(captures[0]))
    _r = build2_loc(loc, COMPOUND_EXPR, type,
                   fold_ignored_result(captures[0]), _r);
```

See `genmatch.cc:4668–4685`, together with its early-out logic at 4359–4400.
`fold_ignored_result(C)` follows the pure literal arms to P
(`fold-const.cc:16323–16374`). The result is therefore a newly constructed
`COMPOUND(P,E)`, **not E**. At least one binary request contradicts the
zero-expression claim. A later nonconstant-result fallback in the declaration
query does not refund this allocation. The analogous MIN rule has the same
issue. The exact source spans and trace are retained in
[finding-F1.json](../evidence/review-concat-selectors-20261024/finding-F1.json).

The actual attached scalar partition is already pure: its EQ/NE conditions
use fresh, nonvolatile base-Integer declarations and literal zero; its bound
leaves are completed literals/declarations, and arithmetic/selectors propagate
no side effects. Initializers are not replayed through these references.
Consequently TREE_SIDE_EFFECTS is false on its unchanged selectors and the
generated omission branch is absent. This counterexample does **not** refute
the attached `80s+568` query-pair coefficient or require changing Silver's
admitted programs.

Required repair: state an explicit side-effect-free condition/selector premise
for the reusable lemma, connect that premise to the actual attached source
grammar, and account for the GENERIC unused-capture generator in its source
argument/dispositions. Keep effect-bearing conditions outside this lemma
unless their separate transfer is derived. This is a proof-domain correction,
not permission to narrow admission. A focused correction/check is sufficient;
replaying successful predecessor or native evidence is unnecessary.

## Supported source partition and accounting

The selected NN>=2 Standard.String event has a dynamic operand and completed
input/Image providers or fixed low1 providers, with exact alias provenance.
This is an occurrence classification, not a restriction on all admitted
concats. The subcall precedes optional allocation-high replacement and does
not claim that the resulting slice shares allocation flags.

The Get_Known_Bound recursion stops at a fixed operand or the last operand;
its source rank is NN-j and it constructs at most s<=NN-1 selectors. Fresh
Length captures distinguish tests even for repeated source values. A surviving
selector spine is initialized into M and later endpoint references use this
declaration cut. G is a fresh aggregate declaration distinct from M and the
incoming bounds. Constant contraction can reduce a grammar without causing
arbitrary initializer replay. The scalar IF lowering and relaxed
Force_Evaluation source gates preserve this pure grammar.

Ityp/Artyp are base signed Integer32, including Var_Length. Input low/high
leaves remain base Integer; Image's last high may require a same-width
Natural-to-Integer conversion. No runtime nonnegativity removes these native
barriers. The nullable low and high tests are two separate EQ nodes over G.
Each may independently invert and swap its arms; no shared-test-pointer
assumption is made.

For dynamic L, `L+(G-1)` first constructs the inner G+(-1). Under undefined
overflow the two independent variable parts prevent handwritten association.
Under wrapping overflow, association constructs L+G once and then builds
the outer +(-1) without another fold (`associate_trees`, 901–1061 and
11458–11663). The old inner arithmetic is discarded but still charged. The
low1 case retains the accepted NON_LVALUE candidate before wrapper removal.
Thus the two high source entries fit four constants, two unary and three
binary requests; the two overflow modes are not conflated.

Each selected-low/nullable selector costs at most its initial comparison,
one inverse comparison and one ternary. Equal arms contract. Distinct test
capture identities exclude repeated-condition rules; leaves are not Boolean
values merely because some are positive at runtime. The G==0/zero/G special
case is covered by the handwritten comparison helper. The tempting generic
comparison/minmax rewrite at match.pd:6869 is GIMPLE-only (6859–6962).
No selected replacement duplicates a capture into multiple result uses.

With the F1 purity premise made explicit, the maximum-query induction is
valid: an all-literal subtree returns unchanged; a changed child supplies
the full same-type extremum, which absorbs the other pure unchanged subtree
before conditional distribution. For s selector occurrences and d declaration
leaves, calls are at most 2s+1 and constant requests at most d+s<=2s+1.
There is no claim for a differing constrained extremum, changed signedness,
SAVE/COMPOUND/call leaf or effect-bearing selector.

M cuts off the selected-low initializer during high queries. The ordinary
high has at most five maximum-query activations; a nullable last bound adds
two, and an Image conversion adds one. Arithmetic children become constants
with overflow flags retained; the caller accepts only nonoverflowed constants
and otherwise uses its existing type extremum. Contraction to G reuses the
accepted immediate aggregate query; contraction to an original input bound
uses its accepted wrapper/SAVE cut. These alternatives support the query-pair
allowance of 2s+11 constants and four unary nodes for the attached pure domain.

The literal occurrence count satisfies J<=2s+4+5r: at most s tests and s+1
literal low leaves, conservative repeated low/high roots, high's unit literal,
two null-test zeros, last low and an unreduced trailing-empty subtraction.
This is not a finite arity cap. The audited local exports are:

| Projection | Bound |
| --- | --- |
| Constants / unary | 13J+4+2r / 2+r+m |
| Binary / ternary / selected-low declaration | 2s+4r+3 / s+2r / m |
| Scalar raw caller bytes | **520J+128s+368r+288m+344** |
| One receiving low/high query pair | **80s+568** |
| One scalar event plus that one query pair | **520J+208s+368r+288m+912** |

Source events and receiving type-query occurrences remain different owners;
copying a type cannot silently share a query charge. The optional debug-bound
declaration alternative is covered as a query input, not priced as an extra
M declaration by this scalar event. Future receiving-type elaboration must
retain that ownership along with metadata, provider initialization, original
objects, allocator/cache backing and native workspace. No global Cs/Ca
coefficient or complete scalar/type multiplicity is established here.

The two path_guards.adb expressions are valid source applicability witnesses:
Work/Original retain input-derived bounds despite Work's byte assignment;
the repeated-input concat can retain the nullable high while its equal low
arms contract. Neither sample was compiled and neither proves universal
capacity.

## Evidence, timing and handoff

One independent offline audit passed on Linux x86_64 in **1.995354 seconds**
at **06:45:53.213433 UTC**. It binds 26 complete sources, 36 authored spans,
five additional inspected spans and 364 authored matcher forms to exact
source locations; checks the 15-state/18-edge rank; and corroborates 256
selector summaries, five chains, 65,856 literal-extremum pairs, 6,810 retained
operand cases, 4,160 high-algebra cases, 72 coefficient cases and 144
independent condition-polarity cases. It imports no author checker or parser.
This successful pure-model/identity audit is **not** a semantic acceptance of
the overbroad lemma.

The subsequent generator inspection identified F1. A focused source receipt
added six relevant spans and the counterexample at **06:48:41.014853 UTC**;
the earlier successful audit was not rerun. First review clock was
**06:40:04 UTC**, making **517.014853 seconds** through that finding receipt.
Report/commit preparation follows. Selected reviewer was Astra Extra High;
runtime confirmation, tokens/cost and pre-clock elapsed time are unavailable.
Intended outcome was bounded acceptance or a concrete defect. Achieved:
confirmed scope defect with a minimal purity repair and an explicit unaffected
attached partition.

The author's single 2.216572-second check and 13,132 finite selector queries
remain reused evidence, not a universal proof. No author/predecessor checker,
compiler, prover, Lean, generated matcher or native target ran in this review.
No macOS validation is claimed. The physical-resource and trusted-source/tool
premises remain required; raw request bounds alone do not establish capacity.

Paired-bound conversions, superflat layout, annotation H/Q, global occurrence
attachment, nested providers, generated slices, forced captures, pointer and
fat-pointer adaptation, backing/workspace and downstream phases remain open.
`complete_native_capacity_result` stays false. The e<=2, two callbacks and
three saves remain once per Why process. No production #88–94, Oracle,
admission, tool pin or PR #121 merge changed. Root owns issue disposition,
author repair, integration and memory. This reviewer made no GitHub, goal,
memory or author-source write and stops at this provisional checkpoint.

## F1 / #214 repair disposition — 2026-10-24

**Accepted at exact repair `de0d23d2faf996931861920d2dcd51d80995ad93`.
F1 is resolved for the corrected pure-selector lemma and the attached bounded
scalar transfer.** This supersedes the provisional disposition above while
preserving the original finding and its exact evidence as history. Issue
closure and integration remain root responsibilities; this is no claim of
full #201/#119 completion.

The repair explicitly requires TREE_SIDE_EFFECTS false on every condition,
scalar arm and selector, together with nonvolatile full-base-type declaration
leaves. It retains unchanged literal-only subtrees and the same-type full
extremum premise. It excludes effect-bearing or unspecified conditions from
this helper lemma without excluding any admitted Silver program. The active
MIN/MAX dispositions, residual inventory and research continuation consistently
use this corrected domain; the original broad statement is retained only as
identified history or the preserved counterexample.

The new source join is sufficient. Capture analysis does not treat MIN/MAX's
top-level @0 as a conditional arm, and the early-out machinery alone does not
establish purity. The generator's unused-capture test is still considered;
the explicit false effect flag excludes its COMPOUND allocation. The original
effectful example remains valid outside the lemma and remains byte-for-byte
preserved. The repair does not reinterpret a later caller fallback as erasing
that request.

Actual source attachment is also supplied. EQ/NE tests use literal zero and
completed nonvolatile Integer declarations, without evaluating initializers.
The selected inverse-comparison, scalar-arithmetic, unary-conversion and
COND constructors propagate operand effect flags. They add no effects in
the already selected no-trapv/sanitizer, scalar-IF/no-actions context.
tree.cc's special void COND with null branches is outside this scalar grammar.
Thus the actual selectors satisfy the strengthened premise. Readonly is
not substituted for the absence of side effects.

The callable model now makes purity an explicit input witness. Its Condition
constructor requires a Boolean field and rejects omitted/non-Boolean values;
maximum checks each encountered condition, including nested literal-only
selectors, and rejects effectful or opaque/unspecified condition inputs.
Literal/var tags denote the separately stated pure leaf domain. These model
witnesses do not infer actual native purity; the retained source argument
provides that correspondence. The original F1 tree is rejected rather than
silently interpreted as pure.

One [independent repair audit](../evidence/review-concat-selectors-20261024/repair-f1/README.md)
passed on Linux x86_64 in **0.370610 seconds**, completing at
**07:00:49.322420 UTC**. It binds the thirteen exact repair files, verifies
the five original reviewer evidence files and seven author receipts unchanged,
checks both retained original review/finding copies, and validates three
complete source identities and nine new spans. All lexical matcher data is
unchanged; only nineteen MIN/MAX dispositions change.

The audit extracts only the exact Condition, Node and maximum definitions
from the repaired file's AST. It runs four pure calls, rejects twenty
unsupported calls and seven omitted/non-Boolean constructors, and corroborates
eight effect-propagation/omission combinations. It loads no module imports,
matcher parser or author check entry point. No author/predecessor checker,
native compiler, prover, Lean or generated matcher was replayed. The author's
successful **0.244336-second** focused repair check is reused. Finite checks
remain corroboration, not a machine proof of semantic source correspondence.

First repair-review clock: **06:58:56 UTC**, or **113.322420 seconds** through
the independent audit; report/commit preparation follows. Selected reviewer:
**GPT-6 Astra / Extra High**, unchanged. Runtime model/effort, tokens and
monetary cost are unavailable. Intended result was a narrow F1 disposition;
achieved result is acceptance without further required author repair.

The original report's first 11,871 bytes remain unchanged, as do its original
audit, current receipt, finding and manifest. That original manifest continues
to describe the provisional freeze; the repair receipt binds this appended
disposition separately. No original successful corpus was rerun.

Scalar `520J+128s+368r+288m+344` and query-pair `80s+568` coefficients are
unchanged. All previously open size/layout, annotation H/Q, global occurrence,
nested-provider, slice, forced-capture, pointer, backing/workspace and
downstream obligations remain open. Physical-resource premises, Oracle,
admission, production #88–94, tool pins and the once-per-Why-process
e<=2/two-callback/three-save limits remain unchanged. Native capacity remains
false. No GitHub, goal or memory write occurred; this reviewer stops here.
