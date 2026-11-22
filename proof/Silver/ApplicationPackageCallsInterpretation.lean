module

public import Silver.ApplicationPackageCallsNative
public import Silver.ApplicationNativeLoopFacts

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def namedParameters (locals : Locals) : Source × PackageBindings.Metadata × Nat × Nat :=
  (locals .source "text", locals .metadata "info", locals .number "first", locals .number "last")

def namedStep (calls : ApplicationPackageCalls.Calls)
    (parameters : Source × PackageBindings.Metadata × Nat × Nat) (index previous : Nat) : Nat :=
  if calls.sameName parameters.1 ⟨parameters.2.2.1, parameters.2.2.2⟩
      (parameters.2.1.parameterAt index).specName then index else previous

def namedBody : C :=
  .choose (call3 .sameName text (.nameSpan first last) (.field .formalSpecName (.index .formal info i)))
    (.assign (.variable "slot") i) .nothing

theorem named_body_denotation (calls : ApplicationPackageCalls.Calls)
    (locals : Locals) (next : Locals → ApplicationPackages.ApplicationCall) :
    namedBody.eval (resultType := .appCall) (imported calls) locals next =
      next (locals.set .number "slot"
        (namedStep calls (namedParameters locals) (locals .number "i") (locals .number "slot"))) := by
  dsimp only [namedBody, Command.eval, Place.set, Expr.eval, imported, call3, call2, call1,
    text, first, last, info, i, Field.get, Index.get, namedStep, namedParameters]
  split
  · rfl
  · rw [Locals.set_unchanged]

def namedRange (item : PackageBindings.Routine) : List Nat :=
  (List.range (item.formalFirst + item.count - 1 + 1 - item.formalFirst)).map (item.formalFirst + ·)

theorem named_scan_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    namedScan.eval (resultType := .appCall) (imported calls) locals next =
      next (locals.set .number "slot"
        ((namedRange (locals .routine "item")).foldl
          (fun previous index => namedStep calls (namedParameters locals) index previous)
          (locals .number "slot"))) := by
  change forValues (fun current continuation => namedBody.eval (resultType := .appCall) (imported calls) current continuation)
    "i" (namedRange (locals .routine "item")) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [forValues_accumulator (resultType := .appCall) (accumulatorType := .number)
    _ namedParameters (namedStep calls) "i" "slot" (Or.inr (by decide))
    (by intros; simp [namedParameters, Locals.set])
    (by intros; simp [namedParameters, Locals.set])
    (named_body_denotation calls) _ locals _
    (by intros; simp only [Locals.set_shadow])]
  rw [Locals.set_commute_names _ .number .number "slot" "i" _ _ (by decide),
    Locals.set_unchanged]

theorem namedRange_of_positive (item : PackageBindings.Routine) (positive : 0 < item.count) :
    namedRange item = formalSlots item := by
  have equal : item.formalFirst + item.count - 1 + 1 - item.formalFirst = item.count := by omega
  simp only [namedRange, formalSlots, equal]

theorem named_scan_from_zero (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) (positive : 0 < (locals .routine "item").count)
    (zero : locals .number "slot" = 0) :
    namedScan.eval (resultType := .appCall) (imported calls) locals next =
      next (locals.set .number "slot"
        (namedSlot calls (locals .source "text") (locals .metadata "info") (locals .routine "item")
          (locals .number "first") (locals .number "last"))) := by
  rw [named_scan_denotation, namedRange_of_positive _ positive, zero]
  rfl


/-- The reset pass leaves all call arguments untouched and uses declared ranges
only for the visible Integer cells in the accumulated write set. -/
def resetLocals (calls : ApplicationPackageCalls.Calls) (locals : Locals) : Locals :=
  let text := locals .source "text"
  let context := locals .parseContext "context"
  let info := locals .metadata "info"
  let index := locals .number "s"
  let writes := locals .stateSet "call_writes"
  let state := info.stateAt index
  if PackageBindings.StateSet.get writes index = true ∧
      calls.visibleState text context info index = true ∧ state.kind = .integer then
    let scalar := calls.scalarLookup text context.scalarNames state.name.first state.name.after
    let updated := locals.set .number "scalar" scalar
    if scalar = 0 then updated else
      updated.set .appCall "result" (replaceScalar (locals .appCall "result") scalar
        (ScalarExpression.binding context.scalarNames scalar).declaredBounds)
  else locals

theorem reset_body_denotation (calls : ApplicationPackageCalls.Calls)
    (locals : Locals) (next : Locals → ApplicationPackages.ApplicationCall) :
    resetCommands.eval (resultType := .appCall) (imported calls) locals next =
      next (resetLocals calls locals) := by
  dsimp only [resetCommands, Command.eval, Command.list, List.foldr, Place.set,
    Place.expression, Expr.eval, imported, call4, call3, call2, call1,
    text, context, info, s, scalar, callWrites, result, output, scan, facts,
    Field.get, Field.set, Index.get, Index.set, resetLocals, replaceScalar, PackageBindings.StateSet.get]
  simp only [Bool.and_eq_true, decide_eq_true_eq, and_assoc]
  split
  · rename_i selected
    simp only [Locals.set, ↓reduceDIte, ↓reduceIte]
    by_cases zero : calls.scalarLookup (locals .source "text")
        (locals .parseContext "context").scalarNames
        ((locals .metadata "info").stateAt (locals .number "s")).name.first
        ((locals .metadata "info").stateAt (locals .number "s")).name.after = 0
    · simp [zero]
    · simp [zero, Predicate.ActiveFlow.replace]
  · rfl

theorem resetLocals_result (calls : ApplicationPackageCalls.Calls) (locals : Locals) :
    (resetLocals calls locals) .appCall "result" =
      resetState calls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .stateSet "call_writes")
        (locals .appCall "result") (locals .number "s") := by
  dsimp only [resetLocals, resetState]
  split
  · split
    · rename_i zero
      simp [Locals.set, replaceScalar, Predicate.ActiveFlow.replace, zero]
    · simp [Locals.set]
  · rfl

end Silver.ApplicationPackageCalls.Native.Call
