module

public import Silver.ScalarExpressionNativeDenotations
public import Silver.ScalarExpressionNativeTypes
public import Silver.ScalarExpressionNativeArrayRecursion

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
  lookupModel : ∀ text, ValidText text → ∀ names, ValidEnvironment text names → ∀ first after index,
    first ≤ text.length + 1 → after ≤ text.length + 1 → index ≤ names.length →
    calls.lookupModel text names first after index = lookupBody.eval calls ({text,names,first,after,index} : Context).locals
  lookup : ∀ text, ValidText text → ∀ names, ValidEnvironment text names → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = calls.lookupModel text names first after names.length
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
  arrayAtom : ∀ text, ValidText text → ∀ position names maskFirst maskAfter target arrays initials elaborating,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    0 < target → target ≤ arrays.length →
    calls.readArrayAtom text position names maskFirst maskAfter target arrays initials elaborating =
      arrayAtomBody.eval calls ({text,position,names,maskFirst,maskAfter,target,arrays,initials,elaborating} : Context).locals
  atom : ∀ text, ValidText text → ∀ position names maskFirst maskAfter allowSign arrays initials elaborating,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.readAtom text position names maskFirst maskAfter allowSign arrays initials elaborating =
      atomBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating} : Context).locals
  readUnary : ∀ text, ValidText text → ∀ position names maskFirst maskAfter arrays initials elaborating,
    0 < position → position ≤ text.length → (Cursor.byteAt text position = 43 ∨ Cursor.byteAt text position = 45) →
    ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.readUnary text position names maskFirst maskAfter arrays initials elaborating =
      readUnaryBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating} : Context).locals
  compound : ∀ text, ValidText text → ∀ position names left maskFirst maskAfter arrays initials elaborating,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → ResultType left →
    (left.after = 0 ∨ (position < left.after ∧ left.after ≤ text.length + 1 ∧ 0 < left.operands)) →
    calls.readCompound text position names left maskFirst maskAfter arrays initials elaborating =
      compoundBody.eval calls ({text,position,names,left,maskFirst,maskAfter,arrays,initials,elaborating} : Context).locals
  group : ∀ text, ValidText text → ∀ position names maskFirst maskAfter arrays initials elaborating,
    0 < position → position ≤ text.length → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.readGroup text position names maskFirst maskAfter arrays initials elaborating =
      groupBody.eval calls ({text,position,names,maskFirst,maskAfter,arrays,initials,elaborating} : Context).locals
  expression : ∀ text, ValidText text → ∀ position names maskFirst maskAfter allowSign arrays initials elaborating,
    position ≤ text.length + 1 → ValidEnvironment text names → ValidMask text maskFirst maskAfter →
    ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials →
    calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating =
      expressionBody.eval calls ({text,position,names,maskFirst,maskAfter,allowSign,arrays,initials,elaborating} : Context).locals

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

theorem interpreted_lookupModel (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after index : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1)
    (indexBound : index ≤ names.length) :
    calls.lookupModel text names first after index = lookupFrom text names first after index := by
  induction index with
  | zero =>
      rw [equations.lookupModel text valid names environment first after 0 firstBound afterBound indexBound,
        lookup_denotation]
      simp [lookupEquation, lookupFrom]
  | succ index ih =>
      rw [equations.lookupModel text valid names environment first after (index + 1) firstBound afterBound indexBound,
        lookup_denotation]
      by_cases bad : first = 0 ∨ after ≤ first
      · simp [lookupEquation, lookupFrom, bad]
      · have itemValid := environment.2 _ (binding_mem (by omega) indexBound)
        have compared := primitives.equalName text valid (binding names (index + 1)).first
          (binding names (index + 1)).after first after
          ⟨itemValid.1,itemValid.2.1,itemValid.2.2.1⟩ ⟨by omega,by omega,afterBound⟩
        simp only [lookupEquation, lookupFrom, bad, Nat.add_eq_zero_iff, Nat.one_ne_zero,
          and_false, or_false, ↓reduceIte, compared, Nat.add_sub_cancel, ih (by omega)]

