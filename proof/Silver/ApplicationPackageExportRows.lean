module

public import Silver.ApplicationPackageFrameCapacity
public import Silver.ApplicationPackageDeclarationsSignatureStates

@[expose] public section

namespace Silver.ApplicationPackageExportRows
open Compose Compose.Expressions ApplicationPackageDeclarations ApplicationPackageObjectRows
open PackageBindings (Metadata)

/-- Information retained by the accepted specification before the body can
install any state. The exported scalar and Boolean tables come from the actual
constant/subtype/routine traversal. -/
structure ExportRows (original info : Metadata) (exports : ParserState) : Prop where
  order : FrameOrder exports
  capacity : exports.scalarNames.length ≤ ScalarExpression.maxBindings
  states : info.states = original.states
  units : info.units = original.units
  completed : info.completed = original.completed

private def StepRows (original : Metadata) : SpecificationStep → Prop
  | .returned result => result.exports.position = 0
  | .ready state | .next state => ExportRows original state.info state.exports

theorem reframe {before after : ParserState} (order : FrameOrder before)
    (integers : after.scalarNames = before.scalarNames) (booleans : after.booleanNames = before.booleanNames)
    (progress : before.position ≤ after.position) : FrameOrder after := by
  have keptInts : integerRows after = integerRows before := congrArg (List.map _) integers
  have keptFlags : flagRows after = flagRows before := congrArg (List.map _) booleans
  constructor
  · rw [keptInts]
    exact ⟨order.1.ordered, fun row member => Nat.lt_of_lt_of_le (order.1.before row member) progress⟩
  · rw [keptFlags]
    exact ⟨order.2.ordered, fun row member => Nat.lt_of_lt_of_le (order.2.before row member) progress⟩

private theorem continue_rows {original : Metadata} (calls : SpecificationCalls) (text : Source)
    (before : Nat) (state : SpecificationState)
    (source : before < state.exports.position → ExportRows original state.info state.exports) :
    StepRows original (continueSpecification calls text before state) := by
  dsimp only [continueSpecification]
  split
  · rfl
  · rename_i pass
    exact source (Nat.lt_of_not_ge (fun failed => pass (by simp [failed])))

private theorem signature_completed (text : Source) (frame : ParserState) (info : Metadata) :
    (readSignature text frame info false).info.completed = info.completed := by
  have kept := congrArg Metadata.completed (readSignature_exec text frame info false).retains_fields
  exact kept

