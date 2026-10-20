# Selected save table/counter attachment

Round 31, 2026-10-20 UTC, Linux x86_64, #119 / #153. Exact base:
`87874f41b44f7abb2d3c4848405b3474a09f51b4`.

The [research note](../../research/retained-why-save-table-contract-join.md)
supplies the source and ownership arguments, external premises and residuals.
The [result](result.json) attaches 206 structural table bounds and five counter
endpoints under those named premises. It preserves failed lookup coverage and
leaves whole-client/save/pipeline capacity false. Prior outputs are unchanged.

- [Input identities](inputs.json): accepted source, fresh table, growth,
  counter, native-effect and theory-control records reused without replay.
- [Source excerpts](source-excerpts.json): exact counter/publication, private
  helper ownership and scalar hash/compare passages from retained archives.
- [Native bodies](native-bodies.json) and [witness manifest](native-witnesses.json):
  two newly projected retained counter bodies, 400 instruction bytes, checked
  directly as data against the identified ELF. No target or disassembler run.
- [Attachment](join.py), [focused checker](check.py), [recorded check](check-result.json)
  and [round record](round.json).

Reproduce only this new focused check from the repository root:

```sh
python3 docs/evidence/retained-why-save-table-contract-join-20261020/check.py
```

The identified retained executable must remain at its manifest path. The full
retained disassembly was identity-checked and projected at packaging; the saved
two bodies suffice for the byte comparison. `join.py` regenerates the JSON
attachment from accepted inputs; it is not an independent proof of the note's
source ownership or imported external behavior. No predecessor checker,
capture, source fetch, solver, proof, native target or disassembler was run.
