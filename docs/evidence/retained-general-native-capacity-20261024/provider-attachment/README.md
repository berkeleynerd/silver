# Concat provider attachment and hereditary lower-one closure

2026-10-24, #201 under #119. This source/math continuation imports original
layout author `302b32d15c293c9f8cf352f80ee9b7b4b068eee0`, accepted without repair
by `793a9738ed8f02e5d84e54a9a687894195f36f94`. Earlier packets are immutable.
It classifies nested concat, allocation-high replacement and generated slice
producers, and closes a larger **hereditary literal-lower-one partition**.
General input-low nesting and whole native capacity remain open. The audit
also found a narrow constructor-row omission in the original packet;
[the explicit repair](repair-original-layout.md) preserves the historical
files and supersedes that row and its layout totals. Repair author
`df7c4491200dbb56642c56b28f9f8341189f967d` was accepted by exact independent
review `10a9004c0f6115fd26c574fc9ca13e903338ece2`, including the named-Image
applicability clarification. That accepted overlay governs this continuation;
the repair's original pending-review fields remain immutable history.

Selected author: GPT-6 Astra / Extra High; runtime confirmation and token/cost
measurements unavailable. First recorded clock: 07:52:13 UTC. The focused
receipt records host and elapsed time. No compiler, prover, Lean, generated
matcher, native target or predecessor checker executes. Independent review
is required at the exact ensuing author commit.

Retain the accepted GCC commit, Linux x86_64 representation, ordinary local
Main/O0 GENERIC mode, precision at most 128, natural Character/String layout,
completed imported dependencies and explicit false TREE_SIDE_EFFECTS premise.
Readonly does not replace purity, and save_expr is not a presumed cut.
The Oracle, admission, production code, pins and physical-resource premises
are unchanged. Fixed representable helper frames and finite traversal use the
retained physical-stack premise; no cumulative compiler RAM/stack gate is
added. Dynamic requests/backing and generated-program frame/encoding duties
remain genuine obligations.

## 1. Source expansion and actual cuts

The current String grammar has literals, initialized names, Integer Image,
parentheses and concatenation; it has no user slices, array aggregates,
character operands or array type declarations. A mutable String's bounds stay
fixed after its initializer. Its later assignments change bytes, not provider
provenance. Name dependencies follow earlier declarations; self/forward
references are excluded (`language.md:169–200,338–392`).

`Expand_N_Op_Concat` leaves a concat that is its parent's left operand for the
parent to process, gathers the same-base-type left spine, and invokes one
`Expand_Concatenate` for that group (`exp_ch4.adb:8005–8097`). A right-nested
concat has already completed expansion before it is consumed as an operand.
Parentheses do not create another array base type. Literal folding can remove
operators; it cannot create an extra concat group. The debug action wrapper
is absent in the retained invocation.

For an event e let n_e be its collected operand count and k_e=n_e-1 the number
of distinct concat operators consumed. Let C be the source's concat operator
count, E the number of expansion events, R the number reaching real result
allocation, M the number taking static-max replacement, and A the number of
**actually generated array assignment slices**. Then

```
E <= C;  sum_e (n_e-1) <= C;  sum_e n_e <= C+E <= 2C;
R <= E;  M <= R;  A <= sum_real n_e <= C+E.
```

Null filtering retains the final operand; NN=0/1 early returns precede the
saved-action insertion and allocate no real concat result. Their unused
frontend action lists must not be counted as translated native declarations.
They return the existing provider. The O0 runtime path for retained NN in
2..9 sets NN=0 after emitting its call, so it generates **no** assignment
slices. Availability failure or larger NN uses the explicit loop. There is no
new nine-operand restriction (`exp_ch4.adb:3097–3124,3470–3560`).

