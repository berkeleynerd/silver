# Selected ELF unwind sizing transfer

2026-10-18, Linux x86_64, research [#119](https://github.com/berkeleynerd/silver/issues/119).
This continues the [link-input](retained-link-inputs.md) and
[dynamic-section](retained-linker-dynamic-sections.md) transfers through
ordinary DWARF `.eh_frame` parsing, editing and header sizing. It gives
conditional per-section and shared-table inequalities, not a complete link
capacity verdict. The [pinned source packet](../evidence/retained-linker-eh-frame-20261018/README.md)
uses the same Binutils relevant-behavior premise. No native tool ran.

## Inputs and invocation boundary

For every nonempty input or linker-created `.eh_frame` section that can
reach this path, retain its original byte size B, entry count E, CIE count C
and relocation count R. Count the zero terminator as an entry. For the
selected final link, F bounds the total number of kept FDEs across all these
sections, including linker-created PLT FDEs. Let A be the output section's
alignment in octets. The selected x86 target has eight-byte addresses and
one octet per target byte. Compact unwind, relocatable-link and section-GC
paths are excluded by the selected configuration.

The ordinary emulation calls `bfd_elf_discard_info` before remapping
segments (`ld/emultempl/elf.em:179–190`). Its `.eh_frame` loop parses and
edits each mapped input once, then pads preceding sections to their output
alignment (`bfd/elflink.c:15235–15305`). The ordinary `lang_process` calls
the after-allocation hook once (`ld/ldlang.c:8751`). Its separate object-only
link invocation at line11093 is excluded by the no-LTO/no-`.gnu_object_only`
input premise. x86 adds no after-allocation override. Source emission and
the fixed-input inventory must supply the actual B/E/C/R/F/A values;
final file size alone does not bound an event count across repeated phases.

Successful parsing also requires valid emitted DWARF and relocations. In
particular, the small fields in `eh_cie_fde` require CIE augmentation-string
length including NUL at most7, augmentation-data length at most31, and
personality/LSDA offsets at most255 (`elf-bfd.h:345–445`). The CIE initial
instruction length stored in an unsigned byte must fit255 before trimming
padding (`elf-eh-frame.c:31–58,893–897,1009–1018`). LEB values and supported
encodings must have their documented meanings. These are emitter/fixed-byte
obligations; this packet does not infer them from a small total section size
or claim that arbitrary valid DWARF satisfies the internal bitfields.

## Parser storage and local editing

The counting pass consumes at least four bytes per counted entry and never
counts more than one terminator. Hence `1 <= E <= floor(B/4)` and `C <= E`.
It explicitly requires B to fit unsigned32 (`elf-eh-frame.c:625–659`).
Under the valid-entry premise, every original offset and `4+hdr_length`
fits the same bound. The entry metadata request is

```text
sizeof(eh_frame_sec_info) + (E-1)*sizeof(eh_cie_fde),
```

and the local CIE request is `C*sizeof(cie)` (`:661–669`). On Linux LP64
the declarations give48 bytes per entry,64 bytes for the one-entry header,
and136 bytes per CIE: respectively `16+48E` and `136C`. These products use
size_t because of `sizeof`; their individual request and pointer-difference
conditions are independent of total memory use. R must fit unsigned32 for
`reloc_index`; relocation-cookie/symbol arrays remain separate consumers.

The optional `DW_CFA_set_loc` list has at most `floor(B/3)` elements: each
instruction needs its opcode and a supported address field of at least two
bytes. Its `(count+1)*sizeof(unsigned int)` request therefore fits64-bit
size arithmetic under the B condition, as do its32-bit count and offsets
(`:1018–1040`). Valid CFA decoding remains a content premise.

A retained CIE grows by at most four augmentation bytes; an FDE by at most
one (`:286–325`). Entry trimming and removal only decrease original payload.
Editing aligns each retained entry to at most eight bytes and finally aligns
to four (`:1593–1630`). An upper bound covering both output and intermediate
`offset + alignment - 1` operations is therefore

```text
local_edited_bytes <= B + 11E + 3.
```

The additional cross-input padding costs at most `A-1` per input section.
Require A to be a power of two with exponent at most30: the caller computes
`1 << alignment_power` as signed int before converting to unsigned. A
sufficient condition for this local editing/serialization chain is

```text
B + 11E + A + 2 <= 2^32-1.
```

It bounds every offset/alignment intermediate, the cross-input rounded size,
the unsigned32 `new_size` and the next-entry offset, including the final
section-size narrowing in `next_cie_fde_offset` (`:328–339,2010–2023`). The
cross-input bit mask itself is unsigned32, another reason not to treat the
64-bit section-size destination as proof of wider supported editing.
For N sections, summing these upper bounds prices their contribution to
the single output `.eh_frame` payload. It is not a total-allocation gate.

## CIE merging and header storage

Only a kept FDE calls `find_merged_cie`; it first increments the shared FDE
count (`:1582–1585`). A CIE already kept or merged immediately returns.
Otherwise one hash lookup can insert one136-byte copy (`:1210–1337`). Thus
the total number of CIE copies and the hash's distinct live entries are at
most F, even when the raw input contains unused CIEs. The initial request1
selects seven pointer slots. There are no entry deletions before whole-table
destruction.

The packet checks libiberty's actual prime table and insertion/growth code
(`libiberty/hashtab.c:134–195,517–575,633–695`). At `F <= 536870911`, twice
the live count is at most1073741822, so the largest selected prime is at
most2147483647. The unsigned32 probe index plus its secondary step is at
most `2p-3`, which fits. Size_t load-factor products, occupancy counters and
the individual `8p`-byte pointer request fit LP64. Hash/search/collision
arithmetic is intentionally modular where it does not control allocation
or lookup equality. Destruction frees the copied CIEs and pointer table.

The same F bound addresses a separate32-bit intermediate in header sizing:

```text
F <= floor(((2^32-1)-4)/8) = 536870911
header_bytes <= 8 + (4 + 8F)
search_array_bytes <= 24F.
```

`fde_count` and `array_count` are unsigned32; the parenthesized header
expression is evaluated at that width even though `sec->size` and the
writer's `size` are64-bit (`elf-bfd.h:455–501`,
`elf-eh-frame.c:1668–1682,2477–2487`). The final eight-byte addition can
exceed32-bit without overflowing its64-bit destination. The search array
contains three64-bit values per FDE and is allocated once on the successful
allocation path (`:1975–1984`). On allocation failure, later attempts are
resource outcomes; no successful lifetime creates a second live array.
Exactly one array entry is appended per kept, written FDE (`:2218–2227`),
under the phase/emission premise above.

