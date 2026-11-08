module

public import Silver.ComposeBooleanInitializerNative
public import Silver.ComposeBooleanDeclarationDomain
public import Silver.PredicateNativeHelpers
public import Silver.PredicateAdapterEnvironment

@[expose] public section

/-! The initializer equation follows from the checked context expression,
verified initial-flow library and native condition definition on its full
precondition domain. No field assumes scanner equivalence to admission. -/
namespace Silver.Compose.BooleanInitializerNative.Libraries
open Predicate Compose.Expressions
open BooleanDeclarationNative.Libraries

set_option backward.dsimp.instances true

structure Links (imports : Imports) (condition : Native.Calls) : Prop where
  context : ∀ scan, scan.state.scalarNames.length ≤ ScalarExpression.maxBindings →
    imports.contextOf scan = fromNative
      (Adapter.contextExpr.eval BodyNative.modelCalls {scan := ⟨scan.state, scan.assigned, scan.output⟩})
  initial : ∃ library initial,
    FlowSourceBridge.CallsMeaning library ∧ FlowSourceBridge.InterpretedInitial library initial ∧
      ∀ context, imports.initialFlow context = Adapter.Environment.initialCall initial (toNative context)
  condition : ∀ text context position facts initials,
    imports.condition text context position facts initials =
      condition.model text (toNative context) position facts initials

def nativeContext (state : ParserState) (first after : Nat) : Native.Context :=
  toNative (context modelImports state first after)

theorem context_valid (text : Source) (state : ParserState) (first after : Nat)
    (valid : OuterReadiness.ValidState text state)
    (mask : (⟨first, after⟩ : Named.NameState).Valid text) :
    Native.ValidContext text (nativeContext state first after) := by
  rcases valid.1 with ⟨_, names, dynamic, _, _, scalars, arrays, _, booleans, _, _, _⟩
  exact ⟨names, dynamic, scalars, valid.2.contextReady scalars.1, arrays.1, booleans, mask, valid.bounds⟩

theorem flow_valid (text : Source) (state : ParserState) (first after : Nat)
    (valid : OuterReadiness.ValidState text state) :
    Native.ValidFlow (nativeContext state first after) (booleanInitializerFacts state) := by
  refine ⟨?_, valid.2.initial valid.1.2.2.2.2.2.1 _⟩
  change (if state.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
    else ⟨some ⟨0, 0⟩, false, false⟩).Bounded
  split
  · exact PathFacts.Context.initial_bounded (Nat.le_refl _)
  · exact Nat.zero_le _

theorem imports_meaning {imports condition}
    (helpers : Native.HelperMeaning condition) (definitions : Native.DefinitionEquations condition)
    (contracts : Native.Contracts condition) (links : Links imports condition)
    (text : Source) (tv : ValidText text) (state : ParserState) (position first after : Nat)
    (valid : OuterReadiness.ValidState text state) (bounded : ValidCursor text position)
    (mask : (⟨first, after⟩ : Named.NameState).Valid text) :
    body.eval imports ⟨text, state, position, first, after⟩ =
      booleanInitializerAfter text state position first after := by
  have scalars := valid.1.2.2.2.2.2.1
  have sameContext : context imports state first after = context modelImports state first after := by
    unfold context
    rw [links.context _ scalars.1]
    rfl
  have initial : imports.initialFlow (context modelImports state first after) = booleanInitializerFacts state := by
    obtain ⟨library, initial, meaning, verified, linked⟩ := links.initial
    rw [linked, Adapter.Environment.initialCall_interpreted library meaning initial verified _ scalars.1]
    change ActiveFlow.initial state.scalarNames (initialFacts (decide (state.dynamicFirst ≠ 0))) = _
    simp only [initialFacts, booleanInitializerFacts, decide_eq_true_eq]
  rw [denotation]
  dsimp only
  rw [sameContext, initial, links.condition]
  have cv := context_valid text state first after valid mask
  have fv := flow_valid text state first after valid
  have iv := valid.1.2.2.2.2.2.2.1.2.2.1
  have defined := definitions.condition text tv _ cv position bounded _ fv _ iv
  change condition.condition text (nativeContext state first after) position (booleanInitializerFacts state)
    state.arrayNames.values = condition.model text (nativeContext state first after) position
    (booleanInitializerFacts state) state.arrayNames.values at defined
  change (condition.model text (nativeContext state first after) position (booleanInitializerFacts state)
    state.arrayNames.values).after = _
  rw [← defined, Native.condition_of_source_equations helpers definitions contracts
    text tv _ cv position bounded _ fv _ iv]
  rfl

theorem model_links : Links modelImports Native.modelCalls where
  context := by intros; rfl
  initial := by
    refine ⟨FlowSourceBridge.modelCalls, FlowSourceBridge.initialStorage FlowSourceBridge.modelCalls,
      FlowSourceBridge.model_calls_meaning, FlowSourceBridge.model_initial_interpreted _, ?_⟩
    intro context
    rw [Adapter.Environment.initialCall, FlowSourceBridge.initial_storage_active _ FlowSourceBridge.model_calls_meaning]
    simp only [Adapter.Environment.flowContext, FlowSourceBridge.ofNames_active, toNative]
    change BooleanDeclarationNative.initialFlow context = ActiveFlow.initial context.scalarNames
      (FlowSourceBridge.initialPath (decide (context.dynamicFirst ≠ 0)))
    by_cases active : context.dynamicFirst ≠ 0 <;>
      simp [BooleanDeclarationNative.initialFlow, FlowSourceBridge.initialPath, active] <;> rfl
  condition := by intros; rfl

end Silver.Compose.BooleanInitializerNative.Libraries
