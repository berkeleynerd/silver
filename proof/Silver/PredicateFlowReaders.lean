module

public import Silver.PredicateFlowSourceBridge
public import Silver.PredicateNativeState

@[expose] public section

namespace Silver.Predicate.FlowReaders
open Compose Compose.Expressions Native

def storageContext (context : Native.Context) : FlowSourceBridge.Context :=
  ⟨FlowSourceBridge.ofNames context.scalarNames, context.declarationCount, context.dynamicFirst⟩

def overlay (reading : FlowSourceBridge.Context → ActiveFlow.Storage → FlowSourceBridge.NameStorage)
    (context : Native.Context) (facts : ActiveFlow) : ScalarExpression.Environment :=
  (reading (storageContext context) (FlowSourceBridge.ofFlow facts)).active

theorem overlay_meaning {reading}
    (source : FlowSourceBridge.InterpretedReadingNames reading)
    {text context facts} (cv : Native.ValidContext text context) (fv : Native.ValidFlow context facts) :
    overlay reading context facts = context.model.readingNames facts := by
  have legal : (storageContext context).InRange := cv.2.2.1.1
  have same : (FlowSourceBridge.ofFlow facts).count = (storageContext context).names.count :=
    fv.2.compatible.count
  simpa only [overlay, storageContext, FlowSourceBridge.ofNames_active, FlowSourceBridge.ofFlow_active,
    Native.Context.model, ParseContext.readingNames] using
    FlowSourceBridge.interpreted_readingNames reading source (storageContext context)
      (FlowSourceBridge.ofFlow facts) legal same

structure Calls where
  reading : FlowSourceBridge.Context → ActiveFlow.Storage → FlowSourceBridge.NameStorage
  scalar : Source → Nat → ScalarExpression.Environment → Nat → Nat → ScalarExpression.Result
  string : Source → Nat → BindingEnvironment → ScalarExpression.Environment → ExpressionResult

structure Inputs where
  text : Source
  context : Native.Context
  position : Nat
  facts : ActiveFlow
  maskFirst : Nat := 0
  maskAfter : Nat := 0

inductive Ty | source | context | position | facts | names | scalarNames | scalar | string

@[reducible] def Ty.meaning : Ty → Type
  | .source => Source | .context => Native.Context | .position => Nat | .facts => ActiveFlow
  | .names => BindingEnvironment | .scalarNames => ScalarExpression.Environment
  | .scalar => ScalarExpression.Result | .string => ExpressionResult

inductive Expr : Ty → Type
  | text : Expr .source
  | context : Expr .context
  | position : Expr .position
  | facts : Expr .facts
  | maskFirst : Expr .position
  | maskAfter : Expr .position
  | names : Expr .context → Expr .names
  | reading : Expr .context → Expr .facts → Expr .scalarNames
  | scalar : Expr .source → Expr .position → Expr .scalarNames → Expr .position → Expr .position → Expr .scalar
  | string : Expr .source → Expr .position → Expr .names → Expr .scalarNames → Expr .string

def Expr.render : Expr ty → List String
  | .text => ["text"] | .context => ["context"] | .position => ["position"] | .facts => ["facts"]
  | .maskFirst => ["mask_first"] | .maskAfter => ["mask_after"]
  | .names contextExpr => contextExpr.render ++ [".", "names"]
  | .reading contextExpr flowExpr => Expressions.call "reading_names" [contextExpr.render, flowExpr.render]
  | .scalar textExpr positionExpr environmentExpr startExpr endExpr =>
      ["scalar_expressions", "."] ++ Expressions.call "read_expression"
        [textExpr.render, positionExpr.render, environmentExpr.render, startExpr.render, endExpr.render]
  | .string textExpr positionExpr environmentExpr scalarsExpr => Expressions.call "expression_at"
      [textExpr.render, positionExpr.render, environmentExpr.render, scalarsExpr.render]

def Expr.eval (calls : Calls) (inputs : Inputs) : Expr ty → ty.meaning
  | .text => inputs.text | .context => inputs.context | .position => inputs.position | .facts => inputs.facts
  | .maskFirst => inputs.maskFirst | .maskAfter => inputs.maskAfter
  | .names contextExpr => (contextExpr.eval calls inputs).names
  | .reading contextExpr flowExpr => overlay calls.reading (contextExpr.eval calls inputs) (flowExpr.eval calls inputs)
  | .scalar textExpr positionExpr environmentExpr startExpr endExpr =>
      calls.scalar (textExpr.eval calls inputs) (positionExpr.eval calls inputs)
        (environmentExpr.eval calls inputs) (startExpr.eval calls inputs) (endExpr.eval calls inputs)
  | .string textExpr positionExpr environmentExpr scalarsExpr =>
      calls.string (textExpr.eval calls inputs) (positionExpr.eval calls inputs)
        (environmentExpr.eval calls inputs) (scalarsExpr.eval calls inputs)

def scalarRhs : Expr .scalar := .scalar .text .position (.reading .context .facts) .maskFirst .maskAfter
def stringRhs : Expr .string := .string .text .position (.names .context) (.reading .context .facts)

