# Boolean proof and source-correspondence review

Read-only independent review for #291. Selected reviewer: GPT-6 Astra / Extra
High, confirmed by the lead's explicit spawn controls. Runtime confirmation and
token/cost measurements unavailable. Interval: 2026-10-30 12:55:52–13:00:56 UTC
(5m4s). No builds, proofs, tests, repository edits or artifact mutations.

Reviewed `5ffdf80d060d65cf069e29082c8bed09de8eb330` against parent
`fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. Initial uncommitted integration was
incorporated into that commit; the final inspection found no tracked changes.
Untracked scratch was untouched. Governing inputs were `AGENTS.md`, `oracle.md`
and the relevant assurance, trusted-boundary and Boolean capability sections.

## Result and examined argument

No new finding in the assigned proof/source-correspondence scope. This is an
argument review, not a complete validation checkpoint; #293/#294 remain open.

- `ComposeSourceBridge.lean:68–133` retains raw helper equations, Boolean
  imports, native predicate definitions/contracts and callee links. It derives
  the declaration law through `ComposeBooleanDeclarationLibraries.imports_meaning`;
  scanner equivalence is not an input premise.
- `ComposeBooleanDeclarationDomain.lean:50–71` establishes context/flow validity
  after the declaration guard. `ComposeBooleanDeclarationCondition.lean:15–40`
  supplies cursor validity, full initializer storage and output-count equality
  before applying the worker contract and predicate uniqueness theorem.
- `PredicateNativeHelpers.lean:326–389`, `PredicateNativeWorkers.lean` and
  `PredicateFlowReaderLibraries.lean:48–76` retain arbitrary valid `Initials`,
  incoming flow and original position. No allocated-prefix assumption replaces
  the full native initializer-array domain. Corrected mutable-flow containment
  uses declared bounds, including during elaboration.
- `PredicateBooleanBodyHelpers`, `PredicateBooleanBodyLibraries` and
  `PredicateBasicLibraries.lean:107–118` connect typed assignment equations and
  executable Static refinement to predicate interpretation. Successful Boolean
  assignment preserves incoming facts and existing scan effects, sets the
  assignment flag and advances the cursor.
- Declaration and assignment trees have scope, precedence and denotation checks.
  Predicate trees cover added chain constructors, named arguments, Boolean
  helpers and the constant node. `PredicateNativeSourceChecks.lean:150–185` and
  `PredicateFlowReaders.lean:233–239` require the relevant constant declarations
  and rendered definitions. `PredicateSourceChecks.lean:15–31` transports the
  reviewed requirements to authoritative tokens through complete-source equality.

The inspected inputs included the `ComposeBooleanDeclaration*` family; Compose
root bridge/checks/candidate and raw-equation assembly; predicate native
expressions, bodies, precedence, equations, contracts, workers, helpers,
libraries and source checks; flow readers; Boolean body/Basic integration;
readiness/flow invariants; retained Sequence-context repair; and corresponding
Ada sections. The complete authoritative-source check remains pending, including
the disclosed native constant repair and source-shape refresh. No separate
defect was found in their prepared proof-side requirements. Review conclusions
must not be read as successful kernel execution of those pending checks.
