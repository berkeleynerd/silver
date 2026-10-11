import Silver.ComposeAdmission

/-! Payload properties carried by every successful source derivation. -/

namespace Silver.Compose

def LiteralDomain (bytes : Source) : Prop :=
  bytes.length ≤ maxSourceLength ∧ ∀ byte ∈ bytes, Output.printable byte = true

def StreamValid (form : Form) : Nat → Nat → List Event → Prop
  | _, _, [] => True
  | fixedLength, capacity, .declaration _ _ :: events => StreamValid form fixedLength capacity events
  | fixedLength, capacity, .constantDeclaration _ _ :: events => StreamValid form fixedLength capacity events
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

theorem value_domain {text bytes : Source} {context : NameContext} {role : LiteralRole}
    {position after : Nat} (parsed : ValueAt text context role position bytes after)
    (sourceBound : text.length ≤ maxSourceLength) : LiteralDomain bytes := by
  cases parsed with
  | literal bound quote value => exact literal_domain value sourceBound (by omega)
  | constantName name noStatic noDynamic header value => exact literal_domain value sourceBound (by omega)

@[simp] theorem initialized_staticLength (context : NameContext) (role : LiteralRole) (position length : Nat) :
    (initializedContext context role position length).staticLength =
      if role = .initial then length else context.staticLength := by cases role <;> rfl

theorem step_length_bounds {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} (parsed : StepAt text form token state event next)
    (sourceBound : text.length ≤ maxSourceLength)
    (fixed : state.context.staticLength ≤ maxSourceLength) (capacity : state.capacity ≤ maxSourceLength) :
    next.context.staticLength ≤ maxSourceLength ∧ next.capacity ≤ maxSourceLength := by
  cases parsed with
  | staticDeclaration | dynamicDeclaration | staticReference | dynamicReference | output | fixed =>
      exact ⟨fixed, capacity⟩
  | constantDeclaration name allowed =>
      constructor
      · split <;> exact fixed
      · exact capacity
  | literal value _ =>
      have domain := value_domain value sourceBound
      constructor
      · rw [initialized_staticLength]
        split <;> simp_all [LiteralDomain]
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
  | @constantDeclaration state name finish second parsed allowed => cases second <;> exact rest
  | literal value compatible =>
      exact ⟨value_domain value sourceBound, compatible, by change StreamValid form _ _ events; simpa only [initialized_staticLength] using rest⟩
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

/-! Constant elaboration is separate from the normalized expression arithmetic.
At every source step the two recorded initializer positions denote the values
actually introduced by the preceding declaration events. A resolved name read
therefore has the immutable binding's bytes, not merely its declared length. -/

structure ConstantValues where
  one : Option Source := none
  two : Option Source := none
  deriving DecidableEq, Repr

def ConstantValues.get (values : ConstantValues) (second : Bool) : Option Source :=
  if second then values.two else values.one

def ConstantValues.afterEvent (values : ConstantValues) : Option Event → ConstantValues
  | some (.literal .constantOne bytes) => {values with one := some bytes}
  | some (.literal .constantTwo bytes) => {values with two := some bytes}
  | _ => values

def SlotCorresponds (text : Source) (position : Nat) (value : Option Source) : Prop :=
  (position = 0 ∧ value = none) ∨
    ∃ bytes after, value = some bytes ∧ Output.LiteralAt text position bytes after

def ConstantsCorrespond (text : Source) (context : NameContext) (values : ConstantValues) : Prop :=
  SlotCorresponds text context.constantOneValueFirst values.one ∧
  SlotCorresponds text context.constantTwoValueFirst values.two

theorem initial_constants (text : Source) : ConstantsCorrespond text initialState.context {} :=
  ⟨Or.inl ⟨rfl, rfl⟩, Or.inl ⟨rfl, rfl⟩⟩

theorem declaration_value_literal {text bytes : Source} {context : NameContext} {role : LiteralRole}
    {position after : Nat} (parsed : ValueAt text context role position bytes after)
    (notInitial : role ≠ .initial) (notAssigned : role ≠ .assigned) :
    Output.LiteralAt text (Cursor.triviaPosition text position + 1) bytes after := by
  cases parsed with
  | literal bound quote value => exact value
  | constantName name noStatic noDynamic header value =>
      simp [valueContext, notInitial, notAssigned, constantValueAtName, matchesConstant] at header

theorem step_constants {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} {values : ConstantValues}
    (parsed : StepAt text form token state event next)
    (prior : ConstantsCorrespond text state.context values) :
    ConstantsCorrespond text next.context (values.afterEvent event) := by
  cases parsed with
  | staticDeclaration | dynamicDeclaration | staticReference | dynamicReference | capacity | output | fixed => exact prior
  | @constantDeclaration state name finish second parsed allowed => cases second <;> exact prior
  | @literal state bytes role finish value compatible =>
      cases role with
      | ordinary | initial | assigned => exact prior
      | constantOne =>
          exact ⟨Or.inr ⟨bytes, finish, rfl, declaration_value_literal value (by decide) (by decide)⟩, prior.2⟩
      | constantTwo =>
          exact ⟨prior.1, Or.inr ⟨bytes, finish, rfl, declaration_value_literal value (by decide) (by decide)⟩⟩

