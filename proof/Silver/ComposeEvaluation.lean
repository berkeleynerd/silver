module

public import Silver.ComposeLexical
public import Silver.ComposeContracts
public import Silver.ComposeArrayDenotations

@[expose] public section

/-! Transport typed body evaluation from retained lexical callees to their
established meanings. Legality states only the domains of executed calls;
it contains no source/model equivalence premise. -/

namespace Silver.Compose.Expressions

def LexicalCursor (text : Source) (position : Nat) : Prop :=
  0 < text.length ∧ text.length ≤ maxSourceLength ∧ 1 ≤ position ∧ position ≤ text.length + 1

def LexicalName (text : Source) (first after : Nat) : Prop :=
  0 < text.length ∧ text.length ≤ maxSourceLength ∧ 1 ≤ first ∧ first < after ∧ after ≤ text.length + 1

def Expr.Legal (calls : Calls) (locals : Locals) : Expr ty → Prop
  | .lexTrivia a b => a.Legal calls locals ∧ b.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralEnd a b => a.Legal calls locals ∧ b.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralLength a b => a.Legal calls locals ∧ b.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals)
  | .lexIdentifier a b => a.Legal calls locals ∧ b.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals)
  | .lexForbidden a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧
      LexicalName (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexForbiddenArgument a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧
      LexicalName (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexEqual a b c d e => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧
      LexicalName (a.eval calls locals) (b.eval calls locals) (c.eval calls locals) ∧ LexicalName (a.eval calls locals) (d.eval calls locals) (e.eval calls locals)
  | .lexDecimal a b => a.Legal calls locals ∧ b.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals)
  | .lexTokenAt a b c d => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧
      LexicalCursor (a.eval calls locals) (b.eval calls locals) ∧ 0 < (c.eval calls locals).toList.length ∧ (c.eval calls locals).toList.length ≤ 16
  | .lexNormalize a => a.Legal calls locals ∧
      (a.eval calls locals).length ≤ maxSourceLength
  | .lexAllowed a => a.Legal calls locals ∧
      True
  | .defaultFalse f => f.Legal calls locals
  | .defaultFull f => f.Legal calls locals
  | .subtypeCount x => x.Legal calls locals
  | .subtypeItem x i => x.Legal calls locals ∧ i.Legal calls locals
  | .hiddenFlag x i => x.Legal calls locals ∧ i.Legal calls locals
  | .operationName x => x.Legal calls locals
  | .subtypeAppend a b c d e f g => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals ∧ g.Legal calls locals
  | .stateSubtype a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals
  | .forOperations name body => ∀ operation, body.Legal calls (locals.set .operation name operation)
  | .maxSubtypeBindings => True

  | .app f x => f.Legal calls locals ∧ x.Legal calls locals
  | .field _ x => x.Legal calls locals
  | .count x => x.Legal calls locals
  | .scalarCount x => x.Legal calls locals
  | .operatorByte x => x.Legal calls locals
  | .fullInterval | .emptyInterval => True
  | .interval a b | .integerNe a b | .integerLt a b => a.Legal calls locals ∧ b.Legal calls locals
  | .constraint a b => a.Legal calls locals ∧ b.Legal calls locals
  | .scalarBinding a b c d e f => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals
  | .scalarReadDefault a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals
  | .scalarReadArrays a b c d e f => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals
  | .expressionArrays a b c d e f g => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals ∧ g.Legal calls locals
  | .stateScalar s p names => s.Legal calls locals ∧ p.Legal calls locals ∧ names.Legal calls locals
  | .item x i => x.Legal calls locals ∧ i.Legal calls locals
  | .add x y => x.Legal calls locals ∧ y.Legal calls locals
  | .sub x y => x.Legal calls locals ∧ y.Legal calls locals
  | .eq x y => x.Legal calls locals ∧ y.Legal calls locals
  | .ne x y => x.Legal calls locals ∧ y.Legal calls locals
  | .boolNe x y => x.Legal calls locals ∧ y.Legal calls locals
  | .lt x y => x.Legal calls locals ∧ y.Legal calls locals
  | .le x y => x.Legal calls locals ∧ y.Legal calls locals
  | .gt x y => x.Legal calls locals ∧ y.Legal calls locals
  | .range x a b => x.Legal calls locals ∧ a.Legal calls locals ∧ b.Legal calls locals
  | .not x => x.Legal calls locals
  | .group x => x.Legal calls locals
  | .locals x => x.Legal calls locals
  | .byteAt text position => text.Legal calls locals ∧ position.Legal calls locals
  | .sourceLast text => text.Legal calls locals
  | .sourceLength text => text.Legal calls locals
  | .characterVal x => x.Legal calls locals
  | .tokenEq x y => x.Legal calls locals ∧ y.Legal calls locals
  | .tokenSpelling x => x.Legal calls locals
  | .spellingLength x => x.Legal calls locals
  | .wordToken x => x.Legal calls locals
  | .hasArguments x => x.Legal calls locals
  | .tokensLast x => x.Legal calls locals
  | .tokenIndex x i => x.Legal calls locals ∧ i.Legal calls locals
  | .binding a b c d e f => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals
  | .value a b c d e f g h => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals ∧ g.Legal calls locals ∧ h.Legal calls locals
  | .result a b c d e f => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals
  | .mul x y => x.Legal calls locals ∧ y.Legal calls locals
  | .scan a b c d e f g h i j => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals ∧ g.Legal calls locals ∧ h.Legal calls locals ∧ i.Legal calls locals ∧ j.Legal calls locals
  | .scanDepth s p d => s.Legal calls locals ∧ p.Legal calls locals ∧ d.Legal calls locals
  | .scanAtom s p m l d o n e => s.Legal calls locals ∧ p.Legal calls locals ∧ m.Legal calls locals ∧ l.Legal calls locals ∧ d.Legal calls locals ∧ o.Legal calls locals ∧ n.Legal calls locals ∧ e.Legal calls locals
  | .scanNeed s p => s.Legal calls locals ∧ p.Legal calls locals
  | .scanComplete s => s.Legal calls locals
  | .statePosition s p => s.Legal calls locals ∧ p.Legal calls locals
  | .stateTarget s p t => s.Legal calls locals ∧ p.Legal calls locals ∧ t.Legal calls locals
  | .stateCapacity s p c => s.Legal calls locals ∧ p.Legal calls locals ∧ c.Legal calls locals
  | .stateDynamic s a b => s.Legal calls locals ∧ a.Legal calls locals ∧ b.Legal calls locals
  | .stateBinding s p info => s.Legal calls locals ∧ p.Legal calls locals ∧ info.Legal calls locals
  | .someForm source => source.Legal calls locals
  | .firstForm _ source => source.Legal calls locals
  | .operation _ => True
  | .number n | .character n => True
  | .word _ | .integerTypeWord => True
  | .truth b => True
  | .variable name => True
  | .maxLength  => True
  | .maxBindings  => True
  | .arrayCount a => a.Legal calls locals
  | .wideInteger a => a.Legal calls locals
  | .wideNumber a => a.Legal calls locals
  | .elementCount a => a.Legal calls locals
  | .integerSub a b => a.Legal calls locals ∧ b.Legal calls locals
  | .integerAdd a b => a.Legal calls locals ∧ b.Legal calls locals
  | .integerGt a b => a.Legal calls locals ∧ b.Legal calls locals
  | .integerGe a b => a.Legal calls locals ∧ b.Legal calls locals
  | .arrayPut a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals
  | .arrayUsedValues a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals
  | .arrayNamesOnly a b => a.Legal calls locals ∧ b.Legal calls locals
  | .stateArray a b => a.Legal calls locals ∧ b.Legal calls locals
  | .statePositionArray a b c => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals
  | .arrayAppend a b c d e f g h => a.Legal calls locals ∧ b.Legal calls locals ∧ c.Legal calls locals ∧ d.Legal calls locals ∧ e.Legal calls locals ∧ f.Legal calls locals ∧ g.Legal calls locals ∧ h.Legal calls locals
  | .maxArrayBindings | .maxArrayElements | .invalidScalar | .integerNumber _ => True
  | .maxScalarBindings => True
  | .maxOperands  => True
  | .maxConcatenations => True
  | .token tok => True
  | .initial  => True
  | .invalid  => True
  | .invalidValue  => True
  | .invalidResult  => True
  | .invalidScan => True
  | .function symbol => symbol.isLexical = false
  | .andThen a b => a.Legal calls locals ∧ (a.eval calls locals = true → b.Legal calls locals)
  | .orElse a b => a.Legal calls locals ∧ (a.eval calls locals = false → b.Legal calls locals)
  | .ite c a b | .elsif c a b => c.Legal calls locals ∧
      (if c.eval calls locals then a.Legal calls locals else b.Legal calls locals)
  | .local name _ localValue rest => localValue.Legal calls locals ∧
      rest.Legal calls (locals.set _ name (localValue.eval calls locals))

set_option maxRecDepth 10000

theorem Expr.eval_lexical (calls : Calls) (meaning : Compose.Lexical.Meaning calls.primitive)
    (locals : Locals) : ∀ (expression : Expr ty), expression.Legal calls locals →
      expression.eval calls locals = expression.eval (lexical calls) locals
  | .lexTrivia a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have domain := legal.2.2
    have established := meaning.trivia (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) domain.2.2.1 domain.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lexLiteralEnd a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have domain := legal.2.2
    have established := meaning.literal (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) domain.2.2.1 domain.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lexLiteralLength a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have domain := legal.2.2
    have established := meaning.length (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) domain.2.2.1 domain.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lexIdentifier a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have domain := legal.2.2
    have established := meaning.identifier (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) domain.2.2.1 domain.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lexForbidden a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have domain := legal.2.2.2
    have established := meaning.forbidden (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) (c.eval calls locals) domain.2.2.1 domain.2.2.2.1 domain.2.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .lexForbiddenArgument a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have domain := legal.2.2.2
    have established := meaning.forbiddenArgument (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) (c.eval calls locals) domain.2.2.1 domain.2.2.2.1 domain.2.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .lexEqual a b c d e, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have domain := legal.2.2.2.2.2
    have established := meaning.equal (a.eval calls locals) domain.1.1 domain.1.2.1 (b.eval calls locals) (c.eval calls locals) (d.eval calls locals) (e.eval calls locals) domain.1.2.2.1 domain.1.2.2.2.1 domain.1.2.2.2.2 domain.2.2.2.1 domain.2.2.2.2.1 domain.2.2.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    all_goals rfl

  | .lexDecimal a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have domain := legal.2.2
    have established := meaning.decimal (a.eval calls locals) domain.1 domain.2.1 (b.eval calls locals) domain.2.2.1 domain.2.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lexTokenAt a b c d, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have domain := legal.2.2.2.2
    have established := meaning.token (a.eval calls locals) domain.1.1 domain.1.2.1 (b.eval calls locals) (c.eval calls locals) (d.eval calls locals) domain.1.2.2.1 domain.1.2.2.2 domain.2.1 domain.2.2
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    all_goals rfl

  | .lexNormalize a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have domain := legal.2
    have established := meaning.normalize (a.eval calls locals) domain
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    all_goals rfl

  | .lexAllowed a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have domain := legal.2
    have established := meaning.allowed (a.eval calls locals)
    dsimp only [Expr.eval, lexical, modelPrimitives]
    rw [established]
    rw [h0]
    all_goals rfl

  | .defaultFull f, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals f legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .subtypeCount x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .subtypeItem x i, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals i legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1]
    all_goals rfl

  | .hiddenFlag x i, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals i legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1]
    all_goals rfl

  | .operationName x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .subtypeAppend a b c d e f g, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals g legal.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1, h2, h3, h4, h5, h6]
    all_goals rfl

  | .stateSubtype a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1, h2]
    all_goals rfl

  | .forOperations name body, legal => by
    have output := Expr.eval_lexical calls meaning (locals.set .operation name .output) body (legal .output)
    have partialOutput :=  Expr.eval_lexical calls meaning (locals.set .operation name .partialOutput) body (legal .partialOutput)
    have argument := Expr.eval_lexical calls meaning (locals.set .operation name .argument) body (legal .argument)
    have validity := Expr.eval_lexical calls meaning (locals.set .operation name .validity) body (legal .validity)
    have reject := Expr.eval_lexical calls meaning (locals.set .operation name .reject) body (legal .reject)
    dsimp only [Expr.eval]
    rw [output, partialOutput, argument, validity, reject]
  | .maxSubtypeBindings, _ => rfl

  | .defaultFalse f, legal => by
    have same := Expr.eval_lexical calls meaning locals f legal
    dsimp only [Expr.eval]
    rw [same]

  | .app f x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals f legal.1
    have h1 := Expr.eval_lexical calls meaning locals x legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .field projection x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .count x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .scalarCount x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .operatorByte x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .fullInterval, _ | .emptyInterval, _ => rfl
  | .interval a b, legal | .integerNe a b, legal | .integerLt a b, legal | .constraint a b, legal => by
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1]
    all_goals rfl

  | .scalarBinding a b c d e f, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1, h2, h3, h4, h5]
    all_goals rfl

  | .scalarReadDefault a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical, Function.isLexical]
    rw [h0, h1, h2]
    rfl

  | .scalarReadArrays a b c d e f, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2
    dsimp only [Expr.eval, lexical, Function.isLexical]
    rw [h0, h1, h2, h3, h4, h5]
    rfl

  | .expressionArrays a b c d e f g, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals g legal.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical, Function.isLexical]
    rw [h0, h1, h2, h3, h4, h5, h6]
    rfl

  | .stateScalar s p names, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals names legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0, h1, h2]
    all_goals rfl

  | .item x i, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals i legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .add x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .sub x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .eq x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .ne x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .boolNe x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .lt x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .le x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .gt x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .range x a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals a legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals b legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .not x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .group x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .locals x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .byteAt text position, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals text legal.1
    have h1 := Expr.eval_lexical calls meaning locals position legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .sourceLast text, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals text legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .sourceLength text, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals text legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .characterVal x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .tokenEq x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .tokenSpelling x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .spellingLength x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .wordToken x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .hasArguments x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .tokensLast x, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .tokenIndex x i, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals i legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .binding a b c d e f, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    all_goals rfl

  | .value a b c d e f g h, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals g legal.2.2.2.2.2.2.1
    have h7 := Expr.eval_lexical calls meaning locals h legal.2.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    rw [h6]
    rw [h7]
    all_goals rfl

  | .result a b c d e f, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    all_goals rfl

  | .mul x y, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals x legal.1
    have h1 := Expr.eval_lexical calls meaning locals y legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .scan a b c d e f g h i j, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals g legal.2.2.2.2.2.2.1
    have h7 := Expr.eval_lexical calls meaning locals h legal.2.2.2.2.2.2.2.1
    have h8 := Expr.eval_lexical calls meaning locals i legal.2.2.2.2.2.2.2.2.1
    have h9 := Expr.eval_lexical calls meaning locals j legal.2.2.2.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    rw [h6]
    rw [h7]
    rw [h8]
    rw [h9]
    all_goals rfl

  | .scanDepth s p d, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals d legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .scanAtom s p m l d o n e, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals m legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals l legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals d legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals o legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals n legal.2.2.2.2.2.2.1
    have h7 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    rw [h6]
    rw [h7]
    all_goals rfl

  | .scanNeed s p, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .scanComplete s, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .statePosition s p, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .stateTarget s p t, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals t legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .stateCapacity s p c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .stateDynamic s a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals a legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals b legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .stateBinding s p info, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals s legal.1
    have h1 := Expr.eval_lexical calls meaning locals p legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals info legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .someForm source, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals source legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .firstForm arguments source, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals source legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .operation _, _ => rfl
  | .number n, _ => rfl
  | .character n, _ => rfl
  | .word _, _ | .integerTypeWord, _ => rfl
  | .truth b, _ => rfl
  | .variable name, _ => rfl
  | .maxLength , _ => rfl
  | .maxBindings , _ => rfl
  | .arrayCount a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .wideInteger a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .wideNumber a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .elementCount a, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal
    dsimp only [Expr.eval, lexical]
    rw [h0]
    all_goals rfl

  | .integerSub a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .integerAdd a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .integerGt a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .integerGe a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .arrayPut a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .arrayUsedValues a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .arrayNamesOnly a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .stateArray a b, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    all_goals rfl

  | .statePositionArray a b c, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    all_goals rfl

  | .arrayAppend a b c d e f g h, legal => by
    dsimp only [Expr.Legal] at legal
    have h0 := Expr.eval_lexical calls meaning locals a legal.1
    have h1 := Expr.eval_lexical calls meaning locals b legal.2.1
    have h2 := Expr.eval_lexical calls meaning locals c legal.2.2.1
    have h3 := Expr.eval_lexical calls meaning locals d legal.2.2.2.1
    have h4 := Expr.eval_lexical calls meaning locals e legal.2.2.2.2.1
    have h5 := Expr.eval_lexical calls meaning locals f legal.2.2.2.2.2.1
    have h6 := Expr.eval_lexical calls meaning locals g legal.2.2.2.2.2.2.1
    have h7 := Expr.eval_lexical calls meaning locals h legal.2.2.2.2.2.2.2
    dsimp only [Expr.eval, lexical]
    rw [h0]
    rw [h1]
    rw [h2]
    rw [h3]
    rw [h4]
    rw [h5]
    rw [h6, h7]
    all_goals rfl

  | .maxArrayBindings, _ | .maxArrayElements, _ | .invalidScalar, _ | .integerNumber _, _ => rfl
  | .maxScalarBindings, _ => rfl
  | .maxOperands , _ => rfl
  | .maxConcatenations, _ => rfl
  | .token tok, _ => rfl
  | .initial , _ => rfl
  | .invalid , _ => rfl
  | .invalidValue , _ => rfl
  | .invalidResult , _ => rfl
  | .invalidScan, _ => rfl
  | .function symbol, legal => by
      cases symbol <;>
        dsimp +instances only [Expr.Legal, Function.isLexical, Expr.eval, Calls.get, lexical] at legal ⊢ <;>
        simp_all
  | .andThen a b, legal => by
      have ha := Expr.eval_lexical calls meaning locals a legal.1
      dsimp only [Expr.eval]
      rw [← ha]
      cases chosen : a.eval calls locals
      · rfl
      · simpa only [Bool.true_and] using Expr.eval_lexical calls meaning locals b (legal.2 chosen)
  | .orElse a b, legal => by
      have ha := Expr.eval_lexical calls meaning locals a legal.1
      dsimp only [Expr.eval]
      rw [← ha]
      cases chosen : a.eval calls locals
      · simpa only [Bool.false_or] using Expr.eval_lexical calls meaning locals b (legal.2 chosen)
      · rfl
  | .ite c a b, legal => by
      have hc := Expr.eval_lexical calls meaning locals c legal.1
      dsimp only [Expr.Legal] at legal
      dsimp only [Expr.eval]
      rw [← hc]
      cases chosen : c.eval calls locals <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Expr.eval_lexical calls meaning locals b legal.2
      · exact Expr.eval_lexical calls meaning locals a legal.2
  | .elsif c a b, legal => by
      have hc := Expr.eval_lexical calls meaning locals c legal.1
      dsimp only [Expr.Legal] at legal
      dsimp only [Expr.eval]
      rw [← hc]
      cases chosen : c.eval calls locals <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Expr.eval_lexical calls meaning locals b legal.2
      · exact Expr.eval_lexical calls meaning locals a legal.2
  | .local name typeName localValue rest, legal => by
      have hv := Expr.eval_lexical calls meaning locals localValue legal.1
      dsimp only [Expr.eval]
      rw [← hv]
      exact Expr.eval_lexical calls meaning _ rest legal.2

