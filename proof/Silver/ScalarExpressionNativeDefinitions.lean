module

public import Silver.ScalarReferenceNative
public import Silver.ScalarExpressionNativeTypes
public import Silver.ScalarArrayAttributeNative

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000

def Span (text : Source) (first after : Nat) : Prop :=
  0 < first ∧ first < after ∧ after ≤ text.length + 1

/-- Imported lexical, literal and interval meanings, restricted to their native
argument domains. No scalar-expression helper correspondence is assumed. -/
structure Primitives (calls : Calls) : Prop where
  arrayPrimitives : ArrayBindings.Native.Primitives calls.arrays
  arrayEquations : ArrayBindings.Native.Equations calls.arrays
  trivia : ∀ text, ValidText text → ∀ position, 0 < position → position ≤ text.length + 1 →
    calls.trivia text position = Cursor.triviaPosition text position
  identifier : ∀ text, ValidText text → ∀ position, 0 < position → position ≤ text.length + 1 →
    calls.identifier text position = Named.identifierEnd text position
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    Span text first after → Span text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  nameIs : ∀ text, ValidText text → ∀ first after word,
    Span text first after → 0 < word.length → word.length ≤ 4096 →
    calls.nameIs text first after word = Named.nameIs text first after word
  lowercase : ∀ byte, byte ≤ 255 → calls.lowercase byte = Silver.lowercase byte
  integerLiteral : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integerLiteral text position = ScalarLiteral.read text position
  checked : ∀ lower upper, Integer.WideInRange lower → Integer.WideInRange upper →
    calls.scalars.checked lower upper = Integer.checked ⟨lower,upper⟩
  negate : ∀ value, value.Bounded → calls.scalars.negate value = Integer.checkedNegate value
  add : ∀ left right, left.Bounded → right.Bounded → calls.scalars.add left right = Integer.checkedAdd left right
  subtract : ∀ left right, left.Bounded → right.Bounded → calls.scalars.subtract left right = Integer.checkedSubtract left right
  multiply : ∀ left right, left.Bounded → right.Bounded → calls.scalars.multiply left right = Integer.checkedMultiply left right
  divide : ∀ left right, left.Bounded → right.Bounded → calls.scalars.divide left right = Integer.checkedDivide left right
  modulo : ∀ left right, left.Bounded → right.Bounded → calls.scalars.modulo left right = Integer.checkedModulo left right
  remainder : ∀ left right, left.Bounded → right.Bounded → calls.scalars.remainder left right = Integer.checkedRemainder left right
  normalize : ∀ value, value.Bounded → calls.scalars.normalize value = value.normalize

