# Platform coexistence checkpoint

The follow-up requested on 2026-10-08 isolates Linux and macOS builds in a shared
checkout. Native OS and architecture select one of `linux-aarch64`,
`linux-x86_64`, `macos-aarch64`, and `macos-x86_64`. There is no mutable shared
host selector and no cleanup or migration of older artifacts.

## Implementation

- `.tools/<host>/` owns Alire, Lean, and Alire settings/cache/toolchains.
- `.silver/<host>/toolchain/` owns the Alire manifest copy, lock, and local settings.
- `.silver/<host>/generated/silver_build.ads` contains SPARK constants used by
  the actual compiler. The proof audit includes this generated unit.
- `.silver/<host>/compiler/` owns compiler objects, executable, and GNATprove
  intermediates. The GPR project requires a supported `SILVER_HOST`; the
  development helper supplies the native value automatically.
- `.silver/<host>/program-XXXXXX/` holds each byte-identical program snapshot,
  generated project, proof evidence, and executable. A proved workspace
  postcondition requires the host prefix.
- `.silver/<host>/proof/` holds clean Lean replay inputs, generated certificates,
  Lake objects, and the manifest. Its adjacent source link resolves directly to
  authoritative `src/`. Shared proof inputs must remain unchanged during replay.

Alire 2.1.1 loads and can migrate settings before applying `-s` and `-C`.
Every invocation therefore starts in the host context, sets
`ALIRE_SETTINGS_DIR` to that host's settings, and removes deprecated
`ALR_CONFIG`. Development tooling also supplies absolute switch arguments.
The SPARK command changes its shell working directory to the host context
before starting Alire and uses the quoted `$PWD` to form the absolute settings
path. Project arguments are prefixed with `../../../` to reach
repository-relative projects. The CLI itself still runs from the repository
root as documented in the README.

Python remains development/bootstrap/proof tooling. Admission and compilation
are still implemented in verified SPARK. The Oracle is unchanged.

## Final validation

Native Linux ARM64 validation passed:

- All **655 SPARK checks** discharged: 124 flow and 531 proof, across eight
  units and 73 entities. The audit includes generated `Silver_Build`, eleven
  reviewed external imports, and twelve documented optional limitation notes.
  A proved intermediate assertion in the existing report congruence helper
  avoids a solver timeout without changing its contract or the 30-second policy.
- All **32 regression tests** passed in 26.401 seconds. These include four-host
  concurrent setup, preservation of other-host/shared/legacy files, poisoned
  Alire and Lean environments, missing/stale generated proof evidence, actual
  SPARK command invocation from a path with shell punctuation, and real program
  proof/build/run cases. Foreign-platform tool execution is simulated.
- Clean **Lean 4.34.1 replay** passed in 1305.561 seconds: fourteen proof modules,
  3,616 declarations, full import closure and axiom audit. All shared and replay
  input hashes remained stable. A real Lake probe confirmed that controlled
  settings select the same native kernel and imports under a poisoned inherited
  environment while isolating config/cache paths. The completed clean replay
  wrote no global Lean/Lake cache state.
- The final rebuilt compiler proved, compiled, and ran the original `null.adb`
  unchanged in `.silver/linux-aarch64/program-72YCWD/`. Its SHA256 remains
  `7b448e583d98d9f037b90d1379fe6afa1a16a93be16a7270c85aed30161a5021`.
- The native GPR tool rejects a missing host selection before building.
  A preservation audit checked 19,251 legacy/shared file entries and found no
  changed legacy tool/build/source artifacts. Only three intentional handoff
  notes in the old checkpoint directory changed; new notes are host-local.

Evidence is under `.silver/linux-aarch64/`: `compiler-proof.log`,
`compiler-build.log`, `tests.log`, `null-program.log`, `lean-proof.log`,
`lean-evidence.json`, `isolation-evidence.json`, and `compiler-inputs.json`.
Machine-readable compiler reports are in `compiler/obj/gnatprove/`.

Native macOS and Linux x86-64 execution have not run here. CI is configured for
all four supported host keys; native macOS validation remains independent and
nonblocking under the Oracle. The original compiler milestone checkpoint is
historical; use the README's host-selecting commands for all current work.
