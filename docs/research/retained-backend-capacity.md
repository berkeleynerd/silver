# Retained native backend: locations, Strings and constant pools

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This supplies local transfers to the unfinished
[capacity contract](retained-tool-capacity.md). It is not whole-backend capacity
assurance, a new membership rule or a native near-limit experiment. GCC source
is `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; the existing source/tool relation
remains an external premise. No compiler, prover or application was run.

## Whole-file native line maps

The Ada frontend's source and line tables are not the last source-location
representation. `back_end.adb:123–130` supplies one record per source file,
including virtual sources, using its maximum **logical** line number:
`Nat (Physical_To_Logical (Last_Source_Line (J), J))`. Main cannot set a source
reference pragma; selected dependency/generated files must retain their own
logical-line inventories.

Gigi creates one GCC map per supplied file, in the same order. Before each
iteration it reports an error if the map count differs from the file index
(`gcc/ada/gcc-interface/trans.cc:346–363`). For each file it calls:

```text
linemap_add(LC_ENTER, first line 1)
linemap_line_start(last logical line, column hint 252)
linemap_position_for_column(251)
linemap_add(LC_LEAVE, no parent file)
```

Ada disables packed source ranges (`gcc/ada/gcc-interface/misc.cc:376–377`).
For a fresh map, the hint selects eight column bits. The map initially has one
line, so `linemap_line_start` can enlarge it in place **only if**

```text
last_logical_line - 1 < 2^(32 - 8).
```

The 32 is the width of `linenum_type`, an unsigned int, rather than the width
of `location_t`. Thus the sufficient per-file condition is
**`1 <= last_logical_line <= 16,777,216`**. At 16,777,217 the inspected code
creates another map, breaking gigi's required file/map correspondence; the
next file's check diagnoses that discrepancy. Do not rely on there being a
next file: every map must obey the condition. This follows the explicit
map-reuse guard at `libcpp/line-map.cc:949–970`, with the types at
`libcpp/include/line-map.h:52–55,295–298`. It is a source-derived boundary for
this mapping path, not an observed native cutoff or an arbitrary source cap.
It is separate from the frontend line allocator's arithmetic condition.

Let `h` be the incoming highest GCC location, and `n_i` the positive maximum
logical line of each file. For the normal map region and empty initial map
inventory, the preallocation recurrence is

```text
s_1 = h + 1
s_(i+1) = s_i + 256*(n_i-1) + 252
highest_after_preallocation = h + sum(256*(n_i-1) + 252).
```

`LC_LEAVE` for these top-level maps returns without allocating another map
(`libcpp/line-map.cc:591–598`). The final column contributes 251 and the next
map start contributes one. Later Sloc conversion masks the supplied column
to eight bits and can add up to 255, so allow **four more location values**
than this preallocation maximum. Require that bound to stay strictly below
`LINE_MAP_MAX_LOCATION_WITH_PACKED_RANGES = 0x50000000 << 31`. This conservative
normal-region condition avoids every location-space fallback in the referenced
path; it does not assert that the much larger location space is exhausted there.
The per-file map-reuse guard remains necessary even with 64-bit `location_t`.

This transfer covers location arithmetic and the one-map-per-file invariant.
It does not establish exact source columns: the pinned mapping intentionally
masks columns. The map-vector allocator is covered below; filename storage, ad-hoc locations,
other GCC IDs and generated code still need their own accounting. Reuse the
complete physical/virtual source inventory; counting only Main misses both
fixed dependencies and virtual copies.

### Ordinary-map vector growth is covered by the file-count interface

Under the one-map-per-file condition above, let F be the number of supplied
files. The Ada/C interface passes it as Nat, so `0 <= F <= 2^31-1`;
gigi's loop variable and its checked map-count conversion fit that same range.
The map table itself uses 64-bit `line_map_uint_t`, an alias of location_t
(`libcpp/include/line-map.h:303,747–777`). Each `new_linemap` requests one
entry. Its first allocation has capacity 256; later exhaustion doubles the
capacity (`libcpp/line-map.cc:469–543`).

On the Linux LP64 structure layout, an ordinary map is 32 bytes
(`line-map.h:425–471`). The active allocator/rounding callbacks are
`ggc_realloc` and `ggc_round_alloc_size` (`gcc/toplev.cc:761–767,1141–1150`).
For these requests, rounding does not inflate the capacity: the allocation
size is already a power of two of at least 8192 bytes. GGC's rounding loop
starts at order ten, then selects the first power-of-two size that fits
(`ggc-page.cc:1292–1327,1883–1894`). The small-object extra orders do not
participate in this path.

Thus, for positive F, capacity is the least power of two at least
`max(256,F)`. It is at most `2^31`; the largest multiplication requests
`32*2^31 = 2^36` bytes. Every capacity increment/doubling, byte multiplication,
division back into entries and zero-fill size fits its 64-bit representation.
The largest executed doubling is `2*2^30`. Zero files request no map vector.
Each top-level enter/leave pair has include depth at most one. These facts
close ordinary-map backing arithmetic without a new source-count restriction;
the existing source-range argument still must supply F and ensure no extra
line map is introduced. Ad-hoc location maps, filename intern tables and all
later GCC structures are separate.

## GNAT-node association backbones

The backend receives
`N = Last_Node_Id - First_Node_Id + 1` through a signed-Int parameter
(`gcc/ada/back_end.adb:155–175`). `init_gnat_utils` allocates two N-element
arrays of GCC tree pointers: the ordinary node association and dummy-type
association (`gcc/ada/gcc-interface/utils.cc:259–280,430–450`). Each real GNAT
node ID in that supplied interval maps to index `ID-First_Node_Id`, in
`0 .. N-1`. The backend's pointed-to tree graph is additional storage;
an N-element association array does not bound how many GCC trees it creates.

`ggc_cleared_vec_alloc` multiplies the size_t element count by the element size
(`gcc/ggc.h:230–258`). With eight-byte pointers and `N <= 2^31-1`, each array
requests at most **17,179,869,176 bytes** and GGC rounds it to at most `2^34`
bytes. Both multiplication and rounding are representable. Charge two such
backbones; the independent packable/padded/sized type hash maps initialized
beside them are not covered by that charge. This is allocation and valid-index
arithmetic under the frontend node inventory, not a global RAM gate or closure
of every backend lookup caller.

## Character String materialization

For ordinary Character data, `trans.cc:6705–6731` copies an `L`-byte Stringt
value into an `L`-byte temporary and creates one `STRING_CST`. Lengths below
1000 use `alloca`; larger lengths use an allocated buffer freed after the
constructor. Wide-character aggregate lowering is a different branch and is
not selected for Standard String. This is a transfer per actual lowering
event; it does not establish the event count from source occurrences.

`build_string` takes unsigned length, allocates `L + H + 1` bytes, stores `L`
in an int field, and appends one NUL (`gcc/tree.cc:2616–2636`). Here
`H = offsetof(tree_string, str)` is fixed by the selected host ABI. Under the
ordinary Linux LP64 GCC layout, `tree_base` is eight bytes, `tree_typed` is
sixteen, and `H=20`; the int length precedes the character tail
(`gcc/tree-core.h:1138–1253,1565–1595`). The ABI and normal compiler structure
layout are explicit premises; this record does not measure an installed binary
layout.

Consequently this event retains one tree node with **`L+21` requested bytes**
and temporarily needs another `L` bytes. For lowering lengths `L_1 .. L_t`,
cumulative requested String-node bytes are at most `sum(L_i)+21*t`; charge
temporary buffers separately and retain the cumulative allocation bound when
reclamation is not justified. Allocator metadata, type trees, RTL and other
backend objects are additional. At `L=2^31-1`, the constructor requests
2,147,483,668 bytes, which fits its unsigned 32-bit quantity, while its stored
length still fits int. This local arithmetic does not make that value admissible:
frontend and producer bounds can bind earlier.

### Ordinary Main literal lowering events

For the current Main grammar, count the ordinary Character String literal
identities in the **expanded** frontend tree, including copies and folded
results, as `N_lit`. Let `W_lit` be their length sum. This is not the number
of lexical literals: the [native expansion transfer](retained-native-expansion.md)
must supply these counts, or conservatively its total Main node bound `A_Main`
and maximum ordinary String length `L_max`. Under that normalized-tree
interface, the gigi materialization contribution is

```text
literal lowering events <= 2 N_lit <= 2 A_Main
lowered payload bytes   <= 2 W_lit <= 2 A_Main L_max
STRING_CST requests     <= 2 W_lit + 42 N_lit.
```

The last row counts requested bytes, using the `L+21` constructor above.
No constant-pool sharing credit is used. Two is a traversal bound, not an
empirical allocation multiplier: one ordinary definition/executable traversal
and, conservatively, one lazy entity-initializer traversal before association.

Ordinary statement lists visit each member once (`trans.cc:5688–5691,9298–9305`).
Assignments choose either the function-call path or one RHS traversal
(`:7756–7821`); calls translate each actual once, then reuse the resulting
GCC tree for addressability, copies and conversions (`:4911–5015`). String
comparison translates its two operands once (`:7415–7470`), slices translate
their prefix once (`:7086–7116`), conversions translate their operand once
(`:7291–7342`), and conditionals/actions visit each child once
(`:7605–7616,7944–7974,8603–8622`). Both branch arms count. A runtime loop
does not repeat this frontend-to-GCC traversal for every iteration.

The two-pass declaration driver visits ordinary object/renaming declarations
only in its first pass; its second pass selects deferred bodies and nested
package/freeze lists (`trans.cc:9889–10025`). Loop-body conversion likewise
occurs once (`:3301–3306`). Object declarations translate the initializer once
before defining its entity
(`:6779–6881`). An as-yet-unassociated constant or renaming can additionally
translate its initializer through `gnat_to_gnu_external`
(`decl.cc:697–718,754–766`; `trans.cc:8968–8996`). The entity association then
prevents another lazy visit (`decl.cc:400–445`). The external-expression
wrapper's `gnat_zaplevel` discards binding blocks without clearing associations
(`utils.cc:770–783`); the object-association reset at `decl.cc:1278–1291`
requires an excluded address clause. An ordinary String reference
calls that cached entity conversion; using a constant value returns its existing
`DECL_INITIAL`, without revisiting Ada source (`trans.cc:1201–1289,1330–1369`).
The separate initializer-replay branch requires an **elementary** constant
with an address clause, excluded for these String objects. Deferred object
freezing likewise retains the already translated initializer at its declaration
instead of replaying it (`:6866–6881`). Main has ordered declarations, no
deferred constants, address clauses, user renamings or frontend inlining;
generated concat result renamings refer to existing result storage.

Type elaboration does not create another route to an ordinary String payload.
String-literal subtype lowering reads only its scalar low bound and length
(`decl.cc:3142–3177`). The native normalization argument makes literal
First/Last/Length queries scalar constants; normalized Image/input views refer
to captured objects. Ordinary aliases do not replay their initializer trees.
Actual cloned expression trees have distinct identities and are charged in
`N_lit`; multiple uses of a GCC tree after conversion are not new calls of the
Ada literal constructor. This separates source-language nesting and copies
from runtime trip counts and later GCC sharing.

This closes the gigi ordinary-Main-payload event count against the expanded
frontend interface. It does **not** bound subsequent GCC tree copying,
constant-pool requests, named object storage, generated diagnostic/filename
Strings, imported/fixed-unit payloads or total emitted code/data. Their separate
costs cannot be replaced by `N_lit`. The optional `2 A_Main L_max` envelope is
deliberately coarse; weighted literal/copy accounting can retain more useful
programs when composing the rule.

Independent source review of this local traversal argument found no correction;
it checked the cache/reset frontier and each named ordinary child traversal.
The complete native normalized-tree/source bound and the excluded later phases
remain separate composition obligations.

## Selected emission options close the extra-NUL path

The earlier [deferred-storage investigation](frontend-deferred-storage-feasibility.md#gcc-still-materializes-the-final-value)
left an option-dependent String-emission narrowing open. `output_constant`
adds a NUL when emitting nonterminated data to a mergeable String section,
then passes the size to `assemble_string(int)` (`gcc/varasm.cc:5627–5635`).
At the signed-int endpoint the extra byte would not fit that parameter.

For the selected native **O0** invocation with no merge override, ordinary
String constants do not take that branch. The optimization-default table enables
`-fmerge-constants` at O1 and above; its default handler explicitly selects the
negative form at O0 (`gcc/opts.cc:470–560,602`). The apparent `Init(1)` in
`common.opt:2414–2420` is therefore not the final effective O0 setting. The
x86 default table and Ada option overrides do not re-enable it. The section
selector requires `flag_merge_constants` (`gcc/varasm.cc:870–920`); variable
and constant emission derive their `merge_strings` argument from the actual
section flags (`:2665–2667,3953–3965`). Ordinary object-block emission passes
false (`:8524`). Main has no section or optimization pragma/aspect.

Under those configuration premises, this path sends exactly `L`, without an
emission-only terminator, to `assemble_string`. Its chunk loop uses at most
2000 bytes per call, or 16384 when base64 support is enabled; in either case
`pos + thissize <= L <= int_max` (`:2304–2335`). At most `ceil(L/2000)` callback
invocations is a sufficient count, zero for an empty value. The constructor's
private NUL remains allocated but is not emitted by this path. This closes
that **specific** option/path obligation without changing the build flags.
Other constant kinds, padding, type sizes, assembler text, objects and relocations
are not covered merely by this String payload transfer.

## Constant pools: entries, requests and labels are different costs

The ordinary tree-constant pool shares equal String constants even when O0
disables mergeable String **sections**. `add_constant_to_table` always hashes
the value and reuses an existing descriptor (`varasm.cc:3804–3842`). String
equality requires equal machine mode, type byte size, byte length and contents
(`:3537–3553`). There is no `flag_merge_constants` guard around this lookup.
This is sharing within that pool; named object storage, different type sizes
and separately compiled units remain separate. Nor does it prevent a caller
from constructing a fresh `STRING_CST` before finding an existing descriptor.

Use four cumulative event counts per native compilation process:

```text
C_tree   fresh tree-constant descriptors
C_rtl    fresh RTL-constant descriptors, across function and shared pools
C_space  assemble_static_space calls
C_part   assemble_start_function calls with has_bb_partition
C_label = C_tree + C_rtl + C_space + C_part.
```

These are counts across allocation lifetimes, including entries recreated after
reclamation. Final live cardinalities alone are insufficient. The file-local
signed-int `const_labelno` is initialized to zero and increments at exactly
these four sites (`varasm.cc:84,2085,2984,3733,4252,9077`). Consequently
**`C_label <= 2^31-1`** covers every executed increment, and each label uses a
number at most `C_label-1`. The endpoint is constrained by the final increment,
not just the largest label printed. The separate anchor counter is outside
this result; source-to-event counts and target-option exclusions remain to be
supplied by the whole backend analysis.

Under the selected ELF internal-label macro (`config/elfos.h:114–132`), a label
occupies `2 + prefix_length + decimal_digits(number) + 1` bytes including its
NUL. At the counter endpoint, LF and LC need at most 15 bytes and the longest
hot/cold prefix needs 19. These fit the actual 17-byte static-space buffer,
100-byte partition buffer and 256-byte constant buffers. This statement assumes
that target macro remains effective; it is not a bound on arbitrary user or
assembler symbol names.

### Deferred requests cannot be charged only to distinct constants

`output_constant_def` calls `maybe_output_constant_def_contents` even on a
descriptor-cache hit. If the value is not already emitted, deferral is allowed
and a function is current, it increments that function's counter
(`varasm.cc:3855–3889`). Repeated requests for one still-deferred constant can
therefore increment it repeatedly. In contrast, `tree_output_constant_def`
does not make this call; it finalizes the associated variable. Do not merge
these request classes merely because they share the descriptor table.

The counter is **unsigned int**, not signed int (`function.h:162–169`). It
starts at zero for each function; its other mutation is a decrement when a
referenced, not-yet-emitted tree constant is output while scanning RTL
(`varasm.cc:4161–4167,4495–4523`). Its only control use in this file is the zero
test which can skip constant-pool scanning (`:4564`). Let `I_f` and `E_f` bound
all increment and decrement events respectively in function f. The sufficient
local condition

```text
I_f <= 2^32-1 and E_f <= 2^32-1
```

preserves that zero test: every mathematical prefix balance is strictly between
`-2^32` and `2^32`, and its unsigned residue is zero exactly when the balance
is zero. This argument neither assumes a nonnegative balance without proving
it nor treats defined unsigned wrap as signed overflow. The ordinary functional
invariant that the counter covers pending referenced constants is separate.
Most importantly, `I_f` needs a **request** bound; `C_tree` alone cannot supply
it. The checker records the two mutation sites, not a source-derived `I_f`.

### Hash backing and probe arithmetic

Both constant pools use GCC's `hash_table`, with initial requests 1009 and 31
(`varasm.cc:4154,6963`). These use GCC's prime table in `hash-table.cc`, not
the Ada-container prime table used by the producer. The prime-table lookup
rounds up to the first entry at least as large as its request.

For these tables, or another instance with the same operation restrictions,
let D bound live entries at every point. Assume initial capacity requests are
at most `2^31-1` and no independent larger reservation is made. A sufficient
local condition is **`D <= 1,073,741,823`**. On growth or tombstone cleanup,
`expand` either keeps the old capacity or requests the first prime at least
`2*live_entries` (`hash-table.h:833–895`). Thus every backing capacity p is
at most the prime **2,147,483,647**. The `size_t` capacity, occupancy, deletion,
doubling and load-factor intermediates fit LP64. Tombstones are counted in
the pre-insertion load test and removed on rehash; they do not require a
separate lifetime-append-sized backing vector.

The probe index and secondary step are 32-bit `hashval_t`
(`include/hashtab.h:41–42`). They are at most `p-1` and `p-2`, respectively.
Their sum is at most `2p-3 <= 2^32-1`; one conditional subtraction returns it
to `0 .. p-1` (`hash-table.h:788–812,1051–1082`). Keeping the rounded prime in
this region is therefore stronger than merely fitting the nominal 32-bit
hash/index type. The next prime, 4,294,967,291, would not have this no-wrap
probe argument. This is a sufficient region, not an observed failure threshold.

`too_empty_p` takes unsigned int and computes `elts*8`
(`hash-table.h:818–821`). Above 536,870,911 that multiplication is modular.
It only chooses whether to rebuild using the same bounded `2*live_entries`
request; either result preserves the capacity/probe argument just given.
Requiring this heuristic multiplication to equal mathematical multiplication
would unnecessarily halve the sufficient live-entry region. Its input still
fits unsigned int under D. Search/collision statistics are likewise modular
diagnostic counters and are not allocation indexes. No restriction on those
statistics is needed for this storage result.

Pointer-valued pool entries request at most **17,179,869,176 bytes** per
backbone; GGC rounds that request to at most `2^34`, as in the association-array
argument above. Old and new backbones coexist during rehash; their aggregate
RAM is not a new language gate. Descriptor and referenced-tree payloads remain
additional. Constructors or explicit reservations outside the stated operation
family require their own request bound; this does not cover every GCC map.

### RTL pool offsets

For each fresh RTL descriptor i, let `a_i` be its positive power-of-two
alignment in bytes and `s_i` its fixed mode size in bytes. `force_const_mem`
adds `a_i-1`, applies an alignment mask, then adds `s_i`
(`varasm.cc:4184–4248`). Its HOST_WIDE_INT offset is signed 64-bit here
(`:4001–4038`), but **the mask is only 32 bits**. The local `align` is
unsigned int, and genmodes emits BITS_PER_UNIT as a plain decimal int literal
(`genmodes.cc:828–845,1021`). Consequently the division, subtraction and
bitwise complement in `~ ((align / BITS_PER_UNIT) - 1)` are unsigned-int
operations. When combined with the signed 64-bit offset, that mask is
zero-extended, so it also clears any offset bits above bit 31.

A signed-64-bit sum condition alone is therefore insufficient to preserve the
intended offsets. For example, an incoming offset of `2^32` with an 8-byte
alignment produces zero after the mask, although mathematical alignment
produces `2^32`; both the incoming value and subsequent 8-byte size addition
fit signed 64-bit arithmetic. This is a local arithmetic counterexample,
not a claim that an admitted current program reaches that offset.

A sufficient condition per pool is

```text
sum_i (a_i - 1 + s_i) <= 2^32 - 1.
```

Starting at zero, the positive sum bounds each addition **before** masking
and each final offset. Every pre-mask value therefore has no significant bit
above bit 31, so the zero-extended unsigned mask computes the intended
power-of-two alignment; it can only decrease that intermediate value. All
these values also fit the signed 64-bit offset. Recomputing offsets for the
marked subset repeats the same operations from zero (`:4476–4490`), so its
smaller positive sum has the same property. This is a sufficient simple
region; it does not claim that every larger pool fails. Duplicate
lookups return a copied RTL reference before this allocation/offset path;
they are not fresh descriptors. Actual allowed modes, alignments, descriptor
counts and RTL-copy multiplicities must still come from source lowering and
the selected target. The recurrence is not an aggregate emitted-code bound.

## Ordinary GCC vector allocation

GCC's ordinary `vec` has a **31-bit capacity field**, despite its 32-bit
unsigned length (`gcc/vec.h:220–260`). Heap and garbage-collected vectors
have different capacity transfers. This component covers their ordinary
reserve operations with element alignment at most eight bytes on LP64; such
vectors have an eight-byte header. Specialized embedded/automatic storage,
other alignments and caller-specific size arithmetic require their own bounds.
Let D bound every requested total `length + reserve`, including explicit
reservations, not merely the eventual live length. Require ordinary reservation
preconditions, including growth only when the requested total exceeds capacity.

For **heap vectors**, `D<=2^31-1` suffices for the capacity field. Exact
reservation returns D; an empty inexact reservation returns `max(4,D)`;
otherwise the helper doubles capacities below sixteen or computes
`old_capacity*3/2`, then takes the maximum with D
(`vec.cc:150–169`, `vec.h:302–325`). The multiplication is unsigned and may
wrap. Its result after division is still at most `2^31-1`, and the subsequent
maximum preserves the requested capacity. Thus that particular wrap does not
invalidate storage; requiring mathematical multiplication throughout would
unnecessarily restrict this helper. The requested allocation is
`8 + capacity*sizeof(T)`, using size_t (`vec.h:1394–1415`). Its product and
sum must separately fit size_t for the actual T.

For **GC vectors**, allocator rounding is copied back into that 31-bit field
(`vec.h:393–425`). Checking only D misses this second capacity change.
For element size e and the eight-byte header, choose

```text
S = largest power of two <= 8 + e*(2^31-1)
C = floor((S-8)/e)
D_gc = floor(2*C/3) + 1.
```

Assume S is in `1024 .. 2^63`, C>=16, and every requested total is at most
D_gc. Initially reserve's raw capacity is at most `max(4,D_gc)<=C`.
At a later actual growth, old capacity is less than the requested total, so
`old<=D_gc-1`. Hence the mathematical `floor(3*old/2)<=C`; any modular
multiplication result is no larger. Exact requests also fit C. Each raw byte
request is consequently at most S, and the reviewed GGC rounding returns at
most S. Recovered capacity is at most C and fits the 31-bit field, closing
the induction. Requests below 512 use the small-object lookup table, whose
selected sizes are at most 512; requests from 512 through 1024 select 1024.
Both fit S. The S condition also keeps
the power-of-two search within the initialized 64-bit object-size table
(`ggc-page.cc:1292–1327,1883–1894`).

This is a general sufficient region, not the sharp threshold for every element
size or append sequence. For e=4 it gives `D_gc=1,431,655,765`; for e=8 or 16,
`1,431,655,765`; for e=24, `954,437,177`. For example, an exact request of
`2^31-1` four-byte elements needs `2^33+4` bytes; rounding to `2^34` yields
`2^32-2` elements and then truncates the capacity field. That arithmetic
counterexample explains why the nominal length limit alone is insufficient.
It is not a near-limit native experiment. An actual construct's element count,
T and reservation multiplicities remain composition inputs. Coexisting old/new
arrays and cumulative allocations are physical costs, not aggregate RAM gates.

## Pseudo-register numbering and its two backing arrays

The selected x86 target defines FIRST_PSEUDO_REG=92
(`config/i386/i386.md:511`), and LAST_VIRTUAL_REGISTER adds five
(`rtl.h:4091–4146`). Each function starts with next pseudo-register number 98
and backing capacity 198 (`emit-rtl.cc:5980–6005`). A fresh pseudo is assigned
the current number and increments it; the ordinary source path's sole writer
is `gen_reg_rtx` (`:1184–1232`). The alternative number-setting caller belongs
to the RTL text reader, absent from Ada compilation. These are allocation
events, including registers later discarded; current live registers do not
suffice. A complex-mode recursive request must count each allocated part.

The grower doubles a signed-int capacity until the index fits
(`:1239–1262`). The largest capacity in its exact sequence that fits int is
`198*2^23 = 1,660,944,384`; the next doubling overflows signed int. Therefore,
for R fresh pseudo-register allocations in one function,

```text
98 + R <= 1,660,944,384
```

is sufficient for the number and backbone-growth arithmetic. The final
increment can equal the capacity because the last written index is one less;
another allocation would require the excluded doubling. The byte-alignment
array requests at most 1,660,944,384 bytes and the pointer array at most
13,287,555,072 bytes; products, copying/zero-fill lengths and GGC rounding fit
LP64. This is separate from the register allocator's other structures, RTL
instruction IDs and the source-to-R transfer.

## Two constant-label event classes are absent at selected O0

For the selected native configuration, the earlier label formula simplifies to
`C_label=C_tree+C_rtl`. `C_space=0`: the sole call of assemble_static_space is
inside `PCC_STATIC_STRUCT_RETURN` (`function.cc:5133–5144`), absent from the
selected x86/Linux target headers. This is a build-configuration premise;
changing the target/header configuration requires rechecking it.

`C_part=0`: fresh RTL function state has no partition flag. The only assignment
of true is the partition pass, gated by positive optimization
(`bb-reorder.cc:2977–3011`). Its other writer, insert_section_boundary_note,
returns immediately if the flag is false (`:2616–2641`). The block-reordering
pass also requires positive optimization (`:2665–2672`). No native LTO or RTL
text input is selected. A full pinned GCC non-tests source search found only
the named call and two flag writers; the source and installed target-header
inventories are retained with this component. This exclusion does not bound
C_tree or C_rtl, or imply that every optimization/transformation is disabled
at O0.

## Bulk String movement: local expansion transfers

Bulk movement is not necessarily expanded once per byte. The selected compiler
reports `-march=x86-64`, `-mtune=generic`, and no inline-string-operation
override in the retained `-Q --help=target` query. This query compiles no
program. The application configuration supplies the same defaults; an
environment or option override requires rechecking this transfer.

For an ordinary `emit_block_move_hints` request, with the epilogue-only
`by_pieces_in_use` flag clear, the piecewise selection test requires
`by_pieces_ninsns < MOVE_RATIO`. The generic target's ratio is 17 when
speed-oriented and 3 otherwise (`x86-tune-costs.h:4212–4213`,
`i386.h:1957`, `targhooks.cc:2156–2220`, `i386.cc:11583–11594`).
Do not infer the size-oriented case merely from O0. The bound 17 covers both.
Every piece has at most 64 bytes even across the wider x86 configurations;
the selected non-AVX configuration has a smaller maximum. `MOVE_MAX_PIECES`
defaults to `MOVE_MAX` (`defaults.h:977–986`) with no selected x86 override.
The estimator
covers the input length with positive-sized pieces and may round it up for
overlap (`expr.cc:1122–1176`). Thus piecewise selection implies
**`L<=16*64=1024`**. This is a bound on this expansion path's input, not an
admission cap or an exact count of its emitted machine instructions. Other
paths handle larger L. With `L<=Integer'Last`, the estimator's 64-bit length,
round-up and piece-count arithmetic is also representable.