## Relocation reach remains an independent obligation

The writer sorts the search array and encodes function/FDE addresses relative
to the output `.eh_frame_hdr` address. It explicitly rejects a relative
entry outside signed32, or overlapping FDE ranges (`:2523–2557`). Neither
the count bound nor the local byte bound establishes these conditions.
Final-image layout must show the relevant addresses fit the signed range,
that address-plus-range arithmetic does not wrap, and that kept function
ranges do not overlap. The header's own encoded pointer and other unwind
relocations also need their target encoding/reach arguments.

## Fixed-input field and entry join

The [fixed-byte check](../evidence/retained-linker-eh-frame-20261018/fixed-input-check-results.json)
re-extracted all nonempty `.eh_frame` sections from every fixed ET_REL input
in the retained link inventory, verifying complete file/member identities.
It charges both explicit libgcc/libgcc_eh occurrences and every archive member.
DSO sections are excluded because they are not mapped into the output. Earlier
archive rescans cannot create another mapped instance of an already loaded
member. Generated Main/binder inputs and linker-created sections remain separate.

The retained888 distinct sections give these weighted upper inputs:

| Quantity | Fixed contribution |
| --- | ---: |
| Nonempty section occurrences |1175|
| Original bytes |551,576|
| Entries including terminator |16,297|
| CIEs |1348|
| FDEs before discarding |14,948|
| Zero terminators |1|
| Largest individual section |17,776 bytes|
| Largest input alignment |8 bytes|

Parsing the retained CIE/FDE headers establishes maximum augmentation-string
length5, augmentation-data length11, personality offset11, initial CIE
instruction length11 and LSDA offset9. Thus those fixed inputs fit the narrow
fields identified above; the check does not merely compare total byte sizes.
It does not interpret the CFA instruction stream, verify relocation targets or
establish nonoverlapping final function ranges.

If generated/linker contributions keep the output alignment at8, the fixed
edited payload is bounded by `551576+11*16297+10*1175 = 742593` bytes. This
is a contribution to one output section. For a different output alignment A,
use `551576+11*16297+(A+2)*1175` instead. The kept-FDE contribution is at most
14,948 regardless of CIE/FDE removal; the final header/array must also include
generated and linker-created FDEs. These are immutable-input bounds, not an
observed whole-link result or a new language cap.

Remaining joins are generated Main/binder and linker-created unwind inputs,
remaining emitted-DWARF/relocation validity, relocation-cookie/symbol storage, shared BFD
allocation backing and the final image layout. These are required before
this transfer contributes a whole-source acceptance verdict. The broader
[capacity design](retained-tool-capacity.md) remains unfinished.

Independent source review checked the layouts, counting/editing arithmetic,
hash growth and header-array lifecycle, finding no defect in these conditional
claims. It corrected the two source citations above. That review does not
establish the remaining emitter or final-layout obligations.
The fixed-byte join was added afterward and has its own retained checker scope.

## Selected function ranges and emitted fields

