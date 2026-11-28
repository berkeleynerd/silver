module

public import Silver.ApplicationPackageRoutineRows
public import Silver.ApplicationPackageFormalReferences
public import Silver.ApplicationPackageObjectLayout

@[expose] public section

namespace Silver.ApplicationPackageFormalStorage
open Compose ApplicationPackageBodies ApplicationPackageRoutineFrame ApplicationPackageObjectRows ApplicationPackageFrameLayout
open PackageBindings (Formal)

def Apart (rows : List Row) (formals : List Formal) : Prop :=
  ∀ row ∈ rows, ∀ formal ∈ formals, row.first ≠ formal.bodyName.first

/-- Output-only declarations have header spans, but remain absent throughout
the local declaration and output-RHS phases. -/
structure LocalFrame (states : List PackageBindings.StateDeclaration) (outputs : List Formal) (frame : ParserState) : Prop where
  source : StateFrame states frame
  outputBefore : ∀ formal ∈ outputs, formal.bodyName.first < frame.position
  scalarApart : Apart (integerRows frame) outputs
  flagApart : Apart (flagRows frame) outputs
  outputOrder : OrderedRows (references outputs)
  distinctStates : ∀ formal ∈ outputs, ∀ state ∈ states, formal.bodyName.first ≠ state.name.first

private theorem entry_rows (calls : ApplicationPackageRoutineFrame.Calls)
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment) (globals : ParserState) (position : Nat) :
    integerRows (entryFrame calls globals position) = integerRows globals ∧
      flagRows (entryFrame calls globals position) = flagRows globals := by
  constructor
  · simp [integerRows, entryFrame, body, ScalarExpression.bodyEnvironment, List.map_map, Function.comp_def]
  · simp only [flagRows, entryFrame, List.map_map, Function.comp_def]
    apply List.map_congr_left
    intro row _
    cases mutable : row.mutable <;> simp [forgetMutable, mutable]

private theorem enter_order {start stop : Nat} {prior added : List Row} {formals : List Formal}
    (original : BeforeCursor start prior) (window : HeaderWindow start stop formals)
    (selected : added.Sublist (references formals)) : BeforeCursor stop (prior ++ added) := by
  constructor
  · rw [OrderedRows, List.pairwise_append]
    exact ⟨original.ordered, window.reference_order.sublist selected,
      fun row member next included => Nat.lt_of_lt_of_le (original.before row member)
        (window.reference_bounds (selected.subset included)).1⟩
  · intro row member
    rcases List.mem_append.mp member with old | new
    · exact Nat.lt_of_lt_of_le (original.before row old) window.progress
    · exact (window.reference_bounds (selected.subset new)).2

private theorem entered_apart {start stop : Nat} {prior added : List Row} {info : PackageBindings.Metadata}
    {indices : List Nat} (original : BeforeCursor start prior) (window : HeaderWindow start stop (indices.map info.parameterAt))
    (selected : added.Sublist (references (chosen false info indices))) : Apart (prior ++ added) (chosen true info indices) := by
  intro row member output later
  have out := (chosen_sublist true info indices).subset later
  rcases List.mem_append.mp member with old | new
  · exact Nat.ne_of_lt (Nat.lt_of_lt_of_le (original.before row old) (window.entries output out).1)
  · obtain ⟨input, earlier, rfl⟩ := List.mem_map.mp (selected.subset new)
    apply window.different ((chosen_sublist false info indices).subset earlier) out
    intro same
    subst output
    have conflicting := (chosen_mode earlier).symm.trans (chosen_mode later)
    contradiction

theorem routineFrame_source {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (prior : StateFrame info.states globals)
    (window : HeaderWindow globals.position position ((formalIndices (info.routineAt routine)).map info.parameterAt))
    (parsed : routineFrame calls text globals info routine position = after) (present : after.position ≠ 0) :
    LocalFrame info.states (chosen true info (formalIndices (info.routineAt routine))) after := by
  obtain ⟨hidden, retained, added⟩ := routineFrame_tables hide append parsed present
  obtain ⟨integers, flags, intRefs, flagRefs, intTable, flagTable⟩ := added.references
  have entry := entry_rows calls body globals position
  have intKept : (integerRows hidden).Sublist (integerRows globals) := by
    rw [← entry.1]; exact retained.integers.map _
  have flagKept : (flagRows hidden).Sublist (flagRows globals) := by
    rw [← entry.2]; exact retained.flags.map _
  have oldInts := prior.order.1.retain intKept
  have oldFlags := prior.order.2.retain flagKept
  have cursor : after.position = position := added.position.trans retained.position
  have inputs := window.retain (chosen_sublist false info _)
  have initialFields : ScalarStateFields info.states (entryFrame calls globals position).scalarNames := by
    simpa only [entryFrame, body] using prior.scalarFields.bodyEnvironment
  refine ⟨⟨?_, ?_, ?_⟩, ?_, ?_, ?_, ?_, ?_⟩
  · constructor
    · rw [cursor, intTable]; exact enter_order oldInts inputs intRefs
    · rw [cursor, flagTable]; exact enter_order oldFlags inputs flagRefs
  · intro state member
    rw [cursor]
    exact Nat.lt_of_lt_of_le (prior.statesBefore state member) window.progress
  · apply added.state_fields
    · intro row member
      exact initialFields row (retained.integers.subset member)
    · intro formal member state declared
      exact Nat.ne_of_gt (Nat.lt_of_lt_of_le (prior.statesBefore state declared) (inputs.entries formal member).1)
  · intro formal member
    rw [cursor]
    exact (window.entries formal ((chosen_sublist true info _).subset member)).2
  · rw [intTable]
    exact entered_apart oldInts window intRefs
  · rw [flagTable]
    exact entered_apart oldFlags window flagRefs
  · exact (window.retain (chosen_sublist true info _)).reference_order
  · intro formal member state included
    exact Nat.ne_of_gt (Nat.lt_of_lt_of_le (prior.statesBefore state included)
      (window.entries formal ((chosen_sublist true info _).subset member)).1)

end Silver.ApplicationPackageFormalStorage
