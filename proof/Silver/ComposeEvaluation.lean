import Silver.ComposeEquations
import Silver.ComposeLexical

/-! The actual helper calls are replaced by their proved lexical meanings only
at calls whose native preconditions hold. Legality follows the executed branches
of the typed source trees, including Ada's short-circuit Boolean operators.
No global helper equality or parser/model equivalence is assumed. -/

namespace Silver.Compose.Expressions

def CursorDomain (text : Source) (position : Nat) : Prop :=
  ValidText text ∧ ValidCursor text position

def NameDomain (text : Source) (first after : Nat) : Prop :=
  ValidText text ∧ 1 ≤ first ∧ first < after ∧ after ≤ text.length + 1

mutual
def Number.Legal (calls : Calls) (ctx : Context) : Number → Prop
  | .characterVal a | .group a | .byteAt a => a.Legal calls ctx
  | .add a b | .sub a b => a.Legal calls ctx ∧ b.Legal calls ctx
  | .trivia a | .identifier a | .literal a | .literalLength a | .decimalAfter a | .decimalValue a =>
      a.Legal calls ctx ∧ CursorDomain ctx.text (a.eval calls ctx)
  | .after a | .resultLength a => a.Legal calls ctx
  | .ite c a b | .elsif c a b => c.Legal calls ctx ∧
      if c.eval calls ctx then a.Legal calls ctx else b.Legal calls ctx
  | _ => True

def Condition.Legal (calls : Calls) (ctx : Context) : Condition → Prop
  | .eq a b | .ne a b | .lt a b | .le a b | .gt a b => a.Legal calls ctx ∧ b.Legal calls ctx
  | .range a b c => a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx
  | .andThen a b => a.Legal calls ctx ∧ (a.eval calls ctx = true → b.Legal calls ctx)
  | .orElse a b => a.Legal calls ctx ∧ (a.eval calls ctx = false → b.Legal calls ctx)
  | .not a | .group a => a.Legal calls ctx
  | .forbidden a b | .forbiddenArgument a b =>
      a.Legal calls ctx ∧ b.Legal calls ctx ∧ NameDomain ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .equalName a b c d => a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx ∧ d.Legal calls ctx ∧
      NameDomain ctx.text (a.eval calls ctx) (b.eval calls ctx) ∧
      NameDomain ctx.text (c.eval calls ctx) (d.eval calls ctx)
  | .fixedAt a => a.Legal calls ctx ∧ CursorDomain ctx.text (a.eval calls ctx) ∧
      0 < (spelling ctx.token).toList.length ∧ (spelling ctx.token).toList.length ≤ 16
  | .resultDynamic a | .resultStatic a => a.Legal calls ctx
  | .suffix a b => a.Legal calls ctx ∧ b.Legal calls ctx
  | .suffixNormalized | .allowedNormalized => ctx.text.length ≤ maxSourceLength
  | .ite c a b | .elsif c a b => c.Legal calls ctx ∧
      if c.eval calls ctx then a.Legal calls ctx else b.Legal calls ctx
  | _ => True

def Result.Legal (calls : Calls) (ctx : Context) : Result → Prop
  | .record a b c d => a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx ∧ d.Legal calls ctx
  | .operand a b c d e f g h i j k l | .expression a b c d e f g h i j k l =>
      a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx ∧ d.Legal calls ctx ∧ e.Legal calls ctx ∧ f.Legal calls ctx ∧ g.Legal calls ctx ∧ h.Legal calls ctx ∧ i.Legal calls ctx ∧ j.Legal calls ctx ∧ k.Legal calls ctx ∧ l.Legal calls ctx
  | .tail a b c d e f g h i j k l m n o p =>
      a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx ∧ d.Legal calls ctx ∧ e.Legal calls ctx ∧ f.Legal calls ctx ∧ g.Legal calls ctx ∧ h.Legal calls ctx ∧ i.Legal calls ctx ∧ j.Legal calls ctx ∧ k.Legal calls ctx ∧ l.Legal calls ctx ∧ m.Legal calls ctx ∧ n.Legal calls ctx ∧ o.Legal calls ctx ∧ p.Legal calls ctx
  | .group a => a.Legal calls ctx
  | .ite c a b | .elsif c a b => c.Legal calls ctx ∧
      if c.eval calls ctx then a.Legal calls ctx else b.Legal calls ctx
  | _ => True

