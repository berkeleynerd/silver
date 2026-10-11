import Silver.ComposeAdmission

/-! Payload properties carried by every successful source derivation. -/

namespace Silver.Compose

def LiteralDomain (bytes : Source) : Prop :=
  bytes.length ≤ maxSourceLength ∧ ∀ byte ∈ bytes, Output.printable byte = true

def StreamValid (form : Form) : Nat → Nat → List Event → Prop
  | _, _, [] => True
  | fixedLength, capacity, .declaration _ _ :: events => StreamValid form fixedLength capacity events
  | fixedLength, capacity, .reference _ :: events => StreamValid form fixedLength capacity events
  | fixedLength, capacity, .literal role bytes :: events =>
      LiteralDomain bytes ∧ (role = .assigned → bytes.length = fixedLength) ∧
      StreamValid form (if role = .initial then bytes.length else fixedLength) capacity events
  | fixedLength, _, .capacity capacity :: events =>
      capacity ≤ maxSourceLength ∧ StreamValid form fixedLength capacity events
  | fixedLength, capacity, .output expression :: events =>
      expression.LiteralsPrintable ∧ expression.length ≤ maxExpressionOperands ∧
      expression.Bounded fixedLength capacity ∧
      (form.hasAssignment = true → 0 < expression.staticCount) ∧
      StreamValid form fixedLength capacity events

theorem literal_domain {text bytes : Source} {position after : Nat}
    (parsed : Output.LiteralAt text position bytes after) (sourceBound : text.length ≤ maxSourceLength)
    (positive : 1 ≤ position) : LiteralDomain bytes := by
  have facts := Output.literalAt_bounds parsed
  exact ⟨by omega, facts.2.2⟩

theorem step_length_bounds {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} (parsed : StepAt text form token state event next)
    (sourceBound : text.length ≤ maxSourceLength)
    (fixed : state.context.staticLength ≤ maxSourceLength) (capacity : state.capacity ≤ maxSourceLength) :
    next.context.staticLength ≤ maxSourceLength ∧ next.capacity ≤ maxSourceLength := by
  cases parsed with
  | staticDeclaration | dynamicDeclaration | staticReference | dynamicReference | output | fixed =>
      exact ⟨fixed, capacity⟩
  | literal _ _ value _ =>
      have domain := literal_domain value sourceBound (by omega)
      constructor
      · split <;> simp_all [LiteralDomain]
      · exact capacity
  | capacity value => exact ⟨fixed, (Guarded.decimalAt_bounds value).2.2⟩

theorem output_expression_bounded {text : Source} {form : Form} {state : ParserState}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionAt text state.context state.position expression result)
    (safe : outputAllowed form state result = true) (capacity : state.capacity ≤ maxSourceLength) :
    expression.Bounded state.context.staticLength state.capacity ∧
      (form.hasAssignment = true → 0 < expression.staticCount) := by
  have fixed := expressionTail_length_bound parsed (Nat.zero_le _)
  have conditions := Bool.and_eq_true_iff.mp safe
  constructor
  · apply expressionAt_bounded parsed
    cases seen : result.dynamicSeen
    · simpa [seen] using fixed
    · have enough := conditions.1
      simp only [seen, Bool.not_true, Bool.false_or, decide_eq_true_eq] at enough
      simp only [↓reduceIte]
      omega
  · intro assignment
    have seen := conditions.2
    simp only [assignment, Bool.not_true, Bool.false_or] at seen
    rw [expressionTail_staticSeen parsed] at seen
    simpa using seen

theorem step_stream_valid {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} {events : List Event}
    (parsed : StepAt text form token state event next)
    (sourceBound : text.length ≤ maxSourceLength) (capacity : state.capacity ≤ maxSourceLength)
    (rest : StreamValid form next.context.staticLength next.capacity events) :
    StreamValid form state.context.staticLength state.capacity (event.toList ++ events) := by
  cases parsed with
  | staticDeclaration | dynamicDeclaration | staticReference | dynamicReference | fixed => exact rest
  | literal bound quote value compatible =>
      exact ⟨literal_domain value sourceBound (by omega), compatible, rest⟩
  | capacity value => exact ⟨(Guarded.decimalAt_bounds value).2.2, rest⟩
  | output expression safe nonzero =>
      have bounded := output_expression_bounded expression safe capacity
      exact ⟨expressionTail_literals expression, (expressionTail_count expression).2,
        bounded.1, bounded.2, rest⟩

theorem parsed_stream_valid {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    {events : List Event} (parsed : Parsed text form tokens state events)
    (sourceBound : text.length ≤ maxSourceLength)
    (fixed : state.context.staticLength ≤ maxSourceLength) (capacity : state.capacity ≤ maxSourceLength) :
    StreamValid form state.context.staticLength state.capacity events := by
  induction parsed with
  | done => trivial
  | next positive step rest ih =>
      have bounds := step_length_bounds step sourceBound fixed capacity
      exact step_stream_valid step sourceBound capacity (ih bounds.1 bounds.2)

theorem meaning_stream_valid {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : StreamValid form 0 maxSourceLength events :=
  parsed_stream_valid meaning.2.2 meaning.1.2.1 (Nat.zero_le _) (Nat.le_refl _)

theorem meaning_eventKinds {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    events.map Event.kind = form.tokens.filterMap ShellToken.eventKind :=
  parsed_eventKinds meaning.2.2

end Silver.Compose
