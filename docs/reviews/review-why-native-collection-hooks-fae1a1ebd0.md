# Independent review: native collection-hook ownership

2026-10-19 UTC, research
[#119](https://github.com/berkeleynerd/silver/issues/119).
Frozen target: `fae1a1ebd0be76b247eae0ad8778483dbdc71cd0`;
base: `d8e9c70e373de172280b87a1459ece88114c2eaf`.

**Disposition: changes required for the four-hook null-preservation closure.**
One material correspondence gap remains. The concrete ELF, direct-reference,
source-excerpt and selected-linkage results are useful partial evidence and are
retained. This review identifies an unsupported exclusion, **not an actual
setter or a demonstrated nonnull hook**. The four-hook preservation condition
must remain until the gap is discharged.

## Material finding: computed addresses from legitimate lowering remain unjoined

The [argument](../research/retained-why-native-collection-hooks.md) at lines
87–132 moves from an exact-address census, a 128-byte neighbour window and a
fixed list of linker anchors to the conclusion that any remaining computed hook
alias would require forged or out-of-object mutation. That implication is not
established for the installed native code.

A compiler or linker can implement a legitimate source-level access to a
standalone global through a shared physical base plus an offset. For example,
the native form of a source-level `hook = callback` can be:

```text
materialize base address into register
store callback at [register + (hook_address - base_address)]
```

The base need not numerically equal the hook, lie in `0xfaaf00–0xfaaf7f`, or be
one of the eight named anchor spellings. The offset need not equal an absolute
hook address. This is a missing-case form, not a claimed instruction sequence
found in this executable. Source-level provenance does not require the temporary
machine base to represent the same source object, so such lowering is compatible
with faithful compilation and well-formed source. It cannot be excluded merely
because interpreting that machine calculation as source-level pointer arithmetic
would go outside a neighbouring object.

The [checker](../evidence/retained-why-native-collection-hooks-20261019/check.py)
lines 262–273 extracts numeric operands and single-instruction RIP-relative
targets. It does not propagate address values through registers or retained data.
The packet explicitly records that limitation. Complete decoded-byte coverage
proves correspondence of the retained disassembly to the selected image; it does
not prove that every legitimate global-address computation appears as an exact
numeric reference. A final executable can also have resolved away the original
static relocation, so the absence of a surviving dynamic relocation or external
hook import does not supply the missing static-client relation.

The selected `scanmult` witnesses do close the two identified option-variable
addresses. The equal TM-clone endpoints, `stderr` loads, GOT metadata and
AT_SECURE call also close those concrete routes. None establishes that this
finite anchor set covers every compiler-generated address base for a hook.
The absence of an overlapping named object is insufficient for that purpose.
The accepted Dynlink/dlsym capability argument closes reflective lookup; it does
not close this distinct static lowering case.

Consequently the note's null-preservation induction at lines 136–143 and removal
of the hook condition at lines 152–158 are premature. Treating all remaining
machine computations as forbidden mutation would add an opaque non-aliasing
premise to the prior faithful-runtime/no-forged-mutation boundary. No such new
premise was authorized.

**Required repair:** establish a bounded selected-source/link correspondence
covering the legitimate static clients and their lowering, or a sound bounded
installed-code address-use argument that includes these base-plus-offset cases.
The evidence must apply to the exact selected executable/plugins and inherited
loaded-code boundary. An arbitrary native alias theorem is not required, but a
wider literal-address scan or another same-name runtime search alone does not
resolve the missing implication. Until then, retain the four hooks as the native
residual and retain all successful partial evidence. The review does not start
a new native proof or broaden the inventory.

## Accepted partial findings

The packet binds the existing run `20261019T000304-fcb988ec2c03`, PID **97103**,
to the same seven selected images used by the accepted callback packet. The
24,561,432-byte `gnatwhy3` image has SHA-256
`7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368`.
Its hook addresses are ELF-relative because the executable is PIE; they are not
observed live process values.

The four direct instruction references are reads of the hook values at
`0xfaaf48`, `0xfaaf40`, `0xfaaf38` and `0xfaaf30`, at instruction addresses
`0x9c551d`, `0x9c595e`, `0x9c6b8f` and `0x9c6e01`, respectively. Independent
instruction-byte decoding confirms the RIP-relative targets. Independent
program-header inspection places each entire eight-byte cell in the writable
load segment's zero-fill suffix. These facts support initial null values and
the identified direct read behavior; they do not prove preservation against
unjoined computed writes.

The retained linkage projection reports each cell as its own eight-byte exported
GLOBAL DEFAULT OBJECT, no other overlapping named object, no selected hook
relocation/import, and no absolute stored-address match in the scanned allocated
noncode PROGBITS data. The dynamic dependency set is within the selected images;
both plugins have no DT_NEEDED entries. Allocated hook-name occurrences are the
main dynamic-string entries. Export visibility is correctly acknowledged, rather
than confused with absence of a client.

`scanmult` retains its incoming destination in one register and each conversion
arm writes one `uintnat` through that destination. The inspected source
`startup_aux.c:89–143` and installed body agree. `register_tm_clones` computes
zero from equal endpoints and returns; `deregister_tm_clones` likewise returns
on equality before calling ITM. References at `__bss_start` load the coincident
`stderr` FILE pointer instead of materializing a BSS base. The stored GOT[0]
address is `_DYNAMIC` loader metadata. `unix_environment` passes **0x17 / AT_SECURE**
to its sole getauxval call and uses the result as a secure-environment flag.
These are meaningful distinctions and should survive repair.

The timing-hook API comment is correctly treated as a client obligation, not
proof of compliance by an unknown client. Existing typed/private-state and
registered-OCaml-client preservation results are unaffected. The first-fold
Shape-buffer/cache implications remain conditional on the four-hook native join.
Complete `R` and exceptional identifier charge remain null, and no ordinary-
ending nested-save, later-forest, exit/output, exception-continuation or
whole-pipeline closure follows. The 66 roots, 966 binders, 315 insertion/reset
bound and accounted endpoint **61,641** remain unchanged;
`counter_end <= 63,573 + 2R` is still conditional.

## Exact review inputs, checks and round record

Read all ten changed files: the source note and nine-file
[evidence packet](../evidence/retained-why-native-collection-hooks-20261019/README.md),
including the full checker, manifest, capture binding, linkage/code projections,
source excerpts and result/round records. Reused the accepted callback and
save-preservation source/capability findings, with direct inspection of their
reflection, fixed-code and outstanding-native-boundary wording. Reused the
previously inspected null definitions and guarded call sites; no broader source
closure is inferred from them.

Independent checks verified **eight input identities**, **seven mapped image
identities**, **three capture metadata members**, **three complete source member
identities and LF excerpts**, and **179 retained instruction-record byte witnesses**
(including overlapping records across projection categories). Four loads were
independently decoded and four zero-fill cells checked. The successful check took
**1.0397145689930767 seconds**. Its first attempt had a reviewer-only excerpt
slicing error that appended an extra newline beyond `envir.c` EOF; exact LF
chunks fixed that check. No target evidence or implementation repair resulted.

Reused the successful author full census, **1,102,177 instructions / 4,986,162
bytes**, measured at **11.11612633599725 seconds**, and the default projection
check at **1.5019439779862296 seconds**. The full census and default checker were
not rerun. The author extractor was inspected; a narrow read of existing text
was used while assessing its address-class coverage. No target, debugger,
disassembler, new capture, native compiler, solver, build, Lean, predecessor
checker or corpus replay ran. No live hook value was observed.

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime model/effort confirmation,
token usage and monetary cost are unavailable; no live-setting change is claimed.
Selected author setting was also Astra / Extra High, as reported by the lead;
its recorded inspection interval was 682 seconds. Review inspection interval:
**2026-10-19 11:54:20–11:58:13 UTC**, **233 seconds**, excluding report preparation
and commit. These clock intervals are not measured model compute times.

Only this report is committed. No target implementation, Oracle, launcher, root
index, issue, session memory or CLI memory changed. The lead owns finding
integration, any authorized focused repair and publication.
`git diff --cached --check` passed before the report commit.
