# Generic null-producer ALI source packet

Research #119, 2026-10-18. See the
[derivation](../../research/retained-producer-ali.md).

`identity.json` pins selected GCC sources against the retained complete source
manifest, selected SPARK sources in its previously retained archive, and the
existing installed System ALI and historical direct null probe. The archive
is copied source evidence; no compiler, GNATprove, Lean, native probe, installation
or debugger was executed for this packet.

Run from the repository root:

```bash
python3 docs/evidence/retained-producer-ali-20261018/check.py
```

`result.json` records source/hash checks, exact retained-file inventories and
conditional arithmetic. The examples deliberately use the historical probe's
A/C shape and are **not** a production GPR invocation reconstruction. The actual
production arguments/configuration descriptor remains required. The file
bounds are conservative sufficient bounds, not actual output-size predictions
or a new source/path/aggregate-memory admission rule.
