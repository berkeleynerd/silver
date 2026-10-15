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
  | validInput (context : Context)
  | scalar (obligation : Integer.Obligation)
  | impossible
  deriving DecidableEq, Repr

def Obligation.discharge : Obligation → Bool
  | .range context summary => fitsSummary context summary
  | .length context left right => equalSummary context left right
  | .validInput context => !context.invalidReachable
  | .scalar obligation => obligation.discharge
  | .impossible => false

def Obligation.Valid : Obligation → Prop
  | .range context summary => ∀ valid length rejected,
      context.Allows valid length rejected → summary.length length ≤ maxSourceLength
  | .length context left right => ∀ valid length rejected,
      context.Allows valid length rejected → left.length length = right.length length
  | .validInput context => ∀ valid length rejected,
      context.Allows valid length rejected → valid = true
  | .scalar obligation => obligation.Valid
  | .impossible => False

theorem Obligation.discharge_sound {check : Obligation} (checked : check.discharge = true) : check.Valid := by
  cases check with
  | range context summary => exact fun _ _ _ allowed => fitsSummary_sound allowed checked
  | length context left right => exact fun _ _ _ allowed => equalSummary_sound allowed checked
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

def Condition.obligations (shape : Shape) (condition : Condition) (context : Context)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
  match condition with
  | .stringCompare _ left right =>
      [.range context (left.summary shape), .range context (right.summary shape)]
  | .lengthCompare _operator left right =>
      match shape left, right.bound shape with
      | some info, some bound => [.range context info.bound.summary, .range context bound.summary]
      | _, _ => [.impossible]
  | .scalarCompare _ left right =>
      (left.obligations ranges ++ right.obligations ranges).map Obligation.scalar
  | .inputValid => []
  | .parenthesized inner | .negated inner => inner.obligations shape context ranges
  | .andThen left right =>
      left.obligations shape context ranges ++ right.obligations shape (left.refine shape context true) ranges
  | .orElse left right =>
      left.obligations shape context ranges ++ right.obligations shape (left.refine shape context false) ranges

theorem Condition.obligations_exact (condition : Condition) (shape : Shape) (context : Context)
    (ranges : Integer.Ranges := Integer.emptyRanges) :
    discharged (condition.obligations shape context ranges) = condition.checkBounds shape context ranges := by
  induction condition generalizing context with
  | stringCompare unequal left right => simp [obligations, discharged, Obligation.discharge, checkBounds]
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

def simpleObligations (shape : Shape) (context : Context) : Sequence.SimpleStatement → List Obligation
  | .null => []
  | .assign update =>
      match shape update.target with
      | some ⟨bound, true⟩ => [.range context (update.value.summary shape),
          .length context (update.value.summary shape) bound.summary]
      | _ => [.impossible]
  | .output expression | .put expression => [.range context (expression.summary shape), .validInput context]

theorem simple_obligations_exact (shape : Shape) (context : Context) (item : Sequence.SimpleStatement) :
    discharged (simpleObligations shape context item) = checkSimple shape context item := by
  cases item with
  | null => rfl
  | output expression | put expression => simp [simpleObligations, discharged, Obligation.discharge, checkSimple]
  | assign update =>
      simp only [simpleObligations, checkSimple, checkAssignment]
      split <;> simp_all [discharged, Obligation.discharge]

mutual
  def Statement.obligations (shape : Shape) (context : Context) (item : Statement)
      (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
    match item with
    | .simple item => simpleObligations shape context item
    | .reject => []
    | .choice condition yes no => condition.obligations shape context ranges ++
        statementsObligations shape (condition.refine shape context true) yes ranges ++
        statementsObligations shape (condition.refine shape context false) no ranges
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
