module

public import Silver.ArrayBindingsMetadata
public import Silver.ProcedureBindings
public import Silver.ScalarFunctionTypes

@[expose] public section

/-! Positive formal type identities resolve in the ordered type table visible
at the declaration. Later type and signature entries preserve that result. -/
namespace Silver.Predicate

def formalType (formal : FunctionBindings.Formal) (types : ArrayBindings.TypeEnvironment := []) :
    ScalarFunctions.ScalarType :=
  if formal.typeId ≠ 0 then .array ((ArrayBindings.arrayType types formal.typeId).domain formal.typeId)
  else match formal.kind with
    | .integer => .integer formal.bounds
    | .boolean => .boolean

theorem formalType_domainValid {text : Source} {types : ArrayBindings.TypeEnvironment}
    {formal : FunctionBindings.Formal} (valid : FunctionBindings.ValidFormal text formal)
    (typesValid : ArrayBindings.ValidTypes text types) (known : formal.typeId ≤ types.length) :
    (formalType formal types).Valid := by
  by_cases named : formal.typeId ≠ 0
  · have positive := Nat.pos_of_ne_zero named
    have shape := (typesValid.type_valid positive known).2
    rw [formalType, ite_eq_left named]
    exact ⟨positive, shape.1, shape.2.1, shape.length_bound, shape.2.2.1, shape.2.2.2.1⟩
  · cases kind : formal.kind with
    | integer => simpa only [formalType, named, ↓reduceIte, kind, ScalarFunctions.ScalarType.Valid] using
        (show formal.bounds.Bounded ∧ formal.bounds.lower ≤ formal.bounds.upper from ⟨valid.2.1, valid.2.2.1⟩)
    | boolean => simp [formalType, named, kind, ScalarFunctions.ScalarType.Valid]

def procedureInputFormal (parameter : ProcedureBindings.Formal) : FunctionBindings.Formal :=
  ⟨parameter.first, parameter.after, parameter.kind, parameter.bounds, parameter.typeId⟩

def resultType (entry : FunctionBindings.Signature) : ScalarFunctions.ScalarType :=
  match entry.resultKind with
  | .integer => .integer entry.resultBounds
  | .boolean => .boolean

def formalTypes (catalog : FunctionBindings.Metadata) (first count : Nat)
    (types : ArrayBindings.TypeEnvironment := []) : List ScalarFunctions.ScalarType :=
  match count with
  | 0 => []
  | n + 1 => formalType (FunctionBindings.parameter catalog first) types ::
      formalTypes catalog (first + 1) n types

def signatureModel (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature)
    (types : ArrayBindings.TypeEnvironment := []) : ScalarFunctions.Signature :=
  ⟨formalTypes catalog entry.formalFirst entry.count types, resultType entry⟩

def catalogSignatures (catalog : FunctionBindings.Metadata) (types : ArrayBindings.TypeEnvironment := []) :
    ScalarFunctions.Signatures :=
  catalog.items.map fun entry => signatureModel catalog entry types

theorem catalogSignatures_lookup {catalog : FunctionBindings.Metadata} {index : Nat}
    (positive : 0 < index) (bounded : index ≤ catalog.items.length) {types : ArrayBindings.TypeEnvironment} :
    ScalarFunctions.lookup (catalogSignatures catalog types) index =
      some (signatureModel catalog (FunctionBindings.signature catalog index) types) := by
  have inside : index - 1 < catalog.items.length := by omega
  simp [ScalarFunctions.lookup, catalogSignatures, FunctionBindings.signature,
    Nat.ne_of_gt positive, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside]

theorem formalTypes_append_parameters (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (first count : Nat)
    (positive : 0 < first) (bounded : first + count - 1 ≤ catalog.parameters.length)
    {types : ArrayBindings.TypeEnvironment} :
    formalTypes {catalog with parameters := catalog.parameters ++ more} first count types =
      formalTypes catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalTypes]
      rw [FunctionBindings.parameter_prefix catalog more first positive (by omega),
        ih (first + 1) (by omega) (by omega)]