theorem interpreted_lookup (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (names : Environment) (environment : ValidEnvironment text names)
    (first after : Nat) (firstBound : first ≤ text.length + 1) (afterBound : after ≤ text.length + 1) :
    calls.lookup text names first after = lookup text names first after := by
  rw [equations.lookup text valid names environment first after firstBound afterBound,
    interpreted_lookupModel calls primitives equations text valid names environment first after names.length
      firstBound afterBound (by omega)]
  rfl

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

theorem interpreted_arrayAtom (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter target : Nat)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidMetadata text arrays)
    (values : ArrayBindings.ValidInitials initials) (targetPositive : 0 < target) (targetBound : target ≤ arrays.length)
    (recurse : ∀ next sign, position < next → next ≤ text.length + 1 →
      calls.readExpression text next names maskFirst maskAfter sign = read text next names maskFirst maskAfter sign) :
    calls.readArrayAtom text position names maskFirst maskAfter target arrays initials elaborating =
      arrayAtomStep scalarReader text position names maskFirst maskAfter target arrays initials elaborating := by
  rw [equations.arrayAtom text valid position names maskFirst maskAfter target arrays initials elaborating
      bound environment mask metadata values targetPositive targetBound, arrayAtom_denotation]
  unfold arrayAtomEquation arrayAtomStep scalarReader
  rw [interpreted_symbol calls primitives equations text valid position 40 bound (by decide)]
  dsimp only
  split
  · rfl
  · rename_i opened
    have opening := symbol_bounds bound opened
    rw [recurse _ true opening.1 opening.2]
    have childType : ResultType (read text (symbol text position 40) names maskFirst maskAfter true) :=
      read_type valid opening.2
    have childBound : (read text (symbol text position 40) names maskFirst maskAfter true).after ≤ text.length + 1 := by
      by_cases zero : (read text (symbol text position 40) names maskFirst maskAfter true).after = 0
      · omega
      · exact (read_bounds opening.2 zero).2.1
    rw [interpreted_symbol calls primitives equations text valid _ 41 childBound (by decide)]
    have member := ArrayBindings.Native.binding_mem targetPositive targetBound
    have itemValid := (metadata.2.1 _ member).2.2.2
    have itemType : ArrayBindings.Native.BindingType (ArrayBindings.binding arrays target) :=
      ⟨itemValid.1, by have cap := itemValid.2.2.2.1; omega,
        by have cap := itemValid.2.2.2.1; omega, itemValid.2.2.2.2.2.1⟩
    rw [ArrayBindings.Native.interpreted_contains calls.arrays primitives.arrayPrimitives primitives.arrayEquations
      _ _ itemType childType.2.1]
    split
    · rfl
    · rename_i accepted
      have inside : ArrayBindings.contains (ArrayBindings.binding arrays target)
          (read text (symbol text position 40) names maskFirst maskAfter true).bounds = true := by
        cases found : ArrayBindings.contains (ArrayBindings.binding arrays target)
          (read text (symbol text position 40) names maskFirst maskAfter true).bounds <;> simp_all
      rw [ArrayBindings.Native.interpreted_readBounds calls.arrays primitives.arrayPrimitives primitives.arrayEquations
        arrays initials elaborating target _ metadata.1 values targetPositive targetBound itemValid inside]

