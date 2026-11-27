module

public import Silver.ApplicationPackageNameReaders
public import Silver.ApplicationPackageHideImports
public import Silver.ApplicationPackageDeclarationsModel
public import Silver.FunctionHeaderValidity

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

/-- The actual declaration-reader precondition combines Ada component types
with the executable Valid_State. The pooled text domain is shared by a read. -/
structure ReaderFrame (text : Source) (state : ParserState) : Prop where
  typed : StateType state
  valid : stateValid text state = true

theorem ReaderFrame.native {text state} (frame : ReaderFrame text state) :
    FunctionDeclarationNative.NativeValidState text state := by
  have original := stateValid_domain frame.typed frame.valid
  exact ⟨original.base, original.ready, original.bounds⟩

theorem ReaderFrame.imported_types {text state} (frame : ReaderFrame text state) (validText : ValidText text) :
    ValidityNative.ImportedTypes state := by
  have record := FunctionDeclarationNative.native_state_record text validText state frame.native
  exact ⟨record.functions, record.procedures,
    ⟨⟨record.arrayTypes, record.arrays.1, record.arrays.2.1⟩, record.arrays.2.2.1, record.arrays.2.2.2⟩⟩

theorem ReaderFrame.cursor {text state} (frame : ReaderFrame text state) : ValidCursor text state.position :=
  frame.native.base.1

theorem ReaderFrame.header {text state} (frame : ReaderFrame text state)
    (position : Nat) (bounded : ValidCursor text position) (pure : Bool) (flags : HiddenMarks) :
    ReaderFrame text {state with position, pure, «hiding» := flags} := by
  refine ⟨⟨frame.typed.context, frame.typed.capacity, frame.typed.namesCount, frame.typed.names,
    frame.typed.scalarCount, frame.typed.scalars, frame.typed.subtypeCount, frame.typed.subtypes,
    frame.typed.booleanCount, frame.typed.firstParameter, frame.typed.firstProcedureParameter⟩, ?_⟩
  have accepted := frame.valid
  simp only [stateValid, Bool.and_eq_true, decide_eq_true_eq, and_assoc] at accepted ⊢
  exact ⟨bounded, accepted.2⟩

theorem ReaderFrame.at_position {text state} (frame : ReaderFrame text state) {position}
    (bounded : ValidCursor text position) : ReaderFrame text {state with position} :=
  frame.header position bounded state.pure state.hiding

theorem ReaderFrame.hidden_name {text state} (frame : ReaderFrame text state) (flags : HiddenMarks) :
    ReaderFrame text {state with «hiding» := flags} :=
  frame.header state.position frame.cursor state.pure flags

/-- All successful Package_Type_At branches return an original identifier,
a strictly advancing bounded cursor, and a nonempty, machine-bounded range. -/
structure ReadType (text : Source) (position : Nat) (mark : PackageTypeResult) : Prop where
  advance : position < mark.after
  cursor : ValidCursor text mark.after
  name : PackageBindings.validName (metadataText text) mark.name = true
  bounded : mark.bounds.Bounded
  ordered : mark.bounds.lower ≤ mark.bounds.upper

theorem package_type_domain (text : Source) (frame : ParserState) (info : PackageBindings.Metadata)
    (position : Nat) (state : ReaderFrame text frame) (cursor : ValidCursor text position) :
    (packageTypeAt text frame info position).after = 0 ∨
      ReadType text position (packageTypeAt text frame info position) := by
  dsimp only [packageTypeAt]
  split
  · exact .inl rfl
  · rename_i accepted
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at accepted
    have name := Bool.of_not_eq_false accepted.1
    have bounds := (ApplicationPackageNames.Native.validName_domain name).2
    have first := skipAt_advances text position cursor (Nat.ne_of_gt bounds.1)
    have nonzero : (functionTypeAt text frame position).after ≠ 0 := by
      rw [Decidable.not_not.mp accepted.2]
      exact Nat.ne_of_gt (Nat.lt_trans bounds.1 bounds.2.1)
    have interval := (functionTypeAt_good text frame position state.native.base.2.2.2.2.2.2.2.1).resolve_left nonzero
    have successful (range : Integer.Interval) (identity : Nat)
        (bounded : range.Bounded) (ordered : range.lower ≤ range.upper) :
        ReadType text position
          ⟨⟨skipAt text position, nameAfter text (skipAt text position)⟩,
            nameAfter text (skipAt text position), (functionTypeAt text frame position).kind, range, identity⟩ :=
      ⟨Nat.lt_of_le_of_lt first bounds.2.1, bounds.2.2, name, bounded, ordered⟩
    split
    · exact .inr (successful .full 0 Integer.Interval.full_bounded (by decide))
    · split
      · exact .inr (successful _ 1 interval.1 interval.2)
      · split
        · exact .inr (successful _ _ interval.1 interval.2)
        · exact .inl rfl

private theorem subset_types (frame : ParserState) (prior : StateType frame)
    {scalars : ScalarExpression.Environment} {booleans : BooleanBindings.Environment}
    {subtypes : List IntegerSubtypes.Binding} (flags : HiddenMarks)
    (scalarRows : scalars.Sublist frame.scalarNames) (booleanRows : booleans.Sublist frame.booleanNames)
    (subtypeRows : subtypes.Sublist frame.subtypeNames.items) :
    StateType {frame with
      scalarNames := scalars, booleanNames := booleans,
      subtypeNames := {frame.subtypeNames with items := subtypes}, «hiding» := flags} :=
  ⟨prior.context, prior.capacity, prior.namesCount, prior.names,
    Nat.le_trans scalarRows.length_le prior.scalarCount, fun item member => prior.scalars item (scalarRows.subset member),
    Nat.le_trans subtypeRows.length_le prior.subtypeCount, fun item member => prior.subtypes item (subtypeRows.subset member),
    Nat.le_trans booleanRows.length_le prior.booleanCount, prior.firstParameter, prior.firstProcedureParameter⟩

theorem ReaderFrame.hide_outer {text frame} (prior : ReaderFrame text frame) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) (present : (hideOuter text frame info name).position ≠ 0) :
    ReaderFrame text (hideOuter text frame info name) := by
  unfold hideOuter at present ⊢
  split at present
  · exact (present rfl).elim
  · rename_i allowed
    rw [ite_eq_right allowed]
    cases scalars : hideEntries (scalarMatches text name)
      (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.scalarNames with
    | none => simp [scalars, invalidState] at present
    | some scalarRows =>
      cases booleans : hideEntries (booleanMatches text name)
        (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.booleanNames with
      | none => simp [scalars, booleans, invalidState] at present
      | some booleanRows =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun item => outerDeclaration info ⟨item.first, item.after⟩) frame.subtypeNames.items with
        | none => simp [scalars, booleans, subtypes, invalidState] at present
        | some subtypeRows =>
          simp only [scalars, booleans, subtypes, Option.bind_some, pure, bind] at present ⊢
          split at present
          · rename_i checked
            rw [ite_eq_left checked]
            exact ⟨subset_types frame prior.typed _ (hideEntries_sublist scalars)
              (hideEntries_sublist booleans) (hideEntries_sublist subtypes), checked⟩
          · exact (present rfl).elim

end Silver.ApplicationPackageDeclarations
