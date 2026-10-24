# Literal-prefixed concat: aggregate-capture maximum and fold envelope

This #201 continuation under #119 starts at accepted input author
4f518ea3151ad1d11c6c3654c84dd730bc4e2aff, independently reviewed without
repair in a33e3ef26af3de8a8c105bc9137a79d7d6ee2438. It closes a source-defined
concat partition's index/type constructor and annotation projection, and its
mixed constant/dynamic bounds-template subcall. The general selected-low,
null-selector, nested-provider and enclosing pointer/address cases remain
explicit in remaining.json. This partition does not restrict admission or
replace complete assurance for every current program.

Use the accepted GCC commit 6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea,
Linux x86_64 representation, ordinary local Main context and selected O0
invocation, without arithmetic sanitizers, trapv or fold checking. Inherit
natural layout, scalar precision, existing associations and completed
fixed/imported dependencies from the accepted packets. Earlier evidence is
reused, not replayed or edited. The new full exp_ch4.adb source is tied to
the already retained frontend source identity; no new tool pin is introduced.

## Exact source dispatch

Let Cs and Ca count distinct selected signed index and constrained String
allocation-type identities. A type qualifies only through this producer path:

1. It is a genuine Standard.String concat with at least two retained operands,
   not the NN=0/1 retained-operand exits.
2. Its first retained operand has a fixed positive length and actual lower
   bound literal1. A nonempty String literal prefix establishes both facts.
3. Every operand is fixed-length, or belongs to the accepted initial-input
   or Integer-Image bound family (including exact provenance-preserving
   ordinary aliases). At least one operand is dynamic. This seed-provider
   condition avoids assuming a shape for a previously unclosed concat.
4. The producer therefore sets Result_May_Be_Null=false, chooses Low_Bound=1,
   and creates High_Bound=1+(G-1), where G is its final generated aggregate-
   length capture. Standard.String's Ityp and Artyp are base Integer.
5. The optional maximum-length optimization does not replace this allocation
   high bound by a literal. If it does, the allocation goes to the accepted
   constant subset, while its separate dynamic returned slice remains a
   different producer obligation.
6. The selected original Subtyp_Rng carries Cannot_Be_Superflat=true.
   Copies qualify only when they preserve this range provenance, endpoint
   capture, base type, local context and flag. An unflagged slice is not
   classified merely because its textual range looks like 1..G.

These predicates are frontend source-producer facts, not tests of a runtime
length, successful native run or conveniently observed folded result. They give

    Cs <= Ts-Ss-Is-Bs; Ca <= Ta-Sa-Ia-Ba; Cs+Ca <= E_Main.

The intervals count distinct type identities, including qualifying copies,
rather than source concat operators. General dynamic roots retain their own
open weights; a source program need not belong wholly to this partition.

The actual source is exp_ch4.adb:2553–2667,2795–2824,2851–2910,3125–3340.
The Var_Length comment says Natural, but its **actual object declaration uses
Artyp** (3015–3045). For Standard.String this is base signed Integer32, not
the Natural capture type used by Image. To_Artyp/To_Ityp are identities
(2727–2761). The high-bound overflow-check flag is not enabled for
Istyp=Standard_Positive (3255–3268). Secondary-stack subtype insertion also
uses Suppress=>All_Checks (3347–3390). The selected normalized high is pure
constant-name arithmetic; it does not contain an action-bearing scalar if.

The flag reaches the actual native range query. Constrain_Array passes its
existing constraint S into Constrain_Index, then sets First_Index to the
same first constraint (sem_ch3.adb:14380–14450). Constrain_Index uses R:=S
and stores that range as the index subtype's Scalar_Range; its fresh-range
fixed-lower-bound alternative requires a missing upper bound, absent here
(15316–15474). Analyze_Range and Resolve_Range analyze or replace the bound
children without replacing the range root (sem_ch4.adb:4818–4930;
sem_res.adb:11161–11289). Process_Range_Expr_In_Decl retains that root and
places required checks at the declaration rather than wrapping the range
(sem_ch3.adb:22588–22834). Gigi obtains gnat_index from First_Index
(decl.cc:2613–2636). Thus the original selected allocation's flag is the one
tested by range_cannot_be_superflat; this is not an assumed transfer from a
different allocation or slice range.

