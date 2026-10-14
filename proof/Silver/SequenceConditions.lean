module

public import Silver.SequenceBasics
public import Silver.SequenceLists
public import Silver.ComposeDecode

@[expose] public section

/-! Recursive equality choices retain exact written arms and the shared fixed
binding shape. Every reading is linked to the executable scanner. -/

namespace Silver.Sequence
open Compose Bindings

abbrev BasicListAt (text : Source) (scan : ScanResult) (stop : ShellToken)
    (items : List SimpleStatement) (final : ScanResult) : Prop :=
  NonemptyAt text (basicStatementAt text) (.token stop) (BasicAt text) scan items final

theorem basicList_sound (text : Source) (scan : ScanResult) (stop : ShellToken)
    (accepted : (readBasicStatements text scan stop).state.position ≠ 0) :
    ∃ items, BasicListAt text scan stop items (readBasicStatements text scan stop) :=
  nonempty_sound text (basicStatementAt text) (.token stop) (BasicAt text) (basic_sound text) scan accepted

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

mutual
  inductive StatementAt (text : Source) : ScanResult → Statement → ScanResult → Prop
    | simple {scan item next} : fixedAfter text scan.state.position "if" true = 0 →
        BasicAt text scan item next → StatementAt text scan (.simple item) next
    | conditional {scan item next} : fixedAfter text scan.state.position "if" true ≠ 0 →
        ConditionalAt text scan item next → StatementAt text scan item next

  inductive ConditionalAt (text : Source) : ScanResult → Statement → ScanResult → Prop
    | choice {scan next comparison yesEnd tailEnd left right yes otherwise} :
        conditionalAt text scan = next →
        TokensAt text .direct equalityTokens scan.state [.comparison left right] comparison.state →
        comparison = scanTokens text .direct equalityTokens scan →
        BodyAt text comparison .arm yes yesEnd →
        AlternativeAt text yesEnd otherwise tailEnd →
        TokensAt text .direct endIfTokens tailEnd.state [] next.state →
        ConditionalAt text scan (.choice left right yes otherwise) next

  inductive AlternativeAt (text : Source) : ScanResult → Alternative → ScanResult → Prop
    | absent {scan} : scan.state.position ≠ 0 →
        fixedAfter text scan.state.position "elsif" true = 0 →
        fixedAfter text scan.state.position "else" true = 0 →
        fixedAfter text scan.state.position "end" true ≠ 0 →
        AlternativeAt text scan .absent scan
    | otherwise {scan start items next} :
        alternativeAt text scan = next →
        fixedAfter text scan.state.position "elsif" true = 0 →
        fixedAfter text scan.state.position "else" true ≠ 0 →
        start = scanToken text scan (.word "else") →
        TokensAt text .direct [.word "else"] scan.state [] start.state →
        BodyAt text start (.token (.word "end")) items next →
        AlternativeAt text scan (.otherwise items) next
    | elsif {scan comparison yesEnd next left right yes otherwise} :
        alternativeAt text scan = next →
        fixedAfter text scan.state.position "elsif" true ≠ 0 →
        comparison = scanTokens text .direct elsifTokens scan →
        TokensAt text .direct elsifTokens scan.state [.comparison left right] comparison.state →
        BodyAt text comparison .arm yes yesEnd →
        AlternativeAt text yesEnd otherwise next →
        AlternativeAt text scan (.elsif left right yes otherwise) next

  inductive BodyAt (text : Source) : ScanResult → BodyStop → List Statement → ScanResult → Prop
    | cons {scan stop item following rest final} :
        readBody text scan stop = final →
        StatementAt text scan item following →
        TailBodyAt text following stop rest final →
        BodyAt text scan stop (item :: rest) final

  inductive TailBodyAt (text : Source) : ScanResult → BodyStop → List Statement → ScanResult → Prop
    | done {scan stop} : scan.state.position ≠ 0 →
        stopAfter text scan.state.position stop ≠ 0 → TailBodyAt text scan stop [] scan
    | next {scan stop item following rest final} :
        bodyTail text scan stop = final →
        scan.state.position ≠ 0 → stopAfter text scan.state.position stop = 0 →
        StatementAt text scan item following →
        TailBodyAt text following stop rest final →
        TailBodyAt text scan stop (item :: rest) final
end

abbrev StatementsAt (text : Source) (scan : ScanResult) (stop : ShellToken)
    (items : List Statement) (final : ScanResult) : Prop :=
  BodyAt text scan (.token stop) items final

theorem conditional_complete {text scan item next}
    (parsed : ConditionalAt text scan item next) : conditionalAt text scan = next := by
  cases parsed with | choice scanned => exact scanned

