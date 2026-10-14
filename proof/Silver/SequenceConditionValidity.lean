module

public import Silver.SequenceConditions

@[expose] public section

/-! Recursive readings have one payload tree and preserve initialized fixed
binding shapes through every explicit arm and omitted alternative. -/

namespace Silver.Sequence
open Compose Bindings

mutual
  theorem statement_unique {text scan left right first second}
      (a : StatementAt text scan left first) (b : StatementAt text scan right second) :
      left = right ∧ first = second := by
    cases a with
    | simple absent one =>
        cases b with
        | simple _ two =>
            have same := basic_unique one two
            exact ⟨congrArg Statement.simple same.1, same.2⟩
        | conditional present => exact False.elim (present absent)
    | conditional present one =>
        cases b with
        | simple absent => exact False.elim (present absent)
        | conditional _ two => exact conditional_unique one two
  termination_by (sizeOf left, 1)

  theorem conditional_unique {text scan left right first second}
      (a : ConditionalAt text scan left first) (b : ConditionalAt text scan right second) :
      left = right ∧ first = second := by
    cases a with
    | choice scanned comparison compSame yes tail ending =>
        cases b with
        | choice other otherComparison otherCompSame otherYes otherTail otherEnding =>
            have scans := otherCompSame.trans compSame.symm
            cases scans
            have names := (tokens_unique comparison otherComparison).1
            simp only [List.cons.injEq, Event.comparison.injEq, and_true] at names
            obtain ⟨rfl, rfl⟩ := names
            obtain ⟨rfl, rfl⟩ := body_unique yes otherYes
            obtain ⟨rfl, _⟩ := alternative_unique tail otherTail
            exact ⟨rfl, scanned.symm.trans other⟩
  termination_by (sizeOf left, 0)

  theorem alternative_unique {text scan left right first second}
      (a : AlternativeAt text scan left first) (b : AlternativeAt text scan right second) :
      left = right ∧ first = second := by
    cases a with
    | absent _ noElsif noElse _ =>
        cases b with
        | absent => exact ⟨rfl, rfl⟩
        | otherwise _ _ hasElse => exact False.elim (hasElse noElse)
        | elsif _ hasElsif => exact False.elim (hasElsif noElsif)
    | otherwise scanned noElsif hasElse startSame token items =>
        cases b with
        | absent _ _ noElse => exact False.elim (hasElse noElse)
        | elsif _ hasElsif => exact False.elim (hasElsif noElsif)
        | otherwise other _ _ otherStart _ otherItems =>
            have starts := otherStart.trans startSame.symm
            cases starts
            obtain ⟨rfl, _⟩ := body_unique items otherItems
            exact ⟨rfl, scanned.symm.trans other⟩
    | elsif scanned hasElsif compSame comparison yes tail =>
        cases b with
        | absent _ noElsif => exact False.elim (hasElsif noElsif)
        | otherwise _ noElsif => exact False.elim (hasElsif noElsif)
        | elsif other _ otherCompSame otherComparison otherYes otherTail =>
            have scans := otherCompSame.trans compSame.symm
            cases scans
            have names := (tokens_unique comparison otherComparison).1
            simp only [List.cons.injEq, Event.comparison.injEq, and_true] at names
            obtain ⟨rfl, rfl⟩ := names
            obtain ⟨rfl, rfl⟩ := body_unique yes otherYes
            obtain ⟨rfl, _⟩ := alternative_unique tail otherTail
            exact ⟨rfl, scanned.symm.trans other⟩
  termination_by (sizeOf left, 0)

  theorem body_unique {text scan stop left right first second}
      (a : BodyAt text scan stop left first) (b : BodyAt text scan stop right second) :
      left = right ∧ first = second := by
    cases a with
    | cons _ one following =>
        cases b with
        | cons _ two other =>
            obtain ⟨rfl, rfl⟩ := statement_unique one two
            obtain ⟨rfl, rfl⟩ := tailBody_unique following other
            exact ⟨rfl, rfl⟩
  termination_by (sizeOf left, 0)

  theorem tailBody_unique {text scan stop left right first second}
      (a : TailBodyAt text scan stop left first) (b : TailBodyAt text scan stop right second) :
      left = right ∧ first = second := by
    cases a with
    | done _ stopped =>
        cases b with
        | done => exact ⟨rfl, rfl⟩
        | next _ _ notStopped => exact False.elim (stopped notStopped)
    | next _ _ notStopped one following =>
        cases b with
        | done _ stopped => exact False.elim (stopped notStopped)
        | next _ _ _ two other =>
            obtain ⟨rfl, rfl⟩ := statement_unique one two
            obtain ⟨rfl, rfl⟩ := tailBody_unique following other
            exact ⟨rfl, rfl⟩
  termination_by (sizeOf left, 0)
end

theorem statements_unique {text scan stop left right first second}
    (a : StatementsAt text scan stop left first) (b : StatementsAt text scan stop right second) :
    left = right ∧ first = second := body_unique a b

