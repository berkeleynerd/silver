# Inherited native/Lean interface review — 74ea2edeaa

Date: 2026-11-09. Owner-authorized response to section 2a of the
[external review](review-74ea2edeaa.md), under
[#364](https://github.com/berkeleynerd/silver/issues/364), umbrella
[#355](https://github.com/berkeleynerd/silver/issues/355), milestone 22.

The review found one low-severity native-domain precision discrepancy, tracked
as [#366](https://github.com/berkeleynerd/silver/issues/366) and repaired in
`4a95d7d782`. No further mismatch was found in the named interfaces and the
dependencies examined below. This is a scoped contract/source-correspondence
assessment, not clearance of the entire inherited implementation range.
The repair still requires the coordinated Lean checkpoint; this report does
not claim that validation has run.

## Inputs and method

The original target is `74ea2edeaa`. Work began from main `3f033b97d8`, whose
governed compiler/proof inputs matched that target. The only implementation
change in this review worktree is the two-line repair in
`proof/Silver/BooleanBindingsNative.lean`. The separate original report remains
unchanged. The [input and field inventory](../evidence/review-response-74ea2edeaa/inherited-interfaces/interface-inventory.json)
records exact revisions, hashes, and the structures/own fields in all nine
requested interface files. The [field map](../evidence/review-response-74ea2edeaa/inherited-interfaces/contract-map.md)
records the native counterparts and domain/postcondition relationships.

The assessment checked three distinct obligations:

1. On represented native values, the Lean call domain supplies the Ada `Pre`
   and the relevant machine-type ranges. Invariants supplied by a caller must
   be present in that caller's actual interface, rather than inferred from a
   plausible declaration history.
2. An assumed Lean range/progress/flow consequence must follow from the actual
   native `Post`, including the record field types. A successful native proof
   does not establish that a different Lean proposition was transcribed faithfully.
3. A raw equation must denote the checked native body or exact executable
   refinement, with the same callees, arguments, record fields, active counts,
   and initializer inputs. Source-token equality alone does not establish the
   meaning assigned by an evaluator.

Changes since `10cdcd274c` guided the deeper dependency checks: Boolean scalar
and array state, bounded String/Character values, subtype visibility and xor,
and iteration. Existing arithmetic and lexical semantic libraries were followed
through their source interfaces; their entire mathematical proofs were not
independently re-proved. The documented Ada/GNAT frontend interpretation remains
an assumption, as explained in
[the trusted boundary](../trusted-boundary.md#source-correspondence-and-semantic-assumptions).

## Finding and repair

**Low — Boolean name comparison had an unnecessarily broad word domain.**
At the original target, `BooleanBindingsNative.Primitives.nameIs` (lines
151–153) quantified over every `expected : List Nat`. The native `Name_Is`
contract in `src/silver_output_lexical.ads:134–139` requires a one-based String
with length in `1 .. Max_Source_Length`. The Lean premise did not state the
nonempty/bounded word-length restriction.

The only consumer of this primitive in the Boolean binding proof compares the
seven-byte word `integer`, through the quantified active-binding predicate and
`hidesInteger_meaning`. No illegal native call, admission disagreement, or
runtime defect was demonstrated. In particular, the trusted boundary explicitly
allows formal totalizations outside native domains; the finding must not be
reported as evidence that an admitted program fails the Oracle.

Commit `4a95d7d782` adds `0 < expected.length` and
`expected.length ≤ maxSourceLength` to the premise and supplies the two closed
proofs at that consumer. It changes neither the admitted language nor Ada code.
The requested focused target is `Silver.BooleanBindingsSourceBridge`, with
`Silver.PredicateSourceBridge` or the complete shared checkpoint covering
integration. `git diff --check` passed for the repair. No Lean execution was
performed by this review stream.

## Coverage and conclusions

| Requested interface | Scope actually examined |
| --- | --- |
| `ComposeContracts.lean` | All 14 structures: their domain/representation fields, all 17 `HelperRanges` fields, all 66 own `RawHelperEquations` fields, the three derived helper meanings, and the explicitly historical interfaces. |
| `PredicateNativeContracts.lean` | All 11 range/progress/flow contract fields against the native predicates, records, and helper contracts. |
| `ComposeSourceBridge.lean` | All six structures, including every `CheckedSource` and `InterpretedSource` field, the Boolean derivations, imported function identities, and current native shell restriction. |
| `PredicateNativeSourceBridge.lean` | All four interpretation fields; raw helper/body equations, sizing and worker refinement dependencies; derivation of condition meaning. |
| `ScalarExpressionSourceBridge.lean` | Both interpretation fields; primitive domains and all scalar expression equations, especially array atoms, masks, default arguments, and initializer/body distinction. |
| `PredicateBodyCorrespondence.lean` | All seven recursive equations, their context/scan/catalogue domains, native bodies/refinements, and the ordinary loop evaluator/import links. |
| `PredicateNativeCorrespondence.lean` | All seven recursive equations and validity domain; normalized helper interpretation and uniqueness route, including Boolean factor/relation and condition tail. |
| `PredicateXorSourceBridge.lean` | Both interpretation fields and all six source-check fields; model/wrapper domains, Character literal dependency, and quote/comment/identifier-boundary state. |
| `BooleanBindingsSourceBridge.lean` | All three interpretation fields; lookup recursion, executable refinement, active-prefix hiding quantifier, and both lexical primitives. |

The current inherited helper bridge uses
`Predicate.OuterReadiness.domain`, not `StateDomain.basic`.
`OuterReadiness.ValidState.ready` supplies nonempty declared scalar bounds and
mutable-bound containment; its `bounds` supplies the exact native String table
invariant. These are required by Ada `Valid_State` and are not consequences of
the older `Compose.Expressions.ValidState` alone. `NativeNames`, `NativeValue`,
`NativeResult`, and `NativeScan` separately carry the relevant index, operand,
capacity, and Integer interval bounds. Native return types contribute some of
the consequences that do not appear as explicit textual `Post` conjuncts.

For arrays, the review checked descriptor order, positive component count,
index-span equality, source-derived capacities, used-cell accounting, component
bounds, and the active table interpretation. `ArrayValuesDomain` retains the
native source/result states and exact `used = source.used + parsed` equation.
It does not silently replace the helper's declared domain with reachable
initializer prefixes. `ValidInitials` represents the complete fixed native
Integer array, including arbitrary values outside allocated components.
Boolean array cells reserve space but do not represent Boolean truth. Shared
lookup uses the full descriptor list before typed semantic projections.

For predicates, `ValidContext`, `ValidFlow`, and `ValidResult` account for the
body context, scalar vector extents, immutable and mutable interval constraints,
and bounded path fields. The condition workers preserve the native output
discriminant: the observed condition call supplies `facts.count`, and the worker
refinement explicitly requires that count. `Incoming` and `Initials` remain
separate inputs. Tail input/result count equality follows from both flows having
the context's scalar count; it is not a missing premise. Strict advancement for
fresh readers and nondecreasing advancement for tails remain distinct.

The String/Character checks included the ordinary command evaluator, early
return and assignment behavior, exact Character triplets, indexed/slice
arguments, null and concatenated bounds, scalar reader defaults, and guarded
region checks. The subtype and Boolean checks included descending active
lookup, hiding flags, initializer masking/elaboration, and the rule that Boolean
metadata retains no predicate refinement facts. The xor evaluator preserves
quote/comment/word-boundary state and invokes the checked Character literal
helper; its executable equality has exactly the native initial flags.

Iteration was examined beyond its top-level equation. The typed body retains
the original incoming flow while reading counted bounds, widens mutable values
for the body, appends the immutable index with the correct count, copies the
five ordinary body fields and exact active value prefix, and distinguishes
empty, definite, and possibly empty paths. Constant-array iteration resolves the
array before extending the binder context and retains the native exclusions for
mutable/Boolean arrays and the binder spelling. Helper links route counted
bounds through `Read_Counted_Bound`; they do not substitute the unrestricted
scalar reader.

The current endpoint is `PredicateSourceBridge.interpreted_correspondence`,
with executable refinement added by `executable_correspondence`. Its conclusions
are derived from checked helper/body equations and domains. The old
`RangeContracts.step`, `LegacyHelperMeaning`, and fixed-shell
`DefinitionEquations` are mathematical interfaces for the historical shell;
they are not premises asserting that the present Ada scanner implements that
old language. Neither the concrete model witnesses nor checked source pins
alone discharge the frontend interpretation premise.

## Remaining scope and evidence limits

This review addresses the named inherited interface question in original
section 2a. It does not claim source-level inspection of every inherited change:
the original report's 207 output-profile hunks, 275 library-report hunks,
153 new Lean modules, and the full 871-commit range are not cleared by this
assessment. Dependency bodies were inspected to answer the interface questions
above; that is not a complete implementation audit of each dependency. The
`FunctionSourceParts` leaf set was not independently re-reviewed. Imported
function-declaration/library wiring was checked without repeating the original
function review. Catalogue, report-source, source-assurance policy, and response
record corrections belong to the other response streams.

The original target's retained native run `20261108T155015-d9cbdb714cbd`
(18,525 checks) and Lean run `20261108T172947-84b3cd350332` (820 modules) are
background evidence whose applicability was assessed in the original report.
This stream did not independently repeat that packet audit or either proof run.
They do not validate the new repair's changed Lean bytes. There was no compiler
build, sample execution, new native proof, Lean build, cold/replay campaign,
capacity experiment, deep-stack test, or macOS execution in this stream.
The detected host was `linux-x86_64` via `scripts/dev.py paths`.

Selected review configuration was Astra Max, as assigned by the lead; live model,
effort, token, cost, and peak-memory telemetry were not independently exposed.
No subthreads or native workers were started. The live harness goal was absent.
The lead owns integration, final evidence applicability, issue disposition,
publication, and durable/CLI memory updates; this review did not update CLI
memory. Completion of #364/#366 remains subject to that integrated evidence and
closing assessment.
