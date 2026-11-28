module

public import Silver.ApplicationPackageStatementReading
public import Silver.ApplicationPackageBodiesBasicMeaning

@[expose] public section

/-! One operational interface for the actual mutually recursive Basic,
Statement and Tail readers. Equations mention only the checked typed native
bodies at their original inputs. The final source bridge instantiates the
domain with the native call domain and proves these equations from the same
authoritative source bindings; no semantic checker or safety assertion occurs
in this interface. -/
namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationNative ApplicationPackages Compose Predicate

structure Readers where
  basic : BasicCalls
  statement : Statement.Calls
  tail : TailCalls
  validFlow : Statement.Native.ValidFlow
  validBody : Tail.ValidBody

def inputLocals (source : Statement.Input) : Locals
  | .source, "text" => source.text
  | .parseContext, "context" => source.context
  | .appScan, "input" => source.input
  | .metadata, "info" => source.info
  | .functions, "catalog" => source.catalog
  | .procedures, "procedure_catalog" => source.procedures
  | ty, _ => ty.default

def tailLocals (source : Statement.Input) (stop : BodyStop) (required : Bool) : Locals
  | .bodyStop, "stop" => stop
  | .truth, "require_one" => required
  | ty, name => inputLocals source ty name

def tailContext (source : Statement.Input) (stop : BodyStop) (required : Bool) : Tail.Context :=
  ⟨source.text, source.context, source.info, stop, required, source.catalog, source.procedures⟩

def Readers.statementResult (readers : Readers) (source : Statement.Input) : ApplicationScan :=
  readers.tail.applicationStatement source.text source.context source.input source.info source.catalog source.procedures

def Readers.tailResult (readers : Readers) (source : Statement.Input) (stop : BodyStop) (required : Bool) : ApplicationScan :=
  readers.statement.applicationTail source.text source.context source.input source.info stop required source.catalog source.procedures

@[simp] theorem inputLocals_source (source : Statement.Input) :
    Statement.Native.source (inputLocals source) = source := by cases source; rfl

@[simp] theorem tailLocals_context (source : Statement.Input) (stop : BodyStop) (required : Bool) :
    Tail.invocation (tailLocals source stop required) = tailContext source stop required := rfl

/-- `domain` is the actual native invocation domain supplied by the source
binding. The equations retain native failure states as well as success. Fuel
only bounds the typed body's local scanner loops; no language unrolling limit
or semantic safety certificate is introduced. -/
structure Equations (readers : Readers) (domain : Statement.Input → Prop) : Prop where
  basic : ∀ source, domain source →
    Basic.body.eval (Basic.functions readers.basic) (inputLocals source) =
      readers.statement.applicationBasic source.text source.context source.input source.info source.catalog source.procedures
  statement : ∀ source, domain source → ∃ fuel,
    Statement.Native.body.eval (Statement.Native.functions readers.statement readers.validFlow)
      (Statement.Native.procedures readers.statement) fuel (inputLocals source) =
      some (readers.statementResult source)
  tail : ∀ source, domain source → ∀ stop required, ∃ fuel,
    Tail.body.eval (Tail.functions readers.tail readers.validBody)
      (Statement.Native.procedures readers.statement) fuel (tailLocals source stop required) =
      some (readers.tailResult source stop required)

theorem Equations.basic_model {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source) :
    readers.statement.applicationBasic source.text source.context source.input source.info source.catalog source.procedures =
      applicationBasic readers.basic source.text source.context source.input source.info source.catalog source.procedures := by
  have evaluated := equations.basic source legal
  rw [Basic.body_meaning] at evaluated
  exact evaluated.symm

theorem Equations.statement_model {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source) :
    ∃ fuel, Statement.statementFuel readers.statement fuel source = some (readers.statementResult source) := by
  obtain ⟨fuel, evaluated⟩ := equations.statement source legal
  rw [Statement.Native.body_meaning, inputLocals_source] at evaluated
  exact ⟨fuel, evaluated⟩

theorem Equations.tail_model {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source)
    (stop : BodyStop) (required : Bool) :
    ∃ fuel, tailFuel (Tail.reader readers.tail (tailContext source stop required)) fuel ⟨source.input, false⟩ =
      some (readers.tailResult source stop required) := by
  obtain ⟨fuel, evaluated⟩ := equations.tail source legal stop required
  rw [Tail.body_meaning, tailLocals_context] at evaluated
  exact ⟨fuel, evaluated⟩

theorem Equations.statement_reading {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source)
    (present : (readers.statementResult source).scan.position ≠ 0) :
    Statement.Reading readers.statement source (readers.statementResult source) := by
  obtain ⟨_, evaluated⟩ := equations.statement_model legal
  exact Statement.statementFuel_reading evaluated present

theorem Equations.tail_reading {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source)
    (stop : BodyStop) (required : Bool)
    (present : (readers.tailResult source stop required).scan.position ≠ 0) :
    ∃ items, Tail.Reading readers.tail (tailContext source stop required) ⟨source.input, false⟩ items
      (readers.tailResult source stop required) := by
  obtain ⟨_, evaluated⟩ := equations.tail_model legal stop required
  obtain ⟨items, read, _⟩ := Tail.tailFuel_reading evaluated present
  exact ⟨items, read⟩

theorem Equations.statement_progress {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source)
    (present : (readers.statementResult source).scan.position ≠ 0) :
    source.input.scan.position < (readers.statementResult source).scan.position := by
  have read := equations.statement_reading legal present
  generalize resultEq : readers.statementResult source = result at read present ⊢
  cases read with
  | basic =>
    rw [equations.basic_model legal] at present ⊢
    have accepted := applicationBasic_accepted present
    rw [accepted.2.2]
    exact accepted.2.1
  | conditional _ _ _ closing => exact closing.advances
  | iteration _ _ _ loop => exact loop.resultAdvances

theorem Equations.tail_progress {readers : Readers} {domain : Statement.Input → Prop}
    (equations : Equations readers domain) {source : Statement.Input} (legal : domain source)
    (stop : BodyStop) (required : Bool)
    (present : (readers.tailResult source stop required).scan.position ≠ 0) :
    source.input.scan.position ≤ (readers.tailResult source stop required).scan.position ∧
      readers.tail.atBodyStop source.text (readers.tailResult source stop required).scan.position stop = true ∧
      (required = true → source.input.scan.position < (readers.tailResult source stop required).scan.position) := by
  obtain ⟨_, evaluated⟩ := equations.tail_model legal stop required
  have accepted := tailExecution_accepted (tailFuel_sound evaluated) present
  exact ⟨accepted.1, accepted.2.1, fun needed => accepted.2.2 needed rfl⟩

end Silver.ApplicationPackageBodies.Recursive
