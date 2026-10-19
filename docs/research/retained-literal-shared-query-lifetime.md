# Selected literal shared-query lifetime

2026-10-19, Linux x86-64/LP64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This source audit closes the selected later tree identity, tree type/integer
cache, alias-vector, global-declaration/statement-list vector and scalar
finalizer query lifetimes. It adds **zero new allocation events**: the named
later requests, five RTL controls and completed String alias graph retain
their existing owners. Its purpose is to replace the unspecified residuals
for these families with a complete selected-path argument.

The [offline packet](../evidence/retained-literal-shared-query-lifetime-20261019/README.md)
is a research candidate for independent review. It does not close all native
counters, typed-array/collector state, the total GGC event ledger, production
invocation or whole-pipeline capacity. It changes no admission or Oracle rule.

## Boundary and evidence

Retain GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea` and the accepted one-with,
declaration-free Main/SPARK family with C>=1 direct qualified literal
Put/Put_Line calls, N>=0 nulls, D distinct output callees and each decoded
length<=INT_MAX. The configuration is the retained Linux SysV generic O0,
no-debug/no-LTO/no-offload/no-instrumentation route with the reviewed
`-fsplit-wide-types` design. No plugin, PCH, target reinitialization, alternate
ABI, function-specific options or additional source bodies are introduced.

The incoming original interval ends at `finalize_size_functions` return.
Its accepted [original shared packet](retained-literal-original-shared-storage.md)
already includes both cold scalar helpers' initial gimplifications. The
[named later packet](retained-literal-later-shared-storage.md) owns Main's
descriptor/CF/SSA/pool declarations and identifiers and the graph controls.
The [repaired RTL packet](retained-literal-rtl-cache-controls.md) owns the
two-setter register-cache result and five fixed controls. The
[completed String graph](retained-literal-type-alias-controls.md) owns five
type-derived aliases, the fixed-frame alias, four entries and two child maps.
This audit does not recharge any of them.

The exact original result and indexed filename correction must identify the
same bytes and recognized counts as the input source. In particular use
corrected identifier ingress 40847, not the historical 40846. Named, RTL and
graph evidence are also checked for the same source. Complete file pins and
the retained source/installed-behavior premise apply. No native execution,
capture, compiler build, accepted-suite, aggregate or corpus-checker replay
was performed. Targeted API/writer searches guide the handwritten audit;
they do not prove reachability by themselves.

## Selected roots after original construction

The accepted literal [pipeline](retained-literal-pipeline.md) supplies the
whole-body ingress and its immutable type/declaration metadata, two pointer
component stores per descriptor, C direct void calls, and N label/nop inputs.
It also supplies the pool/graph, initial CF/CFG/SSA, ranger and out-of-SSA
lifetimes. The [RTL shape](retained-output-rtl.md), split/LRA/frame and emission
arguments give two address stores, register argument extraction, a direct
call, fixed frame and scalar/string constant output. These are the roots of
this audit, not a count inferred from a sample. The two unreferenced scalar
helpers are removed before RTL; their accepted
[synthetic argument](retained-literal-synthetic-function-storage.md#unsharing-scalar-lowering-and-folding-closure)
already covers failed matcher candidates and scalar constant/type zeroes.

| Later root | Type/integer/identity disposition |
| --- | --- |
| Whole-body and constructor unsharing | `mostly_copy_tree_r` stops at types, declarations and constants (`gimplify.cc:944–973`); constructor copies preserve their types. |
| Descriptor materialization, CF common label, initial .MEM | Existing types; C+2 declaration UIDs and one identifier, already in the named packet. |
| Bounds-address hook and direct constant pools | Existing XUB/literal type; default bounds pointer hits; 2C pool declarations/identifiers already named. Readonly declaration storage does not qualify the type. |
| Ordinary GIMPLE folds and CFG cleanup | ADDR single-RHS stores and direct nonbuiltin void calls select no replacement matcher or handwritten rewrite; there are no conditions, switches, real SSA values or PHIs to generate a type/range expression. |
| IPA and queued inline transform | No source callee body, recursive edge, clone, thunk, constructor/destructor, virtual query or adjusted parameter. Active maps/scans remain charged, but there is no body/type copying. Modref's gate being true does not suffice: `analyze_function` exits at `!flag_ipa_modref` (`ipa-modref.cc:3132`) and the later execute exits with null summaries (`:5577–5581`). |
| Non-LTO free-language-data | Returns before integer alias sweep, type copying and generic type rebuilding (`ipa-free-lang-data.cc:1126–1156`). The Ada alias hook remains installed; LTO's `gimple_get_alias_set` hook is not selected. |
| Fixed first RTL setup | The accepted fixed-setup source projection retains zero declaration/type UID changes; `init_dummy_function_start` calls `push_dummy_function(false)`, bypassing its declaration/type/name branch (`function.cc:4980–5020`). |
| Main expansion and calls | Existing XUP, pointer fields and direct function types; void return and register-only fixed descriptor ABI exclude invisible-reference, structure-return, variable-size argument and block-copy helpers. |
| Split/LRA/frame/CFI/final output | RTL/scalar records; no spills, debug declarations, stack protector, TLS/GOT access, builtin/libcall, sanitizer, thunk or alternate-target code. No tree-backed size arithmetic is needed by the fixed frame. |
| Unit constants | Raw STRING_CST and ordinary aligned XUB fields with existing Positive integers. No array-constructor iteration, BitInt limb conversion, floating bitfield conversion, shortened string target or pointer-integer NOP initializer. |

The type-building alternatives in these routines are real obligations, even
when their eventual rewrite would fail. The following checks close those
alternatives for the selected roots.

## Type and tree-integer constructors, including failed probes

`canonicalize_addr_expr` asks for `build_pointer_type(element_type)` before
checking whether an array-address conversion can be rewritten
(`gimplify.cc:3309–3357`). It would be incorrect to dismiss that call merely
because the final pointer types differ. Here the original conversion between
the literal-array pointer and P_ARRAY's XUA pointer has the same address
space and default pointer mode, and neither is a function pointer.
`useless_type_conversion_p` therefore returns true independently of the
pointed-to array identity (`gimple-expr.cc:68–149`). The conversion is stripped
at gimplifier entry (`gimplify.cc:20371`) and again, if needed, before the
canonicalization dispatch (`:3362–3394`). No Character-pointer candidate or
ARRAY_REF is created by this path.

The actual component expressions have exactly their fields' unqualified
types, so `canonicalize_component_ref` does not build a qualified variant
(`:3270–3292`). The bounds hook and direct call reconstruction request the
same existing default pointer as original construction. The alias pointer
canonicalizer's two one-layer XUA/XUB roots do likewise. Their
`TYPE_POINTER_TO` chains are rooted through the retained types; weak-cache
collection does not clear them. The cache test precedes `make_node` and
`layout_type` (`tree.cc:7198–7264`). These calls make no type UID increment,
type-hash insertion-capable lookup or pointer-layout integer request.

Other gimplifier type builders require variable-sized stack objects,
addressable conditional results, atomic/varargs/builtin operands, RAW_DATA
array constructors, OpenMP or dispatch variants (`gimplify.cc:1498,1989,
4075–4092,4389,4512,5605,6260,10236,10461,12166,15444,18276,22122,22194`).
None is in the root set. The ordinary aligned component/address leaves do
not select the fallback aligned MEM_REF path. Assumption-function extraction
(`gimple-low.cc:421,675`), vector rewrites (`tree-ssa.cc:1724,2123`) and CFG
selftests (`tree-cfg.cc:10545`) are also absent. Range selftests are not the
ordinary range-query implementation. The selected ranger has no real-SSA
query; address/Boolean bounds fit its existing inline wide-integer storage.

Call ABI alternatives are excluded by the established descriptor ABI,
rather than by C's argument count: `apply_pass_by_reference_rules` only
builds a pointer on its true branch (`calls.cc:975–983`); the fixed 16-byte
descriptor is passed in the two integer argument registers. The
structure-return pointer branches (`:2974,3653`, `function.cc:2400,5577`)
do not apply to void output calls/Main. No incoming Main formal or result
needs a declaration copy, by-reference conversion or hidden result pointer.
Block-copy/set libcalls, `make_tree` conversion of RTL, stack checking and
late `init_one_libfunc` thus have no selected call site. The return-ABI queries
for the scalar helpers are already covered by synthetic173 and never expand
their arithmetic bodies to RTL.

For tree integer constants, expansion's `get_inner_reference` starts with
`size_zero_node` (`expr.cc:8487–8498`). Each selected store has one ordinary
COMPONENT_REF. Its operand 2 stays null because the field offset is already
an invariant (`gimplify.cc:3620–3639`). `component_ref_field_offset` returns
the existing field offset through constant placeholder substitution
(`tree.cc:13390–13415`). `size_binop(PLUS,0,offset)` returns that operand
before `int_const_binop` (`fold-const.cc:2092–2115`). The nonnegative aligned
0/8-byte field positions exclude negative-offset repair, bitfield
representatives and array-index arithmetic (`expr.cc:5855–5921,6061–6081,
8570–8671`). The remaining arithmetic uses native `poly_int`/wide-int values,
not new INTEGER_CST trees.

`expand_call_stmt` does reconstruct C CALL_EXPRs
(`cfgexpand.cc:3131`). `build_vl_exp` requests `build_int_cst(sizetype,4)`
(`tree.cc:11024–11040`). Original construction of every one-argument call
already requested that identical slot. `sizetype` is a global rooted type;
its `TYPE_CACHED_VALUES` small-integer vector is retained, not a weak hash
entry. The later C lookups have **zero writes, zero new vectors and zero
large-integer hash lookups**, including after collection. This is a specific
rooted-hit argument, not a general warm-cache assumption. Variable argument
size arithmetic at `calls.cc:1650–1680` requires nonnull `args_size->var`;
the selected argument has none.

Pool output handles Positive values as existing ordinary INTEGER_CSTs and
the literal as STRING_CST (`varasm.cc:5410–5510`). It does not take the
pointer-conversion branch (`:5460–5480`), BitInt limb construction
(`:5590–5603`), array-constructor index construction (`:5702`) or floating
bitfield conversion (`:6181`). Scalar output reaches RTL GEN_INT, which is
owned by the separate RTL cache packet. Main's GIMPLE fold zero and the
helpers' failed-pattern zero are inherited from their exact accepted roots.

Consequently later type UID increments, type-hash lookup/entry demands,
large-integer hash lookup/entry demands, small-cache writes and small-cache
vector demands are all zero. The private type/integer hash references in
`tree.cc` give no selected nonlookup resize/empty/traversal replacement.
The type-canonicalizer's `remove_elt` only removes integer extrema; ordinary
GC weak-cache removal also cannot raise capacity. Initialization is already
owned, and PCH restoration/reinitialization is excluded.

## Complete alias-query partition

The complete targeted API census covers `new_alias_set`, `get_alias_set`,
`get_deref_alias_set`, `record_component_aliases` and `record_alias_subset`.
The selected type graph is exactly the graph priced in the predecessor:
Integer/Positive and XUA already known, plus XUB, pointers XUB/XUA, XUP and
the conservative existing XUT root. The latter allowance is retained even
though executable expressions do not use the thin object.

| Query family | Root or exclusion |
| --- | --- |
| Gimplifier constructor preevaluation | XUP LHS; each constant address stops before recursive value alias queries (`gimplify.cc:6005–6012,6668–6678`). |
| `set_mem_attributes_minus_bitpos` | Pool literal/XUB declarations and selected component/descriptor roots (`emit-rtl.cc:1965–1992`). FUNCTION_DECL MEMs explicitly skip the setter (`varasm.cc:1675–1678`). |
| Component store/constructor expansion | The two pointer fields or XUB/Positive. Other expr alias calls require array element stores, block constructors or a MEM_REF; the selected shape has none. |
| Ada hook | Padding/extra subtype/unconstrained-array forwarding remains inside already-described bases (`misc.cc:710–733`). Unchecked-conversion alias manipulation in `trans.cc` is not selected. |
| `get_deref_alias_set` / alias-pointer comparison | Returns zero before querying a pointed-to type with strict aliasing disabled (`alias.cc:717–733`). This early return does not erase ordinary `get_alias_set` calls. |
| Tree SSA alias queries | AO-reference queries see the same declaration/component roots; there are no other memory expressions. `same_type_for_tbaa` receives only those object types. Optimizing SCCVN/vector/data-reference clients do not run. |
| IPA modref/ICF/polymorphic and LTO | Modref's actual early returns above; ICF option false; no virtual/BINFO input; no streaming or LTO hook. |
| Temporary stack-object matching | `objects_must_conflict_p` and `function.cc:941` have empty selected temp-slot lists. |
| Bitfield folding, builtins and foreign frontends | No selected bitfields, builtin call, C/C++/Fortran frontend or unchecked conversion. |

All direct native alias-ID constructors are covered separately:

* `get_frame_alias_set` allocates at most the single already-priced static
  alias (`alias.cc:1376–1386`). `get_varargs_alias_set`'s apparent
  `new_alias_set` is in the inactive `#else`; its compiled arm returns 0.
