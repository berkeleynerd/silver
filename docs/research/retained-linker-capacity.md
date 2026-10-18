# Retained ELF linker representation transfers

2026-10-18, Linux x86_64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This extends the [native backend argument](retained-backend-capacity.md) with
the selected ELF64 string-table and BFD hash representations. It supplies
event-to-capacity transfers; source-to-event counts, code/data layout and the
whole [capacity rule](retained-tool-capacity.md) remain unfinished.

The native compiler selects bundled GNU assembler and linker 2.46.1. The
reviewed Binutils release is tag `binutils-2_46_1`, peeled commit
`5e56594815854de5eca35c7c04b11705d0f19c02`. The
[evidence](../evidence/retained-linker-capacity-20261018/README.md) retains
complete source bytes and immutable retrieval identities. As with GNAT, the
installed tool's relevant source behavior is an explicit external premise;
the version query and release tag are not a historical build attestation.
Assume the selected Linux LP64 layout: 32-bit int/unsigned int, 64-bit
size_t/unsigned long/bfd_size_type, and eight-byte pointers. No assembler,
linker, compiler or prover job was run for these derivations.

## ELF string-table input contract

For each `_bfd_elf_strtab` instance, let D bound the number of distinct
nonempty names ever inserted, including entries subsequently made dead by
`--as-needed` rollback. Let l(s) be each such name's byte length excluding its
NUL, and R(s) bound all positive reference increments for that entry over the
instance's lifetime. Use the following sufficient conditions:

```text
1 <= l(s) <= 2^31-2
B = 1 + sum_distinct_s (l(s)+1) <= 2^32
D <= 805,306,341
R(s) <= 2^32-1.
```

R includes both `_bfd_elf_strtab_add` and `_bfd_elf_strtab_addref`; distinct
name counts do not bound repeated references. A total increment count can
conservatively replace every R(s). Callers must retain the ordinary lifecycle
invariants: decrement/offset uses have an outstanding reference, indices
refer to current entries, and additions precede finalization. These are
separate from the arithmetic bounds. Empty names return index zero without
allocation or refcounting (`bfd/elf-strtab.c:142–202,283–298`).

The entry's signed-int `len` includes its NUL. Hence the upper l bound fits
`strlen(str)+1` before narrowing and preserves positivity. Refcounts are
unsigned int; the positive-event bound prevents overflow even with decrements,
clears and saved-state restoration. Restoring an earlier state cannot exceed
its previous count plus subsequent positive events. Rollback leaves dead
entries in the hash table, so bounding only currently referenced names would
miss both retained hash storage and its `count` (`:219–268`).

The current array contains at most one slot for each distinct entry plus its
reserved zero slot. Rollback removes the corresponding trailing slots before
setting their lengths to zero; a later reinsertion cannot duplicate an entry
in that current array. Its capacity begins at 64 and doubles only on exhaustion
(`:90–120,161–179`). Under D it is at most `2^30`, requesting at most `2^33`
bytes. Finalization's separate sorting array requests at most `8(D+1)` bytes;
the save record requests `16+4D` bytes under the stated ABI. Both fit size_t,
as do pointer differences and loop indices. Old/new arrays and sorting/save
storage may coexist; they are physical storage costs, not another membership
gate.

## Final offsets and suffix merging

Finalization temporarily subtracts one from each live positive length, sorts,
restores the NUL, and marks shared suffix lengths negative
(`bfd/elf-strtab.c:343–471`). Nonempty lengths during sorting lie in
`1 .. 2^31-2`; restored lengths lie in `2 .. 2^31-1`. Negation and the
positive-minus-suffix length therefore fit signed int. The unsigned comparator
length subtraction uses the selected implementation's ordinary 32-bit
unsigned-to-int conversion to obtain the signed difference, whose mathematical
magnitude is at most `2^31-3`. The external behavior premise includes the
source's reverse traversal and comparison conventions; this is not a proof
of all C pointer semantics or the vendor's sorting library.