In particular, both x86 `cpymem` and `movmem` expanders return false when a
known positive length is above `2^30`, before address-register construction
or algorithm expansion (`i386-expand.cc:9510–9586,10453–10506`). This is a
**fallback boundary**, not a compiler rejection. For a normal, nonoverlapping
block copy in generic address space, with inline-string overrides absent,
`emit_block_move_hints` then calls `emit_block_copy_via_libcall` once
(`expr.cc:2024–2154`). Its wrapper selects `BUILT_IN_MEMCPY`; the implementation
forms one three-argument call and calls `expand_call` once
(`expr.h:85–99`, `expr.cc:2540–2579`). No payload-sized compile-time loop is
introduced by that wrapper. Selected machine patterns exist for SI and DI
only, so the pattern-selection loop makes at most two attempts
(`expr.cc:2237–2329`, `i386.md:25924–25962`). Their failed temporary operand
construction still requires its ordinary RTL allocation charge.

The result is useful for composing larger value ranges: **no 1-GiB String
restriction follows from this early return**. At most two pattern attempts
and one fixed-arity call replace the large normal copy at this layer.
This claim does not cover `BLOCK_OP_NO_LIBCALL`, call-parameter copies,
overlapping-copy fallback, or arbitrary addressing spaces; each has its own
caller and transfer. It also does not bound the internal work of `expand_call`
or the runtime execution cost of memcpy.