* Spill-slot declaration creation requires `get_spill_slot_decl(true)` via
  `set_mem_attrs_for_spill` (`emit-rtl.cc:2817–2855`). Its true callers are
  legacy reload and actual LRA spills (`reload1.cc:2284`, `lra-spills.cc:160`).
  Selected LRA has no spill; alias-analysis read probes pass false and cannot
  allocate. Variable tracking is disabled.
* The i386 GOT alias is used for nonlocal PIC data/TLS or no-PLT address
  loads. The selected local literal/bounds SYMBOL_REF takes the early
  legitimate 64-bit displacement return (`i386.cc:12418`); direct default-PLT
  output calls do not materialize a function address. TLS/no-PLT and other
  targets are absent (`:12479,12501,12735,12746,12935`, `i386-expand.cc:411`).
* Setjmp/longjmp aliases require those builtin expansion routes
  (`builtins.cc:894,1003`); selected calls are ordinary output routines and
  there is no nonlocal-goto/SJLJ setup. ASan shadow initialization and
  control-flow hardening require disabled instrumentation options
  (`asan.cc:1486`, `gimple-harden-control-flow.cc:81–86,645`).

The rooted graph's known aliases are never reset or its fields modified by
these later routes. Alias IDs are installed before component recursion and
known IDs return directly, so interleaving repeated queries cannot create a
second graph. No child map is weak/deletable. There are **six later alias
pushes total**, including the frame, with no new sentinel; the original four
pushes already cover cold initialization. Alias lifetime is thereby closed
at the predecessor's 414861 vector occupancy / 414860 alias-ID projection.

