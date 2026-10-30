# Complete repaired native checkpoint

Run `20261029T211041-a76eb6753f23` passed on Linux x86_64 at
2026-10-30 00:32:43 UTC, after 12,119.996 s managed duration. It validates
implementation `6020416906b5fc3d2bd10d012e70937c80f0617c` with the normal
`dev.py prove --full` command, four workers and unchanged strict prover options.
The complete coverage and provenance audit passed after native discharge.

The reports contain **16,825 proved checks**: 1,432 flow checks and 15,393 proof
checks, over 76 units and 1,075 entities. Every proof/flow entry has severity
`info`. The repaired `Body_Tail` session proves all 330 goals. The earlier
[failed full run](../native-full-reuse/failed-full/README.md) remains failed;
this complete successful run establishes the repaired native assurance.

The audit separately classifies 305 limitation notes, 18 imported entities,
6,236 trusted-mathematics notes, 62 vendor-specification entities and five
array-initialization advisories. There are 6,598 `warn_error` entries, including
6,546 with warning severity and 52 with info severity. They are retained in the
[warning inventory](warning-inventory.json); a successful proof does not mean
the producer emitted no warnings.

This is a forced full analysis and fresh complete audit with existing sessions
and solver cache, not a cold run. The [reuse record](../native-full-reuse/README.md)
identifies the workspace, source synchronization and preceding outcomes.
All 143 tracked native inputs match the implementation and integration tree;
the complete provenance map contains 2,561 inputs. Unrelated dirty files in the
native workspace retain their original hashes.

`complete-reports.tar.gz` contains the original 76 `.spark` reports,
`gnatprove.out`, `gnatprove.sarif`, provenance manifest and input snapshot:
80 members. All 78 report digests match the manifest and original ledger.
`tracked-and-generated-inputs.tar.gz` retains the 143 tracked inputs plus six
generated workspace inputs. Original managed events and logs are compressed
without changing their decompressed bytes. The [summary](summary.json) records
counts, command, input identity, cache state and artifact hashes; the
[retention check](retention-verification.json) verifies archive members,
payload hashes, counts and terminal audit evidence. It is a separate check of
the retained packet, not an independent reviewer or a proof rerun.

Native implementation/continuation selected GPT-6 Astra / Extra High. Its
monitoring agent encountered a model-capacity limit before completion; the OS
proof and gated retention processes continued unchanged, and the lead checked
the terminal result and integrated this packet. Lead runtime settings and
token/cost measurements are unavailable. Complete Lean assurance is recorded
separately in the [delivery packet](../README.md).
