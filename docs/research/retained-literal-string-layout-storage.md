# Complete cold Standard.String layout constructor transfer

2026-10-18, Linux x86-64/LP64, authorized capacity research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The complete cold Standard.String conversion, **excluding the separately
accepted 94-request helper-construction interval**, has an envelope of
**216 direct GGC requests, 13,149 caller bytes, and 17,112 separately rounded
slot bytes**, plus **three ordinary requests totaling 192 caller bytes**.
The [packet](../evidence/retained-literal-string-layout-storage-20261018/README.md)
also exports every selected shared-container insertion/lookup demand.
These are lifetime request ceilings, including discarded fold candidates,
not live heap, stack, collector or RSS bounds. Independent review is pending.

Combining this residual with the
[accepted helper interval](retained-literal-original-string-storage.md) once
bounds the complete cold conversion by **310 direct GGC requests,
19,981 + 2P caller bytes, 25,024 + 2 rho(P+33) separately rounded bytes,
and five ordinary requests / 272 bytes**. Here P and rho retain that packet's
filename/global-object and individual request-rounding definitions. The later
173-request synthetic gimplification interval, cgraph registration, original
Main and elaboration (including the Main/null helper11 interval) remain
disjoint. Complete imported-frontend, global
container, collector and whole-pipeline flags remain false.

## Entry state comes from the selected program and startup

Use the exact direct-literal Put/Put_Line family and invocation in the
[layout packet](retained-literal-string-layout.md): C >= 1, N >= 0, one
`with Silver_IO;`, no declarations or use clauses, lengths <= INT_MAX,
non-LTO O0, no debug/instrumentation/sanitizer/offload/OpenMP, checking and
statistics disabled, Linux x86-64 SysV. Retain the installed/source
relevant-behavior premise; this adds no binary identity claim or admission.

Entry is the first complete
`gnat_to_gnu_entity(Standard_String, NULL_TREE, false)` called while translating
an imported I/O profile. Exit is its final return after common type completion,
association and deferred processing (`ada/gcc-interface/decl.cc:299–5126`).
It includes recursively demanded Positive conversion. Complete Character and
base Integer are already associated by gigi startup (`trans.cc:398–438`);
Character is its own Etype/base (`cstand.adb:761–801`). Thus their cache hits
are derived, not supplied by a caller flag. Startup `finish_character_type`
only sets the debug/RM view and does not query alias sets (`utils.cc:2113–2155`).

The residual excises both **complete** allocating self_referential_size
invocations, from their entry through returned CALL_EXPR, not only their
final function bodies. All of their private copies, substitutions, declarations,
names, types, calls, vectors and shared lookup demands stay in helper94.
This packet owns the original input expressions before those calls and XUT
layout using the returned calls. Shared demands below cover only those residual
operations; add helper94's demands once, and charge backing lifetime in the
existing shared-container component. Neither synthetic173 nor Main/null
helper11 contributes here. Per-literal subtype/constructor work and the first
literal's registration of XUA's alias ID also remain outside this cutpoint.

Positive is a signed-32 subtype of cached base Integer, Esize 32, RM size 31,
alignment 4, literal bounds 1 and INT_MAX (`cstand.adb:1040–1053`,
`layout.adb:939–1037`). Charge its **whole cold path once**, including naming,
constant lookup and alias demand, whether it was already converted or not.
A hit returns before that path (`decl.cc:400–445`); none of the selected
constructors can reenter Positive while it is being completed. This is a
uniform hit/miss envelope, not an extra caller Boolean or repeated cold charge.

The profile is an E_Procedure, so it does not take the E_Subprogram_Type
incomplete deferral. Standard.String is complete, nonprivate, nonlimited and
not an itype or an implementation of a packed array. No access type in this
source family can have established its dummy; profile conversion follows the
complete-type branch (`decl.cc:4192–4197,6058–6122`). The accepted prefix has
cleared pending queues. Main/elaboration and package/profile contexts do not
add a record context: `get_debug_scope` skips packages and Standard, returning
only record/subprogram scopes (`utils.cc:816–861`). String adds one temporary
incomplete-deferral level but no pending entry. Positive and String therefore
do not drain an unpriced incomplete or limited-with conversion at exit.
The imported procedure already holds force_global=1; String and cold Positive
can increase it to 2 and 3, respectively, restoring it on return.

