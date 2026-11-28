module

public import Silver.ApplicationPackageTypes
public import Silver.PredicateBodyScanner

@[expose] public section

/-! Native application statement routing and exact statement-list loop.
Subreader calls are explicit. The finite loop evaluator uses Option solely to
expose exhaustion of its meta-level execution bound; its termination theorem
eliminates that case on the full native callee-contract domain. -/
namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackages

structure BasicCalls where
  skipAt : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  takeToken : Source → Nat → ShellToken → Nat
  scalarTarget : Source → ParseContext → Nat → Nat
  booleanTarget : Source → ParseContext → Nat → Nat
  stateTarget : Source → ParseContext → PackageBindings.Metadata → Nat → Nat
  packageCallAt : Source → ParseContext → ApplicationScan → PackageBindings.Metadata → Nat →
    PackageBindings.RoutineKind → ApplicationCall
  callAssignmentResult : ParseContext → BodyScan → Nat → Nat → CallResult → BodyScan
  bodyToken : Source → ParseContext → BodyScan → ShellToken → BodyScan
  basicBody : Source → ParseContext → BodyScan → FunctionBindings.Metadata → ProcedureBindings.Metadata → BodyScan
  stateReads : Source → ParseContext → PackageBindings.Metadata → Nat → Nat → PackageBindings.StateSet
  packageCallee : Source → ParseContext → PackageBindings.Metadata → Nat → PackageBindings.RoutineKind → Nat

def assignmentFirst (calls : BasicCalls) (text : Source) (input : ApplicationScan) : Nat :=
  calls.takeToken text (calls.nameAfter text (calls.skipAt text input.scan.position)) (.symbol ":=")

def functionAssignment (calls : BasicCalls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) : ApplicationScan :=
  let called := calls.packageCallAt text context input info (assignmentFirst calls text input) .function
  let result := if called.value.after ≠ 0 then
      let assigned := calls.callAssignmentResult context
        {called.result.scan with position := input.scan.position}
        (calls.scalarTarget text context input.scan.position)
        (calls.booleanTarget text context input.scan.position) called.value
      {called.result with scan := calls.bodyToken text context assigned (.symbol ";")}
    else
      let scan := calls.basicBody text context input.scan catalog procedures
      {input with scan, reads := (PackageBindings.stateUnion input.reads
        (calls.stateReads text context info (assignmentFirst calls text input) scan.position))}
  let state := calls.stateTarget text context info input.scan.position
  if state ≠ 0 then {result with writes := result.writes.set (state - 1) true} else result

def procedureStatement (calls : BasicCalls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) : ApplicationScan :=
  let called := calls.packageCallAt text context input info input.scan.position .procedure
  {called.result with scan := calls.bodyToken text context called.result.scan (.symbol ";")}

def basicResult (calls : BasicCalls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) : ApplicationScan :=
  if assignmentFirst calls text input ≠ 0 ∧
      (calls.scalarTarget text context input.scan.position ≠ 0 ∨
        calls.booleanTarget text context input.scan.position ≠ 0) then
    functionAssignment calls text context input info catalog procedures
  else if input.allowProcedureCalls &&
      decide (calls.packageCallee text context info input.scan.position .procedure ≠ 0) then
    procedureStatement calls text context input info
  else {input with scan := calls.basicBody text context input.scan catalog procedures}

def applicationBasic (calls : BasicCalls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) : ApplicationScan :=
  if input.scan.position = 0 then invalidApplication input
  else
    let result := basicResult calls text context input info catalog procedures
    if result.scan.position ≤ input.scan.position then invalidApplication input else result

