module

public import Silver.ApplicationPackageEffectsImports
public import Silver.ApplicationPackageCallsImports
public import Silver.ApplicationPackageCalleeSource

@[expose] public section

namespace Silver.ApplicationPackageCalls.CalleeImports
open Compose Compose.Expressions Predicate

set_option backward.dsimp.instances true

/-- The original callee imports share the already source-interpreted scalar,
Boolean and package libraries. Remaining call primitives retain their actual
dictionary entries until their own call-site domains are composed. -/
def calls (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls) :
    ApplicationPackageCalls.Calls :=
  {other with
    reference := imports.scalars.readReference
    scalarLookup := fun text names first after => imports.scalars.lookup text names first after
    booleanLookup := imports.booleans.lookup
    sameName := fun text left right => imports.packages.sameName (ApplicationPackageNames.metadataText text) left right
    lookupRoutine := fun text info name completedOnly =>
      imports.packages.lookupRoutine (ApplicationPackageNames.metadataText text) info name completedOnly}

theorem meaning (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : ApplicationPackageEffects.LookupDomain text context)
    (info : PackageBindings.Metadata) (position : Nat) (bounded : ValidCursor text position)
    (kind : PackageBindings.RoutineKind) :
    packageCallee (calls imports other) text context info position kind =
      packageCallee modelCalls text context info position kind := by
  have reference : imports.scalars.readReference text position = QualifiedNames.read text position :=
    ScalarExpression.SourceBridge.interpreted_readReference
      imports.scalars imports.scalarSource text valid position bounded
  have span := (QualifiedNames.read_bounds text position bounded).1
  have firstBound : (QualifiedNames.read text position).first ≤ text.length + 1 := by
    rcases span with zero | named
    · omega
    · omega
  have afterBound := QualifiedNames.read_after_bound text position bounded
  have scalar := ScalarExpression.SourceBridge.interpreted_lookup imports.scalars imports.scalarSource
    text valid context.scalarNames domain.scalars _ _ firstBound afterBound
  have boolean := imports.booleans.lookup_meaning text valid context.booleanNames domain.booleans
    _ _ firstBound afterBound
  have name := PackageBindings.Native.interpreted_sameName imports.packages
    imports.packagePrimitives imports.packageEquations (ApplicationPackageNames.metadataText text)
    ⟨(QualifiedNames.read text position).qualifierFirst, (QualifiedNames.read text position).qualifierAfter⟩
    ⟨info.nameFirst, info.nameAfter⟩
  unfold packageCallee
  dsimp only [calls, modelCalls]
  rw [reference]
  change (let reference := QualifiedNames.read text position; _) = _
  dsimp only
  by_cases unavailable : info.completed > info.routines.length ∨ (QualifiedNames.read text position).after = 0
  · simp only [unavailable, ↓reduceIte]
  · simp only [unavailable, ↓reduceIte]
    have available : info.completed ≤ info.routines.length := by omega
    have lookup := (PackageBindings.SourceBridge.executable_lookups imports.packages
      imports.packagePrimitives imports.packageEquations (ApplicationPackageNames.metadataText text) info
      ⟨(QualifiedNames.read text position).first, (QualifiedNames.read text position).after⟩).2.2 true available
    rw [scalar, boolean, name, lookup]

/-- Original typed Callee execution, including arbitrary scratch locals and
invalid metadata. Its own completion-prefix guard establishes Lookup_Routine's
precondition; no Valid_Metadata or final-library premise is introduced. -/
theorem native_meaning (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls)
    (locals : ApplicationNative.Locals)
    (valid : ValidText (locals .source "text"))
    (context : ApplicationPackageEffects.LookupDomain (locals .source "text") (locals .parseContext "context"))
    (bounded : ValidCursor (locals .source "text") (locals .number "position")) :
    Native.calleeBody.eval (Native.imported (calls imports other)) locals =
      packageCallee modelCalls (locals .source "text") (locals .parseContext "context")
        (locals .metadata "info") (locals .number "position") (locals .routineKind "kind") := by
  rw [Native.callee_denotation]
  exact meaning imports other _ valid _ context _ _ bounded _

end Silver.ApplicationPackageCalls.CalleeImports
