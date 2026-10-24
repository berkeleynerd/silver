# Concat scalar selectors and maximum-query transfer

2026-10-24 UTC. Author continuation for #201 under #119, after concat-prefix
`fd44328b98f1a977d0cfdbb01aa161940124edcb` was accepted without repair by
`000656e773c6eae24a673afeb5af05f200dc6723`. **This closes a scalar endpoint
subcall and its maximum-query protocol, not the size/layout of a general
concat type.** No existing packet, production code, Oracle, admission rule or
tool pin changes. The global e<=2, two save-entering callbacks and three saves
remain once per Why process, in their existing owners.

Selected author: GPT-6 Astra / Extra High. Runtime confirmation and token/cost
measurements are unavailable. The first recorded round clock was 06:21:15 UTC;
`current.json` records focused-check completion and elapsed time. No compiler,
prover, native target, Lean or predecessor checker ran. The source and lexical
parser are reused; the new checker does not invoke the predecessor checkers.
The original freeze received provisional review F1/P2. The active lemma
includes the [#214 purity repair](repair-f1/README.md); its exact narrow
independent review is pending. Original check receipts remain historical.

## Scope and dispatch

All native claims retain the accepted pinned GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Linux x86_64 representation, selected
O0 GENERIC invocation, regular annotation, ordinary local Main, completed
imported/fixed dependencies and no arithmetic sanitizer/trapv/fold-checking
premises. No SSA, unconstrained in-parameter cache, storage model, scalar
volatile object, coverage-forced conditional expansion or anonymous-access
context is introduced. Exact native correspondences and physical assumptions
from the accepted packets remain required.

The scalar source event is a real Standard.String concat, NN>=2, with at least
one dynamic operand. Its incoming endpoint providers are the accepted initial
input or Integer Image families and exact provenance-preserving aliases, or a
completed fixed family whose lower bound is literal1. This classification uses
producer identities, not numerical runtime values. It does **not** say that
all presently admitted concat providers have these identities. Nested concat
results, their generated slices, other lower-bound provenance and action-bearing
captures remain explicit joins in `remaining.json`; they remain admitted under
the existing language. This packet adds no source restriction.

Unlike concat-prefix, the first retained operand need not be fixed or nonnull,
and Result_May_Be_Null may be true. The subcall occurs before optional static
allocation-high replacement. It covers the constructed scalar endpoints in
that case too; it does not transfer the later returned dynamic slice's type or
its flags. Original object/operand-Length/aggregate declarations are separate
owners. We use their completed associations here, without expanding their
initializers on each reference.

## Producer grammar and native barriers

`exp_ch4.adb:2805–2823,2963–3045,3050–3099,3125–3296` gives this grammar.
Ityp and Artyp are base signed Integer32 for Standard.String. Var_Length's
comment says Natural, but its declaration actually uses Artyp. Let W_j be the
fresh capture of operand j's Length and G the last aggregate-length capture.
NN>=2 and a dynamic operand ensure the final aggregate expression has a fresh
aggregate capture; its identity differs from all incoming bounds and from
any selected-low capture. The declaration may hold an earlier value after
zero-addition folding, but references to it do not replay that initializer.

`Get_Known_Bound(j)` recursively reaches the first fixed-length operand or the
last operand, then returns:

```
K_j = low_j                             (fixed j or j=NN)
K_j = K_(j+1)                          (Compile_Time_Compare proves EQ)
K_j = W_j /= 0 ? low_j : K_(j+1)        (otherwise)
```

It makes at most s<=NN-1 IF nodes. Its recursive rank is NN-j. Repeated source
operands have fresh W_j declarations, so equality of their runtime lengths
is not equality of the test trees. The positive fixed operand stopping rule
also means the low-selection spine can be shorter than the concat chain.
For the attached providers, each low_j is native literal1 or a completed
base-Integer bound declaration. If the result is still an IF, the producer
emits one constant declaration M:Ityp initialized by it, and Low_Bound is M.
Otherwise Low_Bound is the returned endpoint. Write L for this scalar result.
The selected-low spine is **behind a declaration cut** in subsequent high
arithmetic.

```
H_nonnull = L + (G - 1)                 (base signed Integer32)
if Result_May_Be_Null:
    low  = (G = 0) ? last_low  : L
    high = (G = 0) ? last_high : H_nonnull
else:
    low  = L
    high = H_nonnull
```

The two EQ expressions are separately constructed copies over the **same G
identity**. There is no pointer-sharing premise between the test nodes. Later
native operand ordering can invert one test and exchange its arms. Any future
layout transfer must account for condition polarity as well as shared G.

Here last_low is literal1 or an input bound declaration; last_high is input
H, Image's Natural32 position V converted to base Integer32, or the constant
high0 of a fixed empty final operand. Result_May_Be_Null cannot coexist with a
retained fixed positive operand. A trailing empty literal constructs `1-1`
in the frontend; the ledger allows its unreduced constant evaluation too.
The nullable flag is producer knowledge, so Image's semantic nonemptiness is
not used to clear it. Neither input bounds nor G is reclassified as Natural.

The current-language initial source binding is unique (`language.md:188–194`),
but the argument does not need that uniqueness: distinct completed base-Integer
bound declarations are allowed. Exact aliases must preserve endpoint/capture,
type, local context and completed-association provenance.

For these scalar branches, Expand_N_If_Expression has a copyable definite
integer type, no branch actions and no anonymous-access/coverage context. It
returns the scalar IF for gigi (`exp_ch4.adb:5755–5803,5870–5941,6503–6640`).
Relaxed Force_Evaluation calls Side_Effect_Free; entity/literal arithmetic and
scalar IF components qualify (`exp_util.adb:7221–7243,12695–12724,
14408–14457,14519–14612`). A reference to the bounds of a mutable String name
uses its fixed completed type, not the changing bytes. This argument must be
revisited for action-bearing/unconstrained incoming providers.

`trans.cc:2247–2341` retrieves First/Last from TYPE_INDEX_TYPE of the completed
array type. The local constrained path has no in-parameter attribute cache or
unconstrained-pointer-dereference SAVE. `trans.cc:7604–7616` translates all
three IF operands then calls build_cond_expr. The latter's two arm conversions
are exact base-type views on the low grammar; there is no pointer/by-reference
adaptation. Its possible common-SAVE COMPOUND branch is absent: our simple
arithmetic ends at declarations, not SAVE_EXPR (`utils2.cc:1892–1934`).
Readonly nonconstant selected/aggregate initializers produce nonvolatile
VAR_DECLs (`utils.cc:3018–3110`). If all low arms contract to1, the resulting
constant may instead be inlined; that reduces this grammar.

## Scalar fold calls and discarded candidates

On the selected-low grammar native COND folds equal arms, or retains the
selector after at most one operand-order inversion. A declaration before a
nested selector, or a literal before a declaration/selector, can trigger that
inversion. tree_swap_operands_p then rejects the reverse order. Inversion of
EQ/NE constructs one inverse comparison directly, without a TRUTH_NOT wrapper
(`fold-const.cc:4620–4655,7254–7300,12900–13077`). An unequal constant pair is
not transformed by the GIMPLE-only arithmetic rule. Current source low
constants are all1; equal constant arms disappear. Fresh W_j identities rule
out the repeated/inverse nested-test patterns. No condition compares a W_j to
its own bound result; comparison-to-min/max and sign/absolute-value rules do
not apply. A completed low is never assumed to be a Boolean merely because
it is positive at runtime.

For H_nonnull, low1 reuses the accepted normalization:

```
G-1 -> G+(-1);  1+(G+(-1)) -> G+0 -> NON_LVALUE(G) -> G
```

The discarded NON_LVALUE request is charged. With dynamic L, the retained
shape is `L+(G+(-1))` (up to operand order), or `(L+G)+(-1)`. These have exactly
two arithmetic nodes over distinct declarations and one constant. Under
undefined signed overflow, handwritten association rejects two independent
variable parts. Under wrapping overflow it combines the two variables once.
`associate_trees` folds the inner L+G, then uses **build2 without another fold**
for the outer addition because the operand is already PLUS. `split_tree`
cannot split L+G into a variable and literal; the two-object/actual-origin
checks exclude a return cycle. The discarded G+(-1) remains charged. Thus two
source arithmetic entries request at most four constants, two unary nodes and
three binary nodes, including attempted/discarded work. Source integer-literal
translation is separate. `match.pd:2200,4407` and
`fold-const.cc:901–1061,11458–11663` establish the decreasing phase/order/
association rank rather than relying on unchanged tree height.

The paired nullable scalar selectors have atomic low arms and at most the
above arithmetic high arm. Equal arms may contract. When L=1 and last_high=0,
`G==0 ? 0 : G` contracts to G through the handwritten comparison helper.
Otherwise the high selector retains its two arms (possibly swapped). The
zero-one, division, multiply, negate, compare/minmax and arithmetic-value
replacement patterns require missing operators or identities. In particular,
the last incoming bound is not the fresh G, nor an operand L+G's shared
subexpression. No constructor rewrites a selector by expanding M's initializer.

`matcher-audit.json` binds every lexical root form for these requests: 151
binary, 19 conversion, 65 COND, 109 EQ/NE and 20 MIN/MAX forms, plus the empty
TRUTH_NOT matcher inventory. Both preprocessor branches are retained as a
superset. The dispositions and argument are authored semantic claims; lexical
extraction and finite checks do not prove correspondence. The source includes
GIMPLE-only conditional distribution forms; GENERIC handwritten distribution
is addressed by the earlier MIN/MAX return below.

## Maximum queries: unchanged arms and extremum absorption

The following lemma applies to **finite side-effect-free native selector
trees** of one integral type T with nonoverflowed literal leaves and nonvolatile
VAR_DECL leaves whose existing extrema are the full extrema of that same T.
Every condition is already completed and explicitly has TREE_SIDE_EFFECTS
false; all scalar arms and selectors also have TREE_SIDE_EFFECTS false. It is
not a claim that every such tree is currently source-reachable. max_value does
not recursively visit conditions, but their purity is essential to the folder
used for reconstruction. Effect-bearing or unspecified conditions are outside
this lemma; excluding that helper domain does not restrict source admission.

For s selector occurrences and d declaration-leaf occurrences, a call of
max_value in direction p visits exactly 2s+1 non-condition nodes before
contractions (or no more than that after contraction), and requests at most
**d+s <= 2s+1 scalar constants**. It creates no unary/binary/ternary node on
this exact-type grammar. More precisely:

* A literal returns the identical existing pointer. A VAR_DECL returns the
  corresponding existing type extremum through fold_convert; it never follows
  DECL_INITIAL. Charge one constant conservatively for that conversion.
* An all-literal selector subtree returns the **original selector**, not a
  constant MIN/MAX. Both recursive arm pointers are unchanged, so the explicit
  equality test at utils.cc:4169–4170 breaks to `return exp`.
* A subtree with at least one declaration returns the requested extremum E.
  Inductively a changed child is E; the other child is E, a literal, or an
  unchanged all-literal selector. Two constants fold before generic_simplify,
  costing at most one constant request. For E versus an unchanged selector,
  commutation places E second and match.pd:4950/4961 returns E immediately.
  This precedes handwritten conditional distribution. GENERIC's generated
  unused-capture handling still matters: genmatch.cc:4668–4685 would preserve
  effects of the discarded selector with fold_ignored_result and a new
  COMPOUND_EXPR. Our explicit TREE_SIDE_EFFECTS-false premise makes that
  branch false, so no symbolic MIN/MAX, COMPOUND, child arithmetic candidate
  or replacement COND is constructed.

For the attached source grammar the purity premise follows from fresh
nonvolatile captured Integer references and literal zero in EQ/NE tests, and
literal/declaration arms. A declaration reference does not evaluate its
initializer. Inverse comparisons remain pure. tree.cc:5194–5223,5257–5274,
5295–5333,5350–5390 propagates operand TREE_SIDE_EFFECTS through the applicable
unary, binary/comparison and COND constructors; these ordinary integer codes
do not add effects. Thus each nested selector has TREE_SIDE_EFFECTS false.
Readonly alone is not being used as a purity premise. Frontend scalar purity
and absence of inserted branch actions were established above.

The MIN/MAX @0 capture is an ordinary top-level operand; capture analysis at
genmatch.cc:2961–2991 does not treat it as a conditionally captured COND arm.
The early-out rules at4359–4400 therefore do not by themselves exclude an
effectful selector. The explicit omission code at4668–4685 is the required
join. The preserved F1 counterexample has an effectful condition in an
unchanged literal-only subtree: reconstruction returns COMPOUND(P,E), not E,
and a later caller fallback cannot refund that binary allocation. See the
[exact original finding](repair-f1/finding-F1.original.json). No current-Main
reachability claim is made for that synthetic helper.

Within the pure domain this covers unchanged-arm behavior rather than
silently excluding it. It
also explains why a literal-only helper example is not an actual-Main
reachability argument. Do not apply the extremum lemma to a constrained
subtype leaf whose extrema differ from T, a SAVE/COMPOUND/call leaf or a
conversion that changes precision/signedness. Their concrete transfers must
be supplied first. A surrounding same-base wrapper can be handled separately;
none is needed inside the attached selected-low tree.

For the actual nullable endpoint queries, the generated M declaration is a
leaf, so the selected-low spine is not revisited. The nullable low initializer
has at most3 activations. The nonnull high has at most5: its two scalar
arithmetic nodes and three immediate leaves. A nullable high adds one selector
and one last-bound leaf, giving at most7; the possible Natural32-to-Integer32
NOP on last Image V gives at most8. For the high query's maximum direction,
Natural's maximum equals the base-Integer maximum. All arithmetic children
become constants; resulting signed overflow flags are retained. Its COND
therefore either returns an existing contraction or folds constant MIN/MAX,
with at most8 constant requests and no symbolic reconstruction. This is a
work bound, not a claim that overflowed arithmetic computes a valid maximum.

The declaration-query caller accepts only a nonoverflowed INTEGER_CST;
otherwise it falls back to the existing bound type's extremum
(`decl.cc:2670–2712`). If a bound contracted to G, its actual queried initializer
is the already accepted immediate aggregate PLUS (<=3 constants), not the
entire aggregate chain. If it contracted to an original input bound, its
initializer is the accepted <=2-wrapper SAVE cut, whose query can construct
up to2 unary nodes. An additional debug bound declaration references the
already completed scalar and is smaller. Therefore a conservative **one
low-query plus one high-query** export is:

```
constants <= (2s+3) + 8 = 2s+11
unary <= 4
raw caller bytes <= 80s+568
```

The unary allowance is for the accepted original-input capture alternative,
not hidden symbolic rebuilding in the selector lemma. Query occurrences are
counted per receiving type identity; source construction is counted per scalar
producer event. Copying a type must not silently share this query allowance.

## Cumulative scalar constructor projection

Let r be the Result_May_Be_Null indicator and m the selected-low capture
indicator (both0 or1). Let J count integer-literal **translation occurrences**
inside this scalar endpoint subcall, excluding already completed incoming
endpoints and the separately owned original Length/aggregate construction.
Counting selected spine leaves/tests, both low occurrences, the high's1, both
null tests and both last bounds gives the safe source-derived allowance
**J<=2s+4+5r**. The extra r allows an unreduced trailing-empty `1-1`; retaining
an unused root literal when there was no capture only overcounts. This is not
an imposed source or recursion cap.

There are s+2r condition entries, each with an initial comparison and at most
one inverse comparison, and at most one new ternary. Each supplied-type
integer literal costs the accepted13 constant requests. Add the two high
arithmetic entries just analyzed, at most one constant-only empty-tail
subtraction, and at most one same-width last-Image conversion. Finally charge
one scalar declaration (the conservative256-byte VAR envelope also covers a
contracted CONST_DECL) and one DECL_EXPR for m.

| Projection | Bound |
| --- | --- |
| Constants | 13J+4+2r |
| Unary nodes | 2+r+m |
| Binary nodes | 2s+4r+3 |
| Ternary nodes | s+2r |
| Scalar declaration nodes | m |
| Operand slots | unary+2*binary+3*ternary |
| Raw caller bytes | **520J+128s+368r+288m+344** |

The count includes discarded inner arithmetic, inverse comparison and
NON_LVALUE candidates; it is not a count of retained nodes. It excludes names,
bindings, statement metadata, provider translation, original objects,
allocator/cache backing and native frames. The maximum-query pair can be added
when it belongs to the receiving identity: **520J+208s+368r+288m+912 bytes**
for one source scalar event plus that one pair. This is a local compositional
unit, not a new global Cs/Ca coefficient: occurrence/type-copy attachment and
paired-selector layout/annotation remain open. Do not add this scalar event
on top of a predecessor charge that already owns the same high/low roots.

## Current source attachment and residual joins

`samples/path_guards.adb:14` has `Work & ":" & Original`, with Work and Original
holding bounds inherited from the completed initial input. The first dynamic
operand and the positive fixed second operand yield the selected low
`W1/=0 ? Input_L : 1`, captured as M, followed by `M+(G-1)`. Result_May_Be_Null
is false. The path guard controls admitted lengths; it does not change native
base signedness or prove the folder's source grammar. If earlier frontend
comparison contracts a selected arm, the smaller form is covered.

The same file's line16, `Input & Input`, has only dynamic operands, so
Result_May_Be_Null remains true. Both lows are the same completed Input_L;
frontend equality or native equal-arm folding removes the selected-low test
and then the nullable low selector. The high selector is
`G==0 ? Input_H : Input_L+(G-1)`, with the source-derived bounded arithmetic
above. No compilation was performed; these are concrete source attachments
for the universal classified producer argument, not evidence that samples
establish universal capacity.

The next missing native join is conversion and superflat size layout of the
paired original bounds. They may retain readonly CONDs through save_expr;
SAVE is not assumed to cut them. Separate EQ trees may have opposite polarity.
A size expression can expose conditional distribution and sharing beyond this
scalar unit. Its height, annotation retries, repeated helper demand and exact
copy counts require their own argument. All nested incoming providers,
static-maximum returned slices, assignment slices, forced captures, executable
objects, pointer/fat-pointer adaptation, shared backing/workspace, imported
states and downstream phases remain open. `complete_native_capacity_result`
remains false; #201 and #119 are not completed.
