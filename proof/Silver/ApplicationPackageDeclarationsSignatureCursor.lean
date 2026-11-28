module

public import Silver.ApplicationPackageDeclarationsSignatureLoopImports

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace SignatureCursor

private def Start : SignatureStart → Prop
  | .returned result => result.header.position = 0
  | .ready _ | .loop _ => True

private def Step : SignatureStep → Prop
  | .returned result => result.header.position = 0
  | .ready _ | .next _ => True

private def Exit : SignatureExit → Prop
  | .returned result => result.header.position = 0
  | .ready _ => True

private theorem start (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (completing : Bool) :
    Start (signatureStart calls text outer info completing) := by
  dsimp only [signatureStart, startSignatureBody]
  repeat' first | rfl | trivial | split

private theorem finish_formal (calls : SignatureCalls) (text : Source) (before : Nat)
    (state : SignatureState) : Step (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first | rfl | trivial | split

private theorem store (calls : SignatureCalls) (text : Source) (completing : Bool) (before : Nat)
    (state : SignatureState) (first last slot : Nat) (mode : ProcedureBindings.Mode)
    (mark : PackageTypeResult) :
    Step (storeFormal calls text completing before state first last slot mode mark) := by
  dsimp only [storeFormal]
  split
  · rfl
  · split
    · assumption
    · exact finish_formal _ _ _ _

private theorem step (calls : SignatureCalls) (text : Source) (completing : Bool)
    (state : SignatureState) : Step (signatureStep calls text completing state) := by
  dsimp only [signatureStep, readFormalName, readFormalType]
  repeat' first | rfl | assumption | exact store _ _ _ _ _ _ _ _ _ _ | split

private theorem loop {calls text completing state result}
    (run : SignatureLoop calls text completing state result) : Exit result := by
  induction run with
  | @returned state _ parsed =>
    have property := step calls text completing state
    rwa [parsed] at property
  | ready => trivial
  | next _ _ ih => exact ih

private theorem result_if {text : Source} (condition : Prop) [Decidable condition]
    (yes no : SignatureResult) (left : ValidCursor text yes.header.position)
    (right : ValidCursor text no.header.position) :
    ValidCursor text (if condition then yes else no).header.position := by
  split <;> assumption

private theorem after_type (text : Source) (outer : ParserState) (completing : Bool)
    (state : SignatureState) (item : PackageBindings.Routine) (mark : PackageTypeResult) :
    ValidCursor text (signatureAfterType modelSignatureCalls text outer completing state item mark).header.position := by
  dsimp only [signatureAfterType]
  apply result_if
  · exact Nat.zero_le _
  · apply result_if
    · exact Nat.zero_le _
    · apply result_if
      · exact Nat.zero_le _
      · cases completing
        · exact fixedAfter_result_bound text _ ";" false (by decide)
        · exact fixedAfter_result_bound text _ "is" true (by decide)

private theorem finish (text : Source) (outer : ParserState) (completing : Bool)
    (state : SignatureState) :
    ValidCursor text (finishSignature modelSignatureCalls text outer completing state).header.position := by
  rw [finishSignature_afterType]
  apply result_if
  · exact Nat.zero_le _
  · exact after_type text outer completing state _ _

end SignatureCursor

/-- Every Signature result has a native source cursor, including partial-write
failures. The bound follows from its original failure and final-token branches;
no input-frame or metadata-validity premise is required. -/
theorem readSignature_header_cursor (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (completing : Bool) :
    ValidCursor text (readSignature text outer info completing).header.position := by
  have started := SignatureCursor.start modelSignatureCalls text outer info completing
  unfold readSignature
  cases entry : signatureStart modelSignatureCalls text outer info completing with
  | returned result =>
    rw [entry] at started
    change result.header.position ≤ text.length + 1
    rw [started]
    exact Nat.zero_le _
  | ready state => exact SignatureCursor.finish text outer completing state
  | loop state =>
    dsimp only
    have ended := SignatureCursor.loop (runSignatureLoop_exec text completing state)
    cases ending : runSignatureLoop text completing state with
    | returned result =>
      rw [ending] at ended
      change result.header.position ≤ text.length + 1
      rw [ended]
      exact Nat.zero_le _
    | ready state => exact SignatureCursor.finish text outer completing state

end Silver.ApplicationPackageDeclarations
