module

public import Silver.ComposeBooleanDeclarationCondition
public import Silver.ComposeHelperEquations
public import Silver.PredicateNativeHelpers
public import Silver.PredicateAdapterEnvironment

@[expose] public section

namespace Silver.Compose.BooleanDeclarationNative.Libraries
open Predicate Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def toScan (scan : Scan) : Predicate.ScanResult := ⟨scan.state, scan.assigned, scan.output⟩

/-- Direct native callee identities, the checked Context_Of expression, and
verified finite-storage/worker contracts. No field asserts predicate or
declaration scanner equivalence to language admission. -/
structure Links (imports : Imports) (composed : Compose.Expressions.Calls) (condition : Native.Calls) : Prop where
  skip : imports.skip = composed.function .skip
  nameAfter : imports.nameAfter = composed.function .nameAfter
  take : ∀ text position token, imports.take text position token = composed.function .takeToken text position token.shell
  newName : imports.newName = composed.function .newName
  nameIs : ∀ text first after, imports.nameIsBoolean text first after = composed.function .nameIs text first after "boolean"
  nameIsMark : ∀ mark text first after, imports.nameIsMark mark text first after =
    composed.function .nameIs text first after mark.word
  formalHides : imports.formalHides = composed.function .formalHides
  lookup : ∀ kind text state first after, imports.lookup kind text state first after = match kind with
    | .string => composed.function .lookupName text state.names first after
    | .scalar => composed.function .scalarLookup text state.scalarNames first after
    | .array => composed.function .arrayLookup text state.arrayNames.names first after
    | .subtype => composed.function .subtypeLookup text state.subtypeNames first after
    | .boolean => composed.function .booleanLookup text state.booleanNames first after
    | .function => composed.function .functionLookup text state.functions first after
  context : ∀ scan, scan.state.scalarNames.length ≤ ScalarExpression.maxBindings →
    imports.contextOf scan =
    fromNative (Adapter.contextExpr.eval BodyNative.modelCalls {scan := toScan scan})
  initial : ∃ library initial,
    FlowSourceBridge.CallsMeaning library ∧ FlowSourceBridge.InterpretedInitial library initial ∧
      ∀ context, imports.initialFlow context = Adapter.Environment.initialCall initial (toNative context)
  worker : ∃ outputs : Native.Workers.Outputs,
    Native.Workers.Refinement Native.workerInput Native.workerChainInput condition outputs ∧
      ∀ text context position facts count initials,
        imports.conditionInto text context position facts count initials =
          outputs.condition text (toNative context) position facts count initials
  invalid : imports.invalid = invalidState

theorem token_valid (token : Token) : ValidToken token.shell := by
  cases token <;> simp [ValidToken, allTokens, Token.shell]

theorem lexical_meaning {imports composed condition}
    (equations : RawHelperEquations composed (domain := OuterReadiness.domain))
    (links : Links imports composed condition) (text : Source) (tv : ValidText text) :
    LexicalMeaning imports text where
  skip position bounded := by rw [links.skip]; exact interpreted_skip composed equations text tv position bounded
  nameAfter position bounded := by rw [links.nameAfter]; exact interpreted_name composed equations text tv position bounded
  take position token bounded := by
    rw [links.take, interpreted_take composed equations text tv position token.shell bounded (token_valid token)]
    cases token <;> rfl

