module

public import Silver.PackageMetadataSemantics
public import Silver.PackageInitialization

@[expose] public section

/-! Package routine identities are positions in one completion-order table.
Function/procedure projections retain that ordering and explicitly translate an
identity before using a kind-specific callable table. Native metadata supplies
all scalar domains, including empty explicit formal lists. -/
namespace Silver.Packages

def RoutineSignature.inputTypes : RoutineSignature → List ScalarFunctions.ScalarType
  | .function signature => signature.formals
  | .procedure signature => ScalarProcedures.inputTypes signature.formals

def RoutineSignature.outputTypes : RoutineSignature → List ScalarFunctions.ScalarType
  | .function signature => [signature.result]
  | .procedure signature => ScalarProcedures.outputTypes signature.formals

def RoutineSignature.Valid : RoutineSignature → Prop
  | .function signature => signature.Valid
  | .procedure signature => signature.Valid

def RoutineSignature.functionSignature : RoutineSignature → Option ScalarFunctions.Signature
  | .function signature => some signature
  | .procedure _ => none

def RoutineSignature.procedureSignature : RoutineSignature → Option ScalarProcedures.Signature
  | .function _ => none
  | .procedure signature => some signature

def projectedIndex (select : α → Option β) (earlier : List α) (identity : Nat) : Nat :=
  if identity = 0 then 0 else ((earlier.take (identity - 1)).filterMap select).length + 1

theorem lookupRoutine_filterMap {select : α → Option β} {earlier : List α}
    {identity : Nat} {routine : α} {signature : β}
    (found : lookupRoutine earlier identity = some routine) (selected : select routine = some signature) :
    lookupRoutine (earlier.filterMap select) (projectedIndex select earlier identity) = some signature := by
  induction earlier generalizing identity with
  | nil => simp [lookupRoutine] at found
  | cons first rest ih =>
      cases identity with
      | zero => simp [lookupRoutine] at found
      | succ index =>
          cases index with
          | zero =>
              have same : first = routine := by simpa [lookupRoutine] using found
              subst first
              simp [projectedIndex, lookupRoutine, selected]
          | succ index =>
              have tail : lookupRoutine rest (index + 1) = some routine := by
                simpa [lookupRoutine] using found
              have result := ih tail
              cases head : select first with
              | none => simpa [projectedIndex, lookupRoutine, head] using result
              | some value => simpa [projectedIndex, lookupRoutine, head, Nat.add_assoc] using result

def functionSignatures (earlier : List RoutineSignature) : ScalarFunctions.Signatures :=
  earlier.filterMap RoutineSignature.functionSignature

def procedureSignatures (earlier : List RoutineSignature) : ScalarProcedures.Signatures :=
  earlier.filterMap RoutineSignature.procedureSignature

def functionIndex (earlier : List RoutineSignature) (identity : Nat) : Nat :=
  projectedIndex RoutineSignature.functionSignature earlier identity

def procedureIndex (earlier : List RoutineSignature) (identity : Nat) : Nat :=
  projectedIndex RoutineSignature.procedureSignature earlier identity

theorem functionSignatures_lookup {earlier : List RoutineSignature} {identity : Nat}
    {signature : ScalarFunctions.Signature}
    (found : lookupRoutine earlier identity = some (.function signature)) :
    ScalarFunctions.lookup (functionSignatures earlier) (functionIndex earlier identity) = some signature :=
  lookupRoutine_filterMap found rfl

theorem procedureSignatures_lookup {earlier : List RoutineSignature} {identity : Nat}
    {signature : ScalarProcedures.Signature}
    (found : lookupRoutine earlier identity = some (.procedure signature)) :
    ScalarProcedures.lookup (procedureSignatures earlier) (procedureIndex earlier identity) = some signature :=
  lookupRoutine_filterMap found rfl

