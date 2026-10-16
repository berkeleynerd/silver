module

public import Silver.ImageModelWideSimulation
public import Silver.ImageModelFieldArrayBody

@[expose] public section
namespace Silver.ImageModel.ScannerNative

/-- Depth-three broad values derive both the actual field effect and the ASCII
normalization premise whenever a selected matcher survives. -/
theorem wide_field (tables : Native.Tables) (state : Core.State)
    (previous pending outgoing : Bool) (value normalized : JSON.Value) (input : List Nat)
    (normal : JSON.WideValue previous pending value input normalized outgoing)
    (legal : FieldLegal state.field value) (good : state.failed = false) (mode : state.mode = .between)
    (prev : state.previousArrayStart = previous) (nodeId : state.nodeIdPending = pending)
    (active : state.matcher.inTheory = true) (depth : state.depth = 3)
    (room : state.bytes + input.length ≤ 9223372036854775807)
    (depthRoom : state.depth + input.length ≤ 9223372036854775807) :
    FieldResult tables state (input.foldl (consume (Core.modelHelpers tables)) state) value input normalized.encode outgoing ∧
      ∀ kind, ((input.foldl (consume (Core.modelHelpers tables)) state).matcher.cells kind).live = true →
        JSON.NormalValue previous pending value input normalized outgoing := by
  cases normal with
  | null =>
      have narrow : JSON.NormalValue previous false .null [110, 117, 108, 108] .null false := .null previous
      exact ⟨normal_field tables state previous false false _ _ _ narrow legal good mode prev nodeId active depth room depthRoom, fun _ _ => narrow⟩
  | true =>
      have narrow : JSON.NormalValue previous false (.boolean true) [116, 114, 117, 101] (.boolean true) false := .true previous
      exact ⟨normal_field tables state previous false false _ _ _ narrow legal good mode prev nodeId active depth room depthRoom, fun _ _ => narrow⟩
  | false =>
      have narrow : JSON.NormalValue previous false (.boolean false) [102, 97, 108, 115, 101] (.boolean false) false := .false previous
      exact ⟨normal_field tables state previous false false _ _ _ narrow legal good mode prev nodeId active depth room depthRoom, fun _ _ => narrow⟩
  | number _ _ valid =>
      have narrow : JSON.NormalValue previous false (.number input) input (.number input) false := .number previous input valid
      exact ⟨normal_field tables state previous false false _ _ _ narrow legal good mode prev nodeId active depth room depthRoom, fun _ _ => narrow⟩
  | id _ first rest valid decimal bounded =>
      have narrow : JSON.NormalValue previous true (.number (first :: rest)) (first :: rest) (.number [48]) false := .id previous first rest valid decimal bounded
      exact ⟨normal_field tables state previous true false _ _ _ narrow legal good mode prev nodeId active depth room depthRoom, fun _ _ => narrow⟩
  | string _ characters bytes content =>
      obtain ⟨result, ascii⟩ := wide_field_string tables state characters bytes content legal good mode nodeId active depth
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
      refine ⟨field_array_of_body tables state values normalized bytes good mode nodeId active depth room body, ?_⟩
      intro kind live
      let middle := bytes.foldl (consume (Core.modelHelpers tables)) (openedArray tables state)
      have middleDepth : middle.depth = state.depth + 1 := congrArg JsonScope.depth body.context
      have middleBytes : middle.bytes = state.bytes + 1 + bytes.length := body.bytes
      simp only [List.foldl_append, List.foldl_cons, List.foldl_nil] at live
      rw [open_nested_array tables state good
        (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        (by omega) mode nodeId active (by omega)] at live
      rw [nested_close_result tables middle body.good
        (by simp only [List.length_append, List.length_cons, List.length_nil] at room; omega)
        body.boundary body.nodeId body.active (by omega)] at live
      exact .array previous values normalized bytes
        (ascii kind ((closed_array_emits tables middle body.active).live_before kind live))

end Silver.ImageModel.ScannerNative
