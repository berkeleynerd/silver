# GCD and divisor examples review — 2026-11-08

**Accept implementation `5262fb81fa38c4afd55debf87ea44f50720aaf8c` for
the owner-authorized #343 increment through reviewable publication.** All four
programs preserve their primary tasks across their complete declared domains.
Their focused Linux application validation passes, and the accepted compiler
assurance and unaffected regression results remain applicable. No material
finding or implementation repair remains.

The [owner decision](../session-memory.md#2026-11-08--callable-examples-merge-and-divisor-group-authorized)
recorded at `079ad0251d` reached main through merge `a74e67c3a8`. It selects
#343 after the completed #342 group. This review does not authorize #343's
merge, start #344, complete milestone 21 or claim new rendered task coverage.
#345 retains the combined checkpoint and Rosetta assessment/render work.

## Reviewed inputs and task behavior

The implementation delta from `a74e67c3a8` is exactly four new Ada sources and
143 added manifest lines. Compiler/runtime, language, catalogue, Lean, auditor,
test sources and project settings are unchanged. I read the four cached primary
`task.wiki` pages, the Oracle, applicable scalar/function/guard/loop rules and
the batch's validation and reuse requirements. Each source uses closed local
functions with initialized scalar locals, explicit `in` formals, earlier-only
whole-assignment calls and one terminal return. No authored contract, proof
annotation or alternative source representation is introduced.

| Program | Complete argument domain | Declared result range | Source bytes | Shared operators |
| --- | --- | --- | ---: | ---: |
| [Least common multiple](../../samples/rosetta_least_common_multiple.adb) | Each argument -1000..1000 | 0..1,000,000 | 1,872 | 20 |
| [Coprimes](../../samples/rosetta_coprimes.adb) | Each argument -1000..1000 | Boolean | 1,657 | 12 |
| [Sum of divisors](../../samples/rosetta_sum_of_divisors.adb) | 1..100 | 0..5050 | 821 | 4 |
| [Tau function](../../samples/rosetta_tau_function.adb) | 1..100 | 0..100 | 760 | 4 |

Both GCD helpers have the same signed argument domain and return 0..1000.
The sources fit the unchanged 4,096-byte, 63-operator and 64-operand budgets.
Operator counting excludes comments and string literals but includes unary signs.
The largest String expressions contain six, five, three and three operands;
each embedded scalar expression has at most two leaves. Independent read-only
admission with the delivered compiler accepted all four exact Git blobs.

**GCD and loop sufficiency.** Sign normalization safely maps each formal to
0..1000. While `B > 0`, the update `(A,B) := (B,A mod B)` preserves the gcd,
with remainder in 0..B-1. For current positive B=b and first remainder r,
either r=0 finishes, or the following remainder is b mod r. If r<=b/2 this
is below r; if r>b/2 it equals b-r<b/2. Thus every two iterations either
finish or at least halve B. After 20 iterations B<=1000/1024<1, so B=0 and
A is the gcd. Once B is zero the guard preserves that completed result.
The initial (0,0) state correctly returns zero. No necessary Euclidean update
is skipped.

**LCM and Coprimes.** LCM's signed product lies in
-1,000,000..1,000,000; conditional negation produces its exact magnitude
without approaching Integer's minimum. GCD is positive unless both inputs are
zero. In the positive branch it divides the product exactly, giving the
nonnegative least common multiple within the declared result range. When just
one input is zero the quotient is zero; when both are zero the initialized
zero result is the required answer. The divisor guard loses no required case.
Coprime assigns the earlier GCD result to a local and returns whether it is one,
implementing the common-factor definition throughout the declared signed domain.
The 12 LCM demonstrations include the required 12/18 -> 36 example, all its
sign combinations, both zero positions, both-zero and boundary/unit controls.
Coprimes prints all five required pairs first, with results false, true, false,
true, false, followed by eight sign, zero and boundary controls.

**Sum and count of divisors.** For any declared N, the inclusive loop 1..N
visits every positive divisor once, and `N mod Divisor = 0` selects exactly
those divisors. Before candidate d, the accumulated sum is at most
1+...+(d-1)=d(d-1)/2<=4950, and the accumulated count is at most d-1<=99.
Both executable guards are therefore true whenever a contribution is required.
The guarded additions fit 0..5050 and 0..100 respectively. Initialization and
these prefix invariants establish the exact final sum/count for every N in
1..100. Both drivers print all 100 inputs in order, including 1 and 100;
neither cached task requires a particular column arrangement. Conservative
result ranges include zero, but callers accept the full declared ranges and
depend on no correlation with a particular actual.

Independent calculations checked all 1,002,001 nonnegative magnitude pairs
against `math.gcd` and `math.lcm`. Every 20-step calculation completed; the
largest observed active count was 15, at (610,987). The sign-normalization
argument covers all 4,004,001 signed pairs. For sum/tau, independent expected
values use the prime-factor identities
sigma(N)=product((p^(e+1)-1)/(p-1)) and tau(N)=product(e+1), with empty products
equal to one. Every one of the 100 outputs agrees with divisor enumeration,
and no accumulation guard discards work. These finite calculations supplement
the full-domain arguments; they are not universal language assurance.

## Fresh application evidence

Managed run `20261108T211402-d028fe5c343d` completed successfully on Linux
x86-64 with 22 reserved workers. Its native-tool phase returned zero and its
managed duration was 66.335889714 seconds. The original outputs are in the
integration worktree's `tmp/application-validation`; the
[retained packet](../evidence/divisor-examples-20261108/README.md) preserves
the application sources, reports, logs, outputs and validation helper.

I checked `validate_divisor_samples.py` against the unchanged manifest test.
It runs production admission and compilation, requires the byte-identical
author-source snapshot, invokes the existing report auditor and effective-policy
assertions, and compares actual executable stdout/stderr/status with the manifest.
The manifest and report inventories include every helper: GCD/LCM,
GCD/Coprime, Sum_Of_Divisors and Tau. Production options retain all-mode/all-report
checking, pinned solvers and limits, `--no-inlining` and `--no-loop-unrolling`.
Function safety is checked over full formal domains, including the earlier GCD
call chain, rather than only demonstration actuals.

| Application | Units / entities | Flow checks | Proof checks | Function termination checks |
| --- | ---: | ---: | ---: | ---: |
| LCM | 5 / 19 | 21 | 59 | 2 |
| Coprimes | 5 / 19 | 21 | 56 | 2 |
| Sum of divisors | 5 / 18 | 20 | 52 | 1 |
| Tau | 5 / 18 | 20 | 51 | 1 |

Each row includes the application and four selected library units. Classified
assignment/Image advisories discharge no obligation; limitation and operator
reassociation counts are zero. These are application audits, not new compiler
proof totals.

I rehashed all four archives and matched all 93 archived files to their retained
workspaces, including each `main.adb` against the reviewed Git blob. Rerunning
the unchanged Python report audits and effective-policy assertions on those
retained reports reproduced every summary statistic. All 225 saved output lines
match independently derived expected bytes, including Ada Integer Image spacing;
stderr is empty and each recorded executable status is zero. This reviewer
reran no application execution, solver or build.
The six selected runtime source snapshots in each archive also match the
unchanged authoritative library files, for 24 matching file instances.

The validated manifest SHA-256 is
`db4a6c1d1ac04a861ee3f700b9ad935268924eda623c2f24349d59010ac5fb01`.
The original application summary SHA-256 is
`926401cf929b5f30a692c0cd8c7146cca321699960d7dcc7ac42f3e0236b4da1`.
Both bind the reviewed sources and outputs to the retained run.

## Retained assurance and regression applicability

The accepted [#339 delivery](../scalar-functions.md#delivery-assurance-and-validation)
supplies complete native `20261108T155015-d9cbdb714cbd` evidence
(77 units, 1,165 entities, 18,525 checks) and complete Lean/source
`20261108T172947-84b3cd350332` evidence (820 modules, 145,525 declarations).
I independently rehashed all 2,588 native captured inputs and twelve native tool
executables in the original workspace; all match. All 145 repository native
inputs match this target. All 927 captured Lean inputs match both the recorded
original workspace and this target's Git blobs, with present sparse-worktree
files checked directly; both Lean/Lake executable hashes match. The recorded
successful whole-project audit remains applicable. No source, semantic proof,
source certificate generator, auditor or build-setting change invalidates it.

The retained installation's governed tracked inputs are clean and unchanged
from accepted `4d9ce491ee`. Its compiler matches both the application summary
and the accepted #339/#342 binary, SHA-256
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.
Complete native/Lean success is retained evidence; no fresh complete compiler
or Lean run, clean rebuild or independent kernel replay is claimed. Original
failed runs remain failed.

The exact discovered test inventory still contains **645 unique IDs**, matching
the accepted per-ID inventory with no addition or omission. Test source and
shared execution dependencies are unchanged. The other 644 IDs retain their
applicable successes: Rosetta tests consume unchanged Rosetta metadata; platform
fixtures copy unchanged source/proof/project inputs; the Boolean oracle test
reads named pre-existing manifest entries that are unchanged.

For `test_samples.SupportedSampleTests.test_manifest_samples`, all 76 prior
source files and complete manifest records are unchanged. Their accepted
coverage consists of 72 cases from #339 and four from the
[reviewed #342 checkpoint](review-callable-integer-examples-20261108.md).
The four new cases have the fresh equivalent production checks above. Fresh
global checks establish schema 1, 80 unique entries matching all 80 sample
files, valid capability identifiers, specification references and exact helper
inventories. This composes the affected manifest method's coverage; it does
not describe all 645 IDs or all 80 programs as freshly rerun. #345 retains its
later combined checkpoint and assessment reconciliation.

## Review record and handoff

The draft second-group batch account was also inspected. Its domains, check
counts, task arguments and distinction between retained compiler assurance and
fresh application evidence agree with this review. It preserves the 71 rendered
Stage-1 mappings and separates the remaining #344/#345 work from this increment.

Selected reviewer configuration: **GPT-6 Astra / Max**, explicitly requested
for this independent task/domain/evidence review. Independent runtime model and
effort confirmation, total elapsed review time and token/cost telemetry are
unavailable. The managed 66.336-second interval measures application validation,
not review or whole-team elapsed time. `uname` and `scripts/dev.py paths` confirm
Linux x86-64; no native macOS validation is claimed. The live harness goal was
null, and CLI recall was not updated.

Only this report and isolated scratch/worktree state were written. Review
checks were read-only admission, mathematics, discovery, hashing and retained-report
auditing. No production proof/build/test-suite/render run, implementation edit,
GitHub write, push or merge was performed by this reviewer. The coordinator
owns report/evidence integration, publication and issue/board handoff; keep the
implementation target above distinct from later documentation/report commits.
