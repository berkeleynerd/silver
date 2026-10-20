# Signal setter caller capacity

See the [note](../../research/retained-why-save-signal-setter-capacity.md).
The packet binds five retained source excerpts, six installed native bodies,
the actual POSIX signal-table data, selected call edges and imported frame facts.
Normal result wrappers and caller stack are separate from nested callbacks,
failed-service diagnostics and runtime/OS interiors. Full-capacity flags remain
null/false. No fresh execution or disassembly is part of the check.

```sh
python3 docs/evidence/retained-why-save-signal-setter-capacity-20261020/check.py
```

The author check passed in 0.359238 seconds. Preparation initially sought an
absent generated sys.ml; the final packet uses the retained sys.mli contract and
actual native wrapper instead. Source/native correspondence remains reviewed
reasoning, not a consequence of hashes alone. Refs #119, #153.
