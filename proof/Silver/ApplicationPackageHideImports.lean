module

public import Silver.ApplicationPackageFrameImports
public import Silver.ApplicationPackagePrimitiveImports
public import Silver.ApplicationPackageHideModel
public import Silver.FunctionVisibilitySource

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

/-- Hide_Name's existing typed fields use only name spelling; unrelated visibility
helpers are absent from those trees. -/
def visibilityCalls (imports : ApplicationPackageImports.Imports) : FunctionVisibilityNative.Calls :=
  {FunctionVisibilityNative.modelCalls with
    nameIs := imports.lexical.base.identifier.name,
    equalName := imports.lexical.base.identifier.equal}

def importedHideName (imports : ApplicationPackageImports.Imports) (text : Source)
    (flags : HiddenMarks) (first after : Nat) : HiddenMarks :=
  FunctionVisibilityNative.evalMarks (visibilityCalls imports) {text,flags,first,after}
    FunctionVisibilityNative.hideNameField

theorem importedHideName_meaning (imports : ApplicationPackageImports.Imports)
    (text : Source) (valid : Compose.Expressions.ValidText text) (flags : HiddenMarks)
    (first after : Nat) (name : Compose.Expressions.ValidName text first after) :
    importedHideName imports text flags first after = Compose.hideName text flags first after := by
  rw [← FunctionVisibilityNative.hideName_model]
  have fields (mark : FunctionVisibilityNative.Mark) :
      (FunctionVisibilityNative.hideNameField mark).eval (visibilityCalls imports)
          {text,flags,first,after} =
      (FunctionVisibilityNative.hideNameField mark).eval FunctionVisibilityNative.modelCalls
          {text,flags,first,after} := by
    have word : 0 < mark.word.toList.length ∧ mark.word.toList.length ≤ maxSourceLength := by
      cases mark <;> decide
    dsimp only [FunctionVisibilityNative.hideNameField, FunctionVisibilityNative.Expr.eval,
      visibilityCalls]
    have spelling := ApplicationPackageImports.nameIs_meaning imports text valid first after name mark.word
      word.1 word.2
    dsimp only [ApplicationPackageImports.nameIs] at spelling
    rw [spelling]
    rfl
  unfold importedHideName FunctionVisibilityNative.evalMarks
  rw [fields, fields, fields, fields, fields]

def frameCalls (imports : ApplicationPackageImports.Imports) (validity : ValidityNative.Imports) : Calls Function
  | _, .validState => fun text state => ValidityNative.validStateBody.eval
      (ValidityNative.importedCalls validity) (ValidityNative.tableLocals text .state "state" state)
  | _, .forbiddenName => ApplicationPackageImports.forbidden imports
  | _, .equalName => ApplicationPackageImports.equal imports
  | _, .sameName => ApplicationPackageImports.sameName imports
  | _, .outerDeclaration => fun info name =>
      ApplicationPackageNames.Native.outerDeclarationBody.eval
        ApplicationPackageNames.Native.modelCalls.get
        ({info,name} : ApplicationPackageNames.Native.Inputs).locals
  | _, .hideName => importedHideName imports

theorem frameCalls_valid (imports : ApplicationPackageImports.Imports) (validity : ValidityNative.Imports)
    (text : Source) (valid : Compose.Expressions.ValidText text) (state : ParserState)
    (typed : ValidityNative.ImportedTypes state) :
    frameCalls imports validity _ .validState text state = stateValid text state :=
  ValidityNative.imported_validState validity
    (ValidityNative.tableLocals text .state "state" state) valid typed

theorem frameCalls_outer (imports : ApplicationPackageImports.Imports) (validity : ValidityNative.Imports)
    (info : PackageBindings.Metadata) (name : PackageBindings.NameSpan) :
    frameCalls imports validity _ .outerDeclaration info name =
      ApplicationPackageNames.outerDeclaration info name :=
  ApplicationPackageNames.Native.outer_denotation ApplicationPackageNames.Native.modelCalls info name

/-- Only actual list members are inspected, preserving the inherited lexical
preconditions without extending them to arbitrary inactive rows. -/
theorem hideEntries_congr_on {α : Type} (items : List α)
    (left right outer otherOuter : α → Bool)
    (selected : ∀ item ∈ items, left item = right item)
    (classified : ∀ item ∈ items, outer item = otherOuter item) :
    hideEntries left outer items = hideEntries right otherOuter items := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
    simp only [hideEntries]
    rw [selected item (by simp), classified item (by simp),
      ih (by intro value member; exact selected value (by simp [member]))
        (by intro value member; exact classified value (by simp [member]))]


