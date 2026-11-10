module

public import Silver.PredicateStatements
public import Silver.ComposeObligations
public import Silver.StringObligations

@[expose] public section

/-! Complete path-indexed modeled checks. Both syntactic arms and every reached
short-circuit operand contribute schemas. Endpoint arithmetic discharges each
schema; justified runtime path facts are supplied by PredicateExecution. This
is independent of faithful native VC generation and external solver completion. -/

namespace Silver.Predicate
open Bindings Compose PathFacts

variable {signatures : ScalarFunctions.Signatures} {procedures : ScalarProcedures.Signatures}

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

def imageObligations (expression : Expression) (ranges : Integer.Ranges) (shape : Shape) : List Obligation :=
  (expression.imageObligations ranges shape).map Obligation.scalar

theorem image_obligations_discharge {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    discharged (imageObligations expression ranges shape) = true := by
  exact (scalar_discharged _).trans (Expression.image_obligations_discharge known)

def Condition.obligations (shape : Shape) (analysis : Integer.Analysis) (condition : Condition) (flow : Flow) (booleans : Boolean.Analysis := {}) : List Obligation :=
  match condition with
  | .stringCompare _ left right =>
      imageObligations left flow.scalars shape ++ imageObligations right flow.scalars shape ++
        match left.inferLength shape flow.scalars, right.inferLength shape flow.scalars with
        | some a, some b => [.stringRange flow.path a, .stringRange flow.path b]
        | _, _ => [.impossible]
  | .lengthCompare _operator left right =>
      match shape left, right.bound shape with
      | some info, some bound => [.range flow.path info.bound.summary, .range flow.path bound.summary]
      | _, _ => [.impossible]
  | .scalarCompare _ left right =>
      (left.obligations flow.scalars ++ right.obligations flow.scalars).map Obligation.scalar
  | .characterCompare _ left right =>
      ((left.obligations shape.fixedLengths flow.scalars) ++
        (right.obligations shape.fixedLengths flow.scalars)).map Obligation.scalar
  | .inputValid | .booleanLiteral _ => []
  | .booleanName index => if booleans.initialized index then [] else [.impossible]
  | .booleanArrayRead array index =>
      (if array.initialized booleans then [] else [.impossible]) ++
        (array.indexObligations flow.scalars index).map Obligation.scalar
  | .parenthesized inner | .negated inner => inner.obligations shape analysis flow booleans
  | .andThen left right =>
      left.obligations shape analysis flow booleans ++ right.obligations shape analysis (left.refine shape analysis flow true) booleans
  | .orElse left right =>
      left.obligations shape analysis flow booleans ++ right.obligations shape analysis (left.refine shape analysis flow false) booleans

  | .eager _ left right | .booleanCompare _ left right =>
      left.obligations shape analysis flow booleans ++ right.obligations shape analysis flow booleans

theorem Condition.obligations_exact (condition : Condition) (shape : Shape) (analysis : Integer.Analysis) (flow : Flow) (booleans : Boolean.Analysis := {}) :
    discharged (condition.obligations shape analysis flow booleans) = condition.checkBounds shape analysis flow booleans := by
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
  | characterCompare operator left right =>
      simp only [obligations, List.map_append, discharged_append, scalar_discharged,
        Character.Expr.obligations_exact, checkBounds]
  | inputValid | booleanLiteral _ => rfl
  | booleanName index => cases known : booleans.initialized index <;> simp [obligations, checkBounds, known, discharged, Obligation.discharge]
  | booleanArrayRead array index =>
      simp only [obligations, discharged_append, scalar_discharged,
        Boolean.ArrayDescriptor.indexObligations_exact, checkBounds]
      cases array.initialized booleans <;> simp [discharged, Obligation.discharge]
  | parenthesized inner ih => exact ih flow
  | negated inner ih => exact ih flow
  | andThen left right ihl ihr => simp only [obligations, discharged_append, ihl, ihr, checkBounds]
  | orElse left right ihl ihr | eager _ left right ihl ihr | booleanCompare _ left right ihl ihr =>
      simp only [obligations, discharged_append, ihl, ihr, checkBounds]

def simpleObligations (shape : Shape) (context : Context) (item : Sequence.SimpleStatement)
    (ranges : Integer.Ranges := Integer.emptyRanges) : List Obligation :=
  match item with
  | .null => []
  | .assign update => imageObligations update.value ranges shape ++
      match shape update.target, update.value.inferLength shape ranges with
      | some ⟨bound, true⟩, some summary => [.stringRange context summary,
          .intervalLength context summary bound.summary]
      | _, _ => [.impossible]
  | .output expression | .put expression => imageObligations expression ranges shape ++
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


/-- Actual evaluation and formal-subtype checks are distinct schemas. -/
def actualObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
    (booleans : Boolean.Analysis) : ScalarFunctions.ScalarType → ScalarFunctions.Actual → List Obligation
  | .integer target, .integer expression =>
      (expression.obligations flow.scalars).map Obligation.scalar ++
        match expression.infer flow.scalars with
        | some bounds => [.scalar (.within bounds target)]
        | none => [.impossible]
  | .boolean, .boolean condition => condition.obligations shape analysis flow booleans
  | _, _ => [.impossible]

theorem actual_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    {booleans : Boolean.Analysis} {formal : ScalarFunctions.ScalarType} {actual : ScalarFunctions.Actual}
    (checked : actual.check shape analysis flow booleans formal = true) :
    discharged (actualObligations shape analysis flow booleans formal actual) = true := by
  cases formal <;> cases actual
  · rename_i target expression
    cases known : expression.infer flow.scalars with
    | none => simp [ScalarFunctions.Actual.check, known] at checked
    | some bounds =>
        have included : bounds.included target = true := by
          exact (Bool.and_eq_true_iff.mp (show (!bounds.isEmpty && bounds.included target) = true from by
            simpa only [ScalarFunctions.Actual.check, known] using checked)).2
        simp only [actualObligations, known, discharged_append, scalar_discharged,
          Integer.Expr.obligations_discharge known, Bool.true_and]
        simpa [discharged, Obligation.discharge, Integer.Obligation.discharge] using included
  · contradiction
  · contradiction
  · simpa only [actualObligations, Condition.obligations_exact, ScalarFunctions.Actual.check] using checked

def actualsObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
    (booleans : Boolean.Analysis) : List ScalarFunctions.ScalarType → List ScalarFunctions.Actual → List Obligation
  | [], [] => []
  | formal :: formals, actual :: actuals =>
      actualObligations shape analysis flow booleans formal actual ++
        actualsObligations shape analysis flow booleans formals actuals
  | _, _ => [.impossible]

theorem actuals_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    {booleans : Boolean.Analysis} {formals : List ScalarFunctions.ScalarType} {actuals : List ScalarFunctions.Actual}
    (checked : ScalarFunctions.checkActuals shape analysis flow booleans formals actuals = true) :
    discharged (actualsObligations shape analysis flow booleans formals actuals) = true := by
  induction formals generalizing actuals with
  | nil => cases actuals <;> simp_all [ScalarFunctions.checkActuals, actualsObligations, discharged]
  | cons formal formals ih =>
      cases actuals with
      | nil => contradiction
      | cons actual actuals =>
          have both := Bool.and_eq_true_iff.mp checked
          rw [actualsObligations, discharged_append, actual_obligations_discharge both.1, ih both.2]
          rfl

def callObligations (signatures : ScalarFunctions.Signatures) (shape : Shape)
    (analysis : Integer.Analysis) (flow : Flow) (booleans : Boolean.Analysis)
    (assignment : ScalarFunctions.Assignment) : List Obligation :=
  match ScalarFunctions.lookup signatures assignment.call.callee with
  | none => [.impossible]
  | some signature => actualsObligations shape analysis flow booleans signature.formals assignment.call.actuals ++
      match assignment.target, signature.result with
      | .integer _ target, .integer bounds => [.scalar (.within bounds target)]
      | .boolean _, .boolean => []
      | _, _ => [.impossible]

theorem call_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    {booleans : Boolean.Analysis} {assignment : ScalarFunctions.Assignment}
    (checked : assignment.check signatures shape analysis flow booleans = true) :
    discharged (callObligations signatures shape analysis flow booleans assignment) = true := by
  obtain ⟨result, called, targeted⟩ := assignment.check_success checked
  obtain ⟨signature, found, actuals, resultEq⟩ := assignment.call.check_success called
  rw [← resultEq] at targeted
  simp only [callObligations, found, discharged_append, actuals_obligations_discharge actuals, Bool.true_and]
  cases targetEq : assignment.target <;> cases resultEq : signature.result
  · rw [targetEq, resultEq] at targeted
    have included := (ScalarFunctions.Target.integer_check targeted).2.2.2
    simpa [discharged, Obligation.discharge, Integer.Obligation.discharge] using included
  · simp [ScalarFunctions.Target.check, targetEq, resultEq] at targeted
  · simp [ScalarFunctions.Target.check, targetEq, resultEq] at targeted
  · rfl

def targetObligations : ScalarFunctions.ScalarType → ScalarFunctions.Target → List Obligation
  | .integer bounds, .integer _ target => [.scalar (.within bounds target)]
  | .boolean, .boolean _ => []
  | _, _ => [.impossible]

theorem target_obligations_discharge {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {domain : ScalarFunctions.ScalarType} {target : ScalarFunctions.Target}
    (checked : target.check analysis booleans domain = true) :
    discharged (targetObligations domain target) = true := by
  cases domain <;> cases target
  · have included := (ScalarFunctions.Target.integer_check checked).2.2.2
    simpa [targetObligations, discharged, Obligation.discharge, Integer.Obligation.discharge] using included
  · simp [ScalarFunctions.Target.check] at checked
  · simp [ScalarFunctions.Target.check] at checked
  · rfl

def targetsObligations : List ScalarFunctions.ScalarType → List ScalarFunctions.Target → List Obligation
  | [], [] => []
  | domain :: domains, target :: targets => targetObligations domain target ++ targetsObligations domains targets
  | _, _ => [.impossible]

theorem targets_obligations_discharge {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {domains : List ScalarFunctions.ScalarType} {targets : List ScalarFunctions.Target}
    (checked : ScalarProcedures.checkTargets analysis booleans domains targets = true) :
    discharged (targetsObligations domains targets) = true := by
  induction domains generalizing targets with
  | nil => cases targets <;> simp_all [ScalarProcedures.checkTargets, targetsObligations, discharged]
  | cons domain domains ih =>
      cases targets with
      | nil => contradiction
      | cons target targets =>
          have both := Bool.and_eq_true_iff.mp checked
          rw [targetsObligations, discharged_append, target_obligations_discharge both.1, ih both.2]
          rfl

/-- Input evaluation/copy-in and every output copy-back conversion are retained.
The procedure body is discharged separately for every declared input tuple. -/
def procedureCallObligations (procedures : ScalarProcedures.Signatures) (shape : Shape)
    (analysis : Integer.Analysis) (flow : Flow) (booleans : Boolean.Analysis)
    (call : ScalarProcedures.Call) : List Obligation :=
  match call.resolve procedures with
  | none => [.impossible]
  | some resolved => actualsObligations shape analysis flow booleans
      (ScalarProcedures.inputTypes resolved.signature.formals) resolved.actuals.inputs ++
      targetsObligations (ScalarProcedures.outputTypes resolved.signature.formals) resolved.actuals.outputs

theorem procedure_call_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {flow : Flow}
    {booleans : Boolean.Analysis} {call : ScalarProcedures.Call}
    (checked : call.check procedures shape analysis flow booleans = true) :
    discharged (procedureCallObligations procedures shape analysis flow booleans call) = true := by
  obtain ⟨resolved, found, _, inputs, outputs⟩ := call.check_success checked
  simp only [procedureCallObligations, found, discharged_append,
    actuals_obligations_discharge inputs, targets_obligations_discharge outputs, Bool.and_self]

mutual
  def Statement.obligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (item : Statement) (booleans : Boolean.Analysis := {})
      (signatures : ScalarFunctions.Signatures := [])
      (procedures : ScalarProcedures.Signatures := []) : List Obligation :=
    match item with
    | .simple item => simpleObligations shape flow.path item flow.scalars
    | .scalarAssign update => (update.obligations flow.scalars).map Obligation.scalar
    | .callAssign update => callObligations signatures shape analysis flow booleans update
    | .procedureCall call => procedureCallObligations procedures shape analysis flow booleans call
    | .arrayAssign update => (update.obligations flow.scalars).map Obligation.scalar
    | .booleanAssign update =>
        (if booleans.canWrite update.target then [] else [.impossible]) ++
          update.value.obligations shape analysis flow booleans
    | .booleanArrayAssign update =>
        (if update.array.writable booleans then [] else [.impossible]) ++
          (update.array.indexObligations flow.scalars update.index).map Obligation.scalar ++
          update.value.obligations shape analysis flow booleans
    | .reject => []
    | .choice condition yes no => condition.obligations shape analysis flow booleans ++
        statementsObligations (signatures := signatures) (procedures := procedures) shape analysis (condition.refine shape analysis flow true) yes booleans ++
        statementsObligations (signatures := signatures) (procedures := procedures) shape analysis (condition.refine shape analysis flow false) no booleans
    | .forLoop index _ lower upper body =>
        (lower.obligations flow.scalars ++ upper.obligations flow.scalars).map Obligation.scalar ++
          match lower.infer flow.scalars, upper.infer flow.scalars with
          | some a, some b => statementsObligations (signatures := signatures) (procedures := procedures) shape
              (analysis.withIndex index (Integer.loopBounds a b))
              (loopEntry analysis flow index (Integer.loopBounds a b)) body booleans
          | _, _ => [.impossible]
    | .arrayLoop index _ array body =>
        [.scalar (.arrayIndex array array.bounds)] ++
          statementsObligations (signatures := signatures) (procedures := procedures) shape (analysis.withIndex index array.componentBounds)
            (arrayLoopEntry analysis flow index array.componentBounds) body booleans
  termination_by sizeOf item
  def statementsObligations (shape : Shape) (analysis : Integer.Analysis) (flow : Flow)
      (items : List Statement) (booleans : Boolean.Analysis := {})
      (signatures : ScalarFunctions.Signatures := [])
      (procedures : ScalarProcedures.Signatures := []) : List Obligation :=
    match items with
    | [] => []
    | item :: rest => item.obligations (signatures := signatures) (procedures := procedures) shape analysis flow booleans ++
        match item.check (signatures := signatures) (procedures := procedures) shape analysis flow booleans with
        | none => []
        | some next => statementsObligations (signatures := signatures) (procedures := procedures) shape analysis next rest booleans
  termination_by sizeOf items
end

mutual
  theorem statement_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {before after : Flow} {item : Statement}
      (checked : item.check (signatures := signatures) (procedures := procedures) shape analysis before booleans = some after) : discharged (item.obligations (signatures := signatures) (procedures := procedures) shape analysis before booleans) = true := by
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
    | callAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.obligations] using call_obligations_discharge (by assumption : update.check signatures shape analysis before booleans = true)
        · contradiction
    | procedureCall call =>
        simp only [Statement.check] at checked
        split at checked
        · simpa only [Statement.obligations] using procedure_call_obligations_discharge
            (by assumption : call.check procedures shape analysis before booleans = true)
        · contradiction
    | arrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have both : update.check before.scalars analysis.mutable = true ∧
              update.array.componentRanges analysis.declared = true := by
            simpa only [checkArrayAssignment, Bool.and_eq_true] using good
          have accepted := both.1
          simpa only [Statement.obligations, scalar_discharged] using update.obligations_discharge accepted
        · contradiction
    | booleanAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have both := Bool.and_eq_true_iff.mp good
          simp only [Statement.obligations, both.1, ↓reduceIte, List.nil_append,
            Condition.obligations_exact, both.2]
        · contradiction
    | booleanArrayAssign update =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i good
          have both : update.array.writable booleans = true ∧
              update.array.checkIndex before.scalars update.index = true ∧
              update.value.checkBounds shape analysis before booleans = true := by
            simpa only [BooleanArrayAssignment.check, Bool.and_eq_true] using good
          simp only [Statement.obligations, both.1, ↓reduceIte, List.nil_append,
            discharged_append, scalar_discharged, Boolean.ArrayDescriptor.indexObligations_exact,
            Condition.obligations_exact, both.2.1, both.2.2, Bool.and_self]
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
    | arrayLoop index reverse array body =>
        simp only [Statement.check] at checked
        split at checked
        · rename_i ready
          have valid := ((arrayLoopReady_iff analysis before index array).mp (Bool.and_eq_true_iff.mp ready).1).1
          simp only [Option.map_eq_some_iff] at checked
          obtain ⟨bodyAfter, bodyChecked, _⟩ := checked
          have indexCheck : Integer.arrayIndexCheck array array.bounds = true := by
            simp only [Integer.arrayIndexCheck, decide_eq_true_eq]
            exact ⟨valid, valid.2, Int.le_refl _, Int.le_refl _⟩
          simp only [Statement.obligations, discharged_append,
            statements_obligations_discharge bodyChecked, Bool.and_true]
          simp [discharged, Obligation.discharge, Integer.Obligation.discharge, indexCheck]
        · contradiction
  termination_by sizeOf item

  theorem statements_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {before after : Flow} {items : List Statement}
      (checked : checkStatements (signatures := signatures) (procedures := procedures) shape analysis before items booleans = some after) :
      discharged (statementsObligations (signatures := signatures) (procedures := procedures) shape analysis before items booleans) = true := by
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

theorem statements_obligations_valid {shape : Shape} {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {before after : Flow} {items : List Statement}
    (checked : checkStatements (signatures := signatures) (procedures := procedures) shape analysis before items booleans = some after) :
    ∀ check ∈ statementsObligations (signatures := signatures) (procedures := procedures) shape analysis before items booleans, check.Valid := by
  have all := statements_obligations_discharge checked
  simp only [discharged, List.all_eq_true] at all
  exact fun check present => Obligation.discharge_sound (all check present)

def Obligation.toObligation (check : Obligation) : Semantics.Obligation := ⟨.runTimeSafety, check.discharge⟩

def modeledObligations (shape : Shape) (analysis : Integer.Analysis) (before : Flow) (items : List Statement) (booleans : Boolean.Analysis := {})
    (signatures : ScalarFunctions.Signatures := [])
      (procedures : ScalarProcedures.Signatures := []) : List Semantics.Obligation :=
  (statementsObligations (signatures := signatures) (procedures := procedures) shape analysis before items booleans).map Obligation.toObligation

theorem all_modeled_obligations_discharge {shape : Shape} {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {before after : Flow} {items : List Statement}
    (checked : checkStatements (signatures := signatures) (procedures := procedures) shape analysis before items booleans = some after) :
    Semantics.discharge (modeledObligations (signatures := signatures) (procedures := procedures) shape analysis before items booleans) = true := by
  apply (Semantics.discharge_iff _).mpr
  intro check present
  obtain ⟨schema, member, rfl⟩ := List.mem_map.mp present
  exact (List.all_eq_true.mp (statements_obligations_discharge checked)) schema member

end Silver.Predicate
