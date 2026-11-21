module

public import Silver.PredicateProcedureCallReadings
public import Silver.PredicateFunctionCallMeaning
public import Silver.ScalarProcedureChecking

@[expose] public section

namespace Silver.Predicate
open Compose ScalarProcedures

private theorem true_of_not_neg {value : Bool} (known : ¬(!value) = true) : value = true := by
  cases value <;> simp_all

private theorem scalarTarget_checked {context : ParseContext} {index : Nat} {bounds : Integer.Interval}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (positive : index ≠ 0) (within : index ≤ context.scalarNames.length)
    (mutable : (ScalarExpression.binding context.scalarNames index).mutable = true)
    (nonempty : bounds.isEmpty = false)
    (included : bounds.included (ScalarExpression.binding context.scalarNames index).declaredBounds = true) :
    (ScalarFunctions.Target.integer index (ScalarExpression.binding context.scalarNames index).declaredBounds).check
      context.analysis (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (.integer bounds) = true := by
  have same := ScalarExpression.bodyReady_binding base.body (Nat.pos_of_ne_zero positive) within mutable
  have mutableModel : context.analysis.mutable index = true := by
    simp only [ParseContext.analysis, ArrayViews.analysis, ArrayFlow.analysis, ArrayBindings.integerMutability,
      ArrayBindings.mutability_scalar _ _ (Nat.le_trans within base.size),
      ScalarMetadata.analysis, ScalarExpression.mutability,
      Nat.pos_of_ne_zero positive, within, and_self, decide_true, Bool.true_and, mutable]
  have declaredModel : context.analysis.declared index =
      some (ScalarExpression.binding context.scalarNames index).declaredBounds := by
    simp only [ParseContext.analysis, ArrayViews.analysis, ArrayFlow.analysis, ArrayBindings.integerRanges,
      ArrayBindings.ranges_scalar _ _ _ _ (Nat.le_trans within base.size),
      ScalarMetadata.analysis, ScalarExpression.ranges,
      Nat.pos_of_ne_zero positive, within, and_self, ↓reduceIte, same]
  simp only [ScalarFunctions.Target.check, mutableModel, declaredModel, decide_true, nonempty, included,
    Bool.not_false, Bool.and_self]

private theorem booleanTarget_writable {context : ParseContext} {index : Nat}
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (positive : index ≠ 0) (within : index ≤ context.booleanNames.length)
    (mutable : (BooleanBindings.binding context.booleanNames index).mutable = true) :
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)).canWrite index = true := by
  have scalar := ArrayBindings.booleanAnalysis_scalar context.arrayNames
    (BooleanBindings.analysis context.booleanNames) (Nat.le_trans within booleansBound)
  unfold Boolean.Analysis.canWrite
  rw [scalar.1, scalar.2]
  simp only [BooleanBindings.analysis, Nat.pos_of_ne_zero positive, within,
    and_self, decide_true, Bool.true_and, mutable]

private theorem flow_scalar_getD {context : ParseContext} {facts : ActiveFlow} {index : Nat}
    (positive : index ≠ 0) (within : index ≤ facts.count) (low : index ≤ ArrayBindings.scalarLimit) :
    (context.flow facts).scalars index = some (facts.values.getD (index - 1) Integer.Interval.empty) := by
  rw [context.flow_scalar facts low]
  have inRange : index - 1 < facts.values.length := by change index ≤ facts.values.length at within; omega
  simp only [ActiveFlow.model, ActiveFlow.ranges, positive, ↓reduceIte,
    List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inRange, Option.getD_some]

