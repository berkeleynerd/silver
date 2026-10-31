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
  scalar : Source → Nat → ScalarExpression.Environment → Nat → Nat → ArrayBindings.Metadata → ArrayBindings.Initials → Bool → ScalarExpression.Result
  string : Source → Nat → BindingEnvironment → ScalarExpression.Environment → Bool → ArrayBindings.Metadata → ArrayBindings.Initials → Bool → ExpressionResult
  booleanHidesInteger : Source → BooleanBindings.Environment → Bool
  nameIs : Source → Nat → Nat → String → Bool

structure Inputs where
  text : Source
  context : Native.Context
  position : Nat
  facts : ActiveFlow
  maskFirst : Nat := 0
  maskAfter : Nat := 0
  initials : ArrayBindings.Initials := []

inductive Ty | source | context | position | facts | names | scalarNames | arrays | initials | truth | scalar | string

@[reducible] def Ty.meaning : Ty → Type
  | .source => Source | .context => Native.Context | .position => Nat | .facts => ActiveFlow
  | .names => BindingEnvironment | .scalarNames => ScalarExpression.Environment
  | .arrays => ArrayBindings.Metadata | .initials => ArrayBindings.Initials | .truth => Bool
  | .scalar => ScalarExpression.Result | .string => ExpressionResult

inductive Expr : Ty → Type
  | text : Expr .source
  | context : Expr .context
  | position : Expr .position
  | facts : Expr .facts
  | maskFirst : Expr .position
  | maskAfter : Expr .position
  | initials : Expr .initials
  | names : Expr .context → Expr .names
  | arrays : Expr .context → Expr .arrays
  | elaborating : Expr .context → Expr .truth
  | integerHidden : Expr .source → Expr .context → Expr .truth
  | reading : Expr .context → Expr .facts → Expr .scalarNames
  | scalar : Expr .source → Expr .position → Expr .scalarNames → Expr .position → Expr .position → Expr .arrays → Expr .initials → Expr .truth → Expr .scalar
  | string : Expr .source → Expr .position → Expr .names → Expr .scalarNames → Expr .truth → Expr .arrays → Expr .initials → Expr .truth → Expr .string

def Expr.render : Expr ty → List String
  | .text => ["text"] | .context => ["context"] | .position => ["position"] | .facts => ["facts"]
  | .maskFirst => ["mask_first"] | .maskAfter => ["mask_after"] | .initials => ["initials"]
  | .names contextExpr => contextExpr.render ++ [".", "names"]
  | .arrays contextExpr => contextExpr.render ++ [".", "array_names"]
  | .elaborating contextExpr => contextExpr.render ++ [".", "elaborating"]
  | .integerHidden textExpr contextExpr =>
      Expressions.call "boolean_hides_integer" [textExpr.render, contextExpr.render ++ [".", "boolean_names"]] ++
      ["or", "else", "("] ++ contextExpr.render ++ [".", "mask_first", "/=", "0", "and", "then"] ++
      Expressions.call "name_is" [textExpr.render, contextExpr.render ++ [".", "mask_first"],
        contextExpr.render ++ [".", "mask_after"], ["integer_type_word"]] ++ [")"]
  | .reading contextExpr flowExpr => Expressions.call "reading_names" [contextExpr.render, flowExpr.render]
  | .scalar textExpr positionExpr environmentExpr startExpr endExpr arraysExpr initialsExpr elaboratingExpr =>
      ["scalar_expressions", "."] ++ Expressions.call "read_expression"
        [textExpr.render, positionExpr.render, environmentExpr.render, startExpr.render, endExpr.render,
          ["arrays", "=>"] ++ arraysExpr.render, ["initials", "=>"] ++ initialsExpr.render,
          ["elaborating", "=>"] ++ elaboratingExpr.render]
  | .string textExpr positionExpr environmentExpr scalarsExpr hiddenExpr arraysExpr initialsExpr elaboratingExpr =>
      Expressions.call "expression_at" [textExpr.render, positionExpr.render, environmentExpr.render, scalarsExpr.render,
        ["integer_hidden", "=>"] ++ hiddenExpr.render, ["arrays", "=>"] ++ arraysExpr.render,
        ["initials", "=>"] ++ initialsExpr.render, ["elaborating", "=>"] ++ elaboratingExpr.render]

