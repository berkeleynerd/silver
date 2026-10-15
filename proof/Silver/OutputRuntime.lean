module

public import Silver.OutputLiteral

@[expose] public section

/-! A small imperative fragment for the actual Silver_IO implementation.
`checkedByte` renders the assignment and its executable failure guard together;
its semantics tests the returned status before advancing. The external reply
functions describe completed libc calls. Their progress and physical I/O meaning
are documented environmental premises, not project axioms. -/

namespace Silver.Output.Runtime

structure Environment where
  writeStatus : Nat → Nat → Int
  flushStatus : Int

/-- Control result within Put or Put_Line: `returned` continues sequencing, whereas
`failedReturn` sets the GNAT exit status and returns early from the wrapper.
Neither constructor is a process exit; Main completion is modeled separately. -/
inductive Result
  | returned (accepted : Source)
  | failedReturn (status : Nat) (accepted : Source)
  deriving DecidableEq, Repr

def Result.prepend (prior : Source) : Result → Result
  | .returned bytes => .returned (prior ++ bytes)
  | .failedReturn status bytes => .failedReturn status (prior ++ bytes)

def writeBytes (environment : Environment) : Nat → Source → Result
  | _, [] => .returned []
  | index, byte :: bytes =>
    if environment.writeStatus index byte = (byte : Int) then
      (writeBytes environment (index + 1) bytes).prepend [byte]
    else .failedReturn 1 []

theorem writeBytes_returned (environment : Environment) (index : Nat) (input output : Source)
    (h : writeBytes environment index input = .returned output) : output = input := by
  induction input generalizing index output with
  | nil => simpa [writeBytes] using h.symm
  | cons byte bytes ih =>
    simp only [writeBytes] at h
    split at h
    · cases result : writeBytes environment (index + 1) bytes with
      | returned accepted =>
        simp [result, Result.prepend] at h
        subst output
        rw [ih _ _ result]
      | failedReturn status accepted => simp [result, Result.prepend] at h
    · cases h

theorem writeBytes_failure (environment : Environment) (index : Nat) (input output : Source)
    (status : Nat) (h : writeBytes environment index input = .failedReturn status output) :
    status = 1 ∧ ∃ suffix, output ++ suffix = input := by
  induction input generalizing index output with
  | nil => simp [writeBytes] at h
  | cons byte bytes ih =>
    simp only [writeBytes] at h
    split at h
    · cases result : writeBytes environment (index + 1) bytes with
      | returned accepted => simp [result, Result.prepend] at h
      | failedReturn code accepted =>
        simp only [result, Result.prepend, Result.failedReturn.injEq] at h
        obtain ⟨rfl, rfl⟩ := h
        obtain ⟨code, suffix, prior⟩ := ih _ _ result
        exact ⟨code, suffix, by simpa using congrArg (List.cons byte) prior⟩
    · cases h
      exact ⟨rfl, byte :: bytes, rfl⟩

theorem writeBytes_append (environment : Environment) (index : Nat) (left right : Source) :
    writeBytes environment index (left ++ right) =
      match writeBytes environment index left with
      | .returned accepted =>
          (writeBytes environment (index + left.length) right).prepend accepted
      | .failedReturn status accepted => .failedReturn status accepted := by
  induction left generalizing index with
  | nil => simp [writeBytes, Result.prepend]
           cases writeBytes environment index right <;> rfl
  | cons byte bytes ih =>
    simp only [List.cons_append, writeBytes]
    split
    · rw [ih]
      cases result : writeBytes environment (index + 1) bytes <;>
        simp [Result.prepend, List.length_cons, Nat.add_assoc, Nat.add_comm 1 bytes.length]
      case returned accepted =>
        cases writeBytes environment (index + (bytes.length + 1)) right <;>
          simp
    · rfl

/-- Shared bound, explicitly matched to the authoritative Max_Length declaration. -/
def maxLength : Nat := 4096

