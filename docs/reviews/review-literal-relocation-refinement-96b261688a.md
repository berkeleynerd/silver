# Independent literal relocation refinement review

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
Accepted at **`96b261688a54c8e60083bc1e512e7e1e7799c5dd`**, relative to
`6c0f2ebd8f33b91497a13d953123cd157558bd37`, within the inherited selected
source/configuration and fixed-input premises. No material defect was found.
The established operand cases justify replacing the common sufficient bound
`2V+K+15` with `max(V+K+15,V+16)`. Every separate consumer check remains
required. This verdict does not adopt the refinement in the aggregate or
production admission and does not establish complete pipeline capacity.

The exact target inputs are the [refinement argument](../research/retained-literal-relocation-refinement.md)
and its [seven-file change](../evidence/retained-literal-relocation-refinement-20261018/README.md):
the argument, README.md, derive.py, check.py, inputs.json, result.json and
round.json. Review also used the pinned accepted
[relocation operand argument](../research/retained-linker-relocations.md),
[literal linker argument](../research/retained-literal-linker.md), its callable
and [independent review](../evidence/retained-literal-linker-20261018/review.md),
and the selected [EH field contract](../research/retained-linker-eh-frame.md#selected-function-ranges-and-emitted-fields).
The 12-file relocation source capsule is at binutils revision
`5e56594815854de5eca35c7c04b11705d0f19c02`; its compressed SHA-256 is
`4979e62e0a7657f16ee21747a5863c6c6362ce3a972bca599b94b2f0be9ee0eb`.
Source citations below use literal LF line numbering. The Oracle, current
source membership and all inherited source/installed-behavior premises remain
unchanged. The accepted whole fixed-input census was reused, not rerun.

Selected reviewer settings: GPT-6 Astra / Extra High, explicitly assigned by
the lead. Runtime-setting confirmation and token/cost measurements are
unavailable. Review began at the recorded 22:42:57 UTC checkpoint; source
inspection and focused validation completed by 22:44:46 UTC (109 seconds,
excluding report authoring and commit). Actual host: Linux 7.0.14 x86_64.
The isolated worktree is
`/tmp/silver-review-literal-relocation-refinement-20261018`, branch
`review/literal-relocation-refinement-96b261688a`. The child harness goal was
null. The reviewer changes only this report; target files, GitHub, Oracle,
tools/options, admission, memory and harness state were not changed.

For two independently bounded addresses a,b in [0,V], their difference is
in [-V,V]. A separately applicable original addend in [-K,K] gives magnitude
at most V+K. The inherited census bounds K by 2,019,040 and excludes other
fixed narrow relocation families. The generic relocation writer computes
value plus addend minus the section/place address (`bfd/reloc.c:1151–1192`);
the selected howtos do not add unaccounted in-place source bits. Ordinary
resolved symbols, zero undefined weak values, and substituted GOT/PLT entries
retain the previously reviewed address domains. This is a transfer from those
operand contracts, not a claim that image size alone establishes resolution
or relocation legality.

Merged-section relocations require the separate combined-target argument.
`_bfd_elf_rela_local_sym` maps the original symbol-plus-addend position, then
subtracts the old relocation and adds the representative section address
(`bfd/elf.c:13278–13310`; `bfd/merge.c:1133–1173`). Consequently relocation plus
rewritten addend is the mapped target address. The rewritten addend may exceed
K in either direction; no bound on it alone is used. Representative non-section
symbols retain the separate original-addend case. The source argument explicitly
preserves this distinction, and focused examples with rewritten addends of
magnitude V>K satisfy the mapped V bound.

The optional GOT-to-PC32 case remains covered even if the local-symbol helper
rewrites a merge addend: combine relocation and addend into the mapped target
first, then charge the one-byte place adjustment. Its V+1 magnitude is dominated
by the exported V+K+1 row. Ordinary unchanged addends use that row directly.
The conversion probes the candidate field and leaves the original GOT route
when the optional conversion overflows (`elf64-x86-64.c:2075–2124`). Absolute
signed/unsigned GOT replacements clear their addend and check before commitment
(`:2410–2465`); their rejection does not suppress a required original
relocation. Thus this refinement does not use K on a rewritten merge addend
or remove an obligatory overflow check.

TLS supplies a single subtracted endpoint. With the inherited Linux
`static_tls_alignment=1` and the accepted TLS section alignment, final linking
rounds the TLS end and sets size to end minus base
(`bfd/elflink.c:13144–13171`). `elf_x86_64_tpoff` subtracts that size and base
from the symbol address (`elf64-x86-64.c:3147–3160`), giving the retained
V+15 endpoint allowance. Any applicable original addend then contributes K.
DTPOFF uses the TLS base, so V+K suffices. GD-to-LE directly writes the thread
offset; GD-to-IE writes GOT address minus instruction place with the separate
12-or-13-byte bias (`:4174–4269,4760–4808`). LD-to-LE removes its paired call,
and the remaining DTPOFF/TPOFF cases retain their endpoint expressions
(`:4884–5028`). No second independent V is needed for these differences.
Compatibility of the selected instructions and TLS symbols remains inherited.

Synthetic PLT/GOT stores use mapped entry/address differences and bounded
instruction biases. The retained source's lazy, nonlazy, BND and IBT template
constants are at most 16 for the charged biases (`:1007–1159`), and the
writer expressions retain those domains (`:5200–5333,5665–5745`). The backward
PLT0 branch is an offset within the charged PLT section. Its relocation index
is still checked separately as H+R, covering both global and local IFUNC
alternatives. V+16 therefore remains sufficient for the signed direct stores.

The EH contract preserves final mapped code/data targets when it adjusts an
already relocated field from its old place to its new place. Such an update
does not introduce an independent third address: the old-place terms cancel.
The accepted V+K bound covers personality/LSDA fields with original addends;
mapped FDE/header differences use V. The refinement retains the independent
EH size, range, count and signed-field checks. Literal Main also retains its
separate V+4 check: variable local section offsets are part of mapped pool
targets, while direct calls have the minus-four RIP bias. Main's variable
section-relative addends are not assigned fixed-input K.

Dynamic external addresses are not treated as known small executable
addresses. The existing dynamic-relocation paths retain symbolic output records
with original addends, or local resolved-address/TLS addends, as applicable
(`elf64-x86-64.c:3701–3724,4001–4055`). Their 64-bit representation argument and
resolution premises remain separate. Intentional modular subtraction is used
to encode signed displacements, not to hide a capacity counter overflow.

All displayed signed consumers are dominated by
V+max(K+15,16). At K=0 the PLT allowance is decisive; K=1 ties it, and the
retained K=2,019,040 gives V+K+15. Using the symmetric INT32_MAX magnitude
limit is conservative at the negative endpoint. None of this tightens layout
trial arithmetic: `trial_endpoint=2V` and `2V+4096<=INT64_MAX` remain unchanged.
Unsigned32 reach V+293932, Main and EH fields, PLT indices/ranges, request
sizes, symbol/string/hash counts and host-page arithmetic also remain separate.

The callable obtains its predecessor from the pinned complete source-bound
evaluator. `refine` checks the old common bound, its predicate and the old
conjunction, copies the complete check map, and changes only
`fixed_signed_relocation_reach`. Its new conjunction still requires assembler
storage and every copied check, including the assembler-interface check.
Source identity/counts, conditions of claim and open joins are retained exactly.
The internal arithmetic entry point is correctly documented as unable to
certify source/configuration provenance on its own. Review acceptance is
supplied by this report; the evaluator's `independent_review_accepted=False`
does not self-attest it.

Independent focused validation passed **85 checks in 0.516521 seconds**,
22:44:37.760207–22:44:38.276719 UTC. It checked the 13 direct input pins through
one Context, all 12 source-capsule identities and inventory, exact predecessor
preservation, and the actual 5,000-call and two adjacent source substitutions.
Each of the **39 other linker checks** was separately made false in a coherent
predecessor interface; every failure survived the refinement. Separate
assembler-storage and host-page failures also survived. Other checks covered
mapped merge targets with addends larger than K, TLS/PLT extrema, the exact
signed cutoff for K=0/1/2,019,040, rejected negative/noninteger inputs, and
altered predecessor bound/verdict/predicate rejection. The root's successful
4.252882-second focused run and previous broad inventories were reused, not
replayed. Compiler, assembler, linker, debugger/capture, build, proof/prover,
solver and broad-suite executions were zero.

For 5,000 repeated one-byte Put calls, V=1,080,152,481. The old common bound
2,162,324,017 fails; the refined bound 1,082,171,536 and all other selected
local checks pass. At 30,653 calls the local conjunction passes. At 30,654,
both `fixed_signed_relocation_reach` and `EH_signed_fields` fail. The original
test's repaired expectation is therefore supported: it was incorrect to demand
that only the common check fail, and retaining both failures changes no
formula or obligation. These are sufficient-calculation boundaries, not native
tool failures, language limits or complete-capacity results. The existing
aggregate still has its old conservative linker result until separately reviewed
adoption; no historical result is overwritten by this packet.

The local focused driver is `/tmp/silver-review-relocation-refinement-focus.py`
(6485 bytes; SHA-256
`bd24f60e36da11418347aefbc2c8c62a556296f44316c686c0580e9564ec4e6c`), with result
`/tmp/silver-review-relocation-refinement-focus.json` (3947 bytes; SHA-256
`67dffe236b9591db025488e04d7a51bfabc9e63eba6d7aaeae8abb72b2fd9a8d`). These
are local scratch artifacts, not new repository input pins. `git diff --check`
passed for the target change. Finite arithmetic/interface checks support the
reviewed derivative argument; they do not replace its source contracts.

Aggregate attachment remains separate work. The exact selected no-LTO/no-plugin
descriptor, fixed lookup/input and resolution/instruction projections,
source/installed-behavior correspondence, production invocation/materialization,
other producer/compiler/binder phases and whole-pipeline composition remain
required. Physical-resource, RAM-admission and production-admission claims stay
false. No finding requires changing this frozen refinement before attachment.
