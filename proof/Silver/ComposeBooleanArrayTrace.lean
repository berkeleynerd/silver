module

public import Silver.ComposeBooleanTrace
public import Silver.ComposeBooleanArrayElaboration

@[expose] public section

/-! The complete aggregate trace reads every Boolean condition in the same
incoming declaration environment. Allocation placeholders affect only the
result state; they never enter the name or value environment of a sibling. -/
namespace Silver.Compose
open Bindings Predicate PathFacts _root_.Silver.Compose.Expressions

inductive BooleanArrayValuesAt (text : Source) (source : ParserState) (maskFirst maskAfter : Nat) :
    Nat → Nat → Nat → List Condition → Nat → Prop
  | done {position length parsed : Nat} : position ≠ 0 → length ≤ parsed →
      BooleanArrayValuesAt text source maskFirst maskAfter position length parsed [] position
  | next {position length parsed finish : Nat} {raw : Condition} {result : ConditionResult}
      {rest : List Condition} :
      parsed < length →
      ConditionAt text (booleanInitializerContext source maskFirst maskAfter) position
        (booleanInitializerFacts source) raw result source.arrayNames.values →
      BooleanArrayValuesAt text source maskFirst maskAfter
        (if parsed + 1 < length then fixedAfter text result.after "," false else result.after)
        length (parsed + 1) rest finish →
      BooleanArrayValuesAt text source maskFirst maskAfter position length parsed (raw :: rest) finish

theorem booleanArrayValues_trace (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (textValid : ValidText text) (namesValid : ValidNames text source.names)
    (bound : position ≤ text.length + 1)
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0) :
    ∃ raw, BooleanArrayValuesAt text source maskFirst maskAfter position length parsed raw
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position := by
  rw [booleanArrayValuesModel] at positive ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
  · simp only [zero, ↓reduceIte] at positive ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at positive ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
      · simp only [bad, ↓reduceIte] at positive ⊢
        have read := condition_sound text (booleanInitializerContext source maskFirst maskAfter)
          position (booleanInitializerFacts source) textValid namesValid bound bad
        obtain ⟨raw, reading⟩ := read.1
        have nextBound : (if parsed + 1 < length then
            fixedAfter text (booleanInitializerAfter text source position maskFirst maskAfter) "," false
          else booleanInitializerAfter text source position maskFirst maskAfter) ≤ text.length + 1 := by
          split
          · exact fixedAfter_result_bound text _ "," false (by decide)
          · exact read.2
        obtain ⟨rest, following⟩ := booleanArrayValues_trace text source _ _ length (parsed + 1)
          maskFirst maskAfter textValid namesValid nextBound positive
        exact ⟨raw :: rest, .next remaining reading following⟩
    · simp only [remaining, ↓reduceDIte]
      exact ⟨[], .done zero (Nat.le_of_not_gt remaining)⟩
termination_by length - parsed
decreasing_by omega

theorem BooleanArrayValuesAt.length {text source maskFirst maskAfter position length parsed raw finish}
    (trace : BooleanArrayValuesAt text source maskFirst maskAfter position length parsed raw finish) :
    raw.length = length - parsed := by
  induction trace with
  | done _ complete => simp only [List.length_nil]; omega
  | next remaining _ _ ih => simp only [List.length_cons]; omega

theorem BooleanArrayValuesAt.unique {text source maskFirst maskAfter position length parsed left right first last}
    (a : BooleanArrayValuesAt text source maskFirst maskAfter position length parsed left first)
    (b : BooleanArrayValuesAt text source maskFirst maskAfter position length parsed right last) :
    left = right ∧ first = last := by
  induction a generalizing right last with
  | done positive complete =>
      cases b with
      | done => exact ⟨rfl, rfl⟩
      | next remaining => omega
  | next remaining reading rest ih =>
      cases b with
      | done _ complete => omega
      | next _ other following =>
          have rawSame := condition_unique reading other
          have resultSame := (condition_complete reading).symm.trans (condition_complete other)
          cases rawSame
          cases resultSame
          obtain ⟨rfl, rfl⟩ := ih following
          exact ⟨rfl, rfl⟩

def booleanArrayRawChecks (state : ParserState) (maskFirst maskAfter : Nat)
    (raw : List Condition) : List Predicate.Obligation :=
  raw.flatMap fun value => value.obligations state.names.shape
    (booleanInitializerContext state maskFirst maskAfter).analysis
    ((booleanInitializerContext state maskFirst maskAfter).flow
      (booleanInitializerFacts state) state.arrayNames.values)
    (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames))

