# Source-derived Integer Image fold envelope

This #201 continuation under #119 starts at reviewed author input
26bd01de61242d49f4680d609b38d09e3a51925f. It closes the dynamic **Image
index/type size constructor and annotation projection** below: the height
is derived from a current frontend producer, rather than supplied as an
unknown H. It does not close all dynamic String producers, helper workspace,
shared backing, executable lowering or whole native capacity. The earlier
helper and dynamic-annotation packets remain frozen.

## Source classification and incoming state

Use the retained GCC commit 6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea,
Linux x86_64 layout, ordinary local Main gigi translation,
`List_Representation_Info < 3`, `type_annotate_only=false`, no fold-checking,
and the accepted natural-layout and integral-precision frontier. The fixed
Natural/Integer/Character/String types and position/capture object declarations
are earlier completed dependencies; their construction is charged in their
own fixed/object transfers, not erased or charged once for every endpoint.

Define Is as the number of distinct selected Main signed index-subtype entities
with low literal1 and high the internal scalar constant capturing the Natural
position of an admitted Standard Integer Image. Define Ia as the corresponding
distinct constrained String subtype entities. Copies/aliases qualify only if
they preserve these endpoint identities, existing Natural capture type and
local context. These are source/provenance classifications, not tests of a
runtime length or of a successful GCC result. They satisfy
`Is<=Ts-Ss`, `Ia<=Ta-Sa`, and `Is+Ia<=E_Main`; charge distinct identities,
including qualifying copies, not just source Image occurrences. Other String
subtypes retain the existing open residual weights.

The accepted frontend argument gives `Snn : String(1..11)`, `Pnn : Natural`,
`Image_Integer(Integer(E),Snn,Pnn)`, then `Snn(1..Pnn)` under suppressed checks
(`exp_imgv.adb:1295–1330,1410–1437`). Range forcing captures the mutable Pnn
once as a constant of **its existing Natural subtype**, then copies the range
into its index subtype (`sem_res.adb:13117–13165`;
`exp_util.adb:12678–12688,12765–12825,13098–13116`). The accepted earlier
frontend proof covers scalar constant side-effect freedom and later copies.
The original Image argument E is not a bound initializer: no arbitrary source
arithmetic is exposed by following the position capture.

Natural has Esize32, RM_Size31 and literal bounds0..Integer'Last
(`cstand.adb:1017–1028`). Its ordinary native type is signed32: the signed
subtype arm keeps the signed base representation when Esize agrees, even for
a nonnegative range (`decl.cc:1938–1970`). Neither runtime nonnegativity nor
RM_Size31 is permission to replace the signed32 native conversion semantics.

## Bound and layout shape

1. The earlier scalar capture is a readonly, nonvolatile VAR_DECL V, with
   initializer Pnn. It is not TREE_CONSTANT, because that flag requires a
   constant initializer; a mutable position declaration is not one
   (`utils.cc:3018–3090`). Identifier translation uses the existing association
   and does not substitute this initializer (`trans.cc:1187–1390`).
   Elaborating the signed subtype's low root costs at most13 scalar constant
   requests using the accepted supplied-type Uint conversion. The high root
   remains V, or one additional local readonly VAR_DECL with the same type and
   initializer V for debug information. That extra declaration costs one
   DECL_EXPR and no INIT_EXPR (`decl.cc:7534–7657`; `trans.cc:9104–9180`).
   Its fresh declaration layout copies the existing constant Natural sizes
   (`tree.cc:5567–5586`; `stor-layout.cc:661–710,805–820`); it does not
   introduce another symbolic helper. A static low bound disables
   debug-variable creation before entering
   `elaborate_expression_1`. In the following, V may denote either high-root
   declaration: its annotation operand graph is a leaf in both cases.
2. The actual range predicate proves non-superflat: the low literal is1;
   the high endpoint's Natural type leads directly to its low literal0;
   `0 >= 1-1` succeeds (`decl.cc:7049–7095`). Thus the GE/COND alternatives
   and dynamic lower-bound shift are absent. Its already repaired27Ia
   constant allowance stays in the general kernel, and is not added again.
