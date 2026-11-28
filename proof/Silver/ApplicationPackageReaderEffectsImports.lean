module

public import Silver.ApplicationPackageBranchEffects
public import Silver.ApplicationPackageRecursiveSourceImports

@[expose] public section

namespace Silver.ApplicationPackageSourceEffects.ReaderEffectsImports
open ApplicationPackageBodies ApplicationPackageBodies.Recursive
open ApplicationPackageBodies.RecursiveSource

/-- Install the three original effect-helper imports, preserving the original
recursive calls and all other native reader slots. -/
def boundReaders (effects : ApplicationPackageEffects.Imports) (other : Readers) : Readers :=
  {other with
    basic := {other.basic with
      stateTarget := ApplicationPackageEffects.stateTarget (ApplicationPackageEffects.importedCalls effects)
      stateReads := ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls effects)}
    statement := {other.statement with
      stateReads := ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls effects)}}

theorem boundReaders_recursive (effects : ApplicationPackageEffects.Imports) (other : Readers) :
    (boundReaders effects other).statement.applicationBasic = other.statement.applicationBasic ∧
    (boundReaders effects other).statement.applicationTail = other.statement.applicationTail ∧
    (boundReaders effects other).tail.applicationStatement = other.tail.applicationStatement ∧
    (boundReaders effects other).validFlow = other.validFlow ∧
    (boundReaders effects other).validBody = other.validBody ∧
    (boundReaders effects other).basic.packageCallAt = other.basic.packageCallAt :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-- Canonical recursive-library composition retains the original effect slots.
Their existing imported meanings discharge ReaderEffects on exactly the native
lookup/cursor domains; no semantic body property is an input. -/
theorem imported (library : Libraries) (effects : ApplicationPackageEffects.Imports) (other : Readers)
    (target : other.basic.stateTarget =
      ApplicationPackageEffects.stateTarget (ApplicationPackageEffects.importedCalls effects))
    (basic : other.basic.stateReads =
      ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls effects))
    (statement : other.statement.stateReads =
      ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls effects)) :
    ReaderEffects (library.readers other) where
  target text context info position valid lookup bounded := by
    rw [(library.readers_effects other).1, target]
    exact ApplicationPackageEffects.imported_target effects text valid context lookup info position bounded
  basic text context info first after valid lookup firstBound afterBound := by
    rw [(library.readers_effects other).2.1, basic]
    exact ApplicationPackageEffects.imported_reads effects text valid context lookup info first after firstBound afterBound
  statement text context info first after valid lookup firstBound afterBound := by
    rw [(library.readers_effects other).2.2.1, statement]
    exact ApplicationPackageEffects.imported_reads effects text valid context lookup info first after firstBound afterBound

/-- Literal source dictionaries need no caller-supplied helper equations after
the original imported functions have been installed. -/
theorem bound (library : Libraries) (effects : ApplicationPackageEffects.Imports) (other : Readers) :
    ReaderEffects (library.readers (boundReaders effects other)) :=
  imported library effects (boundReaders effects other) rfl rfl rfl

end Silver.ApplicationPackageSourceEffects.ReaderEffectsImports
