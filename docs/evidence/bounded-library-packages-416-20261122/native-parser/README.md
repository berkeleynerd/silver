# Native package parser checkpoint — 2026-11-22

Implementation `fdc0442807` (primary equivalent `af24ff5237`) passed the native
parser build and **33 methods / 92 membership checks** on Linux x86-64. Every
managed command used the automatic eight-worker allocation and CPU affinity
0–7; fixture execution used a 16 MiB process stack. This packet establishes the
reported parser and frontend observations. Complete compiler helper proofs,
Lean/source correspondence, integrated application proof/audit and execution
remain separate requirements.

The harness compiles the actual native recognizer and reads the original three
files. It imports the retained authoritative `test_library_packages.py`, replaces
driver check/compile methods with parser membership checks, and excludes the
driver-only missing-source method and execution assertions. Nine additional
methods exercise reserved names, qualified-vs-bare identity, full-domain local
initialization, implicit/explicit aliases, read-only-call fact preservation,
return-call exclusion, original Main slice context, both selected audit source
fixtures, and the original queue sample. `parser-cases.json` records every
expected and actual exit status; no compilation, application audit or runtime
assertion from the original test class is claimed.

The first corrected-suite run found a fixture using mutable `N : Integer` as a
source for `X : P.Small`. The fixture now declares N in `0 .. 9`, preserving the
intended qualification check and the full-domain body rule. Its failing run log
is retained alongside the successful final run.

The pinned frontend controls compiled the original package body and Main,
then linked Main whenever compilation succeeded:

| Control | Observation |
| --- | --- |
| Package spec without a routine | Body rejected: “spec of this package does not allow a body”. |
| Same form with one routine | Compilation and link succeeded. |
| `Ada`, `Interfaces` | Body rejected: “language-defined units cannot be recompiled”. |
| `System` | Compilation rejected: “system.ads not formatted correctly”. |
| `Standard`, `GNAT` | Exact no-op three-unit controls compiled and linked. |

Only the demonstrated `Ada`, `Interfaces`, and `System` collisions were added to
the existing package identity exclusions. `Standard`/`GNAT` observations do not
establish selected GNATprove/report acceptance; those controls remain pending.

`validation.json` identifies final runs and implementation bytes.
`frontend-controls.json` retains exact commands, exits and diagnostics. Each
`runs/*/events.jsonl` retains the managed input/resource record, and its
`native.log` retains command output. The source fixtures and runner configuration
are copied verbatim, including original absolute paths; they are evidence of
these runs rather than a portable replay installation. `sha256.json` hashes the
retained evidence files. `pending-helper-inventory.json` is a conservative work
inventory, not proof coverage.
