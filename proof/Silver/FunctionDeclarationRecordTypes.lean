module

public import Silver.FunctionDeclarationNative
public import Silver.FunctionBindingsNativeEquations
public import Silver.ProcedureBindingsNativeEquations
public import Silver.ArrayBindingsNativeEquations

@[expose] public section

/-! Native record-type bounds for helpers whose declarations do not require
Valid_State. Active arrays retain arbitrary typed entries, including invalid
names and empty intervals; unused native cells are never read by these helpers. -/
namespace Silver.Compose.FunctionDeclarationNative

abbrev CursorType (position : Nat) : Prop := position ≤ 4097

def StringBindingType (item : BindingInfo) : Prop :=
  CursorType item.first ∧ CursorType item.after ∧ CursorType item.valueFirst ∧
    item.staticLength ≤ maxSourceLength ∧ Integer.InRange item.firstIndex ∧ Integer.InRange item.lastIndex

def ScalarBindingType (item : ScalarExpression.Binding) : Prop :=
  CursorType item.first ∧ CursorType item.after ∧ item.bounds.Bounded ∧ item.declaredBounds.Bounded

def BooleanBindingType (item : BooleanBindings.Binding) : Prop :=
  CursorType item.first ∧ CursorType item.after

def SubtypeBindingType (item : IntegerSubtypes.Binding) : Prop :=
  CursorType item.first ∧ CursorType item.after ∧ item.bounds.Bounded

def ArrayBindingType (item : ArrayBindings.Binding) : Prop :=
  CursorType item.first ∧ CursorType item.after ∧ item.bounds.Bounded ∧
    item.offset ≤ ArrayBindings.maxElements ∧ item.length ≤ ArrayBindings.maxElements ∧ item.componentBounds.Bounded ∧
    item.typeId ≤ ArrayBindings.maxTypes ∧ item.viewSlot ≤ ArrayBindings.maxBindings

def StringEnvironmentType (names : BindingEnvironment) : Prop :=
  names.length ≤ maxBindings ∧ ∀ item ∈ names, StringBindingType item

def ScalarEnvironmentType (names : ScalarExpression.Environment) : Prop :=
  names.length ≤ ScalarExpression.maxBindings ∧ ∀ item ∈ names, ScalarBindingType item

def BooleanEnvironmentType (names : BooleanBindings.Environment) : Prop :=
  names.length ≤ BooleanBindings.maxBindings ∧ ∀ item ∈ names, BooleanBindingType item

def SubtypeEnvironmentType (names : IntegerSubtypes.Environment) : Prop :=
  names.items.length ≤ IntegerSubtypes.maxBindings ∧ ∀ item ∈ names.items, SubtypeBindingType item

def ArrayEnvironmentType (arrays : ArrayBindings.Env) : Prop :=
  arrays.names.length ≤ ArrayBindings.maxBindings ∧
    (∀ item ∈ arrays.names, ArrayBindingType item) ∧ arrays.used ≤ ArrayBindings.maxElements ∧
    arrays.values.length ≤ ArrayBindings.maxElements ∧ ∀ value ∈ arrays.values, Integer.InRange value

structure StateRecord (state : ParserState) : Prop where
  position : CursorType state.position
  functions : FunctionBindings.Native.MetadataType state.functions
  firstParameter : state.firstParameter ≤ FunctionBindings.maxFormals
  names : StringEnvironmentType state.names
  scalars : ScalarEnvironmentType state.scalarNames
  arrays : ArrayEnvironmentType state.arrayNames
  subtypes : SubtypeEnvironmentType state.subtypeNames
  booleans : BooleanEnvironmentType state.booleanNames
  dynamicFirst : CursorType state.dynamicFirst
  dynamicAfter : CursorType state.dynamicAfter
  target : state.target ≤ maxBindings
  capacity : state.capacity ≤ maxSourceLength
  procedures : ProcedureBindings.Native.MetadataType state.procedures
  firstProcedureParameter : state.firstProcedureParameter ≤ ProcedureBindings.maxFormals
  arrayTypes : ArrayBindings.Native.TypesType state.arrayNames.types

theorem invalid_state_record : StateRecord invalidState := by
  constructor <;> simp [invalidState, CursorType, FunctionBindings.Native.MetadataType, ProcedureBindings.Native.MetadataType,
    StringEnvironmentType, ScalarEnvironmentType, ArrayEnvironmentType,
    SubtypeEnvironmentType, BooleanEnvironmentType, ArrayBindings.Native.TypesType]

/-- Native record bounds cover arbitrary typed frames, including invalid states
and unresolved type IDs. The executable guards decide whether a view is added. -/
theorem appendArrayParameter_record (frame : ParserState) (first after typeId : Nat)
    (typed : StateRecord frame) (firstBound : CursorType first) (afterBound : CursorType after)
    (typeIdBound : typeId ≤ ArrayBindings.maxTypes) :
    StateRecord (appendArrayParameter frame first after typeId) := by
  unfold appendArrayParameter
  split
  · exact invalid_state_record
  · rename_i accepted
    simp only [not_or] at accepted
    have itemValid := Classical.byContradiction accepted.2.2.2.1
    have space : frame.arrayNames.names.length < ArrayBindings.maxBindings := by
      have capacity := typed.arrays.1
      omega
    refine {typed with arrays := ?_}
    refine ⟨by simp only [List.length_append, List.length_singleton]; omega,
      ?_, typed.arrays.2.2⟩
    intro item member
    rcases List.mem_append.mp member with old | fresh
    · exact typed.arrays.2.1 item old
    · have same := List.mem_singleton.mp fresh
      subst item
      exact ⟨firstBound, afterBound, itemValid.1, Nat.zero_le _, itemValid.length_bound,
        itemValid.2.2.1, typeIdBound, by dsimp only; omega⟩

theorem appendParameter_record (frame : ParserState) (parameter : FunctionBindings.Formal)
    (typed : StateRecord frame) (parameterTyped : FunctionBindings.Native.FormalType parameter) :
    StateRecord (appendParameter frame parameter) := by
  dsimp only [appendParameter]
  split
  · exact appendArrayParameter_record frame parameter.first parameter.after parameter.typeId
      typed parameterTyped.1 parameterTyped.2.1 parameterTyped.2.2.2
  · split
    · split
      · exact invalid_state_record
      · rename_i space
        refine {typed with scalars := ?_}
        refine ⟨by have bound := typed.scalars.1; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
        intro item member
        rcases List.mem_append.mp member with old | fresh
        · exact typed.scalars.2 item old
        · have same := List.mem_singleton.mp fresh
          subst item
          exact ⟨parameterTyped.1, parameterTyped.2.1, parameterTyped.2.2.1, parameterTyped.2.2.1⟩
    · split
      · exact invalid_state_record
      · rename_i space
        refine {typed with booleans := ?_}
        refine ⟨by have bound := typed.booleans.1; simp only [List.length_append, List.length_singleton]; omega, ?_⟩
        intro item member
        rcases List.mem_append.mp member with old | fresh
        · exact typed.booleans.2 item old
        · have same := List.mem_singleton.mp fresh
          subst item
          exact ⟨parameterTyped.1, parameterTyped.2.1⟩

end Silver.Compose.FunctionDeclarationNative