/-- Typed body interpretation and exact checked runtime refinements. These
premises retain the actual native preconditions and do not assert admission. -/
structure Equations (calls : Calls) : Prop where
  lookupModel : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    ∀ first after index qualifierFirst qualifierAfter,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.length →
    QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
    calls.lookupModel text names first after index qualifierFirst qualifierAfter =
      lookupBody.eval calls ({text,names,first,after,index,qualifierFirst,qualifierAfter} : Context).locals
  lookup : ∀ text, ValidText text → ∀ names, ValidEnvironment text names →
    ∀ first after qualifierFirst qualifierAfter,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    QualifiedNames.ValidSpan text qualifierFirst qualifierAfter →
    calls.lookup text names first after qualifierFirst qualifierAfter =
      calls.lookupModel text names first after names.length qualifierFirst qualifierAfter
  readReference : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.readReference text position = referenceBody.eval calls ({text,position} : Context).locals
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.skip text position = if position = 0 then 0 else calls.trivia text position
  nameAfter : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = if position = 0 then 0 else calls.identifier text position
  binaryAfter : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.binaryAfter text position = binaryAfterBody.eval calls ({text,position} : Context).locals
  symbol : ∀ text, ValidText text → ∀ position item, position ≤ text.length + 1 → item ≤ 255 →
    calls.symbol text position item = symbolBody.eval calls ({text,position,item} : Context).locals
  literal : ∀ number negative, LiteralType number →
    calls.literalResult number negative = literalBody.eval calls ({number,negative} : Context).locals
  unary : ∀ operand negative, ResultType operand →
    calls.unaryResult operand negative = unaryBody.eval calls ({operand,negative} : Context).locals
  binary : ∀ left right operator, ResultType left → ResultType right → operator ≤ 255 →
    calls.binaryResult left right operator = binaryBody.eval calls ({left,right,operator} : Context).locals
  close : ∀ text, ValidText text → ∀ value, ResultType value → value.after ≤ text.length + 1 →
    calls.closeResult text value = closeBody.eval calls ({text,value} : Context).locals
  arrayAttribute : ∀ text, ValidText text → ∀ position names arrays maskFirst maskAfter rangeQuery,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays →
    calls.readArrayAttribute text position names arrays maskFirst maskAfter rangeQuery =
      arrayAttributeBody.eval calls ({text,position,names,arrays,maskFirst,maskAfter,rangeQuery} : Context).locals
  arrayAtom : ∀ text, ValidText text → ∀ position names maskFirst maskAfter target arrays initials elaborating,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    0 < target → target ≤ arrays.items.length →
    calls.readArrayAtom text position names maskFirst maskAfter target arrays initials elaborating =
      arrayAtomBody.eval calls ({text,position,names,maskFirst,maskAfter,target,arrays,initials,elaborating} : Context).locals
  atom : ∀ text, ValidText text → ∀ position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    calls.readAtom text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      atomBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating,arrayReads} : Context).locals
  readUnary : ∀ text, ValidText text → ∀ position names maskFirst maskAfter arrays initials elaborating arrayReads,
    0 < position → position ≤ text.length → (Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45) →
    ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    calls.readUnary text position names maskFirst maskAfter arrays initials elaborating arrayReads =
      readUnaryBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals
  compound : ∀ text, ValidText text → ∀ position names left maskFirst maskAfter arrays initials elaborating arrayReads,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials → ResultType left →
    (left.after = 0 ∨ (position < left.after ∧ left.after ≤ text.length + 1 ∧ 0 < left.operands)) →
    calls.readCompound text position names left maskFirst maskAfter arrays initials elaborating arrayReads =
      compoundBody.eval calls ({text,position,names,left,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals
  group : ∀ text, ValidText text → ∀ position names maskFirst maskAfter arrays initials elaborating arrayReads,
    0 < position → position ≤ text.length → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    calls.readGroup text position names maskFirst maskAfter arrays initials elaborating arrayReads =
      groupBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating,arrayReads} : Context).locals
  expression : ∀ text, ValidText text → ∀ position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials →
    calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      expressionBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating,arrayReads} : Context).locals

theorem interpreted_skip (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : position ≤ text.length + 1) :
    calls.skip text position = skip text position := by
  rw [equations.skip text valid position bound]
  by_cases zero : position = 0
  · simp [skip, zero]
  · simp [skip, zero, primitives.trivia text valid position (by omega) bound]

theorem interpreted_nameAfter (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : position ≤ text.length + 1) :
    calls.nameAfter text position = nameAfter text position := by
  rw [equations.nameAfter text valid position bound]
  by_cases zero : position = 0
  · simp [nameAfter, zero]
  · simp [nameAfter, zero, primitives.identifier text valid position (by omega) bound]

theorem interpreted_readReference (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : position ≤ text.length + 1) :
    calls.readReference text position = readReference text position := by
  rw [equations.readReference text valid position bound]
  exact reference_body_meaning calls text position bound
    (fun next within => interpreted_skip calls primitives equations text valid next within)
    (fun next within => interpreted_nameAfter calls primitives equations text valid next within)

