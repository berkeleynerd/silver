# Gigi structural and cleanup evidence

2026-10-18, Linux x86_64, Refs #119. Companion to
[the source argument](../../research/retained-backend-gigi.md).

`source-manifest.json` pins twelve complete files at GCC
`6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`; Ada file identities also match the
previously retained complete Ada inventory. `source-excerpts.md` retains the
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
coefficient arithmetic. It does not establish the handwritten reachability
argument, installed-source correspondence or transitive allocation bounds.
No compiler, solver, Lean build, full test suite, assurance audit, macOS run or
CI run was performed for this record. Native capture evidence was reused
without rerunning its successful experiment.