/-- Native SPARK establishes the domains of executed lexical calls in these
bodies. No field asserts equality to the membership or semantic model. -/
structure LegalHelpers (calls : Calls) (domain : StateDomain := .basic) : Prop where
  callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames arrays subtypeHidden booleans,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → BooleanBindings.ValidEnvironment text booleans → ValidCursor text position →
    callAfterBody.Legal calls (Context.locals {text,scalarNames,arrays,names,position,operation,subtypeHidden,booleans})
  skip : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    skipBody.Legal calls (Context.locals {text,position})
  name : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    nameBody.Legal calls (Context.locals {text,position})
  fixed : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    fixedBody.Legal calls (Context.locals {text,position,token})
  take : ∀ text, ValidText text → ∀ position token,
    ValidCursor text position → ValidToken token →
    fixedBody.Legal calls (Context.locals {text,position,token})
  lookupFrom : ∀ text, ValidText text → ∀ names first after index,
    ValidNames text names → ValidName text first after → 1 ≤ index → index ≤ names.length + 1 →
    lookupFromBody.Legal calls (Context.locals {text,names,first,after,index})
  lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → ValidCursor text first → ValidCursor text after →
    lookupBody.Legal calls (Context.locals {text,names,first,after})
  literal : ∀ text, ValidText text → ∀ position,
    ValidCursor text position →
    literalBody.Legal calls (Context.locals {text,position})
  image : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    imageBody.Legal calls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  value : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    valueBody.Legal calls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  newName : ∀ text, ValidText text → ∀ state first after arguments,
    domain.holds text state → ValidCursor text first → ValidCursor text after →
    newNameBody.Legal calls (Context.locals {text,state,first,after,arguments})
  addBinding : ∀ text, ValidText text → ∀ state first after value mutable following,
    domain.holds text state → ValidCursor text first → ValidCursor text after → ValidValue text value → ValidCursor text following → state.names.length < maxBindings →
    addBindingBody.Legal calls (Context.locals {text,state,first,after,value,mutable,following})
  stringDeclaration : ∀ text, ValidText text → ∀ state arguments,
    domain.holds text state →
    stringDeclarationBody.Legal calls (Context.locals {text,state,arguments})
  scalarConstraint : ∀ text, ValidText text → ∀ position scalarNames baseBounds,
    ValidCursor text position → ScalarExpression.ValidEnvironment text scalarNames →
    baseBounds.Bounded →
    scalarConstraintBody.Legal calls (Context.locals {text,position,scalarNames,baseBounds})
  subtypeLookupModel : ∀ text, ValidText text → ∀ subtypeNames first after index,
    IntegerSubtypes.ValidEnvironment text subtypeNames → ValidCursor text first → ValidCursor text after →
    index ≤ subtypeNames.items.length →
    subtypeLookupModelBody.Legal calls (Context.locals {text,subtypeNames,first,after,index})
  scalarType : ∀ text, ValidText text → ∀ state position,
    domain.holds text state → ValidCursor text position →
    scalarTypeBody.Legal calls (Context.locals {text,state,position})
  subtypeDeclaration : ∀ text, ValidText text → ∀ state arguments,
    domain.holds text state →
    subtypeDeclarationBody.Legal calls (Context.locals {text,state,arguments})
  scalarDeclaration : ∀ text, ValidText text → ∀ state arguments,
    domain.holds text state →
    scalarDeclarationBody.Legal calls (Context.locals {text,state,arguments})
  declaration : ∀ text, ValidText text → ∀ state arguments,
    domain.holds text state →
    declarationBody.Legal calls (Context.locals {text,state,arguments})
  argument : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    argumentBody.Legal calls (Context.locals {text,state})
  declarations : ∀ text, ValidText text → ∀ state arguments,
    domain.holds text state →
    declarationsBody.Legal calls (Context.locals {text,state,arguments})
  expressionStep : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → ValidScan text scan →
    expressionStepBody.Legal calls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan})
  tail : ∀ text, ValidText text → ∀ names scan scalarNames integerHidden arrays initials elaborating,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → ValidScan text scan →
    tailBody.Legal calls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,names,scan})
  fits : ∀ text, ValidText text → ∀ result capacity,
    ValidResult text result → capacity ≤ maxSourceLength →
    fitsBody.Legal calls (Context.locals {text,result,capacity})
  comparison : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    comparisonBody.Legal calls (Context.locals {text,state})
  expression : ∀ text, ValidText text → ∀ position names scalarNames integerHidden arrays initials elaborating,
    ValidCursor text position → ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    expressionBody.Legal calls (Context.locals {text,scalarNames,integerHidden,arrays,initials,elaborating,position,names})
  target : ∀ text, ValidText text → ∀ state sameTarget,
    domain.holds text state →
    targetBody.Legal calls (Context.locals {text,state,sameTarget})
  dynamic : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    dynamicBody.Legal calls (Context.locals {text,state})
  assignmentValue : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    assignmentBody.Legal calls (Context.locals {text,state})
  output : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    outputBody.Legal calls (Context.locals {text,state})
  capacity : ∀ text, ValidText text → ∀ state,
    domain.holds text state →
    capacityBody.Legal calls (Context.locals {text,state})
  workTail : ∀ text, ValidText text → ∀ position remaining,
    ValidCursor text position → remaining ≤ maxConcatenations →
    workTailBody.Legal calls (Context.locals {text,position,remaining})
  workBudget : ∀ text, ValidText text →
    workBudgetBody.Legal calls (Context.locals {text})