### Overlapping-move template, independent of runtime length

The separately selected `ix86_expand_movmem` template has a finite expansion
bound independent of the runtime copy length. Its fully unrolled branch uses
at most eight full registers and one tail register. Its other loops run over
fixed groups of two, four or eight registers; the forward/backward copying
loops are emitted runtime loops, not repeated compiler execution. The small
tail dispatch has five fixed size bands plus the single-byte case
(`i386-expand.cc:10010–10715`).

Sum both alternatives conservatively, counting even mutually exclusive
branches. Expanding just the six named movmem helpers gives this per-invocation
interface to the ordinary RTL helpers:

| Primitive request | Upper bound |
| --- | ---: |
| Explicit `gen_reg_rtx` | 53 |
| `emit_move_insn` | 111 |
| `gen_label_rtx` / `emit_label`, each | 14 |
| `emit_cmp_and_jump_insns` | 14 |
| `emit_jump_insn` / `emit_barrier`, each | 17 |
| `expand_simple_binop` | 8 |
| `change_address` | 28 |
| `offset_address` | 98 |
| `adjust_address` | 2 |
| `ix86_copy_addr_to_reg` | 2 |

The helper subtotal for explicit pseudos/move requests is respectively
`(9,18)` for the initial unroll; `(14,28)` for the outer groups 2/8/4;
`(10,20)` for the five two-register tail groups; `(8,8)` for the two
four-register loads; `(0,8)` for their stores; and `(8,16)` for the two
four-register loop bodies. The caller and small-tail dispatcher add `(4,13)`.
All counted compiler loops have these fixed positive bounds. The checker
reconciles the loop-free callers' direct sites and the handwritten helper
subtotals against the complete pinned file.

