# Inherited interface field map

Companion to the [review](../../../reviews/review-inherited-interfaces-74ea2edeaa.md),
2026-11-09, #364/#366. Line locators refer to reviewed `74ea2edeaa`, except
the explicitly identified repair in `BooleanBindingsNative.lean` at `4a95d7d782`.
`OP` below means `src/silver_output_profile.adb`; other paths are stated in full
or are under `proof/Silver/`. The [inventory](interface-inventory.json) records
all own fields mechanically; the relationships below are review conclusions,
not an automatically proved Ada-to-Lean translation.

## Representation and domains

An Ada String is interpreted with the native one-based bounds; `Source` records
its character values and length. `ValidText` states length `1 .. 4096` and
`ValidCursor` allows zero or a position through `length + 1`. Positive `Cursor`
parameters additionally require positivity. Active native record counts become
list lengths; record lookup remains one-based. `Scalars.Value` is interpreted
inside the fixed Integer range. Character, enumeration, and fixed-array types
also restrict represented native values even where a mathematical function is
total on a larger Lean type. Unrepresented values are not arbitrary Ada calls.
This is the documented frontend/totalization boundary, not a premise that every
Lean natural number or list is representable.

| Domain/representation | Actual relationship checked |
| --- | --- |
| `ComposeBounds` predicates assembled as `ComposeContracts.ValidState:17–27` | Cursor, String table, dynamic-name pair, target/capacity, scalar/array/subtype/Boolean/function metadata, and formal-prefix bounds match the respective fields of `Parser_State`; the base alone is insufficient for current `OP:297–309`. |
| `PredicateOuterReadiness:18–32`, `PredicateScalarHeaderReady:11–14` | Adds nonempty declared scalar bounds and mutable bounds contained in declared bounds, matching `Valid_Declaration_Values` and `Valid_Mutable_Bounds` at `OP:283–309`; preserves them when scalar/String tables are unchanged. |
| `NativeNames.base/bounds`; `NativeState.base/bounds` | `ValidNames` supplies active count, source spans and capacity. `NamesBoundsValid` adds machine-range first/last indices and exactly `Fixed_Bounds_Valid`, including Character singleton, dynamic length zero, arbitrary null bounds, and nonempty slot ceiling (`ComposeBindingBounds:13–31`, `OP:142–175,203–213`). |
| `NativeValue.base/operands/firstIndex/lastIndex`; `NativeResult.base/firstIndex/lastIndex`; `NativeScan.base/firstIndex/lastIndex` | `ComposeBounds:30–43` plus bounded interval endpoints match `Value_Result`, `Expression_Result`, `Expression_State` and `Valid_Expression_State` (`OP:614–620,1090–1126`). Capacities, reference count, operand count, dynamic count, depth and cursor constraints are not inferred solely from a successful parse. |
| `ArrayBindings.ValidBinding/ValidMetadata/ValidInitials/ValidEnvironment` | Positive length, nonempty index/component intervals, exact index span, offset capacity, ordered descriptors, bounded cell values, count, and allocated end ≤ used (`ArrayBindings:112–133`; `src/silver_array_bindings.ads:13–72`). Native adjacent ordering and positive lengths imply the Lean pairwise ordering. The finite zero-extended `Initials` list can represent all 2048 native cells. |
| `ArrayValuesDomain.sourceContext/resultContext/positionValid/parsedBound/capacity/used` | Both native states valid; cursor bounded; parsed ≤ length; length ≤ max elements − source used; result used = source used + parsed (`OP:1786–1796,1837–1848,1973–1983,2081–2092`). No additional initialized-prefix or component-fit restriction is assumed. |
| `ArrayAddDomain` | Last descriptor's end ≤ new offset; existing validity supplies order for earlier descriptors (`ComposeContracts:218–219`; `OP:1641–1663`). |
| `PredicateNativeState.ValidContext`, `ContextReady` | All `Body_Context` fields, table/target/capacity bounds, masks/hiding, declaration bounds and elaborating/body distinction (`PredicateNativeState:19–51`, `PredicateFlowInvariant:34–40`; `OP:2528–2538,2645–2659`). |
| `ValidFlow`, `FlowReady`, `ValidResult` | Bounded path fields; vector count = scalar count; immutable bounds equal declaration values; mutable bounds contained in declarations and nonempty; both result flows valid (`PredicateNativeState:80–81`, `PredicateConditionFlowValidity:15–21`, `PredicateNativeCorrespondence:14–15`; `OP:2660–2680,3013–3023`). |
| `BodyNative.ValidScan`, `Controls` | Position, target and capacity bounds plus valid flow (`PredicateBodyCorrespondence:21–22`, `PredicateBodyControls:13–14`; `OP:2673–2680`). Catalogue validity is separately retained in every body equation. |

