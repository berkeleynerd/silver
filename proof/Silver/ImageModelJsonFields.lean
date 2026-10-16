module

public import Silver.ImageModelJsonSimulation
public import Silver.ImageModelJsonErasure

@[expose] public section
namespace Silver.ImageModel.ScannerNative

def selectedName (characters : List Nat) (old : Option Native.Theory) : Option Native.Theory :=
  if characters = StringNative.Name.integer.bytes then some .integer
  else if characters = StringNative.Name.string.bytes then some .string
  else if characters = StringNative.Name.image.bytes then some .image else old

/-- Only the actual depth-three name field may select a target. An array field
captures its original closing bracket when it is declarations or includes. -/
def fieldScope (state : Core.State) (value : JSON.Value) (length : Nat) : JsonScope :=
  match value with
  | .string characters => {scope state with theory := if state.field = 4 then selectedName characters state.theory else state.theory}
  | .array _ => {scope state with
      candidateDeclarations := if state.field = 3 then state.bytes + length - 1 else state.candidateDeclarations
      candidateIncludes := if state.field = 6 then state.bytes + length - 1 else state.candidateIncludes}
  | _ => scope state

def FieldLegal (field : Nat) : JSON.Value → Prop
  | .string characters => field = 0 → characters = StringNative.Name.theoryTag.bytes
  | _ => True

structure FieldResult (tables : Native.Tables) (before after : Core.State)
    (value : JSON.Value) (input normalized : List Nat) (pending : Bool) : Prop where
  good : after.failed = false
  active : after.matcher.inTheory = true
  context : scope after = fieldScope before value input.length
  bytes : after.bytes = before.bytes + input.length
  boundary : Boundary after
  previous : after.previousArrayStart = false
  nodeId : after.nodeIdPending = pending
  emits : Emits tables before after normalized

theorem LocalResult.field {tables : Native.Tables} {before after : Core.State}
    {input normalized : List Nat} {pending : Bool}
    (result : LocalResult tables before after input normalized pending) (value : JSON.Value)
    (same : fieldScope before value input.length = scope before) :
    FieldResult tables before after value input normalized pending :=
  ⟨result.good, result.active, result.context.trans same.symm, result.bytes, result.boundary,
   result.previous, result.nodeId, result.emits⟩

theorem field_string_scope (tables : Native.Tables) (state : Core.State) (characters : List Nat)
    (length left code : Nat) (depth : state.depth = 3)
    (legal : state.field = 0 → characters = StringNative.Name.theoryTag.bytes) :
    scope (quotedResult tables state characters length left code) = fieldScope state (.string characters) length ∧
      (quotedResult tables state characters length left code).failed = state.failed := by
  by_cases tag : state.field = 0
  · simp [quotedResult, quoteContext, fieldScope, scope, depth, tag, legal tag]
  · by_cases name : state.field = 4 <;>
      simp [quotedResult, quoteContext, fieldScope, scope, depth, tag, name, selectedName]

theorem closed_array_scope_all (tables : Native.Tables) (state : Core.State) :
    scope (closedArray tables state) =
      {scope state with
        depth := state.depth - 1
        candidateDeclarations := if state.depth = 4 ∧ state.field = 3 then state.bytes else state.candidateDeclarations
        candidateIncludes := if state.depth = 4 ∧ state.field = 6 then state.bytes else state.candidateIncludes} := by
  have same := settled_scope state
  have positive : 0 < state.bytes + 1 := by omega
  change scope (closeNestedArray (counted (settled state))) = _
  simp only [closeNestedArray, counted, scope, settled_bytes, Nat.add_sub_cancel, positive, true_and]
  have d := congrArg JsonScope.depth same
  have f := congrArg JsonScope.field same
  have cd := congrArg JsonScope.candidateDeclarations same
  have ci := congrArg JsonScope.candidateIncludes same
  have p := congrArg JsonScope.phase same
  have t := congrArg JsonScope.theory same
  have s := congrArg JsonScope.seen same
  have od := congrArg JsonScope.declarations same
  have oi := congrArg JsonScope.includes same
  dsimp only [scope] at d f cd ci p t s od oi
  simp only [d, f, cd, ci, p, t, s, od, oi]

