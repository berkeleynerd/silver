import Silver.ComposeExpression

/-! Shared expression recognition and its independent source derivations.
The recognizer retains only cursor/length/use metadata; source meanings retain
the literal values proved by `LiteralAt`, rather than trusting that metadata. -/

namespace Silver.Compose

open Named

def maxExpressionOperands : Nat := 16

structure NameContext where
  staticFirst : Nat := 0
  staticAfter : Nat := 0
  staticLength : Nat := 0
  dynamicFirst : Nat := 0
  dynamicAfter : Nat := 0
  deriving DecidableEq, Repr

structure ExpressionResult where
  after : Nat := 0
  staticLength : Nat := 0
  dynamicSeen : Bool := false
  staticSeen : Bool := false
  deriving DecidableEq, Repr

def invalidExpression : ExpressionResult := {}

def matchesStatic (text : Source) (context : NameContext) (first after : Nat) : Bool :=
  decide (0 < context.staticFirst) &&
    equalName text context.staticFirst context.staticAfter first after

def matchesDynamic (text : Source) (context : NameContext) (first after : Nat) : Bool :=
  decide (0 < context.dynamicFirst) &&
    equalName text context.dynamicFirst context.dynamicAfter first after

def operandCore (text : Source) (start : Nat) (context : NameContext) : ExpressionResult :=
  if start ≤ text.length ∧ Cursor.byteAt text start = 34 then
    if Output.literalEnd text (start + 1) ≠ 0 then
      ⟨Output.literalEnd text (start + 1), Guarded.literalLength text (start + 1), false, false⟩
    else invalidExpression
  else if identifierEnd text start ≠ 0 then
    if matchesStatic text context start (identifierEnd text start) then
      ⟨identifierEnd text start, context.staticLength, false, true⟩
    else if matchesDynamic text context start (identifierEnd text start) then
      ⟨identifierEnd text start, 0, true, false⟩
    else invalidExpression
  else invalidExpression

def operandAt (text : Source) (position : Nat) (context : NameContext) : ExpressionResult :=
  operandCore text (Cursor.triviaPosition text position) context

def Operand.summary (atom : Operand) (context : NameContext) (after : Nat) : ExpressionResult :=
  ⟨after, atom.staticLength context.staticLength, decide (atom.dynamicCount = 1),
    decide (atom.staticCount = 1)⟩

inductive OperandAt (text : Source) (context : NameContext) : Nat → Operand → Nat → Prop
  | literal {position after : Nat} {bytes : Source} :
      Cursor.triviaPosition text position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text position + 1) bytes after →
      OperandAt text context position (.literal bytes) after
  | staticName {position after : Nat} {bytes : Source} :
      IdentifierAt text (Cursor.triviaPosition text position) bytes after →
      matchesStatic text context (Cursor.triviaPosition text position) after = true →
      OperandAt text context position .staticReference after
  | dynamicName {position after : Nat} {bytes : Source} :
      IdentifierAt text (Cursor.triviaPosition text position) bytes after →
      matchesStatic text context (Cursor.triviaPosition text position) after = false →
      matchesDynamic text context (Cursor.triviaPosition text position) after = true →
      OperandAt text context position .dynamicReference after

theorem identifier_not_quote {text bytes : Source} {position after : Nat}
    (parsed : IdentifierAt text position bytes after) : Cursor.byteAt text position ≠ 34 := by
  cases parsed with
  | identifier _ first _ =>
      simp only [letter, decide_eq_true_eq] at first
      omega

theorem operand_complete {text : Source} {context : NameContext} {position after : Nat} {atom : Operand}
    (parsed : OperandAt text context position atom after) :
    operandAt text position context = atom.summary context after := by
  cases parsed with
  | literal bound quote value =>
      have nonzero : after ≠ 0 := by have := Output.literalAt_bounds value; omega
      simp [operandAt, operandCore, bound, quote, Output.literalAt_complete value,
        Guarded.literalLength_decodes value, nonzero, Operand.summary,
        Operand.staticLength, Operand.dynamicCount, Operand.staticCount]
  | staticName name same =>
      have nonzero : after ≠ 0 := by have := identifier_bounds name; omega
      simp [operandAt, operandCore, identifier_not_quote name, identifierEnd_complete name, nonzero,
        same, Operand.summary, Operand.staticLength, Operand.dynamicCount, Operand.staticCount]
  | dynamicName name different same =>
      have nonzero : after ≠ 0 := by have := identifier_bounds name; omega
      simp [operandAt, operandCore, identifier_not_quote name, identifierEnd_complete name, nonzero,
        different, same, Operand.summary, Operand.staticLength, Operand.dynamicCount, Operand.staticCount]

