module

public import Silver.SequenceSourceChecks
public import Silver.SequenceEquations
public import Silver.SequenceModel
public import Silver.ComposeModel

@[expose] public section

/-! Correspondence for the native finite statement scanner. The rendered body
and contract checks are separate from interpretation of arbitrary callees;
recursive equations determine their denotation on every native call domain.
The concrete witness proves these premises jointly consistent. -/

namespace Silver.Sequence.SourceBridge
open Silver.Sequence.Expressions

structure CheckedSource : Prop where
  helpers : Compose.SourceBridge.CheckedSource
  bodies : Bodies
  refinements : Refinements
  declarations : Declarations
  ranges : Ranges

theorem checked_source : CheckedSource where
  helpers := Compose.SourceBridge.checked_source
  bodies := actual_bodies
  refinements := actual_refinements
  declarations := actual_declarations
  ranges := actual_ranges

/-- The documented Ada/frontend interpretation premise, stated using the exact
rendered expressions and native range/result contracts. It does not assume
membership equality, selector equality, or grammar correctness. -/
structure InterpretedSource (calls : Calls) : Prop where
  helpers : Compose.SourceBridge.InterpretedSource calls.helpers
  definitions : DefinitionEquations calls

theorem interpreted_helpers (calls : Calls) (source : InterpretedSource calls) :
    HelperMeaning calls where
  equations := Compose.SourceBridge.interpreted_equations calls.helpers source.helpers
  step := by
    intro text valid form token state tokenValid stateValid
    exact Compose.SourceBridge.interpreted_step calls.helpers source.helpers text valid form.helper token state
      (by cases form <;> simp [Form.helper, Compose.SourceBridge.NativeForm, Compose.SourceBridge.helperForms])
      tokenValid stateValid
  trivia := by
    intro text valid position positive bound
    exact (Compose.SourceBridge.interpreted_primitives calls.helpers source.helpers).trivia
      text valid.1 valid.2 position positive bound

theorem interpreted_member (calls : Calls) (source : InterpretedSource calls) (text : Source) :
    calls.member text = accepts text :=
  Expressions.interpreted_member calls (interpreted_helpers calls source) source.definitions text

theorem interpreted_arguments (calls : Calls) (source : InterpretedSource calls) (text : Source) :
    calls.arguments text = hasArguments text :=
  Expressions.interpreted_arguments calls (interpreted_helpers calls source) source.definitions text

theorem interpreted_assignment (calls : Calls) (source : InterpretedSource calls) (text : Source) :
    calls.assignment text = hasAssignment text :=
  Expressions.interpreted_assignment calls (interpreted_helpers calls source) source.definitions text

theorem interpreted_output (calls : Calls) (source : InterpretedSource calls) (text : Source) :
    calls.output text = hasOutput text :=
  Expressions.interpreted_output calls (interpreted_helpers calls source) source.definitions text

/-- GNATprove discharges these exact executable-wrapper postconditions, whose
source text is included in `checked_source.refinements`. -/
structure ExecutableRefinement (calls : Calls)
    (admit arguments assignment output : Source → Bool) : Prop where
  member : ∀ text, admit text = calls.member text
  arguments : ∀ text, arguments text = calls.arguments text
  assignment : ∀ text, assignment text = calls.assignment text
  output : ∀ text, output text = calls.output text

theorem executable_correspondence (calls : Calls) (source : InterpretedSource calls)
    (admit arguments assignment output : Source → Bool)
    (refinement : ExecutableRefinement calls admit arguments assignment output) (text : Source) :
    admit text = accepts text ∧ arguments text = hasArguments text ∧
      assignment text = hasAssignment text ∧ output text = hasOutput text :=
  ⟨(refinement.member text).trans (interpreted_member calls source text),
    (refinement.arguments text).trans (interpreted_arguments calls source text),
    (refinement.assignment text).trans (interpreted_assignment calls source text),
    (refinement.output text).trans (interpreted_output calls source text)⟩

theorem actual_source_correspondence : CheckedSource ∧
    ∀ calls, InterpretedSource calls → ∀ text,
      calls.member text = accepts text ∧ calls.arguments text = hasArguments text ∧
      calls.assignment text = hasAssignment text ∧ calls.output text = hasOutput text :=
  ⟨checked_source, fun calls source text =>
    ⟨interpreted_member calls source text, interpreted_arguments calls source text,
      interpreted_assignment calls source text, interpreted_output calls source text⟩⟩

/-- Independent consistency witness, rather than a premise of correspondence. -/
theorem model_interpreted : InterpretedSource modelCalls where
  helpers := Compose.SourceBridge.model_interpreted
  definitions := model_definitions

theorem model_executable : ExecutableRefinement modelCalls accepts hasArguments hasAssignment hasOutput where
  member _ := rfl
  arguments _ := rfl
  assignment _ := rfl
  output _ := rfl

end Silver.Sequence.SourceBridge
