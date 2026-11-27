module

public import Silver.ApplicationPackageDeclarationsExecution
public import Silver.PackageInterfaces

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose PackageBindings

/-- Every active formal belongs to its physical parameter table. For a
function each such cell has the input mode checked by Package_Signature_At. -/
def FormalModes (parameters : List Formal) (kind : RoutineKind) (first count : Nat) : Prop :=
  ∀ offset, offset < count →
    0 < first + offset ∧ first + offset ≤ parameters.length ∧
      (kind = .function → (parameters.getD (first + offset - 1) {}).mode = .input)

def DeclaredFormalModes (info : Metadata) : Prop :=
  ∀ routine ∈ info.routines, FormalModes info.parameters routine.kind routine.formalFirst routine.count

theorem DeclaredFormalModes.function_inputs {info : Metadata} (known : DeclaredFormalModes info)
    {routine : Routine} (declared : routine ∈ info.routines) (kind : routine.kind = .function)
    {formal : Formal} (member : formal ∈ routine.formals info) : formal.mode = .input := by
  obtain ⟨offset, inRange, rfl⟩ := List.mem_map.mp member
  exact (known routine declared offset (List.mem_range.mp inRange)).2.2 kind

theorem empty_formal_modes : DeclaredFormalModes ({} : Metadata) := by
  intro routine member
  cases member

namespace FormalModes

private def Extends (old new : List Formal) : Prop :=
  old.length ≤ new.length ∧
  ∀ index, index < old.length → (new.getD index {}).mode = (old.getD index {}).mode

private theorem append_extends (old : List Formal) (item : Formal) : Extends old (old ++ [item]) := by
  refine ⟨by simp, ?_⟩
  intro index inside
  simp only [List.getD_eq_getElem?_getD, List.getElem?_append_left inside]

private theorem set_extends (old : List Formal) (index : Nat) (item : Formal)
    (same : item.mode = (old.getD index {}).mode) : Extends old (old.set index item) := by
  refine ⟨by simp, ?_⟩
  intro offset inside
  by_cases selected : index = offset
  · subst offset
    simpa only [List.getD_eq_getElem?_getD, List.getElem?_set_self inside, Option.getD_some] using same
  · simp only [List.getD_eq_getElem?_getD, List.getElem?_set_ne selected]

private theorem preserve {old new : List Formal} {kind first count}
    (range : FormalModes old kind first count) (written : Extends old new) :
    FormalModes new kind first count := by
  intro offset bounded
  obtain ⟨positive, inside, input⟩ := range offset bounded
  refine ⟨positive, Nat.le_trans inside written.1, ?_⟩
  intro function
  exact (written.2 _ (by omega)).trans (input function)

private theorem extend_range {old : List Formal} (item : Formal) {kind first count}
    (range : FormalModes old kind first count) (slot : first + count = old.length + 1)
    (input : kind = .function → item.mode = .input) :
    FormalModes (old ++ [item]) kind first (count + 1) := by
  intro offset bounded
  by_cases before : offset < count
  · exact preserve range (append_extends old item) offset before
  · have same : offset = count := by omega
    subst offset
    rw [slot]
    refine ⟨by omega, by simp, ?_⟩
    simpa only [Nat.add_sub_cancel, List.getD_eq_getElem?_getD, List.getElem?_concat_length,
      Option.getD_some] using input

private theorem preserve_table {old : Metadata} {rows : List Formal} (known : DeclaredFormalModes old)
    (written : Extends old.parameters rows) : DeclaredFormalModes {old with parameters := rows} :=
  fun routine member => preserve (known routine member) written

private theorem append_routine {info : Metadata} {item : Routine} (known : DeclaredFormalModes info)
    (valid : FormalModes info.parameters item.kind item.formalFirst item.count) :
    DeclaredFormalModes {info with routines := info.routines ++ [item]} := by
  intro routine member
  rcases List.mem_append.mp member with earlier | newItem
  · exact known routine earlier
  · have same : routine = item := List.mem_singleton.mp newItem
    exact same ▸ valid

private theorem set_routine {info : Metadata} {item : Routine} (index : Nat) (known : DeclaredFormalModes info)
    (valid : FormalModes info.parameters item.kind item.formalFirst item.count) :
    DeclaredFormalModes {info with routines := info.routines.set index item} := by
  intro routine member
  rcases List.mem_or_eq_of_mem_set member with earlier | rfl
  · exact known routine earlier
  · exact valid

