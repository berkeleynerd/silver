# Seven explicit String helper groups (#296)

Selected setting: GPT-6.1 Sol / Extra High, per parent briefing. Runtime model and effort independently unconfirmed. Token and monetary cost measurements unavailable.

Authorization and ownership: bounded String/Character #296 repair. Only `proof/Silver/ComposeStringNative.lean` is owned. PR #307 stays open and unmerged. No language/domain/contract/proof-policy changes, native edits, pin edits, generator edits or test edits are part of this lane. All preexisting unowned changes are retained.

The owned file initially matched the lead's exact SHA-256 `86c058ed691aab33f07020fc15b6a5ccf4adb12c7c9d95db42f80f08e16f6f6a`. The production patch adds exactly seven `Expr.group` wrappers around existing left-associated operations: the fixed-bounds difference; the two indexed length differences; indexed operand addition; concatenated static-length addition; and the two concatenated index additions. Expression evaluation interprets `group` as the identity. The expression structure and operation order are otherwise unchanged. The modified file is `1b8c1d932eb496d6c75bc04a4be37b62c605dd946ee41ed5a1076576fe7315f4`.

`GroupingEquivalence.lean` captures the exact three baseline definition blocks in scratch, renaming only their definition names. Three whole-body equalities compare current and original evaluation for arbitrary `Calls` and `Locals`, each by `rfl`. These statements have no validity, store, history or admission premise. The captured old definitions are evidence only; the production patch contains no snapshots or extra definitions.

The precheck compares all 121 modules from the previous actual focused audit, the Lean/Lake binaries, lakefile, toolchain pin and runner with the lead. All initially matched; no dependency synchronization, tool transfer or cache transfer was needed. The actual model closure contains no embedded-source certificate. The older lane Ada source is not final native-source evidence.

The optional scratch render diagnostic extracts three unique helper bodies from the lead's proposed literal pin (`b483c104df7a18f6aa3abe48547ed29d0d491903da4efc66bf4aeccf662b577c`), accompanying exact proposed Ada SHA-256 `4a02223317f89de2653d89ac152ae9e66fb089a0cfa20cd3ecb4c8765d90c485`. It checks the current model rendering against 91 fixed-bounds tokens, 578 indexed-body tokens and 266 concatenated-last tokens. This detects render/pin mismatch; it does not establish source-byte-to-pin correspondence.

The required managed focused targets are `Silver.ComposeHelperEquations` and `Silver.ComposeModelHelperEquations`, one worker, one thread, 4096 MiB, with provenance and a fresh scoped axiom audit. The scratch equivalence and render checks also use one worker, one thread, 4096 MiB and fresh audits. Complete integrated native/source correspondence, final review and capability delivery belong to the lead.

## Terminal result

Commit `5bd5654f4b8deba5284156c2c7b7cd907d99c039` contains only the seven-line production change in ComposeStringNative. `integration.patch` applies the exact delta against the captured lead-matching baseline; no unowned change was committed. All nonowned tracked bytes still match the initial snapshot.

Focused Linux run `20261103T232749-c3db83b33386` passed the two requested targets and a fresh 14,821-declaration audit over 121 actual modules. Build elapsed 585.553 seconds, audit 2.889 seconds, runner elapsed 597.257 seconds. It used one worker, one thread and 4096 MiB, with retained ordinary objects; no memory retry or independent kernel replay was needed. Detailed actual source/tool/compiled-object inventories are retained, including 722 scoped compiled artifact identities and 1206 adjacent metadata identities.

Scratch arbitrary-Calls/Locals whole-body equivalences passed in run `20261103T233751-f8098574d16b`: 2.497 seconds, 1,636,720 KiB maximum RSS, fresh 12,261-declaration permitted-foundation audit. All captured sources and imported artifacts were stable.

The initial scratch render tactic attempt `20261103T233841-b5ad27b7072b` failed in 2.526 seconds because reduction got stuck at mutually recursive Command.render; its subsequent audit correctly rejected the tactic's unfinished sorryAx. This is retained in render-first-failure files. Reusing the exact explicit unfolding already used by ComposeHelperSourceCandidate repaired only the scratch proof. Render parity then passed for all three helper token lists in run `20261103T233923-ebcf06417b58`: 3.426 seconds, 1,718,156 KiB maximum RSS, fresh 12,277-declaration permitted-foundation audit, unchanged source/tool/artifact identities. This establishes current render-to-proposed-literal parity only; complete native-source correspondence remains the lead's obligation.

Selected GPT-6.1 Sol / Extra High, runtime independently unconfirmed. Token/cost measurements unavailable. Timings are measured native tool/runner times, distinct from the snapshot-to-record elapsed time in terminal-summary.json. No CLI memory was updated. Live harness goal returned null. The lead's old-source complete run was intentionally stopped for the concrete seven-site repair, rather than failing a source or kernel claim. No other source run or dense candidate was started by this lane.
