module

public import Silver.ComposeBooleanArrayDeclarations
public import Silver.ComposeArrayElaboration

@[expose] public section

/-! Boolean aggregate parsing reserves cells in the shared native initialization
table. These zero placeholders preserve its storage invariant; Boolean values
and their initializer obligations are recovered separately from the source. -/
namespace Silver.Compose
open Expressions

theorem booleanArrayValuesModel_canonical (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0)
    (canonical : result.arrayNames.values.length = result.arrayNames.used) :
    (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).arrayNames.values =
      result.arrayNames.values ++ List.replicate (length - parsed) 0 := by
  rw [booleanArrayValuesModel] at positive ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
  · simp only [zero, ↓reduceIte] at positive ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at positive ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
      · simp only [bad, ↓reduceIte] at positive ⊢
        have append : ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) 0 =
            result.arrayNames.values ++ [0] := by
          rw [← canonical, ArrayBindings.putInitial_append]
        have nextCanonical : (ArrayBindings.putInitial result.arrayNames.values (result.arrayNames.used + 1) 0).length =
            result.arrayNames.used + 1 := by simp only [append, List.length_append, List.length_singleton, canonical]
        rw [booleanArrayValuesModel_canonical text source _ _ length (parsed + 1) maskFirst maskAfter positive nextCanonical]
        dsimp only
        rw [append, List.append_assoc]
        have count : length - parsed = (length - (parsed + 1)) + 1 := by omega
        rw [count, List.replicate_succ]
        rfl
    · simp only [remaining, ↓reduceDIte]
      rw [Nat.sub_eq_zero_of_le (Nat.le_of_not_gt remaining)]
      simp only [List.replicate_zero, List.append_nil]
termination_by length - parsed
decreasing_by omega

theorem booleanArrayValuesModel_initials_valid (text : Source) (source result : ParserState)
    (position length parsed maskFirst maskAfter : Nat)
    (positive : (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).position ≠ 0)
    (valid : ArrayBindings.ValidInitials result.arrayNames.values)
    (capacity : result.arrayNames.used + (length - parsed) ≤ ArrayBindings.maxElements) :
    ArrayBindings.ValidInitials
      (booleanArrayValuesModel text source result position length parsed maskFirst maskAfter).arrayNames.values := by
  rw [booleanArrayValuesModel] at positive ⊢
  by_cases zero : position = 0
  · simp only [zero, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
  · simp only [zero, ↓reduceIte] at positive ⊢
    by_cases remaining : parsed < length
    · simp only [remaining, ↓reduceDIte] at positive ⊢
      by_cases bad : booleanInitializerAfter text source position maskFirst maskAfter = 0
      · simp only [bad, ↓reduceIte, invalidState, ne_eq, not_true_eq_false] at positive
      · simp only [bad, ↓reduceIte] at positive ⊢
        apply booleanArrayValuesModel_initials_valid text source _ _ length (parsed + 1) maskFirst maskAfter positive
        · exact putInitial_valid valid (by omega) (by decide +kernel)
        · dsimp only; omega
    · simpa only [remaining, ↓reduceDIte] using valid
termination_by length - parsed
decreasing_by omega

theorem boolean_array_declaration_binding_valid {text arguments state parts lower upper}
    (partsEq : arrayDeclarationParts text state = parts)
    (ready : BooleanArrayDeclarationReady text state arguments parts)
    (low : ScalarExpression.At text state.scalarNames (fixedAfter text parts.arrayAfter "(" false) lower parts.lower
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true))
    (high : ScalarExpression.At text state.scalarNames (fixedAfter text parts.lower.after ".." false) upper parts.upper
      (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true)) :
    ArrayBindings.ValidBinding (parts.binding state) := by
  have component : parts.componentBounds = Integer.Interval.full := by
    rw [← partsEq]
    exact arrayParts_boolean_components (partsEq.symm ▸ ready.kind)
  rcases ready with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, ordered, capacity, _, _, _, _, _, _⟩
  have lowSafe := (Integer.Expr.infer_bounded low.inferred).1
  have highSafe := (Integer.Expr.infer_bounded high.inferred).1
  simp only [ArrayBindings.ValidBinding, ArrayDeclarationParts.binding, ArrayDeclarationParts.length, component]
  exact ⟨⟨lowSafe, highSafe⟩, ordered, by omega, by omega, by omega,
    by decide +kernel, by decide +kernel⟩

theorem boolean_array_declaration_array_valid {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final)
    (valid : ArrayBindings.ValidEnvironment text state.arrayNames) :
    ArrayBindings.ValidEnvironment text final.arrayNames := by
  cases reading with
  | @declaration values parts lower upper position following partsEq ready low high _ valuesEq positive _ _ =>
      have bindingValid := boolean_array_declaration_binding_valid partsEq ready low high
      have fields := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after
        (valuesEq.symm ▸ positive)
      rw [valuesEq] at fields
      have metadata : values.arrayNames.names = state.arrayNames.names := congrArg (fun s => s.arrayNames.names) fields
      have used : values.arrayNames.used = state.arrayNames.used + parts.length := by
        simpa only [valuesEq, Nat.sub_zero] using booleanArrayValuesModel_used text state state position parts.length 0
          parts.first parts.after (valuesEq.symm ▸ positive)
      have capacity : state.arrayNames.used + parts.length ≤ ArrayBindings.maxElements := bindingValid.2.2.2.1
      have initials : ArrayBindings.ValidInitials values.arrayNames.values := by
        simpa only [valuesEq] using booleanArrayValuesModel_initials_valid text state state position parts.length 0
          parts.first parts.after (valuesEq.symm ▸ positive) valid.2.2.1 (by simpa only [Nat.sub_zero] using capacity)
      have nameBound : parts.after ≤ text.length + 1 := by
        rw [← partsEq]
        exact model_name_valid text _
      have allowed := ready.1
      simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
      have room : state.arrayNames.names.length < ArrayBindings.maxBindings := by
        have available := ready.2.2.2.2.1
        have bounded := valid.1.1
        omega
      refine ⟨⟨?_, ?_, ?_⟩, ?_, initials, ?_⟩
      · dsimp only
        rw [metadata, List.length_append, List.length_singleton]
        omega
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with member | rfl
        · exact valid.1.2.1 item (metadata ▸ member)
        · exact ⟨by change 0 < parts.first; omega, by change parts.first < parts.after; omega, nameBound, bindingValid⟩
      · dsimp only
        rw [metadata, List.pairwise_append]
        refine ⟨valid.1.2.2, by simp, ?_⟩
        intro left member right last
        have same := List.mem_singleton.mp last
        subst right
        exact valid.2.2.2 left member
      · dsimp only; rw [used]; exact capacity
      · intro item member
        simp only [List.mem_append, List.mem_singleton] at member
        rcases member with member | rfl
        · have before := valid.2.2.2 item (metadata ▸ member)
          dsimp only; omega
        · dsimp only [ArrayDeclarationParts.binding]
          omega