For each retained dynamic operand the expansion requests its First unless
known from its constrained type, one Length capture W_j, and (only at the last
operand of a still-nullable event) First and Last again. Thus there are at
most 2 n_e+2 attribute occurrences in these producer actions. This counts
separate calls; identical prefixes do not identify their native results.
`Duplicate_Subexpr` invokes Remove_Side_Effects then copies the frontend tree
(`exp_util.adb:5323–5334`). Its Name_Req path accepts ordinary nonvolatile names
and safe slices; it does not promise to create a scalar bound capture.

The aggregate prefix after its first dynamic contribution is a fresh readonly
base-Integer declaration initialized by PLUS of two earlier scalar leaves,
or by a leaf after zero-addition contraction. Only the first prefix can be
W_1 itself. The completed declaration reference never expands its initializer.
Every real dynamic result's final G has at least two retained operands and is
a fresh aggregate identity, distinct from incoming provider bounds and tests.
This reuses the accepted aggregate lemma, independently of W_j's initializer.

Nonstatic First/Last attributes retain the attribute after frontend constant
folding (`sem_attr.adb:9590–9618,9817–9846`) and gigi reads the completed signed
index's TYPE_MIN/MAX_VALUE (`trans.cc:2247–2341`). Get_Actual_Subtype returns a
completed constrained subtype; its create-on-demand branch is for an
unconstrained nominal type (`sem_util.adb:10270–10374`). No independent type
construction occurs merely because an ordinary completed provider is queried.
Image and the initial argument producer retain their separate accepted owners.

**A slice is not a universal capture barrier.** Resolve_Slice calls relaxed
Force_Evaluation on each range bound; Set_Slice_Subtype repeats those calls
before copying the range (`sem_res.adb:11963–12005,13109–13198`).
Force_Evaluation sets Variable_Ref=true, but its default relaxed mode still
accepts a side-effect-free scalar IF over constant captures. Its recursive
attribute rule accepts an entity prefix, even when the array bytes are mutable
(`exp_util.adb:7221–7243,12718–12724,14408–14612`). If a scalar value does require
capture, Remove_Side_Effects inserts a constant declaration and rewrites the
old expression to its occurrence (:12761–12825,13099–13115); this cut does not
justify ignoring the initializer's construction. Repetition then sees the
constant name and creates no further capture. Gigi may additionally create
debug bound declarations; otherwise readonly pure expressions remain exposed.
Set_Debug_Info_Needed propagates to related types/indexes, but this packet
allows both resulting paths rather than depending on a debug-only cut.

## 2. Complete provider classification and the remaining mixed frontier

At every concat operand the source classification is one of:

| Provider | Bound provenance consumed by the next event |
| --- | --- |
| Literal or completed fixed name | Completed constant bounds; known-null filtering may apply |
| Initial selected-input family or exact alias | Its accepted completed input bound identities |
| Integer Image or exact alias | Lower 1 and the completed position/capture high |
| Collapsed NN<=1 concat | The returned operand's unchanged provider |
| Real concat, no static replacement | Completed original allocation subtype bounds |
| Real concat, successful static replacement | The separately completed dynamic result-slice bounds |
| Initialized String name | Reused subtype or one constrained alias subtype from that initializer |

Assignments do not add another row: generated assignment slices are internal
write targets, not values returned as providers by Expand_Concatenate.
Their RHS can itself have any earlier row. A temporary introduced for a packed
slice names the same completed slice type, rather than inventing fresh bounds
(`exp_ch4.adb:11422–11450`). Natural Character arrays are not bit-packed and
have no representation change, controlled/atomic components or bit-aligned
record component; Expand_Assign_Array therefore leaves Loop_Required false
and returns before its explicit-loop/temp expansion, including the two-slice
case (`exp_ch5.adb:521–705,861–873`). A generic Pack flag alone is not mistaken
for bit-packing.

For arbitrary incoming low/high trees a_e/b_e, the established source equations
are still exact: selected-low K chooses incoming low providers; a surviving
frontend IF is captured as M; L is its occurrence or the chosen provider;
G is the final aggregate; d=L+(G-1); nullable output is

```
A_e = (G=0) ? last_low  : L;
B_e = (G=0) ? last_high : d.
```