theorem signatureModel_append_parameters {text : Source} (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (entry : FunctionBindings.Signature)
    (valid : FunctionBindings.ValidSignature text catalog entry) {types : ArrayBindings.TypeEnvironment} :
    signatureModel {catalog with parameters := catalog.parameters ++ more} entry types =
      signatureModel catalog entry types := by
  unfold signatureModel
  rw [formalTypes_append_parameters catalog more entry.formalFirst entry.count valid.2.2.1 (by
    have first := valid.2.2.1
    have bounded := valid.2.2.2.1
    have count := valid.2.2.2.2.1
    omega)]

theorem catalogSignatures_append_parameters {text : Source} (catalog : FunctionBindings.Metadata)
    (more : List FunctionBindings.Formal) (valid : FunctionBindings.ValidMetadata text catalog)
    {types : ArrayBindings.TypeEnvironment} :
    catalogSignatures {catalog with parameters := catalog.parameters ++ more} types =
      catalogSignatures catalog types := by
  apply List.map_congr_left
  intro entry present
  exact signatureModel_append_parameters catalog more entry (valid.2.2.2 entry present)

theorem formalTypes_append (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature)
    (first count : Nat) {types : ArrayBindings.TypeEnvironment} :
    formalTypes (FunctionBindings.append catalog entry) first count types = formalTypes catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalTypes]
      exact congrArg (formalType (FunctionBindings.parameter catalog first) types :: ·) (ih (first + 1))

theorem signatureModel_append (catalog : FunctionBindings.Metadata) (entry value : FunctionBindings.Signature)
    {types : ArrayBindings.TypeEnvironment} :
    signatureModel (FunctionBindings.append catalog entry) value types = signatureModel catalog value types := by
  simp only [signatureModel, formalTypes_append]

theorem catalogSignatures_append (catalog : FunctionBindings.Metadata) (entry : FunctionBindings.Signature)
    {types : ArrayBindings.TypeEnvironment} :
    catalogSignatures (FunctionBindings.append catalog entry) types =
      catalogSignatures catalog types ++ [signatureModel catalog entry types] := by
  simp only [catalogSignatures, FunctionBindings.append, List.map_append, List.map_cons, List.map_nil]
  congr 1
  · apply List.map_congr_left
    intro value _
    exact signatureModel_append catalog entry value
  · exact congrArg (fun value => [value]) (signatureModel_append catalog entry entry)

theorem formalType_prefix (formal : FunctionBindings.Formal) (types more : ArrayBindings.TypeEnvironment)
    (known : formal.typeId ≤ types.length) : formalType formal (types ++ more) = formalType formal types := by
  by_cases named : formal.typeId ≠ 0
  · rw [formalType, formalType, ite_eq_left named, ite_eq_left named,
      ArrayBindings.arrayType_prefix types more formal.typeId (Nat.pos_of_ne_zero named) known]
  · simp [formalType, named]

theorem formalTypes_typePrefix (catalog : FunctionBindings.Metadata) (first count : Nat)
    (types more : ArrayBindings.TypeEnvironment)
    (known : ∀ index, first ≤ index → index < first + count →
      (FunctionBindings.parameter catalog index).typeId ≤ types.length) :
    formalTypes catalog first count (types ++ more) = formalTypes catalog first count types := by
  induction count generalizing first with
  | zero => rfl
  | succ count ih =>
      simp only [formalTypes]
      rw [formalType_prefix _ _ _ (known first (by omega) (by omega)),
        ih (first + 1) (fun index lower upper => known index (by omega) (by omega))]

theorem catalogSignatures_typePrefix {text : Source} (catalog : FunctionBindings.Metadata)
    (types more : ArrayBindings.TypeEnvironment) (valid : FunctionBindings.ValidMetadata text catalog)
    (known : ∀ formal ∈ catalog.parameters, formal.typeId ≤ types.length) :
    catalogSignatures catalog (types ++ more) = catalogSignatures catalog types := by
  apply List.map_congr_left
  intro entry member
  have signature := valid.2.2.2 _ member
  apply congrArg (fun formals => (⟨formals, resultType entry⟩ : ScalarFunctions.Signature))
  apply formalTypes_typePrefix
  intro index lower upper
  have start := signature.2.2.1
  have within := signature.2.2.2.1
  have length := signature.2.2.2.2.1
  exact known _ (FunctionBindings.parameter_mem (by omega) (by omega))

end Silver.Predicate
