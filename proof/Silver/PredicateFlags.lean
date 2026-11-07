module

public import Silver.PredicateGrammar

@[expose] public section

namespace Silver.Predicate
variable {catalog : FunctionBindings.Metadata}
open Compose Bindings PathFacts

attribute [local irreducible] ScalarExpression.read

inductive Flag | assignment | output
  deriving DecidableEq, Repr

def Flag.simple : Flag → Sequence.SimpleStatement → Bool
  | .assignment, .assign _ | .output, .output _ | .output, .put _ => true
  | _, _ => false

def Flag.observe (flag : Flag) (scan : BodyScan) : Bool :=
  match flag with | .assignment => scan.assigned | .output => scan.output

mutual
  def Flag.source (flag : Flag) : SourceStatement → Bool
    | .simple item => flag.simple item
    | .scalarAssign _ | .callAssign _ | .arrayAssign _ | .booleanAssign _ | .booleanArrayAssign _ =>
        flag == .assignment
    | .reject => false
    | .choice _ yes tail => flag.sources yes || flag.alternative tail
    | .forLoop _ _ _ _ body | .arrayLoop _ _ _ body => flag.sources body
  termination_by item => sizeOf item
  def Flag.alternative (flag : Flag) : SourceAlternative → Bool
    | .absent => false
    | .otherwise items => flag.sources items
    | .elsif _ yes tail => flag.sources yes || flag.alternative tail
  termination_by tail => sizeOf tail
  def Flag.sources (flag : Flag) : List SourceStatement → Bool
    | [] => false
    | item :: rest => flag.source item || flag.sources rest
  termination_by items => sizeOf items
end

theorem bodyToken_flags (text : Source) (scan : BodyScan) (token : ShellToken) (flag : Flag) :
    flag.observe (bodyToken text scan token) = flag.observe scan := by cases flag <;> rfl

theorem bodyTokens_flags (text : Source) (scan : BodyScan) (tokens : List ShellToken) (flag : Flag) :
    flag.observe (bodyTokens text scan tokens) = flag.observe scan := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih => rw [bodyTokens, List.foldl_cons]; exact (ih _).trans (bodyToken_flags _ _ _ _)

