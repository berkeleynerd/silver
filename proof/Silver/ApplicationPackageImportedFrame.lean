module

public import Silver.ApplicationPackageFrameInterpretation

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

set_option maxRecDepth 10000
set_option maxHeartbeats 1000000
set_option backward.dsimp.instances true

def qualifyScalars (info : PackageBindings.Metadata) (state : ParserState) : ParserState :=
  {state with scalarNames := state.scalarNames.map (scalarQualified info.nameFirst info.nameAfter)}

def qualifyBooleans (info : PackageBindings.Metadata) (state : ParserState) : ParserState :=
  {state with booleanNames := state.booleanNames.map (booleanQualified info.nameFirst info.nameAfter)}

def qualifySubtypes (info : PackageBindings.Metadata) (state : ParserState) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with
    items := state.subtypeNames.items.map (subtypeQualified info.nameFirst info.nameAfter)}}

def clearCalls (state : ParserState) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with hiddenCalls := {}}}

def clearTrue (state : ParserState) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with trueHidden := false}}

def clearFalse (state : ParserState) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with falseHidden := false}}

def importedTransform (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat) : ParserState :=
  clearFalse (clearTrue (clearCalls (qualifySubtypes info (qualifyBooleans info
    (qualifyScalars info (importedInitial exports info position))))))

theorem importedTransform_model (exports : ParserState) (info : PackageBindings.Metadata) (position : Nat) :
    importedTransform exports info position = importedFrameRaw exports info position := rfl

theorem importedDeclarations (calls : Calls Function) (locals : Locals) :
    importedFrameBody.declarations.foldl (Declaration.eval calls) locals =
      locals.set .state "result" (importedInitial (locals .state "exports")
        (locals .metadata "info") (locals .number "position")) := rfl

theorem clearCalls_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .subtypesHiddenCalls (.field .stateSubtypeNames result)) .noCalls) =
      next (locals.set .state "result" (clearCalls (locals .state "result"))) := rfl

theorem clearTrue_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .subtypesTrueHidden (.field .stateSubtypeNames result)) (.truth false)) =
      next (locals.set .state "result" (clearTrue (locals .state "result"))) := rfl

theorem clearFalse_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .subtypesFalseHidden (.field .stateSubtypeNames result)) (.truth false)) =
      next (locals.set .state "result" (clearFalse (locals .state "result"))) := rfl

theorem finalState_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next finalState =
      if calls _ .validState (locals .source "text") (locals .state "result")
      then locals .state "result" else invalidState := by
  dsimp only [finalState, Command.eval, Expr.eval, Place.expression, Native.result, Native.text]
  cases calls _ .validState (locals .source "text") (locals .state "result") <;> rfl

theorem eval_list_cons (calls : Calls Function) (locals : Locals) (next : Locals → ParserState)
    (first : C) (rest : List C) :
    Command.eval (resultType := .state) calls locals next (.list (first :: rest)) =
      Command.eval (resultType := .state) calls locals (fun updated => Command.eval (resultType := .state) calls updated next (.list rest)) first := rfl

theorem importedCommands (calls : Calls Function) (locals : Locals) :
    Command.eval (resultType := .state) calls locals (fun _ => invalidState) importedFrameBody.commands =
      let info := locals .metadata "info"
      let value := clearFalse (clearTrue (clearCalls (qualifySubtypes info
        (qualifyBooleans info (qualifyScalars info (locals .state "result"))))))
      if calls _ .validState (locals .source "text") value then value else invalidState := by
  change Command.eval (resultType := .state) calls locals (fun _ => invalidState)
    (.list [
      qualifyLoop .stateScalarNames .scalarCount .scalar .scalarQualifierFirst .scalarQualifierAfter,
      qualifyLoop .stateBooleanNames .booleanCount .boolean .booleanQualifierFirst .booleanQualifierAfter,
      qualifyLoop .stateSubtypeNames .subtypeCount .subtype .subtypeQualifierFirst .subtypeQualifierAfter,
      .assign (.field .subtypesHiddenCalls (.field .stateSubtypeNames result)) .noCalls,
      .assign (.field .subtypesTrueHidden (.field .stateSubtypeNames result)) (.truth false),
      .assign (.field .subtypesFalseHidden (.field .stateSubtypeNames result)) (.truth false),
      finalState]) = _
  rw [eval_list_cons, scalar_qualify_loop]
  change Command.eval (resultType := .state) calls (locals.set .state "result"
    (qualifyScalars (locals .metadata "info") (locals .state "result"))) _ _ = _
  rw [eval_list_cons, boolean_qualify_loop]
  simp only [Locals.set_get_same, Locals.set_get_other_type _ _ _ _ _ _
    (by decide : Ty.state ≠ Ty.metadata), Locals.set_shadow]
  rw [eval_list_cons, subtype_qualify_loop]
  simp only [Locals.set_get_same, Locals.set_get_other_type _ _ _ _ _ _
    (by decide : Ty.state ≠ Ty.metadata), Locals.set_shadow]
  rw [eval_list_cons, clearCalls_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow]
  rw [eval_list_cons, clearTrue_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow]
  rw [eval_list_cons, clearFalse_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow]
  rw [eval_list_cons, finalState_denotation]
  simp only [Locals.set_get_same, Locals.set_get_other_type _ _ _ _ _ _
    (by decide : Ty.state ≠ Ty.source)]
  rfl

theorem importedFrame_denotation (calls : Calls Function) (locals : Locals) :
    importedFrameBody.eval calls locals = importedEquation calls (locals .source "text")
      (locals .state "exports") (locals .metadata "info") (locals .number "position") := by
  rw [Body.eval, importedDeclarations]
  dsimp only [Ty.default]
  rw [importedCommands]
  simp only [Locals.set_get_same,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.metadata),
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.source)]
  change (if calls _ .validState (locals .source "text")
    (importedTransform (locals .state "exports") (locals .metadata "info") (locals .number "position"))
    then importedTransform (locals .state "exports") (locals .metadata "info") (locals .number "position")
    else invalidState) = _
  rw [importedTransform_model]
  rfl

end Silver.ApplicationPackageFrames.Native
