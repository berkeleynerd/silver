# Factorial and Fibonacci implementation handoff — #342

Owner-selected scope: two of #342's four callable examples, under the merged
plan and existing scalar-function grammar. Only the two new sample sources
are committed by this stream; the parent integrates the shared manifest,
metadata and documentation and runs native application validation.

## Sources, interface and primary-task fidelity

- `samples/rosetta_factorial.adb`: 681 bytes; callable `Factorial`, argument
  subtype `Factorial_Argument` = 0..12, result subtype `Factorial_Value` =
  1..479001600. Primary requirement read from
  `rosetta/f/factorial/task.wiki`: return n!, with 0! = 1; iterative solutions
  are permitted and negative-error handling is optional.
- `samples/rosetta_fibonacci_sequence.adb`: 972 bytes; callable `Fibonacci`,
  argument subtype `Fibonacci_Index` = 0..46, result subtype
  `Fibonacci_Value` = 0..1836311903. Primary requirement read from
  `rosetta/f/fibonacci-sequence/task.wiki`: return Fn, with F0 = 0,
  F1 = 1 and Fn = F(n-1) + F(n-2); negative indices are optional.

Both helpers use explicit `in` formals, literal-initialized scalar locals,
counted loops and one terminal return. Main calls appear only as complete
scalar assignment RHSs. The only author pragma is `SPARK_Mode (On)`;
there are no contracts, proof annotations or transformed sources.
Main prints every member of each declared domain, including every named
boundary case in the batch plan.

## Factorial algorithm and complete-domain guard argument

The initial result is 1. The loop visits factors 1 through N exactly once;
for N = 0 it is null, so the result stays 1. Inductively, before factor i,
the result is (i-1)!. For all required factors 1 <= i <= N <= 12,
(i-1)! <= 11! = 39916800. Therefore `Result <= 39_916_800` is always true
when an update is mathematically required, and the update produces i!.
After the loop the result is N! for every N in 0..12.

The admission check needs no relational invariant: widening the accumulator
to its declared range then applying the static guard gives 1..39916800;
the captured factor interval is 1..12. Endpoint multiplication therefore
gives 1..479001600, which fits the declared result and Integer. The largest
result is 12! = 479001600; 13! = 6227020800 exceeds Integer'Last = 2147483647.
The guard cannot truncate any computation in the declared domain.

## Fibonacci algorithm and complete-domain guard argument

N = 0 explicitly sets Current to zero. For N = 1 the loop 2..N is null,
leaving Current = 1. For N >= 2, before iteration i the pair
(Previous, Current) is (F(i-2), F(i-1)), initially (F0, F1).
Every required iteration has 2 <= i <= N <= 46. Fibonacci is nondecreasing
at these nonnegative indices, so Previous <= F44 = 701408733 and
Current <= F45 = 1134903170. Both static guard conjuncts are therefore
true on every required update. Next_Value receives Fi, then the pair shifts
to (F(i-1), Fi), establishing the next iteration's premise. The final
Current is FN over all inputs in 0..46.

After interval widening, each operand initially ranges over
0..1836311903. The two static upper guards narrow these separately to
0..701408733 and 0..1134903170. Their sum ranges over 0..1836311903,
which fits the Next_Value/Current result subtype and Integer. The shifts
also fit the declared scalar ranges. The final iteration is i = 46,
producing F46 = 1836311903; no unused F47 is computed. F47 = 2971215073
exceeds Integer'Last. The guard cannot truncate any computation in the
declared domain.

## Budgets and exact expected output

Both complete sources fit the unchanged 4096-byte bound. Factorial uses
three budgeted arithmetic/concatenation operators (one multiplication and
two concatenations); Fibonacci uses four (one addition and three
concatenations). Their largest scalar expressions each have two operands;
their output String expressions have respectively three and four leaves.
Image arguments each have one scalar operand. Both remain below the
63-operator and 64-operand/leaf limits; successful admission also checks
these limits.

`tmp/manifest-entries.json` is an array of two proposed manifest entries,
including `application_functions` = `["Factorial"]` / `["Fibonacci"]`,
the scalar-function specification link and exact stdout/stderr/status.
`tmp/rosetta_factorial.stdout` contains 13 lines (145 bytes).
`tmp/rosetta_fibonacci_sequence.stdout` contains 47 lines (977 bytes).
Nonnegative `Integer'Image` contributes the standard leading space;
the output preserves those exact bytes, including each final newline.

Expected Factorial values came from Python's `math.factorial`. Expected
Fibonacci values came from the independent binomial identity
Fn = sum(C(n-k-1,k), k=0..floor((n-1)/2)) for n >= 1, with F0 = 0.
This is independent of the source's two-accumulator algorithm. Mathematical
checks also confirmed 12!/13!, F44/F45/F46/F47 and all 78 factorial plus
1035 Fibonacci required update states across the declared input domains.
`tmp/oracle-metadata.json` records methods, counts and source/output hashes.

## Actual validation and limitations

Native host is Linux x86_64 (`uname`: Linux silver 7.0.14); `scripts/dev.py paths`
reports `linux-x86_64`. Read-only admission used the existing delivered compiler
at `/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver`
with `check` and each absolute source path. Final checks both returned
exit 0 and `Accepted: silver.`. No build, proof run, application execution,
managed job or shared cache mutation was performed by this stream.

The first drafts were rejected because their single arithmetic RHSs lacked
Silver's required full parentheses. The unchanged Primality source accepted
as a control. Adding the two missing parenthesis pairs was the only admission
repair; it did not change the algorithms or declared domains.
`tmp/admission-evidence.json` retains both draft rejections, the control,
the final admission results, source/output hashes and compiler hash.
Native whole-subprogram proofs, application/library audit, compilation,
execution comparison and independent review remain the parent's serialized
integration work. Admission and mathematical checks do not establish those
pending assurance claims.
