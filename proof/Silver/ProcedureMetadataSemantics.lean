module

public import Silver.ProcedureMetadataValidity
public import Silver.PredicateFunctionCallTypes
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

def formalModel (formal : Formal) (types : ArrayBindings.TypeEnvironment := []) : ScalarProcedures.Formal :=
  ⟨modeModel formal.mode, Predicate.formalType (Predicate.procedureInputFormal formal) types⟩

def formalModels (catalog : Metadata) (first count : Nat) (types : ArrayBindings.TypeEnvironment := []) :
    List ScalarProcedures.Formal :=
  match count with
  | 0 => []
  | n + 1 => formalModel (parameter catalog first) types :: formalModels catalog (first + 1) n types

def signatureModel (catalog : Metadata) (entry : Signature) (types : ArrayBindings.TypeEnvironment := []) :
    ScalarProcedures.Signature :=
  ⟨formalModels catalog entry.formalFirst entry.count types⟩

def catalogSignatures (catalog : Metadata) (types : ArrayBindings.TypeEnvironment := []) :
    ScalarProcedures.Signatures :=
  catalog.items.map fun entry => signatureModel catalog entry types

@[simp] theorem formalModels_length (catalog : Metadata) (first count : Nat)
    (types : ArrayBindings.TypeEnvironment := []) :
    (formalModels catalog first count types).length = count := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih => simp only [formalModels, List.length_cons, ih]

theorem formalModel_valid {text : Source} {formal : Formal} {types : ArrayBindings.TypeEnvironment}
    (valid : ValidFormal text formal) (typesValid : ArrayBindings.ValidTypes text types)
    (known : formal.typeId ≤ types.length) :
    (formalModel formal types).domain.Valid ∧
      ((formalModel formal types).mode = .input ∨ (formalModel formal types).domain.IsScalar) := by
  refine ⟨Predicate.formalType_domainValid ?_ typesValid known, ?_⟩
  · exact ⟨valid.1, valid.2.1, valid.2.2.1, fun named => (valid.2.2.2 named).2⟩
  · by_cases named : formal.typeId ≠ 0
    · exact Or.inl (congrArg modeModel (valid.2.2.2 named).1)
    · right
      cases kind : formal.kind <;>
        simp [formalModel, Predicate.formalType, Predicate.procedureInputFormal, named, kind,
          ScalarFunctions.ScalarType.IsScalar]

theorem formalModels_valid {text : Source} (catalog : Metadata) (first count : Nat)
    (valid : ValidMetadata text catalog) (positive : 0 < first)
    (bounded : first + count - 1 ≤ catalog.parameters.length) {types : ArrayBindings.TypeEnvironment}
    (typesValid : ArrayBindings.ValidTypes text types)
    (known : ∀ i, first ≤ i → i < first + count → (parameter catalog i).typeId ≤ types.length) :
    ∀ formal ∈ formalModels catalog first count types,
      formal.domain.Valid ∧ (formal.mode = .input ∨ formal.domain.IsScalar) := by
  induction count generalizing first with
  | zero => simp [formalModels]
  | succ count ih =>
      intro formal member
      simp only [formalModels, List.mem_cons] at member
      rcases member with rfl | later
      · have member := parameter_mem (procedures := catalog) positive (by omega)
        exact formalModel_valid (valid.2.2.1 _ member) typesValid (known first (by omega) (by omega))
      · exact ih (first + 1) (by omega) (by omega) (fun i lower upper => known i (by omega) (by omega)) formal later

theorem signatureModel_valid {text : Source} {catalog : Metadata} {entry : Signature}
    (valid : ValidMetadata text catalog) (entryValid : ValidSignature text catalog entry)
    {types : ArrayBindings.TypeEnvironment} (typesValid : ArrayBindings.ValidTypes text types)
    (known : ∀ i, entry.formalFirst ≤ i → i < entry.formalFirst + entry.count →
      (parameter catalog i).typeId ≤ types.length)
    (writable : ScalarProcedures.outputTypes (signatureModel catalog entry types).formals ≠ []) :
    (signatureModel catalog entry types).Valid := by
  refine ⟨?_, ?_, writable⟩
  · intro empty
    have size := formalModels_length catalog entry.formalFirst entry.count types
    have positive := entryValid.2.1
    change formalModels catalog entry.formalFirst entry.count types = [] at empty
    rw [empty] at size
    simp only [List.length_nil] at size
    omega
  · exact formalModels_valid catalog entry.formalFirst entry.count valid entryValid.2.2.1 (by
      have start := entryValid.2.2.1
      have within := entryValid.2.2.2.1
      have count := entryValid.2.2.2.2
      omega) typesValid known