mutual
  theorem statement_valid {text scan item next}
      (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
      (parsed : StatementAt text scan item next) :
      StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
        next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
    cases parsed with
    | simple _ basic => simpa only [Statement.Valid] using basic_valid domain valid basic
    | conditional _ choice => exact conditional_valid domain valid choice
  termination_by (sizeOf item, 1)

  theorem conditional_valid {text scan item next}
      (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
      (parsed : ConditionalAt text scan item next) :
      StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
        next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
    cases parsed with
    | choice _ comparison _ yes tail ending =>
        obtain ⟨compValid, expressions⟩ := tokens_valid domain comparison valid
        have safe := expressions [] trivial
        simp only [List.append_nil, StreamValid] at safe
        have compShape := tokens_shape (by simp [equalityTokens, ShapeToken, ShellToken.word]) comparison
        have yesValid := body_valid domain compValid yes
        have yesNames := yesValid.2.2.1.trans compShape.1
        have yesCapacity := yesValid.2.2.2.trans compShape.2
        have tailValid := alternative_valid domain yesValid.1 tail
        have tailNames := tailValid.2.2.1.trans yesNames
        have tailCapacity := tailValid.2.2.2.trans yesCapacity
        have endValid := (tokens_valid domain ending tailValid.1).1
        have endShape := tokens_shape (by simp [endIfTokens, ShapeToken, ShellToken.word, ShellToken.symbol]) ending
        refine ⟨endValid, ?_, endShape.1.trans tailNames, endShape.2.trans tailCapacity⟩
        simp only [Statement.Valid]
        exact ⟨safe.1, safe.2.1, body_items yes,
          by simpa only [compShape.1, compShape.2] using yesValid.2.1,
          by simpa only [yesNames, yesCapacity] using tailValid.2.1⟩
  termination_by (sizeOf item, 0)

  theorem alternative_valid {text scan item next}
      (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
      (parsed : AlternativeAt text scan item next) :
      StateValid next.state ∧ item.Valid scan.state.names.shape scan.state.capacity ∧
        next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
    cases parsed with
    | absent => exact ⟨valid, by simp only [Alternative.Valid], rfl, rfl⟩
    | otherwise _ _ _ _ token items =>
        have startValid := (tokens_valid domain token valid).1
        have shape := tokens_shape (by simp [ShapeToken, ShellToken.word]) token
        have result := body_valid domain startValid items
        refine ⟨result.1, ?_, result.2.2.1.trans shape.1, result.2.2.2.trans shape.2⟩
        simp only [Alternative.Valid]
        exact ⟨body_items items, by simpa only [shape.1, shape.2] using result.2.1⟩
    | elsif _ _ _ comparison yes tail =>
        obtain ⟨compValid, expressions⟩ := tokens_valid domain comparison valid
        have safe := expressions [] trivial
        simp only [List.append_nil, StreamValid] at safe
        have compShape := tokens_shape (by simp [elsifTokens, ShapeToken, ShellToken.word]) comparison
        have yesValid := body_valid domain compValid yes
        have yesNames := yesValid.2.2.1.trans compShape.1
        have yesCapacity := yesValid.2.2.2.trans compShape.2
        have tailValid := alternative_valid domain yesValid.1 tail
        refine ⟨tailValid.1, ?_, tailValid.2.2.1.trans yesNames, tailValid.2.2.2.trans yesCapacity⟩
        simp only [Alternative.Valid]
        exact ⟨safe.1, safe.2.1, body_items yes,
          by simpa only [compShape.1, compShape.2] using yesValid.2.1,
          by simpa only [yesNames, yesCapacity] using tailValid.2.1⟩
  termination_by (sizeOf item, 0)

  theorem body_valid {text scan stop items next}
      (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
      (parsed : BodyAt text scan stop items next) :
      StateValid next.state ∧ StatementsValid scan.state.names.shape scan.state.capacity items ∧
        next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
    cases parsed with
    | cons _ first following =>
        have headValid := statement_valid domain valid first
        have restValid := tailBody_valid domain headValid.1 following
        refine ⟨restValid.1, ?_, restValid.2.2.1.trans headValid.2.2.1,
          restValid.2.2.2.trans headValid.2.2.2⟩
        simp only [StatementsValid]
        exact ⟨headValid.2.1, by simpa only [headValid.2.2.1, headValid.2.2.2] using restValid.2.1⟩
  termination_by (sizeOf items, 0)

  theorem tailBody_valid {text scan stop items next}
      (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
      (parsed : TailBodyAt text scan stop items next) :
      StateValid next.state ∧ StatementsValid scan.state.names.shape scan.state.capacity items ∧
        next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity := by
    cases parsed with
    | done => exact ⟨valid, by simp only [StatementsValid], rfl, rfl⟩
    | next _ _ _ first following =>
        have headValid := statement_valid domain valid first
        have restValid := tailBody_valid domain headValid.1 following
        refine ⟨restValid.1, ?_, restValid.2.2.1.trans headValid.2.2.1,
          restValid.2.2.2.trans headValid.2.2.2⟩
        simp only [StatementsValid]
        exact ⟨headValid.2.1, by simpa only [headValid.2.2.1, headValid.2.2.2] using restValid.2.1⟩
  termination_by (sizeOf items, 0)
end

theorem statements_valid {text scan stop items next}
    (domain : text.length ≤ maxSourceLength) (valid : StateValid scan.state)
    (parsed : StatementsAt text scan stop items next) :
    StateValid next.state ∧ StatementsValid scan.state.names.shape scan.state.capacity items ∧
      next.state.names = scan.state.names ∧ next.state.capacity = scan.state.capacity :=
  body_valid domain valid parsed

end Silver.Sequence