## Global declarations, statement-list cache and other identities

`global_decls` has one writer, the push in `gnat_pushdecl`
(`utils.cc:978–983`). Its frontend type/variable/label/function wrappers run
in original translation. Later generic temporary/pool declarations use
`build_decl` directly, and neither the Ada bounds hook nor alias hook calls
`gnat_pushdecl`. The global-output routine iterates the list; its forced
dummy uses direct `build_decl` (`:6460–6532`). External builtins are routed
to `builtin_decls`, not this vector. Later pushes are zero; original D+8
is the complete post-prefix demand.

For `stmt_list_cache`, only `free_stmt_list` pushes (`tree-iterator.cc:53–57`).
Its indirect append/splice writers cannot be ignored merely because a file
has no direct alloc/free call. Whole-body unsharing explicitly preserves
STATEMENT_LIST headers (`gimplify.cc:965–966`). Main's
`gimplify_statement_list` only walks and `tsi_delink`s existing entries
(`:2286–2309`), with no cache push. The helpers' simple comparison makes
`shortcut_cond_expr` return before its multi-term short-circuit append/list
construction (`:5275–5280,5359–5382`). Constructor/address unsharing contains
no statement list. The constructor's side-effects-only append branch
(`:20744–20756`) has no side-effecting element to append. Other gimplifier list writers need cleanup/profiling,
short-circuit predicates, OpenMP or dispatch variants; there is none. IPA
constructor/destructor list builders have no input; body copying via
`tree-inline.cc:888` has no inlinable callee body. GIMPLE sequence operations
do not use this tree cache. Later pushes are zero; the complete original
demand remains H=265+167C+12N. Collection can clear the cache but cannot
increase its lifetime push count or erase its allocated-capacity history.

