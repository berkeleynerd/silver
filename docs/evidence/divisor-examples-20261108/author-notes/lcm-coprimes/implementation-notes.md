# LCM and Coprimes — bounded implementation handoff for #343

Date: 2026-11-08 UTC. Worktree: `tmp/divisor-lcm-coprimes-343`;
branch: `feat/divisor-lcm-coprimes-343`; base: `a74e67c3a8`.
The lead supplied owner authorization for #343 after decision merge #351.
This subthread owns only the two new sample sources, with proposals/evidence
under untracked `tmp/`. Shared manifest, docs, production validation and
publication belong to the lead. No compilation, proof, build or application
execution was performed here; compiler use was limited to read-only admission.

Selected model/effort supplied by the lead: GPT-6.1 Sol / Extra High. Runtime
model/effort confirmation and whole-team elapsed/token/cost data are unavailable
to this subthread; saved configuration was not treated as live-setting evidence.

## Task fidelity and domains

Both public helper functions accept each Integer argument in -1000..1000.
This includes every required demonstration input and both signed boundaries.
Their earlier, closed GCD helpers accept the same full product domain and
return 0..1000. Each helper has explicit `in` formals, scalar initialized locals,
only earlier whole-RHS calls, finite loops and one terminal return. No authored
contracts or proof annotations were added. `pragma SPARK_Mode (On);` is the
only pragma.

`rosetta_least_common_multiple.adb` defines GCD followed by LCM, with declared
LCM result 0..1,000,000. It demonstrates 12,18 -> 36, all four sign combinations
of that pair, zero in either position and both positions, signed input
boundaries, unequal coprime magnitudes 1000 and 999, and unit cases.
`rosetta_coprimes.adb` defines GCD followed by Boolean Coprime. It prints all
five task pairs first, yielding false, true, false, true, false. Further cases
cover 0,0; zero/unit in either order; a negative unit; both signed boundaries;
equal nonunit values; and zero/nonunit. Coprime means `gcd(abs(a),abs(b)) = 1`,
with the conventional extension gcd(0,0)=0.

Primary task sources read: `rosetta/l/least-common-multiple/task.wiki` and
`rosetta/c/coprimes/task.wiki`, as captured by the #343 planning record.
The governing scalar/function/guard/loop rules and the proposed domain in
`docs/scalar-function-rosetta-batch.md` were read, along with the existing GCD
sample and merged callable samples. No task scope or language rule changed.

## Full-domain loop and guard argument

The GCD helpers normalize their two signed formals using separate `< 0` arms.
Negating any negative input in -1000..-1 yields 1..1000; each nonnegative
alternative lies in 0..1000. A and B therefore begin as absolute magnitudes.
When B is positive, `(A,B) := (B,A mod B)` preserves their nonnegative gcd and
gives a remainder in 0..B-1, contained in 0..999. When B is zero the guarded
body makes no change, so subsequent iterations preserve the completed result.

For a positive B=b, let r=A mod b. If r=0, the next B is already zero.
Otherwise the following remainder is s=b mod r. If r<=b/2, then s<r<=b/2.
If r>b/2, then s=b-r<b/2. Thus every two guarded Euclidean updates either
finish or reduce B to less than half its earlier value. Initial B<=1000 and
2^10=1024, so after 20 iterations B<1 and hence B=0. A is consequently the
exact gcd over the complete declared domain; when both initial inputs are zero
it remains zero. The B>0 guard skips no necessary update: it becomes false
precisely once that Euclidean computation is complete.

LCM computes the signed product, bounded by -1,000,000..1,000,000, then negates
it only when negative. Its normalized product is exactly abs(left*right), in
0..1,000,000. GCD returns a positive divisor unless both inputs are zero.
For a positive divisor, division is safe and exact because gcd divides both
arguments and therefore their product. The quotient is the nonnegative least
common multiple, at most the product, so it fits the result subtype. If one
input is zero and the other is nonzero, the positive-divisor branch computes
zero. If both are zero, the positive-divisor guard is false and the initialized
result zero is exactly the task's required zero result. The guard therefore
does not discard any required result or silently reduce the declared domain.

Coprime assigns the earlier GCD result to a local and returns its comparison
with 1, establishing the common-factor definition for every pair in the
declared signed domain, including the stated zero convention.

## Independent mathematical expectations

Run `python3 tmp/independent_expectations.py` to regenerate both proposal files.
The output text is derived from Python `math.lcm` and `math.gcd`, with Ada's
Integer'Image leading space for nonnegative inputs explicitly represented.
`tmp/manifest-entries.json` is a JSON array containing both proposed entries;
each includes every helper in `application_functions`, exact stdout, empty
stderr and exit status zero.

`tmp/independent-arithmetic.json` retains source hashes and an arithmetic
calculation over all 1,002,001 pairs of magnitudes in 0..1000. Its 20-step GCD
calculation matched Python `math.gcd`, ended with B=0 on every pair and gave
LCM equal to Python `math.lcm`. Signed normalization covers all 4,004,001
pairs in the declared signed square. The largest executed step count was 15,
first observed at (610,987). This finite calculation supplements the argument
above; it is not compiler assurance or a native program execution.

The sources contain 1872 and 1657 bytes respectively. A literal/comment-aware
count gives 20 and 12 shared arithmetic/concatenation operators respectively,
within the current 4096-byte/63-operator source budgets. LCM's largest String
expression has six operands and Coprimes' has five; each embedded scalar
expression has at most two leaves, within the independent 64-operand limit.

## Admission evidence and remaining lead work

Actual host: Linux x86_64; `python3 scripts/dev.py paths` identified
`linux-x86_64`. Both sources were checked read-only with the delivered binary:

`/home/canto/src/github.com/berkeleynerd/silver/tmp/scalar-functions-298/.silver/linux-x86_64/compiler/bin/silver check ABSOLUTE_SOURCE_PATH`

Each check exited zero with stdout `Accepted: silver.\n` and empty stderr.
Exact invocation/output records are retained as:

- `tmp/rosetta_least_common_multiple.adb.admission.json`
- `tmp/rosetta_coprimes.adb.admission.json`

No native proof/build/application-execution result is claimed. The lead still
owns shared manifest integration, complete production checks and task review.
Only the two sample sources are committed by this stream in
`072842d04c04a7f9ceeeb1ae98ebc033d9a049d4`, using `Refs #343`;
this partial issue increment does not close #343. The branch was not pushed.
