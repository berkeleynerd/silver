module

public import Silver.ImageModelJsonSimulation

@[expose] public section
namespace Silver.ImageModel.JSON

/-- The scanner's canonical character fragment is itself a valid JSON spelling
of that character throughout the ASCII domain. -/
theorem CharacterEncoding.canonical (code : Nat) (ascii : code < 127) :
    CharacterEncoding code (DecodedNative.normalizedCode code) := by
  by_cases quote : code = 34
  · subst code; exact .short 34 34 rfl
  by_cases escape : code = 92
  · subst code; exact .short 92 92 rfl
  have unescaped : ¬ (code = 34 ∨ code = 92) := by simp [quote, escape]
  by_cases control : code < 32
  · by_cases eight : code = 8
    · subst code; exact .short 98 8 rfl
    by_cases nine : code = 9
    · subst code; exact .short 116 9 rfl
    by_cases ten : code = 10
    · subst code; exact .short 110 10 rfl
    by_cases twelve : code = 12
    · subst code; exact .short 102 12 rfl
    by_cases thirteen : code = 13
    · subst code; exact .short 114 13 rfl
    have highBound : code / 16 < 16 := by omega
    have lowBound : code % 16 < 16 := Nat.mod_lt _ (by decide)
    have high := HexNative.table_decodes ⟨code / 16, highBound⟩
    have low := HexNative.table_decodes ⟨code % 16, lowBound⟩
    have decoded : unicodeValue 48 48 (DecodedNative.hexByte (code / 16)) (DecodedNative.hexByte (code % 16)) = code := by
      simp only [unicodeValue, show Core.hexadecimal 48 = 0 from rfl, high, low,
        Nat.zero_mul, Nat.zero_add]
      omega
    have result := CharacterEncoding.unicode 48 48
      (DecodedNative.hexByte (code / 16)) (DecodedNative.hexByte (code % 16))
      (by decide +kernel) (by decide +kernel) (by rw [high]; exact highBound)
      (by rw [low]; exact lowBound) (by rw [decoded]; exact ascii)
    rw [decoded] at result
    simpa only [DecodedNative.normalizedCode, ite_eq_right unescaped, ite_eq_left control,
      eight, nine, ten, twelve, thirteen] using result
  · simpa only [DecodedNative.normalizedCode, ite_eq_right unescaped, ite_eq_right control] using
      CharacterEncoding.plain code (by omega) ascii quote escape

theorem StringContent.ascii {characters input : List Nat} (content : StringContent characters input) :
    ∀ code ∈ characters, code < 127 := by
  induction content with
  | nil => simp
  | cons code characters spelling rest character tail ih =>
      intro value member
      rcases List.mem_cons.mp member with equal | member
      · simpa only [equal] using character.ascii
      · exact ih value member

theorem StringContent.canonical_of_ascii (characters : List Nat)
    (ascii : ∀ code ∈ characters, code < 127) :
    StringContent characters (characters.flatMap DecodedNative.normalizedCode) := by
  induction characters with
  | nil => exact .nil
  | cons code characters ih =>
      exact .cons code characters _ _ (CharacterEncoding.canonical code (ascii code (by simp)))
        (ih (fun value member => ascii value (by simp [member])))

theorem StringContent.canonical {characters input : List Nat} (content : StringContent characters input) :
    StringContent characters (characters.flatMap DecodedNative.normalizedCode) :=
  canonical_of_ascii characters content.ascii

theorem elements_canonical (values : List Value)
    (valid : ∀ value ∈ values, AsciiSpelling value value.encode) :
    AsciiElements values (separated (values.map Value.encode)) := by
  induction values with
  | nil => exact .empty [] (by simp [ScannerNative.Whitespace])
  | cons value rest ih =>
      cases rest with
      | nil =>
          simpa [separated] using AsciiElements.single value [] value.encode []
            (by simp [ScannerNative.Whitespace]) (valid value (by simp)) (by simp [ScannerNative.Whitespace])
      | cons next rest =>
          rw [ScannerNative.separated_cons value (next :: rest) (by simp)]
          simpa only [List.nil_append, List.append_nil] using
            AsciiElements.more value (next :: rest) [] value.encode []
              (separated ((next :: rest).map Value.encode)) (by simp)
              (by simp [ScannerNative.Whitespace]) (valid value (by simp))
              (by simp [ScannerNative.Whitespace]) (ih (fun item member => valid item (by simp [member])))

