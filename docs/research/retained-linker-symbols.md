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

## Bound version definitions without assuming they are absent

The fixed-input join can be made useful without proving V=0. The additional
[name-domain check](../evidence/retained-linker-symbols-20261018/version-name-results.json)
reads every retained symbol name, including undefined and dynamic symbols,
and the definition and dependency version names of all three DSOs. It adds a
small retained capsule of the input `.gnu.version_r` sections, verified against
the same complete installed-file hashes. Version-name offsets are interpreted
against the complete linked string tables, including offsets into suffixes of
other strings. Merely splitting those tables at NUL would miss that case.

All 44,222 unweighted input symbol records have names without `@`. The union
of input version-definition names and version-dependency names contains
**51 distinct nonempty names**, none itself containing `@`. Counting base
definitions and unused versions is conservative. Reopening a fixed input
does not add a new name to this union.

The ELF input normalization has two relevant operations:

- `elflink.c:5211–5320` decorates an input symbol with a version name read
  from its definition or dependency version table. It inserts one or two
  `@` characters; it does not invent a version name.
- `_bfd_elf_add_default_symbol` (`:1974–2023,2173–2184`) creates an undecorated
  alias or removes one of the two `@` characters. These operations remove a
  suffix or preserve it. Merging and following aliases can change which
  definition is selected without expanding this suffix-name domain.

The output-definition constructor first searches `info->version_info` for an
equal version name (`:2544–2604`), and appends a zero-filled node only when
that search returns no match (`:2690–2751`). With the selected no-version-script
and no-default-symver premises, each distinct nonempty suffix can therefore
create at most one such node. This bounds the number of nodes without assuming
that a decorated alias can never become a regular definition.

Let W bound distinct additional version suffixes introduced outside the fixed
input normalization just described: generated Main/binder names, linker-created
names or any other selected name producer. Include suffixes newly introduced by
transforming an existing decorated name, not just names starting from scratch.
Then the joined sufficient conditions are

```text
V <= 51 + W
maximum version index <= 52 + W + 117 = 169 + W
require 169 + W <= 32767.
```

For W=0, `.gnu.version_d` is at most `28*52 = 1456` bytes; it may be absent.
The earlier `.gnu.version_r` bound remains 2048 bytes. More generally the
definition bound is `28*(52+W)`. This is an intentionally conservative
alternative to the earlier conditional V=0 specialization, with substantial
headroom and no additional input recapture beyond the small dependency sections.

The generated/synthetic-name inventory must still supply W. The present packet
does not set it to zero, establish a full symbol registration lifetime count,
or close the whole link. It removes the need to settle every alias's eventual
definition flags merely to obtain a useful version-index bound.

## Input symbol construction and lifetime contribution

The next join bounds global-link-hash constructors reached while adding ordinary
ELF inputs, including the names produced by default-version aliases. Let R count
all input symbol records across the selected add-symbol passes, and Q count
the `.gnu.warning.<symbol>` sections visited by those passes. Counting every
input section instead of only warning sections is conservative. The selected
case excludes plugins, wrapped symbols, non-ELF inputs and custom target hooks;
the x86 ELF hook leaves the symbol name unchanged
(`elf64-x86-64.c:6019–6049`). These are the existing selected-input premises,
not claims about arbitrary linker options.

Each ordinary record can cause at most three distinct global entry constructors:

| Name | Constructor route |
| --- | --- |
| Original or version-decorated name | The main loop calls `_bfd_elf_merge_symbol`, which performs one create-enabled lookup (`elflink.c:1175–1179,4995–4997,5326–5331`). |
| Undecorated default alias | `_bfd_elf_add_default_symbol` constructs the short name and performs one more merge lookup (`:2011–2030`). |
| Nondefault alias with one `@` | The same helper constructs this name and performs its second merge lookup (`:2173–2189`). |

The ordinary and alias calls to `_bfd_generic_link_add_one_symbol` receive the
entries already looked up (`:2074–2083,2225–2235,5369–5373`). The indirect-symbol
target lookup uses the already-created original name. Following an existing
alias does not construct another global entry (`bfd/linker.c:520–541,1438–1450,
1478–1490`). The per-record loop invokes the default helper once. Its two merge
calls are not recursive. ELF's default `elf_backend_collect` is false and the
selected x86 backend does not override it, excluding the generic constructor-name
callback from this route (`bfd/elfxx-target.h:406–408`,
`bfd/linker.c:1561–1604`).

Each warning section calls the generic insertion once (`elflink.c:4500–4554`).
That can construct one previously absent underlying name and one warning wrapper.
The wrapper copies the existing entry and replaces its table link; it does not
create a third name (`bfd/linker.c:1838–1869`). Charging two constructor events
per warning therefore covers either existing or absent names. Warning text
storage is a separate allocation and is not priced by this count.

The resulting contribution is

```text
global entry constructors from input passes <= 3R + 2Q.
```

This counts actual construction events across input passes, including entries
that are later discarded. The as-needed path saves/restores table state and
releases newly added arena blocks (`elflink.c:4884–4973,5812–5898`). A restored
snapshot does not allocate another global identity. Reprocessing an input is
charged again in R and Q. The snapshot's copied records, allocation bytes and
name-copy requests remain separate resources; this bound does not silently
equate the live hash table with all memory retained by that operation.

The reviewed fixed input-pass inventory gives R=49,081. Using all 36,433 section
visits for Q yields a fixed contribution of **220,109 constructor events**.
The deliberately broad warning allowance avoids relying on a new absence claim
about fixed section names, and still lies far below the hash-table transfer's
805,306,341-entry sufficient boundary. Generated input records add
`3*R_generated + 2*Q_generated`; the known Main object transfer can supply its
counts, while the binder object inventory is still a witness pending its family
argument. No archive-candidate or common-probe work count is substituted for R.

Linker-script symbols, linker-created linkage/header/constructor symbols, output
version symbols and target-local IFUNC entries require their own additions or
separate table domains. This is not yet a total global-symbol or dynamic-symbol
bound. In particular, a symbol can be made local and registered dynamically
again: its `dynindx` transitions and the shared `dynsymcount` high-water mark
need an event argument beyond this constructor count. The
[offline check](../evidence/retained-linker-symbols-20261018/input-symbol-results.json)
reconciles ten source identities, the prior pass inventory and this arithmetic;
it executes no native tool.
