# Twelve scalar-function task reconciliations

Targeted metadata reconciliation for owner-authorized
[#345](https://github.com/berkeleynerd/silver/issues/345), 2026-11-08. The
[batch record](../docs/scalar-function-rosetta-batch.md) records authorization,
the three delivered sample groups and their separate validation. This pass
compares the twelve captured primary tasks with the exact sources at merge
`247592a8fa2cb1230594c50246894f0cf461a642` and their manifest cases. It changes
only those assessments and their generated presentation. No task page is
refreshed, language construct admitted, source budget changed or sample edited.

Selected subthread controls were **GPT-6.1 Sol / Extra High** (`gpt-6.1-sol`,
`xhigh`). Independent live-runtime confirmation, token/cost and total elapsed
work telemetry are unavailable. This metadata reconciliation is separate from
independent acceptance. It reads the three accepted task/domain/evidence reviews
below and performs an ordinary render; it reruns no native/Lean/application
proof, build or application execution. Final combined integration evidence and
independent delivery acceptance belong to the
[combined evidence packet](../docs/evidence/scalar-function-rosetta-batch-20261108/README.md)
and [delivery review](../docs/reviews/review-scalar-function-rosetta-delivery-20261108.md).
Those later integration checks are pending at this metadata checkpoint.

## Primary tasks and delivered programs

The manifest retrieval date remains 2026-10-15. Each revision below identifies
the actual cached `task.wiki` read for this reconciliation. The delivered
argument domains are explicit; wider domains anticipated by historical designs
are not support promises. All twelve primary tasks are covered faithfully in
the current Integer representation and the stated domains. Optional extensions
remain optional, and no required example or search interval is omitted.

| Primary task and captured revision | Exact source and complete formal domain | Required behavior and demonstrated cases | Nonblank lines |
| --- | --- | --- | ---: |
| [Factorial](f/factorial/task.wiki), 415532 | [Factorial](../samples/rosetta_factorial.adb), 0..12 | Real callable factorial; 0! = 1. All thirteen inputs are shown. Negative-input handling is optional. | 22 |
| [Fibonacci sequence](f/fibonacci-sequence/task.wiki), 415533 | [Fibonacci](../samples/rosetta_fibonacci_sequence.adb), 0..46 | Real callable nth-value function; F0 = 0, F1 = 1. Every declared input is shown. Negative indices are optional. | 30 |
| [Sign of an integer (signum)](s/sign-of-an-integer-signum/task.wiki), 413025 | [Signum](../samples/rosetta_signum.adb), full Integer | Returns -1, 0 or 1; demonstrates -10, 42, 0 and both Integer endpoints. This representation has no distinct signed zero. | 26 |
| [Sum multiples of 3 and 5](s/sum-multiples-of-3-and-5/task.wiki), 413418 | [Sum multiples](../samples/rosetta_sum_multiples_of_3_and_5.adb), 0..1000 | Real callable function sums positive multiples strictly below n, counting overlaps once. Eleven cases include the required 1000 -> 233168. Efficient 10^20 inputs are extra credit. | 35 |
| [Least common multiple](l/least-common-multiple/task.wiki), 412881 | [LCM](../samples/rosetta_least_common_multiple.adb), both arguments -1000..1000; same GCD helper domain | Twelve cases include 12,18 -> 36, signs, zero in either/both positions, units and bounds. | 61 |
| [Coprimes](c/coprimes/task.wiki), 406144 | [Coprimes](../samples/rosetta_coprimes.adb), both arguments -1000..1000; same GCD helper domain | All five specified pairs appear first with false, true, false, true, false, followed by eight controls. | 56 |
| [Sum of divisors](s/sum-of-divisors/task.wiki), 404133 | [Sum of divisors](../samples/rosetta_sum_of_divisors.adb), 1..100 | Computes and prints every required positive-divisor sum. The task specifies no column arrangement. | 25 |
| [Tau function](t/tau-function/task.wiki), 413079 | [Tau](../samples/rosetta_tau_function.adb), 1..100 | Computes and prints every required positive-divisor count. No ten-column format is required. | 25 |
| [Sum digits of an integer](s/sum-digits-of-an-integer/task.wiki), 413075 | [Sum digits](../samples/rosetta_sum_digits_of_an_integer.adb), N 0..2147483647, base 2..36 | Seventeen cases include (1,10) -> 1, (1234,10) -> 10, (254,16) -> 29 and (3854,16) -> 29; 254 and 3854 are the required hexadecimal FE and F0E. | 39 |
| [Happy numbers](h/happy-numbers/task.wiki), 415022 | [Happy numbers](../samples/rosetta_happy_numbers.adb), both helpers 0..999 | Complete positive prefix 1..31 prints exactly the first eight: 1,7,10,13,19,23,28,31. | 43 |
| [Additive primes](a/additive-primes/task.wiki), 411689 | [Additive primes](../samples/rosetta_additive_primes.adb), both helpers 0..499 | Scans every candidate 2..499 and prints all 54 whose value and decimal digit sum are prime. The count is optional. | 46 |
| [Attractive numbers](a/attractive-numbers/task.wiki), 413644 | [Attractive numbers](../samples/rosetta_attractive_numbers.adb), factor-count helper 1..120 and primality 0..120 | Scans 1..120 and prints all 74 whose prime-factor count, with multiplicity, is prime. In particular 20 has three factors. | 48 |

Sizes count all nonblank source lines, including comments. Static byte comparison
confirmed that each source equals its accepted implementation Git blob: four
at `db8ca3495c6b2a118f4bd9ebe8bbcddad2e6fa0f`, four at
`5262fb81fa38c4afd55debf87ea44f50720aaf8c`, and four at
`f2842c6d62ecab7c6d44848f22363a7558f43912`. The corresponding independent
reviews establish application-source identity and manifest-output agreement;
the final combined checkpoint owns integrated manifest checks.

## Complete-domain task arguments

Executable safety guards must preserve the required answer. Their success in
application proof alone would not establish that. The accepted reviews retain
the detailed functional arguments and independent expected-output derivations;
this reconciliation checked those arguments against the merged source:

- **Factorial and Fibonacci.** Before factorial step i <= 12 the result is
  (i-1)! <= 39,916,800, so its guard never skips a multiplication; the largest
  result is 12! = 479,001,600. Before Fibonacci step i <= 46 the pair is
  F(i-2), F(i-1), bounded by 701,408,733 and 1,134,903,170. Both guards hold,
  and the last sum is F46 = 1,836,311,903. F47 and 13! exceed Integer, so the
  function domains cover all nonnegative arguments with representable results.
- **Signum and Sum multiples.** Signum partitions the full Integer domain
  without negating its argument. For positive n, Sum multiples uses
  q = floor((n-1)/d) and d*q*(q+1)/2 for d = 3, 5 and 15, with inclusion-exclusion.
  The even product makes division exact; all intermediates fit Integer. Zero
  returns zero. Independent enumeration covers every one of its 1,001 inputs.
- **GCD, LCM and Coprimes.** Sign normalization preserves magnitudes <=1000.
  Euclidean updates preserve GCD, and every two active updates at least halve
  the second operand. Twenty steps therefore finish on the full declared
  domains; inactive guarded steps preserve the result. The GCD is positive
  except at (0,0). Absolute product divided by GCD implements LCM, with the
  initialized zero giving its required both-zero case. Coprime tests GCD = 1.
  Independent math.gcd/math.lcm comparisons cover all 1,002,001 magnitude
  pairs; normalization extends the argument to signed pairs.
- **Divisor sum and count.** The inclusive 1..N scan visits each positive
  divisor once. Before candidate d <=100, earlier candidates sum to at most
  d(d-1)/2 <=4950 and number at most d-1 <=99. Both static guards preserve all
  contributions. Independent prime-factor product identities derive all one
  hundred sums and counts.
- **Sum digits.** N <2^31 and base >=2 imply that thirty-one divisions consume
  every digit. Before each addition at most thirty earlier digits contribute
  30*35=1050, so the guard cannot truncate; the final coarse bound is 1085.
  Extra zero digits change nothing. Independent positional conversions cover
  the retained examples and boundary checks; the analytical argument covers
  the entire formal-domain product, beyond those finite checks.
- **Happy numbers.** Three extractions cover every input 0..999; two earlier
  squared digits total at most 162, so the sum guard never truncates. The first
  transformation enters 0..243, and one is absorbing. If 244 images avoid one,
  two repeat among 243 non-one states; determinism then excludes a later first
  visit to one. The fixed loop therefore decides the unbounded definition on
  the full declared domain. Independent cycle detection checks all 1,000 inputs
  and the complete prefix yielding the first eight happy numbers.
- **Prime helpers, Additive and Attractive numbers.** Every composite n >=4
  has a divisor in 2..floor(n/2), while empty loops correctly accept two and
  three. Additive's three extractions preserve the full decimal digit sum:
  two earlier digits total at most 18. Attractive can remove at most six
  factors from an input <=120, since seven would require at least 128. Seven
  attempts per factor and the count guard therefore discard no removal.
  Smaller primes are exhausted before a composite factor, so only primes are
  removed and multiplicity is counted exactly. Independent sieve, decimal-text
  and prime-power multiplicity expectations cover the complete finite helper
  domains and both required output sequences.

Every helper uses the delivered closed Integer/Boolean function rules, explicit
`in` formals, initialized scalar locals, earlier-only calls and one terminal
return. Every call is the entire RHS of an existing scalar assignment. Helpers
capture no Main values and perform no effects. Full declared result intervals
fit the caller destinations; no argument/result correlation is assumed. The
4,096-byte source, 63-operator and 64-operand budgets remain unchanged. Finite
task checks and source arguments supplement the separately required universal
language and source-correspondence assurance.

## Retained validation and independent reviews

| Increment and accepted implementation | Existing Linux application checkpoint | Independent review and retained packet |
| --- | --- | --- |
| #342, `db8ca3495c6b2a118f4bd9ebe8bbcddad2e6fa0f` | `20261108T194440-c7a94430faf1`; four programs passed admission, complete application/library proof audits, build and exact execution | [Review](../docs/reviews/review-callable-integer-examples-20261108.md), [packet](../docs/evidence/callable-integer-examples-20261108/README.md) |
| #343, `5262fb81fa38c4afd55debf87ea44f50720aaf8c` | `20261108T211402-d028fe5c343d`; same required checks passed for four divisor programs and all helpers | [Review](../docs/reviews/review-divisor-examples-20261108.md), [packet](../docs/evidence/divisor-examples-20261108/README.md) |
| #344, `f2842c6d62ecab7c6d44848f22363a7558f43912` | `20261108T214753-620fcc9bc295`; same required checks passed for four digit/prime programs and all helpers | [Review](../docs/reviews/review-digit-prime-examples-20261108.md), [packet](../docs/evidence/digit-prime-examples-20261108/README.md) |

The three independent reviews selected GPT-6 Astra / Max and accepted their
exact implementation and evidence scopes with no material finding. Their
complete-domain, source identity, exact output and retained-proof applicability
conclusions remain separately attributed. Application safety uses production
`--no-inlining` and `--no-loop-unrolling`; it is checked over the full formal
domains. These retained successes are not fresh proofs in this reconciliation.
The accepted [scalar-function capability assurance](../docs/scalar-functions.md#delivery-assurance-and-validation)
supplies the compiler native and Lean/source baseline. The combined delivery
record owns final applicability, integration tests and acceptance; this document
does not declare those pending checks complete. Earlier failed runs remain
failed. The actual local host is Linux x86_64, confirmed with `uname` and
`scripts/dev.py paths`; no native macOS validation is claimed.

## Assessment provenance and scope

All twelve original records retain `assessed: "2026-10-15"`, their captured
revision above, `rubric: 2`, `tier: "standard"`,
`model: "claude-sonnet-5-5"` and `effort: "medium"` without alteration. None
had a prior targeted `review` object at the source merge. No earlier review
attribution is overwritten or retroactively assigned this reconciliation's date.
Each now receives a separately attributed review object linking this record.

The original historical designs anticipated broader mechanisms. Their original
outlook and size were Factorial plausible/35, Fibonacci likely/35, Signum
likely/30, Sum multiples likely/28, LCM plausible/45, Coprimes likely/35,
Sum of divisors likely/30, Tau likely/45, Sum digits plausible/45, Happy
likely/40, Additive likely/55 and Attractive plausible/55. Those estimates
predated the actual current-language programs. In particular the earlier
Factorial/Fibonacci designs used wider integers, several designs used
procedures and while loops, Signum used a case-statement identifier, and
Additive used a sieve array. The replacement approaches describe the actual
delivered sources rather than broadening their supported domain or preserving
an obsolete implementation requirement. The historical assessments remain
available at source merge `247592a8fa2cb1230594c50246894f0cf461a642`.

Only these twelve task records change in `coverage.json`. The policy and
`supported` list remain unchanged. Their revised
dependencies use only existing supported identifiers: scalar functions, named
Integer subtypes, bounded mutable Integers, counted Integer loops, interval
division, scalar refinement, scalar Boolean objects, fixed Integer arrays,
constant Integer-array iteration, Integer Image and Put, as each actual source
needs. The assessor's current-language description already states the delivered
scalar-function scope and unchanged budgets, so no script edit is required.
Broad `functions`, `procedures`, `arrays`, `booleans`, `integer-division`,
`ranged-subtypes`, `for-loops`, `scalar-image` and `string-building` remain
unsupported. This sample-only reconciliation creates no language-stage issue
and authorizes no later language work.

## Render checkpoint

One `python3 rosetta/refresh.py --render` completed successfully on Linux
x86_64 after the final metadata integration. Stage 1 grows from **71 to 83
task mappings**, an actual gain of **twelve**. The progression retains 1,576
candidates in 44 stages. Separate counts remain two unlikely, 203 excluded and
one design-pending assessment. The supported identifier list, admission-question ordering and
construct stages are unchanged.

| Former stage | Tasks now in Stage 1 |
| --- | --- |
| 6, integer division | Factorial, Sum of divisors, Tau function |
| 7, while loops | Least common multiple, Coprimes, Sum digits of an integer, Happy numbers, Additive primes |
| 8, functions | Fibonacci sequence, Sum multiples of 3 and 5, Attractive numbers |
| 13, case statements | Sign of an integer (signum) |

The board's baseline-output stage and supported
`integer-for-loops`/`immutable-integers`/`integer-image`,
`interval-integer-division`, `scalar-guard-refinement` and `scalar-functions`
remain Stage 1. Broad `for-loops`/`integers`/`procedures`/`ranged-subtypes`/
`scalar-image` remain Stage 2, and broad `arrays` remains Stage 3. No Stage
field changes are required, and closed stage issues retain their closed status.

Full-diff inspection found twelve substantive generated assessment pages and
700 other assessment pages whose only change is their derived position line.
Those 700 tasks retain their stages. The remaining generated changes are the
progression and root index; `manifest.json` is unchanged. Only the twelve named
source assessment records changed, all original attribution fields are equal,
and every revised dependency is already supported. Source bytes and complete
manifest entries match the accepted implementation targets above.
`git diff --check` passed. The integration lead owns the affected managed tests
and final independent review; neither is claimed by this render checkpoint.

The inventory has 84 programs; that count differs from the 83 supported task
mappings. Manifest execution cases remain a separate count as well. Successful
finite executions and the rendered assessment count establish neither universal
language assurance nor additional language support.

## Combined integration follow-up

The integration lead retained successful managed run
`20261108T225101-0e909fa50875` on metadata target `c9d8f3352296`: all three
affected Rosetta tests passed, including rendering under different hash seeds.
The [combined packet](../docs/evidence/scalar-function-rosetta-batch-20261108/README.md)
records all 1,116 matching captured inputs, 84 programs/147 executable cases,
and unchanged board Stage values. The earlier pending wording describes the
metadata-author checkpoint; final independent delivery acceptance remains
pending at this follow-up. This adds no new assessment or render input.
