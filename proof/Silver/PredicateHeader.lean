module

public import Silver.PredicateShell
public import Silver.ComposeDecode

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

private def HeaderToken : ShellToken → Prop
  | .contextClauses | .fixed _ _ | .declarations | .argumentDeclaration => True
  | _ => False

private def eventArguments (arguments : Bool) : Event → Bool
  | .argument _ => true
  | _ => arguments

private def eventsArguments (arguments : Bool) (events : List Event) : Bool :=
  events.foldl eventArguments arguments

private theorem step_arguments {text form token state next event}
    (ordinary : HeaderToken token) (parsed : StepAt text form token state next event) :
    eventsArguments (decide (state.dynamicFirst ≠ 0)) event.toList = decide (next.dynamicFirst ≠ 0) := by
  have payload := parsed.payload
  cases token with
  | contextClauses | fixed spelling word =>
      change event = none at payload
      subst event
      rw [← parsed.scanned]
      simp [step, parsed.positive, eventsArguments]
  | declarations =>
      obtain ⟨values, reading, rfl⟩ := payload
      have fields := declarations_fields reading
      simp [eventsArguments, eventArguments, fields.2.2.1]
  | argumentDeclaration =>
      obtain ⟨fallback, reading, rfl⟩ := payload
      cases reading with
      | argument _ allowed _ _ _ =>
          simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
          simp [eventsArguments, eventArguments, allowed.1.1.1.1]
  | _ => contradiction

private theorem tokens_arguments {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, HeaderToken token)
    (parsed : Sequence.TokensAt text form tokens state events final) :
    eventsArguments (decide (state.dynamicFirst ≠ 0)) events = decide (final.dynamicFirst ≠ 0) := by
  induction parsed with
  | done => rfl
  | @next token tokens state following final event rest head _ ih =>
      simp only [eventsArguments, List.foldl_append]
      change eventsArguments (eventsArguments (decide (state.dynamicFirst ≠ 0)) _) _ = _
      rw [step_arguments (ordinary token (by simp)) head]
      exact ih (fun token member => ordinary token (by simp [member]))

theorem prefix_arguments {source form events}
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state) :
    (contextOf (prefixScan source form)).hasArguments = form.hasArguments := by
  have flag := tokens_arguments (by cases form <;> simp [Form.prefix, Form.hasArguments, currentHeader, HeaderToken, ShellToken.word, ShellToken.symbol]) parsed
  have shape := Sequence.tokens_kinds parsed
  change eventsArguments false events = decide ((prefixScan source form).state.dynamicFirst ≠ 0) at flag
  change decide ((prefixScan source form).state.dynamicFirst ≠ 0) = form.hasArguments
  rw [← flag]
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      rfl
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      rfl

def decodePrefix (form : Form) (events : List Event) (items : List SourceStatement) : Option Program :=
  match form, events with
  | .direct, [.declarations values names] => some ⟨values, names, [], false, lowerStatements items⟩
  | .argument, [.argument fallback, .declarations values names] =>
      some ⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items⟩
  | _, _ => none

theorem prefix_decoded_valid (form : Form) (events : List Event) (items : List SourceStatement)
    (shape : events.map Event.kind = form.prefix.filterMap ShellToken.eventKind)
    (stream : StreamValid emptyShape maxSourceLength events)
    (nonempty : items ≠ [])
    (body : SourceStatementsWellFormed form.hasArguments
      (Sequence.eventsContext (emptyShape, maxSourceLength) events).1 items)
    (checked : ∃ after, checkStatements (Sequence.eventsContext (emptyShape, maxSourceLength) events).1
      (initialFacts form.hasArguments) (lowerStatements items) = some after ∧ completed after = true) :
    ∃ program, decodePrefix form events items = some program ∧ program.Valid := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations] at shape
      obtain ⟨values, names, rest, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst rest
      refine ⟨⟨values, names, [], false, lowerStatements items⟩, rfl, ?_⟩
      exact ⟨stream.1, by simp [Bindings.Printable], by simp [maxSourceLength],
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, checked⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations] at shape
      obtain ⟨fallback, rest, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨values, names, rest, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst rest
      refine ⟨⟨argumentDeclaration :: values, names, fallback, true, lowerStatements items⟩, rfl, ?_⟩
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1,
        lowerStatements_nonempty nonempty, lowerStatements_wellFormed body, checked⟩

end Silver.Predicate
