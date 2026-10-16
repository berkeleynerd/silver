module

public import Silver.ImageModelNativeHelpers

@[expose] public section
namespace Silver.ImageModel.FilesNative

/-- One iteration's external byte-I/O outcomes. Only the declared output
parameters of the I/O calls may change; their native Global contracts preserve
the scanner state and the read observations. -/
structure Outcomes where
  item : Int
  error : Int
  writeOK : Bool
  declarationsOK : Bool
  includesOK : Bool

structure Frame where
  current : Core.State
  read : List Nat
  copied : List Nat
  item : Int
  status : Int
  success : Bool
  ended : Bool
  position : Nat
  declarationsDone : Bool
  includesDone : Bool
  declarationsOffset : Nat
  includesOffset : Nat
  count : Nat

inductive Action
  | read | ended | error | successRead | successRefine | failure
  | appendRead | consume | putByte | appendCopied | increment
  | putDeclarations | putIncludes | declarationsDone | includesDone
  deriving DecidableEq

def Action.eval (run : Core.State → Nat → Core.State) (io : Outcomes) (s : Frame) : Action → Frame
  | .read => {s with item := io.item}
  | .ended => {s with ended := true}
  | .error => {s with status := io.error}
  | .successRead => {s with success := decide (s.status = 0)}
  | .successRefine => {s with success := decide (s.status = 0 ∧ s.position = s.count) && s.declarationsDone && s.includesDone}
  | .failure => {s with success := false}
  | .appendRead => {s with read := s.read ++ [s.item.toNat]}
  | .consume => {s with current := run s.current s.item.toNat}
  | .putByte => {s with success := io.writeOK}
  | .appendCopied => {s with copied := s.copied ++ [s.item.toNat]}
  | .increment => {s with position := s.position + 1}
  | .putDeclarations => {s with success := io.declarationsOK}
  | .putIncludes => {s with success := io.includesOK}
  | .declarationsDone => {s with declarationsDone := true}
  | .includesDone => {s with includesDone := true}

