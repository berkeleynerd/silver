module

public import Silver.ApplicationPackageBasicComposition
public import Silver.ApplicationPackageStatementImportsTail
public import Silver.ApplicationPackageMainRecursiveDomain

@[expose] public section

/-! The recursive reader interface is obtained from the original typed body
equations and the already-bound imported libraries. Partial primitive functions
use the same domain-preserving interpretation as PredicateBodyHelpers. Basic
imports are composed directly over their full native domain. No accepted source,
completed semantic checker or obligation-discharge premise occurs here. -/
namespace Silver.ApplicationPackageBodies.RecursiveSource
open ApplicationNative ApplicationPackages Compose Predicate Recursive

set_option backward.dsimp.instances true

structure Libraries where
  basic : BasicImports.Libraries
  lexical : Compose.Lexical.Meaning basic.inherited.inherited.primitive
  stop : StatementImports.StopLibrary basic.inherited

namespace Libraries

def statement (library : Libraries) : StatementImports.Libraries :=
  ⟨library.basic.inherited, library.lexical⟩

/-- The original recursive symbols, package effects and validity guards are
retained. The stop expression has its source-derived primitive interpretation;
its identity on every native cursor is proved separately below. -/
noncomputable def readers (library : Libraries) (other : Readers) : Readers :=
  {other with
    basic := library.basic.calls other.basic
    statement := library.statement.calls other.statement
    tail := {other.tail with atBodyStop := library.stop.interpreted}}

/-- Interpretation of imported partial primitives in the typed Statement
body. The native contracts govern their domains; extending them supplies no
new recursive function or language admission test. -/
noncomputable def imports (library : Libraries) (other : Readers) : Readers :=
  {library.readers other with statement := library.statement.interpreted other.statement}

theorem readers_recursive (library : Libraries) (other : Readers) :
    (library.readers other).statement.applicationBasic = other.statement.applicationBasic ∧
    (library.readers other).statement.applicationTail = other.statement.applicationTail ∧
    (library.readers other).tail.applicationStatement = other.tail.applicationStatement ∧
    (library.readers other).validFlow = other.validFlow ∧
    (library.readers other).validBody = other.validBody := ⟨rfl, rfl, rfl, rfl, rfl⟩

theorem readers_effects (library : Libraries) (other : Readers) :
    (library.readers other).basic.stateTarget = other.basic.stateTarget ∧
    (library.readers other).basic.stateReads = other.basic.stateReads ∧
    (library.readers other).statement.stateReads = other.statement.stateReads ∧
    (library.readers other).statement.sameName = other.statement.sameName ∧
    (library.readers other).statement.validContext = other.statement.validContext ∧
    (library.readers other).statement.validBody = other.statement.validBody :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem stop_native (library : Libraries) (other : Readers) (text : Source)
    (valid : Expressions.ValidText text) (position : Nat)
    (bounded : Expressions.ValidCursor text position) (stop : BodyStop) :
    (library.readers other).tail.atBodyStop text position stop = library.stop.call text position stop :=
  library.stop.interpreted_native text valid position bounded stop

theorem stop_meaning (library : Libraries) (other : Readers) :
    (library.readers other).tail.atBodyStop = atBodyStop := library.stop.interpreted_meaning

theorem statement_imports (library : Libraries) (other : Readers) :
    (library.imports other).statement = (SourceSyntax.sourceReaders (library.readers other)).statement :=
  library.statement.interpreted_meaning other.statement

/-- Pointwise Basic normalization on the entire original call domain. This
uses the stored native argument-name witness and package component subtypes;
it does not require Valid_Metadata or any successful parse. -/
theorem basic_imports (library : Libraries) (other : Readers) (source : Statement.Input)
    (legal : NativeDomain source) :
    Basic.body.eval (Basic.functions (library.imports other).basic) (inputLocals source) =
      Basic.body.eval (Basic.functions (SourceSyntax.sourceReaders (library.readers other)).basic)
        (inputLocals source) := by
  obtain ⟨native, same, valid⟩ := legal.context
  rcases source with ⟨text, context, input, info, catalog, procedures⟩
  dsimp only at same
  subst context
  rw [Basic.body_meaning, Basic.body_meaning]
  exact library.basic.basic_meaning other.basic text native input info catalog procedures legal valid legal.typed

end Libraries

/-- These are definition equations of the three original typed source bodies,
including their local loops, on the full native precondition. The finite fuel
witness records native termination of those loops; it is not an unrolling bound
on accepted language programs. Structural source checks bind these exact bodies
to the authoritative Output_Profile file at the enclosing source bridge.

Only original imported definitions occur on the left. The right side retains
each actual mutually recursive function, including rejected/empty results.
Primitive meanings, recursive semantic checks and safety are not premises. -/
structure Definitions (library : Libraries) (other : Readers) : Prop where
  basic : ∀ source, NativeDomain source →
    Basic.body.eval (Basic.functions (library.imports other).basic) (inputLocals source) =
      other.statement.applicationBasic source.text source.context source.input source.info source.catalog source.procedures
  statement : ∀ source, NativeDomain source → ∃ fuel,
    Statement.Native.body.eval
      (Statement.Native.functions (library.imports other).statement other.validFlow)
      (Statement.Native.procedures (library.imports other).statement) fuel (inputLocals source) =
      some (other.statementResult source)
  tail : ∀ source, NativeDomain source → ∀ stop required, ∃ fuel,
    Tail.body.eval (Tail.functions (library.imports other).tail other.validBody)
      (Statement.Native.procedures (library.imports other).statement) fuel (tailLocals source stop required) =
      some (other.tailResult source stop required)

/-- Full primitive composition closes the previously abstract recursive
interface. Its domain, all recursive call symbols, effects and rejected inputs
are unchanged. Actual source body equations are the only outer interpretation
premises; no conclusion of the semantic decoder is supplied by the caller. -/
theorem equations (library : Libraries) (other : Readers) (definitions : Definitions library other) :
    Equations (SourceSyntax.sourceReaders (library.readers other)) NativeDomain where
  basic source legal := by
    rw [← library.basic_imports other source legal]
    exact definitions.basic source legal
  statement source legal := by
    obtain ⟨fuel, original⟩ := definitions.statement source legal
    rw [library.statement_imports other] at original
    exact ⟨fuel, original⟩
  tail source legal stop required := by
    obtain ⟨fuel, original⟩ := definitions.tail source legal stop required
    rw [library.statement_imports other] at original
    exact ⟨fuel, original⟩

end Silver.ApplicationPackageBodies.RecursiveSource
