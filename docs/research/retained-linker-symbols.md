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

The same input route also has a separate successful dynamic-registration bound.
The main merge and two alias merges each have one possible registration site
(`:1531`), the default-alias helper has one further site (`:2117`), and the main
record loop has two (`:5688,5693`). This contributes at most six increments per
input record. The post-input weak-alias processing has two sites
(`:6096,6111`). Their targets come from the current input's weak list and symbol
array. Each such target is registered only while its index is -1; that loop
does not reset an index. Thus at most two further increments per input record
cover it, without assuming a particular number of alias-search comparisons.

```text
dynamic registration increments contributed by input passes <= 8R
fixed-input contribution <= 392,648.
```

The counter starts at one (`:8400–8401`), and each successful global registration
increments it once (`:631–634`). The as-needed table rollback restores entry
state but does **not** reset this shared counter. Retaining all input-pass
increments is therefore necessary. This source-derived bound also bounds the
dynamic-name additions made by those registration calls; other dynamic String
table users remain separate. It supplies an additive term for the counter
high-water argument, not a final D: local registration, script and global
traversals, backend requests, version symbols and renumbering must still be
joined with their own counts.

Independent combined review of `a7644c9e45` and `327cab366c` accepted the
input-constructor and registration contributions. It replayed the ten-source
check and examined warning wrappers, all three merge routes, the weak-list
target domain and the rollback counter behavior. No material finding remained
in that input-only scope; the whole-link joins above remain outstanding.

## Selected x86 registration schedule and renumbering

The selected ordinary ELF64 x86 link connects those input events to a lifetime
dynamic-symbol transfer. Let H uniformly bound the global-link-hash entries
reachable in any selected traversal, including warning wrappers and indirect
targets; R retains its
all-input-pass meaning above. Let A bound non-dot assignment nodes visited by
the link-assignment walk, including any linker-inserted statements. Let Qin
and Qout bound the input and output section visits at the start/stop walks,
and V bound generated version-definition nodes. These remain source-derived
caller inputs: H is not silently replaced by the earlier input contribution,
and A is not assumed to equal only the handwritten script's assignments.

Two target facts simplify the renumbering:

- `elfxx-x86.h:996–997` selects `_bfd_elf_omit_section_dynsym_all`, whose body
  returns true (`elflink.c:1020–1027`). Therefore the dynamic section-symbol
  prefix **S is zero**, including for PIE. The generic section-prefix
  arithmetic remains valid for other targets but contributes nothing here.
- The selected target never calls `bfd_elf_link_record_local_dynamic_symbol`.
  Its only list insertion is `elflink.c:921–925`; the selected x86 table starts
  zeroed (`elfxx-x86.c:717–729`). The separate x86 local-IFUNC hash is not that
  list. Its allocation callback enters the regular-IFUNC branch and returns
  before the dynamic-registration sites (`:130–163,563–575`), and the IFUNC
  helper has no registration call. Thus **dynlocal stays empty**. The
  generic IA64 fixup and local-registration callers in other targets are not
  selected. X86's actual fixup only removes an existing dynamic index and
  reference (`:3193–3205`), so repeated registration still needs accounting.

The single ordinary `ldemul_before_allocation` route calls the x86 preliminary
layout pass, then the generic ELF hook, then `ldelf_before_allocation`, and
finally `bfd_elf_size_dynamic_sections`
(`ldlang.c:8736`; `emultempl/elf-x86-64.em:36–63`; `elf.em:171–174`;
`ldelf.c:1752–1845`). Its other call site in `ldlang.c` belongs to the excluded
GNU object-only secondary link. The selected input/configuration argument
already excludes that route. Relaxation does not repeat the before-allocation
hook. This source schedule gives the following **successful increment** bounds:

| Route | Bound | Reason |
| --- | ---: | --- |
| Ordinary input and version-alias processing | `8R` | The input transfer above includes rollback losses. |
| Script assignment notification | `2A` | At most one symbol plus its weak definition (`elflink.c:828,839`); `ldelf.c:1645–1705,1802` visits each assignment expression once. |
| Optional global export traversal | `H` | One registration site per visited entry (`elflink.c:2290,6982–6984`). |
| Version-assignment flag fixing | `H` | One flag-fixing call per visited entry; its selected backend fixup adds no registration (`:2669,3142,7056–7058`). |
| Dynamic adjustment, including weak recursion | `4H` | At most H initial visits and H recursive calls, with at most two registration sites per call (`:3142,3303`). |
| X86 relocation allocation | `5H` | One global traversal and five possible sites per entry (`elfxx-x86.c:179,329,461,469,514,2418–2419`); the local-IFUNC callback adds zero. Charging the i386-only site too is conservative. |
| Output version symbols | `V` | One per generated definition (`elflink.c:7241–7253`); the separate base-version symbol requires excluded `--default-symver`. |
| Start/stop definitions | `2Qin+2Qout` | Two calls per input/output section (`ldlang.c:7109–7138,7215–7231`), at most one registration each (`elflink.c:15741`). Output dot-prefixed names actually take the hiding branch, so charging them is conservative. |

