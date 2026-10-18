# Gigi helper, declaration, type and cleanup evidence

2026-10-18, Linux x86_64, Refs #119. Companion to
[the source argument](../../research/retained-backend-gigi.md).

`source-manifest.json` pins 96 complete files at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; Ada file identities also match the
previously retained complete Ada inventory, and non-Ada GCC files match the
full-source manifest independently. Its separate `silver_main_api_files` rows
pin the two selected Silver API specifications in this tree; those are not
upstream GCC files. `source-excerpts.md` retains the
referenced regions. The three remaining files are the checker, its result,
and a complete textual site inventory over the four gigi implementation
files. Inventory entries include declarations/comments: the report classifies
the reachable paths. Textual absence alone is not a complete compiler proof.

Reproduce with the pinned source checkouts available in this session:

```sh
python3 docs/evidence/retained-backend-gigi-20261018/check.py \
  --ada /tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --output /tmp/retained-backend-gigi-check.json
```

The checker verifies full-file hashes, exact excerpts, binding/temporary site
inventories, phase order, the named return and loop placement, and local
coefficient arithmetic, including scalar helper requests, protection-spine
counts, call adaptation, local type branches and String equality. It does not
establish the handwritten reachability
argument, installed-source correspondence or transitive allocation bounds.
No compiler, solver, Lean build, full test suite, assurance audit, macOS run or
CI run was performed for this record. Native capture evidence was reused
without rerunning its successful experiment.

The final native-root extension checks the diagnostic guard, strict capture,
type-bound association cache and O0 external-body gate. It records the source
argument's `3*(D_i+J_i)` extra scalar diagnostic visits and
`32*T_signed+16*T_literal` normalized type-bound syntax visits. The latter uses
the native expansion report's sixteen-node final endpoint shape, not an
assumption of disjoint semantic descendants. The checker also verifies absence
of `Inline_Always` in the selected runtime and Silver API specifications.
Compiler-generated size wrappers remain a separate layout obligation; neither
the API scan nor these arithmetic checks close the whole backend.

The initializer-order extension pins the two lazy constant/renaming callers,
the earlier entity-association return, ordinary initializer-before-definition
order, EWA actions-before-value order and deferred initializer reuse. The
report joins those sites to the native constructor dependency argument to
exclude variable Main lazy initializer replay. It records the composed
`O_Main+32*E_Main+3*(D_i+J_i)` source-syntax visit bound, with `O_Main<=A_Main`.
These checks do not establish a bound on the resulting GCC expression graph.
The protection extension retains the actual recursively invariant arithmetic
frontier: unchanged expressions may branch, even though newly reconstructed
conversion/reference wrappers follow one spine.

The scalar-gimplification extension pins the shallow temporary replay, SAVE
resolution, raw assignment/folder entry, initial SSA context and separate
generic/Ada metadata-root sites. Its scalar-region transfer counts raw
construction before GIMPLE folder replacements. It preserves separate SSA
and VAR identity demands and adds Ada RM bounds to the size-position root
inventory. Calls, conditionals, memory/aggregate adaptation and the final
folded GIMPLE count are not closed by that restricted transfer.

The concrete null-body extension follows the source fixture through initial
GIMPLE, CF/EH, CFG cleanup and initial SSA. It pins the O0 null-label and
return construction, the unchanged EH statement cases, CFG merge guards,
the mandatory return memory use and its default SSA name. Its arithmetic
records the five-statement CF graph, three-block/four-edge initial CFG and
one SSA memory-use entry. The source argument distinguishes live graphs from
cumulative allocation and preserves fixed pass containers. No pass execution,
whole native capacity predicate or compiler-success claim is added.

The excerpt reader uses literal LF boundaries. An earlier reader used Python
`str.splitlines()`, which also counted GCC form-feed section separators and
shifted some displayed line numbers. The corrected excerpts retain the same
full-file identities; the null specialization's references were reconciled
against LF lines. This correction changes evidence presentation, not compiler
inputs or any claimed pass result.

The O0 continuation extension pins mandatory lowering, warning ranger setup,
zero-real-partition out-of-SSA and the removal of the terminal bare return
before body RTL expansion. Its result remains conditional on the selected
options, default instruction-selection hook and whole-unit preservation.
The retained typed container requests are not a complete setup byte bound.
The checker records four possible ranger instances, the expansion-time
six-slot block-index ceiling, and the two-label/three-note body contribution.
Function entry/exit, subsequent RTL passes and linker costs stay separate.

The selected x86 framework extension continues through the end of pass_expand.
It retains no dynamic pseudo or stack-slot demand for the null signature,
while charging function/block notes, the non-call-exception blockage and up to
four location-preserving O0 nops. The cumulative instruction-chain ceiling is
15 nodes, with at most two blockage nodes/two one-element vectors including
unsharing. The register-array raw subtotal is 1,782 bytes on LP64; one-time
backend, manager, allocator and later RTL/emission costs remain outside it.
The checker verifies 96 source files and 2 Silver API specifications; the 74
non-Ada full-file identities also match the retained full-source inventory.

The IRA-entry extension follows mandatory pre-allocation RTL passes, including
x86 target insertions. Leaving CFG-layout mode can split up to five edges to
preserve locations and adds a block note plus nop for each. The conditional
output grows to ten blocks, eleven edges, twelve block-index slots and 25
cumulative instruction-chain nodes, still with no dynamic pseudos or stack
slots. The one-time IRA wrapper itself has no allocation requests; lazy target
RTL initialization remains a separate fixed-witness candidate with explicit
source-independence obligations. IRA/LRA, machine frame/return generation and
output costs are not closed. The updated checker verifies 160 GCC/Ada source
files and two Silver API specifications; all 138 non-Ada source identities
also match the retained full-source manifest. No native/prover run was made.
