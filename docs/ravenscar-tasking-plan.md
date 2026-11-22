# Bounded Ravenscar tasking — priority plan, 2026-11-22

## Selection and scope

**Implementation selected, 2026-11-22.** Following PR #412's merge, the owner
authorized #416 and the upfront #421 feasibility check, with relevant Rosetta
samples delivered alongside each new feature. The
[dated authorization](session-memory.md#2026-11-22--bounded-packages-and-ravenscar-feasibility-authorized)
supersedes the earlier planning-only status for this first increment. The other
implementation issues retain their planned order and Backlog status. The runtime
check does not complete #421's later integrated-assurance scope.

The earlier planning selection established the near-term roadmap order: the five language foundations
below and Ravenscar profile support, followed immediately by a reassessment of
Jorvik. This replaces waiting for the entire natural language surface or generic
Rosetta progression before considering concurrency. It authorizes planning and
priority, not feature implementation, PR #412's merge or an Oracle amendment.

The named-array review response and validation are complete in merged PR #412.
[Milestone 28](https://github.com/berkeleynerd/silver/milestone/28) is now the active
delivery sequence; bounded library packages are its first selected increment.
The milestone describes one small useful Ravenscar-compatible fragment, not all
Ada tasking, every profile-permitted construct or a new task scheduler/runtime.

## Ordered increments and completion boundaries

| Order | Issue | Included outcome and assurance boundary |
| --- | --- | --- |
| 1 | [#416 — Library packages and application units](https://github.com/berkeleynerd/silver/issues/416) | A bounded static package specification/body and Main, ordered visibility, initialized library state and nonrecursive package subprograms. Establish the complete dependency/elaboration model, exact author-unit closure and unit/entity audit coverage. |
| 2 | [#417 — Protected state and operations](https://github.com/berkeleynerd/silver/issues/417) | Library-level protected objects with initialized private Integer/Boolean state and nonblocking procedures/functions. Derive ownership, shared access, preserved state and allowed call effects, with priority-ceiling rules. |
| 3 | [#418 — Static tasks and persistent loops](https://github.com/berkeleynerd/silver/issues/418) | A finite static set of library-level task objects/bodies, activated after elaboration, with restricted loops whose end is unreachable. Establish concurrent step/finite-prefix safety while retaining existing finite-program guarantees. |
| 4 | [#419 — Protected entries and barriers](https://github.com/berkeleynerd/silver/issues/419) | A simple Boolean-barrier entry per selected object, with at most one distinct caller task, including indirect calls and Main. Cover waiting/runnable states, queue bounds and protected-action blocking/locking rules. |
| 5 | [#420 — Clock and absolute delay](https://github.com/berkeleynerd/silver/issues/420) | Selected real-time clock, Time/Time_Span arithmetic and `delay until` for periodic workers. Cover full-domain time arithmetic and horizon exhaustion with executable behavior and explicit environmental assumptions. |
| Integration across 1–5 | [#421 — Ravenscar profile and complete assurance](https://github.com/berkeleynerd/silver/issues/421) | Establish the pinned profile/runtime recipe at the start, before protected/task code needs it; close the combined delivery with complete current-input native/Lean/source assurance, regression coverage and independent review. |
| Immediately afterward | [#422 — Reassess Jorvik](https://github.com/berkeleynerd/silver/issues/422) | Use delivered Ravenscar experience and real examples to decide whether richer barriers, additional entries/waiters or relative delay justify the next increment. This selects an assessment, not automatic Jorvik implementation. |

The real-time branch serves periodic behavior; basic event-driven synchronization
does not depend on clock support. The ordering remains the owner's near-term
priority. Focused development may overlap separable work within the host's shared
allocation, but dependencies and complete assurance remain explicit. These issues
are reviewable increments, not five separate mandatory cold proof cycles or a
license to label incomplete tasking supported. Reuse matching evidence under the
existing [development workflow](../development.md#proof-loop-and-validation),
with a shared final checkpoint for the selected combined capability.

## Concrete drivers and boundaries

Use a small package-based bounded counter to establish the unit/state foundation,
then a protected scalar mailbox shared by a fixed producer and consumer. The
integrated driver adds a periodic release through the admitted clock/delay
operations. It exercises initialization before activation, private shared state,
an entry barrier and safe arithmetic; task bodies intentionally persist.
Use bounded observation in the test harness without pretending that an externally
stopped task completed normally.

Rosetta **Events** is a candidate for the later faithful task assessment.
**Active object** and other concurrency tasks are research inputs, not promised
gains: they may need additional numeric operations, interfaces or observable
behavior outside this fragment. Existing assessments disagree about the profile
pragma boundary; resolve those exact entries when making support claims.
Do not promote `tasking`, clock or delay identifiers merely because this plan
exists. Add precise supported identifiers and re-render only at validated delivery.

At each increment, assess and deliver the relevant Rosetta samples its new forms
unlock, as requested by the owner. For packages, assess module/interface and
package-state tasks before choosing the driver; preserve each task's actual
requirements. Name the concrete candidates and exclusions in the capability
record rather than promising that the broad package identifier is supported.

The first fragment needs no general records, enumerations, generics, heap,
dynamic task creation, task arrays, arbitrary `while` loops, task rendezvous,
interrupt handling or multicore scheduling. Static priority defaults or a narrow
declaration-aspect form are part of #417/#421. One target CPU is a reasonable
initial restriction; it is separate from the development host's eight-CPU proof
worker budget. All omissions need their scope purpose stated in the eventual
language rules, rather than being attributed to Ada when they are Silver choices.

## Oracle compatibility and proof work

The [Oracle](../oracle.md) remains unchanged. Application authors supply no
contracts, invariants, flow annotations or other extra assurance facts. Admission
must stay decidable before invoking a prover. Derive state ownership, call/effect
sets, callers of entries, initialization and required arithmetic/ceiling facts
from the admitted source and selected library contracts, and cover all permitted
inputs, interleavings and compositions. A successful example or the absence of
observed races is not the universal argument.

The pinned [SPARK concurrency guide](../references/spark/16.1/docs/ug/en/source/concurrency.rst)
expressly allows `Profile (Ravenscar)` and
`Partition_Elaboration_Policy (Sequential)` in a configuration pragma file.
Use one compiler-owned configuration consistently for proof, compilation and
binding; retain all original application units. This preserves the sole permitted
source pragma, `SPARK_Mode (On)`, without hidden annotated replacements. Selecting
configuration outside author source is a concrete implementation route, not
permission to add assumptions or suppress required checks.

SPARK's [tasking rules](../references/spark/16.1/docs/lrm/source/tasks-and-synchronization.rst)
require an unreachable task-body end for both profiles. The current finite
effect-list/completed-result model must therefore be extended to persistent
executions, including reachable blocked states. Keep the existing completion
claims for the existing finite programs. Verification must finish automatically;
that does not imply that a service task must terminate. Safety, bounded queue
storage, locking requirements, scheduler fairness and deadline satisfaction are
different properties. State precisely which are established and which runtime or
environmental assumptions apply; Bronze/Silver discharge alone is not a hard
real-time schedulability result.

Protected operations must preserve their state for every permitted caller.
Do not carry a fact observed before a protected call across an intervening task
as if the execution were sequential. Infer complete potential call chains for
data-sharing, blocking, cyclic-locking and priority-ceiling checks. Keep task
output under explicit ownership or outside the initial fragment: existing output
contracts assume no simultaneous writer and do not automatically become safe for
all tasks merely because a protected mailbox exists.

For time, specify the admitted predefined operations and their actual contracts
and effects. Repeated `Next := Next + Period` requires an explicit full-domain
argument at the finite Time limit. Do not silently presume an unbounded clock,
weaken input domains or add author proof annotations to discharge this case.

## Feasibility and validation plan

At the start of #421, confirm the pinned GNAT/SPARK runtime and configuration
support on the selected Linux target using the smallest faithful package/task
example. Inspect actual task/protected/clock obligations and report entities
before designing their admission and proof rules. Existing GNAT/OS runtime
components keep documented trusted-boundary status; new Silver-owned wrappers,
if necessary, remain SPARK with complete required native verification.

Define bounded program-unit count, dependency depth, total source, initialized
state, task stacks, queues and report capacity for the chosen forms. Preserve a
small explicit total-program bound initially where adequate; multiple units do
not grant an unchecked multiplication of the current 4,096-byte allowance.
This does not reopen the deferred broad unbounded-programs work by default.

Before an expensive integrated checkpoint, require focused success for every new
or changed helper's complete contract, native caller/callee coverage and relevant
Lean targets. At the stable combined checkpoint, complete native verification,
Lean source/semantic/discharge and module/axiom audits, the affected regression
and sample coverage, and independent critical proof review. Use the ordinary
cache/applicability rules, with no new mandatory cold build, second proof kernel
or scheduling framework. Generalize audit coverage to every source-selected unit,
task and protected operation; an old Main-only report policy is insufficient.

Record Linux evidence and exact runtime assumptions; macOS remains independent
and nonblocking under the Oracle. Update specification, catalogue, compiler,
proofs, samples, roadmap and capability/support records together at delivery.
Then carry actual proof cost, limitations and unmet example needs into #422.
The [Ada 2022 profile definitions](../references/ada/2022/RM-D-13.html) and pinned
SPARK guide are the basis for that reassessment, not a presumption that every
Jorvik relaxation should be admitted.
