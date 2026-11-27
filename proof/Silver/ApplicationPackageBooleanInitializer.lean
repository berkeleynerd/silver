module

public import Silver.ComposeBooleanImportMeaning
public import Silver.ComposeBooleanDeclarationSource

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.BooleanInitializer
open Compose Compose.Expressions Predicate
open Compose.BooleanInitializerNative
open Compose.BooleanDeclarationNative.Libraries (toNative)
open Silver.SourceBridge

/-- The executable initializer shares its typed context and cursor with the
model. Its local output discriminant is the incoming scalar name count. -/
def execute (body : BooleanInitializerNative.Body) (calls : Imports) (outputs : Native.Workers.Outputs) (input : Input) : Nat :=
  let current := body.context.eval calls input
  let value := outputs.condition input.text (toNative current) (body.position.eval input)
    (calls.initialFlow current) input.state.scalarNames.length input.state.arrayNames.values
  value.after

def render (body : BooleanInitializerNative.Body) : List String :=
  expectedTokens "Context : constant Body_Context :=" ++ body.context.render ++
  expectedTokens "; Value : Condition_Result (State.Scalar_Names.Count); begin Read_Condition_Into (Text, Context," ++
  body.position.render ++ expectedTokens ", Initial_Flow (Context), Value, State.Array_Names.Values); return Value.After; end Boolean_Initializer_After;"

/-- Both native headers and the complete ordinary body, including the named
terminator. The source binding instantiates this predicate on original tokens. -/
structure Checked (tokens : List String) : Prop where
  specification : functionHeader "boolean_initializer_after" ";" tokens = some
    (BooleanInitializerNative.SourceChecks.implHeader ++ expectedTokens
      "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => (Runtime => Boolean_Initializer_After'Result = 0 or else Boolean_Initializer_After'Result in Position + 1 .. Text'Last + 1, Static => Boolean_Initializer_After'Result = Boolean_Initializer_Model (Text, State, Position, Mask_First, Mask_After))")
  implementation : functionHeader "boolean_initializer_after" "is" tokens = some BooleanInitializerNative.SourceChecks.implHeader
  statements : BooleanDeclarationNative.SourceChecks.ordinaryFunction "boolean_initializer_after" tokens = some (render body)

structure Library (composed : Silver.Compose.Expressions.Calls) where
  calls : Imports
  condition : Native.Calls
  outputs : Native.Workers.Outputs
  source : Compose.SourceBridge.PredicateImportSource condition composed
  definitions : Native.DefinitionEquations condition
  contracts : Native.Contracts condition
  links : Libraries.Links calls condition
  workers : Native.Workers.Refinement Native.workerInput Native.workerChainInput condition outputs

def Library.read (library : Library composed) (text : Source) (state : ParserState) (position first after : Nat) : Nat :=
  execute body library.calls library.outputs ⟨text, state, position, first, after⟩

/-- Interpret the executed Read_Condition_Into. Its complete verified worker
postcondition supplies the returned value and checks the exact output count. -/
theorem Library.meaning (library : Library composed) (raw : RawHelperEquations composed (domain := OuterReadiness.domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (position first after : Nat)
    (ready : OuterReadiness.ValidState text state) (bounded : ValidCursor text position)
    (mask : (⟨first, after⟩ : Named.NameState).Valid text) :
    library.read text state position first after = booleanInitializerAfter text state position first after := by
  have contextEq := Libraries.context_meaning library.links state first after ready.base.2.2.2.2.2.1.1
  have initial := Libraries.initial_meaning library.links state first after ready.base.2.2.2.2.2.1.1
  have cv := Libraries.context_valid text state first after ready mask
  have fv := Libraries.flow_valid text state first after ready
  have iv := ready.base.arrays.2.2.1
  have worker := library.workers.condition text (Libraries.nativeContext state first after) position
    (booleanInitializerFacts state) state.scalarNames.length state.arrayNames.values ⟨valid, cv, bounded, fv⟩ iv
    (by simp [booleanInitializerFacts, ActiveFlow.initial_count])
  change library.outputs.condition _ _ _ _ _ _ = library.condition.model _ _ _ _ _ at worker
  have ghost := Libraries.imports_meaning (library.source.meaning raw) library.definitions library.contracts
    library.links text valid state position first after ready bounded mask
  rw [denotation] at ghost
  change (library.calls.condition text (context library.calls state first after) position
    (library.calls.initialFlow (context library.calls state first after)) state.arrayNames.values).after = _ at ghost
  rw [contextEq, initial, library.links.condition] at ghost
  change (library.outputs.condition text (toNative (context library.calls state first after)) position
    (library.calls.initialFlow (context library.calls state first after)) state.scalarNames.length state.arrayNames.values).after = _
  rw [contextEq, initial]
  exact (congrArg ConditionResult.after worker).trans ghost

theorem Checked.read_meaning {tokens : List String} (checked : Checked tokens) (library : Library composed)
    (raw : RawHelperEquations composed (domain := OuterReadiness.domain))
    (text : Source) (valid : ValidText text) (state : ParserState) (position first after : Nat)
    (ready : OuterReadiness.ValidState text state) (bounded : ValidCursor text position)
    (mask : (⟨first, after⟩ : Named.NameState).Valid text) :
    BooleanDeclarationNative.SourceChecks.ordinaryFunction "boolean_initializer_after" tokens = some (render body) ∧
      library.read text state position first after = booleanInitializerAfter text state position first after :=
  ⟨checked.statements, library.meaning raw text valid state position first after ready bounded mask⟩

def modelLibrary : Library Silver.Compose.Expressions.modelCalls where
  calls := modelImports
  condition := Native.modelCalls
  outputs := Native.Workers.modelOutputs Native.modelCalls
  source := Compose.SourceBridge.model_predicate_import_source
  definitions := Native.model_definition_equations
  contracts := Native.model_contracts
  links := Libraries.model_links
  workers := Native.Workers.model_refinement Native.workerInput Native.workerChainInput Native.modelCalls

end Silver.ApplicationPackageDeclarations.BooleanInitializer