theorem statement_complete {text scan item next}
    (parsed : StatementAt text scan item next) : statementAt text scan = next := by
  cases parsed with
  | simple absent basic => simp only [statementAt, absent, ne_eq, not_true_eq_false, ↓reduceIte, basic_scanned basic]
  | conditional present choice => rw [statementAt, ite_eq_left present]; exact conditional_complete choice

theorem alternative_complete {text scan item next}
    (parsed : AlternativeAt text scan item next) : alternativeAt text scan = next := by
  cases parsed with
  | absent positive noElsif noElse atEnd => rw [alternativeAt]; simp [positive, noElsif, noElse, atEnd]
  | otherwise scanned => exact scanned
  | elsif scanned => exact scanned

theorem body_complete {text scan stop items next}
    (parsed : BodyAt text scan stop items next) : readBody text scan stop = next := by
  cases parsed with | cons scanned => exact scanned

theorem tailBody_complete {text scan stop items next}
    (parsed : TailBodyAt text scan stop items next) : bodyTail text scan stop = next := by
  cases parsed with
  | done positive stopped => rw [bodyTail]; simp [positive, stopped]
  | next scanned => exact scanned

theorem statements_complete {text scan stop items next}
    (parsed : StatementsAt text scan stop items next) : readStatements text scan stop = next :=
  body_complete parsed

theorem body_items {text scan stop items next} (parsed : BodyAt text scan stop items next) : items ≠ [] := by
  cases parsed
  simp

