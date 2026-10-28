module

public import Silver.PredicateArrayBodyNative
public import Silver.PredicateScalarBodyHelpers
public import Silver.ArrayBindingsNativeEquations
public import Silver.SourceDeclarations

@[expose] public section

namespace Silver.Predicate.ArrayBodyNative
open Compose

variable {domain : Expressions.StateDomain}

abbrev CursorDomain := ScalarBodyNative.CursorDomain
abbrev ScalarLookupDomain := ScalarBodyNative.LookupDomain
abbrev TargetDomain := ScalarBodyNative.TargetDomain
abbrev AssignmentDomain := ScalarBodyNative.AssignmentDomain
abbrev ReadDomain := ScalarBodyNative.ReadDomain

def ArrayLookupDomain (text : Source) (arrays : ArrayBindings.Metadata) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ArrayBindings.ValidMetadata text arrays ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def tokens : List ShellToken := [.symbol "(", .symbol ")", .symbol ":="]

def TokenDomain (text : Source) (position : Nat) (token : ShellToken) : Prop :=
  CursorDomain text position ∧ token ∈ tokens

structure ImportsMeaning (imports : Imports) : Prop where
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  scalarLookup : ∀ text names first after, ScalarLookupDomain text names first after →
    imports.scalarLookup text names first after = ScalarExpression.lookup text names first after
  arrayLookup : ∀ text arrays first after, ArrayLookupDomain text arrays first after →
    imports.arrayLookup text arrays first after = ArrayBindings.lookup text arrays first after
  token : ∀ text position token, TokenDomain text position token →
    imports.token text position token = tokenAfter text position token
  readIndex : ∀ text context position facts, ReadDomain text context position facts →
    imports.readIndex text context position facts = ScalarExpression.read text position (context.model.readingNames facts)
  readValue : ∀ text context position facts, ReadDomain text context position facts →
    imports.readValue text context position facts =
      ScalarExpression.read text position (context.model.readingNames facts) (arrays := context.arrayNames)
  contains : ∀ item indices, ArrayBindings.Native.BindingType item → indices.Bounded →
    imports.contains item indices = ArrayBindings.contains item indices
  isEmpty : ∀ bounds, bounds.Bounded → imports.isEmpty bounds = bounds.isEmpty
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → imports.invalid scan = invalidBody scan

/-- Outside the verified native call domains, extend each imported operation
by its proved model. The source bridge retains native call legality separately. -/
noncomputable def totalize (imports : Imports) : Imports := by
  classical
  exact {
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    scalarLookup := fun text names first after => if ScalarLookupDomain text names first after then imports.scalarLookup text names first after else modelImports.scalarLookup text names first after
    arrayLookup := fun text arrays first after => if ArrayLookupDomain text arrays first after then imports.arrayLookup text arrays first after else modelImports.arrayLookup text arrays first after
    token := fun text position token => if TokenDomain text position token then imports.token text position token else modelImports.token text position token
    readIndex := fun text context position facts => if ReadDomain text context position facts then imports.readIndex text context position facts else modelImports.readIndex text context position facts
    readValue := fun text context position facts => if ReadDomain text context position facts then imports.readValue text context position facts else modelImports.readValue text context position facts
    contains := fun item indices => if ArrayBindings.Native.BindingType item ∧ indices.Bounded then imports.contains item indices else modelImports.contains item indices
    isEmpty := fun bounds => if bounds.Bounded then imports.isEmpty bounds else modelImports.isEmpty bounds
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then imports.invalid scan else modelImports.invalid scan }

theorem totalize_eq_model {imports : Imports} (meaning : ImportsMeaning imports) :
    totalize imports = modelImports := by
  apply Imports.ext
  · funext text position
    simp only [totalize]
    split
    · exact meaning.skip text position ‹_›
    · rfl
  · funext text position
    simp only [totalize]
    split
    · exact meaning.nameAfter text position ‹_›
    · rfl
  · funext text names first after
    simp only [totalize]
    split
    · exact meaning.scalarLookup text names first after ‹_›
    · rfl
  · funext text arrays first after
    simp only [totalize]
    split
    · exact meaning.arrayLookup text arrays first after ‹_›
    · rfl
  · funext text position token
    simp only [totalize]
    split
    · exact meaning.token text position token ‹_›
    · rfl
  · funext text context position facts
    simp only [totalize]
    split
    · exact meaning.readIndex text context position facts ‹_›
    · rfl
  · funext text context position facts
    simp only [totalize]
    split
    · exact meaning.readValue text context position facts ‹_›
    · rfl
  · funext item indices
    simp only [totalize]
    split
    · exact meaning.contains item indices (And.left ‹_›) (And.right ‹_›)
    · rfl
  · funext bounds
    simp only [totalize]
    split
    · exact meaning.isEmpty bounds ‹_›
    · rfl
  · funext scan
    simp only [totalize]
    split
    · exact meaning.invalid scan ‹_›
    · rfl

noncomputable def totalizeTarget (target : TargetCall) : TargetCall := by
  classical
  exact fun text context position => if TargetDomain text context position then
    target text context position else modelTarget text context position

