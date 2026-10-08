import Silver.OutputLiteral

/-! A small imperative fragment for the actual Silver_IO implementation.
`CheckedWrite` renders the assignment and its executable failure guard together;
its semantics tests the returned status before advancing. The external reply
functions describe completed libc calls. Their progress and physical I/O meaning
are documented environmental premises, not project axioms. -/

namespace Silver.Output.Runtime

structure Environment where
  writeStatus : Nat → Nat → Int
  flushStatus : Int

inductive Result
  | returned (accepted : Source)
  | exited (status : Nat) (accepted : Source)
  deriving DecidableEq, Repr

def Result.prepend (prior : Source) : Result → Result
  | .returned bytes => .returned (prior ++ bytes)
  | .exited status bytes => .exited status (prior ++ bytes)

def writeBytes (environment : Environment) : Nat → Source → Result
  | _, [] => .returned []
  | index, byte :: bytes =>
    if environment.writeStatus index byte = (byte : Int) then
      (writeBytes environment (index + 1) bytes).prepend [byte]
    else .exited 1 []

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
      | exited status accepted => simp [result, Result.prepend] at h
    · cases h

theorem writeBytes_failure (environment : Environment) (index : Nat) (input output : Source)
    (status : Nat) (h : writeBytes environment index input = .exited status output) :
    status = 1 ∧ ∃ suffix, output ++ suffix = input := by
  induction input generalizing index output with
  | nil => simp [writeBytes] at h
  | cons byte bytes ih =>
    simp only [writeBytes] at h
    split at h
    · cases result : writeBytes environment (index + 1) bytes with
      | returned accepted => simp [result, Result.prepend] at h
      | exited code accepted =>
        simp only [result, Result.prepend, Result.exited.injEq] at h
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
      | .exited status accepted => .exited status accepted := by
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

/-- Ghost statements retain their source tokens and erase to skip. They include
only the statically checked transcript assignments and loop invariants. -/
inductive Instruction
  | lengthGuard (maximum : Nat)
  | itemLoop (before after : List String)
  | checkedByte (byte : Nat)
  | checkedFlush
  | ghost (tokens : List String)
  deriving DecidableEq, Repr

def checkedWriteTokens (argument : List String) : List String :=
  ["status", ":=", "silver_output_libc", ".", "put_byte", "("] ++ argument ++
  [")", ";", "if", "status", "/="] ++ argument ++
  ["then", "silver_output_libc", ".", "fail", "(", "1", ")", ";", "end", "if", ";"]

def itemArgument : List String :=
  ["interfaces", ".", "c", ".", "int", "(", "character", "'", "pos", "(",
   "item", "(", "index", ")", ")", ")"]

def Instruction.render : Instruction → List String
  | .lengthGuard maximum =>
      ["if", "item", "'", "length", ">", "max_length", "then", "silver_output_libc",
       ".", "fail", "(", "1", ")", ";", "end", "if", ";"] ++
      -- The declaration binding for max_length is checked separately.
      (if maximum = 4096 then [] else ["invalid_bound"])
  | .itemLoop before after =>
      ["for", "index", "in", "item", "'", "range", "loop"] ++ before ++
      checkedWriteTokens itemArgument ++ after ++ ["end", "loop", ";"]
  | .checkedByte byte => checkedWriteTokens [toString byte]
  | .checkedFlush =>
      ["status", ":=", "silver_output_libc", ".", "flush", "(", "system", ".",
       "null_address", ")", ";", "if", "status", "/=", "0", "then",
       "silver_output_libc", ".", "fail", "(", "1", ")", ";", "end", "if", ";"]
  | .ghost tokens => tokens

def Instruction.execute (environment : Environment) (item accepted : Source) :
    Instruction → Result
  | .lengthGuard maximum =>
      if item.length > maximum then .exited 1 accepted else .returned accepted
  | .itemLoop _ _ => (writeBytes environment accepted.length item).prepend accepted
  | .checkedByte byte => (writeBytes environment accepted.length [byte]).prepend accepted
  | .checkedFlush =>
      if environment.flushStatus = 0 then .returned accepted else .exited 1 accepted
  | .ghost _ => .returned accepted

def execute (environment : Environment) (item : Source) : List Instruction → Source → Result
  | [], accepted => .returned accepted
  | instruction :: instructions, accepted =>
      match instruction.execute environment item accepted with
      | .returned bytes => execute environment item instructions bytes
      | .exited status bytes => .exited status bytes

def initialGhost : List String :=
  ["written_bytes", ":=", "(", "others", "=>", "character", "'", "val", "(", "0", ")", ")", ";",
   "written_count", ":=", "0", ";"]

def loopBefore : List String :=
  ["pragma", "loop_invariant", "(", "static", "=>", "written_count", "=", "index", "-",
   "item", "'", "first", ")", ";", "pragma", "loop_invariant", "(", "static", "=>", "(",
   "for", "all", "offset", "in", "1", "..", "written_count", "=>", "written_bytes", "(",
   "offset", ")", "=", "item", "(", "item", "'", "first", "+", "(", "offset", "-", "1",
   ")", ")", ")", ")", ";"]

def loopAfter : List String :=
  ["written_count", ":=", "written_count", "+", "1", ";", "written_bytes", "(",
   "written_count", ")", ":=", "item", "(", "index", ")", ";"]

def newlineGhost : List String :=
  ["written_count", ":=", "written_count", "+", "1", ";", "written_bytes", "(",
   "written_count", ")", ":=", "character", "'", "val", "(", "10", ")", ";"]

def program : List Instruction :=
  [.lengthGuard 4096, .ghost initialGhost, .itemLoop loopBefore loopAfter,
   .checkedByte 10, .ghost newlineGhost, .checkedFlush,
   .ghost ["flushed", ":=", "true", ";"]]

def finish (environment : Environment) : Result → Result
  | .returned bytes =>
      if environment.flushStatus = 0 then .returned bytes else .exited 1 bytes
  | .exited status bytes => .exited status bytes

def specification (environment : Environment) (item : Source) : Result :=
  if item.length > 4096 then .exited 1 []
  else finish environment (writeBytes environment 0 (item ++ [10]))

theorem program_refines (environment : Environment) (item : Source) :
    execute environment item program [] = specification environment item := by
  by_cases bound : item.length > 4096
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
    | exited status bytes => simp [finish]

theorem successful_output (environment : Environment) (item output : Source)
    (h : execute environment item program [] = .returned output) :
    item.length ≤ 4096 ∧ output = item ++ [10] ∧ environment.flushStatus = 0 := by
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
    | exited status accepted => simp [result, finish] at h

theorem failed_output (environment : Environment) (item output : Source) (status : Nat)
    (h : execute environment item program [] = .exited status output) :
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
    | exited code accepted =>
      simp only [result, finish, Result.exited.injEq] at h
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
    (item : Source) (bounded : item.length ≤ 4096)
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

end Silver.Output.Runtime
