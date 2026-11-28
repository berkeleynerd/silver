module

public import Silver.ApplicationPackageDeclarationsFormalIteration

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions PackageBindings ApplicationPackageNames

namespace FormalSpanRead
open ApplicationPackageObjectRows

private def Start (text : Source) (lower id : Nat) : SignatureStart → Prop
  | .returned result => Returned text lower id result
  | .ready state | .loop state => At text lower id state.header.position state

private theorem begin_body (text : Source) (outer : ParserState) (info : Metadata)
    (first last id : Nat) (item : Routine)
    (entered : outer.position ≤ last) (bounded : last ≤ text.length + 1)
    (identity : id - 1 < info.routines.length)
    (slots : ∀ i, i < item.count → 0 < item.formalFirst ∧ item.formalFirst + i ≤ info.parameters.length) :
    Start text outer.position id
      (startSignatureBody modelSignatureCalls text outer info first last id item item.formalFirst) := by
  have prior : Progress text outer.position id last info item id item.formalFirst 0 :=
    ⟨entered, bounded, rfl, identity, rfl, slots, BodyFormalOrder.empty ..⟩
  dsimp only [startSignatureBody]
  split
  · exact prior
  · rename_i opened
    have window := fixed_window (by decide) (show fixedAfter text last "(" false ≠ 0 from opened)
    exact prior.advance (Nat.le_of_lt window.1) window.2

private def keywordEnd (text : Source) (position : Nat) : Nat :=
  let functionEnd := fixedAfter text position "function" true
  if functionEnd ≠ 0 then functionEnd else fixedAfter text position "procedure" true

private theorem name_window {text : Source} {position : Nat}
    (present : skipAt text (keywordEnd text position) ≠ 0)
    (named : skipAt text (keywordEnd text position) < nameAfter text (skipAt text (keywordEnd text position))) :
    position ≤ nameAfter text (skipAt text (keywordEnd text position)) ∧
      nameAfter text (skipAt text (keywordEnd text position)) ≤ text.length + 1 := by
  have consumed : keywordEnd text position ≠ 0 := fun empty => present (by simp [empty, skipAt])
  have window : position < keywordEnd text position ∧ keywordEnd text position ≤ text.length + 1 := by
    unfold keywordEnd at consumed ⊢
    by_cases found : fixedAfter text position "function" true ≠ 0
    · rw [ite_eq_left found]
      exact fixed_window (by decide) found
    · rw [ite_eq_right found] at consumed ⊢
      exact fixed_window (by decide) consumed
  have skipped := skipAt_advances text _ window.2 present
  exact ⟨Nat.le_of_lt (Nat.lt_trans window.1 (Nat.lt_of_le_of_lt skipped named)), model_name_valid text _⟩

private theorem range_slots {first count length : Nat}
    (valid : ¬(count > 0 ∧ (first = 0 ∨ first > length ∨ count > length - first + 1))) :
    ∀ i, i < count → 0 < first ∧ first + i ≤ length := by
  intro i below
  omega

private theorem start (text : Source) (outer : ParserState) (info : Metadata) :
    Start text outer.position (info.completed + 1) (signatureStart modelSignatureCalls text outer info true) := by
  let first := skipAt text (keywordEnd text outer.position)
  let last := nameAfter text first
  let item := info.routineAt (info.completed + 1)
  let invalidHead := skipAt text outer.position = 0 ∨
      (fixedAfter text outer.position "function" true = 0 ∧ fixedAfter text outer.position "procedure" true = 0) ∨
      first = 0 ∨ last ≤ first
  let invalidRange := item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
    item.count > info.parameters.length - item.formalFirst + 1)
  let mismatched := !modelSignatureCalls.sameName text item.specName ⟨first,last⟩ ||
    (decide (item.kind = .function) != decide (fixedAfter text outer.position "function" true ≠ 0))
  let updated := {item with bodyName := ⟨first,last⟩, bodyFirst := skipAt text outer.position}
  change Start text outer.position (info.completed + 1)
    (if invalidHead then .returned (rejectedSignature info)
     else if info.completed ≥ info.routines.length then .returned (rejectedSignature info)
     else if invalidRange then .returned (rejectedSignature info)
     else if mismatched then .returned (rejectedSignature info)
     else startSignatureBody modelSignatureCalls text outer info first last (info.completed + 1) updated item.formalFirst)
  by_cases head : invalidHead
  · rw [ite_eq_left head]
    exact rejected rfl
  · rw [ite_eq_right head]
    have present : first ≠ 0 := fun empty => head (.inr (.inr (.inl empty)))
    have named := name_window present (Nat.lt_of_not_ge (fun bad => head (.inr (.inr (.inr bad)))))
    by_cases exhausted : info.completed ≥ info.routines.length
    · rw [ite_eq_left exhausted]
      exact rejected rfl
    · rw [ite_eq_right exhausted]
      by_cases bad : invalidRange
      · rw [ite_eq_left bad]
        exact rejected rfl
      · rw [ite_eq_right bad]
        by_cases mismatch : mismatched = true
        · rw [ite_eq_left mismatch]
          exact rejected rfl
        · rw [ite_eq_right mismatch]
          exact begin_body text outer info first last (info.completed + 1) updated
            named.1 named.2 (by omega) (range_slots bad)

private def Exit (text : Source) (lower id : Nat) : SignatureExit → Prop
  | .returned result => Returned text lower id result
  | .ready state => At text lower id state.header.position state

