# Captured input String bounds: source-derived fold and template envelope

This bounded #201 continuation under #119 starts at Image author freeze
0ed7c10db8e806c4ee05c3c56fa6dfe54f0d132e, accepted by independent review
ce73d07d201646f488b44e965d632747e5028e60 and integrated by the lead at
e2c4456c51. It closes the selected **input-derived index/type helper constructor
and annotation projection**, plus the dynamic two-field bounds-template
subcall. Concat initializer arithmetic, enclosing fat-pointer adaptation,
full helper workspace and whole native capacity remain separate obligations.
Earlier packets and their manifests/exports are unchanged.

## Source family and incoming state

Use GCC commit 6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea, the retained Linux
x86_64 representation and ordinary local Main context, with the accepted
natural-layout and integral-precision frontier, List_Representation_Info < 3,
type_annotate_only=false, and no fold-checking. Standard Integer, Positive,
Character and String, and the input/capture objects, are completed dependencies.
Their fixed/object construction is separately charged, including any imported
dummy/fixup entry state; this is not a cold-entry replacement for those charges.

Let Bs count distinct selected signed index-subtype identities whose two
endpoints are the low/high internal scalar constants created for the initial
input String. Let Ba count distinct corresponding constrained String subtype
identities. Qualifying copies preserve the exact endpoint identities, their
Base_Type(Integer) representation, local context and initializer provenance.
This classification is made from the frontend producer and association order,
not from observed runtime lengths or successful compiler output. In particular,

    Bs <= Ts-Ss-Is; Ba <= Ta-Sa-Ia; Bs+Ba <= E_Main.

Counts are distinct type identities, not just input-call syntax occurrences.
An arbitrary concat constant does not qualify.

The retained frontend argument in retained-native-expansion.md:1210–1240
establishes the input call's one pointer/reference capture P and P.all view,
with unconstrained designated Standard.String and no intervening actual-subtype
recapture. Make_Subtype_From_Expr emits

    L : constant Base_Type(Index_Typ) := P.all'First(1);
    H : constant Base_Type(Index_Typ) := P.all'Last(1);
    range L .. H

(exp_util.adb:10935–11003). Both captures have **signed Integer32 base type**,
not Positive or Natural. They are distinct entity identities. Original and
additional debug bound declarations remain distinct even if runtime endpoint
values happen to coincide.

Identifier translation reaches existing associations; it does not replay
their initializers. The accepted object-order argument is retained-backend-
gigi.md:190–224. For the capture initializer itself, First/Last recognizes
P.all as an unconstrained pointer dereference and encloses the descriptor
value in a **plain SAVE_EXPR** to survive release of the pointed-to bounds
(trans.cc:2132–2220,2286–2344). P is the existing nonvolatile local capture;
its dereference has no side effects, so the attribute-tail COMPOUND path at
2672–2684 is absent. The final scalar conversion and object-initialization
conversion may leave at most two same-width conversion wrappers above this
SAVE (trans.cc:8930–8970; decl.cc:1605–1640). Descriptor-load construction
below the SAVE belongs to the input object transfer, not this type-helper
projection.

These local scalar objects are readonly, nonvolatile VAR_DECLs. SAVE is not
TREE_CONSTANT, so create_var_decl's constant-initializer test cannot set
TREE_CONSTANT on L/H (utils.cc:3018–3090). Bound elaboration either returns
those declarations or creates at most one debug VAR_DECL and one DECL_EXPR
per endpoint, with initializer the existing endpoint declaration and the same
signed32 type (decl.cc:7534–7657). As in the accepted Image proof, fresh
debug-declaration layout copies completed constant scalar sizes and introduces
no new symbolic layout. No source literal endpoint conversion is needed here.

## Maximum queries and actual layout graph

The two possible max_value(DECL_INITIAL(bound), direction) requests at
decl.cc:2670–2711 do not follow an unbounded capture chain. If the bound is
the original capture, max_value passes through at most two NOP conversions
and stops at SAVE_EXPR: its switch has no SAVE recursion. Each return
fold_convert can create at most one unary conversion. If the bound is an
additional debug declaration, its initializer is a VAR_DECL and max_value
returns that declaration's existing constant type extremum, at most one
constant conversion (utils.cc:4095–4177). Conservatively charge **one constant
and two unary constructors per query**, although these alternatives are
exclusive. When no usable constant results, the caller substitutes the
constant signed32 type extremum. Thus update_n_elem and the final maximum-size
multiply receive constants. No claim about max_value on general concat
arithmetic is used.

