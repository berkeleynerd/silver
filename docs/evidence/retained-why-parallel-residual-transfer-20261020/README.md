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

No old checker is replayed by the audit. No native target, solver or proof has
been run at this initial specification freeze. Acquisition results, exact input
checks, managed-run evidence and source/logical correspondence will be retained
separately in this packet as work proceeds; a specification is not evidence of
its successful execution.