private theorem loop_order {text lower id state exit}
    (execution : SignatureLoop modelSignatureCalls text true state exit)
    (prior : At text lower id state.header.position state) : Exit text lower id exit := by
  induction execution with
  | returned step =>
    have seen := iteration _ _ _ _ prior
    rwa [step] at seen
  | ready step =>
    have seen := iteration _ _ _ _ prior
    rwa [step] at seen
  | next step _ tail =>
    have seen := iteration _ _ _ _ prior
    rw [step] at seen
    exact tail seen

private theorem same_parameters {info changed : Metadata} {first count lower upper}
    (order : BodyFormalOrder info first count lower upper) (same : changed.parameters = info.parameters) :
    BodyFormalOrder changed first count lower upper := by
  refine ⟨?_, ?_⟩
  · intro i contained
    simpa only [Metadata.parameterAt, same] using order.span i contained
  · intro i j ordered contained
    simpa only [Metadata.parameterAt, same] using order.before i j ordered contained

private theorem footer (text : Source) (lower id : Nat) (state : SignatureState)
    (prior : At text lower id state.header.position state) (item : Routine) (position : Nat)
    (grown : state.header.position ≤ position) (first : item.formalFirst = state.formalStart)
    (count : item.count = state.formalCount) (advanced : lower < fixedAfter text position "is" true) :
    let following := fixedAfter text position "is" true
    let header := {state.header with position := following}
    Returned text lower id ⟨{state.info with routines := state.info.routines.set (state.routineId - 1) item}, header⟩ := by
  dsimp only
  have window := fixed_window (by decide) (Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) advanced))
  let updated := {state.info with routines := state.info.routines.set (state.routineId - 1) item}
  have assigned : updated.routineAt id = item := by
    simp only [updated, Metadata.routineAt, prior.routine, List.getD_eq_getElem?_getD,
      List.getElem?_set_self prior.routineSlot, Option.getD_some]
  intro _
  refine ⟨advanced, window.2, ?_⟩
  change BodyFormalOrder updated (updated.routineAt id).formalFirst (updated.routineAt id).count lower _
  rw [assigned, first, count]
  exact same_parameters (prior.order.widen (Nat.le_trans grown (Nat.le_of_lt window.1))) rfl

private theorem return_position {text : Source} {state : SignatureState}
    (mark : (packageTypeAt text state.header state.info (fixedAfter text state.header.position "return" true)).after ≠ 0) :
    state.header.position ≤
      (packageTypeAt text state.header state.info (fixedAfter text state.header.position "return" true)).after := by
  have keyword : fixedAfter text state.header.position "return" true ≠ 0 := by
    intro missing
    simp [missing, packageTypeAt, skipAt, nameAfter, PackageBindings.validName] at mark
  have parsed := fixed_window (by decide) keyword
  exact Nat.le_of_lt (Nat.lt_trans parsed.1 (type_window parsed.2 mark).1)

private theorem finish (text : Source) (outer : ParserState) (id : Nat) (state : SignatureState)
    (prior : At text outer.position id state.header.position state) :
    Returned text outer.position id (finishSignature modelSignatureCalls text outer true state) := by
  dsimp only [finishSignature]
  simp only [Bool.true_and, ↓reduceIte, decide_eq_true_eq]
  split
  · exact rejected rfl
  · rename_i matched
    have count : state.item.count = state.formalCount := (Decidable.not_not.mp matched).symm
    cases kind : state.item.kind with
    | procedure =>
      simp [kind]
      split
      · exact rejected rfl
      · rename_i checked
        exact footer _ _ _ _ prior state.item state.header.position (Nat.le_refl _) prior.formalStart.symm count
          (Nat.lt_of_not_ge (fun fail => checked (.inl fail)))
    | function =>
      simp
      split
      · exact rejected rfl
      · rename_i present
        split
        · exact rejected rfl
        · split
          · exact rejected rfl
          · rename_i checked
            let mark := packageTypeAt text state.header state.info (fixedAfter text state.header.position "return" true)
            have completed := footer _ _ _ _ prior {state.item with bodyResultName := mark.name} mark.after
              (return_position present) prior.formalStart.symm count (Nat.lt_of_not_ge (fun fail => checked (.inl fail)))
            simpa only [kind, mark, modelSignatureCalls, ShellToken.word, tokenAfter] using completed

end FormalSpanRead

/-- Successful completion writes every formal's original body name into its
declared slot. Earlier spans finish before later spans begin, and the
closing "is" advances even for a zero-formal procedure. -/
theorem readSignature_completed_order (text : Source) (outer : ParserState) (info : Metadata)
    (accepted : (readSignature text outer info true).header.position ≠ 0) :
    CompletedSignatureOrder text outer.position (info.completed + 1) (readSignature text outer info true) := by
  have started := FormalSpanRead.start text outer info
  generalize actual : readSignature text outer info true = result at accepted ⊢
  have run := actual ▸ readSignature_exec text outer info true
  clear actual
  unfold SignatureExec at run
  cases initial : signatureStart modelSignatureCalls text outer info true with
  | returned failed =>
    simp only [initial] at started run
    subst result
    exact started accepted
  | ready state =>
    simp only [initial] at started run
    subst result
    exact FormalSpanRead.finish _ _ _ _ started accepted
  | loop state =>
    simp only [initial] at started run
    obtain ⟨exit, executed, returned⟩ := run
    have done := FormalSpanRead.loop_order executed started
    cases exit with
    | returned failed =>
      subst result
      exact done accepted
    | ready finalState =>
      subst result
      exact FormalSpanRead.finish _ _ _ _ done accepted

end Silver.ApplicationPackageDeclarations
