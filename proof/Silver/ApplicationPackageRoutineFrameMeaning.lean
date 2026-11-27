module

public import Silver.ApplicationPackageRoutineFrameInterpretation

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame.Native
open ApplicationNative ApplicationPackageBodies Compose

set_option backward.dsimp.instances true

def prepareFormals (calls : ApplicationPackageRoutineFrame.Calls) (current : Context)
    (frame : ParserState) : Option ParserState :=
  if formalRangeRejected current.info current.item then none
  else passParameters calls current (formalIndices current.item) frame

theorem parameters_sourceOrder (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    parameters.eval (modelFunctions calls) (modelProcedures calls) locals next =
      if decide (0 < (locals .routine "item").count) then
        if formalGuard.eval (modelFunctions calls) locals then invalidState
        else formalPasses.eval (modelFunctions calls) (modelProcedures calls) locals next
      else next locals := rfl

theorem parameters_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    parameters.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result")) =
      match prepareFormals calls (context locals) (locals .state "result") with
      | none => invalidState
      | some value => next (context locals) value := by
  rw [parameters_sourceOrder]
  dsimp only [formalGuard, formalFirst, formalCount, item, info, Expr.eval, Field.get]
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  by_cases positive : 0 < (locals .routine "item").count
  · simp only [positive, ↓reduceIte]
    rw [formalPasses_meaning]
    rw [nativeIndices_formal (context locals).item (show 0 < (context locals).item.count from positive)]
    simp only [prepareFormals, formalRangeRejected, context, positive, true_and, decide_eq_true_eq, or_assoc]
    split <;> simp_all
    cases passParameters calls (context locals) (formalIndices (locals .routine "item")) (locals .state "result") with
    | none => rfl
    | some value => rfl
  · have empty : (locals .routine "item").count = 0 := by omega
    simp [prepareFormals, formalRangeRejected, context, empty,
      formalIndices, passParameters, ApplicationPackageRoutineFrame.parameters]

theorem finalState_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    finalState.eval (modelFunctions calls) (modelProcedures calls) locals next =
      if calls.validState (context locals).text (locals .state "result")
      then locals .state "result" else invalidState := by
  dsimp only [finalState, Control.Command.eval, Control.Command.returned, Control.Command.nothing,
    ApplicationNative.Command.eval, Expr.eval, Place.expression, result, text, modelFunctions]
  simp only [context]
  by_cases valid : calls.validState (locals .source "text") (locals .state "result") = true <;> simp_all

def finishCommands : C := .sequence parameters finalState

def finish (calls : ApplicationPackageRoutineFrame.Calls) (current : Context)
    (frame : ParserState) : ParserState :=
  match prepareFormals calls current frame with
  | none => invalidState
  | some value => if calls.validState current.text value then value else invalidState

theorem finishCommands_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    finishCommands.eval (modelFunctions calls) (modelProcedures calls) locals next =
      finish calls (context locals) (locals .state "result") := by
  change parameters.eval _ _ locals (fun current => finalState.eval _ _ current next) = _
  have finalEquation := funext (fun current => finalState_meaning calls current next)
  rw [finalEquation]
  exact parameters_meaning calls locals
    (fun current frame => if calls.validState current.text frame then frame else invalidState)

def forgotten (frame : ParserState) : ParserState :=
  {frame with booleanNames := frame.booleanNames.map forgetMutable}

def executeFrame (calls : ApplicationPackageRoutineFrame.Calls) (current : Context)
    (routine : Nat) (frame : ParserState) : ParserState :=
  if routine > current.info.routines.length then invalidState
  else finish calls current (forgotten frame)

theorem commands_sourceOrder (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    commands.eval (modelFunctions calls) (modelProcedures calls) locals next =
      if decide (locals .number "routine" > (locals .metadata "info").routines.length) then invalidState
      else forgetLoop.eval (modelFunctions calls) (modelProcedures calls) locals
        (fun current => finishCommands.eval (modelFunctions calls) (modelProcedures calls) current next) := rfl

theorem commands_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    commands.eval (modelFunctions calls) (modelProcedures calls) locals next =
      executeFrame calls (context locals) (locals .number "routine") (locals .state "result") := by
  rw [commands_sourceOrder, forgetLoop_meaning, finishCommands_meaning]
  rw [context_frame, Locals.set_get_same]
  by_cases inactive : locals .number "routine" > (locals .metadata "info").routines.length <;>
    simp [executeFrame, context, forgotten, inactive]

def initialFrame (calls : ApplicationPackageRoutineFrame.Calls) (globals : ParserState)
    (position : Nat) : ParserState :=
  {globals with position, pure := true, scalarNames := calls.bodyEnvironment globals.scalarNames}

def initialized (calls : ApplicationPackageRoutineFrame.Calls) (locals : Locals) : Locals :=
  declarations.foldl (Declaration.eval (modelFunctions calls)) locals

theorem initialized_context (calls : ApplicationPackageRoutineFrame.Calls) (locals : Locals) :
    context (initialized calls locals) =
      ⟨locals .source "text", locals .metadata "info",
        (locals .metadata "info").routineAt (locals .number "routine")⟩ := by
  dsimp only [initialized, declarations, List.foldl, Declaration.eval, Declaration.names,
    Expr.eval, Updates.eval, Field.set, Index.get, globals, info, modelFunctions]
  simp [context, Locals.set]

theorem initialized_frame (calls : ApplicationPackageRoutineFrame.Calls) (locals : Locals) :
    initialized calls locals .state "result" =
      initialFrame calls (locals .state "globals") (locals .number "position") := by
  dsimp only [initialized, declarations, List.foldl, Declaration.eval, Declaration.names,
    Expr.eval, Updates.eval, Field.set, Field.get, Index.get, globals, info, modelFunctions]
  simp [Locals.set, initialFrame]

theorem initialized_routine (calls : ApplicationPackageRoutineFrame.Calls) (locals : Locals) :
    initialized calls locals .number "routine" = locals .number "routine" := by
  dsimp only [initialized, declarations, List.foldl, Declaration.eval, Declaration.names]
  simp [Locals.set]

theorem executeFrame_entry (calls : ApplicationPackageRoutineFrame.Calls) (text : Source)
    (globals : ParserState) (info : PackageBindings.Metadata) (routine position : Nat) :
    executeFrame calls ⟨text, info, info.routineAt routine⟩ routine (initialFrame calls globals position) =
      routineFrame calls text globals info routine position := by
  unfold executeFrame routineFrame withItem
  by_cases inactive : routine > info.routines.length
  · simp only [inactive, ↓reduceIte]
  · simp only [inactive, ↓reduceIte]
    unfold finish prepareFormals passParameters
    change (match (if formalRangeRejected info (info.routineAt routine) then none else
      (ApplicationPackageRoutineFrame.parameters
        (hideParameter calls text info) (formalIndices (info.routineAt routine))
        (entryFrame calls globals position)).bind
        (ApplicationPackageRoutineFrame.parameters (appendParameter calls info)
          (formalIndices (info.routineAt routine)))) with
      | none => invalidState
      | some value => if calls.validState text value then value else invalidState) = _
    by_cases rejected : formalRangeRejected info (info.routineAt routine) = true
    · simp only [rejected, ↓reduceIte]
    · simp only [rejected]
      cases ApplicationPackageRoutineFrame.parameters (hideParameter calls text info)
        (formalIndices (info.routineAt routine)) (entryFrame calls globals position) <;> rfl

theorem body_meaning (calls : ApplicationPackageRoutineFrame.Calls) (locals : Locals) :
    body.eval (modelFunctions calls) (modelProcedures calls) locals =
      routineFrame calls (locals .source "text") (locals .state "globals")
        (locals .metadata "info") (locals .number "routine") (locals .number "position") := by
  change commands.eval _ _ (initialized calls locals) (fun _ => invalidState) = _
  rw [commands_meaning, initialized_context, initialized_frame, initialized_routine]
  exact executeFrame_entry calls _ _ _ _ _

end Silver.ApplicationPackageRoutineFrame.Native
