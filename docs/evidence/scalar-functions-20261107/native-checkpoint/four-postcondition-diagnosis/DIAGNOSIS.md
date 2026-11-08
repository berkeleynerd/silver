# Four native postconditions: consolidated independent diagnosis

Target: failed native Linux run `20261108T040128-2651963b8574`, actual exit 1 at
2026-11-08 08:23:26 UTC after 15,717.688 s. Native source snapshot 560144172c;
parser bytes 9ec28d94a41c81bb68168bb674792bc44bf1ddeae69e71d4d3e11b153786b77f.
Current packet is committed at native owner's evidence-only commit 0e11f7f9dc7e38d2780366ece82976fad6feb7a3.
Selected reviewer Astra Extra High; live runtime telemetry unavailable.

Disposition: a concrete full-domain Parameter_Frame contract violation needs a
source repair. The other three failures have specific modular-contract gaps to
address. The evidence does not support attributing these failures to prover
nondeterminism or launching another unchanged full run. No validation, source
mutation, process signal or productive Lean input change occurred in this review.

## Exact failed obligations

All are VC_POSTCONDITION in silver_output_profile.adb. All three ordinary
provers (session names CVC5, Z3, altergo) timed out under their 30 s budgets;
CVC5_CE's introduce_premises branch timed out under 10 s. No counterexample was
produced by those attempts. Recorded limits are prover settings, not measured
fresh elapsed times. The manually derived witness below is separate evidence.

| Entity | Diagnostic location | Root GP_Check location/id | Failing Why3 leaf | Other split children proved |
| --- | --- | --- | --- | ---: |
| Actuals_Model | 4794:16 | 4794:16 / 2612 | def'vc.71 | 71 of 72 |
| Function_Local_At | 5615:19 | 5614:16 / 3154 | def'vc.50 | 50 of 51 |
| Parameter_Frame | 5709:20 | 5703:28 / 3207 | def'vc.98 | 98 of 99 |
| Function_Return_After | 5736:16 | 5736:16 / 3214 | def'vc.35 | 35 of 36 |

The task theory names are Silver_output_profile__<entity>__subprogram_def.
The exact task hashes, sizes, session prover/limit records, report entities,
check trees, report msg IDs and source-label distinctions are in
four-failed-identities.json. Generated task sizes are respectively 14,524,308,
5,730,703, 3,061,403 and 14,223,061 bytes. Those sizes/context counts identify the
inputs; they do not establish the cause of a timeout. Original .gnat-json and
session files remain authoritative; rendered selected theories are reading aids.

## Earlier 231059: same parser, absent parser proof evidence

The earlier failed full run `20261107T231059-a9f0c12c8350` ran 8,765.212 s and
retained 66 report units: 11,575 info proof records  + 983 info flow records  = 12,558,
plus three flow warnings. It has no silver_output_profile.spark, no parser
sessions or any of these four generated tasks, and no parser-unit section in
its final gnatprove.out. Its raw log likewise does not report these four methods.
Current evidence contains 77 units (eleven more), 16,915 info proof  + 1,605 info
flow  + four medium postconditions  = 18,524 records. Neither run has successful
complete proof-provenance/audit evidence. Earlier discharged counts describe
only the recorded checks; they do not establish previous success for these four.

Exact comparisons establish:

- Native command, mode/options, worker count 12, cache location, force flag,
  recorded tool identities and retained why3.conf are identical. Both use -U,
  mode all, report all, warnings error, checks-as-errors on, level 2, the same
  three provers, timeout 30 and -f. No limit-subprogram option appears.
- All parser bytes, annotations and captured parser dependencies are unchanged.
  The complete prepared input-map difference is only src/silver_library_reports.adb,
  SHA 700e6fb94d4d722cb3d95a8c145c03bee44dd36a6384bb693772dd6bc8531459
  to 3254d7d3236cbaa689e61a4dc13478d29ab9cafe6cfdd5f0ba8b2ecff4d13b25.
  Its exact retained diff removes the unused report-policy Source formals and
  forwarded actuals and the ineffective initializer. Parser source did not change.
- There is no older task identity to compare for these four obligations in 231059.
  Similar source text, unchanged command and a previous aggregate total cannot
  stand in for missing per-obligation outcomes. The reason those eleven units
  are absent is not established by this review; no scheduling explanation is
  inferred from the flow warnings.

301 consumed packet artifacts (frozen inputs, native events/logs/reports/config,
these tasks and sessions) were independently decompressed and hash/size verified.
Source/helper reads for the witness equal their frozen inputs. The native owner
separately verified its full 3,711-artifact retained collection. Existing unrelated
successful evidence remains intact.

## 1. Actuals_Model: incomplete induction contract at a failed comma

The written postcondition says result=0 or result advances beyond its Position.
The body parses an Actual_Model, rejects After=0, and for a non-final formal calls
Actuals_Model recursively at Take_Token(Text, After, Comma). A failed comma yields
zero. The recursive call's exported contract allows a positive result when its
own Position=0; it does not promise zero input yields zero output. That permitted
abstract result need not advance beyond the original call's positive Position.
The task contains that recursive program contract and no self-definition axiom
that could replace the induction contract. This identifies a concrete induction
information gap, not a demonstrated incorrect successful parser result.

Two full-domain repair directions are available: explicitly reject a zero comma
cursor before recursion (then prove source/model equivalence), or strengthen the
model's postcondition to include nonzero result implies positive input. The latter
also needs a proved corresponding fact for Actual_Model; its current contract
only states the range. Existing Lean actual_post proves the model's stronger
positive-input property, but Lean does not discharge the native obligation.
Neither direction may narrow First/Last/Position's declared domain or omit calls.

