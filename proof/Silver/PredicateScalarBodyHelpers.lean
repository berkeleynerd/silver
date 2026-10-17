module

public import Silver.PredicateScalarBodyNative
public import Silver.ComposeEquations

@[expose] public section
namespace Silver.Predicate.ScalarBodyNative
open Compose

/-- Native helper domains are the actual inherited contracts. -/
def CursorDomain (text : Source) (position : Nat) : Prop :=
  Expressions.ValidText text ∧ Expressions.ValidCursor text position

def LookupDomain (text : Source) (names : ScalarExpression.Environment) (first after : Nat) : Prop :=
  Expressions.ValidText text ∧ ScalarExpression.ValidEnvironment text names ∧
    Expressions.ValidCursor text first ∧ Expressions.ValidCursor text after

def ReadDomain (text : Source) (position : Nat) (names : ScalarExpression.Environment) : Prop :=
  CursorDomain text position ∧ ScalarExpression.ValidEnvironment text names

structure ImportsMeaning (imports : Imports) : Prop where
  skip : ∀ text position, CursorDomain text position → imports.skip text position = skipAt text position
  nameAfter : ∀ text position, CursorDomain text position → imports.nameAfter text position = Compose.nameAfter text position
  lookup : ∀ text names first after, LookupDomain text names first after →
    imports.lookup text names first after = ScalarExpression.lookup text names first after
  assignment : ∀ text position, CursorDomain text position →
    imports.assignment text position = fixedAfter text position ":=" false
  read : ∀ text position names, ReadDomain text position names →
    imports.read text position names = ScalarExpression.read text position names
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
    assignment := fun text position => if CursorDomain text position then imports.assignment text position else modelImports.assignment text position
    read := fun text position names => if ReadDomain text position names then imports.read text position names else modelImports.read text position names
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

theorem totalize_read (imports : Imports) (text : Source) (position : Nat) (names : ScalarExpression.Environment)
    (valid : ReadDomain text position names) :
    (totalize imports).read text position names = imports.read text position names := by simp only [totalize, valid, ↓reduceIte]

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
  · funext text position
    simp only [totalize]
    split
    · exact meaning.assignment text position ‹_›
    · rfl
  · funext text position names
    simp only [totalize]
    split
    · exact meaning.read text position names ‹_›
    · rfl
  · funext bounds
    simp only [totalize]
    split
    · exact meaning.isEmpty bounds ‹_›
    · rfl

def inheritedImports (calls : Expressions.Calls) : Imports where
  skip := calls.function .skip
  nameAfter := calls.function .nameAfter
  lookup := calls.function .scalarLookup
  assignment := fun text position => calls.function .takeToken text position (.symbol ":=")
  read := calls.function .scalarRead
  isEmpty := calls.function .scalarEmpty

theorem inherited_meaning {calls : Expressions.Calls} (source : Expressions.HelperEquations calls) :
    ImportsMeaning (inheritedImports calls) where
  skip text position valid := Expressions.interpreted_skip calls source text valid.1 position valid.2
  nameAfter text position valid := Expressions.interpreted_name calls source text valid.1 position valid.2
  lookup text names first after valid := source.scalarLookup text valid.1 names first after valid.2.1 valid.2.2.1 valid.2.2.2
  assignment text position valid := by
    exact Expressions.interpreted_take calls source text valid.1 position (.symbol ":=") valid.2 (by unfold Expressions.ValidToken; decide +kernel)
  read text position names valid := source.scalarRead text valid.1.1 position names valid.1.2 valid.2
  isEmpty bounds valid := source.scalarEmpty bounds valid

theorem targetEval_inherited {calls : Expressions.Calls} (source : Expressions.HelperEquations calls)
    (text : Source) (context : Native.Context) (position : Nat) :
    targetEval (totalize (inheritedImports calls)) text context position = scalarTarget text context.model position := by
  rw [totalize_eq_model (inherited_meaning source)]
  exact targetEval_model text context position

theorem assignmentEval_inherited {calls : Expressions.Calls} (source : Expressions.HelperEquations calls)
    (text : Source) (context : Native.Context) (scan : BodyScan) :
    assignmentEval (totalize (inheritedImports calls)) text context scan = scalarAssignmentBody text context.model scan := by
  rw [totalize_eq_model (inherited_meaning source)]
  exact assignmentEval_model text context scan

end Silver.Predicate.ScalarBodyNative
