module

public import Silver.ApplicationPackageStatementReading
public import Silver.ApplicationPackageFlowJoins
public import Silver.PackageChecking

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement
open Compose Predicate ApplicationPackages

def armState : ArmStep → Option Arms
  | .failed => none
  | .finished state | .continued state => some state

theorem finishArm_fields {calls : Calls} {source : Input} {read : ReadArm} {after : Arms}
    (selected : armState (finishArm calls source read) = some after) :
    after.value.scan.facts = read.whenFalse ∧
      after.yes = (if read.haveYes then calls.joinInto read.yes read.branch.scan.facts else read.branch.scan.facts) ∧
      after.haveYes = true := by
  unfold finishArm at selected
  dsimp only at selected
  split at selected
  · simp only [armState, Option.some.injEq] at selected
    cases selected
    exact ⟨rfl, rfl, rfl⟩
  · split at selected
    · simp only [armState, reduceCtorEq] at selected
    · simp only [armState, Option.some.injEq] at selected
      cases selected
      exact ⟨rfl, rfl, rfl⟩

def accumulated (context : ParseContext) (state : Arms) (rest : Flow) : Flow :=
  if state.haveYes then (context.flow state.yes).join rest else rest

theorem accumulated_step {calls : Calls} {source : Input} {prior after : Arms} {read : ReadArm}
    (joined : ∀ left right, calls.joinInto left right = left.join right)
    (parsed : readArm calls source prior = some read)
    (selected : armState (finishArm calls source read) = some after) (rest : Flow) :
    accumulated source.context after rest =
      accumulated source.context prior ((source.context.flow read.branch.scan.facts).join rest) := by
  have observed := readArm_evaluation parsed
  obtain ⟨_, yes, hasYes⟩ := finishArm_fields selected
  simp only [accumulated, hasYes, ite_true, yes, observed.previousArm, observed.previousFlow]
  cases previous : prior.haveYes with
  | false => simp only [Bool.false_eq_true, ite_false]
  | true =>
    simp only [ite_true, joined, ParseContext.flow_join, Flow.join_assoc]

abbrev ArmCode := Condition × List Predicate.Statement

def lowerArms : List ArmCode → List Predicate.Statement → List Predicate.Statement
  | [], alternative => alternative
  | (condition, body) :: rest, alternative => [.choice condition body (lowerArms rest alternative)]

/-- A child source relation is supplied by the enclosing recursive source
decoder. This relation records only its exact syntax and reader invocation. -/
abbrev ChildReading := ApplicationScan → BodyStop → List Predicate.Statement → ApplicationScan → Prop

inductive ArmCodesAt (calls : Calls) (source : Input) (child : ChildReading) :
    List (Arms × ReadArm) → List ArmCode → Prop
  | nil : ArmCodesAt calls source child [] []
  | cons {prior read entries condition body rest}
      (conditionRead : ConditionAt source.text source.context prior.value.scan.position prior.value.scan.facts
        condition (conditionFor calls source prior))
      (bodyRead : child (thenInput calls source prior (conditionFor calls source prior)) .arm body read.branch)
      (following : ArmCodesAt calls source child entries rest) :
      ArmCodesAt calls source child ((prior, read) :: entries) ((condition, body) :: rest)

/-- Both fixed checkers below expose the same conditional composition rule.
This interface is only used by the local recursive proof; the final source
endpoint instantiates it with an actual package or Main checker. -/
structure ConditionalChecker (context : ParseContext) where
  check : Flow → List Predicate.Statement → Option Flow
  choice : ∀ before condition yes no afterYes afterNo,
    condition.checkBounds context.names.shape context.analysis before
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) = true →
    check (condition.refine context.names.shape context.analysis before true) yes = some afterYes →
    check (condition.refine context.names.shape context.analysis before false) no = some afterNo →
    check before [.choice condition yes no] = some (afterYes.join afterNo)

def packageConditionalChecker (earlier : Packages.EffectEnvironment) (layout : Packages.FrameLayout)
    (context : ParseContext) (emptyShape : context.names.shape = Bindings.emptyShape) : ConditionalChecker context where
  check := fun flow body => Packages.checkPackageStatements earlier layout context.analysis flow
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) body
  choice := by
    intro before condition yes no afterYes afterNo guarded yesChecked noChecked
    rw [emptyShape] at guarded yesChecked noChecked
    simp only [Packages.checkPackageStatements, Packages.checkPackageStatement,
      guarded, ite_true, yesChecked, noChecked, Option.bind_some, Option.map_some]

