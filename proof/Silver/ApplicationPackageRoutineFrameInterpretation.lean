module

public import Silver.ApplicationPackageRoutineFrameNative

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame.Native
open ApplicationNative ApplicationPackageFrames Compose

set_option backward.dsimp.instances true

theorem set_getD_same {α : Type} (items : List α) (index : Nat) (fallback : α) :
    items.set index (items.getD index fallback) = items := by
  induction items generalizing index with
  | nil => rfl
  | cons head tail induction =>
      cases index with
      | zero => rfl
      | succ index => simpa using congrArg (head :: ·) (induction index)

def forgetAt (frame : ParserState) (index : Nat) : ParserState :=
  {frame with booleanNames := updateRow forgetMutable {} frame.booleanNames (index - 1)}

theorem forgetBody_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    forgetBody.eval (modelFunctions calls) (modelProcedures calls) locals next =
      next (locals.set .state "result" (forgetAt (locals .state "result") (locals .number "i"))) := by
  dsimp only [forgetBody, Control.Command.eval, Control.Command.assign, Control.Command.nothing,
    ApplicationNative.Command.eval, Place.expression, Place.set, Expr.eval, Field.get, Field.set,
    Index.get, Index.set, result]
  unfold BooleanBindings.binding forgetAt updateRow forgetMutable
  split
  · rename_i mutable
    simp only [mutable]
  · simp only [set_getD_same, Locals.set_unchanged]

theorem forgetSteps (values : List Nat) (frame : ParserState) :
    (values.map (· + 1)).foldl forgetAt frame =
      {frame with booleanNames := values.foldl (updateRow forgetMutable {}) frame.booleanNames} := by
  induction values generalizing frame with
  | nil => rfl
  | cons value rest induction =>
      simp only [List.map_cons, List.foldl_cons, induction, forgetAt, Nat.add_sub_cancel]

theorem forgetLoop_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Locals → ParserState) :
    forgetLoop.eval (modelFunctions calls) (modelProcedures calls) locals next =
      next (locals.set .state "result" {(locals .state "result") with
        booleanNames := (locals .state "result").booleanNames.map forgetMutable}) := by
  change forValues (resultType := .state)
    (fun current continuation => forgetBody.eval (modelFunctions calls) (modelProcedures calls) current continuation)
    "i" ((List.range (locals .state "result").booleanNames.length).map (1 + ·)) locals
    (fun updated => next (updated.set .number "i" (locals .number "i"))) = _
  rw [show (fun i : Nat => 1 + i) = (fun i => i + 1) by funext i; omega]
  rw [forValues_state_fold (resultType := .state) _
    (fun _ index state => forgetAt state index) "i" "result" "info" (forgetBody_meaning calls)
    _ locals _ (by intros; simp only [Locals.set_shadow])]
  rw [forgetSteps, updateRows_full]
  rw [Locals.set_commute_types _ .state .number "result" "i" _ _ (by decide), Locals.set_unchanged]

structure Context where
  text : Source
  info : PackageBindings.Metadata
  item : PackageBindings.Routine

def context (locals : Locals) : Context :=
  ⟨locals .source "text", locals .metadata "info", locals .routine "item"⟩

theorem context_index (locals : Locals) (index : Nat) : context (locals.set .number "i" index) = context locals := by
  simp [context, Locals.set]

theorem context_frame (locals : Locals) (value : ParserState) :
    context (locals.set .state "result" value) = context locals := by
  simp [context, Locals.set]

theorem hideBody_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    hideBody.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result")) =
      match hideParameter calls (context locals).text (context locals).info
          (locals .state "result") (locals .number "i") with
      | none => invalidState
      | some value => next (context locals) value := by
  dsimp only [hideBody, Control.Command.list, List.foldr, Control.Command.eval,
    Control.Command.assign, Control.Command.nothing, Control.Command.returned,
    ApplicationNative.Command.eval, Place.expression, Place.set, Expr.eval,
    Field.get, Field.set, Index.get, result, parameter, text, info]
  simp [context, hideParameter, modelFunctions, Locals.set]
  split <;> simp_all <;> split <;> simp_all

theorem appendBody_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    appendBody.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result")) =
      match appendParameter calls (context locals).info (locals .state "result") (locals .number "i") with
      | none => invalidState
      | some value => next (context locals) value := by
  dsimp only [appendBody, Control.Command.list, List.foldr, Control.Command.eval,
    Control.Command.assign, Control.Command.nothing, Control.Command.returned,
    ApplicationNative.Command.eval, ApplicationPackageProcedure.Primitive.eval,
    Place.expression, Place.set, Expr.eval, Field.get, Field.set, Index.get,
    result, parameter, mark, info]
  simp [context, appendParameter, modelProcedures, Locals.set]
  split <;> simp_all <;> split <;> simp_all