These are **primitive request counts**, not a transitive bound on all RTL
objects, pseudo-register allocations or final instruction bytes. The named
primitives may allocate further objects; mode/address conversion, instruction
recognition and later passes remain composition obligations. Multiply the
interface by actual invocations, including failed speculative attempts. This
closes a length-dependent expansion concern without substituting an observed
instruction count or an unexplained whole-backend multiplier.

## O0 cleanup lowering: no recursive body duplication

The [gigi bridge](retained-backend-gigi.md) separates ordinary normalized Main
work from its binding scopes and cleanup actions. The selected Linux invocation
has no OpenMP/OpenACC, sanitizer, transactional-memory or C++ cleanup hooks.
Gigi contributes at most one Main finalizer-call cleanup. Gimplification can
also add one cleanup per retained BIND, containing one clobber for each eligible
memory variable and at most one stack_restore. Fixed-size memory locals can
therefore create cleanups too; dynamic String storage is not the only source
(`gimplify.cc:1699–1830`). A stack-save/restore pair adds two GIMPLE calls and
one pointer temporary (`:1270–1282`). These are constructor transfers; the
number of eligible variables and BINDs comes from the bridge.

Cleanup **bodies** in this frontier contain no nested try, label, BIND, return,
or outgoing goto. This does not bound the nesting depth of protected bodies.
At O0, `decide_copy_try_finally` permits duplication only of debug statements,
clobbers and stack_restore; an ordinary finalizer call selects the switch route
when there is more than one destination (`tree-eh.cc:1633–1675`). Ada retains
the null `eh_protect_cleanup_actions` language hook (`langhooks-def.h:152`),
so that hook adds no extra cleanup copies. The earlier double-finally
refactoring needs a TRY_CATCH inside a cleanup and cannot apply to this frontier
(`tree-eh.cc:3318–3349`). Thus nested scopes do **not** recursively multiply the
protected source body at this phase.