theorem members_canonical (members : List (List Nat × Value))
    (valid : ∀ member ∈ members,
      (∀ code ∈ member.1, code < 127) ∧ AsciiSpelling member.2 member.2.encode) :
    AsciiMembers members (separated (members.map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode))) := by
  induction members with
  | nil => exact .empty [] (by simp [ScannerNative.Whitespace])
  | cons member rest ih =>
      obtain ⟨name, value⟩ := member
      have item := valid (name, value) (by simp)
      have key := StringContent.canonical_of_ascii name item.1
      cases rest with
      | nil =>
          simpa [separated, stringBytes, List.append_assoc] using
            AsciiMembers.single name value [] _ [] [] value.encode []
              (by simp [ScannerNative.Whitespace]) key (by simp [ScannerNative.Whitespace])
              (by simp [ScannerNative.Whitespace]) item.2 (by simp [ScannerNative.Whitespace])
      | cons next rest =>
          have tail := ih (fun value member => valid value (by simp [member]))
          simpa [separated, stringBytes, List.intersperse_cons_cons, List.append_assoc] using
            AsciiMembers.more name value (next :: rest) [] _ [] [] value.encode []
              (separated ((next :: rest).map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode)))
              (by simp) (by simp [ScannerNative.Whitespace]) key (by simp [ScannerNative.Whitespace])
              (by simp [ScannerNative.Whitespace]) item.2 (by simp [ScannerNative.Whitespace]) tail

mutual
  /-- Any valid ASCII spelling has a valid canonical spelling of the same JSON
value. Numeric lexemes are retained rather than silently canonicalized. -/
  theorem AsciiSpelling.canonical (value : Value) (input : List Nat) (spelling : AsciiSpelling value input) :
      AsciiSpelling value value.encode := by
    cases spelling with
    | null => simpa only [Value.encode] using AsciiSpelling.null
    | true => simpa only [Value.encode] using AsciiSpelling.true
    | false => simpa only [Value.encode] using AsciiSpelling.false
    | number _ valid => simpa only [Value.encode] using AsciiSpelling.number input valid
    | string characters bytes content => simpa only [Value.encode, stringBytes] using AsciiSpelling.string characters _ content.canonical
    | array values bytes entries => simpa only [Value.encode] using AsciiSpelling.array values _ (AsciiElements.canonical values bytes entries)
    | object members bytes entries => simpa only [Value.encode] using AsciiSpelling.object members _ (AsciiMembers.canonical members bytes entries)
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem AsciiElements.canonical (values : List Value) (input : List Nat) (entries : AsciiElements values input) :
      AsciiElements values (separated (values.map Value.encode)) := by
    cases entries with
    | empty => exact .empty [] (by simp [ScannerNative.Whitespace])
    | single value leading bytes trailing before item after =>
        simpa [separated] using AsciiElements.single value [] value.encode []
          (by simp [ScannerNative.Whitespace]) (AsciiSpelling.canonical value bytes item) (by simp [ScannerNative.Whitespace])
    | more value values leading bytes spaces rest nonempty before item between tail =>
        have first := AsciiSpelling.canonical value bytes item
        have remaining := AsciiElements.canonical values rest tail
        rw [ScannerNative.separated_cons value values nonempty]
        simpa only [List.nil_append, List.append_nil] using
          AsciiElements.more value values [] value.encode [] _ nonempty
            (by simp [ScannerNative.Whitespace]) first (by simp [ScannerNative.Whitespace]) remaining
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem AsciiMembers.canonical (members : List (List Nat × Value)) (input : List Nat) (entries : AsciiMembers members input) :
      AsciiMembers members (separated (members.map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode))) := by
    cases entries with
    | empty => exact .empty [] (by simp [ScannerNative.Whitespace])
    | single name value leading key left right bytes trailing before nameBytes beforeColon afterColon item after =>
        simpa [separated, stringBytes, List.append_assoc] using
          AsciiMembers.single name value [] _ [] [] value.encode []
            (by simp [ScannerNative.Whitespace]) nameBytes.canonical (by simp [ScannerNative.Whitespace])
            (by simp [ScannerNative.Whitespace]) (AsciiSpelling.canonical value bytes item) (by simp [ScannerNative.Whitespace])
    | more name value members leading key left right bytes spaces rest nonempty before nameBytes beforeColon afterColon item between tail =>
        have first := AsciiSpelling.canonical value bytes item
        have remaining := AsciiMembers.canonical members rest tail
        cases members with
        | nil => contradiction
        | cons next members =>
            simpa [separated, stringBytes, List.intersperse_cons_cons, List.append_assoc] using
              AsciiMembers.more name value (next :: members) [] _ [] [] value.encode [] _ (by simp)
                (by simp [ScannerNative.Whitespace]) nameBytes.canonical (by simp [ScannerNative.Whitespace])
                (by simp [ScannerNative.Whitespace]) first (by simp [ScannerNative.Whitespace]) remaining
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

