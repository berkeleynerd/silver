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

### Ad-hoc location backing and hash arithmetic

Locations carrying a discriminator or a block pointer use the separate
ad-hoc map. Count all fresh entries in a compilation process as H, including
those produced before and after initial CFG construction. The earlier
`S+E_graph` allowance is only one contributor. Repeated requests can reuse
an entry; assuming every request is fresh is conservative.

The backing starts at 128 entries and doubles when full. Both its current
index and capacity are 64-bit; each LP64 entry is 40 bytes (three locations,
one pointer, one unsigned discriminator and padding)
(`libcpp/include/line-map.h:781–805`, `line-map.cc:175–261`). Under
**`H <= 1,073,741,823`**, backing capacity is at most `2^30` and the largest
byte request is **`40*2^30 = 42,949,672,960`**. The selected GGC reallocator
can round this to `2^36` bytes; the map keeps its requested entry capacity
and does not turn allocator slack into additional entries. Capacity doubling,
byte multiplication, pointer offsets, index increment and the location tag
all fit their respective representations. Physical allocation is separate.

This map uses **libiberty's C `htab`**, not GCC's C++ `hash_table`. Its
source happens to have the same 30-prime sequence, but the argument checks
that identity explicitly. Initial request 100 rounds to 127. Growth selects
the first prime at least twice the live-entry count, or keeps its previous
size (`libiberty/hashtab.c:134–195,517–575,633–695`). H's sufficient bound
therefore keeps capacity at most `2^31-1`. The 32-bit probe index plus secondary
step is at most `2p-3`, so it cannot wrap. Occupancy, deletion counts and
load-factor products use LP64 size_t here; unlike the C++ table's heuristic,
even `8*live_entries` is mathematical arithmetic throughout this region.
The pointer backbone requests at most `8*(2^31-1)` bytes. Search/collision
counters are unsigned diagnostic counters; their modular wrap cannot change
lookup or allocation (`include/hashtab.h:94–137`). Hash-value arithmetic is
also intentionally modular, followed by full entry equality.

The bound is a conservative **local sufficient region**, not a native failure
threshold. It prices the generic `2*live_entries` growth request rather than
exploiting the exact insertion-only growth schedule. A tighter schedule-based
region can be substituted if this term becomes binding in the final useful
domain comparison; this component does not choose a smaller source cap.
Ad-hoc backing relocation rebases the existing hash pointers and creates no
new entries (`line-map.cc:93–106,248–258`). The PCH reconstruction helper has
the same insertion family, although the selected Ada build does not use that
route. Counts from other backend stages still need composition before H is
known from source.

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

## Sparse and dense bitmap storage

The CFG/SSA components index bitmaps by block, name or partition number. Let U
bound the universe cardinality, so each used bit is in [0,U), and require
U<=INT_MAX. Range operations additionally require start+count<=U in mathematical
arithmetic. These inputs cover the actual signed dense-bitmap API as well as
the sparse representation; they are not a bound on total bits across all sets.

The selected native `auto-host.h` defines `GATHER_STATISTICS=0` and uses
eight-byte long/long long. The retained header records this relevant build
premise without claiming binary attestation. Thus the 29-bit allocation
descriptor in `bitmap_head` is never assigned a fresh identifier: registration
and memory-statistics updates are gated off (`bitmap.h:466–475`,
`bitmap.cc:35–59`). It must not become a spurious lifetime bitmap-count limit.

On this LP64 layout a sparse `bitmap_head` is 32 bytes and a `bitmap_element`
is 40 bytes: two pointers, a 32-bit bucket index with alignment padding, and
two 64-bit words (`bitmap.h:279–366`). Each element covers 128 bit positions.
A set with k live bits has at most min(k,ceil(U/128)) nonempty elements.
Temporary candidate elements can be constructed and discarded during set
operations, so this live count is not a lifetime allocation count. In
particular, the empty-destination path in `bitmap_ior_and_compl_into` calls
`bitmap_and_compl`, which can allocate a candidate before discovering that
its bits are zero (`bitmap.cc:1520–1616,2540–2562`).

That distinction does not create another representation limit: elements and
heads are separate fixed-size objects linked by pointers. Their freelists have
no aggregate element number or byte-span index. GGC requests retain the
ordinary allocator's rounding; obstack requests use 64 KiB chunks. Each
`XOBNEW` finishes its object, so at the next allocation the partial-object
size is zero. With eight-byte alignment and a request of at most 40 bytes,
`_obstack_newchunk` selects the existing 65,536-byte preferred size
(`bitmap.cc:102–148,732–812`, `coretypes.h:375–388`,
`include/obstack.h:373–421`, `libiberty/obstack.c:188–235`). No large object is
assembled across the chunks. The memory-block pool also links its free blocks
without a growing integer count (`memory-block.h:26–77`,
`memory-block.cc:33–77`). For I obstack initializations, H head allocation
requests and L element allocation requests, I+H+L bounds chunk requests;
reuse only reduces it. The resulting byte subtotal is descriptive, never an
aggregate address-space or RAM gate.

The sparse bucket index is floor(bit/128); bucket endpoints and range loops
fit unsigned32 under U<=INT_MAX, including rounding the last bucket upward.
Bit counts use unsigned long. Converting a tree-view bitmap to a list can use
two temporary pointer vectors, each with at most ceil(U/128) entries, plus
their 32-element inline storage (`bitmap.cc:597–660`). Apply the existing
vector backing rule to that per-vector demand. List-only operations need no
such vectors. The signed default-obstack nesting depth still needs the
caller's bound below INT_MAX before increment; it counts simultaneous
default-obstack initialization, not lifetime element allocations. Initialized
obstacks and valid views/ranges remain caller invariants.

