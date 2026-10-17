module

public import Silver.PredicateGrammar

@[expose] public section

namespace Silver.Predicate
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
    | .scalarAssign _ => flag == .assignment
    | .reject => false
    | .choice _ yes tail => flag.sources yes || flag.alternative tail
    | .forLoop _ _ _ _ body => flag.sources body
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

theorem basic_flags {text context scan item result} (parsed : BasicAt text context scan item result) (flag : Flag) :
    flag.observe result = (flag.observe scan || flag.source item) := by
  have success : (basicBody text context scan).position ≠ 0 := parsed.equation ▸ parsed.positive
  have raw := basic_raw_positive success
  have resultEq := (basic_after_raw success).symm.trans parsed.equation
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
  | scalarAssignment kind expression =>
      simp only [basicRaw, kind, scalarAssignmentBody] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp [Flag.observe]
  | assignment kind target expression =>
      simp only [basicRaw, kind] at raw resultEq
      split at raw
      · exact False.elim (raw rfl)
      · rename_i good
        rw [ite_eq_right good] at resultEq
        rw [← resultEq]
        simp only [bodyToken_flags, Flag.source]
        cases flag <;> simp only [Flag.observe, bodyToken_output, Flag.simple, Bool.or_true, Bool.or_false]

mutual
  theorem statement_flags {text context scan item result}
      (parsed : StatementAt text context scan item result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source item) := by
    cases parsed with
    | basic _ _ _ reading _ => exact basic_flags reading flag
    | choice _ _ reading _ => exact choice_flags reading flag
    | loop _ _ _ reading _ => exact loop_flags reading flag
  termination_by (bodyRemaining text scan, 2)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem loop_flags {text context scan lower upper body result}
      (parsed : LoopAt text context scan lower upper body result) (flag : Flag) :
      flag.observe result = (flag.observe scan || flag.source
        (.forLoop (context.scalarNames.length + 1) (loopHeader text context scan).reverse lower upper body)) := by
    cases parsed with
    | loop _ _ _ _ bodyRead resultEq _ _ =>
        have observed := body_flags bodyRead flag
        rw [resultEq, bodyTokens_flags]
        cases flag <;> simpa only [Flag.observe, Flag.source, loopHeader] using observed
  termination_by (bodyRemaining text scan, 1)
  decreasing_by all_goals subst_vars; all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem choice_flags {text context scan condition yes tail result}
      (parsed : ChoiceAt text context scan condition yes tail result) (flag : Flag) :
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
      (parsed : AlternativeAt text context scan tail result) (flag : Flag) :
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
      (parsed : BodyTailAt text context stop scan items result) (flag : Flag) :
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
      (parsed : BodyAt text context scan stop items result) (flag : Flag) :
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

theorem scanTokens_flags (text : Source) (form : Compose.Form) (tokens : List ShellToken)
    (scan : ScanResult) (flag : Flag) :
    flag.scanObserve (scanTokens text form tokens scan) = flag.scanObserve scan := by
  induction tokens generalizing scan with
  | nil => rfl
  | cons token tokens ih =>
      rw [scanTokens, ih]
      cases flag <;> rfl

theorem prefix_flags (text : Source) (form : Form) (flag : Flag) :
    flag.scanObserve (prefixScan text form) = false := by
  rw [prefixScan, scanTokens_flags]
  cases flag <;> rfl

/-- Native routing flags summarize the written statements, including untaken
arms. They therefore never depend on which runtime path happens to execute. -/
theorem form_flags {text : Source} {form : Form} {events : List Event} {items : List SourceStatement}
    (domain : SourceDomain text) (parsed : FormReading text form events items) (flag : Flag) :
    flag.scanObserve (formResult text form) = flag.sources items := by
  have member : FormMember text form := ⟨domain, events, items, parsed⟩
  have accepted := form_reading_complete member
  rw [(formResult_success accepted).2.2.2.2, finalScan, scanTokens_flags]
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
  rw [bodyEq]
  have observed := body_flags parsed.statements flag
  have initial := prefix_flags text form flag
  cases flag <;>
    simp only [Flag.scanObserve, Flag.observe, bodyOf, expandBody] at initial observed ⊢
  all_goals simpa only [initial, Bool.false_or] using observed

end Silver.Predicate