## 2. Function_Local_At: missing callee frame facts

The wrapper returns successful Scalar_Declaration_At or otherwise Boolean_Declaration_At.
It promises preservation of Functions, First_Parameter and Pure on success.
Both native callee contracts export only Valid_State and result=0 or progress.
Their program-function declarations in the actual generated task contain no
three-field preservation facts; no callee body/definition axiom supplies them
there. Valid_State alone does not relate these fields to the input state.

The source bodies do preserve them on every successful return: Scalar updates
only Position/Scalar_Names; Boolean updates only Position/Boolean_Names. Both
return canonical Invalid_State on rejected paths. The appropriate modular repair
is to add and prove the three guarded preservation facts to both callee posts,
then prove the wrapper. This does not change executable behavior or input domain.
If record/array equality remains difficult, use the already proved equality
infrastructure with its actual assumptions; do not replace equality by a weaker
active-prefix claim. Merely re-running the wrapper cannot add the missing facts.

## 3. Parameter_Frame: actual counterexample in the declared domain

See parameter-frame-witness.md for the complete precondition discharge.
For Text="x" and Frame=(Invalid_State with delta First_Parameter=>1), all declared
preconditions hold. Parameter_Count=0, so the executable runs zero loop iterations
and returns Frame (First_Parameter=1). The ghost model tests Position=0 first and
returns Invalid_State (First_Parameter=0). Its required static equality is false.
This explanation is independent of solver budgets or array equality encoding.

The smallest source candidate is to return Invalid_State for Frame.Position=0
before the loop, preserving the complete domain and the model's intended result.
The existing runtime postcondition already permits that result when its position is zero.
Current successful callers may avoid the witness, but call-site restrictions do
not repair a false full-domain subprogram contract. No precondition narrowing,
obligation suppression or model weakening is justified.

## 4. Function_Return_After: missing zero-input propagation

Start=Take_Token(Text, Scan.Position, Return_Keyword), then the body returns
Actual_After(Text, Context, Start, ...). A failed keyword yields Start=0. The
Actual_After runtime post allows a positive result from zero input; its static
post links to Actual_Model, whose explicit post also lacks zero-input rejection.
Consequently the caller cannot compose the two progress bounds directly. Its
generated task pulls the actual-model definition and large predicate dependencies;
that is evidence of a deeper proof route, not proof that more time suffices.

Proving/exposing nonzero result implies positive input for Actual_Model and
Actual_After supplies exactly the missing bound: accepted actual implies Start>0;
Take_Token then gives Start>Scan.Position; actual progress gives the final bound.
Alternatively an explicit Start=0 return0 guard makes this caller's proof local,
with source/model equivalence verified. The existing Lean actual_post/return_post
uses the stronger positive-input fact explicitly, confirming the needed semantic
property without replacing native verification.

## Smallest next experiment and required follow-through

First, after coordinator authorization, use a separate source/proof workspace to
try only the Parameter_Frame entry guard and prove that full-domain subprogram
with the original settings. Retain exact before/after bytes and full selected
obligation result, including all its checks. The purpose is to test the smallest
repair for a known false postcondition, not retry the unchanged failing obligation.
A focused proof can still expose additional equality work; success is not assumed.

Then prepare the other three repairs together: guarded preservation posts for
both declaration callees, and either explicit zero-cursor guards or proved
zero-input preservation contracts for the actual-argument chain. Prefer the
contract route if it proves with a small local obligation set because it exposes
the reusable full-domain property already used by the semantic argument. Run
only affected callees plus these four callers in the isolated managed workspace,
with explicit reservation and retained diagnosis for any repeated failure.
No full native rerun is justified until these focused obligations pass and exact
source correspondence is updated. A final complete native audit remains mandatory.
No experiment has been executed or source repair applied by this reviewer.

Any parser edit changes the authoritative source captured by active Lean 064001.
Leave that run's inputs immutable and retain its actual outcome. A later repaired
snapshot must regenerate its source certificate/chunks and update the affected
checked source bodies/contracts and semantic argument together. Parameter_Frame's
exact loop tokens are in FunctionDeclarationSource.loops and checked by
FunctionSourceParts/DeclarationLoopParameterFrame; FrameEquations uses the checked
static contract as a premise and does not excuse this native failure. Actual
contract/body changes also affect PredicateFunctionCallSource and corresponding
FunctionSourceParts; declaration header changes have their existing source-check
owners. Updating pins alone cannot establish correspondence. Existing completed
unaffected objects may be retained, with a fresh complete audit of repaired inputs.

The previously accepted 637-test composition remains applicable to its unchanged
snapshot; no edit here invalidated it. Any eventual source repair requires a new
ordinary affected-input review and fresh affected tests. No publication, merge,
CLI memory update or harness goal change occurred.

Separate read-only Lean note: the proposed CallsIncludedImpl qualification patch
fcf1698abd92167b5438846c0c8c59a6cb6708ac4cc7c04895add0f1bddd8974 correctly selects
Silver.Predicate.FunctionCallNative.SourceChecks.expectedTokens, exactly the
namespace of Checked.included_impl. Both competing helpers are (Source.lexLine
text).getD []; no semantic issue was found. It was not applied or checked here;
the planned affected proof must run after the active lease releases.

Attempt history is intentionally bounded by retained evidence: these are the
first supplied exact failed tasks/sessions for the four obligations. The examined
earlier parser-equality packet contains focused array-declaration, equality and
after-reader repairs, with no retained matching task/session for these four.
The prior complete 231059 packet likewise supplies none. This does not assert
that no unretained or differently scoped attempt ever occurred. No retry count
or recurrence classification was fabricated from similar diagnostic wording.