theorem interpreted_binaryAfter (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (bound : position ≤ text.length + 1) :
    calls.binaryAfter text position = binaryAfter text position := by
  rw [equations.binaryAfter text valid position bound, binaryAfter_denotation]
  unfold binaryAfterEquation binaryAfter
  rw [interpreted_nameAfter calls primitives equations text valid position bound]
  dsimp only
  by_cases invalid : position = 0 ∨ position > text.length
  · simp only [invalid, ↓reduceIte]
  · simp only [invalid, ↓reduceIte]
    split
    · rfl
    · split
      · rfl
      · by_cases unnamed : nameAfter text position = 0
        · simp only [unnamed, ne_eq, not_true_eq_false, false_and, ↓reduceIte]
        · have positive : position ≠ 0 := by omega
          have nameBound := Named.identifierEnd_bounds text position
            (show Named.identifierEnd text position ≠ 0 by simpa [nameAfter, positive] using unnamed)
          have span : Span text position (nameAfter text position) := by
            simp only [Span, nameAfter, positive, ↓reduceIte]
            exact ⟨by omega, nameBound⟩
          rw [primitives.nameIs text valid position _ ("mod".toList.map Char.toNat) span (by decide) (by decide),
            primitives.nameIs text valid position _ ("rem".toList.map Char.toNat) span (by decide) (by decide)]

theorem interpreted_symbol (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position item : Nat) (bound : position ≤ text.length + 1)
    (itemBound : item ≤ 255) : calls.symbol text position item = symbol text position item := by
  rw [equations.symbol text valid position item bound itemBound, symbol_denotation]
  simp only [symbolEquation, interpreted_skip calls primitives equations text valid position bound, symbol]

theorem signed_wide {number : ScalarLiteral.Result} (typed : LiteralType number) (negative : Bool) :
    Integer.WideInRange (signedValue number.value negative) := by
  have cap := typed.2
  cases negative <;> simp only [signedValue, Bool.false_eq_true, ↓reduceIte, Integer.WideInRange]
  all_goals unfold ScalarLiteral.maxMagnitude at cap; simp only [Int.ofNat_eq_natCast]; omega

theorem interpreted_literal (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (number : ScalarLiteral.Result) (negative : Bool) (typed : LiteralType number) :
    calls.literalResult number negative = literalResult number negative := by
  rw [equations.literal number negative typed, literal_denotation]
  simp only [literalEquation, primitives.checked _ _ (signed_wide typed negative) (signed_wide typed negative),
    literalResult, Integer.Interval.singleton]
  rfl

theorem interpreted_unary (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (operand : Result) (negative : Bool) (typed : ResultType operand) :
    calls.unaryResult operand negative = unaryResult operand negative := by
  rw [equations.unary operand negative typed, unary_denotation]
  simp only [unaryEquation, primitives.negate operand.bounds typed.2.1, unaryResult]

theorem interpreted_binary (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (left right : Result) (operator : Nat) (a : ResultType left) (b : ResultType right) (item : operator ≤ 255) :
    calls.binaryResult left right operator = binaryResult left right operator := by
  rw [equations.binary left right operator a b item, binary_denotation]
  simp only [binaryEquation, primitives.add left.bounds right.bounds a.2.1 b.2.1,
    primitives.subtract left.bounds right.bounds a.2.1 b.2.1,
    primitives.multiply left.bounds right.bounds a.2.1 b.2.1,
    primitives.divide left.bounds right.bounds a.2.1 b.2.1,
    primitives.modulo left.bounds right.bounds a.2.1 b.2.1,
    primitives.remainder left.bounds right.bounds a.2.1 b.2.1, binaryResult]

theorem interpreted_close (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (value : Result) (typed : ResultType value)
    (bound : value.after ≤ text.length + 1) : calls.closeResult text value = closeResult text value := by
  rw [equations.close text valid value typed bound, close_denotation]
  simp only [closeEquation, interpreted_symbol calls primitives equations text valid value.after 41 bound (by decide), closeResult]

theorem interpreted_qualifier (calls : Calls) (primitives : Primitives calls)
    (text : Source) (valid : ValidText text) (item : Binding)
    (itemValid : QualifiedNames.ValidSpan text item.qualifierFirst item.qualifierAfter)
    (first after : Nat) (queryValid : QualifiedNames.ValidSpan text first after) :
    (if first = 0 then item.qualifierFirst == 0 else
      decide (0 < item.qualifierFirst) &&
        calls.equalName text item.qualifierFirst item.qualifierAfter first after) =
      QualifiedNames.qualifierMatches text item.qualifierFirst item.qualifierAfter first after := by
  by_cases zero : first = 0
  · simp [QualifiedNames.qualifierMatches, zero]
  · rcases queryValid with absent | span
    · exact False.elim (zero absent.1)
    · by_cases itemZero : item.qualifierFirst = 0
      · simp [QualifiedNames.qualifierMatches, zero, itemZero]
      · rcases itemValid with absent | itemSpan
        · exact False.elim (itemZero absent.1)
        · simp only [QualifiedNames.qualifierMatches, zero, ↓reduceIte]
          rw [primitives.equalName text valid _ _ _ _ itemSpan span]

theorem interpreted_lookupModel_qualified (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ names.length) (qualifierFirst qualifierAfter : Nat)
    (queryValid : QualifiedNames.ValidSpan text qualifierFirst qualifierAfter) :
    calls.lookupModel text names first after index qualifierFirst qualifierAfter =
      lookupFrom text names first after index qualifierFirst qualifierAfter := by
  induction index with
  | zero =>
      rw [equations.lookupModel text valid names environment first after 0 qualifierFirst qualifierAfter
        firstBound afterBound indexBound queryValid,
        lookup_denotation calls text names first after 0 qualifierFirst qualifierAfter]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text valid names environment first after (index + 1) qualifierFirst qualifierAfter
        firstBound afterBound indexBound queryValid,
        lookup_denotation calls text names first after (index + 1) qualifierFirst qualifierAfter]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupEquation, lookupFrom, bad]
      · have itemValid := environment.2 _ (binding_mem (by omega) indexBound)
        have compared := primitives.equalName text valid (binding names (index + 1)).first
          (binding names (index + 1)).after first after
          ⟨itemValid.1,itemValid.2.1,itemValid.2.2.1⟩ ⟨by omega,by omega,afterBound⟩
        have qualifier := interpreted_qualifier calls primitives text valid _ itemValid.2.2.2.2.2
          qualifierFirst qualifierAfter queryValid
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, qualifier, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup_qualified (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (qualifierFirst qualifierAfter : Nat) (queryValid : QualifiedNames.ValidSpan text qualifierFirst qualifierAfter) :
    calls.lookup text names first after qualifierFirst qualifierAfter =
      lookup text names first after qualifierFirst qualifierAfter := by
  rw [equations.lookup text valid names environment first after qualifierFirst qualifierAfter
    firstBound afterBound queryValid]
  exact interpreted_lookupModel_qualified calls primitives equations text valid names environment
    first after names.length firstBound afterBound (Nat.le_refl _) qualifierFirst qualifierAfter queryValid

theorem interpreted_lookupModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ names.length) :
    calls.lookupModel text names first after index = lookupFrom text names first after index :=
  interpreted_lookupModel_qualified calls primitives equations text valid names environment first after index
    firstBound afterBound indexBound 0 0 (Or.inl ⟨rfl,rfl⟩)

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after :=
  interpreted_lookup_qualified calls primitives equations text valid names environment first after
    firstBound afterBound 0 0 (Or.inl ⟨rfl,rfl⟩)

theorem nameAfter_bounds (text : Source) (position : Nat) : nameAfter text position ≤ text.length + 1 := by
  by_cases zero : position = 0
  · simp [nameAfter,zero]
  · by_cases failed : Named.identifierEnd text position = 0
    · simp [nameAfter,zero,failed]
    · simpa only [nameAfter,zero,↓reduceIte] using (Named.identifierEnd_bounds text position failed).2

theorem lookup_invalid (text : Source) (names : Environment) (first after : Nat)
    (bad : first = 0 ∨ after ≤ first) : lookup text names first after = 0 := by
  unfold lookup
  cases names.length <;> simp [lookupFrom,bad]

end Silver.ScalarExpression.Native