A concrete current source family is samples/command_line_greeting.adb:10,
"Hello, " & Name & "!", where Name is the initial First_Or_Default capture.
The first length7 is nonzero, the low bound is1, and the input-name operand's
unknown maximum selects Too_Large_Length_For_Array, so no static maximum
replaces the allocation high. The generated aggregate sequence is

    V2 : constant Integer := Name'Length;
    G2 : constant Integer := 7 + V2;
    G3 : constant Integer := G2 + 1;
    allocation range 1 .. (1 + (G3 - 1)), Cannot_Be_Superflat=true.

The literal prefix, number of suffix literals and repetitions/aliases of the
input can vary; the proof uses the producer clauses above. This sample is an
applicability witness, not evidence for a universal bound, and is not compiled
or changed by this packet. Its runtime length guard is not a premise used to
erase native signedness or folding alternatives.

## Aggregate declarations stop maximum-query dependency replay

For every concat's aggregate construction, before normalization each dynamic
step is exactly

    Gj : constant Artyp := previous_aggregate + current_length.

Each input is a literal or an already created scalar length/aggregate entity
(exp_ch4.adb:3050–3099). Earlier actions precede the subtype and existing
associations prevent lazy initializer replay, as established in
retained-backend-gigi.md:190–224. This is not recursion through an arbitrary
source scalar initializer.

For the classified seed providers, dynamic Var_Length declarations have
nonconstant initializers. Initial-input length uses distinct captured L/H
declarations in the signed comparison and length arithmetic
(trans.cc:1716–1735); Image length depends on its existing position capture.
The conditional/arithmetic length cannot become a scalar constant on these
declaration operands. Its constant-condition/equal-arm simplifications are
absent or still return the nonconstant position, and a min/max contraction
would still depend on that position. Construction of these length initializers
is an object-family charge, not included in the type/helper export here.

All such captures are local, readonly, nonvolatile signed32 VAR_DECLs with
TREE_CONSTANT=false. A partial fixed prefix is a literal; after the first
dynamic operand, each aggregate declaration retains that property. Its
initializer is either PLUS of two scalar leaves or an existing declaration
after a zero-addition contraction. The two dynamic PLUS operands, if both
present, are different fresh capture entities: previous aggregate identity
and current Var_Length identity. Repeated source values do not equate them.
Thus the x+x -> 2*x matcher does not apply. A constant-left addition may swap
once; it does not substitute a declaration's initializer. gnat_to_gnu removes
an exact-type NON_LVALUE wrapper on return (trans.cc:8950–8964).
No general declaration-initializer traversal is hidden here.

The following **maximum-query lemma** also applies to any other concat
aggregate capture once its immediate scalar-leaf invariant is established:
max_value on a PLUS initializer of two base-Integer32 declarations/literals
takes at most three recursive activations and at most three scalar constant
requests. A literal returns unchanged; a declaration requests its existing
constant type extremum through fold_convert; the PLUS then combines two
constants before generic_simplify is reached (utils.cc:4095–4178;
fold-const.cc:11000–11050). An initializer that contracted to a declaration
is smaller. It follows no earlier declaration's initializer, regardless of
the depth or arity of the aggregate chain.

Signed32 extreme sums can overflow. The result remains an INTEGER_CST with
its overflow indication, and the caller accepts it only if the indication is
clear; otherwise decl.cc:2670–2712 substitutes the existing type extremum.
Do not interpret the computed wrapped value as a valid maximum. Neither
alternative creates a new type, binary expression, unary expression or
recursive symbolic folder call. This lemma bounds the actual helper work;
it does not claim max_value always computes a tight mathematical maximum.