theorem slot_read {text bytes : Source} {position after : Nat} {value : Option Source}
    (stored : SlotCorresponds text position value) (positive : 0 < position)
    (read : Output.LiteralAt text position bytes after) : value = some bytes := by
  rcases stored with ⟨zero, absent⟩ | ⟨other, finish, same, parsed⟩
  · omega
  · rw [(Output.literalAt_unique parsed read).1] at same
    exact same

/-- Source-name resolution chooses an initialized immutable slot; its literal
normal form equals reading that slot from the elaborated environment. -/
theorem constant_read_is_bound {text bytes : Source} {context : NameContext} {values : ConstantValues}
    {first after literalAfter : Nat}
    (stored : ConstantsCorrespond text context values)
    (positive : 0 < constantValueAtName text context first after)
    (read : Output.LiteralAt text (constantValueAtName text context first after) bytes literalAfter) :
    ∃ second, matchesConstant text context second first after = true ∧ values.get second = some bytes := by
  by_cases one : (matchesConstant text context false first after && usableConstant text context.constantOneValueFirst) = true
  · simp only [constantValueAtName, one, ↓reduceIte] at positive read
    exact ⟨false, (Bool.and_eq_true_iff.mp one).1, slot_read stored.1 positive read⟩
  · by_cases two : (matchesConstant text context true first after && usableConstant text context.constantTwoValueFirst) = true
    · simp only [constantValueAtName, one, two, ↓reduceIte] at positive read
      exact ⟨true, (Bool.and_eq_true_iff.mp two).1, slot_read stored.2 positive read⟩
    · simp [constantValueAtName, one, two] at positive

/-- Direct source evaluation reads an immutable binding from its elaborated
value. It does not obtain the value by rescanning the declaration initializer. -/
inductive SourceOperandValue (text : Source) (context : NameContext) (values : ConstantValues)
    (staticValue dynamicValue : Source) : Nat → Source → Nat → Prop
  | literal {position after : Nat} {bytes : Source} :
      Cursor.triviaPosition text position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text position + 1) bytes after →
      SourceOperandValue text context values staticValue dynamicValue position bytes after
  | staticName {position after : Nat} {name : Source} :
      Named.IdentifierAt text (Cursor.triviaPosition text position) name after →
      matchesStatic text context (Cursor.triviaPosition text position) after = true →
      SourceOperandValue text context values staticValue dynamicValue position staticValue after
  | dynamicName {position after : Nat} {name : Source} :
      Named.IdentifierAt text (Cursor.triviaPosition text position) name after →
      matchesStatic text context (Cursor.triviaPosition text position) after = false →
      matchesDynamic text context (Cursor.triviaPosition text position) after = true →
      SourceOperandValue text context values staticValue dynamicValue position dynamicValue after
  | constantName {position after : Nat} {name bytes : Source} {second : Bool} :
      Named.IdentifierAt text (Cursor.triviaPosition text position) name after →
      matchesStatic text context (Cursor.triviaPosition text position) after = false →
      matchesDynamic text context (Cursor.triviaPosition text position) after = false →
      matchesConstant text context second (Cursor.triviaPosition text position) after = true →
      values.get second = some bytes →
      SourceOperandValue text context values staticValue dynamicValue position bytes after

theorem operand_read_refines {text : Source} {context : NameContext} {values : ConstantValues}
    {position after : Nat} {atom : Operand} (parsed : OperandAt text context position atom after)
    (stored : ConstantsCorrespond text context values) (staticValue dynamicValue : Source) :
    SourceOperandValue text context values staticValue dynamicValue position
      (atom.evaluate staticValue dynamicValue) after := by
  cases parsed with
  | literal bound quote value => exact .literal bound quote value
  | staticName name matched => exact .staticName name matched
  | dynamicName name different matched => exact .dynamicName name different matched
  | constantName name noStatic noDynamic header value =>
      obtain ⟨second, matched, bound⟩ := constant_read_is_bound stored (by omega) value
      exact .constantName name noStatic noDynamic matched bound

