module

public import Silver.ScalarExpressionBounds

@[expose] public section

/-! An independent, explicitly grouped grammar. Numeric terminals use the
integer-literal derivations; names use identifier derivations. No production
uses the scalar reader or interval admission as a premise. -/
namespace Silver.ScalarExpression

def NoIntegerAt (text : Source) (position : Nat) : Prop :=
  ¬ ∃ value finish, ScalarLiteral.IntegerAt text position value finish

theorem noInteger_iff (text : Source) (position : Nat) (bound : position ≤ text.length + 1) :
    NoIntegerAt text position ↔ (ScalarLiteral.read text position).after = 0 := by
  constructor
  · intro absent
    by_cases failed : (ScalarLiteral.read text position).after = 0
    · exact failed
    · exact False.elim (absent ⟨_, _, ScalarLiteral.read_sound bound failed⟩)
  · intro failed ⟨value, finish, parsed⟩
    have equation := ScalarLiteral.read_complete parsed
    have progress := (ScalarLiteral.integer_bounds parsed).1
    rw [equation] at failed
    dsimp only at failed
    omega

def Sign (byte : Nat) : Prop := byte = 43 ∨ byte = 45

def SymbolAt (text : Source) (position byte finish : Nat) : Prop :=
  skip text position ≠ 0 ∧ skip text position ≤ text.length ∧
    Cursor.byteAt text (skip text position) = byte ∧ finish = skip text position + 1

theorem symbolAt_iff {text : Source} {position byte finish : Nat} :
    SymbolAt text position byte finish ↔ symbol text position byte = finish ∧ finish ≠ 0 := by
  unfold SymbolAt symbol
  dsimp only
  constructor
  · rintro ⟨nonzero, within, byteFound, rfl⟩
    simp [nonzero, Nat.not_lt.mpr within, byteFound]
  · intro found
    split at found
    · omega
    · rename_i valid
      exact ⟨by omega, by omega, by omega, found.1.symm⟩

inductive AtomAt (text : Source) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (position : Nat) : Parsed → Prop
  | unsigned {value finish : Nat} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      ¬ Sign (Cursor.byteAt text (skip text position)) →
      ScalarLiteral.IntegerAt text (skip text position) value finish →
      AtomAt text names maskFirst maskAfter allowSign position
        ⟨finish, .literal (Int.ofNat value)⟩
  | signed {value finish : Nat} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      Sign (Cursor.byteAt text (skip text position)) → allowSign = true →
      ScalarLiteral.IntegerAt text (skip text (skip text position + 1)) value finish →
      AtomAt text names maskFirst maskAfter allowSign position
        ⟨finish, .literal (signedValue value (Cursor.byteAt text (skip text position) == 45))⟩
  | name {bytes : Source} {finish index : Nat} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      ¬ Sign (Cursor.byteAt text (skip text position)) →
      NoIntegerAt text (skip text position) →
      Named.IdentifierAt text (skip text position) bytes finish →
      lookup text names (skip text position) finish = index → index ≠ 0 →
      ¬ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter (skip text position) finish = true) →
      AtomAt text names maskFirst maskAfter allowSign position ⟨finish, .name index⟩

