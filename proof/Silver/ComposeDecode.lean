import Silver.ComposeMain
import Silver.ComposeSemantics
import Silver.NamedDisjoint

namespace Silver.Compose

theorem declaration_shape (events : List Event) (dynamic : Bool) (rest : List EventKind) :
    events.map Event.kind = .declaration dynamic :: rest ↔
      ∃ name tail, events = .declaration dynamic name :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem constant_declaration_shape (events : List Event) (second : Bool) (rest : List EventKind) :
    events.map Event.kind = .constantDeclaration second :: rest ↔
      ∃ name tail, events = .constantDeclaration second name :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem reference_shape (events : List Event) (dynamic : Bool) (rest : List EventKind) :
    events.map Event.kind = .reference dynamic :: rest ↔
      ∃ tail, events = .reference dynamic :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem literal_shape (events : List Event) (role : LiteralRole) (rest : List EventKind) :
    events.map Event.kind = .literal role :: rest ↔
      ∃ bytes tail, events = .literal role bytes :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem capacity_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .capacity :: rest ↔
      ∃ value tail, events = .capacity value :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem output_shape (events : List Event) (rest : List EventKind) :
    events.map Event.kind = .output :: rest ↔
      ∃ expression tail, events = .output expression :: tail ∧ tail.map Event.kind = rest := by
  cases events with
  | nil => simp
  | cons event tail => cases event <;> simp [Event.kind, List.cons.injEq, and_assoc]