Without taking any suffix-sharing credit, final section size is at most B.
Each stored nonempty starting offset is strictly below B. The suffix adjustment
adds a nonnegative difference smaller than its containing entry's length and
therefore stays within that containing entry. Thus every used offset is below
`2^32`, even at `B=2^32`. Intermediate section-size additions use the 64-bit
bfd_size_type and also fit. Emission's length and cumulative `off` arithmetic
obey the same bounds (`:315–340`). A failed allocation may disable suffix
merging; the unshared B bound already covers that path.

This matters even for ELF64: `st_name` and `sh_name` are four-byte offsets,
while section sizes and addresses are eight bytes
(`include/elf/external.h:124–136,163–171`). A 64-bit object format does not
remove its 32-bit name-offset boundary. Apply the transfer separately to each
actual symbol/section/dynamic String table using this implementation; other
String-table implementations need their own transfer.

## BFD hash growth has a different boundary from GCC's hash table

`bfd_hash_table` uses 32-bit unsigned `size` and `count`, with pointer chains
and a fixed prime sequence (`bfd/hash.c:304–406`). Its default initial size
is 4051. The supported default-size setter clamps its input and selects at
most 134,217,689 on LP64 (`:833–847`); either initial route fits the argument.
The string table makes no other reservation. Each new distinct entry increments
count once; lookups and ELF rollback do not decrement it (`:552–670`).

Insertion tests `count > size*3/4` using unsigned-int multiplication, then
selects the next strictly larger prime. The last prime whose triple fits that
arithmetic is **1,073,741,789**. Its growth threshold is
`floor(3*1,073,741,789/4) = 805,306,341`. Therefore D at or below that
threshold keeps every reached capacity at most that prime; every load test,
count increment, prime lookup and loop index is representable without wrap.
Failure to allocate a growth table freezes the existing table while retaining
valid chains. It does not require a different representation bound.