theorem interpreted_atom (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidMetadata text arrays)
    (values : ArrayBindings.ValidInitials initials)
    (recurse : ∀ next sign, position < next → next ≤ text.length + 1 →
      calls.readExpression text next names maskFirst maskAfter sign = read text next names maskFirst maskAfter sign) :
    calls.readAtom text position names maskFirst maskAfter allowSign arrays initials elaborating =
      arraysAtomStep scalarReader text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  rw [equations.atom text valid position names maskFirst maskAfter allowSign arrays initials elaborating
      bound environment mask metadata values, atom_denotation]
  have firstBounds := skip_bounds text position bound
  have afterBound := nameAfter_bounds text (skip text position)
  unfold atomEquation arraysAtomStep
  rw [interpreted_skip calls primitives equations text valid position bound]
  dsimp only
  rw [interpreted_nameAfter calls primitives equations text valid _ firstBounds.2,
    interpreted_lookup calls primitives equations text valid names environment _ _ firstBounds.2 afterBound,
    ArrayBindings.Native.interpreted_lookup calls.arrays primitives.arrayPrimitives primitives.arrayEquations
      text valid arrays metadata _ _ firstBounds.2 afterBound]
  split
  · rfl
  · rename_i firstValid
    split
    · split
      · rfl
      · have nextBounds := skip_bounds text (skip text position + 1) (by omega)
        rw [interpreted_skip calls primitives equations text valid _ (by omega),
          primitives.integerLiteral text valid _ nextBounds.2,
          interpreted_literal calls primitives equations _ _ (literal_read_type valid nextBounds.2)]
    · rw [primitives.integerLiteral text valid _ firstBounds.2]
      split
      · rw [interpreted_literal calls primitives equations _ _ (literal_read_type valid firstBounds.2)]
      · split
        · rfl
        · rename_i namedNonzero
          have firstPositive : skip text position ≠ 0 := by omega
          have nameBounds := Named.identifierEnd_bounds text (skip text position)
            (show Named.identifierEnd text (skip text position) ≠ 0 by
              simpa only [nameAfter, firstPositive, ↓reduceIte] using namedNonzero)
          have named : Span text (skip text position) (nameAfter text (skip text position)) := by
            simpa only [Span, nameAfter, firstPositive, ↓reduceIte] using And.intro (by omega : 0 < skip text position) nameBounds
          have compared : (maskFirst ≠ 0 ∧ calls.equalName text maskFirst maskAfter
              (skip text position) (nameAfter text (skip text position)) = true) =
              (maskFirst ≠ 0 ∧ Named.equalName text maskFirst maskAfter
              (skip text position) (nameAfter text (skip text position)) = true) := by
            by_cases noMask : maskFirst = 0
            · simp [noMask]
            · have maskSpan : Span text maskFirst maskAfter := by
                rcases mask with absent | active
                · exact False.elim (noMask absent.1)
                · exact active
              rw [primitives.equalName text valid maskFirst maskAfter _ _ maskSpan named]
          simp only [compared]
          split
          · rfl
          · split
            · rename_i present
              rw [primitives.normalize _ (binding_bounded environment (by omega) (lookup_bound text names _ _))]
            · split
              · rfl
              · rename_i target
                exact interpreted_arrayAtom calls primitives equations text valid _ names maskFirst maskAfter _
                  arrays initials elaborating afterBound environment mask metadata values (by omega)
                  (ArrayBindings.Native.lookup_bound text arrays _ _)
                  (by
                    intro next sign advanced nextBound
                    apply recurse next sign (by have before := named.2.1; omega) nextBound)

