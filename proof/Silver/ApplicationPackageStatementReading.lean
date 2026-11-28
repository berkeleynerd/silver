module

public import Silver.ApplicationPackageBodiesArmReading
public import Silver.ApplicationPackageBodiesTailReading

@[expose] public section

/-! Accepted statement traces retain every native arm and loop invocation.
These are source-reader facts only; no semantic checker or safety assertion is
part of a reading. The recursive semantic decoder consumes each child tail at
its actual input and in the original source order. -/
namespace Silver.ApplicationPackageBodies.Statement
open ApplicationPackages Compose Predicate

inductive ArmsReading (calls : Calls) (source : Input) :
    Arms → List (Arms × ReadArm) → Arms → Prop
  | last {before read after} :
      readArm calls source before = some read →
      finishArm calls source read = .finished after →
      ArmsReading calls source before [(before, read)] after
  | next {before read after entries final} :
      readArm calls source before = some read →
      finishArm calls source read = .continued after →
      ArmsReading calls source after entries final →
      ArmsReading calls source before ((before, read) :: entries) final

theorem armsFuel_reading {calls : Calls} {source : Input} {before after : Arms} {fuel : Nat}
    (accepted : armsFuel (armStep calls source) fuel before = some (some after)) :
    ∃ entries, ArmsReading calls source before entries after := by
  induction fuel generalizing before with
  | zero => simp only [armsFuel, reduceCtorEq] at accepted
  | succ fuel ih =>
    rw [armsFuel, armStep] at accepted
    cases parsed : readArm calls source before with
    | none => simp only [parsed, Option.some.injEq, reduceCtorEq] at accepted
    | some read =>
      simp only [parsed] at accepted
      cases step : finishArm calls source read with
      | failed => simp only [step, Option.some.injEq, reduceCtorEq] at accepted
      | finished result =>
        simp only [step, Option.some.injEq] at accepted
        cases accepted
        exact ⟨_, .last parsed step⟩
      | continued result =>
        rw [step] at accepted
        obtain ⟨entries, history⟩ := ih accepted
        exact ⟨_, .next parsed step history⟩

theorem ArmsReading.nonempty {calls source before entries after}
    (read : ArmsReading calls source before entries after) : entries ≠ [] := by
  cases read <;> simp

theorem ArmsReading.each {calls source before entries after}
    (read : ArmsReading calls source before entries after) :
    ∀ prior arm, (prior, arm) ∈ entries → ArmEvaluation calls source prior arm := by
  induction read with
  | last parsed _ =>
    intro prior arm member
    cases List.mem_singleton.mp member
    exact readArm_evaluation parsed
  | next parsed _ _ ih =>
    intro prior arm member
    rcases List.mem_cons.mp member with same | rest
    · cases same
      exact readArm_evaluation parsed
    · exact ih prior arm rest

def elsePosition (calls : Calls) (source : Input) (state : Arms) : Nat :=
  calls.takeToken source.text state.value.scan.position (.word "else")

def elseResult (calls : Calls) (source : Input) (state : Arms) : ApplicationScan :=
  if elsePosition calls source state ≠ 0 then
    tail calls source source.context (atPosition state.value (elsePosition calls source state)) .endOnly
  else state.value

structure ClosingReading (calls : Calls) (source : Input) (state : Arms)
    (result : ApplicationScan) : Prop where
  branchPresent : (elseResult calls source state).scan.position ≠ 0
  resultEq : result = closeTokens calls source
    (withFacts (elseResult calls source state)
      (calls.joinInto (elseResult calls source state).scan.facts state.yes)) (.word "if")
  advances : source.input.scan.position < result.scan.position
  valid : calls.validBody source.text source.context result.scan = true

theorem validate_result {calls : Calls} {source : Input} {input : ApplicationScan}
    (present : (validate calls source input).scan.position ≠ 0) :
    validate calls source input = input := by
  unfold validate at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i valid
    rw [ite_eq_right valid]

theorem closeIf_reading {calls : Calls} {source : Input} {state : Arms}
    (present : (closeIf calls source state).scan.position ≠ 0) :
    ClosingReading calls source state (closeIf calls source state) := by
  let branch := elseResult calls source state
  let result := closeTokens calls source
    (withFacts branch (calls.joinInto branch.scan.facts state.yes)) (.word "if")
  have equation : closeIf calls source state =
      if branch.scan.position = 0 then invalidApplication source.input else validate calls source result := rfl
  by_cases missing : branch.scan.position = 0
  · rw [equation, ite_eq_left missing] at present
    exact False.elim (present rfl)
  · rw [equation, ite_eq_right missing] at present ⊢
    have checked := validate_accepted present
    exact ⟨missing, validate_result present, checked.1, checked.2⟩

