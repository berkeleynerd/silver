# Callable integer examples — retained application evidence, 2026-11-08

This packet retains the successful focused application checkpoint for #342's
Factorial, Fibonacci sequence, Signum and Sum multiples of 3 and 5 programs.
The validated source/manifest target is commit
`db8ca3495c6b2a118f4bd9ebe8bbcddad2e6fa0f` in the integration worktree
`/home/canto/src/github.com/berkeleynerd/silver/tmp/callable-examples-342`.
The four exact author source snapshots are `main.adb` inside their respective
application archives; their hashes and byte sizes appear in
[the original summary](application-validation/summary.json).

Managed run `20261108T194440-c7a94430faf1` completed successfully on native
Linux x86_64 in **76.284483401 seconds**, using **22 workers** from 22 available
CPUs (no explicit worker override). Its UTC interval was
2026-11-08 19:44:42.484042 through 19:45:58.486671. The original ledger was
`.git/silver-runs/linux-x86_64/78cde64c3e47f2cb/runs/20261108T194440-c7a94430faf1`.
The complete original events and native log are retained, losslessly compressed,
under [managed-run](managed-run).

| Source | Callable helper/domain | Flow checks | Proof checks | Exact execution output |
| --- | --- | ---: | ---: | --- |
| `rosetta_factorial.adb` | `Factorial`, 0..12 | 20 | 51 | All 13 domain values, including 0! = 1 and 12! = 479001600 |
| `rosetta_fibonacci_sequence.adb` | `Fibonacci`, 0..46 | 20 | 52 | All 47 domain values, including F0 = 0 and F46 = 1836311903 |
| `rosetta_signum.adb` | `Signum`, full Integer | 20 | 50 | -10, 42, 0 and both Integer endpoints |
| `rosetta_sum_multiples_of_3_and_5.adb` | `Sum_Multiples`, 0..1000 | 20 | 58 | Eleven zero/boundary/overlap cases, including 1000 -> 233168 |

Every program passed production admission, application/library flow and proof,
the unchanged proof-policy and report auditors, native build, and byte-for-byte
stdout/stderr plus exit-status comparison. Each executable ran once with no
arguments; each expected exit status was zero and stderr was empty. The report
auditor covered five units and eighteen entities per program, including the
declared helper. All limitation-note counts were zero. The original summaries
retain the complete statistics, including the permitted advisory counts.
These application outcomes do not establish universal language assurance.

## Commands and options

The [validation helper](validate_callable_samples.py) is **agent-authored
validation glue**, copied byte-for-byte from the run input. It invokes the
delivered production compiler and existing `scripts.check_evidence.audit_reports`
and `tests.test_samples.SupportedSampleTests.assert_application_proof_policy`;
it does not change their policies. It is retained here, outside `scripts/`, so
its retention does not add a compiler proof-provenance input or change the
Silver author-source policy.

The managed runner executed this helper through the retained installation's
Alire toolchain environment (`alr ... exec -- /usr/bin/python3`). Exact original
command arrays, tool versions/hashes, resource reservations and run events are
in `managed-run/events.jsonl.gz`. The helper arguments were:

```sh
/usr/bin/python3 /home/canto/src/github.com/berkeleynerd/silver/tmp/callable-examples-342/tmp/validate_callable_samples.py \
  --installation /home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298 \
  --source-root /home/canto/src/github.com/berkeleynerd/silver/tmp/callable-examples-342 \
  --output /home/canto/src/github.com/berkeleynerd/silver/tmp/callable-examples-342/tmp/application-validation
```

For each absolute sample path the helper ran `silver check PATH` and
`silver compile PATH` using the retained executable at
`tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver`.
It required the compilation workspace's author-source snapshot to equal the
input bytes, audited the reports, then ran the produced `bin/main` with a
10-second execution timeout. The compiler hash is in the original summary.

Each retained SARIF records the production GNATprove invocation with:

```text
-P <workspace>/program.gpr -U --mode=all --report=all --warnings=continue
--checks-as-errors=on --level=2 --prover=cvc5,z3,altergo --steps=100000
--timeout=0 --memlimit=1000 -j0 --no-loop-unrolling --no-inlining
```

The generated project records Ada switches `-gnat2022 -gnata -gnato`.
The function-bearing proof uses full declared helper domains with inlining
disabled. Reports and source snapshots correspond to the actual Ada/SPARK
author inputs; no annotated replacement source was introduced.

## Contents, derivation and limits

- [application-validation](application-validation) retains the original summary
  and, per program, `application-evidence.tar.gz`, `check.log`, `compile.log`,
  `execution-0.stdout` and `execution-0.stderr`. Each unchanged archive contains
  the author/runtime source snapshots, generated project, SPARK/SARIF reports,
  proof summary and available Why3 sessions. Executable/object payloads are
  omitted.
- [manifest-entries.json](manifest-entries.json) contains the four selected
  entries extracted from the validated target manifest, including exact
  expected output and `application_functions`. The original complete manifest's
  hash remains in the summary and run events.
- [author-notes](author-notes) preserves historical implementation handoffs and
  independent derivation metadata. Factorial uses Python `math.factorial`;
  Fibonacci uses a binomial-sum identity independent of the source recurrence.
  Recorded guard checks cover every required update in their declared domains.
  Signum expectations cover all five demonstrations; the notes justify its
  full Integer partition. Sum multiples was independently compared against
  direct enumeration for all 1001 inputs in 0..1000. Historical references to
  `tmp/` paths and pending parent validation describe the authors' earlier
  handoffs; the later successful application run is recorded above.
- [integrity-check.json](integrity-check.json) records packet checks against the
  supplied originals, target source bytes and independently derived expectations.
  `SHA256SUMS` covers every retained file except itself.

This retention task ran no build, proof, application execution or new universal
or Lean proof checkpoint. The managed run used the existing compiler/toolchain
installation from the accepted scalar-function work and reused unchanged
compiler and Lean assurance. The
[independent review](../../reviews/review-callable-integer-examples-20261108.md)
accepted the exact validated target's application evidence and baseline
applicability with no findings. It matched the archived files to their retained
workspaces, reran the unchanged Python auditors and proof-policy checks, and
checked source hashes, exact stdout and unchanged native/Lean proof inputs.
That review establishes applicability; this packet-retention task does not
claim to have performed the review. Native macOS validation is not claimed here.

Retention role selection carried forward from the implementation assignment:
GPT-6.1 Sol / Extra High. This records the selected model/effort; independent
live-runtime introspection was unavailable. Only this evidence directory is
changed by the retention commit.