3. Maximum-size bookkeeping does not expand the capture's initializer chain.
   A high-root declaration's initializer is a VAR_DECL; `max_value` immediately
   substitutes that declaration's constant type extremum, via at most one
   constant conversion (`utils.cc:4095–4112`). The low root is constant.
   Conservatively retain both maximum-query slots per Ia. `update_n_elem` and
   the final maximum-byte multiply therefore receive constants.
4. Converting the actual high bound Natural32 -> Integer32 -> sizetype u64
   leaves `X = NOP_u64(V)`: a same-signedness intermediate conversion is
   contracted. Range construction converts to **the incoming base sizetype**,
   not the newly allocated range subtype (`tree.cc:7460–7470`). Repeated
   exact-type conversion is identity. No narrowing, biased representation,
   pointer conversion, fresh helper type or placeholder is reachable.
5. Each of at most two array layouts calculates the length
   `1+(X-1)`. The inner MINUS becomes PLUS with the negated constant;
   commutation, constant association and the zero identity yield X. The
   arithmetic is u64 wrapping arithmetic, so this identity holds even at
   the modular boundary. `bits_from_bytes` converts X to u128; the next
   operation is multiplication by Character's bit size8. Byte size multiplies
   X by1. See `stor-layout.cc:913–929,2662–2730`.
6. The u64 conversion between signed32 V and u128 **may remain**. Removing it
   would change the interpretation of negative V; the conversion rules do
   not justify using the Ada runtime range to erase it. The bit-size result
   is `MULT(NOP_u128(NOP_u64(V)),8)` or a contraction. Round-up to8 returns
   this product: `multiple_of_p` tries the constant factor8 first, proving
   divisibility without descending into V. Byte round-up to1 returns X
   immediately (`fold-const.cc:14230–14273,16379–16400`). `variable_size` and
   `save_expr` return the existing graph: simple arithmetic leads to a
   readonly, side-effect-free declaration (`stor-layout.cc:67–105`;
   `tree.cc:4132–4166,4172–4245`). A SAVE call alone was not the proof.

Every newly constructed operand refers to an already completed operand.
Declarations are annotation cuts; their types and initializers are not
annotation operand edges. The resulting operand graph is finite and acyclic,
with **H_Image<=3**. This is a source-derived construction property.

## Reachable folding and rank

The domain of symbolic folder requests is small: conversion chains above V;
`MINUS(X,1)`; `PLUS(X,-1)`; `PLUS(1,PLUS(X,-1))` and its commuted/associated
forms; `MULT(1,X)`; and `MULT(8,W)` or its commuted form, where W is the u128
conversion of X. Other size calculations in this specialization are constant.
The literal minus-one means its u64 representation, retaining overflow flags
until a source helper explicitly clears them. Conversions never expose a
conditional, comparison, binary scalar initializer, SSA name or placeholder.

The binary source entry first handles constants, then canonicalizes a
constant left operand (`fold-const.cc:11023–11050`). The only successful
symbolic `match.pd` rules on this domain are:

| Rule | Effect and progress |
| --- | --- |
|237| PLUS by zero returns the existing non-lvalue conversion X. |
|499| MULT by one returns X. |
|2200| MINUS(X,1) calls constant NEGATE, then PLUS(X,-1). |
|4407| `(X + -1) + 1` combines the constants and calls PLUS(X,0). Its view conversions have the exact input type and vanish. |
|5721| Exact-type conversion returns its operand. |
|5806–5920| A permitted nested conversion drops an intermediate conversion; the signed32 -> u64 -> u128 barrier is retained. |

The selected GENERIC replacements use each capture once; genmatch's repeated-
capture `unshare_expr` arm is therefore absent (`genmatch.cc:3590–3602`).
`matcher-audit.json` retains all151 PLUS/MINUS/MULT-root and19 conversion-root
forms, including both preprocessor branches, with their source text and
exclusions. This is a review aid, not an executable GCC matcher or a semantic
proof by counting rules. Patterns with real/vector/function, bitwise, shift,
division, conditional, comparison or other nested operands do not match this
grammar. Equal-capture rules require equality of a dynamic conversion and a
literal; MULT's zero/negative-one cases have the wrong constant. The broad
zero-one-valued predicate cannot pass for factor8; factor1 returns at the
identity rule. GENERIC known-bit queries on these declaration/conversion
inputs perform no SSA range query (`fold-const.cc:16715–16796`).