Dynamic adjustment marks an owner before its one possible recursive call and
does not reset that mark during this phase (`elflink.c:3331–3338,3378`). The
flag-fixing and undefined-weak work occurs **before** the mark guard, which is
why the bound charges both initial and recursive visits. Counting only the
backend adjustment callback would miss those earlier registration sites.
The selected x86 backend adjustment has no registration or recursive adjustment
call. Its VxWorks dynamic-section registration is guarded by the excluded
target OS (`elfxx-x86.c:4690–4693`; `elf-vxworks.c:116`).

Each renumbering assigns at most H nonnull global entries. The local and global
traversals partition them by `forced_local`; neither the empty dynlocal list
nor the zero section prefix adds an entry (`elflink.c:951–990,1040–1092`). A
renumbered count is therefore at most H+1. It may increase a previous count,
so the bound must allow that reset as well as the ordinary increments:

```text
all registration increments <= 8R + 11H + 2A + V + 2Qin + 2Qout
D <= 1 + 8R + 12H + 2A + V + 2Qin + 2Qout
S = 0
N <= H
```

The D expression starts from the maximum reset value H+1 and charges every
increment over the entire link; it remains sufficient across both renumberings,
hiding, alias redirection and as-needed rollback. No monotonic-final-count
assumption is used. Apply the earlier D-width and GNU-hash shift conditions
to these computed bounds. The same registration term bounds dynamic-name
additions made by this function, but it does not include other String-table
users or refcount increments.

The [offline reconciliation](../evidence/retained-linker-symbols-20261018/registration-results.json)
checks 25 complete source identities and the registration-site partition. This
is a reviewed source argument with arithmetic reconciliation, not a machine
proof of C reachability. Source-to-H/A/Qin/Qout, generated input counts,
remaining name suffixes, String-table/arena storage and final layout still
need their joins. It establishes no whole-link capacity result or enlarged
Silver domain, and starts no native tool.

Independent review of `443dbfc8d9` replayed all 25 source identities and checked
the callback schedule, recursion guard, local-IFUNC exclusions and both
renumbering domains. It accepted the conditional registration bound. The H
premise is a uniform reachable-domain bound for each traversal, not a claim
that all constructors over the process lifetime remain live simultaneously.

## Selected script and synthetic-name join

The three selected scripts are the retained `elf_x86_64.xdc` default script,
`libatomic_asneeded.so` and `libc.so`. Their exact bytes are retained by the
[input inventory](retained-link-inputs.md). The two library scripts add only
file/group/search-format operations: they contain no assignments. The default
script has 26 assignment expressions, of which **16 target a symbol other
than dot**. These 16 destinations are distinct. Its only other ordinary
symbol-name input is `ENTRY(_start)`; RHS names are dot or the built-in
section/page/segment operations, not further ordinary-symbol references.
Charging `_start` even though the final entry lookup has `create=false`
gives a conservative **17-name script domain**.

Script identifiers pass unchanged to `fold_name`, `exp_assop` and the
corresponding link-hash lookups (`ldexp.c:719–803,1160–1206,1388–1442`).
Repeated expression evaluation reuses an existing identity. None of these
three scripts contains `@`, a version definition, OVERLAY, INCLUDE, EXTERN
or INSERT. The selected descriptor has no command-line undefined/defined
symbols, version script, wrapped-symbol list, MRI script or custom target.
The earlier input-discovery argument supplies the complete script selection;
this is not an assertion about arbitrary linker scripts or options.

The assignment walk does not multiply this count. `lang_for_each_statement`
visits each tree node once and descends through its children
(`ldlang.c:1088–1140`); `ldelf_find_exp_assignment` recursively visits an
expression's children once (`ldelf.c:1645–1705`). The selected default script
does not share assignment subtrees. Subsequent padding/orphan placement does
not insert a new symbol assignment before this walk. The possible extra
assignment producers are excluded as follows:

