module

public import Silver.ScalarArrayAttributeEquations
public import Silver.ScalarExpressionNativeTableStep

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option maxRecDepth 10000
set_option maxHeartbeats 4000000
set_option linter.unusedSimpArgs false


/-- The native reader alias retains the grammar's complete result contract. -/
private theorem tableReader_type {text : Source} (valid : ValidText text) {position maskFirst maskAfter : Nat}
    {names : Environment} {allowSign : Bool} {arrays : ArrayBindings.Table}
    {initials : ArrayBindings.Initials} {elaborating : Bool} {arrayReads : ArrayReadMode}
    (bound : position ≤ text.length + 1) :
    ResultType (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads) :=
  table_read_type valid bound

private theorem tableReader_bounds {text : Source} {names : Environment} {arrays : ArrayBindings.Table}
    {position maskFirst maskAfter : Nat} {allowSign elaborating : Bool} {initials : ArrayBindings.Initials}
    {arrayReads : ArrayReadMode} (bound : position ≤ text.length + 1)
    (success : (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).after ≠ 0) :
    position < (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).after ∧
      (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).after ≤ text.length + 1 ∧
      0 < (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).operands ∧
      (tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads).operands ≤ maxOperands :=
  table_read_bounds bound success

theorem interpreted_arrayAtom (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter target : Nat)
    (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidTable text arrays)
    (values : ArrayBindings.ValidInitials initials) (targetPositive : 0 < target) (targetBound : target ≤ arrays.items.length)
    (recurse : ∀ next sign, position < next → next ≤ text.length + 1 →
      calls.readExpression text next names maskFirst maskAfter sign arrays [] false .noElements = tableReader text next names maskFirst maskAfter sign arrays [] false .noElements) :
    calls.readArrayAtom text position names maskFirst maskAfter target arrays initials elaborating =
      tableArrayAtomStep (@tableReader) text position names maskFirst maskAfter target arrays initials elaborating := by
  rw [equations.arrayAtom text valid position names maskFirst maskAfter target arrays initials elaborating
      bound environment mask metadata values targetPositive targetBound, arrayAtom_denotation]
  unfold arrayAtomEquation tableArrayAtomStep
  rw [interpreted_symbol calls primitives equations text valid position 40 bound (by decide)]
  dsimp only
  split
  · rfl
  · rename_i opened
    have opening := symbol_bounds bound (show symbol text position 40 ≠ 0 by omega)
    rw [recurse _ true opening.1 opening.2]
    have childType : ResultType (tableReader text (symbol text position 40) names maskFirst maskAfter true arrays [] false .noElements) :=
      tableReader_type valid opening.2
    have childBound : (tableReader text (symbol text position 40) names maskFirst maskAfter true arrays [] false .noElements).after ≤ text.length + 1 := by
      by_cases zero : (tableReader text (symbol text position 40) names maskFirst maskAfter true arrays [] false .noElements).after = 0
      · omega
      · exact (tableReader_bounds opening.2 zero).2.1
    rw [interpreted_symbol calls primitives equations text valid _ 41 childBound (by decide)]
    have itemValid := (metadata.binding_valid targetPositive targetBound).2.1
    have itemType := ArrayBindings.validNativeBinding_type itemValid
    rw [ArrayBindings.Native.interpreted_contains calls.arrays primitives.arrayPrimitives primitives.arrayEquations
      _ _ itemType childType.2.1]
    split
    · rfl
    · rename_i accepted
      have inside : ArrayBindings.contains (ArrayBindings.binding arrays.items target)
          (tableReader text (symbol text position 40) names maskFirst maskAfter true arrays [] false .noElements).bounds = true := by
        cases found : ArrayBindings.contains (ArrayBindings.binding arrays.items target)
          (tableReader text (symbol text position 40) names maskFirst maskAfter true arrays [] false .noElements).bounds <;> simp_all
      rw [ArrayBindings.Native.interpreted_readBounds calls.arrays primitives.arrayPrimitives primitives.arrayEquations
        arrays initials elaborating target _ metadata.2.1 values targetPositive targetBound itemValid inside]

