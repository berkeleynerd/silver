# Silver VM handoff

Prepared on 2026-10-09 after completing the authorized performance and guarded
command-line greeting work, before the requested VM replacement. No VM migration
or destruction has been performed.

## Completed work and review target

- `5668806` records the bounded certificate-performance investigation. Neither
  permitted candidate established a validated improvement. The original
  certificate representation remains; no third approach is authorized.
- The feature implementation and external-review target is the commit adding
  this document and `samples/command_line_greeting.adb`. It admits the sixth
  production, normalizes owned argument results to one-based strings, proves
  independent report-policy refinement, and extends the SPARK/Lean assurance.
  Find that commit with `git log -1 --format='%H %s' -- samples/command_line_greeting.adb`.
- Implementation, independent review and full native Linux validation are
  complete. The existing harness goal is to be marked complete at the local
  commit handoff. Its earlier paused status was superseded by the owner's
  explicit resumption; do not recreate it as unfinished work from an old note.
- The Oracle is unchanged. Work is local; nothing has been published. No next
  language capability or further performance investigation is authorized.

Read [the capability record](docs/command-line-greeting.md) for exact proof
claims, results, identities and limitations, and
[the performance record](docs/certificate-performance.md) for the negative
performance result. The next action is external review of the feature commit.

## Preserve before replacing the VM

Keep the entire checkout, including `.git`, rather than relying on a source-only
archive or remote repository. Preserve untracked `.vscode/` and `tmp/` material.
Keep all hosts' `.silver/<host>/` evidence and caches and `.tools/<host>/`
installations; the latter avoid unnecessary downloads. Do not discard another
host's state when preparing Linux. Important evidence is ignored by Git:

- `.silver/linux-aarch64/guarded-greeting-validation/` contains final results,
  review identities and preserved failed/interrupted attempts. Its
  `lean-final-evidence.json` and `lean-final-proof.log` record the completed full
  Lean check; `native-validation-summary.json` and `native-validation.json`
  record compiler proof, build and tests.
- `.silver/linux-aarch64/compiler/obj/cold-tline0db/gnatprove/` contains the
  successful cold compiler audit and `proof-provenance.json`.
- `.silver/linux-aarch64/lean-evidence.json` and
  `.silver/linux-aarch64/proof/` retain the current Lean record and reusable
  module objects.
- `.silver/linux-aarch64/certificate-performance/` retains both bounded
  candidate trials. Earlier review evidence and other-host artifacts retain
  their original scope.

Verify the backup includes these ignored directories and `.git` before destroying
the old VM. Retain original evidence if relocation makes its absolute paths
stale; a new machine or installation does not retroactively change that evidence.

CLI recall is secondary. If needed, preserve the Silver notes under
`/home/agent/.codex/memories/extensions/ad_hoc/notes/`; checked-in guidance and
the owner's latest instructions take precedence over the older paused snapshot.

## Resume on the replacement VM

1. Read [AGENTS.md](AGENTS.md), [oracle.md](oracle.md),
   [language.md](language.md), [development.md](development.md),
   [roadmap.md](roadmap.md), and the latest
   [session memory](docs/session-memory.md). Inspect Git status and the live
   harness goal before starting work.
2. Verify the actual OS, architecture, RAM and free disk. The old checkout path
   looks like macOS, but the completed work ran on Linux ARM64. The owner allows
   **18 GB RAM** for the replacement; **64 GB disk** is the suggested allowance.
   These are provisioning recommendations, not changes already applied.
3. Check selected host paths with `python3 scripts/dev.py paths`. Python 3.11+
   and native libc development files are required on Linux. If the installation
   moves, run `python3 scripts/bootstrap.py`,
   `python3 scripts/bootstrap_lean.py`, then `python3 scripts/dev.py build` to
   refresh installation bindings. See
   [platform coexistence](docs/platform-coexistence.md). Existing evidence still
   describes the original installation and inputs; record new validation with
   its actual scope.
4. Use the existing incremental proof workflow for subsequent authorized work.
   For a full check, start conservatively with
   `python3 scripts/dev.py prove --full --jobs 4` and
   `python3 scripts/check_lean.py --full --threads 1 --memory-mb 6144`.
   Run heavy proof commands separately and monitor available memory. Lake can
   schedule independent modules concurrently; the memory allowance applies to
   each Lean build/audit process, not aggregate host usage. The separate pinned
   `leanchecker` has no memory-limit CLI option. Retain caches; use cold or clean
   checks only when their purpose warrants the extra cost.

No validation process needs to be resumed from this VM. The final compiler audit
used wholly fresh sessions/cache, and the final Lean invocation reused completed
modules but executed a fresh axiom audit and kernel recheck. Native macOS
validation of the sixth form remains independent and pending; x86-64, hosted CI
and AdaCore GNAT Pro remain untested.

The intermittent GNATprove `DOC_END` JSON-reader failure in reused state remains
unresolved. Logs are preserved; there is no automatic retry and cold success is
not evidence that warm state is repaired. Mathematical range validity and its
decision procedure are proved; faithful concrete GNAT obligation generation and
pinned solver completion remain documented external-tool premises. Do not
present these as verified solver completeness or weaken required discharge.