The selected encoding is GDB, not ALL: `defaults.h:1442`, `common.opt:145`,
`misc.cc:73,277`, and Ada's imported same variable (`opt.ads:792–798`). The
retained command has no override; selected Linux x86 target headers do not
override the default. Therefore `rest_of_record_type_compilation` does not
construct XVE, even though `build_unc_object_type` passes debug=true to its
record finisher. No-debug alone would not prove that exclusion.

## Concrete constructor graph and metadata

`decl.cc:2187–2580,7255–7401` constructs the following graph once:

| Objects | Requests |
| --- | ---: |
| XUP, XUB and XUT RECORD_TYPEs | 3 |
| Pointer to XUB and pointer to XUA | 2 |
| Original UNCONSTRAINED_ARRAY_TYPE and XUA ARRAY_TYPE | 2 |
| Cold Positive, Ada bounds range and sizetype index range | 3 |
| Six fields P_ARRAY/P_BOUNDS, LB0/UB0, BOUNDS/ARRAY | 6 |
| TYPE_DECLs including stubs | 7 |
| 16-byte lang_type payloads: XUP/XUB/index/XUT | 4 |
| RM TREE_VEC(3): Positive and Ada bounds range | 2 |

The three record stubs and Positive stub are reused when named; XUB's stub
is not pushed as a separately named declaration. The other declarations are
index, XUA and original String (`utils.cc:2917–2995`). Artificial XUP avoids
the pointer-typedef variant-copy branch. Nonshared ranges return before hash
canonicalization; Character and fresh index are self-canonical, so XUA and
its pointers have no canonical-type recursion (`tree.cc:7198–7264,7460–7520,
7576–7642`). No type hash operation occurs outside the accepted helper interval.

Character's component validation requests size 8 and computes 8 mod 8.
`make_type_from_size` sees unchanged precision and `maybe_pad_type` sees
unchanged size/alignment, returning Character (`decl.cc:5540–5688`,
`utils.cc:1522–1590,1698–1750`). Positive uses `make_signed_type(32)`, two
static bound elaborations, alias copy, stub and common size/RM completion.
Its bounds are Integer-typed integer literals, so `gnat_to_gnu` makes scalar
constants, no elaboration variable, SAVE_EXPR or extra type (`decl.cc:1930–2009,
7532–7680`, `trans.cc:6607–6635,8768–8960`). Known Esize, RM size and alignment
avoid back-annotation. Original unconstrained String has no TYPE_SIZE and
unknown Esize/RM size, so no variable-size elaboration variable or size
back-annotation is introduced in common completion.

All declarations are global. `add_decl_expr` first builds and then marks a
DECL_EXPR even for global types; charge **five unary temporaries** (Positive,
XUP, index, XUA, XUT). Original unconstrained String returns before that build.
The same five types append to shared global_decls; XUB only has its stub
(`utils.cc:894–1068`, `trans.cc:9103–9189`). MARK_VISITED has no visited-set
allocation. Standard/Empty contexts add no deferred-context node. Startup
builtin declarations already established the translation-unit context.
Association writes reuse the preallocated gigi arrays (`utils.cc:429–497`).

## Original extent folds, including candidates

Use signed-32 readonly bound references l,u and let L=(u64)l, U=(u64)u,
Q=(u>=l). The initial graph has one placeholder, three COMPONENT_REFs,
one INDIRECT_REF, two widening conversions, one plain comparison and one
plain conditional. The indirect reference sees a P_BOUNDS component,
so `build_fold_indirect_ref` builds one INDIRECT_REF; it cannot take any
ADDR_EXPR/constant-object path. The high bound is Q?U:(L-1).

The following finite constructor trace prices the original size expressions
before the accepted helper interval. It is not inferred from final tree size.
Every conditional-fold row allows one comparison inversion and one ternary.

