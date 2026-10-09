import Silver.OutputAdmission

/-! Independent ASCII identifier derivations, bounded cursor recognition, and
case-insensitive one-binding names. No external parser/prover result defines
membership. The source bridge is a separate obligation. -/

namespace Silver.Named

def letter (byte : Nat) : Bool :=
  decide ((65 ≤ byte ∧ byte ≤ 90) ∨ (97 ≤ byte ∧ byte ≤ 122))

def identifierTail (text : Source) (position : Nat) (previousUnderscore : Bool) : Nat :=
  if position > text.length ∨ identifierCharacter (Cursor.byteAt text position) = false then
    if previousUnderscore then 0 else position
  else if Cursor.byteAt text position = 95 ∧ previousUnderscore = true then 0
  else identifierTail text (position + 1) (Cursor.byteAt text position == 95)
termination_by text.length + 1 - position
decreasing_by omega

def identifierEnd (text : Source) (position : Nat) : Nat :=
  if position ≤ text.length ∧ letter (Cursor.byteAt text position) = true then
    identifierTail text (position + 1) false
  else 0

inductive IdentifierTail (text : Source) : Nat → Bool → Source → Nat → Prop
  | stop {position : Nat} :
      (position > text.length ∨ identifierCharacter (Cursor.byteAt text position) = false) →
      IdentifierTail text position false [] position
  | character {position finish : Nat} {previous : Bool} {bytes : Source} :
      position ≤ text.length → identifierCharacter (Cursor.byteAt text position) = true →
      ¬(Cursor.byteAt text position = 95 ∧ previous = true) →
      IdentifierTail text (position + 1) (Cursor.byteAt text position == 95) bytes finish →
      IdentifierTail text position previous (Cursor.byteAt text position :: bytes) finish

inductive IdentifierAt (text : Source) : Nat → Source → Nat → Prop
  | identifier {position finish : Nat} {bytes : Source} :
      position ≤ text.length → letter (Cursor.byteAt text position) = true →
      IdentifierTail text (position + 1) false bytes finish →
      IdentifierAt text position (Cursor.byteAt text position :: bytes) finish

theorem identifierTail_complete {text bytes : Source} {position finish : Nat} {previous : Bool}
    (parsed : IdentifierTail text position previous bytes finish) :
    identifierTail text position previous = finish := by
  induction parsed with
  | stop ending => simp [identifierTail, ending]
  | character bound character allowed rest ih =>
      rw [identifierTail]
      simp [Nat.not_lt.mpr bound, character, allowed, ih]

theorem identifierTail_sound (text : Source) (position : Nat) (previous : Bool)
    (nonzero : identifierTail text position previous ≠ 0) :
    ∃ bytes, IdentifierTail text position previous bytes (identifierTail text position previous) := by
  rw [identifierTail] at nonzero ⊢
  by_cases ending : position > text.length ∨ identifierCharacter (Cursor.byteAt text position) = false
  · simp only [ending, ↓reduceIte] at nonzero ⊢
    cases previous with
    | false => exact ⟨[], .stop ending⟩
    | true => simp at nonzero
  · simp only [ending, ↓reduceIte] at nonzero ⊢
    by_cases forbidden : Cursor.byteAt text position = 95 ∧ previous = true
    · simp [forbidden] at nonzero
    · simp only [forbidden, ↓reduceIte] at nonzero ⊢
      obtain ⟨bytes, rest⟩ := identifierTail_sound text (position + 1)
        (Cursor.byteAt text position == 95) nonzero
      exact ⟨_, .character (by omega) (by
        cases character : identifierCharacter (Cursor.byteAt text position) <;> simp_all)
        forbidden rest⟩
termination_by text.length + 1 - position
decreasing_by omega

theorem identifierEnd_complete {text bytes : Source} {position finish : Nat}
    (parsed : IdentifierAt text position bytes finish) : identifierEnd text position = finish := by
  cases parsed with
  | identifier bound first rest =>
      simp [identifierEnd, bound, first, identifierTail_complete rest]

