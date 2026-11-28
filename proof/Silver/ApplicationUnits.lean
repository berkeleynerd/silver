module

public import Silver.Admission

@[expose] public section

/-! Exact original-unit storage. Positions are one-based and spans are half-open,
as in Silver_Application_Units. Packing inserts no lexical separator; a parser
must use the selected prefix and begin at that unit's first position. These
structural facts do not themselves establish package grammar or source meaning. -/
namespace Silver.ApplicationUnits

inductive UnitKind
  | packageSpecification | packageBody | mainBody
  deriving DecidableEq, Repr

structure Span where
  first : Nat
  after : Nat
  deriving DecidableEq, Repr

structure Bundle where
  pool : Source
  used : Nat
  units : UnitKind → Span

def Fits (specification body main : Source) : Prop :=
  0 < specification.length ∧ 0 < body.length ∧ 0 < main.length ∧
    specification.length + body.length + main.length ≤ maxSourceLength

def fits (specification body main : Source) : Bool :=
  decide (0 < specification.length ∧ 0 < body.length ∧ 0 < main.length ∧
    specification.length + body.length + main.length ≤ maxSourceLength)

@[simp] theorem fits_iff (specification body main : Source) :
    fits specification body main = true ↔ Fits specification body main := by
  simp [fits, Fits]

/-- Native array/subtype representation constraints, separate from Valid's
layout test. No lexical alphabet condition is imposed by byte storage. -/
def Bundle.Representable (sources : Bundle) : Prop :=
  sources.pool.length = maxSourceLength ∧ sources.used ≤ maxSourceLength ∧
    ∀ kind, 1 ≤ (sources.units kind).first ∧
      (sources.units kind).first ≤ maxSourceLength + 1 ∧
      1 ≤ (sources.units kind).after ∧
      (sources.units kind).after ≤ maxSourceLength + 1

def Bundle.Layout (sources : Bundle) : Prop :=
  (sources.units .packageSpecification).first = 1 ∧
    (sources.units .packageSpecification).first < (sources.units .packageSpecification).after ∧
    (sources.units .packageBody).first = (sources.units .packageSpecification).after ∧
    (sources.units .packageBody).first < (sources.units .packageBody).after ∧
    (sources.units .mainBody).first = (sources.units .packageBody).after ∧
    (sources.units .mainBody).first < (sources.units .mainBody).after ∧
    (sources.units .mainBody).after = sources.used + 1

def Bundle.Valid (sources : Bundle) : Prop := sources.Representable ∧ sources.Layout

def Bundle.unitSource (sources : Bundle) (kind : UnitKind) : Source :=
  (sources.pool.drop ((sources.units kind).first - 1)).take
    ((sources.units kind).after - (sources.units kind).first)

def Bundle.prefix (sources : Bundle) (kind : UnitKind) : Source :=
  sources.pool.take ((sources.units kind).after - 1)

def pack (specification body main : Source) : Bundle where
  pool := specification ++ body ++ main ++
    List.replicate (maxSourceLength - (specification.length + body.length + main.length)) 0
  used := specification.length + body.length + main.length
  units
    | .packageSpecification => ⟨1, specification.length + 1⟩
    | .packageBody => ⟨specification.length + 1, specification.length + body.length + 1⟩
    | .mainBody => ⟨specification.length + body.length + 1,
        specification.length + body.length + main.length + 1⟩

theorem pack_valid {specification body main : Source} (fitting : Fits specification body main) :
    (pack specification body main).Valid := by
  rcases fitting with ⟨specPositive, bodyPositive, mainPositive, bounded⟩
  constructor
  · refine ⟨?_, bounded, ?_⟩
    · simp only [pack, List.length_append, List.length_replicate]
      omega
    · intro kind
      cases kind <;> simp only [pack] <;> omega
  · refine ⟨rfl, ?_, rfl, ?_, rfl, ?_, rfl⟩
    · change 1 < specification.length + 1
      omega
    · change specification.length + 1 < specification.length + body.length + 1
      omega
    · change specification.length + body.length + 1 <
        specification.length + body.length + main.length + 1
      omega

