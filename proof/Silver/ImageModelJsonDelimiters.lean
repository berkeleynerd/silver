module

public import Silver.ImageModelJsonComposition

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem settled_failed (state : Core.State) : (settled state).failed = state.failed := by
  simp only [settled, closedAtom]
  split <;> rfl

theorem settled_bytes (state : Core.State) : (settled state).bytes = state.bytes := by
  simp only [settled, closedAtom]
  split <;> rfl

theorem settled_pending (state : Core.State) : (settled state).nodeIdPending = state.nodeIdPending := by
  simp only [settled, closedAtom]
  split <;> rfl

theorem settled_previous (state : Core.State) : (settled state).previousArrayStart = state.previousArrayStart := by
  simp only [settled, closedAtom]
  split <;> rfl

def afterSpaces (state : Core.State) (input : List Nat) : Core.State :=
  if input = [] then state else {settled state with bytes := state.bytes + input.length}

/-- Optional whitespace may finalize an atom, but never consumes a synthetic
byte or changes the enclosing theory's structure or normalized stream. -/
theorem boundary_whitespace (helpers : Core.Helpers) (state : Core.State) (input : List Nat)
    (good : state.failed = false) (room : state.bytes + input.length ≤ 9223372036854775807)
    (boundary : Boundary state) (spaces : Whitespace input) :
    input.foldl (consume helpers) state = afterSpaces state input := by
  cases input with
  | nil => simp [afterSpaces]
  | cons byte rest =>
      have space := spaces byte (by simp)
      have delimiter : isDelimiter byte = true := by
        rcases space with eq | eq | eq | eq <;> subst byte <;> decide +kernel
      rw [List.foldl_cons, consume_boundary_delimiter helpers state byte good
        (by simp only [List.length_cons] at room; omega) boundary delimiter,
        structural_whitespace helpers _ byte space]
      rw [consume_whitespace_run helpers (counted (settled state)) rest
        ((settled_failed state).trans good)
        (by change (settled state).bytes + 1 + rest.length ≤ _
            rw [settled_bytes]; simp only [List.length_cons] at room; omega)
        (settled_mode state boundary)
        (fun item member => spaces item (by simp [member]))]
      simp only [counted, afterSpaces, List.cons_ne_nil, ↓reduceIte, List.length_cons, settled_bytes]
      congr 1 <;> omega

theorem spaces_scope (state : Core.State) (input : List Nat) : scope (afterSpaces state input) = scope state := by
  simp only [afterSpaces]
  split
  · rfl
  · exact settled_scope state

theorem spaces_matcher (state : Core.State) (input : List Nat) : (afterSpaces state input).matcher = state.matcher := by
  simp only [afterSpaces]
  split
  · rfl
  · exact settled_matcher state

theorem spaces_good (state : Core.State) (input : List Nat) : (afterSpaces state input).failed = state.failed := by
  simp only [afterSpaces]
  split
  · rfl
  · exact settled_failed state

theorem spaces_pending (state : Core.State) (input : List Nat) : (afterSpaces state input).nodeIdPending = state.nodeIdPending := by
  simp only [afterSpaces]
  split
  · rfl
  · exact settled_pending state

theorem spaces_previous (state : Core.State) (input : List Nat) : (afterSpaces state input).previousArrayStart = state.previousArrayStart := by
  simp only [afterSpaces]
  split
  · rfl
  · exact settled_previous state

theorem spaces_bytes (state : Core.State) (input : List Nat) :
    (afterSpaces state input).bytes = state.bytes + input.length := by
  simp only [afterSpaces]
  split
  · rename_i empty; simp [empty]
  · rfl

theorem spaces_boundary (state : Core.State) (input : List Nat) (boundary : Boundary state) : Boundary (afterSpaces state input) := by
  simp only [afterSpaces]
  split
  · exact boundary
  · exact .inl (settled_mode state boundary)

/-- A comma inside a nested value preserves the theory field index. The pending
node-ID flag deliberately crosses the comma following a W-tag string. -/
theorem nested_comma_result (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (boundary : Boundary state) (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth) :
    consume (Core.modelHelpers tables) state 44 =
      {(Core.modelHelpers tables).matchByte (counted (settled state)) 44 with previousArrayStart := false} := by
  rw [consume_boundary_delimiter _ state 44 good room boundary (by decide +kernel)]
  apply structural_nested_comma
  · exact (settled_matcher state ▸ active)
  · have same := congrArg JsonScope.depth (settled_scope state)
    change (settled state).depth = state.depth at same
    change 3 < (settled state).depth
    omega

theorem nested_close_result (tables : Native.Tables) (state : Core.State)
    (good : state.failed = false) (room : state.bytes ≠ 9223372036854775807)
    (boundary : Boundary state) (pending : state.nodeIdPending = false)
    (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth) :
    consume (Core.modelHelpers tables) state 93 =
      {(Core.modelHelpers tables).matchByte (closeNestedArray (counted (settled state))) 93 with previousArrayStart := false} := by
  rw [consume_boundary_delimiter _ state 93 good room boundary (by decide +kernel)]
  apply structural_close_nested_array
  · exact (settled_pending state).trans pending
  · exact (settled_matcher state ▸ active)
  · have same := congrArg JsonScope.depth (settled_scope state)
    change (settled state).depth = state.depth at same
    change 3 < (settled state).depth
    omega

end Silver.ImageModel.ScannerNative
