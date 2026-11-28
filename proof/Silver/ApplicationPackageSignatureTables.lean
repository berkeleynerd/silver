module

public import Silver.ApplicationPackageDeclarationsSignatureStates

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open PackageBindings

/-- The fields of a formal written while reading its specification. -/
def formalDeclaration (item : Formal) : Formal := {item with bodyName := {}, bodyTypeName := {}}

/-- The fields of a routine retained from its specification throughout the
signature, body, effect and footer passes. -/
def routineDeclaration (item : Routine) : Routine :=
  {item with
    bodyName := {}
    bodyResultName := {}
    bodyFirst := 0
    bodyAfter := 0
    mayRead := []
    mayWrite := []
    assigned := false}

def completingItem (info : Metadata) : Routine := info.routineAt (info.completed + 1)

def OutsideFormalSegment (original : Metadata) (index : Nat) : Prop :=
  ∀ offset, offset < (completingItem original).count → index ≠ (completingItem original).formalFirst + offset - 1

structure FormalTable (original after : Metadata) : Prop where
  declared : after.parameters.map formalDeclaration = original.parameters.map formalDeclaration
  outside : ∀ index, OutsideFormalSegment original index → after.parameters[index]? = original.parameters[index]?

structure CompletedTables (original after : Metadata) : Prop extends FormalTable original after where
  routineDeclarations : after.routines.map routineDeclaration = original.routines.map routineDeclaration
  otherRoutines : ∀ index, index ≠ original.completed → after.routines[index]? = original.routines[index]?

theorem CompletedTables.lengths {original after : Metadata} (tables : CompletedTables original after) :
    after.parameters.length = original.parameters.length ∧ after.routines.length = original.routines.length := by
  constructor
  · simpa only [List.length_map] using congrArg List.length tables.declared
  · simpa only [List.length_map] using congrArg List.length tables.routineDeclarations

namespace SignatureTables

theorem map_set_same {α β : Type} (project : α → β) (rows : List α) (index : Nat) (item fallback : α)
    (same : project item = project (rows.getD index fallback)) : (rows.set index item).map project = rows.map project := by
  rw [List.map_set]
  by_cases bound : index < rows.length
  · have value : project item = (rows.map project)[index]'(by simpa only [List.length_map] using bound) := by
      simpa only [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound, Option.getD_some,
        List.getElem_map] using same
    rw [value, List.set_getElem_self]
  · apply List.set_eq_of_length_le
    simpa only [List.length_map] using Nat.le_of_not_lt bound

theorem initial (info : Metadata) : FormalTable info info := ⟨rfl, fun _ _ => rfl⟩

/-- A successful or partially completed write changes only body spans at
its original one-based slot. All declaration fields survive even at that slot. -/
theorem store_formal {original info : Metadata} {offset : Nat} (prior : FormalTable original info)
    (within : offset < (completingItem original).count) (first : Nat) (start : first = (completingItem original).formalFirst)
    (name typeName : NameSpan) :
    let slot := first + offset
    let item := {info.parameterAt slot with bodyName := name, bodyTypeName := typeName}
    FormalTable original {info with parameters := info.parameters.set (slot - 1) item} := by
  dsimp only
  constructor
  · let updated := {info.parameterAt (first + offset) with bodyName := name, bodyTypeName := typeName}
    exact (map_set_same formalDeclaration info.parameters (first + offset - 1) updated {} rfl).trans prior.declared
  · intro index outside
    have distinct : first + offset - 1 ≠ index := (start ▸ outside offset within).symm
    exact (List.getElem?_set_ne distinct).trans (prior.outside index outside)

theorem unchanged_routines {original info : Metadata} (formals : FormalTable original info)
    (routines : info.routines = original.routines) : CompletedTables original info :=
  ⟨formals, congrArg (List.map routineDeclaration) routines, fun i _ => congrArg (fun rows : List Routine => rows[i]?) routines⟩

theorem store_routine {original info : Metadata} (formals : FormalTable original info)
    (routines : info.routines = original.routines) {identity : Nat} (selected : identity = original.completed + 1)
    (item : Routine) (fields : routineDeclaration item = routineDeclaration (completingItem original)) :
    CompletedTables original {info with routines := info.routines.set (identity - 1) item} := by
  have index : identity - 1 = original.completed := by omega
  have same : routineDeclaration item = routineDeclaration (info.routines.getD (identity - 1) {}) := by
    rw [index, routines]
    simpa only [completingItem, Metadata.routineAt, Nat.add_one_sub_one] using fields
  constructor
  · exact ⟨formals.declared, formals.outside⟩
  · exact (map_set_same routineDeclaration info.routines (identity - 1) item {} same).trans
      (congrArg (List.map routineDeclaration) routines)
  · intro j different
    have away : identity - 1 ≠ j := index ▸ different.symm
    exact (List.getElem?_set_ne away).trans (congrArg (fun xs : List Routine => xs[j]?) routines)

end SignatureTables
end Silver.ApplicationPackageDeclarations
