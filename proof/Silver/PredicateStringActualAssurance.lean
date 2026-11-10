module

public import Silver.PredicateStringActualInitializers

@[expose] public section

namespace Silver.Compose
open Bindings StringObjectBounds

def emptyBoundsStore : BoundsStore := fun _ => .canonical 0

theorem emptyBoundsStore_compatible (input : Source) : emptyBoundsStore.Compatible [] input := by
  intro index info absent
  simp [BindingEnvironment.get] at absent

theorem executeDeclarationsBounds_append (input : Source) (first rest : List Declaration) (bounds : BoundsStore) :
    executeDeclarationsBounds input (first ++ rest) bounds =
      executeDeclarationsBounds input rest (executeDeclarationsBounds input first bounds) := by
  induction first generalizing bounds with
  | nil => rfl
  | cons declaration remaining ih => exact ih _

end Silver.Compose

namespace Silver.Predicate
open Bindings Compose StringObjectBounds

def Program.actualBounds (program : Program) (arguments : Arguments.Runtime.Arguments) : BoundsStore :=
  executeDeclarationsBounds (program.input arguments) program.declarations emptyBoundsStore

theorem header_lead_actual_compatible {source program form before after strings}
    (region : HeaderRegionFacts source program form before after strings)
    (arguments : Arguments.Runtime.Arguments) :
    (executeDeclarationsBounds (program.input arguments) (headerLeadDeclarations form) emptyBoundsStore).Compatible
      before.names (program.input arguments) := by
  intro index info selected
  have cell : before.names.shape index = some info.cell := by simp [BindingEnvironment.shape, selected]
  rw [region.entryShape] at cell
  cases form with
  | direct => simp [headerLeadShape, Form.hasArguments, emptyShape] at cell
  | argument =>
      by_cases same : index = 1
      · subst index
        have infoCell : info.cell = ⟨.argument, false⟩ := by
          simpa [headerLeadShape, Form.hasArguments, argumentShape, Bindings.put] using cell.symm
        have dynamic : info.dynamic = true := by
          have bound := congrArg CellInfo.bound infoCell
          cases flag : info.dynamic with
          | true => rfl
          | false => simp [BindingInfo.cell, BindingInfo.bound, flag] at bound
        simpa [headerLeadDeclarations, Form.hasArguments, executeDeclarationsBounds,
          Declaration.executeBounds, argumentDeclaration, Expression.actualBounds, Operand.actualBounds,
          Operand.objectBounds, Bindings.put, Bounds.concatenate, Bounds.isNull, Bounds.canonical,
          namedModelBounds, dynamic] using
          Bounds.NullEquivalent.refl (canonical_bounds_valid (program.input_domain arguments).1)
      · simp [headerLeadShape, Form.hasArguments, argumentShape, Bindings.put, same, emptyShape] at cell

def HeaderLeadActualBoundsSafe (program : Program) (form : Form)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  form.hasArguments = true →
    argumentDeclaration.initializer.ActualBoundsSafe emptyBoundsStore [] emptyValues
      (program.input arguments) Integer.emptyStore

def RawInitializersActualBoundsSafe (source : Source) (program : Program)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  ∃ form before after strings, HeaderRegionFacts source program form before after strings ∧
    HeaderLeadActualBoundsSafe program form arguments ∧
    ActualHeaderBoundsTrace source form.helper.hasArguments (program.input arguments)
      (program.inputValid arguments) before
      (executeDeclarations (program.input arguments) (headerLeadDeclarations form) emptyValues)
      (executeDeclarationsBounds (program.input arguments) (headerLeadDeclarations form) emptyBoundsStore)
      strings program.booleanDeclarations program.booleanInitializerChecks after

private theorem actual_tokens_outer_ready {source form tokens state final events}
    (textValid : Compose.Expressions.ValidText source)
    (parsed : Sequence.TokensAt source form tokens state events final)
    (valid : OuterReadiness.ValidState source state) : OuterReadiness.ValidState source final := by
  induction parsed with
  | done => exact valid
  | next first _ ih =>
      apply ih
      rw [← first.scanned]
      exact OuterReadiness.step_valid source textValid form _ _ valid

theorem source_actual_initializers_bounds {source program} (meaning : SourceMeaning source program)
    (arguments : Arguments.Runtime.Arguments) :
    (program.actualBounds arguments).Compatible program.names (program.input arguments) ∧
      RawInitializersActualBoundsSafe source program arguments := by
  have domain : SourceDomain source := by
    obtain ⟨_, _, _, _, _, _, _, domain, _⟩ := meaning
    exact domain
  have textValid : Compose.Expressions.ValidText source := ⟨domain.1, domain.2.1⟩
  obtain ⟨form, before, after, strings, region, lead, trace⟩ := source_raw_initializers_bounds meaning arguments
  obtain ⟨events, leading⟩ := region.leading
  have ready := actual_tokens_outer_ready textValid leading (OuterReadiness.initial_valid source)
  have static := (Sequence.tokens_valid domain.2.1 leading Compose.initial_valid).1.2.2.2
  have inputDomain := program.input_domain arguments
  have entryFits : Fits before.names.shape (program.input arguments)
      (executeDeclarations (program.input arguments) (headerLeadDeclarations form) emptyValues) := by
    rw [region.entryShape]
    cases form with
    | direct => exact empty_fits _
    | argument =>
        change Fits argumentShape (program.input arguments)
          (argumentDeclaration.execute emptyValues (program.input arguments))
        simpa only [argumentShape, argumentDeclaration, Declaration.extend] using
          Bindings.declaration_preserves (empty_fits (program.input arguments)) inputDomain.2 argument_declaration_valid
  have actual := trace.actual_bounds domain.2.1 inputDomain.1 inputDomain.2 ready.base.2.1.1 ready.bounds
    entryFits static (header_lead_actual_compatible region arguments)
  refine ⟨?_, form, before, after, strings, region, ?_, actual.2⟩
  · simpa only [Program.actualBounds, region.declarationList, region.names, executeDeclarationsBounds_append] using actual.1
  · intro hasArguments
    obtain ⟨certificate, _, _, _, _, _, safe⟩ := lead hasArguments
    apply Expression.actualBoundsSafe (emptyBoundsStore_compatible _) _ safe
    simp [argumentDeclaration, Expression.BoundsOrigin, Operand.BoundsOrigin]

/-- Exact source initialization creates the bounds store. Ada sliding keeps
these target bounds; every reached runtime grouping is safe in that same store. -/
def Program.CompleteStringBoundsSafe (source : Source) (program : Program)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  program.StringBoundsSafe source arguments ∧ RawInitializersActualBoundsSafe source program arguments ∧
    StatementsActualBoundsSafe (functions := program.functionEnvironment) (procedures := program.procedureEnvironment)
      (program.actualBounds arguments) program.names
      (program.input arguments) (program.inputValid arguments) (program.initialValues arguments)
      program.statements program.initialIntegers (program.initialBooleans arguments)

theorem source_actual_string_bounds_assured {source program} (meaning : SourceMeaning source program) :
    SourceBoundsRefinement source program ∧ ∀ arguments, program.CompleteStringBoundsSafe source arguments := by
  have modeled := source_string_bounds_assured meaning
  refine ⟨modeled.1, ?_⟩
  intro arguments
  have actual := source_actual_initializers_bounds meaning arguments
  exact ⟨modeled.2 arguments, actual.2,
    statements_actualBoundsSafe actual.1 modeled.1.header.statements (modeled.2 arguments).2⟩

end Silver.Predicate
