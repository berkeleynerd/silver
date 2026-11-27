module

public import Silver.ApplicationPackageActualProjection
public import Silver.ApplicationPackageMainFlowImports
public import Silver.ApplicationPackageEffectsImports
public import Silver.ApplicationPackageBodiesCompletion

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackageBodies

structure LeafLibraries where
  flow : ApplicationPackageMain.FlowLibraries
  effects : ApplicationPackageEffects.Imports
  returns : ApplicationPackageActual.ReturnLibrary

namespace LeafLibraries

def flowContext (context : ParseContext) : FlowSourceBridge.Context :=
  ⟨FlowSourceBridge.ofNames context.scalarNames, context.declarationCount,
    if context.hasArguments then 1 else 0⟩

def initialFlow (library : LeafLibraries) (context : ParseContext) : ActiveFlow :=
  (library.flow.initial (flowContext context)).active

theorem initial_meaning (library : LeafLibraries) (context : ParseContext)
    (bounded : context.scalarNames.length ≤ ScalarExpression.maxBindings) :
    library.initialFlow context = ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments) := by
  have legal : (flowContext context).InRange := bounded
  rw [initialFlow, FlowSourceBridge.interpreted_initial library.flow.flow library.flow.meaning
    library.flow.initial library.flow.initialSource _ legal]
  dsimp +instances only [flowContext]
  simp only [FlowSourceBridge.ofNames_active]
  have path (arguments : Bool) :
      FlowSourceBridge.initialPath (decide ((if arguments then (1 : Nat) else 0) ≠ 0)) = initialFacts arguments := by
    cases arguments <;> rfl
  rw [path]

/-- The projected Initial_Flow agrees with the original native call for every
native context with an in-range scalar table, including inactive storage. -/
theorem initial_native (library : LeafLibraries) (context : Predicate.Native.Context)
    (bounded : context.scalarNames.length ≤ ScalarExpression.maxBindings) :
    library.initialFlow context.model = Adapter.Environment.initialCall library.flow.initial context := by
  rw [library.initial_meaning context.model bounded,
    Adapter.Environment.initialCall_interpreted library.flow.flow library.flow.meaning
      library.flow.initial library.flow.initialSource context bounded]
  rfl

noncomputable def calls (library : LeafLibraries) (other : CompletionCalls) : CompletionCalls :=
  {other with
    contextOf := fun scan => (library.flow.context scan).model
    bodyOf := library.flow.wrappers.bodyOf
    initialFlow := library.initialFlow
    stateReads := ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls library.effects)
    actualAfter := library.returns.actual.projected
    functionReturnAfter := library.returns.projected}

def model (other : CompletionCalls) : CompletionCalls :=
  {other with
    contextOf := Predicate.contextOf
    bodyOf := Predicate.bodyOf
    initialFlow := fun context => ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments)
    stateReads := ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls
    actualAfter := Predicate.actualAfter
    functionReturnAfter := Compose.functionReturnAfter}

theorem state_reads (library : LeafLibraries) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (info : PackageBindings.Metadata) (first after : Nat)
    (firstBound : ValidCursor text first) (afterBound : ValidCursor text after) :
    ApplicationPackageEffects.stateReads (ApplicationPackageEffects.importedCalls library.effects)
      text native.model info first after =
    ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls text native.model info first after :=
  ApplicationPackageEffects.imported_reads library.effects text valid native.model
    (ApplicationPackageEffects.LookupDomain.of_native contextValid) info first after firstBound afterBound

end LeafLibraries
end Silver.ApplicationPackageCompletion
