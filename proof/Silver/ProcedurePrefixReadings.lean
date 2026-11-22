module

public import Silver.ProcedureFrameMeaning
public import Silver.PredicateFunctionCallReadings

@[expose] public section

namespace Silver.Compose
open Predicate

def procedurePrefixContext (readFrame : ParserState) (declarationCount : Nat) : ParseContext :=
  {contextOf ⟨readFrame, false, false⟩ with declarationCount}

def procedurePrefixFacts (readFrame : ParserState) (declarationCount : Nat) : ActiveFlow :=
  ActiveFlow.initial (procedurePrefixContext readFrame declarationCount).scalarNames
    (initialFacts (procedurePrefixContext readFrame declarationCount).hasArguments)

def procedurePrefixFormal (formal : ProcedureBindings.Formal) : FunctionBindings.Formal :=
  Predicate.procedureInputFormal formal

def procedurePrefixValueAfter (text : Source) (readFrame frame : ParserState)
    (formal : ProcedureBindings.Formal) (declarationCount : Nat) : Nat :=
  actualAfter text (procedurePrefixContext readFrame declarationCount)
    (fixedAfter text (nameAfter text (skipAt text frame.position)) ":=" false)
    (procedurePrefixFacts readFrame declarationCount) (procedurePrefixFormal formal)

/-- One source assignment. This direct helper reading deliberately does not
require out mode: the enclosing prefix loop selects out formals. -/
structure ProcedurePrefixStepAt (text : Source) (readFrame frame : ParserState)
    (formal : ProcedureBindings.Formal) (actual : ScalarFunctions.Actual) (final : ParserState)
    (declarationCount : Nat) : Prop where
  namePositive : skipAt text frame.position ≠ 0
  nameAdvances : skipAt text frame.position < nameAfter text (skipAt text frame.position)
  nameMatches : Named.equalName text (skipAt text frame.position)
    (nameAfter text (skipAt text frame.position)) formal.first formal.after = true
  value : ActualAt text (procedurePrefixContext readFrame declarationCount)
    (fixedAfter text (nameAfter text (skipAt text frame.position)) ":=" false)
    (procedurePrefixFacts readFrame declarationCount) (procedurePrefixFormal formal) actual
    (procedurePrefixValueAfter text readFrame frame formal declarationCount)
  advances : frame.position < fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false
  installed : final = appendProcedureParameter
    {frame with position := fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false} formal
  accepted : final.position ≠ 0

