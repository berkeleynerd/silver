module

public import Silver.ApplicationPackageRoutineHistory

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose ApplicationUnits ApplicationPackageDeclarations ApplicationPackageObjectRows
open ApplicationAdmission (BodyResult)

private theorem rejected_start {calls : UnitCalls} {text : Source} {exports : ParserState} {info : PackageBindings.Metadata}
    {result : BodyResult} (failed : startUnit calls text exports info = .returned result) : result.accepted = false := by
  dsimp only [startUnit] at failed
  split at failed
  · cases failed; rfl
  · split at failed
    · cases failed; rfl
    · contradiction

private theorem StateObjects.routines {calls : UnitCalls} {text : Source} {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after) : after.phase = .routines := by
  induction history with
  | finished => rfl
  | added _ _ _ _ _ _ _ ih => exact ih

/-- The accepted original unit supplies the object parser results for every
state declaration and a completion frame for every routine in source order. -/
structure BodyHistory (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls) (sources : Bundle)
    (specification : SpecificationResult) (result : BodyResult) where
  entry : UnitState
  objects : List StateObject
  routinesStart : UnitState
  rows : List RoutineRead
  entered : startUnit (bodyReaders reader calls) (sources.prefix .packageBody) specification.exports
    specification.info = .continued entry
  initial : StateEntry sources entry
  declarations : StateObjects (bodyReaders reader calls) (sources.prefix .packageBody) entry objects routinesStart
  completions : RoutineHistory (bodyReaders reader calls) (sources.prefix .packageBody) routinesStart rows result
  states : result.info.states = objects.map (fun row => stateDeclaration row.object)
  layouts : ∀ row ∈ rows, row.before.info.states = result.info.states ∧
    row.SourceLayout reader calls (sources.prefix .packageBody)

private theorem entered_history (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (sources : Bundle) {specification : SpecificationResult} {entry : UnitState} {result : BodyResult}
    (entered : startUnit (bodyReaders reader calls) (sources.prefix .packageBody) specification.exports
      specification.info = .continued entry) (initial : StateEntry sources entry)
    (run : UnitExecution (unitStep (bodyReaders reader calls) (sources.prefix .packageBody)) entry result)
    (accepted : result.accepted = true) : Nonempty (BodyHistory reader calls sources specification result) := by
  obtain ⟨objects, next, decls, tail⟩ := unitExecution_state_objects run accepted initial.objects
  obtain ⟨rows, history⟩ := unitExecution_routines tail accepted decls.routines
  have frame := stateHistory_fields (reader := reader) decls (fun _ _ => rfl) initial.frame
  have size := stateHistory_capacity (reader := reader) decls (fun _ _ => rfl) initial.capacity
  obtain ⟨same, layouts⟩ := history.source_layouts frame size
  refine ⟨⟨entry, objects, next, rows, entered, initial, decls, history, ?_, ?_⟩⟩
  · rw [same, decls.table, initial.empty, List.nil_append]
  · intro row member
    obtain ⟨table, checked⟩ := layouts row member
    exact ⟨table.trans same.symm, checked⟩

theorem original_body_history (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls) (sources : Bundle)
    (valid : sources.Valid) {specification : SpecificationResult} {result : BodyResult} {fuel : Nat}
    (specified : readSpecification reader (sources.prefix .packageSpecification) {units := sources.units} = specification)
    (specificationAccepted : specification.exports.position ≠ 0)
    (body : packageBodyFuel (bodyReaders reader calls) fuel (sources.prefix .packageBody) specification.exports
      specification.info = some result) (accepted : result.accepted = true) :
    Nonempty (BodyHistory reader calls sources specification result) := by
  dsimp only [packageBodyFuel] at body
  split at body
  · rename_i failed returned
    cases body
    have rejected := rejected_start returned
    simp only [accepted, Bool.true_eq_false] at rejected
  · rename_i entry entered
    have header := entered
    dsimp only [bodyReaders] at header
    have initial := source_state_entry reader (readCompletion reader calls) sources valid
      (specification := specification) (state := entry) specified specificationAccepted header
    exact entered_history reader calls sources entered initial (unitFuel_sound body) accepted

end Silver.ApplicationPackageBodies
