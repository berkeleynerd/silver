# Focused formatter-prefix repair evidence

Read the [repair argument](../../research/retained-why-session-formatter-prefix-repair.md).
Frozen base `1ad16d731098e98e94caaa91f0a39f4b58bd6eb8`, review
`6f5d6a7775a5bd421f674aa9915e0ce7a352119c`, M1 / #142. Earlier packets are unchanged.

- `ocaml-source.tar.gz` and `retrieval.json`: official same-commit source archive,
  HTTP 200; 5,510,610 bytes, SHA-256
  `04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7`.
- `source-census.json`: identities and lexical matches for all 2,708 selected
  OCaml source members and the existing 603 Why source members. Tests, comments,
  tools and interfaces remain visible. This is not a call graph.
- `native-census.json`: raw direct-relative candidates, aligned target-pointer
  words and the two plugins' Format symbol inventory. These diagnostics make
  no indirect-call completeness claim.
- `native-bodies.json`: fourteen bodies extracted from existing disassembly,
  with 2,352 bytes compared against the exact installed ELF. No disassembler ran.
- `inputs.json`: exact dependency, checker, local evidence and installed-file
  identities. `result.json` records the bounded conclusion, with complete `R`
  null. The zero normal-formatter charge is justified by the prose argument,
  not proved by the lexical checker.
- `round.json`: selected settings, scope, results and available timings.

Run from this worktree:

```sh
python3 docs/evidence/retained-why-formatter-prefix-repair-20261019/check.py
```

The checker reads files only; it invokes no target, debugger, compiler, solver
or subprocess. Native runs, captures, replay and broad suites were not repeated.
The previously successful frozen formatter and binder checks were reused.
