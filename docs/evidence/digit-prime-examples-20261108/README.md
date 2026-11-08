# Digit and prime examples — retained application evidence, 2026-11-08

This packet retains #344's successful focused application checkpoint for Sum
digits of an integer, Happy numbers, Additive primes and Attractive numbers.
The validated source/manifest target is
`f2842c6d62ecab7c6d44848f22363a7558f43912` in
`/home/canto/src/github.com/berkeleynerd/silver/tmp/digit-prime-examples-344`.
Each exact author source is `main.adb` inside its application archive; source
hashes and sizes are in the [original summary](application-validation/summary.json).

Managed run `20261108T214753-620fcc9bc295` finished successfully on native
Linux x86_64 in **65.653239362 seconds**, reserving **22 workers** from 22
available CPUs without an explicit worker override. Its UTC interval was
2026-11-08 21:47:55.001517 through 21:49:00.353961. The original ledger is
`.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/20261108T214753-620fcc9bc295`.
All four summary results passed, and the final ledger event reports
`outcome: success`. Original events and native log are retained losslessly
compressed under [managed-run](managed-run).

| Source | Audited helpers and complete formal domains | Flow checks | Proof checks | Actual output |
| --- | --- | ---: | ---: | --- |
| `rosetta_sum_digits_of_an_integer.adb` | `Sum_Digits`: N 0..2147483647, base 2..36 | 20 | 55 | 17 required-example and zero/base/Integer-boundary cases |
| `rosetta_happy_numbers.adb` | `Sum_Squared_Digits`, `Is_Happy`: 0..999 | 21 | 50 | Exactly 1,7,10,13,19,23,28,31 |
| `rosetta_additive_primes.adb` | `Is_Prime`, `Digit_Sum`: 0..499 | 21 | 52 | All 54 additive primes below 500 |
| `rosetta_attractive_numbers.adb` | `Is_Prime`: 0..120; `Prime_Factor_Count`: 1..120 | 21 | 52 | All 74 attractive numbers through 120 |

Every program passed production admission, application/library flow and proof,
the unchanged report auditor and proof policy, native build, and exact
stdout/stderr/exit-status comparison. Each executable ran once without
arguments, returned zero and produced empty stderr. The 153 output lines
match the tracked target manifest. The report auditor covered five units per
program: eighteen entities for Sum digits and nineteen for each other program.
Every helper is listed in `application_functions` and audited along with its
caller. Limitation-note counts were zero; the summary retains the permitted
advisory counts. Application results do not establish universal language assurance.

## Command and production policy

[validate_digit_prime_samples.py](validate_digit_prime_samples.py) is the exact
agent-authored validator used by the run, retained outside `scripts/`. It calls
the existing `scripts.check_evidence.audit_reports` and
`tests.test_samples.SupportedSampleTests.assert_application_proof_policy`
without changing their policies. Retention adds no compiler proof-provenance
input. The managed command used the retained installation's Alire environment;
exact command arrays, identities and reservation are in
[events.jsonl.gz](managed-run/events.jsonl.gz). Its validator arguments were:

```sh
/usr/bin/python3 /home/canto/src/github.com/berkeleynerd/silver/tmp/digit-prime-examples-344/tmp/validate_digit_prime_samples.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298 \
  --source-root /home/canto/src/github.com/berkeleynerd/silver/tmp/digit-prime-examples-344 \
  --output /home/canto/src/github.com/berkeleynerd/silver/tmp/digit-prime-examples-344/tmp/application-validation
```

For each absolute sample path it ran `silver check PATH` and `silver compile
PATH`, required the author snapshot to equal the input bytes, audited the
reports and executed `bin/main` with a ten-second timeout. Compiler SHA-256:
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.

Each archived SARIF records the production GNATprove invocation:

```text
-P <workspace>/program.gpr -U --mode=all --report=all --warnings=continue
--checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=100000
--timeout=0 --memlimit=1000 -j0 --no-loop-unrolling --no-inlining
```

Generated projects use `-gnat2022 -gnata -gnato`. Disabling inlining and loop
unrolling preserves whole-helper checks over their complete declared domains.
Admitted, proved and built source is the same Ada/SPARK author bytes; no
annotated replacement was introduced. The initial author additive-prime draft
used reserved identifier `Digits` and was rejected at admission; the retained
failed log records that result. Renaming it `Sum` preceded final admission and
this successful production run. No production proof/build failure is recorded.

## Contents and independent expectations

- [application-validation](application-validation) contains the original
  summary and all four unchanged application archives, check/compile logs,
  and actual stdout/stderr files. Archives retain author/runtime snapshots,
  generated projects, SPARK/SARIF reports, proof summaries and available Why3
  sessions. The original validator omits executable and object payloads.
- [author-notes](author-notes) preserves historical prevalidation handoffs,
  admission records, domain/mathematics results and both derivation scripts.
  References to pending parent validation, scratch, original `tmp/` paths or
  proposed manifests describe those earlier handoffs. Scripts retain their
  original layout assumptions; retention did not rerun or rewrite them.
- Sum-digits expectations use base strings and character values. Selected
  checks cover **147,507 input/base pairs**, not the entire natural-Integer
  domain. The analytical argument establishes 31-step sufficiency for every
  declared input and proves the <=1050 guard never skips a digit.
- Happy expectations use decimal strings and cycle detection, independent of
  the sample's fixed iteration count. Recorded checks cover all **1,000**
  inputs of both helpers. The notes include the three-digit/<=162 guard
  argument and the 244-state argument, including the first transformation
  into 0..243. The complete prefix 1..31 yields exactly the required eight.
- Prime-pair expectations use a sieve, decimal text and a prime-power
  contribution table for factor multiplicities. Recorded comparisons cover
  the complete finite declared helper domains: 0..499 for primality/digit
  sums (including the attractive helper's 0..120), and 1..120 for factor
  counts. The notes justify every guard and all seven divide-out attempts.
- [installation-comparison.json](installation-comparison.json) retains the
  supplied comparison: 145 installation inputs match baseline
  `87e18b4c3ede6efac69a5fe46178510e9f17c2fa`, with no changed inputs.
- [integrity-check.json](integrity-check.json) records original/copy hash
  agreement, readable archives, exact target source correspondence, declared
  helper inventories and actual output against the target manifest.
  `SHA256SUMS` covers every retained file except itself.

Duplicate expected stdout and proposed manifest files are omitted: the tracked
target [manifest](../../../samples/manifest.json) supplies exact expectations.
Its complete hash is retained in the summary and integrity record.

Independent GPT-6 Astra / Max applicability
[review](../../reviews/review-digit-prime-examples-20261108.md) subsequently
accepted the implementation, final application evidence and retained baseline
reuse with no material finding. The integrity record preserves its earlier
retention-stage status; the linked review supplies the final applicability
conclusion. Compiler and Lean assurance were not freshly rerun here.
The accepted coverage combines 80 retained sample cases and four fresh cases;
it is not a fresh full-suite result. This retention task performed no build,
proof, application execution, test or derivation-script rerun. Native macOS
validation is not claimed.

Selected retention settings: GPT-6.1 Sol / Extra High, carried from the
implementation assignment; live runtime introspection was unavailable.
Only this evidence directory is changed by the retention commit.