### Include the generated procedure return

Absence of a source return is insufficient to set all outgoing-edge counts to
zero. GNAT appends an implicit return to Main's statement list. It lies inside
Main's finalizer cleanup and can also lie inside the outer function-BIND
cleanup. The bridge records its frontend placement. Before EH lowering,
`pass_lower_cf` replaces it by a goto to a shared return label emitted after
the complete function body (`passes.def:35–41`,
`gimple-low.cc:122–214,1178–1223`). The original return is reused after that
label. This costs one goto, one GIMPLE label and one label declaration; it
does not create another return. The same rule applies independently in the
generated finalizer function.

Consequently, at the input of EH lowering, a cleanup enclosing Main's implicit
return can have **one queued goto and one distinct outward destination**.
The GIMPLE_RETURN itself is outside those cleanups, so `may_return` is false
there. Inner expression/loop scopes do not contain the appended return.
Generated loop tests and their exits remain within their containing scopes;
the source has no return/exit/goto/handler. The bridge supplies this control
frontier. The formulas below keep queued occurrences and destinations explicit,
so the arithmetic does not depend on mistaking a source restriction for the
absence of compiler-generated transfers.

### Local allocation counts

For one cleanup, let C count its simple cleanup statements, Q its queued
outward goto occurrences, D their distinct destinations, F its possible
fallthrough (0 or 1), and E its possible exception continuation (0 or 1).
There is no EH_ELSE or return inside this phase's protected region. Then
`ndests=D+F+E`. Q counts occurrences, not distinct labels.

