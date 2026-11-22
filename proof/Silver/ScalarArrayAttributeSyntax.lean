module

public import Silver.ScalarArrayAttributes
public import Silver.ScalarExpressionGrammar

@[expose] public section

namespace Silver.ScalarExpression

private theorem trivia_terminal {text rest : Source} (parsed : Trivia text rest) :
    triviaEnd rest = rest := by
  induction parsed with
  | eof => simp [triviaEnd]
  | stop c text space comment => simp [triviaEnd, space, comment]
  | space _ _ _ _ _ ih | comment _ _ _ _ _ ih => exact ih

theorem skip_skipped (text : Source) (position : Nat) :
    skip text (skip text position) =
      skip text position := by
  by_cases zero : skip text position = 0
  · rw [zero]; rfl
  · have positionNonzero : position ≠ 0 := by
      intro equal
      simp [skip, equal] at zero
    have equation : skip text position = Cursor.triviaPosition text position :=
      ite_eq_right positionNonzero
    calc
      skip text (skip text position) =
          Cursor.triviaPosition text (skip text position) := ite_eq_right zero
      _ = Cursor.triviaPosition text (Cursor.triviaPosition text position) := congrArg _ equation
      _ = Cursor.triviaPosition text position := by
        change Cursor.endPosition text (triviaEnd (Cursor.remaining text (Cursor.triviaPosition text position))) = _
        rw [Cursor.remaining_triviaPosition, trivia_terminal (trivia_complete _)]
        rfl
      _ = skip text position := equation.symm

namespace ArrayAttributes

/-- The object namespace takes precedence over the type namespace. A Boolean
array object hides an identically spelled type for this lookup. -/
inductive PrefixShape (text : Source) (arrays : ArrayBindings.Table) (first after : Nat) : Integer.Interval → Prop
  | object {index} : ArrayBindings.lookup text arrays.items first after = index → index ≠ 0 →
      (ArrayBindings.binding arrays.items index).isBoolean = false →
      PrefixShape text arrays first after (ArrayBindings.binding arrays.items index).bounds
  | typeName {index} : ArrayBindings.lookup text arrays.items first after = 0 →
      ArrayBindings.lookupType text arrays.types first after = index → index ≠ 0 →
      PrefixShape text arrays first after (ArrayBindings.arrayType arrays.types index).bounds

theorem prefixShape_iff {text arrays first after shape} : PrefixShape text arrays first after shape ↔
    selectedShape text arrays first after = some shape := by
  constructor
  · intro reading
    cases reading with
    | object found present integer => simp [selectedShape, found, present, integer]
    | typeName absent found present => simp [selectedShape, absent, found, present]
  · intro selected
    unfold selectedShape at selected
    dsimp only at selected
    split at selected
    · rename_i present
      split at selected
      · cases selected
      · rename_i integer
        cases selected
        exact .object rfl present (Bool.eq_false_iff.mpr integer)
    · rename_i absent
      split at selected
      · rename_i present
        cases selected
        exact .typeName (Classical.not_not.mp absent) rfl present
      · cases selected

/-- The permitted source word is determined by whether the caller requested a
range or a scalar. The identifier is matched case-insensitively by Ada name rules. -/
def WordAt (text : Source) (first after : Nat) (rangeQuery : Bool) (query : Query) : Prop :=
  (query = .range ↔ rangeQuery = true) ∧ Named.nameIs text first after query.word = true

private theorem other_length {text left right : Source} {first after : Nat}
    (found : Named.nameIs text first after left = true) (apart : left.length ≠ right.length) :
    Named.nameIs text first after right = false := by
  apply Bool.eq_false_iff.mpr
  intro other
  simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at found other
  exact apart (found.1.symm.trans other.1)

theorem wordAt_iff {text first after rangeQuery query} : WordAt text first after rangeQuery query ↔
    selectedQuery text first after rangeQuery = some query := by
  constructor
  · rintro ⟨mode, found⟩
    cases query with
    | range => simp [selectedQuery, mode.mp rfl, found]
    | first =>
        have scalar : rangeQuery = false := Bool.eq_false_iff.mpr (fun wrong => by cases mode.mpr wrong)
        simp [selectedQuery, scalar, found]
    | last =>
        have scalar : rangeQuery = false := Bool.eq_false_iff.mpr (fun wrong => by cases mode.mpr wrong)
        have distinct := other_length (right := Query.first.word) found (by decide)
        simp [selectedQuery, scalar, distinct, found]
    | length =>
        have scalar : rangeQuery = false := Bool.eq_false_iff.mpr (fun wrong => by cases mode.mpr wrong)
        have firstMiss := other_length (right := Query.first.word) found (by decide)
        have lastMiss := other_length (right := Query.last.word) found (by decide)
        simp [selectedQuery, scalar, firstMiss, lastMiss, found]
  · intro selected
    unfold selectedQuery at selected
    cases rangeQuery <;> simp only [Bool.false_eq_true, ↓reduceIte] at selected
    all_goals repeat' first | split at selected | cases selected
    all_goals exact ⟨by simp, by assumption⟩

