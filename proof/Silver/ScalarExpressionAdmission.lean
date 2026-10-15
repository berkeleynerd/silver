module

public import Silver.ScalarExpressionRecognition
public import Silver.ScalarExpressionEnvironment

@[expose] public section

/-! Admission is the independent source grammar plus typed intermediate
arithmetic safety and the finite operand resource bound. The following
equivalence proves that the reader implements that definition. -/
namespace Silver.ScalarExpression

structure At (text : Source) (names : Environment) (position : Nat)
    (expression : Integer.Expr) (result : Result)
    (maskFirst maskAfter : Nat := 0) (allowSign : Bool := true) : Prop where
  positionBound : position ≤ text.length + 1
  grammar : ExpressionAt text names maskFirst maskAfter allowSign position expression result.after
  inferred : expression.infer (ranges names) = some result.bounds
  operands : result.operands = leaves expression
  operandBound : leaves expression ≤ maxOperands
  staticValue : result.isStatic = isStatic names expression

theorem at_read_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign) :
    read text position names maskFirst maskAfter allowSign = result := by
  have bounds := syntax_bounds parsed.positionBound parsed.grammar
  dsimp only at bounds
  have recognized := parseFuel_complete parsed.grammar (text.length + 1) parsed.positionBound (by omega)
  unfold read
  rw [recognized]
  simp only [summarize]
  have valid : ¬ (result.after = 0 ∨ maxOperands < leaves expression) := by
    have leaf := parsed.operandBound
    omega
  simp only [valid, ↓reduceIte, parsed.inferred]
  cases result
  simp only [Result.mk.injEq, true_and]
  exact ⟨parsed.operands.symm, parsed.staticValue.symm⟩

theorem read_sound {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} (bound : position ≤ text.length + 1)
    (success : (read text position names maskFirst maskAfter allowSign).after ≠ 0) :
    ∃ expression, At text names position expression
      (read text position names maskFirst maskAfter allowSign) maskFirst maskAfter allowSign := by
  obtain ⟨value, bounds, found, _, leafBound, inferred, result⟩ := summarize_success success
  refine ⟨value.expression, ?_⟩
  change At text names position value.expression
    (summarize names (parseFuel (text.length + 1) text position names maskFirst maskAfter allowSign))
    maskFirst maskAfter allowSign
  rw [result]
  exact ⟨bound, parseFuel_sound bound found, inferred, rfl, leafBound, rfl⟩

theorem read_complete {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result}
    (parsed : At text names position expression result maskFirst maskAfter allowSign) :
    read text position names maskFirst maskAfter allowSign = result := at_read_complete parsed

theorem at_unique {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {left right : Integer.Expr} {leftResult rightResult : Result}
    (leftAt : At text names position left leftResult maskFirst maskAfter allowSign)
    (rightAt : At text names position right rightResult maskFirst maskAfter allowSign) :
    left = right ∧ leftResult = rightResult := by
  have leftBounds := syntax_bounds leftAt.positionBound leftAt.grammar
  have rightBounds := syntax_bounds rightAt.positionBound rightAt.grammar
  have l := parseFuel_complete leftAt.grammar (text.length + 1) leftAt.positionBound (by omega)
  have r := parseFuel_complete rightAt.grammar (text.length + 1) rightAt.positionBound (by omega)
  have syntaxSame := Option.some.inj (l.symm.trans r)
  have same : left = right := congrArg Parsed.expression syntaxSame
  exact ⟨same, (read_complete leftAt).symm.trans (read_complete rightAt)⟩

theorem admission_iff {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {result : Result} (bound : position ≤ text.length + 1) :
    (∃ expression, At text names position expression result maskFirst maskAfter allowSign) ↔
      read text position names maskFirst maskAfter allowSign = result ∧ result.after ≠ 0 := by
  constructor
  · rintro ⟨expression, parsed⟩
    have bounds := syntax_bounds parsed.positionBound parsed.grammar
    dsimp only at bounds
    exact ⟨read_complete parsed, by omega⟩
  · rintro ⟨rfl, success⟩
    exact read_sound bound success

theorem at_safe {text : Source} {names : Environment} {position maskFirst maskAfter : Nat}
    {allowSign : Bool} {expression : Integer.Expr} {result : Result} {values : Integer.Store}
    (parsed : At text names position expression result maskFirst maskAfter allowSign)
    (fits : Integer.Fits (ranges names) values) :
    expression.Safe values ∧ result.bounds.Contains (expression.evaluate values) ∧
      expression.checkedEvaluate values = some (expression.evaluate values) := by
  have safe := expression.infer_sound parsed.inferred fits
  exact ⟨safe.2, safe.1, expression.inferred_execution parsed.inferred fits⟩

end Silver.ScalarExpression
