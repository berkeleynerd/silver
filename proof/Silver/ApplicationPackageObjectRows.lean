module

public import Silver.ApplicationPackageDeclarationsModel
public import Silver.ApplicationPackageFrameHistory

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose ApplicationPackageDeclarations ApplicationPackageFrameLayout

def integerRows (frame : ParserState) : List Row :=
  frame.scalarNames.map fun row => ⟨row.first, row.after, row.qualifierFirst, row.qualifierAfter⟩

def flagRows (frame : ParserState) : List Row :=
  frame.booleanNames.map fun row => ⟨row.first, row.after, row.qualifierFirst, row.qualifierAfter⟩

theorem context_rows (scan : Predicate.ScanResult) :
    scalarRows (Predicate.contextOf scan) = integerRows scan.state ∧
      booleanRows (Predicate.contextOf scan) = flagRows scan.state := by
  constructor
  · simp [Predicate.contextOf, ScalarExpression.bodyEnvironment, ScalarExpression.bodyBinding,
      scalarRows, integerRows, List.map_map, Function.comp_def]
  · rfl

def reference (name : PackageBindings.NameSpan) : Row := ⟨name.first, name.after, 0, 0⟩

/-- Original spans and qualifiers of all retained rows, including the row
installed at the end of the native table for the declared scalar kind. -/
structure Appended (base : ParserState) (name : PackageBindings.NameSpan) (out : ObjectResult) : Prop where
  nameEq : out.name = name
  integers : integerRows out.frame = integerRows base ++
    (if out.mark.kind = .integer then [reference name] else [])
  flags : flagRows out.frame = flagRows base ++
    (if out.mark.kind = .boolean then [reference name] else [])

private def OnSuccess (base : ParserState) (name : PackageBindings.NameSpan) (out : ObjectResult) : Prop :=
  out.frame.position ≠ 0 → Appended base name out

private theorem rejected (base : ParserState) (name : PackageBindings.NameSpan) :
    OnSuccess base name invalidObject := fun present => False.elim (present rfl)

private theorem finish_rows {base original : ParserState} {name : PackageBindings.NameSpan}
    (calls : ObjectCalls) (text : Source) (out : ObjectResult) (rows : Appended base name out) :
    OnSuccess base name (finishObject calls text original out) := by
  dsimp only [finishObject]
  split
  · exact rejected _ _
  · exact fun _ => ⟨rows.nameEq, rows.integers, rows.flags⟩

private theorem scalar_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult) (constraint : ScalarConstraintResult)
    (name : seed.name = ⟨first,last⟩) (kind : seed.mark.kind = .integer) :
    OnSuccess seed.frame ⟨first,last⟩
      (objectScalar (modelObjectCalls reader) text original first last constantEnd localObject seed constraint) := by
  dsimp only [objectScalar]
  split
  · exact rejected _ _
  · apply finish_rows
    exact ⟨name, by simp [integerRows, modelObjectCalls, kind, reference], by simp [flagRows, kind]⟩

private theorem finish_flags (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd after : Nat) (localObject : Bool) (seed : ObjectResult)
    (name : seed.name = ⟨first,last⟩) (kind : seed.mark.kind = .boolean) :
    OnSuccess seed.frame ⟨first,last⟩
      (objectBooleanFinish calls text original first last constantEnd after localObject seed) := by
  unfold objectBooleanFinish
  apply finish_rows
  exact ⟨name, by simp [integerRows, kind], by simp [flagRows, kind, reference]⟩

private theorem flag_rows (calls : ObjectCalls) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult)
    (name : seed.name = ⟨first,last⟩) (kind : seed.mark.kind = .boolean) :
    OnSuccess seed.frame ⟨first,last⟩ (objectBoolean calls text original first last constantEnd localObject seed) := by
  dsimp only [objectBoolean]
  split
  · exact rejected _ _
  · split
    · split
      · exact rejected _ _
      · exact finish_flags calls text original first last constantEnd _ localObject _ name kind
    · exact finish_flags calls text original first last constantEnd _ localObject _ name kind

private theorem initialized_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (first last constantEnd : Nat) (localObject : Bool) (seed : ObjectResult) (constraint : ScalarConstraintResult)
    (name : seed.name = ⟨first,last⟩) :
    OnSuccess seed.frame ⟨first,last⟩
      (objectInitialized (modelObjectCalls reader) text original first last constantEnd localObject seed constraint) := by
  dsimp only [objectInitialized]
  split
  · exact rejected _ _
  · split
    · rename_i integer
      exact scalar_rows reader text original first last constantEnd localObject _ constraint name (of_decide_eq_true integer)
    · rename_i flag
      have isFlag : seed.mark.kind = .boolean := by
        cases k : seed.mark.kind with
        | boolean => rfl
        | integer => exact False.elim (flag (by simp [k]))
      exact flag_rows _ text original first last constantEnd localObject _ name isFlag

private theorem typed_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (original : ParserState)
    (info : PackageBindings.Metadata) (first last colonEnd constantEnd : Nat) (localObject : Bool) (seed : ObjectResult)
    (name : seed.name = ⟨first,last⟩) :
    OnSuccess seed.frame ⟨first,last⟩
      (objectTyped (modelObjectCalls reader) text original info first last colonEnd constantEnd localObject seed) := by
  dsimp only [objectTyped]
  split
  · exact rejected _ _
  · split <;> split
    all_goals first | exact rejected _ _ | (split <;> apply initialized_rows <;> exact name)

def objectName (text : Source) (frame : ParserState) : PackageBindings.NameSpan :=
  let first := skipAt text frame.position
  ⟨first, nameAfter text first⟩

/-- These are the rows in scope while checking the new object's initializer. -/
def initializerBase (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) (localObject : Bool) : ParserState :=
  if localObject then ApplicationPackageFrames.hideOuter text frame info name
  else {frame with «hiding» := hideName text frame.hiding name.first name.after}

theorem objectStep_rows (reader : BooleanElaboration.Native.Reader) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (localObject : Bool) :
    let out := objectStep (modelObjectCalls reader) text frame info localObject
    let name := objectName text frame
    out.frame.position ≠ 0 →
      PackageBindings.validName (ApplicationPackageNames.metadataText text) name = true ∧
        Appended (initializerBase text frame info name localObject) name out := by
  dsimp only [objectStep, objectNameStep]
  split
  · exact fun present => False.elim (present rfl)
  · rename_i checked
    have valid : PackageBindings.validName (ApplicationPackageNames.metadataText text) (objectName text frame) = true := by
      apply Bool.eq_true_of_ne_false
      intro rejectedName
      apply checked
      change ((!PackageBindings.validName (ApplicationPackageNames.metadataText text) (objectName text frame)) || _) = true
      simp [rejectedName]
    cases localObject with
    | true =>
      exact fun present => ⟨valid, typed_rows reader text frame info _ _ _ _ true _ rfl present⟩
    | false =>
      split
      · contradiction
      · split
        · exact fun present => ⟨valid, typed_rows reader text frame info _ _ _ _ false _ rfl present⟩
        · exact fun present => False.elim (present rfl)

end Silver.ApplicationPackageObjectRows