inductive At (text : Source) (names : Environment) (arrays : ArrayBindings.Table)
    (position maskFirst maskAfter : Nat) (rangeQuery : Bool) : ParsedQuery → Prop
  | read {objectName prefixEnd tickEnd designator finish shape query} :
      skip text position ≠ 0 → Named.IdentifierAt text (skip text position) objectName prefixEnd →
      lookup text names (skip text position) prefixEnd = 0 →
      ¬ (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter (skip text position) prefixEnd = true) →
      PrefixShape text arrays (skip text position) prefixEnd shape → SymbolAt text prefixEnd 39 tickEnd →
      skip text tickEnd ≠ 0 → Named.IdentifierAt text (skip text tickEnd) designator finish →
      WordAt text (skip text tickEnd) finish rangeQuery query →
      At text names arrays position maskFirst maskAfter rangeQuery ⟨finish, shape, query⟩

theorem at_iff {text names arrays position maskFirst maskAfter rangeQuery parsed} :
    At text names arrays position maskFirst maskAfter rangeQuery parsed ↔
      parse text position names arrays maskFirst maskAfter rangeQuery = some parsed := by
  constructor
  · intro reading
    cases reading with
    | read prefixPositive objectName scalar unmasked selected tick wordPositive designator word =>
        have prefixEnd := Named.identifierEnd_complete objectName
        have prefixBounds := Named.identifier_bounds objectName
        have endWord := Named.identifierEnd_complete designator
        have wordBounds := Named.identifier_bounds designator
        have separator := symbolAt_iff.mp tick
        simp [parse, nameAfter, prefixPositive, prefixEnd, Nat.not_le.mpr prefixBounds.2.2.1,
          separator.1, wordPositive, endWord, Nat.not_le.mpr wordBounds.2.2.1, scalar, unmasked,
          prefixShape_iff.mp selected, wordAt_iff.mp word]
  · intro found
    unfold parse at found
    dsimp only at found
    split at found
    · cases found
    · rename_i allowed
      simp only [not_or] at allowed
      obtain ⟨prefixPositive, prefixAdvance, wordPositive, wordAdvance, scalar, unmasked⟩ := allowed
      change (Option.bind _ _) = some parsed at found
      obtain ⟨shape, selected, found⟩ := Option.bind_eq_some_iff.mp found
      change (Option.bind _ _) = some parsed at found
      obtain ⟨query, word, same⟩ := Option.bind_eq_some_iff.mp found
      cases same
      have identifier {first : Nat} (positive : first ≠ 0) (advanced : first < nameAfter text first) :
          ∃ bytes, Named.IdentifierAt text first bytes (nameAfter text first) := by
        simp only [nameAfter, positive, ↓reduceIte] at advanced ⊢
        exact Named.identifierEnd_sound text first (by omega)
      obtain ⟨_, objectName⟩ := identifier prefixPositive (by omega)
      obtain ⟨_, designator⟩ := identifier wordPositive (by omega)
      have tick : symbol text (nameAfter text (skip text position)) 39 ≠ 0 := by
        intro absent
        rw [absent] at wordPositive
        exact wordPositive rfl
      exact .read prefixPositive objectName (Classical.not_not.mp scalar) unmasked (prefixShape_iff.mpr selected)
        (symbolAt_iff.mpr ⟨rfl, tick⟩) wordPositive designator (wordAt_iff.mpr word)

theorem parse_skipped (text : Source) (position : Nat) (names : Environment) (arrays : ArrayBindings.Table)
    (maskFirst maskAfter : Nat) (rangeQuery : Bool) :
    parse text (skip text position) names arrays maskFirst maskAfter rangeQuery =
      parse text position names arrays maskFirst maskAfter rangeQuery := by
  simp only [parse, skip_skipped]

theorem At.apostrophe {text names arrays position maskFirst maskAfter rangeQuery parsed}
    (reading : At text names arrays position maskFirst maskAfter rangeQuery parsed) :
    symbol text (nameAfter text (skip text position)) 39 ≠ 0 := by
  cases reading with
  | read positive objectName _ _ _ separator _ _ _ =>
      simp only [nameAfter, positive, ↓reduceIte, Named.identifierEnd_complete objectName]
      exact (symbolAt_iff.mp separator).1.symm ▸ (symbolAt_iff.mp separator).2

end ArrayAttributes
end Silver.ScalarExpression