| Source fold | New scalar expressions / factories allowed |
| --- | --- |
| L-1 | One negated-one constant and one PLUS; `match.pd:2201` rewrites subtraction of an easily negated constant. |
| (Q?U:(L-1))-L | One U-L binary, one conditional and possible inverted comparison. The false branch contracts (L+(-1))-L to existing -1 (`match.pd:4362–4383`). |
| 1 + previous result | One `(U-L)+1` binary, one false-arm constant, one conditional and possible comparison. Commutation precedes construction. |
| Widen byte conditional to u128 | One widening, one converted zero constant, one conditional and possible comparison. The false arm is a constant, so the two-conversion pull-back branch fails. |
| Multiply widened conditional by 8 | One true-arm product, one zero-product constant, one conditional and possible comparison. |
| Multiply byte conditional by 1 | Existing operand, no expression request. |

This is **one unary, eight binaries, four ternaries and four scalar factory
slots** beyond the initial graph. `fold_binary_op_with_conditional_arg`
constructs both arms before its success test (`fold-const.cc:7019–7103`);
the trace counts both. Its nonconstant-argument case here succeeds because
the false branch becomes constant. No conditional-distribution attempt on
these inputs leaves an uncounted rejected candidate. `fold_build*` allocates
a fallback only after the fold returns null (`:13886–14024`).

Generated transformations recursively fold nested results, but the selected
results use each capture once; `genmatch.cc:3575–3605` therefore creates no
unshare copy. The repeated-L cancellation returns its constant capture;
same-type view conversions allocate nothing. Arithmetic identity predicates,
zero-one predicates, comparison and conditional predicates inspect fixed-width
values. `tree_nonzero_bits` on these GENERIC nodes returns inline wide values,
not a range-query allocation (`fold-const.cc:16715–16796`). Widening barriers
and distinct leaves exclude narrowing and two-variable cancellation elsewhere.
`extract_muldiv_1` rejects moving the u128 product through wrapping u64
arithmetic before converting its factor (`:6647–6675`). The accepted helper
packet's arithmetic association and conditional-inversion case argument
applies to the resulting extent and each of these nonconstant arms.

The helper inputs are exactly
`Q ? ((U-L)+1) : 0` and `Q ? (u128((U-L)+1)*8) : 0`, up to the accepted
conditional orientation. Round-up of the bit extent to 8 requests its divisor
then proves divisibility from the product; byte round-up by 1 returns early.
The two full helper invocations are charged only by the accepted 94 row.

## Records, final object rounding and scalar factory ledger

XUP has two 64-bit pointers, XUB two 32-bit Positive fields. XUT has the
64-bit bounds record followed by the variable XUA. Six field starts are
naturally aligned; there is no packing, explicit field position or bitfield.
`create_field_decl` is called with no SIZE/POS and packed=0. Accordingly
`layout_decl` copies existing type sizes; finish_bitfield_layout has no
representative. There is no pending-static vector. The type's Pack flag does
not make these implementation record fields packed.

Each record allocates one `record_layout_info_s`, 64 bytes by the LP64 field
layout in `tree-core.h:2303–2330`, and frees it. The two fixed records each
normalize the running bit position once. On the default x86 alignment 128,
XUP normalizes after its second field and XUB at final byte normalization.
There are five constant field advances and one variable advance. Four field
positions are also computed by the fixed-record mode scan. XUT's variable
size exits that scan before its field loop (`stor-layout.cc:872–905,990–1003,
1285–1780,1783–2035,2320–2358`). Alignment warning hooks return without offset
construction because no selected field/type has a warning-alignment attribute.
Target mode/field-alignment hooks inspect scalar metadata only.

Let B be the existing byte helper CALL_EXPR and T the existing bit helper
CALL_EXPR. XUT's variable field computes byte offset 8+B. Its raw bit size
is `u128(8+B)*8`. Its required record alignment is 32 bits. Selected rounding
therefore constructs:

```text
bits  = (u128(8+B)*8 + 31) & u128(-32)
bytes = (B + 11) & u64(-4)
```

The initial variable offset, widening/product, bit add/mask, byte add/mask,
and **both** final `merge_sizes(64,T)` calls cost one unary and eight binaries.
The latter two expressions are built even though XUT's Ada size is not stored.
Each `finish_record_type` always computes bit_position and two merge_sizes
per field (`utils.cc:2221–2448,2698–2775`). Those costs are not omitted merely
because the final type stores only one result.