Dense simple bitmaps use two unsigned32 header fields and 64-bit words
(`sbitmap.h:75–139`, `hwint.h:139–156`). For U bits, put w=ceil(U/64). The
single-object request is 8+8w bytes. Its unsigned intermediates, including
U+63, w, 8w and the header addition, fit under U<=INT_MAX; the largest request
is 268,435,464 bytes (`sbitmap.cc:42–134`). That is a representation ceiling
derived from the index interface, not a promise of physical allocation.
Resize consumes a correctly sized bitmap with size=ceil(old_n_bits/64);
arbitrary mixing with an interface that retains larger capacity metadata is
not covered. The initial SSA and liveness callers start with `sbitmap_alloc`.

`sbitmap_vector_alloc(v,U)` makes one contiguous allocation for v pointers
and v bitmaps. Eight-byte alignment leaves its pointer prefix unchanged, so
the total request is v*(16+8w) bytes (`sbitmap.cc:140–176`). Even at
v=UINT_MAX and U=INT_MAX this is below PTRDIFF_MAX on LP64; the source's
size_t products, offset additions and unsigned loop count fit. A caller's
stricter signed v/index limits still apply. Arrays of sparse bitmap headers
likewise need their actual contiguous count multiplied by 32, rather than
the lifetime number of elements in their linked sets.

This closes these container representation interfaces for the stated
universes/configuration. It does not supply every phase's universe, prove
the caller's set invariants, or bound unrelated allocator classes. Lifetime
event estimates remain useful for cost comparison but cannot independently
exclude a program merely for summing many separate small allocations.

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

## Integer constants and the boundary of the folder transfer

Generic helper requests need separate classification. For a scalar constant
path, the local tree allocation is small and does not recurse through
`match.pd`. For symbolic operands, a call to `fold_build2` is not one tree
allocation; treating the two cases alike would leave a gap.

### Constant representation and caches

Let P bound the precision of every participating integral/pointer type, with
`1 <= P <= 128` for this local transfer. This is an input-type premise, not a
new source restriction or a claim about every GCC internal type. On the
selected 64-bit host, `get_int_cst_ext_nunits` requires at most
`floor(P/64)+1` limbs, including the unsigned extension limb when the upper
bit is set (`tree.cc:1581–1616`). The two limb counts are unsigned shorts
(`tree-core.h:1195–1204`), so their largest selected value, three, fits.
`make_int_cst` requests `16+8*extended_limbs` bytes under the LP64 tree layout:
at most 24, 32 or 40 bytes for P=32, 64 or 128 respectively
(`tree.cc:2926–2943`, `tree-core.h:1575–1578`). The calculation's signed-int
intermediate cannot overflow in this domain. Wide-integer arithmetic work
and its temporary storage are distinct from these retained tree allocations.

One ordinary scalar `force_fit_type`/`wide_int_to_tree` request constructs at
most one INTEGER_CST. The overflow path creates its own node directly; other
paths either hit a cache, create a cached value, or allocate one candidate
that may subsequently be discarded (`tree.cc:1696–1729,1805–1953,2008–2013`).
The one-limb hash route inserts its preexisting candidate and allocates one
replacement candidate; count that fresh allocation even though it is for a
future request. No polynomial constant is involved when the input value is
an ordinary integer. The fixed initial candidate is a separate one-node
startup charge (`tree.cc:783–785`).

Small constants can additionally initialize one TREE_VEC per participating
type. Pointer/reference types use three slots; Boolean types two; the selected
default integer-share limit is 251, hence a signed type uses at most **252**
slots (`params.opt:248–250`, `tree.cc:1776–1794,1828–1913`). This vector requests
at most `24+8*252 = 2040` bytes (`tree.cc:2948–2960`,
`tree-core.h:1631–1634`). If R is the scalar constant request count and T
the number of participating type instances, charge at most `min(R,T)` such
cache vectors and `252*min(R,T)` slots, separately from R constant nodes.
Type-copy operations clear the copied cache flag and must contribute their
new type instances to T. Large constants use `int_cst_hash_table`, initialized
with request 1024; the earlier C++ hash transfer applies to its live entries.
Do not charge the cache as 252 fresh constants: its initially empty pointer
slots and later per-value constructor requests are different allocations.

### Constant-only scalar folding

With two INTEGER_CST operands, integral `+`, `-`, `*`, min/max, bitwise
and/or/xor, nonnegative shifts/rotates, and supported divisions/remainders
with nonzero divisor go through `int_const_binop` to one `force_fit_type`
request (`fold-const.cc:1087–1225,1325–1342,1477–1498`). Integer comparison
uses one scalar Boolean constant request (`15945–16110`). Conversion to an
integral/pointer type of the same address space uses one `force_fit_type`
request (`2192–2203,2484–2504,2626–2666`). Negation, absolute value, bitwise
not and truth-not likewise use at most one scalar constant request
(`646–669,1920–2011,6994–7007,15842–15938`).

At the enclosing `fold_unary_loc`/`fold_binary_loc`, a successful constant
result returns **before** the generated pattern matcher. A mismatch between
its type and the requested result type can add one final constant conversion
(`9205–9254,10986–11056`). Thus one such selected constant-only fold has at
most **two scalar constant requests**, each consuming the representation/cache
transfer above. This is an allocation bound even when the evaluated constant
carries an overflow flag; it does not assert that such an expression is legal
Silver. Pointer arithmetic, complex operations, view conversions, invalid
division/shift operands and symbolic expressions are not included in this
two-request row. In particular, an unsupported constant operation can fall
through to the pattern matcher and needs its own classification.

### Symbolic folding remains a separate obligation