theorem stateValid_spans {text : Source} {state : ParserState}
    (valid : stateValid text state = true) :
    (∀ row ∈ state.scalarNames, Compose.Expressions.ValidName text row.first row.after) ∧
    (∀ row ∈ state.booleanNames, Compose.Expressions.ValidName text row.first row.after) ∧
    (∀ row ∈ state.subtypeNames.items, Compose.Expressions.ValidName text row.first row.after) := by
  simp only [stateValid, Bool.and_eq_true, and_assoc] at valid
  rcases valid with ⟨_, _, _, _, _, _, _, _, scalars, _, subtypes, booleans, _, _, _, _⟩
  constructor
  · intro row member
    have fields := List.all_eq_true.mp scalars row member
    simp only [Bool.and_eq_true, decide_eq_true_eq] at fields
    exact ⟨fields.1.1, nameStateValid_positive fields.1.1 fields.1.2⟩
  constructor
  · intro row member
    have fields := List.all_eq_true.mp booleans row member
    simp only [Bool.and_eq_true, decide_eq_true_eq] at fields
    exact ⟨fields.1.1, nameStateValid_positive fields.1.1 fields.1.2⟩
  · intro row member
    have fields := List.all_eq_true.mp subtypes row member
    simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc] at fields
    exact ⟨fields.1, nameStateValid_positive fields.1 fields.2.1⟩

theorem rowsResult_imports (imports : ApplicationPackageImports.Imports)
    (validity : ValidityNative.Imports) (text : Source) (valid : Compose.Expressions.ValidText text)
    (frame : ParserState) (typed : ValidityNative.ImportedTypes frame)
    (name : PackageBindings.NameSpan) (nameValid : Compose.Expressions.ValidName text name.first name.after)
    (scalars : ScalarExpression.Environment) (booleans : BooleanBindings.Environment)
    (subtypes : List IntegerSubtypes.Binding) :
    rowsResult (frameCalls imports validity) text frame name scalars booleans subtypes =
      rowsResult modelCalls text frame name scalars booleans subtypes := by
  unfold rowsResult
  dsimp only [frameCalls]
  rw [importedHideName_meaning imports text valid _ _ _ nameValid]
  let result : ParserState := { frame with
    scalarNames := scalars
    booleanNames := booleans
    subtypeNames := {frame.subtypeNames with items := subtypes}
    «hiding» := Compose.hideName text frame.hiding name.first name.after }
  have typedResult : ValidityNative.ImportedTypes result :=
    ⟨typed.functions, typed.procedures, typed.arrays⟩
  change (if frameCalls imports validity _ .validState text result then result else invalidState) =
    (if stateValid text result then result else invalidState)
  rw [frameCalls_valid imports validity text valid result typedResult]