On the **copy route**, each destination gets one copy of the simple cleanup.
The original C statements remain part of lifetime allocation accounting, even
when detached. `gimple_seq_copy` allocates one GIMPLE statement per original
simple statement, and these have no GIMPLE substatements
(`gimple.cc:1563–1577,2045–2333`). The copy wrapper finds no local label or BIND;
its variable remapping reuses existing declarations rather than generating a
new variable per operand (`tree-inline.cc:5861–5940,6008–6060`). Operand-tree
unsharing is still charged separately.

Counting both feasible continuation flags conservatively gives

```text
cloned cleanup statements <= (D+2)C
other new GIMPLE statements <= 2Q+D+4
new artificial labels <= D+2.
```

The exact control count is `2Q+D+2F+2E`: each queued goto creates its
continuation goto and redirection goto; each distinct destination creates a
label; fallthrough adds a branch and final label; exception continuation adds
a landing-pad label and RESX. Reusing the continuation goto in its destination
block does not allocate it again (`tree-eh.cc:830–877,1289–1409,1780–1788`).
Cases with zero or one destination use simpler paths and fit these same
allowances, without requiring a copy of the original cleanup.

On the **switch route**, the cleanup body is retained once, without cloning.
The construction at `tree-eh.cc:1419–1623` has these upper bounds:

