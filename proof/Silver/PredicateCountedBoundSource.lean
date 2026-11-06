module

public import Silver.PredicateCountedBoundModel
public import Silver.PredicateFlowReaders
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.CountedBoundNative
open Compose

/-- The fixed native metadata array, observed only through its active prefix. -/
structure Scratch where
  count : Nat
  items : Nat → ArrayBindings.Binding

def Scratch.empty : Scratch := ⟨0, fun _ => ArrayBindings.emptyBinding⟩
def Scratch.active (scratch : Scratch) : ArrayBindings.Metadata :=
  List.ofFn fun index : Fin scratch.count => scratch.items (index.val + 1)

inductive FilterUpdate | increment | copy

def FilterUpdate.eval (item : ArrayBindings.Binding) (scratch : Scratch) : FilterUpdate → Scratch
  | .increment => {scratch with count := scratch.count + 1}
  | .copy => {scratch with items := fun index => if index = scratch.count then item else scratch.items index}

def FilterUpdate.render : FilterUpdate → List String
  | .increment => ["arrays", ".", "count", ":=", "arrays", ".", "count", "+", "1", ";"]
  | .copy => ["arrays", ".", "items", "(", "arrays", ".", "count", ")", ":=",
      "context", ".", "array_names", ".", "items", "(", "index", ")", ";"]

def append (scratch : Scratch) (item : ArrayBindings.Binding) : Scratch :=
  FilterUpdate.copy.eval item (FilterUpdate.increment.eval item scratch)

@[simp] theorem append_active (scratch : Scratch) (item : ArrayBindings.Binding) :
    (append scratch item).active = scratch.active ++ [item] := by
  apply List.ext_getElem
  · simp only [Scratch.active, append, FilterUpdate.eval, List.length_ofFn,
      List.length_append, List.length_singleton]
  · intro index leftBound rightBound
    have inside : index < scratch.count + 1 := by
      simpa only [Scratch.active, append, FilterUpdate.eval, List.length_ofFn] using leftBound
    by_cases final : index = scratch.count
    · subst index
      rw [List.getElem_append_right (by simp only [Scratch.active, List.length_ofFn, Nat.le_refl])]
      simp only [Scratch.active, append, FilterUpdate.eval, List.getElem_ofFn,
        List.length_ofFn, Nat.sub_self, List.getElem_cons_zero, ↓reduceIte]
    · have earlier : index < scratch.count := by omega
      rw [List.getElem_append_left (by simpa only [Scratch.active, List.length_ofFn] using earlier)]
      simp only [Scratch.active, List.getElem_ofFn, append, FilterUpdate.eval]
      have different : index + 1 ≠ scratch.count + 1 := by omega
      simp only [different, ↓reduceIte]

def filterStep (scratch : Scratch) (item : ArrayBindings.Binding) : Scratch :=
  if item.mutable then append scratch item else scratch

/-- Native `1 .. Count` traversal visits exactly the active metadata entries,
in their stored order. Each selected entry is copied whole, without rebasing. -/
def filterFrom (names : ArrayBindings.Metadata) (scratch : Scratch) : Scratch :=
  names.foldl filterStep scratch

theorem filterFrom_active (names : ArrayBindings.Metadata) (scratch : Scratch) :
    (filterFrom names scratch).active = scratch.active ++ countedArrays names := by
  induction names generalizing scratch with
  | nil => simp [filterFrom, countedArrays]
  | cons item rest ih =>
      change (filterFrom rest (filterStep scratch item)).active = _
      rw [ih]
      cases mutable : item.mutable <;>
        simp [filterStep, mutable, countedArrays, List.append_assoc]

def filtered (names : ArrayBindings.Metadata) : Scratch := filterFrom names Scratch.empty

@[simp] theorem filtered_active (names : ArrayBindings.Metadata) :
    (filtered names).active = countedArrays names := by
  change (filterFrom names Scratch.empty).active = _
  rw [filterFrom_active]
  simp [Scratch.active, Scratch.empty]

def expectedTokens (text : String) := (Source.lexLine text).getD []

/-- These are the verified native loop invariants, retained exactly in the
source rendering. Their expressions have no executable state effect. -/
def filterInvariants : List String := expectedTokens
  "pragma Loop_Invariant (Arrays.Count < Index); pragma Loop_Invariant (Array_Bindings.Valid_Metadata (Text, Arrays)); pragma Loop_Invariant (if Arrays.Count > 0 then Arrays.Items (Arrays.Count).Offset + Arrays.Items (Arrays.Count).Length <= Context.Array_Names.Items (Index).Offset);"

def filterRender : List String :=
  ["for", "index", "in", "1", "..", "context", ".", "array_names", ".", "count", "loop"] ++
  filterInvariants ++
  ["if", "context", ".", "array_names", ".", "items", "(", "index", ")", ".", "mutable", "then"] ++
  FilterUpdate.increment.render ++ FilterUpdate.copy.render ++
  ["end", "if", ";", "end", "loop", ";"]

abbrev Wrapper := Source → Native.Context → Nat → ActiveFlow → Nat → Nat → ScalarExpression.Result

structure Frame where
  inputs : FlowReaders.Inputs
  overlay : ScalarExpression.Environment
  arrays : Scratch
  gate : ScalarExpression.Result

def initial (calls : FlowReaders.Calls) (inputs : FlowReaders.Inputs) : Frame :=
  ⟨inputs, FlowReaders.overlay calls.reading inputs.context inputs.facts, Scratch.empty, ScalarExpression.invalid⟩

