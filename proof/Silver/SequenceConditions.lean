module

public import Silver.SequenceBasics
public import Silver.SequenceLists
public import Silver.ComposeDecode

@[expose] public section

/-! One-level equality choices compose the same nonempty simple-statement
lists as ordinary sequencing. Both arms retain the shared fixed binding shape. -/

namespace Silver.Sequence
open Compose Bindings

abbrev BasicListAt (text : Source) (scan : ScanResult) (stop : ShellToken)
    (items : List SimpleStatement) (final : ScanResult) : Prop :=
  NonemptyAt text (basicStatementAt text) stop (BasicAt text) scan items final

theorem basicList_sound (text : Source) (scan : ScanResult) (stop : ShellToken)
    (accepted : (readBasicStatements text scan stop).state.position ≠ 0) :
    ∃ items, BasicListAt text scan stop items (readBasicStatements text scan stop) :=
  nonempty_sound text (basicStatementAt text) stop (BasicAt text) (basic_sound text) scan accepted

theorem basicList_complete {text scan stop items final}
    (parsed : BasicListAt text scan stop items final) : readBasicStatements text scan stop = final :=
  nonempty_complete parsed

theorem basicList_unique {text scan stop left right first second}
    (a : BasicListAt text scan stop left first) (b : BasicListAt text scan stop right second) :
    left = right ∧ first = second := nonempty_unique (Reading := BasicAt text) basic_unique a b

theorem basicList_positive {text scan stop items final}
    (parsed : BasicListAt text scan stop items final) :
    scan.state.position ≠ 0 ∧ final.state.position ≠ 0 := by
  cases parsed with
  | cons first _ following => exact ⟨(basic_positive first).1, (tailAt_positive following).2⟩

theorem basicList_valid {text scan stop items final}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : BasicListAt text scan stop items final) :
    StateValid final.state ∧ SimpleStatementsValid scan.state.names.shape scan.state.capacity items ∧
      final.state.names = scan.state.names ∧ final.state.capacity = scan.state.capacity := by
  have preserved := nonempty_preserves (Reading := BasicAt text)
    (Invariant := fun next => StateValid next.state ∧ next.state.names = scan.state.names ∧
      next.state.capacity = scan.state.capacity)
    (Valid := fun item => item.Valid scan.state.names.shape scan.state.capacity)
    (fun {current item next} reading invariant => by
      have facts := basic_valid domain invariant.1 reading
      exact ⟨⟨facts.1, facts.2.2.1.trans invariant.2.1, facts.2.2.2.trans invariant.2.2⟩,
        by simpa only [invariant.2.1, invariant.2.2] using facts.2.1⟩)
    parsed ⟨valid, rfl, rfl⟩
  exact ⟨preserved.1.1, preserved.2, preserved.1.2⟩

def conditionalComparison (text : Source) (scan : ScanResult) : ScanResult :=
  scanTokens text .direct equalityTokens scan

def conditionalYes (text : Source) (scan : ScanResult) : ScanResult :=
  readBasicStatements text (conditionalComparison text scan) (.word "else")

def conditionalNoStart (text : Source) (scan : ScanResult) : ScanResult :=
  scanToken text (conditionalYes text scan) (.word "else")

def conditionalNo (text : Source) (scan : ScanResult) : ScanResult :=
  readBasicStatements text (conditionalNoStart text scan) (.word "end")

inductive ConditionalAt (text : Source) : ScanResult → Statement → ScanResult → Prop
  | choice {scan next left right yes no} :
      conditionalAt text scan = next →
      TokensAt text .direct equalityTokens scan.state [.comparison left right]
        (conditionalComparison text scan).state →
      BasicListAt text (conditionalComparison text scan) (.word "else") yes (conditionalYes text scan) →
      TokensAt text .direct [.word "else"] (conditionalYes text scan).state []
        (conditionalNoStart text scan).state →
      BasicListAt text (conditionalNoStart text scan) (.word "end") no (conditionalNo text scan) →
      TokensAt text .direct endIfTokens (conditionalNo text scan).state [] next.state →
      ConditionalAt text scan (.choice left right yes no) next

theorem conditional_reduction {text : Source} {scan : ScanResult}
    (accepted : (conditionalAt text scan).state.position ≠ 0) :
    conditionalAt text scan = conditionalRaw text scan := by
  unfold conditionalAt at *
  split <;> rename_i branch
  · simp [branch, invalidScan, invalidState] at accepted
  · rfl