Let X=NOP_u64(L), Y=NOP_u64(H), and C=GE_signed32(H,L). Conversions through
the same Integer base type are identities; repeated exact sizetype conversions
are identities too. Range factories use the incoming base sizetype rather
than their new range subtype (tree.cc:7460–7484). C's operand-base conversions
are exact Integer identities, and the result type is the existing Boolean
type (utils2.cc:1225–1392,1470–1521).

The source range predicate can return early if Cannot_Be_Superflat is set.
Otherwise, the capture Etypes are base Integer entities, not signed-integer
subtypes, so its endpoint-to-subtype loops cannot descend to literals and it
punts (decl.cc:7049–7095). Retain both outcomes. The repaired general kernel's
27Ba predicate allowance remains in force and is not added a second time.

In the general branch both bounds are dynamic, so the constant-null,
constant-overflow and constant-high alternatives are absent. The upper bound
is C ? Y : X-1 (decl.cc:2741–2823); MINUS(X,1) canonicalizes to PLUS(X,-1).
The gigi conditional helper's operand conversions are identities; its
address-taking and common-SAVE/COMPOUND alternatives are absent
(utils2.cc:1892–1943). The SAVE nodes in capture initializers are not operands
of X or Y.

Each of at most two layouts follows stor-layout.cc:2662–2730:

    Z = C ? Y : (X-1)
    D = Z-X                -> C ? (Y-X) : -1
    N = 1+D                -> C ? ((Y-X)+1) : 0
    W = convert_u128(N)    -> C ? NOP_u128((Y-X)+1) : 0
    bits = 8*W             -> C ? MULT(NOP_u128(PLUS(MINUS(Y,X),1)),8) : 0.

All length arithmetic before the widening is wrapping u64. The comparison
is signed32. On its true arm H-L+1 is between1 and2^32, so the modular result
also equals the mathematical length. On its false arm cancellation gives0,
including superflat bounds. Do not replace C by an unsigned comparison of
X and Y: a negative-to-nonnegative signed interval is a counterexample.

If the frontend non-superflat shortcut succeeds, use the same true-arm
arithmetic without C. This simpler graph is included by the envelope; its
semantic use relies on that frontend flag, rather than claiming the flag for
every captured pair. The general conditional derivation itself works for
every signed32 pair.

Read-only flags propagate from L/H through the conversion, binary, comparison
and COND constructors (tree.cc:5194–5223,5295–5389). None has side effects.
Hence save_expr's invariant check returns the existing size expression,
even when its outermost nonarithmetic node is COND (tree.cc:4078–4096,
4132–4166). **Do not treat these SAVE calls as annotation cuts.** The plain
capture-initializer SAVEs above are different nodes.

For round_up(bits,8), multiple_of_p traverses the two COND arms: the product's
constant factor8 succeeds first and the false constant0 succeeds. It does not
descend through the length arithmetic or allocate a replacement divisor.
The existing direct divisor constant is in the kernel. Byte size multiplies
N by1. That identity can create one NON_LVALUE_EXPR because maybe_lvalue_p
includes COND_EXPR (fold-const.cc:2811–2873); byte round-up to1 then returns
it. This wrapper is included in helper allocations, but is not a bit-size
annotation root. The shortcut byte expression is arithmetic and needs no
such wrapper.

All constructed operands point to already completed operands. Declarations
are annotation leaves: their types and initializers are not annotation edges.
The resulting bit-size operand graph is finite and acyclic, with
**H_Input <= 6**.

## Recursive folding, failed candidates and rank

The nonconstant request grammar is:

- Same-width subtype conversions or signed32-to-u64 conversions over L/H;
  u64-to-u128 conversion over N or its one arithmetic arm.
- MINUS(X,1), PLUS(X,-1), MINUS(Y,X), MINUS(PLUS(X,-1),X),
  PLUS(1,MINUS(Y,X)) and its canonical operand order.
- The four displayed conditional stages; binary MINUS with X, PLUS with1,
  and MULT with8 applied to those stages, and the byte MULT with1.
- GE(H,L), conversion/identity wrapper requests, and the bounded maximum-query
  conversion spine over SAVE. Remaining arithmetic requests have constants.

The relevant successful generated rewrites are the accepted MINUS-to-PLUS
constant-negation rule at match.pd:2200, MULT-one at499, exact conversion at
5721 and permitted conversion contraction at5806–5920, plus **false-arm
cancellation** at4362:

    MINUS(PLUS(X,-1),X) -> VIEW_CONVERT_u64(-1) -> existing -1.