theorem catalogSignatures_lookup {catalog : Metadata} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ catalog.items.length) {types : ArrayBindings.TypeEnvironment} :
    ScalarProcedures.lookup (catalogSignatures catalog types) index =
      some (signatureModel catalog (signature catalog index) types) := by
  have inside : index - 1 < catalog.items.length := by omega
  simp [ScalarProcedures.lookup, catalogSignatures, signature,
    Nat.ne_of_gt positive, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]

theorem formalModels_append_parameters (catalog : Metadata)
    (more : List Formal) (first count : Nat)
    (positive : 0 < first) (bounded : first + count - 1 ≤ catalog.parameters.length)
    {types : ArrayBindings.TypeEnvironment} :
    formalModels {catalog with parameters := catalog.parameters ++ more} first count types =
      formalModels catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalModels]
      rw [parameter_prefix catalog more first positive (by omega),
        ih (first + 1) (by omega) (by omega)]

theorem signatureModel_append_parameters {text : Source} (catalog : Metadata)
    (more : List Formal) (entry : Signature)
    (valid : ValidSignature text catalog entry) {types : ArrayBindings.TypeEnvironment} :
    signatureModel {catalog with parameters := catalog.parameters ++ more} entry types =
      signatureModel catalog entry types := by
  unfold signatureModel
  rw [formalModels_append_parameters catalog more entry.formalFirst entry.count valid.2.2.1 (by
    have first := valid.2.2.1
    have bounded := valid.2.2.2.1
    have count := valid.2.2.2.2
    omega)]

theorem catalogSignatures_append_parameters {text : Source} (catalog : Metadata)
    (more : List Formal) (valid : ValidMetadata text catalog)
    {types : ArrayBindings.TypeEnvironment} :
    catalogSignatures {catalog with parameters := catalog.parameters ++ more} types =
      catalogSignatures catalog types := by
  apply List.map_congr_left
  intro entry present
  exact signatureModel_append_parameters catalog more entry (valid.2.2.2 entry present)

theorem formalModels_append (catalog : Metadata) (entry : Signature)
    (first count : Nat) {types : ArrayBindings.TypeEnvironment} :
    formalModels (append catalog entry) first count types = formalModels catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalModels]
      exact congrArg (formalModel (parameter catalog first) types :: ·) (ih (first + 1))

theorem signatureModel_append (catalog : Metadata) (entry value : Signature)
    {types : ArrayBindings.TypeEnvironment} :
    signatureModel (append catalog entry) value types = signatureModel catalog value types := by
  simp only [signatureModel, formalModels_append]

theorem catalogSignatures_append (catalog : Metadata) (entry : Signature)
    {types : ArrayBindings.TypeEnvironment} :
    catalogSignatures (append catalog entry) types =
      catalogSignatures catalog types ++ [signatureModel catalog entry types] := by
  simp only [catalogSignatures, append, List.map_append, List.map_cons, List.map_nil]
  congr 1
  · apply List.map_congr_left
    intro value _
    exact signatureModel_append catalog entry value
  · exact congrArg (fun value => [value]) (signatureModel_append catalog entry entry)

theorem formalModel_prefix (formal : Formal) (types more : ArrayBindings.TypeEnvironment)
    (known : formal.typeId ≤ types.length) : formalModel formal (types ++ more) = formalModel formal types := by
  apply congrArg (fun domain => (⟨modeModel formal.mode, domain⟩ : ScalarProcedures.Formal))
  exact Predicate.formalType_prefix _ _ _ known

theorem formalModels_typePrefix (catalog : Metadata) (first count : Nat)
    (types more : ArrayBindings.TypeEnvironment)
    (known : ∀ index, first ≤ index → index < first + count →
      (parameter catalog index).typeId ≤ types.length) :
    formalModels catalog first count (types ++ more) = formalModels catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalModels]
      rw [formalModel_prefix _ _ _ (known first (by omega) (by omega)),
        ih (first + 1) (fun index lower upper => known index (by omega) (by omega))]

theorem catalogSignatures_typePrefix {text : Source} (catalog : Metadata)
    (types more : ArrayBindings.TypeEnvironment) (valid : ValidMetadata text catalog)
    (known : ∀ formal ∈ catalog.parameters, formal.typeId ≤ types.length) :
    catalogSignatures catalog (types ++ more) = catalogSignatures catalog types := by
  apply List.map_congr_left
  intro entry member
  have signature := valid.2.2.2 _ member
  apply congrArg (fun formals => (⟨formals⟩ : ScalarProcedures.Signature))
  apply formalModels_typePrefix
  intro index lower upper
  have start := signature.2.2.1
  have within := signature.2.2.2.1
  have length := signature.2.2.2.2
  exact known _ (parameter_mem (by omega) (by omega))

end Silver.ProcedureBindings