def BooleanArrayDeclarationChecksAt (text : Source) (state : ParserState)
    (declaration : BooleanArrayDeclaration) (checks : List Predicate.Obligation) : Prop :=
  ∃ parts position raw finish,
    arrayDeclarationParts text state = parts ∧
    ArrayAggregateAt text state parts position ∧
    BooleanArrayValuesAt text state parts.first parts.after position parts.length 0 raw finish ∧
    declaration = ⟨(parts.binding state).booleanDescriptor, decide (parts.constantAfter = 0),
      raw.map (fun value => value.freezeIntegers
        (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values))⟩ ∧
    checks = booleanArrayRawChecks state parts.first parts.after raw

theorem boolean_array_declaration_trace {text arguments state final}
    (textValid : ValidText text) (namesValid : ValidNames text state.names)
    (parsed : BooleanArrayDeclarationAt text arguments state final) :
    ∃ declaration checks, BooleanArrayDeclarationChecksAt text state declaration checks := by
  cases parsed with
  | @declaration values parts lower upper position following partsEq _ _ _ aggregate valuesEq positive _ _ =>
      have bound : position ≤ text.length + 1 := by
        cases aggregate with
        | positional =>
            rw [← partsEq]
            exact fixedAfter_result_bound text _ "(" false (by decide)
        | singleton =>
            exact fixedAfter_result_bound text _ "=>" false (by decide)
      obtain ⟨raw, trace⟩ := booleanArrayValues_trace text state state position parts.length 0
        parts.first parts.after textValid namesValid bound (valuesEq.symm ▸ positive)
      exact ⟨_, _, parts, position, raw, _, partsEq, aggregate, trace, rfl, rfl⟩

theorem boolean_array_declaration_checks_unique {text state first second left right}
    (a : BooleanArrayDeclarationChecksAt text state first left)
    (b : BooleanArrayDeclarationChecksAt text state second right) : first = second ∧ left = right := by
  obtain ⟨parts, position, raw, finish, partsEq, aggregate, trace, rfl, rfl⟩ := a
  obtain ⟨otherParts, otherPosition, otherRaw, otherFinish, otherEq, otherAggregate, otherTrace, rfl, rfl⟩ := b
  have partsSame := partsEq.symm.trans otherEq
  cases partsSame
  have positionSame := (arrayAggregate_complete aggregate).symm.trans (arrayAggregate_complete otherAggregate)
  cases positionSame
  have rawSame := (trace.unique otherTrace).1
  cases rawSame
  exact ⟨rfl, rfl⟩

/-- Shared allocation offsets place every new Boolean cell above all existing
array cells and above the reserved scalar Boolean identity range. -/
theorem boolean_array_fresh_cell {text : Source} {state : ParserState} {cell : Nat}
    (valid : ValidState text state)
    (fresh : BooleanBindings.maxBindings + 1 + state.arrayNames.used ≤ cell) :
    (ArrayBindings.booleanAnalysis state.arrayNames.names
      (BooleanBindings.analysis state.booleanNames)).initialized cell = false := by
  have arrays := valid.2.2.2.2.2.2.1
  have scalars := valid.booleans.1
  apply Bool.or_eq_false_iff.mpr
  constructor
  · apply List.any_eq_false.mpr
    intro item member inside
    have inNames := (ArrayBindings.mem_booleanNames.mp member).1
    have itemValid := (arrays.1.2.1 item inNames).2.2.2
    have length := ArrayBindings.binding_booleanDescriptor_length itemValid
    have used := arrays.2.2.2 item inNames
    have contained := of_decide_eq_true inside
    change item.booleanDescriptor.base ≤ cell ∧
      cell < item.booleanDescriptor.base + item.booleanDescriptor.length at contained
    rw [length] at contained
    simp only [ArrayBindings.Binding.booleanDescriptor] at contained
    omega
  · simp only [BooleanBindings.analysis, decide_eq_false_iff_not]
    omega

