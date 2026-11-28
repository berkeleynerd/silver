module

public import Silver.ApplicationAdmissionPackageDomains
public import Silver.ApplicationPackageUnitHistoryDomains
public import Silver.ApplicationPackageRoutineInitialization
public import Silver.PackageMetadataSemantics

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations ApplicationPackageBodies
open ApplicationPackageObjectRows ApplicationPackageExportRows

private theorem initial_scalars (calls : SpecificationCalls) (text : Source)
    (info : PackageBindings.Metadata) (state : SpecificationState)
    (entered : specificationStart calls text info = .loop state) : state.exports.scalarNames = [] := by
  dsimp only [specificationStart] at entered
  split at entered
  · contradiction
  · split at entered
    · contradiction
    · cases entered
      rfl

private theorem finish_scalars (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState)
    (accepted : (finishSpecification calls text state).exports.position ≠ 0) :
    state.exports.scalarNames = (finishSpecification calls text state).exports.scalarNames := by
  dsimp only [finishSpecification] at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i passed
    rw [ite_eq_right passed]

/-- Recover the original specification's complete raw declaration inventory,
its empty initial scalar frame and its returned scalar identities. Successful
checking and every initializer obligation are derived from the original pass. -/
theorem original_specification_inventory (reader : BooleanElaboration.Native.Reader)
    (text : Source) (valid : ValidText text) (seed : PackageBindings.Metadata)
    {result : SpecificationResult} (read : readSpecification reader text seed = result)
    (accepted : result.exports.position ≠ 0) :
    ∃ first last rows,
      specificationStart (modelSpecificationCalls reader) text seed = .loop first ∧
      ReaderFrame text first.exports ∧ FrameOrder first.exports ∧ first.exports.scalarNames = [] ∧
      SpecificationInventories reader text first rows (.ready last) ∧
      last.exports.scalarNames = result.exports.scalarNames ∧
      Predicate.discharged (specificationObligations text rows) = true := by
  have entered := start_rows (modelSpecificationCalls reader) text seed
  have exec := readSpecification_exec reader text seed
  rw [read] at exec
  unfold SpecificationExec at exec
  cases started : specificationStart (modelSpecificationCalls reader) text seed with
  | returned failed =>
    simp only [started] at exec entered
    exact False.elim (accepted (exec ▸ entered))
  | loop first =>
    simp only [started] at exec entered
    have framed := specification_start_framed reader text seed
    rw [started] at framed
    obtain ⟨exit, loop, finished⟩ := exec
    have reached := loop_rows loop entered
    cases exit with
    | returned failed =>
      exact False.elim (accepted (finished ▸ reached))
    | ready last =>
      dsimp only at finished
      obtain ⟨rows, source, discharged⟩ := specification_loop_inventory reader valid framed loop
      have finalAccepted : (finishSpecification (modelSpecificationCalls reader) text last).exports.position ≠ 0 :=
        finished ▸ accepted
      have same := finish_scalars (modelSpecificationCalls reader) text last finalAccepted
      rw [← finished] at same
      exact ⟨first, last, rows, rfl, framed, entered.order,
        initial_scalars _ _ _ _ started, source, same, discharged⟩

/-- The original BodyHistory retains every raw state initializer. These
checks are distinct from the normalized initial cells used during execution. -/
theorem BodyHistory.state_inventory (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {sources : ApplicationUnits.Bundle}
    {specification : SpecificationResult} {result : ApplicationAdmission.BodyResult}
    (history : BodyHistory reader
      (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)) sources specification result)
    (valid : ValidText (sources.prefix .packageBody))
    (framed : ReaderFrame (sources.prefix .packageBody) specification.exports)
    (typed : specification.info.Typed) :
    ∃ entries : List (StateObject × ObjectSyntax), entries.map Prod.fst = history.objects ∧
      (∀ entry ∈ entries, entry.2.SourceAt (sources.prefix .packageBody)
        entry.1.before.globals entry.1.before.info false entry.1.object) ∧
      Predicate.discharged (entries.flatMap (stateObjectObligations (sources.prefix .packageBody))) = true := by
  have initial := unit_start_domain reader _ valid specification.exports framed specification.info typed history.entered
  exact (state_objects_inventory valid initial.frame history.declarations (fun _ _ => rfl)).2

end Silver.ApplicationPackageInitializers
