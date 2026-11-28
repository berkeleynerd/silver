module

public import Silver.ApplicationUnitsExpressions

@[expose] public section

namespace Silver.ApplicationUnits
open Native

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Each equation is the checked typed body. Fits has no domain premise; the
other premises are precisely native subtype constraints and declared Pre rules.
There is no assumed packing, byte identity, or grammar conclusion. -/
structure InterpretedSource (calls : Calls) : Prop where
  fits : ∀ specification body main,
    calls.fits specification body main = fitsBody.eval ({specification, body, main} : Context).locals
  valid : ∀ sources, sources.Representable →
    calls.valid sources = validBody.eval ({sources} : Context).locals
  unitSpan : ∀ sources, sources.Valid → ∀ kind,
    calls.unitSpan sources kind = unitSpanBody.eval ({sources, kind} : Context).locals
  unitSource : ∀ sources, sources.Valid → ∀ kind,
    calls.unitSource sources kind = unitSourceBody.eval ({sources, kind} : Context).locals
  unitPrefix : ∀ sources, sources.Valid → ∀ kind,
    calls.unitPrefix sources kind = prefixBody.eval ({sources, kind} : Context).locals
  pack : ∀ specification body main, Fits specification.bytes body.bytes main.bytes →
    calls.pack specification body main = packBody.eval ({specification, body, main} : Context).locals

theorem guarded_lengths (specification body main : Nat) :
    (((((decide (specification > 0) && decide (body > 0)) && decide (main > 0)) &&
      decide (specification ≤ maxSourceLength)) && decide (body ≤ maxSourceLength - specification)) &&
      decide (main ≤ maxSourceLength - specification - body)) =
      decide (0 < specification ∧ 0 < body ∧ 0 < main ∧ specification + body + main ≤ maxSourceLength) := by
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc]
  constructor
  · rintro ⟨specPositive, bodyPositive, mainPositive, specBound, bodyBound, mainBound⟩
    exact ⟨specPositive, bodyPositive, mainPositive, by omega⟩
  · rintro ⟨specPositive, bodyPositive, mainPositive, bound⟩
    exact ⟨specPositive, bodyPositive, mainPositive, by omega, by omega, by omega⟩

theorem fitsBody_meaning (specification body main : SourceValue) :
    fitsBody.eval ({specification, body, main} : Context).locals =
      fits specification.bytes body.bytes main.bytes := by
  exact guarded_lengths specification.bytes.length body.bytes.length main.bytes.length

