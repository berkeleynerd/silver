module

public import Silver.SequenceAdmission
public import Silver.ComposeEquations

@[expose] public section

/-! The native recursive scanner shares declarations and keeps only scalar
state in each frame. These conversions preserve the full scanner state used
by admission; failed scans have the canonical invalid result. -/

namespace Silver.Sequence.Native
open Compose

structure Context where
  names : BindingEnvironment
  dynamicFirst : Nat
  dynamicAfter : Nat
  scalarNames : ScalarExpression.Environment
  deriving DecidableEq, Repr

structure Scan where
  position : Nat
  target : Nat
  capacity : Nat
  assigned : Bool
  output : Bool
  deriving DecidableEq, Repr

def invalid : Scan := ⟨0, 0, 0, false, false⟩

def contextOf (scan : ScanResult) : Context :=
  ⟨scan.state.names, scan.state.dynamicFirst, scan.state.dynamicAfter, scan.state.scalarNames⟩

def bodyOf (scan : ScanResult) : Scan :=
  ⟨scan.state.position, scan.state.target, scan.state.capacity, scan.assigned, scan.output⟩

def expand (context : Context) (scan : Scan) : ScanResult :=
  ⟨⟨scan.position, context.names, context.dynamicFirst, context.dynamicAfter,
      scan.target, scan.capacity, context.scalarNames⟩, scan.assigned, scan.output⟩

def compact (context : Context) (scan : ScanResult) : Scan :=
  if scan.state.position = 0 ∨ context.names.length < scan.state.target then invalid
  else bodyOf scan

def lift (context : Context) (scan : Scan) : ScanResult :=
  if scan.position = 0 then invalidScan else expand context scan

def ValidContext (text : Source) (context : Context) : Prop :=
  Compose.Expressions.ValidNames text context.names ∧
    (⟨context.dynamicFirst, context.dynamicAfter⟩ : Named.NameState).Valid text ∧
    ScalarExpression.ValidEnvironment text context.scalarNames

def ValidScan (text : Source) (context : Context) (scan : Scan) : Prop :=
  scan.position ≤ text.length + 1 ∧ scan.target ≤ context.names.length ∧
    scan.capacity ≤ maxSourceLength

theorem contextOf_expand (context : Context) (scan : Scan) :
    contextOf (expand context scan) = context := by cases context; rfl

theorem bodyOf_expand (context : Context) (scan : Scan) :
    bodyOf (expand context scan) = scan := by cases scan; rfl

theorem expand_parts (scan : ScanResult) : expand (contextOf scan) (bodyOf scan) = scan := by
  cases scan with
  | mk state assigned output => cases state; rfl

theorem parts_valid (text : Source) (scan : ScanResult)
    (valid : Compose.Expressions.ValidState text scan.state) :
    ValidContext text (contextOf scan) ∧ ValidScan text (contextOf scan) (bodyOf scan) :=
  ⟨⟨valid.2.1, valid.2.2.1, valid.2.2.2.2.2⟩, valid.1, valid.2.2.2.1, valid.2.2.2.2.1⟩

theorem expand_valid (text : Source) (context : Context) (scan : Scan)
    (contextValid : ValidContext text context) (scanValid : ValidScan text context scan) :
    Compose.Expressions.ValidState text (expand context scan).state :=
  ⟨scanValid.1, contextValid.1, contextValid.2.1, scanValid.2.1, scanValid.2.2, contextValid.2.2⟩

theorem invalid_valid (text : Source) (context : Context) : ValidScan text context invalid := by
  simp [ValidScan, invalid]

theorem compact_valid (text : Source) (context : Context) (scan : ScanResult)
    (valid : Compose.Expressions.ValidState text scan.state) :
    ValidScan text context (compact context scan) := by
  unfold compact
  split
  · exact invalid_valid text context
  · rename_i successful
    refine ⟨valid.1, ?_, valid.2.2.2.2.1⟩
    simp only [not_or, Nat.not_lt] at successful
    exact successful.2

theorem compact_expand (context : Context) (scan : Scan)
    (target : scan.target ≤ context.names.length) :
    compact context (expand context scan) = if scan.position = 0 then invalid else scan := by
  simp [compact, expand, Nat.not_lt.mpr target, bodyOf]

theorem lift_compact (context : Context) (scan : ScanResult)
    (same : contextOf scan = context) (target : scan.state.target ≤ context.names.length) :
    lift context (compact context scan) = if scan.state.position = 0 then invalidScan else scan := by
  subst context
  by_cases zero : scan.state.position = 0
  · simp [compact, lift, zero, invalid]
  · simp only [compact, zero, Nat.not_lt.mpr target, or_self, ↓reduceIte]
    simpa only [lift, bodyOf, zero, ↓reduceIte] using expand_parts scan

end Silver.Sequence.Native
