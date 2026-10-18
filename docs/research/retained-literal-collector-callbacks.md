# Literal-output collector callback effects

2026-10-18, Linux x86-64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The selected literal-output family adds **zero GGC allocation events from
collector callbacks**. Its initialized value-expression cache remains empty;
each invocation of that cache's marker still allocates one ordinary 104-byte
hash backing. No total collector call count or cumulative ordinary allocation
bound is needed for that individual request-size result.

This extends the accepted [null callback argument](retained-native-expansion.md#selected-null-collector-callback-closure)
to the [literal family](retained-literal-pipeline.md), including the two cold
String helpers and the empty elaboration function. It does not reuse the null
program's 40,098-event subtotal, page/finalizer capacities or whole-process
verdict. Complete imported construction, pass lifetimes, global counters and
collector backing still need their own bounds.

The [offline packet](../evidence/retained-literal-collector-callbacks-20261018/README.md)
reuses the frozen full-corpus census and checks the sources used for this
extension. Its checks establish input identity and interface consistency; the
effect and reachability argument below is a handwritten source argument,
pending independent review. Relevant installed behavior/source correspondence
and the selected configuration remain the existing explicit premises.

## Selected graph and configuration

The complete byte recognizer selects one `with Silver_IO;`, Main/SPARK, at
least one qualified literal Put/Put_Line call and any finite sequence of
such calls and null statements. There are no source objects, loops, branches,
renamings, nested functions or declarations. Literal lengths fit signed
32-bit Integer. The current ASCII/HT/CR/LF alphabet is checked separately
from the historical recognizer, which also accepts FF/VT.

Reuse the accepted Main lowering/selected O0 schedule and fixed-prefix
projection. Main has no parameters and returns void; its only local value
objects are fixed-size fat descriptors. Imported Put/Put_Line declarations
have IN parameters and no translated bodies in this Main process. Standard's
String/profile construction adds type/field declarations, not a variable-sized
local object. The [accepted generated-body frontier](../reviews/review-literal-warning-residual-6f3a5af341.md)
contains one empty elaboration body and two size helpers in addition to Main.
The empty elaboration is never gimplified or lowered. Each helper has two
signed-32 by-value scalar parameters and a fixed u64/u128 scalar result, and
is discarded before ordinary lowering and RTL. Initial gimplification still
counts; discard is not used to erase its effects.

Keep the selected no-debug, quiet, no-PCH/no-plugin/no-LTO, no OpenMP,
sanitizer or profiling configuration, ordinary default x86 target state and
the previously reviewed O0 pass exclusions. These are the existing invocation
premises, not new source restrictions. Other configurations need a separate
effect join. Fixed library compiler subprocesses and binder compilation are
also separate processes and are not assigned this Main cache invariant.

## The value-expression cache stays empty

`init_ttree` initializes `value_expr_for_decl` even when it has no entries
(`tree.cc:777–779`). The accepted fixed-prefix projection has no insertion.
Its possible subsequent setters are excluded as follows:

| Setter route | Selected-family reason |
| --- | --- |
| Ada debug renaming (`decl.cc:771–783`) | No source renaming or imported renamed object is translated. Standard String conversion creates types/fields. |
| Debug Out parameter (`decl.cc:1640–1657`) | Main has no parameters; imported procedures have IN parameters and no body; synthetic helper parameters are ordinary scalar parameters created by the generic size constructor. |
| Named result (`trans.cc:3539–3585`) | Main is void. The synthetic helper returns an arithmetic expression through its generic scalar result; no Ada named-return-value transformation occurs. |
| OpenMP allocation (`gimplify.cc:1475–1509`) | No selected OpenMP directive/attribute or transformation. |
| Variable-length object (`gimplify.cc:1968–1995`) | Main's descriptors have constant size; imported unconstrained String is a type/profile, not a local VLA. Helper temporaries/results are fixed scalars. |
| Callee-copy parameter (`function.cc:3900–3980`) | The setter requires `pass_by_reference` and `reference_callee_copied`. Main has no parameters and helper parameters are by-value signed scalars. External procedures are not gimplified here. |
| RTL result address (`function.cc:3774–3794`) | Only void Main reaches RTL. Helpers never reach this phase. |
| Saved static chain (`function.cc:5230–5255`) | Main is library-level with no static chain; no nested function reaches RTL. |
| Tree/body/block copies (`tree.cc:1496–1500`, `tree-inline.cc:780–796`, `tree-cfg.cc:7596–7613`) | These setters require an existing value expression and preserve the empty invariant by induction. |

The full setter inventory is reused from the accepted source census. Other
writers belong to the excluded frontends, nested-function, TLS, OpenMP,
sanitizer, LTO or named-return transformations. Increasing C, N or the literal
lengths does not enable any of those routes. A pointer-containing fat
descriptor is not a pass-by-reference parameter of Main and does not by itself
set `DECL_VALUE_EXPR`.

Consequently `gt_value_expr_mark` (`tree.cc:218–271`) constructs its local
non-lazy hash set but visits zero entries. Its 16-element inline vector never
grows, and recursive `walk_tree_1` calls never occur. The initial ordinary
hash has 13 pointer slots at eight bytes each: **104 bytes per marker call**.
It is freed on return. Cache marking adds zero GGC events, hash insertions,
dynamic vector requests or extra identifier creation. The number of actual
collections remains unspecified.

## Other markers and finalizers retain their effects

The predecessor's 4,929-source census covers 223 typed allocation sites, 149
literal type spellings and 51 GC hash descriptors. This extension does not
infer reachability from those counts. The additional selected objects belong
to the already inspected families: gigi type/declaration/binding records,
tree/GIMPLE/RTL nodes, function/EH/machine records, CFG/SSA records, graph
nodes/edges, and pointer/scalar hash maps, sets and vectors. Their generic
markers walk existing fields and bounded arrays without constructing objects.
The cold helpers add no new target, debug, LTO or plugin family.

Raw tree/GIMPLE/RTL allocations register no finalizer. Function/EH/machine
and gigi records contain scalar/pointer/fixed fields or plain vectors with
trivial destructors. The initial-SSA default-definition hash and warning map
have allocation-free destruction: pointer removal is a no-op, and
`nowarn_spec_t` holds only an unsigned bitset (`gcc-diagnostic-spec.h:29–110`).
Other selected hash descriptors inherit no-op removal; the sole enumerated
override, loop-exit removal, unlinks/frees existing objects and creates none.
During GC the explicit `ggc_free` call itself returns immediately. IPA summary
managers retain their explicit no-dtor/raw allocation route. Symbol-table and
line-map destruction only free existing ordinary backing. None of these
destructors allocates a replacement object or new backing.

Generated/custom markers, identifier purging and weak-cache clearing therefore
retain the predecessor's zero-GGC effect. Plugin/JIT dynamic roots and PCH
contexts are absent. The unchanged quiet/no-time-report selection leaves
`g_timer` null. Context depth zero excludes old-context bitmap backups.
Finalizer dispatch removes existing entries without vector growth. The
argument applies regardless of which of the selected objects become
unreachable, including the discarded size helpers.

The exported zero callback event delta can be added to a future complete
allocation ledger. It does not bound the objects allocated before collection,
the number of finalizer registrations, page indices, global identity counters,
or the individual backing requests of those structures. Those inputs remain
null in this packet. No aggregate RAM gate or language/admission change follows.
