module

public import Silver.ImageModelJsonMeaning
public import Silver.ImageModelCharacter

@[expose] public section
namespace Silver.ImageModel.JSON

/-- A mathematical decoder for the canonical encodings used in the schema
argument. It is proof machinery, not a replacement for the native scanner or
the external JSON consumer. Its round-trip law will remove the external
parser premise from the internal equality step. -/
def characterWidth (input : List Nat) : Nat :=
  if input.head? = some 92 then
    if input[1]? = some 117 then 6 else 2
  else 1

def readCharacter (input : List Nat) : Option (Nat × List Nat) := do
  let width := characterWidth input
  let code ← decodeFragment (input.take width)
  pure (code, input.drop width)

theorem normalized_width (code : Nat) (rest : List Nat) :
    characterWidth (DecodedNative.normalizedCode code ++ rest) =
      (DecodedNative.normalizedCode code).length := by
  unfold DecodedNative.normalizedCode
  split
  · rename_i special
    rcases special with equal | equal <;> subst code <;> simp [characterWidth]
  · split
    · rename_i small
      split <;> simp [characterWidth]
    · simp_all [characterWidth]

theorem readCharacter_roundtrip (code : Nat) (ascii : code < 127) (rest : List Nat) :
    readCharacter (DecodedNative.normalizedCode code ++ rest) = some (code, rest) := by
  simp only [readCharacter, normalized_width, List.take_left, List.drop_left,
    fragment_roundtrip ⟨code, ascii⟩]
  rfl

def readString : Nat → List Nat → Option (List Nat × List Nat)
  | 0, _ => none
  | fuel + 1, input =>
      if input.head? = some 34 then some ([], input.drop 1)
      else do
        let (code, rest) ← readCharacter input
        let (characters, trailing) ← readString fuel rest
        pure (code :: characters, trailing)

def numberByte (byte : Nat) : Bool := decide (byte = 45 ∨ 48 ≤ byte ∧ byte ≤ 57)

def readNumber (input : List Nat) : Value × List Nat :=
  (.number (input.takeWhile numberByte), input.dropWhile numberByte)


theorem normalized_head (code : Nat) (rest : List Nat) :
    (DecodedNative.normalizedCode code ++ rest).head? ≠ some 34 := by
  unfold DecodedNative.normalizedCode
  split
  · simp
  · split
    · split <;> simp
    · simp_all

theorem readString_roundtrip (characters : List Nat)
    (ascii : ∀ code ∈ characters, code < 127) (rest : List Nat)
    (fuel : Nat) (enough : characters.length < fuel) :
    readString fuel (characters.flatMap DecodedNative.normalizedCode ++ 34 :: rest) =
      some (characters, rest) := by
  induction characters generalizing fuel with
  | nil =>
      cases fuel with
      | zero => simp at enough
      | succ fuel => simp [readString]
  | cons code characters ih =>
      cases fuel with
      | zero => simp at enough
      | succ fuel =>
          have codeAscii := ascii code (by simp)
          have tailAscii : ∀ code ∈ characters, code < 127 := fun c hc => ascii c (by simp [hc])
          have tailRoom : characters.length < fuel := by simp only [List.length_cons] at enough; omega
          simp only [List.flatMap_cons, List.append_assoc]
          rw [readString, ite_eq_right (normalized_head code _),
            readCharacter_roundtrip code codeAscii]
          dsimp only [Bind.bind, Option.bind]
          rw [ih tailAscii fuel tailRoom]
          rfl

theorem IntegerToken.numberBytes {bytes : List Nat} (token : IntegerToken bytes) :
    ∀ byte ∈ bytes, numberByte byte = true := by
  cases token with
  | zero | negativeZero => simp [numberByte]
  | positive first rest nonzero digits =>
      intro byte member
      rcases List.mem_cons.mp member with equal | member
      · subst byte; simp only [numberByte, decide_eq_true_eq]; omega
      · simp only [numberByte, decide_eq_true_eq]; exact Or.inr (digits byte member)
  | negative first rest nonzero digits =>
      intro byte member
      rcases List.mem_cons.mp member with equal | member
      · subst byte; rfl
      rcases List.mem_cons.mp member with equal | member
      · subst byte; simp only [numberByte, decide_eq_true_eq]; omega
      · simp only [numberByte, decide_eq_true_eq]; exact Or.inr (digits byte member)

