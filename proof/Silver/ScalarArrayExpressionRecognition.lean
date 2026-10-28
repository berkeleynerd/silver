module

public import Silver.ScalarArrayExpressionGrammar

@[expose] public section

namespace Silver.ScalarExpression

theorem parseArraysFuel_bounds {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Metadata} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseArraysFuel fuel text position names arrays maskFirst maskAfter allowSign = some value) :
    position < value.after ∧ value.after ≤ text.length + 1 := by
  induction fuel generalizing position allowSign value with
  | zero => cases found
  | succ fuel ih =>
      have first := skip_bounds text position bound
      rw [parseArraysFuel] at found
      dsimp only at found
      split at found
      · cases found
      · rename_i valid
        split at found
        · have atom := arrayAtom_bounds first.2 found
          exact ⟨by omega, atom.2⟩
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

theorem parseArraysFuel_sound {fuel : Nat} {text : Source} {position maskFirst maskAfter : Nat}
    {names : Environment} {arrays : ArrayBindings.Metadata} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseArraysFuel fuel text position names arrays maskFirst maskAfter allowSign = some value) :
    ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value := by
  induction fuel generalizing position allowSign value with
  | zero => cases found
  | succ fuel ih =>
      have first := skip_bounds text position bound
      rw [parseArraysFuel] at found
      dsimp only at found
      split at found
      · cases found
      · rename_i valid
        split at found
        · rename_i notGroup
          exact .atom (by omega) (by omega) notGroup (arrayAtom_sound first.2 found)
        · rename_i group
          have inside := skip_bounds text (skip text position + 1) (by omega)
          split at found
          · cases found
          · rename_i innerValid
            have opened : Opens text position := ⟨by omega, by omega, by omega, by unfold inner; omega⟩
            split at found
            · rename_i signed
              have next := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              obtain ⟨original, originalFound, closeGood, rfl⟩ := close_result found
              split at originalFound
              · obtain ⟨numberGood, rfl⟩ := literal_result originalFound
                exact .signed opened signed (ScalarLiteral.read_sound next.2 numberGood)
                  (symbolAt_iff.mpr ⟨rfl, closeGood⟩)
              · rename_i noNumber
                simp only [Option.map_eq_some_iff] at originalFound
                obtain ⟨child, childFound, rfl⟩ := originalFound
                exact .unary opened signed
                  ((noInteger_iff text _ next.2).mpr (by simpa using noNumber))
                  (ih next.2 childFound) (symbolAt_iff.mpr ⟨rfl, closeGood⟩)
            · rename_i notSign
              change (Option.bind _ _) = some value at found
              simp only [Option.bind_eq_some_iff] at found
              obtain ⟨left, leftFound, found⟩ := found
              have leftBounds := parseArraysFuel_bounds inside.2 leftFound
              split at found
              · cases found
              · rename_i nextValid
                split at found
                · rename_i closing
                  cases found
                  exact .grouped opened notSign (ih inside.2 leftFound)
                    ⟨by omega, by omega, closing, rfl⟩
                · split at found
                  · cases found
                  · rename_i operator
                    have operatorBounds := binaryAfter_bounds operator
                    change (Option.bind _ _) = some value at found
                    simp only [Option.bind_eq_some_iff] at found
                    obtain ⟨right, rightFound, found⟩ := found
                    obtain ⟨combined, combinedFound, closeGood, rfl⟩ := close_result found
                    exact .binary opened notSign (ih inside.2 leftFound) (by omega) (by omega)
                      (binaryAfter_sound operator) (ih operatorBounds.2 rightFound) combinedFound
                      (symbolAt_iff.mpr ⟨rfl, closeGood⟩)

