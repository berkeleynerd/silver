# Residual imported-callee closure inventory

Read-only inventory on 2026-11-27 after Specification commit `d25e77eaab`.
Inspected primary `tmp/named-array-parameters-410`, including Main boundary and
identity commits through `ade9e10843`. Selected proof role: Astra Max; live
model/effort is not independently exposed. No validation run or native edit is
claimed by this inventory.

## Specification and static Boolean

`specification_imported_reader_exec` in
`ApplicationPackageDeclarationsSpecificationLoopImports.lean` closes the complete
typed procedure, all return paths and arbitrary prior storage, over `ValidText`
and arbitrary metadata. Its Object import is
`ObjectLibraries.object_meaning`; the scalar initializer and executable Boolean
initializer have actual imported library interpretations. The shared
`BooleanElaboration.Native.Reader` is still an explicit parameter on both sides.

The static recursion is already constructed: `StaticBooleanRecursion.closedReader`
uses the source variant, `closed_stage_equation` proves the four equations, and
`StaticBooleanReaderDefinitions.closed_body_reads` supplies all four typed body
executions. `BodyReads.determined` proves uniqueness on
`StaticBooleanSourceChecks.Domain`, using smaller recursive calls, without assuming
reader equality. `BodyReads.source_expression` gives the accepted expression
reading. These theorems are currently specialized to `modelImports`.

The residual is the **actual imported-leaf interpretation and domain transport**
for `Native.Imports`: `take`, `reference`, `lookup`, `nameIs`, `booleanAtom`,
`scalar`, `comparison`, `chain`, and `chainAfter`. Instantiate the actual reader
family after replacing those leaves on their call domains, then reuse recursion
uniqueness and connect its `.condition` reader to Object/Specification. Domain is
the complete native precondition: `ValidText`, `StateType`, `stateValid = true`,
and cursor at most `text.length + 1`; position zero is included. Actual full
source extraction exists as `BooleanElaboration.Native.SourceChecks.actual_checked`
in `ApplicationPackageCallSourceChecks.lean`, but its current authoritative
checkpoint is the root's responsibility. A candidate or an unchecked source
snapshot cannot replace that checkpoint.

## Completion

`ApplicationPackageCompletionSimulation.body_simulation` is an exact equality
between the projected typed procedure evaluation and `packageCompletionFuel`,
for arbitrary `CompletionCalls`, fuel and incoming locals. It closes source
control and output projection; it does not interpret the callee dictionary.
`declarationCompletion_total` / `readCompletion_eq` totalize the model after
`declarationReaders` substitution, including rejection. This totality can be
transported through `body_simulation`; it is not yet an imported-library bridge.

`declarationReaders` in `ApplicationPackageCompletionSourceLayout.lean` replaces
`signatureAt`, `routineFrame`, `objectAt`, `takeToken`, `skipAt`, `nameAfter`,
`validName`, `sameName`, `contextOf`, `bodyOf`, `appendFormal`, and `validState` by
their models. The five fields still inherited from arbitrary `CompletionCalls`
are `initialFlow`, `stateReads`, `actualAfter`, `applicationTail`, and
`functionReturnAfter`. `CompletionBodyRead.function_source` explicitly still
requires `calls.functionReturnAfter = Predicate.functionReturnAfter`; semantic
history/layout theorems do not discharge that native import equality.

Remaining composition work:

- Construct actual Completion calls from the already proved Signature/Object,
  name/validity/frame libraries and the actual Routine_Frame body. The latter's
  `ApplicationPackageRoutineFrameMeaning.body_meaning` remains parameterized by
  its `Calls` (`bodyEnvironment`, `validName`, `hideOuter`, `appendFormal`,
  `validState`); no complete imported Routine_Frame library was found.
- Prove caller-domain preservation from native `ValidText` and valid Globals,
  retaining native component subtypes of arbitrary metadata. In particular,
  Signature completion results feed Routine_Frame; its returned frame feeds
  every local Object; successful local frames feed the output-initializer loop;
  `validName` and range guards supply each selected output's domains; appending
  outputs must preserve the frame for body/context conversion. Do not add a
  whole-metadata validity premise absent from the header.
- Interpret `initialFlow`, `stateReads`, `actualAfter`, `applicationTail`, and
  `functionReturnAfter` on the actual context/flow/catalog/formal domains. Carry
  all bounded cursors, effect sets and result types through rejected as well as
  accepted paths. Semantic layout/history results apply to successful modeled
  executions and are useful downstream, but do not by themselves provide the
  complete callee preconditions on every execution path.
- Join the imported control equality with totality and the exact source
  extraction in `ApplicationPackageBodies.SourceChecks.Checked`.

## Package_Body

`ApplicationPackageUnitInterpretation.body_meaning` identifies the typed control
with `execute`; `ApplicationPackageUnitSimulation.body_simulation` currently has
the premise that a typed evaluation returned `some after`, and yields
`UnitMeaning`. It is a soundness direction, not native evaluator existence.
`ApplicationPackageBodyTotal.packageBody_total` / `readBody_eq` prove model
totality for `bodyReaders`, with the cursor/phase measure and no input narrowing.

Remaining work is to interpret the actual `UnitCalls` (`validState`,
`packageWord`, `skipAt`, `nameAfter`, `takeToken`, `sparkPragmaAfter`, `sameName`,
`objectAt`, `completionAt`), prove the necessary frame/cursor domains through
both loops and metadata writes, and establish native loop evaluation existence
or the converse execution simulation before concluding the complete procedure
bridge. The header has valid Exports and a bounded package-body unit start;
it does not assume complete metadata. Preserve failed partial metadata.
Object and Completion proofs are reusable callees, not new assumed equations.

## Main

`ApplicationPackageMainSourceShape.checked_meaning` and
`MainSourceChecks.actual_meaning` provide full typed control for an arbitrary
`Main.Calls` dictionary. `Libraries.context/start/frame/footer` in
`ApplicationPackageMainImports.lean` interpret context parsing, start tokens,
pragma, Imported_Frame and footer calls. `IdentityLibraries` in
`ApplicationPackageMainIdentityImports.lean` interprets imported-package scanning
and package spelling, including arbitrary incoming locals and word origins.
The actual spelling extraction checkpoint is still root-owned.

Remaining dictionary entries are `argumentAt`, `readDeclarations`, `contextOf`,
`bodyOf`, `applicationTail`, and `completed`. Root explicitly owns inherited
argument/declaration/context/body/path-completion joining; semantic integration
owns the application-tail source/meaning chain. Their composition must derive
frame/context/flow/catalog domains from `Bundle.Valid`, valid Exports and
`Complete_Metadata` (the actual Main precondition), including failed declaration
and body results needed by later guards. `Libraries.footer` specifically expects
the bounded cursor returned by the body reader. No accepted-Main, decoder,
semantic safety or uninterpreted callback premise may remain in the final bridge.

## Separate admission gap

`ApplicationAdmission.Native.Callees.chargeUnit` is still explicit;
`ApplicationAdmissionBudget.chargeUnit` is model-only. The authorized next task
is a local typed source binding for the complete Charge_Unit procedure, retaining
both Remaining and Accepted outputs over full `ValidText` and the entire
`0 .. maxConcatenations` allowance domain. This is independent of the above
Completion/Body/Main joins.
