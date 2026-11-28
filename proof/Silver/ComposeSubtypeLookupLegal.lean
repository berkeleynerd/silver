module

public import Silver.ComposeModelCalls
public import Silver.ComposeEvaluation
public import Silver.ComposeSubtypeDeclarations

@[expose] public section

namespace Silver.Compose.Expressions

/-- The backward subtype lookup calls lexical equality only for names within
its source, including the selected binding's declaration span. -/
theorem model_legal_subtypeLookupModel : ∀ text, ValidText text → ∀ subtypeNames first after index qualifierFirst qualifierAfter,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    index ≤ subtypeNames.items.length → QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
    subtypeLookupModelBody.Legal modelCalls (Context.locals {text,subtypeNames,first,after,index,qualifierFirst,qualifierAfter}) := by
  intro text valid subtypeNames first after index qualifierFirst qualifierAfter namesValid firstBound afterBound indexBound qualifierValid
  dsimp +instances only [subtypeLookupModelBody, Expr.Legal, Expr.eval, Context.locals, Field.get,
    Function.isLexical, modelCalls, Calls.get]
  simp +instances
  intro firstNonzero afterIncreasing indexNonzero
  have member : IntegerSubtypes.binding subtypeNames index ∈ subtypeNames.items :=
    subtypeBinding_mem (environment := subtypeNames) (index := index)
      (Nat.pos_of_ne_zero indexNonzero) indexBound
  have item := namesValid.2 _ member
  have itemQualifier := item.2.2.2.2.2
  simp_all only [LexicalName, QualifiedNames.ValidSpan, ValidText, ValidCursor]
  constructor
  · simp only [true_and, and_true]
    exact ⟨Nat.succ_le_of_lt item.1, Nat.succ_le_of_lt (Nat.pos_of_ne_zero firstNonzero)⟩
  · intro _ qualifierNonzero itemPositive
    have qualifierSpan : 0 < qualifierFirst ∧ qualifierFirst < qualifierAfter ∧
        qualifierAfter ≤ text.length + 1 := by
      rcases qualifierValid with ⟨zero, _⟩ | present
      · exact False.elim (qualifierNonzero zero)
      · exact present
    have itemSpan : 0 < (IntegerSubtypes.binding subtypeNames index).qualifierFirst ∧
        (IntegerSubtypes.binding subtypeNames index).qualifierFirst <
          (IntegerSubtypes.binding subtypeNames index).qualifierAfter ∧
        (IntegerSubtypes.binding subtypeNames index).qualifierAfter ≤ text.length + 1 := by
      rcases item.2.2.2.2.2 with ⟨zero, _⟩ | present
      · exact False.elim (Nat.ne_of_gt itemPositive zero)
      · exact present
    simp only [true_and]
    exact ⟨⟨Nat.succ_le_of_lt itemSpan.1, itemSpan.2⟩,
      ⟨Nat.succ_le_of_lt qualifierSpan.1, qualifierSpan.2⟩⟩

end Silver.Compose.Expressions