theorem boolean_array_declaration_analysis {text arguments state next declaration checks}
    (valid : ValidState text state)
    (parsed : BooleanArrayDeclarationAt text arguments state next)
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks) :
    0 < declaration.array.base ∧
      (∀ offset, offset < declaration.values.length →
        (ArrayBindings.booleanAnalysis state.arrayNames.names
          (BooleanBindings.analysis state.booleanNames)).initialized (declaration.array.base + offset) = false) ∧
      ArrayBindings.booleanAnalysis next.arrayNames.names (BooleanBindings.analysis next.booleanNames) =
        booleanDeclarationsAnalysis
          (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames))
          declaration.initializations := by
  obtain ⟨parts, position, raw, finish, partsEq, aggregate, rawValues, rfl, _⟩ := trace
  cases parsed with
  | @declaration values parsedParts lower upper first following parsedEq allowed low high _ valuesEq positive _ _ =>
      have same := partsEq.symm.trans parsedEq
      cases same
      have bindingValid := boolean_array_declaration_binding_valid partsEq allowed low high
      have fields := booleanArrayValuesModel_fields text state state first parts.length 0 parts.first parts.after
        (valuesEq.symm ▸ positive)
      rw [valuesEq] at fields
      have names := congrArg (fun state => state.arrayNames.names) fields
      have booleans := congrArg ParserState.booleanNames fields
      have count : raw.length = (parts.binding state).booleanDescriptor.length := by
        rw [rawValues.length, Nat.sub_zero, ArrayBindings.binding_booleanDescriptor_length bindingValid]
        rfl
      refine ⟨by change 0 < BooleanBindings.maxBindings + 1 + (parts.binding state).offset; omega, ?_, ?_⟩
      · intro offset _
        apply boolean_array_fresh_cell valid
        change BooleanBindings.maxBindings + 1 + state.arrayNames.used ≤
          BooleanBindings.maxBindings + 1 + state.arrayNames.used + offset
        omega
      · rw [BooleanArrayDeclaration.initializations_analysis _ _ (by simpa using count)]
        change ArrayBindings.booleanAnalysis (values.arrayNames.names ++ [parts.binding state])
          (BooleanBindings.analysis values.booleanNames) = _
        rw [names, booleans]
        apply ArrayBindings.booleanAnalysis_append_fresh
        · exact allowed.kind
        · intro cell inside
          apply boolean_array_fresh_cell valid
          exact inside.1

theorem boolean_initializer_meaning {text state maskFirst maskAfter position raw result}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (parsed : ConditionAt text (booleanInitializerContext state maskFirst maskAfter) position
      (booleanInitializerFacts state) raw result state.arrayNames.values) :
    ConditionMeaning (booleanInitializerContext state maskFirst maskAfter)
      (booleanInitializerFacts state) raw result state.arrayNames.values := by
  apply condition_valid normal valid.2.1 _ _ _ (boolean_declaration_facts_bounded state) parsed
  · exact ready.contextReady valid.2.2.2.2.2.1.1
  · exact ⟨valid.2.2.2.2.2.2.1.1, valid.2.2.2.2.2.2.1.1.2.2⟩
  · exact ScalarMetadata.initial_compatible ..

theorem BooleanArrayValuesAt.valid {text state maskFirst maskAfter position length parsed raw finish}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (trace : BooleanArrayValuesAt text state maskFirst maskAfter position length parsed raw finish) :
    ∀ value ∈ raw, value.Grammatical ∧
      value.Readable (decide (state.dynamicFirst ≠ 0)) state.names.shape
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) ∧
      value.checkBounds state.names.shape (booleanInitializerContext state maskFirst maskAfter).analysis
        ((booleanInitializerContext state maskFirst maskAfter).flow
          (booleanInitializerFacts state) state.arrayNames.values)
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) = true := by
  induction trace with
  | done => intro value member; cases member
  | next _ reading _ ih =>
      intro value member
      rcases List.mem_cons.mp member with rfl | member
      · have meaning := boolean_initializer_meaning normal valid ready reading
        exact ⟨meaning.grammatical, meaning.readable, meaning.checked⟩
      · exact ih value member

theorem booleanArrayRawChecks_discharge (state : ParserState) (maskFirst maskAfter : Nat)
    (raw : List Condition)
    (checked : ∀ value ∈ raw,
      value.checkBounds state.names.shape (booleanInitializerContext state maskFirst maskAfter).analysis
        ((booleanInitializerContext state maskFirst maskAfter).flow
          (booleanInitializerFacts state) state.arrayNames.values)
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) = true) :
    Predicate.discharged (booleanArrayRawChecks state maskFirst maskAfter raw) = true := by
  unfold booleanArrayRawChecks
  induction raw with
  | nil => rfl
  | cons value rest ih =>
      rw [List.flatMap_cons, Predicate.discharged_append,
        Condition.obligations_exact (booleans := ArrayBindings.booleanAnalysis state.arrayNames.names
          (BooleanBindings.analysis state.booleanNames)), checked value (by simp), Bool.true_and]
      exact ih (fun item member => checked item (by simp [member]))

