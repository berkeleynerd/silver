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

def firstByte (spelling : String) : Nat := (spelling.toList.map Char.toNat).headD 0

theorem fixed_first {text : Source} {position : Nat} {spelling : String} {word : Bool}
    (nonempty : 0 < spelling.length) (matched : fixedAt text position spelling word = true) :
    lowercase (Cursor.byteAt text position) = firstByte spelling := by
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
  have bytesPositive : 0 < (spelling.toList.map Char.toNat).length := by simpa [String.length] using nonempty
  have first := matched.1.2 ⟨0, bytesPositive⟩
  cases chars : spelling.toList with
  | nil => simp [chars] at bytesPositive
  | cons character rest => simpa [firstByte, chars] using first

private theorem beginLetters : ∀ index : Fin Output.Token.beginKeyword.spelling.length,
    identifierCharacter Output.Token.beginKeyword.spelling[index.val] = true := by decide +kernel

theorem begin_declaration_disjoint {text : Source} {form otherForm : Form} {state left right : ParserState}
    {event otherEvent : Option Event}
    (first : StepAt text form (.fixed "begin" true) state event left)
    (second : StepAt text otherForm .staticDeclaration state otherEvent right) : False := by
  cases first with
  | fixed matched =>
    cases second with
    | @staticDeclaration state name finish parsed allowed =>
      have nameBounds := Named.identifier_bounds parsed
      have positive : 1 ≤ Cursor.triviaPosition text state.position := by
        unfold Cursor.triviaPosition Cursor.endPosition
        have trivia := triviaEnd_length (Cursor.remaining text state.position)
        have remaining := Cursor.remaining_length text state.position
        omega
      have bounded : Cursor.triviaPosition text state.position ≤ text.length + 1 := by
        unfold Cursor.triviaPosition Cursor.endPosition
        omega
      have word : Output.tokenAt text (Cursor.triviaPosition text state.position) .beginKeyword = true := matched
      obtain ⟨_, value⟩ := Named.identifier_token positive bounded parsed word rfl beginLetters
      have canonical : Named.canonicalName text (Cursor.triviaPosition text state.position) finish =
          Output.Token.beginKeyword.spelling := by
        unfold Named.canonicalName
        rw [← Named.identifier_span parsed positive]
        exact value
      have forbidden := (Named.forbiddenName_iff text _ _ positive
        (Nat.le_of_lt nameBounds.2.2.1) nameBounds.2.2.2).mpr (by rw [canonical]; decide +kernel)
      simp [staticNameAllowed, forbidden] at allowed

def tokenClash : ShellToken → ShellToken → Bool
  | .fixed left _, .fixed right _ => decide (0 < left.length ∧ 0 < right.length ∧ firstByte left ≠ firstByte right)
  | .fixed spelling word, .staticDeclaration => decide (spelling = "begin" ∧ word = true)
  | .staticDeclaration, .fixed spelling word => decide (spelling = "begin" ∧ word = true)
  | _, _ => false

theorem step_clash {text : Source} {leftForm rightForm : Form} {leftToken rightToken : ShellToken}
    {state leftState rightState : ParserState} {leftEvent rightEvent : Option Event}
    (clash : tokenClash leftToken rightToken = true)
    (first : StepAt text leftForm leftToken state leftEvent leftState)
    (second : StepAt text rightForm rightToken state rightEvent rightState) : False := by
  cases leftToken <;> cases rightToken <;> simp only [tokenClash, Bool.false_eq_true, decide_eq_true_eq] at clash
  case fixed.fixed left leftWord right rightWord =>
    cases first with
    | fixed leftMatch =>
      cases second with
      | fixed rightMatch =>
        exact clash.2.2 ((fixed_first clash.1 leftMatch).symm.trans (fixed_first clash.2.1 rightMatch))
  case fixed.staticDeclaration spelling word =>
    rcases clash with ⟨rfl, rfl⟩
    exact begin_declaration_disjoint first second
  case staticDeclaration.fixed spelling word =>
    rcases clash with ⟨rfl, rfl⟩
    exact begin_declaration_disjoint second first

theorem step_form_independent (text : Source) (left right : Form) (token : ShellToken) (state : ParserState)
    (notOutput : token ≠ .outputExpression) : step text left token state = step text right token state := by
  cases token <;> simp_all [step]

def listsClash : List ShellToken → List ShellToken → Bool
  | left :: lefts, right :: rights =>
      if left = right ∧ left ≠ .outputExpression then listsClash lefts rights else tokenClash left right
  | _, _ => false

theorem suffixes_clash (text : Source) (leftForm rightForm : Form)
    (left right : List ShellToken) (state : ParserState) (clash : listsClash left right = true)
    (first : suffixMatches text leftForm left state = true)
    (second : suffixMatches text rightForm right state = true) : False := by
  induction left generalizing right state with
  | nil => simp [listsClash] at clash
  | cons left lefts ih =>
    cases right with
    | nil => simp [listsClash] at clash
    | cons right rights =>
      simp only [listsClash] at clash
      simp only [suffixMatches, Bool.and_eq_true, decide_eq_true_eq] at first second
      split at clash
      · rename_i same
        have tokenEqual := same.1
        subst right
        have equal := step_form_independent text leftForm rightForm left state same.2
        rw [equal] at first
        exact ih rights _ clash first.2 second.2
      · obtain ⟨leftEvent, leftStep⟩ := step_sound text leftForm left state (suffix_position first.2)
        obtain ⟨rightEvent, rightStep⟩ := step_sound text rightForm right state (suffix_position second.2)
        exact step_clash clash leftStep rightStep

theorem distinct_form_tokens (left right : Form) (different : left ≠ right) :
    listsClash left.tokens right.tokens = true := by
  cases left <;> cases right <;> first | exact False.elim (different rfl) | decide +kernel

theorem form_meaning_unique {source : Source} {left right : Form}
    (first : FormMember source left) (second : FormMember source right) : left = right := by
  by_cases same : left = right
  · exact same
  · apply False.elim
    obtain ⟨leftEvents, leftParsed⟩ := first.2.2.2
    obtain ⟨rightEvents, rightParsed⟩ := second.2.2.2
    exact suffixes_clash source left right left.tokens right.tokens initialState
      (distinct_form_tokens left right same) (parsed_complete leftParsed) (parsed_complete rightParsed)

theorem meaning_argument_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasArguments source = form.hasArguments := by
  apply Bool.eq_iff_iff.mpr
  simp only [hasArguments, List.any_eq_true, Bool.and_eq_true]
  constructor
  · rintro ⟨other, _, arguments, accepted⟩
    have equal := form_meaning_unique meaning.1 ((formAccepts_iff source other).mp accepted)
    simpa [equal] using arguments
  · intro arguments
    exact ⟨form, allForms_complete form, arguments, (formAccepts_iff source form).mpr meaning.1⟩

theorem meaning_assignment_selector {source : Source} {form : Form} {events : List Event}
    (meaning : SourceMeaning source form events) : hasAssignment source = form.hasAssignment := by
  apply Bool.eq_iff_iff.mpr
  simp only [hasAssignment, List.any_eq_true, Bool.and_eq_true]
  constructor
  · rintro ⟨other, _, assignment, accepted⟩
    have equal := form_meaning_unique meaning.1 ((formAccepts_iff source other).mp accepted)
    simpa [equal] using assignment
  · intro assignment
    exact ⟨form, allForms_complete form, assignment, (formAccepts_iff source form).mpr meaning.1⟩

end Silver.Compose

