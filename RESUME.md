# Silver VM handoff

Refreshed on 2026-10-10 from the replacement sandbox after reading the authority
and prior handoff. The actual host is **Linux x86-64**, with 12 visible CPUs,
approximately 31 GiB usable RAM and separate 63-GiB Docker storage. Native pinned
tools have been installed; build, tests, full SPARK validation and full Lean
verification passed. Lean replay resumed after two host/sandbox restarts,
preserving its completed objects and both interrupted attempts' logs, then
passed a fresh axiom audit and independent kernel recheck. See the
[host-readiness record](docs/host-readiness.md) for commands, results and resources.

**Recovery status:** the subsequently fetched migration archives passed full
integrity checks; historical ARM64/macOS evidence, tools and caches are restored
alongside the new x86-64 state. Top-level `tmp/`, `.vscode/`, old CLI memory and
the old checkout's local Git state were outside those snapshots. Preserve any
remaining old VM/backup until that separate state is accounted for. GitHub access
is now restored; an authenticated October 10 check confirmed local and remote
`main` at published recovery checkpoint `eb7262a`. At the owner's explicit
direction, GitHub Actions is disabled for the entire repository and validation
runs locally. Do not enable hosted CI as a readiness follow-up. No runs are
listed and the previously recorded run is no longer retrievable.
CLI memory is disabled and absent; checked-in session memory is the active
handoff. No new language expansion or performance candidate is authorized.

## Completed work and review target

- `5668806` records the bounded certificate-performance investigation. Neither
  permitted candidate established a validated improvement. The original
  certificate representation remains; no third approach is authorized.
- The feature implementation and external-review target is `96b4e3a`, which added
  this document and `samples/command_line_greeting.adb`. It admits the sixth
  production, normalizes owned argument results to one-based strings, proves
  independent report-policy refinement, and extends the SPARK/Lean assurance.
  Find that commit with `git log -1 --format='%H %s' -- samples/command_line_greeting.adb`.
- Implementation, independent review and full native Linux validation are
  complete. The existing harness goal was marked complete at the local
  commit handoff. Its earlier paused status was superseded by the owner's
  explicit resumption; do not recreate it as unfinished work from an old note.
