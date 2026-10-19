# Matching source proof for formatter helpers

Research #119, Linux x86_64, 2026-10-19. See the
[source argument](../../research/retained-why-session-formatter-prefix.md).

Normal formatter queues and output callbacks have zero Why identifier charge
under the stated source-prefix invariant. Their missing runtime descendants do
not force a new capture. The installed Compress implementation is
`Compress_none`. **Complete R and the composed endpoint remain open**, principally
at the exceptional-unwind/registered-exception-printer boundary identified in
the note. The prior PID 97103 binder and read-coverage packets are unchanged.

- `sources.tar.gz` and `source-identities.json`: 603 Why ML/parser/C source files
  from the complete pinned `src/`/`plugins/` projection, plus 9 matching OCaml
  files. The complete projection makes the lexical inventories reproducible.
- `retrieval.json`: exact official commit URLs, results and identities for eight
  newly retrieved OCaml files; no installed tool/pin changes.
- `runtime-version.json`: prior installed-version observation, rechecked against
  this same executable's bytes, not a new tool-version execution.
- `native-source-correspondence.json`: 10 bodies / 9,110 bytes from existing
  disassembly, matched against the installed ELF as data.
- `callsite-inventory.json`: formatter setters and exception registrations,
  including lexical matches in comments/interfaces. It is not a call-graph proof.
- `check.py`, `result.json`, `round.json`: offline identities and reproducible
  evidence, scoped result and selected model/effort/timing.

```sh
python3 -B docs/evidence/retained-why-session-helper-source-20261019/check.py
```

The source and ELF check passed in **0.4404606349999085 seconds**. No target,
debugger, objdump, compiler, build, proof or solver was executed. Newly retrieved
source stays at OCaml commit `8eb41f72ded84df884c3671734c947f612091f84` (4.14.2),
already used by the accepted runtime evidence; no unverified version substitution
or claim of full binary/source refinement is made.
