module

public import Silver.ApplicationUnitsEquations
public import Silver.ApplicationUnitsSourceChecks

@[expose] public section

/-! Actual-source exact storage: native Fits is total on arbitrary input lengths,
and the ordinary Pack tree preserves each original byte sequence and padding.
Unit_Source retains global bounds; Prefix starts at one and ends at the selected
unit. This is a storage result, independent of application grammar and safety. -/
namespace Silver.ApplicationUnits.SourceBridge
open Native

theorem actual_source_correspondence : CheckedSource ∧
    (∀ calls, InterpretedSource calls → ∀ specification body main,
      calls.fits specification body main = fits specification.bytes body.bytes main.bytes) ∧
    (∀ calls, InterpretedSource calls → ∀ sources, sources.Representable →
      (calls.valid sources = true ↔ sources.Valid)) ∧
    (∀ calls, InterpretedSource calls → ∀ specification body main,
      Fits specification.bytes body.bytes main.bytes →
      calls.pack specification body main = pack specification.bytes body.bytes main.bytes) := by
  exact ⟨checked_source, interpreted_fits, interpreted_valid, interpreted_pack⟩

theorem original_units (calls : Calls) (source : InterpretedSource calls)
    (specification body main : SourceValue)
    (fitting : Fits specification.bytes body.bytes main.bytes) :
    let sources := calls.pack specification body main
    sources.Valid ∧
    (calls.unitSource sources .packageSpecification).bytes = specification.bytes ∧
    (calls.unitSource sources .packageBody).bytes = body.bytes ∧
    (calls.unitSource sources .mainBody).bytes = main.bytes ∧
    sources.pool.drop sources.used = List.replicate (maxSourceLength - sources.used) 0 := by
  dsimp only
  rw [interpreted_pack calls source specification body main fitting]
  have valid := pack_valid fitting
  refine ⟨valid, ?_, ?_, ?_, pack_padding _ _ _⟩
  · rw [interpreted_unitSource calls source _ valid .packageSpecification]
    exact pack_specification _ _ _
  · rw [interpreted_unitSource calls source _ valid .packageBody]
    exact pack_body _ _ _
  · rw [interpreted_unitSource calls source _ valid .mainBody]
    exact pack_main _ _ _

theorem original_bounds (calls : Calls) (source : InterpretedSource calls)
    (sources : Bundle) (valid : sources.Valid) (kind : UnitKind) :
    (calls.unitSource sources kind).first = (sources.units kind).first ∧
    (calls.unitSource sources kind).last = (sources.units kind).after - (1 : Int) ∧
    (calls.unitPrefix sources kind).first = 1 ∧
    (calls.unitPrefix sources kind).last = (sources.units kind).after - (1 : Int) ∧
    (calls.unitSource sources kind).bytes =
      (calls.unitPrefix sources kind).bytes.drop ((sources.units kind).first - 1) := by
  rw [interpreted_unitSource calls source sources valid kind,
    interpreted_prefix calls source sources valid kind]
  have bounds := sources.span_bounds valid kind
  simp only [SourceValue.last, sources.unitSource_length valid kind, sources.prefix_length valid kind]
  refine ⟨trivial, by omega, trivial, by omega, sources.unitSource_eq_prefix_drop valid kind⟩

theorem model_interpreted : InterpretedSource modelCalls := ApplicationUnits.model_interpreted

end Silver.ApplicationUnits.SourceBridge