theorem field_array (tables : Native.Tables) (state : Core.State) (values normalized : List JSON.Value) (input : List Nat)
    (entries : JSON.NormalElements true false values input normalized)
    (good : state.failed = false) (mode : state.mode = .between) (nodeId : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + ([91] ++ input ++ [93]).length ≤ 9223372036854775807)
    (depthRoom : state.depth + ([91] ++ input ++ [93]).length ≤ 9223372036854775807) :
    FieldResult tables state (([91] ++ input ++ [93]).foldl (consume (Core.modelHelpers tables)) state)
      (.array values) ([91] ++ input ++ [93]) (JSON.Value.array normalized).encode false := by
  have openingActive : (openedArray tables state).matcher.inTheory = true :=
    (Native.match_inTheory tables state.matcher 91 .integer).trans active
  have body := normal_elements tables (openedArray tables state) true false values normalized input entries
    good mode rfl nodeId openingActive (by change 4 ≤ state.depth + 1; omega)
    (by change state.bytes + 1 + input.length ≤ _
        simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
    (by change state.depth + 1 + input.length ≤ _
        simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
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

/-- Every top-level field derives its exact scope effect from its syntax. This
includes name selection and the original declaration/include closing offsets. -/
theorem normal_field (tables : Native.Tables) (state : Core.State)
    (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
    (normal : JSON.NormalValue previous pending value input normalized outgoing)
    (legal : FieldLegal state.field value) (good : state.failed = false) (mode : state.mode = .between)
    (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + input.length ≤ 9223372036854775807)
    (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
    FieldResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) value input normalized.encode outgoing := by
  cases normal with
  | null => simpa only [JSON.Value.encode] using
      (local_literal tables state 110 [117, 108, 108] good mode nodeId active (.inr (.inr rfl)) (by decide +kernel) room).field .null rfl
  | true => simpa only [JSON.Value.encode] using
      (local_literal tables state 116 [114, 117, 101] good mode nodeId active (.inl rfl) (by decide +kernel) room).field (.boolean true) rfl
  | false => simpa only [JSON.Value.encode] using
      (local_literal tables state 102 [97, 108, 115, 101] good mode nodeId active (.inr (.inl rfl)) (by decide +kernel) room).field (.boolean false) rfl
  | number _ _ valid => simpa only [JSON.Value.encode] using
      (local_integer tables state input valid good mode nodeId active room).field (.number input) rfl
  | id _ first rest _ decimal bounded => simpa only [JSON.Value.encode] using
      (local_node_id tables state first rest good mode nodeId active decimal room bounded).field (.number (first :: rest)) rfl
  | string _ characters bytes content =>
      obtain ⟨left, code, result⟩ := quoted_string_result tables state characters bytes content good mode nodeId (.inl active)
        (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
      rw [result]
      have context := field_string_scope tables state characters (bytes.length + 2) left code depth legal
      refine ⟨context.2.trans good, (matcher_fold_active tables state.matcher _).trans active, ?_, ?_, .inl rfl, rfl, ?_, ?_⟩
      · simpa only [fieldScope] using context.1
      · change state.bytes + (bytes.length + 2) = _
        simp only [List.length_append, List.length_cons, List.length_nil]; omega
      · exact congrArg (fun p => p && JSON.nodeTag characters) prev
      · simpa only [JSON.Value.encode] using quoted_result_emits tables state characters _ left code active
  | array _ values normalized bytes entries => exact field_array tables state values normalized bytes entries good mode nodeId active depth room depthRoom

end Silver.ImageModel.ScannerNative
