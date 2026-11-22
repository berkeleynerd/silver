# Focused proof review of Silver PR #412 — named constrained Integer-array inputs

## 1. Verdict

**No blocker, no medium and no low finding.** On every argument path I traced
through the five priority areas, the proofs at the fixed target support both
endpoint guarantees (universal safety and automatic obligation discharge) for
the new feature, and the #414 repair holds.

I record five info-level items. Three disclose facts that are proved or assumed
but do not feed the endpoint, one is an evidence limit in the capacity argument,
and one is housekeeping. None changes a conclusion the project currently states.

| Item | Classification |
| --- | --- |
| I1 | Side lemmas that do not feed the endpoint; not a gap |
| I2 | Valid trusted premise (one assumed law) consumed only by side lemmas |
| I3 | Valid trusted premise under the documented convention |
| I4 | Evidence limit; the stated conclusion stands |
| I5 | Housekeeping |

I found no false current conclusion and no latent gap.

**This is not a complete review of every proof body.** I read definitions,
hypothesis records, theorem statements and supply chains, and I read tactic
bodies only where the body is itself the argument. For the rest I rely on the
retained kernel audit, which I did not re-execute. Section 3 states the coverage
limit of each area and section 6 lists everything not opened.

## 2. Target, settings and time

| Item | Value |
| --- | --- |
| Target | `5a4b0ad8ac05ed431d2f0c8baee2c2cc75686267`, detached HEAD verified at 10:47Z, 11:26Z, 11:40Z and 11:47Z; worktree clean each time |
| Base | `5f97477d5be1c9da974e6df95300bb8f2bb8fcfb`, verified as the merge-base of the target |
| Selected model and effort | `claude-fable-5-2`, CLI effort `max` (from `launch.json`) |
| Observed model | The session identifies itself as Claude Fable 5.2 (`claude-fable-5-2`). Server-side effort is not observable. No fallback notice was seen. |
| Session form | Direct single-reviewer session; no nested sessions, MCP, agent fan-out or managed runs were started |
| Managed run | `20261122T104651-c6826d4fd799`, session `00c8c1e9-7bce-4a1d-ab7e-ed51f14666c2` |
| CPU | Affinity mask `0x3` (CPUs 0–1) at start and end, `nproc` = 2; all local computations serial |
| Time | Started 2026-11-22T10:46:54Z, closed 2026-11-22T11:49Z; about 62 minutes wall-clock |
| Diff verified with Git | 10 Ada files (+771/−144); 347 Lean files (48 added, 299 modified), 8 of them generated certificates; 339 non-certificate Lean files (+18,259/−6,033) |

The session's context was compacted once, at about 11:20Z. Readings made before
that point are carried by my own retained notes. After it I re-ran the cheap
mechanical checks (HEAD, unchanged endpoint modules, escape-hatch scan, capacity
arithmetic, producer hashes) and re-read the #414 structure, the named-object
path and the procedure path. The typed-tree rendering comparisons in 3.2 and
3.4 and the first seven producer ranges in 3.5 rest on those notes and were not
repeated; the remaining producer ranges were read after it.

Method: static reading only. The only computations were `git diff`/`grep`,
SHA-256 of retained producer files, and four small scripts in `scratch/work/`.

## 3. The five proof areas

### 3.1 Full-domain array views, frames and calls

**Result: no defect.** One disclosure, I1.

Invariants re-derived, with the declarations that carry them:

