module

public import Silver.ScalarExpressionNativeArrayAlgebra

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option linter.unusedSimpArgs false

theorem summarizeArrays_readsOnly {names : Environment} {value : Parsed}
    (capacity : names.length ≤ ArrayBindings.scalarLimit)
    (reads : value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length))
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    summarizeArrays names arrays initials elaborating (some value) = summarize names (some value) := by
  have same : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) =
      value.expression.infer (ranges names) := by
    apply Integer.Expr.infer_readsOnly reads
    intro index inside
    exact ArrayBindings.ranges_scalar arrays initials elaborating (ranges names) (by omega)
  simp only [summarizeArrays, summarize, same]

theorem summarizeArrays_nil (names : Environment) (initials : ArrayBindings.Initials)
    (elaborating : Bool) (parsed : Option Parsed) :
    summarizeArrays names [] initials elaborating parsed = summarize names parsed := by
  cases parsed <;> simp only [summarizeArrays, summarize, ArrayBindings.ranges_nil]

theorem indexed_summary_correspondence {text : Source} {names : Environment}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {target : Nat}
    (capacity : names.length ≤ ArrayBindings.scalarLimit)
    (metadata : ArrayBindings.ValidMetadata text arrays)
    (initialsValid : ArrayBindings.ValidInitials initials)
    (member : ArrayBindings.binding arrays target ∈ arrays)
    (itemValid : ArrayBindings.ValidBinding (ArrayBindings.binding arrays target))
    (elaborating : Bool) (position afterName : Nat) (index : Parsed)
    (before : position ≤ afterName) (advanced : afterName < index.after)
    (indexBound : index.after ≤ text.length + 1)
    (reads : index.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length)) :
    (let subscript := summarize names (some index)
     let closed := symbol text subscript.after 41
     if closed ≤ afterName ∨ subscript.operands = maxOperands ∨
         ArrayBindings.contains (ArrayBindings.binding arrays target) subscript.bounds = false then invalid
     else ⟨closed, ArrayBindings.readBounds arrays initials elaborating target subscript.bounds,
       subscript.operands + 1, false⟩) =
      summarizeArrays names arrays initials elaborating
        (if symbol text index.after 41 ≤ position then none
         else some ⟨symbol text index.after 41,
           .indexed (ArrayBindings.binding arrays target).descriptor index.expression⟩) := by
  have positive : index.after ≠ 0 := by omega
  have inferredSame : index.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) =
      index.expression.infer (ranges names) := by
    apply Integer.Expr.infer_readsOnly reads
    intro scalar inside
    exact ArrayBindings.ranges_scalar arrays initials elaborating (ranges names) (by omega)
  by_cases closed : symbol text index.after 41 = 0
  · simp only [closed, Nat.zero_le, ↓reduceIte, summarizeArrays]
    by_cases rejected : (summarize names (some index)).after = 0
    · rw [summarize_zero rejected]
      simp [invalid, symbol, skip]
    · obtain ⟨value, bounds, same, valuePositive, leavesBound, inferred, summary⟩ := summarize_success rejected
      have equal : value = index := by simpa using same.symm
      subst value
      rw [summary]
      simp only [closed, Nat.zero_le, true_or, ↓reduceIte]
  · have closing := symbol_bounds indexBound closed
    have closedPosition : ¬ symbol text index.after 41 ≤ position := by omega
    have closedName : ¬ symbol text index.after 41 ≤ afterName := by omega
    simp only [closedPosition, ↓reduceIte, summarizeArrays, closed, leaves, false_or,
      Integer.Expr.infer, inferredSame]
    by_cases many : maxOperands < leaves index.expression
    · have more : maxOperands < 1 + leaves index.expression := by omega
      simp [summarize, positive, many, more, invalid, symbol, skip]
    · simp only [summarize, positive, many, or_self, ↓reduceIte]
      cases inferred : index.expression.infer (ranges names) with
      | none => simp [invalid, symbol, skip]
      | some bounds =>
          simp only [Option.bind_some, closedName, false_or]
          have count : (leaves index.expression = maxOperands) =
              (maxOperands < 1 + leaves index.expression) := by apply propext; omega
          by_cases full : leaves index.expression = maxOperands
          · simp only [full, true_or, ↓reduceIte, count] 
            simp [maxOperands]
          · have space : ¬ maxOperands < 1 + leaves index.expression := by omega
            simp only [full, false_or, space, ↓reduceIte]
            cases inside : ArrayBindings.contains (ArrayBindings.binding arrays target) bounds with
            | false =>
                have rejected : Integer.arrayIndexCheck (ArrayBindings.binding arrays target).descriptor bounds = false := by
                  rw [← ArrayBindings.contains_indexCheck itemValid]; exact inside
                simp [Integer.arrayReadRange, rejected]
            | true =>
                rw [ArrayBindings.readBounds_correspondence initialsValid
                  (fun entry present => (metadata.2.1 entry present).2.2.2)
                  metadata.2.2 member itemValid inside elaborating]
                simp [isStatic, Nat.add_comm]

