module

public import Silver.ApplicationPackageCallsReadPhase
public import Silver.ApplicationPackageCallsDeclarationMeaning

@[expose] public section

namespace Silver.ApplicationPackageCalls.Native.Call
open ApplicationNative

/-- The raw entry branches reject an absent callee and an invalid active
parameter-table window. Every other incoming store reaches the actual reader. -/
def entryCommands : C := .list [
  .choose (.eq callee (.number 0)) returnFailure .nothing,
  .assign (.variable "item") (.index .routine info callee),
  .assign callWrites (.field .routineMayWrite item),
  .choose (.andThen (.gt count (.number 0)) (.group (.orElse
    (.orElse (.eq formalFirst (.number 0)) (.gt formalFirst (.field .parameterCount info)))
    (.gt count (.add (.sub (.field .parameterCount info) formalFirst) (.number 1)))))) returnFailure .nothing,
  .assign (.variable "cursor_at") (.field .referenceAfter reference)]

def entered (locals : Locals) (item : PackageBindings.Routine) : Locals :=
  ((locals.set .routine "item" item).set .stateSet "call_writes" item.mayWrite).set .number "cursor_at"
    (locals .reference "reference").after

abbrev InvalidWindow (info : PackageBindings.Metadata) (item : PackageBindings.Routine) : Prop :=
  0 < item.count ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
    item.count > info.parameters.length - item.formalFirst + 1)

theorem entry_commands_denotation (calls : ApplicationPackageCalls.Calls) (locals : Locals)
    (next : Locals → ApplicationPackages.ApplicationCall) :
    entryCommands.eval (resultType := .appCall) (imported calls) locals next =
      let index := locals .number "callee"
      let info := locals .metadata "info"
      let item := info.routineAt index
      if index = 0 then locals .appCall "failure" else
      if InvalidWindow info item then locals .appCall "failure" else next (entered locals item) := by
  dsimp only [entryCommands, Command.list, List.foldr, Command.eval, Place.set, Place.expression, Expr.eval,
    Field.get, Index.get, callee, info, item, count, formalFirst, reference, callWrites, returnFailure, failure,
    entered, InvalidWindow]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, Bool.and_eq_true, Bool.or_eq_true, decide_eq_true_eq]
  apply ite_congr
  · exact propext ⟨fun h => of_decide_eq_true h, fun h => decide_eq_true h⟩
  · intro _; rfl
  · intro _
    apply ite_cond_congr
    simp only [or_assoc]

/-- The projections retain only the source parameters, initialized arrays and
failure return that the remaining commands use. Local scratch is unrestricted. -/
def initialInputs (calls : ApplicationPackageCalls.Calls) (locals : Locals) (item : PackageBindings.Routine) : AliasInputs :=
  ⟨locals .source "text", locals .parseContext "context", locals .appScan "input", locals .metadata "info",
   locals .number "position", locals .routineKind "kind", item, List.replicate PackageBindings.maxFormals {},
   item.mayWrite, (calls.reference (locals .source "text") (locals .number "position")).after,
   ApplicationPackageCalls.failure (locals .appScan "input")⟩

theorem entered_projections (calls : ApplicationPackageCalls.Calls) (locals : Locals) (item : PackageBindings.Routine) :
    let frame := entered (declared calls locals) item
    aliasInputs frame = initialInputs calls locals item ∧ frameOf frame =
      initialActualFrame (locals .appScan "input") item (calls.reference (locals .source "text") (locals .number "position")).after := by
  obtain ⟨_, failed, referenceVal, resultVal, cells, seenVal, namedVal⟩ := declared_values calls locals
  obtain ⟨textVal, contextVal, inputVal, infoVal, posVal, kindVal⟩ := declared_inputs calls locals
  dsimp only [entered, aliasInputs, initialInputs, frameOf, initialActualFrame]
  simp (disch := decide) only [Locals.set_get_same, Locals.set_get_other, failed, referenceVal, resultVal,
    cells, seenVal, namedVal, textVal, contextVal, inputVal, infoVal, posVal, kindVal, and_self]

end Silver.ApplicationPackageCalls.Native.Call
