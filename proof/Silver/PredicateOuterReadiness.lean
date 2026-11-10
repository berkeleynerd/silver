module

public import Silver.PredicateInitialFlowValidity
public import Silver.ComposeStateBounds
public import Silver.CallableDeclarationPreservation
public import Silver.ComposeScalarDeclarations
public import Silver.ComposeNativeStateBounds

@[expose] public section

namespace Silver.Predicate
open Compose

attribute [local irreducible] ScalarExpression.read


namespace OuterReadiness

structure ValidState (text : Source) (state : ParserState) : Prop where
  base : Compose.Expressions.ValidState text state
  ready : ScalarMetadata.HeaderReady state.scalarNames
  bounds : NamesBoundsValid state.names

/-- The exact strengthened state domain used by inherited native helpers. -/
def domain : Compose.Expressions.StateDomain where
  holds := ValidState
  valid := fun _ _ valid => valid.1
  transportScalar := by
    intro text before after context valid same names
    exact ⟨valid, by rw [same]; exact context.2, by rw [names]; exact context.bounds⟩

theorem ValidState.nativeState {text : Source} {state : ParserState} (valid : ValidState text state) :
    Compose.Expressions.NativeState domain text state := ⟨valid, valid.bounds⟩

theorem initial_valid (text : Source) : ValidState text initialState := by
  refine ⟨?_, ScalarMetadata.headerReady_empty, namesBoundsValid_empty⟩
  simp [Compose.Expressions.ValidState, Compose.Expressions.ValidCursor, Compose.Expressions.ValidNames,
    Named.NameState.Valid, initialState, maxSourceLength, maxBindings,
    ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings,
    ArrayBindings.ValidEnvironment, ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials,
    IntegerSubtypes.ValidEnvironment, BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFormals, FunctionBindings.maxFunctions,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxFormals, ProcedureBindings.maxProcedures]

theorem invalid_valid (text : Source) : ValidState text invalidState :=
  ⟨Compose.Expressions.model_invalid_state_valid text, ScalarMetadata.headerReady_empty, namesBoundsValid_empty⟩

theorem subtypeDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (subtypeDeclarationAt text state arguments).scalarNames := by
  unfold subtypeDeclarationAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · exact ready

theorem scalarDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (scalarDeclarationAt text state arguments).scalarNames := by
  unfold scalarDeclarationAt
  generalize scalarDeclarationParts text state = parts
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · rename_i admitted
    have checked : ScalarDeclarationReady text state arguments parts := by
      simpa [ScalarDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, Int.not_lt, and_assoc] using admitted
    rcases checked with ⟨_, _, _, _, _, nonempty, _, lower, upper, _⟩
    exact ready.append nonempty (fun _ => ⟨lower, upper⟩)

theorem stringDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (stringDeclarationAt text state arguments).scalarNames := by
  unfold stringDeclarationAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · exact ready

theorem characterDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (characterDeclarationAt text state arguments).scalarNames := by
  unfold characterDeclarationAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · exact ready

theorem arrayDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (arrayDeclarationAt text state arguments).scalarNames := by
  unfold arrayDeclarationAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · split
    · exact ScalarMetadata.headerReady_empty
    · split
      · exact ScalarMetadata.headerReady_empty
      · rename_i accepted
        split
        · exact ScalarMetadata.headerReady_empty
        · rw [(arrayDeclarationValues_preserves accepted).2.1]
          exact ready

theorem booleanDeclaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (booleanDeclarationAt text state arguments).scalarNames := by
  unfold booleanDeclarationAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · split
    · exact ScalarMetadata.headerReady_empty
    · exact ready

theorem declaration_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (declarationAt text state arguments).scalarNames := by
  rw [declarationAt_callable_equation]
  split
  · rename_i accepted
    rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames]
    exact ready
  · split
    · exact subtypeDeclaration_ready text state arguments ready
    · split
      · exact scalarDeclaration_ready text state arguments ready
      · split
        · rename_i accepted
          rw [(arrayDeclarationAt_count accepted).2.1]
          exact ready
        · split
          · exact booleanDeclaration_ready text state arguments ready
          · split
            · exact characterDeclaration_ready text state arguments ready
            · exact stringDeclaration_ready text state arguments ready
private theorem declarationsLoop_ready (text : Source) (arguments : Bool) (fuel : Nat) (state : ParserState)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (declarationsLoop text arguments fuel state).scalarNames := by
  induction fuel generalizing state with
  | zero => exact ScalarMetadata.headerReady_empty
  | succ fuel ih =>
      rw [declarationsLoop]
      split
      · exact ScalarMetadata.headerReady_empty
      · split
        · exact ready
        · split
          · exact ScalarMetadata.headerReady_empty
          · exact ih _ (declaration_ready text state arguments ready)

theorem argument_ready (text : Source) (state : ParserState)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (argumentAt text state).scalarNames := by
  unfold argumentAt
  dsimp only
  split
  · exact ScalarMetadata.headerReady_empty
  · exact ready

theorem declarations_ready (text : Source) (state : ParserState) (arguments : Bool)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (declarationsAt text state arguments).scalarNames :=
  declarationsLoop_ready text arguments _ state ready

theorem step_ready (text : Source) (form : Compose.Form) (token : ShellToken) (state : ParserState)
    (ready : ScalarMetadata.HeaderReady state.scalarNames) :
    ScalarMetadata.HeaderReady (Compose.step text form token state).scalarNames := by
  unfold Compose.step
  split
  · exact ScalarMetadata.headerReady_empty
  · cases token with
    | contextClauses | fixed | literal => exact ready
    | declarations => exact declarationsLoop_ready text _ _ state ready
    | argumentDeclaration =>
        unfold argumentAt
        dsimp only
        split
        · exact ScalarMetadata.headerReady_empty
        · exact ready
    | capacity | dynamicReference | assignmentTarget | targetReference | assignmentValue |
        outputExpression | comparisonExpression =>
        simp only [capacityAt, dynamicAt, targetAt, assignmentAt, outputAt, Compose.comparisonAt]
        repeat' first | exact ready | exact ScalarMetadata.headerReady_empty | split

theorem step_valid (text : Source) (tv : Compose.Expressions.ValidText text)
    (form : Compose.Form) (token : ShellToken) (state : ParserState) (valid : ValidState text state) :
    ValidState text (Compose.step text form token state) :=
  ⟨Compose.Expressions.model_step_valid text tv form token state valid.1,
    step_ready text form token state valid.2,
    Compose.Expressions.model_step_bounds text tv form token state valid.bounds⟩

end OuterReadiness
end Silver.Predicate
