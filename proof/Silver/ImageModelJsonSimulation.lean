module

public import Silver.ImageModelJsonBodies
public import Silver.ImageModelJsonNormalization

@[expose] public section
namespace Silver.ImageModel.ScannerNative

theorem separated_cons (value : JSON.Value) (values : List JSON.Value) (nonempty : values ≠ []) :
    JSON.separated ((value :: values).map JSON.Value.encode) =
      value.encode ++ [44] ++ JSON.separated (values.map JSON.Value.encode) := by
  cases values with
  | nil => contradiction
  | cons head rest => simp [JSON.separated, List.intersperse_cons_cons, List.append_assoc]

mutual
  /-- Complete recursive simulation for independently normalized nested values.
The room bounds describe native counters, while all semantic premises are
syntax/decimal-domain facts. The result proves the actual Consume fold and
transfers matcher invariants for the derived canonical bytes. -/
  theorem normal_value (tables : Native.Tables) (state : Core.State)
      (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
      (normal : JSON.NormalValue previous pending value input normalized outgoing)
      (good : state.failed = false) (mode : state.mode = .between)
      (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      LocalResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) input normalized.encode outgoing := by
    cases normal with
    | null => simpa only [JSON.Value.encode] using local_literal tables state 110 [117, 108, 108] good mode nodeId active (.inr (.inr rfl)) (by decide +kernel) room
    | true => simpa only [JSON.Value.encode] using local_literal tables state 116 [114, 117, 101] good mode nodeId active (.inl rfl) (by decide +kernel) room
    | false => simpa only [JSON.Value.encode] using local_literal tables state 102 [97, 108, 115, 101] good mode nodeId active (.inr (.inl rfl)) (by decide +kernel) room
    | number _ _ valid => simpa only [JSON.Value.encode] using local_integer tables state input valid good mode nodeId active room
    | id _ first rest _ decimal bounded => simpa only [JSON.Value.encode] using local_node_id tables state first rest good mode nodeId active decimal room bounded
    | string _ characters bytes content =>
        simpa only [prev, JSON.Value.encode] using local_string tables state characters bytes content good mode nodeId active depth
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
    | array _ values normalized bytes entries =>
        have openingActive : (openedArray tables state).matcher.inTheory = true :=
          (Native.match_inTheory tables state.matcher 91 .integer).trans active
        have body := normal_elements tables (openedArray tables state) true false values normalized bytes entries
          good mode rfl nodeId openingActive (by change 4 ≤ state.depth + 1; omega)
          (by change state.bytes + 1 + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          (by change state.depth + 1 + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
        simpa only [JSON.Value.encode] using nested_array tables state bytes (JSON.separated (normalized.map JSON.Value.encode)) good mode nodeId active depth
          (by simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) body
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  /-- The corresponding theorem for full nested array bodies preserves their
enclosing scope and consumes precisely the original serialized byte span. -/
  theorem normal_elements (tables : Native.Tables) (state : Core.State)
      (previous pending : Bool) (values normalized : List JSON.Value) (input : List Nat)
      (normal : JSON.NormalElements previous pending values input normalized)
      (good : state.failed = false) (mode : state.mode = .between)
      (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      BodyResult tables state (input.foldl (consume (Core.modelHelpers tables)) state)
        input (JSON.separated (normalized.map JSON.Value.encode)) := by
    cases normal with
    | empty _ _ whitespace => exact empty_body tables state input good active mode nodeId whitespace room
    | single _ _ value normalized leading bytes trailing before item after =>
        let ready := {state with bytes := state.bytes + leading.length}
        have first := normal_value tables ready previous pending false value normalized bytes item good mode prev nodeId active depth
          (by change state.bytes + leading.length + bytes.length ≤ _
              simp only [List.length_append] at room; omega)
          (by change state.depth + bytes.length ≤ _
              simp only [List.length_append] at depthRoom; omega)
        have body := body_single tables ready bytes normalized.encode trailing first after
          (by change state.bytes + leading.length + bytes.length + trailing.length ≤ _
              simp only [List.length_append] at room; omega)
        have full := body_leading tables state leading (bytes ++ trailing) normalized.encode good mode before
          (by simp only [List.length_append] at room; omega) body
        simpa only [List.map_cons, List.map_nil, JSON.separated, List.intersperse_singleton,
          List.flatten_cons, List.flatten_nil, List.append_nil] using full
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        let ready := {state with bytes := state.bytes + leading.length}
        have first := normal_value tables ready previous pending outgoing value normalized bytes item good mode prev nodeId active depth
          (by change state.bytes + leading.length + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          (by change state.depth + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
        let middle := afterSpaces (bytes.foldl (consume (Core.modelHelpers tables)) ready) spaces
        have firstSpaces := first.spaces spaces
        have middleDepth : middle.depth = state.depth := congrArg JsonScope.depth firstSpaces.context
        have middleBytes : middle.bytes = state.bytes + leading.length + (bytes ++ spaces).length := firstSpaces.bytes
        have nextDepth : (afterComma tables middle).depth = state.depth :=
          (congrArg JsonScope.depth (comma_scope tables middle)).trans middleDepth
        have body := normal_elements tables (afterComma tables middle) false outgoing values restNormalized rest tail
          ((comma_good tables middle).trans firstSpaces.good) (comma_mode tables middle firstSpaces.boundary) rfl
          ((comma_pending tables middle).trans firstSpaces.nodeId) ((comma_active tables middle).trans firstSpaces.active)
          (by rw [nextDepth]; exact depth)
          (by rw [comma_bytes, middleBytes]
              simp only [List.length_append, List.length_cons, List.length_nil] at room ⊢; omega)
          (by rw [nextDepth]
              simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
        have combined := body_more tables ready bytes normalized.encode spaces rest
          (JSON.separated (restNormalized.map JSON.Value.encode)) outgoing first between depth
          (by change state.bytes + leading.length + bytes.length + spaces.length + 1 + rest.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) body
        have full := body_leading tables state leading (bytes ++ spaces ++ [44] ++ rest)
          (normalized.encode ++ [44] ++ JSON.separated (restNormalized.map JSON.Value.encode)) good mode before
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) combined
        rw [separated_cons normalized restNormalized (tail.output_nonempty nonempty)]
        exact full
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

end Silver.ImageModel.ScannerNative
