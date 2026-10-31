module

public import Silver.ComposeBooleanDeclarationDomain
public import Silver.PredicateNativeHelpers

@[expose] public section

/-! Close the initializer's executed Read_Condition_Into call from its exact
native worker contract and the source-derived predicate interpretation. -/
namespace Silver.Compose.BooleanDeclarationNative.Libraries
open Predicate Compose.Expressions

set_option backward.dsimp.instances true

theorem worker_condition_meaning {condition : Native.Calls}
    (helpers : Native.HelperMeaning condition) (definitions : Native.DefinitionEquations condition)
    (contracts : Native.Contracts condition) (outputs : Native.Workers.Outputs)
    (refined : Native.Workers.Refinement Native.workerInput Native.workerChainInput condition outputs)
    (text : Source) (tv : ValidText text) (state : ParserState) (arguments : Bool)
    (valid : OuterReadiness.ValidState text state)
    (ready : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true) :
    outputs.condition text (initializerContext state (booleanDeclarationParts text state))
      (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state)
      state.scalarNames.length state.arrayNames.values = booleanDeclarationValue text state := by
  have bounds := part_bounds text state valid.1.1
  have cv := initializer_context_valid text state arguments valid ready
  have fv := initializer_flow_valid text state valid (booleanDeclarationParts text state)
  have iv := valid.1.2.2.2.2.2.2.1.2.2.1
  rw [refined.condition text _ _ _ _ _ ⟨tv, cv, bounds.valueFirst, fv⟩ iv
    (by simp [booleanDeclarationFacts, ActiveFlow.initial_count])]
  change condition.model text (initializerContext state (booleanDeclarationParts text state))
    (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state) state.arrayNames.values = _
  have call := definitions.condition text tv _ cv _ bounds.valueFirst _ fv _ iv
  change condition.condition text (initializerContext state (booleanDeclarationParts text state))
    (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state) state.arrayNames.values =
    condition.model text (initializerContext state (booleanDeclarationParts text state))
    (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state) state.arrayNames.values at call
  rw [← call, Native.condition_of_source_equations helpers definitions contracts
    text tv _ cv _ bounds.valueFirst _ fv _ iv]
  rfl

end Silver.Compose.BooleanDeclarationNative.Libraries
