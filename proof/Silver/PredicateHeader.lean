module

public import Silver.PredicateShell
public import Silver.PredicateHeaderDecode
public import Silver.SequenceScalarTrace
public import Silver.SequenceInitializerTrace
public import Silver.SequenceArrayReady

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

theorem prefix_scalar_checked {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    Integer.checkDeclarations [] values =
        some (ScalarExpression.constants (prefixScan source form).state.scalarNames) ∧
      ScalarExpression.StaticEnvironment (prefixScan source form).state.scalarNames ∧
      ScalarExpression.ranges (prefixScan source form).state.scalarNames =
        Integer.Constants.ranges (ScalarExpression.constants (prefixScan source form).state.scalarNames) := by
  have checked := Sequence.scalar_tokens_checked trace ScalarExpression.static_empty (by simp [initialState])
    (Sequence.initial_subtypes_valid source) initialState_stored
  exact ⟨checked.1, checked.2, ScalarExpression.static_ranges checked.2⟩

theorem prefix_scalar_objects {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    ScalarExpression.objectBindings (prefixScan source form).state.scalarNames = Integer.elaborate [] values := by
  simpa only [initialState, ScalarExpression.constants, ScalarExpression.objectBindings,
    List.map_nil, List.nil_append] using
    Sequence.scalar_tokens_objects trace ScalarExpression.static_empty (by simp [initialState])
      (Sequence.initial_subtypes_valid source) initialState_stored

theorem prefix_initializer_checked {source form checks}
    (domain : source.length ≤ maxSourceLength)
    (trace : Sequence.InitializerTokensAt source form.helper form.prefix initialState checks
      (prefixScan source form).state) : Integer.discharged checks = true :=
  Sequence.initializer_tokens_discharge domain trace Compose.initial_valid
    (Sequence.initial_subtypes_valid source) (Sequence.initial_array_types_valid source)

theorem prefix_array_ready {source form events}
    (parsed : Sequence.TokensAt source form.helper form.prefix initialState events (prefixScan source form).state) :
    ArrayBindings.SourceReady source (prefixScan source form).state.arrayNames :=
  Sequence.tokens_array_ready parsed (Sequence.initial_array_ready source)
    (Sequence.initial_array_types_valid source) (Sequence.initial_subtypes_valid source)

theorem prefix_scalar_count_bound {source form values}
    (trace : Sequence.ScalarTokensAt source form.helper form.prefix initialState values
      (prefixScan source form).state) :
    (prefixScan source form).state.scalarNames.length ≤ ArrayBindings.scalarLimit :=
  Sequence.scalar_tokens_count_bound trace (by simp [initialState])

end Silver.Predicate
