import Silver.ComposeExpressions
import Silver.GuardedExpressions

/-! Retained lexical-helper correspondence for the composed recognizer.
Only bodies still present in Silver_Output_Lexical are interpretation premises.
The legacy call records supply names for arbitrary callees; none of their old
suffix, member, or fixed-production equations is assumed here. -/

namespace Silver.Compose.Lexical
open Named Guarded

/-- Evaluation of the checked retained typed trees, on their SPARK-proved
machine domains. In particular this does not assume parser/model equality. -/
structure InterpretedSource (calls : Guarded.Expressions.Calls)
    (token : Source → Nat → String → Bool → Bool) : Prop where
  primitive : Output.Expressions.PrimitiveInterpretation calls.base.output calls.base.primitive
  literal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.base.output.literal text position =
        Output.Expressions.literalBody.eval calls.base.output calls.base.primitive {text, position}
  letter : ∀ item, calls.base.letter item = Arguments.Expressions.letterBody.eval calls.base {text := [], item}
  forbiddenSpelling : ∀ index, calls.base.forbiddenSpelling index = forbiddenNames[index.val]
  tail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position previous, 1 ≤ position → position ≤ text.length + 1 →
      calls.base.identifier.tail text position previous = Arguments.Expressions.tailBody.eval calls.base {text, position, previous}
  finish : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.base.identifier.finish text position = Arguments.Expressions.finishBody.eval calls.base {text, position}
  name : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after word, 1 ≤ first → first < after → after ≤ text.length + 1 →
      0 < word.length → word.length ≤ maxSourceLength →
      calls.base.identifier.name text first after word = Arguments.Expressions.nameBody.eval calls.base {text, first, after, word}
  equal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      calls.base.identifier.equal text leftFirst leftAfter rightFirst rightAfter =
        Arguments.Expressions.equalBody.eval calls.base {text, leftFirst, leftAfter, rightFirst, rightAfter}
  forbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.base.identifier.forbidden text first after = Arguments.Expressions.forbiddenBody.eval calls.base {text, first, after}
  argumentForbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.base.argumentForbidden text first after = Arguments.Expressions.argumentForbiddenBody.eval calls.base {text, first, after}
  decimalTail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position value, 1 ≤ position → position ≤ text.length + 1 → value ≤ maxSourceLength →
      calls.tail text position value = Guarded.Expressions.decimalTailBody.eval calls {text,position,value}
  decimal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.decimal text position = Guarded.Expressions.decimalAtBody.eval calls {text,position}
  length : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.length text position = Guarded.Expressions.literalLengthBody.eval calls {text,position}
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position (spelling : String) word, 1 ≤ position → position ≤ text.length + 1 →
      0 < spelling.toList.length → spelling.toList.length ≤ 16 →
      token text position spelling word = Silver.Expressions.tokenBody.eval
        {text, position, word := spelling.toList.map Char.toNat, wordFlag := word}

/-- Direct projection of arbitrary retained lexical calls into the new parser's
interface. No parser or recursive shell function is replaced by a model here. -/
def primitives (calls : Guarded.Expressions.Calls)
    (token : Source → Nat → String → Bool → Bool) : Compose.Expressions.Primitives where
  trivia := calls.base.primitive.trivia
  literal := calls.base.output.literal
  length := calls.length
  identifier := calls.base.identifier.finish
  forbidden := calls.base.identifier.forbidden
  forbiddenArgument := calls.base.argumentForbidden
  equal := calls.base.identifier.equal
  decimal := calls.decimal
  token := token
  normalize := calls.base.primitive.normalize
  allowed := calls.base.primitive.allowed

/-- Established meanings apply exactly on checked caller domains. Values outside
those domains are deliberately unrestricted. -/
structure Meaning (primitive : Compose.Expressions.Primitives) : Prop where
  trivia : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      primitive.trivia text position = Cursor.triviaPosition text position
  literal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      primitive.literal text position = Output.literalEnd text position
  length : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      primitive.length text position = Guarded.literalLength text position
  identifier : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      primitive.identifier text position = identifierEnd text position
  forbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      primitive.forbidden text first after = Named.forbiddenName text first after
  forbiddenArgument : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      primitive.forbiddenArgument text first after = Arguments.forbiddenName text first after
  equal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      primitive.equal text leftFirst leftAfter rightFirst rightAfter =
        equalName text leftFirst leftAfter rightFirst rightAfter
  decimal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      primitive.decimal text position = Guarded.decimalAt text position
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position (spelling : String) word, 1 ≤ position → position ≤ text.length + 1 →
      0 < spelling.toList.length → spelling.toList.length ≤ 16 →
      primitive.token text position spelling word = fixedAt text position spelling word
  normalize : ∀ text, text.length ≤ maxSourceLength → primitive.normalize text = text
  allowed : ∀ text, primitive.allowed text = text.all allowedCharacter

