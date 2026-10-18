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

## Remaining backend closure

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