| Invariant | Where it is established |
| --- | --- |
| Physical cells and symbolic views never share an address. Stored objects occupy cells 586–2633; a view in slot `s ≥ 1` starts at `585 + 1 + 2048·s ≥ 2634`. | `NamedArrayParameters.Domain.formal` (`NamedArrayParameters.lean:132`), `formal_above_scalars`; Ada `Append_Array_Parameter_Model` (`silver_output_profile.adb:6936–6956`) writes `Offset = 0`, `View_Slot = Count + 1` |
| A table is all-stored (Main) or all-view (callable frame). | Ada `Valid_Metadata` adjacency clause; Lean `ValidTable`, `Adjacent`, `ValidTable.stored_iff_first`; `ParserState.StoredArrays` (`ComposeStoredArrays.lean:14`) kept by `initialState_stored`, `step_stored` (`ComposeGrammar.lean:397`), `declarations_stored` (`ComposeDeclarations.lean:231`) |
| A callable frame starts with no array objects and the outer type table. | Typed tree `emptyArrayFrame` (`ProcedureDeclarationSyntax.lean:634`, rendering `:713`) against the Ada delta aggregate; `ParameterFramesAt.arrayViewKinds` (`FunctionParameterArrays.lean:274`), `ProcedureInputFramesAt.arrayViewKinds` (`ProcedureFrameArrays.lean:183`) |
| Nominal identity is the type-table index, and the table only grows. | `Array_Actual_After` (`silver_output_profile.adb:5115`) requires equal non-zero `Type_Id`; `Domain.Matches`; `CallableTypesKnown` (`CallableTypeHistory.lean:11`), `NoncallableTypeExtension` (`NoncallableDeclarationHistory.lean:14`), `formalModel_prefix`, `catalogSignatures_typePrefix` |
| Body reasoning uses the complete declared component interval, including for unused callables. | `ScalarFunctions.arrayAnalysis` (`ScalarFunctionFrame.lean:15`): view cells get the component bounds and are never mutable, static or refinable; Ada `Read_Bounds` postcondition; `viewRanges`; `Definition.Checked` is required of every catalogued definition |
| Formal views are installed after local initializers. | Ada order `Function_Locals` then `Parameter_Frame` / `Procedure_Input_Frame`; `Function_Local_At` (`silver_output_profile.adb:6863–6880`) admits scalar and Boolean locals only; local initializers are typed with `frameExpression []` |
| Call checking implies the callee's input domain. | `Actual.array` check is `Matches` plus `componentRanges` (`ScalarCallChecking.lean:21`); `capture_of_checked_ranges` (`NamedArrayParameters.lean:121`, used at `ScalarCallExecution.lean:80`); `bindArrayArguments_fits` (used at `ScalarFunctionSemantics.lean:73`, `ScalarProcedureSemantics.lean:77`) |
| Forwarding and repeated actuals. | The callee is evaluated on a fresh `localFrame` with slots from 1 (`ScalarFunctionDefinition.lean:126`); each actual is captured by value from the caller's store |
| Scalar state and copy-back. | Procedure array formals must be `in`: Ada `Procedure_Parameter_Step`, `ValidFormal`, `appendProcedureParameter_named_input` (`ProcedureFrameValidity.lean:37`). Writable targets are scalar cells, disjoint from array cells: `actual_write_noninterference`, array case (`ScalarProcedureNoninterference.lean:197–215`) |
| The native frame analysis equals the model analysis. | `ParameterFramesAt.arrayAnalysis` (`FunctionParameterArrays.lean:164`), `ProcedureInputFramesAt.arrayAnalysis` and `.arrayDescriptors` (`ProcedureFrameArrays.lean:55`, `:145`) |

Also read for this area: the nine `ScalarProcedure*` diffs, `ScalarCallSyntax`,
`ScalarFunctionTypes`, `ScalarFunctionArrayShape`, `PredicateArrayViews`,
`PredicateFunctionCallTypes`, `PredicateFunctionCallArrayActual`,
`FunctionFrameValidity`, `ProcedureFrameMeaning`, `ProcedureHeaderValidity`,
`FunctionHeaderValidity`, and the named-object path
(`IntegerArrayHeaderAt.named`, `ComposeArrayTypeDeclarations.lean:284`;
`append_physical_array_native`, `ComposeArrayElaboration.lean:263`).

**Coverage limits.** `FunctionBodySource` (lines 60–175), `ProcedureDeclarationMeaning`
(20–140) and `ProcedurePrefixExpressionMeaning` (1–60, 150–194) were read in part.
For `ProcedurePrefixMeaning`, `ProcedureDeclarationTrace`,
`ProcedureDeclarationHeaderMeaning` and `FunctionDeclarationMeaning` I read the
changed statements, not the bodies.

### 3.2 Native preconditions and primitive assumptions

**Result: no defect.** One disclosure, I2.

Ada contracts compared with Lean equation domains; all matched:

- `silver_array_bindings`: `Valid_Type`, `Valid_Types`, `Valid_Binding`,
  `Valid_Metadata`, `Valid_Environment`, `Lookup[_Model]`, `Lookup_Type[_Model]`,
  `Contains`, `Element_Slot` (now requires `View_Slot = 0`), `Hull_Model`,
  `Read_Bounds`.
- `silver_scalar_expressions`: `Read_Array_Attribute`, `Read_Atom` through
  `Read_Expression` with the new `Array_Reads` mode.
- `silver_output_profile`: `Scalar_Constraint_At`, `Array_Type_At`,
  `Array_Type_Declaration_At`, `Add_Array_Binding`, `Array_Actual_After`,
  `Formal_Type_At`, `Append_Array_Parameter[_Model]`, `Declaration_At`.
- `silver_function_bindings`, `silver_procedure_bindings`: `Valid_Metadata` with
  the `Type_Id` clauses.

Specific points checked:

