# Residual producer transfer — R53

This packet starts with a focused negative coverage audit and a targeted
acquisition specification. The ordered producer transfer and intended parallel
stored-family closure are still open.

`audit-coverage.py` reads all retained `*memory-reads.jsonl` members in the five
R28 capture archives. It checks byte intervals, not textual pointer presence.
The header and first forty payload bytes of every raw-task Meta record,
argument-list root and Use theory root receive zero overlap. Across the five
archives it reads 5,918,792 log rows. `metadata-coverage.json` records every
Meta tdecl/node/record/list reference and per-case results. These root-byte
omissions suffice to prevent direct decoding; the audit does not claim that
arbitrary unreachable memory was exhaustively searched.

```sh
python3 -B docs/evidence/retained-why-parallel-residual-transfer-20261020/audit-coverage.py
```

The fixed library/driver sources are available, but a complete source-level
reconstruction of parser/typing/cloning and physical metadata arguments is
not supplied by the older packets. Older inlining packets explicitly quantified
the missing exclusion set. R53 instead requests the bounded projection in
`acquisition-spec.json`, so the actual branch can be derived offline.

No old checker is replayed by the audit. At the initial specification freeze
`0e7ce6ea890055ae30245a0f25406b8566d5e670`, no new native target had run.

The first-domain continuation now retains one successful native J12 capture,
two failed attempts and their diagnoses. `first-domain-manifest.json` pins all
archive/member bytes. `first-or-default-capture.tar.gz` contains the exact
isolated plan, inputs, collector sources and native observations. The selected
Z3 metadata has 66 theory entries; typed raw metadata and clone maps are complete.
The raw logical graph is included solely to bind metadata arguments to the
frozen logical symbols; full Hsdecl state was not recaptured.

`verify-capture.py CAPTURE_DIRECTORY` replays the new reader from captured
byte reads and compares nine exact outputs. `first-domain-replay.json` records
its successful 1.698-second run. `first-domain-correspondence-result.json` and
the compressed address map retain the 42,481-block raw logical bijection with
R28. The actual run is J12 at registration; neither arbitrary J>1 shared state
nor the residual stored family is thereby closed.

`first-domain-managed.tar.gz` retains all three actual managed run logs;
`round-first-domain.json` distinguishes native time, offline time, reader rework,
review findings and continuing obligations. Every native attempt had zero
preparation/solver entries. The failed artifacts are preserved, not relabeled
as successful metadata captures. Sources in `collector/` document the config
copy and set-layout corrections. The scripts referencing `/tmp/` describe the
actual acquisition/replay paths; the archives retain the portable bytes.