structure LegalBodies (calls : Calls) : Prop extends LegalHelpers calls where
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state →
    stepBody.Legal calls (Context.locals {text,form,token,state})
  suffix : ∀ text, ValidText text → ∀ form nextToken state,
    ValidState text state → 1 ≤ nextToken → nextToken ≤ form.tokens.length + 1 →
    suffixBody.Legal calls (Context.locals {text,form,nextToken,state})
  formMember : ∀ text form, formBody.Legal calls (Context.locals {text,form})
  member : ∀ text, memberBody.Legal calls (Context.locals {text})
  arguments : ∀ text, argumentsBody.Legal calls (Context.locals {text})
  assignment : ∀ text, assignmentSelectorBody.Legal calls (Context.locals {text})


/-- Normalize only retained lexical meanings. All new helper calls stay
arbitrary until their checked equations and terminating recursion determine them. -/
theorem normalized_helpers {domain : StateDomain} (calls : Calls)
    (meaning : Compose.Lexical.Meaning calls.primitive)
    (source : HelperEquations calls calls domain) (legal : LegalHelpers calls domain) :
    HelperEquations calls (domain := domain) where
  ranges := source.ranges
  names := source.names
  scalarLookup := source.scalarLookup
  scalarRead := source.scalarRead
  arrayLookup := source.arrayLookup
  booleanLookup := source.booleanLookup
  booleanHidesInteger := source.booleanHidesInteger
  booleanDeclaration := source.booleanDeclaration
  arrayAdd := by
    intro text valid state first after bounds offset length mutable following componentBounds stateValid nameValid bindingValid room allocated ordered ending
    exact (source.arrayAdd text valid state first after bounds offset length mutable following componentBounds
      stateValid nameValid bindingValid room allocated ordered ending).trans
        (arrayAdd_eval_lexical calls text state first after bounds offset length mutable following componentBounds).symm
  arrayPut := by
    intro state value room safe
    exact (source.arrayPut state value room safe).trans (arrayPut_eval_lexical calls state value).symm
  arrayValuesModel := by
    intro text valid sourceState result position length parsed componentBounds bounded context
    exact (source.arrayValuesModel text valid sourceState result position length parsed componentBounds bounded context).trans
      (arrayValues_eval_lexical calls text sourceState result position length parsed componentBounds).symm
  arrayValues := source.arrayValues
  arrayDeclaration := by
    intro text valid state arguments context
    exact (source.arrayDeclaration text valid state arguments context).trans
      (arrayDeclaration_eval_lexical calls true text state arguments).symm
  scalarLiteral := source.scalarLiteral
  scalarAppend := source.scalarAppend
  scalarEmpty := source.scalarEmpty
  imageMinimum := source.imageMinimum
  imageMaximum := source.imageMaximum
  nameIs := source.nameIs
  callAfter := by
    intros
    apply Eq.trans
    · apply source.callAfter <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.callAfter <;> assumption
  readDeclarations := source.readDeclarations
  skip := by
    intros
    apply Eq.trans
    · apply source.skip <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.skip <;> assumption
  name := by
    intros
    apply Eq.trans
    · apply source.name <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.name <;> assumption
  fixed := by
    intros
    apply Eq.trans
    · apply source.fixed <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.fixed <;> assumption
  take := by
    intros
    apply Eq.trans
    · apply source.take <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.take <;> assumption
  lookupFrom := by
    intros
    apply Eq.trans
    · apply source.lookupFrom <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.lookupFrom <;> assumption
  lookup := by
    intros
    apply Eq.trans
    · apply source.lookup <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.lookup <;> assumption
  literal := by
    intros
    apply Eq.trans
    · apply source.literal <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.literal <;> assumption
  image := by
    intros
    apply Eq.trans
    · apply source.image <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.image <;> assumption
  value := by
    intros
    apply Eq.trans
    · apply source.value <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.value <;> assumption
  newName := by
    intros
    apply Eq.trans
    · apply source.newName <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.newName <;> assumption
  addBinding := by
    intros
    apply Eq.trans
    · apply source.addBinding <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.addBinding <;> assumption
  stringDeclaration := by
    intros
    apply Eq.trans
    · apply source.stringDeclaration <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.stringDeclaration <;> assumption
  scalarConstraint := by
    intros
    apply Eq.trans
    · apply source.scalarConstraint <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.scalarConstraint <;> assumption
  subtypeLookupModel := by
    intros
    apply Eq.trans
    · apply source.subtypeLookupModel <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.subtypeLookupModel <;> assumption
  scalarType := by
    intros
    apply Eq.trans
    · apply source.scalarType <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.scalarType <;> assumption
  subtypeDeclaration := by
    intros
    apply Eq.trans
    · apply source.subtypeDeclaration <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.subtypeDeclaration <;> assumption
  subtypeLookup := source.subtypeLookup
  scalarDeclaration := by
    intros
    apply Eq.trans
    · apply source.scalarDeclaration <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.scalarDeclaration <;> assumption
  declaration := by
    intros
    apply Eq.trans
    · apply source.declaration <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.declaration <;> assumption
  argument := by
    intros
    apply Eq.trans
    · apply source.argument <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.argument <;> assumption
  declarations := by
    intros
    apply Eq.trans
    · apply source.declarations <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.declarations <;> assumption
  expressionStep := by
    intros
    apply Eq.trans
    · apply source.expressionStep <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.expressionStep <;> assumption
  tail := by
    intros
    apply Eq.trans
    · apply source.tail <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.tail <;> assumption
  fits := by
    intros
    apply Eq.trans
    · apply source.fits <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.fits <;> assumption
  comparison := by
    intros
    apply Eq.trans
    · apply source.comparison <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.comparison <;> assumption
  expression := by
    intros
    apply Eq.trans
    · apply source.expression <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.expression <;> assumption
  target := by
    intros
    apply Eq.trans
    · apply source.target <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.target <;> assumption
  dynamic := by
    intros
    apply Eq.trans
    · apply source.dynamic <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.dynamic <;> assumption
  assignmentValue := by
    intros
    apply Eq.trans
    · apply source.assignmentValue <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.assignmentValue <;> assumption
  output := by
    intros
    apply Eq.trans
    · apply source.output <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.output <;> assumption
  capacity := by
    intros
    apply Eq.trans
    · apply source.capacity <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.capacity <;> assumption
  workTail := by
    intros
    apply Eq.trans
    · apply source.workTail <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.workTail <;> assumption
  workBudget := by
    intros
    apply Eq.trans
    · apply source.workBudget <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.workBudget <;> assumption

theorem normalized_definitions (calls : Calls)
    (meaning : Compose.Lexical.Meaning calls.primitive)
    (source : DefinitionEquations calls calls) (legal : LegalBodies calls) :
    DefinitionEquations calls where
  toHelperEquations := normalized_helpers calls meaning source.toHelperEquations legal.toLegalHelpers
  stepRange := source.stepRange
  step := by
    intros
    apply Eq.trans
    · apply source.step <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.step <;> assumption
  suffix := by
    intros
    apply Eq.trans
    · apply source.suffix <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.suffix <;> assumption
  formMember := by
    intros
    apply Eq.trans
    · apply source.formMember <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.formMember <;> assumption
  member := by
    intros
    apply Eq.trans
    · apply source.member <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.member <;> assumption
  arguments := by
    intros
    apply Eq.trans
    · apply source.arguments <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.arguments <;> assumption
  assignment := by
    intros
    apply Eq.trans
    · apply source.assignment <;> assumption
    · apply Expr.eval_lexical calls meaning
      apply legal.assignment <;> assumption

end Silver.Compose.Expressions
