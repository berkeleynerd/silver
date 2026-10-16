module

public import Silver.ImageModelJsonDelimiters

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- The array body leaves its delimiter unconsumed and returns no outstanding
node-ID obligation. An empty body is allowed and need not clear the opening-
array flag; the actual closing bracket clears it. -/
structure BodyResult (tables : Native.Tables) (before after : Core.State)
    (input normalized : List Nat) : Prop where
  good : after.failed = false
  active : after.matcher.inTheory = true
  context : scope after = scope before
  bytes : after.bytes = before.bytes + input.length
  boundary : Boundary after
  nodeId : after.nodeIdPending = false
  emits : Emits tables before after normalized

def openedArray (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).matchByte {counted state with depth := state.depth + 1} 91 with previousArrayStart := true}

theorem open_nested_array (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (depthRoom : state.depth < 9223372036854775807) (mode : state.mode = .between)
    (pending : state.nodeIdPending = false) (active : state.matcher.inTheory = true) (depth : 3 ≤ state.depth) :
    consume (Core.modelHelpers tables) state 91 = openedArray tables state := by
  rw [consume_between _ state 91 good room mode,
    structural_open_nested_array _ (counted state) pending active depth depthRoom]
  rfl

def closedArray (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).matchByte (closeNestedArray (counted (settled state))) 93 with previousArrayStart := false}

theorem closed_array_scope (tables : Native.Tables) (state : Core.State) (depth : 5 ≤ state.depth) :
    scope (closedArray tables state) = {scope state with depth := state.depth - 1} := by
  have same := congrArg JsonScope.depth (settled_scope state)
  change (settled state).depth = state.depth at same
  change scope (closeNestedArray (counted (settled state))) = _
  rw [nested_array_close_scope _ (by change 5 ≤ (settled state).depth; omega)]
  change {scope (settled state) with depth := (settled state).depth - 1} = _
  rw [settled_scope, same]

theorem closed_array_emits (tables : Native.Tables) (state : Core.State) (active : state.matcher.inTheory = true) :
    Emits tables state (closedArray tables state) [93] := by
  apply Emits.of_fold tables state _ [93] active
  change Core.matcher tables (settled state).matcher 93 = Core.matcher tables state.matcher 93
  rw [settled_matcher]

/-- Recursive array composition: the body theorem supplies only its local
subvalue evidence. The opening and closing transitions, original byte span,
enclosing scope and bracket emissions are established here from actual Consume. -/
theorem nested_array (tables : Native.Tables) (state : Core.State) (input normalized : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (pending : state.nodeIdPending = false) (active : state.matcher.inTheory = true)
    (depth : 4 ≤ state.depth) (depthRoom : state.depth < 9223372036854775807)
    (room : state.bytes + input.length + 2 ≤ 9223372036854775807)
    (body : BodyResult tables (openedArray tables state)
      (input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)) input normalized) :
    LocalResult tables state (([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state)
      ([91] ++ input ++ [93]) ([91] ++ normalized ++ [93]) false := by
  let middle := input.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)
  have middleDepth : middle.depth = state.depth + 1 := congrArg JsonScope.depth body.context
  have middleBytes : middle.bytes = state.bytes + 1 + input.length := body.bytes
  have middleRoom : middle.bytes ≠ 9223372036854775807 := by omega
  have fold : ([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state = closedArray tables middle := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [open_nested_array tables state good (by omega) depthRoom mode pending active (by omega)]
    exact nested_close_result tables middle body.good middleRoom body.boundary body.nodeId body.active (by omega)
  rw [fold]
  have context : scope (closedArray tables middle) = scope state := by
    rw [closed_array_scope tables middle (by omega)]
    change {scope middle with depth := middle.depth - 1} = _
    rw [body.context, middleDepth]
    simp only [openedArray, Core.modelHelpers, counted, scope, Nat.add_sub_cancel]
  have finalBytes : (closedArray tables middle).bytes = state.bytes + ([91] ++ input ++ [93]).length := by
    change (settled middle).bytes + 1 = _
    rw [settled_bytes, middleBytes]
    simp only [List.length_append, List.length_cons, List.length_nil]
    omega
  have first : Emits tables state (openedArray tables state) [91] :=
    Emits.of_fold tables state _ [91] active rfl
  refine ⟨(settled_failed middle).trans body.good, ?_, context, finalBytes, ?_, rfl,
    (settled_pending middle).trans body.nodeId, ?_⟩
  · exact (Native.match_inTheory tables (settled middle).matcher 93 .integer).trans
      (by rw [settled_matcher]; exact body.active)
  · exact .inl (settled_mode middle body.boundary)
  · exact (first.trans body.emits).trans (closed_array_emits tables middle body.active)

theorem empty_body (tables : Native.Tables) (state : Core.State) (spaces : List Nat)
    (good : state.failed = false) (active : state.matcher.inTheory = true)
    (mode : state.mode = .between) (pending : state.nodeIdPending = false)
    (whitespace : Whitespace spaces) (room : state.bytes + spaces.length ≤ 9223372036854775807) :
    BodyResult tables state (spaces.foldl (consume (Core.modelHelpers tables)) state) spaces [] := by
  rw [consume_whitespace_run _ state spaces good room mode whitespace]
  exact ⟨good, active, rfl, rfl, .inl mode, pending, Emits.of_matcher_eq tables state _ rfl⟩

end Silver.ImageModel.ScannerNative