theorem identifierEnd_sound (text : Source) (position : Nat)
    (nonzero : identifierEnd text position ≠ 0) :
    ∃ bytes, IdentifierAt text position bytes (identifierEnd text position) := by
  unfold identifierEnd at nonzero ⊢
  split at nonzero
  · rename_i first
    simp only [first]
    obtain ⟨bytes, rest⟩ := identifierTail_sound text (position + 1) false nonzero
    exact ⟨_, .identifier first.1 first.2 rest⟩
  · contradiction

theorem identifierTail_unique {text left right : Source} {position leftEnd rightEnd : Nat}
    {previous : Bool} (first : IdentifierTail text position previous left leftEnd)
    (second : IdentifierTail text position previous right rightEnd) :
    left = right ∧ leftEnd = rightEnd := by
  induction first generalizing right rightEnd with
  | stop ending =>
      cases second with
      | stop => exact ⟨rfl, rfl⟩
      | character bound character => simp_all; omega
  | character bound character allowed rest ih =>
      cases second with
      | stop ending => simp_all; omega
      | character bound character allowed other =>
          obtain ⟨rfl, rfl⟩ := ih other
          exact ⟨rfl, rfl⟩

theorem identifier_unique {text left right : Source} {position leftEnd rightEnd : Nat}
    (first : IdentifierAt text position left leftEnd)
    (second : IdentifierAt text position right rightEnd) :
    left = right ∧ leftEnd = rightEnd := by
  cases first with
  | identifier bound first rest =>
      cases second with
      | identifier bound first other =>
          obtain ⟨rfl, rfl⟩ := identifierTail_unique rest other
          exact ⟨rfl, rfl⟩

theorem identifierTail_bounds {text bytes : Source} {position finish : Nat} {previous : Bool}
    (parsed : IdentifierTail text position previous bytes finish)
    (bound : position ≤ text.length + 1) :
    position + bytes.length = finish ∧ finish ≤ text.length + 1 := by
  induction parsed with
  | stop => simp_all
  | character first character allowed rest ih =>
      obtain ⟨length, last⟩ := ih (by omega)
      exact ⟨by simp only [List.length_cons]; omega, last⟩

theorem identifier_bounds {text bytes : Source} {position finish : Nat}
    (parsed : IdentifierAt text position bytes finish) :
    bytes ≠ [] ∧ position + bytes.length = finish ∧ position < finish ∧ finish ≤ text.length + 1 := by
  cases parsed with
  | identifier bound first rest =>
      have tail := identifierTail_bounds rest (by omega)
      simp only [ne_eq, List.cons_ne_nil, not_false_eq_true, List.length_cons]
      exact ⟨trivial, by omega, by omega, tail.2⟩

theorem identifierEnd_bounds (text : Source) (position : Nat)
    (nonzero : identifierEnd text position ≠ 0) :
    position < identifierEnd text position ∧ identifierEnd text position ≤ text.length + 1 := by
  obtain ⟨bytes, parsed⟩ := identifierEnd_sound text position nonzero
  exact (identifier_bounds parsed).2.2

def span (text : Source) (first after : Nat) : Source :=
  (Cursor.remaining text first).take (after - first)

def canonicalName (text : Source) (first after : Nat) : Source :=
  (span text first after).map lowercase

theorem span_length (text : Source) (first after : Nat)
    (positive : 1 ≤ first) (ordered : first ≤ after) (bounded : after ≤ text.length + 1) :
    (span text first after).length = after - first := by
  simp only [span, List.length_take, Cursor.remaining_length]
  omega

theorem identifierTail_span {text bytes : Source} {position finish : Nat} {previous : Bool}
    (parsed : IdentifierTail text position previous bytes finish) (positive : 1 ≤ position) :
    bytes = span text position finish := by
  induction parsed with
  | stop ending => simp [span]
  | @character position finish previous bytes bound character allowed rest ih =>
      have bounds := identifierTail_bounds rest (by omega)
      have positiveRest : 1 ≤ position + 1 := by omega
      have length : finish - position = (finish - (position + 1)) + 1 := by omega
      rw [span, Cursor.remaining_cons text position positive bound, length, List.take_succ_cons]
      exact congrArg (List.cons _) (ih positiveRest)