However, a `last_low` or `last_high` read from a completed nested type can
itself be a selector tree. Relaxed Force_Evaluation and readonly SAVE do not
make it atomic. A chosen incoming low can remain an exposed selector, so the next high
arithmetic can have a selector low operand rather than a seed leaf. Consequently neither the old H<=9/Q<=63
bound nor the seed-case discarded-candidate table is asserted for this
entire recursive grammar. This is a concrete remaining fold/cumulative-work
obligation, not a new provider cap or a rejection of those admitted programs.
The source equations and occurrence attachment below cover this frontier too;
only the specialized fold transfers in sections 3–5 require lower-one provenance.

## 3. Hereditary literal-lower-one providers

Define this family by producer identity, not by a runtime inequality: every
seed provider has frontend-known literal lower 1 (fixed/literal or Image),
and every incoming nested provider or alias has already established that same
property. Initial-input names enter only if their actual completed provenance
establishes it; the accepted arbitrary-input-bound family alone does not.

All Opnd_Low_Bound values then fold to 1. Get_Known_Bound's equality test
returns 1, so there is no selected-low M. Nullable low IF(1,1) also contracts
to 1. The high d=1+(G-1) contracts to G with the accepted discarded negation,
PLUS-zero and NON_LVALUE work. Nonnullable output is G. A nullable empty fixed
tail has high0 and IF(G=0,0,G) contracts to G. The remaining nullable result
adds at most one high selector above the last provider's completed high:

```
B ::= leaf | (P_G ? B_earlier : G)
P_G ::= EQ(G,0), or NE(G,0) with exchanged arms.
leaf ::= a completed signed32 declaration, or Image V with its allowed
         same-width signed view; constants use the constant specialization.
```

Each G on a spine comes from a different earlier real concat event. No runtime
value equality identifies those native declarations or separately built tests.
Debug/forced captures replace a subtree by a leaf and terminate that spine;
its initializer remains separately owned. There is at most one uncaptured
Image view on a spine, at the terminal seed. A nullable high over a nonnullable
nested result starts a new spine above that result's G leaf.

Let t be the number of retained selectors on this provenance spine, before
optional debug cuts. Seeds have t=0; aliases preserve t; a nullable real event
has t<=1+t_last; a nonnullable/empty-tail contraction resets t to zero; a
successful static-max returned slice preserves the original t. Therefore
**t<=C for every such provider**, by strict earlier-event order. This theorem
is parameterized by arbitrary finite C. Current admission has C<=63 because
concat shares its operator budget with scalar arithmetic; 63 is only a current
comparison point, not a premise for the transfer or a proposed #119 cap.

The scalar event's accepted `520 n_e + 368 r_e + 344` raw-byte envelope applies
with s=m=0: the new high arm is a completed same-base-type tree, not a new
translation of all its descendants. New outer P cannot equal any earlier
P because its G is fresh. Neither successful nested-equal/inverse rules nor
repeated-capture unshare introduce another branch. Distinct source aliases
can share that tree; their native type/query occurrences remain separate.

### Signed Length initializers and maximum-query revisits

One W_j initializer uses get_type_length (`trans.cc:1716–1735`): signed
comparison C_B=GE(B,1), signed32 (B-1)+1, and a zero fallback. Distribution
against a constant enters every spine arm; -1/+1 cancels at each dynamic leaf
in both accepted signed-overflow modes. The signed cancellation may retain
NON_LVALUE around declaration leaves: non_lvalue_loc wraps declarations but
not the Image's NOP view (`fold-const.cc:2810–2875`). Ternary STRIP_NOPS only
changes local inspection variables; its fallback retains the original arms
(:12896–12948). Gigi's outer result stripping does not walk inside those arms
(`trans.cc:8954–8958`). Thus the final initializer is bounded by
`C_B ? B' : 0`, where B' allows one such wrapper at each of its t declaration
leaves and keeps the terminal Image view. Signed comparisons stay signed.
It has H<=t+3 and O<=13t+8. A whole-spine NON_LVALUE alternative is also
subsumed for t>0. The unsigned layout cancellation below has a NOP conversion
at its leaf and does not need this signed-Length wrapper allowance.
Its provisional shifted leaves/conditionals are not refunded. At t=0 the
comparison/conditional helper can instead produce MAX_s32(B,0), possibly
contracting further for the Image view. This is a smaller final graph, with
the MAX construction included in the allowance.

