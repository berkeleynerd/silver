module

public import Silver.ApplicationPackageHideOuter

@[expose] public section

namespace Silver.ApplicationPackageFrames.Native
open ApplicationNative Compose

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

def trimScalars (state : ParserState) (count : Nat) : ParserState :=
  {state with scalarNames := state.scalarNames.take count}

def trimBooleans (state : ParserState) (count : Nat) : ParserState :=
  {state with booleanNames := state.booleanNames.take count}

def trimSubtypes (state : ParserState) (count : Nat) : ParserState :=
  {state with subtypeNames := {state.subtypeNames with items := state.subtypeNames.items.take count}}

def hideResult (calls : Calls Function) (locals : Locals) : ParserState :=
  let trimmed := trimSubtypes (trimBooleans
    (trimScalars (locals .state "result") (locals .number "scalars_kept"))
    (locals .number "booleans_kept")) (locals .number "subtypes_kept")
  {trimmed with
    «hiding» := calls _ .hideName (locals .source "text") trimmed.hiding
      (locals .nameSpan "name").first (locals .nameSpan "name").after}

def hideTail : C := .list [
  .assign (.field .scalarCount (.field .stateScalarNames result)) (.variable "scalars_kept"),
  .assign (.field .booleanCount (.field .stateBooleanNames result)) (.variable "booleans_kept"),
  .assign (.field .subtypeCount (.field .stateSubtypeNames result)) (.variable "subtypes_kept"),
  .assign (.field .stateHiding result)
    (.app (.app (.app (.app (.function .hideName) text) (.field .stateHiding result.expression))
      (.field .nameFirst name)) (.field .nameAfter name)),
  finalState]

def finishHide (calls : Calls Function) (locals : Locals) : ParserState :=
  let value := hideResult calls locals
  if calls _ .validState (locals .source "text") value then value else invalidState

theorem trimScalars_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .scalarCount (.field .stateScalarNames result)) (.variable "scalars_kept")) =
      next (locals.set .state "result" (trimScalars (locals .state "result")
        (locals .number "scalars_kept"))) := rfl

theorem trimBooleans_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .booleanCount (.field .stateBooleanNames result)) (.variable "booleans_kept")) =
      next (locals.set .state "result" (trimBooleans (locals .state "result")
        (locals .number "booleans_kept"))) := rfl

theorem trimSubtypes_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .subtypeCount (.field .stateSubtypeNames result)) (.variable "subtypes_kept")) =
      next (locals.set .state "result" (trimSubtypes (locals .state "result")
        (locals .number "subtypes_kept"))) := rfl

theorem setHiding_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (.assign (.field .stateHiding result)
        (.app (.app (.app (.app (.function .hideName) text) (.field .stateHiding result.expression))
          (.field .nameFirst name)) (.field .nameAfter name))) =
      next (locals.set .state "result" {(locals .state "result") with
        «hiding» := calls _ .hideName (locals .source "text") (locals .state "result").hiding
          (locals .nameSpan "name").first (locals .nameSpan "name").after}) := rfl

theorem hideTail_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next hideTail = finishHide calls locals := by
  unfold hideTail
  rw [eval_list_cons, trimScalars_denotation, eval_list_cons, trimBooleans_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.number)]
  rw [eval_list_cons, trimSubtypes_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.number)]
  rw [eval_list_cons, setHiding_denotation]
  simp only [Locals.set_get_same, Locals.set_shadow,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.source),
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.nameSpan)]
  rw [eval_list_cons, finalState_denotation]
  simp only [Locals.set_get_same,
    Locals.set_get_other_type _ _ _ _ _ _ (by decide : Ty.state ≠ Ty.source)]
  rfl

def scalarStage (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) : ParserState :=
  match compactRows (scalarSelected calls locals) (scalarOuter calls locals)
    (locals .number "scalars_kept") (locals .state "result").scalarNames
    (locals .state "frame").scalarNames with
  | none => invalidState
  | some (count, rows) => next (scalarFilterState locals count rows)

def booleanStage (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) : ParserState :=
  match compactRows (booleanSelected calls locals) (booleanOuter calls locals)
    (locals .number "booleans_kept") (locals .state "result").booleanNames
    (locals .state "frame").booleanNames with
  | none => invalidState
  | some (count, rows) => next (booleanFilterState locals count rows)

def subtypeStage (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) : ParserState :=
  match compactRows (subtypeSelected calls locals) (subtypeOuter calls locals)
    (locals .number "subtypes_kept") (locals .state "result").subtypeNames.items
    (locals .state "frame").subtypeNames.items with
  | none => invalidState
  | some (count, rows) => next (subtypeFilterState locals count rows)

