module

public import Silver.ProcedureNameNative

@[expose] public section

/-! The recursive lexical model keeps its step call and recursive call explicit.
Its native loop is related to this tree by the checked Static postcondition;
neither interface assumes the completed mathematical scanner meaning. -/
namespace Silver.Predicate.ProcedureNameNative
open Compose Expressions

abbrev Free := Source → Nat → Nat → Nat → Nat → Bool

structure FreeFrame where
  text : Source
  position : Nat
  after : Nat
  targetFirst : Nat
  targetAfter : Nat
  next : NameScanStep := ⟨0, false⟩

def FreeFrame.locals (frame : FreeFrame) : Locals :=
  stepLocals frame.text frame.position frame.after frame.targetFirst frame.targetAfter

inductive FreeExpr : Type → Type 1
  | scalar : Expr .number → FreeExpr Nat
  | boolean : Expr .truth → FreeExpr Bool
  | next : FreeExpr Nat
  | free : FreeExpr Bool
  | scan : FreeExpr Nat → FreeExpr NameScanStep
  | recur : FreeExpr Nat → FreeExpr Bool
  | ne : FreeExpr Nat → FreeExpr Nat → FreeExpr Bool
  | andThen : FreeExpr Bool → FreeExpr Bool → FreeExpr Bool
  | ite : FreeExpr Bool → FreeExpr Bool → FreeExpr Bool → FreeExpr Bool
  | elsif : FreeExpr Bool → FreeExpr Bool → FreeExpr Bool → FreeExpr Bool
  | group : FreeExpr Bool → FreeExpr Bool
  | withNext : FreeExpr NameScanStep → FreeExpr Bool → FreeExpr Bool

def FreeExpr.eval (calls : Expressions.Calls) (step : Step) (recursive : Free)
    (frame : FreeFrame) : FreeExpr α → α
  | .scalar value => value.eval calls frame.locals
  | .boolean value => value.eval calls frame.locals
  | .next => frame.next.next
  | .free => frame.next.free
  | .scan position => step frame.text (position.eval calls step recursive frame)
      frame.after frame.targetFirst frame.targetAfter
  | .recur position => recursive frame.text (position.eval calls step recursive frame)
      frame.after frame.targetFirst frame.targetAfter
  | .ne left right => decide (left.eval calls step recursive frame ≠ right.eval calls step recursive frame)
  | .andThen left right => left.eval calls step recursive frame && right.eval calls step recursive frame
  | .ite test yes no | .elsif test yes no =>
      if test.eval calls step recursive frame then yes.eval calls step recursive frame
      else no.eval calls step recursive frame
  | .group value => value.eval calls step recursive frame
  | .withNext value body => body.eval calls step recursive {frame with next := value.eval calls step recursive frame}

def FreeExpr.isElsif : FreeExpr α → Bool
  | .elsif _ _ _ => true
  | _ => false

def FreeExpr.render : FreeExpr α → List String
  | .scalar value => value.render
  | .boolean value => value.render
  | .next => ["next", ".", "next"]
  | .free => ["next", ".", "free"]
  | .scan position => ["actual_name_step", "(", "text", ","] ++ position.render ++
      [",", "after", ",", "target_first", ",", "target_after", ")"]
  | .recur position => ["actual_name_free_model", "(", "text", ","] ++ position.render ++
      [",", "after", ",", "target_first", ",", "target_after", ")"]
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .ite test yes no => ["if"] ++ test.render ++ ["then"] ++ yes.render ++
      (if no.isElsif then [] else ["else"]) ++ no.render
  | .elsif test yes no => ["elsif"] ++ test.render ++ ["then"] ++ yes.render ++
      (if no.isElsif then [] else ["else"]) ++ no.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .withNext value body => ["(", "declare", "next", ":", "constant", "name_scan_step", ":="] ++
      value.render ++ [";", "begin"] ++ body.render ++ [")"]

def FreeExpr.simple : FreeExpr α → Bool
  | .scalar value => value.simple
  | .boolean value => value.simple
  | .next | .free | .scan _ | .recur _ | .group _ | .withNext _ _ => true
  | _ => false

def FreeExpr.relation : FreeExpr α → Bool
  | .scalar value => value.relation
  | .boolean value => value.relation
  | .ne _ _ => true
  | value => value.simple

def FreeExpr.expression : FreeExpr α → Bool
  | .andThen _ _ => true
  | .scalar value => value.expression
  | .boolean value => value.expression
  | value => value.relation

def FreeExpr.andLeft : FreeExpr Bool → Bool
  | .andThen _ _ => true
  | value => value.relation