private theorem routine_rows (reader : BooleanElaboration.Native.Reader) (text : Source)
    {original : Metadata} (state : SpecificationState) (prior : ExportRows original state.info state.exports) :
    StepRows original (specificationRoutine (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationRoutine]
  split
  · rfl
  · apply continue_rows
    intro advanced
    exact ⟨reframe prior.order rfl rfl (Nat.le_of_lt advanced), prior.capacity,
      (readSignature_states ..).trans prior.states, (readSignature_units ..).trans prior.units,
      (signature_completed ..).trans prior.completed⟩

private theorem subtype_fields {text : Source} {before after : ParserState} {arguments : Bool}
    (read : SubtypeDeclarationAt text arguments before after) :
    after.scalarNames = before.scalarNames ∧ after.booleanNames = before.booleanNames := by
  cases read
  exact ⟨rfl, rfl⟩

private theorem subtype_rows (reader : BooleanElaboration.Native.Reader) (text : Source)
    {original : Metadata} (state : SpecificationState) (prior : ExportRows original state.info state.exports) :
    StepRows original (specificationSubtype (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationSubtype]
  split
  · rfl
  · rename_i present
    split
    · rfl
    · unfold appendExport
      apply continue_rows
      intro advanced
      have kept := subtype_fields (subtype_declaration_sound text state.exports false present)
      exact ⟨reframe prior.order kept.1 kept.2 (Nat.le_of_lt advanced), kept.1 ▸ prior.capacity,
        prior.states, prior.units, prior.completed⟩

private theorem object_rows (reader : BooleanElaboration.Native.Reader) (text : Source)
    {original : Metadata} (state : SpecificationState) (prior : ExportRows original state.info state.exports) :
    StepRows original (specificationObject (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationObject]
  split
  · rfl
  · rename_i checked
    have present : (objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position ≠ 0 := by
      intro zero
      apply checked
      change (decide ((objectStep (modelObjectCalls reader) text state.exports state.info false).frame.position = 0) || _) = true
      simp [zero]
    unfold appendExport
    apply continue_rows
    intro _
    exact ⟨objectStep_frameOrder rfl present prior.order, objectStep_capacity rfl present prior.capacity,
      prior.states, prior.units, prior.completed⟩

private theorem step_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (state : SpecificationState)
    {original : Metadata} (prior : ExportRows original state.info state.exports) :
    StepRows original (specificationStep (modelSpecificationCalls reader) text state) := by
  dsimp only [specificationStep]
  split
  · exact prior
  · split
    · exact routine_rows reader text state prior
    · split
      · rfl
      · split
        · exact subtype_rows reader text state prior
        · exact object_rows reader text state prior

private def ExitRows (original : Metadata) : SpecificationExit → Prop
  | .returned result => result.exports.position = 0
  | .ready state => ExportRows original state.info state.exports

private theorem loop_rows {reader : BooleanElaboration.Native.Reader} {text : Source}
    {before : SpecificationState} {exit : SpecificationExit}
    (run : SpecificationLoop (modelSpecificationCalls reader) text before exit) {original : Metadata}
    (prior : ExportRows original before.info before.exports) : ExitRows original exit := by
  induction run with
  | returned step =>
    have checked := step_rows reader text _ prior
    rw [step] at checked
    exact checked
  | ready step =>
    have checked := step_rows reader text _ prior
    rw [step] at checked
    exact checked
  | next step _ ih =>
    have checked := step_rows reader text _ prior
    rw [step] at checked
    exact ih checked

private def StartRows (info : Metadata) : SpecificationStart → Prop
  | .returned result => result.exports.position = 0
  | .loop state => ExportRows info state.info state.exports

private theorem start_rows (calls : SpecificationCalls) (text : Source) (info : Metadata) :
    StartRows info (specificationStart calls text info) := by
  dsimp only [specificationStart]
  split
  · rfl
  · split
    · assumption
    · have empty (position : Nat) : BeforeCursor position [] := ⟨.nil, by simp⟩
      exact ⟨⟨empty _, empty _⟩, Nat.zero_le _, rfl, rfl, rfl⟩

private theorem footer_position {text : Source} {position : Nat}
    (present : fixedAfter text (nameAfter text (skipAt text (fixedAfter text position "end" true))) ";" false ≠ 0) :
    position < fixedAfter text (nameAfter text (skipAt text (fixedAfter text position "end" true))) ";" false ∧
      fixedAfter text (nameAfter text (skipAt text (fixedAfter text position "end" true))) ";" false ≤ text.length + 1 := by
  have named := model_name_advances text _ (fixedAfter_nonzero present)
  have word : fixedAfter text position "end" true ≠ 0 := by
    intro missing
    simp [missing, skipAt] at named
  have start := fixed_window (by decide) word
  have skipped := skipAt_advances text _ start.2 (Nat.ne_of_gt named.1)
  have semi := fixed_window (by decide) present
  exact ⟨Nat.lt_trans start.1 (Nat.lt_of_le_of_lt skipped (Nat.lt_trans named.2 semi.1)), semi.2⟩

private theorem finish_rows (reader : BooleanElaboration.Native.Reader) (text : Source) {original : Metadata}
    (state : SpecificationState) (prior : ExportRows original state.info state.exports) :
    let out := finishSpecification (modelSpecificationCalls reader) text state
    out.exports.position ≠ 0 → ExportRows original out.info out.exports ∧ out.exports.position ≤ text.length + 1 := by
  dsimp only [finishSpecification]
  split
  · exact fun present => False.elim (present rfl)
  · intro present
    have done := footer_position present
    exact ⟨⟨reframe prior.order rfl rfl (Nat.le_of_lt done.1), prior.capacity,
      prior.states, prior.units, prior.completed⟩, done.2⟩

theorem specification_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (info : Metadata)
    (accepted : (readSpecification reader text info).exports.position ≠ 0) :
    let out := readSpecification reader text info
    ExportRows info out.info out.exports ∧ out.exports.position ≤ text.length + 1 := by
  have entered := start_rows (modelSpecificationCalls reader) text info
  have run := readSpecification_exec reader text info
  unfold SpecificationExec at run
  cases seen : specificationStart (modelSpecificationCalls reader) text info with
  | returned failed =>
    simp only [seen] at entered run
    exact False.elim (accepted (run ▸ entered))
  | loop state =>
    simp only [seen] at entered run
    obtain ⟨exit, history, result⟩ := run
    have reached := loop_rows history entered
    cases exit with
    | returned failed =>
      exact False.elim (accepted (result ▸ reached))
    | ready finalState =>
      dsimp only at result
      rw [result] at accepted ⊢
      exact finish_rows reader text finalState reached accepted

end Silver.ApplicationPackageExportRows
