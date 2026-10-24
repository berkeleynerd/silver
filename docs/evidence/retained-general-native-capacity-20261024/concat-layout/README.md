# Original concat bounds: conversion, superflat layout and annotation

2026-10-24 UTC, #201 under #119. This continuation imports scalar author
`bba92a0c0685cffdf8c9e179f6b36aafea81c4be`, its purity repair
`de0d23d2faf996931861920d2dcd51d80995ad93`, and acceptance
`1cd353c2410a483d33ee9e4be6c2487e3261f17d`. Earlier packets are immutable.
The result is a local transfer for the **original** concat-bound family below,
including mixed contracted/captured endpoints. It is not full concat, a new
admission condition, or completion of #201/#119.

Selected author: GPT-6 Astra / Extra High. Runtime confirmation and token/cost
measurements are unavailable. First recorded clock: 07:08:21 UTC. The focused
check records its completion, elapsed check time and elapsed time since that
clock. Native compiler/prover/Lean time is zero; no predecessor check runs.
Independent review is required at the ensuing exact author commit.

## Domain and imported costs

Retain GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, Linux x86_64,
O0 GENERIC, regular local Main, the natural Character/String layout,
precision <=128, completed fixed/import dependencies, and the accepted
no trapv/sanitizer/fold-checking premises. No SSA, volatile scalar, branch
actions, unconstrained-parameter cache or placeholder is added. The explicit
F1 premise is **TREE_SIDE_EFFECTS false on conditions, scalar arms and
selectors**; readonly alone never substitutes for it.

Use exactly the accepted seed providers (initial input, Integer Image, their
provenance-preserving aliases, fixed lower1 families), aggregate captures,
selected-low capture and scalar endpoint grammar. Names denote native
identities, not equal runtime values. G is the fresh final signed Integer32
aggregate declaration. L is literal1 or an already completed signed Integer32
declaration; the potentially long selected-low spine is behind its M capture.
For r=Result_May_Be_Null and d=L+(G-1), the original endpoints are

```
r=0:  A=L,                   B=d
r=1:  A=P_low ? a : L,       B=P_high ? c : d.
```

Both P nodes mean G==0, but are separately constructed, and either may be
inverted to NE with exchanged arms. a is the last low (literal1 or input-low
declaration). c is the last high (input-high declaration, Image position V
with at most one same-width signed conversion, or literal0 for an empty
fixed tail). d is G when L=1; otherwise it has two PLUS nodes, either
L+(G+(-1)) up to operand order, or (L+G)+(-1). G differs from every incoming
endpoint, L and any debug bound capture.

This packet starts after that scalar construction. Reuse its
`520J+128s+368r+288m+344` bytes once per source event. Its maximum-query pair
is `2s+11` constants and four unary nodes, or `80s+568` bytes per receiving
identity; it is imported separately, not included again in the layout table.
An original non-declaration bound does not invoke the declaration query at
all; the maximum-size caller falls back to the bound type's constant extrema.
Thus update_n_elem and the final maximum-size multiply have constant inputs.

Bound elaboration can replace a nonconstant endpoint by a fresh readonly
debug declaration, with initializer the original scalar; references do not
expand that initializer (`decl.cc:7532–7657`). Allow both endpoints to be
captured independently as a conservative superset. At most two VAR_DECLs
and two DECL_EXPRs per receiving signed index identity cost 576 raw bytes.
This is separate from the scalar producer's M capture. Constants remain
constants. Otherwise gnat_save_expr reaches save_expr, whose readonly/pure
test returns these expressions unchanged (`utils2.cc:3068–3092`,
`tree.cc:4078–4166`). In particular a readonly COND is **not** a SAVE cut.

The scope is the original pair before the optional static allocation-high
replacement in exp_ch4.adb. Its generated dynamic result slice, assignment
slices, nested concat providers and other forced captures still need their
own producer attachment. This is not a claim that every admitted concat
has the imported provider grammar.

## Conversion and the paired-distribution guard