- **Widened arithmetic.** `Wide (Upper) - Wide (Lower) < Wide (Max_Elements)`
  and `Length = Wide (Upper) - Wide (Lower) + 1` are modelled over `Int`, so
  the comparison cannot wrap; the Lean `arrayLength` is `(upper - lower + 1).toNat`.
- **Defaults.** The source checks pin `Array_Reads : Array_Read_Mode := All_Elements`,
  `Range_Query : Boolean := False`, the enumeration order, and
  `Type_Id : Array_Bindings.Type_Count := 0` in `Function_Type_Result`
  (`FunctionSourceParts/DeclarationTypeResult.lean`).
- **Dispatch and precedence in `Read_Atom`.** Scalar name, then attribute, then
  element read. The Lean model `tableAtomStep`
  (`ScalarExpressionNativeModel.lean:214`) has the same order, and
  `tableAtomStep_dispatch` restates it.
- **Declaration dispatch.** Ada `Declaration_At` (`silver_output_profile.adb:2610–2636`)
  tries function, procedure, array type, subtype, scalar, array, Boolean,
  character, string. Lean `declarationAt` (`ComposeAdmission.lean:12`) has the
  same order, and the loop fuel now includes `maxTypes`.
- **Hiding.** `Lookup_Type` was added to every site that resolves a name as a
  type mark or admits a new name; the Lean admission model has the same
  additions (`newNameAllowed`, `scalarTypeAt`, `declarationStringTypeHidden`,
  and the character, subtype, scalar, array and Boolean declaration readers in
  `ComposeDeclarationAdmission.lean`).
- **Counts.** `Max_Types = 170`, `Max_Bindings = 585`, `Max_Elements = 2048`.
  Reads of `Types.Items (Id)` are guarded by `Id <= Count` at each site I checked.