For the selected high G, the query is therefore bounded by three constants.
An additional debug declaration has initializer G, so its query is at most
one constant. The low literal does not enter the declaration-query branch,
but retain both residual slots per Ca, at three constants each. No bound on
the length initializer below Var_Length is needed by these maximum queries:
that initializer is not visited.

## High normalization and size graph

The high source root may already have folded to G. Conservatively allow the
full high expression 1+(G-1) reaching gigi. Its two operations use ordinary
build_binary_op, not the overflow helper: all operands have the same base
Integer type and the generated high has no Do_Overflow_Check flag
(trans.cc:7421–7603; utils2.cc:1425–1521).

The actual folding sequence is:

    MINUS_s32(G,1) -> PLUS_s32(G,-1)
    PLUS_s32(1,PLUS_s32(G,-1))
      -> PLUS_s32(PLUS_s32(G,-1),1)
      -> PLUS_s32(G,0)
      -> NON_LVALUE_s32(G)
      -> G at gnat_to_gnu's exact-type wrapper-removal loop.

MINUS-to-PLUS is match.pd:2200; constant association is4407; PLUS-zero is237.
The association works both for wrapping signed arithmetic and the ordinary
undefined-overflow folder mode. In the latter, the requested constant sum
-1+1 fits the type, so the fallback unsigned-type construction is not taken.
The analysis does not assume a runtime G range to remove a conversion.
Because G is a declaration, PLUS-zero's non-lvalue wrapper really can allocate,
unlike the accepted Image layout identity whose operand was already a NOP.
That candidate is included below even though the final high root discards it.

Bound elaboration keeps G or creates at most one additional same-type readonly
debug VAR_DECL and DECL_EXPR. The low literal disables debug capture. Its
native scalar layout copies already completed sizes. Declare the retained
high leaf V to be G or that debug declaration.

The non-superflat decision now follows the **frontend flag**, not the endpoint
type-bound walk. Unlike Natural, base Integer alone would not prove this
shortcut for low1 (decl.cc:7049–7065). The existing conservative27Ca predicate
charge remains once in the repaired kernel even though the early return here
allocates nothing.

With X=NOP_u64(V), range/layout gives 1+(X-1)=X in u64 arithmetic. The bit root
is MULT(NOP_u128(NOP_u64(V)),8), or a permitted contraction. The signed32 ->
unsigned64 -> unsigned128 chain may retain both widenings. Bit round-up
succeeds at factor8; byte multiply by1 returns X; readonly propagation makes
save_expr return the existing size expression. These request shapes and
their terminal folder/extraction behavior are exactly the accepted Image
envelope after substituting this new, separately proved base-Integer leaf
and maximum-query provider. No Natural bound assumption is imported.

Consequently H_ConcatPrefix<=3 and each final root has Q<=5. Its MULT's
converted-inner root is a conversion or declaration, not another MULT, so
no converted-inner retry occurs. Declarations cut annotation edges to their
initializers/types. New operands refer to completed operands, giving an
acyclic graph. There are at most two finishing-root occurrences per Ca:

    Q_ConcatPrefix <= 10Ca.

The lexical audit retains all151 binary and19 conversion patterns with new
dispositions for the signed high normalization and leaf aggregate additions.
The finite call rank separates operand-order normalization, MINUS-to-PLUS
phase, constant association, PLUS-zero, exact-type wrapper removal, conversion
depth, terminal multiplication extraction and maximum-query leaf visits.
Constant maximum arithmetic precedes the matcher. These are source-argued
call states, including discarded candidates, not a general GCC termination
claim or a conclusion from merely counting matcher rules.

## Cumulative constructor projection

