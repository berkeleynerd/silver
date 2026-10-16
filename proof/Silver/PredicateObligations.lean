module

public import Silver.PredicateStatements
public import Silver.ComposeObligations

@[expose] public section

/-! Complete path-indexed modeled checks. Both syntactic arms and every reached
short-circuit operand contribute schemas. Endpoint arithmetic discharges each
schema; justified runtime path facts are supplied by PredicateExecution. This
is independent of faithful native VC generation and external solver completion. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

inductive Obligation
  | range (context : Context) (summary : Summary)
  | length (context : Context) (left right : Summary)
  | intervalLength (context : Context) (left : LengthSummary) (right : Summary)
  | validInput (context : Context)
  | scalar (obligation : Integer.Obligation)
  | impossible
  deriving DecidableEq, Repr

def Obligation.discharge : Obligation → Bool
  | .range context summary => fitsSummary context summary
  | .length context left right => equalSummary context left right
  | .intervalLength context left right => equalLengthSummary context left right
  | .validInput context => !context.invalidReachable
  | .scalar obligation => obligation.discharge
  | .impossible => false

def Obligation.Valid : Obligation → Prop
  | .range context summary => ∀ valid length rejected,
      context.Allows valid length rejected → summary.length length ≤ maxSourceLength
  | .length context left right => ∀ valid length rejected,
      context.Allows valid length rejected → left.length length = right.length length
  | .intervalLength context left right => ∀ valid inputLength rejected actualLength,
      context.Allows valid inputLength rejected → left.Contains inputLength actualLength →
        actualLength = right.length inputLength
  | .validInput context => ∀ valid length rejected,
      context.Allows valid length rejected → valid = true
  | .scalar obligation => obligation.Valid
  | .impossible => False

theorem Obligation.discharge_sound {check : Obligation} (checked : check.discharge = true) : check.Valid := by
  cases check with
  | range context summary => exact fun _ _ _ allowed => fitsSummary_sound allowed checked
  | length context left right => exact fun _ _ _ allowed => equalSummary_sound allowed checked
  | intervalLength context left right =>
      exact fun _ _ _ _ allowed within => equalLengthSummary_sound allowed within checked
  | validInput context =>
      have safe : context.invalidReachable = false := by simpa [Obligation.discharge] using checked
      exact fun _ _ _ allowed => Context.output_requires_valid_input allowed safe
  | scalar obligation => exact Integer.Obligation.discharge_sound checked
  | impossible => contradiction

def discharged (checks : List Obligation) : Bool := checks.all Obligation.discharge

theorem discharged_append (first following : List Obligation) :
    discharged (first ++ following) = (discharged first && discharged following) := List.all_append

theorem scalar_discharged (checks : List Integer.Obligation) :
    discharged (checks.map Obligation.scalar) = Integer.discharged checks := by
  simp only [discharged, Integer.discharged, List.all_map, Function.comp_def, Obligation.discharge]

def imageObligations (expression : Expression) (ranges : Integer.Ranges) : List Obligation :=
  expression.flatMap fun atom => match atom with
    | .image scalar => (scalar.obligations ranges).map Obligation.scalar
    | _ => []

