module

public import Silver.ApplicationPackageDeclarationsFormalSpans
public import Silver.ApplicationPackageNamesMeaning

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings ApplicationPackageNames

/-- The returned routine refers to body names in its original completion,
in physical formal order and between the original entry and return cursors. -/
structure CompletedSignatureOrder (text : Source) (lower id : Nat) (result : SignatureResult) : Prop where
  progress : lower < result.header.position
  bounded : result.header.position ≤ text.length + 1
  formals : BodyFormalOrder result.info (result.info.routineAt id).formalFirst (result.info.routineAt id).count
    lower result.header.position

namespace FormalSpanRead
open ApplicationPackageObjectRows

def Returned (text : Source) (lower id : Nat) (result : SignatureResult) : Prop :=
  result.header.position ≠ 0 → CompletedSignatureOrder text lower id result

theorem rejected {text lower id} {result : SignatureResult} (zero : result.header.position = 0) :
    Returned text lower id result := fun present => (present zero).elim

/-- Quantities unchanged by the loop apart from the checked parameter write.
Keeping the cursor as an argument allows the intermediate hidden frame to be
used for the type lookup without losing the cursor at the start of the step. -/
structure Progress (text : Source) (lower id cursor : Nat) (info : Metadata) (item : Routine)
    (identity first count : Nat) : Prop where
  entered : lower ≤ cursor
  bounded : cursor ≤ text.length + 1
  routine : identity = id
  routineSlot : id - 1 < info.routines.length
  formalStart : first = item.formalFirst
  slots : ∀ i, i < item.count → 0 < first ∧ first + i ≤ info.parameters.length
  order : BodyFormalOrder info first count lower cursor

abbrev At (text : Source) (lower id cursor : Nat) (state : SignatureState) :=
  Progress text lower id cursor state.info state.item state.routineId state.formalStart state.formalCount

theorem Progress.advance {text lower id cursor info item identity first count}
    (prior : Progress text lower id cursor info item identity first count) {next : Nat}
    (moved : cursor ≤ next) (bounded : next ≤ text.length + 1) :
    Progress text lower id next info item identity first count :=
  ⟨Nat.le_trans prior.entered moved, bounded, prior.routine, prior.routineSlot, prior.formalStart,
    prior.slots, prior.order.widen moved⟩

def Step (text : Source) (lower id : Nat) : SignatureStep → Prop
  | .returned result => Returned text lower id result
  | .ready state | .next state => At text lower id state.header.position state

private theorem finish_parameter (text : Source) (lower id before : Nat) (state : SignatureState)
    (prior : At text lower id state.header.position state) :
    Step text lower id (finishFormal modelSignatureCalls text before state) := by
  dsimp only [finishFormal]
  split
  · rename_i closed
    have bounds := fixed_window (by decide) (show fixedAfter text state.header.position ")" false ≠ 0 from closed)
    exact prior.advance (Nat.le_of_lt bounds.1) bounds.2
  · split
    · exact rejected rfl
    · rename_i continues
      have nonzero : fixedAfter text state.header.position ";" false ≠ 0 := by
        change ¬ fixedAfter text state.header.position ";" false ≤ before at continues
        omega
      have bounds := fixed_window (by decide) nonzero
      exact prior.advance (Nat.le_of_lt bounds.1) bounds.2

