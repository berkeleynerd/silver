# Selected null linker count and payload composition

Research for #119, 2026-10-18. The source-derived Main envelope and accepted
[binder object transfer](retained-binder-capacity.md) now supply the remaining
generated-object inputs to the linker count and payload formulas. Every
listed component arithmetic condition passes. The reviewed alignment and
mapping-convergence transfer now supplies the layout inputs. Relocation operands
and complete auxiliary representations still need their joins before claiming
whole-link capacity. This changes no admission rule.

## Counts and names

Use the fixed Linux x86-64 input/configuration descriptor of
[retained-link-inputs.md](retained-link-inputs.md), including its conservative
archive and additional-loader processing occurrences. The binder object
transfer applies to the selected null source family under its documented
filename, path, token and option premises. Main is the source-derived emission
envelope, not an observed object substituted for a proof.

| Quantity | Joined upper bound |
| --- | ---: |
| Original symbol records R | 49,358 |
| Original section headers Q | 36,471 |
| Object processing occurrences P | 1,483 |
| Original relocation headers Qrel | 7,917 |
| Original relocation records Trel | 546,740 |
| Global entries H | 221,088 |
| Input section chain I | 48,872 |
| Output section chain S | 48,965 |
| External ELF section headers N | 48,970 |
| Reserved/actual program headers T | 146,908 |
| Dynamic symbol count high water D | 3,243,678 |
| Ordinary output symbols Z | 763,072 |

These follow the existing component formulas, using Vdef=51 possible version
definitions and at most16 non-dot assignment visits:

```text
H = 3R + 2Q + Vdef + 21
I = Q + Qrel + 3P + 35; S = I + 93; N = S + 5; T = 3S + 13
J = 8R + 11H + 32 + Vdef + 2I + 2S
D = H + 1 + J
Z = R + P + S + 3H + 2.
```

The sharper section count gives S<0xff00, discharging the dynamic symbol
section-index guard. The much larger T deliberately retains the previous
general program-header envelope; it is not a prediction of the selected map.
Using smaller I/S bounds in the symbol walk formulas is valid because those
formulas depend on actual section-chain visits, not the expression used to
bound them. Live H and lifetime J/D remain different quantities.

Main supplies118 nonempty symbol/section-name occurrences and3,194
NUL-inclusive bytes. The accepted binder projection supplies189 occurrences,
4,061 bytes and maximum length45. Neither has an `@` suffix. The combined
307 names and7,255 bytes therefore discharge the generated-name interface;
the fixed maximum171 remains sufficient for ordinary names. The selected
rpath is169 bytes. The resulting dynamic String table is at most1,576,974
bytes. Ordinary strings use maximum payload length196; section strings use182.

## Per-item payload union

The following are additive upper bounds across all sizing phases. Original
payload and full transformed output are both charged where an input changes
size. This bounds the sum of each item's maximum, including items whose maxima
occur on different passes; it does not substitute the maximum of one observed
whole-pass total. Both allocated and nonallocated contents, and NOBITS, count.

| Contribution | Bytes |
| --- | ---: |
| All original fixed input sections | 46,206,441 |
| Main and binder original sections | 35,356 |
| Full fixed and generated merge output | 3,168,261 |
| Full edited EH output, including PLT templates | 743,934 |
| EH search header | 119,668 |
| Full property rewrite | 344 |
| Copy storage, including its internal alignment | 49,388,748 |
| Interpreter | 28 |
| Dynamic symbols and version indices | 84,335,628 |
| SysV and GNU hashes | 14,383,400 |
| Ordinary symbols and optional extended indices | 21,366,016 |
| Ordinary symbol strings | 150,325,185 |
| Section-name strings | 26,882,518 |
| GOT/PLT and dynamic relocations, including copy relocations | 64,241,400 |
| Dynamic tags | 1,232 |
| Dynamic strings | 1,576,974 |
| Version definition and requirement records | 3,504 |
| **Union B** | **462,778,637** |

The merge join needs one additional observation: each generated object adds
only a31-byte `.comment` merge input, alignment one and entry size one.
Main's `.ident` transfer supplies its29-byte identifier plus leading/trailing
NULs; binder supplies the accepted section inventory. These entries cannot
raise an existing fixed group's alignment. Add62 bytes to the fixed merge
allowance, in addition to their original payload already charged above.