The view has the exact input type. Each surviving replacement capture occurs
once, so genmatch's repeated-capture unshare construction is absent.

The conditional distribution is handwritten fold_binary_op_with_conditional_arg,
not match.pd's GIMPLE-only rules8678/8684. On the first subtraction its other
operand X is nonconstant but side-effect-free, neither conditional nor a
comparison, and both original arms are nonconstant. Distribution therefore
tries both arms; cancellation makes the false arm constant, so it **succeeds**
and cannot fall through to a second failed conditional candidate. On +1 and
*8 the other operand is constant, so distribution is allowed directly
(fold-const.cc:7017–7103,11023–11170). Every arm fold has no conditional operand.

Unary conversion distribution constructs a single widened dynamic arm and a
constant zero arm, then one COND. It cannot pull conversions back outside:
the zero arm is an INTEGER_CST, not a conversion (9210–9310). Thus the
plain-build1/build3 pull-out alternative is excluded by shape, not omitted
from a generic conversion count.

GE's two distinct declaration operands match no simplifying pattern.
The conditional arms neither coincide nor form A op B ? A : B; X-1 is not
the signed declaration L. The handwritten comparison-to-min/max helper is
therefore unsuccessful without constructing a candidate
(6053–6254,12899–13270). Operand-order swaps do not invert C: the original
widening Y and PLUS(X,-1) are both nonconstant nondeclarations after
mode-preserving stripping, while every later false arm is constant
(7254–7302). Later conditional-to-Boolean rewrites require a truth-valued
true arm, absent for the conversion/arithmetic/product grammar.

The full lexical inventories retain151 binary,19 conversion,65 conditional
and52 GE-root forms, including both preprocessor branches. The audit has new
dispositions for this grammar, rather than reusing the narrower Image
dispositions. Pattern7091's broad zero-one conditional rule is GIMPLE-only.
Pattern7185's logical_inverted_value predicate recognizes only truth-not,
bit-not, eq-zero, ne-true and xor-true forms (match.pd:2406–2486); GE(H,L)
matches none. Other patterns require missing nested operations, constant
positions, equal captures, vectors, real values, SSA names or function calls.
These inventories are review aids, not an executable GCC matcher or a proof
that counting patterns establishes termination.

Y-X cannot push its two conversions inward: the precision guard at
match.pd:4534 requires64 <= 32, which is false. Its right conversion cannot
be cheaply negated. The handwritten association logic does not decompose
MINUS(Y,X), because both operands are dynamic; with the outer +1 it therefore
finds exactly two objects and its more-than-two guard fails
(fold-const.cc:901–1002,11444–11595). Initial PLUS(X,-1) can still request
one overflow-cleared constant. Final multiplication's extract_muldiv stops
at the wrapping u64 PLUS under the wider u128 NOP, before converting or
recursing through that arithmetic (6583–6701). No new scalar type is needed.

A well-founded call rank distinguishes pending distribution, pending
operand-order normalization, arm folding, conversion depth and constant
calculation. The finite certificate records:

- A constant-left request enters its once-canonicalized request.
- A distribution request enters two strictly lower arm states, then a
  lower conditional-completion state.
- MINUS-shift enters constant negation and terminal PLUS; false-arm
  cancellation enters an exact-type view and then identity.
- A conversion contraction or maximum-query recursion shortens its
  conversion spine; SAVE and VAR_DECL are terminal maximum-query states.
- MULT extraction enters its wrapping-widening barrier and stops.
- Constant calculation and predicate checks use the accepted fixed-precision
  transfer; COND completion constructs no further fold request on this grammar.

This ranks **calls and attempted candidates**, not just retained nodes.
Phase decreases handle the equal-height MINUS-to-PLUS edge, and pending
distribution decreases handle the extra conditional constructors. No rewritten
arm recreates an outstanding conditional-distribution state.

## Cumulative constructor export

Restrict the accepted residual entry multiplicities to Ba. The three explicit
overflow/empty-array fold_build2 alternatives are absent, since both original
bounds and each actual length are nonconstant. Keep the other mutually
exclusive slots conservatively. A constructor envelope for each entry is:

| Entry | Entries/Ba | Constants/entry | Unary/entry | Binary/entry | Ternary/entry |
| --- | ---: | ---: | ---: | ---: | ---: |
| Direct integral convert outside layout |7|1|1|0|0|
| Range/layout fold_convert |6|1|1|0|1|
| size_binop |17|2|1|1|1|
| max_value on a bound initializer |2|1|2|0|0|
| gigi GE helper |1|0|0|1|0|
| gigi COND helper |1|0|0|0|1|
| Total per Ba ||49|34|18|24|

Direct conversions see only constants or endpoint declarations, not CONDs.
A range/layout conversion can distribute once, with one dynamic conversion,
one constant conversion and one new conditional; ordinary/identity cases are
smaller. A size operation can produce at most one dynamic arm binary and one
conditional. Two constants cover shift-negation plus possible overflow clearing,
or constant-arm arithmetic and any retained/discarded scalar candidate. The
extra unary covers MULT-one's non-lvalue wrapper. The successful cancellation
returns an existing exact-type constant. There is no second nonconstant
candidate binary after successful distribution, no conversion pull-out and no
unshare. Constant-only size requests are bounded by one constant request.

Add two debug VAR_DECL and two DECL_EXPR allowances per Bs. Original capture
declarations, descriptor loads, names, binding/statement-list metadata and
fixed/imported declarations remain in their own transfers. Thus

    helper constants <= 49Ba
    helper unary nodes/slots <= 2Bs+34Ba
    helper binary nodes/slots <= 18Ba / 36Ba
    helper ternary nodes/slots <= 24Ba / 72Ba
    helper extra VAR_DECL <= 2Bs
    helper expression operand slots <= 2Bs+142Ba.

With the accepted raw request sizes40/32/40/48 bytes for constant/unary/
binary/ternary and256 bytes per VAR_DECL, the selected cumulative direct
caller export is **576Bs+4920Ba bytes**. This is not peak storage, allocator
backing, metadata or a native-frame bound. Constant-cache vectors and shared
GGC/hash/table transfers retain their existing separate terms.

## Annotation composition

The largest final root has this retry-aware annotation occurrence charge:

| Subgraph | Q |
| --- | ---: |
| L or H leaf |1|
| X or Y conversion |2|
| MINUS(Y,X) |5|
| PLUS(MINUS(Y,X),1) |7|
| u128 conversion |8|
| MULT(...,8) |10|
| GE(H,L) |3|
| COND(C, product,0) |15|

The MULT's converted inner root is PLUS, not MULT. The PLUS's left root is
MINUS, not a conversion of another PLUS. Thus neither converted-inner retry
is reachable, and there is no BIT_AND synthetic branch. Sharing L/H between
comparison and arithmetic does not erase repeated root occurrences. The
largest graph has13 distinct vertices but Q15. The shortcut has H5/Q10;
the conditional has H6/Q15 and active annotation depth at most7.

For two finishing-root occurrences per Ba,

    Q_Input <= 30Ba.

The generic height theorem gives the looser2Ba*B(6)=2914Ba. The sharper30Ba
comes from the complete grammar, not just its height.

Use the accepted callback transfer once. Input annotation adds960Ba constants,
30Ba unary nodes/slots,30Ba map/Rep_Table/serial entries,39840Ba raw GCC caller
bytes,90Ba Uint entries,330Ba digit words and3000Ba logical appended callback
payload bytes. Global alignment's T allowance is added **once** across all
subsets.

    combined constants <= 1009Ba
    combined unary nodes/slots <= 2Bs+64Ba
    combined binary nodes/slots <= 18Ba / 36Ba
    combined ternary nodes/slots <= 24Ba / 72Ba
    extra VAR_DECL <= 2Bs; annotation maps <= 30Ba
    combined expression operand slots <= 2Bs+172Ba
    combined raw caller bytes <= 576Bs+44760Ba.

The repaired kernel constant coefficients remain9 for selected Bs and become
83+49+960=1092 for selected Ba. Keep all other kernel terms. With
Da=Ta-Sa and Dl=Tl-Sl, the mixed annotation attachment is now

    Qc = 2(Sa+Sl)
    Qd <= 10Ia + 30Ba + sum_(remaining dynamic root occurrences i) B(h_i)
    remaining root occurrences <= 2(Da-Ia-Ba+Dl).

Do not add the unpriced generic Qd for a classified root as well as its new
substitution. Incoming Uint/Rep_Table/serial state and native index/backing
guards remain required.

## Dynamic two-field template subcall

