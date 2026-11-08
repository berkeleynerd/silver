# Scalar-function Rosetta batch

## Status and authorization — 2026-11-08

**First group #342 complete and merged through
[PR #351](https://github.com/berkeleynerd/silver/pull/351);
second group #343 implemented, validated on Linux and independently reviewed;
publication prepared.**
The owner initially instructed **“Proceed with the planning effort we just discussed.”**
The [dated decision](session-memory.md#2026-11-08--coherent-batch-planning-authorized)
authorizes the batching guidance, candidate assessment, milestone/issues and
reviewable planning publication. [Milestone 21](https://github.com/berkeleynerd/silver/milestone/21)
holds the four increment issues below.
The owner [authorized merging the ready plan](session-memory.md#2026-11-08--batch-planning-merge-authorized-report-next-unit-first)
in PR #346 and asked for the next unit to be reported before implementation.
PR #346 merged as `74ea2edeaa`. The subsequent
[owner instruction](session-memory.md#2026-11-08--callable-integer-examples-selected-during-external-review)
selects #342's four callable examples while the external review proceeds.
Those four samples are validated and reviewed. The owner's subsequent
[“Agreed. proceed.”](session-memory.md#2026-11-08--callable-examples-merge-and-divisor-group-authorized)
authorizes merging PR #351 and implementing #343's four divisor programs through
reviewable publication. #343's merge remains a later owner decision. #344 stays
unstarted, and #345 retains the later combined batch checkpoint.
PR #351 merged as `a74e67c3a8` and #342 is closed. The divisor group starts from
those accepted inputs; its own source, manifest and application evidence remain
separate from the first-group checkpoint below.

The [first-group checkpoint](#callable-integer-examples--2026-11-08) below
records the four programs and their application validation. It does not complete
the twelve-task batch or promote the candidate Rosetta mappings.

The preceding batch, [small nonrecursive functions #298](https://github.com/berkeleynerd/silver/issues/298),
is complete: PR #339 merged as `05302f760f` and milestone 20 is closed. Its
accepted native/Lean/source assurance supplies this successor's delivery baseline;
pending or failed checkpoints are not reusable success. Planning does not expand
#298; the later authorizations above select the first two implementation groups.

## Outcome and choice

Propose twelve separate numeric programs with twelve Rosetta task mappings.
Four exercise explicitly requested callable interfaces; the other eight use
the same scalar helpers, bounded arithmetic and counted-loop patterns. They
exercise function reuse without introducing another language mechanism.

This is a sample-only batch. Compiler/runtime, language, catalogue, Lean proofs,
auditor and resource policies are outside its proposed changes. Keep the current
4,096-byte source, 63-operator and 64-operand budgets for each complete program.
Each task gets its own source; the plan does not put all twelve tasks and helpers
into one program. Main-local helper reuse is within each source, not a new shared
library or package facility.

The complete [#300 opportunity inventory](https://github.com/berkeleynerd/silver/issues/300)
remains retained. Factorial, Fibonacci, signum and Sum multiples were explicitly
set aside there because an inlined demonstration would omit their requested
callable interface. The other eight are arithmetic candidates from that
inventory. GCD is already delivered; Primality is #298's driver. They supply
helper designs here and do not count as new mappings.

Other scalar call positions would require new grammar/evaluation/source proofs;
array-sort samples are also plausible existing-language work but do not exercise
the newly delivered function interface. This proposal chooses a useful group
with expected compiler-proof reuse, without selecting another future batch.
The saving is avoided repeated validation of unchanged compiler machinery,
not elimination of application proof or task-fidelity work.

## Callable integer examples — 2026-11-08

Implementation target `db8ca3495c` adds four sources and their manifest entries
to authorization baseline `acde83e294`. The existing 72 manifest entries and
sources are unchanged; the resulting manifest contains 76 programs. Each new
program uses a real callable function and the delivered scalar-function rules.
No compiler, runtime, language, catalogue, Lean or test implementation changes.

| Program | Declared argument domain | Demonstrated cases | Audited flow / proof checks |
| --- | --- | --- | --- |
| [Factorial](../samples/rosetta_factorial.adb) | 0..12 | All 13 arguments, including 0! and 12! | 20 / 51 |
| [Fibonacci](../samples/rosetta_fibonacci_sequence.adb) | 0..46 | All 47 arguments, ending at F46 | 20 / 52 |
| [Signum](../samples/rosetta_signum.adb) | Full Integer | -10, 42, 0 and both Integer endpoints | 20 / 50 |
| [Sum multiples](../samples/rosetta_sum_multiples_of_3_and_5.adb) | 0..1000 | 11 zero, strict-boundary, overlap and upper-bound cases | 20 / 58 |

Each row includes the application and its four selected library units; these
are separate sample audits, not additional compiler proof totals. Managed run
`20261108T194440-c7a94430faf1` passed admission, production application proof,
build, both report-policy checks and exact stdout/stderr/status comparisons for
all four programs in 76.284 seconds, reserving 22 workers on Linux x86_64.
The production options retain `--no-inlining` and `--no-loop-unrolling`, so
the function checks cover their full formal domains. The retained application
sources match the sample bytes. The [evidence packet](evidence/callable-integer-examples-20261108/README.md)
contains the managed log, reports, sources, output, validator and derivation notes.

The arithmetic guards preserve the intended result. Before Factorial's step
i <= 12, the accumulator is (i-1)! <= 11! = 39,916,800. Before Fibonacci's
step i <= 46, its terms are F(i-2) <= F44 and F(i-1) <= F45, exactly the two
guard bounds; it never computes F47. Signum partitions Integer into negative,
zero and positive values without negating its argument. Sum multiples uses
the arithmetic-series identity and inclusion-exclusion; every intermediate
fits Integer. Independent expected outputs use `math.factorial`, a binomial
identity for Fibonacci and direct enumeration for Sum multiples. The latter
was compared across all 1,001 declared inputs. These task-correctness arguments
complement the production safety checks; samples do not prove the language.

The accepted [#339 baseline](scalar-functions.md#delivery-assurance-and-validation)
supplies complete compiler native and Lean/source assurance. The
[independent review](reviews/review-callable-integer-examples-20261108.md)
accepts this reuse: compiler/proof/tool/test inputs are unchanged, and the binary
matches the accepted #339 binary. The 645-test inventory is unchanged. Of these,
644 IDs retain their applicable results; the manifest test is covered by its
72 retained sample cases, four fresh cases and fresh global inventory/metadata
checks. This is composed coverage, not a fresh 645-test run. No new complete
compiler or Lean run is claimed. The original failed baseline runs remain failed.

The first Factorial/Fibonacci drafts needed the required parentheses around
their arithmetic RHSs. That admission repair changed neither algorithm nor
domain and preceded the successful production run. No application proof/build
failure occurred in the four-program checkpoint.

| Round | Selected model / effort | Result and rework | Available timing |
| --- | --- | --- | --- |
| Factorial/Fibonacci implementation | GPT-6.1 Sol / Extra High | Two faithful callable sources, independent outputs and complete-domain guard arguments; corrected arithmetic parentheses before validation | Agent elapsed/token/cost measurements unavailable |
| Signum/Sum multiples implementation | GPT-6.1 Sol / Extra High | Two faithful callable sources, independent outputs and all 1,001 sum inputs checked | Agent elapsed/token/cost measurements unavailable |
| Integration and application validation | Lead runtime model/effort not independently exposed | Four manifest entries; all four production application checks passed | Managed native interval 76.284 s; whole-team elapsed unavailable |
| Independent task/evidence review | GPT-6 Astra / Max | Accepted `db8ca3495c`: task fidelity, full-domain guard arguments, exact output, retained application reports and baseline applicability; no material finding | Total review elapsed/token/cost measurements unavailable |

Selected agent settings are distinct from independently confirmed runtime
settings, which were not exposed. No new Rosetta coverage is claimed: #345 owns
the later narrow assessment/render and combined checkpoint. The implementation
is merged in [PR #351](https://github.com/berkeleynerd/silver/pull/351) as
`a74e67c3a8`, and #342 is closed. #343 is selected next; #344
stays unstarted. Milestone 21 remains open.

## GCD and divisor examples — 2026-11-08

Implementation target `5262fb81fa` adds four sources and their manifest entries
to merged baseline `a74e67c3a8`. All 76 earlier sample sources and manifest
records are unchanged; the current inventory is 80 programs. Compiler/runtime,
language, catalogue, Lean, auditor and test implementation inputs are unchanged.

| Program | Declared argument domain | Demonstrated cases | Audited flow / proof checks |
| --- | --- | --- | --- |
| [Least common multiple](../samples/rosetta_least_common_multiple.adb) | Both arguments -1000..1000 | 12 pairs covering the required 12/18 example, signs, zero and bounds | 21 / 59 |
| [Coprimes](../samples/rosetta_coprimes.adb) | Both arguments -1000..1000 | All five required pairs plus eight sign, zero and boundary controls | 21 / 56 |
| [Sum of divisors](../samples/rosetta_sum_of_divisors.adb) | 1..100 | Every required input, including primes and perfect squares | 20 / 52 |
| [Tau function](../samples/rosetta_tau_function.adb) | 1..100 | Every required input, including primes and perfect squares | 20 / 51 |

Managed run `20261108T211402-d028fe5c343d` passed admission, production application
proof, build, the unchanged effective-proof-policy and report audits, and exact
stdout/stderr/status comparison for all four sources in 66.336 seconds, with
22 reserved workers on Linux x86_64. Each row covers its application and four
selected library units. The LCM and Coprimes audits include both their GCD helper
and their task function; they each have 19 audited entities. Sum and Tau each
have 18. These are application checks, not new compiler-proof totals.
The [retained packet](evidence/divisor-examples-20261108/README.md) contains
the actual source snapshots, reports, logs, output and validation helper.

The shared Euclidean algorithm preserves GCD after sign normalization. Every
two active updates reduce the nonnegative second operand by at least half;
after 20 steps it is at most 1000/1024, hence zero. Inactive guarded iterations
preserve the answer. Independent enumeration of all 1,002,001 magnitude pairs
matches `math.gcd` and `math.lcm`, with at most 15 active steps observed;
the sign-normalization argument extends this to every signed argument pair.
LCM computes the absolute product divided by GCD when the latter is positive.
Only two zero arguments give GCD zero; retaining the initialized zero result
then implements the required zero case. All intermediate magnitudes are bounded
by 1,000,000. Coprimes tests whether the resulting GCD is one.

Before candidate divisor d <= 100, the sum of earlier positive candidates is
at most d(d-1)/2 <= 4,950 and their count is at most d-1 <= 99. The static
guards therefore cannot discard a required contribution in either divisor
program. The full loops visit every positive divisor. Expected sums and counts
come independently from prime-factorization product identities, covering all
100 outputs. Application proof retains the production `--no-inlining` and
`--no-loop-unrolling` options and checks full formal domains; task arguments
establish the mathematical result in addition to safety.

The [independent Astra / Max review](reviews/review-divisor-examples-20261108.md)
accepts the implementation, task arguments, application evidence and retained
#339 compiler/native/Lean assurance. It independently matched all 93 archived
files, all 225 output lines, 2,588 captured native inputs and 927 Lean inputs,
with their recorded tool identities. The unchanged 645-ID test inventory retains
644 unaffected results; the manifest ID combines 76 retained cases with four
fresh cases and fresh global inventory/metadata checks. The focused run checked
all 80 manifest records, unique source coverage, capability identifiers and
specification links. No fresh full regression suite or complete compiler/Lean
run is claimed; original failed runs remain failed.

| Round | Selected model / effort | Result and rework | Available timing |
| --- | --- | --- | --- |
| LCM/Coprimes implementation | GPT-6.1 Sol / Extra High | Two callable sources, complete-domain Euclidean/sign argument and independent outputs; both admitted | Agent elapsed/token/cost measurements unavailable |
| Sum/Tau implementation | GPT-6.1 Sol / Extra High | Two callable sources covering all 100 inputs, nontruncating guard arguments and prime-factorization output derivation | Agent elapsed/token/cost measurements unavailable |
| Integration and application validation | Lead runtime model/effort not independently exposed | Four manifest entries; every production application check passed on the first run | Managed native interval 66.336 s; whole-team elapsed unavailable |
| Evidence retention | GPT-6.1 Sol / Extra High | Original reports/logs and derivation notes retained separately from production inputs | Agent elapsed/token/cost measurements unavailable |
| Independent task/evidence review | GPT-6 Astra / Max | Accepted `5262fb81fa`: full-domain algorithms/guards, task fidelity, exact output and evidence applicability; no material finding, one inherited status sentence corrected | Total review elapsed/token/cost measurements unavailable |

No language mechanism or resource budget changed. The first two groups now
provide eight validated programs; #344's four digit/prime programs remain
unstarted. #345 retains the combined checkpoint and narrow Rosetta assessment
and render, so the rendered Stage-1 total remains 71. The #343 implementation
merge remains held for the owner's later decision; milestone 21 remains open.

## Increments and ownership

The [roadmap](../roadmap.md#scalar-function-rosetta-batch) records order:
callable examples first; divisor and digit/prime groups can then proceed
independently; shared delivery follows all three. All issues are in milestone 21.

| Issue | Scope | Completion evidence |
| --- | --- | --- |
| [#342 — Callable integer examples](https://github.com/berkeleynerd/silver/issues/342) | Factorial, Fibonacci, signum, Sum multiples | Four faithful programs, independent expected outputs, focused application checks and task review |
| [#343 — GCD and divisor calculations](https://github.com/berkeleynerd/silver/issues/343) | LCM, Coprimes, Sum of divisors, Tau | Four programs covering all required inputs, justified loop/accumulator bounds and focused checks |
| [#344 — Digit and prime algorithms](https://github.com/berkeleynerd/silver/issues/344) | Sum digits, Happy, Additive primes, Attractive numbers | Four programs with complete required searches, finite-loop arguments and focused checks |
| [#345 — Combined delivery](https://github.com/berkeleynerd/silver/issues/345) | Evidence applicability, final tests, assessment/render, records and review | Complete combined assurance/application evidence, actual coverage accounting and a reviewable PR |

At implementation, each sample stream owns its new sources and proposed manifest
cases in a separate worktree. The delivery stream integrates the shared manifest,
assessment metadata and rendered tree. Use existing managed workspace/worker
coordination. Issues track implementation, focused verification, review and final
evidence applicability; a partial group does not complete the milestone.

## Primary task requirements and proposed domains

The cached manifest was retrieved 2026-10-15. The revisions below identify the
primary `task.wiki` descriptions read for this plan, not the later delivery date.
The table retains the bounded planning designs; the first eight now have the
implementation evidence above. The remaining designs still need validation.
Wider domains from legacy assessments are not promises.

| Task and captured revision | Required behavior and meaningful cases | Proposed bounded design |
| --- | --- | --- |
| [Factorial](../rosetta/f/factorial/task.wiki), 415532 | A function returning factorial; `0! = 1`. No required demonstration range; negative-error handling is optional. | Argument 0..12, the nonnegative factorial domain fitting the pinned signed 32-bit Integer. Counted multiplication; include 0, 1 and 12. |
| [Fibonacci sequence](../rosetta/f/fibonacci-sequence/task.wiki), 415533 | A function generating the nth value, with F0=0 and F1=1. Negative indices are optional. | Argument 0..46, whose results fit Integer. Handle zero separately and iterate 2..N so no unused F47 is computed. Include 0, 1, 2, 10 and 46. |
| [Sign of an integer (signum)](../rosetta/s/sign-of-an-integer-signum/task.wiki), 413025 | A function returning -1, 0 or 1; examples -10, 42 and 0. Signed-zero preservation applies only to representations with signed zero. | Full Integer formal and result subtype -1..1; conditional assignments and one terminal return. Include both Integer endpoints. |
| [Sum multiples of 3 and 5](../rosetta/s/sum-multiples-of-3-and-5/task.wiki), 413418 | A function summing positive multiples of 3 or 5 below n; required n=1000 gives 233168. Efficient n at least 10^20 is extra credit. | Argument 0..1000, zero handled explicitly; bounded arithmetic-series formulas for steps 3, 5 and 15, avoiding double counting. Include small overlap cases. |
| [Least common multiple](../rosetta/l/least-common-multiple/task.wiki), 412881 | Integer inputs; zero in either position gives zero. Page example 12 and 18 gives 36. | Inputs -1000..1000, sign normalization, counted-loop GCD and a positive-GCD guard; product at most 1,000,000. Include signs and both zero positions. |
| [Coprimes](../rosetta/c/coprimes/task.wiki), 406144 | All five pairs (21,15), (17,23), (36,12), (18,29), (60,15), yielding false, true, false, true, false. | Boolean helper assigns an earlier GCD call to a local, then tests whether it is 1. Main prints every specified case. |
| [Sum of divisors](../rosetta/s/sum-of-divisors/task.wiki), 404133 | Positive divisor sums for every integer 1..100. No required column arrangement. | Function domain 1..100; divisor loop 1..N. A 0..5050 accumulator and static addition guard use the sum of 1..100 as a conservative bound. |
| [Tau function](../rosetta/t/tau-function/task.wiki), 413079 | Positive divisor counts for every integer 1..100. No required ten-column format. | Function domain 1..100; divisor loop and counter 0..100 with a static increment guard. |
| [Sum digits of an integer](../rosetta/s/sum-digits-of-an-integer/task.wiki), 413075 | Natural input and a given base. Include (1,10)=1, (1234,10)=10, (16#FE#,16)=29 and (16#F0E#,16)=29. | Natural Integer input, base 2..36 and 31 extraction steps; result bound 0..1085. Retain the base-16 examples and include zero and base boundaries. |
| [Happy numbers](../rosetta/h/happy-numbers/task.wiki), 415022 | Print the first eight: 1, 7, 10, 13, 19, 23, 28 and 31. | Digit-square helper on 0..999 returns 0..243; a justified 244-step finite-state test and Main scan 1..31. Include unhappy controls. |
| [Additive primes](../rosetta/a/additive-primes/task.wiki), 411689 | All additive primes below 500; both the number and its decimal digit sum are prime. Printing the count is optional. | Scan 2..499, assigning primality and digit-sum calls to locals before testing. No array capture or sieve is required by this task. |
| [Attractive numbers](../rosetta/a/attractive-numbers/task.wiki), 413644 | All qualifying numbers through 120, counting prime factors with multiplicity; 20 has three. | Factor loop 2..120 with seven divide-out attempts per factor. At most six successful divisions are possible for a positive value at most 120. Test the returned count for primality. |

Some cached tasks are marked drafts (Coprimes and Sum of divisors); their captured
requirements are still explicit. Recheck any later primary-task revision before
changing the selected delivery scope. No optional extension is silently made
mandatory, and no mandatory input is relabelled optional.

## Shared design constraints and unresolved checks

Follow the [selected function grammar](scalar-functions.md#selected-grammar-and-mechanism--2026-11-07):
Integer/Boolean formals and results, earlier-only calls, closed bodies, initialized
scalar locals, counted loops and one terminal return. Locals start with
literal/static initialization, then body assignments may read formals. Every
function checks its full formal-domain product, including unused functions.
No procedures, out parameters, captured Main values, array/String signatures,
I/O in helpers, recursion, while loops or early return are introduced.

Calls are separate scalar assignment statements. A call in an initializer,
arithmetic expression, guard, actual argument or return expression would exceed
this fragment. Choose declared result ranges that callers can use: call results
export their declared bounds, not correlations with particular argument values.

Current scalar refinement needs a bare scalar compared with a static singleton.
The legacy guards `R <= Max / I` and `A <= Max - B` do not supply the needed
refinement when their thresholds vary. Proposed alternatives are static:

- Factorial can guard an accumulator at 39,916,800 before multiplying by an
  index at most 12, producing at most 479,001,600. All true preceding factorials
  in the chosen domain satisfy that threshold.
- Fibonacci can guard its preceding terms at 701,408,733 and 1,134,903,170;
  their sum is 1,836,311,903. Correct loop orientation avoids an extra F47 step.
- Digit sums use at most 31 digits, each at most 35. Before each addition the
  coarse partial sum is at most 1,050, so a static guard preserves every input.
- Happy-number iteration enters the 244 states 0..243 after one transformation;
  1 is absorbing. A repeated non-1 state cannot first reach 1 later. Retain the
  complete finite-state/bound argument and independently check the eight outputs.

These bounds are mathematical design checks, not successful Silver compilations.
Guarded updates must preserve the requested result throughout each declared
domain; safety alone or a silently skipped update is insufficient. Prove or
independently justify counted-loop sufficiency and absence of truncation in task
review. Source fit, all operator accounting, exact admitted guard shapes, output
format and runtime remain implementation checks. If a faithful candidate does
not fit, record its reason and revise the proposed scope instead of adding
unselected language/capacity work.

## Validation and expected reuse

| Inputs/work | Required evidence |
| --- | --- |
| Unchanged compiler, runtime, proof and audit tooling from accepted #298 | Check actual input applicability, retained native/Lean/source outcomes and every required fresh audit. Reuse matching successful proof work under the existing policy. |
| Each new sample and its cases | Normal admission, complete required application/library proof audit, build and execution with independently derived exact output/status; meaningful boundary and negative controls. |
| Shared manifest, assessment and rendered metadata | Final manifest and affected integration/Rosetta checks, exact task-fidelity review, preserved assessment provenance and inspected render diff. |
| Any changed compiler, proof or auditor input | Reassess scope and use the existing invalidation matrix; complete all affected assurance. Expected reuse never exempts a required check. |

Use [focused helper verification](../development.md#proof-loop-and-validation)
during implementation and one shared final checkpoint on the integrated batch.
Batch the sample checks and preserve applicable successful results under the
ordinary reuse rules. No complete compiler source-certificate rebuild is planned
solely for adding samples; this is conditional on inputs and assurance remaining
applicable, not a guaranteed speedup. Application proofs are still required.

Independent review checks primary-task fidelity, loop/domain arguments, exact
outputs, final evidence applicability and the integrated assessment changes.
Critical proof/correspondence diagnosis or review uses Astra Max. Established
sample implementation follows the ordinary role policy. No new runner, metrics
database, proof bypass or approval ceremony is part of this plan.

## Coverage, tracking and delivery

At planning snapshot `8eec12216a`, the rendered Stage 1 has 70 task mappings.
#298 subsequently delivered Primality, establishing a merged baseline of 71.
None of these twelve candidates is currently in Stage 1: legacy assessments
place them in stages 6, 7, 8 or 13 because their older approaches request extra
surface. A revised implementation and reviewed assessment are required before
any promotion. The batch's upper bound is twelve additional task mappings, not
a claimed gain or guaranteed final total.

Reconcile only demonstrated tasks, preserve earlier review provenance, render
once after the final metadata integration and update affected stage fields.
Do not promote broad functions/procedures or create a language-stage issue for
this sample-only batch. Existing supported identifiers come from completed
language delivery. Keep programs, manifest execution cases and new task mappings
as separate counts; recount against the accepted baseline.

#345 records actual coverage gained, elapsed delivery time (with pauses
distinguished) and expensive checkpoint attempts, including failed/interrupted
attempts and repair causes. Link existing run evidence rather than adding a
metrics subsystem. Finish the capability, roadmap, session-memory and issue
handoffs and publish the reviewed delivery. Issues close only when their complete
criteria reach main through the applicable authorized merge.

## Planning evidence

The lead read current project policy, roadmap, #298 and #300, the complete open
milestone list and open decision issues. A bounded GPT-6.1 Sol / Extra High
subthread read all twelve primary task pages, their manifest revisions, rendered
assessment stages and #298's grammar; the lead reviewed the extracted requirements
and bounds. A separate Astra / Max reviewer inspected the planning content
recorded at `9113e2e230`, the primary tasks, grammar, reference samples and
tracking issues. It found no material planning correction: task requirements,
proposed mathematical bounds, narrow function use and provisional authorization
were preserved. Admission, source/operator fit and application proof remain
unvalidated. Selected settings are recorded; live runtime confirmation and
token/cost measurements were unavailable.

Cheap arithmetic checks confirmed the factorial/Fibonacci limits, digit and
factor-step ceilings, required sum 233168, divisor-sum ceiling 5050 and the first
eight happy numbers. These checks validate the planning arithmetic only.

This planning pass ran no Silver admission, build, proof, sample execution or
Rosetta render and changed no supported-assessment metadata. At the initial
planning checkpoint, delivery agents retained ownership of #298's workspaces
and validation. The planning branch is `plan/coherent-batches-20261108`,
originally based on `8eec12216a` and published in
[PR #346](https://github.com/berkeleynerd/silver/pull/346), stacked on PR #339.
After #339 merged, PR #346 was retargeted to main and its documentation
reconciled with the completed delivery. At that planning publication, all four
issues remained Backlog in milestone 21; the later #342 selection is recorded
above. Local document links and whitespace passed; later planning edits record
review, publication, delivery status and merge authorization only. The reviewed
proposal is unchanged. CLI recall was not updated.