The reviewed layout transfer establishes Aeh=8. Binder's192-byte EH frame
supplies at most48 entries, one section and five FDEs, yielding743,934 edited
bytes and119,668 header bytes. The five FDEs come from the accepted binder
frame inventory; a byte-length bound alone would not justify that exact count.
The full edited contribution includes the three synthetic PLT templates.
Property rewrite adds296 plus the binder's48 original property bytes.

The [copy/optional transfer](retained-linker-layout.md#copy-storage-and-optional-section-joins)
supplies the copy and interpreter terms. New build-id/package notes, SFrame,
CTF and attributes contribute zero. The
[selected defaults](retained-linker-defaults.md) exclude compression, packed
relative relocations, STABS rewriting and script/legacy-constructor data.
Existing notes and ordinary debug bytes remain in the original input charge.
Selected x86 relocation rewriting changes existing contents; its reach and
semantic validity remain separate obligations.

Each dynamic or ordinary table uses its established component formula.
GNU hashing uses H=221,088, exponent21 and32,768 bloom words; both hash formats
are charged. The ordinary symbol formula pays all three output traversals.
The dynamic relocation union already contains24H copy-relocation bytes; the
copy-storage row is its separately allocated target, so neither is omitted
or confused with the other. Hidden ordinary tables are included in B even
where they are not mapped input payload; overcounting them is conservative.

## Address and file positions

The [effective-alignment and mapping transfer](retained-linker-layout.md)
establishes **A=4096**, Aeh=8 and convergence in at most two mapping iterations
for this input family. Substituting that alignment into the existing
virtual/file transfer gives:

```text
padding = (I + S + 5)(A - 1) + 32768 = 400,695,758
Hfile   = 64 + 56T                  =   8,226,912
V       = Hfile + B + padding       = 871,701,307
Vtrial  = 2V                       = 1,743,402,614
Bfile   = B + padding               = 863,474,395
F       = Hfile + (S+1)(V+A) + 4Bfile + (3N+5)A + 64N
        = 42,687,993,785,710.
```

All logical bytes are conservatively charged as file-backed for Bfile, with
all layout padding added. The large F intentionally recharges a full virtual
span for each possible load segment; it is a representability envelope,
not an estimated output size, disk requirement or physical-memory gate.
Both the discarded-trial address arithmetic and file-offset arithmetic fit
signed64. The trial span is also below signed32, but that fact alone does
**not** prove every relocation: absolute/special symbols, signed addends,
TLS-relative operands and format-specific encodings still need their source
domains and transformations.

## Evidence and remaining joins

The [offline checker](../evidence/retained-linker-join-20261018/check.py)
checks19 retained input identities, computes every row and verifies the
component count, product, String offset/reference, hash shift, version and
EH conditions. It is arithmetic reconciliation of the source arguments,
not a machine proof of C semantics. No compiler, assembler, linker, prover,
Lean build or full test suite runs. The accepted binder object is retained
and parsed directly: its192-byte `.eh_frame` has one CIE and five FDEs, each
pointing back to that CIE, with no trailing bytes. This establishes the FDE
count independently of its relocation count; the object-shape transfer gives
it the selected-family scope.

The [retained binder projection](../evidence/retained-linker-join-20261018/binder-object.json)
contains only the accepted object transfer and its named object inventory,
with its originating commit and full-record digest. Those fields were checked
equal across subsequent Gprbind buffer additions. This keeps consumers tied
to the exact object argument without invalidating them whenever an unrelated
runtime-interface record is added.

Independent combined source/arithmetic review accepted the payload-family
coverage, original-plus-rewrite accounting, section-walk substitutions and
file-padding treatment. It identified the need to establish the binder FDE
count directly; the retained-object parse above resolves that point. The
review's acceptance is limited to counts, payloads and conditional arithmetic,
with the remaining obligations below unchanged.

The effective-alignment and mapping-convergence source result is now an input
to the checker. Its sharper twelve-program-header bound does not require
replacing the valid conservative T used above. Relocation/addend legality and
complete auxiliary BFD/LD storage remain open. Finishing the selected null
linker is itself only one part of
#119; broader grammar, native/producer phase composition and useful-domain
comparison remain necessary before production changes #88–#94.
