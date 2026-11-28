module

public import Silver.ApplicationPackageSourceFunctionCalls
public import Silver.ApplicationPackageBodiesBasicReading
public import Silver.PredicateBasicReadings

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages

set_option backward.dsimp.instances true

def callResultDomain (value : CallResult) : ScalarFunctions.ScalarType :=
  match value.kind with
  | .integer => .integer value.bounds
  | .boolean => .boolean

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

/-- The assignment worker checks the declared target, independently of how
the already accepted function result was obtained. Its flow update uses the
complete incoming expression frame, including Main's existing array views. -/
theorem assignment_result_checks {text : Source} {context : ParseContext}
    {scan : BodyScan} {value : CallResult}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (count : scan.count = context.scalarNames.length) (bodyMode : context.elaborating = false)
    (accepted : (callAssignmentResult context scan (scalarTarget text context scan.position)
      (booleanTarget text context scan.position) value).position ≠ 0) :
    let target := functionAssignmentTarget text context scan
    target.identity ≠ 0 ∧
      target.check context.analysis
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (callResultDomain value) = true ∧
      target.after (callResultDomain value) (context.flow scan.facts) =
        context.flow (callAssignmentResult context scan (scalarTarget text context scan.position)
          (booleanTarget text context scan.position) value).facts := by
  unfold callAssignmentResult at accepted ⊢
  split at accepted
  · exact False.elim (accepted rfl)
  · rename_i advance
    rw [ite_eq_right advance]
    split at accepted
    · rename_i nonzero
      rw [ite_eq_left nonzero]
      dsimp only at accepted ⊢
      split at accepted
      · exact False.elim (accepted rfl)
      · rename_i good
        rw [ite_eq_right good]
        have kind : value.kind = .integer := Classical.not_not.mp (fun bad => good (Or.inl bad))
        have within : scalarTarget text context scan.position ≤ context.scalarNames.length :=
          ScalarExpression.lookup_bound ..
        have mutable : (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).mutable = true :=
          true_of_not_neg (fun bad => good (Or.inr (Or.inl bad)))
        have nonempty : value.bounds.isEmpty = false :=
          Bool.eq_false_iff.mpr (fun bad => good (Or.inr (Or.inr (Or.inl bad))))
        have included : value.bounds.included
            (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds = true :=
          true_of_not_neg (fun bad => good (Or.inr (Or.inr (Or.inr bad))))
        have same := ScalarExpression.bodyReady_binding base.body (Nat.pos_of_ne_zero nonzero) within mutable
        have mutableModel : context.analysis.mutable (scalarTarget text context scan.position) = true := by
          simp only [ParseContext.analysis, ArrayViews.analysis, ArrayFlow.analysis, ArrayBindings.integerMutability,
            ArrayBindings.mutability_scalar _ _ (Nat.le_trans within base.size),
            ScalarMetadata.analysis, ScalarExpression.mutability,
            Nat.pos_of_ne_zero nonzero, within, and_self, decide_true, Bool.true_and, mutable]
        have declaredModel : context.analysis.declared (scalarTarget text context scan.position) =
            some (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds := by
          simp only [ParseContext.analysis, ArrayViews.analysis, ArrayFlow.analysis, ArrayBindings.integerRanges,
            ArrayBindings.ranges_scalar _ _ _ _ (Nat.le_trans within base.size),
            ScalarMetadata.analysis, ScalarExpression.ranges,
            Nat.pos_of_ne_zero nonzero, within, and_self, ↓reduceIte, same]
        have target : functionAssignmentTarget text context scan =
            .integer (scalarTarget text context scan.position)
              (ScalarExpression.binding context.scalarNames (scalarTarget text context scan.position)).declaredBounds := by
          unfold functionAssignmentTarget
          exact ite_eq_left nonzero
        dsimp only
        rw [target]
        simp only [callResultDomain, kind, ScalarFunctions.Target.identity]
        refine ⟨nonzero, ?_, ?_⟩
        · simp only [ScalarFunctions.Target.check, mutableModel, declaredModel, decide_true,
            nonempty, included, Bool.not_false, Bool.and_self]
        · change {context.flow scan.facts with
              scalars := Integer.put (context.flow scan.facts).scalars (scalarTarget text context scan.position) (some value.bounds)} = _
          have changed := ArrayFlow.flow_replace (ArrayBindings.viewNames context.arrayNames) scan.facts
            (scalarTarget text context scan.position) value.bounds (Nat.pos_of_ne_zero nonzero)
            (by change scalarTarget text context scan.position ≤ scan.count; rw [count]; exact within)
            (Nat.le_trans within base.size)
          simpa only [ArrayFlow.flow, ParseContext.flow, ArrayBindings.viewRanges,
            ArrayBindings.viewElaborating, bodyMode, Bool.false_and] using changed.symm
    · rename_i noScalar
      rw [ite_eq_right noScalar]
      split at accepted
      · rename_i good
        rw [ite_eq_left good]
        have within : booleanTarget text context scan.position ≤ context.booleanNames.length := by
          unfold booleanTarget
          dsimp only
          split
          · exact Nat.zero_le _
          · exact BooleanBindings.lookup_bound ..
        have scalar := ArrayBindings.booleanAnalysis_scalar context.arrayNames
          (BooleanBindings.analysis context.booleanNames) (Nat.le_trans within booleansBound)
        have writable : (ArrayBindings.booleanAnalysis context.arrayNames
            (BooleanBindings.analysis context.booleanNames)).canWrite (booleanTarget text context scan.position) = true := by
          unfold Boolean.Analysis.canWrite
          rw [scalar.1, scalar.2]
          simp only [BooleanBindings.analysis, Nat.pos_of_ne_zero good.1, within,
            and_self, decide_true, Bool.true_and, good.2.1]
        have target : functionAssignmentTarget text context scan =
            .boolean (booleanTarget text context scan.position) := by
          unfold functionAssignmentTarget
          exact ite_eq_right noScalar
        dsimp only
        rw [target]
        change booleanTarget text context scan.position ≠ 0 ∧ _
        refine ⟨good.1, ?_, ?_⟩
        · simpa only [callResultDomain, good.2.2, ScalarFunctions.Target.check] using writable
        · rfl
      · exact False.elim (accepted rfl)

end Silver.ApplicationPackageBodies.Basic