/-- A completion retains the formal segment of its declaration. A new
routine collects a contiguous suffix as it parses one or more formals. -/
private def InSignature (completing : Bool) (state : SignatureState) : Prop :=
  DeclaredFormalModes state.info ∧
  (completing = true → FormalModes state.info.parameters state.item.kind state.item.formalFirst state.item.count) ∧
  (completing = false → FormalModes state.info.parameters state.item.kind state.formalStart state.formalCount) ∧
  (completing = false → 0 < state.formalCount → state.formalStart + state.formalCount = state.info.parameters.length + 1)

private def Start (completing : Bool) : SignatureStart → Prop
  | .returned result => DeclaredFormalModes result.info
  | .ready state | .loop state => InSignature completing state

private def Step (completing : Bool) : SignatureStep → Prop
  | .returned result => DeclaredFormalModes result.info
  | .ready state | .next state => InSignature completing state

private theorem begin_signature (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (info : Metadata) (first last identity : Nat) (item : Routine) (firstFormal : Nat) (completing : Bool)
    (known : DeclaredFormalModes info)
    (existing : completing = true → FormalModes info.parameters item.kind item.formalFirst item.count) :
    Start completing (startSignatureBody calls text outer info first last identity item firstFormal) := by
  dsimp only [startSignatureBody]
  split <;> exact ⟨known, existing, fun _ _ h => (Nat.not_lt_zero _ h).elim, fun _ h => (Nat.not_lt_zero _ h).elim⟩

private theorem start (calls : SignatureCalls) (text : Source) (outer : ParserState) (info : Metadata)
    (completing : Bool) (known : DeclaredFormalModes info) :
    Start completing (signatureStart calls text outer info completing) := by
  cases completing with
  | false =>
    unfold signatureStart
    simp only [Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact known | exact begin_signature _ _ _ _ _ _ _ _ _ _ known (by intro h; cases h) | split
  | true =>
    unfold signatureStart
    simp only [↓reduceIte]
    repeat' first | exact known | apply begin_signature _ _ _ _ _ _ _ _ _ _ known | split
    all_goals
      intro _
      have bounded : info.completed < info.routines.length := by omega
      have selected : info.routineAt (info.completed + 1) ∈ info.routines := by
        simp only [Metadata.routineAt, Nat.add_sub_cancel, List.getD_eq_getElem?_getD,
          List.getElem?_eq_getElem bounded, Option.getD_some]
        exact List.getElem_mem bounded
      exact known (info.routineAt (info.completed + 1)) selected

private theorem finish_formal (calls : SignatureCalls) (text : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (valid : InSignature completing state) :
    Step completing (finishFormal calls text before state) := by
  dsimp only [finishFormal]
  repeat' first | exact valid | exact valid.1 | split

private theorem store_formal (calls : SignatureCalls) (text : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (first last slot : Nat) (mode : Mode)
    (mark : ApplicationPackageNames.PackageTypeResult) (valid : InSignature completing state)
    (next : completing = false → state.formalStart + state.formalCount = state.info.parameters.length + 1)
    (input : state.item.kind = .function → mode = .input) :
    Step completing (storeFormal calls text completing before state first last slot mode mark) := by
  cases completing with
  | false =>
    unfold storeFormal
    simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    let formal : Formal :=
      { specName := ⟨first, last⟩, specTypeName := mark.name, kind := mark.kind
        bounds := mark.bounds, typeIdentity := mark.identity, mode }
    have table := preserve_table valid.1 (append_extends state.info.parameters formal)
    split
    · exact table
    · apply finish_formal
      refine ⟨table, (by intro h; cases h), fun _ => extend_range formal (valid.2.2.1 rfl) (next rfl) input, ?_⟩
      intro _ _
      change state.formalStart + (state.formalCount + 1) = (state.info.parameters ++ [formal]).length + 1
      have lastSlot := next rfl
      simp only [List.length_append, List.length_cons, List.length_nil]
      omega
  | true =>
    unfold storeFormal
    simp only [Bool.true_and, ↓reduceIte]
    split
    · exact valid.1
    · let formal := {state.info.parameterAt slot with bodyName := ⟨first, last⟩, bodyTypeName := mark.name}
      have same := set_extends state.info.parameters (slot - 1) formal rfl
      have table := preserve_table valid.1 same
      split
      · exact table
      · apply finish_formal
        exact ⟨table, fun _ => preserve (valid.2.1 rfl) same, (by intro h; cases h), (by intro h; cases h)⟩


private theorem permitted_mode {position : Nat} {kind : RoutineKind} {mode : Mode}
    (accepted : ¬(position = 0 ∨ kind = .function ∧ mode ≠ .input)) : kind = .function → mode = .input :=
  fun function => Classical.byContradiction fun wrong => accepted (.inr ⟨function, wrong⟩)

private theorem read_type (calls : SignatureCalls) (text : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (first last slot : Nat) (valid : InSignature completing state)
    (next : completing = false → state.formalStart + state.formalCount = state.info.parameters.length + 1) :
    Step completing (readFormalType calls text completing before state first last slot) := by
  dsimp only [readFormalType]
  repeat' first
    | exact valid.1
    | exact store_formal _ _ _ _ _ _ _ _ _ _ valid next (permitted_mode (by assumption))
    | split

private theorem read_name (calls : SignatureCalls) (text : Source) (completing : Bool)
    (before : Nat) (state : SignatureState) (first last slot : Nat) (valid : InSignature completing state)
    (next : completing = false → state.formalStart + state.formalCount = state.info.parameters.length + 1) :
    Step completing (readFormalName calls text completing before state first last slot) := by
  dsimp only [readFormalName]
  repeat' first | exact valid.1 | exact read_type _ _ _ _ _ _ _ _ valid next | split

private theorem select_new (state : SignatureState) (valid : InSignature false state) :
    let first := if state.formalCount = 0 then state.info.parameters.length + 1 else state.formalStart
    InSignature false {state with formalStart := first} ∧
      first + state.formalCount = state.info.parameters.length + 1 := by
  by_cases empty : state.formalCount = 0
  · simp only [empty, ↓reduceIte, Nat.add_zero, and_true]
    exact ⟨valid.1, (by intro h; cases h), (by intro _ offset bounded; exact (Nat.not_lt_zero offset bounded).elim),
      (by intro _ positive; exact (Nat.not_lt_zero 0 positive).elim)⟩
  · simp only [empty, ↓reduceIte]
    exact ⟨valid, valid.2.2.2 rfl (Nat.pos_of_ne_zero empty)⟩

private theorem iteration (calls : SignatureCalls) (text : Source) (completing : Bool) (state : SignatureState)
    (valid : InSignature completing state) : Step completing (signatureStep calls text completing state) := by
  cases completing with
  | false =>
    obtain ⟨selected, next⟩ := select_new state valid
    dsimp only [signatureStep]
    simp only [Bool.false_and, Bool.not_false, Bool.true_and, Bool.false_or, Bool.false_eq_true, decide_eq_true_eq, ↓reduceIte]
    repeat' first | exact valid.1 | exact read_name _ _ _ _ _ _ _ _ selected (fun _ => next) | split
  | true =>
    dsimp only [signatureStep]
    simp only [Bool.true_and, Bool.not_true, Bool.false_and, Bool.or_false, decide_eq_true_eq, ↓reduceIte]
    repeat' first | exact valid.1 | exact read_name _ _ _ _ _ _ _ _ valid (by intro h; cases h) | split

private theorem finish_signature (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (completing : Bool) (state : SignatureState) (valid : InSignature completing state) :
    DeclaredFormalModes (finishSignature calls text outer completing state).info := by
  cases completing with
  | false =>
    have range := valid.2.2.1 rfl
    dsimp only [finishSignature]
    simp only [Bool.false_and, Bool.false_eq_true, ↓reduceIte]
    repeat' first | exact valid.1 | exact append_routine valid.1 range | split
  | true =>
    have range := valid.2.1 rfl
    dsimp only [finishSignature]
    simp only [Bool.true_and, ↓reduceIte]
    repeat' first | exact valid.1 | exact set_routine _ valid.1 range | split

private def Exit (completing : Bool) : SignatureExit → Prop
  | .returned result => DeclaredFormalModes result.info
  | .ready state => InSignature completing state

private theorem loop_modes {calls text completing state exit} (run : SignatureLoop calls text completing state exit)
    (valid : InSignature completing state) : Exit completing exit := by
  induction run with
  | returned step =>
    have seen := iteration calls text completing _ valid
    rwa [step] at seen
  | ready step =>
    have seen := iteration calls text completing _ valid
    rwa [step] at seen
  | next step _ ih =>
    have seen := iteration calls text completing _ valid
    rw [step] at seen
    exact ih seen

end FormalModes

/-- A new signature builds a fresh contiguous formal segment. A completion
writes body spans back into the original cells and retains their modes. Both
preserve the established routine rows, even on a partial failure. -/
theorem SignatureExec.formal_modes {calls text outer info completing result}
    (execution : SignatureExec calls text outer info completing result) (known : DeclaredFormalModes info) :
    DeclaredFormalModes result.info := by
  have started := FormalModes.start calls text outer info completing known
  unfold SignatureExec at execution
  cases initial : signatureStart calls text outer info completing with
  | returned failed =>
    simp only [initial] at execution started
    exact execution ▸ started
  | ready state =>
    simp only [initial] at execution started
    exact execution ▸ FormalModes.finish_signature calls text outer completing state started
  | loop state =>
    simp only [initial] at execution started
    obtain ⟨exit, run, resultIs⟩ := execution
    have finalRows := FormalModes.loop_modes run started
    cases exit with
    | returned failed =>
      subst result
      exact finalRows
    | ready finalState =>
      subst result
      exact FormalModes.finish_signature calls text outer completing finalState finalRows

theorem readSignature_formal_modes (text : Source) (outer : ParserState) (info : Metadata)
    (completing : Bool) (known : DeclaredFormalModes info) :
    DeclaredFormalModes (readSignature text outer info completing).info :=
  (readSignature_exec text outer info completing).formal_modes known

private def SpecificationModes : SpecificationStep → Prop
  | .returned result => DeclaredFormalModes result.info
  | .ready state | .next state => DeclaredFormalModes state.info

private theorem specification_iteration_modes (reader : BooleanElaboration.Native.Reader)
    (text : Source) (state : SpecificationState) (known : DeclaredFormalModes state.info) :
    SpecificationModes (specificationStep (modelSpecificationCalls reader) text state) := by
  have routine := readSignature_formal_modes text state.exports state.info false known
  dsimp only [specificationStep, specificationRoutine, specificationSubtype, specificationObject,
    appendExport, continueSpecification]
  repeat' first | exact known | exact routine | split

private def SpecificationExitModes : SpecificationExit → Prop
  | .returned result => DeclaredFormalModes result.info
  | .ready state => DeclaredFormalModes state.info

private theorem specification_loop_modes {reader text state exit}
    (run : SpecificationLoop (modelSpecificationCalls reader) text state exit)
    (known : DeclaredFormalModes state.info) : SpecificationExitModes exit := by
  induction run with
  | returned step =>
    have seen := specification_iteration_modes reader text _ known
    rwa [step] at seen
  | ready step =>
    have seen := specification_iteration_modes reader text _ known
    rwa [step] at seen
  | next step _ ih =>
    have seen := specification_iteration_modes reader text _ known
    rw [step] at seen
    exact ih seen

private def SpecificationStartModes : SpecificationStart → Prop
  | .returned result => DeclaredFormalModes result.info
  | .loop state => DeclaredFormalModes state.info

private theorem specification_start_modes (calls : SpecificationCalls) (text : Source) (info : Metadata)
    (known : DeclaredFormalModes info) : SpecificationStartModes (specificationStart calls text info) := by
  dsimp only [specificationStart]
  repeat' first | exact known | split

private theorem specification_finish_modes (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) (known : DeclaredFormalModes state.info) :
    DeclaredFormalModes (finishSpecification calls text state).info := by
  dsimp only [finishSpecification]
  repeat' first | exact known | split

/-- The original specification's routine branches derive the formal modes
from declarations. Starting with the empty routine table discharges the
incoming hypothesis independently of metadata validity. -/
theorem readSpecification_formal_modes (reader : BooleanElaboration.Native.Reader) (text : Source)
    (info : Metadata) (known : DeclaredFormalModes info) :
    DeclaredFormalModes (readSpecification reader text info).info := by
  let calls := modelSpecificationCalls reader
  generalize actual : readSpecification reader text info = result
  have exec := actual ▸ readSpecification_exec reader text info
  clear actual
  have started := specification_start_modes calls text info known
  change SpecificationExec calls text info result at exec
  unfold SpecificationExec at exec
  cases initial : specificationStart calls text info with
  | returned failed =>
    simp only [initial] at exec started
    exact exec ▸ started
  | loop state =>
    simp only [initial] at exec started
    obtain ⟨exit, run, returned⟩ := exec
    have seen := specification_loop_modes run started
    cases exit with
    | returned failed =>
      subst result
      exact seen
    | ready done =>
      subst result
      exact specification_finish_modes calls text done seen

/-- Updating a completion's body location and inferred effects preserves the
modes of every routine whenever its kind and formal segment are retained. -/
theorem DeclaredFormalModes.update_routine {info : Metadata} (known : DeclaredFormalModes info)
    (identity : Nat) (updated : Routine)
    (kind : updated.kind = (info.routineAt identity).kind)
    (first : updated.formalFirst = (info.routineAt identity).formalFirst)
    (count : updated.count = (info.routineAt identity).count) :
    DeclaredFormalModes {info with routines := info.routines.set (identity - 1) updated} := by
  by_cases inside : identity - 1 < info.routines.length
  · apply FormalModes.set_routine _ known
    rw [kind, first, count]
    apply known
    simp only [Metadata.routineAt, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some]
    exact List.getElem_mem inside
  · simpa only [List.set_eq_of_length_le (Nat.le_of_not_gt inside)] using known

end Silver.ApplicationPackageDeclarations