theorem validBody_meaning (sources : Bundle) :
    validBody.eval ({sources} : Context).locals = decide sources.Layout := by
  apply Bool.eq_iff_iff.mpr
  simp only [validBody, Expr.eval, Context.locals, Field.get, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨⟨⟨⟨⟨⟨a, b⟩, c⟩, d⟩, e⟩, f⟩, g⟩
    exact ⟨a, b, c, d, e, f, g⟩
  · intro accepted
    rcases accepted with ⟨a, b, c, d, e, f, g⟩
    exact ⟨⟨⟨⟨⟨⟨a, b⟩, c⟩, d⟩, e⟩, f⟩, g⟩

theorem unitSourceBody_meaning {sources : Bundle} (valid : sources.Valid) (kind : UnitKind) :
    unitSourceBody.eval ({sources, kind} : Context).locals =
      ⟨(sources.units kind).first, sources.unitSource kind⟩ := by
  have bounds := sources.span_bounds valid kind
  simp only [unitSourceBody, unitSpanBody, Expr.eval, Context.locals, Field.get,
    SourceValue.slice, Bundle.unitSource]
  have offset : ((sources.units kind).first - (1 : Int)).toNat = (sources.units kind).first - 1 := by omega
  have length : (sources.units kind).after - 1 + 1 - (sources.units kind).first =
      (sources.units kind).after - (sources.units kind).first := by omega
  rw [offset, length]

theorem prefixBody_meaning {sources : Bundle} (valid : sources.Valid) (kind : UnitKind) :
    prefixBody.eval ({sources, kind} : Context).locals = ⟨1, sources.prefix kind⟩ := by
  have bounds := sources.span_bounds valid kind
  simp only [prefixBody, unitSpanBody, Expr.eval, Context.locals, Field.get,
    SourceValue.slice, Bundle.prefix]
  simp

/-- A slice assignment at the end of a populated prefix preserves those bytes
and replaces only the next segment. Input String bounds never enter this law. -/
theorem replace_padded (front value : Source) (capacity : Nat) :
    (front ++ List.replicate (capacity - front.length) 0).take front.length ++ value ++
      (front ++ List.replicate (capacity - front.length) 0).drop (front.length + value.length) =
      (front ++ value) ++ List.replicate (capacity - (front.length + value.length)) 0 := by
  rw [List.take_append_length, List.drop_length_add_append, List.drop_replicate]
  rw [Nat.sub_sub]

theorem packBody_meaning (specification body main : SourceValue) :
    packBody.eval ({specification, body, main} : Context).locals =
      pack specification.bytes body.bytes main.bytes := by
  simp only [packBody, Command.eval, Expr.eval, Context.locals, Locals.set, reduceCtorEq,
    ↓reduceDIte, ↓reduceIte, String.reduceEq, Nat.add_sub_cancel]
  simp only [writeSlice, Nat.add_sub_cancel, Nat.sub_self, List.take_zero, List.nil_append]
  have first := replace_padded [] specification.bytes maxSourceLength
  simp only [List.nil_append, List.length_nil, Nat.sub_zero, Nat.zero_add, List.take_zero] at first
  rw [first]
  rw [replace_padded specification.bytes body.bytes maxSourceLength]
  have last := replace_padded (specification.bytes ++ body.bytes) main.bytes maxSourceLength
  simp only [List.length_append] at last
  rw [last]
  rfl

theorem interpreted_fits (calls : Calls) (source : InterpretedSource calls)
    (specification body main : SourceValue) :
    calls.fits specification body main = fits specification.bytes body.bytes main.bytes := by
  rw [source.fits, fitsBody_meaning]

theorem interpreted_valid (calls : Calls) (source : InterpretedSource calls)
    (sources : Bundle) (represented : sources.Representable) :
    calls.valid sources = true ↔ sources.Valid := by
  rw [source.valid sources represented, validBody_meaning]
  simp [Bundle.Valid, represented]

theorem interpreted_unitSpan (calls : Calls) (source : InterpretedSource calls)
    (sources : Bundle) (valid : sources.Valid) (kind : UnitKind) :
    calls.unitSpan sources kind = sources.units kind := by
  rw [source.unitSpan sources valid kind]
  rfl

theorem interpreted_unitSource (calls : Calls) (source : InterpretedSource calls)
    (sources : Bundle) (valid : sources.Valid) (kind : UnitKind) :
    calls.unitSource sources kind = ⟨(sources.units kind).first, sources.unitSource kind⟩ := by
  rw [source.unitSource sources valid kind, unitSourceBody_meaning valid]

theorem interpreted_prefix (calls : Calls) (source : InterpretedSource calls)
    (sources : Bundle) (valid : sources.Valid) (kind : UnitKind) :
    calls.unitPrefix sources kind = ⟨1, sources.prefix kind⟩ := by
  rw [source.unitPrefix sources valid kind, prefixBody_meaning valid]

theorem interpreted_pack (calls : Calls) (source : InterpretedSource calls)
    (specification body main : SourceValue) (fitting : Fits specification.bytes body.bytes main.bytes) :
    calls.pack specification body main = pack specification.bytes body.bytes main.bytes := by
  rw [source.pack specification body main fitting, packBody_meaning]

/-- The three writes satisfy the native slice extent constraints over every
fitting input, independently of incoming String lower bounds. -/
theorem packing_slice_extents {specification body main : SourceValue}
    (fitting : Fits specification.bytes body.bytes main.bytes) :
    1 ≤ specification.bytes.length ∧ specification.bytes.length ≤ maxSourceLength ∧
    specification.bytes.length + 1 ≤ specification.bytes.length + body.bytes.length ∧
    specification.bytes.length + body.bytes.length ≤ maxSourceLength ∧
    specification.bytes.length + body.bytes.length + 1 ≤
      specification.bytes.length + body.bytes.length + main.bytes.length ∧
    specification.bytes.length + body.bytes.length + main.bytes.length ≤ maxSourceLength := by
  rcases fitting with ⟨_, _, _, _⟩
  omega

def modelCalls : Calls where
  fits := fun specification body main => fits specification.bytes body.bytes main.bytes
  valid := fun sources => decide sources.Layout
  unitSpan := fun sources kind => sources.units kind
  unitSource := fun sources kind => ⟨(sources.units kind).first, sources.unitSource kind⟩
  unitPrefix := fun sources kind => ⟨1, sources.prefix kind⟩
  pack := fun specification body main => pack specification.bytes body.bytes main.bytes

theorem model_interpreted : InterpretedSource modelCalls where
  fits := fun specification body main => (fitsBody_meaning specification body main).symm
  valid := fun sources _ => (validBody_meaning sources).symm
  unitSpan := fun _ _ _ => rfl
  unitSource := fun _ valid kind => (unitSourceBody_meaning valid kind).symm
  unitPrefix := fun _ valid kind => (prefixBody_meaning valid kind).symm
  pack := fun specification body main _ => (packBody_meaning specification body main).symm

end Silver.ApplicationUnits
