module

public import Silver.ApplicationPackageDeclarationsExecution

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings

namespace SignatureStates

/-- All metadata visible outside the two tables written by Signature. Clearing
those fields on both sides preserves every other component, including the
function that identifies each original unit span. -/
def unchangedFields (info : Metadata) : Metadata :=
  {info with routines := [], parameters := []}

private def Start (preserved : Metadata) : SignatureStart → Prop
  | .returned result => unchangedFields result.info = preserved
  | .ready state | .loop state => unchangedFields state.info = preserved

private def Step (preserved : Metadata) : SignatureStep → Prop
  | .returned result => unchangedFields result.info = preserved
  | .ready state | .next state => unchangedFields state.info = preserved

private def Exit (preserved : Metadata) : SignatureExit → Prop
  | .returned result => unchangedFields result.info = preserved
  | .ready state => unchangedFields state.info = preserved

private theorem either {α : Type} (meaning : α → Prop) (guard : Prop) [Decidable guard] {yes no : α}
    (left : meaning yes) (right : meaning no) : meaning (if guard then yes else no) := by
  split <;> assumption

private theorem enter_body (calls : SignatureCalls) (text : Source) (outer : ParserState) (info : Metadata)
    (first last id : Nat) (item : Routine) (start : Nat) :
    Start (unchangedFields info) (startSignatureBody calls text outer info first last id item start) := by
  dsimp only [startSignatureBody]
  split <;> rfl

private theorem start (calls : SignatureCalls) (text : Source) (outer : ParserState) (info : Metadata)
    (completing : Bool) : Start (unchangedFields info) (signatureStart calls text outer info completing) := by
  dsimp only [signatureStart]
  repeat' first | rfl | exact enter_body .. | apply either (Start (unchangedFields info))

private theorem finish_formal (calls : SignatureCalls) (text : Source) (before : Nat) (state : SignatureState)
    (preserved : Metadata) (same : unchangedFields state.info = preserved) : Step preserved (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first | exact same | apply either (Step preserved)

private theorem store (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) (mode : ProcedureBindings.Mode)
    (mark : ApplicationPackageNames.PackageTypeResult) (preserved : Metadata) (same : unchangedFields state.info = preserved) :
    Step preserved (storeFormal calls text completing before state first last slot mode mark) := by
  cases completing <;> dsimp only [storeFormal]
  · simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact same | exact finish_formal _ _ _ _ preserved same | apply either (Step preserved)
  · simp only [Bool.true_and, ↓reduceIte]
    repeat' first | exact same | exact finish_formal _ _ _ _ preserved same | apply either (Step preserved)

private theorem step (calls : SignatureCalls) (text : Source) (completing : Bool) (state : SignatureState)
    (preserved : Metadata) (same : unchangedFields state.info = preserved) : Step preserved (signatureStep calls text completing state) := by
  dsimp only [signatureStep, readFormalName, readFormalType]
  repeat' first | exact same | exact store _ _ _ _ _ _ _ _ _ _ preserved same | apply either (Step preserved)

private theorem loop {calls text completing state exit} (exec : SignatureLoop calls text completing state exit)
    (preserved : Metadata) (same : unchangedFields state.info = preserved) : Exit preserved exit := by
  induction exec with
  | returned parsed =>
    have property := step calls text completing _ preserved same
    rwa [parsed] at property
  | ready parsed =>
    have property := step calls text completing _ preserved same
    rwa [parsed] at property
  | next parsed _ tail =>
    have property := step calls text completing _ preserved same
    rw [parsed] at property
    exact tail property

private theorem finish (calls : SignatureCalls) (text : Source) (outer : ParserState) (completing : Bool)
    (state : SignatureState) (preserved : Metadata) (same : unchangedFields state.info = preserved) :
    unchangedFields (finishSignature calls text outer completing state).info = preserved := by
  cases completing <;> dsimp only [finishSignature]
  · simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact same | apply either (fun result : SignatureResult => unchangedFields result.info = preserved)
  · simp only [Bool.true_and, ↓reduceIte]
    repeat' first | exact same | apply either (fun result : SignatureResult => unchangedFields result.info = preserved)

end SignatureStates

/-- Signature writes formal and routine cells. Every exit retains all other
metadata, even when an earlier formal write preceded failure. -/
theorem SignatureExec.retains_fields {calls text outer info completing result}
    (exec : SignatureExec calls text outer info completing result) :
    SignatureStates.unchangedFields result.info = SignatureStates.unchangedFields info := by
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
    have retained := SignatureStates.loop ran (SignatureStates.unchangedFields info) started
    cases exit with
    | returned failed =>
      subst result
      exact retained
    | ready finalState =>
      subst result
      exact SignatureStates.finish _ _ _ _ _ _ retained

theorem SignatureExec.retains_states {calls text outer info completing result}
    (exec : SignatureExec calls text outer info completing result) : result.info.states = info.states := by
  have retained := congrArg Metadata.states exec.retains_fields
  exact retained

theorem SignatureExec.retains_units {calls text outer info completing result}
    (exec : SignatureExec calls text outer info completing result) : result.info.units = info.units := by
  have retained := congrArg Metadata.units exec.retains_fields
  exact retained

theorem readSignature_units (text : Source) (outer : ParserState) (info : Metadata) (completing : Bool) :
    (readSignature text outer info completing).info.units = info.units :=
  (readSignature_exec text outer info completing).retains_units

theorem readSignature_states (text : Source) (outer : ParserState) (info : Metadata) (completing : Bool) :
    (readSignature text outer info completing).info.states = info.states :=
  (readSignature_exec text outer info completing).retains_states

end Silver.ApplicationPackageDeclarations
