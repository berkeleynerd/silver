# Native GPR parent evidence

Supports [the selected native GPR join](../../research/retained-gpr-parent.md)
for #119. Two small Linux builds are retained, with exact commands, complete
child environments, tool/input identities, logs, generated artifacts and
managed events. The second retains the auto-configuration source deleted by
the ordinary invocation. No prover, complete suite, Lean build, kernel replay,
macOS validation or CI run was performed.

`sources.tar.gz` contains 16 complete inspected GPR files.
`witnesses.tar.gz` contains both capture scripts and results, source/project,
ALI, binder, object and executable outputs. `manifest.json` hashes every file
and both archives. The source commit identifies inspected text, not historical
binary build provenance. The existing relevant-behavior premise remains.

Replay without installations or cached upstream trees:

```sh
python3 docs/evidence/retained-gpr-parent-20261018/check.py
```

Use `--main <file>` to recompute the local physical-source conditions on an
exact null token family member. This accepts research FF/VT trivia, without
admitting it into production. It rejects unsupported bytes and token streams;
failed arithmetic is reported in the result. It never invokes GPR or decides
language membership. The ALI bound is source-derived in the linked binder
record; `check.py` corroborates the retained record populations, rather than
inferring 378 from the two observed 355-byte files.

The focused offline arithmetic checks cover CR/LF versus FF/VT, tab columns,
line-table growth, source EOF and column boundaries. There is no aggregate
physical-memory test. The default result is retained in `result.json`.

The capture durations are 0.4591 and 0.3446 seconds. Managed IDs are
`20261018T122943-c12e0db35e8a` and `20261018T123112-8c4245919445`.
Both runs succeeded with empty stderr and byte-equal final executables.
The binder object equals the separately accepted 13,432-byte object.

`collect.py` only packages already-existing files; it launches no native tool.
Use a fresh `--output` directory for any later recollection. Historical
capture scripts retain their original absolute paths and refuse to overwrite
their prior result files.