theorem readNumber_roundtrip (bytes : List Nat) (valid : IntegerToken bytes)
    (stop : Nat) (rest : List Nat) (boundary : numberByte stop = false) :
    readNumber (bytes ++ stop :: rest) = (.number bytes, stop :: rest) := by
  simp [readNumber, List.takeWhile_append_of_pos valid.numberBytes,
    List.dropWhile_append_of_pos valid.numberBytes, boundary]

mutual
  /-- This decoder is used only in a round-trip proof for independently valid
  canonical values. No parsing-success claim about external tools follows. -/
  def readValue : Nat → List Nat → Option (Value × List Nat)
    | 0, _ => none
    | fuel + 1, input =>
      if input.head? = some 110 then some (.null, input.drop 4)
      else if input.head? = some 116 then some (.boolean true, input.drop 4)
      else if input.head? = some 102 then some (.boolean false, input.drop 5)
      else if input.head? = some 34 then do
        let (characters, tail) ← readString fuel (input.drop 1)
        pure (.string characters, tail)
      else if input.head? = some 91 then do
        let (values, tail) ← readElements fuel (input.drop 1)
        pure (.array values, tail)
      else if input.head? = some 123 then do
        let (members, tail) ← readMembers fuel (input.drop 1)
        pure (.object members, tail)
      else some (readNumber input)

  def readElements : Nat → List Nat → Option (List Value × List Nat)
    | 0, _ => none
    | fuel + 1, input =>
      if input.head? = some 93 then some ([], input.drop 1)
      else (readValue fuel input).bind fun result =>
        if result.2.head? = some 93 then some ([result.1], result.2.drop 1)
        else if result.2.head? = some 44 then
          (readElements fuel (result.2.drop 1)).map fun tail => (result.1 :: tail.1, tail.2)
        else none

  def readMembers : Nat → List Nat → Option (List (List Nat × Value) × List Nat)
    | 0, _ => none
    | fuel + 1, input =>
      if input.head? = some 125 then some ([], input.drop 1)
      else if input.head? = some 34 then
        (readString fuel (input.drop 1)).bind fun name =>
          if name.2.head? = some 58 then
            (readValue fuel (name.2.drop 1)).bind fun value =>
              if value.2.head? = some 125 then some ([(name.1, value.1)], value.2.drop 1)
              else if value.2.head? = some 44 then
                (readMembers fuel (value.2.drop 1)).map fun tail => ((name.1, value.1) :: tail.1, tail.2)
              else none
          else none
      else none

end

theorem list_length_le_size (items : List Nat) : items.length ≤ sizeOf items := by
  induction items with
  | nil => simp
  | cons item items ih => simp only [List.length_cons, List.cons.sizeOf_spec]; omega

theorem IntegerToken.first_byte {bytes : List Nat} (token : IntegerToken bytes) :
    ∃ first rest, bytes = first :: rest ∧ (first = 45 ∨ 48 ≤ first ∧ first ≤ 57) := by
  cases token with
  | zero => exact ⟨48, [], rfl, Or.inr ⟨by decide, by decide⟩⟩
  | negativeZero => exact ⟨45, [48], rfl, Or.inl rfl⟩
  | positive first rest nonzero _ => exact ⟨first, rest, rfl, Or.inr (by omega)⟩
  | negative first rest _ _ => exact ⟨45, first :: rest, rfl, Or.inl rfl⟩

theorem AsciiSpelling.encode_not_close {value : Value} {input : List Nat}
    (spelling : AsciiSpelling value input) (rest : List Nat) :
    (value.encode ++ rest).head? ≠ some 93 := by
  cases spelling with
  | null | true | false | string | array | object => simp [Value.encode, stringBytes]
  | number bytes token =>
      obtain ⟨first, tail, rfl, domain⟩ := token.first_byte
      simp only [Value.encode, List.cons_append, List.head?_cons, ne_eq, Option.some.injEq]
      omega

