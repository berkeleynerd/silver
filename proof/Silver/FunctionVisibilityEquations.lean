module

public import Silver.FunctionVisibilitySource
public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose.FunctionVisibilityNative
open Silver.Compose.Expressions

abbrev ValidText := FunctionBindings.Native.ValidText
abbrev NameSpan := FunctionBindings.NameSpan

def ValidWord (word : String) : Prop := 0 < word.toList.length ∧ word.toList.length ≤ 4096

structure Implementation where
  calls : Calls
  formalHides : Source → ParserState → Nat → Nat → Bool
  hiddenOuter : Source → ParserState → HiddenMarks
  hideName : Source → HiddenMarks → Nat → Nat → HiddenMarks

structure Primitives (calls : Calls) : Prop where
  nameIs : ∀ text, ValidText text → ∀ first after word,
    NameSpan text first after → ValidWord word →
    calls.nameIs text first after (word.toList.map Char.toNat) =
      Named.nameIs text first after (word.toList.map Char.toNat)
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    NameSpan text first after → NameSpan text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter

structure Equations (implementation : Implementation) : Prop where
  functionHides : ∀ text, ValidText text → ∀ catalog word,
    FunctionBindings.ValidMetadata text catalog → ValidWord word →
    implementation.calls.functionHides text catalog word = functionHidesBody.eval implementation.calls {text, catalog, word}
  formalHides : ∀ text, ValidText text → ∀ state first after,
    ValidState text state → first ≤ text.length + 1 → after ≤ text.length + 1 →
    implementation.formalHides text state first after = formalHidesBody.eval implementation.calls {text, state, first, after}
  hiddenWord : ∀ text, ValidText text → ∀ state word,
    ValidState text state → ValidWord word →
    implementation.calls.hiddenWord text state word = hiddenWordBody.eval implementation.calls {text, state, word}
  hiddenOuter : ∀ text, ValidText text → ∀ state,
    ValidState text state → implementation.hiddenOuter text state = evalMarks implementation.calls {text, state} hiddenOuterField
  hideName : ∀ text, ValidText text → ∀ flags first after,
    NameSpan text first after →
    implementation.hideName text flags first after = evalMarks implementation.calls {text, flags, first, after} hideNameField

private theorem any_congr_on {α : Type} (items : List α) (left right : α → Bool)
    (same : ∀ item ∈ items, left item = right item) : items.any left = items.any right := by
  induction items with
  | nil => rfl
  | cons item rest ih =>
      simp only [List.any_cons]
      rw [same item (by simp), ih (by intro value member; exact same value (by simp [member]))]

theorem functionHides_meaning (implementation : Implementation) (primitives : Primitives implementation.calls)
    (equations : Equations implementation) (text : Source) (textValid : ValidText text)
    (catalog : FunctionBindings.Metadata) (valid : FunctionBindings.ValidMetadata text catalog)
    (word : String) (wordValid : ValidWord word) :
    implementation.calls.functionHides text catalog word = Compose.functionHides text catalog word := by
  rw [equations.functionHides text textValid catalog word valid wordValid]
  dsimp only [functionHidesBody, Expr.eval, Compose.functionHides]
  apply any_congr_on
  intro item member
  exact primitives.nameIs text textValid item.first item.after word (valid.2.2.2 item member).1 wordValid

