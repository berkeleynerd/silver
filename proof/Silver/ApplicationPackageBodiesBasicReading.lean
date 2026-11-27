module

public import Silver.ApplicationPackageBodiesBasicMeaning
public import Silver.ApplicationPackageBodiesStatementModel
public import Silver.PredicateBasicStepReadings

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open ApplicationPackages Compose Predicate

/-- The package wrapper can return an ordinary inherited statement in either
its scalar assignment arm or its final dispatch arm. -/
inductive Origin
  | inherited
  | packageFunction
  | packageProcedure
  deriving DecidableEq, Repr

def selectedAssignment (calls : BasicCalls) (s : Statement.Input) : Prop :=
  assignmentFirst calls s.text s.input ≠ 0 ∧
    (calls.scalarTarget s.text s.context s.input.scan.position ≠ 0 ∨
      calls.booleanTarget s.text s.context s.input.scan.position ≠ 0)

instance (calls : BasicCalls) (s : Statement.Input) : Decidable (selectedAssignment calls s) :=
  inferInstanceAs (Decidable (_ ∧ _))

def functionCall (calls : BasicCalls) (s : Statement.Input) : ApplicationCall :=
  calls.packageCallAt s.text s.context s.input s.info (assignmentFirst calls s.text s.input) .function

def procedureCall (calls : BasicCalls) (s : Statement.Input) : ApplicationCall :=
  calls.packageCallAt s.text s.context s.input s.info s.input.scan.position .procedure

def origin (calls : BasicCalls) (s : Statement.Input) : Origin :=
  if selectedAssignment calls s then
    if (functionCall calls s).value.after ≠ 0 then .packageFunction else .inherited
  else if s.input.allowProcedureCalls &&
      decide (calls.packageCallee s.text s.context s.info s.input.scan.position .procedure ≠ 0) then
    .packageProcedure
  else .inherited

def functionScan (calls : BasicCalls) (s : Statement.Input) : BodyScan :=
  let called := functionCall calls s
  let assigned := calls.callAssignmentResult s.context
    {called.result.scan with position := s.input.scan.position}
    (calls.scalarTarget s.text s.context s.input.scan.position)
    (calls.booleanTarget s.text s.context s.input.scan.position) called.value
  calls.bodyToken s.text s.context assigned (.symbol ";")

def procedureScan (calls : BasicCalls) (s : Statement.Input) : BodyScan :=
  calls.bodyToken s.text s.context (procedureCall calls s).result.scan (.symbol ";")

private theorem mark_scan (slot : Nat) (value : ApplicationScan) :
    (if slot ≠ 0 then {value with writes := value.writes.set (slot - 1) true} else value).scan =
      value.scan := by split <;> rfl

theorem basicResult_source_scan (calls : BasicCalls) (s : Statement.Input) :
    (basicResult calls s.text s.context s.input s.info s.catalog s.procedures).scan =
      match origin calls s with
      | .inherited => calls.basicBody s.text s.context s.input.scan s.catalog s.procedures
      | .packageFunction => functionScan calls s
      | .packageProcedure => procedureScan calls s := by
  unfold basicResult origin
  by_cases assignment : selectedAssignment calls s
  · rw [ite_eq_left assignment]
    have guard := assignment
    unfold selectedAssignment at guard
    rw [ite_eq_left guard]
    dsimp only [functionAssignment]
    rw [mark_scan]
    by_cases called : (functionCall calls s).value.after ≠ 0
    · have raw : (calls.packageCallAt s.text s.context s.input s.info
          (assignmentFirst calls s.text s.input) .function).value.after ≠ 0 := called
      conv => lhs; rw [ite_eq_left raw]
      conv => rhs; rw [ite_eq_left called]
      rfl
    · have raw : ¬ (calls.packageCallAt s.text s.context s.input s.info
          (assignmentFirst calls s.text s.input) .function).value.after ≠ 0 := called
      conv => lhs; rw [ite_eq_right raw]
      conv => rhs; rw [ite_eq_right called]
  · rw [ite_eq_right assignment]
    unfold selectedAssignment at assignment
    rw [ite_eq_right assignment]
    split <;> rfl

/-- Both successful inherited paths produce the same source reading as the
existing Basic_Body, including local function/procedure calls and arrays. -/
theorem inherited_reading {calls : BasicCalls} {s : Statement.Input}
    (tv : Expressions.ValidText s.text) (nv : Expressions.ValidNames s.text s.context.names)
    (inherited : origin calls s = .inherited)
    (body : calls.basicBody s.text s.context s.input.scan s.catalog s.procedures =
      Predicate.basicBody s.text s.context s.input.scan s.catalog s.procedures)
    (accepted : (applicationBasic calls s.text s.context s.input s.info s.catalog s.procedures).scan.position ≠ 0) :
    let result := applicationBasic calls s.text s.context s.input s.info s.catalog s.procedures
    ∃ item, BasicStepAt s.text s.context s.input.scan item result.scan s.catalog s.procedures ∧
      ∀ other, BasicStepAt s.text s.context s.input.scan other result.scan s.catalog s.procedures → other = item := by
  have scan := basicResult_source_scan calls s
  rw [inherited] at scan
  have same := (congrArg ApplicationScan.scan (applicationBasic_accepted accepted).2.2).trans (scan.trans body)
  have positive := same ▸ accepted
  obtain ⟨item, read⟩ := basicStep_sound tv nv positive
  refine ⟨item, same.symm ▸ read, ?_⟩
  intro other otherRead
  exact basicStep_unique otherRead (same.symm ▸ read)

/-- Specialization of the inherited body import to its existing checked raw
parser. The remaining calls retain their full caller-supplied domains. -/
def withInheritedBody (calls : BasicCalls) : BasicCalls :=
  {calls with basicBody := fun t ctx scan fs ps => Predicate.basicBody t ctx scan fs ps}

theorem withInheritedBody_reading {calls : BasicCalls} {s : Statement.Input}
    (tv : Expressions.ValidText s.text) (nv : Expressions.ValidNames s.text s.context.names)
    (inherited : origin (withInheritedBody calls) s = .inherited)
    (accepted : (applicationBasic (withInheritedBody calls) s.text s.context s.input s.info
      s.catalog s.procedures).scan.position ≠ 0) :
    let result := applicationBasic (withInheritedBody calls) s.text s.context s.input s.info s.catalog s.procedures
    ∃ item, BasicStepAt s.text s.context s.input.scan item result.scan s.catalog s.procedures ∧
      ∀ other, BasicStepAt s.text s.context s.input.scan other result.scan s.catalog s.procedures → other = item :=
  inherited_reading tv nv inherited rfl accepted

end Silver.ApplicationPackageBodies.Basic
