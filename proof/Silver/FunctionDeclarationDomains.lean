module

public import Silver.FunctionDeclarationNative
public import Silver.PredicateScalarHeaderReady

@[expose] public section

/-! The function parser uses the existing checked Valid_State representation
boundary. This module spells out its scalar-value and String-bound clauses;
capacity and First_Parameter ceilings come from Parser_State component types.
No extra reachability or declaration-history hypothesis is introduced. -/
namespace Silver.Compose.FunctionDeclarationNative
open Silver.Compose.Expressions

/-- Direct active-prefix meaning of the pinned Valid_Mutable_Bounds body. -/
def MutableBounds (names : ScalarExpression.Environment) : Prop :=
  ∀ item ∈ names, item.mutable = true →
    item.bounds.isEmpty = false ∧ item.declaredBounds.lower ≤ item.bounds.lower ∧
      item.bounds.upper ≤ item.declaredBounds.upper

/-- Valid_Declaration_Values is invoked with Count = Scalar_Names.Count, so
its count comparison is reflexive and its quantified prefix is the full table. -/
def DeclarationValues (names : ScalarExpression.Environment) : Prop :=
  ∀ item ∈ names, item.bounds.isEmpty = false

theorem headerReady_iff (names : ScalarExpression.Environment) :
    Predicate.ScalarMetadata.HeaderReady names ↔ MutableBounds names ∧ DeclarationValues names := by
  constructor
  · intro ready
    exact ⟨fun item member mutable => ⟨(ready item member).1, (ready item member).2 mutable⟩,
      fun item member => (ready item member).1⟩
  · rintro ⟨mutable, values⟩ item member
    exact ⟨values item member, fun yes => (mutable item member yes).2⟩

/-- Clauses of the pinned native Valid_State expression, in source order.
Each environment predicate uses its existing source/representation bridge;
Valid_Names includes the separately established object-bound invariant. -/
structure StateClauses (text : Source) (state : ParserState) : Prop where
  position : state.position ≤ text.length + 1
  functions : FunctionBindings.ValidMetadata text state.functions
  procedures : ProcedureBindings.ValidMetadata text state.procedures
  firstParameter : state.firstParameter ≤ state.functions.parameters.length + 1
  firstProcedureParameter : state.firstProcedureParameter ≤ state.procedures.parameters.length + 1
  names : ValidNames text state.names ∧ NamesBoundsValid state.names
  scalars : ScalarExpression.ValidEnvironment text state.scalarNames
  arrays : ArrayBindings.ValidEnvironment text state.arrayNames
  subtypes : IntegerSubtypes.ValidEnvironment text state.subtypeNames
  booleans : BooleanBindings.ValidEnvironment text state.booleanNames
  mutableBounds : MutableBounds state.scalarNames
  declarationValues : DeclarationValues state.scalarNames
  dynamic : (⟨state.dynamicFirst, state.dynamicAfter⟩ : Named.NameState).Valid text
  target : state.target ≤ state.names.length

structure StateTypeBounds (state : ParserState) : Prop where
  capacity : state.capacity ≤ maxSourceLength
  firstParameter : state.firstParameter ≤ FunctionBindings.maxFormals
  firstProcedureParameter : state.firstProcedureParameter ≤ ProcedureBindings.maxFormals

structure NativeValidState (text : Source) (state : ParserState) : Prop where
  base : ValidState text state
  ready : Predicate.ScalarMetadata.HeaderReady state.scalarNames
  bounds : NamesBoundsValid state.names

/-- The strengthened parser input is exactly the existing checked predicate
plus the three native component bounds omitted from its Boolean expression. -/
theorem nativeValidState_iff (text : Source) (state : ParserState) :
    NativeValidState text state ↔ StateTypeBounds state ∧ StateClauses text state := by
  constructor
  · rintro ⟨base, ready, bounds⟩
    rcases base with ⟨position, names, dynamic, target, capacity, scalars, arrays,
      subtypes, booleans, functions, firstParameter, parameterCapacity, procedures, procedureFirst, procedureCapacity⟩
    have values := (headerReady_iff state.scalarNames).mp ready
    exact ⟨⟨capacity, parameterCapacity, procedureCapacity⟩, ⟨position, functions, procedures, firstParameter, procedureFirst,
      ⟨names, bounds⟩, scalars, arrays, subtypes, booleans, values.1, values.2, dynamic, target⟩⟩
  · rintro ⟨typed, clauses⟩
    exact ⟨⟨clauses.position, clauses.names.1, clauses.dynamic, clauses.target,
      typed.capacity, clauses.scalars, clauses.arrays, clauses.subtypes, clauses.booleans,
      clauses.functions, clauses.firstParameter, typed.firstParameter, clauses.procedures,
      clauses.firstProcedureParameter, typed.firstProcedureParameter⟩,
      (headerReady_iff state.scalarNames).mpr ⟨clauses.mutableBounds, clauses.declarationValues⟩,
      clauses.names.2⟩

/-- Connect a caller's state-domain name to precisely these existing native
clauses. Root integration instantiates this with OuterReadiness.domain. -/
structure ExactDomain (domain : StateDomain) : Prop where
  state : ∀ text state, domain.holds text state ↔ NativeValidState text state

end Silver.Compose.FunctionDeclarationNative