**Primitive assumptions.** The laws below are assumed as fields of the
interpreted-source records; they are how the project states the documented
Ada frontend premise (`docs/trusted-boundary.md`, "unchanged lexical callees
retain their established meanings"), not new project axioms.

| Record | Assumed laws | New in this PR |
| --- | --- | --- |
| `ArrayBindings.Native.Primitives` | `equalName`, `validNameState`, `isEmpty`, `singleton`, `join` | `validNameState` |
| `ScalarExpression.Native.Primitives` | trivia, identifier, `equalName`, `nameIs`, `lowercase`, integer literal, checked interval arithmetic, embedded array primitives | none |
| Function and procedure binding `Primitives` | `equalName`, `validNameState`, `isEmpty` | none |

`validNameState` is examined under I2: the law is the unchanged Ada body, its
domain was not widened, and nothing on the endpoint path consumes it.

**Coverage limits.** The tails of the `ScalarExpressionNativeExpressions`,
`FunctionDeclarationNative` and `PredicateLoopNative` diffs and the middle of
`PredicateFunctionCallNative` were not read. The six
`ScalarExpressionNativeTable*` modules (888 lines) were read at statement level
only. The 8 generated certificates and `OutputBodyLines0–7` were not opened, so
I did not independently confirm that the token tables equal the Ada files.
`src/silver.adb` and `src/silver_catalogue.adb` were not read.

### 3.3 Actual-source imports through every path (#414)

**Result: the repair holds on the paths traced.** One disclosure, I3.

- **Main.** `Compose.SourceBridge.InterpretedSource` carries
  `arrayImports : ArrayImportSource calls` (`ComposeSourceBridge.lean:124–134`).
  `ArrayImportSource.meaning` (`ComposeArrayImportMeaning.lean:41`) derives the
  array lookup, type lookup and full-table scalar reader from a linked native
  library with its own interpreted source, on `ValidTable`, `ValidTypes`,
  `ValidInitials` and valid cursors. `definitions` is now a function of those
  derived imports (`PredicateInheritedReady.lean:247`,
  `definitions := fun _ imports => imports.raw …`), so the three laws are no
  longer free fields.
- **Boolean wrappers.** `PredicateImportSource.meaning`
  (`ComposeBooleanImportMeaning.lean:21`) derives `Predicate.Native.HelperMeaning`
  from the same imports.
- **Function and procedure local-initializer paths.** `inherited_import_source`
  (`ComposeSourceBridge.lean:166`, applied at `:240`) replaces the three array
  imports and `booleanDeclaration` in the nested function source and in the
  procedure's `helpers.ordinarySource`.
- **Array-type helpers.** Typed trees `arrayTypeAtBody` and
  `arrayTypeDeclarationBody`; `interpreted_arrayTypeAt`,
  `interpreted_arrayTypeDeclaration`; source check `candidate_array_type_helpers`
  reaches `CheckedSource.arrayTypeHelpers` through `actual_array_type_helpers`
  (`ComposeSourceChecks.lean:40`, `ComposeSourceBridge.lean:44`, `:71`). Their
  legality is proved, not assumed (`ComposeEvaluation.lean:1449`, `:1454`).
- **Procedure metadata uses the type table of the same scan.** `selectTypes`
  (`ProcedureMetadataMeaning.lean:15`), `meaning_catalog` (`:124`),
  `executable_catalog`, and `actual_source_correspondence`
  (`ProcedureMetadataSourceBridge.lean:36`) all state the catalogue against
  `selectTypes … text`.
- **Local initializers precede view installation.** Confirmed in Ada and in the
  model (3.1). Type-based queries are visible in callable locals because the
  frame keeps the outer type table; formal-based queries are not.
- **Retained String, Character, Image, Boolean and subtype paths.** Each reader
  that now receives the table gained the matching `lookupType` check in the
  model and uses `arrayTypeLookup` from the derived imports
  (`ComposeHelperEquations` changed lines for `callAfter`, `image`, `value`,
  `newName`; `ComposeBooleanDeclarationNative` `Lookup.arrayType`).

**Coverage limits.** Of the ten new `FunctionSourceParts/*` check files I read
two (`CallsArrayActual`, `DeclarationHeaderAppendArrayParameterSpec`) plus the
one-line change in `DeclarationTypeResult`; the other eight have the same
22-line shape and were not opened. `ComposeBooleanDeclaration*`,
`PredicateNativeState` and `PredicateNativeExpressions` were read at
changed-definition level. `PredicateStringBoundsSources` and
`PredicateStringActualInitializers` were read at changed-statement level.

### 3.4 Composition to both endpoint guarantees

**Result: no new endpoint premise, and every new intermediate premise has a
supply.** Disclosures I1, I2 and I5.

- **Endpoint unchanged in statement and in definition.** Twenty modules are
  byte-identical to the base: `Current`, `PredicateCorrespondence`,
  `PredicateSourceBridge`, `PredicateComposition`, `PredicateExecution`,
  `PredicateChecks`, `PredicateChecking`, `PredicateStatements`,
  `PredicateSyntax`, `IntegerExpressions`, `IntegerChecks`, `IntegerArrays`,
  `IntegerMutable`, `SequenceEffects`, `ScalarFunctionComposition`,
  `ScalarProcedureComposition`, `PredicateSelectors`, `PredicateEquations`,
  `PredicateOuterEquations`, `Audit`. So what `Program.Valid`, the obligation
  set and execution mean did not move; what changed is how a source obtains its
  meaning.
- **New intermediate premises and their supply.**

  | Premise | Supplied by |
  | --- | --- |
  | `CallableTypesKnown state` | `initial_callable_types_known` at `PredicateGrammar.lean:100` and in `meaning_catalog`; preserved by `MixedDeclarationsAt.callableTypesKnown` (`ProcedureDeclarationTrace.lean:164`), `functionDeclarationAt_callable_types_known`, `procedureDeclarationAt_callable_types_known` |
  | `state.StoredArrays` | Grammar invariant (3.1) |
  | `ClosedFunctionContext context descriptors` | Derived from `arrayDescriptors` and `arrayViewKinds` in `FunctionBodySource` and `ProcedureDeclarationMeaning` |
  | `names.length ≤ scalarLimit` on constraint and declaration lemmas | Valid-environment capacity |
  | `TypeCoherent` in the array-add domain | `IntegerArrayHeaderAt.coherent` |
  | `ArrayAppendMeaning calls` (procedure path) | Derived by `array_append_meaning` (`ProcedureDeclarationParameterLibraries.lean:171`) from the function library's `interpreted_appendArrayParameter` |

- **Obligations.** A type declaration contributes its bound and component
  obligations (`ArrayTypeDeclarationChecksAt`, `InitializerChecksAt.arrayType`).
  A named object contributes no header obligations because the type already
  carried them (`ArrayHeaderChecksAt`, `ComposeArrayChecks.lean:54`;
  `arrayHeader_checks_discharge`, `:76`). Expression safety and discharge for
  the table reader come from `ArrayGrammar.at_safe`
  (`ScalarArrayGrammarRecognition.lean:170`).
- **Constructor rendering and precedence.** I compared `eval` with the Ada text
  and `render` with the Ada tokens for the new and changed constructors in the
  array-binding, attribute (imperative body), scalar-expression, Compose,
  function-declaration, loop, call, procedure and array-body trees. One case
  needed care and is correct: `procedureFormal` evaluates to the Lean record
  order `(first, after, kind, bounds, mode, typeId)` while rendering the Ada
  order `(…, Type_Id, Mode)`. No mismatch found.
- **Escape hatches.** No `axiom`, `sorry`, `native_decide`, `unsafe`,
  `implemented_by`, `opaque` or `partial def` in the added non-certificate
  proof lines (one comment contains the word "admit").

**Coverage limits.** The three large trace families (`ComposeScalarTrace`,
`ComposeInitializerTrace`, `ComposeBooleanRegionTrace`) were read at the level of
their changed inductive constructors and first statements; `declarations_unique`
and the other bodies were not followed. `Sequence*Trace` other than
`SequenceMixedTrace`, `PredicateBodyMeaning`, `PredicateBasicReadings`,
`PredicateScalarGuardMeaning`, `PredicateProcedureBodyShape` and
`PredicateFunctionFlags` were read at changed-definition level only.

### 3.5 Feature-local report capacity

**Result: the "zero additional term" conclusion holds; no missing multiplicity
found.** One evidence limit, I4.

- **Producer identity.** All six retained producer files hash to the values in
  `docs/named-array-parameters-report-capacity.md` (recomputed twice).
- **Routes read in the pinned sources.**

  | Claim | Source read |
  | --- | --- |
  | An `in` array actual is one `Transform_Expr` to the formal type | `gnat2why-expr.adb:4393–4600` |
  | Same-type conversion is the identity; at most one length check for a constrained target | `why-gen-expr.adb:1120–1170`, `1425–1470` |
  | `First`, `Last`, `Length` come from index metadata, with a prepended check only for modular index types | `gnat2why-expr.adb:19900–20095` |
  | A type declaration with static bounds and a subtype-mark component emits no check | `gnat2why-expr.adb:22885–23010`, `3705–3731` |
  | A type gets its own obligation theory or owned entity only under six predicates (default checks, iterable, access-to-subprogram, non-predefined equality, aggregate annotation, ownership) | `gnat2why-types.adb:1100–1145`, `spark_definition.adb:2313–2389` |
  | Unused-object and ineffective-import advisories are one per entire variable | `flow-analysis.adb:1200–1445` |
  | A bounds query on a constrained array uses the variables of the type's bound expressions, not the prefix object | `flow_utility.adb:3894–3975` (retained in the same directory; not in the account's hash table) |
  | The array-initialization advisory needs writes or `out` actuals and recognises `S'Range` loops | `flow-control_flow_graph.adb:3760–3860`, `3960–4110` |

