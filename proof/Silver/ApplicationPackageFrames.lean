module

public import Silver.ApplicationPackageNames
public import Silver.ComposeContracts
public import Silver.PredicateScalarHeaderReady

@[expose] public section

/-! Executable package-frame operations. The state predicate retains the
native mutable/nonempty declaration checks as well as source-unit context.
Machine representation bounds remain separate from the executable test.
The actual-source interpretation is established by the companion source chain. -/
namespace Silver.ApplicationPackageFrames
open Compose ApplicationPackageNames

def nameStateValid (text : Source) (first after : Nat) : Bool :=
  decide ((first = 0 ∧ after = 0) ∨
    (0 < first ∧ first < after ∧ after ≤ text.length + 1))

def scalarNamesValid (text : Source) (names : ScalarExpression.Environment) : Bool :=
  names.all fun item => decide (0 < item.first) &&
    nameStateValid text item.first item.after &&
    nameStateValid text item.qualifierFirst item.qualifierAfter

def booleanNamesValid (text : Source) (names : BooleanBindings.Environment) : Bool :=
  names.all fun item => decide (0 < item.first) &&
    nameStateValid text item.first item.after &&
    nameStateValid text item.qualifierFirst item.qualifierAfter

def subtypesValid (text : Source) (names : IntegerSubtypes.Environment) : Bool :=
  names.items.all fun item => decide (0 < item.first) &&
    nameStateValid text item.first item.after &&
    nameStateValid text item.qualifierFirst item.qualifierAfter && !item.bounds.isEmpty

def stringNamesValid (text : Source) (names : BindingEnvironment) : Bool :=
  (List.range names.length).all fun index =>
    let item := names.getD index {}
    decide (0 < item.first) && nameStateValid text item.first item.after &&
      decide (item.valueFirst ≤ text.length + 1) &&
      fixedBoundsValid item.staticLength item.dynamic item.isCharacter
        item.firstIndex item.lastIndex (index + 1)

def mutableBoundsValid (names : ScalarExpression.Environment) : Bool :=
  names.all fun item => if item.mutable then
    !item.bounds.isEmpty && decide (item.declaredBounds.lower ≤ item.bounds.lower) &&
      decide (item.bounds.upper ≤ item.declaredBounds.upper)
    else true

def declarationValuesValid (names : ScalarExpression.Environment) (count : Nat) : Bool :=
  decide (count ≤ names.length) && (names.take count).all (fun item => !item.bounds.isEmpty)

def stateValid (text : Source) (state : ParserState) : Bool :=
  decide (state.position ≤ text.length + 1) &&
    decide (state.contextFirst ≤ text.length + 1) &&
    nameStateValid text state.packageFirst state.packageAfter &&
    decide (FunctionBindings.ValidMetadata text state.functions) &&
    decide (ProcedureBindings.ValidMetadata text state.procedures) &&
    decide (state.firstParameter ≤ state.functions.parameters.length + 1) &&
    decide (state.firstProcedureParameter ≤ state.procedures.parameters.length + 1) &&
    stringNamesValid text state.names && scalarNamesValid text state.scalarNames &&
    decide (ArrayBindings.ValidNativeEnvironment text state.arrayNames) &&
    subtypesValid text state.subtypeNames && booleanNamesValid text state.booleanNames &&
    mutableBoundsValid state.scalarNames &&
    declarationValuesValid state.scalarNames state.scalarNames.length &&
    nameStateValid text state.dynamicFirst state.dynamicAfter &&
    decide (state.target ≤ state.names.length)

