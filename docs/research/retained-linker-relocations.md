# Selected linker relocation operand bounds

Research for #119, 2026-10-18. The selected null family now has a retained
input census and a numerical relocation-reach transfer. The transfer treats
merged-section addends, GOT/PLT entries and TLS endpoints separately. It does
not infer relocation legality from image size alone. Symbol resolution and
instruction compatibility remain distinct joins; this record does not complete
the linker or change admission.

## Input domains

The [offline checker](../evidence/retained-linker-relocations-20261018/check.py)
rehashes all15 fixed files and1,161 archive members, then reads their ELF64
headers, symbols and RELA records directly. It also rehashes and reads the
accepted binder object. These are unweighted inventories of the actual input
bytes; earlier occurrence multipliers remain relevant to processing counters.
The three DSOs are excluded from the input-relocation scan because final linking
does not process their contents or relocations (`bfd/elflink.c:11416–11421`).
Their symbols still participate in the existing dynamic-symbol argument.

There are1,166 fixed ET_REL inputs,40,885 symbol records and462,574 relocations.
Binder adds179 symbols and95 relocations. Every defined symbol's value is no
greater than its input section size. Undefined and ABS symbol values are zero;
COMMON, large COMMON and extended symbol indices are absent. Every original
relocation field lies inside its target section. This does not by itself check
the wider instruction window used by TLS or GOT relaxation.

| Original relocation family | Fixed occurrences | Binder occurrences | Fixed addend range |
| --- | ---: | ---: | --- |
| 64-bit absolute |117,805|1|−8 through2,019,040|
| PC32 |54,614|68|−20 through2,019,036|
| PLT32 |29,776|26|−4|
| GOTPCREL |7|0|−5|
| Unsigned32 |258,168|0|0 through293,932|
| TLSGD |243|0|−4|
| TLSLD |2|0|−4|
| DTPOFF32 |23|0|0|
| GOTPCRELX |1|0|−4|
| REX_GOTPCRELX |1,935|0|−4|

Binder's PC32 addends are−8 through962; its absolute addend is zero and
PLT32 addends are−4. All fixed unsigned32 relocations name defined sections
and have nonnegative addends. The23 DTPOFF32 references name TLS sections.
The common original absolute-addend bound is **K=2,019,040**.

Main is supplied by its source-derived emission transfer, not an assumed
hash-equal object. The register-only instruction stream introduces no fixup.
Selected CFI has one FDE, no personality or LSDA, and only an external PC32
reference to the function start; the other CIE/FDE lengths and code advances
are same-section differences. `gas/dw2gencfi.c:2074–2131` constructs the start
reference with addend zero. The function's section offsets are bounded by26
bytes, including the admitted O0 location-induced nops. Optional GNU build
notes add two64-bit references to `.text`, with addends zero and its section
size (`gas/write.c:2014–2103`). Selected SFrame is disabled. Property-note
label differences and alignment produce no external reference. Consequently
Main adds only the already covered PC32 and64-bit operand forms, with offsets
at most26. Its full relocation-count envelope can remain conservatively281.

## Operand transformations

Use **V=871,701,307** from the reviewed
[payload/layout join](retained-linker-join.md). It covers section addresses,
logical lengths and offsets using the union of original and rewritten
per-item payload maxima. For a local or resolved ordinary global symbol,
the initial relocation is its defining section address plus its offset
(`bfd/elf.c:13278–13313`, `bfd/elf-bfd.h:3369–3444`). Undefined weak values
can be zero. GOT and PLT references are replaced by addresses of entries in
the separately charged synthetic sections (`elf64-x86-64.c:3597–3778,
3852–3895`). Dynamic external addresses are carried in output relocations,
not treated as known small addresses in this executable. Applying the reach
transfer requires that each resolved operand follows one of those domains;
existence and compatibility of those resolutions are not proved by this census.

Merged constants need a different addend argument. All113,432 references to
merge-section symbols have `st_value+addend` inside the original section,
including its end. `_bfd_merged_section_offset` maps that original position
to an offset in the representative output (`bfd/merge.c:1133–1181`). The local
symbol helper then subtracts its old relocation and adds the representative's
address to the rewritten addend. Therefore **relocation plus rewritten addend**
is the mapped target address. The rewritten addend itself need not remain
within K. The census does not reuse the original bound after that rewrite.
Non-section merge symbols are adjusted to their representative offsets during
symbol processing (`bfd/elflink.c:3463–3478,11494–11500`); an unchanged original
addend is then charged separately.

