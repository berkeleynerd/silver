# Constant-bound helper joins and the #209 predicate repair

This source-only continuation of #201 closes the GCC tree-constructor demand
of the selected constant-bound type-helper and annotation paths, and the scalar bounds-template helper reached
by the direct String call-adaptation interface. It does not close dynamic
`F(root)`, dynamic Q, other executable conversion callers, imported construction,
or whole native capacity. No new admission condition is introduced.

The first-kernel freeze36d478da0c and #207 freeze1604467b remain historical.
For current use, **add the #209 row below to the first kernel**, and retain the
separate #207 frontend Uint overlay. `current.json` is the current native
constant-request export; it does not supersede #207's frontend export. The
new checker does not execute either predecessor checker or a native target.

## #209: the allocating superflat predicate

At `decl.cc:2771–2772`, the constrained-array branch can call
`range_cannot_be_superflat`. The accepted C row and residual list omitted its
allocating suffix. Its fast `Cannot_Be_Superflat` flag can return immediately;
otherwise the helper follows endpoint types, then either punts or requests two
`UI_To_gnu(..., sbitsizetype)` calls and one constant MINUS `size_binop`
(`:7049–7095`). It must be charged even when its Boolean answer is false.

The already established endpoint-to-earlier-type ordering applies to each
walk: a selected Main endpoint does not have its newly defined subtype as its
Etype. Following the low walk chooses the earlier subtype's high endpoint;
following the high walk chooses its low endpoint. Both strictly decrease that
type order. Integer is a base type and stops the loop. Positive/Natural, when
reached, have literal Integer endpoints. Thus each walk takes at most Ts+1
body iterations; the two walks together take at most `2(Ts+1)` per request.
There is no loop counter, recursive helper call or temporary vector in these
walks. Add at most `2Ta(Ts+1)` pointer-following iterations, with no new trees
from the walk itself. A nonliteral terminal makes the helper return false.

Every terminal integer literal has magnitude at most2^31 on the current
Integer-bound frontier. It occupies at most three base32768 digits. Supplied
signed bitsizetype has precision128 on the retained target, so `UI_To_gnu`
does not widen/retry or construct a type. Its accepted three-digit allowance
is13 scalar-constant requests, including the final conversion. Constant
MINUS adds one. The mandatory additive correction is therefore

```
predicate scalar-constant requests <= (2*13+1)Ta = 27Ta
current first-kernel C             <= 9Ts + 83Ta + 42Tl + 12Tp.
```

The subtraction operands are within signed32 and1; the result fits signed128.
No invalid division, dynamic shift, symbolic matcher or Ada numerical append
occurs here. `UI_To_gnu` reads existing Uint tables; it does not allocate Uint
entries. Constants and their caches consume the original representation and
shared-backing interfaces. This is a missing conservative accounting term,
not an observed overflow or proof that any old aggregate ceiling is exceeded.

## Source classification and constant helper closure

Define Ss as selected Main signed-subtype identities whose two normalized
endpoint roots are `N_Integer_Literal`; Sl as literal-subtype identities whose
low root is such a literal, including the null-literal bypass; and Sa as
constrained String subtype identities whose associated index subtype has
constant endpoints obtained by this classification or the fixed Standard
Integer/Positive endpoint construction. A literal subtype used as a dependency
must first satisfy the Sl rule. These are classifications of the completed
frontend tree described by the source derivation, not values observed after
running GCC. A name known to Silver, or a known runtime String length, does
not by itself satisfy the rule. A subsequent extension to static names must
prove the selected native entity-reference path separately.

The classification is inductive over the earlier-type order. Ordinary folded
numeric/literal bounds, fixed Image buffer bounds and standalone String literal
bounds are examples. A variable Image position or input attribute is outside
it. No complete program is rejected for failing this proof branch. In mixed
Main programs the remaining families keep their original weighted roots.

`Ss<=Ts`, `Sa<=Ta`, `Sl<=Tl`, with the original disjoint entity accounting.
Association misses translate at most2Ss signed endpoints and Sl literal low
roots. `trans.cc:6610–6638` sends each to one supplied-type `UI_To_gnu`, whose
result has the requested type and no overflow. The final conversion tests at
`:8880–8960` add nothing for that result. Static signed bounds clear the debug
variable demand in `elaborate_expression`; `_1` sees a constant and returns it
without a VAR_DECL or SAVE_EXPR (`decl.cc:7548–7657`). Therefore add26Ss+13Sl
scalar constants for this source translation, before the other residual rows.

