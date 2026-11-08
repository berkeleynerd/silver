# #344 Additive primes / Attractive numbers implementation

2026-11-08; isolated worktree `tmp/digit-prime-pair-344`, branch
`feat/digit-prime-pair-344`, base `87e18b4c3e`. The lead supplied owner
authorization for #344 after merge #352 and retained shared integration,
managed production validation and publication. This subthread owns only the
two new sample sources and these untracked proposals/evidence. No shared
manifest, compiler, proof, documentation or GitHub writes were performed.

Read `AGENTS.md`, the complete Oracle, language arithmetic/scalar-guard,
scalar-function and finite-loop rules, `docs/scalar-function-rosetta-batch.md`,
both cached primary task pages and the delivered primality sample. Selected
settings: GPT-6.1 Sol / Extra High, per the lead. Actual runtime settings,
token/cost and elapsed agent measurements are not independently exposed.
Actual host: Linux x86_64 (`uname`: Linux silver 7.0.14 x86_64).
The live harness returned no goal; no goal was created. CLI recall was not
updated.

## Source and admission

| Source | Bytes / 4096 | Operators / 63 | Largest expression operands / 64 | Functions |
| --- | ---: | ---: | ---: | --- |
| `samples/rosetta_additive_primes.adb` | 1366 | 5 | 3 | `Is_Prime`, `Digit_Sum` |
| `samples/rosetta_attractive_numbers.adb` | 1473 | 5 | 2 | `Is_Prime`, `Prime_Factor_Count` |

Both are actual Ada/SPARK source with only `pragma SPARK_Mode (On);`, no
authored contracts/annotations, initialized scalar locals, explicit `in`
formals, closed bodies and one terminal return per helper. Calls occur only
as complete scalar-assignment RHSs. No language or capacity change is needed.

Read-only admission executable:

`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver`

Executable SHA-256:
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.

Each command was `silver check ABSOLUTE_SOURCE_PATH`. Both final commands
exit 0 with exactly `Accepted: silver.` followed by newline; see
`additive-admission.log` and `attractive-admission.log`. Initial additive
admission rejected the reserved identifier `Digits`; renaming that local
`Sum` corrected the source. The failed result is retained in
`additive-admission-initial-reserved-name.log`.

Final source SHA-256s:

- additive: `708e9a9294647a59f96130328fb7013bb146aadb69cd5197745bb201ee016f01`
- attractive: `453ec68a06b211d80fe0ec4beabfa8fac5ccf95c5bea12350565b8883c58694b`

These final bytes were admitted and are the committed samples. No compile,
proof, build, test-suite run or Silver/Ada application execution was performed
by this subthread. Production proof/build/execution and their unchanged-source
checks remain the lead's responsibility.

## Full-domain mathematical arguments

**Primality.** Additive `Is_Prime` has full declared domain 0..499; attractive
`Is_Prime` has full declared domain 0..120. Both return false for 0 and 1 and
test every divisor 2..floor(N/2) for every N >= 2. For 2 and 3 the loop is
empty and the answer is true. A composite N >= 4 has a proper divisor in that
interval, while a prime has none. The range contains every original candidate
and every declared digit-sum/factor-count result, without depending on caller
correlations. Every divisor is at least 2, so modulo/division are defined.

**Digit sum.** `Digit_Sum` accepts every N in 0..499 and declares result 0..27.
After k iterations the remainder is floor(N / 10^k), and the total contains
the k least significant decimal digits, including leading zero contributions.
Three iterations suffice because N < 1000. Immediately before iteration
k=1,2,3, at most k-1 digits have been added, each at most 9, so Total <= 18.
The executable `Total <= 18` guard therefore preserves every required
addition. Within the guard, Total+(Remaining mod 10) is in 0..27; the
remainder and quotient stay in 0..499. The terminal total is the complete
decimal digit sum. Main visits every integer 2..499 exactly once, testing both
primality predicates; 0 and 1 cannot be additive primes. Actual maximum
digit sum on this declared domain is 22, within the conservative result range.

**Multiplicity count.** `Prime_Factor_Count` accepts every N in 1..120 and
returns a declared 0..6 result. The local remainder has declared range 0..120
so interval analysis can admit a quotient whose conservative lower endpoint
is zero. At runtime it starts positive; dividing only when Remaining > 1 and
Remaining mod Factor = 0 preserves a positive integer quotient. The local
zero allowance does not discard or alter any valid input.

Maintain mathematically N = Remaining * product(successfully removed factors),
and Count = number of those factors. Each removed factor is at least 2. Seven
successful removals would imply N >= 2^7 = 128, contradicting N <= 120.
At a prospective removal with Count=6, Remaining >= Factor >= 2 would likewise
imply N >= 2^6 * 2 = 128. Consequently `Count < 6` is true at every valid
division and cannot truncate the factorization. Count+1 stays in 0..6, and
the quotient fits the remainder's 0..120 interval.

For each Factor in 2..120, seven attempts suffice because at most six
successful divisions are possible across the entire function. Once an earlier
prime has been exhausted it cannot reappear after later divisions. A composite
Factor has a smaller prime divisor already exhausted, so no composite Factor
can be removed. All successful removals are therefore primes, counted with
multiplicity. After the full factor loop, a remainder > 1 would have a prime
divisor <= Remaining <= 120 that was already exhausted, a contradiction.
Thus the final remainder is 1 and Count is the complete prime factor count.
In particular, 20 removes 2,2,5 and returns 3. Main visits 1..120 inclusive;
N=1 returns count 0, primes return count 1, and neither qualifies.

## Independent expected results and controls

Run `python3 tmp/derive-evidence.py` from this worktree. It derives prime
flags with a sieve and decimal sums with decimal text, then derives Omega
using a prime-power contribution table: every multiple of each p^k receives
one contribution. The latter differs from the sample's sequential
divide-out algorithm. Separate bounded algorithm models are checked against
those independent results across complete declared helper domains. These are
cheap mathematics checks, not execution evidence for the Ada applications.

`derivation-results.json` and `derivation-run.log` retain all values, controls,
budgets and source hashes. All 500 primality/digit cases and all 120 factor
cases agree. No digit or count guard skips an update. Maximum preceding digit
total is 18; maximum successful divisions, including per-factor success count,
is 6.

Meaningful controls include 0/1 false and 2/3 true for primality, 4/6/119/120
composite, and 499 prime. Additive controls reject prime 13 (digit sum 4),
composite 21 (prime digit sum 3), and prime 499 (digit sum 22); 2 qualifies.
Factor-count controls include 1->0, 2->1, 4->2, 8->3, 16->4, 20->3,
32->5, 64->6, 97->1 and 120->5. The nonqualifying prime and composite cases
are covered as well as the multiplicity example and both endpoints.

`manifest-entries.json` proposes both complete records, including every
application helper name and exact expected stdout/stderr/status. The expected
stdout files contain one Ada Integer'Image result per line, hence a leading
blank before each positive number and a trailing newline. Additive prints
54 values, from 2 through 487. Attractive prints 74 values, from 4 through
120. Both proposed cases expect empty stderr and exit status 0. Counts are
oracle facts; no optional count output was added to the programs.

No shared application-validation evidence is claimed here. The lead must
integrate these proposals and validate the complete production application
audit, proof, build and exact outputs from these source bytes.