theorem interpreted_atom (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidTable text arrays)
    (values : ArrayBindings.ValidInitials initials)
    (recurse : ∀ next sign, position < next → next ≤ text.length + 1 →
      calls.readExpression text next names maskFirst maskAfter sign arrays [] false .noElements = tableReader text next names maskFirst maskAfter sign arrays [] false .noElements) :
    calls.readAtom text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      tableAtomStep (@tableReader) text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
  rw [equations.atom text valid position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads
      bound environment mask metadata values, atom_denotation]
  have firstBounds := skip_bounds text position bound
  have afterBound := nameAfter_bounds text (skip text position)
  unfold atomEquation tableAtomStep
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
            · rw [interpreted_symbol calls primitives equations text valid _ 39 afterBound (by decide)]
              split
              · exact interpreted_arrayAttribute calls primitives equations text valid position names arrays
                  maskFirst maskAfter false bound environment mask metadata
              · split
                · rfl
                · rename_i target
                  exact interpreted_arrayAtom calls primitives equations text valid _ names maskFirst maskAfter _
                    arrays initials elaborating afterBound environment mask metadata values (by omega)
                    (ArrayBindings.Native.lookup_bound text arrays.items _ _)
                    (by
                      intro next sign advanced nextBound
                      apply recurse next sign (by have before := named.2.1; omega) nextBound)