theorem RoutineDefinition.initializers_safe {definition : RoutineDefinition}
    {schema : StateSchema} {globals : ScalarFunctions.Frame} {inputs : List ScalarFunctions.Value}
    {final : SharedRanges} (schemaValid : schema.Valid) (globalsFit : schema.Fits globals)
    (bindingsValid : ∀ binding ∈ definition.inputs, binding.Valid)
    (interface : definition.inputs.map InputBinding.domain = definition.signature.inputTypes)
    (inputsFit : ScalarFunctions.ArgumentsFit definition.signature.inputTypes inputs)
    (readable : ∀ item ∈ definition.initializers, item.Readable)
    (checked : checkInitializers
      ⟨schema.integerRanges, inputRangesFrom Integer.emptyRanges definition.inputs⟩
      definition.initializers = some final) :
    let initial : SharedState :=
      ⟨globals, bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ definition.inputs inputs⟩
    InitializersSafe initial definition.initializers ∧
      final.Fits (invocationFrame globals definition.inputs inputs definition.initializers) ∧
      checkedInitializeLocals initial definition.initializers =
        some (invocationFrame globals definition.inputs inputs definition.initializers) := by
  exact checkInitializers_sound checked readable
    (invocation_inputs_full_domain schemaValid globalsFit bindingsValid (interface ▸ inputsFit))

end Silver.Packages

namespace Silver.PackageBindings
open ScalarFunctions (ScalarType)

def Formal.domain (formal : Formal) : ScalarType :=
  match formal.kind with
  | .integer => .integer formal.bounds
  | .boolean => .boolean

def Formal.semantic (formal : Formal) : ScalarProcedures.Formal :=
  ⟨match formal.mode with | .input => .input | .output => .output | .inputOutput => .inputOutput,
    formal.domain⟩

def Routine.formals (info : Metadata) (routine : Routine) : List Formal :=
  (List.range routine.count).map fun offset => info.parameterAt (routine.formalFirst + offset)

def Routine.resultDomain (routine : Routine) : ScalarType :=
  match routine.resultKind with
  | .integer => .integer routine.resultBounds
  | .boolean => .boolean

def Routine.signature (info : Metadata) (routine : Routine) : Packages.RoutineSignature :=
  match routine.kind with
  | .function => .function ⟨(routine.formals info).map Formal.domain, routine.resultDomain⟩
  | .procedure => .procedure ⟨(routine.formals info).map Formal.semantic⟩

theorem Formal.domain_scalar (formal : Formal) : formal.domain.IsScalar := by
  cases kind : formal.kind <;> simp only [domain, kind, ScalarType.IsScalar]

theorem Routine.result_scalar (routine : Routine) : routine.resultDomain.IsScalar := by
  cases kind : routine.resultKind <;> simp only [resultDomain, kind, ScalarType.IsScalar]

theorem Metadata.parameterAt_typed {info : Metadata} (typed : info.Typed) {identity : Nat}
    (positive : 0 < identity) (bounded : identity ≤ info.parameters.length) : (info.parameterAt identity).Typed := by
  have index : identity - 1 < info.parameters.length := by omega
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, _, parameters⟩
  apply parameters
  simp only [Metadata.parameterAt, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem index, Option.getD_some]
  exact List.getElem_mem index

theorem Metadata.routineAt_typed {info : Metadata} (typed : info.Typed) {identity : Nat}
    (positive : 0 < identity) (bounded : identity ≤ info.routines.length) : (info.routineAt identity).Typed := by
  have index : identity - 1 < info.routines.length := by omega
  rcases typed with ⟨_, _, _, _, _, _, _, _, _, _, routines, _⟩
  apply routines
  simp only [Metadata.routineAt, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem index, Option.getD_some]
  exact List.getElem_mem index

theorem validMetadata_parameter {text : Text} {info : Metadata} (valid : validMetadata text info = true)
    {identity : Nat} (positive : 0 < identity) (bounded : identity ≤ info.parameters.length) :
    parameterValid text info identity = true := by
  simp only [validMetadata, Bool.and_eq_true] at valid
  have selected := (List.all_eq_true.mp valid.1.2) (identity - 1) (by simp; omega)
  simpa only [Nat.sub_add_cancel positive] using selected

