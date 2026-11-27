module

public import Silver.ApplicationPackageCalleeImports

@[expose] public section

namespace Silver.ApplicationPackageCalls.LexicalImports
open Compose Compose.Expressions Predicate

set_option backward.dsimp.instances true

def calls (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls) :
    ApplicationPackageCalls.Calls :=
  {CalleeImports.calls imports other with
    skip := imports.composed.function .skip
    nameAfter := imports.composed.function .nameAfter
    take := imports.composed.function .takeToken}

/-- Every original formal name is compared, in the original last-match order.
No uniqueness or valid-metadata assumption is used to normalize the loop. -/
theorem namedSlot (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls)
    (text : Source) (info : PackageBindings.Metadata) (item : PackageBindings.Routine) (first after : Nat) :
    ApplicationPackageCalls.namedSlot (calls imports other) text info item first after =
      ApplicationPackageCalls.namedSlot modelCalls text info item first after := by
  unfold ApplicationPackageCalls.namedSlot
  apply congrArg (fun step => (formalSlots item).foldl step 0)
  funext slot index
  change (if imports.packages.sameName (ApplicationPackageNames.metadataText text)
      ⟨first, after⟩ (info.parameterAt index).specName then index else slot) = _
  rw [PackageBindings.Native.interpreted_sameName imports.packages
    imports.packagePrimitives imports.packageEquations]
  rfl

/-- The actual association scanner supplies bounded names even for failed or
empty names. Its optional arrow and formal-selection calls therefore consume
the full original lexical contracts without an accepted-call premise. -/
theorem association (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls)
    (text : Source) (valid : ValidText text) (info : PackageBindings.Metadata)
    (item : PackageBindings.Routine) (ordinal : Nat) (frame : ActualFrame)
    (bounded : ValidCursor text frame.cursor) :
    actualAssociation (calls imports other) text info item ordinal frame =
      actualAssociation modelCalls text info item ordinal frame := by
  let first := Compose.skipAt text frame.cursor
  let after := Compose.nameAfter text first
  have skip : imports.composed.function .skip text frame.cursor = first :=
    interpreted_skip _ imports.inherited text valid frame.cursor bounded
  have firstBound : ValidCursor text first := model_skip_valid text frame.cursor bounded
  have name : imports.composed.function .nameAfter text first = after :=
    interpreted_name _ imports.inherited text valid first firstBound
  have afterBound : ValidCursor text after := model_name_valid text first
  have arrow : imports.composed.function .takeToken text after (.symbol "=>") =
      tokenAfter text after (.symbol "=>") :=
    interpreted_take _ imports.inherited text valid after (.symbol "=>") afterBound
      (by unfold ValidToken; decide)
  unfold actualAssociation
  change (let first := imports.composed.function .skip text frame.cursor
    let after := imports.composed.function .nameAfter text first
    let arrow := imports.composed.function .takeToken text after (.symbol "=>")
    if arrow ≠ 0 then some (ApplicationPackageCalls.namedSlot (calls imports other) text info item first after, true, arrow)
    else if frame.named then none else some (item.formalFirst + ordinal - 1, frame.named, frame.cursor)) = _
  dsimp only
  rw [skip, name, arrow, namedSlot]
  rfl

/-- Adding the original lexical imports leaves the already proved callee
interpretation intact; the same complete native domain applies. -/
theorem callee (imports : ApplicationPackageEffects.Imports) (other : ApplicationPackageCalls.Calls)
    (text : Source) (valid : ValidText text) (context : ParseContext)
    (domain : ApplicationPackageEffects.LookupDomain text context)
    (info : PackageBindings.Metadata) (position : Nat) (bounded : ValidCursor text position)
    (kind : PackageBindings.RoutineKind) :
    packageCallee (calls imports other) text context info position kind =
      packageCallee modelCalls text context info position kind :=
  CalleeImports.meaning imports other text valid context domain info position bounded kind

end Silver.ApplicationPackageCalls.LexicalImports
