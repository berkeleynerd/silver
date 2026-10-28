module

public import Silver.PredicateScalarBodyNative
public import Silver.ComposeEquations
public import Silver.PredicateFlowReaderLibraries
public import Silver.PredicateBodyWrappers
public import Silver.PredicateBodyControls

@[expose] public section
namespace Silver.Predicate.ScalarBodyNative
open Compose

variable {domain : Expressions.StateDomain}

/-- Native helper domains are the actual inherited contracts. -/
def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def LookupDomain (text : Source) (names : ScalarExpression.Environment) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ScalarExpression.ValidEnvironment text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def StringLookupDomain (text : Source) (names : BindingEnvironment) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidNames text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def ReadDomain (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow) : Prop :=
  FlowReaders.Legal {text, context, position, facts}

structure ImportsMeaning (imports : Imports) : Prop where
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  lookup : ∀ text names first after, LookupDomain text names first after →
    imports.lookup text names first after = ScalarExpression.lookup text names first after
  stringLookup : ∀ text names first after, StringLookupDomain text names first after →
    imports.stringLookup text names first after = lookupName text names first after
  assignment : ∀ text position, CursorDomain text position →
    imports.assignment text position = fixedAfter text position ":=" false
  read : ∀ text context position facts, ReadDomain text context position facts →
    imports.read text context position facts = ScalarExpression.read text position (context.model.readingNames facts) (arrays := context.arrayNames)
  invalidModel : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → imports.invalidModel scan = invalidBody scan
  isEmpty : ∀ bounds, bounds.Bounded → imports.isEmpty bounds = bounds.isEmpty

/-- A formal extension outside verified call domains. On every legal native
call it retains the imported implementation; GNATprove proves call legality
against the exact source contracts checked with the typed body. -/
noncomputable def totalize (imports : Imports) : Imports := by
  classical
  exact {
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    lookup := fun text names first after => if LookupDomain text names first after then imports.lookup text names first after else modelImports.lookup text names first after
    stringLookup := fun text names first after => if StringLookupDomain text names first after then imports.stringLookup text names first after else modelImports.stringLookup text names first after
    assignment := fun text position => if CursorDomain text position then imports.assignment text position else modelImports.assignment text position
    read := fun text context position facts => if ReadDomain text context position facts then imports.read text context position facts else modelImports.read text context position facts
    invalidModel := fun scan => if scan.count ≤ ScalarExpression.maxBindings then imports.invalidModel scan else invalidBody scan
    isEmpty := fun bounds => if bounds.Bounded then imports.isEmpty bounds else modelImports.isEmpty bounds }

theorem totalize_skip (imports : Imports) (text : Source) (position : Nat) (valid : CursorDomain text position) :
    (totalize imports).skip text position = imports.skip text position := by simp only [totalize, valid, ↓reduceIte]

theorem totalize_nameAfter (imports : Imports) (text : Source) (position : Nat) (valid : CursorDomain text position) :
    (totalize imports).nameAfter text position = imports.nameAfter text position := by simp only [totalize, valid, ↓reduceIte]

theorem totalize_lookup (imports : Imports) (text : Source) (names : ScalarExpression.Environment) (first after : Nat)
    (valid : LookupDomain text names first after) :
    (totalize imports).lookup text names first after = imports.lookup text names first after := by simp only [totalize, valid, ↓reduceIte]

theorem totalize_assignment (imports : Imports) (text : Source) (position : Nat) (valid : CursorDomain text position) :
    (totalize imports).assignment text position = imports.assignment text position := by simp only [totalize, valid, ↓reduceIte]

theorem totalize_read (imports : Imports) (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow)
    (valid : ReadDomain text context position facts) :
    (totalize imports).read text context position facts = imports.read text context position facts := by
  simp only [totalize, valid, ↓reduceIte]

theorem totalize_isEmpty (imports : Imports) (bounds : Integer.Interval) (valid : bounds.Bounded) :
    (totalize imports).isEmpty bounds = imports.isEmpty bounds := by simp only [totalize, valid, ↓reduceIte]

theorem totalize_eq_model {imports : Imports} (meaning : ImportsMeaning imports) : totalize imports = modelImports := by
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
    · exact meaning.lookup text names first after ‹_›
    · rfl
  · funext text names first after
    simp only [totalize]
    split
    · exact meaning.stringLookup text names first after ‹_›
    · rfl
  · funext text position
    simp only [totalize]
    split
    · exact meaning.assignment text position ‹_›
    · rfl
  · funext text context position facts
    simp only [totalize]
    split
    · exact meaning.read text context position facts ‹_›
    · rfl
  · funext scan
    simp only [totalize]
    split
    · exact meaning.invalidModel scan ‹_›
    · rfl
  · funext bounds
    simp only [totalize]
    split
    · exact meaning.isEmpty bounds ‹_›
    · rfl