theorem imports_meaning {imports composed condition}
    (equations : RawHelperEquations composed (domain := OuterReadiness.domain))
    (helpers : Native.HelperMeaning condition) (definitions : Native.DefinitionEquations condition)
    (contracts : Native.Contracts condition) (links : Links imports composed condition)
    (text : Source) (tv : ValidText text) (state : ParserState) (arguments : Bool)
    (valid : OuterReadiness.ValidState text state) : ImportsMeaning imports text state arguments := by
  have bounds := part_bounds text state valid.1.1
  have lexical := lexical_meaning equations links text tv
  rcases valid.1 with ⟨position, names, dynamic, target, capacity, scalars, arrays, subtypes, booleans, functions, firstParameter, firstParameterCapacity⟩
  refine ⟨lexical, position, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, links.invalid⟩
  · rw [links.newName]
    exact interpreted_newName composed equations text tv state _ _ arguments valid.nativeState bounds.first bounds.after
  · dsimp only
    intro allowed
    rw [links.nameIs]
    exact equations.nameIs text tv _ _ "boolean"
      (model_new_name_valid text state _ _ arguments bounds.after allowed) (by decide) (by decide)
  · intro mark
    dsimp only
    intro present
    rw [links.nameIsMark]
    have afterPositive : fixedAfter text (booleanDeclarationParts text state).typeFirst "boolean" true ≠ 0 := present
    have firstPositive := model_fixed_input_nonzero text _ "boolean" true afterPositive
    have advanced := model_fixed_advances text _ "boolean" true bounds.typeFirst (by decide) afterPositive
    apply equations.nameIs text tv _ _ mark.word
    · exact ⟨by omega, advanced, bounds.typeAfter⟩
    · cases mark <;> decide
    · cases mark <;> decide
  · rw [links.formalHides]
    exact equations.formalHides text tv state _ _ valid.nativeState bounds.typeFirst bounds.typeAfter
  · intro kind
    dsimp only
    rw [links.lookup]
    cases kind with
    | string => exact interpreted_lookup composed equations text tv state.names _ _ valid.nativeState.nativeNames bounds.typeFirst bounds.typeAfter
    | scalar => exact equations.scalarLookup text tv state.scalarNames _ _ scalars bounds.typeFirst bounds.typeAfter
    | array => exact equations.arrayLookup text tv state.arrayNames.names _ _ arrays.1 bounds.typeFirst bounds.typeAfter
    | subtype => exact interpreted_subtypeLookup composed equations text tv state.subtypeNames _ _ subtypes bounds.typeFirst bounds.typeAfter
    | boolean => exact equations.booleanLookup text tv state.booleanNames _ _ booleans bounds.typeFirst bounds.typeAfter
    | function => exact equations.functionLookup text tv state.functions _ _ functions bounds.typeFirst bounds.typeAfter
  · rw [links.context _ scalars.1]
    rfl
  · dsimp only
    obtain ⟨library, initial, meaning, verified, linked⟩ := links.initial
    rw [linked, Adapter.Environment.initialCall_interpreted library meaning initial verified _ scalars.1]
    change ActiveFlow.initial state.scalarNames (initialFacts (decide (state.dynamicFirst ≠ 0))) =
      booleanDeclarationFacts state
    simp only [initialFacts, booleanDeclarationFacts, decide_eq_true_eq]
  · intro ready
    obtain ⟨outputs, refined, linked⟩ := links.worker
    rw [linked]
    exact worker_condition_meaning helpers definitions contracts outputs refined text tv state arguments valid ready
  · intro _
    have valueBound : ValidCursor text (booleanDeclarationValue text state).after :=
      Native.condition_bound text (booleanDeclarationContext state (booleanDeclarationParts text state))
        (booleanDeclarationParts text state).valueFirst (booleanDeclarationFacts state) tv names bounds.valueFirst
    exact lexical.take _ .semicolon valueBound

theorem declaration_meaning {imports composed condition}
    (equations : RawHelperEquations composed (domain := OuterReadiness.domain))
    (helpers : Native.HelperMeaning condition) (definitions : Native.DefinitionEquations condition)
    (contracts : Native.Contracts condition) (links : Links imports composed condition)
    (text : Source) (tv : ValidText text) (state : ParserState) (arguments : Bool)
    (valid : OuterReadiness.ValidState text state) :
    body.eval imports {text, state, arguments} = booleanDeclarationAt text state arguments :=
  BooleanDeclarationNative.imports_meaning imports text state arguments
    (imports_meaning equations helpers definitions contracts links text tv state arguments valid)

/-- Concrete source-interface witness; its initializer reads the same native
model through the verified output contract, retaining count and array inputs. -/
theorem model_links : Links modelImports Compose.Expressions.modelCalls Native.modelCalls where
  skip := rfl
  nameAfter := rfl
  take text position token := by cases token <;> rfl
  newName := rfl
  nameIs := by intros; rfl
  nameIsMark := by intros; rfl
  formalHides := rfl
  lookup kind text state first after := by cases kind <;> rfl
  context := by intros; rfl
  initial := by
    refine ⟨FlowSourceBridge.modelCalls, FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls,
      FlowSourceBridge.model_calls_meaning, FlowSourceBridge.model_initial_interpreted _, ?_⟩
    intro context
    rw [Adapter.Environment.initialCall, FlowSourceBridge.initial_storage_active _ FlowSourceBridge.model_calls_meaning]
    simp only [Adapter.Environment.flowContext, FlowSourceBridge.ofNames_active, toNative]
    change initialFlow context = ActiveFlow.initial context.scalarNames
      (FlowSourceBridge.initialPath (decide (context.dynamicFirst ≠ 0)))
    by_cases active : context.dynamicFirst ≠ 0 <;>
      simp [initialFlow, FlowSourceBridge.initialPath, active] <;> rfl
  worker := by
    refine ⟨Native.Workers.modelOutputs Native.modelCalls,
      Native.Workers.model_refinement Native.workerInput Native.workerChainInput Native.modelCalls, ?_⟩
    intros
    rfl
  invalid := rfl

end Silver.Compose.BooleanDeclarationNative.Libraries
