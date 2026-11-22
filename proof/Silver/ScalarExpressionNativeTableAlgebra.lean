module

public import Silver.ScalarExpressionNativeArrayAtoms
public import Silver.ScalarExpressionNativeTableLayout
public import Silver.ScalarArrayGrammarRecognition

@[expose] public section

/-! Reuse the established arithmetic summary algebra under the explicit view
projection. The new source reader's syntax and recursion remain independent. -/
namespace Silver.ScalarExpression.Native

variable (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool)

theorem literal_table_correspondence (names : Environment) (number : ScalarLiteral.Result) (negative : Bool) :
    literalResult number negative = ArrayGrammar.summarize names arrays initials elaborating (literal number negative) :=
  literal_arrays_correspondence (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) names number negative

theorem unary_table_correspondence (names : Environment) (parsed : Option Parsed) (negative : Bool) :
    unaryResult (ArrayGrammar.summarize names arrays initials elaborating parsed) negative =
      ArrayGrammar.summarize names arrays initials elaborating (parsed.map fun value => unary value negative) :=
  unary_arrays_correspondence (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) names parsed negative

theorem binary_table_correspondence (names : Environment) (left right : Parsed) (operator : Nat)
    (leftPositive : left.after ≠ 0) (rightPositive : right.after ≠ 0) :
    binaryResult (ArrayGrammar.summarize names arrays initials elaborating (some left))
        (ArrayGrammar.summarize names arrays initials elaborating (some right)) operator =
      ArrayGrammar.summarize names arrays initials elaborating (binary left right operator) :=
  binary_arrays_correspondence (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) names left right operator leftPositive rightPositive

theorem close_table_correspondence (text : Source) (names : Environment) (parsed : Option Parsed) :
    closeResult text (ArrayGrammar.summarize names arrays initials elaborating parsed) =
      ArrayGrammar.summarize names arrays initials elaborating (close text parsed) :=
  close_arrays_correspondence (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) text names parsed

theorem parenthesized_table_correspondence (names : Environment) (value : Parsed) (finish : Nat)
    (positive : value.after ≠ 0) (finishPositive : finish ≠ 0) :
    ArrayGrammar.summarize names arrays initials elaborating (some ⟨finish, .parenthesized value.expression⟩) =
      if (ArrayGrammar.summarize names arrays initials elaborating (some value)).after = 0 then invalid
      else {ArrayGrammar.summarize names arrays initials elaborating (some value) with after := finish} :=
  parenthesized_arrays_correspondence (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) names value finish positive finishPositive

theorem summarizeTable_zero {names : Environment} {parsed : Option Parsed}
    (zero : (ArrayGrammar.summarize names arrays initials elaborating parsed).after = 0) :
    ArrayGrammar.summarize names arrays initials elaborating parsed = invalid :=
  summarizeArrays_zero (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating) zero

theorem summarizeTable_readsOnly {names : Environment} {value : Parsed}
    (capacity : names.length ≤ ArrayBindings.scalarLimit)
    (reads : value.expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length)) :
    ArrayGrammar.summarize names arrays initials elaborating (some value) = summarize names (some value) :=
  summarizeArrays_readsOnly capacity reads (ArrayBindings.viewNames arrays.items) initials
    (ArrayBindings.viewElaborating arrays.items elaborating)

end Silver.ScalarExpression.Native