`fold_build1/2/3` first invokes its corresponding folder and creates the
plain node only if that folder returns no result
(`fold-const.cc:13886–14015`). The symbolic folder calls generated
`generic_simplify`; `genmatch.cc:3259–3485` recursively emits further
`fold_build*` calls for replacement expressions. The complete pinned
`match.pd` is retained with the checker inputs. Merely counting its syntactic
replacement operators does not bound repeated pattern application, nor does
the fixed number of rules bound expression-dependent recursion.

This closes constant-node/caching arithmetic and the selected constant-only
fold requests. A source-sensitive bound for the reachable symbolic rules,
ordinary conversion/type layout and later GIMPLE folding remains necessary.
The result must consume the bridge's generated complex overflow pairs,
String equality and descriptor/reference shapes as well as source scalar
operators. No undocumented constant multiplier is substituted for that work.

## Scalar and pointer type constructors

The bridge's generic type requests have the following local transfers. They
assume the ordinary GCC invariant that a nonnull canonical type is itself
canonical, the selected Linux target's default type-attribute hook, and completed
scalar/base types. The scalar precision region is `1..128`; generated complex
values here are pairs of ordinary 32-bit Integers. Arbitrary records, arrays,
vector/bitint types, user alignment and language-specific type payloads retain
their own layout transfers.

| Entry request | Fresh type nodes, including discarded candidates | Other local requests |
| --- | ---: | --- |
| `build_pointer_type_for_mode` or reference counterpart | at most 2 | at most 2 scalar/pointer layouts |
| `build_qualified_type` with ordinary non-atomic qualifiers | at most 2 copies | no new layout or bound expression |
| `build_aligned_type`, `build_distinct_type_copy`, `build_variant_type_copy` | at most 1 copy | no new layout or bound expression |
| `make_signed_type`, `make_unsigned_type`, or `build_nonstandard_integer_type` | at most 1 | two scalar-bound constants, one scalar layout; the nonstandard helper also has at most one type-hash insertion |
| `build_range_type` or `build_nonshared_range_type` | 1 | at most two `fold_convert` requests; shared static ranges may add one type-hash insertion |
| unnamed `build_complex_type` for the internal Integer pair | at most 2 | at most 2 scalar/complex layouts and 2 type-hash insertions |

Pointer/reference constructors search the existing chain, then construct the
requested type before an optional call on the canonical referent with
`can_alias_all=false` (`tree.cc:7198–7338`). That second call either finds the
inserted type or reaches the canonical referent; it cannot create an unbounded
canonical chain. The `could_alias` branch can require the second type even when
the referent was already canonical, so one node per entry request is too small.
The record-valued Ada fat-pointer shortcut simply returns its existing type.

Qualified-type construction similarly makes one variant and optionally one
variant of its canonical type (`5840–5885`). Distinct/variant copies call
`copy_node` once and retain the existing bounds, layout and language-specific
pointer; they do not recursively copy the pointed-to graph (`5914–5965`). The
copied Integer-value cache is cleared (`1521–1538`), which is why later constant
requests must count that new type as a separate cache participant. This is not
an exemption for a gigi caller that explicitly copies or completes a language
payload afterward.

`build_nonstandard_integer_type` has a fixed 130-pointer cache on this 64-bit
host, indexed by precision and signedness only through precision 64
(`7340–7385`). Precisions 65 through 128 can allocate a fresh candidate on
every request even if type hashing later finds an equivalent type. Charge
requests, not just the number of distinct widths. Each scalar fixup requests
its minimum and maximum once, then calls layout
(`stor-layout.cc:2838–2860,2991–3040`). Range constructors instead inherit their
base's existing sizes/alignment and convert their two supplied endpoints
(`tree.cc:7460–7511`). Their constant-bound special case consumes at most two
scalar constant requests; symbolic bounds consume the still-separate folder
transfer.

Unnamed complex construction allocates its candidate before hashing and may
repeat once for a canonical component (`tree.cc:8025–8088`). It makes no
TYPE_DECL or name. The `named=true` variant has a separate declaration/name
path and must not use this row without charging it.

### Completed scalar layout has no symbolic folding

For a new Integer/Boolean/enumeral type in the precision region above, an
ordinary pointer/reference, or the internal Integer32 pair, `layout_type`
requests two scalar constants for bit and byte sizes. The mode gives both
sizes directly (`stor-layout.cc:2460–2469,2558–2576,2651–2661`). Its finalizer
does not enter the missing-byte-size division or variable-size path, since
both sizes are constant. It calls `round_up` on each size
(`1962–2019`). Natural scalar alignment is a power of two in the selected
region; the constant arm returns the input or requests one `force_fit_type`
(`fold-const.cc:16378–16418`). Thus, allowing both rounds conservatively,

```text
one completed scalar/pointer/Integer32-complex layout:
    scalar constant requests <= 4;
    symbolic folding requests = 0;
one signed/unsigned scalar construction including fixup:
    scalar constant requests <= 6.
```

An already completed main variant returns immediately. Propagation to existing
variants changes fields but constructs no trees (`stor-layout.cc:2024–2067`).
The Linux target has no default-type-attribute override in its selected header
closure; its hook is `hook_void_tree` (`target.def:2324–2330`). The selected
empty-record hook reaches `is_empty_type`, whose scalar/pointer/complex cases
return false without constructing nodes. The Darwin override is outside this
Linux closure and receives no transferred claim.

### Type identities, cache records and fixed-size allocation

