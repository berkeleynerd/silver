# Digit and prime examples review — 2026-11-08

**Accept implementation `f2842c6d62ecab7c6d44848f22363a7558f43912` for
the owner-authorized #344 increment through reviewable publication.** All four
programs preserve their tasks across their complete declared domains. Fresh
Linux application validation passes; accepted compiler assurance and unaffected
regression evidence remain applicable. No material finding or required repair
remains.

The [owner decision](../session-memory.md#2026-11-08--divisor-examples-merge-and-digitprime-group-authorized)
recorded at `034780977f` reached main through merge `87e18b4c3e`. It selects
#344 after merging #343's PR #352. This review covers implementation through
reviewable publication; it does not authorize this increment's merge, select
#345, complete milestone 21 or claim new rendered task coverage. #345 retains
the combined checkpoint and Rosetta assessment/render work.

## Reviewed inputs and mathematical behavior

The delta from `87e18b4c3e` is exactly four new Ada sources and 139 added
manifest lines. Compiler/runtime, language, catalogue, Lean, auditor, test
sources and project settings are unchanged. I read all four cached primary
`task.wiki` pages, the Oracle, applicable function/scalar/guard/loop rules and
the validation/reuse requirements. The seven helpers use the existing closed
function grammar: explicit `in` formals, initialized scalar locals, earlier-only
whole-assignment calls and one terminal return. No authored contract, proof
annotation, captured Main state or alternative source representation is added.
Integer results expose only their declared intervals; no argument correlation
or saved Boolean predicate is needed for admission.

| Program | Complete helper domains | Result ranges | Source bytes | Shared operators |
| --- | --- | --- | ---: | ---: |
| [Sum digits](../../samples/rosetta_sum_digits_of_an_integer.adb) | N: 0..2,147,483,647; base: 2..36 | 0..1085 | 1,602 | 8 |
| [Happy numbers](../../samples/rosetta_happy_numbers.adb) | Both helpers: 0..999 | Digit squares: 0..243; happiness: Boolean | 1,455 | 4 |
| [Additive primes](../../samples/rosetta_additive_primes.adb) | Both helpers: 0..499 | Digit sum: 0..27; primality: Boolean | 1,366 | 5 |
| [Attractive numbers](../../samples/rosetta_attractive_numbers.adb) | Factor count: 1..120; primality: 0..120 | Factor count: 0..6; primality: Boolean | 1,473 | 5 |

All sources fit the unchanged 4,096-byte, 63-operator and 64-operand limits.
Operator counting excludes comments and string literals. The largest String
expression has six leaves; each embedded scalar expression has at most three.
Independent read-only admission with the delivered compiler accepted all four
exact Git blobs.

**Sum of digits.** Write the input as successive Euclidean quotients and
remainders in base b. Each extraction adds exactly its next digit in 0..b-1,
and division leaves the unprocessed prefix. Since N<2^31 and b>=2, after
31 divisions floor(N/b^31)=0. Thus the loop includes every digit for every
pair in the declared product domain; extra zero digits do not change the sum.
Before iteration k, the sum is at most (k-1)*35<=1050. Induction therefore
establishes that the static guard is always true and no contribution is
discarded. The final sum is at most 31*35=1085. This is a full-domain
mathematical argument, not exhaustive enumeration of natural Integer inputs.

The 17 demonstrations include all four task examples: (1,10)->1,
(1234,10)->10, (254,16)->29 and (3854,16)->29. Decimal values 254 and 3854
are exactly hexadecimal FE and F0E; their explicitly printed base is 16.
Zero is included in both endpoint bases, as are base-2 transitions and
base-36 one/two/three-digit transitions. Integer'Last produces 31, 46, 112
and 127 in bases 2, 10, 16 and 36. Independent variable-length positional
conversion agrees with the fixed-loop algorithm on 1,029 boundary pairs
across every base 2..36, including zero, Integer'Last and powers-of-base
neighbors. These finite checks supplement the argument above.

**Happy numbers.** Three decimal extractions suffice for every N in 0..999.
Each squared digit is at most 81, so the pre-addition sum is at most 162
and the guard never truncates. The digit-square function returns its exact
mathematical result in 0..243. Let x_i be the value after i transformations.
All x_1..x_244 lie in the 244-state set 0..243, and 1 is absorbing. If
x_244 is not 1, none of these images is 1. The 244 images therefore occupy
only 243 possible non-1 states, forcing a repetition. Determinism then
confines all later images to a cycle that avoids 1. Conversely, reaching 1
at any time up to that point leaves the final result 1. The 244-step test
therefore decides happiness on the complete declared domain, including the
unhappy fixed point zero; it is not an arbitrary cutoff.

An independent cycle-detecting calculation matched all 1,000 digit-square
results and happiness decisions. Searching positive integers in order yields
exactly 1, 7, 10, 13, 19, 23, 28 and 31 as the first eight. This establishes
that Main's inclusive scan 1..31 misses no earlier happy number and emits
exactly eight. Controls 0, 2..6, 8, 9 and 999 are unhappy.

**Primality and additive primes.** Both primality helpers correctly reject
0 and 1. For N>=2, a composite has a divisor in 2..floor(N/2); a prime
has none. The complete counted scan therefore decides primality, with empty
loops correctly accepting 2 and 3. It cannot restore a false flag to true.
Three decimal extractions cover 0..499; before each digit addition the
sum is at most 18, so the guard never discards a digit. Its declared 0..27
result fits the independent primality formal domain. Main scans every N in
2..499 and prints exactly those for which both N and its decimal digit sum
are prime. An independent Eratosthenes sieve matched primality on 0..499,
and decimal string conversion matched every helper digit sum. Their joint
selection gives all 54 required additive primes, with none omitted or added.

**Attractive numbers.** Maintain N = Remaining times the product of factors
already removed, with one count increment per removed factor. Every removed
factor is at least 2. Seven successful divisions would imply N>=2^7=128,
outside 1..120; there are at most six across the entire loop. If Count=6
and Remaining>1, the same product invariant implies N>=64*2=128.
Consequently the `Count < 6` guard never suppresses a required division.
Seven attempts at each factor are enough to remove every occurrence.

After processing smaller factors, a composite candidate cannot divide the
remaining value: one of its prime divisors was already fully removed.
Every successful division is therefore by a prime, and visiting every
candidate through 120 leaves Remaining=1 for every positive formal input.
The returned count is the number of prime factors with multiplicity, not
the number of distinct primes. In particular 20 removes 2, 2 and 5 and
returns 3; 1 returns zero, and 120 returns 5. An independent least-prime
factor table and recurrence for multiplicity matched every input 1..120.
The maximum count is six, attained by 64 and 96. Applying independent
primality to these counts yields exactly the 74 outputs through 120.

These task arguments establish mathematical fidelity of these bounded
programs. They do not replace the universal language/source assurance or
the mandatory application safety proof.

## Fresh application evidence

Managed run `20261108T214753-620fcc9bc295` completed successfully on Linux
x86-64 with 22 reserved workers. Its native-tool phase returned zero, the
ledger records success and its managed duration was 65.653239362 seconds.
The [retained packet](../evidence/digit-prime-examples-20261108/README.md)
preserves the original application sources, reports, logs, outputs and validator.
I reviewed its content at evidence commit `e47b4a195ad7d91d5ce9457516f3f3e8152df96d`.

The validator implements the corresponding unchanged manifest-test checks:
production admission and compilation, an identical author snapshot, unchanged
effective-proof-policy assertions and report auditor, and exact executable
stdout/stderr/status comparison. It preserves `--no-inlining`,
`--no-loop-unrolling`, all-mode/all-report checking, the pinned solvers and
normal step/memory limits. Each helper is checked across its full formal
domain; proof scope is not restricted to Main's demonstration arguments.

| Application | Units / entities | Flow checks | Proof checks | Function termination checks |
| --- | ---: | ---: | ---: | ---: |
| Sum digits | 5 / 18 | 20 | 55 | 1 |
| Happy numbers | 5 / 19 | 21 | 50 | 2 |
| Additive primes | 5 / 19 | 21 | 52 | 2 |
| Attractive numbers | 5 / 19 | 21 | 52 | 2 |

Every row covers Main, its exact local-function inventory and four selected
library units. The seven function declarations include both earlier callees
and later callers. Classified assignment/Image advisories discharge no
obligation; limitation and operator-reassociation counts are zero. These are
application audits, not new compiler-proof totals.

I matched all 94 archived files to the retained application workspaces and
each `main.adb` to its reviewed Git blob. The six selected runtime snapshots
in each archive match the authoritative source, for 24 matching file instances.
Read-only reruns of the unchanged report audits and effective-policy assertions
reproduced every summary statistic. All 153 saved stdout lines match the
independently derived bytes, including Ada Integer Image spacing; stderr is
empty and successful validator completion establishes the checked zero statuses.
No application execution, solver or build was repeated by this reviewer.

The retention-stage [SHA256SUMS](../evidence/digit-prime-examples-20261108/SHA256SUMS)
and [integrity record](../evidence/digit-prime-examples-20261108/integrity-check.json)
were reviewed. All 38 payload checksums cover the complete retained file inventory.
All 34 recorded original copies and both losslessly compressed ledger/log files
match their originals. Its historical pending-review wording describes packet
retention before this acceptance. The validated manifest SHA-256 is
`d3f50c254bc14109fdbfd378e4a6bd5bfa631da670c6436737010299155a4752`;
the original application-summary SHA-256 is
`36b27b71de47b8acbf377fcf5ff9d293513fc62434cd8060ce5d15d8ded7c457`.

## Retained assurance and regression applicability

The accepted [#339 delivery](../scalar-functions.md#delivery-assurance-and-validation)
supplies complete native `20261108T155015-d9cbdb714cbd` evidence
(77 units, 1,165 entities, 18,525 checks) and complete Lean/source
`20261108T172947-84b3cd350332` evidence (820 modules, 145,525 declarations).
I rehashed all 2,588 native captured inputs and twelve native tool executables
in the original workspace; all match. All 145 repository native inputs also
match this target and the retained delivered installation. All 927 captured
Lean inputs match both their recorded original workspace and the target's
Git blobs; both Lean/Lake executable hashes match. The complete successful
audit remains applicable. No compiler source, semantic proof, generator,
auditor or build-setting change invalidates it.

The delivered compiler SHA-256 is
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`,
unchanged from accepted #339/#342/#343 evidence. Governed tracked inputs
in that installation are clean. Complete native/Lean success is retained
evidence: no fresh compiler proof, complete Lean run, clean rebuild or
independent kernel replay is claimed. Original failed runs remain failed.

Read-only discovery still finds exactly **645 unique test IDs**, matching the
accepted per-ID inventory without additions or omissions. Test source and
shared execution dependencies are unchanged. The other 644 IDs retain
applicable successes. Rosetta tests consume unchanged Rosetta inputs;
platform fixtures copy unchanged source/proof/project files; the Boolean
oracle test reads specific unchanged manifest records. No test consumes the
new batch narrative or session records as an execution input.

For `test_samples.SupportedSampleTests.test_manifest_samples`, all 80 earlier
source files and complete manifest records are unchanged. Their coverage is
72 retained cases from #339 and four each from the reviewed
[#342](review-callable-integer-examples-20261108.md) and
[#343](review-divisor-examples-20261108.md) increments. Fresh global checks
establish schema 1, 84 unique entries matching all 84 source files, valid
capability identifiers and specification references, and exact inventories
for the seven new helpers. The four new cases have the fresh equivalent
production checks above. This composes the affected manifest method's coverage;
it does not claim a fresh full-suite pass or describe all 84 programs as
freshly rerun. #345 retains its later combined checkpoint and assessment work.

## Review record and handoff

No material review finding remains. The initial Additive primes author draft
used the reserved Ada identifier `Digits` and was rejected by admission.
Renaming that local `Sum` corrected the source before the frozen target;
the packet retains the failed admission log. All four production application
checks passed on their first run. This source correction is neither a
compiler finding nor an excuse to restate a failed result as successful.

The coordinator's draft "Digit and prime examples — 2026-11-08" batch section
was also reviewed. Its domains, task arguments, output/check counts, retained
assurance and 645-ID accounting agree with the evidence. Its 147,507 finite
digit-sum comparisons are the author's separately recorded checks; they are
distinct from this reviewer's 1,029 boundary pairs and from the analytic
full-domain argument. The record preserves 71 rendered task mappings and
separates #344 publication from the held merge and unselected #345 work.

Selected reviewer configuration: **GPT-6 Astra / Max**, explicitly requested
for this independent task/domain/evidence review. Runtime model/effort
confirmation, total review elapsed time and token/cost telemetry are unavailable.
The managed 65.653-second interval measures application validation, not review
or whole-team elapsed time. `uname` and `scripts/dev.py paths` confirm Linux
x86-64; no native macOS validation is claimed. The live harness goal was null,
and CLI recall was not updated.

Only this report and isolated scratch/worktree state were written. Reviewer
checks are admission, independent mathematics, inventory discovery, hashing
and retained-report auditing. No production proof/build/full-test/render
run, implementation edit, GitHub write, push or merge was performed by this
reviewer. The coordinator owns evidence/report integration, publication and
issue/board handoff; keep the implementation target above distinct from later
documentation and report commits.
