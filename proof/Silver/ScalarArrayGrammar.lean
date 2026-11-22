module

public import Silver.ScalarArrayAttributes
public import Silver.PredicateArrayViews

@[expose] public section

/-! Scalar syntax over a complete named-array table. Shape attributes are
static literal values; component reads retain their source-selected descriptor.
The recursive subscript reader disables component reads while preserving shape
attributes, so `A (A'First)` does not admit nested indexed components. -/
namespace Silver.ScalarExpression

inductive ArrayReadMode
  | allElements | mutableElements | noElements
  deriving DecidableEq, Repr

namespace ArrayGrammar

def attributeAtom (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat) : Option Parsed := do
  let query ← ArrayAttributes.parse text position names arrays maskFirst maskAfter
  some ⟨query.after, .literal (query.query.bounds query.shape).lower⟩

def parseFuel : Nat → Source → Nat → Environment → ArrayBindings.Table →
    Nat → Nat → Bool → ArrayReadMode → Option Parsed
  | 0, _, _, _, _, _, _, _, _ => none
  | fuel + 1, text, position, names, arrays, maskFirst, maskAfter, allowSign, arrayReads =>
      let first := skip text position
      if first = 0 ∨ first > text.length then none
      else if Cursor.byteAt text first ≠ 40 then
        let ordinary := ScalarExpression.atom text first names maskFirst maskAfter allowSign
        if ordinary.isSome then ordinary else
          let after := nameAfter text first
          if symbol text after 39 ≠ 0 then
            attributeAtom text first names arrays maskFirst maskAfter
          else
            let target := ArrayBindings.lookup text arrays.items first after
            if arrayReads = .noElements ∨
                (arrayReads = .mutableElements ∧ (ArrayBindings.binding arrays.items target).mutable = false) ∨
                after = 0 ∨ target = 0 ∨
                (ArrayBindings.binding arrays.items target).isBoolean = true ∨
                lookup text names first after ≠ 0 ∨
                Cursor.byteAt text first = 43 ∨ Cursor.byteAt text first = 45 ∨
                (ScalarLiteral.read text first).after ≠ 0 ∨
                (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter first after = true) then none
            else
              let opened := symbol text after 40
              if opened = 0 then none else do
                let index ← parseFuel fuel text opened names arrays maskFirst maskAfter true .noElements
                let closed := symbol text index.after 41
                if closed ≤ first then none
                else some ⟨closed, .indexed (ArrayBindings.binding arrays.items target).viewDescriptor index.expression⟩
      else
        let inner := skip text (first + 1)
        if inner > text.length then none
        else if Cursor.byteAt text inner = 43 ∨ Cursor.byteAt text inner = 45 then
          let next := skip text (inner + 1)
          let number := ScalarLiteral.read text next
          close text (if number.after ≠ 0 then literal number (Cursor.byteAt text inner == 45)
            else (parseFuel fuel text next names arrays maskFirst maskAfter false arrayReads).map
              fun value => unary value (Cursor.byteAt text inner == 45))
        else do
          let left ← parseFuel fuel text inner names arrays maskFirst maskAfter true arrayReads
          let next := skip text left.after
          if next = 0 ∨ next > text.length then none
          else if Cursor.byteAt text next = 41 then
            some ⟨next + 1, .parenthesized left.expression⟩
          else if binaryAfter text next = 0 then none
          else
            let right ← parseFuel fuel text (binaryAfter text next) names arrays maskFirst maskAfter false arrayReads
            close text (binary left right (lowercase (Cursor.byteAt text next)))

def summarize (names : Environment) (arrays : ArrayBindings.Table)
    (initials : ArrayBindings.Initials) (elaborating : Bool) (parsed : Option Parsed) : Result :=
  match parsed with
  | none => invalid
  | some value =>
      if value.after = 0 ∨ maxOperands < leaves value.expression then invalid
      else match value.expression.infer (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) with
      | none => invalid
      | some bounds => ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩

def read (text : Source) (position : Nat) (names : Environment)
    (arrays : ArrayBindings.Table) (maskFirst maskAfter : Nat := 0)
    (allowSign : Bool := true) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) (arrayReads : ArrayReadMode := .allElements) : Result :=
  summarize names arrays initials elaborating
    (parseFuel (text.length + 1) text position names arrays maskFirst maskAfter allowSign arrayReads)

theorem summarize_success {names : Environment} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {parsed : Option Parsed}
    (success : (summarize names arrays initials elaborating parsed).after ≠ 0) :
    ∃ value bounds, parsed = some value ∧ value.after ≠ 0 ∧
      leaves value.expression ≤ maxOperands ∧
      value.expression.infer (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) = some bounds ∧
      summarize names arrays initials elaborating parsed =
        ⟨value.after, bounds, leaves value.expression, isStatic names value.expression⟩ := by
  cases parsed with
  | none => simp [summarize, invalid] at success
  | some value =>
      simp only [summarize] at success ⊢
      split at success
      · simp [invalid] at success
      · rename_i good
        cases found : value.expression.infer
            (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) with
        | none => simp [found, invalid] at success
        | some bounds =>
            refine ⟨value, bounds, rfl, ?_, ?_, found, ?_⟩
            · simp only [found] at success; exact success
            · omega
            · simp only [good, ↓reduceIte]

theorem read_has_expression {text : Source} {position : Nat} {names : Environment}
    {arrays : ArrayBindings.Table} {maskFirst maskAfter : Nat} {allowSign : Bool}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {arrayReads : ArrayReadMode}
    (success : (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≠ 0) :
    ∃ expression, expression.infer (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) =
        some (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).bounds ∧
      leaves expression = (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).operands ∧
      isStatic names expression = (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).isStatic := by
  obtain ⟨value, bounds, _, _, _, found, result⟩ := summarize_success success
  exact ⟨value.expression, by simpa only [read, result] using found,
    by simp only [read, result], by simp only [read, result]⟩

theorem read_safe {text : Source} {position : Nat} {names : Environment}
    {arrays : ArrayBindings.Table} {maskFirst maskAfter : Nat} {allowSign : Bool}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {arrayReads : ArrayReadMode} {values : Integer.Store}
    (success : (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).after ≠ 0)
    (fits : Integer.Fits (ArrayBindings.viewRanges arrays.items initials elaborating (ranges names)) values) :
    ∃ expression : Integer.Expr, expression.Safe values ∧
      (read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads).bounds.Contains
        (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  obtain ⟨expression, found, _, _⟩ := read_has_expression success
  have safe := expression.infer_sound found fits
  exact ⟨expression, safe.2, safe.1, expression.inferred_execution found fits⟩

theorem read_zero (text : Source) (names : Environment) (arrays : ArrayBindings.Table)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (initials : ArrayBindings.Initials)
    (elaborating : Bool) (arrayReads : ArrayReadMode) :
    read text 0 names arrays maskFirst maskAfter allowSign initials elaborating arrayReads = invalid := by
  simp [read, parseFuel, skip, summarize]

end ArrayGrammar
end Silver.ScalarExpression
