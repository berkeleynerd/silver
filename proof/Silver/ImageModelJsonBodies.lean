module

public import Silver.ImageModelJsonArrays

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem LocalResult.spaces {tables : Native.Tables} {before after : Core.State}
    {input normalized : List Nat} {pending : Bool}
    (result : LocalResult tables before after input normalized pending) (spaces : List Nat) :
    LocalResult tables before (afterSpaces after spaces) (input ++ spaces) normalized pending := by
  refine ⟨(spaces_good after spaces).trans result.good, ?_,
    (spaces_scope after spaces).trans result.context, ?_, spaces_boundary after spaces result.boundary,
    (spaces_previous after spaces).trans result.previous, (spaces_pending after spaces).trans result.nodeId, ?_⟩
  · rw [spaces_matcher]; exact result.active
  · rw [spaces_bytes, result.bytes, List.length_append]; omega
  · simpa only [List.append_nil] using result.emits.trans
      (Emits.of_matcher_eq tables after (afterSpaces after spaces) (spaces_matcher after spaces))

theorem body_single (tables : Native.Tables) (state : Core.State) (input normalized spaces : List Nat)
    (item : LocalResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) input normalized false)
    (whitespace : Whitespace spaces)
    (room : state.bytes + input.length + spaces.length ≤ 9223372036854775807) :
    BodyResult tables state ((input ++ spaces).foldl (consume (Core.modelHelpers tables)) state)
      (input ++ spaces) normalized := by
  rw [List.foldl_append, boundary_whitespace _ _ spaces item.good (by rw [item.bytes]; exact room) item.boundary whitespace]
  have result := item.spaces spaces
  exact ⟨result.good, result.active, result.context, result.bytes, result.boundary, result.nodeId, result.emits⟩

def afterComma (tables : Native.Tables) (state : Core.State) : Core.State :=
  {(Core.modelHelpers tables).matchByte (counted (settled state)) 44 with previousArrayStart := false}

theorem comma_scope (tables : Native.Tables) (state : Core.State) : scope (afterComma tables state) = scope state :=
  settled_scope state

theorem comma_bytes (tables : Native.Tables) (state : Core.State) : (afterComma tables state).bytes = state.bytes + 1 := by
  change (settled state).bytes + 1 = _
  rw [settled_bytes]

theorem comma_good (tables : Native.Tables) (state : Core.State) : (afterComma tables state).failed = state.failed :=
  settled_failed state

theorem comma_active (tables : Native.Tables) (state : Core.State) : (afterComma tables state).matcher.inTheory = state.matcher.inTheory := by
  change (Core.matcher tables (settled state).matcher 44).inTheory = _
  rw [settled_matcher]
  exact Native.match_inTheory tables state.matcher 44 .integer

theorem comma_mode (tables : Native.Tables) (state : Core.State) (boundary : Boundary state) :
    (afterComma tables state).mode = .between := settled_mode state boundary

theorem comma_pending (tables : Native.Tables) (state : Core.State) : (afterComma tables state).nodeIdPending = state.nodeIdPending :=
  settled_pending state

theorem comma_emits (tables : Native.Tables) (state : Core.State) (active : state.matcher.inTheory = true) :
    Emits tables state (afterComma tables state) [44] := by
  apply Emits.of_fold tables state _ [44] active
  change Core.matcher tables (settled state).matcher 44 = Core.matcher tables state.matcher 44
  rw [settled_matcher]

/-- A complete element, optional whitespace, the actual comma and a recursively
established tail compose without assuming any template equality. -/
theorem body_more (tables : Native.Tables) (state : Core.State) (input normalized spaces rest tailNormalized : List Nat)
    (pending : Bool)
    (item : LocalResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) input normalized pending)
    (whitespace : Whitespace spaces) (depth : 4 ≤ state.depth)
    (room : state.bytes + input.length + spaces.length + 1 + rest.length ≤ 9223372036854775807)
    (tail : BodyResult tables
      (afterComma tables (afterSpaces (input.foldl (consume (Core.modelHelpers tables)) state) spaces))
      (rest.foldl (consume (Core.modelHelpers tables))
        (afterComma tables (afterSpaces (input.foldl (consume (Core.modelHelpers tables)) state) spaces)))
      rest tailNormalized) :
    BodyResult tables state ((input ++ spaces ++ [44] ++ rest).foldl (consume (Core.modelHelpers tables)) state)
      (input ++ spaces ++ [44] ++ rest) (normalized ++ [44] ++ tailNormalized) := by
  let middle := afterSpaces (input.foldl (consume (Core.modelHelpers tables)) state) spaces
  have first := item.spaces spaces
  have middleDepth : middle.depth = state.depth := congrArg JsonScope.depth first.context
  have fold : (input ++ spaces ++ [44] ++ rest).foldl (consume (Core.modelHelpers tables)) state =
      rest.foldl (consume (Core.modelHelpers tables)) (afterComma tables middle) := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [boundary_whitespace _ _ spaces item.good (by rw [item.bytes]; omega) item.boundary whitespace]
    rw [nested_comma_result tables middle first.good (by rw [first.bytes]; simp only [List.length_append]; omega)
      first.boundary first.active (by omega)]
    rfl
  rw [fold]
  refine ⟨tail.good, tail.active, tail.context.trans ((comma_scope tables middle).trans first.context), ?_, tail.boundary,
    tail.nodeId, (first.emits.trans (comma_emits tables middle first.active)).trans tail.emits⟩
  rw [tail.bytes, comma_bytes, first.bytes]
  simp only [List.length_append, List.length_cons, List.length_nil]
  omega

/-- Leading whitespace preserves both contextual flags, including a pending
node ID after the preceding tag's comma. -/
theorem body_leading (tables : Native.Tables) (state : Core.State) (leading input normalized : List Nat)
    (good : state.failed = false) (mode : state.mode = .between)
    (whitespace : Whitespace leading) (room : state.bytes + leading.length ≤ 9223372036854775807)
    (body : BodyResult tables {state with bytes := state.bytes + leading.length}
      (input.foldl (consume (Core.modelHelpers tables)) {state with bytes := state.bytes + leading.length}) input normalized) :
    BodyResult tables state ((leading ++ input).foldl (consume (Core.modelHelpers tables)) state)
      (leading ++ input) normalized := by
  rw [List.foldl_append, consume_whitespace_run _ state leading good room mode whitespace]
  refine ⟨body.good, body.active, body.context, ?_, body.boundary, body.nodeId, ?_⟩
  · rw [body.bytes, List.length_append]; dsimp only; omega
  · simpa only [List.nil_append] using
      (Emits.of_matcher_eq tables state {state with bytes := state.bytes + leading.length} rfl).trans body.emits

end Silver.ImageModel.ScannerNative
