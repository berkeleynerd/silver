module

public import Silver.ApplicationPackageDeclarationsSignatureLoopDomains

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.MetadataTypes
open Compose Compose.Expressions ApplicationPackageNames PackageBindings

theorem span {text : Source} (valid : ValidText text) (name : NameSpan)
    (named : ValidName text name.first name.after) : name.Typed := by
  unfold NameSpan.Typed
  have length := valid.2
  obtain ⟨_, ordered, bounded⟩ := named
  constructor <;> omega

theorem type_name {text : Source} (valid : ValidText text) (frame : ParserState) (info : Metadata)
    (position : Nat) : (packageTypeAt text frame info position).name.Typed := by
  unfold packageTypeAt
  dsimp only
  split
  · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
  · rename_i accepted
    have named : PackageBindings.validName (metadataText text)
        ⟨skipAt text position, nameAfter text (skipAt text position)⟩ = true :=
      Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false, Bool.true_or]))
    have typed := span valid _ (ApplicationPackageNames.Native.validName_domain named).2
    split
    · exact typed
    · split
      · exact typed
      · split
        · exact typed
        · exact ⟨Nat.zero_le _, Nat.zero_le _⟩

theorem formal_default : Formal.Typed ({} : Formal) := by
  simp [Formal.Typed, NameSpan.Typed, Integer.Interval.empty_bounded]

theorem routine_default : Routine.Typed ({} : Routine) := by
  simp [Routine.Typed, NameSpan.Typed, Integer.Interval.empty_bounded, emptyStateSet]

theorem parameter_at {info : Metadata} (typed : info.Typed) (index : Nat) : (info.parameterAt index).Typed := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, _, parameters⟩
  unfold Metadata.parameterAt
  simp only [List.getD_eq_getElem?_getD]
  cases selected : info.parameters[index - 1]? with
  | none => exact formal_default
  | some item => exact parameters item (List.mem_of_getElem? selected)

theorem routine_at {info : Metadata} (typed : info.Typed) (index : Nat) : (info.routineAt index).Typed := by
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, routines, _⟩
  unfold Metadata.routineAt
  simp only [List.getD_eq_getElem?_getD]
  cases selected : info.routines[index - 1]? with
  | none => exact routine_default
  | some item => exact routines item (List.mem_of_getElem? selected)

theorem formal_body {item : Formal} (typed : item.Typed) (name typeName : NameSpan)
    (named : name.Typed) (typeNamed : typeName.Typed) :
    ({item with bodyName := name, bodyTypeName := typeName} : Formal).Typed :=
  ⟨typed.1, named, typed.2.2.1, typeNamed, typed.2.2.2.2⟩

theorem routine_body {item : Routine} (typed : item.Typed) (name : NameSpan) (named : name.Typed)
    (first : Nat) (bounded : first ≤ maxSourceLength + 1) :
    ({item with bodyName := name, bodyFirst := first} : Routine).Typed := by
  rcases typed with ⟨specName, _, specResult, bodyResult, specFirst, specAfter, _, bodyAfter,
    formalFirst, count, bounds, identity, reads, writes⟩
  exact ⟨specName, named, specResult, bodyResult, specFirst, specAfter, bounded, bodyAfter,
    formalFirst, count, bounds, identity, reads, writes⟩

theorem routine_result {item : Routine} (typed : item.Typed) (name : NameSpan) (named : name.Typed) :
    ({item with bodyResultName := name} : Routine).Typed := by
  rcases typed with ⟨specName, bodyName, specResult, _, rest⟩
  exact ⟨specName, bodyName, specResult, named, rest⟩

theorem set_parameter {info : Metadata} (typed : info.Typed) (index : Nat) (item : Formal)
    (itemTyped : item.Typed) : ({info with parameters := info.parameters.set index item} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, exports, states, routines, completed, ?_, exportTypes, stateTypes, routineTypes, ?_⟩
  · simpa only [List.length_set] using parameters
  · intro value member
    rcases List.mem_or_eq_of_mem_set member with prior | rfl
    · exact parameterTypes value prior
    · exact itemTyped

theorem set_routine {info : Metadata} (typed : info.Typed) (index : Nat) (item : Routine)
    (itemTyped : item.Typed) : ({info with routines := info.routines.set index item} : Metadata).Typed := by
  rcases typed with ⟨name, bodyName, units, exports, states, routines, completed, parameters,
    exportTypes, stateTypes, routineTypes, parameterTypes⟩
  refine ⟨name, bodyName, units, exports, states, ?_, completed, parameters, exportTypes, stateTypes, ?_, parameterTypes⟩
  · simpa only [List.length_set] using routines
  · intro value member
    rcases List.mem_or_eq_of_mem_set member with prior | rfl
    · exact routineTypes value prior
    · exact itemTyped

end Silver.ApplicationPackageDeclarations.MetadataTypes
