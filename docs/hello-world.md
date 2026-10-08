# Hello World capability and validation

The owner authorized this goal on 2026-10-08 under the unchanged Oracle.
The starting implementation commit was `fa558c6`; `e8c068b` established the
manifest-driven sample collection and moved the original null source unchanged.
This record describes the supported output capability and its completed native
Linux validation, independent review and local capability commit.

## Implemented scope

[samples/hello_world.adb](../samples/hello_world.adb) calls
`Silver_IO.Put_Line ("Hello, world!")`. The admitted class covers every printable
ASCII literal that fits the complete 4096-byte source bound, including empty
strings and doubled quotes. The required context clause, literal and qualified
call form one coherent capability. Null remains the other complete production;
context-only null, repeated calls, variables and concatenation remain excluded.
The [language specification](../language.md) and
[catalogue](../catalogue/silver.json) give the exact rules.

The SPARK wrapper checks every libc byte write, LF and final flush. Detected
failure exits unsuccessfully; partial output is possible. It introduces no
Silver-owned C code or SPARK-off implementation. Physical output and progress
have the [documented boundary](trusted-boundary.md#literal-output-boundary).
The [runtime experiment](hello-runtime-experiment.md) records the focused native
proof, reports and ABI/failure probes that selected this implementation.

Both application-unit reports have empty obligation lists. Output additionally
requires the fixed library's nonempty proof and both runtime reports. The
compiler copies the three selected library files unchanged into the private
application workspace and checks their byte identity after proof and build.
The bounded library-report scanner verifies complete selected coverage and every
check; it has verified safety and reviewed format semantics, not a separate
formal JSON-authentication claim.

Lean extends the independent grammar, decoded literal bounds, checked source
expressions and recursive uniqueness, actual runtime statement rendering,
current-language semantics and conditional external-tool pipeline. The library
proof premise remains separate from empty application discharge. Seven source
certificates are generated and checked independently to allow Lake scheduling;
the handwritten source bindings and import facade remain protected inputs.
See [assurance.md](assurance.md) for theorem scope and external premises.

## Review and development checks

An independent read-only subthread reviewed the literal grammar, checked
expression/statement translations, runtime guards, fixed-library proof premise,
source snapshots, report integration and claim wording. It found no blocking
correctness issue. This review did not rerun proofs or establish platform support.

Focused native Linux ARM64 checks passed for the output recognizer, output
library, library snapshots and runtime report checker. The final application
proof command (`-U`, all checks, pinned provers, 10000 steps, no wall-clock timeout,
all detected cores) proved and built Hello World, which printed the exact bytes
and exited successfully. Empty, printable/escaped and maximum-length literals,
write/flush failures and changed/missing evidence have targeted tests.

The new library integrity suite passed all scenarios: mutation of each copied
file during proof or build, each missing runtime report, and fixed installation
selection despite caller-planted package sources. The checker-platform suite
passed after the certificate split, including symlinked temporary paths and all
seven generator routes. Canonical suite results belong below once complete.

A development test initially observed unrelated concurrently created application
workspaces and cleaned them up. New output/sample tests now own only the
workspace named by their published executable; integrity fixtures use their own
workspace marker. The final whole suite runs serially. Cold native Lake and symlinked-platform harnesses exceeded their old
60-second limits amid concurrent proof work; their limits are now 180 seconds.
The three full-size report stress cases likewise have 120-second harness limits
instead of 30 seconds. These changes do not alter proof options or acceptance. An isolated monolithic certificate compile was deliberately stopped
when the parallel canonical replay started; it is not successful proof evidence.
An earlier incremental Lean replay built and audited successfully but correctly
rejected its final provenance because source/proof edits overlapped the run. The
subsequent full replay below checked the frozen implementation.

Refreshing the native Alire context after the package-description update hit its
five-second dependency-solver timeout under load and left incomplete tool
selection. A native local `solver.timeout = 120`, explicit `alr update` and
successful bootstrap restored the same package versions. An earlier suite crossed
that interruption; its failed log is retained as
`.silver/linux-aarch64/hello-tests-before-toolchain-repair.log`. The subsequent
complete suite passed.

## Final validation

Validation ran natively on Linux ARM64 with GNAT/GNATprove 16.1.0 and pinned
Lean 4.34.1. The final implementation build passed, and the complete suite passed
all 109 tests in 60.697 seconds. Its log is
`.silver/linux-aarch64/hello-tests.log`. This includes both manifest samples,
real proof/build/run and output-failure cases, source/library identity checks,
report stress, evidence rejection and native Lake/path-portability regressions.

`python3 scripts/check_lean.py --full` passed in 248.157 seconds. It retained
native Lake artifacts, completed 40 build jobs, freshly audited 7,589 declarations
with only `propext`, `Classical.choice` and `Quot.sound`, and passed independent
`leanchecker --fresh Silver.Audit`. It was a full replay with cache reuse, not
`--clean`. The seven checked-in certificate candidates match the regenerated,
checked modules. Evidence binds all current captured source/script inputs,
workspace inputs, proof objects and tools; those hashes were rechecked after
completion. The manifest SHA256 is
`a22c9dd3e982d7078ffcacba6f4ab3703a63ae531adbb431d9d14de3fa688d61`.
The complete command log is `.silver/linux-aarch64/hello-lean-full.log`.

The initial canonical all-core compiler audit failed inside GNATprove's JSON
parser. The failure log and complete report/session directory were preserved
after all workers exited under
`.silver/linux-aarch64/hello-compiler-proof-failure/`. During the failed run a
read-only inspection observed `GNAT-TEMP-000020.TMP` with 2,129 bytes and 513
trailing NULs beginning at offset 1,616, matching the parser diagnostic. The
observed SHA256 was
`df69ef1ef57066e7674d80b2d407d7e15fd7c4c69f83d96aec23c9c44c0ea9b0`.
However, the post-exit snapshot contains valid JSON instead, with SHA256
`63e2ef1c2b68a5bd5853c2855c815bb16c3a62542e9f33f131c7c8c76965f28d`.
The malformed bytes were therefore not successfully retained as a reproducer.
The corresponding cache entry also contains valid JSON; no empty or malformed
hashed prover-result entry was found. All retained frontend `.gnat-json` inputs
parse correctly. Other temporary results are empty or report a lost Why3 socket.
The source/cache/report directories use this sandbox's virtiofs mount, but neither
a filesystem fault, a parallel race nor a reliable workaround is established.
No automatic retry was added, no obligations were suppressed, and all-core
defaults remain.

An explicit `python3 scripts/dev.py prove --full --jobs 1` comparison used the
same logical requirements and native session/cache reuse. It was deliberately
interrupted after about eight minutes because serial CVC5 attempts were consuming
minutes apiece. Its partial reports and log are preserved under
`.silver/linux-aarch64/hello-compiler-proof-serial-diagnostic/`; they are not a
completed audit or evidence of a reliable workaround. The generated driver
verification input is byte-identical to the successful focused proof.

The four-worker warm full audit also failed in the JSON parser, without a
reported failed SPARK obligation. Its reports/log are preserved under
`.silver/linux-aarch64/hello-compiler-proof-four-worker-failure/`. A small isolated
wrapper probe passed eight first/cached-output comparisons across native overlay
and virtiofs paths; it did not reproduce GNATprove's concurrent pipeline failure.
Its record is
`.silver/linux-aarch64/diagnostics/wrapper-probe-wd2ed5er/results.json`.

The subsequent `python3 scripts/dev.py prove --cold --jobs 4` passed with fresh
isolated sessions and cache and unchanged logical requirements: **1,364 checks**
(247 flow and 1,117 proof), 14 units and 125 entities. The complete audit accepted
only the 14 approved imported entities with spec-only coverage and reported 19
known tool-limitation notes; no obligation was skipped, justified or unproved.
The completed manifest records `mode: cold`, initially absent sessions/cache
entries, the full command, source/configuration/tool identities and all report
hashes. Its SHA256 is
`edb27a288ca64b3c66a510f803303a62ab006a0db23ec42f16400acc63be85ad`.
The standalone provenance/evidence auditor passed again against those reports.
The successful log is `.silver/linux-aarch64/hello-compiler-proof-cold.log`.
This is a cold full audit, not evidence that the warm-state defect is fixed.
The ordinary canonical report directory retains the failed warm run; the
successful complete evidence is in the separate cold directory below.

The final build was already up to date with the tested compiler. A fresh
compilation of the checked-in Hello World sample then passed admission, proof,
library-report checking and build; executing its published binary produced
exactly `Hello, world!` plus LF, empty stderr and status 0. Its command log and
result are `.silver/linux-aarch64/hello-final-application.log` and
`.silver/linux-aarch64/hello-final-application.json`.

The current native evidence paths are:

- `.silver/linux-aarch64/compiler/obj/cold-rdftsh61/gnatprove/`
- `.silver/linux-aarch64/lean-evidence.json`
- `.silver/linux-aarch64/lean-proof.log`

Native macOS validation is independent and nonblocking. Retained macOS workflow
results predate this capability. Neither x86-64 validation nor a hosted CI run is
claimed. The work remains local-only; unrelated `tmp/` material is preserved.