An authored cumulative allowance per Length initializer is
C24/U12/B20/T12 times (t+1), or **2720(t+1) raw bytes**. There are three binary
stages (minus, plus, comparison) and one final conditional. Each leaf's whole
continuation is bounded by C8/U4/B6; each internal selector contributes at
most one arm-order inverse and two conditional requests per binary stage.
The extra outer conditional and the 1/0 constants fit the displayed allowance.
Conversions are exact signed-base views; the optional Image view can only
strip/rebuild one leaf comparison. These counts include rejected/provisional
nodes and do not include the W declaration, its initializer statement or
other executable metadata. The old scalar-event charge did not own these
Length initializers, so this is a distinct owner.

A query of an aggregate G's initializer still stops at its scalar operands:
at most three constants, never a recursive walk through W_j's initializer.
But the **first generated assignment slice's high can be W_1 itself**. Its
maximum-size query can therefore visit that Length initializer. Likewise a
debug high declaration can expose B's selector spine to max_value.

`max_value` ignores a COND's test, recurses into its two value arms, replaces
variable leaves by their type extrema, and folds MIN/MAX of those constants
(`utils.cc:4095–4180`). Its unary NOP rule handles the one Image view, and
NON_LVALUE recurses without a constructor. B's
query takes at most 2t+2 constant requests; a Length initializer adds at most
one constant combination. No condition is translated again. The pair of
bound queries for a classified receiving array is conservatively **2u+8
constants**, or **80u+320 raw bytes**: use u=t for a high-spine type, u equal
to the first operand's depth for a first assignment high W_1, and u=0 for
later aggregate highs. A captured low Gprev+1 adds at most two constants.
Overflowed aggregate extrema remain constants and trigger the existing
caller fallback; no tight-extremum assertion is required. If the Length root contracted to MAX, max_value has no MAX recursion and
returns that existing expression; the caller substitutes the existing type
extremum. This alternative creates no new binary/unary expression, and the
query allowance still holds. Do not claim that every query returns a constant.

## 4. Allocation-high replacement and result slices

The source gate requires a compile-time-known low, a nonconstant high,
Max_Aggr_Length below Too_Large_Length_For_Array, and an in-range computed
known high (`exp_ch4.adb:3299–3325`). Max_Length is finite for a dynamic slice
only when its prefix has completed constant bounds (:3024–3035). Image's
fixed buffer and an earlier static-max concat buffer satisfy that provenance;
an arbitrary dynamically bounded input does not acquire a static maximum from
Silver's runtime limit alone. No semantic maximum is substituted for this
actual frontend test.

The precise source-derived witness for the original-allocation MAX repair is
`Saved : constant String := Integer'Image (I);` followed by
`Result : constant String := Saved & "";`, with nonstatic mutable I and Saved
retaining the accepted dynamic Image bounds. Saved is an identifier, so the
slice-only finite-maximum branch at :3020 does not apply; :3033 sets
Too_Large_Length_For_Array, preventing :3302–3304's static replacement.
The retained final empty operand yields the A=1/B=G nullable original range.
A direct Image expression expands to a slice of its fixed Snn buffer
(`exp_imgv.adb:1418–1429`) and can instead take static replacement. This
clarifies applicability of the immutable repair without changing its native
MAX path or numerical overlay. No compiler execution establishes this witness.