theorem conditional_sound (text : Source) (scan : ScanResult)
    (accepted : (conditionalAt text scan).state.position ≠ 0) :
    ∃ item, ConditionalAt text scan item (conditionalAt text scan) := by
  have same := conditional_reduction accepted
  have endPositive : (scanTokens text .direct endIfTokens (conditionalNo text scan)).state.position ≠ 0 := by
    simpa only [same, conditionalRaw, conditionalNo, conditionalNoStart, conditionalYes,
      conditionalComparison] using accepted
  have noPositive : (conditionalNo text scan).state.position ≠ 0 := fun zero =>
    endPositive (scanTokens_zero text .direct endIfTokens (conditionalNo text scan) zero)
  obtain ⟨no, noParsed⟩ := basicList_sound text (conditionalNoStart text scan) (.word "end") noPositive
  have noStartPositive := (basicList_positive noParsed).1
  have yesPositive : (conditionalYes text scan).state.position ≠ 0 := fun zero =>
    noStartPositive (step_zero text .direct (.word "else") (conditionalYes text scan).state zero)
  obtain ⟨yes, yesParsed⟩ := basicList_sound text (conditionalComparison text scan) (.word "else") yesPositive
  obtain ⟨events, comparison⟩ := tokens_sound text .direct equalityTokens scan
    (basicList_positive yesParsed).1
  have comparisonShape : events.map Event.kind = [.comparison] := by
    simpa only [equalityTokens, List.filterMap_cons, List.filterMap_nil, ShellToken.eventKind,
      ShellToken.word] using tokens_kinds comparison
  obtain ⟨left, right, rest, rfl, empty⟩ := (comparison_event_shape events []).mp comparisonShape
  have noRest : rest = [] := List.map_eq_nil_iff.mp empty
  subst rest
  obtain ⟨elseEvents, middle⟩ := tokens_sound text .direct [.word "else"] (conditionalYes text scan) noStartPositive
  have noElseEvents : elseEvents = [] := List.map_eq_nil_iff.mp (by
    simpa only [List.filterMap_cons, List.filterMap_nil, ShellToken.eventKind, ShellToken.word]
      using tokens_kinds middle)
  subst elseEvents
  obtain ⟨endEvents, ending⟩ := tokens_sound text .direct endIfTokens (conditionalNo text scan) endPositive
  have noEndEvents : endEvents = [] := List.map_eq_nil_iff.mp (by
    simpa only [endIfTokens, List.filterMap_cons, List.filterMap_nil, ShellToken.eventKind,
      ShellToken.word, ShellToken.symbol] using tokens_kinds ending)
  subst endEvents
  refine ⟨.choice left right yes no, .choice rfl comparison yesParsed middle noParsed ?_⟩
  simpa only [same, conditionalRaw, conditionalNo, conditionalNoStart, conditionalYes,
    conditionalComparison] using ending

theorem conditional_complete {text scan item next}
    (parsed : ConditionalAt text scan item next) : conditionalAt text scan = next := by
  cases parsed with
  | choice scanned => exact scanned

theorem conditional_positive {text scan item next}
    (parsed : ConditionalAt text scan item next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  cases parsed with
  | choice _ comparison _ _ _ ending => exact ⟨(tokens_positive comparison).1, (tokens_positive ending).2⟩

theorem conditional_unique {text scan left right first second}
    (a : ConditionalAt text scan left first) (b : ConditionalAt text scan right second) :
    left = right ∧ first = second := by
  cases a with
  | choice scanned comparison yes _ no _ =>
      cases b with
      | choice other otherComparison otherYes _ otherNo _ =>
          have names := (tokens_unique comparison otherComparison).1
          have yesSame := (basicList_unique yes otherYes).1
          have noSame := (basicList_unique no otherNo).1
          simp only [List.cons.injEq, Event.comparison.injEq, and_true] at names
          obtain ⟨rfl, rfl⟩ := names
          cases yesSame
          cases noSame
          exact ⟨rfl, scanned.symm.trans other⟩

theorem conditional_valid {text scan item next}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : ConditionalAt text scan item next) :
    StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
      next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
  cases parsed with
  | choice _ comparison yesParsed middle noParsed ending =>
      obtain ⟨compValid, expressions⟩ := tokens_valid domain comparison valid
      have safe := expressions [] trivial
      simp only [List.append_nil, StreamValid] at safe
      have comparisonShape := tokens_shape (by simp [equalityTokens, ShapeToken, ShellToken.word]) comparison
      have yesValid := basicList_valid domain compValid yesParsed
      have yesNames := yesValid.2.2.1.trans comparisonShape.1
      have yesCapacity := yesValid.2.2.2.trans comparisonShape.2
      have middleValid := (tokens_valid domain middle yesValid.1).1
      have middleShape := tokens_shape (by simp [ShapeToken, ShellToken.word]) middle
      have middleNames := middleShape.1.trans yesNames
      have middleCapacity := middleShape.2.trans yesCapacity
      have noValid := basicList_valid domain middleValid noParsed
      have noNames := noValid.2.2.1.trans middleNames
      have noCapacity := noValid.2.2.2.trans middleCapacity
      have endValid := (tokens_valid domain ending noValid.1).1
      have endShape := tokens_shape (by simp [endIfTokens, ShapeToken, ShellToken.word, ShellToken.symbol]) ending
      refine ⟨endValid, ?_, endShape.1.trans noNames, endShape.2.trans noCapacity⟩
      exact ⟨safe.1, safe.2.1, nonempty_items yesParsed, nonempty_items noParsed,
        by simpa only [comparisonShape.1, comparisonShape.2] using yesValid.2.1,
        by simpa only [middleNames, middleCapacity] using noValid.2.1⟩

