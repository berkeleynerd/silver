module

public import Silver.ApplicationPackageActualProjection

@[expose] public section

namespace Silver.ApplicationPackageActual.Library
open Compose Compose.Expressions Predicate

theorem assignment_result (library : Library) (native : Predicate.Native.Context)
    (scan : BodyScan) (scalar flag : Nat) (value : CallResult)
    (legal : FunctionCallNative.ResultDomain native scan scalar flag value) :
    library.calls.assignmentResult native scan scalar flag value =
      Predicate.callAssignmentResult native.model scan scalar flag value := by
  classical
  have meaning := congrArg (fun fn => fn native scan scalar flag value)
    (FunctionCallNative.normalized_result library.imports_meaning library.definitions)
  simpa only [FunctionCallNative.totalizeCalls, FunctionCallNative.modelCalls, legal, ↓reduceIte] using meaning

/-- This helper has no source/context-validity precondition. Only its native
component subtypes matter, so the projection retains any original context
witness without adding a source-domain requirement. -/
noncomputable def projectedResult (library : Library) (context : ParseContext)
    (scan : BodyScan) (scalar flag : Nat) (value : CallResult) : BodyScan := by
  classical
  exact if witnessed : ∃ native : Predicate.Native.Context, native.model = context then
    library.calls.assignmentResult (Classical.choose witnessed) scan scalar flag value
  else invalidBody scan

theorem result_domain_transport {first second : Predicate.Native.Context}
    (same : first.model = second.model) (scan : BodyScan) (scalar flag : Nat) (value : CallResult)
    (legal : FunctionCallNative.ResultDomain first scan scalar flag value) :
    FunctionCallNative.ResultDomain second scan scalar flag value := by
  have scalars : first.scalarNames = second.scalarNames := congrArg ParseContext.scalarNames same
  have booleans : first.booleanNames = second.booleanNames := congrArg ParseContext.booleanNames same
  unfold FunctionCallNative.ResultDomain at legal ⊢
  rwa [scalars, booleans] at legal

theorem projected_result (library : Library) (native : Predicate.Native.Context)
    (scan : BodyScan) (scalar flag : Nat) (value : CallResult)
    (legal : FunctionCallNative.ResultDomain native scan scalar flag value) :
    library.projectedResult native.model scan scalar flag value =
      Predicate.callAssignmentResult native.model scan scalar flag value := by
  classical
  have witnessed : ∃ chosen : Predicate.Native.Context, chosen.model = native.model := ⟨native, rfl⟩
  rw [projectedResult, dite_eq_left witnessed]
  have same := Classical.choose_spec witnessed
  rw [library.assignment_result _ scan scalar flag value (result_domain_transport same.symm scan scalar flag value legal), same]

theorem projected_result_native (library : Library) (native : Predicate.Native.Context)
    (scan : BodyScan) (scalar flag : Nat) (value : CallResult)
    (legal : FunctionCallNative.ResultDomain native scan scalar flag value) :
    library.projectedResult native.model scan scalar flag value =
      library.calls.assignmentResult native scan scalar flag value :=
  (library.projected_result native scan scalar flag value legal).trans
    (library.assignment_result native scan scalar flag value legal).symm

end Silver.ApplicationPackageActual.Library