- **Arithmetic reproduced** (`scratch/work/capacity_check.py`): 3,006 checks;
  Main 15,142,912; loop advisory `floor(S²/(4·24·8)) = 21,845`, exact maximum of
  `L·W` under `24L + 8W ≤ 4096` also 21,845; function envelope 33,149,440;
  procedure 38,186,752; with unused outputs 48,676,608; combined 49,279,744;
  allocation 67,108,864; headroom 17,829,120.
- **Minimal spellings recounted.** `(X:in T` 7 bytes, `A:T:=(0,0);` 11,
  `type T is array(0..0)of S;` 26, `for I in A'Range loop` 21, `P(X);` 5. They
  give at most 585 formals, 128 callables, 819 calls, 372 named objects and 157
  types in 4,096 bytes, so the 170-entry type table cannot fill.
- **Multiplicities.** Each array actual is charged within its own delimiter and
  token bytes. Queries are static atoms without their own check. A Range loop is
  longer than the loops already charged. A type declaration adds no check or
  entity record. An array formal adds at most one advisory, already charged per
  formal; this includes a formal used only through bounds queries, which flow
  analysis treats as unused. Callables contain no array writes, so the
  array-initialization term is unchanged. Named objects are always initialized
  at declaration and formals need no initialization record.
- **Corroboration from retained output.** The retained complete native report
  for `Silver_Array_Bindings` (SHA-256 `48ab71dd…`, equal to the provenance
  record of run `20261121T191055-5cced625eb47`) covers three constrained array
  type declarations, one of them an array of an Integer subtype
  (`Element_Array`). Its 19 entities and 14 SPARK-status entries are all
  subprograms and the package; there is no type entity. The retained regression
  includes callables whose array formals are used only through `'Length`
  (`tests/test_array_parameters.py:79–88`, `:170–172`); I read the test sources
  and did not re-run them.

**Coverage limits.** I did not read the whole producer; I read the routes the
account cites and the neighbouring code. Two routes are decided on retained
output rather than source (I4): the anti-aliasing check, and the definitions of
two of the six type predicates. No maximal-program run was made or requested.

## 4. Findings, ranked

All five are info-level.

