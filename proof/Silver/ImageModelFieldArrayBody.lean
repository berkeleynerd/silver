module

public import Silver.ImageModelJsonFields

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem field_array_of_body (tables : Native.Tables) (state : Core.State) (values normalized : List JSON.Value) (input : List Nat)
    (good : state.failed = false) (mode : state.mode = .between) (nodeId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + ([91] ++ input ++ [93]).length ≤ 9223372036854775807)
    (body : BodyResult tables (openedArray tables state)
      (input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state))
      input (JSON.separated (normalized.map JSON.Value.encode))) :
    FieldResult tables state (([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state)
      (.array values) ([91] ++ input ++ [93]) (JSON.Value.array normalized).encode false := by
  let middle := input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)
  have middleDepth : middle.depth = 4 := (congrArg JsonScope.depth body.context).trans (by change state.depth + 1 = 4; omega)
  have middleBytes : middle.bytes = state.bytes + 1 + input.length := body.bytes
  have fold : ([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state = closedArray tables middle := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [open_nested_array tables state good
      (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      (by omega) mode nodeId active (by omega)]
    exact nested_close_result tables middle body.good (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      body.boundary body.nodeId body.active (by omega)
  rw [fold]
  have context : scope (closedArray tables middle) = fieldScope state (.array values) ([91] ++ input ++ [93]).length := by
    rw [closed_array_scope_all tables middle]
    have field := congrArg JsonScope.field body.context
    have cd := congrArg JsonScope.candidateDeclarations body.context
    have ci := congrArg JsonScope.candidateIncludes body.context
    change middle.field = state.field at field
    change middle.candidateDeclarations = state.candidateDeclarations at cd
    change middle.candidateIncludes = state.candidateIncludes at ci
    rw [body.context, middleDepth, middleBytes, field, cd, ci]
    simp only [fieldScope, openedArray, Core.modelHelpers, counted, scope, depth, List.length_append,
      List.length_cons, List.length_nil, Nat.reduceSub, true_and]
    congr 1 <;> split <;> omega
  have first : Emits tables state (openedArray tables state) [91] := Emits.of_fold tables state _ [91] active rfl
  refine ⟨(settled_failed middle).trans body.good, ?_, context, ?_, .inl (settled_mode middle body.boundary),
    rfl, (settled_pending middle).trans body.nodeId, ?_⟩
  · exact (Native.match_inTheory tables (settled middle).matcher 93 .integer).trans (by rw [settled_matcher]; exact body.active)
  · change (settled middle).bytes + 1 = _
    rw [settled_bytes, middleBytes]
    simp only [List.length_append, List.length_cons, List.length_nil]; omega
  · simpa only [JSON.Value.encode] using (first.trans body.emits).trans (closed_array_emits tables middle body.active)

end Silver.ImageModel.ScannerNative
