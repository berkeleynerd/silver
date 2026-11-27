module

public import Silver.ApplicationPackageDeclarationsExecution

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings

namespace SignatureStates

private abbrev Rows := List StateDeclaration

private def Start (rows : Rows) : SignatureStart → Prop
  | .returned result => result.info.states = rows
  | .ready state | .loop state => state.info.states = rows

private def Step (rows : Rows) : SignatureStep → Prop
  | .returned result => result.info.states = rows
  | .ready state | .next state => state.info.states = rows

private def Exit (rows : Rows) : SignatureExit → Prop
  | .returned result => result.info.states = rows
  | .ready state => state.info.states = rows

private theorem either {α : Type} (meaning : α → Prop) (guard : Prop) [Decidable guard] {yes no : α}
    (left : meaning yes) (right : meaning no) : meaning (if guard then yes else no) := by
  split <;> assumption

private theorem enter_body (calls : SignatureCalls) (text : Source) (outer : ParserState) (info : Metadata)
    (first last id : Nat) (item : Routine) (start : Nat) :
    Start info.states (startSignatureBody calls text outer info first last id item start) := by
  dsimp only [startSignatureBody]
  split <;> rfl

private theorem start (calls : SignatureCalls) (text : Source) (outer : ParserState) (info : Metadata)
    (completing : Bool) : Start info.states (signatureStart calls text outer info completing) := by
  dsimp only [signatureStart]
  repeat' first | rfl | exact enter_body .. | apply either (Start info.states)

private theorem finish_formal (calls : SignatureCalls) (text : Source) (before : Nat) (state : SignatureState)
    (rows : Rows) (same : state.info.states = rows) : Step rows (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first | exact same | apply either (Step rows)

private theorem store (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) (mode : ProcedureBindings.Mode)
    (mark : ApplicationPackageNames.PackageTypeResult) (rows : Rows) (same : state.info.states = rows) :
    Step rows (storeFormal calls text completing before state first last slot mode mark) := by
  cases completing <;> dsimp only [storeFormal]
  · simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact same | exact finish_formal _ _ _ _ rows same | apply either (Step rows)
  · simp only [Bool.true_and, ↓reduceIte]
    repeat' first | exact same | exact finish_formal _ _ _ _ rows same | apply either (Step rows)

private theorem step (calls : SignatureCalls) (text : Source) (completing : Bool) (state : SignatureState)
    (rows : Rows) (same : state.info.states = rows) : Step rows (signatureStep calls text completing state) := by
  dsimp only [signatureStep, readFormalName, readFormalType]
  repeat' first | exact same | exact store _ _ _ _ _ _ _ _ _ _ rows same | apply either (Step rows)

private theorem loop {calls text completing state exit} (exec : SignatureLoop calls text completing state exit)
    (rows : Rows) (same : state.info.states = rows) : Exit rows exit := by
  induction exec with
  | returned parsed =>
    have property := step calls text completing _ rows same
    rwa [parsed] at property
  | ready parsed =>
    have property := step calls text completing _ rows same
    rwa [parsed] at property
  | next parsed _ tail =>
    have property := step calls text completing _ rows same
    rw [parsed] at property
    exact tail property

private theorem finish (calls : SignatureCalls) (text : Source) (outer : ParserState) (completing : Bool)
    (state : SignatureState) (rows : Rows) (same : state.info.states = rows) :
    (finishSignature calls text outer completing state).info.states = rows := by
  cases completing <;> dsimp only [finishSignature]
  · simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact same | apply either (fun result : SignatureResult => result.info.states = rows)
  · simp only [Bool.true_and, ↓reduceIte]
    repeat' first | exact same | apply either (fun result : SignatureResult => result.info.states = rows)

end SignatureStates

/-- Signature writes formal and routine cells. Every exit retains the exact
state declaration table, even when an earlier formal write preceded failure. -/
theorem SignatureExec.retains_states {calls text outer info completing result}
    (exec : SignatureExec calls text outer info completing result) : result.info.states = info.states := by
  have started := SignatureStates.start calls text outer info completing
  unfold SignatureExec at exec
  cases entry : signatureStart calls text outer info completing with
  | returned failed =>
    simp only [entry] at started exec
    subst result
    exact started
  | ready state =>
    simp only [entry] at started exec
    subst result
    exact SignatureStates.finish _ _ _ _ _ _ started
  | loop state =>
    simp only [entry] at started exec
    obtain ⟨exit, ran, eq⟩ := exec
    have rows := SignatureStates.loop ran info.states started
    cases exit with
    | returned failed =>
      subst result
      exact rows
    | ready finalState =>
      subst result
      exact SignatureStates.finish _ _ _ _ _ _ rows

theorem readSignature_states (text : Source) (outer : ParserState) (info : Metadata) (completing : Bool) :
    (readSignature text outer info completing).info.states = info.states :=
  (readSignature_exec text outer info completing).retains_states

end Silver.ApplicationPackageDeclarations