def Action.render : Action → List String
  | .read => ["item", ":=", "c_get", "(", "input", ")", ";"]
  | .ended => ["read_ended", ":=", "true", ";"]
  | .error => ["status", ":=", "c_error", "(", "input", ")", ";"]
  | .successRead => ["success", ":=", "status", "=", "0", ";"]
  | .successRefine => ["success", ":=", "status", "=", "0", "and", "then", "position", "=", "plan", ".", "bytes", "and", "then", "declarations_done", "and", "then", "includes_done", ";"]
  | .failure => ["success", ":=", "false", ";"]
  | .appendRead => ["read_bytes", ":=", "bytes", ".", "add", "(", "read_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  | .consume => ["model", ".", "consume", "(", "current", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  | .putByte => ["put_byte", "(", "output", ",", "character", "'", "val", "(", "item", ")", ",", "success", ")", ";"]
  | .appendCopied => ["copied_bytes", ":=", "bytes", ".", "add", "(", "copied_bytes", ",", "character", "'", "val", "(", "item", ")", ")", ";"]
  | .increment => ["position", ":=", "position", "+", "1", ";"]
  | .putDeclarations => ["put_insertion", "(", "output", ",", "model", ".", "declarations_insertion", ",", "success", ")", ";"]
  | .putIncludes => ["put_insertion", "(", "output", ",", "model", ".", "includes_insertion", ",", "success", ")", ";"]
  | .declarationsDone => ["declarations_done", ":=", "true", ";"]
  | .includesDone => ["includes_done", ":=", "true", ";"]

inductive Test
  | eof | invalidByte | exhausted | failed | declarations | includes
  deriving DecidableEq

def Test.eval (s : Frame) : Test → Bool
  | .eof => decide (s.item = -1)
  | .invalidByte => decide (s.item < 0 ∨ 255 < s.item)
  | .exhausted => decide (s.item < 0 ∨ 255 < s.item ∨ s.position = 9223372036854775807)
  | .failed => !s.success
  | .declarations => decide (s.position = s.declarationsOffset)
  | .includes => decide (s.position = s.includesOffset)

def Test.render : Test → List String
  | .eof => ["item", "=", "-", "1"]
  | .invalidByte => ["item", "not", "in", "0", "..", "255"]
  | .exhausted => ["item", "not", "in", "0", "..", "255", "or", "else", "position", "=", "model", ".", "byte_count", "'", "last"]
  | .failed => ["not", "success"]
  | .declarations => ["position", "=", "plan", ".", "declarations_offset"]
  | .includes => ["position", "=", "plan", ".", "includes_offset"]

inductive Command
  | skip | exit | action (a : Action) | sequence (a b : Command)
  | branch (condition : Test) (yes no : Command)
  deriving DecidableEq

structure Result where
  frame : Frame
  exited : Bool

def Command.eval (run : Core.State → Nat → Core.State) (io : Outcomes) (s : Frame) : Command → Result
  | .skip => ⟨s, false⟩
  | .exit => ⟨s, true⟩
  | .action a => ⟨a.eval run io s, false⟩
  | .sequence a b =>
      let first := a.eval run io s
      if first.exited then first else b.eval run io first.frame
  | .branch t yes no => if t.eval s then yes.eval run io s else no.eval run io s

mutual
def Command.render : Command → List String
  | .skip => []
  | .exit => ["exit", ";"]
  | .action a => a.render
  | .sequence a b => a.render ++ b.render
  | .branch t yes no => ["if"] ++ t.render ++ ["then"] ++ yes.render ++ no.renderElse ++ ["end", "if", ";"]
def Command.renderElse : Command → List String
  | .skip => []
  | .branch t yes no => ["elsif"] ++ t.render ++ ["then"] ++ yes.render ++ no.renderElse
  | other => ["else"] ++ other.render
end

def Command.list (commands : List Command) : Command := commands.foldr .sequence .skip
def stopFailure : Command := .list [.action .failure, .exit]
def copiedByte : Command := .list [.action .appendRead, .action .consume, .action .putByte,
  .branch .failed .exit .skip, .action .appendCopied]
def snapshot : Command := .list [.action .read,
  .branch .eof (.list [.action .ended, .action .error, .action .successRead, .exit])
    (.branch .invalidByte stopFailure .skip), copiedByte]
def insertions : Command := .branch .declarations
  (.list [.action .putDeclarations, .branch .failed .exit .skip, .action .declarationsDone])
  (.branch .includes (.list [.action .putIncludes, .branch .failed .exit .skip, .action .includesDone]) .skip)
def refine : Command := .list [.action .read,
  .branch .eof (.list [.action .ended, .action .error, .action .successRefine, .exit])
    (.branch .exhausted stopFailure .skip), insertions, copiedByte, .action .increment]

/-- Projection of one actual loop iteration. Failed insertion stops before
consumption; failed output stops after consumption. Both preserve the exact
read/scanner relation. -/
def ReadStep (run : Core.State → Nat → Core.State) (before after : Frame) : Prop :=
  (after.read = before.read ∧ after.current = before.current) ∨
  ∃ byte, byte ≤ 255 ∧ after.read = before.read ++ [byte] ∧ after.current = run before.current byte

theorem snapshot_step (run : Core.State → Nat → Core.State) (io : Outcomes) (before : Frame) :
    ReadStep run before (snapshot.eval run io before).frame := by
  by_cases eof : io.item = -1
  · simp [snapshot, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, ReadStep]
  · by_cases invalid : io.item < 0 ∨ 255 < io.item
    · simp [snapshot, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid, ReadStep]
    · have byte : io.item.toNat ≤ 255 := by omega
      cases write : io.writeOK <;>
        simp [snapshot, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid, write, ReadStep] <;> exact ⟨io.item.toNat, byte, rfl, rfl⟩

theorem refine_step (run : Core.State → Nat → Core.State) (io : Outcomes) (before : Frame) :
    ReadStep run before (refine.eval run io before).frame := by
  by_cases eof : io.item = -1
  · simp [refine, insertions, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, ReadStep]
  · by_cases invalid : io.item < 0 ∨ 255 < io.item ∨ before.position = 9223372036854775807
    · simp [refine, insertions, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid, ReadStep]
    · have byte : io.item.toNat ≤ 255 := by omega
      cases declarations : decide (before.position = before.declarationsOffset)
      · cases includes : decide (before.position = before.includesOffset)
        · cases write : io.writeOK <;>
            simp [refine, insertions, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid,
              declarations, includes, write, ReadStep] <;> exact ⟨io.item.toNat, byte, rfl, rfl⟩
        · cases includeWrite : io.includesOK <;> cases write : io.writeOK <;>
            simp [refine, insertions, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid,
              declarations, includes, includeWrite, write, ReadStep] <;> exact ⟨io.item.toNat, byte, rfl, rfl⟩
      · cases declarationWrite : io.declarationsOK <;> cases write : io.writeOK <;>
          simp [refine, insertions, copiedByte, stopFailure, Command.list, Command.eval, Action.eval, Test.eval, eof, invalid,
            declarations, declarationWrite, write, ReadStep] <;> exact ⟨io.item.toNat, byte, rfl, rfl⟩

theorem ReadStep.trace (run : Core.State → Nat → Core.State) (initial : Core.State)
    (before after : Frame) (typed : before.current.Typed)
    (history : SourceBridge.NativeScan run initial before.read before.current)
    (step : ReadStep run before after) :
    SourceBridge.NativeScan run initial after.read after.current := by
  rcases step with same | ⟨byte, valid, read, current⟩
  · rw [same.1, same.2]; exact history
  · rw [read, current]
    exact SourceBridge.NativeScan.append run initial before.current (run before.current byte)
      before.read [byte] history (.cons before.current byte [] _ typed valid (.nil _))

/-- Finite execution of the actual loop, retaining every I/O outcome and exit.
The typing premises are native State type safety, separately checked in SPARK. -/
inductive LoopRun (command : Command) (run : Core.State → Nat → Core.State) : Frame → Frame → Prop
  | stop (before : Frame) (io : Outcomes) (typed : before.current.Typed)
      (exits : (command.eval run io before).exited = true) :
      LoopRun command run before (command.eval run io before).frame
  | next (before : Frame) (io : Outcomes) (after : Frame) (typed : before.current.Typed)
      (continues : (command.eval run io before).exited = false)
      (tail : LoopRun command run (command.eval run io before).frame after) :
      LoopRun command run before after

theorem LoopRun.trace (command : Command) (run : Core.State → Nat → Core.State)
    (steps : ∀ io before, ReadStep run before (command.eval run io before).frame)
    (initial : Core.State) (before after : Frame) (execution : LoopRun command run before after)
    (history : SourceBridge.NativeScan run initial before.read before.current) :
    SourceBridge.NativeScan run initial after.read after.current := by
  induction execution with
  | stop before io typed exits => exact ReadStep.trace run initial before _ typed history (steps io before)
  | next before io after typed continues tail ih =>
      exact ih (ReadStep.trace run initial before _ typed history (steps io before))

theorem snapshot_trace (run : Core.State → Nat → Core.State) (before after : Frame)
    (empty : before.read = []) (execution : LoopRun snapshot run before after) :
    SourceBridge.NativeScan run before.current after.read after.current := by
  apply LoopRun.trace snapshot run (snapshot_step run) before.current before after execution
  rw [empty]
  exact .nil _

theorem refine_trace (run : Core.State → Nat → Core.State) (before after : Frame)
    (empty : before.read = []) (execution : LoopRun refine run before after) :
    SourceBridge.NativeScan run before.current after.read after.current := by
  apply LoopRun.trace refine run (refine_step run) before.current before after execution
  rw [empty]
  exact .nil _

end Silver.ImageModel.FilesNative