theorem formalHides_meaning (implementation : Implementation) (primitives : Primitives implementation.calls)
    (equations : Equations implementation) (text : Source) (textValid : ValidText text)
    (state : ParserState) (valid : ValidState text state) (first after : Nat)
    (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    implementation.formalHides text state first after = Compose.formalHides text state first after := by
  rw [equations.formalHides text textValid state first after valid firstBound afterBound]
  rw [← formalHides_model]
  dsimp only [formalHidesBody, Expr.eval, modelCalls]
  by_cases firstPositive : 0 < first
  · by_cases ordered : first < after
    · congr 1
      apply any_congr_on
      intro item member
      exact primitives.equalName text textValid item.first item.after first after
        ((valid.2.2.2.2.2.2.2.2.2.1).2.2.1 item (List.mem_of_mem_drop member)).1
        ⟨firstPositive, ordered, afterBound⟩
    · simp only [show ¬after > first from ordered, decide_false, Bool.and_false, Bool.false_and]
  · simp only [firstPositive, decide_false, Bool.false_and]

private theorem table_spans (text : Source) (state : ParserState) (valid : ValidState text state)
    (table : Table) (span : Nat × Nat) (member : span ∈ table.spans state) : NameSpan text span.1 span.2 := by
  rcases valid with ⟨_, names, _, _, _, scalars, arrays, subtypes, booleans, _, _, _⟩
  cases table with
  | strings =>
      dsimp only [Table.spans] at member
      obtain ⟨item, itemMember, rfl⟩ := List.mem_map.mp member
      exact (names.2 item itemMember).1
  | scalars =>
      dsimp only [Table.spans] at member
      obtain ⟨item, itemMember, rfl⟩ := List.mem_map.mp member
      exact ⟨(scalars.2 item itemMember).1, (scalars.2 item itemMember).2.1, (scalars.2 item itemMember).2.2.1⟩
  | booleans =>
      dsimp only [Table.spans] at member
      obtain ⟨item, itemMember, rfl⟩ := List.mem_map.mp member
      exact booleans.2 item itemMember
  | arrays =>
      dsimp only [Table.spans] at member
      obtain ⟨item, itemMember, rfl⟩ := List.mem_map.mp member
      exact ⟨(arrays.1.2.1 item itemMember).1, (arrays.1.2.1 item itemMember).2.1, (arrays.1.2.1 item itemMember).2.2.1⟩
  | subtypes =>
      dsimp only [Table.spans] at member
      obtain ⟨item, itemMember, rfl⟩ := List.mem_map.mp member
      exact ⟨(subtypes.2 item itemMember).1, (subtypes.2 item itemMember).2.1, (subtypes.2 item itemMember).2.2.1⟩

theorem hiddenWord_meaning (implementation : Implementation) (primitives : Primitives implementation.calls)
    (equations : Equations implementation) (text : Source) (textValid : ValidText text)
    (state : ParserState) (valid : ValidState text state) (word : String) (wordValid : ValidWord word) :
    implementation.calls.hiddenWord text state word = Compose.hiddenWord text state word := by
  rw [equations.hiddenWord text textValid state word valid wordValid, ← hiddenWord_model]
  have tableMeaning (table : Table) : (Expr.tableNames table).eval implementation.calls {text, state, word} =
      (Expr.tableNames table).eval modelCalls {text, state, word} := by
    apply any_congr_on
    intro span member
    exact primitives.nameIs text textValid span.1 span.2 word (table_spans text state valid table span member) wordValid
  dsimp only [hiddenWordBody, Expr.eval]
  rw [functionHides_meaning implementation primitives equations text textValid state.functions
    valid.2.2.2.2.2.2.2.2.2.1 word wordValid]
  dsimp only [Expr.eval] at tableMeaning
  rw [tableMeaning, tableMeaning, tableMeaning, tableMeaning, tableMeaning]
  rfl

private theorem mark_word_valid (mark : Mark) : ValidWord mark.word := by unfold ValidWord; cases mark <;> decide

theorem hiddenOuter_meaning (implementation : Implementation) (primitives : Primitives implementation.calls)
    (equations : Equations implementation) (text : Source) (textValid : ValidText text)
    (state : ParserState) (valid : ValidState text state) :
    implementation.hiddenOuter text state = Compose.hiddenOuter text state := by
  rw [equations.hiddenOuter text textValid state valid, ← hiddenOuter_model]
  have fields (mark : Mark) : (hiddenOuterField mark).eval implementation.calls {text, state} =
      (hiddenOuterField mark).eval modelCalls {text, state} := by
    dsimp only [hiddenOuterField, Expr.eval]
    rw [hiddenWord_meaning implementation primitives equations text textValid state valid mark.word (mark_word_valid mark)]
    rfl
  dsimp only [evalMarks]
  rw [fields, fields, fields, fields, fields]

theorem hideName_meaning (implementation : Implementation) (primitives : Primitives implementation.calls)
    (equations : Equations implementation) (text : Source) (textValid : ValidText text)
    (flags : HiddenMarks) (first after : Nat) (span : NameSpan text first after) :
    implementation.hideName text flags first after = Compose.hideName text flags first after := by
  rw [equations.hideName text textValid flags first after span, ← hideName_model]
  have fields (mark : Mark) : (hideNameField mark).eval implementation.calls {text, flags, first, after} =
      (hideNameField mark).eval modelCalls {text, flags, first, after} := by
    dsimp only [hideNameField, Expr.eval]
    rw [primitives.nameIs text textValid first after mark.word span (mark_word_valid mark)]
    rfl
  dsimp only [evalMarks]
  rw [fields, fields, fields, fields, fields]

end Silver.Compose.FunctionVisibilityNative