def Expr.eval (calls : Calls) (inputs : Inputs) : Expr ty → ty.meaning
  | .text => inputs.text | .context => inputs.context | .position => inputs.position | .facts => inputs.facts
  | .maskFirst => inputs.maskFirst | .maskAfter => inputs.maskAfter | .initials => inputs.initials
  | .names contextExpr => (contextExpr.eval calls inputs).names
  | .arrays contextExpr => (contextExpr.eval calls inputs).arrayNames
  | .elaborating contextExpr => (contextExpr.eval calls inputs).elaborating
  | .integerHidden textExpr contextExpr =>
      let context := contextExpr.eval calls inputs
      let text := textExpr.eval calls inputs
      calls.booleanHidesInteger text context.booleanNames ||
        (decide (context.maskFirst ≠ 0) && calls.nameIs text context.maskFirst context.maskAfter "integer")
  | .reading contextExpr flowExpr => overlay calls.reading (contextExpr.eval calls inputs) (flowExpr.eval calls inputs)
  | .scalar textExpr positionExpr environmentExpr startExpr endExpr arraysExpr initialsExpr elaboratingExpr =>
      calls.scalar (textExpr.eval calls inputs) (positionExpr.eval calls inputs)
        (environmentExpr.eval calls inputs) (startExpr.eval calls inputs) (endExpr.eval calls inputs)
        (arraysExpr.eval calls inputs) (initialsExpr.eval calls inputs) (elaboratingExpr.eval calls inputs)
  | .string textExpr positionExpr environmentExpr scalarsExpr hiddenExpr arraysExpr initialsExpr elaboratingExpr =>
      calls.string (textExpr.eval calls inputs) (positionExpr.eval calls inputs)
        (environmentExpr.eval calls inputs) (scalarsExpr.eval calls inputs) (hiddenExpr.eval calls inputs)
        (arraysExpr.eval calls inputs) (initialsExpr.eval calls inputs) (elaboratingExpr.eval calls inputs)

def scalarRhs : Expr .scalar :=
  .scalar .text .position (.reading .context .facts) .maskFirst .maskAfter (.arrays .context) .initials (.elaborating .context)
def stringRhs : Expr .string :=
  .string .text .position (.names .context) (.reading .context .facts) (.integerHidden .text .context)
    (.arrays .context) .initials (.elaborating .context)

def integerHidden (text : Source) (context : Native.Context) : Bool :=
  BooleanBindings.hidesInteger text context.booleanNames ||
    (decide (context.maskFirst ≠ 0) && Named.nameIs text context.maskFirst context.maskAfter ("integer".toList.map Char.toNat))

structure Meaning (calls : Calls) : Prop where
  reading : FlowSourceBridge.InterpretedReadingNames calls.reading
  booleanHidesInteger : ∀ text, ValidText text → ∀ booleans, BooleanBindings.ValidEnvironment text booleans →
    calls.booleanHidesInteger text booleans = BooleanBindings.hidesInteger text booleans
  nameIs : ∀ text, ValidText text → ∀ first after, Expressions.ValidName text first after →
    calls.nameIs text first after "integer" = Named.nameIs text first after ("integer".toList.map Char.toNat)
  scalar : ∀ text, ValidText text → ∀ position names first after arrays initials elaborating,
    position ≤ text.length + 1 → ScalarExpression.ValidEnvironment text names →
    (⟨first, after⟩ : Named.NameState).Valid text → ArrayBindings.ValidMetadata text arrays →
    ArrayBindings.ValidInitials initials →
    calls.scalar text position names first after arrays initials elaborating =
      ScalarExpression.read text position names first after (arrays := arrays) (initials := initials) (elaborating := elaborating)
  string : ∀ text, ValidText text → ∀ position names scalars hidden arrays initials elaborating,
    position ≤ text.length + 1 → Expressions.ValidNames text names → ScalarExpression.ValidEnvironment text scalars →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.string text position names scalars hidden arrays initials elaborating =
      expressionAt text position names scalars hidden (arrays := arrays) (initials := initials) (elaborating := elaborating)

/-- Initials validity interprets the fixed Ada Element_Array type. It imposes no
source-allocation or initialized-prefix premise on an arbitrary native call. -/
structure Legal (inputs : Inputs) : Prop where
  text : ValidText inputs.text
  context : Native.ValidContext inputs.text inputs.context
  flow : Native.ValidFlow inputs.context inputs.facts
  position : inputs.position ≤ inputs.text.length + 1
  initials : ArrayBindings.ValidInitials inputs.initials

abbrev ScalarWrapper := Source → Native.Context → Nat → ActiveFlow → Nat → Nat → ArrayBindings.Initials → ScalarExpression.Result
abbrev StringWrapper := Source → Native.Context → Nat → ActiveFlow → ArrayBindings.Initials → ExpressionResult

