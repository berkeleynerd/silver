module

public import Silver.ApplicationPackageConstantSeeds
public import Silver.ApplicationPackageDeclarationsFormalModes

@[expose] public section

/-! Exact source-identity ranges for global state, incoming formals and
immutable constant loads. Incoming integer domains retain their full declared
intervals; ordinal parser slots are never substituted for declaration cells. -/
namespace Silver.ApplicationPackageInitializers
open Packages Compose ApplicationPackageFrameLayout ApplicationPackageDeclarations

private theorem extend_other (ranges : Integer.Ranges) (target : Cell) (domain : ScalarFunctions.ScalarType)
    (identity : Nat) (apart : target ≠ .integer identity) :
    extendRanges ranges target domain identity = ranges identity := by
  cases target with
  | integer other =>
    cases domain <;> simp_all only [extendRanges, Integer.put, ScalarProcedures.Cell.integer.injEq, ne_eq]
    split
    · subst other
      contradiction
    · rfl
  | boolean other => cases domain <;> rfl

theorem inputRangesFrom_other (ranges : Integer.Ranges) (bindings : List InputBinding) (identity : Nat)
    (apart : ∀ binding ∈ bindings, binding.target ≠ .integer identity) :
    inputRangesFrom ranges bindings identity = ranges identity := by
  induction bindings generalizing ranges with
  | nil => rfl
  | cons binding rest ih =>
    exact (ih _ (fun next member => apart next (List.mem_cons_of_mem _ member))).trans
      (extend_other ranges binding.target binding.domain identity (apart binding List.mem_cons_self))

theorem inputRangesFrom_selected {bindings : List InputBinding} {binding : InputBinding}
    {identity : Nat} {bounds : Integer.Interval}
    (unique : (bindings.map InputBinding.target).Nodup) (member : binding ∈ bindings)
    (target : binding.target = .integer identity) (domain : binding.domain = .integer bounds)
    (ranges : Integer.Ranges) : inputRangesFrom ranges bindings identity = some bounds := by
  induction bindings generalizing ranges with
  | nil => cases member
  | cons head rest ih =>
    have distinct := List.nodup_cons.mp unique
    rcases List.mem_cons.mp member with rfl | later
    · change inputRangesFrom (extendRanges ranges binding.target binding.domain) rest identity = _
      rw [inputRangesFrom_other]
      · simp only [target, domain, extendRanges, Integer.put, ite_true]
      · intro next present same
        apply distinct.1
        exact List.mem_map.mpr ⟨next, present, same.trans target.symm⟩
    · exact ih distinct.2 later _

theorem inputRangesFrom_bound {bound : Nat} {ranges : Integer.Ranges} {bindings : List InputBinding}
    (prior : ∀ identity, bound < identity → ranges identity = none)
    (inside : ∀ binding ∈ bindings, cellIndex binding.target ≤ bound) :
    ∀ identity, bound < identity → inputRangesFrom ranges bindings identity = none := by
  intro identity above
  rw [inputRangesFrom_other]
  · exact prior identity above
  · intro binding member selected
    have index := inside binding member
    rw [selected] at index
    change identity ≤ bound at index
    omega

theorem initializerDomains_bindings (ranges : SharedRanges) (items : List LocalInitializer) :
    initializerDomains ranges items =
      ⟨ranges.globals, inputRangesFrom ranges.locals (items.map fun item => ⟨item.target, item.domain⟩)⟩ := by
  induction items generalizing ranges with
  | nil => rfl
  | cons item rest ih =>
    simpa only [initializerDomains, List.map_cons, inputRangesFrom, LocalInitializer.declare] using
      ih (item.declare ranges)

