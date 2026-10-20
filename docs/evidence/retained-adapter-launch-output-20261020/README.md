# Direct server launch diagnostics evidence

2026-10-20 UTC, Linux x86_64; #119 / #153 research only.

The [argument](../../research/retained-adapter-launch-output.md) derives the
direct stock-server failure-message terms. It retains the exact libc/C-locale
and normal-service assumptions; it is not complete startup or raw-output
coverage. No production code or invocation changes.

- `check.py`: exact ELF/source reader, RIP-relative lookup decoder, RELA/RELR
  decoder, finite error-string inventory, source-order and format arithmetic
  checks. Running it compares its output to the retained `result.json`.
- `result.json`: complete inventory, instruction bytes and source witnesses.
- `native-disassembly.txt`: read-only disassembly of the lookup and strerror
  paths using the existing toolchain's objdump. No target execution.
- `inputs.json`: exact local/native input and packet identities.
- `check-run.json`: focused check result and elapsed time after source-format
  assertions were added. The earlier successful extraction took 0.077220902s;
  it is reused, not an additional native capture.

The initial extractor omitted packed RELR relocations and failed its pointer
relocation assertion. Its failure output was not retained in this packet.
Adding the selected ELF's RELR decoding corrected the reader; no native input
changed. The ordinary `objdump` command was unavailable, so the already
installed GNAT toolchain's objdump supplied disassembly. These are evidence
tooling corrections, not failures of the target or its bound.

Measured checks are ordinary Python reads and arithmetic only. Native target,
compiler, solver, proof and predecessor-checker runs: zero. The manual native
control-flow interpretation remains independently reviewable and is not
represented as a machine proof. The selected research/review baseline is
Astra / Extra High; runtime-confirmed lead settings and separate token/cost
measurements are unavailable. Round integration records the reviewer and exact
freezes separately.
