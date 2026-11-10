module

public import Silver.ProcedureNameCharacterReadings
public import Silver.ProcedureNameCompoundTokens

@[expose] public section

set_option maxHeartbeats 800000

namespace Silver.Predicate
open Compose ScalarProcedures

/-- The Integer Image spelling, attribute designator and argument retain their
separate source spans, so the lexical check covers every scalar argument read. -/
theorem ActualNameFreeTrace.imageSyntax {text : Source}
    {names : BindingEnvironment} {scalarNames : ScalarExpression.Environment}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials}
    {elaborating integerHidden : Bool}
    {position target limit targetFirst targetAfter : Nat} {expression : Integer.Expr}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (source : ImageReading text names scalarNames integerHidden position expression arrays initials elaborating)
    (positionBound : position ≤ text.length + 1)
    (finishBound : (imageParts text position scalarNames arrays initials elaborating).following ≤ limit)
    (targetFound : ScalarExpression.lookup text scalarNames targetFirst targetAfter = target)
    (targetBound : target ≤ ArrayBindings.scalarLimit) :
    integerMentions target expression = false ∧
      ActualNameFreeTrace text limit targetFirst targetAfter
        (imageParts text position scalarNames arrays initials elaborating).following := by
  let parts := imageParts text position scalarNames arrays initials elaborating
  have scalarSource := source.scalar
  have scalarBounds := scalarSource.cursorBounds
  change 0 < fixedAfter text parts.attributeAfter "(" false ∧
    fixedAfter text parts.attributeAfter "(" false < parts.scalar.after ∧
    parts.scalar.after ≤ text.length + 1 at scalarBounds
  have namePositive : nameAfter text parts.attributeFirst ≠ 0 := by
    have ordered : parts.attributeFirst < parts.attributeAfter := source.attributeOrdered
    change parts.attributeFirst < nameAfter text parts.attributeFirst at ordered
    omega
  obtain ⟨attributePositive, bytes, attributeSource⟩ := nameAfter_source namePositive
  have attributeBounds := Named.identifier_bounds attributeSource
  have attributeLength : parts.attributeFirst + bytes.length = parts.attributeAfter := attributeBounds.2.1
  have attributeEndBound : parts.attributeAfter ≤ text.length + 1 := attributeBounds.2.2.2
  have longName : 2 ≤ bytes.length := by
    have spelling := source.attributeName
    change Named.nameIs text parts.attributeFirst parts.attributeAfter [105, 109, 97, 103, 101] = true at spelling
    simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq, List.length_cons, List.length_nil] at spelling
    omega
  have typeBound : parts.typeAfter ≤ text.length + 1 :=
    fixedAfter_result_bound text (skipAt text position) "integer" true (by decide)
  have tickPositive : fixedAfter text parts.typeAfter "'" false ≠ 0 := by
    intro zero
    have positive := source.attributePositive
    change skipAt text (fixedAfter text parts.typeAfter "'" false) ≠ 0 at positive
    simp only [zero, skipAt, ↓reduceIte, ne_eq, not_true_eq_false] at positive
  obtain ⟨tickFirstPositive, tickBound, tickMatched, tickAfter⟩ := fixedAfter_fields typeBound tickPositive
  change skipAt text parts.typeAfter + 1 ≤ text.length + 1 at tickBound
  change fixedAfter text parts.typeAfter "'" false = skipAt text parts.typeAfter + 1 at tickAfter
  have tickFound := tickMatched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at tickFound
  have tick := tickFound.1.2 ⟨0, by simp⟩
  simp only [Nat.add_zero] at tick
  have tickByte : Cursor.byteAt text (skipAt text parts.typeAfter) = 39 := lowercase_symbol (by decide) tick
  have attributeSource' : Named.IdentifierAt text (skipAt text (skipAt text parts.typeAfter + 1)) bytes parts.attributeAfter := by
    rw [← tickAfter]
    exact attributeSource
  have opening : fixedAfter text parts.attributeAfter "(" false ≠ 0 := Nat.ne_of_gt scalarBounds.1
  have openAdvance := Compose.Expressions.model_fixed_advances text _ "(" false attributeEndBound (by decide) opening
  have following := source.following
  change position < fixedAfter text parts.scalar.after ")" false at following
  change fixedAfter text parts.scalar.after ")" false ≤ limit at finishBound
  have closing : fixedAfter text parts.scalar.after ")" false ≠ 0 := by omega
  have closeAdvance := Compose.Expressions.model_fixed_advances text _ ")" false scalarBounds.2.2 (by decide) closing
  have typePositive : fixedAfter text position "integer" true ≠ 0 := by
    simpa only [imageParts, fixedAfter_skipped positionBound] using source.typePresent
  have typeSame : fixedAfter text position "integer" true = parts.typeAfter := (fixedAfter_skipped positionBound "integer" true).symm
  have typeAdvance := Compose.Expressions.model_fixed_advances text _ "'" false typeBound (by decide) tickPositive
  have attrSkip := ScalarExpression.skip_bounds text (fixedAfter text parts.typeAfter "'" false)
    (fixedAfter_result_bound text parts.typeAfter "'" false (by decide))
  change fixedAfter text parts.typeAfter "'" false ≤ parts.attributeFirst ∧ parts.attributeFirst ≤ text.length + 1 at attrSkip
  have afterType := trace.fixedWord (word := "integer") positionBound (by decide) (by decide) typePositive (by
    rw [typeSame]
    omega)
  rw [typeSame] at afterType
  have afterAttribute := afterType.attribute (by
    omega) rfl (by omega) tickByte attributeSource' longName (by omega)
  have afterOpen := afterAttribute.fixedSymbol (byte := '(') attributeEndBound
    (by unfold OrdinarySymbol; decide) opening (show fixedAfter text parts.attributeAfter "(" false ≤ limit by omega)
  obtain ⟨free, afterScalar⟩ := afterOpen.scalar scalarSource
    (show parts.scalar.after ≤ limit by omega) targetFound targetBound
  exact ⟨free, afterScalar.fixedSymbol (byte := ')') scalarBounds.2.2
    (by unfold OrdinarySymbol; decide) closing finishBound⟩

end Silver.Predicate
