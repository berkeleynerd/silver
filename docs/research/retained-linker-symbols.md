# Retained ELF dynamic symbol, hash and version capacities

2026-10-18, Linux LP64, [#119](https://github.com/berkeleynerd/silver/issues/119).
This source-derived transfer extends the [linker representation argument](retained-linker-capacity.md).
It bounds selected output arrays and narrow fields from caller-supplied symbol
and version counts. It does not yet derive those counts for every admitted
source or establish whole-link capacity. The [evidence](../evidence/retained-linker-symbols-20261018/README.md)
retains eight complete files from Binutils commit
`5e56594815854de5eca35c7c04b11705d0f19c02`. Their relevant behavior remains an
external source-correspondence premise, not a historical build attestation.

## Dynamic symbols and nonoptimizing hash selection

Let D bound every reached dynamic symbol count, including the null entry,
temporary pre-renumbering counts and later linker-created version symbols.
Let S bound the section-symbol prefix of each renumbering, and N bound the
number of global symbols selected for GNU hashing. Require

```text
1 <= D <= 2^32-1,  0 <= S <= min(D-1, 2^31-1),  0 <= N <= D-1.
```

The section prefix is assigned first and stored in signed-int section
`dynindx`, whereas ordinary/local symbol indices use signed-long fields.
Renumbering's counter is unsigned long; the persistent count is bfd_size_type.
The section-prefix condition covers its narrower assignment independently of
D (`bfd/elflink.c:1031–1092`, `bfd/elf-bfd.h:153,332,686–687,1894`). The
caller's D must include the registration increments at `elflink.c:634,925`;
a final output inventory alone does not establish that lifetime bound.

For the selected ELF64 target, `.dynsym` requests 24D bytes and a present
`.gnu.version` requests 2D. Section initialization touches at most 24(S+1)
bytes inside `.dynsym` (`:7914–7950`). Both products fit 64-bit size_t and
pointer differences under D. The caller must also preserve the ordinary
renumbering invariant that each selected symbol has one index below D.

This transfer selects `info->optimize == false`. The default branch of
`compute_bucket_count` chooses from sixteen fixed sizes, ending at 32771;
GNU hashing raises the smallest choice from 1 to 2 (`:6667–6820`). These
are output-format buckets, distinct from the [BFD name hash](retained-linker-capacity.md#bfd-hash-growth-has-a-different-boundary-from-gccs-hash-table).
The ordinary SysV hash has B <= 32771 and requests `4(2+B+D)` bytes, with
an additional temporary 8D-byte hash-code array. Its header and chain entries
use 32-bit values, fitting D and B (`:7955–8005`).

`ldmain.c:172` defines zero-initialized global `link_info`; `lexsup.c:1181–1189`
sets its optimization flag for linker `-O`. The selected retained argv has no
such option. Excluding any other configuration writer remains part of the
invocation join; this component does not claim an exhaustive linker-option
proof. The optimized bucket search has separate metric/count arithmetic and
is outside this transfer. Either or both hash formats may be emitted: the
bounds do not infer configured hash defaults from their absence on argv.

## GNU hash bloom-filter shift

For N=0, the emitted ELF64 GNU hash is exactly 28 bytes. For N>0, calculate
the following entirely in mathematical integers:

```text
k = bit_length(N)
m = 5                                      if k < 3
    k+3                                    if k >= 3 and bit(k-2,N)=1
    k+2                                    otherwise
m = max(m,6)                               for ELF64
require m <= 30
W = 2^(m-6), B <= 32771
```

This reproduces `elflink.c:8086–8113`. In particular the source expressions
`1 << maskbitslog2` and `1 << (maskbitslog2 - shift1)` start from signed int,
despite their unsigned-long destinations. With m<=30 they remain positive and
representable. The earlier bit test has shift k-2<=26 in this region. The
largest contiguous N satisfying the rule is **201,326,591**; the next value
sets bit 26 and requests a signed shift by 31. This is a sufficient no-overflow
region, not an observed failure threshold or an assertion that the installed
tool fails at the next value. The checker verifies the transition at every
bit-length/quarter boundary rather than enumerating all values.

The two hash-code vectors occupy one 16D-byte allocation. The bitmask and
two bucket arrays occupy one `8W+16B` allocation. Output requests
`4(4+B+N)+8W` bytes; the x86 target has no MIPS translation suffix.
Here W<=2^24, all individual sizes fit pointer differences and size_t, and
the largest output bound is 939,655,192 bytes. Bucket indices, counts and
prefix sums stay below D, and the final index may equal D only after the
last symbol has been emitted. The emitted 32-bit symbol offsets therefore
fit. Hash values intentionally use modular arithmetic; that is not a storage
overflow (`:6504–6647,8007–8188`). Runtime bloom-bit shifts cast their left
operand to bfd_vma before shifting by a value at most 63.

These are separate allocation requests. Their sum is neither a new admission
limit nor a promise of physical-memory availability.

## Version records without an explicit version script

The selected case has no version script, anonymous version tag or
`--default-symver`. It may still create version definitions: an exported
regular symbol containing `@version` causes `_bfd_elf_link_assign_sym_version`
to append a version node (`elflink.c:2647–2751`). Thus no version script is
insufficient to conclude that `.gnu.version_d` is absent.

Let V bound these distinct generated definition nodes. They are zero-filled,
have no dependency lists, and receive consecutive `vernum` values 1..V.
Let U bound distinct imported version dependencies plus all successful
backend-added dependencies, and K their library groups. Require

```text
K <= U
max(1,V+1) + U <= 32767.
```

When V=0 the definition section is excluded. Otherwise it contains one base
definition plus V nodes, each with one auxiliary name: `28(V+1)` bytes.
The maximum generated definition index is V+1. The dependency walk starts
at `max(1,cverdefs)` and gives each new dependency its next index, so its
maximum is `max(1,V+1)+U`. This fits the fifteen-bit version domain; bit 15
is reserved for `VERSYM_HIDDEN` (`include/elf/common.h:1383–1392`). Checking
only the unsigned-short width would wrongly admit collisions with that bit.

Every group is created with its first dependency, so K<=U. Each dependency
has one sixteen-byte external record, as does each group header:
`.gnu.version_r` requests `16(K+U)` bytes. Its actual size accumulator is
unsigned int, despite the 64-bit final section size. The index condition
gives U<=32766 and a maximum request of 1,048,512 bytes, so that accumulator,
group count, group-local unsigned-short `vn_cnt`, and 32-bit next offsets fit
(`elflink.c:2463–2535,7084–7314,7332–7442`). Internal allocation requests
are 64 bytes per Verneed and 48 per Vernaux on LP64
(`include/elf/internal.h:207–235`); they use BFD's separately bounded allocator.

The x86 backend can request `GLIBC_ABI_DT_RELR`, `GLIBC_ABI_GNU2_TLS`,
`GLIBC_ABI_DT_X86_64_PLT` and fallback `GLIBC_2.36`. Charging four successful
additions is a conservative bound even without excluding inactive options
(`bfd/elf64-x86-64.c:6273–6322`). These additions extend an existing libc
group; they cannot create an empty group. Imported definition names, version
IDs and linkage must still be valid; capacity does not prove their semantic
compatibility or the success of external-symbol resolution.

All version-name and library-name additions/refcounts feed the existing
dynamic-string-table transfer, including the base definition's output basename
when V>0. The external name fields are 32-bit offsets. Their final offset
bounds do not excuse intermediate string-table index or lifetime refcount
checks. Final `.gnu.version` emission uses the same version indices and adds
the hidden bit only for selected local definitions (`elflink.c:11172–11209`).

## Remaining joins

The [fixed input inventory](retained-link-inputs.md) bounds fixed symbol
records but is not a lifetime dynamic-symbol count. The later fixed-version
join below adds exact input names. Generated Main/binder inputs, selected/resolved symbols, synthetic
names and registration events must supply D, S, N, V, U and K. The selected
invocation must supply the nonoptimizing/no-version-script premises. Dynamic
String-table events, generic symbol/section storage, relocation targets and
final file/virtual layout remain separate. No compile, link, native proof,
Lean build or complete test run was used for this packet.

Independent narrow review of `36a32b9e24` accepted the arithmetic and source
routes above, including the signed shift transition and automatic version
definitions. It identified an incomplete source citation, now corrected to
include the Verneed scalar fields. The review did not establish configuration
writer closure, source-to-count inputs or whole-link storage.

## Fixed symbol and version input join

The [fixed-version capsule](../evidence/retained-linker-symbols-20261018/fixed-version-results.json)
retains relevant ELF headers, symbol tables, linked string tables and version
definitions for every fixed ELF object/member in the earlier inventory.
Its extraction checked complete installed file/member hashes, then retained
the exact regions for offline parsing. There are1,169 distinct inputs,
of which1,166 are ordinary ET_REL objects. Weighted symbol counts reproduce
the earlier48,769-record inventory.

None of those ordinary objects defines a nonlocal symbol containing `@`.
This excludes such input names as a source of output version definitions;
generated Main/binder and linker-synthesized names still need their own join.
The three DSOs have4,46 and7 version definitions respectively:
libatomic, libc and the loader. Counting even their base versions, retaining
the earlier allowance of nine loader processings, and charging all four
possible backend additions gives

```text
U <= 4 + 46 + 9*7 + 4 = 117
K <= 1 + 1 + 9 = 11.
```

Revisited versions need not all survive; charging separate groups and names
for every revisit is conservative. If the generated/synthetic-name join
establishes V=0, the maximum output version index is118 and
`.gnu.version_r` is at most `16(117+11) = 2048` bytes. The output version
definition section is then absent. These are conditional fixed-domain
conclusions, not a whole symbol-resolution or no-version-definition proof.
This capture/replay reads installed or retained bytes only; no assembler,
linker, compiler or prover executes.
