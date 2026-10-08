import Silver.Admission

/-! Ada doubled-quote string literals over printable ASCII. This grammar reads
the tail after the opening delimiter. A pair of quotes denotes one quote;
a lone quote closes the literal. No whitespace or comment processing occurs
inside a literal. -/

namespace Silver.Output

def printable (byte : Nat) : Bool := decide (32 ≤ byte ∧ byte ≤ 126)

def startsQuote : Source → Bool
  | [] => false
  | byte :: _ => byte == 34

def literalTail : Source → Option (Source × Source)
  | [] => none
  | byte :: rest =>
    if byte = 34 then
      if startsQuote rest then
        (literalTail rest.tail).map (fun (value, remaining) => (34 :: value, remaining))
      else some ([], rest)
    else if printable byte then
      (literalTail rest).map (fun (value, remaining) => (byte :: value, remaining))
    else none
termination_by text => text.length
decreasing_by all_goals simp_wf; all_goals omega

/-- Declarative literal derivations, independent of any prover invocation. -/
inductive LiteralTail : Source → Source → Source → Prop
  | close {rest : Source} : startsQuote rest = false → LiteralTail (34 :: rest) [] rest
  | quote {text value rest : Source} : LiteralTail text value rest →
      LiteralTail (34 :: 34 :: text) (34 :: value) rest
  | character {byte : Nat} {text value rest : Source} :
      byte ≠ 34 → printable byte = true → LiteralTail text value rest →
      LiteralTail (byte :: text) (byte :: value) rest

theorem literalTail_complete {text value rest : Source}
    (derivation : LiteralTail text value rest) : literalTail text = some (value, rest) := by
  induction derivation with
  | close ending => simp [literalTail, ending]
  | quote previous ih => simp [literalTail, startsQuote, ih]
  | character different character previous ih => simp [literalTail, different, character, ih]

theorem literalTail_sound (text : Source) (value rest : Source)
    (parsed : literalTail text = some (value, rest)) : LiteralTail text value rest := by
  cases text with
    | nil => simp [literalTail] at parsed
    | cons byte tail =>
      by_cases quote : byte = 34
      · subst byte
        by_cases next : startsQuote tail = true
        · cases tail with
          | nil => simp [startsQuote] at next
          | cons byte tail =>
            have byteQuote : byte = 34 := by simpa [startsQuote] using next
            subst byte
            simp only [literalTail, startsQuote, BEq.rfl, ↓reduceIte, List.tail_cons] at parsed
            cases recursive : literalTail tail with
            | none => simp [recursive] at parsed
            | some pair =>
              obtain ⟨decoded, remaining⟩ := pair
              simp only [recursive, Option.map_some, Option.some.injEq, Prod.mk.injEq] at parsed
              obtain ⟨rfl, rfl⟩ := parsed
              exact .quote (literalTail_sound tail decoded remaining recursive)
        · have ending : startsQuote tail = false := Bool.eq_false_iff.mpr next
          simp only [literalTail, ↓reduceIte, ending, Bool.false_eq_true, ↓reduceIte,
            Option.some.injEq, Prod.mk.injEq] at parsed
          obtain ⟨rfl, rfl⟩ := parsed
          exact .close ending
      · by_cases character : printable byte = true
        · simp only [literalTail, quote, ↓reduceIte, character] at parsed
          cases recursive : literalTail tail with
          | none => simp [recursive] at parsed
          | some pair =>
            obtain ⟨decoded, remaining⟩ := pair
            simp only [recursive, Option.map_some, Option.some.injEq, Prod.mk.injEq] at parsed
            obtain ⟨rfl, rfl⟩ := parsed
            exact .character quote character (literalTail_sound tail decoded remaining recursive)
        · simp [literalTail, quote, character] at parsed

termination_by text.length

theorem literalTail_iff (text value rest : Source) :
    literalTail text = some (value, rest) ↔ LiteralTail text value rest :=
  ⟨literalTail_sound text value rest, literalTail_complete⟩

theorem literal_printable {text value rest : Source} (h : LiteralTail text value rest) :
    ∀ byte ∈ value, printable byte = true := by
  induction h with
  | close => simp
  | quote previous ih => simp_all [printable]
  | character different character previous ih => simp_all

theorem literal_consumes {text value rest : Source} (h : LiteralTail text value rest) :
    value.length + rest.length < text.length := by
  induction h with
  | close => simp
  | quote previous ih => simp only [List.length_cons]; omega
  | character different character previous ih => simp only [List.length_cons]; omega

theorem literal_unique {text left right restLeft restRight : Source}
    (first : LiteralTail text left restLeft) (second : LiteralTail text right restRight) :
    left = right ∧ restLeft = restRight := by
  have equality := (literalTail_complete first).symm.trans (literalTail_complete second)
  simpa using equality

end Silver.Output
