module

public import Silver.ComposeDeclarations
public import Silver.ComposeStateBounds
public import Silver.PredicateConditionSound
public import Silver.PredicateConditionValidity
public import Silver.PredicateConditionUnique
public import Silver.PredicateScalarHeaderReady
public import Silver.BooleanFreezingChecks
public import Silver.BooleanShapeExtension
public import Silver.BooleanDeclarationObligations

@[expose] public section

/-! Boolean initializer traces retain the unique raw source condition and its
complete original obligations. Integer specialization changes the semantic
payload only; it never removes checks from this source projection. -/
namespace Silver.Compose
open Bindings Predicate PathFacts _root_.Silver.Compose.Expressions

def BooleanDeclarationChecksAt (text : Source) (state : ParserState)
    (declaration : BooleanDeclaration) (checks : List Predicate.Obligation) : Prop :=
  ∃ raw,
    ConditionAt text (booleanDeclarationContext state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      raw (booleanDeclarationValue text state) state.arrayNames.values ∧
    declaration = ⟨decide ((booleanDeclarationParts text state).constantAfter = 0),
      raw.freezeIntegers (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values)⟩ ∧
    checks = raw.obligations state.names.shape
      (booleanDeclarationContext state (booleanDeclarationParts text state)).analysis
      ((booleanDeclarationContext state (booleanDeclarationParts text state)).flow
        (booleanDeclarationFacts state) state.arrayNames.values)
      (BooleanBindings.analysis state.booleanNames)

theorem boolean_declaration_trace {text arguments state next}
    (textValid : ValidText text) (namesValid : ValidNames text state.names)
    (parsed : BooleanDeclarationAt text arguments state next) :
    ∃ declaration checks, BooleanDeclarationChecksAt text state declaration checks := by
  have positive := boolean_declaration_value_positive parsed
  have bounded : (booleanDeclarationParts text state).valueFirst ≤ text.length + 1 :=
    fixedAfter_result_bound text _ ":=" false (by decide)
  obtain ⟨raw, reading⟩ := (condition_sound text _ _ _ textValid namesValid bounded positive).1
  exact ⟨_, _, raw, reading, rfl, rfl⟩

theorem boolean_declaration_checks_unique {text state first second left right}
    (a : BooleanDeclarationChecksAt text state first left)
    (b : BooleanDeclarationChecksAt text state second right) : first = second ∧ left = right := by
  obtain ⟨raw, parsed, rfl, rfl⟩ := a
  obtain ⟨other, otherParsed, rfl, rfl⟩ := b
  have same := condition_unique parsed otherParsed
  cases same
  exact ⟨rfl, rfl⟩

theorem boolean_declaration_facts_bounded (state : ParserState) :
    (booleanDeclarationFacts state).path.Bounded := by
  unfold booleanDeclarationFacts
  change (if state.dynamicFirst ≠ 0 then Context.initial maxSourceLength else _).Bounded
  split
  · exact Context.initial_bounded (Nat.le_refl _)
  · change 0 ≤ maxSourceLength
    exact Nat.zero_le _

theorem boolean_declaration_meaning {text state raw}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (parsed : ConditionAt text (booleanDeclarationContext state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      raw (booleanDeclarationValue text state) state.arrayNames.values) :
    ConditionMeaning (booleanDeclarationContext state (booleanDeclarationParts text state))
      (booleanDeclarationFacts state) raw (booleanDeclarationValue text state) state.arrayNames.values := by
  apply condition_valid normal valid.2.1 _ _ (boolean_declaration_facts_bounded state) parsed
  · exact ready.contextReady valid.2.2.2.2.2.1.1
  · exact ScalarMetadata.initial_compatible ..

theorem boolean_declaration_checks_discharge {text state declaration checks}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (trace : BooleanDeclarationChecksAt text state declaration checks) :
    Predicate.discharged checks = true := by
  obtain ⟨raw, parsed, _, rfl⟩ := trace
  rw [Condition.obligations_exact (booleans := BooleanBindings.analysis state.booleanNames)]
  exact (boolean_declaration_meaning normal valid ready parsed).checked

theorem boolean_declaration_ranges_exact {state : ParserState} {parts : BooleanDeclarationParts}
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    ExactScalarRanges ((booleanDeclarationContext state parts).flow
      (booleanDeclarationFacts state) state.arrayNames.values).scalars := by
  intro index bounds found
  change ArrayBindings.ranges state.arrayNames.names state.arrayNames.values true
    (ActiveFlow.initial state.scalarNames _).model.scalars index = some bounds at found
  rw [ActiveFlow.initial_model] at found
  unfold ArrayBindings.ranges at found
  split at found
  · cases found
    rfl
  · rw [ScalarExpression.static_ranges static] at found
    simp only [Integer.Constants.ranges, Option.map_eq_some_iff] at found
    obtain ⟨value, _, rfl⟩ := found
    rfl

theorem boolean_declaration_ranges_fit {state : ParserState} {parts : BooleanDeclarationParts}
    (static : ScalarExpression.StaticEnvironment state.scalarNames) :
    Integer.Fits ((booleanDeclarationContext state parts).flow
      (booleanDeclarationFacts state) state.arrayNames.values).scalars
      (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) := by
  change Integer.Fits (ArrayBindings.ranges state.arrayNames.names state.arrayNames.values true
    (ActiveFlow.initial state.scalarNames _).model.scalars) _
  rw [ActiveFlow.initial_model]
  exact frozenIntegers_fits static

private theorem readable_initialized {condition : Condition} {shape : Shape} {arguments : Bool}
    {first second : Boolean.Analysis} (same : first.initialized = second.initialized) :
    condition.Readable arguments shape first ↔ condition.Readable arguments shape second := by
  induction condition <;> simp only [Condition.Readable, *]

private theorem checkBounds_initialized {condition : Condition} {shape : Shape} {analysis : Integer.Analysis}
    {first second : Boolean.Analysis} (same : first.initialized = second.initialized) (flow : Flow) :
    condition.checkBounds shape analysis flow first = condition.checkBounds shape analysis flow second := by
  induction condition generalizing flow <;> simp only [Condition.checkBounds, *]

theorem boolean_declaration_frozen_valid {text state declaration checks finalShape}
    (normal : NamesNormal state.names) (valid : ValidState text state)
    (ready : ScalarMetadata.HeaderReady state.scalarNames)
    (static : ScalarExpression.StaticEnvironment state.scalarNames)
    (extension : ShapeExtends state.names.shape finalShape)
    (trace : BooleanDeclarationChecksAt text state declaration checks) :
    declaration.value.Grammatical ∧
      declaration.value.Readable (decide (state.dynamicFirst ≠ 0)) finalShape
        (booleanInitialAnalysis state.booleanNames.length) ∧
      declaration.value.checkBounds finalShape Integer.Analysis.empty
        ⟨(booleanDeclarationFacts state).path, Integer.emptyRanges⟩
        (booleanInitialAnalysis state.booleanNames.length) = true := by
  obtain ⟨raw, parsed, rfl, _⟩ := trace
  have meaning := boolean_declaration_meaning normal valid ready parsed
  have readable := raw.freezeIntegers_readable (frozenIntegers state.scalarNames state.arrayNames.names state.arrayNames.values) meaning.readable
  have checked := (raw.freezeIntegers_checked (boolean_declaration_ranges_exact static)
    (boolean_declaration_ranges_fit static) meaning.checked).1
  have names : (BooleanBindings.analysis state.booleanNames).initialized =
      (booleanInitialAnalysis state.booleanNames.length).initialized := rfl
  refine ⟨raw.freezeIntegers_grammatical _ meaning.grammatical, ?_, ?_⟩
  · exact (readable_initialized names).mp (Condition.readable_extends extension readable)
  · rw [← checkBounds_initialized names]
    exact (Condition.checkBounds_extends extension readable Integer.Analysis.empty _).trans checked

end Silver.Compose
