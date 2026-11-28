module

public import Silver.ApplicationPackageDeclarationsNameImports
public import Silver.ApplicationPackageDeclarationsObjectEquations
public import Silver.ApplicationPackageCallsValidityNative
public import Silver.ApplicationPackageBooleanInitializer
public import Silver.ScalarExpressionSourceBridge

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames

structure ObjectLibraries where
  names : NameLibraries
  scalar : ScalarExpression.Native.Calls
  scalarSource : ScalarExpression.SourceBridge.InterpretedSource scalar
  booleanSource : BooleanInitializer.Library names.shared.composed

namespace ObjectLibraries

private theorem domain_of_holds (left right : StateDomain) (same : left.holds = right.holds) : left = right := by
  cases left
  cases right
  cases same
  rfl

private theorem exact_domain (library : ObjectLibraries) :
    library.names.shared.domain = Predicate.OuterReadiness.domain := by
  apply domain_of_holds
  funext text state
  apply propext
  rw [library.names.header.domain.state]
  exact ⟨fun original => ⟨original.base, original.ready, original.bounds⟩,
    fun original => ⟨original.base, original.ready, original.bounds⟩⟩

theorem boolean (library : ObjectLibraries) {text frame position first last}
    (valid : ValidText text) (state : ReaderFrame text frame) (bounded : ValidCursor text position)
    (span : ValidName text first last) :
    library.booleanSource.read text frame position first last =
      booleanInitializerAfter text frame position first last := by
  have raw : RawHelperEquations library.names.shared.composed (domain := Predicate.OuterReadiness.domain) := by
    rw [← library.exact_domain]
    exact library.names.shared.inherited
  exact library.booleanSource.meaning raw text valid frame position first last
    (ApplicationPackageFrames.stateValid_domain state.typed state.valid) bounded (.inr span)

def scalarValue (library : ObjectLibraries) (text : Source) (position : Nat) (environment : ScalarExpression.Environment)
    (first last : Nat) (elaborating : Bool) : ScalarExpression.Result :=
  library.scalar.readExpression text position environment first last true {} [] elaborating .allElements

theorem scalar_value (library : ObjectLibraries) {text position frame first last} (elaborating : Bool)
    (valid : ValidText text) (bounded : ValidCursor text position) (state : ReaderFrame text frame)
    (span : ValidName text first last) :
    library.scalarValue text position frame.scalarNames first last elaborating =
      ScalarExpression.read text position frame.scalarNames first last (elaborating := elaborating) := by
  have reading := ScalarExpression.SourceBridge.interpreted_readExpression_table library.scalar library.scalarSource
    text valid position frame.scalarNames first last true {} [] elaborating .allElements bounded
    state.native.base.2.2.2.2.2.1 (.inr span)
    (by simp [ArrayBindings.ValidTable, ArrayBindings.ValidTypes, ArrayBindings.maxBindings, ArrayBindings.maxTypes])
    (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])
  exact reading.trans (ScalarExpression.Native.table_read_empty text _ _ _ _ true [] elaborating .allElements)

theorem constraint (library : ObjectLibraries) {text frame position} (valid : ValidText text)
    (bounded : ValidCursor text position) (state : ReaderFrame text frame) (base : Integer.Interval)
    (typed : base.Bounded) :
    library.names.shared.composed.function .scalarConstraint text position frame.scalarNames base {} =
      scalarConstraintAt text position frame.scalarNames base :=
  interpreted_scalarConstraint _ library.names.shared.inherited text valid position frame.scalarNames bounded
    state.native.base.2.2.2.2.2.1 base typed {}
    (by simp [ArrayBindings.ValidTable, ArrayBindings.ValidTypes, ArrayBindings.maxBindings, ArrayBindings.maxTypes])

def intervalInputs (value bounds : Integer.Interval) : ApplicationNative.Locals
  | .interval, "value" => value
  | .interval, "bounds" => bounds
  | ty, _ => ty.default

def intervalCalls (library : ObjectLibraries) : ApplicationNative.Calls ApplicationPackageCalls.ValidityNative.Function
  | _, .empty => library.names.shared.composed.function .scalarEmpty
  | ty, other => ApplicationPackageCalls.ValidityNative.imports ty other

def included (library : ObjectLibraries) (value bounds : Integer.Interval) : Bool :=
  ApplicationPackageCalls.ValidityNative.includedExpression.eval library.intervalCalls (intervalInputs value bounds)

theorem included_value (library : ObjectLibraries) (value bounds : Integer.Interval)
    (typedValue : value.Bounded) (typedBounds : bounds.Bounded) :
    library.included value bounds =
      ApplicationPackageCalls.includedCheck value bounds := by
  change (library.names.shared.composed.function .scalarEmpty value ||
    ((!library.names.shared.composed.function .scalarEmpty bounds && decide (value.lower ≥ bounds.lower)) &&
      decide (value.upper ≤ bounds.upper))) = _
  simp only [library.names.shared.inherited.scalarEmpty value typedValue,
    library.names.shared.inherited.scalarEmpty bounds typedBounds, ApplicationPackageCalls.includedCheck]

/-- The static Boolean reader is shared with the enclosing source library.
The actual masked scalar call supplies Elaborating explicitly and leaves
Allow_Sign and the array parameters at their native defaults. -/
def values (library : ObjectLibraries) (staticBoolean : BooleanElaboration.Native.Reader) : ObjectCalls :=
  {modelObjectCalls staticBoolean with
    typeAt := ApplicationPackageNames.Native.readType library.names.header.names
    constraint := fun text position names bounds => library.names.shared.composed.function .scalarConstraint text position names bounds {}
    scalar := fun text position names first last => library.scalarValue text position names first last true
    empty := library.names.shared.composed.function .scalarEmpty
    included := library.included
    appendScalar := library.names.shared.composed.function .scalarAppend
    booleanInitializer := library.booleanSource.read
    singleton := library.scalar.arrays.singleton}

def object (library : ObjectLibraries) (staticBoolean : BooleanElaboration.Native.Reader) : ObjectNative.Calls where
  base := library.names.object (library.values staticBoolean)
  scalar := library.scalarValue

theorem object_raw (library : ObjectLibraries) (staticBoolean : BooleanElaboration.Native.Reader) :
    (library.object staticBoolean).raw = library.names.object (library.values staticBoolean) := rfl

end ObjectLibraries
end Silver.ApplicationPackageDeclarations