For a build_template invocation on a completed classified Ba String and the
completed Standard.String XUB, create_index_type preserves the original
signed index type in TYPE_INDEX_TYPE (utils.cc:2857–2871). The template reads
that original L/H pair, **not** the superflat-adjusted sizetype bounds
(utils.cc:4401–4460). The existing XUB fields are Positive32, as established
by the accepted helper-joins argument.

Each same-width Integer32-to-Positive32 scalar conversion returns the existing
value or creates at most one NOP. Neither value is TREE_CONSTANT or TREE_STATIC:
local declarations have no static storage and fresh scalar expressions have
no static flag. There is no actual placeholder in either converted bound,
so both placeholder substitutions are identities.

For each element, gnat_build_constructor's first condition,
!TREE_CONSTANT(val) && !TREE_STATIC(val), is true. C++ short circuit therefore
skips both initializer_constant_valid_for_bitfield_p and
initializer_constant_valid_p, rather than merely bounding their recursive
traversal (utils2.cc:2166–2220). allconstant becomes false, so the constant
record sort and its bit-position comparator do not run. Flag propagation
itself allocates nothing.

The selected subcall creates at most two32-byte conversions, one24-byte
CONSTRUCTOR and one72-byte inexact element vector, whose second append needs
no growth. For Db qualifying invocations:

    unary nodes/slots <= 2Db
    CONSTRUCTOR nodes = Db; element-vector allocations = Db
    stored elements = 2Db
    raw caller bytes <= (2*32+24+72)Db = 160Db
    separately rounded slots <= 4*512Db = 2048Db.

There are two temporary16-byte constructor elements, not a full frame claim.
No scalar-constant cache is touched by this subcall. Imported XUB construction
is charged separately, not once per Db.

Let Pb count direct Call_to_gnu String-actual traversal occurrences with
qualifying completed array provenance, including arrays exposed by the
accepted address/view peeling. The accepted direct-call adaptation argument
applies unchanged: Db <= 8Pb <= 8V_Main. This is an occurrence attachment,
not a count of distinct values. The other five template callers remain
outside this ordinary Main family as in helper-joins.

This does **not** price the enclosing convert_to_fat_pointer. Its ordinary
branch additionally takes the template's address at utils.cc:4877, converts
the actual pointer for P_ARRAY at4902, appends the two outer elements and
constructs/validates the outer fat-pointer constructor. Those operations need
their own pointer operand/spine and cumulative candidate argument. The null,
thin and extended-pointer branches are not silently assigned this template
bound. The selected bounds-template coefficient can be composed when that
outer join is discharged.

## Remaining joins, evidence and round record

The next dynamic-bound producer is concat. Its normalized high bound can
retain low+(aggregate-1) and a null selector, with low/length/aggregate
temporaries referring to earlier values. A VAR_DECL annotation leaf alone
does not settle the native maximum-query call on its initializer: unlike
input First/Last, concat arithmetic may not have a SAVE cut. The missing
argument is a ranked transfer for those surviving arithmetic/conditional
roots and max_value initializer queries, followed by the actual pointer/
address adaptation grammar. This packet neither assumes that transfer nor
treats all internal constants as input endpoints.

The focused checker validates complete archived source identity, retained
input and packet pins, LF witness hashes, all four lexical matcher inventories,
the authored finite rank DAG, exhaustive reduced-width and signed32 boundary
arithmetic, occurrence-sensitive annotation DAG charges and coefficient
composition. It reuses the frozen parser as a library, not its predecessor
checker. These checks corroborate the authored source reasoning; they are
not a generated matcher execution, GCC/prover run or machine proof.

Selected author setting: GPT-6 Astra / Extra High. Runtime confirmation,
total author elapsed time, tokens and cost are unavailable. Intended outcome:
a bounded input/descriptor continuation after the accepted Image result.
Achieved: source-dependent input H/Q and cumulative constructor bounds, plus
the dynamic template coefficient with its caller attachment. Material audit
findings: base-Integer captures preserve a genuine GE/COND path; readonly
COND size expressions are not hidden by save_expr; byte MULT-one can add a
non-lvalue wrapper; dynamic template validation short-circuits before the
constant validators/sort. Native execution time is zero. Current check time
and actual host are recorded in current.json.

The unchanged process allowance is e <= 2, two save-entering callbacks and
three saves **once per Why process**, not per stage and not a GCC-producer
charge. Nothing here changes that allowance. Independent review, integration
and publication are pending at author freeze. No issue, live goal, memory,
Oracle, admission, production implementation or tool pin is changed by this
subthread. Full #201/#119 closure is not claimed.