/-- Flat source concatenation over the actual values read at each operand. -/
inductive SourceExpressionValue (text : Source) (context : NameContext) (values : ConstantValues)
    (staticValue dynamicValue : Source) : Nat → Source → Nat → Prop
  | last {position after : Nat} {bytes : Source} :
      SourceOperandValue text context values staticValue dynamicValue position bytes after →
      hasAmpersand text after = false →
      SourceExpressionValue text context values staticValue dynamicValue position bytes after
  | more {position after finish : Nat} {bytes rest : Source} :
      SourceOperandValue text context values staticValue dynamicValue position bytes after →
      hasAmpersand text after = true →
      SourceExpressionValue text context values staticValue dynamicValue
        (Cursor.triviaPosition text after + 1) rest finish →
      SourceExpressionValue text context values staticValue dynamicValue position (bytes ++ rest) finish

theorem expression_read_refines {text : Source} {context : NameContext} {values : ConstantValues}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result)
    (stored : ConstantsCorrespond text context values) (staticValue dynamicValue : Source) :
    SourceExpressionValue text context values staticValue dynamicValue position
      (expression.evaluate staticValue dynamicValue) result.after := by
  induction parsed with
  | last atom fits ending =>
      simpa [Expression.evaluate, accumulated, Operand.summary] using
        SourceExpressionValue.last (operand_read_refines atom stored staticValue dynamicValue) ending
  | more atom fits ampersand previous ih =>
      exact .more (operand_read_refines atom stored staticValue dynamicValue) ampersand ih

theorem value_read_refines {text bytes : Source} {context : NameContext} {values : ConstantValues}
    {role : LiteralRole} {position after : Nat} (parsed : ValueAt text context role position bytes after)
    (stored : ConstantsCorrespond text context values) (staticValue dynamicValue : Source) :
    SourceOperandValue text (valueContext context role) values staticValue dynamicValue position bytes after := by
  by_cases copied : role = .initial ∨ role = .assigned
  · exact operand_read_refines parsed (by simpa [valueContext, copied, copyNames, ConstantsCorrespond] using stored)
      staticValue dynamicValue
  · cases parsed with
    | literal bound quote value => exact .literal bound quote value
    | constantName name noStatic noDynamic header value =>
        simp [valueContext, copied, constantValueAtName, matchesConstant] at header

/-- Each emitted initializer, replacement, and output payload is the direct
source evaluation in the current immutable environment, for any live result
and argument values. This connects normalization to statement execution. -/
def StepReadsBound (text : Source) (state : ParserState) (values : ConstantValues)
    (event : Option Event) (next : ParserState) : Prop :=
  match event with
  | some (.literal role bytes) => ∀ staticValue dynamicValue,
      SourceOperandValue text (valueContext state.context role) values staticValue dynamicValue
        state.position bytes next.position
  | some (.output expression) => ∀ staticValue dynamicValue,
      SourceExpressionValue text state.context values staticValue dynamicValue state.position
        (expression.evaluateLeft staticValue dynamicValue) next.position
  | _ => True

theorem step_reads_bound {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} {values : ConstantValues}
    (parsed : StepAt text form token state event next)
    (stored : ConstantsCorrespond text state.context values) : StepReadsBound text state values event next := by
  cases parsed with
  | literal value compatible => exact value_read_refines value stored
  | output expression safe nonzero =>
      intro staticValue dynamicValue
      simpa only [Expression.left_association] using
        expression_read_refines expression stored staticValue dynamicValue
  | staticDeclaration | constantDeclaration | dynamicDeclaration | staticReference | dynamicReference | capacity | fixed => trivial

/-- A complete source derivation with immutable environments at every step.
The slots change only when their literal declaration initializers elaborate;
result assignments and output do not modify them. -/
inductive ConstantElaboration (text : Source) (form : Form) :
    List ShellToken → ParserState → ConstantValues → List Event → Prop
  | done {state : ParserState} {values : ConstantValues} :
      ConstantsCorrespond text state.context values → ConstantElaboration text form [] state values []
  | next {token : ShellToken} {tokens : List ShellToken} {state next : ParserState}
      {values : ConstantValues} {event : Option Event} {events : List Event} :
      ConstantsCorrespond text state.context values →
      StepAt text form token state event next →
      StepReadsBound text state values event next →
      ConstantElaboration text form tokens next (values.afterEvent event) events →
      ConstantElaboration text form (token :: tokens) state values (event.toList ++ events)

theorem parsed_constant_elaboration {text : Source} {form : Form} {tokens : List ShellToken}
    {state : ParserState} {events : List Event} (parsed : Parsed text form tokens state events)
    (values : ConstantValues) (stored : ConstantsCorrespond text state.context values) :
    ConstantElaboration text form tokens state values events := by
  induction parsed generalizing values with
  | done => exact .done stored
  | next positive step rest ih => exact .next stored step (step_reads_bound step stored) (ih _ (step_constants step stored))

theorem meaning_constant_elaboration {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    ConstantElaboration source form form.tokens initialState {} events :=
  parsed_constant_elaboration meaning.2.2 {} (initial_constants source)

end Silver.Compose