For bit rounding, `multiple_of_p` reaches product factor 8, creates the ratio
32/8=4 and then fails at the helper CALL through the widening/plus chain
(`fold-const.cc:14230–14355`). It is not assumed allocation-free. `round_up`
then requests 31 and -32. The AND simplifier constructs the positive 32
probe even when its multiple test fails (`:11932–11948`). Byte rounding
requests 4,3,-4, combines 8+3 to 11 via `match.pd:4407–4444`, then makes its
positive-4 AND probe. The second round-up of each already masked result
only requests its divisor: multiple_of_p succeeds on the mask.

No generic mask rewrite is silently omitted: `fold_bit_and_mask` rejects
negative-alignment masks at its initial `(mask & (mask+1)) != 0` gate before
any factory (`fold-const.cc:12758–12774`, `match.pd:1677–1687`). Two-widening
narrowing needs two converted operands and a low-bit mask, absent here
(`match.pd:9794–9822`). Product/add reassociation cannot cross the u64-to-u128
conversion; negative-product factoring rejects positive 31 (`:4789–4804`).
The byte constant association makes one constant and one PLUS, using its
helper capture once. Further expression distribution, bitfield, vector,
pointer, SSA/GIMPLE and floating cases fail before result construction.

Every selected scalar factory site is recorded in `derive.py`. There are
**129 scalar factory slots**, each charged as a possible fresh INTEGER_CST
of at most 40 caller bytes. This is deliberately looser than counting unique
cache misses: constant-mode sites that return an existing operand are still
charged. A symbolic site is also allowed its single constant-result case
while its separately audited expression path is charged above. There is no
unproved per-node allowance or unbounded rewrite iteration.

The ledger consists of component validation 2; Positive extrema/layout/bounds/
size completion 16; two pointer layouts 4; maximum length/byte-size 6; array
literal and round divisor 2; fixed field advances 5; two normalizations 14;
three final bit/byte positions 18; four mode-scan positions 12; six finisher
positions 18; twelve merge calls 12; variable advance/probe 4; XUT rounding
12; and the four original-extent constant factories. Positive's INT_MAX
uses Base=2^15 digits [1,32767,32767]: base+first+2*(digit,multiply,add)=8,
not one direct Uint lookup (`uintp.ads:464–487`, `cuintp.cc:76–159`). These
C++ conversions only read Ada Uint tables; they never append Uint digits.

