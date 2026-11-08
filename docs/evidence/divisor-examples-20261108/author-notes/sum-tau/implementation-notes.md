# #343 Sum of divisors / Tau implementation handoff — 2026-11-08

Authorization: the lead assigned exactly these two sources after the owner's
“Agreed. proceed.” authorization for merging #351 and implementing #343 through
reviewable publication. The authorization is recorded in `079ad0251d` and reached
the `a74e67c3a8` main baseline. #343 merge remains held for the owner. This
isolated worktree uses branch `feat/divisor-sum-tau-343`; no shared manifest,
documentation, compiler, proof or tooling file is changed by this subthread.
Implementation commit: `c6ac57906d5740d928bf6e6015996604e231c861`
(`Refs #343`), containing only the two new sample sources.

Selected agent: GPT-6.1 Sol / Extra High. Runtime introspection is unavailable;
these selected settings are not an independently confirmed runtime claim.
Native host determined by `uname -s -m`: Linux x86_64. `scripts/dev.py paths`
identifies `linux-x86_64` for this worktree. No harness goal was created.

## Interface, source and output

| Source | Callable helper | Full formal domain | Declared result range | Bytes |
| --- | --- | --- | --- | --- |
| `samples/rosetta_sum_of_divisors.adb` | `Sum_Of_Divisors` | 1..100 | 0..5050 | 821 |
| `samples/rosetta_tau_function.adb` | `Tau` | 1..100 | 0..100 | 760 |

Both programs visit every integer 1..100 and print one `Integer'Image (N)`,
a colon, `Integer'Image (Value)` and a newline. The leading spaces from Ada
Integer Image are intentional. Each program therefore prints exactly 100
labeled lines, in ascending input order, covering both endpoints, primes,
composites and perfect squares. The cached primary task descriptions require
every input 1..100 and impose no column layout.

Each source has four counted arithmetic/concatenation operators: `mod`, one
addition and two concatenations. The longest expression has three leaves.
Both are within the existing 4096-byte, 63-operator and 64-operand bounds.
The helpers have explicit `in` formals, static initialized locals, closed scalar
bodies and exactly one terminal return. Calls are entire scalar assignment
right-hand sides. The sole pragma is `SPARK_Mode (On)`; no author contracts or
proof annotations are introduced.

## Complete-domain algorithm and guards

Fix any declared input N with 1 <= N <= 100. Every positive divisor d of N lies
in 1..N, so the inclusive ascending loop visits every divisor exactly once.
Its `N mod Divisor = 0` test selects precisely those divisors. The divisor is
always positive, so remainder has no zero-divisor case. Both loops terminate
after N iterations and need no correlation unavailable to scalar admission.

For Sum of divisors, before iteration d, Result equals the sum of the divisors
among 1..d-1. It is nonnegative and at most
sum(1..d-1) = d(d-1)/2 <= 100*99/2 = 4950. Consequently the executable
`Result <= 4950` guard is always true whenever a divisor contributes. Admission
refines Result to 0..4950 and Divisor is in 1..100, giving a sum in 1..5050;
the assignment fits the accumulator's declared range. Initialization establishes
the empty-prefix sum, each selected update preserves the prefix sum and the
terminal Result is exactly the positive-divisor sum. This argument holds for
every N in the declared domain, not just demonstrated cases. No contribution
is dropped by the guard.

For Tau, before iteration d, Count equals the number of divisors among 1..d-1,
so 0 <= Count <= d-1 <= 99. Thus `Count < 100` is always true whenever a divisor
contributes. Admission narrows Count to 0..99 and the increment fits 1..100.
The initial empty-prefix count is zero, each selected candidate increments it
once and the final count is exactly Tau(N), throughout the declared domain.
No contribution is dropped by the guard.

The declared result intervals conservatively include zero; actual results for
the positive input domain are positive. The callers store the full declared
result intervals and do not depend on correlations with specific actuals.

## Independent expected results

`tmp/derive-expected.py` derives expected values using unique prime factorization,
not a scan of all positive-divisor candidates. For N = product(p^e), it computes
sigma(N) = product((p^(e+1)-1)/(p-1)) and Tau(N) = product(e+1). Trial primes
2, 3, 5 and 7 suffice: any composite at most 100 has a prime factor at most 10;
after their complete removal, a remainder above one is prime. The empty product
for N=1 gives sigma(1)=Tau(1)=1.

A separately written direct candidate enumeration cross-checks both recurrence
results for all 100 declared inputs and checks that both guards are true before
every iteration. This is a finite task-correctness check, not universal language
assurance or an application proof/build claim. The maximum observed accumulator
before an iteration was 156 and the maximum observed counter was 11. Domain-wide
maxima of the final outputs are sigma=252 and Tau=12. Illustrative oracle values:
sigma(36)=91 and Tau(36)=9; sigma(97)=98 and Tau(97)=2;
sigma(100)=217 and Tau(100)=9.

Artifacts:

- `tmp/manifest-entries.json`: proposed two-entry JSON list, exact expected
  stdout/stderr/status and every helper in `application_functions`.
- `tmp/sum-of-divisors.expected.stdout` and `tmp/tau-function.expected.stdout`:
  exact independently derived expected bytes.
- `tmp/derive-expected.py` and `tmp/derivation-summary.json`: reproducible
  derivation, exhaustive recurrence/guard check and source hashes.
- `tmp/admission.json`: actual retained-binary command, native host, compiler
  hash, source hashes, stdout/stderr and zero statuses for both sources.

## Admission and validation boundary

Both sources returned `Accepted: silver.` with status zero and empty stderr
from read-only `silver check`, using the retained delivered compiler at
`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver`.
Each check was repeated once solely to retain structured admission evidence.
Compiler SHA-256:
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.

No application compile, build, execution, GNATprove, Lean, test suite or shared
cache mutation was performed. The lead owns serial managed production
validation, integration, publication and later review. The committed source
bytes are the ones recorded by admission and the derivation summary; production
proof/build must keep those bytes unchanged. Scratch evidence stays uncommitted.
