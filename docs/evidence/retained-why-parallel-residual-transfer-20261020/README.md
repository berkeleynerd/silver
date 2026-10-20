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

## All-domain attachment checkpoint

The four additional captures complete actual raw/Z3 metadata acquisition for all
five physical domains. Their `*-replay.json` files record exact nine-file offline
replays, and `*-correspondence.json` plus compressed maps join the old raw logical
graphs to the new J12 registration graphs. The earlier successful First replay
was reused. `remaining-manifest.json` pins four capture archives and both new
managed logs; `remaining-post-identities.json` rehashes every declared input after
both batches, including the batch interrupted before its aggregate final check.

| Domain | Raw tasks | Declaration pairs | Joined blocks | Immediate operands | Native seconds | Replay seconds |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| First_Or_Default (retained) | 33 | 334 | 42,481 | 48,769 | 4.938 | 1.698 |
| Input_Is_Valid | 5 | 248 | 16,106 | 17,833 | 2.562 | 2.362 |
| Put_Line | 65 | 638 | 115,020 | 142,849 | 12.153 | 13.147 |
| Put | 54 | 627 | 95,672 | 117,922 | 17.125 | 11.429 |
| Is_Message | 4 | 209 | 14,087 | 15,456 | 4.284 | 2.713 |

The two Put graphs each contain seven custom blocks. Their operation pointers
match by captured executable load bias; all remaining opaque words match exactly.
The other three graphs have no custom blocks. Input's old capture has no symbol
file/load bias; its correspondence therefore asserts that no custom block occurs,
rather than supplying an invented bias. Its old stop was after the first CE
transformation, but the matched immutable raw graphs are exactly equal.

Managed batch `20261020T212620-bf50915cba85` completed Input and Put_Line, then
failed on `/tmp` ENOSPC while creating Put's capture directory, before launching
Put. Only the never-started Put and Is_Message were relocated to the host
filesystem and run in `20261020T212742-ef4313af368d`. No successful native capture
was repeated. The first batch's inherited managed reason still names First;
its exact plan/argv and retained results identify the actual four planned cases
and two completed cases. The second batch uses its exact plan scope as reason.
Both batches reserved one managed worker and ran sequential native processes,
with actual client and server `-j 12`. No protected guard hits or preparation or
solver entries occurred. Startup GC observations remain in the native logs.

Provenance-label clarification: `first-domain-plan.json` and
`first-domain-headroom.json` describe attempt 1. The successful first-domain
archive contains the plan matching `attempt-3-plan.json`. These historical
aliases are retained verbatim. “No protected guard hits” does not erase the four
inherited startup GC observations in the First log.

This checkpoint closes actual metadata/raw-symbol acquisition and correspondence
for the five captured J12 domains. It does not attach every mutable table to an
arbitrary J>1 schedule or establish the thirteen-key stored-family theorem.
