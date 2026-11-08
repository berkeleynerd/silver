# Scalar-function driver reconciliation

**Prepared source review, 2026-11-07; delivery validation recorded 2026-11-08.**
The original bounded review prepared the Rosetta metadata for owner-authorized
[#298](https://github.com/berkeleynerd/silver/issues/298) and draft
[PR #339](https://github.com/berkeleynerd/silver/pull/339). That preparation did not promote
support, complete assurance or authorize merge; the delivery section below records
the later actual validation. The
[capability record](../docs/scalar-functions.md) is the home of complete feature
assurance. The historical lead reconciliation in
`tmp/scalar-functions-298/tmp/assessment-scalar-functions-20261107.md` remains
prepared provenance; this record extends its source/task comparison.

The bounded subthread selected GPT-6.1 Sol / High. Runtime model/effort,
token/cost and total elapsed-work telemetry are unavailable. It inspected cached
source, specifications, metadata and retained native application results; it
ran no build, proof, test or renderer and is not an independent critical review
of the compiler or universal assurance argument.

## Source, task and bounded behavior

The target is `tmp/scalar-functions-source-integration-298`, observed HEAD
`59fd67c7c902feec99766a991c43f2eed21b62b3`, following published implementation
`96950ce3e8`. The two proof-only fixes present in its working tree remain under
lead validation. Source identity, rather than the branch name alone, controls
whether this mapping applies.

The cached task is keyed by **Primality by trial division** in
`rosetta/coverage.json`, path `p/primality-by-trial-division`, revision **414879**,
cached task timestamp `2026-10-02T21:34:48Z`. It asks for a Boolean function using
trial division, excludes 1 and all nonpositive integers, and explicitly permits
loops other than the suggested square-root loop. It requires no particular
output format or larger input domain.

The unchanged 28-line
[driver](../samples/rosetta_primality_by_trial_division.adb), SHA-256
`6e2d5263135fb3aa0c36554425303c3b87a375315207c37ee897c5ed71b457a4`, defines
`Candidate` as Integer range -10..100 and `Is_Prime(N : in Candidate) return
Boolean`. The local flag starts False. If N >= 2 it becomes True; every divisor
from 2 through N/2 is tested and any exact divisor clears it. The final return
is Boolean. Main calls the function as the entire RHS of a Boolean assignment
for every integer in the domain and prints exactly the prime candidates.

For N < 2 the flag stays False. For 2 and 3 the divisor loop is empty, leaving
True. Every composite N >= 4 can be written N = a*b with a,b >= 2, so the proper
divisor a lies between 2 and N/2; some test therefore clears the flag. Prime N
has no such divisor. All cases in the declared domain are covered without an
answer table, floating-point square root, while loop, early return, extra
procedure, computed String buffer or authored contract. The upper divisor bound
is at most 50; every executed divisor is at least 2. The positive-candidate
guard supports scalar interval refinement for division, and finite counted
loops establish the sample's termination. The admitted language's full-domain
and complete-discharge guarantees remain the separate capability assurance
claim.

Independent expected-output derivation marks composite positive multiples
`2*d, 3*d, ... <= 100` for each d from 2 to 100, then retains exactly n >= 2 not
marked while scanning -10..100. This differs from the driver's candidate-wise
trial division. The resulting 25 lines are the Integer Images of:

`2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97`.

Each line has one leading space and a trailing newline. Expected stdout
SHA-256 is `e8bcc8b23fdad035260f1dcf4699346083a51b45e2dc26a51678f42bcde0a40b`,
with empty stderr and exit status 0. Static byte comparison matched both the
existing manifest and retained native stdout.

The [retained native packet](../docs/evidence/scalar-functions-20261107/final-native-behavior/README.md),
prepared in `tmp/scalar-functions-parser-repairs-298` and published at
`49b073fc8b`, records successful admission, proof, build and execution on unchanged
application source. Its runner checked the byte-identical source snapshot and
application/function report policy. Its audit counted 5 units, 18 entities,
20 flow checks, 49 proof checks and 1 termination check, with 1 assignment
advisory and 1 Image advisory. These retained results were read, not rerun here;
they do not establish complete compiler Bronze/Silver verification, Lean
checking or complete actual-source correspondence for the later integration.

## Proposed metadata and provenance

Preserve all original assessment provenance: assessed date `2026-10-15`,
revision `414879`, rubric `2`, tier `standard`, model `claude-sonnet-5-5`, effort
`medium`. There is no prior targeted `review` object to replace. Its historical
approach anticipated broader while loops, procedures, functions, string-building
and Boolean surface; those are not the implemented driver. Add a separately
attributed 2026-11-07 source review rather than relabeling that original assessment.

The driver's exact assessed surface is:

- `named-integer-subtypes` for Candidate and its formal domain;
- `scalar-functions` for the closed Boolean function and assignment call;
- `scalar-boolean-objects` for initialized flags, comparisons and conditional use;
- `integer-for-loops` for both counted loops;
- `interval-integer-division` for / and mod;
- `scalar-guard-refinement` for the Integer formal guard;
- `integer-image` for printed candidate values.

Put_Line is existing baseline output; this driver does not need `put`. No broad
`functions`, `procedures`, `booleans`, `ranged-subtypes`, `integer-division`,
`for-loops`, `scalar-image` or `string-building` identifier is required or promoted.
Only `scalar-functions` would be added to `supported`, after complete assurance.
The assessor's current-language description must state the exact function scope,
immutable formal refinement, signature subtype use, assignment-only calls,
conservative results, unchanged budgets and remaining exclusions. The renderer
also needs the new admission-question entry and human-readable label; otherwise
it rejects the unknown supported identifier.

## Delivery validation — 2026-11-08

The [capability delivery record](../docs/scalar-functions.md#delivery-assurance-and-validation)
separately retains the final implementation, regression inventory and independent
acceptance status. Current governed integration is `0333d33503`: the reviewed
Ada/function proofs, independently approved auditor correction and one diagnosed
facade import. Complete Linux [native assurance](../docs/evidence/scalar-functions-20261107/native-checkpoint/auditor-refresh-53d3/README.md)
and [Lean/source/module/axiom assurance](../docs/evidence/scalar-functions-20261107/complete-lean/20261108T172947-84b3cd350332/README.md)
passed with actual driver exits 0. The complete Lean result covers all 820 project
modules and 145,525 declarations; earlier failed checkpoints remain failed.
The raw-source derivation repair for #340 retains its separate review and is
included in that complete current closure.

The driver SHA-256 remains `6e2d5263135fb3aa0c36554425303c3b87a375315207c37ee897c5ed71b457a4`.
The repaired compiler's complete manifest run passed all 72 samples, including
this unchanged source, and the [remaining compiler/platform regressions](../docs/evidence/scalar-functions-20261107/final-regression/isolated-final/README.md)
passed with original deadlines and options. The facade-only import changes no
native source or application behavior, and no redundant driver compilation was
needed for this metadata reconciliation. Original assessment and prepared-review
provenance above remain unchanged.

Only `scalar-functions` is newly supported. The actual render and its three
regression results are retained in the final capability delivery record; general
functions, procedures and booleans keep their separate unsupported scope. Final
independent acceptance is recorded there separately from this task/source
reconciliation. Implementation merge remains held, and the stage change does
not authorize another feature.
