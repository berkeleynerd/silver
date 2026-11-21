module

public import Silver.FunctionParameterMeaning

@[expose] public section

namespace Silver.Predicate.ArrayViews

@[simp] theorem analysis_nil (base : Integer.Analysis) : analysis [] base = base := rfl

end Silver.Predicate.ArrayViews

namespace Silver.Compose
open Predicate ScalarFunctions Silver.Compose.Expressions

/-- One immutable formal view contributes its entire declared component range. -/
def parameterArrayAnalysis (view : Integer.ArrayDescriptor) (base : Integer.Analysis) : Integer.Analysis :=
  let outside (property : Nat → Bool) := fun cell => !decide (view.ContainsCell cell) && property cell
  ⟨view.bodyRanges base.declared, outside base.mutable, outside base.static, outside base.refinable⟩

theorem parameterArrayAnalysis_withIndex (view : Integer.ArrayDescriptor) (base : Integer.Analysis)
    (index : Nat) (bounds : Integer.Interval) (outside : ¬view.ContainsCell index) :
    parameterArrayAnalysis view (base.withIndex index bounds) =
      (parameterArrayAnalysis view base).withIndex index bounds := by
  unfold parameterArrayAnalysis Integer.Analysis.withIndex
  dsimp only
  congr 1 <;> funext cell <;> by_cases same : cell = index
  all_goals simp_all [Integer.ArrayDescriptor.bodyRanges, Integer.put]

theorem arrayAnalysis_withIndex (formals : List ScalarType) (slot : Nat) (base : Integer.Analysis)
    (index : Nat) (bounds : Integer.Interval) (low : index ≤ ArrayBindings.scalarLimit) :
    arrayAnalysis slot formals (base.withIndex index bounds) =
      (arrayAnalysis slot formals base).withIndex index bounds := by
  induction formals generalizing slot base with
  | nil => rfl
  | cons formal rest ih =>
      cases formal with
      | integer | boolean => exact ih slot base
      | array domain =>
          have outside : ¬(domain.formal slot).ContainsCell index := by
            intro inside
            have above := NamedArrayParameters.formal_above_scalars domain slot
            simp only [Integer.ArrayDescriptor.ContainsCell] at inside
            change index ≤ NamedArrayParameters.scalarLimit at low
            omega
          change arrayAnalysis (slot + 1) rest (parameterArrayAnalysis (domain.formal slot)
            (base.withIndex index bounds)) =
              (arrayAnalysis (slot + 1) rest (parameterArrayAnalysis (domain.formal slot) base)).withIndex index bounds
          rw [parameterArrayAnalysis_withIndex _ _ _ _ outside, ih]

theorem arrayParameterBinding_viewDescriptor (frame : ParserState) (first after typeId : Nat) :
    (arrayParameterBinding frame first after typeId).viewDescriptor =
      ((ArrayBindings.arrayType frame.arrayNames.types typeId).domain typeId).formal
        (frame.arrayNames.names.length + 1) := by
  simp [arrayParameterBinding, ArrayBindings.Binding.viewDescriptor, ArrayBindings.ArrayType.domain,
    NamedArrayParameters.Domain.formal, NamedArrayParameters.Domain.atBase,
    ArrayBindings.scalarLimit, ArrayBindings.maxElements, NamedArrayParameters.scalarLimit,
    NamedArrayParameters.maxLength]