Write U(x) for signed32-to-unsigned64 sizetype conversion, and W(x) for
unsigned64-to-unsigned128 bitsizetype conversion. Existing same-base
conversions and the range factories' exact sizetype conversions are identities
(`decl.cc:2716–2722`, `utils.cc:2857–2871`, `tree.cc:7460–7484`).
convert_to_integer uses a NOP for these full-mode non-narrowing conversions,
then gigi's convert calls fold on the returned root (`convert.cc:660–698,
981–984`, `utils.cc:5474–5486`, `fold-const.cc:13518–13569`). That second fold
does not recursively refold its descendants. A retained canonical COND is
already ordered, so it does not allocate another conditional merely because
of this extra root visit.

U distributes into a selector's arms. Its result precision is <=BITS_PER_WORD,
so the pull-out clause is false. Each dynamic arm keeps at most one widening,
or a conservatively allowed same-width wrapper plus that widening. A
same-signedness same-width conversion of Image V can contract; no runtime
nonnegativity premise erases U. The arithmetic d stays **inside** U: the
arithmetic-conversion rule at match.pd:9687 requires narrowing with widening
inner operands and does not apply to this 32-to-64 widening.

The central guard is `fold-const.cc:7076–7083`. For a nonconstant other
operand, conditional distribution returns NULL before conversions or arm
folds if that other operand is COND_EXPR, has side effects, or either
conditional arm is TREE_CONSTANT. Therefore

```
GE(COND(...), COND(...))
MINUS(COND(...), COND(...))
```

do **not** distribute in this GENERIC route, even when their conditions are
operand-equal. Both caller attempts reject before making arm candidates.
The paired rule at match.pd:6277 is VEC_COND-only. The scalar binary rules at
8678/8684 and scalar comparison rule8663 are GIMPLE-only. Neither identical
EQ node pointers nor matching polarity is required or assumed here.

For a constant other operand, distribution may instead enter both arms.
For a pure nonconstant non-COND other operand and two nonconstant arms it
also enters both, then returns NULL if neither result is TREE_CONSTANT
(`:7085–7103`). Those discarded requests are charged below. A second caller
attempt is considered separately; it does not refund the first.

W can distribute through two nested selectors in the constant-low case.
If an inner conditional returns two W(NOP_u64(...)) arms, the result is wider
than a word; the folder constructs a **plain** COND of the u64 inner values
and a **plain** outer NOP, then returns (`:9263–9308`). The two provisional
unaries and provisional conditional remain allocated. This is not a recursive
pull-out/back-in cycle. The signed32 -> unsigned64 -> unsigned128 chain is
not contracted on the strength of a nonnegative runtime length.

## Complete original-bound case split

All size arithmetic below is wrapping unsigned64. Comparisons of A and B
remain signed32. Standard.String's base is not flat; B is nonconstant in
this family. Thus the constant-overflow, constant-null and constant-high
alternatives at decl.cc:2724–2796 do not introduce extra branches. Put

```
X=U(A), Y=U(B), C=GE_s32(B,A), S=X-1, Z=C ? Y : S.
```

For the superflat route, each layout computes D=Z-X, N=1+D,
bits=8*W(N), bytes=1*N (`stor-layout.cc:2662–2730`). The frontend sets
Cannot_Be_Superflat to !r (`exp_ch4.adb:3327–3331`). When r=0 the shortcut
uses Z=Y. When r=1 the uncaptured IF endpoints have base Integer Etypes,
so the endpoint subtype walk cannot prove the shortcut. A copied completed
flag may safely select the shortcut; its smaller graph is included. Do not
substitute unsigned GE(Y,X) for C: signed intervals crossing zero refute it.

1. **A retains a selector.** B is a selector or a fresh debug declaration.
   (A selector with uncaptured nonnullable arithmetic B is not in the source
   dispatch: r=0 has A=L; a nullable high cannot lose its test except for the
   L=1/empty-tail contraction, which also makes A=1.) For two selectors C
   rejects paired distribution. For a fresh B declaration, the attempt over
   A's two atomic arms creates two nonconstant comparisons and is discarded;
   freshness excludes a reflexive constant comparison. C is retained.
   S distributes the constant -1 into A's two arms; constant1 becomes0 and
   a declaration arm becomes PLUS(U(leaf),-1). Z retains its outer C and
   D rejects both paired-COND attempts because X is still a COND. Consequently

   ```
   bits = MULT_u128(W(PLUS_u64(MINUS_u64(Z,X),1)),8).
   ```

   The compare-to-MIN/MAX helper cannot identify C's signed conditional
   operand with an armwise converted conditional: operand_equal_for_comparison_p
   only strips same-mode wrappers or one **outer** widening, not conversions
   inside COND arms (`fold-const.cc:4372–4409`). The fresh-declaration variant
   can match that first equality, but its other endpoint is not S=A-1,
   so its second equality fails without construction. C is GE/LE of endpoints,
   not P's EQ/NE of G and0; nested-condition equal/inverse rules do not apply.

2. **A is a declaration and B retains a selector.** C tries the two signed
   comparisons c>=A and d>=A. The first remains nonconstant: input H and L
   are distinct, Image V differs from every bound capture, and literal0
   compared with a full-base declaration is nonconstant. If A=L, an
   undefined-overflow d comparison can cancel L and become a comparison of
   fresh G with0 or1. If A is a fresh debug cut it cannot cancel L. In wrapping
   mode the shared-addend relational rule is inapplicable. In every case the
   second result is still nonconstant. Thus C discards both candidates and
   keeps GE(B,A). No semantic assumption about G's value is used.

   For D, the outer distribution is allowed. Its first arm E=Y-X can itself
   attempt distribution through Y; if it does, both arm differences remain
   nonconstant and are discarded. The ordinary narrowing rule at
   match.pd:4534 requires result precision <= the inner precision, and
   split_tree does not strip a widening. **The separate rule4571 does permit
   U(L+(G-1))-U(L) -> U(G-1) under undefined signed overflow.** This is one
   unary candidate instead of the unsimplified binary; it remains nonconstant
   and is still discarded by the enclosing E distribution. In wrapping
   signed32 mode its precision/overflow guard fails. A
   constant c instead triggers the pre-arm guard. Its second outer arm
   (X-1)-X cancels to the existing u64 -1, so the **outer** distribution succeeds:

   ```
   D = C ? E : -1
   N = C ? PLUS_u64(E,1) : 0
   bits = C ? MULT_u128(W(PLUS_u64(E,1)),8) : 0.
   ```

   The true-arm candidate work that was rejected inside E still counts.

3. **A=literal1 and B retains a selector.** The source identities matter:
   last_low must also be1. A fixed empty tail has c=0 and d=G, whose scalar
   selector contracts to G. Therefore the surviving case has c=Image V,
   with its possible signed same-width wrapper, and d=G. Write P for either
   polarity with the corresponding arms. Distribution against constant1 gives

   ```
   C = P ? (c>=1) : (G>=1)       [each comparison may canonicalize to >0]
   Y = P ? U(c) : U(G)
   D = C ? (P ? U(c)-1 : U(G)-1) : -1
   N = C ? (P ? U(c)   : U(G))   : 0.
   ```

   On +1 each inner -1 cancels in wrapping64 arithmetic; all provisional
   shifted arms and conditionals are counted. The W pull-out described above
   yields `bits = C ? MULT(W(Y'),8) : 0`, where Y' is the same arm grammar as
   Y but may be a newly allocated plain COND. C has two dynamic Boolean arms,
   not a constant arm that would create a truth-AND/OR replacement. Its P
   condition and Y's P may have opposite polarity; the argument preserves
   arm correlation and does not merge them. The B-declaration alternative
   has the accepted simple low1 leaf layout, with the genuine signed GE
   superflat test retained when r=1.

4. **Both endpoints are declarations, or r=0 has arithmetic B=d.** Two
   declarations use the accepted input layout shape (their query initializers
   still use the separately imported concat query transfer). For r=0 the
   source flag removes the superflat branch: N=1+(U(d)-U(A)), or the accepted
   low1 cancellation if A=1. The shared-addend cancellation alternative under
   undefined overflow is N=PLUS_u64(U(PLUS_s32(G,-1)),1). It retains both
   arithmetic widths and reaches annotation's converted-inner PLUS path. Its
   -1/+1 constants cause that path's zero-sum early return, including when the
   child returns No_Uint; no retry follows. It is included explicitly in the
   graph certificate. Wrapping signed32
   retains the uncancelled difference. Debug captures shorten these operand
   graphs without enabling
   a new arithmetic-arm comparison. No case above is disposed of merely by
   saying that a contracted endpoint is smaller.

## Fold rank and cumulative candidates

The new reachable comparison continuations are bounded explicitly. For
`d>=L`, match.pd:2953 can remove the shared addend only under undefined
overflow. For `(G-1)>=0`, the constant-offset rule9884 and positive-constant
rule7376 remove the -1 offset and canonicalize >=1 to >0. Alternatively
maybe_canonicalize_comparison_1 removes the magnitude-one offset using two
constant requests and a PLUS-zero request (`fold-const.cc:9774–9840`).
For `(L+G)-1>=A`, that handwritten path can first produce `(L+G)>A`, after
which at most the shared-addend rule applies. A PLUS-zero over a declaration
can allocate a NON_LVALUE candidate. The resulting leaf comparison has no
reverse transformation that restores the offset or removed addend. Allow
eight constants, four unary nodes and four binary nodes for either arm's
whole arithmetic-comparison continuation; only one such arm occurs in C.
The other arm and the retained outer comparison take at most two more
binary nodes. The eight-binary GE envelope below is conservative.

Other successful generated rules are the imported constant/identity,
MINUS-to-PLUS, PLUS-zero, MULT-one, constant association and conversion-chain
rules, plus (X-1)-X and the guarded widened shared-addend cancellation4571.
Widening, distinct capture identities and
the absence of multiply/bitwise/SSA/pointer/real operands exclude the other
root patterns. Equal/inverse nested tests use *operand* equality when reached;
no source assertion identifies the two P node addresses. Their C versus P
shapes here prevent those nested rules. The lexical audit is retained as a
review aid, not a semantic execution of GCC.

The rank in rank.json distinguishes outer and inner MINUS-to-PLUS dispatch
**before** conditional distribution, then arm fold, conditional completion,
one operand-order change, comparison offset/addend removal, conversion-spine
reduction and constant calculation. A minus request with a dynamic integral
NOP/COND right operand is not cheaply negatable; it enters distribution
directly. The constant-right request first negates its constant and becomes
PLUS (`fold-const.cc:488–638`, `match.pd:2200`). Branch recursion strictly
decreases pending selector depth. MINUS-to-PLUS decreases phase despite equal
height; constant association removes a constant-bearing arithmetic layer.
For comparison, the offset-first path removes the outer -1 before the shared
addend, while the addend-first path removes the shared L before the remaining
G-1 offset and positive constant. Both remove the same finite resources and
cannot restore them; the certificate gives separate paths for both orders.
Rebuilt CONDs do not reenter a pending
binary distribution. The W pull-out uses plain builders and returns. The
extra gigi fold is a separate final-root visit, not a loop back through convert.

For a layout size-binop request the largest conditional frontier has three
conditional activations (one outer and at most two inner candidates), two
dynamic arithmetic leaves, and at most two constant leaves. The mixed
subtraction can add two discarded inner binary candidates and one retained
inner binary before constructing its outer COND. The constant-low +1 stage
can create discarded view/identity candidates at both inner leaves. The
following deliberately rounded entry envelopes include these alternatives,
the one initial shift-negation and operand inversion; they do not just count
final nodes. No new scalar type or repeated replacement-capture unshare is
needed by these replacements: each retained generated capture occurs once.
The fold_buildN wrappers allocate their fallback only on a NULL fold result
(`fold-const.cc:13880–14035`). The integral fold_convert route returns directly
at :2633–2676, bypassing the location-copy exit; its same-type route is also
an identity. No retained condition in these layout cases has a constant test
or 1/0 Boolean arms that would reach conditional completion's location-copy
return. Thus protected_set_expr_location_unshare's possible shallow copy
(:245–265) introduces no additional constructor in these routes.

| Residual entry | Entries/receiving array | C | U | B | T |
| --- | ---: | ---: | ---: | ---: | ---: |
| Direct integral convert |7|2|4|2|2|
| Range/layout fold_convert |6|4|4|2|4|
| size_binop |17|8|4|6|4|
| gigi signed comparison |1|8|4|8|4|
| gigi conditional |1|0|0|1|1|
| Total ||**182**|**124**|**137**|**111**|

C/U/B/T mean cumulative constant/unary/binary/ternary requests. In particular,
W of the nested constant-low N allocates up to three unaries and three
conditionals (two provisional inner unaries/one conditional, one plain
inner conditional/outer unary, one outer conditional), plus a converted zero.
This fits the conversion row; none of those provisional requests is refunded.
GE's failed candidates are in its own row. Scalar source construction and
maximum queries are separate owners. The three kernel constant-overflow
alternatives are absent because B is dynamic; retain the other original
7/6/17/1/1 multiplicities conservatively. The repaired27-per-array range
predicate allowance stays in the kernel and is not added here.

Using accepted 40/32/40/48 raw request bytes gives **22056 bytes per receiving
array**, with 731 expression operand slots. Add 576 per qualifying signed
index identity for its possible debug declarations, and the imported query
pair where actually attached. These are raw caller requests, not GGC rounding,
constant-cache vectors, metadata, physical residency, native frames or a
whole-helper workspace claim. Existing kernel type/declaration terms remain.

## Annotation, round-up and helper operand weights

Every new node points only to completed operands. Declarations cut edges to
initializers/types; all expression graphs above are finite and acyclic.
The conservative largest case1 grammar, allowing a redundant same-width
Image wrapper even where it contracts, has these bounds. O is the unfolded
ordinary operand-occurrence count; Q includes the accepted failed-child retry
and synthetic-node charging rules. Counts do not deduplicate shared children.

| Root | Height | O | Q |
| --- | ---: | ---: | ---: |
| A, original low selector |2|6|6|
| B, original high selector |3|11|12|
| X=U(A) |2|8|8|
| Y=U(B) |4|14|15|
| C=GE(B,A) |4|18|19|
| S=X-1 after distribution |3|12|14|
| Z=C?Y:S |5|45|49|
| D=Z-X |6|54|58|
| N=1+D |7|56|60|
| W(N) |8|57|61|
| bits=8*W(N) |**9**|**59**|**63**|

Q's four extra units here charge the sign-bit-set -1 PLUS occurrences in
the high arithmetic twice and the shifted low arms twice. Neither the final
MULT nor the outer +1 in this largest case has a converted *same-code* inner
operation, so its converted-inner failed-left retry is absent. The case4
guarded cancellation reaches converted-inner PLUS, but its -1/+1 zero-sum
early return prevents a retry even when the child fails. The conservative
full-descendant charge still gives its N O6/Q7 and its final bit root O9/Q10;
it does not subtract work for that early return. A separate nonzero
converted-inner MULT example checks the general failed-child retry charge.
No BIT_AND synthetic branch occurs.
The other cases have no greater height/O/Q; check.py builds their explicit
supergraph variants, including both signed high associations and all P
polarities. The uniform height theorem would give B(9)=39365; the sharper63
uses the complete case grammar and the retry-aware charge.

Let Ka count distinct receiving array identities in this original-bound family
whose roots have not already been assigned a constant/input/Image/prefix
specialization. Count both finishing occurrences, even if TYPE_SIZE and rm_size
point to the same tree or one failed call is retried. Then

```
Q_OriginalConcat <= 126 Ka
annotation constants <= 4032 Ka
annotation unary nodes/slots, maps, Rep_Table and serial increments <=126 Ka
annotation raw GCC caller bytes <=167328 Ka
Uint entries <=378 Ka; digit words <=1386 Ka
logical appended callback payload <=12600 Ka.
```

Global alignment's T allowance and incoming states are still added once.
For these roots replace their open generic Q term; do not add both. Layout
plus this annotation export is **189384 Ka** raw bytes, before the separately
owned debug declarations, query pair, scalar event, kernel and backing.
This formula is a local occurrence attachment, not an asserted global Ka
count from syntax. Its whole-program attachment remains open.

Round-up of the final bit root to8 succeeds: MULT tests its constant factor8
first; a surrounding COND tests both arms and its zero arm succeeds. This
takes at most four multiple_of_p activations, does not descend into N/Y, and
does not allocate a replacement divisor (`fold-const.cc:14233–14347`). Byte
multiply by1 can create one NON_LVALUE wrapper when N is COND; that request
is counted but does not become the bit-size annotation root. Byte round-up
to1 is immediate. No rounding BIT_AND graph is introduced.

Readonly and false effects propagate through each selected scalar builder.
For these graphs skip_simple_arithmetic's first binary invariant test
succeeds, so it does not explore the later retry alternatives. Its recursive
check follows one child and its tail walk the other; CONDs are terminals for
that walk. A safe bound per invocation is 2O+1 node examinations and 2h+3
simultaneous skip/invariant helper activations: **119 examinations and21
activations** for the largest graph. contains_placeholder_p has at most59
ordinary operand activations/depth10 and returns false; no declaration
initializer or type is visited (`tree.cc:4288–4377`). Annotation has at most
11 active invocations by the accepted h+2 theorem (this grammar is sharper).
These inputs also bound the scalar operands presented to the remaining
shared equality/hash/marking helpers. They do **not** price every invocation
of those helpers, their type/metadata traversal, hash probes, machine frames
or allocator backing; those ownership joins remain explicit.

## Verification and residuals

One focused source/math check verifies accepted-input hashes and acceptance
blob, complete archived source identities, LF witnesses, lexical inventories,
the authored rank DAG, table arithmetic, polarity-sensitive finite graph
charges, distribution-gate behavior including discarded candidates, and
reduced-width plus signed32-boundary superflat arithmetic. It does not compile
GCC, run a generated matcher, execute a prover or replay predecessor checks.
The finite models corroborate this authored source correspondence; they do
not establish it by themselves.

The initial focused check passed at 07:32:07 UTC. A second focused check is
justified by the final source audit: it adds the pre-distribution dispatch and
both comparison rank paths, pins the builder/negation/location-copy sources,
and specializes the converted-inner PLUS zero-sum return. The numerical
exports are unchanged. The final receipt supersedes the initial check's
packet input set; no predecessor or expensive validation is repeated.

Remaining obligations are listed in remaining.json: nested providers and
post-replacement/generated slices, original object/Length/executable work,
global occurrence/type-copy attachment, pointer/fat-pointer adaptation,
shared helper/backing/frame composition, fixed/import incoming state and
later GCC/process phases. The prospective fixed-report launcher has a
separately reviewed same-runtime explicit --RTS/configuration-storage delta;
its proof-production GPR process must not be confused with the #89 direct
build graph or silently absorbed into old configuration counts.

The physical-resource premises, Oracle, language admission, production code,
tool pins and once-per-Why-process e<=2, two save-entering callbacks and three
saves are unchanged. There is no cumulative physical RAM/stack gate. Root
owns integration, issue/memory bookkeeping and publication. No GitHub write,
publication or live-goal change occurs in this subthread.
