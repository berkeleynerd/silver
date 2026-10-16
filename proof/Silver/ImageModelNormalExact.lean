module

public import Silver.ImageModelExactEmission

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem literal_exact (tables : Native.Tables) (state : Core.State) (first : Nat) (rest : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (notId : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (start : first = 116 ∨ first = 102 ∨ first = 110)
    (tail : ∀ byte ∈ rest, isDelimiter byte = false)
    (room : state.bytes + (first :: rest).length ≤ 9223372036854775807) :
    ExactEmits tables state ((first :: rest).foldl (consume (Core.modelHelpers tables)) state) (first :: rest) := by
  rw [literal_result tables state first rest good mode notId active start tail room]
  exact ExactEmits.of_fold tables state _ _ active rfl

/-- Array delimiters and the independently established body stream determine
the entire matcher effect at either field depth or deeper nesting. -/
theorem array_body_exact (tables : Native.Tables) (state : Core.State) (input normalized : List Nat)
    (good : state.failed = false) (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : 3 ≤ state.depth)
    (room : state.bytes + ([91] ++ input ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : state.depth + ([91] ++ input ++ [93]).length ≤ 9223372036854775807)
    (body : BodyResult tables (openedArray tables state)
      (input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)) input normalized)
    (exactBody : ExactEmits tables (openedArray tables state)
      (input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)) normalized) :
    ExactEmits tables state (([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state)
      ([91] ++ normalized ++ [93]) := by
  let middle := input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)
  have middleDepth : middle.depth = state.depth + 1 := congrArg JsonScope.depth body.context
  have middleBytes : middle.bytes = state.bytes + 1 + input.length := body.bytes
  have fold : ([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state = closedArray tables middle := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [open_nested_array tables state good
      (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      (by simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
      mode pending active depth]
    exact nested_close_result tables middle body.good
      (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      body.boundary body.nodeId body.active (by omega)
  rw [fold]
  exact ((ExactEmits.of_fold tables state (openedArray tables state) [91] active rfl).trans exactBody).trans
    (closed_array_exact tables middle body.active)

mutual
  /-- Independent narrow syntax yields exact matcher execution, without an
acceptance or liveness premise. Depth three is allowed because even an invalid
top-level tag leaves its exact matcher effect; field legality separately proves
the surrounding scanner remains successful. -/
  theorem normal_value_exact (tables : Native.Tables) (state : Core.State)
      (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
      (normal : JSON.NormalValue previous pending value input normalized outgoing)
      (good : state.failed = false) (mode : state.mode = .between)
      (_prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 3 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      ExactEmits tables state (input.foldl (consume (Core.modelHelpers tables)) state) normalized.encode := by
    cases normal with
    | null => simpa only [JSON.Value.encode] using literal_exact tables state 110 [117, 108, 108] good mode nodeId active (.inr (.inr rfl)) (by decide +kernel) room
    | true => simpa only [JSON.Value.encode] using literal_exact tables state 116 [114, 117, 101] good mode nodeId active (.inl rfl) (by decide +kernel) room
    | false => simpa only [JSON.Value.encode] using literal_exact tables state 102 [97, 108, 115, 101] good mode nodeId active (.inr (.inl rfl)) (by decide +kernel) room
    | number _ _ valid =>
        obtain ⟨digits, result⟩ := ordinary_integer_result tables state input valid good mode nodeId active room
        rw [result]
        simpa only [JSON.Value.encode] using ExactEmits.of_fold tables state
          (atomEffect tables (ordinaryNumber state digits) input) input active rfl
    | id _ first rest _ decimal bounded =>
        rw [consume_node_id tables state first rest good mode nodeId active decimal room bounded]
        simpa only [JSON.Value.encode] using ExactEmits.of_fold tables state _ [48] active rfl
    | string _ characters bytes content =>
        obtain ⟨left, code, result⟩ := quoted_string_result tables state characters bytes content good mode nodeId (.inl active)
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        rw [result]
        simpa only [JSON.Value.encode] using ExactEmits.of_fold tables state
          (quotedResult tables state characters (bytes.length + 2) left code) (JSON.stringBytes characters) active rfl
    | array _ values normalized bytes entries =>
        have openingActive : (openedArray tables state).matcher.inTheory = true :=
          (Native.match_inTheory tables state.matcher 91 .integer).trans active
        have bodyRoom : (openedArray tables state).bytes + bytes.length ≤ 9223372036854775807 := by
          change state.bytes + 1 + bytes.length ≤ _
          simp only [List.length_append, List.length_cons, List.length_nil] at room; omega
        have bodyDepthRoom : (openedArray tables state).depth + bytes.length ≤ 9223372036854775807 := by
          change state.depth + 1 + bytes.length ≤ _
          simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega
        have nested : 4 ≤ (openedArray tables state).depth := by change 4 ≤ state.depth + 1; omega
        have body := normal_elements tables (openedArray tables state) true false values normalized bytes entries
          good mode rfl nodeId openingActive nested bodyRoom bodyDepthRoom
        have exactBody := normal_elements_exact tables (openedArray tables state) true false values normalized bytes entries
          good mode rfl nodeId openingActive nested bodyRoom bodyDepthRoom
        simpa only [JSON.Value.encode] using array_body_exact tables state bytes
          (JSON.separated (normalized.map JSON.Value.encode)) good mode nodeId active depth room depthRoom body exactBody
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem normal_elements_exact (tables : Native.Tables) (state : Core.State)
      (previous pending : Bool) (values normalized : List JSON.Value) (input : List Nat)
      (normal : JSON.NormalElements previous pending values input normalized)
      (good : state.failed = false) (mode : state.mode = .between)
      (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      ExactEmits tables state (input.foldl (consume (Core.modelHelpers tables)) state)
        (JSON.separated (normalized.map JSON.Value.encode)) := by
    cases normal with
    | empty _ _ whitespace =>
        rw [consume_whitespace_run _ state input good room mode whitespace]
        exact ExactEmits.of_matcher_eq tables state _ rfl
    | single _ _ value normalized leading bytes trailing before item after =>
        let ready := {state with bytes := state.bytes + leading.length}
        have valueRoom : ready.bytes + bytes.length ≤ 9223372036854775807 := by
          change state.bytes + leading.length + bytes.length ≤ _
          simp only [List.length_append] at room; omega
        have valueDepthRoom : ready.depth + bytes.length ≤ 9223372036854775807 := by
          change state.depth + bytes.length ≤ _
          simp only [List.length_append] at depthRoom; omega
        have first := normal_value tables ready previous pending false value normalized bytes item good mode prev nodeId active depth valueRoom valueDepthRoom
        have exactFirst := normal_value_exact tables ready previous pending false value normalized bytes item good mode prev nodeId active (by change 3 ≤ state.depth; omega) valueRoom valueDepthRoom
        let middle := bytes.foldl (consume (Core.modelHelpers tables)) ready
        have fold : (leading ++ (bytes ++ trailing)).foldl (consume (Core.modelHelpers tables)) state = afterSpaces middle trailing := by
          simp only [List.foldl_append]
          rw [consume_whitespace_run _ state leading good (by simp only [List.length_append] at room; omega) mode before]
          exact boundary_whitespace _ middle trailing first.good
            (by rw [first.bytes]; change state.bytes + leading.length + bytes.length + trailing.length ≤ _
                simp only [List.length_append] at room; omega) first.boundary after
        rw [fold]
        have leadingExact := ExactEmits.of_matcher_eq tables state ready rfl
        have trailingExact := ExactEmits.of_matcher_eq tables middle (afterSpaces middle trailing) (spaces_matcher middle trailing)
        simpa only [List.map_cons, List.map_nil, JSON.separated, List.intersperse_singleton,
          List.flatten_cons, List.flatten_nil, List.append_nil, List.nil_append] using
          (leadingExact.trans exactFirst).trans trailingExact
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        let ready := {state with bytes := state.bytes + leading.length}
        have valueRoom : ready.bytes + bytes.length ≤ 9223372036854775807 := by
          change state.bytes + leading.length + bytes.length ≤ _
          simp only [List.length_append, List.length_cons, List.length_nil] at room; omega
        have valueDepthRoom : ready.depth + bytes.length ≤ 9223372036854775807 := by
          change state.depth + bytes.length ≤ _
          simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega
        have first := normal_value tables ready previous pending outgoing value normalized bytes item good mode prev nodeId active depth valueRoom valueDepthRoom
        have exactFirst := normal_value_exact tables ready previous pending outgoing value normalized bytes item good mode prev nodeId active (by change 3 ≤ state.depth; omega) valueRoom valueDepthRoom
        let middle := afterSpaces (bytes.foldl (consume (Core.modelHelpers tables)) ready) spaces
        have firstSpaces := first.spaces spaces
        have middleDepth : middle.depth = state.depth := congrArg JsonScope.depth firstSpaces.context
        have middleBytes : middle.bytes = state.bytes + leading.length + (bytes ++ spaces).length := firstSpaces.bytes
        have nextDepth : (afterComma tables middle).depth = state.depth :=
          (congrArg JsonScope.depth (comma_scope tables middle)).trans middleDepth
        have restExact := normal_elements_exact tables (afterComma tables middle) false outgoing values restNormalized rest tail
          ((comma_good tables middle).trans firstSpaces.good) (comma_mode tables middle firstSpaces.boundary) rfl
          ((comma_pending tables middle).trans firstSpaces.nodeId) ((comma_active tables middle).trans firstSpaces.active)
          (by rw [nextDepth]; exact depth)
          (by rw [comma_bytes, middleBytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room ⊢; omega)
          (by rw [nextDepth]; simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
        have fold : (leading ++ (bytes ++ spaces ++ [44] ++ rest)).foldl (consume (Core.modelHelpers tables)) state =
            rest.foldl (consume (Core.modelHelpers tables)) (afterComma tables middle) := by
          simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
          rw [consume_whitespace_run _ state leading good
            (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) mode before]
          rw [boundary_whitespace _ _ spaces first.good
            (by rw [first.bytes]; change state.bytes + leading.length + bytes.length + spaces.length ≤ _
                simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) first.boundary between]
          rw [nested_comma_result tables middle firstSpaces.good
            (by rw [middleBytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room ⊢; omega)
            firstSpaces.boundary firstSpaces.active (by omega)]
          rfl
        rw [fold, separated_cons normalized restNormalized (tail.output_nonempty nonempty)]
        have leadingExact := ExactEmits.of_matcher_eq tables state ready rfl
        have spacesExact := ExactEmits.of_matcher_eq tables _ middle (spaces_matcher _ spaces)
        simpa only [List.nil_append, List.append_nil] using
          (((leadingExact.trans exactFirst).trans spacesExact).trans (comma_exact tables middle firstSpaces.active)).trans restExact
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

theorem normal_field_exact (tables : Native.Tables) (state : Core.State)
    (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
    (normal : JSON.NormalValue previous pending value input normalized outgoing)
    (_legal : FieldLegal state.field value) (good : state.failed = false) (mode : state.mode = .between)
    (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + input.length ≤ 9223372036854775807)
    (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
    ExactEmits tables state (input.foldl (consume (Core.modelHelpers tables)) state) normalized.encode :=
  normal_value_exact tables state previous pending outgoing value normalized input normal
    good mode prev nodeId active (by omega) room depthRoom

theorem normal_segment_exact (tables : Native.Tables) (state : Core.State)
    (index : Nat) (previous pending outgoing : Bool) (span : JSON.FieldSpan) (normalized : JSON.Value)
    (normal : JSON.NormalField index previous pending span normalized outgoing)
    (good : state.failed = false) (mode : state.mode = .between)
    (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3) (field : state.field = index)
    (room : state.bytes + span.bytes.length ≤ 9223372036854775807)
    (depthRoom : state.depth + span.bytes.length ≤ 9223372036854775807) :
    ExactEmits tables state (span.bytes.foldl (consume (Core.modelHelpers tables)) state) normalized.encode := by
  cases normal with
  | mk before value legal after =>
      let ready := {state with bytes := state.bytes + span.leading.length}
      have valueRoom : ready.bytes + span.body.length ≤ 9223372036854775807 := by
        change state.bytes + span.leading.length + span.body.length ≤ _
        simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega
      have valueDepthRoom : ready.depth + span.body.length ≤ 9223372036854775807 := by
        change state.depth + span.body.length ≤ _
        simp only [JSON.FieldSpan.bytes, List.length_append] at depthRoom; omega
      have item := normal_field tables ready previous pending outgoing span.value normalized span.body value
        (field ▸ legal) good mode prev nodeId active depth valueRoom valueDepthRoom
      have exactItem := normal_field_exact tables ready previous pending outgoing span.value normalized span.body value
        (field ▸ legal) good mode prev nodeId active depth valueRoom valueDepthRoom
      let middle := span.body.foldl (consume (Core.modelHelpers tables)) ready
      have fold : span.bytes.foldl (consume (Core.modelHelpers tables)) state = afterSpaces middle span.trailing := by
        simp only [JSON.FieldSpan.bytes, List.foldl_append]
        rw [consume_whitespace_run _ state span.leading good
          (by simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega) mode before]
        exact boundary_whitespace _ middle span.trailing item.good
          (by rw [item.bytes]; change state.bytes + span.leading.length + span.body.length + span.trailing.length ≤ _
              simp only [JSON.FieldSpan.bytes, List.length_append] at room; omega) item.boundary after
      rw [fold]
      have leading := ExactEmits.of_matcher_eq tables state ready rfl
      have trailing := ExactEmits.of_matcher_eq tables middle (afterSpaces middle span.trailing) (spaces_matcher middle span.trailing)
      simpa only [List.nil_append, List.append_nil] using (leading.trans exactItem).trans trailing

/-- Exact forward matcher execution for all eight original theory fields.
Syntax, native bounds and ordinary field legality suffice; selected acceptance
and expected template identity are not premises. -/
theorem normal_fields_exact (tables : Native.Tables) (index : Nat) (previous pending : Bool)
    (spans : List JSON.FieldSpan) (normalized : List JSON.Value)
    (normal : JSON.NormalFields index previous pending spans normalized) :
    ∀ (state : Core.State), state.failed = false → state.mode = .between →
      state.previousArrayStart = previous → state.nodeIdPending = pending →
      state.matcher.inTheory = true → state.depth = 3 → state.field = index →
      state.bytes + (JSON.fieldsBytes spans).length ≤ 9223372036854775807 →
      state.depth + (JSON.fieldsBytes spans).length ≤ 9223372036854775807 →
      ExactEmits tables state ((JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) state)
        (JSON.separated (normalized.map JSON.Value.encode)) := by
  induction normal with
  | last previous pending span normalized fieldNormal =>
      intro state good mode prev nodeId active depth field room depthRoom
      have result := normal_segment_exact tables state 7 previous pending false span normalized fieldNormal
        good mode prev nodeId active depth field room depthRoom
      simpa only [JSON.fieldsBytes, List.map_cons, List.map_nil, JSON.separated,
        List.intersperse_singleton, List.flatten_cons, List.flatten_nil, List.append_nil] using result
  | more index previous pending outgoing span normalized spans restNormalized bounded fieldNormal tail ih =>
      intro state good mode prev nodeId active depth field room depthRoom
      have input := JSON.fieldsBytes_cons span spans tail.nonempty.1
      rw [input] at room depthRoom ⊢
      have valueRoom : state.bytes + span.bytes.length ≤ 9223372036854775807 := by
        simp only [List.length_append, List.length_cons, List.length_nil] at room; omega
      have valueDepthRoom : state.depth + span.bytes.length ≤ 9223372036854775807 := by
        simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega
      have item := normal_segment tables state index previous pending outgoing span normalized fieldNormal
        good mode prev nodeId active depth field valueRoom valueDepthRoom
      have exactItem := normal_segment_exact tables state index previous pending outgoing span normalized fieldNormal
        good mode prev nodeId active depth field valueRoom valueDepthRoom
      let middle := span.bytes.foldl (consume (Core.modelHelpers tables)) state
      have middleDepth : middle.depth = state.depth :=
        (congrArg JsonScope.depth item.context).trans (valueScope_depth _ _ _ _)
      have middleField : middle.field = state.field :=
        (congrArg JsonScope.field item.context).trans (valueScope_field _ _ _ _)
      have nextScope := field_comma_scope tables middle
      have nextBytes : (fieldComma tables middle).bytes = state.bytes + span.bytes.length + 1 :=
        (comma_bytes tables middle).trans (by rw [item.bytes])
      have nextDepth : (fieldComma tables middle).depth = state.depth :=
        (congrArg JsonScope.depth nextScope).trans middleDepth
      have nextField : (fieldComma tables middle).field = index + 1 := by change middle.field + 1 = _; rw [middleField, field]
      have final := ih (fieldComma tables middle) ((comma_good tables middle).trans item.good)
        (comma_mode tables middle item.boundary) rfl ((comma_pending tables middle).trans item.nodeId)
        ((comma_active tables middle).trans item.active) (nextDepth.trans depth) nextField
        (by rw [nextBytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        (by rw [nextDepth]; simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
      have fold : (span.bytes ++ [44] ++ JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) state =
          (JSON.fieldsBytes spans).foldl (consume (Core.modelHelpers tables)) (fieldComma tables middle) := by
        simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
        rw [field_comma_result tables middle item.good
          (by rw [item.bytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          item.boundary item.active (middleDepth.trans depth) (by omega)]
      rw [fold, separated_cons normalized restNormalized tail.nonempty.2]
      exact (exactItem.trans (field_comma_exact tables middle item.active)).trans final

end Silver.ImageModel.ScannerNative
