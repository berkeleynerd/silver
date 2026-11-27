module

public import Silver.ApplicationPackageCompletionLayout

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose ApplicationPackageBodies ApplicationPackageDeclarations ApplicationPackageFormalStorage

theorem objectStep_capacity {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {localObject : Bool} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) (initial : frame.scalarNames.length ≤ ScalarExpression.maxBindings) :
    out.frame.scalarNames.length ≤ ScalarExpression.maxBindings := by
  obtain ⟨stored, sub, _⟩ := objectStep_storage parsed present
  exact stored.scalarCapacity (Nat.le_trans sub.length_le initial)

theorem stateHistory_capacity {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls} {text : Source}
    {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (initial : before.globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    after.globals.scalarNames.length ≤ ScalarExpression.maxBindings := by
  induction history with
  | finished => exact initial
  | @added row following final phase chosen capacity parsed advances writable rest ih =>
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    exact objectStep_capacity ((original row List.mem_cons_self).symm.trans parsed) (by omega) initial

theorem localHistory_capacity {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (initial : before.frame.scalarNames.length ≤ ScalarExpression.maxBindings) :
    after.frame.scalarNames.length ≤ ScalarExpression.maxBindings := by
  induction history with
  | finished => exact initial
  | @added row final following atBegin apart parsed advances rest ih =>
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    exact objectStep_capacity ((original row List.mem_cons_self).symm.trans parsed) (by omega) initial

theorem routineFrame_capacity {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (parsed : ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position = after)
    (present : after.position ≠ 0) (initial : globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    after.scalarNames.length ≤ ScalarExpression.maxBindings := by
  obtain ⟨hidden, kept, installed⟩ := routineFrame_tables hide append parsed present
  apply installed.scalarCapacity
  apply Nat.le_trans kept.integers.length_le
  simpa only [ApplicationPackageRoutineFrame.entryFrame, body, ScalarExpression.bodyEnvironment_length] using initial

theorem outputFrame_capacity {calls : CompletionCalls} {text : Source} {info : PackageBindings.Metadata}
    {item : PackageBindings.Routine} {locals : InitializationFrame} (outputs : OutputFrames calls text info item locals)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    (initial : locals.frame.scalarNames.length ≤ ScalarExpression.maxBindings) :
    outputs.completed.scalarNames.length ≤ ScalarExpression.maxBindings := by
  have first := (outputInitializers_frame _ outputs.read).1
  have retained := congrArg ParserState.scalarNames first
  apply (outputs_stored append text info _ outputs.installed).scalarCapacity
  rw [retained]
  exact initial

end Silver.ApplicationPackageObjectRows