`make_node` and `copy_node` each increment the unsigned32 `next_type_uid` for
a fresh type (`tree.cc:142,1368–1369,1521`). Starting at one, an all-phase fresh
type bound T with `1+T <= 2^32-1` is a sufficient no-wrap condition. Include
startup/fixed types and every discarded candidate. Hash-collision cleanup can
roll back the most recent UID, but the envelope takes no credit for that
rollback (`6433–6479`). This is a local counter condition, not a source cap.

All these type codes allocate `tree_type_non_common`, not a
source-length-dependent object (`tree.cc:1114–1142`). A conservative LP64
structural byte bound is 256: start with the 24-byte common header, three
pointers, a four-byte UID, at most four bytes for each of the 23 declared
bitfields, a four-byte alias-set ID, align the next pointer to eight bytes,
then eight pointer/union slots, one language pointer and four noncommon
pointers (`tree-core.h:1801–1871`; `coretypes.h:366`). This deliberately
does not assume adjacent bitfields share storage. Its individual GGC rounded
request is at most 256 bytes. The actual ABI can use less; pointed-to type
data and constant caches are separate.

`type_hash_canon` calls layout, then either discards the candidate or allocates
one 16-byte `(unsigned long hash, tree type)` record. Its C++ hash table starts
with request 1000 (`tree.cc:150–156,770–774,6433–6492`). The existing
hash backing/probe envelope applies to its live records. For the selected
scalar/range/complex types, completed layout and hash comparison add no new
type or bound expression. These constructor transfers therefore close their
own local allocations without assuming that all generic folding or aggregate
layout is bounded. The remaining gigi-to-request and all-phase sums still
have to supply T and the corresponding constant/hash requests.

### Ordinary Character array types

`build_nonshared_array_type` makes one ARRAY_TYPE, lays it out and may repeat
once for canonical component/domain types (`tree.cc:7576–7668`). With the
canonical invariant above, the second call has canonical inputs and cannot
repeat that recursion. Thus one request costs at most **two type nodes and
two array layouts**, including a discarded or structurally equal candidate.
The nonshared entry performs no type-hash insertion. The shared entry has
at most two insertions; completed sizes make its extra layout call return
immediately. Incomplete arrays require their own repeat-call accounting.

For the ordinary one-dimensional Character arrays reached by Main, the
component is already complete, with bit size 8, byte size 1 and alignment 8.
No user alignment, packing or placeholder bound is selected. The array's
logical length L satisfies `0 <= L <= Integer'Last`; the caller must also
supply representable domain endpoints and bound-expression intermediates.
Its natural byte size is L and bit size is `8L <= 17,179,869,176`, within
the selected 64-bit size representation. A length of zero is allowed.
This is a layout fact, not a sufficient all-phase String capacity rule.

With constant endpoints, one completed array layout requests at most
**13 scalar constants**, before the cache costs already derived above:

| Local work | Scalar constant requests |
| --- | ---: |
| Optional unsigned reversed-bound normalization | 2 |
| Unit literal in length computation | 1 |
| Length subtraction/addition and bit/byte size multiplication | 4 |
| Conversion to sizetype and bitsizetype | 2 |
| Final bit/byte alignment rounding | 2 |
| x86 empty-array query | 2 |

`size_binop` returns its constant result before symbolic folding; each
listed size operation therefore uses at most one constant request
(`fold-const.cc:2092–2137`). The two conversions likewise take their constant
paths. Both alignment rounds use the power-of-two constant path; the byte
round with divisor 1 actually returns unchanged. Charging it is conservative.
The x86 empty-record hook does reach `is_empty_type` for arrays, so it must
not be treated as a scalar no-op: `array_type_nelts_minus_one` can request a
constant subtraction fold before returning (`tree.cc:3834–3872,15095–15129`).
The earlier two-request constant-fold row bounds this case. No variable-size
SAVE or symbolic matcher is entered on this complete constant path.

Mode selection does not impose a maximum String length. `mode_for_size_tree`
returns no scalar mode when size does not fit its unsigned-int temporary;
`compute_array_mode` then retains BLKmode (`stor-layout.cc:296–339,603–633,
2402–2427`). In particular, the 32-bit mode-size temporary is not a 512-MiB
array rejection threshold. The selected x86 member hook returns false for
the supplied VOIDmode; the default array-mode hooks return no special mode
and false. They construct no type or expression. The evidence checks the
selected Linux header closure has no array-mode override.

Dynamic endpoints need symbolic folding, even though the resulting runtime
size has the same natural-layout bound. Expanding just `layout_type`, its
finalizer and these selected helpers gives, per layout:

```text
direct scalar constant requests <= 6
size_binop requests             <= 6
fold_convert requests           <= 2
empty-hook fold_build2 requests <= 1
multiple_of_p requests          <= 1
save_expr requests              <= 2.
```

The first four size operations compute length and bit/byte size; the final
bit-alignment round can add two size operations and three constants. The
byte-alignment round is again identity. `multiple_of_p` is the nonconstant
round's query and is **not** assumed allocation-free. Its recursive work,
the symbolic size/fold helpers and any temporary query storage remain
separate. No missing-byte-size division is selected because Character has
both sizes. With the established no-placeholder Main bound frontier,
`variable_size` returns its argument or calls `save_expr` once; the latter
constructs at most one SAVE_EXPR without copying the expression
(`stor-layout.cc:67–87`, `tree.cc:4132–4170`). Its predicate traversals still
need their own scratch/recursion account. These request bounds must be
multiplied by the possible two canonical layouts; they do not claim complete
dynamic-array or whole-backend capacity.

## Expression unsharing preserves payload and save boundaries