theorem scalarStage_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateScalarNames .scalarCount .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept") =
      scalarStage calls locals next := by
  rw [scalar_filter_loop]
  unfold scalarStage
  cases compactRows (scalarSelected calls locals) (scalarOuter calls locals)
    (locals .number "scalars_kept") (locals .state "result").scalarNames
    (locals .state "frame").scalarNames with
  | none => rfl
  | some output => cases output; rfl

theorem booleanStage_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateBooleanNames .booleanCount .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept") =
      booleanStage calls locals next := by
  rw [boolean_filter_loop]
  unfold booleanStage
  cases compactRows (booleanSelected calls locals) (booleanOuter calls locals)
    (locals .number "booleans_kept") (locals .state "result").booleanNames
    (locals .state "frame").booleanNames with
  | none => rfl
  | some output => cases output; rfl

theorem subtypeStage_denotation (calls : Calls Function) (locals : Locals) (next : Locals → ParserState) :
    Command.eval (resultType := .state) calls locals next
      (filterLoop .stateSubtypeNames .subtypeCount .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept") =
      subtypeStage calls locals next := by
  rw [subtype_filter_loop]
  unfold subtypeStage
  cases compactRows (subtypeSelected calls locals) (subtypeOuter calls locals)
    (locals .number "subtypes_kept") (locals .state "result").subtypeNames.items
    (locals .state "frame").subtypeNames.items with
  | none => rfl
  | some output => cases output; rfl

def hideRejected (calls : Calls Function) (locals : Locals) : Bool :=
  calls _ .forbiddenName (locals .source "text") (locals .nameSpan "name").first
      (locals .nameSpan "name").after ||
    calls _ .sameName (locals .source "text") (locals .nameSpan "name")
      ⟨(locals .metadata "info").nameFirst, (locals .metadata "info").nameAfter⟩

def hideCommands (calls : Calls Function) (locals : Locals) : ParserState :=
  if hideRejected calls locals then invalidState
  else scalarStage calls locals (fun scalars => booleanStage calls scalars
    (fun booleans => subtypeStage calls booleans (finishHide calls)))

theorem eval_sequence (calls : Calls Function) (locals : Locals) (next : Locals → ParserState)
    (first rest : C) :
    Command.eval (resultType := .state) calls locals next (.sequence first rest) =
      Command.eval (resultType := .state) calls locals
        (fun updated => Command.eval (resultType := .state) calls updated next rest) first := rfl

theorem hideCommands_denotation (calls : Calls Function) (locals : Locals) :
    Command.eval (resultType := .state) calls locals (fun _ => invalidState) hideOuterBody.commands =
      hideCommands calls locals := by
  rw [show hideOuterBody.commands = .sequence
    (.choose (.orElse
      (.app (.app (.app (.function .forbiddenName) text) (.field .nameFirst name)) (.field .nameAfter name))
      (.app (.app (.app (.function .sameName) text) name)
        (.nameSpan (.field .infoNameFirst info) (.field .infoNameAfter info))))
      (.returned .invalidState) .nothing)
    (.sequence
      (filterLoop .stateScalarNames .scalarCount .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept")
      (.sequence
        (filterLoop .stateBooleanNames .booleanCount .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept")
        (.sequence
          (filterLoop .stateSubtypeNames .subtypeCount .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept")
          hideTail))) by rfl]
  change (if hideRejected calls locals then invalidState else
    Command.eval calls locals (fun _ => invalidState)
      (.sequence
        (filterLoop .stateScalarNames .scalarCount .scalar .scalarFirst .scalarAfter .scalarQualifierFirst "scalars_kept")
        (.sequence
          (filterLoop .stateBooleanNames .booleanCount .boolean .booleanFirst .booleanAfter .booleanQualifierFirst "booleans_kept")
          (.sequence
            (filterLoop .stateSubtypeNames .subtypeCount .subtype .subtypeFirst .subtypeAfter .subtypeQualifierFirst "subtypes_kept")
            hideTail)))) = _
  unfold hideCommands
  split
  · rfl
  · rw [eval_sequence, scalarStage_denotation]
    apply congrArg (scalarStage calls locals)
    funext scalars
    rw [eval_sequence, booleanStage_denotation]
    apply congrArg (booleanStage calls scalars)
    funext booleans
    rw [eval_sequence, subtypeStage_denotation]
    apply congrArg (subtypeStage calls booleans)
    funext subtypes
    exact hideTail_denotation calls subtypes _

def hideInitial (locals : Locals) : Locals :=
  (((locals.set .state "result" (locals .state "frame")).set .number "scalars_kept" 0).set
    .number "booleans_kept" 0).set .number "subtypes_kept" 0

theorem hideOuter_denotation (calls : Calls Function) (locals : Locals) :
    hideOuterBody.eval calls locals = hideCommands calls (hideInitial locals) := by
  change Command.eval calls (hideInitial locals) (fun _ => invalidState) hideOuterBody.commands = _
  exact hideCommands_denotation calls (hideInitial locals)

end Silver.ApplicationPackageFrames.Native