inductive StatementAt (text : Source) : ScanResult → Statement → ScanResult → Prop
  | simple {scan item next} : fixedAfter text scan.state.position "if" true = 0 →
      BasicAt text scan item next → StatementAt text scan (.simple item) next
  | conditional {scan item next} : fixedAfter text scan.state.position "if" true ≠ 0 →
      ConditionalAt text scan item next → StatementAt text scan item next

theorem statement_sound (text : Source) (scan : ScanResult)
    (accepted : (statementAt text scan).state.position ≠ 0) :
    ∃ item, StatementAt text scan item (statementAt text scan) := by
  by_cases choice : fixedAfter text scan.state.position "if" true ≠ 0
  · rw [statementAt, ite_eq_left choice] at accepted ⊢
    obtain ⟨item, parsed⟩ := conditional_sound text scan accepted
    exact ⟨item, .conditional choice parsed⟩
  · rw [statementAt, ite_eq_right choice] at accepted ⊢
    obtain ⟨item, parsed⟩ := basic_sound text scan accepted
    exact ⟨.simple item, .simple (by simpa using choice) parsed⟩

theorem statement_complete {text scan item next}
    (parsed : StatementAt text scan item next) : statementAt text scan = next := by
  cases parsed with
  | simple absent parsed => simp only [statementAt, absent, ne_eq, not_true_eq_false, ↓reduceIte, basic_scanned parsed]
  | conditional present parsed => rw [statementAt, ite_eq_left present]; exact conditional_complete parsed

theorem statement_positive {text scan item next}
    (parsed : StatementAt text scan item next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  cases parsed with
  | simple _ basic => exact basic_positive basic
  | conditional _ choice => exact conditional_positive choice

theorem statement_unique {text scan left right first second}
    (a : StatementAt text scan left first) (b : StatementAt text scan right second) :
    left = right ∧ first = second := by
  cases a with
  | simple absent first =>
      cases b with
      | simple _ second =>
          have same := basic_unique first second
          exact ⟨congrArg Statement.simple same.1, same.2⟩
      | conditional present => exact False.elim (present absent)
  | conditional present first =>
      cases b with
      | simple absent => exact False.elim (present absent)
      | conditional _ second => exact conditional_unique first second

theorem statement_valid {text scan item next}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : StatementAt text scan item next) :
    StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
      next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
  cases parsed with
  | simple _ basic => exact basic_valid domain valid basic
  | conditional _ choice => exact conditional_valid domain valid choice

abbrev StatementsAt (text : Source) (scan : ScanResult) (stop : ShellToken)
    (items : List Statement) (final : ScanResult) : Prop :=
  NonemptyAt text (statementAt text) stop (StatementAt text) scan items final

theorem statements_sound (text : Source) (scan : ScanResult) (stop : ShellToken)
    (accepted : (readStatements text scan stop).state.position ≠ 0) :
    ∃ items, StatementsAt text scan stop items (readStatements text scan stop) :=
  nonempty_sound text (statementAt text) stop (StatementAt text) (statement_sound text) scan accepted

theorem statements_complete {text scan stop items final}
    (parsed : StatementsAt text scan stop items final) : readStatements text scan stop = final :=
  nonempty_complete parsed

theorem statements_unique {text scan stop left right first second}
    (a : StatementsAt text scan stop left first) (b : StatementsAt text scan stop right second) :
    left = right ∧ first = second := nonempty_unique (Reading := StatementAt text) statement_unique a b

theorem statements_positive {text scan stop items final}
    (parsed : StatementsAt text scan stop items final) :
    scan.state.position ≠ 0 ∧ final.state.position ≠ 0 := by
  cases parsed with
  | cons first _ following => exact ⟨(statement_positive first).1, (tailAt_positive following).2⟩

theorem statements_input_positive {text scan stop}
    (accepted : (readStatements text scan stop).state.position ≠ 0) : scan.state.position ≠ 0 := by
  obtain ⟨items, parsed⟩ := statements_sound text scan stop accepted
  exact (statements_positive parsed).1

theorem statements_valid {text scan stop items final}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : StatementsAt text scan stop items final) :
    StateValid final.state ∧ StatementsValid scan.state.names.shape scan.state.capacity items ∧
      final.state.names = scan.state.names ∧ final.state.capacity = scan.state.capacity := by
  have preserved := nonempty_preserves (Reading := StatementAt text)
    (Invariant := fun next => StateValid next.state ∧ next.state.names = scan.state.names ∧
      next.state.capacity = scan.state.capacity)
    (Valid := fun item => item.Valid scan.state.names.shape scan.state.capacity)
    (fun {current item next} reading invariant => by
      have facts := statement_valid domain invariant.1 reading
      exact ⟨⟨facts.1, facts.2.2.1.trans invariant.2.1, facts.2.2.2.trans invariant.2.2⟩,
        by simpa only [invariant.2.1, invariant.2.2] using facts.2.1⟩)
    parsed ⟨valid, rfl, rfl⟩
  exact ⟨preserved.1.1, preserved.2, preserved.1.2⟩

end Silver.Sequence
