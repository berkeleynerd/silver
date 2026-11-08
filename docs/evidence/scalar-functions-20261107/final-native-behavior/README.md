# Scalar-function native behavior — 2026-11-07

The native compiler build, all 23 focused scalar-function tests, and the existing
`Is_Prime` sample passed on `linux-x86_64`. This is the bounded #298 behavior
checkpoint for integration snapshot `0b24ae95f8`.

All files under `src/` match that reference byte for byte. The source Git tree is
`a4536bb894cebe1bfe55eab78d9df1b66eb8b282`. Synchronization commit `b2336060d4`
copied the reference report parser and final test file into this separate
worktree; the sample and manifest already matched. The relevant native project
files, scripts and shared test helpers also matched the reference when the
packet was collected. Later proof repairs are outside this packet's scope.

The compiler SHA-256 is
`7a70ed31116ee5ed8cd6948587155c741de093cf0d9beaa7816a6496ac7514f4`.
[index.json](index.json) records the complete source-file hash inventory,
compiler and Image adapter identities, retained input snapshots and artifact
hashes. A hash marked `compressed: true` applies to the decompressed bytes.

The worktree initially had no native installation or artifacts. Existing Alire
archive, cache, settings and toolchains were physically copied with
`cp -a --reflink=auto`, then `python3 scripts/bootstrap.py` initialized the
private installation. The active parent installation and caches were not
changed. The toolchain was GNAT/GNATprove 16.1.0, Alire 2.1.1 and GPRbuild package
26.0.1 (binary banner 26.0.0). The retained
[setup record](setup/final-native-setup.json.gz),
[bootstrap log](setup/final-native-bootstrap.log.gz) and managed events identify
the actual private paths, tools and inputs.

Each managed run reserved six workers. The build used
`python3 scripts/dev.py build --jobs 6`. Tests and the sample used managed
`scripts/dev.py tool --jobs 6` runs with explicit workspace/input declarations.
Their child commands ran through `taskset --cpu-list 16,17,18,19,20,21` so the
compiler's existing `-j0` descendants stayed within six CPUs. The runners record
their observed affinity; the managed controller retained the full pool view.
This allocation coexisted with the original eight-worker native run and two
four-worker Lean reservations in other worktrees.

| Managed run | Scope and outcome | Managed elapsed time |
| --- | --- | --- |
| `20261107T223625-492cb4acfdfc` | Native compiler build passed. | 51.154 s |
| `20261107T223934-c6e442c2b547` | Test launcher failed before any tests ran. | 13.789 s |
| `20261107T224100-ba6111ac6456` | All 23 scalar-function tests passed. | 117.278 s |
| `20261107T224350-4e936a797061` | Existing `Is_Prime` admission, proof/build, report audit and execution passed. | 58.590 s |

The initial launcher supplied an explicit unittest top-level directory (`-t`),
which rejected the namespace-style `tests` directory as non-importable. The
corrected [test runner](runners/run-final-scalar-tests.py) used the repository's
normal `discover('tests', pattern='test_scalar_functions.py')` from the root.
The test source, compiler source and compiler binary were unchanged between
these attempts. The failed run is retained as a launcher failure, without a
claim that tests executed. The successful unittest run took 95.142 seconds and
included both native proof/build/execution tests and the two final admission
review cases. Exact test names and outcomes are in its
[native log](runs/20261107T224100-ba6111ac6456/native.log.gz).

The [sample runner](runners/check-final-is-prime.py) reused
`SupportedSampleTests.assert_application_proof_policy` and `audit_reports` for
the existing `samples/rosetta_primality_by_trial_division.adb` manifest entry.
It confirmed exactly one byte-identical application source snapshot in the
generated project, checked the standard application/function report policy,
and compared stdout, stderr and exit status exactly with the existing manifest.
The source SHA-256 is
`6e2d5263135fb3aa0c36554425303c3b87a375315207c37ee897c5ed71b457a4`.

The sample audit counted 5 units, 18 entities, 20 flow checks, 49 proof checks
and 1 termination check, with 1 assignment advisory and 1 Image advisory.
Execution printed exactly the manifest's primes from 2 through 97, with empty
stderr and exit status 0. The executable SHA-256 is
`1f55be4ae0520ad7b02e235636bc320a33b1a4a339f64c95991d24dae1f98a3c`.
[sample/summary.json](sample/summary.json) records the results, hashes and
retained workspace, `.silver/linux-x86_64/program-RyA54D`. The packet includes
the original reports, unchanged source snapshot, project, stdout and stderr.

The runner copies are historical artifacts from the worktree's `tmp/`
directory; their root calculation assumes that original location. Their exact
managed command lines and input identities are retained in each run's
`events.jsonl.gz`. All four event/log pairs are indexed, including the failed
launcher. No new test cases were designed for this checkpoint.

These results establish the stated native build and application behavior
checks. Complete compiler Bronze/Silver verification, Lean checking, complete
source correspondence and final integrated assurance remain the lead's work.
This packet does not promote language or Rosetta support and makes no macOS or
CI validation claim. Successful runs are retained for integration; a later
source change requires its own correctly scoped evidence.

The live agent model/effort and token/cost measurements were not independently
exposed. The native elapsed times above are not whole-team cost measurements.
The live harness goal was `null` at handoff; CLI recall was not updated by this
subthread. No native run remains active in this worktree for this assignment.
