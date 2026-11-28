module

public import Silver.ApplicationPackageCompletionLayout

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose ApplicationPackageDeclarations

/-- The original completion prefix fixes the routine ordinal before Signature
writes its body fields. All following passes use the returned metadata and the
same ordered formal segment. -/
structure CompletionFrames (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (result : CompletionResult) where
  signature : SignatureResult
  entry : ParserState
  locals : InitializationFrame
  objects : List LocalObject
  signed : calls.signatureAt text globals info true = signature
  headerPresent : signature.header.position ≠ 0
  entered : calls.routineFrame text globals signature.info (info.completed + 1) signature.header.position = entry
  entryPresent : entry.position ≠ 0
  declarations : LocalObjects calls text signature.info (signature.info.routineAt (info.completed + 1))
    {frame := entry} objects locals
  outputs : OutputFrames calls text signature.info (signature.info.routineAt (info.completed + 1)) locals
  executed : completionBody calls text globals signature.info (info.completed + 1)
    (signature.info.routineAt (info.completed + 1)) outputs.body = result

theorem packageCompletionFuel_frames {calls : CompletionCalls} {fuel : Nat} {text : Source}
    {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (read : packageCompletionFuel calls fuel text globals info = some result) (present : result.globals.position ≠ 0) :
    Nonempty (CompletionFrames calls text globals info result) := by
  dsimp only [packageCompletionFuel] at read
  split at read
  · cases read; exact False.elim (present rfl)
  · split at read
    · cases read; exact False.elim (present rfl)
    · rename_i header
      split at read
      · cases read; exact False.elim (present rfl)
      · split at read
        · cases read; exact False.elim (present rfl)
        · rename_i entry
          dsimp only [completionLocals] at read
          obtain ⟨outcome, localRun, finished⟩ := Option.map_eq_some_iff.mp read
          cases outcome with
          | none => cases finished; exact False.elim (present rfl)
          | some locals =>
            obtain ⟨objects, declarations⟩ := localsFuel_objects localRun
            obtain ⟨outputs, executed⟩ := completionOutputs_frames finished present
            exact ⟨⟨_, _, locals, objects, rfl, header, rfl, entry, declarations, outputs, executed⟩⟩

theorem completionBody_globals {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {index : Nat} {item : PackageBindings.Routine} {state : InitializationFrame}
    {result : CompletionResult} (read : completionBody calls text globals info index item state = result)
    (present : result.globals.position ≠ 0) :
    result.globals = {globals with position := result.globals.position} ∧
      globals.position < result.globals.position ∧ result.info.states = info.states := by
  dsimp only [completionBody] at read
  split at read
  · dsimp only [uncheckedCompletionBody] at read
    split at read
    · cases read; exact False.elim (present rfl)
    · split at read
      · cases read; exact False.elim (present rfl)
      · dsimp only [completionFooter] at read
        split at read
        · cases read; exact False.elim (present rfl)
        · rename_i advanced
          cases read
          exact ⟨rfl, Nat.lt_of_not_ge (fun earlier => advanced (Or.inl earlier)), rfl⟩
  · cases read; exact False.elim (present rfl)

end Silver.ApplicationPackageBodies