## All 14 structures in ComposeContracts

| Structure | Own fields and status |
| --- | --- |
| `StateDomain` | `holds`, `valid`, `transportScalar`: abstract caller invariant and preservation rule; current instantiation is `OuterReadiness.domain`, not `.basic`. |
| `NativeNames` | `base`, `bounds`: table domain above. |
| `NativeState` | `base`, `bounds`: caller domain plus exact String-table invariant. |
| `NativeValue` | `base`, `operands`, `firstIndex`, `lastIndex`: value record domain above. |
| `NativeResult` | `base`, `firstIndex`, `lastIndex`: expression result domain above. |
| `NativeScan` | `base`, `firstIndex`, `lastIndex`: expression traversal domain above. |
| `Context` | Evaluator locals, not an assumed contract. All 41 fields are assigned by `Context.locals:162–193`; see the grouping immediately below. |
| `ArrayValuesDomain` | All six fields mapped above. |
| `HelperRanges` | All 17 fields mapped in the next table. |
| `RangeContracts` | Inherits `HelperRanges`; own `step` is the historical `.basic` interface. It is not the current bridge's `step` premise. |
| `RawHelperEquations` | All 66 own fields mapped below. |
| `HelperEquations` | Inherits raw equations; `functionDeclaration`, `booleanInitializer`, `booleanDeclaration` are derived by the current bridge, not scanner-meaning assumptions. |
| `LegacyHelperMeaning` | `argument`, `declarations`, `target`, `dynamic`, `assignmentValue`, `output`, `comparison`, `capacity`: independent historical fixed-form mathematical meanings. No current-native clearance is attributed to these broader-domain fields. |
| `DefinitionEquations` | Inherits helper equations; `legacy`, `stepRange`, `step`, `suffix`, `formMember`, `member`, `arguments`, `assignment`: historical fixed-shell equations, explicitly separate from the present native statement scanner. |

`Context` field groups checked against `Context.locals` and native argument names:

- Source/cursors/counters: `text`, `position`, `first`, `after`, `index`, `length`,
  `remaining`, `following`, `limit`, `depth`, `nextToken`, `slot`, `capacity`.
- Tables and values: `names`, `scalarNames`, `booleans`, `arrays`, `initials`,
  `subtypeNames`, `state`, `value`, `result`, `scan`, `baseBounds`, `firstIndex`,
  `lastIndex`.
- Tags and flags: `chained`, `ending`, `elaborating`, `characterElement`,
  `characterObject`, `isCharacter`, `form`, `token`, `operation`, `arguments`,
  `mutable`, `sameTarget`, `dynamicSeen`, `integerHidden`, `subtypeHidden`.

### HelperRanges: every assumed consequence

All rows carry the corresponding source/cursor/table/value/state domain above.
The relation is equality of the needed property or a projection of the native
contract plus native return type; no row substitutes a model validity proof for
the native postcondition.

