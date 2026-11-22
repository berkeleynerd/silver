module

public import Silver.SequenceAdmission
public import Silver.ComposeContracts

@[expose] public section

/-! The retained sequence-scanner model shares its complete declaration
environment between frames. These conversions preserve its full admission
state; failed scans have the canonical invalid result. The current compiler's
metadata-only context and separate array environment are interpreted by
`Predicate.Native`, rather than this earlier mathematical witness. -/

namespace Silver.Sequence.Native
open Compose

structure Context where
  names : BindingEnvironment
  dynamicFirst : Nat
  dynamicAfter : Nat
  scalarNames : ScalarExpression.Environment
  arrayNames : ArrayBindings.Env
  subtypeNames : IntegerSubtypes.Environment
  booleanNames : BooleanBindings.Environment
  functions : FunctionBindings.Metadata
  pure : Bool
  assignedInFunctions : Bool
  «hiding» : HiddenMarks
  firstParameter : Nat
  procedures : ProcedureBindings.Metadata
  firstProcedureParameter : Nat
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
  ⟨scan.state.names, scan.state.dynamicFirst, scan.state.dynamicAfter,
    scan.state.scalarNames, scan.state.arrayNames, scan.state.subtypeNames, scan.state.booleanNames,
    scan.state.functions, scan.state.pure, scan.state.assignedInFunctions, scan.state.hiding,
    scan.state.firstParameter, scan.state.procedures, scan.state.firstProcedureParameter⟩

def bodyOf (scan : ScanResult) : Scan :=
  ⟨scan.state.position, scan.state.target, scan.state.capacity, scan.assigned, scan.output⟩

def expand (context : Context) (scan : Scan) : ScanResult :=
  ⟨⟨scan.position, context.names, context.dynamicFirst, context.dynamicAfter,
      scan.target, scan.capacity, context.scalarNames, context.arrayNames, context.subtypeNames, context.booleanNames,
      context.functions, context.pure, context.assignedInFunctions, context.hiding, context.firstParameter, context.procedures,
      context.firstProcedureParameter⟩, scan.assigned, scan.output⟩

def compact (context : Context) (scan : ScanResult) : Scan :=
  if scan.state.position = 0 ∨ context.names.length < scan.state.target then invalid
  else bodyOf scan

def lift (context : Context) (scan : Scan) : ScanResult :=
  if scan.position = 0 then invalidScan else expand context scan

def ValidContext (text : Source) (context : Context) : Prop :=
  Compose.Expressions.ValidNames text context.names ∧
    (⟨context.dynamicFirst, context.dynamicAfter⟩ : Named.NameState).Valid text ∧
    ScalarExpression.ValidEnvironment text context.scalarNames ∧
    ArrayBindings.ValidNativeEnvironment text context.arrayNames ∧
    IntegerSubtypes.ValidEnvironment text context.subtypeNames ∧
    BooleanBindings.ValidEnvironment text context.booleanNames ∧
    FunctionBindings.ValidMetadata text context.functions ∧
    context.firstParameter ≤ context.functions.parameters.length + 1 ∧
    context.firstParameter ≤ FunctionBindings.maxFormals ∧
    ProcedureBindings.ValidMetadata text context.procedures ∧
    context.firstProcedureParameter ≤ context.procedures.parameters.length + 1 ∧
    context.firstProcedureParameter ≤ ProcedureBindings.maxFormals

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