theorem compactFrame_imports (imports : ApplicationPackageImports.Imports)
    (validity : ValidityNative.Imports) (text : Source) (valid : Compose.Expressions.ValidText text)
    (frame : ParserState) (frameValid : stateValid text frame = true)
    (typed : ValidityNative.ImportedTypes frame) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) (nameValid : Compose.Expressions.ValidName text name.first name.after) :
    compactFrame (frameCalls imports validity) text frame info name =
      compactFrame modelCalls text frame info name := by
  have spans := stateValid_spans frameValid
  have scalarSame : hideEntries (scalarSelection (frameCalls imports validity) text name)
      (fun row => frameCalls imports validity _ .outerDeclaration info ⟨row.first,row.after⟩) frame.scalarNames =
    hideEntries (scalarSelection modelCalls text name)
      (fun row => modelCalls _ .outerDeclaration info ⟨row.first,row.after⟩) frame.scalarNames := by
    apply hideEntries_congr_on
    · intro row member
      exact congrArg (fun result => decide (row.qualifierFirst = 0) && result)
        (ApplicationPackageImports.equal_meaning imports text valid name.first name.after
          row.first row.after nameValid (spans.1 row member))
    · intro row _
      exact frameCalls_outer imports validity info ⟨row.first,row.after⟩
  have booleanSame : hideEntries (booleanSelection (frameCalls imports validity) text name)
      (fun row => frameCalls imports validity _ .outerDeclaration info ⟨row.first,row.after⟩) frame.booleanNames =
    hideEntries (booleanSelection modelCalls text name)
      (fun row => modelCalls _ .outerDeclaration info ⟨row.first,row.after⟩) frame.booleanNames := by
    apply hideEntries_congr_on
    · intro row member
      exact congrArg (fun result => decide (row.qualifierFirst = 0) && result)
        (ApplicationPackageImports.equal_meaning imports text valid name.first name.after
          row.first row.after nameValid (spans.2.1 row member))
    · intro row _
      exact frameCalls_outer imports validity info ⟨row.first,row.after⟩
  have subtypeSame : hideEntries (subtypeSelection (frameCalls imports validity) text name)
      (fun row => frameCalls imports validity _ .outerDeclaration info ⟨row.first,row.after⟩) frame.subtypeNames.items =
    hideEntries (subtypeSelection modelCalls text name)
      (fun row => modelCalls _ .outerDeclaration info ⟨row.first,row.after⟩) frame.subtypeNames.items := by
    apply hideEntries_congr_on
    · intro row member
      exact congrArg (fun result => decide (row.qualifierFirst = 0) && result)
        (ApplicationPackageImports.equal_meaning imports text valid name.first name.after
          row.first row.after nameValid (spans.2.2 row member))
    · intro row _
      exact frameCalls_outer imports validity info ⟨row.first,row.after⟩
  have forbiddenSame : frameCalls imports validity _ .forbiddenName text name.first name.after =
      modelCalls _ .forbiddenName text name.first name.after :=
    ApplicationPackageImports.forbidden_meaning imports text valid name.first name.after nameValid
  have packageSame : frameCalls imports validity _ .sameName text name ⟨info.nameFirst,info.nameAfter⟩ =
      modelCalls _ .sameName text name ⟨info.nameFirst,info.nameAfter⟩ :=
    ApplicationPackageImports.sameName_meaning imports text name ⟨info.nameFirst,info.nameAfter⟩
  have resultSame : rowsResult (frameCalls imports validity) text frame name =
      rowsResult modelCalls text frame name := by
    funext scalars booleans subtypes
    exact rowsResult_imports imports validity text valid frame typed name nameValid scalars booleans subtypes
  simp only [compactFrame, compactRows_full, scalarSame, booleanSame, subtypeSame,
    forbiddenSame, packageSame, resultSame]

/-- Full-domain source interpretation of the complete shadow compaction helper.
All name domains follow from the native executable checks; inactive backing
rows and caller reachability are not premises. -/
theorem hideOuter_imports (imports : ApplicationPackageImports.Imports)
    (validity : ValidityNative.Imports) (locals : Locals)
    (valid : Compose.Expressions.ValidText (locals .source "text"))
    (frameValid : stateValid (locals .source "text") (locals .state "frame") = true)
    (typed : ValidityNative.ImportedTypes (locals .state "frame"))
    (nameValid : Compose.Expressions.ValidName (locals .source "text")
      (locals .nameSpan "name").first (locals .nameSpan "name").after) :
    hideOuterBody.eval (frameCalls imports validity) locals =
      hideOuter (locals .source "text") (locals .state "frame")
        (locals .metadata "info") (locals .nameSpan "name") := by
  rw [hideOuter_denotation, hideCommands_compact,
    compactFrame_imports imports validity _ valid _ frameValid typed _ _ nameValid,
    compactFrame_model]


theorem hideOuter_rows {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan}
    (accepted : (hideOuter text frame info name).position ≠ 0) :
    (hideOuter text frame info name).scalarNames.Sublist frame.scalarNames ∧
    (hideOuter text frame info name).booleanNames.Sublist frame.booleanNames ∧
    (hideOuter text frame info name).subtypeNames.items.Sublist frame.subtypeNames.items := by
  unfold hideOuter at accepted ⊢
  split at accepted
  · simp only [invalidState] at accepted
    contradiction
  · rename_i allowed
    simp only [allowed]
    cases scalars : hideEntries (scalarMatches text name)
      (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.scalarNames with
    | none => simp [scalars, invalidState] at accepted
    | some scalarRows =>
      cases booleans : hideEntries (booleanMatches text name)
        (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.booleanNames with
      | none => simp [scalars, booleans, invalidState] at accepted
      | some booleanRows =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first,item.after⟩) frame.subtypeNames.items with
        | none => simp [scalars, booleans, subtypes, invalidState] at accepted
        | some subtypeRows =>
          simp only [scalars, booleans, subtypes, Option.bind_some, pure, bind] at accepted ⊢
          split at accepted
          · rename_i checked
            simp only [ite_eq_left checked]
            exact ⟨hideEntries_sublist scalars, hideEntries_sublist booleans, hideEntries_sublist subtypes⟩
          · simp only [invalidState] at accepted
            contradiction

end Silver.ApplicationPackageFrames.Native