theorem conditional_positive {text scan item next}
    (parsed : ConditionalAt text scan item next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  cases parsed with
  | choice _ comparison _ _ _ ending => exact ⟨(tokens_positive comparison).1, (tokens_positive ending).2⟩

theorem statement_positive {text scan item next}
    (parsed : StatementAt text scan item next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  cases parsed with
  | simple _ basic => exact basic_positive basic
  | conditional _ choice => exact conditional_positive choice

theorem tailBody_positive {text scan stop items next}
    (parsed : TailBodyAt text scan stop items next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  induction items generalizing scan next with
  | nil => cases parsed with | done positive _ => exact ⟨positive, positive⟩
  | cons item rest ih =>
      cases parsed with
      | next _ positive _ _ following => exact ⟨positive, (ih following).2⟩

theorem body_positive {text scan stop items next}
    (parsed : BodyAt text scan stop items next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  cases parsed with
  | cons _ first following => exact ⟨(statement_positive first).1, (tailBody_positive following).2⟩

theorem alternative_positive {text scan item next}
    (parsed : AlternativeAt text scan item next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 := by
  generalize count : sizeOf item = n
  induction n using Nat.strongRecOn generalizing scan item next with
  | ind n ih =>
      cases parsed with
      | absent positive => exact ⟨positive, positive⟩
      | otherwise _ _ _ _ token items => exact ⟨(tokens_positive token).1, (body_positive items).2⟩
      | elsif _ _ _ token _ rest =>
          refine ⟨(tokens_positive token).1, ?_⟩
          exact (ih _ (by simp_all; omega) rest rfl).2

theorem statements_positive {text scan stop items next}
    (parsed : StatementsAt text scan stop items next) : scan.state.position ≠ 0 ∧ next.state.position ≠ 0 :=
  body_positive parsed

theorem bodyTail_input_positive {text scan stop}
    (accepted : (bodyTail text scan stop).state.position ≠ 0) : scan.state.position ≠ 0 := by
  intro zero
  rw [bodyTail] at accepted
  simp [zero, invalidScan, invalidState] at accepted

theorem statement_input_positive {text scan}
    (accepted : (statementAt text scan).state.position ≠ 0) : scan.state.position ≠ 0 := by
  rw [statementAt] at accepted
  split at accepted
  · rw [conditionalAt] at accepted
    intro zero
    simp [zero, invalidScan, invalidState] at accepted
  · unfold basicStatementAt at accepted
    intro zero
    simp [zero, invalidScan, invalidState] at accepted

theorem readBody_input_positive {text scan stop}
    (accepted : (readBody text scan stop).state.position ≠ 0) : scan.state.position ≠ 0 := by
  apply statement_input_positive (text := text)
  rw [readBody] at accepted
  try dsimp only at accepted
  split at accepted <;> simp_all [invalidScan, invalidState]

theorem alternative_input_positive {text scan}
    (accepted : (alternativeAt text scan).state.position ≠ 0) : scan.state.position ≠ 0 := by
  intro zero
  rw [alternativeAt] at accepted
  simp [zero, invalidScan, invalidState] at accepted

theorem comparison_sound (text : Source) (scan : ScanResult) (tokens : List ShellToken)
    (shape : tokens.filterMap ShellToken.eventKind = [.comparison])
    (accepted : (scanTokens text .direct tokens scan).state.position ≠ 0) :
    ∃ left right, TokensAt text .direct tokens scan.state [.comparison left right]
      (scanTokens text .direct tokens scan).state := by
  obtain ⟨events, parsed⟩ := tokens_sound text .direct tokens scan accepted
  have kinds : events.map Event.kind = [.comparison] := (tokens_kinds parsed).trans shape
  obtain ⟨left, right, rest, rfl, empty⟩ := (comparison_event_shape events []).mp kinds
  have noRest : rest = [] := List.map_eq_nil_iff.mp empty
  subst rest
  exact ⟨left, right, parsed⟩

theorem silent_tokens_sound (text : Source) (scan : ScanResult) (tokens : List ShellToken)
    (shape : tokens.filterMap ShellToken.eventKind = [])
    (accepted : (scanTokens text .direct tokens scan).state.position ≠ 0) :
    TokensAt text .direct tokens scan.state [] (scanTokens text .direct tokens scan).state := by
  obtain ⟨events, parsed⟩ := tokens_sound text .direct tokens scan accepted
  have empty : events = [] := List.map_eq_nil_iff.mp ((tokens_kinds parsed).trans shape)
  subst events
  exact parsed


theorem conditional_success {text scan}
    (accepted : (conditionalAt text scan).state.position ≠ 0) :
    scan.state.position ≠ 0 ∧
    remaining text (scanTokens text .direct equalityTokens scan) < remaining text scan ∧
    remaining text (readBody text (scanTokens text .direct equalityTokens scan) .arm) < remaining text scan ∧
    conditionalAt text scan = scanTokens text .direct endIfTokens
      (alternativeAt text (readBody text (scanTokens text .direct equalityTokens scan) .arm)) := by
  have reduced := accepted
  rw [conditionalAt] at reduced
  try dsimp only at reduced
  repeat' split at reduced <;> simp_all [invalidScan, invalidState]
  rw [conditionalAt]
  simp_all
  omega

mutual
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
  termination_by (remaining text scan, 2)

  theorem conditional_sound (text : Source) (scan : ScanResult)
      (accepted : (conditionalAt text scan).state.position ≠ 0) :
      ∃ item, ConditionalAt text scan item (conditionalAt text scan) := by
    obtain ⟨positive, advance, yesAdvance, same⟩ := conditional_success accepted
    have endPositive := accepted
    rw [same] at endPositive
    have altPositive := fun zero => endPositive
      (scanTokens_zero text .direct endIfTokens _ zero)
    have yesPositive := alternative_input_positive altPositive
    have comparisonPositive := readBody_input_positive yesPositive
    obtain ⟨left, right, comparison⟩ := comparison_sound text scan equalityTokens
      (by rfl) comparisonPositive
    obtain ⟨yes, yesParsed⟩ := body_sound text _ .arm yesPositive
    obtain ⟨otherwise, alternative⟩ := alternative_sound text _ altPositive
    have ending := silent_tokens_sound text _ endIfTokens (by rfl) endPositive
    refine ⟨.choice left right yes otherwise, .choice rfl comparison rfl yesParsed alternative ?_⟩
    simpa only [same] using ending
  termination_by (remaining text scan, 1)

  theorem alternative_sound (text : Source) (scan : ScanResult)
      (accepted : (alternativeAt text scan).state.position ≠ 0) :
      ∃ item, AlternativeAt text scan item (alternativeAt text scan) := by
    have positive := alternative_input_positive accepted
    by_cases isElsif : fixedAfter text scan.state.position "elsif" true ≠ 0
    · have reduced := accepted
      rw [alternativeAt, ite_eq_right positive, ite_eq_left isElsif] at reduced
      try dsimp only at reduced
      split at reduced <;> rename_i advance
      · split at reduced <;> rename_i yesAdvance
        · have same : alternativeAt text scan = alternativeAt text
              (readBody text (scanTokens text .direct elsifTokens scan) .arm) := by
            rw [alternativeAt]
            simp [positive, isElsif, advance, yesAdvance]
          have yesPositive := alternative_input_positive reduced
          have comparisonPositive := readBody_input_positive yesPositive
          obtain ⟨left, right, comparison⟩ := comparison_sound text scan elsifTokens (by rfl) comparisonPositive
          obtain ⟨yes, yesParsed⟩ := body_sound text _ .arm yesPositive
          obtain ⟨otherwise, rest⟩ := alternative_sound text _ reduced
          refine ⟨.elsif left right yes otherwise, .elsif rfl isElsif rfl comparison yesParsed ?_⟩
          simpa only [same] using rest
        · simp [invalidScan, invalidState] at reduced
      · simp [invalidScan, invalidState] at reduced
    · have noElsif : fixedAfter text scan.state.position "elsif" true = 0 := by simpa using isElsif
      by_cases isElse : fixedAfter text scan.state.position "else" true ≠ 0
      · have reduced := accepted
        rw [alternativeAt, ite_eq_right positive, ite_eq_right isElsif, ite_eq_left isElse] at reduced
        try dsimp only at reduced
        split at reduced <;> rename_i advance
        · have same : alternativeAt text scan = readBody text (scanToken text scan (.word "else"))
              (.token (.word "end")) := by
            rw [alternativeAt]
            simp [positive, isElsif, isElse, advance]
          have nextPositive := readBody_input_positive reduced
          have token := silent_tokens_sound text scan [.word "else"] (by rfl) nextPositive
          obtain ⟨items, body⟩ := body_sound text _ (.token (.word "end")) reduced
          refine ⟨.otherwise items, .otherwise rfl noElsif isElse rfl token ?_⟩
          simpa only [same] using body
        · simp [invalidScan, invalidState] at reduced
      · have noElse : fixedAfter text scan.state.position "else" true = 0 := by simpa using isElse
        have reduced := accepted
        rw [alternativeAt, ite_eq_right positive, ite_eq_right isElsif, ite_eq_right isElse] at reduced
        split at reduced <;> rename_i atEnd
        · have same : alternativeAt text scan = scan := by
            rw [alternativeAt]; simp [positive, isElsif, isElse, atEnd]
          rw [same]
          exact ⟨.absent, .absent positive noElsif noElse atEnd⟩
        · simp [invalidScan, invalidState] at reduced
  termination_by (remaining text scan, 1)

  theorem body_sound (text : Source) (scan : ScanResult) (stop : BodyStop)
      (accepted : (readBody text scan stop).state.position ≠ 0) :
      ∃ items, BodyAt text scan stop items (readBody text scan stop) := by
    have reduced := accepted
    rw [readBody] at reduced
    try dsimp only at reduced
    split at reduced <;> rename_i positive
    · simp [invalidScan, invalidState] at reduced
    · split at reduced <;> rename_i advance
      · have same : readBody text scan stop = bodyTail text (statementAt text scan) stop := by
          rw [readBody]; simp [positive, advance]
        obtain ⟨item, first⟩ := statement_sound text scan positive
        obtain ⟨rest, following⟩ := tailBody_sound text _ stop reduced
        refine ⟨item :: rest, .cons rfl first ?_⟩
        simpa only [same] using following
      · simp [invalidScan, invalidState] at reduced
  termination_by (remaining text scan, 3)

  theorem tailBody_sound (text : Source) (scan : ScanResult) (stop : BodyStop)
      (accepted : (bodyTail text scan stop).state.position ≠ 0) :
      ∃ items, TailBodyAt text scan stop items (bodyTail text scan stop) := by
    have positive := bodyTail_input_positive accepted
    by_cases stopped : stopAfter text scan.state.position stop ≠ 0
    · have same : bodyTail text scan stop = scan := by rw [bodyTail]; simp [positive, stopped]
      rw [same]
      exact ⟨[], .done positive stopped⟩
    · have notStopped : stopAfter text scan.state.position stop = 0 := by simpa using stopped
      have reduced := accepted
      rw [bodyTail, ite_eq_right positive, ite_eq_right stopped] at reduced
      try dsimp only at reduced
      split at reduced <;> rename_i nextPositive
      · simp [invalidScan, invalidState] at reduced
      · split at reduced <;> rename_i advance
        · have same : bodyTail text scan stop = bodyTail text (statementAt text scan) stop := by
            rw [bodyTail]; simp [positive, stopped, nextPositive, advance]
          obtain ⟨item, first⟩ := statement_sound text scan nextPositive
          obtain ⟨rest, following⟩ := tailBody_sound text _ stop reduced
          refine ⟨item :: rest, .next rfl positive notStopped first ?_⟩
          simpa only [same] using following
        · simp [invalidScan, invalidState] at reduced
  termination_by (remaining text scan, 3)
end

theorem statements_sound (text : Source) (scan : ScanResult) (stop : ShellToken)
    (accepted : (readStatements text scan stop).state.position ≠ 0) :
    ∃ items, StatementsAt text scan stop items (readStatements text scan stop) :=
  body_sound text scan (.token stop) accepted

theorem statements_input_positive {text scan stop}
    (accepted : (readStatements text scan stop).state.position ≠ 0) : scan.state.position ≠ 0 :=
  readBody_input_positive accepted

end Silver.Sequence
