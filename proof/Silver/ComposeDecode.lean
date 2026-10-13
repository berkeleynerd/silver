module

public import Silver.ComposeGrammar
public import Silver.NamedDisjoint

@[expose] public section

namespace Silver.Compose
open Bindings

def decode : Form → List Event → Option Program
  | .direct, [.declarations values names, .output expression] => some ⟨values, names, [], .output expression⟩
  | .assignment, [.declarations values names, .assignment update, .output expression] =>
      some ⟨values, names, [], .assignment update expression⟩
  | .argument, [.argument fallback, .declarations values names, .output expression] =>
      some ⟨argumentDeclaration :: values, names, fallback, .argument none expression⟩
  | .guardedArgument, [.argument fallback, .declarations values names, .capacity bound, .output expression] =>
      some ⟨argumentDeclaration :: values, names, fallback, .argument (some bound) expression⟩
  | .branching, [.argument fallback, .declarations values names, .comparison left right, .output yes, .output no] =>
      some ⟨argumentDeclaration :: values, names, fallback, .branching none left right yes no⟩
  | .guardedBranching, [.argument fallback, .declarations values names, .capacity bound, .comparison left right, .output yes, .output no] =>
      some ⟨argumentDeclaration :: values, names, fallback, .branching (some bound) left right yes no⟩
  | .result, [.argument fallback, .declarations values names, .comparison left right, .assignment yes, .assignment no, .output expression] =>
      some ⟨argumentDeclaration :: values, names, fallback, .result none left right yes no expression⟩
  | .guardedResult, [.argument fallback, .declarations values names, .capacity bound, .comparison left right, .assignment yes, .assignment no, .output expression] =>
      some ⟨argumentDeclaration :: values, names, fallback, .result (some bound) left right yes no expression⟩
  | _, _ => none

theorem argument_declaration_valid : argumentDeclaration.Valid emptyShape .argument := by
  simp [Declaration.Valid, argumentDeclaration, emptyShape, Expression.infer,
    Expression.summary, Expression.staticLength, Expression.dynamicCount,
    Expression.PrintableLiterals, Expression.LiteralsPrintable,
    Operand.staticLength, Operand.dynamicCount, Operand.bound, Bindings.Value.infer,
    Bindings.Value.PrintableLiterals, Bound.staticPart, Bound.dynamicPart,
    Bindings.Bound.summary, Bindings.Bound.length, maxExpressionOperands]

theorem prepend_argument {values : List Declaration} {names : BindingEnvironment}
    (valid : DeclarationsValid argumentShape values names.shape) :
    DeclarationsValid emptyShape (argumentDeclaration :: values) names.shape :=
  .cons argument_declaration_valid valid

