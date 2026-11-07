# Small nonrecursive scalar functions

**Owner-selected work, 2026-11-07; design and implementation pending.** Existing
[#298](https://github.com/berkeleynerd/silver/issues/298), in
[milestone 20](https://github.com/berkeleynerd/silver/milestone/20), **Small
nonrecursive functions**, is one cohesive work package. The
[dated authorization](session-memory.md#2026-11-07--small-nonrecursive-functions-selected)
records the owner's **“Proceed”** after the recommendation to start with Integer
and Boolean scalar parameters/results, acyclic calls and no caller-visible
mutation. The current [language](../language.md) and
[catalogue](../catalogue/silver.json) still exclude user-defined functions.
This plan admits no syntax and records no completed function assurance.

Routine planning publication and merge, followed by implementation through
reviewable publication, are authorized. Implementation merge remains a later
owner decision. No next feature is selected. The completed sample expansion
[#300](https://github.com/berkeleynerd/silver/issues/300) merged through
[PR #337](https://github.com/berkeleynerd/silver/pull/337); it is not an outstanding
dependency of this work.

## Bounded capability and first driver

Admit small user-defined nonrecursive functions with Integer/Boolean scalar
parameters and results, an explicitly decidable acyclic call discipline, and
no caller-visible mutation. Reuse existing scalar bounds, Boolean expressions,
guards, declaration visibility and finite control flow wherever their current
rules suffice. Specify the exact admitted declaration, call and return forms
during the native/Lean design, before representing any form as supported.
The selected scope does not preselect a final grammar or a proof mechanism.

The first driver is a Boolean `Is_Prime` function for
[Primality by trial division](../rosetta/p/primality-by-trial-division/task.wiki).
The task explicitly asks for a Boolean function; an inline calculation in Main
does not fulfill it. Use trial division and a bounded declared input domain
including negative values, zero, 1, primes and composites. Return nonprime for
1 and all non-positive inputs, and include independent expected results for
boundary, prime and composite cases. Bounded existing
Integer/loop/division machinery should suffice; the task permits loops other
than a square-root loop. Do not import the old assessment's anticipated while
loops, extra procedures or other unadmitted constructs merely to match its
sketch. A faithful bounded implementation and reviewed assessment determine
any coverage change. GCD and numeric search helpers remain candidate uses, not
additional promised sample deliveries.

Recursion, `out`/`in out` parameters, array or String signatures, general
procedure/package admission, generics and capacity rewrites are outside this
package. The Oracle and the existing trusted-tool boundary remain unchanged.
Local implementation state may be considered within the selected no-mutation
boundary; its exact permitted forms and observable effects must be explicit.

## Design decisions to settle within #298

These are ordinary bounded design work, not additional owner approval gates:

- Choose ordinary Ada/SPARK declaration placement and declaration ordering;
  settle parameter grouping, explicit or implicit `in`, named subtype marks,
  result marks, zero-parameter forms, and positional/named call associations.
  Specify what is admitted and reject adjacent unsupported forms. No overloading,
  forward declaration, default argument or extra nesting form is implied by
  this list.
- Specify scope, hiding and uniqueness for function names, formals, local
  objects and existing loop binders. Determine permitted references to enclosing
  declarations and earlier functions. Make the no-caller-visible-mutation rule
  structural and account for all observable library effects, including output,
  input acquisition and rejection; a scalar result alone does not establish
  absence of effects.
- Define the accepted body/control-flow and return forms, including total
  return coverage, early returns if admitted, unreachable arms and static Ada
  legality. Establish function and call-chain termination from the accepted
  acyclic calls and existing finite constructs. Detect direct and indirect
  recursion by explicit membership rules, independently of prover outcomes.
- Define typed actual/formal binding, formal input domains, parameter subtype
  checks, result subtype checks and caller consumption. Derive all range,
  overflow, divisor and other safety facts from declarations and executable
  control flow. Settle how a caller's interval/Boolean facts and a callee's
  source-derived result facts compose without assuming unstated contracts or
  inheriting unrelated caller-local facts.
- Specify function calls in each admitted expression position, nested calls,
  repeated calls, short-circuit evaluation, return expressions and local
  initialization/assignment. Preserve Ada evaluation meaning. A native
  feasibility probe must expose actual application-unit report entities,
  obligation classes and producer elimination before report handling is chosen.
- Account for source-derived function/formal/local storage, call depth and
  repeated-call proof/report growth under the existing budgets. Preserve the
  4,096-byte complete-source bound, 64-leaf expression policy, shared 63-operator
  budget and current source-derived scalar/String/array storage limits. Explain
  how calls and their arguments fit those policies. Do not silently reset a
  source-wide budget per function or multiply tables per call. Any newly needed
  bounded representation must have a documented source-derived capacity
  argument; a general capacity rewrite stays deferred.

Record the chosen native rules, Lean representation and their correspondence
together here and in the authoritative language/catalogue changes. If design
shows that a split is necessary, create its increment issues and record their
order/completion criteria in the same planning step under
[planning](planning.md); a partial result does not complete #298.

## Required assurance chain

The [Oracle](../oracle.md) applies to the entire resulting language and every
permitted composition. Program authors write actual Ada/SPARK and no contracts,
preconditions, postconditions, invariants or proof annotations; the sole
permitted program pragma remains `pragma SPARK_Mode (On);`. Safety must hold
throughout the full call chain for every permitted input and execution path.
Compiler-derived facts must follow from the admitted source and verified
operations, never developer-supplied assurance facts.

Extend decidable membership, typed evaluation, scope/state handling, call/return
composition, universal safety, termination and automatic-discharge arguments.
The result must establish automatic discharge of every required Bronze and
Silver obligation for every admitted program, not merely semantic safety or
successful driver examples. Unknown report entities, new obligation classes or
unclassified diagnostics cannot be accepted as a shortcut. Any new class needs
its semantic/discharge schema and complete producer/provenance account.

Verify all changed Silver-owned SPARK implementation to Bronze and Silver.
Extend the Lean proofs over the actual authoritative compiler/library source,
including source-tree structure and semantic equations affected by function
parsing, binding, analysis and report selection. Review source pins with the
source and semantic changes. A separately correct call model or refreshed pin
does not establish actual-source correspondence. Author source admitted,
proved and compiled must remain byte-identical; hidden annotated replacements,
source rewriting to ease proof and narrowed input domains are forbidden.
Keep [assurance claims](assurance.md) and
[trusted assumptions](trusted-boundary.md) precise.

## Validation and completion criteria

Use focused native probes and Lean targets while settling the mechanism, then
complete the native Bronze/Silver, ordinary build, complete Lean/actual-source
and fresh module/axiom audit checkpoint on stable implementation inputs. Read
the managed-run summary first, retain successful matching evidence, and record
the input/configuration comparison that makes reuse applicable. Follow the
[proof-iteration workflow](proof-iteration.md), actual workspace/worker
reservations and documented CPU/memory settings; avoid identical-success
expensive reruns without a stated reason. Linux evidence is primary; independent
macOS validation remains nonblocking. No native, Lean or sample result is claimed
by this planning record.

Exercise the driver through admission, proof, build and execution with independent
expected results. Cover type/domain boundaries, scope and hiding, returns and
rejected missing returns, direct/indirect recursion rejection, call compositions,
no-mutation/effect restrictions, dead code and interactions with the existing
scalar, guard, loop and array language as applicable. Include source/storage and
report-capacity boundary evidence for the chosen rules. Complete proportionate
regression validation, identifying fresh runs and retained applicable results
separately; samples do not replace the universal assurance argument.

At delivery, update `language.md`, the catalogue, samples, roadmap capability
status and this record together. Reconcile the precise Rosetta construct
identifier/assessments with the delivered fragment, update the assessor's
current-language description, render the progression and reconcile affected
stage issues under [Rosetta progression](planning.md#rosetta-progression).
Do not promote broad functions/procedures or promise coverage totals ahead of
that review. Publish the reviewable implementation and evidence for independent
review; retain #298's open status until the complete package and later authorized
merge close it.

## Planning settings

Documentation preparation selected GPT-6.1 Sol / High; independent runtime
confirmation, token/cost measurements and elapsed-work measurements are
unavailable. This planning subthread performs no proof/build/test/render run,
GitHub mutation, staging, commit or publication. The lead integrates and
publishes the bounded plan before implementation.