/-- These are equations of the checked source trees, with no equality to the
mathematical indexed assignment assumed. -/
structure DefinitionEquations (imports : Imports) (calls : Calls) : Prop where
  target : ∀ text context position, TargetDomain text context position →
    calls.target text context position = targetEval (totalize imports) text context position
  assignment : ∀ text context scan, AssignmentDomain text context scan →
    calls.assignment text context scan =
      assignmentEval (totalize imports) (totalizeTarget calls.target) text context scan

theorem target_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (position : Nat)
    (valid : TargetDomain text context position) :
    calls.target text context position = arrayTarget text context.model position := by
  rw [definitions.target text context position valid, totalize_eq_model meaning]
  exact targetEval_model ..

theorem totalizeTarget_eq_model {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) : totalizeTarget calls.target = modelTarget := by
  funext text context position
  simp only [totalizeTarget]
  split
  · exact target_meaning meaning definitions text context position ‹_›
  · rfl

theorem assignment_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (scan : BodyScan)
    (valid : AssignmentDomain text context scan) :
    calls.assignment text context scan = arrayAssignmentBody text context.model scan := by
  rw [definitions.assignment text context scan valid, totalize_eq_model meaning,
    totalizeTarget_eq_model meaning definitions]
  exact assignmentEval_model ..

def inheritedImports (calls : Expressions.Calls) (scalar : FlowReaders.DefaultScalarWrapper)
    (reading : FlowSourceBridge.Context → ActiveFlow.Storage → FlowSourceBridge.NameStorage)
    (arrays : ArrayBindings.Native.Calls) (body : BodyWrappers.Calls) : Imports where
  skip := calls.function .skip
  nameAfter := calls.function .nameAfter
  scalarLookup := calls.function .scalarLookup
  arrayLookup := calls.function .arrayLookup
  token := calls.function .takeToken
  readIndex := fun text context position facts => calls.function .scalarRead text position
    (FlowReaders.overlay reading context facts) [] [] false
  readValue := scalar
  contains := arrays.contains
  isEmpty := calls.function .scalarEmpty
  invalid := body.invalid