theorem basic_flags {text context scan item result} (parsed : BasicAt (catalog := catalog) text context scan item result) (flag : Flag) :
    flag.observe result = (flag.observe scan || flag.source item) := by
  have success : (basicBody (catalog := catalog) text context scan).position ≠ 0 := parsed.equation ▸ parsed.positive
  have raw := basic_raw_positive (catalog := catalog) success
  have resultEq := (basic_after_raw (catalog := catalog) success).symm.trans parsed.equation
  cases parsed.payload with
  | null kind =>
      rw [← resultEq]
      simp only [bodyToken_flags, basicRaw, kind, bodyToken_flags, Flag.source, Flag.simple, Bool.or_false]
  | reject kind =>
      rw [← resultEq]
      simp only [bodyToken_flags, basicRaw, kind, Flag.source, Bool.or_false]
      cases flag <;> simp only [Flag.observe]
  | output kind expression =>
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag with
        | assignment =>
            simp only [Flag.observe, bodyToken_assigned, Flag.simple, Bool.or_false]
        | output => simp only [Flag.observe, Flag.simple, Bool.or_true]
  | put kind expression =>
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag with
        | assignment =>
            simp only [Flag.observe, bodyToken_assigned, Flag.simple, Bool.or_false]
        | output => simp only [Flag.observe, Flag.simple, Bool.or_true]
  | scalarCallAssignment kind source | booleanCallAssignment kind source =>
      have called := source.positive
      have assigned : (callAssignmentBody text context scan catalog).assigned = true ∧
          (callAssignmentBody text context scan catalog).output = scan.output := by
        unfold callAssignmentBody callAssignmentResult at called ⊢
        split at called
        · exact False.elim (called rfl)
        · rename_i advances
          rw [ite_eq_right advances]
          split at called
          · rename_i scalar
            rw [ite_eq_left scalar]
            dsimp only at called ⊢
            split at called
            · exact False.elim (called rfl)
            · rename_i permitted
              rw [ite_eq_right permitted]
              exact ⟨rfl, rfl⟩
          · rename_i scalar
            rw [ite_eq_right scalar]
            split at called
            · rename_i permitted
              rw [ite_eq_left permitted]
              exact ⟨rfl, rfl⟩
            · exact False.elim (called rfl)
      have selected : basicRaw text context scan catalog = callAssignmentBody text context scan catalog := by
        dsimp only [basicRaw]
        rw [kind]
        exact ite_eq_left source.positive
      rw [← resultEq, selected, bodyToken_flags]
      cases flag with
      | assignment => simp [Flag.observe, Flag.source, assigned.1]
      | output => simp [Flag.observe, Flag.source, assigned.2]
  | scalarAssignment kind noCall expression =>
      simp only [basicRaw, kind, noCall, ne_eq, not_true_eq_false, ↓reduceIte, scalarAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp [Flag.observe]
  | arrayAssignment kind indexed expression =>
      simp only [basicRaw, kind, arrayAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp [Flag.observe]
  | booleanAssignment kind noCall condition =>
      simp only [basicRaw, kind, noCall, ne_eq, not_true_eq_false, ↓reduceIte, booleanAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp [Flag.observe]
  | booleanArrayAssignment kind indexed condition =>
      simp only [basicRaw, kind, booleanArrayAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp [Flag.observe]
  | assignment kind reading =>
      have impure : context.pure = false := by
        by_cases pure : context.pure = true
        · simp [basicRaw, kind, pure, invalidBody] at raw
        · exact Bool.of_not_eq_true pure
      simp only [basicRaw, kind, impure, Bool.false_eq_true, ↓reduceIte] at raw resultEq
      have positive : (stringAssignmentBody text context scan).position ≠ 0 := by
        exact raw
      have fields := stringAssignment_success_fields positive
      rw [← resultEq]
      simp only [bodyToken_flags, Flag.source]
      cases flag <;> simp only [Flag.observe, fields.2.2.2.1, fields.2.2.2.2,
        Flag.simple, Bool.or_true, Bool.or_false]

mutual
  theorem statement_flags {text context scan item result}
      (parsed : StatementAt (catalog := catalog) text context scan item result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source item) := by
    cases parsed with
    | basic _ _ _ reading _ => exact basic_flags reading flag
    | choice _ _ reading _ => exact choice_flags reading flag
    | loop _ _ _ reading _ => exact loop_flags reading flag
    | arrayLoop _ _ _ reading _ => exact arrayLoop_flags reading flag
  termination_by (bodyRemaining text scan, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem loop_flags {text context scan lower upper body result}
      (parsed : LoopAt (catalog := catalog) text context scan lower upper body result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source
        (.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse lower upper body)) := by
    cases parsed with
    | loop _ _ _ _ _ bodyRead resultEq _ _ =>
        have observed := body_flags bodyRead flag
        rw [resultEq, bodyTokens_flags]
        cases flag <;> simpa only [Flag.observe, Flag.source, loopHeader] using observed
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem arrayLoop_flags {text context scan body result}
      (parsed : ArrayLoopAt (catalog := catalog) text context scan body result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source
        (.arrayLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse
          (ArrayBindings.binding context.arrayNames (loopArrayTarget text context scan)).descriptor body)) := by
    cases parsed with
    | loop _ _ _ _ bodyRead resultEq _ _ =>
        have observed := body_flags bodyRead flag
        rw [resultEq, bodyTokens_flags]
        cases flag <;> simpa only [Flag.observe, Flag.source, loopHeader] using observed
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem choice_flags {text context scan condition yes tail result}
      (parsed : ChoiceAt (catalog := catalog) text context scan condition yes tail result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source (.choice condition yes tail)) := by
    cases parsed with
    | choice _ _ yesRead _ noRead resultEq _ _ =>
        have first := body_flags yesRead flag
        have following := alternative_flags noRead flag
        rw [resultEq, bodyTokens_flags]
        cases flag <;>
          simp only [Flag.observe, branchStart_assigned, branchStart_output] at first following ⊢
        all_goals simpa only [Flag.source, ← Bool.or_assoc, ← first] using following
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem alternative_flags {text context scan tail result}
      (parsed : AlternativeAt (catalog := catalog) text context scan tail result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.alternative tail) := by
    cases parsed with
    | absent => simp only [Flag.alternative, Bool.or_false]
    | otherwise _ _ _ _ body _ =>
        have h := body_flags body flag
        simpa only [bodyToken_flags, Flag.alternative] using h
    | elsif _ _ _ _ yesRead _ noRead resultEq _ _ =>
        have first := body_flags yesRead flag
        have following := alternative_flags noRead flag
        rw [resultEq]
        cases flag <;>
          simp only [Flag.observe, branchStart_assigned, branchStart_output] at first following ⊢
        all_goals simpa only [Flag.alternative, ← Bool.or_assoc, ← first] using following
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem bodyTail_flags {text context stop scan items result}
      (parsed : BodyTailAt (catalog := catalog) text context stop scan items result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.sources items) := by
    cases parsed with
    | done => simp only [Flag.sources, Bool.or_false]
    | next _ _ item _ rest _ =>
        have first := statement_flags item flag
        have following := bodyTail_flags rest flag
        simpa only [Flag.sources, ← Bool.or_assoc, ← first] using following
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem body_flags {text context scan stop items result}
      (parsed : BodyAt (catalog := catalog) text context scan stop items result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.sources items) := by
    cases parsed with
    | cons item _ rest _ =>
        have first := statement_flags item flag
        have following := bodyTail_flags rest flag
        simpa only [Flag.sources, ← Bool.or_assoc, ← first] using following
  termination_by (bodyRemaining text scan, 3)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

def Flag.scanObserve (flag : Flag) (scan : ScanResult) : Bool :=
  match flag with | .assignment => scan.assigned | .output => scan.output

theorem scanTokens_output (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) : (scanTokens text form tokens scan).output = scan.output := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih => rw [scanTokens]; exact ih _

theorem step_functionAssignments_preserved {text form token state next event}
    (ordinary : token ≠ ShellToken.declarations) (parsed : StepAt text form token state next event) :
    next.assignedInFunctions = state.assignedInFunctions := by
  have following := parsed.following
  cases token with
  | declarations => exact False.elim (ordinary rfl)
  | argumentDeclaration =>
      obtain ⟨fallback, reading, _⟩ := parsed.payload
      cases reading
      rfl
  | contextClauses | fixed | literal =>
      rw [← parsed.scanned]
      simp only [step, parsed.positive, ↓reduceIte]
  | capacity | dynamicReference | assignmentTarget | targetReference | assignmentValue |
      outputExpression | comparisonExpression =>
      rw [← parsed.scanned] at following ⊢
      simp only [step, parsed.positive, ↓reduceIte, capacityAt, dynamicAt, targetAt,
        assignmentAt, outputAt, Compose.comparisonAt] at following ⊢
      split <;> (try split) <;> simp_all [invalidState]

theorem scanTokens_flags {text form tokens state events final}
    (ordinary : ∀ token ∈ tokens, token ≠ ShellToken.declarations)
    (parsed : Sequence.TokensAt text form tokens state events final)
    (assigned output : Bool) (absorbs : (assigned || state.assignedInFunctions) = assigned) (flag : Flag) :
    flag.scanObserve (scanTokens text form tokens ⟨state, assigned, output⟩) =
      flag.scanObserve ⟨state, assigned, output⟩ := by
  induction parsed generalizing assigned with
  | done => rfl
  | @next token tokens state middle final event events head _ ih =>
      have kept := step_functionAssignments_preserved (ordinary token (by simp)) head
      have next := ih (fun token member => ordinary token (by simp [member]))
        assigned (by simpa only [kept] using absorbs)
      cases flag <;> simpa only [scanTokens, head.scanned, kept, absorbs, Flag.scanObserve] using next

theorem prefix_output (text : Source) (form : Form) : (prefixScan text form).output = false :=
  scanTokens_output text form.helper form.prefix initialScan

/-- Native routing flags summarize the written statements, including untaken
arms. They therefore never depend on which runtime path happens to execute. -/
theorem form_flags {text : Source} {form : Form} {events : List Event} {items : List SourceStatement}
    (domain : SourceDomain text) (parsed : FormReading text form events items)
    (absorbs : ((prefixScan text form).assigned || (prefixScan text form).state.assignedInFunctions) =
      (prefixScan text form).assigned) (flag : Flag) :
    flag.scanObserve (formResult text form) = (flag.scanObserve (prefixScan text form) || flag.sources items) := by
  have member : FormMember text form := ⟨domain, events, items, parsed⟩
  have accepted := form_reading_complete member
  rw [(formResult_success accepted).2.2.2.2, finalScan]
  have bodyPositive : (bodyScan text form).state.position ≠ 0 := by
    obtain ⟨_, footer⟩ := parsed.footer
    exact (Sequence.tokens_positive footer).1
  have bodyEq : bodyScan text form = expandBody (prefixScan text form).state (rawBody text form) := by
    unfold bodyScan readStatements at bodyPositive ⊢
    dsimp only at bodyPositive ⊢
    split at bodyPositive
    · exact False.elim (bodyPositive rfl)
    · rename_i good
      exact ite_eq_right good
  obtain ⟨footerEvents, footer⟩ := parsed.footer
  have bodyAssigned := body_flags parsed.statements .assignment
  have bodyAbsorbs : ((bodyScan text form).assigned || (bodyScan text form).state.assignedInFunctions) =
      (bodyScan text form).assigned := by
    rw [bodyEq]
    change ((rawBody text form).assigned || (prefixScan text form).state.assignedInFunctions) =
      (rawBody text form).assigned
    change (rawBody text form).assigned = ((prefixScan text form).assigned || Flag.assignment.sources items) at bodyAssigned
    rw [bodyAssigned]
    rw [Bool.or_right_comm, absorbs]
  have finalFlags := scanTokens_flags (by cases form <;> simp [Form.footer, ShellToken.word, ShellToken.symbol])
    footer (bodyScan text form).assigned (bodyScan text form).output bodyAbsorbs flag
  rw [finalFlags, bodyEq]
  have observed := body_flags parsed.statements flag
  cases flag <;> simpa only [Flag.scanObserve, Flag.observe, bodyOf, expandBody] using observed

end Silver.Predicate
