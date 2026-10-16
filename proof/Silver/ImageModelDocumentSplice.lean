module

public import Silver.ImageModelDocumentSpan
public import Silver.ImageModelTheorySplice

@[expose] public section
namespace Silver.ImageModel

/-- A pair of insertions within a subdocument commutes with its unchanged
outer context. Both insertion offsets still refer to original bytes. -/
theorem splice_context (pre body post first second : List α) (a b : Nat)
    (ordered : a ≤ b) (bounded : b ≤ body.length) :
    splice (pre ++ body ++ post) first second (pre.length + a) (pre.length + b) =
      pre ++ splice body first second a b ++ post := by
  have aBound : a ≤ body.length := Nat.le_trans ordered bounded
  have takeLength : (body.take a).length = a := by simp [List.length_take, Nat.min_eq_left aBound]
  have middleLength : ((body.drop a).take (b-a)).length = b-a := by
    simp [List.length_take, List.length_drop, Nat.min_eq_left (by omega : b-a ≤ body.length-a)]
  have shape : (pre ++ body.take a) ++ (body.drop a).take (b-a) ++ (body.drop b ++ post) =
      pre ++ body ++ post := by
    calc
      _ = pre ++ (body.take a ++ (body.drop a).take (b-a) ++ body.drop b) ++ post := by
        simp only [List.append_assoc]
      _ = _ := by rw [input_segments body a b ordered]
  have firstLength : (pre ++ body.take a).length = pre.length + a := by simp only [List.length_append, takeLength]
  have secondLength : (pre ++ body.take a).length + ((body.drop a).take (b-a)).length = pre.length+b := by
    rw [firstLength, middleLength]; omega
  have result := splice_segments (pre ++ body.take a) ((body.drop a).take (b-a))
    (body.drop b ++ post) first second
  rw [shape, secondLength, firstLength] at result
  simpa only [splice, List.append_assoc] using result

end Silver.ImageModel

namespace Silver.ImageModel.JSON

/-- Replacing one theory preserves the spelling of all other entries, even
when those contain non-ASCII strings. The replacement is a general JSON value;
it need not satisfy the original producer node-ID bound. -/
theorem entries_replace_spelling (before : List TheoryEntry) (entry : TheoryEntry)
    (after : List TheoryEntry) (value : Value) (input : List Nat)
    (replacement : CodeUnitSpelling value input) :
    CodeUnitElements (before.map TheoryEntry.value ++ value :: after.map TheoryEntry.value)
      (entryPrefix before ++ entry.leading ++ input ++ entry.trailing ++ entrySuffix after) := by
  induction before with
  | nil =>
      cases after with
      | nil =>
          simpa only [List.map_nil, List.nil_append, entryPrefix, entrySuffix, ↓reduceIte,
            List.append_nil, List.append_assoc] using
            CodeUnitElements.single value entry.leading input entry.trailing entry.before replacement entry.after
      | cons head rest =>
          have tail := entries_spelling (head :: rest)
          simpa only [List.map_nil, List.nil_append, entryPrefix, entrySuffix, List.cons_ne_nil,
            ↓reduceIte, List.append_assoc] using
            CodeUnitElements.more value ((head :: rest).map TheoryEntry.value) entry.leading input entry.trailing
              (entriesBytes (head :: rest)) (by simp) entry.before replacement entry.after tail
  | cons head before ih =>
      have joined := CodeUnitElements.more head.value
        (before.map TheoryEntry.value ++ value :: after.map TheoryEntry.value)
        head.leading head.span.bytes head.trailing
        (entryPrefix before ++ entry.leading ++ input ++ entry.trailing ++ entrySuffix after)
        (by simp) head.before head.span.original_spelling head.after ih
      cases before <;>
        simpa only [entryPrefix, entriesBytes, TheoryEntry.bytes, List.cons_ne_nil, ↓reduceIte,
          List.map_cons, List.cons_append, List.nil_append, List.append_assoc] using joined

/-- Restoring the original root context around a replacement theory yields
exactly the original theory list with that one value replaced. The outer
whitespace is retained separately from the syntactic root object. -/
theorem DocumentSpan.replace_entry_spelling (document : DocumentSpan)
    (before : List TheoryEntry) (entry : TheoryEntry) (after : List TheoryEntry)
    (value : Value) (input : List Nat) (replacement : CodeUnitSpelling value input) :
    ∃ core,
      (document.header ++ entryPrefix before ++ entry.leading) ++ input ++
        (entry.trailing ++ entrySuffix after ++ document.footer) = document.leading ++ core ++ document.trailing ∧
      CodeUnitSpelling (.object [(ascii "theory_declarations",
        .array (before.map TheoryEntry.value ++ value :: after.map TheoryEntry.value))]) core := by
  let values := before.map TheoryEntry.value ++ value :: after.map TheoryEntry.value
  let list := entryPrefix before ++ entry.leading ++ input ++ entry.trailing ++ entrySuffix after
  let member := document.beforeKey ++ [34] ++ document.key ++ [34] ++ document.beforeColon ++ [58] ++
    document.afterColon ++ ([91] ++ list ++ [93]) ++ document.afterList
  refine ⟨[123] ++ member ++ [125], ?_, ?_⟩
  · simp only [DocumentSpan.header, DocumentSpan.footer, member, list, List.append_assoc]
  · exact CodeUnitSpelling.object _ member
      (CodeUnitMembers.single (ascii "theory_declarations") (.array values)
        document.beforeKey document.key document.beforeColon document.afterColon
        ([91] ++ list ++ [93]) document.afterList document.beforeKeySpace document.keyContent
        document.beforeColonSpace document.afterColonSpace
        (.array values list (entries_replace_spelling before entry after value input replacement)) document.afterListSpace)

/-- The whole-document result follows from original-byte cuts within the
selected theory and a proved replacement spelling. The selected occurrence and
its local offsets are derived separately by the initialized scanner endpoint. -/
theorem DocumentSpan.spliced_entry_spelling (document : DocumentSpan)
    (before : List TheoryEntry) (entry : TheoryEntry) (after : List TheoryEntry)
    (position : document.entries = before ++ entry :: after)
    (first second : List Nat) (a b : Nat) (ordered : a ≤ b) (bounded : b ≤ entry.span.bytes.length)
    (value : Value) (replacement : CodeUnitSpelling value (splice entry.span.bytes first second a b)) :
    let start := (document.header ++ entryPrefix before ++ entry.leading).length
    ∃ core,
      splice document.bytes first second (start+a) (start+b) = document.leading ++ core ++ document.trailing ∧
      CodeUnitSpelling (.object [(ascii "theory_declarations",
        .array (before.map TheoryEntry.value ++ value :: after.map TheoryEntry.value))]) core := by
  dsimp only
  rw [document.split_entry before entry after position, splice_context _ _ _ _ _ a b ordered bounded]
  exact document.replace_entry_spelling before entry after value _ replacement

end Silver.ImageModel.JSON
