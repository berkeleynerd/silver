# Review: scalar guard semantics and composition

2026-10-26. Independent bounded critical review; selected GPT-6 Astra at Extra
High, as assigned. Runtime model/effort are not independently exposed. Inspection
interval: 04:21:27–04:23:36 UTC (2 minutes 9 seconds); report writing and the
final input-state check completed at 04:24:30 UTC (3 minutes 3 seconds total).
Token and cost measurements are unavailable.

Exact review target: `0655fa76beffc2126c3441471d292d5eaafb8d44` in
`tmp/scalar-guard-refinement`. Comparison base: `origin/main` at
`a5305f1b04741302d589d881f2e3cc243d7d65d0`. Both the initial and subsequent
inspection checks found that exact HEAD and only untracked `tmp/` content.
Authorization is the lead's bounded review of owner-authorized #234; no deferred
work is included.

## Verdict

**No material soundness or admission-domain gap found within the reviewed
semantic scope.** The scalar-flow definitions and the inspected native transfer
agree with the selected rules. The universal argument explicitly closes repeated
loop execution; it does not assume that precise preloop mutable facts survive an
iteration. This is a read-only argument/code review, not a new Lean or native
validation result or approval of the unfinished source-correspondence integration.

## Critical checks

- Guard selection requires a bare resolved name, separate refinability metadata,
  and an independently static singleton threshold (`ScalarFlow.lean:96`). Both
  operands are inferred before selection (`ScalarFlow.lean:122` and
  `PredicateChecking.lean:456`). Complement/swap and `refineOrKeep` cover both
  outcomes, strict endpoints, contradictory guards, and initially empty indexes.
  The native `Bare_Target`/`Read_Relation_Into` logic agrees
  (`silver_output_profile.adb:1452`, `:1750`). An immutable nonstatic snapshot or
  singleton loop index does not become a static threshold merely because its
  interval is a singleton.
- True/false, negation, reached short-circuit RHSs, and alternative-outcome hulls
  carry the entire flow (`PredicateChecking.lean:257`). String/Image checking
  reads that reached scalar component. Scalar comparisons leave the independent
  input path unchanged, including impossible scalar outcomes. The native chain
  updates match (`silver_output_profile.adb:1865`), as do branch/elsif/omitted-else
  transfers (`:2301`, `:2325`).
- Assignment checks the RHS in incoming flow against the immutable declared
  target range and replaces only its target cell (`IntegerMutable.lean:125`,
  `PredicateStatements.lean:147`, native `:2007`). String writes leave scalar
  flow intact. Scalar writes preserve established facts about immutable input
  length; later Images are inferred afresh. The execution theorem retains both
  current-flow fit and declared-range fit.
- Loop bounds are captured in entry flow before mutable widening. Entry flow
  retains immutable/outer-index cells, adds a fresh index, and exit flow restores
  those entry cells while widening mutable cells unless the loop is abstractly
  empty (`PredicateStatements.lean:136`, native `:2225`). The difficult repeated
  iteration step is proved from declared containment plus equality of readonly
  cells (`ScalarFlow.lean:56`, `PredicateExecution.lean:147`, `:270`, `:416`).
  Captured iteration values do not change when bound objects are assigned;
  nested loops restore their lexical index. Body-derived outer-index refinements
  do not escape, and no mutable first-iteration precision is reused.
- Declaration-order static flags and initial analysis are derived from the
  parsed declarations (`IntegerMutable.lean:201`, `PredicateHeaderFlow.lean:76`).
  Header-derived nonemptiness justifies literal preservation of fixed cells
  through joins (`PredicateHeaderFlow.lean:103`,
  `PredicateStatements.lean:244`). Reader overlays preserve metadata and binding
  identity; the scalar guard source-reading lemmas distinguish bare names from
  parenthesized names (`PredicateScalarGuardMeaning.lean:82`, `:168`, `:200`).
- Obligation generation consumes the same reached flow, assignment replacement,
  branch flows and widened loop entry as admission
  (`PredicateObligations.lean:100`, `:183`, `:200`). Its structural discharge
  theorems cover all statement/condition constructors, including nested loops
  and sequencing. Source/native VC correspondence and external solver completion
  remain distinct obligations, accurately stated by `PredicateChecks.lean`.
- Empty index intervals do not suppress inference of independent illegal static
  subtrees. Constants' exact values/staticness remain unchanged; scalar assignment
  retains its unconditional nonempty-RHS requirement. The documented loss of
  admission when precise captured bounds expose an empty loop is intentional
  (`language.md:393`), and no unjustified admission-monotonicity claim was found.

## Exact inputs and limits

Read `AGENTS.md`, `oracle.md`, selected rules/flow sections of
`docs/scalar-guard-refinement.md`, the complete
`docs/evidence/scalar-guard-refinement/proof-design-20261026.md`, relevant Integer,
guard, assignment and loop sections of `language.md`, and the existing
`docs/reviews/review-integer-division-delivery-384cb43a24.md` format. Inspected the
branch change inventory and focused `origin/main...HEAD` semantic diffs.

Proof inputs read directly: `IntegerComparisons`, `IntegerMutable`,
`IntegerExpressions` (inference/safety), `ScalarFlow`, `PredicateChecking`,
`PredicateStatements`, `PredicateExecution`, `PredicateObligations`,
`PredicateComposition`, `PredicateChecks`, `PredicateFlowOverlay`,
`PredicateFlowInvariant`, `PredicateHeaderFlow`, `PredicateScalarGuardMeaning`,
`PredicateBasicReadings` (basic meaning), `PredicateBodyFlow`,
`PredicateBodyMeaning` (metadata, loop and statement meaning),
`PredicateConditionFlowValidity` (flow invariant/guard/join preservation), and
the `SourceDeclarations` diff. Also inspected the theorem inventory of condition
and body flow-validity modules, the changed native flow/reader/condition/statement/
loop implementations in `src/silver_output_profile.adb`, and the corresponding
cases in `tests/test_scalar_guards.py`.

The report does not claim a complete typed native-equation/source audit, native
proof-annotation review, final assurance closure, resource bound, fresh runner
result, or test execution. Those were explicitly outside this bounded assignment.
No native, Lean, build or test runner was invoked; no project source, GitHub state
or unrelated file was changed. Only this scratch report was written.