### I1 — Array value-transport and slot-disjointness lemmas do not feed the endpoint

*Classification: side lemmas, disclosed. Not a gap.*

**Evidence.** These seven theorems have no reference outside their own two
files (whole-tree search):

- `NamedArrayParameters.lean`: `formal_disjoint` (:135), `bind_preserves_scalar`
  (:157), `bind_read` (:189), `capture_bind` (:208).
- `ScalarFunctionFrame.lean`: `bindArrayArguments_preserves_before` (:50),
  `capture_bound_parameter` (:73), `capture_after_scalar_arguments` (:122).

They state that a callee view reads exactly the captured actual, that repeated
actuals in different slots do not disturb each other, and that scalar binding
leaves captured arrays intact. The endpoint needs none of this. It uses only
that the captured actual lies in the formal's component interval
(`capture_of_checked_ranges`) and that binding preserves range fit
(`bindArrayArguments_fits`). `bind_declared_fits` rewrites ranges and cells
together, so fit survives any slot layout.

**Impact.** None on the guarantees. This is the design the feature asks for:
body reasoning over full declared component intervals. The consequence worth
knowing is that the forwarding and repeated-actual behaviour of the execution
model is certified by reading `capture` and `bind` (both are plain by-value
copies, which I confirmed), not by a theorem the endpoint depends on.

