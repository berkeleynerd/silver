module

public import Silver.ProcedureMetadataValidity
public import Silver.ScalarProcedureTypes

@[expose] public section

/-! The procedure signature seen by the compositional checker is read from the
native formal slice. Appending later formal metadata cannot change an already
accepted signature. Writable existence belongs to declaration admission, not
Valid_Metadata's more general native input domain. -/
namespace Silver.ProcedureBindings

def modeModel : Mode → ScalarProcedures.Mode
  | .input => .input
  | .output => .output
  | .inputOutput => .inputOutput

def formalModel (formal : Formal) : ScalarProcedures.Formal :=
  ⟨modeModel formal.mode, match formal.kind with
    | .integer => .integer formal.bounds
    | .boolean => .boolean⟩

def formalModels (catalog : Metadata) (first : Nat) : Nat → List ScalarProcedures.Formal
  | 0 => []
  | count + 1 => formalModel (parameter catalog first) :: formalModels catalog (first + 1) count

def signatureModel (catalog : Metadata) (entry : Signature) : ScalarProcedures.Signature :=
  ⟨formalModels catalog entry.formalFirst entry.count⟩

def catalogSignatures (catalog : Metadata) : ScalarProcedures.Signatures :=
  catalog.items.map (signatureModel catalog)

@[simp] theorem formalModels_length (catalog : Metadata) (first count : Nat) :
    (formalModels catalog first count).length = count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih => simp only [formalModels, List.length_cons, ih]

theorem formalModel_valid {text : Source} {formal : Formal}
    (valid : ValidFormal text formal) : (formalModel formal).domain.Valid := by
  cases kind : formal.kind <;> simp only [formalModel, kind, ScalarFunctions.ScalarType.Valid]
  · exact valid.2

theorem formalModels_valid {text : Source} (catalog : Metadata) (first count : Nat)
    (valid : ValidMetadata text catalog) (positive : 0 < first)
    (bounded : first + count - 1 ≤ catalog.parameters.length) :
    ∀ formal ∈ formalModels catalog first count, formal.domain.Valid := by
  induction count generalizing first with
  | zero => simp [formalModels]
  | succ count ih =>
      intro formal member
      simp only [formalModels, List.mem_cons] at member
      rcases member with rfl | later
      · exact formalModel_valid (valid.2.2.1 _ (parameter_mem positive (by omega)))
      · exact ih (first + 1) (by omega) (by omega) formal later

theorem signatureModel_valid {text : Source} {catalog : Metadata} {entry : Signature}
    (valid : ValidMetadata text catalog) (entryValid : ValidSignature text catalog entry)
    (writable : ScalarProcedures.outputTypes (signatureModel catalog entry).formals ≠ []) :
    (signatureModel catalog entry).Valid := by
  refine ⟨?_, ?_, writable⟩
  · intro empty
    have size := formalModels_length catalog entry.formalFirst entry.count
    have positive := entryValid.2.1
    change formalModels catalog entry.formalFirst entry.count = [] at empty
    rw [empty] at size
    simp only [List.length_nil] at size
    omega
  · exact formalModels_valid catalog entry.formalFirst entry.count valid entryValid.2.2.1 (by
      have start := entryValid.2.2.1
      have within := entryValid.2.2.2.1
      have count := entryValid.2.2.2.2
      omega)

theorem catalogSignatures_lookup {catalog : Metadata} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ catalog.items.length) :
    ScalarProcedures.lookup (catalogSignatures catalog) index =
      some (signatureModel catalog (signature catalog index)) := by
  have inside : index - 1 < catalog.items.length := by omega
  simp [ScalarProcedures.lookup, catalogSignatures, signature,
    Nat.ne_of_gt positive, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]

theorem formalModels_append_parameters (catalog : Metadata)
    (more : List Formal) (first count : Nat)
    (positive : 0 < first) (bounded : first + count - 1 ≤ catalog.parameters.length) :
    formalModels {catalog with parameters := catalog.parameters ++ more} first count =
      formalModels catalog first count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalModels]
      rw [parameter_prefix catalog more first positive (by omega),
        ih (first + 1) (by omega) (by omega)]

theorem signatureModel_append_parameters {text : Source} (catalog : Metadata)
    (more : List Formal) (entry : Signature) (valid : ValidSignature text catalog entry) :
    signatureModel {catalog with parameters := catalog.parameters ++ more} entry =
      signatureModel catalog entry := by
  unfold signatureModel
  rw [formalModels_append_parameters catalog more entry.formalFirst entry.count valid.2.2.1 (by
    have first := valid.2.2.1
    have bounded := valid.2.2.2.1
    have count := valid.2.2.2.2
    omega)]

theorem catalogSignatures_append_parameters {text : Source} (catalog : Metadata)
    (more : List Formal) (valid : ValidMetadata text catalog) :
    catalogSignatures {catalog with parameters := catalog.parameters ++ more} = catalogSignatures catalog := by
  apply List.map_congr_left
  intro entry present
  exact signatureModel_append_parameters catalog more entry (valid.2.2.2 entry present)

theorem formalModels_append (catalog : Metadata) (entry : Signature) (first count : Nat) :
    formalModels (append catalog entry) first count = formalModels catalog first count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalModels]
      exact congrArg (formalModel (parameter catalog first) :: ·) (ih (first + 1))

theorem signatureModel_append (catalog : Metadata) (entry value : Signature) :
    signatureModel (append catalog entry) value = signatureModel catalog value := by
  simp only [signatureModel, formalModels_append]

theorem catalogSignatures_append (catalog : Metadata) (entry : Signature) :
    catalogSignatures (append catalog entry) =
      catalogSignatures catalog ++ [signatureModel catalog entry] := by
  simp only [catalogSignatures, append, List.map_append, List.map_cons, List.map_nil]
  congr 1
  · apply List.map_congr_left
    intro value _
    exact signatureModel_append catalog entry value
  · exact congrArg (fun value => [value]) (signatureModel_append catalog entry entry)

end Silver.ProcedureBindings