- Overlay statements require the absent OVERLAY syntax
  (`ldlang.c:9486–9494,9528`).
- `ldctor_build_sets` adds assignments only for its collected sets
  (`ldctor.c:251–333`). The selected ELF input route sets symbol flags only
  to ordinary global, weak or GNU-unique classes, never `BSF_CONSTRUCTOR`
  (`elflink.c:5022–5073`); the x86 add-symbol hook does not change them.
  The other constructor callback is gated by `collect`, which is false for
  this target (`elfxx-target.h:406–408`, `linker.c:1565–1604`). Thus neither
  `ldmain.c:1709–1722` nor `:1741–1784` populates the set list.
- The selected ELF/x86 emulation templates add no assignment expression.
  MRI and other target emulations are not selected.

Consequently **A=16** is a sufficient bound for the one non-dot assignment
notification walk. This is a source-derived count, not a count from a link
map or a particular output binary.

Only four independent fixed spellings are added by the selected backend's
global-name constructors:

| Producer | Name domain |
| --- | --- |
| Linkage symbols (`elflink.c:187–222,275,410,499`) | `_GLOBAL_OFFSET_TABLE_`, `_DYNAMIC`, `_PROCEDURE_LINKAGE_TABLE_` |
| Unwind header (`elf-eh-frame.c:1764–1774`) | `__GNU_EH_FRAME_HDR` |
| Output version symbols (`elflink.c:7241–7249`) | One existing version name for each of at most V version nodes |

The TLS-base and legacy stack helpers first require a lookup of an existing
name (`elfxx-x86.c:3093–3111`, `elflink.c:6844–6879`); they do not expand the
name domain. Start/stop and section-size helpers also use `create=false`
(`elflink.c:15709–15710`). Symbol hiding, final entry resolution, archive
candidate lookup and version-alias redirection likewise use existing names.
The excluded `--default-symver` route is the only output-basename version
symbol constructor. Warning wrappers and ordinary/default aliases are already
charged by `3R+2Q`. The separate x86 local-IFUNC table is not the global table.

The supplemental [fixed section-name capsule](../evidence/retained-linker-symbols-20261018/fixed-name-results.json)
reads all 29,004 section records in the 1,169 fixed ELF objects, following
each actual section-name offset. None contains `@`; the 28 warning sections
therefore introduce no new version suffix. This capture checked complete
installed file/member hashes before retaining the exact section-name tables;
offline replay uses those bytes. The warning count is descriptive: the prior
broad `Q` bound still charges every section visit.

At any selected traversal, the global table and its warning/indirect targets
therefore fit

```text
H <= 3R + 2Q + 17 + 4 + V = 3R + 2Q + V + 21
A <= 16
D <= 285 + 44R + 24Q + 13V + 2Qin + 2Qout.
```

The last line substitutes the first two into the previous lifetime
registration transfer; it retains all `8R` registration losses. As-needed
rollback may cause the same spelling to be constructed again, but does not
increase the live name domain. **This H bound is not a lifetime constructor
or cumulative arena-allocation bound.** Storage with an actual cumulative
counter must account for discarded allocations; the global hash arena
analysis below does not invent such a counter for objalloc.

If generated Main/binder symbol and section names also have no `@`, the
selected linker introduces no additional version suffix: the only decorator
uses the 51 retained version names, its default aliases preserve/remove that
suffix, and version-symbol names themselves contain no `@`. Under that
explicit generated-name premise, W=0, V<=51 and the maximum version index
is169. The fixed-input contribution to H is then220,181; generated inputs
add `3R_generated+2Q_generated`. Main's name transfer is established in the
[assembler record](retained-assembler-capacity.md); the binder's complete
compiler-name transfer remains separate. Without that join, retain the
earlier `V<=51+W` interface rather than substituting zero for W.

The [offline checker](../evidence/retained-linker-symbols-20261018/check-global-names.py)
reconciles 31 complete source files, the exact script bytes and this
arithmetic. It is not an ld parser or a C reachability proof. Generated
counts/names, section visits, lifetime storage and final layout remain open;
no whole-link result or enlarged admission domain is claimed.

## Dynamic String-table lifetime join

