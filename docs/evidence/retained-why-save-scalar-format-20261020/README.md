# Selected save scalar conversion packet

Research #119 / #153, Round 29, 2026-10-20. The
[argument](../../research/retained-why-save-scalar-format.md) derives conditional
normal scalar output d=20 and selected temporary extents. Actual continued
conversion premises and aggregate Format/save capacity remain unjoined.

- `source-witnesses.json` identifies exact members and excerpts of retained
  OCaml and Why3 source archives.
- `native-bodies.json` projects 17 bodies from the previously retained installed
  disassembly. `native-witnesses.json` binds the executable, 3,408 instruction
  bytes and three selected data constants.
- `libc-contract/` and `retrieval.json` retain three published GNU libc 2.43
  manual pages describing the imported service contract. They do not reconstruct
  historical build provenance or prove libc internals.
- `transfer.py` and `result.json` keep conditional arithmetic separate from
  actual joined premises and complete-capacity flags.
- `check.py` verifies identities, exact source excerpts, native bytes, integer
  inequalities and rejection of missing/false/malformed premise inputs.

From the repository root:

```sh
python3 -B docs/evidence/retained-why-save-scalar-format-20261020/check.py
```

The checker reads installed ELF bytes; it does not execute the tool or invoke a
disassembler. No previous collector, binder, alpha or formatter checker is
replayed. `check-result.json` retains the actual focused result. Independent
review belongs to the combined Round 29 checkpoint.