| Field | Native routine/contract | Lean consequence supplied |
| --- | --- | --- |
| `skip` | `Skip_At`, OP:332–337 | Cursor ≤ last + 1. |
| `name` | `Name_After`, OP:348–354 | Zero or advancing bounded cursor implies requested cursor bound. |
| `token` | `Take_Token`, OP:412–419 | Same cursor projection; `ValidToken` selects actual native token constructors. |
| `lookup` | `Lookup_Name`, OP:452–462 | Result ≤ active name count. |
| `literal` | `Literal_At`, OP:626–645 | After/value-first bounds from Post; other `NativeValue` ranges from record types. |
| `image` | `Image_At`, OP:995–1009 | After/value-first bounds and native record ranges; array values remain a separate fixed-array input. |
| `value` | `Value_At`, OP:1043–1059 | Same full record-domain conclusion. |
| `stringDeclaration` | `String_Declaration_At`, OP:1589–1596 | Valid state and zero-or-strict progress. |
| `subtypeDeclaration` | `Subtype_Declaration_At`, OP:1447–1454 | Valid state and zero-or-strict progress. |
| `scalarType` | `Scalar_Type_At`, OP:1417–1425 | Bounded after, machine interval endpoints, nonempty interval on success. |
| `scalarDeclaration` | `Scalar_Declaration_At`, OP:1501–1511 | Valid state and zero-or-strict progress. |
| `arrayDeclaration` | `Array_Declaration_At`, OP:2184–2192 | Runtime Post: valid state and zero-or-strict progress. |
| `declaration` | `Declaration_At`, OP:2300–2307 | Valid state and zero-or-strict progress. |
| `argument` | `Argument_At`, OP:2324–2328 | Valid state. |
| `declarations` | `Declarations_At`, OP:2353–2359 | Valid state. |
| `expressionStep` | `Expression_Step`, OP:1164–1181 | Valid expression state; zero, complete, or strict progress. |
| `expression` | `Expression_At`, OP:1269–1288 | After bound from Post and remaining `NativeResult` ranges from record types. |

### RawHelperEquations: all 66 own fields

The equations below are interpreted body/refinement premises. Their consistency
is proved separately by model witnesses. Exact-source bindings are transported
by `ComposeSourceChecks:36–76` from expression, contract, helper and Boolean
candidates to the authoritative complete output source. `ComposeExpressions`
maps call names at `:131–216`, fields at `:546–614`, and aggregates/defaults/counts
at `:1025–1145`. `ComposeStringNative` supplies ordinary sequencing/assignment/
early-return semantics; `ComposeArrayDeclarationSource` supplies the ordinary
array declaration's constant initializer/return wrapper. These evaluator
connections, not just the token pins, were part of the comparison.