theorem readValue_number (bytes : List Nat) (valid : IntegerToken bytes)
    (stop : Nat) (rest : List Nat) (boundary : numberByte stop = false) (fuel : Nat) :
    readValue (fuel + 1) (bytes ++ stop :: rest) = some (.number bytes, stop :: rest) := by
  have roundtrip := readNumber_roundtrip bytes valid stop rest boundary
  obtain ⟨first, tail, rfl, domain⟩ := valid.first_byte
  have a : first ≠ 110 := by omega
  have b : first ≠ 116 := by omega
  have c : first ≠ 102 := by omega
  have d : first ≠ 34 := by omega
  have e : first ≠ 91 := by omega
  have f : first ≠ 123 := by omega
  simpa only [readValue, List.cons_append, List.head?_cons, Option.some.injEq,
    a, b, c, d, e, f, ↓reduceIte] using congrArg some roundtrip

mutual
  theorem readValue_roundtrip (value : Value) (input : List Nat)
      (spelling : AsciiSpelling value input) (stop : Nat) (rest : List Nat)
      (boundary : numberByte stop = false) (fuel : Nat) (enough : 2 * sizeOf value < fuel) :
      readValue fuel (value.encode ++ stop :: rest) = some (value, stop :: rest) := by
    cases fuel with
    | zero => omega
    | succ fuel =>
      cases spelling with
      | null => simp [Value.encode, readValue]
      | true => simp [Value.encode, readValue]
      | false => simp [Value.encode, readValue]
      | number _ valid => simpa only [Value.encode] using readValue_number input valid stop rest boundary fuel
      | string characters bytes content =>
          have room : characters.length < fuel := by
            have h := list_length_le_size characters
            simp only [Value.string.sizeOf_spec] at enough
            omega
          simp [Value.encode, stringBytes, List.append_assoc, readValue,
            readString_roundtrip characters content.ascii (stop :: rest) fuel room]
      | array values bytes entries =>
          have room : 2 * sizeOf values < fuel := by
            simp only [Value.array.sizeOf_spec] at enough; omega
          simp [Value.encode, List.append_assoc, readValue,
            readElements_roundtrip values bytes entries (stop :: rest) fuel room]
      | object members bytes entries =>
          have room : 2 * sizeOf members < fuel := by
            simp only [Value.object.sizeOf_spec] at enough; omega
          have parsed := readMembers_roundtrip members bytes entries (stop :: rest) fuel room
          simp only [List.singleton_append, List.append_assoc] at parsed
          simp [Value.encode, List.append_assoc, readValue, parsed]
  termination_by input.length * 2
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem readElements_roundtrip (values : List Value) (input : List Nat)
      (entries : AsciiElements values input) (rest : List Nat)
      (fuel : Nat) (enough : 2 * sizeOf values < fuel) :
      readElements fuel (separated (values.map Value.encode) ++ 93 :: rest) = some (values, rest) := by
    cases fuel with
    | zero => omega
    | succ fuel =>
      cases entries with
      | empty => simp [separated, readElements]
      | single value leading bytes trailing before item after =>
          have room : 2 * sizeOf value < fuel := by
            simp only [List.cons.sizeOf_spec, List.nil.sizeOf_spec] at enough; omega
          simp only [List.map_cons, List.map_nil, separated, List.intersperse_singleton,
            List.flatten_cons, List.flatten_nil, List.append_nil, readElements]
          rw [ite_eq_right (item.encode_not_close _), readValue_roundtrip value bytes item 93 rest (by decide) fuel room]
          rfl
      | more value values leading bytes spaces tail nonempty before item between entries =>
          have firstRoom : 2 * sizeOf value < fuel := by
            simp only [List.cons.sizeOf_spec] at enough; omega
          have tailRoom : 2 * sizeOf values < fuel := by
            simp only [List.cons.sizeOf_spec] at enough; omega
          rw [ScannerNative.separated_cons value values nonempty]
          simp only [List.append_assoc, List.cons_append, List.nil_append, readElements]
          rw [ite_eq_right (item.encode_not_close _), readValue_roundtrip value bytes item 44
            (separated (values.map Value.encode) ++ 93 :: rest) (by decide) fuel firstRoom]
          simp only [Option.bind_some, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          rw [readElements_roundtrip values tail entries rest fuel tailRoom]
          rfl
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega

  theorem readMembers_roundtrip (members : List (List Nat × Value)) (input : List Nat)
      (entries : AsciiMembers members input) (rest : List Nat)
      (fuel : Nat) (enough : 2 * sizeOf members < fuel) :
      readMembers fuel (separated (members.map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode)) ++ 125 :: rest) =
        some (members, rest) := by
    cases fuel with
    | zero => omega
    | succ fuel =>
      cases entries with
      | empty => simp [separated, readMembers]
      | single name value leading key left right bytes trailing before nameBytes beforeColon afterColon item after =>
          have room : 2 * sizeOf value < fuel := by
            simp only [List.cons.sizeOf_spec, List.nil.sizeOf_spec, Prod.mk.sizeOf_spec] at enough; omega
          have nameRoom : name.length < fuel := by
            have h := list_length_le_size name
            simp only [List.cons.sizeOf_spec, List.nil.sizeOf_spec, Prod.mk.sizeOf_spec] at enough; omega
          simp only [List.map_cons, List.map_nil, separated, List.intersperse_singleton,
            List.flatten_cons, List.flatten_nil, List.append_nil, stringBytes,
            List.append_assoc, List.cons_append, List.nil_append, readMembers, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          rw [readString_roundtrip name nameBytes.ascii _ fuel nameRoom]
          simp only [Option.bind_some, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          rw [readValue_roundtrip value bytes item 125 rest (by decide) fuel room]
          rfl
      | more name value members leading key left right bytes spaces tail nonempty before nameBytes beforeColon afterColon item between entries =>
          have room : 2 * sizeOf value < fuel := by
            simp only [List.cons.sizeOf_spec, Prod.mk.sizeOf_spec] at enough; omega
          have tailRoom : 2 * sizeOf members < fuel := by
            simp only [List.cons.sizeOf_spec, Prod.mk.sizeOf_spec] at enough; omega
          have nameRoom : name.length < fuel := by
            have h := list_length_le_size name
            simp only [List.cons.sizeOf_spec, Prod.mk.sizeOf_spec] at enough; omega
          have separatedMore : separated (((name,value) :: members).map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode)) =
              stringBytes name ++ [58] ++ value.encode ++ [44] ++
                separated (members.map (fun member => stringBytes member.1 ++ [58] ++ member.2.encode)) := by
            cases members with
            | nil => contradiction
            | cons next members => simp [separated, List.intersperse_cons_cons, List.append_assoc]
          rw [separatedMore]
          simp only [stringBytes, List.append_assoc, List.cons_append, List.nil_append, readMembers, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          rw [readString_roundtrip name nameBytes.ascii _ fuel nameRoom]
          simp only [Option.bind_some, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          rw [readValue_roundtrip value bytes item 44 _ (by decide) fuel room]
          simp only [Option.bind_some, List.head?_cons, List.drop_succ_cons, List.drop_zero, ↓reduceIte]
          have parsed := readMembers_roundtrip members tail entries rest fuel tailRoom
          simp only [stringBytes, List.append_assoc, List.cons_append, List.nil_append] at parsed
          rw [parsed]
          rfl
  termination_by input.length * 2 + 1
  decreasing_by all_goals subst input; simp only [List.length_append, List.length_cons, List.length_nil]; omega
end

/-- Canonical encoding is injective on independently valid ASCII JSON values.
The proof uses a terminating mathematical decoder and contains no external
parser premise. Numeric token spelling is retained, including negative zero. -/
theorem Valid.encode_injective {left right : Value} (a : Valid left) (b : Valid right)
    (equal : left.encode = right.encode) : left = right := by
  let fuel := 2 * sizeOf left + 2 * sizeOf right + 1
  obtain ⟨leftBytes, leftSpelling⟩ := a
  obtain ⟨rightBytes, rightSpelling⟩ := b
  have l := readValue_roundtrip left leftBytes leftSpelling 0 [] (by decide) fuel (by omega)
  have r := readValue_roundtrip right rightBytes rightSpelling 0 [] (by decide) fuel (by omega)
  rw [equal, r] at l
  exact (congrArg Prod.fst (Option.some.inj l)).symm

theorem Valid.canonical_meaning_eq {left right : Value} (a : Valid left) (b : Valid right)
    (equal : left.encode = right.encode) : left.meaning = right.meaning :=
  congrArg Value.meaning (a.encode_injective b equal)

end Silver.ImageModel.JSON