On success the original low/high nodes first enter Slice_Rng. Allocation gets
its own constant known-high range; the final result is a slice of the allocated
S object using the original pair (:3327–3331,3635–3645). The allocation's
Cannot_Be_Superflat flag is set **after** Slice_Rng was created, so it is not
transferred to the returned slice. In the lower-one partition the allocation
belongs to the accepted constant-type family; the returned dynamic slice has
A=1 and the same B spine, with an unproved-superflat alternative retained.
If the gate fails, the original dynamic allocation itself has that pair.
The slice translation can additionally attach TYPE_ARRAY_MAX_SIZE from its
constant-sized prefix without changing the signed endpoints or annotation
roots (`trans.cc:7086–7111`).

For a dynamic receiving lower-one array, write U=signed32->u64 and W=u64->u128.
Against constant1, GE and -1/+1 distribute through all t selectors. Put Y=U(B)
and C_B equal to the comparison spine. The retained superflat bit-root is

```
C_B ? MULT_u128(W(Y'),8) : 0.
```

Y' has Y's u64 selector grammar but may use newly allocated plain CONDs.
The non-superflat shortcut is smaller. At t=0, conditional completion may
recognize the signed compare operands through the one outer U and produce
U(MAX_s32(B,0)); subsequent -1/+1 cancellation returns that tree. Its final
bit root is MULT(W(U(MAX_s32(B,0))),8), with H<=5/O<=8/Q<=8. This contraction
allocates a MAX and a conversion; it is explicitly charged below. For t>0,
C_B is a Boolean COND spine and cannot trigger that comparison helper. W
first distributes, retaining its
provisional arm widenings and conditionals. At every internal selector whose
two arms are NOP_u128 of u64 values it pulls out using plain builders and
returns. Inductively this rebuilds the spine behind one W: at most 2t+1 unary
and 2t conditional requests for the inner W route, plus the outer zero-arm
conditional. No recursive conversion/distribution cycle is created.

All new native nodes use completed operands. The general call rank is
lexicographic in remaining selector depth, then the accepted phase order:
MINUS dispatch -> PLUS dispatch -> distribution -> arm canonicalization ->
constant association -> conditional completion/order -> plain-builder return.
The comparison leaf canonicalizes >=1 to >0; its optional view removal lowers
conversion depth. Whole arithmetic work is linear in the t-node spine, including
failed attempts, because constant-other distribution has no second branching
operand and each level has one recursive arm and one leaf. Outer C_B is a
Boolean comparison spine, never any P_G; independent polarity inversion is
allowed. No source substitution identifies P node pointers.

The retained kernel entry envelopes from concat-layout can conservatively be
multiplied by t+1 after enlarging the gigi-conditional row from C0/U0/B1/T1
to C2/U2/B2/T2 to own the depth-zero signed MAX/conversion continuation. The frontier has at most t+1 conditional activations and
t+2 leaves, versus the previous rounded allowance for three activations and
two dynamic/two constant leaves. The direct U route uses at most two unaries
per leaf and one conditional per level; W's exact provisional/plain counts
above fit the fold_convert row. Size-binop leaf cancellation takes at most two
constant calculations and one NON_LVALUE; per level at most an inverse compare
and two conditional constructions. GE's leaf/view/positive-constant stages
fit its existing separate row. Thus the cumulative total is

```
C184/U126/B138/T112 times (t+1)
layout raw bytes <= 22288(t+1); operand slots <= 738(t+1).
```

There is no graph-height-as-termination assumption and no refund for failed
folds. The same guarded GENERIC paths and absent SSA/vector/pointer/real
patterns as the accepted audit apply; the only new recursion repeats a
strictly shorter one-armed selector spine. The signed arithmetic kernel,
constant query, type/debug and shared backing owners stay separate.

Exact conservative occurrence formulas for the final supergraph are

| Root | H bound | O=Q bound |
| --- | ---: | ---: |
| B | t+1 (t=0 allows one view) | 5t+2 |
| C_B | t+2 | 7t+4 |
| Y | t+2 | 6t+3 |
| final bit root | t+5 | 13t+12 |