theorem interpreted_identifier_equations (calls : Guarded.Expressions.Calls) (token : Source → Nat → String → Bool → Bool)
    (source : InterpretedSource calls token) :
    IdentifierEquations calls.base.identifier where
  tail := by
    intro text positive bounded position previous first last
    rw [source.tail text positive bounded position previous first last]
    exact Arguments.Expressions.tail_denotation calls.base _
  finish := by
    intro text positive bounded position first last
    rw [source.finish text positive bounded position first last]
    exact Arguments.Expressions.finish_denotation calls.base _ (fun item => (source.letter item).trans (Arguments.Expressions.letter_denotation calls.base _))
  name := by
    intro text positive bounded first after word start ordered last nonempty wordBound
    rw [source.name text positive bounded first after word start ordered last nonempty wordBound]
    exact Arguments.Expressions.name_denotation calls.base _ nonempty
  equal := by
    intro text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl
    rw [source.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl]
    exact Arguments.Expressions.equal_denotation calls.base _ lo
  forbidden := by
    intro text positive bounded first after start ordered last
    rw [source.forbidden text positive bounded first after start ordered last]
    exact Arguments.Expressions.forbidden_denotation calls.base _ source.forbiddenSpelling


theorem interpreted_argument_forbidden (calls : Guarded.Expressions.Calls) (token : Source → Nat → String → Bool → Bool)
    (source : InterpretedSource calls token)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (first after : Nat) (start : 1 ≤ first) (ordered : first < after) (last : after ≤ text.length + 1) :
    calls.base.argumentForbidden text first after = Arguments.forbiddenName text first after := by
  rw [source.argumentForbidden text positive bounded first after start ordered last,
    Arguments.Expressions.argumentForbidden_denotation]
  unfold Arguments.Expressions.argumentForbiddenEquation
  have identifiers := interpreted_identifier_equations calls token source
  rw [Named.forbidden_implementation calls.base.identifier identifiers text positive bounded first after start ordered last]
  rw [identifiers.name text positive bounded first after ("silver_arguments".toList.map Char.toNat)
    start ordered last (by decide) (by decide)]
  rfl

theorem interpreted_tail (calls : Guarded.Expressions.Calls) (token : Source → Nat → String → Bool → Bool)
    (source : InterpretedSource calls token)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position value : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (valueBound : value ≤ maxSourceLength) : calls.tail text position value = decimalTail text position value := by
  apply decimalTail_unique text (calls.tail text) _ position value first last valueBound
  intro position value first last valueBound
  rw [source.decimalTail text positive bounded position value first last valueBound, Guarded.Expressions.decimalTail_denotation]

theorem interpreted_length (calls : Guarded.Expressions.Calls) (token : Source → Nat → String → Bool → Bool)
    (source : InterpretedSource calls token)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.length text position = literalLength text position := by
  apply literalLength_unique text (calls.length text) _ position first last
  intro position first last
  rw [source.length text positive bounded position first last, Guarded.Expressions.literalLength_denotation]

theorem interpreted_decimal (calls : Guarded.Expressions.Calls) (token : Source → Nat → String → Bool → Bool)
    (source : InterpretedSource calls token)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.decimal text position = decimalAt text position := by
  rw [source.decimal text positive bounded position first last, Guarded.Expressions.decimalAt_denotation]
  change decimalAtEquation (calls.tail text) text position = decimalAt text position
  unfold decimalAtEquation decimalAt
  split
  · rfl
  · rename_i valid
    split
    · rfl
    · have valueBound : Cursor.byteAt text position - 48 ≤ maxSourceLength := by
        simp only [digit, maxSourceLength] at valid ⊢
        omega
      rw [interpreted_tail calls token source text positive bounded (position + 1)
        (Cursor.byteAt text position - 48) (by omega) (by omega) valueBound]

