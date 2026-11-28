module

public import Silver.ApplicationPackageCompletionSourceLayout

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFormalStorage

private theorem local_bound {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {before after : InitializationFrame}
    (window : (calls.objectAt text before.frame info true).frame.position ≤ text.length + 1)
    (continued : localStep calls text info item before = .continued after) : after.frame.position ≤ text.length + 1 := by
  dsimp only [localStep] at continued
  split at continued
  · contradiction
  · split at continued
    · contradiction
    · split at continued
      · contradiction
      · cases continued
        exact window

private theorem completion_total (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata)
    (headerBound : let signed := calls.signatureAt text globals info true
      signed.header.position ≠ 0 → signed.header.position ≤ text.length + 1)
    (entryBound : ∀ data index position, position ≤ text.length + 1 →
      let entry := calls.routineFrame text globals data index position
      entry.position ≠ 0 → entry.position ≤ text.length + 1)
    (objectsBounded : ∀ frame data, (calls.objectAt text frame data true).frame.position ≤ text.length + 1) :
    ∃ result, packageCompletionFuel calls (text.length + 2) text globals info = some result := by
  dsimp only [packageCompletionFuel]
  split
  · exact ⟨_, rfl⟩
  · split
    · exact ⟨_, rfl⟩
    · rename_i hasHeader
      split
      · exact ⟨_, rfl⟩
      · split
        · exact ⟨_, rfl⟩
        · rename_i hasFrame
          have bounded := entryBound _ _ _ (headerBound hasHeader) hasFrame
          dsimp only [completionLocals]
          obtain ⟨result, read⟩ := localsFuel_total
            (valid := fun state => state.frame.position ≤ text.length + 1) (limit := text.length + 1)
            (fun _ legal => legal) (fun state next _ advanced => local_bound (objectsBounded state.frame _) advanced)
            (state := {frame := calls.routineFrame text globals _ _ _}) (fuel := text.length + 2) bounded (by omega)
          rw [read]
          exact ⟨_, rfl⟩

/-- Totality holds even on a rejected Signature or Object. The sufficient
fuel counts the original text cursor, independently of accepted program size. -/
theorem declarationCompletion_total (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) :
    ∃ result, packageCompletionFuel (declarationReaders reader calls) (text.length + 2) text globals info = some result := by
  apply completion_total
  · dsimp only
    intro present
    exact (readSignature_completed_order text globals info present).bounded
  · intro data index position bounded
    dsimp only
    intro present
    obtain ⟨hidden, kept, stored⟩ := routineFrame_tables (calls := routineFrameReaders)
      (text := text) (globals := globals) (info := data) (routine := index) (position := position)
      rfl rfl rfl present
    have same := stored.position.trans kept.position
    exact Nat.le_trans (Nat.le_of_eq same) bounded
  · intro frame data
    by_cases present : (objectStep (modelObjectCalls reader) text frame data true).frame.position = 0
    · change (objectStep (modelObjectCalls reader) text frame data true).frame.position ≤ _
      rw [present]; exact Nat.zero_le _
    · exact (objectStep_positions reader text frame data true present).2.2.2

def readCompletion (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) : CompletionResult :=
  (packageCompletionFuel (declarationReaders reader calls) (text.length + 2) text globals info).get
    (Option.isSome_iff_exists.mpr (declarationCompletion_total reader calls text globals info))

theorem readCompletion_eq (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    (text : Source) (globals : ParserState) (info : PackageBindings.Metadata) :
    packageCompletionFuel (declarationReaders reader calls) (text.length + 2) text globals info =
      some (readCompletion reader calls text globals info) :=
  (Option.some_get _).symm

end Silver.ApplicationPackageBodies
