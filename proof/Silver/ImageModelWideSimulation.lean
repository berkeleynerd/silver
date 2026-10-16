module

public import Silver.ImageModelWideQuotedResult
public import Silver.ImageModelWideNormalization
public import Silver.ImageModelEmissionLiveness

@[expose] public section
namespace Silver.ImageModel.ScannerNative

mutual
  /-- Broad JSON syntax is simulated before imposing ASCII. If any selected
candidate survives the actual run, the same derivation converts to the ASCII
normalization grammar used by the exact schema theorem. -/
  theorem wide_value (tables : Native.Tables) (state : Core.State)
      (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
      (normal : JSON.WideValue previous pending value input normalized outgoing)
      (good : state.failed = false) (mode : state.mode = .between)
      (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      LocalResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) input normalized.encode outgoing ∧
        ∀ kind, ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
          JSON.NormalValue previous pending value input normalized outgoing := by
    cases normal with
    | null =>
        refine ⟨?_, fun _ _ => .null previous⟩
        simpa only [JSON.Value.encode] using local_literal tables state 110 [117, 108, 108] good mode nodeId active
          (.inr (.inr rfl)) (by decide +kernel) room
    | true =>
        refine ⟨?_, fun _ _ => .true previous⟩
        simpa only [JSON.Value.encode] using local_literal tables state 116 [114, 117, 101] good mode nodeId active
          (.inl rfl) (by decide +kernel) room
    | false =>
        refine ⟨?_, fun _ _ => .false previous⟩
        simpa only [JSON.Value.encode] using local_literal tables state 102 [97, 108, 115, 101] good mode nodeId active
          (.inr (.inl rfl)) (by decide +kernel) room
    | number _ _ valid =>
        exact ⟨by simpa only [JSON.Value.encode] using local_integer tables state input valid good mode nodeId active room,
          fun _ _ => .number previous input valid⟩
    | id _ first rest valid decimal bounded =>
        exact ⟨by simpa only [JSON.Value.encode] using local_node_id tables state first rest good mode nodeId active decimal room bounded,
          fun _ _ => .id previous first rest valid decimal bounded⟩
    | string _ characters bytes content =>
        obtain ⟨result, ascii⟩ := wide_local_string tables state characters bytes content good mode nodeId active depth
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        refine ⟨by simpa only [prev, JSON.Value.encode] using result, ?_⟩
        intro kind live
        exact .string previous characters bytes (ascii kind live)
    | array _ values normalized bytes entries =>
        have openingActive : (openedArray tables state).matcher.inTheory = true :=
          (Native.match_inTheory tables state.matcher 91 .integer).trans active
        obtain ⟨body, ascii⟩ := wide_elements tables (openedArray tables state) true false values normalized bytes entries
          good mode rfl nodeId openingActive (by change 4 ≤ state.depth + 1; omega)
          (by change state.bytes + 1 + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          (by change state.depth + 1 + bytes.length ≤ _
              simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
        have arrayResult := nested_array tables state bytes (JSON.separated (normalized.map JSON.Value.encode)) good mode nodeId active depth
          (by simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) body
        refine ⟨by simpa only [JSON.Value.encode] using arrayResult, ?_⟩
        intro kind live
        let middle := bytes.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)
        have middleDepth : middle.depth = state.depth + 1 := congrArg JsonScope.depth body.context
        have middleBytes : middle.bytes = state.bytes + 1 + bytes.length := body.bytes
        simp only [List.foldl_append, List.foldl_cons, List.foldl_nil] at live
        rw [open_nested_array tables state good
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          (by simp only [List.length_append, List.length_cons, List.length_nil] at depthRoom; omega)
          mode nodeId active (by omega)] at live
        rw [nested_close_result tables middle body.good
          (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
          body.boundary body.nodeId body.active (by omega)] at live
        exact .array previous values normalized bytes
          (ascii kind ((closed_array_emits tables middle body.active).live_before kind live))
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem wide_elements (tables : Native.Tables) (state : Core.State)
      (previous pending : Bool) (values normalized : List JSON.Value) (input : List Nat)
      (normal : JSON.WideElements previous pending values input normalized)
      (good : state.failed = false) (mode : state.mode = .between)
      (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
      (active : state.matcher.inTheory = true) (depth : 4 ≤ state.depth)
      (room : state.bytes + input.length ≤ 9223372036854775807)
      (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
      BodyResult tables state (input.foldl (consume (Core.modelHelpers tables)) state)
        input (JSON.separated (normalized.map JSON.Value.encode)) ∧
        ∀ kind, ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
          JSON.NormalElements previous pending values input normalized := by
    cases normal with
    | empty _ _ whitespace => exact ⟨empty_body tables state input good active mode nodeId whitespace room,
        fun _ _ => .empty previous input whitespace⟩
    | single _ _ value normalized leading bytes trailing before item after =>
        let ready := {state with bytes := state.bytes + leading.length}
        obtain ⟨first, ascii⟩ := wide_value tables ready previous pending false value normalized bytes item good mode prev nodeId active depth
          (by change state.bytes + leading.length + bytes.length ≤ _
              simp only [List.length_append] at room; omega)
          (by change state.depth + bytes.length ≤ _
              simp only [List.length_append] at depthRoom; omega)
        have body := body_single tables ready bytes normalized.encode trailing first after
          (by change state.bytes + leading.length + bytes.length + trailing.length ≤ _
              simp only [List.length_append] at room; omega)
        have full := body_leading tables state leading (bytes ++ trailing) normalized.encode good mode before
          (by simp only [List.length_append] at room; omega) body
        refine ⟨by simpa only [List.map_cons, List.map_nil, JSON.separated, List.intersperse_singleton,
          List.flatten_cons, List.flatten_nil, List.append_nil] using full, ?_⟩
        intro kind live
        simp only [List.foldl_append] at live
        rw [consume_whitespace_run _ state leading good (by simp only [List.length_append] at room; omega) mode before] at live
        rw [boundary_whitespace _ _ trailing first.good
          (by rw [first.bytes]; change state.bytes + leading.length + bytes.length + trailing.length ≤ _
              simp only [List.length_append] at room; omega) first.boundary after, spaces_matcher] at live
        exact .single previous pending value normalized leading bytes trailing before (ascii kind live) after
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        let ready := {state with bytes := state.bytes + leading.length}
        obtain ⟨first, firstAscii⟩ := wide_value tables ready previous pending outgoing value normalized bytes item good mode prev nodeId active depth
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
        obtain ⟨body, tailAscii⟩ := wide_elements tables (afterComma tables middle) false outgoing values restNormalized rest tail
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
        refine ⟨?_, ?_⟩
        · rw [separated_cons normalized restNormalized (tail.output_nonempty nonempty)]
          exact full
        · intro kind live
          simp only [List.foldl_append, List.foldl_cons, List.foldl_nil] at live
          rw [consume_whitespace_run _ state leading good
            (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) mode before] at live
          rw [boundary_whitespace _ _ spaces first.good
            (by rw [first.bytes]; change state.bytes + leading.length + bytes.length + spaces.length ≤ _
                simp only [List.length_append, List.length_cons, List.length_nil] at room; omega) first.boundary between] at live
          rw [nested_comma_result tables middle firstSpaces.good
            (by rw [middleBytes]; simp only [List.length_append, List.length_cons, List.length_nil] at room ⊢; omega)
            firstSpaces.boundary firstSpaces.active (by omega)] at live
          have middleLive := (comma_emits tables middle firstSpaces.active).live_before kind (body.emits.live_before kind live)
          rw [spaces_matcher] at middleLive
          exact .more previous pending outgoing value normalized values restNormalized leading bytes spaces rest nonempty before
            (firstAscii kind middleLive) between (tailAscii kind live)
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

end Silver.ImageModel.ScannerNative
