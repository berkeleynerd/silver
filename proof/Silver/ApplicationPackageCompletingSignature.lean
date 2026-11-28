module

public import Silver.ApplicationPackageSignatureTables

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings

namespace SignatureTables

private structure Current (original info : Metadata) (item : Routine) (id first : Nat) : Prop where
  formals : FormalTable original info
  routines : info.routines = original.routines
  identity : id = original.completed + 1
  fields : routineDeclaration item = routineDeclaration (completingItem original)
  start : first = (completingItem original).formalFirst

private abbrev Running (original : Metadata) (state : SignatureState) :=
  Current original state.info state.item state.routineId state.formalStart

private def Start (original : Metadata) : SignatureStart → Prop
  | .returned result => CompletedTables original result.info
  | .ready state | .loop state => Running original state

private def Step (original : Metadata) : SignatureStep → Prop
  | .returned result => CompletedTables original result.info
  | .ready state | .next state => Running original state

private def Exit (original : Metadata) : SignatureExit → Prop
  | .returned result => CompletedTables original result.info
  | .ready state => Running original state

private theorem either {α : Type} (property : α → Prop) (test : Prop) [Decidable test] {left right : α}
    (yes : property left) (no : property right) : property (if test then left else right) := by
  split <;> assumption

private theorem enter_body (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (original : Metadata) (first last id : Nat) (item : Routine) (formals : Nat)
    (current : Current original original item id formals) :
    Start original (startSignatureBody calls text outer original first last id item formals) := by
  dsimp only [startSignatureBody]
  split <;> exact current

private theorem start (calls : SignatureCalls) (text : Source) (outer : ParserState) (original : Metadata) :
    Start original (signatureStart calls text outer original true) := by
  dsimp only [signatureStart]
  simp only [↓reduceIte]
  repeat' first
    | exact unchanged_routines (initial original) rfl
    | exact enter_body calls text outer original _ _ _ _ _ ⟨initial original, rfl, rfl, rfl, rfl⟩
    | apply either (Start original)

private theorem finish_formal (calls : SignatureCalls) (text : Source) (before : Nat) (state : SignatureState)
    {original : Metadata} (current : Running original state) : Step original (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first
    | exact current
    | exact unchanged_routines current.formals current.routines
    | apply either (Step original)

private theorem store (calls : SignatureCalls) (text : Source) (before : Nat) (state : SignatureState)
    (first last : Nat) (mode : ProcedureBindings.Mode) (mark : ApplicationPackageNames.PackageTypeResult)
    {original : Metadata} (current : Running original state) (within : state.formalCount < state.item.count) :
    Step original (storeFormal calls text true before state first last (state.formalStart + state.formalCount) mode mark) := by
  have count := congrArg Routine.count current.fields
  change state.item.count = (completingItem original).count at count
  have stored := store_formal current.formals (count ▸ within) state.formalStart current.start ⟨first,last⟩ mark.name
  dsimp only [storeFormal]
  simp only [Bool.true_and, ↓reduceIte]
  split
  · exact unchanged_routines current.formals current.routines
  · split
    · exact unchanged_routines stored current.routines
    · apply finish_formal
      exact ⟨stored, current.routines, current.identity, current.fields, current.start⟩

private theorem iteration (calls : SignatureCalls) (text : Source) (state : SignatureState)
    {original : Metadata} (current : Running original state) : Step original (signatureStep calls text true state) := by
  dsimp only [signatureStep]
  simp only [Bool.true_and, Bool.not_true, Bool.false_and, Bool.or_false, decide_eq_true_eq, ↓reduceIte]
  split
  · exact unchanged_routines current.formals current.routines
  · split
    · exact unchanged_routines current.formals current.routines
    · rename_i inRange
      have within := Nat.lt_of_not_ge inRange
      dsimp only [readFormalName, readFormalType]
      repeat' first
        | exact unchanged_routines current.formals current.routines
        | exact store calls text _ _ _ _ _ _ current within
        | apply either (Step original)

private theorem loop {calls text state exit original} (exec : SignatureLoop calls text true state exit)
    (current : Running original state) : Exit original exit := by
  induction exec with
  | returned parsed =>
    have outcome := iteration calls text _ current
    rwa [parsed] at outcome
  | ready parsed =>
    have outcome := iteration calls text _ current
    rwa [parsed] at outcome
  | next parsed _ tail =>
    have outcome := iteration calls text _ current
    rw [parsed] at outcome
    exact tail outcome

private theorem finish (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (state : SignatureState) {original : Metadata} (current : Running original state) :
    CompletedTables original (finishSignature calls text outer true state).info := by
  have unchanged := unchanged_routines current.formals current.routines
  have written (item : Routine) (fields : routineDeclaration item = routineDeclaration (completingItem original)) :=
    store_routine current.formals current.routines current.identity item fields
  cases kind : state.item.kind <;> dsimp only [finishSignature] <;>
    simp only [Bool.true_and, kind, reduceCtorEq, ↓reduceIte]
  all_goals repeat' first
    | exact unchanged
    | exact written _ current.fields
    | apply either (fun result : SignatureResult => CompletedTables original result.info)
  apply written
  simpa only [routineDeclaration, kind] using current.fields

end SignatureTables

/-- A completing Signature keeps both specification tables and all rows
outside its designated routine and formal segment, including on partial failure. -/
theorem SignatureExec.completing_tables {calls text outer info result}
    (exec : SignatureExec calls text outer info true result) : CompletedTables info result.info := by
  have started := SignatureTables.start calls text outer info
  unfold SignatureExec at exec
  cases entry : signatureStart calls text outer info true with
  | returned failed =>
    simp only [entry] at started exec
    subst result
    exact started
  | ready state =>
    simp only [entry] at started exec
    subst result
    exact SignatureTables.finish calls text outer state started
  | loop state =>
    simp only [entry] at started exec
    obtain ⟨exit, ran, eq⟩ := exec
    have tables := SignatureTables.loop ran started
    cases exit with
    | returned failed => subst result; exact tables
    | ready finalState =>
      subst result
      exact SignatureTables.finish calls text outer finalState tables

theorem readSignature_tables (text : Source) (outer : ParserState) (info : Metadata) :
    CompletedTables info (readSignature text outer info true).info :=
  (readSignature_exec text outer info true).completing_tables

end Silver.ApplicationPackageDeclarations
