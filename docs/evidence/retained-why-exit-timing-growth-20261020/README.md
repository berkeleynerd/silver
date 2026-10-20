# Retained exit timing-table growth packet

Author packet, 2026-10-20, #119 / #153. See the
[source and control argument](../../research/retained-why-exit-timing-growth.md).
This packet owns only post-cut timing-update counts, key/counter domains,
table-mutation preservation, iteration inputs and named local individual
requests. Parent-owned formatter, runtime-service and exit composition are
not closed here.

- `inputs.json` pins the imported accepted results/notes, retained source
  archives, selected source ranges and native symbols.
- `source-census.json` retains the identities of all 528 Why3 ML/interface
  files in the archive and every timing/Stats lexical reference. The note
  classifies the actual clients, including the exported mutable alias.
- `source-witnesses.json` contains the exact source excerpts used by the
  argument. `native-witnesses.json` retains complete selected bodies, verified
  against the existing ELF, plus native timing literals and reviewed sites.
- `result.json` retains both `15E+3` and the sharper accepted-directive `D+3`
  bounds, all 26 possible keys, per-key counters, table and traversal bounds,
  individual-request projections and explicit incomplete-capacity flags.
- `round.json` records selected settings and measured focused-check time;
  `manifest.json` binds this authored packet and its research note.

The focused author freeze check is:

```sh
python3 docs/evidence/retained-why-exit-timing-growth-20261020/check.py --write
```

For independent read-only replay, omit `--write`. Optional `--elf` and
`--disassembly` paths must identify bytes with the same pinned identities.
The default paths point to retained local inputs; no source fetch, native
target, capture, disassembler, proof/solver or predecessor checker is invoked.
Do not rerun a successful check merely to fill a reporting field.

An initial setup attempt stopped before producing results because the selected
`Fun.ml` excerpt ended at line 41 while the retained file ends at line 38.
The range was corrected to lines 21–38. The round record retains this failure
separately from the successful freeze check; no successful input was replayed.

The checker verifies identities, source/native witnesses and arithmetic. It
does not mechanically prove the source call graph or mutation induction and
does not establish compiler refinement, runtime-service capacity, formatter
output, full native stack, successful exit or physical sufficiency. All such
claims retain their named owners and premises. Independent review is pending
at author freeze.