theorem interpreted_readExpression_arrays (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidMetadata text arrays)
    (values : ArrayBindings.ValidInitials initials) :
    calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating =
      read text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  have total : ∀ budget position allowSign arrays initials elaborating,
      ArrayBindings.ValidMetadata text arrays → ArrayBindings.ValidInitials initials → position ≤ text.length + 1 →
      text.length + 1 - position = budget →
      calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating =
        read text position names maskFirst maskAfter allowSign arrays initials elaborating := by
    intro budget
    induction budget using Nat.strongRecOn with
    | ind budget ih =>
      intro position allowSign arrays initials elaborating metadata values bound measure
      rw [equations.expression text valid position names maskFirst maskAfter allowSign arrays initials elaborating bound environment mask metadata values,
        expression_denotation, ← arrays_read_step environment metadata values elaborating position maskFirst maskAfter allowSign bound]
      unfold expressionEquation arraysReadStep
      rw [interpreted_skip calls primitives equations text valid position bound]
      have firstBounds := skip_bounds text position bound
      dsimp only
      split
      · rfl
      · rename_i validFirst
        split
        · rw [equations.group text valid _ names maskFirst maskAfter arrays initials elaborating (by omega) (by omega) environment mask metadata values,
            group_denotation]
          unfold groupEquation arraysGroupStep
          rw [interpreted_skip calls primitives equations text valid _ (by omega)]
          have innerBounds := skip_bounds text (skip text position + 1) (by omega)
          dsimp only
          split
          · rfl
          · rename_i validInner
            split
            · rename_i sign
              rw [equations.readUnary text valid _ names maskFirst maskAfter arrays initials elaborating (by omega) (by omega) sign environment mask metadata values,
                unary_read_denotation]
              unfold unaryReadEquation arraysUnaryStep unaryStep
              rw [interpreted_skip calls primitives equations text valid _ (by omega)]
              have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              dsimp only
              rw [primitives.integerLiteral text valid _ nextBounds.2]
              split
              · rw [interpreted_literal calls primitives equations _ _ (literal_read_type valid nextBounds.2)]
                have resultAfter := literal_result_after
                  (ScalarLiteral.read text (skip text (skip text (skip text position + 1) + 1)))
                  (Cursor.byteAt text (skip text (skip text position + 1)) == 45)
                have numberAfter := (literal_read_bounds nextBounds.2).1
                rw [interpreted_close calls primitives equations text valid _
                  (literal_result_type (literal_read_type valid nextBounds.2) _) (by omega)]
              · rw [ih _ (by omega) _ false arrays initials elaborating metadata values nextBounds.2 rfl]
                rw [interpreted_unary calls primitives equations _ _ (read_type valid nextBounds.2)]
                have resultAfter := unary_result_after
                  (read text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating)
                  (Cursor.byteAt text (skip text (skip text position + 1)) == 45)
                have childAfter : (read text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating).after
                    ≤ text.length + 1 := by
                  by_cases zero : (read text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating).after = 0
                  · omega
                  · exact (read_arrays_bounds nextBounds.2 zero).2.1
                rw [interpreted_close calls primitives equations text valid _
                  (unary_result_type (read_type valid nextBounds.2) _) (by omega)]
            · rw [ih _ (by omega) _ true arrays initials elaborating metadata values innerBounds.2 rfl]
              have childType := read_type (names := names) (maskFirst := maskFirst) (maskAfter := maskAfter)
                (allowSign := true) (arrays := arrays) (initials := initials) (elaborating := elaborating) valid innerBounds.2
              have childContract :
                  (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after = 0 ∨
                  (skip text position < (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after ∧
                    (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after ≤ text.length + 1 ∧
                    0 < (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).operands) := by
                by_cases zero : (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after = 0
                · exact Or.inl zero
                · have limits := read_arrays_bounds innerBounds.2 zero
                  exact Or.inr ⟨by omega,limits.2.1,limits.2.2.1⟩
              have childAfter : (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after ≤ text.length + 1 := by
                rcases childContract with zero | good
                · omega
                · exact good.2.1
              rw [equations.compound text valid _ names _ maskFirst maskAfter arrays initials elaborating firstBounds.2 environment mask metadata values childType childContract,
                compound_denotation]
              unfold compoundEquation arraysCompoundStep compoundStep
              rw [interpreted_skip calls primitives equations text valid _ childAfter]
              have nextBounds := skip_bounds text _ childAfter
              dsimp only
              rw [interpreted_binaryAfter calls primitives equations text valid _ nextBounds.2]
              split
              · rfl
              · rename_i validNext
                split
                · rfl
                · split
                  · rfl
                  · rename_i supported
                    have operatorBounds := binaryAfter_bounds supported
                    have rightPosition := operatorBounds.2
                    have childProgress : position < (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after := by
                      rcases childContract with zero | good
                      · have skipped : skip text (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after = 0 := by
                          rw [zero]; rfl
                        exact False.elim (validNext (Or.inl skipped))
                      · omega
                    rw [ih _ (by omega) _ false arrays initials elaborating metadata values rightPosition rfl]
                    have rawOperatorBound := binaryAfter_byte_bound supported
                    rw [primitives.lowercase _ rawOperatorBound]
                    have operatorBound := lowercase_byte_bound rawOperatorBound
                    rw [interpreted_binary calls primitives equations _ _ _ childType (read_type valid rightPosition) operatorBound]
                    have resultAfter := binary_result_after
                      (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating)
                      (read text (binaryAfter text (skip text (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after))
                        names maskFirst maskAfter false arrays initials elaborating)
                      (Silver.lowercase (Cursor.byteAt text (skip text (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after)))
                    have rightAfter : (read text (binaryAfter text (skip text (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after))
                        names maskFirst maskAfter false arrays initials elaborating).after ≤ text.length + 1 := by
                      by_cases zero : (read text (binaryAfter text (skip text (read text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating).after))
                        names maskFirst maskAfter false arrays initials elaborating).after = 0
                      · omega
                      · exact (read_arrays_bounds rightPosition zero).2.1
                    rw [interpreted_close calls primitives equations text valid _
                      (binary_result_type childType (read_type valid rightPosition) _) (by omega)]
        · exact interpreted_atom calls primitives equations text valid _ names maskFirst maskAfter allowSign
            arrays initials elaborating firstBounds.2 environment mask metadata values
            (by
              intro next sign advanced nextBound
              exact ih _ (by omega) next sign [] [] false
                (by simp [ArrayBindings.ValidMetadata, ArrayBindings.maxBindings])
                (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements]) nextBound rfl)
  exact total _ position allowSign arrays initials elaborating metadata values bound rfl

theorem interpreted_readExpression (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) :
    calls.readExpression text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign :=
  interpreted_readExpression_arrays calls primitives equations text valid position names maskFirst maskAfter
    allowSign [] [] false bound environment mask
    (by simp [ArrayBindings.ValidMetadata, ArrayBindings.maxBindings])
    (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])

/-- The equation premises admit the independent reader as a concrete witness. -/
theorem model_primitives : Primitives modelCalls where
  arrayPrimitives := ArrayBindings.Native.model_primitives
  arrayEquations := ArrayBindings.Native.model_equations
  trivia _ _ _ _ _ := rfl
  identifier _ _ _ _ _ := rfl
  equalName _ _ _ _ _ _ _ _ := rfl
  nameIs _ _ _ _ _ _ _ _ := rfl
  lowercase _ _ := rfl
  integerLiteral _ _ _ _ := rfl
  checked _ _ _ _ := rfl
  negate _ _ := rfl
  add _ _ _ _ := rfl
  subtract _ _ _ _ := rfl
  multiply _ _ _ _ := rfl
  divide _ _ _ _ := rfl
  modulo _ _ _ _ := rfl
  remainder _ _ _ _ := rfl
  normalize _ _ := rfl

theorem model_equations : Equations modelCalls where
  lookupModel text _ names _ first after index _ _ _ := by
    rw [lookup_denotation]
    cases index <;> simp [lookupEquation,modelCalls,lookupFrom]
    all_goals rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  skip _ _ _ _ := rfl
  nameAfter _ _ _ _ := rfl
  binaryAfter _ _ _ _ := by rw [binaryAfter_denotation]; rfl
  symbol _ _ _ _ _ _ := by rw [symbol_denotation]; rfl
  literal _ _ _ := by rw [literal_denotation]; rfl
  unary _ _ _ := by rw [unary_denotation]; rfl
  binary _ _ _ _ _ _ := by rw [binary_denotation]; rfl
  close _ _ _ _ _ := by rw [close_denotation]; rfl
  arrayAtom := by intros; rw [arrayAtom_denotation]; rfl
  atom := by intros; rw [atom_denotation]; rfl
  readUnary := by intros; rw [unary_read_denotation]; rfl
  compound := by intros; rw [compound_denotation]; rfl
  group := by intros; rw [group_denotation]; rfl
  expression text _ position names maskFirst maskAfter allowSign arrays initials elaborating bound environment _ metadata values := by
    rw [expression_denotation]
    exact (arrays_read_step environment metadata values elaborating position maskFirst maskAfter allowSign bound).symm

end Silver.ScalarExpression.Native
