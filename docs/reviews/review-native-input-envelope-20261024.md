# Native captured-input fold-envelope review

2026-10-24 UTC. Independent critical review for #201 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, token usage and monetary cost are unavailable.

Exact reviewed author: `4f518ea3151ad1d11c6c3654c84dd730bc4e2aff`.
**Accepted at the source-classified constructor/annotation and dynamic
bounds-template subcall scope.** No material defect or required author repair
was identified. Concat initializers, the enclosing fat-pointer conversion,
full helper workspace and whole #201/#119 remain open.

The [receipt](../evidence/review-native-input-envelope-20261024/README.md)
binds the complete input-fold packet, research continuation, accepted inputs
and retained source. GCC remains `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
with the retained Linux x86_64 representation, ordinary local Main context,
completed fixed dependencies, regular annotation mode and disabled fold
checking. Installed-tool correspondence and the accepted natural-layout and
integral-precision frontier are inherited requirements. This is a bounded
continuation of the accepted Image author `0ed7c10db8e806c4ee05c3c56fa6dfe54f0d132e`,
reviewed at `ce73d07d201646f488b44e965d632747e5028e60`.

## Producer and maximum-query attachment

Bs/Ba count distinct selected index/array subtype identities, including
qualifying copies; they do not count source input calls. The exact original
low/high endpoint identities, base-Integer representation, local context and
initializer provenance must be preserved. The exclusions of constant and
Image subsets justify `Bs<=Ts-Ss-Is`, `Ba<=Ta-Sa-Ia` and `Bs+Ba<=E_Main`.
Concat captures are not included merely because they are internal constants.

The frontend producer emits both endpoint captures with
`Base_Type(Etype(Index_Typ))`. The input pointer/reference capture supplies an
unconstrained Standard.String view without an intervening actual-subtype
recapture. Thus the two scalar captures have **signed Integer32 base type**,
not Positive/Natural subtype bounds. Identifier translation reaches existing
associations without replaying the object initializers.

For the original First/Last initializer, the unconstrained-pointer path
explicitly builds a plain SAVE_EXPR around the selected descriptor value.
The nonvolatile existing pointer capture and its dereference have no side
effects, so the attribute's side-effect COMPOUND alternative is absent.
Final/object conversions contribute at most two same-width wrappers above
SAVE. Descriptor loads below it belong to the separately owned input-object
transfer. SAVE is not TREE_CONSTANT, so the readonly endpoint declarations
are not replaced by constant initializers.

`max_value` recurses through the permitted NOP spine and stops at SAVE,
returning the expression. The caller uses the fixed type extremum when no
usable constant results. For an additional debug declaration, its initializer
is the existing VAR_DECL and `max_value` obtains that declaration's constant
type extremum immediately. These alternatives fit one constant and two unary
requests per query; they do not traverse an arbitrary initializer chain.
There are two queries per Ba. Local elaboration permits at most two extra
VAR_DECLs and two DECL_EXPRs per Bs; their scalar layout copies completed
constant sizes. Metadata and original capture declarations remain separate.

## Actual graph and cumulative folding

Writing `X=NOP_u64(L)`, `Y=NOP_u64(H)` and `C=GE_signed32(H,L)`, the general
upper bound is `C ? Y : X-1`. The source range predicate either returns at
the non-superflat flag or punts at base Integer captures; it does not discover
literal endpoint bounds by descending a signed subtype. Both branches are
covered, and the existing conservative 27Ba predicate term remains once in
the general kernel.

The actual conditional derivation is:

```text
(C ? Y : X-1)-X       -> C ? Y-X : -1
1+(...)              -> C ? (Y-X)+1 : 0
convert_u128(...)    -> C ? NOP_u128((Y-X)+1) : 0
8*(...)              -> C ? MULT(NOP_u128(PLUS(MINUS(Y,X),1)),8) : 0
```

The comparison remains signed32 while the length operations wrap in u64.
For `H>=L`, the mathematical length lies between 1 and 2^32, so its modular
calculation agrees. Otherwise the false arm cancels to zero, including
superflat pairs. Unsigned comparison of X/Y would be invalid for an interval
crossing zero. The shortcut graph omits C only under its frontend flag.

The handwritten conditional distributor may enter the first subtraction
because X is side-effect-free and both initial arms are dynamic. It folds
both arms. The generated cancellation rule makes `(X+-1)-X` an existing
exact-type constant, satisfying the distributor's success condition. There
is therefore one dynamic binary and one conditional, without a second failed
conditional candidate or a subsequent unfactored binary. Addition/multiplication
distribution has a constant other operand and smaller arm states.

Conversion distributes to one widened dynamic arm and a constant zero.
The pull-out alternative requires both results to be conversions, which the
zero is not. The conditional-comparison helper cannot form min/max: initially
the other arm is X-1 rather than the comparison operand L, and later the
arithmetic arm is not H. Its zero comparison cases also fail. No candidate
node is constructed on these excluded paths. Operand-order normalization
does not invert C.

The 151 binary, 19 conversion, 65 conditional and 52 GE lexical forms were
reviewed for this grammar. The broad conditional patterns at 7091 and 8428,
and generated distribution at 8678/8684, are GIMPLE-only. GE is not a
`logical_inverted_value`; its two declaration operands are distinct. Other
forms require missing constants, nested operators, repeated captures, vectors,
real/SSA/function operands or incompatible type relations. In particular,
moving the Y-X conversions inward requires `64<=32`, and the narrowing
arithmetic conversion rule cannot admit this widening over PLUS.

The two dynamic operands of Y-X prevent constant decomposition by `split_tree`.
The outer +1 association scan therefore has only two objects and fails its
strictly-more-than-two guard. Initial MINUS-to-PLUS constant negation and
possible overflow clearing are charged. Multiplier extraction stops before
constructing a converted factor at the wrapping u64 PLUS under the u128 NOP.
No selected rule needs a new scalar type or repeated-capture unsharing.

The rank distinguishes pending operand normalization/distribution, arm folds,
conversion-spine depth and terminal constant work. It covers attempted calls
and candidates, rather than only retained nodes. MINUS-to-PLUS decreases its
phase even at equal expression height; distribution enters nonconditional
arms, and no completion recreates a pending distribution request. The finite
rank DAG corroborates this source argument, not global GCC termination.

Each size entry fits two constant requests, one unary, one binary and one
ternary. This includes discarded overflow-clearing candidates and MULT-one's
possible NON_LVALUE_EXPR around a byte-size conditional. Direct conversions
are narrower than layout conversions, which permit one distributed conditional.
The accepted multiplicities give C49/U34/B18/T24 per Ba, plus the two unary
and two debug declarations per Bs. Raw requests of 40/32/40/48 bytes and
256 bytes per debug declaration yield **576Bs+4920Ba** helper bytes.
These are cumulative direct requests, not allocator backing or native frames.

## Annotation and dynamic template composition

Readonly flags propagate through the conversion, arithmetic, comparison and
conditional nodes, with no side effects. The later `save_expr` calls therefore
return the existing size graph. They are **not annotation cuts**; the original
initializer SAVEs are separate nodes. Alignment divisibility tests succeed
through the product factor 8 and false zero without descending the inner
length arithmetic. The byte NON_LVALUE wrapper is priced but is not a bit-size
annotation root.

Every new operand points to completed operands. Declarations are annotation
leaves; their initializers/types add no annotation edge. The conditional graph
has height 6, 13 distinct vertices and occurrence charge 15. Shared L/H each
occur again under C, so vertex counting would understate Q. Converted-inner
retries are excluded because the relevant roots are PLUS/MINUS rather than
the matching MULT/PLUS shapes; no BIT_AND synthetic branch exists. The
shortcut has H5/Q10. Thus two roots per Ba give **Q_Input<=30Ba**, with at most
seven active annotation frames.

The accepted callback transfer adds 960Ba constants, 30Ba unary nodes/maps,
39840Ba raw GCC bytes, 90Ba Uint entries, 330Ba digit words, 30Ba Rep_Table/
serial additions and 3000Ba logical appended callback bytes. Together:

| Projection | Bound |
| --- | ---: |
| Constants | 1009Ba |
| Unary nodes/slots | 2Bs+64Ba |
| Binary nodes / operand slots | 18Ba / 36Ba |
| Ternary nodes / operand slots | 24Ba / 72Ba |
| Extra VAR_DECLs | 2Bs |
| Raw direct caller bytes | **576Bs+44760Ba** |

The selected kernel coefficients remain 9 for Bs and become 1092 for Ba.
The generic unpriced Q term is replaced for these roots, not added again.
The global alignment T allowance is composed once, with incoming state/index/
backing guards retained.

For the bounds-template subcall, TYPE_INDEX_TYPE supplies the original signed
L/H pair, not the superflat-adjusted size bounds. Two same-width conversions
to completed Positive32 fields need at most two NOPs. The results are neither
TREE_CONSTANT nor TREE_STATIC and contain no placeholders. The first disjunct
of the constructor's constant check succeeds, so C++ short circuit skips both
constant validators. `allconstant=false` also skips record sorting.

The two conversions, 24-byte CONSTRUCTOR and 72-byte element vector give
**160Db** raw bytes and **2048Db** separately rounded request slots. The
second element needs no vector growth. The accepted direct-call occurrence
attachment gives `Db<=8Pb<=8V_Main`, not a distinct-value count. Fixed imported
XUB construction remains separate. This does not price taking the template
address, adapting P_ARRAY or building/validating the outer fat-pointer
constructor, nor its alternate pointer branches.

## Evidence, disposition and round record

One independent audit passed: **23 complete sources, 49 authored LF witnesses,
7 additional spans, 287 lexical forms tied to source, a 29-state/43-edge rank
DAG, 5,456 reduced signed cases, 729 signed32 boundary pairs, 64 coefficient
cases and 8 template coefficient cases**. It separately models seven size
entry candidate vectors, four conversion vectors and the two annotation
graphs. All seventeen accepted prerequisite inputs match the earlier Image
freeze. No author checker, matcher parser or predecessor checker was loaded
or replayed. The authored successful check is retained rather than repeated.

The finite calculations corroborate the reviewed source argument; they do
not machine-prove matcher completeness, semantic correspondence or allocation
counts, and are not native measurements. Actual host: Linux x86_64. No
compiler, prover, solver, Lean, native target or pattern generator ran; no
macOS validation is claimed.

First review clock: **05:33:22 UTC**. Audit completion:
**05:39:10.172230 UTC**, or **348.172230 seconds** through audit. The independent
audit itself took **0.724093 seconds**. Report/commit preparation follows that
interval. Selected reviewer setting was GPT-6 Astra / Extra High; runtime
confirmation, tokens and cost are unavailable. Intended outcome was independent
acceptance or a concrete defect at the selected input/template boundary.
Achieved: acceptance without material finding or author rework.

Shared allocator/hash/cache backing, metadata, native frames and other dynamic
producers remain separate. Full #201/#119 closure is not claimed. Oracle,
current admission, installed GCC/GNATprove pins and production #88–94 are
unchanged. The existing e<=2, two save-entering callbacks and three saves are
still **once per Why process**. Root owns integration, publication, issue
disposition and durable memory; this reviewer made no GitHub, harness-goal,
memory or author-source write.