theorem procedurePrefixStep_reading {text readFrame declarationCount frame formal}
    (textValid : Expressions.ValidText text) (names : Expressions.ValidNames text readFrame.names)
    (accepted : (procedurePrefixStep text readFrame frame formal declarationCount).position ≠ 0) :
    ∃ actual, ProcedurePrefixStepAt text readFrame frame formal actual
      (procedurePrefixStep text readFrame frame formal declarationCount) declarationCount := by
  dsimp only [procedurePrefixStep] at accepted ⊢
  split at accepted
  · contradiction
  · rename_i allowed
    have namePositive : skipAt text frame.position ≠ 0 := fun bad => allowed (.inl bad)
    have nameAdvances : skipAt text frame.position < nameAfter text (skipAt text frame.position) := by
      have noBack : ¬nameAfter text (skipAt text frame.position) ≤ skipAt text frame.position :=
        fun bad => allowed (.inr (.inl bad))
      omega
    have nameMatches : Named.equalName text (skipAt text frame.position)
        (nameAfter text (skipAt text frame.position)) formal.first formal.after = true := by
      apply Bool.of_not_eq_false
      intro bad
      exact allowed (.inr (.inr (.inl (by simp only [bad, Bool.not_false]))))
    have valuePositive : procedurePrefixValueAfter text readFrame frame formal declarationCount ≠ 0 :=
      fun bad => allowed (.inr (.inr (.inr (.inl bad))))
    have advances : frame.position < fixedAfter text
        (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false := by
      have noBack : ¬fixedAfter text
          (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false ≤ frame.position :=
        fun bad => allowed (.inr (.inr (.inr (.inr bad))))
      omega
    obtain ⟨actual, reading⟩ := actual_sound textValid names
      (Expressions.model_fixed_valid text _ ":=" false (Expressions.model_name_valid text _)) valuePositive
    refine ⟨actual, ?_⟩
    rw [ite_eq_right allowed]
    exact ⟨namePositive, nameAdvances, nameMatches, reading, advances, rfl, accepted⟩

theorem ProcedurePrefixStepAt.complete {text readFrame declarationCount frame formal actual final}
    (source : ProcedurePrefixStepAt text readFrame frame formal actual final declarationCount) :
    procedurePrefixStep text readFrame frame formal declarationCount = final := by
  dsimp only [procedurePrefixStep]
  have allowed : ¬(skipAt text frame.position = 0 ∨
      nameAfter text (skipAt text frame.position) ≤ skipAt text frame.position ∨
      (!Named.equalName text (skipAt text frame.position) (nameAfter text (skipAt text frame.position))
        formal.first formal.after) = true ∨
      procedurePrefixValueAfter text readFrame frame formal declarationCount = 0 ∨
      fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false ≤ frame.position) := by
    simp only [source.namePositive, Nat.not_le_of_gt source.nameAdvances, source.nameMatches,
      Bool.not_true, Bool.false_eq_true, source.value.positive, Nat.not_le_of_gt source.advances,
      or_self, not_false_eq_true]
  simp only [procedurePrefixValueAfter, procedurePrefixContext, procedurePrefixFacts,
    procedurePrefixFormal, procedureInputFormal] at allowed
  rw [ite_eq_right allowed]
  exact source.installed.symm

/-- A prefix helper advances the cursor and can install a formal binding.
The declared types, physical array pool and callable metadata stay in scope. -/
def ProcedurePrefixFields (before after : ParserState) : Prop :=
  after = {before with
    position := after.position
    scalarNames := after.scalarNames
    booleanNames := after.booleanNames
    arrayNames := {before.arrayNames with names := after.arrayNames.names}}

theorem ProcedurePrefixFields.trans {first middle last : ParserState}
    (before : ProcedurePrefixFields first middle) (after : ProcedurePrefixFields middle last) :
    ProcedurePrefixFields first last := by
  unfold ProcedurePrefixFields at *
  rw [before] at after
  exact after

theorem ProcedurePrefixStepAt.fields {text readFrame declarationCount frame formal actual final}
    (source : ProcedurePrefixStepAt text readFrame frame formal actual final declarationCount) :
    ProcedurePrefixFields frame final := by
  have preserved := appendProcedureParameter_fields
    {frame with position := fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false}
    formal (source.installed ▸ source.accepted)
  rw [← source.installed] at preserved
  unfold ProcedureFrameFields at preserved
  have position : final.position =
      fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false :=
    congrArg ParserState.position preserved
  change final = {frame with
    position := final.position
    scalarNames := final.scalarNames
    booleanNames := final.booleanNames
    arrayNames := {frame.arrayNames with names := final.arrayNames.names}}
  rw [position]
  exact preserved

theorem ProcedurePrefixStepAt.position {text readFrame declarationCount frame formal actual final}
    (source : ProcedurePrefixStepAt text readFrame frame formal actual final declarationCount) :
    final.position = fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false := by
  have preserved := appendProcedureParameter_fields
    {frame with position := fixedAfter text (procedurePrefixValueAfter text readFrame frame formal declarationCount) ";" false}
    formal (source.installed ▸ source.accepted)
  rw [← source.installed] at preserved
  exact congrArg ParserState.position preserved

inductive ProcedurePrefixAt (text : Source) (readFrame : ParserState) (declarationCount : Nat) :
    ParserState → Nat → List ScalarFunctions.Actual → ParserState → Prop
  | done {frame : ParserState} {index : Nat} : frame.position ≠ 0 →
      frame.procedures.parameters.length < index → ProcedurePrefixAt text readFrame declarationCount frame index [] frame
  | skip {frame final : ParserState} {index : Nat} {actuals} : frame.position ≠ 0 →
      index ≤ frame.procedures.parameters.length →
      (ProcedureBindings.parameter frame.procedures index).mode ≠ .output →
      ProcedurePrefixAt text readFrame declarationCount frame (index + 1) actuals final →
      ProcedurePrefixAt text readFrame declarationCount frame index actuals final
  | next {frame middle final : ParserState} {index : Nat} {actual actuals} : frame.position ≠ 0 →
      index ≤ frame.procedures.parameters.length →
      (ProcedureBindings.parameter frame.procedures index).mode = .output →
      ProcedurePrefixStepAt text readFrame frame (ProcedureBindings.parameter frame.procedures index) actual middle declarationCount →
      middle.procedures.parameters.length + 1 - (index + 1) < frame.procedures.parameters.length + 1 - index →
      ProcedurePrefixAt text readFrame declarationCount middle (index + 1) actuals final →
      ProcedurePrefixAt text readFrame declarationCount frame index (actual :: actuals) final

theorem procedurePrefix_reading_or_rejected (text : Source) (readFrame frame : ParserState) (index declarationCount : Nat)
    (textValid : Expressions.ValidText text) (names : Expressions.ValidNames text readFrame.names) :
    (procedurePrefixModel text readFrame frame index declarationCount).position = 0 ∨
      ∃ actuals, ProcedurePrefixAt text readFrame declarationCount frame index actuals (procedurePrefixModel text readFrame frame index declarationCount) := by
  rw [procedurePrefixModel]
  split
  · exact .inl rfl
  · rename_i positive
    split
    · rename_i stopped
      exact .inr ⟨[], .done positive stopped⟩
    · rename_i more
      split
      · rename_i input
        rcases procedurePrefix_reading_or_rejected text readFrame frame (index + 1) declarationCount textValid names
          with rejected | ⟨actuals, reading⟩
        · exact .inl rejected
        · exact .inr ⟨actuals, .skip positive (by omega) input reading⟩
      · rename_i output
        dsimp only
        split
        · exact .inl rfl
        · rename_i accepted
          split
          · rename_i advanced
            obtain ⟨actual, step⟩ := procedurePrefixStep_reading textValid names accepted
            rcases procedurePrefix_reading_or_rejected text readFrame
                (procedurePrefixStep text readFrame frame (ProcedureBindings.parameter frame.procedures index) declarationCount)
                (index + 1) declarationCount textValid names with rejected | ⟨actuals, reading⟩
            · exact .inl rejected
            · exact .inr ⟨actual :: actuals, .next positive (by omega) (Classical.byContradiction output)
                step advanced reading⟩
          · exact .inl rfl
termination_by frame.procedures.parameters.length + 1 - index
decreasing_by all_goals first | omega | assumption

theorem procedurePrefix_reading {text readFrame declarationCount frame index}
    (textValid : Expressions.ValidText text) (names : Expressions.ValidNames text readFrame.names)
    (accepted : (procedurePrefixModel text readFrame frame index declarationCount).position ≠ 0) :
    ∃ actuals, ProcedurePrefixAt text readFrame declarationCount frame index actuals (procedurePrefixModel text readFrame frame index declarationCount) :=
  (procedurePrefix_reading_or_rejected text readFrame frame index declarationCount textValid names).resolve_left accepted

theorem ProcedurePrefixAt.complete {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) :
    procedurePrefixModel text readFrame frame index declarationCount = final := by
  induction source with
  | done positive stopped =>
      rw [procedurePrefixModel, ite_eq_right positive, dite_eq_left stopped]
  | skip positive more input _ ih =>
      rw [procedurePrefixModel, ite_eq_right positive, dite_eq_right (by omega), ite_eq_left input]
      exact ih
  | next positive more output first advanced _ ih =>
      rw [procedurePrefixModel, ite_eq_right positive, dite_eq_right (by omega),
        ite_eq_right (not_not_intro output)]
      dsimp only
      rw [first.complete, ite_eq_right first.accepted, dite_eq_left advanced]
      exact ih

theorem ProcedurePrefixAt.fields {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) : ProcedurePrefixFields frame final := by
  induction source with
  | done => rfl
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih => exact first.fields.trans ih

/-- The output prefix selects writable scalar formals. Its successful steps preserve
all input array descriptors as well as the type environment and physical pool. -/
theorem ProcedurePrefixAt.arrays {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) :
    final.arrayNames = frame.arrayNames := by
  induction source with
  | done => rfl
  | skip _ _ _ _ ih => exact ih
  | next _ _ output step _ _ ih =>
      have accepted := step.installed ▸ step.accepted
      have scalar := appendProcedureParameter_writable_type (by rw [output]; decide) accepted
      exact ih.trans ((congrArg ParserState.arrayNames step.installed).trans
        (appendProcedureParameter_scalar_arrays scalar accepted))

theorem ProcedurePrefixAt.positive {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) : final.position ≠ 0 := by
  induction source with
  | done positive _ => exact positive
  | skip _ _ _ _ ih | next _ _ _ _ _ _ ih => exact ih

theorem ProcedurePrefixAt.grows {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) :
    frame.scalarNames.length ≤ final.scalarNames.length ∧ frame.booleanNames.length ≤ final.booleanNames.length := by
  induction source with
  | done => exact ⟨Nat.le_refl _, Nat.le_refl _⟩
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      have step := appendProcedureParameter_grows _ _ (first.installed ▸ first.accepted)
      rw [← first.installed] at step
      exact ⟨Nat.le_trans step.1 ih.1, Nat.le_trans step.2 ih.2⟩

theorem ProcedurePrefixAt.length {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final)
    (types : ArrayBindings.TypeEnvironment := []) :
    actuals.length = (ScalarProcedures.outTypes (ProcedureBindings.formalModels frame.procedures index
      (frame.procedures.parameters.length + 1 - index) types)).length := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.procedures.parameters.length + 1 - index = 0 := by omega
      simp [empty, ProcedureBindings.formalModels, ScalarProcedures.outTypes]
  | @skip before final index actuals _ more input _ ih =>
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      cases mode : (ProcedureBindings.parameter before.procedures index).mode <;>
        simp_all [ProcedureBindings.formalModel, ProcedureBindings.modeModel, ScalarProcedures.outTypes]
  | @next before middle final index actual actuals _ more output first _ _ ih =>
      have preserved := congrArg ParserState.procedures first.fields
      change middle.procedures = before.procedures at preserved
      rw [preserved] at ih
      have remaining : before.procedures.parameters.length + 1 - index =
          (before.procedures.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, ProcedureBindings.formalModels]
      simpa only [ProcedureBindings.formalModel, output, ProcedureBindings.modeModel,
        ScalarProcedures.outTypes, List.length_cons] using congrArg Nat.succ ih

theorem ProcedurePrefixAt.progress {text readFrame declarationCount frame index actuals final}
    (source : ProcedurePrefixAt text readFrame declarationCount frame index actuals final) :
    frame.position ≤ final.position ∧ (frame.position < final.position ↔ actuals ≠ []) := by
  induction source with
  | done => exact ⟨Nat.le_refl _, by simp⟩
  | skip _ _ _ _ ih => exact ih
  | next _ _ _ first _ _ ih =>
      have advanced : _ < _ := first.position.symm ▸ first.advances
      constructor
      · omega
      · constructor
        · intro _ impossible
          cases impossible
        · intro _
          omega

theorem ProcedurePrefixAt.unique {text readFrame declarationCount frame index
    left right leftFinal rightFinal}
    (first : ProcedurePrefixAt text readFrame declarationCount frame index left leftFinal)
    (second : ProcedurePrefixAt text readFrame declarationCount frame index right rightFinal) :
    left = right ∧ leftFinal = rightFinal := by
  refine ⟨?_, first.complete.symm.trans second.complete⟩
  induction first generalizing right rightFinal with
  | done _ stopped =>
      cases second with
      | done => rfl
      | skip _ more | next _ more => omega
  | skip _ more input _ ih =>
      cases second with
      | done _ stopped => omega
      | skip _ _ _ rest => exact ih rest
      | next _ _ output => exact False.elim (input output)
  | next _ more output one _ _ ih =>
      cases second with
      | done _ stopped => omega
      | skip _ _ input => exact False.elim (input output)
      | next _ _ _ two _ rest =>
          have middle := one.complete.symm.trans two.complete
          cases middle
          have same := (actual_unique one.value two.value).1
          rw [same, ih rest]

end Silver.Compose