theorem atom_sound {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (found : atom text position names maskFirst maskAfter allowSign = some value) :
    AtomAt text names maskFirst maskAfter allowSign position value := by
  have first := skip_bounds text position bound
  unfold atom at found
  dsimp only at found
  split at found
  · cases found
  · rename_i valid
    split at found
    · rename_i sign
      split at found
      · cases found
      · rename_i allowed
        obtain ⟨numberGood, rfl⟩ := literal_result found
        have next := skip_bounds text (skip text position + 1) (by omega)
        exact .signed (by omega) (by omega) sign (by simpa using allowed)
          (ScalarLiteral.read_sound next.2 numberGood)
    · rename_i notSign
      split at found
      · obtain ⟨numberGood, rfl⟩ := literal_result found
        exact .unsigned (by omega) (by omega) notSign (ScalarLiteral.read_sound first.2 numberGood)
      · rename_i notNumber
        split at found
        · cases found
        · rename_i nameGood
          cases found
          have nonzero : nameAfter text (skip text position) ≠ 0 := by
            intro zero
            have zeroLookup : lookup text names (skip text position) 0 = 0 := by
              unfold lookup
              cases names.length <;> simp [lookupFrom]
            simp only [zero, zeroLookup, true_or, not_true_eq_false] at nameGood
          have afterEquation : nameAfter text (skip text position) = Named.identifierEnd text (skip text position) := by
            simp only [nameAfter, show skip text position ≠ 0 by omega, ↓reduceIte]
          obtain ⟨bytes, identifier⟩ := Named.identifierEnd_sound text (skip text position)
            (by simpa only [afterEquation] using nonzero)
          apply AtomAt.name (bytes := bytes) (by omega) (by omega) notSign
            ((noInteger_iff text _ first.2).mpr (by simpa using notNumber))
          · simpa only [afterEquation] using identifier
          · rfl
          · exact fun failed => nameGood (Or.inl failed)
          · exact fun masked => nameGood (Or.inr masked)

theorem atom_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (parsed : AtomAt text names maskFirst maskAfter allowSign position value) :
    atom text position names maskFirst maskAfter allowSign = some value := by
  have first := skip_bounds text position bound
  cases parsed with
  | unsigned nonzero within notSign number =>
      unfold Sign at notSign
      have numberEquation := ScalarLiteral.read_complete number
      have progress := ScalarLiteral.integer_bounds number
      simp [atom, nonzero, Nat.not_lt.mpr within, notSign, numberEquation,
        literal, show _ ≠ 0 from Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) progress.1), signedValue]
  | signed nonzero within sign allowed number =>
      unfold Sign at sign
      have numberEquation := ScalarLiteral.read_complete number
      have progress := ScalarLiteral.integer_bounds number
      simp [atom, nonzero, Nat.not_lt.mpr within, sign, allowed, numberEquation,
        literal, show _ ≠ 0 from Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) progress.1)]
  | name nonzero within notSign noNumber identifier found nonzeroIndex unmasked =>
      unfold Sign at notSign
      have numberEquation := (noInteger_iff text _ first.2).mp noNumber
      have nameEquation := Named.identifierEnd_complete identifier
      simp [atom, nonzero, Nat.not_lt.mpr within, notSign, numberEquation,
        nameAfter, nameEquation, found, nonzeroIndex, unmasked]

/-- Operator terminals are described independently of the operator reader. -/
inductive BinaryTokenAt (text : Source) (position : Nat) : Nat → Prop
  | symbol : 0 < position → position ≤ text.length →
      (Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45 ∨
        Cursor.byteAt text position = 42) → BinaryTokenAt text position (position + 1)
  | divide : 0 < position → position ≤ text.length → Cursor.byteAt text position = 47 →
      ¬ (position < text.length ∧ Cursor.byteAt text (position + 1) = 61) →
      BinaryTokenAt text position (position + 1)
  | word {bytes : Source} {after : Nat} : 0 < position →
      Named.IdentifierAt text position bytes after →
      (Named.canonicalName text position after = ("mod".toList.map Char.toNat) ∨
        Named.canonicalName text position after = ("rem".toList.map Char.toNat)) →
      BinaryTokenAt text position after

theorem binaryToken_bounds {text : Source} {position after : Nat}
    (token : BinaryTokenAt text position after) :
    0 < position ∧ position < after ∧ after ≤ text.length + 1 := by
  cases token with
  | symbol positive within _ | divide positive within _ _ => omega
  | word positive named _ =>
      have bounds := Named.identifier_bounds named
      exact ⟨positive, bounds.2.2.1, bounds.2.2.2⟩

theorem binaryToken_not_close {text : Source} {position after : Nat}
    (token : BinaryTokenAt text position after) : Cursor.byteAt text position ≠ 41 := by
  cases token with
  | symbol _ _ operators => omega
  | divide _ _ slash _ => omega
  | word _ named _ =>
      cases named with
      | identifier _ letter _ => simp only [Named.letter, decide_eq_true_eq] at letter; omega

theorem binaryAfter_sound {text : Source} {position : Nat}
    (success : binaryAfter text position ≠ 0) :
    BinaryTokenAt text position (binaryAfter text position) := by
  unfold binaryAfter at success ⊢
  dsimp only at success ⊢
  split
  · simp_all
  · rename_i valid
    split
    · exact .symbol (by omega) (by omega) (by assumption)
    · split
      · split
        · simp_all
        · exact .divide (by omega) (by omega) (by assumption) (by assumption)
      · split
        · rename_i matched
          have positive : position ≠ 0 := by omega
          have identified : Named.identifierEnd text position ≠ 0 := by
            simpa [nameAfter, positive] using matched.1
          obtain ⟨bytes, named⟩ := Named.identifierEnd_sound text position identified
          have bounds := Named.identifierEnd_bounds text position identified
          apply BinaryTokenAt.word (bytes := bytes) (by omega)
          · simpa [nameAfter, positive] using named
          · have nameBounds : nameAfter text position = Named.identifierEnd text position := by simp [nameAfter, positive]
            rcases matched.2 with mod | rem
            · exact Or.inl ((Named.nameIs_iff text position _ (("mod".toList.map Char.toNat)) (by omega)
                (by omega) (by omega)).mp mod)
            · exact Or.inr ((Named.nameIs_iff text position _ (("rem".toList.map Char.toNat)) (by omega)
                (by omega) (by omega)).mp rem)
        · simp_all

