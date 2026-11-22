module

public import Silver.PredicateCountedBoundModel
public import Silver.PredicateFlowReaders
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.CountedBoundNative
open Compose

def expectedTokens (text : String) := (Source.lexLine text).getD []

abbrev Wrapper := Source → Native.Context → Nat → ActiveFlow → Nat → Nat → ScalarExpression.Result

/-- The imported gate is exactly the native scalar reader with Mutable_Elements.
The full table remains visible to static bounds queries. -/
abbrev Gate := Source → Nat → ScalarExpression.Environment → Nat → Nat → ArrayBindings.Table → Bool → ScalarExpression.Result

def GateMeaning (gate : Gate) : Prop :=
  ∀ text, Compose.Expressions.ValidText text → ∀ position names first after arrays elaborating,
    position ≤ text.length + 1 → ScalarExpression.ValidEnvironment text names →
    (⟨first, after⟩ : Named.NameState).Valid text → ArrayBindings.ValidTable text arrays →
    gate text position names first after arrays elaborating =
      ScalarExpression.ArrayGrammar.read text position names arrays first after
        (elaborating := elaborating) (arrayReads := .mutableElements)

structure Frame where
  inputs : FlowReaders.Inputs
  overlay : ScalarExpression.Environment
  gate : ScalarExpression.Result

def initial (calls : FlowReaders.Calls) (gate : Gate) (inputs : FlowReaders.Inputs) : Frame :=
  let overlay := FlowReaders.overlay calls.reading inputs.context inputs.facts
  ⟨inputs, overlay, gate inputs.text inputs.position overlay inputs.maskFirst inputs.maskAfter
    inputs.context.arrayTable inputs.context.elaborating⟩

inductive Command | finish

def Command.eval (original : FlowReaders.ScalarWrapper) (frame : Frame) : Command → ScalarExpression.Result
  | .finish => if frame.gate.after = 0 then ScalarExpression.invalid else
      original frame.inputs.text frame.inputs.context frame.inputs.position frame.inputs.facts
        frame.inputs.maskFirst frame.inputs.maskAfter []

def Command.render : Command → List String
  | .finish => ["if", "gate", ".", "after", "=", "0", "then", "return", "scalar_expressions", ".", "invalid", ";",
      "end", "if", ";", "return"] ++ Expressions.call "read_scalar_in_flow"
      [["text"], ["context"], ["position"], ["facts"], ["mask_first"], ["mask_after"]] ++ [";"]

def body : Command := .finish

def eval (calls : FlowReaders.Calls) (gate : Gate) (original : FlowReaders.ScalarWrapper) (inputs : FlowReaders.Inputs) :=
  body.eval original (initial calls gate inputs)

def render : List String := expectedTokens
  "Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts); Gate : constant Scalar_Expressions.Expression_Result := Scalar_Expressions.Read_Expression (Text, Position, Overlay, Mask_First, Mask_After, Arrays => Context.Array_Names, Elaborating => Context.Elaborating, Array_Reads => Scalar_Expressions.Mutable_Elements); begin" ++
  body.render ++ ["end", "read_counted_bound", ";"]

/-- Both calls are interpreted only on their complete native domains. The gate
changes admission mode, while success retains the original scalar-flow result. -/
theorem eval_meaning {calls : FlowReaders.Calls} {gate : Gate} {original : FlowReaders.ScalarWrapper}
    (meaning : FlowReaders.Meaning calls) (gateMeaning : GateMeaning gate)
    (source : FlowReaders.ScalarRefinement calls original)
    (inputs : FlowReaders.Inputs) (legal : FlowReaders.Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    eval calls gate original inputs = readCountedBound inputs.text inputs.context.model inputs.position
      inputs.facts inputs.maskFirst inputs.maskAfter := by
  have overlay := FlowReaders.overlay_meaning meaning.reading legal.context legal.flow
  have names := ScalarMetadata.readingNames_valid (declarations := inputs.context.declarationCount)
    legal.context.2.2.1 legal.flow.2.compatible.count legal.flow.2.bounded
  have initials : ArrayBindings.ValidInitials [] := by
    simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements]
  have gateEquation := gateMeaning inputs.text legal.text inputs.position
    (inputs.context.model.readingNames inputs.facts) inputs.maskFirst inputs.maskAfter
    inputs.context.arrayTable inputs.context.elaborating legal.position names mask legal.context.arrays
  have originalMeaning := FlowReaders.scalar_meaning meaning source
    {inputs with initials := []} ⟨legal.text, legal.context, legal.flow, legal.position, initials⟩ mask
  simp only [eval, Command.eval, initial, overlay, gateEquation]
  exact congrArg (fun result => if (countedBoundGate inputs.text inputs.context.model inputs.position
    inputs.facts inputs.maskFirst inputs.maskAfter).after = 0 then ScalarExpression.invalid else result)
    originalMeaning