All subsequent selected array-bound operands are INTEGER_CST. This invariant
survives integral conversions, range construction, superflat selection,
layout and natural rounding. In particular, a superflat range is normalized
by the native branch; this does not change #207's separate raw frontend
negative-extent arithmetic. `max_value` is not called, since the index endpoints
are not declarations. `multiple_of_p` on two constants uses its inline
wide-integer predicate and creates no tree. Constant sizes never enter
`variable_size`; SAVE traversal requests disappear on these selected paths.

The former residual entries now have these cumulative scalar-constant costs:

| Entry | Sa contribution | Sl contribution |
| --- | ---: | ---: |
| Ordinary conversion, at most one constant |7|4|
| `fold_convert`, at most one constant |6|8|
| `size_binop`, at most one constant |17|12|
| Selected `fold_build2`, at most two constants |6|4|
| Scalar gigi binary helper |5|5|
| Scalar gigi conditional helper |2|0|
| **Additional helper constants** |**43**|**33**|

The gigi binary allowance is two operand conversions, a two-request constant
fold, and one result conversion. It covers the GE and PLUS sites, with no
modulus, record or complex alternative. The conditional converts its two
constant arms and uses a scalar Boolean constant test. Unlike a constant binary
fold, its ternary folder does enter `generic_simplify`; the exact rule
`match.pd:6231–6238` returns the selected existing arm, with no replacement
expression or repeated capture. This is a closed constant-condition case,
not an assumption that every matcher entry is free. No fallback COND_EXPR or
SAVE-prefix COMPOUND_EXPR is constructed. Original layout C allowances remain
conservative even where these rows charge an overlapping constant operation.

Before annotation, fully classified local-family constant coefficients are
`[35,126,88,12]` in Ss/Sa/Sl/Tp order. They include the general #209 repair,
source translation and the tree-constructor component of all formerly weighted
helper entries for these classified type paths. The earlier K/D/R/Lg/U bounds remain valid; this result
does not remove their conservative unused dummy/debug/SAVE allowances.
Names, associations, declarations' insertion, type/constant hashes and other
metadata remain in the separately named M owner.
Wide-integer arithmetic workspace and physical native frames retain their
existing owners too. This is not a completed allocation/slots/local-storage
vector F for an entire helper invocation; its formerly symbolic tree demand
is now explicit on the classified path.

## Constant sizes close Q and its numerical callback demand

The unpadded classified arrays finish with nonnegative constant TYPE_SIZE
`8L`, where `0<=L<=Integer'Last`; `rm_size` returns the same constant. Each
common finisher has at most two annotation calls, even if a cache would permit
reuse. Hence `Qc<=2(Sa+Sl)`. No failed-inner-left retry, declaration, component
reference, unsupported node or symbolic operation is traversed: the input
INTEGER_CST immediately returns through `UI_From_gnu`.

The maximum size is17179869176, strictly below2^35 and signed64. The conversion
therefore succeeds using the existing signed32 fast path or its fixed
five-word vector. Each call appends at most one Uint and five digits, and
requests at most31 GCC constants. No `Create_Node`, Rep_Table addition,
annotation-cache record or dynamic-variable serial increment is made.
Keeping the earlier conservative T alignment callbacks yields

```
GCC annotation constants <= 31Qc <= 62(Sa+Sl)
Uint entries              <= Qc+T
Uint digit words          <= 5Qc+3T
UI_From_Int cache calls   <= Qc+T
Rep_Table/cache/serial additions = 0.
```

The alignment allowance can be sharpened because local alignments are small,
but is retained to compose with the first kernel. A failed native allocation
does not admit a larger successful prefix. Incoming Uint/cache state is not
reset: append/index and geometric backing conditions must be checked on
`incoming_entries+Qc+T` and `incoming_digits+5Qc+3T`, using the retained
callback-table transfer and current #207 frontend demand. For an unsigned
byte-size product also include the element sizes8/4 and the existing growth
formula, not just logical counts. This unit supplies the new demand and local
conversion guards; it does not claim the complete process has that headroom.

Including this annotation allowance, the classified constant coefficients are
`[35,188,150,12]`. Equivalently, for mixed programs add
`26Ss+105Sa+108Sl` to the repaired first-kernel C. Replace only the corresponding
classified tree-constructor component of F and the classified annotation
callbacks; preserve the other F components. Do not count the closed tree terms
and their old symbolic tree allowances as disjoint allocation events.

## Bounds-template conversion, validation, sorting and backing

Take a `build_template` call whose array is a completed classified Sa/Sl
constrained String and whose template is the completed Standard.String XUB.
XUB has two Positive32 fields, natural offsets0/4 bytes, bit offsets0 and
sizes32; its size is64 bits. `build_template_type` creates or reuses exactly
that pair for one dimension (`decl.cc:7265–7416`); no extended-access, bitfield,
reverse-storage or padding option is selected. The source-domain attachment
and required imported completion state are discussed below.