def widened (calls : Calls) (source : Input) (iteration : Iteration) : ActiveFlow :=
  calls.widenInto source.context iteration.value.scan.facts

def loopResult (calls : Calls) (source : Input) (iteration : Iteration) : ApplicationScan :=
  tail calls source (innerContext source iteration)
    (innerInput source iteration (widened calls source iteration)) .endOnly

structure IterationReading (calls : Calls) (source : Input) (afterFor : Nat)
    (iteration : Iteration) (result : ApplicationScan) : Prop where
  header : forHeader calls source afterFor = some iteration
  advances : source.input.scan.position < iteration.value.scan.position
  bodyPresent : (loopResult calls source iteration).scan.position ≠ 0
  resultEq : result = closeTokens calls source
    (afterIteration calls source iteration (widened calls source iteration)
      (loopResult calls source iteration)) (.word "loop")
  resultAdvances : source.input.scan.position < result.scan.position
  valid : calls.validBody source.text source.context result.scan = true

theorem forStatement_reading {calls : Calls} {source : Input} {afterFor : Nat}
    (present : (forStatement calls source afterFor).scan.position ≠ 0) :
    ∃ iteration, IterationReading calls source afterFor iteration (forStatement calls source afterFor) := by
  unfold forStatement at present ⊢
  cases header : forHeader calls source afterFor with
  | none => simp only [header] at present; exact False.elim (present rfl)
  | some iteration =>
    simp only [header] at present ⊢
    split at present
    · exact False.elim (present rfl)
    · rename_i advances
      rw [ite_eq_right advances]
      split at present
      · exact False.elim (present rfl)
      · rename_i nonzero
        rw [ite_eq_right nonzero]
        have checked := validate_accepted present
        exact ⟨iteration, header, Nat.lt_of_not_ge advances, nonzero,
          validate_result present, checked.1, checked.2⟩

inductive Reading (calls : Calls) (source : Input) : ApplicationScan → Prop
  | basic (present : source.input.scan.position ≠ 0)
      (noIf : calls.takeToken source.text source.input.scan.position (.word "if") = 0)
      (noFor : calls.takeToken source.text source.input.scan.position (.word "for") = 0) :
      Reading calls source
        (calls.applicationBasic source.text source.context source.input source.info source.catalog source.procedures)
  | conditional {entries state result} (present : source.input.scan.position ≠ 0)
      (keyword : calls.takeToken source.text source.input.scan.position (.word "if") ≠ 0)
      (arms : ArmsReading calls source
        ⟨atPosition source.input (calls.takeToken source.text source.input.scan.position (.word "if")),
          source.input.scan.facts, false⟩ entries state)
      (closing : ClosingReading calls source state result) : Reading calls source result
  | iteration {iteration result} (present : source.input.scan.position ≠ 0)
      (noIf : calls.takeToken source.text source.input.scan.position (.word "if") = 0)
      (keyword : calls.takeToken source.text source.input.scan.position (.word "for") ≠ 0)
      (loop : IterationReading calls source
        (calls.takeToken source.text source.input.scan.position (.word "for")) iteration result) :
      Reading calls source result

/-- Every accepted branch of the complete native statement reader yields its
exact child invocations, including all ELSIF arms and a possibly unreachable loop
body. No unrolling bound is added to the admitted language. -/
theorem statementFuel_reading {calls : Calls} {source : Input} {fuel : Nat} {result : ApplicationScan}
    (parsed : statementFuel calls fuel source = some result) (present : result.scan.position ≠ 0) :
    Reading calls source result := by
  unfold statementFuel at parsed
  split at parsed
  · cases parsed
    exact False.elim (present rfl)
  · rename_i inputPresent
    dsimp only at parsed
    split at parsed
    · rename_i isIf
      obtain ⟨state, run, resultEq⟩ := Option.map_eq_some_iff.mp parsed
      cases state with
      | none => cases resultEq; exact False.elim (present rfl)
      | some state =>
        cases resultEq
        obtain ⟨entries, arms⟩ := armsFuel_reading run
        exact .conditional inputPresent isIf arms (closeIf_reading present)
    · rename_i noIf
      split at parsed
      · rename_i isFor
        cases parsed
        obtain ⟨iteration, read⟩ := forStatement_reading present
        exact .iteration inputPresent (Nat.eq_zero_of_not_pos (fun h => noIf (Nat.ne_of_gt h))) isFor read
      · rename_i noFor
        cases parsed
        exact .basic inputPresent (by simpa using noIf) (by simpa using noFor)

end Silver.ApplicationPackageBodies.Statement