All scalar values have precision at most 128. Their ordinary wide-integer
values use at most two 64-bit units, but an unsigned value with its high bit
set requires up to **three extended stored units**: `get_int_cst_ext_nunits`
returns `precision/64+1` (`tree.cc:1581–1588`). XUT's unsigned 128-bit -32
mask is such a value. `make_int_cst` allocates
`sizeof(tree_int_cst)+(ext_len-1)*8` (`:2925–2930`); the selected LP64
typed prefix is 16 bytes and the one-unit struct is 24 bytes
(`tree-core.h:1565–1578`). The existing **40-byte** factory ceiling therefore
covers all three units, including discarded candidates. This corrects the
stored-unit explanation and metadata from frozen `e652db280a` under
[#135](https://github.com/berkeleynerd/silver/issues/135); no allocation total
changes. `force_fit_type` creates either a fresh overflow constant or
one shared-factory result, not both (`tree.cc:1685–1729`). Small-value caches
for base Integer, sizetype and bitsizetype are startup inputs; fresh Positive
only receives its two out-of-small-range GCC extrema, while its RM bounds
are base-Integer typed. No fresh per-type constant-cache vector is needed.
The 129 ceiling also bounds insertion-capable large-integer lookups (including
hits and discarded extended-unit candidates), new entries and small-cache writes.
Shared table replacement lifetime is consumed by the aggregate component.

Subsequent calls of variable_size on T, B or XUT's rounded expressions may
enter self_referential_size, but its initial skip of constant arithmetic
reaches the existing CALL and returns before allocation. There are exactly
two allocating helper constructions, not extra helper requests for XUT.

## Names, ABI predicates, pools and exported demands

Eleven identifier lookups suffice: `string`, `positive`, `string___XUB`,
`string___UB0`, `string___XUA`, P_ARRAY/P_BOUNDS, LB0/UB0 and BOUNDS/ARRAY.
Charge all as misses: eleven 40-byte identifier nodes and 93 character bytes
including eleven NULs. `Get_External_Name` reads existing Chars, skips Standard
qualification, and appends into the fixed Name_Buffer. It does not call
Name_Find or allocate an Ada name entry (`exp_dbug.adb:613–908,1292,1340`,
`namet.ads:143–162`). No bound encoding runs under GDB. C++ identifier strings
use the stringpool GGC atomic callback, not an ordinary string obstack
(`libcpp/symtab.cc:152–184`). Standard locations map to BUILTINS_LOCATION
before line-map access (`trans.cc:11006–11019`); warning suppression cannot
insert a map entry at that reserved destination.

`type_for_nonaliased_component_p` is called for LB0, UB0 and Character.
Its must/default-pass-by-ref checks do call the target ABI. The selected
`ix86_return_in_memory` only runs `examine_argument`; it does **not** query
`hard_function_value` or construct a REG (`misc.cc:1097–1137`,
`calls.cc:936–961`, `i386.cc:3629–3667,4451–4481`). Thus these three predicates
add zero RTL requests. This differs from the corrected six REG allocations
in the later synthetic interval, whose aggregate_value_p also queries the
hard return value. Positive's ALIAS_SET_COPY can create at most one base
Integer alias ID and two alias_sets pushes including a cold sentinel, with
no alias entry or child hash; its scalar component-recording path is empty.
Charge that safe alternative regardless of prior Integer alias state. XUA
stays alias-unknown and has TYPE_NONALIASED_COMPONENT=true; Character alias
state is unchanged. The first literal subtype's XUA alias registration is
owned by its own interval.

There is **no constant-pool API reachability** in the residual. The only
selected trees are scalar constants, types, declarations, bound references,
scalar arithmetic/conditionals and the existing helper calls. No CONSTRUCTOR
or STRING_CST is built, no aggregate-address branch is selected, and static
Positive bound elaboration does not create a VAR_DECL. `add_decl_expr` receives
only TYPE_DECLs; its variable-initializer branch is false. `layout_decl` sees
fresh FIELD_DECLs with no RTL and uses DECL_RTL_IF_SET. None of these paths
calls make_decl_rtl, tree_output_constant_def or output_constant_def. Mask
and range folds cannot introduce addresses. The accepted helper packet
separately proves that its only addresses designate helper FUNCTION_DECLs.
Consequently the **whole cold conversion**, including that packet, contributes
zero tree-pool insertion-capable lookups, entries, replacement objects,
constructor-address materializations and make_decl_rtl calls. This conclusion
comes from reachability, not from the helpers' lack of eventual emission.

Export 13 DECL UIDs and ten type UIDs, eleven identifier insertion-capable
lookups/entries, 129 large-integer insertion-capable lookups/entries and
small-cache writes (alternative conservative ceilings), five global_decls
pushes and at most two alias_sets pushes. Export zero type-hash lookups,
new integer-cache vectors, pool demands, finalizers, cgraph registrations,
function-definition numbers, labels, pseudos and symbol-order increments.
Keep incoming +13 <= INT_MAX and type UID +10 <= UINT32_MAX; composed with
the helper packet use +21 and +14, respectively, together with its P/fnno
guards. The five shared declarations and these table demands are consumed
once by existing shared-container lifetime components, not five private
containers or another copy of the helper's size_functions vector.

Selected worker: GPT-6 Astra / Extra High; runtime-setting confirmation and
token/cost measurements unavailable. Round began 2026-10-18 21:31:43 UTC.
Only source reads, six new raw upstream byte comparisons and focused offline
checks were run. Native compiler, build, prover and full-test runs: zero.
No production, Oracle, admission, tool, proof-pin, aggregate, GitHub or memory
change is part of this packet. The packet records the actual check time.