theorem arrays_syntax_bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (bound : position ≤ text.length + 1)
    (parsed : ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value) :
    0 < position ∧ position < value.after ∧ value.after ≤ text.length + 1 := by
  induction parsed with
  | @atom position allowSign value nonzero within notGroup atom =>
      have first := skip_bounds text position bound
      have after := arrayAtom_syntax_bounds first.2 atom
      have positive : position ≠ 0 := by
        intro zero
        simp [skip, zero] at nonzero
      exact ⟨by omega, by omega, after.2⟩
  | @signed position value finish closed allowSign opened _ number closing =>
      have start := opens_bounds bound opened
      have numberBounds := ScalarLiteral.integer_bounds number
      have next := skip_bounds text (inner text position + 1) (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds numberBounds.2.1 (show symbol text finish 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @unary position closed allowSign value opened _ _ _ closing ih =>
      have start := opens_bounds bound opened
      have next := skip_bounds text (inner text position + 1) (by omega)
      have child := ih next.2
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @grouped position closed allowSign value opened _ _ closing ih =>
      have start := opens_bounds bound opened
      have child := ih (by omega)
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds child.2.2 (show symbol text value.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩
  | @binary position closed operatorEnd allowSign leftValue rightValue combinedValue opened _ _ _ within operator _ combined closing ihl ihr =>
      have start := opens_bounds bound opened
      have left := ihl (by omega)
      have next := skip_bounds text leftValue.after left.2.2
      have operatorBounds := binaryToken_bounds operator
      have right := ihr (by omega)
      have same := binary_result combined
      have closeEquation := symbolAt_iff.mp closing
      have finish := symbol_bounds (by omega : combinedValue.after ≤ text.length + 1)
        (show symbol text combinedValue.after 41 ≠ 0 by rw [closeEquation.1]; exact closeEquation.2)
      rw [closeEquation.1] at finish
      exact ⟨start.1, by dsimp only; omega, finish.2⟩

theorem parseArraysFuel_complete {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed} (parsed : ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value)
    (fuel : Nat) (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    parseArraysFuel fuel text position names arrays maskFirst maskAfter allowSign = some value := by
  induction parsed generalizing fuel with
  | @atom position allowSign value nonzero within notGroup atom =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have first := skip_bounds text position bound
          rw [parseArraysFuel]
          dsimp only
          simp only [nonzero, Nat.not_lt.mpr within, false_or, ↓reduceIte]
          rw [ite_eq_left notGroup]
          exact arrayAtom_complete first.2 (by omega) atom
  | @signed position value finish closed allowSign opened sign number closing =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have numberEquation := ScalarLiteral.read_complete number
          have numberPositive : _ ≠ 0 := Nat.ne_of_gt
            (Nat.lt_of_le_of_lt (Nat.zero_le _) (ScalarLiteral.integer_bounds number).1)
          have closeEquation := symbolAt_iff.mp closing
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at sign numberEquation innerWithin
          unfold Sign at sign
          simp [parseArraysFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, sign, numberEquation, numberPositive,
            literal, close, closeEquation.1, closeEquation.2, inner]
  | @unary position closed allowSign value opened sign noNumber child closing ih =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have next := skip_bounds text (inner text position + 1) (by omega)
          have childEquation := ih fuel next.2 (by omega)
          have noNumberEquation := (noInteger_iff text _ next.2).mp noNumber
          have closeEquation := symbolAt_iff.mp closing
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at sign childEquation noNumberEquation innerWithin
          unfold Sign at sign
          simp [parseArraysFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, sign, noNumberEquation, childEquation,
            close, unary, closeEquation.1, closeEquation.2, inner]
  | @grouped position closed allowSign value opened notSign child closing ih =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have childEquation := ih fuel (by omega) (by omega)
          rcases closing with ⟨closeNonzero, closeWithin, closeByte, rfl⟩
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at notSign childEquation innerWithin
          unfold Sign at notSign
          simp [parseArraysFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, notSign, childEquation,
            closeNonzero, Nat.not_lt.mpr closeWithin, closeByte]
  | @binary position closed operatorEnd allowSign leftValue rightValue combinedValue opened notSign left nextNonzero nextWithin operator right combined closing ihl ihr =>
      cases fuel with
      | zero => omega
      | succ fuel =>
          have start := opens_bounds bound opened
          have leftBounds := arrays_syntax_bounds (by omega) left
          have next := skip_bounds text leftValue.after leftBounds.2.2
          have operatorBounds := binaryToken_bounds operator
          have operatorEquation := binaryAfter_complete operator
          have leftEquation := ihl fuel (by omega) (by omega)
          have rightEquation := ihr fuel (by omega) (by omega)
          have closeEquation := symbolAt_iff.mp closing
          have notClose := binaryToken_not_close operator
          have notInvalid : operatorEnd ≠ 0 := by omega
          rcases opened with ⟨nonzero, within, opening, innerWithin⟩
          unfold inner at notSign leftEquation innerWithin
          unfold Sign at notSign
          simp [parseArraysFuel, nonzero, Nat.not_lt.mpr within, opening,
            Nat.not_lt.mpr innerWithin, notSign, leftEquation, nextNonzero,
            Nat.not_lt.mpr nextWithin, notClose, notInvalid, operatorEquation, rightEquation,
            combined, close, closeEquation.1, closeEquation.2]

/-- One current source grammar, with the scalar-only parser reused exactly for
subscripts and for an environment with no array names. -/
def sourceSyntaxAt (text : Source) (names : Environment) (arrays : ArrayBindings.Metadata)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (position : Nat) (value : Parsed) : Prop :=
  match arrays with
  | [] => SyntaxAt text names maskFirst maskAfter allowSign position value
  | _ :: _ => ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value

def parseWithArrays (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Metadata) (maskFirst maskAfter : Nat) (allowSign : Bool) : Option Parsed :=
  match arrays with
  | [] => parseFuel fuel text position names maskFirst maskAfter allowSign
  | _ :: _ => parseArraysFuel fuel text position names arrays maskFirst maskAfter allowSign

theorem sourceSyntax_bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (parsed : sourceSyntaxAt text names arrays maskFirst maskAfter allowSign position value) :
    0 < position ∧ position < value.after ∧ value.after ≤ text.length + 1 := by
  cases arrays with
  | nil => exact syntax_bounds bound parsed
  | cons => exact arrays_syntax_bounds bound parsed

theorem parseWithArrays_sound {fuel : Nat} {text : Source} {names : Environment}
    {arrays : ArrayBindings.Metadata} {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (bound : position ≤ text.length + 1)
    (found : parseWithArrays fuel text position names arrays maskFirst maskAfter allowSign = some value) :
    sourceSyntaxAt text names arrays maskFirst maskAfter allowSign position value := by
  cases arrays with
  | nil => exact parseFuel_sound bound found
  | cons => exact parseArraysFuel_sound bound found

theorem parseWithArrays_complete {text : Source} {names : Environment} {arrays : ArrayBindings.Metadata}
    {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (parsed : sourceSyntaxAt text names arrays maskFirst maskAfter allowSign position value)
    (fuel : Nat) (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    parseWithArrays fuel text position names arrays maskFirst maskAfter allowSign = some value := by
  cases arrays with
  | nil => exact parseFuel_complete parsed fuel bound enough
  | cons => exact parseArraysFuel_complete parsed fuel bound enough

theorem read_eq_summarizeArrays (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (arrays : ArrayBindings.Metadata)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    read text position names maskFirst maskAfter allowSign arrays initials elaborating =
      summarizeArrays names arrays initials elaborating
        (parseWithArrays (text.length + 1) text position names arrays maskFirst maskAfter allowSign) := by
  cases arrays <;> rfl

theorem summarizeArrays_success {names : Environment} {arrays : ArrayBindings.Metadata}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {parsed : Option Parsed}
    (success : (summarizeArrays names arrays initials elaborating parsed).after ≠ 0) :
    ∃ value bounds, parsed = some value ∧ value.after ≠ 0 ∧ leaves value.expression ≤ maxOperands ∧
      value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) = some bounds ∧
      summarizeArrays names arrays initials elaborating parsed =
        ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩ := by
  cases parsed with
  | none => simp [summarizeArrays, invalid] at success
  | some value =>
      simp only [summarizeArrays] at success ⊢
      split at success
      · simp [invalid] at success
      · rename_i good
        cases found : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
        | none => simp [found, invalid] at success
        | some bounds =>
            refine ⟨value, bounds, rfl, ?_, ?_, found, ?_⟩
            · simp only [found] at success; exact success
            · omega
            · simp only [good, ↓reduceIte]

theorem atom_readsOnly {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed}
    (parsed : AtomAt text names maskFirst maskAfter allowSign position value) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  cases parsed with
  | unsigned | signed => trivial
  | @name bytes finish index nonzero within notSign noNumber identifier found positive unmasked =>
      have bounded := lookup_bound text names (skip text position) finish
      rw [found] at bounded
      exact ⟨by omega, bounded⟩

theorem binary_readsOnly {left right combined : Parsed} {operator : Nat} {allowed : Nat → Prop}
    (leftReads : left.expression.ReadsOnly allowed) (rightReads : right.expression.ReadsOnly allowed)
    (found : binary left right operator = some combined) : combined.expression.ReadsOnly allowed := by
  unfold binary at found
  repeat' first | split at found | (cases found <;> exact ⟨leftReads, rightReads⟩)

theorem binary_hasArray {left right combined : Parsed} {operator : Nat}
    (found : binary left right operator = some combined) :
    combined.expression.hasArray = (left.expression.hasArray || right.expression.hasArray) := by
  unfold binary at found
  repeat' first | split at found | (cases found <;> rfl)

theorem syntax_readsOnly {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {value : Parsed}
    (parsed : SyntaxAt text names maskFirst maskAfter allowSign position value) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  induction parsed with
  | atom _ _ _ atom => exact atom_readsOnly atom
  | signed => trivial
  | unary _ _ _ _ _ ih =>
      simp only [unary]
      split <;> exact ih
  | grouped _ _ _ _ ih => exact ih
  | binary _ _ _ _ _ _ _ combined _ ihl ihr =>
      have result := binary_readsOnly ihl ihr combined
      exact result

theorem arrays_syntax_noArray_readsOnly {text : Source} {names : Environment}
    {arrays : ArrayBindings.Metadata} {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (parsed : ArraysSyntaxAt text names arrays maskFirst maskAfter allowSign position value)
    (absent : value.expression.hasArray = false) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  induction parsed with
  | atom _ _ _ atom =>
      cases atom with
      | ordinary parsed => exact atom_readsOnly parsed
      | indexed => contradiction
  | signed => trivial
  | unary _ _ _ _ _ ih =>
      simp only [unary] at absent ⊢
      split at absent <;> rename_i condition <;>
        simpa only [condition, Bool.false_eq_true, ↓reduceIte, Integer.Expr.ReadsOnly] using ih absent
  | grouped _ _ _ _ ih => exact ih absent
  | binary _ _ _ _ _ _ _ combined _ ihl ihr =>
      rw [binary_hasArray combined] at absent
      have parts := Bool.or_eq_false_iff.mp absent
      have result := binary_readsOnly (ihl parts.1) (ihr parts.2) combined
      exact result

theorem sourceSyntax_noArray_readsOnly {text : Source} {names : Environment}
    {arrays : ArrayBindings.Metadata} {position maskFirst maskAfter : Nat} {allowSign : Bool} {value : Parsed}
    (parsed : sourceSyntaxAt text names arrays maskFirst maskAfter allowSign position value)
    (absent : value.expression.hasArray = false) :
    value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) := by
  cases arrays with
  | nil => exact syntax_readsOnly parsed
  | cons => exact arrays_syntax_noArray_readsOnly parsed absent

end Silver.ScalarExpression