**Minimal repair.** None required. If the project wants the stage record in
`docs/named-array-parameters.md` ("disjoint virtual formals and read-only
forwarding proved") to be unambiguous, add that these are model-consistency
lemmas outside the endpoint chain.

### I2 — Array-table validity equivalences and the new `validNameState` law are side facts

*Classification: `validNameState` is a valid trusted premise; the equivalences
are side lemmas, disclosed. Not a gap.*

**Evidence.**

- `ArrayBindingsSourceBridge.lean:46–64` (`PredicatesCorrect`,
  `interpreted_predicates`) and `:66–104` (`ImplementationCorrect`,
  `interpreted_complete`) prove that the Ada bodies of `Valid_Binding`,
  `Valid_Types`, `Valid_Metadata` and `Valid_Environment` equal the Lean
  predicates. Only `PredicatesCorrect.validType` is consumed elsewhere
  (`FunctionDeclarationFrameEquations.lean:41–52`).
- `Primitives.validNameState` (`ArrayBindingsNativeEquations.lean:38–39`) is a
  field added by this PR. Its only uses are in the same file: `:356–357`
  (helper `name_test`), `:373` (`validTypes_meaning`), and `:411` and `:427`
  (`validMetadata_meaning`).
- The law is `calls.validNameState text first after = decide ((first = 0 ∧
  after = 0) ∨ NameSpan text first after)` for `first, after ≤ 4097`. The Ada
  function is `Silver_Output_Lexical.Valid_Name_State`
  (`src/silver_output_lexical.ads:268–274`), an expression function with exactly
  that body, in a file unchanged by the PR. 4097 is the whole `Literal_Position`
  range, so the domain was not widened; the PR only calls the function on type
  names as well as object names.
- The same law was already a `Primitives` field of the function and procedure
  binding bridges at the base. There is no typed tree or source check for
  `Valid_Name_State` itself anywhere in the proof, and it is not named in
  `docs/trusted-boundary.md`.

**Impact.** None on the guarantees: the endpoint never evaluates
`Valid_Metadata`; it uses the Lean predicates as the stated domains of the
source-checked equations. The equivalences are the only machine-checked
statement that those Lean domains are the Ada predicates, and that statement is
conditional on one assumed law about a three-line Ada function.

**Minimal repair.** None required. Optional: name `Valid_Name_State` among the
unchanged lexical callees in `docs/trusted-boundary.md`, or give it a typed tree
and source check like its callers so that the law is derived.

### I3 — Leaf import laws still assumed; one redundant re-assumption

*Classification: valid trusted premise (documented convention), disclosed.*

**Evidence.** After #414 the three array imports and both Boolean-wrapper
meanings are derived. Still assumed, unchanged by this PR:

- `RawHelperEquations` fields supplied by `definitions`: `scalarLookup`,
  `booleanHidesInteger`, `booleanLookup`, `scalarLiteral`, `scalarAppend`,
  `scalarEmpty`, `nameIs` (`ComposeContracts.lean:394–426`).
- The leaf `Primitives` records in 3.2.
- Link identities between libraries, such as `calls .appendArrayParameter =
  ordinary .appendArrayParameter` (`ProcedureDeclarationParameterLibraries.lean:15–28`).

New consumers of the inherited laws in this PR: `interpreted_arrayTypeAt`
(`scalarLookup`, `booleanLookup`) and `interpreted_arrayTypeDeclaration`
(`nameIs`, `scalarEmpty`).

The nested callable record `FunctionDeclarationNative.InterpretedSource.inheritedSource`
re-assumes `functionLookup`, `procedureLookup`, `formalHides`, `imageMinimum`
and `imageMaximum` for the same `calls`, although the root derives them;
`inherited_import_source` patches only the three array imports and
`booleanDeclaration`.

**Impact.** None. Each re-assumed law follows from the root record, so the
nested assumption is redundant, not stronger. The assumed leaf laws are the
project's documented frontend-interpretation premise.

**Minimal repair.** None required. Optional: extend `inherited_import_source`
to supply the five re-assumed laws from the root, which would make the nested
record's assumptions visibly empty.

### I4 — Capacity: two producer routes are decided on output, not source

*Classification: evidence limit. The stated conclusion stands.*

**Evidence.** A procedure call that passes an array `in` actual (not a by-copy
type) together with writable scalar actuals is the one new shape that could make
the producer emit a non-aliasing flow record per call. The file that decides
this, `flow-analysis-antialiasing.adb`, is not among the retained producer
files and is not on this host.

I rejected the multiplicity on retained evidence instead. All 78 reports of the
complete native run `20261121T191055-5cced625eb47` (19,994 checks) contain no
`ALIASING` record and an empty "Non-Aliasing" summary row, although the compiler
sources they cover call `Skip_Trivia (Text : String; Position : in out Cursor)`
and `Match_Identifier` (a `String` input with `in out` and `out` scalars) many
times. The retained #370 procedure probe report shows the same.

The second route is smaller. Whether a type receives its own obligation theory
or owned entity is gated by six predicates (`gnat2why-types.adb:1108–1141`,
`spark_definition.adb:2313–2389`). Two of them, `Use_Predefined_Equality_For_Type`
and `Needs_Default_Checks_At_Decl`, are defined in a producer file that is not
retained, so I could not read that an array of Integer satisfies neither. The
retained `Silver_Array_Bindings` report described in 3.5 shows no type entity
for three such declarations.

**Impact.** Affects only the confidence basis of two sentences in the capacity
account. Neither can change its conclusion. If the producer emitted one record
per call with an array actual, the bound is 819 calls; if it emitted one per
named type, the bound is 157 types. Even at 1,024 bytes per record (the
allowance the procedure account uses for initialization records) that is under
1 MiB in total against 17,829,120 bytes of headroom.

**Minimal repair.** Retain `flow-analysis-antialiasing.adb` and the file
defining the two predicates with their SHA-256 values, or add the fallback
bound above to the account.

### I5 — Ten new theorems are referenced nowhere

*Classification: housekeeping.*

**Evidence.** A textual scan of the 48 added files
(`scratch/work/unused_new_theorems.py`) finds ten theorems with no reference
beyond their own declaration, none tagged `@[simp]`: `validType_domain`,
`viewDescriptor_nominal` (`ArrayBindingsMetadata`);
`array_type_declaration_unique` (`ComposeArrayTypeDeclarations`);
`declarationsAt_stored` (`ComposeStoredArrays`); `Domain.length_positive`,
`bind_preserves_scalar`, `bind_read` (`NamedArrayParameters`); `flow_model`
(`PredicateArrayViews`); `selectedQuery_range` (`ScalarArrayAttributes`);
`lookup_invalid` (`ScalarExpressionNativeDefinitions`). The scan is by short
name, so it can miss a use only through an unusual notation.

**Impact.** None. **Minimal repair.** Remove them or leave them; no assurance
statement depends on either choice.

## 5. Rejected candidates

| Candidate | Why it was raised | Why it is rejected |
| --- | --- | --- |
| Non-aliasing flow records per procedure call with an array actual | New call shape for the producer | No such record in 78 retained complete reports whose sources have the same shape (I4) |
| `catalogSignatures`, `signatureModel`, `formalModel` default `types := []` could resolve a nominal formal against an empty table | New optional parameter; this is the shape of the earlier procedure-metadata defect | Every use I found passes an explicit table; the endpoint-facing statements use `selectTypes … text` or the state's own table |
| `ArrayAppendMeaning` looked like an assumed equation on the procedure path | New hypothesis record | Derived by `array_append_meaning` from the function library |
| `P (A, A (1))` would violate SPARK anti-aliasing yet be admitted | Array `in` formal with a writable scalar | `Procedure_Target_Actual` (`silver_output_profile.adb:5727–5769`) admits only a bare scalar or Boolean name as a writable actual and rejects a formal with `Type_Id /= 0`; outer arrays are invisible inside callables, so no global can alias |
| Attributes are read even in `No_Elements` (subscript) and `Mutable_Elements` (counted-bound gate) modes | Mode guard sits after the attribute branch | Intended and sound: a bounds query is static and reads no component; the model has the same order |
| `X'Length` of a formal in a callable-local initializer might resolve to something else | Views are not yet installed there | The frame has no array objects and a formal cannot share a name with a type, so the read is rejected; conservative |
| `installArrayView` evaluates as `names.take (index - 1) ++ [binding]`, which is not a general array update | Typed-tree `eval` differs from the Ada delta aggregate in general | Its only use binds `index` to `count + 1`, where the two agree |
| Counted-bound gate reads with empty `Initials` | Looked like a lost elaboration fact | Pre-existing, modelled exactly, and the gate's bounds are not used |
| A Boolean array object could hide a type name in the attribute prefix | Object lookup precedes type lookup | A valid table cannot hold an object and a type with the same name |
| A formal used only through `X'Length` is "unused" to flow analysis and would add a new warning class | `flow_utility.adb:3894–3975` takes no variable from the prefix of a constrained array | It is the existing unused-formal advisory, one per formal, already reserved; retained passing tests cover the shape |
| The capacity loop term uses a 24-byte minimum that an 11-byte named declaration undercuts | Shorter new declaration form | The 24 bytes are the loop's own prefix and `end loop;`; the flow allowance is per source vertex |
| Reads of `Types.Items (Id)` beyond `Count` could see stale Ada data that the Lean list does not model | Record-with-array against list abstraction | Every read is guarded by `Id <= Count`, and entries beyond `Count` are never written |

## 6. Not re-executed and not verified

**Not executed.** No Lean build or kernel replay, no GNATprove run, no compiler
build, no regression, bootstrap or Rosetta run, no compiled probe. The retained
audits (native `20261121T191055-5cced625eb47`, Lean
`20261121T215449-12cec2fc5976` on endpoint `7f449246ce`, final regression) were
used as context and, for I4, as evidence. They are cached or incremental
complete audits, not cold replays. `proof/` and `src/` are identical between
that endpoint and the target (verified with Git); the four later commits change
other paths only.

**Proof text not read.** Per-file record in `scratch/work/coverage-map.tsv`.

| Class | Files | Added lines | What was not read |
| --- | ---: | ---: | --- |
| Target text read in full | 45 | 5,252 | — |
| Complete diff read | 68 | 3,291 | Unchanged parts of the file |
| Partly read | 13 | 1,994 | The ranges named in section 3 |
| Changed declaration statements only | 30 | 3,910 | All tactic bodies |
| Changed definition headers only | 175 | 2,144 | Theorem statements and bodies |
| Not opened | 8 | 1,668 | `OutputBodyLines0–7`, generated token tables |
| Not opened | 8 | — | Generated certificates |

The 175 "definition headers only" files were scanned mechanically
(`scratch/work/changed_statements.py`, output in
`not-opened-changed-definitions.filtered.txt`); what I saw there was propagation
of the table type, the `typeId` field and the `arrayType` trace constructor.
A changed theorem statement in those files that adds a hypothesis would not have
been seen unless it also changed a definition.

**Could not verify.**

- That the generated certificates and `OutputBodyLines*` equal the Ada sources
  token for token. This is what the `decide +kernel` source checks establish
  under the retained Lean audit.
- Faithfulness of the Lean model to Ada and SPARK semantics beyond reading. I
  found no divergence for attribute values and staticness, component intervals,
  index containment, nominal typing, Range loops, parameter passing and hiding,
  but this is the trusted modelling boundary and no theorem covers it.
- The anti-aliasing producer source and the definitions of two type
  predicates (I4).
- ARM64 and macOS; nothing in this review is platform-specific.
- `src/silver.adb` and `src/silver_catalogue.adb`, which are outside the five
  proof areas.

## 7. Outputs

All in `/home/canto/src/github.com/berkeleynerd/silver/tmp/external-proof-review-pr412-5a4b0ad8ac/`:

- `report.md` (this file), `status.md`, `interim-findings.md`, `questions.md`
- `scratch/work/coverage-map.tsv` — per-file coverage class
- `scratch/work/capacity_check.py` — envelope arithmetic
- `scratch/work/unused_new_theorems.py`, `changed_statements.py`,
  `coverage_map.py` — the reference scan, statement extractor and coverage join
- `scratch/work/not-opened-changed-definitions*.txt` — extractor output
- `scratch/producer-probe-selected/` — the extracted retained #370 probe report

Nothing was written outside that directory. No source, test, proof, pin, branch,
issue or pull request was changed, and nothing was published.