theorem readonly_analysis_append {names : ArrayBindings.Metadata} {item : ArrayBindings.Binding}
    (base : Integer.Analysis) (kind : item.isBoolean = false) (immutable : item.mutable = false)
    (nonempty : item.componentBounds.lower ≤ item.componentBounds.upper)
    (fresh : ∀ cell, item.descriptor.ContainsCell cell →
      ArrayBindings.covers (ArrayBindings.integerNames names) cell = false)
    (static : ∀ cell, item.descriptor.ContainsCell cell → base.static cell = false) :
    ArrayFlow.analysis (names ++ [item]) base =
      parameterArrayAnalysis item.descriptor (ArrayFlow.analysis names base) := by
  have noFind (cell : Nat) (inside : item.descriptor.ContainsCell cell) :
      (ArrayBindings.integerNames names).find? (fun entry => decide (entry.descriptor.ContainsCell cell)) = none := by
    apply List.find?_eq_none.mpr
    intro entry member
    exact List.any_eq_false.mp (fresh cell inside) entry member
  have normalized : item.componentBounds.normalize = item.componentBounds := by
    simp [Integer.Interval.normalize, Integer.Interval.isEmpty, Int.not_lt.mpr nonempty]
  unfold ArrayFlow.analysis ArrayFlow.ranges parameterArrayAnalysis
  simp only [ArrayBindings.integerRanges, ArrayBindings.integerMutability,
    ArrayBindings.integerRefinability, ArrayBindings.integerNames_append_integer names kind]
  congr 1 <;> funext cell <;> by_cases inside : item.descriptor.ContainsCell cell
  · simp +instances [ArrayBindings.ranges, ArrayBindings.covers, ArrayBindings.componentRange,
      List.any_append, List.find?_append, noFind cell inside, inside, normalized,
      Integer.ArrayDescriptor.bodyRanges]
    rfl
  · have covered : ArrayBindings.covers (ArrayBindings.integerNames names ++ [item]) cell =
        ArrayBindings.covers (ArrayBindings.integerNames names) cell := by
      simp [ArrayBindings.covers, List.any_append, inside]
    simp [ArrayBindings.ranges, covered, ArrayBindings.componentRange,
      List.find?_append, inside, Integer.ArrayDescriptor.bodyRanges]
  · simp [ArrayBindings.mutability, List.find?_append, noFind cell inside, inside, immutable]
  · simp [ArrayBindings.mutability, List.find?_append, inside]
  · simp [inside, static cell inside]
  · simp [inside]
  · simp +instances [ArrayBindings.refinability, ArrayBindings.covers, List.any_append, inside]
  · simp +instances [ArrayBindings.refinability, ArrayBindings.covers, List.any_append, inside]


/-- Ordered native tables separate the newly installed view from every prior
semantic segment, including the full named component intervals. -/
theorem appendParameter_arrayAnalysis {text frame parameter}
    (valid : ValidState text frame) (typed : FunctionBindings.ValidFormal text parameter)
    (named : parameter.typeId ≠ 0)
    (accepted : (appendParameter frame parameter).position ≠ 0) (declarations : Nat) :
    ArrayViews.analysis (appendParameter frame parameter).arrayNames.names
        (functionScalarAnalysis (appendParameter frame parameter) declarations) =
      parameterArrayAnalysis
        (((ArrayBindings.arrayType frame.arrayNames.types parameter.typeId).domain parameter.typeId).formal
          (frame.arrayNames.names.length + 1))
        (ArrayViews.analysis frame.arrayNames.names (functionScalarAnalysis frame declarations)) := by
  let item := arrayParameterBinding frame parameter.first parameter.after parameter.typeId
  have step := appendParameter_array named accepted
  have nextValid := appendParameter_valid valid typed
  rw [step] at nextValid ⊢
  change ArrayViews.analysis (frame.arrayNames.names ++ [item]) (functionScalarAnalysis frame declarations) = _
  have itemValid := (nextValid.arrays.1.member_valid
    (show item ∈ frame.arrayNames.names ++ [item] from by simp)).2.1.1
  have ordered : (ArrayBindings.viewNames frame.arrayNames.names ++ [item.effective]).Pairwise
      (fun left right => left.offset + left.length ≤ right.offset) := by
    simpa only [ArrayBindings.viewNames, ArrayBindings.Env.table, List.map_append, List.map_singleton] using
      nextValid.arrays.1.viewNames_ordered
  have fresh : ∀ cell, item.effective.descriptor.ContainsCell cell →
      ArrayBindings.covers (ArrayBindings.integerNames (ArrayBindings.viewNames frame.arrayNames.names)) cell = false := by
    intro cell inside
    apply List.any_eq_false.mpr
    intro entry member
    intro found
    have contained := of_decide_eq_true found
    have effectiveMember := (ArrayBindings.mem_integerNames.mp member).1
    have separate := (List.pairwise_append.mp ordered).2.2 entry effectiveMember item.effective (by simp)
    obtain ⟨original, originalMember, same⟩ := List.mem_map.mp effectiveMember
    subst entry
    have length := ArrayBindings.binding_descriptor_length (valid.arrays.1.member_valid originalMember).2.1.1
    have effectiveLength : original.effective.descriptor.length = original.effective.length := by
      simpa only [ArrayBindings.Binding.descriptor, Integer.ArrayDescriptor.length,
        ArrayBindings.Binding.effective_bounds, ArrayBindings.Binding.effective_length] using length
    simp only [Integer.ArrayDescriptor.ContainsCell] at contained inside
    rw [effectiveLength] at contained
    dsimp only [ArrayBindings.Binding.descriptor] at contained inside
    omega
  have static : ∀ cell, item.effective.descriptor.ContainsCell cell →
      (functionScalarAnalysis frame declarations).static cell = false := by
    intro cell inside
    have above := NamedArrayParameters.formal_above_scalars
      ((ArrayBindings.arrayType frame.arrayNames.types parameter.typeId).domain parameter.typeId)
      (frame.arrayNames.names.length + 1)
    rw [ArrayBindings.Binding.effective_descriptor,
      show item.viewDescriptor = _ from arrayParameterBinding_viewDescriptor _ _ _ _] at inside
    have capacity := valid.2.2.2.2.2.1.1
    have outside : ¬(0 < cell ∧ cell ≤ (ScalarExpression.bodyEnvironment frame.scalarNames).length) := by
      simp only [Integer.ArrayDescriptor.ContainsCell] at inside
      simp only [ScalarExpression.bodyEnvironment_length]
      change frame.scalarNames.length ≤ NamedArrayParameters.scalarLimit at capacity
      omega
    simp only [functionScalarAnalysis, ScalarMetadata.analysis, ScalarMetadata.staticness,
      outside, decide_false, Bool.false_and]
  have result := readonly_analysis_append (names := ArrayBindings.viewNames frame.arrayNames.names)
    (item := item.effective) (functionScalarAnalysis frame declarations)
    (by simp [item, arrayParameterBinding]) (by simp [item, arrayParameterBinding])
    (by simpa only [ArrayBindings.Binding.effective_componentBounds] using itemValid.2.2.2.2.2.2)
    fresh static
  simpa only [ArrayViews.analysis, ArrayBindings.viewNames, List.map_append, List.map_singleton,
    ArrayBindings.Binding.effective_descriptor, item, arrayParameterBinding_viewDescriptor] using result

