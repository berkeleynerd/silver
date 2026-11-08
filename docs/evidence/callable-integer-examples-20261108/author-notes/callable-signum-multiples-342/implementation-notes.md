# #342 Signum and Sum multiples implementation handoff

Date: 2026-11-08. Worktree: `tmp/callable-signum-multiples-342`.
Selected role: GPT-6.1 Sol / Extra High, as assigned by the lead. Native host:
Linux x86_64 (`scripts/dev.py paths`: `linux-x86_64`).

Only the two assigned sample sources are committed. Proposed manifest entries,
exact independently derived stdout, and calculation/admission evidence remain
under this worktree's untracked `tmp/` for lead integration.

## Signum

`samples/rosetta_signum.adb` (697 bytes) declares
`Signum (X : in Integer) return Sign_Value`, where `Sign_Value` is `-1 .. 1`.
The three branches partition the entire Integer domain: negative inputs assign
-1, positive inputs assign 1, and the remaining zero input assigns 0. No
arithmetic is performed on X, so the minimum Integer has the same behavior as
any other negative input without a negation/absolute-value overflow risk. Ada
Integer has one zero, so signed-zero preservation introduces no extra case.

Main calls the helper for every required task example (-10, 42, 0) and both
pinned signed-32-bit Integer endpoints (-2147483648, 2147483647). Every call is
the complete RHS of a scalar assignment. The helper has initialized scalar
locals, explicit `in`, no author contracts, and one terminal return.

## Sum multiples

`samples/rosetta_sum_multiples_of_3_and_5.adb` (1202 bytes) declares
`Sum_Multiples (N : in Input_Value) return Integer`, where `Input_Value` is
`0 .. 1000`. N = 0 explicitly yields zero. Otherwise, Upper = N - 1 is
0 .. 999, and q_k = Upper / k is the count of positive multiples of k strictly
below N. The arithmetic-series identity gives k*q_k*(q_k+1)/2; q_k*(q_k+1)
is even, so Integer division is exact. Inclusion-exclusion adds the k=3 and
k=5 series and subtracts the k=15 series, counting overlaps once.

The counts are bounded by 333, 199 and 66. Their weighted predivision products
are at most 333666, 199000 and 66330. The two positive series total at most
266333, and the overlap series is at most 33165. Thus even the independent
interval hull for the final subtraction is -33165 .. 266333 and every
intermediate fits Integer. The declared full Integer result accommodates that
conservative hull without adding a behavior-changing guard or artificially
narrow result range. The mathematical result is 0 .. 233168 on the entire
declared domain.

The zero test supplies the ordinary bare-formal/static-zero refinement needed
to admit N - 1. There are no update guards that could skip a valid contribution,
no loops in the helper, and no iteration/truncation bound. Calls are complete
scalar assignment RHSs, and the helper has one terminal return.

Main cases cover zero/empty sums (0, 1), strict exclusion and subsequent
inclusion of the first 3 and 5 (3, 4, 5, 6), the familiar 10 case, the first
overlap boundary (15, 16), and the top-domain boundary (999, 1000). In particular,
15 -> 45 excludes 15, 16 -> 60 adds it once, and 999 -> 232169 excludes 999
whereas 1000 -> 233168 includes it. Optional extra-credit N >= 10^20 remains
outside this bounded task implementation.

## Validation and integration

The assigned delivered baseline compiler accepted both absolute source paths
using `silver check`, each with stdout `Accepted: silver.`, empty stderr and
status zero. Source fit and the unchanged expression/operator capacities were
therefore checked by actual admission. The compiler was read from the lead's
`tmp/scalar-functions-298` worktree; this task did not build a new compiler or
touch its caches.

Independent Python direct enumeration summed each positive integer below N
whose remainder modulo 3 or 5 is zero, and compared the result with the
implemented arithmetic identity for every N in 0 .. 1000: 1001 checks, zero
mismatches. The exact expected stdout uses that direct enumeration, with Ada
Integer'Image's leading space for nonnegative values. Signum expectations use
zero handling and x // abs(x) on its five demonstration inputs. Expected stderr
is empty and exit status is zero for both samples. These are expected results,
not claims of sample execution.

Integration artifacts:

- `tmp/manifest-entries.json`: complete proposed entries, including
  `application_functions` (`Signum`, `Sum_Multiples`) and exact stdout.
- `tmp/independent-domain-check.json`: all displayed values, full-domain
  enumeration result, source SHA-256/size, and actual admission command/result.

No sample build, native application proof, managed tool job, Lean check or
sample execution was run here. The lead owns serialized focused application
validation, manifest integration, task metadata and final review. These sample
checks do not establish universal language assurance.