For ordinary PC-relative relocation, the field is target plus addend minus
place. The selected howtos have no in-place source bits to add; the generic
writer subtracts the containing section address and relocation offset
(`bfd/reloc.c:1151–1195`, `bfd/elf64-x86-64.c:52–143`). Two addresses in
`[0,V]` give a difference in `[-V,V]`. Adding an unchanged original addend
requires at most **V+K=873,720,347** in magnitude. A mapped merge target needs
only the address difference. Original unsigned32 references are nonnegative
and at most **V+293,932=871,995,239**, below unsigned32.

TLS uses an endpoint, rather than two independent positive V charges.
The selected Linux x86 target uses `static_tls_alignment=1`, the generic
default (`bfd/elfxx-target.h:602–603`, instantiated before the FreeBSD/Solaris
overrides in `elf64-x86-64.c:6413–6460`). Consequently the final-link code
aligns the TLS end to the TLS section's alignment, then sets `htab->tls_size`
to end minus base (`bfd/elflink.c:13144–13171`). The census checks that fixed
TLS inputs have alignment at most8; neither generated object adds TLS.
The reviewed layout has no larger TLS alignment override. The x86 thread
offset subtracts that size plus the TLS base (`elf64-x86-64.c:3147–3160`).
Thus the subtracted endpoint is at most V+7; retaining V+15 is conservative.
The16-byte override later in the source belongs to Solaris and is not used.
DTPOFF subtracts
the TLS base (`elfxx-x86.c:78–85`). Thus thread-relative values have magnitude
at most **V+15=871,701,322** before any applicable original addend. GD-to-LE
rewrites directly write this thread offset; GD-to-IE writes GOT address minus
instruction place and a bias at most13. LD-to-LE removes the paired call;
the remaining DTPOFF follows the same endpoint rule
(`elf64-x86-64.c:4174–4269,4760–4844,4884–5028`). These are bounds on numerical
operands, conditional on the selected TLS symbols and instruction forms.

GOT relaxation can replace an original GOT reference with PC32, unsigned32
or signed32. Absolute replacements clear the addend and check the proposed
field before committing the conversion; a failed optional conversion leaves
the GOT reference (`elf64-x86-64.c:2075–2124,2210–2261,2410–2465`). The original
GOT entry is already charged. The new PC32 operand follows the ordinary
address-difference domain, including its one-byte place adjustment.

Synthetic PLT writers also have direct32-bit stores. GOT/PLT address differences
plus instruction biases are bounded by V+16. The backwards PLT0 displacement
is an offset inside the charged PLT section. Charging both global and local
IFUNC alternatives bounds its relocation index by H+R=270,446
(`elf64-x86-64.c:5200–5333,5665–5745`), without needing to reuse the separate
empty-local-IFUNC result.64-bit dynamic relocations
carry either zero/original addends, a resolved address, or a TLS difference;
these same domains fit their signed addend and unsigned address fields.
Intentional unsigned subtraction represents negative displacements modulo2^64;
it is not a growing capacity counter or an unchecked allocation product.

A common conservative arithmetic envelope is

```text
2V + K + 15 = 1,745,421,669 < 2,147,483,648.
```

The checker verifies this and the sharper unsigned32/index conditions. This
is a field-representation envelope, not a memory or executable-size budget.

## Scope and remaining joins

The packet retains12 complete upstream sources, input identities, an immutable
projection of the numerical layout fields and the full census. Its checker
compares that projection against the current aggregate, so unrelated evidence
metadata does not require repinning the arithmetic. No native tool ran.

Independent source/arithmetic review accepted the corrected packet and replayed
it byte-equal. It identified the Solaris-only TLS alignment citation and the
need to charge local IFUNC alternatives in the PLT index. The selected Linux
alignment census and H+R index above resolve both; the common reach envelope
is unchanged. Acceptance is limited to the stated conditional transfer.

To claim complete relocation legality, finish the source transfer from the
selected symbol-name/binding and fixed instruction inputs to successful
resolution, TLS-transition compatibility and any edited EH field semantics.
A retained successful fixed link can support that transfer if its read
projection excludes variable Main code lengths except through the bounded
address operands above. It cannot replace the transfer with another sample.
Complete remaining linker/process allocations and broader native/producer
composition separately. #119 and production #88–#94 remain unfinished.