The two `convert` calls produce Integer constants in the field types, at most
one request each. Consequently there is no actual placeholder anywhere in the
result values; both substitutions return the same leaves with no allocation.
`gnat_build_constructor` tests these two values. `initializer_constant_valid_p`
returns the preexisting null-pointer marker immediately for INTEGER_CST
(`varasm.cc:5101–5109,5328–5341`); the bitfield predicate is not called.
Readonly/side-effect/constant flags require no recursive traversal or storage.

The constant two-field record invokes `vec::qsort`, which calls `gcc_qsort`.
For n=2 and element size16, its buffer-size calculation is16 and selects its
256-byte automatic scratch, not xmalloc. The sorting network performs one
comparator call and reorders two eight-byte chunks. Checking is disabled in
the retained configuration, so no `qsort_chk` pass occurs (`sort.cc:154–175,
193–205,255–274`). The comparator computes two constant bit positions using
one conversion, one multiplication and one addition each: at most six scalar
constant requests. The positions are0 and32, so their comparison is nonzero;
the unsigned DECL_UID subtraction tie-breaker is unreachable. No UID-distance
assumption is needed.

The final constructor is a24-byte `tree_constructor` (typed16 + vector pointer8),
one fresh node. Its element vector's first reserve requests72 bytes and holds
at least four elements; the second append requires no growth. Its retained
rounded request is at most512 bytes, as proved in the first kernel. Each
constant requests at most40 bytes, including abandoned cache candidates.
For Dc such bounds-template calls the closed direct export is

```
constant requests       <= 8Dc
CONSTRUCTOR nodes       = Dc, caller bytes24Dc
element vectors         = Dc, caller bytes72Dc, rounded slots<=512Dc
stored elements         = 2Dc
total caller bytes      <= (8*40+24+72)Dc = 416Dc
separately rounded slots<= 512*(8+1+1)Dc = 5120Dc.
```

The deliberately loose512 bound applies individually to each of these ten
small requests. Constant-cache vectors, at most `min(8Dc, participating_types)`,
still add at most2040 caller bytes apiece, using their existing backing transfer;
shared constant-hash and GGC page metadata/collection are separate. There are
two temporary16-byte constructor elements and one256-byte sort scratch object
per invocation; these are logical automatic objects, not a complete native
frame bound. The vector length2, initial capacity4, recovered capacity<=31,
sort product16, offsets0/32 and precision<=128 all fit their native fields.

## Concrete callers and fixed imported entry states

The complete retained `decl.cc`, `utils.cc`, `utils2.cc` and `trans.cc` files
have six `build_template` call sites (plus its definition):
ordinary nonnull constrained-pointer to fat-pointer conversion;
extended-pointer conversion; conversion to a template-containing record;
default aliased-object construction; and the two fat/thin/extended allocator
initialization alternatives. The latter five are outside ordinary Main's
constrained String storage: no extended accesses, no aliased/template-containing
Main objects, and secondary concat allocation returns an ordinary pointer to
a constrained String. Fixed imported objects have a separate owner. These
exclusions do not suppress the first, ordinary fat-pointer adaptation site.

For a direct `Call_to_gnu` String actual whose completed constrained subtype
satisfies the classification, including constrained array types exposed by
its view/address peeling, let Pc count its **source traversal occurrences**,
not distinct node IDs or distinct values. The accepted call interface supplies
at most8Pc ordinary/unchecked input-adaptation roots. Each such conversion can
enter `convert_to_fat_pointer`'s ordinary constrained-pointer alternative at
most once: removing existing array-view wrappers decreases that spine; the
result is already a fat pointer; and its final P_ARRAY field conversion is an
ordinary pointer conversion with no template call. Thus its bounds-template
subcalls satisfy `Dc<=8Pc`. These actual positions are included in the ordinary
source-visits interface, so `Pc<=V_Main` with visit multiplicity preserved.
This attaches the closed template cost to a source caller family. It does not
price the enclosing fat-pointer constructor, pointer/address folds, other
executable conversion roots or assert `Dt=8Pc` for the entire compiler.

The completed-XUB requirement is essential. A null fat-pointer conversion can
run while its bounds type is dummy and constructs an empty bounds constructor
instead (`utils.cc:4810–4835`); it is not this two-field kernel. The demanded
Standard.String graph can be entered cold, already complete, or with a dummy
fat-pointer graph created by the input access-all type. On full String
conversion the dummy branch preserves the original fat fields, copies their
old view for fixup, and completes the bounds type (`decl.cc:2229–2261,
2323–2338,2426–2440`). `build_template_type` either reuses existing bound fields
or creates the pair before finishing it. Complete Character and Integer come
from startup; Positive must be completed or converted. A local Sa/Sl lookup
demands its Standard.String parent before constructing its own index/array.