/-- Only these fixed static observations may erase. No constructor accepts
source tokens, arbitrary targets, expressions, or executable calls. -/
inductive GhostAction
  | initialize | recordItem | recordNewline | complete
  deriving DecidableEq, Repr

def initialGhostTokens : List String :=
  ["written_bytes", ":=", "(", "others", "=>", "character", "'", "val", "(", "0", ")", ")", ";",
   "written_count", ":=", "0", ";", "flushed", ":=", "false", ";",
   "succeeded", ":=", "false", ";"]

def loopInvariantTokens : List String :=
  ["pragma", "loop_invariant", "(", "static", "=>", "written_count", "=", "index", "-",
   "item", "'", "first", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "(",
   "for", "all", "offset", "in", "1", "..", "written_count", "=>", "written_bytes", "(",
   "offset", ")", "=", "item", "(", "item", "'", "first", "+", "(", "offset", "-", "1",
   ")", ")", ")", ")", ";"]

def recordItemTokens : List String :=
  ["written_count", ":=", "written_count", "+", "1", ";", "written_bytes", "(",
   "written_count", ")", ":=", "item", "(", "index", ")", ";"]

def recordNewlineTokens : List String :=
  ["written_count", ":=", "written_count", "+", "1", ";", "written_bytes", "(",
   "written_count", ")", ":=", "character", "'", "val", "(", "10", ")", ";"]

def GhostAction.render : GhostAction → List String
  | .initialize => initialGhostTokens
  | .recordItem => recordItemTokens
  | .recordNewline => recordNewlineTokens
  | .complete => ["flushed", ":=", "true", ";", "succeeded", ":=", "true", ";"]

/-- A finite check of every erased block. Calls and control-flow cannot be
hidden in these fixed renderings; indexing and Character'Val are predefined. -/
theorem ghost_blocks_no_effect_calls (action : GhostAction) :
    ∀ token ∈ action.render ++ loopInvariantTokens,
      token ≠ "silver_output_libc" ∧ token ≠ "return" ∧ token ≠ "if" := by
  cases action <;> decide

inductive Instruction
  | lengthGuard
  | itemLoop
  | checkedByte (byte : Nat)
  | checkedFlush
  | ghost (action : GhostAction)
  deriving DecidableEq, Repr

def failureTokens : List String :=
  ["silver_output_libc", ".", "set_exit_status", "(", "1", ")", ";", "return", ";"]

def checkedWriteTokens (argument : List String) : List String :=
  ["status", ":=", "silver_output_libc", ".", "put_byte", "("] ++ argument ++
  [")", ";", "if", "status", "/="] ++ argument ++
  ["then"] ++ failureTokens ++ ["end", "if", ";"]

def itemArgument : List String :=
  ["interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(",
   "item", "(", "index", ")", ")", ")"]

def Instruction.render : Instruction → List String
  | .lengthGuard =>
      ["if", "item", "'", "length", ">", "max_length", "then"] ++
      failureTokens ++ ["end", "if", ";"]
  | .itemLoop =>
      ["for", "index", "in", "item", "'", "range", "loop"] ++ loopInvariantTokens ++
      checkedWriteTokens itemArgument ++ GhostAction.recordItem.render ++ ["end", "loop", ";"]
  | .checkedByte byte => checkedWriteTokens [toString byte]
  | .checkedFlush =>
      ["status", ":=", "silver_output_libc", ".", "flush", "(", "system", ".",
       "null_address", ")", ";", "if", "status", "/=", "0", "then"] ++
       failureTokens ++ ["end", "if", ";"]
  | .ghost action => action.render

def Instruction.execute (environment : Environment) (item accepted : Source) :
    Instruction → Result
  | .lengthGuard =>
      if item.length > maxLength then .failedReturn 1 accepted else .returned accepted
  | .itemLoop => (writeBytes environment accepted.length item).prepend accepted
  | .checkedByte byte => (writeBytes environment accepted.length [byte]).prepend accepted
  | .checkedFlush =>
      if environment.flushStatus = 0 then .returned accepted else .failedReturn 1 accepted
  | .ghost _ => .returned accepted

