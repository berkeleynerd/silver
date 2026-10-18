# Literal linker: consumer-specific signed reach

2026-10-18, research [#119](https://github.com/berkeleynerd/silver/issues/119).
The accepted [relocation operand argument](retained-linker-relocations.md)
already bounds each selected address difference by V, the retained image
endpoint. Its common arithmetic check uses `2V+K+15`, which is stronger than
those individual sufficient conditions require. This packet takes the maximum
of the established consumer bounds instead:

```text
max(V+K+15, V+16) <= INT32_MAX.
```

The retained fixed-input census has K=2,019,040, so this is `V+K+15`.
It changes only the inherited common signed-relocation check; the unsigned
fields, PLT index, Main reach, EH, layout-trial arithmetic, individual requests
and other linker conditions remain unchanged. The existing packet and its
5,000-call failure remain historical evidence. This new conditional rule is
not adopted by the aggregate or production admission. Independent review is
pending; complete literal-pipeline capacity remains unestablished.

## Why one V is enough for the selected consumers

This refinement inherits the exact source/descriptor, complete fixed-input
census, successful symbol-resolution and instruction-compatibility transfers
of the [literal linker join](retained-literal-linker.md), including the
no-LTO/no-plugin, selected Linux x86-64 and fixed file lookup premises.
It changes no symbol domain or input object. The source arguments and complete
source capsules are pinned by the [evidence packet](../evidence/retained-literal-relocation-refinement-20261018/README.md).

For a,b in [0,V], `-V <= a-b <= V`. This follows from a>=0, b>=0 and their
individual upper bounds; using `abs(a)+abs(b)` would unnecessarily charge 2V.
For a TLS endpoint b in [0,V+15], the same argument gives
`abs(a-b) <= V+15`. An independently retained addend of magnitude at most K
then adds K by the triangle inequality. These interval facts apply to the
resolved operands, not arbitrary unreconciled ELF symbol/addend fields.

| Consumer | Sufficient absolute magnitude |
| --- | ---: |
| Ordinary PC-relative fixed relocation | V+K |
| Mapped section-merge target minus place | V |
| Thread-relative TLS endpoint, with an applicable original addend | V+15+K |
| Dynamic TLS endpoint, with an applicable original addend | V+K |
| GD-to-IE instruction adjustment | V+13 |
| Optional GOT-to-PC32 adjustment, conservatively retaining K and the place adjustment | V+K+1 |
| Synthetic PLT address differences and instruction biases | V+16 |
| EH relative fields | V+K |
| New literal Main PC32/PLT32 fields | V+4 |

These rows reuse the operand cases in `retained-linker-relocations.md`:
ordinary and merged operands (`bfd/reloc.c:1151–1195`,
`bfd/merge.c:1133–1181`, `bfd/elflink.c:3463–3478,11494–11500`);
Linux TLS end alignment and thread offsets (`bfd/elflink.c:13144–13171`,
`bfd/elf64-x86-64.c:3147–3160,4174–4269,4760–4844,4884–5028`);
optional GOT conversion (`:2075–2124,2210–2261,2410–2465`); and synthetic PLT
stores (`:5200–5333,5665–5745`). The literal join supplies Main's source-derived
V+4 domain and the unchanged fixed Silver/binder relocation census.

The rewritten merge addend is **not** assigned the original K. The accepted
merge argument bounds relocation plus rewritten addend as one mapped target
address; the second row uses that address. Ordinary non-section merge symbols
retain their adjusted representative address with an unchanged original
addend, covered by V+K. Dynamic external addresses carried in output relocation
records are not assumed to be small known executable addresses. Their existing
64-bit/addend and resolution arguments remain inherited.

An optional absolute GOT rewrite already checks the proposed field before
commitment. Failure of that optional optimization retains the independently
bounded original GOT path; no required relocation is suppressed. The unsigned
32-bit domain `V+293932` and PLT index H+R remain separate unchanged conditions.
Symmetric magnitude <=INT32_MAX is sufficient for signed fields; the asymmetric
extra negative value is deliberately unused.

All displayed rows are dominated by `V+max(K+15,16)`. This is an algebraic
join of the existing operand contracts, not a new image-size-only legality
claim. In particular `trial_endpoint=2V` and the check `2V+A<=INT64_MAX` remain:
trial layout arithmetic has a different purpose and was not tightened.

## Callable and evidence boundary

`evaluate(raw, context, path_bytes, host_page_bytes)` recomputes the complete
predecessor result from the same actual source, checks its original envelope,
and replaces just its common signed-reach predicate. It exports the original
failed checks separately and preserves all other checks and open joins.
The pure `operand_domains(V,K)` and internal `refine(result)` functions do not
by themselves establish source/configuration correspondence.

Focused checks compare source-recognized examples and the adjacent repeated
one-byte-call boundary, exercise interval extrema and the K=0/K=1 transition,
reject altered predecessor envelope/counter state, and retain an independent
host-page arithmetic failure. They neither compile nor link the sources.
Exact results and timing are retained in the packet. No native target,
debugger, build, proof, solver or full-suite run belongs to this refinement.

The focused check passed in 4.252882 seconds. The 5,000-call example has
V=1,080,152,481: the previous common bound is 2,162,324,017, while the refined
bound is 1,082,171,536. Its other selected assembler/linker checks also pass.
For repeated one-byte calls with the same configuration, 30,653 calls pass
the local conjunction; 30,654 fail both the refined signed-reach check and
the unchanged EH signed-field check. This is an adjacent boundary of the
sufficient calculation, not an observed native cutoff or a complete-language
admission threshold.

The first check attempt had an overstrict test expectation: it required only
the common signed-reach check to fail at the upper adjacent case. Inspection
showed that the independent EH check also fails there. The assertion now
requires the signed-reach failure while retaining every other failure; no
source argument, formula or consumer check was relaxed to make it pass.

This is root-authored work; the lead's live model/effort and per-task token/cost
measurements are unavailable. Work began at 2026-10-18 22:33:58 UTC. The round
record distinguishes elapsed preparation and focused-check time. Independent
review must challenge operand-case exhaustiveness and continued applicability
of the inherited source contracts before attachment.