The same selected configuration also bounds the `.dynstr` users. Let J be
the successful dynamic-registration increment bound from above, and let
`N_generated`, `B_generated` and `L_generated` bound respectively all
nonempty generated-input symbol/section-name occurrences, their total bytes
including each NUL, and their largest payload. Counting section names too
is conservative. Let `L_rpath` be the configured runtime-search-path length.
Keep the preceding no-`@` generated-name premise explicit in this join.

Dynamic symbol registration removes the entire suffix starting at the first
`@` before inserting the name (`elflink.c:645–659`). Consequently, decorating
an ordinary input name and constructing its default/nondefault aliases do not
add distinct longer names to `.dynstr`. The underlying warning name is a
substring of its `.gnu.warning.<name>` section name. Counting every fixed
input symbol and section name on every retained pass gives72,019 occurrences
and1,568,528 NUL-inclusive bytes. This deliberately includes duplicates,
unused names and the repeated loader trials.

The additional name domain is the 17 script names, four independent synthetic
names,51 fixed version names, four possible backend version requirements,
three DSO SONAMEs, the output basename `main`, and the configured rpath.
The input inventory records a nonempty SONAME and no DT_AUDIT in each selected
DSO. The loader therefore uses its SONAME rather than an arbitrary filename
(`elflink.c:4781–4798`), and the input audit-to-depaudit accumulation is empty
(`ldelf.c:1810–1837`). The descriptor has no output SONAME, filter, auxiliary
filter, audit or depaudit option. Its explicit rpath also excludes the
LD_RUN_PATH fallback. The no-version-script route creates zero-filled version
nodes without dependency lists; it has no version-dependency addrefs.

These facts give the unshared lifetime name bounds

```text
distinct .dynstr entries <= 72,100 + N_generated
unshared .dynstr bytes <= 1,569,550 + B_generated + L_rpath
largest name payload <= max(171, L_generated, L_rpath).
```

The byte bound includes the table's reserved zero byte and every name's NUL,
including rpath. It charges all four possible backend version spellings even
if one is already in the fixed51-name union. Reinserting a dead name after
rollback reuses its retained String-table hash entry; it does not enlarge this
distinct-name domain. No suffix-sharing credit is taken.

References require a separate lifetime count. The selected positive-reference
sites are:

| Site (`elflink.c`) | Positive events |
| --- | ---: |
| Global registration `:659` | J |
| Local registration `:914` | 0: selected dynlocal list is empty |
| DT_NEEDED `:3944` | <=22: conservatively two hooks times11 DSO processings |
| Output SONAME `:6991`, base SONAME addref `:7167` | 0: no output SONAME |
| Base version output basename `:7179` | <=1 |
| Version-definition name addref `:7281` | <=V |
| Version-dependency addref `:7303` | 0: no version-script dependencies |
| Imported version group/name `:7404,7427` | <=K+U<=128 |
| Rpath `:7588` | <=1 |
| Filter/auxiliary/audit/depaudit `:7602,7617,7629,7640` | 0 under the selected descriptor/input inventory |

The DT_NEEDED wrapper inserts before testing whether the tag is already
present, then may decrement the reference (`:3933–3970`). Charging attempts
therefore matters. Its sole selected caller scans the input list at the end
of DT_NEEDED handling (`ldelf.c:1199–1209`). The two-hook allowance is
conservative: the plugin hook is actually excluded and additionally suppresses
this insertion loop while handling plugin dependencies. The previous
one-time size-dynamic-sections schedule supplies the version and rpath rows.
The selected x86, IFUNC and unwind helpers add no direct String-table refs.
The later `:10432` insertion uses the distinct ordinary `symstrtab` instance.

Thus **positive references <=J+V+152**, or <=J+203 when the generated-name
join supplies V<=51. This bounds every individual unsigned32 reference count,
including increments later undone by hiding, duplicate DT_NEEDED or rollback.
Apply the [String-table transfer](retained-linker-capacity.md) to these actual
inputs: name lengths, distinct entries, unshared bytes and positive refs have
separate representation conditions. This is not an aggregate RAM condition.
Generated-input sizes and Qin/Qout remain caller obligations; ordinary symbol
and section String tables and the final file/layout are separate. The
[offline reconciliation](../evidence/retained-linker-symbols-20261018/dynamic-string-results.json)
checks the retained identities, direct-site partition and arithmetic without
executing a native tool.