theorem declarations_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .declarations :: rest ↔
      ∃ values names tail, events = .declarations values names :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem argument_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .argument :: rest ↔
      ∃ fallback tail, events = .argument fallback :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem assignment_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .assignment :: rest ↔
      ∃ update tail, events = .assignment update :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem literal_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .literal :: rest ↔
      ∃ bytes tail, events = .literal bytes :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem comparison_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .comparison :: rest ↔
      ∃ left right tail, events = .comparison left right :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem capacity_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .capacity :: rest ↔
      ∃ bound tail, events = .capacity bound :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem output_event_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .output :: rest ↔
      ∃ expression tail, events = .output expression :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem decode_complete_spec {form : Form} {events : List Event}
    (shape : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind) :
    ∃ program, decode form events = some program ∧
      (StreamValid emptyShape maxSourceLength events → program.Valid) := by
  cases form with
  | direct =>
      change events.map Event.kind = [.declarations, .output] at shape
      obtain ⟨value0, names0, tail0, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (output_event_shape _ _).mp shape0
      have empty := List.map_eq_nil_iff.mp shape1
      subst tail1
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, List.length_nil]
      exact ⟨stream.1, (by simp [Printable, Bindings.Printable]), (by simp [maxSourceLength]), stream.2⟩
  | assignment =>
      change events.map Event.kind = [.declarations, .assignment, .output] at shape
      obtain ⟨value0, names0, tail0, rfl, shape0⟩ := (declarations_event_shape _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (assignment_event_shape _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (output_event_shape _ _).mp shape1
      have empty := List.map_eq_nil_iff.mp shape2
      subst tail2
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, List.length_nil]
      exact ⟨stream.1, (by simp [Printable, Bindings.Printable]), (by simp [maxSourceLength]), stream.2⟩
  | argument =>
      change events.map Event.kind = [.argument, .declarations, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (output_event_shape _ _).mp shape1
      have empty := List.map_eq_nil_iff.mp shape2
      subst tail2
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, ⟨Nat.le_refl _, stream.2.2.2⟩⟩
  | guardedArgument =>
      change events.map Event.kind = [.argument, .declarations, .capacity, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (capacity_event_shape _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (output_event_shape _ _).mp shape2
      have empty := List.map_eq_nil_iff.mp shape3
      subst tail3
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, stream.2.2.2⟩
  | branching =>
      change events.map Event.kind = [.argument, .declarations, .comparison, .output, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨left2, right2, tail2, rfl, shape2⟩ := (comparison_event_shape _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (output_event_shape _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (output_event_shape _ _).mp shape3
      have empty := List.map_eq_nil_iff.mp shape4
      subst tail4
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, ⟨Nat.le_refl _, stream.2.2.2⟩⟩
  | guardedBranching =>
      change events.map Event.kind = [.argument, .declarations, .capacity, .comparison, .output, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (capacity_event_shape _ _).mp shape1
      obtain ⟨left3, right3, tail3, rfl, shape3⟩ := (comparison_event_shape _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (output_event_shape _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (output_event_shape _ _).mp shape4
      have empty := List.map_eq_nil_iff.mp shape5
      subst tail5
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, stream.2.2.2⟩
  | result =>
      change events.map Event.kind = [.argument, .declarations, .comparison, .assignment, .assignment, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨left2, right2, tail2, rfl, shape2⟩ := (comparison_event_shape _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (assignment_event_shape _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (assignment_event_shape _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (output_event_shape _ _).mp shape4
      have empty := List.map_eq_nil_iff.mp shape5
      subst tail5
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, ⟨Nat.le_refl _, stream.2.2.2⟩⟩
  | guardedResult =>
      change events.map Event.kind = [.argument, .declarations, .capacity, .comparison, .assignment, .assignment, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (argument_event_shape _ _).mp shape
      obtain ⟨value1, names1, tail1, rfl, shape1⟩ := (declarations_event_shape _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (capacity_event_shape _ _).mp shape1
      obtain ⟨left3, right3, tail3, rfl, shape3⟩ := (comparison_event_shape _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (assignment_event_shape _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (assignment_event_shape _ _).mp shape4
      obtain ⟨value6, tail6, rfl, shape6⟩ := (output_event_shape _ _).mp shape5
      have empty := List.map_eq_nil_iff.mp shape6
      subst tail6
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp only [StreamValid, and_true] at stream
      simp only [Program.Valid, Body.Valid, effectiveCapacity, Option.getD]
      exact ⟨prepend_argument stream.2.2.1, stream.1, stream.2.1, stream.2.2.2⟩

theorem decode_complete {form : Form} {events : List Event}
    (shape : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind) :
    ∃ program, decode form events = some program := by
  obtain ⟨program, decoded, _⟩ := decode_complete_spec shape
  exact ⟨program, decoded⟩

theorem decoded_valid {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    ∃ program, decode form events = some program ∧ program.Valid := by
  obtain ⟨program, decoded, valid⟩ := decode_complete_spec (meaning_eventKinds meaning)
  exact ⟨program, decoded, valid (meaning_stream_valid meaning)⟩

theorem null_compose_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, form, member⟩
  obtain ⟨events, parsed⟩ := member.2.2.2.2
  obtain ⟨tokens, spelling⟩ : ∃ tokens, form.tokens = .fixed "with" true :: tokens := by
    cases form <;> exact ⟨_, rfl⟩
  rw [spelling] at parsed
  cases parsed with
  | next first rest =>
      have accepted := first.following
      rw [← first.scanned] at accepted
      have matched : fixedAt source (Cursor.triviaPosition source 1) "with" true = true := by
        by_cases found : fixedAt source (Cursor.triviaPosition source 1) "with" true = true
        · exact found
        · simp [step, initialState, fixedAfter, found] at accepted
      have nullParsed := (Cursor.isMember_iff source).mpr nullMember
      change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
        .procedureKeyword && _)) = true at nullParsed
      simp only [Bool.and_eq_true] at nullParsed
      have nullToken := nullParsed.2.1
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstOutput := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling] at firstNull firstOutput
      omega

theorem meaning_argument_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasArguments source = form.hasArguments := by
  simp [hasArguments, meaning.2.1]

theorem meaning_assignment_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasAssignment source = form.hasAssignment := by
  simp [hasAssignment, meaning.2.1]

end Silver.Compose
