module

public import Silver.ApplicationPackageProcedureControl
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

/-! Operational meaning of procedure loops. Every returning path propagates the
original procedure return; exhaustion is eliminated by progress on the complete
callee-contract domain, rather than imposed as a source-membership condition. -/
namespace Silver.ApplicationPackageProcedure
open ApplicationNative

theorem eval_nothing {Fn : Ty → Type} (functions : Calls Fn) (procedures : ProcedureCalls)
    (fuel : Nat) :
    Command.eval functions procedures fuel .nothing = fun locals => some ⟨locals, false⟩ := rfl

theorem eval_assign {Fn : Ty → Type} {ty : Ty} (functions : Calls Fn) (procedures : ProcedureCalls)
    (fuel : Nat) (place : Place Fn ty) (value : Expr Fn ty) :
    Command.eval functions procedures fuel (.assign place value) = fun locals =>
      some ⟨place.set functions locals (value.eval functions locals), false⟩ := rfl

theorem eval_sequence {Fn : Ty → Type} (functions : Calls Fn) (procedures : ProcedureCalls)
    (fuel : Nat) (first rest : Command Fn) :
    Command.eval functions procedures fuel (.sequence first rest) = fun locals =>
      (first.eval functions procedures fuel locals).bind (fun result =>
        result.bind (rest.eval functions procedures fuel)) := rfl

theorem eval_choose {Fn : Ty → Type} (functions : Calls Fn) (procedures : ProcedureCalls)
    (fuel : Nat) (test : Expr Fn .truth) (yes no : Command Fn) :
    Command.eval functions procedures fuel (.choose test yes no) = fun locals =>
      if test.eval functions locals then yes.eval functions procedures fuel locals
      else no.eval functions procedures fuel locals := rfl

theorem eval_returned {Fn : Ty → Type} (functions : Calls Fn) (procedures : ProcedureCalls)
    (fuel : Nat) :
    Command.eval functions procedures fuel .returned = fun locals => some ⟨locals, true⟩ := rfl

@[simp] theorem Outcome.bind_done (result : Outcome) :
    result.bind (fun locals => some ⟨locals, false⟩) = some result := by
  cases result with
  | mk locals returned => cases returned <;> rfl

inductive WhileExecution (test : Locals → Bool) (body : Locals → Option Outcome) :
    Locals → Outcome → Prop
  | stopped {locals} : test locals = false → WhileExecution test body locals ⟨locals, false⟩
  | returned {locals result} : test locals = true → body locals = some result → result.returned = true →
      WhileExecution test body locals result
  | continued {locals next result} : test locals = true → body locals = some next → next.returned = false →
      WhileExecution test body next.locals result → WhileExecution test body locals result

theorem whileLocals_sound {test : Locals → Bool} {body : Locals → Option Outcome} {fuel : Nat}
    {locals : Locals} {result : Outcome} (found : whileLocals test body fuel locals = some result) :
    WhileExecution test body locals result := by
  induction fuel generalizing locals with
  | zero => simp only [whileLocals, reduceCtorEq] at found
  | succ fuel induction =>
      simp only [whileLocals] at found
      split at found
      · rename_i tested
        simp only [Option.bind_eq_some_iff] at found
        obtain ⟨step, selected, rest⟩ := found
        unfold Outcome.bind at rest
        split at rest
        · rename_i returned
          cases rest
          exact .returned tested selected returned
        · rename_i returned
          exact .continued tested selected (Bool.eq_false_iff.mpr returned) (induction rest)
      · rename_i tested
        cases found
        exact .stopped (Bool.eq_false_iff.mpr tested)

theorem WhileExecution.preserves {test : Locals → Bool} {body : Locals → Option Outcome}
    {locals : Locals} {result : Outcome} (execution : WhileExecution test body locals result)
    (property : Locals → Prop)
    (preserved : ∀ current outcome, property current → body current = some outcome → property outcome.locals)
    (initial : property locals) : property result.locals := by
  induction execution with
  | stopped => exact initial
  | returned _ selected _ => exact preserved _ _ initial selected
  | continued _ selected _ _ induction => exact induction (preserved _ _ initial selected)

theorem whileLocals_total {test : Locals → Bool} {body : Locals → Option Outcome}
    (valid : Locals → Prop) (measure : Locals → Nat)
    (stepTotal : ∀ locals, valid locals → test locals = true →
      ∃ result, body locals = some result ∧
        (result.returned = false → valid result.locals ∧ measure result.locals < measure locals))
    {locals : Locals} (legal : valid locals) {fuel : Nat} (enough : measure locals + 1 ≤ fuel) :
    ∃ result, whileLocals test body fuel locals = some result := by
  induction fuel generalizing locals with
  | zero => omega
  | succ fuel induction =>
      simp only [whileLocals]
      split
      · rename_i tested
        obtain ⟨step, selected, preserved⟩ := stepTotal locals legal tested
        rw [selected]
        simp only [Option.bind_some, Outcome.bind]
        split
        · exact ⟨step, rfl⟩
        · rename_i notReturned
          have progress := preserved (Bool.eq_false_iff.mpr notReturned)
          apply induction progress.1
          omega
      · exact ⟨_, rfl⟩

inductive ForExecution (body : Locals → Option Outcome) (name : String) :
    List Nat → Locals → Outcome → Prop
  | empty {locals} : ForExecution body name [] locals ⟨locals, false⟩
  | returned {value rest locals result} : body (locals.set .number name value) = some result →
      result.returned = true → ForExecution body name (value :: rest) locals result
  | continued {value rest locals next result} : body (locals.set .number name value) = some next →
      next.returned = false → ForExecution body name rest next.locals result →
      ForExecution body name (value :: rest) locals result

theorem forLocals_sound {body : Locals → Option Outcome} {name : String} {values : List Nat}
    {locals : Locals} {result : Outcome} (found : forLocals body name values locals = some result) :
    ForExecution body name values locals result := by
  induction values generalizing locals with
  | nil => cases found; exact .empty
  | cons value rest induction =>
      simp only [forLocals, Option.bind_eq_some_iff] at found
      obtain ⟨step, selected, found⟩ := found
      unfold Outcome.bind at found
      split at found
      · rename_i returned
        cases found
        exact .returned selected returned
      · rename_i notReturned
        exact .continued selected (Bool.eq_false_iff.mpr notReturned) (induction found)

theorem forLocals_total {body : Locals → Option Outcome} {name : String}
    (valid : Locals → Prop) (values : List Nat)
    (stepTotal : ∀ value ∈ values, ∀ locals, valid locals →
      ∃ result, body (locals.set .number name value) = some result ∧
        (result.returned = false → valid result.locals))
    {locals : Locals} (legal : valid locals) :
    ∃ result, forLocals body name values locals = some result := by
  induction values generalizing locals with
  | nil => exact ⟨_, rfl⟩
  | cons value rest induction =>
      obtain ⟨step, selected, preserved⟩ := stepTotal value (by simp) locals legal
      simp only [forLocals, selected, Option.bind_some, Outcome.bind]
      split
      · exact ⟨step, rfl⟩
      · rename_i notReturned
        exact induction (fun index member current currentValid =>
          stepTotal index (by simp only [List.mem_cons]; exact Or.inr member) current currentValid)
          (preserved (Bool.eq_false_iff.mpr notReturned))

end Silver.ApplicationPackageProcedure