theorem decode_complete_spec {form : Form} {events : List Event}
    (shape : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind) :
    ∃ program, decode form events = some program ∧
      (StreamValid form 0 maxSourceLength events → program.Valid) := by
  cases form with
  | direct =>
      change events.map Event.kind = [.output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (output_shape _ _).mp shape
      have empty := List.map_eq_nil_iff.mp shape0
      subst tail0
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, Program.Valid, SafeExpression, Form.hasAssignment]
  | static =>
      change events.map Event.kind = [.declaration false, .literal .initial, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (output_shape _ _).mp shape1
      have empty := List.map_eq_nil_iff.mp shape2
      subst tail2
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, Form.hasAssignment]
  | assignment =>
      change events.map Event.kind = [.declaration false, .literal .initial, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨tail2, rfl, shape2⟩ := (reference_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (output_shape _ _).mp shape3
      have empty := List.map_eq_nil_iff.mp shape4
      subst tail4
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, Form.hasAssignment]
  | argument =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (output_shape _ _).mp shape1
      have empty := List.map_eq_nil_iff.mp shape2
      subst tail2
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | guardedArgument =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .reference true, .capacity, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨tail2, rfl, shape2⟩ := (reference_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (capacity_shape _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (output_shape _ _).mp shape3
      have empty := List.map_eq_nil_iff.mp shape4
      subst tail4
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | branching =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .reference true, .literal .ordinary, .output, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨tail2, rfl, shape2⟩ := (reference_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (output_shape _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (output_shape _ _).mp shape4
      have empty := List.map_eq_nil_iff.mp shape5
      subst tail5
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | guardedBranching =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .reference true, .capacity, .reference true, .literal .ordinary, .output, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨tail2, rfl, shape2⟩ := (reference_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (capacity_shape _ _).mp shape2
      obtain ⟨tail4, rfl, shape4⟩ := (reference_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨value6, tail6, rfl, shape6⟩ := (output_shape _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (output_shape _ _).mp shape6
      have empty := List.map_eq_nil_iff.mp shape7
      subst tail7
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | result =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .declaration false, .literal .initial, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨tail4, rfl, shape4⟩ := (reference_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨tail6, rfl, shape6⟩ := (reference_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (literal_shape _ _ _).mp shape8
      obtain ⟨value10, tail10, rfl, shape10⟩ := (output_shape _ _).mp shape9
      have empty := List.map_eq_nil_iff.mp shape10
      subst tail10
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | guardedResult =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .declaration false, .literal .initial, .reference true, .capacity, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨tail4, rfl, shape4⟩ := (reference_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (capacity_shape _ _).mp shape4
      obtain ⟨tail6, rfl, shape6⟩ := (reference_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (literal_shape _ _ _).mp shape8
      obtain ⟨tail10, rfl, shape10⟩ := (reference_shape _ _ _).mp shape9
      obtain ⟨value11, tail11, rfl, shape11⟩ := (literal_shape _ _ _).mp shape10
      obtain ⟨value12, tail12, rfl, shape12⟩ := (output_shape _ _).mp shape11
      have empty := List.map_eq_nil_iff.mp shape12
      subst tail12
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]

  | assignmentOne =>
      change events.map Event.kind = [.constantDeclaration false, .literal .constantOne, .declaration false, .literal .initial, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (constant_declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨tail4, rfl, shape4⟩ := (reference_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨value6, tail6, rfl, shape6⟩ := (output_shape _ _).mp shape5
      have empty := List.map_eq_nil_iff.mp shape6
      subst tail6
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, Form.hasAssignment]
  | assignmentTwo =>
      change events.map Event.kind = [.constantDeclaration false, .literal .constantOne, .constantDeclaration true, .literal .constantTwo, .declaration false, .literal .initial, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (constant_declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (constant_declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (declaration_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨tail6, rfl, shape6⟩ := (reference_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨value8, tail8, rfl, shape8⟩ := (output_shape _ _).mp shape7
      have empty := List.map_eq_nil_iff.mp shape8
      subst tail8
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, Form.hasAssignment]
  | resultOne =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .constantDeclaration false, .literal .constantOne, .declaration false, .literal .initial, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (constant_declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (declaration_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨tail6, rfl, shape6⟩ := (reference_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (literal_shape _ _ _).mp shape8
      obtain ⟨tail10, rfl, shape10⟩ := (reference_shape _ _ _).mp shape9
      obtain ⟨value11, tail11, rfl, shape11⟩ := (literal_shape _ _ _).mp shape10
      obtain ⟨value12, tail12, rfl, shape12⟩ := (output_shape _ _).mp shape11
      have empty := List.map_eq_nil_iff.mp shape12
      subst tail12
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | resultTwo =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .constantDeclaration false, .literal .constantOne, .constantDeclaration true, .literal .constantTwo, .declaration false, .literal .initial, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (constant_declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (constant_declaration_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨value6, tail6, rfl, shape6⟩ := (declaration_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (literal_shape _ _ _).mp shape8
      obtain ⟨tail10, rfl, shape10⟩ := (reference_shape _ _ _).mp shape9
      obtain ⟨value11, tail11, rfl, shape11⟩ := (literal_shape _ _ _).mp shape10
      obtain ⟨tail12, rfl, shape12⟩ := (reference_shape _ _ _).mp shape11
      obtain ⟨value13, tail13, rfl, shape13⟩ := (literal_shape _ _ _).mp shape12
      obtain ⟨value14, tail14, rfl, shape14⟩ := (output_shape _ _).mp shape13
      have empty := List.map_eq_nil_iff.mp shape14
      subst tail14
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | guardedResultOne =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .constantDeclaration false, .literal .constantOne, .declaration false, .literal .initial, .reference true, .capacity, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (constant_declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (declaration_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨tail6, rfl, shape6⟩ := (reference_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (capacity_shape _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (literal_shape _ _ _).mp shape8
      obtain ⟨tail10, rfl, shape10⟩ := (reference_shape _ _ _).mp shape9
      obtain ⟨value11, tail11, rfl, shape11⟩ := (literal_shape _ _ _).mp shape10
      obtain ⟨tail12, rfl, shape12⟩ := (reference_shape _ _ _).mp shape11
      obtain ⟨value13, tail13, rfl, shape13⟩ := (literal_shape _ _ _).mp shape12
      obtain ⟨value14, tail14, rfl, shape14⟩ := (output_shape _ _).mp shape13
      have empty := List.map_eq_nil_iff.mp shape14
      subst tail14
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]
  | guardedResultTwo =>
      change events.map Event.kind = [.declaration true, .literal .ordinary, .constantDeclaration false, .literal .constantOne, .constantDeclaration true, .literal .constantTwo, .declaration false, .literal .initial, .reference true, .capacity, .reference true, .literal .ordinary, .reference false, .literal .assigned, .reference false, .literal .assigned, .output] at shape
      obtain ⟨value0, tail0, rfl, shape0⟩ := (declaration_shape _ _ _).mp shape
      obtain ⟨value1, tail1, rfl, shape1⟩ := (literal_shape _ _ _).mp shape0
      obtain ⟨value2, tail2, rfl, shape2⟩ := (constant_declaration_shape _ _ _).mp shape1
      obtain ⟨value3, tail3, rfl, shape3⟩ := (literal_shape _ _ _).mp shape2
      obtain ⟨value4, tail4, rfl, shape4⟩ := (constant_declaration_shape _ _ _).mp shape3
      obtain ⟨value5, tail5, rfl, shape5⟩ := (literal_shape _ _ _).mp shape4
      obtain ⟨value6, tail6, rfl, shape6⟩ := (declaration_shape _ _ _).mp shape5
      obtain ⟨value7, tail7, rfl, shape7⟩ := (literal_shape _ _ _).mp shape6
      obtain ⟨tail8, rfl, shape8⟩ := (reference_shape _ _ _).mp shape7
      obtain ⟨value9, tail9, rfl, shape9⟩ := (capacity_shape _ _).mp shape8
      obtain ⟨tail10, rfl, shape10⟩ := (reference_shape _ _ _).mp shape9
      obtain ⟨value11, tail11, rfl, shape11⟩ := (literal_shape _ _ _).mp shape10
      obtain ⟨tail12, rfl, shape12⟩ := (reference_shape _ _ _).mp shape11
      obtain ⟨value13, tail13, rfl, shape13⟩ := (literal_shape _ _ _).mp shape12
      obtain ⟨tail14, rfl, shape14⟩ := (reference_shape _ _ _).mp shape13
      obtain ⟨value15, tail15, rfl, shape15⟩ := (literal_shape _ _ _).mp shape14
      obtain ⟨value16, tail16, rfl, shape16⟩ := (output_shape _ _).mp shape15
      have empty := List.map_eq_nil_iff.mp shape16
      subst tail16
      refine ⟨_, rfl, ?_⟩
      intro stream
      simp_all [StreamValid, LiteralDomain, Program.Valid, SafeExpression, Printable, effectiveCapacity, Form.hasAssignment]

theorem decode_complete {form : Form} {events : List Event}
    (shape : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind) :
    ∃ program, decode form events = some program := by
  obtain ⟨program, decoded, _⟩ := decode_complete_spec shape
  exact ⟨program, decoded⟩

theorem decode_complete_valid {form : Form} {events : List Event}
    (shape : events.map Event.kind = form.tokens.filterMap ShellToken.eventKind)
    (stream : StreamValid form 0 maxSourceLength events) :
    ∃ program, decode form events = some program ∧ program.Valid := by
  obtain ⟨program, decoded, valid⟩ := decode_complete_spec shape
  exact ⟨program, decoded, valid stream⟩

theorem decoded_valid {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) :
    ∃ program, decode form events = some program ∧ program.Valid :=
  decode_complete_valid (meaning_eventKinds meaning) (meaning_stream_valid meaning)

theorem null_compose_disjoint (source : Source) : ¬ (Silver.Member source ∧ Member source) := by
  rintro ⟨nullMember, composed⟩
  obtain ⟨form, member⟩ := composed
  obtain ⟨events, parsed⟩ := member.2.2.2
  obtain ⟨tokens, spelling⟩ : ∃ tokens, form.tokens = .fixed "with" true :: tokens := by
    cases form <;> exact ⟨_, rfl⟩
  rw [spelling] at parsed
  cases parsed with
  | next positive first rest =>
    cases first with
    | fixed matched =>
      have nullParsed := (Cursor.isMember_iff source).mpr nullMember
      change (_ && _ && (Cursor.tokenAt source (Cursor.triviaPosition source 1)
        .procedureKeyword && _)) = true at nullParsed
      simp only [Bool.and_eq_true] at nullParsed
      have nullToken := nullParsed.2.1
      simp only [Cursor.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at nullToken
      simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
      have firstNull := nullToken.1.2 ⟨0, by decide⟩
      have firstOutput := matched.1.2 ⟨0, by decide⟩
      simp [Silver.Token.spelling, initialState] at firstNull firstOutput
      omega

theorem meaning_argument_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasArguments source = form.hasArguments := by
  simp [hasArguments, meaning.2.1]

theorem meaning_assignment_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasAssignment source = form.hasAssignment := by
  simp [hasAssignment, meaning.2.1]

end Silver.Compose

