module

public import Silver.ComposeBooleanDeclarationNative
public import Silver.SourceDeclarations

@[expose] public section

/-! Typed interpretation of the Boolean aggregate initializer model. This
small tree has only parameter references, calls and parenthesized record
updates: no infix operator or unbound local can be constructed. The actual
condition-reader meaning is supplied by its separate native source bridge. -/
namespace Silver.Compose.BooleanInitializerNative
open Predicate BooleanDeclarationNative
open Silver.SourceBridge

inductive CursorInput | position | maskFirst | maskAfter
  deriving DecidableEq, Repr

structure Input where
  text : Source
  state : ParserState
  position : Nat
  maskFirst : Nat
  maskAfter : Nat

def CursorInput.eval (input : Input) : CursorInput → Nat
  | .position => input.position
  | .maskFirst => input.maskFirst
  | .maskAfter => input.maskAfter

def CursorInput.render : CursorInput → List String
  | .position => ["position"]
  | .maskFirst => ["mask_first"]
  | .maskAfter => ["mask_after"]

structure Imports where
  contextOf : Scan → Context
  initialFlow : Context → ActiveFlow
  condition : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult

inductive ContextExpr
  | contextOf
  | initialize : ContextExpr → CursorInput → CursorInput → ContextExpr

def ContextExpr.eval (imports : Imports) (input : Input) : ContextExpr → Context
  | .contextOf => imports.contextOf ⟨input.state, false, false⟩
  | .initialize base first after =>
      {base.eval imports input with
        scalarNames := input.state.scalarNames
        elaborating := true
        maskFirst := first.eval input
        maskAfter := after.eval input}

def ContextExpr.render : ContextExpr → List String
  | .contextOf => expectedTokens "Context_Of ((State, False, False))"
  | .initialize base first after => ["("] ++ base.render ++
      expectedTokens "with delta Scalar_Names => State.Scalar_Names, Elaborating => True, Mask_First =>" ++
      first.render ++ expectedTokens ", Mask_After =>" ++ after.render ++ [")"]

/-- The local Context is bound once and used for both Initial_Flow and the
Condition_Model call. The only varying cursor is an in-scope parameter. -/
structure Body where
  context : ContextExpr
  position : CursorInput

def Body.eval (body : Body) (imports : Imports) (input : Input) : Nat :=
  let context := body.context.eval imports input
  (imports.condition input.text context (body.position.eval input)
    (imports.initialFlow context) input.state.arrayNames.values).after

def Body.render (body : Body) : List String :=
  expectedTokens "declare Context : constant Body_Context :=" ++ body.context.render ++
  expectedTokens "; begin Condition_Model (Text, Context," ++ body.position.render ++
  expectedTokens ", Initial_Flow (Context), State.Array_Names.Values).After"

def body : Body := ⟨.initialize .contextOf .maskFirst .maskAfter, .position⟩

def context (imports : Imports) (state : ParserState) (first after : Nat) : Context :=
  {imports.contextOf ⟨state, false, false⟩ with
    scalarNames := state.scalarNames
    elaborating := true
    maskFirst := first
    maskAfter := after}

theorem denotation (imports : Imports) (input : Input) :
    body.eval imports input =
      (imports.condition input.text (context imports input.state input.maskFirst input.maskAfter)
        input.position (imports.initialFlow (context imports input.state input.maskFirst input.maskAfter))
        input.state.arrayNames.values).after := rfl

def modelImports : Imports where
  contextOf := BooleanDeclarationNative.contextOf
  initialFlow := BooleanDeclarationNative.initialFlow
  condition := fun text context position facts initials => readCondition text context.model position facts initials

theorem model_context (state : ParserState) (first after : Nat) :
    (context modelImports state first after).model = booleanInitializerContext state first after := rfl

theorem model_facts (state : ParserState) (first after : Nat) :
    modelImports.initialFlow (context modelImports state first after) = booleanInitializerFacts state := rfl

theorem model_meaning (input : Input) : body.eval modelImports input =
    booleanInitializerAfter input.text input.state input.position input.maskFirst input.maskAfter := rfl

namespace SourceChecks

def implHeader : List String := expectedTokens
  "(Text : String; State : Parser_State; Position, Mask_First, Mask_After : Literal_Position) return Literal_Position"

def specHeader : List String := implHeader ++ expectedTokens
  "with Ghost => Static, Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_State (Text, State) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => Boolean_Initializer_Model'Result = 0 or else Boolean_Initializer_Model'Result in Position + 1 .. Text'Last + 1"

structure Checked (tokens : List String) : Prop where
  body : expressionDeclaration "boolean_initializer_model" tokens = some (body.render, [])
  spec : functionHeader "boolean_initializer_model" ";" tokens = some specHeader
  impl : functionHeader "boolean_initializer_model" "is" tokens = some implHeader

end SourceChecks
end Silver.Compose.BooleanInitializerNative