/-- The raw writable-target guard proves its full declared-domain copy-out
contract, and checks copy-in only for an in-out formal. -/
structure ProcedureTargetMeaning (context : ParseContext) (incoming : ActiveFlow)
    (parameter : ProcedureBindings.Formal) (target : ProcedureActualResult) : Prop where
  readable : (Actual.target (procedureTargetIdentity context target)).Readable context.hasArguments context.names.shape
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
  checked : (procedureTargetIdentity context target).check context.analysis
    (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
    (ProcedureBindings.formalModel parameter context.arrayTypes).domain = true
  copyIn : parameter.mode = .inputOutput →
    (targetRead (procedureTargetIdentity context target)).check context.names.shape context.analysis (context.flow incoming)
      (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (ProcedureBindings.formalModel parameter context.arrayTypes).domain = true
  changed : ∀ current : BodyScan, current.count = context.scalarNames.length →
    context.flow (procedureWritableUpdate current parameter target).facts =
      (procedureTargetIdentity context target).after (ProcedureBindings.formalModel parameter context.arrayTypes).domain (context.flow current.facts)

theorem procedureTargetActual_meaning {text context position incoming parameter}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (booleansBound : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (sameCount : incoming.count = context.scalarNames.length)
    (bodyMode : context.elaborating = false)
    (formalBounds : parameter.bounds.Bounded)
    (accepted : (procedureTargetActual text context position incoming parameter).after ≠ 0) :
    ProcedureTargetMeaning context incoming parameter (procedureTargetActual text context position incoming parameter) := by
  unfold procedureTargetActual at accepted ⊢
  dsimp only at accepted ⊢
  split at accepted
  · contradiction
  · rename_i named
    have scalarFormal : parameter.typeId = 0 :=
      Classical.not_not.mp (fun different => named (Or.inr (Or.inr different)))
    rw [ite_eq_right named]
    split at accepted
    · rename_i integerKind
      rw [ite_eq_left integerKind]
      split at accepted
      · contradiction
      · rename_i good
        rw [ite_eq_right good]
        have checks := good
        simp only [not_or] at checks
        have positive := checks.1
        have mutable := true_of_not_neg checks.2.1
        have nonempty := Bool.eq_false_iff.mpr checks.2.2.1
        have included := true_of_not_neg checks.2.2.2.1
        have within : scalarTarget text context position ≤ context.scalarNames.length := ScalarExpression.lookup_bound ..
        have low := Nat.le_trans within base.size
        refine ⟨?_, ?_, ?_, ?_⟩
        · simp only [procedureTargetIdentity, positive, ↓reduceIte, Actual.Readable,
            ScalarFunctions.Target.identity, targetRead, ScalarFunctions.Actual.Readable, and_true]
          exact positive
        · simpa only [procedureTargetIdentity, positive, ↓reduceIte, ProcedureBindings.formalModel, formalType, procedureInputFormal, scalarFormal, ne_eq, not_true_eq_false, ↓reduceIte, integerKind]
            using scalarTarget_checked base positive within mutable nonempty included
        · intro inputOutput
          have copyChecked : ¬((incoming.values.getD (scalarTarget text context position - 1) Integer.Interval.empty).isEmpty = true ∨
              (!(incoming.values.getD (scalarTarget text context position - 1) Integer.Interval.empty).included parameter.bounds) = true) :=
            fun bad => checks.2.2.2.2 ⟨inputOutput, bad⟩
          have copyNonempty := Bool.eq_false_iff.mpr (fun bad => copyChecked (Or.inl bad))
          have copyIncluded := true_of_not_neg (fun bad => copyChecked (Or.inr bad))
          have found := flow_scalar_getD (context := context) (facts := incoming) positive (by rw [sameCount]; exact within) low
          have copyOrdered :
              (incoming.values.getD (scalarTarget text context position - 1) Integer.Interval.empty).lower ≤
                (incoming.values.getD (scalarTarget text context position - 1) Integer.Interval.empty).upper := by
            have ordered := copyNonempty
            simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at ordered
            omega
          have copyBounded : (incoming.values.getD (scalarTarget text context position - 1) Integer.Interval.empty).Bounded :=
            ⟨Integer.Interval.bounded_contains formalBounds
                (Integer.Interval.included_sound copyIncluded ⟨Int.le_refl _, copyOrdered⟩),
              Integer.Interval.bounded_contains formalBounds
                (Integer.Interval.included_sound copyIncluded ⟨copyOrdered, Int.le_refl _⟩)⟩
          simp only [procedureTargetIdentity, positive, ↓reduceIte, targetRead, ScalarFunctions.Actual.check,
            ProcedureBindings.formalModel, formalType, procedureInputFormal, scalarFormal, ne_eq, not_true_eq_false, ↓reduceIte, integerKind, Integer.Expr.infer, found, Option.bind_some,
            Integer.checked, copyNonempty, Bool.false_eq_true, copyBounded, Integer.accepted,
            copyIncluded, Bool.not_false, Bool.and_self]
        · intro current count
          simp only [procedureWritableUpdate, procedureTargetIdentity, positive, ↓reduceIte,
            ProcedureBindings.formalModel, formalType, procedureInputFormal, scalarFormal, ne_eq, not_true_eq_false, ↓reduceIte, integerKind, ScalarFunctions.Target.after]
          have changed := ArrayFlow.flow_replace (ArrayBindings.viewNames context.arrayNames) current.facts
            (scalarTarget text context position) parameter.bounds (Nat.pos_of_ne_zero positive)
            (by change scalarTarget text context position ≤ current.count; rw [count]; exact within) low
          simpa only [ArrayFlow.flow, ParseContext.flow, ArrayBindings.viewRanges,
            ArrayBindings.viewElaborating, bodyMode, Bool.false_and] using changed
    · rename_i notInteger
      rw [ite_eq_right notInteger]
      split at accepted
      · contradiction
      · rename_i good
        rw [ite_eq_right good]
        have booleanKind : parameter.kind = .boolean := by cases kind : parameter.kind <;> simp_all
        have positive : booleanTarget text context position ≠ 0 := fun zero => good (Or.inl zero)
        have mutable := true_of_not_neg (fun bad => good (Or.inr bad))
        have within : booleanTarget text context position ≤ context.booleanNames.length := by
          dsimp only [booleanTarget]
          split
          · exact Nat.zero_le _
          · exact BooleanBindings.lookup_bound ..
        have writable := booleanTarget_writable booleansBound positive within mutable
        have initialized := Boolean.canWrite_initialized writable
        refine ⟨?_, ?_, ?_, ?_⟩
        · exact ⟨positive, trivial, initialized⟩
        · simpa only [procedureTargetIdentity, ↓reduceIte, ProcedureBindings.formalModel, formalType, procedureInputFormal, scalarFormal, ne_eq, not_true_eq_false, ↓reduceIte, booleanKind,
            ScalarFunctions.Target.check] using writable
        · intro _
          simpa only [procedureTargetIdentity, ↓reduceIte, ProcedureBindings.formalModel, formalType, procedureInputFormal, scalarFormal, ne_eq, not_true_eq_false, ↓reduceIte, booleanKind,
            targetRead, ScalarFunctions.Actual.check, Condition.checkBounds] using initialized
        · intro current _
          simp only [procedureWritableUpdate, procedureTargetIdentity, ↓reduceIte, ScalarFunctions.Target.after]

end Silver.Predicate