theorem identifier_span {text bytes : Source} {position finish : Nat}
    (parsed : IdentifierAt text position bytes finish) (positive : 1 ≤ position) :
    bytes = span text position finish := by
  cases parsed with
  | identifier bound first rest =>
      have bounds := identifierTail_bounds rest (by omega)
      have length : finish - position = (finish - (position + 1)) + 1 := by omega
      rw [span, Cursor.remaining_cons text position positive bound, length, List.take_succ_cons]
      exact congrArg (List.cons _) (identifierTail_span rest (by omega))

def nameIs (text : Source) (first after : Nat) (word : Source) : Bool :=
  decide (after - first = word.length) &&
    decide (∀ index : Fin word.length,
      lowercase (Cursor.byteAt text (first + index.val)) = word[index.val])

theorem nameIs_iff (text : Source) (first after : Nat) (word : Source)
    (positive : 1 ≤ first) (ordered : first ≤ after) (bounded : after ≤ text.length + 1) :
    nameIs text first after word = true ↔ canonicalName text first after = word := by
  have length := span_length text first after positive ordered bounded
  constructor
  · intro matched
    simp only [nameIs, Bool.and_eq_true, decide_eq_true_eq] at matched
    have enough : word.length ≤ (Cursor.remaining text first).length := by
      simp only [Cursor.remaining_length]
      omega
    have same := (Cursor.word_at_position text word first positive enough).mpr matched.2
    simpa [canonicalName, span, matched.1] using same
  · intro same
    have lengths : after - first = word.length := by
      have equal := congrArg List.length same
      simpa [canonicalName, length] using equal
    have enough : word.length ≤ (Cursor.remaining text first).length := by
      simp only [Cursor.remaining_length]
      omega
    have matched := (Cursor.word_at_position text word first positive enough).mp
      (by simpa [canonicalName, span, lengths] using same)
    simp [nameIs, lengths, matched]

theorem canonicalName_length (text : Source) (first after : Nat)
    (positive : 1 ≤ first) (ordered : first ≤ after) (bounded : after ≤ text.length + 1) :
    (canonicalName text first after).length = after - first := by
  simpa [canonicalName] using span_length text first after positive ordered bounded

theorem canonicalName_get (text : Source) (first after index : Nat)
    (positive : 1 ≤ first) (ordered : first ≤ after) (bounded : after ≤ text.length + 1)
    (inside : index < after - first) :
    (canonicalName text first after)[index]'(by
      rw [canonicalName_length text first after positive ordered bounded]; exact inside) =
      lowercase (Cursor.byteAt text (first + index)) := by
  have offset : first + index - 1 = first - 1 + index := by omega
  have sourceBound : first - 1 + index < text.length := by omega
  simp [canonicalName, span, Cursor.remaining, Cursor.byteAt, offset, sourceBound]

def equalName (text : Source) (leftFirst leftAfter rightFirst rightAfter : Nat) : Bool :=
  decide (leftAfter - leftFirst = rightAfter - rightFirst) &&
    decide (∀ index : Fin (leftAfter - leftFirst),
      lowercase (Cursor.byteAt text (leftFirst + index.val)) =
        lowercase (Cursor.byteAt text (rightFirst + index.val)))

