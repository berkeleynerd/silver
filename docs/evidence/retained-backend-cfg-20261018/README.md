# Initial CFG cleanup and loop-discovery evidence

Source pin: GCC `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`.
Date: 2026-10-18. Native analysis host: Linux x86-64.

The [component report](../../research/retained-backend-cfg.md) supplies the
manual source/reachability argument and identifies unresolved interfaces.
This package checks source identity, retained excerpts, selected source guards
and finite arithmetic. It does not execute a compiler, test programs, proof
solver, Lean, complete audit, macOS or CI.

Artifacts:

* `source-manifest.json`: full-file sizes and SHA256 hashes, independently
  reconciled with the pinned source archive's retained `manifest.json`.
* `source-excerpts.md`: numbered source excerpts supporting the report.
* `checks.json`: offline check result and explicit open interfaces.
* `check.py`: standalone reproducer outside the proof-provenance scripts tree.

Reproduce against the existing source copy:

```sh
python3 docs/evidence/retained-backend-cfg-20261018/check.py \
  --gcc-root /tmp/silver-backend-compose-20261018/full-source \
  --output /tmp/retained-backend-cfg-check.json
```

The source copy's top-level `manifest.json` identifies the archive URL and
commit. The reproducer checks every consumed source against both that manifest
and this package's full-file identities. `--capture` was used only to create
these initial text artifacts; it refuses to overwrite existing artifacts.
No successful compiler/proof capture was repeated for this increment.

The small tree enumeration checks the ancestor-slot arithmetic on 5,913 tiny
rooted trees; it does not validate GCC loop discovery or replace the general
counting argument. Representative arithmetic likewise does not prove the
matcher bounds, cleanup termination, dominator correctness, or a whole-pipeline
capacity predicate. In particular, the cumulative signed `graphds_domtree`
marker is retained as an open obligation.
