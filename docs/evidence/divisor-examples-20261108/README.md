# Divisor examples — retained application evidence, 2026-11-08

This packet retains #343's successful focused application checkpoint for Least
common multiple, Coprimes, Sum of divisors and Tau function. The validated
source/manifest target is `5262fb81fa38c4afd55debf87ea44f50720aaf8c` in
`/home/canto/src/github.com/berkeleynerd/silver/tmp/divisor-examples-343`.
Each exact author source is `main.adb` inside its application archive; source
hashes and sizes are recorded in the [original summary](application-validation/summary.json).

Managed run `20261108T211402-d028fe5c343d` finished successfully on native Linux
x86_64 in **66.335889714 seconds**, reserving **22 workers** from 22 available
CPUs without an explicit worker override. Its UTC interval was
2026-11-08 21:14:04.363151 through 21:15:10.479725. The original ledger is
`.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/20261108T211402-d028fe5c343d`.
The final summary reports four passed results and the last ledger event reports
`outcome: success`. The complete original native log and events are retained
losslessly compressed under [managed-run](managed-run).

| Source | Audited helpers and complete formal domains | Flow checks | Proof checks | Demonstrated output |
| --- | --- | ---: | ---: | --- |
| `rosetta_least_common_multiple.adb` | `GCD`, `LCM`: each argument -1000..1000 | 21 | 59 | Twelve pairs: required 12,18; all sign combinations; zero in either/both positions; boundaries and units |
| `rosetta_coprimes.adb` | `GCD`, `Coprime`: each argument -1000..1000 | 21 | 56 | All five required pairs, followed by eight zero/unit/sign/boundary controls |
| `rosetta_sum_of_divisors.adb` | `Sum_Of_Divisors`: 1..100 | 20 | 52 | Every integer 1..100, including sigma(100)=217 |
| `rosetta_tau_function.adb` | `Tau`: 1..100 | 20 | 51 | Every integer 1..100, including Tau(100)=9 |

Each program passed production admission, application/library flow and proof,
the unchanged report auditor and proof policy, native build, and exact
stdout/stderr/exit-status comparison. Each executable ran once without
arguments, returned zero and produced empty stderr. The report auditor covered
five units per program: nineteen entities for LCM/Coprimes and eighteen for
Sum of divisors/Tau. Both separate GCD helpers were listed explicitly in
`application_functions` and audited along with their callers. Limitation-note
counts were zero; the original summary retains the permitted advisory counts.
These application results do not establish universal language assurance.

## Command and unchanged production policy

[validate_divisor_samples.py](validate_divisor_samples.py) is the exact
agent-authored validator used by the run, retained outside `scripts/`. It uses
the existing `scripts.check_evidence.audit_reports` and
`tests.test_samples.SupportedSampleTests.assert_application_proof_policy`
without altering their policies. Retention does not add a compiler
proof-provenance input. The managed command used the retained installation's
Alire environment; exact command arrays, versions, hashes and reservations are
in [events.jsonl.gz](managed-run/events.jsonl.gz). Its helper arguments were:

```sh
/usr/bin/python3 /home/canto/src/github.com/berkeleynerd/silver/tmp/divisor-examples-343/tmp/validate_divisor_samples.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298 \
  --source-root /home/canto/src/github.com/berkeleynerd/silver/tmp/divisor-examples-343 \
  --output /home/canto/src/github.com/berkeleynerd/silver/tmp/divisor-examples-343/tmp/application-validation
```

For each absolute sample path the validator ran `silver check PATH` and
`silver compile PATH` with the retained delivered compiler. It required the
compilation workspace's author snapshot to equal the input bytes, audited the
reports and ran the resulting `bin/main` with a ten-second timeout. The compiler
SHA-256 is `807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.

Each archived SARIF records the production GNATprove invocation:

```text
-P <workspace>/program.gpr -U --mode=all --report=all --warnings=continue
--checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=100000
--timeout=0 --memlimit=1000 -j0 --no-loop-unrolling --no-inlining
```

The generated projects use Ada switches `-gnat2022 -gnata -gnato`. Disabling
inlining and loop unrolling preserves whole-helper checks over the complete
declared domains, including both GCD helpers. The admitted, proved and built
sources are the same Ada/SPARK author bytes; no annotated replacement source
was introduced.

## Retained contents and independent expectations

- [application-validation](application-validation) contains the complete
  original summary and, per program, the unchanged `application-evidence.tar.gz`,
  `check.log`, `compile.log` and actual `execution-0.stdout`/`.stderr`. Each
  archive retains author/runtime source snapshots, generated project,
  SPARK/SARIF reports, proof summary and available Why3 sessions. Executable
  and object payloads are omitted by the original validator.
- [author-notes](author-notes) contains byte-preserved historical implementation
  handoffs, admission records, independent mathematics/domain JSON and both
  derivation scripts. These are **prevalidation author notes**: references to
  pending parent validation, uncommitted scratch or original `tmp/` paths
  describe those earlier handoffs. The scripts retain their original layout
  assumptions; they were not rerun or rewritten during packet retention.
- LCM/Coprimes expectations use Python `math.lcm`/`math.gcd`. The recorded
  calculation checks all 1,002,001 magnitude pairs in 0..1000, covering all
  4,004,001 signed pairs by normalization. The notes establish the twenty-step
  Euclidean-loop bound and zero/sign handling across the complete domains.
- Sum/Tau expectations use prime-factorization product identities independent
  of the source divisor scan. A separate recorded calculation matches the
  recurrence and both nontruncating guards for every input 1..100; the notes
  justify the sum bound 4950 before addition and count bound 99 before increment.
- [installation-comparison.json](installation-comparison.json) retains the
  supplied comparison: 145 installation inputs match the merged baseline
  `a74e67c3a8d1c3ec6213519e4b4664c6e66825e7`, with no changed inputs.
- [integrity-check.json](integrity-check.json) records original/copy hash
  agreement, readable archives, archived author bytes against the exact target,
  report count/declared-helper checks and exact actual output against its tracked
  manifest. `SHA256SUMS` covers every retained file except itself.

Expected-output files and proposed manifest entries are omitted: the tracked
target [manifest](../../../samples/manifest.json) already supplies exact
expectations and this packet retains actual output. The manifest's complete
hash remains in the original summary and the integrity record.

This retention task performed no build, proof, application execution or test
rerun. No new complete compiler/Lean checkpoint or fresh full-suite result is
claimed. The independent GPT-6 Astra / Max
[review](../../reviews/review-divisor-examples-20261108.md) accepted this exact
target and baseline applicability with no material finding. The reviewer
re-audited all four report/policy sets and matched all 93 archived files and
225 output lines to their inputs and independent expectations. The reviewer
also confirmed unchanged native evidence inputs (2,588 inputs and 12 tools)
and Lean evidence inputs (927 inputs and two tools). The 645-ID test inventory
is unchanged: 644 IDs retain applicable results, while the manifest check has
76 retained cases plus these four fresh cases. This is composed coverage,
not a fresh full-suite run. The review is separate from this packet-retention
work. Native macOS validation is not claimed.

Selected retention model/effort: GPT-6.1 Sol / Extra High, carried forward from
the implementation assignment. Live-runtime introspection was unavailable.
Only this evidence directory is changed by the retention commit.