After these type/alias and generic-constructor closures, the complete later
identifiers are the named 2C+1, and complete later declaration UID increments
are 3C+2. The apparent other writers have concrete excluded triggers:
`%sfp` needs a spill; `.result_ptr` needs a structure return; `make_tree`'s
fallback VAR needs a block/libcall/RTL-to-tree conversion; debug expressions
need debug output; x86 thunk/stack-protector/varargs helpers need their absent
features. LC pools and .MEM are already charged. `generate_internal_label`
has only UBSan and foreign-frontend callers; target assembler-label macros
are different functions and do not intern identifiers. Ordinary emitted
names use existing identifiers or `maybe_get_identifier`, while libcall
external-name insertion requires an absent libcall. GCC integer/register/
label/callgraph counters retain their separate owners and are not inferred
from this tree UID result.

## Scalar-finalizer control census

Use the retained typed-destructor census to classify record destructors and
raw/no-dtor allocations, and the targeted `create_ggc`/typed-constructor
writer audit for their selected lifetimes. The census is an audit aid, not
a reachability proof. Original controls, possible delayed creation and graph
controls are included once regardless of when they interleave.

| Registered controls after the prefix | Lifetime allowance and owner |
| --- | --- |
| Ada namespace map; two helper default-def tables; warning and assembler-name maps |5, original shared allowance. |
| Main default-def table; four call-site-table lifetimes; IPA value-range table |6, named later allowance. |
| Dummy and Main RTL pool tables; temporary-address table; two frame-insn tables |5, repaired RTL-control allowance. |
| Alias child maps for XUP and conservative XUT |2, completed alias graph. |
| **Total** |**18 scalar registrations**. |

