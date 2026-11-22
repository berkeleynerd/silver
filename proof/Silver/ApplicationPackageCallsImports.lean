module

public import Silver.ApplicationPackageCallsSemantics
public import Silver.ApplicationPackageEffectsModel
public import Silver.PredicateConditionFlowValidity

@[expose] public section

/-! Concrete imported readers for the package-call equation. The executable
flow/body guards retain all native active-cell cases, including immutable suffix
and empty intervals. Metadata validity is not a prerequisite of these guards. -/
namespace Silver.ApplicationPackageCalls
open Compose Predicate

def includedCheck (value bounds : Integer.Interval) : Bool :=
  value.isEmpty || (!bounds.isEmpty && decide (value.lower ≥ bounds.lower) &&
    decide (value.upper ≤ bounds.upper))

theorem includedCheck_model (value bounds : Integer.Interval) :
    includedCheck value bounds = value.included bounds := by
  apply Bool.eq_iff_iff.mpr
  simp only [includedCheck, Integer.Interval.included, Integer.Interval.isEmpty,
    Bool.or_eq_true, Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq,
    decide_eq_false_iff_not]
  omega

def flowCellCheck (context : ParseContext) (facts : ActiveFlow) (index : Nat) : Bool :=
  let item := ScalarExpression.binding context.scalarNames index
  let value := facts.values.getD (index - 1) .empty
  if item.mutable then !value.isEmpty && includedCheck value item.declaredBounds
  else if index > context.declarationCount then includedCheck value item.bounds
  else decide (value = item.bounds)

def flowValidCheck (context : ParseContext) (facts : ActiveFlow) : Bool :=
  decide (facts.count = context.scalarNames.length) &&
    (List.range facts.values.length).all (fun index => flowCellCheck context facts (index + 1))

def bodyValidCheck (text : Source) (context : ParseContext) (scan : BodyScan) : Bool :=
  decide (scan.position ≤ text.length + 1) && decide (scan.target ≤ context.names.length) &&
    flowValidCheck context scan.facts

theorem flowValidCheck_meaning (context : ParseContext) (facts : ActiveFlow) :
    flowValidCheck context facts = true ↔ facts.count = context.scalarNames.length ∧
      ∀ index, 0 < index → index ≤ facts.count → flowCellCheck context facts index = true := by
  simp only [flowValidCheck, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, List.mem_range]
  constructor
  · rintro ⟨count, cells⟩
    refine ⟨count, ?_⟩
    intro index positive bounded
    have found := cells (index - 1) (by change index ≤ facts.values.length at bounded; omega)
    simpa only [Nat.sub_add_cancel positive] using found
  · rintro ⟨count, cells⟩
    refine ⟨count, ?_⟩
    intro index bounded
    exact cells (index + 1) (by omega) (by change index + 1 ≤ facts.values.length; omega)

theorem bodyValidCheck_meaning (text : Source) (context : ParseContext) (scan : BodyScan) :
    bodyValidCheck text context scan = true ↔ scan.position ≤ text.length + 1 ∧
      scan.target ≤ context.names.length ∧ flowValidCheck context scan.facts = true := by
  simp only [bodyValidCheck, Bool.and_eq_true, decide_eq_true_eq, and_assoc]

def modelCalls : Calls where
  reference := QualifiedNames.read
  scalarLookup text names first after := ScalarExpression.lookup text names first after
  booleanLookup text names first after := BooleanBindings.lookup text names first after
  sameName text left right := PackageBindings.sameName (ApplicationPackageNames.metadataText text) left right
  lookupRoutine text info name completedOnly :=
    PackageBindings.lookupRoutine (ApplicationPackageNames.metadataText text) info name completedOnly
  take := tokenAfter
  skip := skipAt
  nameAfter := Compose.nameAfter
  actualAfter := Predicate.actualAfter
  targetActual := procedureTargetActual
  stateTarget := ApplicationPackageEffects.stateTarget ApplicationPackageEffects.modelCalls
  stateReads := ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls
  actualNameFree := actualNameFree
  visibleState := ApplicationPackageEffects.visibleState ApplicationPackageEffects.modelCalls
  validBody := bodyValidCheck

/-- The zero-error postcondition check is the same predicate for every caller;
no final-metadata or valid-callee assumption is built into the imported model. -/
theorem model_validBody (text : Source) (context : ParseContext) (scan : BodyScan) :
    modelCalls.validBody text context scan = true ↔ scan.position ≤ text.length + 1 ∧
      scan.target ≤ context.names.length ∧ flowValidCheck context scan.facts = true :=
  bodyValidCheck_meaning text context scan

end Silver.ApplicationPackageCalls