theorem stateRanges_selected {schema : StateSchema} {declaration : Packages.StateDeclaration}
    {identity : Nat} {bounds : Integer.Interval}
    (unique : (schema.map Packages.StateDeclaration.cell).Nodup)
    (member : declaration ∈ schema)
    (target : declaration.cell = .integer identity) (domain : declaration.domain = .integer bounds) :
    schema.integerRanges identity = some bounds := by
  induction schema with
  | nil => cases member
  | cons head rest ih =>
    have distinct := List.nodup_cons.mp unique
    rcases List.mem_cons.mp member with rfl | later
    · simp only [StateSchema.integerRanges, target, domain, extendRanges, Integer.put, ite_true]
    · change extendRanges (StateSchema.integerRanges rest) head.cell head.domain identity = _
      rw [extend_other]
      · exact ih distinct.2 later
      · intro selected
        apply distinct.1
        exact List.mem_map.mpr ⟨declaration, later, target.trans selected.symm⟩

theorem metadata_global_range (info : PackageBindings.Metadata) {identity : Nat}
    (positive : 0 < identity) (inside : identity ≤ info.states.length)
    (kind : (info.stateAt identity).kind = .integer) :
    info.stateSchema.integerRanges identity = some (info.stateAt identity).declaredBounds := by
  apply stateRanges_selected (declaration := (info.stateAt identity).semantic identity)
  · simp only [PackageBindings.Metadata.stateSchema, List.map_map, Function.comp_def,
      PackageBindings.StateDeclaration.semantic_cell]
    change List.Pairwise (fun a b : Cell => a ≠ b) _
    rw [List.pairwise_map]
    apply List.Pairwise.imp _ List.nodup_range
    intro a b different same
    apply different
    have indices := congrArg cellIndex same
    simpa only [PackageBindings.StateDeclaration.cell_identity, Nat.add_right_cancel_iff] using indices
  · exact List.mem_map.mpr ⟨identity - 1, List.mem_range.mpr (by omega), by rw [Nat.sub_add_cancel positive]⟩
  · simp only [PackageBindings.StateDeclaration.semantic, kind]
  · simp only [PackageBindings.StateDeclaration.semantic, kind]

def formalInput (formal : PackageBindings.Formal) : InputBinding :=
  ⟨match formal.kind with | .integer => .integer formal.bodyName.first | .boolean => .boolean formal.bodyName.first,
    formal.domain⟩

theorem formalInput_valid (formal : PackageBindings.Formal) (domain : formal.domain.Valid) :
    (formalInput formal).Valid := by
  refine ⟨?_, domain⟩
  cases kind : formal.kind <;> simp only [formalInput, PackageBindings.Formal.domain, kind, CellDomain]

theorem formalInput_identity (formal : PackageBindings.Formal) :
    cellIndex (formalInput formal).target = formal.bodyName.first := by
  cases kind : formal.kind <;> simp only [formalInput, kind, cellIndex]

def routineInputs (info : PackageBindings.Metadata) (item : PackageBindings.Routine) : List InputBinding :=
  (ApplicationPackageFormalStorage.chosen false info (ApplicationPackageBodies.formalIndices item)).map formalInput

