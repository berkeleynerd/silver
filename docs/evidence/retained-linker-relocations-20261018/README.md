# Selected relocation input and operand evidence

Supports [the source transfer](../../research/retained-linker-relocations.md)
for #119. `check.py` verifies the12 complete sources in `sources.tar.gz`, the
four retained input records, actual fixed input files/archive members and
accepted binder ELF. It checks original field extents, symbol domains and
merge-section offsets, then reconciles the documented reach inequalities.

`layout-projection.json` contains only the aggregate fields used here. The
checker requires equality with those fields in the live linker join; this
avoids changing a source pin for unrelated metadata. Installed paths are
read from the existing fixed-input inventory; identical bytes are required.

```sh
python3 docs/evidence/retained-linker-relocations-20261018/check.py --output /tmp/retained-relocation-replay.json
```

No compiler, assembler, linker or prover is executed. This is an offline
inventory/arithmetic check, not a proof of C control flow, symbol resolution,
instruction compatibility or complete linker capacity.

`check-unwind.py` adds the FDE range/nonoverlap and CFA operand-length census
described in the [unwind record](../../research/retained-linker-eh-frame.md).
Its supplemental `unwind-sources` files retain `elf-eh-frame.c` and the DWARF
opcode definitions, for fourteen checked sources in total. The result retains
a digest of the complete per-input range inventory; the checker reconstructs
that inventory from the pinned ELF inputs. It does not execute the CFA
expressions or infer universal unwind semantics from the inventory.

```sh
python3 docs/evidence/retained-linker-relocations-20261018/check-unwind.py --output /tmp/retained-unwind-range-replay.json
```
