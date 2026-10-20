# R57 stock server allocation owners

The [note](../../research/retained-server-owned-storage.md) closes direct C
allocation families for the proposed shared J12 server and five fixed backend
connections, while preserving the separate historical singleton captures and
explicit library/physical-memory residuals.

From the repository root:

```sh
python3 -B docs/evidence/retained-server-owned-storage-20261020/check.py
```

This focused nonmutating check verifies retained byte identities, source/caller
coverage, static installed ELF operands and the new topology/owner arithmetic.
It does not replay predecessor checkers, start an inferior or execute a server,
solver, compiler or proof run. `projection.json` supplies the computable direct
allocation terms and exact topology distinction; `source-inventory.json` and
`source-witnesses.json` are review inputs, not semantic machine proofs.
`native-inputs.json`, `installed-disassembly.txt` and `native-symbol-inventory.json`
record static installed-byte correspondence. Inputs and results are frozen;
the checker rewrites none of them. See `round.md` for measured evidence and
remaining integration obligations. No production adoption or complete q is
claimed.
