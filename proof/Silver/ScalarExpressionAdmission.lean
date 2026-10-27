module

public import Silver.ScalarArrayExpressionRecognition
public import Silver.ScalarExpressionEnvironment

@[expose] public section

/-! Admission is the independent source grammar plus typed intermediate
arithmetic safety and the finite operand resource bound. The following
equivalence proves that the reader implements that definition. -/
namespace Silver.ScalarExpression

structure At (text : Source) (names : Environment) (position : Nat)
    (expression : Integer.Expr) (result : Result)
    (maskFirst maskAfter : Nat := 0) (allowSign : Bool := true)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := [])
    (elaborating : Bool := false) : Prop where
  positionBound : position ≤ text.length + 1
  grammar : sourceSyntaxAt text names arrays maskFirst maskAfter allowSign position ⟨result.after, expression⟩
  inferred : expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) = some result.bounds
  operands : result.operands = leaves expression
  operandBound : leaves expression ≤ maxOperands
  staticValue : result.isStatic = isStatic names expression

theorem at_read_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating) :
    read text position names maskFirst maskAfter allowSign arrays initials elaborating = result := by
  have bounds := sourceSyntax_bounds parsed.positionBound parsed.grammar
  dsimp only at bounds
  have recognized := parseWithArrays_complete parsed.grammar (text.length + 1) parsed.positionBound (by omega)
  rw [read_eq_summarizeArrays, recognized]
  simp only [summarizeArrays]
  have valid : ¬ (result.after = 0 ∨ maxOperands < leaves expression) := by
    have leaf := parsed.operandBound
    omega
  simp only [valid, ↓reduceIte, parsed.inferred]
  cases result
  simp only [Result.mk.injEq, true_and]
  exact ⟨parsed.operands.symm, parsed.staticValue.symm⟩

theorem read_sound {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} (bound : position ≤ text.length + 1)
    (success : (read text position names maskFirst maskAfter allowSign arrays initials elaborating).after ≠ 0) :
    ∃ expression, At text names position expression
      (read text position names maskFirst maskAfter allowSign arrays initials elaborating)
      maskFirst maskAfter allowSign arrays initials elaborating := by
  have success' := success
  rw [read_eq_summarizeArrays] at success'
  obtain ⟨value, bounds, found, _, leafBound, inferred, result⟩ := summarizeArrays_success success'
  refine ⟨value.expression, ?_⟩
  rw [read_eq_summarizeArrays, result]
  exact ⟨bound, parseWithArrays_sound bound found, inferred, rfl, leafBound, rfl⟩

theorem read_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating) :
    read text position names maskFirst maskAfter allowSign arrays initials elaborating = result := at_read_complete parsed

theorem at_unique {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} {left right : Integer.Expr} {leftResult rightResult : Result}
    (leftAt : At text names position left leftResult maskFirst maskAfter allowSign arrays initials elaborating)
    (rightAt : At text names position right rightResult maskFirst maskAfter allowSign arrays initials elaborating) :
    left = right ∧ leftResult = rightResult := by
  have leftBounds := sourceSyntax_bounds leftAt.positionBound leftAt.grammar
  have rightBounds := sourceSyntax_bounds rightAt.positionBound rightAt.grammar
  have l := parseWithArrays_complete leftAt.grammar (text.length + 1) leftAt.positionBound (by omega)
  have r := parseWithArrays_complete rightAt.grammar (text.length + 1) rightAt.positionBound (by omega)
  have syntaxSame := Option.some.inj (l.symm.trans r)
  have same : left = right := congrArg Parsed.expression syntaxSame
  exact ⟨same, (read_complete leftAt).symm.trans (read_complete rightAt)⟩

theorem admission_iff {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} {result : Result} (bound : position ≤ text.length + 1) :
    (∃ expression, At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating) ↔
      read text position names maskFirst maskAfter allowSign arrays initials elaborating = result ∧ result.after ≠ 0 := by
  constructor
  · rintro ⟨expression, parsed⟩
    have bounds := sourceSyntax_bounds parsed.positionBound parsed.grammar
    dsimp only at bounds
    exact ⟨read_complete parsed, by omega⟩
  · rintro ⟨rfl, success⟩
    exact read_sound bound success

theorem at_safe {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating : Bool}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result} {values : Integer.Store}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating)
    (fits : Integer.Fits (ArrayBindings.ranges arrays initials elaborating (ranges names)) values) :
    expression.Safe values ∧ result.bounds.Contains (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  have safe := expression.infer_sound parsed.inferred fits
  exact ⟨safe.2, safe.1, expression.inferred_execution parsed.inferred fits⟩

theorem At.cursorBounds {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating) :
    0 < position ∧ position < result.after ∧ result.after ≤ text.length + 1 :=
  sourceSyntax_bounds parsed.positionBound parsed.grammar

theorem At.noArray_readsOnly {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials} {elaborating allowSign : Bool}
    {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign arrays initials elaborating)
    (absent : expression.hasArray = false) :
    expression.ReadsOnly (fun index => 0 < index ∧ index ≤ names.length) :=
  sourceSyntax_noArray_readsOnly parsed.grammar absent

end Silver.ScalarExpression