The full-conversion exit can process **incoming** incomplete/deferred queues
(`decl.cc:5065–5117`). Their construction, pointer-copy/fixup work and lifetime
are not covered by the literal-only cold graph's empty-queue result. This
continuation establishes the required stable two-field endpoint of that graph
for this helper, not the cumulative cost of every way to reach it. Compose
the existing cold result only at its own entry state; retain separate fixed
dummy/fixup entry demands for general Main. No new fixed graph is charged once
per descriptor call.

## Exact remaining dynamic recursion and the next decisive argument

The unresolved term is not an unspecified large compiler routine. A reachable
dynamic constrained-array lower bound L takes the source path
`decl.cc:2801–2813 -> size_binop(MINUS,L,1) -> fold_build2_loc ->
fold_binary_loc -> generic_simplify`. Rule `match.pd:2199–2203` transforms the
minus into `(plus L (negate 1))`. The GENERIC generator emits a recursive
`fold_build1_loc(NEGATE,1)` followed by `fold_build2_loc(PLUS,L,-1)`
(`genmatch.cc:3450–3485`), with the constant negation returning before matching.
If L already has constant arithmetic, the association rules at
`match.pd:4407–4444` create further folded constants/conversions/PLUS or MINUS
results. This is direct type-helper demand, not merely later executable code.

Likewise the dynamic high selector enters the conditional distribution helper
through array extent subtraction (`fold-const.cc:11052–11138,7019–7103`).
That helper constructs both arm candidates before deciding whether to return
the conditional; a rejected candidate's allocations still count. Each arm
reenters `fold_build2`, and an accepted result reenters `fold_build3`.
Generated repeated captures can invoke `unshare_expr`
(`genmatch.cc:3590–3602`). The specific subtraction rule uses L once, but that
fact is not a universal exclusion of repeated captures in other reachable
rules. Do not charge only the final extent graph.

The current sixteen-Ada-node endpoint bound counts names as leaves. GCC
attribute lowering may reuse earlier type-bound graphs, and max_value can
follow a declaration initializer; that source bound is therefore not a bound
on these operand graphs. The63 source-operator budget does not count generated
size operators. `elaborate_expression_1` can return readonly-derived arithmetic
unchanged (`decl.cc:7586–7617,7657`). `save_expr` skips arithmetic and recognizes
readonly or existing SAVE/TARGET leaves (`tree.cc:4079–4106,4132–4213`), so the
presence of variable_size does not establish an opaque one-node annotation
root. Generic `multiple_of_p` even descends into a SAVE. Finally the existing
Q recurrence counts failed inner-left retries and can grow exponentially in
its actual conversion/MULT spine; no proof currently limits that spine to the
constant case above.

The smallest decisive extension is a **type-bound shape invariant and ranked
rewrite transfer**, not a proof of arbitrary GCC folding: (1) classify all
normalized bound leaves as literal, actual declaration, stable descriptor
reference or previously completed type-bound graph, retaining their dependency
rank; (2) close the reachable signed32/unsigned64/unsigned128
conversion/add/subtract/comparison/conditional/constant-scale rules, including
candidate arm construction, cancellations and conversion barriers; (3) assign
a decreasing lexicographic rank to every recursive rewrite edge and separately
price structural copy/predicate walks; (4) export both cumulative F and the
actual final size grammar, then derive Q from that grammar. The existing cold
String trace handles two opaque placeholder-reference leaves; it cannot be
substituted for these more general leaves. A concrete failure of the proposed
rank, rather than the remaining volume, is the trigger for a Max escalation.
No change of the selected Extra High setting is claimed in this round.

## Evidence and round record

`sources.tar.gz` retains the exact required complete files at GCC
6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea. The manifest reconciles each file with
an already retained identity; LF witnesses retain the exact branches above.
The offline check validates identities, coefficients, signed boundary cases,
descriptor layout/arithmetic and subset additivity. It does not execute GCC,
the pattern generator, a regex engine, prover or predecessor checker. The
source argument and claimed reachable cases require independent review.

Selected author: GPT-6 Astra / Extra High. Runtime confirmation, total author
elapsed time, tokens and cost are unavailable. Intended result: cross the
constant helper/annotation/descriptor joins and identify the decisive dynamic
proof. Material finding: #209's previously omitted allocating predicate.
Completed outputs and offline elapsed time are recorded in `current.json`.
The focused check passed18 complete sources,59 LF witnesses,10 pinned inputs,
16,875 subset assignments and400 signed endpoint pairs in0.353941 seconds on
Linux x86_64. The arithmetic checks exercise representational boundaries; they
do not infer native behavior from those finite pairs.
Native execution time is zero. Independent review and root integration are
pending; #201 and #119 remain open.
