module

public import Silver.FunctionBodySource
public import Silver.CallableTypeHistory

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Bindings Silver.Compose.Expressions

def functionNameFirst (text : Source) (state : ParserState) : Nat :=
  skipAt text (fixedAfter text state.position "function" true)

def functionNameAfter (text : Source) (state : ParserState) : Nat :=
  nameAfter text (functionNameFirst text state)

def functionHeaderRejected (text : Source) (state : ParserState) (arguments : Bool) : Prop :=
  fixedAfter text state.position "function" true = 0 ∨
    fixedAfter text (functionNameAfter text state) "(" false = 0 ∨ state.pure ∨
    !newNameAllowed text state (functionNameFirst text state) (functionNameAfter text state) arguments ∨
    state.functions.items.length = FunctionBindings.maxFunctions ∨
    state.functions.parameters.length = FunctionBindings.maxFormals

instance (text : Source) (state : ParserState) (arguments : Bool) :
    Decidable (functionHeaderRejected text state arguments) := inferInstanceAs (Decidable (_ ∨ _))

def functionHeaderInitial (text : Source) (state : ParserState) : ParserState :=
  {initialState with
    position := fixedAfter text (functionNameAfter text state) "(" false, pure := true,
    subtypeNames := state.subtypeNames, functions := state.functions, procedures := state.procedures,
    arrayNames := {types := state.arrayNames.types},
    «hiding» := hideName text (hiddenOuter text state) (functionNameFirst text state) (functionNameAfter text state),
    firstParameter := state.functions.parameters.length + 1}

