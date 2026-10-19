# Installed Sexplib converter prefix evidence

2026-10-19, Linux x86_64, research #119. This is a new packet after frozen
`18bd02108fc2e0456f4339d3e31b593b5daab7da`. The
[research note](../../research/retained-why-sexplib-converter-prefix.md) supplies
the scoped semantic argument. The checker is an evidence-consistency check,
not an exception-effect or whole-program reachability proof.

- `sexplib0.tar.gz`, `sexplib.tar.gz`, `parsexp.tar.gz`, and their tag/retrieval
  JSON records pin the exact official v0.16.0 source commits selected by the
  installed executable's debug build paths. All six requests returned HTTP 200.
- `inputs.json` pins the executable, both retained plugins, dependencies, local
  inputs, version-string bytes, and the native export/module ranges inspected.
- `source-excerpts.json` holds 26 exact excerpts; `source-census.json` retains
  file identities, API/alias matches and all 64 Why sexp-deriving declaration
  snippets. Presence in a source archive does not imply linkage or execution.
- `registration-events.json` records the 24 source/native initialization events
  and the same-key `Of_sexp_error` shadowing. There are 23 distinct keys, with
  six enabled and 17 disabled for automatic Printexc dispatch after startup.
- `native-bodies.json` retains 50 existing-disassembly bodies, four windows and
  39 static closure records. The checker byte-matches 20,509 instruction bytes
  and the closure records to the pinned ELF. Disassembly provenance is retained;
  the old external disassembly file is not needed for subsequent checks.
- `native-census.json` records raw E8/E9 and selected RIP-relative candidates,
  aligned data pointers, and plugin symbol references. These are diagnostics;
  alias/access and dormant-API reasoning is explicit in the note.
- `result.json` and `round.json` separate the bounded converter-family result
  from the still-null exceptional charge and complete `R`.

Run from the repository root:

```sh
python3 docs/evidence/retained-why-sexplib-converter-prefix-20261019/check.py
```

This reads the pinned installed files and retained sources; it makes no network
request and starts no subprocess, target, debugger, disassembler or solver.
Its semantic status fields refer to the prose argument, rather than a theorem
proved by Python assertions. No broad tests or proof-provenance scripts changed.
An earlier excerpt-range typo and startup-window endpoint were corrected before
successful generation. One subsequent evidence update included the discovered
`add_inner` infix closure in the already inspected exported `add` block.