def State.Legal (calls : Calls) (ctx : Context) : State → Prop
  | .position a | .step a => a.Legal calls ctx
  | .staticBinding a b c | .dynamicBinding a b c | .constantOneBinding a b c | .constantTwoBinding a b c | .constantValues a b c =>
      a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx
  | .declarations a b c d e f g => a.Legal calls ctx ∧ b.Legal calls ctx ∧ c.Legal calls ctx ∧ d.Legal calls ctx ∧ e.Legal calls ctx ∧ f.Legal calls ctx ∧ g.Legal calls ctx
  | .length a b | .capacity a b => a.Legal calls ctx ∧ b.Legal calls ctx
  | .group a => a.Legal calls ctx
  | .ite c a b | .elsif c a b => c.Legal calls ctx ∧
      if c.eval calls ctx then a.Legal calls ctx else b.Legal calls ctx
  | _ => True
end

mutual
theorem Number.eval_lexical (calls : Calls) (meaning : Compose.Lexical.Meaning calls.primitive) (ctx : Context) :
    ∀ (expression : Number) (_legal : expression.Legal calls ctx),
      expression.eval calls ctx = expression.eval (lexical calls) ctx
  | .characterVal a, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal]
      rfl
  | .group a, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal]
      rfl
  | .byteAt a, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal]
      rfl
  | .add a b, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .sub a b, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .trivia a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.trivia ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .identifier a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.identifier ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .literal a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.literal ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .literalLength a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.length ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .decimalAfter a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.decimal ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .decimalValue a, legal => by
      dsimp +instances only [Number.Legal] at legal
      have argument := Number.eval_lexical calls meaning ctx a legal.1
      have value := meaning.decimal ctx.text legal.2.1.1 legal.2.1.2
        (a.eval calls ctx) legal.2.2.1 legal.2.2.2
      dsimp +instances only [Number.eval, lexical, modelPrimitives]
      rw [value, argument]
      rfl
  | .after a, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Result.eval_lexical calls meaning ctx a legal]
      rfl
  | .resultLength a, legal => by
      dsimp +instances only [Number.Legal] at legal
      dsimp +instances only [Number.eval, lexical]
      rw [Result.eval_lexical calls meaning ctx a legal]
      rfl
  | .ite c a b, legal => by
      dsimp +instances only [Number.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Number.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Number.eval_lexical calls meaning ctx b legal.2
      · exact Number.eval_lexical calls meaning ctx a legal.2
  | .elsif c a b, legal => by
      dsimp +instances only [Number.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Number.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Number.eval_lexical calls meaning ctx b legal.2
      · exact Number.eval_lexical calls meaning ctx a legal.2
  | .constant _, _ => rfl
  | .character _, _ => rfl
  | .position, _ => rfl
  | .last, _ => rfl
  | .sourceLength, _ => rfl
  | .maxLength, _ => rfl
  | .maxOperands, _ => rfl
  | .length, _ => rfl
  | .remaining, _ => rfl
  | .nextToken, _ => rfl
  | .tokensLast, _ => rfl
  | .staticFirst, _ => rfl
  | .staticAfter, _ => rfl
  | .staticLength, _ => rfl
  | .dynamicFirst, _ => rfl
  | .dynamicAfter, _ => rfl
  | .statePosition, _ => rfl
  | .stateStaticFirst, _ => rfl
  | .stateStaticAfter, _ => rfl
  | .stateStaticLength, _ => rfl
  | .stateDynamicFirst, _ => rfl
  | .stateDynamicAfter, _ => rfl
  | .stateCapacity, _ => rfl
  | .constantOneFirst, _ => rfl
  | .constantOneAfter, _ => rfl
  | .constantOneValueFirst, _ => rfl
  | .constantTwoFirst, _ => rfl
  | .constantTwoAfter, _ => rfl
  | .constantTwoValueFirst, _ => rfl
  | .stateConstantOneFirst, _ => rfl
  | .stateConstantOneAfter, _ => rfl
  | .stateConstantOneValueFirst, _ => rfl
  | .stateConstantTwoFirst, _ => rfl
  | .stateConstantTwoAfter, _ => rfl
  | .stateConstantTwoValueFirst, _ => rfl
  | .spellingLength, _ => rfl
theorem Condition.eval_lexical (calls : Calls) (meaning : Compose.Lexical.Meaning calls.primitive) (ctx : Context) :
    ∀ (expression : Condition) (_legal : expression.Legal calls ctx),
      expression.eval calls ctx = expression.eval (lexical calls) ctx
  | .eq a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .ne a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .lt a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .le a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .gt a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .range a b c, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .not a, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Condition.eval_lexical calls meaning ctx a legal]
      rfl
  | .group a, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Condition.eval_lexical calls meaning ctx a legal]
      rfl
  | .andThen a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have left := Condition.eval_lexical calls meaning ctx a legal.1
      dsimp +instances only [Condition.eval]
      rw [← left]
      cases selected : a.eval calls ctx
      all_goals simp only [Bool.false_and, Bool.true_and]
      all_goals exact Condition.eval_lexical calls meaning ctx b (legal.2 selected)
  | .orElse a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have left := Condition.eval_lexical calls meaning ctx a legal.1
      dsimp +instances only [Condition.eval]
      rw [← left]
      cases selected : a.eval calls ctx
      all_goals simp only [Bool.false_or, Bool.true_or]
      all_goals exact Condition.eval_lexical calls meaning ctx b (legal.2 selected)
  | .forbidden a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have value := meaning.forbidden ctx.text legal.2.2.1.1 legal.2.2.1.2
        (a.eval calls ctx) (b.eval calls ctx) legal.2.2.2.1 legal.2.2.2.2.1 legal.2.2.2.2.2
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [value, Number.eval_lexical calls meaning ctx a legal.1,
        Number.eval_lexical calls meaning ctx b legal.2.1]
      rfl
  | .forbiddenArgument a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have value := meaning.forbiddenArgument ctx.text legal.2.2.1.1 legal.2.2.1.2
        (a.eval calls ctx) (b.eval calls ctx) legal.2.2.2.1 legal.2.2.2.2.1 legal.2.2.2.2.2
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [value, Number.eval_lexical calls meaning ctx a legal.1,
        Number.eval_lexical calls meaning ctx b legal.2.1]
      rfl
  | .equalName a b c d, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have left := legal.2.2.2.2.1
      have right := legal.2.2.2.2.2
      have value := meaning.equal ctx.text left.1.1 left.1.2
        (a.eval calls ctx) (b.eval calls ctx) (c.eval calls ctx) (d.eval calls ctx)
        left.2.1 left.2.2.1 left.2.2.2 right.2.1 right.2.2.1 right.2.2.2
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [value, Number.eval_lexical calls meaning ctx a legal.1,
        Number.eval_lexical calls meaning ctx b legal.2.1,
        Number.eval_lexical calls meaning ctx c legal.2.2.1,
        Number.eval_lexical calls meaning ctx d legal.2.2.2.1]
      rfl
  | .fixedAt a, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have value := meaning.token ctx.text legal.2.1.1.1 legal.2.1.1.2
        (a.eval calls ctx) (spelling ctx.token) (isWord ctx.token)
        legal.2.1.2.1 legal.2.1.2.2 legal.2.2.1 legal.2.2.2
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [value, Number.eval_lexical calls meaning ctx a legal.1]
      rfl
  | .resultDynamic a, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Result.eval_lexical calls meaning ctx a legal]
      rfl
  | .resultStatic a, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Result.eval_lexical calls meaning ctx a legal]
      rfl
  | .suffix a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [State.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .suffixNormalized, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [meaning.normalize ctx.text legal]
      rfl
  | .allowedNormalized, legal => by
      dsimp +instances only [Condition.Legal] at legal
      dsimp +instances only [Condition.eval, lexical, modelPrimitives]
      rw [meaning.normalize ctx.text legal]
      exact meaning.allowed ctx.text
  | .ite c a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Condition.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Condition.eval_lexical calls meaning ctx b legal.2
      · exact Condition.eval_lexical calls meaning ctx a legal.2
  | .elsif c a b, legal => by
      dsimp +instances only [Condition.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Condition.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Condition.eval_lexical calls meaning ctx b legal.2
      · exact Condition.eval_lexical calls meaning ctx a legal.2
  | .value _, _ => rfl
  | .dynamicSeen, _ => rfl
  | .staticSeen, _ => rfl
  | .tokenEq _, _ => rfl
  | .tokenNe _, _ => rfl
  | .literalToken, _ => rfl
  | .copyToken, _ => rfl
  | .declarationToken, _ => rfl
  | .assignmentForm, _ => rfl
  | .formMember _, _ => rfl
  | .currentFormMember, _ => rfl
  | .someForm _, _ => rfl
  | .firstForm _, _ => rfl
theorem Result.eval_lexical (calls : Calls) (meaning : Compose.Lexical.Meaning calls.primitive) (ctx : Context) :
    ∀ (expression : Result) (_legal : expression.Legal calls ctx),
      expression.eval calls ctx = expression.eval (lexical calls) ctx
  | .record a b c d, legal => by
      dsimp +instances only [Result.Legal] at legal
      dsimp +instances only [Result.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Condition.eval_lexical calls meaning ctx c legal.2.2.1]
      rw [Condition.eval_lexical calls meaning ctx d legal.2.2.2]
      rfl
  | .operand a b c d e f g h i j k l, legal => by
      dsimp +instances only [Result.Legal] at legal
      dsimp +instances only [Result.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2.1]
      rw [Number.eval_lexical calls meaning ctx d legal.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx e legal.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx f legal.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx g legal.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx h legal.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx i legal.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx j legal.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx k legal.2.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx l legal.2.2.2.2.2.2.2.2.2.2.2]
      rfl
  | .expression a b c d e f g h i j k l, legal => by
      dsimp +instances only [Result.Legal] at legal
      dsimp +instances only [Result.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2.1]
      rw [Number.eval_lexical calls meaning ctx d legal.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx e legal.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx f legal.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx g legal.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx h legal.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx i legal.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx j legal.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx k legal.2.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx l legal.2.2.2.2.2.2.2.2.2.2.2]
      rfl
  | .tail a b c d e f g h i j k l m n o p, legal => by
      dsimp +instances only [Result.Legal] at legal
      dsimp +instances only [Result.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2.1]
      rw [Number.eval_lexical calls meaning ctx d legal.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx e legal.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx f legal.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx g legal.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx h legal.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx i legal.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx j legal.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx k legal.2.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx l legal.2.2.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx m legal.2.2.2.2.2.2.2.2.2.2.2.2.1]
      rw [Condition.eval_lexical calls meaning ctx n legal.2.2.2.2.2.2.2.2.2.2.2.2.2.1]
      rw [Condition.eval_lexical calls meaning ctx o legal.2.2.2.2.2.2.2.2.2.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx p legal.2.2.2.2.2.2.2.2.2.2.2.2.2.2.2]
      rfl
  | .group a, legal => by
      dsimp +instances only [Result.Legal] at legal
      dsimp +instances only [Result.eval, lexical]
      rw [Result.eval_lexical calls meaning ctx a legal]
      rfl
  | .ite c a b, legal => by
      dsimp +instances only [Result.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Result.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Result.eval_lexical calls meaning ctx b legal.2
      · exact Result.eval_lexical calls meaning ctx a legal.2
  | .elsif c a b, legal => by
      dsimp +instances only [Result.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [Result.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact Result.eval_lexical calls meaning ctx b legal.2
      · exact Result.eval_lexical calls meaning ctx a legal.2
  | .invalid, _ => rfl
theorem State.eval_lexical (calls : Calls) (meaning : Compose.Lexical.Meaning calls.primitive) (ctx : Context) :
    ∀ (expression : State) (_legal : expression.Legal calls ctx),
      expression.eval calls ctx = expression.eval (lexical calls) ctx
  | .position a, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal]
      rfl
  | .step a, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal]
      rfl
  | .staticBinding a b c, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .dynamicBinding a b c, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .constantOneBinding a b c, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .constantTwoBinding a b c, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .constantValues a b c, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2]
      rfl
  | .declarations a b c d e f g, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2.1]
      rw [Number.eval_lexical calls meaning ctx c legal.2.2.1]
      rw [Number.eval_lexical calls meaning ctx d legal.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx e legal.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx f legal.2.2.2.2.2.1]
      rw [Number.eval_lexical calls meaning ctx g legal.2.2.2.2.2.2]
      rfl
  | .length a b, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .capacity a b, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [Number.eval_lexical calls meaning ctx a legal.1]
      rw [Number.eval_lexical calls meaning ctx b legal.2]
      rfl
  | .group a, legal => by
      dsimp +instances only [State.Legal] at legal
      dsimp +instances only [State.eval, lexical]
      rw [State.eval_lexical calls meaning ctx a legal]
      rfl
  | .ite c a b, legal => by
      dsimp +instances only [State.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [State.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact State.eval_lexical calls meaning ctx b legal.2
      · exact State.eval_lexical calls meaning ctx a legal.2
  | .elsif c a b, legal => by
      dsimp +instances only [State.Legal] at legal
      have condition := Condition.eval_lexical calls meaning ctx c legal.1
      dsimp +instances only [State.eval]
      rw [← condition]
      cases chosen : c.eval calls ctx <;> simp only [chosen, Bool.false_eq_true, ↓reduceIte] at legal ⊢
      · exact State.eval_lexical calls meaning ctx b legal.2
      · exact State.eval_lexical calls meaning ctx a legal.2
  | .current, _ => rfl
  | .initial, _ => rfl
  | .invalid, _ => rfl
end

/-- These are the helper-call preconditions discharged by the native SPARK
analysis of the four bodies that perform lexical operations. The predicate
contains only domains of executed calls, never a model-equivalence equation. -/
structure LegalBodies (calls : Calls) : Prop where
  operand : ∀ text, ValidText text → ∀ position names,
    ValidCursor text position → ValidNames text names →
    operandBody.Legal calls {text,position,names}
  tail : ∀ text, ValidText text → ∀ names remaining position length dynamicSeen staticSeen,
    ValidCursor text position → ValidNames text names → remaining ≤ maxExpressionOperands → length ≤ maxSourceLength →
    tailBody.Legal calls {text,position,names,remaining,length,dynamicSeen,staticSeen}
  step : ∀ text, ValidText text → ∀ form token state,
    ValidToken token → ValidState text state → 0 < state.position →
    stepBody.Legal calls {text,form,token,state}
  suffix : ∀ text, ValidText text → ∀ form index state,
    ValidState text state → 1 ≤ index → index ≤ form.tokens.length + 1 →
    suffixBody.Legal calls {text,form,nextToken := index,state}

private theorem expressionBody_legal (calls : Calls) (ctx : Context) : expressionBody.Legal calls ctx := by
  simp [expressionBody, Result.Legal, Number.Legal, Condition.Legal]

private theorem formBody_legal (calls : Calls) (ctx : Context) : formBody.Legal calls ctx := by
  dsimp +instances only [formBody, both, Condition.Legal, Number.Legal, Condition.eval, Number.eval]
  simp only [true_and, decide_eq_true_eq, Bool.and_eq_true]
  constructor
  · exact fun bounded => bounded.2
  · exact fun bounded => bounded.1.2

/-- Raw checked body equations evaluate actual lexical callees. Their proved
meanings plus SPARK's legal-call contracts imply the normalized equations used
by recursion uniqueness; lexical interpretation is therefore consumed here. -/
theorem normalized_definitions (calls : Calls)
    (meaning : Compose.Lexical.Meaning calls.primitive)
    (source : DefinitionEquations calls calls) (legal : LegalBodies calls) :
    DefinitionEquations calls where
  operand := by
    intro text valid position names cursor context
    exact (source.operand text valid position names cursor context).trans
      (Result.eval_lexical calls meaning _ _ (legal.operand text valid position names cursor context))
  tail := by
    intro text valid names remaining position length dynamicSeen staticSeen cursor context fuel size
    exact (source.tail text valid names remaining position length dynamicSeen staticSeen cursor context fuel size).trans
      (Result.eval_lexical calls meaning _ _
        (legal.tail text valid names remaining position length dynamicSeen staticSeen cursor context fuel size))
  expression := by
    intro text valid position names cursor context
    exact (source.expression text valid position names cursor context).trans
      (Result.eval_lexical calls meaning _ _ (expressionBody_legal calls _))
  step := by
    intro text valid form token state tokenValid context positive
    exact (source.step text valid form token state tokenValid context positive).trans
      (State.eval_lexical calls meaning _ _ (legal.step text valid form token state tokenValid context positive))
  stepRange := source.stepRange
  suffix := by
    intro text valid form index state context first last
    exact (source.suffix text valid form index state context first last).trans
      (Condition.eval_lexical calls meaning _ _ (legal.suffix text valid form index state context first last))
  formMember := by
    intro text form
    exact (source.formMember text form).trans
      (Condition.eval_lexical calls meaning _ _ (formBody_legal calls _))
  member := by
    intro text
    exact (source.member text).trans
      (Condition.eval_lexical calls meaning _ _ (by trivial))
  arguments := by
    intro text
    exact (source.arguments text).trans
      (Condition.eval_lexical calls meaning _ _ (by trivial))
  assignment := by
    intro text
    exact (source.assignment text).trans
      (Condition.eval_lexical calls meaning _ _ (by
        simp [assignmentBody, Condition.Legal]))

end Silver.Compose.Expressions