theorem inherited_meaning {calls scalar string reading arrays body}
    (source : Expressions.HelperEquations calls (domain := domain))
    (flow : FlowReaders.Links calls scalar string)
    (readingSource : FlowSourceBridge.InterpretedReadingNames reading)
    (arrayPrimitives : ArrayBindings.Native.Primitives arrays)
    (arrayEquations : ArrayBindings.Native.Equations arrays)
    (bodyEquations : BodyWrappers.DefinitionEquations body) :
    ImportsMeaning (inheritedImports calls scalar reading arrays body) where
  skip text position valid := Expressions.interpreted_skip calls source text valid.1 position valid.2
  nameAfter text position valid := Expressions.interpreted_name calls source text valid.1 position valid.2
  scalarLookup text names first after valid := source.scalarLookup text valid.1 names first after
    valid.2.1 valid.2.2.1 valid.2.2.2
  arrayLookup text arrays first after valid := source.arrayLookup text valid.1 arrays first after
    valid.2.1 valid.2.2.1 valid.2.2.2
  token text position token valid := by
    have selected := valid.2
    simp only [tokens, List.mem_cons, List.mem_nil_iff, or_false] at selected
    rcases selected with rfl | rfl | rfl <;>
      exact Expressions.interpreted_take calls source text valid.1.1 position _ valid.1.2
        (by unfold Expressions.ValidToken; decide)
  readIndex text context position facts valid := by
    change calls.function .scalarRead text position (FlowReaders.overlay reading context facts) [] [] false = _
    rw [FlowReaders.overlay_meaning readingSource valid.2.1 valid.2.2.1]
    exact source.scalarRead text valid.1 position _ [] [] false valid.2.2.2
      (ScalarMetadata.readingNames_valid valid.2.1.2.2.1 valid.2.2.1.2.compatible.count valid.2.2.1.2.bounded)
      (by simp [ArrayBindings.ValidMetadata, ArrayBindings.maxBindings])
      (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
  readValue text context position facts valid := FlowReaders.linked_scalar source flow {text,context,position,facts} valid
  contains item indices itemType indexType :=
    ArrayBindings.Native.interpreted_contains arrays arrayPrimitives arrayEquations item indices itemType indexType
  isEmpty bounds valid := source.scalarEmpty bounds valid
  invalid scan size := BodyWrappers.invalid_meaning bodyEquations scan size

theorem model_imports_meaning : ImportsMeaning modelImports where
  skip _ _ _ := rfl
  nameAfter _ _ _ := rfl
  scalarLookup _ _ _ _ _ := rfl
  arrayLookup _ _ _ _ _ := rfl
  token _ _ _ _ := rfl
  readIndex _ _ _ _ _ := rfl
  readValue _ _ _ _ _ := rfl
  contains _ _ _ _ := rfl
  isEmpty _ _ := rfl
  invalid _ _ := rfl

theorem totalizeTarget_model : totalizeTarget modelTarget = modelTarget := by
  funext text context position
  simp only [totalizeTarget, ite_self]

theorem model_definitions : DefinitionEquations modelImports modelCalls where
  target text context position _ := by
    rw [totalize_eq_model model_imports_meaning]
    exact (targetEval_model ..).symm
  assignment text context scan _ := by
    change arrayAssignmentBody text context.model scan = _
    rw [totalize_eq_model model_imports_meaning]
    change _ = assignmentEval modelImports (totalizeTarget modelTarget) text context scan
    rw [totalizeTarget_model]
    exact (assignmentEval_model ..).symm

/-- The indexed helper imports the same scalar reader, flow-name overlay,
array library and invalid-body wrapper that occur in its native source. -/
structure Links (composed : Expressions.Calls) (scalar : FlowReaders.DefaultScalarWrapper)
    (calls : Calls) : Prop where
  source : ∃ reading arrays body,
    FlowSourceBridge.InterpretedReadingNames reading ∧
    ArrayBindings.Native.Primitives arrays ∧ ArrayBindings.Native.Equations arrays ∧
    BodyWrappers.DefinitionEquations body ∧
    DefinitionEquations (inheritedImports composed scalar reading arrays body) calls

theorem linked_target {composed scalar string calls}
    (source : Expressions.HelperEquations composed (domain := domain))
    (flow : FlowReaders.Links composed scalar string) (links : Links composed scalar calls)
    (text : Source) (context : Native.Context) (position : Nat)
    (valid : TargetDomain text context position) :
    calls.target text context position = arrayTarget text context.model position := by
  obtain ⟨reading, arrays, body, readingSource, primitives, equations, bodyEquations, definitions⟩ := links.source
  exact target_meaning (inherited_meaning source flow readingSource primitives equations bodyEquations)
    definitions text context position valid

theorem linked_assignment {composed scalar string calls}
    (source : Expressions.HelperEquations composed (domain := domain))
    (flow : FlowReaders.Links composed scalar string) (links : Links composed scalar calls)
    (text : Source) (context : Native.Context) (scan : BodyScan)
    (valid : AssignmentDomain text context scan) :
    calls.assignment text context scan = arrayAssignmentBody text context.model scan := by
  obtain ⟨reading, arrays, body, readingSource, primitives, equations, bodyEquations, definitions⟩ := links.source
  exact assignment_meaning (inherited_meaning source flow readingSource primitives equations bodyEquations)
    definitions text context scan valid

theorem model_links {scalar string}
    (source : Expressions.HelperEquations Expressions.modelCalls (domain := domain))
    (flow : FlowReaders.Links Expressions.modelCalls scalar string) :
    Links Expressions.modelCalls scalar modelCalls := by
  have meaning := inherited_meaning source flow FlowSourceBridge.model_reading_interpreted
    ArrayBindings.Native.model_primitives ArrayBindings.Native.model_equations BodyWrappers.model_definitions
  refine ⟨FlowSourceBridge.readingStorage, ArrayBindings.Native.modelCalls, BodyWrappers.modelCalls,
    FlowSourceBridge.model_reading_interpreted, ArrayBindings.Native.model_primitives,
    ArrayBindings.Native.model_equations, BodyWrappers.model_definitions, ?_⟩
  exact {
    target := fun text context position _ => by
      rw [totalize_eq_model meaning]
      exact (targetEval_model ..).symm
    assignment := fun text context scan _ => by
      rw [totalize_eq_model meaning]
      change _ = assignmentEval modelImports (totalizeTarget modelTarget) text context scan
      rw [totalizeTarget_model]
      exact (assignmentEval_model ..).symm }

namespace SourceChecks
open Silver.SourceBridge

def expectedTokens (text : String) : List String := (Source.lexLine text).getD []
def targetImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Position : Literal_Position) return Array_Bindings.Binding_Count"
def targetSpec : List String := targetImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Position <= Text'Last + 1, Post => Array_Target'Result <= Context.Array_Names.Count"
def assignmentImpl : List String := expectedTokens
  "(Text : String; Context : Body_Context; Scan : Body_Scan) return Body_Scan"
def assignmentSpec : List String := assignmentImpl ++ expectedTokens
  "with Global => null, Pre => Text'First = 1 and then Text'Length in 1 .. Max_Source_Length and then Valid_Context (Text, Context) and then Valid_Body (Text, Context, Scan), Post => Valid_Body (Text, Context, Array_Assignment_Body'Result) and then (Array_Assignment_Body'Result.Position = 0 or else Array_Assignment_Body'Result.Position > Scan.Position)"

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
        match headerEnd 0 tokens with
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
  target_body : qualifiedExpressionBody "array_target" tokens = some targetBody.render
  target_spec : functionHeader "array_target" ";" tokens = some targetSpec
  target_impl : functionHeader "array_target" "is" tokens = some targetImpl
  assignment_body : ordinaryFunction "array_assignment_body" tokens = some assignmentRender
  assignment_spec : functionHeader "array_assignment_body" ";" tokens = some assignmentSpec
  assignment_impl : functionHeader "array_assignment_body" "is" tokens = some assignmentImpl

end SourceChecks
end Silver.Predicate.ArrayBodyNative