Generic expression copies must charge repeated incoming edges, but need not
charge a new String payload at every expression node. For `unshare_expr` and
the first pass of `unshare_expr_without_location`, `mostly_copy_tree_r` stops
at types, declarations, constants, SAVE_EXPR, TARGET_EXPR and BIND_EXPR
(`gimplify.cc:944–973,1096–1126`). Its data argument is NULL on these entries,
so even the children of those last three nodes remain shared. This preserves
the one-evaluation boundaries inserted by the [gigi bridge](retained-backend-gigi.md#protection-preserves-shared-checked-operands).
The second location-pruning pass changes location fields without copying nodes.

Define a copy weight on the finite operand graph by unfolding its incoming
edges until those stop boundaries. Count one for each ordinary expression,
TREE_LIST, TREE_VEC and CONSTRUCTOR occurrence. A STATEMENT_LIST contributes
zero for its own header and links, but includes each member expression's
weight. TREE_LIST walks its value and chain, not its purpose; CONSTRUCTOR
walks element values, not field/index metadata. The explicit generic walker
has no language callback on this invocation (`tree.h:5921–5929`,
`tree.cc:11719–11993`). Nodes such as BLOCK, SSA_NAME, IDENTIFIER_NODE and
PLACEHOLDER_EXPR are terminal and are not copied. OpenMP clauses are outside the selected frontier. Generated Ada expression
codes use their existing node size and ordinary operand traversal.

For each charged occurrence v, let `bytes(v)` be its input `tree_size` and let
k(v) be its CONSTRUCTOR element count, zero for other kinds. Then:

```text
fresh tree nodes <= copy_weight(input)
raw tree allocation requests <= sum(charged occurrences v, bytes(v))
fresh nonempty constructor vectors <= number of occurrences with k(v)>0
constructor entries copied = sum(constructor occurrences v, k(v))
fresh String payloads = fresh scalar constants = fresh types = 0.
```

`copy_node` allocates one object of the input node's size and copies its
immediate fields. Its extra declaration/type/options handling is unreachable
at these stop boundaries (`tree.cc:1468–1547`). `copy_tree_r` separately copies
a CONSTRUCTOR's element vector; it copies pointer pairs, not their payloads
(`tree-inline.cc:5735–5795`). On LP64 the constructor node is 24 bytes and each
element pair is 16. `vec_safe_copy` reserves from a null vector, so k>0 first
requests capacity `max(4,k)`, then the existing GC rounding applies. The later
`embedded_init(k,k)` does not undo the allocation already made
(`vec.h:731–740,863–868,999–1016`). Charge the rounded allocation, not merely
`8+16k`. Each original input node/vector must already meet the signed length,
allocation-product and GC-capacity conditions; copying does not increase its
individual arity, length or precision.

These are **occurrences**, not unique identities. A shared binary DAG with d
successive nodes, each pointing twice to the previous, requires `2^d-1` copies
when the terminal is a declaration. Wrapping the reused operands in SAVE_EXPR
stops that expansion on this entry. The offline fixtures illustrate both
cases. Applying the result without its save/edge structure could either miss
exponential duplication or impose an unnecessarily large charge. Every actual
gigi unshare request still needs a source-derived input shape and multiplicity.

This result does not cover direct `copy_node(STRING_CST)` conversions already
charged in the gigi payload row, arbitrary `copy_tree_r` users that can copy
TYPE_DECL or statement lists, or folder-induced replacement trees.

### Whole-body copying: include protected children and declaration metadata

Ada selects deep unsharing (`misc.cc:1475–1476`). For each `unshare_body`
invocation, `copy_if_shared` starts at the saved body and the result
declaration's SIZE and SIZE_UNIT. A shared hash set permits a second traversal
inside each SAVE_EXPR, TARGET_EXPR and BIND_EXPR identity, while those
protected nodes themselves remain shared (`gimplify.cc:976–1089`). The
ordinary NULL-data formula above therefore needs additional expression roots.

Define W from the finite input graph of **one function invocation**. Use the
same incoming-edge occurrence weight, cutting at protected nodes, types,
declarations and constants. Sum this weight over:

- the three initial roots;
- each reachable protected identity's walker children, once per identity;
- each reached TYPE_DECL's expression metadata roots, once per type identity.

Expand that root inventory transitively when an added root reaches another
protected identity or type declaration. For BIND, its walker children include
every declared object's INITIAL, SIZE and SIZE_UNIT, plus the body. For TARGET,
use the walker's deduplication of equal operands 1 and 3. DECL_EXPR introduces
scalar MIN/MAX, record field OFFSET/SIZE/SIZE_UNIT and union QUALIFIER, and
every declared type's SIZE/SIZE_UNIT (`tree.cc:11830–11993`). Including each
such reached family even when an earlier visited mark would suppress it is
conservative. Mere references to objects do not replay their initializers.
Generic `walk_type_fields` follows type links, not further expression fields
(`:11637–11711`). OpenMP clauses are outside this frontier.

The source traversal gives the sufficient transfer

```text
fresh ordinary tree nodes <= 3W
raw tree allocation bytes <= 3 * sum(weighted occurrences v, bytes(v))
constructor element-copy requests <= 3 * sum(constructor occurrences v, k(v))
fresh String payloads = fresh scalar constants = fresh types = fresh decls = 0.
```

The factor three charges up to two copies during the initial mark traversal
and one during the permitted protected-node deep-copy traversal. On the
initial traversal, an already marked ordinary
node is copied with its cut subtree. A protected node is marked on its first
visit; later visits can descend through the deep-copy callback only once,
controlled by the shared set. Copying an ordinary subtree preserves its cut
occurrence weight and creates no protected, type or declaration identity.
Consequently it cannot create another protected root family or multiply that
family's allowed traversals. Type-declaration metadata is reached only on the
mark traversal: the copying callback stops at its TYPE_DECL before the walker
opens the metadata. STATEMENT_LIST headers/links are not copied; their member
occurrences still contribute to W.

`copy_node` clears TREE_VISITED on every fresh ordinary copy
(`tree.cc:1484`), but that fact alone does not establish a factor of two.
After the copy callback sets `walk_subtrees=0`, the generic walker's special
TREE_LIST continuation still visits its chain (`:11753–11767`). It marks fresh
ordinary copies, yet a shared STATEMENT_LIST inside that chain retains its
old visited bit: its member expressions can be copied again. This second
copy is charged to the sibling continuation of the first copied cut forest.
That invocation's outer mark traversal stops below the shared statement list;
its inner copying traversal has no TREE_LIST stop/continuation duplication.
Further incoming edges are already separate occurrences in W. The distinct
protected-set traversal can add one more copy. The unmark traversal creates
no tree nodes. Existing visited marks must be allowed: gigi deliberately
marks externally shared trees before gimplification.
The selected `add_decl_expr` and `mark_visited` paths retain that
premise (`trans.cc:9119–9212`). Acyclic ordinary operand/list chains and the
stated protected/type boundaries are the transfer's input invariants.

A small counterexample explains the headroom. Let an initially unmarked SAVE
contain a premarked two-element TREE_LIST chain. The first value is one
ordinary leaf; the second is a premarked STATEMENT_LIST containing ten marked
ordinary leaves. Reference SAVE twice from the body. W is 13: two list nodes
and eleven ordinary leaves. The first SAVE visit can allocate 13 copies, then
the sibling continuation copies the statement-list's ten members again.
The second SAVE visit can allocate 13 more through the protected set, for
36 fresh nodes. Thus `2W=26` is insufficient, while `3W=39` covers this case.
This is a source-algorithm counterexample, not a claim that Silver emits that
particular tree. Keeping the extra pass avoids an unjustified all-marks-clear
or no-TREE_LIST assumption in the general transfer.

The protected hash set has at most one entry per reachable protected identity.
Apply the earlier hash/backing transfer to that count, and apply the ordinary
per-object allocation/vector conditions to each occurrence charge.
The byte sum describes requests, not an aggregate RAM or address-span gate.
The occurrence forest and its node/constructor weights still need the
source-to-GENERIC join. Generic pointer-type walker sets and stack depth are
separate caller costs.

Sum this transfer for every actual invocation: nested functions get their own
set, and `gimplify_body` invokes `unshare_body` at its own entry
(`gimplify.cc:21774`). Do not assume a single process-wide traversal or infer W
from unique node identities. This closes the whole-body copying transfer at
its input interface; it does not close symbolic folding or the earlier
source-to-input bridge.

## Placeholder substitution follows the original expression

The gigi String-template and equality helpers call
`SUBSTITUTE_PLACEHOLDER_IN_EXPR`, whose macro returns null/constant inputs
unchanged (`tree.h:5510–5517`). For nonconstant expressions the implementation
recurses through the **original** operands before constructing a replacement
parent (`tree.cc:4756–4932`). It does not recursively substitute again inside
the replacement returned by a fold or inside a matching object expression.
This is distinct from `substitute_in_expr`, which has a call-inlining route
and is outside this result.

Use the implementation's traversal occurrences, including repeated DAG paths:
TREE_LIST follows value/chain; ordinary arity1–4 nodes follow their operands;
CALL_EXPR follows operand positions1 through its stored length minus one.
Declarations and constants stop. For counts L of lists, H of placeholders,
N1/N2/N3/N4 of ordinary nodes by arity, and C of call occurrences, the direct
upper interface is:

| Request | Bound |
| --- | ---: |
| `tree_cons` | L |
| `fold_build1` | N1+H |
| `fold_build2` | N2 |
| `fold_build3` | N3 |
| Plain `build4`, followed by `fold` | N4 each |
| `copy_node(CALL_EXPR)`, followed by `fold` | C each |

A changed call allocates its copy only at the first changed operand; later
operands update that same copy. Its stored operand count is unchanged, so
the existing input-call length/allocation checks apply. `process_call_operands`
recomputes flags after folding; it is not another source substitution or
argument-copy loop (`tree.cc:4257–4283`). Fold internals and any call-metadata
queries keep their separate transfers.

For each placeholder, at most two searches follow the supplied object's
reference/operand-zero spine (operand one for a compound or conditional).
A direct type match returns an existing subtree. A pointer-target match
requests one folded INDIRECT_REF. No match returns the original placeholder.
If h bounds this acyclic spine length, at most `2*h*H` object positions are
examined; that is a traversal bound, not new expression storage. Parent folds
can still enlarge their results, so the table does not bound their transitive
allocations by N1+N2+N3+N4+C.

There is a useful closed special case: if no placeholder occurs on any
traversed path, induction gives **the identical input pointer and zero tree,
vector or fold requests**. Each child returns unchanged, and every parent
returns before its reconstruction branch. This includes calls whose arguments
contain no placeholders; they do not inline on this helper. Do not infer this
stronger syntactic premise merely from `contains_placeholder_p` returning false:
that predicate intentionally skips some reference operands and saved-expression
children (`tree.cc:4286–4377`). Ordinary Main's captured local array bounds can
use the zero-allocation row once their no-placeholder source argument is joined;
the fixed unconstrained-String template bounds retain the general row. This
closes the substitution recursion interface while preserving the actual
String-bound and folder dependencies.

## Size extrema helpers: recursion and call reconstruction

The constrained-array bridge can inspect a captured bound's initializer with
`max_value` before falling back to its scalar type endpoints
(`decl.cc:2664–2712`). `max_value` and `max_size` have different traversal
rules; neither may be replaced by the placeholder-substitution zero row.
This component covers scalar integral size/bound expressions, with no
placeholder-bearing reference reached by `max_size`, and no call satisfying
the body-inlining gate below. Types and declaration metadata are not recursive
children in this occurrence count. Unsupported tree codes remain excluded by
the bridge's size-expression shape obligation.

`maybe_inline_call_in_expr` copies a function body only when the resolved
callee has both `TREE_READONLY` and `DECL_SAVED_TREE`
(`tree-inline.cc:6667–6720`). A call without that conjunction returns null
without allocating its declaration map or copying a body. The no-inline
premise must cover compiler-generated size wrappers as well as imported
subprograms. An arbitrary call cannot use this component merely because the
command line selects O0.

For `max_value`, recursion follows only original selected children
(`utils.cc:4095–4180`). A VAR_DECL requests one `fold_convert` of its type
endpoint, a NOP conversion requests another, a comparison requests one
scalar constant, and each selected binary or changed conditional requests one
`fold_build2`. Calls satisfying the no-inline premise stop without visiting
arguments. Constants and other declaration kinds stop too. Thus if V, U, Q,
B and K count reached variable, NOP, comparison, selected binary and
conditional occurrences, the direct interface is at most V+U conversions,
Q scalar constant requests and B+K binary fold requests. No result returned
by these folds is recursively revisited by this helper.

For `max_size`, declarations/constants/SSA names stop, SAVE stops, and a
reference without a placeholder stops. Calls take the fallback that visits
each argument once and constructs one new call. A comparison returns a
Boolean endpoint; ordinary unary/binary/conditional reconstruction uses the
folders (`utils.cc:4191–4390`). A conditional always requests its min/max
fold when both arms exist, even when both arms return unchanged. Consequently
absence of placeholders alone does **not** imply zero allocation.

There is one local shape rewrite: an unsigned plus with a multiply by a
sign-bit-set Integer constant becomes a minus with a multiply by the negated
constant. Its negation is one of the closed constant-only scalar folds above.
It introduces one plain binary node and a terminal constant, then visits the
new multiply's original left child once. It neither replays the discarded
multiply nor recursively visits a symbolic fold result. Each such rewrite is
charged to an original plus occurrence; the introduced multiply cannot itself
trigger the plus rewrite.

Let N count original expression occurrences in the traversal forest, B its
binary occurrences, U unary/one-operand expression occurrences, X its
two-operand and conditional expression occurrences, Q comparisons and C calls.
Overcounting the replaced multiplication gives at most N+2B recursive visits.
The following direct request bounds include that replacement:

| Request in `max_size` | Upper bound |
| --- | ---: |
| Plain binary construction for normalization | B |
| Unary fold, including both unsigned-negative corrections | U+3B |
| `size_binop` | 2B |
| Binary fold for two-operand expressions/conditionals | X |
| Scalar endpoint constant | Q |
| Reconstructed call and its operand-count constant | C each |

These are helper entries, not transitive folder allocation bounds. The
placeholder-reference path can recurse into newly computed subtype bounds,
and the inlining path can recurse into copied bodies; both are explicitly
outside this row. The general placeholder template/layout transfer must price
them separately if reached.

The call fallback also needs actual constructor arithmetic. For a call of
arity a>0 it requests a temporary array of a tree pointers, then
`build_call_array` calls `build_vl_exp` with signed length a+3
(`tree.cc:11024–11113`). On the selected LP64 layout, `tree_exp` is 32 bytes,
including its first operand; the call's allocation request is 48+8a bytes.
That byte expression is narrowed to an **int**, so a sufficient condition is
`48+8a <= INT_MAX`, or a<=268,435,449. This also protects a+3 and the argument
loop. Apply the ordinary allocator rounding separately. This is a constructor
interface check, not a new source-call limit; current selected calls have a
small source-derived arity. The temporary array's 8a-byte product fits under
the same condition. For nested calls, the sum of active arrays is bounded by
8 times the forest's total argument positions; it is descriptive stack demand,
not an aggregate RAM or address-space admission gate. The constructor shares
argument payloads and creates no copied String bytes. Call-flag queries and
source-to-expression occurrence weights remain in the surrounding bridge.

### Compiler-generated size functions have a separate finite interface

O0 does not exclude `self_referential_size` functions. `variable_size` first
returns constant sizes, then dispatches placeholder-containing sizes to this
helper; other local sizes use SAVE_EXPR (`stor-layout.cc:67–87`). The helper
can construct one readonly function with a saved body and return its call
(`:155–265`). That function meets `maybe_inline_call_in_expr`'s body gate and
must be included when a size helper reaches it.

Two reductions keep this interface small without assuming all sizes constant.
The bounds template for a one-dimensional String has two completed Integer
fields; its natural layout is eight bytes. Its fat pointer has two pointer
fields and is sixteen bytes on the selected LP64 target
(`decl.cc:2370–2380,7265–7402`). Their own bit/byte sizes are constants, so they
create no self-referential size functions. This statement is about those two
record forms; it excludes the template-plus-array object record, padding and
other imported records.

Also, `self_referential_size` immediately returns unchanged when
`skip_simple_constant_arithmetic(size)` ends at an existing call or
self-referential component (`stor-layout.cc:168–170`). That scanner strips
unary operators and follows the nonconstant side of constant-sided binary
operators (`tree.cc:4220–4243`). Thus a retained unary/constant-arithmetic
chain around a prior size call creates no further function. Applying this
reduction to record alignment/offset formulas requires their **actual folded
shape**; merely observing a constant padding amount before folding is not
sufficient. Arbitrarily branching invariant arithmetic does not satisfy this
smaller constant-sided condition.

Let V count reached `variable_size` invocations and r the number of distinct
self references collected at one invocation. The helper creates at most one
function, so new size functions are at most V. In the layout/record interface,
a sufficient caller bound is

```text
V <= 2*T + 2*D + P + 2*R + C + 2*S,
```

where T counts completed `finalize_type_size` calls, D `layout_decl` calls,
P `place_field` calls, R gigi `finish_record_type` calls with rep_level=1,
C `create_field_decl_from` calls and S `copy_and_substitute_in_size` calls. These
count actual helper invocations, including a repeated field layout, not
distinct source types. The five generic and five gigi call sites are explicit
in `stor-layout.cc:810–813,1679,2012–2015`, `utils.cc:2419–2425` and
`decl.cc:10491,10721–10722`. The source-to-layout bridge still supplies these
counts; the inequality does not declare all six families reachable in Main.

For a nontrivial invocation, the initial private copy follows original operand
occurrences, stopping at types, declarations, constants and the collected
self-reference leaves. It aborts at SAVE_EXPR, retaining any prefix copy
allocations already made; STATEMENT_LIST is outside the valid size-expression
input. Apply the ordinary occurrence and constructor-vector accounting to
this copy. Each of the r references then causes one parameter declaration,
one parameter-type list node and one substitution pass; one final list node
terminates the parameter list. After substitution, the helper adds one function
and one result declaration, one BLOCK, one MODIFY_EXPR and one RETURN_EXPR,
one function-type request and one call-construction request. Parameter/result
layout and function-type canonicalization remain their normal helper costs.
The collected-reference and call-argument vectors use the existing pointer
vector transfers.

Each replacement is a fresh parameter declaration. It cannot equal a constant
or any actual in a pre-existing call, so the substitution's conditional body
inliner does not run on this construction path
(`tree.cc:4564–4740`). Each pass follows its current expression's original
children and may invoke folding, without recursively visiting a newly folded
result. Its input size must be updated between the r passes; neither r times
the first size nor one request per distinct node is a valid general bound.
The already recorded substitution/folder interfaces apply to these passes.

The function name serial is unsigned HOST_WIDE_INT, and the local name buffer
has 128 bytes. A nonwrapping serial needs V plus the incoming serial to remain
below 2^64; the existing function/declaration identity domain is much smaller.
The `p%d` parameter spelling fits that buffer under the signed arity condition.
The final call must satisfy `r <= 268435449` from the variable-arity constructor
above, as well as both vector conditions. Generated filename-derived function
names and identifier interning retain their separate name-transfer obligation.

Finally, `finalize_size_functions` later gimplifies and queues every retained
function (`stor-layout.cc:275–292`). Those bodies need their own unsharing,
GIMPLE and backend charges even if all their original calls were integrated.
This interface prevents treating their creation or later lowering as absent
at O0; it does not yet bound symbolic folding, every imported record, or
source-to-helper multiplicities.

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
EH maps, CFG construction, RTL expansion and instruction/data sizes remain
explicit composition work. The simple cleanup operand copies close as follows.

### Simple cleanup operand copies

The selected BIND cleanup contains only `VAR_DECL := CONSTRUCTOR(empty)`
clobbers and at most one `stack_restore(saved_pointer)` call. The clobber
constructor has a null element vector (`tree.cc:2482–2488`); its LHS is the
existing variable itself (`gimplify.cc:1738–1754`). The restore's one actual
is the pointer temporary created by `build_stack_save_restore`
(`gimplify.cc:1270–1282`). Its function operand is an ADDR_EXPR around the
builtin FUNCTION_DECL (`gimple.cc:251–263`). No source expression tree is
embedded in either shape. This statement concerns the selected cleanup bodies;
it does not generalize to arbitrary GIMPLE operands or debug-value statements.

`gimple_copy` calls `unshare_expr` on each operand (`gimple.cc:2307–2309`).
That walker stops at declarations, types and constants; with null walker data
it also stops at SAVE_EXPR, TARGET_EXPR and BIND_EXPR
(`gimplify.cc:944–973,1096–1101`). The clobber thus copies exactly one empty
CONSTRUCTOR and its null vector requires no allocation. The restore copies
at most one ADDR_EXPR, stopping at the builtin declaration and reusing its
actual pointer variable. `copy_tree_r` and `vec_safe_copy` implement these two
cases (`tree-inline.cc:5735–5795`, `vec.h:863–868`). Each selected copy adds
**at most one ordinary tree node and one expression-operand slot**, with no
String payload, type, declaration or constructor-element allocation. `copy_node`
does not add secondary allocations for either node kind (`tree.cc:1468–1547`).

The subsequent local-declaration remapping creates no additional tree: these
bodies have no labels, BINDs, SSA names or OpenMP clauses, and the variable
lookup returns the original declaration (`tree-inline.cc:5861–6060`). The
empty remapping map and traversal sets still use their ordinary container
transfers; no cost is inferred to be zero merely because the map is empty.
For the earlier cleanup bound, add at most **`(D+2)C` ordinary tree nodes**,
hence at most **`3C`** for Main's outer scopes or **`2C`** for inner scopes.
This is additive across scopes and preserves the earlier absence of recursive
protected-body duplication.

The selected cleanup tuple maximum is four operands: the one-actual restore
uses `1+3`, a switch uses at most three destinations plus its index, a clobber
uses two, and a label or goto uses one. GIMPLE tuple allocation, the switch
temporary's declaration/layout helpers and traversal-container capacity remain
separate transfers. The operand-copy result does not close generic folding or
unsharing of the full Main body.

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
line-map charge. The ad-hoc backing/hash transfer above consumes their aggregate
H; requests from later phases remain part of the location composition.

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