The handwritten residual folder has no additional successful symbolic rewrite
on this grammar. Unary special cases require absent operand codes or a
narrowing multiplication. PLUS(X,-1) and MULT(W,8) reach `split_tree`, which
finds exactly two objects, so the association block's `>2` guard fails. A
possible `drop_tree_overflow` of the constant is still charged.
MULT(W,8) can attempt `extract_muldiv`: with two widenings it stops at the
wrapping intermediate expression; with a contracted conversion it may convert
factor8 once and then fail at V (`fold-const.cc:6583–6701,11773–11860`).
There is no conditional distribution or repeated failed subtree traversal.

A well-founded specialized call rank is given by the finite state graph:
constant-left association -> canonical association -> PLUS-zero -> identity;
MINUS -> constant NEGATE / terminal PLUS; constant-left multiply -> terminal
multiply; and a conversion chain -> a strictly shorter conversion chain.
Constant calculations terminate by the accepted fixed-precision transfer.
Each swap removes a pending-order flag; no case recreates it. Each association
removes the inner arithmetic operation; each conversion contraction removes a
conversion. `extract_muldiv` follows a strictly shorter conversion spine and
stops at V (its general depth guard is not needed for this argument). These
states account for recursive **calls**, including the failed constant factor
candidate, not only retained nodes. They repair the earlier height-only rank:
MINUS -> PLUS changes phase even though operand height stays the same.

## Cumulative constructor projection

Use the conservative residual multiplicities already proved for Ta, restricted
to Ia. Empty-array, overflow, GE/COND and shift alternatives are absent, so
keeping their other conversion/size slots only overcounts. The following is
an allocation envelope for **each entry**, not one allocation per helper name:

| Entry kind | Entries/Ia | Scalar constants/entry | Unary/entry | Binary/entry |
| --- | ---: | ---: | ---: | ---: |
| Direct integral convert |7|1|1|0|
| Range/layout fold_convert |6|1|1|0|
| size_binop |17|2|0|1|
| max_value on initializer |2|1|0|0|
| Total per Ia | |49|13|17|

A conversion either constructs one scalar constant, constructs at most one
new final unary node after contractions, or returns an operand. Charging both
covers all alternatives; gigi's outer `fold` of an already constructed
conversion adds no second constructor. For a size operation, two constants
cover constant negation plus a possible overflow-clearing candidate, constant
association, or the discarded converted multiplier candidate. Only one final
binary constructor can survive an unsuccessful fold. Commutation allocates
no tree by itself; its outer fold reuses the returned tree. The association
views and non-lvalue identities above allocate no unary node because X is
already a conversion, and every view has the exact same type. Constant-only
size calls cost at most one request. Multiple-of and SAVE traversals add no
helper constructor on these shapes; their direct divisor constant is already
in the kernel. No fresh type or unshare constructor is hidden in this row.

Add `13Is` low-bound constants, `Is` debug VAR_DECLs and `Is` DECL_EXPRs.
The fixed-position/capture object's own declaration remains in its object
transfer, separate from this possible additional debug declaration. Thus

```
helper constants <= 13Is + 49Ia
helper unary nodes / slots <= Is + 13Ia
helper binary nodes <= 17Ia; binary slots <= 34Ia
helper extra VAR_DECL nodes <= Is
helper expression slots <= Is + 47Ia.
```

With the accepted raw requests40/32/40 bytes for constant/unary/binary,
and a conservative256-byte raw VAR_DECL bound, the selected direct caller
projection is **808Is + 3056Ia bytes**. The VAR_DECL bound follows from
`tree.cc:1090–1100` and its inherited structures in `tree-core.h`: at most16
pointer fields and16 four-byte scalar/bitfield/padding words give192 bytes,
within256 on this ABI. This excludes declaration names, binding/statement
lists, attributes and other metadata, already separate in M. Cache vectors,
GGC rounding/backing and compiler stack frames are not included.

## Annotation attachment and mixed export

