module

public import Silver.SequenceConditions

@[expose] public section

/-! Ordinary body tokens preserve the immutable declaration context. The
native recursive scanner shares that context rather than copying its storage
in every conditional frame. -/

namespace Silver.Sequence
open Compose Bindings

def SameContext (left right : ParserState) : Prop :=
  left.names = right.names ∧ left.dynamicFirst = right.dynamicFirst ∧
    left.dynamicAfter = right.dynamicAfter ∧ left.capacity = right.capacity ∧
    left.scalarNames = right.scalarNames ∧ left.arrayNames = right.arrayNames ∧
    left.subtypeNames = right.subtypeNames ∧ left.booleanNames = right.booleanNames ∧
    left.functions = right.functions ∧ left.pure = right.pure ∧
    left.assignedInFunctions = right.assignedInFunctions ∧ left.hiding = right.hiding ∧
    left.firstParameter = right.firstParameter ∧ left.procedures = right.procedures ∧
    left.firstProcedureParameter = right.firstProcedureParameter ∧
    left.contextFirst = right.contextFirst ∧ left.packageFirst = right.packageFirst ∧
    left.packageAfter = right.packageAfter

theorem SameContext.trans {left middle right : ParserState}
    (first : SameContext left middle) (second : SameContext middle right) : SameContext left right := by
  rcases first with ⟨a, b, c, d, e, f, g, h, i, j, k, l, m, procedures, procedureFirst, context, packageFirst, packageAfter⟩
  rcases second with ⟨n, o, p, q, r, s, t, u, v, w, x, y, z, nextProcedures, nextProcedureFirst, nextContext, nextPackageFirst, nextPackageAfter⟩
  exact ⟨a.trans n, b.trans o, c.trans p, d.trans q, e.trans r, f.trans s,
    g.trans t, h.trans u, i.trans v, j.trans w, k.trans x, l.trans y, m.trans z,
    procedures.trans nextProcedures, procedureFirst.trans nextProcedureFirst,
    context.trans nextContext, packageFirst.trans nextPackageFirst, packageAfter.trans nextPackageAfter⟩