theorem equalName_iff (text : Source) (leftFirst leftAfter rightFirst rightAfter : Nat)
    (leftPositive : 1 ≤ leftFirst) (leftOrdered : leftFirst ≤ leftAfter)
    (leftBounded : leftAfter ≤ text.length + 1)
    (rightPositive : 1 ≤ rightFirst) (rightOrdered : rightFirst ≤ rightAfter)
    (rightBounded : rightAfter ≤ text.length + 1) :
    equalName text leftFirst leftAfter rightFirst rightAfter = true ↔
      canonicalName text leftFirst leftAfter = canonicalName text rightFirst rightAfter := by
  have leftLength := canonicalName_length text leftFirst leftAfter leftPositive leftOrdered leftBounded
  have rightLength := canonicalName_length text rightFirst rightAfter rightPositive rightOrdered rightBounded
  simp only [equalName, Bool.and_eq_true, decide_eq_true_eq]
  constructor
  · rintro ⟨lengths, bytes⟩
    apply List.ext_getElem (by omega)
    intro index leftInside rightInside
    have li : index < leftAfter - leftFirst := by omega
    have ri : index < rightAfter - rightFirst := by omega
    rw [canonicalName_get text leftFirst leftAfter index leftPositive leftOrdered leftBounded li,
      canonicalName_get text rightFirst rightAfter index rightPositive rightOrdered rightBounded ri]
    exact bytes ⟨index, li⟩
  · intro same
    have lengths := congrArg List.length same
    refine ⟨by omega, ?_⟩
    intro index
    have li := index.isLt
    have ri : index.val < rightAfter - rightFirst := by omega
    have bytes := (List.ext_getElem_iff.mp same).2 index.val (by omega) (by omega)
    rw [canonicalName_get text leftFirst leftAfter index.val leftPositive leftOrdered leftBounded li,
      canonicalName_get text rightFirst rightAfter index.val rightPositive rightOrdered rightBounded ri] at bytes
    exact bytes

/-- Ada 2022 RM2.9 reserved words, then the two actual collisions in this form. -/
def forbiddenSpellings : List String :=
  ["abort", "abs", "abstract", "accept", "access", "aliased", "all", "and", "array", "at", "begin", "body", "case", "constant", "declare", "delay", "delta", "digits", "do", "else", "elsif", "end", "entry", "exception", "exit", "for", "function", "generic", "goto", "if", "in", "interface", "is", "limited", "loop", "mod", "new", "not", "null", "of", "or", "others", "out", "overriding", "package", "parallel", "pragma", "private", "procedure", "protected", "raise", "range", "record", "rem", "renames", "requeue", "return", "reverse", "select", "separate", "some", "subtype", "synchronized", "tagged", "task", "terminate", "then", "type", "until", "use", "when", "while", "with", "xor", "string", "silver_io"]

def forbiddenNames : List Source := forbiddenSpellings.map (fun word => word.toList.map Char.toNat)

def forbiddenName (text : Source) (first after : Nat) : Bool :=
  forbiddenNames.any (nameIs text first after)

theorem forbiddenName_iff (text : Source) (first after : Nat)
    (positive : 1 ≤ first) (ordered : first ≤ after) (bounded : after ≤ text.length + 1) :
    forbiddenName text first after = true ↔ canonicalName text first after ∈ forbiddenNames := by
  simp only [forbiddenName, List.any_eq_true]
  constructor
  · rintro ⟨word, member, matched⟩
    rw [(nameIs_iff text first after word positive ordered bounded).mp matched]
    exact member
  · intro member
    exact ⟨_, member, (nameIs_iff text first after _ positive ordered bounded).mpr rfl⟩

/-- Recursive equations are supplied by the checked source interpretation.
Their uniqueness is independent of a prover accepting particular programs. -/
def identifierTailEquation (recurse : Nat → Bool → Nat) (text : Source)
    (position : Nat) (previous : Bool) : Nat :=
  if position > text.length ∨ identifierCharacter (Cursor.byteAt text position) = false then
    if previous then 0 else position
  else if Cursor.byteAt text position = 95 ∧ previous = true then 0
  else recurse (position + 1) (Cursor.byteAt text position == 95)

theorem identifierTail_unique_equations (text : Source) (implementation : Nat → Bool → Nat)
    (equations : ∀ position previous, 1 ≤ position → position ≤ text.length + 1 →
      implementation position previous = identifierTailEquation implementation text position previous)
    (position : Nat) (previous : Bool) (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) :
    implementation position previous = identifierTail text position previous := by
  rw [equations position previous positive bounded, identifierTail]
  unfold identifierTailEquation
  split
  · rfl
  · rename_i continuing
    split
    · rfl
    · exact identifierTail_unique_equations text implementation equations (position + 1) _
        (by omega) (by omega)
termination_by text.length + 1 - position
decreasing_by omega

end Silver.Named
