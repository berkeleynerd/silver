# Silver handoff

Updated on 2026-10-10 on Linux x86-64. Read [AGENTS.md](AGENTS.md),
[oracle.md](oracle.md), [language.md](language.md),
[development.md](development.md), [roadmap.md](roadmap.md), and the newest
[session memory](docs/session-memory.md) before substantial work. Inspect Git
status and the live harness goal; historical goal states are not current instructions.

## Current work

The seventh production is implemented and locally validated: one literal-initialized `String`
variable, one assignment of an equal-decoded-length literal, then output through
the same name. Independent reviews, native validation, the full Lean build,
fresh axiom audit and independent fresh kernel recheck passed. Final evidence
corroboration matched current inputs and artifacts. The harness goal also covers
the closing commit and publication; check its live status and closing evidence
at resumption.
The [capability record](docs/string-assignment.md) records exact scope, the
obligation experiment, source correspondence and validation status.

The owner also requested a read-only [architecture review](docs/architecture-review.md)
while validation ran. It recommends retaining the main boundaries, with small
evidence-runner and proof-only I/O improvements as possible follow-ups. No
recommended refactor has been implemented or selected as the next goal.

The implementation/review target is the commit introducing
[samples/string_assignment.adb](samples/string_assignment.adb), identifiable with:

```sh
git log --diff-filter=A -1 --format='%H %s' -- samples/string_assignment.adb
```

The implementation is based on `6403b5c`. Earlier feature `96b4e3a` and its
[external review disposition](docs/command-line-greeting.md#external-review-disposition)
remain historical evidence for the sixth form. No further language expansion is
authorized. The Oracle is unchanged.

## Local tools and evidence

The current sandbox has 12 visible CPUs and approximately 31 GiB RAM. Native
pinned tools are installed. Use `python3 scripts/dev.py paths` for the actual
installation and artifact paths. GNATprove uses all cores by default; Lean uses
all available Lake workers and per-process threads, with independent overrides.
The [concurrency record](docs/lean-concurrency.md) distinguishes measured speedups
from remaining serial work and explains the per-process memory threshold.

During iteration, choose the smallest relevant check and use existing caches;
these commands are alternatives, not a sequence after every edit:

```sh
python3 scripts/dev.py build
python3 scripts/dev.py prove
python3 scripts/dev.py test -- -p test_string_assignment.py
python3 scripts/check_lean.py --memory-mb 12288
```

Choose tests for the affected behavior and batch edits before expensive
source-certificate rebuilds. Once a capability's inputs are stable, run the full
test suite and add `--full` to both proof commands. This regenerates
complete compiler evidence and adds Lean's independent fresh kernel recheck;
it does not imply a cold build. Repeat only validation affected by subsequent
changes, failures or unresolved concerns. Documentation-only follow-ups need
lightweight checks. See the [validation cadence](development.md#proof-loop-and-validation).
Monitor aggregate host memory when running heavy
commands together. Preserve `.tools/<host>/`, `.silver/<host>/`, scratch files
and all foreign-host evidence. Source/runtime installation moves require
bootstrap and rebuild under the [platform coexistence rules](docs/platform-coexistence.md).

Current task evidence is under `.silver/linux-x86_64/assignment-validation/`.
Prior canonical reports/manifests were preserved there before validation. Earlier
host recovery and Linux ARM64 records retain their original input and platform
scope in the [host-readiness record](docs/host-readiness.md) and linked artifacts.
Linux is primary; macOS records are entirely optional. GNAT Pro is untested.

<a id="recover-and-preserve-the-old-vm-evidence"></a>

## Git, recovery and session state

The owner authorized committing and publishing completed work to
[the repository](https://github.com/berkeleynerd/silver). GitHub Actions remains
**disabled repository-wide** by explicit instruction; validation runs locally.
Do not enable hosted CI as a follow-up. Verify remote `main` at handoff and record
the closing commit in the final response and local evidence.

The non-dot `silver/` and `tools/` transfer directories were removed from both
the tree and reachable Git history at the owner's request. Live `.silver/` and
`.tools/` were preserved. See the
[history rewrite record](docs/host-readiness.md#transfer-history-removal) for
commit mappings and recovery limits. Back up the ignored live directories
separately; a clone cannot recover them. Do not merge the old archive-bearing
history into the rewritten branch. Existing scratch, foreign-host artifacts and
safety stash `a48321d` remain preserved. Historical references are not instructions
to recover the removed archives.

CLI memory is unavailable: no memory tool is exposed and the conventional recall
directories are absent. No CLI recall entry was updated. Checked-in
[session memory](docs/session-memory.md) is the durable handoff. The separate
Codex remote-control request remains unresolved because of API authentication;
this language task does not change authentication or restart its daemon.

## Remaining limits

The intermittent warm-state GNATprove `DOC_END` JSON-reader failure remains
unresolved. Retain a recurrence's logs and inputs; successful validation does not
establish repair, and no automatic retry is configured. Faithful complete GNAT
obligation generation, static elimination of the admitted assignment's satisfied
length check, pinned solver completion for guarded concatenation, and the
frontend/runtime/environment assumptions remain explicit in
[assurance](docs/assurance.md) and the [trusted boundary](docs/trusted-boundary.md).
No new external operation or trusted shortcut is introduced by this increment.