| Field(s) | Native counterpart and specific connection |
| --- | --- |
| `ranges` | The 17 Post/type projections above. |
| `names` | `Names.InterpretedSource`: imported checked name/context/library-operation source meanings. |
| `functionLookup`, `formalHides` | `silver_function_bindings.ads:64–83` lookup model/refinement; `Formal_Hides`, OP:319. Current bridge obtains them from directly linked metadata/visibility interpretation. Function internals retain their separate review. |
| `fixedBounds` | `Fixed_Bounds_Valid`, OP:166–175; exact expression with bounded Integer endpoints, capacity and positive bounded slot. |
| `characterLiteral` | `Character_Literal_After`, OP:663–676; exact graphic-ASCII triplet and bounded cursor. |
| `guardedAt` | `Guarded_At`, OP:682–722; positive cursor, bounded limit/depth; exact quote/Character/comment skipping and token-region state. |
| `indexed` | `Indexed_At`, OP:727–808; typed ordinary body, same arrays/initials/elaborating/Character-element argument; all type/value domains retained. |
| `characterValue` | `Character_At`, OP:810–865; grouping, literal, named Character and indexed fallback; final named argument is `Character_Element => True`. |
| `concatenatedFirst`, `concatenatedLast` | OP:1128–1162; exact null-left and interval branches; wide arithmetic interpreted mathematically with bounded native inputs and checked conversions. |
| `addBindingWithCharacter`, `addBinding` | `Add_Binding`, OP:1355–1376; same append/update, explicit Character flag versus default False; capacity and exact new-slot `fixedBoundsValid` premise retained. |
| `characterDeclaration` | `Character_Declaration_At`, OP:1548–1587; ordinary body and `Character_Object => True`, exact table/hiding inputs. |
| `scalarLookup`, `scalarRead` | `silver_scalar_expressions.ads:50–59,83–98`; checked lookup/refinement and expression source bridge. Read uses zero mask, sign enabled, and explicit arrays/initials/elaboration. |
| `booleanHidesInteger`, `booleanLookup` | `Boolean_Hides_Integer`, OP:575–581; `Lookup_Boolean`, OP:545–573; separate Boolean binding source bridge and active-prefix quantifier. |
| `arrayLookup` | `silver_array_bindings.ads:83–92`; native model/refinement on complete descriptor metadata. |
| `scalarLiteral` | `silver_scalar_literals.ads:28` `Read_Integer`; imported checked literal source meaning. |
| `scalarAppend` | `silver_scalar_expressions.ads:60–63` `Append`; count < maximum, count+1 and exact active-prefix append. Broader mathematical record arguments are totalizations, not a claim that arbitrary unbounded records are native values. |
| `scalarEmpty` | `silver_scalars.ads:14` `Is_Empty`; bounded interval. |
| `imageMinimum`, `imageMaximum` | `silver_integer_image.ads:21,27`; independently checked integer-image source interpretation, linked on bounded intervals. |
| `nameIs` | `silver_output_lexical.ads:134–139`; valid positive span and nonempty word length ≤ 16 (hence ≤ native 4096). This is distinct from the repaired Boolean primitive. |
| `callAfter` | `Call_After`, OP:583–612; same operation, scalar/array/Boolean tables and subtype-hiding argument. |
| `skip`, `name` | OP:332–364 executable Static equalities to trivia/identifier helpers with zero sentinel branch. |
| `fixed`, `take` | `Fixed_After`, OP:366–379; `Take_Token`, OP:412–433 refines that same expression. |
| `lookupFrom`, `lookup` | OP:435–481; ascending String-table search from positive index ≤ count+1; invalid-span gate and executable refinement retain active count. |
| `literal` | OP:626–661; exact native Static literal-result equality, including default operand/index fields. |
| `workTail`, `workBudget` | OP:872–910; bounded remaining work and exact whole-source budget wrapper. |
| `image`, `value` | OP:995–1088; exact checked expression bodies with scalar hiding and all array/elaboration arguments. |
| `newName` | `New_Name_Allowed`, OP:1333–1353; state and arguments flag unchanged. |
| `stringDeclaration` | OP:1589–1633; exact expression body with native state domain. |
| `scalarConstraint` | `Scalar_Constraint_At`, OP:1382–1415; bounded base interval, cursor and scalar environment. |
| `subtypeLookupModel`, `subtypeLookup` | OP:483–527; descending index ≤ count; runtime equality starts at full active count. |
| `scalarType`, `subtypeDeclaration`, `scalarDeclaration` | OP:1417–1546; same native type/constraint calls and record append/hiding updates, including Boolean true/false and operation-name marks. |
| `arrayAdd` | OP:1641–1663; valid binding, capacity, allocated end, last-descriptor ordering and following cursor exactly retained. |
| `arrayPut` | OP:1635–1639; used < maximum and bounded Integer value; increments used and updates that cell. No unneeded full-state validity premise imposed. |
| `arrayValuesModel`, `booleanArrayValuesModel` | OP:1786–1835,1837–1885; exact recursive body and full `ArrayValuesDomain`, plus component interval or masked-name domain. |
| `arrayValues`, `booleanArrayValues` | OP:1973–1998,2081–2107; exact executable Static equality to corresponding model, with unchanged original/result state and parsed counts. |
| `arrayDeclaration` | OP:2184–2277; checked ordinary constant initializer/return body denotes `arrayDeclarationBody true`; the separately checked ghost body at OP:1895 uses `false`. Runtime initializer calls are not silently identified with ghost callees. |
| `declaration`, `argument`, `declarations` | OP:2300–2365; exact expression bodies and same current state domain. |
| `expressionStep`, `tail`, `expression` | OP:1164–1324; exact step/tail bodies and expression executable refinement; all String/scalar/array/initials/elaboration parameters retained. |
| `fits` | OP:1326–1331; bounded result and capacity, exact fitting expression. |
| `comparison`, `target`, `dynamic`, `assignmentValue`, `output`, `capacity` | OP:2450–2464,2389–2406,2408–2419,2421–2436,2438–2448,2466–2486 respectively; exact native helper bodies on current state domain. These are shared helpers, not the historical shell membership assumption. |
| `readDeclarations` | OP:2367–2387; exact executable refinement to `Declarations_At`. |