mutual
  theorem NormalValue.canonical (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (normal : NormalValue previous pending value input normalized outgoing) :
      AsciiSpelling normalized normalized.encode := by
    cases normal with
    | null => simpa only [Value.encode] using AsciiSpelling.null
    | true => simpa only [Value.encode] using AsciiSpelling.true
    | false => simpa only [Value.encode] using AsciiSpelling.false
    | number _ _ valid => simpa only [Value.encode] using AsciiSpelling.number input valid
    | id => simpa only [Value.encode] using AsciiSpelling.number [48] IntegerToken.zero
    | string _ characters bytes content => simpa only [Value.encode, stringBytes] using AsciiSpelling.string characters _ content.canonical
    | array _ values normalized bytes entries => simpa only [Value.encode] using AsciiSpelling.array normalized _ (NormalElements.canonical true false values normalized bytes entries)
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem NormalElements.canonical (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (normal : NormalElements previous pending values input normalized) :
      AsciiElements normalized (separated (normalized.map Value.encode)) := by
    cases normal with
    | empty => exact .empty [] (by simp [ScannerNative.Whitespace])
    | single _ _ value normalized leading bytes trailing before item after =>
        simpa [separated] using AsciiElements.single normalized [] normalized.encode []
          (by simp [ScannerNative.Whitespace]) (NormalValue.canonical previous pending false value normalized bytes item)
          (by simp [ScannerNative.Whitespace])
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        have first := NormalValue.canonical previous pending outgoing value normalized bytes item
        have remaining := NormalElements.canonical false outgoing values restNormalized rest tail
        rw [ScannerNative.separated_cons normalized restNormalized (tail.output_nonempty nonempty)]
        simpa only [List.nil_append, List.append_nil] using
          AsciiElements.more normalized restNormalized [] normalized.encode [] _ (tail.output_nonempty nonempty)
            (by simp [ScannerNative.Whitespace]) first (by simp [ScannerNative.Whitespace]) remaining
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

mutual
  /-- Normalization carries an independently valid spelling of the original
value, preserving its original whitespace, escapes and numeric ID digits. -/
  theorem NormalValue.original_spelling (previous pending outgoing : Bool) (value normalized : Value) (input : List Nat)
      (normal : NormalValue previous pending value input normalized outgoing) :
      AsciiSpelling value input := by
    cases normal with
    | null => exact .null
    | true => exact .true
    | false => exact .false
    | number _ _ valid => exact .number input valid
    | id _ first rest valid _ _ => exact .number (first :: rest) valid
    | string _ characters bytes content => exact .string characters bytes content
    | array _ values normalized bytes entries =>
        exact .array values bytes (NormalElements.original_spelling true false values normalized bytes entries)
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem NormalElements.original_spelling (previous pending : Bool) (values normalized : List Value) (input : List Nat)
      (normal : NormalElements previous pending values input normalized) :
      AsciiElements values input := by
    cases normal with
    | empty _ _ whitespace => exact .empty input whitespace
    | single _ _ value normalized leading bytes trailing before item after =>
        simpa only [List.append_assoc] using AsciiElements.single value leading bytes trailing before
          (NormalValue.original_spelling previous pending false value normalized bytes item) after
    | more _ _ outgoing value normalized values restNormalized leading bytes spaces rest nonempty before item between tail =>
        simpa only [List.append_assoc] using AsciiElements.more value values leading bytes spaces rest nonempty before
          (NormalValue.original_spelling previous pending outgoing value normalized bytes item) between
          (NormalElements.original_spelling false outgoing values restNormalized rest tail)
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

/-- Validity is witnessed by syntax, independently of any external parser. -/
def Valid (value : Value) : Prop := ∃ input, AsciiSpelling value input

theorem Valid.canonical {value : Value} (valid : Valid value) : AsciiSpelling value value.encode := by
  obtain ⟨input, spelling⟩ := valid
  exact spelling.canonical value input

end Silver.ImageModel.JSON