theorem token_denotation (text : Source) (position : Nat) (spelling : String) (word : Bool)
    (last : position ≤ text.length + 1) :
    Silver.Expressions.tokenBody.eval
      {text, position, word := (spelling.toList.map Char.toNat), wordFlag := word} = fixedAt text position spelling word := by
  let context : Silver.Expressions.Context := {text, position, word := (spelling.toList.map Char.toNat), wordFlag := word}
  have quantified := Silver.Expressions.quantified_word_denotation context
  have bound : (spelling.toList.length : Int) ≤ (text.length : Int) - position + 1 ↔
      spelling.toList.length ≤ text.length + 1 - position := by omega
  change Silver.Expressions.tokenBody.eval context = _
  simp only [Silver.Expressions.tokenBody, Silver.Expressions.Condition.eval]
  change (_ && (Silver.Expressions.Condition.forallWord Silver.Expressions.wordEqualityBody).eval context && _) = _
  rw [quantified]
  simp [Silver.Expressions.Number.eval, context, fixedAt, bound, ← Int.natCast_add]

theorem interpreted_literal (calls : Guarded.Expressions.Calls)
    (token : Source → Nat → String → Bool → Bool) (source : InterpretedSource calls token)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.base.output.literal text position = Output.literalEnd text position := by
  apply Output.literalEnd_unique text (calls.base.output.literal text) _ position first last
  intro position first last
  rw [source.literal text positive bounded position first last,
    Output.Expressions.literal_denotation]

/-- The retained checked helper definitions uniquely determine every primitive
used by ComposeEquations on its actual machine domains. -/
theorem interpreted_primitives (calls : Guarded.Expressions.Calls)
    (token : Source → Nat → String → Bool → Bool) (source : InterpretedSource calls token) :
    Meaning (primitives calls token) where
  trivia := Output.primitive_trivia calls.base.primitive
    (Output.Expressions.primitive_interpreted_equations calls.base.output calls.base.primitive source.primitive)
  literal := interpreted_literal calls token source
  length := interpreted_length calls token source
  identifier := Named.identifier_implementation calls.base.identifier
    (interpreted_identifier_equations calls token source)
  forbidden := Named.forbidden_implementation calls.base.identifier
    (interpreted_identifier_equations calls token source)
  forbiddenArgument := interpreted_argument_forbidden calls token source
  equal := (interpreted_identifier_equations calls token source).equal
  decimal := interpreted_decimal calls token source
  token := by
    intro text positive bounded position spelling word first last nonempty wordBound
    exact (source.token text positive bounded position spelling word first last nonempty wordBound).trans
      (token_denotation text position spelling word last)
  normalize := source.primitive.normalize
  allowed := (Output.Expressions.primitive_interpreted_equations
    calls.base.output calls.base.primitive source.primitive).allowed

/-- Inhabitation of the narrowed helper interface. This is a consistency
witness, not the premise linking arbitrary actual Ada calls to checked trees. -/
theorem model_interpreted : InterpretedSource Guarded.Expressions.modelCalls fixedAt where
  primitive := Guarded.Expressions.model_interpreted.inherited.output.primitive
  literal := Guarded.Expressions.model_interpreted.inherited.output.literal
  letter := Guarded.Expressions.model_interpreted.inherited.letter
  forbiddenSpelling := Guarded.Expressions.model_interpreted.inherited.forbiddenSpelling
  tail := Guarded.Expressions.model_interpreted.inherited.tail
  finish := Guarded.Expressions.model_interpreted.inherited.finish
  name := Guarded.Expressions.model_interpreted.inherited.name
  equal := Guarded.Expressions.model_interpreted.inherited.equal
  forbidden := Guarded.Expressions.model_interpreted.inherited.forbidden
  argumentForbidden := Guarded.Expressions.model_interpreted.inherited.argumentForbidden
  decimalTail := Guarded.Expressions.model_interpreted.tail
  decimal := Guarded.Expressions.model_interpreted.decimal
  length := Guarded.Expressions.model_interpreted.length
  token := by
    intro text _ _ position spelling word _ last _ _
    exact (token_denotation text position spelling word last).symm

end Silver.Compose.Lexical