@[simp] theorem pack_specification (specification body main : Source) :
    (pack specification body main).unitSource .packageSpecification = specification := by
  simp [Bundle.unitSource, pack]

@[simp] theorem pack_body (specification body main : Source) :
    (pack specification body main).unitSource .packageBody = body := by
  simp [Bundle.unitSource, pack, Nat.add_sub_cancel_left]

@[simp] theorem pack_main (specification body main : Source) :
    (pack specification body main).unitSource .mainBody = main := by
  simp [Bundle.unitSource, pack, Nat.add_sub_cancel_left, List.drop_length_add_append]

theorem pack_originals (specification body main : Source) :
    (pack specification body main).pool.take (pack specification body main).used =
      specification ++ body ++ main := by
  change (specification ++ body ++ main ++ _).take
    (specification.length + body.length + main.length) = _
  simpa only [List.length_append] using
    (List.take_append_length (l₁ := (specification ++ body) ++ main)
      (l₂ := List.replicate (maxSourceLength -
        (specification.length + body.length + main.length)) 0))

theorem pack_padding (specification body main : Source) :
    (pack specification body main).pool.drop (pack specification body main).used =
      List.replicate (maxSourceLength - (pack specification body main).used) 0 := by
  change (specification ++ body ++ main ++ _).drop
    (specification.length + body.length + main.length) = _
  simpa only [List.length_append, pack] using
    (List.drop_append_length (l₁ := (specification ++ body) ++ main)
      (l₂ := List.replicate (maxSourceLength -
        (specification.length + body.length + main.length)) 0))

theorem Bundle.span_bounds {sources : Bundle} (valid : sources.Valid) (kind : UnitKind) :
    1 ≤ (sources.units kind).first ∧
      (sources.units kind).first < (sources.units kind).after ∧
      (sources.units kind).after ≤ sources.used + 1 := by
  have layout := valid.2
  have positive := (valid.1.2.2 kind).1
  cases kind <;> simp only [Layout] at layout <;> omega

theorem Bundle.unitSource_eq_prefix_drop {sources : Bundle} (valid : sources.Valid)
    (kind : UnitKind) :
    sources.unitSource kind = (sources.prefix kind).drop ((sources.units kind).first - 1) := by
  have bounds := sources.span_bounds valid kind
  simp only [unitSource, Bundle.prefix, List.drop_take]
  congr 1
  omega

theorem Bundle.prefix_length {sources : Bundle} (valid : sources.Valid) (kind : UnitKind) :
    (sources.prefix kind).length = (sources.units kind).after - 1 := by
  have bounds := sources.span_bounds valid kind
  have used := valid.1.2.1
  simp only [Bundle.prefix, List.length_take, valid.1.1]
  omega

theorem Bundle.unitSource_length {sources : Bundle} (valid : sources.Valid) (kind : UnitKind) :
    (sources.unitSource kind).length = (sources.units kind).after - (sources.units kind).first := by
  rw [sources.unitSource_eq_prefix_drop valid kind, List.length_drop,
    sources.prefix_length valid kind]
  have bounds := sources.span_bounds valid kind
  omega

theorem Bundle.complete_budget {sources : Bundle} (valid : sources.Valid) :
    (sources.unitSource .packageSpecification).length +
      (sources.unitSource .packageBody).length + (sources.unitSource .mainBody).length = sources.used ∧
      sources.used ≤ maxSourceLength := by
  simp only [sources.unitSource_length valid]
  have layout := valid.2
  have bounds₁ := sources.span_bounds valid .packageSpecification
  have bounds₂ := sources.span_bounds valid .packageBody
  have bounds₃ := sources.span_bounds valid .mainBody
  simp only [Layout] at layout
  exact ⟨by omega, valid.1.2.1⟩

end Silver.ApplicationUnits
