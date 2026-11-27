module

public import Silver.ApplicationPackageDeclarationsObjectMeaning
public import Silver.ApplicationPackageUnitTotal

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.ObjectLibraries
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageBodies

set_option backward.dsimp.instances true

def unit (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) (other : UnitCalls) : UnitCalls :=
  {other with
    packageWord := ApplicationPackageNames.Native.readWord library.names.header.names
    skipAt := library.names.shared.composed.function .skip
    nameAfter := library.names.shared.composed.function .nameAfter
    takeToken := library.names.shared.composed.function .takeToken
    sparkPragmaAfter := ApplicationPackageNames.Native.readPragma library.names.header.names
    sameName := ApplicationPackageImports.sameName library.names.shared
    objectAt := fun text frame info localObject => ObjectNative.body.eval (library.object reader).get
      (ObjectNative.inputLocals prior text frame info localObject)}

def unitModel (reader : BooleanElaboration.Native.Reader) (other : UnitCalls) : UnitCalls :=
  {unitReaders reader other.completionAt with validState := other.validState}

private theorem word_bound (text : Source) (position : Nat) (word : String) :
    ValidCursor text (ApplicationPackageNames.packageWord text position word) := by
  unfold ValidCursor
  dsimp only [ApplicationPackageNames.packageWord]
  split
  · exact model_name_valid text _
  · exact Nat.zero_le _

private theorem pragma_bound (text : Source) (position : Nat) :
    ValidCursor text (ApplicationPackageNames.sparkPragmaAfter text position) :=
  fixedAfter_result_bound _ _ ";" false (by decide)

/-- Original Package_Body prefix on its declared unit-start domain. Metadata
need not be valid or complete: name comparison retains the native rejection. -/
theorem unit_start (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) (other : UnitCalls) {text : Source} (valid : ValidText text)
    (exports : ParserState) (info : PackageBindings.Metadata)
    (start : ValidCursor text (info.units .packageBody).first) :
    startUnit (library.unit reader prior other) text exports info =
      startUnit (unitModel reader other) text exports info := by
  let packageEnd := ApplicationPackageNames.packageWord text (info.units .packageBody).first "package"
  let bodyEnd := ApplicationPackageNames.packageWord text packageEnd "body"
  let first := Compose.skipAt text bodyEnd
  let last := Compose.nameAfter text first
  let isEnd := fixedAfter text last (spelling (.word "is")) (isWord (.word "is"))
  have readers := ApplicationPackageNames.Native.imported_readers library.names.shared library.names.header
  have packageEq := readers.word text valid (info.units .packageBody).first start "package" (by decide) (by decide)
  have bodyEq := readers.word text valid packageEnd (word_bound ..) "body" (by decide) (by decide)
  have skipEq := interpreted_skip _ library.names.shared.inherited text valid bodyEnd (word_bound ..)
  have firstBound : ValidCursor text first := model_skip_valid text bodyEnd (word_bound ..)
  have nameEq := interpreted_name _ library.names.shared.inherited text valid first firstBound
  have lastBound : ValidCursor text last := model_name_valid text first
  have tokenEq := interpreted_take _ library.names.shared.inherited text valid last (.word "is") lastBound
    (by unfold ValidToken; decide)
  have isBound : ValidCursor text isEnd := fixedAfter_result_bound _ _ "is" true (by decide)
  have pragmaEq := readers.pragmaAfter text valid isEnd isBound
  dsimp +instances only [startUnit, unit, unitModel, unitReaders]
  rw [packageEq, bodyEq, skipEq, nameEq, ApplicationPackageImports.sameName_meaning, tokenEq, pragmaEq]
  rfl

private theorem start_framed (calls : UnitCalls) {text : Source}
    (bounded : ∀ position, ValidCursor text (calls.sparkPragmaAfter text position))
    {exports : ParserState} (framed : ReaderFrame text exports)
    (info : PackageBindings.Metadata) {state : UnitState}
    (started : startUnit calls text exports info = .continued state) :
    ReaderFrame text state.globals := by
  dsimp only [startUnit] at started
  split at started
  · contradiction
  · split at started
    · contradiction
    · cases started
      exact framed.at_position (bounded _)

/-- Successful prefix execution supplies the exact next reader domain. -/
theorem unit_start_framed (reader : BooleanElaboration.Native.Reader) (other : UnitCalls)
    {text : Source} {exports : ParserState} (framed : ReaderFrame text exports)
    (info : PackageBindings.Metadata) {state : UnitState}
    (started : startUnit (unitModel reader other) text exports info = .continued state) :
    ReaderFrame text state.globals :=
  start_framed _ (fun _ => pragma_bound ..) framed info started

/-- Every non-Completion unit step interprets its actual lexical/Object calls.
The Completion callback is retained identically for its separate full proof. -/
theorem unit_step (library : ObjectLibraries) (reader : BooleanElaboration.Native.Reader)
    (prior : ApplicationNative.Locals) (other : UnitCalls) {text : Source} (valid : ValidText text)
    (state : UnitState) (framed : ReaderFrame text state.globals) :
    unitStep (library.unit reader prior other) text state =
      unitStep (unitModel reader other) text state := by
  have token (word : String) (legal : ValidToken (.word word)) :=
    interpreted_take _ library.names.shared.inherited text valid state.globals.position
      (.word word) framed.cursor legal
  cases phase : state.phase with
  | objects =>
    dsimp +instances only [unitStep, unit, unitModel, unitReaders]
    simp only [phase]
    rw [token "function" (by unfold ValidToken; decide), token "procedure" (by unfold ValidToken; decide),
      token "end" (by unfold ValidToken; decide), library.object_meaning reader valid state.globals framed state.info false prior]
    rfl
  | routines =>
    dsimp +instances only [unitStep, unit, unitModel, unitReaders]
    simp only [phase]
  | footer =>
    let ended := fixedAfter text state.globals.position (spelling (.word "end")) (isWord (.word "end"))
    let first := Compose.skipAt text ended
    let last := Compose.nameAfter text first
    let following := fixedAfter text last (spelling (.symbol ";")) (isWord (.symbol ";"))
    have endBound : ValidCursor text ended := fixedAfter_result_bound _ _ "end" true (by decide)
    have skipEq := interpreted_skip _ library.names.shared.inherited text valid ended endBound
    have firstBound : ValidCursor text first := model_skip_valid text ended endBound
    have nameEq := interpreted_name _ library.names.shared.inherited text valid first firstBound
    have lastBound : ValidCursor text last := model_name_valid text first
    have tokenEq := interpreted_take _ library.names.shared.inherited text valid last (.symbol ";") lastBound
      (by unfold ValidToken; decide)
    have finalBound : ValidCursor text following := fixedAfter_result_bound _ _ ";" false (by decide)
    have finalEq := interpreted_skip _ library.names.shared.inherited text valid following finalBound
    dsimp +instances only [unitStep, unit, unitModel, unitReaders]
    simp only [phase]
    rw [token "end" (by unfold ValidToken; decide), skipEq, nameEq, tokenEq,
      ApplicationPackageImports.sameName_meaning, finalEq]
    rfl

end Silver.ApplicationPackageDeclarations.ObjectLibraries
