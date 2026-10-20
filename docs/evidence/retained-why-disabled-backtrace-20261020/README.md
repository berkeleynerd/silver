# Retained disabled-backtrace component

2026-10-20, #119 / #153, Linux x86_64. This packet supports the
[source/control and resource interface](../../research/retained-why-disabled-backtrace.md)
for the selected five cuts and continuation. It does not certify all exception
diagnostics, whole-suffix call multiplicities or complete capacity.

Run the focused retained-input check from the repository root:

```sh
python3 docs/evidence/retained-why-disabled-backtrace-20261020/check.py
```

The checker regenerates these small evidence projections from retained inputs:

- `source-client-inventory.json` and `source-witnesses.json`: lexical source
  inventory and exact archive/member/line excerpts. Reachability is the reviewed
  source argument, not a property proved by lexical matching.
- `input-attachment.json`: joined accepted five-process metadata. No old checker
  or raw capture observer is replayed.
- `native-bodies.json`, `native-control.json`, `native-frames.json`: selected
  retained native text, recording references and reviewed frame multiplicities.
  Every retained instruction byte is compared with the pinned ELF via its load
  segments. Native text is read from the existing `/tmp` disassembly; no new
  disassembler is run.
- `fallback-layout.json`: direct ELF data decoding of the fixed 59-byte string,
  its format node, selected native switch arms and ignore continuation.
- `inputs.json`, `result.json`, `round.json`: exact inputs, conditional component
  results and author/validation measurements.

The external ELF and retained disassembly paths are those of the shared Linux
installation, not an executable rebuilt in this worktree. Source archives are
reused by exact identity. The checker does not execute the target, fetch sources,
run solvers/proofs or infer semantic refinement from byte equality.