def functionHeaderParameters (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  parametersAt text (functionHeaderInitial text state) arguments

def functionHeaderResult (text : Source) (state : ParserState) (arguments : Bool) : FunctionTypeResult :=
  let header := functionHeaderParameters text state arguments
  functionTypeAt text header (fixedAfter text header.position "return" true)

def functionHeaderFrame (text : Source) (state : ParserState) (arguments : Bool) : ParserState :=
  {functionHeaderParameters text state arguments with
    position := fixedAfter text (functionHeaderResult text state arguments).after "is" true}

inductive FunctionDeclarationSource (text : Source) (state : ParserState) (arguments : Bool) : Definition → Prop
  | parsed {definition} :
      (functionDeclarationAt text state arguments).position ≠ 0 →
      FunctionBodySource text (functionHeaderFrame text state arguments)
        (functionNameFirst text state) (functionNameAfter text state)
        (functionHeaderResult text state arguments) arguments definition →
      FunctionDeclarationSource text state arguments definition

structure FunctionHeaderStages (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  allowed : ¬functionHeaderRejected text state arguments
  parameters : (functionHeaderParameters text state arguments).position ≠ 0
  result : (functionHeaderResult text state arguments).after ≠ 0
  bodyStart : (functionHeaderFrame text state arguments).position ≠ 0
  body : (functionBodyAt text state (functionHeaderFrame text state arguments)
    (functionNameFirst text state) (functionNameAfter text state)
    (functionHeaderResult text state arguments) arguments).position ≠ 0
  equation : functionDeclarationAt text state arguments =
    functionBodyAt text state (functionHeaderFrame text state arguments)
      (functionNameFirst text state) (functionNameAfter text state)
      (functionHeaderResult text state arguments) arguments

theorem functionDeclarationAt_stages {text state arguments}
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    FunctionHeaderStages text state arguments := by
  dsimp only [functionDeclarationAt] at accepted
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i allowed
    split at accepted
    · exact False.elim (accepted rfl)
    · rename_i parameters
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i result
        refine ⟨allowed, parameters, fun zero => result (Or.inl zero),
          fun zero => result (Or.inr zero), accepted, ?_⟩
        dsimp only [functionDeclarationAt]
        rw [ite_eq_right allowed, ite_eq_right parameters, ite_eq_right result]
        rfl


structure FunctionHeaderReady (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  valid : ValidState text (functionHeaderFrame text state arguments)
  closed : ClosedFunctionState (functionHeaderFrame text state arguments)
  emptyIntegers : (functionHeaderFrame text state arguments).scalarNames = []
  emptyBooleans : (functionHeaderFrame text state arguments).booleanNames = []
  arrayTypes : (functionHeaderFrame text state arguments).arrayNames.types = state.arrayNames.types
  firstPositive : 0 < (functionHeaderFrame text state arguments).firstParameter
  signature : FunctionBindings.ValidSignature text (functionHeaderFrame text state arguments).functions
    (functionSourceEntry (functionHeaderFrame text state arguments)
      (functionNameFirst text state) (functionNameAfter text state) (functionHeaderResult text state arguments))
  catalogPrefix : catalogSignatures (functionHeaderFrame text state arguments).functions
    (functionHeaderFrame text state arguments).arrayNames.types = catalogSignatures state.functions state.arrayNames.types

theorem functionHeader_ready {text state arguments}
    (valid : ValidState text state) (stages : FunctionHeaderStages text state arguments) :
    FunctionHeaderReady text state arguments := by
  let initial := functionHeaderInitial text state
  let header := functionHeaderParameters text state arguments
  let frame := functionHeaderFrame text state arguments
  have admitted := stages.allowed
  simp only [functionHeaderRejected, not_or, Bool.not_eq_true'] at admitted
  have allowed : newNameAllowed text state (functionNameFirst text state) (functionNameAfter text state) arguments = true :=
    Bool.eq_true_of_ne_false admitted.2.2.2.1
  have cap : state.functions.parameters.length + 1 ≤ FunctionBindings.maxFormals := by
    have bounded := valid.functions.2.1
    omega
  have empty := model_invalid_state_valid text
  have initialValid : ValidState text initial := by
    refine ⟨fixedAfter_result_bound text _ "(" false (by decide), empty.2.1, empty.2.2.1,
      empty.2.2.2.1, Nat.le_refl _, empty.2.2.2.2.2.1, ArrayBindings.ValidNativeEnvironment.emptyItems valid.arrayTypes,
      valid.2.2.2.2.2.2.2.1, empty.booleans, valid.functions, Nat.le_refl _, cap,
      valid.procedures, Nat.zero_le _, Nat.zero_le _, Names.validContext_default text⟩
  have headerValid : ValidState text header := parametersModel_state_valid initialValid
  have frameValid : ValidState text frame := model_state_position_valid text header headerValid _
    (fixedAfter_result_bound text _ "is" true (by decide))
  have fields : ParameterFieldsPreserved initial header := parametersAt_fields stages.parameters
  have headerInfo : ParameterExtension text initial header :=
    (parametersAt_valid text initial arguments initialValid.functions initialValid.2.2.2.2.2.2.2.1 initialValid.arrayTypes).resolve_left
      stages.parameters
  have closed : ClosedFunctionState frame := by
    change ClosedFunctionState {header with position := frame.position}
    rw [fields]
    exact ⟨rfl, rfl, rfl, rfl⟩
  have emptyIntegers : frame.scalarNames = [] := by
    change header.scalarNames = []
    rw [fields]
    rfl
  have emptyBooleans : frame.booleanNames = [] := by
    change header.booleanNames = []
    rw [fields]
    rfl
  have first : frame.firstParameter = state.functions.parameters.length + 1 := headerInfo.firstParameter
  have firstPositive : 0 < frame.firstParameter := by rw [first]; omega
  have firstBound : frame.firstParameter ≤ frame.functions.parameters.length := by
    have grows := headerInfo.grows
    change state.functions.parameters.length < header.functions.parameters.length at grows
    change frame.firstParameter ≤ header.functions.parameters.length
    rw [first]
    omega
  have nameSpan := newNameAllowed_span text state _ _ arguments allowed
  have span : FunctionBindings.NameSpan text (functionNameFirst text state) (functionNameAfter text state) :=
    ⟨nameSpan.1, nameSpan.2, function_nameAfter_bound text _⟩
  have resultBounds := (functionTypeAt_good text header (fixedAfter text header.position "return" true)
    headerValid.2.2.2.2.2.2.2.1).resolve_left stages.result
  have signature : FunctionBindings.ValidSignature text frame.functions
      (functionSourceEntry frame (functionNameFirst text state) (functionNameAfter text state)
        (functionHeaderResult text state arguments)) :=
    ⟨span, by dsimp [functionSourceEntry]; omega, firstPositive, firstBound, Nat.le_refl _, resultBounds⟩
  have catalogPrefix : catalogSignatures frame.functions frame.arrayNames.types =
      catalogSignatures state.functions state.arrayNames.types := by
    obtain ⟨more, extended⟩ := headerInfo.parameterPrefix
    have catalog : header.functions = {state.functions with parameters := state.functions.parameters ++ more} := by
      calc
        header.functions = ⟨header.functions.items, header.functions.parameters⟩ := rfl
        _ = _ := by rw [headerInfo.items, extended]; rfl
    change catalogSignatures header.functions header.arrayNames.types = _
    rw [catalog, headerInfo.arrayTypes]
    exact catalogSignatures_append_parameters state.functions more valid.functions
  exact ⟨frameValid, closed, emptyIntegers, emptyBooleans, headerInfo.arrayTypes, firstPositive, signature, catalogPrefix⟩

theorem functionDeclarationAt_source {text state arguments}
    (textValid : ValidText text) (valid : ValidState text state)
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    ∃ definition, FunctionDeclarationSource text state arguments definition := by
  have stages := functionDeclarationAt_stages accepted
  have ready := functionHeader_ready valid stages
  obtain ⟨definition, body⟩ := functionBodyAt_source textValid ready.valid ready.firstPositive stages.body
  exact ⟨definition, .parsed accepted body⟩

theorem functionDeclarationAt_callable_types_known {text state arguments}
    (valid : ValidState text state) (known : CallableTypesKnown state)
    (accepted : (functionDeclarationAt text state arguments).position ≠ 0) :
    CallableTypesKnown (functionDeclarationAt text state arguments) := by
  have stages := functionDeclarationAt_stages accepted
  have ready := functionHeader_ready valid stages
  have initial : CallableTypesKnown (functionHeaderInitial text state) :=
    ⟨known.functions, known.procedures⟩
  have header : CallableTypesKnown (functionHeaderParameters text state arguments) :=
    parametersModel_callable_types_known text (functionHeaderInitial text state) arguments initial
  have frame : CallableTypesKnown (functionHeaderFrame text state arguments) :=
    ⟨header.functions, header.procedures⟩
  have fields := functionDeclarationAt_preserves_outer text state arguments accepted
  have parameters : (functionDeclarationAt text state arguments).functions.parameters =
      (functionHeaderFrame text state arguments).functions.parameters := by
    rw [stages.equation, (functionBodyAt_stages stages.body).2.2.2.2]
    rfl
  constructor
  · intro formal member
    rw [parameters] at member
    have bound := frame.functions formal member
    rw [ready.arrayTypes] at bound
    simpa only [fields.arrayNames] using bound
  · intro formal member
    rw [fields.procedures] at member
    simpa only [fields.arrayNames] using known.procedures formal member

theorem FunctionDeclarationSource.checked {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) (valid : ValidState text state) :
    definition.Checked (catalogSignatures state.functions state.arrayNames.types) := by
  cases source with
  | parsed accepted body =>
    have ready := functionHeader_ready valid (functionDeclarationAt_stages accepted)
    have checked := body.checked ready.valid ready.closed ready.emptyIntegers ready.emptyBooleans
      ready.firstPositive ready.signature
    rw [ready.catalogPrefix] at checked
    exact checked

theorem FunctionDeclarationSource.catalog {text state arguments definition}
    (source : FunctionDeclarationSource text state arguments definition) (valid : ValidState text state) :
    catalogSignatures (functionDeclarationAt text state arguments).functions
        (functionDeclarationAt text state arguments).arrayNames.types =
      catalogSignatures state.functions state.arrayNames.types ++ [definition.signature] := by
  cases source with
  | parsed accepted body =>
    have stages := functionDeclarationAt_stages accepted
    have ready := functionHeader_ready valid stages
    have arrays := (functionDeclarationAt_preserves_outer text state arguments accepted).arrayNames
    rw [arrays, stages.equation, (functionBodyAt_stages stages.body).2.2.2.2, catalogSignatures_append]
    have catalogPrefix := ready.catalogPrefix
    rw [ready.arrayTypes] at catalogPrefix
    rw [catalogPrefix, body.signature, ready.arrayTypes]

end Silver.Compose
