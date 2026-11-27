module

public import Silver.ApplicationNativeCommands

@[expose] public section

namespace Silver.ApplicationPackageBodies.StatementValues
open ApplicationNative

/-- Native Dynamic_First is observed here only by its nonzero test. -/
theorem dynamic_context (calls : Calls Fn) (locals : Locals) (scan : Predicate.ScanResult)
    (given : locals .parseContext "context" = Predicate.contextOf scan) :
    (Expr.contextHasDynamic (Expr.variable "context") : Expr Fn .truth).eval calls locals =
      decide (scan.state.dynamicFirst ≠ 0) := by
  dsimp only [Expr.eval]
  rw [given]
  rfl

theorem array_selector (context : Predicate.ParseContext) (index : Nat) :
    Index.get .arrayItem (Property.get .contextArrays context) index =
      ArrayBindings.binding context.arrayNames index := rfl

theorem metadata_types (context : Predicate.ParseContext) :
    (Property.get .contextArrays context).types = context.arrayTypes := rfl

theorem native_range_first (calls : Calls Fn) (locals : Locals) (flow : Expr Fn .activeFlow) :
    (Expr.flowValuesFirst flow).eval calls locals = 1 := rfl

theorem native_interval (calls : Calls Fn) (locals : Locals) (lower upper : Expr Fn .integer) :
    (Expr.intervalValue lower upper).eval calls locals = ⟨lower.eval calls locals, upper.eval calls locals⟩ := rfl

theorem condition_storage (prior : Predicate.ConditionResult) :
    Initialization.value .conditionResult prior = prior := rfl

def conditionLocal (count : Expr Fn .number) : Declaration Fn :=
  { type := .conditionResult, name := "condition", typeName := ["condition_result"], constraint := some count, initial := none }

theorem condition_allocated (calls : Calls Fn) (locals : Locals) (count : Expr Fn .number) :
    (conditionLocal count).Allocated calls locals ↔
      (locals .conditionResult "condition").whenTrue.count = count.eval calls locals ∧
      (locals .conditionResult "condition").whenFalse.count = count.eval calls locals := by
  simp [Declaration.Allocated, conditionLocal, Declaration.names]

end Silver.ApplicationPackageBodies.StatementValues
