module

public import Silver.ApplicationPackageDeclarationsTypes
public import Silver.ApplicationPackageFrames
public import Silver.StaticBooleanModel

@[expose] public section

/-! Raw declaration-reader equations. Calls remain explicit so source
interpretation can identify every inherited helper on its own native domain.
The Boolean initializer is read by the admission helper before the independent
exact-value reader; matching endpoints do not assume disjoint name tables. -/
namespace Silver.ApplicationPackageDeclarations
open Compose
open ApplicationPackageNames

structure ObjectCalls where
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  take : Source → Nat → ShellToken → Nat
  validName : Source → PackageBindings.NameSpan → Bool
  hideOuter : Source → ParserState → PackageBindings.Metadata → PackageBindings.NameSpan → ParserState
  fresh : Source → PackageBindings.Metadata → PackageBindings.NameSpan → Bool
  newName : Source → ParserState → Nat → Nat → Bool → Bool
  hide : Source → HiddenMarks → Nat → Nat → HiddenMarks
  typeAt : Source → ParserState → PackageBindings.Metadata → Nat → PackageTypeResult
  constraint : Source → Nat → ScalarExpression.Environment → Integer.Interval → ScalarConstraintResult
  scalar : Source → Nat → ScalarExpression.Environment → Nat → Nat → ScalarExpression.Result
  empty : Integer.Interval → Bool
  included : Integer.Interval → Integer.Interval → Bool
  appendScalar : ScalarExpression.Environment → ScalarExpression.Binding → ScalarExpression.Environment
  booleanInitializer : Source → ParserState → Nat → Nat → Nat → Nat
  staticBoolean : BooleanElaboration.Native.Reader
  singleton : Int → Integer.Interval

def finishObject (calls : ObjectCalls) (text : Source) (original : ParserState)
    (result : ObjectResult) : ObjectResult :=
  let frame := {result.frame with position := calls.take text result.initAfter (.symbol ";")}
  if decide (frame.position ≤ original.position) then invalidObject else {result with frame}

/-- The common final statements retain the original frame for the strict
progress test, including every failure after a successful initializer. -/
def objectBooleanFinish (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd after : Nat) (localObject : Bool) (result : ObjectResult) : ObjectResult :=
  let result := {result with initAfter := after}
  let result := {result with initialBounds := calls.singleton (if result.booleanValue then 1 else 0)}
  let binding : BooleanBindings.Binding :=
    ⟨first,last,decide (constantEnd = 0),0,0,!localObject,result.booleanValue⟩
  let result := {result with frame := {result.frame with booleanNames := result.frame.booleanNames ++ [binding]}}
  finishObject calls text original result