## All six ComposeSourceBridge structures

| Structure/fields | Source/semantic connection |
| --- | --- |
| `CheckedSource.imageLengths/scalarExpressions/names/inherited` | Their independently checked source facades; `namesLexical` is the exact equality of imported fixed/take meanings. |
| `CheckedSource.expressions/stringHelpers/arrayHelpers/booleanDeclaration/booleanArrayHelpers` | Actual output-token expression/ordinary-body checks described above, including all helper headers/refinements. |
| `CheckedSource.catalogue/tokens/declarations/refinement/adapters` | Helper catalogue, finite token mapping, declarations, executable refinement, adapter checks; helper catalogue here is distinct from the machine-readable language catalogue reviewed elsewhere. |
| `CheckedSource.arrayLength/arrayLookup/arrayExtension` | `ComposeExpressions.ArrayNames:2328–2359`: active length = count; positive in-range active lookup = native items; extension = append. |
| `BooleanDeclarationInterpretation.source` | Existential native imports/predicate, helper meanings, raw definitions, contracts, and links; typed body equality on `OuterReadiness.ValidState`. `BooleanDeclarationNative.Libraries` derives the declaration meaning. |
| `BooleanInitializerInterpretation.source` | Same predicate links plus context/initial flow/condition call; position and masked-name validity retained. `ComposeBooleanInitializerLibraries:19–81` supplies the domain derivation. Native bodies OP:4435–4499. |
| `FunctionDeclarationInterpretation.source` | Exact inherited calls, declaration call, metadata lookup and formal-hiding identities with the independently reviewed function source interface. |
| `FunctionImportMeaning.lookup/hides` | Only directly linked metadata/visibility meanings; their domains match `RawHelperEquations.functionLookup/formalHides`. |
| `InterpretedSource.imageLengths/lexical` | Links actual imported image and lexical callees; meanings derived from their interfaces. |
| `InterpretedSource.definitions/booleanDeclaration/booleanInitializer/functionDeclaration` | Raw current-domain equations require the subsequently derived function imports; the three declaration/initializer meanings are derived, not primitive scanner equalities. |
| `InterpretedSource.legal/step/stepLegal` | Actual helper call legality and typed `Step` body/legality restricted to `NativeForm` and native tokens; OP:2488–2514. The restriction prevents attributing historical shell tags to current Ada. |

`interpreted_equations:153–217` normalizes imported callees and derives the three
additional `HelperEquations` fields. `interpreted_step:219–248` uses the current
state and native form/token domains. No field consumes historical `DefinitionEquations`.

## Predicate contracts and recursive interfaces

### PredicateNativeContracts.Contracts: all 11 fields