- The Oracle is unchanged. After completion, the owner added the
  [GitHub remote](https://github.com/berkeleynerd/silver) and authorized pushing
  the committed history. The previous handoff confirmed that remote `main`
  contained `9731278`, including the implementation and performance commits.
  The initial missing-`workflow`-scope rejection is historical. The replacement
  checkout started at `69d294c` and has now incorporated the fetched migration
  commits through `1bf065d`. Initial credential failures on the replacement host
  were separate from that earlier resolved scope issue; access recovered after
  the second restart. No next language
  capability or further performance investigation is authorized.

Read [the capability record](docs/command-line-greeting.md) for exact proof
claims, results, identities and limitations, and
[the performance record](docs/certificate-performance.md) for the negative
performance result. The next action is external review of the feature commit.
The first [hosted CI run](https://github.com/berkeleynerd/silver/actions/runs/37983290787)
started for `9731278` and was reported in progress at the previous refresh.
The authenticated API now returns 404 for that run and lists no repository runs;
the `Verify Silver` workflow is `disabled_manually`, and repository-wide Actions
has now been disabled at the owner's request. The old results remain unavailable;
hosted validation is outside the intended local workflow. Later handoff-only
commits do not change the implementation review target. This session's live
harness returned no goal; do not recreate the completed implementation goal.

## Recover and preserve the old VM evidence

The owner subsequently authorized including snapshots of both artifact trees in
Git under their non-dot names. [silver/](silver/README.md) and
[tools/](tools/README.md) contain compressed, split archives of the original
`.silver/` and `.tools/`, with capture metadata, checksums and restoration steps.
Use every part of each selected snapshot; restore through the documented staging
procedure so existing state is preserved. These are point-in-time migration
copies, not alternate live build directories or new validation runs.

Keep the entire checkout, including `.git`, for any local state newer than those
snapshots. Preserve untracked `.vscode/` and `tmp/` material; those directories
are still excluded from Git.

The fetched snapshot commits are now present locally at `1bf065d`. All part and
archive hashes, extracted inventories and full content comparisons passed.
Foreign-host and legacy trees were restored without collisions; the new native
x86-64 state was preserved. New validation does not replace historical records.

Keep all hosts' `.silver/<host>/` evidence and caches and `.tools/<host>/`
installations; the latter avoid unnecessary downloads. Do not discard another
host's state when preparing Linux. Live artifact trees remain ignored by Git;
the snapshots preserve their captured contents, including this evidence:

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

Verify snapshot checksums and any additional backup before destroying the old
VM. Retain original evidence if relocation makes its absolute paths
stale; a new machine or installation does not retroactively change that evidence.

CLI recall is secondary. If available in the backup, preserve the Silver notes under
`/home/agent/.codex/memories/extensions/ad_hoc/notes/`; checked-in guidance and
the owner's latest instructions take precedence over the older paused snapshot.

## Continue on the replacement VM

1. Read [AGENTS.md](AGENTS.md), [oracle.md](oracle.md),
   [language.md](language.md), [development.md](development.md),
   [roadmap.md](roadmap.md), and the latest
   [session memory](docs/session-memory.md). Inspect Git status and the live
   harness goal before starting work.
2. Verify the actual OS, architecture, RAM and free disk. The old checkout path
   looks like macOS, but the completed work ran on Linux ARM64. The owner now has
   a host with **96 GB RAM**. The recommended sandbox allocation is **32 GiB RAM**,
   automatic CPU allocation, and **64 GiB Docker storage**. The mounted Silver
   workspace, including `.tools/` and `.silver/`, uses the host filesystem and
   needs its own free space. These recommendations supersede the earlier 18 GB
   plan. This sandbox's observed RAM and Docker capacity match those allocations;
   the mounted workspace has approximately 604 GiB free before installation.
   The separate root filesystem is only 20 GiB. Physical host RAM is not directly
   verified from inside the sandbox.
3. Check selected host paths with `python3 scripts/dev.py paths`. Python 3.11+
   and native libc development files are required on Linux. If the installation
   moves, run `python3 scripts/bootstrap.py`,
   `python3 scripts/bootstrap_lean.py`, then `python3 scripts/dev.py build` to
   refresh installation bindings. See
   [platform coexistence](docs/platform-coexistence.md). Existing evidence still
   describes the original installation and inputs; record new validation with
   its actual scope. Both bootstrap commands have now passed on x86-64, after
   installing missing Linux libc development files; consult the readiness record
   before repeating completed phases.
4. Use the existing incremental proof workflow for subsequent authorized work.
   For a full check, start conservatively with
   `python3 scripts/dev.py prove --full --jobs 4` and
   `python3 scripts/check_lean.py --full --threads 1 --memory-mb 6144`.
   Run heavy proof commands separately and monitor available memory. Lake can
   schedule independent modules concurrently; the memory allowance applies to
   each Lean build/audit process, not aggregate host usage. The separate pinned
   `leanchecker` has no memory-limit CLI option. Retain caches; use cold or clean
   checks only when their purpose warrants the extra cost.

For future recreation, the previously recommended host-side command is:

```sh
DOCKER_SANDBOXES_DOCKER_SIZE=64g sbx create --name codex-silver --cpus 0 --memory 32g codex .
```

Then attach with `sbx run --name codex-silver`. The
[creation options](https://docs.docker.com/reference/cli/sbx/create/) use binary
memory units and automatic CPU allocation (capped at 16 on Linux ARM64). The
[disk override](https://docs.docker.com/ai/sandboxes/configuration/settings/#sandboxdiskdockervolume)
sets the new sandbox's Docker volume, not the mounted workspace's capacity.
Additional physical RAM does not change Lean's configured allocation limit or
establish a measured proof speedup; retain the conservative starting settings
above until actual resource use warrants tuning.

No historical ARM64 validation process needs resumption. Its compiler audit
used wholly fresh sessions/cache, and its final Lean invocation reused completed
modules but executed a fresh axiom audit and kernel recheck. Those underlying
artifacts are now restored and corroborated within the snapshot's scope. The readiness record distinguishes new x86-64
validation from those historical results. Native macOS validation of the sixth
form and AdaCore GNAT Pro remain pending. GitHub Actions is intentionally disabled
repository-wide; local validation is the requested workflow. Publication
authorization continues, with its outcome recorded
in the latest session-memory entry.

The intermittent GNATprove `DOC_END` JSON-reader failure in reused state remains
unresolved. Its historical logs are restored. There is no automatic retry and
cold success is not evidence that
warm state is repaired. Mathematical range validity and its
decision procedure are proved; faithful concrete GNAT obligation generation and
pinned solver completion remain documented external-tool premises. Do not
present these as verified solver completeness or weaken required discharge.
