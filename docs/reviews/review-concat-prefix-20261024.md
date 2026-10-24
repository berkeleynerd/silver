# Literal-prefixed concat capacity review

2026-10-24 UTC. Independent critical review for #201 under #119.
Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort
confirmation, tokens and monetary cost are unavailable.

Reviewed author: `fd44328b98f1a977d0cfdbb01aa161940124edcb`.
**Accepted at the source-classified concat-prefix constructor/annotation and
mixed bounds-template subcall scope. No material defect or required author
repair was identified.** This is a partial research transfer; full concat,
native capacity and #201/#119 remain open.

The [receipt](../evidence/review-concat-prefix-20261024/README.md) binds all
thirteen changed files, nineteen prerequisite anchors, the accepted input
review and twenty-six retained source files by exact bytes/SHA-256. Input
author `4f518ea3151ad1d11c6c3654c84dd730bc4e2aff`, accepted by review
`a33e3ef26af3de8a8c105bc9137a79d7d6ee2438`, is reused unchanged. All forty-eight
earlier files in the general-native packet match that accepted author.

GCC remains `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, with the retained
Linux x86_64 representation, selected O0 invocation, ordinary local Main
context, no arithmetic sanitizer/trapv/fold checking, regular annotation
mode and completed imported/fixed dependencies. The existing natural-layout,
integral-precision, source/tool correspondence and physical-resource premises
remain required. Direct caller bytes below exclude allocator backing and
native frames; they do not establish that a physical compiler run fits.

## Source dispatch and range identity

The qualification is determined from the actual producer, rather than
observed runtime lengths or successful folding. It requires Standard.String,
at least two retained operands, first retained operand of fixed positive
length and literal lower bound 1, at least one dynamic operand, and only the
accepted input/Image dynamic providers or exact provenance-preserving aliases.
An otherwise matching nested provider still requires its own transfer.

`exp_ch4.adb:2851–2910,3050–3118,3125–3340` establishes the distinction from
NN<=1 exits, all-fixed allocation and optional static-maximum replacement.
The first positive fixed operand clears `Result_May_Be_Null` and supplies
the lower bound. Standard.String uses base Integer for both Ityp and Artyp;
the actual Var_Length declaration uses Artyp despite its stale Natural
comment. To_Artyp/To_Ityp are identities on this path. High becomes
`1+(G-1)` without the Positive-index overflow-check flag. The original
allocation range receives `Cannot_Be_Superflat=true`.

The added flag/source join is valid. `Constrain_Array` passes the existing
constraint and installs that same first constraint as First_Index.
`Constrain_Index` uses `R:=S` and stores R as Scalar_Range. Its fresh-range
FLB alternative requires an absent upper bound; the classified range has
one. Analyze_Range and Resolve_Range retain the root while resolving its
children. Process_Range_Expr_In_Decl inserts checks at the declaration.
Force_Evaluation returns for constant entity/literal arithmetic: its
Side_Effect_Free recursion does not introduce an action-bearing endpoint
capture here. Gigi obtains `gnat_index` from this First_Index and tests the
same range's flag (`decl.cc:2613–2636,2774–2785,7049–7065`). The shortcut
does not depend on treating base Integer as Natural.

Cs/Ca count distinct index/array type identities, including only copies that
preserve endpoint identity, range flag, base type and local context. They are
disjoint from the accepted constant, Image and input subsets. Other producers
in the same source program retain their own residual charges.

The `command_line_greeting.adb:10` applicability argument is sound: the
literal prefix is nonempty with low 1, Name comes from the initial input
producer, and its non-slice unknown maximum prevents static allocation-high
replacement. This is a source witness, not a native run or universal test.

## Maximum-query and recursive-folder accounting

Concat actions precede dependent subtype translation; the accepted existing
association argument prevents lazy replay of their initializers. After the
first dynamic operand, each aggregate's immediate initializer is PLUS of
base-Integer scalar leaves, or an existing declaration after zero addition.
Input Length depends on distinct captured bounds; Image Length depends on
the position capture. Both remain nonconstant. Subsequent generated
declarations are readonly, nonvolatile local VAR_DECLs with TREE_CONSTANT
false (`utils.cc:3018–3110`). An earlier aggregate and a fresh Var_Length
are different declarations even when source operands repeat, excluding x+x.

For that immediate grammar, `max_value` replaces a VAR_DECL with its type
extremum and never follows DECL_INITIAL. A literal returns unchanged; PLUS
has only its two immediate visits. Both results are constants and are folded
before `generic_simplify`. Thus **at most three recursive activations and
three scalar-constant requests** suffice independently of aggregate-chain
depth. Signed extreme sums may overflow. `decl.cc:2670–2712` rejects an
overflowed constant as a usable maximum and falls back to the existing type
extremum. A debug capture initialized by G is smaller. This bounds helper
work without asserting a tight numerical maximum.

The signed high normalization is also source supported:

```text
G-1 -> G+(-1)
1+(G+(-1)) -> (G+(-1))+1 -> G+0 -> NON_LVALUE(G) -> G
```

The relevant rules are at `match.pd:237,2200,4407`; `trans.cc:8950–8964`
removes the final exact-type wrapper. The constant sum -1+1 is representable,
so the undefined-overflow branch does not need its fallback unsigned type.
The wrapping branch also applies. Unlike a NOP operand, G is an lvalue
declaration, so the NON_LVALUE constructor can allocate. It is charged even
though discarded. No runtime nonnegativity is used to collapse signedness
or widening barriers.

The accepted 151 binary and 19 conversion source forms remain identical;
the new declaration-leaf dispositions are consistent with their guards.
Other forms require missing nested operators, vectors/reals, SSA/function
inputs, incompatible conversions or equal captures. The terminal aggregate
PLUS cases cannot expose an initializer. Handwritten PLUS association has
only two objects and cannot pass its strictly-more-than-two guard; source
high association returns through the earlier matching rule. Constant maximum
arithmetic never enters symbolic matching. Layout multiplication retains the
accepted bounded extraction attempt and discarded factor candidate.

The rank separates operand-order normalization, MINUS-to-PLUS phase,
association, zero identity, wrapper removal, conversion depth and immediate
maximum visits. Its edges decrease even when tree height is unchanged.
This is a specialized source argument including attempted calls/candidates,
not a proof of general GCC folder termination.

## Constructor, annotation and template exports

The unreduced source high/low roots contribute three supplied-type literal
conversions, two scalar binary entries, and at most one debug declaration
with DECL_EXPR. The componentwise envelope is **C43/U3/B2 per Cs** plus
one VAR_DECL. The array ledger's 7 direct conversions, 6 layout conversions,
17 size operations and two maximum-query slots yield **C53/U13/B17 per Ca**.
The low literal does not need a maximum query; retaining both slots is safe.

For `X=NOP_u64(V)`, non-superflat layout reduces `1+(X-1)` to X. Bit size
is `MULT(NOP_u128(NOP_u64(V)),8)` or a contraction. The two widenings need
not collapse; factor 8 establishes alignment without inspecting V. Readonly
propagation makes save_expr reuse the graph. Declarations cut annotation
operand edges, and each new operand refers to completed operands. Hence
**H<=3, Q<=5 per root and Q_ConcatPrefix<=10Ca** for two root occurrences.
The converted-inner MULT retry is absent because its inner root is a
conversion/declaration, not MULT.

| Projection | Accepted bound |
| --- | --- |
| Helper constants / unary / binary | 43Cs+53Ca / 3Cs+13Ca / 2Cs+17Ca |
| Helper operand slots | 7Cs+47Ca |
| Helper raw caller bytes | 2152Cs+3216Ca |
| Combined constants / unary / binary | 43Cs+373Ca / 3Cs+23Ca / 2Cs+17Ca |
| Combined operand slots | 7Cs+57Ca |
| Combined raw caller bytes | **2152Cs+16496Ca** |

Annotation additionally owns 10Ca maps/Rep_Table/serial entries, 30Ca Uint
entries, 110Ca digit words and 1000Ca logical callback payload bytes. The
repaired kernel's selected constant coefficients become 52 per Cs and 456
per Ca. This substitutes classified roots in the open Q component; it does
not add Q twice. The global alignment T term and existing e<=2, two
save-entering callbacks and three saves remain once in their existing owners,
with the last three limits still **once per Why process**.

For the mixed template, TYPE_INDEX_TYPE supplies original 1/V. Converting
the first value to Positive32 costs at most one constant and the second at
most one same-width unary. Neither contains a placeholder. The literal has
the accepted immediate constant-validator path; the high value is neither
TREE_CONSTANT nor TREE_STATIC, so short circuit avoids both validators for
it. `allconstant=false` skips sorting. One constant, one unary, the 24-byte
constructor and 72-byte element vector give **168Dg raw bytes**, four
separately rounded requests totaling 2048Dg, and two stored elements.
The accepted occurrence attachment remains `Dg<=8Pg<=8V_Main`.

Names, bindings, metadata, original length/aggregate-object construction,
constant-cache vectors, GGC/hash/table backing, imported states and native
workspace retain separate ownership. Template address/P_ARRAY adaptation
and the enclosing fat-pointer constructor are not covered by 168Dg.

## Evidence and disposition

The independent receipt passed 26 complete source identities, 37 authored LF
spans and six additional inspected spans. It binds all 170 reused lexical
forms to their source text/locations, checks the 30-state/40-edge rank,
216 immediate maximum-query arithmetic cases, four capture chains through
4096 operands, 267 high/layout arithmetic cases, three annotation graphs,
49 coefficient combinations and the template arithmetic. No author checker,
matcher parser, predecessor checker, compiler, prover, Lean, pattern
generator or native target ran. No macOS validation is claimed.

Finite checks corroborate the semantic review and exact inputs; they do not
machine-prove source correspondence or universal allocation bounds. The
author's final successful 0.827069-second check is reused. Its earlier pass
preceded the new flag-transport sources/witnesses, so the author's final
changed-input check was justified; no identical-success replay is requested.

First recorded reviewer clock: **06:12:09 UTC**. Independent audit completion:
**06:16:44.427579 UTC**, or **275.427579 seconds** through audit. The passing
audit took **1.251843 seconds**; report/commit preparation followed. One initial
reviewer-script run stopped because its source-line assertion treated a
`simplify` form's line as the following pattern's line. Correcting that
receipt assertion required no author change. Runtime model/effort, tokens,
cost and total pre-clock elapsed time remain unavailable. Native time is zero.
Intended outcome was bounded independent acceptance or a concrete defect;
achieved result is acceptance without material author rework.

`remaining.json` correctly retains selected-low/null-selector grammars,
non-1 lows, unclosed nested providers, dynamic result/assignment slices,
forced action-bearing captures, pointer adaptation and all downstream
obligations. In particular, max_value(COND) can return the original conditional
when both arms are unchanged; the synthetic example does not prove current
Main reachability. No narrowed universal claim or new admission restriction
is introduced. `complete_native_capacity_result` must remain false.

Oracle, admission, production #88–94 and tool pins are unchanged; PR #121 is
not merged. Root owns integration, publication, issue status and durable
memory. This reviewer made no GitHub, harness-goal, memory or author-source
write and stops after this bounded review.