def FreeExpr.wellFormed : FreeExpr α → Bool
  | .scalar value => value.wellFormed && value.expression
  | .boolean value => value.wellFormed && value.expression
  | .next | .free => true
  | .scan position | .recur position => position.wellFormed && position.expression
  | .ne left right => left.wellFormed && left.simple && right.wellFormed && right.simple
  | .andThen left right => left.wellFormed && left.andLeft && right.wellFormed && right.relation
  | .ite test yes no | .elsif test yes no => test.wellFormed && test.expression &&
      yes.wellFormed && yes.expression && no.wellFormed && (no.isElsif || no.expression)
  | .group value => !value.isElsif && value.wellFormed
  | .withNext value body => value.wellFormed && body.wellFormed && body.expression

def freeCallScoped (scope : Scope) : Bool :=
  scope.contains "text" .source && scope.contains "after" .number &&
    scope.contains "target_first" .number && scope.contains "target_after" .number

def FreeExpr.scoped (scope : Scope) (nextBound : Bool) : FreeExpr α → Bool
  | .scalar value => value.scoped scope
  | .boolean value => value.scoped scope
  | .next | .free => nextBound
  | .scan position | .recur position => freeCallScoped scope && position.scoped scope nextBound
  | .ne left right => left.scoped scope nextBound && right.scoped scope nextBound
  | .andThen left right => left.scoped scope nextBound && right.scoped scope nextBound
  | .ite test yes no | .elsif test yes no => test.scoped scope nextBound &&
      yes.scoped scope nextBound && no.scoped scope nextBound
  | .group value => value.scoped scope nextBound
  | .withNext value body => !nextBound && !(scope.any fun item => item.1 == "next") &&
      value.scoped scope nextBound && body.scoped scope true

def freeBody : FreeExpr Bool :=
  let position : Expr .number := .variable "position"
  let after : Expr .number := .variable "after"
  .ite (.boolean (.orElse (.eq position (.number 0)) (.gt position after))) (.boolean (.truth false))
    (.elsif (.boolean (.eq position after)) (.boolean (.truth true))
      (.withNext (.scan (.scalar position))
        (.andThen (.andThen (.ne .next (.scalar (.number 0))) .free) (.recur .next))))

def FreeExpr.checked (scope : Scope) (value : FreeExpr Bool) : Bool :=
  !value.isElsif && value.wellFormed && value.scoped scope false

theorem freeBody_checked : freeBody.checked parameters = true := by
  decide +kernel

theorem unbound_next_rejected : (FreeExpr.recur .next).scoped parameters false = false := by
  decide +kernel

theorem nested_conjunction_rejected :
    (FreeExpr.andThen .free (.andThen .free .free)).render =
      (FreeExpr.andThen (.andThen .free .free) .free).render ∧
    (FreeExpr.andThen .free (.andThen .free .free)).wellFormed = false ∧
    (FreeExpr.andThen (.andThen .free .free) .free).wellFormed = true := by
  decide +kernel

theorem conditional_scalar_rejected :
    (FreeExpr.ne (.scalar (.ite (.truth true) (.number 1) (.number 0))) (.scalar (.number 0))).wellFormed = false := by
  decide +kernel

theorem dangling_elsif_rejected :
    (FreeExpr.elsif (.boolean (.truth true)) (.boolean (.truth true))
      (.boolean (.truth false))).checked parameters = false ∧
    (FreeExpr.group (.elsif (.boolean (.truth true)) (.boolean (.truth true))
      (.boolean (.truth false)))).wellFormed = false := by
  decide +kernel

structure FreeDefinitionEquations (calls : Expressions.Calls) (step : Step) (model scan : Free) : Prop where
  stepEquation : DefinitionEquation calls step
  modelEquation : ∀ text position after targetFirst targetAfter,
    StepDomain text position after targetFirst targetAfter →
      model text position after targetFirst targetAfter = freeBody.eval (lexical calls) step model
        {text, position, after, targetFirst, targetAfter}
  scanContract : ∀ text position after targetFirst targetAfter,
    StepDomain text position after targetFirst targetAfter →
      scan text position after targetFirst targetAfter = model text position after targetFirst targetAfter

