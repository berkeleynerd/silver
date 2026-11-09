# Independent response integration review — 74ea2edeaa

Date: 2026-11-09. Tracking: [#355](https://github.com/berkeleynerd/silver/issues/355),
milestone 22. This is a source-review checkpoint, **not final delivery acceptance**.
No unresolved source-review finding remains within the scope below. Final
integrated validation remains pending.

## Target and method

Reviewed response commits through `6365003968a3631493e60380d71417fdc42233c3`,
against authorization base `3f033b97d8`, and selected inherited report-policy and
catalogue source changes since `10cdcd274c`. The initial response review was at
`299d224eae`; the direct-formal regression repair `423b11500e` and guard commits
`61cbc12a7b` / `97596fb4d1`, catalogue wording repair `060d5dcfac`, and control
elaboration repairs through `b426a2fe94` were subsequently inspected. The
inherited-interface report at `6365003968` is byte-identical to its author's
`3fe93af679`. The governing Oracle, response plan and original external report
were read. Requested review settings:
Astra Max; no independent live-model telemetry was exposed to this subthread.

The integration checkout remained read-only. This reviewer ran no compiler,
tests, bootstrap, native proof or Lean build, and changed no GitHub state. The
review report is owned in a separate worktree. No managed workers were reserved.
The live harness goal query returned no goal. Complete final validation artifacts
have not yet been reviewed; successful retained proofs are evidence, not a substitute
for inspecting the acceptance rules or native-to-model domains.

## Findings and disposition

1. **Low, resolved in source:** extending the native `Wrapper` fixture replaced
   its direct `Next_Value(X)` call on a scalar formal with `Next_Value(J)` on a
   loop index. That removed a distinct existing native path. Commit `423b11500e`
   restores the direct call before the nested loops while retaining the new
   loop-index call and the expected ` 10` output. The unrestricted Integer
   self-actual path remains covered by the new `R := Main(R)` fixture, so changing
   the older self-actual fixture to a constrained subtype loses no corresponding
   path. Execution of the final repaired fixture remains to be checked.
2. **Low, resolved in source:** the general refinement target descriptions in
   `catalogue/silver.json`, its Ada emitter, `language.md` and the capability
   summary omit Integer formals. The function-specific catalogue and language
   rules already admit bare-name formal refinement. The lead accepted this
   inconsistency as [#367](https://github.com/berkeleynerd/silver/issues/367).
   Commit `060d5dcfac` adds formals to the general target descriptions and
   identifies immutable object constants precisely. The emitter and JSON agree;
   the patch corrects descriptions without changing admission.
3. No new blocker or medium was found in the bounded source review below.
   Three small focused attempts failed in newly added control proofs: private
   fixture visibility, numeric rendering reduction, and the Compose String
   mutual/dependent renderer equality. The repairs make fixture-dependent
   controls private, separate reflexive equalities from guard decisions, and
   finally rewrite the independently established condition-token equality
   through the command-render equations. They change no control proposition or
   guard semantics. The final Compose String focused run passes as recorded
   below; the full guard batch and complete integrated validation remain pending.

## Response regressions and records

The four malformed-function additions use otherwise valid declarations and
reach the intended syntax distinctions: trailing formal semicolon, bare
`return`, trailing actual comma, and a missing actual comma in a two-formal
call. The existing empty-formal rejection remains. The B2 additions preserve
the four identity spellings and nonstatic counted-loop index case without
introducing an unrelated arithmetic error.

The local-hiding controls distinguish the legal local name from an ungrouped
sum and from its grouped, full-Integer-overflowing form. The native hiding and
argument-shell fixture's expected outputs follow its declarations and calls;
the two-argument path rejects before output. The unused-function fixture is an
output-capable shell despite having no output statement, and binds termination
and division records to `Main.Unused`, while the shared helper independently
audits all supplied function identities. It does not claim to exercise the
separate null-program warnings route.

The four scalar-index placeholder edits match between the emitter strings and
JSON text. Their conditions still exclude nested array reads; changing the
placeholder does not widen the index grammar. The historical evidence pointers,
auxiliary frame-flow description, measured-memory units and CPU-policy correction
retain the distinction between dated evidence and current claims. The assessor's
new text accurately includes the slice span and guarded-endpoint restrictions,
constant-array counted-bound exclusion and empty-operand identity restrictions.

## Boolean name-domain repair — #366

`Name_Is` in `src/silver_output_lexical.ads` requires `Word'First = 1` and
`Word'Length in 1 .. Max_Source_Length`, alongside the valid source/span domain.
The list interpretation supplies one-based indexing; the added
`0 < expected.length` and `expected.length ≤ maxSourceLength` premises in
`BooleanBindingsNative.Primitives.nameIs` supply the previously missing length
domain exactly. `maxSourceLength` is 4096.

The current consumer compares the literal `integer` (seven bytes), so its two
new domain proofs are concrete. `model_primitives` remains a direct model
witness. Neither the native implementation nor the `lookup_meaning` and
`hidesInteger_meaning` endpoint statements changed. The documented trusted
boundary permits formal totalizations outside represented native domains; the
broader original premise is not evidence of an illegal native call or Oracle
failure. The repair makes the native-domain correspondence explicit without
narrowing an admitted program's domain or weakening an endpoint conclusion.

The retained `20261109T140146-6fb9495fc152` evidence and log were inspected:
the `Silver.BooleanBindingsNative` focused build and fresh audit passed on
Linux x86_64, checking 12,824 declarations under the three documented foundations.
This was a cached build, not a clean build or kernel replay, and does not alone
check the caller bridge or the final integrated guard changes.

## Structural guards — #356 and #357

The prefix rules were compared with the constructors' actual renderers in
`FunctionDeclarationNative`, `FunctionBindingsNativeExpressions`,
`PredicateFunctionCallNative`, `PredicateBooleanBodyNative` and
`ComposeExpressions`. Each changed variable prefix now requires a name category
and recursively checks its child. This covers ordinary selection/indexing and
the additional selections emitted inside aggregate constructors. Grouped
expressions, conditionals and unqualified aggregates cannot masquerade as names;
actual names, calls and indexed/selected components remain available.

An aggregate base that is only used as an expression keeps its previous rule.
In particular, grouped and nested delta updates remain positive controls.
`addHiddenCalls`, `appendBoolean`, the metadata extensions, `subtypeAppend`,
`arrayAppend` and `stateBinding` need the stronger rule because their renderers
also select fields from the supplied base. The current positive tree inventories
and their existing checked-source connections are retained.

The new `not` and subtraction controls assert equal rendered tokens and reject
the wrongly associated tree while accepting the intended tree. Function
visibility has only its applicable logical/quantified categories; it needs no
invented subtraction constructor. Compose String controls check propagation
through declarations and command branches. Existing array-subtraction collision
coverage is retained rather than duplicated. Mixed-operator, explicit-group and
malformed-nested-child controls exercise the actual recursive rules.

The guard diff changes no evaluation function, renderer, current tree definition,
source-shape pin, native source, semantic equation or endpoint statement. These
are structural checks supporting the documented interpreted-source boundary,
not a general verified Ada parser. Their theorem elaboration and complete final
source/module audit remain required.

The `20261109T141833-cb10648fbacb` log and focused evidence were inspected after
the final proof repair: `Silver.ComposeStringNative` builds and its fresh audit
passes with 13,357 declarations and only the three documented foundations. This
is partial cached validation, not the complete guard/source checkpoint. The
earlier failed attempts remain failed; their retained diagnostics do not count
as successful evidence.

## Bounded inherited report-policy and catalogue review

This supplements the external report's section 2a within an explicit scope. The
separate inherited-interface reviewer owns the nine named Compose/Predicate/
Scalar/Boolean premise families; this review does not duplicate or silently
extend that inventory.

The [inherited-interface report](review-inherited-interfaces-74ea2edeaa.md), its
276-line field map and exact input/field inventory were read. They distinguish
native preconditions, postcondition consequences and raw equations, identify
the current caller domains and historical interfaces, and state the remaining
frontend/totalization assumption. Their scoped conclusions and limits are
consistent with this review. This is review of that assessment, not a second
field-by-field audit of all nine interfaces; #366 was independently checked
above.

The inspected policy path comprises application entity/function identification,
`Reference_Policy`, termination/record/list policies and executable counterparts,
exact entity and coverage maps, bounded/raw object and application policies,
record/list observation agreements and congruences, the termination-witness
transfer, projection/application interfaces and the driver's propagation of
`Source` and `Functions`.

- Every application variant includes all declared functions in its exact entity
  set and requires `all` coverage for Main and each function. The universal flow
  audit checks successful termination record contents; the separate per-function
  witness pass requires exactly one matching record. A witness alone does not
  bypass the universal diagnostic check.
- Application proof records remain restricted to proved range, length,
  overflow, division and index checks on Main or a supplied local function.
  Exact warning allowances remain distinct from proof records; suppression,
  justification and skipped-proof/assumption fields do not gain an allowance.
  Local-function dependency references admit AORTE/effects, not postcondition
  claims. Image message casing is limited to the three exact producer strings.
- Raw and bounded policy branches carry the same source/function arguments and
  acceptance conditions. Observation relations preserve relevant byte fields,
  malformed states, record order and resolved entity identities; they do not
  assume policy acceptance. The raw policy has no projected-storage bound.
  `Mixed_Termination_Witnesses` transfers the exact quantified predicate rather
  than replacing it with a weaker witness. The existing `Hide_Info` annotations
  hide bodies in callers; they introduce no premise or discharged-check waiver.
- The projection-audit specification, implementation and driver pass identical
  metadata to the raw and executable policies. The final successful-read facts
  remain required by the driver contract.

No acceptance or congruence mismatch was found in that path. This was a source
inspection of the named policy conditions and interfaces, not a fresh proof of
every JSON scanner lemma or every changed `Mixed_*` body. The complete native
checkpoint must still discharge all their actual obligations.

The changed catalogue condition inventory was read against the corresponding
current-language rules, prioritizing Boolean/array flows, subtypes, staticness,
slice endpoints, counted-loop bounds, empty operands and function domains. The
formal-refinement description finding above is the resulting correction. This
does not establish complete line-by-line clearance of every recognizer helper
changed in the inherited 871-commit range, of all previously unread Lean module
statements, or of historical record-only findings.

## Remaining acceptance work

Inspect the full focused guard/domain evidence on the exact integrated commit,
the final regression inventory, live catalogue equality, and complete native and Lean/source/audit
results with their final input identity and cache provenance. No cold/replay or
macOS run is implied or required by this source-review checkpoint. Final
delivery acceptance remains pending those results. The lead owns final evidence
applicability, publication and durable/CLI memory updates; this review did not
update CLI memory.