| New item | Bound |
| --- | ---: |
| GIMPLE statements | `11+3Q+D` |
| Integer temporary | 1 |
| Artificial labels | `5+D` |
| CASE_LABEL nodes / case-vector entries | `2+D` |
| Integer-constant construction requests | `4+Q+D` |
| Continuation-map entries | `D` |

The exact statement count is `2+4F+5E+3Q+D`: the common finally label/switch;
fallthrough assignment, case label, branch and final label; exception landing
label, assignment, branch, case label and RESX; three allocations per queued
goto (assignment and two gotos); and one label per distinct destination.
Constant construction requests are counted even if GCC interns the result.
The new temporary's ordinary declaration/helper allocations are separate.
Single-destination and unreachable-cleanup paths fit the same conservative
allowance. The Main finalizer call is not declared noreturn; even if a future
analysis recognizes a nonfallthrough cleanup, its simpler branch redirection
also fits the control allowance.

For the bridge's `Q,D<=1`, a simple BIND cleanup therefore contributes at most
**3C+7** new GIMPLE statements and three labels; a finalizer-call cleanup at
most **15** new statements, one temporary, six labels, three case nodes and
six constant requests. For inner scopes with `Q=D=0`, use the sharper
**2C+4** and two labels. Each goto queue with at most one entry allocates its
initial capacity of 32 records and never doubles (`tree-eh.cc:618–655`).
These local fixed-size queues are not an aggregate memory gate. Each cleanup
creates at most one EH region and one landing pad. Multiple scopes are summed,
including both scopes around Main's return; they are not limited to a fixed
nesting depth.