theorem step_body_context {text form token state}
    (ordinary : ShapeToken token)
    (accepted : (step text form token state).position ≠ 0) :
    SameContext (step text form token state) state := by
  have positive : state.position ≠ 0 := fun zero => accepted (step_zero text form token state zero)
  cases token <;> simp only [ShapeToken] at ordinary
  all_goals try contradiction
  all_goals simp only [step, positive, ↓reduceIte, SameContext] at accepted ⊢
  all_goals first
    | trivial
    | exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
    | (try simp only [targetAt, dynamicAt, assignmentAt, outputAt, comparisonAt] at accepted ⊢
       repeat' split <;> simp_all [invalidState])

theorem scanTokens_context {text form tokens scan}
    (ordinary : ∀ token ∈ tokens, ShapeToken token)
    (accepted : (scanTokens text form tokens scan).state.position ≠ 0) :
    SameContext (scanTokens text form tokens scan).state scan.state := by
  induction tokens generalizing scan with
  | nil => exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
  | cons token tokens ih =>
      have nextPositive : (step text form token scan.state).position ≠ 0 := fun zero =>
        accepted (scanTokens_zero text form tokens {scan with state := step text form token scan.state} zero)
      have first := step_body_context (ordinary _ (by simp)) nextPositive
      have rest := ih (fun t member => ordinary t (by simp [member])) accepted
      exact rest.trans first

theorem basic_context {text scan}
    (accepted : (basicStatementAt text scan).state.position ≠ 0) :
    SameContext (basicStatementAt text scan).state scan.state := by
  have same := basic_reduction accepted
  rw [same] at accepted ⊢
  exact scanTokens_context (basic_shape_tokens _) accepted

mutual
  theorem statement_context {text scan}
      (accepted : (statementAt text scan).state.position ≠ 0) :
      SameContext (statementAt text scan).state scan.state := by
    by_cases choice : fixedAfter text scan.state.position "if" true ≠ 0
    · rw [statementAt, ite_eq_left choice] at accepted ⊢
      exact conditional_context accepted
    · rw [statementAt, ite_eq_right choice] at accepted ⊢
      exact basic_context accepted
  termination_by (remaining text scan, 2)

  theorem conditional_context {text scan}
      (accepted : (conditionalAt text scan).state.position ≠ 0) :
      SameContext (conditionalAt text scan).state scan.state := by
    obtain ⟨positive, advance, yesAdvance, same⟩ := conditional_success accepted
    have endPositive := accepted
    rw [same] at endPositive ⊢
    have altPositive := fun zero => endPositive (scanTokens_zero text .direct endIfTokens _ zero)
    have yesPositive := alternative_input_positive altPositive
    have compPositive := readBody_input_positive yesPositive
    have head := scanTokens_context (by simp [equalityTokens, ShapeToken, ShellToken.word]) compPositive
    have yes := body_context yesPositive
    have rest := alternative_context altPositive
    have ending := scanTokens_context (by simp [endIfTokens, ShapeToken, ShellToken.word, ShellToken.symbol]) endPositive
    exact ending.trans (rest.trans (yes.trans head))
  termination_by (remaining text scan, 1)

  theorem alternative_context {text scan}
      (accepted : (alternativeAt text scan).state.position ≠ 0) :
      SameContext (alternativeAt text scan).state scan.state := by
    have positive := alternative_input_positive accepted
    by_cases isElsif : fixedAfter text scan.state.position "elsif" true ≠ 0
    · rw [alternativeAt, ite_eq_right positive, ite_eq_left isElsif] at accepted ⊢
      dsimp only at accepted ⊢
      split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
      · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
        · have yesPositive := alternative_input_positive accepted
          have compPositive := readBody_input_positive yesPositive
          have head := scanTokens_context (by simp [elsifTokens, ShapeToken, ShellToken.word]) compPositive
          have yes := body_context yesPositive
          have rest := alternative_context accepted
          exact rest.trans (yes.trans head)
        · simp [invalidScan, invalidState] at accepted
      · simp [invalidScan, invalidState] at accepted
    · by_cases isElse : fixedAfter text scan.state.position "else" true ≠ 0
      · rw [alternativeAt, ite_eq_right positive, ite_eq_right isElsif, ite_eq_left isElse] at accepted ⊢
        dsimp only at accepted ⊢
        split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
        · have head := step_body_context (form := .direct) (by trivial : ShapeToken (.word "else"))
            (readBody_input_positive accepted)
          exact (body_context accepted).trans head
        · simp [invalidScan, invalidState] at accepted
      · rw [alternativeAt, ite_eq_right positive, ite_eq_right isElsif, ite_eq_right isElse] at accepted ⊢
        split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
        · exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
        · simp [invalidScan, invalidState] at accepted
  termination_by (remaining text scan, 1)

  theorem body_context {text scan stop}
      (accepted : (readBody text scan stop).state.position ≠ 0) :
      SameContext (readBody text scan stop).state scan.state := by
    rw [readBody] at accepted ⊢
    split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
    · simp [invalidScan, invalidState] at accepted
    · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
      · have first := statement_context (bodyTail_input_positive accepted)
        exact (tailBody_context accepted).trans first
      · simp [invalidScan, invalidState] at accepted
  termination_by (remaining text scan, 3)

  theorem tailBody_context {text scan stop}
      (accepted : (bodyTail text scan stop).state.position ≠ 0) :
      SameContext (bodyTail text scan stop).state scan.state := by
    rw [bodyTail] at accepted ⊢
    dsimp only at accepted ⊢
    split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
    · simp [invalidScan, invalidState] at accepted
    · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
      · exact ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩
      · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
        · simp [invalidScan, invalidState] at accepted
        · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
          · have first := statement_context (bodyTail_input_positive accepted)
            exact (tailBody_context accepted).trans first
          · simp [invalidScan, invalidState] at accepted
  termination_by (remaining text scan, 3)
end

end Silver.Sequence