theorem lookup_after_zero (text : Source) (names : Environment) (first : Nat) :
    lookup text names first 0 = 0 := by
  unfold lookup
  cases names.length <;> simp [lookupFrom]

theorem arraysAtomStep_dispatch (recurse : Reader) (text : Source) (position : Nat)
    (names : Environment) (maskFirst maskAfter : Nat) (allowSign : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arraysAtomStep recurse text position names maskFirst maskAfter allowSign arrays initials elaborating =
      if (atom text position names maskFirst maskAfter allowSign).isSome then
        atomResult text position names maskFirst maskAfter allowSign
      else
        let first := skip text position
        let after := nameAfter text first
        let target := ArrayBindings.lookup text arrays first after
        if first = 0 ∨ first > text.length ∨ after = 0 ∨ target = 0 ∨
            lookup text names first after ≠ 0 ∨
            Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 ∨
            (ScalarLiteral.read text first).after ≠ 0 ∨
            (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true) then invalid
        else arrayAtomStep recurse text after names maskFirst maskAfter target arrays initials elaborating := by
  unfold arraysAtomStep atom atomResult
  dsimp only
  by_cases bad : skip text position = 0 ∨ text.length < skip text position
  · simp only [bad, ↓reduceIte, Option.isSome_none, Bool.false_eq_true]
    split <;> (try rfl)
    omega
  · simp only [bad, ↓reduceIte]
    by_cases sign : Cursor.byteAt text (skip text position) = 43 ∨ Cursor.byteAt text (skip text position) = 45
    · simp only [sign, ↓reduceIte]
      cases allowSign <;> simp only [Bool.not_false, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
      · simp only [Option.isSome_none, Bool.false_eq_true, ↓reduceIte]
        split <;> (try rfl)
        omega
      · by_cases absent : (ScalarLiteral.read text (skip text (skip text position + 1))).after = 0
        · rcases sign with sign | sign <;> simp [literal, literalResult, absent, sign]
        · simp only [literal, absent, ↓reduceIte, Option.isSome_some]
    · simp only [sign, ↓reduceIte]
      by_cases number : (ScalarLiteral.read text (skip text position)).after ≠ 0
      · simp [number, literal]
      · simp only [number, ↓reduceIte]
        by_cases noName : nameAfter text (skip text position) = 0
        · simp [noName, lookup_after_zero]
        · simp only [noName, ↓reduceIte]
          by_cases masked : maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter
              (skip text position) (nameAfter text (skip text position)) = true
          · simp [masked]
          · simp only [masked, ↓reduceIte, or_false]
            by_cases noScalar : lookup text names (skip text position) (nameAfter text (skip text position)) = 0
            · simp only [noScalar, true_or, ↓reduceIte, Option.isSome_none, Bool.false_eq_true,
                ne_eq, not_true_eq_false, or_false]
              have a : skip text position ≠ 0 := by omega
              have b : ¬ text.length < skip text position := by omega
              have c : Cursor.byteAt text (skip text position) ≠ 43 := by omega
              have d : Cursor.byteAt text (skip text position) ≠ 45 := by omega
              simp [a, b, c, d, noName, number, masked]
            · simp [noScalar]

theorem arrayAtomStep_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {target : Nat}
    (metadata : ArrayBindings.ValidMetadata text arrays)
    (initialsValid : ArrayBindings.ValidInitials initials)
    (member : ArrayBindings.binding arrays target ∈ arrays)
    (itemValid : ArrayBindings.ValidBinding (ArrayBindings.binding arrays target))
    (fuel position afterName maskFirst maskAfter : Nat) (elaborating : Bool)
    (before : position ≤ afterName) (afterBound : afterName ≤ text.length + 1) :
    arrayAtomStep (readFuel fuel) text afterName names maskFirst maskAfter target arrays initials elaborating =
      summarizeArrays names arrays initials elaborating
        (if symbol text afterName 40 = 0 then none else do
          let index ← parseFuel fuel text (symbol text afterName 40) names maskFirst maskAfter true
          let closed := symbol text index.after 41
          if closed ≤ position then none else
            some ⟨closed, .indexed (ArrayBindings.binding arrays target).descriptor index.expression⟩) := by
  unfold arrayAtomStep
  dsimp only
  split
  · rfl
  · rename_i opened
    have opening := symbol_bounds afterBound opened
    rw [readFuel_correspondence valid fuel _ maskFirst maskAfter true opening.2]
    cases parsed : parseFuel fuel text (symbol text afterName 40) names maskFirst maskAfter true with
    | none => simp [summarize, summarizeArrays, invalid, symbol, skip]
    | some index =>
        have bounds := parseFuel_bounds opening.2 parsed
        have reads := syntax_readsOnly (parseFuel_sound opening.2 parsed)
        exact indexed_summary_correspondence valid.1 metadata initialsValid member itemValid elaborating
          position afterName index before (by omega) bounds.2 reads

theorem arraysAtom_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials)
    (fuel position maskFirst maskAfter : Nat) (allowSign elaborating : Bool)
    (bound : position ≤ text.length + 1) :
    arraysAtomStep (readFuel fuel) text position names maskFirst maskAfter allowSign arrays initials elaborating =
      summarizeArrays names arrays initials elaborating
        (arrayAtom fuel text position names arrays maskFirst maskAfter allowSign) := by
  rw [arraysAtomStep_dispatch]
  unfold arrayAtom
  dsimp only
  split
  · rename_i ordinary
    rw [atom_correspondence valid]
    cases parsed : atom text position names maskFirst maskAfter allowSign with
    | none => simp only [parsed, Option.isSome_none, Bool.false_eq_true] at ordinary
    | some value =>
        exact (summarizeArrays_readsOnly valid.1 (atom_readsOnly (atom_sound bound parsed)) arrays initials elaborating).symm
  · split
    · rfl
    · rename_i good
      have first := skip_bounds text position bound
      have named : nameAfter text (skip text position) ≠ 0 := by omega
      have firstPositive : skip text position ≠ 0 := by omega
      have identifier := Named.identifierEnd_bounds text (skip text position)
        (show Named.identifierEnd text (skip text position) ≠ 0 by simpa only [nameAfter, firstPositive, ↓reduceIte] using named)
      have namedBounds : skip text position < nameAfter text (skip text position) ∧
          nameAfter text (skip text position) ≤ text.length + 1 := by
        simpa only [nameAfter, firstPositive, ↓reduceIte] using identifier
      have targetPositive : 0 < ArrayBindings.lookup text arrays (skip text position) (nameAfter text (skip text position)) := by omega
      have member := ArrayBindings.Native.binding_mem targetPositive (ArrayBindings.Native.lookup_bound text arrays _ _)
      exact arrayAtomStep_correspondence valid metadata initialsValid member (metadata.2.1 _ member).2.2.2
        fuel position _ maskFirst maskAfter elaborating (by omega) namedBounds.2

end Silver.ScalarExpression.Native
