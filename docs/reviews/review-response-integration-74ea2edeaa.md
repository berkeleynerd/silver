# Independent response integration review — 74ea2edeaa

Date: 2026-11-09. Tracking: [#355](https://github.com/berkeleynerd/silver/issues/355),
milestone 22. **Accepted for response delivery within the scope below.** No
unresolved source, disposition or evidence-applicability finding remains. Complete
native, Lean/source/module/axiom and regression evidence applies to the reviewed
governed inputs.

## Target and method

Reviewed response commits through `6365003968a3631493e60380d71417fdc42233c3`,
against authorization base `3f033b97d8`, and selected inherited report-policy and
catalogue source changes since `10cdcd274c`. Final evidence acceptance targets
`b58c89d4815de10c7f3d6543aa58309224ad3650`; governed implementation inputs are
unchanged since `6365003968`. The initial response review was at
`299d224eae`; the direct-formal regression repair `423b11500e` and guard commits
`61cbc12a7b` / `97596fb4d1`, catalogue wording repair `060d5dcfac`, and control
elaboration repairs through `b426a2fe94` were subsequently inspected. The
inherited-interface report at `6365003968` is byte-identical to its author's
`3fe93af679`. The governing Oracle, response plan and original external report
were read. Requested review settings:
Astra Max; no independent live-model telemetry was exposed to this subthread.
Whole-review elapsed time and token/cost measurements are unavailable.

The integration checkout remained read-only. This reviewer ran no compiler,
tests, bootstrap, native proof or Lean build, and changed no GitHub state. The
review report is owned in a separate worktree. No managed workers were reserved.
The live harness goal query returned no goal, including at final handoff.
Completed focused/native, full regression and complete Lean evidence were
inspected as recorded below. Successful retained proofs support the acceptance
alongside source inspection of the acceptance rules and native-to-model domains.

## Findings and disposition

1. **Low, resolved:** extending the native `Wrapper` fixture replaced
   its direct `Next_Value(X)` call on a scalar formal with `Next_Value(J)` on a
   loop index. That removed a distinct existing native path. Commit `423b11500e`
   restores the direct call before the nested loops while retaining the new
   loop-index call and the expected ` 10` output. The unrestricted Integer
   self-actual path remains covered by the new `R := Main(R)` fixture, so changing
   the older self-actual fixture to a constrained subtype loses no corresponding
   path. The final repaired fixture passed in the full regression run below.
2. **Low, resolved:** the general refinement target descriptions in
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
   below. The full guard batch, regression suite and complete Lean checkpoint
   subsequently passed.

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
not a general verified Ada parser. The focused and complete checkpoints below
establish their theorem elaboration and final source/module audit.

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
checkpoint inspected below supplies their actual obligation-discharge evidence.

The changed catalogue condition inventory was read against the corresponding
current-language rules, prioritizing Boolean/array flows, subtypes, staticness,
slice endpoints, counted-loop bounds, empty operands and function domains. The
formal-refinement description finding above is the resulting correction. This
does not establish complete line-by-line clearance of every recognizer helper
changed in the inherited 871-commit range, of all previously unread Lean module
statements, or of historical record-only findings.

## Disposition and completed-evidence checkpoint

The retained artifacts are in the [response evidence packet](../evidence/review-response-74ea2edeaa/README.md),
with separate [regression records](../evidence/review-response-74ea2edeaa/regression/README.md)
and [complete Lean records](../evidence/review-response-74ea2edeaa/runs/20261109T144532-5e2dbc4f965b/index.json).

The response inventory accounts for every original low and informational finding
and section 2a. The no-change dispositions have no unresolved source finding
within the recorded scope. The original report remains byte-identical, SHA-256
`e6ceec4be70e00803e9823c7cfe2f17ad013075737d51f6cbcb2c738788a3300`.
The response correctly separates admission inputs, run invocations and successful
distinct source hashes; it does not repeat the original inflated full-route
claim. P1-5 now distinguishes `/=` exclusion at an interval endpoint from an
unrepresentable interior hole. C-1's original `c24b` probe also contains an
ungrouped sum; `c24c` has no function local and its retained log says accepted,
contrary to its rejection attribution in the original report.

The following evidence was inspected against unchanged governed inputs at
`6365003968`. The later integration commits change records only. The full
regression packet was inspected after its integration at `8ca502c2e8`, together
with the lead's updated response dispositions. The final Lean packet was
subsequently inspected at `b58c89d481`.

- Complete native run `20261109T142006-5f058d0b96be` has a successful managed
  finish, final all-checks-proved output and complete report audit: 77 units,
  1,165 entities, 1,605 flow checks and 16,920 proof checks, or 18,525 total.
  All 2,593 recorded input hashes and twelve tool hashes match the integration
  installation. Its full-scope command uses eight workers and `-f`; the native
  sessions and solver cache were present. This is a warm complete audit.
- The retained native packet initially omitted `gnatprove.sarif`, although its
  hash was in the complete provenance manifest. The lead repaired retention;
  all 79 report hashes now have matching compressed files, with the two
  input/provenance manifests bringing the report index to 81 artifacts. The
  omission was a packet gap, not a failed native run.
- Six-target focused run `20261109T142008-886cdd5994b7` passed its build and
  fresh 22,643-declaration audit. Its six requested closures include every
  changed guard/helper and the Boolean native-domain source bridge. It used
  fourteen Lake workers and 22 threads per process alongside native validation.
- The 80-function-leaf run `20261109T142839-1befe0666f22` passed its build and
  fresh 16,910-declaration audit, using six Lake workers and 22 threads per
  process. Its recorded actual driver exit is 0. Both focused audits admit only
  `propext`, `Classical.choice` and `Quot.sound`; both are partial cached checks,
  without clean build or kernel replay. The indexed compressed artifacts match
  their original hashes and lengths.
- Both final focused runs record the same 927 governed inputs, all of which
  match the integration bytes. Their recomputed digest is
  `5023e1a9cb4cc726eb10a5b5fc76feff0db1785e80c7ff630f7b0454693fd135`.
  Their pinned Lean/Lake tool hashes also match the installation.
- The post-rebuild live catalogue record reports driver exit 0 and byte equality
  with `catalogue/silver.json`. Its catalogue and compiler hashes match the
  current files. This reviewer inspected that evidence without rerunning the
  command.
- Regression setup/build records identify an independent installation and fresh
  compiler build. Every one of the 12,170 recorded source/test/sample/Rosetta/
  reference/project inputs matches both worktrees, with no missing or extra
  tracked file in the declared roots. Executable hashes match the setup record.
  The two generated path-bearing packages agree after installation-prefix
  normalization; `silver_library_sources.ads` is byte-identical. Canonical
  `silver` has SHA-256 `f0f50fea…`; the separately rebuilt regression `silver`
  has `eb8bf88f…`. Their identities are distinct. Before/after binary stability
  below refers to the regression installation, not cross-installation equality.

## Full regression evidence — 20261109T144553-8abe96c6e3ad

The complete unfiltered Linux x86_64 suite passed. The retained driver log ends
`Ran 648 tests in 4495.139s` / `OK`; the managed test phase records return code 0,
and the result record preserves the separately observed actual driver exit 0.
The managed finish is successful with no failure keys; its null `returncode`
field is not mistaken for an observed process exit. The run used 21 workers,
unchanged default deadlines/options and ordinary
`unittest discover -s tests -v`, with no exclusions, repair reruns or skips. Its
managed duration was 4,498.508 seconds, distinct from the unittest interval and
from agent time.

All 648 distinct execution headers and their successful endings were checked
against the census, including multiline diagnostic/description output. The
census covers all 634 current syntactic method definitions with no omitted or
extra definition. Five inherited Image/Array report executions and nine
`SharedBindingsTests` methods imported under both module spellings account for
the fourteen additional executions. They are actual executions, not additional
test definitions.

All nine named response methods passed, including the restored direct-formal
call and loop-index call in the same native fixture. The manifest method passed;
its unchanged source requires admission, application proof/report audit, build
and exact expected execution streams/status for all 84 manifest samples. These
are behavioral results, not universal assurance from samples.

After the run, all 12,170 recorded tracked inputs still match both worktrees and
their exact declared inventory, and all 1,123 prepared managed regression inputs
match their recorded hashes. Both regression executable hashes match their
pre-suite build identities. The archived event stream and native log also match
the original retained runner bytes. This reviewer read logs, inputs and ASTs;
no tests, discovery, builds or proofs were executed. The result applies to the
frozen response inputs, without composing successes from an earlier failed
suite. No regression evidence or applicability gap remains.

## Complete Lean evidence — 20261109T144532-5e2dbc4f965b

The ordinary complete Linux x86_64 check passed under pinned Lean 4.34.1. Its
`Silver.Audit` build reports 857 jobs; the separate fresh audit checks 145,589
declarations and admits exactly `propext`, `Classical.choice` and `Quot.sound`.
All 820 emitted project-module identities agree with both the evidence inventory
and the entire current proof-module tree, with no missing or unexpected module.
The build and fresh audit phases each exit 0. The managed finish is successful
with no failure keys; the result separately records the lead's observation of
actual driver exit 0, rather than interpreting the managed null return code.

All 927 captured input hashes and both Lean/Lake tool hashes match the canonical
installation. The captured file set is exactly the runner's current input set,
and its recomputed digest is the same `5023e1a9…` digest recorded above. Generated
certificates are excluded from this input count by design and regenerated by
the runner; they remain in the complete module inventory. The workspace's
authoritative-source link resolves to the canonical `src` directory. The seven
indexed compressed artifacts match their recorded original hashes/lengths and
the retained original runner/monitor bytes.

The run used one Lake worker and 22 threads per process, with the documented
host-memory reason for serializing dense candidates. The build took 14,038.369
seconds, the fresh audit 10.660 seconds, and the managed interval 14,069.219
seconds. These are tool intervals, not whole-team time or cost. The packet also
retains 933 resource samples spanning the leaf/complete work; these are sampled
observations, not established process peaks or universal memory bounds.

This is a cached complete build with a fresh whole-project audit. It does not
claim a clean build, independent kernel replay or new macOS validation. Applicable
seed caches and preceding focused successes were retained; this reviewer did not
repeat any successful validation.

## Final acceptance

The reviewed repairs, complete checkpoints and full regression inventory satisfy
this response's acceptance requirements on the governed `6365003968` inputs,
retained at final evidence target `b58c89d481`. All original findings have an
implemented or reasoned disposition; the two integration findings and native
packet-retention gap are resolved. No remaining review blocker was found.

This acceptance retains the bounded source-review limits above and the documented
interpreted-source/trusted-tool boundary. It does not confer fresh line-by-line
clearance on the entire inherited range or turn samples into universal assurance.
The lead owns final editorial closeout, publication and durable/CLI memory
updates. This reviewer changed only this report and did not update CLI memory.