/-- Mixed formal installation agrees with the semantic array pass followed by
the scalar pass. The native validity predicate retains its complete domain. -/
theorem ParameterFramesAt.arrayAnalysis {text frame index final}
    (source : ParameterFramesAt frame index final) (valid : ValidState text frame)
    (positive : 0 < index) (declarations : Nat) (count : declarations ≤ frame.scalarNames.length) :
    ArrayViews.analysis final.arrayNames.names (functionScalarAnalysis final declarations) =
      parameterAnalysis frame.scalarNames.length
        (formalTypes frame.functions index (frame.functions.parameters.length + 1 - index) frame.arrayNames.types)
        (ScalarFunctions.arrayAnalysis (frame.arrayNames.names.length + 1)
          (formalTypes frame.functions index (frame.functions.parameters.length + 1 - index) frame.arrayNames.types)
          (ArrayViews.analysis frame.arrayNames.names (functionScalarAnalysis frame declarations))) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.functions.parameters.length + 1 - index = 0 := by omega
      simp only [empty, formalTypes, parameterAnalysis, ScalarFunctions.arrayAnalysis]
  | @next before final index _ more accepted _ rest ih =>
      have typed := valid.functions.2.2.1 _ (FunctionBindings.parameter_mem positive more)
      have nextValid := appendParameter_valid valid typed
      have grows := (appendParameter_scalar_count_or_rejected before
        (FunctionBindings.parameter before.functions index)).resolve_left accepted
      have tail := ih nextValid (by omega) (Nat.le_trans count grows)
      have remaining : before.functions.parameters.length + 1 - index =
          (before.functions.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, formalTypes]
      by_cases named : (FunctionBindings.parameter before.functions index).typeId ≠ 0
      · have step := appendParameter_array named accepted
        have analysis := appendParameter_arrayAnalysis valid typed named accepted declarations
        rw [analysis] at tail
        rw [step] at tail
        simpa only [formalType, ite_eq_left named, parameterAnalysis, ScalarFunctions.arrayAnalysis,
          List.length_append, List.length_singleton, Nat.add_assoc, parameterArrayAnalysis] using tail
      · cases kind : (FunctionBindings.parameter before.functions index).kind with
        | integer =>
            have space : before.scalarNames.length ≠ ScalarExpression.maxBindings := by
              intro full
              simp [appendParameter, named, kind, full, invalidState] at accepted
            have step : appendParameter before (FunctionBindings.parameter before.functions index) =
                {before with scalarNames := before.scalarNames ++
                  [integerFormalBinding (FunctionBindings.parameter before.functions index)]} := by
              simp [appendParameter, named, kind, space, integerFormalBinding]
            have low : before.scalarNames.length + 1 ≤ ArrayBindings.scalarLimit := by
              have capacity := valid.2.2.2.2.2.1.1
              change before.scalarNames.length ≤ ArrayBindings.scalarLimit at capacity
              change before.scalarNames.length ≠ ArrayBindings.scalarLimit at space
              omega
            rw [step] at tail
            rw [functionScalarAnalysis_integer before _ declarations count,
              ArrayViews.analysis_withIndex _ _ _ _ low, arrayAnalysis_withIndex _ _ _ _ _ low] at tail
            simpa only [formalType, named, ↓reduceIte, kind, parameterAnalysis, ScalarFunctions.arrayAnalysis,
              List.length_append, List.length_singleton] using tail
        | boolean =>
            have space : before.booleanNames.length ≠ BooleanBindings.maxBindings := by
              intro full
              simp [appendParameter, named, kind, full, invalidState] at accepted
            have step : appendParameter before (FunctionBindings.parameter before.functions index) =
                {before with booleanNames := before.booleanNames ++
                  [⟨(FunctionBindings.parameter before.functions index).first,
                    (FunctionBindings.parameter before.functions index).after, false⟩]} := by
              simp [appendParameter, named, kind, space]
            rw [step] at tail
            simpa only [formalType, named, ↓reduceIte, kind, parameterAnalysis, ScalarFunctions.arrayAnalysis,
              functionScalarAnalysis] using tail


