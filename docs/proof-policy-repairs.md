# Application proof policy repairs

This 2026-10-15 record addresses L1/#18 and L3/#20 from the
[review of e2c4fc2..343c2f8](reviews/review-343c2f8.md#32-low), under the
[selected-repair authorization](review-343c2f8-repairs.md). The isolated implementation
starts from `39d0ad38e6`, under the authorization published in
`618c28a77cdf011f338a31fcb0e9022743a338de`; that intervening commit changes only
documentation. It changes no language membership rule or Oracle guarantee.

## Explicit policy

Application proof retains `--level=2 --prover=cvc5,z3,altergo --steps=100000
--timeout=0 -j0` and passes **`--memlimit=1000`** explicitly. This preserves
GNATprove 16.1's effective policy: with level 2 the earlier zero option meant
unset, selecting the same 1,000 MiB allowance. The purpose is to retain the
existing per-process resource budget and observed automatic-discharge behavior
while making the limit visible and testable. It is not an aggregate host-memory
budget; frontend, flow analysis and concurrent prover processes need additional
resources.

The review independently observed Linux `RLIMIT_AS` of 1,048,576,000 bytes for
each external solver, corroborated with the effective Why3 limits. Its memory
evidence does **not** establish uniform positive headroom: Alt-Ergo ran out of
memory at about 899 MB on an admitted 64-leaf verification condition. Resident
memory and the enforced address-space limit are different quantities, so their
numerical difference is not available prover headroom. Z3 proved every hard goal
measured in that review under the cap. Preserving this policy retains that
observed behavior; it does not promise that each portfolio member succeeds or
that all admitted programs fit a proved solver-memory bound. A fresh 64-leaf
compile below also succeeds under the explicit cap. The completion premise in
[assurance](assurance.md) and [the trusted boundary](trusted-boundary.md) now
includes both normalized steps and memory, with sufficient environmental
resources. An admitted program that fails proof remains a defect.

For the pinned toolchain, GNATprove normalizes its 100,000-step option to these
effective external-prover settings in `why3session.xml`:

| Prover | Why3 step limit | Time limit | Memory limit (MiB) |
| --- | ---: | ---: | ---: |
| Alt-Ergo | 100,000 | 0 | 1,000 |
| CVC5 | 3,515,000 | 0 | 1,000 |
| Z3 | 80,450,000 | 0 | 1,000 |

The internal Why3 `Trivial` prover has separate settings. A zero time limit
does not bound frontend/flow work, operating-system delays or total compilation
time. Historical records showing the earlier zero memory flag retain that
literal command; they must not be read as measurements of unlimited memory.

## Regression

[The sample tests](../tests/test_samples.py) now check the recorded application
options, including step/time/memory allowances, and inspect effective Why3
defaults and per-attempt overrides for each selected external solver. Output
compilations in the original parallel checkpoint retained sessions and all three
prover declarations. Null uses its distinct warnings policy and may have no
external solver session.

For some output samples, the first configured solver discharges every goal under
the 2026-11-21 one-worker application configuration. The sample regression therefore
requires an external attempt with a recorded result for output, while checking the exact three-solver command
and the effective defaults and overrides for every observed solver. It does not
require redundant attempts after discharge. Complete obligation auditing remains
unchanged; the earlier three-solver observation describes the parallel checkpoint.

`test_maximum_dynamic_expression` admits, proves, builds and executes the
retained meaningful 64-leaf source: an immutable input `D`, an executable
validity/length guard `D'Length <= 64`, and `Put_Line` of 64 copies of `D`.
It audits all five selected units, checks the byte-identical proof/build source,
and verifies both the empty input's newline and a 64-byte input's 4,096 bytes
plus newline. Its 300-second test-runner deadline is separate from production
prover policy. Ordinary suite execution cleans up the temporary program.

## Focused Linux evidence

The actual host was Linux x86_64. `python3 scripts/dev.py build` succeeded in
the isolated `tmp/review-proof-policy-343c2f8` worktree, using the existing pinned
tools and that worktree's native artifacts. The new test ran once through
`scripts/dev.py tool` with a scratch unittest runner that retained its successful
program workspace instead of registering the usual removal cleanup. It changed
no assertions or production execution. The run passed in **50.496 seconds**;
this is a test duration under concurrent host work, not a solver bound.

The retained workspace, relative to that worktree, is
`.silver/linux-x86_64/program-VtoNUA/`. It contains the exact author snapshot,
executable, five complete reports, SARIF and six Why3 sessions. The report audit
accepted 17 entities, 19 flow checks and 110 proof checks. Main has 63 proved
range-check records; Z3 proved all 126 Main proof attempts, with a maximum
**10,738 normalized steps**, reproducing the historical specimen above the old
10,000-step allowance. Other solvers had unsuccessful attempts; those are not
unproved obligations when another selected solver discharges them. All six
sessions passed the effective-limit assertions.

The generated 395-byte source has SHA256
`3dfeee525b935212f90c161d4eadc87ac1707aa1f33f347bcc008b2ef75ffbae`.
The measured driver source has SHA256
`066f115f8cc9077845c2a13a9a1b711790f951cedf39ddd16637526e3271b4df`;
the rebuilt executable has SHA256
`847c99ef854353a355cc09a41b88c0b6c13378ffce7e4e5ff7d9254883af3eea`.
The test source has SHA256
`fe12ea02a5d505e20ceda2c35841abefac6cfcd73c1bd3b0b3b2f0a1f0d85434`.
Scratch runners and structured results are retained in
`tmp/check_proof_policy.py`, `tmp/proof-policy-evidence.json`,
`tmp/check_policy_controls.py` and `tmp/proof-policy-controls.json` in that
worktree.

A separate fresh null compile passed its option assertion and is retained in
`.silver/linux-x86_64/program-FbKzhj/`. The assertion helper also rejected 21
negative controls made on copies of the actual evidence: three command changes
(10,000 steps, a nonzero time limit and zero memory), plus changing each of the
three effective limits in each solver's declaration and in a proof-attempt
override. The retained production reports were not modified.

These focused checks do not replace the integration branch's compiler-proof
and source-correspondence checkpoint. No full suite, full compiler proof, Lean
rerun or native macOS run is claimed by this lane. Samples and measured limits
are regression evidence, not universal completion proofs.
