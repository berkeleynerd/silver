# Fixed library producer processes

Linux x86_64, 2026-10-18, #119. Supports the
[fixed producer record](../../research/retained-producer-fixed.md#separate-fixed-library-processes).
The four units are Silver_IO and Silver_Arguments bodies, and the import-only
Silver_Output_Libc and Silver_Runtime specifications. They use the exact current
sources and phase-one ALIs retained by the
[dependency probes](../retained-producer-dependencies-20261018/README.md).
Those prerequisites were reused; no identical-success phase-one rerun occurred.

`inputs-and-outputs.tar.gz` retains reconstructed invocations, options, debugger
scripts, results/logs and five emitted `.gnat-json` files. `graphs.tar.gz`
retains all 12 graphs. `managed-runs.tar.gz` retains events and logs for the four
run IDs in `summary.json`. `archive-manifest.json` hashes every member.

Unlike the single-Main probes, these processes can generate several files.
Their Why3 command is explicitly `/usr/bin/false`. They are allowed to launch
that command asynchronously, while a debugger guard stops before any result
collection or a 63rd launch. All four reached `Why.Atree.Free` first. The raw
reader makes no inferior function calls or memory writes. The source pass
generates all entities before Free, and result collection occurs afterwards;
the records do not report proof success from this intentionally disabled backend.
No solver ran. Five files were serialized, but no results were consumed.

The fixed record explains why these separate processes are independent of Main
and why their counts must not be summed into Main's table budget. It also lists
the limitations, including capacity-changing future runtime edits and the
historical source-to-binary premise.

```sh
python3 docs/evidence/retained-producer-bodies-20261018/check.py
```

This offline check reconciles graphs, snapshots, archive hashes, disabled-backend
options, emitted JSON, managed phase success and exact reused input hashes.
It neither executes the producer nor establishes the remaining frontend,
auxiliary storage, backend or proof obligations.
