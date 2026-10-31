module

public import Silver.PredicateBooleanBodyNative
public import Silver.PredicateBodyControls
public import Silver.PredicateBodyWrappers

@[expose] public section
namespace Silver.Predicate.BooleanBodyNative
open Compose

def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def ScalarLookupDomain (text : Source) (names : ScalarExpression.Environment) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ScalarExpression.ValidEnvironment text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def BooleanLookupDomain (text : Source) (names : BooleanBindings.Environment) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ BooleanBindings.ValidEnvironment text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def TargetDomain (text : Source) (context : Native.Context) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Native.ValidContext text context ∧ Expressions.ValidCursor text position

def ReadDomain (text : Source) (context : Native.Context) (position : Nat) (facts : ActiveFlow) : Prop :=
  TargetDomain text context position ∧ Native.ValidFlow context facts

def AssignmentDomain (text : Source) (context : Native.Context) (scan : BodyScan) : Prop :=
  TargetDomain text context scan.position ∧ Controls context.model scan ∧ Native.ValidFlow context scan.facts

structure ImportsMeaning (imports : Imports) : Prop where
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  scalarLookup : ∀ text names first after, ScalarLookupDomain text names first after →
    imports.scalarLookup text names first after = ScalarExpression.lookup text names first after
  booleanLookup : ∀ text names first after, BooleanLookupDomain text names first after →
    imports.booleanLookup text names first after = BooleanBindings.lookup text names first after
  assignment : ∀ text position, CursorDomain text position → imports.assignment text position = fixedAfter text position ":=" false
  condition : ∀ text context position facts, ReadDomain text context position facts →
    imports.condition text context position facts = readCondition text context.model position facts
  invalid : ∀ scan, scan.count ≤ ScalarExpression.maxBindings → imports.invalid scan = invalidBody scan

/-- Each callee retains its native meaning on its complete verified domain.
Values outside those domains are a formal totalization only. -/
noncomputable def totalize (imports : Imports) : Imports := by
  classical
  exact {
    skip := fun text position => if CursorDomain text position then imports.skip text position else modelImports.skip text position
    nameAfter := fun text position => if CursorDomain text position then imports.nameAfter text position else modelImports.nameAfter text position
    scalarLookup := fun text names first after => if ScalarLookupDomain text names first after then imports.scalarLookup text names first after else modelImports.scalarLookup text names first after
    booleanLookup := fun text names first after => if BooleanLookupDomain text names first after then imports.booleanLookup text names first after else modelImports.booleanLookup text names first after
    assignment := fun text position => if CursorDomain text position then imports.assignment text position else modelImports.assignment text position
    condition := fun text context position facts => if ReadDomain text context position facts then imports.condition text context position facts else modelImports.condition text context position facts
    invalid := fun scan => if scan.count ≤ ScalarExpression.maxBindings then imports.invalid scan else modelImports.invalid scan }

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
    · exact meaning.scalarLookup text names first after ‹_›
    · rfl
  · funext text names first after
    simp only [totalize]
    split
    · exact meaning.booleanLookup text names first after ‹_›
    · rfl
  · funext text position
    simp only [totalize]
    split
    · exact meaning.assignment text position ‹_›
    · rfl
  · funext text context position facts
    simp only [totalize]
    split
    · exact meaning.condition text context position facts ‹_›
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

/-- Target and ghost assignment equations interpret their checked typed trees.
The executable assignment contributes its exact checked Static postcondition. -/
structure DefinitionEquations (imports : Imports) (calls : Calls) : Prop where
  target : ∀ text context position, TargetDomain text context position →
    calls.target text context position = targetEval (totalize imports) text context position
  assignmentSized : ∀ text context scan, AssignmentDomain text context scan →
    assignmentBody.Sized (totalize imports) (totalizeTarget calls.target) {text, context, scan}
  assignmentModel : ∀ text context scan, AssignmentDomain text context scan →
    calls.assignmentModel text context scan = assignmentEval (totalize imports) (totalizeTarget calls.target) text context scan
  assignment : ∀ text context scan, AssignmentDomain text context scan →
    calls.assignment text context scan = calls.assignmentModel text context scan

theorem target_meaning {imports calls} (meaning : ImportsMeaning imports)
    (definitions : DefinitionEquations imports calls) (text : Source) (context : Native.Context) (position : Nat)
    (valid : TargetDomain text context position) :
    calls.target text context position = booleanTarget text context.model position := by
  rw [definitions.target text context position valid, totalize_eq_model meaning]
  exact target_model ..

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
    calls.assignment text context scan = booleanAssignmentBody text context.model scan := by
  rw [definitions.assignment text context scan valid, definitions.assignmentModel text context scan valid,
    totalize_eq_model meaning, totalizeTarget_eq_model meaning definitions]
  exact assignment_model ..

theorem model_imports_meaning : ImportsMeaning modelImports := by constructor <;> intros <;> rfl

theorem model_totalizeTarget : totalizeTarget modelTarget = modelTarget := by
  funext text context position
  simp only [totalizeTarget]
  split <;> rfl

theorem model_definitions : DefinitionEquations modelImports modelCalls where
  target text context position _ := by
    rw [totalize_eq_model model_imports_meaning]
    exact (target_model ..).symm
  assignmentSized text context scan _ := by
    rw [totalize_eq_model model_imports_meaning]
    change assignmentBody.Sized modelImports (totalizeTarget modelTarget) _
    rw [model_totalizeTarget]
    exact assignment_sized ..
  assignmentModel text context scan _ := by
    rw [totalize_eq_model model_imports_meaning]
    change booleanAssignmentBody text context.model scan = assignmentEval modelImports (totalizeTarget modelTarget) _ _ _
    rw [model_totalizeTarget]
    exact (assignment_model ..).symm
  assignment _ _ _ _ := rfl

end Silver.Predicate.BooleanBodyNative
