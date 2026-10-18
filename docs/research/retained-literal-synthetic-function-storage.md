# Literal synthetic function storage

2026-10-18, Linux x86-64/LP64, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
The three non-Main synthetic function structures and the two String helpers'
initial gimplifications contribute at most **167 direct GGC allocation events**
and **8 ordinary allocation requests**. The individual caller-size ceilings
sum to 13,336 GGC bytes and 584 ordinary bytes; rounding each GGC row to a
power of two gives 17,216 slot bytes. These are lifetime request envelopes,
not peak memory, an allocator/page total or a global capacity gate.
The [callable interface and offline evidence](../evidence/retained-literal-synthetic-function-storage-20261018/README.md)
also export identities and shared-container demands. Independent review is
pending. This closes the synthetic allocation/initial-gimplification slice;
it does not close original-gigi construction or the whole literal pipeline.

## Boundary and imported inputs

Use the frozen [String layout](retained-literal-string-layout.md) and
[constructor frontier](retained-literal-warning-residual-bound.md): one empty
elaboration function, two String size helpers, and no other non-Main body.
The selected family has C >= 1 qualified direct-literal Put/Put_Line calls,
N >= 0 nulls, one `with Silver_IO;`, Main/SPARK, no declarations/use clauses,
and each literal length <= INT_MAX. Keep the retained non-LTO, O0, no-debug,
no-instrumentation/sanitizer/offload/OpenMP, checking/statistics-disabled
configuration, default x86-64 SysV target, and existing source/installed
behavior premise. GCC source is
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.

Count the three `allocate_struct_function(..., false)` calls and both helper
initial gimplifications, **starting with the frozen declarations and bodies**.
The predecessor `self_referential_size` construction (types, declarations,
parameter names, private copies, folding, calls and size-function vector) and
the empty-elaboration declaration/BIND construction remain original-gigi
charges. They are outside this packet, not zero. Also exclude the already
charged two cgraph nodes and symbol-map backing. The cgraph discard control
path comes from the frozen layout packet; the release effects of this
packet's objects are accounted below. This partition must be preserved when
adding the packet to a complete original-gigi ledger.

The empty elaboration allocates its structure at `trans.cc:5994`. Its saved
empty BIND takes `trans.cc:698–723`'s no-elaboration-code branch, with no
finalization or gimplification. Its void result has fixed metadata.
Each helper has two distinct signed-32 scalar parameters and a fixed scalar
result, u64 for bytes or u128 for bits. With L=(u64)l, U=(u64)u and a signed
comparison Q of u and l, the frozen bodies are:

```text
RETURN(MODIFY(RESULT, Q ? ((U-L)+1) : 0))
RETURN(MODIFY(RESULT, Q ? (u128((U-L)+1)*8) : 0))
```

Ordinary plus/minus reassociation, commutation, and condition inversion/arm
swapping preserve the dimensions below. The canonical arithmetic has two
widenings and two binary extent operations; the bit body adds one widening
and one multiplication. It does not introduce a duplicated bound occurrence
or an extra negation. Constant-sided subtraction is normalized by the
predecessor folder into addition with its signed constant. All saved-body
leaves are parameters, the result, or scalar constants. There is no CALL,
SAVE, BIND, constructor, cleanup, EH, volatile, aggregate or complex form.
The existing `DECL_INITIAL` BLOCK is not a child of this saved-body walk.

| Input occurrence dimension | Byte helper | Bit helper |
| --- | ---: | ---: |
| Unary nodes (including RETURN) | 3 | 4 |
| Binary nodes (including MODIFY and comparison) | 4 | 5 |
| Ternary COND | 1 | 1 |
| Whole-body ordinary occurrence weight W | 8 | 10 |
| Scalar arithmetic/conversion materializations T | <=4 | <=6 |
| Parameters / results / body conditionals | 2 / 1 / 1 | 2 / 1 / 1 |

## Structure, parameter and SSA initialization