The B height bound can be enlarged to t+2 uniformly without changing any
export. No final sign-bit-set PLUS or converted same-code PLUS/MULT appears
in this family, so Q=O is a valid conservative charge. The separate Length
initializer formula does not imply that it is an annotation root. Two
finishing occurrences give **26t+24 annotation charge**, even if native roots
are shared, hence **1328(26t+24) raw annotation bytes**. Constant factors 8/0
make round-up terminate before entering Y, at at most four multiple_of_p
activations as in the accepted layout packet.

## 5. Generated assignment-slice bounds from lower-one results

In the explicit-copy loop Lo=A+G_(j-1), Hi=A+(G_j-1), using copies of the
**original** Low_Bound, not the replaced allocation high. For A=1 the high
contracts to G_j. The low is 1 for the first operand; a later fixed prefix
gives a constant k; after a dynamic prefix it is Gprev+1. Gprev and G_j are
different aggregate/Length identities. Their initializers are not operands.
A static null operand emits no slice assignment; a dynamic early operand can
be guarded by W_j/=0, but that guard does not confer a non-superflat type flag
(`exp_ch4.adb:3564–3633`).

For dynamic low the final layout is bounded by

```
X=U(Gprev+1), Y=U(G_j), C=GE_s32(G_j,Gprev+1)
bits = C ? 8*W(1+(Y-X)) : 0.
```

The false-arm (X-1)-X cancellation makes the outer distribution succeed.
Neither widened shared-addend cancellation applies to the true arm: G_j is a
fresh declaration, not its PLUS initializer. The first low1 slice can take the MAX continuation just described.
Comparison can canonicalize its single +1 offset, but that consumes the offset. Wrapping mode retains it.
C is never the arithmetic difference or a nullable P. Constant-low k has the
smaller shifted leaf `U(G_j)+(1-k)` under its signed comparison. Alternatively,
GE(G_j,k) canonicalizes to GT(G_j,k-1), and the conditional before subtraction
can contract to `U(MAX_s32(G_j,k-1))`. The completed length is then
`U(MAX_s32(G_j,k-1))+(1-k)`; its bit root has H<=5/O<=9/Q<=10.
The MAX and conversion are in the repaired conditional allowance, including
k=1. A retained negative offset can add one Q unit. Optional debug cuts reduce these operand
graphs. Constant-high and fully constant alternatives fit the same bound or
the constant specialization. The accepted constructor envelopes, without a
t multiplier, cover this single-superflat-selector grammar.

Therefore each newly classified assignment-slice receiving array has
**H<=7, O<=19, Q<=19 per finishing bit root**, two-root Q<=38, layout<=22288
raw bytes and annotation<=50464, for **72752 raw layout+annotation bytes**.
Do not infer that each source assignment creates this many arrays: the type
attachment below identifies the exact constructor sites.

The scalar translation of its two source bound roots is separately bounded
by C73/U4/B8, or **3368 raw bytes**. There are at most five source integer
literal occurrences (the two copied low1 values, the high's subtract-one,
and two potentially literal aggregate prefixes), each using the accepted
13-constant UI_To_gnu transfer. Eight further constants, four unary and eight
binary candidates cover the two arithmetic stages and discarded association/
NON_LVALUE work. The generated guard/body/object/ARRAY_RANGE_REF conversion,
copy executable machinery and metadata are separate owners.

## 6. Source entities, native identities and compositional exports

Constrain_Array/Constrain_Index create one constrained array subtype and one
signed index subtype for a fresh range (`sem_ch3.adb:14339–14454,15316–15482`).
Set_Slice_Subtype creates one array and one signed index subtype, and copies
its range before attaching the latter. This source copy makes a new bound
node identity; it does not promise a second execution of an earlier initializer.
A retained subtype mark instead reuses its existing index subtype.