def mainConditionalChecker (functions : ScalarFunctions.Signatures) (procedures : ScalarProcedures.Signatures)
    (context : ParseContext) : ConditionalChecker context where
  check := fun flow body => checkStatements context.names.shape context.analysis flow body
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)) functions procedures
  choice := by
    intro before condition yes no afterYes afterNo guarded yesChecked noChecked
    simp only [checkStatements, Predicate.Statement.check, guarded, ite_true,
      yesChecked, noChecked, Option.bind_some, Option.map_some]

def DecodedArm (calls : Calls) (source : Input) (child : ChildReading)
    (checker : ConditionalChecker source.context) (prior : Arms) (read : ReadArm) (code : ArmCode) : Prop :=
  ConditionAt source.text source.context prior.value.scan.position prior.value.scan.facts
      code.1 (conditionFor calls source prior) ∧
    child (thenInput calls source prior (conditionFor calls source prior)) .arm code.2 read.branch ∧
    code.2 ≠ [] ∧
    StatementsWellFormed source.context.hasArguments source.context.names.shape code.2
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
    ConditionMeaning source.context prior.value.scan.facts code.1 (conditionFor calls source prior) ∧
    checker.check (source.context.flow (conditionFor calls source prior).whenTrue) code.2 =
      some (source.context.flow read.branch.scan.facts)