theorem boolean_array_declaration_source_ready {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final)
    (ready : ArrayBindings.SourceReady text state.arrayNames) :
    ArrayBindings.SourceReady text final.arrayNames := by
  have valid := boolean_array_declaration_array_valid reading ready.1
  cases reading with
  | @declaration values parts lower upper position following partsEq allowed low high _ valuesEq positive _ _ =>
      have table : values.arrayNames.values = state.arrayNames.values ++ List.replicate parts.length 0 := by
        simpa only [valuesEq, Nat.sub_zero] using booleanArrayValuesModel_canonical text state state position parts.length 0
          parts.first parts.after (valuesEq.symm ▸ positive) ready.2.1
      have used : values.arrayNames.used = state.arrayNames.used + parts.length := by
        simpa only [valuesEq, Nat.sub_zero] using booleanArrayValuesModel_used text state state position parts.length 0
          parts.first parts.after (valuesEq.symm ▸ positive)
      have metadata : values.arrayNames.names = state.arrayNames.names := by
        have fields := booleanArrayValuesModel_fields text state state position parts.length 0 parts.first parts.after
          (valuesEq.symm ▸ positive)
        rw [valuesEq] at fields
        exact congrArg (fun s => s.arrayNames.names) fields
      have bindingValid := boolean_array_declaration_binding_valid partsEq allowed low high
      have component : parts.componentBounds = Integer.Interval.full := by
        rw [← partsEq]
        exact arrayParts_boolean_components (partsEq.symm ▸ allowed.kind)
      refine ⟨valid, ?_, valid.1.2.2, ?_⟩
      · change values.arrayNames.values.length = values.arrayNames.used
        simp only [table, List.length_append, List.length_replicate, ready.2.1, used]
      · change ArrayBindings.InitialsFit (values.arrayNames.names ++ [parts.binding state]) values.arrayNames.values
        rw [metadata, table]
        apply ArrayBindings.initialsFit_append ready.2.2.2
        · intro entry member
          rw [ArrayBindings.binding_descriptor_length ((ready.1.1.2.1 entry member).2.2.2), ready.2.1]
          exact ready.1.2.2.2 entry member
        · exact ready.2.1.symm
        · rw [ArrayBindings.binding_descriptor_length bindingValid, List.length_replicate]
          rfl
        · exact bindingValid.2.2.2.2.2.1
        · intro value member
          have zero : value = 0 := (List.mem_replicate.mp member).2
          rw [zero]
          change parts.componentBounds.Contains 0
          rw [component]
          decide +kernel

theorem boolean_array_declaration_unique {text arguments state left right}
    (first : BooleanArrayDeclarationAt text arguments state left)
    (second : BooleanArrayDeclarationAt text arguments state right) : left = right :=
  (boolean_array_declaration_complete first).symm.trans (boolean_array_declaration_complete second)

theorem boolean_array_declaration_advances {text arguments state final}
    (reading : BooleanArrayDeclarationAt text arguments state final) : state.position < final.position := by
  cases reading with
  | declaration _ _ _ _ _ _ _ _ advances => exact advances

theorem array_declaration_kinds_disjoint {text arguments state declaration first second}
    (integer : ArrayDeclarationAt text arguments state declaration first)
    (boolean : BooleanArrayDeclarationAt text arguments state second) : False := by
  have kind := boolean_array_declaration_kind boolean
  cases integer with
  | declaration parts ready _ _ _ _ _ _ _ =>
      rw [parts, ready.integer] at kind
      contradiction

theorem array_declaration_boolean_analysis {text arguments state declaration final}
    (reading : ArrayDeclarationAt text arguments state declaration final) :
    ArrayBindings.booleanAnalysis final.arrayNames.names (BooleanBindings.analysis final.booleanNames) =
      ArrayBindings.booleanAnalysis state.arrayNames.names (BooleanBindings.analysis state.booleanNames) := by
  cases reading with
  | @declaration values parts lower upper position following expressions _ ready _ _ _ _ valuesRead _ _ =>
      have fields := arrayValues_fields valuesRead
      have names : values.arrayNames.names = state.arrayNames.names := congrArg (fun s => s.arrayNames.names) fields
      have booleans : values.booleanNames = state.booleanNames := congrArg (fun s => s.booleanNames) fields
      change ArrayBindings.booleanAnalysis (values.arrayNames.names ++ [parts.binding state])
        (BooleanBindings.analysis values.booleanNames) = _
      rw [names, booleans, ArrayBindings.booleanAnalysis_append_integer _ _ ready.integer]

end Silver.Compose