structure Meaning (calls : Calls) : Prop where
  reading : FlowSourceBridge.InterpretedReadingNames calls.reading
  scalar : ∀ text, ValidText text → ∀ position names first after,
    position ≤ text.length + 1 → ScalarExpression.ValidEnvironment text names →
    (⟨first, after⟩ : Named.NameState).Valid text →
    calls.scalar text position names first after = ScalarExpression.read text position names first after
  string : ∀ text, ValidText text → ∀ position names scalars,
    position ≤ text.length + 1 → Expressions.ValidNames text names → ScalarExpression.ValidEnvironment text scalars →
    calls.string text position names scalars = expressionAt text position names scalars

def Legal (inputs : Inputs) : Prop :=
  ValidText inputs.text ∧ Native.ValidContext inputs.text inputs.context ∧
    Native.ValidFlow inputs.context inputs.facts ∧ inputs.position ≤ inputs.text.length + 1

abbrev ScalarWrapper := Source → Native.Context → Nat → ActiveFlow → Nat → Nat → ScalarExpression.Result
abbrev StringWrapper := Source → Native.Context → Nat → ActiveFlow → ExpressionResult

structure ScalarRefinement (calls : Calls) (wrapper : ScalarWrapper) : Prop where
  equation : ∀ inputs, Legal inputs → (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text →
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter = scalarRhs.eval calls inputs

structure StringRefinement (calls : Calls) (wrapper : StringWrapper) : Prop where
  equation : ∀ inputs, Legal inputs →
    wrapper inputs.text inputs.context inputs.position inputs.facts = stringRhs.eval calls inputs

theorem scalar_meaning {calls wrapper} (meaning : Meaning calls) (verified : ScalarRefinement calls wrapper)
    (inputs : Inputs) (legal : Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter =
      ScalarExpression.read inputs.text inputs.position (inputs.context.model.readingNames inputs.facts)
        inputs.maskFirst inputs.maskAfter := by
  rw [verified.equation inputs legal mask]
  simp only [scalarRhs, Expr.eval, overlay_meaning meaning.reading legal.2.1 legal.2.2.1]
  apply meaning.scalar inputs.text legal.1 _ _ _ _ legal.2.2.2 _ mask
  exact ScalarMetadata.readingNames_valid legal.2.1.2.2.1
    legal.2.2.1.2.compatible.count legal.2.2.1.2.bounded

theorem string_meaning {calls wrapper} (meaning : Meaning calls) (verified : StringRefinement calls wrapper)
    (inputs : Inputs) (legal : Legal inputs) :
    wrapper inputs.text inputs.context inputs.position inputs.facts =
      expressionAt inputs.text inputs.position inputs.context.names (inputs.context.model.readingNames inputs.facts) := by
  rw [verified.equation inputs legal]
  simp only [stringRhs, Expr.eval, overlay_meaning meaning.reading legal.2.1 legal.2.2.1]
  apply meaning.string inputs.text legal.1 _ _ _ legal.2.2.2 legal.2.1.1
  exact ScalarMetadata.readingNames_valid legal.2.1.2.2.1
    legal.2.2.1.2.compatible.count legal.2.2.1.2.bounded

def modelCalls : Calls where
  reading := FlowSourceBridge.readingStorage
  scalar text position names first after := ScalarExpression.read text position names first after
  string text position names scalars := expressionAt text position names scalars

theorem model_meaning : Meaning modelCalls :=
  ⟨FlowSourceBridge.model_reading_interpreted, fun _ _ _ _ _ _ _ _ _ => rfl,
    fun _ _ _ _ _ _ _ _ => rfl⟩

def modelScalar (calls : Calls) : ScalarWrapper := fun text context position facts first after =>
  scalarRhs.eval calls ⟨text, context, position, facts, first, after⟩
def modelString (calls : Calls) : StringWrapper := fun text context position facts =>
  stringRhs.eval calls {text, context, position, facts}

theorem model_scalar_refinement (calls : Calls) : ScalarRefinement calls (modelScalar calls) := ⟨fun _ _ _ => rfl⟩
theorem model_string_refinement (calls : Calls) : StringRefinement calls (modelString calls) := ⟨fun _ _ => rfl⟩

def expectedTokens (text : String) := (Source.lex text).getD []
def scalarHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0) return Scalar_Expressions.Expression_Result"
def stringHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow) return Expression_Result"
def scalarSpec : List String := scalarHeader ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => (Runtime => Read_Scalar_In_Flow'Result.After = 0 or else (Read_Scalar_In_Flow'Result.After in Position + 1 .. Text'Last + 1 and then Read_Scalar_In_Flow'Result.Operands > 0), Static => Read_Scalar_In_Flow'Result =" ++
  scalarRhs.render ++ [")"]
def stringSpec : List String := stringHeader ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1, Post => (Runtime => Read_String_In_Flow'Result.After = 0 or else Read_String_In_Flow'Result.After in Position + 1 .. Text'Last + 1, Static => Read_String_In_Flow'Result =" ++
  stringRhs.render ++ [")"]

structure Checked (tokens : List String) : Prop where
  scalarSpec : Silver.SourceBridge.functionHeader "read_scalar_in_flow" ";" tokens = some scalarSpec
  scalarBody : Silver.SourceBridge.functionHeader "read_scalar_in_flow" "is" tokens = some scalarHeader
  stringSpec : Silver.SourceBridge.functionHeader "read_string_in_flow" ";" tokens = some stringSpec
  stringBody : Silver.SourceBridge.functionHeader "read_string_in_flow" "is" tokens = some stringHeader

end Silver.Predicate.FlowReaders