/-- Compose every original IF/ELSIF arm with the recursive child result. The
accumulation invariant equates the native left fold to nested semantic choices;
the original condition and child-tail readings are retained in the conclusion.
No arm is omitted when its incoming abstract path is empty. -/
theorem arms_checked {calls : Calls} {source : Input} {child : ChildReading}
    {checker : ConditionalChecker source.context} {before after : Arms}
    {entries : List (Arms × ReadArm)} {alternative : List Predicate.Statement} {alternativeAfter : Flow}
    (read : ArmsReading calls source before entries after)
    (joined : ∀ left right, calls.joinInto left right = left.join right)
    (decode : ∀ prior arm, (prior, arm) ∈ entries → ∃ code, DecodedArm calls source child checker prior arm code)
    (alternativeWellFormed : StatementsWellFormed source.context.hasArguments source.context.names.shape alternative
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (alternativeChecked : checker.check (source.context.flow after.value.scan.facts) alternative = some alternativeAfter) :
    ∃ codes finalFlow, ArmCodesAt calls source child entries codes ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape (lowerArms codes alternative)
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checker.check (source.context.flow before.value.scan.facts) (lowerArms codes alternative) = some finalFlow ∧
      accumulated source.context before finalFlow = accumulated source.context after alternativeAfter := by
  induction read with
  | @last before arm after parsed finished =>
    obtain ⟨⟨condition, body⟩, sourceCondition, sourceBody, nonempty, wellFormed, meaning, bodyChecked⟩ :=
      decode before arm List.mem_cons_self
    have state : armState (finishArm calls source arm) = some after := by rw [finished]; rfl
    have facts := (finishArm_fields state).1
    rw [(readArm_evaluation parsed).falseFlow] at facts
    have noChecked := alternativeChecked
    rw [facts, meaning.whenFalse] at noChecked
    rw [meaning.whenTrue] at bodyChecked
    refine ⟨[(condition, body)], (source.context.flow arm.branch.scan.facts).join alternativeAfter,
      .cons sourceCondition sourceBody .nil, ?_, ?_, ?_⟩
    · simp only [lowerArms, StatementsWellFormed, Predicate.Statement.WellFormed]
      exact ⟨⟨meaning.grammatical, meaning.readable, nonempty, wellFormed, alternativeWellFormed⟩, trivial⟩
    · exact checker.choice _ _ _ _ _ _ meaning.checked bodyChecked noChecked
    · exact (accumulated_step joined parsed state alternativeAfter).symm
  | @next before arm next entries after parsed continued following ih =>
    obtain ⟨⟨condition, body⟩, sourceCondition, sourceBody, nonempty, wellFormed, meaning, bodyChecked⟩ :=
      decode before arm List.mem_cons_self
    obtain ⟨codes, tailFlow, tailSource, tailWellFormed, tailChecked, accumulatedTail⟩ :=
      ih (fun prior entry member => decode prior entry (List.mem_cons_of_mem _ member))
        alternativeChecked
    have state : armState (finishArm calls source arm) = some next := by rw [continued]; rfl
    have facts := (finishArm_fields state).1
    rw [(readArm_evaluation parsed).falseFlow] at facts
    rw [facts, meaning.whenFalse] at tailChecked
    rw [meaning.whenTrue] at bodyChecked
    refine ⟨(condition, body) :: codes, (source.context.flow arm.branch.scan.facts).join tailFlow,
      .cons sourceCondition sourceBody tailSource, ?_, ?_, ?_⟩
    · simp only [lowerArms, StatementsWellFormed, Predicate.Statement.WellFormed]
      exact ⟨⟨meaning.grammatical, meaning.readable, nonempty, wellFormed, tailWellFormed⟩, trivial⟩
    · exact checker.choice _ _ _ _ _ _ meaning.checked bodyChecked tailChecked
    · exact (accumulated_step joined parsed state tailFlow).symm.trans accumulatedTail

theorem ArmsReading.final_hasYes {calls source before entries after}
    (read : ArmsReading calls source before entries after) : after.haveYes = true := by
  induction read with
  | last _ finished =>
    exact (finishArm_fields (by rw [finished]; rfl)).2.2
  | next _ _ _ ih => exact ih

theorem ClosingReading.flow {calls : Calls} {source : Input} {state : Arms} {result : ApplicationScan}
    (read : ClosingReading calls source state result)
    (joined : ∀ left right, calls.joinInto left right = left.join right)
    (tokens : ∀ scan token, (calls.bodyToken source.text source.context scan token).facts = scan.facts) :
    source.context.flow result.scan.facts =
      (source.context.flow state.yes).join (source.context.flow (elseResult calls source state).scan.facts) := by
  rw [read.resultEq]
  simp only [closeTokens, withFacts, tokens, joined, ParseContext.flow_join]
  exact Flow.join_comm ..

/-- The complete conditional has exactly its native result flow after all
source-ordered arms and the actual ELSE (or empty alternative) are checked. -/
theorem conditional_checked {calls : Calls} {source : Input} {child : ChildReading}
    {checker : ConditionalChecker source.context} {state : Arms} {result : ApplicationScan}
    {entries : List (Arms × ReadArm)} {alternative : List Predicate.Statement}
    (read : ArmsReading calls source
      ⟨atPosition source.input (calls.takeToken source.text source.input.scan.position (.word "if")),
        source.input.scan.facts, false⟩ entries state)
    (closing : ClosingReading calls source state result)
    (joined : ∀ left right, calls.joinInto left right = left.join right)
    (tokens : ∀ scan token, (calls.bodyToken source.text source.context scan token).facts = scan.facts)
    (decode : ∀ prior arm, (prior, arm) ∈ entries → ∃ code, DecodedArm calls source child checker prior arm code)
    (alternativeWellFormed : StatementsWellFormed source.context.hasArguments source.context.names.shape alternative
      (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)))
    (alternativeChecked : checker.check (source.context.flow state.value.scan.facts) alternative =
      some (source.context.flow (elseResult calls source state).scan.facts)) :
    ∃ codes, ArmCodesAt calls source child entries codes ∧
      StatementsWellFormed source.context.hasArguments source.context.names.shape (lowerArms codes alternative)
        (ArrayBindings.booleanAnalysis source.context.arrayNames (BooleanBindings.analysis source.context.booleanNames)) ∧
      checker.check (source.context.flow source.input.scan.facts) (lowerArms codes alternative) =
        some (source.context.flow result.scan.facts) := by
  obtain ⟨codes, finalFlow, sourceRead, wellFormed, checked, flow⟩ :=
    arms_checked read joined decode alternativeWellFormed alternativeChecked
  simp only [accumulated, read.final_hasYes, ite_true, Bool.false_eq_true, ite_false] at flow
  have same : finalFlow = source.context.flow result.scan.facts := flow.trans (closing.flow joined tokens).symm
  rw [same] at checked
  exact ⟨codes, sourceRead, wellFormed, checked⟩

end Silver.ApplicationPackageBodies.Statement