def execute (environment : Environment) (item : Source) : List Instruction → Source → Result
  | [], accepted => .returned accepted
  | instruction :: instructions, accepted =>
      match instruction.execute environment item accepted with
      | .returned bytes => execute environment item instructions bytes
      | .failedReturn status bytes => .failedReturn status bytes

def program : List Instruction :=
  [.ghost .initialize, .lengthGuard, .itemLoop, .checkedByte 10,
   .ghost .recordNewline, .checkedFlush, .ghost .complete]

/-- Accepted bytes and status contribution from a completed call. The original
single-call Main exposes this pair directly; statement sequences concatenate
the per-call bytes and retain failure status across ordinary returning calls.
Signals and external nonprogress are outside this completed-reply model. -/
structure ProcessResult where
  status : Nat
  accepted : Source
  deriving DecidableEq, Repr

def completeMain : Result → ProcessResult
  | .returned bytes => ⟨0, bytes⟩
  | .failedReturn status bytes => ⟨status, bytes⟩

def finish (environment : Environment) : Result → Result
  | .returned bytes =>
      if environment.flushStatus = 0 then .returned bytes else .failedReturn 1 bytes
  | .failedReturn status bytes => .failedReturn status bytes

def specification (environment : Environment) (item : Source) : Result :=
  if item.length > maxLength then .failedReturn 1 []
  else finish environment (writeBytes environment 0 (item ++ [10]))

theorem program_refines (environment : Environment) (item : Source) :
    execute environment item program [] = specification environment item := by
  by_cases bound : item.length > maxLength
  · simp [program, execute, Instruction.execute, specification, bound]
  · simp only [program, execute, Instruction.execute, specification, bound, ↓reduceIte]
    simp only [Result.prepend, List.nil_append, List.length_nil]
    rw [writeBytes_append]
    cases output : writeBytes environment 0 item with
    | returned bytes =>
      have same := writeBytes_returned environment 0 item bytes output
      subst bytes
      simp only [Nat.zero_add]
      cases writeBytes environment item.length [10] <;>
        simp [Result.prepend, finish]
      by_cases flush : environment.flushStatus = 0 <;> simp [flush]
    | failedReturn status bytes => simp [finish]

theorem successful_output (environment : Environment) (item output : Source)
    (h : execute environment item program [] = .returned output) :
    item.length ≤ maxLength ∧ output = item ++ [10] ∧ environment.flushStatus = 0 := by
  rw [program_refines] at h
  unfold specification at h
  split at h
  · cases h
  · rename_i bound
    cases result : writeBytes environment 0 (item ++ [10]) with
    | returned accepted =>
      simp only [result, finish] at h
      split at h
      · cases h
        exact ⟨by omega, writeBytes_returned _ _ _ _ result, by assumption⟩
      · cases h
    | failedReturn status accepted => simp [result, finish] at h