Source-bound translation per Cs conservatively has three Integer literal
occurrences: low1 and the two ones in the unreduced high. Use the accepted
thirteen-constant supplied-type UI_To_gnu bound for each. For the two high
binary entries, allow two scalar constants, one unary and one binary each.
The inner entry can negate/clear the shift constant and retain one PLUS;
the outer can combine constants and construct the discarded NON_LVALUE.
The componentwise envelope deliberately charges both entries alike.
Its common operand conversions are exact identities. Add one debug
VAR_DECL and DECL_EXPR. This gives

    source-bound constants <= 39Cs+4Cs = 43Cs
    source-bound unary <= 2Cs+Cs = 3Cs
    source-bound binary <= 2Cs
    extra VAR_DECL <= Cs.

If frontend normalization removed the high arithmetic or its type association
was already present, this allowance only decreases. Original aggregate and
operand-length object construction remains in O, not charged once per type.

The remaining array helper ledger uses the accepted multiplicities:

| Entry | Entries/Ca | Constants/entry | Unary/entry | Binary/entry |
| --- | ---: | ---: | ---: | ---: |
| Direct integral convert |7|1|1|0|
| Range/layout fold_convert |6|1|1|0|
| size_binop |17|2|0|1|
| max_value initializer query |2|3|0|0|
| Total per Ca ||53|13|17|

The Image cumulative size-operation argument applies to the exact same
layout request grammar. It includes discarded overflow-cleared constants
and the possible converted multiplier candidate, not just surviving trees.
GE/COND and constant-null/overflow alternatives are absent: the high is a
nonconstant capture and the source flag selects the shortcut.

    helper constants <= 43Cs+53Ca
    helper unary nodes/slots <= 3Cs+13Ca
    helper binary nodes/slots <= (2Cs+17Ca) / (4Cs+34Ca)
    helper expression operand slots <= 7Cs+47Ca
    helper extra VAR_DECL <= Cs
    helper raw caller bytes <= 2152Cs+3216Ca.

Raw requests are40/32/40 bytes for constant/unary/binary, and the accepted
256-byte VAR_DECL allowance. This excludes metadata, cache/hash/GGC backing,
native frames and input/import/operand-length object construction.

Annotation adds320Ca constants,10Ca unary nodes/slots,10Ca maps/Rep_Table/
serial entries,13280Ca raw GCC caller bytes,30Ca Uint entries,110Ca digit
words and1000Ca logical appended callback payload bytes. Therefore

    combined constants <= 43Cs+373Ca
    combined unary nodes/slots <= 3Cs+23Ca
    combined binary nodes/slots <= (2Cs+17Ca) / (4Cs+34Ca)
    extra VAR_DECL <= Cs; maps <= 10Ca
    combined expression operand slots <= 7Cs+57Ca
    combined raw caller bytes <= 2152Cs+16496Ca.

The repaired kernel's selected constant coefficients become52 per Cs and456
per Ca. All other kernel components and mandatory #207 frontend costs remain.
For Da=Ta-Sa and Dl=Tl-Sl, the mixed callback attachment is

    Qc = 2(Sa+Sl)
    Qd <= 10Ia+30Ba+10Ca + sum_(remaining dynamic root occurrences i) B(h_i)
    remaining root occurrences <= 2(Da-Ia-Ba-Ca+Dl).

Replace the classified unpriced Q component; do not add it twice. The global
alignment T term is composed once. Incoming Uint/Rep_Table/serial state,
constant-cache vectors and native field/backing guards retain their owners.

## Mixed constant/dynamic template subcall

For a completed classified Ca type and completed Standard.String XUB,
TYPE_INDEX_TYPE supplies original1/V, not size-domain conversions. The first
Positive32 field conversion needs at most one constant; the second needs at
most one same-width unary over V. Both placeholder substitutions are identity.

gnat_build_constructor's constant first value uses the already proved immediate
INTEGER_CST validator return. The second is neither TREE_CONSTANT nor
TREE_STATIC, so its first disjunct short-circuits before both constant validators.
Thus allconstant is false and no two-field sort/comparator is called.
No declaration initializer is followed by these flag tests.

For Dg qualifying calls the export is one constant, one unary, one24-byte
CONSTRUCTOR and one72-byte element vector per call:

    raw caller bytes <= (40+32+24+72)Dg = 168Dg
    separately rounded request slots <= 4*512Dg = 2048Dg
    stored elements = 2Dg; temporary constructor elements = two16-byte values.