theorem binaryAfter_complete {text : Source} {position after : Nat}
    (token : BinaryTokenAt text position after) : binaryAfter text position = after := by
  cases token with
  | symbol positive within operators => simp [binaryAfter, show position ≠ 0 by omega, Nat.not_lt.mpr within, operators]
  | divide positive within slash notEqual =>
      simp [binaryAfter, show position ≠ 0 by omega, Nat.not_lt.mpr within, slash, notEqual]
  | word positive named spelling =>
      have eq := Named.identifierEnd_complete named
      have bounds := Named.identifier_bounds named
      have letter : Named.letter (Cursor.byteAt text position) = true := by cases named; assumption
      have charRange := letter
      simp only [Named.letter, decide_eq_true_eq] at charRange
      have names : Named.nameIs text position after (("mod".toList.map Char.toNat)) = true ∨
          Named.nameIs text position after (("rem".toList.map Char.toNat)) = true := by
        rcases spelling with mod | rem
        · exact Or.inl ((Named.nameIs_iff text position after _ (by omega) (by omega) bounds.2.2.2).mpr mod)
        · exact Or.inr ((Named.nameIs_iff text position after _ (by omega) (by omega) bounds.2.2.2).mpr rem)
      change Named.nameIs text position after [109, 111, 100] = true ∨
        Named.nameIs text position after [114, 101, 109] = true at names
      have within : position ≤ text.length := by cases named; assumption
      simp [binaryAfter, nameAfter, show position ≠ 0 by omega, Nat.not_lt.mpr within,
        show Cursor.byteAt text position ≠ 43 by omega, show Cursor.byteAt text position ≠ 45 by omega,
        show Cursor.byteAt text position ≠ 42 by omega, show Cursor.byteAt text position ≠ 47 by omega,
        eq, show after ≠ 0 by omega, names]

def inner (text : Source) (position : Nat) : Nat := skip text (skip text position + 1)

def Opens (text : Source) (position : Nat) : Prop :=
  skip text position ≠ 0 ∧ skip text position ≤ text.length ∧
    Cursor.byteAt text (skip text position) = 40 ∧ inner text position ≤ text.length

inductive SyntaxAt (text : Source) (names : Environment) (maskFirst maskAfter : Nat) :
    Bool → Nat → Parsed → Prop
  | atom {position : Nat} {allowSign : Bool} {value : Parsed} :
      skip text position ≠ 0 → skip text position ≤ text.length →
      Cursor.byteAt text (skip text position) ≠ 40 →
      AtomAt text names maskFirst maskAfter allowSign (skip text position) value →
      SyntaxAt text names maskFirst maskAfter allowSign position value
  | signed {position value finish closed : Nat} {allowSign : Bool} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      ScalarLiteral.IntegerAt text (skip text (inner text position + 1)) value finish →
      SymbolAt text finish 41 closed →
      SyntaxAt text names maskFirst maskAfter allowSign position
        ⟨closed, .literal (signedValue value (Cursor.byteAt text (inner text position) == 45))⟩
  | unary {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → Sign (Cursor.byteAt text (inner text position)) →
      NoIntegerAt text (skip text (inner text position + 1)) →
      SyntaxAt text names maskFirst maskAfter false (skip text (inner text position + 1)) value →
      SymbolAt text value.after 41 closed →
      SyntaxAt text names maskFirst maskAfter allowSign position
        ⟨closed, (unary value (Cursor.byteAt text (inner text position) == 45)).expression⟩
  | grouped {position closed : Nat} {allowSign : Bool} {value : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      SyntaxAt text names maskFirst maskAfter true (inner text position) value →
      SymbolAt text value.after 41 closed →
      SyntaxAt text names maskFirst maskAfter allowSign position ⟨closed, .parenthesized value.expression⟩
  | binary {position closed operatorEnd : Nat} {allowSign : Bool} {left right combined : Parsed} :
      Opens text position → ¬ Sign (Cursor.byteAt text (inner text position)) →
      SyntaxAt text names maskFirst maskAfter true (inner text position) left →
      skip text left.after ≠ 0 → skip text left.after ≤ text.length →
      BinaryTokenAt text (skip text left.after) operatorEnd →
      SyntaxAt text names maskFirst maskAfter false operatorEnd right →
      binary left right (lowercase (Cursor.byteAt text (skip text left.after))) = some combined →
      SymbolAt text combined.after 41 closed →
      SyntaxAt text names maskFirst maskAfter allowSign position {combined with after := closed}

abbrev ExpressionAt (text : Source) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (position : Nat) (expression : Integer.Expr) (finish : Nat) : Prop :=
  SyntaxAt text names maskFirst maskAfter allowSign position ⟨finish, expression⟩

end Silver.ScalarExpression
