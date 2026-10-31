module

public import Silver.PredicateStringBoundsExecution

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

/-- Source membership supplies the actual name metadata and origin alignment,
and concrete endpoint certificates refining the retained source schemas. -/
structure SourceBoundsRefinement (source : Source) (program : Program) : Prop where
  header : HeaderBoundsFacts program
  sourceRegion : ∃ form before after strings, HeaderRegionFacts source program form before after strings
  declarationCertificates : ∀ schema,
    Check.declaration (.range schema) ∈ program.checks →
    ∃ certificate : StringBoundsObligation,
      certificate.bindingCount = program.names.length ∧ certificate.length = .declaration schema ∧
      (Check.stringBounds certificate).Refines (.declaration (.range schema)) ∧ certificate.Valid
  pathCertificates : ∀ context summary,
    Check.path (.stringRange context summary) ∈ program.checks →
    ∃ certificate : StringBoundsObligation,
      certificate.bindingCount = program.names.length ∧ certificate.length = .path context summary ∧
      (Check.stringBounds certificate).Refines (.path (.stringRange context summary)) ∧ certificate.Valid

theorem source_bounds_refinement {source program} (meaning : SourceMeaning source program) :
    SourceBoundsRefinement source program := by
  have header := source_header_bounds_facts meaning
  have valid := meaning_valid meaning
  refine ⟨header, source_header_region meaning, ?_, ?_⟩
  · intro schema present
    let certificate : StringBoundsObligation := ⟨program.names.length, .declaration schema⟩
    have refined : (Check.stringBounds certificate).Refines (.declaration (.range schema)) :=
      ⟨header.count, _, rfl, Nat.le_refl _, Nat.le_refl _⟩
    exact ⟨certificate, rfl, rfl, refined,
      Check.fragment_valid (Check.fragment_of_refines refined (Program.checks_fragment valid _ present))⟩
  · intro context summary present
    let certificate : StringBoundsObligation := ⟨program.names.length, .path context summary⟩
    have refined : (Check.stringBounds certificate).Refines (.path (.stringRange context summary)) :=
      ⟨header.count, rfl⟩
    exact ⟨certificate, rfl, rfl, refined,
      Check.fragment_valid (Check.fragment_of_refines refined (Program.checks_fragment valid _ present))⟩

/-- All raw source initializers and every reached body expression, including
all source-order-preserving groupings and all loop iterations. -/
def Program.StringBoundsSafe (source : Source) (program : Program)
    (arguments : Arguments.Runtime.Arguments) : Prop :=
  RawInitializersBoundsSafe source program arguments ∧
    StatementsObjectBoundsSafe program.names (program.input arguments) (program.inputValid arguments)
      (program.initialValues arguments) program.statements program.initialIntegers (program.initialBooleans arguments)

theorem source_string_bounds_assured {source program} (meaning : SourceMeaning source program) :
    SourceBoundsRefinement source program ∧ ∀ arguments, program.StringBoundsSafe source arguments := by
  have valid := meaning_valid meaning
  have refinement := source_bounds_refinement meaning
  have header := refinement.header
  have certificates : RawBooleanBoundsCertificates program program.names
      (statementsObligations program.names.shape program.bodyAnalysis program.initialFlow
        program.statements program.bodyBooleanAnalysis) := by
    intro context summary member
    have present : Check.path (.stringRange context summary) ∈ program.checks :=
      List.mem_append_right _ (List.mem_map.mpr ⟨_, member, rfl⟩)
    obtain ⟨certificate, count, length, refined, safe⟩ := refinement.pathCertificates context summary present
    exact ⟨certificate, count, length, present, refined, safe⟩
  refine ⟨refinement, ?_⟩
  intro arguments
  refine ⟨source_raw_initializers_bounds meaning arguments, ?_⟩
  obtain ⟨after, checked, _⟩ := valid.2.2.2.2.2
  have bodyChecked := ((program.checkBody_iff after).mp checked).2.2.2
  exact statements_objectBoundsSafe header.count header.metadata header.statements valid.2.2.2.2.1 bodyChecked
    (program.initial_fits valid arguments) (program.input_domain arguments).2
    ⟨program.initial_allowed arguments, program.initial_integer_fits valid⟩ (program.initial_integer_fits valid)
    certificates

end Silver.Predicate