The checker enumerates the Boolean continuation cases and checks these sums
against the separately stated formulas. It checks the pass order, copy gate,
null Ada hook, and complete source identities. The manual source argument
supplies the reachable frontier; enumeration is not a proof of GCC. Remaining
tree operands, EH maps, CFG construction, RTL expansion and instruction/data
sizes remain explicit composition work.

## EH output to initial control-flow graph

Let S count the flat GIMPLE statements after the preceding CF/EH transfers,
including labels and all retained cleanup copies. Let K be the sum of switch
label-vector lengths, including default labels. These are phase-output counts,
not source statement counts. For Main and its finalizer the bridge excludes
computed/nonlocal gotos and setjmp-like calls; their `has_nonlocal_label` and
`calls_setjmp` flags remain false. Consequently
`call_can_make_abnormal_goto` returns false (`tree-cfg.cc:2633–2666`). This
excludes the extra dispatcher blocks and abnormal-call assignment inserted by
`make_blocks_1` and `make_edges`; exception edges are still included.

`make_blocks_1` creates at most one block per visited statement and creates no
new statement in this frontier (`tree-cfg.cc:488–555`). The empty sequence
gets one empty block. With `B=max(1,S)` the initial construction therefore has

```text
ordinary blocks <= B
all blocks including entry/exit <= B+2
edge allocation requests <= 1+2B+K
label-map entries <= S.
```

Entry adds one edge. A condition adds two; a call or control-altering assignment
adds at most one EH edge and one fallthrough; a return, direct goto or RESX
adds at most one; and a switch adds one request per label. `make_eh_edge`
targets the single nearest landing pad (`tree-eh.cc:2333–2356`). The K term
deliberately adds switch destinations on top of the generic two-per-block
allowance. Duplicate source/destination requests reuse an existing edge
(`cfg.cc:278–342`). At most three labels per cleanup switch gives the alternate
bound `1+3B`; use the smaller of the two. The direct-goto statement removed
while connecting an edge remains counted in S for lifetime allocation.

Block/edge counts, block indices and label UIDs are signed int (`cfg.h:38–57`).
Block and label backbones begin with 20 entries; each edge also appends one
pointer to its source-successor and destination-predecessor GC vectors
(`tree-cfg.cc:145–164,631–666`, `cfg.cc:214–231`). The existing e=8 GC-vector
transfer applies. Requiring

```text
max(20, B+2, S, min(1+2B+K,1+3B)) <= 1,431,655,765
```

suffices for these initial integer counters, increments and pointer-vector
growth. The label map increments its UID only for a previously unnumbered
label (`gimple.cc:1901–1931`). This is a local sufficient inequality, not the
final source predicate: later block splitting, SSA/RTL transformations and
their lifetime allocations need subsequent transfers.

Initial dead-label cleanup selects and removes existing labels; it allocates
one temporary `label_record` array of B+2 entries, frees it, and is called twice
(`tree-cfg.cc:1507–1698`). Its loops do not add GIMPLE statements or blocks.
Case grouping edits/removes existing case nodes and cannot increase K
(`:1710–1852`). Label-record byte size and ordinary allocator behavior are
separate from this cardinality argument.

The same routine then assigns location discriminators. This is performed even
at O0. There are no PHIs yet, so it makes at most `S+E_graph` discriminator
requests, where `E_graph` is the edge bound above. Its unsigned `bb_id` is
incremented at most once per call, twice per block, and once per outgoing edge;
`S+2B+E_graph <= 2^32-1` suffices for that counter. Each line's discriminator
is incremented at most once per request; `S+E_graph <= Integer'Last` also
keeps the subsequent signed-int parameter conversion representable
(`tree-cfg.cc:1085–1187`, `input.cc:1048–1059`). The line-keyed hash map has at
most S+E_graph entries and uses the preceding ordinary GCC hash transfer.
Each nonzero discriminator can request one ad-hoc location. Add this to all
earlier gigi/GIMPLE location requests: it does not replace the ordinary source
line-map charge. Complete ad-hoc-location backing/hash growth remains part of
the remaining location composition.

This reaches the end of `build_gimple_cfg`, before `execute_build_cfg` invokes
CFG cleanup and loop discovery. It does not claim the whole CFG pass, later
SSA construction, machine expansion, instruction encoding or linker layout.
The formulas carry the EH output forward without multiplying cleanup nesting
or mistaking runtime iterations for repeated compiler traversal.

## Remaining backend closure

The [ELF linker transfer](retained-linker-capacity.md) supplies the separate
32-bit String-name offset, signed name-length, reference-count, lifetime hash
entry and backing-allocation bounds. Those inputs still need source/generated
symbol and reference counts; they are not established by payload lengths.

The default x86-64 target chooses `CM_SMALL_PIC` when PIC is effective and
`CM_SMALL` otherwise (`gcc/config/i386/i386-options.cc:2275–2286`). The retained
installation uses default PIE. Existing medium/large-model experiments remain
[separate evidence](unbounded-static-data-continuation.md); this derivation
does not silently select either. Whole-program accounting still needs emitted
code/data and fixed library placement, relocation reach, frame and temporary
object sizes, GCC/assembler/binder/linker counters and containers, and all
growth intermediates. Samples or an individual payload bound do not close them.

The [evidence bundle](../evidence/retained-backend-capacity-20261018/README.md)
retains exact new source bytes, verifies reused source identities and reproduces
the arithmetic. Its checks establish those local facts, not full construct
coverage or installed compiler acceptance.