| Field | Native source | Consequence/domain check |
| --- | --- | --- |
| `comparison` | `Scalar_Comparison_At`, OP:2961–2967 | Result cursor bound. |
| `length` | `Length_At`, OP:2988–2995 | Result cursor bound on valid context. |
| `booleanArray` | `Boolean_Array_After`, OP:3239–3247 | Bound and zero-or-strict progress; valid incoming flow. |
| `booleanAtom` | `Boolean_Atom_After`, OP:3271–3278 | Bound and zero-or-strict progress. |
| `primary` | `Primary_Model`, OP:3310–3322 | `Valid_Condition` and zero-or-strict bounded progress. |
| `booleanFactor` | `Boolean_Factor_Model`, OP:3361–3373 | Same. |
| `booleanRelation` | `Boolean_Relation_Model`, OP:3374–3386 | Same. |
| `relation` | `Relation_Model`, OP:3323–3335 | Same. |
| `model` | `Condition_Model`, OP:3297–3309 | Same. |
| `condition` | `Read_Condition_Into`, OP:3659–3670 | Same via observed output with count = input flow count. |
| `tail` | `Condition_Tail`, OP:3604–3619 | Valid result and zero-or-nondecreasing progress; chain enum, original start, incoming flow, initializer array retained. |

`ValidResult`'s stronger-looking bounded flow components come from native
record/vector types together with `Valid_Condition`, not an unsupported stronger
Post. `Initials` validity interprets the fixed array type; it is not an extra Ada
Pre requiring a reachable allocation history.

### PredicateNativeSourceBridge and PredicateNativeCorrespondence

`InterpretedSource.source` checks the actual source; `helpers` supplies imported
callee interpretations; `definitions` supplies raw typed bodies/sizing/worker
refinements; `contracts` is exactly the preceding table. All four fields are
needed to derive normalized recursive equations.

| Normalized equation field | Native body/refinement |
| --- | --- |
| `primary` | `Primary_Model` body OP:3336–3360. |
| `booleanFactor` | `Boolean_Factor_Model` OP:3387–3395. |
| `booleanRelation` | `Boolean_Relation_Model` OP:3396–3409. |
| `relation` | `Relation_Model` OP:3410–3471. |
| `model` | `Condition_Model` OP:3650–3657. |
| `condition` | `Read_Condition_Into` Static equality OP:3659–3670; `Workers.observe` uses the actual output and `facts.count`. |
| `tail` | `Condition_Tail` OP:3620–3648, with original start/incoming retained. |

The underlying `PredicateNativeHelpers.DefinitionEquations` also maps
`characterCondition` to OP:3027–3057; `summary/bound/bindingSummary` to
OP:2949–2955; `comparison/length` to OP:2968–3011;
`chainToken/chainAfter` to OP:3575–3602; `booleanArray/booleanAtom` to
OP:3248–3295. `sized` is `PredicateNativeModelSizing:12–41`, preserving the
native discriminant/vector sizes before a redundant count is projected away in
the evaluator. `workers` carries all six procedure refinements in
`PredicateNativeWorkers:42–62`, corresponding to OP:3659–3709,3799–3821.
The chain wrapper uses `Short_And, False`, `Result'Old`, the separate `Incoming`,
and exact `Original_Start`. Both input flow counts equal the context scalar
count, supplying native `Incoming.Count = Result.Count`.

Imported helper domains were followed through reading-name/flow adapters,
scalar/String readers, String/name/array/Boolean lookup, xor, and scalar
conditions. Path operators explicitly use total mathematical interpretations
of their checked projections; these are not claims about out-of-range Ada
records. `PredicateNativeExpressions.Field.get:352–391`, `Expr.eval:516–568`,
and `PredicateNativeEquations.Inputs.locals:13–42` preserve fields, active
counts, Boolean/chain tags, `Initials` and `Incoming` separately.

### PredicateBodyCorrespondence.Equations: all seven fields

| Field | Native source and dependency |
| --- | --- |
| `statement` | `Statement_Body`, OP:5100–5109,5267–5273; typed dispatch over if/for/basic, same catalogue. |
| `loop` | `Loop_Body`, OP:5110–5119,5275–5395; `PredicateLoopNative` typed ordinary body. |
| `conditional` | `Conditional_Body`, OP:5120–5129,5397–5423. |
| `alternative` | `Alternative_Body`, OP:5130–5140,5425–5459. |
| `tailModel` | `Body_Tail_Model`, OP:5141–5159; checked recursive expression. |
| `tail` | `Body_Tail`, OP:5161–5172; exact Static equality to model on valid scan. |
| `read` | `Read_Body`, OP:5244–5256; exact Static expression combining `Statement_Body`, invalid result and tail. |