structure ScalarRefinement (calls : Calls) (wrapper : ScalarWrapper) : Prop where
  equation : ∀ inputs, Legal inputs → (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text →
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter inputs.initials = scalarRhs.eval calls inputs

structure StringRefinement (calls : Calls) (wrapper : StringWrapper) : Prop where
  equation : ∀ inputs, Legal inputs →
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.initials = stringRhs.eval calls inputs

theorem scalar_meaning {calls wrapper} (meaning : Meaning calls) (verified : ScalarRefinement calls wrapper)
    (inputs : Inputs) (legal : Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter inputs.initials =
      ScalarExpression.read inputs.text inputs.position (inputs.context.model.readingNames inputs.facts)
        inputs.maskFirst inputs.maskAfter (arrays := inputs.context.arrayNames)
        (initials := inputs.initials) (elaborating := inputs.context.elaborating) := by
  rw [verified.equation inputs legal mask]
  simp only [scalarRhs, Expr.eval, overlay_meaning meaning.reading legal.context legal.flow]
  apply meaning.scalar inputs.text legal.text _ _ _ _ _ _ _ legal.position _ mask legal.context.arrays legal.initials
  exact ScalarMetadata.readingNames_valid legal.context.2.2.1
    legal.flow.2.compatible.count legal.flow.2.bounded

theorem string_meaning {calls wrapper} (meaning : Meaning calls) (verified : StringRefinement calls wrapper)
    (inputs : Inputs) (legal : Legal inputs) :
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.initials =
      expressionAt inputs.text inputs.position inputs.context.names (inputs.context.model.readingNames inputs.facts)
        (integerHidden inputs.text inputs.context) (arrays := inputs.context.arrayNames)
        (initials := inputs.initials) (elaborating := inputs.context.elaborating) := by
  rw [verified.equation inputs legal]
  dsimp +instances only [stringRhs, Expr.eval]
  rw [overlay_meaning meaning.reading legal.context legal.flow]
  have maskedName :
      (decide (inputs.context.maskFirst ≠ 0) &&
        calls.nameIs inputs.text inputs.context.maskFirst inputs.context.maskAfter "integer") =
      (decide (inputs.context.maskFirst ≠ 0) &&
        Named.nameIs inputs.text inputs.context.maskFirst inputs.context.maskAfter ("integer".toList.map Char.toNat)) := by
    rcases legal.context.mask with empty | present
    · have zero : inputs.context.maskFirst = 0 := empty.1
      simp [zero]
    · rw [meaning.nameIs inputs.text legal.text _ _ present]
  rw [meaning.booleanHidesInteger inputs.text legal.text _ legal.context.booleans, maskedName]
  apply meaning.string inputs.text legal.text _ _ _ _ _ _ _ legal.position legal.context.1 _ legal.context.arrays legal.initials
  exact ScalarMetadata.readingNames_valid legal.context.2.2.1
    legal.flow.2.compatible.count legal.flow.2.bounded

def modelCalls : Calls where
  reading := FlowSourceBridge.readingStorage
  scalar text position names first after arrays initials elaborating :=
    ScalarExpression.read text position names first after (arrays := arrays) (initials := initials) (elaborating := elaborating)
  string text position names scalars hidden arrays initials elaborating :=
    expressionAt text position names scalars hidden (arrays := arrays) (initials := initials) (elaborating := elaborating)
  booleanHidesInteger := BooleanBindings.hidesInteger
  nameIs text first after word := Named.nameIs text first after (word.toList.map Char.toNat)

theorem model_meaning : Meaning modelCalls where
  reading := FlowSourceBridge.model_reading_interpreted
  booleanHidesInteger := by intros; rfl
  nameIs := by intros; rfl
  scalar := by intros; rfl
  string := by intros; rfl

def modelScalar (calls : Calls) : ScalarWrapper := fun text context position facts first after initials =>
  scalarRhs.eval calls {text, context, position, facts, maskFirst := first, maskAfter := after, initials}
def modelString (calls : Calls) : StringWrapper := fun text context position facts initials =>
  stringRhs.eval calls {text, context, position, facts, initials}

theorem model_scalar_refinement (calls : Calls) : ScalarRefinement calls (modelScalar calls) := ⟨fun _ _ _ => rfl⟩
theorem model_string_refinement (calls : Calls) : StringRefinement calls (modelString calls) := ⟨fun _ _ => rfl⟩

def expectedTokens (text : String) := (Source.lexLine text).getD []
def scalarHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Mask_First : Literal_Position := 0; Mask_After : Literal_Position := 0; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Scalar_Expressions.Expression_Result"
def stringHeader : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Initials : Array_Bindings.Element_Array := Array_Bindings.Empty_Values) return Expression_Result"
def scalarSpec : List String := scalarHeader ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => (Runtime => Read_Scalar_In_Flow'Result.After = 0 or else (Read_Scalar_In_Flow'Result.After in Position + 1 .. Text'Last + 1 and then Read_Scalar_In_Flow'Result.Operands > 0), Static => Read_Scalar_In_Flow'Result =" ++
  scalarRhs.render ++ [")"]
def stringSpec : List String := stringHeader ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1, Post => (Runtime => Read_String_In_Flow'Result.After = 0 or else Read_String_In_Flow'Result.After in Position + 1 .. Text'Last + 1, Static => Read_String_In_Flow'Result =" ++
  stringRhs.render ++ [")"]

structure Checked (tokens : List String) : Prop where
  integerTypeWord : Source.declaration "integer_type_word" tokens =
    some (expectedTokens "constant String := \"integer\"")
  scalarSpec : Silver.SourceBridge.functionHeader "read_scalar_in_flow" ";" tokens = some scalarSpec
  scalarBody : Silver.SourceBridge.functionHeader "read_scalar_in_flow" "is" tokens = some scalarHeader
  stringSpec : Silver.SourceBridge.functionHeader "read_string_in_flow" ";" tokens = some stringSpec
  stringBody : Silver.SourceBridge.functionHeader "read_string_in_flow" "is" tokens = some stringHeader

end Silver.Predicate.FlowReaders
