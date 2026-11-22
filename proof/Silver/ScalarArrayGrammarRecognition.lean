module

public import Silver.ScalarArrayGrammar

@[expose] public section

/-! Recognition evidence retains the exact source parser's selected expression.
Cursor and interval facts are derived here; correspondence with the executable
Ada reader is established separately by the native source equations. -/
namespace Silver.ScalarExpression.ArrayGrammar

theorem parseFuel_bounds {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Table} {allowSign : Bool} {arrayReads : ArrayReadMode} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseFuel fuel text position names arrays maskFirst maskAfter allowSign arrayReads = some value) :
    position < value.after ∧ value.after ≤ text.length + 1 := by
  induction fuel generalizing position allowSign arrayReads value with
  | zero => cases found
  | succ fuel ih =>
      have first := skip_bounds text position bound
      rw [parseFuel] at found
      dsimp only at found
      split at found
      · cases found
      · rename_i valid
        split at found
        · split at found
          · have atom := ScalarExpression.atom_bounds first.2 found
            exact ⟨by omega, atom.2⟩
          · split at found
            · unfold attributeAtom at found
              obtain ⟨query, parsed, same⟩ := Option.bind_eq_some_iff.mp found
              cases same
              have queryBounds := ArrayAttributes.parse_bounds first.2 parsed
              dsimp only
              exact ⟨by omega, queryBounds.2⟩
            · split at found
              · cases found
              · rename_i allowed
                split at found
                · cases found
                · rename_i opened
                  have namedBounds := ArrayAttributes.nameAfter_bounds
                    (show nameAfter text (skip text position) ≠ 0 by omega)
                  have opening := symbol_bounds namedBounds.2 opened
                  obtain ⟨index, parsed, found⟩ := Option.bind_eq_some_iff.mp found
                  have indexBounds := ih opening.2 parsed
                  split at found
                  · cases found
                  · rename_i closed
                    cases found
                    have closing := symbol_bounds indexBounds.2
                      (show symbol text index.after 41 ≠ 0 by omega)
                    dsimp only
                    exact ⟨by omega, closing.2⟩
        · have inner := skip_bounds text (skip text position + 1) (by omega)
          split at found
          · cases found
          · rename_i innerValid
            split at found
            · have next := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
              have originalBounds : position < original.after ∧ original.after ≤ text.length + 1 := by
                split at originalFound
                · obtain ⟨numberGood, rfl⟩ := literal_result originalFound
                  have number := ScalarLiteral.integer_bounds (ScalarLiteral.read_sound next.2 numberGood)
                  dsimp only
                  exact ⟨by omega, number.2.1⟩
                · simp only [Option.map_eq_some_iff] at originalFound
                  obtain ⟨child, childFound, rfl⟩ := originalFound
                  have childBounds := ih next.2 childFound
                  exact ⟨by simpa only [unary] using Nat.lt_of_le_of_lt (by omega) childBounds.1,
                    childBounds.2⟩
              have closing := symbol_bounds originalBounds.2 closeGood
              dsimp only
              exact ⟨by omega, closing.2⟩
            · change (Option.bind _ _) = some value at found
              simp only [Option.bind_eq_some_iff] at found
              obtain ⟨left, leftFound, found⟩ := found
              have leftBounds := ih inner.2 leftFound
              have next := skip_bounds text left.after leftBounds.2
              split at found
              · cases found
              · rename_i nextValid
                split at found
                · cases found
                  dsimp only
                  exact ⟨by omega, by omega⟩
                · split at found
                  · cases found
                  · rename_i operator
                    have operatorBounds := binaryAfter_bounds operator
                    change (Option.bind _ _) = some value at found
                    simp only [Option.bind_eq_some_iff] at found
                    obtain ⟨right, rightFound, found⟩ := found
                    have rightBounds := ih operatorBounds.2 rightFound
                    obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
                    have same := binary_result originalFound
                    have closing := symbol_bounds (by omega : original.after ≤ text.length + 1) closeGood
                    dsimp only
                    exact ⟨by omega, closing.2⟩

theorem parseFuel_zero (fuel : Nat) (text : Source) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrayReads : ArrayReadMode) :
    parseFuel fuel text 0 names arrays maskFirst maskAfter allowSign arrayReads = none := by
  cases fuel <;> simp [parseFuel, skip]

structure At (text : Source) (names : Environment) (position : Nat)
    (expression : Integer.Expr) (result : Result)
    (maskFirst maskAfter : Nat := 0) (allowSign : Bool := true)
    (arrays : ArrayBindings.Table := {}) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) (arrayReads : ArrayReadMode := .allElements) : Prop where
  positionBound : position ≤ text.length + 1
  grammar : parseFuel (text.length + 1) text position names arrays maskFirst maskAfter allowSign arrayReads =
    some ⟨result.after, expression⟩
  inferred : expression.infer (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) = some result.bounds
  operands : result.operands = leaves expression
  operandBound : leaves expression ≤ maxOperands
  staticValue : result.isStatic = isStatic names expression

theorem At.cursorBounds {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {arrayReads : ArrayReadMode} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads) :
    0 < position ∧ position < result.after ∧ result.after ≤ text.length + 1 := by
  have bounds := parseFuel_bounds parsed.positionBound parsed.grammar
  have positive : position ≠ 0 := by
    intro zero
    have impossible := parsed.grammar
    rw [zero, parseFuel_zero] at impossible
    cases impossible
  exact ⟨by omega, bounds⟩

theorem read_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {arrayReads : ArrayReadMode} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads) :
    read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads = result := by
  have bounds := parsed.cursorBounds
  have permitted : ¬ (result.after = 0 ∨ maxOperands < leaves expression) := by
    have limit := parsed.operandBound
    omega
  simp only [read, parsed.grammar, summarize, permitted, ↓reduceIte, parsed.inferred]
  cases result
  simp only [Result.mk.injEq, true_and]
  exact ⟨parsed.operands.symm, parsed.staticValue.symm⟩

theorem read_sound {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {arrayReads : ArrayReadMode} (bound : position ≤ text.length + 1)
    (success : (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≠ 0) :
    ∃ expression, At text names position expression
      (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads)
      maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
  obtain ⟨value, bounds, found, _, leafBound, inferred, result⟩ := summarize_success success
  refine ⟨value.expression, ?_⟩
  rw [read, result]
  exact ⟨bound, found, inferred, rfl, leafBound, rfl⟩

theorem at_unique {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {arrayReads : ArrayReadMode} {left right : Integer.Expr} {leftResult rightResult : Result}
    (leftAt : At text names position left leftResult maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    (rightAt : At text names position right rightResult maskFirst maskAfter allowSign arrays initials elaborating arrayReads) :
    left = right ∧ leftResult = rightResult := by
  have syntaxSame := Option.some.inj (leftAt.grammar.symm.trans rightAt.grammar)
  exact ⟨congrArg Parsed.expression syntaxSame, (read_complete leftAt).symm.trans (read_complete rightAt)⟩

theorem at_safe {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {arrayReads : ArrayReadMode} {expression : Integer.Expr} {result : Result} {values : Integer.Store}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating arrayReads)
    (fits : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) values) :
    expression.Safe values ∧ result.bounds.Contains (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  have safe := expression.infer_sound parsed.inferred fits
  exact ⟨safe.2, safe.1, expression.inferred_execution parsed.inferred fits⟩

end Silver.ScalarExpression.ArrayGrammar
