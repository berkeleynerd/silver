# Partial static-data research evidence, 2026-10-17

This is an incomplete research handoff for Silver #108, authorized by PR #106.
It does not adopt new language bounds, complete #108, or authorize implementation.
The accompanying record is `docs/research/unbounded-static-data.md`.

`probes/` contains eight measured Darwin compiler/linker cases and one invalid
initial monitoring attempt. `linux-retained/probes/` contains seven measured
Linux cases. Outputs were never executed. All valid cases used a 512 MiB
sampled process-group RSS guard, 30-second wall/32-second CPU limits, a 16 MiB
per-file limit and disabled core dumps. No guard fired. Four measured cases
returned expected unsupported-model/relocation errors; eleven succeeded.

The BSS cases are C proxies. They test object/address/layout behavior using
zero-fill metadata rather than giant initialized files. Their successful links
do not establish allocation or runtime success. The Ada cases use identical
889-byte proposed-language sources with A0 through A20 String constants, ending
in a 1 MiB value. Their source exceeds current Silver value bounds. They compile
only to assembly; runtime source copies match the frozen research worktree.

Every measured case retains inputs, command, exit status, diagnostics, timing,
RSS observations and output hashes in `result.json`. Darwin `ru_maxrss` units
are bytes; Linux units are KiB. Sampled aggregate RSS is a separate metric and
can miss short peaks. The earliest valid native result files predate the added
explicit max-RSS unit field; their platform fixes the interpretation.

The initial unguarded-measurement attempt remains under `probes/c-default/`.
Its ps monitoring call failed after launching a 45-byte C assembly probe. The
child completed and no surviving child was observed; that run is not used as
measured validation. The repaired harness checks ps before launching.

`identity.json`, `native-linker-identity.json`, binary hashes and selected
environment snapshots identify the macOS inputs. Linux identity records both
PATH ld2.46 and GCC's selected bundled linker path. The later
`linux-retained/linux-selected-linker.json` resolves that distinction: the
selected linker is GNU ld2.46.1 with its own hash.

`sources/` records retrieval URLs, pinned release recipes, hashes and relevant
exact excerpts. Source-to-installed-binary identity has not been attested.
The fetched generic GCC source is distinct from the pinned Darwin fork.

Large repetitive assembly and downloaded full backend sources remain in the
original scratch tree; the bundle provides line-numbered nonliteral assembly
excerpts and source excerpts. `retained-large-artifacts.json` identifies every
omitted artifact by full scratch path, size and SHA-256. Local originals remain
at `/tmp/silver-unbounded-feasibility-20261017/static-data/`; Linux originals
remain at the same path on `canto@nix.local`. No worktree/cache was removed.
`MANIFEST.json` covers this compact copy.

Continuation scripts are research tooling, not production scripts. Do not run
them as a checklist: retain the existing successful observations. Investigate
the frontend String-pool argument and same-source alternatives first, then run
only the smallest new discriminating probe if a concrete question remains.
Any compiler/linker probe must be coordinated to keep one active at a time.
Independent adversarial review and final owner-facing conclusions are pending.