Each selected bit-size root has a MULT, at most two conversions, V and
constant8: the accepted retry-aware charge is at most5. Its converted inner
operand is a conversion or declaration, **not another MULT**, so the
converted-inner retry does not apply. This sharp calculation gives
`Q_Image<=10Ia` for the two finishing-root occurrences per Ia. The general
height theorem also gives `2Ia*B(3)=106Ia`; using10Ia is justified by the
explicit grammar, not by height alone. A constant contraction only reduces
the conservative charge. Active annotate_value depth is at most4 here.

For the rest put `Da=Ta-Sa`, `Dl=Tl-Sl` and retain actual unknown heights
h_i. The current mixed attachment becomes

```
Qc = 2(Sa+Sl)
Qd <= 10Ia + sum_(remaining dynamic root occurrences i) B(h_i)
remaining root occurrences <= 2(Da-Ia+Dl).
```

Use the accepted mixed callback formulas once with this Qd. Image's
incremental annotation projection is320Ia constants,10Ia unary nodes/slots,
10Ia16-byte maps,13280Ia raw caller bytes,30Ia Uint entries,110Ia digit words,
and10Ia Rep_Table/serial additions. Its logical appended callback payload is
1000Ia bytes. Alignment's T term is global and added **once**, not once for
each classified subset.

Combined Image helper/annotation additions to the repaired general kernel:

```
constants <= 13Is + 369Ia
unary nodes / slots <= Is + 23Ia
binary nodes / slots <= 17Ia / 34Ia
extra VAR_DECLs <= Is; annotation maps <= 10Ia
raw direct caller bytes <= 808Is + 16336Ia.
```

The repaired kernel's constant coefficients9Ts+83Ta+42Tl+12Tp become22 per
selected Is and452 per selected Ia after these additions. Preserve all other
kernel terms and the separate constant subsets; do not add both the generic
unpriced dynamic Q and its new Image substitution. Additional scalar-constant
cache vectors obey the accepted2040-byte per participating-type bound. Incoming
Uint/Rep_Table/serial state, cache/table growth and native index/byte guards
remain required. Failure of this conservative allowance to establish a guard
is not a new language rejection rule or a claim of actual overflow.

## Remaining obligation, evidence and round record

This specialization discharges actual Image-root H/Q and its cumulative
scalar/expression constructor projection. It does not supply the full F vector:
local workspace/frame storage and metadata/backing still need their transfers.
The next producer obligation is the normalized input/concat String graph:
First/Last descriptor loads and captured concat length arithmetic can have
nonliteral lower bounds, superflat GE/COND roots and incoming fat-pointer
conversions. The Image proof cannot be applied merely because such an endpoint
also contains an internal constant. The smallest next extension is a ranked
constructor/height transfer for a descriptor-bound load and its two-ended
String layout, preserving signedness and the conditional continuation. Full
source-derived dynamic F/Q and #201/#119 stay open.

The focused checker verifies complete source identities, LF spans, accepted
input/packet pins, the regenerated lexical matcher inventory, finite rank
edges, modular conversion/cancellation boundary cases, and the exported
coefficient composition. No predecessor checker, compiler, native target,
prover, generated matcher or benchmark is run. Source semantic reasoning is
an authored argument awaiting independent review, not a machine proof.

The R85 capped-evaluator wording is made precise here without editing the
frozen packet: exponentiation-loop operands are <=cap+1, their products
<=(cap+1)^2, while final `2*result` is separately bounded by2(cap+1), including
cap=0. The old packet's manifest pins the research note at its own freeze;
this continuation updates the note and intentionally does not rerun or repair
that historical manifest.

Selected author setting: GPT-6 Astra / Extra High; runtime confirmation,
total author elapsed time, tokens and cost unavailable. Intended outcome:
a source-dependent dynamic fold/height unit. Achieved: the classified Image
constructor/rank/H/Q transfer and explicit residual boundary. Material finding:
the two widenings cannot generally be collapsed using runtime nonnegativity.
First recorded source-analysis clock:2026-10-24 04:36:07 UTC, after analysis
had begun; it is not total author start. Native execution time is zero.
Focused check elapsed time and host are in current.json. Independent review,
root integration and publication are pending; this subthread changed no issue,
harness goal, CLI memory, production code, Oracle or tool pin.