theorem validMetadata_routine {text : Text} {info : Metadata} (valid : validMetadata text info = true)
    {identity : Nat} (positive : 0 < identity) (bounded : identity ≤ info.routines.length) :
    routineValid text info identity = true := by
  simp only [validMetadata, Bool.and_eq_true] at valid
  have selected := (List.all_eq_true.mp valid.2) (identity - 1) (by simp; omega)
  simpa only [Nat.sub_add_cancel positive] using selected

theorem formal_domain_valid {text : Text} {info : Metadata} {identity : Nat}
    (typed : (info.parameterAt identity).Typed) (valid : parameterValid text info identity = true) :
    (info.parameterAt identity).domain.Valid := by
  have bounded := typed.2.2.2.2.1
  simp only [parameterValid, Bool.and_eq_true] at valid
  have nonempty := valid.2
  simp only [Integer.Interval.isEmpty, Bool.not_eq_true', decide_eq_false_iff_not] at nonempty
  cases kind : (info.parameterAt identity).kind with
  | integer =>
      simp only [Formal.domain, kind, ScalarType.Valid]
      exact ⟨bounded, by omega⟩
  | boolean => simp only [Formal.domain, kind, ScalarType.Valid]

theorem routine_formal_index {text : Text} {info : Metadata} {identity offset : Nat}
    (valid : routineValid text info identity = true) (inside : offset < (info.routineAt identity).count) :
    0 < (info.routineAt identity).formalFirst + offset ∧
      (info.routineAt identity).formalFirst + offset ≤ info.parameters.length := by
  simp only [routineValid, Bool.and_eq_true] at valid
  have formals := valid.1.1.1.1.2
  split at formals
  · omega
  · simp only [decide_eq_true_eq] at formals
    omega

theorem routine_formals_valid {text : Text} {info : Metadata} {identity : Nat}
    (typed : info.Typed) (valid : validMetadata text info = true)
    (routine : routineValid text info identity = true) :
    ∀ formal ∈ (info.routineAt identity).formals info, formal.domain.Valid := by
  intro formal member
  obtain ⟨offset, inside, rfl⟩ := List.mem_map.mp member
  have index := routine_formal_index routine (List.mem_range.mp inside)
  exact formal_domain_valid (info.parameterAt_typed typed index.1 index.2)
    (validMetadata_parameter valid index.1 index.2)

theorem routine_signature_valid {text : Text} {info : Metadata} {identity : Nat}
    (typed : info.Typed) (valid : validMetadata text info = true)
    (positive : 0 < identity) (bounded : identity ≤ info.routines.length) :
    ((info.routineAt identity).signature info).Valid := by
  have routine := validMetadata_routine valid positive bounded
  have formals := routine_formals_valid typed valid routine
  cases kind : (info.routineAt identity).kind with
  | function =>
      simp only [Routine.signature, kind, Packages.RoutineSignature.Valid]
      have itemTyped := info.routineAt_typed typed positive bounded
      rcases itemTyped with ⟨_, _, _, _, _, _, _, _, _, _, resultBounded, _⟩
      simp only [routineValid, Bool.and_eq_true] at routine
      have result := routine.1.2
      simp only [kind, ↓reduceIte, Bool.and_eq_true, Integer.Interval.isEmpty,
        Bool.not_eq_true', decide_eq_false_iff_not] at result
      refine ⟨?_, ?_, (info.routineAt identity).result_scalar⟩
      · intro domain member
        obtain ⟨formal, present, rfl⟩ := List.mem_map.mp member
        exact formals formal present
      · cases resultKind : (info.routineAt identity).resultKind with
        | integer =>
            simp only [Routine.resultDomain, resultKind, ScalarType.Valid]
            exact ⟨resultBounded, by omega⟩
        | boolean => simp only [Routine.resultDomain, resultKind, ScalarType.Valid]
  | procedure =>
      simp only [Routine.signature, kind, Packages.RoutineSignature.Valid, ScalarProcedures.Signature.Valid]
      intro formal member
      obtain ⟨native, present, rfl⟩ := List.mem_map.mp member
      exact ⟨formals native present, Or.inr native.domain_scalar⟩

end Silver.PackageBindings
