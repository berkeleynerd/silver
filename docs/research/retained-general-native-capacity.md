# General Main native capacity: local type construction

This is author work for [#201](https://github.com/berkeleynerd/silver/issues/201),
under #119. It advances the actual-source current-grammar native derivation
beyond the completed literal-only #145 family. **#201 remains incomplete.**
There is no new admission predicate, production change, tool change or Oracle
amendment. Native compilation and proof success are not membership tests.
Physical-resource premises and the global exceptional allowance are unchanged.

The [#207 repair](../evidence/retained-general-native-capacity-20261024/string-pack-repair.md)
now supplies the omitted frontend static String layout cost. All current
frontend numerical joins use its mandatory
[current overlay](../evidence/retained-general-native-capacity-20261024/string-pack-current.json),
while the original native-expansion generator/output remain historical. This
supersedes the old zero-Uint freeze claim without altering the native type
kernel's coefficients below. Its effect on exact natural versus superflat
sizes is stated explicitly here.

The subsequent [#209 helper continuation](../evidence/retained-general-native-capacity-20261024/helper-joins/README.md)
repairs an omitted allocating superflat predicate with **+27Ta GCC constant
requests**. This is mandatory for current use of the first kernel; its original
table and check remain historical. The continuation also closes the classified
constant-bound helper and annotation paths and the bounds-template helper for
direct String call-adaptation roots. Its
[current native export](../evidence/retained-general-native-capacity-20261024/helper-joins/current.json)
is separate from the mandatory #207 frontend Uint export. Dynamic F/Q, general
imported-entry costs and whole native capacity remain open.

The first result is a source-to-layout lemma and a cumulative allocation kernel
for Main's local types. It removes the padding-record alternatives for those
types, supplies explicit type/declaration/vector/constant coefficients, and
connects the remaining dynamic operations to their actual roots. It does not
label a request to the symbolic folder as one allocation. The
[evidence packet](../evidence/retained-general-native-capacity-20261024/README.md)
retains complete source files, source witnesses and offline arithmetic checks.

## Inputs and accounting boundary

The source is GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`, on the retained
Linux x86_64 configuration, with the ordinary O0 native invocation, GDB rather
than ALL GNAT encodings, no representation-only mode, and
`List_Representation_Info < 3`. Character is eight bits, Integer is signed32,
and ordinary pointers are64 bits. No macOS transfer is claimed.

Consume the [normalized Main frontier](retained-native-expansion.md#normalized-main-frontier-for-backend-composition)
and the [once-only full conversion argument](retained-backend-gigi.md#constructor-bearing-main-entities-are-fully-converted-once):

```text
O + Ts + Ta + Tl + Tp <= E_Main
T = Ts + Ta + Tl + Tp
V_Main <= A_Main + 32 E_Main + 3 H_store
```

O is the ordinary object/capture/renaming/loop-index family; Ts counts signed
Integer subtypes; Ta constrained String subtypes; Tl String-literal subtypes;
Tp generated access-to-constrained-String types. These count distinct frontend
entities, not references or successful cache misses observed in a run. The
kernel multiplies each selected full-conversion branch once. A separate dummy
allowance of one dummy and at most one debug type per local type counts objects
that are subsequently replaced or discarded. Scope-only block/loop entities,
Main/finalizer subprogram profiles and ordinary-object lowering are outside T.
V_Main is an upper bound on source visits, **not** GCC nodes or bytes.

The input access-all unconstrained String type is deliberately outside Tp.
It belongs to the fixed input/scaffold graph, whose demand indicator must be
attached to the input construct. Its fat-pointer/dummy path cannot be charged
as an ordinary constrained pointer. A complete Main profile includes that
indicator even though the graph is fixed once demanded.

All dependency lookups of earlier Main types are charged to their own family
row, never recursively multiplied by the number of references. Completed
Integer, Character and the applicable fixed Standard.String graph are entry
states for this local result. General Main can enter the String graph through
an access type before a literal, so the literal-only cold-entry proof's empty
pending queues and absence of earlier dummy pointers are **not transferred**.
The complete composition still owes the fixed graph for every reachable entry
state, including unfinished/dummy states, plus its initialization costs.

## Actual size and alignment facts close the padding branch

Absence of user representation clauses alone is insufficient. The frontend
and gigi setters provide these stronger facts.

1. `Set_Size_Info` copies Esize, alignment and relevant representation flags,
   but not RM_Size (`sem_util.adb:29103–29121`). `Constrain_Integer`,
   `Constrain_Index`, `Make_Index` and `Set_Slice_Subtype` use this operation
   with Integer or an earlier Integer subtype
   (`sem_ch3.adb:15450–15498,20712–20734`;
   `sem_res.adb:13148–13165`). The existing constructor frontier excludes
   biased/representation-bearing types. Consequently Ts inherits Esize32;
   discrete RM size remains a known value in0..32. `Layout_Type` and
   `Set_Elem_Alignment` preserve the size and select four-byte alignment
   (`layout.adb:359–420,939–1052`). The subtype's GCC factory constructs
   precision32, including nonnegative subranges of the same-size signed base
   (`decl.cc:1901–2003`).
2. Standard.String explicitly starts with component size8 and alignment1
   (`cstand.adb:915–922`). **It also has an internally generated pragma Pack**
   (`582–595`). This is distinct from a packed representation: Character8
   does not need bit packing after freezing. Do not infer
   `Has_Pragma_Pack=false` from Silver's source pragma rule.
3. The plain explicit String subtype initially copies Standard.String's
   unknown Esize (`sem_ch3.adb:14440–14444`). A slice itype initially has
   unknown Esize (`itypes.adb:61–66`; `sem_res.adb:13167–13179`). Array freezing
   inherits the base alignment if necessary (`freeze.adb:4093–4102`).
   `Check_Compile_Time_Size` can set a small, nonzero, exact RM size8L
   (`freeze.adb:773–794,855–913`). Moreover the
   `Has_Pragma_Pack` arm of `Layout_Type` can set exact static RM size and
   Esize, rounding only to alignment1 (`layout.adb:510–553`). Thus the useful
   final invariant for nonnegative raw extents is **unknown size or exact
   natural size**, not “all local array Esize fields stay unknown”. For a
   superflat static range, raw `d=high-low+1<0` instead gives RM size8d and
   rounded Esize8(d+1); these negative/zero requests are ignored by native
   size validation. The #207 repair accounts for that case without clamping
   the frontend arithmetic. A dynamic subtype has no new static size
   supplied by these paths. Bounds determine `L=max(0,high-low+1)`; the
   accepted String domain has `L<=Integer'Last`.
4. String-literal subtype layout explicitly clears Esize and RM_Size and
   returns (`layout.adb:237–246`), including after an earlier small-size check.
   Its lower bound can still be dynamic. No constant-layout claim follows
   merely from constant literal length.
5. Ordinary constrained access types receive Esize/RM size64, and elementary
   alignment8 on this target (`layout.adb:248–357,939–1052`). The designated
   local String type is complete and nonrecursive. The ordinary pointer
   factory therefore applies. The access-all unconstrained input case instead
   receives128-bit fat-pointer size and remains in the fixed graph.

In gigi, `validate_size` converts a supplied size but does not change these
values (`decl.cc:9875–10000`). The Character component route validates8,
retains precision8 in `make_type_from_size`, and requests alignment8 bits
(`decl.cc:5538–5638`; `utils.cc:1522–1613`). Scalar precision32 and ordinary
pointer64 likewise remain unchanged in `make_type_from_size`; an ARRAY_TYPE
falls through unchanged. `rm_size` for an ordinary array/pointer is its
TYPE_SIZE (`decl.cc:11233–11260`).

For a new scalar, the native size is32 and the requested alignment32 bits.
For a local String it is8L and the requested alignment is either absent or8
bits, equal to the **component** alignment used by the padding gate. For an
ordinary pointer it is64 and alignment64 bits. A nonnegative known array size
is the same natural size; unknown, negative and zero-unspecified sizes supply
no padding request (`validate_size` returns before conversion for negative
sizes). The
`maybe_pad_type` equality tests therefore clear size/alignment and return the
original type before constructing a record (`utils.cc:1698–1750`).

This establishes zero padding-record construction for these local type
completion calls and their Character-component calls. No PAD/XVZ variable,
packable-record reconstruction, stripped padding type declaration or recursive
unpadding conversion is owed by those calls. It says nothing about arbitrary
imported records, over-aligned **objects**, or a conversion whose input came
from another family. The type dependency induction starts from the unpadded
Standard scalar/component types; it does not assume an already padded input
satisfies the same early-return argument.

## Cumulative constructor kernel

Use the already established scalar/pointer/range/array helper transfers in
[backend capacity](retained-backend-capacity.md#scalar-and-pointer-type-constructors),
including two possible pointer or canonical-array candidates, two non-atomic
qualified variants, and candidate allocations before cache/hash rejection.
Named artificial generated pointer declarations do not take the nonartificial
pointer-typedef copy path (`utils.cc:1010–1035`). GDB encoding excludes the ALL
array debug-record alternative (`decl.cc:2839–2854,2986–3035`).

The following counts include the per-entity dummy allowance and direct common
finishing. A helper's recursively lowered endpoint, symbolic fold, metadata
insertion or statement-list insertion is assigned to the residual interface
below, rather than counted twice here. This is the original first-kernel table:
current C is its row **plus27Ta** for #209, giving coefficients9/83/42/12.

| Cumulative request | Ts | Ta | Tl | Tp |
| --- | ---: | ---: | ---: | ---: |
| Fresh type nodes K, including dummy/debug/canonical/qualified candidates | 3 | 5 | 6 | 6 |
| TYPE_DECL nodes D, allowing stub and final separately | 3 | 4 | 3 | 2 |
| RM TREE_VEC(3) allocations R | 1 | 0 | 1 | 0 |
| lang_type payloads Lg, including dummy debug slot | 1 | 2 | 2 | 1 |
| Direct scalar constant requests C | 9 | 56 | 42 | 12 |
| Direct DECL_EXPR/SAVE_EXPR nodes U | 1 | 6 | 6 | 1 |
| Direct expression operand slots | 1 | 6 | 6 | 1 |
| Alloca request count | 0 | 2 | 0 | 0 |
| Sum of logical alloca payload bytes | 0 | 9 | 0 | 0 |

For Ts, one precision32 type plus two dummy/debug candidates gives3. Its first
RM-bound setter allocates one three-slot vector, which both bounds and the RM
size share. Six constants cover scalar fixup/layout; size validation and RM
size conversion add one each, and byte-divisibility validation adds one.
The two source endpoints are separately lowered, once on an association miss.

For Ta, the index range supplies one type and the nonshared array factory at
most two; dummy/debug add two. Index metadata requests one16-byte lang_type.
The index declaration, array stub, final declaration and dummy declaration
supply D<=4. The literal branch additionally creates its RM range (one type
and one TREE_VEC(3)); it has no separate array stub. The pointer branch permits
two pointer types and two const-qualified designated-type copies before adding
the two dummy/debug candidates. Copying a qualified type shares its existing
layout and language payload; it does not allocate a new RM vector.

The constant coefficients are intentionally cumulative and conservative:

- Each of at most two Character-array layouts contributes at most26 constants
  in total, using13 for a constant layout and the looser same allowance for
  a dynamic layout's six direct constants. Symbolic helper work is additional.
- A Ta Character-component validation adds two. The largest natural String
  bit size is `8*(2^31-1)`, needing at most three base32768 digits. For a typed,
  unbiased, at-least32-bit `UI_To_gnu` input of k<=3 digits, its source loop
  requests at most `3+5*(k-1)<=13` scalar constants: two initial constants,
  at most one digit plus two two-request constant folds per subsequent digit,
  and one final constant conversion (`cuintp.cc:85–166`). There is no widening
  retry because the target type is supplied. Ta size validation and RM-size
  processing therefore cost at most13+1+13; allow another one for the constant
  bound-shift alternative: `26+2+27+1=56`.
- Tl length conversion costs at most13, its null-bound alternatives at most2,
  its length-minus-one constant fold at most1, and its two layouts at most26:
  `13+2+1+26=42`. The four outer conversions and PLUS helper remain separately
  charged, including on constant paths.
- Tp pointer layouts cost at most8; size conversion, byte remainder, default
  pointer-size constant and RM-size conversion add four:12.

`create_index_type` allocates one lang_type slot and one declaration;
`create_range_type` allocates the single RM vector
(`utils.cc:2861–2894`; `ada-tree.h:257–265,348–351`;
`misc.cc:1389–1394`). Dummy debug metadata allocates at most one lang_type
(`utils.cc:521–568`; `ada-tree.h:415–419`). The scalar and array stubs can be
reused by common completion; D takes no credit for that reuse.

`gnat_pushdecl` calls `add_decl_expr` even when a later placement decision
will discard the expression (`utils.cc:960–990`; `trans.cc:9104–9137`). There
are at most `Ts+2Ta+2Tl+Tp` such type-declaration insertion calls; each creates
one unary DECL_EXPR. The array-layout transfer additionally permits four
SAVE_EXPR nodes per array entity, including both canonical layouts. Hence U
in the table counts allocated temporary/discarded expressions, not just final
reachable nodes. Predicate walks, binding-list work and marked subtrees remain
separate from these direct node allocations.

The constrained-array branch has two `XALLOCAVEC` calls with dimension1:
one tree pointer and one bool (`decl.cc:2603–2611`). Their logical payloads
are8 and1 bytes on this host. These are two individual stack requests, not a
heap vector or an aggregate RAM limit. Stack alignment, frame coexistence,
recursion and the later native frame bound remain obligations.

Each type allocation above has the accepted256-byte bound. RM vectors request48
bytes each, and lang_type payloads16 bytes. Each scalar constant request has
at most one40-byte INTEGER_CST allocation in the selected precision<=128
frontier, including the replacement-candidate charge. Thus this projection is

```text
selected caller bytes <= 256K + 48R + 16Lg + 40C
```

Use the corrected current C above; the historical table's C alone omits the
predicate. The new constant-bound continuation supplies further closed helper
and annotation terms for its explicitly classified subsets.

It omits D/U storage, type/name/context/hash backbones, constant cache vectors,
statement lists, allocator backing and every residual below. At most
`min(C, participating_type_instances)` constant-cache vectors, each at most2040
bytes, are additional. The incoming type instances and fresh copies must both
be included; a fixed number of scalar widths is not a valid cache count.
No whole-memory or whole-compiler conclusion follows from this projection.

## Residual roots are explicit, not zero-cost helper names

The allocation kernel has the following additional entry multiset. Counts are
upper bounds, so mutually exclusive branches may both be charged. Each entry
carries its actual typed argument graph; a root occurrence keeps its calling
path even if another occurrence points to the same node. The source-node bound
alone cannot replace these weights.

| Residual entry family | Number of entries |
| --- | ---: |
| Signed bound translation plus `elaborate_expression_1` | 2Ts |
| Literal lower-bound source translation | Tl |
| Direct `convert` outside layout | 7Ta+4Tl |
| Range/layout `fold_convert` | 6Ta+8Tl |
| `size_binop` outside constant charges | 17Ta+12Tl |
| Explicit overflow/empty-array `fold_build2` | 3Ta+2Tl |
| gigi binary helper | Ta+Tl |
| gigi conditional helper | Ta |
| `max_value` on bound-declaration initializer | 2Ta |
| `multiple_of_p` query | 2Ta+2Tl |
| SAVE predicate/traversal work, with direct SAVE nodes already in U | 4Ta+4Tl |

The #209 superflat predicate is now a closed additional row: at mostTa calls,
two typed three-digit `UI_To_gnu` plus one constant subtraction each, priced
as27Ta constant requests. Its two endpoint walks take at most2Ta(Ts+1)
pointer-following iterations by the earlier-type ordering. It is not included
in the original residual rows or their historical constant coefficients.

The Ta conversion/size rows expand `update_n_elem`'s two conversions and three
size operations (`decl.cc:7169–7197`) and the final maximum-size multiply.
The range factories contribute two `fold_convert` calls each; there is one
range for Ta and two for Tl. Each of two possible array layouts adds two
`fold_convert`, six `size_binop`, one empty-array `fold_build2`, one
`multiple_of_p` and two SAVE requests. The coefficient17 includes the possible
shift plus three update operations plus the final maximum multiply plus12
layout operations. The alternative constant shift is also charged in C.

For each multiset member r, a future source-sensitive transfer must supply the
full cumulative vector F(r) of allocations/slots/local storage for its helper,
including any internally synthesized or discarded trees. Add `sum F(r)` to
the kernel. One must not define F by observing a successful native run, set it
to one per request, or assume a syntactic bound on `match.pd` replacements
bounds recursive matcher application. The algebra is a closed direct kernel
and a precisely bounded number of **open weighted operands**, not a completed
bound on the symbolic helper graph. Ts is already free of padding/layout
folding in its type shell, but its executable bound lowering is still owed.

Metadata M is separate and includes entity-name construction, association/
dummy caches, alias bookkeeping, deferred contexts, global/import callbacks,
statement-list insertion, marking walks, and fixed startup. A complete sum is
`KERNEL + sum F(r) + ANNOTATION + M + OBJECTS/EXECUTABLE/FIXED`, followed by
later GCC/process phases. Direct type-node counts do not bound types created
inside an as-yet-unbounded symbolic helper.

## Annotation-root attachment and two-field descriptors

Known scalar/access size/alignment fields make their selected local common
finishing annotation-free. Ta/Tl completion supplies at most two size roots
per entity: TYPE_SIZE and rm_size; for unpadded arrays those are the same tree,
but a failed annotation can be retried, so charge both roots. Allow at most T
additional direct `UI_From_Int` alignment callbacks, conservatively even when
the frontend has already set alignment. Neither the scalar nor the array
common route requires placeholder-based `max_size` here: the normalized bound
roots have no discriminant/record placeholder, and the no-padding lemma adds
none.

Let Q be the sum of the accepted structural annotation weight over this root
multiset, including the failed inner-left retry rule in
[native backannotation](retained-backend-capacity.md#native-backannotation-returns-costs-to-ada-tables).
This attaches the **number and identity of roots** to the local family counts;
Q itself still requires the post-folder size shape. No `Q=2(Ta+Tl)` or
`Q=V_Main` substitution is justified for dynamic sizes. Then add

```text
GCC constants                  <= 32Q
GCC unary nodes / operand slots<= Q / Q
GCC annotation-map records     <= Q, each16 bytes
Rep_Table additions            <= Q
Uint entries                   <= 3Q + T
Uint digit words               <= 11Q + 3T
UI_From_Int cache requests      <= 3Q + T
annotation serial increments   <= Q.
```

The extra T is the direct alignment callback, not an additional annotation
root. Its allowance uses the general three-digit UI_From_Int row even though
these alignments are small. Add fixed/import/object annotation roots separately;
Rep_Table incoming504 and all other incoming table/serial states are not reset
at Main. Uint/Repinfo are writable during gigi while AST/name/list tables are
locked; the existing callback phase/backing conditions continue to apply.

For a `build_template` request on one of these completed constrained Main
String types, `utils.cc:4401–4460` now has no padding-unwrapping iterations.
Its fixed two-field template iterates once, requests two typed conversions,
two placeholder substitutions, two constructor-element appends and one
CONSTRUCTOR. After those conversions, absence of an **actual** placeholder
in the traversed expression permits the accepted substitution identity lemma;
a shallow `CONTAINS_PLACEHOLDER_P` test alone does not prove it. Conversion
output preservation of that invariant is part of the corresponding F(r).
For Dt such requests, the direct descriptor kernel is Dt CONSTRUCTOR nodes,
2Dt stored elements and Dt GC-vector allocations. Each append forms one
temporary16-byte `constructor_elt`. The first inexact reserve starts with four
slots: its unrounded request is `8+4*16=72` bytes
(`tree.h:1290–1294`; `tree-core.h:1640–1643`; `vec.cc:150–169`). The accepted
small-object GGC transfer rounds this to at most512 bytes; the recovered
capacity is between4 and31, so the second append needs no growth. Each vector's
subsequent caller request is at most504 bytes and rounded request at most512
bytes (`vec.h:393–425`). No payload-length factor occurs.

The two conversions per request keep their actual operand weights. Constructor
flag validation has at most two value roots; when both values are constant,
the two-field sort additionally calls the fixed comparator with bit-position
queries (`utils2.cc:2135–2217`). These validator/sort/query costs, caller
multiplicity Dt and the CONSTRUCTOR object's representation remain explicit
remaining joins; this is a closed direct vector/element kernel, not a complete
descriptor byte bound. This statement does not apply
to the fixed unconstrained String's placeholder-containing layout graph or
silently supply all fat-pointer conversion alternatives. These joins are the
next descriptor work, not an already closed descriptor byte bound.

## Verification, scope and next work

The original focused checker at author freeze36d478da0c verified the
complete-file source pins listed in its manifest, LF-based
source witness hashes, predecessor input hashes, the coefficient construction,
linearity/additivity, and the five retained real-source E_Main projections.
The projections conservatively put all E_Main into each coefficient maximum;
they are **not measured native allocations or complete capacity verdicts**.
No compiler, GNATprove, Lean, predecessor checker, native replay or broad test
suite was invoked. Source correspondence here is retained-source identity plus
the authored branch argument; arithmetic checks do not prove that argument.

Remaining #201 joins, in dependency order, are: review this local layout/kernel
result; close the symbolic root weights and descriptor constructors; attach
all executable/object families and fixed String/import entry states; provide
actual annotation-size shapes; then compose live/cumulative phase storage,
UIDs/counters, frames, emission/symbols, assembler/linker and ALI/binder. The
future verified SPARK implementation and direct graph obligation #89 remain
unchanged. This research packet does not implement that parent.

Current continuation, 2026-10-24: the first kernel and #207 were independently
reviewed and accepted before this helper round. The new source-only unit closes
the constant-bound subsets with combined constant coefficients35/188/150/12,
including the #209 predicate repair, source-bound translation and constant-size
annotation. It closes each selected two-field bounds-template helper at eight
constant requests, one24-byte CONSTRUCTOR and one72-byte element vector, and
attaches direct call-adaptation template occurrences to8Pc. These are scoped
helper exports, with shared backing, metadata and enclosing executable
conversions still separate. The linked continuation identifies the reachable
recursive matcher edges and the type-bound shape/rank argument required for
dynamic F/Q; neither a sixteen-node Ada endpoint nor a SAVE wrapper supplies
that missing proof. Independent review of this new unit remains pending.

Historical first-kernel round record, 2026-10-24: selected author setting GPT-6 Astra / Extra High;
runtime model/effort confirmation unavailable. Intended outcome: replace an
open local padding/helper inventory with an actual-source constructor kernel.
Achieved: natural-layout gate proof, cumulative coefficients, bounded residual
entry multiplicities and annotation-root attachment. Material correction during
authoring: Standard.String's compiler-generated pragma Pack means static array
Esize cannot uniformly be assumed unknown; the final lemma covers exact natural
sizes as well. Native execution time was zero. Offline elapsed time is retained
in `check-result.json`; total author elapsed time, tokens and cost are unavailable.
Independent review of36d478da0c plus the #207 repair is pending at this
author checkpoint. The repair's focused validation and current numerical exports
are retained separately; the old generator/output and original check result
remain historical. The new checker passed16 source files,29 LF witnesses and
3600 signed/boundary arithmetic pairs in0.491806 seconds, without native,
prover or predecessor replay.