/-- Full finite range interpretation with an arbitrary projected continuation.
The one-step equality is proved above from the typed source tree; no successful
callee result or reachable-store restriction is imposed. -/
theorem forValues_parameters
    (body : Locals → (Locals → ParserState) → ParserState)
    (step : Context → ParserState → Nat → Option ParserState)
    (equation : ∀ locals (next : Context → ParserState → ParserState),
      body locals (fun updated => next (context updated) (updated .state "result")) =
        match step (context locals) (locals .state "result") (locals .number "i") with
        | none => invalidState
        | some value => next (context locals) value)
    (values : List Nat) (locals : Locals) (next : Context → ParserState → ParserState) :
    forValues (resultType := .state) body "i" values locals
      (fun updated => next (context updated) (updated .state "result")) =
      match ApplicationPackageRoutineFrame.parameters (step (context locals)) values (locals .state "result") with
      | none => invalidState
      | some value => next (context locals) value := by
  induction values generalizing locals next with
  | nil => rfl
  | cons value rest induction =>
      rw [forValues]
      have continuation :
          (fun updated => forValues (resultType := .state) body "i" rest updated
            (fun finished => next (context finished) (finished .state "result"))) =
          (fun updated =>
            match ApplicationPackageRoutineFrame.parameters (step (context updated)) rest
                (updated .state "result") with
            | none => invalidState
            | some frame => next (context updated) frame) := by
        funext updated
        exact induction updated next
      rw [continuation]
      rw [equation (locals.set .number "i" value)
        (fun current frame =>
          match ApplicationPackageRoutineFrame.parameters (step current) rest frame with
          | none => invalidState
          | some value => next current value)]
      simp only [context_index, Locals.set_get_same,
        Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.number ≠ Ty.state),
        ApplicationPackageRoutineFrame.parameters]
      cases step (context locals) (locals .state "result") value <;> rfl

def nativeIndices (item : PackageBindings.Routine) : List Nat :=
  (List.range (item.formalFirst + item.count - 1 + 1 - item.formalFirst)).map (item.formalFirst + ·)

theorem nativeIndices_formal (item : PackageBindings.Routine) (positive : 0 < item.count) :
    nativeIndices item = ApplicationPackageBodies.formalIndices item := by
  unfold nativeIndices ApplicationPackageBodies.formalIndices
  congr 2
  omega

theorem hideLoop_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    Control.Command.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result"))
      (.forRange "i" formalFirst formalLast hideBody) =
      match ApplicationPackageRoutineFrame.parameters
          (hideParameter calls (context locals).text (context locals).info)
          (nativeIndices (context locals).item) (locals .state "result") with
      | none => invalidState
      | some value => next (context locals) value := by
  change forValues (resultType := .state)
    (fun current continuation => hideBody.eval (modelFunctions calls) (modelProcedures calls) current continuation)
    "i" (nativeIndices (context locals).item) locals
    (fun updated => next (context (updated.set .number "i" (locals .number "i")))
      ((updated.set .number "i" (locals .number "i")) .state "result")) = _
  simp only [context_index,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.number ≠ Ty.state)]
  exact forValues_parameters _ (fun current => hideParameter calls current.text current.info)
    (hideBody_meaning calls) _ locals next

theorem appendLoop_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    Control.Command.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result"))
      (.forRange "i" formalFirst formalLast appendBody) =
      match ApplicationPackageRoutineFrame.parameters (appendParameter calls (context locals).info)
          (nativeIndices (context locals).item) (locals .state "result") with
      | none => invalidState
      | some value => next (context locals) value := by
  change forValues (resultType := .state)
    (fun current continuation => appendBody.eval (modelFunctions calls) (modelProcedures calls) current continuation)
    "i" (nativeIndices (context locals).item) locals
    (fun updated => next (context (updated.set .number "i" (locals .number "i")))
      ((updated.set .number "i" (locals .number "i")) .state "result")) = _
  simp only [context_index,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.number ≠ Ty.state)]
  exact forValues_parameters _ (fun current => appendParameter calls current.info)
    (appendBody_meaning calls) _ locals next

def formalPasses : C := .sequence (.forRange "i" formalFirst formalLast hideBody)
  (.forRange "i" formalFirst formalLast appendBody)

def passParameters (calls : ApplicationPackageRoutineFrame.Calls) (current : Context)
    (values : List Nat) (frame : ParserState) : Option ParserState :=
  (ApplicationPackageRoutineFrame.parameters (hideParameter calls current.text current.info) values frame).bind
    (ApplicationPackageRoutineFrame.parameters (appendParameter calls current.info) values)

theorem formalPasses_meaning (calls : ApplicationPackageRoutineFrame.Calls)
    (locals : Locals) (next : Context → ParserState → ParserState) :
    formalPasses.eval (modelFunctions calls) (modelProcedures calls) locals
      (fun updated => next (context updated) (updated .state "result")) =
      match passParameters calls (context locals) (nativeIndices (context locals).item) (locals .state "result") with
      | none => invalidState
      | some value => next (context locals) value := by
  change Control.Command.eval _ _ locals
    (fun current => Control.Command.eval _ _ current
      (fun updated => next (context updated) (updated .state "result"))
      (.forRange "i" formalFirst formalLast appendBody))
    (.forRange "i" formalFirst formalLast hideBody) = _
  have appendEquation := funext (fun current => appendLoop_meaning calls current next)
  rw [appendEquation]
  rw [hideLoop_meaning calls locals
    (fun current frame =>
      match ApplicationPackageRoutineFrame.parameters (appendParameter calls current.info)
          (nativeIndices current.item) frame with
      | none => invalidState
      | some value => next current value)]
  unfold passParameters
  cases ApplicationPackageRoutineFrame.parameters
    (hideParameter calls (context locals).text (context locals).info)
    (nativeIndices (context locals).item) (locals .state "result") <;> rfl

end Silver.ApplicationPackageRoutineFrame.Native
