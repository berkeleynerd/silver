module

public import Silver.ApplicationPackageCompletingSignature
public import Silver.ApplicationPackageBodyHistory

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackages ApplicationPackageDeclarations
open PackageBindings (Metadata Routine)

def footerName (calls : CompletionCalls) (text : Source) (scan : ApplicationScan) : PackageBindings.NameSpan :=
  let first := calls.skipAt text (calls.takeToken text scan.scan.position (.word "end"))
  ⟨first, calls.nameAfter text first⟩

def footerAfter (calls : CompletionCalls) (text : Source) (scan : ApplicationScan) : Nat :=
  calls.takeToken text (footerName calls text scan).after (.symbol ";")

def finishedItem (item : Routine) (after : Nat) (scan : ApplicationScan) : Routine :=
  {item with bodyAfter := after, mayRead := scan.reads, mayWrite := scan.writes, assigned := scan.scan.assigned}

def finishedInfo (info : Metadata) (index : Nat) (item : Routine) : Metadata :=
  {info with routines := info.routines.set (index - 1) item, completed := index, assigned := info.assigned || item.assigned}

/-- A successful Completion exposes the original tail, optional function
return, exact declared footer and the metadata fields written by that footer. -/
structure CompletionBodyRead (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : Metadata) (index : Nat) (item : Routine) (state : InitializationFrame) (result : CompletionResult) where
  returned : ApplicationScan
  valid : calls.validState text state.frame = true
  dispatchPresent : (completionDispatch calls text info item state).scan.position ≠ 0
  readReturn : completionReturn calls text (completionContextOf calls state) info item
    (completionDispatch calls text info item state) = some returned
  named : calls.sameName text (footerName calls text returned) item.bodyName = true
  advances : globals.position < footerAfter calls text returned
  globalsAfter : result.globals = {globals with position := footerAfter calls text returned}
  stored : result.info = finishedInfo info index (finishedItem item (footerAfter calls text returned) returned)

theorem completion_body_read {calls : CompletionCalls} {text : Source} {globals : ParserState} {info : Metadata}
    {index : Nat} {item : Routine} {state : InitializationFrame} {result : CompletionResult}
    (run : completionBody calls text globals info index item state = result) (present : result.globals.position ≠ 0) :
    Nonempty (CompletionBodyRead calls text globals info index item state result) := by
  dsimp only [completionBody] at run
  split at run
  · rename_i valid
    dsimp only [uncheckedCompletionBody] at run
    split at run
    · cases run; exact False.elim (present rfl)
    · rename_i dispatched
      split at run
      · cases run; exact False.elim (present rfl)
      · rename_i returned read
        dsimp only [completionFooter] at run
        split at run
        · cases run; exact False.elim (present rfl)
        · rename_i checked
          cases run
          exact ⟨⟨returned, valid, dispatched, read, Classical.not_not.mp (fun wrong => checked (Or.inr wrong)),
            Nat.lt_of_not_ge (fun stalled => checked (Or.inl stalled)), rfl, rfl⟩⟩
  · cases run; exact False.elim (present rfl)

private theorem finished_tables {original info : Metadata} (tables : CompletedTables original info)
    (ending : Nat) (scan : ApplicationScan) :
    let id := original.completed + 1
    let item := finishedItem (info.routineAt id) ending scan
    CompletedTables original (finishedInfo info id item) := by
  let id := original.completed + 1
  let item := finishedItem (info.routineAt id) ending scan
  have same : routineDeclaration item = routineDeclaration (info.routineAt id) := rfl
  have updates := SignatureTables.map_set_same routineDeclaration info.routines (id - 1) item {} same
  refine ⟨⟨tables.declared, tables.outside⟩, updates.trans tables.routineDeclarations, ?_⟩
  intro n other
  have away : id - 1 ≠ n := by simpa only [id, Nat.add_one_sub_one] using other.symm
  exact (List.getElem?_set_ne away).trans (tables.otherRoutines n other)

/-- The accepted routine's table write is confined to its original
ordinal. All other routines and the declared fields of both tables survive. -/
theorem CompletionFrames.result_tables {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0) :
    result.info.completed = info.completed + 1 ∧ CompletedTables info result.info := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have tables : CompletedTables info frames.signature.info := signed ▸ readSignature_tables text globals info
  rw [read.stored]
  exact ⟨rfl, finished_tables tables _ _⟩

end Silver.ApplicationPackageBodies