private theorem store_parameter (text : Source) (lower id before : Nat) (state : SignatureState)
    (first last : Nat) (direction : ProcedureBindings.Mode) (mark : PackageTypeResult)
    (prior : At text lower id before state) (within : state.formalCount < state.item.count)
    (positive : 0 < first) (start : before ≤ first) (named : first < last)
    (typed : last < mark.after) (bounded : mark.after ≤ text.length + 1) :
    Step text lower id (storeFormal modelSignatureCalls text true before state first last
      (state.formalStart + state.formalCount) direction mark) := by
  unfold storeFormal
  simp only [Bool.true_and, ↓reduceIte]
  split
  · exact rejected rfl
  · let slot := state.formalStart + state.formalCount
    let formal := {state.info.parameterAt slot with bodyName := ⟨first,last⟩, bodyTypeName := mark.name}
    let header := appendFormal {state.header with position := mark.after} ⟨first,last⟩ mark direction
    split
    · rename_i missing
      exact rejected missing
    · rename_i present
      have same : header.position = mark.after := append_position _ _ _ _ present
      apply finish_parameter
      change Progress text lower id header.position
        {state.info with parameters := state.info.parameters.set (slot - 1) formal}
        state.item state.routineId state.formalStart (state.formalCount + 1)
      rw [same]
      obtain ⟨physical, active⟩ := prior.slots state.formalCount within
      have spans := prior.order.write physical active formal positive start named typed prior.entered
      refine ⟨?_, bounded, prior.routine, prior.routineSlot, prior.formalStart, ?_, spans⟩
      · exact Nat.le_trans prior.entered (Nat.le_trans start (Nat.le_of_lt (Nat.lt_trans named typed)))
      · intro i contained
        simpa only [List.length_set] using prior.slots i contained

private theorem read_type (text : Source) (lower id before : Nat) (state : SignatureState)
    (first last : Nat) (prior : At text lower id before state) (within : state.formalCount < state.item.count)
    (positive : 0 < first) (start : before ≤ first) (named : first < last) :
    Step text lower id (readFormalType modelSignatureCalls text true before state first last
      (state.formalStart + state.formalCount)) := by
  let selected := mode text last
  let mark := packageTypeAt text state.header state.info selected.1
  change Step text lower id (if selected.1 = 0 ∨ state.item.kind = .function ∧ selected.2 ≠ .input
    then .returned (rejectedSignature state.info)
    else if mark.after = 0 then .returned (rejectedSignature state.info)
    else storeFormal modelSignatureCalls text true before state first last
      (state.formalStart + state.formalCount) selected.2 mark)
  split
  · exact rejected rfl
  · rename_i permitted
    split
    · exact rejected rfl
    · rename_i markFound
      have words := mode_window (show selected.1 ≠ 0 from fun empty => permitted (.inl empty))
      have nameWindow := type_window words.2 markFound
      exact store_parameter text lower id before state first last selected.2 mark prior within positive start named
        (Nat.lt_trans words.1 nameWindow.1) nameWindow.2

private theorem read_name (text : Source) (lower id before : Nat) (state : SignatureState)
    (first last : Nat) (prior : At text lower id before state) (within : state.formalCount < state.item.count)
    (positive : 0 < first) (start : before ≤ first) (named : first < last) :
    Step text lower id (readFormalName modelSignatureCalls text true before state first last
      (state.formalStart + state.formalCount)) := by
  dsimp only [readFormalName]
  split
  · exact rejected rfl
  · split
    · rename_i missing
      exact rejected missing
    · exact read_type _ _ _ _ _ first last prior within positive start named

theorem iteration (text : Source) (lower id : Nat) (state : SignatureState)
    (prior : At text lower id state.header.position state) :
    Step text lower id (signatureStep modelSignatureCalls text true state) := by
  dsimp only [signatureStep]
  simp only [Bool.true_and, Bool.not_true, Bool.false_and, Bool.or_false, decide_eq_true_eq, ↓reduceIte]
  split
  · exact rejected rfl
  · rename_i allowed
    split
    · exact rejected rfl
    · rename_i canWrite
      have valid : PackageBindings.validName (metadataText text)
          ⟨skipAt text state.header.position, nameAfter text (skipAt text state.header.position)⟩ = true := by
        exact Bool.of_not_eq_false (fun missing => allowed (by simp only [modelSignatureCalls, missing, Bool.not_false]))
      have name := (ApplicationPackageNames.Native.validName_domain valid).2
      have advanced := skipAt_advances text _ prior.bounded (Nat.ne_of_gt name.1)
      exact read_name _ _ _ _ _ _ _ prior (Nat.lt_of_not_ge canWrite) name.1 advanced name.2.1

end FormalSpanRead
end Silver.ApplicationPackageDeclarations
