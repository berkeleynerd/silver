module

public import Silver.ComposeBooleanDeclarationMeaning
public import Silver.PredicateNativeState
public import Silver.PredicateOuterReadiness

@[expose] public section

/-! Exact native preconditions at the Boolean initializer site, including
elaboration over snapshots contained in mutable declared bounds. -/
namespace Silver.Compose.BooleanDeclarationNative

theorem Token.name_eq_tokenName_shell : ∀ t : Token, t.name = Expressions.tokenName t.shell := by
  intro t; cases t <;> rfl

end Silver.Compose.BooleanDeclarationNative

namespace Silver.Compose.BooleanDeclarationNative.Libraries
open Predicate Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def toNative (context : BooleanDeclarationNative.Context) : Native.Context :=
  ⟨context.names, context.dynamicFirst, context.dynamicAfter, context.scalarNames,
    context.declarationCount, context.arrayNames, context.subtypeHiding, context.booleanNames,
    context.trueHidden, context.falseHidden, context.elaborating, context.maskFirst, context.maskAfter,
    context.pure, context.integerHidden, context.arrayTypes⟩

def fromNative (context : Native.Context) : BooleanDeclarationNative.Context :=
  ⟨context.names, context.dynamicFirst, context.dynamicAfter, context.scalarNames,
    context.declarationCount, context.arrayNames, context.subtypeHiding, context.booleanNames,
    context.trueHidden, context.falseHidden, context.elaborating, context.maskFirst, context.maskAfter,
    context.pure, context.integerHidden, context.arrayTypes⟩

@[simp] theorem toNative_model (context : BooleanDeclarationNative.Context) :
    (toNative context).model = context.model := rfl


structure PartBounds (text : Source) (p : BooleanDeclarationParts) : Prop where
  first : ValidCursor text p.first
  after : ValidCursor text p.after
  typeFirst : ValidCursor text p.typeFirst
  typeAfter : ValidCursor text p.typeAfter
  valueFirst : ValidCursor text p.valueFirst

theorem part_bounds (text : Source) (state : ParserState) (position : ValidCursor text state.position) :
    PartBounds text (booleanDeclarationParts text state) := by
  refine ⟨model_skip_valid text state.position position, model_name_valid text _, ?_, ?_, ?_⟩
  · apply model_skip_valid
    split <;> exact fixedAfter_result_bound text _ _ _ (by decide)
  · exact fixedAfter_result_bound text _ _ _ (by decide)
  · exact fixedAfter_result_bound text _ _ _ (by decide)

def initializerContext (state : ParserState) (p : BooleanDeclarationParts) : Native.Context :=
  toNative (elaborationContext modelImports state p)

theorem initializer_context_valid (text : Source) (state : ParserState) (arguments : Bool)
    (valid : OuterReadiness.ValidState text state)
    (ready : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true) :
    Native.ValidContext text (initializerContext state (booleanDeclarationParts text state)) := by
  have bounds := part_bounds text state valid.1.1
  have allowed : newNameAllowed text state (booleanDeclarationParts text state).first
      (booleanDeclarationParts text state).after arguments = true := by
    simp only [booleanDeclarationReady, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at ready
    exact ready.1
  have name := model_new_name_valid text state _ _ arguments bounds.after allowed
  rcases valid.1 with ⟨_, names, dynamic, _, _, scalars, arrays, _, booleans, _, _, _⟩
  exact ⟨names, dynamic, scalars, valid.2.contextReady scalars.1, arrays.1, booleans, Or.inr name, valid.bounds⟩

theorem initializer_flow_valid (text : Source) (state : ParserState)
    (valid : OuterReadiness.ValidState text state) (p : BooleanDeclarationParts) :
    Native.ValidFlow (initializerContext state p) (booleanDeclarationFacts state) := by
  refine ⟨?_, valid.2.initial valid.1.2.2.2.2.2.1 _⟩
  change (if state.dynamicFirst ≠ 0 then PathFacts.Context.initial maxSourceLength
      else ⟨some ⟨0, 0⟩, false, false⟩).Bounded
  split
  · exact PathFacts.Context.initial_bounded (Nat.le_refl _)
  · exact Nat.zero_le _

end Silver.Compose.BooleanDeclarationNative.Libraries