theorem declaration_ready {names : ScalarExpression.Environment}
    (mutable : mutableBoundsValid names = true)
    (values : declarationValuesValid names names.length = true) :
    Predicate.ScalarMetadata.HeaderReady names := by
  simp only [mutableBoundsValid, List.all_eq_true] at mutable
  simp only [declarationValuesValid, Nat.le_refl, decide_true, Bool.true_and,
    List.take_length, List.all_eq_true, Bool.not_eq_true'] at values
  intro item member
  refine ⟨values item member, ?_⟩
  intro writable
  have checked := mutable item member
  simp only [writable, ↓reduceIte, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at checked
  exact checked.2

theorem stateValid_ready {text : Source} {state : ParserState}
    (valid : stateValid text state = true) : Predicate.ScalarMetadata.HeaderReady state.scalarNames := by
  simp only [stateValid, Bool.and_eq_true] at valid
  exact declaration_ready valid.1.1.1.2 valid.1.1.2

/-- Remove only a shadowed outer declaration. A duplicate local rejects.
The defining byte spans of every retained binding are unchanged. -/
def hideEntries {α : Type} (selected : α → Bool) (outer : α → Bool) : List α → Option (List α)
  | [] => some []
  | item :: rest =>
      if selected item then
        if outer item then hideEntries selected outer rest else none
      else (hideEntries selected outer rest).map (item :: ·)

theorem hideEntries_sublist {α : Type} {selected outer : α → Bool} {before after : List α}
    (checked : hideEntries selected outer before = some after) : after.Sublist before := by
  induction before generalizing after with
  | nil =>
      cases Option.some.inj checked
      exact List.Sublist.refl _
  | cons item rest ih =>
      simp only [hideEntries] at checked
      split at checked
      · split at checked
        · exact (ih checked).cons _
        · contradiction
      · obtain ⟨kept, next, rfl⟩ := Option.map_eq_some_iff.mp checked
        exact (ih next).cons_cons _

def scalarMatches (text : Source) (name : PackageBindings.NameSpan)
    (item : ScalarExpression.Binding) : Bool :=
  decide (item.qualifierFirst = 0) && Named.equalName text name.first name.after item.first item.after

def booleanMatches (text : Source) (name : PackageBindings.NameSpan)
    (item : BooleanBindings.Binding) : Bool :=
  decide (item.qualifierFirst = 0) && Named.equalName text name.first name.after item.first item.after

def subtypeMatches (text : Source) (name : PackageBindings.NameSpan)
    (item : IntegerSubtypes.Binding) : Bool :=
  decide (item.qualifierFirst = 0) && Named.equalName text name.first name.after item.first item.after

def hideOuter (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) : ParserState :=
  if Named.forbiddenName text name.first name.after ||
      PackageBindings.sameName (metadataText text) name ⟨info.nameFirst, info.nameAfter⟩ then invalidState
  else
    let result := do
      let scalars ← hideEntries (scalarMatches text name)
        (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.scalarNames
      let booleans ← hideEntries (booleanMatches text name)
        (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.booleanNames
      let subtypes ← hideEntries (subtypeMatches text name)
        (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.subtypeNames.items
      pure {frame with
        scalarNames := scalars, booleanNames := booleans,
        subtypeNames := {frame.subtypeNames with items := subtypes},
        «hiding» := Compose.hideName text frame.hiding name.first name.after}
    match result with
    | none => invalidState
    | some value => if stateValid text value then value else invalidState

namespace Native

theorem hideOuter_frame {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan}
    (accepted : (hideOuter text frame info name).position ≠ 0) :
    (hideOuter text frame info name).position = frame.position ∧
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
            exact ⟨rfl, hideEntries_sublist scalars, hideEntries_sublist booleans, hideEntries_sublist subtypes⟩
          · simp only [invalidState] at accepted
            contradiction

theorem hideOuter_rows {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan}
    (accepted : (hideOuter text frame info name).position ≠ 0) :
    (hideOuter text frame info name).scalarNames.Sublist frame.scalarNames ∧
    (hideOuter text frame info name).booleanNames.Sublist frame.booleanNames ∧
    (hideOuter text frame info name).subtypeNames.items.Sublist frame.subtypeNames.items :=
  (hideOuter_frame accepted).2

end Native

def importedFrameRaw (exports : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) : ParserState :=
  {exports with
    position, contextFirst := (info.units .mainBody).first,
    packageFirst := info.nameFirst, packageAfter := info.nameAfter,
    pure := false, «hiding» := {},
    scalarNames := exports.scalarNames.map (fun item =>
      {item with qualifierFirst := info.nameFirst, qualifierAfter := info.nameAfter}),
    booleanNames := exports.booleanNames.map (fun item =>
      {item with qualifierFirst := info.nameFirst, qualifierAfter := info.nameAfter}),
    subtypeNames := {items := exports.subtypeNames.items.map (fun item =>
      {item with qualifierFirst := info.nameFirst, qualifierAfter := info.nameAfter})}}

def importedFrame (text : Source) (exports : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) : ParserState :=
  let result := importedFrameRaw exports info position
  if stateValid text result then result else invalidState

theorem importedFrame_scalar_spans (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    ((importedFrameRaw exports info position).scalarNames.map (fun item => (item.first, item.after))) =
      exports.scalarNames.map (fun item => (item.first, item.after)) := by
  simp only [importedFrameRaw, List.map_map, Function.comp_def]

theorem importedFrame_scalar_ranges (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    ((importedFrameRaw exports info position).scalarNames.map (fun item => item.bounds)) =
      exports.scalarNames.map (fun item => item.bounds) := by
  simp only [importedFrameRaw, List.map_map, Function.comp_def]

end Silver.ApplicationPackageFrames
