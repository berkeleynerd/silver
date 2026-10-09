# Platform coexistence

Native OS and architecture select one of `linux-aarch64`, `linux-x86_64`,
`macos-aarch64`, and `macos-x86_64`. A shared checkout has no mutable host selector
and no cleanup or migration of another host's artifacts.

## Installation and output layout

- `.tools/<host>/` owns Alire, Lean, and Alire settings/cache/toolchains.
- `.silver/<host>/toolchain/` owns the Alire manifest copy, lock, and local settings.
- `.silver/<host>/generated/silver_build.ads` contains installation paths and the
  shell command prefix used by the actual compiler. SPARK verification includes
  this generated specification and the adjacent `silver_library_sources.ads`
  containing exact expected runtime sources; external-tool selection remains reviewed setup
  configuration.
- `.silver/<host>/compiler/` owns compiler objects, the executable, GNATprove
  intermediates, and content-bound proof provenance. The GPR project requires a
  supported `SILVER_HOST`; development tooling supplies the native value.
- `.silver/<host>/proof-cache/gnatprove/<lock-digest>/` holds the native solver
  cache for normal development and full-audit runs. Optional `prove --cold`
  instead allocates `compiler/obj/cold-<random>/` with fresh `gnatprove/` reports
  and sessions plus a separate `cache/`. It preserves normal warm state and
  every other host's artifacts, and prints its evidence path.
- `.silver/<host>/program-XXXXXX/` holds each byte-identical program snapshot,
  selected runtime library snapshots for output, generated project, proof
  reports and executable. The workspace contract checks
  the absolute installation prefix and an alphanumeric six-character suffix.
- `.silver/<host>/proof/` holds Lean verification inputs, generated certificates,
  Lake objects, and its manifest. The adjacent source link resolves to
  authoritative `src/`. Replay fingerprints shared inputs, scripts, tools,
  compiled artifacts and logs; shared inputs must remain unchanged.

Legacy flat-layout artifacts are retained. Authenticated release archives can be
copied from the old cache without modifying it. Foreign-host setup and execution
are rejected before invoking tools.

## Working directories and environment

The compiled SPARK executable accepts invocation from another working directory.
Relative source paths refer to the caller's directory. Tool invocations and
private workspaces use absolute paths recorded during bootstrap, so the caller's
directory does not become a second installation. Moving the checkout requires
rerunning bootstrap and rebuilding its compiler.

Bootstrap shell-quotes installation paths, including spaces and quotes, before
emitting byte-preserving Ada constants. The driver combines the fixed quoted
prefix with the checked workspace suffix for shell command arguments. Raw
absolute paths are used for file operations. Setup checks the existing path and
command-length bounds.

Alire 2.1.1 loads settings before applying `-s` and `-C`. Every invocation starts
in the selected host context, sets `ALIRE_SETTINGS_DIR` to that host's settings,
and removes `ALR_CONFIG`, `GPR_CONFIG`, `GPR_PROJECT_PATH`,
`GPR_PROJECT_PATH_FILE`, and `ADA_PROJECT_PATH`. Development tools pass explicit
native paths; the compiler's generated shell prefix does the same before Alire
starts. The compiler process retains the caller's working directory.

These controls isolate known configuration and search-path overrides. Native
libraries, build utilities, loader state and general environment integrity remain
external assumptions; see the [trusted computing base](trusted-boundary.md).
Python remains development/bootstrap/evidence tooling. Admission and compilation
remain in SPARK.

## Validation scope

Current capability and repair records are indexed in the
[README's platform evidence](../README.md#proofs-and-platform-evidence).
Earlier workflow results remain in [proof-workflow.md](proof-workflow.md);
[the review repair record](review-repairs.md) records the earlier baseline.
Platform regressions cover
canonical paths under symlinked `TMPDIR`, concurrent simulated setup for all four
host keys, preservation of other-host/shared/legacy files, inherited environment
overrides, and generated shell invocation from a foreign working directory.
Cross-host routing tests mock foreign downloads and executables; they do not
establish native ABI or proof behavior on those hosts.

A native Linux ARM64 probe also builds the actual generated Ada configuration
for an installation containing spaces, both quote types, shell punctuation and
Unicode, then exercises workspace creation and shell invocation from another
working directory with runtime assertions enabled. Its focused SPARK evidence
and the complete repaired validation are linked from the repair record.

The initial coexistence checkpoint was produced on **2026-10-08**, before the
review repairs, at baseline commit `32d50d6`. Its proof, test and Lean totals are
historical evidence and must not be substituted for current validation.
The [initial implementation checkpoint](implementation-checkpoint.md) is likewise
a historical baseline. A later external review ran the repaired `8b8619f` tree
natively on macOS ARM64: compiler proof, build and Lean/kernel checks passed;
three tests exposed another symlinked-temporary-directory fixture error. The
retained proof and Lean artifacts were subsequently checked read-only on Linux.
See [proof-workflow.md](proof-workflow.md) for evidence and scope.

An earlier external review also validated the staged incremental workflows on
macOS ARM64 before the cold-proof and direct-tool guard additions. It reported
passing compiler proofs, all tests under symlinked `TMPDIR`, and all Lean modes.
The retained compiler and final clean Lean artifacts were independently
corroborated on Linux; intermediate timings and test results remain reviewer
reports. At that stage, the cold/guard additions still awaited native macOS
validation. Later validation of the command-line baseline and the current
follow-up's platform scope are recorded in
[command-line-review-repairs.md](command-line-review-repairs.md).
Linux/macOS x86-64 validation also remains pending.
CI is configured for all four supported host keys, including a fresh Lean kernel
recheck, but has not executed. This work remains local as requested and the
repository has no Git remote. Linux is the primary validation platform; native
macOS validation remains independent and nonblocking under the Oracle.
