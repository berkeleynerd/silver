module

public import Silver.ComposeBooleanDeclarationLibraries
public import Silver.ComposeBooleanInitializerLibraries
public import Silver.PredicateNativeLibraries

@[expose] public section

namespace Silver.Compose.SourceBridge
open Silver.Compose.Expressions

/-- Raw literal equations and direct identities select the predicate used by
the Boolean wrapper. Its normalized helper meaning is derived below. -/
def PredicateImportSource (predicate : Predicate.Native.Calls) (calls : Expressions.Calls) : Prop :=
  ∃ (literals : IntegerLiteral.Native.Calls) (integer : Source → Nat → IntegerLiteral.Result),
    IntegerLiteral.Native.Equations literals ∧
      (∀ text, IntegerLiteral.Native.ValidText text → ∀ position, position ≤ text.length + 1 →
        integer text position = literals.model text position) ∧
      Predicate.Native.Libraries.Links predicate calls integer

theorem PredicateImportSource.meaning {predicate calls}
    (source : PredicateImportSource predicate calls)
    (raw : RawHelperEquations calls (domain := Predicate.OuterReadiness.domain)) :
    Predicate.Native.HelperMeaning predicate := by
  obtain ⟨literals, integer, equations, refinement, links⟩ := source
  exact Predicate.Native.Libraries.helper_meaning predicate calls raw literals equations integer refinement links

/-- The complete ordinary Boolean declaration law, on its written native
state domain, is an output of source interpretation. -/
def BooleanDeclarationMeaning (calls : Expressions.Calls) : Prop :=
  ∀ text, ValidText text → ∀ state arguments, Predicate.OuterReadiness.ValidState text state →
    calls.function .booleanDeclaration text state arguments = booleanDeclarationAt text state arguments

def BooleanInitializerMeaning (calls : Expressions.Calls) : Prop :=
  ∀ text, ValidText text → ∀ state position first after,
    Predicate.OuterReadiness.ValidState text state → ValidCursor text position →
    (⟨first, after⟩ : Named.NameState).Valid text →
    calls.function .booleanInitializer text state position first after =
      booleanInitializerAfter text state position first after

/-- The same predicate appears in its raw library links, definitions,
contracts and the wrapper's direct callee identities. -/
structure BooleanDeclarationInterpretation (calls : Expressions.Calls) : Prop where
  source : ∃ (imports : BooleanDeclarationNative.Imports) (predicate : Predicate.Native.Calls),
    PredicateImportSource predicate calls ∧
    Predicate.Native.DefinitionEquations predicate ∧ Predicate.Native.Contracts predicate ∧
    BooleanDeclarationNative.Libraries.Links imports calls predicate ∧
    ∀ text, ValidText text → ∀ state arguments,
      Predicate.OuterReadiness.ValidState text state →
      calls.function .booleanDeclaration text state arguments =
        BooleanDeclarationNative.body.eval imports {text, state, arguments}

structure BooleanInitializerInterpretation (calls : Expressions.Calls) : Prop where
  source : ∃ (imports : BooleanInitializerNative.Imports) (predicate : Predicate.Native.Calls),
    PredicateImportSource predicate calls ∧
    Predicate.Native.DefinitionEquations predicate ∧ Predicate.Native.Contracts predicate ∧
    BooleanInitializerNative.Libraries.Links imports predicate ∧
    ∀ text, ValidText text → ∀ state position first after,
      Predicate.OuterReadiness.ValidState text state → ValidCursor text position →
      (⟨first, after⟩ : Named.NameState).Valid text →
      calls.function .booleanInitializer text state position first after =
        BooleanInitializerNative.body.eval imports ⟨text, state, position, first, after⟩

theorem BooleanDeclarationInterpretation.meaning {calls : Expressions.Calls}
    (source : BooleanDeclarationInterpretation calls)
    (raw : RawHelperEquations calls (domain := Predicate.OuterReadiness.domain)) :
    BooleanDeclarationMeaning calls := by
  obtain ⟨imports, predicate, predicateSource, definitions, contracts, links, equation⟩ := source.source
  have helpers := predicateSource.meaning raw
  intro text tv state arguments ready
  exact (equation text tv state arguments ready).trans
    (BooleanDeclarationNative.Libraries.declaration_meaning raw helpers definitions contracts links
      text tv state arguments ready)

theorem BooleanInitializerInterpretation.meaning {calls : Expressions.Calls}
    (source : BooleanInitializerInterpretation calls)
    (raw : RawHelperEquations calls (domain := Predicate.OuterReadiness.domain)) :
    BooleanInitializerMeaning calls := by
  obtain ⟨imports, predicate, predicateSource, definitions, contracts, links, equation⟩ := source.source
  have helpers := predicateSource.meaning raw
  intro text tv state position first after ready bounded mask
  exact (equation text tv state position first after ready bounded mask).trans
    (BooleanInitializerNative.Libraries.imports_meaning helpers definitions contracts links
      text tv state position first after ready bounded mask)

theorem model_predicate_import_source :
    PredicateImportSource Predicate.Native.modelCalls Expressions.modelCalls :=
  ⟨IntegerLiteral.Native.modelCalls, IntegerLiteral.read, IntegerLiteral.Native.model_equations,
    fun _ _ _ _ => rfl, Predicate.Native.Libraries.model_links⟩

theorem model_boolean_declaration_interpretation :
    BooleanDeclarationInterpretation Expressions.modelCalls where
  source := by
    refine ⟨BooleanDeclarationNative.modelImports, Predicate.Native.modelCalls,
      model_predicate_import_source, Predicate.Native.model_definition_equations,
      Predicate.Native.model_contracts, BooleanDeclarationNative.Libraries.model_links, ?_⟩
    intro text _ state arguments _
    exact (BooleanDeclarationNative.model_meaning text state arguments).symm

theorem model_boolean_initializer_interpretation :
    BooleanInitializerInterpretation Expressions.modelCalls where
  source := by
    refine ⟨BooleanInitializerNative.modelImports, Predicate.Native.modelCalls,
      model_predicate_import_source, Predicate.Native.model_definition_equations,
      Predicate.Native.model_contracts, BooleanInitializerNative.Libraries.model_links, ?_⟩
    intro text _ state position first after _ _ _
    exact (BooleanInitializerNative.model_meaning ⟨text, state, position, first, after⟩).symm

end Silver.Compose.SourceBridge