def inheritedImports (calls : Expressions.Calls) (scalar : FlowReaders.DefaultScalarWrapper)
    (body : BodyWrappers.Calls) : Imports where
  skip := calls.function .skip
  nameAfter := calls.function .nameAfter
  lookup := calls.function .scalarLookup
  stringLookup := calls.function .lookupName
  assignment := fun text position => calls.function .takeToken text position (.symbol ":=")
  read := scalar
  invalidModel := body.invalidModel
  isEmpty := calls.function .scalarEmpty

theorem inherited_meaning {calls : Expressions.Calls} {scalar string body}
    (source : Expressions.HelperEquations calls (domain := domain))
    (flow : FlowReaders.Links calls scalar string) (invalid : BodyWrappers.DefinitionEquations body) :
    ImportsMeaning (inheritedImports calls scalar body) where
  skip text position valid := Expressions.interpreted_skip calls source text valid.1 position valid.2
  nameAfter text position valid := Expressions.interpreted_name calls source text valid.1 position valid.2
  lookup text names first after valid := source.scalarLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  stringLookup text names first after valid :=
    Expressions.interpreted_lookup calls source text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  assignment text position valid := by
    exact Expressions.interpreted_take calls source text valid.1 position (.symbol ":=") valid.2 (by unfold Expressions.ValidToken; decide +kernel)
  read text context position facts valid := FlowReaders.linked_scalar source flow {text,context,position,facts} valid
  invalidModel scan capacity := BodyWrappers.invalidModel_meaning invalid scan capacity
  isEmpty bounds valid := source.scalarEmpty bounds valid

def TargetDomain (text : Source) (context : Native.Context) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Native.ValidContext text context ∧ Expressions.ValidCursor text position

def AssignmentDomain (text : Source) (context : Native.Context) (scan : BodyScan) : Prop :=
  TargetDomain text context scan.position ∧ Controls context.model scan ∧ Native.ValidFlow context scan.facts

/-- The ghost assignment body is interpreted independently; the executable
wrapper contributes only its checked Static equality and constrained extent. -/
structure DefinitionEquations (imports : Imports) (calls : Calls) : Prop where
  target : ∀ text context position, TargetDomain text context position →
    calls.target text context position = targetEval (totalize imports) text context position
  stringTarget : ∀ text context position, TargetDomain text context position →
    calls.stringTarget text context position = stringTargetEval (totalize imports) text context position
  assignmentSized : ∀ text context scan, AssignmentDomain text context scan →
    (assignmentEval (totalize imports) text context scan).count = scan.count
  assignmentModel : ∀ text context scan, AssignmentDomain text context scan →
    calls.assignmentModel text context scan = assignmentEval (totalize imports) text context scan
  assignment : ∀ text context scan, AssignmentDomain text context scan →
    calls.assignment text context scan = assignmentRhs.eval calls text context scan

theorem target_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (position : Nat)
    (valid : TargetDomain text context position) :
    calls.target text context position = scalarTarget text context.model position := by
  rw [definitions.target text context position valid, totalize_eq_model meaning]
  exact targetEval_model ..

theorem stringTarget_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (scan : BodyScan)
    (valid : TargetDomain text context scan.position) :
    calls.stringTarget text context scan.position =
      ⟨(targetAt text (parserState context.model scan) false).position,
       (targetAt text (parserState context.model scan) false).target⟩ := by
  rw [definitions.stringTarget text context scan.position valid, totalize_eq_model meaning]
  exact stringTargetEval_model ..

theorem assignment_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (scan : BodyScan)
    (valid : AssignmentDomain text context scan) :
    calls.assignment text context scan = scalarAssignmentBody text context.model scan := by
  rw [definitions.assignment text context scan valid]
  change calls.assignmentModel text context scan = _
  rw [definitions.assignmentModel text context scan valid, totalize_eq_model meaning]
  exact assignmentEval_model ..

theorem model_imports_meaning : ImportsMeaning modelImports where
  skip _ _ _ := rfl
  nameAfter _ _ _ := rfl
  lookup _ _ _ _ _ := rfl
  stringLookup _ _ _ _ _ := rfl
  assignment _ _ _ := rfl
  read _ _ _ _ _ := rfl
  invalidModel _ _ := rfl
  isEmpty _ _ := rfl

theorem model_definitions : DefinitionEquations modelImports modelCalls where
  target text context position _ := by
    rw [totalize_eq_model model_imports_meaning]
    exact (targetEval_model ..).symm
  stringTarget _ _ _ _ := by rw [totalize_eq_model model_imports_meaning]; rfl
  assignmentSized text context scan _ := by
    rw [totalize_eq_model model_imports_meaning]
    exact assignmentEval_model_count ..
  assignmentModel text context scan _ := by
    rw [totalize_eq_model model_imports_meaning]
    exact (assignmentEval_model ..).symm
  assignment _ _ _ _ := rfl

end Silver.Predicate.ScalarBodyNative