The later [operand/layout join](retained-linker-relocations.md) supplies
V=871,701,307, output EH alignment8 and the743,934-byte union of edited EH
payloads. The [range checker](../evidence/retained-linker-relocations-20261018/check-unwind.py)
now independently reads the original ELF relocation targets and function ranges
for all888 fixed EH sections and the accepted binder object. It rehashes the
fixed files and archive members and retains fourteen complete source files
across its shared and supplemental packets. No native tool runs.

There are **14,267 fixed FDEs** and **five binder FDEs** in this unweighted input
census. Earlier14,948 remains the conservative fixed processing-occurrence
bound, so these counts do not contradict one another. Every original FDE:

- uses four-byte signed PC-relative initial-location encoding (`0x1b`);
- has exactly one PC32 initial-location relocation naming a local symbol in
  a defined executable section, independent of global symbol resolution;
- has a positive, literal function range, with no relocation on that range;
- starts and ends inside that section, which is neither mergeable nor TLS;
- does not overlap another FDE range in the same input code section.

The largest range is36,684 bytes. The checks cover1,080 code sections including
binder. The CIE and FDE instruction walks consume163,618 CFA operations, using
the operand-length grammar of `skip_cfa_op` (`bfd/elf-eh-frame.c:345–418`);
there is **no DW_CFA_set_loc**. Expression blocks are skipped by their checked
length, not interpreted as a proof of unwinder semantics. All present
personality encodings are indirect signed PC-relative32 (`0x9b`), and all
present LSDA encodings are signed PC-relative32 (`0x1b`). These exact fixed
streams retain their meaning under the accepted fixed-input projection;
their variable address fields have the separate relocation bounds.

Input code mapping concatenates these nonmerge, non-TLS sections into disjoint
output intervals. There is no overlay, code-folding option or executable merge
section in the selected descriptor. The selected x86 GOT/TLS instruction
rewrites replace bytes in place. They do not change these original function
intervals. Removing an EH record or merging a CIE cannot introduce a new
function interval. This transfers the within-section nonoverlap check to the
fixed and binder output functions.

Main contributes its single source-derived interval, of length at most26,
in a separately mapped `.text` input. It has no personality, LSDA or set_loc.
The three possible linker PLT FDEs each cover their separately generated
`.plt`, `.plt.got` or `.plt.sec` section. Their range fields are exactly the
associated PLT section sizes (`bfd/elfxx-x86.c:2693–2723`); their start fields
are the corresponding output-section address minus the EH field address
(`:2903–2976`). The fixed/generated input census has no other PLT code input,
and the selected script keeps these output families separate. Therefore these
ranges are disjoint from each other and from ordinary input code. Each PLT
range fits unsigned32 because its section payload is already bounded by the
joined payload union, itself below signed32.

The remaining writer fields now have concrete domains:

| Field | Source and bound |
| --- | --- |
| Edited entry length and CIE back-reference | Nonnegative offsets within the743,934-byte EH output bound; `elf-eh-frame.c:2010–2027,2145–2154`. The output EH walk follows link order (`elflink.c:15237–15280`), and CIE merging selects an earlier representative (`elf-eh-frame.c:1302–1335`); the reference is a backward distance. |
| FDE initial location | The writer adds old offset minus new offset to the already relocated PC-relative field, preserving its code target; `:2188–2207`. The result is a difference of mapped addresses and fits signed32. |
| Personality and LSDA address | The same offset adjustment preserves the relocated target; `:2100–2120,2232–2256`. The operand transfer's V+K bound covers the final relative value, including original addends. No smaller16-bit encoding occurs. |
| set_loc adjustment | Absent from all selected fixed, binder and Main inputs; PLT templates have no such opcode. |
| Header's EH pointer | The generic selected encoder subtracts the header field address from the EH address; `:2624–2632`. Both are mapped addresses within V. |
| Header search entries | Function-start and FDE addresses minus header address have magnitude at most V; `:2523–2545`. Each function start plus range is its already bounded code endpoint. |

The existing FDE-count bound covers the header count field and array indexing.
The source-derived Main interval and exact original range census above also
discharge the header writer's nonoverlap guard (`:2546–2557`); an image-span
bound alone could not do that. All edited relative fields use the intended
modular address subtraction before writing the signed displacement. No
representation limit is hidden by ignoring an overlapping range or wrapping
a growing counter.

This closes the selected range and emitted-field representation join, under
the existing input/emission/layout premises. It does not claim a new general
DWARF semantic proof or complete linker/process capacity. Symbol/instruction
compatibility and whole-source composition retain their separate records.

Independent review replayed the packet byte-equal and accepted this field/range
scope. It requested an overlap check for complete relocation fields around each
FDE range, rather than checking only one starting byte, and the explicit
output-order/CIE citations above. Both are included. No native tool ran.