theorem operand_sound (text : Source) (position : Nat) (context : NameContext)
    (accepted : (operandAt text position context).after ≠ 0) :
    ∃ atom, OperandAt text context position atom (operandAt text position context).after ∧
      operandAt text position context = atom.summary context (operandAt text position context).after := by
  by_cases quote : Cursor.triviaPosition text position ≤ text.length ∧
      Cursor.byteAt text (Cursor.triviaPosition text position) = 34
  · by_cases nonzero : Output.literalEnd text (Cursor.triviaPosition text position + 1) ≠ 0
    · obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ nonzero
      have observed : operandAt text position context =
          ⟨Output.literalEnd text (Cursor.triviaPosition text position + 1), Guarded.literalLength text (Cursor.triviaPosition text position + 1), false, false⟩ := by
        simp [operandAt, operandCore, quote, nonzero]
      rw [observed]
      refine ⟨.literal bytes, .literal quote.1 quote.2 parsed, ?_⟩
      simp [Operand.summary, Operand.staticLength, Operand.dynamicCount,
        Operand.staticCount, Guarded.literalLength_decodes parsed]
    · simp [operandAt, operandCore, quote, nonzero, invalidExpression] at accepted
  · by_cases nonzero : identifierEnd text (Cursor.triviaPosition text position) ≠ 0
    · obtain ⟨bytes, parsed⟩ := identifierEnd_sound text _ nonzero
      by_cases same : matchesStatic text context (Cursor.triviaPosition text position)
          (identifierEnd text (Cursor.triviaPosition text position)) = true
      · have observed : operandAt text position context =
            ⟨identifierEnd text (Cursor.triviaPosition text position), context.staticLength, false, true⟩ := by
          simp [operandAt, operandCore, quote, nonzero, same]
        rw [observed]
        exact ⟨.staticReference, .staticName parsed same, rfl⟩
      · by_cases dynamic : matchesDynamic text context (Cursor.triviaPosition text position)
            (identifierEnd text (Cursor.triviaPosition text position)) = true
        · have observed : operandAt text position context =
              ⟨identifierEnd text (Cursor.triviaPosition text position), 0, true, false⟩ := by
            simp [operandAt, operandCore, quote, nonzero, same, dynamic]
          rw [observed]
          exact ⟨.dynamicReference, .dynamicName parsed (Bool.eq_false_iff.mpr same) dynamic, rfl⟩
        · simp [operandAt, operandCore, quote, nonzero, same, dynamic, invalidExpression] at accepted
    · simp [operandAt, operandCore, quote, nonzero, invalidExpression] at accepted

theorem operand_unique {text : Source} {context : NameContext} {position leftAfter rightAfter : Nat}
    {left right : Operand} (first : OperandAt text context position left leftAfter)
    (second : OperandAt text context position right rightAfter) : left = right ∧ leftAfter = rightAfter := by
  cases first with
  | literal bound quote parsed =>
      cases second with
      | literal _ _ other =>
          obtain ⟨rfl, rfl⟩ := Output.literalAt_unique parsed other
          exact ⟨rfl, rfl⟩
      | staticName name _ => exact False.elim (identifier_not_quote name quote)
      | dynamicName name _ _ => exact False.elim (identifier_not_quote name quote)
  | staticName name same =>
      cases second with
      | literal _ quote _ => exact False.elim (identifier_not_quote name quote)
      | staticName other _ => exact ⟨rfl, (identifier_unique name other).2⟩
      | dynamicName other different _ =>
          have ends := (identifier_unique name other).2
          rw [ends] at same
          simp [same] at different
  | dynamicName name different same =>
      cases second with
      | literal _ quote _ => exact False.elim (identifier_not_quote name quote)
      | staticName other matched =>
          have ends := (identifier_unique name other).2
          simp [ends, matched] at different
      | dynamicName other _ _ => exact ⟨rfl, (identifier_unique name other).2⟩

theorem operand_bounds {text : Source} {context : NameContext} {position after : Nat} {atom : Operand}
    (parsed : OperandAt text context position atom after)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) :
    position < after ∧ after ≤ text.length + 1 := by
  have trivia := Cursor.triviaPosition_bounds text position positive bounded
  cases parsed with
  | literal _ _ value => have := Output.literalAt_bounds value; omega
  | staticName name _ => have := identifier_bounds name; omega
  | dynamicName name _ _ => have := identifier_bounds name; omega

theorem operand_literals {text : Source} {context : NameContext} {position after : Nat} {bytes : Source}
    (parsed : OperandAt text context position (.literal bytes) after) :
    ∀ byte ∈ bytes, Output.printable byte = true := by
  cases parsed with
  | literal _ _ value => exact (Output.literalAt_bounds value).2.2

def hasAmpersand (text : Source) (after : Nat) : Bool :=
  decide (Cursor.triviaPosition text after ≤ text.length ∧
    Cursor.byteAt text (Cursor.triviaPosition text after) = 38)

def accumulated (atom : ExpressionResult) (length : Nat) (dynamicSeen staticSeen : Bool) : ExpressionResult :=
  ⟨atom.after, length + atom.staticLength, dynamicSeen || atom.dynamicSeen, staticSeen || atom.staticSeen⟩

def fitsAccumulator (atom : ExpressionResult) (length : Nat) (dynamicSeen : Bool) : Bool :=
  decide (atom.staticLength ≤ maxSourceLength - length) && !(dynamicSeen && atom.dynamicSeen)

def expressionTail (text : Source) (context : NameContext) :
    Nat → Nat → Nat → Bool → Bool → ExpressionResult
  | 0, _, _, _, _ => invalidExpression
  | remaining + 1, position, length, dynamicSeen, staticSeen =>
    let atom := operandAt text position context
    if atom.after = 0 ∨ fitsAccumulator atom length dynamicSeen = false then invalidExpression
    else if hasAmpersand text atom.after then
      expressionTail text context remaining (Cursor.triviaPosition text atom.after + 1)
        (length + atom.staticLength) (dynamicSeen || atom.dynamicSeen) (staticSeen || atom.staticSeen)
    else accumulated atom length dynamicSeen staticSeen

def expressionAt (text : Source) (position : Nat) (context : NameContext) : ExpressionResult :=
  expressionTail text context maxExpressionOperands position 0 false false

