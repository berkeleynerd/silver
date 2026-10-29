module

public import Silver.ComposeModelCalls
public import Silver.ComposeEvaluation
public import Silver.ComposeSubtypeDeclarations

@[expose] public section

namespace Silver.Compose.Expressions

/-- The backward subtype lookup calls lexical equality only for names within
its source, including the selected binding's declaration span. -/
theorem model_legal_subtypeLookupModel : ∀ text, ValidText text → ∀ subtypeNames first after index,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    index ≤ subtypeNames.items.length →
    subtypeLookupModelBody.Legal modelCalls (Context.locals {text,subtypeNames,first,after,index}) := by
  intro text valid subtypeNames first after index namesValid firstBound afterBound indexBound
  dsimp +instances only [subtypeLookupModelBody, Expr.Legal, Expr.eval, Context.locals, Field.get,
    Function.isLexical, modelCalls, Calls.get]
  simp +instances
  intro firstNonzero afterIncreasing indexNonzero
  have member : IntegerSubtypes.binding subtypeNames index ∈ subtypeNames.items :=
    subtypeBinding_mem (environment := subtypeNames) (index := index)
      (Nat.pos_of_ne_zero indexNonzero) indexBound
  have item := namesValid.2 _ member
  exact ⟨⟨valid.1, valid.2, item.1, item.2.1, item.2.2.1⟩,
    ⟨valid.1, valid.2, Nat.pos_of_ne_zero firstNonzero, afterIncreasing, afterBound⟩⟩

end Silver.Compose.Expressions