The first value can participate in the existing constant-cache vector charge;
do not omit that separate backing term. For Pg qualifying direct String-actual
source traversal occurrences, the accepted adaptation attachment gives
Dg<=8Pg<=8V_Main. Fixed imported XUB construction is separate. Template address,
P_ARRAY adaptation and the enclosing fat-pointer constructor remain open;
this168-byte coefficient is not a whole conversion bound.

## Remaining finite producer inventory

remaining.json records the source dispatch order and exact next obligations.
NN<=1 returns an existing producer. All-literal allocation endpoints use the
accepted constant unit. A static maximum allocation can still emit a separate
dynamic result slice; an allocation's non-superflat flag cannot be silently
transferred to that slice. This packet closes only the selected nonnull
low1/G allocation identities with the seed-provider premise.

The remaining genuine concat families are: nonnull constant low other than1
(where reachable); nonnull nonliteral low, including a captured selected-low
spine; maybe-null low/high selectors; and otherwise matching low1 allocations
whose incoming bound providers are not yet closed. Generated assignment slices
are an additional family with low=L+previous_aggregate and
high=L+(aggregate-1). Count those separate type identities.

The initializer inventory distinguishes operand Length, immediate aggregate
PLUS, selected-low conditionals, surviving high arithmetic, paired null
selectors and forced action-bearing captures. Only the immediate aggregate
maximum query and this partition's endpoint/layout transfer are discharged
here. A crucial source guard remains explicit: max_value(COND) returns the
**original conditional** when both processed arms are unchanged. It does not
unconditionally construct MAX/MIN. A synthetic literal-arm example in the
checker refutes that unrestricted helper lemma; it does not establish that
such an example survives the actual current Main folder. Future work must
prove exclusion or bound the surviving selector and its mixed constant/
symbolic MAX/MIN calls.

The next useful closure is the selected-low/null-selector native grammar,
including its shared condition, exact signedness/conversion barriers, possible
unchanged max_value arms and source/candidate recursion rank. The pointer/
address spine follows that scalar grammar. Full allocator/hash/cache backing,
helper/native workspace, imported entry states, executable/object families,
and downstream GCC/assembler/linker/ALI/binder phases remain required for #201.
No conservative allowance becomes a new admission rejection rule.

## Evidence and round record

The checker validates26 complete source identities, new LF witnesses, pinned
accepted inputs and the unchanged concrete sample, regenerated lexical
inventories, the finite call rank, signed32/u64 high normalization cases,
maximum-query overflow/fallback cases, arbitrarily long model capture chains
with declaration cuts, annotation graphs and coefficient composition.
Arithmetic checks corroborate the authored semantic argument; they do not
machine-prove source correspondence or run the generated GCC matcher.
Only the frozen parser library is reused. No author/predecessor checker,
compiler, prover or native target is replayed.

Selected author: GPT-6 Astra / Extra High. Runtime confirmation, total author
elapsed time, tokens and cost are unavailable. Intended outcome: an actual
concat source partition plus a reusable bounded aggregate maximum-query
lemma. Achieved: source dispatch, high normalization, explicit discarded
non-lvalue candidate, cumulative helper/Q/template exports and a finite
remaining producer/initializer inventory. Important boundary finding:
unchanged conditional arms prevent a blanket constant-output max_value lemma.
An initial focused pass succeeded before the final source-correspondence audit
added the explicit range-node/flag transport. The final changed-input check
covers those added retained sources and witnesses; this is the reason for
the focused recheck. Native execution time is zero; final host/time are in
current.json.

Independent review, integration and publication are pending at author freeze.
This subthread changes no issue, goal, memory, production code, Oracle,
admission or tool pin. The e<=2, two save-entering callbacks and three saves
remain once per Why process, not per stage or a GCC-producer charge.
#201/#119 are not complete.