theorem interpreted_readExpression_table (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (arrays : ArrayBindings.Table) (initials : ArrayBindings.Initials) (elaborating : Bool) (arrayReads : ArrayReadMode)
    (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) (metadata : ArrayBindings.ValidTable text arrays)
    (values : ArrayBindings.ValidInitials initials) :
    calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
      ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads := by
  have total : ∀ budget position allowSign arrays initials elaborating arrayReads,
      ArrayBindings.ValidTable text arrays → ArrayBindings.ValidInitials initials → position ≤ text.length + 1 →
      text.length + 1 - position = budget →
      calls.readExpression text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
        tableReader text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads := by
    intro budget
    induction budget using Nat.strongRecOn with
    | ind budget ih =>
      intro position allowSign arrays initials elaborating arrayReads metadata values bound measure
      rw [equations.expression text valid position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads bound environment mask metadata values,
        expression_denotation]
      change expressionEquation calls text position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads =
        ArrayGrammar.read text position names arrays maskFirst maskAfter allowSign initials elaborating arrayReads
      rw [← table_read_step environment metadata values elaborating position maskFirst maskAfter allowSign arrayReads bound]
      unfold expressionEquation tableReadStep
      rw [interpreted_skip calls primitives equations text valid position bound]
      have firstBounds := skip_bounds text position bound
      dsimp only
      split
      · rfl
      · rename_i validFirst
        split
        · rw [equations.group text valid _ names maskFirst maskAfter arrays initials elaborating arrayReads (by omega) (by omega) environment mask metadata values,
            group_denotation]
          unfold groupEquation tableGroupStep
          rw [interpreted_skip calls primitives equations text valid _ (by omega)]
          have innerBounds := skip_bounds text (skip text position + 1) (by omega)
          dsimp only
          split
          · rfl
          · rename_i validInner
            split
            · rename_i sign
              rw [equations.readUnary text valid _ names maskFirst maskAfter arrays initials elaborating arrayReads (by omega) (by omega) sign environment mask metadata values,
                unary_read_denotation]
              unfold unaryReadEquation tableUnaryStep unaryStep
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
              · rw [ih _ (by omega) _ false arrays initials elaborating arrayReads metadata values nextBounds.2 rfl]
                rw [interpreted_unary calls primitives equations _ _ (tableReader_type valid nextBounds.2)]
                have resultAfter := unary_result_after
                  (tableReader text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating arrayReads)
                  (Cursor.byteAt text (skip text (skip text position + 1)) == 45)
                have childAfter : (tableReader text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating arrayReads).after
                    ≤ text.length + 1 := by
                  by_cases zero : (tableReader text (skip text (skip text (skip text position + 1) + 1)) names maskFirst maskAfter false arrays initials elaborating arrayReads).after = 0
                  · omega
                  · exact (tableReader_bounds nextBounds.2 zero).2.1
                rw [interpreted_close calls primitives equations text valid _
                  (unary_result_type (tableReader_type valid nextBounds.2) _) (by omega)]
            · rw [ih _ (by omega) _ true arrays initials elaborating arrayReads metadata values innerBounds.2 rfl]
              have childType := tableReader_type (names := names) (maskFirst := maskFirst) (maskAfter := maskAfter)
                (allowSign := true) (arrays := arrays) (initials := initials) (elaborating := elaborating) (arrayReads := arrayReads) valid innerBounds.2
              have childContract :
                  (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after = 0 ∨
                  (skip text position < (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after ∧
                    (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after ≤ text.length + 1 ∧
                    0 < (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).operands) := by
                by_cases zero : (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after = 0
                · exact Or.inl zero
                · have limits := tableReader_bounds innerBounds.2 zero
                  exact Or.inr ⟨by omega,limits.2.1,limits.2.2.1⟩
              have childAfter : (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after ≤ text.length + 1 := by
                rcases childContract with zero | good
                · omega
                · exact good.2.1
              rw [equations.compound text valid _ names _ maskFirst maskAfter arrays initials elaborating arrayReads firstBounds.2 environment mask metadata values childType childContract,
                compound_denotation]
              unfold compoundEquation tableCompoundStep compoundStep
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
                    have childProgress : position < (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after := by
                      rcases childContract with zero | good
                      · have skipped : skip text (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after = 0 := by
                          rw [zero]; rfl
                        exact False.elim (validNext (Or.inl skipped))
                      · omega
                    rw [ih _ (by omega) _ false arrays initials elaborating arrayReads metadata values rightPosition rfl]
                    have rawOperatorBound := binaryAfter_byte_bound supported
                    rw [primitives.lowercase _ rawOperatorBound]
                    have operatorBound := lowercase_byte_bound rawOperatorBound
                    rw [interpreted_binary calls primitives equations _ _ _ childType (tableReader_type valid rightPosition) operatorBound]
                    have resultAfter := binary_result_after
                      (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads)
                      (tableReader text (binaryAfter text (skip text (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after))
                        names maskFirst maskAfter false arrays initials elaborating arrayReads)
                      (Silver.lowercase (Cursor.byteAt text (skip text (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after)))
                    have rightAfter : (tableReader text (binaryAfter text (skip text (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after))
                        names maskFirst maskAfter false arrays initials elaborating arrayReads).after ≤ text.length + 1 := by
                      by_cases zero : (tableReader text (binaryAfter text (skip text (tableReader text (skip text (skip text position + 1)) names maskFirst maskAfter true arrays initials elaborating arrayReads).after))
                        names maskFirst maskAfter false arrays initials elaborating arrayReads).after = 0
                      · omega
                      · exact (tableReader_bounds rightPosition zero).2.1
                    rw [interpreted_close calls primitives equations text valid _
                      (binary_result_type childType (tableReader_type valid rightPosition) _) (by omega)]
        · exact interpreted_atom calls primitives equations text valid _ names maskFirst maskAfter allowSign
            arrays initials elaborating arrayReads firstBounds.2 environment mask metadata values
            (by
              intro next sign advanced nextBound
              exact ih _ (by omega) next sign arrays [] false .noElements
                metadata
                (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements]) nextBound rfl)
  exact total _ position allowSign arrays initials elaborating arrayReads metadata values bound rfl

theorem interpreted_readExpression (calls : Calls) (primitives : Primitives calls) (equations : Equations calls)
    (text : Source) (valid : ValidText text) (position : Nat) (names : Environment) (maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) (environment : ValidEnvironment text names)
    (mask : ValidMask text maskFirst maskAfter) :
    calls.readExpression text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign := by
  rw [interpreted_readExpression_table calls primitives equations text valid position names maskFirst maskAfter
    allowSign {} [] false .allElements bound environment mask
    (by simp [ArrayBindings.ValidTable, ArrayBindings.ValidTypes, ArrayBindings.maxBindings, ArrayBindings.maxTypes])
    (by simp [ArrayBindings.ValidInitials, ArrayBindings.maxElements])]
  exact table_read_empty text position names maskFirst maskAfter allowSign [] false .allElements

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
  arrayAttribute := by intros; rw [arrayAttribute_denotation]; exact (arrayAttribute_model_equation ..).symm
  arrayAtom := by intros; rw [arrayAtom_denotation]; rfl
  atom := by intros; rw [atom_denotation]; rfl
  readUnary := by intros; rw [unary_read_denotation]; rfl
  compound := by intros; rw [compound_denotation]; rfl
  group := by intros; rw [group_denotation]; rfl
  expression text _ position names maskFirst maskAfter allowSign arrays initials elaborating arrayReads bound environment _ metadata values := by
    rw [expression_denotation]
    exact (table_read_step environment metadata values elaborating position maskFirst maskAfter allowSign arrayReads bound).symm

end Silver.ScalarExpression.Native