theorem failed_output (environment : Environment) (item output : Source) (status : Nat)
    (h : execute environment item program [] = .failedReturn status output) :
    status = 1 ∧ ∃ suffix, output ++ suffix = item ++ [10] := by
  rw [program_refines] at h
  unfold specification at h
  split at h
  · cases h
    exact ⟨rfl, item ++ [10], rfl⟩
  · cases result : writeBytes environment 0 (item ++ [10]) with
    | returned accepted =>
      simp only [result, finish] at h
      split at h
      · cases h
      · cases h
        exact ⟨rfl, [], by simpa using writeBytes_returned _ _ _ _ result⟩
    | failedReturn code accepted =>
      simp only [result, finish, Result.failedReturn.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact writeBytes_failure _ _ _ _ _ result

def Healthy (environment : Environment) : Prop :=
  (∀ index byte, byte ≤ 255 → environment.writeStatus index byte = (byte : Int)) ∧
    environment.flushStatus = 0

theorem writeBytes_success (environment : Environment) (healthy : Healthy environment)
    (index : Nat) (input : Source) (bytes : ∀ byte ∈ input, byte ≤ 255) :
    writeBytes environment index input = .returned input := by
  induction input generalizing index with
  | nil => rfl
  | cons byte rest ih =>
      have head := bytes byte (by simp)
      have tail : ∀ value ∈ rest, value ≤ 255 := fun value member => bytes value (by simp [member])
      simp [writeBytes, healthy.1 index byte head, ih _ tail, Result.prepend]

theorem healthy_output (environment : Environment) (healthy : Healthy environment)
    (item : Source) (bounded : item.length ≤ maxLength)
    (bytes : ∀ byte ∈ item, byte ≤ 255) :
    execute environment item program [] = .returned (item ++ [10]) := by
  rw [program_refines]
  have all : ∀ byte ∈ item ++ [10], byte ≤ 255 := by
    intro byte member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact bytes byte member
    · decide
  simp [specification, Nat.not_lt.mpr bounded, writeBytes_success environment healthy 0 _ all,
    finish, healthy.2]

/-- `Put` uses the same guarded byte loop and flush, without a newline write. -/
def putProgram : List Instruction :=
  [.ghost .initialize, .lengthGuard, .itemLoop, .checkedFlush, .ghost .complete]

def putSpecification (environment : Environment) (item : Source) : Result :=
  if item.length > maxLength then .failedReturn 1 []
  else finish environment (writeBytes environment 0 item)

theorem put_program_refines (environment : Environment) (item : Source) :
    execute environment item putProgram [] = putSpecification environment item := by
  by_cases bound : item.length > maxLength
  · simp [putProgram, execute, Instruction.execute, putSpecification, bound]
  · simp only [putProgram, execute, Instruction.execute, putSpecification, bound, ↓reduceIte]
    simp only [Result.prepend, List.nil_append, List.length_nil]
    cases writeBytes environment 0 item <;> simp [finish]
    by_cases flush : environment.flushStatus = 0 <;> simp [flush]

theorem successful_put (environment : Environment) (item output : Source)
    (h : execute environment item putProgram [] = .returned output) :
    item.length ≤ maxLength ∧ output = item ∧ environment.flushStatus = 0 := by
  rw [put_program_refines] at h
  unfold putSpecification at h
  split at h
  · cases h
  · rename_i bound
    cases result : writeBytes environment 0 item with
    | returned accepted =>
      simp only [result, finish] at h
      split at h
      · cases h
        exact ⟨by omega, writeBytes_returned _ _ _ _ result, by assumption⟩
      · cases h
    | failedReturn status accepted => simp [result, finish] at h

theorem failed_put (environment : Environment) (item output : Source) (status : Nat)
    (h : execute environment item putProgram [] = .failedReturn status output) :
    status = 1 ∧ ∃ suffix, output ++ suffix = item := by
  rw [put_program_refines] at h
  unfold putSpecification at h
  split at h
  · cases h
    exact ⟨rfl, item, rfl⟩
  · cases result : writeBytes environment 0 item with
    | returned accepted =>
      simp only [result, finish] at h
      split at h
      · cases h
      · cases h
        exact ⟨rfl, [], by simpa using writeBytes_returned _ _ _ _ result⟩
    | failedReturn code accepted =>
      simp only [result, finish, Result.failedReturn.injEq] at h
      obtain ⟨rfl, rfl⟩ := h
      exact writeBytes_failure _ _ _ _ _ result

theorem healthy_put (environment : Environment) (healthy : Healthy environment)
    (item : Source) (bounded : item.length ≤ maxLength)
    (bytes : ∀ byte ∈ item, byte ≤ 255) :
    execute environment item putProgram [] = .returned item := by
  rw [put_program_refines]
  simp [putSpecification, Nat.not_lt.mpr bounded,
    writeBytes_success environment healthy 0 item bytes, finish, healthy.2]

end Silver.Output.Runtime