All retain valid text/context/scan and catalogue. `PredicateBodyLibraries:20–142`
joins separately checked basic/Boolean/array/flow/wrapper/predicate/loop sources;
it does not assume recursive body equivalence. Boolean assignment sources
OP:4501–4554 and 4697–4740 preserve metadata/flow separation and refine their
checked models.

Loop imports were additionally checked in `PredicateLoopHelpers.Links:43–79`
and `PredicateLoopImports.ImportsMeaning:52–81`: `token`, `bodyToken`, `invalid`,
`skip`, `nameAfter`, `forbidden`, `nameIs`, `equalName`, `arrayTarget`,
`readScalar`, `widen`, `isEmpty`, `normalize`, `join`, `emptyBounds`, `emptyFacts`.
These retain the native helper identities and domains; `readScalar` specifically
links the counted-bound wrapper. `PredicateLoopNative:137–184,217–285,397–466`
preserves all ordinary field copies and the active flow prefix, binder/count
extension, empty/definite path distinction, and constant-array restrictions.

## Scalar, xor and Boolean binding bridges

| Interface field(s) | Checked relationship |
| --- | --- |
| `ScalarExpressionSourceBridge.InterpretedSource.primitives` | Imported lexical/literal/scalar and array primitives retain their native spans, operator-byte and interval domains; array `BindingType` and initializer ranges are explicit. |
| `.definitions.lookupModel/lookup/skip/nameAfter/binaryAfter/symbol/literal/unary/binary/close` | These are fields of its `Native.Equations` payload (`ScalarExpressionNativeEquations:49–70`), tied to the scalar source bodies and exact lookup refinement. Result/literal type predicates include native field ranges. |
| `.definitions.arrayAtom/atom/readUnary/compound/group/expression` | Remaining raw equations (`:71–103`); `src/silver_scalar_expressions.adb:149–344`, specification `:83–98`. Positive active array target; valid mask; unary sign/in-text precondition; compound left-result progress; group positive cursor; arrays excluded from subscripts via native defaults; Boolean tags rejected for Integer reads. |
| Array primitive dependency | `ArrayBindingsNativeEquations:17–50`; `src/silver_array_bindings.ads:73–118` and body: descending lookup, interval contains, offset+1 slot, recursive hull and Read_Bounds refinement. Elaborating reads the initializer hull; body reads component bounds. `ValidInitials` covers arbitrary native cells. |
| `PredicateXorSourceBridge.InterpretedSource.calls/equations` | `XorNative.Equations.characterLiteral/model/runtime` (`PredicateXorNative:163–171`): source Character helper plus exact `Xor_Free_Model` OP:3473–3509 and executable Static equality OP:3511–3516. Position/after may be zero; subtraction/indexing occurs only on guarded native branches. |
| `PredicateXorSourceBridge.Checked.body/precedence/modelSpec/modelImpl/runtimeSpec/runtimeImpl` | Entire model expression, well-formedness, and both specification/body headers on the authoritative token sequence. Runtime initial flags are exactly `False, False, True`. |
| `BooleanBindingsSourceBridge.InterpretedSource.calls/primitives/definitions` | `BooleanBindingsNative` maps active native storage to descending lookup OP:529–573 and the active-prefix `Boolean_Hides_Integer` quantifier OP:575–581. `equalName` spans match lexical Pre; `nameIs` word bounds are the #366 repair. |

The scalar bridge derives expression equality before admission/safety theorems;
the xor bridge derives scanner equality by recurrence; the Boolean bridge
derives lookup/hiding meanings. Their concrete `modelSource`/`model_interpreted`
witnesses establish consistency, not execution or physical-frontend verification.

No mismatch beyond #366 was found in these mappings. Fresh proof validation,
broader implementation coverage, and the final response's evidence applicability
remain separate from this source review, as recorded in the main report.
