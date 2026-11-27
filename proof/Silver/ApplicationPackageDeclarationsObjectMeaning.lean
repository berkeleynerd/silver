module

public import Silver.ApplicationPackageDeclarationsValueImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations.ObjectLibraries
open Compose Compose.Expressions ApplicationPackageNames

private abbrev imported (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader) :=
  library.names.object (library.values reader)

private theorem finish (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (result : ObjectResult)
    (bounded : ValidCursor text result.initAfter) :
    finishObject (library.imported reader) text original result = finishObject (modelObjectCalls reader) text original result := by
  have token : (library.imported reader).take text result.initAfter (.symbol ";") =
      (modelObjectCalls reader).take text result.initAfter (.symbol ";") :=
    interpreted_take _ library.names.shared.inherited text valid _ _ bounded (by unfold ValidToken; decide)
  simp only [finishObject, token]

private theorem boolean_finish (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (first last constant after : Nat)
    (localObject : Bool) (result : ObjectResult) (bounded : ValidCursor text after) :
    objectBooleanFinish (library.imported reader) text original first last constant after localObject result =
      objectBooleanFinish (modelObjectCalls reader) text original first last constant after localObject result := by
  have bit : Integer.InRange (if result.booleanValue then 1 else 0) := by cases result.booleanValue <;> decide
  have singleton : (library.imported reader).singleton (if result.booleanValue then 1 else 0) =
      (modelObjectCalls reader).singleton (if result.booleanValue then 1 else 0) :=
    library.scalarSource.primitives.arrayPrimitives.singleton _ bit
  simp only [objectBooleanFinish, singleton]
  exact library.finish reader valid original _ bounded

private theorem boolean_branch (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (first last constant : Nat)
    (localObject : Bool) (result : ObjectResult) (state : ReaderFrame text result.frame)
    (bounded : ValidCursor text result.initFirst) (span : ValidName text first last) :
    objectBoolean (library.imported reader) text original first last constant localObject result =
      objectBoolean (modelObjectCalls reader) text original first last constant localObject result := by
  let after := booleanInitializerAfter text result.frame result.initFirst first last
  have actual : (library.imported reader).booleanInitializer text result.frame result.initFirst first last = after :=
    library.boolean valid state bounded span
  have limit : ValidCursor text after :=
    Predicate.Native.condition_bound text (booleanInitializerContext result.frame first last) result.initFirst
      (booleanInitializerFacts result.frame) valid state.native.base.2.1 bounded
  simp only [objectBoolean, actual]
  change (if decide (after = 0) || decide (result.frame.booleanNames.length = BooleanBindings.maxBindings) then _ else _) =
    (if decide (after = 0) || decide (result.frame.booleanNames.length = BooleanBindings.maxBindings) then _ else _)
  split
  · rfl
  · cases localObject with
    | true => exact library.boolean_finish reader valid original first last constant after true result limit
    | false =>
      change (if decide ((reader text result.frame result.initFirst).after ≠ after) then _ else _) =
        (if decide ((reader text result.frame result.initFirst).after ≠ after) then _ else _)
      split
      · rfl
      · exact library.boolean_finish reader valid original first last constant after false _ limit

private theorem scalar_branch (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (first last constant : Nat)
    (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult) (state : ReaderFrame text result.frame)
    (bounded : ValidCursor text result.initFirst) (span : ValidName text first last) (typed : range.bounds.Bounded) :
    objectScalar (library.imported reader) text original first last constant localObject result range =
      objectScalar (modelObjectCalls reader) text original first last constant localObject result range := by
  let value := ScalarExpression.read text result.initFirst result.frame.scalarNames first last (elaborating := true)
  have reading : (library.imported reader).scalar text result.initFirst result.frame.scalarNames first last = value :=
    library.scalar_value true valid bounded state span
  have typedValue : value.bounds.Bounded := (ScalarExpression.Native.read_type valid bounded).2.1
  have empty : (library.imported reader).empty value.bounds = value.bounds.isEmpty :=
    library.names.shared.inherited.scalarEmpty _ typedValue
  have included : (library.imported reader).included value.bounds range.bounds =
      (modelObjectCalls reader).included value.bounds range.bounds := library.included_value _ _ typedValue typed
  simp only [objectScalar, reading, empty, included]
  let rejected := (((decide (value.after = 0) || value.bounds.isEmpty) || !(modelObjectCalls reader).included value.bounds range.bounds) ||
    (!localObject && decide (value.bounds.lower ≠ value.bounds.upper))) || decide (result.frame.scalarNames.length = ScalarExpression.maxBindings)
  change (if rejected then invalidObject else _) = (if rejected then invalidObject else _)
  by_cases bad : rejected = true
  · rw [ite_eq_left bad, ite_eq_left bad]
  · rw [ite_eq_right bad, ite_eq_right bad]
    have succeeded : value.after ≠ 0 := fun zero => bad (by simp [rejected, zero])
    have spare : result.frame.scalarNames.length < ScalarExpression.maxBindings := by
      have capacity := state.native.base.2.2.2.2.2.1.1
      have neq : result.frame.scalarNames.length ≠ ScalarExpression.maxBindings := fun full => bad (by simp [rejected, full])
      omega
    have append (item : ScalarExpression.Binding) : (library.imported reader).appendScalar result.frame.scalarNames item =
        (modelObjectCalls reader).appendScalar result.frame.scalarNames item :=
      library.names.shared.inherited.scalarAppend _ item spare
    rw [append]
    exact library.finish reader valid original _ (ScalarExpression.read_arrays_bounds bounded succeeded).2.1

private theorem initialized (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (first last constant : Nat)
    (localObject : Bool) (result : ObjectResult) (range : ScalarConstraintResult) (state : ReaderFrame text result.frame)
    (bounded : ValidCursor text range.after) (span : ValidName text first last) (typed : range.bounds.Bounded) :
    objectInitialized (library.imported reader) text original first last constant localObject result range =
      objectInitialized (modelObjectCalls reader) text original first last constant localObject result range := by
  let assignment := fixedAfter text range.after ":=" false
  let start := skipAt text assignment
  have taken : (library.imported reader).take text range.after (.symbol ":=") = assignment :=
    interpreted_take _ library.names.shared.inherited text valid _ _ bounded (by unfold ValidToken; decide)
  have destination := model_fixed_valid text range.after ":=" false bounded
  have skipped : (library.imported reader).skip text assignment = start :=
    interpreted_skip _ library.names.shared.inherited text valid _ destination
  have fromBound := model_skip_valid text assignment destination
  simp only [objectInitialized, taken, skipped]
  change (if decide (start = 0) then _ else _) = (if decide (start = 0) then _ else _)
  split
  · rfl
  · split
    · exact library.scalar_branch reader valid original first last constant localObject _ range state fromBound span typed
    · exact library.boolean_branch reader valid original first last constant localObject _ state fromBound span

attribute [local irreducible] objectInitialized

private theorem typed (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (original : ParserState) (info : PackageBindings.Metadata)
    (first last colon constant : Nat) (localObject : Bool) (result : ObjectResult)
    (input : ObjectNameDomain text first last colon constant result) :
    objectTyped (library.imported reader) text original info first last colon constant localObject result =
      objectTyped (modelObjectCalls reader) text original info first last colon constant localObject result := by
  unfold objectTyped
  by_cases zero : result.frame.position = 0
  · simp only [zero, decide_true, ↓reduceIte]
  · have state := input.frame zero
    let position := if decide (constant = 0) then colon else constant
    let mark := packageTypeAt text result.frame info position
    have bounded : ValidCursor text position := by dsimp [position]; split <;> first | exact input.colon | exact input.qualifier
    have read : (library.imported reader).typeAt text result.frame info position = mark :=
      (ApplicationPackageNames.Native.imported_readers library.names.shared library.names.header).typeAt
        text valid result.frame state.typed state.valid info position bounded
    dsimp only [position] at read
    simp only [zero, decide_false, Bool.false_eq_true, ↓reduceIte]
    rw [read]
    change (if decide (mark.after = 0) then _ else _) = (if decide (mark.after = 0) then _ else _)
    by_cases absent : mark.after = 0
    · simp only [absent, decide_true, ↓reduceIte]
    · have found := (package_type_domain text result.frame info position state bounded).resolve_left absent
      simp only [absent, decide_false, Bool.false_eq_true, ↓reduceIte]
      let seed := {result with constantObject := decide (constant ≠ 0), mark := mark}
      change (if decide (mark.kind = .integer) then _ else _) = (if decide (mark.kind = .integer) then _ else _)
      split
      · have actual : (library.imported reader).constraint text mark.after result.frame.scalarNames mark.bounds =
            scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds :=
          library.constraint valid found.cursor state mark.bounds found.bounded
        rw [actual]
        exact library.initialized reader valid original first last constant localObject seed
          (scalarConstraintAt text mark.after result.frame.scalarNames mark.bounds) state
          (scalarConstraintAt_position_valid text mark.after result.frame.scalarNames found.cursor) input.span
          (scalarConstraintAt_bounded_all text mark.after result.frame.scalarNames found.cursor found.bounded)
      · exact library.initialized reader valid original first last constant localObject seed
          ⟨mark.after, mark.bounds⟩ state found.cursor input.span found.bounded

/-- Complete typed execution of Package_Object_At, including both declaration
visibility modes, arbitrary prior storage, and its executable initializer. -/
theorem object_meaning (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (frame : ParserState) (state : ReaderFrame text frame)
    (info : PackageBindings.Metadata) (localObject : Bool) (prior : ApplicationNative.Locals) :
    ObjectNative.body.eval (library.object reader).get (ObjectNative.inputLocals prior text frame info localObject) =
      objectStep (modelObjectCalls reader) text frame info localObject := by
  rw [ObjectNative.denotation, library.object_raw]
  apply objectNameStep_imports library.names (library.values reader) reader text valid frame state info localObject
  intro first last colon constant seed domain
  exact library.typed reader valid frame info first last colon constant localObject seed domain

end Silver.ApplicationPackageDeclarations.ObjectLibraries