/-- Grammar constructors consume one source operand and, for `more`, an actual
ampersand. Their literal payloads come from the independent primitive grammar. -/
inductive ExpressionTailAt (text : Source) (context : NameContext) :
    Nat → Nat → Nat → Bool → Bool → Expression → ExpressionResult → Prop
  | last {remaining position after length : Nat} {dynamicSeen staticSeen : Bool} {atom : Operand} :
      OperandAt text context position atom after →
      fitsAccumulator (atom.summary context after) length dynamicSeen = true →
      hasAmpersand text after = false →
      ExpressionTailAt text context (remaining + 1) position length dynamicSeen staticSeen
        [atom] (accumulated (atom.summary context after) length dynamicSeen staticSeen)
  | more {remaining position after length : Nat} {dynamicSeen staticSeen : Bool}
      {atom : Operand} {rest : Expression} {result : ExpressionResult} :
      OperandAt text context position atom after →
      fitsAccumulator (atom.summary context after) length dynamicSeen = true →
      hasAmpersand text after = true →
      ExpressionTailAt text context remaining (Cursor.triviaPosition text after + 1)
        (length + atom.staticLength context.staticLength)
        (dynamicSeen || decide (atom.dynamicCount = 1))
        (staticSeen || decide (atom.staticCount = 1)) rest result →
      ExpressionTailAt text context (remaining + 1) position length dynamicSeen staticSeen (atom :: rest) result

def ExpressionAt (text : Source) (context : NameContext) (position : Nat)
    (expression : Expression) (result : ExpressionResult) : Prop :=
  ExpressionTailAt text context maxExpressionOperands position 0 false false expression result

theorem operand_after_nonzero {text : Source} {context : NameContext} {position after : Nat} {atom : Operand}
    (parsed : OperandAt text context position atom after) : after ≠ 0 := by
  cases parsed with
  | literal _ _ value => have := Output.literalAt_bounds value; omega
  | staticName name _ => have := identifier_bounds name; omega
  | dynamicName name _ _ => have := identifier_bounds name; omega

