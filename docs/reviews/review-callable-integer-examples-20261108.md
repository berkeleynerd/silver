# Callable integer examples review — 2026-11-08

**Accept implementation `db8ca3495c6b2a118f4bd9ebe8bbcddad2e6fa0f` for
the authorized #342 increment.** The four callable examples preserve their
primary tasks across their complete declared domains, and their focused Linux
application validation passes. The accepted compiler assurance and unaffected
regression results remain applicable. No material finding or source repair is
required by this review.

This accepts the first group in the
[batch plan](../scalar-function-rosetta-batch.md), whose
[owner authorization](../session-memory.md#2026-11-08--callable-integer-examples-selected-during-external-review)
is recorded at `acde83e294`. It does not complete milestone 21 or authorize the
remaining groups. #343 and #344 are unstarted; #345 retains the combined
checkpoint, assessment reconciliation and render. No new rendered task mapping
is claimed. The implementation PR and #342 remain open for the owner's later
merge decision.

## Reviewed inputs and mathematical behavior

The implementation delta is exactly four new Ada sources and 136 added manifest
lines. Compiler/runtime, language rules, catalogue, proof, auditor, test sources
and project settings are unchanged. I read the four primary `task.wiki` pages,
the Oracle, current scalar-function and arithmetic rules, validation/reuse policy
and batch requirements. Each task has an actual local callable function, full
formal-domain checking, initialized scalar locals and one terminal return.
Calls are complete assignment RHSs inside Main's existing counted or array
iteration. No source annotation, hidden replacement or new language mechanism
is introduced.

| Source | Declared argument domain | Source bytes | Shared operators | Largest expression leaf count |
| --- | --- | ---: | ---: | ---: |
| [Factorial](../../samples/rosetta_factorial.adb) | 0..12 | 681 | 3 | 3 |
| [Fibonacci](../../samples/rosetta_fibonacci_sequence.adb) | 0..46 | 972 | 4 | 4 |
| [Signum](../../samples/rosetta_signum.adb) | Full Integer | 697 | 7 | 4 |
| [Sum multiples](../../samples/rosetta_sum_multiples_of_3_and_5.adb) | 0..1000 | 1,202 | 21 | 10 |

These counts respect the existing 4,096-byte, 63-operator and 64-leaf limits.
Operator accounting includes signs in literals and subtype bounds as required
by the source-wide scanner. All four sources also passed independent read-only
admission checks with the delivered compiler.

- **Factorial:** before iteration `i` in `1..N`, induction gives
  `Result = (i-1)!`. Since `i <= 12`, that value is at most
  `11! = 39,916,800`; the guard never skips a required multiplication.
  Its largest product is `12! = 479,001,600`, within the result subtype and
  Integer. For zero the loop is empty and returns one. `13!` exceeds Integer,
  so 0..12 is the complete nonnegative factorial-result domain fitting this
  integer representation. The primary task permits an iterative function and
  makes negative-input support optional. Main demonstrates all 13 inputs.
- **Fibonacci:** zero is handled explicitly. For a positive input, the initial
  pair is `(F0,F1)`; before step `i` in `2..N` it is `(F(i-2),F(i-1))`.
  With `i <= 46`, those terms are at most `F44 = 701,408,733` and
  `F45 = 1,134,903,170`, so both guards are true at every required step.
  The update yields `F(i)` and preserves the pair invariant. The last possible
  addition is `F44 + F45 = F46 = 1,836,311,903`; no unused F47 is computed.
  The null loop for one returns one. F47 exceeds Integer. The task's optional
  negative-index extension is outside the stated domain. Main covers all 47
  inputs, including 0, 1, 2, 10 and 46.
- **Signum:** the negative, positive and remaining zero branches partition
  every Integer value and return -1, 1 and 0 respectively. There is no
  negation, division or absolute-value operation on the argument, so the
  minimum Integer is handled directly. The driver contains all three primary
  examples and both Integer endpoints. This Integer representation has no
  distinct signed zero, so the task's representation-dependent extension does
  not apply.
- **Sum multiples:** zero returns zero. Otherwise `Upper = N-1 >= 0` and
  `q_d = Upper/d` is the floor quotient for positive `d` in 3, 5 and 15.
  The multiples' sum is `d*q_d*(q_d+1)/2`. Adjacent integers have an even
  product; multiplication precedes division, so every division by two is exact
  and loses no term. Inclusion-exclusion subtracts each common multiple of 15
  once. The numerator bounds are 333,666, 199,000 and 66,330; the first two
  sums total at most 266,333. Even the independent interval subtraction
  `[-33,165,266,333]` fits Integer; actual results are nonnegative. The eleven
  demonstrations cover zero, exclusion of the bound itself, the overlap at 15,
  999 and the required `N=1000`, whose result is 233,168. The task marks the
  `10^20` extension as extra credit.

These are functional-correctness arguments in addition to the compiler's safety
proofs. Safe guarded code alone would not establish the task result. Independent
small calculations checked every factorial and Fibonacci input and all 1,001
sum inputs, including that no required recurrence guard is false. Expected bytes
were derived with `math.factorial`, the binomial-sum identity for Fibonacci,
the sign partition and direct enumeration of multiples. Every manifest stdout
matches, including Ada Integer Image spacing; stderr is empty and status is zero.

## Focused application evidence

The [retained packet](../evidence/callable-integer-examples-20261108/README.md)
records managed run `20261108T194440-c7a94430faf1` on Linux x86-64. Its actual
native-tool phase exited zero; the run completed successfully in 76.284 seconds
with 22 reserved workers. The summary's four check/compile outcomes and exact
execution comparisons pass. This is a focused application run, not another
complete compiler proof checkpoint.

I reviewed `validate_callable_samples.py` against the unchanged manifest test.
It performs production admission and compilation, byte-identical source
snapshot checks, the existing effective-prover-policy assertions, complete
application/library report audits and direct executable output/status checks.
Its four `application_functions` inventories exactly name `Factorial`,
`Fibonacci`, `Signum` and `Sum_Multiples`; none omits a helper. The effective
policy retains all-mode/all-report checking, the pinned solvers and limits,
`--no-inlining` and `--no-loop-unrolling`. Function safety is therefore checked
over the declared formal domains rather than only the demonstration actuals.

| Application | Units / entities | Flow checks | Proof checks |
| --- | ---: | ---: | ---: |
| Factorial | 5 / 18 | 20 | 51 |
| Fibonacci | 5 / 18 | 20 | 52 |
| Signum | 5 / 18 | 20 | 50 |
| Sum multiples | 5 / 18 | 20 | 58 |

Each row includes the application and its four selected library units. These
are separate audits, not additional compiler-proof totals. Each includes the
function termination check. Classified assignment/Image advisories contribute
no proved obligation; no limitation or reassociation advisory occurs here.

Independent inspection rehashed all four archives, matched their 91 files to
the retained application workspaces, and matched each source snapshot to the
reviewed Git blob. I reran the unchanged Python report audit and effective-policy
assertions for all four retained report sets and compared their saved output
with the independently derived expectations. All passed. No solver or build
was rerun by this reviewer.

## Retained baseline and regression applicability

The [accepted #339 delivery](../scalar-functions.md#delivery-assurance-and-validation)
supplies the complete native `20261108T155015-d9cbdb714cbd` result
(77 units, 1,165 entities, 18,525 checks) and complete Lean/source
`20261108T172947-84b3cd350332` result (820 modules, 145,525 declarations).
Their successful provenance, source correspondence and audits remain applicable:
the exact diff from accepted target `4d9ce491ee` changes only the five sample
files among source, scripts, proof, tests, catalogue, project, sample and Rosetta
inputs. The retained installation's governed tracked inputs are clean. Its
compiler SHA-256 matches both the new application summary and the independently
accepted #339 binary:
`807d862b572e4dcab8e72302a2fdcfe1a3304f3c064b9166900e24544b8dbcfe`.
There is no reason to repeat the unchanged expensive proofs. Earlier failed
baseline runs remain failed, and retained success is not described as a fresh
native or Lean run.

The accepted inventory still has **645 test IDs**; four added manifest entries
do not create four new unittest methods. The other 644 IDs retain applicability
because their code and executed dependencies are unchanged. In particular,
Rosetta tests use the unchanged Rosetta manifest/assessments, platform fixtures
copy source/proof/project inputs rather than these samples, and the Boolean
oracle test only reads named pre-existing manifest entries.

For `test_samples.SupportedSampleTests.test_manifest_samples`, the 72 previous
sample sources and complete records are unchanged, so their accepted
admission/proof/build/execution outcomes remain applicable. The four new cases
have the fresh equivalent checks above. Fresh global checks establish schema 1,
76 distinct manifest entries matching all 76 sample files, admitted capability
identifiers, valid specification references and exact function inventories.
This composes the affected manifest method's coverage for #342; it is not a
claim that all 645 IDs or all 76 programs were freshly rerun. #345 still owns
the later combined batch checkpoint and final integration/assessment work.

The lead's draft first-group batch record and roadmap were also inspected:
they distinguish the four validated programs from the pending eight candidates,
hold the rendered Stage-1 count at 71 and leave merge/issue closure with the
owner. No further implementation is selected by this verdict.

## Review record and handoff

Selected reviewer configuration: **GPT-6 Astra / Max**, requested for this
independent review. Runtime model/effort confirmation, total elapsed review
time and token/cost telemetry are unavailable. The managed 76.284-second
interval above measures application validation, not review or whole-team time.
`scripts/dev.py paths` confirmed `linux-x86_64`; no native macOS validation is
claimed. The live harness goal was null, and CLI recall was not updated.

Only this report and isolated worktree state were written. Read-only admission,
mathematical checks and retained-report audits were performed; no production
proof/build/test-suite/render run, implementation edit, GitHub write, push or
merge was performed by this reviewer. The coordinator owns integration of this
report and the evidence packet, publication and issue/board handoff. Keep the
review target above distinct from the later documentation/report commits.