Independent combined review of `ca6fd8c437` and `54200120f7` replayed all three
name/String-table checkers byte-equal. It checked the script walk, empty
constructor-set path despite SORT(CONSTRUCTORS), fixed/generated name routes,
existing-name guards, version dependencies, SONAME/audit inputs and
DT_NEEDED's pre-deduplication increment. It accepted the displayed bounds
without a material finding, retaining the generated-input and lifetime-arena
obligations and the generated warning-section premise.

The generated-name premise is now supplied for the selected null link.
Main's source-derived assembler transfer preserves its symbol spellings;
the [binder naming transfer](retained-binder-capacity.md#names-calls-and-retained-object-inventory)
and its warning-section extension (`0f738ce13a`, `284c5c9463`) independently
trace builtins, libcalls, generated elaboration/init names and the selected
ELF section producers. Binder nonlocal names contain no `@`, and it has no
`.gnu.warning.<name>` producer. Other section names cannot introduce a new
global spelling through the create-disabled start/stop lookups. Thus the
selected Main/binder/fixed/script/synthetic union supplies **W=0**, V<=51
and maximum version index169. The earlier checkers deliberately retain their
conditional transfer interfaces; this composition supplies the naming
premise, not the still-open generated counts, lengths or whole-link capacity.


## Global hash storage and rollback snapshots

The selected x86 global link hash stores one
`elf_x86_link_hash_entry` per ordinary entry. Its constructor allocates the
complete derived record once and passes that existing record to its
superclasses (`elfxx-x86.c:625–657,725–727`). On the retained LP64 ABI,
a conservative field-layout calculation charges every bitfield its own
four-byte unit, rather than relying on the tighter compiler packing:

| Record portion | Bound in bytes | Fields |
| --- | ---: | --- |
| BFD link entry | 80 | 24-byte base hash, eight bitfields and a 24-byte union |
| ELF extension | 192 | ten eight-byte fields/unions and 27 bitfields rounded to eight-byte alignment |
| X86 extension | 72 | one byte rounded to eight, ten bitfields, three eight-byte fields/unions |

The sum is344, so **512 bytes per complete entry** is sufficient.
The separate common-entry record is16 bytes: an unsigned alignment power
and one pointer (`include/bfdlink.h:92–205`, `bfd/elf-bfd.h:128–280`,
`bfd/elfxx-x86.h:326–387`). These are derived upper bounds, not measurements
of the installed binary's `sizeof` values.

Let H be the uniform live/traversal entry bound above and C the table's
pointer capacity. The as-needed snapshot loops over actual table entries,
copying one entry, at most one warning target and at most one common record
per entry (`elflink.c:4884–4973`). Its `size_t` request is therefore at most

```text
8C + (2*512+16)H = 8C + 1040H.
```

Restoring an unneeded input restores both `table.count` and `table.size`
from their saved values (`:4936–4938,5842–5844`). Thus H bounds the actual
global hash count, including its high water during each input trial; repeated
construction after rollback is not a cumulative `count` increment across
those trials. This differs from the dynamic String table, whose dead entries
remain in its hash. Applying the existing sufficient hash-growth conditions
`H<=805306341` and `C<=1073741789` also bounds the snapshot request by
846108528952 bytes, below signed64/size_t. That very loose representability
bound is not an assertion of available physical storage or a required
allocation for an ordinary null link.

Name copies use two interfaces. `bfd_hash_hash` narrows the name length to
unsigned32, and `bfd_hash_lookup` adds the NUL in that type before requesting
objalloc storage (`hash.c:509–532,552–584`). `bfd_hash_allocate` separately
accepts an unsigned32 size (`:740–760`). A sufficient payload condition is
therefore **L<=2^32-2**, covering both length-plus-NUL routes. The selected
global names satisfy `L<=max(171,L_generated)+2+L_version`: input, script and
synthetic spellings have the preceding name domain, and version normalization
adds at most two `@` bytes plus one retained version suffix. Substring aliases
and warning targets do not lengthen their originating names. The generated
length remains a caller input; the no-new-version result supplies the fixed
suffix domain.

The global table owns an independent objalloc, not an output-BFD arena.
Objalloc stores a current pointer, unsigned32 remaining space in a small
chunk and a linked list of chunks. It has **no cumulative byte counter**
(`include/objalloc.h:44–49`). Each small chunk is4064 bytes; large requests
add a16-byte header after eight-byte alignment
(`libiberty/objalloc.c:62–175`). A request taken from the current small chunk
is guarded by its remaining space. Individual names, fixed-size records and
the previously bounded pointer backbones fit these operations. Multiple
old backbones or repeated names may remain allocated, but their aggregate
RAM is not another representation predicate. Allocation failure remains an
external resource outcome under the proposed capacity contract.

This closes the selected global hash count, per-request arithmetic and
rollback-snapshot storage interface. The separate
[cache-statistic consumer argument](retained-linker-capacity.md#cache-statistics-do-not-constrain-the-selected-link)
now shows that BFD's `alloc_size` is unobserved under this descriptor; it
requires no cumulative byte gate. The local-IFUNC table, other link allocation
requests, ordinary symbol/section String tables, generated input counts and
final layout remain separate joins.

The [offline checker](../evidence/retained-linker-symbols-20261018/check-hash-storage.py)
verifies37 complete source identities, the reviewed bitfield inventory and
the displayed arithmetic. Its
[result](../evidence/retained-linker-symbols-20261018/hash-storage-results.json)
retains the scope exclusions. Anchors and hashes reconcile the written
source argument; they do not automatically prove C reachability. No native
compiler, assembler, linker or prover was executed for this result.

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-hash-storage.py \
  --output /tmp/linker-hash-storage.json
```


Independent narrow review replayed37 source identities and the hash result
byte-for-byte, then checked the derived record constructor/layout, warning
and common snapshot cases, count/size restoration, length/NUL arithmetic and
objalloc paths. It accepted this transfer and the preceding W=0 composition;
the objalloc field citation was corrected after review. Generated count/length
and whole-link closure remain outside that acceptance.


## Selected local-IFUNC table is empty

The retained fixed-symbol capsule contains44,222 symbol records across
1,169 distinct fixed ELF objects/members. Reading each symbol table's
`sh_info` local boundary and symbol type finds82 GNU_IFUNC records, all
nonlocal and all in two shared objects. It finds **zero local IFUNC symbols**.
Repeated archive/group/loader processing cannot introduce a new type into
these fixed bytes. This is an exhaustive read of the selected fixed inputs,
not a sample of generated objects.

The generated Main and binder require a separate source premise. Null Main
has one ordinary function, no aliases or attribute-bearing declarations,
as established by the native lifecycle/emission transfers. The binder's
source projection similarly excludes `Machine_Attribute`, inline assembly
and the multiversion/alias routes. The
[binder type-producer argument](retained-binder-capacity.md#names-calls-and-retained-object-inventory)
connects that absence to GCC's `ifunc_resolver` flag and IFUNC type directive;
it does not infer it from the observed binder object. With that premise,
the complete selected input union contains zero local IFUNC records.

The x86-64 backend has exactly two calls to the local-symbol hash helper.
Relocation checking creates an entry only for a local symbol whose type is
`STT_GNU_IFUNC` (`elf64-x86-64.c:2583–2603`). Final relocation uses the same
guard and passes `create=false` (`:3259–3273`). Neither is reached for this
input union. Only the create helper sets `has_loc_hash_table`
(`elfxx-x86.c:581–619`), so the later local allocation/finish traversals
remain empty (`:2423–2426`, `elf64-x86-64.c:5781–5784`). This excludes no
regular global IFUNC path; those remain covered by the dynamic-section
transfer.

Startup still constructs both storage objects unconditionally
(`elfxx-x86.c:785–795`). `htab_try_create(1024,...)` rounds to prime2039,
allocating a16,312-byte pointer backbone and one control object bounded
by128 bytes on LP64 (`libiberty/hashtab.c:134–173,347–375,402–405`,
`include/hashtab.h:94–137`). The independent objalloc requests a24-byte
control object and one4,064-byte initial chunk. There are no local entry
records, later hash resizes or additional chunks for this instance.
Destruction frees the existing objects (`elfxx-x86.c:685–699`). Each
individual fixed request fits its size representation; their sum is not
an additional memory predicate.

The [offline checker](../evidence/retained-linker-symbols-20261018/check-local-ifunc.py)
verifies39 complete Binutils source identities, all retained fixed ELF
regions and their correspondence to the existing fixed-input inventory.
Its [result](../evidence/retained-linker-symbols-20261018/local-ifunc-results.json)
retains the generated-source absence as an explicit composition premise.
No native tool or new generated-object witness ran. This closes only the
local-IFUNC table; general linker allocations, payload and final layout
remain separate.

```sh
python3 docs/evidence/retained-linker-symbols-20261018/check-local-ifunc.py \
  --output /tmp/linker-local-ifunc.json
```