theorem image_obligations_discharge {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    discharged (imageObligations expression ranges) = true := by
  induction expression generalizing summary with
  | nil => rfl
  | cons atom rest ih =>
      simp only [Expression.inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, _⟩ := known
      have tail := ih restKnown
      simp only [imageObligations, List.flatMap_cons, discharged_append]
      change (discharged _ && discharged (imageObligations rest ranges)) = true
      rw [tail, Bool.and_true]
      cases atom with
      | literal | argument | reference => rfl
      | image scalar =>
          simp only [Operand.inferLength, Option.map_eq_some_iff] at atomKnown
          obtain ⟨bounds, found, _⟩ := atomKnown
          exact (scalar_discharged _).trans (Integer.Expr.obligations_discharge found)

def Condition.obligations (shape : Shape) (condition : Condition) (context : Context)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
  match condition with
  | .stringCompare _ left right =>
      imageObligations left ranges ++ imageObligations right ranges ++
        match left.inferLength shape ranges, right.inferLength shape ranges with
        | some a, some b => [.range context a.upper, .range context b.upper]
        | _, _ => [.impossible]
  | .lengthCompare _operator left right =>
      match shape left, right.bound shape with
      | some info, some bound => [.range context info.bound.summary, .range context bound.summary]
      | _, _ => [.impossible]
  | .scalarCompare _ left right =>
      (left.obligations ranges ++ right.obligations ranges).map Obligation.scalar
  | .inputValid => []
  | .parenthesized inner | .negated inner => inner.obligations shape context ranges
  | .andThen left right =>
      left.obligations shape context ranges ++ right.obligations shape (left.refine shape context true ranges) ranges
  | .orElse left right =>
      left.obligations shape context ranges ++ right.obligations shape (left.refine shape context false ranges) ranges

theorem Condition.obligations_exact (condition : Condition) (shape : Shape) (context : Context)
    (ranges : Integer.Ranges := Integer.emptyRanges) :
    discharged (condition.obligations shape context ranges) = condition.checkBounds shape context ranges := by
  induction condition generalizing context with
  | stringCompare unequal left right =>
      cases leftKnown : left.inferLength shape ranges with
      | none => simp [obligations, checkBounds, leftKnown, discharged, Obligation.discharge]
      | some a =>
          cases rightKnown : right.inferLength shape ranges with
          | none => simp [obligations, checkBounds, leftKnown, rightKnown, discharged, Obligation.discharge]
          | some b =>
              simp only [obligations, checkBounds, leftKnown, rightKnown, discharged_append,
                image_obligations_discharge leftKnown, image_obligations_discharge rightKnown,
                Bool.true_and]
              simp [discharged, Obligation.discharge]
  | lengthCompare operator left right =>
      simp only [obligations, checkBounds]
      split <;> simp_all [discharged, Obligation.discharge]
  | scalarCompare operator left right =>
      simp only [obligations, List.map_append, discharged_append, scalar_discharged,
        Integer.Expr.obligations_exact, checkBounds]
  | inputValid => rfl
  | parenthesized inner ih => exact ih context
  | negated inner ih => exact ih context
  | andThen left right ihl ihr => simp only [obligations, discharged_append, ihl, ihr, checkBounds]
  | orElse left right ihl ihr => simp only [obligations, discharged_append, ihl, ihr, checkBounds]

def simpleObligations (shape : Shape) (context : Context) (item : Sequence.SimpleStatement)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
  match item with
  | .null => []
  | .assign update => imageObligations update.value ranges ++
      match shape update.target, update.value.inferLength shape ranges with
      | some ⟨bound, true⟩, some summary => [.range context summary.upper,
          .intervalLength context summary bound.summary]
      | _, _ => [.impossible]
  | .output expression | .put expression => imageObligations expression ranges ++
      match expression.inferLength shape ranges with
      | some summary => [.range context summary.upper, .validInput context]
      | none => [.impossible]

theorem simple_obligations_exact (shape : Shape) (context : Context) (item : Sequence.SimpleStatement)
    (ranges : Integer.Ranges := Integer.emptyRanges) :
    discharged (simpleObligations shape context item ranges) = checkSimple shape context item ranges := by
  cases item with
  | null => rfl
  | output expression | put expression =>
      cases known : expression.inferLength shape ranges with
      | none => simp [simpleObligations, checkSimple, known, discharged, Obligation.discharge]
      | some summary =>
          simp only [simpleObligations, checkSimple, known, discharged_append,
            image_obligations_discharge known, Bool.true_and]
          simp [discharged, Obligation.discharge]
  | assign update =>
      simp only [simpleObligations, checkSimple, checkAssignment, discharged_append]
      split
      · rename_i bound summary target known
        rw [image_obligations_discharge known]
        simp [target, known, discharged, Obligation.discharge]
      ·
        simp only [discharged, List.all_cons, List.all_nil, Obligation.discharge,
          Bool.false_and, Bool.and_false]

mutual
  def Statement.obligations (shape : Shape) (context : Context) (item : Statement)
      (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
    match item with
    | .simple item => simpleObligations shape context item ranges
    | .reject => []
    | .choice condition yes no => condition.obligations shape context ranges ++
        statementsObligations shape (condition.refine shape context true ranges) yes ranges ++
        statementsObligations shape (condition.refine shape context false ranges) no ranges
    | .forLoop index _ lower upper body =>
        (lower.obligations ranges ++ upper.obligations ranges).map Obligation.scalar ++
          match lower.infer ranges, upper.infer ranges with
          | some a, some b => statementsObligations shape (loopContext context (Integer.loopBounds a b)) body
              (Integer.put ranges index (some (Integer.loopBounds a b)))
          | _, _ => [.impossible]
  termination_by sizeOf item
  def statementsObligations (shape : Shape) (context : Context) (items : List Statement)
      (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
    match items with
    | [] => []
    | item :: rest => item.obligations shape context ranges ++
        match item.check shape context ranges with
        | none => []
        | some next => statementsObligations shape next rest ranges
  termination_by sizeOf items
end

mutual
  theorem statement_obligations_discharge {shape : Shape} {ranges : Integer.Ranges} {before after : Context} {item : Statement}
      (checked : item.check shape before ranges = some after) : discharged (item.obligations shape before ranges) = true := by
    cases item with
    | simple item =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simpa only [Statement.obligations, simple_obligations_exact] using good
        · contradiction
    | reject => simp [Statement.obligations, discharged]
    | choice condition yes no =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i bounded
          simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
          obtain ⟨afterYes, yesChecked, afterNo, noChecked, _⟩ := checked
          simp only [Statement.obligations, discharged_append, Condition.obligations_exact, bounded,
            statements_obligations_discharge yesChecked, statements_obligations_discharge noChecked,
            Bool.and_self]
        · contradiction
    | forLoop index reverse lower upper body =>
        simp only [Statement.check, Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
        obtain ⟨a, lowerFound, b, upperFound, bodyAfter, bodyChecked, _⟩ := checked
        simp only [Statement.obligations, lowerFound, upperFound, List.map_append, discharged_append,
          scalar_discharged, Integer.Expr.obligations_discharge lowerFound,
          Integer.Expr.obligations_discharge upperFound, statements_obligations_discharge bodyChecked,
          Bool.and_self]
  termination_by sizeOf item

  theorem statements_obligations_discharge {shape : Shape} {ranges : Integer.Ranges} {before after : Context} {items : List Statement}
      (checked : checkStatements shape before items ranges = some after) :
      discharged (statementsObligations shape before items ranges) = true := by
    cases items with
    | nil => simp [statementsObligations, discharged]
    | cons item rest =>
        simp only [checkStatements, Option.bind_eq_some_iff] at checked
        obtain ⟨middle, firstChecked, restChecked⟩ := checked
        simp only [statementsObligations, firstChecked, discharged_append,
          statement_obligations_discharge firstChecked, statements_obligations_discharge restChecked,
          Bool.and_self]
  termination_by sizeOf items
end

theorem statements_obligations_valid {shape : Shape} {ranges : Integer.Ranges} {before after : Context} {items : List Statement}
    (checked : checkStatements shape before items ranges = some after) :
    ∀ check ∈ statementsObligations shape before items ranges, check.Valid := by
  have all := statements_obligations_discharge checked
  simp only [discharged, List.all_eq_true] at all
  exact fun check present => Obligation.discharge_sound (all check present)

def Obligation.toObligation (check : Obligation) : Semantics.Obligation := ⟨.runTimeSafety, check.discharge⟩

def modeledObligations (shape : Shape) (before : Context) (items : List Statement)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Semantics.Obligation :=
  (statementsObligations shape before items ranges).map Obligation.toObligation

theorem all_modeled_obligations_discharge {shape : Shape} {ranges : Integer.Ranges} {before after : Context} {items : List Statement}
    (checked : checkStatements shape before items ranges = some after) :
    Semantics.discharge (modeledObligations shape before items ranges) = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check present
  obtain ⟨schema, member, rfl⟩ := List.mem_map.mp present
  exact (List.all_eq_true.mp (statements_obligations_discharge checked)) schema member

end Silver.Predicate