theorem expressionTail_complete {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    expressionTail text context remaining position length dynamicSeen staticSeen = result := by
  induction parsed with
  | last atom fits ending =>
      rw [expressionTail, operand_complete atom]
      simp only [Operand.summary] at fits
      simp [Operand.summary, operand_after_nonzero atom, fits, ending]
  | more atom fits ampersand previous ih =>
      rw [expressionTail, operand_complete atom]
      simp [Operand.summary, operand_after_nonzero atom, fits, ampersand] at *
      exact ih

theorem expressionTail_sound (text : Source) (context : NameContext)
    (remaining position length : Nat) (dynamicSeen staticSeen : Bool)
    (accepted : (expressionTail text context remaining position length dynamicSeen staticSeen).after ≠ 0) :
    ∃ expression, ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression
      (expressionTail text context remaining position length dynamicSeen staticSeen) := by
  induction remaining generalizing position length dynamicSeen staticSeen with
  | zero => simp [expressionTail, invalidExpression] at accepted
  | succ remaining ih =>
      by_cases valid : (operandAt text position context).after = 0 ∨
          fitsAccumulator (operandAt text position context) length dynamicSeen = false
      · simp [expressionTail, valid, invalidExpression] at accepted
      · have nonzero : (operandAt text position context).after ≠ 0 := fun bad => valid (Or.inl bad)
        have fits : fitsAccumulator (operandAt text position context) length dynamicSeen = true := by
          cases same : fitsAccumulator (operandAt text position context) length dynamicSeen <;> simp_all
        obtain ⟨atom, atomParsed, summary⟩ := operand_sound text position context nonzero
        by_cases amp : hasAmpersand text (operandAt text position context).after = true
        · simp only [expressionTail, valid, amp, ↓reduceIte] at accepted ⊢
          obtain ⟨rest, parsed⟩ := ih _ _ _ _ accepted
          refine ⟨atom :: rest, .more atomParsed ?_ amp ?_⟩
          · simpa only [← summary] using fits
          · have fixed := congrArg ExpressionResult.staticLength summary
            have dynamic := congrArg ExpressionResult.dynamicSeen summary
            have static := congrArg ExpressionResult.staticSeen summary
            simp only [Operand.summary] at fixed dynamic static
            simpa only [fixed, dynamic, static] using parsed
        · have ending : hasAmpersand text (operandAt text position context).after = false :=
            Bool.eq_false_iff.mpr amp
          simp only [expressionTail, valid, amp, ↓reduceIte, Bool.false_eq_true]
          refine ⟨[atom], ?_⟩
          have proof := ExpressionTailAt.last (remaining := remaining) (staticSeen := staticSeen)
            atomParsed (by simpa only [← summary] using fits) ending
          simpa only [← summary] using proof

theorem expressionTail_unique {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {left right : Expression} {leftResult rightResult : ExpressionResult}
    (first : ExpressionTailAt text context remaining position length dynamicSeen staticSeen left leftResult)
    (second : ExpressionTailAt text context remaining position length dynamicSeen staticSeen right rightResult) :
    left = right ∧ leftResult = rightResult := by
  induction first generalizing right rightResult with
  | last atom fits ending =>
      cases second with
      | last other _ _ =>
          obtain ⟨rfl, rfl⟩ := operand_unique atom other
          exact ⟨rfl, rfl⟩
      | more other _ amp _ =>
          obtain ⟨rfl, rfl⟩ := operand_unique atom other
          simp [ending] at amp
  | more atom fits amp rest ih =>
      cases second with
      | last other _ ending =>
          obtain ⟨rfl, rfl⟩ := operand_unique atom other
          simp [ending] at amp
      | more other _ _ otherRest =>
          obtain ⟨rfl, rfl⟩ := operand_unique atom other
          obtain ⟨rfl, rfl⟩ := ih otherRest
          exact ⟨rfl, rfl⟩

theorem expressionTail_count {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    expression ≠ [] ∧ expression.length ≤ remaining := by
  induction parsed with
  | last => simp
  | more _ _ _ _ ih => simpa using Nat.succ_le_succ ih.2

theorem expressionTail_literals {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    expression.LiteralsPrintable := by
  induction parsed with
  | last atom _ _ =>
      intro bytes present
      simp only [List.mem_singleton] at present
      subst present
      exact operand_literals atom
  | more atom _ _ _ ih =>
      intro bytes present
      simp only [List.mem_cons] at present
      rcases present with same | member
      · subst same
        exact operand_literals atom
      · exact ih bytes member

theorem expressionTail_staticLength {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    result.staticLength = length + expression.staticLength context.staticLength := by
  induction parsed with
  | last => simp [accumulated, Operand.summary, Expression.staticLength]
  | more _ _ _ _ ih => simpa [Expression.staticLength, Nat.add_assoc] using ih

theorem expressionTail_dynamicCount {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    (if dynamicSeen then 1 else 0) + expression.dynamicCount ≤ 1 := by
  induction parsed with
  | @last remaining position after length dynamicSeen staticSeen atom parsed fits ending =>
      cases atom <;> cases dynamicSeen <;>
        simp_all [fitsAccumulator, Operand.summary, Operand.dynamicCount, Expression.dynamicCount]
  | @more remaining position after length dynamicSeen staticSeen atom rest result parsed fits amp previous ih =>
      cases atom <;> cases dynamicSeen <;>
        simp_all [fitsAccumulator, Operand.summary, Operand.dynamicCount, Expression.dynamicCount]

theorem positive_sum (left right : Nat) :
    decide (0 < left + right) = (decide (0 < left) || decide (0 < right)) := by
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq, Bool.or_eq_true]
  omega

theorem expressionTail_dynamicSeen {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    result.dynamicSeen = (dynamicSeen || decide (0 < expression.dynamicCount)) := by
  induction parsed with
  | @last remaining position after length dynamicSeen staticSeen atom parsed fits ending =>
      cases atom <;> simp [accumulated, Operand.summary, Operand.dynamicCount, Expression.dynamicCount]
  | @more remaining position after length dynamicSeen staticSeen atom rest result parsed fits amp previous ih =>
      rw [ih]
      cases atom <;> simp [Expression.dynamicCount, Operand.dynamicCount]
      right
      exact decide_eq_true (by omega)

theorem expressionTail_staticSeen {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result) :
    result.staticSeen = (staticSeen || decide (0 < expression.staticCount)) := by
  induction parsed with
  | @last remaining position after length dynamicSeen staticSeen atom parsed fits ending =>
      cases atom <;> simp [accumulated, Operand.summary, Operand.staticCount, Expression.staticCount]
  | @more remaining position after length dynamicSeen staticSeen atom rest result parsed fits amp previous ih =>
      rw [ih]
      cases atom <;> simp [Expression.staticCount, Operand.staticCount]
      right
      exact decide_eq_true (by omega)

theorem expressionTail_length_bound {text : Source} {context : NameContext}
    {remaining position length : Nat} {dynamicSeen staticSeen : Bool}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionTailAt text context remaining position length dynamicSeen staticSeen expression result)
    (initial : length ≤ maxSourceLength) : result.staticLength ≤ maxSourceLength := by
  induction parsed with
  | last _ fits _ =>
      have fit := (Bool.and_eq_true_iff.mp fits).1
      have value := of_decide_eq_true fit
      simp only [accumulated, Operand.summary] at *
      omega
  | more _ fits _ _ ih =>
      apply ih
      have fit := (Bool.and_eq_true_iff.mp fits).1
      have value := of_decide_eq_true fit
      simp only [Operand.summary] at value
      omega

theorem expressionAt_bounded {text : Source} {context : NameContext} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult}
    (parsed : ExpressionAt text context position expression result)
    (safe : result.staticLength + (if result.dynamicSeen then capacity else 0) ≤ maxSourceLength) :
    expression.Bounded context.staticLength capacity := by
  have nonempty := (expressionTail_count parsed).1
  have fixed := expressionTail_staticLength parsed
  have counted := expressionTail_dynamicCount parsed
  have seen := expressionTail_dynamicSeen parsed
  simp only [Bool.false_or, Nat.zero_add, Bool.false_eq_true, ↓reduceIte] at fixed counted seen
  refine ⟨nonempty, counted, ?_⟩
  rw [fixed, seen] at safe
  have possibilities : expression.dynamicCount = 0 ∨ expression.dynamicCount = 1 := by omega
  rcases possibilities with zero | one
  · simpa [zero] using safe
  · simpa [one] using safe

inductive Form
  | direct | static | assignment | argument | guardedArgument
  | branching | guardedBranching | result | guardedResult
  deriving DecidableEq, Repr

def allForms : List Form :=
  [.direct, .static, .assignment, .argument, .guardedArgument,
   .branching, .guardedBranching, .result, .guardedResult]

def Form.hasArguments : Form → Bool
  | .direct | .static | .assignment => false
  | _ => true

def Form.hasAssignment : Form → Bool
  | .assignment | .result | .guardedResult => true
  | _ => false

inductive LiteralRole | ordinary | initial | assigned
  deriving DecidableEq, Repr

inductive ShellToken
  | fixed (spelling : String) (word : Bool)
  | staticDeclaration | dynamicDeclaration | staticReference | dynamicReference
  | literal (role : LiteralRole)
  | capacity | outputExpression
  deriving DecidableEq, Repr

def ShellToken.word (spelling : String) : ShellToken := .fixed spelling true
def ShellToken.symbol (spelling : String) : ShellToken := .fixed spelling false

structure ParserState where
  position : Nat := 1
  context : NameContext := {}
  capacity : Nat := maxSourceLength
  deriving DecidableEq, Repr

def initialState : ParserState := {}
def invalidState : ParserState := ⟨0, {}, 0⟩

def fixedAt (text : Source) (position : Nat) (spelling : String) (word : Bool) : Bool :=
  let bytes := spelling.toList.map Char.toNat
  decide (bytes.length ≤ text.length + 1 - position) &&
    decide (∀ index : Fin bytes.length,
      lowercase (Cursor.byteAt text (position + index.val)) = bytes[index.val]) &&
    (!word || decide (position + bytes.length > text.length) ||
      !identifierCharacter (Cursor.byteAt text (position + bytes.length)))

def staticNameAllowed (text : Source) (context : NameContext) (first after : Nat) : Bool :=
  !forbiddenName text first after &&
    (decide (context.dynamicFirst = 0) ||
      (!Arguments.forbiddenName text first after &&
        !equalName text context.dynamicFirst context.dynamicAfter first after))

def outputAllowed (form : Form) (state : ParserState) (result : ExpressionResult) : Bool :=
  (!result.dynamicSeen || decide (result.staticLength ≤ maxSourceLength - state.capacity)) &&
    (!form.hasAssignment || result.staticSeen)

def step (text : Source) (form : Form) (token : ShellToken) (state : ParserState) : ParserState :=
  let start := Cursor.triviaPosition text state.position
  let finish := identifierEnd text start
  match token with
  | .staticDeclaration =>
      if finish ≠ 0 ∧ staticNameAllowed text state.context start finish = true then
        {state with position := finish, context := {state.context with staticFirst := start, staticAfter := finish}}
      else invalidState
  | .dynamicDeclaration =>
      if finish ≠ 0 ∧ Arguments.forbiddenName text start finish = false then
        {state with position := finish, context := {state.context with dynamicFirst := start, dynamicAfter := finish}}
      else invalidState
  | .staticReference =>
      if finish ≠ 0 ∧ matchesStatic text state.context start finish = true then
        {state with position := finish}
      else invalidState
  | .dynamicReference =>
      if finish ≠ 0 ∧ matchesDynamic text state.context start finish = true then
        {state with position := finish}
      else invalidState
  | .literal role =>
      if start ≤ text.length ∧ Cursor.byteAt text start = 34 ∧ Output.literalEnd text (start + 1) ≠ 0 ∧
          (role ≠ .assigned ∨ Guarded.literalLength text (start + 1) = state.context.staticLength) then
        {state with position := Output.literalEnd text (start + 1), context := {state.context with staticLength := if role = .initial then Guarded.literalLength text (start + 1) else state.context.staticLength}}
      else invalidState
  | .capacity =>
      if (Guarded.decimalAt text start).after ≠ 0 then
        {state with position := (Guarded.decimalAt text start).after, capacity := (Guarded.decimalAt text start).value}
      else invalidState
  | .outputExpression =>
      if (expressionAt text state.position state.context).after ≠ 0 ∧
          outputAllowed form state (expressionAt text state.position state.context) = true then
        {state with position := (expressionAt text state.position state.context).after}
      else invalidState
  | .fixed spelling word =>
      if fixedAt text start spelling word then {state with position := start + spelling.length}
      else invalidState

inductive Event
  | declaration (dynamic : Bool) (canonical : Source)
  | reference (dynamic : Bool)
  | literal (role : LiteralRole) (bytes : Source)
  | capacity (value : Nat)
  | output (expression : Expression)
  deriving DecidableEq, Repr

inductive StepAt (text : Source) (form : Form) :
    ShellToken → ParserState → Option Event → ParserState → Prop
  | staticDeclaration {state : ParserState} {name : Source} {finish : Nat} :
      IdentifierAt text (Cursor.triviaPosition text state.position) name finish →
      staticNameAllowed text state.context (Cursor.triviaPosition text state.position) finish = true →
      StepAt text form .staticDeclaration state (some (.declaration false (name.map lowercase)))
        {state with position := finish, context := {state.context with
          staticFirst := Cursor.triviaPosition text state.position, staticAfter := finish}}
  | dynamicDeclaration {state : ParserState} {name : Source} {finish : Nat} :
      IdentifierAt text (Cursor.triviaPosition text state.position) name finish →
      Arguments.forbiddenName text (Cursor.triviaPosition text state.position) finish = false →
      StepAt text form .dynamicDeclaration state (some (.declaration true (name.map lowercase)))
        {state with position := finish, context := {state.context with
          dynamicFirst := Cursor.triviaPosition text state.position, dynamicAfter := finish}}
  | staticReference {state : ParserState} {name : Source} {finish : Nat} :
      IdentifierAt text (Cursor.triviaPosition text state.position) name finish →
      matchesStatic text state.context (Cursor.triviaPosition text state.position) finish = true →
      StepAt text form .staticReference state (some (.reference false)) {state with position := finish}
  | dynamicReference {state : ParserState} {name : Source} {finish : Nat} :
      IdentifierAt text (Cursor.triviaPosition text state.position) name finish →
      matchesDynamic text state.context (Cursor.triviaPosition text state.position) finish = true →
      StepAt text form .dynamicReference state (some (.reference true)) {state with position := finish}
  | literal {state : ParserState} {bytes : Source} {role : LiteralRole} {finish : Nat} :
      Cursor.triviaPosition text state.position ≤ text.length →
      Cursor.byteAt text (Cursor.triviaPosition text state.position) = 34 →
      Output.LiteralAt text (Cursor.triviaPosition text state.position + 1) bytes finish →
      (role = .assigned → bytes.length = state.context.staticLength) →
      StepAt text form (.literal role) state (some (.literal role bytes))
        {state with position := finish, context := {state.context with staticLength :=
          if role = .initial then bytes.length else state.context.staticLength}}
  | capacity {state : ParserState} {value finish : Nat} :
      Guarded.DecimalAt text (Cursor.triviaPosition text state.position) value finish →
      StepAt text form .capacity state (some (.capacity value)) {state with position := finish, capacity := value}
  | output {state : ParserState} {expression : Expression} {result : ExpressionResult} :
      ExpressionAt text state.context state.position expression result →
      outputAllowed form state result = true → result.after ≠ 0 →
      StepAt text form .outputExpression state (some (.output expression)) {state with position := result.after}
  | fixed {state : ParserState} {spelling : String} {word : Bool} :
      fixedAt text (Cursor.triviaPosition text state.position) spelling word = true →
      StepAt text form (.fixed spelling word) state none
        {state with position := Cursor.triviaPosition text state.position + spelling.length}

theorem step_complete {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} (parsed : StepAt text form token state event next) : step text form token state = next := by
  cases parsed with
  | staticDeclaration name allowed =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [step, identifierEnd_complete name, nonzero, allowed]
  | dynamicDeclaration name allowed =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [step, identifierEnd_complete name, nonzero, allowed]
  | staticReference name matched =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [step, identifierEnd_complete name, nonzero, matched]
  | dynamicReference name matched =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (identifier_bounds name).2.2.1)
      simp [step, identifierEnd_complete name, nonzero, matched]
  | @literal state bytes role finish bound quote literal equal =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (Output.literalAt_bounds literal).1)
      have compatible : role ≠ .assigned ∨ bytes.length = state.context.staticLength := by
        by_cases assigned : role = .assigned
        · exact Or.inr (equal assigned)
        · exact Or.inl assigned
      simp [step, bound, quote, Output.literalAt_complete literal, nonzero,
        Guarded.literalLength_decodes literal, compatible]
  | capacity decimal =>
      have nonzero : _ ≠ 0 := Nat.ne_of_gt (Nat.lt_of_le_of_lt (Nat.zero_le _) (Guarded.decimalAt_bounds decimal).1)
      simp [step, Guarded.decimalAt_complete decimal, nonzero]
  | output expression safe nonzero =>
      have equation := expressionTail_complete expression
      change expressionAt _ _ _ = _ at equation
      simp [step, equation, safe, nonzero]
  | fixed matched => simp [step, matched]

theorem step_sound (text : Source) (form : Form) (token : ShellToken) (state : ParserState)
    (accepted : (step text form token state).position ≠ 0) :
    ∃ event, StepAt text form token state event (step text form token state) := by
  cases token with
  | staticDeclaration =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨name, parsed⟩ := identifierEnd_sound text _ permitted.1
        exact ⟨_, .staticDeclaration parsed permitted.2⟩
      · exact False.elim (accepted rfl)
  | dynamicDeclaration =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨name, parsed⟩ := identifierEnd_sound text _ permitted.1
        exact ⟨_, .dynamicDeclaration parsed permitted.2⟩
      · exact False.elim (accepted rfl)
  | staticReference =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨name, parsed⟩ := identifierEnd_sound text _ permitted.1
        exact ⟨_, .staticReference parsed permitted.2⟩
      · exact False.elim (accepted rfl)
  | dynamicReference =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨name, parsed⟩ := identifierEnd_sound text _ permitted.1
        exact ⟨_, .dynamicReference parsed permitted.2⟩
      · exact False.elim (accepted rfl)
  | literal role =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨bytes, parsed⟩ := Output.literalAt_sound text _ permitted.2.2.1
        rw [Guarded.literalLength_decodes parsed]
        refine ⟨_, .literal permitted.1 permitted.2.1 parsed ?_⟩
        intro assigned
        have compatible := permitted.2.2.2
        simpa [assigned, Guarded.literalLength_decodes parsed] using compatible
      · exact False.elim (accepted rfl)
  | capacity =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        exact ⟨_, .capacity (Guarded.decimalAt_sound text _ permitted)⟩
      · exact False.elim (accepted rfl)
  | outputExpression =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        obtain ⟨expression, parsed⟩ := expressionTail_sound text state.context
          maxExpressionOperands state.position 0 false false permitted.1
        exact ⟨_, .output parsed permitted.2 permitted.1⟩
      · exact False.elim (accepted rfl)
  | fixed spelling word =>
      simp only [step] at accepted ⊢
      split at accepted
      · rename_i permitted
        rw [ite_eq_left permitted]
        exact ⟨none, .fixed permitted⟩
      · exact False.elim (accepted rfl)

theorem step_unique {text : Source} {form : Form} {token : ShellToken} {state next other : ParserState}
    {event otherEvent : Option Event}
    (first : StepAt text form token state event next)
    (second : StepAt text form token state otherEvent other) : event = otherEvent ∧ next = other := by
  have states := (step_complete first).symm.trans (step_complete second)
  refine ⟨?_, states⟩
  cases first with
  | staticDeclaration name allowed =>
      cases second with
      | staticDeclaration otherName _ =>
          obtain ⟨rfl, _⟩ := identifier_unique name otherName
          rfl
  | dynamicDeclaration name allowed =>
      cases second with
      | dynamicDeclaration otherName _ =>
          obtain ⟨rfl, _⟩ := identifier_unique name otherName
          rfl
  | staticReference => cases second; rfl
  | dynamicReference => cases second; rfl
  | literal _ _ value _ =>
      cases second with
      | literal _ _ otherValue _ =>
          obtain ⟨rfl, _⟩ := Output.literalAt_unique value otherValue
          rfl
  | capacity value =>
      cases second with
      | capacity otherValue =>
          obtain ⟨rfl, _⟩ := Guarded.decimalAt_unique value otherValue
          rfl
  | output expression _ _ =>
      cases second with
      | output otherExpression _ _ =>
          obtain ⟨rfl, _⟩ := expressionTail_unique expression otherExpression
          rfl
  | fixed => cases second; rfl

def suffixMatches (text : Source) (form : Form) : List ShellToken → ParserState → Bool
  | [], state => decide (state.position ≠ 0 ∧ Cursor.triviaPosition text state.position = text.length + 1)
  | token :: tokens, state => decide (state.position ≠ 0) && suffixMatches text form tokens (step text form token state)

inductive Parsed (text : Source) (form : Form) : List ShellToken → ParserState → List Event → Prop
  | done {state : ParserState} : state.position ≠ 0 →
      Cursor.triviaPosition text state.position = text.length + 1 → Parsed text form [] state []
  | next {token : ShellToken} {tokens : List ShellToken} {state next : ParserState}
      {event : Option Event} {events : List Event} :
      state.position ≠ 0 → StepAt text form token state event next →
      Parsed text form tokens next events → Parsed text form (token :: tokens) state (event.toList ++ events)

theorem parsed_position {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    {events : List Event} (parsed : Parsed text form tokens state events) : state.position ≠ 0 := by
  cases parsed <;> assumption

theorem parsed_complete {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    {events : List Event} (parsed : Parsed text form tokens state events) : suffixMatches text form tokens state = true := by
  induction parsed with
  | done positive ending => simp [suffixMatches, positive, ending]
  | next positive step rest ih => simp [suffixMatches, positive, step_complete step, ih]

theorem suffix_position {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    (accepted : suffixMatches text form tokens state = true) : state.position ≠ 0 := by
  cases tokens <;> simp_all [suffixMatches]

theorem parsed_sound (text : Source) (form : Form) (tokens : List ShellToken) (state : ParserState)
    (accepted : suffixMatches text form tokens state = true) : ∃ events, Parsed text form tokens state events := by
  induction tokens generalizing state with
  | nil =>
      simp only [suffixMatches, decide_eq_true_eq] at accepted
      exact ⟨[], .done accepted.1 accepted.2⟩
  | cons token tokens ih =>
      simp only [suffixMatches, Bool.and_eq_true, decide_eq_true_eq] at accepted
      obtain ⟨event, stepParsed⟩ := step_sound text form token state (suffix_position accepted.2)
      obtain ⟨events, rest⟩ := ih _ accepted.2
      exact ⟨_, .next accepted.1 stepParsed rest⟩

theorem parsed_unique {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    {left right : List Event} (first : Parsed text form tokens state left)
    (second : Parsed text form tokens state right) : left = right := by
  induction first generalizing right with
  | done => cases second; rfl
  | next _ step rest ih =>
      cases second with
      | next _ other otherRest =>
          obtain ⟨rfl, rfl⟩ := step_unique step other
          rw [ih otherRest]

theorem parsed_iff (text : Source) (form : Form) (tokens : List ShellToken) (state : ParserState) :
    suffixMatches text form tokens state = true ↔ ∃ events, Parsed text form tokens state events :=
  ⟨parsed_sound text form tokens state, fun ⟨_, parsed⟩ => parsed_complete parsed⟩





def Form.tokens : Form → List ShellToken
  | .direct =>
      [.word "with", .word "silver_io", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .word "begin", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .static =>
      [.word "with", .word "silver_io", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .staticDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .literal .initial, .symbol ";", .word "begin", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .assignment =>
      [.word "with", .word "silver_io", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .staticDeclaration, .symbol ":", .word "string", .symbol ":=", .literal .initial, .symbol ";", .word "begin", .staticReference, .symbol ":=", .literal .assigned, .symbol ";", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .argument =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "then", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .guardedArgument =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity, .word "then", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .branching =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "then", .word "if", .dynamicReference, .symbol "=", .literal .ordinary, .word "then", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "end", .word "if", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .guardedBranching =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity, .word "then", .word "if", .dynamicReference, .symbol "=", .literal .ordinary, .word "then", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "end", .word "if", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .result =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .staticDeclaration, .symbol ":", .word "string", .symbol ":=", .literal .initial, .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "then", .word "if", .dynamicReference, .symbol "=", .literal .ordinary, .word "then", .staticReference, .symbol ":=", .literal .assigned, .symbol ";", .word "else", .staticReference, .symbol ":=", .literal .assigned, .symbol ";", .word "end", .word "if", .symbol ";", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]
  | .guardedResult =>
      [.word "with", .word "silver_io", .symbol ";", .word "with", .word "silver_arguments", .symbol ";", .word "procedure", .word "main", .word "is", .word "pragma", .word "spark_mode", .symbol "(", .word "on", .symbol ")", .symbol ";", .dynamicDeclaration, .symbol ":", .word "constant", .word "string", .symbol ":=", .word "silver_arguments", .symbol ".", .word "first_or_default", .symbol "(", .literal .ordinary, .symbol ")", .symbol ";", .staticDeclaration, .symbol ":", .word "string", .symbol ":=", .literal .initial, .symbol ";", .word "begin", .word "if", .word "silver_arguments", .symbol ".", .word "input_is_valid", .word "and", .word "then", .dynamicReference, .symbol "'", .word "length", .symbol "<=", .capacity, .word "then", .word "if", .dynamicReference, .symbol "=", .literal .ordinary, .word "then", .staticReference, .symbol ":=", .literal .assigned, .symbol ";", .word "else", .staticReference, .symbol ":=", .literal .assigned, .symbol ";", .word "end", .word "if", .symbol ";", .word "silver_io", .symbol ".", .word "put_line", .symbol "(", .outputExpression, .symbol ")", .symbol ";", .word "else", .word "silver_arguments", .symbol ".", .word "reject", .symbol ";", .word "end", .word "if", .symbol ";", .word "end", .word "main", .symbol ";"]

inductive EventKind
  | declaration (dynamic : Bool)
  | reference (dynamic : Bool)
  | literal (role : LiteralRole)
  | capacity | output
  deriving DecidableEq, Repr

def Event.kind : Event → EventKind
  | .declaration dynamic _ => .declaration dynamic
  | .reference dynamic => .reference dynamic
  | .literal role _ => .literal role
  | .capacity _ => .capacity
  | .output _ => .output

def ShellToken.eventKind : ShellToken → Option EventKind
  | .fixed _ _ => none
  | .staticDeclaration => some (.declaration false)
  | .dynamicDeclaration => some (.declaration true)
  | .staticReference => some (.reference false)
  | .dynamicReference => some (.reference true)
  | .literal role => some (.literal role)
  | .capacity => some .capacity
  | .outputExpression => some .output

theorem step_eventKind {text : Source} {form : Form} {token : ShellToken} {state next : ParserState}
    {event : Option Event} (parsed : StepAt text form token state event next) :
    event.map Event.kind = token.eventKind := by cases parsed <;> rfl

theorem parsed_eventKinds {text : Source} {form : Form} {tokens : List ShellToken} {state : ParserState}
    {events : List Event} (parsed : Parsed text form tokens state events) :
    events.map Event.kind = tokens.filterMap ShellToken.eventKind := by
  induction parsed with
  | done => rfl
  | @next token tokens state next event events _ step _ ih =>
      have shape := step_eventKind step
      simp only [List.map_append, List.filterMap_cons]
      rw [← shape]
      cases event <;> simp [ih, Option.toList]

def FormMember (source : Source) (form : Form) : Prop :=
  0 < source.length ∧ source.length ≤ maxSourceLength ∧
    (∀ byte ∈ source, allowedCharacter byte = true) ∧
    ∃ events, Parsed source form form.tokens initialState events

def formAccepts (source : Source) (form : Form) : Bool :=
  decide (0 < source.length ∧ source.length ≤ maxSourceLength) &&
    source.all allowedCharacter && suffixMatches source form form.tokens initialState

theorem formAccepts_iff (source : Source) (form : Form) :
    formAccepts source form = true ↔ FormMember source form := by
  simp [formAccepts, FormMember, parsed_iff, and_assoc]

def selectedForm (source : Source) : Option Form := allForms.find? (formAccepts source)
def accepts (source : Source) : Bool := (selectedForm source).isSome
def Member (source : Source) : Prop := ∃ form, FormMember source form

theorem allForms_complete (form : Form) : form ∈ allForms := by cases form <;> simp [allForms]

theorem accepts_iff_member (source : Source) : accepts source = true ↔ Member source := by
  simp [accepts, selectedForm, List.find?_isSome, allForms_complete, formAccepts_iff, Member]

instance memberDecidable (source : Source) : Decidable (Member source) :=
  decidable_of_iff (accepts source = true) (accepts_iff_member source)

def SourceMeaning (source : Source) (form : Form) (events : List Event) : Prop :=
  FormMember source form ∧ selectedForm source = some form ∧
    Parsed source form form.tokens initialState events

theorem member_has_meaning {source : Source} (member : Member source) :
    ∃ form events, SourceMeaning source form events := by
  have someForm := (accepts_iff_member source).mpr member
  cases selected : selectedForm source with
  | none => simp [accepts, selected] at someForm
  | some form =>
      have accepted : formAccepts source form = true := List.find?_some selected
      have formMember := (formAccepts_iff source form).mp accepted
      obtain ⟨events, parsed⟩ := formMember.2.2.2
      exact ⟨form, events, formMember, selected, parsed⟩

theorem meaning_unique {source : Source} {leftForm rightForm : Form} {left right : List Event}
    (first : SourceMeaning source leftForm left) (second : SourceMeaning source rightForm right) :
    leftForm = rightForm ∧ left = right := by
  have forms := Option.some.inj (first.2.1.symm.trans second.2.1)
  subst rightForm
  exact ⟨rfl, parsed_unique first.2.2 second.2.2⟩

def hasArguments (source : Source) : Bool :=
  allForms.any (fun form => form.hasArguments && formAccepts source form)

def hasAssignment (source : Source) : Bool :=
  allForms.any (fun form => form.hasAssignment && formAccepts source form)

end Silver.Compose