structure Refinement (calls : FlowReaders.Calls) (gate : Gate)
    (original : FlowReaders.ScalarWrapper) (wrapper : Wrapper) : Prop where
  equation : ∀ inputs, FlowReaders.Legal inputs →
    (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text →
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter = eval calls gate original inputs

theorem wrapper_meaning {calls gate original wrapper} (meaning : FlowReaders.Meaning calls)
    (gateMeaning : GateMeaning gate) (source : FlowReaders.ScalarRefinement calls original)
    (verified : Refinement calls gate original wrapper)
    (inputs : FlowReaders.Inputs) (legal : FlowReaders.Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter =
      readCountedBound inputs.text inputs.context.model inputs.position inputs.facts inputs.maskFirst inputs.maskAfter :=
  (verified.equation inputs legal mask).trans (eval_meaning meaning gateMeaning source inputs legal mask)

def modelWrapper (calls : FlowReaders.Calls) (gate : Gate) (original : FlowReaders.ScalarWrapper) : Wrapper :=
  fun text context position facts first after => eval calls gate original
    {text, context, position, facts, maskFirst := first, maskAfter := after}

theorem model_refinement (calls : FlowReaders.Calls) (gate : Gate) (original : FlowReaders.ScalarWrapper) :
    Refinement calls gate original (modelWrapper calls gate original) := ⟨by intros; rfl⟩

def header : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position; Facts : Scalar_Flow; Mask_First : Literal_Position; Mask_After : Literal_Position) return Scalar_Expressions.Expression_Result"
def spec : List String := header ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Flow (Context, Facts) and then Position <= Text'Last + 1 and then Valid_Name_State (Text, Mask_First, Mask_After), Post => (Runtime => Read_Counted_Bound'Result.After = 0 or else (Read_Counted_Bound'Result.After in Position + 1 .. Text'Last + 1 and then Read_Counted_Bound'Result.Operands > 0), Static => (if Read_Counted_Bound'Result.After /= 0 then Read_Counted_Bound'Result = Read_Scalar_In_Flow (Text, Context, Position, Facts, Mask_First, Mask_After)))"

def noInline : List String → Bool
  | "pragma" :: "no_inline" :: "(" :: "read_counted_bound" :: ")" :: ";" :: _ => true
  | _ :: rest => noInline rest
  | [] => false

def throughEnd (name : String) : List String → Option (List String)
  | [] => none
  | "end" :: actual :: ";" :: rest =>
      if actual == name then some ["end", actual, ";"]
      else (throughEnd name (actual :: ";" :: rest)).map ("end" :: ·)
  | token :: rest => (throughEnd name rest).map (token :: ·)

def ordinaryFunctions (name : String) : List String → List (List String)
  | [] => []
  | "function" :: actual :: tokens =>
      let later := ordinaryFunctions name (actual :: tokens)
      if actual == name then
        match Silver.SourceBridge.headerEnd 0 tokens with
        | some (header, "is") =>
            match throughEnd name (tokens.drop (header.length + 1)) with
            | some body => body :: later
            | none => later
        | _ => later
      else later
  | _ :: tokens => ordinaryFunctions name tokens

def ordinaryFunction (name : String) (tokens : List String) : Option (List String) :=
  match ordinaryFunctions name tokens with
  | [body] => some body
  | _ => none

structure Checked (tokens : List String) : Prop where
  body : ordinaryFunction "read_counted_bound" tokens = some render
  header : Silver.SourceBridge.functionHeader "read_counted_bound" "is" tokens = some header
  spec : Silver.SourceBridge.functionHeader "read_counted_bound" ";" tokens = some spec
  noInline : noInline tokens = true

end Silver.Predicate.CountedBoundNative
