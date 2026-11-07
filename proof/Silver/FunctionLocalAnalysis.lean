module

public import Silver.FunctionInitializerShape
public import Silver.FunctionParameterMeaning
public import Silver.PredicateScalarGuardMeaning

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions Silver.Compose.Expressions

private theorem local_staticness_flags (names : ScalarExpression.Environment) :
    ScalarMetadata.staticness names = Integer.nameFlags (names.map (·.isStatic)) := by
  funext index
  by_cases zero : index = 0
  · simp [ScalarMetadata.staticness, Integer.nameFlags, zero]
  · by_cases inside : index - 1 < names.length
    · have active : 0 < index ∧ index ≤ names.length := by omega
      simp [ScalarMetadata.staticness, Integer.nameFlags, ScalarExpression.binding,
        active, zero, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]
    · have outside : ¬(0 < index ∧ index ≤ names.length) := by omega
      simp [ScalarMetadata.staticness, Integer.nameFlags, outside, zero,
        List.getElem?_eq_none (by omega : names.length ≤ index - 1)]

private theorem local_declaration_staticFlags {text arguments state next declaration}
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    next.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) [declaration] := by
  cases parsed with
  | @declaration parts value _ _ _ reading =>
      have static := reading.staticValue
      rw [inferred_staticness reading.inferred, local_staticness_flags] at static
      by_cases constant : parts.constantAfter = 0 <;>
        simp [addScalarBinding, Integer.declarationStaticFlags, Integer.Expr.freezeArrays_static, constant, static]


theorem FunctionLocalsAt.static_flags {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final) :
    final.scalarNames.map (·.isStatic) =
      Integer.declarationStaticFlags (state.scalarNames.map (·.isStatic)) integers := by
  induction source with
  | done => rfl
  | integer _ _ first _ _ _ ih =>
      rw [ih, local_declaration_staticFlags first]
      rfl
  | boolean _ _ _ first _ _ _ ih => cases first; exact ih

theorem FunctionLocalsAt.local_analysis {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (valid : ValidState text state) (empty : state.scalarNames = []) :
    functionScalarAnalysis final final.scalarNames.length = Integer.Analysis.ofDeclarations integers := by
  have elaborated : ScalarExpression.ElaboratedEnvironment state.scalarNames := by
    rw [empty]
    exact ScalarExpression.static_empty
  have objects : ScalarExpression.objectBindings final.scalarNames = Integer.elaborate [] integers := by
    simpa only [empty, ScalarExpression.objectBindings, ScalarExpression.constants,
      List.map_nil, List.nil_append] using
      source.scalar_objects elaborated valid.2.2.2.2.2.1.1 valid.2.2.2.2.2.2.2.1
  have flags := source.static_flags
  simp only [empty, List.map_nil] at flags
  have ranges := ScalarExpression.objectBindings_ranges final.scalarNames
  have mutable := ScalarExpression.objectBindings_mutability final.scalarNames
  rw [objects] at ranges mutable
  have static : ScalarMetadata.staticness (ScalarExpression.bodyEnvironment final.scalarNames) =
      Integer.nameFlags (Integer.declarationStaticFlags [] integers) := by
    rw [local_staticness_flags]
    simpa only [ScalarExpression.bodyEnvironment, List.map_map, Function.comp_def,
      ScalarExpression.bodyBinding_static] using congrArg Integer.nameFlags flags
  have refinable : ScalarMetadata.refinable (ScalarExpression.bodyEnvironment final.scalarNames)
      final.scalarNames.length =
      ScalarExpression.mutability (ScalarExpression.bodyEnvironment final.scalarNames) := by
    rw [← ScalarExpression.bodyEnvironment_length final.scalarNames]
    exact ScalarMetadata.refinable_declarations _
  simp only [functionScalarAnalysis, ScalarMetadata.analysis, Integer.Analysis.ofDeclarations]
  rw [← ranges, ← mutable, static, refinable, ← mutable]

private theorem empty_local_boolean_analysis :
    ArrayBindings.booleanAnalysis [] (BooleanBindings.analysis []) = ({} : Boolean.Analysis) := by
  unfold ArrayBindings.booleanAnalysis ArrayBindings.booleanNames BooleanBindings.analysis
  congr 1 <;> funext index <;> simp <;> omega

private theorem empty_array_boolean_analysis (analysis : Boolean.Analysis) :
    ArrayBindings.booleanAnalysis [] analysis = analysis := rfl

theorem FunctionLocalsAt.local_boolean_analysis
    {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (valid : ValidState text state) (empty : state.booleanNames = [])
    (arrays : state.arrayNames.names = []) :
    BooleanBindings.analysis final.booleanNames = booleanBodyAnalysis booleans := by
  have known := source.boolean_analysis valid
  rw [source.preserves.arrayNames, arrays, empty, empty_local_boolean_analysis,
    empty_array_boolean_analysis] at known
  exact known

end Silver.Compose