Do not substitute the [GCC constant-pool](retained-backend-capacity.md#hash-backing-and-probe-arithmetic)
bound or infer this hash safety from `B<=2^32`. The next BFD prime is
2,147,483,647, whose triple wraps before division. The retained arithmetic
checker shows that this can trigger subsequent growth immediately; the
no-wrap region above avoids that path. It is a sufficient source-derived
region, not a measured crash threshold or a claim that all larger tables fail.

Hash values intentionally use modular arithmetic; chain indexing takes their
remainder modulo a positive capacity. Those hash operations do not need a
no-wrap precondition. Name-length narrowing in `bfd_hash_hash`, `len+1` in
copy allocation and pointer subtraction fit the l bound
(`bfd/hash.c:516–584`). Each pointer backbone requests at most
`8*1,073,741,789 < 2^33` bytes through an unsigned-long product. Old backbones
remain in objalloc until table destruction; retain their separate charges.
Even charging every prime through that maximum plus the largest possible
initial capacity gives less than `2^35` requested backbone bytes.

Objalloc uses eight-byte alignment and a sixteen-byte large-chunk header on
this ABI (`include/objalloc.h:51–99`, `libiberty/objalloc.c:62–175`). The
largest single backbone request, name copy and fixed-size hash entry all fit
its unsigned-long alignment addition and subsequent header addition. Small
chunk requests are fixed at 4064 bytes. These facts close the allocation-size
arithmetic for this table family; available RAM remains a separate condition.

## Cache statistics do not constrain the selected link

The earlier global-hash result left BFD's `alloc_size` as a separate possible
cumulative counter. Inspecting its consumers resolves that question for the
selected descriptor without a lifetime-RAM condition. `bfd.alloc_size` and
`bfd_link_info.cache_size` are unsigned64 statistics on this target. The
former is updated after a successful `bfd_alloc`; the latter is updated for
cached relocation and converted-section contents
(`libbfd.c:434–458`, `elflink.c:2900–2925`, `elf64-x86-64.c:3100–3110`).
Neither update uses the accumulated value to construct the allocation or
index an object.

Their sole reader is `_bfd_elf_link_keep_memory`. It returns before either
read when `max_cache_size == (bfd_size_type)-1`
(`elflink.c:53–93`). `ldmain.c:760–762` initializes that value, and the sole
selected setter is the parser's `--max-cache-size` case
(`lexsup.c:1770–1778`). That option is absent from the selected fixed link
command; plugins and user-supplied options remain excluded. The optional
mmap and `!keep_memory` branches return even earlier. None observes either
statistic. There is no later reset of the maximum that makes old accumulated
values visible.

Consequently, two selected executions with identical meaningful state and
arbitrary different values of these two statistics make the same allocation
requests, decisions and output. Each update changes only its own statistic
using defined unsigned modular addition; each potential reader returns
before looking at it. This gives an erasure invariant for these fields under
the descriptor. It **does not assert that their mathematical cumulative
byte totals never wrap**. Such wrapping is unobserved and cannot corrupt a
representation or cause a rejection. As with modular hash arithmetic, it
needs no no-wrap predicate. If `--max-cache-size` becomes reachable, this
argument no longer applies and the cache heuristic needs its own analysis.

All individual BFD allocation sizes, alignment/header additions, array
counts, section/string/symbol offsets and other live counters retain their
existing obligations. This result closes only the two statistic-consumer
questions; it does not establish complete BFD allocation-request coverage.
No aggregate RAM/address-span gate is added across independent objects.

The [offline checker](../evidence/retained-linker-capacity-20261018/check-cache-statistics.py)
hash-verifies the retained inventory of1,516 complete non-test BFD, LD,
include and libiberty files, including generation templates. Its
[result](../evidence/retained-linker-capacity-20261018/cache-statistics-results.json)
records all ten member accesses: the unused i386 update is included in the
inventory and excluded from the x86-64 execution. Other identifier uses are
field declarations, comments, allocation-size attributes and unrelated local
variables/parameters. Two retained no-LTO command records are checked
separately. The written consumer argument establishes the scope; source
hashes and lexical searches are reconciliation checks, not a C proof.
The selected source/tool behavior premise is unchanged.

Replay uses the already retained full source tree, whose immutable archive
URL, archive digest and per-file identities are in
[the source inventory](../evidence/retained-linker-capacity-20261018/cache-source-inventory.json):

```sh
python3 docs/evidence/retained-linker-capacity-20261018/check-cache-statistics.py \
  --binutils-root /tmp/silver-link-layout-20261018/sources \
  --output /tmp/linker-cache-statistics.json
```

Independent focused source review confirmed the unsigned type, initialization,
sole option setter and early-return consumer argument. No native tool ran.

## Remaining native composition

The [fixed input closure](retained-link-inputs.md) supplies the selected null
link's dependency inventory, archive-map storage, conservative repeated
add-symbol input-pass counts and a separate common-probe scan bound. These
work counts are not shared integer counters or live-storage demands. The
compiler's generated symbols/sections, linker-created
names and reference events must still supply D, l, B and R. Final live object
contents alone cannot supply lifetime counts across link rollback.
The [selected dynamic-section sizing transfer](retained-linker-dynamic-sections.md)
now supplies GOT/PLT/relocation payload additions from explicit caller counts,
including regular and local IFUNC paths. Its jump-table multiplication is
unsigned32 despite the64-bit size destination, with sufficient count ceiling
536,870,911. This event-to-size component still requires the source-to-event
and complete-layout joins.
The [dynamic-symbol and version transfer](retained-linker-symbols.md) adds
individual `.dynsym`, SysV/GNU hash and version-record requests. It identifies
the signed-int bloom-filter shifts and fifteen-bit version indices, with
explicit nonoptimizing/no-version-script premises and caller-supplied counts.
GCC/assembler containers, code/data/frame sizes, relocation reach and linker
layout still need their transfers. In particular, x86-64 PC32/PLT32/GOTPCREL
relocations retain signed 32-bit displacement checks
(`bfd/elf64-x86-64.c:53–76`). Conversely, a 65,535-section cap must not be
inferred solely from the ELF header: extended section numbering exists
(`include/elf/external.h:47`, `include/elf/internal.h:80`,
`include/elf/common.h:545`). Neither observation supplies a whole-layout rule.