theorem routineInputs_unique {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {start stop : Nat}
    (window : ApplicationPackageFormalStorage.HeaderWindow start stop
      ((ApplicationPackageBodies.formalIndices item).map info.parameterAt)) :
    ((routineInputs info item).map InputBinding.target).Nodup := by
  have ordered := window.ordered.sublist
    (ApplicationPackageFormalStorage.chosen_sublist false info (ApplicationPackageBodies.formalIndices item))
  change List.Pairwise (fun a b : Cell => a ≠ b) _
  simp only [routineInputs, List.map_map, List.pairwise_map]
  apply ordered.imp
  intro left right before same
  have positions := congrArg cellIndex same
  simp only [Function.comp_apply, formalInput_identity] at positions
  exact Nat.ne_of_lt before positions

theorem routineInputs_range {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {start stop : Nat}
    (window : ApplicationPackageFormalStorage.HeaderWindow start stop
      ((ApplicationPackageBodies.formalIndices item).map info.parameterAt))
    {formal : PackageBindings.Formal}
    (selected : formal ∈ ApplicationPackageFormalStorage.chosen false info (ApplicationPackageBodies.formalIndices item))
    (kind : formal.kind = .integer) (ranges : Integer.Ranges) :
    inputRangesFrom ranges (routineInputs info item) formal.bodyName.first = some formal.bounds := by
  apply inputRangesFrom_selected (binding := formalInput formal) (routineInputs_unique window)
    (List.mem_map.mpr ⟨formal, selected, rfl⟩)
  · simp only [formalInput, kind]
  · simp only [formalInput, PackageBindings.Formal.domain, kind]

theorem routineInputs_preserve_before {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {start stop : Nat}
    (window : ApplicationPackageFormalStorage.HeaderWindow start stop
      ((ApplicationPackageBodies.formalIndices item).map info.parameterAt))
    (ranges : Integer.Ranges) {identity : Nat} (earlier : identity < start) :
    inputRangesFrom ranges (routineInputs info item) identity = ranges identity := by
  apply inputRangesFrom_other
  intro binding member same
  obtain ⟨formal, selected, rfl⟩ := List.mem_map.mp member
  have after := (window.entries formal
    ((ApplicationPackageFormalStorage.chosen_sublist false info _).subset selected)).1
  have position := congrArg cellIndex same
  rw [formalInput_identity] at position
  change formal.bodyName.first = identity at position
  omega

theorem routineInputs_bound {info : PackageBindings.Metadata} {item : PackageBindings.Routine} {start stop bound : Nat}
    (window : ApplicationPackageFormalStorage.HeaderWindow start stop
      ((ApplicationPackageBodies.formalIndices item).map info.parameterAt))
    (within : stop ≤ bound + 1) (ranges : Integer.Ranges)
    (bounded : ∀ identity, bound < identity → ranges identity = none) :
    ∀ identity, bound < identity → inputRangesFrom ranges (routineInputs info item) identity = none := by
  apply inputRangesFrom_bound bounded
  intro binding member
  obtain ⟨formal, selected, rfl⟩ := List.mem_map.mp member
  rw [formalInput_identity]
  have before := (window.entries formal
    ((ApplicationPackageFormalStorage.chosen_sublist false info _).subset selected)).2
  omega

private theorem input_types (formals : List PackageBindings.Formal) :
    ((formals.flatMap (ApplicationPackageFormalStorage.selected false)).map formalInput).map InputBinding.domain =
      ScalarProcedures.inputTypes (formals.map PackageBindings.Formal.semantic) := by
  induction formals with
  | nil => rfl
  | cons formal rest ih =>
    cases mode : formal.mode <;>
      simp [ApplicationPackageFormalStorage.selected, mode, formalInput,
        PackageBindings.Formal.semantic, ScalarProcedures.inputTypes, ih]

private theorem function_inputs (formals : List PackageBindings.Formal)
    (inputs : ∀ formal ∈ formals, formal.mode = .input) :
    formals.flatMap (ApplicationPackageFormalStorage.selected false) = formals := by
  induction formals with
  | nil => rfl
  | cons formal rest ih =>
    simp [ApplicationPackageFormalStorage.selected, inputs formal List.mem_cons_self,
      ih (fun next member => inputs next (List.mem_cons_of_mem _ member))]

theorem routineInputs_interface {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    (declared : DeclaredFormalModes info) (member : item ∈ info.routines) :
    (routineInputs info item).map InputBinding.domain = (item.signature info).inputTypes := by
  have chosen : ApplicationPackageFormalStorage.chosen false info (ApplicationPackageBodies.formalIndices item) =
      (item.formals info).flatMap (ApplicationPackageFormalStorage.selected false) := by
    simp only [ApplicationPackageFormalStorage.chosen, ApplicationPackageBodies.formalIndices,
      PackageBindings.Routine.formals, List.flatMap_map]
  unfold routineInputs
  rw [chosen]
  cases kind : item.kind with
  | function =>
    rw [function_inputs _ (fun formal present => declared.function_inputs member kind present)]
    simp only [List.map_map, Function.comp_def, formalInput, PackageBindings.Routine.signature, kind,
      RoutineSignature.inputTypes]
  | procedure =>
    simpa only [PackageBindings.Routine.signature, kind, RoutineSignature.inputTypes] using input_types (item.formals info)

end Silver.ApplicationPackageInitializers
