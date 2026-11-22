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
  if frame.position ≤ original.position then invalidObject else {result with frame}

def objectStep (calls : ObjectCalls) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool := false) : ObjectResult :=
  let first := calls.skip text frame.position
  let last := calls.nameAfter text first
  let colonEnd := calls.take text last (.symbol ":")
  let constantEnd := calls.take text colonEnd (.word "constant")
  if !calls.validName text ⟨first,last⟩ || decide (colonEnd = 0) then invalidObject else
  let hidden := if localObject then calls.hideOuter text frame info ⟨first,last⟩
    else if calls.fresh text info ⟨first,last⟩ && calls.newName text frame first last false then
      {frame with «hiding» := calls.hide text frame.hiding first last}
    else invalidState
  if hidden.position = 0 then invalidObject else
  let mark := calls.typeAt text hidden info (if constantEnd = 0 then colonEnd else constantEnd)
  if mark.after = 0 then invalidObject else
  let constraint := if mark.kind = .integer then calls.constraint text mark.after hidden.scalarNames mark.bounds
    else ⟨mark.after,mark.bounds⟩
  let mark := {mark with bounds := constraint.bounds}
  let start := calls.skip text (calls.take text constraint.after (.symbol ":="))
  if start = 0 then invalidObject else
  let result : ObjectResult := {
    frame := hidden
    name := ⟨first,last⟩
    mark := mark
    initFirst := start
    constantObject := decide (constantEnd ≠ 0)
  }
  if mark.kind = .integer then
    let value := calls.scalar text start hidden.scalarNames first last
    if decide (value.after = 0) || calls.empty value.bounds || !calls.included value.bounds constraint.bounds ||
        (!localObject && decide (value.bounds.lower ≠ value.bounds.upper)) ||
        decide (hidden.scalarNames.length = ScalarExpression.maxBindings) then invalidObject else
    let item : ScalarExpression.Binding := ⟨first,last,value.bounds,
      decide (constantEnd ≠ 0) && value.isStatic,constraint.bounds,decide (constantEnd = 0),0,0⟩
    let updated := {hidden with scalarNames := calls.appendScalar hidden.scalarNames item}
    finishObject calls text frame {result with frame := updated, initAfter := value.after, initialBounds := value.bounds}
  else
    let after := calls.booleanInitializer text hidden start first last
    if after = 0 ∨ hidden.booleanNames.length = BooleanBindings.maxBindings then invalidObject else
    let flag := if localObject then (⟨after,false⟩ : BooleanElaboration.Native.Result)
      else calls.staticBoolean text hidden start
    if !localObject && decide (flag.after ≠ after) then invalidObject else
    let item : BooleanBindings.Binding := ⟨first,last,decide (constantEnd = 0),0,0,!localObject,flag.value⟩
    let updated := {hidden with booleanNames := hidden.booleanNames ++ [item]}
    finishObject calls text frame {result with
      frame := updated
      initAfter := after
      booleanValue := flag.value
      initialBounds := calls.singleton (if flag.value then 1 else 0)}

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