inductive Command | filter (next : Command) | gate (next : Command) | finish

def Command.eval (calls : FlowReaders.Calls) (original : FlowReaders.ScalarWrapper)
    (frame : Frame) : Command → ScalarExpression.Result
  | .filter next => next.eval calls original
      {frame with arrays := filterFrom frame.inputs.context.arrayNames frame.arrays}
  | .gate next => next.eval calls original
      {frame with gate := (calls.scalar frame.inputs.text frame.inputs.position
        frame.overlay frame.inputs.maskFirst frame.inputs.maskAfter frame.arrays.active [] frame.inputs.context.elaborating)}
  | .finish => if frame.gate.after = 0 then ScalarExpression.invalid else
      original frame.inputs.text frame.inputs.context frame.inputs.position frame.inputs.facts
        frame.inputs.maskFirst frame.inputs.maskAfter []

def Command.render : Command → List String
  | .filter next => filterRender ++ next.render
  | .gate next => ["gate", ":=", "scalar_expressions", "."] ++ Expressions.call "read_expression"
      [["text"], ["position"], ["overlay"], ["mask_first"], ["mask_after"],
        ["arrays", "=>", "arrays"], ["elaborating", "=>", "context", ".", "elaborating"]] ++
      [";"] ++ next.render
  | .finish => ["if", "gate", ".", "after", "=", "0", "then", "return", "scalar_expressions", ".", "invalid", ";",
      "end", "if", ";", "return"] ++ Expressions.call "read_scalar_in_flow"
      [["text"], ["context"], ["position"], ["facts"], ["mask_first"], ["mask_after"]] ++ [";"]

def body : Command := .filter (.gate .finish)
def eval (calls : FlowReaders.Calls) (original : FlowReaders.ScalarWrapper) (inputs : FlowReaders.Inputs) :=
  body.eval calls original (initial calls inputs)

def render : List String := expectedTokens
  "Overlay : constant Scalar_Expressions.Environment := Reading_Names (Context, Facts); Arrays : Array_Bindings.Metadata := Array_Bindings.Empty_Metadata; Gate : Scalar_Expressions.Expression_Result; begin" ++
  body.render ++ ["end", "read_counted_bound", ";"]

/-- Native calls are interpreted only on their proved domains. In particular,
the direct scalar gate is interpreted on the proved filtered metadata. -/
theorem eval_meaning {calls : FlowReaders.Calls} {original : FlowReaders.ScalarWrapper}
    (meaning : FlowReaders.Meaning calls) (source : FlowReaders.ScalarRefinement calls original)
    (inputs : FlowReaders.Inputs) (legal : FlowReaders.Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    eval calls original inputs = readCountedBound inputs.text inputs.context.model inputs.position
      inputs.facts inputs.maskFirst inputs.maskAfter := by
  have overlay := FlowReaders.overlay_meaning meaning.reading legal.context legal.flow
  have names := ScalarMetadata.readingNames_valid (declarations := inputs.context.declarationCount)
    legal.context.2.2.1
    legal.flow.2.compatible.count legal.flow.2.bounded
  have arrays := countedArrays_valid legal.context.arrays
  have initials : ArrayBindings.ValidInitials [] := by
    simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements]
  have gate := meaning.scalar inputs.text legal.text inputs.position
    (inputs.context.model.readingNames inputs.facts) inputs.maskFirst inputs.maskAfter
    (countedArrays inputs.context.arrayNames) [] inputs.context.elaborating
    legal.position names mask arrays initials
  have originalMeaning := FlowReaders.scalar_meaning meaning source
    {inputs with initials := []} ⟨legal.text, legal.context, legal.flow, legal.position, initials⟩ mask
  have selected : (filterFrom inputs.context.arrayNames Scratch.empty).active =
      countedArrays inputs.context.arrayNames := filtered_active _
  simp only [eval, body, Command.eval, initial, selected, overlay, gate]
  exact congrArg (fun result => if (countedBoundGate inputs.text inputs.context.model inputs.position
    inputs.facts inputs.maskFirst inputs.maskAfter).after = 0 then ScalarExpression.invalid else result)
    originalMeaning

structure Refinement (calls : FlowReaders.Calls) (original : FlowReaders.ScalarWrapper) (wrapper : Wrapper) : Prop where
  equation : ∀ inputs, FlowReaders.Legal inputs →
    (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text →
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter = eval calls original inputs

theorem wrapper_meaning {calls original wrapper} (meaning : FlowReaders.Meaning calls)
    (source : FlowReaders.ScalarRefinement calls original) (verified : Refinement calls original wrapper)
    (inputs : FlowReaders.Inputs) (legal : FlowReaders.Legal inputs)
    (mask : (⟨inputs.maskFirst, inputs.maskAfter⟩ : Named.NameState).Valid inputs.text) :
    wrapper inputs.text inputs.context inputs.position inputs.facts inputs.maskFirst inputs.maskAfter =
      readCountedBound inputs.text inputs.context.model inputs.position inputs.facts inputs.maskFirst inputs.maskAfter :=
  (verified.equation inputs legal mask).trans (eval_meaning meaning source inputs legal mask)

def modelWrapper (calls : FlowReaders.Calls) (original : FlowReaders.ScalarWrapper) : Wrapper :=
  fun text context position facts first after => eval calls original
    {text, context, position, facts, maskFirst := first, maskAfter := after}

theorem model_refinement (calls : FlowReaders.Calls) (original : FlowReaders.ScalarWrapper) :
    Refinement calls original (modelWrapper calls original) := ⟨by intros; rfl⟩

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
