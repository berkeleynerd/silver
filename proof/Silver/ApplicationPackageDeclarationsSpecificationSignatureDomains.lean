module

public import Silver.ApplicationPackageDeclarationsSpecificationDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace SpecificationSignature

private def StartDomain (text : Source) : SignatureStart → Prop
  | .returned result => result.header.position = 0
  | .ready state | .loop state => ValidName text state.item.specName.first state.item.specName.after

private def StepDomain (text : Source) : SignatureStep → Prop
  | .returned result => result.header.position = 0
  | .ready state | .next state => ValidName text state.item.specName.first state.item.specName.after

private def ExitDomain (text : Source) : SignatureExit → Prop
  | .returned result => result.header.position = 0
  | .ready state => ValidName text state.item.specName.first state.item.specName.after

private theorem either {α : Type} (property : α → Prop) (guard : Prop) [Decidable guard]
    {yes no : α} (left : property yes) (right : property no) : property (if guard then yes else no) := by
  split <;> assumption

private theorem body (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : PackageBindings.Metadata) (first last id : Nat) (item : PackageBindings.Routine) (start : Nat)
    (name : ValidName text item.specName.first item.specName.after) :
    StartDomain text (startSignatureBody calls text outer info first last id item start) := by
  dsimp only [startSignatureBody]
  split <;> exact name

private theorem start (text : Source) (outer : ParserState) (info : PackageBindings.Metadata) :
    StartDomain text (signatureStart modelSignatureCalls text outer info false) := by
  let original := skipAt text outer.position
  let functionEnd := tokenAfter text outer.position (.word "function")
  let procedureEnd := tokenAfter text outer.position (.word "procedure")
  let first := skipAt text (if functionEnd ≠ 0 then functionEnd else procedureEnd)
  let last := nameAfter text first
  change StartDomain text (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _)
  split
  · rfl
  · rename_i guarded
    simp only [Bool.false_eq_true, ↓reduceIte]
    apply either (StartDomain text)
    · rfl
    · apply body
      simp only [not_or] at guarded
      exact ⟨Nat.pos_of_ne_zero guarded.2.2.1, Nat.lt_of_not_ge guarded.2.2.2, model_name_valid text _⟩

private theorem finish_formal (calls : SignatureCalls) (text : Source) (before : Nat) (state : SignatureState)
    (name : ValidName text state.item.specName.first state.item.specName.after) :
    StepDomain text (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first | exact name | rfl | apply either (StepDomain text)

private theorem store (calls : SignatureCalls) (text : Source) (before : Nat)
    (state : SignatureState) (first last slot : Nat) (mode : ProcedureBindings.Mode) (mark : PackageTypeResult)
    (name : ValidName text state.item.specName.first state.item.specName.after) :
    StepDomain text (storeFormal calls text false before state first last slot mode mark) := by
  simp only [storeFormal, Bool.false_and, Bool.false_eq_true, ↓reduceIte]
  split
  · assumption
  · exact finish_formal _ _ _ _ name

private theorem step (calls : SignatureCalls) (text : Source) (state : SignatureState)
    (name : ValidName text state.item.specName.first state.item.specName.after) :
    StepDomain text (signatureStep calls text false state) := by
  dsimp only [signatureStep, readFormalName, readFormalType]
  repeat' first
    | rfl
    | assumption
    | exact store _ _ _ _ _ _ _ _ _ name
    | split

private theorem loop {calls text state exit} (exec : SignatureLoop calls text false state exit)
    (name : ValidName text state.item.specName.first state.item.specName.after) : ExitDomain text exit := by
  induction exec with
  | returned parsed =>
    have property := step calls text _ name
    rwa [parsed] at property
  | ready parsed =>
    have property := step calls text _ name
    rwa [parsed] at property
  | next parsed _ tail =>
    have property := step calls text _ name
    rw [parsed] at property
    exact tail property

/-- A successful specification signature installs the original routine name
in the final active routine cell, regardless of the incoming metadata. -/
def ResultDomain (text : Source) (result : SignatureResult) : Prop :=
  result.header.position ≠ 0 → ValidCursor text result.header.position ∧
    ValidName text (result.info.routineAt result.info.routines.length).specName.first
      (result.info.routineAt result.info.routines.length).specName.after

private theorem appended_last (info : PackageBindings.Metadata) (item : PackageBindings.Routine) :
    ({info with routines := info.routines ++ [item]} : PackageBindings.Metadata).routineAt
      (info.routines ++ [item]).length = item := by
  simp [PackageBindings.Metadata.routineAt, List.getD_eq_getElem?_getD]

private theorem successful (text : Source) (info : PackageBindings.Metadata)
    (header : ParserState) (item : PackageBindings.Routine)
    (cursor : ValidCursor text header.position)
    (name : ValidName text item.specName.first item.specName.after) :
    ResultDomain text ⟨{info with routines := info.routines ++ [item]},header⟩ := by
  intro _
  exact ⟨cursor, by simpa only [appended_last] using name⟩

private theorem finish (text : Source) (outer : ParserState) (state : SignatureState)
    (name : ValidName text state.item.specName.first state.item.specName.after) :
    ResultDomain text (finishSignature modelSignatureCalls text outer false state) := by
  cases kind : state.item.kind <;> simp [finishSignature, kind] <;>
    repeat' first
      | split
      | exact fun present => False.elim (present rfl)
      | (apply successful; exact fixedAfter_result_bound text _ ";" false (by decide); exact name)

end SpecificationSignature

theorem readSignature_specification_domain (text : Source) (outer : ParserState) (info : PackageBindings.Metadata) :
    SpecificationSignature.ResultDomain text (readSignature text outer info false) := by
  have initial := SpecificationSignature.start text outer info
  unfold readSignature
  cases entry : signatureStart modelSignatureCalls text outer info false with
  | returned failed =>
    rw [entry] at initial
    exact fun present => False.elim (present initial)
  | ready state =>
    rw [entry] at initial
    exact SpecificationSignature.finish text outer state initial
  | loop state =>
    rw [entry] at initial
    dsimp only
    have final := SpecificationSignature.loop (runSignatureLoop_exec text false state) initial
    cases ending : runSignatureLoop text false state with
    | returned failed =>
      rw [ending] at final
      exact fun present => False.elim (present final)
    | ready result =>
      rw [ending] at final
      exact SpecificationSignature.finish text outer result final

end Silver.ApplicationPackageDeclarations
