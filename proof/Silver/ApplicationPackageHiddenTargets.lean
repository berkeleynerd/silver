module

public import Silver.ApplicationPackageHiddenSource
public import Silver.ApplicationPackageProcedureTargetCells

@[expose] public section

namespace Silver.ApplicationPackageEffects
open Compose Predicate Packages

/-- A successful bare target lookup also resolves the selected row by its own
original spelling. The proof does not assume an unshadowed or duplicate-free
environment. -/
theorem scalar_lookup_original {text : Source} {context : ParseContext} {first after slot : Nat}
    (row : OriginalRow context (.integer slot))
    (found : ScalarExpression.lookup text context.scalarNames first after = slot) :
    OriginalLookup text context (.integer slot) := by
  have domain : first ≠ 0 ∧ first < after := by
    have valid : ¬(first = 0 ∨ after ≤ first) := by
      intro bad
      have absent : ScalarExpression.lookup text context.scalarNames first after = 0 := by
        unfold ScalarExpression.lookup
        cases context.scalarNames.length <;> simp [ScalarExpression.lookupFrom, bad]
      rw [found] at absent
      exact row.1 absent
    exact ⟨fun zero => valid (Or.inl zero), Nat.lt_of_not_ge (fun backwards => valid (Or.inr backwards))⟩
  exact (scalarLookup_retarget row.2.2.2.1 row.2.2.2.2 domain.1 domain.2
    (scalarLookupFrom_spelling found row.1)).trans found

theorem hidden_scalar_target {text : Source} {context : ParseContext} {slot position : Nat}
    (row : OriginalRow context (.integer slot)) (hidden : ¬OriginalLookup text context (.integer slot)) :
    scalarTarget text context position ≠ slot :=
  fun selected => hidden (scalar_lookup_original row selected)

theorem writable_integer_original {text : Source} {context : ParseContext} {slot position after : Nat}
    (row : OriginalRow context (.integer slot))
    (source : WritableNameAt text context position after (.integer slot)) :
    OriginalLookup text context (.integer slot) := by
  cases source with
  | name skipped nonzero identifier spelling =>
    cases spelling with
    | integer found _ => exact scalar_lookup_original row found

end Silver.ApplicationPackageEffects

namespace Silver.ScalarFunctions
open Predicate

theorem Target.after_other_integer {target : Target} {slot : Nat}
    (other : ScalarProcedures.targetCell target ≠ .integer slot) (domain : ScalarType) (flow : Flow) :
    (target.after domain flow).scalars slot = flow.scalars slot := by
  cases target with
  | boolean identity => rfl
  | integer identity bounds =>
    have different : slot ≠ identity := by
      intro same
      exact other (by cases same; rfl)
    cases domain <;> simp only [Target.after, Integer.put, different, ite_false]

end Silver.ScalarFunctions

namespace Silver.ScalarProcedures
open Predicate

theorem afterTargets_other_integer {targets : List ScalarFunctions.Target} {slot : Nat}
    (other : ∀ target ∈ targets, targetCell target ≠ .integer slot)
    (domains : List ScalarFunctions.ScalarType) (flow : Flow) :
    (afterTargets domains targets flow).scalars slot = flow.scalars slot := by
  induction domains generalizing targets flow with
  | nil => rfl
  | cons domain domains ih =>
    cases targets with
    | nil => rfl
    | cons target targets =>
      change (afterTargets domains targets (target.after domain flow)).scalars slot = _
      rw [ih (fun item member => other item (List.mem_cons_of_mem _ member))]
      exact target.after_other_integer (other target List.mem_cons_self) domain flow

end Silver.ScalarProcedures

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings ApplicationPackageEffects

theorem ArgumentAt.target_original {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {parameter : Formal} {row : PackageActual}
    {object : ScalarFunctions.Target} {slot : Nat}
    (source : ArgumentAt text context input parameter row (.target object))
    (accepted : row.after ≠ 0) (original : OriginalRow context.model (.integer slot))
    (hidden : ¬OriginalLookup text context.model (.integer slot)) :
    ScalarProcedures.targetCell object ≠ .integer slot := by
  cases source with
  | target _ parsed ends _ =>
    have present : (procedureTargetActual text context.model row.first input.scan.facts
        (outputFormal parameter)).after ≠ 0 := by rw [parsed, ← ends]; exact accepted
    have named := procedureTargetActual_name present
    rw [parsed] at named
    intro same
    rw [same] at named
    exact hidden (writable_integer_original original named)

theorem FormalArgumentsAt.targets_original {text : Source} {context : Predicate.Native.Context}
    {input : ApplicationScan} {info : Metadata} {frame : ActualFrame}
    {slots : List Nat} {arguments : List ScalarProcedures.Actual} {slot : Nat}
    (source : FormalArgumentsAt text context input info frame slots arguments)
    (accepted : ∀ index ∈ slots, (frame.actual index).after ≠ 0)
    (original : OriginalRow context.model (.integer slot))
    (hidden : ¬OriginalLookup text context.model (.integer slot)) :
    ∀ target ∈ ScalarProcedures.writableTargets arguments, ScalarProcedures.targetCell target ≠ .integer slot := by
  induction source with
  | nil => simp only [ScalarProcedures.writableTargets, List.not_mem_nil, false_implies, implies_true]
  | @cons index indices argument arguments head tail ih =>
    have later := ih (fun index member => accepted index (List.mem_cons_of_mem _ member))
    cases head with
    | value => exact later
    | target writable parsed ends meaning =>
      have first : ArgumentAt text context input (info.parameterAt index) (frame.actual index)
          (.target (procedureTargetIdentity context.model (frame.actual index).target)) :=
        .target writable parsed ends meaning
      intro target member
      rcases List.mem_cons.mp member with rfl | member
      · exact first.target_original (accepted index List.mem_cons_self) original hidden
      · exact later target member

end Silver.ApplicationPackageCalls