theorem applicationBasic_accepted {calls : BasicCalls} {text : Source} {context : ParseContext}
    {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (accepted : (applicationBasic calls text context input info catalog procedures).scan.position ≠ 0) :
    input.scan.position ≠ 0 ∧
      input.scan.position < (basicResult calls text context input info catalog procedures).scan.position ∧
      applicationBasic calls text context input info catalog procedures =
        basicResult calls text context input info catalog procedures := by
  unfold applicationBasic at accepted ⊢
  split at accepted
  · simp only [invalidApplication_position] at accepted
    exact False.elim (accepted rfl)
  · rename_i present
    dsimp only at accepted
    split at accepted
    · simp only [invalidApplication_position] at accepted
      exact False.elim (accepted rfl)
    · rename_i advanced
      refine ⟨present, by omega, ?_⟩
      simp only [present, ↓reduceIte, advanced]

structure TailCalls where
  atBodyStop : Source → Nat → BodyStop → Bool
  applicationStatement : Source → ParseContext → ApplicationScan → PackageBindings.Metadata →
    FunctionBindings.Metadata → ProcedureBindings.Metadata → ApplicationScan

structure TailState where
  value : ApplicationScan
  seen : Bool

inductive TailStep
  | returned (value : ApplicationScan)
  | continued (state : TailState)

def tailStep (calls : TailCalls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (stop : BodyStop) (requireOne : Bool)
    (catalog : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata) (state : TailState) : TailStep :=
  if state.value.scan.position ≠ 0 ∧ !calls.atBodyStop text state.value.scan.position stop then
    let next := calls.applicationStatement text context state.value info catalog procedures
    if next.scan.position ≤ state.value.scan.position then .returned (invalidApplication next)
    else .continued ⟨next, true⟩
  else if state.value.scan.position = 0 ∨ (requireOne = true ∧ state.seen = false) then
    .returned (invalidApplication state.value)
  else .returned state.value

def tailFuel (step : TailState → TailStep) : Nat → TailState → Option ApplicationScan
  | 0, _ => none
  | fuel + 1, state => match step state with
    | .returned value => some value
    | .continued next => tailFuel step fuel next

inductive TailExecution (step : TailState → TailStep) : TailState → ApplicationScan → Prop
  | returned {state value} : step state = .returned value → TailExecution step state value
  | continued {state next value} : step state = .continued next → TailExecution step next value →
      TailExecution step state value

theorem tailFuel_sound {step : TailState → TailStep} {fuel : Nat} {state : TailState} {value : ApplicationScan}
    (found : tailFuel step fuel state = some value) : TailExecution step state value := by
  induction fuel generalizing state with
  | zero => simp only [tailFuel, reduceCtorEq] at found
  | succ fuel induction =>
      simp only [tailFuel] at found
      split at found
      · rename_i result selected
        cases found
        exact .returned selected
      · rename_i next selected
        exact .continued selected (induction found)

theorem TailExecution.unique {step : TailState → TailStep} {state : TailState} {first second : ApplicationScan}
    (left : TailExecution step state first) (right : TailExecution step state second) : first = second := by
  induction left with
  | returned returned =>
      cases right with
      | returned other => simpa only [returned, TailStep.returned.injEq] using other
      | continued other _ => simp only [returned, reduceCtorEq] at other
  | continued continued _ induction =>
      cases right with
      | returned other => simp only [continued, reduceCtorEq] at other
      | continued other rest =>
          have same := TailStep.continued.inj (continued.symm.trans other)
          subst same
          exact induction rest

theorem tailStep_progress {calls : TailCalls} {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {stop : BodyStop} {requireOne : Bool}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    {state next : TailState}
    (continued : tailStep calls text context info stop requireOne catalog procedures state = .continued next) :
    state.value.scan.position < next.value.scan.position ∧ next.seen = true ∧
      next.value = calls.applicationStatement text context state.value info catalog procedures := by
  unfold tailStep at continued
  split at continued
  · dsimp only at continued
    split at continued
    · contradiction
    · cases continued
      dsimp only
      exact ⟨by omega, rfl, rfl⟩
  · split at continued <;> contradiction

/-- A semantic execution bound follows from the native scanner's complete
position/preservation contract. No statement list is capped by an extra language
limit, and no successful native scan is turned into exhaustion. -/
theorem tailFuel_total {step : TailState → TailStep} {valid : TailState → Prop} {limit : Nat}
    (bounded : ∀ state, valid state → state.value.scan.position ≤ limit)
    (progress : ∀ state next, valid state → step state = .continued next →
      valid next ∧ state.value.scan.position < next.value.scan.position)
    {state : TailState} (legal : valid state) {fuel : Nat}
    (enough : limit - state.value.scan.position + 1 ≤ fuel) :
    ∃ value, tailFuel step fuel state = some value := by
  induction fuel generalizing state with
  | zero => omega
  | succ fuel induction =>
      simp only [tailFuel]
      split
      · exact ⟨_, rfl⟩
      · rename_i next continued
        have advancement := progress state next legal continued
        apply induction advancement.1
        have before := bounded state legal
        have after := bounded next advancement.1
        omega

end Silver.ApplicationPackageBodies