`function.cc:4848–4920` allocates one function, calls
`init_eh_for_function`, then the machine-status hook. The
[retained fixed layouts](retained-native-expansion.md#real-function-construction-and-rtl-startup)
are function=208, eh_status=48, machine_function=320. EH initialization
adds exactly two pointer vectors with a single zero entry
(`except.cc:351–359`). Capacity starts at four, nominally 40 bytes; 64 covers
GGC-vector pre-rounding. The x86 hook allocates only its machine object
(`i386-options.cc:1991–2001`). No EH region or landing pad exists.

The function-specific option pointers select the unchanged defaults. The
x86 target/ABI remains SysV with ordinary saved-register rules, so
`ix86_set_current_function` does not create target globals, rebuild option
nodes or reinitialize registers (`i386-options.cc:3452–3580`). Alignment
flags are O2-speed defaults (`opts.cc:684–687`), unselected at O0 with no
alignment overrides; `ix86_default_align` only supplies strings when their
flags are enabled (`i386-options.cc:1868–1875`). All four strings are null.
Thus `parse_N_M` returns before its static cache construction
(`toplev.cc:1215–1282`); a cache-hit assumption is unnecessary.
The retained quiet invocation has no time report or detailed statistics,
so the accepted timer-disabled interface also applies to these timevar
push/pop calls. Dumps and debug size-function callbacks are disabled.
No callgraph stack-usage request or nondefault optimization-optabs setup is
selected. Relayout of existing scalar result/parameter declarations copies
their existing type size/alignment (`stor-layout.cc:661–813`), adding no
type, constant or expression. Void/u64/u128 results do not return in memory
on this ABI.

For each helper, `gimplify_body` initializes SSA, sets the default RTL
profile flag, and obtains one context before visiting its body
(`gimplify.cc:21745–21785`). Setting the profile is a scalar write, not RTL
initialization. Reuse the [initial SSA layout transfer](retained-native-expansion.md#null-initial-gimple-cfg-and-ssa-allocation-join):
one gimple_df <=256, one default-def hash control <=128, its 31-pointer
backing=248, and the name vector <=512 bytes. The vector reserves 50 entries
and starts with slot zero (`tree-ssanames.cc:146–166`). At most six fresh
names fit without growth. No SSA renaming pass runs; the default-def hash
stays empty, with no `.MEM`, detached NOP, operand slab, points-to bitmap or
SSA freelist growth. `init_tree_ssa` only resets both points-to solutions
(`tree-ssa.cc:1214–1220`).

`gimplify_parameters` builds one ordinary vector for its two parameters,
then releases it (`function.cc:3886–3984`). SysV scalar classification and
argument advancement use fixed automatic state and no RTL construction;
the signed-32 parameters are passed by value. This excludes the hidden
result parameter, complex splitting, callee-copy, alloca and cleanup paths.
Their type/size positions are constant, so size gimplification adds no
expression or statement.

## Unsharing, scalar lowering and folding closure

Apply the accepted [3W whole-body transfer](retained-backend-capacity.md#whole-body-copying-include-protected-children-and-declaration-metadata)
to W=8+10. This permits arbitrary incoming visited marks; it does not
assume a pristine tree. No protected identity or declaration-metadata
expression root is added. Result sizes are constants, and scalar type
links introduce no expression traversal or pointer-type deduplication
table. Charge 21 unary copies at 32 bytes, 27 binary at 40, and six ternary
at 48: **54 events, 2,040 caller bytes**. Each invocation also constructs
the ordinary deep-unshare hash set, even though it stays empty
(`gimplify.cc:1035–1052`). Its control/backing are ordinary rows below.

The [scalar materialization transfer](retained-backend-gigi.md) charges
each of T<=10 materializations one INIT_EXPR, a shallow copy of the now
scalar-operand expression, one SSA_NAME, and one GIMPLE_ASSIGN
(`gimplify.cc:680–721`). Each INIT is explicitly freed afterward. Its copy
has at most two operands. The failure-only fallback VAR constructor is
unreachable for these valid scalar operations with an assigned definition.
Widening conversions only adjust the existing expression code/type on this
path (`gimplify.cc:3362–3406`). There is no expression-result cache because
SSA materialization takes the branch before `lookup_tmp_var`.

Each nonvoid RETURN creates one unnamed return VAR_DECL. Assigning the
COND to this register distributes its assignment into the two arms
(`gimplify.cc:7002–7048`), reusing the return variable. Charge two arm-wrapper
binary trees and two arm GIMPLE_ASSIGNs per helper; no separate conditional
temporary is necessary. The direct conditional adds one condition, three
labels and one goto, with three fresh LABEL_DECLs
(`gimplify.cc:5557–5809`). The whole RETURN adds one GIMPLE_RETURN. Its
early-return predictor guard is false because the condition context has
been popped before the enclosing return is emitted. Finally `gimplify_body`
wraps the sequence in one GIMPLE_BIND. It does not revisit that new wrapper
or push a binding stack entry; `declare_vars` splices the temporary chain
without a local-declaration vector. There are at most **28 GIMPLE tuples**:
14 assignments, two conditions, six labels, two gotos, two returns and two
binds. The [tuple layout transfer](retained-backend-capacity.md#raw-gimple-tuples-use-individual-operand-arrays)
supplies their individual sizes.

Folding is a real allocation obligation. Every selected assignment and
condition reaches `maybe_fold_stmt`, then `fold_stmt` with
`no_follow_ssa_edges`, which always returns null (`gimple-fold.cc:6978–7019`).
The generated matcher's `get_def` refuses a definition when that callback
returns null (`gimple-match-head.cc:62–67`). All nested expression patterns
requiring a definition of an arithmetic SSA operand therefore fail. A
parameter is likewise an opaque declaration. This is why constructor
folding's larger request envelope must not be copied onto each GIMPLE
operation.

The remaining direct cases are exhausted by the selected roots and leaves:

| Root/candidate rules in match.pd | Selected-path disposition |
| --- | --- |
| Widening conversion; direct strip rule 5720–5726 | 32->64 and 64->128 are not useless conversions. Nested conversion/arithmetic rules cannot follow an SSA definition. |
| plus/minus identities 238,293,6037,6045 | The surviving binary operations have a nonzero constant or two distinct operands; no x-x, x+x, or zero-left subtraction. Reassociation can use 1-x; x has no Boolean range, so 2211 fails. |
| Easily negated RHS, 2145–2168,2201 | A subtraction RHS is an opaque nonconstant value; predecessor constant subtraction was already normalized. No NEGATE/MINUS definition can be followed. |
| Multiplication identities 305,500,6061; Boolean-product 2497 | The constant is eight, not zero/one/minus-one. Eight is not zero-or-one. Other operand's absent range information gives all possible bits, without constructing range state (`tree-ssanames.cc:506–571`, `fold-const.cc:16715–16795`). |
| Multiply-to-shift 1293 | Requires a visible `lshift(1,...)`, not the integer constant eight. |
| Comparison identities/constants 7367–7377,7544–7569 | Distinct full-width signed-32 parameters, neither constant nor repeated. No Boolean, pointer, floating, vector or range-narrowing case applies. |
| Other mandatory nested patterns, optional-conversion patterns, scalar copies | No nested definition is available. Removing optional conversions leaves either an excluded operand predicate/constant comparison or an unrelated root. Copies of VAR_DECL/SSA_NAME/zero have no eligible scalar-expression rewrite. |

The evidence retains a mechanically extracted inventory of flat and
optional-conversion-only simplify patterns as an audit aid. Root selection,
operator-list interpretation, matcher predicates and the exclusions above
are a handwritten source argument; that inventory is not a proof by regex.
The reachable matcher predicates inspect scalar types/values or fixed-size
wide integers; they do not create a range oracle or heap-backed scratch.
The fixed widths here fit `wide_int`'s inline storage.
For the possible `1-x` reassociation, `ssa_name_has_boolean_range` uses the
existing `global_ranges` because the fresh function has no active range
query. Its nondefault SSA name has no range information, so the query
returns varying (`value-query.h:132–135`, `value-query.cc:493–558`). The
predicate's `int_range<2>` and comparison `int_range<1>` have inline,
nonresizable pair storage (`value-range.h:380–401`, `range.h:48–54`);
neither the failed predicate nor its all-bits fallback allocates.

`gimple_resimplify1/2`'s constant-folding branches require all operation
operands constant, absent here; a single-RHS INTEGER_CST has no expression
operator for `const_unop`. Operand reordering can still succeed, but it
preserves arity and `gimple_assign_set_rhs_with_ops` mutates the existing
tuple (`gimple.cc:1969–2005`); condition reordering also mutates its tuple.
`maybe_build_generic_op` only constructs REALPART/IMAGPART/VIEW_CONVERT or
BIT_FIELD_REF nodes, none selected. No speculative replacement is built by
the failed matcher cases. The subsequent `fold_gimple_assign` does nothing
for unary/binary operations; its scalar single-RHS route cannot obtain a
constant initializer from the mutable unnamed return temporary. There is
no ternary assignment, reference, call or constructor case. Thus folding
adds **zero requests** to these rows, including discarded candidates.

## Names, counters and shared containers

Conservatively allow every one of T<=10 materializations to call
`create_tmp_var_name`. `get_name` strips conversions and can reach the
two parameter names p0/p1; arithmetic SSA results are unnamed, so the
additional bit-width conversion cannot recursively extend a prefix
(`tree.cc:12055–12082`). A miss allocates one 40-byte identifier and a
separate character array. `tmp_var_id_num` is unsigned32
(`gimple-expr.cc:417–436`); requiring incoming+10 <= UINT_MAX suffices.
Even the longest fallback private-name format in `defaults.h:38–56`,
`__%s_%lu`, fits 16 bytes including NUL for a two-character prefix and ten
digits. This deliberately covers more than the selected dotted format.
Only those character arrays are GGC requests; ASTRDUP/private formatting
use bounded automatic buffers, not ordinary heap allocations.

Export at most ten insertion-capable identifier lookups/new entries. Their
shared hash backing must be composed with its incoming population; this
packet does not invent a constant total for that table. The warning packet
already establishes zero helper warning-map puts at reserved locations.
Do not add a second warning allocation allowance.

The persistent counter contributions inside this boundary are funcdef +3,
fresh DECL_UID <=8 (two return variables, six labels), type UID +0, and
temporary-name serial <=10. The helper SSA vectors have lengths <=5/<=7
including slot zero. Each helper resets the condition UID to one and
allocates one condition ID, leaving next=2; disabled condition coverage
does not eliminate that increment, but does eliminate its mapping table.
No CFG label UID or RTL label is assigned, and no synthetic code is emitted.
The predecessor helper declaration/parameter/result UIDs, SZfnno and
symbol UID/order contributions are deliberately outside this row.

| Ordinary storage | Requests | Individual bytes | Lifetime |
| --- | ---: | ---: | --- |
| Deep-unshare hash control | 2 | 64 | Deleted after each unshare. |
| Deep-unshare 13-pointer backing | 2 | 104 | Same; no protected-node insertion or growth. |
| Gimplifier context pool extension | <=1 | 128 | Depth one, returned to the pool; second helper reuses it. |
| Two-parameter pointer vector | 2 | 40 | Initial capacity four; released after each parameter scan. |
| Global cfun stack first capacity | <=1 | 40 | Two sequential push/pop pairs; length zero on entry, peak one; backing retained. |

The context and cfun-stack rows bound possible extension of shared resources.
If the integration already charges these very allocations, deduplicate the
rows by ownership, while preserving their peak demands. There is no
bind-stack allocation: the input body contains no BIND. No temp hash,
condition map, switch/OMP/ASAN state or CFG structure is created. Every row
has its own constructor or storage-transfer derivation; the subtotal is
not a flat multiplier on a complete function pipeline.

## Release and collector interface

The two helpers remain registered through Main's initial gimplification,
then are discarded before ordinary lowering, as proved by the frozen
layout packet. `release_function_body` calls `delete_tree_ssa`, clears EH
and body references, frees each function and clears its saved tree
(`cgraph.cc:2188–2255`). There is no CFG, loop, histogram, IPA transform,
callee edge or selected LTO body state to allocate during release.
`fini_ssanames` releases its vectors. Emptying the zero-entry default-def
hash does not shrink: its capacity is 31, below the >32 shrink guard
(`hash-table.h:818,910–950`). Released tree/tuple/machine/EH objects can
become unreachable for later collection; their allocation events remain
charged, with no assumed collection time. No early reclamation is claimed
for the unused empty elaboration structure.

The [retained destructor census](retained-native-expansion.md#registration-and-destructor-effects)
gives two singleton finalizer registrations, for the two GGC hash controls,
and zero vector registrations. Other charged typed objects are trivial;
raw trees, tuples, strings and pointer vectors have no finalizers. Hash
destruction and the selected release operations allocate nothing. Export
the two registrations plus all 167 events to the shared collector/page/
finalizer transfer. That backing and ordinary allocator metadata remain
integration obligations, as do imported original-gigi construction and
complete all-phase counter/container bounds.

## Evidence and round record

The packet starts at Silver `a409ff9db1e7a290bc12dd415d0d9518c93e4652`.
Its checker validates pinned predecessor documents, retained source
identities, route landmarks, shape dimensions, individual sizes and subtotal
arithmetic. It executes no compiler and establishes no new installed-source
correspondence premise. The GIMPLE matcher helper and value-range source
are additionally compared byte-for-byte with their raw files at the retained
GCC commit; the other source pins reuse historical retained records.

Selected worker: GPT-6 Astra / Extra High. Runtime model/effort confirmation
and token/cost measurements are unavailable. This round began
2026-10-18 20:32:36 UTC. Its intended outcome is the bounded synthetic
storage/event interface; the achieved result is the numerical closure above
and offline checks. The material audit refinement was excluding nested
SSA-definition matches while still checking direct predicates and in-place
canonicalization. No native build, capture, compiler run or expensive
validation rerun was performed. No production, aggregate, GitHub or CLI
memory state is changed by this bounded packet.