theorem boolean_array_declaration_checks_discharge {text state declaration checks}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks) :
    Predicate.discharged checks = true := by
  obtain ⟨parts, position, raw, finish, _, _, values, _, rfl⟩ := trace
  exact booleanArrayRawChecks_discharge state parts.first parts.after raw
    (fun value member => (values.valid normal valid ready value member).2.2)

theorem boolean_initializer_ranges_exact {state : ParserState} {maskFirst maskAfter : Nat}
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ExactScalarRanges ((booleanInitializerContext state maskFirst maskAfter).flow
      (booleanInitializerFacts state) state.arrayNames.values).scalars := by
  intro index bounds found
  change ArrayBindings.integerRanges state.arrayNames.names state.arrayNames.values true
    (ActiveFlow.initial state.scalarNames _).model.scalars index = some bounds at found
  rw [ActiveFlow.initial_model] at found
  unfold ArrayBindings.integerRanges ArrayBindings.ranges at found
  split at found
  · cases found
    rfl
  · rw [ScalarExpression.static_ranges static] at found
    simp only [Integer.Constants.ranges, Option.map_eq_some_iff] at found
    obtain ⟨value, _, rfl⟩ := found
    rfl

theorem boolean_initializer_ranges_fit {state : ParserState} {maskFirst maskAfter : Nat}
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    Integer.Fits ((booleanInitializerContext state maskFirst maskAfter).flow
      (booleanInitializerFacts state) state.arrayNames.values).scalars
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) := by
  change Integer.Fits (ArrayBindings.integerRanges state.arrayNames.names state.arrayNames.values true
    (ActiveFlow.initial state.scalarNames _).model.scalars) _
  rw [ActiveFlow.initial_model]
  exact frozenIntegers_fits static

theorem boolean_array_declaration_frozen_valid {text state declaration checks finalShape}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (extension : ShapeExtends state.names.shape finalShape)
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks) :
    ∀ value ∈ declaration.values, value.Grammatical ∧
      value.Readable (decide (state.dynamicFirst ≠ 0)) finalShape
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) ∧
      value.checkBounds finalShape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts state).path, Integer.emptyRanges⟩
        (ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames)) = true := by
  obtain ⟨parts, position, raw, finish, _, _, values, rfl, _⟩ := trace
  have meaning := values.valid normal valid ready
  intro frozen member
  change frozen ∈ raw.map (fun value => value.freezeIntegers
    (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)) at member
  obtain ⟨value, rawMember, rfl⟩ := List.mem_map.mp member
  have current := meaning value rawMember
  have readable := value.freezeIntegers_readable
    (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) current.2.1
  have checked := (value.freezeIntegers_checked (boolean_initializer_ranges_exact static)
    (boolean_initializer_ranges_fit static) current.2.2).1
  exact ⟨value.freezeIntegers_grammatical _ current.1,
    Condition.readable_extends extension readable,
    (Condition.checkBounds_extends extension readable Integer.Analysis.empty _).trans checked⟩

/-- The accepted source aggregate's expanded initializers evaluate each
component in the incoming Boolean store, even though allocation is represented
by an ordered list of targeted initialization events. -/
theorem boolean_array_declaration_snapshot {text arguments state next declaration checks}
    {values : Values} {input : Source} {valid rejected : Bool} {incoming : Boolean.Store}
    (normal : NamesNormal state.names) (stateValid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (parsed : BooleanArrayDeclarationAt text arguments state next)
    (trace : BooleanArrayDeclarationChecksAt text state declaration checks)
    (fits : Fits state.names.shape input values)
    (allowed : (booleanDeclarationFacts state).path.Allows valid input.length rejected) :
    executeBooleanDeclarations values input valid Integer.emptyStore declaration.initializations incoming =
      snapshotBooleanDeclarations values input valid Integer.emptyStore incoming declaration.initializations incoming := by
  have allocation := boolean_array_declaration_analysis stateValid parsed trace
  have frozen := boolean_array_declaration_frozen_valid normal stateValid ready static
    (fun _ _ present => present) trace
  apply declaration.initializations_snapshot allocation.2.1
    (fun value member => (frozen value member).2.1)
    (fun value member => (frozen value member).2.2) fits
  exact ⟨allowed, fun _ _ absent => by cases absent⟩

end Silver.Compose