theorem appendParameter_scalar_arrayNames {frame parameter}
    (scalar : parameter.typeId = 0)
    (accepted : (appendParameter frame parameter).position ≠ 0) :
    (appendParameter frame parameter).arrayNames = frame.arrayNames := by
  simp only [appendParameter, scalar, ne_eq, not_true_eq_false, ↓reduceIte] at accepted ⊢
  split
  · split
    · simp_all [invalidState]
    · rfl
  · split
    · simp_all [invalidState]
    · rfl

/-- Exact nominal identities and symbolic descriptors of the installed suffix. -/
theorem ParameterFramesAt.arrayDescriptors {frame index final}
    (source : ParameterFramesAt frame index final) :
    final.arrayNames.names.map (fun item => (item.typeId, item.viewDescriptor)) =
      frame.arrayNames.names.map (fun item => (item.typeId, item.viewDescriptor)) ++
        formalArrays (frame.arrayNames.names.length + 1)
          (formalTypes frame.functions index (frame.functions.parameters.length + 1 - index) frame.arrayNames.types) := by
  induction source with
  | @done before index _ stopped =>
      have empty : before.functions.parameters.length + 1 - index = 0 := by omega
      simp only [empty, formalTypes, formalArrays, List.append_nil]
  | @next before final index _ more accepted _ rest ih =>
      have remaining : before.functions.parameters.length + 1 - index =
          (before.functions.parameters.length + 1 - (index + 1)) + 1 := by omega
      rw [remaining, formalTypes]
      by_cases named : (FunctionBindings.parameter before.functions index).typeId ≠ 0
      · rw [appendParameter_array named accepted] at ih
        simp only [List.map_append, List.map_singleton] at ih
        rw [arrayParameterBinding_viewDescriptor] at ih
        simpa only [formalType, ite_eq_left named, formalArrays, List.length_append,
          List.length_singleton,
          ArrayBindings.ArrayType.domain, List.append_assoc, List.singleton_append,
          arrayParameterBinding, Nat.add_assoc] using ih
      · have fields := (appendParameter_fields_or_rejected before
          (FunctionBindings.parameter before.functions index)).resolve_left accepted
        have arrays := appendParameter_scalar_arrayNames (by omega) accepted
        rw [arrays] at ih
        have functions : (appendParameter before (FunctionBindings.parameter before.functions index)).functions =
            before.functions := by rw [fields]
        rw [functions] at ih
        cases kind : (FunctionBindings.parameter before.functions index).kind <;>
          simpa only [formalType, named, ↓reduceIte, kind, formalArrays] using ih

/-- Array formals are immutable Integer views; scalar installation cannot add a
Boolean array or physical pool binding. -/
theorem ParameterFramesAt.arrayViewKinds {frame index final}
    (source : ParameterFramesAt frame index final)
    (initial : ∀ item ∈ frame.arrayNames.names, item.isBoolean = false ∧ item.viewSlot ≠ 0) :
    ∀ item ∈ final.arrayNames.names, item.isBoolean = false ∧ item.viewSlot ≠ 0 := by
  induction source with
  | done => exact initial
  | @next before final index _ _ accepted _ _ ih =>
      apply ih
      by_cases named : (FunctionBindings.parameter before.functions index).typeId ≠ 0
      · rw [appendParameter_array named accepted]
        intro item member
        rcases List.mem_append.mp member with old | fresh
        · exact initial item old
        · have same := List.mem_singleton.mp fresh
          subst item
          simp [arrayParameterBinding]
      · rw [appendParameter_scalar_arrayNames (by omega) accepted]
        exact initial

end Silver.Compose
