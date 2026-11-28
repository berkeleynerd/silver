module

public import Silver.ApplicationPackageFrames
public import Silver.PredicateOuterReadiness

@[expose] public section

namespace Silver.ApplicationPackageFrames
open Compose Compose.Expressions

/-- Bounds provided by native field subtypes, independent of executable
`Valid_State`. They do not assert a reachable declaration history. -/
structure StateType (state : ParserState) : Prop where
  context : 1 ≤ state.contextFirst
  capacity : state.capacity ≤ maxSourceLength
  namesCount : state.names.length ≤ Compose.maxBindings
  names : ∀ item ∈ state.names, item.staticLength ≤ maxSourceLength ∧
    Integer.InRange item.firstIndex ∧ Integer.InRange item.lastIndex
  scalarCount : state.scalarNames.length ≤ ScalarExpression.maxBindings
  scalars : ∀ item ∈ state.scalarNames, item.bounds.Bounded ∧ item.declaredBounds.Bounded
  subtypeCount : state.subtypeNames.items.length ≤ IntegerSubtypes.maxBindings
  subtypes : ∀ item ∈ state.subtypeNames.items, item.bounds.Bounded
  booleanCount : state.booleanNames.length ≤ BooleanBindings.maxBindings
  firstParameter : state.firstParameter ≤ FunctionBindings.maxFormals
  firstProcedureParameter : state.firstProcedureParameter ≤ ProcedureBindings.maxFormals

theorem nameStateValid_meaning (text : Source) (first after : Nat) :
    nameStateValid text first after = true ↔ Names.ValidNameState text first after := by
  simp only [nameStateValid, Names.ValidNameState, decide_eq_true_eq]

theorem nameStateValid_positive {text : Source} {first after : Nat}
    (positive : 0 < first) (valid : nameStateValid text first after = true) :
    first < after ∧ after ≤ text.length + 1 := by
  have checked := (nameStateValid_meaning ..).mp valid
  rcases checked with empty | present
  · omega
  · exact present.2

theorem stringNamesValid_item {text : Source} {names : BindingEnvironment}
    (valid : stringNamesValid text names = true) (index : Nat) (bound : index < names.length) :
    0 < names[index].first ∧ nameStateValid text names[index].first names[index].after = true ∧
      names[index].valueFirst ≤ text.length + 1 ∧
      fixedBoundsValid names[index].staticLength names[index].dynamic names[index].isCharacter
        names[index].firstIndex names[index].lastIndex (index + 1) = true := by
  have checked := List.all_eq_true.mp valid index (List.mem_range.mpr bound)
  simpa only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound, Option.getD_some,
    Bool.and_eq_true, decide_eq_true_eq, and_assoc] using checked

theorem stateValid_domain {text : Source} {state : ParserState}
    (typed : StateType state) (valid : stateValid text state = true) :
    Predicate.OuterReadiness.ValidState text state := by
  have ready := stateValid_ready valid
  simp only [stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at valid
  rcases valid with ⟨position, context, packageName, functions, procedures, firstParameter,
    firstProcedureParameter, names, scalars, arrays, subtypes, booleans, _, _, dynamicName, target⟩
  have stringFields (item : BindingInfo) (member : item ∈ state.names) :
      ValidInfo text item := by
    obtain ⟨index, bounded, same⟩ := List.getElem_of_mem member
    have fields := stringNamesValid_item names index bounded
    rw [same] at fields
    exact ⟨⟨fields.1, (nameStateValid_positive fields.1 fields.2.1).1,
      (nameStateValid_positive fields.1 fields.2.1).2⟩, fields.2.2.1, (typed.names item member).1⟩
  have scalarFields : ScalarExpression.ValidEnvironment text state.scalarNames := by
    refine ⟨typed.scalarCount, ?_⟩
    intro item member
    have checked := List.all_eq_true.mp scalars item member
    simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc] at checked
    have span := nameStateValid_positive checked.1 checked.2.1
    exact ⟨checked.1, span.1, span.2, (typed.scalars item member).1,
      (typed.scalars item member).2, (nameStateValid_meaning ..).mp checked.2.2⟩
  have subtypeFields : IntegerSubtypes.ValidEnvironment text state.subtypeNames := by
    refine ⟨typed.subtypeCount, ?_⟩
    intro item member
    have checked := List.all_eq_true.mp subtypes item member
    simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.not_eq_true', and_assoc] at checked
    have span := nameStateValid_positive checked.1 checked.2.1
    have nonempty := checked.2.2.2
    simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty
    exact ⟨checked.1, span.1, span.2, typed.subtypes item member, by omega,
      (nameStateValid_meaning ..).mp checked.2.2.1⟩
  have booleanFields : BooleanBindings.ValidEnvironment text state.booleanNames := by
    refine ⟨typed.booleanCount, ?_⟩
    intro item member
    have checked := List.all_eq_true.mp booleans item member
    simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc] at checked
    have span := nameStateValid_positive checked.1 checked.2.1
    exact ⟨checked.1, span.1, span.2, (nameStateValid_meaning ..).mp checked.2.2⟩
  refine ⟨⟨position, ⟨typed.namesCount, stringFields⟩,
    (nameStateValid_meaning ..).mp dynamicName, target, typed.capacity, scalarFields,
    arrays, subtypeFields, booleanFields, functions, firstParameter, typed.firstParameter,
    procedures, firstProcedureParameter, typed.firstProcedureParameter,
    typed.context, context, (nameStateValid_meaning ..).mp packageName⟩, ready, ?_⟩
  intro slot item present
  have nonzero : slot ≠ 0 := by
    intro zero
    simp only [Bindings.BindingEnvironment.get, zero, ↓reduceIte] at present
    contradiction
  have selected : state.names[slot - 1]? = some item := by
    simpa only [Bindings.BindingEnvironment.get, nonzero, ↓reduceIte] using present
  have bounds := List.getElem?_eq_some_iff.mp selected
  have fields := stringNamesValid_item names (slot - 1) bounds.1
  rw [bounds.2] at fields
  have machine := (typed.names item (List.mem_of_getElem? selected)).2
  exact ⟨machine.1, machine.2, by simpa only [Nat.sub_add_cancel (by omega : 1 ≤ slot)] using fields.2.2.2⟩

end Silver.ApplicationPackageFrames
