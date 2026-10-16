module

public import Silver.ImageModelDocumentTheory

@[expose] public section
namespace Silver.ImageModel.ScannerNative

structure BeforeTheory (state : Core.State) : Prop where
  mode : state.mode = .between
  depth : state.depth = 2
  pending : state.nodeIdPending = false
  phase : state.phase = .firstTheory ∨ state.phase = .nextTheory

theorem document_header (tables : Native.Tables) (document : JSON.DocumentSpan)
    (room : document.header.length ≤ 9223372036854775807) :
    let result := document.header.foldl (consume (Core.modelHelpers tables)) {}
    result.failed = false ∧ BeforeTheory result ∧ result.bytes = document.header.length ∧
      (∀ kind, result.seen kind = false) ∧ result.declarations = 0 ∧ result.includes = 0 := by
  let beforeName : Core.State :=
    {bytes := document.leading.length + 1 + document.beforeKey.length, depth := 1, phase := .rootKey}
  have lengthBound : document.leading.length + 1 + document.beforeKey.length + 1 + document.key.length + 1 +
      document.beforeColon.length + 1 + document.afterColon.length + 1 ≤ 9223372036854775807 := by
    simpa only [JSON.DocumentSpan.header, List.length_append, List.length_cons, List.length_nil] using room
  have initialPart : (document.leading ++ [123] ++ document.beforeKey).foldl (consume (Core.modelHelpers tables)) {} = beforeName := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [consume_whitespace_run _ {} document.leading rfl (by simp only; omega) rfl document.leadingSpace]
    rw [consume_between _ _ 123 rfl (by change 0 + document.leading.length ≠ _; omega) rfl,
      structural_root_open _ _ rfl rfl rfl]
    rw [consume_whitespace_run _ _ document.beforeKey rfl
      (by change 0 + document.leading.length + 1 + document.beforeKey.length ≤ _; omega) rfl document.beforeKeySpace]
    simp only [beforeName, counted, Nat.zero_add]
  have keyAscii : JSON.StringContent (JSON.ascii "theory_declarations") document.key :=
    document.keyContent.to_ascii (by decide +kernel)
  obtain ⟨left, code, keyResult⟩ := quoted_string_result tables beforeName (JSON.ascii "theory_declarations") document.key keyAscii
    rfl rfl rfl (.inr ⟨rfl, rfl⟩)
    (by change document.leading.length + 1 + document.beforeKey.length + document.key.length + 2 ≤ _; omega)
  let named := quotedResult tables beforeName (JSON.ascii "theory_declarations") (document.key.length + 2) left code
  have keyEq : JSON.ascii "theory_declarations" = StringNative.Name.key.bytes := rfl
  have namedGood : named.failed = false := by simp [named, quotedResult, quoteContext, beforeName, keyEq]
  have namedPhase : named.phase = .rootColon := by simp [named, quotedResult, quoteContext, beforeName, keyEq]
  have namedPending : named.nodeIdPending = false := rfl
  let beforeColon := {named with bytes := named.bytes + document.beforeColon.length}
  let afterColon := {counted beforeColon with phase := TheoryNative.Phase.rootList, previousArrayStart := false}
  let beforeList := {afterColon with bytes := afterColon.bytes + document.afterColon.length}
  let final := {counted beforeList with depth := 2, phase := TheoryNative.Phase.firstTheory, previousArrayStart := true}
  have suffix : (document.beforeColon ++ [58] ++ document.afterColon ++ [91]).foldl (consume (Core.modelHelpers tables)) named = final := by
    simp only [List.foldl_append, List.foldl_cons, List.foldl_nil]
    rw [consume_whitespace_run _ named document.beforeColon namedGood
      (by change document.leading.length + 1 + document.beforeKey.length + (document.key.length + 2) + document.beforeColon.length ≤ _; omega)
      rfl document.beforeColonSpace]
    rw [consume_between _ beforeColon 58 namedGood
      (by change document.leading.length + 1 + document.beforeKey.length + (document.key.length + 2) + document.beforeColon.length ≠ _; omega) rfl,
      structural_root_colon _ (counted beforeColon) namedPending rfl namedPhase]
    rw [consume_whitespace_run _ afterColon document.afterColon namedGood
      (by change document.leading.length + 1 + document.beforeKey.length + (document.key.length + 2) + document.beforeColon.length + 1 + document.afterColon.length ≤ _; omega)
      rfl document.afterColonSpace]
    rw [consume_between _ beforeList 91 namedGood
      (by change document.leading.length + 1 + document.beforeKey.length + (document.key.length + 2) + document.beforeColon.length + 1 + document.afterColon.length ≠ _; omega) rfl,
      structural_root_list _ (counted beforeList) namedPending rfl rfl]
  have header : document.header = (document.leading ++ [123] ++ document.beforeKey) ++
      ([34] ++ document.key ++ [34]) ++ (document.beforeColon ++ [58] ++ document.afterColon ++ [91]) := by
    simp only [JSON.DocumentSpan.header, List.append_assoc]
  have run : document.header.foldl (consume (Core.modelHelpers tables)) {} = final := by
    rw [header, List.foldl_append (l := (document.leading ++ [123] ++ document.beforeKey) ++ ([34] ++ document.key ++ [34])),
      List.foldl_append (l := document.leading ++ [123] ++ document.beforeKey), initialPart, keyResult, suffix]
  rw [run]
  refine ⟨namedGood, ⟨rfl, rfl, namedPending, .inl rfl⟩, ?_, fun _ => rfl, rfl, rfl⟩
  change document.leading.length + 1 + document.beforeKey.length + (document.key.length + 2) + document.beforeColon.length + 1 + document.afterColon.length + 1 = _
  simp only [JSON.DocumentSpan.header, List.length_append, List.length_cons, List.length_nil]
  omega

end Silver.ImageModel.ScannerNative