theorem interpreted_freeModel {domain : StateDomain} (calls : Expressions.Calls)
    (inherited : RawHelperEquations calls (domain := domain)) (step : Step) (model scan : Free)
    (definitions : FreeDefinitionEquations calls step model scan) (text : Source)
    (position after targetFirst targetAfter : Nat) (valid : StepDomain text position after targetFirst targetAfter) :
    model text position after targetFirst targetAfter = actualNameFree text position after targetFirst targetAfter := by
  rw [definitions.modelEquation text position after targetFirst targetAfter valid, actualNameFree]
  dsimp +instances only [freeBody, FreeExpr.eval, FreeFrame.locals, stepLocals, Context.locals,
    Locals.set, Expr.eval]
  simp only [String.reduceEq, ↓reduceIte, ↓reduceDIte,
    decide_eq_true_eq, Bool.or_eq_true]
  split
  · rfl
  · rename_i active
    split
    · rfl
    · rename_i before
      rw [interpreted_step calls inherited step definitions.stepEquation text position after targetFirst targetAfter valid]
      by_cases nonzero : (actualNameStep text position after targetFirst targetAfter).next = 0
      · simp only [nonzero, ne_eq, not_true_eq_false, decide_false, Bool.false_and, true_or, ↓reduceIte]
      · by_cases free : (actualNameStep text position after targetFirst targetAfter).free = true
        · have progress := (actualNameStep_progress text position after targetFirst targetAfter valid.position).resolve_left nonzero
          have afterBound := valid.after
          have advanced : text.length + 1 - (actualNameStep text position after targetFirst targetAfter).next <
              text.length + 1 - position := by unfold ValidCursor at afterBound; omega
          have nextDomain : StepDomain text (actualNameStep text position after targetFirst targetAfter).next
              after targetFirst targetAfter :=
            ⟨valid.textValid, Nat.le_trans progress.2 valid.after, valid.after, valid.target⟩
          simp only [nonzero, ne_eq, not_false_eq_true, decide_true, free, Bool.true_and,
            Bool.not_true, Bool.false_eq_true, or_self, ↓reduceIte, advanced]
          exact interpreted_freeModel calls inherited step model scan definitions text
            (actualNameStep text position after targetFirst targetAfter).next after targetFirst targetAfter nextDomain
        · have notFree : (actualNameStep text position after targetFirst targetAfter).free = false :=
            Bool.eq_false_iff.mpr free
          simp only [nonzero, ne_eq, not_false_eq_true, decide_true, notFree,
            Bool.true_and, Bool.false_and, Bool.not_false, or_true, ↓reduceIte]
termination_by text.length + 1 - position
decreasing_by assumption

theorem interpreted_free {domain : StateDomain} (calls : Expressions.Calls)
    (inherited : RawHelperEquations calls (domain := domain)) (step : Step) (model scan : Free)
    (definitions : FreeDefinitionEquations calls step model scan) (text : Source)
    (position after targetFirst targetAfter : Nat) (valid : StepDomain text position after targetFirst targetAfter) :
    scan text position after targetFirst targetAfter = actualNameFree text position after targetFirst targetAfter :=
  (definitions.scanContract text position after targetFirst targetAfter valid).trans
    (interpreted_freeModel calls inherited step model scan definitions text position after targetFirst targetAfter valid)

/-- The concrete scanner inhabits the same complete-domain equations. This
checks consistency of the raw interface independently of its interpretation. -/
theorem freeBody_model (text : Source) (position after targetFirst targetAfter : Nat)
    (valid : StepDomain text position after targetFirst targetAfter) :
    freeBody.eval (lexical Expressions.modelCalls) actualNameStep actualNameFree
      {text, position, after, targetFirst, targetAfter} =
      actualNameFree text position after targetFirst targetAfter := by
  rw [actualNameFree]
  dsimp +instances only [freeBody, FreeExpr.eval, FreeFrame.locals, stepLocals, Context.locals,
    Locals.set, Expr.eval]
  simp only [String.reduceEq, ↓reduceIte, ↓reduceDIte, decide_eq_true_eq, Bool.or_eq_true]
  split
  · rfl
  · split
    · rfl
    · by_cases nonzero : (actualNameStep text position after targetFirst targetAfter).next = 0
      · simp only [nonzero, ne_eq, not_true_eq_false, decide_false, Bool.false_and, true_or, ↓reduceIte]
      · by_cases free : (actualNameStep text position after targetFirst targetAfter).free = true
        · have progress := (actualNameStep_progress text position after targetFirst targetAfter valid.position).resolve_left nonzero
          have afterBound := valid.after
          have advanced : text.length + 1 - (actualNameStep text position after targetFirst targetAfter).next <
              text.length + 1 - position := by unfold ValidCursor at afterBound; omega
          simp only [nonzero, ne_eq, not_false_eq_true, decide_true, free, Bool.true_and,
            Bool.not_true, Bool.false_eq_true, or_self, ↓reduceIte, advanced]
          rfl
        · have notFree : (actualNameStep text position after targetFirst targetAfter).free = false :=
            Bool.eq_false_iff.mpr free
          simp only [nonzero, ne_eq, not_false_eq_true, decide_true, notFree,
            Bool.true_and, Bool.false_and, Bool.not_false, or_true, ↓reduceIte]

theorem model_definitions :
    FreeDefinitionEquations Expressions.modelCalls actualNameStep actualNameFree actualNameFree where
  stepEquation := by
    intro text position after targetFirst targetAfter _
    exact (stepBody_model text position after targetFirst targetAfter).symm
  modelEquation := fun text position after targetFirst targetAfter valid =>
    (freeBody_model text position after targetFirst targetAfter valid).symm
  scanContract := by intros; rfl

end Silver.Predicate.ProcedureNameNative
