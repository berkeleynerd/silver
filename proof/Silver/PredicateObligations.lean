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
  | stringRange (context : Context) (summary : LengthSummary)
  | length (context : Context) (left right : Summary)
  | intervalLength (context : Context) (left : LengthSummary) (right : Summary)
  | validInput (context : Context)
  | scalar (obligation : Integer.Obligation)
  | impossible
  deriving DecidableEq, Repr

def Obligation.discharge : Obligation → Bool
  | .range context summary => fitsSummary context summary
  | .stringRange context summary => fitsLengthSummary context summary
  | .length context left right => equalSummary context left right
  | .intervalLength context left right => equalLengthSummary context left right
  | .validInput context => !context.invalidReachable
  | .scalar obligation => obligation.discharge
  | .impossible => false

def Obligation.Valid : Obligation → Prop
  | .range context summary => ∀ valid length rejected,
      context.Allows valid length rejected → summary.length length ≤ maxSourceLength
  | .stringRange context summary => summary.staticLength ≤ maxSourceLength ∧
      ∀ valid length rejected actualLength, context.Allows valid length rejected →
        summary.Contains length actualLength → summary.upper.length length ≤ maxSourceLength
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
  | stringRange context summary =>
      exact ⟨fitsLengthSummary_static checked, fun _ _ _ _ allowed within =>
        fitsLengthSummary_sound allowed within checked⟩
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

def Condition.obligations (shape : Shape) (analysis : Integer.Analysis) (condition : Condition) (flow : Flow) : List Obligation :=
  match condition with
  | .stringCompare _ left right =>
      imageObligations left flow.scalars ++ imageObligations right flow.scalars ++
        match left.inferLength shape flow.scalars, right.inferLength shape flow.scalars with
        | some a, some b => [.stringRange flow.path a, .stringRange flow.path b]
        | _, _ => [.impossible]
  | .lengthCompare _operator left right =>
      match shape left, right.bound shape with
      | some info, some bound => [.range flow.path info.bound.summary, .range flow.path bound.summary]
      | _, _ => [.impossible]
  | .scalarCompare _ left right =>
      (left.obligations flow.scalars ++ right.obligations flow.scalars).map Obligation.scalar
  | .inputValid => []
  | .parenthesized inner | .negated inner => inner.obligations shape analysis flow
  | .andThen left right =>
      left.obligations shape analysis flow ++ right.obligations shape analysis (left.refine shape analysis flow true)
  | .orElse left right =>
      left.obligations shape analysis flow ++ right.obligations shape analysis (left.refine shape analysis flow false)

theorem Condition.obligations_exact (condition : Condition) (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) :
    discharged (condition.obligations shape analysis flow) = condition.checkBounds shape analysis flow := by
  induction condition generalizing flow with
  | stringCompare unequal left right =>
      cases leftKnown : left.inferLength shape flow.scalars with
      | none => simp [obligations, checkBounds, leftKnown, discharged, Obligation.discharge]
      | some a =>
          cases rightKnown : right.inferLength shape flow.scalars with
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
  | parenthesized inner ih => exact ih flow
  | negated inner ih => exact ih flow
  | andThen left right ihl ihr => simp only [obligations, discharged_append, ihl, ihr, checkBounds]
  | orElse left right ihl ihr => simp only [obligations, discharged_append, ihl, ihr, checkBounds]

def simpleObligations (shape : Shape) (context : Context) (item : Sequence.SimpleStatement)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
  match item with
  | .null => []
  | .assign update => imageObligations update.value ranges ++
      match shape update.target, update.value.inferLength shape ranges with
      | some ⟨bound, true⟩, some summary => [.stringRange context summary,
          .intervalLength context summary bound.summary]
      | _, _ => [.impossible]
  | .output expression | .put expression => imageObligations expression ranges ++
      match expression.inferLength shape ranges with
      | some summary => [.stringRange context summary, .validInput context]
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
  def Statement.obligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (item : Statement) : List Obligation :=
    match item with
    | .simple item => simpleObligations shape flow.path item flow.scalars
    | .scalarAssign update => (update.obligations flow.scalars).map Obligation.scalar
    | .arrayAssign update => (update.obligations flow.scalars).map Obligation.scalar
    | .reject => []
    | .choice condition yes no => condition.obligations shape analysis flow ++
        statementsObligations shape analysis (condition.refine shape analysis flow true) yes ++
        statementsObligations shape analysis (condition.refine shape analysis flow false) no
    | .forLoop index _ lower upper body =>
        (lower.obligations flow.scalars ++ upper.obligations flow.scalars).map Obligation.scalar ++
          match lower.infer flow.scalars, upper.infer flow.scalars with
          | some a, some b => statementsObligations shape
              (analysis.withIndex index (Integer.loopBounds a b))
              (loopEntry analysis flow index (Integer.loopBounds a b)) body
          | _, _ => [.impossible]
  termination_by sizeOf item
  def statementsObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (items : List Statement) : List Obligation :=
    match items with
    | [] => []
    | item :: rest => item.obligations shape analysis flow ++
        match item.check shape analysis flow with
        | none => []
        | some next => statementsObligations shape analysis next rest
  termination_by sizeOf items
end

mutual
  theorem statement_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {item : Statement}
      (checked : item.check shape analysis before = some after) : discharged (item.obligations shape analysis before) = true := by
    cases item with
    | simple item =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simpa only [Statement.obligations, simple_obligations_exact] using good
        · contradiction
    | scalarAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          simpa only [Statement.obligations, scalar_discharged] using update.obligations_discharge good
        · contradiction
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have accepted := (Bool.and_eq_true.mp good).1
          simpa only [Statement.obligations, scalar_discharged] using update.obligations_discharge accepted
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

  theorem statements_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {items : List Statement}
      (checked : checkStatements shape analysis before items = some after) :
      discharged (statementsObligations shape analysis before items) = true := by
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

theorem statements_obligations_valid {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {items : List Statement}
    (checked : checkStatements shape analysis before items = some after) :
    ∀ check ∈ statementsObligations shape analysis before items, check.Valid := by
  have all := statements_obligations_discharge checked
  simp only [discharged, List.all_eq_true] at all
  exact fun check present => Obligation.discharge_sound (all check present)

def Obligation.toObligation (check : Obligation) : Semantics.Obligation := ⟨.runTimeSafety, check.discharge⟩

def modeledObligations (shape : Shape) (analysis : Integer.Analysis) (before : Flow) (items : List Statement) : List Semantics.Obligation :=
  (statementsObligations shape analysis before items).map Obligation.toObligation

theorem all_modeled_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {before after : Flow} {items : List Statement}
    (checked : checkStatements shape analysis before items = some after) :
    Semantics.discharge (modeledObligations shape analysis before items) = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check present
  obtain ⟨schema, member, rfl⟩ := List.mem_map.mp present
  exact (List.all_eq_true.mp (statements_obligations_discharge checked)) schema member

end Silver.Predicate