Expand_Subtype_From_Expr either reuses a suitable constrained itype, makes
one array subtype alias, or builds a constrained array using the existing
slice index type (`exp_util.adb:5864–6007`). Copy_Array_Subtype_Attributes shares
First_Index (:15790–15807 in sem_ch3.adb). Thus each ordinary String declaration
whose initializer is a completed provider adds at most one array identity and
no new scalar index in the alias/slice cases. Literal initializer cases use
the already owned constant-index path. Let D count these source declarations;
no new D cap is assumed.

Gigi caches each completed entity and each elaborated bound node. Its generic-
actual clone special cases do not turn an ordinary Main alias into the same
native type (`decl.cc:405–445,5418–5475`). A fresh array subtype reaches its own
nonshared array constructor and its own maximum queries/finishing annotation,
even when it shares the signed index and bound trees. Repeated First/Last uses
of that same completed entity do not reconstruct its type. Distinct index
copies can elaborate their own bound expressions; references inside them to
earlier captures/types use the completed associations.

For the direct concat producer sites (before unrelated call/pointer/native
metadata variants), therefore

```
array-construction identities <= R + M + A + D <= 4C + D;
signed-index identities from concat ranges <= R + M + A <= 4C.
```

This includes the static allocation and dynamic returned slice separately.
A Make_Temporary_For_Slice object reuses the completed slice type. The natural
assignment path introduces no extra frontend copy-loop subtype. Source
literal/Image/input families and any type from a broader unconstrained or
pointer adaptation have their own existing owners. No inference counts every
native type node or source name as one of these array-construction identities;
GCC's internal type/metadata variants stay in the kernel/metadata join.

For disjoint newly classified receiving identities let H contain lower-one
high-spine types (depth t_i), and J contain generated assignment-slice types.
Let U contain actual Length initializer occurrences (provider depth t_v), and
u_i be the maximum-query depth selected in section 3. The local exports are

```
layout bytes <= 22288 * (sum_H(t_i+1) + |J|)
annotation Q <= sum_H(26t_i+24) + 38|J|
annotation bytes <= 1328 * annotation Q
bound-query bytes <= sum_(H union J)(80u_i+320)
Length-initializer bytes <= 2720 * sum_U(t_v+1)
assignment-bound scalar bytes <= 3368|J|.
```

Charge the last row by the actual slice-bound translation occurrence; shared
index aliases reuse it and add no duplicate source bound translation. The
identity notation |J| is a conservative allowance for those occurrences,
not a requirement that each alias retranslates them. At most one nonconstant
high debug declaration per distinct lower-one signed index costs 288 bytes;
assignment indexes allow two, 576 bytes. Existing scalar-event, kernel,
constant-family, table, allocator and executable metadata terms remain.
No received root gets both an old specialization and the new one.

Every t_i,t_v,u_i is source-derived and at most C. Hence coarse replacement
by C in these sums is legitimate **for these attached families**, while retaining
D and the actual disjoint ownership. The finite formulas remain valid for
arbitrary finite C; eventual native representability/backing arithmetic decides
an admissible region. The current 63-operator policy is not used to truncate
or prove the inductive recurrences.

## Verification and exact residuals

The focused changed-unit check verifies exact accepted-input/review hashes,
complete archived GCC sources and LF spans, authored rank/resource paths,
spine/Length/assignment occurrence formulas, polarity variants, query costs,
small concat-forest event counting and table arithmetic. It executes no GCC
matcher, compiler, prover, Lean target or predecessor checker. Finite checks
corroborate the source argument; the stated induction/source correspondences
are not replaced by the examples.

Still open: general input-low nested selector and arithmetic providers;
all scalar folding/Length construction for that general recursive grammar;
full input/Image/executable object and procedure-call construction; generated
range checks and pointer/fat-pointer adaptation; complete global metadata/type
variants and shared backing; fixed/import incoming states; later compiler,
assembler, linker, ALI/binder and process composition. This packet does not
claim complete-current-grammar #201/#119 capacity. It does not change the
once-per-Why-process e<=2, two save-entering callbacks and three saves.
Parent owns issue/memory/integration/publication; this subthread makes no
GitHub, goal or publication writes.
