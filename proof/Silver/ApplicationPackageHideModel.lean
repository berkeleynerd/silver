module

public import Silver.ApplicationPackageHideInterpretation

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def scalarSelection (calls : Calls Function) (text : Source) (name : PackageBindings.NameSpan)
    (row : ScalarExpression.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName text name.first name.after row.first row.after

def booleanSelection (calls : Calls Function) (text : Source) (name : PackageBindings.NameSpan)
    (row : BooleanBindings.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName text name.first name.after row.first row.after

def subtypeSelection (calls : Calls Function) (text : Source) (name : PackageBindings.NameSpan)
    (row : IntegerSubtypes.Binding) : Bool :=
  decide (row.qualifierFirst = 0) && calls _ .equalName text name.first name.after row.first row.after

theorem scalarSelected_selection (calls : Calls Function) (locals : Locals) :
    scalarSelected calls locals = scalarSelection calls (locals .source "text") (locals .nameSpan "name") := rfl

theorem booleanSelected_selection (calls : Calls Function) (locals : Locals) :
    booleanSelected calls locals = booleanSelection calls (locals .source "text") (locals .nameSpan "name") := rfl

theorem subtypeSelected_selection (calls : Calls Function) (locals : Locals) :
    subtypeSelected calls locals = subtypeSelection calls (locals .source "text") (locals .nameSpan "name") := rfl

theorem scalarOuter_equation (calls : Calls Function) (locals : Locals) :
    scalarOuter calls locals = fun row => calls _ .outerDeclaration (locals .metadata "info")
      ⟨row.first, row.after⟩ := rfl

theorem booleanOuter_equation (calls : Calls Function) (locals : Locals) :
    booleanOuter calls locals = fun row => calls _ .outerDeclaration (locals .metadata "info")
      ⟨row.first, row.after⟩ := rfl

theorem subtypeOuter_equation (calls : Calls Function) (locals : Locals) :
    subtypeOuter calls locals = fun row => calls _ .outerDeclaration (locals .metadata "info")
      ⟨row.first, row.after⟩ := rfl

def rowsResult (calls : Calls Function) (text : Source) (frame : ParserState)
    (name : PackageBindings.NameSpan) (scalars : ScalarExpression.Environment)
    (booleans : BooleanBindings.Environment) (subtypes : List IntegerSubtypes.Binding) : ParserState :=
  let value := {frame with
    scalarNames := scalars, booleanNames := booleans,
    subtypeNames := {frame.subtypeNames with items := subtypes},
    «hiding» := calls _ .hideName text frame.hiding name.first name.after}
  if calls _ .validState text value then value else invalidState

def compactFrame (calls : Calls Function) (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) : ParserState :=
  if calls _ .forbiddenName text name.first name.after ||
      calls _ .sameName text name ⟨info.nameFirst, info.nameAfter⟩ then invalidState
  else
    let scalars := (compactRows (scalarSelection calls text name)
      (fun row => calls _ .outerDeclaration info ⟨row.first, row.after⟩)
      0 frame.scalarNames frame.scalarNames).map (fun result => result.2.take result.1)
    let booleans := (compactRows (booleanSelection calls text name)
      (fun row => calls _ .outerDeclaration info ⟨row.first, row.after⟩)
      0 frame.booleanNames frame.booleanNames).map (fun result => result.2.take result.1)
    let subtypes := (compactRows (subtypeSelection calls text name)
      (fun row => calls _ .outerDeclaration info ⟨row.first, row.after⟩)
      0 frame.subtypeNames.items frame.subtypeNames.items).map (fun result => result.2.take result.1)
    scalars.elim invalidState (fun scalarRows => booleans.elim invalidState
      (fun booleanRows => subtypes.elim invalidState (rowsResult calls text frame name scalarRows booleanRows)))

theorem compactFrame_model (text : Source) (frame : ParserState)
    (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    compactFrame modelCalls text frame info name = hideOuter text frame info name := by
  unfold compactFrame
  rw [compactRows_full, compactRows_full, compactRows_full]
  rw [show scalarSelection modelCalls text name = scalarMatches text name from rfl,
    show booleanSelection modelCalls text name = booleanMatches text name from rfl,
    show subtypeSelection modelCalls text name = subtypeMatches text name from rfl]
  dsimp only [modelCalls]
  unfold hideOuter
  split
  · rfl
  · cases hideEntries (scalarMatches text name)
      (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first, row.after⟩) frame.scalarNames with
    | none => rfl
    | some scalarRows =>
      cases hideEntries (booleanMatches text name)
        (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first, row.after⟩) frame.booleanNames with
      | none => rfl
      | some booleanRows =>
        cases hideEntries (subtypeMatches text name)
          (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first, row.after⟩) frame.subtypeNames.items with
        | none => rfl
        | some subtypeRows => rfl

theorem hideCommands_compact (calls : Calls Function) (locals : Locals) :
    hideCommands calls (hideInitial locals) =
      compactFrame calls (locals .source "text") (locals .state "frame")
        (locals .metadata "info") (locals .nameSpan "name") := by
  simp only [hideCommands, hideRejected, hideInitial, scalarStage, booleanStage, subtypeStage,
    scalarSelected_selection, booleanSelected_selection, subtypeSelected_selection,
    scalarOuter_equation, booleanOuter_equation, subtypeOuter_equation,
    scalarFilterState, booleanFilterState, subtypeFilterState, finishHide, hideResult,
    trimScalars, trimBooleans, trimSubtypes, compactFrame,
    Option.elim_map]
  simp [Locals.set]
  split
  · rfl
  · cases compactRows (scalarSelection calls (locals .source "text") (locals .nameSpan "name"))
      (fun row => calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩)
      0 (locals .state "frame").scalarNames (locals .state "frame").scalarNames with
    | none => rfl
    | some scalarResult =>
      rcases scalarResult with ⟨scalarCount, scalarRows⟩
      cases compactRows (booleanSelection calls (locals .source "text") (locals .nameSpan "name"))
        (fun row => calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩)
        0 (locals .state "frame").booleanNames (locals .state "frame").booleanNames with
      | none => rfl
      | some booleanResult =>
        rcases booleanResult with ⟨booleanCount, booleanRows⟩
        cases compactRows (subtypeSelection calls (locals .source "text") (locals .nameSpan "name"))
          (fun row => calls _ .outerDeclaration (locals .metadata "info") ⟨row.first, row.after⟩)
          0 (locals .state "frame").subtypeNames.items (locals .state "frame").subtypeNames.items with
        | none => rfl
        | some subtypeResult =>
          rcases subtypeResult with ⟨subtypeCount, subtypeRows⟩
          rfl

theorem hideOuter_model (locals : Locals) :
    hideOuterBody.eval modelCalls locals =
      hideOuter (locals .source "text") (locals .state "frame")
        (locals .metadata "info") (locals .nameSpan "name") := by
  rw [hideOuter_denotation, hideCommands_compact, compactFrame_model]

end Silver.ApplicationPackageFrames.Native
