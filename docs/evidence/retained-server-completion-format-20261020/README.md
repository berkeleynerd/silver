# Stock completion-format evidence

2026-10-20 UTC, Linux x86_64; #119 / #153 research only.

The [argument](../../research/retained-server-completion-format.md) bounds the
stock completion line under the named Linux CPU-accounting, libc/formatting and
source-correspondence premises. No installed kernel-source attestation is claimed.

`kernel-tag.json` preserves the public annotated tag resolution;
`kernel-inputs.json` pins each upstream source file and URL at the exact commit.
`kernel-source.tar.gz` retains those files under `source/`. `native-inputs.json` pins the selected libc,
objdump and inspected native-interface bytes; `native-disassembly.txt` records
the read-only disassembly. `inputs.json` binds repository/local inputs.
`check.py` verifies identities, source witnesses and arithmetic, with signed
conversion and generic-time64 counterexamples. Boundary examples exercise the
source argument; they do not establish the universal bound by sampling.

The code executes only Python arithmetic and file reads, plus read-only objdump
when preparing evidence. No native target, compiler, solver, proof, capture or
predecessor checker run is needed. Retained elapsed time is in `check-run.json`.
Selected project baseline for this lead-owned source argument is Astra / Extra
High; live lead settings/runtime confirmation and isolated token/cost telemetry
are unavailable. Independent review is a separate exact freeze.
