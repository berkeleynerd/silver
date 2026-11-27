module

public import Silver.ApplicationPackageBodiesStatementArms

@[expose] public section

namespace Silver.ApplicationPackageBodies.Statement.Native
open ApplicationNative ApplicationPackages Statements

set_option backward.dsimp.instances true

def iteration (locals : Locals) : Iteration :=
  ⟨locals .appScan "result", locals .number "first", locals .number "last", locals .interval "bounds", locals .truth "definite"⟩

structure LoopFrame where
  scope : Input
  current : Iteration
  inner : Predicate.ParseContext
  inside : ApplicationScan

def frame (locals : Locals) : LoopFrame :=
  ⟨source locals, iteration locals, locals .parseContext "inner", locals .appScan "inside"⟩

def LoopFrame.withValues (current : LoopFrame) (values : List Integer.Interval) : LoopFrame :=
  {current with inside := withFacts current.inside {current.inside.scan.facts with values}}

def LoopFrame.copy (current : LoopFrame) (index : Nat) : LoopFrame :=
  current.withValues (current.inside.scan.facts.values.set (index - 1)
    (current.current.value.scan.facts.values.getD (index - 1) .empty))

def copySlot (values : List Integer.Interval) (destination : List Integer.Interval) (index : Nat) : List Integer.Interval :=
  destination.set index (values.getD index .empty)

def copySlots (values destination : List Integer.Interval) (count : Nat) : List Integer.Interval :=
  (List.range count).foldl (copySlot values) destination

theorem copySlots_succ (values destination : List Integer.Interval) (count : Nat) :
    copySlots values destination (count + 1) =
      (copySlots values destination count).set count (values.getD count .empty) := by
  simp [copySlots, copySlot, List.range_succ, List.foldl_append]

@[simp] theorem copySlots_length (values destination : List Integer.Interval) (count : Nat) :
    (copySlots values destination count).length = destination.length := by
  induction count with
  | zero => rfl
  | succ count ih => rw [copySlots_succ, List.length_set, ih]

theorem copySlots_lookup (values destination : List Integer.Interval) (count index : Nat)
    (bounded : index < destination.length) :
    (copySlots values destination count)[index]? =
      if index < count then some (values.getD index .empty) else destination[index]? := by
  induction count with
  | zero => simp [copySlots]
  | succ count ih =>
    rw [copySlots_succ]
    by_cases same : count = index
    · subst count
      simp [List.getElem?_set_self (by simpa using bounded : index < (copySlots values destination index).length)]
    · rw [List.getElem?_set_ne same, ih]
      by_cases prior : index < count
      · simp [prior, Nat.lt_succ_of_lt prior]
      · simp [prior, show ¬ index < count + 1 by omega]

/-- The native destination has the outer discriminant plus one. The final slot is the
iterator even when the caller supplies a widened flow of a different length. -/
theorem copy_append_bound (values : List Integer.Interval) (count : Nat) (bound : Integer.Interval) :
    (copySlots values (List.replicate (count + 1) .empty) values.length).set count bound =
      (List.range count).map (fun i => values.getD i .empty) ++ [bound] := by
  apply List.ext_getElem?
  intro i
  by_cases prior : i < count
  · rw [List.getElem?_set_ne (by omega), List.getElem?_append_left (by simpa using prior),
      List.getElem?_map, List.getElem?_range prior, Option.map_some,
      copySlots_lookup _ _ _ _ (by simpa using Nat.lt_succ_of_lt prior)]
    by_cases present : i < values.length
    · simp [present]
    · simp [present, List.getD_eq_getElem?_getD,
        List.getElem?_replicate_of_lt (Nat.lt_succ_of_lt prior)]
  · by_cases last : i = count
    · subst i
      rw [List.getElem?_set_self (by simp), List.getElem?_append_right (by simp)]
      simp
    · have beyond : count + 1 ≤ i := by omega
      rw [List.getElem?_eq_none (by simpa using beyond), List.getElem?_eq_none (by simpa using beyond)]

theorem copyFrame_fold (indexes : List Nat) (current : LoopFrame) :
    indexes.foldl LoopFrame.copy current =
      current.withValues (indexes.foldl (fun acc i => copySlot current.current.value.scan.facts.values acc (i - 1))
        current.inside.scan.facts.values) := by
  induction indexes generalizing current with
  | nil => rfl
  | cons i rest ih =>
    rw [List.foldl_cons, ih]
    rfl

private theorem copied_step (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (body : C) (next : LoopFrame → Option ApplicationScan) (leave : Continuation)
    (index : Nat) (eqn : copyValues = .forFlowValues "i" facts.expression body) :
    body.eval (functions calls valid) (procedures calls) fuel (locals.set .number "i" index)
      (fun current => next (frame current)) leave = next ((frame locals).copy index) := by
  cases eqn
  dsimp only [Statements.Command.list, List.foldr, Statements.Command.eval, Place.expression, Place.set, Expr.eval,
    Index.get, Index.set, Field.get, Field.set, facts, insideFacts, insideScan, inside, scan, result,
    frame, iteration, source, LoopFrame.copy, LoopFrame.withValues, withFacts]
  simp [Locals.set]

private theorem copied_range (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (body : C) (next : LoopFrame → Option ApplicationScan) (indexes : List Nat)
    (eqn : copyValues = .forFlowValues "i" facts.expression body) :
    flowRange "i" (fun current k e => body.eval (functions calls valid) (procedures calls) fuel current k e)
      (fun current => next (frame current)) indexes locals =
    next (indexes.foldl LoopFrame.copy (frame locals)) := by
  induction indexes generalizing locals with
  | nil => rfl
  | cons i rest ih =>
    rw [flowRange, funext ih]
    exact copied_step calls valid fuel locals body (fun f => next (rest.foldl LoopFrame.copy f)) _ i eqn

theorem copyValues_meaning (calls : Statement.Calls) (valid : ValidFlow) (fuel : Nat) (locals : Locals)
    (next : LoopFrame → Option ApplicationScan) (leave : Continuation) :
    copyValues.eval (functions calls valid) (procedures calls) fuel locals (fun current => next (frame current)) leave =
    let current := frame locals
    let values := current.current.value.scan.facts.values
    next (current.withValues (copySlots values current.inside.scan.facts.values values.length)) := by
  have shape : ∃ body, copyValues = .forFlowValues "i" facts.expression body := ⟨_, rfl⟩
  obtain ⟨body, eqn⟩ := shape
  have restore (current : Locals) : frame (current.set .number "i" (locals .number "i")) = frame current := by
    simp [frame, iteration, source, Locals.set]
  rw [eqn, Statements.Command.eval]
  simp only [restore]
  rw [copied_range calls valid fuel locals body next _ eqn, copyFrame_fold]
  simp only [List.foldl_map, Nat.add_sub_cancel]
  rfl

end Silver.ApplicationPackageBodies.Statement.Native
