# Fixed-array semantic and source integration review

Date: 2026-10-27. Target: `726465447c11d8826164fdca343d71178dc53fdf`,
issue #260, in the `tmp/fixed-integer-arrays` worktree.
Independent reviewer selected GPT-6 Astra / Extra High (`gpt-6-astra`, `xhigh`),
confirmed by the lead's spawn configuration. Runtime-confirmed settings and
token/cost measurements are unavailable. Read-only review, approximately five
minutes; the recorded inspection interval was 11:33:07–11:37:28 UTC (4m21s),
with initial guidance reads before the first clock sample and report preparation
after the last. No builds, proof runs, tests, agents, or GitHub writes were used.
Only this proposed report and its input manifest were written, under `/tmp`.

## Result

No new consequential mathematical or source-correspondence integration finding
in the inspected chain. No counterexample was identified for lost initializer
obligations, overlapping admitted storage identities, snapshot corruption,
loop mutation, or a strengthened caller domain unsupported by the native contract.
This is a semantic integration review, not the complete assurance checkpoint.

## Challenged links

- Array storage and mutability: `ArrayBindings.lean:105` distinguishes native
  validity from source allocation readiness; `covers_scalar` at line 191 reserves
  low identities independently of descriptor overlap assumptions. Ordered source
  declarations supply disjoint segments and `ArrayBindingsOrdered.lean:35`
  supplies the target's component mutability. The assignment checker requires
  full target ranges in both current and declared states, so a write cannot
  preserve an unsound narrower element fact.
- Caller domains: `ComposeArrayEquations.lean:28` interprets raw aggregate
  recursion with both caller contexts; `:154` derives declaration behavior from
  typed bodies and helper equations. It supplies capacity, cursor, value,
  descriptor and initialized-extent premises at actual calls. Successful aggregate
  results recover the caller context through scalar-field preservation; rejection
  does not transport arbitrary caller facts. This agrees with native helper
  preconditions at `silver_output_profile.adb:959`, `:965` and `:1025` and the
  #262 repair described in the prior domain review. SourceReady/canonical tables
  are not substituted for native helper domains.
- Initializer meaning and obligations: `ComposeArrayStore.lean:63` relates the
  raw aggregate execution to the resulting table. `ComposeInitializerTrace.lean:49`
  retains raw scalar initializers before array freezing; String/Image checks and
  array bounds, singleton choice, component and length/index checks also enter
  the initializer trace (`ComposeArrayChecks.lean:64`). The final parsed header
  retains both the array environment and this inventory in
  `PredicateGrammar.lean:169`, `:179`, and `:206`; `PredicateChecks.lean:69`
  carries the initializer schemas into current-language obligations.
- Loop identities and execution: `PredicateHeaderFlow.lean:136` supplies array
  readiness from the parsed header. `PredicateLoopProperties.lean:58` derives
  room for the new scalar identity, and `PredicateBodyMeaning.lean:253` consumes
  that bound while entering each loop. Generic Nat identities are not silently
  assumed below the array base. `PredicateExecution.lean:74` computes iteration
  values from the entry store, then threads each iteration's updated Integer
  store and restores only the scoped index. Thus later array writes do not alter
  captured bounds; empty iteration lists preserve the store. Read-only snapshots
  use the same mutability-preservation argument
  (`PredicateComposition.lean:191`).
- Native body and source connection: indexed target/assignment trees match the
  inspected native helpers at `silver_output_profile.adb:3029` and `:3044`.
  `PredicateArrayBodySource` connects the scalar-only subscript reader, array-aware
  RHS reader, actual flow overlay, array helper equations and body wrapper.
  `ScalarExpressionSourceBridge.lean:113` includes the array helper source bridge.
  `PredicateSourceChecks.lean:21` requires authoritative complete-shape equality
  before candidate checks; the array helpers are included in those checks.
  The final source interface uses `OuterReadiness.domain`, and `Current` consumes
  the parsed Predicate meaning/obligation chain. The inspected integration does
  not replace exact source reconstruction with a pin equality.

## Exact inputs and limits

The 45 primary source/proof inputs listed in the
[companion manifest](review-fixed-arrays-integration-726465447c-inputs.sha256)
were checked byte-equal to the target commit after inspection.
The native output-profile SHA-256 is
`446ac3f3e668096e5cdda361bfa21bbc7dac747ea637659de2cae951d767d794`.
The review read AGENTS.md, the Oracle, the array capability record, the relevant
language and assurance material, and the previous Compose domain/snapshot review
including its #262 follow-up. Supporting source adapters and selected changes
from baseline `7acddbcc0f4e7e1aec567f496539f956864ed294` were inspected as needed.
The manifest identifies primary inspected interfaces, not a claim of line-by-line
review of every transitive module or generated certificate.

Concurrent uncommitted proof-script repairs in `ComposeModelLegal.lean` and
`ComposeModelEquations.lean`, and documentation edits, are outside this target;
the lead reported no statement, core-definition or native-source changes.
Known pending compilation/validation work, including complete native proof,
exact-byte source certificates, Predicate/source candidates and the full
module/axiom audit, remains a completion obligation rather than a new review
finding. This review neither reran those checks nor inferred success from pending
runs. Report capacity and native/specification admission already received separate
scoped reviews and were not re-reviewed here. The documented external frontend,
producer and solver premises remain in the assurance claim.