Remaining constructor groups are excluded or prefix-owned as follows:

* Tree/RTL hash initialization, frontend pad/size/packable/annotation maps,
  section/object/constant tables, EH runtime-type map, symbol table and
  optab/libfunc initialization belong to fixed startup. Their controls are
  not rebuilt on the selected route. Warning and assembler maps are rooted
  until their normal end; GC cannot trigger their recreation.
* Recorded loop-exit tables are not requested by the selected loop-state
  modes; DF and the IRA/LRA/ranger private hash containers use ordinary
  allocation. The repaired RTL packet establishes these exclusions.
* Function-version/clone-name tables need cloning or multiversioning;
  noted-function-pointer tables need those IPA inputs; Modref constructors
  are behind its false option/absent streaming routes. The IPA summary
  managers explicitly use `ggc_alloc_no_dtor`; their raw records do not
  register embedded maps separately. No scalar return range or real scalar
  argument creates a new IPA range record for this void/aggregate shape.
* `symtab->section_hash` needs an explicit per-symbol section assignment;
  selected Main, helpers and pools have none. Default assembler sections use
  the prefix-owned `section_htab`. Priority maps need static ctor/dtor
  priorities, absent here (`symtab.cc:1752–1771,1872–1900`).
* Used-type hashes are guarded by debug level (`function.cc:6474–6510`);
  the global variable-type map has no queued type at no-debug. Other DWARF,
  CTF/BTF, debug-argument and debug-name tables are absent. Unwind-only CFI
  uses the accepted raw/trivial records; the indirect personality pool has
  no personality/type-table input.
* Internal-label maps require UBSan/foreign frontends; OpenMP critical maps,
  transactional-memory maps, sanitizer caches and exception throw-statement
  maps require constructs/options absent from the selected roots. Input
  string-concatenation databases belong to C-family token concatenation,
  not the Ada STRING_CST route.
* Every other selected typed record in the retained census has a trivial
  destructor (scalar, pointer, fixed storage or plain `vec` fields); raw
  GGC trees/tuples/backings and explicit no-dtor allocations register none.
  The selected finalizer callbacks allocate nothing under the already
  accepted callback proof.

Thus the complete scalar registration history is <=39257+18=39275.
Allowing all prefix GGC events as possible incoming registrations remains
conservative. Prefix capacity and each intervening high-water capacity are
preserved by the same monotone heap-vector envelope; arbitrary collection
and interleaving do not require assuming all 18 objects are simultaneously
live. The ordinary backing ceiling is 8+16*58911=942584 bytes. This closes
the scalar vector input, not the outer vector/depth or collector event count.

## Export and remaining obligations

| Complete selected family endpoint | Bound |
| --- | --- |
| Identifier historical insertions |40879+3C+4D, corrected ingress included |
| Next DECL_UID |5869+5C+N+3D |
| Next type_UID |2295+6C+5D |
| Type-hash history |39257+(2D+4) |
| Large-integer hash history |39257+(164C+16D+137) |
| global_decls post-prefix pushes |D+8 |
| stmt_list_cache post-prefix pushes |265+167C+12N |
| Alias-vector history / alias ID |414861 /414860 |
| Scalar-finalizer history / allocated capacity |39275 /58911 |

For Hello: identifier history 40886 with 65536 slots, DECL_UID 5877, type_UID 2306,
type-hash history 39263 and integer-hash history 39574 with 131071 slots each,
global_decls occupancy 414860 with 1048575 slots, statement cache occupancy
432 with 1023 slots, and the alias/scalar
figures above. These are upper bounds, not measured live occupancies.
The original type/integer/global/list requests, graph 14 and RTL 4C backbones
retain their owners; this packet's new event delta is zero.

All accepted signed/unsigned index, growth, probe, allocated-capacity,
individual byte-product and allocator-order guards remain explicit. A closed
source lifetime does not assert that an arbitrary large source satisfies
those guards. The checker rejects mismatched source histories and pins and
checks the arithmetic/ownership projection. The source reachability proof
above remains handwritten and requires independent review.

Concrete remaining native joins are the selected mem_attrs changing setters
against operation/frame owners; SSA/version, instruction/label/register,
DF and emission counters at their actual reset boundaries; ordinary pools/
stacks; typed-array/outer-finalizer/depth and page-index/mark-array state;
and the disjoint total positive GGC event/per-object ledger. Frontend tables,
production invocation/source correspondence and external producer/link/storage
capacity also retain their separate obligations. No unspecified type, alias,
identifier, tree-cache or scalar-registration residual is used in this packet.