def objectBoolean (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (result : ObjectResult) : ObjectResult :=
  let after := calls.booleanInitializer text result.frame result.initFirst first last
  if decide (after = 0) || decide (result.frame.booleanNames.length = BooleanBindings.maxBindings) then invalidObject else
  if !localObject then
    let flag := calls.staticBoolean text result.frame result.initFirst
    if decide (flag.after ≠ after) then invalidObject else
    objectBooleanFinish calls text original first last constantEnd after localObject {result with booleanValue := flag.value}
  else objectBooleanFinish calls text original first last constantEnd after localObject result

def objectScalar (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (result : ObjectResult)
    (constraint : ScalarConstraintResult) : ObjectResult :=
  let value := calls.scalar text result.initFirst result.frame.scalarNames first last
  if (((decide (value.after = 0) || calls.empty value.bounds) || !calls.included value.bounds constraint.bounds) ||
      (!localObject && decide (value.bounds.lower ≠ value.bounds.upper))) ||
      decide (result.frame.scalarNames.length = ScalarExpression.maxBindings) then invalidObject else
  let result := {result with initAfter := value.after}
  let result := {result with initialBounds := value.bounds}
  let binding : ScalarExpression.Binding := ⟨first,last,value.bounds,
    decide (constantEnd ≠ 0) && value.isStatic,constraint.bounds,decide (constantEnd = 0),0,0⟩
  let result := {result with frame := {result.frame with scalarNames := calls.appendScalar result.frame.scalarNames binding}}
  finishObject calls text original result

def objectInitialized (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (result : ObjectResult)
    (constraint : ScalarConstraintResult) : ObjectResult :=
  let result := {result with mark := {result.mark with bounds := constraint.bounds}}
  let result := {result with initFirst := calls.skip text (calls.take text constraint.after (.symbol ":="))}
  if decide (result.initFirst = 0) then invalidObject else
  if decide (result.mark.kind = .integer) then
    objectScalar calls text original first last constantEnd localObject result constraint
  else objectBoolean calls text original first last constantEnd localObject result

def objectTyped (calls : ObjectCalls) (text : Source) (original : ParserState)
    (info : PackageBindings.Metadata) (first last colonEnd constantEnd : Nat)
    (localObject : Bool) (result : ObjectResult) : ObjectResult :=
  if decide (result.frame.position = 0) then invalidObject else
  let result := {result with constantObject := decide (constantEnd ≠ 0)}
  let result := {result with mark := (calls.typeAt text result.frame info
    (if decide (constantEnd = 0) then colonEnd else constantEnd))}
  if decide (result.mark.after = 0) then invalidObject else
  let constraint : ScalarConstraintResult := ⟨result.mark.after,result.mark.bounds⟩
  if decide (result.mark.kind = .integer) then
    objectInitialized calls text original first last constantEnd localObject result
      (calls.constraint text result.mark.after result.frame.scalarNames result.mark.bounds)
  else objectInitialized calls text original first last constantEnd localObject result constraint

/-- Complete raw Object execution in native statement order. Small continuations
keep source evaluation and callback values shared without adding a precondition. -/
abbrev ObjectContinuation := Source → ParserState → PackageBindings.Metadata →
  Nat → Nat → Nat → Nat → Bool → ObjectResult → ObjectResult

def objectNameStep (calls : ObjectCalls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) (next : ObjectContinuation) : ObjectResult :=
  let first := calls.skip text frame.position
  let last := calls.nameAfter text first
  let colonEnd := calls.take text last (.symbol ":")
  let constantEnd := calls.take text colonEnd (.word "constant")
  if !calls.validName text ⟨first,last⟩ || decide (colonEnd = 0) then invalidObject else
  let result := {invalidObject with name := ⟨first,last⟩}
  if localObject then
    next text frame info first last colonEnd constantEnd localObject
      {result with frame := calls.hideOuter text frame info result.name}
  else if calls.fresh text info result.name && calls.newName text frame first last false then
    next text frame info first last colonEnd constantEnd localObject
      {result with frame := {frame with «hiding» := calls.hide text frame.hiding first last}}
  else invalidObject

/-- The source prefix and typed suffix compose without unfolding the suffix at
all of the prefix's callback and local-state substitutions. -/
def objectStep (calls : ObjectCalls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool := false) : ObjectResult :=
  objectNameStep calls text frame info localObject (objectTyped calls)

def modelObjectCalls (staticBoolean : BooleanElaboration.Native.Reader) : ObjectCalls where
  skip := skipAt
  nameAfter := Compose.nameAfter
  take := tokenAfter
  validName text name := PackageBindings.validName (metadataText text) name
  hideOuter := ApplicationPackageFrames.hideOuter
  fresh := packageNameFresh
  newName := newNameAllowed
  hide := hideName
  typeAt := packageTypeAt
  constraint text position names bounds := scalarConstraintAt text position names bounds
  scalar text position names first last := ScalarExpression.read text position names first last (elaborating := true)
  empty := Integer.Interval.isEmpty
  included value bounds := value.isEmpty ||
    (!bounds.isEmpty && decide (value.lower ≥ bounds.lower) && decide (value.upper ≤ bounds.upper))
  appendScalar names value := names ++ [value]
  booleanInitializer := booleanInitializerAfter
  staticBoolean := staticBoolean
  singleton := Integer.Interval.singleton

def appendFormal (frame : ParserState) (name : PackageBindings.NameSpan)
    (mark : PackageTypeResult) (mode : ProcedureBindings.Mode) : ParserState :=
  if mark.kind = .integer ∧ frame.scalarNames.length < ScalarExpression.maxBindings then
    let item : ScalarExpression.Binding := ⟨name.first,name.after,mark.bounds,false,mark.bounds,decide (mode ≠ .input),0,0⟩
    {frame with scalarNames := frame.scalarNames ++ [item]}
  else if mark.kind = .boolean ∧ frame.booleanNames.length < BooleanBindings.maxBindings then
    let item : BooleanBindings.Binding := ⟨name.first,name.after,decide (mode ≠ .input),0,0,false,false⟩
    {frame with booleanNames := frame.booleanNames ++ [item]}
  else {frame with position := 0}

/-- Every metadata component used by the surrounding signature remains exact;
no validity, nonempty interval or source-bound premise is imposed here. -/
theorem appendFormal_retains_frames (frame : ParserState) (name : PackageBindings.NameSpan)
    (mark : PackageTypeResult) (mode : ProcedureBindings.Mode) :
    let result := appendFormal frame name mark mode
    result.contextFirst = frame.contextFirst ∧ result.packageFirst = frame.packageFirst ∧
    result.packageAfter = frame.packageAfter ∧ result.functions = frame.functions ∧
    result.procedures = frame.procedures ∧ result.arrayNames = frame.arrayNames ∧
    result.subtypeNames = frame.subtypeNames ∧ result.names = frame.names ∧ result.hiding = frame.hiding := by
  unfold appendFormal
  split <;> (try split) <;> exact ⟨rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl,rfl⟩

end Silver.ApplicationPackageDeclarations
